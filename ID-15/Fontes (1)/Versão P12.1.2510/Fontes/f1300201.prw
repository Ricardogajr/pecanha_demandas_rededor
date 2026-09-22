#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "REPORT.CH"

/*/{Protheus.doc} F1300201
Geração do relatório Relatório de Headcount Analitico
@author henrique.toyada
@since 27/09/2017
@version 6
@project MAN0000007423048_EF_002
@type function
/*/
user function F1300201()
	Local oReport := nil
	Local cPerg:= Padr("FSW1300201",10)

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
@project MAN0000007423048_EF_002
@param cNome, characters, descricao
@type function
/*/
Static Function RptDef(cNome)

	Local cPerg:= Padr("FSW1300201",10)
	Local oReport := Nil
	Local oSection:= Nil
	Local oBreak
	Local oFunction

	oReport := TReport():New(cNome,"Relatório de Headcount Analitico",cNome,{|oReport| ReportPrint(oReport)},"Relatório de Headcount Analitico")
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)

	oSection:= TRSection():New(oReport,	 "RD4", {"RD4"}, , .F., .T.,,,,,.T.)
	TRCell():New(oSection, "TMP_GESTOR", "RD4", "Gestor Imediato"                 , "@!", TAMSX3("RA_NOME")[1]   , .T.,,,.T.)
	TRCell():New(oSection, "RCL_FILIAL", "RD4", "Filial do Posto"                 , "@!", TAMSX3("RCL_FILIAL")[1], .T.,,,.T.)
	TRCell():New(oSection, "RD4_CODIDE", "RD4", "Posto"                           , "@!", TAMSX3("RD4_CODIDE")[1], .T.,,,.T.)
	TRCell():New(oSection, "QB_DEPTO"  , "RD4", "Cod.Depto."                      , "@!", TAMSX3("QB_DEPTO")[1]  , .T.,,,.T.)
	TRCell():New(oSection, "QB_DESCRIC", "RD4", "Descrição do Depto."             , "@!", TAMSX3("QB_DESCRIC")[1], .T.,,,.T.)
	TRCell():New(oSection, "RCL_CARGO" , "RD4", "Cargo"                           , "@!", TAMSX3("RCL_CARGO")[1] , .T.,,,.T.)
	TRCell():New(oSection, "Q3_DESCSUM", "RD4", "Descrição do Cargo"              , "@!", TAMSX3("Q3_DESCSUM")[1], .T.,,,.T.)
	TRCell():New(oSection, "RA_FILIAL" , "RD4", "Filial Ocupante"                 , "@!", TAMSX3("RA_FILIAL")[1] , .T.,,,.T.)
	TRCell():New(oSection, "RA_MAT"    , "RD4", "Matrícula Ocupante / Cod.Solic"  , "@!", TAMSX3("RA_MAT")[1]    , .T.,,,.T.)
	TRCell():New(oSection, "RA_NOME"   , "RD4", "Nome Ocupante"                   , "@!", TAMSX3("RA_NOME")[1]   , .T.,,,.T.)
	TRCell():New(oSection, "RA_SALARIO" , "RD4", "Salário Ocupante"               , "@!", 10                     , .T.,,,.T.)
	TRCell():New(oSection, "RA_SITFOLH", "RD4", "Situação do Ocupante do Posto"   , "@!", TAMSX3("RA_SITFOLH")[1], .T.,,,.T.)
	TRCell():New(oSection, "TMP_TITULA", "RD4", "Titular"                         , "@!", 10                     , .T.,,,.T.)

	oReport:SetTotalInLine(.F.)

	//oSection:SetPageBreak(.T.)
	oSection:SetTotalText(" ")

Return(oReport)


/*/{Protheus.doc} ReportPrint
Montagem dos dados
@author henrique.toyada
@since 27/09/2017
@version 6
@project MAN0000007423048_EF_002
@param oReport, object, descricao
@type function
/*/
Static Function ReportPrint(oReport)
	Local lRet      := .T.
	Local cPath     := GetTempPath()
	Local cArq      := "FS" + DToS(dDataBase) + StrTran(time(),':','')
	Local cQry      := ""
	Local cEOL      := CHR(13) + CHR(10)
	Local nCnt      := 1
	Local nLoop     := 1
	Local aDados    := {}
	Local oExcelApp := FWMsExcelEx():New()
	Local oSection  := oReport:Section(1)
	
	If EMPTY(MV_PAR01)
		Help( ,, 'HELP',, 'Prencher o código da visão para continuar', 1, 0)
		Return
	EndIf
	
	aDados := RetDados()

	If	MV_PAR07 != 1
		oReport:SetMeter(Len(aDados))
		oReport:IncMeter()
		// Para instanciar e configurar o objeto da String
		oTString        := TCString():New()
		oTString:cPath  := cPath
		oTString:cArq   := cArq+".csv"	//?cNome + ".xml"
		oTString:Clear()

		//-Inclui o cabeçalho no arquivo
		cQry := "Gestor Imediato;"
		cQry += "Filial do Posto;"
		cQry += "Posto;"
		cQry += "Cod.Depto.;"
		cQry += "Descrição do Depto.;"
		cQry += "Cargo;"
		cQry += "Descrição do Cargo;"
		cQry += "Filial Ocupante;"
		cQry += "Matrícula Ocupante / Cod.Solic;"
		cQry += "Nome Ocupante;"
		cQry += "Salário Ocupante;"
		cQry += "Situação do Ocupante do Posto; "
		cQry += "Titular;"
		cQry += cEOL

		For nCnt:= 1 to Len(aDados)
			If oReport:Cancel()
				Exit
			EndIf
			oSection:Init()
			oReport:IncMeter()
			If MV_PAR06 != 1
				lRet := MV_PAR06 = 2 .AND. aDados[nCnt][13] != "SUBSTITUTO"
			EndIf
			If  lRet
				cQry += ""  + aDados[nCnt][1]  + ";"
				cQry += "'" + aDados[nCnt][2]  + ";"
				cQry += "'" + aDados[nCnt][3]  + ";"
				cQry += "'" + aDados[nCnt][4]  + ";"
				cQry += ""  + aDados[nCnt][5]  + ";"
				cQry += "'" + aDados[nCnt][6]  + ";"
				cQry += ""  + aDados[nCnt][7]  + ";"
				cQry += "'" + aDados[nCnt][8]  + ";"
				cQry += "'" + aDados[nCnt][9]  + ";"
				cQry += ""  + aDados[nCnt][10] + ";"
				cQry += ""  + aDados[nCnt][11] + ";"
				cQry += ""  + aDados[nCnt][12] + ";"
				cQry += ""  + aDados[nCnt][13] + ";"
				cQry += cEOL
				oTString:SetString(cQry)
			EndIf
			cQry := ""
		Next

		oTString:Str2File()
		Aviso('Relatório de Postos',"Gerado o arquivo: " + oTString:cArq, {'OK'}, 1)
		oExcelApp:WorkBooks:Open(oTString:cPath + oTString:cArq)
		oExcelApp:SetVisible(.T.)
		oSection:Finish()
		oReport:SetPreview(.F.)
	Else
		oReport:SetMeter(Len(aDados))
		oReport:IncMeter()
		For nCnt:= 1 to Len(aDados)
			If oReport:Cancel()
				Exit
			EndIf
			If MV_PAR06 != 1
				lRet := MV_PAR06 = 2 .AND. aDados[nCnt][13] != "SUBSTITUTO"
			EndIf
			If  lRet
				oSection:Init()
				oReport:IncMeter()
				oSection:Cell("TMP_GESTOR"):SetValue(aDados[nCnt][1])
				oSection:Cell("RCL_FILIAL"):SetValue(aDados[nCnt][2])
				oSection:Cell("RD4_CODIDE"):SetValue(aDados[nCnt][3])
				oSection:Cell("QB_DEPTO"  ):SetValue(aDados[nCnt][4])
				oSection:Cell("QB_DESCRIC"):SetValue(aDados[nCnt][5])
				oSection:Cell("RCL_CARGO" ):SetValue(aDados[nCnt][6])
				oSection:Cell("Q3_DESCSUM"):SetValue(aDados[nCnt][7])
				oSection:Cell("RA_FILIAL" ):SetValue(aDados[nCnt][8])
				oSection:Cell("RA_MAT"    ):SetValue(aDados[nCnt][9])
				oSection:Cell("RA_NOME"   ):SetValue(aDados[nCnt][10])
				oSection:Cell("RA_SALARIO"):SetValue(aDados[nCnt][11])
				oSection:Cell("RA_SITFOLH"):SetValue(aDados[nCnt][12])
				oSection:Cell("TMP_TITULA"):SetValue(aDados[nCnt][13])
				oSection:PrintLine()
			EndIf
		Next

		oSection:Finish()
	EndIf
Return

/*/{Protheus.doc} ValidUsr
Validação dos usuarios
@author henrique.toyada
@since 27/09/2017
@version 6
@project MAN0000007423048_EF_002
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

		///cMatSoli := SubString(aDdSolic[1][22], Len(cEmpAnt) + Len(cFilAnt) + 1, 12)
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

/*/{Protheus.doc} RetDados
Monta informações
@author henrique.toyada
@since 07/11/2017
@version 6
@project MAN0000007423048_EF_002
@type function
/*/
Static Function RetDados()

	Local cSituac   := ""
	Local cAliasTmp := "TMP"
	Local cQuery    := ""
	Local cGeren    := ""
	Local cChave    := ""
	Local cVisao    := ""
	Local nCnt      := 1
	Local nLoop     := 1
	Local nValor    := 1
	Local nAux      := 1
	Local nAux1     := 1
	Local nSolicit  := 1
	Local aDados    := {}
	Local aAux      := {}
	Local aSolicit  := {}
	Local cPerg     := Padr("FSW1300201",10)
	Local lContador := .T.

	MakeSqlExpr( cPerg )
	
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

	cQuery := "SELECT RCL.RCL_FILIAL,RCL.RCL_POSTO,RCX.RCX_FILFUN, "
	cQuery += "RCX.RCX_MATFUN,RCX.RCX_SUBST, RCL.RCL_DEPTO,  "
	cQuery += "RCL.RCL_CARGO, RCL.RCL_FUNCAO, RCL.RCL_CC,  "
	cQuery += "RD4.RD4_CODIGO, RCL.RCL_NPOSTO, RCL.RCL_OPOSTO "
	cQuery += "FROM " + RETSQLNAME('RD4') + " RD4  "
	cQuery += "INNER JOIN " + RETSQLNAME('RCL') + " RCL  "
	cQuery += "ON RCL.D_E_L_E_T_ = ' '  "
	cQuery += "AND RCL.RCL_POSTO =  RD4.RD4_CODIDE  "
	cQuery += "AND RCL.RCL_FILIAL = RD4.RD4_FILIDE  "
	If !(EMPTY(MV_PAR02)) // Filial
		cQuery += " AND " + MV_PAR02 + " "
	EndIf
	If !(EMPTY(MV_PAR03)) // Posto
		cQuery += " AND " + MV_PAR03 + " "
	EndIf
	If !(EMPTY(MV_PAR05)) // Departamento
		cQuery += " AND " + MV_PAR05 + " "
	EndIf
	cQuery += "LEFT JOIN " + RETSQLNAME('RCX') + " RCX  "
	cQuery += "ON RCX.D_E_L_E_T_ = ' '  "
	cQuery += "AND RCX.RCX_POSTO =  RCL.RCL_POSTO "
	cQuery += "AND RCX.RCX_FILIAL = RCL.RCL_FILIAL  "
	If !(EMPTY(MV_PAR04)) // Matricula
		cQuery += " AND " + MV_PAR04 + " "
	EndIf
	cQuery += "WHERE RD4.D_E_L_E_T_ = ' '  "
	If !(EMPTY(MV_PAR01))
		cQuery += "AND RD4.RD4_CODIGO = '" + MV_PAR01 + "' "
	EndIf
	If cGeren != '01' .AND. !(EMPTY(cChave))
		If TcGetDB() == "ORACLE"
			cQuery += "   	AND    RD4.RD4_CHAVE LIKE( TRIM('" + cChave + "') || '%')  "
		Else
			cQuery += "   	AND    RD4.RD4_CHAVE LIKE( RTRIM('" + cChave + "') + '%') "
		EndIf
	EndIf
	cQuery += "ORDER BY RCL.RCL_FILIAL, RCL.RCL_POSTO, RD4.RD4_CHAVE "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp)

	While (cAliasTmp)->(!Eof())
		AADD(aDados,{;
			U_F1300202((cAliasTmp)->RCL_FILIAL, (cAliasTmp)->RCL_POSTO, cVisao),;                           //"Gestor Imediato"
		(cAliasTmp)->RCL_FILIAL,;                                                                       //"Filial do Posto"
		(cAliasTmp)->RCL_POSTO,;                                                                        //"Posto"
		(cAliasTmp)->RCL_DEPTO,;                                                                        //"Cod.Depto."
		POSICIONE("SQB",1,(cAliasTmp)->RCL_FILIAL + (cAliasTmp)->RCL_DEPTO, "QB_DESCRIC"),;             //"Descrição do Depto."
		(cAliasTmp)->RCL_CARGO,;                                                                        //"Cargo"
		POSICIONE("SQ3",1,XFILIAL("SQ3") + (cAliasTmp)->RCL_CARGO, "Q3_DESCSUM"),;                      //"Descrição do Cargo"
		IIF(!(EMPTY((cAliasTmp)->RCX_FILFUN )),(cAliasTmp)->RCX_FILFUN, "VAZIO"),;                      //"Filial Ocupante"
		IIF(!(EMPTY((cAliasTmp)->RCX_MATFUN )),(cAliasTmp)->RCX_MATFUN, "VAZIO"),;                      //"Matrícula Ocupante / Cod.Solic"
		IIF(!(EMPTY((cAliasTmp)->RCX_MATFUN )) .AND. !(EMPTY((cAliasTmp)->RCX_FILFUN )), POSICIONE("SRA",1,(cAliasTmp)->RCX_FILFUN + (cAliasTmp)->RCX_MATFUN, "RA_NOME"), "VAZIO"),; //"Nome Ocupante"
		IIF(!(EMPTY((cAliasTmp)->RCX_MATFUN )) .AND. !(EMPTY((cAliasTmp)->RCX_FILFUN )), IIF((cAliasTmp)->RCX_SUBST == '2',cValToChar(POSICIONE("SRA",1,(cAliasTmp)->RCX_FILFUN + (cAliasTmp)->RCX_MATFUN, "RA_SALARIO")),""), "VAZIO"),; // "Salário Ocupante"
		SitFolha((cAliasTmp)->RCX_FILFUN, (cAliasTmp)->RCX_MATFUN),; //"Situação do Ocupante do Posto"
		IIF(!(EMPTY((cAliasTmp)->RCX_MATFUN )) .AND. !(EMPTY((cAliasTmp)->RCX_FILFUN )), IIF((cAliasTmp)->RCX_SUBST == '2',"TITULAR","SUBSTITUTO"), "VAZIO"),; //"Titular"
		cValToChar((cAliasTmp)->RCL_NPOSTO),;
			cValToChar((cAliasTmp)->RCL_OPOSTO);
			})

		(cAliasTmp)->(dbSkip())
	End
	(cAliasTmp)->(DbCloseArea())

	While nCnt <= Len(aDados)

		nValor := IIF(nCnt < LEN(aDados), nCnt + 1, LEN(aDados))

		If nLoop <= VAL(aDados[nCnt][14])
			nAux := nCnt
			While nAux1 <= VAL(aDados[nAux][15])
				AADD(aAux,{aDados[nCnt][1],aDados[nCnt][2],aDados[nCnt][3],aDados[nCnt][4],aDados[nCnt][5],aDados[nCnt][6],aDados[nCnt][7],;
					aDados[nCnt][8],aDados[nCnt][9],aDados[nCnt][10],aDados[nCnt][11],aDados[nCnt][12],aDados[nCnt][13]})
				lContador := .F.
				nCnt++
				nAux1++
			End
			nLoop := nAux1
			aSolicit := ValidRh3(aDados[nAux][2],aDados[nAux][3])
			For nSolicit := 1 To Len(aSolicit)
				AADD(aAux,{aDados[nAux][1],aDados[nAux][2],aDados[nAux][3],aDados[nAux][4],aDados[nAux][5],aDados[nAux][6],aDados[nAux][7],aSolicit[nSolicit][1],aSolicit[nSolicit][2],aSolicit[nSolicit][3],aSolicit[nSolicit][5],aSolicit[nSolicit][4],"VAZIO"})
				nLoop++
			Next nSolicit
					
			While nLoop <= VAL(aDados[nAux][14])
				AADD(aAux,{aDados[nAux][1],aDados[nAux][2],aDados[nAux][3],aDados[nAux][4],aDados[nAux][5],aDados[nAux][6],aDados[nAux][7],"VAZIO","VAZIO","VAZIO","VAZIO","VAZIO","VAZIO"})
				nLoop++
			End
			If lContador
				nCnt++
			EndIf
		EndIf
		nAux1 := 1
		nLoop := 1
		lContador := .T.
	End

	aDados := aClone(aAux)

Return aDados

/*/{Protheus.doc} SitFolha
Retorna a descrição da situação do participante
@author henrique.toyada
@since 07/11/2017
@version 6
@project MAN0000007423048_EF_002
@param cFilFun, characters, descricao
@param cMatFun, characters, descricao
@type function
/*/
Static Function SitFolha(cFilFun, cMatFun)
	Local cSitfol   := ""
	Local cSituacao := ""

	Default cFilFun := ""
	Default cMatFun := ""
	If !(EMPTY(cFilFun)) .AND. !(EMPTY(cMatFun))
		cSitfol := POSICIONE("SRA",1,cFilFun + cMatFun, "RA_SITFOLH")
		Do Case
		Case EMPTY(ALLTRIM(cSitfol))
			cSituacao := "Situação Normal"
		Case ALLTRIM(cSitfol) == "A"
			cSituacao := "Afastado Temp."
		Case ALLTRIM(cSitfol) == "D"
			cSituacao := "Demitido"
		Case ALLTRIM(cSitfol) == "F"
			cSituacao := "Férias"
		Case ALLTRIM(cSitfol) == "T"
			cSituacao := "Trasferido"
		EndCase
	Else
		cSituacao := "VAZIO"
	EndIf

Return cSituacao

Static Function ValidRh3(cFilPosto,cPosto)

	Local aSolicit := {}
	Local cAlias1   := GetNextAlias()
	Local cGRPSOL   := SuperGetMv("FS_GRPSOL",,"002001/006003/006005/006006/006007/006008/006010/")
	Local cQuery    := ""
	Local nQ        := 0
	Local nTotal    := 0
	Local lNOracle  := TCGetDB() == 'ORACLE'
	
	Default cFilPosto := ""
	Default cPosto    := ""
	
	
	If lNOracle
		cQuery := "SELECT * FROM "
		cQuery +="(SELECT "
		cQuery +=" RH4F.RH4_CAMPO RH4f_DEF, RH4p.RH4_CAMPO RH4p_DEF, RH4m.RH4_CAMPO RH4m_DEF, RPAD(RH4f.RH4_VALNOV,8,' ') FILIAL, RPAD(RH4p.RH4_VALNOV,9,' ') POSTO, RPAD(RH4m.RH4_VALNOV,8,' ') SALARIO,RH3b.RH3_XTPCTM, "
		cQuery +=" RH3b.RH3_FILIAL, RH3b.RH3_STATUS, RH3b.RH3_CODIGO "
		cQuery +=" FROM "+RetSqlName("RH3")+" RH3b "
		cQuery +=" left JOIN "+RetSqlName("RH4")+" RH4f ON RH4f.RH4_FILIAL = RH3b.RH3_FILIAL "
		cQuery +=" AND RH4f.RH4_CODIGO = RH3b.RH3_CODIGO "
		cQuery +=" AND RH4f.RH4_CAMPO = RPAD(DECODE( RH3b.RH3_XTPCTM, '002', 'QS_FILPOST','006','RA_FILIAL'),10,' ') "
		cQuery +=" left JOIN "+RetSqlName("RH4")+" RH4p ON RH4p.RH4_FILIAL = RH3b.RH3_FILIAL "
		cQuery +=" AND RH4p.RH4_CODIGO = RH3b.RH3_CODIGO "
		cQuery +=" AND RH4p.RH4_CAMPO = RPAD(DECODE( RH3b.RH3_XTPCTM, '002', 'QS_POSTO','006','RA_POSTO'),10, ' ') "
		cQuery +=" AND RH4p.D_E_L_E_T_ = ' ' "
		cQuery +=" left JOIN "+RetSqlName("RH4")+" RH4m ON RH4m.RH4_FILIAL = RH3b.RH3_FILIAL "
		cQuery +=" AND RH4m.RH4_CODIGO = RH3b.RH3_CODIGO "
		cQuery +=" AND RH4m.RH4_CAMPO = RPAD(DECODE( RH3b.RH3_XTPCTM, '002', 'QS_VCUSTO','006','RA_SALARIO'),10, ' ') "
		cQuery +=" AND RH4m.D_E_L_E_T_ = ' ' "
		cQuery +=" INNER JOIN  "+RetSqlName("PAB")+" PAB ON PAB.D_E_L_E_T_ = ' ' "
		cQuery +=" AND RH3_XCODAL = PAB_CODIGO AND RH3_XTPCTM = PAB_TPSOLI "
		cQuery +=" WHERE RH3b.D_E_L_E_T_ = ' ' "
		cQuery +="   AND RH3b.RH3_XTPCTM IN ('002','004','006') "
		cQuery +="   AND RH3b.RH3_STATUS IN ('1','4') "
		cQuery +=" AND ( EXISTS  (SELECT 1 FROM "+RetSqlName("SQS")+" SQS   WHERE SQS.QS_XSOLFIL = RH3b.RH3_FILIAL "
		cQuery +=" AND   SQS.QS_XSOLPTL = RH3b.RH3_CODIGO   AND   SQS.D_E_L_E_T_ = ' ' "
		cQuery +=" AND   SQS.QS_XSTATUS in ('1','2','3','4','6','8')   AND   ROWNUM = 1  )    OR RH3b.RH3_STATUS IN ('1','4') ) "
		cQuery +=" ) RALL "
		cQuery +=" WHERE RALL.FILIAL = '" + cFilPosto + "' AND RALL.POSTO = '" + cPosto + "' "
	Else
		cQuery +="SELECT * FROM "
		cQuery +="  (SELECT RH4F.RH4_CAMPO RH4f_DEF, "
		cQuery +="          RH4p.RH4_CAMPO RH4p_DEF, "
		cQuery +="          RH4m.RH4_CAMPO RH4m_DEF, "
		cQuery +="          RH4f.RH4_VALNOV FILIAL, "
		cQuery +="          RH4p.RH4_VALNOV POSTO, "
		cQuery +="          RH4m.RH4_VALNOV SALARIO, "
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
		cQuery +="   AND RH4p.D_E_L_E_T_ = ' ' "
		cQuery +="   LEFT JOIN RH4990 RH4m ON RH4m.RH4_FILIAL = RH3b.RH3_FILIAL "
		cQuery +="   AND RH4m.RH4_CODIGO = RH3b.RH3_CODIGO "
		cQuery +="   AND RH4m.RH4_CAMPO = RIGHT(CASE RH3b.RH3_XTPCTM WHEN '002' THEN 'QS_VCUSTO' WHEN '006' THEN 'RA_SALARIO' END,10) "
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
		cQuery +=" WHERE RALL.FILIAL = '" + cFilPosto + "' AND RALL.POSTO = '" + cPosto + "' "
	EndIf
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAlias1, .T., .T.)
	
	While (cAlias1)->(!Eof())
		AADD(aSolicit,{;
			(cAlias1)->RH3_FILIAL,;
			(cAlias1)->RH3_CODIGO,;
			IIF(VAL((cAlias1)->RH3_STATUS)==1,"Em processo de aprovação",IIF(VAL((cAlias1)->RH3_STATUS)==2,"Atendida",IIF(VAL((cAlias1)->RH3_STATUS)==3,"Reprovada","Aguardando Efetivação do RH"))),;
			FDESC("PA7",(cAlias1)->RH3_XTPCTM,"PA7_DESCR"),;
			(cAlias1)->SALARIO;
			})
		(cAlias1)->(DbSkip())
	End
	
	(cAlias1)->(DbCloseArea())
	
Return aSolicit
