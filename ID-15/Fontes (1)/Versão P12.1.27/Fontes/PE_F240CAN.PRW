 #include 'TOTVS.CH'
 
/*/{Protheus.doc} F240CAN
Ponto de entrada executado no cancelamento do bordero de pagamento.
@type User function
@author Paulo Krüger
@since 20/03/2017
@version 12.7
@project MAN0000007423041_EF_029
@return NIL
/*/

User Function F240CAN()

Local aArea := GetArea()

//Desbloqueio de Notas Fiscais de Entrada

SE2->(DbSetOrder(01))
If SE2->(DbSeek(SEA->EA_FILIAL + SEA->EA_PREFIXO + SEA->EA_NUM + SEA->EA_PARCELA + SEA->EA_TIPO + SEA->EA_FORNECE +  SEA->EA_LOJA))
	U_F0702901(SE2->E2_XID)
EndIf

RestArea(aArea)

Return