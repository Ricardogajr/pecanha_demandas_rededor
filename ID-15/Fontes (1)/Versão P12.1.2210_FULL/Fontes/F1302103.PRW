#Include 'Protheus.ch'
#include "APWEBEX.CH"

User Function F1302103()

	Local cHtml   := ""
	Local nCnt    := 0
	Local nTotal  := 0
	Local oOrg
	
	Private cMsg       := ""
	Private cFilPEsc   := ""
	Private cPostoEsc  := ""
	Private nPTotal    := 0
	Private nTotalPage := 0
	Private cFilDepto      := ""
	Private cCodDepto      := ""
	Private cDescrDepto    := ""
	Private cFilPostoVis   := ""
	Private cPostoVis      := ""
	Private cDepartmentEmp := ""
	
	Default HttpGet->nIndDept     := ""
	Default HttpGet->Page         := ""
	Default HttpGet->nIndiceDepto := ""
	Default HttpGet->nTotalPage   := ""
	Default HttpGet->nCurrentPage := 0
	Default HttpSession->Postos   := {}
	Default HttpSession->departamentos := {}
	 	
	cOpc         := HttpGet->cOpc
	cNPost       := HttpGet->cNPost
	nCPage       := Val(HttpGet->Page)
	nIndDept := Val(HttpGet->nIndDept)
	
	cCodDepto   := HttpGet->cCodDepto
	cDescrDepto := HttpGet->cDescrDepto
	cPostFilial := HttpGet->cPostFilial
	cfildepart  := HttpGet->cfildepart
	cNvDesen    := HttpGet->cNvDesen
	nIndiceDepto   :=  HttpGet->nIndiceDepto
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	HttpCTType("text/html; charset=ISO-8859-1")
	
	oOrg := WSORGSTRUCTURE():New()
	WsChgURL(@oOrg, "ORGSTRUCTURE.APW",,,HttpSession->cEDepto)
		
	nCurrentPage := IIF(!(EMPTY(HttpGet->nCurrentPage)),VAL(HttpGet->nCurrentPage),1)
	
	cFilRepor   := IIF(EMPTY(HttpGet->cFilRepor),"",HttpGet->cFilRepor)
	cDescRepor  := IIF(EMPTY(HttpGet->cDescRepor),"",HttpGet->cDescRepor)
	cDepRepor   := IIF(EMPTY(HttpGet->cDepRepor),"",HttpGet->cDepRepor)
	cDesDpRepor := IIF(EMPTY(HttpGet->cDesDpRepor),"",HttpGet->cDesDpRepor)
	oSolic := WSW1302100():New()
	WsChgURL(@oSolic,"W1302100.apw")
	
	oSolic:cDepartmentID   := cDepRepor
	oSolic:cFilterField    := IIF(EMPTY(HttpGet->cCampo),"",HttpGet->cCampo)
	oSolic:cFilterValue    := IIF(EMPTY(HttpGet->cValor),"",HttpGet->cValor)
	oSolic:nPage           := nCurrentPage
	oSolic:cEmployeeFil    := cFilRepor
	HttpSession->DadosFunc := WsClassNew('ORGSTRUCTURE_DATAEMPLOYEE')
	HttpSession->DadosFunc:CEMPLOYEEEMP := cDepartmentEmp
	HttpSession->Postos := {}
	
	If oSolic:RetPostos()
		HttpSession->Postos := oSolic:oWSRetPostosRESULT:oWSLISTOFallPOSToS:oWSALLPOSTOS
		nPTotal             := oSolic:oWSRetPostosRESULT:nPagesTotal
	EndIf
	
	nTotal := 0
	
	For nCnt:= 1 to Len(HttpSession->Postos)
		If oSolic:AllBuscDepto(cCodDepto,HttpSession->Postos[nCnt]:cPostFilial,HttpSession->Postos[nCnt]:cPOSTO)
			nTotal := oSolic:nAllBUSCDEPTORESULT
		EndIf
		HttpSession->Postos[nCnt]:nOcupado := HttpSession->Postos[nCnt]:nOcupado + nTotal
	Next
	
	cCcusto := IIF(EMPTY(HttpGet->cCcusto),"",HttpGet->cCcusto)
	cDscCC := IIF(EMPTY(HttpGet->cDscCC),"",HttpGet->cDscCC)
	
	cHtml += ExecInPage( "F1302103" )
	
	WEB EXTENDED END
	
Return cHtml