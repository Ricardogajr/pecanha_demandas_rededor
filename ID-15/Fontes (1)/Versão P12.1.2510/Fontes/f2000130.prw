#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#Include 'RWMake.ch'
#DEFINE MOD_DADOS 1
#DEFINE MOD_INTER 2

User Function F2000130()
	Local oBrowse

	oBrowse := FWMBrowse():New() 
	oBrowse:SetAlias('PX1')
	oBrowse:SetDescription('Integração XRT - Empresas Habilitadas')
	oBrowse:Activate()

Return NIL

Static Function MenuDef()
	Local aRotina := {}

    /* Thiago Marques - ticket nº 23781643 - 13/06/2025 - Removido o ADD OPTION para compatibilização.
    ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.F2000130' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.F2000130' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.F2000130' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.F2000130' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Importar Empresas' ACTION 'U_F2000131' OPERATION 3 ACCESS 0
    */
    AAdd(aRotina, {"Incluir",           "VIEWDEF.F2000130", 0, 3})
    AAdd(aRotina, {"Alterar",           "VIEWDEF.F2000130", 0, 4})
    AAdd(aRotina, {"Excluir",           "VIEWDEF.F2000130", 0, 5})
    AAdd(aRotina, {"Visualizar",        "VIEWDEF.F2000130", 0, 2})
    AAdd(aRotina, {"Importar Empresas", "U_F2000131", 0, 3})

Return aRotina

Static Function ModelDef()
	Local oStruPX1  := FWFormStruct(MOD_DADOS,"PX1")
	local oModel := MPFormModel():New('MF2000130',,{|oMdl| VldPos(oMdl)})	

	oModel:AddFields('PX1MASTER', /*cOwner*/, oStruPX1)
	oModel:SetPrimaryKey( {"FwXFilial('PX1')","PX1_EMPINT","PX1_FILINT"} )
Return oModel

Static Function ViewDef()
	Local oModel := FWLoadModel( 'F2000130' )
	Local oStruPX1  := FWFormStruct(MOD_INTER, 'PX1' )
	Local oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "VIEW_PX1", oStruPX1, 'PX1MASTER')
	oView:CreateHorizontalBox( "TELA" , 100 )
	oView:SetOwnerView( "VIEW_PX1","TELA" )

Return oView

/*/{Protheus.doc} VldPos
    Valida se os dados estão corretos
    @type  Static Function
    @author Gianluca Moreira
    @since 23/08/2021
    /*/
Static Function VldPos(oModel)
    Local aAreaPX1 := PX1->(GetArea())
    Local aAreas   := {aAreaPX1, GetArea()}
    Local cEmpAtu  := oModel:GetValue('PX1MASTER', 'PX1_EMPINT')
    Local cFilAtu  := oModel:GetValue('PX1MASTER', 'PX1_FILINT')
    Local cRet     := ''
    Local lRet     := .T.
    Local nOpc     := oModel:GetOperation()

    If !FWFilExist(cEmpAtu, cFilAtu)
        cRet := 'Empresa '+cEmpAtu+' Filial '+cFilAtu+' não encontrada no arquivo de empresas'
        lRet := .F.
    EndIf

    PX1->(DbSetOrder(1)) //PX1_FILIAL+PX1_EMPINT+PX1_FILINT
    If lRet .And. nOpc == 3 .And. PX1->(DbSeek(FWXFilial('PX1')+cEmpAtu+cFilAtu))
        cRet := 'Empresa '+cEmpAtu+' Filial '+cFilAtu+' já inclusas'
        lRet := .F.
    EndIf

    If !lRet
        Help(,, "F2000130",, cRet, 1, 0)
    EndIf

    AEval(aAreas, {|x| RestArea(x)})
Return lRet

/*/{Protheus.doc} User Function F2000131
    Realiza a importação do cadastro de empresas a partir da SM0
    @type  Function
    @author Gianluca Moreira
    @since 30/07/2021
    /*/
User Function F2000131()
    Local aSM0     := FWLoadSM0(.T.)
    Local aAreaPX1 := PX1->(GetArea())
    Local aAreas   := {aAreaPX1, GetArea()}
    Local cEmpAtu  := ''
    Local cFilAtu  := ''
    Local nSM0     := 0

    If !MsgYesNo('Deseja importar as empresas cadastradas no configurador?')
        Return
    EndIf

    If Len(cEmpAnt) != Len(PX1->PX1_EMPINT)
        MsgStop('Tamanho do campo PX1_EMPINT incorreto. Ajustar para tamanho '+cValToChar(Len(cEmpAtu)))
        Return
    EndIf
    If Len(cFilAnt) != Len(PX1->PX1_FILINT)
        MsgStop('Tamanho do campo PX1_FILINT incorreto. Ajustar para tamanho '+cValToChar(Len(cFilAnt)))
        Return
    EndIf

    PX1->(DbSetOrder(1)) //PX1_FILIAL+PX1_EMPINT+PX1_FILINT
    For nSM0 := 1 To Len(aSM0)
        cEmpAtu := aSM0[nSM0, 1]
        cFilAtu := aSM0[nSM0, 2]

        If !PX1->(DbSeek(FWXFilial('PX1')+cEmpAtu+cFilAtu))
            If RecLock('PX1', .T.)
                PX1->PX1_FILIAL := FWXFilial('PX1')
                PX1->PX1_EMPINT := cEmpAtu
                PX1->PX1_FILINT := cFilAtu
                PX1->PX1_ATIVO  := '2' //Inativo
                PX1->(MsUnlock())
            EndIf
        EndIf
    Next nSM0

    AEval(aAreas, {|x| RestArea(x)})
Return

/*/{Protheus.doc} User Function F2000132
    Valida se a integração está habilitada na empresa/filial informada
    @type  Function
    @author Gianluca Moreira
    @since 30/07/2021
    /*/
User Function F2000132(cEmpAtu, cFilAtu)
    Local aAreaPX1 := {}
    Local aAreas   := {}
    Local lAtivo := .F.

    Default cEmpAtu := cEmpAnt
    Default cFilAtu := cFilAnt

    If !FwAliasInDic('PX1', .F.)
        Return lAtivo
    EndIf

    If Select('PX1') <= 0
        If !ChkFile('PX1')
            Return lAtivo
        EndIf
    EndIf

    If Select('PX1') <= 0
        Return lAtivo
    EndIf

    aAreaPX1 := PX1->(GetArea())
    aAreas   := {aAreaPX1, GetArea()}

    PX1->(DbSetOrder(1)) //PX1_FILIAL+PX1_EMPINT+PX1_FILINT
    If PX1->(DbSeek(FWXFilial('PX1')+cEmpAtu+cFilAtu))
        lAtivo := PX1->PX1_ATIVO == '1'
    EndIf

    AEval(aAreas, {|x| RestArea(x)})
Return lAtivo

/*/{Protheus.doc} User Function F2000133
    Retorna lista de empresas/filiais habilitadas para integração
    @type  Function
    @author Gianluca Moreira
    @since 26/08/2021
    /*/
User Function F2000133()
    Local aAreaPX1 := {}
    Local aAreas   := {}
    Local aSM0     := {}

    If !FwAliasInDic('PX1', .F.)
        Return aSM0
    EndIf

    If Select('PX1') <= 0
        If !ChkFile('PX1')
            Return aSM0
        EndIf
    EndIf

    If Select('PX1') <= 0
        Return aSM0
    EndIf

    aAreaPX1 := PX1->(GetArea())
    aAreas   := {aAreaPX1, GetArea()}

    PX1->(DbSetOrder(1)) //PX1_FILIAL+PX1_EMPINT+PX1_FILINT
    PX1->(DbGoTop())
    While !PX1->(EoF())
        If PX1->PX1_ATIVO == '1' .And. FWFilExist(PX1->PX1_EMPINT, PX1->PX1_FILINT)
            AAdd(aSM0, {PX1->PX1_EMPINT, PX1->PX1_FILINT})
        EndIf
        PX1->(DbSkip())
    EndDo

    AEval(aAreas, {|x| RestArea(x)})
Return aSM0
