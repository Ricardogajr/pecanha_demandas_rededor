#Include "PROTHEUS.CH"

/*/{Protheus.doc} MT120DEL
Valida Exclusão da Solicitação de Pagamento.
@author izac.ciszevski
@since 01/06/2017
@Project    MAN0000007423044_EF_004 
/*/
User Function MT120E()

    Local lValido := .T.
    
    lValido := U_F1000304()// Valida solicitação de pagamento

Return lValido