#Include 'Protheus.ch' 
#INCLUDE 'FWMVCDEF.CH'

Static lBtApRp := .T.  

/*
{Protheus.doc} WFLOG000()
Monitoramento do Envio de E-mail - Schedule Medição
@Autora     Thais Paiva
@Data      09/07/2021
@Versão    P12.1.27
*/
User Function WFLOG000()
	Local cFiltro	:= ""
	Local aRotina	:= MenuDef()
	
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("WFL")
	oMBrowse:SetDescription("Consulta Log Envio E-mail")
	
	oMBrowse:AddLegend('SUBSTR(UPPER(WFL->WFL_MSG1),1,3) <> "NÃO" .AND. UPPER(WFL->WFL_STAGER) <> "ERRO" .AND. UPPER(WFL_STAENV) <> "ERRO"', "GREEN", "OK")
	oMBrowse:AddLegend('SUBSTR(UPPER(WFL->WFL_MSG1),1,3) ==	 "NÃO"', "RED", "ERRO GRV/ENV")
	oMBrowse:AddLegend('UPPER(WFL->WFL_STAGER) == "ERRO"', "YELLOW", "ERRO PDF")
	oMBrowse:AddLegend('UPPER(WFL_STAENV) == "ERRO"', "ORANGE", "ERRO ENVIO")
	oMBrowse:SetMenuDef("WFLOG000")
	
	oMBrowse:SetFilterDefault("")
		
	oMBrowse:SetCacheView( .F. )
	oMBrowse:Activate()
	
Return

/*
{Protheus.doc} MenuDef()
Menu
@Autora     Thais Paiva
@Data      09/07/2021
@Versão    P12.1.27
@Return		aRotina, opções de menu
*/
Static Function MenuDef()
	
	Local aRotina := {}
	
	AAdd(aRotina,{"&Visualizar"	, "VIEWDEF.WFLOG000"    , 0, 2 } )
	// ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.WFLOG000" OPERATION 1 ACCESS 0	
	
	
Return aRotina

/*
{Protheus.doc} ModelDef()
Modelo de dados
@Autora     Thais Paiva
@Data      09/07/2021
@Versão    P12.1.27
@Return		oModel, Modelo de dados
*/
Static Function ModelDef()
	
	Local oModel
	Local oStrWFL := FwFormStruct(1, "WFL")

	
	
	oModel := MPFormModel():New("MFLOG000",  /*bPreMd*/ , /*bPosMd*/ , /*bCommit*/ , /*bCancel*/ )	

	oModel:AddFields("FORMWFL", /*cOwner*/, oStrWFL)
	
	oModel:SetPrimaryKey({'WFL_FILIAL','WFL_NUM','WFL_DATA','WFL_HORA'})
	
	oModel:GetModel("FORMWFL"):SetDescription("Log Envio E-mail")
	
			
Return oModel

/*
{Protheus.doc} ViewDef()
Interface
@Autora     Thais Paiva
@Data      09/07/2021
@Versão    P12.1.27
@Param		oView, interface
*/
Static Function ViewDef()
	
	Local oModel := FWLoadModel('WFLOG000')
	Local oStrRH3 := FWFormStruct(2, "WFL")
	Local oView	:= FWFormView():New()
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_WFL", oStrRH3, "FORMWFL")
	oView:CreateHorizontalBox("TELA",100)
	oView:EnableTitleView('VIEW_WFL', 'Dados do Envio do E-mail' )
	oView:SetCloseOnOk({||.T.})
	oView:SetOwnerView("VIEW_WFL","TELA")
	
Return oView
