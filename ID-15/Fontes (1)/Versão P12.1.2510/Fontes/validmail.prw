#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'totvs.ch'


/*/{Protheus.doc} VALIDMAIL

Rotina para realizar a validação da regra de envio automatico de email do pedido de compra

@type function
@version  
@author Sato
@since 21/05/2024
@param nRecSC7, numeric, param_description
@return variant, return_description
/*/
user function VALIDMAIL( cFilPed as Character, cPedido as Character, nRecSC7 as Numeric )

Local aArea     := GetArea()

//Local cAprovado := 'N'		// Flag de verificação se Todos os Itens do Pedido estão aprovados
Local cEnvMail  := 'N'		// Flag de verificação se ja foi Enviado de Email
Local cExterno  := 'N'		// Flag de verificação se Pedido Externo
Local cDelegada := "N"		// Flag de verificação de Compra Delegada
Local cRegular  := "N"		// Flag de verificação de Pedido de Regularização
Local cSolPgto  := 'N'		// Flag de verificação de Solicitação de Pagamento
Local cMesFech  := 'N'		// Flag de verificação de Devolução de mês fechado
Local cBionexo  := 'N'		// Flag de verificação de Pedidos Bionexo
Local cResiduo  := 'N'		// Flag de verificação de Eliminação de Residuo
//Local bConapro := .T.
Local bEnvMail := .T.
Local bExterno := .T.
Local bSolPgto := .T.
Local bMesFech := .T.
Local bBionexo := .T.
Local bResiduo := .T.

Default cFilPed := ""
Default cPedido := ""
Default nRecSC7 := 0

SC7->( dbGoTop() )
SC7->( dbSetOrder(1) )
If SC7->( dbseek( cFilPed + cPedido ) )
	Do While SC7->(!Eof()) .and. SC7->C7_FILIAL == cFilPed .and. SC7->C7_NUM == cPedido
		// Verifica se Todos os Itens do Pedido estão aprovados
		/*
		If bConapro .and. SC7->C7_CONAPRO == 'L' 
			cAprovado := 'S'
		else
			cAprovado := 'N'
			bConapro := .F.
		EndIf
		*/
		
		// Verifica se ja foi Enviado de Email para este Pedido de Compra
		If bEnvMail .and. SC7->C7_XENVMAL == "S" 
			cEnvMail := 'S'
			bEnvMail := .F.
			Exit
		else
			cEnvMail := 'N'
		EndIf
		
		// Verificação se é um Pedido Externo
		If bExterno .and. (SC7->C7_XORIG == "2" .or. SC7->C7_XORIG == "3")
			cExterno := 'S'
			bExterno := .F.
			Exit
		else
			cExterno := 'N'
		EndIf

		// Verifica se é uma Solicitação de Pagamento
		If bSolPgto .and. SC7->C7_XSOLPAG == '1'
			cSolPgto := 'S'
			bSolPgto := .F.
			Exit
		else
			cSolPgto := 'N'
		EndIf
		
		// Verifica se é uma Devolução de mês fechado
		If bMesFech .and. !Empty(SC7->C7_XIDEXNF)
			cMesFech := 'S'
			bMesFech := .F.
			Exit
		else
			cMesFech := 'N'
		EndIf
		
		// Verifica se é um Pedido Bionexo
		If bBionexo .and. !Empty(SC7->C7_XIDBIO)
			cBionexo := 'S'
			bBionexo := .F.
			Exit
		else
			cBionexo := 'N'
		EndIf
		
		// Verifica se é um Pedido de Eliminação de Residuo
		If bResiduo .and. SC7->C7_RESIDUO = 'S'
			cResiduo := 'S'
			bResiduo := .F.
			Exit
		else
			cResiduo := 'N'
		EndIf

		SC7->( dbSkip() )
	EndDo

	SC7->( DbGoto(nRecSC7) )

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
			EndDo
		EndIf
	EndIf

	If cEnvMail  == 'N' ; 				// Alteração de Pedido (Se ja foi enviado email)
		.And. cExterno  == 'N' ; 		// Pedidos Externo (nascidos no front)
		.And. cDelegada == "N" ; 		// Pedidos de Compra Delegada
		.And. cSolPgto  == "N" ; 		// Solicitação de Pagamento
		.And. cMesFech  == 'N' ; 		// Devolução de mês fechado
		.And. cBionexo  == 'N' ; 		// Pedidos Bionexo
		.And. cRegular  == "N" ; 		// Pedidos de Regularização
		.And. cResiduo  == "N"  		// Eliminação de Residuo
			
			U_DORMAILPC( nRecSC7 )

	EndIf
EndIf

RestArea(aArea)

Return
