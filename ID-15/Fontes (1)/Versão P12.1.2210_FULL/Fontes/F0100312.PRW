#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH" 

/*
{Protheus.doc} F0100312()
Chama página inicial da solicitação do aumento de quadro\orçamento
@Author     Bruno de Oliveira
@Since      07/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Return 	cHtml, página html
*/
User Function F0100312()

	Local cHtml   	:= ""
		
	Private cMsg


	oInfUsr := WSW0500308():New()
	WsChgURL(@oInfUsr,"W0500308.apw")

	HttpCTType("text/html; charset=ISO-8859-1")

	WEB EXTENDED INIT cHtml START "InSite"
		              
		cHtml := ExecInPage("F0100312")
		
	WEB EXTENDED END

Return cHtml