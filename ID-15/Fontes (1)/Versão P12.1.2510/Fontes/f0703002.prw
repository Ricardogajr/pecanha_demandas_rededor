#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"


/*{Protheus.doc} F0703002
Rotina de Estorno de virada de estoque
 
@author Alex Sandro Valario
@since  27/06/2017
@project MAN0000007423041_EF_030
@menu Estorna Fechamento
@version P12.1.7
@return Nil  
*/

Static oDbApData  := NIL

User Function F0703002(lJob)

    Local dDtFec    := GetMv("MV_ULMES")
    Default lJob    := .F.

    If lJob
        ProcEstorno(lJob)
    Else
        If ! MsgYesNo("Confirma o estorno do fechamento [" + dtoc(dDtFec) + "]")
            Return
        EndIf

        AutoGrLog("Processando ESTORNO " + dtoc(dDtFec) + " em " + DToC(date()) )
        AutoGrLog("Estorno do ultimo fechamento")
        Processa({|| ProcEstorno(lJob) }, "Estorno do ultimo fechamento", "Estorno de virada de saldo personalizado", .F.)  
        AutoGrLog("Processamento finalizando com sucesso.")       

        cLog := MemoRead(NomeAutoLog())
        FErase(NomeAutoLog())

		PreparaEmail(cLog,  .T. )
    
    EndIf

Return

Static Function ProcEstorno(lJob)

    Local dDtFec    := GetMv("MV_ULMES")
    Local dDtFecAnt := GetFecAnt()
    
    Local aP26    := {}
    Local lProcT  := .F. 

    Private cChaveFec	:= ""
    
    If !LockByName("F0703002" + cFilAnt, .F., .F.)
        Conout( 'F0703002 - Estorno de fechamento em andamento!')
        Return
    EndIf

    Begin Transaction

        If !lJob
        	AutoGrLog("Estorno do ultimo fechamento. Deletando SB9.")    
        Endif
        DelSB9(dDtFec)     // Voltar

		If !lJob
	        AutoGrLog("Estorno do ultimo fechamento. Deletando SB2.")
		Endif
        AtuSB2(dDtFecAnt)  // Voltar

        If !lJob

//        	cChaveFec := GetChave(cFilAnt, dDtFecAnt)
        	cChaveFec := GetChave(cFilAnt, dDtFec)

			CriaArq() // cria a tabela no banco caso não exista
        
	        If ! BuscaMov(aP26, lProcT)  // Caso não tenha 
       		    Break
       		EndIf  
			 
        	If !Empty(cChaveFec) .AND. Len(aP26) <> 0 

		        If !lJob
        			AutoGrLog("Estorno do ultimo fechamento. Atualizando P26.")    
				Endif
 	       		
 	       		AtuP26(cFilAnt, aP26[1][2][1][1]) // Voltar
//   	     		AtuP27(cFilAnt, cChaveFec) // Voltar


		        If !lJob
        			AutoGrLog("Estorno do ultimo fechamento. Atualizando P27.")    
				Endif
   	     		AtuP27(cFilAnt, aP26[1][2][1][1]) // Voltar
   	     		
 	     		AtuStatus("1" , aP26[1][2][1][1] , "")

        	EndIf

        EndIf

    End Transaction     

	If !lJob
    	AutoGrLog("Estorno do ultimo fechamento. Atualizando MV_ULMES.")    
	Endif
	
    PutMV("MV_ULMES", dDtFecAnt)
    UnLockByName("F0703002" + cFilAnt, .F., .F.)		

Return

Static Function GetFecAnt()
    Local cQuery    := ""
    Local cNewAlias := GetNextAlias()
    Local dDtFecAnt := Ctod("")
    Local aArea     := GetArea()
    
    cQuery := " SELECT DISTINCT B9_DATA "  
    cQuery += "  FROM " +RetSqlName("SB9") + " "
    cQuery += "  WHERE D_E_L_E_T_ = ' ' "
    cQuery += "  AND B9_FILIAL = '" + xFilial("SB9") + "' "
    cQuery += "  ORDER BY 1 DESC "
    cQuery := ChangeQuery( cQuery )

    dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery), cNewAlias)

    (cNewAlias)->(DbGotop())
    (cNewAlias)->(DbSkip())
    If (cNewAlias)->(! Eof())
        dDtFecAnt := SToD((cNewAlias)->B9_DATA)
    EndIf
    (cNewAlias)->(dbCloseArea())
    RestArea(aArea)

Return dDtFecAnt
    

Static Function DelSB9(dDtFec)
    Local cQuery := ""
    
    If Empty(dDtFec)
        Return
    EndIf

    cQuery := " UPDATE " + RetSqlName("SB9") 
    cQuery += "    SET  D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
	cQuery += "  WHERE  B9_DATA = '" + dtos(dDtFec) + "' AND "
    cQuery += "         B9_FILIAL = '" + xFilial("SB9") + "' AND "
    cQuery += "         D_E_L_E_T_ = ' ' "
    
    TcSqlExec(cQuery)

Return 

Static Function AtuSB2(dDtFecAnt)
    Local aArea    := GetArea()
    Local aAreaSB2 := {}
    Local nQINI    := 0
    Local nVINI    := 0

    If Empty(dDtFecAnt)
        Return
    EndIf
    
    Chkfile("SB2")
    
    aAreaSB2 := SB2->(GetArea("SB2"))

    SB2->(DbSetOrder(1))
    SB2->(DbSeek(xFilial("SB2")))

    While SB2->( ! Eof() .and. B2_FILIAL == xFilial("SB2"))
        
        nQINI := 0
        nVINI := 0

        If SB9->(DbSeek(xFilial("SB9") + SB2->(B2_COD + B2_LOCAL) + Dtos(dDtFecAnt)))
            nQINI := SB9->B9_QINI
            nVINI := SB9->B9_VINI1
        EndIf
        
        SB2->(RecLock("SB2", .F.))
            SB2->B2_QFIM  := nQINI
            SB2->B2_VFIM1 := nVINI
            SB2->B2_XDATA := dDtFecAnt
            SB2->B2_XFLAG := "E" // F-Fechamento E-Estorno
            SB2->B2_XQTDE:= CalcEst(SB2->B2_COD, SB2->B2_LOCAL, dDtFecAnt+1)[ 1 ]
            SB2->B2_XVLTOT:= SB2->(B2_XQTDE * (B2_VFIM1 / B2_QFIM )  )

        SB2->(MsUnLock())

        SB2->(DbSkip())
    EndDo

Return 

Static Function GetChave(cFilTrb, dDtFecAnt)
    Local cDtFech	:= ""
    Local cNewAlias := GetNextAlias()
    Local cQuery    := ""
    
    cQuery := " SELECT P26_CODFEC , P26_DTFECH "  
    cQuery += "  FROM " +RetSqlName("P26") + " "
    cQuery += "  WHERE P26_FILIAL = '" + cFilTrb + " '"
    cQuery += "  AND P26_DTFECH = '" + DtoS(dDtFecAnt) + "'"
    cQuery += "  AND D_E_L_E_T_ = ' '"
    cQuery += "  ORDER BY P26_PROCTB DESC "
    cQuery := ChangeQuery( cQuery )

    dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery), cNewAlias)

    If (cNewAlias)->(! Eof())   
        cDtFech := (cNewAlias)->P26_DTFECH
    EndIf
    (cNewAlias)->(dbCloseArea())
Return cDtFech

Static Function AtuP26(cFilTrb, cChaveFec)

	Local aAreaP26 := P26->(GetArea())
	P26->(DbSetOrder(1))
	
	If P26->(DbSeek(cFilTrb + cChaveFec))
		While P26->(P26_FILIAL + P26_CODFEC) == cFilTrb + cChaveFec

			RecLock("P26",.F.)
				// P26->P26_STATUS := '1'
				DBDelete()
			P26->(MsUnLock())
			P26->(DbSkip())
		EndDo
	EndIf
	RestArea(aAreaP26)

Return

Static Function AtuP27(cFilTrb, cChaveFec)
	Local aAreaP27 := P27->(GetArea())
	P27->(DbSetOrder(1))
	
	If P27->(DbSeek(cFilTrb + cChaveFec))
		While P27->(P27_FILIAL + P27_CODFEC) == cFilTrb + cChaveFec
			RecLock("P27",.F.)
				DBDelete()
				// P27->P27_OBSERV := ''
				// P27->P27_DTPROC := ''
				// P27->P27_HRPROC := ''
			P27->(MsUnLock())
			P27->(DbSkip())
		EndDo
	EndIf
	RestArea(aAreaP27)
Return


Static Function BuscaMov(aP26, lProcT)

    Local cQuery    := ""
    Local cNewAlias := GetNextAlias()
    Local cFilAux   := ""
    Local aP26Aux   := {}
    Local dDtFec    := GetMv("MV_ULMES")

    cQuery := " SELECT DISTINCT P26_FILIAL,P26_CODFEC, P26_DTFECH, P26_QTDTOT, P26_STATUS, P26_OPER "  // fazer versão para oracle
    cQuery += "  FROM F0703001 " 
    cQuery += "  WHERE P26_STATUS = '3' "
    cQuery += "  AND P26_DTFECH = '" + DTOC(dDtFec) + "' "
    If ! lProcT
        cQuery += "    AND P26_FILIAL = '" + cFilAnt + "' "
    EndIf
    cQuery += "  ORDER BY 1, 2, 5 "
    
    //EECVIEW(cQuery)
    
    cQuery := ChangeQuery( cQuery )

	 InicioETL() // Inicializa conexão

        

        SelecionaETL ( cQuery, cNewAlias ) // Executa a Query
    
        (cNewAlias)->(DbGotop())
        While (cNewAlias)->(! Eof())
            If ! (cNewAlias)->P26_FILIAL == cFilAux
                AAdd(aP26,{(cNewAlias)->P26_FILIAL, {}})
                cFilAux   := (cNewAlias)->P26_FILIAL
            EndIf
            (cNewAlias)->(AAdd(aP26Aux,{P26_CODFEC, P26_DTFECH, P26_QTDTOT, P26_OPER }))
            
            aP26[len(aP26),2] := aClone(aP26Aux)
            
            (cNewAlias)->(DbSkip())
        End
        (cNewAlias)->(dbCloseArea())
    
		TerminoETL() // Finaliza conexão    
    
Return .T.

Static Function InicioETL()
    Local cDBMS   := GETMV("FS_DBMS")
    Local cBanco  := GETMV("FS_DTBASE")
    Local cServer := GETMV("FS_SERVER")
    Local nPort	  := Val(GETMV("FS_PORT"))	
                             
    If Empty(cDBMS) .Or. Empty(cBanco) .Or. Empty(cServer) .Or. Empty(nPort)
        cMsgETL := "Parametros de conexao nao preenchidos FS_DBMS|FS_DTBASE|FS_SERVER|FS_PORT"
        Break
    EndIf
        
    If ValType(oDbApData) == "O" 
    	IF oDbApData:HasConnection()	
        	cMsgETL := "Conexão com o ApData ja esta Ativa"
        	Break
        Endif
    EndIf
    
    oDbApData := FWDBAccess():New(cDBMS + "/" + cBanco, cServer, nPort)
    oDbApData:SetConsoleError( .T. )																		
    
    If !oDbApData:OpenConnection()
        cMsgETL := "Falha Conexão com a base Externa - Erro: " + AllTrim( oDbApData:ErrorMessage() )		
        Break
    EndIf

Return 

// As funcoes Static de conexap foram redeclaradas para fins de clareza neste fonte

Static Function SelecionaETL(cQuery, cNewAlias)
    If Empty(cQuery)	
        cMsgETL := "Parametro de query vazio"
        Break
    EndIf
    If Empty(cNewAlias)
        cMsgETL := "Parametro de Alias nao informado"
        Break
    Endif	
    
    If ValType(oDbApData) == "O" .And. !oDbApData:HasConnection()
        cMsgETL := "Conexao com o ApData nao esta Ativa"
        Break
    EndIf
        
    If Select(cNewAlias) > 0
        (cNewAlias)->(dbCloseArea())
    Endif
    
    oDbApData:NewAlias( cQuery , cNewAlias )
    If oDbApData:HasError()
        cMsgETL := "Erro na selecao dos dados na tabela " + cNewAlias + " - " + AllTrim(oDbApData:ErrorMessage())
        Break
    Endif	

Return

Static Function TerminoETL()
    If ValType(oDbApData) == "O" .And. ! oDbApData:HasConnection()	
        cMsgETL := "Conexao com o ApData nao esta Ativa"
        Break
    EndIf
	oDbApData:CloseConnection()
	oDbApData:Finish()
    oDbApData := Nil

Return


Static Function CriaArq()

    Local cTbl     := "F0703001"
    Local aTblStru := {}
    Local aTblIndex:= {}
    Local cMsg     := ""

    AAdd(aTblStru, {"P26_FILIAL", "VARCHAR", 008})
    AAdd(aTblStru, {"P26_CODFEC", "VARCHAR", 019})   // AAAA-MM-DD HH:MM:SS
    AAdd(aTblStru, {"P26_DTFECH", "VARCHAR", 010})   //DD/MM/AAAA
    AAdd(aTblStru, {"P26_OPER"  , "VARCHAR", 001})   // F=Fechamento; E=Estorno
    AAdd(aTblStru, {"P26_QTDTOT", "VARCHAR", 007})   
    AAdd(aTblStru, {"P26_STATUS", "VARCHAR", 001})   // 1= Disponivel para processamento; 2=Processando; 3=Processado OK; 4=Processado Erro
    AAdd(aTblStru, {"P26_PROCTB", "VARCHAR", 019})   // AAAA-MM-DD HH:MM:SS
    AAdd(aTblStru, {"P26_DTEXFE", "VARCHAR", 010})   //DD/MM/AAAA
    AAdd(aTblStru, {"P26_HREXFE", "VARCHAR", 008})   //HH:MM:SS
    AAdd(aTblStru, {"P26_USER"  , "VARCHAR", 030})   
    AAdd(aTblStru, {"P27_IDORIG", "VARCHAR", 019})   // Id do Front
    AAdd(aTblStru, {"P27_PRODUT", "VARCHAR", 015})
    AAdd(aTblStru, {"P27_QTDPRO", "VARCHAR", 014})
    AAdd(aTblStru, {"P27_LOCAL" , "VARCHAR", 006})
    AAdd(aTblStru, {"P27_VLTOTP", "VARCHAR", 015})
    AAdd(aTblStru, {"P27_OBSERV", "VARCHAR", 200})
    AAdd(aTblStru, {"P27_DTPROC", "VARCHAR", 010})   //DD/MM/AAAA
    AAdd(aTblStru, {"P27_HRPROC", "VARCHAR", 008})   //HH:MM:SS
    AAdd(aTblStru, {"P27_IDFRON", "VARCHAR", 001})

    aTblIndex := {"P26_FILIAL", "P26_CODFEC", "P26_STATUS"}

    InicioETL() 
        CriaETL(cTbl, aTblStru, aTblIndex)
    TerminoETL()

    If ! Empty(cMsg)
        cMsgETL := cMsg
        Break
    EndIf
	
Return 

Static Function CriaETL(cTbl, aTblStru, aTblIndex)
    Local cCommand := ""
//  Local cOwner   := GetMV('FS_OWNER',,'')
    Local cOwner := ""
    Local nCampos  := 0
    Local nIndice  := 0
    
    If Empty(cTbl)
        cMsgETL := "Tabela nao informada nos parametros"
        Break
    EndIf
    If Len(aTblStru) == 0
        cMsgETL :=  "Array de Estrutura da tabela " + cTbl + " nao informado nos parametros"
        Break
    EndIf
    If ValType(oDbApData) == "O" .And. !oDbApData:HasConnection()
        cMsgETL := "Conexao com o ApData nao esta Ativa"
        Break
    EndIf

    If oDbApData:FileExists(cTbl)
        Return
    EndIf

    cCommand := "CREATE TABLE " + cOwner + cTbl + "( "
    For nCampos := 1 To Len(aTblStru)
        cCommand += aTblStru[nCampos, 1] + " " 
        If aTblStru[nCampos, 2] == "VARCHAR"
            If TcGetDb() == "ORACLE"
                cCommand += "VARCHAR2(" + StrZero(aTblStru[nCampos, 3], 3) + ")"
            Else
                cCommand += "VARCHAR(" + StrZero(aTblStru[nCampos, 3], 3) + ")"
            EndIf
        Else
            cCommand += aTblStru[nCampos, 2] 
        EndIf
        If nCampos < Len(aTblStru)
            cCommand += ", "
        EndIf
    Next
    cCommand += ")"	 
        
    oDbApData:SQLExec(cCommand)
    If oDbApData:HasError()
        cMsgETL := "Erro: [" + AllTrim(Str(oDbApData:SqlError())) + "] na criacao da tabela: " + cTbl + " - " + AllTrim(oDbApData:ErrorMessage())  	
        Break
    EndIf

    cCommand := "CREATE INDEX T_" + cTbl + "_IDX ON " + cOwner + cTbl + " (" 
    For nIndice := 1 to Len(aTblIndex) 
        cCommand += aTblIndex[nIndice]
        If nIndice < Len(aTblIndex) 
           cCommand += ", "
        EndIf    
    Next
    cCommand += ")"
                        
    oDbApData:SQLExec(cCommand)
    If oDbApData:HasError()
        cMsgETL += "Erro: [" + AllTrim(Str(oDbApData:SqlError())) + "] na criacao da tabela: " + cTbl + " - " + AllTrim(oDbApData:ErrorMessage())  	
        Break
    Endif	  			

Return

Static Function PreparaEmail(cLog,  lEstorno)
	Local cSMTP     := AllTrim(GetMV("MV_RELSERV"))  // smtp.ig.com.br ou 200.181.100.51
	Local cConta    := AllTrim(GetMV("MV_RELACNT"))  // fulano@ig.com.br
	Local cPass     := AllTrim(GetMV("MV_RELPSW" ))  // 123abc
	Local cContaDes := AllTrim(GetMv("FS_EF70301"))
	Local cAssunto  := "Termino do Fechamento de Estoque Especifico da filial:" + cFilAnt
	Local cMensagem := "" 
	Local cRet      := ""
	Default lEstorno := .F.


	cMensagem := "<html>"
	cMensagem += "<head><title>" + AllTrim(cAssunto) + "</title></head>"

	cMensagem += "<body>" 
	cMensagem += "<br>"
	cMensagem += "Sr(a)(s),<br>"
	cMensagem += "<br>"
	If ! lEstorno
		cMensagem += "O Fechamento Especifico de Estoque foi finalizado em " + Dtoc(dDataBase) + " às " + Left(Time(),5) + " <br>"
	Else
		cMensagem += "O Estorno do Fechamento Especifico de Estoque foi finalizado em " + Dtoc(dDataBase) + " às " + Left(Time(),5) + " <br>"
	EndIf
	cMensagem += "<br>"
	cMensagem += "Log:<br>"
	cMensagem += StrTran( cLog, CRLF , "<br>" )
	cMensagem += "</body>"
	cMensagem += "</html>"

	cRet := EnviaEmail(cSMTP, cConta, cPass, cContaDes, cAssunto, cMensagem)

Return cRet



Static Function EnviaEmail(cSMTP, cConta, cPass, cContaDes, cAssunto, cMensagem)
	Local lConSMTP  := .F.
	Local lEnvEmail := .F.
	Local cError    := ""
	Local cRet      := ""  

    Local nSMTPTime     := GetNewPar("MV_RELTIME",60)
    Local nSMTPPort     := GetNewPar("MV_PORSMTP",25)

	/*Connect SMTP Server cSMTP Account cConta Password cPass Result lConSMTP
	If lConSMTP
		Send Mail From cConta To cContaDes Subject cAssunto Body  cMensagem  Result lEnvEmail

		If !lEnvEmail // Erro no envio do email
			Get Mail Error cError
			cRet := "Erro no envio do email: " + cError
		EndIf
		Disconnect SMTP Server
	Else // Erro na conexao com o SMTP Server
		Get Mail Error cError
		cRet := "Erro na conexão SMTP: " + cError
	EndIf*/



    // Objeto de Email
    oServer := tMailManager():New()
    nErr := oServer:init("",cSMTP,cConta,cPass,,)
    If nErr <> 0    
        alert("Falha ao conectar:" + oServer:getErrorString(nErr)) // Falha ao conectar:     
        Return(.F.)
    Endif
    If oServer:SetSMTPTimeout(nSMTPTime) != 0
        alert("Falha ao definir timeout") // Falha ao definir timeout
        Return(.F.)
    EndIf
    nErr := oServer:smtpConnect()
    If nErr <> 0    
        alert("Falha ao conectar:" + oServer:getErrorString(nErr)) // Falha ao conectar:        
        oServer:SMTPDisconnect()
        Return(.F.)
    EndIf
    // Realiza autenticacao no servidor
    If lAutentica
        nErr := oServer:smtpAuth(cConta,cPass)
        If nErr <> 0        
            alert("Falha ao autenticar: " + oServer:getErrorString(nErr)) // Falha ao autenticar: 
            oServer:SMTPDisconnect() 
        EndIf
    EndIf    

    // Cria uma nova mensagem (TMailMessage)
    oMessage := tMailMessage():new()
    oMessage:clear()        

    oMessage:cFrom        := cConta 
    oMessage:cTo         :=  cContaDes 
    oMessage:cSubject    := cAssunto
    oMessage:cBody       := cMensagem

    nErr := oMessage:send(oServer)
    If nErr <> 0        
        alert("Falha ao Enviar MSg: " + oServer:getErrorString(nErr)) // Falha ao autenticar: 
        oServer:SMTPDisconnect() 
    EndIf

    // Desconecta do Servidor
    oServer:smtpDisconnect() 

Return cRet
Static Function AtuStatus(cStatus, cCodFec, cMsg)  // 1= Disponivel para processamento; 2=Processando; 3=Processado OK; 4=Processado Erro
	Local cCommand := ""
	Local cOwner   := ""
	Default cMsg   := ""

	cOwner   := GetMV('FS_OWNER', , '')
	cCommand := " UPDATE "+cOwner+"F0703001 "
	cCommand += "    SET P26_STATUS = '" + cStatus + "' "

	If cStatus == "2"
		cCommand += "       , P26_PROCTB = '"+ FwTimeStamp() + "' "
	EndIf
	If cStatus == "3"
		cCommand += "      , P26_DTEXFE = '"+ Dtoc(Date()) + "' "
		cCommand += "      , P26_HREXFE = '"+ Time() + "' "
	Endif
	If cStatus $ "34"
		cCommand += "      , P27_DTPROC = '"+ Dtoc(Date()) + "' "
		cCommand += "      , P27_HRPROC = '"+ Time() + "' "
	EndIf
	If ! Empty(cMsg)
		cCommand += "      , P27_OBSERV = '"+ cMsg + "' "
	EndIf
	cCommand +=  " WHERE P26_CODFEC = '"+ cCodFec + "' "
	cCommand += "    AND P26_FILIAL = '"+ cFilAnt + "' "

	InicioETL()
	AlteraETL(cCommand)
	TerminoETL()

Return
