#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"

/*
{Protheus.doc} F0801107()

@Author     Henrique Madureira
@Since	     27/03/2017
@Version    P12.7
@Project    MAN0000007423042_EF_011
@Return	 cHtml
*/
User Function F0801107()
	
	Local aAux        := {}
	Local cHtml       := ""
	Local cHierarquia := ""
	Local nPos        := 0
	Local nAux        := 0
	Local nNivel      := 0
	Local oParam      := Nil
	Local oOrg

	Private cDepartame := ""
	Private nPTotal    := 0 
	Private nTotalPage := 0 
		
	Private oLista1
	Private oLista2
	Private oLista3
	Private aAuxPag        := {}
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	Default HttpGet->nCurrentPage := 0
	Default HttpGet->Page           := "1"
	Default HttpGet->FilterField    := ""
	Default HttpGet->FilterValue    := ""
	Default HttpGet->EmployeeFilial := ""
	Default HttpGet->Registration   := ""
	Default HttpGet->EmployeeEmp    := ""
	Default HttpGet->cKeyVision     := ""
	
	nCurrentPage        := IIF(!(EMPTY(HttpGet->nCurrentPage)),VAL(HttpGet->nCurrentPage),1)
	
	cMat      := HttpSession->RHMat
	codsubfun := HttpGet->codsubfun
	depsubfun := HttpGet->depsubfun
	filsubfun := HttpGet->EmployeeFilial
	nmsuper   := HttpGet->nmsuper
	
	If AllTrim(HttpSession->aStructure[1]:cRegistration) == AllTrim(cMat)
		HttpSession->aStructureAux := AClone(HttpSession->aStructure)
	EndIf
	aAuxPag   := AClone(HttpSession->aStructureAux)
	oParam    := WSW0801101():new()
	WsChgURL(@oParam, "W0801101.APW")
	
	//-------------------------------------------------------------------
	oOrg := WSORGSTRUCTURE():New()
	WsChgURL(@oOrg, "ORGSTRUCTURE.APW", ,, HttpGet->EmployeeEmp)
	
	oOrg:nPage        := nCurrentPage

	If Empty(HttpGet->EmployeeFilial) .And. Empty(codsubfun)
		oOrg:cParticipantID := HttpSession->cParticipantID
		
		If Type("HttpSession->RHMat") != "U" .And. !Empty(HttpSession->RHMat)
			oOrg:cRegistration	 := HttpSession->RHMat
		EndIf
	Else
		oOrg:cEmployeeFil  := HttpGet->EmployeeFilial
		oOrg:cRegistration := codsubfun
	EndIf
	
	oOrg:cKeyVision   :=  AllTrim(HttpGet->cKeyVision)
	
	oOrg:cVision      := HttpSession->aInfRotina:cVisao
	oOrg:cFilterValue := Upper(HttpGet->FilterValue)
	oOrg:cFilterField := HttpGet->FilterField
	
	If oOrg:GetStructure()
		HttpSession->aStructure  := aClone(oOrg:oWSGetStructureResult:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE)
		nPTotal                 := oOrg:oWSGetStructureResult:nPagesTotal
		nPageTotal 		       := oOrg:oWSGetStructureResult:nPagesTotal
	Else
		HttpSession->aStructure := {}
		nPageTotal              := 1
	EndIf
	
	If oParam:BuscaFerias(cMat)
		oLista2 := oParam:oWSBuscaFeriasRESULT
	EndIf

	cHtml := ExecInPage("F0801107")
	
	WEB EXTENDED END
	
Return cHtml
