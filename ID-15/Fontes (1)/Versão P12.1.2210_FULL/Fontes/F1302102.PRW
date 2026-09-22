#include 'protheus.ch'
#include "APWEBEX.CH"

User Function F1302102()
	Local cHtml := ""
	Local cValor := ""
	
	Private nPTotal := 0
	Private cFilPEsc  := ""
	Private cPostoEsc := ""
	Private cFilRepor := ""
	Private cDescRepor := ""
	Private oSolic
	
	Default HttpGet->Page         := ""
	Default HttpGet->nTotalPage   := ""
	Default HttpGet->nCurrentPage := 0
	
	cCodDepto := HttpGet->cCodDepto
	cDescrDepto := HttpGet->cDescrDepto
	cFilDepart   := HttpGet->cFilDepart
	cPostFilial := HttpGet->cPostFilial
	cNvDesen := HttpGet->cNvDesen
	nIndiceDepto   :=  HttpGet->nIndiceDepto
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	oSolic := WSW1302100():New()
	WsChgURL(@oSolic,"W1302100.apw")
	fGetInfRotina("U_F0100312.APW")// lembrar de trocar pelo nome do menu principal
	nCurrentPage        := IIF(!(EMPTY(HttpGet->nCurrentPage)),VAL(HttpGet->nCurrentPage),1)
	cNPosto := HttpGet->cNPost
	cOpc := HttpGet->cOpc
	
	cValor     := IIF(EMPTY(HttpGet->cFiltro),"",HttpGet->cFiltro)
	cFilRepor  := IIF(EMPTY(HttpGet->cFilRepor),"",HttpGet->cFilRepor)
	cDescRepor := IIF(EMPTY(HttpGet->cDescRepor),"",HttpGet->cDescRepor)
	
	oSolic:cFilRepor := IIF(EMPTY(HttpGet->cFilRepor),"",HttpGet->cFilRepor)
	oSolic:NPAGE := nCurrentPage

	oSolic:cCampo := IIF(EMPTY(HttpGet->cCampo),"",HttpGet->cCampo)
	oSolic:cFiltro := IIF(EMPTY(HttpGet->cValor),"",HttpGet->cValor)
	oSolic:cOcupados := "S"

	cCcusto := IIF(EMPTY(HttpGet->cCcusto),"",HttpGet->cCcusto)
	cDscCC := IIF(EMPTY(HttpGet->cDscCC),"",HttpGet->cDscCC)

	HttpSession->departamentos := {}
	
	If oSolic:RetDepartamentos()
		HttpSession->departamentos := oSolic:oWSRetDepartamentosRESULT:oWSLISTOFalldepart:oWSalldepart
		nPTotal                    := oSolic:oWSRetDepartamentosRESULT:nPagesTotal
	EndIf
	
	HttpCTType("text/html; charset=ISO-8859-1")
	cHtml := ExecInPage( "F1302102" )
			
	WEB EXTENDED END
		
Return cHtml