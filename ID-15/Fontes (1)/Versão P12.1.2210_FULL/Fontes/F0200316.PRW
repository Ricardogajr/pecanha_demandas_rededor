#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"
/*
{Protheus.doc} F0200316()
Retorna incentivos cadastrados
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_003
@Return	 cHtml
*/
User Function F0200316()
	
	Local cHtml   	:= ""
	Local cMat			:= ""
	Local cNome 		:= ""
	Local oObj			:= Nil
	Local oParam  	:= Nil
	
	Private oLista2
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	cMat := HTTPSession->RHMat
	cNome := HttpSession->Login
	
	oParam := WSW0200301():new()
	WsChgURL(@oParam,"W0200301.APW")
	
		If oParam:RetornaPa3(cMat)
			oLista2 :=  oParam:oWSRETORNAPA3RESULT
		EndIf
		
		cHtml := ExecInPage("F0200303")
	
	WEB EXTENDED END
	
Return cHtml

