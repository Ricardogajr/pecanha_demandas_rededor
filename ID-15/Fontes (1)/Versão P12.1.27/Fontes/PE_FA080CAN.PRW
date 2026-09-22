#INCLUDE 'Protheus.ch'
 
/*{Protheus.doc} FA080CAN
Ponto de entrada executado no cancelamento de baixa de contas a pagar.
@author Paulo Krüger
@since 17/03/2017
@project MAN0000007423041_EF_029
*/

User Function FA080CAN() 

	Local lExecPECli := SuperGetMV("FS_EXPECLI",,.T.)
	
	U_F0702901(SE2->E2_XID)
	
	If lExecPECli .And. FindFunction("U_FSPE0011")
		U_FSPE0011()
	EndIf

Return