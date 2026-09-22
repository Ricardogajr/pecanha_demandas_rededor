#Include "Protheus.ch"
#INCLUDE "TopConn.ch"
#Include "Totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MSEXTRSBZ()
AutomaÃ§Ã£o de cadastros - Gera arquivo de carga complementar SBZ
@author Lucas Miranda de Aguiar
@since 25/04/2024
@version 1.0
Inicial
@return NIL
/*/
//-------------------------------------------------------------------

User Function MSEXTRSBZ()


	Local aArea := GetArea()
	Local cWarn := ""
	Local aPergs := {}
	Local nX := 0
	Local aRet := {}

	Private lMailErr := .F.
	Private aEmails := {}
	Private cMailErr := "" 
	Private cFilSel := ""
	Private cMailSel := ""
	Private cQry := ""
	Private cTmpTbl := GetNextalias()
	Private oFWMsExcel
	Private oExcel
	Private cArquivo    := " "
	Private oFWriter
	Private cPasta := GetTempPath()
	Private lEnvMail := .F.


	aAdd( aPergs ,{9,"Relatório de local padrão SBZ",50, 20,.T.})

	aAdd(aPergs,{1,"Código da filial",Space(8),"","","SM0","",10,.F.})

	//aAdd(aPergs,{1,"Enviar para (email 1;email 2...)",Space(200),"","",,"",100,.F.})

	If ParamBox(aPergs,"Relatório local padrão SBZ",@aRet)
		For nX:=1 To Len(aRet)
			If !Empty(aRet[nX]) .And. Len(aRet[nX]) == 8
				cFilSel := AllTrim(UPPER(aRet[nX]))
			EndIf
			If !Empty(aRet[nX]) .And. Len(aRet[nX]) <> 8
				cMailSel := AllTrim(aRet[nX])
			EndIf
		Next nX
		If !Empty(cMailSel)
			lEnvMail := .T.
			aEmails := StrTokArr(cMailSel,";")
			For nX := 01 To Len(aEmails)
				If !IsEmail(aEmails[nX])
					lMailErr := .T.
					cMailErr := aEmails[nX]
					Exit
				EndIf
			Next nX
		EndIf
		If !FWFilExist("01",cFilSel)
			Alert("A filial informada no parâmetro não existe!" + CRLF + " O processo será abortado.")
			Return
		ElseIf lMailErr
			Alert("O email " +cMailErr+ " é inválido, favor verificar.")
		Else
			MsgRun("Gerando Relatório da SBZ... ", "Utilitarios Go Live " + cFilSel, {|| fProcessa() })
		EndIf
	Else
		Alert("Processo abortado.")
		Return
	Endif

	RestArea(aArea)
Return

Static Function fProcessa()

	Local cDirSrv := "\sigadoc\RELSBZ\"

	cQry += " SELECT "
	cQry += "'" +cFilSel + "'" + " BZ_FILIAL,"
	cQry += " B1_COD BZ_COD,'PADRAO'  BZ_LOCPAD, '1' BZ_QE FROM "
	cQry += RetSqlname("SB1")
	cQry += " WHERE B1_XESTOQ = 'N' AND D_E_L_E_T_ = ' '"
	cQry += " AND NOT B1_COD IN (SELECT BZ_COD FROM "
	cQry += RetSqlname("SBZ")
	cQry += " WHERE BZ_FILIAL = '"
	cQry += cFilSel
	cQry += "' AND D_E_L_E_T_ = ' ') "

	TcQuery cQry Alias ( cTmpTbl ) New

	//Criando o objeto que irÃ¡ gerar o conteÃºdo do Excel
	oFWMsExcel := FWMSExcel():New()

	oFWriter := FWFileWriter():New(cPasta + "SBZ_NESTOQ_LOCALPADRAO_" +cFilSel+".txt", .T.)
	oFWriter:Create()


	oFWMsExcel:AddworkSheet("SBZLOCPAD")

	//Criando a Tabelas
	oFWMsExcel:AddTable("SBZLOCPAD","SBZLOCPAD")

	//Criando colunas tabela 1
	oFWMsExcel:AddColumn("SBZLOCPAD","SBZLOCPAD","BZ_FILIAL",1)
	oFWMsExcel:AddColumn("SBZLOCPAD","SBZLOCPAD","BZ_COD",1)
	oFWMsExcel:AddColumn("SBZLOCPAD","SBZLOCPAD","BZ_LOCPAD",1)
	oFWMsExcel:AddColumn("SBZLOCPAD","SBZLOCPAD","BZ_QE",1)

	oFWriter:Write("BZ_FILIAL;BZ_COD;BZ_LOCPAD;BZ_QE" + CRLF)


	(cTmpTbl)->(DbGoTop())

	While !( cTmpTbl )->( Eof() )
		oFWMsExcel:AddRow("SBZLOCPAD","SBZLOCPAD",{;
			(cTmpTbl)->BZ_FILIAL,;
			(cTmpTbl)->BZ_COD,;
			(cTmpTbl)->BZ_LOCPAD,;
			(cTmpTbl)->BZ_QE;
			})

		oFWriter:Write((cTmpTbl)->BZ_FILIAL+";"+ (cTmpTbl)->BZ_COD+";"+ (cTmpTbl)->BZ_LOCPAD+";"+ (cTmpTbl)->BZ_QE + CRLF)

		(cTmpTbl)->(DbSkip())
	EndDo

	(cTmpTbl)->(DBCLOSEAREA())

	//Ativando o arquivo e gerando o xml
	cArquivo    := cPasta+'RELPADRAOSBZ_' + cFilSel + '.xml'

	oFWriter:Close()
	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cArquivo)

	If lEnvMail
		If !ExistDir(cDirSrv)
			MakeDir(cDirSrv)
		EndIf
		__CopyFile(cArquivo, cDirSrv+'RELPADRAOSBZ_' + cFilSel + '.xml')
		__CopyFile(cArquivo, cDirSrv+"SBZ_NESTOQ_LOCALPADRAO_" +cFilSel+".txt")
		If fMailBz(cMailSel,"Arquivo para validação - SBZ PADRAO - " + cFilSel,"",{cDirSrv+'RELPADRAOSBZ_' + cFilSel + '.xml',cDirSrv+"SBZ_NESTOQ_LOCALPADRAO_" +cFilSel+".txt"})
			MsgInfo("Rotina finalizada!" + CRLF + "Os arquivos foram enviados por email e gerados na pasta" + CRLF + cPasta)
		Else
			Alert("Erro ao enviar o email com o conteúdo extraido!" + CRLF + "Os arquivos foram enviados por email e gerados na pasta" + CRLF + cPasta)
		EndIf
	Else
		MsgInfo("Rotina finalizada!" + CRLF + "Os arquivos foram gerados na pasta e o excel será aberto ao clicar em OK" + CRLF + cPasta)

		//Abrindo o excel e abrindo o arquivo xml
		oExcel := MsExcel():New()             //Abre uma nova conexÃ£o com Excel
		oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
		oExcel:SetVisible(.T.)                 //Visualiza a planilha
		oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas
	EndIf


Return



Static Function fMailBz(cPara, cAssunto, cCorpo, aAnexos, lMostraLog, lUsaTLS)
	Local aArea        := GetArea()
	Local nAtual       := 0
	Local lRet         := .T.
	Local oMsg         := Nil
	Local oSrv         := Nil
	Local nRet         := 0
	Local cFrom        := Alltrim(GetMV("MV_RELACNT"))
	Local cUser        := SubStr(cFrom, 1, At('@', cFrom)-1)
	Local cPass        := Alltrim(GetMV("MV_RELPSW"))
	Local cSrvFull     := Alltrim(GetMV("MV_RELSERV"))
	Local cServer      := Iif(':' $ cSrvFull, SubStr(cSrvFull, 1, At(':', cSrvFull)-1), cSrvFull)
	Local nPort        := Iif(':' $ cSrvFull, Val(SubStr(cSrvFull, At(':', cSrvFull)+1, Len(cSrvFull))), 587)
	Local nTimeOut     := GetMV("MV_RELTIME")
	Local cLog         := ""
	Local lSSL 		:= GetNewPar("MV_RELSSL",.F.)	// VERIFICA O USO DE SSL
	Local lTLS 		:= GetNewPar("MV_RELTLS",.F.)	// VERIFICA O USO DE TLS
	Default cPara      := ""
	Default cAssunto   := ""
	Default cCorpo     := ""
	Default aAnexos    := {}
	Default lMostraLog := .T.
	Default lUsaTLS    := .F.

	cCorpo := " <body> "
	cCorpo += " <p>Prezados,</p> "
	cCorpo += " <p>Segue o relatório de produtos não estocáveis com local de estoque PADRAO na SBZ para validação.</p> "
	cCorpo += " <p>O email possui dois anexos, um para ser conferido no excel e o outro no formato TXT para subir via Kit Migração após o retorno da validação.</p> "
	cCorpo += " </body> "

	//Se tiver em branco o destinatário, o assunto ou o corpo do email
	If Empty(cPara) .Or. Empty(cAssunto) .Or. Empty(cCorpo)
		cLog += "001 - Destinatario, Assunto ou Corpo do e-Mail vazio(s)!" + CRLF
		lRet := .F.
	EndIf

	If lRet
		//Cria a nova mensagem
		oMsg := TMailMessage():New()
		oMsg:Clear()

		//Define os atributos da mensagem
		oMsg:cFrom    := cFrom
		oMsg:cTo      := cPara
		oMsg:cSubject := cAssunto
		oMsg:cBody    := cCorpo

		//Percorre os anexos
		For nAtual := 1 To Len(aAnexos)
			//Se o arquivo existir
			If File(aAnexos[nAtual])

				//Anexa o arquivo na mensagem de e-Mail
				nRet := oMsg:AttachFile(aAnexos[nAtual])
				If nRet < 0
					cLog += "002 - Nao foi possivel anexar o arquivo '"+aAnexos[nAtual]+"'!" + CRLF
				EndIf

				//Senao, acrescenta no log
			Else
				cLog += "003 - Arquivo '"+aAnexos[nAtual]+"' nao encontrado!" + CRLF
			EndIf
		Next

		//Cria servidor para disparo do e-Mail
		oSrv := tMailManager():New()

		If lSSL
			oServer:SetUseSSL(lSSL)
		ElseIf lTLS
			oServer:SetUseTLS(lTLS)
		Endif

		//Inicializa conexão
		nRet := oSrv:Init("", cServer, cFrom, cPass, ,nPort)

		//oSrv:Init( "", cSrvFull, cUser, cPass )
		If nRet != 0
			cLog += "004 - Nao foi possivel inicializar o servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
			lRet := .F.
		EndIf

		If lRet
			//Define o time out
			nRet := oSrv:SetSMTPTimeout(nTimeOut)
			If nRet != 0
				cLog += "005 - Nao foi possivel definir o TimeOut '"+cValToChar(nTimeOut)+"'" + CRLF
			EndIf

			//Conecta no servidor
			nRet := oSrv:SMTPConnect()
			If nRet <> 0
				cLog += "006 - Nao foi possivel conectar no servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
				lRet := .F.
			EndIf

			If lRet
				//Realiza a autenticação do usuário e senha
				nRet := oSrv:SmtpAuth(cFrom, cPass)
				If nRet <> 0
					cLog += "007 - Nao foi possivel autenticar no servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
					lRet := .F.
				EndIf

				If lRet
					//Envia a mensagem
					nRet := oMsg:Send(oSrv)
					If nRet <> 0
						cLog += "008 - Nao foi possivel enviar a mensagem: " + oSrv:GetErrorString(nRet) + CRLF
						lRet := .F.
					EndIf
				EndIf

				//Disconecta do servidor
				nRet := oSrv:SMTPDisconnect()
				If nRet <> 0
					cLog += "009 - Nao foi possivel disconectar do servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
				EndIf
			EndIf
		EndIf
	EndIf

	//Se tiver log de avisos/erros
	If !Empty(cLog)
		cLog := "zEnvMail - "+dToC(Date())+ " " + Time() + CRLF + ;
			"Funcao - " + FunName() + CRLF + CRLF +;
			"Existem mensagens de aviso: "+ CRLF +;
			cLog
		ConOut(cLog)

		//Se for para mostrar o log visualmente e for processo com interface com o usuário, mostra uma mensagem na tela
		If lMostraLog .And. ! IsBlind()
			Aviso("Log", cLog, {"Ok"}, 2)
		EndIf
	EndIf

	RestArea(aArea)
Return lRet
