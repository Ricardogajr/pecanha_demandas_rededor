#INCLUDE "PROTHEUS.CH"

/*{Protheus.doc} F0400103()
Função para adicionar as opções do Banco de Conhecimento no aRotina
@Author			Nairan Alves Silva
@Since			15/09/2016
@Project    	MAN00000463801_EF_001
*/

User Function F0400103()
                        
	AAdd( aRotina, { 'Banco Específico - Visualizar'	, 'U_F0400101(1)', 0, 0 } )
	AAdd( aRotina, { 'Banco Específico - Incluir'		, 'U_F0400101(3)', 0, 0 } )
	AAdd( aRotina, { 'Banco Específico - Excluir'		, 'U_F0400101(5)', 0, 0 } )

Return



