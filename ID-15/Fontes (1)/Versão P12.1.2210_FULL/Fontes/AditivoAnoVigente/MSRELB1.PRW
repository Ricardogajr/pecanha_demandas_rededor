#Include 'Protheus.ch'
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TopConn.ch"
#Include 'FWMVCDef.ch'
#Include 'MATA094.ch'
#Include "GCTXDEF.CH"
#INCLUDE "MATA097.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"


 
//Relatório de produtos de serviço da SB1 em tela
//Lucas Miranda de Aguiar
//14/05/2024

User Function MSRELB1()

	RptStatus({|| MSRELB1A()}, "Aguarde...", "Gerando relatório...")

Return


Static Function MSRELB1A()

	Local aRotinaBkp := {}
	//Objetos e componentes
	Private oDlgPulo
	Private oFwLayer
	Private oPanTitulo
	Private oPanGrid
	//Cabeçalho
	Private oSayModulo, cSayModulo := "Rede D'Or"
	Private oSayTitulo, cSayTitulo := 'Produtos de serviço'
	Private oSaySubTit, cSaySubTit := 'Resumo'
	//Tamanho da janela
	Private aSize := MsAdvSize(.F.)
	Private nJanLarg := 1150//aSize[5]
	Private nJanAltu := 600//aSize[6]
	//Fontes
	Private cFontUti    := "Tahoma"
	Private oFontMod    := TFont():New(cFontUti, , -38)
	Private oFontSub    := TFont():New(cFontUti, , -20)
	Private oFontSubN   := TFont():New(cFontUti, , -20, , .T.)
	Private oFontBtn    := TFont():New(cFontUti, , -14)
	Private oFontSay    := TFont():New(cFontUti, , -12)
	//Grid
	Private aCampos := {}
	Private cAliasTmp := GetNextAlias()
	Private aColunas := {}

	If Type("aRotina") == "A"
		aRotinaBkp := aRotina
		aRotina := {}
	EndIf

	//Campos da Temporária
	aAdd(aCampos, { 'COD_PRDT', 'C', 15, 0})
	aAdd(aCampos, { "DESC_PRDT" , "C", 254, 0 })
	aAdd(aCampos, { "DESC_COMP" , "C", 254, 0 })
	aAdd(aCampos, { "COD_REF", "C", 100,  0 })
	aAdd(aCampos, { "NAT_REC", "C", 100,  0 })
	aAdd(aCampos, { "GRUPO", "C", 100,  0 })
	aAdd(aCampos, { "CONT_DESP", "C", 100,  0 })
	aAdd(aCampos, { "CONT_PAT", "C", 100,  0 })
	aAdd(aCampos, { "CONT_REC", "C", 100,  0 })
	aAdd(aCampos, { "CONT_EST", "C", 100,  0 })
	aAdd(aCampos, { "STATUS", "C", 10,  0 })

	//Cria a tabela temporária
	oTempTable:= FWTemporaryTable():New(cAliasTmp)
	oTempTable:SetFields( aCampos )
	oTempTable:Create()

	//Busca as colunas do browse
	aColunas := fCriaCols()

	//Popula a tabela temporária
	fPopula()

	//Cria a janela
	DEFINE MSDIALOG oDlgPulo TITLE "Resumo dos produtos de serviço."  FROM 0, 0 TO nJanAltu, nJanLarg PIXEL

	//Criando a camada
	oFwLayer := FwLayer():New()
	oFwLayer:init(oDlgPulo,.F.)

	//Adicionando 3 linhas, a de título, a superior e a do calendário
	oFWLayer:addLine("TIT", 15, .F.)
	oFWLayer:addLine("COR", 90, .F.)

	//Adicionando as colunas das linhas
	oFWLayer:addCollumn("HEADERTEXT",   060, .T., "TIT")
	oFWLayer:addCollumn("BTNOK",     	100, .T., "TIT")
	oFWLayer:addCollumn("BTNSAIR",      100, .T., "TIT")
	oFWLayer:addCollumn("COLGRID",      100, .T., "COR")

	//Criando os paineis
	oPanHeader := oFWLayer:GetColPanel("HEADERTEXT", "TIT")
	oPanSair   := oFWLayer:GetColPanel("BTNSAIR",    "TIT")
	oPanSair   := oFWLayer:GetColPanel("BTNOK",      "TIT")
	oPanGrid   := oFWLayer:GetColPanel("COLGRID",    "COR")

	//Títulos e SubTítulos
	oSayModulo := TSay():New(004, 008, {|| cSayModulo}, oPanHeader, "", oFontMod,  , , , .T., RGB(149, 179, 215), , 200, 30, , , , , , .F., , )
	oSayTitulo := TSay():New(004, 100, {|| cSayTitulo}, oPanHeader, "", oFontSub,  , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )
	oSaySubTit := TSay():New(014, 100, {|| cSaySubTit}, oPanHeader, "", oFontSubN, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , )

	//Criando os botões
	oBtnSair := TButton():New(006, 9, "Exportar para Excel",             oPanSair, {|| oDlgPulo:End(),lPosTela := .T.,Processa({|| fexport(cAliasTmp)}, "Gerando Excel...")}, 70, 018, , oFontBtn, , .T., , , , , , )
	oBtnSair := TButton():New(006, 80, "Sair",             oPanSair, {|| oDlgPulo:End()}, 70, 018, , oFontBtn, , .T., , , , , , )

	//Cria a grid
	oGetGrid := FWMarkBrowse():New()
	oGetGrid:SetDataTable()
	//oGetGrid:SetInsert(.F.)
	//oGetGrid:SetDelete(.F., { || .F. })
	oGetGrid:SetAlias(cAliasTmp)
	oGetGrid:DisableReport()
	//oGetGrid:DisableFilter()
	oGetGrid:DisableConfig()
	oGetGrid:DisableReport()
	oGetGrid:DisableSeek()
	oGetGrid:DisableSaveConfig()
	//oGetGrid:SetFieldMark('OK')
	oGetGrid:SetFontBrowse(oFontSay)
	oGetGrid:SetMenuDef("MSRELB1")
	oGetGrid:SetColumns(aColunas)
	oGetGrid:SetOwner(oPanGrid)
	//oGetGrid:SetCustomMarkRec({ || fOk(oGetGrid) })
	oGetGrid:Activate()
	Activate MsDialog oDlgPulo Centered
	oTempTable:Delete()
	If !Empty(aRotinaBkp)
		aRotina := aRotinaBkp
	EndIf

Return


Static Function fCriaCols()
	Local nAtual   := 0
	Local aColunas := {}
	Local aEstrut  := {}
	Local oColumn

	//Adicionando campos que serão mostrados na tela
	//[1] - Campo da Temporaria
	//[2] - Titulo
	//[3] - Tipo
	//[4] - Tamanho
	//[5] - Decimais
	//[6] - Máscara
	/*/aAdd(aEstrut, {"TIPO", "Tipo dos Docs",                "C", TamSX3('CR_TIPO')[01],   0, ""})
	aAdd(aEstrut, {"DESCTP", "Descrição do tipo",             "C", 25,    0, ""})
	aAdd(aEstrut, {"QTD", "Quantidade selecionada",             "N", 5,    0, ""})
	aAdd(aEstrut, {"Total", "Valor total dos documentos",             "C", 15,  0  , ""})/*/

	aAdd(aEstrut, {"COD_PRDT","CODIGO_PRODUTO", 'C', 15, 0, ""})
	aAdd(aEstrut, {"DESC_PRDT","DESCRICAO_PRODUTO" , "C", 254, 0, ""} )
	aAdd(aEstrut, {"DESC_COMP","DESCRICAO_COMPLETA" , "C", 254, 0, ""} )
	aAdd(aEstrut, {"COD_REF", "CODIGO_REFERENCIA", "C", 100,  0, ""} )
	aAdd(aEstrut, {"NAT_REC","NATUREZA_RECEITA", "C", 100,  0, ""} )
	aAdd(aEstrut, {"GRUPO","GRUPO", "C", 100,  0, ""} )
	aAdd(aEstrut, {"CONT_DESP","CONTA_DESPESA", "C", 100,  0, ""} )
	aAdd(aEstrut, {"CONT_PAT","CONTA_PATRIMONIAL", "C", 100,  0, ""})
	aAdd(aEstrut, {"CONT_REC","CONTA_RECEITA", "C", 100,  0, ""} )
	aAdd(aEstrut, {"CONT_EST","CONTA_DE_ESTOQUE", "C", 100,  0, ""})
	aAdd(aEstrut, {"STATUS","STATUS", "C", 10,  0, ""} )



	//Percorrendo todos os campos da estrutura
	For nAtual := 1 To Len(aEstrut)
		//Cria a coluna
		oColumn := FWBrwColumn():New()
		oColumn:SetData(&("{|| (cAliasTmp)->" + aEstrut[nAtual][1] +"}"))
		oColumn:SetTitle(aEstrut[nAtual][2])
		oColumn:SetType(aEstrut[nAtual][3])
		oColumn:SetSize(aEstrut[nAtual][4])
		oColumn:SetDecimal(aEstrut[nAtual][5])
		oColumn:SetPicture(aEstrut[nAtual][6])
		//oColumn:bHeaderClick := &("{|| fOrdena('" + aEstrut[nAtual][1] + "') }")

		//Adiciona a coluna
		aAdd(aColunas, oColumn)
	Next
Return aColunas



Static Function fPopula()

	Local cQuery := " "
	Local cAlias := GetNextAlias()
	Local nAtual := 0
	Local nTotal := 0


	cQuery += " SELECT                                                                                                             "
	cQuery += " B1_COD	CODIGO_PRODUTO,                                                                                            "
	cQuery += " TRIM(B1_DESC)	DESCRICAO_PRODUTO,                                                                                 "
	cQuery += " TRIM(B1_XDES)	DESCRICAO_COMPLETA,                                                                                "
	cQuery += " CASE WHEN B1_XREFER = ' ' THEN ' ' ELSE TRIM(B1_XREFER) END CODIGO_REFERENCIA,                                     "
	cQuery += " B1_XNATREC	NATUREZA_RECEITA,                                                                                      "
	cQuery += " B1_GRUPO	GRUPO,                                                                                                 "
	cQuery += " CASE WHEN BM_XCONTA = ' ' THEN ' ' ELSE TRIM(BM_XCONTA) ||' - ' || TRIM(BM_XDESCD) END CONTA_DESPESA,	           "
	cQuery += " CASE WHEN BM_XCTPAT = ' ' THEN ' ' ELSE TRIM(BM_XCTPAT) ||' - ' || TRIM(BM_XDESCP) END CONTA_PATRIMONIAL,	       "
	cQuery += " CASE WHEN BM_XCTREC = ' ' THEN ' ' ELSE TRIM(BM_XCTREC) ||' - ' || TRIM(BM_XDESCR) END CONTA_RECEITA,	           "
	cQuery += " CASE WHEN BM_XCTDES = ' ' THEN ' ' ELSE TRIM(BM_XCTDES) ||' - ' || TRIM(BM_XDESCE) END CONTA_DE_ESTOQUE,	       "
	cQuery += " 'ATIVO' STATUS													                                                   "
	cQuery += " FROM " +RetSqlName("SB1")+ " B1 "                                                                                  "
	cQuery += " INNER JOIN "+RetSqlName("SBM") + " BM ON "                                                                         "
	cQuery += " BM.D_E_L_E_T_ = ' ' AND                                                                                            "
	cQuery += " BM.BM_GRUPO = B1.B1_GRUPO                                                                                          "
	cQuery += " WHERE                                                                                                              "
	cQuery += " B1.D_E_L_E_T_ = ' ' AND B1_MSBLQL = '2'                                                                            "
	cQuery += " AND B1.B1_XMATSER = '2'                                                                                            "

	If Select( cAlias ) > 0
		( cAlias )->( DbCloseArea() )
	EndIf

	TcQuery cQuery Alias ( cAlias) New

	Count To nTotal
	SetRegua(nTotal)
	(cAlias)->(DbGoTop())


	While !( cAlias )->( Eof() )

		nAtual++
		IncRegua()

		RecLock(cAliasTmp, .T.)
		(cAliasTmp)->COD_PRDT    	    := (cAlias)->CODIGO_PRODUTO
		(cAliasTmp)->DESC_PRDT  		:= (cAlias)->DESCRICAO_PRODUTO
		(cAliasTmp)->DESC_COMP 			:= (cAlias)->DESCRICAO_COMPLETA
		(cAliasTmp)->COD_REF  			:= (cAlias)->CODIGO_REFERENCIA
		(cAliasTmp)->NAT_REC   			:= (cAlias)->NATUREZA_RECEITA
		(cAliasTmp)->GRUPO              := (cAlias)->GRUPO
		(cAliasTmp)->CONT_DESP      	:= (cAlias)->CONTA_DESPESA
		(cAliasTmp)->CONT_PAT  			:= (cAlias)->CONTA_PATRIMONIAL
		(cAliasTmp)->CONT_REC      		:= (cAlias)->CONTA_RECEITA
		(cAliasTmp)->CONT_EST   		:= (cAlias)->CONTA_DE_ESTOQUE
		(cAliasTmp)->STATUS             := (cAlias)->STATUS
		(cAliasTmp)->(MsUnlock())



		(cAlias)->(DbSkip())
	EndDo
	( cAlias )->( DbCloseArea() )


Return



Static Function fexport(cAliasTmp)
	Local aArea       := GetArea()
	Local cArquivo    := GetTempPath()+'Resumo_Produtos_Serviço' + DtoS(ddatabase) + __cUserID + '.xml'
	Local oFWMsExcel
	Local oExcel

	//Criando o objeto que irá gerar o conteúdo do Excel
	oFWMsExcel := FWMSExcel():New()



	oFWMsExcel:AddworkSheet("Relatório")
	//Criando a Tabela
	oFWMsExcel:AddTable("Relatório","Produtos")
	oFWMsExcel:AddColumn("Relatório","Produtos","Código do produto",1)
	oFWMsExcel:AddColumn("Relatório","Produtos","Descrição do produto",1)
	oFWMsExcel:AddColumn("Relatório","Produtos","Descrição completa",1)
	oFWMsExcel:AddColumn("Relatório","Produtos","Código de referencia",1)
	oFWMsExcel:AddColumn("Relatório","Produtos","Natureza da receita",1)
	oFWMsExcel:AddColumn("Relatório","Produtos","Grupo",1)
	oFWMsExcel:AddColumn("Relatório","Produtos","Conta despesa",1)
	oFWMsExcel:AddColumn("Relatório","Produtos","Conta patrimonial",1)
	oFWMsExcel:AddColumn("Relatório","Produtos","Conta receita",1)
	oFWMsExcel:AddColumn("Relatório","Produtos","Conta de estoque",1)
	oFWMsExcel:AddColumn("Relatório","Produtos","Status",1)

	//Criando as Linhas... Enquanto não for fim da query
	(cAliasTmp)->(DbGoTop())
	While !((cAliasTmp)->(EoF()))
		oFWMsExcel:AddRow("Relatório","Produtos",{;
			(cAliasTmp)->COD_PRDT,;
			(cAliasTmp)->DESC_PRDT,;
			(cAliasTmp)->DESC_COMP,;
			(cAliasTmp)->COD_REF,;
			(cAliasTmp)->NAT_REC,;
			(cAliasTmp)->GRUPO,;
			(cAliasTmp)->CONT_DESP,;
			(cAliasTmp)->CONT_PAT,;
			(cAliasTmp)->CONT_REC,;
			(cAliasTmp)->CONT_EST,;
			(cAliasTmp)->STATUS;
			})

		//Pulando Registro
		(cAliasTmp)->(DbSkip())
	EndDo

	MsgInfo("O arquivo foi gerado com sucesso na pasta " + cArquivo + CRLF + "O Excel será aberto após fechar esta mensagem.","Resumo de produtos")
	//Ativando o arquivo e gerando o xml
	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cArquivo)

	//Abrindo o excel e abrindo o arquivo xml
	oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
	oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
	oExcel:SetVisible(.T.)                 //Visualiza a planilha
	oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas

	RestArea(aArea)
Return
