#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"

/*/{Protheus.doc} F1302403
Estrutura organizacional portal
@type function
@author henrique.toyada
@since 29/12/2017
@version 1.0
@return ${return}, ${return_description}
@Project    MAN0000007423048_EF_024
/*/
User Function F1302403()
	Local cHtml := ""
	
	Private cMsg
	Private oLista
	Private oWs
	Private lRet := .F.
	
	HttpCTType("text/html; charset=ISO-8859-1")
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	cMatricu := HTTPSession->RHMat
	cNome    := HttpSession->Login
	cFilMat  := HttpSession->aUser[2]
	
	cFilPosto := IIF(EMPTY(HttpGet->cFilPosto), "", HttpGet->cFilPosto)
	cCodPosto := IIF(EMPTY(HttpGet->cCodPosto), "", HttpGet->cCodPosto)
	cDado     := IIF(EMPTY(HttpGet->cDado)    , "", HttpGet->cDado)
	cCampo    := IIF(EMPTY(HttpGet->cCampo)   , "", HttpGet->cCampo)
	cLista    := IIF(EMPTY(HttpGet->cLista)   , "", HttpGet->cLista)
	
	oWs := WSW1302400():new()
	WsChgURL(@oWs,"W1302400.APW")
	
	If oWs:BuscaRCX(cFilPosto, cCodPosto, cCampo, cDado)
		If !Empty(OWS:oWSBUSCARCXRESULT:OWSREGISTRO_FUNC:OWSESTRUTURA_FUNC[1]:cFilialMat)
			oLista := OWS:oWSBUSCARCXRESULT:OWSREGISTRO_FUNC:OWSESTRUTURA_FUNC
		EndIf
	EndIf
	cHtml := ExecInPage("F1302403")
	
	WEB EXTENDED END
Return cHtml
