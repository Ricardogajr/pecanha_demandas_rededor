#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 /*
{Protheus.doc} CadFilP12S()
Rotina Responsavel pelo cadastro de filiais do P12 Simplificado.
@Author     Romer Junior
@Since      14/06/2021  
*/
User Function CadFilP12S()
    Local aArea   := GetArea()
    Local oBrowse := FwLoadBrw("CadFilP12S")
    Private cTitulo := "Cadastro de Filiais - P12 Simplificado"
    Private cAlias := "P33"

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias(cAlias)
    oBrowse:SetDescription(cTitulo)
    oBrowse:AddLegend( "P33->P33_STATUS == '1'", "GREEN",  "Ativo" )
    oBrowse:AddLegend( "P33->P33_STATUS == '2'", "RED",    "Inativo" )
    oBrowse:Activate()
     
    RestArea(aArea)

Return Nil
 
Static Function MenuDef()
    Local aRot := {}
     
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.CADFILP12S' OPERATION 1 ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_zMVC01Leg'        OPERATION 6 ACCESS 0 //OPERATION X
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.CADFILP12S' OPERATION 3 ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.CADFILP12S' OPERATION 4 ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.CADFILP12S' OPERATION 5 ACCESS 0 //OPERATION 5
 
Return aRot
 
Static Function ModelDef()
    Local oModel := Nil   
    Local oStP33 := FWFormStruct(1, cAlias)
    Local aTrigFil :=	FwStruTrigger("P33_FILPS", "P33_NOMFIL" , 'Posicione("SM0",1, cEmpAnt + M->P33_FILPS, "M0_FILIAL")', .F.,,  01,, )

    oStP33:AddTrigger(aTrigFil[1], aTrigFil[2], aTrigFil[3], aTrigFil[4]) 
    oModel := MPFormModel():New("FILP12S",/*bPre*/,,/*bCommit*/,/*bCancel*/) 
    oModel:AddFields("FORMP33",/*cOwner*/,oStP33)
    oModel:SetPrimaryKey({'P33_FILIAL','P33_FILPS'}) 
    
	
    oModel:SetDescription(cTitulo)
    oModel:GetModel("FORMP33"):SetDescription("Formulário do Cadastro "+cTitulo)

Return oModel

Static Function ViewDef()
   
    Local oModel := FWLoadModel("CADFILP12S")
    Local oStP33 := FWFormStruct(2, cAlias)  
    Local oView := Nil
 
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_P33", oStP33, "FORMP33")
    oView:CreateHorizontalBox("TELA",100)
    oView:EnableTitleView('VIEW_P33', cTitulo )  
    oView:SetCloseOnOk({||.T.})
    oView:SetOwnerView("VIEW_P33","TELA")

Return oView
  
User Function zMVC01Leg()
    Local aLegenda := {}
     
    AADD(aLegenda,{"BR_VERDE",        "Ativo" })
    AADD(aLegenda,{"BR_VERMELHO",    "Inativo"})
     
    BrwLegenda(cTitulo, "Filiais", aLegenda)

Return
