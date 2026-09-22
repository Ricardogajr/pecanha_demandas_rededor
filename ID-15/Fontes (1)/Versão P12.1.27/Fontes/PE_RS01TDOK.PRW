#Include 'Protheus.ch'

/*
{Protheus.doc} RS01TDOK()
Confirmação de dados na admissão
@Author     Bruno de Oliveira
@Since      01/04/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_006
@Return 	lRet
*/
User Function RS01TDOK()

Local lRet := .T.

lRet := U_F0100602(lRet)

Return lRet