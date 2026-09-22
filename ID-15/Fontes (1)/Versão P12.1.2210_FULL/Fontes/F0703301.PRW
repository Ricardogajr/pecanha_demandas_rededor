#INCLUDE "totvs.ch"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} F0703301
Função responsável pela integração de documentos de entrada
@type function
@author anieli.rodrigues
@since 03/02/2017
@version 12.7
@param oCabec, object, Dados do cabeçalho da nota fiscal
@param oCorpo, object, Dados do item da nota fiscal
@param oParcela, object, Dados dos títulos da nota fiscal  
@param nOperac, numérico, Operação utilizada sendo 3 para inclusão e 5 para exclusão
@project MAN0000007423041_EF_033
@return cRET
/*/  

User Function F0703301(oCabec, oCorpo, oParcela, nOperac)

	Local aCabec	:= {}
	Local aConv     := {}
	Local aExcNF	:= {}
	Local aExcTit	:= {}
	Local aImp		:= {}
	Local aItens	:= {}
	Local aLinha	:= {}
	Local aLog 	:= {}
	Local aTitulo := {}
	Local bBlock 	:= ErrorBlock({|e|ChkErr(e)})
	Local cFilDoc := ""
	Local cRet 	:= "ERRO|"
	Local cXID		:= U_GetIntegID()
	Local cXIDOld	:= ""
	Local lRet 	:= .T.
	Local nTamDoc	:= TamSX3("F1_DOC")[1]
	Local nTamFor	:= TamSX3("F1_FORNECE")[1]
	Local nTamLoja := TamSX3("F1_LOJA")[1]
	Local nTamSer  := TamSX3("F1_SERIE")[1]
	Local nX       := 0
	Local nY		:= 0
	Local nZ 		:= 0
	Local cIndKey  := ''
	Local nLenParc := 0
	Local aVctos  := {}
	Local aValCond := {}
	Local lValCond := .T.

	//Local aPergMTA := {} // ticket n° 10631343
	//Local nMta1 := GETMV("FS_MTA1") // ticket n° 10631343
	//Local nMta2 := GETMV("FS_MTA2") // ticket n° 10631343
	//Local nMta6 := GETMV("FS_MTA6") // ticket n° 10631343


	Local cConteudo := ""

	Private cNomeArq	:= AllTrim(oCabec:cDoc) + AllTrim(oCabec:cSerie) + AllTrim(oCabec:cFornece) + AllTrim(oCabec:cLoja) + AllTrim(cXID)+".txt"
	Private cErrorL			:= ""
	Private lAutoErrNoFile 	:= .T.
	Private lMsErroAuto 		:= .F.
	Private CUSERNAME 		:= "INTNF"
	Private dDtValExec       := CToD("  /  /    ")
	Private dDigita := ""
	Private _cCodServ := "" // ticket n° 11485458
	Private cFilSBZ   := AllTrim(oCabec:cFilReg) // ticket n° 11485458
	Private nRegLog	:= 0
/*
	cConteudo := "---------------------"  + CRLF
    cConteudo += "ID:" + cXID  + CRLF

	//U_F07Log04(cConteudo, cNomeArq)
*/
	//cteste := ddatabase + 1 + "oi"
	//xfVldNf(oCabec,oParcela,cXID)
	nRegLog := U_MSINTNFS("I",{oCabec,oCorpo,oParcela},0,{},nOperac)//Novo LOG da integração de NFS

	//cteste := 1+"a
	__CUSERID := "005026"

	// ticket n° 11485458
	// E2_CODSERV
	//cteste := ddatabase + 1 + "oi"
	DbSelectArea("SBZ")
	DbSetOrder(1)
	If nOperac <> 5
		For nX := 1 To Len(oCorpo)
			If DbSeek(cFilSBZ+oCorpo[nX]:cCod)
				_cCodServ := SBZ->BZ_CODISS
			Endif
		Next nX
	EndIf

	cFilDoc := Alltrim(oCabec:cFilReg)

	If Empty(cFilDoc) .Or. !ExistCpo("SM0",cEmpAnt + cFilDoc)
		lRet := .F.
		cRet += "PARAMETRO OBRIGATORIO INVALIDO: CFILREG"
		U_MSINTNFS("A",{},nRegLog,{cRet,2},nOperac)
	Else
		cFilAnt := cFilDoc
	EndIf

	//nRegLog := U_F07LOG01(cXID,{oCabec,oCorpo,oParcela,nOperac})
	/*
	cConteudo := "---------------------"  + CRLF
    cConteudo += "Ajusta Filial:" + cFilDoc  + CRLF

	//U_F07Log04(cConteudo, cNomeArq)
*/

	If Empty(cFilDoc) .Or. !ExistCpo("SM0",cEmpAnt + cFilDoc)
		lRet := .F.
		cRet += "PARAMETRO OBRIGATORIO INVALIDO: CFILREG"
		U_MSINTNFS("A",{},nRegLog,{cRet,2},nOperac)
	Else
		cFilAnt := cFilDoc
	EndIf
/*
	cConteudo := "---------------------"			+ CRLF
	cConteudo += "Validação dos dados NF"			+ CRLF
    cConteudo += "Filial:" + cFilAnt  				+ CRLF
    cConteudo += "Documento	:" + oCabec:cDoc		+ CRLF
    cConteudo += "Serie		:" + oCabec:cSerie		+ CRLF
    cConteudo += "Fornecedor:" + oCabec:cFornece	+ CRLF
    cConteudo += "Loja		:" + oCabec:cLoja		+ CRLF

	//U_F07Log04(cConteudo, cNomeArq)
*/		
	If lRet .And. Empty(oCabec:cDoc)
		lRet := .F.
		cRet += "PARAMETRO OBRIGATORIO INVALIDO: CDOC"
		U_MSINTNFS("A",{},nRegLog,{cRet,2},nOperac)
	EndIf


	If lRet .And. Empty(oCabec:cSerie)
		lRet := .F.
		cRet += "PARAMETRO OBRIGATORIO INVALIDO: CSERIE"
		U_MSINTNFS("A",{},nRegLog,{cRet,2},nOperac)
	EndIf

	If lRet .And. Empty(oCabec:cFornece)
		lRet := .F.
		cRet += "PARAMETRO OBRIGATORIO INVALIDO: CFORNECE"
		U_MSINTNFS("A",{},nRegLog,{cRet,2},nOperac)
	EndIf

	If lRet .And. Empty(oCabec:cLoja)
		lRet := .F.
		cRet += "PARAMETRO OBRIGATORIO INVALIDO: CLOJA"
		U_MSINTNFS("A",{},nRegLog,{cRet,2},nOperac)
	EndIf

	If nOperac == 3 .And. !Empty(oCabec:cDtDigit)
		If Empty(cToD(oCabec:cDtDigit))
			lRet := .F.
			cRet += "PARAMETRO OBRIGATORIO INVALIDO: CDTDIGIT"
			U_MSINTNFS("A",{},nRegLog,{cRet,2},nOperac)
		Else
			dDataBase := cToD(oCabec:cDtDigit)
		EndIf
	EndIf

	For nZ := 1 to Len(oParcela)
		If nZ == 1
			If cToD(oParcela[nZ]:cEmissao) < cToD(GetNewPar("MS_XDATLIM","20250701"))//Só valida vencimento para notas com emissão a partir de 01/07
				lValCond := .F.
				Exit
			EndIf
			Aadd(aVctos, cToD(oParcela[nZ]:cEmissao))
			Aadd(aVctos, {cToD(oParcela[nZ]:cVencto),oParcela[nZ]:cParcela})
		Else
			Aadd(aVctos, {cToD(oParcela[nZ]:cVencto),oParcela[nZ]:cParcela})
		EndIf
	Next nZ

	If lValCond
		//Valida condição de pagamento de acordo com a nova política da empresa
		//Lucas Miranda de Aguiar 15/06/2025
		aValCond := U_MSCHKCOND("",Padr(oCabec:cFornece,nTamFor),Padr(oCabec:cLoja,nTamLoja),.T.,aVctos)

		If GetNewPar("MS_VLDTINT",2) == 1 //versão da validação do vencimento para integração
			If !aValCond[1]
				lRet := .F.
				cRet += aValCond[2]
				U_MSINTNFS("A",{},nRegLog,{cRet,2},nOperac)
			EndIf
		Else
			If !aValCond[1]
				For nZ := 01 To Len(aValCond[2])
					For nY := 01 To Len(oParcela)
						If oParcela[nZ]:cParcela == aValCond[2][nZ][2]
							oParcela[nZ]:cVencto := DtoC(aValCond[2][nZ][1])
							oParcela[nZ]:cVencOri := DtoC(aValCond[2][nZ][1])
							oParcela[nZ]:cVencRea := DtoC(aValCond[2][nZ][1])
						EndIf
					Next nY
				Next nZ
			EndIf
		EndIf
	EndIf
	cIndKey := xFilial("SF1") + '|' + Padr(oCabec:cDoc,nTamDoc) + '|' + Padr(oCabec:cSerie,nTamSer) + '|' + Padr(oCabec:cFornece,nTamFor) + '|' + Padr(oCabec:cLoja,nTamLoja)

	If lRet
		SF1->(DbSetOrder(1))
		If SF1->(DbSeek(xFilial("SF1") + Padr(oCabec:cDoc,nTamDoc) + Padr(oCabec:cSerie,nTamSer) + Padr(oCabec:cFornece,nTamFor) + Padr(oCabec:cLoja,nTamLoja)))

			//Verifica se calendario contabil esta aberto ou fechado, se fechado e exclusao, nao permite o processamento
			If nOperac == 5 .and. InvalidCTG()
				lRet := .F.
				cRet += "CALENDARIO CONTABIL FECHADO OU BLOQUEADO, EXCLUSAO DA NF DE ENTRADA NAO REALIZADA"
			Endif

			if lRet
				Begin Transaction
			/*
				cConteudo := "---------------------"			+ CRLF
				cConteudo += "Execauto Exclusão de Título"		+ CRLF
			    cConteudo += "Filial	:"  + cFilAnt  			+ CRLF
	            cConteudo += "E2_NUM	:"	+ SE2->E2_NUM		+ CRLF
				cConteudo += "E2_PREFIXO:"	+ SE2->E2_PREFIXO   + CRLF
				cConteudo += "E2_PARCELA:"	+ SE2->E2_PARCELA   + CRLF
				cConteudo += "E2_TIPO	:"	+ SE2->E2_TIPO	    + CRLF
				cConteudo += "E2_FORNECE:"	+ SE2->E2_FORNECE   + CRLF
				cConteudo += "E2_LOJA	:"	+ SE2->E2_LOJA	    + CRLF
			
				//U_F07Log04(cConteudo, cNomeArq)
			*/
					cXIDOld := SF1->F1_XID
					SE2->(DBOrderNickName("EF0703301"))
					If SE2->(DbSeek(xFilial("SE2") + cXIDOld))
						While SE2->E2_FILIAL == xFilial("SE2") .And. SE2->E2_XID == cXIDOld
							aExcTit := {}
							AAdd(aExcTit,{"E2_NUM" 		,SE2->E2_NUM		,NIL})
							AAdd(aExcTit,{"E2_PREFIXO"	,SE2->E2_PREFIXO	,NIL})
							AAdd(aExcTit,{"E2_PARCELA"	,SE2->E2_PARCELA	,NIL})
							AAdd(aExcTit,{"E2_TIPO"		,SE2->E2_TIPO		,NIL})
							AAdd(aExcTit,{"E2_FORNECE"	,SE2->E2_FORNECE	,NIL})
							AAdd(aExcTit,{"E2_LOJA"		,SE2->E2_LOJA		,NIL})

							MsExecAuto({|x,y,z| FINA050(x,y,z)},aExcTit,,5)

							If lMsErroAuto
								DisarmTransaction()
								Break
							EndIf
							SE2->(DbSkip())
						EndDo
					EndIf
/*
				cConteudo := "---------------------"			+ CRLF
				cConteudo += "Execauto Exclusão de NF"			+ CRLF
			    cConteudo += "Filial	:"  + cFilAnt  			+ CRLF
	            cConteudo += "F1_DOC	:"	+ SF1->F1_DOC		+ CRLF
				cConteudo += "F1_SERIE	:"	+ SF1->F1_SERIE   + CRLF
				cConteudo += "F1_FORNECE:"	+ SF1->F1_FORNECE   + CRLF
				cConteudo += "F1_LOJA	:"	+ SF1->F1_LOJA	    + CRLF
				cConteudo += "F1_FORMUL	:"	+ SF1->F1_FORMUL   + CRLF
			
				//U_F07Log04(cConteudo, cNomeArq)
*/		 
					AAdd(aExcNF,{"F1_DOC"    , SF1->F1_DOC    , NIL})
					AAdd(aExcNF,{"F1_SERIE"  , SF1->F1_SERIE  , NIL})
					AAdd(aExcNF,{"F1_FORNECE", SF1->F1_FORNECE, NIL})
					AAdd(aExcNF,{"F1_LOJA"   , SF1->F1_LOJA   , NIL})
					AAdd(aExcNF,{"F1_FORMUL" , SF1->F1_FORMUL , NIL})

					dDtValExec := SF1->F1_EMISSAO

					//aAdd(aPergMTA, {"MV_PAR02", nMta2}) // Aglut Lançamentos?     1 = Sim, 2 = Não  // ticket n° 10631343

					//MSExecAuto({|x,y,z,k| MATA103(x,y,z,,,,k,,,,)},aExcNF,aItens,5,aPergMTA) // ticket n° 10631343
					MSExecAuto({|x,y,z| MATA103(x,y,z)},aExcNF,aItens,5)

					If lMsErroAuto
						DisarmTransaction()
						Break
					EndIf

					If nOperac == 3
						lRet := CarArrayNF(oCabec,oCorpo,@aCabec,@aItens,@cRet,cXID,oParcela[1])

						If !lRet
							DisarmTransaction()
							Break
						EndIf

						dDtValExec := CToD(oCabec:cDtDigit)
						//aAdd(aPergMTA, {"MV_PAR01", nMta1}) // Mostra Lanc Contábeis? 1 = Sim, 2 = Não  // ticket n° 10631343
						//aAdd(aPergMTA, {"MV_PAR02", nMta2}) // Aglut Lançamentos?     1 = Sim, 2 = Não  // ticket n° 10631343
						//aAdd(aPergMTA, {"MV_PAR06", nMta6}) // Contabilizacao Online? 1 = Sim, 2 = Não  // ticket n° 10631343

						//MSExecAuto({|x,y,z,k| MATA103(x,y,z,,,,k,,,,)},aCabec,aItens,3,aPergMTA) // ticket n° 10631343
						MSExecAuto({|x,y,z| MATA103(x,y,z)},aCabec,aItens,3)

						If lMsErroAuto
							DisarmTransaction()
							Break
						EndIf

						SD1->(DbSetOrder(1))
						If !SD1->(DbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
							EnviaEmail()
							Conout("D1 SEM FILIAL")
							Conout("CHAVE F1: " + SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
							cRet += "Itens da nota fiscal não encontrados - rollback na operação."
							Conout("Nota fiscal existia anteriormente")
							//U_F07LOG02(nRegLog,cRet,.F.,"SF1",1,cIndKey)
							U_MSINTNFS("A",{},nRegLog,{cRet,2},nOperac)
							DisarmTransaction()
							Break
						EndIf

						For nZ := 1 to Len(oParcela)
							nLenParc := Len(oParcela)
							aTitulo := {}
							lRet := CarArrayCP(oParcela[nZ], cXID, @cRet, @aTitulo, SD1->D1_CC, _cCodServ, nLenParc)

							If !lRet
								DisarmTransaction()
								Break
							EndIf

							If Len(aTitulo) > 0
								CUSERNAME := "Integrador"
								MsExecAuto({|x,y,z| FINA050(x,y,z)},aTitulo,,3)
								If lMsErroAuto

									DisarmTransaction()
									U_MSINTNFS("A",{},nRegLog,{cRet,2},nOperac)
									Break
								EndIf
							EndIf
						Next nZ
					EndIf
				End Transaction
			EndIf
		Else
			If nOperac == 5
				lRet := .F.
				cRet += "NOTA FISCAL NAO LOCALIZADA" + CRLF
			Else
				Begin Transaction

					lRet := CarArrayNF(oCabec,oCorpo,@aCabec,@aItens,@cRet,cXID,oParcela[1])

					If !lRet
						DisarmTransaction()
						Break
					EndIf

					dDtValExec := CToD(oCabec:cDtDigit)

					//aAdd(aPergMTA, {"MV_PAR01", nMta1}) // Mostra Lanc Contábeis? 1 = Sim, 2 = Não  // ticket n° 10631343
					//aAdd(aPergMTA, {"MV_PAR02", nMta2}) // Aglut Lançamentos?     1 = Sim, 2 = Não  // ticket n° 10631343
					//aAdd(aPergMTA, {"MV_PAR06", nMta6}) // Contabilizacao Online? 1 = Sim, 2 = Não  // ticket n° 10631343

					//MSExecAuto({|x,y,z,k| MATA103(x,y,z,,,,k,,,,)},aCabec,aItens,3,aPergMTA) // ticket n° 10631343
					MSExecAuto({|x,y,z| MATA103(x,y,z)},aCabec,aItens,3)

					If lMsErroAuto
						DisarmTransaction()
						Break
					EndIf

					SD1->(DbSetOrder(1))
					If !SD1->(DbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
						EnviaEmail()
						Conout("D1 SEM FILIAL")
						Conout("CHAVE F1: " + SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
						Conout("Nota fiscal não existia anteriormente")
						cRet += "Itens da nota fiscal não encontrados - rollback na operação."
						//U_F07LOG02(nRegLog,cRet,.F.,"SF1",1,cIndKey)

						DisarmTransaction()
						U_MSINTNFS("A",{},nRegLog,{cRet,2},nOperac)
						Break
					EndIf

					For nZ := 1 to Len(oParcela)

						nLenParc := Len(oParcela)
						aTitulo := {}
						lRet := CarArrayCP(oParcela[nZ], cXID, @cRet, @aTitulo, SD1->D1_CC, _cCodServ, nLenParc)

						If !lRet
							DisarmTransaction()
							Break
						EndIf

						If Len(aTitulo) > 0
							CUSERNAME := "Integrador"
							MsExecAuto({|x,y,z| FINA050(x,y,z)},aTitulo,,3)
							If lMsErroAuto
								DisarmTransaction()
								Break
							EndIf
						EndIf
					Next nZ

				End Transaction
			EndIf
		EndIf

		CUSERNAME := "INTNF"
		//ErrorBlock(bBlock)

		If lMsErroAuto
			cRet += "INCONSISTENCIA DE ROTINA AUTOMATICA | " + CRLF
			lRet := .F.
			aLog := GetAutoGRLog()
			For nY := 1 To Len(aLog)
				cRet += aLog[nY] + CRLF
			Next nY
		EndIf

		If !Empty(cErrorL)
			lRet := .F.
			cRet += "ERRO DE PROGRAMACAO | " + CRLF + cErrorL
		EndIf

		If !lMsErroAuto .And. lRet

			//lret := xfVldNf(oCabec,oParcela,cXID)
			//SF1->(DbSetOrder(1))
			If lRet//SF1->(DbSeek(xFilial("SF1") + Padr(oCabec:cDoc,nTamDoc) + Padr(oCabec:cSerie,nTamSer) + Padr(oCabec:cFornece,nTamFor) + Padr(oCabec:cLoja,nTamLoja))) .Or. (nOperac == 5 .And. SF1->(! DbSeek(xFilial("SF1") + Padr(oCabec:cDoc,nTamDoc) + Padr(oCabec:cSerie,nTamSer) + Padr(oCabec:cFornece,nTamFor) + Padr(oCabec:cLoja,nTamLoja))))
				cRet := "OK|ID: " + cXID
				//U_F07LOG02(nRegLog,cRet,.T.,"SF1",1,cIndKey)
				U_MSINTNFS("A",{},nRegLog,{cRet,1},nOperac)
			Else
				cRet := "ERRO DE PROGRAMACAO | Erro ao gerar a NF " + cXID + xFilial("SF1") + Padr(oCabec:cDoc,nTamDoc) + Padr(oCabec:cSerie,nTamSer) + Padr(oCabec:cFornece,nTamFor) + Padr(oCabec:cLoja,nTamLoja) + " Favor reprocessar!"
				//U_F07LOG02(nRegLog,cRet,.F.,"SF1",1,cIndKey)
				U_MSINTNFS("A",{},nRegLog,{cRet,2},nOperac)
			EndIf
		Else
			//U_F07LOG02(nRegLog,cRet,.F.,"SF1",1,cIndKey)
			U_MSINTNFS("A",{},nRegLog,{cRet,2},nOperac)
		EndIf
	EndIf

	dDataBase := Date()
	ErrorBlock(bBlock)
Return cRet


/*/{Protheus.doc} CarArrayNF
Função responsável pela montagem do array para inclusão da nota fiscal via execauto
@type function
@author anieli.rodrigues
@since 03/02/2017
@version 12.7
@param oCabec, object, Dados do cabeçalho da nota fiscal
@param oCorpo, object, Dados do item da nota fiscal
@param aCabec, array, Variavel para montagem do array de cabeçalho (referencia)  
@param aItens, array, Variavel para montagem do array de itens (referencia)
@param cRet, caractere, Variavel para armazenar mensagem de erro (referencia)
@param cXID, caractere, ID unico reservado para a integração
@project MAN0000007423041_EF_033
@return lRet
/*/

Static Function CarArrayNf(oCabec,oCorpo,aCabec,aItens,cRet,cXID,oParcela)

	Local aConv    := {}
	Local aItens   := {}
	Local aLinha   := {}
	Local lRet     := .T.
	Local nTamDoc  := TamSX3("F1_DOC")[1]
	Local nTamFor  := TamSX3("F1_FORNECE")[1]
	Local nTamLoja := TamSX3("F1_LOJA")[1]
	Local nTamProd := TamSX3("D1_COD")[1]
	Local nTamSer  := TamSX3("F1_SERIE")[1]
	Local nX       := 0
	Local nDespesa := 0
	Local cTESIntNor := SuperGetMV("FS_TESINOR",,"")
	Local cTESIntCon := SuperGetMV("FS_TESICON",,"")
	Local nVlDescItm := 0
	Local lFixa := .F.
	Local dData := ""

	// variáveis ticket n° 11485458
	Local lParam      := .F.
	Local _cTESFor    := SuperGetMV("FS_TESSERV")
	Local _cCodFor    := SuperGetMV("FS_FORSERV")
	Local _nAliq      := 0
	Local _cTotal     := ""
	Local _nValiss    := 0
	Local _cTESPar    := ""
	Private aPedidos := {}

	If Empty(cTESIntNor)
		lRet := .F.
		cRet += "PARAMETRO FS_TESINOR NÃO CONFIGURADO (TES DE INTEGRAÇÃO MOVIMENTO NORMAL)"
		Return lRet
	EndIf

	If Empty(cTESIntCon)
		lRet := .F.
		cRet += "PARAMETRO FS_TESICON NÃO CONFIGURADO (TES DE INTEGRAÇÃO MOVIMENTO CONSIGNADO)"
		Return lRet
	EndIf

	dDigita := oCabec:cDtDigit

	AAdd(aCabec,{"F1_TIPO" 		,oCabec:cTipo})
	AAdd(aCabec,{"F1_FORMUL" 	,"N"})
	AAdd(aCabec,{"F1_DOC"    	,Padr(oCabec:cDoc,nTamDoc)})
	AAdd(aCabec,{"F1_SERIE"  	,Padr(oCabec:cSerie,nTamSer)})
	AAdd(aCabec,{"F1_EMISSAO"	,CtoD(oCabec:cEmissao)})
	AAdd(aCabec,{"F1_FORNECE"	,Padr(oCabec:cFornece,nTamFor)})
	AAdd(aCabec,{"F1_LOJA"   	,Padr(oCabec:cLoja,nTamLoja)})
	AAdd(aCabec,{"F1_ESPECIE"	,oCabec:cEspecie})
	AAdd(aCabec,{"F1_EST" 		,oCabec:cEst})
	AAdd(aCabec,{"F1_CHVNFE" 	,oCabec:cChvNfe})
	AAdd(aCabec,{"F1_NFORIG" 	,oCabec:cNfOrig})
	AAdd(aCabec,{"F1_SERORIG" 	,oCabec:cSerOrig})
	AAdd(aCabec,{"F1_HORA" 		,oCabec:cHora})
	AAdd(aCabec,{"F1_FOB_R" 	,Iif(Empty(Val(oCabec:cFob_R)),0,Val(oCabec:cFob_R))})
	AAdd(aCabec,{"F1_CIF" 		,Iif(Empty(Val(oCabec:cCif)),0,Val(oCabec:cCif))})
	AAdd(aCabec,{"F1_RECBMTO" 	,cToD(oCabec:cRecbmto)})
	AAdd(aCabec,{"F1_CODNFE" 	,oCabec:cCodNfe})
	AAdd(aCabec,{"F1_CHVNFE" 	,oCabec:cChvNfe})
	AAdd(aCabec,{"F1_MENNOTA" 	,oCabec:cMenNota})
	AAdd(aCabec,{"F1_XCONSIG"	,oCabec:cXConsig})
	AAdd(aCabec,{"F1_XTITFRO"	,oCabec:cXTitFro})
	AAdd(aCabec,{"F1_XID" 		,cXID})
	AAdd(aCabec,{"F1_FRETE"  	,Iif(Empty(Val(oCabec:cFRETE)),0,Val(oCabec:cFRETE))})
	AADD(aCabec,{"F1_XDTEXCE"   ,"2"})
	AADD(aCabec,{"F1_XDTORIG"	,cToD(oParcela:cVencto)})

	If Posicione("SA2",1,xFilial("SA2")+Padr(oCabec:cFornece,nTamFor)+Padr(oCabec:cLoja,nTamLoja),"SA2->A2_XDTFIX") == "1"
		dData := U_DTFORNFIX(cToD(oParcela:cVencto),"",1,dDigita)//Melhoria data fixa - Lucas Miranda de Aguiar
		lFixa := .T.
	EndIf

	U_F07PADR(aCabec)

/*
	cConteudo := "---------------------"							+ CRLF
	cConteudo += "Array SF1 Inclusão"								+ CRLF
    cConteudo += "Filial	:"  + cFilAnt  							+ CRLF
    cConteudo += "F1_TIPO 	:"	+ oCabec:cTipo                      + CRLF
	cConteudo += "F1_FORMUL :"	+ "N"                               + CRLF
	cConteudo += "F1_DOC   	:"	+ Padr(oCabec:cDoc,nTamDoc)         + CRLF
	cConteudo += "F1_SERIE 	:"	+ Padr(oCabec:cSerie,nTamSer)       + CRLF
	cConteudo += "F1_EMISSAO:"	+ oCabec:cEmissao             		+ CRLF
    cConteudo += "F1_FORNECE:"  + Padr(oCabec:cFornece,nTamFor)     + CRLF
    cConteudo += "F1_LOJA  	:"	+ Padr(oCabec:cLoja,nTamLoja)       + CRLF
	cConteudo += "F1_ESPECIE:"	+ oCabec:cEspecie                   + CRLF
	cConteudo += "F1_EST	:"	+ oCabec:cEst                       + CRLF
	cConteudo += "F1_CHVNFE	:"	+ oCabec:cChvNfe                    + CRLF
	cConteudo += "F1_NFORIG	:"	+ oCabec:cNfOrig                    + CRLF
    cConteudo += "F1_SERORIG:"  + oCabec:cSerOrig                   + CRLF
    cConteudo += "F1_HORA 	:"	+ oCabec:cHora                      + CRLF
	cConteudo += "F1_FOB_R	:"	+ oCabec:cFob_R						+ CRLF
	cConteudo += "F1_CIF	:"	+ oCabec:cCif   					+ CRLF
	cConteudo += "F1_RECBMTO:"	+ oCabec:cRecbmto                 	+ CRLF
	cConteudo += "F1_CODNFE	:"	+ oCabec:cCodNfe                    + CRLF
    cConteudo += "F1_CHVNFE	:"  + oCabec:cChvNfe	                + CRLF
    cConteudo += "F1_MENNOTA:"	+ oCabec:cMenNota                   + CRLF
	cConteudo += "F1_XCONSIG:"	+ oCabec:cXConsig                   + CRLF
	cConteudo += "F1_XTITFRO:"	+ oCabec:cXTitFro                   + CRLF
	cConteudo += "F1_XID	:"	+ cXID	                            + CRLF 	
	cConteudo += "F1_FRETE	:"	+ oCabec:cFRETE                     + CRLF
				
	//U_F07Log04(cConteudo, cNomeArq)
*/
	DbSelectArea("SC7")
	SC7->(DbSetOrder(1))
	For nX := 1 To Len(oCorpo)

		SC7->(DbSeek(xFilial("SC7")+oCorpo[nX]:cPedido+oCorpo[nX]:cItemPC))
		AADD(aPedidos,{SC7->C7_QUANT,SC7->C7_QUJE,SC7->(RECNO())})

		aConv := U_F07024X(Padr(oCorpo[nX]:cCod,nTamProd),cFilAnt,Val(oCorpo[nX]:cQUANT),1,2,oCorpo[nX]:cUM)

		If !Empty(aConv[3])
			lRet := .F.
			cRet += aConv[3]
			Exit
		EndIf

		If Empty(oCorpo[nX]:cITEM)
			lRet := .F.
			cRet += "PARAMETRO OBRIGATORIO NAO INFORMADO: CITEM"
			U_MSINTNFS("A",{},nRegLog,{cRet,2},nOperac)
			Exit
		EndIf

		If Empty(oCorpo[nX]:cPedido)
			lRet := .F.
			cRet += "PARAMETRO OBRIGATORIO NAO INFORMADO: CPEDIDO"
			U_MSINTNFS("A",{},nRegLog,{cRet,2},nOperac)
			Exit
		EndIf

		If Empty(oCorpo[nX]:cItemPC)
			lRet := .F.
			cRet += "PARAMETRO OBRIGATORIO NAO INFORMADO: CITEMPC"
			U_MSINTNFS("A",{},nRegLog,{cRet,2},nOperac)
			Exit
		EndIf

		//Posiciona ítem de Pedido de Compra para cálculo de despesa
		SC7->(DbSetOrder(01))


		// ticket n° 11485458
		If _cCodFor == Padr(oCabec:cFornece,nTamFor)
			lParam := .T.
		EndIf

		If lParam

			// D1_TES
			//_cTESFor

			// D1_ALIQISS
			DbSelectArea("SBZ")
			DbSetOrder(1)
			If DbSeek(cFilSBZ+oCorpo[nX]:cCod)
				_nAliq := SBZ->BZ_ALIQISS
			Endif

			// D1_BASEISS
			_cTotal := Val(oCorpo[nX]:cTOTAL)

			// D1_VALISS
			_nValiss := (_nAliq / 100) * _cTotal

		Else

			// D1_TES
			If  oCorpo[nX]:cXCONSIG == "1"
				_cTESFor := cTESIntCon
			Else
				_cTESFor := cTESIntNor
			EndIf

			// D1_ALIQISS
			If Empty(oCorpo[nX]:cAliqISS)
				_nAliq := 0
			Else
				_nAliq := (oCorpo[nX]:cAliqISS)
			EndIf

			// D1_BASEISS
			If Empty(oCorpo[nX]:cBaseISS)
				_cTotal := 0
			Else
				_cTotal := oCorpo[nX]:cBaseISS
			EndIf

			// D1_VALISS
			If Empty(oCorpo[nX]:cValISS)
				_nValiss := 0
			Else
				_nValiss := oCorpo[nX]:cValISS
			EndIf

		EndIf

		// Fim ticket n° 11485458

//      ID 1405 - Retirado C7_DESPESA do somatório da nota
//    	If SC7->(DbSeek(oCabec:cFilReg + oCorpo[nX]:cPedido + oCorpo[nX]:cItemPC))
//    		nDespesa += (SC7->C7_DESPESA / SC7->C7_QUANT) * aConv[1]
//		EndIf
/*		
		cConteudo := "---------------------"													+ CRLF
		cConteudo += "Array SD1 Inclusão"														+ CRLF
    	cConteudo += "Filial	:"  + cFilAnt  													+ CRLF
	    cConteudo += "D1_ITEM   :"  + oCorpo[nX]:cITEM											+ CRLF
	    cConteudo += "D1_COD    :"	+ oCorpo[nX]:cCod											+ CRLF
		cConteudo += "D1_PEDIDO :"	+ oCorpo[nX]:cPedido										+ CRLF
		cConteudo += "D1_ITEMPC :"	+ oCorpo[nX]:cItemPC										+ CRLF
		cConteudo += "D1_UM     :"	+ aConv[2]													+ CRLF
		cConteudo += "D1_QUANT  :"	+ cValToChar(aConv[1])										+ CRLF
	    cConteudo += "D1_VUNIT  :"  + cValtoChar(Val(oCorpo[nX]:cTOTAL)/aConv[1])				+ CRLF
	    cConteudo += "D1_TOTAL  :"	+ oCorpo[nX]:cTOTAL											+ CRLF
	    cConteudo += "D1_VALFRE :"	+ oCorpo[nX]:cValFre										+ CRLF
		cConteudo += "D1_SEGURO :"	+ oCorpo[nX]:cSeguro										+ CRLF
		cConteudo += "D1_VALDESC:"	+ oCorpo[nX]:cValDesc										+ CRLF
		cConteudo += "D1_TES    :"	+ Iif(oCorpo[nX]:cXCONSIG == "1",cTESIntCon,cTESIntNor)		+ CRLF
	    cConteudo += "D1_CF     :"  + oCorpo[nX]:cCF											+ CRLF
	    cConteudo += "D1_LOCAL  :"	+ oCorpo[nX]:cLocal											+ CRLF
		cConteudo += "D1_NFORI  :"	+ oCorpo[nX]:cNfOri											+ CRLF
		cConteudo += "D1_SERIORI:"	+ oCorpo[nX]:cSeriOri										+ CRLF
		cConteudo += "D1_ITEMORI:"	+ oCorpo[nX]:cItemOri										+ CRLF
		cConteudo += "D1_CUSTO  :"	+ oCorpo[nX]:cCusto											+ CRLF
	    cConteudo += "D1_QTDPEDI:"  + oCorpo[nX]:cQtdPedi										+ CRLF
	    cConteudo += "D1_XDTVALI:"	+ oCorpo[nX]:cXDtVali										+ CRLF
		cConteudo += "D1_XLOTECT:"	+ oCorpo[nX]:cXLoteCt										+ CRLF
		cConteudo += "D1_XSETOR :"	+ oCorpo[nX]:cXSetor										+ CRLF
		cConteudo += "D1_XCONSIG:"	+ oCorpo[nX]:cXCONSIG										+ CRLF 	
        cConteudo += "D1_IPI    :"	+ oCorpo[nX]:cIPI											+ CRLF 
        cConteudo += "D1_BASEIPI:"	+ oCorpo[nX]:cBaseIPI									    + CRLF 
        cConteudo += "D1_VALIP  :"	+ oCorpo[nX]:cValIPI								     	+ CRLF 
        cConteudo += "D1_PIC    :"	+ oCorpo[nX]:cPICM										    + CRLF 
        cConteudo += "D1_BASEICM:"	+ oCorpo[nX]:cBaseICM									    + CRLF 
        cConteudo += "D1_VALICM :"  + oCorpo[nX]:cVALICM									    + CRLF 
        cConteudo += "D1_ESTCRED:"	+ oCorpo[nX]:cEstCred									    + CRLF 
        cConteudo += "D1_ICMSCOM:"	+ oCorpo[nX]:cICMSCom									    + CRLF 
        cConteudo += "D1_VALACRS:"	+ oCorpo[nX]:cValAcrs								     	+ CRLF 
        cConteudo += "D1_MARGEM :"	+ oCorpo[nX]:cMargem								     	+ CRLF 
        cConteudo += "D1_ALIQSOL:"	+ oCorpo[nX]:cAliqSol								     	+ CRLF 
        cConteudo += "D1_BRICMS :"  + oCorpo[nX]:cBRICMS									    + CRLF 
        cConteudo += "D1_ICMSRET:"	+ oCorpo[nX]:cICMSRet									    + CRLF 
        cConteudo += "D1_BASEPIS:"	+ oCorpo[nX]:cBasePIS									    + CRLF 
        cConteudo += "D1_ALQPIS :"	+ oCorpo[nX]:cAlqPIS									    + CRLF 
        cConteudo += "D1_VALPIS :"	+ oCorpo[nX]:cValPIS								        + CRLF 
        cConteudo += "D1_BASECOF:"	+ oCorpo[nX]:cBaseCof									    + CRLF 
        cConteudo += "D1_ALQCOF :"  + oCorpo[nX]:cAlqCof								        + CRLF 
        cConteudo += "D1_VALCOF :"	+ oCorpo[nX]:cValCof									    + CRLF 
        cConteudo += "D1_BASECSL:"	+ oCorpo[nX]:cBaseCSL									    + CRLF 
        cConteudo += "D1_ALQCSL :"	+ oCorpo[nX]:cAlqCSL								        + CRLF 
        cConteudo += "D1_VALCSL :"	+ oCorpo[nX]:cValCSL								        + CRLF 
        cConteudo += "D1_BASIMP6:"	+ oCorpo[nX]:cBasImp6 									    + CRLF 
        cConteudo += "D1_ALQIMP6:"	+ oCorpo[nX]:cAlqImp6									    + CRLF 
        cConteudo += "D1_VALIMP6:"	+ oCorpo[nX]:cValImp6									    + CRLF 
        cConteudo += "D1_BASIMP5:"	+ oCorpo[nX]:cBasImp5 									    + CRLF 
        cConteudo += "D1_ALQIMP5:"	+ oCorpo[nX]:cAlqImp5									    + CRLF 
        cConteudo += "D1_VALIMP5:"  + oCorpo[nX]:cValImp5									    + CRLF 
        cConteudo += "D1_BASEIRR:"	+ oCorpo[nX]:cBaseIRR									    + CRLF 
        cConteudo += "D1_ALIQIRR:"	+ oCorpo[nX]:cAliqIRR									    + CRLF 
        cConteudo += "D1_VALIRR :"	+ oCorpo[nX]:cValIRR								        + CRLF 
        cConteudo += "D1_ABATMAT:"	+ oCorpo[nX]:cAbatMat									    + CRLF 
        cConteudo += "D1_BASEISS:"	+ oCorpo[nX]:cBaseISS									    + CRLF 
        cConteudo += "D1_ALIQISS:"  + oCorpo[nX]:cAliqISS									    + CRLF 
        cConteudo += "D1_VALISS :"	+ oCorpo[nX]:cValISS							         	+ CRLF 
        cConteudo += "D1_BASEINS:"	+ oCorpo[nX]:cBaseINS								        + CRLF 
        cConteudo += "D1_ALIQINS:"	+ oCorpo[nX]:cAliqINS								        + CRLF 
        cConteudo += "D1_VALINS :"	+ oCorpo[nX]:cValINS								        + CRLF 
        cConteudo += "D1_ALIQCF3:"	+ oCorpo[nX]:cAliqCF3								        + CRLF 
        cConteudo += "D1_BASECF3:"  + oCorpo[nX]:cBasePS3								        + CRLF 
        cConteudo += "D1_VALCF3 :"	+ oCorpo[nX]:cValCF3 								        + CRLF 
        cConteudo += "D1_CRDZFM :"	+ oCorpo[nX]:cCrdZFM								        + CRLF 
				
		//U_F07Log04(cConteudo, cNomeArq)		
*/		
		aLinha := {}

		AAdd(aLinha,{"D1_ITEM"   , oCorpo[nX]:cITEM															,Nil})
		AAdd(aLinha,{"D1_COD"    , oCorpo[nX]:cCod															,Nil})
		AAdd(aLinha,{"D1_PEDIDO" , oCorpo[nX]:cPedido														,Nil})
		AAdd(aLinha,{"D1_ITEMPC" , oCorpo[nX]:cItemPC														,Nil})
		AAdd(aLinha,{"D1_UM"     , aConv[2]																	,Nil})
		AAdd(aLinha,{"D1_QUANT"  , aConv[1]																	,Nil})
		AAdd(aLinha,{"D1_VUNIT"  , Val(oCorpo[nX]:cTOTAL)/aConv[1]											,Nil})
		AAdd(aLinha,{"D1_TOTAL"  , Val(oCorpo[nX]:cTOTAL)													,Nil})
		//AAdd(aLinha,{"D1_VALFRE" , Iif(Empty(Val(oCorpo[nX]:cValFre)),0,	Val(oCorpo[nX]:cValFre))		,Nil}) //O Frete será informado apenas no Cabeçalho
		AAdd(aLinha,{"D1_SEGURO" , Iif(Empty(Val(oCorpo[nX]:cSeguro)),0,	Val(oCorpo[nX]:cSeguro))		,Nil})
		//AAdd(aLinha,{"D1_DESPESA", Iif(Empty(Val(oCorpo[nX]:cDespesa)),0,Val(oCorpo[nX]:cDespesa))			,Nil})
		AAdd(aLinha,{"D1_VALDESC", Iif(Empty(Val(oCorpo[nX]:cValDesc)),0,Val(oCorpo[nX]:cValDesc))			,Nil})
		//AAdd(aLinha,{"D1_TES"    , Iif(oCorpo[nX]:cXCONSIG == "1",cTESIntCon,cTESIntNor)				    ,Nil}) // ticket n° 11485458
		AAdd(aLinha,{"D1_TES"    , _cTESFor				                                                    ,Nil})
		If !Empty(oCorpo[nX]:cCF)
			AAdd(aLinha,{"D1_CF" , oCorpo[nX]:cCF															,Nil})
		EndIf
		AAdd(aLinha,{"D1_LOCAL"  , oCorpo[nX]:cLocal		 												,Nil})
		AAdd(aLinha,{"D1_NFORI"  , oCorpo[nX]:cNfOri														,Nil})
		AAdd(aLinha,{"D1_SERIORI", oCorpo[nX]:cSeriOri														,Nil})
		AAdd(aLinha,{"D1_ITEMORI", oCorpo[nX]:cItemOri														,Nil})
		AAdd(aLinha,{"D1_CUSTO"  , Iif(Empty(Val(oCorpo[nX]:cCusto)),0,Val(oCorpo[nX]:cCusto))				,Nil})
		AAdd(aLinha,{"D1_QTDPEDI", Iif(Empty(Val(oCorpo[nX]:cQtdPedi)),0,Val(oCorpo[nX]:cQtdPedi))			,Nil})
		AAdd(aLinha,{"D1_XDTVALI", CtoD(oCorpo[nX]:cXDtVali)												,Nil})
		AAdd(aLinha,{"D1_XLOTECT", oCorpo[nX]:cXLoteCt														,Nil})
		If !Empty(oCorpo[nX]:cXSetor)
			AAdd(aLinha,{"D1_XSETOR", oCorpo[nX]:cXSetor													,Nil})
		EndIf
		AAdd(aLinha,{"D1_XCONSIG", oCorpo[nX]:cXCONSIG														,Nil})
		AAdd(aLinha,{"D1_IPI"    , Iif(Empty(Val(oCorpo[nX]:cIPI)),0,Val(oCorpo[nX]:cIPI))					,Nil})
		AAdd(aLinha,{"D1_BASEIPI", Iif(Empty(Val(oCorpo[nX]:cBaseIPI)),0,Val(oCorpo[nX]:cBaseIPI))			,Nil})
		AAdd(aLinha,{"D1_VALIPI" , Iif(Empty(Val(oCorpo[nX]:cValIPI)),0,	Val(oCorpo[nX]:cValIPI))		,Nil})
		AAdd(aLinha,{"D1_PICM"   , Iif(Empty(Val(oCorpo[nX]:cPICM)),0,Val(oCorpo[nX]:cPICM))				,Nil})
		AAdd(aLinha,{"D1_BASEICM", Iif(Empty(Val(oCorpo[nX]:cBaseICM)),0,Val(oCorpo[nX]:cBaseICM))			,Nil})
		AAdd(aLinha,{"D1_VALICM" , Iif(Empty(Val(oCorpo[nX]:cVALICM)),0,Val(oCorpo[nX]:cVALICM))			,Nil})
		AAdd(aLinha,{"D1_ESTCRED", IIf(Empty(Val(oCorpo[nX]:cEstCred)),0,Val(oCorpo[nX]:cEstCred))			,Nil})
		AAdd(aLinha,{"D1_ICMSCOM", IIf(Empty(Val(oCorpo[nX]:cICMSCom)),0,Val(oCorpo[nX]:cICMSCom))			,Nil})
		AAdd(aLinha,{"D1_VALACRS", Iif(Empty(Val(oCorpo[nX]:cValAcrs))	,0,	Val(oCorpo[nX]:cValAcrs))		,Nil})
		AAdd(aLinha,{"D1_MARGEM" , Iif(Empty(Val(oCorpo[nX]:cMargem)),0,	Val(oCorpo[nX]:cMargem))		,Nil})
		AAdd(aLinha,{"D1_ALIQSOL", Iif(Empty(Val(oCorpo[nX]:cAliqSol))	,0,	Val(oCorpo[nX]:cAliqSol))		,Nil})
		AAdd(aLinha,{"D1_BRICMS" , Iif(Empty(Val(oCorpo[nX]:cBRICMS)),0,Val(oCorpo[nX]:cBRICMS))			,Nil})
		AAdd(aLinha,{"D1_ICMSRET", Iif(Empty(Val(oCorpo[nX]:cICMSRet)),0,Val(oCorpo[nX]:cICMSRet))			,Nil})
		AAdd(aLinha,{"D1_BASEPIS", Iif(Empty(Val(oCorpo[nX]:cBasePIS)),0,Val(oCorpo[nX]:cBasePIS))			,Nil})
		AAdd(aLinha,{"D1_ALQPIS" , Iif(Empty(Val(oCorpo[nX]:cAlqPIS)),0,Val(oCorpo[nX]:cAlqPIS))			,Nil})
		AAdd(aLinha,{"D1_VALPIS" , Iif(Empty(Val(oCorpo[nX]:cValPIS)),0,	Val(oCorpo[nX]:cValPIS))		,Nil})
		AAdd(aLinha,{"D1_BASECOF", Iif(Empty(Val(oCorpo[nX]:cBaseCof)),0,Val(oCorpo[nX]:cBaseCof))			,Nil})
		AAdd(aLinha,{"D1_ALQCOF" , Iif(Empty(Val(oCorpo[nX]:cAlqCof)),0,	Val(oCorpo[nX]:cAlqCof))	 	,Nil})
		AAdd(aLinha,{"D1_VALCOF" , Iif(Empty(Val(oCorpo[nX]:cValCof)),0,Val(oCorpo[nX]:cValCof))			,Nil})
		AAdd(aLinha,{"D1_BASECSL", Iif(Empty(Val(oCorpo[nX]:cBaseCSL)),0,Val(oCorpo[nX]:cBaseCSL))			,Nil})
		AAdd(aLinha,{"D1_ALQCSL" , Iif(Empty(Val(oCorpo[nX]:cAlqCSL)),0,	Val(oCorpo[nX]:cAlqCSL))		,Nil})
		AAdd(aLinha,{"D1_VALCSL" , Iif(Empty(Val(oCorpo[nX]:cValCSL)),0,	Val(oCorpo[nX]:cValCSL))		,Nil})
		AAdd(aLinha,{"D1_BASIMP6", Iif(Empty(Val(oCorpo[nX]:cBasImp6)),0,Val(oCorpo[nX]:cBasImp6)) 			,Nil})
		AAdd(aLinha,{"D1_ALQIMP6", Iif(Empty(Val(oCorpo[nX]:cAlqImp6)),0,Val(oCorpo[nX]:cAlqImp6))			,Nil})
		AAdd(aLinha,{"D1_VALIMP6", Iif(Empty(Val(oCorpo[nX]:cValImp6)),0,Val(oCorpo[nX]:cValImp6))			,Nil})
		AAdd(aLinha,{"D1_BASIMP5", Iif(Empty(Val(oCorpo[nX]:cBasImp5)),0,Val(oCorpo[nX]:cBasImp5)) 			,Nil})
		AAdd(aLinha,{"D1_ALQIMP5", Iif(Empty(Val(oCorpo[nX]:cAlqImp5)),0,Val(oCorpo[nX]:cAlqImp5))			,Nil})
		AAdd(aLinha,{"D1_VALIMP5", Iif(Empty(Val(oCorpo[nX]:cValImp5)),0,Val(oCorpo[nX]:cValImp5))			,Nil})
		AAdd(aLinha,{"D1_BASEIRR", Iif(Empty(Val(oCorpo[nX]:cBaseIRR)),0,Val(oCorpo[nX]:cBaseIRR))			,Nil})
		AAdd(aLinha,{"D1_ALIQIRR", Iif(Empty(Val(oCorpo[nX]:cAliqIRR)),0,Val(oCorpo[nX]:cAliqIRR))			,Nil})
		AAdd(aLinha,{"D1_VALIRR" , Iif(Empty(Val(oCorpo[nX]:cValIRR)),0,	Val(oCorpo[nX]:cValIRR))		,Nil})
		AAdd(aLinha,{"D1_ABATMAT", Iif(Empty(Val(oCorpo[nX]:cAbatMat)),0,Val(oCorpo[nX]:cAbatMat))			,Nil})
		//AAdd(aLinha,{"D1_BASEISS", Iif(Empty(Val(oCorpo[nX]:cBaseISS)),0,Val(oCorpo[nX]:cBaseISS))		,Nil}) // ticket n° 11485458
		//AAdd(aLinha,{"D1_ALIQISS", Iif(Empty(Val(oCorpo[nX]:cAliqISS)),0,Val(oCorpo[nX]:cAliqISS))		,Nil}) // ticket n° 11485458
		//AAdd(aLinha,{"D1_VALISS" , Iif(Empty(Val(oCorpo[nX]:cValISS)),0,	Val(oCorpo[nX]:cValISS))		,Nil}) // ticket n° 11485458
		AAdd(aLinha,{"D1_BASEISS", _cTotal			                                                        ,Nil}) // ticket n° 11485458
		AAdd(aLinha,{"D1_ALIQISS", _nAliq			                                                        ,Nil}) // ticket n° 11485458
		AAdd(aLinha,{"D1_VALISS" , _nValiss	                                                                ,Nil}) // ticket n° 11485458
		AAdd(aLinha,{"D1_BASEINS", Iif(Empty(Val(oCorpo[nX]:cBaseINS)),0,Val(oCorpo[nX]:cBaseINS))			,Nil})
		AAdd(aLinha,{"D1_ALIQINS", Iif(Empty(Val(oCorpo[nX]:cAliqINS)),0,Val(oCorpo[nX]:cAliqINS))			,Nil})
		AAdd(aLinha,{"D1_VALINS" , Iif(Empty(Val(oCorpo[nX]:cValINS)),0,Val(oCorpo[nX]:cValINS))			,Nil})
		AAdd(aLinha,{"D1_ALIQCF3", Iif(Empty(Val(oCorpo[nX]:cAliqCF3)),0,Val(oCorpo[nX]:cAliqCF3))			,Nil})
		AAdd(aLinha,{"D1_BASECF3", Iif(Empty(Val(oCorpo[nX]:cBasePS3)),0,Val(oCorpo[nX]:cBasePS3))			,Nil})
		AAdd(aLinha,{"D1_VALCF3" , Iif(Empty(Val(oCorpo[nX]:cValCF3)),0,Val(oCorpo[nX]:cValCF3)) 			,Nil})
		AAdd(aLinha,{"D1_CRDZFM" , Iif(Empty(Val(oCorpo[nX]:cCrdZFM)),0,Val(oCorpo[nX]:cCrdZFM))			,Nil})
		If lFixa
			AAdd(aLinha,{"D1_XPRIVEN" , dData			,Nil})
		EndIf
		nVlDescItm := nVlDescItm + Iif(Empty(Val(oCorpo[nX]:cValDesc)),0,Val(oCorpo[nX]:cValDesc))

		U_F07PADR(aLinha)

		AAdd(aItens,aLinha)

	Next nX

//  ID 1405 - Retirado C7_DESPESA do somatório da nota
//	AAdd(aCabec,{"F1_DESPESA"	,nDespesa + VAL(oCabec:cDespesa)})	
	AAdd(aCabec,{"F1_DESPESA"	,VAL(oCabec:cDespesa)})

	AAdd(aCabec,{"F1_DESCONT"   ,VAL(oCabec:cDescont) + nVlDescItm })

Return lRet

/*/{Protheus.doc} CarArrayCP
Função responsável pela montagem do array para inclusão do contas a pagar 
@type function
@author anieli.rodrigues
@since 03/02/2017
@version 12.7
@param oParcela, object, Dados dos títulos a pagar da nota fiscal 
@param cXID, caractere, ID unico reservado para a integração)
@param cRet, caractere, Variavel para armazenar mensagem de erro (referencia)
@param aTitulo, array, Variavel para montagem do array de duplicatas (referencia)  
@project MAN0000007423041_EF_033
@return lRet 
/*/

Static Function CarArrayCp(oParcela, cXID, cRet, aTitulo, cCCusto, _cCodServ, nLen)

	Local lEmpty 		:= .T.
	Local lRet 		:= .T.
	Local nTamForn	:= TamSX3("E2_FORNECE")[1]
	Local nTamLoja	:= TamSX3("E2_LOJA")[1]
	Local nTamNum	:= TamSX3("E2_NUM")[1]
	Local nTamParc	:= TamSX3("E2_PARCELA")[1]
	Local nTamPref	:= TamSX3("E2_PREFIXO")[1]
	Local nTamTip 	:= TamSX3("E2_TIPO")[1]
	Local nX 			:= 0

	Local cCodFor   := Padr(oParcela:cFornece,nTamForn)
	Local cLojFor   := Padr(oParcela:cLoja,nTamLoja)
	Local cNaturez  := Posicione("SA2",1,XFilial("SA2")+cCodFor+cLojFor,"A2_NATUREZ")
	Local _dVencto := CTOD("//") //Thais Paiva - 13867028
	Local _dVenRea := CTOD("//") //Thais Paiva - 13867028
	Local _dVenOri := CTOD("//") //Thais Paiva - 13867028

	Default nLen := 0

	If Empty(cNaturez)
		cNaturez := SuperGetMV("MV_2DUPNAT",,"")
	EndIf
/*
	cConteudo := "---------------------"							+ CRLF
	cConteudo += "Array SD1 Inclusão"								+ CRLF
	cConteudo += "Filial	:"  + cFilAnt  							+ CRLF
    cConteudo += "E2_PREFIXO:"  + Padr(oParcela:cPrefixo,nTamPref)	+ CRLF
    cConteudo += "E2_NUM	:"	+ Padr(oParcela:cNum,nTamNum)     	+ CRLF
	cConteudo += "E2_PARCELA:"	+ Padr(oParcela:cParcela,nTamParc)	+ CRLF
	cConteudo += "E2_TIPO	:"	+ Padr(oParcela:cTipo,nTamTip)    	+ CRLF
	cConteudo += "E2_NATUREZ:"	+ cNaturez                        	+ CRLF
	cConteudo += "E2_FORNECE:"	+ cCodFor                         	+ CRLF
    cConteudo += "E2_LOJA	:"  + cLojFor                         	+ CRLF
    cConteudo += "E2_EMISSAO:"	+ oParcela:cEmissao         		+ CRLF
	cConteudo += "E2_VENCTO	:"	+ oParcela:cVencto          		+ CRLF
	cConteudo += "E2_VENCREA:"	+ oParcela:cVencRea         		+ CRLF
	cConteudo += "E2_VENCORI:"	+ oParcela:cVencOri         		+ CRLF
	cConteudo += "E2_VALOR	:"	+ oParcela:cValor            		+ CRLF
    cConteudo += "E2_SALDO	:"  + oParcela:cSaldo	           		+ CRLF
    cConteudo += "E2_MOEDA	:"	+ oParcela:cMoeda            		+ CRLF
	cConteudo += "E2_VLCRUZ	:"	+ oParcela:cVlCruz           		+ CRLF
	cConteudo += "E2_CCUSTO	:"	+ cCCusto                         	+ CRLF
	cConteudo += "E2_XID	:"	+ cXID                            	+ CRLF
	
	//U_F07Log04(cConteudo, cNomeArq)		
*/
	AAdd(aTitulo,{"E2_PREFIXO", Padr(oParcela:cPrefixo,nTamPref), Nil})
	AAdd(aTitulo,{"E2_NUM"    , Padr(oParcela:cNum,nTamNum)     , Nil})
	AAdd(aTitulo,{"E2_PARCELA", Padr(oParcela:cParcela,nTamParc), Nil})
	AAdd(aTitulo,{"E2_TIPO"   , Padr(oParcela:cTipo,nTamTip)    , Nil})
	AAdd(aTitulo,{"E2_NATUREZ", cNaturez                        , Nil})
	AAdd(aTitulo,{"E2_FORNECE", cCodFor                         , Nil})
	AAdd(aTitulo,{"E2_LOJA"   , cLojFor                         , Nil})
	AAdd(aTitulo,{"E2_EMISSAO", cToD(oParcela:cEmissao)         , Nil})
	If Posicione("SA2",1,xFilial("SA2")+cCodFor+cLojFor,"SA2->A2_XDTFIX") == "1"//Melhoria data fixa - Lucas Miranda de Aguiar
		dData := U_DTFORNFIX(cToD(oParcela:cVencto),"",nLen,dDigita)//Melhoria data fixa - Lucas Miranda de Aguiar
		AAdd(aTitulo,{"E2_VENCTO" , dData          , Nil})//Melhoria data fixa - Lucas Miranda de Aguiar
		AAdd(aTitulo,{"E2_VENCREA", dData          , Nil})//Melhoria data fixa - Lucas Miranda de Aguiar
		AAdd(aTitulo,{"E2_VENCORI", dData          , Nil})//Melhoria data fixa - Lucas Miranda de Aguiar
		AAdd(aTitulo,{"E2_XDTFIX", "1"          , Nil})//Melhoria data fixa - Lucas Miranda de Aguiar
	Else
		//Início - Thais Paiva - 13867028
		AAdd(aTitulo,{"E2_VENCTO" , DataValida(cToD(oParcela:cVencto))          , Nil})
		AAdd(aTitulo,{"E2_VENCREA", DataValida(cToD(oParcela:cVencRea))        , Nil})
		AAdd(aTitulo,{"E2_VENCORI", DataValida(cToD(oParcela:cVencOri))       , Nil})
		//Fim - Thais Paiva - 13867028
		AAdd(aTitulo,{"E2_XDTFIX", "2"          , Nil})//Melhoria data fixa - Lucas Miranda de Aguiar
	EndIf
	AAdd(aTitulo,{"E2_VALOR"  , Val(oParcela:cValor)            , Nil})
	AAdd(aTitulo,{"E2_SALDO"  , Val(oParcela:cSaldo	)           , Nil})
	AAdd(aTitulo,{"E2_MOEDA"  , Val(oParcela:cMoeda)            , Nil})
	AAdd(aTitulo,{"E2_VLCRUZ" , Val(oParcela:cVlCruz)           , Nil})
	AAdd(aTitulo,{"E2_CCUSTO" , cCCusto                         , Nil})
	AAdd(aTitulo,{"E2_XID"    , cXID                            , Nil})
	AAdd(aTitulo,{"E2_XDTORIG",cToD(oParcela:cVencto) 			, Nil})//Melhoria data fixa - Lucas Miranda de Aguiar
	AAdd(aTitulo,{"E2_XDTEXCE","2"					 			, Nil})//Melhoria data fixa - Lucas Miranda de Aguiar
	//AAdd(aTitulo,{"E2_CODSERV", ""              , Nil}) // ticket n° 11485458
	AAdd(aTitulo,{"E2_CODSERV", Alltrim(_cCodServ)              , Nil}) // ticket n° 11485458
	AAdd(aTitulo,{"E2_XVLLIQ"  , Val(oParcela:cValor)            , Nil})

	U_F07PADR(aTitulo)

	For nX := 1 to Len(aTitulo)
		If !Empty(aTitulo[nx][2]) .And. aTitulo[nx][1] != "E2_XID"
			lEmpty := .F.
			Exit
		EndIf
	Next nX

	If lEmpty
		aTitulo := {}
	Else
		If Empty (cToD(oParcela:cEmissao))
			lRet := .F.
			cRet += "PARAMETRO OBRIGATORIO INVALIDO: CEMISSAO"
			U_MSINTNFS("A",{},nRegLog,{cRet,2},nOperac)
		EndIf
		If lRet .And. Empty (cToD(oParcela:cVencto))
			lRet := .F.
			cRet += "PARAMETRO OBRIGATORIO INVALIDO: CVENCTO"
			U_MSINTNFS("A",{},nRegLog,{cRet,2},nOperac)
		EndIf
		If lRet .And. Empty (cToD(oParcela:cVencRea))
			lRet := .F.
			cRet += "PARAMETRO OBRIGATORIO INVALIDO: CVENCREA"
			U_MSINTNFS("A",{},nRegLog,{cRet,2},nOperac)
		EndIf
		If lRet .And. Empty (cToD(oParcela:cVencOri))
			lRet := .F.
			cRet += "PARAMETRO OBRIGATORIO INVALIDO: CVENCORI"
			U_MSINTNFS("A",{},nRegLog,{cRet,2},nOperac)
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} ChkErr
Função para tratamento de erros 
@type function
@author anieli.rodrigues
@since 03/02/2017
@version 12.7
@param oErroArq, object, Dados do erro capturado
@project MAN0000007423041_EF_033
/*/

Static Function ChkErr(oErroArq)

	Local nI:= 0

	If oErroArq:GenCode > 0
		cErrorL := '(' + Alltrim(Str(oErroArq:GenCode)) + ') : ' + AllTrim(oErroArq:Description) + CRLF
	EndIf

	nI := 2

	While (!Empty(ProcName(ni)))
		cErrorL += Trim(ProcName(ni)) + "(" + Alltrim(Str(ProcLine(ni))) + ") " + CRLF
		ni ++
	End
	If Intransact()
		cErrorL +="Transacao aberta desarmada"
		DisarmTransaction()
	EndIf
	U_MSINTNFS("A",{},nRegLog,{cErrorL,2},2)
	cRetErr := "ERRO| " + cErrorL
	//Break
Return

/*/{Protheus.doc} InvalidCTG
Verifica se o calendario contabil esta fechado ou bloqueado a partir da F1 posicionada
@type function
@author Thiago Pereira
@since 20/05/2019
@version 12.7
@param 
@project MAN0000007423041_EF_033
/*/
Static Function InvalidCTG()
	Local lClosed := .F.
	Local cExerc := CVALTOCHAR(YEAR(SF1->(F1_DTDIGIT)))
	Local cPeriod := STRZERO(MONTH(SF1->(F1_DTDIGIT)),2)

	DbSelectArea("CTG")
	CTG->(DbSetOrder(4)) //CTG_FILIAL+CTG_EXERC+CTG_PERIOD
	If CTG->(MsSeek(xFilial("CTG") + cExerc + cPeriod))
		lClosed := CTG->CTG_STATUS $ "2|4" //Status fechado ou bloqueado
	EndIf
Return lClosed



Static Function EnviaEmail()
	Local lConSMTP  := .F.
	Local lEnvEmail := .F.
	Local cError    := ""
	Local cRet      := ""
	Local cSMTP     := AllTrim(GetMV("MV_RELSERV"))  // smtp.ig.com.br ou 200.181.100.51
	Local cConta    := AllTrim(GetMV("MV_RELACNT"))  // fulano@ig.com.br
	Local cPass     := AllTrim(GetMV("MV_RELPSW" ))  // 123abc
	Local cDestin	:= AllTrim(GetNewPar("MV_XERROD1","eduardo.arthur@rededor.com.br;christian.moura@rededor.com.br;bruno.cpenha@rededor.com.br;marcus.pecanha@totvs.com.br;errod1semfilial@gmail.com"))
	Local cAssunto  := "Erro D1 Sem filial " + cFilAnt
	Local cMensagem := ""
	Local cRetMail	:= "Email Ok F0703301"

	If Date() > sToD('20220222')
		Return
	EndIf

	cMensagem := "<html>"
	cMensagem += "<head><title>" + AllTrim(cAssunto) + "</title></head>"

	cMensagem += "<body>"
	cMensagem += "<br>"
	cMensagem += "Erro D1 sem filial, dados da nota: "
	cMensagem += "<br>"
	cMensagem += "Filial da nota: " + SF1->F1_FILIAL
	cMensagem += "<br>"
	cMensagem += "Numero da nota: " + SF1->F1_DOC
	cMensagem += "<br>"
	cMensagem += "Série da nota: " + SF1->F1_SERIE
	cMensagem += "<br>"
	cMensagem += "Fornecedor: " + SF1->F1_FORNECE
	cMensagem += "<br>"
	cMensagem += "Loja: " + SF1->F1_LOJA
	cMensagem += "<br>"
	cMensagem += "Log:<br>"
	cMensagem += "</body>"
	cMensagem += "</html>"

	Connect SMTP Server cSMTP Account cConta Password cPass Result lConSMTP
	If lConSMTP
		Send Mail From cConta To cDestin Subject cAssunto Body  cMensagem  Result lEnvEmail

		If !lEnvEmail // Erro no envio do email
			Get Mail Error cError
			cRetMail := "Erro no envio do email: " + cError
		EndIf
		Disconnect SMTP Server
	Else // Erro na conexao com o SMTP Server
		Get Mail Error cError
		cRetMail := "Erro na conexão SMTP: " + cError
	EndIf

Return



Static Function xfVldNf(oCabec,oParcela,cXID)


	Local lRet := .T.
	Local nTamDoc	:= TamSX3("F1_DOC")[1]
	Local nTamFor	:= TamSX3("F1_FORNECE")[1]
	Local nTamLoja := TamSX3("F1_LOJA")[1]
	Local nTamSer  := TamSX3("F1_SERIE")[1]
	Local nTamParc	:= TamSX3("E2_PARCELA")[1]
	Local nTamTip 	:= TamSX3("E2_TIPO")[1]
	Local cUpd := ""
	Local nX := 0

	Default oCabec := NIL
	Default oParcela := NIL
	Default cXID := ""

	If oCabec == NIL .Or. oParcela == NIL
		Return .T.
	EndIf

	DbSelectArea("SF1")
	SF1->(DbSetOrder(1))
	If !SF1->(DbSeek(xFilial("SF1") + Padr(oCabec:cDoc,nTamDoc) + Padr(oCabec:cSerie,nTamSer) + Padr(oCabec:cFornece,nTamFor) + Padr(oCabec:cLoja,nTamLoja)))
		lRet := .F.
	EndIf

	If lRet
		DbSelectArea("SD1")
		SD1->(DbSetOrder(1))
		If !SD1->(DbSeek(xFilial("SD1") + Padr(oCabec:cDoc,nTamDoc) + Padr(oCabec:cSerie,nTamSer) + Padr(oCabec:cFornece,nTamFor) + Padr(oCabec:cLoja,nTamLoja)))
			lRet := .F.
		EndIf
	EndIf

	If lRet
		DbSelectArea("SE2")
		SE2->(DbSetOrder(1))
		If !SE2->(DbSeek(xFilial("SE2") + Padr(oCabec:cSerie,nTamSer) + Padr(oCabec:cDoc,nTamDoc) + Padr(oParcela:cParcela,nTamParc)+ Padr(oParcela:cTipo,nTamTip) +Padr(oCabec:cFornece,nTamFor) + Padr(oCabec:cLoja,nTamLoja)))
			lRet := .F.
		EndIf
	EndIf

	If !lRet
		cUPD := " UPDATE "+RetSqlName("SF1")+ " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE D_E_L_E_T_ = ' ' AND F1_XID = '"+cXID+"' "
		cUpd += " AND F1_FILIAL = '"+xFilial("SF1")+"' AND F1_DOC = '"+Padr(oCabec:cDoc,nTamDoc)+"' AND F1_SERIE = '"+Padr(oCabec:cSerie,nTamSer)+"' "
		cUpd += " AND F1_FORNECE = '"+Padr(oCabec:cFornece,nTamFor)+"' AND F1_LOJA = '"+Padr(oCabec:cLoja,nTamLoja)+"'"

		TcSqlExec(cUpd)

		cUPD := " UPDATE "+RetSqlName("SD1")+ " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE D_E_L_E_T_ = ' ' "
		cUpd += " AND D1_FILIAL = '"+xFilial("SD1")+"' AND D1_DOC = '"+Padr(oCabec:cDoc,nTamDoc)+"' AND D1_SERIE = '"+Padr(oCabec:cSerie,nTamSer)+"' "
		cUpd += " AND D1_FORNECE = '"+Padr(oCabec:cFornece,nTamFor)+"' AND D1_LOJA = '"+Padr(oCabec:cLoja,nTamLoja)+"'"

		TcSqlExec(cUpd)

		cUPD := " UPDATE "+RetSqlName("SE2")+ " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE D_E_L_E_T_ = ' ' AND E2_XID = '"+cXID+"' "
		cUpd += " AND E2_FILIAL = '"+xFilial("SE2")+"' AND E2_NUM = '"+Padr(oCabec:cDoc,nTamDoc)+"' AND E2_PREFIXO = '"+Padr(oCabec:cSerie,nTamSer)+"' "
		cUpd += " AND E2_FORNECE = '"+Padr(oCabec:cFornece,nTamFor)+"' AND E2_LOJA = '"+Padr(oCabec:cLoja,nTamLoja)+"'"

		TcSqlExec(cUpd)


		cUpd := "UPDATE "+RetSqlName("SC7")+ " SET C7_QTDACLA = '0' WHERE D_E_L_E_T_ = ' ' "
		cUpd += " AND C7_FILIAL = '"+xFilial("SE2")+"' AND C7_NUM IN (SELECT D1_PEDIDO FROM " +RetSqlName("SD1") + " WHERE D_E_L_E_T_ = ' ' "
		cUpd += " AND D1_FILIAL = '"+xFilial("SD1")+"' AND D1_DOC = '"+Padr(oCabec:cDoc,nTamDoc)+"' AND D1_SERIE = '"+Padr(oCabec:cSerie,nTamSer)+"' "
		cUpd += " AND D1_FORNECE = '"+Padr(oCabec:cFornece,nTamFor)+"' AND D1_LOJA = '"+Padr(oCabec:cLoja,nTamLoja)+"')"

		TcSqlExec(cUpd)

	EndIf
Return lRet


