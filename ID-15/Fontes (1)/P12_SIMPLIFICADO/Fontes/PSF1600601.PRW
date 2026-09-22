#Include 'Protheus.ch'

Static nTamCamp := TamSX3("A2_COD")[1]
Static cCodForn := Space(nTamCamp)
Static lFirst   := .T.

User Function F1600601()

    If FunName() == "MATA020" .And. INCLUI
        If lFirst
            cCodForn := GetSXENum("SA2", "A2_XCOD",, 11)
        EndIf
    EndIf

    lFirst := !lFirst

Return cCodForn

User Function F1600602()

    If FunName() == "MATA020" .And. INCLUI
        If lFirst
            cCodForn := GetSXENum("SA2", "A2_XCOD",, 11)
        EndIf
    EndIf

    lFirst := !lFirst

Return cCodForn