#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

/*/{Protheus.doc} F1302401
Estrutura organizacional portal
@type function
@author henrique.toyada
@since 29/12/2017
@version 1.0
@return ${return}, ${return_description}
@Project    MAN0000007423048_EF_024
/*/
User Function F1302401()
	
	Local cHtml := ""
	Local oWs   := nil
	
	Private cMsg
	
	HttpCTType("text/html; charset=ISO-8859-1")
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	
	cHtml := ExecInPage("F1302401")
	
	WEB EXTENDED END
	
Return cHtml
