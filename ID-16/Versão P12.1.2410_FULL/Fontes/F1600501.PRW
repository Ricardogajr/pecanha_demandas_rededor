/*/{Protheus.doc} F1600501
    Fonte criado apenas para criar update de campo
    /*/
User Function F1600501()

    Local oModel     := FwModelActive()
   	Local oMdlDetail := oModel:GetModel("MODEL_SC7")
    Local nValDesc   := oMdlDetail:GetValue("C7_VLDESC")
    Local nDesFin    := oMdlDetail:GetValue("C7_XDESFIN")
    Local lValido    := .T.

    If nValDesc > 0 .And. nDesFin > 0
        Help("", 1, "F1600501", , 'Campos "Desconto Nota" e "Desconto Boleto" não podem ser preenchidos simultaneamente.', 1, 0, , , , , , {"Utilize apenas um dos descontos."})
        lValido := .F.
    EndIf

    SD1->D1_XDESFIN := 0

Return lValido