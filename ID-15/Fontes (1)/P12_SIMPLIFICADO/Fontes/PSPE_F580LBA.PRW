#INCLUDE 'Protheus.ch'

/*
{Protheus.doc} F580LBA()
Ponto de Entrada F580LbA que efetua ou não o bloqueio da liberação automática dos títulos a pagar. 
O retorno deve ser  .T. ou .F.
@Author     Paulo Krüger
@Since      20/01/2017
@Version    P12.7
@Project    MAN00000462901_EF_010
*/

User Function F580LBA()

	Local lLiberado  := .T.
	Local lExecPECli := SuperGetMV("FS_EXPECLI",,.T.)
	
	lLiberado := U_F010101N()
	
	If lExecPECli .And. lLiberado .and. FindFunction("U_FSPE0007")
	    lLiberado := U_FSPE0007()
	EndIf

Return lLiberado
