#include 'protheus.ch'
#include 'parmtype.ch'
#include 'totvs.ch'

/*/{Protheus.doc} REDA002
Programa para o Menu da tela de Gerar Cotação, é utilizado para 
gerar as cotações (WASE - Método de Solicitação de Compras) do que 
ainda não foram integradas com o Bionexo no botão Integrar Bionexo 
no Menu de Ações Relacionadas.
@type function
@author Ricardo da Silva
@since 16/06/2017 
@version 1.0
@return Solicitações de Compras
/*/
User Function REDA002(cXIdProc)

	Default cXIdProc := ""
	Processa( {|| fProcessa(cXIdProc) }, "Aguarde...", "Integrando Solicitações de compras...", .F.)

Return

Static Function fProcessa(cXIdProc)

	Local oWs			:= Nil
	Local oNewStrSolic	:= Nil
	Local aArea			:= GetArea()
	Local aZRecNo		:= {}
	Local nX			:= 0
	Local nI			:= 0
	Local cUser			:= ""
	Local cSenha 		:= ""
	Local _cZNumero		:= ""
	Local _cZNumSC		:= ""
	Local cQuery		:= ""
	Local cAliasSC1 	:= GetNextAlias()//"TMPSC1"
	Local lRetSC	   	:= .F.
	Local _cZFilial		:= xFilial("SY1")
	Local _cZUser 		:= RetCodUsr()
	Local aAux			:= {}
	Local cComprador	:= ""
	Local aTemp			:= {}
	Local cProduto      := ""
	Local cTabSC1   	:= RetSqlName("SC1")
	Local aAuxValid		:= {}
	Local lRet			:= .F.
	Local cNumCotacao 	:= GetSxENum("SC8","C8_NUM")
	Local lErroTam		:= .F.
	Local cMark			:= ""
	Local aScAux		:= {}
	Local nY			:= 00
	Local nPosProd		:= 00
	Local lLock			:= .T.
	Local cUpdate := ""
	Local lCpoVazio := .F.
	Local cSolics := ""
	Local cKeys := ""

	cQuerySC1 := iIf(Type("cQuerySC1")=="U","",cQuerySC1)

	cFuncName := "getChaveSCEmp" + cEmpAnt

	cQuery := " CREATE OR REPLACE FUNCTION " + cFuncName + "("
	cQuery += "  c1Filial  IN "+ cTabSC1 +".C1_FILIAL%type," 	+ CRLF
	cQuery += "  c1Produto IN "+ cTabSC1 +".C1_PRODUTO%type," 	+ CRLF
	cQuery += "  c1Local   IN "+ cTabSC1 +".C1_LOCAL%type," 	+ CRLF
	cQuery += "  c1CC 	   IN "+ cTabSC1 +".C1_CC%type, "  		+ CRLF
	cQuery += "  c1Xidproc IN "+ cTabSC1 +".C1_XIDPROC%type )" 	+ CRLF
	cQuery += "  RETURN VARCHAR " 	+ CRLF
	cQuery += "  IS " 	+ CRLF
	cQuery += "  cChaves varchar(1000) := '';" 	+ CRLF
	cQuery += "  cItem    "+ cTabSC1 +".C1_ITEM%type;" 		+ CRLF
	cQuery += "  cFilAux  "+ cTabSC1 +".C1_FILIAL%type;" 	+ CRLF
	cQuery += "  cNum  	  "+ cTabSC1 +".C1_NUM%type;" 		+ CRLF
	cQuery += "  cProduto "+ cTabSC1 +".C1_PRODUTO%type;" 	+ CRLF
	cQuery += "  CURSOR c1 " 	+ CRLF
	cQuery += "    IS " 	+ CRLF
	cQuery += "    SELECT C1_FILIAL, C1_NUM, C1_PRODUTO, C1_ITEM FROM " + cTabSC1 + " SC1TRB " + CRLF
	If Alltrim(cXIdProc) == "SC1"
		cQuery += "   	WHERE "+ cQuerySC1 + CRLF
		cQuery += " 	AND SC1TRB.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "   	AND C1_FILIAL 	= c1Filial " + CRLF
		cQuery += "   	AND C1_PRODUTO 	= c1Produto " + CRLF
		cQuery += "   	AND C1_LOCAL 	= c1Local " + CRLF
		cQuery += "   	AND C1_CC 		= c1CC " + CRLF
		cQuery += " 	AND C1_OK 		= '" + cMarca + "'" 	+ CRLF
		cQuery += " 	AND C1_USRCODE  = '"+RetCodUsr()+"'" 	+ CRLF
		cQuery += " 	AND C1_FILIAL   = '"+xFilial("SC1")+"'" 	+ CRLF
	Else
		cQuery += " 	WHERE SC1TRB.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "     AND C1_XIDPROC  = c1Xidproc " + CRLF
	Endif
	cQuery += "   GROUP BY C1_FILIAL, C1_NUM, C1_PRODUTO, C1_ITEM; " + CRLF
	cQuery += " BEGIN" 	+ CRLF
	cQuery += "     OPEN c1;" 	+ CRLF
	cQuery += "     LOOP" 	+ CRLF
	cQuery += "        FETCH c1 INTO cFilAux, cNum, cProduto, cItem; " 	+ CRLF
	cQuery += "        EXIT WHEN c1%notfound;" 	+ CRLF
	cQuery += "          cChaves := cChaves  || RTRIM(cFilAux) || RTRIM(cNum) || RTRIM(cItem) || ';'  ; " 	+ CRLF
	cQuery += "     END LOOP;" 	+ CRLF
	cQuery += "     CLOSE c1;" 	+ CRLF
	cQuery += "  RETURN(cChaves); " 	+ CRLF
	cQuery += "  END; " 	+ CRLF

	If TcSqlExec(cQuery) < 0
		MsgInfo("Erro na criação da view (" + cFuncName + ") !","Atenção")
		Return
	EndIf

	cQuery := ""

	cQuery := "  SELECT " + CRLF
	cQuery += " 	C1_FILIAL " + CRLF
	cQuery += " 	,C1_PRODUTO " + CRLF
	cQuery += " 	,C1_SEGUM " + CRLF
	cQuery += " 	,SUM(C1_QTSEGUM) C1_QTSEGUM" + CRLF
	cQuery += " 	,SUM(C1_QUANT) 	 C1_QUANT" + CRLF
	cQuery += " 	,C1_OK " + CRLF
	cQuery += " 	,C1_CONDPAG " + CRLF
	cQuery += " 	,C1_MOEDA " + CRLF
	cQuery += " 	,C1_TPSC " + CRLF
	cQuery += " 	,C1_XTPSC " + CRLF
	cQuery += " 	,C1_XIDBIO " + CRLF
	cQuery += " 	,C1_CC " + CRLF
	cQuery += " 	,C1_LOCAL " + CRLF
	cQuery += " 	,C1_XIDPROC " + CRLF
	cQuery += " 	,getChaveSCEmp"+ cEmpAnt + "(C1_FILIAL, C1_PRODUTO, C1_LOCAL, C1_CC, C1_XIDPROC )CHAVE " + CRLF
	cQuery += " 	FROM "+ cTabSC1 +" SC1 " 	+ CRLF
	If Alltrim(cXIdProc) == "SC1"
		cQuery += " 	WHERE "+ cQuerySC1 + " " 			+ CRLF
		cQuery += " 	AND SC1.D_E_L_E_T_ = ' '" 			+ CRLF
		cQuery += " 	AND SC1.C1_OK = '" + cMarca + "'" 	+ CRLF
		cQuery += " 	AND SC1.C1_USRCODE = '"+RetCodUsr()+"'" 	+ CRLF
		cQuery += " 	AND SC1.C1_FILIAL = '" + xFilial("SC1") + "' " 	+ CRLF
	Else
		cQuery += " 	WHERE SC1.D_E_L_E_T_ = ' '" 			+ CRLF
		cQuery += "     AND SC1.C1_XIDPROC = '" + cXIdProc + "'"
	Endif
	cQuery += " 	GROUP BY C1_FILIAL, C1_PRODUTO, C1_LOCAL, C1_CC,C1_SEGUM,C1_OK,C1_CONDPAG,C1_MOEDA,C1_TPSC,C1_XTPSC,C1_XIDBIO, C1_CC, C1_LOCAL, C1_XIDPROC" 	+ CRLF


	DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasSC1, .F., .T.)

	If (cAliasSC1)->(Eof())
		If !IsBlind()
			Alert("Não foram encontrados dados para a consulta")
		Else
			conout("Não foram encontrados dados para a consulta")
		EndIf
		Return
	EndIf

	Count To nReg
	(cAliasSC1)->(DbGoTop())
	ProcRegua(nReg)
	cIdProc := AllTrim(FWUUIDV4())
	aAdd(aAux,{ {"PARAMETROS", 	"LAYOUT=WA"},;
		{"FILIAL", 		cFilAnt},;
		{"LOGIN", 		"teste1"},;
		{"PASSWORD", 	"teste1"},;
		{"XIDPROC",		cIdProc}})

	While !(cAliasSC1)->(Eof()) //.And. (cAliasSC1)->C1_FILIAL == xFilial("SC1")
		cKeys += AllTrim((cAliasSC1)->CHAVE)
		aChave := StrTokArr(AllTrim((cAliasSC1)->CHAVE), ";")
		If Len(aChave) > 39
			Aviso("Atenção", "Não é possivel enviar o produto " + (cAliasSC1)->C1_PRODUTO + " - " + Posicione("SB1", 01, xFilial("SB1")+(cAliasSC1)->C1_PRODUTO,"B1_DESC") + ". Só poderão ser enviados 39 itens deste produto.", {"Sair"})
			lErroTam := .T.
			Exit
		EndIf
		aQtdConsum := U_FConvUmBio(AllTrim((cAliasSC1)->C1_PRODUTO), (cAliasSC1)->C1_QUANT, 0, "B")
		aAdd(aAux, {{"C1FILIAL", 	(cAliasSC1)->C1_FILIAL},;
			{"C1NUM", 		cNumCotacao},;//(cAliasSC1)->C1_NUM},;
			{"C1ITEM", 		AllTrim((cAliasSC1)->CHAVE)},;//(cAliasSC1)->C1_FILIAL + (cAliasSC1)->C1_NUM + (cAliasSC1)->C1_ITEM},;
			{"XCONDPAG", 	GETSPARAM("MV_XCONDBI",,"1")},;
			{"XDTCOTA", 	DToC(Date() + GETSPARAM("MV_XDTBIO",,1))},;
			{"XHRCOTA", 	GETSPARAM("MV_XHRBIO",,"00:00")},;
			{"C1PRODUTO", 	AllTrim((cAliasSC1)->C1_PRODUTO) },;
			{"C1OBS", 		" "},;
			{"C1QTSEGUM", 	cValToChar(aQtdConsum[01]) },;
			{"TITPDC", 		"PDC PROTHEUS " + cNumCotacao },;
			{"C1XTPSC",  	(cAliasSC1)->C1_XTPSC },;
			{"C1MOEDA",		cValToChar((cAliasSC1)->C1_MOEDA)},;
			{"LOCAL",		cValToChar((cAliasSC1)->C1_LOCAL)},;
			{"CC",		cValToChar((cAliasSC1)->C1_CC)};
			})
		aAdd(aAuxValid ,{ 	(cAliasSC1)->C1_FILIAL,;
			(cAliasSC1)->C1_PRODUTO,;
			(cAliasSC1)->C1_LOCAL,;
			(cAliasSC1)->C1_CC})
		(cAliasSC1)->(DbSkip())
	EndDo

	If lErroTam
		Return
	EndIf

	aScAux := aSort(aAuxValid,,, {|x,y| x[1]+x[2]+x[3]+x[4] < y[1]+y[2]+y[3]+y[4]})

	For nY := 01 To Len(aScAux)
		If Len(aTemp) > 0
			nPosProd := aScan(aTemp,{|x| Alltrim(x[2]) == AllTrim(aScAux[nY][2])})
			If nPosProd > 0
				If aTemp[nPosProd][3] != AllTrim(aScAux[nY][3]) .OR. aTemp[nPosProd][4] != AllTrim(aScAux[nY][4])
					//REGRA DE QUEBRA DE SOLICITAÇÃO REDE DOR
					Alert("Foram Selecionados produtos iguais com Armazém e Centro de custo diferentes, por favor, desmarque e integre novamente.")
					lRet := .T.
					Exit
				EndIf
				//fImporta(aTemp)
			Else
				aAdd(aTemp, aScAux[nY])
			EndIf
		Else
			aAdd(aTemp, aScAux[nY])
		EndIf
	Next nY

	If lRet
		Return
	Else
		//(cAliasSC1)->(DbGoTop())
		//While !(cAliasSC1)->(Eof())

		DbSelectArea("SC1")
		SC1->(DbSetOrder(01))
		aSolic 		:= StrTokArr(AllTrim(cKeys), ";")
		cComprador 	:= Posicione("SY1", 03, xFilial("SC1") + _cZUser, "Y1_COD")
		For nX := 01 To Len (aSolic)
			If SC1->(DbSeek(aSolic[nX]))
				/*/	SoftLock("SC1")
				RecLock("SC1", .F.)
				SC1->C1_XENVBIO := "1" //1=Aguardando Integr. Bionexo, 2=Integrado Bionexo, 3=Aguardando Desvinculo Bionexo, 4=Erro de Integração Bionexo
				SC1->C1_XCPBIO  := cComprador
				SC1->C1_XIDPROC := cIdProc
					SC1->( MsUnLock() )/*/
				cUpdate := "UPDATE " + RetSqlName("SC1") + " SET C1_XENVBIO = '1', C1_XCPBIO = '"+cComprador+"', C1_XIDPROC = '"+cIdProc+"'"
				cUpdate += " WHERE R_E_C_N_O_ = " + cValToChar(SC1->(RECNO()))

				If TCSQLExec(cUpdate) < 0
					SoftLock("SC1")
					RecLock("SC1", .F.)
					SC1->C1_XENVBIO := "1" //1=Aguardando Integr. Bionexo, 2=Integrado Bionexo, 3=Aguardando Desvinculo Bionexo, 4=Erro de Integração Bionexo
					SC1->C1_XCPBIO  := cComprador
					SC1->C1_XIDPROC := cIdProc
					SC1->( MsUnLock() )
				Else
					SC1->(dbCommit())
				EndIf
			EndIf
		Next nX
		(cAliasSC1)->(DbSkip())
		//EndDo
		//(cAliasSC1)->(DbGoTop())
		//While !(cAliasSC1)->(Eof())
		DbSelectArea("SC1")
		SC1->(DbSetOrder(01))
		aSolic 		:= StrTokArr(AllTrim(cKeys), ";")
		//aSolic 		:= StrTokArr(AllTrim((cAliasSC1)->CHAVE), ";")
		For nX := 01 To Len (aSolic)
			If SC1->(DbSeek(aSolic[nX]))
				If Empty(SC1->C1_XENVBIO) .Or. Empty(SC1->C1_XIDPROC)
					lCpoVazio := .T.
					cSolics += aSolic[nX] + CRLF
				EndIf
			EndIf
		Next nX
		//(cAliasSC1)->(DbSkip())
		//EndDo

		If !lCpoVazio
			aXml := U_REDWSDL2("WASE", aAux)
			ConfirmSX8()
			//Chama Método de Solicitação de Compras
			If Type("aXml") == "A"
				If Len(aXml) > 0
					If aXml[1] != "1"
						//(cAliasSC1)->(DbGoTop())
						//While !(cAliasSC1)->(Eof())
						DbSelectArea("SC1")
						SC1->(DbSetOrder(01))
						//	aSolic 		:= StrTokArr(AllTrim((cAliasSC1)->CHAVE), ";")
						aSolic 		:= StrTokArr(AllTrim(cKeys), ";")
						For nX := 01 To Len (aSolic)
							If SC1->(DbSeek(aSolic[nX]))
								cUpdate := "UPDATE " + RetSqlName("SC1") + " SET C1_XENVBIO = ' ', C1_XCPBIO = ' ', C1_XIDPROC = ' ' "
								cUpdate += " WHERE R_E_C_N_O_ = " + cValToChar(SC1->(RECNO()))

								If TCSQLExec(cUpdate) < 0
									SoftLock("SC1")
									RecLock("SC1", .F.)
									SC1->C1_XENVBIO := " " //1=Aguardando Integr. Bionexo, 2=Integrado Bionexo, 3=Aguardando Desvinculo Bionexo, 4=Erro de Integração Bionexo
									SC1->C1_XCPBIO  := " "
									SC1->C1_XIDPROC := " "
									SC1->( MsUnLock() )
								Else
									SC1->(dbCommit())
								EndIf
							EndIf
						Next nX
						//(cAliasSC1)->(DbSkip())
						//EndDo
					Else
						//(cAliasSC1)->(DbGoTop())
						//While !(cAliasSC1)->(Eof())
							DbSelectArea("SC1")
							SC1->(DbSetOrder(01))
							aSolic 		:= StrTokArr(AllTrim(cKeys), ";")
							//aSolic 		:= StrTokArr(AllTrim((cAliasSC1)->CHAVE), ";")
							cComprador 	:= Posicione("SY1", 03, xFilial("SC1") + _cZUser, "Y1_COD")
							For nX := 01 To Len (aSolic)
								If SC1->(DbSeek(aSolic[nX]))
				/*/	SoftLock("SC1")
									RecLock("SC1", .F.)
									SC1->C1_XENVBIO := "1" //1=Aguardando Integr. Bionexo, 2=Integrado Bionexo, 3=Aguardando Desvinculo Bionexo, 4=Erro de Integração Bionexo
									SC1->C1_XCPBIO  := cComprador
									SC1->C1_XIDPROC := cIdProc
					SC1->( MsUnLock() )/*/
									cUpdate := "UPDATE " + RetSqlName("SC1") + " SET C1_XENVBIO = '1', C1_XCPBIO = '"+cComprador+"', C1_XIDPROC = '"+cIdProc+"'"
									cUpdate += " WHERE R_E_C_N_O_ = " + cValToChar(SC1->(RECNO()))

									If TCSQLExec(cUpdate) < 0
										SoftLock("SC1")
										RecLock("SC1", .F.)
										SC1->C1_XENVBIO := "1" //1=Aguardando Integr. Bionexo, 2=Integrado Bionexo, 3=Aguardando Desvinculo Bionexo, 4=Erro de Integração Bionexo
										SC1->C1_XCPBIO  := cComprador
										SC1->C1_XIDPROC := cIdProc
										SC1->( MsUnLock() )
									Else
										SC1->(dbCommit())
									EndIf
								EndIf
							Next nX
							//(cAliasSC1)->(DbSkip())
						//EndDo
					EndIf
				EndIf
			EndIf

			If Type("aXml") == "A"
				If Len(aXml) > 0
					If aXml[1] == "1"
						Aviso("Mensagem de integração", "Foi integrada a requisição " + cNumCotacao, {"Ok"})
					ElseIf aXml[1] == "-1"
						Alert(aXml[2])
					EndIf
				EndIf
			EndIf
		Else
			//(cAliasSC1)->(DbGoTop())
			//While !(cAliasSC1)->(Eof())
				DbSelectArea("SC1")
				SC1->(DbSetOrder(01))
				//aSolic 		:= StrTokArr(AllTrim((cAliasSC1)->CHAVE), ";")
				aSolic 		:= StrTokArr(AllTrim(cKeys), ";")
				For nX := 01 To Len (aSolic)
					If SC1->(DbSeek(aSolic[nX]))
						cUpdate := "UPDATE " + RetSqlName("SC1") + " SET C1_XENVBIO = ' ', C1_XCPBIO = ' ', C1_XIDPROC = ' ' "
						cUpdate += " WHERE R_E_C_N_O_ = " + cValToChar(SC1->(RECNO()))

						If TCSQLExec(cUpdate) < 0
							SoftLock("SC1")
							RecLock("SC1", .F.)
							SC1->C1_XENVBIO := " " //1=Aguardando Integr. Bionexo, 2=Integrado Bionexo, 3=Aguardando Desvinculo Bionexo, 4=Erro de Integração Bionexo
							SC1->C1_XCPBIO  := " "
							SC1->C1_XIDPROC := " "
							SC1->( MsUnLock() )
						Else
							SC1->(dbCommit())
						EndIf
					EndIf
				Next nX
			//	(cAliasSC1)->(DbSkip())
			//EndDo
			//(cAliasSC1)->(DbSkip())
			Alert("A solicitação não foi enviada porque as linhas abaixo não foram gravadas na base! " + cSolics)
			lCpoVazio := .F.
		EndIf
		aAux := {}
		cKeys := ""

		(cAliasSC1)->( DbCloseArea() )
		RestArea(aArea)
	EndIf

Return( .T. )

Static Function GETSPARAM(_cPar01,_lPar02,_cPar03,_cPar04)
	Default _lPar02 := .F.
	Default _cPar03 := ""
	Default _cPar04 := cFilAnt
Return SUPERGETMV(_cPar01,_lPar02,_cPar03,_cPar04)
