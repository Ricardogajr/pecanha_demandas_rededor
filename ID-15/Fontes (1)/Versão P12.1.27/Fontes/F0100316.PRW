#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"

/*
{Protheus.doc} F0100316()
Exibição dos postos referentes ao departamento selecionado
@Author     Bruno de Oliveira
@Since      07/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Return 	cHtml, página html
*/
User Function F0100316()

	Local cHtml   	:= ""
	Local oOrg      
	Local nIndiceDepto	:= Val(HttpGet->nIDept)
	
	Private nPTotal    := 0
	Private nTotalPage := 0
	
	WEB EXTENDED INIT cHtml START "InSite"
	                     
	 	Default HttpSession->Postos  := {}
	 	Default HttpGet->Page         := "1"
	 	Default HttpGet->nIndiceDepto := '1'
	 	Default HttpGet->nCurrentPage := 0
	 	Default HttpGet->nTotalPage   := '1'
	 	
	 	nCPage:= Val(HttpGet->Page)
	 	
	 	cOpc := HttpGet->cOpc	 	
		oOrg := WSORGSTRUCTURE():New()
		WsChgURL(@oOrg, "ORGSTRUCTURE.APW",,,HttpSession->cEDepto)
		
		nCurrentPage        := IIF(!(EMPTY(HttpGet->nCurrentPage)),VAL(HttpGet->nCurrentPage),1)
		
		cCodDepto := HttpSession->Department[nIndiceDepto]:cDepartment
		cDescrDepto := HttpSession->Department[nIndiceDepto]:cDescrDepartment
		                     
		//LISTA DE POSTOS	                
		oOrg:cCompanyID		:= HttpSession->AMATS[1]:CEMPLOYEEEMP//HttpSession->Department[nIndiceDepto]:cDepartmentEmp
		oOrg:cDepartmentID	:= HttpSession->Department[nIndiceDepto]:cDepartment
		oOrg:cRequestType   := HttpSession->cTypeRequest
		oOrg:cEmployeeFil      := HttpSession->Department[nIndiceDepto]:cDepartmentFilial
		oOrg:cPostoVis  	   := HttpSession->Department[nIndiceDepto]:cPostoVis
		HttpSession->DadosFunc := WsClassNew('ORGSTRUCTURE_DATAEMPLOYEE')
		HttpSession->DadosFunc:CEMPLOYEEEMP := HttpSession->Department[nIndiceDepto]:cDepartmentEmp
		
		If oOrg:GetPostos()
			HttpSession->Postos := oOrg:oWSGETPOSTOSRESULT:oWSLISTOFPOSTS:oWSDATAPOSTOS
			nPTotal	        := oOrg:oWSGETPOSTOSRESULT:nPagesTotal
		EndIf
		
		HttpCTType("text/html; charset=ISO-8859-1")		
		cHtml := ExecInPage( "F0100316" )
			
	WEB EXTENDED END
	
Return cHtml