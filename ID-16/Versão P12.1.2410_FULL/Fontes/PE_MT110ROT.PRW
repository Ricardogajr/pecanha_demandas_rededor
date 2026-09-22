/*{Protheus.doc} MT110ROT()
Ponto de Entrada para adicionar as opções do Banco de Conhecimento no aRotina
@Author			Nairan Alves Silva
@Since			15/09/2016
@Version		P12.7
@Project    	MAN00000463801_EF_001
@Return		Nil	 */
User Function MT110ROT()

U_F0400103()

AAdd( aRotina, { 'Importa Solicitação de Compras'	, 'U_AMS00015()', 0, 0 } ) //Thais Paiva - 8313126

Return aRotina
