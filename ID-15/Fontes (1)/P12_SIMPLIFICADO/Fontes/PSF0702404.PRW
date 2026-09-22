#include 'protheus.ch'

/*{Protheus.doc} F0702404
Validações nos processos para não permitir a utilização de produtos que estejam 
bloqueados na filial em questão.

•	C7_PRODUTO - Pedido de Compra
•	D3_COD     - Movimentos de Estoque
•	C1_PRODUTO - Cotação
•	C1_PRODUTO - Solicitação de compra
•	C6_PRODUTO - Pedido de Venda
•	D1_COD     - Documento de Entrada

@author Alex Sandro
@since 08/02/2017
@param cProduto - codigo do produto 
@param cFTrata  - codigo da filial de tratamento
@project MAN0000007423041_EF_024
@return NIL 
*/

User Function F0702404(cVldProd)
	Local aAreaP17  := P17->(GetArea())
	Local cReadVar  := ''//ReadVar()
	Local cProduto  := ''//If(Empty(cReadVar), "", &(cReadVar))
	Local cFTrata  := cFilAnt
 
	Default cVldProd := '' 

	If FwIsInCallStack("fExecClass")
		Return .T.
	EndIf

	if empty(cVldProd)
		IF IsBlind()
			Return .t.
		EndIf

		cReadVar := ReadVar()
		cProduto := IIf(Empty(cReadVar), "", &(cReadVar))
	else
		cProduto := cVldProd
	endif

	P17->(DbSetOrder(1))
	If ! P17->(DbSeek(xFilial('P17') + cProduto + cFTrata))
		MsgStop('Tratamento de Filial ' + cFTrata + ' ' + Alltrim(FWFilialName(cEmpAnt,cFTrata)) + ' não cadastrado!')
		RestArea(aAreaP17)
		Return .f.
	EndIf

	If P17->(P17_BLOQ $ " S")
		MsgStop('Produto Bloqueado na Filial ' + cFTrata + ' ' + Alltrim(FWFilialName(cEmpAnt,cFTrata)) + ' !')
		RestArea(aAreaP17)
		Return .f.
	EndIf

	If !IsInCallStack('U_F0703301') //Caso não venha de integração
		If IsInCallStack('MATA103') .or. IsInCallStack('MATA140')
			If P17->(P17_ESTOQ == 'S')
				MsgStop('Não é permitida a inclusão de ítens estocáveis!')
				RestArea(aAreaP17)
				Return .f.
			EndIf
		EndIf
	EndIf

	RestArea(aAreaP17)

Return .t.

