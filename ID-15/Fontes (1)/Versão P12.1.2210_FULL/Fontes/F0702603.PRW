#include "totvs.ch"

/*/{Protheus.doc} F0702603
Função responsável por validar a eliminação de resíduos do pedido de compra
@type User function
@author anieli.rodrigues
@since 23/01/2017
@version 12.7
@param cAlias, characters, descricao
@param nArq, numeric, descricao
@project	MAN0000007423041_EF_026
@return lRet
/*/
User Function F0702603(cAlias, nArq)
	
	Local lRet := .T.
	
	If nArq == 1 .And. SC7->C7_XORIG == "2" 
		Help(,,'EXTERNO',,'Manutenção não permitida para pedido de compra externo',1,0) 
		lRet := .F.
	EndIf 

Return lRet 