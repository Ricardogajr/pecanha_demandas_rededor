#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#DEFINE cTitulo "Grupos de Filiais"
/*/{Protheus.doc} SUPRIM00
	Grupos de Filiais
	@type Function - User function
	@author Cleiton Genuino
	@since 12/05/2023
	@version 1.0
	@example
	u_SUPRIM00()
/*/
User Function SUPRIM00()
	Local aArea   := FWGetArea()
	Local oBrowse
	Local cFunBkp := FunName()

	SetFunName("SUPRIM00")

	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("P42")

	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

    //Legendas1
    oBrowse:AddLegend( "P42->P42_ATIVO == 'S'", "GREEN","S = Grupo de filiais Ativo "   ,"1")
    oBrowse:AddLegend( "P42->P42_ATIVO == 'N'", "RED"  ,"N = Grupo de filiais Inativo"  ,"1")

	//Ativa a Browse
	oBrowse:Activate()

	SetFunName(cFunBkp)
	RestArea(aArea)
Return
/*/{Protheus.doc} MenuDef
	
	Criação do menu MVC
	
	@type Function - Static function
	@author Cleiton Genuino
	@since 12/05/2023
	@version 1.0
/*/
Static Function MenuDef()
	Local aRot := {}

	//Adicionando opções
	aadd(aRot,{"Visualizar","VIEWDEF.SUPRIM00",0,2})  //ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.SUPRIM00' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	aadd(aRot,{"Incluir","VIEWDEF.SUPRIM00",0,3})  //ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.SUPRIM00' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	aadd(aRot,{"Alterar","VIEWDEF.SUPRIM00",0,4})  //ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.SUPRIM00' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	aadd(aRot,{"Excluir","VIEWDEF.SUPRIM00",0,5})  //ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.SUPRIM00' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot
/*/{Protheus.doc} ModelDef
	Criação do modelo de dados MVC
	@type Function - Static function
	@author Cleiton Genuino
	@since 12/05/2023
	@version 1.0
/*/
Static Function ModelDef()
	Local bP42VldPos := {|| P42Pos()} //Validação ao clicar no Confirmar
	//Criação do objeto do modelo de dados
	Local oModel := Nil

	//Criação da estrutura de dados utilizada na interface
	Local oStP42 := FWFormStruct(1,"P42")

	//Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("MSUPRIM00",/*bPre*/, bP42VldPos/*bPos*/,/*bCommit*/,/*bCancel*/)

	//Atribuindo formulários para o modelo
	oModel:AddFields("MD_P42MASTER",/*cOwner*/,oStP42)

	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({'P42_FILIAL','P42_GRUPO'})

	//Adicionando descrição ao modelo
	oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)

	//Setando a descrição do formulário
	oModel:GetModel("MD_P42MASTER"):SetDescription("Formulário do Cadastro "+cTitulo)

	
Return oModel
/*/{Protheus.doc} ViewDef
	Criação da visão MVC
	@type Function - Static function
	@author Cleiton Genuino
	@since 12/05/2023
	@version 1.0
/*/
Static Function ViewDef()

	//Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
	Local oModel := FWLoadModel("SUPRIM00")

	//Criação da estrutura de dados utilizada na interface do cadastro de Autor
	Local oStP42 := FWFormStruct(2, "P42")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SP42_NOME|SP42_DTAFAL|'}

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Atribuindo formulários para interface
	oView:AddField("VIEW_P42", oStP42, "MD_P42MASTER")

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)

	//Colocando título do formulário
	oView:EnableTitleView('VIEW_P42', 'Dados - ' + cTitulo )

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_P42","TELA")

Return oView
/*/{Protheus.doc} P42Pos
	Função chamada após validar o ok da rotina para os dados serem salvos
	@type Function - Static function
	@author Cleiton Genuino
	@since 12/05/2023
	@version 1.0
/*/
Static Function P42Pos()
	Local oModel := FWModelActive()
	Local oModelPad  := oModel:GetModel("MD_P42MASTER") //FWModelActive()
	Local nOpc       := oModelPad:GetOperation()
	Local lRet       := .T.
	Local nTextOpc   := ""
	Local cGrupo     := oModelPad:GetValue('P42_GRUPO' ) //as charater

	If nOpc == MODEL_OPERATION_VIEW
		nTextOpc := 'visualizar'
	ElseIf nOpc == MODEL_OPERATION_INSERT
		nTextOpc := 'incluir'
	ElseIf nOpc == MODEL_OPERATION_UPDATE
		nTextOpc := 'alterar'
		oModelPad:SetValue("P42_USRAID", RETCODUSR() ) 
		oModelPad:SetValue("P42_USRANO", USRRETNAME(RETCODUSR()) )
		oModelPad:SetValue("P42_USRADT", DATE() ) 
		oModelPad:SetValue("P42_USRAHR", SubStr( time(),1,5) ) 
	ElseIf nOpc == MODEL_OPERATION_DELETE
		
		If MsgYesNo('<font color="#4865E5">' + '<h1> Deseja excluir o grupo e sua amarração com as filiais ? </h1>' + '</font>', "Confirma?")

			If Select('P43') < 0
				DBSELECTAREA( 'P43')
			EndIF
			P43->(DBSETORDER( 1 )) // P43_FILIAL + P43_GRUPO + P43_FILAUT
		
			If dbSeek( xFilial("P43") + cGrupo ) 
				
				WHILE P43->(!Eof()) .And. Alltrim(cGrupo) ==  Alltrim(P43->P43_GRUPO)				
					Reclock("P43", .F.)
					P43->(dbDelete())
					P43->(MsUnlock())
					P43->(DbSkip())
				EndDo
			EndIf
				
			nTextOpc := 'excluir'

		Else
		  lRet := .F. // Não excluir
		EndIF

	EndIF

Return lRet
