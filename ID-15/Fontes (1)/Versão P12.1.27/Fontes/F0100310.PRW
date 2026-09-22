#Include "Protheus.ch"
#INCLUDE "APWEBEX.CH"

/*
{Protheus.doc} F0100310()
Busca as informações da solicitação de vaga
@Author     Bruno de Oliveira, Henrique Madureira
@Since      07/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Return 	cHtml, página html
*/
User Function F0100310()
	
	Local cHtml := ""
	Local oSol  := Nil
	
	Private oInf    := Nil
	Private cMsg
	Private cObsApr := 'N'
	
	WEB EXTENDED INIT cHtml START "InSite"
			
		cFililS := httpget->cFilil
		cCodSol := httpget->cSolic
		cMatric := HttpSession->RHMat
		cVisPad := HttpSession->aInfRotina:cVisao
		nOperac := httpget->nGrid
		cTVaga  := ""
		cTipo   := "002"
		cDesc   := "Vagas"
		cCodigo := httpget->cSolic
		
		oSol := WSW0500308():New()
		WsChgURL(@oSol, "W0500308.APW")
		
		oSol:BscSolVags(cCodSol, cMatric, cVisPad, cFililS)
		If oSol:oWSBscSolVagsRESULT:cRet == ".T."
			cFVaga   := oSol:oWSBscSolVagsRESULT:cFilVag
			cTVaga   := "Contratação"
			cCdDept  := oSol:oWSBscSolVagsRESULT:cDepto
			cDscDpt  := oSol:oWSBscSolVagsRESULT:cDescDpt
			cCdPost  := oSol:oWSBscSolVagsRESULT:cPosto
			cFPost   := oSol:oWSBscSolVagsRESULT:cFlPost
			cCdCC    := oSol:oWSBscSolVagsRESULT:cCodCC
			cDESCRCC := oSol:oWSBscSolVagsRESULT:cDescCc
			cCdFun   := oSol:oWSBscSolVagsRESULT:cFuncao
			CDESCRFC := oSol:oWSBscSolVagsRESULT:cDescFu
			cNSolic  := oSol:oWSBscSolVagsRESULT:cNomeSol
			cPrzVg   := oSol:oWSBscSolVagsRESULT:cPrazo
			cDtAbt   := oSol:oWSBscSolVagsRESULT:cDtAbt
			cDtFch   := oSol:oWSBscSolVagsRESULT:cDtFch
			cCustV   := oSol:oWSBscSolVagsRESULT:cCustVg
			cPrSel   := oSol:oWSBscSolVagsRESULT:cProcS
			cTpVg    := IIF(AllTrim(oSol:oWSBscSolVagsRESULT:cTpVaga) == "1", "Int./Ext.", IIF(AllTrim(oSol:oWSBscSolVagsRESULT:cTpVaga) == "2", "Interna", "Externa"))
			cJornTb  := oSol:oWSBscSolVagsRESULT:cHorMes
			cObservacao   := ALLTRIM(oSol:oWSBscSolVagsRESULT:cXObs)
			cDscDetal   := ALLTRIM(oSol:oWSBscSolVagsRESULT:cObserDet)
			cCODCARGO  := oSol:oWSBscSolVagsRESULT:cCODCARGO
			cDESCRCARGO  := oSol:oWSBscSolVagsRESULT:cDESCRCARGO
			cTurno   := oSol:oWSBscSolVagsRESULT:cTurnoTab
			cDescTrn :=	oSol:oWSBscSolVagsRESULT:cDscTurno
			cCatFun  := oSol:oWSBscSolVagsRESULT:cCatFun
			cDscCatF := oSol:oWSBscSolVagsRESULT:cDscCateg
			cTpCont  := IIF(AllTrim(oSol:oWSBscSolVagsRESULT:cTpContr) == "1", "Indeterminado", "Determinado")
			cHrsSem  := oSol:oWSBscSolVagsRESULT:cHorSem
			cSalHrs  := oSol:oWSBscSolVagsRESULT:cSalHora
			cDFPost  := oSol:oWSBscSolVagsRESULT:cDscFilPt
			
			cStatus := oSol:oWSBscSolVagsRESULT:cStatusS
			
			If oSol:InfFxSl(cCODCARGO, cFPost)
				oInf :=  oSol:oWSInfFxSlRESULT
			EndIf
			
			If oSol:PegMnem(.T.)
				nVal := VAL(oSol:cPEGMNEMRESULT)
			EndIf
		EndIf
		
		oParam   := WSW0500307():new()
		WsChgURL(@oParam,"W0500307.APW")
		
		IF oParam:BscDados(cFililS,cCodSol)
			cFilSoli:= oParam:oWSBSCDADOSRESULT:cFilSoli
			cDescFil:= oParam:oWSBSCDADOSRESULT:cDescFil
			cFilIniS:= oParam:oWSBSCDADOSRESULT:cFilIniS
			cDescFlS:= oParam:oWSBSCDADOSRESULT:cDescFlS
			cMatrFlS:= oParam:oWSBSCDADOSRESULT:cMatrFlS
			cNomeFlS:= oParam:oWSBSCDADOSRESULT:cNomeFlS
			cDescCar:= oParam:oWSBSCDADOSRESULT:cDescCar
			cDescCtt:= oParam:oWSBSCDADOSRESULT:cDescCtt
			cFilSltd:= oParam:oWSBSCDADOSRESULT:cFilSltd
			cDecSltd:= oParam:oWSBSCDADOSRESULT:cDecSltd
			cMatSltd:= oParam:oWSBSCDADOSRESULT:cMatSltd
			cNomSltd:= oParam:oWSBSCDADOSRESULT:cNomSltd
			cCARSLTD:= oParam:oWSBSCDADOSRESULT:cCARSLTD
		EndIf
		
		HttpCTType("text/html; charset=ISO-8859-1")
		cHtml := ExecInPage( "F0100310" )
	
	WEB EXTENDED END
	
Return cHtml
