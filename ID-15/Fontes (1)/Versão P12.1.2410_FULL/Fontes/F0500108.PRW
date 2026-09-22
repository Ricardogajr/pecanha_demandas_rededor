#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH"
/*
{Protheus.doc} F0500108()
Atualização da tabela RCB
@Author     Roberto Souza
@Since      08/11/2016
@Version    P12.7
@Project    MAN0000007423039_EF_00101
@Return
*/
User Function F0500108()
	
	Local nFil
	Local nTamFil    := Len(cFilAnt)
	Local nTamFilRCB := Len(AllTrim(xFilial("RCB")))
	Local nTFilRCC 	 := Len(AllTrim(xFilial("RCC")))
	Local aTodasFil  := {}
	Local aFilRCB    := {xFilial("RCB")}
	Local cFilRCB    := cFilAnt
	Local aFilRCC    := {}
	Local cFilRCC    := ""
	
	aTodasFil := FWAllFilial(cEmpAnt,,,.F.)
	For nFil := 1 To Len(aTodasFil)
		cFilRCB := PadR(Left(aTodasFil[nFil],nTamFilRCB),nTamFil)
		If ( AScan(aFilRCB,{|x| x == cFilRCB }) == 0 )
			AAdd(aFilRCB,cFilRCB)
		EndIf
	Next
	
	For nFil := 1 To Len(aFilRCB)
		RCB->(DbSetOrder(1))
		If !RCB->(DbSeek(IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil]) + "U006"))
			
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U006'
			RCB->RCB_DESC   := 'CODIGO RESCISAO'
			RCB->RCB_ORDEM  := '01'
			RCB->RCB_CAMPOS := 'CODIGO'
			RCB->RCB_DESCPO := 'Código Rescisão'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 3// N
			RCB->RCB_DECIMA := 0// N
			RCB->RCB_PICTUR := '999'
			RCB->RCB_PESQ   := '1'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())
			
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U006'
			RCB->RCB_DESC   := 'CODIGO RESCISAO'
			RCB->RCB_ORDEM  := '02'
			RCB->RCB_CAMPOS := 'DESCRICAO '
			RCB->RCB_DESCPO := 'Descrição Rescisão'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 30// N
			RCB->RCB_DECIMA := 0// N
			RCB->RCB_PICTUR := '@!'
			RCB->RCB_PADRAO := ''
			RCB->RCB_PESQ   := '1'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())			
			
		EndIf
	Next
	
	If Empty(xFilial("RCC"))
		aFilRCC := {cFilAnt}
	Else
		For nFil := 1 To Len(aTodasFil)
			cFilRCC := PadR(Left(aTodasFil[nFil],nTFilRCC),nTamFil)
			If ( AScan(aFilRCC,{|x| x == cFilRCC }) == 0 )
				AAdd(aFilRCC,cFilRCC)
			EndIf
		Next
	EndIf
	
	For nFil := 1 To Len(aFilRCC)
		RCC->(DbSetOrder(1))
		If !RCC->(DbSeek(IIF(Empty(xFilial("RCC")),xFilial("RCC"),aFilRCC[nFil]) + "U006"))
			
			RecLock("RCC",.T.)
			RCC->RCC_FILIAL := IIF(Empty(xFilial("RCC")),xFilial("RCC"),aFilRCC[nFil])
			RCC->RCC_CODIGO	:= "U006"
			RCC->RCC_SEQUEN := "001"	
			RCC->RCC_CONTEU := "001OBITO"	
			RCC->(MsUnlock())
			
			RecLock("RCC",.T.)
			RCC->RCC_FILIAL := IIF(Empty(xFilial("RCC")),xFilial("RCC"),aFilRCC[nFil])
			RCC->RCC_CODIGO	:= "U006"
			RCC->RCC_SEQUEN := "002"	
			RCC->RCC_CONTEU := "002PEDIDO DE DEMISSAO"	
			RCC->(MsUnlock())
			
			RecLock("RCC",.T.)
			RCC->RCC_FILIAL := IIF(Empty(xFilial("RCC")),xFilial("RCC"),aFilRCC[nFil])
			RCC->RCC_CODIGO	:= "U006"
			RCC->RCC_SEQUEN := "003"	
			RCC->RCC_CONTEU := "003TERMINO DE CONTRATO"	
			RCC->(MsUnlock())
			
			RecLock("RCC",.T.)
			RCC->RCC_FILIAL := IIF(Empty(xFilial("RCC")),xFilial("RCC"),aFilRCC[nFil])
			RCC->RCC_CODIGO	:= "U006"
			RCC->RCC_SEQUEN := "004"	
			RCC->RCC_CONTEU := "004ABANDONO DE EMPREGO"	
			RCC->(MsUnlock())
			
			RecLock("RCC",.T.)
			RCC->RCC_FILIAL := IIF(Empty(xFilial("RCC")),xFilial("RCC"),aFilRCC[nFil])
			RCC->RCC_CODIGO	:= "U006"
			RCC->RCC_SEQUEN := "005"	
			RCC->RCC_CONTEU := "005DISPENSA SEM JUSTA CAUSA"	
			RCC->(MsUnlock())
			
			RecLock("RCC",.T.)
			RCC->RCC_FILIAL := IIF(Empty(xFilial("RCC")),xFilial("RCC"),aFilRCC[nFil])
			RCC->RCC_CODIGO	:= "U006"
			RCC->RCC_SEQUEN := "006"	
			RCC->RCC_CONTEU := "006DISPENSA COM JUSTA CAUSA"	
			RCC->(MsUnlock())

			RecLock("RCC",.T.)
			RCC->RCC_FILIAL := IIF(Empty(xFilial("RCC")),xFilial("RCC"),aFilRCC[nFil])
			RCC->RCC_CODIGO	:= "U006"
			RCC->RCC_SEQUEN := "007"	
			RCC->RCC_CONTEU := "098FUNCIONARIO GERENTE OU SUPERIOR (DISPENSA SEM JUSTA CAUSA)"	
			RCC->(MsUnlock())
			
			RecLock("RCC",.T.)
			RCC->RCC_FILIAL := IIF(Empty(xFilial("RCC")),xFilial("RCC"),aFilRCC[nFil])
			RCC->RCC_CODIGO	:= "U006"
			RCC->RCC_SEQUEN := "008"	
			RCC->RCC_CONTEU := "099FUNCIONARIO COM MAIS DE 10 ANOS (DISPENSA SEM JUSTA CAUSA)"	
			RCC->(MsUnlock())
												
		EndIf
		
	Next
	
Return