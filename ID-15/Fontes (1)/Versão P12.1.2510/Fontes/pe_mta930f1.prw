#include "totvs.ch"

/*/{Protheus.doc} MTA930F1
Inserção de filtros adicionais no processamento dos livros fiscais
@type User function
@author anieli.rodrigues
@since 20/02/2017
@version 12.7
@param PARAMIXB[1], caractere, alias da query processada pela rotina padrão
@project MAN0000007423041_EF_033
@return cRet
/*/

User Function MTA930F1()

	Local lRet := .T.  
	
	lRet := U_F0703306(PARAMIXB[1])

Return lRet
