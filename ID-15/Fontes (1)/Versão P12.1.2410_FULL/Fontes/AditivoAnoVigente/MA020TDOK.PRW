#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} MA020TDOK
//TODO Descrição auto-gerada.
@author Paulo D
@since 11/05/2021
@project DOR08203457
@type function
/*/

User Function MA020TDOK

Local aArea := GetArea()
Local lRet:= .T.	   

If !Empty(M->A2_XCODES) .AND. !Empty(M->A2_COD_MUN)
	M->A2_IBGE := (M->A2_XCODES + M->A2_COD_MUN)
EndIf

RestArea(aArea)
Return lRet
