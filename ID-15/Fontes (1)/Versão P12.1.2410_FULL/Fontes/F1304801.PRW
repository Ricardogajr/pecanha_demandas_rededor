#Include 'Protheus.ch'

/*/{Protheus.doc} F1304801
Realiza a inclusão do(s) título(s) com os dados da(s) Nota Fiscal Excluída anteriormente no processo de integração.

@project    MAN0000007423048_EF_048
@@type      User Function
@author     Rafael Riego
@since      15/05/2018
@version    12.1.7
@param      cIdInteg, character, Id gerado para esta integração de Inclusão de Nota
@return     lOk, se a movimentação ocorreu com sucesso ou não
/*/
User Function F1304801(cIdInteg)

    Local aArea         := {}
    Local aLog          := {}
    Local aTitulos      := {}
    Local aTitulo       := {}

    Local cErro         := ""

    Local lOk           := .T.

    Local nErro         := 0
    Local nTitulo       := 0
    Local nQtdTitulos   := 0

    Private lMsErroAuto := .F.

    Default cIdInteg    := ""

    aArea := {GetArea(), SE2->(GetArea())}

    SET DELETED OFF

    SE2->(DbOrderNickName("EF1304801"))
    If SE2->(DbSeek(cIdInteg))
        While SE2->(!(EoF())) .And. SE2->E2_XIDEXNF == cIdInteg

            aTitulo := {}

            AAdd(aTitulo, {"E2_PREFIXO",    SE2->E2_PREFIXO,    Nil})
            AAdd(aTitulo, {"E2_NUM",        SE2->E2_NUM,        Nil})
            AAdd(aTitulo, {"E2_PARCELA",    SE2->E2_PARCELA,    Nil})
            AAdd(aTitulo, {"E2_TIPO",       SE2->E2_TIPO,       Nil})
            AAdd(aTitulo, {"E2_NATUREZ",    SE2->E2_NATUREZ,    Nil})
            AAdd(aTitulo, {"E2_FORNECE",    SE2->E2_FORNECE,    Nil})
            AAdd(aTitulo, {"E2_LOJA",       SE2->E2_LOJA,       Nil})
            AAdd(aTitulo, {"E2_EMISSAO",    SE2->E2_EMISSAO,    Nil})
            AAdd(aTitulo, {"E2_VENCTO",     SE2->E2_VENCTO,     Nil})
            AAdd(aTitulo, {"E2_VENCREA",    SE2->E2_VENCREA,    Nil})
            AAdd(aTitulo, {"E2_VENCORI",    SE2->E2_VENCORI,    Nil})
            AAdd(aTitulo, {"E2_VALOR",      SE2->E2_VALOR,      Nil})
            AAdd(aTitulo, {"E2_SALDO",      SE2->E2_SALDO,      Nil})
            AAdd(aTitulo, {"E2_MOEDA",      SE2->E2_MOEDA,      Nil})
            AAdd(aTitulo, {"E2_VLCRUZ",     SE2->E2_VLCRUZ,     Nil})
            AAdd(aTitulo, {"E2_CCUSTO",     SE2->E2_CCUSTO,     Nil})
            AAdd(aTitulo, {"E2_XID",        SE2->E2_XID,        Nil})

            AAdd(aTitulos, AClone(aTitulo))
            FwFreeObj(aTitulo)
            aTitulo := Nil
            SE2->(DbSkip())
        End

        SET DELETED ON

        nQtdTitulos := Len(aTitulos)

        For nTitulo := 1 To nQtdTitulos

            MsExecAuto({|titulo, y, operacao| FINA050(titulo, y, operacao)}, aTitulos[nTitulo],, 3)

            If lMsErroAuto
                cErro += "INCONSISTENCIA DE ROTINA AUTOMATICA - EXCLUSÃO DE TÍTULO | " + CRLF
                aLog := GetAutoGRLog()
                For nErro := 1 To Len(aLog)
                    cErro += aLog[nErro] + CRLF
                Next nErro
                lOk := .F.
                Exit
            EndIf
        Next nTitulo
    //Else
    //   lOk     := .F.
    //    cErro   := "Título não encontrado para esse Id de integração."
    EndIf

    If !lOk
        U_F1303703(cErro, .F.)
    EndIf

    FwFreeObj(aTitulos)
    FwFreeObj(aLog)
    aTitulos := Nil
    aLog := Nil

    AEval(aArea, {|area| RestArea(area)})

Return lOk

User Function F1304899()

    Private lAutoErrNoFile  := .T.

    RpcSetEnv("01", "01010004")

    Begin Transaction

        U_F1304801("c3dc778e882e40009725bd283565ee60")

        DisarmTransaction()
        Break

        Alert("Cancelamento")

    End Transaction

    RpcClearEnv()

    lAutoErrNoFile := Nil

Return Nil