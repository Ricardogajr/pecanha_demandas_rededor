#Include "protheus.ch"

/*/{Protheus.doc} REDA005
Programa para o "Cadastro de Log's de Erro da Integração Bionexo.
É utilizado visualizar e excluir os registros de Log de erros gerados 
durante o processamento da geração de cotações do que ainda não tinha 
sido integrada com o Bionexo no botao INTEGRAR BIONEXO ao menu de ações 
relacionadas.
@type function
@author Ricardo da Silva
@since 16/06/2017
@version 1.0
@return NIL
/*/

User Function REDA005()

Local aArea		:= GetArea()
Local _cAlias	:= "ZZX"

Private cCadastro := "Cadastro de Log's de Erro da Integração Bionexo"
Private aRotina   := {}
	
	aAdd( aRotina, { "Pesquisar" , "AxPesqui", 0, 1 } )
	aAdd( aRotina, { "Visualizar", "AxVisual", 0, 2 } )
	//aAdd( aRotina, { "Incluir"   , "AxInclui", 0, 3 } )
	//aAdd( aRotina, { "Alterar"   , "AxAltera", 0, 4 } )
	aAdd( aRotina, { "Excluir"   , "AxDeleta", 0, 5 } )
	
	DbSelectArea( _cAlias )
	( _cAlias )->( DbSetOrder(1) )
	mBrowse( 06, 01, 22, 75, _cAlias)
	
	RestArea( aArea )
	
Return( Nil )