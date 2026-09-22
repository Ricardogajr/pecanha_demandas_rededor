#include "totvs.ch"
#include "rwmake.ch"
#Include 'Protheus.ch'
#Include "TopConn.ch"

/*/{Protheus.doc} KITINCORP
Rotina para copiar dados de uma filial para outra filial.
@type function
@version  
@author Ricardo Junior
@since 07/12/2020
@return variant, return_description
/*/
User Function KITINCORP()
	Local _aRetorno := {}
	Private aPerg := {}
	Private aRet := {}
	Private aRetPerg2 := {}
	Private lRetScript := .F.
	Private cTabela := ""
	Private oMark	:= Nil
	Private aRetFil := {}
	Private aListMms := {}
	//Executa perguntas e preenche array aPerg
	If !fPergunta()
		Return
	EndIf

	cTabela := UPPER(aRet[3])

	//Valida se a filial origem existe
	If !FWFilExist(cEmpAnt, aRet[1])
		MsgInfo("A Filial Origem inválida.")
		Return
	EndIf

	//Valida se a filial destino existe
	If !FWFilExist(cEmpAnt, aRet[2])
		MsgInfo("A Filial Destino inválida.")
		Return
	EndIf

	//Valida a existencia da tabela.
	If !TCCanOpen(RetSqlName(aRet[3]))
		MsgInfo("A Tabela "+aRet[3]+" não existe no sistema.")
		Return
	EndIf

	//DbSelectArea("Sx2")
	_aRetorno := FwSX2Util():GetSX2data(aRet[3], {"X2_MODO"}) //DbSetOrder(1)
	If Len(_aRetorno) > 0 //DbSeek(aRet[3])
		If AllTrim(_aRetorno[1][2]) != "E"
			MsgInfo("A Tabela "+ aRet[3] +" não é exclusiva e não poderá ser importada.")
			Return
		EndIf
	EndIf

	If !(cValToChar(aRet[6]) $ "2|Sim") .And. !(cValToChar(aRet[7]) $ "2|Sim")//Não Rodar o Script e Não Integra pedido
		MsgRun("Importando tabela","Aguarde...",{|| fImpTabela() })
		Return
	EndIf

	If (cValToChar(aRet[7]) $ "2|Sim")//Integra Pedido
		MsgRun("Selecionando pedidos","Aguarde...",{|| fIntPedidos() })
		Return
	EndIf

	If (cValToChar(aRet[6]) $ "2|Sim")
		lRetScript := FScript()
		If cTabela == "SC7" .And. MsgYesNo("Deseja integrar os pedidos de compras?","Integração")
			if lRetScript
				Processa( {|| fIntPedidos() }, "Aguarde...", "Integrando pedido de compras...",.F.)
				Return
			endif
		EndIf
	EndIf
Return
/*/{Protheus.doc} fImpTabela
Função para importação da tabela.
@type function
@version  
@author Ricardo Junior
@since 07/12/2020
@return variant, return_description
/*/
Static Function fImpTabela()
	Local cAliasTMP := GetNextAlias()
	Local nReg  := 0
	Local cArqRed   := "\RDANEXOS\"
	Local cCampFil := ""
	Local cCampoFil  := ""
	Local cCampoFil2 := ""
	Local cCampoFil3 := ""
	Local oError := ErrorBlock({|e| MsgAlert("Mensagem de Erro: " +chr(10)+ e:Description)})
	Local lRegra := .T.
	Local cDecTNN := ""
	Local nX := 0
	Local nY := 0

	lRegra := iIf(cValToChar(aRet[5]) $ "1|Sim", .T., .F.)

	If !lRegra .And. Empty(aRet[4])
		Alert("Não será possivel seguir com a rotina. Caso escolha a opção 'NÃO' no campo Regras incorporação, será obrigatório informar o campo Condição.")
		Return
	EndIf

	If lRegra
		DbSelectArea(cTabela)
		If DbSeek(aRet[2])
			Alert("Existem registros na filial destino("+aRet[2]+"), Sendo assim, não será efetuada a importação de dados." + CRLF +;
				"Solução: Só será possível fazer a importação para tabelas que não contenham nenhum registro.")
			Return
		EndIf
	EndIf

	If cTabela == "P17"
		aRetFil := {"P17_FTRATA"}
		cCampoFil := "P17_FTRATA"
	ElseIf cTabela == "RCC"
		aRetFil := {"RCC_FIL"}
		cCampoFil := "RCC_FIL"
	ElseIf cTabela == "LHT"
		aRetFil := {"LHT_FILIAL", "LHT_FILMAT"}
		cCampoFil := "LHT_FILIAL"
	ElseIf cTabela == "SC7"
		aRetFil := {"C7_FILIAL", "C7_FISCORI","C7_FILENT"}
		cCampoFil := "C7_FILIAL"
	ElseIf cTabela == "TK8"
		aRetFil := {"TK8_FILIAL", "TK8_FILRE"}
		cCampoFil := "TK8_FILIAL"
	ElseIf cTabela == "TNN"
		aRetFil := {"TNN_FILIAL", "TNN_FILRE1", "TNN_FILRE2", "TNN_FILPRE", "TNN_FILSEC", "TNN_FILPSE", "TNN_FILSSE" }
		cCampoFil := "TNN_FILIAL"
	ElseIf cTabela == "TNC"
		aRetFil := {"TNC_FILIAL", "TNC_FILFUN" }
		cCampoFil := "TNC_FILIAL"
	ElseIf cTabela == "TNO"
		aRetFil := {"TNO_FILIAL", "TNO_FILMAT"}
		cCampoFil := "TNO_FILIAL"
	ElseIf cTabela == "TNQ"
		aRetFil := {"TNQ_FILIAL", "TNQ_FILMAT"}
		cCampoFil := "TNQ_FILIAL"
	ElseIf cTabela == "TKM"
		aRetFil := {"TKM_FILIAL", "TKM_FILMAT"}
		cCampoFil := "TKM_FILMAT"
	ElseIf cTabela == "SF1"
		aRetFil := {"F1_FILIAL", "F1_FILORIG"}
		cCampoFil := "F1_FILIAL"
	ElseIf cTabela == "SD1"
		aRetFil := {"D1_FILIAL", "D1_FILORI"}
		cCampoFil := "D1_FILIAL"
	ElseIf cTabela == "SE1"
		aRetFil := {"E1_FILIAL", "E1_FILORIG"}
		cCampoFil := "E1_FILIAL"
	ElseIf cTabela == "SE2"
		aRetFil := {"E2_FILIAL", "E2_FILORIG"}
		cCampoFil := "E2_FILIAL"
	ElseIf cTabela == "SEF"
		aRetFil := {"EF_FILIAL", "EF_FILORIG"}
		cCampoFil := "EF_FILIAL"
	ElseIf cTabela == "SEU"
		aRetFil := {"EU_FILIAL", "EU_FILORI"}
		cCampoFil := "EU_FILIAL"
	Else
		If SubStr(cTabela,1,1) == "S"
			cCampoFil := SubStr(cTabela,2,2) + "_FILIAL"
			aRetFil := {cCampoFil}
		Else
			cCampoFil := cTabela + "_FILIAL"
			aRetFil := {cCampoFil}
		EndIf
	EndIf

	For nX := 1 to Len(aRetFil)
		If cTabela == "TNN"
			cCampFil += " DECODE("+aRetFil[nx]+", '" +Space(TamSx3(aRetFil[nx])[1])+ "', '"+Space(TamSx3(aRetFil[nx])[1])+ "', '" +aRet[2]+ "') " +aRetFil[nx]+","
			//ElseIf cTabela == "TNC"
			//	cCampFil += " DECODE("+aRetFil[nx]+", '" +aRet[1]+ "', '"+aRet[2]+"', "+aRetFil[nX]+") " +aRetFil[nx]+","
		else
			cCampFil += " DECODE("+aRetFil[nx]+", '" +aRet[1]+ "', '"+aRet[2]+"', "+aRetFil[nX]+") " +aRetFil[nx]+","
			//cCampFil += "'"+aRet[2]+"' " +aRetFil[nx] + ","
		EndIf
	Next

	If cTabela $ "RBR|RB6"
		fPerg2()
	EndIf

	cFilOrigem := aRet[1]

	cTabelaAlias := cTabela + "_1" //Foi necessário mudar o alias por causa da tabela SET que é uma palavra reservada do banco.

	cSqlAux := ""
	cSQL := " SELECT " + cCampFil
	If cTabela == "RCL"//Adicionada essa regra para as tabelas RCL com o preenchimento do campo RCL_STATUS e RCL_OPOSTO.
		cSQL += " ' ' RCL_OPOSTO, DECODE(RCL_STATUS,'2', '1', RCL_STATUS) RCL_STATUS, "
	ElseIf cTabela == "SC7"
		if SubStr(aRet[8],1,1) == "1"
			cSQL += " ' ' C7_XNUM, ' ' C7_XFRONT, ' ' C7_XID, 0 C7_QUJE, (C7_QUANT - C7_QUJE) C7_QUANT," + CRLF
			cSQL += " ((C7_QUANT - C7_QUJE)  * C7_PRECO) C7_TOTAL," + CRLF
			cSQL += " (DECODE(P17.P17_P12FRO, 'M', DECODE((("+cTabelaAlias+ ".C7_QUANT - "+cTabelaAlias+ ".C7_QUJE)*P17.P17_COMP) * "+cTabelaAlias+ ".C7_XPRECO,1, C7_XTOTAL,(("+cTabelaAlias+ ".C7_QUANT - "+cTabelaAlias+ ".C7_QUJE)*P17.P17_COMP) * "+cTabelaAlias+ ".C7_XPRECO),DECODE((("+cTabelaAlias+ ".C7_QUANT - "+cTabelaAlias+ ".C7_QUJE)/P17.P17_COMP) * "+cTabelaAlias+ ".C7_XPRECO,1,C7_XTOTAL,(("+cTabelaAlias+ ".C7_QUANT - "+cTabelaAlias+ ".C7_QUJE)/P17.P17_COMP) * "+cTabelaAlias+ ".C7_XPRECO)))  C7_XTOTAL," + CRLF
			cSQL += " DECODE(P17.P17_P12FRO, 'M', DECODE((("+cTabelaAlias+ ".C7_QUANT - "+cTabelaAlias+ ".C7_QUJE)*P17_COMP),1, ("+cTabelaAlias+ ".C7_QUANT - "+cTabelaAlias+ ".C7_QUJE),(("+cTabelaAlias+ ".C7_QUANT - "+cTabelaAlias+ ".C7_QUJE)*P17_COMP)) , DECODE((("+cTabelaAlias+ ".C7_QUANT - "+cTabelaAlias+ ".C7_QUJE)/P17.P17_COMP),1, ("+cTabelaAlias+ ".C7_QUANT - "+cTabelaAlias+ ".C7_QUJE),(("+cTabelaAlias+ ".C7_QUANT - "+cTabelaAlias+ ".C7_QUJE)/P17.P17_COMP))) C7_XQTDPC," + CRLF
		endif
	ElseIf cTabela == "RBR"
		cSQL += "'"+DTOS(aRetPerg2[1])+"' RBR_DTREF,"
	ElseIf cTabela == "RB6"
		cSQL += "'"+DTOS(aRetPerg2[1])+"' RB6_DTREF,"
	EndIf

	cSQL += cTabelaAlias +".* FROM " + RetSqlName(cTabela) + " " + cTabelaAlias
	cSqlAux := cSQL

	//Regra do Banco de conhecimento
	If lRegra
		If cTabela == "P09"
			cSQL += " INNER JOIN "+ RetSqlName("SF1")+" SF1" + CRLF
			cSQL += " ON SF1.F1_FILIAL = '"+aRet[2]+"'" + CRLF
			cSQL += " AND TRIM("+cTabelaAlias+".P09_CODORI) = TRIM(SF1.F1_DOC||SF1.F1_SERIE||SF1.F1_FORNECE||SF1.F1_LOJA)" + CRLF
			cSQL += " AND SF1.D_E_L_E_T_ = ' '" + CRLF
			cSQL += " WHERE "
			cSQL += cCampoFil + " = '" + cFilOrigem +"'"	// Filial Atual
			cSQL += " AND "+cTabelaAlias+".D_E_L_E_T_ = ' ' "
			cSQL += " AND P09_ROTINA IN ('FINA050', 'FINA750', 'MATA103')" + CRLF
			cSQL += " UNION " + CRLF
			cSQL += " SELECT '"+aRet[2]+"' "+cCampoFil+", " + Iif(!Empty(cCampoFil2), "'"+aRet[2]+"' " + cCampoFil2 + ",", "")
			cSQL += cTabelaAlias+".* FROM " + RetSqlName(cTabela) + " " + cTabelaAlias
			cSQL += " INNER JOIN " + RetSqlName("SD1") + " SD1" + CRLF
			cSQL += " ON SD1.D1_FILIAL = '"+aRet[2]+"'" + CRLF
			cSQL += " AND TRIM(" + cTabelaAlias + ".P09_CODORI) = TRIM(D1_PEDIDO)" + CRLF
			cSQL += " AND SD1.D_E_L_E_T_ = ' '" + CRLF
			cSQL += " WHERE "
			cSQL += cCampoFil + " = '" + cFilOrigem +"'"	// Filial Atual
			cSQL += " AND "+cTabelaAlias+".D_E_L_E_T_ = ' ' "
			cSQL += " AND P09_ROTINA IN ('MATA120', 'MATA121', 'F0100401')" + CRLF
		EndIf

		if cTabela == "P00"
			cSql += " INNER JOIN "+ RetSqlName("SE2")+"  SE2 "
			cSql += " ON SE2.E2_FILIAL   = "+cTabelaAlias+".P00_FILIAL "
			cSql += " AND SE2.E2_NUM     = "+cTabelaAlias+".P00_NUM "
			cSql += " AND SE2.E2_PREFIXO = "+cTabelaAlias+".P00_PREFIX "
			cSql += " AND SE2.E2_FORNECE = "+cTabelaAlias+".P00_FORNEC "
			cSql += " AND SE2.E2_SALDO > 0 "

		endif
	EndIf
	If cTabela == "SC7"
		cSQL += " LEFT JOIN "+ RetSqlName("P17")+"  P17" + CRLF
		cSQL += " ON P17.D_E_L_E_T_ = ' '" + CRLF
		cSQL += " AND P17.P17_FTRATA = "+cTabelaAlias+ ".C7_FILIAL" + CRLF
		cSQL += " AND P17.P17_COD = "+cTabelaAlias+ ".C7_PRODUTO" + CRLF
	EndIf

	If cTabela != "P09" .Or. !lRegra
		cSQL += " WHERE "
		cSQL += cCampoFil + " = '" + cFilOrigem +"'"	// Filial Atual
		cSQL += " AND "+cTabelaAlias+".D_E_L_E_T_ = ' ' "
	EndIf

	//Trata se o comando AND existe na query, caso não, adiciona.
	If !Empty(aRet[4])
		cQueryAdd := AllTrim(aRet[4])
		If SubStr(cQueryAdd,1,3) != "AND"
			cQueryAdd := " AND " + cQueryAdd
		EndIf
		cSQL += cQueryAdd
	EndIf

	If lRegra
		Do Case
		Case cTabela == "SE2"
			cSQL += " AND "+cTabelaAlias+".E2_SALDO > 0 "
		Case cTabela == "SF1"
			cSQL += " AND ("+cTabelaAlias+ ".F1_FILIAL||"+cTabelaAlias+ ".F1_DOC||"+cTabelaAlias+ ".F1_SERIE||"+cTabelaAlias+ ".F1_FORNECE||"+cTabelaAlias+ ".F1_LOJA IN ( " + CRLF
			cSQL += " SELECT DISTINCT SE2.E2_FILIAL||SE2.E2_NUM||SE2.E2_PREFIXO||SE2.E2_FORNECE||SE2.E2_LOJA  " + CRLF
			cSQL += " FROM "+RetSqlName("SE2")+" SE2   " + CRLF
			cSQL += " WHERE E2_FILIAL = "+cTabelaAlias+ ".F1_FILIAL " + CRLF
			cSQL += " AND SE2.E2_NUM = "+cTabelaAlias+ ".F1_DOC " + CRLF
			cSQL += " AND SE2.E2_PREFIXO  = "+cTabelaAlias+ ".F1_SERIE " + CRLF
			cSQL += " AND SE2.E2_FORNECE  = "+cTabelaAlias+ ".F1_FORNECE  " + CRLF
			cSQL += " AND SE2.E2_LOJA  = "+cTabelaAlias+ ".F1_LOJA " + CRLF
			cSQL += " AND SE2.D_E_L_E_T_ = ' ' " + CRLF
			cSQL += " AND SE2.E2_SALDO > 0) " + CRLF
			/*cSQL += " OR "+cTabelaAlias+ ".F1_FILIAL||"+cTabelaAlias+ ".F1_DOC||"+cTabelaAlias+ ".F1_SERIE||"+cTabelaAlias+ ".F1_FORNECE||"+cTabelaAlias+ ".F1_LOJA IN (" + CRLF
			cSQL += " SELECT SD1.D1_FILIAL|| SD1.D1_DOC|| SD1.D1_SERIE|| SD1.D1_FORNECE|| SD1.D1_LOJA" + CRLF
			cSQL += " FROM "+RetSqlName("SD1")+" SD1" + CRLF
			cSQL += " INNER JOIN "+RetSqlName("SC7")+" SC7" + CRLF
			cSQL += " ON SC7.C7_FILIAL ='"+aRet[1]+"'" + CRLF
			cSQL += " AND SD1.D1_PEDIDO || SD1.D1_ITEMPC = SC7.C7_NUM || SC7.C7_ITEM" + CRLF
			cSQL += " AND C7_QTDACLA > 0" + CRLF
			cSQL += " AND C7_RESIDUO = ' '" + CRLF
			cSQL += " AND C7_XSOLPAG = '1'" + CRLF
			cSQL += " AND C7_ENCER = ' '" + CRLF
			cSQL += " AND SC7.D_E_L_E_T_ = ' '" + CRLF
			cSQL += " WHERE SD1.D_E_L_E_T_ = ' '" + CRLF
			cSQL += " AND SD1.D1_FILIAL = '"+aRet[1]+"'" + CRLF
			cSQL += " AND SD1.D1_TES = ' '" + CRLF
			cSQL += " GROUP BY SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA))" + CRLF*/
			cSQL += " OR (SF1_1.D_E_L_E_T_ = ' ' AND SF1_1.F1_FILIAL ='"+aRet[1]+"' AND SF1_1.F1_XSOLPAG = '1' AND SF1_1.F1_STATUS = ' '))"
		Case cTabela == "SD1"
			cSQL += " AND "+cTabelaAlias+".D1_FILIAL||"+cTabelaAlias+".D1_DOC||"+cTabelaAlias+".D1_SERIE||"+cTabelaAlias+".D1_FORNECE||"+cTabelaAlias+".D1_LOJA IN ( " + CRLF
			cSQL += " SELECT DISTINCT SE2.E2_FILIAL||SE2.E2_NUM||SE2.E2_PREFIXO||SE2.E2_FORNECE||SE2.E2_LOJA  " + CRLF
			cSQL += " FROM "+RetSqlName("SE2")+" SE2   " + CRLF
			cSQL += " WHERE E2_FILIAL = "+cTabelaAlias+".D1_FILIAL " + CRLF
			cSQL += " AND SE2.E2_NUM = "+cTabelaAlias+".D1_DOC " + CRLF
			cSQL += " AND SE2.E2_PREFIXO  = "+cTabelaAlias+".D1_SERIE " + CRLF
			cSQL += " AND SE2.E2_FORNECE  = "+cTabelaAlias+".D1_FORNECE  " + CRLF
			cSQL += " AND SE2.E2_LOJA  = "+cTabelaAlias+".D1_LOJA " + CRLF
			cSQL += " AND SE2.D_E_L_E_T_ = ' ' " + CRLF
			cSQL += " AND SE2.E2_SALDO > 0)" + CRLF
			/*cSQL += " OR "+cTabelaAlias+".D1_FILIAL||"+cTabelaAlias+".D1_DOC||"+cTabelaAlias+".D1_SERIE||"+cTabelaAlias+".D1_FORNECE||"+cTabelaAlias+".D1_LOJA IN (
			cSQL += " SELECT SD1.D1_FILIAL|| SD1.D1_DOC|| SD1.D1_SERIE|| SD1.D1_FORNECE|| SD1.D1_LOJA" + CRLF
			cSQL += " FROM "+RetSqlName("SD1")+" SD1" + CRLF
			cSQL += " INNER JOIN "+RetSqlName("SC7")+" SC7" + CRLF
			cSQL += " ON SC7.C7_FILIAL ='"+aRet[1]+"'" + CRLF
			cSQL += " AND SD1.D1_PEDIDO || SD1.D1_ITEMPC = SC7.C7_NUM || SC7.C7_ITEM" + CRLF
			cSQL += " AND C7_QTDACLA > 0" + CRLF
			cSQL += " AND C7_RESIDUO = ' '" + CRLF
			cSQL += " AND C7_XSOLPAG = '1'" + CRLF
			cSQL += " AND C7_ENCER = ' '" + CRLF
			cSQL += " AND SC7.D_E_L_E_T_ = ' '" + CRLF
			cSQL += " WHERE SD1.D_E_L_E_T_ = ' '" + CRLF
			cSQL += " AND SD1.D1_FILIAL = '"+aRet[1]+"'" + CRLF
			cSQL += " AND SD1.D1_TES = ' '" + CRLF
			cSQL += " GROUP BY SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA))" + CRLF*/
			cSQL += " UNION " + CRLF
 			cSQL += " SELECT '"+aRet[2]+"' D1_FILIAL, D1_FILORI, SD1.* FROM "+RetSqlName("SD1")+" SD1 WHERE D_E_L_E_T_  = ' ' AND D1_TES = ' ' AND D1_FILIAL = '"+aRet[1]+"'"
		Case cTabela == "SC7"
			cSQL += " AND "+cTabelaAlias+ ".C7_QUJE < "+cTabelaAlias+ ".C7_QUANT" + CRLF
			cSQL += " AND "+cTabelaAlias+ ".C7_CONAPRO != 'R'" + CRLF
			cSQL += " AND "+cTabelaAlias+ ".C7_ENCER = ' '" + CRLF
			cSQL += " AND "+cTabelaAlias+ ".C7_RESIDUO = ' '" + CRLF
			cSQL += " UNION ALL " + CRLF			
			cSQlAux := Replace(cSqlAux, "_1", "_2")//troca o alias para 2
			cSQL += cSqlAux + CRLF//Verifica se Pedidos encerrados e com titulos em aberto.
			cSQL += " WHERE SC7_2.D_E_L_E_T_ = ' ' " + CRLF
			cSQL += " AND SC7_2.C7_FILIAL = '"+aRet[1]+"' " + CRLF
			cSQL += " AND SC7_2.C7_CONAPRO = 'L'" + CRLF
			cSQL += " AND SC7_2.C7_ENCER = 'E'" + CRLF
			cSQL += " AND SC7_2.C7_RESIDUO = ' '" + CRLF
			cSQL += " AND SC7_2.C7_FILIAL||SC7_2.C7_XDOC||SC7_2.C7_XSERIE||SC7_2.C7_FORNECE||SC7_2.C7_LOJA IN (" + CRLF
			cSQL += " SELECT E2_FILIAL||E2_NUM||E2_PREFIXO||E2_FORNECE||E2_LOJA FROM "+RetSqlName("SE2")+" SE2" + CRLF
			cSQL += " WHERE SE2.E2_FILIAL = SC7_2.C7_FILIAL" + CRLF
			cSQL += " AND SE2.D_E_L_E_T_ = ' ' " + CRLF
			cSQL += " AND SE2.E2_NUM = SC7_2.C7_XDOC " + CRLF
			cSQL += " AND SE2.E2_PREFIXO = SC7_2.C7_XSERIE " + CRLF
			cSQL += " AND SE2.E2_FORNECE = SC7_2.C7_FORNECE" + CRLF
			cSQL += " AND SE2.E2_LOJA = SC7_2.C7_LOJA" + CRLF
			cSQL += " AND SE2.E2_SALDO > 0 )" + CRLF
		Case cTabela == "SCR"
			cSQL += " AND "+cTabelaAlias+".CR_NUM IN (SELECT DISTINCT(SC7AUX.C7_NUM)" + CRLF
			cSQL += " FROM "+RetSqlName("SC7")+" SC7AUX" + CRLF
			cSQL += " WHERE SC7AUX.D_E_L_E_T_ = ' '" + CRLF
			cSQL += " AND SC7AUX.C7_FILIAL = "+cTabelaAlias+".CR_FILIAL" + CRLF
			cSQL += " AND SC7AUX.C7_QUJE < SC7AUX.C7_QUANT" + CRLF
			cSQL += " AND SC7AUX.C7_CONAPRO != 'R'" + CRLF
			cSQL += " AND SC7AUX.C7_ENCER = ' '" + CRLF
			cSQL += " AND SC7AUX.C7_RESIDUO = ' ') " + CRLF
			cSQL += " UNION ALL"
			cSQL += cSqlAux + CRLF //Verifica se tem alçada com Pedidos encerrados e com titulos em aberto.
			cSQL += " WHERE  "+cTabelaAlias+".D_E_L_E_T_ = ' ' " + CRLF
			cSQL += " AND  "+cTabelaAlias+".CR_FILIAL = '"+aRet[1]+"' " + CRLF
			cSQL += " AND "+cTabelaAlias+".CR_NUM IN (SELECT DISTINCT(SC7AUX1.C7_NUM)" + CRLF
			cSQL += " FROM "+RetSqlName("SC7")+" SC7AUX1" + CRLF
			cSQL += " WHERE SC7AUX1.D_E_L_E_T_ = ' ' " + CRLF
			cSQL += " AND SC7AUX1.C7_FILIAL = '"+aRet[1]+"' " + CRLF
			cSQL += " AND SC7AUX1.C7_CONAPRO = 'L'" + CRLF
			cSQL += " AND SC7AUX1.C7_ENCER = 'E'" + CRLF
			cSQL += " AND SC7AUX1.C7_RESIDUO = ' '
			cSQL += " AND SC7AUX1.C7_FILIAL||SC7AUX1.C7_XDOC||SC7AUX1.C7_XSERIE||SC7AUX1.C7_FORNECE||SC7AUX1.C7_LOJA IN (
			cSQL += " SELECT E2_FILIAL||E2_NUM||E2_PREFIXO||E2_FORNECE||E2_LOJA FROM  "+RetSqlName("SE2")+" SE2 " + CRLF
			cSQL += " WHERE SE2.E2_FILIAL = SC7AUX1.C7_FILIAL" + CRLF
			cSQL += " AND SE2.E2_NUM = SC7AUX1.C7_XDOC " + CRLF
			cSQL += " AND SE2.E2_PREFIXO = SC7AUX1.C7_XSERIE " + CRLF
			cSQL += " AND SE2.E2_FORNECE = SC7AUX1.C7_FORNECE" + CRLF
			cSQL += " AND SE2.E2_LOJA = SC7AUX1.C7_LOJA" + CRLF
			cSQL += " AND SE2.E2_SALDO > 0 " + CRLF
			cSQL += " AND SE2.D_E_L_E_T_ = ' '))" + CRLF			
		Case cTabela == "SEF"
			cSQL += " AND EF_NUM NOT IN (SELECT DISTINCT SE5.E5_NUMERO " + CRLF
			cSQL += " FROM "+RetSqlName("SE5")+" SE5 " + CRLF
			cSQL += " WHERE SE5.D_E_L_E_T_ = ' ' " + CRLF
			cSQL += " AND SE5.E5_FILIAL = SEF.EF_FILIAL  " + CRLF
			cSQL += " AND SE5.E5_NUMCHEQ = SEF.EF_NUM " + CRLF
			cSQL += " AND SE5.E5_DATA = SEF.EF_DATA) " + CRLF
		case cTabela == "P00"
			cSQL += " AND "+cTabelaAlias+".D_E_L_E_T_ = ' '  " + CRLF
		case cTabela == "RBR"
			cSQL +=  " AND RBR_APLIC = '1' " + CRLF
		case cTabela == "RB6"
			cSQL +=  " AND RB6_ATUAL = '1' " + CRLF
		EndCase
	EndIf
	MemoWrite(GetTempPath(.T.)+cTabela+"_"+FWTimeStamp()+".txt",cSql)

	cSQL := ChangeQuery( cSQL )

	dbUseArea(.T.,'TOPCONN', TCGenQry(,,cSQL), cAliasTMP, .F., .F.)

	DbSelectArea(cAliasTMP)
	Count To nReg
	(cAliasTMP)->(DbGotop())
	If (cAliasTMP)->(!Eof())
		If Aviso("Atenção", "Deseja confirmar a importação da tabela " + aRet[3] + " ? " + CRLF + "Registros: " + cValToChar(nReg),{ "Sair", "Confirmar" }, 1) == 1
			Return
		EndIf
		//nHr1 := Replace(TIME(), ":", ".")
		If cTabela == "P09"
			(cAliasTMP)->(DbGotop())
			While (cAliasTMP)->(!Eof())
				cArqOrigem := cArqRed + aRet[1] + (cAliasTMP)->P09_CODDOC + ".MZP"
				cArqDestino:= cArqRed + aRet[2] + (cAliasTMP)->P09_CODDOC + ".MZP"
				If File(cArqOrigem)
					__copyFile(cArqOrigem, cArqDestino)
				EndIf
				(cAliasTMP)->(DbSkip())
			EndDo
			(cAliasTMP)->(DbGotop())
		EndIf
		DbSelectArea(cTabela)
		(cTabela)->(DBRLock())
		Append From ( cAliasTMP ) VIA 'TOPCONN'//Importa tabela temporaria
		//nHr2 := Replace(TIME(), ":", ".")
		If cTabela == "SC7"
			If MsgYesNo("Deseja integrar os pedidos de compras?","Integração")
				Processa( {|| fIntPedidos() }, "Aguarde...", "Integrando pedido de compras...",.F.)
			else
				//Elimina Residuo da filial antiga
				if MsgYesNo("Deseja eliminar resíduo dos pedidos de compras?","Integração")
					SetResiduo(aRet[1])
				endif
			EndIf
		EndIf
		
		If cTabela == "SE2"
			
			Processa({|| fAtuPor()}, "Atualiza Portador", "Processando Aguarde...", .F.)// Atualiza Portador.

			if MsgYesNo("Deseja recusar todos os títulos da filial de origem?","Integração")
				(cAliasTMP)->(DbGotop())
				DbSelectArea("SE2")
				SE2->(DbSetOrder(1))
				While (cAliasTMP)->(!Eof())
					if SE2->(DbSeek(aRet[01] + (cAliasTMP)->E2_PREFIXO + (cAliasTMP)->E2_NUM + (cAliasTMP)->E2_PARCELA + (cAliasTMP)->E2_TIPO + (cAliasTMP)->E2_FORNECE + (cAliasTMP)->E2_LOJA))
						CRIAP00(aRet[01], SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_VALOR,SE2->E2_VENCREA,SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_ORIGEM, SE2->E2_USERLGI)
						Reclock("SE2",.F.)
						SE2->E2_XDTRECU := dDatabase
						IF EMPTY(SE2->E2_XDTRECP)
							SE2->E2_XDTRECP := dDataBase
						ENDIF
						SE2->E2_XSTRECU := "R"
						SE2->E2_DATALIB := CtoD("")
						SE2->E2_STATLIB := '01'
						SE2->(MsUnLock())
					endif

					(cAliasTMP)->(DbSkip())
				EndDo
				(cAliasTMP)->(DbGotop())
			EndIf
		Endif

		Processa({|| fCarregaMemo(cTabela, cAliasTMP) }, "Aguarde...", "Copiando campos memos!")

		MsgInfo("Processo Finalizado com Sucesso! Tabela: " + cTabela + " Registros: " + cValToChar(nReg))
	Else
		MsgInfo("Não foram encontrados dados para importação da tabela " +cTabela)
	EndIf

	ErrorBlock(oError)

	If Select(cAliasTMP) > 0
		(cAliasTMP)->(DbCloseArea())
	EndIf
Return
/*/{Protheus.doc} fPergunta
Mostra pergunta para usuário
@type function
@version  
@author Dell
@since 09/06/2022
@return variant, return_description
/*/
Static Function fPergunta()
	Local lRet := .T.

	AADD( aPerg ,{1,"Filial Origem:" ,Space(TamSX3("CCH_FILIAL")[1]) ,"",".T.","SM0","",50,.T.}) //
	AADD( aPerg ,{1,"Filial Destino:",Space(TamSX3("CCH_FILIAL")[1]),"",".T.","SM0","",50,.T.})
	AADD( aPerg ,{1,"Tabela:","   ","",".T.","","",50,.T.})
	AADD( aPerg ,{1,"Condição(Opcional):",Space(200),"",".T.","","",100,.F.})
	AADD( aPerg ,{2,"Regras do Incorporação",1,{"Sim","Não"},50,"",.F.})
	AADD( aPerg ,{2,"Rodar Script",1,{"Não","Sim"},50,"",.F.})
	AADD( aPerg ,{2,"Integrar Pedidos",1,{"Não","Sim"},50,"",.F.})
	AADD( aPerg ,{2,"Tp de virada Front:",1,{"1=Nova base","2=Mesma base"},50,"",.F.})

	If !ParamBox(aPerg ,"Replica de tabelas por Filial",@aRet)
		MsgInfo("Rotina encerrada")
		lRet := .F.
	Endif

Return lRet
/*/{Protheus.doc} FScript
Roda o Arquivo de Script selecionado pelo Usuário.
@type function
@version  
@author Ricardo Junior
@return variant, return_description
/*/
Static Function FScript()

	Local oFile
	Local lRet := .T.
	Local nX := 00

	cFile := cGetFile( 'Arquivo TXT|*.txt',; //[ cMascara],
	'Selecao de Arquivos',;                  //[ cTitulo],
	0,;                                      //[ nMascpadrao],
	'C:\',;                            //[ cDirinicial],
	.F.,;                                    //[ lSalvar],
	GETF_LOCALHARD  + GETF_NETWORKDRIVE,;    //[ nOpcoes],
	.T.)
	oFile := FWFileReader():New(cFile)
	If (oFile:Open())
		TCLink()
		BEGIN TRANSACTION
			while (oFile:hasLine())
				nX++
				cQuery := AllTrim(oFile:GetLine())
				If Right(cQuery,1) != ";"
					Aviso("A Query da linha: " + cValToChar(nX) + " não será executada, pois não possui o ';' no final da instrução.")
					Loop
				EndIf
				If AT(cTabela, cQuery) <= 0
					Loop
				EndIf
				nStatus := TCSqlExec(SubStr(cQuery,1,Len(cQuery)-1))
				If (nStatus < 0)
					Alert("TCSQLError() " + TCSQLError())
					DisarmTransaction()
					TCUnlink()
					lRet := .F.
					Exit
				EndIf
			EndDo
		END TRANSACTION
		TCUnlink()
		oFile:Close()
	EndIf

Return lRet
/*/{Protheus.doc} fIntPedidos
Integra os pedidos de compras da filial destino.
@type function
@version  
@author  Ricardo Junior
@param cQuery, character, param_description
@param cFil, character, param_description
@return variant, return_description
/*/
Static Function fIntPedidos(cQuery, cFil)
	Local aCampos := {}
	Local SC7TMP := GetNextAlias()

	Default cQuery := ""
	Default cFil   := aRet[2]

	If cTabela != "SC7"
		Return
	EndIf

	if Empty(cQuery)
		cQuery := " SELECT C7_FILIAL, C7_NUM, C7_FORNECE, C7_LOJA FROM " + RetSqlName("SC7")
		cQuery += " WHERE D_E_L_E_T_ = ' ' "
		cQuery += " AND C7_FILIAL = '"+aRet[2]+"' "
		cQuery += " AND C7_XSOLPAG != '1' "
		cQuery += " GROUP BY C7_FILIAL, C7_NUM, C7_FORNECE, C7_LOJA "
	Endif

	cSQL := ChangeQuery( cQuery )

	dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), SC7TMP, .F., .F.)

	//Criar a tabela temporária
	AAdd(aCampos,{"C7_OK",		"C", 002,0}) //Este campo será usado para marcar/desmarcar
	AAdd(aCampos,{"C7_FILIAL",	"C", TAMSX3("C7_FILIAL")[1],TAMSX3("C7_FILIAL")[2]})
	AAdd(aCampos,{"C7_NUM",		"C", TAMSX3("C7_NUM")[1],TAMSX3("C7_NUM")[2]})
	AAdd(aCampos,{"C7_FORNECE",	"C", TAMSX3("C7_FORNECE")[1],TAMSX3("C7_FORNECE")[2]})
	AAdd(aCampos,{"C7_LOJA",	"C", TAMSX3("C7_LOJA")[1],TAMSX3("C7_LOJA")[2]})

	//Se o alias estiver aberto, fechar para evitar erros com alias aberto
	If (Select("TRB") <> 0)
		dbSelectArea("TRB")
		TRB->(DbCloseArea())
	Endif
	//A função CriaTrab() retorna o nome de um arquivo de trabalho que ainda não existe e dependendo dos parâmetros passados, pode criar um novo arquivo de trabalho.
	oTempTable := FWTemporaryTable():New( "TRB" ) //cArqTrb   := CriaTrab(aCampos,.T.)

	//Criar indices
	oTemptable:SetFields( aCampos ) //cIndice1 := Alltrim(CriaTrab(,.F.))

	oTempTable:AddIndex( '01' , { "C7_FILIAL","C7_NUM" } ) //cIndice1 := Left(cIndice1,5) + Right(cIndice1,2) + "A"

	//Se indice existir excluir
	/*If File(cIndice1+OrdBagExt())
		FErase(cIndice1+OrdBagExt())
	EndIf*/

	//A função dbUseArea abre uma tabela de dados na área de trabalho atual ou na primeira área de trabalho disponível
	oTempTable:Create() //dbUseArea(.T.,,cArqTrb,"TRB",Nil,.F.)
	//A função IndRegua cria um índice temporário para o alias especificado, podendo ou não ter um filtro
	IndRegua("TRB", cIndice1, "C7_NUM"    ,,, "Indice Numero...")

	//Fecha todos os índices da área de trabalho corrente.
	dbClearIndex()
	//Acrescenta uma ou mais ordens de determinado índice de ordens ativas da área de trabalho.
	dbSetIndex(cIndice1+OrdBagExt())

	//Popular tabela temporária, irei colocar apenas um unico registro
	DbSelectArea(SC7TMP)
	(SC7TMP)->(DbGoTop())
	While (SC7TMP)->(!Eof())
		If RecLock("TRB",.T.)
			TRB->C7_FILIAL := (SC7TMP)->C7_FILIAL
			TRB->C7_NUM    := (SC7TMP)->C7_NUM
			TRB->C7_FORNECE:= (SC7TMP)->C7_FORNECE
			TRB->C7_LOJA   := (SC7TMP)->C7_LOJA
			TRB->(MsUnLock())
		Endif
		(SC7TMP)->(DbSkip())
	EndDo

	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oMark:= FWMarkBrowse():NEW()   // Cria o objeto oMark - MarkBrowse
	oMark:SetAlias("TRB")          // Define a tabela do MarkBrowse
	oMark:SetDescription("Pedidos a serem integrados") // Define o titulo do MarkBrowse
	oMark:SetFieldMark("C7_OK")    // Define o campo utilizado para a marcacao
	//oMark:SetColumns(MCFG006TIT("C7_OK",		"Ok",			03,"@!",0,010,0))
	oMark:SetColumns(MCFG006TIT("C7_FILIAL",	"Filial",		04,"@!",1,TAMSX3("C7_FILIAL")[1],TAMSX3("C7_FILIAL")[2]))
	oMark:SetColumns(MCFG006TIT("C7_NUM",		"Pedido",		05,"@!",1,TAMSX3("C7_NUM")[1],TAMSX3("C7_NUM")[2]))
	oMark:SetColumns(MCFG006TIT("C7_FORNECE",	"Fornecedor",	06,"@!",1,TAMSX3("C7_FORNECE")[1],TAMSX3("C7_FORNECE")[2]))
	oMark:SetColumns(MCFG006TIT("C7_LOJA",	"Loja",			07,"@!",1,TAMSX3("C7_LOJA")[1],TAMSX3("C7_LOJA")[2]))

	//oMark:SetFields(aCampos)         // Define os campos a serem mostrados no MarkBrowse
	oMark:SetSemaphore(.F.)        // Define se utiliza marcacao exclusiva
	oMark:DisableDetails()         // Desabilita a exibicao dos detalhes do Browse
	oMark:AllMark()
	oMark:AddButton("Integrar" ,  { || Processa({||U_F01EnvPed(cFil)}, "Aguarde...", "Integrando pedido de compras...",.F.) },,,, .F., 2 )

	oMark:Activate() // Ativa o MarkBrowse
	oMark:oBrowse:Setfocus()

	//Limpar o arquivo temporário
	//If !Empty(cArqTrb)
		If Select(SC7TMP) > 0
			(SC7TMP)->(DbCloseArea())
		EndIf
		//Ferase(cArqTrb+GetDBExtension())
		//Ferase(cArqTrb+OrdBagExt())
		//cArqTrb := ""
		TRB->(DbCloseArea())
		oTempTable:Delete()
	//Endif

Return

/*/{Protheus.doc} F01EnvPed
Pega os pedidos marcados e envia para o front.
@type function
@version  
@author Ricardo Junior
@since 30/12/2020
@param cFil, character, param_description
@return variant, return_description
/*/
User Function F01EnvPed(cFil)
	TRB->(DbGotop())
	cFilBkp := cFilAnt
	cFilAnt := cFil
	ProcRegua(TRB->(RECCOUNT()))
	TRB->(DbGotop())
	While TRB->(!Eof()) //Filial
		If oMark:isMark("C7_OK") .Or. !Empty(TRB->C7_OK)
			IncProc("Integrando pedido... " + TRB->C7_NUM)
			U_F07022RE(TRB->C7_NUM,"I")
		EndIf
		TRB->(DbSkip())
	EndDo
	TRB->(DbGotop())
	cFilAnt := cFilBkp
	MsgInfo("Pedidos enviados!")
Return
/*/{Protheus.doc} MCFG006TIT
Função para criar as colunas do grid
@type function
@version  
@author Ricardo Junior
@since 30/12/2020
@param cCampo, character, param_description
@param cTitulo, character, param_description
@param nArrData, numeric, param_description
@param cPicture, character, param_description
@param nAlign, numeric, param_description
@param nSize, numeric, param_description
@param nDecimal, numeric, param_description
@return variant, return_description
/*/
Static Function MCFG006TIT(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
	Local aColumn
	Local bData     := {||}
	Default nAlign     := 1
	Default nSize     := 20
	Default nDecimal:= 0
	Default nArrData:= 0

	If nArrData > 0
		bData := &("{||" + cCampo +"}") //&("{||oBrowse:DataArray[oBrowse:At(),"+STR(nArrData)+"]}")
	EndIf

	/* Array da coluna
    [n][01] Título da coluna
    [n][02] Code-Block de carga dos dados
    [n][03] Tipo de dados
    [n][04] Máscara
    [n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
    [n][06] Tamanho
    [n][07] Decimal
    [n][08] Indica se permite a edição
    [n][09] Code-Block de validação da coluna após a edição
    [n][10] Indica se exibe imagem
    [n][11] Code-Block de execução do duplo clique
    [n][12] Variável a ser utilizada na edição (ReadVar)
    [n][13] Code-Block de execução do clique no header
    [n][14] Indica se a coluna está deletada
    [n][15] Indica se a coluna será exibida nos detalhes do Browse
    [n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
	*/
	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}
Return {aColumn}
/*/{Protheus.doc} ftrataMemo
Função tratar campos memos, caso existam na tabela escolhida pelo usuário.
@type function
@version  
@author Ricardo Junior
@since 30/12/2020
@param cTabela, character, param_description
@return variant, return_description
/*/
Static Function ftrataMemo(cTabela)
	Local cText := ""
	Local aArea := GetArea()
	Local nX := 01
	Local aListMms := {}

	DbSelectArea(cTabela)
	aListCampos := DbStruct()
	For nX := 01 To Len(aListCampos)
		If aListCampos[nX][02] == "M"
			//cText += " DECODE(dbms_lob.substr("+aListCampos[nX][01]+"), NULL, RAWTOHEX(null),utl_raw.cast_to_varchar2(dbms_lob.substr("+aListCampos[nX][01]+"))) " + aListCampos[nX][01] + ","
			//cText += "  clob2blob(blob2char("+aListCampos[nX][01]+")) " + aListCampos[nX][01] + ","
			aAdd(aListMms, aListCampos[nX][01] )
		EndIf
	Next nX

	RestArea(aArea)
Return aListMms
/*/{Protheus.doc} CRIAP00
Rotina responsavel por atualizar a tabela P00.
@type function
@version  
@author Ricardo Junior.
@since 01/02/2022
@param cFil, character, param_description
@param cNumTit, character, param_description
@param cPrefixo, character, param_description
@param nValor, numeric, param_description
@param dVencrea, date, param_description
@param cFornece, character, param_description
@param cLojaF, character, param_description
@param cOrigem, character, param_description
@param cUsrlog, character, param_description
@return variant, return_description
/*/
Static Function CRIAP00(cFil,cNumTit,cPrefixo,nValor,dVencrea,cFornece,cLojaF,cOrigem,cUsrlog)

	Local cTipoDoc := " "
	Local cMensagem := "[CANCELAMENTO DE RECUSA]: "
	Local lRet := .T.

	Default cLojaF := "01"

	Begin Transaction
		P00->(RecLock("P00",.T.))
		P00->P00_FILIAL := cFil
		P00->P00_NUM	:= cNumTit
		P00->P00_PREFIX	:= cPrefixo
		P00->P00_VALOR	:= nValor
		P00->P00_XDTVEN	:= dVencrea
		P00->P00_FORNEC	:= cFornece
		P00->P00_LOJAF	:= cLojaF
		P00->P00_USREMI	:= ""
		P00->P00_USRREC	:= SUBS(Embaralha(cUsrlog,01),03, 06)
		P00->P00_MOTIVO	:= "Recusado - Incorporação"
		P00->P00_DTRECU	:= dDatabase
		P00->P00_ORIGEM	:= cOrigem
		P00->P00_TIPO	:= ""
		P00->(MsUnlock())

	End Transaction

Return
/*/{Protheus.doc} SetResiduo
Preenche o Residuo da SC7.
@type function
@version  
@author Ricardo Junior
@since 09/06/2022
@param cFil, character, param_description
@return variant, return_description
/*/
Static function SetResiduo(cFil)
	Local SC7TMP := GetNextAlias()

	cQuery := " SELECT C7_FILIAL, C7_ITEM, C7_NUM, C7_FORNECE, C7_LOJA FROM " + RetSqlName("SC7")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND C7_FILIAL = '"+cFil+"' "
	cQuery += " AND C7_QUJE < C7_QUANT "
	cQuery += " AND C7_RESIDUO = ' ' "
	cQuery += " AND C7_ENCER = ' ' "
	cQuery += " GROUP BY C7_FILIAL, C7_ITEM, C7_NUM, C7_FORNECE, C7_LOJA "

	cSQL := ChangeQuery( cQuery )

	dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), SC7TMP, .F., .F.)

	While (SC7TMP)->(!Eof())
		if SC7->(DbSeek(cFil+ (SC7TMP)->C7_NUM + (SC7TMP)->C7_ITEM))
			Reclock("SC7",.F.)
			SC7->C7_XOBSRES := ALLTRIM(SC7->C7_XOBSRES) + " | ELIMINAÇÃO DE RESIDUO - PROJETO INCORPORAÇÃO"
			SC7->C7_RESIDUO := "S"
			SC7->C7_ENCER 	:= "E"
			SC7->(MsUnLock())
		endif
		(SC7TMP)->(DbSkip())
	End
	//Query de envio dos pedidos para integração
	cQuery := " SELECT C7_FILIAL, C7_NUM, C7_FORNECE, C7_LOJA FROM " + RetSqlName("SC7")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND C7_FILIAL = '"+cFil+"' "
	cQuery += " AND C7_XORIG != '2' "
	cQuery += " AND C7_XID != ' ' "
	cQuery += " AND C7_XSOLPAG = '2' "
	cQuery += " AND C7_QUJE < C7_QUANT "
	cQuery += " GROUP BY C7_FILIAL, C7_NUM, C7_FORNECE, C7_LOJA "

	Processa( {|| fIntPedidos(cQuery, cFil) }, "Aguarde...", "Integrando pedido de compras...",.F.)
Return

Static Function fPerg2()
	Local lRet := .T.
	Local aPerg2 := {}

	AADD( aPerg2 ,{1,"Informe a data de Referência: ",Ctod(Space(8)),"","","","",50,.F.}) //
	//aAdd( aPerg2 ,{1,"Data"  ,Ctod(Space(8)),"","","","",50,.F.}) // Tipo data

	If !ParamBox(aPerg2 ,"Replica de tabelas por Filial",@aRetPerg2)
		MsgInfo("Rotina encerrada")
		lRet := .F.
	Endif

Return lRet

return
/*/{Protheus.doc} fCarregaMemo
Função responsável por atualizar campos memos.
@type function
@version  
@author Ricardo Junior
@since 01/04/2022
@param cTabela, character, param_description
@param cAliasTMP, character, param_description
@return variant, return_description
/*/
static function fCarregaMemo(cTabela, cAliasTMP)

	Local nY := 0
	Local nX := 0
	Local aArea := GetArea()
	Local aAreaTemp := (cAliasTMP)->(GetArea())
	Local aAreaTab := (cTabela)->(GetArea())

	aCmpMMS := ftrataMemo(cTabela)
	(cAliasTMP)->(DbGotop())
	DbSelectArea(cTabela)
	if Len(aCmpMMS) > 0
		While !(cAliasTMP)->(Eof())
			IncProc("Atualizando...")
			aChave := strtokarr(Indexkey(), "+")
			cChaveMMS := ""
			//For para montar Indice de busca.
			For nX  := 01 To Len(aChave)
				if "FILIAL" $ aChave[nX]
					cChaveMMS += aRet[2]
					Loop
				endif
				if "DTOS" $ aChave[nX]
					aChave[nX] := Replace(Replace(aChave[nX], "DTOS(", ""), ")", "")
					cChaveMMS += (cAliasTMP)->&(aChave[nX])
					Loop
				endif
				cChaveMMS += (cAliasTMP)->&(aChave[nX])
			Next nX

			(cTabela)->(DbGoTo((cAliasTMP)->R_E_C_N_O_))

			aDadosM := {}
			For nY := 01 To Len(aCmpMMS)
				if Empty((cTabela)->&(aCmpMMS[nY]))
					Loop
				endif
				aAdd(aDadosM, { aCmpMMS[nY] , (cTabela)->&(aCmpMMS[nY]) })
			Next nY

			//Busca registro de destino.
			if (cTabela)->(DbSeek(cChaveMMS))
				For nY := 01 To Len(aDadosM)
					RecLock(cTabela, .F.)
					(cTabela)->&(aDadosM[nY][1]) := aDadosM[nY][2]
					(cTabela)->(MsUnlock())
				Next nY
			endif
			(cAliasTMP)->(DbSkip())
		endDo
	endif

	RestArea(aArea)
	RestArea(aAreaTemp)
	RestArea(aAreaTab)
Return
/*/{Protheus.doc} fAtuPor
	Atualização do Portador na filial de destino.
@type function
@author Ricardo Junior
@since 08/06/2022
@return variant, return_description
/*/
Static Function fAtuPor()
	Local aArea := GetArea()
	Local aAreaE2 := SE2->(GetArea())
	Local lRet := .T.
	Local aPergPor := {}
	Local aRetPor := {}

	AADD( aPergPor ,{1,"Portador:", Space(TamSX3("E2_PORTADO")[1]) ,"",".T.","SA6PZE","",50,.T.}) //
	AADD( aPergPor ,{1,"Agência:",Space(TamSX3("E2_XAGEPOR")[1]),"",".T.","","",50,.T.})
	AADD( aPergPor ,{1,"Digito Agência:",Space(TamSX3("E2_XDVAPOR")[1]),"",".T.","","",10,.F.})
	AADD( aPergPor ,{1,"Conta:",Space(TamSX3("E2_XCONPOR")[1]),"",".T.","","",50,.T.})
	AADD( aPergPor ,{1,"Digito Conta:",Space(TamSX3("E2_XDVCPOR")[1]),"",".T.","","",10,.T.})

	If !ParamBox(aPergPor ,"Atualiza Portador nova filial",@aRetPor)
		lRet := .F.
		Return
	endif

	if lRet
		DbSelectArea("SE2")
		SE2->(DbSetOrder(1))
		SE2->(DbGotop())
		SE2->(DbSeek(aRet[02]))
		ProcRegua(0)
		nX := 0
		While SE2->(!Eof()) .And. AllTrim(SE2->E2_FILIAL) == AllTrim(aRet[02])
			nX += 1
			IncProc("Atualizando portador nos titulos da filial " + aRet[02] + " | Quantidade: " + cValToChar(nX))			
			if !Empty(SE2->E2_PORTADO)
				Reclock("SE2",.F.)
				E2_XAGEPOR := aRetPor[2]
				E2_XDVAPOR := aRetPor[3]
				E2_XCONPOR := aRetPor[4]
				E2_XDVCPOR := aRetPor[5]
				E2_PORTADO := aRetPor[1]
				SE2->(MsUnLock())
			endif			
			SE2->(DbSkip())
		EndDo
	endif

	SE2->(DbGotop())
	RestArea(aAreaE2)
	RestArea(aArea)
Return
