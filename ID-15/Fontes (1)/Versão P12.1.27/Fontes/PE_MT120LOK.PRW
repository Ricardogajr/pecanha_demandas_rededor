#include "totvs.ch"

/*/{Protheus.doc} MT120LOK
Validação de cada linha da GetDados do Pedido de Compras / Autorização de Entrega
@type User function
@author robson.william
@since 23/01/2017
@version 12.7
@param
@project MAN0000007423041_EF_022
@return lRet
/*/

User Function MT120LOK()

Local lRet := .T. 

lRet := U_F0702202()

Return lRet

