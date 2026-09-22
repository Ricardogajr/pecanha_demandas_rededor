#Include 'Protheus.ch'
#Include 'TopConn.ch'
#Include 'Report.Ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} F0300202

Relatorio Plano de Açõe Pesquisa de Clima

@author Everson S P Junior
@since 12/07/2016
@version P12.7
@Project MAN0000004_EF_002

/*/
//--------------------------------------------------------------------
User Function F0300202()
	Private cPerg := "F0300202"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	pergunte(cPerg,.F.)
	
	oReport := ReportDef()
	oReport :PrintDialog()
	
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao dos componentes de impressao                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ReportDef()
	Local oReport
	Local oSection1, oSection2, oSection3, oSection4
	Local cDesc	 :=	"Relatório de Controle de Pesquisa de Clima" //Descrição
	Local cTitulo:= "Controle de Pesquisa de Clima" //Titulo
	Local aOrd   :=	{}
	Local aStruXX8 := XX8->(dbStruct())
	Local nI := 0
	Local cAliasQry	:= "PA4"
	
	AAdd( aOrd, 'Por Unidade' )  // Por Matricula
	AAdd( aOrd, 'Por Data Inicio' )   // Por Servidor
	AAdd( aOrd, 'Por Matricula' )    // Por Jornada
	AAdd( aOrd, 'Por Responsavel' )    // Por Lotação
	AAdd( aOrd, 'Por Status' )      // Por Cargo
	AAdd( aOrd, 'Por Data Conclus' )       // Por Data
	
	DEFINE REPORT oReport NAME "F0300202"  TITLE cTitulo PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} DESCRIPTION cDesc
	
	oSection1 := TRSection():New(oReport,cTitulo,{cAliasQry},aOrd)
	TRCell():New(oSection1,"PA4_XFIL", cAliasQry, "Unidade")
	TRCell():New(oSection1,"TMP_XDFIL", "", "Desc. Unidade")
	TRCell():New(oSection1,"PA4_XCOD", cAliasQry, "Cod. Pesquisa")
	TRCell():New(oSection1,"TMP_XCOD", "", "Desc. Pesquisa")
	
	oSection2 := TRSection():New(oReport,cTitulo,{cAliasQry},aOrd)
	TRCell():New(oSection2,"PA4_XACAO", cAliasQry, "Acao Tomada")
	TRCell():New(oSection2,"PA4_XMAT", cAliasQry, "Matricula")
	TRCell():New(oSection2,"PA4_XPART", cAliasQry, "Nome Respons.")
	TRCell():New(oSection2,"PA4_XDTIN", cAliasQry, "Data Inicio")
	
	oSection3 := TRSection():New(oReport,cTitulo,{"PA4"},aOrd)
	TRCell():New(oSection3,"PA4_XPRAZ", cAliasQry, "Prazo Conclu.")
	TRCell():New(oSection3,"PA4_XSTART", cAliasQry, "Status Acao")
	TRCell():New(oSection3,"PA4_XDTCO", cAliasQry, "Data Conclus")
	
	oSection4 := TRSection():New(oReport,cTitulo,{"PA4"},aOrd)
	TRCell():New(oSection4,"PA4_XOBS", cAliasQry, "Observacoes")
	
	oSection1:Cell('PA4_XFIL'):SetSize(TamSX3('PA4_XFIL')[1])
	oSection1:Cell('PA4_XCOD'):SetSize(TamSX3('PA4_XCOD')[1])
	oSection1:Cell('TMP_XCOD'):SetSize(TamSX3('RD5_DESC')[1])
	
	oSection2:Cell('PA4_XACAO'):SetSize(TamSX3('PA4_XACAO')[1])
	oSection2:Cell('PA4_XMAT'):SetSize(TamSX3('PA4_XMAT')[1])
	oSection2:Cell('PA4_XPART'):SetSize(TamSX3('PA4_XPART')[1])
	oSection2:Cell('PA4_XDTIN'):SetSize(TamSX3('PA4_XDTIN')[1])
	
	oSection3:Cell('PA4_XPRAZ'):SetSize(TamSX3('PA4_XPRAZ')[1])
	oSection3:Cell('PA4_XSTART'):SetSize(TamSX3('PA4_XSTART')[1])
	oSection3:Cell('PA4_XDTCO'):SetSize(TamSX3('PA4_XDTCO')[1])
	
	oSection4:Cell('PA4_XOBS'):SetSize(170)
	
	//oReport:SetDevice(4) //Define o tipo de impressão selecionado. Opções: 1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html.
	
	For nI := 1 To Len(aStruXX8)
		If aStruXX8[nI][1] == "XX8_DESCRI"
			Exit
		EndIf
	Next
	
	If nI <= Len(aStruXX8)
		oSection1:Cell('TMP_XDFIL'):SetSize(aStruXX8[nI][3])
	EndIf
	
	oSection1:SetHeaderPage()
	oSection2:SetHeaderPage()
	oSection3:SetHeaderPage()
	oSection4:SetHeaderPage()
	
	oSection1:SetLineBreak(.T.)
	oSection2:SetLineBreak(.T.)
	oSection3:SetLineBreak(.T.)
	oSection4:SetLineBreak(.T.)
	
Return oReport


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selecao dos Dados                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function PrintReport(oReport, cAliasQry)
	
	Local oSection1  := oReport:Section(1)
	Local oSection2  := oReport:Section(2)
	Local oSection3  := oReport:Section(3)
	Local oSection4  := oReport:Section(4)
	Local nOrdem	:= oSection1:GetOrder()
	Local cQuery	:= ""
	Local cAliasQry	:= GetNextAlias()
	Local nRecno	:= 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01        //  Filial                                   ³
	//³ mv_par02        //  Centro de Custo                          ³
	//³ mv_par03        //  Matricula                                ³
	//³ mv_par04        //  Nome                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If oReport:Cancel()
		SET CENTURY ON
		Return
	EndIf
	
	cQuery := "SELECT R_E_C_N_O_ "
	cQuery += "FROM " + RetSqlName("PA4") + " "
	cQuery += "WHERE D_E_L_E_T_ = ' ' "
	cQuery += IIf(!Empty(mv_par01), "AND PA4_XFIL >= '" + mv_par01 + "' ", "")
	cQuery += IIf(!Empty(mv_par02), "AND PA4_XFIL <= '" + mv_par02 + "' ", "")
	cQuery += IIf(!Empty(mv_par03), "AND PA4_XCOD >= '" + mv_par03 + "' ", "")
	cQuery += IIf(!Empty(mv_par04), "AND PA4_XCOD <= '" + mv_par04 + "' ", "")
	cQuery += IIf(!Empty(mv_par05), "AND PA4_XDTIN >= '" + DTOS(mv_par05) + "' ", "")
	cQuery += IIf(!Empty(mv_par06), "AND PA4_XDTIN <= '" + DTOS(mv_par06) + "' ", "")
	cQuery += "ORDER BY "
	
	If nOrdem == 1
		cQuery += "PA4_XFIL"
	ElseIf nOrdem == 2
		cQuery += "PA4_XDTIN"
	ElseIf nOrdem == 3
		cQuery += "PA4_XMAT"
	ElseIf nOrdem == 4
		cQuery += "PA4_XPART"
	ElseIf nOrdem == 5
		cQuery += "PA4_XSTART"
	ElseIf nOrdem == 6
		cQuery += "PA4_XDTCO"
	Endif
	
	cQuery := ChangeQuery(cQuery)
			
	dbUseArea(.T., "TOPCONN", TCGenQry( ,,cQuery ), cAliasQry, .F., .T.)
	
	While !(cAliasQry)->(Eof())
	
		nRecno := (cAliasQry)->R_E_C_N_O_
		dbSelectArea("PA4")
		PA4->(dbGoTo(nRecno))
	
		oSection1:Init()
		oSection2:Init()
		oSection3:Init()
		oSection4:Init()
		
		oSection1:Cell("TMP_XDFIL"):SetValue(FWFilialName(,PA4->PA4_XFIL,))
		oSection1:Cell("TMP_XCOD"):SetValue(Posicione("RD5", 1, FWXFilial("RD5") + PA4->PA4_XCOD, "RD5_DESC"))
		
		oSection1:PrintLine()
		oSection2:PrintLine()
		oSection3:PrintLine()
		oSection4:PrintLine()
		        
        oReport:FatLine()
        
        oSection1:Finish()
		oSection2:Finish()
		oSection3:Finish()
		oSection4:Finish()
			
		(cAliasQry)->(dbSkip())
	
	End
	
Return
