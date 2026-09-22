#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"

/*
{Protheus.doc} F0100315()
Redireciona a página responsável pela opção escolhida.
@Author     Bruno de Oliveira
@Since      07/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Return 	cHtml, página html
*/
User Function F0100315()

	Local cHtml   := ""
	Local nCnt    := 0
	Local nTotal  := 0
	Local oOrg
	
	Private cMsg       := ""
	Private cFilPEsc   := ""
	Private cPostoEsc  := ""
	Private cCodDepto  := ""
	Private cDescrDepto := ""
	Private cFilDepto  := ""
	Private nPTotal    := 0
	Private nTotalPage := 0
	
	Default HttpGet->nIndDept     := "1"
	Default HttpGet->Page         := "1"
	Default HttpGet->nIndiceDepto := "1"
	Default HttpGet->nTotalPage   := "1"
	Default HttpGet->nCurrentPage := 0
	Default HttpSession->Postos   := {}
	 	
	cOpc         := HttpGet->cOpc
	cNPost       := HttpGet->cNPost
	nCPage       := Val(HttpGet->Page)
	nIndiceDepto := Val(HttpGet->nIndiceDepto)
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	HttpCTType("text/html; charset=ISO-8859-1")
	
	cFilDepto   := HttpSession->AMATS[1]:CEMPLOYEEFILIAL//HttpSession->Department[nIndiceDepto]:cDepartmentFilial
	cCodDepto   := HttpSession->Department[nIndiceDepto]:cDepartment
	cDescrDepto := HttpSession->Department[nIndiceDepto]:cDescrDepartment
	
	oOrg := WSORGSTRUCTURE():New()
	WsChgURL(@oOrg, "ORGSTRUCTURE.APW",,,HttpSession->cEDepto)
		
	nCurrentPage := IIF(!(EMPTY(HttpGet->nCurrentPage)),VAL(HttpGet->nCurrentPage),1)
		
	oSolic := WSW0500308():New()
	WsChgURL(@oSolic,"W0500308.apw")
	
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
	EndIf

	nTotal := 0
	
	For nCnt:= 1 to Len(HttpSession->Postos)
		If oSolic:BuscDepto(cCodDepto,HttpSession->Postos[nCnt]:cPostFilial,HttpSession->Postos[nCnt]:cPOSTO)
			nTotal := oSolic:nBUSCDEPTORESULT
		EndIf
		HttpSession->Postos[nCnt]:nOcupado := HttpSession->Postos[nCnt]:nOcupado + nTotal
	Next
	
	If oSolic:BsCntrCusto(cFilDepto, cCodDepto)
		cCcusto := oSolic:oWSBsCntrCustoRESULT:cCodCC
		cDscCC := oSolic:oWSBsCntrCustoRESULT:cDescC
	Else
		cCcusto := ""
		cDscCC := ""
	EndIf
			
	If cOpc == "2" //Orçamento
		cHtml += ExecInPage( "F0100315" )
	Else
		If cNPost == "1" //Novo Posto Sim
			cNPosto := "1"
			//cHtml += ExecInPage( "F0100319" )
			U_F1302101(.T.,cCcusto,cDscCC,nIndiceDepto)
		Else
			cHtml += ExecInPage( "F0100315" )
		EndIf
	EndIf
	
	WEB EXTENDED END
	
Return cHtml