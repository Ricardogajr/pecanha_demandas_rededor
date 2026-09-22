#Include 'Protheus.ch'
#INCLUDE "APWebSrv.ch"

Static nSCRRecno    := 0

User Function W1701301() //dummy-function
Return

WSStruct SolicitacaoAlcada

    WSData codEmpresa   As String
    WSData codFilial    As String
    WSData codTipo      As String
    WSData codNum       As String
    WSData codNivel     As String
    WSData codUsuario   As String
    WSData codStatus    As String

EndWSStruct

WSStruct RespostaFluig

    WSData Resultado    As String
    WSData mensagemErro As String

EndWSStruct

WSService W1701301 Description "Serviço para atualização de alçada de aprovação do BackOffice"

    WSData Solicitacao  As SolicitacaoAlcada
    WSData Resposta     As RespostaFluig

    WSMethod AtualizaSolicitacaoAprovacao Description "Atualiza alçada de aprovação do BackOffice"

EndWSService

WSMethod AtualizaSolicitacaoAprovacao WSReceive Solicitacao WSSend Resposta WSService W1701301

    Local cEmpSCR   := ""
    Local cFilSCR   := ""
    Local cNivelSCR := ""
    Local cNumSCR   := ""
    Local cTipoSCR  := ""
    Local cUserSCR  := ""

    Local lAprovac  := .T.

    cEmpSCR     := ::Solicitacao:codEmpresa
    cFilSCR     := ::Solicitacao:codFilial
    cNumSCR     := Padr(::Solicitacao:codNum, TamSX3("CR_NUM")[1])
    cTipoSCR    := ::Solicitacao:codTipo
    cNivelSCR   := ::Solicitacao:codNivel
    cUserSCR    := ::Solicitacao:codUsuario
    lAprovac    := IIf(::Solicitacao:codStatus == "1", .T., .F.)

    ::Resposta:Resultado    := "OK"
    ::Resposta:mensagemErro := ""

    aRetorno := U_F1701301(cEmpSCR, cFilSCR, cTipoSCR, cNumSCR, cNivelSCR, cUserSCR, lAprovac)

    If !(aRetorno[1])
        ::Resposta:Resultado    := "NOK"
        ::Resposta:mensagemErro := aRetorno[2]
    ELSE
        ::Resposta:Resultado    := "OK"
        ::Resposta:mensagemErro := aRetorno[2]
    EndIf

Return .T.

/*/{Protheus.doc} F1701301
Efetua aprovação ou reprovação da alçada.

@project
@type       User Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      cEmpSCR, boolean, empresa da alçada
@param      cFilSCR, character, filial da alçada
@param      cTipoSCR, character, tipo de alçada (PC, CT, RV, MD, SP, SC)
@param      cNumSCR, character, código da alçada
@param      cNivelSCR, character, nível da alçada
@param      cUserSCR, character, usuário que aprovou alçada
@param      lAprovac, character, true se aprovação e false se reprovação
@return     aRetorno, [1] lRetorno, [2] Mensagem de Resultado
/*/
User Function F1701301(cEmpSCR, cFilSCR, cTipoSCR, cNumSCR, cNivelSCR, cUserSCR, lAprovac)

    Local aArea         := {}
    Local aRetorno      := {}

    Local cCodUser      := ""
    Local cCodUsrBkp    := ""
    Local cFilAtu       := ""
    Local cFilBkp       := ""
    Local cUserBkp      := ""

    Local lOk           := .T.

    Local nOperacao     := 4
    Local nSM0Recno     := 0
    Local nPswOrder     := 0

    Local oModel        := Nil

    Private aCamposC7   := {}
    Private aCamposDBL  := {}

    Private cFieldSC7   := ""

    DbSelectArea("SCR")

    aArea := {GetArea(), SCR->(GetArea())}

    cFilAtu := FwCodFil()

    aRetorno := PreValid(cEmpSCR, cFilSCR, cTipoSCR, cNumSCR, cNivelSCR, cUserSCR)

    If aRetorno[1]
        If cFilAnt != cFilSCR
            cFilBkp := cFilAtu
            cFilAnt := cFilSCR
            nSM0Recno := SM0->(Recno())
            SM0->(DbSeek(FwCodEmp() + cFilSCR))
        EndIf

        SCR->(DbSetOrder(2)) //CR_FILIAL + CR_TIPO + CR_NUM + CR_USER
        SCR->(DbGoTo(nSCRRecno))//DbSeek(FwXFilial("SCR") + cTipoSCR + cNumSCR + cUserSCR))
        nOperacao := IIf(lAprovac, 4, 7)

        //#DEFINE OP_LIB  "001" // Liberado
        //#DEFINE OP_EST  "005" // Estornar
        If lAprovac
            cIdOperac := "001"
        Else
            cIdOperac := "005"
        EndIf

        cUserBkp    := cUserName
        cCodUser    := SCR->CR_USER
        cUserName   := UsrRetName(cCodUser)
        nPswOrder   := PswOrder(1)
        cCodUsrBkp  := __cUserId
        __cUserId   := cCodUser

        PswSeek(cCodUser, .T.)

        A094SetOp(cIdOperac)

        //Trecho copiado do padrão para evitar errorlog
        aCamposC7   := MtGetFec("SC7", "C7")
        aCamposDBL  := MtGetFec("DBL", "DBL")

        AEval(aCamposC7, {|campo| cFieldSC7 += "|" + campo})

        oModel := FwLoadModel("MATA094") 

        oModel:SetOperation(4)

        If oModel:Activate()
            oModel:SetValue("FieldSCR", "CR_OBS", "Alçada " + IIf(lAprovac, "aprovada", "reprovada") + " via Fluig.")
            If oModel:VldData() 
                Begin Transaction
                    oModel:CommitData()
                    //restaura após o commit para ser verificado se foi liberado/rejeitado com sucesso
                    SCR->(DbGoTo(nSCRRecno))
                    SCR->(DbSetOrder(2)) //CR_FILIAL + CR_TIPO + CR_NUM + CR_USER
                    If !(SCR->(DbSeek(FwXFilial("SCR") + cTipoSCR + cNumSCR + cUserSCR)) .And. SCR->CR_STATUS $ IIf(lAprovac, "03", "05|06"))
                        aRetorno[1] := .F.
                        aRetorno[2] := "Erro na " + IIf(lAprovac, "aprovação", "reprovação") + " da alçada. Verifique o motivo no sistema Protheus."
                        DisarmTransaction()
                    EndIf
                End Transaction
            Else
                aRetorno[1] := .F.
                aRetorno[2] := "Erro: " + AllTrim(oModel:GetErrorMessage()[6]) + " Solução: " + AllTrim(oModel:GetErrorMessage()[7])
            EndIf
        Else
            aRetorno[1] := .F.
            aRetorno[2] := "Erro: " + AllTrim(oModel:GetErrorMessage()[6]) + " Solução: " + AllTrim(oModel:GetErrorMessage()[7])
        EndIf

        cUserName := cUserBkp
        __cUserId := cCodUsrBkp
        PswOrder(nPswOrder)
        PswSeek(cCodUser, .T.)

        If !(Empty(cFilBkp))
            cFilAnt := cFilBkp
            SM0->(DbGoTo(nSM0Recno))
        EndIf
    EndIf

    AEval(aArea, {|area| RestArea(area)})

Return aRetorno

/*/{Protheus.doc} PreValid
Pré validação da alçada a ser aprovada.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      cEmpSCR, boolean, empresa da alçada
@param      cFilSCR, character, filial da alçada
@param      cTipoSCR, character, tipo de alçada (PC, CT, RV, MD, SP, SC)
@param      cNumSCR, character, código da alçada
@param      cNivelSCR, character, nível da alçada
@param      cUserSCR, character, usuário que aprovou alçada
@return     aRetorno, [1] lRetorno, [2] Mensagem de Resultado
/*/
Static Function PreValid(cEmpSCR, cFilSCR, cTipoSCR, cNumSCR, cNivelSCR, cUserSCR)

    Local aArea     := {}

    Local cMsgErro  := "OK"

    Local lOk       := .T.

    aArea := {GetArea(), SCR->(GetArea())}

    If cEmpSCR != FwCodEmp()
        cMsgErro    := "Empresa informada é inválida."
        lOk         := .F.
    ElseIf !(FwFilExist(cEmpSCR, cFilSCR))
        cMsgErro    := "Filial informada não existe para a Empresa informada."
        lOk         := .F.
    ElseIf !(VerifNivel(cFilSCR, cTipoSCR, cNumSCR, cNivelSCR, cUserSCR, @cMsgErro))
        lOk         := .F.
    EndIf

    AEval(aArea, {|area| RestArea(area)})

Return {lOk, cMsgErro}

/*/{Protheus.doc} VerifNivel
Verifica se o usuário existe no nível que foi informado

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      cFilSCR, character, filial da alçada
@param      cTipoSCR, character, tipo de alçada (PC, CT, RV, MD, SP, SC)
@param      cNumSCR, character, código da alçada
@param      cNivelSCR, character, nível da alçada
@param      cUserSCR, character, usuário que aprovou alçada
@return     lOk, se enco
/*/
Static Function VerifNivel(cFilSCR, cTipoSCR, cNumSCR, cNivelSCR, cUserSCR, cMsgErro)

    Local aArea         := {}

    Local lEncontrad    := .F.
    Local lOk           := .T.

    aArea := {SCR->(GetArea()), GetArea()}

    SCR->(DbSetOrder(1))
    If SCR->(DbSeek(cFilSCR + cTipoSCR + cNumSCR + cNivelSCR))
        While SCR->(!(EoF())) .And.;
                SCR->CR_FILIAL == cFilSCR .And. SCR->CR_TIPO == cTipoSCR .And. SCR->CR_NUM == cNumSCR .And. SCR->CR_NIVEL == cNivelSCR

            If SCR->CR_USER == cUserSCR
                lEncontrad  := .T.
                nSCRRecno   := SCR->(Recno())
                Exit
            EndIf
            SCR->(DbSkip())
        End

        If lEncontrad
            If SCR->CR_STATUS == "01"
                cMsgErro    := "Alçada se encontra aguardando nível anterior de aprovação."
                lOk         := .F.
            ElseIf SCR->CR_STATUS == "04"
                cMsgErro    := "Alçada se encontra bloqueada. Não é possível aprovar ou reprovar alçada."
                lOk         := .F.
            ElseIf SCR->CR_STATUS $ "03|05|06"
                cMsgErro    := "Alçada se encontra aprovada. Não é possível aprovar ou reprovar alçada."
                lOk         := .F.
            EndIf
        Else
            cMsgErro := "Alçada de aprovação não encontrada para o usuário no nível informado."
            lOk         := .F.
        EndIf
    Else
        cMsgErro := "Alçada de aprovação não encontrada. Verifique se a mesma não foi excluída no Protheus."
        lOk         := .F.
    EndIf

    AEval(aArea, {|area| RestArea(area)})

Return lOk