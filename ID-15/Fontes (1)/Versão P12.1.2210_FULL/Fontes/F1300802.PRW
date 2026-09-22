#INCLUDE "protheus.ch"
#INCLUDE "report.ch"

/*/{Protheus.doc} F1300802
Relatório de Sindicato
@author queizy.nascimento
@since 19/10/2017
@version 1.0
@return ${return}, ${return_description}
@project MAN0000007423048_EF_008
@type function
/*/
User Function F1300802()

	Local oReport

	Pergunte('FSW1300801',.T.)
	oReport := reportDef()
	oReport:printDialog()

Return

/*/{Protheus.doc} reportDef
ReportDef
@author queizy.nascimento
@since 19/10/2017
@version 1.0
@project MAN0000007423048_EF_008
@type function
/*/
Static Function reportDef()

	Local oReport := Nil
	Local oSection:= Nil
	Local cTitulo := 'Relatório de Sindicato'
	Local lRet := .T.

	oReport := TReport():New('F1300802', cTitulo, , {|oReport| PrintReport(oReport)},"Este relatorio ira imprimir os Sindicatos.")


	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()

	oSection := TRSection():New(oReport,"Filial",{"SRA"},,.F.,.T.)
	oSection:SetTotalInLine(.F.)

	TRCell():New(oSection, "RA_FILIAL"		, "SRA", 'Filial'			,"@!" ,TamSX3("RA_FILIAL")[1], .T.,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "RA_CC"			, "SRA", 'CC'				,"@!" ,TamSX3("RA_CC")[1], .T.,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "RA_DESCCC"		, "SRA", 'Desc CC'			,"@!" ,TamSX3("RA_DESCCC")[1], .T.,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "RA_MAT"			, "SRA", 'Matricula'		,"@!" ,TamSX3("RA_MAT")[1], .T.,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "RA_NOME"		, "SRA", 'Nome'				,"@!" ,TamSX3("RA_NOME")[1], .T.,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "RA_CODFUNC"		, "SRA", 'Função'			,"@!" ,TamSX3("RA_CODFUNC")[1], .T.,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "RA_DESCFUN"		, "QRY", 'Desc Funçao'		,"@!" ,TamSX3("RA_DESCFUN")[1], .T.,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "RA_SINDICA"		, "SRA", 'Sindicato'		,"@!" ,TamSX3("RA_SINDICA")[1], .T.,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "RCE_DESCRI"		, "RCE", 'Desc Sindicato'	,"@!" ,TamSX3("RCE_DESCRI")[1], .T.,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "Situacao"		, "QRY", 'Situaçao'			,"@!" ,100,.T.)

	oReport:SetTotalInLine(.F.)

	oSection:SetPageBreak(.T.)
	oSection:SetTotalText(" ")

return (oReport)

/*/{Protheus.doc} PrintReport
PrintReport
@author queizy.nascimento
@since 19/10/2017
@version 1.0
@param oReport, object, descricao
@project MAN0000007423048_EF_008
@type function
/*/
Static Function PrintReport(oReport)

	Local oSection := oReport:Section(1)
	Local cQuery    := ""
	Local lPrim 	:= .T.
	Local lRet:= .F.
	Local cRegional := GETMV("MV_ESTADO")
	Local lRet := .T.
	Local cAliasTmp := "TMP"
	Local cRetorno :=""
	Local cPerg :="FSW1300801"
	Local cQry1	:= ""  		
	Local cQry2	:= ""		
	Local cSit1	:= MV_PAR06 
	Local cSit2 := MV_PAR07	
	Local nRegX	:= 0       	     

	For nRegX:=1 to Len(cSit1)
		cQry1 += "'"+Subs(cSit1,nRegX,1)+"'"
		If ( nRegX+1 ) <= Len(cSit1)
			cQry1 += "," 
		Endif
	Next nRegX     
	
	For nRegX:=1 to Len(cSit2)
		cQry2 += "'"+Subs(cSit2,nRegX,1)+"'"
		If ( nRegX+1 ) <= Len(cSit2)
			cQry2 += "," 
		Endif
	Next nRegX     

	If oReport:nDevice == 1 .OR.  oReport:nDevice == 6
		MsgInfo("Não é possível imprimir o relatório em PDF ")
		oReport:CancelPrint()
		Return( Nil )
	EndIf

	MakeSqlExpr( cPerg )

	cQuery += "SELECT RA_FILIAL,RA_CC,RA_MAT,RA_NOME,RA_CODFUNC,RA_SINDICA,RA_CATFUNC,RA_SITFOLH,RA_ESTADO " + CRLF
	cQuery += "FROM " + RETSQLNAME('SRA') + " SRA " + CRLF
	cQuery += "WHERE SRA.D_E_L_E_T_ ='' " + CRLF
	If !EMPTY(MV_PAR01)
		cQuery += "AND " + MV_PAR01 + "" + CRLF
	EndIf

	If !EMPTY(MV_PAR02)
		cQuery += "AND " + MV_PAR02 + " " + CRLF
	EndIf

	If !EMPTY(MV_PAR03)
		cQuery += "AND " + MV_PAR03 + " " + CRLF
	EndIf

	If !EMPTY(MV_PAR04)
		cQuery += "AND " + MV_PAR04 + " " + CRLF
	EndIf

	If !EMPTY(MV_PAR05)
		cQuery += "AND " + MV_PAR05 + " " + CRLF
	EndIf

	If !EMPTY(cQry1)
		cQuery += "AND RA_CATFUNC IN(" + cQry1 + ")" + CRLF
	EndIf

	If !EMPTY(cQry2)
		cQuery += "AND RA_SITFOLH IN(" + cQry2 + ")" + CRLF
	EndIf

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp)

	oReport:SetMeter((cAliasTmp)->(LastRec()))
	oReport:IncMeter()

	While (cAliasTmp)->(!Eof())

		If oReport:Cancel()
			Exit
		EndIf

		cRetorno:=ValidCad()

		If !Empty (cRetorno)

			oSection:Init()
			oReport:IncMeter()
			oSection:Cell("RA_FILIAL"):SetValue((cAliasTmp)->RA_FILIAL)
			oSection:Cell("RA_CC"):SetValue((cAliasTmp)->RA_CC)
			oSection:Cell("RA_DESCCC"):SetValue(Posicione("CTT",1,xFilial("CTT") +(cAliasTmp)->RA_CC,"CTT_DESC01"))
			oSection:Cell("RA_MAT"):SetValue((cAliasTmp)->RA_MAT)
			oSection:Cell("RA_NOME"):SetValue((cAliasTmp)->RA_NOME)
			oSection:Cell("RA_CODFUNC"):SetValue((cAliasTmp)->RA_CODFUNC)
			oSection:Cell("RA_DESCFUN"):SetValue(Posicione("SRJ",1,xFilial("SRJ") +(cAliasTmp)->RA_CODFUNC,"RJ_DESC"))
			oSection:Cell("RA_SINDICA"):SetValue((cAliasTmp)->RA_SINDICA)
			oSection:Cell("RCE_DESCRI"):SetValue(Posicione("RCE",1,xFilial("RCE") +(cAliasTmp)->RA_SINDICA,"RCE_DESCRI"))
			oSection:Cell("Situacao"):SetValue(cRetorno)

			oSection:Printline()

		EndIf
		(cAliasTmp)->(dbSkip())

	EndDo

	(cAliasTmp)->(DbCloseArea())

	oReport:ThinLine()
	oSection:Finish()
Return

/*/{Protheus.doc} ValidCad
//TODO Descrição auto-gerada.
@author queizy.nascimento
@since 26/10/2017
@version 1.0
@return ${return}, ${return_description}
@project MAN0000007423048_EF_008
@type function
/*/
Static Function ValidCad()

	Local cAliasTmp := "TMP"
	Local cRetorno  :=""
	Local cEstado   :=""
	Local cCodMun   :=""	
	Local cSindU014	:= ""

	cEstado   := Posicione("SM0",1,cEmpant+(cAliasTmp)->RA_FILIAL,"M0_ESTCOB")
	cCodMun   := SubStr(Posicione("SM0",1,cEmpant+(cAliasTmp)->RA_FILIAL,"M0_CODMUN"),3,5)
	
	If !VALRCC("U014", cEstado, 0, 2,.F.)
		cRetorno:="O Estado "+cEstado+" não está cadastrado na tabela Função x Regional x Sindicato."
	ElseIf !ValRCC("U014", cEstado + cCodMun, 0, 7,.F.)
		cRetorno:="Estado "+cEstado+" e Município "+cCodMun+" não constam na tabela de relacionamento de Função x Regional x Sindicato"
	ElseIf !ValFunc(cEstado, cCodMun, (cAliasTmp)->RA_SINDICA, (cAliasTmp)->RA_CODFUNC, @cSindU014)
		cRetorno:="Função " + (cAliasTmp)->RA_CODFUNC + " não consta da tabela de relacionamento de Função x Regional x Sindicato"
	ElseIf AllTrim(cSindU014) != AllTrim((cAliasTmp)->RA_SINDICA)
		cRetorno:="O sindicato do funcionário está incorreto. Sindicato cadastrado: " + AllTrim((cAliasTmp)->RA_SINDICA) + " - Sindicato correto " + AllTrim(cSindU014) + "."
	EndIf

Return cRetorno

/*/{Protheus.doc} ValTab
Valida a Chave Regional+ Municipio+Sindicato+Funcao
@author queizy.nascimento
@since 08/12/2017
@version undefined
@project MAN0000007423048_EF_008
@type function
/*/
User Function ValTab(cSindicato)
	Local cMsg	:= ""
	Local lRet	:= .T.
	
	If aScan(aCols, {|x| x[3] == aCols[n][3] }) > 0 .And. aScan(aCols, {|x| x[3] == aCols[n][3] }) != n 
		If aScan(aCols, {|x| x[3]+x[4] == aCols[n][3] + aCols[n][4]}) > 0 .And. aScan(aCols, {|x| x[3]+x[4] == aCols[n][3] + aCols[n][4]}) != n
			If aScan(aCols, {|x| x[3]+x[4]+x[5] == aCols[n][3] + aCols[n][4] + cSindicato}) > 0 .And. aScan(aCols, {|x| x[3]+x[4]+x[5] == aCols[n][3] + aCols[n][4] + cSindicato}) != n
				cMsg := 'Já existe um registro para o estado '+aCols[n][3]+', município '+aCols[n][4]+' e sindicato '+aCols[n][5]+'.'
				lRet	:= .F.
			EndIf
		EndIf
	EndIf

	If !lRet
		Alert(cMsg)
	EndIf

Return lRet 
/*/{Protheus.doc} ValRCC
Verifica codigo no Cadastro de Tabelas
@author queizy.nascimento
@since 26/10/2017
@version 1.0
@return ${return}, ${return_description}
@param cCodigo, characters, descricao
@param cConteudo, characters, descricao
@param nPos1, numeric, descricao
@param nPos2, numeric, descricao
@param lMsg, logical, descricao
@project MAN0000007423048_EF_008
@type function
/*/
Static Function ValRCC(cCodigo,cConteudo,nPos1,nPos2,lMsg)

	Local lRet := .F.
	Default lMsg := .T.

	If nPos1 = Nil
		nPos1 := 0
	EndIf
	If nPos2 = Nil
		nPos2 := 0
	EndIf

	If cCodigo <> Nil .AND. cConteudo <> Nil

		dbSelectArea( "RCC" )
		RCC->(dbSetOrder(1))
		RCC->(dbSeek(xFilial("RCC")+ cCodigo))

		While !Eof() .AND. RCC->RCC_FILIAL+RCC_CODIGO == xFilial("RCC")+cCodigo
			If RCC->RCC_FILIAL+RCC_CODIGO == xFilial("RCC")+cCodigo .AND. ;
			Alltrim(cConteudo) $ Alltrim(Substr(RCC->RCC_CONTEU,nPos1,nPos2))
				lRet := .T.
				Exit
			EndIf
			RCC->(dBSkip())
		EndDo
		If !lRet .And. lMsg
			Help(" ",1, "NOTAB")
		EndIf
	EndIf

Return(lRet)

//-----------------------------------------------------------------------
/*/{Protheus.doc} ValFunc
Valida o código da função na tabela U014 da RCC
 
@author Nairan Alves Silva
@since  27/12/2017
@return Nil  

@project MAN0000007423048_EF_008
@cliente Rededor
@version P12.1.7
             
/*/
//-----------------------------------------------------------------------
Static Function ValFunc(cEstado, cCodMun, cSind, cFuncao, cSindU014)

	Local cQuery	:= ""
	Local cNewAlias	:= GetNextAlias()
	Local lRet		:= .T.
	
	cQuery := " SELECT RCC_CONTEU "
	cQuery += " FROM " + RetSqlName("RCC") + " "
	cQuery += " WHERE RCC_CODIGO = 'U014' "
	cQuery += " AND RCC_CONTEU LIKE '%" + cEstado + cCodMun + "%' "
	cQuery += " AND RCC_CONTEU LIKE '%" + AllTrim(cFuncao) + "%' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T., "TOPCONN", TCGenQry( ,,cQuery ), cNewAlias, .F., .T.)
			
	If (cNewAlias)->(EOF())
		lRet := .F.
	Else
		cSindU014 := SubStr((cNewAlias)->RCC_CONTEU,8,2)
	EndIf
	
	(cNewAlias)->(DbCloseArea())

Return lRet