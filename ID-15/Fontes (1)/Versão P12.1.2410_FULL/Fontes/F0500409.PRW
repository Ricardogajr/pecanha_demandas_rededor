#Include 'Protheus.ch'
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F0500409
(long_description)
@type function
@author Cris
@since 23/11/2016
@version 1.0
@param cFilSol, character, (Filial da Solicitação)
@param cMatFun, character, (Matricula do funcionário)
@param cNumSol, character, (Numero da Solicitação)
@param cVisaoAtu, character, (Código do Visão)
@param cOpc, character, (opção de mensagem)
@return ${lEnvEmail}, ${.T. email enviado com sucesso .F. não enviado}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function F0500409(cFilSol,cMatFun,cNumSol,cVisaoAtu,cOpc)

	Local aResp     := {}
	Local iResp     := 0
	Local cEmails	  := ''
	Local cTpMov    := ''
	Local cNomFun   := ''
	Local cDtEfet   := ''
	Local cBody     := ''
	Local cAssunto  := ''
	Local lEnvEmail := .T.
		
		//Retorna todos os emails de todos os aprovadores responsáveis
		U_F0500405(cVisaoAtu,,,,.T.,@aResp)
	
		For iResp := 1 to len(aResp)
		
			if !Empty(cEmails) 
				
				cEmails	:= cEmails + ';'
			
			EndIf
			
			if !Alltrim(aResp[iResp][3]) $ cEmails
				
				cEmails	+= Alltrim(aResp[iResp][3])
				
			EndIf
			
		Next iResp
	
		cTpMov  := IIF(EMPTY(POSICIONE("PAA",3,cFilSol + cNumSol, "PAA_DESSUB")),"",POSICIONE("PAA",3,cFilSol + cNumSol, "PAA_DESSUB"))
		cNomFun := IIF(EMPTY(POSICIONE("SRA",1,cFilSol + cMatFun, "RA_NOME")   ),"",POSICIONE("SRA",1,cFilSol + cMatFun, "RA_NOME")   )
		cDtEfet := IIF(EMPTY(POSICIONE("RH3",1,cFilSol + cNumSol, "RH3_DTATEN")),"",POSICIONE("RH3",1,cFilSol + cNumSol, "RH3_DTATEN"))
		
		if cOpc == '1'
			
			cAssunto := "Efetivação da Solicitação de Movimentações de Pessoal"
			
			cBody := '<html><body><pre>' + CRLF
			cBody += '<b>Prezado,</b>' + CRLF
			cBody += "A solicitação abaixo foi EFETIVADA pelo departamento RH com SUCESSO." + CRLF
			cBody += "Filial: " + cFilSol + CRLF
			cBody += "Número da Solicitação: " + cNumSol + CRLF
			cBody += "Matrícula: " + cMatFun + CRLF
			cBody += "Nome: " + cNomFun + CRLF
			cBody += "Tipo da Movimentação: " + cTpMov + CRLF
			cBody += "Data da Efetivação: " + cDtEfet + CRLF
			cBody += '</pre></body></html>'

		Elseif  cOpc == '2'
			
			cAssunto := "Negada Efetivação da Solicitação"
				
			cBody := '<html><body><pre>' + CRLF
			cBody += '<b>Prezado,</b>' + CRLF
			cBody += "CANCELADA a solicitação abaixo pelo departamento RH." + CRLF
			cBody += "Número da Solicitação: " + cNumSol + CRLF
			cBody += "Matrícula: " + cMatFun + CRLF
			cBody += '</pre></body></html>'
		
		EndIf
		
		FWMsgRun(,{|| lEnvEmail	:= U_F0200304(cAssunto, cBody, cEmails)},"Aguarde...","Estabelecendo conexão com o serviço de e-mail." ) 
		//FWMsgRun(,{|| lEnvEmail:= EnvEmail("",cAssunto,cBody,cEmails,"")},"Aguarde...","Estabelecendo conexão com o serviço de e-mail." )
		
		if lEnvEmail
			
			Aviso("SUCESSO - Email","E-mail enviado com sucesso!" ,{'OK'},1)

		Else
		
			Aviso("INSUCESSO - Email","E-mail NÃO enviado. Comunique aos envolvidos!" ,{'OK'},1)
							
		EndIf

Return lEnvEmail
//--------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ${EnvEmail}
(Envia e-mail)
@type function
@author Cris
@since 09/11/2016
@param cArquivo, character, (nome do arquivo a ser anexado)
@param cSubject, character, (Titulo do e-mail)
@param cBody, character, (Corpo do e-mail)
@param cTo, character, (endereço de Destino do e-mail)
@param cCC, character, (endereço copia de destino)
@version P12.1.7
@Project MAN0000007423039_EF_004
@return ${return}, ${não há}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function EnvEmail(cArquivo,cSubject,cBody,cTo,cCC)

	Local cServer	:= AllTrim(GetMv("MV_RELSERV"))
	Local cFrom		:= AllTrim(GetMv("MV_RELACNT")) 
	Local lAutentica:= GetMv("MV_RELAUTH") 
	Local cUserAut	:= Alltrim(GetMv("MV_RELAUSR"))
	Local cPassAut	:= Alltrim(GetMv("MV_RELAPSW"))
	
	Default cArquivo := ""
	Default cSubject := ""
	Default cBody    := ""
	Default cTo      := ""
	Default cCC      := ""
	
	If Empty(cServer)
		conout("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
		Return .F.
	EndIF
	
	IF Empty(cFrom)
		conout("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
		Return .F.
	EndIf

	cTo := AvLeGrupoEMail(cTo)
	cCC := AvLeGrupoEMail(cCC)
	
	lOK	:= MailSmtpOn( cServer, cFrom, cPassAut, 60 )
	
	If !lOK
		
		conout("Falha na Conexão com Servidor de E-Mail")
		Aviso('Email não enviado',"Falha na Conexão com Servidor de E-Mail. ",{'OK'},3)
		
	Else
	
		If lAutentica
			If !MailAuth(cUserAut,cPassAut)
				Aviso('Email não enviado',"Falha na Autenticação do Usuário. ",{'OK'},3)
				conout("Falha na Autenticacao do Usuario")
				lOk	:=	MailSmtpOff()
			EndIf
		EndIf
		
		If !Empty(cCC)
			lOK:=MailSend( cFrom, { cTo }, { cCC }, { }, cSubject, cBody, { cArquivo },.F. )
		Else
			lOK:=MailSend( cFrom, { cTo }, { }, { }, cSubject, cBody, { cArquivo },.F. )
		EndIF                                  
		If !lOK
			if !IsBlind() 
				///Aviso('Email não enviado',"Falha no Envio do E-Mail: " + ALLTRIM(cTo),{'OK'},3)
			Else
				conout("Falha no Envio do E-Mail: " + ALLTRIM(cTo)) 
			EndIF
		Else
			if  !IsBlind()                                                                      
				//Aviso("Envio de Email",'E-mail enviado com sucesso.', {'OK'},3)
			EndIf
		EndIF
	ENDIF
	
	MailSmtpOff()

RETURN lOK  
