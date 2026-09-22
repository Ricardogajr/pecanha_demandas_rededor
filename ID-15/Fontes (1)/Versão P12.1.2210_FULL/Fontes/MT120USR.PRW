#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT120USR
//TODO Ponto de entrada para validar usuario caso o pedido seja de mes fechado.
CHAMADO:DOR06406002
@author Ricardo Junior
@since 07/06/2019
@version 1.0
@return Nil

@type function
/*/
User Function MT120USR()
	Local aArea := GetArea()
	Local lRet  := 0
	
	If !Empty(SC7->C7_XIDEXNF)
		lRet := .T.
	EndIf
	
	RestArea(aArea)
Return lRet