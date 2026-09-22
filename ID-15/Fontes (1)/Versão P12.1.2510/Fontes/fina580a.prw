// #########################################################################################
// Projeto: Rede D'Or
// Modulo : Financeiro
// Fonte  : FINA580A
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 18/11/21 | Rafael Yera Barchi| Ponto de Entrada para gravação complementar após a 
//          |                   | liberação do título a pagar
// ---------+-------------------+-----------------------------------------------------------

#INCLUDE    "PROTHEUS.CH"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINA580A
//Ponto de Entrada para gravação complementar após a liberação do título a pagar
@author Rafael Yera Barchi
@since 18/11/2021
@version 1.00
@type function

/*/
//------------------------------------------------------------------------------------------
User Function FINA580A()


    SA2->(DBSelectArea("SA2"))
    SA2->(DBSetOrder(1))
    SA2->(DBSeek(FWxFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA))
    
    If !Empty(SE2->E2_DATALIB)
        If RecLock("SE2", .F.)
            If SE2->(FieldPos("E2_XANALIS")) > 0
                SE2->E2_XANALIS := "S"
            EndIf
            If SE2->(FieldPos("E2_XRISCOS")) > 0 .And. SA2->(FieldPos("A2_XRISSAC")) > 0 .And. Empty(SE2->E2_XRISCOS)
                SE2->E2_XRISCOS := SA2->A2_XRISSAC
            EndIf
            SE2->(MSUnLock())
        EndIf
    EndIf

Return
