#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"

/*
{Protheus.doc} F0100304()
Validação da disponibilidade de postos e orçamento.
@Author     Bruno de Oliveira
@Since      07/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Return 	cHtml, página html
*/
User Function F0100304()

	Local nIndiceDepto := Val(HttpGet->nIndiceDepto)
	Local lFsUsaPco    := .F.
	Local cHtml        := ""
	Local nCnt         := 0
	Local nTotal       := 0
	Local oOrg
	
	Private nPTotal    := 0 
	Private nTotalPage := 0 
	
	Private cMsg       := ""
	
	HttpCTType("text/html; charset=ISO-8859-1")
	WEB EXTENDED INIT cHtml START "InSite"                     
	
	 	Default HttpSession->Postos   := {}
		Default HttpGet->FilterField  := ""
		Default HttpGet->FilterValue  := ""
	 	Default HttpGet->Page         := "1"
	 	Default HttpGet->nIndiceDepto := '1'
	 	Default HttpGet->nCurrentPage := 0
	 	Default HttpGet->nTotalPage   := '1'
	 	
	 	nCPage:= Val(HttpGet->Page)
	 		 	
		oOrg := WSORGSTRUCTURE():New()
		WsChgURL(@oOrg, "ORGSTRUCTURE.APW",,,HttpSession->Department[nIndiceDepto]:cDepartmentEmp)
		
		nCurrentPage        := IIF(!(EMPTY(HttpGet->nCurrentPage)),VAL(HttpGet->nCurrentPage),1)
		
		oSolic := WSW0500308():New()
		WsChgURL(@oSolic,"W0500308.apw")
			                    
		//LISTA DE POSTOS	                
		oSolic:cCompanyID        := HttpSession->AMATS[1]:CEMPLOYEEEMP//HttpSession->Department[nIndiceDepto]:cDepartmentEmp
		oSolic:cDepartmentID     := HttpSession->Department[nIndiceDepto]:cDepartment
		oSolic:cFilterField      := HttpGet->FilterField
		oSolic:cFilterValue      := HttpGet->FilterValue
		oSolic:nPage             := nCurrentPage
		oSolic:cRequestType      := HttpSession->cTypeRequest
		oSolic:cEmployeeFil      := HttpSession->Department[nIndiceDepto]:cDepartmentFilial
		oSolic:cFilPotVis  	   := HttpSession->Department[nIndiceDepto]:cFilPostoVis
		oSolic:cPostoVis  	   := HttpSession->Department[nIndiceDepto]:cPostoVis
		HttpSession->DadosFunc := WsClassNew('ORGSTRUCTURE_DATAEMPLOYEE')
		HttpSession->DadosFunc:CEMPLOYEEEMP := HttpSession->Department[nIndiceDepto]:cDepartmentEmp
		HttpSession->Postos := {}
		If oSolic:GetPostosD()
			HttpSession->Postos := oSolic:oWSGETPOSTOSDRESULT:oWSLISTOFPOSTS:oWSDTPOSTOS
			nPTotal             := oSolic:oWSGETPOSTOSDRESULT:nPagesTotal
			nTotalPage          := val(HttpGet->nTotalPage)
			
			If Len(HttpSession->Postos) == 0
				lPostV := .F.
				If lFsUsaPco 
					cMsg := "Posto indisponível!"
					Return ExecInPage("F0100308")
				Else
					cMsg := "Posto e saldo indisponíveis!" 
					Return ExecInPage("F0100308")
				EndIf
			EndIf
		EndIf
		
		nTotal := 0
		
		For nCnt:= 1 to Len(HttpSession->Postos)
			If oSolic:BuscDepto(HttpSession->Department[nIndiceDepto]:cDepartment,HttpSession->Postos[nCnt]:cPostFilial,HttpSession->Postos[nCnt]:cPOSTO)
				nTotal := oSolic:nBUSCDEPTORESULT
			EndIf
			HttpSession->Postos[nCnt]:nReserv := HttpSession->Postos[nCnt]:nReserv + nTotal
		Next
		
		cHtml := ExecInPage( "F0100304" )
			
	WEB EXTENDED END
	
Return cHtml