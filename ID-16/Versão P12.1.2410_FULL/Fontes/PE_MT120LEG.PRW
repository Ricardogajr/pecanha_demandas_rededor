#Include 'Protheus.ch'
/*
{Protheus.doc} MT120LEG()
Ponto de Entrada para alteração da Legenda dos Pedidos de Compra
PE no fonte MATA120
@Author     Mick William da Silva
@Since      05/05/2016
@Version    P12.7
@Project    MAN00000462901_EF_004
@Return		aRet, Vetor de Cores     
*/
User Function MT120LEG()

	Local aNewLegenda := {}
	Local lExecPECli  := SuperGetMV("FS_EXPECLI",,.T.)

	aNewLegenda := U_F0100403()
	
	IF lExecPECli .And. FindFunction('U_FSPE0018')
		ParamIXB[1] := AClone(aNewLegenda)
		aNewLegenda := U_FSPE0018()
	EndIf

Return aNewLegenda

