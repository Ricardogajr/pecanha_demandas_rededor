#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"

/*
{Protheus.doc} F0100320()
Gravação da solicitação de aumento de postos\orçamento. 
@Author     Bruno de Oliveira
@Since      07/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Return 	cHtml, página html
*/
User Function F0100320()

	Local cHtml   := ""
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
			
			oSolic:oWSSolicitQdr:cFilialQdr := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cEmployeeFilial
			oSolic:oWSSolicitQdr:cCodMatric := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
			oSolic:oWSSolicitQdr:cFilSolic  := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cEmployeeFilial
			oSolic:oWSSolicitQdr:cMatSolic  := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
			oSolic:oWSSolicitQdr:cVisaoOrg  := HttpSession->aInfRotina:cVisao
			oSolic:oWSSolicitQdr:cEmpresa	:= GetEmpFun() 
	
			oSolic:oWSSolicitQdr:cCodDepto	:= IIF(Empty(HttpGet->cDptoEsc),HttpPost->cDepNvQuadro,HttpGet->cDptoEsc)
			oSolic:oWSSolicitQdr:cCdFuncao	:= HttpPost->cFuncao
			oSolic:oWSSolicitQdr:cCdCargo	:= HttpPost->cCargo	
			oSolic:oWSSolicitQdr:cCdCentCt	:= HttpPost->cCcusto
			oSolic:oWSSolicitQdr:cSalario	:= HttpPost->cSalario
			oSolic:oWSSolicitQdr:cTpContr	:= AllTrim(HttpGet->cTipCon)
			oSolic:oWSSolicitQdr:cQntQdro	:= HttpPost->cQtd
			oSolic:oWSSolicitQdr:cTpPosto	:= AllTrim(HttpGet->cTipPos)
			oSolic:oWSSolicitQdr:cObserv	:= HttpPost->cObs
			oSolic:oWSSolicitQdr:cDescDp	:= IIF(Empty(HttpPost->cDescrDepto),HttpPost->cDepNvQuadrod,HttpPost->cDescrDepto)
			oSolic:oWSSolicitQdr:cDescCg	:= HttpPost->cDscCC
			
			oSolic:oWSSolicitQdr:cNvPost    := HttpGet->cNvPosto
			oSolic:oWSSolicitQdr:cFilPosto  := IIF(!Empty(HttpGet->cPostFilial),HttpGet->cPostFilial,HttpSession->aUser[2])
			
			oSolic:oWSSolicitQdr:cFilAtu    := HttpSession->aUser[2]
			oSolic:oWSSolicitQdr:cMatAtu  := HttpSession->RhMat
			
			If HttpGet->cNPost == "1"
				oSolic:oWSSolicitQdr:cAlPostRepor   := HttpGet->cPostRepor
				oSolic:oWSSolicitQdr:cAlDesDpRepor  := HttpGet->cDesDpRepor
				oSolic:oWSSolicitQdr:cAlDepRepor    := HttpGet->cDepRepor
				oSolic:oWSSolicitQdr:cAlDescRepor   := HttpGet->cDescRepor
				oSolic:oWSSolicitQdr:cAlFilRepor    := HttpGet->cFilRepor
				If HttpGet->cNvDesen == "1"
					oSolic:oWSSolicitQdr:cAlFilSol      := HttpGet->cFilSol
					oSolic:oWSSolicitQdr:cAlDescSol     := HttpGet->cDescSol
					oSolic:oWSSolicitQdr:cAlDeptSol     := HttpGet->cDeptSol
					oSolic:oWSSolicitQdr:cAlDescDeptSol := HttpGet->cDescDeptSol
				EndIf
			Else
				oSolic:oWSSolicitQdr:cAlPostRepor   := ""
				oSolic:oWSSolicitQdr:cAlDesDpRepor  := ""
				oSolic:oWSSolicitQdr:cAlDepRepor    := ""
				oSolic:oWSSolicitQdr:cAlDescRepor   := ""
				oSolic:oWSSolicitQdr:cAlFilRepor    := ""
				oSolic:oWSSolicitQdr:cAlFilSol      := ""
				oSolic:oWSSolicitQdr:cAlDescSol     := ""
				oSolic:oWSSolicitQdr:cAlDeptSol     := ""
				oSolic:oWSSolicitQdr:cAlDescDeptSol := ""
			EndIf
			If HttpGet->cNvPosto == "2"
				oSolic:oWSSolicitQdr:cCdPost := HttpGet->cPostEsc
			EndIf
			
			If oSolic:InsSolQdro()
				If oSolic:OWSINSSOLQDRORESULT:CLRETORN == "TRUE"
					cMsg := "Solicitação " + oSolic:OWSINSSOLQDRORESULT:cCdSolic + " efetuada com sucesso"
					cMsg += " na data de " + oSolic:OWSINSSOLQDRORESULT:cDataSol
				Else
					cMsg := oSolic:OWSINSSOLQDRORESULT:cMsgAvso
				EndIf
			EndIf
	
		EndIf
		
		If HttpGet->cNvDesen == "1"
			cHtml := ExecInPage("F1301201")
		Else
			cHtml := ExecInPage("F0100312")
		EndIf
	WEB EXTENDED END

Return cHtml