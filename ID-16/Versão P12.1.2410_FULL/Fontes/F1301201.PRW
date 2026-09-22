#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH" 

User Function F1301201()

	Local cHtml   	:= ""
		
	Private cMsg

	oInfUsr := WSW0500308():New()
	oInfUsr:_HEADOUT := {} //Thais Paiva - 24273898
	aadd( oInfUsr:_HEADOUT, "Authorization: Basic " + Encode64( cWSUser + ":" + cWSPass ) ) //Thais Paiva - 24273898
	
	WsChgURL(@oInfUsr,"W0500308.apw")

	HttpCTType("text/html; charset=ISO-8859-1")

	WEB EXTENDED INIT cHtml START "InSite"
		
		cAuthWS := SuperGetMV("MV_AUTHWS",.F.,"") //Thais Paiva - 24273898
		
		if !Empty(cAuthWS) //Início Thais Paiva - 24273898
			oInfUsr:_HEADOUT :=  { "Authorization: BASIC "+ ENCODE64(rc4crypt( cAuthWS ,"AuthWS#ReceiptID", .F.,.T.)) }
		endif//Fim Thais Paiva - 24273898
		              
		cHtml := ExecInPage("F1301201")
		
	WEB EXTENDED END

Return cHtml