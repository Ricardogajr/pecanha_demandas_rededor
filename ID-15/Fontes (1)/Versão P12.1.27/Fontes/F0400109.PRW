#INCLUDE "PROTHEUS.CH"

/*{Protheus.doc} F0400109()
Função para adicionar as opções do Banco de Conhecimento no aButtons
@Author  Rafael de Campos Falco
@Project MAN00000463801_EF_001
@param   aButtons, Vetor com as opções de menu
@Return  aButtons, Vetor com as opções de menu	 
*/

User Function F0400109(aButtons)

//	AAdd( aButtons, { 'Bco. Conhecimento'	, {|| U_F0400101(1) }, "Banco Específico - Visualizar" } )
	aAdd( aButtons, { 'Banco Específico - Visualizar'	, {|| U_F0400101(1) }, "BC Conhecimento" } )

Return( aButtons )
