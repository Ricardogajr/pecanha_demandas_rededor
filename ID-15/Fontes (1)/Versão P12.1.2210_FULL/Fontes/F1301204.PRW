#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"

User Function F1301204()
	
	Local cHtml := ""
	
	Private nPTotal   := 1
	Private cFilPEsc  := ""
	Private cPostoEsc := ""
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
	
	nCurrentPage := IIF(!(EMPTY(HttpGet->nCurrentPage)),VAL(HttpGet->nCurrentPage),1)	
	
	oSolic := WSW1302100():New()
	WsChgURL(@oSolic,"W1302100.apw")
	
	oSolic:NPAGE := nCurrentPage
	oSolic:cCampo := IIF(EMPTY(HttpGet->cCampo),"",HttpGet->cCampo)
	oSolic:cFiltro := IIF(EMPTY(HttpGet->cValor),"",HttpGet->cValor)
	
	HttpSession->FUNCAO := {}
	
	If oSolic:RETFUNCRG()
		HttpSession->FUNCAO := oSolic:oWSRETFUNCRGRESULT:oWSListOfallfuncao:oWSallfuncao
		nPTotal             := oSolic:oWSRETFUNCRGRESULT:nPagesTotal
	EndIf
	
	If oSolic:AllCntrCusto(cFilSol, cDeptSol)
		cCcusto := oSolic:oWSAllCntrCustoRESULT:cCodCC
		cDscCC := oSolic:oWSAllCntrCustoRESULT:cDescC
	Else
		cCcusto := ""
		cDscCC := ""
	EndIf
	
	HttpCTType("text/html; charset=ISO-8859-1")
	cHtml := ExecInPage( "F1301205" )
			
	WEB EXTENDED END
		
Return cHtml