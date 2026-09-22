#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH" 

/*/{Protheus.doc} F0500305()

@Author     Henrique Madureira
@Since      25/10/2016
@Version    P12.1.07
@Project    MAN0000007423039_EF_003
@Return     cHtml
/*/
User Function F0500305()

	Local cHtml   	:= ""
	
	Private cmsg
	
	HttpCTType("text/html; charset=ISO-8859-1")

	WEB EXTENDED INIT cHtml START "InSite"	           
		cHtml := ExecInPage("F0500305")
	WEB EXTENDED END

Return cHtml