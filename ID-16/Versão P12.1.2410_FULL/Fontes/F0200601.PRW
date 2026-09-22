#INCLUDE 'Protheus.ch'
#INCLUDE "Topconn.ch"

/*
{Protheus.doc} F0200601
Relatorio custos emergenciais
@Project MAN00000463301_EF_006
@author bruno.aferreira
@since 07/10/2016
*/
User Function F0200601()

	Private oReport
	Private oSection1
	Private cPerg := "FSW0200601"

	If Pergunte(cPerg, .T.)
		RptDef()
		oReport:PrintDialog()
	EndIf

Return

/*{Protheus.doc} ReportPrint
Impressão do relatorio
@Project MAN00000463301_EF_006 001
@author bruno.aferreira
@since 07/10/2016
*/
Static Function ReportPrint()
	
	oSection1 := oReport:Section(1)
	oSection1:Init()
	F02006MontadadosRel()
	oSection1:Finish()

Return

/*{Protheus.doc} RptDef
//TODO Montagem da estrutura do relatorio
@Project MAN00000463301_EF_006 001
@author bruno.aferreira
@since 07/10/2016
@version undefined
@type function
*/
Static Function RptDef()
	
	Local oBreak
	Local oFunction
	
	oReport := TReport():New(cPerg,"Relatório Custo Emergencial",cPerg,{|| ReportPrint() },"Mostra o custo emergencial")
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)
	
	oSection1:= TRSection():New(oReport, "COTACOES", {"SC8"}, , .F., .T.)
	TRCell():New(oSection1, "FILIAL"   , "QRY", "Filial"         ,                    , 08                     , .T.) 
	TRCell():New(oSection1, "DATAEMI"  , "QRY", "Dt Emissao"     ,                    , 08                     , .T.)
	TRCell():New(oSection1, "CODIGO"   , "QRY", "Material"       ,                    , TamSX3("C7_PRODUTO")[1], .T.)
	TRCell():New(oSection1, "DESC"     , "QRY", "Descriçao"      ,                    , TamSX3("C7_DESCRI")[1] , .F.)
	TRCell():New(oSection1, "SEGMENTO" , "QRY", "Segmento"       ,                    , TamSX3("ACU_DESC")[1]  , .T.)
	TRCell():New(oSection1, "GRUPAMEN" , "QRY", "Grupamento"     ,                    , TamSX3("ACU_DESC")[1]  , .T.)
	TRCell():New(oSection1, "CODMOV"   , "QRY", "Cod. Mov."      ,                    , 01                     , .T.)
	TRCell():New(oSection1, "MOVIMENTA", "QRY", "Movimentacao"   ,                    , 25                     , .T.)
	TRCell():New(oSection1, "COMPRADOR", "QRY", "Comprador"      ,                    , 25                     , .T.)
	TRCell():New(oSection1, "SOLCOMPRA", "QRY", "S. Compra"      ,                    , 25                     , .T.)
	TRCell():New(oSection1, "NECESENTR", "QRY", "Necess. Entrega",                    , 08                     , .T.)
	TRCell():New(oSection1, "ORDCOMPRA", "QRY", "O. Compra"      ,                    , 25                     , .T.)
	TRCell():New(oSection1, "QNTPED"   , "QRY", "Qtd. Pedido"    ,                    , 25                     , .T.)
	TRCell():New(oSection1, "MOTIVO"   , "QRY", "Motivo"         ,                    , 25                     , .T.)
	TRCell():New(oSection1, "DIASEMANA", "QRY", "Dia da Semana"  ,                    , 25                     , .T.)
	TRCell():New(oSection1, "FORNEOC"  , "QRY", "Forn. OC"       ,                    , 45                     , .T.)
	TRCell():New(oSection1, "MODALID"  , "QRY", "Modalidade"     ,                    , 30                     , .T.)
	TRCell():New(oSection1, "VALUNIT"  , "QRY", "Vl. Un Cont/Mer", "@E 999,999,999.99", 14                          ) 
	TRCell():New(oSection1, "TOTCONTR" , "QRY", "Tot Cont/Mer"   , "@E 999,999,999.99", 14                          ) 
	TRCell():New(oSection1, "VALEMERG" , "QRY", "Val. Un Emerg." , "@E 999,999,999.99", 14                          ) 
	TRCell():New(oSection1, "TOTEMERG" , "QRY", "Tot. Emerg."    , "@E 999,999,999.99", 14                          ) 
	TRCell():New(oSection1, "VARIACAO" , "QRY", "Variaçao"       , "@E 999,999,999.99", 14                     , .T.)
	TRCell():New(oSection1, "JUSTIFIC" , "QRY", "Justificativa"  ,                    , 20                     , .T.)
	TRCell():New(oSection1, "ANALISTA" , "QRY", "Analista"       ,                    , 40                     , .T.)
	
Return

/* {Protheus.doc} F02006MontadadosRel()
Busca as informacoes no banco, jogando em um array
@Project MAN00000463301_EF_006
@author bruno.aferreira
@since 10/10/2016
*/
Static Function F02006MontadadosRel()

	Local cTesteFil
	Local cBanco    := If(Trim(TcGetDb()) == 'ORACLE',.T.,.F.)
	Local cProdIni  := Space(TamSX3("B1_COD")[1])
	Local cProdFim  := Space(TamSX3("B1_COD")[1])
	Local cFilIni   := Space(TamSX3("C7_FILIAL")[1])
	Local cFilFim   := Space(TamSX3("C7_FILIAL")[1])
	Local aAux      := {}
	Local nX        := 1
	Local cAliasQry := GetNextAlias()

	Private cProdRet,cFilRet

	cFilRet:= Alltrim(MV_PAR01)
	cProdRet:= Alltrim(MV_PAR04)
	
	If at('-',cFilRet) > 0
		cFilRet := StrTran(cFilRet,";","")
		cFilIni := Substr(cFilRet,1, at('-', cFilRet) - 1)
		cFilFim := Substr(cFilRet,at('-', cFilRet) + 1,TamSX3("C7_FILIAL")[1] )
	Else
		aAux := StrtoKarr(cFilRet,';')
		cFilRet:= ""
		For nX := 1 To Len(aAux)
			If Alltrim(aAux[nX]) != ""
		//		cFilRet += "'" + aAux[nX] + "'," // ticket n° 9103900 - ajuste para não duplicar as aspas
				cFilRet += aAux[nX] + ","
			Endif
		Next
		If Right(AllTrim(cFilRet),1) == ','
			cFilRet := SubStr(AllTrim(cFilRet),1,Len(AllTrim(cFilRet))-1)
		Endif
	EndIf

	aAux := {}
	If at('-',cProdRet) > 0
		cProdRet:= StrTran(cProdRet,";","")
		cProdIni := Substr(cProdRet,1, at('-', cProdRet) - 1)
		cProdFim := Substr(cProdRet,at('-', cProdRet) + 1,TamSX3("B1_COD")[1] )
	Else
		aAux := StrtoKarr(cProdRet,';')
		cProdRet:= ""
		For nX := 1 To Len(aAux)
			If Alltrim(aAux[nX]) != ""
		//		cProdRet += "'" + aAux[nX] + "'," // ticket n° 9103900 - ajuste para não duplicar as aspas
				cProdRet += aAux[nX] + ","
			Endif
		Next
		If Right(AllTrim(cProdRet),1) == ','
			cProdRet := SubStr(AllTrim(cProdRet),1,Len(AllTrim(cProdRet))-1)
		Endif
	EndIf

	cQuery1 := " SELECT C7_FILIAL FILIAL, C8_EMISSAO EMISSAOCOT, C8_NUM NUMCOT, C7_PRODUTO PRODUTO, C7_DESCRI DESCRICAO, " + CRLF
	cQuery1 += " C7_USER COMPRADOR, C7_NUMSC NUMSC, C7_NUM NUMPED, C7_QUANT QUANTPED, C8_FORNECE FORNECE, A2_NOME NOMEFOR, " + CRLF
	cQuery1 += " C7_LOJA LOJA, C7_PRECO PRECOUNIT, C7_TOTAL TOTAL, C7_EMISSAO EMISSAOPED, C8_MOTIVO JUSTIFIC, " + CRLF
	cQuery1 += " ACU01.ACU_DESC SEGMENTO, ACU02.ACU_DESC GRUPAMEN, C1_SOLICIT ANALISTA, C1_XTPSC, C1_DATPRF, C1_EMISSAO, C1_XMOTIVO, " + CRLF
	cQuery1 += " MAX(B9_CM1) CUSTOMEDIO, MAX(AIB_PRCCOM) PRECOCON " + CRLF
	cQuery1 += " FROM " + RetSqlName("SC7") + " C7 " + CRLF
	cQuery1 += " INNER JOIN " + RetSqlName("SC8") + " C8 ON C8_FILIAL = C7_FILIAL AND C8.D_E_L_E_T_ = ' ' AND C8_NUMPED = C7_NUM AND C8_ITEMPED = C7_ITEM " + CRLF
	cQuery1 += " INNER JOIN " + RetSqlName("SA2") + " A2 ON A2_FILIAL = '" + xFilial("SA2") + "' AND A2.D_E_L_E_T_ = ' ' AND A2_COD = C7_FORNECE AND A2_LOJA = C7_LOJA " + CRLF
	cQuery1 += " INNER JOIN " + RetSqlName("SC1") + " C1 ON C1_FILIAL = C7_FILIAL AND C1.D_E_L_E_T_ = ' ' AND C1_PEDIDO = C7_NUM AND C1_ITEMPED = C7_ITEM " + CRLF
	cQuery1 += " LEFT OUTER JOIN " + RetSqlName("ACV") + " ACV ON ACV.ACV_FILIAL = C7_FILIAL AND ACV.D_E_L_E_T_ = ' ' AND ACV.ACV_CODPRO = C7_PRODUTO " + CRLF
	cQuery1 += " LEFT OUTER JOIN " + RetSqlName("ACU") + " ACU01 ON ACU01.ACU_FILIAL = C7_FILIAL AND ACU01.D_E_L_E_T_ = ' ' AND ACU01.ACU_COD = ACV.ACV_CATEGO " + CRLF
	cQuery1 += " LEFT OUTER JOIN " + RetSqlName("ACU") + " ACU02 ON ACU02.ACU_FILIAL = C7_FILIAL AND ACU02.D_E_L_E_T_ = ' ' AND ACU02.ACU_COD = ACU01.ACU_CODPAI " + CRLF
	cQuery1 += " LEFT OUTER JOIN " + RetSqlName("SB9") + " B9 ON B9_FILIAL = C7_FILIAL AND B9_COD = C7_PRODUTO AND B9_LOCAL = C7_LOCAL AND SUBSTR(B9_DATA,1,6) = SUBSTR(C7_EMISSAO,1,6) AND B9.D_E_L_E_T_ = ' ' " + CRLF
	cQuery1 += " LEFT OUTER JOIN " + RetSqlName("CN9") + " CN9 ON CN9_FILIAL = C7_FILIAL AND C7_EMISSAO BETWEEN CN9_DTINIC AND CN9_DTFIM AND CN9.D_E_L_E_T_ = ' ' " + CRLF
	cQuery1 += " LEFT OUTER JOIN " + RetSqlName("AIB") + " AIB ON AIB_FILIAL = CN9_FILIAL AND AIB_CODPRO = C7_PRODUTO AND AIB_XCONTR = CN9_NUMERO AND AIB.D_E_L_E_T_ = ' ' " + CRLF
	cQuery1 += " WHERE C7.D_E_L_E_T_ = '' " + CRLF
	cQuery1 += " AND C7_EMISSAO BETWEEN '" + DtoS(MV_PAR02) + "' AND '" + DtoS(MV_PAR03) + "' " + CRLF
	cQuery1 += " AND C1_XTPSC IN ('02','03') " + CRLF

	If !Empty(cProdRet)
	    If Empty(cProdIni)
			cQuery1 +="AND C7_PRODUTO IN ("+cProdRet+")" + CRLF
		Else
			cQuery1 +="AND C7_PRODUTO BETWEEN '" + cProdIni + "' AND '" + cProdFim + "' " + CRLF
		EndIf
	Endif

	If !Empty(cFilRet)
	    If Empty(cFilIni)
			cQuery1 += "AND C7_FILIAL IN (" + cFilRet + ")" + CRLF
		Else
			cQuery1 +="AND C7_FILIAL BETWEEN '" + cFiLIni + "' AND '" + cFilFim + "' " + CRLF
		EndIf                               
	Endif

	cQuery1 += " GROUP BY C7_FILIAL, C8_EMISSAO, C8_NUM, C7_PRODUTO, C7_DESCRI, C7_USER, C7_NUMSC, C7_NUM, C7_QUANT, C8_FORNECE, A2_NOME, " + CRLF
    cQuery1 += " C7_LOJA, C7_PRECO, C7_TOTAL, C7_EMISSAO, C8_MOTIVO, ACU01.ACU_DESC, ACU02.ACU_DESC, C1_SOLICIT, C1_XTPSC, C1_DATPRF, C1_EMISSAO, C1_XMOTIVO " + CRLF
	cQuery1 += " ORDER BY FILIAL, PRODUTO, NUMSC, NUMPED "

	cQuery1 := ChangeQuery(cQuery1)
	dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery1), cAliasQry, .T., .T.)
	
	While (cAliasQry)->(!Eof())
	
		oSection1:Cell("FILIAL")   :SetValue(FwFilName(cEmpAnt,(cAliasQry)->FILIAL))
		oSection1:Cell("DATAEMI")  :SetValue(DtoC(StoD((cAliasQry)->EMISSAOCOT)))
		oSection1:Cell("CODIGO")   :SetValue((cAliasQry)->PRODUTO)
		oSection1:Cell("DESC")     :SetValue((cAliasQry)->DESCRICAO)
		oSection1:Cell("COMPRADOR"):SetValue(UsrRetName((cAliasQry)->COMPRADOR))
		oSection1:Cell("SOLCOMPRA"):SetValue((cAliasQry)->NUMSC)
		oSection1:Cell("ORDCOMPRA"):SetValue((cAliasQry)->NUMPED)
		oSection1:Cell("QNTPED")   :SetValue((cAliasQry)->QUANTPED)
		oSection1:Cell("FORNEOC")  :SetValue((cAliasQry)->NOMEFOR)
		oSection1:Cell("MODALID")  :SetValue((cAliasQry)->(Iif(PRECOCON == 0,"MERCADO","CONTRATO") ))
		oSection1:Cell("VALUNIT")  :SetValue((cAliasQry)->(Max(PRECOCON,CUSTOMEDIO)))
		oSection1:Cell("TOTCONTR") :SetValue((cAliasQry)->(Max(PRECOCON,CUSTOMEDIO)) * (cAliasQry)->QUANTPED)
		oSection1:Cell("VALEMERG") :SetValue((cAliasQry)->PRECOUNIT)
		oSection1:Cell("TOTEMERG") :SetValue((cAliasQry)->TOTAL)
		oSection1:Cell("VARIACAO") :SetValue((cAliasQry)->TOTAL - ((cAliasQry)->(Max(PRECOCON,CUSTOMEDIO)) * (cAliasQry)->QUANTPED) )
		oSection1:Cell("JUSTIFIC") :SetValue((cAliasQry)->JUSTIFIC)
		oSection1:Cell("ANALISTA") :SetValue((cAliasQry)->ANALISTA)
		oSection1:Cell("SEGMENTO") :SetValue((cAliasQry)->SEGMENTO)
		oSection1:Cell("GRUPAMEN") :SetValue((cAliasQry)->GRUPAMEN)
		oSection1:Cell("CODMOV")   :SetValue(Iif((cAliasQry)->C1_XTPSC=="02","1",Iif((cAliasQry)->C1_XTPSC=="03","2","")))
		oSection1:Cell("MOVIMENTA"):SetValue(Tabela("ZX",(cAliasQry)->C1_XTPSC,.F.))
		oSection1:Cell("NECESENTR"):SetValue(DtoC(StoD((cAliasQry)->C1_DATPRF)))
		oSection1:Cell("DIASEMANA"):SetValue(DiaSemana(Stod((cAliasQry)->C1_EMISSAO)))
		oSection1:Cell("MOTIVO"   ):SetValue(Tabela("ZZ",(cAliasQry)->C1_XMOTIVO,.F.))
		oSection1:Printline()
		oReport:ThinLine()

		(cAliasQry)->(dbSkip())

	EndDo

	(cAliasQry)->(DbCloseArea())

Return
