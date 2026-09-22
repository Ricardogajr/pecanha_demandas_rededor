#include 'protheus.ch'
#include "APWEBEX.CH"

User Function F1301203()
	Local cHtml := ""
	Local cValor := ""
	
	Private nPTotal := 1
	Private cFilPEsc  := ""
	Private cPostoEsc := ""
	Private cFilRepor := ""
	Private cDescRepor := ""
	Private oSolic
	
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
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	oSolic := WSW1302100():New()
	WsChgURL(@oSolic,"W1302100.apw")
	fGetInfRotina("U_F0100312.APW")// lembrar de trocar pelo nome do menu principal
	nCurrentPage        := IIF(!(EMPTY(HttpGet->nCurrentPage)),VAL(HttpGet->nCurrentPage),1)
	
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
	
	oSolic:cFilRepor := IIF(EMPTY(HttpGet->cFilRepor),"",HttpGet->cFilRepor)
	oSolic:NPAGE := nCurrentPage
	
	oSolic:cCampo := IIF(EMPTY(HttpGet->cCampo),"",HttpGet->cCampo)
	oSolic:cFiltro := IIF(EMPTY(HttpGet->cValor),"",HttpGet->cValor)
	oSolic:cOcupados := "N"

	HttpSession->departamentos := {}
	
	If oSolic:RetDepartamentos()
		HttpSession->departamentos := oSolic:oWSRetDepartamentosRESULT:oWSLISTOFalldepart:oWSalldepart
		nPTotal                    := oSolic:oWSRetDepartamentosRESULT:nPagesTotal
	EndIf
	
	HttpCTType("text/html; charset=ISO-8859-1")
	cHtml := ExecInPage( "F1301203" )
			
	WEB EXTENDED END
		
Return cHtml