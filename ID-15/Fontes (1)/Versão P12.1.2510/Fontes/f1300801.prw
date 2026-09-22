#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH"
/*{Protheus.doc} F1300801
Atualização da tabela RCB e RCC
@owner     Queizy de Oliveira Nascimento
@author    Queizy de Oliveira Nascimento
@since      18/10/2017
@param      NIL
@return     NIL
@project    MAN0000007423048_EF_008
@version    P 12.1.7
@obs        Observacoes
*/
User Function F1300801()

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
		If !RCB->(DbSeek(IIF(Empty(xFilial("RCB")), xFilial("RCB"), aFilRCB[nFil]) + "U014"))


			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")), xFilial("RCB"), aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U014'
			RCB->RCB_DESC   := 'SINDICATO X FUNCAO'
			RCB->RCB_ORDEM  := '01'
			RCB->RCB_CAMPOS := 'REGIONAL'
			RCB->RCB_DESCPO := 'Regional'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 2
			RCB->RCB_DECIMA := 0
			RCB->RCB_PICTUR := '!@'
			RCB->RCB_PADRAO := 'B1N992'
			RCB->RCB_PESQ   := '1'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '3'
			RCB->RCB_VALID := 'NAOVAZIO() .AND. EXISTCPO("CC2")'
			RCB->(MsUnlock())

			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")), xFilial("RCB"), aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U014'
			RCB->RCB_DESC   := 'SINDICATO X FUNCAO'
			RCB->RCB_ORDEM  := '02'
			RCB->RCB_CAMPOS := 'MUNICIPIO'
			RCB->RCB_DESCPO := 'Municipio'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 5
			RCB->RCB_DECIMA := 0
			RCB->RCB_PICTUR := '@!'
			RCB->RCB_PADRAO := 'CC2'
			RCB->RCB_PESQ   := '1'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '3'
			RCB->RCB_VALID :='NAOVAZIO() .AND. U_F1300803(MUNICIPIO, 1)'
			RCB->(MsUnlock())

			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")), xFilial("RCB"), aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U014'
			RCB->RCB_DESC   := 'SINDICATO X FUNCAO'
			RCB->RCB_ORDEM  := '03'
			RCB->RCB_CAMPOS := 'SINDICATO'
			RCB->RCB_DESCPO := 'Sindicato'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 2
			RCB->RCB_DECIMA := 0
			RCB->RCB_PICTUR := '@!'
			RCB->RCB_PADRAO := 'RCE'
			RCB->RCB_PESQ   := '1'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '3'
			RCB->RCB_VALID  :='NAOVAZIO() .AND. EXISTCPO("RCE") .AND. U_ValTab(SINDICATO)'
			RCB->(MsUnlock())

			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")), xFilial("RCB"), aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U014'
			RCB->RCB_DESC   := 'SINDICATO X FUNCAO'
			RCB->RCB_ORDEM  := '04'
			RCB->RCB_CAMPOS := 'FUNCAO'
			RCB->RCB_DESCPO := 'Função Vinculada'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 200
			RCB->RCB_DECIMA := 0
			RCB->RCB_PICTUR := '@!'
			RCB->RCB_PADRAO := 'SRJ'
			RCB->RCB_PESQ   := '1'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '3'
			RCB->RCB_VALID :='NAOVAZIO() .AND. U_F1300803(FUNCAO, 2)'
			RCB->(MsUnlock())



		EndIf
	Next

Return

