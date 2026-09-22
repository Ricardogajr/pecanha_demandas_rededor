#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TBICONN.CH'
#INCLUDE 'FWMVCDEF.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMPPV ºAutor  ³Hildepablo Belarmino     º Data ³  01/31/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comando G8                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION FGRPATV()

	Local oBrowse := FwLoadBrw("FGRPATV")
	Private cCadastro := "Amarração Produto x Grupo Ativo"

	oBrowse:Activate()
Return (NIL)

// BROWSEDEF() SERÁ ÚTIL PARA FUTURAS HERANÇAS: FWLOADBRW()
Static Function BrowseDef()
	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias("ZNG")
	oBrowse:SetDescription("Amarração Produto x Grupo Ativo")

	//oBrowse:AddLegend( "EMPTY(Z8_ULTCALC)" , "GREEN"     , "Periodo não calculado"      )
	//oBrowse:AddLegend( "!EMPTY(Z8_ULTCALC)", "RED"  	 , "Periodo calculado"  )
	//oBrowse:AddLegend( "Z8_ATIVO =='S'", "GREEN"   , "Unidade Ativa"  )

	// DEFINE DE ONDE SERÁ RETIRADO O MENUDEF
	oBrowse:SetMenuDef("FGRPATV")
Return (oBrowse)

// OPERAÇÕES DA ROTINA
Static Function MenuDef()
	// FUNÇÃO PARA CRIAR MENUDEF
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
	AAdd(aRotina,{"&Incluir"	, "VIEWDEF.FGRPATV"    , 0, 3 } )
	AAdd(aRotina,{"&Visualizar"	, "VIEWDEF.FGRPATV"    , 0, 2 } )
	AAdd(aRotina,{"&Alterar"	, "VIEWDEF.FGRPATV"    , 0, 4 } )
	AAdd(aRotina,{"&Excluir"	, "VIEWDEF.FGRPATV"    , 0, 5 } )

	// ADD OPTION aRotina TITLE '&Incluir'    		ACTION 'VIEWDEF.FGRPATV' 	OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	// ADD OPTION aRotina TITLE '&Visualizar' 		ACTION 'VIEWDEF.FGRPATV' 	OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	// ADD OPTION aRotina TITLE '&Alterar'    		ACTION 'VIEWDEF.FGRPATV' 	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	// ADD OPTION aRotina TITLE '&Excluir'    		ACTION 'VIEWDEF.FGRPATV' 	OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5 

	//ADD OPTION aRotina Title 'Visualizar'  			Action 'AxVisual'  		   OPERATION 2 ACCESS 0
	//ADD OPTION aRotina Title 'Pesquisar'  			Action VIEWDEF'AxPesqui'  		   OPERATION 1 ACCESS 0
	//ADD OPTION aRotina Title 'Pesquisar'  			Action VIEWDEF'AxPesqui'  		   OPERATION 1 ACCESS 0
	//ADD OPTION aRotina Title 'Visualizar'  			Action 'AxVisual'  		   OPERATION 2 ACCESS 0
	//ADD OPTION aRotina TITLE '&Incluir'   			ACTION 'AxInclui' 		   OPERATION 3 ACCESS 0
	//ADD OPTION aRotina TITLE '&Alterar'   			ACTION 'AxAltera'  		   OPERATION 4 ACCESS 0
	//ADD OPTION aRotina TITLE '&Deletar'    			ACTION 'AxDeleta'  		   OPERATION 5 ACCESS 0
	//ADD OPTION aRotina Title 'Calcular Rateio' 		Action 'VIEWDEF.FGRPATV'  OPERATION 8 ACCESS 0
	//ADD OPTION aRotina Title 'Gerar Financeiro'		Action 'VIEWDEF.FGRPATV'  OPERATION 5 ACCESS 0
	//ADD OPTION aRotina Title 'Conhecimento'    		Action 'MsDocument' 	   OPERATION 4 ACCESS 0
Return (aRotina)

// REGRAS DE NEGÓCIO
Static Function ModelDef()
 	//Local bVldPre := {|| u_zM1bPre()} //Antes de abrir a Tela
    //Local bVldPos := {|| u_zM1bPos()} //Validação ao clicar no Confirmar
    //Local bVldCon := {|| u_ZNGCOB()} //Função chamadao ao confirmar
    //Local bVldCan := {|| u_zM1bCan()} //Função chamadao ao cancelar
	// INSTANCIA OS SUBMODELOS
	Local oStruZNG := FwFormStruct(1, "ZNG")
	// INSTANCIA O MODELO
	Local oModel := MPFormModel():New("FGRPATVM", /*bVldPre - PreValidacao*/, /*{ |oModel| U_CHECADUPL(oModel,"ZNG") } */, /*bVldCom - Confirmar*/, /*bVldCan - Cancelar*/)  
	//Local bVldPre := {|| u_zM1bPre()}
	// DEFINE SE OS SUBMODELOS SERÃO FIELD OU GRID
	oModel:AddFields("ZNGMASTER", NIL, oStruZNG)
	//oModel:AddFields("SZ1MASTER", NIL, oStruSZ1)
	//oStruZNG:SetProperty('Z8_CODIGO',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	//oStruZNG:SetProperty('Z8_CODIGO',   MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'SZ0->Z0-CODIGO'))         				//Ini Padrão
	//oModel:SetProperty('ZZ1_DESC',  MODEL_FIELD_OBRIGAT, Iif(RetCodUsr()!='000000', .T., .F.) )                                         	//Campo Obrigatório

	// DESCRIÇÃO DO MODELO
	oModel:SetDescription("Amarração Produto x Grupo Ativo" )

	// DESCRIÇÃO DOS SUBMODELOS
	oModel:GetModel("ZNGMASTER"):SetDescription("Amarração Produto x Grupo Ativo")

	// DEFINE A RELAÇÃO ENTRE OS SUBMODELOS
	//oModel:SetRelation("ZNGMASTER", {{"Z8_FILIAL", "FwXFilial('SZ0')"}, {"Z8_CODIGO", "Z0_CODIGO"}}, ZNG->(IndexKey( 1 )))
	//oModel:GetModel('SZ5DETAIL'):SetLoadFilter(, "Z5_CODIGO = '" + ZNG->Z8_CODIGO + "'" )
 
	//oModel:GetModel('ZV0MASTER'):SetDescription('Subcategorias de Lente')
	//FNG_FILIAL+ZNG_PRODUT+ZNG_GRUPOP                                                                                                                                
	oModel:SetPrimaryKey( { "ZNG", "ZNG_FILIAL","ZNG_PRODUT","ZNG_GRUPOP" } )
Return (oModel)

// INTERFACE GRÁFICA
Static Function ViewDef()
	// INSTANCIA A VIEW
	Local oView := Nil
	Local oModel := FwLoadModel("FGRPATV")

	// INSTANCIA AS SUBVIEWS
	Local oStruZNG := FwFormStruct(2, "ZNG")


	// RECEBE O MODELO DE DADOS
	oView := FWFormView():New()

	// INDICA O MODELO DA VIEW
	oView:SetModel(oModel)

	// CRIA ESTRUTURA VISUAL DE CAMPOS
	oView:AddField("VIEW_ZNG", oStruZNG, "ZNGMASTER")


	//oStruSZ1:RemoveField( 'SZ1_STATUS' )
	//oStruSZ3:RemoveField( 'SZ3_STATUS' )

	// CRIA BOXES HORIZONTAIS
	oView:CreateHorizontalBox("MASTER"  , 100)
	

	// RELACIONA OS BOXES COM AS ESTRUTURAS VISUAIS
	oView:SetOwnerView("VIEW_ZNG", "MASTER")


	// DEFINE AUTO-INCREMENTO AO CAMPO
	// oView:AddIncrementField("VIEW_SZ3", "SZ3_ITEM")

	// DEFINE OS TÍTULOS DAS SUBVIEWS
	oView:EnableTitleView("VIEW_ZNG","Amarração Produto x Grupo Ativo")


	//oView:SetViewProperty('VIEW_ZNG', "GRIDFILTER", {.T.})
	//oView:SetViewProperty("VIEW_ZNG", "GRIDSEEK", {.T.})
	//oView:SetViewProperty("VIEW_ZNG", "GRIDVSCROLL", {.T.})
	oView:lModify := .T.

	oView:SetCloseOnOk({||.T.})

Return (oView)

Static Function CreateTrigger()
Local aAux :=   FwStruTrigger(;
      "XZ1_SOURCE" ,; // Campo Dominio
      "XZ1_SOURCE" ,; // Campo de Contradominio
      "CFG600G01('XZ1_SOURCE',M->XZ1_SOURCE)",; // Regra de Preenchimento
      .F. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "" ,; // Alias da tabela a ser posicionada
      0 ,; // Ordem da tabela a ser posicionada
      "" ,; // Chave de busca da tabela a ser posicionada
      NIL ,; // Condicao para execucao do gatilho
      "01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   
Return aAux



User Function CHECADUPL(oModel, cALias)
Local lRet := .T.
Local aChaveUnq := {}
Local nOrder := 0
Local cChaveUnq := ""
Local aAreaSZX := (cALias)->(FWGetArea())
Local aArea 	:= FWGetArea()
Local lGrid 	:= Iif(cAlias $ 'SZ5|SZ7|SZ9', .T., .F.)
Local lAmarr 	:= Iif(cAlias $ 'ZNG|SZ3', .T., .F.)


If Inclui .or. lGrid
	//alias , indice, ordem
	aAdd(aChaveUnq,{"ZNG", "ZNG_FILIAL+ZNG_GRUPOP"						,2 	} )//ok
	//aAdd(aChaveUnq,{"SZ3", "Z3_FILIAL+Z3_CODIGO+M->Z3_CODUNI"						,2 	} )//ok
	
	
	nSeek := Ascan( aChaveUnq , {|X| x[1]  = cALias  } )
	
	If nSeek > 0 
		cChaveUnq := aChaveUnq[nSeek][2]
		nOrder :=  aChaveUnq[nSeek][3]

		dbSelectArea(cALias)
		(cALias)->(dbSetOrder(nOrder))

		lRet := !(cALias)->(dbSeek(M->(&cChaveUnq)))
		
		If !lRet 
			//oModel:
			If lGrid
				oModel:GetModel():SetErrorMessage(,,,, "Chave Duplicada ", 'Os dados não podem ser utilizados, chave duplicada para a tabela! Filial+Produto+Grupo Produto', 'Por favor revise o cadastro') 
			Else 
				oModel:SetErrorMessage(,,,, "Chave Duplicada ", 'Os dados não podem ser utilizados, chave duplicada para a tabela!', 'Por favor revise o cadastro')      
			EndIf 
		EndIf 
	
		nOrder :=  1
		(cALias)->(dbSetOrder(nOrder))

		FWRestArea(aAreaSZX)
    	FWRestArea(aArea)
	EndIf 
EndIf 

Return lRet
