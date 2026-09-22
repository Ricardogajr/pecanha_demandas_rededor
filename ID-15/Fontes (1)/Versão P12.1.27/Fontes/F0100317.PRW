#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"

/*
{Protheus.doc} F0100317()
Busca as informações das minhas solicitações de aumento de postos\orçamento
@Author     Bruno de Oliveira
@Since      07/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Return 	cHtml, página html
*/
User Function F0100317()
	
	Local cHtml   := ""
	Local cMatric := ""
	Local oSolic  := Nil
	
	Private oListSol
	
	WEB EXTENDED INIT cHtml START "InSite"	         
	
		cMatric := HttpSession->RHMat
		cTpSol  := "003"
		
		oSolic := WSW0500308():New()
		WsChgURL(@oSolic, "W0500308.APW")	
		
		If oSolic:MinhSolict(cMatric, cTpSol)
			oListSol := oSolic:oWSMinhSolictRESULT
		EndIf
		
		cHtml := ExecInPage("F0100307")
		
	WEB EXTENDED END

Return cHtml