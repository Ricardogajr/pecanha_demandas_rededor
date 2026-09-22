#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"

/*
{Protheus.doc} F0801104()

@Author     Henrique Madureira
@Since	     27/03/2017
@Version    P12.7
@Project    MAN0000007423042_EF_011
@Return	 cHtml
*/
User Function F0801104()
	Local aFerProg := {}
	Local cHtml    := ""
	Local nIndice  := 0
	Local nReg     := 0
	Local oObj
	Local oWSFerProg
	
	Private oParam  := Nil
	Private cMsg    := ''
	Private cObsApr := 'N'
	
	Default HttpGet->cSolic := ""
	
	funcodigo	:= HttpGet->funcodigo
	cFilFun		:= HttpGet->cFilFun
	cCodigo		:= HttpGet->cSolic
	cDesc       := "Férias"
	cTipo       := "008"

	If HttpGet->nOperacao == "1"
		If Type("HttpGet->nIndice") == "C"
			nIndice := Val(HttpGet->nIndice)
		EndIf
	Else
		If Type("HttpGet->nIndiceSolic")  == "C"
			nIndice := Val(HttpGet->nIndiceSolic)
		EndIf
	EndIf
			
	WEB EXTENDED INIT cHtml START "InSite"
	
	GetMat()	//Pega filial e matricula do participante
	
	oParam := WSW0200301():new()
	WsChgURL(@oParam, "W0200301.APW")
	
	If oParam:RetInvFu(funcodigo, cFilFun)
		cMatricu1  := oParam:oWSRetInvFuRESULT:cMatricula
		cNome1     := oParam:oWSRetInvFuRESULT:cNome
		cAdmissao1 := oParam:oWSRetInvFuRESULT:cAdmissao
		cDepartam1 := oParam:oWSRetInvFuRESULT:cDepartame
		cCenCusto1 := oParam:oWSRetInvFuRESULT:cCenCusto
		cCargo1    := oParam:oWSRetInvFuRESULT:cCargo
		cNmCeCu1   := oParam:oWSRetInvFuRESULT:cNMCENTRO
		cNmCarg1   := oParam:oWSRetInvFuRESULT:cNMCARGO
		cNmDepa1   := oParam:oWSRetInvFuRESULT:cNMDEPART
		cNomeFil1   := oParam:oWSRetInvFuRESULT:cNomeFil
	EndIf
	
	//Busca ferias programadas do funcionario
	oWSFerProg := WsRHVACATION():New()
	WsChgURL(@oWSFerProg, "RHVACATION.apw" , ,, GetEmpFun())

	HttpGet->nDiasAbo  := 0
	HttpGet->nDiasProg := 0
	
	//Busca Dados montagem da solicitacao
	oObj := WSRHVacation():New()
	WsChgURL(@oObj, "RHVACATION.APW", ,, GetEmpFun())
	
	oFerObj := WSW0801101():new()
	WsChgURL(@oFerObj, "W0801101.APW")
	
	If HttpGet->nOperacao == "1"
		oFerObj:cEmployeeFil  := HttpSession->aStructure[nIndice]:cEmployeeFilial
		oFerObj:cRegistration := HttpSession->aStructure[nIndice]:cRegistration
		
		If nIndice > 0
			oWSFerProg:cEmployeeFil  := HttpSession->aStructure[nIndice]:cEmployeeFilial
			oWSFerProg:cRegistration := HttpSession->aStructure[nIndice]:cRegistration
			If oWSFerProg:GetVacProgEffect()
				aFerProg          := oWSFerProg:oWSGETVACPROGEFFECTRESULT:oWSListOfVacProgEffect:oWSDataVacProgEffect
				HttpGet->aFerProg := oWSFerProg:oWSGETVACPROGEFFECTRESULT:oWSListOfVacProgEffect:oWSDataVacProgEffect
	
				For nReg := 1 to Len(aFerProg)
					HttpGet->nDiasAbo  += aFerProg[nReg]:nAllowDays
					HttpGet->nDiasProg += aFerProg[nReg]:nVacationDays
				Next nReg
			EndIf
		EndIf
		
		HttpGet->aPeriodos := {}
	
		If oFerObj:GetPeriodAbert()
			If EMPTY(oFerObj:oWSGetPeriodAbertResult:oWSListOfPeriod:oWSPerdVacationProg) .OR. Len(oFerObj:oWSGetPeriodAbertResult:oWSListOfPeriod:oWSPerdVacationProg) < 2
				HttpGet->aPeriodos := oFerObj:oWSGetPeriodAbertResult:oWSListOfPeriod:oWSPerdVacationProg
			Else
				HttpGet->aPeriodos := aSize( oFerObj:oWSGetPeriodAbertResult:oWSListOfPeriod:oWSPerdVacationProg, 1 )
			EndIf
		EndIf

		If oObj:GetTypeCalcDay()
			HttpSession->cTipoCalcDia := oObj:cGetTypeCalcDayResult
		EndIf
		
		If oFerObj:TemSoliAbert(cFilFun, funcodigo)
			If oFerObj:lTEMSOLIABERTRESULT
				cMsg := "Já existe Solicitação para esta matricula!"
				Return ExecInPage( "F0801101" )
			EndIf
		EndIf

	ElseIf HttpGet->nOperacao $ "3*4"
		oParam := WSW0500307():new()
		WsChgURL(@oParam, "W0500307.APW")
		
		If oParam:InfRh4Fe(cCodigo, cFilFun)
			oLista                      :=  oParam:oWSINFRH4FERESULT
			cFili                       := AllTrim(oLista:CR8FILIAL)
			cCodVg                      := AllTrim(oLista:CR8MAT)
			cNomVg                      := AllTrim(oLista:CTMPNOME)
			cInitialDate                := AllTrim(oLista:CR8DATAINI)
			cFinalDate                  := AllTrim(oLista:CR8DATAFIM)
			cDays                       := AllTrim(oLista:CR8DURACAO)
			cPecuniaryAllowance         := AllTrim(oLista:CTMPABONO)
			cThirteenthSalary1stInstall := AllTrim(oLista:CTMP1P13SL)
			cObservacao                 := oLista:CObs
			
			cStatus := AllTrim(oLista:cStatusS)
			
		EndIf
		
		IF oParam:BscDados(cFilFun, cCodigo)
			cFilSoli:= oParam:oWSBSCDADOSRESULT:cFilSoli
			cDescFil:= oParam:oWSBSCDADOSRESULT:cDescFil
			cFilIniS:= oParam:oWSBSCDADOSRESULT:cFilIniS
			cDescFlS:= oParam:oWSBSCDADOSRESULT:cDescFlS
			cMatrFlS:= oParam:oWSBSCDADOSRESULT:cMatrFlS
			cNomeFlS:= oParam:oWSBSCDADOSRESULT:cNomeFlS
			cDescCar:= oParam:oWSBSCDADOSRESULT:cDescCar
			cDescCtt:= oParam:oWSBSCDADOSRESULT:cDescCtt
			cFilSltd:= oParam:oWSBSCDADOSRESULT:cFilSltd
			cDecSltd:= oParam:oWSBSCDADOSRESULT:cDecSltd
			cMatSltd:= oParam:oWSBSCDADOSRESULT:cMatSltd
			cNomSltd:= oParam:oWSBSCDADOSRESULT:cNomSltd
			cCARSLTD:= oParam:oWSBSCDADOSRESULT:cCARSLTD
		EndIf
		
		oFerObj:cEmployeeFil  := cFili
		oFerObj:cRegistration := cCodVg
		
		If nIndice > 0
			oWSFerProg:cEmployeeFil  := oObj:cEmployeeFil
			oWSFerProg:cRegistration := oObj:cRegistration
			If oWSFerProg:GetVacProgEffect()
				aFerProg          := oWSFerProg:oWSGETVACPROGEFFECTRESULT:oWSListOfVacProgEffect:oWSDataVacProgEffect
				HttpGet->aFerProg := oWSFerProg:oWSGETVACPROGEFFECTRESULT:oWSListOfVacProgEffect:oWSDataVacProgEffect
	
				For nReg := 1 to Len(aFerProg)
					HttpGet->nDiasAbo  += aFerProg[nReg]:nAllowDays
					HttpGet->nDiasProg += aFerProg[nReg]:nVacationDays
				Next nReg
			EndIf
		EndIf
	EndIf
	
	HttpCTType("text/html; charset=ISO-8859-1")
	cHtml := ExecInPage( "F0801104" )

	WEB EXTENDED END

Return cHtml