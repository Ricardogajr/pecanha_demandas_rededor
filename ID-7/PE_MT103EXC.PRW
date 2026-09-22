#include "totvs.ch"

/*/{Protheus.doc} MT103EXC
Valida exclusão do documento de entrada.
@type User function
@author anieli.rodrigues
@since 20/02/2017
@version 12.7
@project MAN0000007423041_EF_033
@return lRet
/*/

User Function MT103EXC()

	Local lRet := .T.
	Local cPed := ""
	Local cFilPed := ""
	Local aArea := SC7->(GetArea())

	lRet := U_F0703303()

	cPed := SD1->D1_PEDIDO
	cFilPed := SD1->D1_FILIAL 
	DbSelectArea("SC7")
	SC7->(DbSetOrder(1))
	If SC7->(DbSeek(cFilPed+cPed))
		While SC7->(!EOF()) .And. SC7->C7_FILIAL+SC7->C7_NUM == cFilPed+cPed
			Reclock("SC7",.F.)
			SC7->C7_ZINTOGY := "1"
			SC7->(MsUnlock())
			SC7->(DbSkip())
		EndDo
	EndIf
	RestArea(aArea)
Return lRet

