#include "totvs.ch"

/*/{Protheus.doc} F0702604
Manipula grupo de aprovação e saldo de pedido
@type User function
@author anieli.rodrigues
@since 23/01/2017
@version 12.7
@project	MAN0000007423041_EF_026
@return cRet
/*/

User Function F0702604()
	
	Local xRet := Nil
	Local lInt := IsInCallStack("U_F0702601")
	
	If lInt  
		xRet := "" 
	EndIf 

Return xRet 