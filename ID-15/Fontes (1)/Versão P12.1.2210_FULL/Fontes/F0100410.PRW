#Include 'Protheus.ch'

/*
{Protheus.doc} F0104101()
Gravação do Campo F1_XDTVNF
@Author     Robson William
@Since      02/06/2017
@Version    P12.7
@Project    MAN00000462901_EF_004, MIT031
*/ 
User Function F0104101(dVenciment)

    Default dVenciment := CtoD("  /  /  ")
    If !Empty(dVenciment) .and. Empty(SF1->F1_XDTVNF)
        SF1->(Reclock("SF1",.F.))
        SF1->F1_XDTVNF := dVenciment
        SF1->(MsUnlock())
    Endif

Return