#Include "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE 'parmtype.ch'
/*{Protheus.doc} F0200901
Relatório de Evolução de Preços
@Project MAN00000463301_EF_009
@author queizy.nascimento
@since 10/10/2016
*/ 
User Function F0200901()
	
	Local oReport := nil
	
	Private cPerg := "FSW0200901"
	
	If Pergunte(cPerg, .T.)
		oReport := RptDef(cPerg)
		oReport:PrintDialog()
	EndIf
	
Return

Static Function ReportPrint(oReport)
	
	Local oSection1 := oReport:Section(1)
	Local cProdIni  := Space(TamSX3("B1_COD")[1])
	Local cProdFim  := Space(TamSX3("B1_COD")[1])
	Local cFilIni   := Space(TamSX3("C7_FILIAL")[1])
	Local cFilFim   := Space(TamSX3("C7_FILIAL")[1])
	Local cGrpdIni  := Space(TamSX3("B1_GRUPO")[1])
	Local cGrpdFim  := Space(TamSX3("B1_GRUPO")[1])
	Local aAux      := {}
	Local nx        := 0
	Local na        := 0
	Local cGrpIni   := ""
	Local cFilSBM	:= xFilial('SBM')
		
	Private aPer1   := {}
	Private aPer2   := {}
	Private aRelImp := {}
	Private cProdRet,cFilRet,cGrupoProd
	Private cPer1   := DtoS(MV_PAR04) + "/" + DtoS(MV_PAR05)
	Private cPer2   := DtoS(MV_PAR06) + "/" + DtoS(MV_PAR07)
	
	//Tratativa dos parametros para passar a query
	cFilRet   := Alltrim(MV_PAR01)
	cGrupoProd:= Alltrim(MV_PAR02)
	cProdRet  := Alltrim(MV_PAR03)
	
	If at('-',cFilRet) > 0
		cFilRet := StrTran(cFilRet,";","")
		cFilIni := Substr(cFilRet,1, at('-', cFilRet) - 1)
		cFilFim := Substr(cFilRet,at('-', cFilRet) + 1,TamSX3("C7_FILIAL")[1] )
	Else
		aAux := StrtoKarr(cFilRet,';')
		cFilRet:= ""
		For nX := 1 To Len(aAux)
			If Alltrim(aAux[nX]) != ""
				cFilRet += "'" + aAux[nX] + "',"
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
				cProdRet += "'" + aAux[nX] + "',"
			Endif
		Next
		If Right(AllTrim(cProdRet),1) == ','
			cProdRet := SubStr(AllTrim(cProdRet),1,Len(AllTrim(cProdRet))-1)
		Endif
	EndIf
	aAux := {}
	If at('-',cGrupoProd) > 0
		cGrupoProd:= StrTran(cGrupoProd,";","")
		cGrpIni := Substr(cGrupoProd,1, at('-', cGrupoProd) - 1)
		cGrpFim := Substr(cGrupoProd,at('-', cGrupoProd) + 1,TamSX3("B1_GRUPO")[1] )
	Else
		aAux := StrtoKarr(cGrupoProd,';')
		cGrupoProd:= ""
		For nX := 1 To Len(aAux)
			If Alltrim(aAux[nX]) != ""
				cGrupoProd += "'" + aAux[nX] + "',"
			Endif
		Next
		If Right(AllTrim(cGrupoProd),1) == ','
			cGrupoProd := SubStr(AllTrim(cGrupoProd),1,Len(AllTrim(cGrupoProd))-1)
		Endif
	EndIf

	//Monta a query
	cQuery:=" SELECT C7_FILIAL EMPRESA, B1_COD CODPRO, CASE WHEN BM.BM_DESC IS NULL THEN '' ELSE BM.BM_DESC END GRUPO , B1_DESC DESCRI, '1' PER, '" + DTOS(MV_PAR04) + "/" + DTOS(MV_PAR05) + "' DEATE, " + CRLF
	cQuery +=" SUM(C7_QUANT) QUANTTOT, SUM(C7_TOTAL) VALTOT, SUM(C7_TOTAL)/SUM(C7_QUANT) MEDIA " + CRLF
	cQuery +=" FROM " + RETSQLNAME('SC7') + "  C7 " + CRLF
	cQuery +=" INNER JOIN " + RETSQLNAME('SB1') + " B1 ON B1_FILIAL = '" + xFilial("SB1") + "' AND B1.D_E_L_E_T_  = ' ' AND C7_PRODUTO = B1_COD " + CRLF
	cQuery +=" LEFT  JOIN " + RETSQLNAME('SBM') + " BM ON BM_FILIAL = '" + cFilSBM        + "' AND BM.BM_GRUPO = B1.B1_GRUPO AND BM.D_E_L_E_T_  = ' ' AND C7.C7_PRODUTO = B1.B1_COD " + CRLF
	cQuery +=" WHERE C7.D_E_L_E_T_ = '' " + CRLF
	//Se o parametro Filial não estiver vazio ele adiciona essa linha a query,caso o contrario
	//a query ira rodar sem filtro
	If  !Empty (MV_PAR01)
		If Empty(cFilIni)
			cQuery += " AND C7_FILIAL IN ('" + cFilRet + "') " + CRLF // ticket #9103900 - ajuste sintaxe query
		Else
			cQuery +=" AND C7_FILIAL BETWEEN '" + cFiLIni + "' AND '" + cFilFim + "' " + CRLF
		EndIf
	EndIf
	cQuery +=" AND C7_EMISSAO BETWEEN '" + DTOS(MV_PAR04) + "' AND '" + DTOS(MV_PAR05) + "' " + CRLF
	If !Empty (MV_PAR02)
		If Empty(cGrpIni)
			cQuery += " AND B1_GRUPO IN ('" + cGrupoProd + "') " + CRLF
		Else
			cQuery +=" AND B1_GRUPO BETWEEN '" + cGrpIni + "' AND '" + cGrpFim + "' " + CRLF
		EndIf
	EndIf
	If !Empty (MV_PAR03)
		//Se o parametro Produto não estiver vazio ele adiciona essa linha a query,caso o contrario
		//a query ira rodar sem filtro
		If Empty(cProdIni)
			cQuery +=" AND C7_PRODUTO IN ('" + cProdRet + "') " + CRLF // ticket #9103900 - ajuste sinntaxe query
		Else
			cQuery +=" AND C7_PRODUTO BETWEEN '" + cProdIni + "' AND '" + cProdFim + "' " + CRLF
		EndIf
	EndIf
	cQuery +=" GROUP BY C7_FILIAL, B1_COD, BM_DESC ,B1_DESC " + CRLF
	
	cQuery +=" UNION ALL" + CRLF
	cQuery +=" SELECT C7_FILIAL EMPRESA, B1_COD CODPRO, CASE WHEN BM.BM_DESC IS NULL THEN '' ELSE BM.BM_DESC END GRUPO , B1_DESC DESCRI, '2' PER, '" + DTOS(MV_PAR06) + "/" + DTOS(MV_PAR07) + "' DEATE, " + CRLF
	cQuery +=" SUM(C7_QUANT) QUANTTOT,  SUM(C7_TOTAL) VALTOT, SUM(C7_TOTAL)/SUM(C7_QUANT) MEDIA " + CRLF
	cQuery +=" FROM " + RETSQLNAME('SC7') + " C7 " + CRLF
	cQuery +=" INNER JOIN " + RETSQLNAME('SB1') + "  B1 ON B1_FILIAL = '" + xFilial("SB1") + "' AND B1.D_E_L_E_T_  = ' ' AND C7_PRODUTO = B1_COD " + CRLF
	cQuery +=" LEFT  JOIN " + RETSQLNAME('SBM') + " BM ON BM_FILIAL  = '" + cFilSBM        + "' AND BM.BM_GRUPO = B1.B1_GRUPO AND BM.D_E_L_E_T_  = ' ' AND C7.C7_PRODUTO = B1.B1_COD " + CRLF
	cQuery +=" WHERE C7.D_E_L_E_T_ = '' " + CRLF
	If  !Empty (MV_PAR01)
		If Empty(cFilIni)
			cQuery += " AND C7_FILIAL IN ('" + cFilRet + "') " + CRLF // ticket #9103900 - ajuste sintaxe query
		Else
			cQuery +=" AND C7_FILIAL BETWEEN '" + cFiLIni + "' AND '" + cFilFim + "' " + CRLF
		EndIf
	EndIf
	cQuery +=" AND C7_EMISSAO BETWEEN '" + DTOS(MV_PAR06) + "' AND '" + DTOS(MV_PAR07) + "' " + CRLF
	If !Empty (MV_PAR02)
		If Empty(cGrpIni)
			cQuery += " AND B1_GRUPO IN ('" + cGrupoProd + "') " + CRLF
		Else
			cQuery +=" AND B1_GRUPO BETWEEN '" + cGrpIni + "' AND '" + cGrpFim + "' " + CRLF
		EndIf
	EndIf
	If !Empty (MV_PAR03)
		//Se o parametro Produto não estiver vazio ele adiciona essa linha a query,caso o contrario
		//a query ira rodar sem filtro
		If Empty(cProdIni)
			cQuery +=" AND C7_PRODUTO IN ('" + cProdRet + "') " + CRLF // ticket #9103900 - ajuste sinntaxe query
		Else
			cQuery +=" AND C7_PRODUTO BETWEEN '" + cProdIni + "' AND '" + cProdFim + "' " + CRLF
		EndIf
	EndIf
	cQuery +=" GROUP BY C7_FILIAL, B1_COD, BM_DESC ,B1_DESC " + CRLF

	cQuery := ChangeQuery(cQuery)
	If Select("QRY") > 0
		Dbselectarea("QRY")
		QRY->(DbClosearea())
	Endif
	TcQuery cQuery New ALIAS "QRY"
	dbSelectArea("QRY")
	dbGotop()
	
	oReport:SetMeter(QRY->(LastRec()))
	oSection1:Init()
	oReport:IncMeter()
	
	While QRY->(!Eof())
		If oReport:Cancel()
			Exit
		EndIf
		
		If QRY->PER == '1'
			// Array com os dados do Periodo 1
			AAdd(aPer1,{QRY->EMPRESA, QRY->GRUPO, QRY->CODPRO, QRY->DESCRI, QRY->DEATE, QRY->QUANTTOT, QRY->VALTOT, QRY->MEDIA})
		Else
			// Array com os dados do Periodo 2
			AAdd(aPer2,{QRY->EMPRESA, QRY->GRUPO, QRY->CODPRO, QRY->DESCRI, QRY->DEATE, QRY->QUANTTOT, QRY->VALTOT, QRY->MEDIA,.F.})
		Endif
		QRY->(dbSkip())
	Enddo

	For nx:=1 to Len (aPer1)
		If AScan(aPer2,{|x| x[1] == aPer1[nx,1] .And. x[3] == aPer1[nx,3] .And. x[5] == cPer2 }) > 0
			AAdd(aRelImp,{aPer1[nx,1], aPer1[nx,2], aPer1[nx,3], aPer1[nx,4], aPer1[nx,5], aPer1[nx,6], aPer1[nx,7],aPer1[nx,8],'','','','','','','','','Compra P1/P2',})
		Else
			AAdd(aRelImp,{aPer1[nx,1], aPer1[nx,2], aPer1[nx,3], aPer1[nx,4], aPer1[nx,5], aPer1[nx,6], aPer1[nx,7],aPer1[nx,8],'', 0, 0, 0, 0, 0, 0, 0, 'Compra P1',})
		EndIf
	Next nx
	
	For nx:=1 to Len (aPer2)
		ny := AScan(aPer1,{|x| x[1] == aPer2[nx,1] .And. x[3] == aPer2[nx,3] .And. x[5] == cPer1 })
		If ny <= 0
			AAdd(aRelImp,{aPer2[nx,1],aPer2[nx,2],aPer2[nx,3],aPer2[nx,4],'', 0, 0, 0, aPer2[nx,5], aPer2[nx,6],aPer2[nx,7],aPer2[nx,8], 0, 0, 0, 0,'Compra P2',})
		Else
			aRelImp[ny,09] := aPer2[nx,05]
			aRelImp[ny,10] := aPer2[nx,06]
			aRelImp[ny,11] := aPer2[nx,07]
			aRelImp[ny,12] := aPer2[nx,08]
			aRelImp[ny,13] := aRelImp[ny,10] * aRelImp[ny,08] 
			aRelImp[ny,14] := aRelImp[ny,11] - (aRelImp[ny,10] * aRelImp[ny,08])
			aRelImp[ny,15] := Round(Iif( aRelImp[ny,08] == aPer2[nx,08], 0, Iif( aRelImp[ny,06] == aPer2[nx,06], aPer2[nx,07] - aRelImp[ny,07], (aRelImp[ny,06] * aPer2[nx,08]) - aRelImp[ny,07] )),2)
			aRelImp[ny,16] := Round((aPer2[nx,08] - aRelImp[ny,08]) /  aRelImp[ny,08] *100, 2)
			If aRelImp[ny,06] != aPer2[nx,06] .And. aRelImp[ny,08] != aPer2[nx,08]
//				aRelImp[ny,17] := Alltrim(aRelImp[ny,17]) + " - Qtd. Dif. "
				aRelImp[ny,17] := 'Compra P1/P2'
			EndIf
		EndIf
	Next nx
 

	//IMPRESSÃO DO  RELATORIO

	For na:=1 to Len (aRelImp)
		oSection1:Cell("FILIAL"		):SetValue(FWFilialName(,aRelImp[na,1]))
		oSection1:Cell("GRUPO" 		):SetValue(aRelImp[na,2])
		oSection1:Cell("CODIGO" 	):SetValue(aRelImp[na,3])
		oSection1:Cell("DESC"		):SetValue(aRelImp[na,4])
		oSection1:Cell("DEATE"		):SetValue(If(Empty(aRelImp[na,5]),aRelImp[na,5],Substr(aRelImp[na,5],7,2) + "/" + Substr(aRelImp[na,5],5,2) + "/" + Substr(aRelImp[na,5],1,4) + "-" + Substr(aRelImp[na,5],16,2) + "/" + Substr(aRelImp[na,5],14,2) + "/" + Substr(aRelImp[na,5],10,4)))
		oSection1:Cell("QUANTTOT"	):SetValue(aRelImp[na,6])
		oSection1:Cell("VALTOT"		):SetValue(aRelImp[na,7])
		oSection1:Cell("VALUNI"		):SetValue(aRelImp[na,8])
		oSection1:Cell("DEATE2"		):SetValue(If(Empty(aRelImp[na,9]),aRelImp[na,9],Substr(aRelImp[na,9],7,2) + "/" + Substr(aRelImp[na,9],5,2) + "/" + Substr(aRelImp[na,9],1,4) + "-" + Substr(aRelImp[na,9],16,2) + "/" + Substr(aRelImp[na,9],14,2) + "/" + Substr(aRelImp[na,9],10,4)))
		oSection1:Cell("QUANTTOT1"	):SetValue(aRelImp[na,10])
		oSection1:Cell("VALTOT1"	):SetValue(aRelImp[na,11])
		oSection1:Cell("VALUNI1"	):SetValue(aRelImp[na,12])
		oSection1:Cell("VALTOTENS"	):SetValue(aRelImp[na,13])
		oSection1:Cell("VALTOTDIF"	):SetValue(aRelImp[na,14])
//		oSection1:Cell("DIFENS"		):SetValue(aRelImp[na,15])
//		oSection1:Cell("PERDIF"		):SetValue(aRelImp[na,16])
		oSection1:Cell("PERDIF"		):SetValue(aRelImp[na,14] / aRelImp[na,13])
		oSection1:Cell("Obs"		):SetValue(aRelImp[na,17])
		oSection1:Printline()
	Next na
	oSection1:Finish()
	
Return

/*{Protheus.doc} RptDef
Function que monta  estrutura do relatorio
@author queizy.nascimento
@since 27/09/2016
*/
Static Function RptDef(cNome)
	Local oReport	:= Nil
	Local oSection1	:= Nil
	Local oBreak
	Local oFunction
	
	oReport := TReport():New(cNome,"Relatório Evolucao de Preço",cNome,{|oReport| ReportPrint(oReport)},"Descrição do meu relatório")
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)
	
	oSection1:= TRSection():New(oReport, "PROD", {"SB1"}, , .F., .T.)
	TRCell():New(oSection1,"FILIAL"	  ,"QRY","Filial"  				,"@!"				,30	,.T.)
	TRCell():New(oSection1,"GRUPO"    ,"QRY","Grp. Material"		,"@!"				,20	,.T.)
	TRCell():New(oSection1,"CODIGO"	  ,"QRY","Cod. Produto "		,"@!"				,50	,.T.)
	TRCell():New(oSection1,"DESC"	  ,"QRY","Descriçao"  			,"@!"				,46	,.T.)
	TRCell():New(oSection1,"DEATE"	  ,"QRY","Periodo 1"  			,"@!"				,70		)
	TRCell():New(oSection1,"QUANTTOT" ,"QRY","Quantidade"  			,"@E 99999999"		,20)
	TRCell():New(oSection1,"VALTOT"	  ,"QRY","Val. Total"  			,"@E 999999999.99"	,25)
	TRCell():New(oSection1,"VALUNI"	  ,"QRY","Val. Unit."  			,"@E 99999999.99"	,22	,.T.)
	TRCell():New(oSection1,"DEATE2"	  ,"QRY","Periodo 2"  			,"@!"				,70)
	TRCell():New(oSection1,"QUANTTOT1","QRY","Quantidade"  			,"@E 99999999"		,20)
	TRCell():New(oSection1,"VALTOT1"  ,"QRY","Val. Total"  			,"@E 999999999.99"	,25)
	TRCell():New(oSection1,"VALUNI1"  ,"QRY","Val. Unit."  			,"@E 99999999.99"	,22	,.T.)
	TRCell():New(oSection1,"VALTOTENS","QRY","Val. Total Ensaio"	,"@E 99999999.99"	,22	,.T.) //Valor Total do Ensaio 
	TRCell():New(oSection1,"VALTOTDIF","QRY","Val. Dif. Ensaio"		,"@E 99999999.99"	,22	,.T.) //Valor de Diferença do Ensaio
//	TRCell():New(oSection1,"DIFENS"	  ,"QRY","Val. Difer."  		,"@E 999999999.99"	,25)
	TRCell():New(oSection1,"PERDIF"	  ,"QRY","%Diferença"  			,"@E 9999.99%"		,19)
	TRCell():New(oSection1,"Obs"      ,"QRY","Observaçao"   		,"@!"				,60	,.T.)
	
Return oReport