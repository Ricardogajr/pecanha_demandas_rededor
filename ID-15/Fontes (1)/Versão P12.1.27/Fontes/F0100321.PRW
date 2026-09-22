#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"

/*
{Protheus.doc} F0100321()
Busca as informações da solicitação escolhida.
@Author     Bruno de Oliveira
@Since      07/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Return 	cHtml, página html
*/
User Function F0100321()
	
	Local cHtml := ""
	Local oSol  := Nil
	
	Private cObsApr := 'N'
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	    cFililS := httpget->cFilil
	    cCodSol := httpget->cSolic
	    cMatric := HttpSession->RHMat
	    cVisPad := HttpSession->aInfRotina:cVisao
	    nOperac := httpget->nGrid
		cTipo   := "002"
		cDesc   := "Aumento de quadro"
		cCodigo := httpget->cSolic
			    
	  	oSol := WSW0500308():New()
		WsChgURL(@oSol, "W0500308.APW")            
	
		If oSol:BscSolQdro(cCodSol, cMatric, cVisPad, cFililS)
			cFilQd := oSol:oWSBscSolQdroRESULT:cFilQdr
			cCDept := oSol:oWSBscSolQdroRESULT:cCdDept
			cDDept := oSol:oWSBscSolQdroRESULT:cDsDept
			cCFunc := oSol:oWSBscSolQdroRESULT:cCdFunc
			cDFunc := oSol:oWSBscSolQdroRESULT:cDsFunc
			cCCarg := oSol:oWSBscSolQdroRESULT:cCdCarg
			cDCarg := oSol:oWSBscSolQdroRESULT:cDsCarg
			cCCtt  := oSol:oWSBscSolQdroRESULT:cCdCCtt
			cDCtt  := oSol:oWSBscSolQdroRESULT:cDscCtt
			cSalar := oSol:oWSBscSolQdroRESULT:cSalari
			cTpCnt := oSol:oWSBscSolQdroRESULT:cTpCont
			cQntQd := oSol:oWSBscSolQdroRESULT:cQntQdr
			cTpPst := oSol:oWSBscSolQdroRESULT:cTpPost
			cObs   := oSol:oWSBscSolQdroRESULT:cObserv
			cCdPst := oSol:oWSBscSolQdroRESULT:cCodPst
			cOrgSl := oSol:oWSBscSolQdroRESULT:cOrigSl
			cStatus := oSol:oWSBscSolQdroRESULT:cStatusS
			AlPstRpr  := oSol:oWSBscSolQdroRESULT:cAlPstRpr  
			AlDsDpRpr := oSol:oWSBscSolQdroRESULT:cAlDsDpRpr 
			AlDpRpr   := oSol:oWSBscSolQdroRESULT:cAlDpRpr   
			AlDscRpr  := oSol:oWSBscSolQdroRESULT:cAlDscRpr  
			AlFlRpr   := oSol:oWSBscSolQdroRESULT:cAlFlRpr   
			AlFlSl    := oSol:oWSBscSolQdroRESULT:cAlFlSl    
			AlDscSl   := oSol:oWSBscSolQdroRESULT:cAlDscSl   
			AlDptSl   := oSol:oWSBscSolQdroRESULT:cAlDptSl   
			AlDscDptSl:= oSol:oWSBscSolQdroRESULT:cAlDscDptSl
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
		cHtml := ExecInPage( "F0100321" )
		
	WEB EXTENDED END
		
Return cHtml