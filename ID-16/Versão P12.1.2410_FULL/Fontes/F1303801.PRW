#Include "Protheus.ch"
#Include "Fileio.ch"

/*/{Protheus.doc} F1303801
Valida as informações para se caso possível, gerar o arquivo semaforo na pasta system\fs_semaforo\.

@project    MAN0000007423048_EF_038
@type       User Function
@author     Rafael Riego
@since      10/05/2018
@version    12.1.7
@param      cIdInteg, character, id de integração da nota fiscal a ser deletada
@param      cNovIdInt, character, novo id de integração gerado para esta integração
@param      nSF1Recno, numeric, recno do registro da tabela SF1
@return     lOk, retorno lógico do processamento
/*/
User Function F1303801(cIdInteg, cNovIdInt, nSF1Recno)

    Local aArea         := {}

    Local cCaminho      := ""
    Local cConteudo     := ""
    Local cNomeArq      := ""

    Local dMvUltMes     := CToD("  /  /    ")
    Local dDtDigit      := CToD("  /  /    ")

    Local lOk          := .T.

    Default cIdInteg    := ""
    Default cNovIdInt   := ""
    Default nSF1Recno   := 0

    SF1->(DbGoTo(nSF1Recno))

    dDtDigit := SF1->F1_DTDIGIT

    aArea       := {GetArea(), SX6->(GetArea())}

    cCaminho    := "\system\fs_semaforo\"
    cNomeArq    := cFilAnt + "_semaforo.txt"

    If U_F1303802(2, cCaminho, cNomeArq)
        dMvUltMes := GetMv("MV_ULMES")
        cConteudo := "IDINTEG: " + cIdInteg         + CRLF
        cConteudo += "DTDIGIT: " + DToS(dDtDigit)   + CRLF
        cConteudo += "DTULMES: " + DToS(dMvUltMes)  + CRLF
        //Caso o semaforo não exista, prosseguir
        U_F1303802(1, cCaminho, cNomeArq, cConteudo)
    EndIf

    AEval(aArea, {|area| RestArea(area)})

Return lOk

/*/{Protheus.doc} F1303802
Cria ou Deleta o arquivo de semaforo conforme parâmetro nOpcao informado.

@project    MAN0000007423048_EF_038
@type       User Function
@author     Rafael Riego
@since      10/05/2018
@version    12.1.7
@param      nOpcao, numeric, opção da ção a ser executada (1=inclusão;2=Exclusão)
@param      cDirArqSem, character, diretório do arquivo a ser criado
@param      cNomArqSem, character, nome (com a extenção) do arquivo a ser criado
@param      cConteudo, character, conteudo a ser gravado no arquivo
@return     lOk, retorno lógico do processamento
/*/
User Function F1303802(nOpcao, cDirArqSem, cNomArqSem, cConteudo)

    Local dFsUltMes     := CToD("  /  /    ")
    Local dMvUltMes     := CToD("  /  /    ")

    Local lArqExsite    := .F.
    Local lOk           := .T.

    Local nHandle       := Nil

    Default nOpcao      := 1 //1-Cria/2-Deleta
    Default cDirArqSem  := "\system\fs_semaforo\"
    Default cNomArqSem  := cFilAnt + "_semaforo.txt"
    Default cConteudo   := ""

    dFsUltMes := GetMv("FS_ULMES")
    dMvUltMes := GetMv("MV_ULMES")

    //Verifica a existência do diretório e o cria caso não exista
    If !(ExistDir(cDirArqSem))
        If !(MakeDir(cDirArqSem) == 0)
            lOk := .F.
            U_F1303703("Diretório do arquivo semaforo não existe e não pode ser criado", .F.)
        EndIf
    EndIf

    //Verifica a existência do arquivo no diretório criado acima
    If lOk
        If File(cDirArqSem + cNomArqSem)
            lArqExsite := .T.
            //Tenta abrir em modo exclusivo para deletá-lo
            nHandle := FOpen(cDirArqSem + cNomArqSem/*cNomeArq*/, FO_READWRITE + FO_EXCLUSIVE)
            If nHandle <> -1
                FClose(nHandle)
                If nOpcao == 1
                    lOk := DeltArqSem(cDirArqSem + cNomArqSem)
                EndIf
            Else
                lOk := .F.
                U_F1303703("Arquivo de semaforo em utilização. Não é possível prosseguir com a rotina.", .F.)
            EndIf
        EndIf
    EndIf

    //Caso o diretório exista e o arquivo não exista
    If lOk
        If nOpcao == 1
            lOk := CriaArqSem(cDirArqSem, cNomArqSem, cConteudo, .T.)
        ElseIf nOpcao == 2 .And. lArqExsite
            lOk := DeltArqSem(cDirArqSem + cNomArqSem)
        ElseIf nOpcao == 2 .And. !lArqExsite
            //Caso o FS_ULMES esteja preenchido e o MV_ULMES seja menor que o FS_ULMES, restaura o valor original do MV_ULMES
            If !(Empty(dFsUltMes)) .And. dMvUltMes < dFsUltMes
                U_F1303805(dFsUltMes)
            EndIf
        EndIf
    EndIf

    If lOk .And. FwIsInCallStack("U_F1303803")
        U_F1303703("O Arquivo foi deletado com sucesso ou não foi encontrado na pasta.", .T.)
    EndIf

Return lOk

//
/*/{Protheus.doc} F1303803
Exclui o arquivo de semaforo através do menu.

@project    MAN0000007423048_EF_038
@type       User Function
@author     Rafael Riego
@since      10/05/2018
@version    12.1.7
@return     Nil
/*/
User Function F1303803()

    Local cCaminho  := "\system\fs_semaforo\"
    Local cNomeArq  := cFilAnt + "_semaforo.txt"

    Local cResposta := ""

    U_F1303802(2, cCaminho, cNomeArq)

    cResposta := U_F1303705()

    Help("", 1, "HELP", "Semaforo", cResposta, 1, 0,,,,,,;
        {"não necessária."})

Return Nil

/*/{Protheus.doc} F1303804
Valida se o semaforo existe para não permitir executar nenhuma dos pontos de Entrada.

@project    MAN0000007423048_EF_038
@type       User Function
@author     Rafael Riego
@since      10/05/2018
@version    12.1.7
@param      cCaminho, character, diretório do arquivo a ser criado
@param      cNomeArq, character, nome (com a extenção) do arquivo a ser criado
@return     lOk, retorno lógico da verificação
/*/
User Function F1303804(cCaminho, cNomeArq)

    Local cResposta     := ""

    Local dFsDtUlMes    := ""
    Local dMvDtUlMes    := ""

    Local lOk           := .T.

    Default cCaminho := "\system\fs_semaforo\"
    Default cNomeArq := cFilAnt + "_semaforo.txt"

    dMvDtUlMes    := GetMv("MV_ULMES")
    dFsDtUlMes    := GetMv("FS_ULMES")

    If !(U_F1303802(2, cCaminho, cNomeArq))
        lOk := .F.
        cResposta := U_F1303705()
        If cResposta != "OK"
            Help("", 1, "HELP", "Semaforo", cResposta, 1, 0,,,,,,;
                {""})
        EndIf
    EndIf

Return lOk

/*/{Protheus.doc} F1303805
Atualiza os valores contidos nos parâmetros MV_ULMES e FS_ULMES.

@@type      User Function
@author     Rafael Riego
@since      10/05/2018
@version    12.1.7
@param      dFsDtUlMes, date, valor a ser atribuído no parâmetro MV_ULMES
@param      dMvDtUlMes, date, valor a ser atribuído no parâmetro FS_ULMES
@return     Nil
/*/
User Function F1303805(dFsDtUlMes, dMvDtUlMes)

    Default dFsDtUlMes  := CToD("  /  /    ")
    Default dMvDtUlMes  := CToD("  /  /    ")

    If !(Empty(dFsDtUlMes))
		//Início - Thais Paiva - Compatibilização P27
        //SX6->(DbSeek(SX6->X6_FIL + "MV_ULMES"))
        //RecLock("SX6", .F.)
        //SX6->X6_CONTEUD := DToS(dFsDtUlMes)
        //SX6->(MsUnlock())
		If FWSX6Util():ExistsParam( "MV_ULMES" )
			
			PUTMV("MV_ULMES", DToS(dFsDtUlMes))
			   
		EndIf
		//Fim - Thais Paiva - Compatibilização P27
    EndIf

    If !(Empty(dMvDtUlMes))
		//Início - Thais Paiva - Compatibilização P27
        //SX6->(DbSeek(SX6->X6_FIL + "FS_ULMES"))
        //RecLock("SX6", .F.)
        //SX6->X6_CONTEUD := DToS(dMvDtUlMes)
        //SX6->(MsUnlock())
		If FWSX6Util():ExistsParam( "FS_ULMES" )
			
			PUTMV("FS_ULMES", DToS(dMvDtUlMes))
			   
		EndIf
		//Fim - Thais Paiva - Compatibilização P27
    EndIf

Return Nil

/*/{Protheus.doc} F1303805
Valida se as rotinas externas podem prosseguir com a execução.

@@type      User Function
@author     Rafael Riego
@since      11/07/2018
@version    12.1.7
@return     Nil
/*/
User Function F1303806()

    Local cDirArqSem    := "\system\fs_semaforo\"
    Local cNomArqSem    := cFilAnt + "_semaforo.txt"

    Local dFsUltMes     := CToD("  /  /    ")

    Local lExistVar     := .T.
    Local lOk           := .T.

    Local nHandle       := 0

    dFsUltMes := GetMv("FS_ULMES")

    //Variavel private declarada nas rotinas de integração
    If Type("dDtValExec") == "U"
        lExistVar := .F.
    EndIf

    //Se a variável não existir não há necessidade de prosseguir
    If lExistVar
        //se o arquivo de semaforo existir, deverá ser validado
        If File(cDirArqSem + cNomArqSem)
            //Tenta abrir em modo exclusivo para deletá-lo
            nHandle := FOpen(cDirArqSem + cNomArqSem/*cNomeArq*/, FO_READWRITE + FO_EXCLUSIVE)
            If nHandle <> -1
                FClose(nHandle)
            Else
                //Verificar o FS_ULMES pois o mesmo deverá ter o valor original do parametro MV_ULMES
                If Empty(dDtValExec)
                    lOk := .F.
                ElseIf dDtValExec <= dFsUltMes
                    lOk := .F.
                EndIf
            EndIf
        EndIf
    EndIf

Return lOk

/*/{Protheus.doc} CriaArqSem
Cria arquivo de semaforo.

@@type      Static Function
@author     Rafael Riego
@since      10/05/2018
@version    12.1.7
@param      nOpcao, numeric, opção da ção a ser executada (1=inclusão;2=Exclusão)
@param      cDirArqSem, character, diretório do arquivo a ser criado
@param      cNomArqSem, character, nome (com a extenção) do arquivo a ser criado
@param      cConteudo, character, conteudo a ser gravado no arquivo
@param      lSetHandle, boolean, se deve ou não atribuir valor do handle do arquivo aberto a variável static da rotina F1303701 (inclusão de nota).
@return     lOk, retorno lógico do processamento
/*/
Static Function CriaArqSem(cDirArqSem, cNomArqSem, cConteudo, lSetHandle)

    Local dFsUltMes := CToD("  /  /    ")
    Local dMvUltMes := CToD("  /  /    ")

    Local lOk       := .T.

    Local nHandle   := 0

    Default lSetHandle  := .F.

    dMvUltMes := GetMv("MV_ULMES")
    dFsUltMes := GetMv("FS_ULMES")

    nHandle := FCreate(cDirArqSem + cNomArqSem)

    If nHandle == -1
        lOk := .F.
        U_F1303703("Não foi possível criar arquivo de semaforo. Impossível prosseguir.", .F.)
    Else
        If !(Empty(cConteudo))
            FWrite(nHandle, cConteudo)
        EndIf
        //Seta a variavel static ou fecha o arquivo
        If lSetHandle
            U_F1303706(nHandle)
        Else
            FClose(nHandle)
        EndIf

        //Caso o FS_ULMES esteja preenchido e o MV_ULMES seja menor que o FS_ULMES, restaura o valor original do MV_ULMES
        If !(Empty(dFsUltMes)) .And. dMvUltMes < dFsUltMes
            U_F1303805(dFsUltMes)
        EndIf

        //Pega o último dia do mes anterior (data de fechamento anterior)
        dFsUltMes := LastDate(MonthSub(dMvUltMes, 1))

        //Atualiza parâmetro FS_ULMES e MV_ULMES
        //Retrocede o MV_ULMES em 1 e mantem o backup do ultimo valor do MV_ULMES
        U_F1303805(dFsUltMes, dMvUltMes)
    EndIf

Return lOk

/*/{Protheus.doc} DeltArqSem
Deleta arquivo de semaforo.

@@type      Static Function
@author     Rafael Riego
@since      10/05/2018
@version    12.1.7
@param      nOpcao, numeric, opção da ção a ser executada (1=inclusão;2=Exclusão)
@param      cDirArqSem, character, caminho do completo do arquivo a ser deletado
@return     lOk, se conseguiu deletar o arquivo ou não
/*/
Static Function DeltArqSem(cDirArqSem)

    Local lOk       := .T.

    Local dFsUltMes := CToD("  /  /    ")
    Local dMvUltMes := CToD("  /  /    ")

    Local nHandle   := 0

    dFsUltMes := GetMv("FS_ULMES")
    dMvUltMes := GetMv("MV_ULMES")

    nHandle := FErase(cDirArqSem)

    If nHandle == -1
        lOk := .F.
        U_F1303703("Não foi possível deletar o arquivo de semaforo.", .T.)
    EndIf

    //Caso o FS_ULMES esteja preenchido e o MV_ULMES seja menor que o FS_ULMES, restaura o valor original do MV_ULMES
    If !(Empty(dFsUltMes)) .And. dMvUltMes < dFsUltMes
        U_F1303805(dFsUltMes)
    EndIf

Return lOk