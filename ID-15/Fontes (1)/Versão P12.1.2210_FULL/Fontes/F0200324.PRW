#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

/*
{Protheus.doc} F0200324()
Página inicial do acompanhamento
@Author     Bruno de Oliveira
@Since      07/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Return 	 cHtml, página em html
*/
User Function F0200324()
	
	Local cHtml := ""
	Local oWs   := nil
	
	Private cMsg
	
	HttpCTType("text/html; charset=ISO-8859-1")
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	
	cHtml := ExecInPage("F0200324")
	
	WEB EXTENDED END
	
Return cHtml
