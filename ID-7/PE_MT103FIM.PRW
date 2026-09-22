#INCLUDE "PROTHEUS.CH"
/*{Protheus.doc} MT103FIM()
Ponto de entrada no final do processamento da Nota de Entrada.
@Author	Paulo Krüger
@Since		27/10/2016
@Version	P12.7
@Project	MAN00000463801_EF_001
@Return	lógico	 */

User Function MT103FIM()
	Local cPed := ""
	Local cFilPed := ""
	Local aArea := SC7->(GetArea())

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

	U_F0400107() // Exclui documentos anexos quando excluida a Nota de Entrada.
Return
