#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MSGRAPHI.CH"
/*/{Protheus.doc} RHDIVE01

	Tela de controle de Diversidade do RH - RHDIVE01

	@type Function User
	@author Cleiton Genuino da Silva
	@since 28/11/2023
	@version 12.1.2210

/*/
User Function RHDIVE01()
	Local aArea       := GetArea()      as array
	Local aGenero     := {}             as array
	Local aCpsFilt    := {}             as array
	Local aFilter     := {}             as array
	Local aIndex      := {}             as array
	Local aSeek       := {}             as array
	Local cAlsSRA     := GetNextAlias() as character
	Local cDescGenero := ''             as character
	Local nF          := 0              as numeric

	cQry := "   SELECT RA_FILIAL,"
	cQry += "          RA_MAT,"
	cQry += "          RA_NOMECMP,"
	cQry += "          RA_CIC,"
	cQry += "          RA_EMAIL,"
	cQry += "          RA_NUMCELU,"
	cQry += "          RA_RACACOR,"
    cQry += "          RA_DEFIFIS,"
	cQry += "          RA_XGENERO,"
	cQry += "          RA_XUSASOC,"
	cQry += "          RA_XNAMESO,"
	cQry += "          RA_XCODRAC,"
	cQry += "          RA_DEPTO,"
	cQry += "          RA_CODFUNC,"
	cQry += "          RA_CC,"
	cQry += "          SRA.R_E_C_N_O_ AS RA_RECNO"
	cQry += "     FROM " + RetSqlName("SRA") + " SRA"
	cQry += "    WHERE RA_FILIAL <> ' '"
	cQry += "      AND SRA.D_E_L_E_T_ = ' '"
	cQry += " ORDER BY RA_FILIAL, RA_MAT "

	Aadd( aSeek, { "Filial.+ Matricul."   , {{"", "C", TamSX3("RA_FILIAL")[1]  , 0 ,"RA_FILIAL"   , X3Picture("RA_FILIAL")    },;
		{"", "C", TamSX3("RA_MAT")[1]  , 0 ,"RA_MAT"   , X3Picture("RA_MAT")    }}, 1} )
	Aadd( aSeek, { "Filial.+ CPF"  , {{"", "C", TamSX3("RA_FILIAL")[1]  , 0 ,"RA_FILIAL"   , X3Picture("RA_FILIAL")    },;
		{"", "C", TamSX3("RA_CIC")[1]  , 0 ,"RA_CIC"   , X3Picture("RA_CIC")    }}, 2} )

	Aadd( aIndex, "RA_FILIAL+RA_MAT" )
	Aadd( aIndex, "RA_FILIAL+RA_CIC" )

	aAdd(aCpsFilt,"RA_FILIAL")
	aAdd(aCpsFilt,"RA_CIC")
	aAdd(aCpsFilt,"RA_MAT")

	For nF := 1 to Len(aCpsFilt)
		Aadd(aFilter,{aCpsFilt[nF] ,;
			RetTitle(aCpsFilt[nF]) ,;
			TamSx3(aCpsFilt[nF])[3],;
			TamSx3(aCpsFilt[nF])[1] ,;
			TamSx3(aCpsFilt[nF])[2],"@!"})
	Next
	

	oBrowse := FWmBrowse():New()
	oBrowse:SetDataQuery(.T.)
	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetSeek(, aSeek)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetAlias(cAlsSRA)
	oBrowse:SetQuery(cQry)
	oBrowse:SetDescription("Tela Diversidade")
	oBrowse:DisableDetails()
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetCacheView(.F.)
	oBrowse:SetProfileID( 'BRW2')
	oBrowse:SetFieldFilter(aFilter)
	oBrowse:SetAmbiente(.F.)
	oBrowse:SetWalkThru(.F.)
	oBrowse:SetUseCursor(.F.)
	oBrowse:SetSeeAll(.T.) // Permite visualizar registros todas filiais
	oBrowse:SetChgAll(.F.) // Permite alterar reg. de outras filiais

	oBrowse:AddButton("Gerar Relatório",{|| U_INSU003()},,2,,,8)
	oBrowse:AddButton("Visualizar",{|| U_INSU001()},,2,,,8)
	If SuperGetMV("RD_IMPORTA", .T. ,.F.)
		oBrowse:AddButton("Importar",{|| U_INSU002()},,2,,,8)
	EndIf

	If !Empty((cAlsSRA)->RA_XGENERO)
		aGenero := FWGetSX5('ZG', PadR((cAlsSRA)->RA_XGENERO, TamSx3("X5_CHAVE")[1])) 
		If len(aGenero) > 0
			cDescGenero := aGenero[1][4]
		EndIf
	EndIf

	CriaColuna("Código da filial" 		,{||(cAlsSRA)->RA_FILIAL},TamSx3("RA_FILIAL")[01],TamSx3("RA_FILIAL")[03], "RA_FILIAL","SRA")//RA_FILIAL
	CriaColuna("Desc. Filial" 			,{||FWFilialName(cEmpAnt,(cAlsSRA)->RA_FILIAL)})//RA_FILIAL
	CriaColuna("Matrícula" 				,{||(cAlsSRA)->RA_MAT}   ,TamSx3("RA_MAT")[01],TamSx3("RA_MAT")[03], "RA_MAT","SRA")//RA_MAT
	CriaColuna("Nome Completo" 		    ,{||Alltrim((cAlsSRA)->RA_NOMECMP)})//RA_NOMECMP
	CriaColuna("CPF" 		    		,{||(cAlsSRA)->RA_CIC}   ,TamSx3("RA_CIC")[01],TamSx3("RA_CIC")[03], "RA_CIC","SRA")//RA_CIC
	CriaColuna("E-mail Corporativo" 	,{||(cAlsSRA)->RA_EMAIL} ,TamSx3("RA_EMAIL")[01],TamSx3("RA_EMAIL")[03], "RA_EMAIL","SRA")//RA_EMAIL
	CriaColuna("Telefone" 		    	,{||(cAlsSRA)->RA_NUMCELU}   ,TamSx3("RA_NUMCELU")[01],TamSx3("RA_NUMCELU")[03], "RA_NUMCELU","SRA")//RA_NUMCELU
	CriaColuna("Cor" 		    		,{||If( (cAlsSRA)->RA_RACACOR == "1" , "Indígena" , ( If( (cAlsSRA)->RA_RACACOR == "2" , "Branca" , ( If( (cAlsSRA)->RA_RACACOR == "4" , "Negra" , ( If( (cAlsSRA)->RA_RACACOR == "6" , "Amarela" , ( If( (cAlsSRA)->RA_RACACOR == "8" , "Parda" , "Não informado" ) ) ) ) ) ) ) ) )}   ,TamSx3("RA_RACACOR")[01],TamSx3("RA_RACACOR")[03], "RA_RACACOR","SRA")//RA_RACACOR
	CriaColuna("Possui Deficiência ?"   ,{||IF((cAlsSRA)->RA_DEFIFIS=='1','Sim','Não') } ,TamSx3("RA_DEFIFIS")[01],TamSx3("RA_DEFIFIS")[03], "RA_DEFIFIS","SRA")//RA_DEFIFIS - 1=Sim;2=Nao 
	CriaColuna("Usa Social Nome ?"      ,{||IF((cAlsSRA)->RA_XUSASOC=='S', 'Sim' , IF((cAlsSRA)->RA_XUSASOC=='N','Não', ' '))})//RA_XUSASOC
	CriaColuna("Nome Social"     		,{||(cAlsSRA)->RA_XNAMESO},TamSx3("RA_XNAMESO")[01],TamSx3("RA_XNAMESO")[03], "RA_XNAMESO","SRA")//RA_XNAMESO
	CriaColuna("Gênero"     			,{||(cAlsSRA)->RA_XGENERO} ,TamSx3("RA_XGENERO")[01],TamSx3("RA_XGENERO")[03], "RA_XGENERO","SRA")//RA_XGENERO
	CriaColuna("Desc. Gênero"     		,{||FDESC('SX5',"ZG" + (cAlsSRA)->RA_XGENERO,'X5_DESCRI',,(cAlsSRA)->RA_FILIAL)})//RA_XDESCGE
	CriaColuna("Raça Ident"     		,{||(cAlsSRA)->RA_XCODRAC} ,TamSx3("RA_XCODRAC")[01],TamSx3("RA_XCODRAC")[03], "RA_XCODRAC","SRA")//RA_XCODRAC
	CriaColuna("Desc. Raça"     		,{||FDESC('SX5',"ZH" + (cAlsSRA)->RA_XCODRAC,'X5_DESCRI',,(cAlsSRA)->RA_FILIAL)})//RA_
	CriaColuna("Cód. Departamento"     	,{||(cAlsSRA)->RA_DEPTO} ,TamSx3("RA_DEPTO")[01],TamSx3("RA_DEPTO")[03], "RA_DEPTO","SRA")//RA_DEPTO                                                                  
	CriaColuna("Departamento"     		,{||FDESC('SQB',(cAlsSRA)->RA_DEPTO,'QB_DESCRIC')})//RA_DDEPTO
	CriaColuna("Cód. da função"     	,{||(cAlsSRA)->RA_CODFUNC},TamSx3("RA_CODFUNC")[01],TamSx3("RA_CODFUNC")[03], "RA_CODFUNC","SRA")//RA_CODFUNC
	CriaColuna("Desc. da função"     	,{|| FDESC('SRJ',(cAlsSRA)->RA_CODFUNC,'RJ_DESC',TamSX3('RJ_DESC'),(cAlsSRA)->RA_FILIAL)}) //RA_DESCFUNC   
	CriaColuna("Cód. Centro de custo"   ,{||(cAlsSRA)->RA_CC}   ,TamSx3("RA_CC")[01],TamSx3("RA_CC")[03], "RA_CC","SRA")//RA_CC
	CriaColuna("Desc. Centro de custo"  ,{||(FDESC("CTT",(cAlsSRA)->RA_CC,"CTT_DESC01",,(cAlsSRA)->RA_FILIAL))} )//RA_DESCCC

	oBrowse:Activate()

	FreeObj( oBrowse )

	RestArea(aArea)

Return
/*/{Protheus.doc} CriaColuna

	Monta menu principal, função para criar as colunas do fwmbrose

	@type Function Static
	@author Cleiton Genuino da Silva
	@since 09/08/2023
	@version 12.1.2210
	@param cTitulo	, character		, Titulo a ser exibido no browser
	@param bData	, array			, Recebe o codeblock com a informação de inicialização do campo
	@param nSize	, numeric		, Titulo a ser exibido na coluna
	@param cType	, character		, Define o tipo do campo que será apresentado C = Catacter, D = Data, N = Numérico
	@param cCampo	, character		, Campo a ser carregado
	@param cTabela	, character		, Tabela da origem do dado

/*/
Static Function CriaColuna( cTitulo, bData, nSize, cType, cCampo, cTabela )
	Local aArea     := GetArea() as array
	Local aCampoFil := {}        as array
	Local oColumn   := NIL       as object
	Default bData   := ''
	Default cCampo  := ''
	Default cTabela := ''
	Default cTitulo := ''
	Default cType   := ''
	Default nSize   := 0

	oColumn := FWBrwColumn():New()
	oColumn:SetData(bData) //recebe o codeblock com a informação de inicialização do campo
	oColumn:SetTitle(cTitulo) // recebe o titulo que será apresentado na coluna
	oColumn:SetSize(nSize) // tamanho do campo
	oColumn:cType := cType // define o tipo do campo que será apresentado C = Catacter, D = Data, N = Numérico
	oBrowse:SetColumns({oColumn})// adiciona a coluna ao Browser
	aadd(aCampoFil,{ cTitulo, nSize, cType,cCampo,cTabela })//adiciona ao array de filtros, todo o campo aqui adicionado será utlizado para filtro

	RestArea(aArea)

Return
/*/{Protheus.doc} MenuDef

	Monta menu principal

	@type  Function Static
	@author Cleiton Genuino da Silva
	@since 28/11/2023
	@version 12.1.2210
	@return array, Lista de funções do menu

/*/
Static Function MenuDef()

	Local aRotina := {} as array
	//Adicionando opções
	/*ADD OPTION aRotina TITLE "2-V&isualizar"				ACTION "U_INSU001"  	OPERATION 2 ACCESS 0*/
	aRotina:= {{"2-Visualizar"						,"U_INSU001"					,0,1}}
	//ADD OPTION aRotina TITLE "3-I&mportação de Carga"		ACTION "U_INSU002"  	OPERATION 2 ACCESS 0

Return aRotina
/*/{Protheus.doc}INSU001

	função para chamada da execview com a SRA posicionada

	@type  Function Static
	@author  Cleiton Genuino da Silva
	@since 28/11/2023
	@version 12.1.2210

/*/
User Function INSU001()
	Local aArea    := GetArea()            as array
	Local cAlsSRA  := oBrowse:cAlias       as character
	Local cSRAFilE := (cAlsSRA)->RA_FILIAL as character
	Local cSRAMat  := (cAlsSRA)->RA_MAT    as character

	If Select('SRA') <= 0
		dbSelectArea('SRA')
	EndIf
	SRA->(DbSetOrder(1)) //RA_FILIAL+RA_MAT+RA_NOME
	If SRA->(DbSeek( cSRAFilE + cSRAMat ))
		FWExecView('Consulta', "VIEWDEF.RHDIVE01", MODEL_OPERATION_VIEW, , { || .T. }, , /*30*/)
	Endif

	oBrowse:FWBrowse():UpdateBrowse()
	RestArea(aArea)

Return
/*/{Protheus.doc} ModelDef

	Montar model do mvc

	@type  Function Static
	@author Cleiton Genuino da Silva
	@since 28/11/2023
	@version 12.1.2210

/*/
Static Function ModelDef()
	Local cSRAlist := LoodSRA()                                                    as character
	Local oModel   := nil                                                          as object
	Local oStPai   := FWFormStruct(1, 'SRA' ,{ |x| ALLTRIM(x) $ cSRAlist },,,.F. ) as object

	oModel := MPFormModel():New("MRHDIVE01",,)

	oModel:addFields('MD_SRAMASTER',,oStPai,)

	//Setando as descrição
	oModel:SetDescription( "RHDIVE01 - SRA - Diversidade :" + cUserName )
	oModel:GetModel('MD_SRAMASTER'):SetDescription('Diversidade')
	

Return oModel
/*/{Protheus.doc} ViewDef

	Montar view do mvc

	@type  Function Static
	@author Cleiton Genuino da Silva
	@since 28/11/2023
	@version 12.1.2210

/*/
Static Function ViewDef()
	Local cSRAlist := LoodSRA()                                                    as character
	Local oModel   := FWLoadModel("RHDIVE01")                                      as object
	Local oStPai   := FWFormStruct(2, 'SRA' ,{ |x| ALLTRIM(x) $ cSRAlist },,,.F. ) as object
	Local oView    := NIL                                                          as object

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField( 'VIEW_SRA' , oStPai, 'MD_SRAMASTER' )

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox( 'BOX_SUPERIOR', 100)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_SRA','BOX_SUPERIOR')

	//Habilitando tí­tulo
	oView:EnableTitleView('VIEW_SRA','Cabeçalho do Ecommerce')

	// habilita a barra de controle
	oView:EnableControlBar(.T.)

	//verificar se a janela deve ou não ser fechada após a execução do botão OK
	oView:SetCloseOnOk({|| .T.})

Return oView
/*/{Protheus.doc}LoodSRA

	Retorna lista de campos usado no modelo de dados x view

	@type  Function Static
	@author Cleiton Genuino da Silva
	@since 28/11/2023
	@version 12.1.2210
	@return character, Lista da SRA para montar modelo de dados
/*/
Static Function LoodSRA()
	Local aArea := GetArea() as array
	Local cSRAlist := 'RA_FILIAL,RA_MAT,RA_NOMECMP,RA_CIC,RA_EMAIL,RA_NUMCELU,RA_RACACOR,RA_DEFIFIS,RA_XGENERO,RA_XDESCGE, RA_XUSASOC,RA_XNAMESO,RA_XCODRAC, RA_XDESCRA, RA_DEPTO,RA_DDEPTO,RA_CODFUNC,RA_DESCFUNC,RA_CC,RA_DESCCC' as character
					   
	RestArea(aArea)

Return(cSRAlist)
/*/{Protheus.doc} INSU003

	Confirmar nova tentativa de geração de relatorio

	@type Function Static
	@author Cleiton Genuino da Silva
	@since 28/11/2023
	@version 12.1.2210

/*/
User Function INSU003()
	Local aArea := GetArea() as array
	Local lOk   := .T.       as logical

		IF FindFunction('U_RHDIVER')
			//U_RHDIVE03() // Relatorio Treport
			U_RHDIVER() // Relatorio Excel
		ENDIF

	RestArea(aArea)

Return lOk
/*/{Protheus.doc} INSU002

	Faz importação de dados de diversidade

	@type Function Static
	@author Cleiton Genuino da Silva
	@since 28/11/2023
	@version 12.1.2210

/*/
User Function INSU002()
	Local aArea := GetArea() as array
	Local lOk   := .T.       as logical

		IF FindFunction('U_RHDIVE04')
			U_RHDIVE04() // Importação
		ENDIF

	RestArea(aArea)

Return lOk

