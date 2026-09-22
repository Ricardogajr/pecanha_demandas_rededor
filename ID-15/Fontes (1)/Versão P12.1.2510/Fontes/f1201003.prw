#Include 'Protheus.ch'

User Function F1201003()

	Local aArea := GetArea()
	Local lRet	:= .F.
	
	DbSelectArea("SC7")
	SC7->(DbSetOrder(1))
	SC7->(DbGotop())
	
	While !SC7->(EOF())
	
		If Empty(SC7->C7_XNOMFOR) .OR. Empty(SC7->C7_XNOMECO)
			SC7->(RecLock('SC7',.F.))
			SC7->C7_XNOMFOR := Posicione("SA2",1,XFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NREDUZ")
			SC7->C7_XNOMECO := FullNamec(SC7->C7_USER)
			SC7->(MsUnLock())
			lRet := .T.
		EndIf
	
		SC7->(DbSkip())
	End
	
	If lRet
		MsgAlert("Processamento realizado com sucesso!!")
	EndIf
	
	RestArea(aArea)

Return
Static Function FullNamec(cUserc)
Return UsrFullName(cUserc)
