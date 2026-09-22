#Include 'Protheus.ch'

User Function F1201002(cFilPed,cPedComp)

Local	aAreaSC7	:= SC7->(GetArea())

SC7->(DbSetOrder(01))
SC7->(DbSeek(cFilPed + cPedComp))

While !SC7->(Eof()) .And. SC7->C7_FILIAL + SC7->C7_NUM == cFilPed + cPedComp

	If Empty(SC7->C7_XNOMFOR) .OR. Empty(SC7->C7_XNOMECO)
		SC7->(RecLock('SC7',.F.))
		SC7->C7_XNOMFOR := Posicione("SA2",1,XFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NREDUZ")
		SC7->C7_XNOMECO := FullNamec(SC7->C7_USER)
		SC7->(MsUnLock())
	EndIf

	SC7->(DbSkip())
End

SC7->(RestArea(aAreaSC7))

Return
Static Function FullNamec(cUserc)
Return UsrFullName(cUserc)
