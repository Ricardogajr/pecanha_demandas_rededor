#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
/*{Protheus.doc} F0200502
Cadastro de Grau de Liberdade de Distribuição
@author 	Cristiane Thomaz Polli
@since 		15/07/2016
@version	12.1.7
@Project 	MAN00000463301_EF_005
*/ 
User Function F0200502()

	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('P08')
	oBrowse:SetDescription('Grau de Liberdade da Distribuição')
	If P08->(FieldPos("P08_MSBLQL")) > 0
		oBrowse:AddLegend( "P08_MSBLQL == '1'", "RED", "Bloqueado"  )
		oBrowse:AddLegend( "P08_MSBLQL <> '1'", "GREEN", "Ativo"  )
	EndIf
	oBrowse:DisableDetails()
	oBrowse:Activate()

Return NIL
/*{Protheus.doc} MenuDef
(Menu da rotina)
@author 	Cristiane Thomaz Polli
@since 		15/07/2016
@version 	12.1.7
@return		aRotina, array contendo as opções do menu
@Project 	MAN00000463301_EF_005
*/ 
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE '&Visualizar' ACTION 'VIEWDEF.F0200502' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE '&Incluir'    ACTION 'VIEWDEF.F0200502' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE '&Alterar'    ACTION 'VIEWDEF.F0200502' OPERATION 4 ACCESS 0

Return aRotina

/*{Protheus.doc} ModelDef
Modelo da Rotina
@author 	Cristiane Thomaz Polli
@since 		15/07/2016
@version 	12.1.7
@return 	oModel, objeto contendo o modelo
@Project 	MAN00000463301_EF_005
*/ 
Static Function ModelDef()

	Local oStruP08 := FWFormStruct( 1, 'P08')
	Local oModel
 
	oModel := MPFormModel():New('M0200502' )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields('P08UNICA', /*cOwner*/, oStruP08)
	oModel:GetModel('P08UNICA'):GetStruct():SetProperty("P08_GL",MODEL_FIELD_VALID,{||M02005VL()})
// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel('P08UNICA'):SetDescription('Grau de Liberdade da Distribuição')

Return oModel

/*{Protheus.doc} ViewDef 
Interface da rotina
@author 	Cristiane Thomaz Polli
@since 		15/07/2016
@version 	12.1.7
@return 	oView, objeto contendo a view
@Project 	MAN00000463301_EF_005
*/ 
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'F0200502' )
// Cria a estrutura a ser usada na View
	Local oStruP08 := FWFormStruct( 2, 'P08' )
	Local oView
	Local cCampos := {}

// Cria o objeto de View
	oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_P08', oStruP08, 'P08UNICA' )

// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_P08', 'TELA' )

Return oView
/*{Protheus.doc} M02005VL
Valida o contéudo digitado no campo P08_GL
@author		Cristiane Thomaz Polli
@since 		19/07/2016
@version 	12.1.7
@return 	lRetGl, .T. indica que o conteúdo é válido, .F. o conteúdo não  é válido.
@Project 	MAN00000463301_EF_005
*/ 
Static Function M02005VL()

	Local lRetGl	:= .T.
	Local oModel	:= FWModelActive()
	Local cInfGL	:= oModel:GetModel('P08UNICA'):GetValue('P08_GL')
	Local aArea		:= GetArea()
	
	dbSelectArea('P08')
	P08->(dbSetORder(1))
	if P08->(DbSeek(FwxFilial('P08') + cInfGL))
	
		Help(" ",1, 'Help','F0200502_01', "Contéudo utilizado em outro cadastro. Não é permitido informar  o mesmo contéudo!", 3, 0 )
		
		lRetGl	:= .F.
		
	EndIf

	RestArea(aArea)
		
Return lRetGl
