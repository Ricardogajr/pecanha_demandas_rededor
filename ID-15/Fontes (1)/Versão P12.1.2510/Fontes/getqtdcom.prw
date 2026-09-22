#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} GetQtdCom
Programa para Buscar aQuantidade e a Unidade de Compra da Solicitação de Compras.
@type function
@author Ricardo Junior
@since 04/10/2017
@version 1.0
@return NIL
/*/
*-----------------------------------*
User Function GetQtdCom(cChave)
*-----------------------------------*	
	Local nQuant := 00
	Local cUm	 := ""
	Local aRet   := { 00, "" }
	
	DbSelectArea("SC1")
	DbSetOrder(01)
	If SC1->(DbSeek(cChave)) 
		nQuant := SC1->C1_QUANT	
		cUm	   := SC1->C1_UM	
	EndIf
	
	aRet := { nQuant, cUm }
Return aRet