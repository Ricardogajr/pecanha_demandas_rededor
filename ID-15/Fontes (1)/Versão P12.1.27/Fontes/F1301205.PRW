#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"

User Function F1301205()
	
	Local cHtml := ""
	
	Private cFilPEsc  := ""
	Private cPostoEsc := ""
	
	Default HttpGet->cCcusto      := ""
	Default HttpGet->cDscCC       := "1"
	Default HttpGet->nOperacao    := "1"
	Default HttpGet->nIndDept     := ""
	Default HttpGet->nIndicePosto := ""
	Default HttpGet->cNPost       := ""
	Default HttpGet->cOpc         := ""
	Default HttpGet->cCodDepto    := ""
	Default HttpGet->cDescrDepto  := ""
	Default HttpGet->cPostFilial  := ""
	Default HttpGet->cPostRepor   := ""
	Default HttpGet->cDesDpRepor  := ""
	Default HttpGet->cDepRepor    := ""
	Default HttpGet->cDescRepor   := ""
	Default HttpGet->cFilRepor    := ""
	Default HttpGet->cFilSol      := ""
	Default HttpGet->cDescSol     := ""
	Default HttpGet->cDeptSol     := ""
	Default HttpGet->cDescDeptSol := ""
	
	WEB EXTENDED INIT cHtml START "InSite"

	cCcusto      := HttpGet->cCcusto
	cDscCC       := HttpGet->cDscCC
	nOperacao    := HttpGet->nOperacao
	nIndDept     := HttpGet->nIndDept
	nIndicePosto := HttpGet->nIndicePosto
	cNPost       := HttpGet->cNPost
	cOpc         := HttpGet->cOpc
	cCodDepto    := HttpGet->cCodDepto
	cDescrDepto  := HttpGet->cDescrDepto
	cPostFilial  := HttpGet->cPostFilial
	cPostRepor   := HttpGet->cPostRepor
	cDesDpRepor  := HttpGet->cDesDpRepor
	cDepRepor    := HttpGet->cDepRepor
	cDescRepor   := HttpGet->cDescRepor
	cFilRepor    := HttpGet->cFilRepor
	cFilSol      := HttpGet->cFilSol
	cDescSol     := HttpGet->cDescSol
	cDeptSol     := HttpGet->cDeptSol
	cDescDeptSol := HttpGet->cDescDeptSol
	cCodFunc     := HttpGet->cCodFunc
	cDescFunc    := HttpGet->cDescFunc
	
	oSolic := WSW1302100():New()
	WsChgURL(@oSolic,"W1302100.apw")
	
	HttpCTType("text/html; charset=ISO-8859-1")
	cHtml := ExecInPage( "F1301204" )
			
	WEB EXTENDED END
		
Return cHtml