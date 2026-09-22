#Include 'Protheus.ch'

/*
{Protheus.doc} MT103QPC()
Manipular query ao selecionar Pedido de Compras no Documento de Entrada
@Author  Fabrica de Software
@Since   24/08/2018
@Project MAN0000007423048_EF_055
@Param   cQuery, caracter, consulta padrão
@Param   nOpc, numerico, tipo 1=Pedido; 2=Item Ped.
@Return  cRetQry, consulta customizada.
*/
User Function MT103QPC()

	Local cQuery  := PARAMIXB[1]
	Local nOpc    := PARAMIXB[2]
	Local cRetQry := ""
	
	cRetQry := U_F1205505(cQuery,nOpc)

Return cRetQry