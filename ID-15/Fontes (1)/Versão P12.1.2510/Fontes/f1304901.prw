#Include "Protheus.ch"

User Function F1304901()

    Local nRecnoSC7     := 0
    Local cBkpUsr     := __CUSERID
    If !(Empty(SC7->C7_XIDEXNF))
        nRecnoSC7 := SC7->(Recno())
        AltrFornec(nRecnoSC7)
    Else
        cMensagem   := "Pedido de compra não é originado pela integração de Devolução de Notas Fiscais para Meses Fechados."
        Help("", 1, "HELP", "Alt. Fornecedor", cMensagem, 1, 0,,,,,,;
            {""})
    EndIf
__cUserId := cBkpUsr
Return Nil

Static Function AltrFornec(nRecnoSC7)

    Local aAreas        := {}
    Local aButtons      := {}

    Local cCodFornec    := ""
    Local cLojFornec    := ""
    Local cMensagem     := ""
    Local cNomFornec    := ""

    Local cNvCodForn    := ""
    Local cNvLojForn    := ""
    Local cNvNomForn    := ""

    Local oDlg          := Nil

    Default nRecnoSC7   := 0

    aAreas := {GetArea(), SC7->(GetArea())}

    If !(Empty(nRecnoSC7))
        SC7->(DbGoTo(nRecnoSC7))
    EndIf

    cCodFornec  := SC7->C7_FORNECE
    cLojFornec  := SC7->C7_LOJA
    cNomFornec  := GetAdvFVal("SA2", "A2_NOME", FwXFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA, 1, SC7->C7_XNOMFOR, .T.)
    cNvCodForn  := Space(TamSX3("C7_FORNECE")[1])
    cNvLojForn  := Space(TamSX3("C7_LOJA")[1])
    cNvNomForn  := Space(TamSX3("C7_XNOMFOR")[1])

    DEFINE MSDIALOG oDlg TITLE "Pedido de Compra - Alteração do Fornecedor" STYLE DS_MODALFRAME FROM 0, 0 TO 180, 700 PIXEL

    //ROW, COL

    //1a Coluna
    @ 040, 005  SAY "Cód. Fornecedor (Atual):"  SIZE 200, 008   PIXEL OF oDlg
    @ 040, 070  MSGET   cCodFornec  PICTURE "@!"    SIZE 020, 010   READONLY    PIXEL OF oDlg

    //2a Coluna
    @ 040, 105  SAY "Loja (Atual):"  SIZE 200, 008   PIXEL OF oDlg
    @ 040, 140  MSGET   cLojFornec  PICTURE "@!"    SIZE 010, 010   READONLY    PIXEL OF oDlg

    //3a Coluna
    @ 040, 160  SAY "Fornecedor (Atual):"  SIZE 200, 008   PIXEL OF oDlg
    @ 040, 210  MSGET   cNomFornec  PICTURE "@!"    SIZE 120, 010   READONLY    PIXEL OF oDlg

    //1a Coluna
    @ 055, 005  SAY "Cód. Fornecedor (Novo):"   SIZE 200, 008   PIXEL OF oDlg
    @ 055, 070  MSGET cNvCodForn  PICTURE "@!"  VALID VldFornec(cCodFornec, cLojFornec, cNvCodForn, cNvLojForn, @cNvNomForn) SIZE 010, 010   F3 "VV6A"   PIXEL OF oDlg

    //2a Coluna
    @ 055, 105  SAY "Loja (Novo):"    SIZE 200, 008 PIXEL OF oDlg
    @ 055, 140  MSGET cNvLojForn  PICTURE "@!"  VALID VldFornec(cCodFornec, cLojFornec, cNvCodForn, cNvLojForn, @cNvNomForn) SIZE 010, 010   PIXEL OF oDlg

    //3a Coluna
    @ 055, 160  SAY "Fornecedor (Novo):"   SIZE 200, 008 PIXEL OF oDlg
    @ 055, 210  MSGET cNvNomForn    PICTURE "@!"    SIZE 120, 010   READONLY    PIXEL OF oDlg

    ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,;
        {|| IIf(ValidGeral(cCodFornec, cLojFornec, cNvCodForn, cNvLojForn),;
        IIf(ExecDelGrv(cNvCodForn, cNvLojForn), oDlg:End(), Nil), Nil)}, {|| oDlg:End()},, aButtons,,, .F., .F., .F., .T., .F.)

Return Nil

/*/{Protheus.doc} ValidGeral
Validação geral do fornecedor.

@type       static function
@author     Rafael Riego
@since      28/05/2018
@version    1.0
@param      cCodForAtu, character, código do fornecedor atual do pedido de compra
@param      cCodLojAtu, character, loja do fornecedor atual do pedido de compra
@param      cCodForNov, character, novo código do fornecedor
@param      cCodLojNov, character, nova loja do fornecedor
@return     lOk, se as informações foram validadas ou não
/*/
Static Function ValidGeral(cCodForAtu, cCodLojAtu, cCodForNov, cCodLojNov)

    Local lOk   := .T.

    Default cCodForAtu  := ""
    Default cCodLojAtu  := ""
    Default cCodForNov  := ""
    Default cCodLojNov  := ""

    lOk := VldFornec(cCodForAtu, cCodLojAtu, cCodForNov, cCodLojNov)

Return lOk

Static Function ExecDelGrv(cCodForNov, cCodLojNov)

    Local aArea         := {}

    Local cCompGener    := ""
    Local cCodUsrBkp    := ""
    Local cGrpComBkp    := ""
    Local cNumPedido    := ""
    Local cUserBkp      := ""

    Local lOk           := .T.
    Local lRestaura     := .F.

    Local nPswOrder     := 0

    aArea := {GetArea(), SY1->(GetArea()), SC7->(GetArea())}

    cCompGener  := GetMv("FS_COMPGEN")

    If ValType(cCompGener) == "C" .And. !(Empty(cCompGener))
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
        Help("", 1, "HELP", "Comprador", "Parâmetro 'FS_COMPGEN' não existe ou não está preenchido.", 1, 0,,,,,,;
            {""})
        lOk := .F.
    EndIf

    If lOk
        cNumPedido  := SC7->C7_NUM
        cGrpComBkp  := SC7->C7_GRUPCOM

        Begin Transaction

            If !(AltGrupCom(cNumPedido, SY1->Y1_GRUPCOM))
                lOk := .F.
                DisarmTransaction()
                Break
            EndIf

            //Exclui Documentos com Alcada
            DeletSCR(cNumPedido)

            //Exclui Historico Pedidos de Compras
            DeletSCY(cNumPedido)

            //Altera Fornecedor e Loja do Pedido de Compra
            If !(RegrvForne(cNumPedido, cCodForNov, cCodLojNov))
                lOk := .F.
                DisarmTransaction()
                Break
            EndIf

            If !(AltGrupCom(cNumPedido, cGrpComBkp))
                lOk := .F.
                DisarmTransaction()
                Break
            EndIf

        End Transaction
        If lOk
            MsgInfo("Fornecedor alterado com sucesso!","Alteração de fornecedor.")
            //Help("", 1, "HELP", "Alt. Fornec", "Fornecedor alterado com sucesso.", 1, 0,,,,,,{""})
        EndIf
    EndIf

    If lRestaura
        cUserName := cUserBkp
        __cUserId := cCodUsrBkp
        PswOrder(nPswOrder)
    EndIf

    AEval(aArea, {|area| RestArea(area)})

Return lOk

//Altera o grupo de compras do pedido para o grupo de compras do usuário integrador para que seja possível modificar o pedido de compras
Static Function AltGrupCom(cNumPedido, cGrupoComp)

    Local lOk   := .T.

    Default cNumPedido  := ""
    Default cGrupoComp  := ""

    If SC7->(DbSeek(FwXFilial("SC7") + cNumPedido))
        While SC7->(!(EoF())) .And. SC7->C7_FILIAL == FwXFilial("SC7") .And. SC7->C7_NUM == cNumPedido
            RecLock("SC7", .F.)
                SC7->C7_GRUPCOM := cGrupoComp
            SC7->(MsUnlock())
            SC7->(DbSkip())
        End
    Else
        Help("", 1, "HELP", "Alt. Fornec", "Erro ao encontrar Pedido de Compra.", 1, 0,,,,,,;
            {""})
        lOk := .F.
    EndIf

Return lOk

Static Function DeletSCR(cNumPedido)

    Local aAreas := {}

    Default cNumPedido  := ""

    aAreas := {GetArea(), SCR->(GetArea())}

    SCR->(DbSetOrder(1))
    If SCR->(DbSeek(FwXFilial("SCR") + "PC" + cNumPedido))
        While SCR->(!(EoF())) .And. SCR->CR_FILIAL == FwXFilial("SCR") .And. SCR->CR_TIPO == "PC" .And. SCR->CR_NUM == cNumPedido
            RecLock("SCR", .F.)
            SCR->(DbDelete())
            SCR->(MsUnLock())
        End
    EndIf

    AEval(aAreas, {|area| RestArea(area)})

Return Nil

//Verifica se existe versão do PC no histórico de alterações (SCY) e exclui.
Static Function DeletSCY(cNumPedido)

    Local aAreas := {}

    aAreas := {GetArea(), SCY->(GetArea())}

    SCY->(DbSetOrder(1))
    If SCY->(DbSeek(FwXFilial("SCY") + cNumPedido))
        While SCR->(!(EoF())) .And. SCY->CY_FILIAL == FwXFilial("SCY") .And. SCY->CY_NUM == cNumPedido
            Reclock("SCY", .F., .T.)
            SCY->(DbDelete())
            SCY->(MsUnlock())
            SCY->(DbSkip())
        End
    EndIf

    AEval(aAreas, {|area| RestArea(area)})

Return Nil

//@param      cNvNomForn, character, nome do novo fornecedor
Static Function VldFornec(cCodForAtu, cCodLojAtu, cCodForNov, cCodLojNov, cNvNomForn)

    Local aAreas    := {}

    Local lValido   := .T.

    Default cCodForAtu  := ""
    Default cCodLojAtu  := ""
    Default cCodForNov  := ""
    Default cCodLojNov  := ""
    Default cNvNomForn  := ""

    aAreas := {GetArea(), SA2->(GetArea())}

    If !(Empty(cCodForNov)) .And. !(Empty(cCodLojNov))
        SA2->(DbSetOrder(1))
        If SA2->(DbSeek(FwXFilial("SA2") + cCodForNov + cCodLojNov))
            If SA2->A2_MSBLQL == "1"
                Help("", 1, "HELP", "Fornecedor", "Fornecedor bloqueado para uso.", 1, 0,,,,,,;
                    {""})
                lValido := .F.
            ElseIf (cCodForAtu + cCodLojAtu) == (cCodForNov + cCodLojNov)
                Help("", 1, "HELP", "Fornecedor", "Novo Fornecedor não pode ser igual ao Fornecedor antigo.", 1, 0,,,,,,;
                    {""})
                lValido := .F.
            EndIf
        Else
            Help("", 1, "HELP", "Fornecedor", "Fornecedor não encontrado na base da dados.", 1, 0,,,,,,;
                {""})
            lValido := .F.
        EndIf
    EndIf

    If lValido .And. !(FwIsInCallStack("ValidGeral"))
        cNvNomForn := SA2->A2_NOME
    EndIF

    AEval(aAreas, {|area| RestArea(area)})

Return lValido

Static Function RegrvForne(cNumPedido, cFornec, cLoja)

    Local aPedido       := {}
    Local aItemPed      := {}
    Local aItensPed     := {}

    Local cComprador    := ""

    Local dDataBkp      := CToD("  /  /    ")
    Local dDataEmiss    := CToD("  /  /    ")

    Local lOk           := .T.

    Local nCampo        := 1
    Local nTipo         := 0
    Local nValor        := 2

    Default cNumPedido  := ""
    Default cFornec     := ""
    Default cLoja       := ""

    Private lMsErroAuto     := .F.
    Private lAutoErrNoFile  := .T.

    If CarPedComp(cNumPedido, @nTipo, @dDataEmiss, @aPedido, @aItensPed)
        dDataBkp    := Date()
        dDataBase   := dDataEmiss
        aPedido[AScan(aPedido, {|cabecalho| cabecalho[nCampo] == "C7_FORNECE"})][nValor] := cFornec
        aPedido[AScan(aPedido, {|cabecalho| cabecalho[nCampo] == "C7_LOJA"})][nValor]    := cLoja

        cComprador := aPedido[AScan(aPedido, {|cabecalho| cabecalho[nCampo] == "C7_COMPRA"})][nValor]

        If !(DelPedComp(cNumPedido) .And. IncNovPed(nTipo, aPedido, aItensPed))
            lOk := .F.
        EndIf
        dDataBase   := dDataBkp
    EndIf

    FwFreeObj(aPedido)
    FwFreeObj(aItensPed)
    aPedido := Nil
    aItensPed := Nil

Return lOk

Static Function CarPedComp(cNumPedido, nTipo, dDataEmiss, aPedido, aItensPed)

    Local lCabec    := .T.
    Local lOk       := .T.

    Default nTipo       := 0
    Default aPedido     := {}
    Default aItensPed   := {}

    If SC7->(DbSeek(FwXFilial("SC7") + cNumPedido))
        While SC7->(!(EoF())) .And. SC7->C7_FILIAL == FwXFilial("SC7") .And. SC7->C7_NUM == cNumPedido
            If lCabec
                nTipo       := SC7->C7_TIPO
                dDataEmiss  := SC7->C7_EMISSAO
                lCabec      := .F.
                AAdd(aPedido, {"C7_NUM",        SC7->C7_NUM,        Nil})
                AAdd(aPedido, {"C7_FORNECE",    SC7->C7_FORNECE,    Nil})
                AAdd(aPedido, {"C7_LOJA",       SC7->C7_LOJA,       Nil})
                AAdd(aPedido, {"C7_COND",       SC7->C7_COND,       Nil})
                AAdd(aPedido, {"C7_FILENT",     SC7->C7_FILENT,     Nil})
                AAdd(aPedido, {"C7_COMPRA",     SC7->C7_COMPRA,     Nil})
                AAdd(aPedido, {"C7_GRUPCOM",    SC7->C7_GRUPCOM,    Nil})
                //AAdd(aPedido, {"C7_GRUPCOM",    SC7->C7_GRUPCOM,    Nil})
                AAdd(aPedido, {"C7_USER",       SC7->C7_USER,       Nil})
                AAdd(aPedido, {"C7_CONTATO",    SC7->C7_CONTATO,    Nil})
                AAdd(aPedido, {"C7_EMISSAO",    SC7->C7_EMISSAO,    Nil})
                AAdd(aPedido, {"C7_TPFRETE",    SC7->C7_TPFRETE,    Nil})
                AAdd(aPedido, {"C7_FRETE",      SC7->C7_FRETE,      Nil})
                AAdd(aPedido, {"C7_XFRONT",     SC7->C7_XFRONT,     Nil})
                AAdd(aPedido, {"C7_XIDEXNF",    SC7->C7_XIDEXNF,    Nil})
                //AAdd(aPedido, {"C7_CONAPRO",    "L",                Nil})
            EndIf

            aItemPed := {}
            AAdd(aItemPed, {"C7_ITEM",      SC7->C7_ITEM,       Nil})
            AAdd(aItemPed, {"C7_PRODUTO",   SC7->C7_PRODUTO,    Nil})
            AAdd(aItemPed, {"C7_QUANT",     SC7->C7_QUANT,      Nil})
            AAdd(aItemPed, {"C7_PRECO",     SC7->C7_PRECO,      Nil})
            AAdd(aItemPed, {"C7_TOTAL",     SC7->C7_TOTAL,      Nil})
            AAdd(aItemPed, {"C7_TES",       SC7->C7_TES,        Nil})
            AAdd(aItemPed, {"C7_XORIG",     SC7->C7_XORIG,      Nil})
            AAdd(aItemPed, {"C7_XNUM",      SC7->C7_XNUM,       Nil})
            AAdd(aItemPed, {"C7_RESIDUO",   SC7->C7_RESIDUO,    Nil})
            AAdd(aItemPed, {"C7_UM",        SC7->C7_UM,         Nil})
            AAdd(aItemPed, {"C7_NUMSC",     SC7->C7_NUMSC,      Nil})
            AAdd(aItemPed, {"C7_ITEMSC",    SC7->C7_ITEMSC,     Nil})
            AAdd(aItemPed, {"C7_LOCAL",     SC7->C7_LOCAL,      Nil})
            AAdd(aItemPed, {"C7_OBS",       SC7->C7_OBS,        Nil})
            AAdd(aItemPed, {"C7_DATPRF",    SC7->C7_DATPRF,     Nil})
            //AAdd(aItemPed, {"C7_CONAPRO",   "L",                Nil})
            AAdd(aItemPed, {"C7_XID",       SC7->C7_XID,        Nil})
            AAdd(aItemPed, {"C7_XIDEXNF",   SC7->C7_XIDEXNF,    Nil})

            AAdd(aItensPed, AClone(aItemPed))
            FwFreeObj(aItemPed)
            aItemPed := Nil
            SC7->(DbSkip())
        End
    Else
        Help("", 1, "HELP", "Fornecedor", "Erro ao encontrar Pedido de Compra.", 1, 0,,,,,,;
            {""})
        lOk := .F.
    EndIf

Return lOk

/*/{Protheus.doc} DelPedComp
Excluí Pedido de Compra passado por parâmetro.

@@type      Static Function
@author     Rafael Riego
@since      28/05/2018
@version    12.1.7
@param      cNumPedido, character, número do pedido a ser deletado
@return     lOk, se o pedido foi excluído com sucesso ou não
/*/
Static Function DelPedComp(cNumPedido)

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

    Default cNumPedido  := ""

    aArea := {GetArea(), SC7->(GetArea())}

    If !(Empty(cNumPedido))
        SC7->(DbSetOrder(1))
        If !(SC7->(DbSeek(FwXFilial("SC7") + cNumPedido)))
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
        While SC7->(!(EoF())) .And. SC7->C7_FILIAL == FwXFilial("SC7") .And. SC7->C7_NUM == cNumPedido
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
            cErro += "Exclusão de Pedido de Compra | " + CRLF
            aLog := GetAutoGRLog()
            For nErro := 1 To Len(aLog)
                cErro += aLog[nErro] + CRLF
            Next nErro
            lOk := .F.
        EndIf
    EndIf

    If !(lOk)
        Help("", 1, "HELP", "Fornecedor", cErro, 1, 0,,,,,,;
            {""})
    EndIf

    FwFreeObj(aPedido)
    FwFreeObj(aItensPed)
    aPedido := Nil
    aItensPed := Nil

    AEval(aArea, {|area| RestArea(area)})

Return lOk

/*/{Protheus.doc} IncNovPed
Inclui Pedido de Compra passado por parâmetro.

@@type      Static Function
@author     Rafael Riego
@since      28/05/2018
@version    12.1.7
@param      nTipo, numeric, tipo do pedido
@param      aPedido, array, cabeçalho do pedido de compra
@param      aItensPed, array, itens do pedido de compra
@return     lOk, se o pedido foi excluído com sucesso ou não
/*/
Static Function IncNovPed(nTipo, aPedido, aItensPed)

    Local cErro := ""

    Local lOk   := .T.
    Local cFilC7 := ""//Chamado DOR010485332 Ticket 13538714 - Lucas Miranda de Aguiar

    Local nErro := 0

    Default nTipo       := 1
    Default aPedido     := {}
    Default aItensPed   := {}


    aPedido[aScan(aPedido,{|x|Trim(x[1])== "C7_USER" })][2] := __CUSERID //Chamado DOR010485332 Ticket 13538714 - Lucas Miranda de Aguiar
    cFilC7 := xFilial("SC7")//Chamado DOR010485332 Ticket 13538714 - Lucas Miranda de Aguiar
    MsExecAuto({|tipo, cabec, itens, operacao| MATA120(tipo, cabec, itens, operacao)}, nTipo, aPedido, aItensPed, 3)

    If lMsErroAuto
        cErro += "Alteração de Pedido de Compra | " + CRLF
        aLog := GetAutoGRLog()
        For nErro := 1 To Len(aLog)
            cErro += aLog[nErro] + CRLF
        Next nErro
        lOk := .F.
    EndIf

    If !(lOk)
        Help("", 1, "HELP", "Fornecedor", cErro, 1, 0,,,,,,;
            {""})
    EndIf
//Chamado DOR010485332 Ticket 13538714 - Lucas Miranda de Aguiar | Inicio
    If lOk
        DbSelectArea("SC7")
        DbSetOrder(1)
        If SC7->(DbSeek(cFilC7+aPedido[aScan(aPedido,{|x|Trim(x[1])== "C7_NUM" })][2]))
            Reclock("SC7",.F.)
                SC7->C7_USER := ""
            SC7->(MsUnLock())
        EndIf
    EndIf
//Chamado DOR010485332 Ticket 13538714 - Lucas Miranda de Aguiar | Fim
Return lOk

User Function F1304999()

    Local nRecnoSC7 := 0

    RpcSetEnv("01", "01010004")

    AltrFornec()

    RpcClearEnv()

Return Nil
