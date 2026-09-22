#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"
/*
{Protheus.doc} F0200317()

@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_003
@Return	 cHtml
*/
User Function F0200317()
	
	Local cHtml        := ""
	Local cSupeMat     := ""
	Local cHierarquia  := ""
	Local nPos         := 0
	Local aAux         := {}
	Local nAux         := 0
	Local nNivel       := 0
	Local oParam       := Nil
	Local oOrg
	Private oLista3
	Private oLista4
	Private cObsApr := 'N'
	
	WEB EXTENDED INIT cHtml START "InSite"
	Default HttpGet->Page           := "1"
	Default HttpGet->FilterField    := ""
	Default HttpGet->FilterValue    := ""
	Default HttpGet->EmployeeFilial := ""
	Default HttpGet->Registration   := ""
	Default HttpGet->EmployeeEmp    := ""
	Default HttpGet->cKeyVision     := ""
	
	//cMat := HTTPSession->RHMat
	cNome := HttpSession->Login
	HttpSession->aStructure	   	:= {}
	HttpSession->cHierarquia		:= ""
	HttpSession->cDataIni		:= ""
	cMat      := HTTPSession->RHMat
	cNomeSup  := HttpSession->Login
	cSolic    := HttpGet->cSolic
	cStatus   := "3"
	cFilis    := ""
	cFilials  := ""
	lBtAprova := .T.
	funcodigo := IIF(HttpGet->funcodigo != Nil, HttpGet->funcodigo,cMat)
	supfuncod := IIF(HttpGet->cDepSup != NIL,HttpGet->cDepSup,cMat)
	nReg      := IIF(HttpGet->nReg != NIL,VAL(HttpGet->nReg),1)
	cFilSup   := HttpSession->aUser[2]
	
	oParam := WSW0200301():new()
	WsChgURL(@oParam,"W0200301.APW")
	
	fGetInfRotina("U_F0200301.APW")
	GetMat()								//Pega a Matricula e a filial do participante logado
	
	oOrg := WSORGSTRUCTURE():New()
	WsChgURL(@oOrg,"ORGSTRUCTURE.APW",,,HttpGet->EmployeeEmp)

	If Empty(HttpGet->EmployeeFilial) .And. Empty(HttpGet->Registration)
		oOrg:cParticipantID 	    := HttpSession->cParticipantID
		
		If ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat)
			oOrg:cRegistration	 := HttpSession->RHMat
		EndIf
	Else
		oOrg:cEmployeeFil  := HttpGet->EmployeeFilial
		oOrg:cRegistration := HttpGet->Registration
	EndIf
	
	oOrg:cKeyVision     :=  Alltrim(HttpGet->cKeyVision)
	
	oOrg:cVision        := HttpSession->aInfRotina:cVisao
	oOrg:cFilterValue   := HttpGet->FilterValue
	oOrg:cFilterField   := HttpGet->FilterField
	oOrg:cRequestType   := ""
	
	IF oOrg:GetStructure()
		HttpSession->aStructure := aClone(oOrg:oWSGetStructureResult:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE)
		nPageTotal              := oOrg:oWSGetStructureResult:nPagesTotal
	Else
		HttpSession->aStructure := {}
		nPageTotal              := 1
	EndIf
	
	If LEN(HttpSession->aStructure) > 0
		cFilFun    := HttpSession->aStructure[nReg]:CEMPLOYEEFILIAL
		cMatricu1  := HttpSession->aStructure[nReg]:cRegistration
		cNome1     := HttpSession->aStructure[nReg]:cName
		cAdmissao1 := HttpSession->aStructure[nReg]:CADMISSIONDATE
		cDepartam1 := HttpSession->aStructure[nReg]:CDEPARTMENT
		cSituacao1 := HttpSession->aStructure[nReg]:CDESCSITUACAO
		cCenCusto1 := HttpSession->aStructure[nReg]:CCOSTID
		cCargo1    := ""
		cFilial1   := HttpSession->aStructure[nReg]:CEMPLOYEEFILIAL
		cNmCarg1   := ""
		cNmCeCu1   := HttpSession->aStructure[nReg]:CCOST
		cNmDepa1   := HttpSession->aStructure[nReg]:CDESCRDEPARTMENT
		Superior1  := ""
	EndIf
	
	If oParam:RetInvFu(cMatricu1,cFilial1)
		cCargo1    := oParam:oWSRetInvFuRESULT:cCargo
		cNmCarg1   := oParam:oWSRetInvFuRESULT:cNMCARGO
	EndIf
	
	If oParam:ListaSolicita(cMat)
		oLista3 :=  oParam:oWSLISTASOLICITARESULT
	EndIf
	
	If oParam:InfInsti()
		oLista4 :=  oParam:oWSInfInstiRESULT
	EndIf
	
	cHtml := ExecInPage("F0200304")
	WEB EXTENDED END
	
Return cHtml

