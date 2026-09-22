#include "totvs.ch"

/*/{Protheus.doc} F0703305
Função responsável por validar a exclusão ou alteração de títulos do contas a pagar
@type User function
@author anieli.rodrigues
@since 20/02/2017
@version 12.7
@project	MAN0000007423041_EF_033
@return lRet
/*/

User Function F0703305()

	Local lInt := IsInCallStack("U_F0703301") .Or. FwIsInCallStack("U_F1303701") .Or. FwIsInCallStack("U_F1303702")//Integração Devolução para Ajuste em mês Fechado
	Local lRet := .T.
	
	If !lInt .And. _Opc == 5 .And. !Empty(SE2->E2_XID)   
		Help(,,"EXTERNO",,"Não é possível realizar a exclusão manual de títulos originados pela integração",1,0) 
		lRet := .F.
	EndIf 
	
Return lRet 