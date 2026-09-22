#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'

user function FORMDELEG( cFilPed as Character, cNumPed as Character, nOper as Numeric )

Local oDlg

Local oSayFilial
Local oSayPedido
Local oSayNumFor
Local oSayNumMat
Local oSayDemand
Local oSayAusenc
Local oSayPadrao
Local oSayRepete
Local oSayEmerge
Local oSayMoment
Local oSayCotaca
Local oSayQtdCot

Local oGetFilial
Local oGetPedido
Local oGetNumFor
Local oGetNumMat
Local oGetDemand
Local oGetCombo1
Local oGetCombo2
Local oGetCombo3
Local oGetCombo4
//Local oGetCombo5
Local oGetCombo6
Local oGetQtdCot

Local lRet       as Logical
Local cGetFilial as Character
Local cGetPedido as Character
Local cGetNumFor as Character
Local cGetNumMat as Character
Local cGetDemand as Character
Local aComboSN   as Array
Local cCombo01   as Character
Local cCombo02   as Character
Local cCombo03   as Character
Local cCombo04   as Character
Local aComboMT   as Array
//Local cCombo05   as Character
Local cCombo06   as Character
Local cGetQtdCot as Numeric
Local aItens     as Array
Local nRadio     as Numeric
Local nOpc       as Numeric
Local lSair      as Logical

Local aButtons   as Array
Local lHasButton as Logical

Default cFilPed := ''
Default cNumPed := ''
Default nOper   := 0

lRet       := .F.
cGetFilial := cFilPed
cGetPedido := cNumPed

aComboSN   := {'','Sim','Não'}
aComboMT   := {'1 - Final de semana (sábado, domingo, feriados)','2 - Horário não corporativo (18:00 às 08:00)','3 - Nenhuma das alternativas anteriores'}
aItens     := {'1 - Final de semana (sábado, domingo, feriados)','2 - Horário não corporativo (18:00 às 08:00)','3 - Nenhuma das alternativas anteriores'}

nOpc       := 0
lSair      := .F.

aButtons   := {}
lHasButton := .T.

dbSelectArea("SZ7")
SZ7->( dbSetOrder(2) )
SZ7->( dbGoTop() )
If !dbSeek(cGetFilial+cGetPedido)
    cGetNumFor := GetSxeNum('SZ7','Z7_NUMFOR')
    cGetNumMat := SPACE(TamSX3("Z7_MAT")[1])
    cGetDemand := SPACE(TamSX3("Z7_NOME")[1])
    cCombo01   := aComboSN[1]
    cCombo02   := aComboSN[1]
    cCombo03   := aComboSN[1]
    cCombo04   := aComboSN[1]
    //cCombo05   := aComboMT[1]
    cCombo06   := aComboSN[1]
    nRadio     := 0
    cGetQtdCot := 0
else
    cGetNumFor := SZ7->Z7_NUMFOR
    cGetNumMat := SZ7->Z7_MAT
    cGetDemand := SZ7->Z7_NOME
    cCombo01   := If(SZ7->Z7_AUSENCI=='S',aComboSN[2],aComboSN[3])
    cCombo02   := If(SZ7->Z7_PADRAO=='S',aComboSN[2],aComboSN[3])
    cCombo03   := If(SZ7->Z7_REPETE=='S',aComboSN[2],If(SZ7->Z7_REPETE=='N',aComboSN[3],aComboSN[1]))
    cCombo04   := If(SZ7->Z7_EMERGEN=='S',aComboSN[2],aComboSN[3])
    //cCombo05   := aComboMT[VAL(SZ7->Z7_MOMENTO)]
    cCombo06   := If(SZ7->Z7_COTACAO=='S',aComboSN[2],aComboSN[3])
    nRadio     := VAL(SZ7->Z7_MOMENTO)
    cGetQtdCot := SZ7->Z7_QTDCOTA
EndIf



DO CASE
  CASE nOper = 1
        cCadastro := OemToAnsi("Formulário de Compra Delegada - Inclusão")
  CASE nOper = 2
        cCadastro := OemToAnsi("Formulário de Compra Delegada - Alteração")
  CASE nOper = 3
        cCadastro := OemToAnsi("Formulário de Compra Delegada - Exclusão")
ENDCASE

DEFINE MSDIALOG oDlg TITLE "" FROM 0,50 TO 450,450 PIXEL STYLE nOR( WS_VISIBLE, WS_POPUP )

oDlg:lEscClose := .F. //desabilita fechar a janela ao pressinar esc.
//oDlg:lCentered := .T. //abre a janela centralizado.
oDlg:lMaximized := .T. //abre a janela maximizada.

oTFont := TFont():New('Courier new',,-16,.T.)
//oTSay := TSay():New( 01, 01,{||'TSay para teste do TFont (usado Courier new)'},oDlg,,oTFont,.T.,.F.,.F.,.T.,0,,250,20,.F.,.T.,.F.,.F.,.F.,.F. ) 

oSayFilial := TSay():New( 35, 15, {||'Filial :'},oDlg,,,,,,.T.,,,200,20)
oSayFilial:cName := 'FILIAL'
oGetFilial := TGet():New( 33, 50, { | u | If( PCount() == 0, cGetFilial, cGetFilial := u ) },oDlg, 060, 010, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cGetFilial",,,,lHasButton  )
oGetFilial:lActive := .F.

oSayNumFor := TSay():New( 35, 140, {||'Formulário :'},oDlg,,,,,,.T.,,,200,20)
oSayNumFor:cName := 'FORMS'
oGetNumFor := TGet():New( 33, 175, { | u | If( PCount() == 0, cGetNumFor, cGetNumFor := u ) },oDlg, 060, 010, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cGetNumFor",,,,lHasButton  )
oGetNumFor:lActive := .F.

oSayPedido := TSay():New( 35, 280, {||'Pedido :'},oDlg,,,,,,.T.,,,200,20)
oSayPedido:cName := 'PEDIDO'
oGetPedido := TGet():New( 33, 305, { | u | If( PCount() == 0, cGetPedido, cGetPedido := u ) },oDlg, 060, 010, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cGetPedido",,,,lHasButton  )
oGetPedido:lActive := .F.

oSayNumMat := TSay():New( 50, 15, {||'Matricula :'},oDlg,,,,,,.T.,,,200,20)
oSayNumMat := TSay():New( 50, 42, {||'*'},oDlg,,oTFont,,,,.T.,CLR_RED,,10,20)
oSayNumMat:cName := 'MATRIC'
oGetNumMat := TGet():New( 48, 50, { | u | If( PCount() == 0, cGetNumMat, cGetNumMat := u ) },oDlg, 060, 010, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,{ | u | buscaDemand(cGetNumMat, @cGetDemand) },.F.,.F. ,,"cGetNumMat",,,,lHasButton  )
oGetNumMat:cF3 := 'SRA'
If nOper = 3
    oGetNumMat:lActive := .F.
EndIf

oSayDemand := TSay():New( 50, 140, {||'Demandante :'},oDlg,,,,,,.T.,,,200,20)
oSayDemand:cName := 'DEMAND'
oGetDemand := TGet():New( 48, 175, { | u | If( PCount() == 0, cGetDemand, cGetDemand := u ) },oDlg, 190, 010, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cGetDemand",,,,lHasButton  )
oGetDemand:lActive := .F.

oSayAusenc := TSay():New( 65, 15, {||'No momento, há ausência de estoque ou insuficiência da quantidade necessária para uso imediato desse item? :'},oDlg,,,,,,.T.,,,180,20)
oSayAusenc := TSay():New( 72, 120, {||'*'},oDlg,,oTFont,,,,.T.,CLR_RED,,10,20)
oSayAusenc:cName := 'AUSENCIA'
oGetCombo1 := TComboBox():New(63,235,{|u|if(PCount()>0,cCombo01:=u,cCombo01)}, aComboSN,060,10,oDlg,,,,,,.T.,,,,,,,,,'cCombo01')
If nOper = 3
    oGetCombo1:lActive := .F.
EndIf

oSayPadrao := TSay():New( 85, 15, {||'A classificação do material comprado é padrão? :'},oDlg,,,,,,.T.,,,180,20)
oSayPadrao := TSay():New( 85, 135, {||'*'},oDlg,,oTFont,,,,.T.,CLR_RED,,10,20)
oSayPadrao:cName := 'PADRAO'
oGetCombo2 := TComboBox():New(83,235,{|u|if(PCount()>0,cCombo02:=u,cCombo02)}, aComboSN,060,10,oDlg,,,,,,.T.,,,,,,,,,'cCombo02')
If nOper = 3
    oGetCombo2:lActive := .F.
EndIf

oSayRepete := TSay():New( 105, 15, {||'Você identifica uma recorrência/repetição na compra desse item? :'},oDlg,,,,,,.T.,,,180,20)
oSayRepete := TSay():New( 105, 177, {||'*'},oDlg,,oTFont,,,,.T.,CLR_RED,,10,20)
oSayRepete:cName := 'REPETE'
oGetCombo3 := TComboBox():New(103,235,{|u|if(PCount()>0,cCombo03:=u,cCombo03)}, aComboSN,060,10,oDlg,,,,,,.T.,,,,{ |u| If(cCombo02=='Não',.T.,(.F.,cCombo03==' '))},,,,,'cCombo03')
If nOper = 3
    oGetCombo3:lActive := .F.
EndIf

oSayEmerge := TSay():New( 125, 15, {||'A compra é de caráter emergencial? :'},oDlg,,,,,,.T.,,,180,20)
oSayEmerge := TSay():New( 125, 108, {||'*'},oDlg,,oTFont,,,,.T.,CLR_RED,,10,20)
oSayEmerge:cName := 'EMERGE'
oGetCombo4 := TComboBox():New(123,235,{|u|if(PCount()>0,cCombo04:=u,cCombo04)}, aComboSN,060,10,oDlg,,,,,,.T.,,,,,,,,,'cCombo04')
If nOper = 3
    oGetCombo4:lActive := .F.
EndIf

//oSayMoment := TSay():New( 145, 15, {||'Qual reflete o momento da criação do PC / SP ? :'},oDlg,,,,,,.T.,,,180,20)
oSayMoment := TSay():New( 145, 15, {||"Em que momento identificou a necessidade de compra? :"},oDlg,,,,,,.T.,,,180,20)
oSayMoment := TSay():New( 145, 133, {||'*'},oDlg,,oTFont,,,,.T.,CLR_RED,,10,20)
oSayMoment:cName := 'MOMENTO'
oRadio := TRadMenu():New (143,235,aItens,,oDlg,,,,,,,,130,12,,,,.T.)
oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}
If nOper = 3
    oRadio:lActive := .F.
EndIf

oSayCotaca := TSay():New( 180, 15, {||'Houve cotação com mais de um fornecedor? :'},oDlg,,,,,,.T.,,,180,20)
oSayCotaca := TSay():New( 180, 128, {||'*'},oDlg,,oTFont,,,,.T.,CLR_RED,,10,20)
oSayCotaca:cName := 'COTACAO'
oGetCombo6 := TComboBox():New(177,235,{|u|if(PCount()>0,cCombo06:=u,cCombo06)}, aComboSN,060,10,oDlg,,,,,,.T.,,,,,,,,,'cCombo06')
If nOper = 3
    oGetCombo6:lActive := .F.
EndIf

oSayQtdCot := TSay():New( 200, 15, {||'Quantas cotações? :'},oDlg,,,,,,.T.,,,180,20)
oSayQtdCot := TSay():New( 200, 70, {||'*'},oDlg,,oTFont,,,,.T.,CLR_RED,,10,20)
oSayQtdCot:cName := 'QTDCOTA'
oGetQtdCot := TGet():New( 198, 235, { | u | If( PCount() == 0, cGetQtdCot, cGetQtdCot := u ) },oDlg, 060, 010, "99",, 0, 16777215,,.F.,,.T.,,.F., { |u| If(cCombo06=='Sim',.T.,.F.)},.F.,.F.,,.F.,.F. ,,"cGetQtdCot",,,,lHasButton  )


If nOper = 3
    oGetQtdCot:lActive := .F.
EndIf

If nOper = 1 .or. nOper = 2
    //ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| nOpc := 1,oDlg:End()}, {|| if( btnCancelar(nOper), (nOpc := 0,oDlg:End()), oGetNumMat:setFocus()) },,aButtons)
    ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| if( btnConfirmar(nOper, cGetNumMat, cCombo01, cCombo02, cCombo03, cCombo04, nRadio, cCombo06, cGetQtdCot), (nOpc := 1,oDlg:End()), oGetNumMat:setFocus()) }, {|| if( btnCancelar(nOper), (nOpc := 0,oDlg:End()), oGetNumMat:setFocus()) },,aButtons)
ElseIf nOper = 3
    ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| nOpc := 2,oDlg:End()}, {|| if( btnCancelar(nOper), (nOpc := 0,oDlg:End()), oGetNumMat:setFocus()) },,aButtons)
EndIf

If nOpc == 0
    RollbackSx8()
    lRet := .F.
ElseIf nOpc == 1
    If nOper == 1
        lRecLock := .T.
        cCadastro := OemToAnsi("Pedido de Compra - INCLUIR")
    else
        dbSelectArea("SZ7")
        SZ7->( dbSetOrder(1) )
        SZ7->( dbGoTop() )
        If !dbSeek(cGetFilial+cGetNumFor)
            lRecLock := .T.
        else
            lRecLock := .F.
        EndIf
    EndIf

    If RecLock("SZ7", lRecLock)		
            SZ7->Z7_FILIAL  := cGetFilial
            SZ7->Z7_NUMFOR  := cGetNumFor
            SZ7->Z7_NUMPC   := cGetPedido
            SZ7->Z7_MAT     := cGetNumMat
            SZ7->Z7_NOME    := cGetDemand
            SZ7->Z7_AUSENCI := cCombo01
            SZ7->Z7_PADRAO  := cCombo02
            SZ7->Z7_REPETE  := cCombo03
            SZ7->Z7_EMERGEN := cCombo04
            SZ7->Z7_MOMENTO := cValToChar(nRadio)
            SZ7->Z7_COTACAO := cCombo06
            SZ7->Z7_QTDCOTA := cGetQtdCot
            If lRecLock
                ConfirmSx8()
            EndIf
        SZ7->( MsUnLock() )

        lRet := .T.
    Else
        RollbackSx8()
        lRet := .F.
    EndIf
ElseIf nOpc == 2
    dbSelectArea("SZ7")
    SZ7->( dbSetOrder(1) )
    SZ7->( dbGoTop() )
    If dbSeek(cGetFilial+cGetNumFor)
        RecLock("SZ7", .F.)
            SZ7->( dbDelete() )
        SZ7->( MsUnLock() )

        lRet := .T.
    Else
        lRet := .F.
    EndIf
EndIf

Return lRet




Static function btnConfirmar(nOper as Numeric, cGetNumMat as Character, cCombo01 as Character, cCombo02 as Character, cCombo03 as Character, cCombo04 as Character, nRadio  as Numeric, cCombo06 as Character, cGetQtdCot as Numeric)
Local lRet := .F.

If nOper == 3
    lRet := .T.
Else
    Do Case
        Case Empty(cGetNumMat)
            msgInfo("Matricula é um campo obrigatório.", "Atenção")
        Case Empty(cCombo01)
            msgInfo("Ausência de estoque ou insuficiência da quantidade é um campo obrigatório.", "Atenção")
        Case Empty(cCombo02)
            msgInfo("Material padrão é um campo obrigatório.", "Atenção")
        Case (cCombo02=='Não' .or. cCombo02=='N') .and. Empty(cCombo03)
            msgInfo("Recorrência/Repetição na compra desse item é um campo obrigatório.", "Atenção")
        Case Empty(cCombo04)
            msgInfo("Caráter emergencial é um campo obrigatório.", "Atenção")
        Case Empty(nRadio)
            msgInfo("Momento da criação do PC é um campo obrigatório.", "Atenção")
        Case Empty(cCombo06)
            msgInfo("Cotação é um campo obrigatório.", "Atenção")
        Case (cCombo06=='Sim' .or. cCombo06=='S') .and. Empty(cGetQtdCot)
            msgInfo("Quantidade de cotações é um campo obrigatório.", "Atenção")
        OtherWise
            lRet := .T.
    EndCase
EndIf

Return lRet




Static function btnCancelar(nOper as Numeric)
Local lRet := .F.

If nOper == 1
    If MSGYESNO( "Se você cancelar o Formulário, perderá este pedido."+chr(13)+chr(10)+"Deseja cancelar?", OemToAnsi("Formulário de Compra Delegada") )
        lRet := .T.
    EndIf
ElseIf nOper == 2
    If MSGYESNO( "Se você cancelar o formulário, perderá as alterações do pedido de compra."+chr(13)+chr(10)+"Deseja cancelar?", OemToAnsi("Formulário de Compra Delegada") )
        lRet := .T.
    EndIf
Else
    If MSGYESNO( "Para realizar a exclusão do Pedido de Compra é necessário excluir este Formulário."+chr(13)+chr(10)+"Deseja cancelar a exclusão?", OemToAnsi("Formulário de Compra Delegada") )
        lRet := .T.
    EndIf
EndIf

Return lRet




Static function buscaDemand(cGetNumMat, cGetDemand)

cGetDemand := GetAdvFVal("SRA", "RA_NOME", cGetNumMat, 13, " ")

Return
