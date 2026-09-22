#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} FUNXCUR
Cadastro de vinculo de Funcionarios x Cursos
@author luciano.camargo
@since 17/05/2018
@version undefined
@see PE_GP010AGRV / PE_GP180TRA / ADICESTIM / ADIC1ESTIM / GRATITULA / GPE10MENU
@type function
/*/

User Function FUNXCUR()

	Local oBrowse
	Local cFilZZD as char
	
	Private aRotina := MenuDef()

	//Criação do objeoto Browse
	oBrowse := FWMBrowse():New()

	//Seta o Alias Browse
	oBrowse:SetAlias('ZZD')

	//Seta a descrição do Browse
	oBrowse:SetDescription('Vinculo Funcionarios x Cursos')

	If AllTrim(funname()) $ "MBRWZZD/GPEA010"
		//oBrowse:AddFilter( "Funcionario", "ZZD_MAT ='" + SRA->RA-MAT + "'", .T., .T., , , , "ZZD_MAT" )
		cFilZZD := "ZZD_FILIAL = '"+xFilial("ZZD")+"' .AND. ZZD_MAT ='" + SRA->RA_MAT + "'"
		oBrowse:SetFilterDefault(cFilZZd)

		aRotina := MenuDef()
	Endif

	//Grafico
	oBrowse:SetAttach(.T.)

	//Ativa o Browse
	oBrowse:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Cadastro de Funcionarios x Cursos - Menu Funcional
@author luciano.camargo
@since 17/05/2018
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Array contendo as Rotinas a executar do programa      ³
	³ ----------- Elementos contidos por dimensao ------------     ³
	³ 1. Nome a aparecer no cabecalho                              ³
	³ 2. Nome da Rotina associada                                  ³
	³ 3. Usado pela rotina                                         ³
	³ 4. Tipo de Transa‡„o a ser efetuada                          ³
	³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
	³    2 - Simplesmente Mostra os Campos                         ³
	³    3 - Inclui registros no Bancos de Dados                   ³
	³    4 - Altera o registro corrente                            ³
	³    5 - Remove o registro corrente do Banco de Dados          ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	AAdd(aRotina,{"&Pesquisar"	, "PesqBrw"				, 0, 1 } )
	AAdd(aRotina,{"&Visualizar"	, "VIEWDEF.FUNXCUR"    	, 0, 2 } )
	AAdd(aRotina,{"&Incluir"	, "VIEWDEF.FUNXCUR"    	, 0, 3 } )
	AAdd(aRotina,{"&Alterar"	, "VIEWDEF.FUNXCUR"    	, 0, 4 } )
	AAdd(aRotina,{"&Excluir"	, "VIEWDEF.FUNXCUR"    	, 0, 5 } )
	AAdd(aRotina,{"Imprimir"	, "VIEWDEF.FUNXCUR"    	, 0, 8 } )
	AAdd(aRotina,{"Copiar"		, "VIEWDEF.FUNXCUR"    	, 0, 9 } )

	// ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'        	OPERATION 1 ACCESS 0
	// ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.FUNXCUR' 	OPERATION 2 ACCESS 0
	// ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.FUNXCUR' 	OPERATION 3 ACCESS 0
	// ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.FUNXCUR' 	OPERATION 4 ACCESS 0
	// ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.FUNXCUR' 	OPERATION 5 ACCESS 0
	// ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.FUNXCUR' 	OPERATION 8 ACCESS 0
	// ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.FUNXCUR' 	OPERATION 9 ACCESS 0
 
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Cadastro de Funcionarios x Cursos - Modelo de Dados
@author luciano.camargo
@since 17/05/2018
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruZZD := FWFormStruct( 1, 'ZZD', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('FUNXCURM', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'ZZDMASTER', /*cOwner*/, oStruZZD, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({'ZZD_FILIAL','ZZD_MAT','ZZD_NMCURS'})

	If AllTrim(funname()) $ "MBRWZZD/GPEA010"

		//Iniciar o campo com o conteudo do cadastro de funcionario
		oStruZZD:SetProperty('ZZD_MAT' , MODEL_FIELD_INIT,{||SRA->RA_MAT} )

		//Bloquear/liberar os campos para edição
		oStruZZD:SetProperty('ZZD_MAT' , MODEL_FIELD_WHEN,{|| .F. })

	Endif

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Cadastro de Funcionarios x Cursos' )

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'ZZDMASTER' ):SetDescription( 'Cadastro de Funcionarios x Cursos' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Cadastro de Funcionarios x Cursos - Interface com usuário
@author luciano.camargo
@since 17/05/2018
@version undefined
@type function
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'FUNXCUR' )
	// Cria a estrutura a ser usada na View
	Local oStruZZD := FWFormStruct( 2, 'ZZD', /*bAvalCampo*/)
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_ZZD', oStruZZD, 'ZZDMASTER' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR' , 100 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_ZZD', 'SUPERIOR' )

	// Liga a identificacao do componente
	//oView:EnableTitleView('VIEW_U01','Cursos')

	//Indica se a janela deve ser fechada ao final da operação. Se ele retornar .T. (verdadeiro) fecha a janela
	oView:bCloseOnOK := {|| .T.}

Return oView
