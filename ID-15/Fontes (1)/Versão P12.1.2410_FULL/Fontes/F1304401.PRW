#Include "Protheus.ch"

/*/{Protheus.doc} F1304401
Excluí Pedido de Compra gerado na integração de inclusão.

@project    MAN0000007423048_EF_044
@@type      User Function
@author     Rafael Riego
@since      10/05/2018
@version    12.1.7
@param      cIdInteg, character, id de integração para encontrar o Pedido de Venda a ser excluído
@return     lOk, se o pedido foi excluído com sucesso ou não
/*/
User Function F1304401(cIdInteg)

    Local aArea         := {}
    Local aItemPed      := {}
    Local aItensPed     := {}
    Local aLog          := {}
    Local aPedido       := {}

    Local cErro         := ""
    Local cNumPed       := ""

    Local lOk           := .T.

    Local nErro         := 0
    Local nTipo         := 0

    Private lMsErroAuto     := .F.

    Default cIdInteg    := 0

    aArea := {GetArea(), SC7->(GetArea())}

    If !(Empty(cIdInteg))
        SC7->(DbOrderNickname("EF1304401"))
        If !(SC7->(DbSeek(cIdInteg)))
            cErro   := "Pedido de Compra referente ao id de integração não encontrado."
            lOk     := .F.
        EndIf
    Else
        cErro   := "Id de integração não pode estar vazio."
        lOk     := .F.
    EndIf

    If lOk
        cNumPed := SC7->C7_NUM
        nTipo   := SC7->C7_TIPO

        AAdd(aPedido, {"C7_NUM", cNumPed, Nil})

        //Indice através do código da integração (C7_XIDEXNF) que deve ser único. NickName 'F1304401'
        While SC7->(!(EoF())) .And. SC7->C7_XIDEXNF == cIdInteg
            aItemPed := {}

            AAdd(aItemPed, {"C7_REC_WT",    SC7->(Recno()),     Nil})
            AAdd(aItemPed, {"C7_ITEM",      SC7->C7_ITEM,       Nil})
            AAdd(aItemPed, {"C7_PRODUTO",   SC7->C7_PRODUTO,    Nil})

            AAdd(aItensPed, AClone(aItemPed))
            FwFreeObj(aItemPed)
            aItemPed := Nil
            SC7->(DbSkip())
        End

        MsExecAuto({|tipo, cabec, itens, operacao| MATA120(tipo, cabec, itens, operacao)}, nTipo, aPedido, aItensPed, 5)

        If lMsErroAuto
            cErro += "INCONSISTENCIA DE ROTINA AUTOMATICA - Pedido de Compra | " + CRLF
            aLog := GetAutoGRLog()
            For nErro := 1 To Len(aLog)
                cErro += aLog[nErro] + CRLF
            Next nErro
            lOk := .F.
        EndIf
    EndIf

    If !(lOk)
        U_F1303703(cErro, .F.)
    EndIf

    AEval(aArea, {|area| RestArea(area)})

    FwFreeObj(aPedido)
    FwFreeObj(aItensPed)
    aPedido := Nil
    aItensPed := Nil

Return lOk

User Function F1304499()

    Local cIdInteg  := ""

    Local lOk       := .T.

    cIdInteg := "0a9cf628cbe9400085E9cecd54796027"

    RpcSetEnv("01", "01010004")

    lOk := U_F1304401(cIdInteg)

    RpcClearEnv()

Return lOk