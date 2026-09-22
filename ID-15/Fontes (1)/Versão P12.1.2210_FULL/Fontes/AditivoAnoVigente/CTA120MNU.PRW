#Include 'Protheus.ch'

User Function CNT121BT()

	If Type('aRotina') == 'A'
		aadd( aRotina , { 'Banco Específico - Incluir'    , 'u_f0400101(3)' , 0 , 0 } )
		aadd( aRotina , { 'Banco Específico - Visualizar' , 'u_f0400101(1)' , 0 , 0 } )
		aadd( aRotina , { 'Banco Específico - Excluir'    , 'u_f0400101(5)' , 0 , 0 } )
	Endif
Return

Return 
 