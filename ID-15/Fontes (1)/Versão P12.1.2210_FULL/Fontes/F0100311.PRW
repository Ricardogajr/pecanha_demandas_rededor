#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"

/*
{Protheus.doc} F0100311()
Realiza o processo de aprovação ou reprovação
@Author     Bruno de Oliveira, Henrique Madureira
@Since      07/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Return 	cHtml, página html
*/
User Function F0100311()
	
	Local cHtml   := ""
	Local oSolic  := Nil
	
	Private cMsg
	
	WEB EXTENDED INIT cHtml START "InSite"

	oOrg := WSORGSTRUCTURE():New()
		WsChgURL(@oOrg, "ORGSTRUCTURE.APW")
		
	oSolic := WSW0500308():New()
		WsChgURL(@oSolic, "W0500308.apw")
	
	oSpr := WSW0500307():New()
	WsChgURL(@oSpr, "W0500307.apw")
	
	cFililS  := httpGet->cFilil
	cCodSol  := HttpGet->cSolic
	cVisPad  := HttpSession->aInfRotina:cVisao
	cConfirm := httpget->cAceita
	cLugar   := HttpPost->cLugar
	txtobs   := HttpPost->cObs
	cMat     := HTTPSession->RHMat
	cFil     := HttpSession->aUser[2]
		
	If oSpr:ValAprSol(cMat, cFil, cCodSol, cFililS)
		If oSpr:lVALAPRSOLRESULT
			If oSolic:InfSolVg(cFililS, cCodSol)
				
				oOrg:cEmployeeFil  := oSolic:oWSInfSolVgResult:cRH3FILINI
				oOrg:cRegistration := oSolic:oWSInfSolVgResult:cRH3MATINI
				cFilSol            := oSolic:oWSInfSolVgResult:cRH3FILAPR
				cMatSol            := oSolic:oWSInfSolVgResult:cRH3MATAPR
				
			EndIf
				
			cVOrg   := HttpSession->aInfRotina:cVisao
					
			oSolic:oWSSolicitVag:cFilialVg  := cFililS
			oSolic:oWSSolicitVag:cCodMatric := oOrg:cRegistration
			oSolic:oWSSolicitVag:cFilSolic  := oOrg:cEmployeeFil
			oSolic:oWSSolicitVag:cMatSolic  := oOrg:cRegistration
			oSolic:oWSSolicitVag:cVisaoOrg  := cVOrg
			oSolic:oWSSolicitVag:cEmpresa   := GetEmpFun()
			oSolic:oWSSolicitVag:cCODSOLVG  := cCodSol
			oSolic:oWSSolicitVag:cXObs      := txtobs
			oSolic:oWSSolicitVag:cFilAtu    := cFil
			oSolic:oWSSolicitVag:cMatAtu    := cMat
				
			If cConfirm == "1" //Aprovar
				
				oSolic:AprSolVaga()
				cMsg := oSolic:cAPRSOLVAGARESULT
				
			ElseIf cConfirm == "2" //Reprovar
				
				oSolic:oWSSolicitVag:cTpRj  := "1" //Cancela
					
				oSolic:RepSolVaga()
				cMsg := "Solicitação reprovada!"
				
			EndIf
		
		Else
			cMsg := "Cadastro já foi alterado, e passado para o próximo aprovador!"
		EndIf
	EndIf
	If cLugar != '1'
		cHtml := ExecInPage("F0100301")
	Else
		cHtml := ExecInPage("F0500305")
	EndIf
	WEB EXTENDED END

Return cHtml