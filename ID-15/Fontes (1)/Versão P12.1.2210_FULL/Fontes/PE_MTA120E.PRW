#Include "PROTHEUS.CH"

/*/{Protheus.doc} MTA120E
Valida Exclusão do pedido de compra
@author ALEX SANDRO VALARIO
@since 27/07/2017
@Project    MAN0000007423044_EF_022 
/*/
User Function MTA120E()
    Local nOpcA   := paramixb[1]
    Local cNumPed := paramixb[2]
            
    U_F0702203(cNumPed, 5, nOpcA) // Rotina para integrara com os fronts ws client de exclusão

Return .T.