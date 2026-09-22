#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH"
/*
{Protheus.doc} F0500107()
Atualização da tabela RCB
@Author     Roberto Souza
@Since      08/11/2016
@Version    P12.7
@Project    MAN0000007423039_EF_00101
@Return
*/
User Function F0500107()
	
	Local nFil
	Local nTamFil    := Len(cFilAnt)
	Local nTamFilRCB := Len(AllTrim(xFilial("RCB")))
	Local aTodasFil  := {}
	Local aFilRCB    := {xFilial("RCB")}
	Local cFilRCB    := cFilAnt

	aTodasFil := FWAllFilial(cEmpAnt,,,.F.)
	For nFil := 1 To Len(aTodasFil)
		cFilRCB := PadR(Left(aTodasFil[nFil],nTamFilRCB),nTamFil)
		If ( AScan(aFilRCB,{|x| x == cFilRCB }) == 0 )
			AAdd(aFilRCB,cFilRCB)
		EndIf
	Next

	For nFil := 1 To Len(aFilRCB)
		RCB->(DbSetOrder(1))
		
	
		If !RCB->(DbSeek(IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil]) + "U005"))
		
			
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U005'
			RCB->RCB_DESC   := 'TP RESCISÕES VS. COD.RESCISAO'
			RCB->RCB_ORDEM  := '01'
			RCB->RCB_CAMPOS := 'XCOD_RES'
			RCB->RCB_DESCPO := 'Código Rescisão'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 2// N
			RCB->RCB_DECIMA := 0// N
			RCB->RCB_PICTUR := '@!'
			RCB->RCB_PADRAO := 'FS43BR'
			RCB->RCB_PESQ   := '1'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())
			
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U005'
			RCB->RCB_DESC   := 'TP RESCISÕES VS. VISÕES'
			RCB->RCB_ORDEM  := '02'
			RCB->RCB_CAMPOS := 'XDES_RES'
			RCB->RCB_DESCPO := 'Descrição Rescisão'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 30// N
			RCB->RCB_DECIMA := 0// N
			RCB->RCB_PICTUR := '@!'
			RCB->RCB_PADRAO := ''
			RCB->RCB_PESQ   := '2'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())
						
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U005'
			RCB->RCB_DESC   := 'TP RESCISÕES VS. VISÕES'
			RCB->RCB_ORDEM  := '03'
			RCB->RCB_CAMPOS := 'XTIP_RES'
			RCB->RCB_DESCPO := 'Tipo Rescisão'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 3// N
			RCB->RCB_DECIMA := 0// N
			RCB->RCB_PICTUR := '@!'
			RCB->RCB_PADRAO := 'FSU006'			
			RCB->RCB_PESQ   := '2'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())

			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U005'
			RCB->RCB_DESC   := 'TP RESCISÕES VS. VISÕES'
			RCB->RCB_ORDEM  := '04'
			RCB->RCB_CAMPOS := 'XANEXO'
			RCB->RCB_DESCPO := 'ANEXO?'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 1// N
			RCB->RCB_DECIMA := 0// N
			RCB->RCB_PICTUR := '@!'
			RCB->RCB_VALID  := 'Pertence("S|N")'
			RCB->RCB_PADRAO := ''			
			RCB->RCB_PESQ   := '2'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())
			
			
		EndIf
	Next
	
Return

