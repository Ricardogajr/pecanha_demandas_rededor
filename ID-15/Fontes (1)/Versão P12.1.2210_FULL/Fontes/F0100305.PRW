#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"

/*
{Protheus.doc} F0100305()
Ao clicar no posto verifica disponibilidade de orçamento e posto
@Author     Bruno de Oliveira
@Since      07/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Return 	cHtml, página html
*/
User Function F0100305()
	
	Local lFsUsoPco := .T.
	Local lExist	:= .F.
	Local cHtml     := "F0100305"
	Local cCodVg    := ""
	Local nOcup     := 0
	Local nQntd     := 0
	Local nTotal    := 0
	Local oOrg
	Local lLibPst   := .F.
	
	Private cMsg
	Private oInf
	
	WEB EXTENDED INIT cHtml START "InSite"
		
		oPost := WSW0500308():New()
		WsChgURL(@oPost,"W0500308.APW")
		
		HttpPost->Posto := HttpSession->Postos[val(HttpGet->nIndicePosto)]
		
		cPosto := HttpPost->Posto:cPosto
		cDepto := HttpPost->Posto:cCodDepto		
		
		nOcup := HttpSession->Postos[val(HttpGet->nIndicePosto)]:nOcupado + HttpSession->Postos[val(HttpGet->nIndicePosto)]:nReserv
		nQntd := HttpSession->Postos[val(HttpGet->nIndicePosto)]:nQtd
		cFilP := HttpSession->Postos[val(HttpGet->nIndicePosto)]:cPostFilial
		
		cCodVg     := HttpPost->Posto:CCODCARGO
		cFilPosto  := HttpPost->Posto:cPostFilial
		cFilDepar  := HttpSession->DEPARTMENT[1]:CDEPARTMENTFILIAL
		cCodDepto := HttpSession->Department[1]:cDepartment
		//oPost:VerPostSol(cPosto,cDepto,nOcup,nQntd,cFilP)
		
		If oPost:BsCntrCusto(cFilDepar, cCodDepto)
			cCcusto := oPost:oWSBsCntrCustoRESULT:cCodCC
			cDscCC := oPost:oWSBsCntrCustoRESULT:cDescC
		Else
			cCodCC := ""
			cDescC := ""
		EndIf
		/*
		If oPost:BuscDepto(cDepto,cFilP,cPosto)
			nTotal := oPost:nBUSCDEPTORESULT
		EndIf	
		*/
		//If oPost:lVERPOSTSOLRESULT	
		
		If oPost:BscParametr()
			lLibPst := oPost:lBSCPARAMETRRESULT
		EndIf
		lPostV := .T.
		cDscDetal := ""	
		
		nOcup += nTotal
		
		If nOcup >= nQntd
			
			If !lLibPst		
				If lFsUsoPco
					cMsg := "Posto indisponível!"
					cHtml := "F0100308"
				Else
					cMsg := "Posto e saldo indisponíveis!"
					cHtml := "F0100308"
				EndIf
				lCntPrcss := .F.	
			Else
				lCntPrcss := .T.
			EndIf
		/* Nairan - Orçamento ainda não implantado	
		ElseIf nOcup < nQntd
			
			If !lFsUsoPco
				cMsg := "Saldo indisponível!"
				cHtml := "F0100308"
			EndIf*/
		ElseIf nOcup >= nQntd
		
			If !lLibPst	
				cMsg := "Posto indisponível!"
				cHtml := "F0100308"	
				lCntPrcss := .F.	
			Else
				lCntPrcss := .T.
			EndIf	
		
		ElseIf nOcup < nQntd
			oParam := WSW0500308():New()
			WsChgURL(@oParam,"W0500308.apw")
		
			If oParam:InfFxSl(cCodVg,cFilPosto)
				oInf :=  oParam:oWSInfFxSlRESULT
			EndIf
	
			If oParam:PegMnem(.T.)
				nVal :=  VAL(oParam:cPEGMNEMRESULT)
			EndIf
			
			oParam:oWSIdVaga:cQ3FILIAL := cFilP
			oParam:oWSIdVaga:cQ3CARGO  := HttpPost->Posto:CCODCARGO
			oParam:oWSIdVaga:cQ3CC     := HttpPost->Posto:CCC
			
			If oParam:VgDescDet()
				cDscDetal :=  oParam:cVgDescDetRESULT
			Else
				cDscDetal := ""
			EndIf	
			lCntPrcss := .F.
		EndIf
		
		If lCntPrcss
			oParam := WSW0500308():New()
			WsChgURL(@oParam,"W0500308.apw")
		
			If oParam:InfFxSl(cCodVg,cFilPosto)
				oInf :=  oParam:oWSInfFxSlRESULT
			EndIf
	
			If oParam:PegMnem(.T.)
				nVal :=  VAL(oParam:cPEGMNEMRESULT)
			EndIf
			
			oParam:oWSIdVaga:cQ3FILIAL := cFilP
			oParam:oWSIdVaga:cQ3CARGO  := HttpPost->Posto:CCODCARGO
			oParam:oWSIdVaga:cQ3CC     := HttpPost->Posto:CCC
			
			If oParam:VgDescDet()
				cDscDetal :=  oParam:cVgDescDetRESULT
			Else
				cDscDetal := ""
			EndIf
		EndIf	
		
		HttpCTType("text/html; charset=ISO-8859-1")
		cHtml := ExecInPage( cHtml )
	
	WEB EXTENDED END
	
Return cHtml