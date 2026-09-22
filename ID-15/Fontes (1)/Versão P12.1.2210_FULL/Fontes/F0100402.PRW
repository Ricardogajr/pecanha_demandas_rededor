#Include 'Protheus.ch'

/*
{Protheus.doc} F0100402()
Inclusão da Legenda e Status - PE MT120COR
@Author     Mick William da Silva
@Since      05/05/2016
@Version    P12.7s
@Project    MAN00000462901_EF_004
@Return    	aNewCores 
*/
User Function F0100402()

	Local nI
	Local aNewCores	:= aClone(PARAMIXB[1])
	Local aRetCores	:= {}
	
	AAdd( aRetCores, {'C7_XSTATUS == "4" ', 'BR_VIOLETA'} )  //-- Bloqueado no Orçamento
	
	For nI := 01 To Len(aNewCores)
		AAdd( aRetCores, {aNewCores[nI][01], aNewCores[nI][02]} )
	Next

Return aRetCores
