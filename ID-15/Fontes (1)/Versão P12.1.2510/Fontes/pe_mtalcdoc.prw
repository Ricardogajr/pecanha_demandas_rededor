#Include "Protheus.ch"

/*/{Protheus.doc} MtAlcDoc
Ponto de entrada após a execução das alçadas (qualquer operação).

@project
@type       User Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.7
@return     lOk, se integrado com sucesso ou não
/*/
User Function MtAlcDoc()

	Local aDocument     := {}
	Local aParamIXB     := {}
	Local dDataRef      := CToD("  /  /    ")
	Local nOperation    := 0
	Local lAprovSC		:= .F.
	Local cScNum		:= ""
	Local cFilSc		:= ""
	Local cTipoSc		:= ""
	
	//dummy - evitar warning TDS de variável sem uso
	paramIXB    := paramIXB
	aParamIXB   := AClone(paramIXB)
	aDocument   := AClone(aParamIXB[1])
	dDataRef    := aParamIXB[2]
	nOperation  := aParamIXB[3]
	
	//Verifica se a SC foi aprovada, em caso de aprovação o envio do FLUIG será por esse fonte.
	cFilSc		:= SCR->CR_FILIAL
	cTipoSc		:= SCR->CR_TIPO
	cScNum		:= SCR->CR_NUM
	
	If Funname() == 'MATA235'
		If AllTrim(aDocument[2]) == "PC" .AND. nOperation == 1
			AjustaApro(cScNum,cFilSc,cTipoSc)
		EndIf
	Else 
		//Início - Thais Paiva - 9474856
		If AllTrim(aDocument[2]) == "PC" .AND. (INCLUI .OR. nOperation == 1)
			AjustaApro(cScNum,cFilSc,cTipoSc)
		EndIf
		//Fim - Thais Paiva - 9474856
	EndIf 

	If AllTrim(aDocument[2]) == "SC"
		lAprovSC 	:= VeriApro(cScNum,cFilSc,cTipoSc)
	EndIf
	 
	If  AllTrim(aDocument[2]) != "SC"
		If FindFunction("U_F1701101")
			//StartJob("U_F1701101", GetEnvServer(), .F., aDocument, dDataRef, nOperation, FwCodEmp(), FwCodFil())
			U_F1701101(aDocument, dDataRef, nOperation)
		EndIf
	EndIf
	
	If lAprovSC
		If FindFunction("U_F1701101")
			//StartJob("U_F1701101", GetEnvServer(), .F., aDocument, dDataRef, nOperation, FwCodEmp(), FwCodFil())
			U_F1701101(aDocument, dDataRef, nOperation)
		EndIf
	EndIf
Return


Static Function VeriApro(cNum,cFil,cTipo)

	Local aArea  := GetArea()
	Local lAprov := .F.
	
	Default cNum  := ""
	Default cFil  := ""
	Default cTipo  := ""
	
	SCR->(DbSetOrder(1))
	If SCR->(DbSeek(cFil + cTipo + cNum))
		While SCR->(!(EoF())) .And. SCR->CR_FILIAL == cFil .And. SCR->CR_TIPO == cTipo .And. SCR->CR_NUM == cNum
			If SCR->CR_STATUS $ "03|04|05|06"
				lAprov := .T.
			EndIf
		SCR->(DbSkip())
		End
	EndIf
	RestArea(aArea)
Return lAprov

//Início - Thais Paiva - 9474856
Static Function AjustaApro(cNum,cFil,cTipo)

	Local aArea  := GetArea()
	Local lFalAprov := .F.
	Local lRelib    := .T.
	
	Default cNum  := ""
	Default cFil  := ""
	Default cTipo  := ""
	
	SCR->(DbSetOrder(1))
	If SCR->(DbSeek(cFil + cTipo + cNum))
		While SCR->(!(EoF())) .And. SCR->CR_FILIAL == cFil .And. SCR->CR_TIPO == cTipo .And. SCR->CR_NUM == cNum
			If SCR->CR_STATUS $ "01|02"
				lFalAprov := .T.
			EndIf
		SCR->(DbSkip())
		End
	EndIf
	
	If lFalAprov .and. (SC7->C7_CONAPRO == ' ' .OR. SC7->C7_CONAPRO == 'L') .AND. lRelib
		lRelib := .F.
	EndIf
	RestArea(aArea)
Return 
//Fim - Thais Paiva - 9474856
