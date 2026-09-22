#INCLUDE 'Protheus.ch'
 
/*{Protheus.doc} FA080PE
Ponto de entrada executado na saida da funcao de baixa, apos gravar todos os dados e apos a contabilizacao.
@author  Paulo Krüger
@since   17/03/2017
@project MAN0000007423041_EF_029
*/

User Function FA080PE() 

	Local lExecPECli := SuperGetMV("FS_EXPECLI",,.T.)
	Local cUsrAlt  := UsrFullName(__cUserId)
	Local lFilSimp := U_VALSIMP(cFilAnt)
	//Bloqueio de Notas Fiscais de Entrada
	U_F0702901(SE2->E2_XID)
	
	If lExecPECli .And. FindFunction("U_FSPE0012")
		U_FSPE0012()
	EndIf

	if !lFilSimp
		// ticket n° 12912589
		If SE5->E5_RECPAG == 'P'	
			RecLock("SE5", .F. )
			SE5->E5_XLOGMOV  := cUsrAlt
			SE5->E5_XHORMOV  := TIME() 
			SE5->E5_XDATMOV  := DATE() 
			MsUnlock()
		EndIf 
	endif

Return
