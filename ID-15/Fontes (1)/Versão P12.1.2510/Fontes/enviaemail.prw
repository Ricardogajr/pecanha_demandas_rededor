#INCLUDE "EnviaEmail.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "AP5MAIL.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EnviaEmailºAutor  ³Itamar				 º Data ³  15/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Envia e-mail para os destinatarios informados no paramentro º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CDV - Controle de Despesas de viagens						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/    
 
User Function EnviaEmail(aDestinatarios, cSubject, mMsg) 
//Parametros da funcao: Array de Destinatarios, Subject do e-mail e a Mensagem a ser enviada
Local _MailServer
Local nCont 		:= 0
Local nSMTPPort   := 587
Local ni          := 0   
Local cErro			:= ""
Local aEmailConfig:= {} 
Local lOK			:= .F.
Local lAutentica	:= .T.
Local aEmailParam	:= {{"MV_WFSMTP"	,STR0006},;  //"Servidor"
						{"MV_WFACC"		,STR0007},;  //"Conta autenticação"
						{"MV_WFPASSW"	,STR0008},;  //"Senha autenticação"
						{"MV_WFMAIL"	,STR0009},;  //"Conta envio"
						{"MV_WFMAILT"	,STR0010},;  //"Conta padrão"
						{"MV_RELAUTH"	,STR0011}}  //"Serv.SMTP exige autenticação"

ChkTemplate("CDV")
For ni := 1 to Len(aEmailParam)
	aAdd(aEmailConfig,SuperGetMV(aEmailParam[ni][1],.F.,Nil))
	If Empty(aEmailConfig[ni]) .AND. ValType(aEmailConfig[ni]) # "L"
		cErro += "- " + aEmailParam[ni][1] + " (" + OemToAnsi(aEmailParam[ni][2]) + ")" + CRLF
	Else                      
		If ValType(aEmailConfig[ni]) == "C"
			aEmailConfig[ni] := AllTrim(aEmailConfig[ni])
		Endif
	Endif
Next ni
If Len(cErro) > 0
	Alert(STR0002 + CRLF + cErro)  //"Erro no envio da mensagem. Os seguinte(s) parâmetros precisam ser configurados :"
	Return Nil
Endif

_MailServer := aEmailConfig[1]

If Len(aDestinatarios) = 0
	MsgInfo(STR0001) //"Não será possível enviar e-mail. Não há destinatários configurados."
	Return
Else
	_cMail	:= aDestinatarios[1]
	_cMailCC := ""
	For nCont = 2 To Len(aDestinatarios) 
		If nCont == 2
			_cMailCC += AllTrim(aDestinatarios[nCont])
		Else
			_cMailCC += "; " + AllTrim(aDestinatarios[nCont])
		EndIf
	Next
EndIf

// Objeto de Email
				oServer := tMailManager():New()

				


				nErr := oServer:init("",_MailServer,aEmailConfig[2],aEmailConfig[3],,nSMTPPort)
				If nErr <> 0	
					alert("Falha ao conectar:" + oServer:getErrorString(nErr)) // Falha ao conectar: 	
					Return(.F.)
				Endif


				If oServer:SetSMTPTimeout(200) != 0
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
					nErr := oServer:smtpAuth(aEmailConfig[2], aEmailConfig[3])
					If nErr <> 0		
						alert("Falha ao autenticar: " + oServer:getErrorString(nErr)) // Falha ao autenticar: 
						oServer:SMTPDisconnect() 
					EndIf
				EndIf	


				// Cria uma nova mensagem (TMailMessage)
				oMessage := tMailMessage():new()
				oMessage:clear()        


				//	// envia e-mail
				// Dados da mensagem		
				oMessage:cFrom		:= aEmailConfig[4] 
				oMessage:cBCC     	:=  _cMailCC 
				oMessage:cTo     	:=  _cMail
				oMessage:cSubject	:=cSubject
				oMessage:cBody   	:= mMsg

oServer:SMTPDisconnect() 



Return
 