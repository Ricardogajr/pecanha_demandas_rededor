#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} F1206901
Mudança de status de Recusa "Recusado" para "corrigido" ao alterar o título.

@project    MAN0000007423041_EF_069
@author     William Ferreira Souza
@since      04/04/2019
@return     lRet, verdadeiro ou falso
/*/

User Function F1206901()

    Local lRet := .t.

    If (ALLTRIM(SE2->E2_ORIGEM) $ "FINA870|FINA376|FINA378|FINA290|FINA290M") .and. SE2->E2_XSTRECU == "R"
        M->E2_XSTRECU := "C"
        M->E2_XDTRECU := dDataBase
    EndIf

return lRet