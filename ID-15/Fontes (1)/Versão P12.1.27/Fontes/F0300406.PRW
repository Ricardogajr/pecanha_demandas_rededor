#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"
/*
{Protheus.doc} F0300406()

@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463701_EF_004
@Return	 cHtml
*/
User Function F0300406()
	
	Local cHtml   	:= ""
	Local cHierarquia 	:= ""
	Local nPos        	:= 0
	Local aAux        	:= {}
	Local nAux        	:= 0
	Local nNivel      	:= 0
	Local oOrg
	Local oAcao
	Local oParam  	:= Nil
	
	Private oLista1
	Private oLista3
	Private oAcao1
	Private oPerio
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	Default HttpGet->Page           := "1"
	Default HttpGet->FilterField    := ""
	Default HttpGet->FilterValue    := ""
	Default HttpGet->EmployeeFilial := ""
	Default HttpGet->Registration   := ""
	Default HttpGet->EmployeeEmp    := ""
	Default HttpGet->cKeyVision     := ""
	
	cMat      := HTTPSession->RHMat
	codsubfun := HttpGet->codsubfun
	depsubfun := HttpGet->depsubfun
	nmsuper   := HttpGet->nmsuper
	HttpSession->aStructure	   	:= {}
	HttpSession->cHierarquia		:= ""
	HttpSession->cDataIni		:= ""
	
	aAuxPag   := aClone(HttpSession->aStructure)
	
	oAcao  := WSW0300401():new()
	WsChgURL(@oAcao,"W0300401.APW")
	
	fGetInfRotina("U_F0300401.APW")
	GetMat()								//Pega a Matricula e a filial do participante logado
	
	//--------------------------------------------------------------------------------
	oOrg := WSORGSTRUCTURE():New()
	WsChgURL(@oOrg,"ORGSTRUCTURE.APW")
	
	If Empty(HttpGet->EmployeeFilial) .And. Empty(codsubfun)
		oOrg:cParticipantID 	    := HttpSession->cParticipantID
		
		If ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat)
			oOrg:cRegistration	 := HttpSession->RHMat
		EndIf
	Else
		oOrg:cEmployeeFil  := HttpGet->EmployeeFilial
		oOrg:cRegistration := codsubfun
	EndIf
	
	oOrg:cKeyVision    :=  Alltrim(HttpGet->cKeyVision)
	oOrg:cVision       := HttpSession->aInfRotina:cVisao
	oOrg:cFilterValue  := HttpGet->FilterValue
	oOrg:cFilterField  := HttpGet->FilterField
	
	IF oOrg:GetStructure()
		HttpSession->aStructure := aClone(oOrg:oWSGetStructureResult:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE)
		nPageTotal              := oOrg:oWSGetStructureResult:nPagesTotal
		
		// *****************************************************************
		// Inicio - Monta Hierarquia
		// *****************************************************************
		cHierarquia := '<ul style="list-style-type: none;"><li><a href="#" class="links" onclick="javascript:GoToPage(null,1,null,null,null,null,' + ;
			"'" + HttpSession->aStructure[1]:cEmployeeFilial + "'," + ;
			"'" + HttpSession->aStructure[1]:cRegistration + "'," + ;
			"'" + HttpSession->aStructure[1]:cEmployeeEmp + "'," + ;
			"'" + oOrg:cKeyVision + "'" + ')">'
		
		If Empty(HttpSession->cHierarquia) .or. (HttpSession->cParticipantID == HttpSession->aStructure[1]:cParticipantID)
			nNivel                 := 1
			HttpSession->cHierarquia := ""
		Else
			aAux := Str2Arr(HttpSession->cHierarquia, "</ul>")
			If (nPos := AScan(aAux, {|x| cHierarquia $ x })) > 0
				For nAux := len(aAux) to nPos step -1
					aDel(aAux,nAux)
					aSize(aAux,Len(aAux)-1)
				Next nAux
			EndIf
			HttpSession->cHierarquia := ""
			For nPos := 1 to Len(aAux)
				HttpSession->cHierarquia += aAux[nPos] + "</ul>"
			Next nPos
			
			nNivel := Iif(Len(aAux) > 0,Len(aAux) + 1,1)
		EndIf
		
		For nPos := 1 to nNivel
			cHierarquia += '&nbsp;&nbsp;&nbsp;'
		Next nPos
		cHierarquia += Alltrim(str(nNivel)) + " . " + HttpSession->aStructure[1]:cName + '</a></li></ul>'
		
		HttpSession->cHierarquia += cHierarquia
		// Fim - Monta Hierarquia
	Else
		HttpSession->aStructure := {}
		nPageTotal 		      := 1
	EndIf
	//--------------------------------------------------------------------------------	
	
	If oAcao:RetAcao()
		oAcao1 := oAcao:oWSRetAcaoRESULT
	EndIf
	
	If oAcao:InfCalen()
		oPerio := oAcao:oWSInfCalenRESULT
	EndIf
	
	If oAcao:VisSuper(codsubfun, cMat)
		oLista3 :=  oAcao:oWSVisSuperRESULT
	EndIf
	
	cHtml := ExecInPage("F0300404")
	WEB EXTENDED END
	
Return cHtml
