#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"

/*
{Protheus.doc} F0100318()
Informações das solicitações de aumento de postos\orçamento para aprovação ou rejeição. 
@Author     Bruno de Oliveira
@Since      07/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Return 	cHtml, página html
*/
User Function F0100318()
	
	Local cHtml   := ""
	Local cMatric := ""
	Local oSolic  := Nil
	
	Private oListARp
	
	WEB EXTENDED INIT cHtml START "InSite" 
		
		cMatric := HttpSession->RHMat
		cFilApr := HttpSession->aUser[2]
		cVisPad := HttpSession->aInfRotina:cVisao
		cTpSol := "003"
		
		oSolic := WSW0500308():New()
		WsChgURL(@oSolic, "W0500308.APW")	
		
		If oSolic:SolicApRp(cMatric, cFilApr, cVisPad, cTpSol)
			oListARp := oSolic:oWSSolicApRpRESULT
		EndIf
		
		cHtml := ExecInPage("F0100309")
		
	WEB EXTENDED END

Return cHtml