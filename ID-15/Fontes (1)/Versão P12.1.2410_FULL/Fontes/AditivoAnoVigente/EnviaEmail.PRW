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

CONNECT SMTP SERVER _MailServer ACCOUNT aEmailConfig[2] PASSWORD aEmailConfig[3] TIMEOUT 200 RESULT lOk
If lOk 
	//Se o servidor SMTP exige autenticacao
	If aEmailConfig[6]
		lAutentica := MailAuth(aEmailConfig[2],aEmailConfig[3])
	Endif
	If lAutentica          
		SEND MAIL FROM aEmailConfig[4] ;
			TO _cMail ;
			CC _cMailCC ;
			SUBJECT cSubject ;
			BODY mMsg ;
			FORMAT TEXT ;
			RESULT lOk
		
		If !lOk                      
			GET MAIL ERROR cErro
			Alert(STR0003 + CRLF + cErro)	 //"Erro no envio da mensagem."
		Endif
	Else
		Alert(STR0004)	 //"Erro no envio da mensagem. Não foi possível autenticar o servidor SMTP"
	Endif
	DISCONNECT SMTP SERVER
Else
	GET MAIL ERROR cErro
	Alert(STR0005 + CRLF + cErro)  //"Erro no envio da mensagem. Não foi possível estabelecer conexão com o servidor :"
Endif

Return
 