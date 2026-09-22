#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 
Static cTitulo := "Cadastro filiais Greenfields"
/*/{Protheus.doc} FCADP53
Cadastro de filiais GreenFields
@type function
@version P122410     
@author Ricardo Junior
@since 12/23/2025
@return variant, Nil
/*/ 
User Function FCADP53()
    Local aArea   := GetArea()
    Local oBrowse
     
    oBrowse := FWMBrowse():New()
     
    oBrowse:SetAlias("P53")
    oBrowse:SetDescription(cTitulo)
          
    oBrowse:Activate()
     
    RestArea(aArea)
Return Nil
 
/*/{Protheus.doc} FCADP53
Cadastro de filiais GreenFields
@type function
@version P122410     
@author Ricardo Junior
@since 12/23/2025
@return variant, Nil
/*/ 
Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.FCADP53' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.FCADP53' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.FCADP53' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.FCADP53' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return aRot
 
/*/{Protheus.doc} ModelDef
ModelDef
@type function
@version P122410     
@author Ricardo Junior
@since 12/23/2025
@return variant, Nil
/*/ 
Static Function ModelDef()
    Local oModel := Nil     
    Local oStP53 := FWFormStruct(1, "P53")
    
    aP53FilNm := FwStruTrigger("P53_FILGRE", "P53_DESC", "FWFilName(cEmpAnt,M->P53_FILGRE)", .F., "SM0",,,)
	oStP53:AddTrigger(aP53FilNm[1], aP53FilNm[2], aP53FilNm[3], aP53FilNm[4])

    oModel := MPFormModel():New("FCADP53M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
    oModel:AddFields("FORMP53",/*cOwner*/,oStP53)
        
    oModel:SetPrimaryKey({'P53_FILIAL','P53_FILGRE'})
    oModel:SetDescription("Modelo "+cTitulo)
    oModel:GetModel("FORMP53"):SetDescription("Formulário "+cTitulo)
    
Return oModel
 
/*/{Protheus.doc} ViewDef
ViewDef
@type function
@version P122410     
@author Ricardo Junior
@since 12/23/2025
@return variant, Nil
/*/ 
Static Function ViewDef()
    Local oModel := FWLoadModel("FCADP53")
    Local oStP53 := FWFormStruct(2, "P53")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}
    Local oView := Nil
 
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_P53", oStP53, "FORMP53")
    oView:CreateHorizontalBox("TELA",100)
    oView:EnableTitleView('VIEW_P53', 'Dados Filiais Greenfields' )  
    oView:SetCloseOnOk({||.T.})
     
    oView:SetOwnerView("VIEW_P53","TELA")
Return oView
 