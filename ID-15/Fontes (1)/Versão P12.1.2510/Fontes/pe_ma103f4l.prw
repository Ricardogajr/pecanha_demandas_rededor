#Include 'Protheus.ch'

/*
{Protheus.doc} MA103F4L()
Alteração de pedidos
@Author  Fabrica de Software
@Since   27/08/2018
@Project MAN0000007423048_EF_055
@Param   cQuery, caracter, consulta padrão
@Param   nOpc, numerico, tipo 1=Pedido; 2=Item Ped.
@Return  cRetQry, consulta customizada.
*/
User Function MA103F4L()

	U_F1205504(PARAMIXB[1],PARAMIXB[2])

Return