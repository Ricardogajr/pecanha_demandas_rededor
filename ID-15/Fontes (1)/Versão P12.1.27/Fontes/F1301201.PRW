#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH" 

User Function F1301201()

	Local cHtml   	:= ""
		
	Private cMsg

	oInfUsr := WSW0500308():New()
	WsChgURL(@oInfUsr,"W0500308.apw")

	HttpCTType("text/html; charset=ISO-8859-1")

	WEB EXTENDED INIT cHtml START "InSite"
		              
		cHtml := ExecInPage("F1301201")
		
	WEB EXTENDED END

Return cHtml