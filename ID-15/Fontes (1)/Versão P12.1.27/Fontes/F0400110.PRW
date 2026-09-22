#INCLUDE "PROTHEUS.CH"

/*{Protheus.doc} F0400110()
Função para adicionar as opções do Banco de Conhecimento no aButtons
@Author  Rafael de Campos Falco
@Project MAN00000463801_EF_001
@param   aButtons, Vetor com as opções de menu
@Return  aButtons, Vetor com as opções de menu	 
*/

User Function F0400110()

	Local aButtons := {}
	
//	aButtons := {"Banco Específico - Visualizar", "BC Conhecimento", { || U_F0400101(1) }, "Banco Específico - Visualizar" }
	aButtons := {"Bco. Conhecimento", "Banco Específico - Visualizar", { || U_F0400101(1) }, "Bco. Conhecimento" }
	
Return ( aButtons )
