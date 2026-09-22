#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"

User Function F1301202()
	Local cHtml := ""
	
	Private nPTotal   := 1
	Private cValor    := ""
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
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	oSolic := WSW1302100():New()
	WsChgURL(@oSolic,"W1302100.apw")
	nCurrentPage := IIF(!(EMPTY(HttpGet->nCurrentPage)),VAL(HttpGet->nCurrentPage),1)
	
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
	
	oSolic:NPAGE := nCurrentPage
	
	cValor     := IIF(EMPTY(HttpGet->cFiltro),"",HttpGet->cFiltro)
	
	If cValor == "2"
		oSolic:cCampo := IIF(EMPTY(HttpGet->cCampo),"",HttpGet->cCampo)
		oSolic:cFiltro := IIF(EMPTY(HttpGet->cValor),"",HttpGet->cValor)
	Else
		oSolic:cCampo := ""
		oSolic:cFiltro := ""
	EndIf
	
	HttpSession->FILIAIS := {}
	
	If oSolic:RETFILIAIS()
		HttpSession->FILIAIS := oSolic:oWSRETFILIAISRESULT:oWSLISTOFALLFIL:oWSALLFIL
		nPTotal             := oSolic:oWSRETFILIAISRESULT:nPagesTotal
	EndIf
	
	HttpCTType("text/html; charset=ISO-8859-1")
	cHtml := ExecInPage( "F1301202" )
			
	WEB EXTENDED END
		
Return cHtml