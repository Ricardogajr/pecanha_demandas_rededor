#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} F1300601
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 31/10/2017
@project MAN0000007423048_EF_006
@type function
/*/
User Function F1300601()
	Local oBrowse	:= Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("PAI")
	oBrowse:SetDescription("Listagem de Postos ")
	oBrowse:DisableReport()
	oBrowse:DisableDetails()
	oBrowse:Activate()

return

/*/{Protheus.doc} MenuDef
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 31/10/2017
@project MAN0000007423048_EF_006
@type function
/*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.F1300601" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"		ACTION "VIEWDEF.F1300601" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"		ACTION "VIEWDEF.F1300601" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"		ACTION "VIEWDEF.F1300601" OPERATION 5 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 31/10/2017
@project MAN0000007423048_EF_006
@type function
/*/
Static Function ModelDef()

	Local aAux       := {}
	Local oStructPAI := FWFormStruct(1,"PAI")
	Local oStructPAH := FWFormStruct(1,"PAH")
	Local oModel     := Nil
	
	aAux := FwStruTrigger ( 'PAH_POSTO', 'PAH_FILRES', 'POSICIONE("RCX",1,ALLTRIM(FwFldGet("PAH_FILPOS")) + FwFldGet("PAH_POSTO"), "RCX_FILFUN")' , .F. )
	oStructPAH:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])
	
	aAux := FwStruTrigger ( 'PAH_POSTO', 'PAH_MATRES', 'POSICIONE("RCX",1,ALLTRIM(FwFldGet("PAH_FILPOS")) + FwFldGet("PAH_POSTO"), "RCX_MATFUN")' , .F. )
	oStructPAH:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])
	
	aAux := FwStruTrigger ( 'PAH_POSTO', 'PAH_NOMRES', 'POSICIONE("SRA",1,ALLTRIM(FwFldGet("PAH_FILRES")) + FwFldGet("PAH_MATRES"), "RA_NOME")' , .F. )
	oStructPAH:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])
	
	aAux := FwStruTrigger ( 'PAH_POSTO', 'PAH_SITFOL', 'POSICIONE("SRA",1,ALLTRIM(FwFldGet("PAH_FILRES")) + FwFldGet("PAH_MATRES"), "RA_SITFOLH")' , .F. )
	oStructPAH:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])
	
	oModel := MPFormModel():New("F13006M",,{|oModel| FsVldMdl(oModel)})
	
	oStructPAH:SetProperty('PAH_POSTO',MODEL_FIELD_VALID, {|| FsVldCdAl("PAH_POSTO")})
	
	oModel:AddFields("CABMASTER",,oStructPAI)
	oModel:AddGrid("PAHDETAIL","CABMASTER",oStructPAH)
	
	oModel:SetRelation("PAHDETAIL",{{"PAH_FILIAL","PAI_FILIAL"},{"PAH_CODIGO","PAI_CODIGO"}}, "PAH_FILIAL + PAH_CODIGO")

	oModel:SetDescription("Listagem de Postos")

	oModel:SetPrimaryKey({"PAI_CODIGO"})
Return oModel

/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 31/10/2017
@project MAN0000007423048_EF_006
@type function
/*/
Static Function ViewDef()

	Local oStructPAI := FWFormStruct(2,"PAI")
	Local oStructPAH := FWFormStruct(2,"PAH")
	Local oModel   	 := FWLoadModel("F1300601")
	Local oView	 	 := Nil

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_CAB",oStructPAI,"CABMASTER")
	oView:AddGrid("VIEW_PAH",oStructPAH,"PAHDETAIL")

	oStructPAH:RemoveField("PAH_CODIGO")
	
	//Painel Superior 
	oView:CreateHorizontalBox("SUPERIOR",30)

	//Painel Inferior
	oView:CreateHorizontalBox("INFERIOR",70)

	oView:EnableTitleView("VIEW_CAB","Listagem de Postos")
	oView:EnableTitleView("VIEW_PAH","Detalhes")

	oView:SetOwnerView("VIEW_CAB","SUPERIOR")
	oView:SetOwnerView("VIEW_PAH","INFERIOR")

Return oView

/*/{Protheus.doc} FsVldMdl
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 31/10/2017
@project MAN0000007423048_EF_006
@type function
/*/
Static Function FsVldMdl()

	Local oMdl    := FwModelActivate()
	Local cOper   := oMdl:GetOperation()
	Local cAlias1 := GetNextAlias()
	Local cPAC	  := "%" + RetFullName("PAC",cEmpAnt) + "%"
	Local lRet    := .T.
	
	If cOper == MODEL_OPERATION_DELETE
		
		BeginSql alias cAlias1
			
			SELECT PAC_CODALC
			FROM %Exp:cPAC% PAC
			WHERE PAC.PAC_VINCL = '1'
			AND   PAC.PAC_CODLG != ' '
			AND   PAC.%notDel%
			
		EndSql
		
		If (cAlias1)->(!EOF())
			Help("",1, "FsVldMdl",, "Não é permitido excluir, existe alçada vinculada!" , 1, 0)
			lRet := .F.
		EndIf
		
		(cAlias1)->(DbCloseArea())
		
	EndIf

Return lRet

Static Function FsVldCdAl(cCampo)
	
	Local aArea     := GetArea()
	Local oModel    := FwModelActive()
	Local oMdlPAH   := oModel:GetModel("PAHDETAIL")
	Local nQtdLin	:= oMdlPAH:GetQTDLine()
	Local nLin		:= oMdlPAH:Getline()
	Local cCodPosto := oMdlPAH:GetValue("PAH_POSTO", nLin)
	Local cCodFili  := oMdlPAH:GetValue("PAH_FILPOS", nLin)
	Local lRet      := .T.
	Local nX        := 1
	
	If cCampo == "PAH_POSTO"
		DbSelectArea("RCL")
		RCL->(DbSetOrder(2))
		If !(RCL->(DbSeek(ALLTRIM(cCodFili) + cCodPosto)))
			lRet := .F.
		EndIf
	EndIf

	If lRet
		For nX := 1 To nQtdLin
			If AllTrim(cCodFili) + AllTrim(cCodPosto) ==;
			 AllTrim(oMdlPAH:GetValue("PAH_FILPOS", nX )) + AllTrim(oMdlPAH:GetValue("PAH_POSTO", nX )) ;
			 .And. nLin != nX
				Help('',1,'Atenção',,"Essa filial e posto já foi informado.",1,0,,,,,,{"Informe um posto válido."})
				lRet := .F.
			Endif
		Next
	Endif

	RestArea(aArea)
	
Return lRet