#Include "Protheus.ch"

/*/{Protheus.doc} F1303901
Exclui os títulos gerados via integração de entrada de NF.

@project    MAN0000007423048_EF_039
@@type      User Function
@author     Nairan Alves Silva
@since      02/05/2018
@version    12.1.7
@param      cIdInteg, character, novo id de integração da nota fiscal a ser deletada
@param      cNovIdInt, character, id da integração da exclusão/devolução
@return     lOk, se excluiu com sucesso ou não
/*/
User Function F1303901(cIdInteg, cNovIdInt)

    Local aArea     := {}
    Local aTitulo   := {}
    Local aLog      := {}

    Local cErro     := ""

    Local lOk       := .T.

    Local nErro     := 0

    Private lMsErroAuto     := .F.

    Default cIdInteg    := ""
    Default cNovIdInt   := ""

    aArea := {GetArea(), SE2->(GetArea())}

    SE2->(DbOrderNickName("EF0703301"))
    If SE2->(DbSeek(FwXFilial("SE2") + cIdInteg))
        While SE2->(!(EoF())) .And. SE2->E2_FILIAL == FwXFilial("SE2") .And. SE2->E2_XID == cIdInteg
            RecLock("SE2", .F.)
                SE2->E2_XIDEXNF := cNovIdInt
            SE2->(MsUnlock())
            aTitulo := {}
            AAdd(aTitulo, {"E2_NUM",        SE2->E2_NUM,        Nil})
            AAdd(aTitulo, {"E2_PREFIXO",    SE2->E2_PREFIXO,    Nil})
            AAdd(aTitulo, {"E2_PARCELA",    SE2->E2_PARCELA,    Nil})
            AAdd(aTitulo, {"E2_TIPO",       SE2->E2_TIPO,       Nil})
            AAdd(aTitulo, {"E2_FORNECE",    SE2->E2_FORNECE,    Nil})
            AAdd(aTitulo, {"E2_LOJA",       SE2->E2_LOJA,       Nil})

            MsExecAuto({|titulo, nulo, operacao| FINA050(titulo, nulo, operacao)}, aTitulo,, 5)

            FwFreeObj(aTitulo)
            aTitulo := Nil
            If lMsErroAuto
                cErro += "INCONSISTENCIA DE ROTINA AUTOMATICA - EXCLUSÃO DE TÍTULO | " + CRLF
                aLog := GetAutoGRLog()
                For nErro := 1 To Len(aLog)
                    cErro += aLog[nErro] + CRLF
                Next nErro
                lOk := .F.
                Exit
            EndIf
            SE2->(DbSkip())
        End
    //Else
    //    cErro   := "Nenhum título não encontrado para esse Id de integração."
    //    lOk     := .F.
    EndIf

    If !lOk
        U_F1303703(cErro, .F.)
    EndIf

    AEval(aArea, {|area| RestArea(area)})

Return lOk

User Function F1303999()

    Private lAutoErrNoFile  := .T.

    RpcSetEnv("01", "01010004")

    Begin Transaction

        U_F1303901("702e39b0a1764000804F23efeacc7b1e", "18d85f388cb4400093B434ebdafc5858")

        //DisarmTransaction()
        //Break

        Alert("Cancelamento")

    End Transaction

    RpcClearEnv()

    lAutoErrNoFile := Nil

Return Nil