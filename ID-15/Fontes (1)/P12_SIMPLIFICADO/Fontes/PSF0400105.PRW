#Include "PROTHEUS.CH"
/*{Protheus.doc} F0400105()
Função para excluir arquivos compactados do banco de conhecimento
quando excluído o documento de origem.
@Author     Paulo Krüger
@Since          25/10/2016
@Version        P12.7
@Project        MAN00000463801_EF_001
@param cRotina, characters, descricao
@param cFilOri, characters, descricao
@param cChave, characters, descricao
@Return     nil  */

User Function F0400105(cRotina, cFilOri, cChave)

    Local cAlias01  :=  ''
    Local cArqRed   :=  '\RDANEXOS\' + FWxFilial("P09")
    Local cRootPath :=  GetSrvProfString('ROOTPATH','')
    Local nHdl      :=  0
    Local lRet      :=  .T.
    Local cMensErro :=  ''
    Local cTabAlias :=  'P09'
    Local aArea     := GetArea()
    Local aAreaP09  := P09->(GetArea())
    Default cRotina :=  ''
    Default cFilOri :=  ''
    Default cChave  :=  ''

    cAlias01 := GetNextAlias()

    BeginSql alias cAlias01

    SELECT  P09.P09_CODDOC ARQUIVO,
            P09.R_E_C_N_O_ NRECNO
    FROM    %table:P09% P09
    WHERE       P09.%notDel%
            AND P09_FILIAL  =   %exp:cFilOri%
            AND P09_ROTINA  =   %exp:cRotina%
            AND P09_CODORI  =   %exp:cChave%
    ORDER BY 1

    EndSql

    dBSelectArea('P09')

    While !(cAlias01)->(Eof())
        P09->(dBGoTo((cAlias01)->NRECNO))
        If SimpleLock()
            P09->(dbDelete())
            P09->(MsUnLock())
        Else
            lRet := .F.
        EndIf
        If lRet
            // Rafael Falco 07/06/2018 - ajuste para quando a rotina for executada através do WS de devolução de nota fiscal de entrada
            If FwIsInCallStack("U_F1303701")
                cRootPath := "/"
            EndIf
            If File(cRootPath + cArqRed + (cAlias01)->ARQUIVO + '.MZP')
                nHdl := FErase( cRootPath + cArqRed + (cAlias01)->ARQUIVO + '.MZP', ,)
                If nHdl < 0
                    cMensErro += 'Erro ao excluir arquivo: ' + cRootPath + cArqRed + (cAlias01)->ARQUIVO + '.MZP ' + ' - Cod: ' + STR(FError(),04) + CRLF
                EndIf
            Else
                cMensErro += 'Erro ao excluir arquivo: ' + cRootPath + cArqRed + (cAlias01)->ARQUIVO + '.MZP ' + ' - Cod: ' + STR(FError(),04) + CRLF
            EndIf
        EndIf
        (cAlias01)->(dBSkip())
    EndDo
    (cAlias01)->(dBCloseArea())

    If !Empty(cMensErro)
        conout(cMensErro)
    EndIf

    RestArea(aAreaP09)
    RestArea(aArea)

Return lRet