#Include 'Protheus.ch'
/*
{Protheus.doc} F0100403()
Inclusão da Legenda - PE MT120LEG
@Author     Mick William da Silva
@Since      05/05/2016
@Version    P12.7
@Project    MAN00000462901_EF_004
@Param      
@Return     
*/
User Function F0100403()
	
	Local aNewLegenda  := aClone(PARAMIXB[1])
	
	AAdd( aNewLegenda, {"BR_VIOLETA", "Bloqueado no Orçamento"} )
	
Return aNewLegenda
