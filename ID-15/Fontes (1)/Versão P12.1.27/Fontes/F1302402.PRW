#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"
/*/{Protheus.doc} F1302402
Estrutura organizacional portal
@type function
@author henrique.toyada
@since 29/12/2017
@version 1.0
@return ${return}, ${return_description}
@Project    MAN0000007423048_EF_024
/*/
User Function F1302402()
	Local cHtml     := ""
	Local cFilMat   := ""
	Local cMatricu  := ""
	Local cVisao    := ""
	Local cFilPosto := ""
	Local cCodPosto := ""
	Local nCont		:= 0
	Local nPos      := 0
	Local nI		:= 0
	
	Private cMsg
	Private oLista
	Private oStatu
	Private lRet := .F.
	Private aAux      := {}
	
	Default HttpGet->cFiltro := ""
	
	HttpCTType("text/html; charset=ISO-8859-1")
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	fGetInfRotina("U_F1302401.APW")
	
	cVisao   := HttpSession->aInfRotina:cVisao
	cLista   := IIF(!(EMPTY(HttpGet->cLista)),HttpGet->cLista,"")
	
	If !(EMPTY(HttpGet->cFilPosto)) .AND. !(EMPTY(HttpGet->cCodPosto))
		cFilPosto := IIF(!(EMPTY(HttpGet->cFilPosto)),HttpGet->cFilPosto,"")
		cCodPosto := IIF(!(EMPTY(HttpGet->cCodPosto)),HttpGet->cCodPosto,"")
		cDescDpto := IIF(!(EMPTY(HttpGet->cDescDpto)),HttpGet->cDescDpto,"")
		
		If !(EMPTY(HttpSession->aStructureAux))
			//nValList := IIF(!(EMPTY(HttpGet->nLista)),VAL(HttpGet->nLista),1)
			For nCont := 1 To Len(HttpSession->aStructureAux)//nValList
				AADD(aAux,{HttpSession->aStructureAux[nCont][1],HttpSession->aStructureAux[nCont][2],HttpSession->aStructureAux[nCont][3]})
			Next
		EndIf
		nPos := aScan(aAux,{|x| x[1]+x[2] == cFilPosto+cCodPosto })
		If nPos == 0
			AADD(aAux,{cFilPosto,cCodPosto,cDescDpto})
		Else
			nQtdDl := nPos + 1
			For nI := Len(HttpSession->aStructureAux) to nQtdDl Step -1
				aDel(aAux,nI)
				aSize(aAux,Len(aAux)-1)
			Next nI
		EndIf
	Else
		cMatricu := HTTPSession->RHMat
		cNome    := HttpSession->Login
		cFilMat  := HttpSession->aUser[2]
		AADD(aAux,{"Topo","Pagina inicial",""})
	EndIf
	
	HttpSession->aStructureAux := AClone(aAux)
	
	If HttpGet->cFiltro == "2"
		cFiltro := IIF(!(EMPTY(HttpGet->cValor)),HttpGet->cValor,"")
		cCampo := IIF(!(EMPTY(HttpGet->cCampo)),HttpGet->cCampo,"")
	Else
		cFiltro := ""
		cCampo := ""
	EndIf
	
	oWs := WSW1302400():new()
	WsChgURL(@oWs,"W1302400.APW")
	
	If oWs:BuscaRCL(cFilMat, cMatricu, cVisao, cFilPosto, cCodPosto, cFiltro, cCampo, cLista)
		oLista := OWS:oWSBUSCARCLRESULT:OWSREGISTRO:OWSESTRUTURA
	EndIf
	cHtml := ExecInPage("F1302402")
	
	WEB EXTENDED END
Return cHtml
