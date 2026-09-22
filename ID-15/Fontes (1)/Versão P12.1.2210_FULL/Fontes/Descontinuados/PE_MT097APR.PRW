#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'totvs.ch'

/*/{Protheus.doc} MT097APR

description

@type function
@version  
@author Sato
@since 22/02/2024
@return variant, return_description
/*/
user function MT097APR()

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   22/02/2024
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Envio de Email Automatico do Pedido de Compra.
// ------------------------------------
Local aArea     := GetArea()
Local cDelegada := "N"		// Flag de verificação de Compra Delegada
Local cRegular  := "N"		// Flag de verificação de Pedido de Regularização
Local cLiberado := 'N'		// Flag de verificação de Todos os Itens do Pedido
Local cPedido   := SC7->C7_NUM
Local dDtLibera := GetAdvFval("SCR", "CR_DATALIB", SC7->C7_FILIAL+"PC"+cPedido, 1, CTOD("  /  /    "))
Local nRegSc7   := SC7->( Recno() )

Do While SC7->(!Eof()) .and. SC7->C7_FILIAL == cFilAnt .and. SC7->C7_NUM == cPedido
	If SC7->C7_CONAPRO = 'L'
		cLiberado := 'S'
	else
		cLiberado := 'N'
		Exit
	EndIf
	SC7->( dbSkip() )
EndDo

If cLiberado == 'S' .And. SC7->C7_XENVMAL <> "S" .And. SCR->CR_DATALIB == dDtLibera

	SC7->( dbGoto(nRegSc7) )

	dbSelectArea("SAJ")
	SAJ->( dbSetOrder(2) )     // AJ_FILIAL + AJ_USER
	SAJ->( dbGoTop() )
	If dbseek( SC7->C7_FILIAL + SC7->C7_USER )
		Do While SAJ->( !EOF() ) .AND. SAJ->AJ_FILIAL == SC7->C7_FILIAL .AND. SAJ->AJ_USER == SC7->C7_USER
			If SAJ->AJ_GRCOM = "000006"
				cDelegada := "S"
				Exit
			EndIf
			SAJ->( dbSkip() )
		EndDo
	EndIf

	If !Empty(SC7->C7_NUMSC)
		dbSelectArea("SC1")
		SC1->( dbSetOrder(1) )     // C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD
		SC1->( dbGoTop() )
		If dbseek( SC7->C7_FILIAL + SC7->C7_NUMSC )
			Do While SC1->( !EOF() ) .AND. SC1->C1_FILIAL == SC7->C7_FILIAL .AND. SC1->C1_NUM == SC7->C7_NUMSC
				If SC1->C1_XTPSC $ "04|08|09|13|18|21|36"
					cRegular := "S"
				EndIf
				Exit
				//SAJ->( dbSkip() )
			EndDo
		EndIf
	EndIf

	If SCR->CR_TIPO == "PC" ; 									
	.And. SC7->C7_XORIG <> "2"; 				// Pedidos Externo (nascidos no front)
	.And. SC7->C7_XORIG <> "3"; 				// Pedidos Externo (nascidos no front)
	.And. cDelegada == "N" ; 					// Pedidos de Compra Delegada
	.And. SC7->C7_XSOLPAG == "2"; 				// Solicitação de Pagamento
	.And. Empty(SC7->C7_XIDEXNF) ; 				// Devolução de mês fechado
	.And. Empty(SC7->C7_XPEDBIO) ; 				// Pedidos Bionexo
	.And. Empty(SC7->C7_XIDBIO) ; 				// Pedidos Bionexo
	.And. SC7->C7_XENVMAL <> "S" ; 				// Alteração de Pedido
	.And. cRegular == "N"  						// Pedidos de Regularização
		
		U_DORMAILPC( nRegSc7 )

	EndIf
EndIf
// ------------------------------------

RestArea(aArea)

Return
