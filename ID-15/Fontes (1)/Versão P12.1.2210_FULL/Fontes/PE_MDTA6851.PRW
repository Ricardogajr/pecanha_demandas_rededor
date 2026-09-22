#Include 'Protheus.ch'

/*
{Protheus.doc} MDTA6851()
Ponto de entrada que permite a criação de própria regra de validação no momento de Incluir, Alterar e Excluir
@Author     Bruno de Oliveira
@Since      15/04/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_007
@Return 	lRet
*/
User Function MDTA6851()

Local lRet := .T.
Local nOpc := ParamIXB[1]

lRet := U_F0100701(lRet,nOpc)

Return lRet

