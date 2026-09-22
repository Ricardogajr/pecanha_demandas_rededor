#INCLUDE 'PROTHEUS.CH'

// -----------------------------------------------------------------------
// {Protheus.doc} F0400104()
// Função para adicionar as opções do Banco de Conhecimento no aRotina
// @Author  Nairan Alves Silva
// @Project MAN00000463801_EF_001
// @param   aRotina , Vetor com as opções de menu
// @Return  aRotina , Vetor com as opções de menu	 
// -----------------------------------------------------------------------

user function f0400104( aRotina )
// ----------------------------------------------
//  Local lBloq := OAPP:CMODNAME $ supergetmv( 'FS_XBLOQCP' , , .T. )
	local lBloq := OAPP:CMODNAME $ supergetmv( 'FS_XBLOQCP' , , .T. ) .AND. ;
		Funname() == 'FINA050'
// ----------------------------------------------
	aadd(     aRotina , { 'Banco Específico - Visualizar' , 'u_f0400101(1)' , 0 , 0 } )
	AAdd( aRotina, { 'Relatório de recusas'       , 'U_AMSREL001()', 0,0  } )
	if !lBloq
		aadd( aRotina , { 'Banco Específico - Incluir'    , 'u_f0400101(3)' , 0 , 0 } )
		aadd( aRotina , { 'Banco Específico - Excluir'    , 'u_f0400101(5)' , 0 , 0 } )
	endif
// ----------------------------------------------
	If (Funname() == 'FINA050' .OR. Funname() == 'FINA750')
		aadd( aRotina , { 'Rel. Produtos Serviço'                  , 'U_MSRELB1'    , 0 , 0 } )
	EndIf
	if funname() <> 'MATA094'
		aadd( aRotina , { 'Hist. Recusa'                  , 'u_f010101g'    , 0 , 3 } )
	endif
// ----------------------------------------------
return aRotina

// -----------------------------------------------------------------------
// [ fim de f0400104.prw ]
// -----------------------------------------------------------------------
