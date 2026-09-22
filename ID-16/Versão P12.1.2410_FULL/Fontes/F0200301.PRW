#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
/*
{Protheus.doc} F0200301()
Inicia a pagina de incentivo
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_003
@Return	 cHtml
*/
User Function F0200301()
	
	Local cHtml   	:= ""
	Local oParam  	:= Nil
	
	Private cMsg
	WEB EXTENDED INIT cHtml START "InSite"
	cHtml := ExecInPage("F0200301")
	WEB EXTENDED END
Return cHtml

