#INCLUDE "totvs.ch"
#include "topconn.ch"

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

	If lRet
		fArrumaGV()
	EndIf

Return lRet



Static Function fArrumaGV()

	Local cUpD := ""

	PutMv("MV_HISTAPC",.F.)

	cUpD += " UPDATE "+RETSQLNAME("SGV") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE "
	cUpD += " D_E_L_E_T_ = ' ' AND GV_TIPO = 'PC' AND GV_NUM = '"+SC7->C7_NUM+"' AND GV_FILIAL = '"+SC7->C7_FILIAL+"' "

	TcSqlExec(cUpD)

Return
