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

    Add Option aRotina Title "Visualizar"	Action "VIEWDEF.DORUSFAP" Operation 2 Access 0
    Add Option aRotina Title "Incluir" 		Action "VIEWDEF.DORUSFAP" Operation 3 Access 0 
    Add Option aRotina Title "Alterar"		Action "VIEWDEF.DORUSFAP" Operation 4 Access 0 
    Add Option aRotina Title "Excluir"		Action "VIEWDEF.DORUSFAP" Operation 5 Access 0

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
