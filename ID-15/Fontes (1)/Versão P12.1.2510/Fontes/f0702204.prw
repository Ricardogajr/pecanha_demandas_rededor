#include "totvs.ch"

/*/{Protheus.doc} F0702204
Função responsável por validar a alteração de um Pedido de Compras ERP
@type User function
@author robson.william
@since 02/03/2017
@version 12.7
@param nOperac, numeric, descricao
@project	MAN0000007423041_EF_022
@return lRet
/*/
User Function F0702204(nOperac)

	Local lRet      := .T.
	Local aSC7Area  := {}
    Local cPedComp  := SC7->C7_NUM

	If nOperac == 4 
        aSC7Area := SC7->(GetArea())
		SC7->(DbSetOrder(1))
		If SC7->(DbSeek(xFilial("SC7") + cPedComp))
	        While SC7->(!Eof() .and. C7_FILIAL + C7_NUM == xFilial("SC7") + cPedComp)
	            If SC7->C7_QUJE > 0 .and. ! SC7->C7_RESIDUO == "S"
	                Help(,,'F0702204',,'Manutenção não permitida para pedido com entrega parcial',1,0) 
	                lRet := .F.
	                Exit
	            EndIf
	            SC7->(DbSkip())
	        End
		EndIf
        RestArea(aSC7Area)
	EndIf

Return lRet