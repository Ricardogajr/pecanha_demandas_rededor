/*{Protheus.doc} AE_DVMENU()
Ponto de Entrada para adicionar as opções do Banco de Conhecimento no aRotina
@Author			Nairan Alves Silva
@Since			20/09/2016
@Version		P12.7
@Project    	MAN00000463801_EF_001
@Return		Nil	 */
User Function AE_DVMENU()

U_F0400103()
AAdd( aRotina, { 'Estornar Liberação'	, 'U_AE_ESTLIB(2)', 0, 0 } )

Return 
