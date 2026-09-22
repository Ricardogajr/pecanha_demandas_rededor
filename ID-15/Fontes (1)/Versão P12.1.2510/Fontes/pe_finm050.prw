#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'

/*/{Protheus.doc} User Function FINM050
    Ponto de Entrada MVC da movimentação bancária - Títulos PA
    @type  Function
    @author Gianluca Moreira
    @since 07/06/2021
    /*/
User Function FINM050()
    Local lRet     := .T.

    If lRet .And. FindFunction('U_F2000220')
        U_F2000220() //Gera tabela de integração ao XRT
    EndIf

Return lRet
