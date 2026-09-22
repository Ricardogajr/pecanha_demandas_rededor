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
	
	lRet := U_F0703303()

Return lRet

