/*{Protheus.doc} FA550BUT()
Ponto de Entrada para adicionar as opções do Banco de Conhecimento no aRotina
@Author			Nairan Alves Silva
@Since			16/09/2016
@Version		P12.7
@Project    	MAN00000463801_EF_001
@Return		Nil	 */
User Function FA550BUT()
Local aRotina := aClone(PARAMIXB[01])

aRotina := U_F0400104(aRotina)

Return aRotina