#include "totvs.ch"

/*/{Protheus.doc} F0702602
Função responsável por validar a alteração ou exclusão de um pedido de compra
@type User function
@author anieli.rodrigues
@since 23/01/2017
@version 12.7
@param nOperac
@project	MAN0000007423041_EF_026
@return lRet
/*/

User Function F0702602(nOperac)

	Local lInt := IsInCallStack("U_F0702601")
	Local lRet := .T.
	
	If (nOperac != 3 .And. nOperac != 2) .And. !lInt .And. SC7->C7_XORIG == "2" 
		Help(,,'EXTERNO',,'Manutenção não permitida para pedido de compra externo',1,0) 
		lRet := .F.
	EndIf 

Return lRet 