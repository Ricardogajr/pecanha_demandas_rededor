#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH" 
/*
{Protheus.doc} F0200311()
Monta array do treinamentos
@Author     Henrique Madureira
@Since      
@Version    P12.7
@Project    MAN00000463301_EF_003
@Return	 cHtml
*/
User Function F0200311()

Local cHtml     := ""
Local oParam    := Nil

Private cObsApr := "N"

WEB EXTENDED INIT cHtml START "InSite"	    
	
  	cMATRI    := HttpGet->cMatricula1
  	cNOME 	   := HttpGet->cNome1
  	cFilFun   := HttpGet->cFilFun
  	CSOLIC    := ""
  	cFilis    := ""
  	cStatus   := "1"
	lBtAprova := .T.
	oParam := WSW0200301():new()
	WsChgURL(@oParam,"W0200301.APW")
	If oParam:InfTrm(HttpGet->cTrm,HttpGet->cCurso,HttpGet->cFilTrm)
		cCalendario 	:=  oParam:oWSInfTrmRESULT:cCalendario
		cCurso 		:=  oParam:oWSInfTrmRESULT:cCurso
		cHorario 		:=  oParam:oWSInfTrmRESULT:cHorario
		cInicio 		:=  oParam:oWSInfTrmRESULT:cInicio
		cTermino 		:=  oParam:oWSInfTrmRESULT:cTermino
		cTreinamento 	:=  oParam:oWSInfTrmRESULT:cTreinamento
		cVagas 		:=  oParam:oWSInfTrmRESULT:cVagas
		cTurma 		:=  oParam:oWSInfTrmRESULT:cTurma
	EndIf
	
	If oParam:StatuTrmIn(cMATRI,cCalendario)
		lRel := oParam:lSTATUTRMINRESULT
	EndIf
	
	cHtml := ExecInPage("F0200309")
WEB EXTENDED END

Return cHtml 