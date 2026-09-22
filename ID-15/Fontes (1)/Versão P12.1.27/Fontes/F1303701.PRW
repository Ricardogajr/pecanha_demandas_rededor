#Include "Protheus.ch"

Static cResposta    := ""
Static lSucesso     := .T.
Static nHandle      := Nil

/*/{Protheus.doc} F1303701
Rotina utilizada dentro do método UpSertDocDev para inclusão de nota fiscal de entrada em mês fechado.

@project    MAN0000007423048_EF_037
@type       User Function
@author     Rafael Riego
@since      10/05/2018
@version    12.1.7
@param      aCabNota, array, cotem 5 posicoes que compõe a chave da nota fiscal de entrada
@param      cData, character, data no formato (yyyyMMdd) que a movimentação para baixar o saldo e o novo pedido de compras devem utilizar
@param      cNovIdInt, character, novo id de integração
@param      nRecLog, numeric, recno do novo registro da P19
@param      cEmpLog, character, codigo da empresa
@param      cFilLog, character, codigo da filial
@return     cResposta, caso esteja em branco nenhum erro ocorreu
/*///aCabNota, cData, cNovIdInt, nRecLog, cEmpLog, cFilLog)
User Function F1303701(aCabNota, cData, cNovIdInt, nRecLog, cEmpLog, cFilLog, cDocNum)

    Local aArea         := {}
    Local aItens        := {}

    Local bBlock        := {||}

    Local cCodUsrBkp    := ""
    Local cCompGener    := ""
    Local cErro         := ""
    Local cFilBkp       := ""
    Local cIdInteg      := ""
    Local cIdKey        := ""
    Local cUserBkp      := ""

    Local dData         := CToD("  /  /    ")

    Local lEnvAberto    := .F.
    Local lRestaura     := .F.

    Local nPswOrder     := 0
    Local nSF1Recno     := 0
    Local nSM0Recno     := 0

    Private cErroL          := ""
    Private lAutoErrNoFile  := .T.

    Default aCabNota    := {}
    Default cData       := ""
    Default nRecLog     := 0
    Default cNovIdInt   := U_GetIntegID()
    Default cEmpLog     := ""
    Default cFilLog     := ""

    bBlock  := ErrorBlock({|e| ChkErr(e)})

    If !(Select("SX2") > 0)
        If Empty(cFilLog) .Or. Empty(cEmpLog)
            U_F1303703("nao e possivel montar o ambiente.", .F.)
        Else
            // Conectar no ambiente para realizar a integracao na empresa e filial que o usuario está logado
            RpcSetEnv(cEmpLog, cFilLog)
            If !(Select("SX2") > 0)
                U_F1303703("Erro ao tentar montar ambiente para execucao da rotina.", .F.)
            Else
                lEnvAberto := .T.
                //Conout("F1303701 - Abertura de ambiente corretamente.")
            EndIf
        EndIf
    EndIf

    If lSucesso
        aArea   := {GetArea(), SF1->(GetArea()), SY1->(GetArea())}
        dData   := SToD(cData)

        cIdKey := aCabNota[1] + aCabNota[2] + aCabNota[3] + aCabNota[4] + aCabNota[5]

        SF1->(DbSetOrder(1))//F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA
        If SF1->(DbSeek(cIdKey))
            nSF1Recno   := SF1->(Recno())
            cIdInteg    := SF1->F1_XID
            //Conout("F1303701 - Nota encontrada com sucesso.")
        Else
            U_F1303703("Nota Fiscal nao foi encontrada.", .F.)
        EndIf
    EndIf

    If lSucesso
        //Backup Filial Atual
        cFilBkp     := cFilAnt

        If cFilAnt <> SF1->F1_FILIAL
            nSM0Recno   := SM0->(Recno())
            cFilAnt     := SF1->F1_FILIAL
            SM0->(DbSeek(cEmpAnt + cFilAnt))
        EndIf

        cCompGener  := GetMv("FS_COMPGEN")

        If !(Empty(cCompGener))
            SY1->(DbSetOrder(1))
            If SY1->(DbSeek(FwXFilial("SY1") + cCompGener))
                cUserBkp    := cUserName
                cCodUser    := SY1->Y1_USER
                cUserName   := UsrRetName(cCodUser)
                nPswOrder   := PswOrder(1)
                cCodUsrBkp  := __cUserId
                __cUserId   := cCodUser
                lRestaura   := .T.
                If !(PswSeek(cCodUser, .T.))
                    cResposta   := "Usuario cadastrado na tabela de compradores nao encontrado no sistema."
                    lSucesso    := .F.
                EndIf
            Else
                cResposta   := "Comprador generico nao existe na base de dados."
                lSucesso    := .F.
            EndIf
        Else
            lSucesso    := .F.
            cResposta   := "Parametro 'FS_COMPGEN' vazio. Impossivel prosseguir com a execucao."
        EndIf
    EndIf

    If lSucesso
        Begin Transaction

            //EF_038 - Bloqueio de Rotinas de Movimentação - Rede D'Or
            U_F1303801(cIdInteg, cNovIdInt, nSF1Recno)
            BreakTran() 
            //Conout("F1303701 - Arquivo de semaforo criado com sucesso." + FwTimeStamp(2))

            //EF_039 - Exclui Títulos da Nota Fiscal
            U_F1303901(cIdInteg, cNovIdInt)
            BreakTran()
            //Conout("F1303701 - titulos da nota fiscal excluidos com sucesso." + FwTimeStamp(2))

            //Carrega os itens da nota para uso nas rotinas
            aItens := CarrItens(nSF1Recno)

            //EF_041 - Inclui Movimentação Interna para Gerar Saldo
            U_F1304101(aItens, cNovIdInt, nSF1Recno, cDocNum)
            BreakTran()
            //Conout("F1303701 - Movimento interno para gerar saldo com sucesso." + FwTimeStamp(2))

            //EF_042 - Inclui Movimentação Interna para Baixar o saldo
            U_F1304201(aItens, cNovIdInt, dData, nSF1Recno, cDocNum)
            BreakTran()
            //Conout("F1303701 - Movimento interno para baixar saldo com sucesso." + FwTimeStamp(2))

            //EF_043 - Inclui Novo Pedido de Compra
            U_F1304301(aItens, cNovIdInt, dData)
            BreakTran()
            //Conout("F1303701 - Pedido incluído com sucesso." + FwTimeStamp(2))

            U_F1304001(nSF1Recno, cNovIdInt, dData)
            BreakTran()
            //Conout("F1303701 - Nota excluida com sucesso." + FwTimeStamp(2))

        End Transaction
    EndIf

    //Se o nHandle for diferente de nulo significa que foi preenchido e o arquivo deverá ser fechado
    If nHandle <> Nil
        FClose(nHandle)
        U_F1303802(2)
    EndIf

    ErrorBlock(bBlock)

    If !(Empty(cErroL))
        lSucesso := .F.
        cResposta := "ERRO DE PROGRAMACAO - " + CRLF + cErroL
    EndIf

    If !(Empty(cResposta))
        cResposta := "ERRO| " + cResposta
    EndIf

    cIdKey := aCabNota[1] + "|" + aCabNota[2] + "|" + aCabNota[3] + "|" + aCabNota[4] + "|" + aCabNota[5]
    U_F07Log02(nRecLog, cResposta, lSucesso, "SF1", 1, cIdKey)

    //Somente se o processo de devolução de nota tiver ocorrido com sucesso tenta integrar
    If lSucesso
        Begin Transaction
            U_F1303708(cNovIdInt, 3)
        End Transaction
    EndIf

    lAutoErrNoFile := Nil
    If lRestaura
        cUserName := cUserBkp
        __cUserId := cCodUsrBkp
        PswOrder(nPswOrder)
    EndIf

    //Caso tenha trocado a filial corrente realiza o backup
    If cFilBkp <> cFilAnt .And. !(Empty(cFilAnt))
        cFilAnt := cFilBkp
        SM0->(DbGoTo(nSM0Recno))
    EndIf

    If ValType(aArea) == "A" .And. Len(aArea) > 0
        AEval(aArea, {|area| RestArea(area)})
    EndIf

    FwFreeObj(aItens)
    aItens := Nil

    If lEnvAberto
        RpcClearEnv()
    EndIf

Return cResposta

/*/{Protheus.doc} F1303702
Rotina utilizada dentro do método DelDocDev para exclusão de nota fiscal de entrada em mês fechado.

@project    MAN0000007423048_EF_037
@type       User Function
@author     Rafael Riego
@since      10/05/2018
@version    12.1.7
@param      cIdInteg, character, id de integração da nota fiscal a ser deletada
@param      nRecLog, numeric, recno do novo registro da P19
@param      cEmpLog, character, codigo da empresa
@param      cFilLog, character, codigo da filial
@return     cResposta, caso esteja em branco nenhum erro ocorreu
/*///F1303704(cRotina, oDocEnt, cData, cNovIdInt, nRecLog, cEmpLog, cFilLog) | aCabNota, nRecLog, cEmpLog, cFilLog
User Function F1303702(aCabNota, nRecLog, cEmpLog, cFilLog, cDocNum)

    Local aArea         := {}
    Local aItens        := {}

    Local bBlock        := {||}

    Local cCodUsrBkp    := ""
    Local cCompGener    := ""
    Local cErro         := ""
    Local cFilBkp       := ""
    Local cIdInteg      := ""
    Local cIdKey        := ""
    Local cUserBkp      := ""

    Local dDataBkp      := CToD("  /  /    ")
    Local dDataRetro    := CTOD("  /  /    ")
    Local dMvUltMes     := CToD("  /  /    ")

    Local lEnvAberto    := .F.
    Local lRestaura     := .T.

    Local nPswOrder     := 0
    Local nSF1Recno     := 0
    Local nSM0Recno     := 0

    Private cErroL          := ""
    Private lAutoErrNoFile  := .T.

    Default aCabNota    := {}
    Default nRecLog     := 0
    Default cEmpLog     := ""
    Default cFilLog     := ""
    Default cDocNum     := ""

    bBlock  := ErrorBlock({|e| ChkErr(e)})

    If !(Select("SX2") > 0)
        If Empty(cFilLog) .Or. Empty(cEmpLog)
            U_F1303703("nao e possivel montar o ambiente.", .F.)
        Else
            // Conectar no ambiente para realizar a integracao na empresa e filial que o usuario está logado
            RpcSetEnv(cEmpLog, cFilLog)
            If !(Select("SX2") > 0)
                U_F1303703("Erro ao tentar montar ambiente para execucao da rotina.", .F.)
            Else
                lEnvAberto := .T.
                //Conout("F1303701 - Abertura de ambiente corretamente.")
            EndIf
        EndIf
    EndIf

    If lSucesso
        aArea       := {GetArea(), SF1->(GetArea()), SY1->(GetArea())}
        dDataBkp    := dDataBase

        cIdKey := aCabNota[1] + aCabNota[2] + aCabNota[3] + aCabNota[4] + aCabNota[5]

        SET DELETED OFF
        SF1->(DbSetOrder(1))
        If SF1->(DbSeek(cIdKey))
            //Sempre o ultimo registro com a chave encontrada
            While SF1->(!(EoF())) .And. SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA == cIdKey
                nSF1Recno := SF1->(Recno())
                SF1->(DbSkip())
            End
        Else
            U_F1303703("Nota Fiscal nao foi encontrada.", .F.)
        EndIf
        SET DELETED ON
    EndIf

    If lSucesso
        SF1->(DbGoTo(nSF1Recno))
        cIdInteg := SF1->F1_XIDEXNF

        //Backup Filial Atual
        cFilBkp     := cFilAnt

        If cFilAnt <> SF1->F1_FILIAL
            nSM0Recno   := SM0->(Recno())
            cFilAnt     := SF1->F1_FILIAL
            SM0->(DbSeek(cEmpAnt + cFilAnt))
        EndIf

        cCompGener  := GetMv("FS_COMPGEN")
        dMvUltMes   := GetMv("MV_ULMES")

        If !(Empty(cCompGener))
            SY1->(DbSetOrder(1))
            If SY1->(DbSeek(FwXFilial("SY1") + cCompGener))
                cUserBkp    := cUserName
                cCodUser    := SY1->Y1_USER
                cUserName   := UsrRetName(cCodUser)
                nPswOrder   := PswOrder(1)
                cCodUsrBkp  := __cUserId
                __cUserId   := cCodUser
                lRestaura   := .T.
                If !(PswSeek(cCodUser, .T.))
                    cResposta   := "Usuário cadastrado na tabela de compradores não encontrado no sistema."
                    lSucesso    := .F.
                EndIf
            Else
                cResposta   := "Comprador genérico não existe na base de dados."
                lSucesso    := .F.
            EndIf
        Else
            lSucesso    := .F.
            cResposta   := "Parâmetro 'FS_COMPGEN' vazio. Impossível prosseguir com a execução."
        EndIf
    EndIf

    If lSucesso
        Begin Transaction

            //EF_038 - Bloqueio de Rotinas de Movimentação - Rede D'Or
            U_F1303801("", "", nSF1Recno)
            BreakTran()
            //Conout("F1303702 - Arquivo de semaforo criado com sucesso.")

            //EF_044 - Exclui o Pedido de Compra gerado pela integração de inclusão
            U_F1304401(cIdInteg)
            BreakTran()
            //Conout("F1303702 - Pedido de compra excluído com sucesso. ")

            //EF_045 - Exclui o Movimento Interno de Saída gerado pela integração de inclusão
            U_F1304501(cIdInteg, cDocNum)
            BreakTran()
            //Conout("F1303702 - Movimento interno de saída excluído com sucesso.")

            //Retrocede a data base para a data de digitação da nota
            dDataRetro := DataOri(cIdInteg)

            //Realiza o Backup da database atual e troca a database atual para a data da nota fiscal deletada
            dDataBase   := dDataRetro

            //EF_046 - Exclui o Movimento Interno de Entrada gerado pela integração de inclusão
            U_F1304601(cIdInteg, cDocNum)
            BreakTran()
            //Conout("F1303702 - Movimento interno de entrada excluído com sucesso.")

            //EF_048 - Inclui os títulos com os dados dos títulos excluídos anteriormente
            U_F1304801(cIdInteg)
            BreakTran()
            //Conout("F1303702 - Inclui Pedido de Compra com os dados da nota deletada no processo de inclusão.")

            //EF_047 - Inclui a Nota Fiscal com os dados da nota deletada anteriormente
            U_F1304701(cIdInteg)
            BreakTran()
            //Conout("F1303702 - Inclui Nota Fiscal com os dados da nota deletada no processo de inclusão.")

        End Transaction
    EndIf

    ErrorBlock(bBlock)

    If !(Empty(cErroL))
        lSucesso := .F.
        cResposta := "ERRO DE PROGRAMACAO - " + CRLF + cErroL
    EndIf

    If !(Empty(cResposta))
        cResposta := "ERRO| " + cResposta
    EndIf

    cIdKey := aCabNota[1] + "|" + aCabNota[2] + "|" + aCabNota[3] + "|" + aCabNota[4] + "|" + aCabNota[5]
    U_F07Log02(nRecLog, cResposta, lSucesso, "SF1", 1, cIdKey)

    //Somente se o processo exclusão da devolução de nota tiver ocorrido com sucesso tenta integrar
    If lSucesso
        Begin Transaction
            U_F1303708(cIdInteg, 5)
        End Transaction
    EndIf

    //Se o nHandle for diferente de nulo significa que foi preenchido e o arquivo deverá ser fechado
    If nHandle <> Nil
        FClose(nHandle)
        U_F1303802(2)
    EndIf

    //Retorna a data correta
    If dDataBase <> dDataBkp
        dDataBase := dDataBkp
    EndIf

    lAutoErrNoFile := Nil

    If lRestaura
        cUserName := cUserBkp
        __cUserId := cCodUsrBkp
        PswOrder(nPswOrder)
    EndIf

    //Caso tenha trocado a filial corrente realiza o backup
    If cFilBkp <> cFilAnt
        cFilAnt := cFilBkp
        SM0->(DbGoTo(nSM0Recno))
    EndIf

    If ValType(aArea) == "A" .And. Len(aArea) > 0
        AEval(aArea, {|area| RestArea(area)})
    EndIf

    FwFreeObj(aItens)
    aItens := Nil

    If lEnvAberto
        RPCClearEnv()
    EndIf

Return cResposta

/*/{Protheus.doc} F1303703
Atribui valor as variáveis cResposta e lSucesso caso sejam informada por parâmetro.

@project    MAN0000007423048_EF_037
@type       User Function
@author     Rafael Riego
@since      10/05/2018
@version    12.1.7
@param      cNovResp, character, resposta (string) a ser atribuída a variável cResposta
@param      lNewSucess, boolean, resposta (boolean)a ser atribuída a variável lSucesso
@param      cData, character, data no formato (aaaammdd) que a movimentação para baixar o saldo e o novo pedido de compras devem utilizar
@return     Nil
/*/
User Function F1303703(cNovResp, lNewSucess)

    If cNovResp <> Nil
        cResposta := cNovResp
    EndIf

    If lSucesso <> Nil
        lSucesso := lNewSucess
    EndIf

Return Nil

/*/{Protheus.doc} F1303704
Executa o startjob para liberar a thread chamada através do serviço web service.

@project    MAN0000007423048_EF_037
@type       User Function
@author     Rafael Riego
@since      10/05/2018
@version    12.1.7
@param      cRotina, character, rotina a ser executada (F1303701 ou F1303702)
@param      oDocEnt, object, objeto do ws contendo a chave da nota fiscal de entrada
@param      cData, character, data no formato (aaaammdd) que a movimentação para baixar o saldo e o novo pedido de compras devem utilizar
@param      cNovIdInt, character, novo id de integração
@param      nRecLog, numeric, recno do novo registro da P19 (passar por referência)
@param      cEmpLog, character, codigo da empresa
@param      cFilLog, character, codigo da filial
@return     Nil
/*/
User Function F1303704(cRotina, oDocEnt, cData, cNovIdInt, nRecLog, cEmpLog, cFilLog, cDocNum)

    Local aCabNota  := {}

    Local cRetorno  := ""

    Default cData   := ""
    Default cDocNum := ""

    AAdd(aCabNota, oDocEnt:cFilialDoc)
    AAdd(aCabNota, oDocEnt:cDoc)
    AAdd(aCabNota, oDocEnt:cSerie)
    AAdd(aCabNota, oDocEnt:cFornecedor)
    AAdd(aCabNota, oDocEnt:cLoja)

    //o terceiro parâmetro do StartJob indica que o programa aguardará a execução da rotina na nova thread para prosseguir
    If cRotina == "U_F1303701"
        cRetorno := StartJob(cRotina, GetEnvServer(), .T., aCabNota, cData, cNovIdInt, nRecLog, cEmpLog, cFilLog, cDocNum)
    ElseIf cRotina == "U_F1303702"// ::cIdInteg,, nRecLog, cEmpAnt, cFilAnt)
        cRetorno := StartJob(cRotina, GetEnvServer(), .T., aCabNota, nRecLog, cEmpLog, cFilLog, cDocNum)
    EndIf

Return cRetorno

/*/{Protheus.doc} F1303705
Acessa o valor da variável static cResposta.

@project    MAN0000007423048_EF_037
@type       User Function
@author     Rafael Riego
@since      10/05/2018
@version    12.1.7
@return     cResposta, variável static cResposta
/*/
User Function F1303705()
Return cResposta

/*/{Protheus.doc} F1303706
Atribui o valor do handle do arquivo aberto a variável static nHandle para que o arquivo seja fechado posteriormente, mantendo assim o semaforo ligado até o fim do processamento.

@project    MAN0000007423048_EF_037
@type       User Function
@author     Rafael Riego
@since      10/05/2018
@version    12.1.7
@param      nNovHandle, numeric, valor do handle a ser atribuido a variável static
@return     Nil
/*/
User Function F1303706(nNovHandle)
    nHandle := nNovHandle
Return Nil

/*/{Protheus.doc} F1303707
Validaçõea da rotina de inclusão/exclusão.

@project    MAN0000007423048_EF_037
@type       User Function
@author     Rafael Riego
@since      05/06/2018
@version    12.1.7
@param      oCabDocEnt, object, objeto do ws contendo a chave da nota fiscal de entrada (passar por referência)
@param      cData, character, data string no formato yyyyMMdd
@param      cNovIdInt, character, novo id de integração (passar por referência)
@param      nRecLog, numeric, recno do novo registro da P19 (passar por referência)
@param      cRetorno, character, retorno em caso de erro (passar por referência)
@param      nOperacao, numeric, numero da operacao 1 - UpSertDocDev/2 - DelDocDev

@return     Nil
/*/
User Function F1303707(oCabDocEnt, cData, cNovIdInt, nRecLog, cRetorno, nOperacao)

    Local aArea         := {}

    Local cCodUsrBkp    := ""
    Local cCompGener    := ""
    Local cFilBkp       := ""
    Local cIdInteg      := ""
    Local cIdKey        := ""
    Local cUserBkp      := ""

    Local dData         := CToD("  /  /    ")
    Local dMvUltMes     := CToD("  /  /    ")

    Local lValidado     := .T.
    Local lRestaura     := .F.

    Local nPswOrder     := 0
    Local nSM0Recno     := 0
    Local nSF1Recno     := 0

    Local bBlock        := {||}

    Default cData       := ""
    Default cNovIdInt   := ""
    Default cRetorno    := ""
    Default nRecLog     := 0
    Default oCabDocEnt  := Nil
    Default nOperacao   := 1 //1 - UpSertDocDev/2 - DelDocDev

    cNovIdInt := U_GetIntegID()

    aArea   := {GetArea(), SF1->(GetArea()), SD1->(GetArea()), SY1->(GetArea()), SE2->(GetArea())}

    If nOperacao == 1
        nRecLog := U_F07Log01(cNovIdInt, {oCabDocEnt, cData}, "U_F1303701")
    Else
        nRecLog := U_F07Log01(cNovIdInt, {oCabDocEnt}, "U_F1303702")
    EndIf

    dData   := SToD(cData)

    If lValidado// .And. nOperacao == 1
        If Empty(oCabDocEnt:cFilialDoc)
            lValidado := .F.
            cRetorno := "parametro obrigatorio: cFilialDoc (filial de documento da nota)"
        ElseIf !FwFilExist(cEmpAnt, oCabDocEnt:cFilialDoc)
            lValidado := .F.
            cRetorno := "cFilialDoc - filial informada nao existe."
        ElseIf Empty(oCabDocEnt:cDoc)
            lValidado := .F.
            cRetorno := "parametro obrigatorio: cDoc (numero de documento da nota)"
        ElseIf Empty(oCabDocEnt:cSerie)
            lValidado := .F.
            cRetorno := "parametro obrigatorio: cSerie (filial da nota)"
        ElseIf Empty(oCabDocEnt:cFornecedor)
            lValidado := .F.
            cRetorno := "parametro obrigatorio: cFornecedor (fornecedor da nota)"
        ElseIf Empty(oCabDocEnt:cLoja)
            lValidado := .F.
            cRetorno := "parametro obrigatorio: cLoja (loja da nota)"
        EndIf
    EndIf

    If lValidado
        oCabDocEnt:cFilialDoc   := PadR(oCabDocEnt:cFilialDoc,  TamSX3("F1_FILIAL")[1])
        oCabDocEnt:cDoc         := PadR(oCabDocEnt:cDoc,        TamSX3("F1_DOC")[1])
        oCabDocEnt:cSerie       := PadR(oCabDocEnt:cSerie,      TamSX3("F1_SERIE")[1])
        oCabDocEnt:cFornecedor  := PadR(oCabDocEnt:cFornecedor, TamSX3("F1_FORNECE")[1])
        oCabDocEnt:cLoja        := PadR(oCabDocEnt:cLoja,       TamSX3("F1_LOJA")[1])

        cIdKey := oCabDocEnt:cFilialDoc + oCabDocEnt:cDoc + oCabDocEnt:cSerie + oCabDocEnt:cFornecedor + oCabDocEnt:cLoja

        If nOperacao == 1
            SF1->(DbSetOrder(1))//F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA
            If !(SF1->(DbSeek(cIdKey)))
                cRetorno := "Nota nao localizada"
                lValidado := .F.
            Else
                cIdInteg := SF1->F1_XID
                SD1->(DbSetOrder(1))
                If !(SD1->(DbSeek(cIdKey)))
                    cRetorno := "Nao foi encontrado nenhum item para a nota fiscal informada."
                    lValidado := .F.
                EndIf
            EndIf
        Else
            //para devolução procura pela nota deletada
            SET DELETED OFF
            SF1->(DbSetOrder(1))//F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA
            If SF1->(DbSeek(cIdKey))
                While SF1->(!(EoF())) .And. SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA == cIdKey
                    nSF1Recno := SF1->(Recno())
                    SF1->(DbSkip())
                End
                SF1->(DbGoTo(nSF1Recno))
                //caso a nota não esteja deletada significa que não deverá ser retornada
                If !(SF1->(Deleted()))
                    cRetorno := "Nota nao localizada"
                    lValidado := .F.
                EndIf
            Else
                cRetorno := "Nota nao localizada"
                lValidado := .F.
            EndIf
            SET DELETED ON
        EndIf
    EndIf

    If lValidado .And. nOperacao == 1 .And. (Empty(dData))
        cRetorno := "Data informada e invalida."
        lValidado := .F.
    EndIf

    If lValidado
        //Backup Filial Atual
        cFilBkp := cFilAnt

        If cFilAnt <> SF1->F1_FILIAL .And. !(Empty(SF1->F1_FILIAL))
            nSM0Recno   := SM0->(Recno())
            cFilAnt     := SF1->F1_FILIAL
            SM0->(DbSeek(cEmpAnt + cFilAnt))
        EndIf

        If lValidado
            //Verifica integridade dos parâmetros MV_ULMES e FS_ULMES
            lValidado := VerifParam(@cRetorno)
        EndIf

        If lValidado
            If !U_F1303802(2)
                If !(Empty(cResposta))
                    cRetorno := cResposta
                Else
                    cRetorno := "Nao foi possivel excluir arquivo de semaforo."
                EndIf
                lValidado := .F.
            EndIf
        EndIf

        If lValidado
            cCompGener  := GetMv("FS_COMPGEN")

            If !(Empty(cCompGener))
                SY1->(DbSetOrder(1))
                If SY1->(DbSeek(FwXFilial("SY1") + cCompGener))
                    cUserBkp    := cUserName
                    cCodUser    := SY1->Y1_USER
                    cUserName   := UsrRetName(cCodUser)
                    nPswOrder   := PswOrder(1)
                    cCodUsrBkp  := __cUserId
                    __cUserId   := cCodUser
                    lRestaura   := .T.
                    If !(PswSeek(cCodUser, .T.))
                        cRetorno    := "Usuario cadastrado na tabela de compradores nao encontrado no sistema."
                        lValidado   := .F.
                    EndIf
                Else
                    cRetorno    := "Comprador generico nao existe na base de dados."
                    lValidado   := .F.
                EndIf
            Else
                lValidado   := .F.
                cRetorno    := "Parametro 'FS_COMPGEN' vazio. Impossivel prosseguir com a execucao."
            EndIf
        EndIf
    EndIf

    If lValidado
        dMvUltMes := GetMV("MV_ULMES")
        If !(DateDiffMonth(SF1->F1_DTDIGIT, dMvUltMes) == 0)
            //cRetorno := "Diferenca entre o mes de digitacao da nota e parametro MV_ULMES nao pode ser diferente de 0."
            cRetorno := "A Nota Fiscal a ser devolvida e do dia " + DToC(SF1->F1_DTDIGIT) +;
                " e nao pertence a data registrada no ultimo fechamento " + DToC(dMvUltMes) + "."
            lValidado := .F.
        ElseIf nOperacao == 1
            /*If !(dData > dMvUltMes)
                cRetorno := "Data informada nao pode ser inferior ao parametro MV_ULMES."
                lValidado := .F.
            ElseIf !(DateDiffMonth(dMvUltMes, dData) == 1)
                cRetorno := "Diferenca entre data informada e parametro MV_ULMES nao pode ser diferente de 1 mes."
                lValidado := .F.
            EndIf*/
        EndIf
    EndIf

    //Valida se os títulos da nota se encontram em bordero ou estão baixados
    If lValidado .And. nOperacao == 1
        SE2->(DbOrderNickName("EF0703301"))
        If SE2->(DbSeek(FwXFilial("SE2") + cIdInteg))
            While SE2->(!(EoF())) .And. SE2->E2_FILIAL == FwXFilial("SE2") .And. SE2->E2_XID == cIdInteg
                //Verifica se título está em borderô
                If !(Empty(SE2->E2_NUMBOR))
                    cRetorno := "Titulo se encontra em bordero. Impossivel efetuar a exclusao."
                    lValidado := .F.
                    Exit
                ElseIf !(Empty(SE2->E2_BAIXA))
                    cRetorno := "Titulo se encontra baixado. Impossivel efetuar a exclusao."
                    lValidado := .F.
                    Exit
                EndIf
                SE2->(DbSkip())
            End
        EndIf
     EndIf

    If lRestaura
        cUserName := cUserBkp
        __cUserId := cCodUsrBkp
        PswOrder(nPswOrder)
    EndIf

    //Caso tenha trocado a filial corrente realiza o backup
    If cFilBkp <> cFilAnt .And. !(Empty(cFilBkp))
        cFilAnt := cFilBkp
        If nSM0Recno > 0
            SM0->(DbGoTo(nSM0Recno))
        EndIf
    EndIf

    AEval(aArea, {|area| RestArea(area)})

    If !lValidado
        cIdKey := oCabDocEnt:cFilialDoc + "|" + oCabDocEnt:cDoc + "|" + oCabDocEnt:cSerie + "|" + oCabDocEnt:cFornecedor + "|" + oCabDocEnt:cLoja
        cRetorno := "ERRO| " + cRetorno
        U_F07Log02(nRecLog, cRetorno, lValidado, "SF1", 1, cIdKey)
    EndIf

Return lValidado

//

/*/{Protheus.doc} F1303708
Encapsulamento da rotina F0702203() para integração do pedido de compra após a finalização do processo de devolução da nota/cancelamento da devolução.

@project    MAN0000007423048_EF_037
@type       User Function
@author     Rafael Riego
@since      05/06/2018
@version    12.1.7
@param      nOperac, numeric, numero da operacao 3 - Inclusão/5 - Exclusão
@param      cIdInteg, character, id de integração somente caso seja operação igual a 2

@return     Nil
/*/
User Function F1303708(cIdInteg, nOperac)

    Local aArea     := {}

    Local cNumPed   := ""

    Local nRecnoSC7 := 0

    //trecho apenas para evitar errolog na rotina F0702203
    Private INCLUI  := .T.
    Private ALTERA  := .T.

    Default cIdInteg    := ""
    Default nOperac     := 0

    aArea := {GetArea(), SC7->(GetArea())}

    If !(Empty(cIdInteg)) .And. nOperac <> 0
        If nOperac == 3
            SC7->(DbOrderNickname("EF1304401"))
            If SC7->(DbSeek(cIdInteg))
                cNumPed := SC7->C7_NUM
                U_F0702203(cNumPed, nOperac, 1)//U_F0702203( cPedComp, nOper, nOpca, nRecSC7)
            EndIf
        ElseIf nOperac == 5
            SC7->(DbOrderNickname("EF1304401"))
            SET DELETED OFF
            If SC7->(DbSeek(cIdInteg))
                nRecnoSC7   := SC7->(Recno())
                cNumPed     := SC7->C7_NUM
            EndIf
            SET DELETED ON
            U_F07022RE(cNumPed, "E")
        EndIf
    EndIf

    AEval(aArea, {|area| RestArea(area)})

Return Nil

/*/{Protheus.doc} CarrItens
Carrega itens da nota fiscal deletada.

@type       Static Function
@author     Rafael Riego
@since      15/05/2018
@version    12.1.7
@param      nSF1Recno, numeric, recno do registro da tabela SF1
@return     Nil
/*/
Static Function CarrItens(nSF1Recno)

    Local aArea         := {}
    Local aItensNota    := {}

    Local cChaveSF1     := ""

    Default nSF1Recno   := 0

    aArea := {GetArea(), SF1->(GetArea()), SD1->(GetArea())}

    If !(Empty(nSF1Recno))
        SF1->(DbGoTo(nSF1Recno))
    EndIf

    cChaveSF1 := FwXFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA

    SD1->(DbSetOrder(1))
    If SD1->(DbSeek(FwXFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
        While SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE +SD1->D1_LOJA == cChaveSF1
            AAdd(aItensNota, {SD1->D1_COD, SD1->D1_QUANT, SD1->D1_LOCAL, SD1->D1_CC, SD1->D1_DTDIGIT, SD1->D1_CUSTO, SD1->D1_PEDIDO, SD1->D1_ITEMPC})
            SD1->(DbSkip())
        End
    EndIf

    AEval(aArea, {|area| RestArea(area)})

Return aItensNota

/*/{Protheus.doc} DataOri
Retorna a data de digitação original da Nota Fiscal.

@type       Static Function
@author     Rafael Riego
@since      15/05/2018
@version    12.1.7
@param      cIdInteg, character, id de integração da nota fiscal a ser pesquisada
@return     Nil
/*/
Static Function DataOri(cIdInteg)

    Local aArea     := {}

    Local dDataOri  := CToD("  /  /    ")

    Default cIdInteg    := ""

    aArea := {GetArea(), SF1->(GetArea())}

    SET DELETED OFF

    SF1->(DbOrderNickname("EF1304701"))
    If SF1->(DbSeek(cIdInteg))
        While SF1->(!(EoF())) .And. SF1->F1_XIDEXNF == cIdInteg
            dDataOri := SF1->F1_DTDIGIT
            SF1->(DbSkip())
        End
    EndIf

    SET DELETED ON

    AEval(aArea, {|area| RestArea(area)})

Return dDataOri

/*/{Protheus.doc} BreakTran
Verifica e fecha a transação aberta dependendo da variável static lSucesso.

@type       Static Function
@author     Rafael Riego
@since      10/05/2018
@version    12.1.7
@return     Nil
/*/
Static Function BreakTran()

    If !lSucesso .And. InTransact()
        DisarmTransaction()
        Break
    EndIf

Return Nil

/*/{Protheus.doc} VerifParam
Verifica integridade doS parâmetro MV_ULMES, FS_ULMES e FS_COMPGEN.

@type       Static Function
@author     Rafael Riego
@since      15/05/2018
@version    12.1.7
@return     lOk, se os parâmetros estão integros ou não
/*/
Static Function VerifParam(cErro)

    Local cCompGen  := ""
    Local cTMEntr   := ""
    Local cTMSaida  := ""

    Local dFsUltMes := CToD("  /  /    ")
    Local dMvUltMes := CToD("  /  /    ")

    Local lOk       := .T.

    Default cErro     := ""

    cCompGen    := GetMv("FS_COMPGEN",  .T., "")
    cTMEntr     := GetMv("FS_TMENTAS",  .T., "")
    cTMSaida    := GetMv("FS_TMSAIAS",  .T., "")
    dFsUltMes   := GetMv("FS_ULMES",    .T., CToD("  /  /    "))
    dMvUltMes   := GetMv("MV_ULMES",    .T., CToD("  /  /    "))

    If Empty(dMvUltMes)
        lOk     := .F.
        cErro   := "Parametro MV_ULMES nao existe ou esta com vazio."
    EndIf

    If lOk
        If Empty(dFsUltMes)
            If !GetMV("FS_ULMES", .T.)
                lOk     := .F.
                cErro   := "Parametro FS_ULMES nao existe."
            EndIf
        EndIf
    EndIf

    If lOk
        If Empty(cCompGen)
            lOk     := .F.
            cErro   := "Parametro FS_COMPGEN nao existe ou esta vazio."
        EndIf
    EndIf

    If lOk
        If Empty(cTMEntr)
            lOk     := .F.
            cErro   := "Parametro FS_TMENTAS nao existe ou esta vazio."
        EndIf
    EndIf

    If lOk
        If Empty(cTMSaida)
            lOk     := .F.
            cErro   := "Parametro FS_TMSAIAS não pode estar vazio."
        EndIf
    EndIf

    If !lOk
        U_F1303703(cErro, .F.)
    EndIf

Return lOk

/*/{Protheus.doc} ChkErr
Função para tratamento de erros.

@project    MAN0000007423041_EF_033
@type       function
@author     Anieli Rodrigues
@since      03/02/2017
@version    12.7
@param      oErroArq, object, Dados do erro capturado
/*/
Static Function ChkErr(oErroArq)

    If oErroArq:GenCode > 0
        cErroL := "(" + AllTrim(Str(oErroArq:GenCode)) + ") : " + AllTrim(oErroArq:Description) + CRLF
    EndIf

    cErroL += GetEStack()

    If InTransact()
        cErroL += "Transacao aberta desarmada."
        DisarmTransaction()
    EndIf
    Break

Return Nil

/*/{Protheus.doc} GetEStack
trata e retorna o stack de erro.

@type       static function
@author     Anieli Rodrigues
@since      03/02/2017
@version    12.7
@param      oErroArq, object, Dados do erro capturado
/*/
Static Function GetEStack() As Character

    Local cStack := ""

    Local nI     := 2

    While (!(Empty(ProcName(nI))))
        cStack += Trim(ProcName(nI)) + "(" + AllTrim(Str(ProcLine(nI))) + ") " + CRLF
        nI ++
    End

Return cStack
