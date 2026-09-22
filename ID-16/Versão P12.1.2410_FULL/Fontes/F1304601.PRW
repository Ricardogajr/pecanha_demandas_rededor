#Include "Protheus.ch"

/*/{Protheus.doc} F1304601
Excluí o movimento interno de Entrada.

@project    MAN0000007423048_EF_046
@@type      User Function
@author     Rafael Riego
@since      10/05/2018
@version    12.1.7
@param      cIdInteg, character, novo id de integração gerado para esta integração
@return     lOk, se a movimentação foi excluída com sucesso ou não
/*/
User Function F1304601(cIdInteg, cDocNum)

    Local aArea         := {}
    Local aCabItens     := {}
    Local aCabNota      := {}
    Local aItensNota    := {}
    Local aLog          := {}
    Local aMovimento    := {}
    Local aMoviments   := {}

    Local aCabs         := {} //Thiago Marques - 16/06/2025 - nºticket 23781663
    Local aCabecalho    := {} //Thiago Marques - 16/06/2025 - nºticket 23781663

    Local cErro         := ""

    Local lOk           := .T.

    Local nErro         := 0
    Local nMovimento    := 0

    Private lMsErroAuto     := .F.

    Default cIdInteg    := ""
    Default cDocNum     := ""

    aArea := {GetArea(), SD3->(GetArea())}

    If !(Empty(cIdInteg))
        SD3->(DbOrderNickname("EF1304501"))
        If !(SD3->(DbSeek(cIdInteg)))
            cErro   := "Movimento Interno de Saída não encontrado."
            lOk     := .F.
        EndIf
    Else
        cErro   := "Id de integração não pode estar vazio."
        lOk     := .F.
    EndIf

    If lOk
        While SD3->(!(EoF())) .And. SD3->D3_XIDEXNF == cIdInteg
            /*If !(Empty(cDocNum))
                RecLock("SD3", .F.)
                SD3->D3_DOC := cDocNum
                SD3->(MsUnLock())
            EndIf*/
            If SD3->D3_TM <= "500" .And. !(SD3->D3_TM == "499") .And. Empty(SD3->D3_ESTORNO)
                aCabecalho := {}
                AAdd(aCabecalho, {"D3_DOC", SD3->D3_DOC, Nil}) //Thiago Marques - 16/06/2025 - Compatibilizando para MATA241

                AAdd(aCabs, AClone(aCabecalho))

                aMovimento := {}
                aAdd(aMovimento, {"D3_COD",     SD3->D3_COD,   Nil})
                aAdd(aMovimento, {"D3_UM",      SD3->D3_UM,    Nil})
                aAdd(aMovimento, {"D3_QUANT",   SD3->D3_QUANT, Nil})
                aAdd(aMovimento, {"D3_LOCAL",   SD3->D3_LOCAL, Nil})
                aAdd(aMovimento, {"D3_ESTORNO", "S",           Nil})
                //AAdd(aMovimento, {"D3_NUMSEQ",  SD3->D3_NUMSEQ, Nil})
                //AAdd(aMovimento, {"INDEX",      4,              Nil})

                AAdd(aMoviments, AClone(aMovimento))
                FwFreeObj(aMovimento)
                FwFreeObj(aCabecalho)

                aMovimento := Nil
                aCabecalho := Nil
            EndIf
            SD3->(DbSkip())
        End

        nQtdMovim := Len(aMoviments)

        For nMovimento := 1 To nQtdMovim
            //MsExecAuto({| movimentacao, operacao| MATA240(movimentacao, operacao)}, aMoviments[nMovimento], 5)
            MsExecAuto({| cabecalho, movimentacao, operacao| MATA241(cabecalho,movimentacao, operacao)},aCabs[nMovimento], aMoviments[nMovimento], 6)

            If lMsErroAuto
                cErro += "INCONSISTENCIA DE ROTINA AUTOMATICA - Movimento Interno | " + CRLF
                aLog := GetAutoGRLog()
                For nErro := 1 To Len(aLog)
                    cErro += aLog[nErro] + CRLF
                Next nErro
                lOk := .F.
                Exit
            Else
                //caso tenha gerado a movimentação de estorno, grava o D3_DOC
                If !(Empty(cDocNum)) .And. SD3->D3_TM == "999" .And. Empty(SD3->D3_ESTORNO) .And. SD3->D3_XIDEXNF = cIdInteg
                    RecLock("SD3", .F.)
                    SD3->D3_DOC := cDocNum
                    SD3->(MsUnLock())
                EndIf
            EndIf
        Next nMovimento
    EndIf

    If !(lOk)
        U_F1303703(cErro, .F.)
    Else
        aCabItens := CarrgItens(cIdInteg)
        aCabNota    := AClone(aCabItens[1])
        aItensNota  := AClone(aCabItens[2])
        If ExistBlock("F13046E")
            ExecBlock("F13046E", .F., .F., {aCabNota, aItensNota})
        EndIf
    EndIf

    AEval(aArea, {|area| RestArea(area)})

    FwFreeObj(aMoviments)
    FwFreeObj(aCabItens)
    FwFreeObj(aCabNota)
    FwFreeObj(aItensNota)

    aMoviments  := Nil
    aCabItens   := Nil
    aCabNota    := Nil
    aItensNota  := Nil
Return lOk

Static Function CarrgItens(cIdInteg)

    Local aArea         := {}
    Local aCabNota      := {}
    Local aItensNota    := {}
    Local aRetorno      := {}

    Local cChaveSF1     := ""

    Local nSF1Recno     := 0

    Default cIdInteg    := ""

    aArea := {GetArea(), SF1->(GetArea()), SD1->(GetArea())}

    SET DELETED OFF

    SF1->(DbOrderNickname("EF1304701"))
    If SF1->(DbSeek(cIdInteg))
        While SF1->(!(EoF())) .And. SF1->F1_XIDEXNF == cIdInteg
            //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_FORMUL
            nSF1Recno := SF1->(Recno())
            SF1->(DbSkip())
        End

        SF1->(DbGoTo(nSF1Recno))

        AAdd(aCabNota, SF1->F1_DOC)
        AAdd(aCabNota, SF1->F1_SERIE)
        AAdd(aCabNota, SF1->F1_FORNECE)
        AAdd(aCabNota, SF1->F1_LOJA)
        AAdd(aCabNota, SF1->F1_FORMUL)

        cChaveSF1 := FwXFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA

        SD1->(DbSetOrder(1))
        If SD1->(DbSeek(cChaveSF1))
            While SD1->(!(EoF())) .And. SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA == cChaveSF1
                If SD1->D1_XIDEXNF == SF1->F1_XIDEXNF
                    AAdd(aItensNota, {SD1->D1_PEDIDO, SD1->D1_ITEMPC, SD1->D1_QUANT, SD1->D1_LOCAL, SD1->D1_COD})
                EndIf
                SD1->(DbSkip())
            End
        EndIf
    EndIf

    SET DELETED ON

    AEval(aArea, {|area| RestArea(area)})

    AAdd(aRetorno, AClone(aCabNota))
    AAdd(aRetorno, AClone(aItensNota))

    FwFreeObj(aCabNota)
    FwFreeObj(aItensNota)
    aCabNota := Nil
    aItensNota := Nil

Return aRetorno
