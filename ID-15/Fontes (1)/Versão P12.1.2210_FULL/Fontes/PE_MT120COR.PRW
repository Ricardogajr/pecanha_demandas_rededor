#INCLUDE 'Protheus.ch'
/*
{Protheus.doc} MT120COR()
Ponto de Entrada para alteração do Status (legenda de Pedidos de Compra)
PE no fonte MATA120
@Author     Mick William da Silva
@Since      05/05/2016
@Version    P12.7
@Project    MAN00000462901_EF_004
@Return		aPECores, vetor de cores      
*/

User Function MT120COR()

	Local aPECores   := {}
	Local lExecPECli := SuperGetMV("FS_EXPECLI",,.T.)

	aPECores := U_F0100402()
	
	IF lExecPECli .And. FindFunction('U_FSPE0017')
		ParamIXB[1] := AClone(aPECores)
		aPECores        := U_FSPE0017()
	EndIf
		
Return aPECores

