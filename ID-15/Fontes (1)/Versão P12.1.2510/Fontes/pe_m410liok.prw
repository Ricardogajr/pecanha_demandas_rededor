#include "totvs.ch"

/*/{Protheus.doc} M410LIOK
Validação de linha de pedido de venda
@type User function
@author anieli.rodrigues
@since 20/02/2017
@version 12.7
@project MAN0000007423041_EF_033
@return lRet
/*/

User Function M410LIOK()

	Local lRet := .T. 
	
	lRet := U_F0703304()

Return lRet
