#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} F1207501
Função para adicionar o botão de Pendência de Subordinados Específico.
@author Reinaldo Dias
@since  22/04/2019
@return aRotina
@project MAN0000007423048_EF_74
@cliente Rededor
@version P12.1.17
/*/

User Function F1207501(aRotina)

	AAdd( aRotina, { 'Pendência de Subordinados Específico'	, 'U_F1207502()', 0, 0 } )
	
Return(aRotina)