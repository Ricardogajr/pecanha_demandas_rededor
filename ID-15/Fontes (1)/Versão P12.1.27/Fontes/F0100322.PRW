#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"

/*
{Protheus.doc} F0100322()
Realiza o processo de aprovação ou reprovação da solicitação. 
@Author     Bruno de Oliveira
@Since      07/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Return 	cHtml, página html
*/
User Function F0100322()

	Local cHtml   := ""
	Local oSolic  := Nil
	Local aSup    := {}
	
	Private cMsg
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	oOrg := WSORGSTRUCTURE():New()
	WsChgURL(@oOrg, "ORGSTRUCTURE.APW")
		
	oSolic := WSW0500308():New()
	WsChgURL(@oSolic, "W0500308.apw")
		
	oDepto := WSW0500308():New()
	WsChgURL(@oDepto, "W0500308.apw")
		
	oSApr := WSW0500307():New()
	WsChgURL(@oSApr, "W0500307.apw")
		
	cFililS  := httpGet->cFilil
	cCodSol  := HttpGet->cSolic
	cVisPad  := HttpSession->aInfRotina:cVisao
	cConfirm := httpget->cAceita
	cLugar   := HttpPost->cLugar
	txtobs   := HttpPost->cObs
	cMat     := HTTPSession->RHMat
	cFil     := HttpSession->aUser[2]
		
	If oSApr:ValAprSol(cMat, cFil, cCodSol, cFililS)
		If oSApr:lVALAPRSOLRESULT
		
			If oSolic:InfSolVg(cFililS, cCodSol)
				
				oOrg:cEmployeeFil    := oSolic:oWSInfSolVgResult:cRH3FILINI
				oOrg:cRegistration   := oSolic:oWSInfSolVgResult:cRH3MATINI
				cFilSol              := oSolic:oWSInfSolVgResult:cRH3FILAPR
				cMatSol              := oSolic:oWSInfSolVgResult:cRH3MATAPR
		
			EndIf
				
			cVOrg    := HttpSession->aInfRotina:cVisao
			
			oDepto:GetDepto(oSolic:oWSInfSolVgResult:cRH3FILAPR, oSolic:oWSInfSolVgResult:cRH3MATAPR)
			cDepto   := oDepto:cGetDeptoRESULT
			
			oSolic:oWSSolicitQdr:cFilialQdr := cFililS//oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cEmployeeFilial
			oSolic:oWSSolicitQdr:cCodMatric := oOrg:cRegistration
			oSolic:oWSSolicitQdr:cFilSolic  := oOrg:cEmployeeFil
			oSolic:oWSSolicitQdr:cMatSolic  := oOrg:cRegistration
			oSolic:oWSSolicitQdr:cVisaoOrg  := cVOrg

			oSolic:oWSSolicitQdr:cEmpresa   := GetEmpFun()
			oSolic:oWSSolicitQdr:cCodSolic  := cCodSol
			oSolic:oWSSolicitQdr:cOBSERV    := txtobs
		
			oSolic:oWSSolicitQdr:cFilAtu    := cFil
			oSolic:oWSSolicitQdr:cMatAtu    := cMat
		
			If cConfirm == "1" //Aprovar
				oSolic:AprSolQdro()
				cMsg := oSolic:cAprSolQdroRESULT
			ElseIf cConfirm == "2" //Reprovar
				oSolic:RepSolQdro()
				cMsg := "Solicitação reprovada!"
			EndIf
		
		Else
			cMsg := "Cadastro já foi alterado, e passado para o próximo aprovador!"
		EndIf
	EndIf
	cHtml := ExecInPage("F0500305")

	WEB EXTENDED END

Return cHtml