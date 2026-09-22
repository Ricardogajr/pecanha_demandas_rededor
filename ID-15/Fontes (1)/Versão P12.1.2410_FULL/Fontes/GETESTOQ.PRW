#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} GetEstoq
//Retorna se o produto é estocável ou não
@author Ricardo
@since 02/07/2017
@version 1.0
@type function
/*/
*----------------------------------------------------------*
User Function GetEstoq(cFil, cProd)
*----------------------------------------------------------*	
	Local cEstoq := "S"

	DbSelectArea("P17")
	DbSetOrder(01)
	If DbSeek(xFilial("P17") + cProd + cFil)
		cEstoq := AllTrim(P17->P17_ESTOQ)
	EndIf*/

Return cEstoq