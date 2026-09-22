#include 'protheus.ch'

/*{Protheus.doc} F0702401
Função para a geranção dos registros de tratamento por filiais, utilizadas 
nos PEs MT010INC, MTA010E, A010TOK.

@author Alex Sandro
@since 08/02/2017
@param cModo 'I' p/ Inclui ou 'E' p/ Excluir ou 'VLD' p/ validar campos necessarios
@project MAN0000007423041_EF_024
@return Logico
*/

User Function F0702401(cModo)
	Local lRet:= .t. 
	If cModo =="VLD"
		lRet :=  VldCampos()
	ElseIf cModo == "I"
		lRet := IncP17()
	ElseIf cModo == "E"
		lRet := DelP17()
	EndIf
Return lRet

Static Function VldCampos()

	Local cCpInvalid := "|"

	If INCLUI
		If  Empty(M->B1_CONV)
			cCpInvalid += "CONV|"
		EndIf
		If Empty(M->B1_XCONV2)
			cCpInvalid += "XCONV2!"
		EndIf
		If Empty(M->B1_XTERUM)
			cCpInvalid += "XTERUM|"
		EndIf
		If Empty(M->B1_XCOMP)
			cCpInvalid += "XCOMP|"
		EndIf
		If Empty(M->B1_XCONSUM)
			cCpInvalid += "XCONSUM|"
		EndIf
		If cCpInvalid != "|"
			If IsBlind()
				AutoGrLog("Campos " + cCpInvalid + " de tratamento de filiais não informados ou inválidos!")
				Return .F.
			Else
				If ! MsgNoYes("Confirma a inclusão do produto com os campos " + cCpInvalid + " de intergração incompletos ou inválidos!")
					Return .F.
				EndIf
			EndIf
		EndIf
	EndIf
	IF ALTERA
		AltP17()
	Endif

Return .T.

Static Function IncP17()
	Local cDtTime    := DToS(Date())+Space(1)+Time()
	Local aAreaSM0 := {}
	Local aAreaP17 := {}
	Local cReplP17 := "N"
	Local cText    := ""
	Local aRet     :={}
	Local aFilRepl := {}
	Local lAchou 	:= .F.
	Local nFils := 0

	If Select("P17") == 0
		ChkFile("P17")
	EndIf

	aAreaSB1 := SB1->(GetArea('SB1'))
	aAreaP17 := P17->(GetArea('P17'))
	aAreaP30 := P30->(GetArea('P30'))

	Dbselectarea("P30")
	Dbselectarea("P31")

	P30->(DbSetOrder(1))
	P30->(DbGotop())
	P31->(DbSetOrder(1))
	P31->(DbGotop())

	While P30->( !Eof())
		//If P30->(DbSeek(FwXFilial("P30") + SM0->M0_CODFIL))
		IF 	P30->P30_REPLIC == '1'
			// Adiciona matriz/hospital ao vetor com as filiais cujos produtos deverão ser replicados
			AAdd(aFilRepl, P30->P30_CODFIL)
			cFilialP31 := FwXFilial("P31")
			// Adiciona clinicas vinculadas a matriz ao vetor de replicação
			If P31->(DbSeek(cFilialP31 + P30->P30_COD))
				While P31->P31_COD = P30->P30_COD
					AAdd(aFilRepl, P31->P31_CODFIL)
					P31->(DbSkip())
				End
			EndIf
		EndIf
		P30->(DbSkip())
	End

	If Len(aFilRepl) > 0
		For nFils := 1 TO  Len(aFilRepl)
			Begin Transaction
				U_F0702405(aFilRepl[nFils])
			End Transaction
		Next
	EndIf

	RestArea(aAreaP30)
	RestArea(aAreaSB1)
	RestArea(aAreaP17)

Return .T.

Static Function AltP17()
	Local aAreaP17 := {}

	If Select("P17") == 0
		ChkFile("P17")
	EndIf
	aAreaP17 := P17->(GetArea('P17'))
	P17->(DbSetOrder(1))
	IF P17->(DbSeek(xFilial("P17") + SB1->B1_COD))
		While P17->P17_FILIAL == xFilial('P17') .AND. P17->P17_COD == SB1->B1_COD
			P17->(RecLock('P17',.F.))
			IF M->B1_MSBLQL=="1"
				P17->P17_BLOQ := "S"
			ENDIF
			P17->(MsUnlock())
			P17->(DbSkip())
			//U_F1206501(xFilial('P17'),SB1->B1_COD,"A")
		End
	Endif

	//U_F1206403(xFilial("P17"),SB1->B1_COD,IsBlind())

	RestArea(aAreaP17)
Return .t.

Static Function DelP17()
	Local aAreaP17 := {}

	If Select("P17") == 0
		ChkFile("P17")
	EndIf
	aAreaP17 := P17->(GetArea('P17'))
	P17->(DbSetOrder(1))
	While P17->(DbSeek(xFilial("P17") + SB1->B1_COD))
		P17->(RecLock('P17',.F.))
		P17->(DbDelete())
		P17->(MsUnlock())
	End
	RestArea(aAreaP17)
Return .t.

User Function F0702405(cFilP17)
	Local cDtTime    := DToS(Date())+Space(1)+Time()
	If SB1->B1_XMATSER == "1"
		If U_VALSIMP(cFilP17)
			Return
		EndIf
	EndIf
	RecLock('P17', .T. )
	P17->P17_FILIAL := xFilial('P17')
	P17->P17_COD    := SB1->B1_COD
	P17->P17_FTRATA := cFilP17
	P17->P17_FATUR  := SB1->B1_XFATURA
	P17->P17_UM1    := SB1->B1_UM
	P17->P17_CONV1  := SB1->B1_CONV
	P17->P17_TPC1   := SB1->B1_TIPCONV
	P17->P17_UM2    := SB1->B1_SEGUM
	P17->P17_CONV2  := SB1->B1_XCONV2
	P17->P17_TPC2   := SB1->B1_XTCONV2
	P17->P17_UM3    := SB1->B1_XTERUM
	P17->P17_ESTOQ  := SB1->B1_XESTOQ


	// ID 1320 - Bloquear a edicao caso B1_XESTOQ

	IF SB1->B1_MSBLQL == '1' //.OR. INCLUI // Em caso de inclusão força a entrada do produto como bloqueado
		P17->P17_BLOQ := "S"
	Else
		If SB1->B1_XESTOQ <> "S"
			If SB1->B1_XMATSER == "2"
				P17->P17_BLOQ := "N"
			ElseIf SB1->B1_XMATSER == "1" .AND. SB1->B1_XESTOQ == "N"
				P17->P17_BLOQ := "N"
			Else
				IF INCLUI
					P17->P17_BLOQ := "S"
				Else
					P17->P17_BLOQ := IIF(SB1->B1_MSBLQL=="1","S","N")
				Endif
			Endif
		Else
			If INCLUI
				P17->P17_BLOQ := "S"
			Else
				P17->P17_BLOQ := IIF(SB1->B1_MSBLQL=="1","S","N")
			EndIf
		Endif
	Endif

	P17->P17_CONSUM := SB1->B1_XCONSUM
	P17->P17_P12FRO := SB1->B1_XP12FRO
	P17->P17_FROP12 := SB1->B1_XFROP12
	P17->P17_COMP   := SB1->B1_XCOMP
	P17->P17_ATUAL  := SB1->B1_XATUAL
	P17->P17_XUSRIN := cDtTime
	P17->P17_XUSRAL := cDtTime
	P17->P17_XBRASC := SB1->B1_XBRASCV
	P17->P17_XSIMPC := SB1->B1_XSIMPCV
	P17_PRCUC	:= "2"
	P17_REQ		:= "2"
	P17_PRESC	:= "2"	
	P17_PADR	:= "2"	
	P17_BXESTP	:= "2"
	P17_RESSUP	:= "2"
	P17_CONSIG	:= "2"
	


	P17->(MsUnlock())

	U_F1206501(cFilP17,SB1->B1_COD,"I")
Return
