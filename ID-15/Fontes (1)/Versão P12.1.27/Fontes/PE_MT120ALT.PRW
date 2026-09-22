#INCLUDE 'Protheus.ch'

/*{Protheus.doc} MT120ALT
Valida o registro do PC e retorna andamento do processo
@author anieli.rodrigues
@project MAN0000007423041_EF_026
@project MAN0000007423041_EF_022
@return lRet
*/

User Function MT120ALT()

	Local lRet       := .T.
	Local lExecPECli := SuperGetMV("FS_EXPECLI",,.T.)
	
	lRet := U_F0702602(PARAMIXB[1])

	If lRet
		lRet := U_F0702204(PARAMIXB[1])  //Referente à MAN0000007423041_EF_022 - Incluído por Robson William em 08/03/2017
	Endif
	
	If lExecPECli .And. lRet .And. FindFunction('U_FSPE0014')
		lRet := U_FSPE0014()
	EndIf

Return lRet

