#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH"
/*---------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} F0500406
Atualização da tabela RCB e RCA
@Author     Cris
@Since      16/11/2016
@Version    P12.7
@Project    MAN0000007423039_EF_004
@Return
/*///---------------------------------------------------------------------------------------------------------------------------
User Function F0500406()

	//Inclui dados na RCB - Tabela
	AtuRCB()
	
	//Inclui dados na RCA - Mnemonico
	AtuRCA()
	
Return
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtuRCB
(long_description)
@type function
@author Cris
@since 16/11/2016
@version 1.0
@return ${return}, ${return_description}
@Project    MAN0000007423039_EF_004
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function AtuRCB()
	
	Local nFil
	Local nTamFil    := Len(cFilAnt)
	Local nTamFilRCB := Len(AllTrim(xFilial("RCB")))
	Local aTodasFil  := {}
	Local aFilRCB    := {}
	Local cFilRCB    := cFilAnt
	
	If Empty(xFilial("RCB"))
		aFilRCB := {cFilAnt}
	Else
		aTodasFil := FWAllFilial(cEmpAnt,,,.F.)
		For nFil := 1 To Len(aTodasFil)
			cFilRCB := PadR(Left(aTodasFil[nFil],nTamFilRCB),nTamFil)
			If ( AScan(aFilRCB,{|x| x == cFilRCB }) == 0 )
				AAdd(aFilRCB,cFilRCB)
			EndIf
		Next
	EndIf
	
	For nFil := 1 To Len(aFilRCB)
		RCB->(DbSetOrder(1))
		If !RCB->(DbSeek(IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil]) + "U004"))
			
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U004'
			RCB->RCB_DESC   := 'MOVIMENTACOES VS TIPO MOVIMENTACAO'
			RCB->RCB_ORDEM  := '01'
			RCB->RCB_CAMPOS := 'ALT_SALARI'
			RCB->RCB_DESCPO := 'Alteração Salarial'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 1
			RCB->RCB_DECIMA := 0 
			RCB->RCB_PICTUR := '@!'
			RCB->RCB_VALID  := 'Pertence("X| ")'
			RCB->RCB_PESQ   := '1'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())
			
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U004'
			RCB->RCB_DESC   := 'MOVIMENTACOES VS VISOES'
			RCB->RCB_ORDEM  := '02'
			RCB->RCB_CAMPOS := 'ALT_CARGO'
			RCB->RCB_DESCPO := 'Alteração de Cargo'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 1 
			RCB->RCB_DECIMA := 0 
			RCB->RCB_PICTUR := '@!'
			RCB->RCB_VALID  :=  'Pertence("X| ")'
			RCB->RCB_PESQ   := '2'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())

			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U004'
			RCB->RCB_DESC   := 'MOVIMENTACOES VS VISOES'
			RCB->RCB_ORDEM  := '03'
			RCB->RCB_CAMPOS := 'ALT_CHORA'
			RCB->RCB_DESCPO := 'Alteração de Carga Hora'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 1 
			RCB->RCB_DECIMA := 0 
			RCB->RCB_PICTUR := '@!'
			RCB->RCB_VALID  :=  'Pertence("X| ")'
			RCB->RCB_PESQ   := '2'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())

			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U004'
			RCB->RCB_DESC   := 'MOVIMENTACOES VS VISOES'
			RCB->RCB_ORDEM  := '04'
			RCB->RCB_CAMPOS := 'ALT_TURNO'
			RCB->RCB_DESCPO := 'Alteração de Turno'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 1 
			RCB->RCB_DECIMA := 0 
			RCB->RCB_PICTUR := '@!'
			RCB->RCB_VALID  :=  'Pertence("X| ")'
			RCB->RCB_PESQ   := '2'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())

			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U004'
			RCB->RCB_DESC   := 'MOVIMENTACOES VS VISOES'
			RCB->RCB_ORDEM  := '05'
			RCB->RCB_CAMPOS := 'ALT_TRANSF'
			RCB->RCB_DESCPO := 'Transferência'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 1 
			RCB->RCB_DECIMA := 0 
			RCB->RCB_PICTUR := '@!'
			RCB->RCB_VALID  :=  'Pertence("X| ")'
			RCB->RCB_PESQ   := '2'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())
			
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U004'
			RCB->RCB_DESC   := 'MOVIMENTACOES VS VISOES'
			RCB->RCB_ORDEM  := '06'
			RCB->RCB_CAMPOS := 'TIPMOV'
			RCB->RCB_DESCPO := 'Tipo Movimentação'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 3
			RCB->RCB_DECIMA := 0
			RCB->RCB_PICTUR := '@!'
			RCB->RCB_VALID  := 'If(VALIDRCC("U010", TIPMOV, 1, 3), (GDFieldPut("DESC_TPMOV",SubStr(RCC->RCC_CONTEU,4,100)),.T.),.F.)'
			RCB->RCB_PADRAO := 'FSWTMV'
			RCB->RCB_PESQ   := '2'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())
			
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U004'
			RCB->RCB_DESC   := 'MOVIMENTACOES VS VISOES'
			RCB->RCB_ORDEM  := '07'
			RCB->RCB_CAMPOS := 'DESC_TPMOV'
			RCB->RCB_DESCPO := 'Descricao'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 100
			RCB->RCB_DECIMA := 0
			RCB->RCB_PICTUR := '@!'
			RCB->RCB_VALID  := '.F.'
			RCB->RCB_PADRAO := ''
			RCB->RCB_PESQ   := '1'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())
		EndIf
		
		RCB->(DbSetOrder(3))
		If !RCB->(DbSeek(IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil]) + "ESCALON   " + "U004"))
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U004'
			RCB->RCB_DESC   := 'MOVIMENTACOES VS VISOES'
			RCB->RCB_ORDEM  := '08'
			RCB->RCB_CAMPOS := 'ESCALON'
			RCB->RCB_DESCPO := 'Merito'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 1
			RCB->RCB_DECIMA := 0
			RCB->RCB_PICTUR := '@!'
			RCB->RCB_VALID  := 'PERTENCE("S|N")'
			RCB->RCB_PADRAO := ''
			RCB->RCB_PESQ   := '2'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())		
		EndIf
		
		RCB->(DbSetOrder(3))
		If !RCB->(DbSeek(IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil]) + "TIPMOVESCA" + "U004"))
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U004'
			RCB->RCB_DESC   := 'MOVIMENTACOES VS VISOES'
			RCB->RCB_ORDEM  := '09'
			RCB->RCB_CAMPOS := 'TIPMOVESCA'
			RCB->RCB_DESCPO := 'Tipo Mov. Merito'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 3
			RCB->RCB_DECIMA := 0
			RCB->RCB_PICTUR := '@!'
			RCB->RCB_VALID  := '( VALIDRCC("U010",TIPMOVESCA,1,3)) .Or. (EMPTY(GDFieldGet ("ESCALON")) .And. EMPTY(GDFieldGet ("TIPMOVESCA"))  )'
			RCB->RCB_PADRAO := 'FSWTMV'
			RCB->RCB_PESQ   := '2'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())
		EndIf
	Next

Return 
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtuRCA
(long_description)
@type function
@author Cris
@since 16/11/2016
@version 1.0
@return ${return}, ${return_description}
@Project    MAN0000007423039_EF_004
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function AtuRCA()

	Local nFil
	Local nTamFil    := Len(cFilAnt)
	Local nTFilRCA 	 := Len(AllTrim(xFilial("RCA")))
	Local aTodasFil  := {}
	Local aFilRCA    := {}
	Local cFilRCA    := cFilAnt
	
	If Empty(xFilial("RCA"))
		aFilRCA := {cFilAnt}
	Else
		aTodasFil := FWAllFilial(cEmpAnt,,,.F.)
		For nFil := 1 To Len(aTodasFil)
			cFilRCA := PadR(Left(aTodasFil[nFil],nTFilRCA),nTamFil)
			If ( AScan(aFilRCA,{|x| x == cFilRCA }) == 0 )
				AAdd(aFilRCA,cFilRCA)
			EndIf
		Next
	EndIf
	
	For nFil := 1 To Len(aFilRCA)
		RCA->(DbSetOrder(1))
		If !RCA->(DbSeek(IIF(Empty(xFilial("RCA")),xFilial("RCA"),aFilRCA[nFil]) + "M_PERCTOL"))
		
			RCA->(RecLock("RCA", .T.))
			RCA->RCA_FILIAL := IIF(Empty(xFilial("RCA")),xFilial("RCA"),aFilRCA[nFil])
			RCA->RCA_MNEMON	:= "M_PERCTOL"
			RCA->RCA_DESC	:= "% DE TOLERANCIA P/ ENQUADRAMENTO DE FX SALARIAL"
			RCA->RCA_TIPO	:= "N"
			RCA->RCA_CONTEU	:= "3.5"
			RCA->RCA_ACUMUL	:= "3"
			RCA->(MsUnlock())
			
		EndIf
		
	Next
				
Return 