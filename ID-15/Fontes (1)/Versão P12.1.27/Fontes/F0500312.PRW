#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"

/*/{Protheus.doc} F0500312
Efetua a aprovação e reprovação enviando e-mail
@type function
@author henrique.toyada
@since 04/11/2016
@project MAN00000463301_EF_003
@version 1.0
@return cHtml, Retorna página
/*/
User Function F0500312()
	
	Local cHtml    := ""
	Local oSolic   := Nil
	Local nCnt     := 0
	Local cAssApr  := "Solicitação para Aprovação"
	Local cBodyApr := ""
	Local cAssRpr  := "Solicitação Reprovada"
	Local cBodyRpr := ""
	Local cObs     := ""
	Local nDiIni   := 0 // ticket n° 2829702 - 26/06/2018 - Paulo Dias 

	Private cMsg
	Private oParam
	Private oLista
	Private oLista2
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	HttpCTType("text/html; charset=ISO-8859-1")
	
	oSolic := WSW0500307():New()
	WsChgURL(@oSolic,"W0500307.apw")
	
	oOrg := WSORGSTRUCTURE():New()
	WsChgURL(@oOrg,"ORGSTRUCTURE.APW")
	
	cMsg     := ""
	cMat     := HTTPSession->RHMat
	cFil     := HttpSession->aUser[2]
	cCodSol  := HttpGet->cSolic
	cConfirm := HttpGet->cAceita
	cLocal   := IIF(EMPTY(HttpPost->cLocal),"",HttpPost->cLocal)
	cFilRh3  := IIF(HttpGet->cFilRh3 != NIL,HttpGet->cFilRh3,HttpPost->cFilRh3)
	cObs     := IIF(HttpGet->cObs != NIL,HttpGet->cObs,HttpPost->cObs)
	cDtDlg   := IIF(HttpGet->cDtDeslig != NIL,HttpGet->cDtDeslig,"")
	
	If oSolic:ValAprSol(cMat,cFil,cCodSol,cFilRh3)
		If oSolic:lVALAPRSOLRESULT
			cBodyApr := "Prezado," +CRLF + ;
				"Foi adicionado uma solicitação " + cCodSol + " para sua aprovação." + CRLF + ;
				"Acesse o Portal RH e efetue a analise da mesma."
			
			cBodyRpr := "Prezado," +CRLF + ;
				"A solicitação " + cCodSol + " foi reprovada."
			
			If oSolic:InfSolVg(cCodSol,cFilRh3)
				
				cVOrg              := oSolic:oWSInfSolVgResult:cRH3VISAO
				oOrg:cEmployeeFil  := oSolic:oWSInfSolVgResult:cRH3FILINI
				oOrg:cRegistration := oSolic:oWSInfSolVgResult:cRH3MATINI
				cFilSol            := oSolic:oWSInfSolVgResult:cRH3FILAPR
				cMatSol            := oSolic:oWSInfSolVgResult:cRH3MATAPR
				
			EndIf
			
			oSolic:OWSSUPERINF:cFilMaSup := ''
			oSolic:OWSSUPERINF:cCodMaSup := ''
			oSolic:OWSSUPERINF:cNvlAprov := ''
			oSolic:OWSSUPERINF:cEmpAprov := ''
			oSolic:OWSSUPERINF:cSolici   := cCodSol
			oSolic:OWSSUPERINF:cFilSolic := cFilRh3
			oSolic:OWSSUPERINF:cObs      := cObs
			
			oSolic:OWSSUPERINF:cFilMaSup := cFil
			oSolic:OWSSUPERINF:cCodMaSup := cMat
			
			oParam := WSW0200301():new()
			WsChgURL(@oParam,"W0200301.APW")
			If cLocal == "008" //Férias // ticket n° 2829702 - 26/06/2018 - Paulo Dias  - variável atribúida
				oInfPar	:= WSCFGDICTIONARY():NEW()
				WsChgURL(@oInfPar,"CFGDICTIONARY.APW")
			
				If oInfPar:GETPARAM( "MSALPHA", "FS_DINIFER" )
					// Verifica se existe o parametro
					If oInfPar:cGETPARAMRESULT <> ".F."
						nDiIni := VAL(oInfPar:cGETPARAMRESULT)
					else
						nDiIni := 45
					EndIf
				EndIf
			
				If oInfPar:GETPARAM( "MSALPHA", "FS_DTER2PE" )
					// Verifica se existe o parametro
					If oInfPar:cGETPARAMRESULT <> ".F."
						cDiPer := oInfPar:cGETPARAMRESULT
					else
						cDiPer := "75"
					EndIf
				EndIf
			EndIf
			// ticket n° 2829702 - 26/06/2018 - Paulo Dias - início da condicional para aprovação da solicitação de Férias	
			If cLocal == "008" 
				If cConfirm == "1"
					cDtInicio := substr(HttpPost->cInitialDate,7,4) + substr(HttpPost->cInitialDate,4,2) + substr(HttpPost->cInitialDate,0,2)
					dDate := DaySum( DATE() , nDiIni )
				
					If !(EMPTY(cDtInicio)) .AND. ((dDate - STOD(cDtInicio)) < 0)
						cMsg := "Data valida!"
					Else
						cMsg := "Solicitação cancelada! Tempo limite para aprovação atingido!"
					EndIf
					
					oSolic:OWSSUPERINF:cFilMaSup := ''
					oSolic:OWSSUPERINF:cCodMaSup := ''
					oSolic:OWSSUPERINF:cNvlAprov := ''
					oSolic:OWSSUPERINF:cEmpAprov := ''
					oSolic:OWSSUPERINF:cSolici   := cCodSol
					oSolic:OWSSUPERINF:cFilSolic := cFilRh3
					oSolic:OWSSUPERINF:cObs      := cObs
			
					oSolic:OWSSUPERINF:cFilMaSup := cFil
					oSolic:OWSSUPERINF:cCodMaSup := cMat
					oSolic:InfPegSup()
					cMsg := oSolic:oWSInfPegSupRESULT:cMSGRET
				Else
					If oParam:PegViInv(cMat,cCodSol,cLocal,cFilRh3, cObs, cfil, cMat)
						cMsg := "Solicitação reprovada com sucesso."
					Else
						cMsg := "Solicitação reprovada com sucesso."
					EndIf
				EndIf
			    //Fim - Paulo Dias
			Else
				If cConfirm == "1"
					If !Empty(cDtDlg)
						oSolic:GrvDtDlg(cDtDlg,cFilRh3,cCodSol)
					EndIf
				oSolic:OWSSUPERINF:cFilMaSup := ''
				oSolic:OWSSUPERINF:cCodMaSup := ''
				oSolic:OWSSUPERINF:cNvlAprov := ''
				oSolic:OWSSUPERINF:cEmpAprov := ''
				oSolic:OWSSUPERINF:cSolici   := cCodSol
				oSolic:OWSSUPERINF:cFilSolic := cFilRh3
				oSolic:OWSSUPERINF:cObs      := cObs
			
				oSolic:OWSSUPERINF:cFilMaSup := cFil
				oSolic:OWSSUPERINF:cCodMaSup := cMat
				oSolic:InfPegSup()
				cMsg := oSolic:oWSInfPegSupRESULT:cMSGRET
				Else
					If oParam:PegViInv(cMat,cCodSol,cLocal,cFilRh3, cObs, cfil, cMat)
						cMsg := "Solicitação reprovada com sucesso."
					Else
						cMsg := "Solicitação reprovada com sucesso."
					EndIf
				EndIf
			EndIf
		Else
			cMsg     := "Cadastro já foi alterado, e passado para o próximo aprovador!"
		EndIf
	EndIf
	cHtml := ExecInPage("F0500305")
	
	WEB EXTENDED END
	
Return cHtml

/*
{Protheus.doc} SendEm()

@Author     Henrique Madureira
@Since      30/06/2016
@Version    P12.7
@Project    MAN00000463301_EF_003
@Param		 cAssunto
@param		 cBody
@param		 cEmail
@Return
*/
Static Function SendEm(cAssunto,cBody,cEmail)
	
	Local oWs
	
	oWs := WSW0200301():new()
	WsChgURL(@oWs,"W0200301.apw")
	oWs:PARAMENTRE(cAssunto,cBody,cEmail)
	
	
Return
