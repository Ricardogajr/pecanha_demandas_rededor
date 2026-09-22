#include 'protheus.ch'
  
/*{Protheus.doc} F0900103
Validações na digitação do codigo do produto para restringir o uso dos produtos que são controlados pelo planejamento compras.

@author Alex Sandro
@since 11/05/2017
@project MAN0000007423043_EF_001
@return NIL
*/
 
User Function F0900103(cProduto)
	Local aAreas    := { SB1->(GetArea('SB1')), SAJ->(GetArea('SAJ')), P21->(GetArea('P21')), GetArea() }
	Local cReadVar  := ReadVar()
	Local cTipo     := ""
	Local cUsoCom   := RetCodUsr()
	Local lTemGrupo := .F.

	DEFAULT cProduto  := If(Empty(cReadVar), "", &(cReadVar))
	
	cTipo := Posicione('SB1', 01, xFilial('SB1') + cProduto, 'B1_GRUPO')

	If IsInCallStack("U_F0100401")	// Quando PC originado de Solicitação de Pagamento.
		lTemGrupo := .T.
	EndIf
	
	If IsInCallStack('U_F1200709')	// Quando PC originado de Medição Automática.
		lTemGrupo := .T.
	EndIf
	
	If IsInCallStack('MATA094')     // Quando originado de aprovação de Medição.
		If SCR->CR_TIPO == 'MD'
			lTemGrupo := .T.
		EndIf	
	EndIf
	
	If IsInCallStack('U_F0702601')	// Quando pedidos de compras externos.
		lTemGrupo := .T.
	EndIf

	If IsInCallStack('U_REDSCH1')	// Quando pedidos de compras Bionexo.
		lTemGrupo := .T.
	EndIf

	If FwIsInCallStack("U_F1304301")   //Ignora quando vier do WS de Estorno de Nota Fiscal em Mês Fechado
        lTemGrupo := .T.
    EndIf

    If FwIsInCallStack("U_F1304901")   //Ignora quando vier da rotina de alteração de Fornecedor Customizada
        lTemGrupo := .T.
    EndIf

	If FwIsInCallStack("U_RDCAR02")   //Carga da SP
        lTemGrupo := .T.
    EndIf

    If  !EMPTY(GDFieldGet ( "C7_XIDEXNF" , N ,.F. , ,  )) 
		lTemGrupo := .T.
	EndIf



	If !lTemGrupo

		Begin Sequence
		
			If Empty(cTipo)
				Help( , , 'F0900103', , 'Tipo de Produto não cadastrado!', 1, 0 )
				Break
			EndIf 
			
			SAJ->(DbSetOrder(2))
			If !SAJ->(DbSeek(xFilial('SAJ') + cUsoCom))
				Help( , , 'F0900103',,'Usuário sem Grupo de compras!', 1, 0, , , , , , {"Solicite seu cadastro para a equipe responsável."} )
				Break
			EndIf
			
			P21->(DbSetOrder(1))
			While SAJ->(!Eof()) .And. ( xFilial('SAJ') + cUsoCom ) == SAJ->(AJ_FILIAL+AJ_USER)
				If P21->(DbSeek(xFilial('P21') + cTipo + SAJ->AJ_GRCOM ))
					lTemGrupo := .T.
					Exit
				EndIf
				SAJ->(DbSkip())
			EndDo
		
			If !lTemGrupo .AND. EMPTY(GDFieldGet ( "C7_NUMSC" , N ,.F. , ,  )) 
				Help( , , 'F0900103', , 'Produto escolhido não pertence a um grupo de compras do usuário!', 1, 0)
				Break
			EndIf
		
		End Sequence	
	
	EndIf
	
	AEval(aAreas,{|aArea| RestArea(aArea) })
	
Return lTemGrupo
