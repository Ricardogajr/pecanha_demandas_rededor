/*{Protheus.doc} F1200718
Ponto de entrada para tratamento de campos do pedido de compra
*/
User Function F1200718

    Local aItens    := AClone(ParamIXB[1])
    Local nPosLocal := AScan(aItens[1],{|aItem| aItem[1] == "C7_LOCAL" })
    Local nItem     := 0
    Local cLocal    := ""
    Local aArea     := GetArea()
    Local aAreaSC1  := SC1->(GetArea())

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
            RestArea(aAreaSC1)
            RestArea(aArea)
        EndIf

        If !Empty(cLocal)
            For nItem := 1 To Len(aItens)
                aItens[nItem][nPosLocal][2] := cLocal
            Next
        EndIf
    EndIf

Return aItens
