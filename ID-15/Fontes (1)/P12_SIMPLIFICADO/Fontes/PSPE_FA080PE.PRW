#INCLUDE 'Protheus.ch'
 
/*{Protheus.doc} FA080PE
Ponto de entrada executado na saida da funcao de baixa, apos gravar todos os dados e apos a contabilizacao.
@author  Paulo Krüger
@since   17/03/2017
@project MAN0000007423041_EF_029
*/

User Function FA080PE() 

	Local lExecPECli := SuperGetMV("FS_EXPECLI",,.T.)
	
	//Bloqueio de Notas Fiscais de Entrada
	U_F0702901(SE2->E2_XID)
	
	If lExecPECli .And. FindFunction("U_FSPE0012")
		U_FSPE0012()
	EndIf

Return