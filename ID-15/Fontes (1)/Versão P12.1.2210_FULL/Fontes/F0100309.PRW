#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"

/*
{Protheus.doc} F0100309()
Exibe as solicitações das vagas a serem Aprovadas ou Reprovadas
@Author     Bruno de Oliveira
@Since      07/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Return 	lRet
*/
User Function F0100309()
	
	Local cHtml   := ""
	Local cMatric := ""
	Local oSolic  := Nil
	
	Private oListARp
	
	WEB EXTENDED INIT cHtml START "InSite" 
	
		cMatric := HttpSession->RHMat
		cFilApr := HttpSession->aUser[2]
		cVisPad := HttpSession->aInfRotina:cVisao
		cTpSol 	:= "002"
		
		oSolic := WSW0500308():New()
		WsChgURL(@oSolic, "W0500308.APW")	
		
		If oSolic:SolicApRp(cMatric, cFilApr, cVisPad, cTpSol)
			oListARp :=  oSolic:oWSSolicApRpRESULT
		EndIf
		
		cHtml := ExecInPage("F0100309")
	
	WEB EXTENDED END

Return cHtml