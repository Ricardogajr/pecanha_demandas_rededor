#Include 'Protheus.ch'
#Include 'TopConn.ch'
#Include 'FWMVCDef.ch'

/*
{Protheus.doc} F0200101()
Relat�rio de Custo Evitado e Saving.
@Author     Mick William da Silva
@Since      30/05/2016
@Version    P12.7
@Project    MAN00000463301_EF_001
@Return    
*/

User Function F0200101()

	local oReport 
	Private vpTmpDB:= ""
	Private cIndex	:= ""
	Private aStrCmp	:= {}
	
	oReport:= ReportDef()
	If ValType(oReport) == "O"
		oReport:PrintDialog()
	Endif
	
Return
 
Static Function ReportDef()
	
	Local oReport
	Local oSection

	If !Pergunte("FSW0200101",.T.)
		Return
	Endif
	
	oReport := TReport():New("Custo Evitado e Saving","Relatorio de Custo Evitado e Saving","FSW0200101",{|oReport| PrintReport(oReport)},"Este relatorio ira imprimir o Custo Evitado e Saving.")
	oSection := TRSection():New(oReport,"Compras",{"TMP"},{"Saving","Custo Evitado"} )
	oSection:SetTotalInLine(.F.)
	
	TRCell():new(oSection, "TMP_NUM"		, "TMP", "Cotacao"			)
	TRCell():New(oSection, "TMP_FORNEC"		, "TMP", "Fornecedor"		)
	TRCell():new(oSection, "TMP_LOJA"		, "TMP", "Loja"				)
	TRCell():new(oSection, "TMP_FORNOM"		, "TMP", "Nome"				)
	TRCell():new(oSection, "TMP_NUMPRO"		, "TMP", "Proposta"			)
	TRCell():new(oSection, "TMP_GRUPO"		, "TMP", "Tipo"				)
	TRCell():new(oSection, "TMP_XGRPPR"		, "TMP", "Grupo"			)
	TRCell():new(oSection, "TMP_XSUBGR"		, "TMP", "Subgrupo" 		)
	TRCell():New(oSection, "TMP_PRODUT"		, "TMP", "Código"			)
	TRCell():new(oSection, "TMP_DESC"		, "TMP"	,"Descricao"		)
	TRCell():new(oSection, "TMP_QUANT1"		, "TMP", "Quantidade"		)
	TRCell():new(oSection, "TMP_PRECO1"		, "TMP", "Valor Unitario"	)
	TRCell():new(oSection, "TMP_EVITA"		, "TMP", "Valor Total"		)
	TRCell():new(oSection, "DTULCOMP"		, "TMP","Data da ultima Compra"	,,,,{||(StoD(TMP->TMP_DTULCO))},,,,,,,,,.t.)
	TRCell():new(oSection, "TMP_QTULCO"		, "TMP","Quantidade"		)
	TRCell():New(oSection, "TMP_PRULCO"		, "TMP","Valor Unitario"	)
	TRCell():new(oSection, "TMP_SAVING"		, "TMP","Valor Total"		)
	TRCell():new(oSection, "DtCompAt"		, "TMP", "Data da Compra Atual"	,,,,{||(StoD(TMP->TMP_EMISSA))},,,,,,,,,.t.)
	TRCell():new(oSection, "TMP_QUANT2"		, "TMP", "Quantidade"		)
	TRCell():new(oSection, "TMP_PRECO2"		, "TMP", "Valor Unitario"	)
	TRCell():new(oSection, "TMP_TOTAL"		, "TMP", "Valor Total"		)
	TRCell():new(oSection, "TMP_USER"		, "TMP", "Comprador"		)
	TRCell():new(oSection, "TMP_FILIAL"		, "TMP", "Filial"			)
	TRCell():new(oSection, "TMP_CC"			, "TMP", "Centro de Custo"	)
	TRCell():new(oSection, "TMP_DESC01"		, "TMP", "Descricao"		)
	TRCell():new(oSection, "TMP_LOCAL"		, "TMP", "Setor"			)
	TRCell():new(oSection, "TMP_DESCRI"		, "TMP", "Descricao"		)

Return (oReport)
 
Static Function PrintReport(oReport)

	Local aArea		:= GetArea()
	Local oSection 	:= oReport:Section(1)
	Local cQuery	:= ""
	Local cProd		:= ""
	Local cFilC8	:= ""
	Local cRetTab  	:= ""
	Local nCpo  	:= 0
	Local xValor 	:= Nil
	Local aCpos  	:= {}
	Local nOrdem	:= oSection:GetOrder()
	Local cNamIn	:= ""
	Local cFilFilt:= ""	
	Local aAux		:= {}
	Local nX		:= 1
	F021Stru()

	aAux := StrtoKarr(MV_PAR01,';')
	
	For nX := 1 To Len(aAux)
		If Alltrim(aAux[nX]) != ""
			cFilFilt += "'" + aAux[nX] + "',"
		Endif
	Next

	If Right(AllTrim(cFilFilt),1) == ','
		cFilFilt := SubStr(AllTrim(cFilFilt),1,Len(AllTrim(cFilFilt))-1)  
	Endif
	
	
	IF nOrdem == 1
		//cIndex:= "Alltrim(STR(TMP->TMP_SAVING)) + TMP_FILIAL + TMP_NUM + TMP_FORNEC + TMP_LOJA + TMP_PRODUT"
		cIndex:= {"TMP_SAVING","TMP_FILIAL","TMP_NUM","TMP_FORNEC","TMP_LOJA","TMP_PRODUT"}
	ELSE
		//cIndex:= "Alltrim(STR(TMP->TMP_EVITA)) + TMP_FILIAL + TMP_NUM + TMP_FORNEC + TMP_LOJA + TMP_PRODUT"
		cIndex:= {"TMP_EVITA","TMP_FILIAL","TMP_NUM","TMP_FORNEC","TMP_LOJA","TMP_PRODUT"}
	ENDIF
	
	//Início - Thais Paiva - Compatibilização P27
	oTempTable1 := FWTemporaryTable():New( "TMP" )
	oTemptable1:SetFields( aStrCmp )
	oTempTable:AddIndex("TMP", cIndex )
	oTempTable1:Create()
	//Fim - Thais Paiva - Compatibilização P27
	
	//cNamIn 		:= "Indice"
	
	//IndRegua("TMP",cNamIn,cIndex,"D",,,)
	dbSelectArea("TMP")
	//dbSetIndex(cNamIn + OrdBagExt())
	TMP->( dbSetOrder(1) )
	dbGoTop()
	
	oSection:Init()
 
	MakeSqlExpr("FSW0200101")
	
	
	//Consulta a Cota��o 
	cQuery :="SELECT C8_FILIAL,C8_NUM, C8_FORNECE, C8_LOJA, C8_FORNOME, C8_NUMPRO, C8_PRODUTO,C8_QUANT, C8_PRECO, C8_TOTAL"
	cQuery +=" FROM " + RETSQLNAME('SC8') + " SC8 "
	cQuery +=" WHERE "
//Nairan - Alterado no dia 05/08.	
//	IF(Substr(Alltrim(MV_PAR01),20,2)<>'')
		cQuery += " C8_FILIAL IN (" + cFilFilt + ") AND "
//	EndIf
	cQuery +=" SC8.C8_EMISSAO BETWEEN '" + DtoS(MV_PAR02) + "' AND '" + DtoS(MV_PAR03) + "' AND SC8.D_E_L_E_T_ =' ' "
	
	If Select("cAlQry") > 0
		DbSelectArea("cAlQry")
		cAlQry->(DbCloseArea())
	Endif
		
	TCQUERY cQuery NEW ALIAS "cAlQry"
		
	dbSelectArea("cAlQry")
	cAlQry->(dbGoTop())
			
	While !cAlQry->(EOF())
		oReport:IncMeter()
		cProd 	:= cAlQry->C8_PRODUTO
		cFilC8	:= cAlQry->C8_FILIAL
		cSaving := 0
		cEvitad	:= 0
		
		//Verifica se existe produto, Pedido Parcialmente Atendido ou Atendido, tamb�m Carrega os totais do ultimo Pedido Atendido(Ultima Compra).
		cQuery :="SELECT C7_FILIAL,C7_PRODUTO,C7_FORNECE,C7_LOJA, C7_TOTAL,C7_EMISSAO DTULCOMP, C7_QUANT QTULCOMP, C7_PRECO PRULCOMP, C7_TOTAL TOTULCOMP"
		cQuery +=" FROM " + RETSQLNAME('SC7') + " SC7 "
		cQuery +=" WHERE SC7.C7_FILIAL='" + cFilC8 + "' AND SC7.D_E_L_E_T_=' ' "
		cQuery +=" AND SC7.C7_EMISSAO BETWEEN '" + DtoS(MV_PAR02) + "' AND '" + DtoS(MV_PAR03) + "' " 
		cQuery +=" AND SC7.C7_PRODUTO ='" + cProd + "' "
		cQuery +=" AND ((SC7.C7_QUJE<>0 And SC7.C7_QUJE<C7_QUANT) OR (SC7.C7_QUJE>=SC7.C7_QUANT))"//Nairan - Alterado por o ROWNUM sempre retorna o primeiro registro AND ROWNUM <=1 "
		cQuery +=" ORDER BY SC7.C7_EMISSAO DESC, SC7.R_E_C_N_O_ DESC  "
		
		If Select("QRYULPC") > 0
			DbSelectArea("QRYULPC")
			QRYULPC->(DbCloseArea())
		Endif
		
		TCQUERY cQuery NEW ALIAS "QRYULPC"
		
		DbSelectArea("QRYULPC")
		QRYULPC->(dbGoTop())
		
		//Verifica se existe Contrato Atual para esse produto. Para compor valor de "Saving".
		IF !QRYULPC->(EOF())
			
			cQuery :="SELECT CN9_FILIAL,CNB_PRODUT,CNA_FORNEC,CNA_LJFORN,CNB_VLUNIT,CNB_VLTOT,CN9_DTFIM "
			cQuery +=" FROM " + RETSQLNAME('CN9') + " CN9 "
			cQuery +=" INNER JOIN " + RETSQLNAME('CNA') + " CNA ON CN9.CN9_FILIAL = CNA.CNA_FILIAL AND CN9.CN9_NUMERO = CNA.CNA_CONTRA AND CN9.CN9_REVISA = CNA.CNA_REVISA "
			cQuery +=" INNER JOIN " + RETSQLNAME('CNB') + " CNB ON CNA.CNA_FILIAL = CNB.CNB_FILIAL AND CNA.CNA_CONTRA = CNB.CNB_CONTRA AND CNA.CNA_REVISA = CNB.CNB_REVISA AND CNA.CNA_NUMERO = CNB.CNB_NUMERO "
			cQuery +=" INNER JOIN " + RETSQLNAME('CN1') + " CN1 ON CN9.CN9_FILIAL = CN1.CN1_FILIAL  AND CN9.CN9_TPCTO = CN1.CN1_CODIGO "
			cQuery +=" WHERE CN9.CN9_FILIAL='" + QRYULPC->C7_FILIAL + "' AND CN9.CN9_SITUAC = '05' "
			cQuery +=" AND CNB.CNB_PRODUT ='" + cProd + "' AND CNA.CNA_FORNEC ='" + QRYULPC->C7_FORNECE + "' AND CNA.CNA_LJFORN='" + QRYULPC->C7_LOJA + "' "
			cQuery +=" AND CN1.CN1_ESPCTR='1' AND CN1.D_E_L_E_T_=' ' AND CN9.D_E_L_E_T_=' ' AND CNA.D_E_L_E_T_=' ' AND CNB.D_E_L_E_T_=' ' "
			// Nairan - Alterado dia 05/08/16 - cQuery +=" AND ROWNUM <=1 "
			cQuery +=" ORDER BY CN9.CN9_DTFIM DESC, CN9.R_E_C_N_O_ DESC  "
			
			If Select("QRYSC3") > 0
				DbSelectArea("QRYSC3")
				QRYSC3->(DbCloseArea())
			Endif
			
			TCQUERY cQuery NEW ALIAS "QRYSC3"
			
			DbSelectArea("QRYSC3")
			QRYSC3->(dbGoTop())
					
			IF !QRYSC3->(EOF())
				cSaving := QRYULPC->C7_TOTAL - QRYSC3->CNB_VLTOT
			EndIf
		//Caso N�o exista Ultima Compra ou Contrato. Condi��o utilizada para compor valor "Custo Evitado"
		Else
			//Valor Total do Menor Custo Cotado
			cQuery:= "SELECT C8_TOTAL "
			cQuery += "FROM " + RETSQLNAME('SC8') + " "
			cQuery += "WHERE C8_NUMPED LIKE '%X%' AND C8_FILIAL='" + cFilC8 + "'AND C8_NUM='" + cAlQry->C8_NUM + "' AND C8_PRODUTO='" + cProd + "' "
			cQuery += "AND D_E_L_E_T_=' ' AND ROWNUM <=1 "
			cQuery += "ORDER BY C8_TOTAL"
			
			If Select("QRYMNC") > 0
				DbSelectArea("QRYMNC")
				QRYMNC->(DbCloseArea())
			Endif
				
			TCQUERY cQuery NEW ALIAS "QRYMNC"
			
			//Valor Total do Custo Fechado na Cota��o
			cQuery:= "SELECT C8_TOTAL "
			cQuery += "FROM " + RETSQLNAME('SC8') + " "
			cQuery += "WHERE C8_NUMPED NOT LIKE '%X%' AND C8_FILIAL='" + cFilC8 + "'AND C8_NUM='" + cAlQry->C8_NUM + "' AND C8_PRODUTO='" + cProd + "' "
			cQuery += "AND D_E_L_E_T_=' ' AND ROWNUM <=1 "
			cQuery += "ORDER BY C8_TOTAL"
			
			If Select("QRYFECH") > 0
				DbSelectArea("QRYFECH")
				QRYFECH->(DbCloseArea())
			Endif
				
			TCQUERY cQuery NEW ALIAS "QRYFECH"
			
			cEvitad:= QRYMNC->C8_TOTAL - QRYFECH->C8_TOTAL
			
		EndIf
		//Compra Atual- Pedido de Compras Pendente
		cQuery :="SELECT C7_FILIAL,C7_PRODUTO,C7_FORNECE,C7_LOJA, C7_TOTAL, C7_EMISSAO, C7_QUANT, C7_PRECO, C7_USER, C7_CC, C7_LOCAL,B1_GRUPO, B1_XGRPPRO, B1_XSUBGRP, B1_DESC"
		cQuery +=" FROM " + RETSQLNAME('SC7') + " SC7 "
		cQuery +=" INNER JOIN " + RETSQLNAME('SB1') + " SB1 "
		cQuery +=" ON SC7.C7_PRODUTO = SB1.B1_COD "	
		cQuery +=" WHERE SC7.C7_FILIAL='" + cFilC8 + "' "
		cQuery +=" AND SC7.C7_PRODUTO ='" + cProd + "' And SC7.C7_QUJE=0 And SC7.C7_QTDACLA=0 AND SC7.C7_CONAPRO='L' AND SC7.D_E_L_E_T_=' '" //Nairan Alterado dia 05/08/16 - AND ROWNUM <=1 "
		cQuery +=" ORDER BY SC7.C7_EMISSAO DESC, SC7.R_E_C_N_O_ DESC  "
		
		If Select("QRYSC7") > 0
			DbSelectArea("QRYSC7")
			QRYSC7->(DbCloseArea())
		Endif
			
		TCQUERY cQuery NEW ALIAS "QRYSC7"

		DbSelectArea("TMP")
		TMP->(DbGoTop())
		TMP->(DBSetOrder(1))
		RecLock("TMP",.T.)
		
		TMP->TMP_NUM 	:= cAlQry->C8_NUM
		TMP->TMP_FORNEC := cAlQry->C8_FORNECE
		TMP->TMP_LOJA 	:= cAlQry->C8_LOJA
		TMP->TMP_FORNOM := cAlQry->C8_FORNOME
		TMP->TMP_NUMPRO := cAlQry->C8_NUMPRO
		TMP->TMP_GRUPO 	:= QRYSC7->B1_GRUPO
		TMP->TMP_XGRPPR := QRYSC7->B1_XGRPPRO
		TMP->TMP_XSUBGR := QRYSC7->B1_XSUBGRP
		TMP->TMP_PRODUT := cAlQry->C8_PRODUTO
		TMP->TMP_DESC 	:= QRYSC7->B1_DESC
		TMP->TMP_QUANT1 := cAlQry->C8_QUANT
		TMP->TMP_PRECO1 := cAlQry->C8_PRECO
		TMP->TMP_EVITA 	:= cEvitad
		TMP->TMP_DTULCO := QRYULPC->DTULCOMP
		TMP->TMP_QTULCO := QRYULPC->QTULCOMP
		TMP->TMP_PRULCO := QRYULPC->PRULCOMP
		TMP->TMP_SAVING := cSaving
		TMP->TMP_EMISSA := QRYSC7->C7_EMISSAO
		TMP->TMP_QUANT2 := QRYSC7->C7_QUANT
		TMP->TMP_PRECO2 := QRYSC7->C7_PRECO
		TMP->TMP_TOTAL 	:= QRYSC7->C7_TOTAL
		TMP->TMP_USER 	:= QRYSC7->C7_USER
		TMP->TMP_FILIAL := QRYSC7->C7_FILIAL
		TMP->TMP_CC 	:= QRYSC7->C7_CC
		TMP->TMP_DESC01 := Alltrim(Posicione("CTT",1,xFilial("CTT") + QRYSC7->C7_CC,"CTT_DESC01"		)	)
		TMP->TMP_LOCAL 	:= QRYSC7->C7_LOCAL
		TMP->TMP_DESCRI := Alltrim(Posicione("NNR",1,xFilial("NNR") + QRYSC7->C7_LOCAL,"NNR_DESCRI"	)	)

		TMP->( MsUnlock() )

		cAlQry->(dbSkip())
	EndDo
	
	DbSelectArea("TMP")
	
	TMP->(DbGoTop())
	TMP->(DBSetOrder(1))
	Do While TMP->(!Eof())
		oSection:PrintLine()
		TMP->(DbSkip())
	Enddo
	
	oSection:Finish()
	
	If Select("cAlQry") > 0
		DbSelectArea("cAlQry")
		cAlQry->(DbCloseArea())
	Endif
	
	If Select("TMP") > 0
		DbSelectArea("TMP")
		TMP->(DbCloseArea())
	Endif
	
	oTempTable1:Delete() //Thais Paiva 04/12/2020
	
	RestArea(aArea)

Return .T.

/*
{Protheus.doc} F021Stru()
Carrega a estrutura da Tabela Tempor�ria
@Author     Mick William da Silva
@Since      02/06/2016
@Version    P12.7
@Project    MAN00000463301_EF_001
@Return    
*/


Static Function F021Stru()

	
	// CRIA ARQUIVO TEMPORARIO
	// ==================================
	AAdd(aStrCmp, {"TMP_NUM" 	,"C",	06,	0}	)
	AAdd(aStrCmp, {"TMP_FORNEC"	,"C",	06,	0}	)
	AAdd(aStrCmp, {"TMP_LOJA"	,"C",	02,	0}	)
	AAdd(aStrCmp, {"TMP_FORNOM"	,"C",	80,	0}	)
	AAdd(aStrCmp, {"TMP_NUMPRO"	,"C",	02,	0}	)
	AAdd(aStrCmp, {"TMP_GRUPO"	,"C",	04,	0}	)
	AAdd(aStrCmp, {"TMP_XGRPPR"	,"C",	04,	0}	)
	AAdd(aStrCmp, {"TMP_XSUBGR"	,"C",	04,	0}	)
	AAdd(aStrCmp, {"TMP_PRODUT"	,"C",	15,	0}	)
	AAdd(aStrCmp, {"TMP_DESC"	,"C",	30,	0}	)
	AAdd(aStrCmp, {"TMP_QUANT1"	,"N",	12,	2}	)
	AAdd(aStrCmp, {"TMP_PRECO1"	,"N",	14,	2}	)
	AAdd(aStrCmp, {"TMP_EVITA"	,"N",	14,	2}	)
	AAdd(aStrCmp, {"TMP_DTULCO"	,"C",	08,	0}	)
	AAdd(aStrCmp, {"TMP_QTULCO"	,"N",	12,	2}	)
	AAdd(aStrCmp, {"TMP_PRULCO"	,"N",	14,	2}	)
	AAdd(aStrCmp, {"TMP_SAVING"	,"N",	14,	2}	)
	AAdd(aStrCmp, {"TMP_EMISSA"	,"C",	08,	0}	)
	AAdd(aStrCmp, {"TMP_QUANT2"	,"N",	12,	2}	)
	AAdd(aStrCmp, {"TMP_PRECO2"	,"N",	14,	2}	)
	AAdd(aStrCmp, {"TMP_TOTAL"	,"N",	14,	2}	)
	AAdd(aStrCmp, {"TMP_USER"	,"C",	06,	0}	)
	AAdd(aStrCmp, {"TMP_FILIAL"	,"C",	08,	0}	)
	AAdd(aStrCmp, {"TMP_CC"		,"C",	09,	0}	)
	AAdd(aStrCmp, {"TMP_DESC01"	,"C",	40,	0}	)
	AAdd(aStrCmp, {"TMP_LOCAL"	,"C",	02,	0}	)
	AAdd(aStrCmp, {"TMP_DESCRI"	,"C",	20,	0}	)
	
Return (.T.)
