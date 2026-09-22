#INCLUDE "totvs.ch"

/*{Protheus.doc} MT235G2
Ponto de entrada de validação antes do processamento da eliminação de resíduos
@author  anieli.rodrigues
@since   23/01/2017
@project MAN0000007423041_EF_026
@return  lRet
*/

User Function MT235G2()

	Local lRet       := .T. 
	Local lExecPECli := SuperGetMV("FS_EXPECLI",,.T.)
	
	lRet := U_F0702603(PARAMIXB[1], PARAMIXB[2])

	If lExecPECli .And. lRet .and. FindFunction("U_FSPE0008")
		lRet := U_FSPE0008()
	EndIf

	If lExecPECli .And. lRet .and. FindFunction("U_FSPE0025")
		lRet := U_FSPE0025()
	EndIf

Return lRet
