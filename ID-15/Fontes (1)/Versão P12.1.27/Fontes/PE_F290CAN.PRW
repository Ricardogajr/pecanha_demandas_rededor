#include 'TOTVS.CH'

/*/{Protheus.doc} F290CAN

// PONTO DE ENTRADA F290CAN                                       
// Este PE serve para grava‡äes complementares ap¢s cancelamento 
// do titulo na fatura.                                          
// Utilizado para Desbloqueio de Notas Fiscais de Entrada

@type User function
@author Marcel Mendes Trindade
@since 14/06/2019
@version 12.17
@project 
@return NIL
/*/
User Function F290CAN()

Local aArea := GetArea()

// Só envia desbloqueio se saldo for igual valor do título (não houve baixa anteriormente )  
If SE2->E2_SALDO = SE2->E2_VALOR .AND. !Empty(SE2->E2_XID) 
	U_F0702901(SE2->E2_XID)
Endif

RestArea(aArea)

Return(Nil)

