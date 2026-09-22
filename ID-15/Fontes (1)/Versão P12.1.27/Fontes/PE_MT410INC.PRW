#Include 'Protheus.ch'

/*
{Protheus.doc} MT410INC()
Ponto de Entrada para a Automatização da Emissão das Notas Fiscais
@Author     Mick William da Silva
@Since      25/04/2016
@Version    P12.7
@Project    MAN00000463301_EF_012
@Param      
@Return     
*/

User Function MT410INC()
	Local lRet:= .T.
	//IF FindFunction('U_F0201201') - Nairan - Alterado no dia 27/12/16 por solicitação do Carlão.
	//	MsgRun("Processando Pedido para Transmissão. Aguarde",,{|| lRet := U_F0201201()})		
	//EndIF
Return lRet

