#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} F1207701
Cadastro de Grupo de Solicitação de Pagamentos.

@project    MAN0000007423048_EF_77
@author     Reinaldo Dias
@since      09/05/2019
@version    P12.1.17
/*/
User Function F1207701()

    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias("P32")         // Alias da tabela utilizada
    oBrowse:SetDescription("Cadastro de Grupo de Solicitação de Pagamentos")
    oBrowse:SetMenuDef("F1207701")  // Nome do fonte onde esta a função MenuDef
    oBrowse:SetAmbiente(.F.)        // Desabilita opção Ambiente do menu Ações Relacionadas
    oBrowse:SetWalkThru(.F.)        // Desabilita opção WalkThru do menu Ações Relacionadas
    oBrowse:Activate()

Return Nil

/*/{Protheus.doc} MenuDef
MenuDef para o Objeto.

@Project    MAN0000007423048_EF_77
@author     Reinaldo Dias
@since      09/05/2019
@version    P12.1.17
@return     aRotina, array contendo os botões de menu
/*/
Static Function MenuDef()

    Local aRotina := {}

    //ADD OPTION aRotina TITLE "Pesquisar"    ACTION "VIEWDEF.F1207701" OPERATION 1  ACCESS 0 // Pesquisar
    //ADD OPTION aRotina TITLE "Visualizar"   ACTION "VIEWDEF.F1207701" OPERATION 2  ACCESS 0 // Visualizar
    //ADD OPTION aRotina TITLE "Incluir"      ACTION "VIEWDEF.F1207701" OPERATION 3  ACCESS 0 // Incluir
    //ADD OPTION aRotina TITLE "Alterar"      ACTION "VIEWDEF.F1207701" OPERATION 4  ACCESS 0 // Alterar
    //ADD OPTION aRotina TITLE "Excluir"      ACTION "VIEWDEF.F1207701" OPERATION 5  ACCESS 0 // Excluir
    aAdd(aRotina,{"Pesquisar",  "VIEWDEF.F1207701",     0,  1})
    aAdd(aRotina,{"Visualizar", "VIEWDEF.F1207701",     0,  2})
    aAdd(aRotina,{"Incluir",    "VIEWDEF.F1207701",     0,  3})
    aAdd(aRotina,{"Alterar",    "VIEWDEF.F1207701",     0,  4})
    aAdd(aRotina,{"Excluir",    "VIEWDEF.F1207701",     0,  5})

Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@Project    MAN0000007423048_EF_77
@author     Reinaldo Dias
@since      09/05/2019
@version    P12.1.17
@return     oModel, objeto contendo o modelo de dados
/*/
Static Function ModelDef()
    Local oStruP32  := FwFormStruct(1, "P32", {|cCampo|  AllTrim(cCampo) + "|" $ "P32_FILIAL|P32_CODEQP|P32_NOMEQP|"})
    Local oStruGrid := FwFormStruct(1, "P32", {|cCampo| !(AllTrim(cCampo)) + "|" $ "P32_FILIAL|P32_CODEQP|P32_NOMEQP|"})
    local oModel    := MPFormModel():New("M1207701",, /*bPosValidacao*/, {|oModel| GrvModelo(oModel)}, /*bCancel*/)

// Validações da Grid
    Local bLinePost	:= {|oMdl| PosVldLine(oMdl)}

    oModel:SetDescription("Cadastro de Grupo de Solicitação de Pagamentos")
    oModel:AddFields("P32MASTER", /*cOwner*/,  oStruP32, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)
    oModel:AddGrid("P32DETAIL", "P32MASTER", oStruGrid, /*bLinePre*/, bLinePost, /*bPre*/, /*bPost*/,/*bLoad*/)

    oModel:SetRelation("P32DETAIL", {{"P32_FILIAL", "FwXFilial('P32')"}, {"P32_FILIAL",  "FwXFilial('P32')"}, {"P32_CODEQP", "P32_CODEQP"}}, P32->(IndexKey(1)))

    oModel:SetPrimaryKey({"FwXFilial('P32')", "P32_CODEQP", "P32_CODUSU"})

    oModel:GetModel("P32DETAIL"):SetUniqueLine({"P32_CODUSU"})

Return oModel

/*/{Protheus.doc} ViewDef
Funcao generica MVC do View.

@Project    MAN0000007423048_EF_77
@author     Reinaldo Dias
@since      09/05/2019
@version    P12.1.17
@return     oView - Objeto da View MVC
/*/
Static Function ViewDef()

    Local oModel    := FwLoadModel("F1207701")
    Local oStruP32  := FwFormStruct(2, "P32", {|cCampo|  AllTrim(cCampo) + "|" $ "P32_FILIAL|P32_CODEQP|P32_NOMEQP|"})
    Local oStruGrid := FwFormStruct(2, "P32", {|cCampo| !(AllTrim(cCampo)) + "|" $ "P32_FILIAL|P32_CODEQP|P32_NOMEQP|"})
    Local oView     := FwFormView():New()

    oView:SetModel(oModel)
    oView:AddField("VIEW_P32", oStruP32,  "P32MASTER")
    oView:AddGrid ("VIEW_GRID", oStruGrid, "P32DETAIL")

    oView:CreateHorizontalBox("TELA", 20)
    oView:CreateHorizontalBox("GRID", 80)

    oView:SetOwnerView("VIEW_P32",  "TELA")
    oView:SetOwnerView("VIEW_GRID", "GRID")

    oView:EnableTitleView("VIEW_P32", "Grupo")
    oView:EnableTitleView("VIEW_GRID", "Usuário")

Return oView

/*/{Protheus.doc} PosVldLine
Funcao de validacao da linha do Grid (compatibilizacao)
@Project MAN0000007423048_EF_77

@author     Reinaldo Dias
@since      09/05/2019
@version    P12.1.17
@Return     lRet
/*/
Static Function PosVldLine(oMdl)

    Local aArea    := GetArea()
    Local aAreaP32 := P32->(GetArea())
    Local lRet     := .T.
    Local oModel   := FwModelActive()
    Local cCodEqp  := oModel:GetValue("P32MASTER", "P32_CODEQP")
    Local cCodUsu  := oModel:GetValue("P32DETAIL", "P32_CODUSU")

    If !oMdl:IsDeleted()
        If !Empty(cCodUsu)
            P32->(DBSetOrder(2)) //P32_FILIAL+P32_CODUSU+P32_CODEQP
            If P32->(DBSeek(xFilial("P32")+cCodUsu)) .And. cCodEqp <> P32->P32_CODEQP
                Help("", 1, "F1207701",, "Este usuário já está cadastrado no grupo: " + P32->P32_CODEQP, 1, 0,,,,,, {"Por favor, verificar..."})
                lRet := .F.
            EndIf
        EndIf
    EndIf

    RestArea(aAreaP32)
    RestArea(aArea)

Return lRet



/*/{Protheus.doc} PosVldLine
Funcao de validacao da linha do Grid (compatibilizacao)
@Project ID 1591 

@author     Tiago Dantas da Cruz
@since      25/06/2019
@version    P12.1.17
@Return     lRet
/*/
Static Function GrvModelo(oModel)
Local lret		:= .T.
Local cCodigo := oModel:GetValue("P32MASTER", "P32_CODEQP") 
Local cDescr  := oModel:GetValue("P32MASTER", "P32_NOMEQP")
Local aAreaP32:= P32->(GetArea())

FwFormCommit(oModel, , {|oModel,cID,cAlias| .T.})	

Dbselectarea("P32")
Dbsetorder(1)
P32->(Dbgotop())
If Dbseek(FwxFilial("P32")+cCodigo)
	While !P32->(EOF()) .And. P32->P32_FILIAL==FwxFilial("P32") .AND. P32->P32_CODEQP ==cCodigo
		Reclock("P32",.F.)
			P32->P32_NOMEQP := cDescr
		P32->(MsUnlock())
	P32->(DbSkip())
	EndDo   
EndIf
		
RestArea(aAreaP32)		
Return lRet
