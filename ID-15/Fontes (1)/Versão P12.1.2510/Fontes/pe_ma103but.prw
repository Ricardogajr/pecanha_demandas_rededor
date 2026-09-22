#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} MA103BUT()
Permite ao usuário adicionar opções na barra de menus EnchoiceBar
Localização: Function MATA103 - Rotina responsável pelo Documento de Entrada
Em que ponto: Na abertura do documento.
@return		aButtons, novos botões adicionados
@author 	CDE PRIVATE
@since 		25/05/2018
@version 	1.0
@project	REDE'DOR
*/
User Function MA103BUT()

	Local aButtons := {}

//	AAdd( aButtons, { 'Bco. Conhecimento'	, {|| U_F0400101(1) }, "Banco Específico - Visualizar" } )
	aAdd( aButtons, { 'Banco Específico - Visualizar',{|| U_F0400101(1) },"BC Conhecimento"})
	aButtons := U_F1205504(aButtons)
	If INCLUI
		aAdd( aButtons, { 'Exceção de data fixa.',{|| U_fxDtFX1() },"Exceção de data fixa."})
	ElseIf (ALTERA .AND. SF1->F1_XSOLPAG <> "1")
		aAdd( aButtons, { 'Exceção de data fixa.',{|| U_fxDtFX1() },"Exceção de data fixa."})
	EndIf
Return (aButtons)
