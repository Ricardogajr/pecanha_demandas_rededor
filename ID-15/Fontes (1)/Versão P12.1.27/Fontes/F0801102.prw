#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"
/*
{Protheus.doc} F0801102()
Pega Informações de quem acessou
@Author     Henrique Madureira
@Since	     27/03/2017
@Version    P12.7
@Project    MAN0000007423042_EF_011
@Return	 cHtml
*/
User Function F0801102()
	
	Local cMat        := ""
	Local cHtml       := ""
	Local oOrg
	
	Private cDepartame := ""
	Private nPTotal    := 0 
	Private nTotalPage := 0 
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	Default HttpGet->Page          := "1"
	Default HttpGet->FilterField   := ""
	Default HttpGet->FilterValue   := ""
	Default HttpGet->EmployeeFilial:= ""
	Default HttpGet->Registration  := ""
	Default HttpGet->EmployeeEmp   := ""
	Default HttpGet->cKeyVision    := ""
	Default HttpGet->nIndiceDepto := '1'
	Default HttpGet->nCurrentPage := 0
	Default HttpGet->nTotalPage   := '1'
	
	nCPage:= Val(HttpGet->Page)
	
	If Empty(HttpGet->FilterValue)
		HttpGet->FilterField   := ""
	EndIf 	
	
	cMat                     := HttpSession->RHMat
	cNome                    := HttpSession->Login
	HttpSession->aStructure  := {}
	HttpSession->cDataIni    := ""
	cFilSup                  := HttpSession->aUser[2]
	
	fGetInfRotina("U_F0801101.APW")
	GetMat() //Pega a Matricula e a filial do participante logado
	
	//-------------------------------------------------------------------
	oOrg := WSORGSTRUCTURE():New()
	WsChgURL(@oOrg, "ORGSTRUCTURE.APW", ,, HttpGet->EmployeeEmp)
	nCurrentPage        := IIF(!(EMPTY(HttpGet->nCurrentPage)),VAL(HttpGet->nCurrentPage),1)
		
	If Empty(HttpGet->EmployeeFilial) .And. Empty(HttpGet->Registration)
		oOrg:cParticipantID := HttpSession->cParticipantID
		
		If Type("HttpSession->RHMat") == "C" .And. !Empty(HttpSession->RHMat)
			oOrg:cRegistration	 := HttpSession->RHMat
		EndIf
	Else
		oOrg:cEmployeeFil  := HttpGet->EmployeeFilial
		oOrg:cRegistration := HttpGet->Registration
	EndIf
	
	oOrg:cKeyVision   := AllTrim(HttpGet->cKeyVision)
	oOrg:cVision      := HttpSession->aInfRotina:cVisao
	oOrg:cFilterValue := UPPER(HttpGet->FilterValue)
	oOrg:cFilterField := HttpGet->FilterField
	oOrg:cRequestType := ""
	oOrg:nPage        := nCurrentPage
		
	If oOrg:GetStructure()
		HttpSession->aStructure := aClone(oOrg:oWSGetStructureResult:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE)
		nPTotal                 := oOrg:oWSGetStructureResult:nPagesTotal
		nTotalPage              := val(HttpGet->nTotalPage)
	Else
	
		HttpSession->aStructure := {}
		nPageTotal              := 1
		nPTotal                 := 1
		nTotalPage              := 1
	EndIf
	
	cHtml := ExecInPage("F0801102")
	
	WEB EXTENDED END
	
Return cHtml
