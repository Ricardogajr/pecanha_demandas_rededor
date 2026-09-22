#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*/{Protheus.doc} DORUSFAP
Cadastro Solicitantes Admissão Digital
@author 	Laura Peghini
@since 		20/05/2025
@version 	1.0
/*/ 
User Function DORUSFAP()

//AxCadastro("PAM","Cad. Solic. Admissão Digital",.T.,.T.)

//Return

Local oBrowser := Nil

    oBrowser := FWmBrowse():New()
    oBrowser:SetAlias("PAM")
    oBrowser:SetDescription("Cad. Solic. Admissão Digital")
    //Legendas
    oBrowser:AddLegend( "PAM->PAM_STATUS == '1'", "GREEN",    "Ativo" )
    oBrowser:AddLegend( "PAM->PAM_STATUS == '2'", "RED",    "Inativo" )
    oBrowser:Activate()

Return Nil

/*/{Protheus.doc} MenuDef
Monta o menu.
@author 	Laura Peghini
@since 		20/05/2025
@version 	1.0
/*/
Static Function MenuDef()

Local aRotina := {}

	
	  AAdd(aRotina,{"Visualizar" , 'VIEWDEF.DORUSFAP'   , 0, 2 } )
	    AAdd(aRotina,{"Incluir" , 'VIEWDEF.DORUSFAP'   , 0, 3 } )
		  AAdd(aRotina,{"Alterar" , 'VIEWDEF.DORUSFAP'   , 0, 4 } )
		    AAdd(aRotina,{"Excluir" , 'VIEWDEF.DORUSFAP'   , 0, 5 } )

Return aRotina

/*/{Protheus.doc} ModelDef
Model - Cadastro Solicitantes Admissão Digital
@author 	Laura Peghini
@since 		20/05/2025
@version 	1.0
/*/
Static Function ModelDef()

Local oModel		:= Nil
Local oStruPAM	:= FwFormStruct(1,"PAM") 

    oModel := MPFormModel():New("DORC01FS",/*bPreValidacao*/,{ |oModel| ValidDupli( oModel ) }/*bTudoOk*/,/*bCommit*/,/*bCancel*/)
    
    oModel:AddFields("PAMMASTER",/*Owner*/,oStruPAM)
    oModel:SetPrimaryKey({"PAM_FILIAL","PAM_FILUSR","PAM_MATRIC"})
                                                                                 
    oModel:SetDescription("Cad. Solic. Admissão Digital")

    oModel:GetModel("PAMMASTER"):SetDescription("Cad. Solic. Admissão Digital")

Return oModel

/*/{Protheus.doc} ViewDef
View - Cadastro Solicitantes Admissão Digital
@author 	Laura Peghini
@since 		20/05/2025
@version 	1.0
/*/
Static Function ViewDef()

Local oView	:= Nil
Local oModel:= FwLoadModel("DORUSFAP") 

Local oStruPAM := FwFormStruct(2,"PAM")

    oView := FwFormView():New()
    oView:SetModel(oModel)

    oView:AddField("VIEW_PAM",oStruPAM,"PAMMASTER")

    oView:CreateHorizontalBox("SUPERIOR",100,,,,)

    oView:SetOwnerView("VIEW_PAM","SUPERIOR")

Return oView

Static Function ValidDupli( oModel )

Local lRet := .T.
Local nOperation:= oModel:GetOperation()
	
	If nOperation == MODEL_OPERATION_INSERT
		If PAM->(DbSeek(xFilial("PAM")+oModel:GetValue("PAMMASTER","PAM_FILUSR") + oModel:GetValue("PAMMASTER","PAM_MATRIC")))
			lRet := .F.
			Help( ,, 'Help',, 'Registro já existe! (Filial Usuário e Usuário.)', 1, 0 )
		EndIf
	EndIf

Return( lRet )
