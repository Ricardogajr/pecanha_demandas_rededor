#INCLUDE "PROTHEUS.CH"

/*
{Protheus.doc} RS050SEL()
Ponto de entrada de marcação no listbox
@Author     Henrique Madureira
@Since      08/04/2016
@Version    P12.7
@Project    MAN00000462901_EF_002
@Return	 	lCont, Resultado de validação de marcação no markbrowse
*/
User Function RS050SEL()
		
	Local lCont
	
	lCont := U_F0201404()
	If lCont
		lCont := U_F0100201()
	EndIf
Return lCont
