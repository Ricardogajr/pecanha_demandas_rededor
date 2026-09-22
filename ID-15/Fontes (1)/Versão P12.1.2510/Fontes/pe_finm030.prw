#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'

/*/{Protheus.doc} User Function FINM050
    Ponto de Entrada MVC da movimentação bancária - Títulos PA
    @type  Function
    @author Gianluca Moreira
    @since 07/06/2021
    /*/
User Function FINM030()
    Local lRet     := .T.

    If FWIsInCallStack('U_F2000401')
        Return lRet
    EndIf

    //Versões antigas do SIGAFIN utilizam o programa FINM030 para lançamento de adiantamentos
    //Versões recentes passam a utilizar o FINM050.

    //Aviso: Em versões atualizadas, caso o fonte FINM050.prw esteja compilado, este ponto
    //de entrada poderá ser removido sem problemas, pois já foi criado o PE_FINM050.
    // ticket n° 12912589
    //If lRet .And. !FindFunction('FINM050') .And. FindFunction('U_F2000220')
    If lRet .And. FindFunction('U_F2000220')
        lRet := U_F2000220() //Gera tabela de integração ao XRT
    EndIf

Return lRet
