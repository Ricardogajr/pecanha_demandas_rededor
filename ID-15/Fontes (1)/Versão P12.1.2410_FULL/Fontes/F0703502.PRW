#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*{Protheus.doc} F0703502
Consulta de consignado
@author Alex Sandro Valario
@since 07/03/2017
@version 1.0
@Project MAN0000007423041_EF_035
@Menu Consulta Consignado
@return
*/

User Function F0703502()
	Local oBrowse := FWMBrowse():New()
	Private l240 := .f.	
	Private dDtIni:= ctod('')
	Private dDtFim:= ctod('')
	
	oBrowse:SetAlias('P18')
	oBrowse:SetDescription('Saldo Consignado Especifico') // TESTE
	oBrowse:Activate()
Return

Static Function MenuDef()
	Local aRot := {}
	//ADD OPTION aRot TITLE 'Movimentos' ACTION 'U_F070350X()'  OPERATION 1   ACCESS 0 //OPERATION X
	aRot:={{"Movimentos"				,'U_F070350X()'						,0,1}}
Return aRot

/*{Protheus.doc} F070350X

@author Alex Sandro Valario
@since 07/03/2017
@version 1.0
@Project MAN0000007423041_EF_035
@Menu Consulta Consignado
@return
*/
User Function F070350X()
	Carrega()
	FWExecView('Movimentos periodo de ' + dtoc(dDtIni) + ' até ' + dtoc(dDtFim),'F0703502', 1 /*MODEL_OPERATION_INSERT*/, , { || .T. } )
Return

Static Function ModelDef()
	Local oModel 		:= Nil
	Local oStPai 		:= FWFormStruct(1, 'P18')
	Local oStFilho 		:= FWFormStruct(1, 'SD3')
	Local aSD3Rel		:= {}

	oStFilho:AddField( ;                      // Ord. Tipo Desc.
					AllTrim( 'Tipo' )           	, ;      // [01]  C   Titulo do campo
					AllTrim( 'Tipo' )    		 	, ;      // [02]  C   ToolTip do campo
					'D3_DESCTP'                     , ;      // [03]  C   Id do Field
					'C'                             , ;      // [04]  C   Tipo do campo
					10                              , ;      // [05]  N   Tamanho do campo
					0                               , ;      // [06]  N   Decimal do campo
					NIL								, ;    // [07]  B   Code-block de validação do campo
					NIL                             , ;      // [08]  B   Code-block de validação Whe	n do campo
					NIL                				, ;      // [09]  A   Lista de valores permitido do campo
					.T.                             , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
					FwBuildFeature( STRUCT_FEATURE_INIPAD, "If(D3_TM<'500','Entrada','Saida')" )    , ;      // [11]  B   Code-block de inicializacao do campo
					NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
					NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.                              )        // [14]  L   Indica se o campo é virtual

	


	//Criando o modelo e os relacionamentos
	oModel := MPFormModel():New('MF0703502')
	oModel:AddFields('P18MASTER',/*cOwner*/,oStPai)
	oModel:AddGrid('SD3DETAIL','P18MASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
	
	//Fazendo o relacionamento entre o Pai e Filho
	AAdd(aSD3Rel, {'D3_FILIAL'	,	'P18_FILIAL'} )
	AAdd(aSD3Rel, {'D3_COD'		,	'P18_COD'	} ) 
	AAdd(aSD3Rel, {'D3_LOCAL'	,	'P18_LOCAL'	} ) 
	AAdd(aSD3Rel, {'D3_XFORN'	,	'P18_FORN'	} ) 
	AAdd(aSD3Rel, {'D3_XLJFOR'	,	'P18_LOJA'	} ) 
		
	oModel:SetRelation('SD3DETAIL', aSD3Rel, SD3->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
	oModel:GetModel('SD3DETAIL'):SetUniqueLine({"D3_FILIAL","D3_COD"})	//Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:GetModel('SD3DETAIL'):SetLoadFilter({ { 'D3_EMISSAO',"CTOD('" + Dtoc(dDtIni) + "')", MVC_LOADFILTER_GREATER_EQUAL },;
												 { 'D3_EMISSAO',"CTOD('" + Dtoc(dDtFim) + "')", MVC_LOADFILTER_LESS_EQUAL } } )


	oModel:SetPrimaryKey({})
	
	//Setando as descrições
	oModel:SetDescription("Consignado")
	oModel:GetModel('P18MASTER'):SetDescription('Modelo consignado')
    oModel:GetModel('P18MASTER'):SetOnlyView()
	oModel:GetModel('SD3DETAIL'):SetDescription('Modelo Movimentos de Estoque')
    
Return oModel

Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= FWLoadModel('F0703502')
	Local oStPai	:= FWFormStruct(2, 'P18', { |x| ALLTRIM(x) $ 'P18_COD, P18_DESCRI, P18_LOCAL, P18_FORN, P18_LOJA, P18_NOMFOR' })
	Local oStFilho	:= FWFormStruct(2, 'SD3', { |x| ALLTRIM(x) $ 'D3_EMISSAO, D3_TM, D3_QUANT, D3_CUSTO1, D3_XSETOR, D3_ESTORNO'})

	oStFilho:AddField( ;                        // Ord. Tipo Desc.
						'D3_DESCTP'                       , ;      	// [01]  C   Nome do Campo
						'01'                           	  , ;      // [02]  C   Ordem
						AllTrim( 'Tipo'    )          , ;      		// [03]  C   Titulo do campo
						AllTrim( 'Tipo' )       , ;     			 // [04]  C   Descricao do campo
						{ 'Tipo do movimento entrada ou saida' } , ;      // [05]  A   Array com Help
						'C'                                , ;      // [06]  C   Tipo do campo
						'@!'                               , ;      // [07]  C   Picture
						NIL                                , ;      // [08]  B   Bloco de Picture Var
						''                                 , ;      // [09]  C   Consulta F3
						.f.                                , ;      // [10]  L   Indica se o campo é alteravel
						NIL                                , ;      // [11]  C   Pasta do campo
						NIL                                , ;      // [12]  C   Agrupamento do campo
						NIL 			                   , ;      // [13]  A   Lista de valores permitido do campo (Combo) /*{'1=Sim','2=Nao'}*/
						NIL                                , ;      // [14]  N   Tamanho maximo da maior opção do combo
						NIL                                , ;      // [15]  C   Inicializador de Browse
						.T.                                , ;      // [16]  L   Indica se o campo é virtual
						NIL                                , ;      // [17]  C   Picture Variavel
						NIL                                )        // [18]  L   Indica pulo de linha após o campo
	
	
	
	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField('VIEW_P18',oStPai,'P18MASTER')
	oView:AddGrid('VIEW_SD3',oStFilho,'SD3DETAIL')
	
	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',20)
	oView:CreateHorizontalBox('GRID',80)
	
	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_P18','CABEC')
	oView:SetOwnerView('VIEW_SD3','GRID')
	
	//Habilitando título
	oView:EnableTitleView('VIEW_P18','Consignado')
	oView:EnableTitleView('VIEW_SD3','Movimentos de Estoque')
	
Return oView

Static Function Carrega()
	Local aPergs   := {}
	Local dData1   := ctod('')
	Local dData2   := date()
	Local aRet     := {}

	AAdd( aPergs ,{1,"Data de  " ,dData1       ,"@E",'.T.',,'.T.',50,.f.})
	AAdd( aPergs ,{1,"Data até " ,dData2       ,"@E",'.T.',,'.T.',50,.T.})

	If ! ParamBox(aPergs ,"Parametros para seleção dos movimentos",aRet,,,,,,,,.f.)      
		dDtini := dData1
		dDtfim := dData2
		Return .t.
	EndIf
	dDtini := aRet[1]
	dDtfim := aRet[2]
Return .t.
 
