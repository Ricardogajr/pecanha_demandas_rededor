#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'   

/*{Protheus.doc} AVALCOPC()
PE na rotina Analisa Cotacao para permitir ou n?o continuar a confirma??o da an?lise
@Author     robson william
@Since      05/04/2017
@Version    P12.7
@Project    MAN0000007423043
*/
User Function MT161OK()
	
	Local lValido    := .T.
	Local lExecPECli := SuperGetMV("FS_EXPECLI",,.T.)

	lValido := U_F0900106()
	
	If lValido
		lValido := U_F0900201(ParamIxb)
	EndIf

//  Retirado ID 1278 FSW
//	If lExecPECli .And. lValido .And. FindFunction('U_FSPE0020')
//		lValido := U_FSPE0020()
//	EndIf

Return lValido
