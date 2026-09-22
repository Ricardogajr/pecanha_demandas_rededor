#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} FCadConvBio
Cadastro da tabela P29 - Conversão de unidade de medida Bionexo.
@type function
@author Ricardo Junior
@since 20/01/2018
@version 1.0
@return Nil
/*/
*----------------------------------*
User Function FCadConvBio()
*----------------------------------*
	Private cCadastro  := "Cadastro conversão integração Bionexo X Protheus12"
	AxCadastro("P29", OemToAnsi(cCadastro))
Return 