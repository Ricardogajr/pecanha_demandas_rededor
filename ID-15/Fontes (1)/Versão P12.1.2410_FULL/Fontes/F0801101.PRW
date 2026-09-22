#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
/*
{Protheus.doc} F0801101()
Inicia a pagina de férias
@Author     Henrique Madureira
@Since		 27/03/2017
@Version    P12.7
@Project    MAN0000007423042_EF_011
@Return	 cHtml
*/
User Function F0801101()
	
	Local cHtml   	:= ""
	Local oParam  	:= Nil
	
	Private cMsg
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	cHtml := ExecInPage("F0801101")
	
	WEB EXTENDED END
	
Return cHtml
