// #########################################################################################
// Projeto: Rede D'Or
// Modulo : Financeiro
// Fonte  : F241INC2
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 16/06/24 | Rafael Yera Barchi| Ponto de Entrada para gravação complementar após de 
//          |                   | impostos na rotina Bordero de Impostos
// ---------+-------------------+-----------------------------------------------------------

#INCLUDE    "PROTHEUS.CH"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F241INC2
//Ponto de Entrada para gravação complementar de impostos na rotina Bordero de Impostos
@author Rafael Yera Barchi
@since 16/06/2024
@version 1.00
@type function

/*/
//------------------------------------------------------------------------------------------
User Function F241INC2() 

    Local cObs := "(MNK) "
    
     
    If SE2->E2_SALDO < 0 
        
        RecLock("SE2", .F.)
            SE2->E2_SALDO   := 0
            SE2->E2_VALLIQ  := SE2->E2_VALOR + SE2->E2_ACRESC - SE2->E2_DECRESC
            SE2->E2_HIST    := cObs + Left(SE2->E2_HIST, TamSX3("E2_HIST")[1] - Len(cObs))
        SE2->(MSUnlock())

    EndIf

Return
