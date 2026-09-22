#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"
/*
{Protheus.doc} F0200320()
Aprova/Reprova
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_003
@Return	 cHtml
*/
User Function F0200320()
	
	Local cHtml   := ""
	Local nCnt    := 1
	Local oParam  := Nil
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	cMat     := HTTPSession->RHMat
	cFil     := HttpSession->aUser[2]
	cmsg     := "Registro não alterado."
	cSolic   := HttpGet->cSolic
	cStatus  := HttpGet->cAprova
	cNome    := HttpPost->cNome
	CFILIALS := HttpGet->CFILIALS
	cObs     := IIF(HttpGet->cObs != NIL,HttpGet->cObs,HttpPost->cObs)
	
	oParam := WSW0200301():new()
	WsChgURL(@oParam,"W0200301.APW")
	
	oOrg := WSORGSTRUCTURE():New()
	WsChgURL(@oOrg,"ORGSTRUCTURE.APW")
	
	fGetInfRotina("U_F0200301.APW")
	GetMat()								//Pega a Matricula e a filial do participante logado
	
	oSolic := WSW0500307():New()
	WsChgURL(@oSolic,"W0500307.apw")
	
	If oSolic:ValAprSol(cMat,cFil,cSolic,CFILIALS)
		If oSolic:lVALAPRSOLRESULT
			oOrg:cParticipantID   := ""
			oOrg:cVision          := HttpSession->aInfRotina:cVisao
			oOrg:cEmployeeFil     := HttpSession->aUser[2]
			oOrg:cRegistration    := HttpSession->RhMat
			oOrg:cEmployeeSolFil  := HttpSession->aUser[2]
			oOrg:cRegistSolic     := HttpSession->RhMat
	
			If oOrg:GetStructure()
		
				oSolic := WSW0500308():New()
				WsChgURL(@oSolic,"W0500308.apw")
		
				cFilSol  := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cEmployeeFilial
				cMatSol  := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
				cVOrg    := HttpSession->aInfRotina:cVisao
				cEmpFunc := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cEmployeeEmp
				cDepto   := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cDepartment

				If cStatus == "1"
					If oParam:PegSuper(cMat, cSolic, '2',CFILIALS, cObs)
						cMsg := oParam:OWSPegSuperRESULT:cMsgAvso//"Aprovado com sucesso."
					EndIf
				Else
					If oParam:PegViInv(cMat,cSolic,'2',CFILIALS, cObs, cMat, cfil)
						cMsg := "Reprovado com sucesso."
					EndIf
				EndIf
			EndIf
		Else
			cMsg     := "Cadastro já foi alterado, e passado para o próximo aprovador!"
		EndIf
	EndIf
	cHtml := ExecInPage("F0500305")
	
	WEB EXTENDED END
	
Return cHtml

