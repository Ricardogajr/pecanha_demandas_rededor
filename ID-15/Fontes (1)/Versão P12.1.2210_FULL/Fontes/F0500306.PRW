#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

/*/{Protheus.doc} F0500306()
Monta a tela de listagem das solicitações
@Author     Henrique Madureira
@Since      25/10/2016
@Version    P12.1.07
@Project    MAN0000007423039_EF_003
@Return     cHtml
/*/

User Function F0500306()
	
	Local cHtml      := ""
	Local cMat       := ""
	Local cNome      := ""
	Local oObj       := Nil
	Local oParam     := Nil
	
	Private oLista2  := Nil
	
	Private cMsg
	WEB EXTENDED INIT cHtml START "InSite"
		
		cMat    := HTTPSession->RHMat
		cNome   := HttpSession->Login
		cFilFun := HttpSession->aUser[2]
		cFiltro := IIF(EMPTY(HttpGet->cFiltro),"1","2")
		cCampo  := IIF(EMPTY(HttpGet->cCampo),"",HttpGet->cCampo)
		cValor  := IIF(EMPTY(HttpGet->cValor),"",HttpGet->cValor)
		
		HttpCTType("text/html; charset=ISO-8859-1")
		
		oParam := WSW0500307():new()
		WsChgURL(@oParam,"W0500307.APW")
		If oParam:INFRH3(cMat,cFiltro,cCampo,cValor,cFilFun)
			oLista2 :=  oParam:oWSINFRH3RESULT
		EndIf
		
		cHtml := ExecInPage("F0500306")
		
	WEB EXTENDED END
	
Return cHtml
