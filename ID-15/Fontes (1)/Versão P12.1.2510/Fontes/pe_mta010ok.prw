#Include 'Protheus.ch'

/*/{Protheus.doc} MTA010OK
Ponto de Entrada que Valida adicionais para a exclusão do produto
@type function
@author queizy.nascimento
@since 13/02/2017
@version 1.0
@project MAN0000007423041_EF_023
/*/
User Function MTA010OK()
	Local lRet := .T.

	lRet := U_F0702302()

Return lRet
