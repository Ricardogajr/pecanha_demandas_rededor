#Include 'Protheus.ch'
/*
{Protheus.doc} F0200304()
Envia email
@Author     Henrique Madureira
@Since      20/05/2016
@Version    P12.7
@Project    MAN00000463301_EF_003
@Param		 cAssunto
@Param		 cBody
@Param		 cEmail
@Return
*/
User Function F0200304(cAssunto, cBody, cEmail)
	Local cMailConta	:= SuperGetMV("MV_RELAUSR")
	Local cUsuario	:= SubStr(cMailConta,1,At("@",cMailConta)-1)
	Local cMailServer	:= AllTrim(SuperGetMv("MV_RELSERV"))
	Local cMailSenha	:= SuperGetMV("MV_RELAPSW")
	Local nMailPort	:= 0
	Local nAt			:= At(":",cMailServer)
	
	Local lMailAuth	:= SuperGetMV("MV_RHAUTEN",,.F.)
	Local lUseSSL		:= SuperGetMV("MV_RELSSL",,.F.)
	Local lUseTLS		:= SuperGetMV("MV_RELTLS",,.F.)
	
	Local lRet 		:= .T.
	
	oServer	:= TMailManager():New()
	oServer:SetUseSSL(lUseSSL)
	oServer:SetUseTLS(lUseTLS)
	
	// Tratamento para usar a porta quando informada no mailserver
	If nAt > 0
		nMailPort	:= VAL(SUBSTR(ALLTRIM(cMailServer),At(":",cMailServer) + 1,Len(ALLTRIM(cMailServer)) - nAt))
		cMailServer	:= SUBSTR(ALLTRIM(cMailServer),1,At(":",cMailServer)-1)
		oServer:Init("", cMailServer, cMailConta, cMailSenha,0,nMailPort)
	Else
		oServer:Init("", cMailServer, cMailConta, cMailSenha,0,nMailPort)
	EndIf
	
	If oServer:SMTPConnect() != 0
		lRet := .F.
	EndIf
	
	If lRet
		If lMailAuth
			
			//Tentar com conta e senha
			If oServer:SMTPAuth(cMailConta, cMailSenha) != 0
				
				//Tentar com usuário e senha
				If oServer:SMTPAuth(cUsuario, cMailSenha) != 0
					lRet := .F.
				EndIf
				
			EndIf
			
		EndIf
	EndIf
	
	If lRet
		
		oMessage				:= TMailMessage():New()
		
		oMessage:Clear()
		oMessage:cFrom		:= cMailConta
		oMessage:cTo			:= cEmail
		oMessage:cCc			:= ""
		oMessage:cSubject		:= cAssunto
		oMessage:cBody		:= cBody
		
		//Envia o e-mail
		
		If !(oMessage:Send( oServer ) == 0)
			lRet := .F.
		EndIf
		
	EndIf
	//Desconecta do servidor
	oServer:SMTPDisconnect()
	
Return lRet
