/*{Protheus.doc} MA103OPC()
Ponto de Entrada para adicionar as opções do Banco de Conhecimento no aRotina
@Author			Nairan Alves Silva
@Since			15/09/2016
@Version		P12.7
@Project    	MAN00000463801_EF_001
@Return		Nil	 */
User Function MA103OPC()
    
    Local aRotina := ParamIxb
    aRotina := U_F0400104(aRotina)
    aRotina := U_F0100405(aRotina)

Return aRotina