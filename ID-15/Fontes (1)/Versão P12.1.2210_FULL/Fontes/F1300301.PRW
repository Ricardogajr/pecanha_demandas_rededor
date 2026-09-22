#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "REPORT.CH"

/*/{Protheus.doc} F1300301
Geração do relatório Relatório de Headcount Sintético
@author henrique.toyada
@since 27/09/2017
@version 6
@project MAN0000007423048_EF_003

@type function
/*/
user function F1300301()

	Local oReport := nil
	Local cPerg:= Padr("FSW1300301",10)

	Private cFilSoli := ""
	Private cMatSoli := ""
	
	If ValidUsr(@cFilSoli, @cMatSoli)
		Pergunte(cPerg,.T.)
		oReport := RptDef(cPerg)
		oReport:PrintDialog()
	EndIf
Return


/*/{Protheus.doc} RptDef
Montagem da estrutura do relatório
@author henrique.toyada
@since 27/09/2017
@version 6
@project MAN0000007423048_EF_003
@param cNome, characters, descricao
@type function
/*/
Static Function RptDef(cNome)

	Local cPerg:= Padr("FSW1300301",10)
	Local oReport := Nil
	Local oSection:= Nil
	Local oBreak
	Local oFunction

	oReport := TReport():New(cNome,"Relatório de Headcount Sintético",cNome,{|oReport| ReportPrint(oReport)},"Relatório de Headcount Sintético")
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)

	oSection:= TRSection():New(oReport,	 "RD4", {"RD4"}, , .F., .T.,,,,.T.)
	TRCell():New(oSection, "TMP_GESTOR", "RD4", "Gestor Imediato"      , "@!", TAMSX3("RA_NOME")[1]   , .T.,,,.T.)
	TRCell():New(oSection, "RCL_FILIAL", "RD4", "Filial"               , "@!", TAMSX3("RCL_FILIAL")[1], .T.,,,.T.)
	TRCell():New(oSection, "QB_DEPTO"  , "RD4", "Cod.Depto."           , "@!", TAMSX3("QB_DEPTO")[1]  , .T.,,,.T.)
	TRCell():New(oSection, "QB_DESCRIC", "RD4", "Descrição do Depto."  , "@!", TAMSX3("QB_DESCRIC")[1], .T.,,,.T.)
	TRCell():New(oSection, "RCL_POSTO", "RD4", "Posto"                 , "@!", TAMSX3("RCL_POSTO")[1], .T.,,,.T.)
	TRCell():New(oSection, "RCL_CARGO" , "RD4", "Cargo"                , "@!", TAMSX3("RCL_CARGO")[1] , .T.,,,.T.)
	TRCell():New(oSection, "Q3_DESCSUM", "RD4", "Descrição do Cargo"   , "@!", TAMSX3("Q3_DESCSUM")[1], .T.,,,.T.)
	TRCell():New(oSection, "RCL_NPOSTO", "RD4", "Qtd.Máxima"           , "@!", TAMSX3("RCL_NPOSTO")[1], .T.,,,.T.)
	TRCell():New(oSection, "RCL_OPOSTO", "RD4", "Qtd.Ocupados"         , "@!", TAMSX3("RCL_OPOSTO")[1], .T.,,,.T.)
	TRCell():New(oSection, "TMP_RESERV", "RD4", "Qtd.Reservados"       , "@!", TAMSX3("RCL_OPOSTO")[1], .T.,,,.T.)
	TRCell():New(oSection, "TMP_DISPON", "RD4", "Qtd.Disponível"       , "@!", TAMSX3("RCL_OPOSTO")[1], .T.,,,.T.)
	oReport:SetTotalInLine(.F.)

	oSection:SetPageBreak(.T.)
	oSection:SetTotalText(" ")

Return(oReport)


/*/{Protheus.doc} ReportPrint
Montagem dos dados
@author henrique.toyada
@since 27/09/2017
@version 6
@project MAN0000007423048_EF_003
@param oReport, object, descricao
@type function
/*/
Static Function ReportPrint(oReport)

	Local nCnt      := 0
	Local cPath     := GetTempPath()
	Local cArq      := "FS" + DToS(dDataBase) + StrTran(time(),':','')
	Local cQry      := ""
	Local cEOL      := CHR(13) + CHR(10)
	Local cAliasTmp := "TMP"
	Local cQuery    := ""
	Local cGeren    := ""
	Local cChave    := ""
	Local lNOracle  := TCGetDB() == 'ORACLE'
	Local cVisao    := ""
	Local cPerg     := Padr("FSW1300301",10)
	Local oExcelApp := MsExcel():New()
	Local oSection  := oReport:Section(1)

	MakeSqlExpr( cPerg )
	
	If EMPTY(MV_PAR01)
		Help( ,, 'HELP',, 'Prencher o código da visão para continuar', 1, 0)
		Return
	EndIf
	
	If !(EMPTY(MV_PAR01))
		cVisao := MV_PAR01
	EndIf

	If SRA->(DbSeek(cFilSoli + cMatSoli))
		cQuery := "SELECT RD4.RD4_CHAVE "
		cQuery += "FROM " + RETSQLNAME('RD4') + " RD4 "
		cQuery += "INNER JOIN " + RETSQLNAME('SRA') + " SRA "
		cQuery += "ON SRA.D_E_L_E_T_ = ' ' "
		cQuery += "AND SRA.RA_FILIAL = '" + cFilSoli + "' "
		cQuery += "AND SRA.RA_MAT = '" + cMatSoli + "' "
		cQuery += "AND SRA.RA_POSTO = RD4.RD4_CODIDE "
		cQuery += "WHERE RD4.D_E_L_E_T_ = ' '	"
		cQuery += "AND RD4.RD4_CODIGO = " + MV_PAR01 + " "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp)

		If (cAliasTmp)->(!(EOF()))
			cChave := (cAliasTmp)->RD4_CHAVE
		EndIf
		(cAliasTmp)->(DbCloseArea())

		cQuery := "SELECT RJ_XGEREN "
		cQuery += "FROM " + RETSQLNAME('SRJ') + " SRJ "
		cQuery += "WHERE SRJ.D_E_L_E_T_ = ' '	"
		cQuery += "AND SRJ.RJ_FUNCAO = '" + SRA->RA_CODFUNC + "' "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp)

		If (cAliasTmp)->(!(EOF()))
			cGeren := (cAliasTmp)->RJ_XGEREN
		EndIf
		(cAliasTmp)->(DbCloseArea())
	EndIf

	cQuery := "SELECT RCL.RCL_FILIAL, "
	cQuery += "       RCL.RCL_POSTO, "
	cQuery += "       RCL.RCL_CARGO, "
	cQuery += "       RCL.RCL_DEPTO, "
	cQuery += "       RCL.RCL_OPOSTO, "
	cQuery += "       RCL.RCL_NPOSTO, "
	cQuery += "  ( "
	If lNOracle
		cQuery += "SELECT COUNT( * ) FROM "
		cQuery +="(SELECT "
		cQuery +=" RH4F.RH4_CAMPO RH4f_DEF, RH4p.RH4_CAMPO RH4p_DEF, RPAD(RH4f.RH4_VALNOV,8,' ') FILIAL, RPAD(RH4p.RH4_VALNOV,9,' ') POSTO, RH3b.RH3_XTPCTM, "
		cQuery +=" RH3b.RH3_FILIAL, RH3b.RH3_STATUS, RH3b.RH3_CODIGO "
		cQuery +=" FROM "+RetSqlName("RH3")+" RH3b "
		cQuery +=" left JOIN "+RetSqlName("RH4")+" RH4f ON RH4f.RH4_FILIAL = RH3b.RH3_FILIAL "
		cQuery +=" AND RH4f.RH4_CODIGO = RH3b.RH3_CODIGO "
		cQuery +=" AND RH4f.RH4_CAMPO = RPAD(DECODE( RH3b.RH3_XTPCTM, '002', 'QS_FILPOST','006','RA_FILIAL'),10,' ') "
		cQuery +=" left JOIN "+RetSqlName("RH4")+" RH4p ON RH4p.RH4_FILIAL = RH3b.RH3_FILIAL "
		cQuery +=" AND RH4p.RH4_CODIGO = RH3b.RH3_CODIGO "
		cQuery +=" AND RH4p.RH4_CAMPO = RPAD(DECODE( RH3b.RH3_XTPCTM, '002', 'QS_POSTO','006','RA_POSTO'),10, ' ') "
		cQuery +=" AND RH4p.D_E_L_E_T_ <> '*' "
		cQuery +=" INNER JOIN  "+RetSqlName("PAB")+" PAB ON PAB.D_E_L_E_T_ = ' ' "
		cQuery +=" AND RH3_XCODAL = PAB_CODIGO AND RH3_XTPCTM = PAB_TPSOLI "
		cQuery +=" WHERE RH3b.D_E_L_E_T_ = ' ' "
		cQuery +="   AND RH3b.RH3_XTPCTM IN ('002','004','006') "
		cQuery +="   AND RH3b.RH3_STATUS IN ('1','4') "
		cQuery +=" AND ( EXISTS  (SELECT 1 FROM "+RetSqlName("SQS")+" SQS   WHERE SQS.QS_XSOLFIL = RH3b.RH3_FILIAL "
		cQuery +=" AND   SQS.QS_XSOLPTL = RH3b.RH3_CODIGO   AND   SQS.D_E_L_E_T_ = ' ' "
		cQuery +=" AND   SQS.QS_XSTATUS in ('1','2','3','4','6','8')   AND   ROWNUM = 1  )    OR RH3b.RH3_STATUS IN ('1','4') ) "
		cQuery +=" ) RALL "
		cQuery +=" WHERE RALL.FILIAL = RCL.RCL_FILIAL AND RALL.POSTO = RCL.RCL_POSTO "
	Else
		cQuery +="SELECT COUNT( * ) FROM "
		cQuery +="  (SELECT RH4F.RH4_CAMPO RH4f_DEF, "
		cQuery +="          RH4p.RH4_CAMPO RH4p_DEF, "
		cQuery +="          RH4f.RH4_VALNOV FILIAL, "
		cQuery +="          RH4p.RH4_VALNOV POSTO, "
		cQuery +="          RH3b.RH3_XTPCTM, "
		cQuery +="          RH3b.RH3_FILIAL, "
        cQuery +="          RH3b.RH3_STATUS, "
		cQuery +="          RH3b.RH3_CODIGO "
		cQuery +="   FROM "+RetSqlName("RH3")+" RH3b "
		cQuery +="   LEFT JOIN "+RetSqlName("RH4")+" RH4f ON RH4f.RH4_FILIAL = RH3b.RH3_FILIAL "
		cQuery +="   AND RH4f.RH4_CODIGO = RH3b.RH3_CODIGO "
		cQuery +="   AND RH4f.RH4_CAMPO = RIGHT(CASE RH3b.RH3_XTPCTM  WHEN '002' THEN  'QS_FILPOST' WHEN '006' THEN 'RA_FILIAL' END,10) "
		cQuery +="   LEFT JOIN "+RetSqlName("RH4")+" RH4p ON RH4p.RH4_FILIAL = RH3b.RH3_FILIAL "
		cQuery +="   AND RH4p.RH4_CODIGO = RH3b.RH3_CODIGO "
		cQuery +="   AND RH4p.RH4_CAMPO = RIGHT(CASE RH3b.RH3_XTPCTM  WHEN '002' THEN  'QS_POSTO' WHEN '006' THEN 'RA_POSTO' END,10) "
		cQuery +="   AND RH4p.D_E_L_E_T_ <> '*' "
		cQuery +="   INNER JOIN "+RetSqlName("PAB")+" PAB ON PAB.D_E_L_E_T_ = ' ' "
		cQuery +="   AND RH3_XCODAL = PAB_CODIGO "
		cQuery +="   AND RH3_XTPCTM = PAB_TPSOLI "
		cQuery +="   WHERE RH3b.D_E_L_E_T_ = ' ' "
		cQuery +="   AND RH3b.RH3_XTPCTM IN ('002','004','006') "
		cQuery +="   AND RH3b.RH3_STATUS IN ('1','4') "
		cQuery +="     AND (EXISTS "
		cQuery +="            (SELECT 1 FROM "+RetSqlName("SQS")+" SQS "
		cQuery +="             WHERE SQS.QS_XSOLFIL = RH3b.RH3_FILIAL "
		cQuery +="               AND SQS.QS_XSOLPTL = RH3b.RH3_CODIGO "
		cQuery +="               AND SQS.D_E_L_E_T_ = ' ' "
		cQuery +="               AND SQS.QS_XSTATUS IN ('1','2','3','4','6','8') "
		cQuery +="                ) "
		cQuery +="          OR RH3b.RH3_STATUS IN ('1','4')) ) RALL "
		cQuery +=" WHERE RALL.FILIAL = RCL.RCL_FILIAL AND RALL.POSTO = RCL.RCL_POSTO "	
	EndIf 
	cQuery +=" ) AS RESERVADOS, "
	cQuery += "       (RCL.RCL_NPOSTO - (RCL.RCL_OPOSTO + "
	cQuery += "                            ( "
	If lNOracle
		cQuery += "SELECT COUNT( * ) FROM "
		cQuery +="(SELECT "
		cQuery +=" RH4F.RH4_CAMPO RH4f_DEF, RH4p.RH4_CAMPO RH4p_DEF, RPAD(RH4f.RH4_VALNOV,8,' ') FILIAL, RPAD(RH4p.RH4_VALNOV,9,' ') POSTO, RH3b.RH3_XTPCTM, "
		cQuery +=" RH3b.RH3_FILIAL, RH3b.RH3_STATUS, RH3b.RH3_CODIGO "
		cQuery +=" FROM "+RetSqlName("RH3")+" RH3b "
		cQuery +=" left JOIN "+RetSqlName("RH4")+" RH4f ON RH4f.RH4_FILIAL = RH3b.RH3_FILIAL "
		cQuery +=" AND RH4f.RH4_CODIGO = RH3b.RH3_CODIGO "
		cQuery +=" AND RH4f.RH4_CAMPO = RPAD(DECODE( RH3b.RH3_XTPCTM, '002', 'QS_FILPOST','006','RA_FILIAL'),10,' ') "
		cQuery +=" left JOIN "+RetSqlName("RH4")+" RH4p ON RH4p.RH4_FILIAL = RH3b.RH3_FILIAL "
		cQuery +=" AND RH4p.RH4_CODIGO = RH3b.RH3_CODIGO "
		cQuery +=" AND RH4p.RH4_CAMPO = RPAD(DECODE( RH3b.RH3_XTPCTM, '002', 'QS_POSTO','006','RA_POSTO'),10, ' ') "
		cQuery +=" AND RH4p.D_E_L_E_T_ <> '*' "
		cQuery +=" INNER JOIN  "+RetSqlName("PAB")+" PAB ON PAB.D_E_L_E_T_ = ' ' "
		cQuery +=" AND RH3_XCODAL = PAB_CODIGO AND RH3_XTPCTM = PAB_TPSOLI "
		cQuery +=" WHERE RH3b.D_E_L_E_T_ = ' ' "
		cQuery +=" AND ( EXISTS  (SELECT 1 FROM "+RetSqlName("SQS")+" SQS   WHERE SQS.QS_XSOLFIL = RH3b.RH3_FILIAL "
		cQuery +=" AND   SQS.QS_XSOLPTL = RH3b.RH3_CODIGO   AND   SQS.D_E_L_E_T_ = ' ' "
		cQuery +=" AND   SQS.QS_XSTATUS in ('1','2','3','4','6','8')   AND   ROWNUM = 1  )    OR RH3b.RH3_STATUS IN ('1','4') ) "
		cQuery +=" ) RALL "
		cQuery +=" WHERE RALL.FILIAL = RCL.RCL_FILIAL AND RALL.POSTO = RCL.RCL_POSTO "
	Else
		cQuery +="SELECT COUNT( * ) FROM "
		cQuery +="  (SELECT RH4F.RH4_CAMPO RH4f_DEF, "
		cQuery +="          RH4p.RH4_CAMPO RH4p_DEF, "
		cQuery +="          RH4f.RH4_VALNOV FILIAL, "
		cQuery +="          RH4p.RH4_VALNOV POSTO, "
		cQuery +="          RH3b.RH3_XTPCTM, "
		cQuery +="          RH3b.RH3_FILIAL, "
        cQuery +="          RH3b.RH3_STATUS, "
		cQuery +="          RH3b.RH3_CODIGO "
		cQuery +="   FROM "+RetSqlName("RH3")+" RH3b "
		cQuery +="   LEFT JOIN "+RetSqlName("RH4")+" RH4f ON RH4f.RH4_FILIAL = RH3b.RH3_FILIAL "
		cQuery +="   AND RH4f.RH4_CODIGO = RH3b.RH3_CODIGO "
		cQuery +="   AND RH4f.RH4_CAMPO = RIGHT(CASE RH3b.RH3_XTPCTM  WHEN '002' THEN  'QS_FILPOST' WHEN '006' THEN 'RA_FILIAL' END,10) "
		cQuery +="   LEFT JOIN "+RetSqlName("RH4")+" RH4p ON RH4p.RH4_FILIAL = RH3b.RH3_FILIAL "
		cQuery +="   AND RH4p.RH4_CODIGO = RH3b.RH3_CODIGO "
		cQuery +="   AND RH4p.RH4_CAMPO = RIGHT(CASE RH3b.RH3_XTPCTM  WHEN '002' THEN  'QS_POSTO' WHEN '006' THEN 'RA_POSTO' END,10) "
		cQuery +="   AND RH4p.D_E_L_E_T_ <> '*' "
		cQuery +="   INNER JOIN "+RetSqlName("PAB")+" PAB ON PAB.D_E_L_E_T_ = ' ' "
		cQuery +="   AND RH3_XCODAL = PAB_CODIGO "
		cQuery +="   AND RH3_XTPCTM = PAB_TPSOLI "
		cQuery +="   WHERE RH3b.D_E_L_E_T_ = ' ' "
		cQuery +="   AND RH3b.RH3_XTPCTM IN ('002','004','006') "
		cQuery +="     AND (EXISTS "
		cQuery +="            (SELECT 1 FROM "+RetSqlName("SQS")+" SQS "
		cQuery +="             WHERE SQS.QS_XSOLFIL = RH3b.RH3_FILIAL "
		cQuery +="               AND SQS.QS_XSOLPTL = RH3b.RH3_CODIGO "
		cQuery +="               AND SQS.D_E_L_E_T_ = ' ' "
		cQuery +="               AND SQS.QS_XSTATUS IN ('1','2','3','4','6','8') "
		cQuery +="                ) "
		cQuery +="          OR RH3b.RH3_STATUS IN ('1','4')) ) RALL "
		cQuery +=" WHERE RALL.FILIAL = RCL.RCL_FILIAL AND RALL.POSTO = RCL.RCL_POSTO "	
	EndIf 
	cQuery += "  )	)) AS DISPONIVEL, "
	cQuery += "       RD4.RD4_CHAVE, "
	cQuery += "       RD4.RD4_TREE "
	cQuery += "FROM " + RETSQLNAME('RD4') + " RD4 "
	cQuery += "INNER JOIN " + RETSQLNAME('RCL') + " RCL ON RCL.D_E_L_E_T_ = ' ' "
	cQuery += "AND RCL.RCL_POSTO = RD4.RD4_CODIDE "
	If !(EMPTY(MV_PAR02))
		cQuery += " AND " + MV_PAR02 + " "
	EndIf
	If !(EMPTY(MV_PAR03))
		cQuery += " AND " + MV_PAR03 + " "
	EndIf
	If !(EMPTY(MV_PAR04))
		cQuery += " AND " + MV_PAR04 + " "
	EndIf
	cQuery += "WHERE RD4.D_E_L_E_T_ = ' ' "
	If !(EMPTY(MV_PAR01))
		cQuery += " AND RD4_CODIGO = '" + MV_PAR01 + "' "
	EndIf
	If cGeren != '01' .AND. !(EMPTY(cChave))
		If TcGetDB() == "ORACLE"
			cQuery += "AND    (RD4.RD4_CHAVE LIKE( TRIM('" + cChave + "') || '%')) "
		Else
			cQuery += "AND    (RD4.RD4_CHAVE LIKE( RTRIM('" + cChave + "') + '%')) "
		EndIf
	EndIf
	cQuery += "ORDER BY RD4.RD4_CHAVE "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp)


	If	MV_PAR05 != 1
		oReport:SetMeter((cAliasTmp)->(LastRec()))
		oReport:IncMeter()
		// Para instanciar e configurar o objeto da String
		oTString        := TCString():New() 
		oTString:cPath  := cPath 
		oTString:cArq   := cArq+".csv"	//?cNome + ".xml" 
		oTString:Clear()

		//-Inclui o cabeçalho no arquivo
		cQry := "Gestor Imediato"
		cQry += ";Filial"
		cQry += ";Cod.Depto."
		cQry += ";Descrição do Depto."
		cQry += ";Posto"
		cQry += ";Cargo"
		cQry += ";Descrição do Cargo"
		cQry += ";Qtd.Máxima"
		cQry += ";Qtd.Ocupados"
		cQry += ";Qtd.Reservados"
		cQry += ";Qtd.Disponível"
		cQry += cEOL

		While (cAliasTmp)->(!Eof())
			If oReport:Cancel()
				Exit
			EndIf
			oSection:Init()
			oReport:IncMeter()
			cQry += "'" + U_F1300202((cAliasTmp)->RCL_FILIAL,(cAliasTmp)->RCL_POSTO, cVisao)   + ""
			cQry += ";'" + (cAliasTmp)->RCL_FILIAL             + ""
			cQry += ";'" + (cAliasTmp)->RCL_DEPTO               + ""
			cQry += ";'" + POSICIONE("SQB",1,(cAliasTmp)->RCL_FILIAL + (cAliasTmp)->RCL_DEPTO, "QB_DESCRIC")             + ""
			cQry += ";'" + (cAliasTmp)->RCL_POSTO             + ""
			cQry += ";'" + (cAliasTmp)->RCL_CARGO              + ""
			cQry += ";'" + POSICIONE("SQ3",1,XFILIAL("SQ3") + (cAliasTmp)->RCL_CARGO, "Q3_DESCSUM")             + ""
			cQry += ";'" + cValToChar((cAliasTmp)->RCL_NPOSTO) + ""
			cQry += ";'" + cValToChar((cAliasTmp)->RCL_OPOSTO) + ""
			cQry += ";'" + cValToChar((cAliasTmp)->RESERVADOS) + ""
			cQry += ";'" + cValToChar((cAliasTmp)->DISPONIVEL) + ""
			cQry += cEOL

			//-Carrega a linha no objeto/array
			oTString:SetString(cQry)
			cQry := ""

			(cAliasTmp)->(dbSkip())
		Enddo
		(cAliasTmp)->(DbCloseArea())

		// Para gerar o arquivo no caminho e no nome de arquivo indicado no atributo cPath
		oTString:Str2File() 

		Aviso('Relatório de Postos',"Gerado o arquivo: " + oTString:cArq, {'OK'}, 1)

		//-Chama o Excel e abre o arquivo gerado
		oExcelApp:WorkBooks:Open(oTString:cPath + oTString:cArq)
		oExcelApp:SetVisible(.T.)
		oSection:Finish()
		oReport:SetPreview(.F.)
	Else
		oReport:SetMeter((cAliasTmp)->(LastRec()))
		oReport:IncMeter()
		While (cAliasTmp)->(!Eof())
			If oReport:Cancel()
				Exit
			EndIf
			oSection:Init()
			oReport:IncMeter()
			oSection:Cell("TMP_GESTOR"):SetValue(U_F1300202((cAliasTmp)->RCL_FILIAL,(cAliasTmp)->RCL_POSTO, cVisao))
			oSection:Cell("RCL_FILIAL"):SetValue((cAliasTmp)->RCL_FILIAL)
			oSection:Cell("QB_DEPTO"  ):SetValue((cAliasTmp)->RCL_DEPTO)  
			oSection:Cell("QB_DESCRIC"):SetValue(POSICIONE("SQB",1,(cAliasTmp)->RCL_FILIAL + (cAliasTmp)->RCL_DEPTO, "QB_DESCRIC"))
			oSection:Cell("RCL_POSTO"):SetValue((cAliasTmp)->RCL_POSTO)
			oSection:Cell("RCL_CARGO" ):SetValue((cAliasTmp)->RCL_CARGO) 
			oSection:Cell("Q3_DESCSUM"):SetValue(POSICIONE("SQ3",1,XFILIAL("SQ3") + (cAliasTmp)->RCL_CARGO, "Q3_DESCSUM") )
			oSection:Cell("RCL_NPOSTO"):SetValue(cValToChar((cAliasTmp)->RCL_NPOSTO))
			oSection:Cell("RCL_OPOSTO"):SetValue(cValToChar((cAliasTmp)->RCL_OPOSTO))
			oSection:Cell("TMP_RESERV"):SetValue(cValToChar((cAliasTmp)->RESERVADOS))
			oSection:Cell("TMP_DISPON"):SetValue(cValToChar((cAliasTmp)->DISPONIVEL))
			(cAliasTmp)->(dbSkip())
			oSection:PrintLine()
		Enddo
		(cAliasTmp)->(DbCloseArea())

		oSection:Finish()
		//oReport:Print()
	EndIf
Return

/*/{Protheus.doc} ValidUsr
Validação dos usuarios
@author henrique.toyada
@since 27/09/2017
@version 6
@project MAN0000007423048_EF_003
@param cFilSoli, characters, descricao
@param cMatSoli, characters, descricao
@type function
/*/
Static Function ValidUsr(cFilSoli, cMatSoli)

	Local lRet := .F.

	Default cMatSoli := ""
	Default cFilSoli := ""

	If (PswSeek(__cUserId,.T.))
		aDdSolic := PswRet()

		////cMatSoli := SubString(aDdSolic[1][22], Len(cEmpAnt) + Len(cFilAnt) + 1, 12)
		cMatSoli := SubString(aDdSolic[1][22], (Len(aDdSolic[1,22])-6) + 1, 12)
		cFilSoli := SubString(aDdSolic[1][22], Len(cEmpAnt) + 1, Len(cFilAnt))

		If !Empty(cMatSoli)
			lRet := .T.
		Else
			Help( ,, 'HELP',, 'Não há Vínculo entre o Solicitante e o cadastro de Funcionários.', 1, 0)
			lRet := .F.
		EndIf

	EndIf
Return lRet
