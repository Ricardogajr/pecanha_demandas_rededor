#include 'protheus.ch'
#include 'fwmvcdef.ch'
#Include "fileio.ch"

/*{Protheus.doc} F0700001
Realiza Upsert em um Registro com modelo MVC.
@author izac.ciszevski
@since 19/01/2017
@param cTabela  , character, Nome da Tabela para Busca
@param aPosChave, array    , Posição da chave de Busca dos Registros sem o campo filial
@param cFonte   , character, Nome do fonte MVC
@param cModelo  , character, Nome do Modelo a ser preenchido
@param aCampos  , array    , campos a serem atualizados no formato {{"CAMPO", xConteudo}}
@param nInd     , numeric  , Opcional - Indice de busca
@Project MAN0000007423041_EF_000
*/
User Function F0700001(cTabela, aPosChave, cFonte, cModelo, aCampos, nInd, nOperation)

    Local cRetorno := ""
    Local lOK      := .T.
    Local aInfo    := {}
    Local nRecLog  := 0
    Local cChave   := ""
    
    Default nOperation := 0
    Default nInd       := 1
    Default aPosChave  := {2}

    aInfo := { cTabela, aPosChave, cFonte, cModelo, aCampos, nInd}
//    nRecLog := u_F07Log01(aCampos[len(aCampos)][2], aInfo, ProcName(1))

    Begin Sequence

        If !U_F07ChkFil(aCampos[1][2])
            cRetorno := "ERRO|Filial Inválida"
            lOK := .f.
            Break 
        EndIf 

	    nRecLog := u_F07Log01(aCampos[len(aCampos)][2], aInfo, ProcName(1))

        aCampos[1][2] := XFilial(cTabela) //-- ajusta a filial
        cChave := U_F0700005(cTabela, aCampos, aPosChave)

        If Empty(nOperation) .or. nOperation == MODEL_OPERATION_UPDATE
            (cTabela)->(DbSetOrder(nInd))
            If (cTabela)->(DbSeek(cChave))
				nOperation := MODEL_OPERATION_UPDATE
            Else
				nOperation := MODEL_OPERATION_INSERT
            EndIf
        EndIf    
        If ( lOK := U_F0700007(cFonte, cModelo, aCampos, nOperation, @cRetorno ))
            cRetorno := "Registro Incluído/Alterado com sucesso"
        EndIf
    
    End Sequence
    
    u_F07Log02(nRecLog, cRetorno, lOK,cTabela)

    aInfo := ASize(aInfo, 0)
    aInfo := Nil

Return cRetorno


/*/{Protheus.doc} GetIntegID
Retorna um ID único para a integração
@author izac.ciszevski
@since 19/01/2017
@Project MAN0000007423041_EF_000 | Funções de Suporte
/*/
User Function GetIntegID()

Return FwUUIDv4()

/*/{Protheus.doc} F07ChkFil
Verifica informação de filial
@author izac.ciszevski
@since 19/01/2017
@version undefined
@param cFilReg, caracter, código da filial a ser verificada
@Project MAN0000007423041_EF_000 - Funções de Suporte
/*/
User Function F07ChkFil(cFilReg)
   If Empty(cFilReg)
      Return .F.
   EndIf

   SM0->(DbSetOrder(1))
   If !SM0->(MsSeek(cEmpAnt + cFilReg))
      SM0->(MsSeek(cEmpAnt + cFilAnt))
      Return .F.
   EndIf
   
   cFilAnt := cFilReg
  
Return .T.

/*/{Protheus.doc} F07Log01
Grava logs 
@author izac.ciszevski
@since 19/01/2017
@version undefined
@param cID, character, Nome da Tabela para Busca
@param cRotina, character, Nome da Rotina executando
@param xInfo, undefined, Conteúdo a ser logado
@Project MAN0000007423041_EF_000 - Funções de Suporte
/*/
User Function F07Log01(cID, xInfo, cRotina)
    Local aCampos := {}
    Local cTrace  := GetMV("FS_WSTRACE",,"2")  //1 | Habilitado; 2 | Desabilitado
    Local nRecLog := 0
    
    Default cRotina := ProcName(1)
    Default xInfo   := ""

    If cTrace == "1"
        aCampos :=  {;
                        {"P19_FILIAL", XFilial('P19')         },;
                        {"P19_ID"    , cID                    },;
                        {"P19_DTHRI" , FwTimeStamp()          },;
                        {"P19_ROTINA", cRotina                },;
                        {"P19_STATUS", "1"                    },;
                        {"P19_INPUT" , FwJsonSerialize(xInfo) };
                    }

        U_F0700007("F0700002", "MASTER", aCampos, 3)
        nRecLog := P19->(Recno())
    EndIf

    aCampos := ASize(aCampos, 0)
    aCampos := Nil

Return nRecLog

/*/{Protheus.doc} F07Log02
Grava logs 
@author izac.ciszevski
@since 19/01/2017
@version undefined
@param nRecLog, numeric, descricao
@param cRetorno, characters, descricao
@param lSucesso, logical, descricao
@param cAlias, characters, descricao
@param nOrdKey, numeric, descricao
@param cIndKey, characters, descricao
@Project MAN0000007423041_EF_000 - Funções de Suporte

/*/
User Function F07Log02(nRecLog, cRetorno, lSucesso, cAlias, nOrdKey, cIndKey)
    Local aCampos   := {}
    Local aEstAlias := {}
    Local cTrace    := GetMV("FS_WSTRACE", , "2")  //1 | Habilitado; 2 | Desabilitado
    
    Default nOrdKey := 1
    Default cIndKey := ""
        
    If cTrace == "1"
        P19->(DbGoTo(nRecLog))

        If lSucesso .And. Empty(cIndKey)
            (cAlias)->(DbSetOrder(nOrdKey))
            aEstAlias := StrTokArr((cAlias)->(IndexKey()), " + ")
            (cAlias)->(AEval(aEstAlias, {|cCampo| cIndKey += (cAlias)->(FieldGet(FieldPos(cCampo))) + "|"}))
        EndIf

        aCampos :=  {;
                        {"P19_INDKEY", Left(cAlias + '|' + StrZero(nOrdKey,2) + '|' + cIndKey,Len(P19->P19_INDKEY)) },;
                        {"P19_STATUS", If(lSucesso,"2","3")                                                         },;
                        {"P19_DTHRF" , FwTimeStamp()                                                                },;
                        {"P19_OUTPUT", cRetorno                                                                     };
                    }

        U_F0700007("F0700002", "MASTER", aCampos, 4)

    EndIf

    aCampos := ASize(aCampos, 0)
    aCampos := Nil

Return 

/*/{Protheus.doc} F07Log03
Grava logs 
@author izac.ciszevski
@since 19/01/2017
@version undefined
@param cRotina, characters, descricao
@param cInput, characters, descricao
@param cOutput, characters, descricao
@param cStatus, characters, descricao
@param cAlias, characters, descricao
@param nOrdKey, numeric, descricao
@param cIndKey, characters, descricao
@Project MAN0000007423041_EF_000 - Funções de Suporte
/*/
User Function F07Log03(cRotina,cInput,cOutput,cStatus,cAlias,nOrdKey,cIndKey)
    Local aCampos   := {}
    Local cID       := U_GetIntegID()
    
    Default cRotina := ProcName(1)

     aCampos :=  {;
	                 {"P20_FILIAL", XFilial('P20')         },;
	                 {"P20_FILPRO", cFilAnt                },;
	                 {"P20_ID"    , cID                    },;
	                 {"P20_DTHR"  , FwTimeStamp()          },;
	                 {"P20_ROTINA", cRotina                },;
	                 {"P20_STATUS", cStatus                },;
	                 {"P20_INPUT" , FwJsonSerialize(cInput)},;
	                 {"P20_OUTPUT", cOutput 			   },;
	                 {"P20_INDKEY", cAlias + '|' + StrZero(nOrdKey,2) + '|' + cIndKey   };
                 }

    U_F0700007("F0700003", "MASTER", aCampos, 3)
 
    aCampos := ASize(aCampos, 0)
    aCampos := Nil

Return cID

/*/{Protheus.doc} F07PADR
Função para tratamento do tamanho dos campos caracter 
@type  Function
@author robson.william
@since 23/03/2017
@version version
@param aRotAuto, array, Array com os campos a terem os espaços configurados
@return Nil,Nulo, Não há necessidade de retorno pois se trata de array
@Project MAN0000007423041_EF_000 - Funções de Suporte 
/*/
User Function F07PADR(aRotAuto)
    Local nI
    Local aAreaSX3 := SX3->(GetArea('SX3'))
    //Início - Thais Paiva - Compatibilização P27
	//SX3->(DbSetOrder(2))
    For nI:=1 to len(aRotAuto)
        //If !SX3->(DbSeek(Padr(aRotAuto[nI,1],10)))
		If FieldPos(aRotAuto[nI,1]) == 0
            Loop
        EndIf
        //If SX3->X3_TIPO == "C"
		If Alltrim(GetSx3Cache(aRotAuto[nI,1], 'X3_TIPO')) == "C"
            //aRotAuto[nI,2] := Padr(aRotAuto[nI,2],SX3->X3_TAMANHO)
			aRotAuto[nI,2] := Padr(aRotAuto[nI,2],GetSx3Cache(aRotAuto[nI,1], 'X3_TAMANHO'))
        Endif
    Next
	//Fim - Thais Paiva - Compatibilização P27
    RestArea(aAreaSX3)


Return Nil 


User Function F07Log04(cConteudo, cNomeArq)
	Local cCaminho		:= "\system\fs_log\"
	Local lRet			:= .T.		
	
    If !(ExistDir(cCaminho))
        lRet := .F.
    EndIf

	If lRet
		If !(CriaArqSem(cCaminho, cNomeArq, cConteudo))
			lOk := .F.
		EndIf
	EndIf
Return


Static Function CriaArqSem(cDirArqSem, cNomArqSem, cConteudo)

    Local lOk       := .T.

    Local nHandle   := 0
    
    Local cContGrv	:= "--------------------- " + CRLF + FWTimeStamp(3) + CRLF

    Default lSetHandle  := .F.
    
    If File(cDirArqSem + cNomArqSem)
        nHandle := FOpen(cDirArqSem + cNomArqSem/*cNomeArq*/, FO_READWRITE + FO_EXCLUSIVE)
    Else
    	nHandle := FCreate(cDirArqSem + cNomArqSem)
    EndIf

    If nHandle == -1
        lOk := .F.
        conout("erro ao criar/abrir o arquivo")
    Else
        If !(Empty(cConteudo))
        	cContGrv += cConteudo
			FSeek(nHandle, 0, 2)
        	FWrite(nHandle, cContGrv)
        EndIf
        //Seta a variavel static ou fecha o arquivo
 
        FClose(nHandle)
     EndIf

Return lOk