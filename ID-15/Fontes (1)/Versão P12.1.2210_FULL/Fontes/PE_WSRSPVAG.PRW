#Include 'Protheus.ch'

/*
{Protheus.doc} WSRSPVAG()
Validação de apresentação de vaga
@Author     Bruno de Oliveira
@Since      09/01/2017
@Version    P12.1.07
@Project    MAN00000462901_EF_003
*/
User Function WSRSPVAG()

	Local cCodVag := PARAMIXB[1]
	
	//Valida pelos parametros se essa empresa irá executar essas chamadas.
	If !U_VALIDEMP()
		Return .T.
	EndIf
	
	lRet := U_F0100328(cCodVag)

Return lRet