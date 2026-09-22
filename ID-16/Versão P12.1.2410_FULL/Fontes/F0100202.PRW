#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH"
/*
{Protheus.doc} F0100202()
Atualização da tabela RCB
@Author     Henrique Madureira
@Since      20/04/2016
@Version    P12.7
@Project    MAN00000462901_EF_002
@Return
*/
User Function F0100202()
	
	Local nFil
	Local nTamFil    := Len(cFilAnt)
	Local nTamFilRCB := Len(AllTrim(xFilial("RCB")))
	Local aTodasFil  := {}
	Local aFilRCB    := {}
	Local cFilRCB    := cFilAnt
	
	If Empty(xFilial("RCB"))
		aFilRCB := {cFilAnt}
	Else
		aTodasFil := FWAllFilial(cEmpAnt, ,, .F.)
		For nFil := 1 To Len(aTodasFil)
			cFilRCB := PadR(Left(aTodasFil[nFil], nTamFilRCB), nTamFil)
			If ( AScan(aFilRCB, {|x| x == cFilRCB }) == 0 )
				AAdd(aFilRCB, cFilRCB)
			EndIf
		Next
	EndIf
	
	For nFil := 1 To Len(aFilRCB)
		RCB->(DbSetOrder(1))
		If !RCB->(DbSeek(IIF(Empty(xFilial("RCB")), xFilial("RCB"), aFilRCB[nFil]) + "U001"))
		
			
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")), xFilial("RCB"), aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U001'
			RCB->RCB_DESC   := 'PRAZOS PARA RECONTRATACAO'
			RCB->RCB_ORDEM  := '01'
			RCB->RCB_CAMPOS := 'CODRESCIS'
			RCB->RCB_DESCPO := 'Codigo Rescisao'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 2// N
			RCB->RCB_DECIMA := 0// N
			RCB->RCB_PICTUR := '99'
			RCB->RCB_PADRAO := 'FS43CD'
			RCB->RCB_PESQ   := '1'
			RCB->RCB_SHOWMA := 'S'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())
			
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")), xFilial("RCB"), aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U001'
			RCB->RCB_DESC   := 'PRAZOS PARA RECONTRATACAO'
			RCB->RCB_ORDEM  := '02'
			RCB->RCB_CAMPOS := 'DESCRICAO'
			RCB->RCB_DESCPO := 'Descricao'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 30// N
			RCB->RCB_DECIMA := 0// N
			RCB->RCB_PICTUR := '@!'
			RCB->RCB_PADRAO := 'FS43DE'
			RCB->RCB_PESQ   := '1'
			RCB->RCB_SHOWMA := 'S'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())
			
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")), xFilial("RCB"), aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U001'
			RCB->RCB_DESC   := 'PRAZOS PARA RECONTRATACAO'
			RCB->RCB_ORDEM  := '03'
			RCB->RCB_CAMPOS := 'PZDIAS'
			RCB->RCB_DESCPO := 'Prazo em dias'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 3// N
			RCB->RCB_DECIMA := 0// N
			RCB->RCB_PICTUR := '999'
			RCB->RCB_PESQ   := '2'
			RCB->RCB_SHOWMA := 'S'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())
			
			
			
		EndIf
	Next
	
Return

