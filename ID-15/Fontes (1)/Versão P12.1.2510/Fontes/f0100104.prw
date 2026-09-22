#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#Include 'TopConn.ch'

/*
{Protheus.doc} F0100104
Validação e Execução da Rotina de Medição Automatizada - Automatica
@Author		Mick William da Silva
@Since		30/06/2016
@Version	P12.7
@Project    MAN00000462901_EF_001
@param		cNumSol, Número da solicitação de compra.
@param		cItemSol, Item da solicitação de compra.
@param		lLiberacao, indica se veio da rotina de aprovação.
@param      cTipoSC, Tipo da Solicitação de Compra
@param      cCodMSC, Motivo da Solicitação de Compra
@Return		lRet, Retorna se houve erro e gerou Log, para não Setar o Status de Contrato na Solicitação de Compras(Destino F0100101)
*/
User Function F0100104(cNumSol,cItemSol,lLiberacao,cTipoSC,cCodMSC)

Return .F.	// Fonte substituido no projeto MAN0000007423045
