#Include 'Protheus.ch'

/*
{Protheus.doc} F0100405()
Função para a Inclusão do Botão Recusa no Documento de Entrada - PE MA103OPC
@Author     Mick William da Silva
@Since      09/05/2016
@Version    P12.7
@Project    MAN00000462901_EF_004
@Return		aRet, Vetor aRotina     
 */

User Function F0100405(aRetorno)

	Default aRetorno := {}	
	AAdd(aRetorno, {'Recusar'        , 'U_F010101A'              , 0, 3} )
	AAdd(aRetorno, {'Cancelar Recusa', 'U_F010101PCANCELARECUSA' , 0, 3} )
	AAdd(aRetorno, {'Hist. Recusa'   , 'U_F010101G'              , 0, 3})

Return aRetorno

