#INCLUDE 'Protheus.ch'

/*/{Protheus.doc} MT120GRV

Localização... : Function A120Pedido - Rotina de Inclusão, Alteração, Exclusão e Consulta dos Pedidos de Compras e Autorizações de Entrega.
Finalidade.... : O  ponto de entrada MT120GRV utilizado para continuar ou não a Inclusão, alteração ou exclusão do Pedido de Compra ou Autorização de Entrega.
Programa Fonte : MATA120.PRX
Sintaxe....... : MT120GRV - Continuar ou não a inclusão, alteração ou exclusão ( [ ParamIxb[1] ], [ ParamIxb[2] ], [ ParamIxb[3] ], [ ParamIxb[4] ] ) --> lRet

@type function
@version  
@author Sato
@since 23/08/2024
@return variant, return_description
/*/


User Function MT120GRV()

Local aAreaSC7  as Array

Local cFilPed 	as Character
Local cNumPed   as Character
Local lInclui   as Logical
Local lAltera   as Logical
Local lDeleta   as Logical
Local lMt120Grv as Logical
Local nOper 	as Numeric
Local cGrupCom 	as Character
Local cCodUser 	as Character
Local nContGrp	as Numeric
Local cSubTit 	as Character

Local cSolPag 	as Character
Local cContra 	as Character
Local cMedicao 	as Character
Local cConapro 	as Character

aAreaSC7    := SC7->( GetArea() )

cFilPed  	:= FwCodFil()
cNumPed     := PARAMIXB[1]
lInclui     := PARAMIXB[2]
lAltera     := PARAMIXB[3]
lDeleta     := PARAMIXB[4]
lMt120Grv   := .T.
cGrupCom 	:= ''
cCodUser 	:= ''
nOper 		:= 0
nContGrp    := 0
cSubTit 	:= ''

cSolPag 	:= aCols[1,aScan(aHeader, {|x| AllTrim(x[2]) == "C7_XSOLPAG"})]
cContra 	:= aCols[1,aScan(aHeader, {|x| AllTrim(x[2]) == "C7_CONTRA"})]
cMedicao 	:= aCols[1,aScan(aHeader, {|x| AllTrim(x[2]) == "C7_MEDICAO"})]
cConapro 	:= SC7->C7_CONAPRO


If cSolPag == "2" .and. Empty(cContra) .and. Empty(cMedicao)
	If lInclui
		nOper := 1
	ElseIf lAltera
		nOper := 2
	ElseIf lDeleta
		nOper := 3
	Endif

	cCodUser := RetCodUsr()

	dbSelectArea("SAJ")
	SAJ->( dbSetOrder(2) )     // AJ_FILIAL + AJ_USER
	SAJ->( dbGoTop() )
	If dbseek( cFilPed + cCodUser )
		Do While SAJ->( !EOF() ) .AND. SAJ->AJ_FILIAL == cFilPed .AND. SAJ->AJ_USER == cCodUser
			cGrupCom := SAJ->AJ_GRCOM
			nContGrp++
			SAJ->( dbSkip() )
		EndDo
		
	EndIf

	If nContGrp == 1 .and. cGrupCom == '000006'
		DO CASE
			CASE nOper = 1
					cSubTit := OemToAnsi("Formulário de Compra Delegada - Inclusão")
			CASE nOper = 2
					cSubTit := OemToAnsi("Formulário de Compra Delegada - Alteração")
			CASE nOper = 3
					cSubTit := OemToAnsi("Formulário de Compra Delegada - Exclusão")
		ENDCASE
		If lInclui
			//MSGINFO( "Processo de Compra Delegada"+chr(13)+chr(10)+"para continuar, deve-se preencher o formulário a seguir.", "Pedido de Compra Delegada" )
			// AVISO(<cTitulo>, <cMensagem>, <aBotoes>, <nTamTela>, <cSubTitulo>, <nRotAut>, <cBitmap>, <lEditMemo>, <nTimer>)
			AVISO( "Atenção", "Processo de Compra Delegada"+chr(13)+chr(10)+"para continuar, deve-se preencher o formulário a seguir.", {"Seguir"}, 2, cSubTit, , "BR_AZUL")
			lMt120Grv := u_FORMDELEG( cFilPed, cNumPed, nOper )
		ElseIf lAltera
			//MSGINFO( "Processo de Compra Delegada"+chr(13)+chr(10)+"para continuar, deve-se preencher o formulário a seguir.", "Pedido de Compra Delegada" )
			// AVISO(<cTitulo>, <cMensagem>, <aBotoes>, <nTamTela>, <cSubTitulo>, <nRotAut>, <cBitmap>, <lEditMemo>, <nTimer>)
			//AVISO( "Atenção", "Processo de Compra Delegada"+chr(13)+chr(10)+"para continuar, deve-se preencher o formulário a seguir.", {"Seguir"}, 2, cSubTit, , "BR_AZUL")
			DbSelectArea("SZ7")
			SZ7->( DbSetOrder(2) )
			SZ7->( DbGoTop() )
			If DbSeek(cFilPed+cNumPed)
				If MSGYESNO( "Voce deseja editar o Formulário?", cSubTit )
					lMt120Grv := u_FORMDELEG( cFilPed, cNumPed, nOper )
				Else
					lMt120Grv := .T.
				EndIf
			Else
				AVISO( "Atenção", "Processo de Compra Delegada"+chr(13)+chr(10)+"para continuar, deve-se preencher o formulário a seguir.", {"Seguir"}, 2, cSubTit, , "BR_AZUL")
				lMt120Grv := u_FORMDELEG( cFilPed, cNumPed, nOper )
			EndIf
		ElseIf lDeleta
			DbSelectArea("SZ7")
			SZ7->( DbSetOrder(2) )
			SZ7->( DbGoTop() )
			If DbSeek(cFilPed+cNumPed)
				//MSGINFO( "O Pedido de Compra "+cNumPed+" possue Formulário vinculado."+chr(13)+chr(10)+"Para realizar a excluisão do Pedido de Compra, deve-se excluir o formulário a seguir.", "Pedido de Compra Delegada" )
				// AVISO(<cTitulo>, <cMensagem>, <aBotoes>, <nTamTela>, <cSubTitulo>, <nRotAut>, <cBitmap>, <lEditMemo>, <nTimer>)
				AVISO( "Atenção", "O Pedido de Compra "+cNumPed+" possue Formulário vinculado."+chr(13)+chr(10)+"Para realizar a excluisão do Pedido de Compra, deve-se excluir o formulário a seguir.", {"Seguir"}, 2, cSubTit, , "BR_AZUL")
				lMt120Grv := u_FORMDELEG( cFilPed, cNumPed, nOper )
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaSC7)

Return lMt120Grv
