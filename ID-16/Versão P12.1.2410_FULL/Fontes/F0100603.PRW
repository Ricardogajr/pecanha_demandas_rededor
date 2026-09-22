#Include 'Protheus.ch'
#INCLUDE "APWIZARD.CH"
/*
{Protheus.doc} F0100603()
Envio de e-mail para o responsável da vaga. 
@Author     Bruno de Oliveira
@Since      01/04/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_006
@Param		cEmail, caracter, e-mail que receberá
@Param		cAssunto, caracter, assunto do e-mail
@Param		cConteudo, caracter, conteudo do e-mail
@Param		cCcopia, caracter, Com copia do e-mail
@Param		lJob, lógico, Se é Job(.T.) ou não(.F.)
@Param		cErrJb, caracter, grava os erros do JOB
@Return 	lRet
*/
User Function F0100603(cEmail,cAssunto,cConteudo,cCcopia,lJob,cErrJb)

Local cMailConta	:= SuperGetMV("MV_EMCONTA")
Local cUsuario	:= SubStr(cMailConta,1,At("@",cMailConta)-1)
Local cMailServer	:= AllTrim(SuperGetMv("MV_RELSERV"))
Local cMailSenha	:= SuperGetMV("MV_EMSENHA")
Local nMailPort	:= 0
Local nAt			:= At(":",cMailServer)

Local lMailAuth	:= SuperGetMV("MV_RHAUTEN",,.F.)
Local lUseSSL		:= SuperGetMV("MV_RELSSL",,.F.)
Local lUseTLS		:= SuperGetMV("MV_RELTLS",,.F.)

Local lRet 		:= .T.
Local nErro 		:= 0
Local cMsgErro 	:= ""

Default cErrJb 	:= ""

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
	
nErro := oServer:SMTPConnect()
	
If nErro != 0
	cMsgErro := oServer:GetErrorString(nErro)
	If lJob
		cErrJb := "Falha na conexão com servidor de e-mail" + CHR(13) + cMsgErro
	Else
		Aviso("Atencao","Falha na conexão com servidor de e-mail" + CHR(13) + cMsgErro ,{"Ok"})
	EndIf
	lRet := .F.
EndIf	

If lRet	
	If lMailAuth
		
		//Tentar com conta e senha
		nErro := oServer:SMTPAuth(cMailConta, cMailSenha)
		If nErro != 0
			
			//Tentar com usuário e senha
			nErro := oServer:SMTPAuth(cUsuario, cMailSenha)
			If nErro != 0
				If lJob
					cErrJb := "Falha na conexão com servidor de e-mail" + CHR(13) + oServer:GetErrorString(nErro)
				Else
					Aviso("Atenção","Falha na conexão com servidor de e-mail " + CHR(13) + oServer:GetErrorString(nErro) ,{"Ok"})
				EndIf		
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
	oMessage:cCc			:= cCcopia
	oMessage:cSubject		:= cAssunto
	oMessage:cBody		:= cConteudo
	
	//Envia o e-mail
	nErro := oMessage:Send( oServer )
	
	If !(nErro == 0)
		cMsgErro := oServer:GetErrorString(nErro)
		If lJob
			cErrJb := "Falha no envio do e-mail. Erro retornado: " + CHR(13) + cMsgErro
		Else	
			Aviso("Atenção","Falha no envio do e-mail. Erro retornado: " + CHR(13) + cMsgErro,{"OK"})
		EndIf
		lRet := .F.
	EndIf
	
EndIf
//Desconecta do servidor
oServer:SMTPDisconnect()

Return lRet