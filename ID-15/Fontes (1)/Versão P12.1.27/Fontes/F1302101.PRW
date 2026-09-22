#include 'protheus.ch'
#include "APWEBEX.CH"

User Function F1302101(lRet,cCsto,cDsC,nIndDepto)
	
	Local cHtml := ""
	
	Private nPTotal   := 0
	Private cFilPEsc  := ""
	Private cPostoEsc := ""
	Private oSolic
	
	Private nTotalPage := 0
	
	HttpCTType("text/html; charset=ISO-8859-1")
	WEB EXTENDED INIT cHtml START "InSite"
	
		Default lRet := .F.
		Default HttpGet->Page         := "1"
		Default HttpGet->nTotalPage   := "1"
		Default HttpGet->nCurrentPage := 0
		Default HttpGet->cFilDepto    := ""
		Default HttpGet->cCodDepto    := ""
		Default HttpGet->cDescrDepto  := ""
		Default HttpGet->nIndicePosto := ""
		Default HttpSession->Postos   := {}
		
		nCPage:= Val(HttpGet->Page)
		cContinua := HttpGet->cNvDesen
		If cContinua != Nil .AND. Empty(cContinua)
			lRet        := .T.
			cFilDepto   := HttpGet->cFilDepart
			cCodDepto   := HttpGet->cCodDepto
			cDescrDepto := HttpGet->cDescrDepto
			cCsto       := HttpGet->cCcusto
			cDsC        := HttpGet->cDscCC
			nIndDepto   :=  HttpGet->nIndiceDepto
		EndIf
	
		If lRet
			cFilDepto   := IIF(!(EMPTY(cFilDepto)),cFilDepto,"")
			cCodDepto   := IIF(!(EMPTY(cCodDepto)),cCodDepto,"")
			cDescrDepto := IIF(!(EMPTY(cDescrDepto)),cDescrDepto,"")
			cNvDesen    := ""
			cCcusto     := cCsto
			cDscCC      := cDsC
			nIndiceDepto := nIndDepto
		Else
			cFilDepto   := IIF(!(EMPTY(HttpGet->cFilDepto)) .AND. HttpGet->cFilDepto != NIL ,HttpGet->cFilDepto,"")
			cCodDepto   := IIF(!(EMPTY(HttpGet->cCodDepto)) .AND. HttpGet->cCodDepto != NIL ,HttpGet->cCodDepto,"")
			cDescrDepto := IIF(!(EMPTY(HttpGet->cDescrDepto)) .AND. HttpGet->cDescrDepto != NIL,HttpGet->cDescrDepto,"")
			cNvDesen    := "1"
			cCcusto     := ""
			cDscCC      := ""
			nIndiceDepto := ""
		EndIf
			
		cPostFilial := IIF(!(EMPTY(HttpGet->cPostFilial)) .AND. HttpGet->cPostFilial != NIL,HttpGet->cPostFilial,"")
		
		oSolic := WSW1302100():New()
		WsChgURL(@oSolic,"W1302100.apw")
		
		nCurrentPage := IIF(!(EMPTY(HttpGet->nCurrentPage)),VAL(HttpGet->nCurrentPage),1)
			
		cNPosto := IIF(!(EMPTY(HttpGet->cNPost)),HttpGet->cNPost,"")
		cNPosto := IIF (Type("cNPosto") != "U",cNPosto,"")
		cOpc := IIF(!(EMPTY(HttpGet->cOpc)),HttpGet->cOpc,"")
		
		cValor     := IIF(EMPTY(HttpGet->cFiltro),"",HttpGet->cFiltro)
		
		oSolic:NPAGE := nCurrentPage
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
			nPTotal              := oSolic:oWSRETFILIAISRESULT:nPagesTotal
			nPageTotal 		     := oSolic:oWSRETFILIAISRESULT:nPagesTotal
		EndIf
		
		cHtml := ExecInPage( "F1302101" )
			
	WEB EXTENDED END
		
Return cHtml