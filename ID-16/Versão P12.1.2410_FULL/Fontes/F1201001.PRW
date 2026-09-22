#Include 'Protheus.ch'

User Function F1201001()

	Local aArea := GetArea()
	Local lRet	:= .F.
	
	DbSelectArea("AIB")
	AIB->(DbSetOrder(1))
	AIB->(DbGotop())
	
	While !AIB->(EOF())
	
		If Empty(AIB->AIB_XDSPRO) .OR. EMPTY(AIB->AIB_XNMFOR)
			RecLock("AIB",.F.)
			AIB->AIB_XDSPRO := Posicione("SB1",1,XFilial("SB1")+AIB->AIB_CODPRO,"B1_DESC")
			AIB->AIB_XNMFOR := Posicione("SA2",1,XFilial("SA2")+AIB->AIB_CODFOR+AIB->AIB_LOJFOR,"A2_NREDUZ")
			AIB->(MsUnLock())
			lRet := .T.
		EndIf
	
		AIB->(DbSkip())
	End
	
	If lRet
		MsgAlert("Processamento realizado com sucesso!!")
	EndIf
	
	RestArea(aArea)

Return

