/*{Protheus.doc} AE_FNMENU()
Ponto de Entrada para adicionar as opçõe ao menu da rotina de Departametno de Viagem (AE_FINA_AP6)
@Author			Ramon Teodoro e Silva
@Since			22/07/2024
@Version		P12.2210
@Project    	
@Return		Nil	 */
User Function AE_FNMENU()

AAdd( aRotina, { 'Estornar Adiantamento'	, 'U_AE_ESTLIB(1)', 0, 0 } )

Return 
