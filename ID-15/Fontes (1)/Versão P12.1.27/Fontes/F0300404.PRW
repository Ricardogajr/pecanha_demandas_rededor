#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH" 

/*
{Protheus.doc} F0300404()

@Author     Henrique Madureira
@Since      
@Version    P12.7
@Project    MAN00000463701_EF_004
@Return	 cHtml
*/
User Function F0300404()
Local cHtml   := ""
Local cMat    := ""
Local nCnt    := 1
Local oObj   
Local oParam  

WEB EXTENDED INIT cHtml START "InSite"	         
	
	cMat      := HTTPSession->RHMat
	cNome     := HttpSession->Login
	cFilSup   := HttpSession->aUser[2]
	cCheck    := HttpPost->ckb
	cDtInicio := STRTRAN(HttpPost->dtInicio,'-','')
	cDtFim    := STRTRAN(HttpPost->dtFim,'-','')
	cItemAd   := HttpPost->ItmAcaoRes
	cPeriodo  := HttpPost->periodo
	cParticip := HttpPost->cParticipantId
	cMsg      := "Registros não Alterados ou já Existentes!"
	
	aArrayUsu := IIF(!(Empty(cCheck)),StrToKarr(cCheck, ','),{})
	aArrayItm := IIF(!(Empty(cItemAd)),StrToKarr(cItemAd, '-'),{})
	
	oAcao  := WSW0300401():new()
	WsChgURL(@oAcao,"W0300401.APW")
	If !(ValidPeri(cPeriodo,cDtInicio,cDtFim))
		cMsg := "A data Inicial ou Final não está dentro do periodo informado!"
	Else
		If EMPTY(aArrayUsu)
			cMsg := "Selecione um dos funcionários"
		Else
			For nCnt := 1 To Len(aArrayUsu)
				If aArrayUsu[nCnt] != 'on'
					If oAcao:GravAcao(cFilSup,cMat, ALLTRIM(aArrayUsu[nCnt]), cDtInicio, cDtFim, aArrayItm[1], aArrayItm[2], cPeriodo)
						lRet := oAcao:lGRAVACAORESULT
						If lRet
							cMsg := "Registro Incluido com sucesso!"
						Else
							cMsg := "Registro não Alterado! Participante já tem o item cadastrado ou algum dado está incorreto!"
						EndIf
					EndIf
				EndIf
			Next
		EndIf
	EndIf

	cHtml := ExecInPage("F0300401")

WEB EXTENDED END
Return cHtml

Static Function ValidPeri(cPeriodo,cDtInicio,cDtFim)

Local lRet     := .T.
Local cDataIni := ""
Local cDataFim := ""

cDataIni := SUBSTR(cPeriodo, 7, 8)
cDataFim := SUBSTR(cPeriodo, 15, 8)

If (STOD(cDtFim) - STOD(cDtInicio)) < 0
	lRet := .F.
Else
	If (STOD(cDtInicio) - STOD(cDataIni)) < 0
		lRet := .F.
	Else
		If ((STOD(cDataFim) - STOD(cDtFim)) < 0) .AND. ((STOD(cDtFim) - STOD(cDataIni)) > 0)
			lRet := .F.
		EndIf 
	EndIf
EndIf

Return lRet