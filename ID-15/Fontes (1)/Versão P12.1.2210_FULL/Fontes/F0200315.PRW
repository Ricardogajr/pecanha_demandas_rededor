#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"
/*
{Protheus.doc} F0200315()
Pega Informações de quem acessou
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_003
@Return	 cHtml
*/
User Function F0200315()
	
	Local cHtml          := ""
	Local cMat           := ""
	Local oObj           := Nil
	Local oParam         := Nil
	Local cHierarquia 	:= ""
	Local nPos        	:= 0
	Local aAux        	:= {}
	Local nAux        	:= 0
	Local nNivel      	:= 0
	Local oOrg
	
	Private oLista1
	Private cDepartame := ""
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	Default HttpGet->Page         		:= "1"
	Default HttpGet->FilterField     	:= ""
	Default HttpGet->FilterValue	    := ""
	Default HttpGet->EmployeeFilial   	:= ""
	Default HttpGet->Registration     	:= ""
	Default HttpGet->EmployeeEmp     	:= ""
	Default HttpGet->cKeyVision		    := ""
	
	cMat := HTTPSession->RHMat
	cNome := HttpSession->Login
	HttpSession->aStructure	   	:= {}
	HttpSession->cHierarquia		:= ""
	HttpSession->cDataIni		:= ""
	cFilSup	  := HttpSession->aUser[2]
	
	oParam := WSW0200301():new()
	WsChgURL(@oParam,"W0200301.APW")
	
	fGetInfRotina("U_F0200301.APW")
	GetMat() //Pega a Matricula e a filial do participante logado
	
	oOrg := WSORGSTRUCTURE():New()
	WsChgURL(@oOrg,"ORGSTRUCTURE.APW",,,HttpGet->EmployeeEmp)
	
	If Empty(HttpGet->EmployeeFilial) .And. Empty(HttpGet->Registration)
		oOrg:cParticipantID 	    := HttpSession->cParticipantID
		
		If ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat)
			oOrg:cRegistration	 := HttpSession->RHMat
		EndIf
	Else
		oOrg:cEmployeeFil  := HttpGet->EmployeeFilial
		oOrg:cRegistration := HttpGet->Registration
	EndIf
	
	oOrg:cKeyVision    :=  Alltrim(HttpGet->cKeyVision)
	oOrg:cVision       := HttpSession->aInfRotina:cVisao
	oOrg:cFilterValue  := HttpGet->FilterValue
	oOrg:cFilterField  := HttpGet->FilterField
	oOrg:cRequestType 		    := ""
	
	IF oOrg:GetStructure()
		HttpSession->aStructure := aClone(oOrg:oWSGetStructureResult:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE)
		nPageTotal              := oOrg:oWSGetStructureResult:nPagesTotal
	Else
		HttpSession->aStructure := {}
		nPageTotal 		      := 1
		
	EndIf
	
	cHtml := ExecInPage("F0200302")
	
	WEB EXTENDED END
	
Return cHtml

