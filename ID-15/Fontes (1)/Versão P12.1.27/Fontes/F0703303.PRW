#include "totvs.ch"

/*/{Protheus.doc} F0703303
Função responsável por validar a exclusão de notas fiscais de entrada
@type User function
@author anieli.rodrigues
@since 23/01/2017
@version 12.7
@project	MAN0000007423041_EF_033
@return lRet
/*/

User Function F0703303()

	Local lInt := IsInCallStack("U_F0703301") .Or. FwIsInCallStack("U_F1303701") .Or. FwIsInCallStack("U_F1303702")//Integração Devolução para Ajuste em mês Fechado
	Local lRet := .T.
	
	If !lInt .And. !Empty(SF1->F1_XID)  
		Help(,,'EXTERNO',,'Não é possível realizar a exclusão manual de documentos originados pela integração',1,0) 
		lRet := .F.
	EndIf 

Return lRet 