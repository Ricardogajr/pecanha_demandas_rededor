#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "TOTVS.CH"
#Include 'TopConn.Ch'

User Function MSGPED001(cFl,cPedido,nOpca)

	Local aArea := GetArea()
	Local nRecC7 := SC7->(RECNO())
	Local cGrpExt := GetNewPar("MV_XGRPKT1","000005") //Grupo de pedido externo KT
	Local cGrpDel := GetNewPar("MV_XGRPKT2","000006") //Grupo de pedido Delegado KT
	Local cGrupo := ""
	

	If nOpca <> 1
		Return
	EndIf

	DbSelectArea("SC7")
	SC7->(DbSetOrder(1))
	If SC7->(MsSeek(cFl + AllTrim(cPedido)))
		While SC7->(!Eof() .AND. C7_FILIAL + C7_NUM == cFl + AllTrim(cPedido))

			Reclock("SC7",.F.)

			If fPedDelegado(cFl,SC7->C7_USER)
				SC7->C7_XKTGRUP := cGrpDel // Grupo delegado
			ElseIf SC7->C7_XORIG == "2"
				SC7->C7_XKTGRUP := cGrpExt // Grupo Ped Externo
			ElseIf !Empty(SC7->C7_USER) .Or. !Empty(SC7->C7_GRUPCOM) //Compra Corporativa
				SC7->C7_XKTGRUP := fGetCorp(cFl,SC7->C7_USER,SC7->C7_GRUPCOM)
			ElseIf Empty(SC7->C7_USER) .And. Empty(SC7->C7_GRUPCOM) //Pedidos de contrato em sua maioria
				SC7->C7_XKTGRUP := fGetSBZ(cFl,SC7->C7_PRODUTO)
			EndIf
			SC7->(MsUnlock())
			SC7->(DbSkip())

		EndDo
	EndIf

	SC7->(DbGoto(nRecC7))
	RestArea(aArea)
Return


Static Function fPedDelegado(cFl,cUser)

	Local lRet := .F.
	Local cGrpDel := GetNewPar("MV_XGRPKT2","000006")
	Default cUser := ""
	Default cFl := ""

	DbSelectArea("SAJ")
	SAJ->(DbSetOrder(2))

	SAJ->(DbSeek(cFl+cUser))

	While SAJ->(!Eof() .AND. AllTrim(AJ_FILIAL + AJ_USER) == AllTrim(cFl + cUser))
		If SAJ->AJ_GRCOM == cGrpDel
			lRet := .T.
			Exit
		EndIf
		SAJ->(DbSkip())
	EndDo

Return lRet


Static Function fGetCorp(cFl,cUser,cGrp)

	Local cRet := ""
	Default cUser := ""
	Default cFl := ""
	Default cGrp := ""

	IF !Empty(cGrp)
		cRet := cGrp
	EndIf

	If Empty(cRet)
		DbSelectArea("SAJ")
		SAJ->(DbSetOrder(2))
		SAJ->(DbSeek(cFl+cUser))
		cRet := SAJ->AJ_GRCOM
	EndIf
Return cRet


Static Function fGetSBZ(cFl,cProd)

	Local cRet := ""
	Default cProd := ""
	Default cFl := ""

	cRet := Posicione("SBZ",1,cFl+cProd,"BZ_XGRPCOM")
Return cRet
