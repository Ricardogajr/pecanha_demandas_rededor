#include "protheus.ch"
#include "fina435.ch"
#include "fileio.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} FINA260
Retorno de comunicacao banc�ria a pagar - via Job.

@param   cParm01    Codigo da empresa.
@param   cParm02    Codigo da filial.

@author  Thiago Goes do Nascimento	
@since   30/06/2021
/*/
User Function RDORDDA1(aParm01)

/*
CPARM01[1]:"01"
CPARM01[2]:"01010004"
CPARM01[3]:"011379"
CPARM01[4]:"000002000001"
*/
	Local aParam
	Local nCntFor
	Local cParm01 
	Local cParm02
	Private cCadastro  := "Retorno Bancario Automatico (Pagar)" // "Retorno Bancario Automatico (Pagar)"
	Private cMsgDupl   := "Ajuste Duplicidades DDA"

	Default cParm01 := '01'
	Default cParm02 := '01010004'
	
	
	cParm01 := aParm01[1]
	cParm02 := aParm01[2]

	If !empty(cParm01) .and. !empty(cParm02)
		aParam := {cParm01, cParm02}
	Else 
		ConOut("***ERROR*** - " + "Processo nao executado, filial nao posicionada no schedule") // "Processo pode ser executado apenas via Schedule"
	Endif

	ConOut("*** IN�CIO - " + Dtoc(Date()) + " " + Time() + " - " + cCadastro)

	if Valtype(aParam) <> "A"
		ConOut("*** - " + "Processo pode ser executado apenas via Schedule") // "Processo pode ser executado apenas via Schedule"
	Else
		// Executa apenas se for chamado pelo Schedule.
		// As vari�veis abaixo s�o �teis para debug da rotina via execu��o normal.
		Private lExecJob := .T.
		Private aMsgSch  := {}
		Private aFA205R  := {}

		// Manter posicionado pois o FINA200 vai utilizar estas informa��es.
		RPCSetType(3)
		RpcSetEnv(aParam[1], aParam[2])

		BatchProcess(cCadastro, cCadastro, "FA260JOB", {|| FA260JOB()}, {|| .F. })

		// Se o par�metro n�o est� definido, envia as mensagens para o console.
		If empty(GetMv("MV_RETMAIL",, "")) .and. Len(aMsgSch) > 0
			For nCntFor := 1 to Len(aMsgSch)
				ConOut(aMsgSch[nCntFor])
			Next
		Endif

		RpcClearEnv()
	Endif

	ConOut("*** FIM - " + Dtoc(Date()) + " " + Time() + " - " + cCadastro)


Return

/*/{Protheus.doc} FA435JOB
Retorno de comunica��o banc�ria a pagar - via Job.

@author  Aldo Barbosa dos Santos
@since   31/05/2011
/*/
Static Function FA260JOB()

	Local cPerg	:= "AFI430"
	Local aVetPar // vetor das perguntas
	Local cQuery  // query de bancos que serao executados automaticamente
	Local cAlias := GetNextAlias()
  // alias temporario dos banco que serao executados
	Local cBarra := If(IsSrvUnix(), "/", "\")
	Local nA

	Local aArq
	Local cArquivo
	Local cDirArq
	Local cDirBkp
	Local cArqItau  //Arquivo Itau
	Local cArqBrad  //Arquivo Bradesco
	Local cArqSant  //Arquivo Santander
	Local cArqBB	//Arquivo Banco do Brasil
	Local cArqCEF	//Arquivo Caixa
	Local lOk := .T.

	Private aRecSE5 := {}
	Private cDirFull := ""
	SEE->(dbsetorder(1))  // EE_FILIAL, EE_CODIGO, EE_AGENCIA, EE_CONTA, EE_SUBCTA.

// L� as perguntas do FINA430 que ser�o modificadas de acordo com os novos campos da tabela de bancos.
// Pergunte(cPergunta,lAsk,cTitle,lOnlyView,oDlg,lUseProf,aPerg,lBreakLine,lHasHelp)
	Pergunte(cPerg, .F., Nil, Nil, Nil, .F.)

// Seleciona todas as contas que est�o programadas para recebimento autom�tico.
	cQuery := "SELECT R_E_C_N_O_ REGSEE "
	cQuery += "FROM " + RetSqlName("SEE") + " SEE "
	cQuery += "WHERE EE_FILIAL = '" + xFilial("SEE") + "' "
	cQuery += "AND EE_RETAUT IN ('2', '3') " // 1.recebimento; 2.pagamento; 3.ambos
	cQuery += "AND EE_SUBCTA = 'DDA'  " // Somente contas com subconta DDA
	cQuery += "AND SEE.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY EE_CODIGO,EE_AGENCIA,EE_CONTA "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)


	Do While (cAlias)->(!Eof())
		// Mant�m posicionado pois o FINA430 vai utilizar estas informa��es.
		SEE->(dbGoto((cAlias)->REGSEE))

			// le os arquivos do diretorio configurado
			cArqItau  := SuperretMv("FS_DDAITAU",.F.,"c:\temp\DDA\ITAU")  		//Arquivo Itau
			cArqBrad  := SuperretMv("FS_DDABRAD",.F.,"c:\temp\DDA\BRADESCO") 	//Arquivo Bradesco
			cArqSant  := SuperretMv("FS_DDASANT",.F.,"c:\temp\DDA\SANTANDER")	//Arquivo Santander
			cArqBB	  := SuperretMv("FS_DDABB"	,.F.,"c:\temp\DDA\BB") 			//Arquivo Banco do Brasil
			cArqCEF	  := SuperretMv("FS_DDACEF"	,.F.,"c:\temp\DDA\CEF") 		//Arquivo Caixa
			
			Do case 
			Case SEE->EE_CODIGO == "341"
				cDirArq := Alltrim(cArqItau)
			Case SEE->EE_CODIGO == "237"
				cDirArq := Alltrim(cArqBrad)
			Case SEE->EE_CODIGO == "033"
				cDirArq := Alltrim(cArqSant)
			Case SEE->EE_CODIGO == "001"
				cDirArq := Alltrim(cArqBB)
			Case SEE->EE_CODIGO == "001"
				cDirArq := Alltrim(cArqCEF)
			EndCase
	
			// Verifica se os diret�rios est�o com a barra no final.
			If right(cDirArq, 1) <> cBarra
				cDirArq += cBarra
			Endif

			cDirBkp := Alltrim(cDirArq+"LIDOS")

			If !empty(cDirBkp) .and. right(cDirBkp, 1) <> cBarra
				cDirBkp += cBarra
			Endif

			// L� os arquivos a serem processados.
			aArq := Directory(cDirArq + "*." + AllTrim(SEE->EE_EXTEN) + "*")
			If Empty(aArq) .and. AllTrim(cDirArq) == cBarra
				aArq    := Directory("*." + AllTrim(SEE->EE_EXTEN) + "*")
				cDirArq := ""
			Endif

			For nA := 1 to Len(aArq)
				// Armazena o nome do arquivo nos par�metros.
				cArquivo := aArq[nA, 1]
				//aVetPar[3, 2] := cDirArq + cArquivo
				cDirFull :=cDirArq + cArquivo//Pega o CNPJ da filial no arquivo
				cArqTxT := MemoRead( cDirArq + cArquivo )
				cCnPj := SubStr( cArqTxT, 19,14 )

				cFilSEE := fCodFilSm0(cCnPj) // Lucas Miranda de Aguiar
				If cFilSee <> xFilial("SEE")
					lOk := .F.
				Else
					lOk := .T.
				EndIf

				If lOk //S� vai executar a FINA 430 para os arquivos que forem da filial logada no momento
					// Atualiza o pergunte do FINR650.
		
					// Controle de mensagens de erro.
					aMsgSch := {}

					// Controle de titulos baixados utilizado no fina430
					aFA205R := {}

					aVetPar := {{'mv_par01', 2					},; // 01	Mostra Lanc Contab ?
					{'mv_par02', Val(SEE->EE_AGLCTB)},; // 02	Aglut Lancamentos ?
					{'mv_par03', cDirFull			},; // 03	Arquivo de Entrada ?
					{'mv_par04', SEE->EE_CFGPAG		},; // 04	Arquivo de Config ?
					{'mv_par05', SEE->EE_CODIGO		},; // 05	Codigo do Banco ?
					{'mv_par06', SEE->EE_AGENCIA	},; // 06	Codigo da Agencia ?
					{'mv_par07', SEE->EE_CONTA		},; // 07	Codigo da Conta ?
					{'mv_par08', SEE->EE_SUBCTA		},; // 08	Codigo da Sub-Conta ?
					{'mv_par09', 2					},; // 09	Contabiliza On Line ?
					{'mv_par10', 2},; // 10	Configuracao CNAB ?
					{'mv_par11', 1},; // 11	Processa Filial?
					{'mv_par12', 2},;  // 12	Considera Multiplas naturezas ?
					{'mv_par13', 2}}
					
					FINA430(nil, aVetPar)

					// Envia e-mail (FINA205) das mensagens de erro
					FA205MAIL("Retorno Bancario Automatico (Pagar)", cDirArq + cArquivo, aMsgSch) // "Retorno Bancario Automatico (Pagar)"

					Fina260Job(cDirArq,cArquivo) //Rotina Conciliacao DDA

					BatchProcess(cMsgDupl, cMsgDupl, "FADUPJOB", {|| U_FADUPJOB(cDirArq,cArquivo)}, {|| .F. })

					If Len(aMsgSch) == 0
						If !empty(cDirBkp)
							// Move o arquivo processado para o diret�rio de backup.
							If fRename(cDirArq + cArquivo, cDirBkp + cArquivo) < 0
								ConOut("N�o foi poss�vel copiar o arquivo " + cDirArq + cArquivo + " para o diret�rio " + cDirBkp) // "N�o foi poss�vel copiar o arquivo " # " para o diret�rio "
								ConOut("fRename: " + "Erro " + cValToChar(FError()))  // "Erro "
							Endif
						Else
							// Exclui o arquivo processado.
							If fErase(cDirArq + cArquivo) < 0
								ConOut("N�o foi poss�vel excluir o arquivo " + cDirArq + cArquivo) // "N�o foi poss�vel excluir o arquivo "
								ConOut("fErase: " + "Erro " + cValToChar(FError()))  // "Erro "
							Endif
						Endif
					Endif
				EndIf
			Next nA
		//Endif
		
		
		
		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())
Return

Static function SuperretMv(cVar, lVar,cVar2 )

return SuperretMv(cVar, lVar,cVar2 )


//Fun��o que retorna o c�digo da filial pelo CNPJ.
Static Function fCodFilSm0(cCnPj)

	Local aArea := GetArea()
	Local nX := 1
	Local aInfSM0 := FWLoadSM0()
	Local cReturn := ""

	Default cCnPj := ""

	For nX := 01 To Len(aInfSM0)

		If AllTrim(aInfSM0[nX][18]) == AllTrim(cCnPj)

			cReturn := AllTrim(aInfSM0[nX][2])
			Exit
		EndIf
	Next nX

	RestArea(aArea)
Return cReturn

Static Function Fina260Job(cDirArq,cArquivo)
 Local nDifDDA   := SuperGetMv("FS_DDADIF"	,.F.,0)  //DIFEREN�A EM VALORES ACEITAVEIS PARA DDA, EX. 0.01 � CONSIDERADO TITULOS COM DIFEREN�A DE 1 CENTAVO
 Local nDIAS  	 := SuperGetMv("FS_DDADIAS"	,.F.,30)  //DIFEREN�A EM DIAS PARA CONSIDERAR O VENCIMENTO, EX. 10 � CONSIDERADO 10 DIAS DE VENCIMENTO REAL NOS TITULOS PARA CONCILIAR
 Local lAutomato := .T.
 Local nPosArotina := 3
 Local dDtIni	 := CTOD("01/01/1980","ddmmyy")
 Local dDtFin	 := CTOD("01/01/1980","ddmmyy")




 //��������������������������������������������������������������Ŀ
 //�                    P A R A M E T R O S                       �
 //�--------------------------------------------------------------�
 //�MV_PAR01: Considera Filiais Abaixo                            �
 //�MV_PAR02: Filial De                                           �
 //�MV_PAR03: Filial Ate                                          �
 //�MV_PAR04: Fornecedor De                                       �
 //�MV_PAR05: Fornecedor Ate                                      �
 //�MV_PAR06: Loja De			                                      �
 //�MV_PAR07: Loja Ate		                                      �
 //�MV_PAR08: Considera Vencto ou Vencto Real                     �
 //�MV_PAR09: Vencto De                                           �
 //�MV_PAR10: Vencto Ate                                          �
 //�MV_PAR11: Dt. de Processamento do Arquivo DDA De              �
 //�MV_PAR12: Dt. de Processamento do Arquivo DDA Ate             � 
 //�MV_PAR13: Avancar Dias (Vencto + nDias)                       �
 //�MV_PAR14: Retroceder Dias (Vencto - nDias)                    �
 //�MV_PAR15: Diferenca a Menor                                   �
 //�MV_PAR16: Diferenca a Maior                                   �
 //����������������������������������������������������������������

dDtIni	:= Date() - nDIAS
dDtFin	:= Date() + nDIAS

SetFunName("FINA260")

Pergunte("FIN260",.F.)//Carrego as MV_PAR's sem exibir a tela

 SetMVValue("FIN260","MV_PAR01",1) 	 // Considera Filiais Abaixo                          
 SetMVValue("FIN260","MV_PAR02",cFilAnt)  //Filial De                                          
 SetMVValue("FIN260","MV_PAR03",cFilAnt)  // Filial Ate                                        
 SetMVValue("FIN260","MV_PAR04",' ')      // Fornecedor De                                     
 SetMVValue("FIN260","MV_PAR05",'ZZZZZZ') // Fornecedor Ate                                    
 SetMVValue("FIN260","MV_PAR06",' ')      // Loja De			                                 
 SetMVValue("FIN260","MV_PAR07",'ZZ')     // Loja Ate		                                     
 SetMVValue("FIN260","MV_PAR08",2)        // Considera Vencto ou Vencto Real 2-VENCIMENTO REAL   
 SetMVValue("FIN260","MV_PAR09",dDtIni)   // Vencto De                                         
 SetMVValue("FIN260","MV_PAR10",dDtFin)   // Vencto Ate                                        
 SetMVValue("FIN260","MV_PAR11",Date())   // Dt. de Processamento do Arquivo DDA De            
 SetMVValue("FIN260","MV_PAR12",Date())   // Dt. de Processamento do Arquivo DDA Ate           
 SetMVValue("FIN260","MV_PAR13",nDIAS)    // Avancar Dias (Vencto + nDias)                     
 SetMVValue("FIN260","MV_PAR14",nDIAS)    // Retroceder Dias (Vencto - nDias)                  
 SetMVValue("FIN260","MV_PAR15",nDifDDA)  // Diferenca a Menor                                 
 SetMVValue("FIN260","MV_PAR16",nDifDDA)  // Diferenca a Maior       

 Pergunte("FIN260", .F.) //salva as alteracoes na pergunta

 FINA260(nPosArotina,lAutomato)

//FINA260(NIL,lautomat)
FIG->(dbSetOrder(2)) //Filial+Fornecedor+Loja+Vencto+Titulo
cChave		:= FIG->(IndexKey())
cAliasFIG	:= GetNextAlias()
aStru		:= FIG->(dbStruct())
cCampos		:= ""
cFilIn 		:= cFilAnt
dDtIni	:= Max(dDtIni,Iif(Empty(mv_par09),dDtIni,mv_par09))
dDtFin	:= Max(dDtFin,Iif(Empty(mv_par10),dDtFin,mv_par10))

// Acrescento/diminuo das variaveis para abrir periodo
dDtIni	:= dDtIni - mv_par14
dDtFin	:= dDtFin + mv_par13

aEval(aStru,{|x| cCampos += ","+AllTrim(x[1])})

cQuery := "SELECT "+SubStr(cCampos,2) + ", R_E_C_N_O_ RECNOFIG "
cQuery += "FROM " + RetSqlName("FIG") + " FIG  WHERE "
cQuery +=		"FIG_FILIAL IN "	+ FormatIn(cFilIn,"/") + " AND "
cQuery += 		"FIG_FORNEC  >= '"+ mv_par04 + "' AND "
cQuery += 		"FIG_FORNEC  <= '"+ mv_par05 + "' AND "
cQuery += 		"FIG_LOJA >= '"	+ mv_par06 + "' AND "
cQuery += 		"FIG_LOJA <= '"	+ mv_par07 + "' AND "
cQuery +=		"FIG_VENCTO >= '"	+ DTOS(dDtIni) + "' AND "
cQuery +=		"FIG_VENCTO <= '"	+ DTOS(dDtFin) + "' AND "
cQuery +=		"FIG_DATA >= '"	+ DTOS(mv_par11) + "' AND "
cQuery +=		"FIG_DATA <= '"	+ DTOS(mv_par12) + "' AND "
cQuery += 		"FIG_VALOR > 0 AND "
cQuery +=		"FIG_CONCIL = '2' AND "
cQuery +=		"FIG_CODBAR <> ' ' AND "
cQuery +=		"D_E_L_E_T_ = ' ' "
cQuery +=	"ORDER BY " + SqlOrder(cChave)

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasFIG,.T.,.T.)

//Chama a função e um título
Return

Static Function QryExcel(cQryAux, cTitAux,cDirArq,cArquivo)
    Default cQryAux   := ""
    Default cTitAux   := "Título"
     
    Processa({|| fProcessa(cQryAux, cTitAux,cDirArq,cArquivo) }, "Processando...")
Return
 
/*---------------------------------------------------------------------*
 | Func:  fProcessa                                                    |
 | Desc:  Função de processamento                                      |
 *---------------------------------------------------------------------*/
 
Static Function fProcessa(cQryAux, cTitAux,cDirArq,cArquivo)
    Local aArea       := GetArea()
    Local aAreaX3     := SX3->(GetArea())
    Local nAux        := 0
    Local oFWMsExcel
    Local oExcel
    Local cDiretorio  := cDirArq //alterado Thiago Goes em 30/09/2021
    Local cArqFull    := alltrim(cDirArq)+dtos(date())+cFilAnt+".xls"
    Local cWorkSheet  := "Aba - Principal"
    Local cTable      := ""
    Local aColunas    := {}
    Local aEstrut     := {}
    Local aLinhaAux   := {}
    Local cTitulo     := ""
    Local nTotal      := 0
    Local nAtual      := 0
    Default cQryAux   := ""
    Default cTitAux   := "Título"
     
    cTable := cTitAux
     
    //Se tiver a consulta
    If !Empty(cQryAux)
        TCQuery cQryAux New Alias "QRY_AUX"
         
        DbSelectArea('SX3')
        SX3->(DbSetOrder(2)) //X3_CAMPO
         
        //Percorrendo a estrutura
        aEstrut := QRY_AUX->(DbStruct())
        ProcRegua(Len(aEstrut))
        For nAux := 1 To Len(aEstrut)
            IncProc("Incluindo coluna "+cValToChar(nAux)+" de "+cValToChar(Len(aEstrut))+"...")
            cTitulo := ""
             
            //Se conseguir posicionar no campo
            If SX3->(DbSeek(aEstrut[nAux][1]))
                cTitulo := Alltrim(getsx3xcacHe(aEstrut[nAux][1],"X3_TITULO"))
                 
                //Se for tipo data, transforma a coluna
                If getsx3xcacHe(aEstrut[nAux][1],"X3_TIPO") == 'D'
                    TCSetField("QRY_AUX", aEstrut[nAux][1], "D")
                EndIf
            Else
                cTitulo := Capital(Alltrim(aEstrut[nAux][1]))
            EndIf
             
            //Adicionando nas colunas
            aAdd(aColunas, cTitulo)
        Next
          
        //Criando o objeto que irá gerar o conteúdo do Excel
        oFWMsExcel := FWMSExcelex():New()
        oFWMsExcel:AddworkSheet(cWorkSheet)
        oFWMsExcel:AddTable(cWorkSheet, cTable)
             
            //Adicionando as Colunas
            For nAux := 1 To Len(aColunas)
                oFWMsExcel:AddColumn(cWorkSheet, cTable, aColunas[nAux], 1, 1)
            Next
             
            //Definindo o total da barra
            DbSelectArea("QRY_AUX")
            QRY_AUX->(DbGoTop())
            Count To nTotal
            ProcRegua(nTotal)
            nAtual := 0
             
            //Percorrendo os produtos
            QRY_AUX->(DbGoTop())
            While !QRY_AUX->(EoF())
                nAtual++
                IncProc("Processando registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
             
                //Criando a linha
                aLinhaAux := Array(Len(aColunas))
                For nAux := 1 To Len(aEstrut)
                    aLinhaAux[nAux] := &("QRY_AUX->"+aEstrut[nAux][1])
                Next
                  
                //Adiciona a linha no Excel
                oFWMsExcel:AddRow(cWorkSheet, cTable, aLinhaAux)
                  
                QRY_AUX->(DbSkip())
            EndDo
              
        //Ativando o arquivo e gerando o xml
        oFWMsExcel:Activate()
        oFWMsExcel:GetXMLFile(cArqFull)
         
        //Se tiver o excel instalado
    /*
	    If ApOleClient("msexcel")
            oExcel := MsExcel():New()
            oExcel:WorkBooks:Open(cArqFull)
            oExcel:SetVisible(.T.)
            oExcel:Destroy()
         
        Else
            //Se existir a pasta do LibreOffice 5
            If ExistDir("C:\Program Files (x86)\LibreOffice 5")
                WaitRun('C:\Program Files (x86)\LibreOffice 5\program\scalc.exe "'+cDiretorio+cArquivo+'"', 1)
             
            //Senão, abre o XML pelo programa padrão
            Else
                ShellExecute("open", cArquivo, "", cDiretorio, 1)
            EndIf
        EndIf
    */      
        QRY_AUX->(DbCloseArea())
    EndIf

	EMailDDA(cDirFull)
     
    RestArea(aAreaX3)
    RestArea(aArea)
Return


//#include "TOTVS.CH"
Static Function EMailDDA(cDirFull)
  Local oServer
  Local oMessage
  Local nNumMsg := 0
  Local nTam    := 0
  Local nI      := 0
  Local cEmailDDA 	 := SuperGetMv("FS_DDAMAIL",.F.,"thiago.goes.totvs@gmail.com")  
  Private _cServer   := SUPERGETMV("MV_RELSERV",.F.,"10.250.0.224:587") // 10.250.0.224:587          ==> Configuracao do SMTP do E-Mail
  Private _cConta    := SUPERGETMV("MV_RELACNT",.F.,"protheus12@rededor.com.br") // protheus12@rededor.com.br ==> Conta de e-mail
  Private _cPass     := SUPERGETMV("MV_RELPSW",.F. ,"Ropi%45H@")  // Ropi%45H@                 ==> Senha do e-Mail
  Private _cRemet    := SUPERGETMV("MV_RELACNT",.F.,"protheus12@rededor.com.br") // protheus12@rededor.com.br ==> Conta de e-mail
  Private _cPorta
  Private cTxt 

  cTxt:= separa(_cServer,":")
  _cServer:=alltrim(cTxt[1])
  _cPorta :=val(cTxt[2])

  If Empty(_cPorta)
	_cPorta := 25
  EndIf
  //Cria a conexão com o server STMP ( Envio de e-mail )
  oServer := TMailManager():New()
  oServer:Init( "", _cServer, _cConta, _cPass , 0, _cPorta )
   
  //seta um tempo de time out com servidor de 1min
  If oServer:SetSmtpTimeOut( 60 ) != 0
    Conout( "Falha ao setar o time out" )
    Return .F.
  EndIf
   
  //realiza a conexão SMTP
  If oServer:SmtpConnect() != 0
    Conout( "Falha ao conectar" )
    Return .F.
  EndIf
   
  //Apos a conexão, cria o objeto da mensagem
  oMessage := TMailMessage():New()
   
  //Limpa o objeto
  oMessage:Clear()
   
  //Popula com os dados de envio
  oMessage:cFrom              := cEmailDDA
  oMessage:cTo                := _cRemet
  oMessage:cCc                := ""
  oMessage:cBcc               := ""
  oMessage:cSubject           := "Conciliacao DDA " + DTOC(DATE())
  oMessage:cBody              := "Relatorio de conciliacao DDA titulos nao Conciliados"
   
  //Adiciona um attach
  If oMessage:AttachFile(cDirFull) < 0
    Conout( "Erro ao atachar o arquivo" )
    Return .F.
  Else
    //adiciona uma tag informando que é um attach e o nome do arq
    oMessage:AddAtthTag( 'Content-Disposition: attachment; filename=arquivo.txt')
  EndIf
   
  //Envia o e-mail
  If oMessage:Send( oServer ) != 0
    Conout( "Erro ao enviar o e-mail" )
    Return .F.
  EndIf
   
  //Desconecta do servidor
  If oServer:SmtpDisconnect() != 0
    Conout( "Erro ao disconectar do servidor SMTP" )
    Return .F.
  EndIf
   
Return .T.


User Function FADUPJOB(cDirArq,cArquivo)

Local cQryFIG, cQrySE2 
Local cChvFIG    := ""
Local cCampFIG   := ""
Local dDtIni	 := CTOD("01/01/1980","ddmmyy")
Local dDtFin	 := CTOD("01/01/1980","ddmmyy")
Local cFornece   := ""
Local cLoja 	 := ""
Local cCodBar    := ""
Local nValor     := 0
Local nValorMin  := 0
Local nValorMax  := 0
Local aAreaSe2 
Local lConcilia  := .F. 
Local aStruFIG   := {}
Local cTitNum    := ""
Local cvARFA260GRSE2:= ExistBlock("FA260GRSE2")


nDifDDA    	:= SuperGetMv("FS_DDADIF"	,.F.,0)  //DIFEREN�A EM VALORES ACEITAVEIS PARA DDA, EX. 0.01 � CONSIDERADO TITULOS COM DIFEREN�A DE 1 CENTAVO
nDIAS  	 	:= SuperGetMv("FS_DDADIAS"	,.F.,30)  //DIFEREN�A EM DIAS PARA CONSIDERAR O VENCIMENTO, EX. 10 � CONSIDERADO 10 DIAS DE VENCIMENTO REAL NOS TITULOS PARA CONCILIAR
aAreaSE2    := GetArea()


dDtIni	:= Max(dDtIni,Iif(Empty(DATE()),dDtIni,DATE()))
dDtFin	:= Max(dDtFin,Iif(Empty(DATE()),dDtFin,DATE()))

// Acrescento/diminuo das variaveis para abrir periodo
dDtIni	:= dDtIni - nDIAS
dDtFin	:= dDtFin + nDIAS

dbSelectArea("FIG")

FIG->(dbSetOrder(2)) //Filial+Fornecedor+Loja+Vencto+Titulo
cChvFIG		:= FIG->(IndexKey())
cAliasFIG	:= GetNextAlias()
aStruFIG	:= FIG->(dbStruct())

aEval(aStruFIG,{|x| cCampFIG += ","+AllTrim(x[1])})

cQryFIG := "SELECT "+SubStr(cCampFIG,2) + ", R_E_C_N_O_ RECNOFIG "
cQryFIG += "FROM " + RetSqlName("FIG") + " FIG  WHERE "
cQryFIG +=		"FIG_FILIAL IN "	+ FormatIn(cFilAnt,"/") + " AND "
cQryFIG +=		"FIG_DATA >= '"	+ DTOS(date()) + "' AND "
cQryFIG +=		"FIG_DATA <= '"	+ DTOS(date()) + "' AND "
cQryFIG += 		"FIG_VALOR > 0 AND "
cQryFIG +=		"FIG_CONCIL = '2' AND "
cQryFIG +=		"FIG_CODBAR <> ' ' AND "
cQryFIG +=		"D_E_L_E_T_ = ' ' "
cQryFIG +=	"ORDER BY " + SqlOrder(cChvFIG)

cQryFIG := ChangeQuery(cQryFIG)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryFIG),cAliasFIG,.T.,.T.)

dbSelectArea("SE2")

SE2->(dbSetOrder(2)) //Filial+Fornecedor+Loja+Vencto+Titulo
cAliasSE2	:= GetNextAlias()

 While (cAliasFIG)->(!Eof())
	lConcilia := .F.
	cFornece  := (cAliasFIG)->FIG_FORNEC
	cLoja     := (cAliasFIG)->FIG_LOJA
	cCodBar   := Alltrim((cAliasFIG)->FIG_CODBAR)
	cCodTit   := (cAliasFIG)->FIG_TITULO
	cTitNum   := (cAliasFIG)->FIG_TITULO
	nValor    := (cAliasFIG)->FIG_VALOR
	nValorMin := nValor-nDifDDA
	nValorMax := nValor+nDifDDA

	cQrySE2 := "SELECT R_E_C_N_O_ RECNOSE2 "
	cQrySE2 += "FROM " + RetSqlName("SE2") + " SE2  WHERE "
	cQrySE2 +=		"E2_FILIAL IN "	+ FormatIn(cFilAnt,"/") + " AND "
	cQrySE2 +=		"E2_VENCTO >= '"	+ DTOS(dDtIni) + "' AND "
	cQrySE2 +=		"E2_VENCTO <= '"	+ DTOS(dDtFin) + "' AND "
	cQrySE2 +=		"E2_FORNECE = '"	+ cFornece + "' AND "
	cQrySE2 +=		"E2_LOJA    = '"	+ cLoja + "' AND "
	cQrySE2 +=		"E2_VALOR >= "	+ cValtoChar(nValorMin)+" AND "
	cQrySE2 +=		"E2_VALOR <= "	+ cValToChar(nValorMax)+" AND "
	cQrySE2 +=		"E2_CODBAR = ' ' AND "
	cQrySE2 +=		"E2_BAIXA  = ' ' AND "
	cQrySE2 +=		"E2_IDCNAB = ' ' AND "
	cQrySE2 +=		"D_E_L_E_T_ = ' ' "

	cQrySE2 := ChangeQuery(cQrySE2)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySE2),cAliasSE2,.T.,.T.)

	While (cAliasSE2)->(!Eof())	
		nRecnoSe2 := (cAliasSE2)->RECNOSE2
		SE2->(dbGoTo(nRecnoSe2))
		
		cCodTit   := fNoEspec(cCodTit)
		lConcilia := fChaveNum(cCodTit,cTitNum)

		If lConcilia
		//BEGIN TRANSACTION 
		   	If Reclock("SE2",.f.)
				SE2->E2_CODBAR := cCodBar
				If cvARFA260GRSE2
					U_FA260GRSE2()
				Endif
			SE2->(Msunlock())
			EndIf
		EndIf 
		cTitSE2			:= 	SE2->E2_FILIAL+"|"+;
							SE2->E2_PREFIXO+"|"+;
							SE2->E2_NUM+"|"+;
							SE2->E2_PARCELA+"|"+;
							SE2->E2_TIPO+"|"+;
							SE2->E2_FORNECE+"|"+;
							SE2->E2_LOJA+"|"+;
							DTOS(SE2->E2_VENCTO)+"|"
		If lConcilia 
			nRecnoFig := (cAliasFIG)->RECNOFIG
			FIG->(dbGoTo(nRecnoFig))
			If RecLock("FIG",.F.)
				FIG->FIG_DDASE2	:= cTitSE2		//Chave do SE2 com o qual foi conciliado
				FIG->FIG_CONCIL	:= "1" 			//Conciliado
				FIG->FIG_DTCONC	:= dDatabase	//Data da Conciliacao
				FIG->FIG_USCONC	:= cUserName 	//Usuario responsavel pela conciliacao

			FIG->(Msunlock())
			EndIf
		EndIF
	(cAliasSE2)->(dbSkip())
	EndDo
 (cAliasSE2)->(dbCloseArea())
 (cAliasFIG)->(dbSkip())
 EndDo

 
QryExcel(cQryFIG, "Titulos DDA",cDirArq,cArquivo)
(cAliasFIG)->(dbCloseArea())

RestArea(aAreaSe2)
Return

Static Function fNoEspec(cCodTit)

    Local cConteudo   := cCodTit
    Local nTamOrig    := Len(cConteudo)

    //Retirando caracteres
	cConteudo := FwCutOff(cConteudo,.T.)
	cConteudo := FwNoAccent(cConteudo)
	cConteudo := StrTran(cConteudo, "'", "")
    cConteudo := StrTran(cConteudo, "#", "")
    cConteudo := StrTran(cConteudo, "%", "")
    cConteudo := StrTran(cConteudo, "*", "")
    cConteudo := StrTran(cConteudo, "&", "")
    cConteudo := StrTran(cConteudo, ">", "")
    cConteudo := StrTran(cConteudo, "<", "")
    cConteudo := StrTran(cConteudo, "!", "")
    cConteudo := StrTran(cConteudo, "@", "")
    cConteudo := StrTran(cConteudo, "$", "")
    cConteudo := StrTran(cConteudo, "(", "")
    cConteudo := StrTran(cConteudo, ")", "")
    cConteudo := StrTran(cConteudo, "_", "")
    cConteudo := StrTran(cConteudo, "=", "")
    cConteudo := StrTran(cConteudo, "+", "")
    cConteudo := StrTran(cConteudo, "{", "")
    cConteudo := StrTran(cConteudo, "}", "")
    cConteudo := StrTran(cConteudo, "[", "")
    cConteudo := StrTran(cConteudo, "]", "")
    cConteudo := StrTran(cConteudo, "/", "")
    cConteudo := StrTran(cConteudo, "?", "")
    cConteudo := StrTran(cConteudo, ".", "")
    cConteudo := StrTran(cConteudo, "\", "")
    cConteudo := StrTran(cConteudo, "|", "")
    cConteudo := StrTran(cConteudo, ":", "")
    cConteudo := StrTran(cConteudo, ";", "")
    cConteudo := StrTran(cConteudo, '"', '')
    cConteudo := StrTran(cConteudo, '�', '')
    cConteudo := StrTran(cConteudo, '�', '')
    cConteudo := StrTran(cConteudo, ",", "")
    cConteudo := StrTran(cConteudo, "-", "")
	cConteudo := GetdToVal(cConteudo)
	cConteudo := cValtoChar(cConteudo)
    cConteudo := Alltrim(cConteudo)

Return cConteudo


Static Function fChaveNum(cCodTit,cTitNum)
Local lRet := .F.

If Len(cTitNum) >9
	cTitNum := SubStr(cTitNum,1,9)
	DO Case
		Case cTitNum == SE2->E2_NUM
		lRet := .T.
	EndCase
EndIf

Do Case 
	Case cCodTit == SE2->E2_NUM
		lRet := .T.
	Case StrZero(Val(cCodTit),9) == SE2->E2_NUM
		lRet := .T.
End Case

Return lRet
