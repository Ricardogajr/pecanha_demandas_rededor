#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} fGetForn
//Retorna código e loja do fornecedor
@author Cesar Escobar
@since 03/07/2017
@version 1.0
@type function
/*/
*----------------------------------------------------------*
User Function GetForn(cCgc)
*----------------------------------------------------------*	
	Local aRet := {.F., "", ""}
	Local cCod := ""
	Local aArea := SA2->(GetArea())

	cCod := STRTRAN(STRTRAN(STRTRAN(cCgc, ".", "" ), "/", "" ), "-", "" )

	DbSelectArea("SA2")
	SA2->(DbSetOrder(3))
	If SA2->(DbSeek(xFilial("SA2") + PADR(cCod,TamSx3("A2_CGC")[1])))
		aRet := {.T., SA2->A2_COD, SA2->A2_LOJA}
	EndIf

	RestArea(aArea)
Return aRet