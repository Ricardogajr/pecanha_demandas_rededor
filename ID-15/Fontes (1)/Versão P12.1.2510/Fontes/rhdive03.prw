#INCLUDE 'TOTVS.CH'
#INCLUDE 'PARMTYPE.CH'
/*/{Protheus.doc} RHDIVER
	Relatório em Excel.
	@type function
	@version 1.0
	@author Cleiton Genuino  da Silva
	@since 30/11/2023
/*/
User Function RHDIVER()
	Local aNomes    := {}                as array
	Local aTabela   := SRA->(DbStruct()) as array
	Local cCampos   := 'RA_FILIAL|RA_MAT|RA_NOMECMP|RA_CIC|RA_EMAIL|RA_NUMCELU|RA_RACACOR|RA_DEFIFIS|RA_XGENERO|RA_XUSASOC|RA_XNAMESO|RA_XCODRAC|RA_DEPTO|RA_CC|RA_ADMISSA|RA_DEMISSA|RA_CODFUNC'                as character
	Local cPerg     := ""                as character
	Local cTitulo   := ""                as character
	Local nX        := 0                 as numeric
	Local nY        := 0                 as numeric
	Private SRAStruct := {}                as array

	aNomes  := StrTokArr2(cCampos, "|")

	For nY:=1 to len(aNomes)
		For nX := 1 to len(aTabela)
			If Alltrim(aTabela[nX][1]) == aNomes[nY]
				AADD(SRAStruct,{aTabela[nX][1],aTabela[nX][2],aTabela[nX][3],aTabela[nX][4]} )
			EndIf
		Next

	Next

	cPerg   := PADR("RHDIVE03", 10)
	cTitulo := "Relatório de diversidade admitidos e demitidos"

	If !Pergunte(cPerg,.T.)
		Return( )
	Endif

	Processa({|| fExec() }, "Atenção", "Aguarde...", .T.)

Return
/*/{Protheus.doc} fExec
Executa rotina para impressão do relatório
@type function
@version P12 
@author Ricardo
@since 5/8/2024
@return variant, nulo
/*/
Static function fExec()
	Local nX        := 0
	Local aArea     := GetArea( )        as array
	Local aStrAlias := {}                as array
	Local aStruct   := {}                as array
	Local cAlias    := GetNextAlias()    as character
	Local cQuery    := ""                as character
	Local oExcel    := FWMsExcelEx():New()

	cQuery += " SELECT"+CRLF
	cQuery += " 	'"+cEmpAnt+"' EMPRESA,"+CRLF
	cQuery += "          RA_FILIAL,"+CRLF
	cQuery += "          RA_MAT,"+CRLF
	cQuery += "          RA_NOMECMP,"+CRLF
	cQuery += "          RA_CIC,"+CRLF
	cQuery += "          RA_EMAIL,"+CRLF
	cQuery += "          RA_NUMCELU,"+CRLF
	//cQuery += "          RA_RACACOR,"+CRLF
	cQuery += "          CASE WHEN RA_RACACOR = '1' THEN '1-INDIGENA'"+CRLF
	cQuery += "			 WHEN RA_RACACOR = '2' THEN '2-BRANCA'"+CRLF
	cQuery += "			 WHEN RA_RACACOR = '4' THEN '3-PRETA'"+CRLF
	cQuery += "			 WHEN RA_RACACOR = '6' THEN '6-AMARELA'"+CRLF
	cQuery += "			 WHEN RA_RACACOR = '8' THEN '8-PARDA'"+CRLF
	cQuery += "			 WHEN RA_RACACOR = '9' THEN '9-NAO INFORMADO'"+CRLF
	cQuery += "			 WHEN RA_RACACOR = 'x' THEN 'x-ANONIMIZADO'"+CRLF
	cQuery += "          END AS RA_RACACOR,"+CRLF
	//cQuery += "          RA_DEFIFIS,"+CRLF
	cQuery += "          CASE WHEN RA_DEFIFIS = '1' THEN '1-SIM'"+CRLF
	cQuery += "			 WHEN RA_DEFIFIS = '2' THEN '2-NAO'"+CRLF
	cQuery += "			 WHEN RA_DEFIFIS = 'x' THEN 'X-ANONIMIZADO'"+CRLF
	cQuery += "			 WHEN RA_DEFIFIS = ' ' THEN 'VAZIO'"+CRLF
	cQuery += "          END AS RA_DEFIFIS,"+CRLF
	cQuery += "          RA_XGENERO,"+CRLF
	cQuery += "          RA_XUSASOC,"+CRLF
	cQuery += "          RA_XNAMESO,"+CRLF
	cQuery += "          RA_XCODRAC,"+CRLF
	cQuery += "          RA_DEPTO,"+CRLF
	cQuery += "          RA_CC,"+CRLF
	cQuery += "          RA_CODFUNC,"+CRLF
	cQuery += "          RA_ADMISSA,"+CRLF
	cQuery += "          RA_DEMISSA "+CRLF
	cQuery += " FROM " + RetSqlName("SRA") + " SRA " +CRLF
	cQuery += " WHERE"+CRLF
	cQuery += " 	RA_FILIAL  BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND"+CRLF
	cQuery += " 	RA_MAT     BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND"+CRLF
	If MV_PAR07 == 2 // Sim relaciona apenas ativos diferente de demitido
		cQuery += " 	RA_ADMISSA BETWEEN '"+DtoS(MV_PAR05)+"' AND '"+DtoS(MV_PAR06)+"' AND"+CRLF
		cQuery += " 	RA_SITFOLH <> 'D' AND"+CRLF //
	ElseIf MV_PAR07 == 1 // Não relaciona apenas inativos
		cQuery += " 	RA_ADMISSA BETWEEN '"+DtoS(MV_PAR05)+"' AND '"+DtoS(MV_PAR06)+"' AND"+CRLF
		cQuery += " 	RA_SITFOLH = 'D'  AND"+CRLF
	ElseIf MV_PAR07 == 3 // Ambos relaciona todos ativos e nativos
		cQuery += " 	RA_ADMISSA BETWEEN '"+DtoS(MV_PAR05)+"' AND '"+DtoS(MV_PAR06)+"' AND"+CRLF
	EndIf
	cQuery += " 	SRA.D_E_L_E_T_ = ' ' "

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), cAlias,.F.,.T.)

	if (cAlias)->(Eof())
		Alert("Nenhum dado foi encontrado.")
		Return
	endif

	For nX := 01 To Len(SRAStruct)
		aAdd(aStruct, SRAStruct[nX][1])
		aAdd(aStrAlias, "(cAlias)->"+SRAStruct[nX][1])
	Next nX

	oExcel:AddworkSheet("RHDIVER")
	oExcel:AddTable("RHDIVER","Lista")

	For nX := 01 To Len(aStruct)
		if GetSX3Cache(aStruct[nX], "X3_TIPO") == "N"
			nTipo := 2
		elseif GetSX3Cache(aStruct[nX], "X3_TIPO") == "D"
			nTipo := 4
		else
			nTipo := 1
		endif

		oExcel:AddColumn("RHDIVER","Lista",GetSX3Cache(aStruct[nX], "X3_TITULO"),2, nTipo)

		If aStruct[nX] ==  'RA_FILIAL'
			oExcel:AddColumn("RHDIVER","Lista","NomeFilial",2, 1) //Nome da Filial
		EndIf

		If aStruct[nX] ==  'RA_CODFUNC'
			oExcel:AddColumn("RHDIVER","Lista",GetSX3Cache('RJ_DESC', "X3_TITULO"),2, 1) // Desc da função
		EndIf

		If aStruct[nX] ==  'RA_CC'
			oExcel:AddColumn("RHDIVER","Lista",GetSX3Cache('RA_DESCCC', "X3_TITULO"),2, 1) // Desc do centro de custo
		EndIf

		If aStruct[nX] ==  'RA_DEPTO'
			oExcel:AddColumn("RHDIVER","Lista",GetSX3Cache('RA_DDEPTO', "X3_TITULO"),2, 1) // Desc departamento
		EndIf

		If aStruct[nX] ==  'RA_XGENERO'
			oExcel:AddColumn("RHDIVER","Lista",GetSX3Cache('RA_XDESCGE', "X3_TITULO"),2, 1) // Desc genero
		EndIf

		If aStruct[nX] ==  'RA_XCODRAC'
			oExcel:AddColumn("RHDIVER","Lista",GetSX3Cache('RA_XDESCRA', "X3_TITULO"),2, 1) // Desc raça
		EndIf

	Next nX

	oExcel:SetCelBold(.T.)
	oExcel:SetCelFont('Arial')
	oExcel:SetCelItalic(.T.)
	oExcel:SetCelUnderLine(.T.)
	oExcel:SetCelSizeFont(10)

	nCount := 0
	Count to nCount
	(cAlias)->(DbGoTop())
	ProcRegua(nCount)

	//Lista itens
	While !(cAlias)->(Eof())
		IncProc("Processando registros...")
		Sleep(100)
		ProcessMessages()
		aStr := {}
		For nX := 01 To Len(aStrAlias)
			cRet := ""
			cCampo := SubStr(aStrAlias[nX],11,100)
			aAdd(aStr, &(aStrAlias[nX]))

			If cCampo ==  'RA_FILIAL'
				aAdd(aStr, FWFilialName(cEmpAnt,(cAlias)->RA_FILIAL))
			EndIf

			If cCampo ==  'RA_CODFUNC'
				aAdd(aStr, FDESC('SRJ',(cAlias)->RA_CODFUNC,'RJ_DESC',TamSX3('RJ_DESC'),(cAlias)->RA_FILIAL) )
			EndIf

			If cCampo ==  'RA_CC'
				aAdd(aStr, FDESC("CTT",(cAlias)->RA_CC,"CTT_DESC01",,(cAlias)->RA_FILIAL) )
			EndIf

			If cCampo ==  'RA_DEPTO'
				aAdd(aStr, FDESC('SQB',(cAlias)->RA_DEPTO,'QB_DESCRIC') )
			EndIf

			If cCampo ==  'RA_XGENERO'
				aAdd(aStr, FDESC('SX5',"ZG"+(cAlias)->RA_XGENERO,'X5_DESCRI',,(cAlias)->RA_FILIAL))
			EndIf

			If cCampo ==  'RA_XCODRAC'
				aAdd(aStr, FDESC('SX5',"ZH"+(cAlias)->RA_XCODRAC,'X5_DESCRI',,(cAlias)->RA_FILIAL))
			EndIf

		Next nX
		oExcel:AddRow("RHDIVER","Lista",aStr)
		(cAlias)->(DbSkip())
	EndDo

	oExcel:Activate()
	cFile := GetTempPath()+"RHDIVER"+FWTimeStamp(4)+".xml"
	oExcel:GetXMLFile(cFile)

	ShellExecute("open", "excel.exe", cFile, "", 3)

	RestArea(aArea)
Return
