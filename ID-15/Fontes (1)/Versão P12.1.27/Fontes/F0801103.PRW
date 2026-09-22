#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"
/*
{Protheus.doc} F0801103()
Retorna incentivos cadastrados
@Author     Henrique Madureira
@Since	     27/03/2017
@Version    P12.7
@Project    MAN0000007423042_EF_011
@Return	 cHtml
*/
User Function F0801103()
	
	Local cHtml  := ""
	Local cMat   := ""
	Local cNome  := ""
	Local oParam := Nil
	
	Private oLista2
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	cMat  := HttpSession->RHMat
	cNome := HttpSession->Login
	
	oParam := WSW0801101():new()
	
	WsChgURL(@oParam, "W0801101.APW")
	
	If oParam:BuscaFerias(cMat)
		oLista2 :=  oParam:oWSBuscaFeriasRESULT
	EndIf
	
	cHtml := ExecInPage("F0801103")
	
	WEB EXTENDED END
	
Return cHtml

