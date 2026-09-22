#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH" 

/*
{Protheus.doc} F0100303()
Exibe os postos do departamento selecionado
@Author     Bruno de Oliveira
@Since      07/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Return 	cHtml, página html
*/
User Function F0100303()

	Local cHtml   	:= ""
	Private cMsg
	
	WEB EXTENDED INIT cHtml START "InSite"
	
		HttpCTType("text/html; charset=ISO-8859-1")
		cHtml += ExecInPage( "F0100303" ) 
		
	WEB EXTENDED END
	
Return cHtml