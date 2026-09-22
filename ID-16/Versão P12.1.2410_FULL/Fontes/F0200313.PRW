#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH" 

/*
{Protheus.doc} F0200313()
Aprova/Reprova
@Author     Henrique Madureira
@Since      
@Version    P12.7
@Project    MAN00000463301_EF_003
@Return	 cHtml
*/
User Function F0200313()

Local cHtml   	:= ""
Local aAux			:= {}
Local oParam  	:= Nil

WEB EXTENDED INIT cHtml START "InSite"	 
	lBtAprova := .F.
	cMATRI    := HttpGet->cMatricula
  	cNOME 	   := HttpGet->cNome
  	cSolic    := HttpGet->cSolic
  	cStatus   := HttpGet->cStatus
  	cFiliS    := HttpGet->cFiliS
  	cFilFun   := HttpGet->cFiliS
  	cObsApr   := 'N'
  	oParam := WSW0200301():new()
  	WsChgURL(@oParam,"W0200301.APW")
  	lRet := .F.
  	
  	If oParam:AnaSoli(cSolic,cFiliS)
		cMATRI 		:=  oParam:OWSANASOLIRESULT:cRA3MAT
		cNOME	 		:=  oParam:OWSANASOLIRESULT:cTMPNOME
		cCalendario 	:=  oParam:OWSANASOLIRESULT:cRA3CALEND
		cCurso 		:=  oParam:OWSANASOLIRESULT:cRA3CURSO
		cObserva 		:=  oParam:OWSANASOLIRESULT:cObs
	EndIf
  	
	If oParam:InfTrm(cCalendario,cCurso,cFiliS)
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

