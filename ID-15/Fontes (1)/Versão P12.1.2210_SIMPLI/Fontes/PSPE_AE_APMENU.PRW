/*{Protheus.doc} AE_APMENU()
Ponto de Entrada para adicionar as opções do Banco de Conhecimento no aRotina
@Author			Thiago Pereira
@Since			25/07/2019
@Version		P12.17
@Project    	MAN00000463801_EF_001
@Return		Nil	 */
User Function AE_APMENU()

	AAdd( aRotina, { 'Banco Específico - Visualizar'	, 'U_F0400101(1)', 0, 0 } )
	
Return