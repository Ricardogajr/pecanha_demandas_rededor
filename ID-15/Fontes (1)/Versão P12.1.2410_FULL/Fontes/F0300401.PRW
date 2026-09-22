#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH" 
/*
{Protheus.doc} F0300401()
Tela inicial do Plano de Desenvolvimento em Equipe
@Author     Henrique Madureira
@Since      
@Version    P12.7
@Project    MAN00000463701_EF_004
@Return	 cHtml
*/
User Function F0300401()

	Local cHtml    := ""
	
	Private cMsg
	
	WEB EXTENDED INIT cHtml START "InSite"	      
		
	cHtml := ExecInPage("F0300401")
		
	WEB EXTENDED END
Return cHtml  