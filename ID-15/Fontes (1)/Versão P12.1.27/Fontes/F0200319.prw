#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"
/*
{Protheus.doc} F0200319()
Aprovação superior
@Author     Henrique Madureira
@Since      
@Version    P12.7
@Project    MAN00000463301_EF_003
@Return	 cHtml
*/
User Function F0200319()
	
	Local cHtml       := ""
	Local oParam      := Nil
	Local cHierarquia := ""
	Local oOrg
	
	Private cObsApr := 'N'
	
	WEB EXTENDED INIT cHtml START "InSite"
	Default HttpGet->Page         		:= "1"
	Default HttpGet->FilterField     	:= ""
	Default HttpGet->FilterValue	    := ""
	Default HttpGet->EmployeeFilial   	:= ""
	Default HttpGet->Registration     	:= ""
	Default HttpGet->EmployeeEmp     	:= ""
	Default HttpGet->cKeyVision		    := ""
	
	cNome := HttpSession->Login
	HttpSession->aStructure	   	:= {}
	HttpSession->cHierarquia		:= ""
	HttpSession->cDataIni		:= ""
	cFilSup   := HttpSession->aUser[2]
	lBtAprova := .F.
	cMat      := HTTPSession->RHMat
	cNomeSup  := HttpSession->Login
	cFuncod   := HttpGet->cFuncod
	cSolic    := HttpGet->cSolic
	cStatus   := HttpGet->cStatus
	CFILIALS  := HttpGet->CFILIALS
	Ccodpa3   := HttpGet->Ccodpa3
	Cfilpa3   := HttpGet->Cfilpa3
	cFilFun   := HttpGet->CFILIALS
	
	cFilSup   := HttpSession->aUser[2]
	
	oParam    := WSW0200301():new()
	WsChgURL(@oParam,"W0200301.APW")
	lRet := .F.
	
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
	
	oOrg:cKeyVision		 :=  Alltrim(HttpGet->cKeyVision)
	oOrg:cVision     		    := HttpSession->aInfRotina:cVisao
	oOrg:cFilterValue 		    := HttpGet->FilterValue
	oOrg:cFilterField   		:= HttpGet->FilterField
	oOrg:cRequestType 		    := ""
	
	IF oOrg:GetStructure()
		HttpSession->aStructure  := aClone(oOrg:oWSGetStructureResult:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE)
		nPageTotal 		       := oOrg:oWSGetStructureResult:nPagesTotal
	Else
		HttpSession->aStructure := {}
		nPageTotal 		      := 1
	EndIf

	If oParam:RetInvFu(cFuncod,CFILIALS)
		cMatricu1  := oParam:oWSRetInvFuRESULT:cMatricula
		cNome1     := oParam:oWSRetInvFuRESULT:cNome
		cAdmissao1 := oParam:oWSRetInvFuRESULT:cAdmissao
		cDepartam1 := oParam:oWSRetInvFuRESULT:cDepartame
		cSituacao1 := ""
		cCenCusto1 := oParam:oWSRetInvFuRESULT:cCenCusto
		cCargo1    := oParam:oWSRetInvFuRESULT:cCargo
		cFilial1   := CFILIALS
		cNmCarg1   := oParam:oWSRetInvFuRESULT:cNMCARGO
		cNmCeCu1   := oParam:oWSRetInvFuRESULT:cNMCENTRO
		cNmDepa1   := oParam:oWSRetInvFuRESULT:cNMDEPART
		Superior1  := cMat
	Else
		cMatricu1  := ''
		cNome1     := ''
		cAdmissao1 := ''
		cDepartam1 := ''
		cSituacao1 := ''
		cCenCusto1 := ''
		cCargo1    := ''
		cFilial1   := ''
		cNmCarg1   := ''
		cNmCeCu1   := ''
		cNmDepa1   := ''
		Superior1  := ''
	EndIf
	
	If oParam:InfPa3(ALLTRIM(Cfilpa3),ALLTRIM(Ccodpa3))
		ccurseName         := oParam:oWSINFPA3RESULT:ccurseName
		cinstituteName     := oParam:oWSINFPA3RESULT:cinstituteName
		ccontact           := oParam:oWSINFPA3RESULT:ccontact
		cphone             := oParam:oWSINFPA3RESULT:cphone
		cramal             := oParam:oWSINFPA3RESULT:cramal
		cstartDate         := oParam:oWSINFPA3RESULT:cstartDate
		cendDate           := oParam:oWSINFPA3RESULT:cendDate
		cmonthlyPayment    := oParam:oWSINFPA3RESULT:cmonthlyPayment
		cinstallmentAmount := oParam:oWSINFPA3RESULT:cinstallmentAmount
		cbenefconcedido    := oParam:oWSINFPA3RESULT:cbenefconcedido
		cvltotcurso        := oParam:oWSINFPA3RESULT:cvltotcurso
		cvlinvesanovig     := oParam:oWSINFPA3RESULT:cvlinvesanovig
		cduracao           := oParam:oWSINFPA3RESULT:cduracao
		cTipo              := oParam:oWSINFPA3RESULT:cTipo
		cObservacao        := oParam:oWSINFPA3RESULT:cobservation
	EndIf
		
	cHtml := ExecInPage("F0200304")
	
	WEB EXTENDED END

Return cHtml

