#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"
/*
{Protheus.doc} F0200325()
Página inicial do acompanhamento
@Author     Bruno de Oliveira
@Since      07/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Return 	 cHtml, página em html
*/
User Function F0200325()
	Local cHtml := ""
	
	Private cMsg
	Private oLista
	Private oStatu
	Private lRet := .F.
	Private nPTotal   := 0
	Private nTotalPage := 0
	
	HttpCTType("text/html; charset=ISO-8859-1")
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	Default HttpGet->Page         := "1"
	Default HttpGet->nTotalPage   := "1"
	Default HttpGet->nCurrentPage := 0
	
	nCPage:= Val(HttpGet->Page)
	
	cMatricu := HTTPSession->RHMat
	cNome    := HttpSession->Login
	cFilMat  := HttpSession->aUser[2]
	
	cDtIni   := IIF(EMPTY(HttpGet->dAbertura), "", SUBSTR(HttpGet->dAbertura,7,4) + SUBSTR(HttpGet->dAbertura,4,2) + SUBSTR(HttpGet->dAbertura,0,2))
	cDtFim   := IIF(EMPTY(HttpGet->dFech), "", SUBSTR(HttpGet->dFech,7,4) + SUBSTR(HttpGet->dFech,4,2) + SUBSTR(HttpGet->dFech,0,2))
	cMat     := IIF(EMPTY(HttpGet->cMat), "", HttpGet->cMat)
	cStatus  := IIF(EMPTY(HttpGet->cStatus), "", HttpGet->cStatus)
	cServico := IIF(EMPTY(HttpGet->cServico), "", HttpGet->cServico)
	cCodigo  := IIF(EMPTY(HttpGet->cCodigo), "", HttpGet->cCodigo)
	
	oWs := WSW0200302():new()
	WsChgURL(@oWs,"W0200302.APW")
	
	nCurrentPage := IIF(!(EMPTY(HttpGet->nCurrentPage)),VAL(HttpGet->nCurrentPage),1)
	
	If oWs:BuscaMat(cMatricu, cFilMat)
		lRet := oWs:lBuscaMatRESULT
	EndIf
	
	oWs:NPAGE := nCurrentPage
	
	HttpSession->BuscaRH3 := {}

	If oWs:BuscaRH3(cFilMat, cMatricu,cDtIni, cDtFim, cMat, cStatus, cServico, cCodigo)
		HttpSession->BuscaRH3 := OWS:OWSBUSCARH3RESULT:OWSREGISTRO:OWSACOMPANHA
		nPTotal := OWS:OWSBUSCARH3RESULT:nPagesTotal //Thais Paiva - 165987008
		nPageTotal := OWS:OWSBUSCARH3RESULT:nPagesTotal //Thais Paiva - 165987008
	EndIf
	cHtml := ExecInPage("F0200325")
	
	WEB EXTENDED END
Return cHtml