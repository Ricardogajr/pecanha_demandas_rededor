#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH" 

/*
{Protheus.doc} F0100314()
Chama a página para escolha da solicitação.
@Author     Bruno de Oliveira, Henrique Madureira
@Since      07/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Return 	lRet
*/
User Function F0100314()

	Local cHtml := ""
	
	Private cMsg
	
	WEB EXTENDED INIT cHtml START "InSite"
	
		HttpCTType("text/html; charset=ISO-8859-1")
		cHtml += ExecInPage( "F0100314" )
		 
	WEB EXTENDED END
	
Return cHtml