#INCLUDE "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
#INCLUDE "FWMVCDEF.CH"

#DEFINE cHdSC7 ""
#DEFINE cItemSC7 ""

// Indica se a função SumDesc ou SumDesp foi chamada.
Static lFunSum := .F.

/*
{Protheus.doc} F0100401()
Geração Solicitação de Pagamentos - Req. ID_635
@Author     Mick William da Silva
@Since      29/04/2016
@Version    P12.7
@Project    MAN00000462901_EF_004
@Menu		Compras\Atualizações\Pedidos\solicitações de Pagamento
*/
User Function F0100401()
	Local oBrw 	   := FwMBrowse():New()
	Local aColunas := {}
	Local cSoliPag := Alltrim(SuperGetMV('FS_SOLIPAG', .F., ""))
	Local cUserP32 := ""
	Local cGrupo
	Local aUsersP32 := {}
	Local nX := 01
	Local nY := 01
	Local cFiltro := ""
	Local cFils := ""
	Local cFiltroRP := " "
	Local aSeek := {}
	Local cQuery := ""
	Local cAliasP32 := GetNextAlias()

	Public __xxFiltro := ""
	Public __oBrw2 := NIL


	Private aHeader // ticket n° 9081027
	Private aCols   // ticket n° 9081027
	Private dDtBKP := ""//Lucas Miranda de Aguiar - Melhoria data Fixa
	Private lChange := .F.
	Private lCancel := .F.
	private lFilSimp := U_VALSIMP(cFilant)


	if lFilSimp
		SETFUNNAME("S0100401")
		U_S0100401()
		SETFUNNAME("F0100401")
		Return
	endif

	oBrw:SetDescription("Solicitação de Pagamentos")
	oBrw:SetAlias("SC7")
	oBrw:SetMenuDef("F0100401")

	//Validação do Grupo de Solicitação de Pagamentos.
	P32->(DBSetOrder(2)) //P32_FILIAL+P32_CODUSU+P32_CODEQP
	IF P32->(DBSeek(xFilial("P32")+__CUSERID)) .And. P32->P32_BLQUSU == "N" //Usuário Bloqueado
		/*/cSeek := xFilial("P32")+P32->P32_CODEQP
		P32->(DBSetOrder(1)) //P32_FILIAL+P32_CODEQP+P32_CODUSU
		P32->(DBSeek(cSeek))
		While !P32->(Eof()) .And. cSeek == P32->P32_FILIAL+P32->P32_CODEQP
			IF P32->P32_BLQUSU == "N" //Usuário Bloqueado
				cUserP32 += IIF(!Empty(cUserP32),"|"+P32->P32_CODUSU,P32->P32_CODUSU)
			Endif
			P32->(DBSkip())
		Enddo/*/
			/*/cQuery += " WITH partitioned_data AS (                                                                              "
			cQuery += "     SELECT                                                                                              "
			cQuery += "         'SC7.C7_XUSR = ''' || P32_CODUSU || '''' AS condition,                                       "
			cQuery += "         CEIL(ROW_NUMBER() OVER (ORDER BY P32_CODUSU) / 500) AS part                                     "
			cQuery += "     FROM " + RetSqlname("P32")
			cQuery += "     WHERE D_E_L_E_T_ = ' '  AND P32_BLQUSU = 'N'                                                        "
			cQuery += "      AND P32_CODEQP = '"+P32->P32_CODEQP+"' 															"
			cQuery += "     GROUP BY P32_CODUSU                                                                                 "
			cQuery += " ),                                                                                                      "
			cQuery += " concatenated_parts AS (                                                                                 "
			cQuery += "     SELECT                                                                                              "
			cQuery += "         part,                                                                                           "
			cQuery += "         TO_CLOB(LISTAGG(condition, ' OR ') WITHIN GROUP (ORDER BY condition)) AS partial_result         "
			cQuery += "     FROM partitioned_data                                                                               "
			cQuery += "     GROUP BY part                                                                                       "
			cQuery += " ),                                                                                                      "
			cQuery += " final_result AS (                                                                                       "
			cQuery += "     SELECT                                                                                              "
			cQuery += "         '(' || LISTAGG(partial_result, ' OR ') WITHIN GROUP (ORDER BY part) || ')' AS resultado_clob    "
			cQuery += "     FROM concatenated_parts                                                                             "
			cQuery += " )                                                                                                       "
			cQuery += " SELECT resultado_clob                                                                                   "
			cQuery += " FROM final_result/*/
			cQuery += " WITH partitioned_data AS (                                                                                                          "
			cQuery += "    SELECT                                                                                                                           "
			cQuery += "        P32_CODUSU AS codusu,                                                                                                        "
			cQuery += "        CEIL(ROW_NUMBER() OVER (ORDER BY P32_CODUSU) / 10) AS part                                                                   "
			cQuery += "     FROM " + RetSqlname("P32")
			cQuery += "    WHERE D_E_L_E_T_ = ' '  AND P32_BLQUSU = 'N'                                                                                     "
			cQuery += "      AND P32_CODEQP = '"+P32->P32_CODEQP+"' 																						"
			cQuery += "    GROUP BY P32_CODUSU                                                                                                              "
			cQuery += " ),                                                                                                                                  "
			cQuery += " concatenated_parts AS (                                                                                                             "
			cQuery += "    SELECT                                                                                                                           "
			cQuery += "        part,                                                                                                                        "
			cQuery += "        'SC7.C7_XUSR IN (' || LISTAGG('''' || codusu || '''', ',') WITHIN GROUP (ORDER BY codusu) || ')' AS partial_result           "
			cQuery += "    FROM partitioned_data                                                                                                            "
			cQuery += "    GROUP BY part                                                                                                                    "
			cQuery += " ),                                                                                                                                  "
			cQuery += " final_result AS (                                                                                                                   "
			cQuery += "    SELECT                                                                                                                           "
			cQuery += "        LISTAGG(partial_result, ' OR ') WITHIN GROUP (ORDER BY part) AS resultado_clob                                               "
			cQuery += "    FROM concatenated_parts                                                                                                          "
			cQuery += " )                                                                                                                                   "
			cQuery += " SELECT '(' || resultado_clob || ')' AS resultado_clob                                                                               "
			cQuery += " FROM final_result																													"

			DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAliasP32, .T., .T.)

			cUserP32 := (cAliasP32)->(resultado_clob)

			(cAliasP32)->(DbCloseArea())
		Endif

		cFiltro := " R_E_C_N_O_ IN ( SELECT " + CRLF
		cFiltro += " SC7.R_E_C_N_O_ " + CRLF
		cFiltro += " FROM " + CRLF
		cFiltro += RetSQLName("SC7") + " SC7 " + CRLF
		cFiltro += " WHERE SC7.C7_XSOLPAG = '1' AND SC7.D_E_L_E_T_ = ' ' " + CRLF

		IF !Empty(cSoliPag) .And. __CUSERID $ cSoliPag
			oBrw:SetFilterDefault("C7_XSOLPAG == '1'")
		Elseif !Empty(cUserP32)
			cFils := "()"//fGetFils(cUserP32)
			If AllTrim(cFils) == "()"
				cFils := " SC7.C7_FILIAL <> ' ' "
			EndIf
			If U_fVldRmed()
				cFiltro += " AND "+cUserP32+ CRLF
				cFiltro += " AND "+cFils + CRLF
				cFiltro += " AND ( SC7.C7_XREPMED = ' ' OR SC7.C7_XREPMED = '1' OR SC7.C7_XREPMED = '2' OR SC7.C7_XREPMED = '3') " + CRLF
				cFiltro += " ) "
			Else
				cFiltro += " AND "+cUserP32+ CRLF
				cFiltro += " AND "+cFils + CRLF
				cFiltro += " AND ( SC7.C7_XREPMED = ' ' OR SC7.C7_XREPMED = '1' ) " + CRLF
				cFiltro += " ) "
			EndIf
			oBrw:SetFilterDefault( "@"  + cFiltro )


		Else
			cFils := "()"//fGetFils(" SC7.C7_XUSR = '" +__CUSERID+"' ")
			If AllTrim(cFils) == "()"
				cFils := " SC7.C7_FILIAL <> ' ' "
			EndIf
			cFiltro += " AND SC7.C7_XUSR = '"+__CUSERID+"'" + CRLF
			cFiltro += " AND " + cFils  + CRLF
			cFiltro += " AND ( SC7.C7_XREPMED = ' ' OR SC7.C7_XREPMED = '1' OR SC7.C7_XREPMED = '2' OR SC7.C7_XREPMED = '3') " + CRLF
			cFiltro += " ) " + CRLF
			oBrw:SetFilterDefault( "@"  + cFiltro )
		Endif

		//Incrementa coluna no browse
		AAdd(aColunas, {"Numero", "C7_NUM", "C", 6, 0, "@!"})


		oBrw:SetFields(aColunas)

	/*
	oBrw:AddLegend("C7_CONAPRO == 'B' .And. C7_QUJE < C7_QUANT", "BR_AZUL"	 , "Em aprovação"             )
	oBrw:AddLegend("C7_QTDACLA > 0 .AND. C7_CONAPRO = 'L'"							   , "BR_LARANJA", "Em recebimento (Pré-nota)")
	oBrw:AddLegend("C7_QUJE >= C7_QUANT .AND. C7_CONAPRO <> 'R'"					   , "DISABLE"	 , "Recebido"                 )
	oBrw:AddLegend("C7_QUJE == 0 .And. C7_QTDACLA == 0 .AND. C7_CONAPRO = 'L' .AND. !U_FRecSF1()"		   , "ENABLE"	 , "Pendente"                 ) // Aqui está o problema, está é legenda com problema

	oBrw:AddLegend("C7_CONAPRO == 'R' .And. C7_QUJE < C7_QUANT", "BR_CANCEL"	 , "Recusa Por Alcada"             )
	oBrw:AddLegend("C7_QUJE == 0 .And. C7_QTDACLA == 0 .AND. C7_CONAPRO = 'L' .AND. U_FRecSF1()", "BR_PINK"	 , "Recusa Doc. Entrada"             )

	oBrw:AddLegend("C7_QUJE >= 0 C7_QUANT .And. C7_QTDACLA == 0 .AND. C7_CONAPRO = 'L' .AND. C7_ENCER='E' .AND. U_FRecSE2()", "BR_PRETO"	 , "Recusa Contas a Pagar"             )
	*/
		// ID 1537
		oBrw:AddLegend("C7_XERLEG =.T. ", "BR_VERDE_ESCURO" 	, "Erro Geração Pré-Nota")

		oBrw:AddLegend("C7_CONAPRO == 'B' .And. C7_QUJE < C7_QUANT  ", "BR_AZUL" 	         				, "Em aprovação")
		//oBrw:AddLegend("C7_QTDACLA > 0 .AND. C7_CONAPRO = 'L' .AND. !U_FRecSF1()"        				, "BR_LARANJA", "Em recebimento (Pré-nota)")
		oBrw:AddLegend("C7_QTDACLA > 0 .AND. C7_CONAPRO = 'L' .AND. !U_SRecSF1()"        				, "BR_LARANJA", "Em recebimento (Pré-nota)")
		//	oBrw:AddLegend("C7_QUJE >= C7_QUANT .AND. C7_CONAPRO <> 'R' .AND. !U_FRecSE2()"	 , "DISABLE"	, "Recebido"                 )
		//oBrw:AddLegend("C7_QUJE >= C7_QUANT .AND. C7_CONAPRO <> 'R' "	 , "DISABLE"	, "Recebido")
		oBrw:AddLegend("C7_QUJE >= C7_QUANT .AND. C7_CONAPRO <> 'R' .AND. !U_FRecMat() "	 , "DISABLE"	, "Recebido")

		//oBrw:AddLegend("C7_QUJE == 0 .And. C7_QTDACLA == 0 .AND. C7_CONAPRO = 'L' .AND. !U_FRecSF1()"	, "ENABLE"	 , "Pendente") // Aqui está o problema, está é legenda com problema
		oBrw:AddLegend("C7_QUJE == 0 .And. C7_QTDACLA == 0 .AND. C7_CONAPRO = 'L' .AND. !U_SRecSF1() .And. !U_FRecMat()"	, "ENABLE"	 , "Pendente"                 ) // Aqui está o problema, está é legenda com problema

		oBrw:AddLegend("C7_CONAPRO == 'R' .And. C7_QUJE < C7_QUANT", "BR_PINK" 					, "Recusa Por Alcada")
		//oBrw:AddLegend("C7_QTDACLA > 0 .AND. C7_CONAPRO = 'L' .AND. U_FRecSF1()","BR_CANCEL"	 	 			, "Recusa Doc. Entrada")

		oBrw:AddLegend("(C7_QTDACLA > 0 .AND. C7_CONAPRO = 'L' .AND. U_SRecSF1()) .Or. U_FRecMat()","BR_CANCEL"	 	 			, "Recusa Doc. Entrada"             )
		//Simplificada
		oBrw:AddLegend("U_FRecCap(C7_XTPSP, C7_CONAPRO)", "BR_AMARELO"	 , "Recusa Pagamento"             )
		// FIM ID 1537

		// Novo retira recusa CP
		//	oBrw:AddLegend("C7_QUJE >= 0 .And. C7_QTDACLA == 0 .AND. C7_CONAPRO = 'L' .AND. C7_ENCER='E' .AND. U_FRecSE2()", "BR_PRETO"	 , "Recusa Contas a Pagar"             )
		__xxFiltro := cFiltro
		__oBrw2 := oBrw
		oBrw:Activate()

		Return

Static Function MenuDef()
	Local cAltSolic := Alltrim(SuperGetMV('FS_EQUIPE', .F., ""))
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Pesquisar"  ACTION "VIEWDEF.F0100401" OPERATION 1  ACCESS 0 // Pesquisar
	//ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.F0100401" OPERATION 2  ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE "Visualizar" ACTION "U_xFILSF(1)" OPERATION 2  ACCESS 0 // Visualizar
	//ADD OPTION aRotina TITLE "Incluir"	  ACTION "VIEWDEF.F0100401" OPERATION 3  ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE "Incluir"	  ACTION "U_xFILSF(3)" OPERATION 3  ACCESS 0 // Incluir
	//ADD OPTION aRotina TITLE "Alterar"	  ACTION "VIEWDEF.F0100401" OPERATION 4  ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE "Alterar"	  ACTION "U_xFILSF(4)" OPERATION 4  ACCESS 0 // Alterar
	//ADD OPTION aRotina TITLE "Excluir"	  ACTION "VIEWDEF.F0100401" OPERATION 5  ACCESS 0 // Excluir
	ADD OPTION aRotina TITLE "Excluir"	  ACTION "U_xFILSF(5)" OPERATION 5  ACCESS 0

	//Verifica se o usuário tem acesso para alterar o solicitante.
	If !(Empty(cAltSolic)) .And. __cUserId $ cAltSolic
		ADD OPTION aRotina TITLE "Alterar Solicitante" ACTION "U_F0100414"     OPERATION 5  ACCESS 0 //Alterar Solicitante
	EndIf
	if lFilSimp
		ADD OPTION aRotina TITLE "Upload de SP's" ACTION "U_XRDCAR99"     OPERATION 3  ACCESS 0 //Carga de SP's
	else
		ADD OPTION aRotina TITLE "Upload de SP's" ACTION "U_RDCAR99"     OPERATION 3  ACCESS 0 //Carga de SP's
	endif

	aRotina := U_F0400104(aRotina)  //Adiciona Opções do Banco de Conhecimento.
	//ADD OPTION aRotina TITLE "Imprime Recusas" ACTION 'MsgRun("Gerando relatório...", "Rel. Recusas", {||U_F0100REC() })'     OPERATION 3  ACCESS 0

Return aRotina
/*/{Protheus.doc} xFILSF
Rotina responsável por mudar o modelo simplificado ou full.
@type function
@version  P12
@author Ricardo Junior
@since 4/1/2025
@param nOper, numeric, param_description
@return variant, return_description
/*/
User Function xFILSF(nOper)
	Local lFilSimp := U_VALSIMP(cFilAnt)
	Local aAreas := { SC7->(GetArea()) }

	If lFilSimp
		SetFunName("S0100401")
		FWExecView('SIMPLIFICADO', 'S0100401', nOper,,,,,,{|| .T. })
		SetFunName("F0100401")
		//AEval( aAreas, {|aArea| RestArea(aArea)})
	else
		SetFunName("F0100401")
		FWExecView('FULL', 'F0100401', nOper,,,,,,{|| .T. })
		SetFunName("S0100401")
		//AEval( aAreas, {|aArea| RestArea(aArea)})
	endif
Return

/*{Protheus.doc} ModelDef
Definição do modelo de Dados
@author		Mick William da Silva
@since		29/04/2016
@version	P12.7
@Project	MAN00000462901_EF_004
*/
Static Function ModelDef()

	// Cria as estruturas a serem utilizadas no Modelo de Dados.
	Local oStruSC7	:= FwFormStruct(1, "SC7", {|x| AllTrim(x) + "|" $ cItemSC7})
	Local oStruSC7p	:= FWFormStruct(1, "SC7", {|x| AllTrim(x) + "|" $ cHdSC7  })
	Local oStruSC7r	:= FWFormStruct(1, "SC7", {|x| AllTrim(x) + "|" $ cHdSC7  })

	// Cria o objeto do Modelo de Dados
	Local oModel 	 := MpFormModel():New("M0100401",{|oModel| IsOpenModel(oModel)} , {|oModel| IsValidModel(oModel)}, {|oModel| SaveModel(oModel)}, {|oModel| CancelModel(oModel)})
	Local cVldForn	 := "Empty(M->C7_FORNECE) .Or. ExistCpo('SA2', M->C7_FORNECE)             "
	Local cVldLoja	 := "Empty(M->C7_LOJA)    .Or. ExistCpo('SA2', M->C7_FORNECE + M->C7_LOJA)"
	Local cVldCond	 := "(Empty(M->C7_COND)    .Or. ExistCpo('SE4', M->C7_COND))  .And. U_fchkcond()            "
	Local cVldXTipo	 := "Empty(M->C7_XTIPO)   .Or. U_ValidaP02()"
	Local cVldXEsp	 := "Empty(M->C7_XESPECI) .Or. ExistCpo('SX5', '42' + M->C7_XESPECI)      "
	Local cVldXDtEmi := "Empty(M->C7_XDTEMI)  .Or. M->C7_XDTEMI <= DDATABASE                  "
	Local cVldXDtVen := "Empty(M->C7_XDTVEN)  .Or. U_F0100412()                               "
	//Local cVldXDtFix := "U_VALFNFIX()                              "
	Local cVldProd	 := "Empty(M->C7_PRODUTO) .Or. ExistCpo('SB1', M->C7_PRODUTO)             "
	Local cVldCC	 := "Empty(M->C7_CC)      .Or. ExistCpo('CTT', M->C7_CC)                  "
	Local cVldUM	 := "Empty(M->C7_UM)      .Or. ExistCpo('SAH', M->C7_UM)                  "
	Local cVldLocal	 := "Empty(M->C7_LOCAL)   .Or. ExistCpo('NNR', M->C7_LOCAL)               "
	Local cVldXDoc	 := "Empty(M->C7_XDOC)    .Or. U_TrataXDoc()                              "
	Local cVldXSerie := "U_TrataXSer()"
	Local cVldPlan   := "U_fValR2()"
	Local aTrigCond	 :=	FwStruTrigger("C7_COND"   , "C7_CONDD" , "SE4->E4_DESCRI"	                   , .T., "SE4",  01, "xFilial('SE4') + M->C7_COND"   , )
	Local aTrigVenc  :=	FwStruTrigger("C7_XDTEMI" , "C7_XDTVEN", "U_F0100411(M->C7_XDTEMI, M->C7_COND)", .T., "SE4",  01, "xFilial('SE4') + M->C7_COND"   , )
	Local aTrigTipo	 :=	FwStruTrigger("C7_XTIPO"  , "C7_XTIPOD", "P02->P02_DESC"	                   , .T., "P02",  01, "xFilial('P02') + M->C7_XTIPO"  , )
	Local aTrigTipo2 := FwStruTrigger("C7_XTIPO"  , "C7_XTIPOD", "U_FRETENC()"	                       , .T., "P02",  01, "xFilial('P02') + M->C7_XTIPO"  , )
	Local aTrigTipo3 := FwStruTrigger("C7_XTIPO"  , "C7_XNUMPRO","U_fVLDJUR1()"	                       , .T., "P02",  01, "xFilial('P02') + M->C7_XTIPO"  , )
	Local aTrigTipo4 := FwStruTrigger("C7_XTIPO"  , "C7_XTPCJU", "U_fVLDJUR1()"	                       , .T., "P02",  01, "xFilial('P02') + M->C7_XTIPO"  , )
	Local aTrigProd1 :=	FwStruTrigger("C7_PRODUTO", "C7_UM"    , "SB1->B1_UM"		                   , .T., "SB1",  01, "xFilial('SB1') + M->C7_PRODUTO", )
	Local aTrigProd2 :=	FwStruTrigger("C7_PRODUTO", "C7_DESCRI", "SB1->B1_DESC"	                       , .T., "SB1",  01, "xFilial('SB1') + M->C7_PRODUTO", )
	Local aTrigProd3 :=	FwStruTrigger("C7_PRODUTO", "C7_LOCAL" , "U_F0100413()"                        , .F.,      ,    ,                                 , )
	Local nOper		 := oModel:GetOperation()
	Local aGrps := UsrRetGrp()
	Local nX := 1


	// Adiciona os campos no Cabeçalho.
	oStruSC7p:AddField("C7_NUM"    , "C7_NUM"    , "C7_NUM"    , "C", TamSX3("C7_NUM"    )[01], TamSX3("C7_NUM"    )[02],                                                 , , , .T., {|| GetSX8Num("SC7", "C7_NUM")}                                                      , .F., .F., .F., )
	oStruSC7p:AddField("C7_EMISSAO", "C7_EMISSAO", "C7_EMISSAO", "D", TamSX3("C7_EMISSAO")[01], TamSX3("C7_EMISSAO")[02],                                                 , , , .T., {|| dDataBase}                                                                       , .F., .F., .F., )
	oStruSC7p:AddField("C7_FORNECE", "C7_FORNECE", "C7_FORNECE", "C", TamSX3("C7_FORNECE")[01], TamSX3("C7_FORNECE")[02], FWBuildFeature(STRUCT_FEATURE_VALID, cVldForn  ), , , .T.,                                                                                      , .F., .F., .F., )
	oStruSC7p:AddField("C7_LOJA"   , "C7_LOJA"   , "C7_LOJA"   , "C", TamSX3("C7_LOJA"   )[01], TamSX3("C7_LOJA"   )[02], FWBuildFeature(STRUCT_FEATURE_VALID, cVldLoja  ), , , .T.,                                                                                      , .F., .F., .F., )
	oStruSC7p:AddField("C7_COND"   , "C7_COND"   , "C7_COND"   , "C", TamSX3("C7_COND"   )[01], TamSX3("C7_COND"   )[02], FWBuildFeature(STRUCT_FEATURE_VALID, cVldCond  ), , , .T.,                                                                                      , .F., .F., .F., )
	oStruSC7p:AddField("C7_CONDD"  , "C7_CONDD"  , "C7_CONDD"  , "C", TamSX3("E4_DESCRI" )[01], TamSX3("E4_DESCRI" )[02],                                                 , , , .F., {|| GetDescrip(oModel, cFilAnt, "C7_COND", "SE4", "E4_DESCRI")}                      , .F., .F., .T., )
	oStruSC7p:AddField("C7_XTIPO"  , "C7_XTIPO"  , "C7_XTIPO"  , "C", TamSX3("C7_XTIPO"  )[01], TamSX3("C7_XTIPO"  )[02], FWBuildFeature(STRUCT_FEATURE_VALID, cVldXTipo ), , , .T.,                                                                                      , .F., .F., .F., )
	oStruSC7p:AddField("C7_XTIPOD" , "C7_XTIPOD" , "C7_XTIPOD" , "C", TamSX3("P02_DESC"  )[01], TamSX3("P02_DESC"  )[02],                                                 , , , .F., {|| GetDescrip(oModel, cFilAnt, "C7_XTIPO", "P02", "P02_DESC")}                      , .F., .F., .T., )
	oStruSC7p:AddField("C7_XESPECI", "C7_XESPECI", "C7_XESPECI", "C", TamSX3("C7_XESPECI")[01], TamSX3("C7_XESPECI")[02], FWBuildFeature(STRUCT_FEATURE_VALID, cVldXEsp  ), , , .T.,                                                                                      , .F., .F., .F., )
	oStruSC7p:AddField("C7_XDOC"   , "C7_XDOC"   , "C7_XDOC"   , "C", TamSX3("C7_XDOC"   )[01], TamSX3("C7_XDOC"   )[02], FWBuildFeature(STRUCT_FEATURE_VALID, cVldXDoc  ), , , .T.,                                                                                      , .F., .F., .F., )
	oStruSC7p:AddField("C7_XSERIE" , "C7_XSERIE" , "C7_XSERIE" , "C", TamSX3("C7_XSERIE" )[01], TamSX3("C7_XSERIE" )[02], FWBuildFeature(STRUCT_FEATURE_VALID, cVldXSerie), , , .T.,                                                                                      , .F., .F., .F., )
	oStruSC7p:AddField("C7_XDTEMI" , "C7_XDTEMI" , "C7_XDTEMI" , "D", TamSX3("C7_XDTEMI" )[01], TamSX3("C7_XDTEMI" )[02], FWBuildFeature(STRUCT_FEATURE_VALID, cVldXDtEmi), , , .T.,                                                                                      , .F., .F., .F., )
	oStruSC7p:AddField("C7_XDTVEN" , "C7_XDTVEN" , "C7_XDTVEN" , "D", TamSX3("C7_XDTVEN" )[01], TamSX3("C7_XDTVEN" )[02], FWBuildFeature(STRUCT_FEATURE_VALID, cVldXDtVen), , , .T.,                                                                                      , .F., .F., .F., )
	oStruSC7p:AddField("C7_XRETENC","C7_XRETENC" ,"C7_XRETENC" , "C", TamSX3("C7_XRETENC")[01], TamSX3("C7_XRETENC")[02], 											      , , , .F.,																					  , .F., .F., .F., )//Lucas Miranda de Aguiar
	oStruSC7p:AddField("C7_XDTEXCE","C7_XDTEXCE" ,"C7_XDTEXCE" , "C", 						 3,          			   3, , , , .F.,																					  , .F., .F., .F., )//Lucas Miranda de Aguiar
	oStruSC7p:AddField("C7_XDBAUT","C7_XDBAUT" ,"C7_XDBAUT"    , "C",TamSX3("C7_XDBAUT")[01],TamSX3("C7_XDBAUT")[02], , , , .F.,																					  , .F., .F., .F., )//Lucas Miranda de Aguiar


	//Melhorias processo Juridico
	oStruSC7p:AddField("C7_XNUMPRO","C7_XNUMPRO" ,"C7_XNUMPRO" , "C", TamSX3("C7_XNUMPRO")[01], TamSX3("C7_XNUMPRO")[02],   , , , .F.,																					  , .F., .F., .F., )
	oStruSC7p:AddField("C7_XTPCJU","C7_XTPCJU" ,"C7_XTPCJU" , "C", 	TamSX3("C7_XTPCJU")[01], TamSX3("C7_XTPCJU")[02], , , , .F.,																					  , .F., .F., .F., )

	//Melhorias repasse médico
	oStruSC7p:AddField("C7_XREPMED","C7_XREPMED" ,"C7_XREPMED" , "C", TamSX3("C7_XREPMED")[01], TamSX3("C7_XREPMED")[02],   , , , .F.,																					  , .F., .F., .F., )
	oStruSC7p:AddField("C7_XPLANRE","C7_XPLANRE" ,"C7_XPLANRE" , "C", TamSX3("C7_XPLANRE")[01], TamSX3("C7_XPLANRE")[02], FWBuildFeature(STRUCT_FEATURE_VALID, cVldPlan)  , , , .F.,																					  , .F., .F., .F., )
	oStruSC7p:AddField("C7_XRETINS","C7_XRETINS" ,"C7_XRETINS" , "C", TamSX3("C7_XRETINS")[01], TamSX3("C7_XRETINS")[02],   , , , .F.,																					  , .F., .F., .F., )

	// Adiciona gatilhos ao cabeçalho.
	//oStruSC:AddTrigger(cField      , cTargetField, bPre        , bSetValue   )
	oStruSC7p:AddTrigger(aTrigCond[1], aTrigCond[2], aTrigCond[3], aTrigCond[4])
	oStruSC7p:AddTrigger(aTrigVenc[1], aTrigVenc[2], aTrigVenc[3], aTrigVenc[4])
	oStruSC7p:AddTrigger(aTrigTipo[1], aTrigTipo[2], aTrigTipo[3], aTrigTipo[4])
	oStruSC7p:AddTrigger(aTrigTipo2[1], aTrigTipo2[2], aTrigTipo2[3], aTrigTipo2[4])
	oStruSC7p:AddTrigger(atrigTipo3[1], atrigTipo3[2], atrigTipo3[3], atrigTipo3[4])
	oStruSC7p:AddTrigger(atrigTipo4[1], atrigTipo4[2], atrigTipo4[3], atrigTipo4[4])
	//oStruSC7p:AddTrigger(aTrigDtFix[1], aTrigDtFix[2], aTrigDtFix[3], aTrigDtFix[4])
	//oStruSC7p:AddTrigger(aTrigfFor1[1], aTrigfFor1[2], aTrigfFor1[3], aTrigfFor1[4])
	// Adiciona os campos ao grid.
	//oStruSC7:AddField("C7_ITEM", "C7_ITEM", "C7_ITEM", "C", 4, nDecimal, bValid, bWhen, aValues, lObrigat, bInit, lKey.F., lNoUpd.F., lVirtual.F., cValid)
	oStruSC7:AddField("C7_ITEM"   , "C7_ITEM"   , "C7_ITEM"   , "C", TamSX3("C7_ITEM"   )[01], TamSX3("C7_ITEM"   )[02],                                                                           , , ,    ,                      , .F., .F., .F., )
	oStruSC7:AddField("C7_PRODUTO", "C7_PRODUTO", "C7_PRODUTO", "C", TamSX3("C7_PRODUTO")[01], TamSX3("C7_PRODUTO")[02], FWBuildFeature(STRUCT_FEATURE_VALID, cVldProd)                            , , ,    ,                      , .F., .F., .F., )
	oStruSC7:AddField("C7_DESCRI" , "C7_DESCRI" , "C7_DESCRI" , "C", TamSX3("C7_DESCRI" )[01], TamSX3("C7_DESCRI" )[02],                                                                           , , ,    ,                      , .F., .F., .T., )
	oStruSC7:AddField("C7_UM"     , "C7_UM"     , "C7_UM"     , "C", TamSX3("C7_UM"     )[01], TamSX3("C7_UM"     )[02], FWBuildFeature(STRUCT_FEATURE_VALID, cVldUM)                              , , ,    ,                      , .F., .F., .F., )
	oStruSC7:AddField("C7_QUANT"  , "C7_QUANT"  , "C7_QUANT"  , "N", TamSX3("C7_QUANT"  )[01], TamSX3("C7_QUANT"  )[02], {|| SumProd(oModel)}                                                      , , ,    ,                      , .F., .F., .F., )
	oStruSC7:AddField("C7_PRECO"  , "C7_PRECO"  , "C7_PRECO"  , "N", TamSX3("C7_PRECO"  )[01], TamSX3("C7_PRECO"  )[02], {|| SumProd(oModel)}                                                      , , ,    ,                      , .F., .F., .F., )
	oStruSC7:AddField("C7_TOTAL"  , "C7_TOTAL"  , "C7_TOTAL"  , "N", TamSX3("C7_TOTAL"  )[01], TamSX3("C7_TOTAL"  )[02],                                                                           , , ,    , {|| TotValue(oModel)}, .F., .F., .F., )
	oStruSC7:AddField("C7_LOCAL"  , "C7_LOCAL"  , "C7_LOCAL"  , "C", TamSX3("C7_LOCAL"  )[01], TamSX3("C7_LOCAL"  )[02], FWBuildFeature(STRUCT_FEATURE_VALID, cVldLocal)                           , , ,    ,                      , .F., .F., .F., )
	oStruSC7:AddField("C7_OBS"    , "C7_OBS"    , "C7_OBS"    , "C", TamSX3("C7_OBS"    )[01], TamSX3("C7_OBS"    )[02],                                                                           , , ,    ,                      , .F., .F., .F., )
	oStruSC7:AddField("C7_CC"     , "C7_CC"     , "C7_CC"     , "C", TamSX3("C7_CC"     )[01], TamSX3("C7_CC"     )[02], FWBuildFeature(STRUCT_FEATURE_VALID, cVldCC)                              , , , .T.,                      , .F., .F., .F., )
	oStruSC7:AddField("C7_XJURMUL", "C7_XJURMUL", "C7_XJURMUL", "N", TamSX3("C7_XJURMUL")[01], TamSX3("C7_XJURMUL")[02],                                                                           , , ,    ,                      , .F., .F., .F., )
	oStruSC7:AddField("C7_XDESFIN", ""          , "C7_XDESFIN", "N", TamSX3("C7_XDESFIN")[01], TamSX3("C7_XDESFIN")[02], 													                       , , ,    ,                      , .F., .F., .F., )
	oStruSC7:AddField("C7_XMULTA" , "C7_XMULTA" , "C7_XMULTA" , "N", TamSX3("C7_XMULTA")[01] , TamSX3("C7_XMULTA" )[02],                                                                           , , ,    ,                      , .F., .F., .F., )

	// Novo Campo
	oStruSC7:AddField("C7_XERAUT" , "C7_XERAUT" , "C7_XERAUT" , "M", TamSX3("C7_XERAUT" )[01], TamSX3("C7_XERAUT" )[02], , , , .F.,                                                                                      , .F., .F., .F., )

	// ticket n° 10326179 -- novo campo Tx Expediente
	oStruSC7:AddField("C7_XTXEXPE", "C7_XTXEXPE", "C7_XTXEXPE", "N", TamSX3("C7_XTXEXPE")[01], TamSX3("C7_XTXEXPE" )[02],                                                                           , , ,   ,                      , .F., .F., .F., )
	oStruSC7:AddField("C7_ZINTOGY", "C7_ZINTOGY", "C7_ZINTOGY", "C", TamSX3("C7_ZINTOGY")[01], TamSX3("C7_ZINTOGY" )[02],       		              												,{|| .F.} , ,   ,                      , .F., .F., .F., )
	oStruSC7:AddField("C7_ZIDONGY", "C7_ZIDONGY", "C7_ZIDONGY", "C", TamSX3("C7_ZIDONGY")[01], TamSX3("C7_ZIDONGY" )[02], 		                     												,{|| .F.} , ,   ,                      , .F., .F., .F., )

	// Adiciona gatilhos ao grid.
	//oStruSC7:AddTrigger( cIdField, cTargetIdField,  bPre ,  bSetValue )
	oStruSC7:AddTrigger( aTrigProd1[1] , aTrigProd1[2] , aTrigProd1[3] , aTrigProd1[4]  )
	oStruSC7:AddTrigger( aTrigProd2[1] , aTrigProd2[2] , aTrigProd2[3] , aTrigProd2[4]  )
	oStruSC7:AddTrigger( aTrigProd3[1] , aTrigProd3[2] , aTrigProd3[3] , aTrigProd3[4]  )

	// Adiciona os campos do Rodapé.
	oStruSC7r:AddField("C7_TOTSOL" , "C7_TOTSOL" , "C7_TOTSOL" , "N", 18, 4,                                                            ,        , , , {|| /*TotSolPagt(oModel)*/ SumMerc(oModel)}                       , .F., .F., .T., )

	// Adiciona ao modelo um componente de formulário
	oModel:AddFields("MODEL_SC7p", , oStruSC7p)

	// Adiciona ao modelo uma grid
	oModel:AddGrid("MODEL_SC7", "MODEL_SC7p", oStruSC7)

	oModel:GetModel("MODEL_SC7"):SetOptional(.T.)
	oModel:GetModel("MODEL_SC7"):SetUniqueLine({"C7_ITEM", "C7_PRODUTO"})
	oModel:SetRelation("MODEL_SC7", {{"C7_FILIAL", "xFilial('SC7')"}, {"C7_NUM", "C7_NUM"}}, SC7->(IndexKey(1)))

	oModel:GetModel("MODEL_SC7p"):SetPrimaryKey({"C7_FILIAL", "C7_NUM", "C7_ITEM"})

	// Adiciona a estrutura do rodapé ao modelo
	oModel:AddFields("MODEL_SC7r", "MODEL_SC7p", oStruSC7r)
	oModel:SetDescription("Solicitação de Pagamentos")

	//Permite alteracao nos campos Fornecedor e Loja somente na inclusao.
	if !FWIsInCallStack("U_RDCAR99")
		oStruSC7p:SetProperty("C7_FORNECE", MODEL_FIELD_WHEN, {|| IIF(oModel:GetOperation() == 3, .T., .F.) })
		oStruSC7p:SetProperty("C7_LOJA"   , MODEL_FIELD_WHEN, {|| IIF(oModel:GetOperation() == 3, .T., .F.) })

		oStruSC7p:SetProperty("C7_XDTVEN" , MODEL_FIELD_WHEN, {|| U_fValdFix() })
		oStruSC7p:SetProperty("C7_XDTEXCE" , MODEL_FIELD_WHEN, {|| U_fVldEx() })

		oStruSC7p:SetProperty("C7_XNUMPRO" , MODEL_FIELD_WHEN, {|oModel| U_fVldJur2(oModel) })
		oStruSC7p:SetProperty("C7_XTPCJU" , MODEL_FIELD_WHEN, {|oModel| U_fVldJur2(oModel) })
		oStruSC7p:SetProperty("C7_XREPMED" , MODEL_FIELD_WHEN, {|| u_fvldrmed() })
		oStruSC7p:SetProperty("C7_XPLANRE" , MODEL_FIELD_WHEN, {|| u_fvldrmed() })
		oStruSC7p:SetProperty("C7_XDBAUT" , MODEL_FIELD_WHEN, {|| u_fxdbaut1() })
		oStruSC7:SetProperty("C7_XTXEXPE" , MODEL_FIELD_WHEN, {|| .F.})
		For nX := 01 To Len(aGrps)
			If aGrps[nX] $ GetNewPar("FS_XTXEXP","000000")
				oStruSC7:SetProperty("C7_XTXEXPE" , MODEL_FIELD_WHEN, {|| .T.})
				Exit
			EndIf
		Next nX
	endif

	oModel:SetVldActivate({|oModel| U_F0100410(oModel)})

Return oModel

/*{Protheus.doc} F0100410
Validação na alteração/exclusão da solicitação.
@Author Nairan Alves Silva
@Since 17/12/2016
@Version P12.7
@Project	MAN00000462901_EF_004
@param oModel, object, descricao
@Return lREt = True or False
*/
User Function F0100410(oModel)

	Local aAreas     := { SAJ->(GetArea()),P02->(GetArea()),SY1->(GetArea()), SC7->(GetArea()), GetArea() }
	Local nOper		 := oModel:GetOperation()
	Local cComprador := ""
	Local lRet       := .T.
	Local lSolic     := .T.
	Local lRestPed   := .T.
	Local aGrupo     := {}
	Local cGrupo     := ""
	Local nLoop      := 0
	Local lFilSimp := U_VALSIMP()

	lCancel := .F.

	If nOper == MODEL_OPERATION_UPDATE .Or. nOper == MODEL_OPERATION_DELETE // 4 OU 5
		lRestPed := If(SuperGetMv("MV_RESTPED")=="S", .T. , .F. )
		aAreas     := {SAJ->(FWGetArea()),P02->(FWGetArea()),SY1->(FWGetArea()), FWGetArea()}
		cComprador := Posicione("P02", 1, xFilial("P02") + SC7->C7_XTIPO, "P02_COMPRA")
		If Empty(cComprador)
			Help("", 1, "F0100401", , "Não foi encontrado comprador vinculado a esse Tipo de Pagamento.", 1, 0, , , , , , {"Atualize a tabela Tipos de Despesas."})
			lRet := .F.
		Else
			cUserTemp := Posicione("SY1", 1, xFilial("SY1") + cComprador, "Y1_USER")
			If Empty(cUserTemp)
				Help("", 1, "F0100401", , "Inconsistência no cadastro de compradores.", 1, 0, , , , , , {"Verifique o cadastro de compradores."})
				lRet := .F.
			Else
				aGrupo := UsrGrComp(cUserTemp)
				If AScan(aGrupo, "*") != 0
					lSolic := .F.
				Else
					For nLoop := 1 to Len(aGrupo)
						cGrupo += aGrupo[nLoop]
					Next
				EndIf
				If ( lSolic .And. lRestPed .And. !(SC7->C7_GRUPCOM $ cGrupo) .And. SC7->C7_USER != cUserTemp .And. !Empty(SC7->C7_USER) )
					If Empty(SC7->C7_GRUPCOM)
						Help("  ", 1, "A120RSPED", , UsrRetName(SC7->C7_USER), 4, 11)
					Else
						Help("  ", 1, "USUNAOAUT", , SC7->C7_GRUPCOM, 3, 25)
					EndIf
					lRet := .F.
				EndIf
			EndIf
		EndIf
		AEval( aAreas, {|aArea| FwRestArea(aArea)})
	EndIf
Return lRet

/*{Protheus.doc} ViewDef
Funcao generica MVC do View
@Author Mick William da Silva
@Since 29/04/2016
@Version P12.7
@Project	MAN00000462901_EF_004
@Return oView - Objeto da View MVC
*/
Static Function ViewDef()

	Local oModel	:= FWLoadModel("F0100401")
	Local oView 	:= FWFormView():New()
	Local oStruSC7  := Nil
	Local oStruSC7p	:= Nil
	Local oStruSC7r := Nil
	Local lDtFixaEx := U_fUsrDtFixa() //Lucas Miranda de Aguiar - Melhoria data fixa
	Local nOpc  := 1

	oView:SetModel(oModel)

	oStruSC7p := FwFormStruct(2, "SC7", {|x| AllTrim(x) + "|" $ cHdSC7  }) 	// Campos do Cabeçalho
	oStruSC7  := FwFormStruct(2, "SC7", {|x| AllTrim(x) + "|" $ cItemSC7}) 	// Campos dos Itens
	oStruSC7r := FwFormStruct(2, "SC7", {|x| AllTrim(x) + "|" $ cHdSC7  }) 	// Campos do Rodapé

	oView:AddField("VIEW_SC7p", oStruSC7p, "MODEL_SC7p")
	oView:AddGrid("VIEW_SC7"  , oStruSC7 , "MODEL_SC7" )
	oView:AddField("VIEW_TOT" , oStruSC7r, "MODEL_SC7r")

	//oStruc:AddField("NOME"       , "01", "TITULO"                  , "DESCRICAO"         , aHelp, "TIPO", "PICTURE", bPictVar, cLookUp, lCanChange.F., cFolder"01", cGroup, aComboValues, nMaxLenCombo, cIniBrow, lVirtual.F., PictVar, lInsertLine, nWidth )
	oStruSC7p:AddField("C7_NUM"    , "01", "Num. Solic. Pagto"       , "Num. Solic. Pagto"       , , "C", "@!", ,         , .F., "01", , , , , .F., , ,  )
	oStruSC7p:AddField("C7_EMISSAO", "02", "Dt Emissão"              , "Dt Emissão"              , , "D",     , ,         , .F., "01", , , , , .F., , ,  )
	oStruSC7p:AddField("C7_FORNECE", "03", "Cod. Fornecedor"         , "Cod. Fornecedor"         , , "C", "@!", , "FOR"   , .T., "01", , , , , .F., , ,  )
	oStruSC7p:AddField("C7_LOJA"   , "04", "Loja Fornecedor"         , "Loja Fornecedor"         , , "C", "@!", ,         , .T., "01", , , , , .F., , ,  )
	oStruSC7p:AddField("C7_COND"   , "05", "Cond. Pagto"             , "Cond. Pagto"             , , "C", "@!", , "FSSE4" , .T., "01", , , , , .F., , ,  )
	oStruSC7p:AddField("C7_CONDD"  , "06", "Desc. Cond. Pagto"       , "Desc. Cond. Pagto"       , , "C", "@!", ,         , .F., "01", , , , , .T., , ,  )
	oStruSC7p:AddField("C7_XTIPO"  , "09", "Tipo de Requisição"      , "Tipo de Requisição"      , , "C", "@!", , "FSWP02", .T., "01", , , , , .F., , ,  )
	oStruSC7p:AddField("C7_XTIPOD" , "10", "Desc. Tipo de Requisição", "Desc. Tipo de Requisição", , "C", "@!", ,         , .F., "01", , , , , .T., , ,  )
	oStruSC7p:AddField("C7_XESPECI", "12", "Especie do Documento"    , "Especie do Documento"    , , "C", "@!", , "42"    , .T., "01", , , , , .F., , ,  )
	oStruSC7p:AddField("C7_XDOC"   , "13", "Num. da Nota Fiscal"     , "Num. da Nota Fiscal"     , , "C", "@!", ,         , .T., "01", , , , , .F., , ,  )
	oStruSC7p:AddField("C7_XSERIE" , "14", "Serie da Nota Fiscal"    , "Serie da Nota Fiscal"    , , "C", "@!", ,         , .T., "01", , , , , .F., , ,  )
	oStruSC7p:AddField("C7_XDTEMI" , "15", "Dt Emissao Nota Fiscal"  , "Dt Emissao Nota Fiscal"  , , "D", ""  , ,         , .T., "01", , , , , .F., , ,  )
	oStruSC7p:AddField("C7_XDTVEN" , "16", "Data 1º Vencimento"      , "Data 1º Vencimento"      , , "D", ""  , ,         , .T., "01", , , , , .F., , ,  )
	oStruSC7p:AddField("C7_XRETENC", "17", "Cód Retenção"            , "Cód Retenção"            , , "C", "@!", , "37"    , .T., "01", , , , , .T., , ,  )//Lucas Miranda de Aguiar
	If lDtFixaEx //Melhoria data fixa - Lucas Miranda de Aguiar
		oStruSC7p:AddField("C7_XDTEXCE","18","Exceção da data fixa"  ,"Exceção da data fixa" , , "C","@!"                   , , , .T., "01", , {"Não","Sim"}, 1, , , , .F., )
	Else
		oStruSC7p:AddField("C7_XDTEXCE","18","Exceção da data fixa"  ,"Exceção da data fixa" , , "C","@!"                   , , , .F., "01", , {"Não","Sim"}, 1, , , , .F., )
	EndIf

	oStruSC7p:AddField("C7_XNUMPRO", "19", "Número do Processo", "Número do Processo", , "C", "@!", , ""    , .T., "01", , , , , .F., , ,  )
	oStruSC7p:AddField("C7_XTPCJU" , "20", "Tp Despesa do Proc Judicial", "Tp Despesa do Proc Judicial", , "C", "@!", ,         , .T., "01", , {"","1=custas judiciais", "2=despesas advocatícias"}, , , .F., , ,  )
	oStruSC7p:AddField("C7_XREPMED", "21", "Repasse Médico", "Repasse Médico", , "C", "@!", ,         , .T., "01", , {"1=Não", "2=Repasse Médico","3=Honorários"},1 , , .F., , ,  )
	oStruSC7p:AddField("C7_XPLANRE", "22", "Planilha do repasse", "Planilha do repasse", , "C", "@!", , ""    , .T., "01", , , , , .F., , ,  )
	oStruSC7p:AddField("C7_XRETINS", "23", "Código de retenção INSS", "Código de retenção INSS", , "C", "@!", , "QM"    , .T., "01", , , , , .F., , ,  )

	oStruSC7p:AddField("C7_XDBAUT", "24", "Deb. Automatico", "Deb. Automatico", , "C", "@!", ,         , .T., "01", , {"2=Não", "1=Sim"},1 , , .F., , ,  )


	oStruSC7:AddField("C7_ITEM"   , "01", "Item"                , "Item",                 , "C", "@!"                  , ,        , .F., "01", , , , , .F., , ,  )
	oStruSC7:AddField("C7_PRODUTO", "02", "Codigo do Produto"   , "Codigo do Produto"   , , "C", "@!"                  , , "FSSB1", .T., "01", , , , , .F., , ,  )
	oStruSC7:AddField("C7_DESCRI" , "03", "Descricao do Produto", "Descricao do Produto", , "C", "@!"                  , ,        , .F., "01", , , , , .T., , ,  )
	oStruSC7:AddField("C7_UM"     , "04", "Unidade de medida"   , "Unidade de medida"   , , "C", "@!"                  , , "SAH"  , .T., "01", , , , , .F., , ,  )
	oStruSC7:AddField("C7_QUANT"  , "05", "Quantidade"          , "Quantidade"          , , "N", "@E 999999999.99"     , ,        , .T., "01", , , , , .F., , ,  )
	oStruSC7:AddField("C7_PRECO"  , "06", "Preco"               , "Preco"               , , "N", "@E 99,999,999,999.99", ,        , .T., "01", , , , , .F., , ,  )
	oStruSC7:AddField("C7_TOTAL"  , "07", "Total"               , "Total"               , , "N", "@E 99,999,999,999.99", ,        , .F., "01", , , , , .F., , ,  )
	oStruSC7:AddField("C7_XDESFIN", "08", "Desconto"            , "Desconto"            , , "N", "@E 99,999,999,999.99", ,        , .T., "01", , , , , .F., , ,  )
	oStruSC7:AddField("C7_LOCAL"  , "09", "Armazem"             , "Armazem"             , , "C", "@!"                  , , "NNR"  , .T., "01", , , , , .F., , ,  )
	oStruSC7:AddField("C7_OBS"    , "10", "Observacoes"         , "Observacoes"         , , "C", "@!"                  , ,        , .T., "01", , , , , .F., , ,  )
	oStruSC7:AddField("C7_CC"     , "11", "Centro de Custo"     , "Centro de Custo"     , , "C", ""                    , , "CTT"  , .T., "01", , , , , .F., , ,  )
	oStruSC7:AddField("C7_XMULTA" , "12", "Multa"               , "Multa"               , , "N", "@E 99,999,999,999.99", , ""     , .T., "01", , , , , .F., , ,  )
	oStruSC7:AddField("C7_XJURMUL", "13", "Juros"               , "Juros "              , , "N", "@E 99,999,999,999.99", , ""     , .T., "01", , , , , .F., , ,  )

	// Novo
	oStruSC7:AddField("C7_XERAUT", "14", "Erro Aprovac."        , "Erro Aprovac."            , , "M", "@!", ,        , .T., "01", , , , , .F., , ,  )

	oStruSC7r:AddField("C7_TOTSOL" , "04", "Total da Solicitação de Pagamento", "Total da Solicitação de Pagamento", , "N", "@E 99,999,999,999.99", , , .F., "01", , , , , .F., , ,  )

	// ticket n° 10326179 -- novo campo Tx Expediente
	oStruSC7:AddField("C7_XTXEXPE", "15", "T Expediente"        , "T Expediente"        , , "N", "@E 999,999,999.99"   , , ""     , .T., "01", , , , , .F., , ,  )

	oStruSC7:AddField("C7_ZINTOGY", "16", "Status Onergy", "Status Onergy"        		, , "C", "@!"   				, , ""     , .T., "01", , , , , .F., , ,  )
	oStruSC7:AddField("C7_ZIDONGY", "17", "ID Onergy"    , "ID Onergy"        			, , "C", "@!"   				, , ""     , .T., "01", , , , , .F., , ,  )

	oView:CreateHorizontalBox("SUPERIOR", 40)
	oView:CreateHorizontalBox("GRID"    , 50)
	oView:CreateHorizontalBox("RODAPE"  , 10)

	oView:SetOwnerView("VIEW_SC7p", "SUPERIOR")
	oView:SetOwnerView("VIEW_SC7" , "GRID"    )
	oView:SetOwnerView("VIEW_TOT" , "RODAPE"  )

	oView:AddIncrementField("VIEW_SC7", "C7_ITEM")

	oView:AddUserButton('Aprovação', 'BUDGET', {||  VerAprov() } )
	oView:AddUserButton('BC Conhecimento', 'Banco Específico - Visualizar', {||  U_F0400101(1) } )

Return oView

/*/{Protheus.doc} SaveModel
Gravação do modelo de dados.
@author 	alexandre.arume
@since 		24/08/2016
@version 	1.0
@param 		oModel, Modelo de dados.
@Project	MAN00000462901_EF_004
@return ${lRet}, Status da operação.
/*/
Static Function SaveModel(oModel)

	Local nOperation	:= oModel:GetOperation()
	Local oMdlDetail	:= oModel:GetModel("MODEL_SC7")
	Local oMdlMain		:= oModel:GetModel("MODEL_SC7p")
	Local oMdlFooter	:= oModel:GetModel("MODEL_SC7r")
	Local cCond			:= GetMv("FS_CONDPAG", , "001")
	Local aAreas     	:= {P02->(GetArea()), GetArea()}
	Local aCabec		:= {}
	Local aItens		:= {}
	Local aItem			:= {}
	Local nI			:= 0
	Local lMJ			:= .F.
	Local lRet			:= .T.
	Local cComprador	:= ""
	Local cUserIdBk		:= __cUserId
	Local cUserTemp		:= ""
	Local cBloqueio     := ""
	Local nMulta		:= 99999999
	Local nJuros		:= 99999999
	Local cAnex := ""
	Local cDbaut        := ""
	Local aRet := {.T.,"OK"}
	Private lMsErroAuto	:= .F.


	DbSelectArea("P35")
	DbSetOrder(1)
	DbGoTop()

	While P35->(!EOF())

		If P35->P35_TIPO == "1"
			nMulta := P35->P35_VALMIN
		ElseIf P35->P35_TIPO == "2"
			nJuros := P35->P35_VALMIN
		EndIf
		P35->(DbSkip())
	EndDo

	If Posicione("SA2",1,xFilial("SA2")+AllTrim(oMdlMain:GetValue("C7_FORNECE"))+AllTrim(oMdlMain:GetValue("C7_LOJA")),"SA2->A2_XDTFIX") == "1"
		if !FWIsInCallStack("U_RDCAR99")
			If !MsgYesNo("O fornecedor desta SP/NF controla datas fixas de vencimento para seus títulos a pagar, deseja continuar?")
				lRet := .F.
				AEval(aAreas, {|aArea| RestArea(aArea)})
				Return lRet
			EndIf
		endif 
	EndIf

	If nOperation <> MODEL_OPERATION_DELETE
		aRet := U_MSCHKCOND(AllTrim(oMdlMain:GetValue("C7_COND")),AllTrim(oMdlMain:GetValue("C7_FORNECE")),AllTrim(oMdlMain:GetValue("C7_LOJA")))
	EndIf
	If !aRet[1]
		Help("", 1, "PS0100401", , aRet[2], 1, 0, , , , , , {"Revise a condição de pagamento escolhida."})
		lRet := .F.
		AEval(aAreas, {|aArea| RestArea(aArea)})
		Return lRet
	EndIf

	If AllTrim(oMdlMain:GetValue("C7_XTIPO")) $ AllTrim(GetNewPar("FS_TPSP","CFR"))
		If AllTrim(oMdlMain:GetValue("C7_XRETENC")) == ""
			if !FWIsInCallStack("U_RDCAR99")
				If !MsgYesNo("O código de retenção não foi preenchido para o tipo de SP " + AllTrim(oMdlMain:GetValue("C7_XTIPO"))+ ", deseja continuar?")
					lRet := .F.
					AEval(aAreas, {|aArea| RestArea(aArea)})
					Return lRet
				EndIf
			/*else
				oModel:SetErrorMessage(, , oModel:GetId(), , "Help", "Erro preenchimento C7_XRETENC.", "O código de retenção não foi preenchido para o tipo de SP " + oMdlMain:GetValue("C7_XTIPO"), , )
				lRet := .F.
				AEval(aAreas, {|aArea| RestArea(aArea)})
				Return lRet*/
			endif
		EndIf
	Else
		If AllTrim(oMdlMain:GetValue("C7_XRETENC")) != ""
			if !FWIsInCallStack("U_RDCAR99")
				Alert("O preenchimento do código de renteção não é permitido para o tipo de solicitação " + oMdlMain:GetValue("C7_XTIPO"))
			else
				//oModel:SetErrorMessage(, , oModel:GetId(), , "Help", "Erro preenchimento C7_XRETENC.", "O preenchimento do código de renteção não é permitido para o tipo de solicitação " + oMdlMain:GetValue("C7_XTIPO"), , )				
				oModel:SetErrorMessage(oModel:GetId(),"C7_XRETENC" , oModel:GetId(), "C7_XRETENC", "Help", "O preenchimento do código de renteção("+AllTrim(oMdlMain:GetValue("C7_XTIPO"))+") não é permitido para o tipo de solicitação ", , )
			endif
			lRet := .F.
			AEval(aAreas, {|aArea| RestArea(aArea)})
			Return lRet
		EndIf
	EndIf
	lMJ := U_XCHKMULJUR(oModel)
	If lMJ
		if !FWIsInCallStack("U_RDCAR99")
			If !MsgYesNo("Esta SP possui valor de Multa e/ou Juros e passará por alçada de aprovação de Multa/Juros." + CRLF + "Deseja confirmar a gravação?")
				lRet := .F.
				AEval(aAreas, {|aArea| RestArea(aArea)})
				Return lRet
			EndIf
		endif
	EndIf


	If nOperation <> MODEL_OPERATION_INSERT
		AAdd(aCabec, {"C7_NUM", oMdlMain:GetValue("C7_NUM"), Nil})
		cAnex := Posicione("SC7", 1, FwXFilial("SC7") + oMdlMain:GetValue("C7_NUM"), "C7_XANEXO")
	EndIf

	cComprador := Posicione("P02", 1, xFilial("P02") + oMdlMain:GetValue("C7_XTIPO"), "P02_COMPRA")

	If Empty(cComprador)
		Help("", 1, "F0100401", , "Não foi encontrado comprador vinculado a esse Tipo de Pagamento.", 1, 0, , , , , , {"Atualize a tabela Tipos de Despesas."})
		AEval(aAreas, {|aArea| RestArea(aArea)})
		Return .F.
	Else
		cUserTemp := Posicione("SY1", 1, xFilial("SY1") + cComprador, "Y1_USER")
		If Empty(cUserTemp)
			Help("", 1, "F0100401", , "Inconsistência no cadastro de compradores.", 1, 0, , , , , , {"Verifique o cadastro de compradores."})
			AEval(aAreas, {|aArea| RestArea(aArea)})
			Return .F.
		Else
			AAdd(aCabec, {"C7_COMPRA" 	, cComprador							, Nil})
		EndIf
	EndIf

	AAdd(aCabec, {"C7_EMISSAO", oMdlMain:GetValue("C7_EMISSAO")  , Nil})
	AAdd(aCabec, {"C7_FORNECE", oMdlMain:GetValue("C7_FORNECE")  , Nil})
	AAdd(aCabec, {"C7_LOJA"   , oMdlMain:GetValue("C7_LOJA"	  )  , Nil})
	AAdd(aCabec, {"C7_COND"   , oMdlMain:GetValue("C7_COND"	  )  , Nil})
	AAdd(aCabec, {"C7_CONTATO", ""								 , Nil})
	AAdd(aCabec, {"C7_FILENT" , cFilAnt							 , Nil})
	AAdd(aCabec, {"C7_MOEDA"  , 1								 , Nil})
	AAdd(aCabec, {"C7_TXMOEDA", 0								 , Nil})
	AAdd(aCabec, {"C7_SOLICIT", AllTrim(UsrRetName(__CUSERID))	 , Nil})
	AAdd(aCabec, {"C7_APROV"  , cComprador                       , Nil})
	AAdd(aCabec, {"C7_USER"   , cUserTemp                        , Nil}) //Thais
	AAdd(aCabec, {"C7_XUSRSP" , cUserIdBk						 , Nil})//Lucas Miranda de Aguiar
	AAdd(aCabec, {"C7_XRETENC" , oMdlMain:GetValue("C7_XRETENC") , Nil})//Lucas Miranda de Aguiar
	If oMdlMain:GetValue("C7_XREPMED") <> '1'
		AAdd(aCabec, {"C7_XREPMED" , oMdlMain:GetValue("C7_XREPMED") , Nil})
		AAdd(aCabec, {"C7_XPLANRE" , oMdlMain:GetValue("C7_XPLANRE") , Nil})
	EndIf
	AAdd(aCabec, {"C7_XRETINS" , oMdlMain:GetValue("C7_XRETINS") , Nil})
		If oMdlMain:GetValue("C7_XDBAUT") == " "
		AAdd(aCabec, {"C7_XDBAUT" , "2", Nil})
		cDbaut := "2"
	Else
		AAdd(aCabec, {"C7_XDBAUT" , oMdlMain:GetValue("C7_XDBAUT"), Nil})
		cDbaut := oMdlMain:GetValue("C7_XDBAUT")
	EndIf
	
		If nOperation == MODEL_OPERATION_INSERT
			AAdd(aCabec, {"C7_XANEXO" , "NAO" , Nil})
		EndIf
	
	For nI := 1 To oMdlDetail:Length()

		oMdlDetail:GoLine(nI)

		If oMdlDetail:IsDeleted() .And. nOperation == MODEL_OPERATION_INSERT
			Loop
		EndIf
		aItem := {}

		AAdd(aItem, {"C7_ITEM"	 , oMdlDetail:GetValue("C7_ITEM"   ), Nil})
		AAdd(aItem, {"C7_PRODUTO", oMdlDetail:GetValue("C7_PRODUTO"), Nil})
		AAdd(aItem, {"C7_UM" 	 , oMdlDetail:GetValue("C7_UM"	   ), Nil})
		AAdd(aItem, {"C7_QUANT"  , oMdlDetail:GetValue("C7_QUANT"  ), Nil})
		AAdd(aItem, {"C7_PRECO"  , oMdlDetail:GetValue("C7_PRECO"  ), Nil})
		AAdd(aItem, {"C7_TOTAL"  , oMdlDetail:GetValue("C7_TOTAL"  ), Nil})
		AAdd(aItem, {"C7_LOCAL"  , oMdlDetail:GetValue("C7_LOCAL"  ), Nil})
		AAdd(aItem, {"C7_OBS" 	 , oMdlDetail:GetValue("C7_OBS"	   ), Nil})
		AAdd(aItem, {"C7_CC"	 , oMdlDetail:GetValue("C7_CC"	   ), Nil})
		AAdd(aItem, {"C7_XJURMUL", oMdlDetail:GetValue("C7_XJURMUL"), Nil})
		AAdd(aItem, {"C7_XDESFIN", U_F1600701(xFilial("CNE"), oMdlMain:GetValue("C7_NUM"),oMdlDetail:GetValue("C7_XDESFIN")), Nil})
		AAdd(aItem, {"C7_XMULTA" , oMdlDetail:GetValue("C7_XMULTA") , Nil})
		AAdd(aItem, {"C7_XSOLPAG", "1"							    , Nil})
		AAdd(aItem, {"C7_XUSR"	 , __CUSERID                        , Nil})
		AAdd(aItem, {"C7_XTIPO"	 , oMdlMain:GetValue("C7_XTIPO"	   ), Nil})
		AAdd(aItem, {"C7_XESPECI", oMdlMain:GetValue("C7_XESPECI"  ), Nil})
		AAdd(aItem, {"C7_XDOC"	 , oMdlMain:GetValue("C7_XDOC"	   ), Nil})
		AAdd(aItem, {"C7_XSERIE" , oMdlMain:GetValue("C7_XSERIE"   ), Nil})
		AAdd(aItem, {"C7_XDTEMI" , oMdlMain:GetValue("C7_XDTEMI"   ), Nil})
		AAdd(aItem, {"C7_XDTVEN" , oMdlMain:GetValue("C7_XDTVEN"   ), Nil})
		AAdd(aItem, {"C7_REC_WT" , GetRecno(oModel)				    , Nil})
		AAdd(aItem, {"C7_XUSRSP" , cUserIdBk						, Nil})//Lucas Miranda de Aguiar
		AAdd(aItem, {"C7_XRETENC" , oMdlMain:GetValue("C7_XRETENC") , Nil})//Lucas Miranda de Aguiar
		AAdd(aItem, {"C7_XTXEXPE", oMdlDetail:GetValue("C7_XTXEXPE" ),Nil}) // ticket n° 10326179 -- novo campo Tx Expediente
		AAdd(aItem, {"C7_XNUMPRO", oMdlMain:GetValue("C7_XNUMPRO" ),Nil}) // ticket n° 10326179 -- novo campo Tx Expediente
		AAdd(aItem, {"C7_XTPCJU", oMdlMain:GetValue("C7_XTPCJU" ),Nil}) // ticket n° 10326179 -- novo campo Tx Expediente
		If oMdlMain:GetValue("C7_XREPMED") <> '1'
		AAdd(aItem, {"C7_XREPMED" , oMdlMain:GetValue("C7_XREPMED") , Nil})
		AAdd(aItem, {"C7_XPLANRE" , oMdlMain:GetValue("C7_XPLANRE") , Nil})
		EndIf
		AAdd(aItem, {"C7_XRETINS" , oMdlMain:GetValue("C7_XRETINS") , Nil})
		AAdd(aItem, {"C7_ZINTOGY" , oMdlDetail:GetValue("C7_ZINTOGY") , Nil})
		AAdd(aItem, {"C7_ZIDONGY" , oMdlDetail:GetValue("C7_ZIDONGY") , Nil})

				If oMdlMain:GetValue("C7_XDBAUT") == " "
		AAdd(aItem, {"C7_XDBAUT" , "2", Nil})
		Else
		AAdd(aItem, {"C7_XDBAUT" , oMdlMain:GetValue("C7_XDBAUT"), Nil})
		EndIf
		If Posicione("SA2",1,xFilial("SA2")+oMdlMain:GetValue("C7_FORNECE")+oMdlMain:GetValue("C7_LOJA"),"SA2->A2_XDTFIX") == "1"
			If oMdlMain:GetValue("C7_XDTEXCE") == "Sim"
				AAdd(aItem, {"C7_XDTEXCE" , "1"						 , Nil})//Lucas Miranda de Aguiar
			ElseIf oMdlMain:GetValue("C7_XDTEXCE") == "Não" .Or. AllTrim(oMdlMain:GetValue("C7_XDTEXCE")) == ""
				AAdd(aItem, {"C7_XDTEXCE" , "2"						 , Nil})//Lucas Miranda de Aguiar
			EndIf
			If Empty(dDtBKP)
				dDtBKP := dDataBase
			EndIf
			AAdd(aItem, {"C7_XDTORIG" , dDtBKP , Nil})//Lucas Miranda de Aguiar
		EndIf

		If oMdlDetail:IsDeleted()
			AAdd(aItem, {"AUTDELETA", "S", Nil})	// Linha deletada.
		EndIf

		AAdd(aItens, aItem)

	Next nI

	If oModel:VldData()

		Begin Transaction
			If nOperation == MODEL_OPERATION_DELETE
				U_F0400105("F0100401", SC7->C7_FILIAL, SC7->C7_NUM)
				ExcluiNota(SC7->(Recno()))
				If lMsErroAuto
					DisarmTransaction()
					MostraErro()
					oModel:SetErrorMessage(, , oModel:GetId(), , "Help", "Erro na exclusão da Nota.", "Verifique os dados informados.", , )
					AEval(aAreas, {|aArea| RestArea(aArea)})
					//Return .F. //Thais Paiva - Compatibilização P27
					lRet := .F.
				EndIf				
			EndIf
			If lRet //Thais Paiva - Compatibilização P27
				__cUserId := cUserTemp
				//If nOperation == MODEL_OPERATION_INSERT
				If M->C7_XTIPO == NIL .Or. Empty(AllTrim(M->C7_XTIPO))
					cBloqueio := Posicione("P02", 1, xFilial("P02") + SC7->C7_XTIPO, "P02_MSBLQL")
				Else
					cBloqueio := Posicione("P02", 1, xFilial("P02") + M->C7_XTIPO, "P02_MSBLQL")
				EndIf
				//ElseIf nOperation == MODEL_OPERATION_UPDATE
				//cBloqueio := Posicione("P02", 1, xFilial("P02") + SC7->C7_XTIPO, "P02_MSBLQL")
				//EndIf

				If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE // 4 OU 5
					cComprador := Posicione("P02", 1, xFilial("P02") + SC7->C7_XTIPO, "P02_COMPRA")
					If Empty(cComprador)
						Help("", 1, "F0100401", , "Não foi encontrado comprador vinculado a esse Tipo de Pagamento.", 1, 0, , , , , , {"Atualize a tabela Tipos de Despesas."})
						lRet := .F.
					Else
						cUserTemp := Posicione("SY1", 1, xFilial("SY1") + cComprador, "Y1_USER")
						If Empty(cUserTemp)
							Help("", 1, "F0100401", , "Inconsistência no cadastro de compradores.", 1, 0, , , , , , {"Verifique o cadastro de compradores."})
							lRet := .F.
						EndIf
					EndIf
				EndIf

				If cBloqueio == "1" .And. nOperation != MODEL_OPERATION_DELETE
					Help("", 1, "F0100401", , "O tipo de requisição selecionado está bloqueado.", 1, 0, , , , , , {"Atualize a tabela Tipos de requisição."})
					lRet := .F.
				Else
					// Rotina automática do Pedido de Compra.
					PutMv("MV_HISTAPC",.F.)
					if !FWIsInCallStack("U_RDCAR99")
						MsgRun("Aguarde...", , {|| MATA120(1, aCabec, aItens, nOperation)})
					else
						MATA120(1, aCabec, aItens, nOperation)
					endif
					PutMv("MV_HISTAPC",.T.)
					
					IF lMsErroAuto

						DisarmTransaction()
						if !FWIsInCallStack("U_RDCAR99")
							MostraErro()
						else
							oModel:SetErrorMessage(oModel:GetId(),"C7_PRODUTO" , oModel:GetId(), "C7_PRODUTO", "Help", MostraErro("C:\temp\"), , )
						endif
						lRet := .F.
						//oModel:SetErrorMessage(, , oModel:GetId(), , "Help", "Erro na rotina automática", "Verifique os dados informados.", , )
					Else
						If (nOperation == MODEL_OPERATION_INSERT) .Or. (nOperation == MODEL_OPERATION_UPDATE) // 3 OU 4
							Reclock("SC7",.F.)
							SC7->C7_XUSRSP := UsrFullName(cUserIdBk)
							SC7->C7_XDBAUT := cDbaut
							SC7->(MsUnLock())
							if !FWIsInCallStack("U_RDCAR99")
								MsgInfo("Favor anexar Nota Fiscal e/ou documento via banco de conhecimento!")
								//else
								//oModel:SetErrorMessage(, , oModel:GetId(), , "Help", "Erro na Geração da SP.", "Favor anexar Nota Fiscal e/ou documento via banco de conhecimento!", , )
							endif
						EndIf
						If (nOperation == MODEL_OPERATION_UPDATE)
							Reclock("SC7",.F.)
								SC7->C7_XANEXO := cAnex
							SC7->(MsUnLock())
						EndIf
					EndIf
				EndIf
				__cUserId := cUserIdBk
			EndIf  //Thais Paiva - Compatibilização P27

		End Transaction

		//Melhoria Multa e Juros - Lucas Miranda de Aguiar 07/07/2021
		U_XF01004MJ()

	Else
		if !FWIsInCallStack("U_RDCAR99")
			JurShowErro(oModel:GetModel():GetErrormessage())
		else
			oModel:SetErrorMessage(, , oModel:GetId(), , "Help", "Erro na Geração da SP.", oModel:GetModel():GetErrormessage(), , )
			lRet := .F.
		endif
	EndIf

	AEval(aAreas, {|aArea| RestArea(aArea)})

Return lRet

Static Function ExcluiNota(nRecno)

	Local aCabecNota := {}
	Local aItensNota := {}
	Local bExecAuto  := {||}
	Local nOpcExclui := 5

	If Empty(nRecno)
		Return
	EndIf
	SF1->(DbSetOrder(1))
	If !SF1->(DbSeek(xFilial("SF1")+SC7->(C7_XDOC+C7_XSERIE+C7_FORNECE+C7_LOJA)))
		Return
	EndIf

	SC7->(DbGoTo(nRecno))

	aCabecNota := {;
		{"F1_DOC"	 , SC7->C7_XDOC	  , Nil},;
		{"F1_SERIE"	 , SC7->C7_XSERIE , Nil},;
		{"F1_EMISSAO", SC7->C7_XDTEMI , Nil},;
		{"F1_FORNECE", SC7->C7_FORNECE, Nil},;
		{"F1_LOJA"	 , SC7->C7_LOJA	  , Nil};
		}

	bExecAuto := {|aCabec, aItens, nOpc| MatA140(aCabec, aItens, nOpc)}

	MsExecAuto(bExecAuto, aCabecNota, aItensNota, nOpcExclui)

Return

/*/{Protheus.doc} GetRecno
Retorna o valor do Recno do registro.
@author 	alexandre.arume
@since 		24/08/2016
@version 	1.0
@Project	MAN00000462901_EF_004
@param oModel, Modelo de dados.
@return ${nRet}, Valor do Recno.
/*/
Static Function GetRecno(oModel)

	Local nOperation := oModel:GetOperation()
	Local oMdlMain	 := oModel:GetModel("MODEL_SC7p")
	Local oMdlDetail := oModel:GetModel("MODEL_SC7")
	Local cNum 		 := oMdlMain:GetValue("C7_NUM")
	Local cItem 	 := oMdlDetail:GetValue("C7_ITEM")
	Local aSC7Area	 := {}
	Local nRet		 := 0

	If nOperation <> MODEL_OPERATION_INSERT

		aSC7Area := SC7->(GetArea())

		SC7->(DbSetOrder(1))
		If SC7->(DbSeek(xFilial("SC7") + cNum + cItem))
			nRet := SC7->(RECNO())
		EndIf

		RestArea(aSC7Area)

	EndIf

Return nRet

/*/{Protheus.doc} GetDescrip
Retorna a descrição do campo.
@author 	alexandre.arume
@since 		22/08/2016
@version 	1.0
@param 		oModel, (Objeto do modelo)
@param 		cFil, (Codigo da filial)
@param 		cSC7Field, (Campo da tabela SC7)
@param 		cTable, (Nome da tabela a ser pesquisada)
@param 		cRetField, (Nome do campo a ser pesquisado)
@Project	MAN00000462901_EF_004
@return 	cRet, Descrição.
/*/
Static Function GetDescrip(oModel, cFilPesq, cSC7Field, cTabPesq, cRetField)

	Local cRet       := ""
	Local oMdlMain   := oModel:GetModel("MODEL_SC7p")
	Local nOperation := oModel:GetOperation()

	If nOperation <> MODEL_OPERATION_INSERT .And. ! Empty(oMdlMain:GetValue(cSC7Field))
		//cRet := Posicione(cTabPesq, 1, cFilPesq + oMdlMain:GetValue(cSC7Field), cRetField)
		cRet := Posicione(cTabPesq, 1, xFilial("SE4") + oMdlMain:GetValue(cSC7Field), cRetField)
	EndIf

Return cRet

/*/{Protheus.doc} SumProd
Multiplicação da quantidade pelo preço de cada item.
@author 	alexandre.arume
@since 		19/08/2016
@version 	1.0
@Project	MAN00000462901_EF_004
@return ${.T.}
/*/
Static Function SumProd(oModel)

	Local oMdlDetail	:= oModel:GetModel("MODEL_SC7")
	Local nTotal		:= 0

	// Calcula o valor total do produto.
	nTotal := oMdlDetail:GetValue("C7_QUANT") * oMdlDetail:GetValue("C7_PRECO")

	// Atualiza o valor do campo Total.
	If oMdlDetail:GetOperation() <> MODEL_OPERATION_DELETE // 5
		oMdlDetail:LoadValue("C7_TOTAL", nTotal)
	EndIf
	// Atualiza o valor do campo Total de Mercadoria.
	SumMerc(oModel)

Return .T.

/*/{Protheus.doc} TotValue
Valor total do produto.
@author 	alexandre.arume
@since 		22/08/2016
@version 	1.0
@param 		oModel, objeto, (Objeto do modelo)
@Project	MAN00000462901_EF_004
@return ${nRet}, Valor total.
/*/
Static Function TotValue(oModel)

	Local oMdlDetail 	:= oModel:GetModel("MODEL_SC7")
	Local nRet			:= 0

	If oModel:GetOperation() <> MODEL_OPERATION_INSERT // 3
		If ! Empty(oMdlDetail:GetValue("C7_QUANT")) .And. ! Empty(oMdlDetail:GetValue("C7_PRECO"))
			nRet := oMdlDetail:GetValue("C7_QUANT") * oMdlDetail:GetValue("C7_PRECO")
		EndIf
	EndIf

Return nRet

/*/{Protheus.doc} SumMerc
Somatória dos valores totais de cada item.
@author 	alexandre.arume
@since 		19/08/2016
@version 	1.0
@param 		oModel, objeto, (Modelo do objeto)
@Project	MAN00000462901_EF_004
@return ${nTotal}, Valor total das Mercadoria.
/*/
Static Function SumMerc(oModel)

	Local oMdlDetail 	:= oModel:GetModel("MODEL_SC7")
	Local oMdlFooter 	:= oModel:GetModel("MODEL_SC7r")
	Local oView		    := FWViewActive()
	Local nI			:= 0
	Local nTotal		:= 0
	Local aSaveLines	:= {}

	aSaveLines	:= FWSaveRows()

	// Percorre os itens do Grid.
	For nI := 1  To oMdlDetail:Length()
		oMdlDetail:GoLine(nI)
		nTotal += oMdlDetail:GetValue("C7_TOTAL")
	Next
	FWRestRows(aSaveLines)

	// Atualiza o campo do valor do Total da Solicitação de Pagamento.
	TotSolPagt(oModel,nTotal)

Return nTotal

/*/{Protheus.doc} PropValue
Cálculo do valor proporcional por item.
@author alexandre.arume
@since 22/08/2016
@version 1.0
@param oModel, (Descrição do parâmetro)
@param cFooTot, (Campo total do footer)
@param cFld, (Campo proporcional)
@return ${return}, ${return_description}
/*/
Static Function PropValue(oModel, cFooTot, cFld, cBlock)

	Local oMdlMain 	 := oModel:GetModel("MODEL_SC7p")
	Local oMdlDetail := oModel:GetModel("MODEL_SC7")
	Local oMdlFooter := oModel:GetModel("MODEL_SC7r")
	Local oView		 := FWViewActive()
	Local nI		 := 0
	Local nTotalMerc := 0
	Local nTotal	 := IIf(oMdlFooter:GetValue(cFooTot)      <> Nil, oMdlFooter:GetValue(cFooTot)     , 0)
	Local nTotalItem := 0
	Local nValItem	 := 0

	// Caso não esteja vindo da função SumDesc ou SumDesp.
	If !lFunSum

		// Percorre os itens do Grid.
		For nI := 1 To oMdlDetail:Length()

			oMdlDetail:GoLine(nI)

			// Pega o valor do campo total do produto.
			nTotalItem := IIf(oMdlDetail:GetValue("C7_TOTAL") <> Nil, oMdlDetail:GetValue("C7_TOTAL"), 0)

			If nTotalMerc = 0 .Or. nTotal = 0 .Or. nTotalItem = 0
				nValItem := 0
			Else
				nValItem := (nTotalItem * 100) / nTotalMerc	// Porcentagem equivalente
				nValItem := (nValItem / 100) * nTotal	    // Valor proporcional
			EndIf

			// Atualiza o valor do campo.
			If oMdlDetail:GetOperation() <> MODEL_OPERATION_DELETE // 5
				oMdlDetail:LoadValue(cFld, nValItem)
			EndIf
		Next

		// Se for edição do campo Desconto Total ou Juros Total.
		If cBlock == "Valid"

			oMdlDetail:GoLine(1)
			oView:Refresh()

		EndIf

	EndIf

Return .T.

/*/{Protheus.doc} TotSolPagt
Cálculo da Solicitação de Pagamento.
@author 	alexandre.arume
@since 		19/08/2016
@version 	1.0
@param 		oModel, objeto, (Modelo do objeto)
@Project	MAN00000462901_EF_004
@return ${nTotal}, Valor total da Solicitação de Pagamento
/*/
Static Function TotSolPagt(oModel,nTotal)

	Local oTotais    := oModel:GetModel("MODEL_SC7r")

	If oTotais:GetValue("C7_TOTSOL") <> Nil
		If oTotais:GetOperation() <> MODEL_OPERATION_DELETE
			oTotais:LoadValue("C7_TOTSOL", nTotal)
		EndIf
	EndIf

Return nTotal

/*/{Protheus.doc} IsValidModel
Chamada de funções de validações na confirmação do cadastro.
@author 	Paulo Krüger
@since 		13/12/2016
@version 	1.0
@param 		oModelo
@Project	MAN00000462901_EF_004
@return	lógico
/*/

Static Function IsValidModel(oModelo)

	Local lValidado := .T.
	Local nOpca     := 0
	Local oMdlMain  := oModelo:GetModel("MODEL_SC7p")

	SC7->(DbSetOrder(1))
	SC7->(DbSeek(XFilial("SC7")+oMdlMain:GetValue("C7_NUM")))
	nOpca := oModelo:GetOperation()

	If nOpca == MODEL_OPERATION_DELETE // 5
		If NotaClassificada()
			Help( , , "Help", ,;
				"O Documento de entrada associada a esta solicitação se encontra classificado."+;
				"Este documento não será excluído.", 1, 0)
			lValidado := .F.
		EndIf

		If lValidado
			ExcluiSCR(SC7->C7_NUM) // Colocado aqui pela verificação de integridade. Se existir SCR não deixa excluir.
		EndIf
	ElseIf nOpca == MODEL_OPERATION_INSERT
		lValidado := U_TrataXSer()
		//Início - 10019683
	ElseIf nOpca == MODEL_OPERATION_UPDATE
		If SC7->C7_QTDACLA > 0 .AND. SC7->C7_CONAPRO = 'L'
			Help("", 1, "F0100401", ,;
				"Esta Solicitação de Pagamento possui uma pré nota criada!."+;
				"Para seguir com a alteração desta solicitação de pagamento, será necessário excluir a pré nota fiscal.", 1, 0, , , , , , {"Excluir a pré nota fiscal"})
			lValidado := .F.
		EndIf
		//Fim - 10019683
	EndIf

	If Empty(oMdlMain:GetValue("C7_FORNECE")) .And. oMdlMain:GetValue("C7_FORNECE") != Nil
		Help( , , "Help", , "PREENCHA O CAMPO FONECEDOR", 1, 0)
		lValidado  := .F.
	EndIf

	If AllTrim(SuperGetMV("MV_XTIPJUR",,"CJU")) $ Alltrim(FWFldGet("C7_XTIPO")) .And. nOpca != MODEL_OPERATION_DELETE // 5
		if !Empty(FwFldGet("C7_XNUMPRO"))
			if Empty(FwFldGet("C7_XTPCJU"))
				Help( , , "Help", , "Preencha o Tipo da Despesa do Processo Judicial", 1, 0)
				lValidado := .F.
			endif
		elseif !Empty(FwFldGet("C7_XTPCJU"))
			if Empty(FwFldGet("C7_XNUMPRO"))
				Help( , , "Help", , "Preencha o Número do Processo do Processo Judicial", 1, 0)
				lValidado := .F.
			endif
		endif
	elseif !(AllTrim(SuperGetMV("MV_XTIPJUR",,"CJU")) $ Alltrim(FWFldGet("C7_XTIPO"))) .And. nOpca != MODEL_OPERATION_DELETE
		if !Empty(FwFldGet("C7_XNUMPRO")) .Or. !Empty(FwFldGet("C7_XTPCJU"))
			oMdlMain:SetValue("C7_XNUMPRO","")
			oMdlMain:SetValue("C7_XTPCJU","")
		endif
	endif

Return lValidado

Static Function NotaClassificada()

	Local aArea		    := GetArea()
	Local aAreaSD1	    := SD1->(GetArea())
	Local lClassificada := .F.

	SD1->(DbSetOrder(1))
	If SD1->(DbSeek(XFilial("SD1") + SC7->(C7_XDOC + C7_XSERIE + C7_FORNECE + C7_LOJA)))
		lClassificada := !Empty(SD1->D1_TES)
	EndIf

	RestArea(aAreaSD1)
	RestArea(aArea)

Return lClassificada

/*/{Protheus.doc} F0100411
Calcula a data de vencimento da parcela
@author 	Nairan Silva
@since 		17/02/2017
@version 	1.0
@param 		dDataEmis, data, descricao
@param 		cCond, caracter, descricao
@Project	MAN00000462901_EF_004
@return	lógico
/*/
User Function F0100411(dDataEmis, cCond)

	Local dRet   := dDataBase
	Local aDatas := Condicao(100, cCond , , dDataEmis , , , , )
	Local nPerc  := Condicao(100, cCond , , dDataEmis , , , , )[1][2]

	Default cCond     := "001"
	Default dDataEmis := Date()

	If Len(aDatas) > 0
		If !Empty(aDatas[01][01])
			dRet := aDatas[01][01]
		EndIf
	EndIf

	If Posicione("SA2",1,xFilial("SA2")+M->C7_FORNECE+M->C7_LOJA,"SA2->A2_XDTFIX") == "1"
		dRet := U_DTFORNFIX(dRet,cCond)
		lChange := .T.
	Else
		dRet := DataValida(dRet)
	EndIf

	dDtBKP := dRet

Return dRet

/*/{Protheus.doc} F0100412
Valida a data de vencimento digitada
@author 	Robson William
@since 		02/06/2017
@version 	1.0
@param
@param
@Project	MAN00000462901_EF_004, MIT031
@return	lógico
/*/
User Function F0100412()

	Local lRetorno  := .F.
	Local dDataEmis := M->C7_XDTEMI
	Local dDataVenc := M->C7_XDTVEN
	Local cEdit     := AllTrim(M->C7_XDTEXCE)
	Local dDataUtil := DataValida(dDataVenc, .T.)
	Local nDiasMax := GetNewPar("FS_DVECTO",60)

	Begin Sequence
		If dDataVenc < dDataEmis
			Help( , , 'HELP', , "A data de vencimento deve ser maior ou igual a data de emissão", 1, 0)
			Break
		Endif
		If dDataUtil <> dDataVenc
			Help( , , 'HELP', , "A data de vencimento inválida.", 1, 0 , , , , , , {"Digite uma data que seja dia útil."})
			Break
		EndIf
		If Posicione("SA2",1,xFilial("SA2")+M->C7_FORNECE+M->C7_LOJA,"SA2->A2_XDTFIX") == "1"
			If !lChange
				If cEdit == "Não" .Or. cEdit == ""
					Help( , , 'HELP', , "A data não poderá ser alterada se não for exceção de data fixa.", 1, 0 , , , , , , {"Verifique se é uma exceção."})
					Break
				EndIf
			EndIf
				If cEdit <> "Não" .And. cEdit <> ""
				If nDiasMax < DateDiffDay(dDataEmis,  dDataUtil) 
					Help( , , 'HELP', , "A de vencimento informada passa do limite de " +cValToChar(nDiasMax)+" dias a partir da data de emissão.", 1, 0 , , , , , , {"Verifique o parâmetro FS_DVECTO."})
					Break
				EndIf
			EndIf
		EndIf
		
		If Posicione("SA2",1,xFilial("SA2")+M->C7_FORNECE+M->C7_LOJA,"SA2->A2_XDTFIX") == "2"
			If nDiasMax < DateDiffDay(dDataEmis,  dDataUtil)
				Help( , , 'HELP', , "A de vencimento informada passa do limite de " +cValToChar(nDiasMax)+" dias a partir da data de emissão.", 1, 0 , , , , , , {"Verifique o parâmetro FS_DVECTO."})
				Break
			EndIf
		EndIf
		lChange := .F.
		lRetorno := .T.
	End Sequence
Return lRetorno

/*/{Protheus.doc} TrataXDoc
Valida o documento
@author 	Nairan Silva
@since 		17/02/2017
@version 	1.0
@Project	MAN00000462901_EF_004
@return	lógico
/*/
User Function TrataXDoc()

	Local oModel   := FwModelActive()
	Local oModeCab := oModel:GetModel("MODEL_SC7p")
	Local lRet	   := .T.
	Local aArea	   := GetArea()

	oModeCab:SetValue("C7_XDOC", StrZero(Val(oModeCab:GetValue("C7_XDOC")), 9))

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} TrataXSer
Valida o serviço
@author 	Nairan Silva
@since 		17/02/2017
@version 	1.0
@Project	MAN00000462901_EF_004
@return	lógico
/*/
User Function TrataXSer()

	Local aArea	    := GetArea()
	Local cAliasSC7 := GetNextAlias()
	Local cQuery    := ""
	Local lRet	    := .T.
	Local oModel    := FwModelActive()
	Local oModeCab  := oModel:GetModel("MODEL_SC7p")

	cQuery += " SELECT Count(C7_XDOC) PEDIDOS"
	cQuery += " FROM " + RetSqlName("SC7")
	cQuery += " WHERE C7_XDOC  = '" + oModeCab:GetValue("C7_XDOC"   ) + "'"
	cQuery += " AND C7_XSERIE  = '" + oModeCab:GetValue("C7_XSERIE" ) + "'"
	cQuery += " AND C7_FORNECE = '" + oModeCab:GetValue("C7_FORNECE") + "'"
	cQuery += " AND C7_LOJA    = '" + oModeCab:GetValue("C7_LOJA"   ) + "'"
	cQuery += " AND D_E_L_E_T_ = ''"

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAliasSC7, .T., .T.)

	If (cAliasSC7)->(PEDIDOS) > 0
		if !FWIsInCallStack("U_RDCAR99")
			Help(" ", 1, "EXISTNF")
		else
			oModel:SetErrorMessage(oModel:GetId(),"C7_XSERIE" , oModel:GetId(), "C7_XSERIE", "Help", "Nota já existe", , )
		endif
		lRet := .F.
	EndIf

	(cAliasSC7)->(DbCloseArea())
	RestArea(aArea)

	// MMT Incluir validação aqui

	SE2->(DbSetOrder(6))
	//	X:= StrZero( Val(oModeCab:GetValue("C7_XDOC")) , 9 )
	If SE2->(DbSeek(XFilial("SE2") + oModeCab:GetValue("C7_FORNECE") + oModeCab:GetValue("C7_LOJA") + oModeCab:GetValue("C7_XSERIE")+ StrZero( Val(oModeCab:GetValue("C7_XDOC")) , 9 ) ))
		lRet := .F.
		if !FWIsInCallStack("U_RDCAR99")
			Alert("Nota já existe no financeiro")
		else
			oModel:SetErrorMessage(oModel:GetId(),"C7_XSERIE" , oModel:GetId(), "C7_XSERIE", "Help", "Nota já existe no financeiro", , )
		endif
	EndIf

Return lRet

Static Function ExcluiSCR(cNumPed)

	Local aArea		:= GetArea()
	Local aAreaSCR	:= SCR->(GetArea())

	DbSelectArea("SCR")
	SCR->(DbSetOrder(1))

	While SCR->(DbSeek(xFilial("SCR") + "PC" + cNumPed))
		RecLock("SCR", .F.)
		SCR->(DbDelete())
		SCR->(MsUnLock())
	Enddo

	RestArea(aAreaSCR)
	RestArea(aArea)

Return

/*/{Protheus.doc} VerAprov
Permite visualizar o historico da alçada de aprovação
/*/
Static Function VerAprov
	Local oModel      := FwModelActive()
	Local nOperation	:= oModel:GetOperation()
	Private aRotina   := {}
	Nrecc7 := GetRecno(oModel)
	SC7->(DbGoTo(Nrecc7))

	aAdd(aRotina,{"Pesquisar" ,"PesqBrw"   , 0, 1, 0, .F. })
	aAdd(aRotina,{"Visualizar","A120Pedido", 0, 2, 0, Nil })
	a120Posic("SC7", nRecc7, 2,Iif(SC7->C7_TIPO == 1,'PC','AE'), .F., .F. )

Return

/*/{Protheus.doc} F0100413
Gatilho no C7_PRODUTO
@return Local de estoque padrão do produto
/*/
User Function F0100413()
	Local cLocalEst := ""

	cLocalEst := Posicione("SBZ", 1, xFilial("SBZ") + M->C7_PRODUTO, "BZ_LOCPAD")
	If Empty(cLocalEst)
		cLocalEst := Posicione("SB1", 1, xFilial('SB1') + M->C7_PRODUTO, "B1_LOCPAD")
	EndIf

Return cLocalEst

User Function FRecSF1()

	Local aArea		    := GetArea()
	Local aAreaSF1	    := SF1->(GetArea())
	Local cAliasSF1 := GetNextAlias()
	Local lRecusa := .F.
	Local cQuery := ""

	cQuery += "SELECT F1_XSTRECU FROM " + RetSqlName("SF1") + " SF1 "
	cQuery += " WHERE SF1.D_E_L_E_T_ = ' ' "
	cQuery += " AND SF1.F1_FILIAL = '"+ SC7->C7_FILIAL +"' "
	cQuery += " AND SF1.F1_DOC = '"+ SC7->C7_XDOC +"' "
	cQuery += " AND SF1.F1_SERIE = '"+ SC7->C7_XSERIE +"' "
	cQuery += " AND SF1.F1_FORNECE = '"+ SC7->C7_FORNECE +"' "
	cQuery += " AND SF1.F1_LOJA = '"+ SC7->C7_LOJA +"' "

	cQuery := ChangeQuery(cQuery) 

	If Select(cAliasSF1) > 0
		(cAliasSF1)->(DbCloseArea())
	EndIf
	DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAliasSF1, .T., .T.)

	If AllTrim((cAliasSF1)->(F1_XSTRECU)) == "R"
			lRecusa := .T.
	EndIf

	(cAliasSF1)->(DbCloseArea())
	
		/*/If AllTrim(Posicione("SF1", 1, SC7->(C7_FILIAL+C7_XDOC+C7_XSERIE+C7_FORNECE+C7_LOJA), "F1_XSTRECU")) == "R"
			lRecusa := .T.
		EndIf/*/
	RestArea(aAreaSF1)
	RestArea(aArea)

Return ( lRecusa )

User Function FRecSE2

	Local aArea		    := GetArea()
	Local aAreaSE2	    := SE2->(GetArea())

	Local lRecusa := .F.

	// D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	// F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	// E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
	// E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO

	//	E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO

	SE2->(DbSetOrder(6))
	If SE2->(DbSeek(XFilial("SE2") + SC7->( C7_FORNECE + C7_LOJA + C7_XSERIE + C7_XDOC  )))
		//		lRecusa := !Empty(SE2->E2_XDTRECU)
		IF SE2->E2_XSTRECU == 'R'
			lRecusa := .T.
		Endif
	EndIf

	RestArea(aAreaSE2)
	RestArea(aArea)

Return ( lRecusa )

/*/{Protheus.doc} F0100414
Função para alterar o código e o nome do solicitante.

@Project MAN0000007423048_EF_77
@author  Reinaldo Dias
@since   10/05/2019
@version P12.1.17
/*/
User Function F0100414()

	If SC7->C7_XUSR == __CUSERID
		Help("", 1, "F0100401", , "Essa solicitação já pertence a esse código de solicitante.", 1, 0, , , , , , {"Por favor, verificar..."})
		Return
	EndIf

	If MsgYesNo("Confirma alteração do solicitante [ " + AllTrim(UsrRetName(SC7->C7_XUSR)) + " ] para o novo solicitante [ " +;
			AllTrim(UsrRetName(__cUserId)) + " ] ?")
		RecLock("SC7",.F.)
		SC7->C7_XUSR    := __cUserId
		SC7->C7_XUSRSP    := UsrFullName(cUserIdBk)
		SC7->C7_SOLICIT := AllTrim(UsrRetName(__cUserId))
		SC7->(MsUnLock())
	EndIf

/*
User Function FRecSF1()

Local aArea		    := GetArea()
Local aAreaSF1	    := SF1->(GetArea())

Local lRecusa := .F.

SF1->(DbSetOrder(1))
	If SF1->(DbSeek(XFilial("SF1") + SC7->(C7_XDOC + C7_XSERIE + C7_FORNECE + C7_LOJA)))
lRecusa := !Empty(SF1->F1_XDTRECU)
	EndIf

RestArea(aAreaSF1)
RestArea(aArea)

Return ( lRecusa )

User Function FRecSE2()

Local aArea		    := GetArea()
Local aAreaSE2	    := SE2->(GetArea())

Local lRecusa := .F.

SE2->(DbSetOrder(1))
	If SE2->(DbSeek(XFilial("SE2") + SC7->( C7_FORNECE + C7_LOJA + C7_XSERIE + C7_XDOC  )))
lRecusa := !Empty(SE2->E2_XDTRECU)
	EndIf

RestArea(aAreaSE2)
RestArea(aArea)

Return ( lRecusa )
*/

User Function ValidaP02()
	/*/{Protheus.doc} ValidaP02
	Validação usuário no campo C7_XTIPO
	Lucas Miranda de Aguiar 10/10/2019
	/*/

	Local cBloqueio := ""
	Local lValida   := .F.

	cExistCpo := AllTrim(Posicione("P02", 1, xFilial("P02") + M->C7_XTIPO, 	 "P02_COD"))
	If Posicione("P02", 1, xFilial("P02") + M->C7_XTIPO, "P02_MSBLQL") == "1"
		Help("", 1, "F0100401", , "O tipo de requisição selecionado está bloqueado.", 1, 0, , , , , , {"Atualize a tabela Tipos de requisição."})
	ElseIf !ExistCpo('P02', M->C7_XTIPO)
		Help("", 1, "F0100401", , "Não existe registro relacionado a este código.", 1, 0, , , , , , {"Atualize a tabela Tipos de requisição."})
	Else
		lValida := .T.
	EndIf
Return lValida

//Início - 10019683 
/*/{Protheus.doc} IsOpenModel
Chamada de funções de validações na abertura cadastro.
@authora 	Thais Paiva 
@since 		15/10/2020
@version 	1.0
@param 		oModelo
@return	lógico
/*/

Static Function IsOpenModel(oModelo)

	Local lOk := .T.
	Local nOpca     := oModelo:GetOperation()
	Local oMdlMain  := oModelo:GetModel("MODEL_SC7p")

	If nOpca == MODEL_OPERATION_UPDATE
		SC7->(DbSetOrder(1))
		SC7->(DbSeek(XFilial("SC7")+oMdlMain:GetValue("C7_NUM")))
		If SC7->C7_QTDACLA > 0 .AND. SC7->C7_CONAPRO = 'L'
			Help("", 1, "F0100401", ,;
				"Esta Solicitação de Pagamento possui uma pré nota criada!."+;
				"Para seguir com a alteração desta solicitação de pagamento, será necessário excluir a pré nota fiscal.", 1, 0, , , , , , {"Excluir a pré nota fiscal"})
			lOk := .F.
		EndIf
	EndIf

Return lOk
//Fim - - 10019683 



User Function fRetenc()
	Local aArea := GetArea()
	if !FWIsInCallStack("U_RDCAR99")
		If !(AllTrim(M->C7_XTIPO) $ AllTrim(GetNewPar("FS_TPSP","CFR")))
			MsgInfo("Prezado(a), o campo de código de retenção não deverá ser preenchido para o tipo de solicitação " + M->C7_XTIPO + ".")
		endif
	else
		If !(AllTrim(M->C7_XTIPO) $ AllTrim(GetNewPar("FS_TPSP","CFR")))
			oModel	:= FWLoadModel("F0100401")
			oModel:SetErrorMessage(, , oModel:GetId(), , "Help", "Erro na função fRetenc.", "Prezado(a), o campo de código de retenção não deverá ser preenchido para o tipo de solicitação ", , )
		endif
	endif
	DbSelectArea("P02")
	DbSeek(xFilial('P02') + M->C7_XTIPO)
	M->C7_XTIPOD := P02->P02_DESC
	RestArea(aArea)
Return P02->P02_DESC


Static Function fGetFils(cUserP32,l1User)

	Local aArea := GetArea()
	Local cQuery := ""
	Local cAliasSP := GetNextAlias()
	Local cFils := ""
	Local aUsr := {}
	Local nX := 1
	Local cQuery2 := ""

	Default cUserP32 := ""
	Default l1User := .F.

	/*/If l1User
	cQuery := " SELECT C7_FILIAL FROM " + RetSqlName("SC7")
	cQuery += " WHERE D_E_L_E_T_ = ' ' AND C7_XSOLPAG = '1' AND C7_XUSR = '"+cUserP32+"'"
	cQuery += " GROUP BY C7_FILIAL"
Else
	cQuery := "SELECT C7_FILIAL FROM " + RetSqlName("SC7")
	cQuery += " WHERE D_E_L_E_T_ = ' ' AND C7_XSOLPAG = '1' AND C7_XUSR IN " + FTRATAIN(cUserP32)
	cQuery += " GROUP BY C7_FILIAL"

	EndIf/*/

	cQuery := " WITH partitioned_data AS (                                                                                          "
	cQuery += "     SELECT                                                                                                          "
	cQuery += "         'SC7.C7_FILIAL = ''' || C7_FILIAL || '''' AS condition,                                                     "
	cQuery += "         CEIL(ROW_NUMBER() OVER (ORDER BY C7_FILIAL) / 500) AS part                                                  "
	cQuery += "     FROM " + RetSqlname("SC7") + " SC7 "
	cQuery += "     WHERE D_E_L_E_T_ = ' '                                                                                          "
	cQuery += "       AND C7_XSOLPAG = '1'                                                                                          "
	cQuery += "       AND " + cUserP32
	cQuery2 += "       GROUP BY C7_FILIAL                                                                                            "
	cQuery2 += " ),                                                                                                                  "
	cQuery2 += " concatenated_parts AS (                                                                                             "
	cQuery2 += "     SELECT                                                                                                          "
	cQuery2 += "         part,                                                                                                       "
	cQuery2 += "         TO_CLOB(LISTAGG(condition, ' OR ') WITHIN GROUP (ORDER BY condition)) AS partial_result                     "
	cQuery2 += "     FROM partitioned_data                                                                                           "
	cQuery2 += "     GROUP BY part                                                                                                   "
	cQuery2 += " ),                                                                                                                  "
	cQuery2 += " final_result AS (                                                                                                   "
	cQuery2 += "     SELECT                                                                                                          "
	cQuery2 += "         '(' || LISTAGG(partial_result, ' OR ') WITHIN GROUP (ORDER BY part) || ')' AS resultado_clob                "
	cQuery2 += "     FROM concatenated_parts                                                                                         "
	cQuery2 += " )                                                                                                                   "
	cQuery2 += " SELECT resultado_clob                                                                                               "
	cQuery2 += " FROM final_result																									"
	//cQuery := ChangeQuery(cQuery)

	DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery+cQuery2), cAliasSP, .T., .T.)

	cFils := (cAliasSP)->(resultado_clob)


	/*/While !(cAliasSP)->(EOF())

	cFils := cFils + (cAliasSP)->C7_FILIAL + "|"

	(cAliasSP)->(DbSkip())
	EndDo/*/

	(cAliasSP)->(DbCloseArea())
	RestArea(aArea)
Return cFils
//Valida campo When Jurico.
User Function fVldJur2(oModel)
	Local lRet := .F.

	If !Empty(FWFldGet("C7_XTIPO"))
		If Alltrim(FWFldGet("C7_XTIPO")) $ AllTrim(SuperGetMV("MV_XTIPJUR",,"CJU"))
			lRet := .T.
		EndIf
	endif
Return lRet
//Apaga preenchimento dos campos C7_XNUMPRO e C7_XTPCJU caso não seja juridico.
User Function fVLDJUR1()
	/*Local oModelActive := FwModelActive()
	Local oStruSC7p := oModelActive:GetModel("MODEL_SC7p")
	
	If !Empty(FWFldGet("C7_XTIPO"))
		If !(Alltrim(FWFldGet("C7_XTIPO")) $ AllTrim(SuperGetMV("MV_XTIPJUR",,"CJU")))
			oStruSC7p:SetValue("C7_XNUMPRO","")	
			oStruSC7p:SetValue("C7_XTPCJU","")	
		endif
	endif*/
Return ""
/*/Static Function fUsrDtFixa()

	Local aArea := GetArea()
	Local lRet := .F.
	Local aGrupos := {}
	Local nX := 1
	Local cGrupos := GetNewPar("MV_XGPDTF","")

	aGrupos := UsrRetGrp()

	For nX := 1 To Len(aGrupos)

		If aGrupos[nX] $ cGrupos
			lRet := .T.
			Exit
		EndIf

	Next nX

	RestArea(aArea)
Return lRet

User Function VALFNFIX()

	Local aArea := GetArea()
	Local lRetorno := .F.

	Begin Sequence
		If Empty(AllTrim(M->C7_FORNECE))
			MsgInfo("O código do fornecedor precisa estar preenchido para esta ação!")
			Break
		ElseIf Posicione("SA2",1,xFilial("SA2")+M->C7_FORNECE+M->C7_LOJA,"SA2->A2_XDTFIX") <> "1" .And. M->C7_XDTEXCE == "Sim"
			MsgInfo("Este fornecedor não recebe pagamentos em data fixa!")
			M->C7_XDTEXCE := ""
			Break
		EndIf
		lRetorno := .T.
	End Sequence

	RestArea(aArea)
Return lRetorno/*/


//Função da consulta padrão do campo D1_XRETINS
//Lucas Miranda de Aguiar 04/05/2023
/*/User Function XFCPINSS()

Local aAreaF1 := SF1->(GetArea())
Local aAreaD1 := SD1->(GetArea())
Local cRet := "1162"
Local cQuery := ""
Local cAliasC7 := GetNextAlias()

	If ALTERA
		If SF1->F1_XSOLPAG == "1"
			cQuery += "SELECT C7_XRETINS FROM "+RETSQLNAME("SC7")+" WHERE D_E_L_E_T_ = ' ' AND C7_XSOLPAG = '1'"
			cQuery += " AND C7_FILIAL = '"+SF1->F1_FILIAL+"' AND C7_XDOC = '"+SF1->F1_DOC+"' AND C7_FORNECE = '"+SF1->F1_FORNECE+"'"
			cQuery += " AND C7_XSERIE = '"+SF1->F1_SERIE+"' AND C7_LOJA = '"+SF1->F1_LOJA+"'"

			DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAliasC7, .T., .T.)

			If !(cAliasC7)->(EOF())
				If !Empty((cAliasC7)->C7_XRETINS)
					cRet := (cAliasC7)->C7_XRETINS
				EndIf
			EndIf

		(cAliasC7)->(DbCloseArea())
		EndIf
	EndIf

RestArea(aAreaF1)
RestArea(aAreaD1)
Return cRet
/*/
Static function fTrataIn(cDados)
Return Replace(FormatIn(SubStr(replace(cDados,"|",","),1,Len(cDados)), ","),",''","")

Static Function fTrataOr(cCampo,cDados)

Local aDados := STRTOKARR(cDados, "|")
Local nx := 01
Local cRet := ""


For nX := 01 To Len(aDados)

cRet += cRet + " " + cCampo + " = '"+cDados[nX] + "' "

Next nX

Return cRet
//Função When do campo C7_XDBAUT
//Lucas Miranda de Aguiar 16/09/2024
User Function fxdbaut1()

Local lRet := .F.
Local cTipos := GetNewPar("FS_TPREQUI")

If AllTrim(M->C7_XTIPO) $ cTipos
	lRet := .T.
EndIf

Return lRet

Static Function CancelModel(oModel)
	Local aAreas := { SC7->(GetArea()) }
	lCancel := .T.
	AEval( aAreas, {|aArea| RestArea(aArea)})		
Return .T.


	//Valida condição de pagamento de acordo com a nova política da empresa
	//Lucas Miranda de Aguiar 15/06/2025
User Function fchkcond()

Local aRet := {}

aRet := U_MSCHKCOND(M->C7_COND,M->C7_FORNECE,M->C7_LOJA)  

If !aRet[1]
Help("", 1, "F0100401", , aRet[2], 1, 0, , , , , , {"Revise a condição de pagamento escolhida."})
EndIf

Return aRet[1]
