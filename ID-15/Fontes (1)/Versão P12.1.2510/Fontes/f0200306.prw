#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
/*
{Protheus.doc} F0200306()
Inicia a pagina de Treinamento/Evento
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_003
@Return	 cHtml
*/
User Function F0200306()
	
	Local cHtml   	:= ""
	Local oParam  	:= Nil
	Private cMsg
	WEB EXTENDED INIT cHtml START "InSite"
	
	cHtml := ExecInPage("F0200305")
	
	WEB EXTENDED END
Return cHtml
