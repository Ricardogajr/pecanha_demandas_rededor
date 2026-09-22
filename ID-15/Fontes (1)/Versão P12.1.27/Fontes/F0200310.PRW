#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"

/*
{Protheus.doc} F0200310()
Pesquisa solicitações
@Author     Henrique Madureira
@Since      
@Version    P12.7
@Project    MAN00000463301_EF_003
@Return	 cHtml
*/
User Function F0200310()
	
	Local cHtml       := ""
	Local cTela       := "F0200308"
	Local oParam      := Nil
	Local oObj           := Nil
	Local cHierarquia 	:= ""
	Local nPos        	:= 0
	Local aAux        	:= {}
	Local nAux        	:= 0
	Local nNivel      	:= 0
	Local nCnt        := 0
	Local oOrg
	
	Private oLista3   := Nil
	
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
	
	oParam := WSW0200301():new()
	WsChgURL(@oParam,"W0200301.APW")
	
	fGetInfRotina("U_F0200306.APW")
	GetMat()								//Pega a Matricula e a filial do participante logado
	
	cMat      := HTTPSession->RHMat
	cNomeSup  := HttpSession->Login
	funcodigo := IIF(HttpGet->funcodigo != Nil, HttpGet->funcodigo,cMat)
	supfuncod := IIF(HttpGet->cMatSup != NIL,HttpGet->cMatSup,funcodigo)
	nReg      := IIF(HttpGet->nReg != NIL,VAL(HttpGet->nReg),1)
	cFilSup   := HttpSession->aUser[2]
	
	oOrg := WSORGSTRUCTURE():New()
	WsChgURL(@oOrg,"ORGSTRUCTURE.APW",,,HttpGet->EmployeeEmp)
	
	If Empty(HttpGet->EmployeeFilial) .And. Empty(HttpGet->Registration)
		oOrg:cParticipantID 	    := HttpSession->cParticipantID
		
		If ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat)
			oOrg:cRegistration	 := HttpSession->RHMat
		EndIf
	Else
		oOrg:cEmployeeFil  	    := HttpGet->EmployeeFilial
		oOrg:cRegistration 	    := HttpGet->Registration
	EndIf
	
	oOrg:cKeyVision				:=  Alltrim(HttpGet->cKeyVision)
	
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
	
	For nCnt := 1 To LEN(HttpSession->aStructure)
		nReg := IIF(HttpSession->aStructure[nCnt]:cRegistration $ supfuncod,nCnt,nReg)
	Next nCnt
	
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
	
	If oParam:BuscaTrm(.T.)
		oLista3 :=  oParam:oWSBUSCATRMRESULT
	EndIf
	
	cHtml := ExecInPage(cTela)
	WEB EXTENDED END

Return cHtml

