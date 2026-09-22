#include "Protheus.ch"
#include "topconn.ch"

User Function MT120GOK()

	Local cPedido    :=  PARAMIXB[1] // Numero do Pedido
	Local lInclui    :=  PARAMIXB[2] // Inclusão
	Local lAltera    :=  PARAMIXB[3] // Alteração
	Local lExclusao  :=  PARAMIXB[4] // Exclusão
	Local nReCAtu    := SC7->(RECNO())
	Local cAliasC7   := GetNextAlias()
	Local cQuery := ""
	Local lPrim     := .F.
	Local cUser := ""

	If (isincallstack("MATA094") .Or. IsInCallStack("U_XMATA094"))
		If SCR->CR_TIPO == "MD"
			SC7->(DbSetOrder(1))
			SC7->(MsSeek(cFilant + AllTrim(cPedido)))
		EndIf
		If !Empty(SC7->C7_MEDICAO)
			cUser := Posicione("CND",4,SCR->CR_FILIAL+AllTrim(SCR->CR_NUM),"CND_FORNEC")
			If !Empty(cUser)
				While SC7->(!Eof() .and. C7_FILIAL + C7_NUM == cFilant + AllTrim(cPedComp))
					RecLock("SC7",.F.)
					SC7->C7_USER := cUser
					SC7->C7_OBS := Posicione("CND",4,SCR->CR_FILIAL+AllTrim(SCR->CR_NUM),"CND_OBS")
					SC7->(MsUnlock())
					SC7->(DbSkip())
				EnddO
			EndIf
		EndIF
	EndIf

	If lInclui
		SC7->(DbSetOrder(1))
		SC7->(MsSeek(cFilant + AllTrim(cPedido)))

		DbSelectArea("SC1")
		SC1->(DbSetOrder(1))
		While (SC7->(!EOF()) .And. SC7->C7_FILIAL+SC7->C7_NUM == cFilAnt+cPedido)
			If SC1->(DbSeek(SC7->C7_FILIAL+SC7->C7_NUMSC+SC7->C7_ITEMSC))
				Reclock("SC1",.F.)
				SC1->C1_QUJE := SC1->C1_QUJE + SC7->C7_QUANT
				SC1->(MsUnlock())
			EndIf

			SC7->(DbSkip())
		EndDo
	ElseIf lExclusao
		cQuery := "SELECT * FROM " + RetSqlName("SC7")
		cQuery += " WHERE D_E_L_E_T_ = '*' AND C7_FILIAL = '"+cFilAnt+"'"
		cQuery += " AND C7_NUM = '"+cPedido+"' ORDER BY R_E_C_N_O_ DESC "

		dbusearea( .T. , 'TOPCONN' , TCGenQry( , , cQuery ) , cAliasC7 , .F. , .T. )

		While (cAliasC7)->(!EOF())

			If (cAliasC7)->C7_ITEM == "0001" .And. lPrim
				Exit
			EndIf

			If (cAliasC7)->(C7_ITEM) == "0001"
				lPrim := .T.
			EndIf

			DbSelectArea("SC1")
			SC1->(DbSetOrder(1))
			If SC1->(DbSeek((caliasC7)->C7_FILIAL+(caliasC7)->C7_NUMSC+(caliasC7)->C7_ITEMSC))
				Reclock("SC1",.F.)
				SC1->C1_QUJE := SC1->C1_QUJE - (caliasC7)->C7_QUANT
				SC1->C1_PEDIDO := ""
				SC1->(MsUnlock())
			EndIf
			(cAliasC7)->(DbSkip())
		EndDo
	EndIf

	/*/If IsInCallStack("F1200709")
	SC7->(DbSetOrder(1))
	SC7->(MsSeek(cFilant + AllTrim(cPedido)))
	DbSelectArea("SCR")
	SCR->(DbSetOrder(1))
	If SCR->(DbSeek(SC7->C7_FILIAL+PadR("PC",TAMSX3("CR_TIPO")[1])+PadR(SC7->C7_NUM,TAMSX3("CR_NUM")[1]))
		While SCR->(!EOF()) .And. AllTrim(SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM) == AllTrim(SC7->C7_FILIAL+PadR("PC",TAMSX3("CR_TIPO")[1])+PadR(SC7->C7_NUM,TAMSX3("CR_NUM")[1])))
			If SCR->CR_STATUS <> "03"
				If SCR->CR_STATUS <> "05"
					Reclock("SCR",.F.)
					SCR->CR_STATUS := "05"
					SCR->(MsUnLock())
				EndIf
			EndIf
		EndIf
	EndIf
	EndIf/*/
	SC7->(DbGoto(nReCAtu))
Return

