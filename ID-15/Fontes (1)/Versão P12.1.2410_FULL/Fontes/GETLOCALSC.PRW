#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} GetEstoq
//Retorna o Local(Armazem) da solicitação de compras
@author Ricardo
@since 02/07/2017
@version 1.0
@type function
/*/
*----------------------------------------------------------*
User Function GetLocalSc(cFil, cNumSc, cItemSc)
*----------------------------------------------------------*
	Local cLocal := ""
	Local aArea  := GetArea()
	
	DbSelectArea("SC1")
	SC1->(DbSetOrder(01))
	If SC1->(DbSeek(PadR(cFil, TamSx3("C1_FILIAL")[1]) + PadR(cNumSc, TamSx3("C1_NUM")[1]) + PadR(cItemSc, TamSx3("C1_ITEM")[1])))
		cLocal := AllTrim(SC1->C1_LOCAL)
	EndIf
	RestArea(aArea)
	
Return cLocal