#Include 'Protheus.ch'

/*
{Protheus.doc} RS150CDT()
Verifica se funcionário existe, se existe ele verifica demissão e motivo
Chamada no PE RS050SEL
@Author     Henrique Madureira
@Since      08/04/2016
@Version    P12.7
@Project    MAN00000462901_EF_002
@Return	 lRet
*/
User Function RS150CDT()

	Local lCont
	
	lCont := U_F0201404(.T.)
	If lCont
		lCont := U_F0100201(.T.)
	EndIf
	
Return lCont
