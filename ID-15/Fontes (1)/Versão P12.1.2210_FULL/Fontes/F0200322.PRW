#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"
/*
{Protheus.doc} F0200322()

@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_003
@Return	 cHtml
*/
User Function F0200322()
	
	Local cHtml   	:= ""
	Local oParam  	:= Nil
	Local oOrg
	
	Private oLista1
	Private oLista2
	Private oLista4
	Private aAuxPag        := {}
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	Default HttpGet->Page         		:= "1"
	Default HttpGet->FilterField     	:= ""
	Default HttpGet->FilterValue	    := ""
	Default HttpGet->EmployeeFilial   	:= ""
	Default HttpGet->Registration     	:= ""
	Default HttpGet->EmployeeEmp     	:= ""
	Default HttpGet->cKeyVision		    := ""
	
	cMat      := HTTPSession->RHMat
	codsubfun := HttpGet->codsubfun
	depsubfun := HttpGet->depsubfun
	nmsuper   := HttpGet->nmsuper
	aAuxPag   := aClone(HttpSession->aStructure)
	oParam    := WSW0200301():new()
	WsChgURL(@oParam,"W0200301.APW")

	oOrg := WSORGSTRUCTURE():New()
	WsChgURL(@oOrg,"ORGSTRUCTURE.APW",,,HttpGet->EmployeeEmp)
	
	If Empty(HttpGet->EmployeeFilial) .And. Empty(codsubfun)
		oOrg:cParticipantID 	    := HttpSession->cParticipantID
		
		If ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat)
			oOrg:cRegistration	 := HttpSession->RHMat
		EndIf
	Else
		oOrg:cEmployeeFil  	    := HttpGet->EmployeeFilial
		oOrg:cRegistration 	    := codsubfun
	EndIf
	
	oOrg:cKeyVision				:=  Alltrim(HttpGet->cKeyVision)
	
	oOrg:cVision     		    := HttpSession->aInfRotina:cVisao
	oOrg:cFilterValue 		 := HttpGet->FilterValue
	oOrg:cFilterField   		:= HttpGet->FilterField
	oOrg:cRequestType 		    := ""
	
	IF oOrg:GetStructure()
		HttpSession->aStructure  := aClone(oOrg:oWSGetStructureResult:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE)
		nPageTotal 		       := oOrg:oWSGetStructureResult:nPagesTotal
	Else
		HttpSession->aStructure := {}
		nPageTotal 		      := 1
	EndIf
	
	If oParam:SoliTrm(cMat)
		oLista2 :=  oParam:oWSSoliTrmRESULT
	EndIf
	
	If oParam:VisSuper(codsubfun, cMat, '1')
		oLista4 :=  oParam:oWSVisSuperRESULT
	EndIf
	
	cHtml := ExecInPage("F0200311")
	WEB EXTENDED END
	
Return cHtml

