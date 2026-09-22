#INCLUDE 'Protheus.ch'

/*{Protheus.doc} A010TOK
Ponto de entrada para a validação para inclusão ou alteração do Produto
@author  queizy.nascimento
@since   13/02/2017
@project MAN0000007423041_EF_023
@project MAN0000007423041_EF_024 
*/
User Function A010TOK ()
	
	Local lRet       := .T.
	Local lExecPECli := SuperGetMV("FS_EXPECLI",,.T.)
	
	lRet := U_F0702301() .and.;
			U_F0702401("VLD") // Rotina para validação campos especificos de integração do produto

	If lExecPECli .And. lRet .and. FindFunction("U_FSPE0009")
		lRet := U_FSPE0009()
	EndIf

Return lRet
