#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

/*
{Protheus.doc} F1301101()
Cadastro de Substituição
@Author     Bruno de Oliveira
@Since      14/11/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_011
*/
User Function F1301101()
	
	Local aRotina := MenuDef()
	
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("PAJ")
	oMBrowse:SetDescription("Cadastro de Substituição")
	oMBrowse:AddLegend('PAJ->PAJ_STATUS=="1"',"YELLOW","Programado")
	oMBrowse:AddLegend('PAJ->PAJ_STATUS=="2"',"GREEN","Ativo")
	oMBrowse:AddLegend('PAJ->PAJ_STATUS=="3"',"RED"  ,"Inativo")
	oMBrowse:SetMenuDef("F1301101")
	oMBrowse:SetCacheView( .F. )
	oMBrowse:Activate()
	
Return

/*
{Protheus.doc} MenuDef()
Cadastro de Substituição
@Author     Bruno de Oliveira
@Since      14/11/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_011
*/
Static Function MenuDef()
	
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.F1301101" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.F1301101" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.F1301101" OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.F1301101" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Multipla Substituições' Action "U_F1301104" OPERATION 3 ACCESS 0
	
Return aRotina

/*
{Protheus.doc} ModelDef()
Modelo de dados do cadastro de substituição
@Author     Bruno de Oliveira
@Since      14/11/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_011
@Return		oModel, Modelo de dados
*/
Static Function ModelDef()
	
	Local oModel
	Local oStrPAJ := FwFormStruct(1, "PAJ")
	Local oStrGrid := FWFormStruct(1,"PAJ",{|cCampo| AllTrim(cCampo) $ "PAJ_FILSUB|PAJ_MATSUB|PAJ_NOMSUB|PAJ_FILFUN|PAJ_MATFUN|PAJ_NOMFUN|PAJ_MOTIVO"} )
	Local bPosMd := {|| FsPosVld()}
	Local bCommitMd := {|oModel| FsCommtMd(oModel)}
	
	aAux := FwStruTrigger ( 'PAJ_MATSUB', 'PAJ_NOMSUB', 'U_F1301102("NOMSUB")' , .F. )
	oStrPAJ:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])
	
	aAux := FwStruTrigger ( 'PAJ_MATSUB', 'PAJ_FILPOS', 'U_F1301102("FILPOS")' , .F. )
	oStrPAJ:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])
	
	aAux := FwStruTrigger ( 'PAJ_MATSUB', 'PAJ_CODPOS', 'U_F1301102("CODPOS")' , .F. )
	oStrPAJ:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])
	
	aAux := FwStruTrigger ( 'PAJ_MATFUN', 'PAJ_NOMFUN', 'U_F1301102("NOMFUN")' , .F. )
	oStrPAJ:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])
	
	aAux := FwStruTrigger ( 'PAJ_MATFUN', 'PAJ_FILPFN', 'U_F1301102("FILPFN")' , .F. )
	oStrPAJ:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])
	
	aAux := FwStruTrigger ( 'PAJ_MATFUN', 'PAJ_CODPFN', 'U_F1301102("CODPFN")' , .F. )
	oStrPAJ:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])	
	
	aAux := FwStruTrigger ( 'PAJ_MATSUB', 'PAJ_NOMSUB', 'U_F1301102("NOMSUB","Grid")' , .F. )
	oStrGrid:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])
	
	aAux := FwStruTrigger ( 'PAJ_MATFUN', 'PAJ_NOMFUN', 'U_F1301102("NOMFUN","Grid")' , .F. )
	oStrGrid:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])
	
	oModel := MPFormModel():New("F13011", /*bPreMd*/ , bPosMd , bCommitMd, /*bCancel*/ )
	
	oStrPAJ:SetProperty( "PAJ_FILSUB", MODEL_FIELD_WHEN, {|oModel| oModel:GetOperation() == MODEL_OPERATION_INSERT } )
	oStrPAJ:SetProperty( "PAJ_FILSUB", MODEL_FIELD_VALID,{|oModel| ExistCpo("SM0",cEmpAnt+oModel:GetValue("PAJ_FILSUB"))})
	oStrPAJ:SetProperty( "PAJ_MATSUB", MODEL_FIELD_WHEN, {|oModel| oModel:GetOperation() == MODEL_OPERATION_INSERT .AND. !Empty(oModel:GetValue("PAJ_FILSUB"))} )
	oStrPAJ:SetProperty( "PAJ_MATSUB", MODEL_FIELD_VALID,{|oModel| IIF(!Empty(oModel:GetValue("PAJ_MATSUB")),FsVldMat(oModel:GetValue("PAJ_FILSUB"),oModel:GetValue("PAJ_MATSUB")),.T.)} )
	oStrPAJ:SetProperty( "PAJ_FILFUN", MODEL_FIELD_WHEN, {|oModel| oModel:GetOperation() == MODEL_OPERATION_INSERT .AND. !Empty(oModel:GetValue("PAJ_FILSUB")) .AND. !Empty(oModel:GetValue("PAJ_MATSUB") )} )
	oStrPAJ:SetProperty( "PAJ_FILFUN", MODEL_FIELD_VALID,{|oModel| ExistCpo("SM0",cEmpAnt+oModel:GetValue("PAJ_FILFUN"))})
	oStrPAJ:SetProperty( "PAJ_MATFUN", MODEL_FIELD_WHEN, {|oModel| oModel:GetOperation() == MODEL_OPERATION_INSERT .AND. !Empty(oModel:GetValue("PAJ_FILFUN"))} )
	oStrPAJ:SetProperty( "PAJ_MATFUN", MODEL_FIELD_VALID,{|oModel| IIF(!Empty(oModel:GetValue("PAJ_MATFUN")),FsVldMat(oModel:GetValue("PAJ_FILFUN"),oModel:GetValue("PAJ_MATFUN")),.T.) .AND. FsVldCmp(oModel)} )
	oStrPAJ:SetProperty( "PAJ_DTINI" , MODEL_FIELD_VALID,{|oModel| FSVldDtIn() } )
	oStrPAJ:SetProperty( "PAJ_DTFIM" , MODEL_FIELD_VALID,{|oModel| FSVldDtFm() } )
		
	oStrPAJ:SetProperty( "PAJ_TPDATA", MODEL_FIELD_WHEN, {|oModel| oModel:GetOperation() == MODEL_OPERATION_INSERT } )
	oStrPAJ:SetProperty( "PAJ_DTINI", MODEL_FIELD_WHEN, {|oModel| oModel:GetOperation() == MODEL_OPERATION_INSERT } )
	
	If IsInCallStack("U_F1301104")
		oStrGrid:SetProperty( "PAJ_FILSUB", MODEL_FIELD_VALID,{|oModel| ExistCpo("SM0",cEmpAnt+oModel:GetValue("PAJ_FILSUB"))})
		oStrGrid:SetProperty( "PAJ_MATSUB", MODEL_FIELD_WHEN, {|oModel| !Empty(oModel:GetValue("PAJ_FILSUB"))} )
		oStrGrid:SetProperty( "PAJ_MATSUB", MODEL_FIELD_VALID,{|oModel| FsVldMat(oModel:GetValue("PAJ_FILSUB"),oModel:GetValue("PAJ_MATSUB"))} )
		oStrGrid:SetProperty( "PAJ_FILFUN", MODEL_FIELD_WHEN, {|oModel| !Empty(oModel:GetValue("PAJ_FILSUB")) .AND. !Empty(oModel:GetValue("PAJ_MATSUB") )} )
		oStrGrid:SetProperty( "PAJ_FILFUN", MODEL_FIELD_VALID,{|oModel| ExistCpo("SM0",cEmpAnt+oModel:GetValue("PAJ_FILFUN"))})
		oStrGrid:SetProperty( "PAJ_MATFUN", MODEL_FIELD_WHEN, {|oModel| !Empty(oModel:GetValue("PAJ_FILFUN")) } )
		oStrGrid:SetProperty( "PAJ_MATFUN", MODEL_FIELD_VALID,{|oModel| FsVldMat(oModel:GetValue("PAJ_FILFUN"),oModel:GetValue("PAJ_MATFUN")) .AND. FsVldCmp(oModel)} )	
	
		oStrPAJ:SetProperty( "PAJ_DTFIM", MODEL_FIELD_OBRIGAT, .T.)
		oStrPAJ:SetProperty( "PAJ_FILSUB", MODEL_FIELD_OBRIGAT, .F.)
		oStrPAJ:SetProperty( "PAJ_MATSUB", MODEL_FIELD_OBRIGAT, .F.)
		oStrPAJ:SetProperty( "PAJ_FILFUN", MODEL_FIELD_OBRIGAT, .F.)
		oStrPAJ:SetProperty( "PAJ_MATFUN", MODEL_FIELD_OBRIGAT, .F.)
		oStrPAJ:SetProperty( "PAJ_MOTIVO", MODEL_FIELD_OBRIGAT, .F.)
		oStrGrid:SetProperty( "PAJ_FILSUB", MODEL_FIELD_OBRIGAT, .T.)
		oStrGrid:SetProperty( "PAJ_MATSUB", MODEL_FIELD_OBRIGAT, .T.)
		oStrGrid:SetProperty( "PAJ_FILFUN", MODEL_FIELD_OBRIGAT, .T.)
		oStrGrid:SetProperty( "PAJ_MATFUN", MODEL_FIELD_OBRIGAT, .T.)
	EndIf	
	
	oModel:SetDescription("Cadastro de Substituição")
	
	oModel:AddFields("PAJMASTER", /*cOwner*/, oStrPAJ)
	oModel:AddGrid("PAJDETAIL", "PAJMASTER" , oStrGrid)
	
	oModel:GetModel( 'PAJDETAIL' ):SetOptional( .T. )
	
	oModel:GetModel( 'PAJDETAIL' ):SetUniqueLine( { 'PAJ_FILSUB', 'PAJ_MATSUB' } )
		
	oModel:SetPrimaryKey({"PAJ_FILIAL","PAJ_CODIGO"})
	
Return oModel

/*
{Protheus.doc} ViewDef()
Interface do cadastro de substituição
@Author     Bruno de Oliveira
@Since      14/11/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_011
@Param		oView, interface
*/
Static Function ViewDef()
	
	Local oModel := FWLoadModel('F1301101')
	Local oStrPAJ := FWFormStruct(2, "PAJ")
	Local oView	:= FWFormView():New()
	
	oStrPAJ:RemoveField("PAJ_CODIGO")
	oStrPAJ:RemoveField("PAJ_STATUS")
	oStrPAJ:RemoveField("PAJ_USUARI")
	oStrPAJ:RemoveField("PAJ_NOMUSU")
	oStrPAJ:RemoveField("PAJ_DTINCL")
	oStrPAJ:RemoveField("PAJ_HRINCL")
	
	oStrPAJ:SetProperty('PAJ_MATSUB' , MVC_VIEW_LOOKUP, "FSSRAS" )
	oStrPAJ:SetProperty('PAJ_MATFUN' , MVC_VIEW_LOOKUP, 'FSFUNS' )
	
	oView:SetModel(oModel)
	oView:AddField("VIEW_PAJ", oStrPAJ, 'PAJMASTER')
	
	oView:CreateHorizontalBox("TOP", 100)
	
	oView:SetOwnerView("VIEW_PAJ", "TOP")
	
Return oView

/*
{Protheus.doc} F1301102()
Busca das informações do gatilho
@Author     Bruno de Oliveira
@Since      14/11/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_011
@Param		cCampo, identificação do gatilho
@Return		cRet, retorno da informação
*/
User Function F1301102(cCampo,cTipo)

	Local aArea := GetArea()
	Local cRet	:= ""
	Local cQuery := ""
	Local oMdl  := FwModelActive()
	Local oMdlPAJ := oMdl:GetModel("PAJMASTER")
	Local oMdlPGd := oMdl:GetModel("PAJDETAIL")
	Local cFilApr := oMdlPAJ:GetValue("PAJ_FILSUB")
	Local cMatApr := oMdlPAJ:GetValue("PAJ_MATSUB")
	Local cFilFun := oMdlPAJ:GetValue("PAJ_FILFUN")
	Local cMatFun := oMdlPAJ:GetValue("PAJ_MATFUN")	
	Local cAlias1 := GetNextAlias()
	
	If cTipo == "Grid"
		cFilApr := oMdlPGd:GetValue("PAJ_FILSUB")
		cMatApr := oMdlPGd:GetValue("PAJ_MATSUB")
		cFilFun := oMdlPGd:GetValue("PAJ_FILFUN")
		cMatFun := oMdlPGd:GetValue("PAJ_MATFUN")	
	EndIf
	
	If cCampo == "NOMSUB"
	
		cRet := Posicione("SRA",1,cFilApr+cMatApr,"RA_NOME")
	
	ElseIf cCampo == "FILPOS"
	
		cQuery += "SELECT RCX_FILIAL, RCX_POSTO FROM " + RetSqlName("RCX") + " "
		cQuery += "WHERE RCX_FILFUN = '" + cFilApr + "' AND "
		cQuery += "RCX_MATFUN = '" + cMatApr + "' AND "
		cQuery += "RCX_SUBST = '2' AND D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAlias1)
		
		If (cAlias1)->(!EOF())
			cRet := (cAlias1)->RCX_FILIAL
		EndIf
		
	ElseIf cCampo == "CODPOS"
	
		cQuery += "SELECT RCX_FILIAL, RCX_POSTO FROM " + RetSqlName("RCX") + " "
		cQuery += "WHERE RCX_FILFUN = '" + cFilApr + "' AND "
		cQuery += "RCX_MATFUN = '" + cMatApr + "' AND "
		cQuery += "RCX_SUBST = '2' AND D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAlias1)
		
		If (cAlias1)->(!EOF())
			cRet := (cAlias1)->RCX_POSTO
		EndIf
	
	ElseIf cCampo == "NOMFUN"
	
		cRet := Posicione("SRA",1,cFilFun+cMatFun,"RA_NOME")
	
	ElseIf cCampo == "FILPFN"
	
		cQuery += "SELECT RCX_FILIAL, RCX_POSTO FROM " + RetSqlName("RCX") + " "
		cQuery += "WHERE RCX_FILFUN = '" + cFilFun + "' AND "
		cQuery += "RCX_MATFUN = '" + cMatFun + "' AND "
		cQuery += "RCX_SUBST = '2' AND D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAlias1)
		
		If (cAlias1)->(!EOF())
			cRet := (cAlias1)->RCX_FILIAL
		EndIf
		
	
	ElseIf cCampo == "CODPFN"
	
		cQuery += "SELECT RCX_FILIAL, RCX_POSTO FROM " + RetSqlName("RCX") + " "
		cQuery += "WHERE RCX_FILFUN = '" + cFilFun + "' AND "
		cQuery += "RCX_MATFUN = '" + cMatFun + "' AND "
		cQuery += "RCX_SUBST = '2' AND D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAlias1)
		
		If (cAlias1)->(!EOF())
			cRet := (cAlias1)->RCX_POSTO
		EndIf
		
	
	EndIf
	
	RestArea(aArea)

Return cRet

/*
{Protheus.doc} F1301103()
Filtro da consulta padrão
@Author     Bruno de Oliveira
@Since      16/11/2017
@Return		cRet, Filtro
*/
User Function F1301103(nOpcao)

	Local oMdl    := FwModelActive()
	Local oMdlLJ  := oMdl:GetModel("PAJMASTER")
	Local cFilSub := oMdlLJ:GetValue("PAJ_FILSUB")
	Local cFilfun := oMdlLJ:GetValue("PAJ_FILFUN")
	Local lRet    := .F.
	Local aBrowse := {}
	Local oLayer  := FWLayer():new()
	Local cQuery  := ""
	Local cAlias1 := GetNextAlias()
	Local cQuery2 := ""
	Local cAlias2 := ""
	Local cFilRCX := ""
	Local cPosto  := ""
	Local aIndex  := {}
 	Local aSeek   := {}

	AAdd(aSeek, {"Matrícula", {{"", "C", TamSX3("RA_MAT")[1] , 0, "Matrícula", , }}, 1, .T.}) 
   	AAdd(aSeek, {"Nome"     , {{"", "C", TamSX3("RA_NOME")[1], 0, "Nome"     , , }}, 2, .T.})

	AAdd(aIndex, "RA_MAT" )
   	AAdd(aIndex, "RA_NOME")
	
	oBrowse 	:= FWFormBrowse():New()
	
	cQuery 	:= " SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME"
	cQuery 	+= " FROM " + RetSqlName("SRA") + " SRA "
	cQuery 	+= " WHERE "
	If nOpcao == 1
		cQuery 	+= "SRA.RA_FILIAL = '" + cFilSub + "' "
	Else
		cQuery 	+= "SRA.RA_FILIAL = '" + cFilfun + "' "
	EndIf
	cQuery 	+= " AND SRA.D_E_L_E_T_	= ' '"
	cQuery  += "ORDER BY RA_FILIAL, RA_MAT"

	DEFINE MSDIALOG oDlg FROM 0,0 TO 500,800 TITLE OemToAnsi("Consulta Padrão") PIXEL OF oMainWnd
	
		oLayer:init(oDlg,.F., .T.)
		
		oLayer:addLine('Sup',80,.F.)
		oLayer:addLine('Inf',90,.F.)	
		oLayer:addCollumn('Col',100,.F.,'Sup')
		oLayer:addCollumn('Col',100,.F.,'Inf')		
		
		oLayer:addWindow('Col','Browse' ,''	,100,.T.,.F.,{|| /*"Clique janela 01!"*/ },'Sup',{|| /*"Janela 01 recebeu foco!"*/ })
		oLayer:addWindow('Col','Button' ,''	,100,.T.,.T.,{|| /*"Clique janela 02!"*/ },'Inf',{|| /*"Janela 02 recebeu foco!"*/ })
		
		oPanel1 	:= oLayer:GetWinPanel('Col','Browse','Sup')
		oPanel1:FreeChildren()
		oPanel2 	:= oLayer:GetWinPanel('Col','Button','Inf')
		oPanel2:FreeChildren()
	
		oBrowse:SetOwner(oPanel1)
		oBrowse:SetDescription("Consulta Padrão") 
		oBrowse:SetDataQuery(.T.)
		oBrowse:SetAlias(cAlias1)
		oBrowse:SetQueryIndex(aIndex)
		oBrowse:SetQuery(cQuery) 
    	oBrowse:SetSeek(,aSeek)		
 		oBrowse:SetUseFilter( .F. )
		oBrowse:DisableDetails()
		oBrowse:DisableConfig() 

		ADD COLUMN oColumn DATA {|| RA_MAT}     TITLE 'Matricula' 	    SIZE TamSX3('RA_MAT')[1]  OF oBrowse
		ADD COLUMN oColumn DATA {|| RA_NOME}    TITLE 'Nome   ' 	    SIZE TamSX3('RA_NOME')[1]  OF oBrowse
		
		oBrowse:Activate()
	
		TButton():New( 010, 002, "OK"			, oPanel2,{|| lRet := .T.,cMat := (oBrowse:Alias())->RA_MAT,cNomMat := (oBrowse:Alias())->RA_NOME,oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
  		TButton():New( 010, 052, "Cancelar"   	, oPanel2,{|| lRet := .F.,oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
        
	ACTIVATE MSDIALOG oDLG  CENTER
		
	If lRet	
		IF !(Empty(cMat))
		
			cAlias2 := GetNextAlias()
		
			cQuery2 += "SELECT RCX_FILIAL, RCX_POSTO FROM " + RetSqlName("RCX") + " "
			cQuery2 += "WHERE "
			If nOpcao == 1
				cQuery2 += "RCX_FILFUN = '" + cFilSub + "' AND "
			Else
				cQuery2 += "RCX_FILFUN = '" + cFilfun + "' AND "
			EndIf
			cQuery2 += "RCX_MATFUN = '" + cMat + "' AND "
			cQuery2 += "RCX_SUBST = '2' AND D_E_L_E_T_ = ' ' "
			
			cQuery2 := ChangeQuery(cQuery2)
			dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery2), cAlias2)
			
			If (cAlias2)->(!EOF())
				cFilRCX := (cAlias2)->RCX_FILIAL
				cPosto  := (cAlias2)->RCX_POSTO
			EndIf
						
			If nOpcao == 1 //Substituido
				oMdlLJ:SetValue("PAJ_MATSUB",cMat)
				oMdlLJ:SetValue("PAJ_NOMSUB",cNomMat)
				oMdlLJ:SetValue("PAJ_FILPOS",cFilRCX)
				oMdlLJ:SetValue("PAJ_CODPOS",cPosto)
			Else //Substituto
				oMdlLJ:SetValue("PAJ_MATFUN",cMat)
				oMdlLJ:SetValue("PAJ_NOMFUN",cNomMat)
				oMdlLJ:SetValue("PAJ_FILPFN",cFilRCX)
				oMdlLJ:SetValue("PAJ_CODPFN",cPosto)
			EndIf
		Else
			lRet := .F.		
		EndIf			
	EndIf
	
Return lRet

/*
{Protheus.doc} F1301105()
Retorno da consulta especifica
@Author     Bruno de Oliveira
@Since      17/11/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_011
*/
User Function F1301105(nOpc)
	
	Local cRet := ""
	Local oMdl    := FwModelActive()
	Local oMdlLJ  := oMdl:GetModel("PAJDETAIL")
	
	If nOpc == 1
		cRet := M->PAJ_MATSUB
	Else
		cRet := M->PAJ_MATFUN
	EndIf
	
	If IsInCallStack("U_F1301104")
		If nOpc == 1
			oMdlLJ:SetValue("PAJ_NOMSUB",M->PAJ_NOMSUB)
		Else
			oMdlLJ:SetValue("PAJ_NOMFUN",M->PAJ_NOMFUN)
		EndIf
	EndIf
	
Return cRet

/*
{Protheus.doc} FsVldCmp()
Cadastro de Substituição
@Author     Bruno de Oliveira
@Since      17/11/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_011
*/
Static Function FsVldCmp(oMdlPAJ)

	Local cFilSub := oMdlPAJ:GetValue("PAJ_FILSUB")
	Local cMatSub := oMdlPAJ:GetValue("PAJ_MATSUB")
	Local cFilFun := oMdlPAJ:GetValue("PAJ_FILFUN")
	Local cMatFun := oMdlPAJ:GetValue("PAJ_MATFUN")
	Local lRet    := .T.
	
	If cFilSub == cFilFun .AND. cMatSub == cMatFun
		Help("",1, "Help", "Validação do Substituto", "Não pode ser o mesmo funcionário que o aprovador substituido", 3, 0)
		lRet := .F.
	Else
		cCodSub := Posicione("SRA",1,cFilSub+cMatSub,"RA_CODFUNC")
		cCodFun := Posicione("SRA",1,cFilFun+cMatFun,"RA_CODFUNC")
		nNvlSub := Posicione("SRJ",1,xFilial("SRJ")+cCodSub,"RJ_XGEREN")
		nNvlFun := Posicione("SRJ",1,xFilial("SRJ")+cCodFun,"RJ_XGEREN")
		If nNvlFun > nNvlSub
			Help("",1, "Help", "Validação do Substituto", "Nível do substituto precisa ser superior ou igual ao Substituído", 3, 0)
			lRet := .F.	
		EndIf
	EndIf		

Return lRet

/*
{Protheus.doc} F1301104()
View da Multiplas Substituições
@Author     Bruno de Oliveira
@Since      16/11/2017
@Return		oView2, objeto view
*/
User Function F1301104()

	Local oModel  := FWLoadModel('F1301101')
	Local oStrPJC := FWFormStruct(2,"PAJ",{|cCampo| AllTrim(cCampo) $ "PAJ_DTINI|PAJ_DTFIM"} )
	Local oStrPJG := FWFormStruct(2,"PAJ",{|cCampo| AllTrim(cCampo) $ "PAJ_FILSUB|PAJ_MATSUB|PAJ_NOMSUB|PAJ_FILFUN|PAJ_MATFUN|PAJ_NOMFUN|PAJ_MOTIVO"} )
	Local oView2  := FWFormView():New()
	Local lRet    := .F.
	
	oStrPJG:SetProperty('PAJ_MATSUB' , MVC_VIEW_LOOKUP, 'FSSRAC' )
	oStrPJG:SetProperty('PAJ_MATFUN' , MVC_VIEW_LOOKUP, 'FSSRAG' )
	
	oView2:SetModel(oModel)
	oView2:AddField("VIEW_CPAJ", oStrPJC, 'PAJMASTER')
	oView2:AddGrid("VIEW_GPAJ", oStrPJG, "PAJDETAIL")
	
	oView2:CreateHorizontalBox("TOP", 20)
	oView2:CreateHorizontalBox("BOTTOM", 80)
	
	oView2:SetOwnerView("VIEW_CPAJ", "TOP")
	oView2:SetOwnerView("VIEW_GPAJ", "BOTTOM")
	
	oExecView := FWViewExec():New()
	oExecView:SetTitle("Cadastro de Multiplas Substituições")
	oExecView:SetView(oView2)
	oExecView:SetOK({|| lRet := FsMultSubs(oModel:GetModel("PAJMASTER"),oModel:GetModel("PAJDETAIL")) })
	oExecView:SetModal( .T. )
	oExecView:SetModel( oModel )
	oExecView:SetOperation(MODEL_OPERATION_INSERT)
	oExecView:SetReduction(60)
	oExecView:OpenView(.F.)
	oExecView:DeActivate()

Return lRet

/*
{Protheus.doc} FsMultSubs()
Gravação das Multiplas Substituições
@Author     Bruno de Oliveira
@Since      21/11/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_011
@Param		oCabec, modelo do cabeçalho
@Param		oItensSub, modelo do item
*/
Static Function FsMultSubs(oCabec,oItensSub)

	Local lOk := .T.
	Local nI := 0
	Local nX := 0
	Local cPerIni := oCabec:GetValue("PAJ_DTINI")
	Local cPerFim := oCabec:GetValue("PAJ_DTFIM")
	Local aRet := {}
	Local cLinhas := ""
	Local aDdUser := PswRet()
	Local dDtAtual := dDatabase
	
	If !Empty(cPerIni) .AND. !Empty(cPerFim)
	
		For nI := 1 To oItensSub:Length()
			
			oItensSub:GoLine( nI )
			
			If !(oItensSub:IsDeleted())
				lOk := .T.

				cQuery  := ""
				cAlias1 := GetNextAlias()
				
				cQuery 	:= " SELECT PAJ_CODIGO "
				cQuery 	+= " FROM " + RetSqlName("PAJ") + " PAJ "
				cQuery 	+= " WHERE "
				cQuery 	+= " PAJ.PAJ_FILSUB = '" + oItensSub:GetValue("PAJ_FILSUB") + "' AND"
				cQuery  += " PAJ.PAJ_MATSUB = '" + oItensSub:GetValue("PAJ_MATSUB") + "' AND"
				cQuery  += " ((PAJ.PAJ_DTINI <= '" + DTOS(cPerIni) + "' AND"
				cQuery  += " (PAJ.PAJ_DTFIM >= '" + DTOS(cPerIni) + "' OR PAJ.PAJ_DTFIM = ' ')) " 			
				cQuery  += " OR ( PAJ.PAJ_DTINI <= '" + DTOS(cPerFim) + "' AND"
				cQuery  += " (PAJ.PAJ_DTFIM >= '" + DTOS(cPerFim) + "' OR PAJ.PAJ_DTFIM = ' '))) " 					
				cQuery 	+= " AND PAJ.D_E_L_E_T_	= ' '"
					
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1,.T.,.T.)
				
				If (cAlias1)->(!EOF())
					AADD(aRet,{nI})
					cLinhas += STR(nI)+","
				EndIf
			EndIf
			
		Next nI
	
	Else
		Help("",1, "Help", "Validação do Período", "É obrigatório o preenchimento do período inicial e final", 3, 0)
		lOk := .F.	
	EndIf
	
	If lOK .AND. Len(aRet) == 0
	
		For nX := 1 To oItensSub:Length()
			
		oItensSub:GoLine( nX )
		
		If !(oItensSub:IsDeleted())
			If !Empty(oItensSub:GetValue("PAJ_FILSUB")) .AND. !Empty(oItensSub:GetValue("PAJ_MATSUB"))	
				RecLock("PAJ",.T.)
				PAJ->PAJ_CODIGO := GetSx8Num("PAJ","PAJ_CODIGO")
				PAJ->PAJ_FILSUB := oItensSub:GetValue("PAJ_FILSUB")
				PAJ->PAJ_MATSUB := oItensSub:GetValue("PAJ_MATSUB")
				PAJ->PAJ_NOMSUB := oItensSub:GetValue("PAJ_NOMSUB")
				PAJ->PAJ_FILFUN := oItensSub:GetValue("PAJ_FILFUN")
				PAJ->PAJ_MATFUN := oItensSub:GetValue("PAJ_MATFUN")
				PAJ->PAJ_NOMFUN := oItensSub:GetValue("PAJ_NOMFUN")
				PAJ->PAJ_DTINI  := cPerIni
				PAJ->PAJ_DTFIM  := cPerFim
				PAJ->PAJ_MOTIVO := oItensSub:GetValue("PAJ_MOTIVO")
				PAJ->PAJ_STATUS := "1"	
				PAJ->PAJ_TPDATA := "1"
				PAJ->PAJ_USUARI := aDdUser[1][1]
				PAJ->PAJ_NOMUSU := aDdUser[1][2]
				PAJ->PAJ_DTINCL := dDtAtual
				PAJ->PAJ_HRINCL := SUBSTR(Time(),1,5)
				PAJ->(MsUnlock())
			
				ConfirmSX8()			
			
				U_F1301107(PAJ->PAJ_FILSUB,PAJ->PAJ_MATSUB,PAJ->PAJ_FILFUN,PAJ->PAJ_MATFUN,PAJ->PAJ_DTINI,PAJ->PAJ_DTFIM,PAJ->PAJ_MOTIVO) //Envia E-mail
			EndIf
		EndIf
			
		Next nX
	Else
		Help("",1, "Help", "Validação na Gravação", "Já existe cadastro de substituição para o(s) substituido(s) da(s) linha(s) " + cLinhas + " no período informado", 3, 0)
		lOK := .F.
		aRet := {}
	EndIf

Return lOk

/*
{Protheus.doc} F1301106()
Filtro da consulta padrão
@Author     Bruno de Oliveira
@Since      21/11/2017
@Param		nOpcao, identificação 1-Substituido ou 2-Substituto
@Return		lRet, Confirmou ou cancelou
*/
User Function F1301106(nOpcao)

	Local oMdl    := FwModelActive()
	Local oMdlPAJ := oMdl:GetModel("PAJDETAIL")
	Local cFilSub := oMdlPAJ:GetValue("PAJ_FILSUB")
	Local cFilfun := oMdlPAJ:GetValue("PAJ_FILFUN")
	Local lRet    := .F.
	Local aBrowse := {}
	Local oLayer  := FWLayer():new()
	Local cQuery  := ""
	Local cAlias1 := GetNextAlias()
	Local aIndex  := {}
 	Local aSeek   := {}

	AAdd(aSeek, {"Matrícula", {{"", "C", TamSX3("RA_MAT")[1] , 0, "Matrícula", , }}, 1, .T.}) 
   	AAdd(aSeek, {"Nome"     , {{"", "C", TamSX3("RA_NOME")[1], 0, "Nome"     , , }}, 2, .T.})

	AAdd(aIndex, "RA_MAT" )
   	AAdd(aIndex, "RA_NOME")
	
	oBrowse 	:= FWFormBrowse():New()
	
	cQuery 	:= " SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME"
	cQuery 	+= " FROM " + RetSqlName("SRA") + " SRA "
	cQuery 	+= " WHERE "
	If nOpcao == 1
		cQuery 	+= "SRA.RA_FILIAL = '" + cFilSub + "' "
	Else
		cQuery 	+= "SRA.RA_FILIAL = '" + cFilfun + "' "
	EndIf
	cQuery 	+= " AND SRA.D_E_L_E_T_	= ' '"
	cQuery  += "ORDER BY RA_FILIAL, RA_MAT"

	DEFINE MSDIALOG oDlg FROM 0,0 TO 500,800 TITLE OemToAnsi("Consulta Padrão") PIXEL OF oMainWnd
	
		oLayer:init(oDlg,.F., .T.)
		
		oLayer:addLine('Sup',80,.F.)
		oLayer:addLine('Inf',90,.F.)	
		oLayer:addCollumn('Col',100,.F.,'Sup')
		oLayer:addCollumn('Col',100,.F.,'Inf')		
		
		oLayer:addWindow('Col','Browse' ,''	,100,.T.,.F.,{|| /*"Clique janela 01!"*/ },'Sup',{|| /*"Janela 01 recebeu foco!"*/ })
		oLayer:addWindow('Col','Button' ,''	,100,.T.,.T.,{|| /*"Clique janela 02!"*/ },'Inf',{|| /*"Janela 02 recebeu foco!"*/ })
		
		oPanel1 	:= oLayer:GetWinPanel('Col','Browse','Sup')
		oPanel1:FreeChildren()
		oPanel2 	:= oLayer:GetWinPanel('Col','Button','Inf')
		oPanel2:FreeChildren()

		oBrowse:SetOwner(oPanel1)
		oBrowse:SetDescription("Consulta Padrão") 
		oBrowse:SetDataQuery(.T.)
		oBrowse:SetAlias(cAlias1)
		oBrowse:SetQueryIndex(aIndex)
		oBrowse:SetQuery(cQuery) 
    	oBrowse:SetSeek(,aSeek)		
 		oBrowse:SetUseFilter( .F. )
		oBrowse:DisableDetails()
		oBrowse:DisableConfig()
		
		ADD COLUMN oColumn DATA {|| RA_MAT}     TITLE 'Matricula' 	    SIZE TamSX3('RA_MAT')[1]  OF oBrowse
		ADD COLUMN oColumn DATA {|| RA_NOME}    TITLE 'Nome   ' 	    SIZE TamSX3('RA_NOME')[1]  OF oBrowse
		
		oBrowse:Activate()
	
		TButton():New( 010, 002, "OK"			, oPanel2,{|| lRet := .T.,cMat := (oBrowse:Alias())->RA_MAT,cNomMat := (oBrowse:Alias())->RA_NOME,oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
  		TButton():New( 010, 052, "Cancelar"   	, oPanel2,{|| lRet := .F.,oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
        
	ACTIVATE MSDIALOG oDLG  CENTER
		
	If lRet	
		IF !(Empty(cMat))				
			If nOpcao == 1 //Substituido
				oMdlPAJ:SetValue("PAJ_MATSUB",cMat)
				oMdlPAJ:LoadValue("PAJ_NOMSUB",cNomMat)
			Else //Substituto
				oMdlPAJ:SetValue("PAJ_MATFUN",cMat)
				oMdlPAJ:LoadValue("PAJ_NOMFUN",cNomMat)
			EndIf
		Else
			lRet := .F.		
		EndIf			
	EndIf

Return lRet

/*
{Protheus.doc} FsPosVld()
Pós validação do Model
@Author     Bruno de Oliveira
@Since      21/11/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_011
*/
Static Function FsPosVld()

	Local oMdl := FwModelActive()
	Local oMdlPAJ := oMdl:GetModel("PAJMASTER")
	Local cTpData := oMdlPAJ:GetValue("PAJ_TPDATA")
	Local cDtFim  := oMdlPAJ:GetValue("PAJ_DTFIM")
	Local cStatus := oMdlPAJ:GetValue("PAJ_STATUS")
	Local cQuery := ""
	Local cAlias1 := GetNextAlias()
	Local lRet := .T.
	
	If oMdl:GetOperation() == MODEL_OPERATION_INSERT
		
		If cTpData == "1" //Determinado
			If Empty(cDtFim)
				Help("",1, "Help", "Validação Data", "É obrigatório o preenchimento da data final de um período determinado", 3, 0)
				lRet := .F.
			EndIf
		EndIf
	
		If lRet
			cQuery 	+= " SELECT PAJ_CODIGO "
			cQuery 	+= " FROM " + RetSqlName("PAJ") + " PAJ "
			cQuery 	+= " WHERE "
			cQuery 	+= " PAJ.PAJ_FILSUB = '" + oMdlPAJ:GetValue("PAJ_FILSUB") + "' AND"
			cQuery  += " PAJ.PAJ_MATSUB = '" + oMdlPAJ:GetValue("PAJ_MATSUB") + "' AND"
			cQuery  += " ((PAJ.PAJ_DTINI <= '" + DTOS(oMdlPAJ:GetValue("PAJ_DTINI")) + "' AND"
			cQuery  += " (PAJ.PAJ_DTFIM >= '" + DTOS(oMdlPAJ:GetValue("PAJ_DTINI")) + "' OR PAJ.PAJ_DTFIM = ' ')) " 
			cQuery  += " OR ( PAJ.PAJ_DTINI <= '" + DTOS(oMdlPAJ:GetValue("PAJ_DTFIM")) + "' AND"
			cQuery  += " (PAJ.PAJ_DTFIM >= '" + DTOS(oMdlPAJ:GetValue("PAJ_DTFIM")) + "' OR PAJ.PAJ_DTFIM = ' '))) " 						
			cQuery 	+= " AND PAJ.D_E_L_E_T_	= ' '"
				
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1,.T.,.T.)
			
			If (cAlias1)->(!EOF())
				Help("",1, "Help", "Validação Substituiçao", "Já existe cadastro de substituição para o substituido no período informado", 3, 0)
				lRet := .F.
			EndIf
		EndIf
		
	ElseIf oMdl:GetOperation() == MODEL_OPERATION_DELETE
	
		If cStatus == "2" .OR. cStatus == "3" 
			Help("",1, "Help", "Validação da exclusão", "Não é permitido excluir cadastros Ativos ou Inativos", 3, 0)
			lRet := .F.		
		EndIf
	
	ElseIf oMdl:GetOperation() == MODEL_OPERATION_UPDATE
	
		If cStatus == "3" 
			Help("",1, "Help", "Validação da alteração", "Não é permitido alterar cadastros Inativos", 3, 0)
			lRet := .F.		
		EndIf
	
	EndIf

Return lRet

/*
{Protheus.doc} FsCommtMd()
Gravação do Model
@Author     Bruno de Oliveira
@Since      27/11/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_011
*/
Static Function FsCommtMd(oModel)

	Local oMdlPAJ := oModel:GetModel("PAJMASTER")
	Local cFilSub := oMdlPAJ:GetValue("PAJ_FILSUB")
	Local cMatSub := oMdlPAJ:GetValue("PAJ_MATSUB")
	Local cFilFun := oMdlPAJ:GetValue("PAJ_FILFUN")
	Local cMatFun := oMdlPAJ:GetValue("PAJ_MATFUN")
	Local cPerIni := oMdlPAJ:GetValue("PAJ_DTINI")
	Local cPerFim := oMdlPAJ:GetValue("PAJ_DTFIM")
	Local cMotivo := oMdlPAJ:GetValue("PAJ_MOTIVO")
	Local aDdUser := PswRet()
	Local dDtAtual := dDatabase
	Local cHrAtual := SUBSTR(Time(),1,5)
	Local lRet := .T.
	
	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		oMdlPAJ:SetValue("PAJ_USUARI",aDdUser[1][1])
		oMdlPAJ:SetValue("PAJ_NOMUSU",aDdUser[1][2])
		oMdlPAJ:SetValue("PAJ_DTINCL",dDtAtual)
		oMdlPAJ:SetValue("PAJ_HRINCL",cHrAtual)
		
		If DTOS(cPerIni) <= DTOS(dDtAtual) .AND. (DTOS(cPerFim) >= DTOS(dDtAtual) .OR. Empty(cPerFim))
			oMdlPAJ:SetValue("PAJ_STATUS","2")
		EndIf
		
		If oModel:VldData()
			FWFormCommit( oModel )
			StartJob("U_F1301112",GetEnvServer(),.F.,{"01",cFilAnt})
			lRet := .T.
		Else
			lRet := .F.	
		EndIf
	
		If lRet
			U_F1301107(cFilSub,cMatSub,cFilFun,cMatFun,cPerIni,cPerFim,cMotivo) //Envia E-mail
		EndIf
	Else
		If oModel:VldData()
			FWFormCommit( oModel )
		EndIf	
	EndIf

Return lRet

/*
{Protheus.doc} F1301107()
Envio do E-mail para os envolvidos
@Author     Bruno de Oliveira
@Since      27/11/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_011
*/
User Function F1301107(cFilSub,cMatSub,cFilFun,cMatFun,cPerIni,cPerFim,cMotivo)

	Local cMailConta  := SuperGetMV("MV_RELAUSR")
	Local cUsuario	  := SubStr(cMailConta,1,At("@",cMailConta)-1)
	Local cMailServer := AllTrim(SuperGetMv("MV_RELSERV"))
	Local cMailSenha  := SuperGetMV("MV_RELAPSW")
	Local lMailAuth   := SuperGetMV("MV_RHAUTEN",,.F.)
	Local lUseSSL     := SuperGetMV("MV_RELSSL" ,,.F.)
	Local lUseTLS     := SuperGetMV("MV_RELTLS" ,,.F.)
	Local nAt		  := At(":",cMailServer)
	Local nMailPort   := 0	
	Local lRet        := .T.
	Local cAssunto    := "Substituição"
	Local cEmail      := ""
	Local cBody       := ""
	Local cMailSbd    := ""
	Local cMailSbt    := ""
	
	oServer	:= TMailManager():New()
	oServer:SetUseSSL(lUseSSL)
	oServer:SetUseTLS(lUseTLS)
	
	cMailSbd := Posicione("SRA",1,cFilSub+cMatSub,"RA_EMAIL")
	cSbtuido := Posicione("SRA",1,cFilSub+cMatSub,"RA_NOME")
	cMailSbt := Posicione("SRA",1,cFilFun+cMatFun,"RA_EMAIL")
	cSubtuto := Posicione("SRA",1,cFilFun+cMatFun,"RA_NOME")
	
	cEmail := Alltrim(cMailSbd) + ";" + Alltrim(cMailSbt)
	
	If nAt > 0 // Tratamento para usar a porta quando informada no mailserver
		nMailPort	:= VAL(SUBSTR(ALLTRIM(cMailServer),At(":",cMailServer) + 1,Len(ALLTRIM(cMailServer)) - nAt))
		cMailServer	:= SUBSTR(ALLTRIM(cMailServer),1,At(":",cMailServer)-1)
		oServer:Init("", cMailServer, cMailConta, cMailSenha,0,nMailPort)
	Else
		oServer:Init("", cMailServer, cMailConta, cMailSenha,0,nMailPort)
	EndIf
	
	If oServer:SMTPConnect() != 0
		lRet := .F.
	EndIf
	
	If lRet
		If lMailAuth
			If oServer:SMTPAuth(cMailConta, cMailSenha) != 0 //Tentar com conta e senha
				If oServer:SMTPAuth(cUsuario, cMailSenha) != 0 //Tentar com usuário e senha
					lRet := .F.
				EndIf
			EndIf			
		EndIf
	EndIf
	
	If lRet
		
		cBody := '<html><body><pre>'+CRLF
		cBody += '<b>Prezados, </b>'+CRLF
		cBody += 'O período de substituição das aprovações\reprovações das solicitações será a partir de ' + Dtoc(cPerIni) + ' até ' + IIF(!Empty(cPerFim),Dtoc(cPerFim),"tempo indetermindado") + '. ' + CRLF + CRLF
		cBody += 'O funcionário ' + Alltrim(cSbtuido) + ' substituirá o ' + Alltrim(cSubtuto) + '. '  + CRLF + CRLF
		cBody += 'Motivo: ' + cMotivo + ' ' + CRLF
		cBody += '</pre></body></html>'
		
		oMessage := TMailMessage():New()
		
		oMessage:Clear()
		oMessage:cFrom      := cMailConta
		oMessage:cTo        := cEmail
		oMessage:cCc        := ""
		oMessage:cSubject   := cAssunto
		oMessage:cBody      := cBody
						
		If !(oMessage:Send( oServer ) == 0) //Envia o e-mail
			lRet := .F.
		EndIf
		
	EndIf
	
	oServer:SMTPDisconnect() //Desconecta do servidor
	
Return lRet

/*
{Protheus.doc} FsVldMat()
Validação da Matricula
@Author     Bruno de Oliveira
@Since      04/12/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_011
*/
Static Function FsVldMat(cFilFun,cMatFun)

	Local aAreaSRA := SRA->(GetArea())
	Local lRet := .T.
	
	DbSelectArea("SRA")
	SRA->(DbSetOrder(1))
	If SRA->(DbSeek(cFilFun+cMatFun))
		lRet := .T.
	Else
		Help("",1, "Help", "Validação da matricula", "Não existe matricula informada no sistema", 3, 0)
		lRet := .F.	
	EndIf


	RestArea(aAreaSRA)

Return lRet 

/*
{Protheus.doc} FsVldMat()
Validação da data final
@Author     Bruno de Oliveira
@Since      04/12/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_011
*/
Static Function FSVldDtFm()

	Local aArea   := GetArea()
	Local oMdl    := FwModelActive()
	Local oMdlPAJ := oMdl:GetModel("PAJMASTER")
	Local dPerIni := oMdlPAJ:GetValue("PAJ_DTINI")
	Local dPerFim := oMdlPAJ:GetValue("PAJ_DTFIM")
	Local lRet    := .T.
	
	If DTOS(dPerFim) < DTOS(dPerIni)
		Help("",1, "Help", "Validação data fim", "Data final não pode ser menor que a data inicio", 3, 0)
		lRet := .F.
	EndIf
	
	RestArea(aArea)

Return lRet

/*
{Protheus.doc} FsVldMat()
Validação da dara inicial
@Author     Bruno de Oliveira
@Since      04/12/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_011
*/
Static Function FSVldDtIn()

	Local aArea   := GetArea()
	Local oMdl    := FwModelActive()
	Local oMdlPAJ := oMdl:GetModel("PAJMASTER")
	Local dPerIni := oMdlPAJ:GetValue("PAJ_DTINI")
	Local dDtAtual := dDatabase
	Local lRet    := .T.
	
	If DTOS(dPerIni) < DTOS(dDtAtual)
		Help("",1, "Help", "Validação data incial", "Data inicio não pode ser menor que a data base", 3, 0)
		lRet := .F.
	EndIf
	
	RestArea(aArea)

Return lRet