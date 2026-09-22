#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
  
/*
{Protheus.doc} ModelDef
Funcao generica MVC do model para a
Tela de Visualização dos Logs da Medição de Contrato

@Author		Mick William
@Since 		06/07/2016
@Version	P12.7
@Project    MAN00000462901_EF_001
@Return 	oModel - Objeto do Modelo MVC
*/
 
Static Function ModelDef()

	Local oStruP07 	:= Nil
	Local oStruPG1 	:= Nil
	Local oStruSC1 	:= Nil
	Local oStruPG3 	:= Nil
	Local oStruCNA 	:= Nil
	Local oModel   	:= MpFormModel():New( "M0100107")
	Local cCmpFil	:= ''	
		
	//cCmpFil  := "P07_FILIAL|"
	//oStruP07 := FwFormStruct( 1, "P07", { |x| AllTrim( x ) + "|" $ cCmpFil } ) //Field
	oStruP07 := FwFormStruct( 1 , "P07" ) //Field
	
	//Logs Gerados
	cCmpFil  := "P07_FILIAL|P07_COD|P07_SOLCO|P07_DTMED|P07_MOTSOL|P07_ITEMSC"
	oStruPG1 := FwFormStruct( 1, "P07", { |x| AllTrim( x ) + "|" $ cCmpFil } ) 

	//Itens da Solicitação
	cCmpFil	 := "P07_FILIAL|P07_COD|P07_SOLCO|P07_CONTR|P07_ITEMSC|ZCOD_ITEM|ZDES_ITEM|ZQTD_ITEM|ZC1_FORNEC|P07_CONTR|"
	oStruSC1 := FwFormStruct( 1, "P07", { |x| AllTrim( x ) + "|" $ cCmpFil } ) 
	oStruSC1:AddField( 																			  ; 	// Ord. Tipo Desc.
						AllTrim( 'Código' ) 													, ; 	// [01] C Titulo do campo
						AllTrim( 'Código' ) 													, ; 	// [02] C ToolTip do campo
						'ZCOD_ITEM' 															, ; 	// [03] C identificador (ID) do Field
						'C' 																	, ; 	// [04] C Tipo do campo
						TamSX3("C1_PRODUTO")[1] 												, ; 	// [05] N Tamanho do campo
						0 																		, ; 	// [06] N Decimal do campo
						Nil																		, ; 	// [07] B Code-block de validação do campo
						NIL 																	, ; 	// [08] B Code-block de validação When docampo
						Nil																		, ; 	// [09] A Lista de valores permitido docampo
						NIL 																	, ; 	// [10] L Indica se o campo tem preenchimento obrigatório
						{ || POSICIONE("SC1", 1, P07->P07_FILIAL + P07->P07_SOLCO, "C1_PRODUTO") } , ;	// [11] B Code-block de inicializacao do campo
						NIL 																	, ; 	// [12] L Indica se trata de um campo chave
						NIL 																	, ; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
						.T. ) 																			// [14] L Indica se o campo é virtual			
	oStruSC1:AddField(																			  ; 	// Ord. Tipo Desc.
						AllTrim( 'Desc.Item' ) 													, ; 	// [01] C Titulo do campo
						AllTrim( 'Descrição do Item' ) 											, ; 	// [02] C ToolTip do campo
						'ZDES_ITEM' 															, ; 	// [03] C identificador (ID) do Field
						'C' 																	, ; 	// [04] C Tipo do campo
						TamSX3("C1_DESCRI")[1] 													, ; 	// [05] N Tamanho do campo
						0 																		, ; 	// [06] N Decimal do campo
						Nil																		, ; 	// [07] B Code-block de validação do campo
						NIL 																	, ; 	// [08] B Code-block de validação When docampo
						Nil																		, ; 	// [09] A Lista de valores permitido docampo
						NIL 																	, ; 	// [10] L Indica se o campo tem preenchimento obrigatório
						{ || IIF ( !Empty(POSICIONE("SC1", 1, P07->P07_FILIAL + P07->P07_SOLCO, "C1_DESCRI")), POSICIONE("SC1", 1, P07->P07_FILIAL + P07->P07_SOLCO, "C1_DESCRI"), "Solicitação Não Encontrada") } , ; // [11] B Code-block de inicializacao do campo
						NIL 																	, ; 	// [12] L Indica se trata de um campo chave
						NIL 																	, ; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
						.T. )																			// [14] L Indica se o campo é virtual
						
	oStruSC1:AddField( 																			; 	// Ord. Tipo Desc.
						AllTrim( 'Quantidade' ) 												, ; // [01] C Titulo do campo
						AllTrim( 'Quantidade' ) 												, ; // [02] C ToolTip do campo
						'ZQTD_ITEM' 															, ; // [03] C identificador (ID) do Field
						'C' 																	, ; // [04] C Tipo do campo
						TamSX3("C1_QUANT")[1] 													, ; // [05] N Tamanho do campo
						0 																		, ; // [06] N Decimal do campo
						Nil																		, ; // [07] B Code-block de validação do campo
						NIL 																	, ; // [08] B Code-block de validação When docampo
						Nil																		, ; // [09] A Lista de valores permitido docampo
						NIL 																	, ; // [10] L Indica se o campo tem preenchimento obrigatório
						{ || POSICIONE("SC1", 1, P07->P07_FILIAL + P07->P07_SOLCO, "C1_QUANT") }, ; // [11] B Code-block de inicializacao do campo
						NIL 																	, ; // [12] L Indica se trata de um campo chave
						NIL 																	, ; // [13] L Indica se o campo pode receber valor em uma operação de update.
						.T. )																		// [14] L Indica se o campo é virtual		

	oStruSC1:AddField( 																			; // Ord. Tipo Desc.
						AllTrim( 'Fornecedor' ) 												, ; // [01] C Titulo do campo
						AllTrim( 'Fornecedor' ) 												, ; // [02] C ToolTip do campo
						'ZC1_FORNEC' 															, ; // [03] C identificador (ID) do Field
						'C' 																	, ; // [04] C Tipo do campo
						TamSX3("C1_FORNECE")[1] 												, ; // [05] N Tamanho do campo
						0 																		, ; // [06] N Decimal do campo
						Nil																		, ; // [07] B Code-block de validação do campo
						NIL 																	, ; // [08] B Code-block de validação When docampo
						Nil																		, ; // [09] A Lista de valores permitido docampo
						NIL 																	, ; // [10] L Indica se o campo tem preenchimento obrigatório
						{ || POSICIONE("SC1", 1, P07->P07_FILIAL + P07->P07_SOLCO, "C1_FORNECE") } , ; // [11] B Code-block de inicializacao do campo
						NIL 																	, ; // [12] L Indica se trata de um campo chave
						NIL 																	, ; // [13] L Indica se o campo pode receber valor em uma operação de update.
						.T. )																		// [14] L Indica se o campo é virtual	

	//Contratos Relacionados
	cCmpFil  := "P07_FILIAL|P07_COD|P07_SOLCO|P07_CONTR|P07_DTVIGI|P07_DTVIGF|"
	oStruPG3 := FwFormStruct( 1, "P07", { |x| AllTrim( x ) + "|" $ cCmpFil } ) 


	//Tabela de Preço Relacionados
	cCmpFil  := "CNA_FILIAL|CNA_CONTRA|CNA_XTABPC|CNA_FORNEC|CNA_LJFORN|ZCNA_DXTAP|"
	oStruCNA := FwFormStruct( 1, "CNA", { |x| AllTrim( x ) + "|" $ cCmpFil } ) 
	
	oStruCNA:AddField( 																		  ; // Ord. Tipo Desc.
					AllTrim( 'Descrição' ) 													, ; // [01] C Titulo do campo
					AllTrim( 'Descrição' ) 													, ; // [02] C ToolTip do campo
					'ZCNA_DXTAP' 															, ; // [03] C identificador (ID) do Field
					'C' 																	, ; // [04] C Tipo do campo
					TamSX3("AIA_DESCRI")[1] 												, ; // [05] N Tamanho do campo
					0 																		, ; // [06] N Decimal do campo
					Nil																		, ; // [07] B Code-block de validação do campo
					NIL 																	, ; // [08] B Code-block de validação When docampo
					Nil																		, ; // [09] A Lista de valores permitido docampo
					NIL 																	, ; // [10] L Indica se o campo tem preenchimento obrigatório
					{ || POSICIONE("AIA", 1, xFilial("AIA") + CNA->CNA_FORNEC + CNA->CNA_LJFORN  + CNA->CNA_XTABPC, "AIA_DESCRI") } , ; // [11] B Code-block de inicializacao do campo
					NIL 																	, ; // [12] L Indica se trata de um campo chave
					NIL 																	, ; // [13] L Indica se o campo pode receber valor em uma operação de update.
					.T. ) 																	// [14] L Indica se o campo é virtual		

	oModel:AddFields( "MODEL_P07", /*cOwner*/, oStruP07 ) // Cabeçalho 

	oModel:AddGrid("MODEL_PG1", "MODEL_P07", oStruPG1) // Logs Gerados
	oModel:GetModel( "MODEL_PG1" ):SetOptional(.T.)
	
	oModel:AddGrid("MODEL_SC1", "MODEL_PG1", oStruSC1) // Itens da Solicitação (Campos criados manualmente)
	oModel:GetModel( "MODEL_SC1" ):SetOptional(.T.)

	oModel:AddGrid("MODEL_PG3", "MODEL_SC1", oStruPG3) // Contratos relacionados
	oModel:GetModel( "MODEL_PG3" ):SetOptional(.T.)
	
	oModel:AddGrid("MODEL_CNA", "MODEL_PG3", oStruCNA) // Tabela de Preços Relacionadas
	oModel:GetModel( "MODEL_CNA" ):SetOptional(.T.)

	oModel:SetRelation( "MODEL_PG1", {{ "P07_FILIAL", "P07_FILIAL" }, { "P07_SOLCO", "P07_SOLCO" } }, P07->(IndexKey(5)) )
	
	oModel:SetRelation( "MODEL_SC1", {{ "P07_FILIAL", "P07_FILIAL" }, { "P07_SOLCO", "P07_SOLCO" } }, P07->(IndexKey(5)) )

	oModel:SetRelation( "MODEL_PG3", {{ "P07_FILIAL", "P07_FILIAL" }, {"P07_COD", "P07_COD"}, { "P07_SOLCO", "P07_SOLCO" }, { "P07_CONTR", "P07_CONTR" }}, P07->(IndexKey(5)) )
	
	oModel:SetRelation( "MODEL_CNA", {{ "CNA_FILIAL", "P07_FILIAL" }, { "CNA_CONTRA", "P07_CONTR" } }, CNA->(IndexKey(1)) )

	oModel:GetModel( "MODEL_P07" ):SetPrimaryKey( { "P07_FILIAL" } )

Return( oModel )

/*{Protheus.doc} ViewDef
Funcao generica MVC do View para a
Tela de Visualização dos Logs da Medição de Contrato

@Author 	Mick William
@Since 		06/07/2016
@Version	P12.7
@Return 	oView - Objeto da View MVC
*/

Static Function ViewDef()

	Local oModel    := FWLoadModel("F0100107")
	Local oStruP07	:= Nil
	Local oStruPG1	:= Nil
	Local oStruSC1	:= Nil
	Local oStruPG3	:= Nil
	Local oStruCNA	:= Nil
	Local oView    	:= FWFormView():New()
	Local cCmpFil   := ""
	
	oView:SetModel(oModel)

	/*cCmpFil  := "P07_FILIAL|"
	oStruP07 := FwFormStruct( 2, "P07", { |x| AllTrim( x ) + "|" $ cCmpFil } ) //Field
	*/
	oStruP07 := FwFormStruct( 2, "P07" ) //Field
	
	cCmpFil  := "P07_COD|P07_DTMED|P07_MOTSOL|"
	oStruPG1 := FwFormStruct( 2, "P07", { |x| AllTrim( x ) + "|" $ cCmpFil } ) //Logs Gerados

	cCmpFil		:= "ZCOD_ITEM|ZDES_ITEM|ZQTD_ITEM|"
	oStruSC1	:= FwFormStruct( 2, "P07", { |x| AllTrim( x ) + "|" $ cCmpFil } ) //Itens da Solicitação

	oStruSC1:AddField( 								  ; // Ord. Tipo Desc.
					'ZCOD_ITEM' 					, ; // [01] C Nome do Campo
					'50' 							, ; // [02] C Ordem
					AllTrim( 'Código' ) 			, ; // [03] C Titulo do campo
					AllTrim( 'Código do Item' ) 	, ; // [04] C Descrição do campo
					{ 'Código do Item' } 			, ; // [05] A Array com Help
					'C' 							, ; // [06] C Tipo do campo
					'@!' 							, ; // [07] C Picture
					NIL 							, ; // [08] B Bloco de Picture Var
					'' 								, ; // [09] C Consulta F3
					.T. 							, ; // [10] L Indica se o campo é evitável
					NIL 							, ; // [11] C Pasta do campo
					NIL 							, ; // [12] C Agrupamento do campo
					Nil 							, ; // [13] A Lista de valores permitido do campo (Combo)
					NIL 							, ; // [14] N Tamanho Maximo da maior opção do combo
					NIL 							, ; // [15] C Inicializador de Browse
					.T. 							, ; // [16] L Indica se o campo é virtual
					NIL ) 								// [17] C Picture Variável
	
	oStruSC1:AddField( 								  ; // Ord. Tipo Desc.
					'ZDES_ITEM' 					, ; // [01] C Nome do Campo
					'51' 							, ; // [02] C Ordem
					AllTrim( 'Descrição do Item' ) 			, ; // [03] C Titulo do campo
					AllTrim( 'Descrição do Item' ) 			, ; // [04] C Descrição do campo
					{ 'Descrição do Item' } 				, ; // [05] A Array com Help
					'C' 							, ; // [06] C Tipo do campo
					'@!'							, ; // [07] C Picture
					NIL 							, ; // [08] B Bloco de Picture Var
					'' 								, ; // [09] C Consulta F3
					.T. 							, ; // [10] L Indica se o campo é evitável
					NIL 							, ; // [11] C Pasta do campo
					NIL 							, ; // [12] C Agrupamento do campo
					Nil 							, ; // [13] A Lista de valores permitido do campo (Combo)
					NIL 							, ; // [14] N Tamanho Maximo da maior opção do combo
					NIL 							, ; // [15] C Inicializador de Browse
					.T. 							, ; // [16] L Indica se o campo é virtual
					NIL ) 								// [17] C Picture Variável
	
	oStruSC1:AddField( 								  ; // Ord. Tipo Desc.
					'ZQTD_ITEM'	 					, ; // [01] C Nome do Campo
					'52' 							, ; // [02] C Ordem
					AllTrim( 'Quantidade' ) 		, ; // [03] C Titulo do campo
					AllTrim( 'Quantidade' ) 		, ; // [04] C Descrição do campo
					{ 'Quantidade' } 				, ; // [05] A Array com Help
					'C' 							, ; // [06] C Tipo do campo
					'@!' 							, ; // [07] C Picture
					NIL 							, ; // [08] B Bloco de Picture Var
					'' 								, ; // [09] C Consulta F3
					.T. 							, ; // [10] L Indica se o campo é evitável
					NIL 							, ; // [11] C Pasta do campo
					NIL 							, ; // [12] C Agrupamento do campo
					Nil 							, ; // [13] A Lista de valores permitido do campo (Combo)
					NIL 							, ; // [14] N Tamanho Maximo da maior opção do combo
					NIL 							, ; // [15] C Inicializador de Browse
					.T. 							, ; // [16] L Indica se o campo é virtual
					NIL ) 								// [17] C Picture Variável

	oStruSC1:AddField( 								  ; // Ord. Tipo Desc.
					'ZC1_FORNEC'	 				, ; // [01] C Nome do Campo
					'53' 							, ; // [02] C Ordem
					AllTrim( 'Fornecedor' ) 		, ; // [03] C Titulo do campo
					AllTrim( 'Fornecedor' ) 		, ; // [04] C Descrição do campo
					{ 'Fornecedor' } 				, ; // [05] A Array com Help
					'C' 							, ; // [06] C Tipo do campo
					'@!' 							, ; // [07] C Picture
					NIL 							, ; // [08] B Bloco de Picture Var
					'' 								, ; // [09] C Consulta F3
					.T. 							, ; // [10] L Indica se o campo é evitável
					NIL 							, ; // [11] C Pasta do campo
					NIL 							, ; // [12] C Agrupamento do campo
					Nil 							, ; // [13] A Lista de valores permitido do campo (Combo)
					NIL 							, ; // [14] N Tamanho Maximo da maior opção do combo
					NIL 							, ; // [15] C Inicializador de Browse
					.T. 							, ; // [16] L Indica se o campo é virtual
					NIL ) 								// [17] C Picture Variável

	cCmpFil  := "P07_CONTR|P07_DTVIGI|P07_DTVIGF|"
	oStruPG3 := FwFormStruct( 2, "P07", { |x| AllTrim( x ) + "|" $ cCmpFil } ) //Contratos Relacionados

	cCmpFil  := "CNA_XTABPC|ZCNA_DXTAP|"
	oStruCNA := FwFormStruct( 2, "CNA", { |x| AllTrim( x ) + "|" $ cCmpFil } ) //Tabela de Preço Relacionados

	oStruCNA:AddField( 								  ; // Ord. Tipo Desc.
					'ZCNA_DXTAP'	 				, ; // [01] C Nome do Campo
					'54' 							, ; // [02] C Ordem
					AllTrim( 'Descrição' ) 			, ; // [03] C Titulo do campo
					AllTrim( 'Descrição' ) 			, ; // [04] C Descrição do campo
					{ 'Descrição' } 				, ; // [05] A Array com Help
					'C' 							, ; // [06] C Tipo do campo
					'@!' 							, ; // [07] C Picture
					NIL 							, ; // [08] B Bloco de Picture Var
					'' 								, ; // [09] C Consulta F3
					.T. 							, ; // [10] L Indica se o campo é evitável
					NIL 							, ; // [11] C Pasta do campo
					NIL 							, ; // [12] C Agrupamento do campo
					Nil 							, ; // [13] A Lista de valores permitido do campo (Combo)
					NIL 							, ; // [14] N Tamanho Maximo da maior opção do combo
					NIL 							, ; // [15] C Inicializador de Browse
					.T. 							, ; // [16] L Indica se o campo é virtual
					NIL ) 								// [17] C Picture Variável


	oView:AddField( "VIEW_P07"	, oStruP07, "MODEL_P07"  )
	oView:AddGrid ( 'VIEW_PG1'	, oStruPG1, 'MODEL_PG1'  )
	
	oView:AddOtherObject('OTHER_PANEL1', {|oPanel| F001Pesq(oPanel, oView)})

	oView:AddGrid ( 'VIEW_SC1' 	, oStruSC1, 'MODEL_SC1'  )
	oView:AddGrid ( 'VIEW_PG3'	, oStruPG3, 'MODEL_PG3'  )
	oView:AddGrid ( 'VIEW_CNA'  , oStruCNA, 'MODEL_CNA'  )

	oView:CreateHorizontalBox( 'PAINEL_SUPERIOR', 8 )
	oView:CreateHorizontalBox( 'BOX_0', 1 )
	oView:CreateHorizontalBox( 'BOX_1', 32 )
	oView:CreateHorizontalBox( 'BOX_2', 20)
	oView:CreateHorizontalBox( 'BOX_3', 20 )
	oView:CreateHorizontalBox( 'BOX_4', 19 )

	oView:SetOwnerView( 'OTHER_PANEL1' , 'PAINEL_SUPERIOR')
	oView:SetOwnerView( 'VIEW_P07' , 'BOX_0'		  )
	oView:SetOwnerView( 'VIEW_PG1' , 'BOX_1'		  )
	oView:SetOwnerView( 'VIEW_SC1' , 'BOX_2' 		  )
	oView:SetOwnerView( 'VIEW_PG3' , 'BOX_3' 		  )
	oView:SetOwnerView( 'VIEW_CNA' , 'BOX_4' 		  )

	oView:EnableTitleView('VIEW_PG1', "Logs Gerados")
	oView:EnableTitleView('VIEW_SC1', "Itens da Solicitação")
	oView:EnableTitleView('VIEW_PG3', "Contratos Relacionados")
	oView:EnableTitleView('VIEW_CNA', "Tabelas de Preço Relacionadas")

	oView:SetViewProperty("VIEW_PG1", "GRIDFILTER", {.T.}) 
	 
Return( oView )


/*{Protheus.doc} F001Pesq()
Função que faz a busca das solicitações de Compras

@author		Mick William da Silva
@since		11/07/2016
@version 	P12.7
@Project    MAN00000462901_EF_001
@Param		oPanel, Recebe o Painel aonde deverá ser exibido, na Field nesse caso. 
@Param		oView , Recebe a View que está ativa.
*/

Static Function F001Pesq(oPanel, oView)
	
	Local oMdlFull  := oView:GetModel()
	Local oButton	  := Nil
	Local oFonte	  := Nil
	Local cCodSol	  := Space(6)
	
	DEFINE FONT oFonte NAME "Arial" BOLD
	
	@ 12, 05 Say 'Solicitação de Compras: ' SIZE 70, 10 Of oPanel Pixel FONT oFonte
	@ 10, 78 MsGet cCodSol  SIZE 50, 10 Of oPanel F3 'SC1' PIXEL WHEN .T.
	
		
	@ 010, 128 Button oButton Prompt 'Pesquisar' Of oPanel Size 060, 012 Pixel
	oButton:bAction := { || F001ExecPes(oMdlFull, M->cCodSol, oView) }
	
Return

/*{Protheus.doc} F001ExecPes()
Executa busca e posiciona na grid de acordo com os
parametros informados.


@author		Mick William da Silva
@since		11/07/2016
@version 	P12.7
@Project    MAN00000462901_EF_001
@Param		oMdlFull, Recebe a Model Ativa.
@Param		cCodSol, Recebe o Código da Solicitação de Compras.
@Param		oView, Recebe a View Ativa.
*/

Static Function F001ExecPes(oMdlFull, cCodSol, oView)
	
Local oModel := oMdlFull:GetModel('MODEL_PG1')
Local nX	 := 0
Local nLinha := 0

SC1->(DbSetOrder(01))

If !SC1->(DbSeek(xFilial('SC1') + cCodSol)) 
	Help( , , 'Help', 'F0100107', 'O Código informado não existe.', 1, 0 )
//Else
//	oView:Deactivate()
//	oMdlFull:SetOperation(4)
//	oView:Activate()
EndIf

//If oModel:SeekLine({{ "P07_SOLCO", cCodSol }})
//	oView:Refresh("VIEW_PG1")
//Else
//	Help( , , 'Help', "F0100107", "O Código informado não existe.", 1, 0 )
//EndIf
	
Return()