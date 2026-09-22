#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE "REPORT.CH"

/*/{Protheus.doc} F1300101
Geração do relatório Estrututa Hierárquica de Visões
@author henrique.toyada
@since 27/09/2017
@version 6
@project MAN0000007423048_EF_001

@type function
/*/
user function F1300101()

	Local oReport := nil
	Local cPerg:= Padr("FSW1300101",10)

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
@project MAN0000007423048_EF_001
@param cNome, characters, descricao
@type function
/*/
Static Function RptDef(cNome)

	Local cPerg   := Padr("FSW1300101",10)
	Local oReport := Nil
	Local oSection:= Nil
	Local oBreak
	Local oFunction

	oReport := TReport():New(cNome,"Estrututa Hierárquica de Visões",cNome,{|oReport| ReportPrint(oReport)},"Estrututa Hierárquica de Visões")
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)

	Pergunte(cPerg, .F.)

	oSection:= TRSection():New(oReport,	 "RD4", {"RD4"}, , .F., .T.)
	TRCell():New(oSection, "RCL_FILIAL", "RD4", "Filial"                       , "@!", TAMSX3("RCL_FILIAL")[1], .T.)
	TRCell():New(oSection, "TMP_DESFIL", "RD4", "Descricao"                    , "@!", TAMSX3("Q3_DESCSUM")[1], .T.)
	TRCell():New(oSection, "RD4_CODIDE", "RD4", "Posto Superior"	           , "@!", TAMSX3("RD4_CODIDE")[1], .T.)
	TRCell():New(oSection, "Q3_DESCSUM", "RD4", "Descrição do Cargo do Posto"  , "@!", TAMSX3("Q3_DESCSUM")[1], .T.)
	If MV_PAR04 == 1
		TRCell():New(oSection,"RCL_OPOSTO", "RD4", "Qtd.Vagas Ocupadas"        , "@!", TAMSX3("RCL_OPOSTO")[1], .T.)
	EndIf
	TRCell():New(oSection, "RCL_NPOSTO", "RD4", "Qtd.Vagas no Posto"           , "@!", TAMSX3("RCL_NPOSTO")[1], .T.)
	//=================================================================================================================
	oSection1 := TRSection():New(oReport,	 "RD4", {"RD4"}, , .F., .T.)
	TRCell():New(oSection1, "RCL_FILIAL", "RD4", "Filial"                       , "@!", TAMSX3("RCL_FILIAL")[1], .T.)
	TRCell():New(oSection1, "TMP_DESFIL", "RD4", "Descricao"                    , "@!", TAMSX3("Q3_DESCSUM")[1], .T.)
	TRCell():New(oSection1, "RD4_CODIDE", "RD4", "Posto"        	            , "@!", TAMSX3("RD4_CODIDE")[1], .T.)
	TRCell():New(oSection1, "Q3_DESCSUM", "RD4", "Descrição do Cargo do Posto"  , "@!", TAMSX3("Q3_DESCSUM")[1], .T.)
	If MV_PAR04 == 1
		TRCell():New(oSection1,"RCL_OPOSTO", "RD4", "Qtd.Vagas Ocupadas"        , "@!", TAMSX3("RCL_OPOSTO")[1], .T.)
	EndIf
	TRCell():New(oSection1, "RCL_NPOSTO", "RD4", "Qtd.Vagas no Posto"           , "@!", TAMSX3("RCL_NPOSTO")[1], .T.)
	//=================================================================================================================
	oSection2 := TRSection():New(oReport,	 "RD4", {"RD4"}, , .F., .T.)
	TRCell():New(oSection2, "RCL_FILIAL", "RD4", "Filial"                       , "@!", TAMSX3("RCL_FILIAL")[1], .T.)
	TRCell():New(oSection2, "TMP_DESFIL", "RD4", "Descricao"                    , "@!", TAMSX3("Q3_DESCSUM")[1], .T.)
	TRCell():New(oSection2, "RD4_CODIDE", "RD4", "Posto Subordinados"           , "@!", TAMSX3("RD4_CODIDE")[1], .T.)
	TRCell():New(oSection2, "Q3_DESCSUM", "RD4", "Descrição do Cargo do Posto"  , "@!", TAMSX3("Q3_DESCSUM")[1], .T.)
	If MV_PAR04 == 1
		TRCell():New(oSection2,"RCL_OPOSTO", "RD4", "Qtd.Vagas Ocupadas"        , "@!", TAMSX3("RCL_OPOSTO")[1], .T.)
	EndIf
	TRCell():New(oSection2, "RCL_NPOSTO", "RD4", "Qtd.Vagas no Posto"           , "@!", TAMSX3("RCL_NPOSTO")[1], .T.)
	oReport:SetTotalInLine(.F.)

	oSection:SetPageBreak(.T.)
	oSection:SetTotalText(" ")

Return(oReport)

/*/{Protheus.doc} ReportPrint
Montagem dos dados
@author henrique.toyada
@since 27/09/2017
@version 6
@project MAN0000007423048_EF_001
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
	Local cPerg     := Padr("FSW1300101",10)
	Local oExcelApp := FWMsExcelEx():New()
	Local oSection  := oReport:Section(1)
	Local oSection1 := oReport:Section(2)
	Local oSection2 := oReport:Section(3)

	MakeSqlExpr( cPerg )
	
	If EMPTY(MV_PAR01)
		Help( ,, 'HELP',, 'Prencher o código da visão para continuar', 1, 0)
		Return
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

	cQuery := "SELECT RD4.RD4_CODIDE,RD4.RD4_CODIGO,SQ3.Q3_DESCSUM,RCL.RCL_FILIAL,RCL.RCL_OPOSTO, RCL.RCL_NPOSTO, RD4.RD4_CHAVE "
	cQuery += "FROM   " + RETSQLNAME('RD4') + " RD4 "
	cQuery += "INNER JOIN " + RETSQLNAME('RCL') + " RCL "
	cQuery += "ON     RCL.D_E_L_E_T_ = ' ' "
	cQuery += "AND    RCL.RCL_FILIAL = RD4.RD4_FILIDE "
	cQuery += "AND    RCL.RCL_POSTO = RD4.RD4_CODIDE "
	If !(EMPTY(MV_PAR02))
		cQuery += "AND    " + MV_PAR02 + " "
	EndIf
	cQuery += "LEFT JOIN " + RETSQLNAME('SQ3') + " SQ3 "
	cQuery += "ON     SQ3.D_E_L_E_T_ = ' ' "
	cQuery += "AND    SQ3.Q3_CARGO = RCL.RCL_CARGO "
	cQuery += "WHERE  RD4.D_E_L_E_T_ = ' ' "
	If cGeren != '01'
		If TcGetDB() == "ORACLE"
			cQuery += "AND    ((RD4.RD4_CHAVE LIKE( TRIM('" + cChave + "') || '%')) "
			cQuery += "OR     RD4.RD4_CHAVE = SUBSTR(TRIM('" + cChave + "'),1,LENGTH(TRIM('" + cChave + "')) - 3)) "
		Else
			cQuery += "AND    ((RD4.RD4_CHAVE LIKE( RTRIM('" + cChave + "') + '%')) "
			cQuery += "OR     RD4.RD4_CHAVE = SUBSTRING(RTRIM('" + cChave + "'),1,len(RTRIM('" + cChave + "')) - 3)) "
		EndIf
	EndIf
	If !(EMPTY(MV_PAR03))
		cQuery += "       AND " + MV_PAR03 + " "
	EndIf
	If !(EMPTY(MV_PAR01))
		cQuery += "       AND RD4_CODIGO = '" + MV_PAR01 + "' "  
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
		oTString:cArq   := cArq + ".csv"	//?cNome + ".xml" 
		oTString:Clear()

		//-Inclui o cabeçalho no arquivo
		cQry += "Filial;"
		cQry += "Descrição;"
		cQry += "Posto Superior;"
		cQry += "Descrição do Cargo do posto;"
		If MV_PAR04 == 1
			cQry += "Qtd.Vagas Ocupadas;"
		EndIf
		cQry += "Qtd.Vagas no Posto"
		cQry += cEOL

		If nCnt == 0 .AND. (cAliasTmp)->(!Eof()) 

			cQry += "'" + (cAliasTmp)->RCL_FILIAL + ";"
			cQry += "'" + FWFilialName(,(cAliasTmp)->RCL_FILIAL,1) + ";"
			cQry += "'" + (cAliasTmp)->RD4_CODIDE + ";" 
			cQry += "'" + (cAliasTmp)->Q3_DESCSUM + ";"
			If MV_PAR04 == 1
				cQry += "'" + cValToChar((cAliasTmp)->RCL_OPOSTO) + ";"
			EndIf
			cQry += "'" + cValToChar((cAliasTmp)->RCL_NPOSTO) + ";"
			cQry += cEOL
			cQry += cEOL
			(cAliasTmp)->(dbSkip())
			nCnt++
			oTString:SetString(cQry)
			cQry := ""

		EndIf

		If nCnt == 1 .AND. (cAliasTmp)->(!Eof())
			//-Inclui o cabeçalho no arquivo
			cQry += "Filial;"
			cQry += "Descrição;"
			cQry += "Posto;"
			cQry += "Descrição do Cargo do posto;"
			If MV_PAR04 == 1
				cQry += "Qtd.Vagas Ocupadas;"
			EndIf
			cQry += "Qtd.Vagas no Posto"
			cQry += cEOL
			cQry += "'" + (cAliasTmp)->RCL_FILIAL + ";"
			cQry += "'" + FWFilialName(,(cAliasTmp)->RCL_FILIAL,1) + ";"
			cQry += "'" + (cAliasTmp)->RD4_CODIDE + ";" 
			cQry += "'" + (cAliasTmp)->Q3_DESCSUM + ";"
			If MV_PAR04 == 1
				cQry += "'" + cValToChar((cAliasTmp)->RCL_OPOSTO) + ";"
			EndIf
			cQry += "'" + cValToChar((cAliasTmp)->RCL_NPOSTO) + ";"
			cQry += cEOL
			cQry += cEOL
			(cAliasTmp)->(dbSkip())
			nCnt++
			oTString:SetString(cQry)
			cQry := ""

		EndIf
		//-Inclui o cabeçalho no arquivo
		cQry += "Filial;"
		cQry += "Descrição;"
		cQry += "Posto Subordinados;"
		cQry += "Descrição do Cargo do posto;"
		If MV_PAR04 == 1
			cQry += "Qtd.Vagas Ocupadas;"
		EndIf
		cQry += "Qtd.Vagas no Posto"
		cQry += cEOL

		While (cAliasTmp)->(!Eof())
			If oReport:Cancel()
				Exit
			EndIf
			oSection:Init()
			oReport:IncMeter()
			If nCnt > 1 
				cQry += "'" + (cAliasTmp)->RCL_FILIAL + ";"
				cQry += "'" + FWFilialName(,(cAliasTmp)->RCL_FILIAL,1) + ";"
				cQry += "'" + (cAliasTmp)->RD4_CODIDE + ";" 
				cQry += "'" + (cAliasTmp)->Q3_DESCSUM + ";"
				If MV_PAR04 == 1
					cQry += "'" + cValToChar((cAliasTmp)->RCL_OPOSTO) + ";"
				EndIf
				cQry += "'" + cValToChar((cAliasTmp)->RCL_NPOSTO) + ";"
				cQry += cEOL
			EndIf
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
			oSection1:Init()
			oSection2:Init()
			oReport:IncMeter()
			If nCnt == 0 
				oSection:Cell("RD4_CODIDE"):SetValue((cAliasTmp)->RD4_CODIDE)				
				oSection:Cell("Q3_DESCSUM"):SetValue((cAliasTmp)->Q3_DESCSUM)
				oSection:Cell("RCL_FILIAL"):SetValue((cAliasTmp)->RCL_FILIAL)
				oSection:Cell("TMP_DESFIL"):SetValue(FWFilialName(,(cAliasTmp)->RCL_FILIAL,1))
				If MV_PAR04 == 1
					oSection:Cell("RCL_OPOSTO"):SetValue(cValToChar((cAliasTmp)->RCL_OPOSTO))
				EndIf
				oSection:Cell("RCL_NPOSTO"):SetValue(cValToChar((cAliasTmp)->RCL_NPOSTO))
				oSection:PrintLine()
			EndIf
			//=======================================================================================
			If nCnt == 1
				oSection1:Cell("RD4_CODIDE"):SetValue((cAliasTmp)->RD4_CODIDE)				
				oSection1:Cell("Q3_DESCSUM"):SetValue((cAliasTmp)->Q3_DESCSUM)
				oSection1:Cell("RCL_FILIAL"):SetValue((cAliasTmp)->RCL_FILIAL)
				oSection1:Cell("TMP_DESFIL"):SetValue(FWFilialName(,(cAliasTmp)->RCL_FILIAL,1))
				If MV_PAR04 == 1
					oSection1:Cell("RCL_OPOSTO"):SetValue(cValToChar((cAliasTmp)->RCL_OPOSTO))
				EndIf
				oSection1:Cell("RCL_NPOSTO"):SetValue(cValToChar((cAliasTmp)->RCL_NPOSTO))
				oSection1:PrintLine()
			EndIf
			//=======================================================================================
			If nCnt > 1
				oSection2:Cell("RD4_CODIDE"):SetValue((cAliasTmp)->RD4_CODIDE)				
				oSection2:Cell("Q3_DESCSUM"):SetValue((cAliasTmp)->Q3_DESCSUM)
				oSection2:Cell("RCL_FILIAL"):SetValue((cAliasTmp)->RCL_FILIAL)
				oSection2:Cell("TMP_DESFIL"):SetValue(FWFilialName(,(cAliasTmp)->RCL_FILIAL,1))
				If MV_PAR04 == 1
					oSection2:Cell("RCL_OPOSTO"):SetValue(cValToChar((cAliasTmp)->RCL_OPOSTO))
				EndIf
				oSection2:Cell("RCL_NPOSTO"):SetValue(cValToChar((cAliasTmp)->RCL_NPOSTO))
				oSection2:PrintLine()
			EndIf
			(cAliasTmp)->(dbSkip())

			nCnt++
		Enddo
		(cAliasTmp)->(DbCloseArea())

		oSection:Finish()
		oSection1:Finish()
		oSection2:Finish()
		//oReport:Print()
	EndIf
Return

/*/{Protheus.doc} ValidUsr
Validação dos usuarios
@author henrique.toyada
@since 27/09/2017
@version 6
@project MAN0000007423048_EF_001
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
