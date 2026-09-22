#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"
/*/{Protheus.doc} FCADP39
Função responsável pelo cadastro das regras de recusa automática.
@author Ricardo Junior
@since 01/01/2023
/*/
User Function FCADP39()
    Local oBrowse := FwLoadBrw("FCADP39")
    oBrowse:Activate()
Return (NIL)

/*/{Protheus.doc} BrowseDef
Função BrowseDef.
@author Ricardo Junior
@since 01/01/2023
/*/ 
Static Function BrowseDef()
    Local oBrowse := FwMBrowse():New()
    oBrowse:AddLegend( "P39_STATUS == '1'", "GREEN")
    oBrowse:AddLegend( "P39_STATUS != '1'", "RED")
    oBrowse:SetAlias("P39")
    oBrowse:SetDescription("Regras recusa automática")
    oBrowse:SetMenuDef("FCADP39")
Return (oBrowse)

/*/{Protheus.doc} MenuDef
Função MenuDef.
@author Ricardo Junior
@since 01/01/2023
/*/
Static Function MenuDef()
    Local aRotina := FwMVCMenu("FCADP39")
Return (aRotina)

/*/{Protheus.doc} ModelDef
Função ModelDef.
@author Ricardo Junior
@since 01/01/2023
/*/
Static Function ModelDef()
    Local oModel := MPFormModel():New("FCADP39M",{|oModel| IsOpenModel(oModel)},,{|oModel| fCommitP39() },/*bCancel*/)
    Local oStP39C := FwFormStruct(1, "P39", {|x| AllTrim(x) $ "P39_FILIAL, P39_CODIGO, P39_DESCRICAO, P39_VENCRE, P39_STATUS, P39_ANEXO, P39_TDPROD, P39_MSGMAI"})
    Local oStP39I := FwFormStruct(1, "P39", {|x| AllTrim(x) $ "P39_FILIAL, P39_PRODUT, P39_DESPRO"})

    Local aTrigDesc	 :=	FwStruTrigger("P39_PRODUT"   , "P39_DESPRO" , "SB1->B1_XDES", .T., "SB1",  01, "xFilial('SB1') + M->P39_PRODUT"   , )

    oStP39I:AddTrigger(aTrigDesc[1], aTrigDesc[2], aTrigDesc[3], aTrigDesc[4])

    oModel:AddFields("P39MASTER", NIL, oStP39C)
    oModel:AddGrid("P39DETAIL", "P39MASTER", oStP39I)


    oModel:SetRelation("P39DETAIL", {{"P39_FILIAL", "xFilial('P39')"}, {"P39_CODIGO", "P39_CODIGO"}}, P39->(IndexKey( 1 )))
    oModel:SetPrimaryKey({'P39_FILIAL', 'P39_CODIGO', 'P39_PRODUT'})

    oModel:GetModel("P39DETAIL"):SetOptional(.T.)

    oModel:SetDescription("Regras de Recusa automática" )

    oStP39C:SetProperty('P39_TDPROD', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "U_FCADP39A()"))
    
    oStP39C:SetProperty('P39_STATUS', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "U_FCADP39C()"))

    oStP39I:SetProperty('P39_PRODUT', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "U_FCADP39B() .And.  ExistCPO('SB1',FwFldGet('P39_PRODUT'))"))
    oModel:GetModel("P39MASTER"):SetDescription("Cabecalho da Regra da Recusa automatica")
    oModel:GetModel("P39DETAIL"):SetDescription("Lista de Produtos")
Return (oModel)

/*/{Protheus.doc} ViewDef
Função ViewDef.
@author Ricardo Junior
@since 01/01/2023
/*/
Static Function ViewDef()
    Local oView := FwFormView():New()
    Local oStP39C := FwFormStruct(2, "P39", {|x| AllTrim(x) $ "P39_FILIAL, P39_CODIGO, P39_DESCRICAO, P39_VENCRE, P39_STATUS, P39_ANEXO, P39_TDPROD, P39_MSGMAI"})
    Local oStP39I := FwFormStruct(2, "P39", {|x| AllTrim(x) $ "P39_FILIAL, P39_PRODUT, P39_DESPRO"})
    Local oModel := FwLoadModel("FCADP39")

    oView:SetModel(oModel)

    oView:AddField("VIEW_P39C", oStP39C, "P39MASTER")
    oView:AddGrid("VIEW_P39I", oStP39I, "P39DETAIL")

    oView:CreateHorizontalBox("SUPERIOR", 50)
    oView:CreateHorizontalBox("INFERIOR", 50)

    oView:SetOwnerView("VIEW_P39C", "SUPERIOR")
    oView:SetOwnerView("VIEW_P39I", "INFERIOR")

    oView:EnableTitleView("VIEW_P39C","Regras de Recusa automática")


Return (oView)

/*/{Protheus.doc} fCommitP39
Função de antes do commit.
@author Ricardo Junior
@since 01/01/2023
/*/
Static Function fCommitP39()
    Local nI     := 0
    Local oModel := FWModelActivate()
    Local nOper	 := oModel:GetOperation()
    Local lRet := .T.

    oModelDet := oModel:GetModel("P39DETAIL")
    oModelMas := oModel:GetModel("P39MASTER")

    if oModelMas:GetValue("P39_TDPROD") == "2"
        if oModelDet:Length() <= 1 .And.  Empty(oModelDet:GetValue("P39_PRODUT")) .ANd. !oModelDet:IsDeleted(1)
            Alert("Não será possivel salvar o formulário com o campo Todos os produtos = 'Não' e não informar os produtos")
            lRet := .F.
        endif
    endif

    For nI := 1 To oModelDet:Length()
        //Posicionando na linha
        oModelDet:GoLine(nI)
        if nOper == 3
            if oModelDet:IsDeleted(nI)
                Loop
            endif
            RecLock("P39",.T.)
            P39->P39_CODIGO := oModelMas:GetValue("P39_CODIGO")
            P39->P39_DESCRI := oModelMas:GetValue("P39_DESCRI")
            P39->P39_VENCRE := oModelMas:GetValue("P39_VENCRE")
            P39->P39_PRODUT := oModelDet:GetValue("P39_PRODUT")
            P39->P39_DESPRO := oModelDet:GetValue("P39_DESPRO")
            P39->P39_STATUS := oModelMas:GetValue("P39_STATUS")
            P39->P39_ANEXO := oModelMas:GetValue("P39_ANEXO")
            P39->P39_TDPROD := oModelMas:GetValue("P39_TDPROD")
            P39->P39_MSGMAI := oModelMas:GetValue("P39_MSGMAI")
            P39->(MsUnlock())
        elseif nOper == 4
            if oModelDet:isEmpty()
                loop
            endif
            DbSelectArea("P39")
            P39->(DbSetOrder(01))
            if P39->(DbSeek(oModelMas:GetValue("P39_FILIAL")+oModelMas:GetValue("P39_CODIGO")+oModelDet:GetValue("P39_PRODUT")))
                if oModelDet:IsDeleted(nI)
                    RecLock("P39",.F.)
                    P39->(DBDelete())
                    P39->(MsUnlock())
                    Loop
                endif
                lInclui := .F.
            else
                if nI == 1
                    if P39->(DbSeek(oModelMas:GetValue("P39_FILIAL")+oModelMas:GetValue("P39_CODIGO")))
                        lInclui := .F.
                    else
                        lInclui := .T.
                    endif
                else
                    lInclui := .T.
                endif
            endif
            RecLock("P39", lInclui)
            P39->P39_CODIGO := oModelMas:GetValue("P39_CODIGO")
            P39->P39_DESCRI := oModelMas:GetValue("P39_DESCRI")
            P39->P39_VENCRE := oModelMas:GetValue("P39_VENCRE")
            P39->P39_PRODUT := oModelDet:GetValue("P39_PRODUT")
            P39->P39_DESPRO := oModelDet:GetValue("P39_DESPRO")
            P39->P39_STATUS := oModelMas:GetValue("P39_STATUS")
            P39->P39_ANEXO := oModelMas:GetValue("P39_ANEXO")
            P39->P39_TDPROD := oModelMas:GetValue("P39_TDPROD")
            P39->P39_MSGMAI := oModelMas:GetValue("P39_MSGMAI")
            P39->(MsUnlock())
        elseif nOper == 5
            DbSelectArea("P39")
            P39->(DbSetOrder(01))
            if P39->(DbSeek(oModelMas:GetValue("P39_FILIAL")+oModelMas:GetValue("P39_CODIGO")+oModelDet:GetValue("P39_PRODUT")))
                RecLock("P39",.F.)
                P39->(DBDelete())
                P39->(MsUnlock())
            endif
        endif
    Next nI

    if nOper == 3
        ConfirmSX8()
    else
        RollbackSx8()
    endif

    oModelDet:SetNoInsertLine(.F.)
    oModelDet:SetNoUpdateLine(.F.)
Return lRet

/*/{Protheus.doc} FCADP39A
Função responsável pela regra do campo P39_TDPROD.
@author Ricardo Junior
@since 01/01/2023
/*/
User Function FCADP39A()

    Local oModel := FWModelActivate()
    Local nI := 01

    oModelDet := oModel:GetModel("P39DETAIL")
    oModelMas := oModel:GetModel("P39MASTER")

    oModelDet:SetNoInsertLine(.F.)
    oModelDet:SetNoUpdateLine(.F.)

    if oModelMas:GetValue("P39_TDPROD") == "1"
        if MsgYesNo("Deseja mesmo colocar todos os produtos? Esse processo apagará todos os produtos do grid.", "Atenção")
            DbSelectArea("P39")
            P39->(DbSetOrder(01))
            For nI := 1 To oModelDet:Length()
                oModelDet:GoLine(nI)
                if nI == 1
                    oModelDet:LoadValue("P39_PRODUT", Space(TamSx3("P39_PRODUT")[1]))
                    oModelDet:LoadValue("P39_DESPRO", Space(TamSx3("P39_PRODUT")[1]))
                    Loop
                endif
                oModelDet:DeleteLine()
            Next nI
            oModelDet:GoLine(1)
            oView := FwViewActive()
            oView:Refresh("VIEW_P39I")
            oModelDet:SetNoInsertLine(.T.)
            oModelDet:SetNoUpdateLine(.T.)
        endif
    endif
return .T.


/*/{Protheus.doc} FCADP39B
Função Valida se o produto já esta cadastrado.
@author Ricardo Junior
@since 01/01/2023
/*/
User Function FCADP39B()
    Local cQuery := ""
    Local cAliasP39 := GetNextAlias()
    Local lRet := .T.

    if Empty(FWFldGet("P39_PRODUT"))
        Return lRet
    endif

    cQuery += " SELECT P39_PRODUT, P39_CODIGO, P39_DESCRI FROM " + RetSqlname("P39") + CRLF
    cQuery += " WHERE D_E_L_E_T_ = ' ' " + CRLF
    cQuery += " AND P39_PRODUT = '"+AllTrim(FWFldGet("P39_PRODUT"))+"'" + CRLF
    cQuery += " AND P39_CODIGO != '"+AllTrim(FWFldGet("P39_CODIGO"))+"'" + CRLF
    cQuery += " AND P39_STATUS = '1' " + CRLF

    DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAliasP39, .T., .T.)

    if !(cAliasP39)->(Eof())
        Alert("O produto "+ AllTrim((cAliasP39)->P39_PRODUT) + " já existe esta cadastrado na regra "+AllTrim((cAliasP39)->P39_CODIGO) + "-"+AllTrim((cAliasP39)->P39_DESCRI))
        lRet := .F.
    endif

Return lRet

/*/{Protheus.doc} FCADP39B
Função Não poderá ativar a regra caso algum produto esteja em outro cadastro.
@author Ricardo Junior
@since 01/01/2023
/*/
User Function FCADP39C()

    Local oModel := FWModelActivate()
    Local oMdlGrid := oModel:GetModel("P39DETAIL")
    Local lRet := .T.

    For nI := 1 To oMdlGrid:Length()
        oMdlGrid:GoLine(nI)
        if oMdlGrid:IsDeleted(nI)
            Loop
        endif

        lRet := U_FCADP39B()

        if !lRet
            Exit
        endif
    Next nX

Return lRet

Static Function IsOpenModel()

    Local oModel := FWModelActivate()

    oModelDet := oModel:GetModel("P39DETAIL")
    oModelMas := oModel:GetModel("P39MASTER")
    
    if FWFldGet("P39_TDPROD") == "2"
        oModelDet:SetNoInsertLine(.F.)
        oModelDet:SetNoUpdateLine(.F.)
    endif

Return .T.
