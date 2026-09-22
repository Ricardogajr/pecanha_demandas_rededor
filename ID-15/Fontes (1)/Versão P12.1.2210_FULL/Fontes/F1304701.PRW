#Include 'Protheus.ch'

/*/{Protheus.doc} F1304601
Realiza a inclusão da Nota Fiscal de Entrada com os dados da Nota Fiscal excluída anteriormente no processo de integração da inclusão.

@project    MAN0000007423048_EF_047
@@type      User Function
@author     Rafael Riego
@since      15/05/2018
@version    12.1.7
@param      cIdInteg, character, Id gerado para esta integração de Inclusão de Nota
@return     lOk, se a movimentação ocorreu com sucesso ou não
/*/
User Function F1304701(cIdInteg)

    Local aArea         := {}
    Local aItensNota    := {}
    Local aLog          := {}
    Local aNota         := {}

    Local cErro         := ""
    Local cChaveSF1     := ""

    Local lOk           := .T.

    Local nErro         := 0

    Private lMsErroAuto     := .F.

    Default cIdInteg    := ""

    If CarArrayNf(cIdInteg, @aNota, @aItensNota, @cErro)

        MsExecAuto({|cabecalho, itens, operacao| MATA103(cabecalho, itens, operacao)}, aNota, aItensNota, 3)

        If lMsErroAuto
            cErro += "INCONSISTENCIA DE ROTINA AUTOMATICA - INCLUSÃO DE Nota Fiscal | " + CRLF
            aLog := GetAutoGRLog()
            For nErro := 1 To Len(aLog)
                cErro += aLog[nErro] + CRLF
            Next nErro
            lOk := .F.
        EndIf
    Else
        lOk := .F.
    EndIf

    If !lOk
        U_F1303703(cErro, .F.)
    EndIf

    FwFreeObj(aNota)
    FwFreeObj(aItensNota)
    aNota := Nil
    aItensNota := Nil

    AEval(aArea, {|area| RestArea(area)})

Return lOk

/*/{Protheus.doc} CarArrayNF
Função responsável pela montagem do array para inclusão da nota fiscal via ExecAuto.

@project    MAN0000007423048_EF_047
@type       User function
@author     Rafael Riego
@since      14/05/2017
@version    12.1.7
@param      cIdInteg, character, ID unico reservado para a integração
@param      aNota, array, dados do cabeçalho da nota (deve ser passado por referência).
@param      aItensNota, array, dados dos itens da nota (deve ser passado por referência).
@param      cErro, character, mensagem de erro que deve ser utilizada quando o a rotina retornar falso
@return     lOk, se foi possível carregar os dados da NF ou não
/*/
Static Function CarArrayNf(cIdInteg, aNota, aItensNota, cErro)

    Local aArea     := {}
    Local aItemNota := {}

    Local lOk       := .T.

    Local nSF1Recno := 0

    aArea := {GetArea(), SF1->(GetArea()), SD1->(GetArea())}

    SET DELETED OFF

    SF1->(DbOrderNickname("EF1304701"))
    If SF1->(DbSeek(cIdInteg))
        While SF1->(!(EoF())) .And. SF1->F1_XIDEXNF == cIdInteg
            nSF1Recno := SF1->(Recno())
            SF1->(DbSkip())
        End

        SF1->(DbGoTo(nSF1Recno))

        AAdd(aNota, {"F1_TIPO",     SF1->F1_TIPO,       Nil})
        AAdd(aNota, {"F1_FORMUL",   SF1->F1_FORMUL,     Nil})
        AAdd(aNota, {"F1_DOC",      SF1->F1_DOC,        Nil})
        AAdd(aNota, {"F1_SERIE",    SF1->F1_SERIE,      Nil})
        AAdd(aNota, {"F1_EMISSAO",  SF1->F1_EMISSAO,    Nil})
        AAdd(aNota, {"F1_FORNECE",  SF1->F1_FORNECE,    Nil})
        AAdd(aNota, {"F1_LOJA",     SF1->F1_LOJA,       Nil})
        AAdd(aNota, {"F1_ESPECIE",  SF1->F1_ESPECIE,    Nil})
        AAdd(aNota, {"F1_EST",      SF1->F1_EST,        Nil})
        AAdd(aNota, {"F1_CHVNFE",   SF1->F1_CHVNFE,     Nil})
        AAdd(aNota, {"F1_NFORIG",   SF1->F1_NFORIG,     Nil})
        AAdd(aNota, {"F1_SERORIG",  SF1->F1_SERORIG,    Nil})
        AAdd(aNota, {"F1_HORA",     SF1->F1_HORA,       Nil})
        AAdd(aNota, {"F1_FOB_R",    SF1->F1_FOB_R,      Nil})
        AAdd(aNota, {"F1_CIF",      SF1->F1_CIF,        Nil})
        AAdd(aNota, {"F1_RECBMTO",  SF1->F1_RECBMTO,    Nil})
        AAdd(aNota, {"F1_CODNFE",   SF1->F1_CODNFE,     Nil})
        AAdd(aNota, {"F1_CHVNFE",   SF1->F1_CHVNFE,     Nil})
        AAdd(aNota, {"F1_MENNOTA",  SF1->F1_MENNOTA,    Nil})
        AAdd(aNota, {"F1_XCONSIG",  SF1->F1_XCONSIG,    Nil})
        AAdd(aNota, {"F1_XTITFRO",  SF1->F1_XTITFRO,    Nil})
        AAdd(aNota, {"F1_XID",      SF1->F1_XID,        Nil})
        AAdd(aNota, {"F1_DESPESA",  SF1->F1_DESPESA,    Nil})
        AAdd(aNota, {"F1_DESCONT",  SF1->F1_DESCONT,    Nil})

        cChaveSF1 := FwXFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA
        SD1->(DbSetOrder(1))
        If SD1->(DbSeek(FwXFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
            While SD1->(!(EoF())) .And. SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE +SD1->D1_LOJA == cChaveSF1
                If SD1->D1_XIDEXNF == SF1->F1_XIDEXNF
                    aItemNota   := {}

                    AAdd(aItemNota, {"D1_ITEM",     SD1->D1_ITEM,       Nil})
                    AAdd(aItemNota, {"D1_COD",      SD1->D1_COD,        Nil})
                    AAdd(aItemNota, {"D1_PEDIDO",   SD1->D1_PEDIDO,     Nil})
                    AAdd(aItemNota, {"D1_ITEMPC",   SD1->D1_ITEMPC,     Nil})
                    AAdd(aItemNota, {"D1_UM",       SD1->D1_UM,         Nil})
                    AAdd(aItemNota, {"D1_QUANT",    SD1->D1_QUANT,      Nil})
                    AAdd(aItemNota, {"D1_VUNIT",    SD1->D1_VUNIT,      Nil})
                    AAdd(aItemNota, {"D1_TOTAL",    SD1->D1_TOTAL,      Nil})
                    AAdd(aItemNota, {"D1_VALFRE",   SD1->D1_VALFRE,     Nil})
                    AAdd(aItemNota, {"D1_SEGURO",   SD1->D1_SEGURO,     Nil})
                    AAdd(aItemNota, {"D1_VALDESC",  SD1->D1_VALDESCM,   Nil})
                    AAdd(aItemNota, {"D1_TES",      SD1->D1_TES,        Nil})

                    If !(Empty(SD1->D1_CF))
                        AAdd(aItemNota, {"D1_CF",   SD1->D1_CF,         Nil})
                    EndIf

                    AAdd(aItemNota, {"D1_LOCAL",    SD1->D1_LOCAL,      Nil})
                    AAdd(aItemNota, {"D1_NFORI",    SD1->D1_NFORI,      Nil})
                    AAdd(aItemNota, {"D1_SERIORI",  SD1->D1_SERIORI,    Nil})
                    AAdd(aItemNota, {"D1_ITEMORI",  SD1->D1_ITEMORI,    Nil})
                    AAdd(aItemNota, {"D1_CUSTO",    SD1->D1_CUSTO,      Nil})
                    AAdd(aItemNota, {"D1_QTDPEDI",  SD1->D1_QTDPEDI,    Nil})
                    AAdd(aItemNota, {"D1_XDTVALI",  SD1->D1_XDTVALI,    Nil})
                    AAdd(aItemNota, {"D1_XLOTECT",  SD1->D1_XLOTECT,    Nil})

                    If !(Empty(SD1->D1_XSETOR))
                        AAdd(aItemNota, {"D1_XSETOR",   SD1->D1_XSETOR, Nil})
                    EndIf

                    AAdd(aItemNota, {"D1_XCONSIG",  SD1->D1_XCONSIG,    Nil})
                    AAdd(aItemNota, {"D1_IPI",      SD1->D1_IPI,        Nil})
                    AAdd(aItemNota, {"D1_BASEIPI",  SD1->D1_BASEIPI,    Nil})
                    AAdd(aItemNota, {"D1_VALIPI",   SD1->D1_VALIPI,     Nil})
                    AAdd(aItemNota, {"D1_PICM",     SD1->D1_PICM,       Nil})
                    AAdd(aItemNota, {"D1_BASEICM",  SD1->D1_BASEICM,    Nil})
                    AAdd(aItemNota, {"D1_VALICM",   SD1->D1_VALICM,     Nil})
                    AAdd(aItemNota, {"D1_ESTCRED",  SD1->D1_ESTCRED,    Nil})
                    AAdd(aItemNota, {"D1_ICMSCOM",  SD1->D1_ICMSCOM,    Nil})
                    AAdd(aItemNota, {"D1_VALACRS",  SD1->D1_VALACRS,    Nil})
                    AAdd(aItemNota, {"D1_MARGEM",   SD1->D1_MARGEM,     Nil})
                    AAdd(aItemNota, {"D1_ALIQSOL",  SD1->D1_ALIQSOL,    Nil})
                    AAdd(aItemNota, {"D1_BRICMS",   SD1->D1_BRICMS,     Nil})
                    AAdd(aItemNota, {"D1_ICMSRET",  SD1->D1_ICMSRET,    Nil})
                    AAdd(aItemNota, {"D1_BASEPIS",  SD1->D1_BASEPIS,    Nil})
                    AAdd(aItemNota, {"D1_ALQPIS",   SD1->D1_ALQPIS,     Nil})
                    AAdd(aItemNota, {"D1_VALPIS",   SD1->D1_VALPIS,     Nil})
                    AAdd(aItemNota, {"D1_BASECOF",  SD1->D1_BASECOF,    Nil})
                    AAdd(aItemNota, {"D1_ALQCOF",   SD1->D1_ALQCOF,     Nil})
                    AAdd(aItemNota, {"D1_VALCOF",   SD1->D1_VALCOF,     Nil})
                    AAdd(aItemNota, {"D1_BASECSL",  SD1->D1_BASECSL,    Nil})
                    AAdd(aItemNota, {"D1_ALQCSL",   SD1->D1_ALQCSL,     Nil})
                    AAdd(aItemNota, {"D1_VALCSL",   SD1->D1_VALCSL,     Nil})
                    AAdd(aItemNota, {"D1_BASIMP6",  SD1->D1_BASIMP6,    Nil})
                    AAdd(aItemNota, {"D1_ALQIMP6",  SD1->D1_ALQIMP6,    Nil})
                    AAdd(aItemNota, {"D1_VALIMP6",  SD1->D1_VALIMP6,    Nil})
                    AAdd(aItemNota, {"D1_BASIMP5",  SD1->D1_BASIMP5,    Nil})
                    AAdd(aItemNota, {"D1_ALQIMP5",  SD1->D1_ALQIMP5,    Nil})
                    AAdd(aItemNota, {"D1_VALIMP5",  SD1->D1_VALIMP5,    Nil})
                    AAdd(aItemNota, {"D1_BASEIRR",  SD1->D1_BASEIRR,    Nil})
                    AAdd(aItemNota, {"D1_ALIQIRR",  SD1->D1_ALIQIRR,    Nil})
                    AAdd(aItemNota, {"D1_VALIRR",   SD1->D1_VALIRR,     Nil})
                    AAdd(aItemNota, {"D1_ABATMAT",  SD1->D1_ABATMAT,    Nil})
                    AAdd(aItemNota, {"D1_BASEISS",  SD1->D1_BASEISS,    Nil})
                    AAdd(aItemNota, {"D1_ALIQISS",  SD1->D1_ALIQISS,    Nil})
                    AAdd(aItemNota, {"D1_VALISS",   SD1->D1_VALISS,     Nil})
                    AAdd(aItemNota, {"D1_BASEINS",  SD1->D1_BASEINS,    Nil})
                    AAdd(aItemNota, {"D1_ALIQINS",  SD1->D1_ALIQINS,    Nil})
                    AAdd(aItemNota, {"D1_VALINS",   SD1->D1_VALINS,     Nil})
                    AAdd(aItemNota, {"D1_ALIQCF3",  SD1->D1_ALIQCF3,    Nil})
                    AAdd(aItemNota, {"D1_BASECF3",  SD1->D1_BASECF3,    Nil})
                    AAdd(aItemNota, {"D1_VALCF3",   SD1->D1_VALCF3,     Nil})
                    AAdd(aItemNota, {"D1_CRDZFM",   SD1->D1_CRDZFM,     Nil})

                    AAdd(aItensNota, AClone(aItemNota))
                    FwFreeObj(aItemNota)
                    aItemNota := Nil
                EndIf
                SD1->(DbSkip())
            End
        Else
            lOk     := .F.
            cErro   := "Nenhum Item para a Nota Fiscal encontrada."
        EndIf
    Else
        lOk     := .F.
        cErro   := "Nota Fiscal não encontrada para o Id de Integração informado."
    EndIf

    SET DELETED ON

Return lOk

User Function F1304799()

    cIdInteg := "fa151f42915b4000923631703f62ce8c    "

    RpcSetEnv("01", "01010004")

    cUserName := "Integrador"

    Begin Transaction

        U_F1304701(cIdInteg)

        DisarmTransaction()
        Break

    End Transaction

    RpcClearEnv()

Return Nil