/*{Protheus.doc} F1200718
Ponto de entrada para tratamento de campos do pedido de compra
*/
User Function F1200718()

	Local aItens    := AClone(ParamIXB[2])
	Local nPosLocal := AScan(aItens[1],{|aItem| aItem[1] == "C7_LOCAL" })
	Local nPosNumSc := AScan(aItens[1],{|aItem| aItem[1] == "C7_NUMSC" })
	Local nPosIemSc := AScan(aItens[1],{|aItem| aItem[1] == "C7_ITEMSC" })
	Local nItem     := 0
	Local cLocal    := ""
	Local cNumSc    := ""
	Local cIemSc    := ""
	Local aArea     := GetArea()
	Local aAreaSC1  := SC1->(GetArea())

	//Tratativa Forn e Loja
	DbSelectArea("CNA")
	DbSetOrder(1)
	If CNA->(DbSeek(CN9->CN9_FILIAL+CN9->CN9_NUMERO+CN9->CN9_REVISA+"000001"))
		ParamIXB[1][AScan(ParamIXB[1],{|aItem| aItem[1] == "C7_FORNECE" })][2] := CNA->CNA_FORNEC
		ParamIXB[1][AScan(ParamIXB[1],{|aItem| aItem[1] == "C7_LOJA" })][2] := CNA->CNA_LJFORN
	Else
		ParamIXB[1][AScan(ParamIXB[1],{|aItem| aItem[1] == "C7_FORNECE" })][2] := aListMedic[nMedicaoFS][6]
		ParamIXB[1][AScan(ParamIXB[1],{|aItem| aItem[1] == "C7_LOJA" })][2] := aListMedic[nMedicaoFS][7]
	EndIf


	If nPosLocal > 0
		If Type("aListMedic") == "A"
			cLocal := aListMedic[nMedicaoFS][20]
		ElseIf !Empty(CNE->CNE_XNUMSC)
			aArea     := GetArea()
			aAreaSC1  := SC1->(GetArea())
			SC1->(DbSetOrder(1))
			If SC1->(DbSeek(xFilial("SC1")+CNE->CNE_XNUMSC))
				cLocal := SC1->C1_LOCAL
			EndIf
		EndIf

		If !Empty(cLocal)
			For nItem := 1 To Len(aItens)
				aItens[nItem][nPosLocal][2] := cLocal
			Next
		EndIf
	EndIf

	If nPosNumSc > 0
		If Type("aListMedic") == "A"
			cNumSc := aListMedic[nMedicaoFS][27]
		ElseIf !Empty(CNE->CNE_XNUMSC)
			aArea     := GetArea()
			aAreaSC1  := SC1->(GetArea())
			SC1->(DbSetOrder(1))
			If SC1->(DbSeek(xFilial("SC1")+CNE->CNE_XNUMSC+CNE->CNE_XITSC))
				cNumSc := SC1->C1_NUM
			EndIf
		EndIf

		If !Empty(cNumSc)
			For nItem := 1 To Len(aItens)
				aItens[nItem][nPosNumSc][2] := cNumSc
			Next
		EndIf
	EndIf

	If nPosIemSc > 0
		If Type("aListMedic") == "A"
			cIemSc := aListMedic[nMedicaoFS][28]
		ElseIf !Empty(CNE->CNE_XNUMSC)
			aArea     := GetArea()
			aAreaSC1  := SC1->(GetArea())
			SC1->(DbSetOrder(1))
			If SC1->(DbSeek(xFilial("SC1")+CNE->CNE_XNUMSC+CNE->CNE_XITSC))
				cIemSc := SC1->C1_ITEM 
			EndIf
		EndIf

		If !Empty(cIemSc)
			For nItem := 1 To Len(aItens)
				aItens[nItem][nPosIemSc][2] := cIemSc
			Next
		EndIf
	EndIf

	RestArea(aAreaSC1)
	RestArea(aArea)

Return {ParamIXB[1],aItens}
