#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"

/*
{Protheus.doc} F1302501()
Cancelamento da solicitação
@Author     Bruno de Oliveira
@Since      15/12/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_025
@Return 	cHtml, página html
*/
User Function F1302501()
	
	Local cHtml   := ""
	Local oSolic  := Nil
	
	Private cMsg
	
	WEB EXTENDED INIT cHtml START "InSite"
		
		oSolic := WSW0500308():New()
		WsChgURL(@oSolic, "W0500308.apw")
			
		cFSolicitacao  := HttpGet->cFilil
		cCSolicitacao  := HttpGet->cSolic
		cMotivCanceld  := HttpPost->cObsCan
		cFlSolicitant  := HttpSession->aUser[2]
		cMtSolicitant  := HTTPSession->RHMat
		cTipoSolic     := HttpGet->cTipSol
		
		oSolic:CancSolic(cFSolicitacao,cCSolicitacao,cMotivCanceld,cFlSolicitant,cMtSolicitant)
		cMsg := oSolic:cCancSolicRESULT
		
		If cTipoSolic == "002" //Vagas
			cHtml := ExecInPage("F0100301")
		ElseIf cTipoSolic == "003" //Aumento de Quadro
			cHtml := ExecInPage("F0100312")
		ElseIf cTipoSolic == "008" //Férias
			cHtml := ExecInPage("F0801101")
		EndIf 

	WEB EXTENDED END

Return cHtml