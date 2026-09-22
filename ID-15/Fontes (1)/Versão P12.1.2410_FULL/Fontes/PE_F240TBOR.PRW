#INCLUDE 'Protheus.ch'
 
/*{Protheus.doc} F240TBOR
Ponto de entrada executado na inclusao do bordero.
@author Paulo Kruger
@since 21/03/2017
@project MAN0000007423041_EF_029
*/

User Function F240TBOR()

	Local lExecPECli := SuperGetMV("FS_EXPECLI",,.T.)

	U_F0702901(SE2->E2_XID)
	
	If lExecPECli .And. FindFunction("U_FSPE0010")
		U_FSPE0010()
	EndIf

Return