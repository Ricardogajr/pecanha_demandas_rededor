#include 'protheus.ch'
#include 'apwebsrv.ch'

/*/{Protheus.doc} F0700601
Função para Excluir o Local de Estoque
@type function
@author queizy.nascimento
@since 26/01/2017
@version 1.0
@param LocalEstoqueID, ${param_type}, (Descrição do parâmetro)
@Project MAN0000007423041_EF_006
/*/
User Function F0700601(LocalEstoqueID)
	Local cRetorno := ""
	Local aCampos  := {}
	Local cFil:= ""

	aCampos := {;
		{"NNR_FILIAL", LocalEstoqueID:cFil},;
		{"NNR_CODIGO", LocalEstoqueID:cCodigo}}

	cRetorno  := U_F0700006 ("NNR", {2}, "AGRA045", 1, aCampos )
    
	aCampos := ASize(aCampos,0)
	aCampos := Nil

Return cRetorno