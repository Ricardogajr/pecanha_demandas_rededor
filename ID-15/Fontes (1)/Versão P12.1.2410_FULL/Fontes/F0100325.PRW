#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"

/*{Protheus.doc} F0100325

@Author     Bruno de Oliveira
@Since      07/11/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@return cHtml, Retorna página
*/
User Function F0100325()

Local cHtml := ""

	WEB EXTENDED INIT cHtml START "InSite"

		cFilSol  := httpGet->cFilil
		cCodSol  := HttpGet->cSolic
		cLugar   := HttpPost->cLugar
		
		cHtml := ExecInPage("F0100325")
	
	WEB EXTENDED END

Return cHtml