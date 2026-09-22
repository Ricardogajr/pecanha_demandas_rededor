#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"

/*
{Protheus.doc} F0100306()
Gravação da Solicitação de Vaga
@Author     Bruno de Oliveira
@Since      07/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Return 	cHtml, página html
*/
User Function F0100306()

	Local nIndiceDepto := HttpPost->nIndiceDepto
	Local cCodPosto    := ""
	Local cFilPosto    := ""
	Local cHtml        := ""
	Local oOrg
	Local oSolic
	
	Private cMsg
	
	WEB EXTENDED INIT cHtml START "InSite"

	   	oOrg := WSORGSTRUCTURE():New()
		WsChgURL(@oOrg, "ORGSTRUCTURE.APW")
		
		oOrg:cParticipantID   := ""
		oOrg:cVision          := HttpSession->aInfRotina:cVisao
	 	oOrg:cEmployeeFil     := HttpSession->aUser[2]
		oOrg:cRegistration    := HttpSession->RhMat
		oOrg:cEmployeeSolFil  := HttpSession->aUser[2]
		oOrg:cRegistSolic     := HttpSession->RhMat
	 
		If ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat)
			oOrg:cRegistration := HttpSession->RHMat
		EndIf   
				 
		If oOrg:GetStructure()
			oSolic := WSW0500308():New()
			WsChgURL(@oSolic, "W0500308.apw")
			
			cFilSol  := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cEmployeeFilial
			cMatSol  := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
			cVOrg    := HttpSession->aInfRotina:cVisao			
			cEmpFunc := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cEmployeeEmp
			cDepto   := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cDepartment
			
			
			oSolic:oWSSolicitVag:cFilialVg  := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cEmployeeFilial
			oSolic:oWSSolicitVag:cCodMatric := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
			oSolic:oWSSolicitVag:cFilSolic  := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cEmployeeFilial
			oSolic:oWSSolicitVag:cMatSolic  := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
			oSolic:oWSSolicitVag:cVisaoOrg  := cVOrg
			
			oSolic:oWSSolicitVag:cEmpresa   := GetEmpFun() 
			
			oSolic:oWSSolicitVag:cCodDepto    := HttpGet->cDptoEsc
			oSolic:oWSSolicitVag:cDscDepto    := HttpGet->cDptoDsc
			oSolic:oWSSolicitVag:cFilPosto    := HttpGet->cFlPEsc
			oSolic:oWSSolicitVag:cCodPosto    := HttpGet->cPostEsc
			oSolic:oWSSolicitVag:cVaga        := "1"
			oSolic:oWSSolicitVag:cDscVaga     := HttpPost->cDscVaga	
			oSolic:oWSSolicitVag:cCodCC       := HttpPost->cCcusto
			oSolic:oWSSolicitVag:cCodFunc     := HttpPost->cFuncao
			oSolic:oWSSolicitVag:cCodCargo    := HttpPost->cCargo
			oSolic:oWSSolicitVag:cPrazoVaga   := "0"
			oSolic:oWSSolicitVag:dDatAbertura := CTOD(" / / ")
			oSolic:oWSSolicitVag:dDatFecham   := CTOD(" / / ")
			oSolic:oWSSolicitVag:cCustoVaga   := HttpPost->cCusto
			oSolic:oWSSolicitVag:cProcSelet   := ""
			oSolic:oWSSolicitVag:cTpVaga      := HttpPost->ddltpvaga
			
			oSolic:oWSSolicitVag:cTurnoTab    := HttpPost->cTurno
			oSolic:oWSSolicitVag:cHorMes      := HttpPost->cHrMes
			oSolic:oWSSolicitVag:cHorSem      := HttpGet->cHrSeman
			oSolic:oWSSolicitVag:cSalHora     := HttpGet->cSalHora
			oSolic:oWSSolicitVag:cCatFun      := HttpPost->ddltpcat
			oSolic:oWSSolicitVag:cTpContr     := httppost->ddltpcon
			oSolic:oWSSolicitVag:cXObs        := HttpPost->cDscVaga
			
			oSolic:oWSSolicitVag:cFilAtu        := HttpSession->aUser[2]
			oSolic:oWSSolicitVag:cMatAtu        := HttpSession->RHMat
			
			If oSolic:InstSolict()
				If oSolic:OWSINSTSOLICTRESULT:CLRETORN == "TRUE"
					cMsg := "Solicitação de vaga " + oSolic:OWSINSTSOLICTRESULT:cCdSolic + " efetuada com sucesso"
					cMsg += " na data de " + oSolic:OWSINSTSOLICTRESULT:cDataSol
				Else
					cMsg := oSolic:OWSINSTSOLICTRESULT:cMsgAvso
				EndIf
			EndIf
	
		EndIf
		
		cHtml := ExecInPage("F0100301")
	
	WEB EXTENDED END

Return cHtml