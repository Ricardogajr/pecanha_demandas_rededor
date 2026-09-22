#INCLUDE "TOTVS.ch"
/*/{Protheus.doc} CN240CGRV

	Ponto de entrada CN240CGRV

    No ok da gravação dos acessos do contrato

    @type function - User
	@author Cleiton Genuino da Silva
	@since 10/05/2023
	@version 12.1.2210
	@obs Monta a tela após a atualização da PCD
/*/
User Function CN240CGRV()
    Local aArea := GetArea() as array
    Local lRet  := .T.

    If FindFunction('U_PUTCN240')
        U_PUTCN240()
    ElSE
        lRet := .F.
        cMensagem := "A rotina de grupo de acessos "+CRLF
        cMensagem += "não está disponivel no .rpo "+CRLF
        Help("CN240CGRV",1,"HELP","PUTCN240",cMensagem,1,0)
    EndIf

    Restarea(aArea)

Return lRet
/*/{Protheus.doc} PUTCN240
    Monta o array de GRUPOS para exibir ao usuario
    @type Function - User Function
    @author Cleiton Genuino
    @since 12/05/2023
    @version 12.1.2210
    @see
    U_PUTCN240()
/*/
User Function PUTCN240()
    Local aArea         := GetArea()       as array
    local aCores        := {}              as array
    local aCpoBro       := {}              as array
    local aDados        := {}              as array
    local aFields       := {}              as array
    local aGRUPOS       := {}              as array
    local aP42          := {}              as array
    Local bCancel       :={|| oDlg:End() } as array
    Local cAlias        := ''              as character
    local cAreaTmp      := ''              as character
    Local cCn9Filial    := ''              as character
    Local cCn9Numero    := ''              as character
    Local cCn9Revisa    := ''              as character
    Local cCnaNumero    := ''              as character
    Local cMark         := "OK"            as character
    local cQuery        := ''              as character
    local cStatus       := ''              as character
    local cSufixo       := 'REDEDOR'       as character
    local cTableName    := ''              as character
    Local cVAR_AXB      := ''              as character
    local lCloseConnect := .F.             as logical
    Local lInverte      := .F.             as logical
    Local lOk           := .T.             as logical
    local nConnect      := 0               as numeric
    Local nJJ           := 0               as numeric
    Local nX            := 0               as numeric
    local oTable                           as object

    If Select('CN9') > 0
        cCn9Filial := CN9->CN9_FILIAL
        cCn9Numero := CN9->CN9_NUMERO
        cCn9Revisa := CN9->CN9_REVISA
    ENDIF

    If Select('CNA') < 0
        DBSELECTAREA( 'CNA' )
    ENDIF
    CNA->(dbSetOrder(3)) // CNA_FILIAL + CNA_CONTRA + CNA_REVISA

    If Select('CPD') < 0
        DBSELECTAREA( 'CPD' )
    ENDIF
    CPD->(dbSetOrder(1)) // CPD_FILIAL + CPD_CONTRA + CPD_NUMPLA + CPD_FILAUT

    If ! ( CHKFILE ("P42") .And. CHKFILE ("P43") )
        MsgAlert("Atenção, Existe um erro no dicionario nas tabelas P42 e P43 !")
        lOk := .F.
    EndIf

    If lOk
        If MsgYesNo('<font color="#4865E5">' + '<h1> Deseja incluir Grupo x Filiais ? </h1>' + '</font>', "Confirma?")
            lOk := .T.
        Else
            lOk := .F.
        EndIf
    EndIf

    If lOk

        If Select('P42') < 0
            DbSelectarea("P42")
        EndIf
        P42->(DbSetOrder(1)) // P42_FILIAL + P42_GRUPO + P42_FILAUT

        If CNA->(dbseek(cCn9Filial + cCn9Numero + cCn9Revisa ))
            cCnaNumero := CNA->CNA_NUMERO
        Else
            lOk := .F.
        EndIF

        If lOk

            cQuery := ""
            cQuery +=" SELECT P42.P42_GRUPO,P42.P42_DESCR,P42.P42_ATIVO  " + CRLF
            cQuery +=" FROM " + RetSqlname("P42") + " P42 " + CRLF
            cQuery +=" WHERE P42.P42_FILIAL = '" + xFilial("P42") + "'"
            cQuery +=" AND P42.P42_ATIVO = 'S'  " + CRLF
            cQuery +=" AND P42.D_E_L_E_T_ = ' '  " + CRLF
            cQuery +=" GROUP BY P42_GRUPO,P42_DESCR,P42_ATIVO" + CRLF
            cQuery +=" ORDER BY 1 " + CRLF

            cAreaTmp := getNextAlias()
            dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAreaTmp, .T., .T.)

            While !(cAreaTmp)->(Eof())
                AAdd( aGRUPOS , (cAreaTmp)->P42_GRUPO  )
                (cAreaTmp)->(DbSkip())
            EndDo
            (cAreaTmp)->(DBCloseArea())

            cQuery := ""
            cQuery +=" SELECT P42.P42_GRUPO,P42.P42_DESCR  " + CRLF
            cQuery +=" FROM " + RetSqlname("P42") + " P42 " + CRLF
            cQuery +=" WHERE P42.P42_FILIAL = '" + xFilial("P42") + "'"
            cQuery +=" AND P42.D_E_L_E_T_ = ' '  " + CRLF
            cQuery +=" GROUP BY P42_GRUPO,P42_DESCR" + CRLF
            cQuery +=" ORDER BY 1 " + CRLF

            cAreaTmp := getNextAlias()
            dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAreaTmp, .T., .T.)

            While !(cAreaTmp)->(Eof())
                AAdd( aP42 , { (cAreaTmp)->P42_GRUPO, (cAreaTmp)->P42_DESCR } )
                (cAreaTmp)->(DbSkip())
            EndDo
            (cAreaTmp)->(DBCloseArea())

            //--------------------------------------------------------------------------
            //Esse bloco efetua a conexão com o DBAccess caso a mesma ainda não exista
            //--------------------------------------------------------------------------
            If TCIsConnected()
                nConnect := TCGetConn()
                lCloseConnect := .F.
            Else
                nConnect := TCLink()
                lCloseConnect := .T.
            EndIf

            //-------------------------------------------------------------------------------------------
            //Só podemos continuar com a geração da tabela temporária caso exista conexão com o DBAccess
            //-------------------------------------------------------------------------------------------
            If nConnect >= 0

                For nX := 1 to len(aP42)

                    If len(aGRUPOS) > 0 .And. aScan(aGRUPOS, {|x| x == Alltrim(aP42[nX][1]) }) > 0
                        cStatus := "Sim"
                    else
                        cStatus := "Não"
                    EndIf

                    AADD(aDados , { Space(2), cStatus , Alltrim(aP42[nX][1]), Alltrim(aP42[nX][2]) })

                NEXT nX

                cAlias := cSufixo + getNextAlias()
                oTable := FwTemporaryTable():New(cAlias)
                //----------------------------------------------------
                //O array de campos segue o mesmo padrão do DBCreate:
                //1 - C - Nome do campo
                //2 - C - Tipo do campo
                //3 - N - Tamanho do campo
                //4 - N - Decimal do campo
                //----------------------------------------------------
                aFields := {}
                aAdd(aFields, {"OK"            , "C" , 2                         , 0                        })
                aAdd(aFields, {"ATIVO"         , "C" , 7                         , 0                        })
                aAdd(aFields, {"GRUPOS"        , "C" , TamSX3("P42_GRUPO")[01]   , TamSX3("P42_GRUPO")[02]  })
                aAdd(aFields, {"DESCRICAO"     , "C" , TamSX3("P42_DESCR")[01]    , TamSX3("P42_DESCR")[02]   })

                oTable:SetFields(aFields)
                //---------------------
                //Criação dos índices
                //---------------------
                oTable:AddIndex("01", {"GRUPOS"} )
                //---------------------------------------------------------------
                //Pronto, agora temos a tabela criado no espaço temporário do DB
                //---------------------------------------------------------------
                oTable:Create()
                //SQLToTrb(cQuery, aFields, cAlias)

                cAlias      := oTable:GetAlias()    // Nome do Alias
                cTableName  := oTable:GetRealName() // Nome no Banco

                //------------------------------
                //Inserção de dados
                //------------------------------
                For nJJ := 1 to len(aDados)

                    (cAlias)->(DBAppend())
                    (cAlias)->OK        := aDados[nJJ][01] // OK
                    (cAlias)->ATIVO     := aDados[nJJ][02] // ATIVO
                    (cAlias)->GRUPOS    := aDados[nJJ][03] // GRUPOS
                    (cAlias)->DESCRICAO := aDados[nJJ][04] // DESCRICAO

                    (cAlias)->(DBCommit())

                NEXT

                //Define as cores dos itens de legenda.aCores := {}
                aAdd(aCores,{ cAlias + "->ATIVO = 'Sim'" ,"BR_VERDE"	})
                aAdd(aCores,{ cAlias + "->ATIVO = 'Não'","BR_VERMELHO"})

                aCpoBro	:= {{ "OK"			,, "Mark"          ,"@!"               },;
                    { "ATIVO"		,, "Ativo"        ,"@BMP"             },;
                    { "GRUPOS"	    ,, "Gupos"         ,"@!"              },;
                    { "DESCRICAO"	,, "Descrição"     ,"@!"               };
                    }

                DEFINE DIALOG oDlg TITLE 'GRUPOS' FROM 9, 0 TO 680, 600 PIXEL STYLE nOR( WS_VISIBLE, WS_POPUP ) // Etilo Style DS_MODALFRAME ou nOR( WS_VISIBLE, WS_POPUP )
                DbSelectArea(cAlias)
                (cAlias)->(DbGotop())

                //Cria a MsSelect
                oBrwTrb := MsSelect():New(cAlias,"OK","",aCpoBro,@lInverte,@cMark,{33,1,320,300},,,,,aCores)
                oBrwTrb:bMark := {| | xMark(cAlias,cMark)}
                oBrwTrb:oBrowse:lCanAllmark := .T.
                oBrwTrb:oBrowse:lHasMark    := .T.	 
                Eval(oBrwTrb:oBrowse:bGoTop)	 
                oBrwTrb:oBrowse:Refresh()	
                ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| PutRetArea('INCLUIR',cAlias,cMark,@cVAR_AXB,cCn9Numero,cCnaNumero),oDlg:End() },bCancel,.F.,{{'BMPINCLUIR',{|| PutRetArea('EXCLUIR',cAlias,cMark,@cVAR_AXB,cCn9Numero,cCnaNumero),oDlg:End()},'Remove GruposxFilias do Contrato'}} /*aButtons*/,1,cAlias,.F.,.F.,.F.,.T.,.F., )

            EndIf
            //--------------------------------------
            //Fecha a conexão criada para os testes
            //--------------------------------------
            If lCloseConnect
                TCUnLink()
            EndIf

            oTable:Delete()

            P42->(DBCLOSEAREA())
        EndIf

    EndIf

    RestArea(aArea)

return .T.
/*/{Protheus.doc} xMark
    Gera a marca na tabela temporia
    @type Function - Static Function
    @author Cleiton Genuino
    @since 12/05/2023
    @version 12.1.2210
    @param cAlias   , CHARACTER , Alias temporário para gravação da marca
    @param cMark    , CHARACTER , Marca utilizada para verificação
    @return LOGICAL, Sempre retorna verdadeiro
/*/
Static Function xMark(cAlias,cMark)

    RecLock(cAlias,.F.)
    If Marked("OK")
        (cAlias)->OK := cMark
    Else
        (cAlias)->OK := ""
    EndIf
    (cAlias)->(MSUNLOCK())

Return .T.
/*/{Protheus.doc} PutRetArea
    Gera a marca na tabela temporia
    @type Function - Static Function
    @author Cleiton Genuino
    @since 12/05/2023
    @version 12.1.2210
    @param cAlias   , CHARACTER , Alias temporário para gravação da marca
    @param cMark    , CHARACTER , Marca utilizada para verificação
    @param cVAR_AXB , CHARACTER , Variavel de retorno da marca
    @param cCn9Numero , CHARACTER , Numero do contrato CN9 x CPD_CONTRA
    @param cCnaNumero , CHARACTER , Numero da CNA x CPD_NUMPLA
    @return LOGICAL, Sempre retorna verdadeiro
/*/
Static Function PutRetArea(cAction,cAlias,cMark,cVAR_AXB,cCn9Numero,cCnaNumero)
    Local aArea        := GetArea() as array
    Local aExc         := {}        as array
    Local aInc         := {}        as array
    Default cAction    := "INCLUIR"
    Default cAlias     := ""
    Default cCn9Numero := ""
    Default cCnaNumero := ""
    Default cMark      := ""
    Default cVAR_AXB   := ""

    If Select('P43') < 0
        DbSelectarea("P43")
    EndIf
    P43->(DbSetOrder(1)) // P43_FILIAL + P43_GRUPO + P43_FILAUT

    DbSelectArea(cAlias)
    (cAlias)->(DbGotop())

    FWMsgRun( , {|oSay| CleanMark(oSay)}, "Clean", "Aguarde..." )

    While !(cAlias)->(Eof())


        If IsMark("OK",cMark)

            cVAR_AXB += Alltrim((cAlias)->GRUPOS) + ";"
            FWMsgRun( , {|oSay|  DirtyMark( (cAlias)->GRUPOS , cMark, oSay )}, "Carregando", "Aguarde...")
            // Inclui os novos registros na CPD( Filiais autorizadas x contrato)
            If !Empty((cAlias)->GRUPOS)

                If P43->(dbseek(xFilial("P43") + (cAlias)->GRUPOS ))

                    While !P43->(Eof()) .And. (cAlias)->GRUPOS == P43->P43_GRUPO

                        IF !Empty(P43->P43_ATIVO) .And. Upper(Alltrim(P43->P43_ATIVO)) == 'S' .And. cAction == 'INCLUIR'

                            AADD(aInc,{ cCn9Numero , cCnaNumero , P43->P43_FILAUT } )

                        ELSEIF !Empty(P43->P43_ATIVO) .And. cAction == 'EXCLUIR'

                            AADD(aExc,{ cCn9Numero , cCnaNumero , P43->P43_FILAUT } )

                        ENDIF

                        P43->(DbSkip())
                    EndDo

                ENDIF

            ENDIF

        ENDIF

        (cAlias)->(DBSkip())
    EndDo

    FWMsgRun( , {|oSay|  CN240GrvCPD(aInc, aExc) }, "Gravando grupos", "Aguarde...")

    RestArea(aArea)

Return .T.

/*/{Protheus.doc} GETCN240
    Gera a marca na tabela temporia
    @type Function - Static Function
    @author Cleiton Genuino
    @since 12/05/2023
    @version 12.1.2210
    @return CHARACTER, Variavel de retorno da marca
/*/
User Function GETCN240()
    Local aArea     := GetArea()      as array
    Local AGRUPOS   := {}             as array
    Local cAliasP42 := GetNextAlias() as character
    Local cQueryP42 := ""             as character
    Local cVAR_AXB  := ""             as character

    cQueryP42 += " SELECT P42.P42_GRUPO FROM "+RetSqlname("P42")+" P42  " + CRLF
    cQueryP42 += " WHERE P42.P42_FILIAL  = '"+XFILIAL("P42")+ "' " + CRLF
    cQueryP42 += " AND P42.P42_OK = 'OK' " + CRLF
    cQueryP42 += " AND P42.D_E_L_E_T_ = ' ' " + CRLF
    cQueryP42 += " GROUP BY P42_GRUPO " + CRLF
    cQueryP42 += " ORDER BY P42_GRUPO " + CRLF

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryP42),cAliasP42,.T.,.T.)

    WHILE (cAliasP42)->(!Eof())
        AADD( AGRUPOS ,{ (cAliasP42)->P42_GRUPO } )
        If !Empty( Alltrim((cAliasP42)->P42_GRUPO) )
            cVAR_AXB += Alltrim((cAliasP42)->P42_GRUPO) + ";"
        EndIF
        (cAliasP42)->(DbSkip())
    EndDo

    // Não deixa Alias TMP aberto
    If Select(cAliasP42) > 0
        (cAliasP42)->(dbCloseArea())
    ENDIF

    RestArea(aArea)

Return cVAR_AXB
/*/{Protheus.doc} CleanMark
    Limpa marca da tabela P42
    @type Function - Static Function
    @author Cleiton Genuino
    @since 12/05/2023
    @version 12.1.2210
    @param oSay, OBJECT, Objeto de tela a ser utilizada na limpeza
    @return LOGICAL , Sempre retorna verdadeiro
/*/
Static Function CleanMark(oSay)
    Local aArea  := GetArea()
    Default oSay := nil

    If Select('P42') < 0
        DbSelectarea("P42")
    EndIF
    P42->(Dbsetorder(1))
    P42->(DbGotop())

    While !P42->(Eof())

        If RecLock("P42",.F.)
            P42->P42_OK := ""
            P42->(MSUNLOCK())
        EndIf

        oSay:cCaption := "Loading area aguarde..."

        P42->(DbSkip())

    EndDo

    P42->(DBCLOSEAREA())

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} DirtyMark
    Suja a marca da tabela P42
    @type Function - Static Function
    @author Cleiton Genuino
    @since 12/05/2023
    @version 12.1.2210
    @param cArea    , CHARACTER , Area a ser selecionada
    @param cMark    , CHARACTER , Marca utilizada
    @param oSay     , OBJECT    , Objeto que foi utilizado na visão de marca
    @return LOGICAL , Sempre retorna verdadeiro
/*/
Static Function DirtyMark(cArea,cMark,oSay)
    Local aArea   := GetArea()
    Default cArea := ""
    Default cMark := ""
    Default oSay  := nil

    If Select('P42') < 0
        DbSelectarea("P42")
    EndIF
    P42->(Dbsetorder(3))

    If P42->(dbSeek(xFilial("P42") + PADR( cArea ,TamSx3("P42_GRUPO")[1]) ))

        While !P42->(Eof()) .And. Alltrim(cArea) == Alltrim(P42->P42_GRUPO)

            oSay:cCaption := "Loading area..."

            If RecLock("P42",.F.)
                P42->P42_MARK := cMark
                P42->(MSUNLOCK())
            EndIf

            P42->(DbSkip())

        EndDo

    EndIf

    P42->(DBCLOSEAREA())

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} CN240GrvCPD

    Grava/Deleta nas filiais autorizadas x contrato

    @type Function - Static Function
    @author Cleiton Genuino
    @since 12/05/2023
    @version 12.1.2210
    @param aInc, Array, Lista com as filiais inclusas
    @param aExc , Array, Listacom as filiais excluidas

/*/
Static Function CN240GrvCPD(aInc, aExc)
    Local aArea     := GetArea() as array
    Local cContrato := ''        as character
    Local cFilaut   := ''        as character
    Local cNumpla   := ''        as character
    Local nX        := 0         as numeric

    If Select('CPD') < 0
        DBSELECTAREA( 'CPD' )
    ENDIF
    CPD->(dbSetOrder(1)) // CPD_FILIAL, CPD_CONTRA, CPD_NUMPLA, CPD_FILAUT

    Begin Transaction

        // Inclui os novos registros na CPD( Filiais autorizadas x contrato)

        For nX := 1 To Len(aInc)

            cContrato := Padr(aInc[nX][1],TamSx3("CPD_CONTRA")[1])
            cNumpla   := Padr(aInc[nX][2],TamSx3("CPD_NUMPLA")[1])
            cFilaut   := Padr(aInc[nX][3],TamSx3("CPD_FILAUT")[1])

            If !CPD->(dbSeek(xFilial("CPD")+cContrato+cNumpla+cFilaut))
                Reclock("CPD", .T.)
                CPD_FILIAL := xFilial("CPD")
                CPD_CONTRA := cContrato  //SubStr(aInc[nX],1,nTamCTR)
                CPD_NUMPLA := cNumpla    //SubStr(aInc[nX],nTamCTR+1,nTamPla)
                CPD_FILAUT := cFilaut    //SubStr(aInc[nX],nTamCTR+nTamPla+1,FWGETTAMFILIAL)
                CPD->(MsUnlock())
            EndIf
        Next nX

        // Exclui os registros da CPD( Filiais autorizadas x contrato)
        For nX := 1 To Len(aExc)

            cContrato := Padr(aExc[nX][1],TamSx3("CPD_CONTRA")[1])
            cNumpla   := Padr(aExc[nX][2],TamSx3("CPD_NUMPLA")[1])
            cFilaut   := Padr(aExc[nX][3],TamSx3("CPD_FILAUT")[1])

            If CPD->(dbSeek(xFilial("CPD")+cContrato+cNumpla+cFilaut))
                Reclock("CPD", .F.)
                CPD->(dbDelete())
                CPD->(MsUnlock())
            EndIf
        Next nX

    End Transaction

    RestArea(aArea)

Return
