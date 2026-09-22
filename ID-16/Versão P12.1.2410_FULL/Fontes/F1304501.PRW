#Include "Protheus.ch"

/*/{Protheus.doc} F1304501
Exclui o movimento interno de Saída.

@project    MAN0000007423048_EF_045
@@type      User Function
@author     Rafael Riego
@since      10/05/2018
@version    12.1.7
@param      cIdInteg, character, novo id de integração gerado para esta integração
@return     lOk, se a movimentação ocorreu com sucesso ou não
/*/
User Function F1304501(cIdInteg, cDocNum)

    Local aArea         := {}
    Local aLog          := {}
    Local aMovimento    := {}
    Local aMoviments    := {}

    Local cErro         := ""

    Local lOk           := .T.

    Local nErro         := 0
    Local nMovimento    := 0

    Local aCabs         := {} //Thiago Marques - 16/06/2025 - nºticket 23781663
    Local aCabecalho    := {} //Thiago Marques - 16/06/2025 - nºticket 23781663

    Private lMsErroAuto     := .F.

    Default cIdInteg    := ""
    Default cDocNum     := ""

    aArea := {GetArea(), SD3->(GetArea())}

    If !(Empty(cIdInteg))
        SD3->(DbOrderNickname("EF1304501"))
        If !(SD3->(DbSeek(cIdInteg)))
            cErro   := "Movimento Interno de Saida nao encontrado."
            lOk     := .F.
        EndIf
    Else
        cErro   := "Id de integracao nao pode estar vazio."
        lOk     := .F.
    EndIf

    If lOk
        While SD3->(!(EoF())) .And. SD3->D3_XIDEXNF == cIdInteg
            If SD3->D3_TM > "500" .And. !(SD3->D3_TM == "999") .And. Empty(SD3->D3_ESTORNO)
                aCabecalho := {}
                AAdd(aCabecalho, {"D3_DOC", SD3->D3_DOC, Nil}) //Thiago Marques - 16/06/2025 - Compatibilizando para MATA241

                AAdd(aCabs, AClone(aCabecalho))

                aMovimento := {}
                //AAdd(aMovimento, {"D3_NUMSEQ",  SD3->D3_NUMSEQ, Nil})
                //AAdd(aMovimento, {"INDEX",      4,              Nil})
                aAdd(aMovimento, {"D3_COD",     SD3->D3_COD,   Nil})
                aAdd(aMovimento, {"D3_UM",      SD3->D3_UM,    Nil})
                aAdd(aMovimento, {"D3_QUANT",   SD3->D3_QUANT, Nil})
                aAdd(aMovimento, {"D3_LOCAL",   SD3->D3_LOCAL, Nil})
                aAdd(aMovimento, {"D3_ESTORNO", "S",           Nil})

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
            MsExecAuto({| cabecalho, movimentacao, operacao| MATA241(cabecalho, movimentacao, operacao)},aCabs[nMovimento], aMoviments[nMovimento], 6)

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
                If !(Empty(cDocNum)) .And. SD3->D3_TM == "499" .And. Empty(SD3->D3_ESTORNO) .And. SD3->D3_XIDEXNF = cIdInteg
                    RecLock("SD3", .F.)
                    SD3->D3_DOC := cDocNum
                    SD3->(MsUnLock())
                EndIf
            EndIf
        Next nMovimento
    EndIf

    If !(lOk)
        U_F1303703(cErro, .F.)
    EndIf

    AEval(aArea, {|area| RestArea(area)})

Return lOk

User Function F1304599()

    Private lAutoErrNoFile  := .T.

    RpcSetEnv("01", "01010004")

    Begin Transaction

        If !(U_F1304501("808ddb986922497494275b50442b1af2    "))
            DisarmTransaction()
            Alert("Cancelamento")
            Break
        EndIf
    End Transaction

    RpcClearEnv()

    lAutoErrNoFile := Nil

Return Nil
