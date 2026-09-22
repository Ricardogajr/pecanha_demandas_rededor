#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} FA050ALT
Validações adicionais ao alterar o titulo no contas a pagar.

@project    ID1559/MAN0000007423041_EF_069
@author     William Ferreira Souza/Marcelo Mendes
@since      04/04/2019
@return     lRet
/*/
User Function FA050ALT()

    Local lRet := .T.

    If lRet .And. FindFunction("U_FSPE0027")
        lRet := U_FSPE0027()
    EndIf

    If (ALLTRIM(SE2->E2_ORIGEM) $ "FINA870|FINA376|FINA378|FINA290|FINA290M") .and. SE2->E2_XSTRECU == "R"
        M->E2_XSTRECU := "C"
        M->E2_XDTRECU := dDataBase
    EndIf

return lRet