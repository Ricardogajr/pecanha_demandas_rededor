#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "Fileio.ch"
#INCLUDE "TRYEXCEPTION.CH"


#DEFINE C_CRLF     CHR(13) + CHR(10)
#DEFINE N_BUF_SIZE 1024

///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROJETO CONECTA REDE D´OR    |  MODULO | MIGRAÇÃO                           |//
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | MAINCHARGE | AUTOR | Edsonho ®               | DATA |26/07/2017 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | Função: Importação de Arquivos a partir Parametros do Cadastro  |//
//+-----------------------------------------------------------------------------+//
//+ EXEMPLO   | u_RDI003("TN0","\SIGADOC\MIGRAÇÃO\TN0\")                     +//
//+ EXEMPLO   | u_RDI003("TN0","R:\MIGRAÇÃO\TN0\")                           +//
//+-----------------------------------------------------------------------------+//

User Function RDI003(Param1,Param2)

	Local lRet     := .T.
	Local _cArquivo:= " "

	Param1 := AllTrim(QZ1->QZ1_DESTIN)
	Param2 := U_GetDir(101) + AllTrim(QZ1->QZ1_DESTIN) + "\"

	Public oFileTXT
	Public cCodFilial := ""
	Public cCodCC     := ""
	Public aArqsTXT   := {}
	Public nContaLin  := 0
	Public nTotLinha  := 0
	Public cCrLf      := Chr(13)+Chr(10)
	Public aCampos    := {}
	Public aTabSX2    := {}
	Public cTmpTabDB  := ""
	Public cNomTabTMP := ""
	Public cAliasTAB  := Param1
	Public cDeParaFIL := ""
	Public cDeParaCC  := ""
	Public cDesInd    := ""
	Public aValida    := {}
	Public aUniq      := {}
	Public cChave     := ""
	Public cKeyLog    := ""
	Public aDadosKey  := {}
	Public aDadosVLD  := {}
	Public nGravou    := 0
	Public nSeq       := 0
	Public nLinAnt    := 0
	Public nPosInd    := 0
	Public dDataLog   := dDatabase
	Public _Conteudo  := ""
	Public lLOG       := .f.
	Public cCodRetFil := ""
	Public cStatLog   := "OK"
	Public cCNPJ      := ""
	Private aLinhaTXT := {}
	Private aHeaderTXT:= {}
	Private cPathTXT  :=  Param2
	Private nLote     := 0
	Private oProcess
	Private aKeyData  := {}
	Private cXMigLt   := ""
	Private cTabCar   := AllTrim(QZ1->QZ1_DESTIN)


	Public dDtLogIni := Date()
	Public cHrLogIni := Time()

///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Rotina Principal                                                            |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////

	fCHARGE_A()
	lRet := fCHARGE_B(@_cArquivo)

Return lRet
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Seleciona Arquivo(s) TXT                                                    |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fCHARGE_B(_cArquivo)
	Local lRet       := .T.
	Local aArea      := GetArea()
	Local nTXT       := 0
	Local cLotes     := ""
	Local lContinua  := .F.

	If  UPPER(Right(cPathTXT,4)) == ".TXT"
		lContinua := .T.
		aArqsTXT := U_fDirectory(Left(cPathTXT,RAT("\",cPathTXT)),Substr(cPathTXT,RAT("\",cPathTXT)+1),.T.)
	ElseIf U_fExistDir(cPathTXT)
		lContinua := .T.
		aArqsTXT := U_fDirectory(cPathTXT,Upper(Alltrim(cAliasTAB))+"*.TXT",.T.)
	Else
		MsgStop("Sr. Usuário: "+Upper(Alltrim(cUserName))+Chr(13)+" Favor Verificar...","Pasta Não Encontrada"+Chr(13)+cPathTXT)
		return .F.
	EndIf

	If lContinua
		If Len(aArqsTXT) > 0

			aSort(aArqsTXT,,,{|x,y| x[1] < y[1]})

			If IsInCallStack( 'U_RDI008' ) .OR. MsgYesNo("Confirma a Migração de [ "+Alltrim(Str(Len(aArqsTXT)))+" ] Arquivo(s) TXT ???", "Tabela [ "+cNomTabTMP+" ]")

				//fCHARGE_D(cAliasTAB)
				fCHARGE_D(QZ1->QZ1_CODIGO)

				nLote := GetMV('FS_RDI002')
				PutMv("FS_RDI002",++nLote)
				cLotes += "/"+Alltrim(Str(nLote))

				cXMigLt := DToS(dDtLogIni) + " " + cHrLogIni + " KIT" + Strzero(nLote,7)

				For nTXT := 1 To Len(aArqsTXT)

					nTotLinha := U_CountReg(0,aArqsTXT)

					If  UPPER(Right(cPathTXT,4)) == ".TXT"
						cTmpTabDB := u_RDI006(cAliasTAB,cPathTXT)
					Else
						cTmpTabDB := u_RDI006(cAliasTAB,cPathTXT+aArqsTXT[nTXT,1])
					EndIf

					If Empty(cTmpTabDB)
						MsgStop("Não foi possível carregar os dados!"+CRLF+CRLF+"Processamento interrompido.")
						lRet := .F.
						Exit
					Endif

					//fCHARGE_R(nTXT) //rename
					oProcess:= MsNewProcess():New( { || fCHARGE_Z(oProcess,aCampos,cAliasTAB,nTXT,Len(aArqsTXT)) },;
						"["+cAliasTAB+"] Gravando no Banco de Dados "+"[Lote: "+Alltrim(Str(nLote))+"]",,,.T.)
					oProcess:Activate()
					FreeObj(oProcess)

				Next nTXT

				RestArea(aArea)

				U_MoveRead(aArqsTXT,Strzero(nLote,10))

				If nTotLinha > 1 .And. ! IsInCallStack( 'U_RDI008' )
					MsgInfo("Referente à [ "+Alltrim(Str(Len(aArqsTXT)))+" ] Arquivo(s) TXT."+Chr(13)+;
						"Foram Lido(s): "+Alltrim(Transform(nTotLinha, "@E 999,999,999,999"))+" Registro(s)."+Chr(13)+;
						"Numero(s) de Lote(s) Gerado(s): "+cLotes+Chr(13)+Chr(13)+;
						"Sr. Usuário: "+Upper(Alltrim(cUserName))+Chr(13)+" Favor Conferir..","Migração ["+cAliasTAB+"] Finalizado com Sucesso !!!")
				EndIf

			EndIf

			If !Empty(cTmpTabDB) .And. (Select(cTmpTabDB) > 0)
				(cTmpTabDB)->(DbCloseArea())
			Endif

		Else
			MsgStop("Na Pasta [ "+cPathTXT+" ] !!!"+Chr(13)+;
				"Sr. Usuário: "+Upper(Alltrim(cUserName))+Chr(13)+" Favor Verificar..","*** Não Existem Arquivo(s) TXT ***")
			return .F.
		EndIf
	EndIf

	RestArea(aArea)

Return lRet
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Processa Registros                                                          |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fCHARGE_Z(oObj,aCampos,cAliasTAB,nTXT,nTotArqs)

	Local aArea := GetArea()
	Local h          := 0
	Local j          := 0
	Local aLOG       := {}
	Local nLOG       := 0
	Local cHeader    := ""
	Local cCabecTXT  := ""
	Local cEncodeUTF8:= ""
	Local cDecodeUTF8:= ""
	Local nTotOkDB   := 0
	Local cQry       := ""
	Local cDelim     := ";"
	Local cFilOld    := cFilAnt
	Local aUnique    := U_GetUnique(cAliasTAB)
	Local lUnique    := ! Empty(aUnique)
	Local cTabDest   := RetSqlName(cAliasTAB)
	Local nPosFil    := 0
	Local nIdx       := 0
	Local nSaveSx8

	Public cLine     := ''

	If ( Select(cTmpTabDB) > 0)
		(cTmpTabDB)->(dbCloseArea())
	Endif

	cQry := "SELECT * FROM " + cTmpTabDB + " order by numlinha"
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cTmpTabDB, .F., .F.)
	DbSelectArea(cTmpTabDB)
	nContaLin := ContarLinha(cTmpTabDB)

	fCHARGE_Z2(nTXT)

	aHeaderTXT := {}

	(cAliasTAB)->(dbSetOrder(nPosInd))
	If lUnique
		aUniq := AClone(aUnique)
	Else
		aUniq := Separa(Replace(Replace(cDesInd,"DTOS(","" ), ")","") ,"+",.T.)
	Endif

	oObj:SetRegua1(nContaLin) //Alimenta a primeira barra de progresso
	oObj:SetRegua2(0)

	(cTmpTabDB)->(DbGoTop())

	If (AT(chr(165),AllTrim((cTmpTabDB)->LINHAO)) > 0)
		cDelim := Chr(165)
	elseIf (AT(chr(167),AllTrim((cTmpTabDB)->LINHAO)) > 0)
		cDelim := Chr(167)
	Endif

	aLinhaTXT  := {}
	aLinhaTXT  := StrToKArr2(AllTrim((cTmpTabDB)->LINHAO), cDelim, .T. )
	aHeaderTXT := aClone(aLinhaTXT)
	cEncodeUTF8:= EncodeUTF8(cLine)
	cCabecTXT  := cEncodeUTF8
	cHeader    := (cTmpTabDB)->LINHAO

	For h := 1 to  Len(aHeaderTXT)
		If (aScan(aCampos,{|x| x[1] == cAliasTAB .And. aHeaderTXT[h] == Alltrim(x[2])})) == 0
			aAdd(aLOG,{"00000","Campo Não Encontrado no Dicionário Protheus",Alltrim(aHeaderTXT[h]),"","","FIELDPOS()"})
		EndIf
	Next h

//Ajusta o número máximo de nomes a serem reservados pela função MayIUseCode.
	SetMaxCodes( 9999999 )

	nPosFil   := AScan(aHeaderTXT,{|x| Alltrim(x) == Alltrim(aCampos[aScan(aCampos,{|f| f[1] == cAliasTAB .And. "_FILIAL" $ Alltrim(f[2])}),2])})

	nGravou := 0

	DbSelectArea(cTmpTabDB)
	(cTmpTabDB)->(DbSkip())

	DbSelectArea(cTmpTabDB)
	While (cTmpTabDB)->(!Eof())

		oObj:IncRegua1("Processando TXT ["+Alltrim(Str(nTXT))+"/"+Alltrim(Str(nTotArqs))+"] Linha: [ "+Alltrim(Str((cTmpTabDB)->NUMLINHA)) + "/" + Alltrim(Str(nContaLin))+" ]")
		oObj:IncRegua2("Gravando Linha: [ "+Alltrim(Str((cTmpTabDB)->NUMLINHA)) + " ] na Tabela [ "+cAliasTAB+" ]")

		lLOG  := .f.
		aLinhaTXT := {}
		aLinhaTXT := StrToKArr2(AllTrim((cTmpTabDB)->LINHAO), cDelim, .T. )

		//Roberto: força a atualização do código da filial (cCodFilial).
		If "U_RDIBF004" $ cDeParaFIL
			MyRegToMem(cAliasTAB,.t.,.t.,.f.)
			&("M->"+Alltrim((aCampos[aScan(aCampos,{|x| x[1] == cAliasTAB .And. "_FILIAL" $ Alltrim(x[2])}),2]))) := aLinhaTXT[(AScan(aHeaderTXT,{|x| Alltrim(x) == Alltrim((aCampos[aScan(aCampos,{|x| x[1] == cAliasTAB .And. "_FILIAL" $ Alltrim(x[2])}),2]))},,))]
			cCodFilial := &(cDeParaFIL)
		Else
			//cCodFilial := aLinhaTXT[(AScan(aHeaderTXT,{|x| Alltrim(x) == Alltrim((aCampos[aScan(aCampos,{|f| f[1] == cAliasTAB .And. "_FILIAL" $ Alltrim(f[2])}),2]))},,))]
			cCodFilial := aLinhaTXT[nPosFil]
		EndIf
		cFilAnt := cCodFilial //Altera a filial corrente.
		//fim: Roberto.

		If (cTmpTabDB)->NUMLINHA == 1
			If Len(aLOG) > 0
				For nLOG := 1 to  Len(aLOG)
					fCHARGE_Z3(aLOG[nLOG,1],aLOG[nLOG,2],aLOG[nLOG,3],aLOG[nLOG,4],aLOG[nLOG,5],aLOG[nLOG,6])
				Next nLOG
			EndIf
			lLOG := .f.
			DbSelectArea("QZ3")
			If RecLock("QZ3",.f.)
				QZ3->QZ3_FILIAL := xFilial("QZ3") //cCodFilial
				QZ3->QZ3_ARQCAB := cHeader
				QZ3->(MsUnLock())
			EndIF
		EndIf

		If Len(aLinhaTXT) > Len(aHeaderTXT)
			aDel(aLinhaTXT,Len(aLinhaTXT))
			aSize(aLinhaTXT,Len(aHeaderTXT))
		EndIf

		//SetInit()

		If Len(aDadosKey) == 0
			// Consistência de campos Indices
			fCHARGE_F(aHeaderTXT)
		Else
			fCHARGE_K(aDadosKey)  // Consistência de campos Indices
		EndIf

		DbSelectArea(cAliasTAB)
		If lUnique
			lExist := VldUniq(aKeyData,cTabDest)
		Else
			lExist := (cAliasTAB)->(DbSeek(cChave))
		Endif

		If lExist
			fCHARGE_Z3("00001","Chave Duplicada","","",cKeyLog,cDesInd)
		Else
			MyRegToMem(cAliasTAB,.t.,.t.,.f.)
			fCHARGE_VM(aHeaderTXT)   // Carrega Linha para Variavél de Memória
			If Len(aValida) > 0
				If Len(aDadosVLD) == 0
					fCHARGE_M(aHeaderTXT) // Validação Especifica
				Else
					fCHARGE_N(aDadosVLD)  // Validação Especifica
				EndIf
			EndIf
		EndIf

		If !lLOG
			fCHARGE_G()
		EndIf

		DbSelectArea(cTmpTabDB)
		(cTmpTabDB)->(DbSkip())

		nSaveSx8:= GetSx8Len()
		While (GetSX8Len() > nSaveSx8)
			ConfirmSx8()
		End

		FreeUsedCode()

	Enddo

	DbSelectArea("QZ3")
	If RecLock("QZ3",.f.)
		QZ3->QZ3_TOTLIN := nContaLin
		QZ3->QZ3_TOTGRA := nGravou
		QZ3->QZ3_DATAFI := Date()
		QZ3->QZ3_HORAFI := Time()
		QZ3->QZ3_STATLOG := cStatLog
		QZ3->QZ3_BKEY    := GetBKey(1)
		QZ3->(MsUnLock())
	EndIf
	RestArea(aArea)

	cFilAnt := cFilOld

Return
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Capatura Campo e Posição do Indice                                          |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fCHARGE_F(aFields)

	Local nUniq    := 0
	Local nPosUniq := 0
	Local nPosTipo := 0

	For nUniq := 1 to  Len(aUniq)
		If (nPosUniq := AScan(aFields, {|x| Alltrim(x) == Alltrim(aUniq[nUniq])},,)) > 0
			If (nPosTipo := aScan(aCampos,{|x| x[1] == cAliasTAB .And. Alltrim(aUniq[nUniq]) == Alltrim(x[2])})) > 0
				aAdd(aDadosKey,{Alltrim(aUniq[nUniq]),nPosTipo,nPosUniq})
			Endif
		Endif
	Next nUniq

	fCHARGE_K(aDadosKey)

Return
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Capatura Indice e seu Conteúdo                                              |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fCHARGE_K(aDadosKey)

	Local k := 0
	Local cValue := ""

	cChave  := ""
	cKeyLog := ""

	aKeyData := {}

	For k := 1 to  Len(aDadosKey)

		If aCampos[aDadosKey[k,2],3] == "D"
			cValue := Dtos(IIf(At("/",Alltrim(aLinhaTXT[aDadosKey[k,3]])) > 0,Ctod(Alltrim(aLinhaTXT[aDadosKey[k,3]])),Stod(Alltrim(aLinhaTXT[aDadosKey[k,3]]))))
		Else
			cValue := Padr(aLinhaTXT[aDadosKey[k,3]],aCampos[aDadosKey[k,2],4])
		EndIf
		cChave += cValue

		Aadd(aKeyData,{aDadosKey[k,1],cValue,aCampos[aDadosKey[k,2],3]})

		cKeyLog += "["+Alltrim(aDadosKey[k,1])+": "+IIf(aCampos[aDadosKey[k,2],3] == "D",IIf(At("/",Alltrim(aLinhaTXT[aDadosKey[k,3]])) > 0,Alltrim(aLinhaTXT[aDadosKey[k,3]]),Dtoc(Stod(Alltrim(aLinhaTXT[aDadosKey[k,3]])))),Alltrim(aLinhaTXT[aDadosKey[k,3]]))+"] + "
	Next k

Return
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Capatura Validação e seu Conteúdo                                           |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fCHARGE_M(aHeaderTXT)

	Local nVLD     := 0
	Local nPosTipo := 0
	Local nPosALin := 0

	If ! Empty(aValida)
		For nVLD := 1 to Len(aValida)
			If (nPosALin := AScan(aHeaderTXT, {|x| Alltrim(x) == Alltrim(aValida[nVLD,2])},,)) > 0
				If (nPosTipo := aScan(aCampos,{|x| x[1] == cAliasTAB .And. Alltrim(aValida[nVLD,2]) == Alltrim(x[2])})) > 0
					aAdd(aDadosVLD,{Alltrim(aValida[nVLD,2]),nPosTipo,nVLD,nPosALin})
				Endif
			Endif
		Next nVLD

		fCHARGE_N(aDadosVLD)

	EndIf

Return
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Validação Especifica                                                        |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fCHARGE_N(aDadosVLD)

	Local v        := 0
	Local nLenSx3  := 0
	Local nLenVar  := 0
	Local xValor
	Local cCodCpo
	Local cDesCpo
	Local cValida
	Local cCodCpo
	Local cDesCpo
	Local cTipo
	Local cValida
	Local cHelp
	Local lObrigat


	For  v := 1 to  Len(aDadosVLD)

		If aDadosVld[v][1] == 'RA_ESTADO'
			cTeste:= cTeste
		EndIf

		xValor   := aLinhaTXT[aDadosVLD[v,4]] //aLinhaTXT[aDadosVLD[v,4]]
		cCodCpo  := aDadosVLD[v,1] //AllTrim(aCampos[v][2])
		cDesCpo  := Alltrim(aCampos[aDadosVLD[v,2],8]) //AllTrim(aCampos[v][8])
		cValida  := " "

		If VALTYPE(xValor) == 'U'
			xValor := " "
		EndIf

		If ! Empty(aValida[aDadosVLD[v,3],14]) //QZ2_VLDPRO
			cValida := Upper(Alltrim(aValida[aDadosVLD[v,3],14]))
		Endif

		If ! Empty( aValida[aDadosVLD[v,3],3] ) //QZ2_VALIDA
			cValida += If(!Empty(cValida),".AND.","") + Upper(Alltrim(aValida[aDadosVLD[v,3],3]))
		Endif

		cTipo    := aCampos[aDadosVLD[v,2],3] //AllTrim(aCampos[v][3])
		lObrigat := aValida[aDadosVLD[v,3],20] //aValida[aDadosVLD[v,3],20]

		If ( cTipo == "C")
			nLenSx3  := aCampos[aDadosVLD[v,2],4]
			nLenVar  := Len(xValor)
			If (nLenVar >  nLenSx3)
				fCHARGE_Z3("00013",U_FormatStr("O tamanho do conteúdo ({1}) excede a capacidade ({2}) do campo!",{nLenVar,nLenSx3}),cCodCpo,cDesCpo,xValor,cValida)
				Loop
			Endif
		Endif

		If aValida[aDadosVLD[v,3],20] .OR. ( ! Empty(cValida) )
			//cCodCpo,cDesCpo,cTipo,cValida,_Conteudo,cHelp,lObrigat
			aValidData(cCodCpo,cDesCpo,cTipo,cValida,xValor,Nil,lObrigat)
		EndIf
	Next v

Return
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Capatura Valid                                                              |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function aValidData(cCodCpo,cDesCpo,cTipo,cValida,_Conteudo,cHelp,lObrigat)

	Local xRetVLD  := nil
	Local cValid   := cValida
	Local xValue   := _Conteudo

	Local cException := ""
	Local oException := nil
	Local lExcept    := .T.
	Local cCampoM    := ""
	Local cTabsEsp   := GetNewPar("FS_XRDI003","SBZ")

	Private lMsHelpAuto := .T. //Inibe as mensagens da tela.
//Private lMsErroAuto := .T.
//Private lAutoErrNoFile := .T. 


	Public xReadVar  := "M->"+cCodCpo

	If cTabCar $ cTabsEsp
		cCampoM := "M->"+cCodCpo

//Transformando o campo em memória M->, adicionando os espaços em branco de acordo com a SX3
		If Type(cCodCpo) == "C"
			&cCampoM := PADR(&cCampoM,TamSx3(cCodCpo)[1]," ")
		EndIf

	EndIf
	If lObrigat
		Do Case
		Case ( cTipo == "N" )
			xValue := GetDtoVal(StrTran(xValue,",","."))
		Case ( cTipo == "D" )
			If ( "/" $ xValue )
				xValue := CToD(xValue)
			Elseif !Empty(xValue)
				xValue := StoD(xValue)
			Endif
		EndCase

		If Empty(xValue)
			xValue := CriaVar(AllTrim(cCodCpo))
			If Empty(xValue)
				fCHARGE_Z3("00012","Campo obrigatório! Não é Permitido Vazio.",cCodCpo,cDesCpo,_Conteudo,cValida)
				return
			Endif
		Endif
	Endif

	If Empty(cValid)
		return
	Endif

	If !X3USO(GetSX3Cache(cCodCpo, "X3_USADO")) .or. (Empty(_Conteudo) .and. "PERTENCE" $ cValid)
		Return
	EndIf

	If At("EXISTCPO",cValid) > 0
		If At("SX5",cValid) <= 0
			cValid := Replace(cValida,"EXISTCPO(", "U_RDIBF005('"+&("M->"+cCodCpo)+ "', " )
		ENdIf
	EndIf
	If "VAZIO()" $ cValid
		If "NAO" $ cValid
			cValid := StrTran(cValid,("NAOVAZIO()"),"!Empty(M->"+cCodCpo+")")
		Else
			cValid := StrTran(cValid,("VAZIO()"),"Empty(M->"+cCodCpo+")")
		EndIf
	EndIf

	If "POSITIVO()" $ cValid
		cValid := StrTran(cValid,("POSITIVO()"),"(M->"+cCodCpo+">=0)")
	EndIf

	If "MGVALSM0" $ cValid
		cValid := Replace(cValid, "U_MGVALSM0(", "VALIDASM0(" )
	EndIf

	If "EXISTCHAV" $ cValid
		cValid := Replace(cValid, "EXISTCHAV(", "EXISTKEY(" )
	EndIf

	If "VALCTASUP" $ cValid
		cValid := Replace(cValid, "VALCTASUP(", "U_VALCTASUP(" )
	EndIf

	If "PERTENCE" $ cValid
		cValid := Replace(cValid, "PERTENCE (", "PERTENCE(")
		cValid := Replace(cValid, "PERTENCE(", "U_RDIBF001('"+cValToChar(&("M->"+cCodCpo))+"'," )
	EndIf

	If "ENTRE(" $ cValid
		cValid := Replace(cValid, "ENTRE(", "fENTRE(" )
	EndIf

	If "FREEFORUSE" $ cValid
		cValid := Replace(cValid, "FREEFORUSE(", "FREEFORUSE('"+&("M->"+cCodCpo)+"'," )
	EndIf

	If "TEXTO" $  cValid
		cValid := Replace(cValid, "TEXTO(", 'TEXTO('+('M->'+cCodCpo)+',' )
	EndIf

	If "FHIST" $  cValid
		cValid := Replace(cValid, "FHIST(", 'FHIST('+('M->'+cCodCpo)+',' )
	EndIf

	If !Empty(cValid)

		lExcept    := .F.

		TRYEXCEPTION

		xRetVLD := &(cValid)

		CATCHEXCEPTION USING oException
		IF ( ValType( oException ) == "O" )
			lExcept    := .T.
			cException := oException:DESCRIPTION
			oException := nil
		EndIF
		ENDEXCEPTION

		If lExcept
			fCHARGE_Z3("ERROR",Left(cException,100),cCodCpo,cDesCpo,_Conteudo,cValida)
			return
		Endif

		If Valtype(xRetVLD) != "L"
			cValid := xRetVLD
		Else
			If ! xRetVLD
				If "NAOVAZIO()" $ cValida
					fCHARGE_Z3("00003","Não é Permitido Vazio",cCodCpo,cDesCpo,_Conteudo,cValida)
				ElseIf "PERTENCE" $ cValid
					fCHARGE_Z3("00006","Conteúdo Não Pertence",cCodCpo,cDesCpo,_Conteudo,cValida)
				ElseIf "EXISTCPO" $ cValida .Or. "U_RDIBF005" $ cValida
					fCHARGE_Z3("00004","Código Não Cadastrado",cCodCpo,cDesCpo,_Conteudo,cValida)
				ElseIf "VALCTASUP" $ cValida
					fCHARGE_Z3("00007","Conta Contábil Inválida",cCodCpo,cDesCpo,_Conteudo,cValida)
				ElseIf "VALIDASM0" $ cValid
					If cCodRetFil == "00008"
						fCHARGE_Z3("00008","Tabela Compartilhada e o TXT, possui Conteudo",cCodCpo,cDesCpo,_Conteudo,cValida)
					ElseIf cCodRetFil == "00009"
						fCHARGE_Z3("00009","Tabela Exclusiva e o TXT, Não possui Conteudo",cCodCpo,cDesCpo,_Conteudo,cValida)
					ElseIf cCodRetFil == "00010"
						fCHARGE_Z3("00010","Tamanho do Campo Filial Divergente",cCodCpo,cDesCpo,_Conteudo,cValida)
					ElseIf cCodRetFil == "00011"
						fCHARGE_Z3("00011","Filial Inexistente. A filial Informada não existe no cadastro de Empresas",cCodCpo,cDesCpo,_Conteudo,cValida)
					EndIf
				Else
					fCHARGE_Z3("00014","Conteúdo inválido",cCodCpo,cDesCpo,_Conteudo,cValida)
				EndIf
			EndIF
		EndIF
	EndIf
Return

///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Carrega Variavél de Memória                                                 |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fCHARGE_VM(aHeaderTXT)

	Local i := 0
	Local nPosSX3 := 0
	Local nPosCpo := 0
	Local cVar	  := ""

	DbSelectArea(cAliasTAB)
	For i := 1 To Len(aLinhaTXT)
		If !Empty(Alltrim(aLinhaTXT[i]))
			nPosSX3 := 0
			cVar := aLinhaTXT[i]
			If (nPosSX3 := aScan(aCampos,{|x| x[1] == cAliasTAB .And. aHeaderTXT[i] == Alltrim(x[2])})) > 0
				Do Case
				Case  aCampos[nPosSX3,3] == "D"
					&("M->"+(Alltrim(aHeaderTXT[i]))) := IIf(At("/",Alltrim(cVar)) > 0,Ctod(Alltrim(cVar)),Stod(Alltrim(cVar)))
				Case aCampos[nPosSX3,3] == "N"
					cVar := StrTran(cVar,",",".")
					If aCampos[nPosSX3,4] = 5 .And. At(".",Alltrim(cVar)) = 4
						&("M->"+(Alltrim(aHeaderTXT[i]))) := 0
					Else
						&("M->"+(Alltrim(aHeaderTXT[i]))) := NoRound(Val(cVar),aCampos[nPosSX3,5])
					EndIf
				Case aCampos[nPosSX3,3] == "L"
					&("M->"+(Alltrim(aHeaderTXT[i]))) := ("T" $ Upper(cVar))
				OtherWise
					Do Case
					Case "_FILIAL" $ Upper(Alltrim(aHeaderTXT[i]))
						&("M->"+(Alltrim(aHeaderTXT[i]))) := cCodFilial
					Case "_CCC" $ Upper(Alltrim(aHeaderTXT[i])) .OR. "_CCD" $ Upper(Alltrim(aHeaderTXT[i]))
						&("M->"+(Alltrim(aHeaderTXT[i]))) := cCodCC
					Case "A1_CGC" $ Upper(Alltrim(aHeaderTXT[i])) .And. Len(Alltrim(cVar)) < aCampos[nPosSX3,4]
						&("M->"+(Alltrim(aHeaderTXT[i]))) := Padl(Alltrim(cVar),aCampos[nPosSX3,4],"0")
						cCNPJ := cVar
					OtherWise
						&("M->"+(Alltrim(aHeaderTXT[i]))) := cVar
					EndCase
				EndCase
			EndIf
		EndIf
	Next i
/*
For i := 1 To Len(aLinhaTXT)
    If !Empty(Alltrim(aLinhaTXT[i])) 
    	cVar := ""
        nPosCpo := aScan(aValida,{|x| AllTrim(x[2]) == Alltrim(aHeaderTXT[i]) .And. !"_FILIAL" $ Alltrim(x[2])})    
        
        If nPosCpo > 0 
        	If Alltrim(aValida[nPosCpo][2]) <> Alltrim(aValida[nPosCpo][4])
        		cVar := &(aValida[nPosCpo][4])
        		&("M->"+(Alltrim(aHeaderTXT[i]))) := cVar
        	EndIf	
        EndIf    
	EndIf        
Next i
*/ 
	SetInit()

Return
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Grava Registros                                                             |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fCHARGE_G()
	Local j := 0
	Local cPrefixo := Left(aCampos[1,2],AT("_",aCampos[1,2]))
	Local lxmiglt  := ! Empty( TamSx3(cPrefixo + "XMIGLT") )

	DbSelectArea(cAliasTAB)
	RecLock((cAliasTAB),.t.)

	If lxmiglt
		&("M->"+Alltrim(cPrefixo + "XMIGLT")) := cXMigLt
	Endif

	For j := 1 To Len(aCampos)
		**
		If Empty(&("M->"+Alltrim(aCampos[j,2]))) .And. ("_XUSRIN" $ Alltrim(aCampos[j,2]) .OR. "_XUSRAL" $ Alltrim(aCampos[j,2]))
			&("M->"+Alltrim(aCampos[j,2])) := DToS(dDataBase) + " " + Time()
			Loop
		Endif
		**
		&(cAliasTAB+"->"+(Alltrim(aCampos[j,2]))) := &("M->"+Alltrim(aCampos[j,2]))
	Next j

	(cAliasTAB)->(MsUnLock())

	nGravou++

Return
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Grava Header do LOG                                                         |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fCHARGE_Z2(nTXT)

	DbSelectArea("QZ3")
	If RecLock("QZ3",.t.)
		QZ3->QZ3_UKEY    := Upper(Alltrim(cAliasTAB))+"-"+FWTimeStamp(3,dDatabase,Time())+FWTimeStamp(4,dDatabase,Time())
		QZ3->QZ3_NUMLOT := Strzero(nLote,10)
		QZ3->QZ3_CODPRC  := QZ1->QZ1_CODIGO
		QZ3->QZ3_CODTAB  := Upper(Alltrim(cAliasTAB))
		QZ3->QZ3_DATAIN := dDtLogIni
		QZ3->QZ3_HORAIN := Time() //cHrLogIni
		QZ3->QZ3_FRONT   := Upper(Subs(Alltrim(aArqsTXT[nTXT,1]),At("_",Alltrim(aArqsTXT[nTXT,1]))+1,At("_",Subs(Alltrim(aArqsTXT[nTXT,1]),At("_",Alltrim(aArqsTXT[nTXT,1]))+1))-1))
		QZ3->QZ3_ARQUIV := Upper(Alltrim(aArqsTXT[nTXT,1]))
		QZ3->QZ3_DATATX := aArqsTXT[nTXT,3]
		QZ3->QZ3_HORATX := aArqsTXT[nTXT,4]
		QZ3->QZ3_CODUSE := Alltrim(cUserName)
		QZ3->QZ3_AMBIEN := Alltrim(GetEnvServer())
		QZ3->QZ3_TIMSTA := FWTimeStamp(2,Date(),Time())
		QZ3->QZ3_VALIDA  := "S"
		QZ3->QZ3_MAXREC  := U_GetMaxRecno(Upper(Alltrim(cAliasTAB)) )
		If ( QZ3->(FieldPos("QZ3_XMIGLT")) > 0 )
			QZ3->QZ3_XMIGLT := cXMigLt
		Endif
		QZ3->(MsUnLock())
	EndIf
	nSeq := 0

Return
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Grava Detail do LOG                                                         |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fCHARGE_Z3(Param1,Param2,Param3,Param4,Param5,Param6)

	lLOG := .t.

	If nLinAnt == (cTmpTabDB)->NUMLINHA
		nSeq++
	Else
		nLinAnt := (cTmpTabDB)->NUMLINHA
		nSeq := 1
	EndIf

	DbSelectArea("QZ4")
	If RecLock("QZ4",.t.)
		QZ4->QZ4_FILIAL  := xFilial("QZ4") //cCodFilial
		QZ4->QZ4_UKEY    := Upper(Alltrim(cAliasTAB))+"-"+FWTimeStamp(3,Date(),Time())+FWTimeStamp(4,Date(),Time())+Alltrim(Str(nSeq))
		QZ4->QZ4_NUMLOT  := QZ3->QZ3_NUMLOT
		QZ4->QZ4_DATALO  := dDataLog
		QZ4->QZ4_CODTAB  := QZ3->QZ3_CODTAB
		QZ4->QZ4_NUMLIN  := (cTmpTabDB)->NUMLINHA
		QZ4->QZ4_SEQLOG  := nSeq
		QZ4->QZ4_CODCPO  := Param3
		QZ4->QZ4_DESCPO  := Param4
		QZ4->QZ4_CONTEU  := Param5
		QZ4->QZ4_VALID   := Param6
		QZ4->QZ4_UKEYP   := QZ3->QZ3_UKEY
		QZ4->QZ4_CODLOG  := Param1
		QZ4->QZ4_DESCLO  := Param2
		QZ4->QZ4_TIMSTA  := FWTimeStamp(2,Date(),Time())
		QZ4->QZ4_BKEY    := GetBKey(2)
		QZ4->(MsUnLock())
	EndIf
	cStatLog := "LOG"

Return

	******************************
Static Function GetBKey(nTRet)
	******************************
	Local cRet   := ""
	Local cFlds  := ""
	Local cKeys  := ""
	Local nX     := 0
	Local nY     := 0
	Local nLen   := Len(aKeyData)
	Local xValue := nil

	For nY := 1 To nLen

		cFlds += AllTrim(aKeyData[nY,1])
		cKeys += aKeyData[nY,2]

		If (nY < nLen)
			cFlds += ";"
			cKeys += ";"
		Endif
	Next nY

	If     ( nTRet == 1)
		cRet := cFlds
	ElseIF ( nTRet == 2 )
		cRet := cKeys
	Endif

Return cRet

///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Renomeia Arquivos TXT                                                      |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fCHARGE_R(nTXT)

	Local cPathLido := "Lote_"+Alltrim(Str(nLote))+"_"+Dtos(dDtLogIni)+"_"+Replace(cHrLogIni,':',"")+"\"

	If ! U_fExistDir(Upper(cPathTXT+"\LIDOS\"))
		U_fMkWrkDirUpper(cPathTXT+"\LIDOS\")
	EndIf

	If !(U_fExistDir(Upper(cPathTXT+"\LIDOS\"+cPathLido)))
		U_fMkWrkDir(Upper(cPathTXT+"\LIDOS\"+cPathLido))
	EndIf

	__CopyFile(cPathTXT+Upper(Alltrim(aArqsTXT[nTXT,1])),Upper(cPathTXT+"\LIDOS\"+cPathLido)+Upper(Alltrim(aArqsTXT[nTXT,1])))
	fErase(cPathTXT+"\"+Upper(Alltrim(aArqsTXT[nTXT,1])))

Return
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Cria variaveis M-> para uso no modelo3()                                    |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function MyRegToMem(cAlias,lInc,lDic,lInitPad,cStack)

	Local nX  := 0
	Local cCpo:= ""
	Local aArea    := GetArea()
	Local aAreaSX3 := SX3->(GetArea())
	Local aSE1Brw := FWSX3Util():GetAllFields( cAlias , .F. )

	Default lInc := .f.
	Default lDic := .t.
	Default lInitPad := .t.
//Default __HasSNPrvt := ( FindFunction('_SETNAMEDPRVT') )

//If (cStack != NIL ) .And. (! __HasSNPrvt)
	If (cStack != NIL ) .And. (! FindFunction('_SETNAMEDPRVT') )
		UserException( 'Cannot find function _SetNamedPrvt' )
	EndIf

	If lDic
		For nx:=1 To Len(aSE1Brw)
			cCampo:= AllTrim(aSE1Brw[nX])
			DbSelectArea(cAlias)
			If GetSx3Cache( cCampo ,"X3_CONTEXT") == "V" .or. lInc
				If (cStack == NIL )
					If Type("M->"+Trim(GetSx3Cache( cCampo ,"X3_CAMPO")))=='U'
						_SetOwnerPrvt(Trim(GetSx3Cache( cCampo ,"X3_CAMPO")),CriaVar(Trim(GetSx3Cache( cCampo ,"X3_CAMPO")),lInitPad))
					Else
						&("M->"+Trim(GetSx3Cache( cCampo ,"X3_CAMPO"))) := CriaVar(Trim(GetSx3Cache( cCampo ,"X3_CAMPO")),lInitPad)
					EndIf
				Else
					_SetNamedPrvt(Trim(GetSx3Cache( cCampo ,"X3_CAMPO")),CriaVar(Trim(GetSx3Cache( cCampo ,"X3_CAMPO")),lInitPad), cStack)
				EndIf
			Else
				cCpo := (cAlias+"->"+Trim(GetSx3Cache( cCampo ,"X3_CAMPO")))
				If (cStack == NIL)
					If Type("M->"+Trim(GetSx3Cache( cCampo ,"X3_CAMPO")))=='U'
						_SetOwnerPrvt(Trim(GetSx3Cache( cCampo ,"X3_CAMPO")),&cCpo)
					Else
						&("M->"+Trim(GetSx3Cache( cCampo ,"X3_CAMPO"))) := &cCpo
					EndIf
				Else
					_SetNamedPrvt(Trim(GetSx3Cache( cCampo ,"X3_CAMPO")),&cCpo, cStack)
				EndIf
			EndIf
		Next
	Else
		dbSelectArea(cAlias)
		For nX := 1 To FCount()
			cCampo:=FieldName(nX)
			If (lInc)
				cCpo := CriaVar(Trim(FieldName(nX)),lInitPad)
			Else
				cCpo := &("M->"+Trim(FieldName(nX)))
			EndIf
			If (cStack == NIL)
				If Type("M->"+Trim(GetSx3Cache( cCampo ,"X3_CAMPO")))=='U'
					_SetOwnerPrvt(Trim(FieldName(nX)),cCpo)
				Else
					&("M->"+Trim(FieldName(nX))) := cCpo
				EndIf
			Else
				_SetNamedPrvt(Trim(FieldName(nX)),cCpo, cStack)
			EndIf
		Next nX
	EndIf

	RestArea(aAreaSX3)
	RestArea(aArea)

Return(Nil)
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Incrementa Arrays                                                           |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fCHARGE_D(cCodPrc)

	Local cQuery   := ""
	Local nRecPARAM:= 0
	Local aAreaSX3 := SX3->(GetArea())
	Local aSE1Brw  := {}
	Local nx

	cQuery += "Select Distinct "+cCrLf
	cQuery += " QZ1.QZ1_DESTIN,"+cCrLf
//cQuery += " QZ1.QZ1_ORIGEM,"+cCrLf
	cQuery += " QZ1.QZ1_CODIGO,"+cCrLf
	cQuery += " QZ1.R_E_C_N_O_ AS QZ1RECNO,"+cCrLf
	cQuery += " QZ2.QZ2_CODEXT,"+cCrLf
	cQuery += " QZ2.QZ2_SEQ,"+cCrLf
	cQuery += " QZ2.QZ2_CPOORI,"+cCrLf
	cQuery += " QZ2.QZ2_CPODES,"+cCrLf
	cQuery += " QZ2.QZ2_VALIDA,"+cCrLf
	cQuery += " QZ2.QZ2_VLDPRO,"+cCrLf
	cQuery += " QZ2.QZ2_PROVLD,"+cCrLf
	cQuery += " QZ2.QZ2_REJEIT,"+cCrLf
	cQuery += " QZ2.QZ2_DECDES,"+cCrLf
	cQuery += " QZ2.QZ2_OBRDES,"+cCrLf
	cQuery += " QZ2.R_E_C_N_O_ AS QZ2RECNO"+cCrLf
	cQuery += " From "+RetSqlName("QZ1")+" QZ1 "+cCrLf
	cQuery += " Inner Join "+RetSqlName("QZ2")+" QZ2 On "+cCrLf
	cQuery += " QZ1.QZ1_CODIGO = QZ2.QZ2_CODEXT And QZ2.D_E_L_E_T_ = ' ' "+cCrLf
	cQuery += " Where QZ1.D_E_L_E_T_ = ' '  And QZ1.QZ1_CODIGO = '"+cCodPrc+"' "+cCrLf
	cQuery += "Order By QZ1.QZ1_DESTIN,QZ2.QZ2_SEQ"

	_cQuery := ChangeQuery(cQuery)

	If Select("TMPPARAM") > 0
		DbSelectArea("TMPPARAM")
		("TMPPARAM")->(DbCloseArea())
	Endif

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery),"TMPPARAM", .F., .T.)

	DbSelectArea("TMPPARAM")
	TMPPARAM->(DbGotop())
	Count To nRecPARAM

	DbSelectArea("TMPPARAM")
	TMPPARAM->(DbGotop())
	While TMPPARAM->(!Eof())
		aAdd(aValida,;
			{TMPPARAM->QZ1_DESTIN,;
			TMPPARAM->QZ2_CPODES,;
			TMPPARAM->QZ2_VALIDA,;
			TMPPARAM->QZ2_CPOORI,;
			U_GetDir(101) + AllTrim(TMPPARAM->QZ1_DESTIN) + "\",;
			" "                 ,;
			TMPPARAM->QZ1_CODIGO,;
			""                  ,;
			0                   ,;
			""                  ,;
			TMPPARAM->QZ1RECNO,;
			TMPPARAM->QZ2_CODEXT,;
			TMPPARAM->QZ2_SEQ,;
			TMPPARAM->QZ2_VLDPRO,;
			TMPPARAM->QZ2_PROVLD,;
			TMPPARAM->QZ2_REJEIT,;
			TMPPARAM->QZ2_DECDES,;
			TMPPARAM->QZ2_OBRDES,;
			TMPPARAM->QZ2RECNO,;
			(TMPPARAM->QZ2_OBRDES == 'S') })
		//fObrigat(TMPPARAM->QZ2_CPODES)})

		If "U_RDIBF004" $ TMPPARAM->QZ2_CPOORI
			cDeParaFIL := TMPPARAM->QZ2_CPOORI
		EndIf
		If "U_RDIBF003" $ TMPPARAM->QZ2_CPOORI
			cDeParaCC := TMPPARAM->QZ2_CPOORI
		EndIf

		DbSelectArea("TMPPARAM")
		TMPPARAM->(DbSkip())
	EndDo

	aSort(aValida,,,{|x,y| x[2] < y[2]})

	If Select("TMPPARAM") > 0
		DbSelectArea("TMPPARAM")
		("TMPPARAM")->(DbCloseArea())
	Endif

	aSE1Brw := FWSX3Util():GetAllFields( cAliasTAB, .F. )
	If Len(aSE1Brw)>0
		aCampos := {}
		For nx:=1 TO Len(aSE1Brw)
			cCampo:= AllTrim(aSE1Brw[nX])
			If GetSx3Cache( cCampo ,"X3_CONTEXT") <> "V"
				aAdd(aCampos,{GetSx3Cache( cCampo ,"X3_ARQUIVO"),;
					GetSx3Cache( cCampo ,"X3_CAMPO"),;
					GetSx3Cache( cCampo ,"X3_TIPO"),;
					GetSx3Cache( cCampo ,"X3_TAMANHO"),;
					GetSx3Cache( cCampo ,"X3_DECIMAL"),;
					GetSx3Cache( cCampo ,"X3_PICTURE"),;
					GetSx3Cache( cCampo ,"X3_VALID"),;
					GetSx3Cache( cCampo ,"X3_DESCRIC"),;
					fObrigat(GetSx3Cache( cCampo ,"X3_CAMPO"))})
			EndIf
		Next
		aSort(aCampos,,,{|x,y| x[2] < y[2]})

	Else
		MsgStop("Tabela Selecionada [ "+cAliasTAB+" ], Não Encontrado no Dicionário Protheus !!!"+Chr(13)+;
			"Sr. Usuário: "+Upper(Alltrim(cUserName))+Chr(13)+" Favor Verificar..","*** TABELA PROTHEUS INVÁLIDA ***")
	EndIf

	RestArea(aAreaSX3)

Return
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Seleciona Registros da SX2                                                  |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fCHARGE_A()
	Local aAreaSX2 := SX2->(GetArea())

	DbSelectArea("SX2")
	SX2->(DbSetOrder(1))
	SX2->(DbSeek(cAliasTAB))

	//cNomTabTMP := FwSX2Util():GetSX2data(cAliasTAB, {"X2_CHAVE"})[2]	+' - '+Alltrim(FwSX2Util():GetSX2data(cAliasTAB, {"X2_NOME"})[2]	)
	cNomTabTMP := cAliasTAB +' - '+Alltrim(FwSX2Util():GetX2Name( cAliasTAB , .T. ) 	)

	DbSelectArea(cAliasTAB)
	nPosInd := RetIndex(cAliasTAB)
	cDesInd := (cAliasTAB)->(IndexKey())

	RestArea(aAreaSX2)
Return

Static Function VALIDASM0(cTabAtu,cCnt)

	Local aArea		:= GetArea()
	Local cFilAux	:= xFilial(cTabAtu)
	Local lRetor := .f.

	cCodRetFil := ""

	if Empty(Alltrim(cCnt)) .AND.  !Empty(Alltrim(cFilAux))
		cCodRetFil := "00009"
		Return {.F.} //008 - Tabela exclusiva. O arquivo não possui conteúdo.

	EndIf

	if !Empty(Alltrim(cCnt)) .AND.  Empty(Alltrim(cFilAux))
		cCodRetFil := "00008"
		Return {.F.}      // Tabela compartilhada. O arquivo possui conteúdo.

	EndIf

	if len(Alltrim(cCnt)) <>  len(Alltrim(cFilAux))
		cCodRetFil := "00010"
		Return {.F.}  //009 -  Tamanho do campo filial divergente.

	EndIf

	if !Empty(Alltrim(cCnt))

		dbSelectarea('SM0')
		if !SM0->(dbSeek(cEmpAnt+cCnt))
			cCodRetFil := "00011"

			Return {.F.} // 001 - Filial Inexistente. A filial informada não existe no cadastro de empresa.

		EndIf

	EndIf

	RestArea(aArea)

Return {.T.,''}

Static Function ContarLinha(cTmpTabDB)

	Local nCount := 0
	Local cQry := ""
	Local cTempAli := GetNextAlias()

	cQry1 := "SELECT COUNT(1)-1 AS TOTAL FROM " + cTmpTabDB
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry1),cTempAli, .F., .F.)

	nCount := (cTempAli)->TOTAL

	(cTempAli)->(DbCloseArea())

Return nCount

	********************************
Static Function fObrigat(cField)
	********************************
	Local lRet      := .F.
	Local cFileName := "\sigadoc\NoX3Obrigat.txt"
	Local nField    := 0

	Private _aX3Obrigat := NoObrigat(cFileName)

	cField    := AllTrim(cField)

	nField    := AScan(_aX3Obrigat,cField)

	lRet := (nField == 0)
	If lRet
		lRet := X3Obrigat(cField)
	Endif

Return lRet

	************************************
Static Function NoObrigat(cFileName)
	************************************
	Local aRet      := {}
	Local nHandle   := 0
	Local nBuffer   := 1024
	Local cRead     := Space(nBuffer)

	If ( ! File(cFileName) )
		//MSgInfo("Arquivo não encontrado! "+CRLF+CRLF+cFileName)
		return {}
	Endif

	nHandle   := U_OpenFile(cFileName,FO_READ + FO_SHARED)
	If ( nHandle = -1 )
		MSgInfo("Não foi possivel abrir o arquivo "+CRLF+CRLF+cFileName)
		return {}
	Endif

	fSeek(nHandle,0,0) // Posiciona no início do arquivo

	//While (FRead(nHandle,@cRead,nBuffer) > 0)
	While (GetRow(nHandle,@cRead) > 0)
		If ! Empty(cRead)
			Aadd(aRet,AllTrim(cRead))
		Endif
	EndDo

	fClose(nHandle)

Return aRet

	************************************
Static Function GetRow(nHandle,cRow)
	************************************
	Local nBuffer := N_BUF_SIZE
	Local cEOL    := C_CRLF
	Local nRet    := 0
	Local cRead   := Space(nBuffer)
	Local nReturn := 0
	Local nPosEol := 0

	cRow := ""

	While ((nRet += FRead(nHandle,@cRead,nBuffer)) > 0)
		cRow += cRead
		cRead := Space(nBuffer)
		nPosEol := At(cEOL,cRow)
		If (nPosEol != 0)
			cNewRow := Left(cRow,nPosEol - 1)
			nSkip   := Len(cRow) - (Len(cEOL) + Len(cNewRow))
			fSeek(nHandle,(nSkip * -1),FS_RELATIVE) //Volta o ponteiro para o início da próxima linha
			cRow    :=  cNewRow
			Exit
		Endif
	EndDo

Return nRet

	*************************
Static Function SetInit()
	*************************
	Local nLen    := Len(aHeaderTXT)
	Local nX      := 0
	Local cExpr   := ""
	Local nPos    := 0

	For nX := 1 To nLen
		nPos := AScan(aValida,{|v| AllTrim(v[2]) == AllTrim(aHeaderTXT[nX]) .And. AllTrim(v[2])!=AllTrim(v[4]) })
		If nPos > 0
			cExpr := AllTrim(aValida[nPos,4])
			If Left(cExpr,1) == '"' .OR. Left(cExpr,1) == "'"
				aLinhaTXT[nX] := &cExpr
			Endif
		Endif
	Next nX

Return

	************************************
User Function GetUnique(cTabAlias)
	************************************
	Local aRet      := {}
	Local cAlias    := GetNextAlias()
	Local cTable    := RetSqlName(cTabAlias)
	Local cQuery    := ""
	Local aEx       := {"R_E_C_D_E_L_","R_E_C_N_O_","D_E_L_E_T_"}

	If Empty(cTable)
		return {}
	Endif

	cQuery := "select c.COLUMN_NAME              " + CRLF
	cQuery += "from user_ind_columns c           " + CRLF
	cQuery += "where c.table_name = '"+cTable+"' " + CRLF
	cQuery += "and c.INDEX_NAME like '%_UNQ'     " + CRLF
	cQuery += "order by c.COLUMN_POSITION        "

	TCQUERY cQuery NEW ALIAS (cAlias)

	While (cAlias)->(!Eof())
		If ( AScan(aEx, {| f | f == AllTrim((cAlias)->column_name) }) == 0 )
			Aadd(aRet,AllTrim((cAlias)->column_name))
		Endif
		(cAlias)->(DbSkip(1))
	EndDo

	If (Select(cAlias) > 0)
		(cAlias)->(DbCloseArea())
	Endif

Return aRet

	************************************
Static Function VldUniq(aKey,cTable)
	************************************
	Local lRet      := .F.
	Local cAlias    := GetNextAlias()
	Local cQuery    := "SELECT 1 EXISTE FROM "+cTable+" WHERE D_E_L_E_T_=' ' "
	Local nX        := 0
	Local nLenKey   := Len(aKey)
	Local cField    := ""
	Local cValue    := ""

	If Empty(aKey)
		return .F.
	Endif

	For nX := 1 To nLenKey
		cField := aKey[nX,1]
		cValue := aKey[nX,2]
		If aKey[nX,3] == "N"
			cQuery += U_FormatStr(" AND {1}={2}",{cField,StrTran(cValue,",",".")})
		Else
			cQuery += U_FormatStr(" AND {1}='{2}'",{cField,cValue})
		Endif
	Next

	TCQUERY cQuery NEW ALIAS (cAlias)

	lRet := ( (cAlias)->(!Eof()) .And. ( (cAlias)->EXISTE == 1 )  )

	If (Select(cAlias) > 0)
		(cAlias)->(DbCloseArea())
	Endif

Return lRet


	*****************************************************
Static Function existkey(cAlias,cChave,nOrdem,cHelp)
	*****************************************************
	LOCAL xAlias,nSalvReg,nSavOrd,nRegSeek,lRetorno:=.T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega o conteudo da variavel caso nao venha como parametro	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(cChave) = "U"
		cChave :=GetMemVar(xReadVar) //&(ReadVar())
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva o ALIAS do arquivo ativo								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	xAlias := Alias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona o arquivo a ser consultado						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAlias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona a ordem escolhida									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nSavOrd := IndexOrd()
	If nOrdem != NIL
		dbSetOrder(nOrdem)
	else
		dbSetOrder(1)
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva o registro original do arquivo a ser consultado		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If EOF() .Or. RecC() == 0
		nSalvReg := 0
	Else
		nSalvReg := RecN()
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quando seleciona ordem ele salva a ordem original 			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
	Case valtype(cChave) == "D"
		dbSeek(xFilial(cAlias)+DTOS(cChave))
	Otherwise                 
		dbSeek(xFilial(cAlias)+cChave)
	End Case
	If inclui
		If !Found()
			If nSalvReg > 0
				Go nSalvReg
			EndIf
			dbSetOrder(nSavOrd)
			dbSelectArea(xAlias)
			Return .T.
		Else
			lRetorno := .F.
		EndIf
	Else
		If Found()
			nRegSeek := RecNo()
			If nSalvReg > 0
				Go nSalvReg
			EndIf
			dbSetOrder(nSavOrd)
			dbSelectArea(xAlias)
			lRetorno :=Iif( nRegSeek == nSalvReg, .T. , .F. )
		EndIf
	EndIf

	If !lRetorno
		IF cHelp == NIL
			//HELP(2,"JAGRAVADO",STR0001,STR0002) //"Já existe registro com esta informação"###"Troque a chave principal deste registro."
		Else
			//HELP(2,"JAGRAVADO",cHelp,"")
		EndIF
	End

	dbSelectArea(cAlias)
	If nSalvReg > 0
		Go nSalvReg
	EndIf
	dbSetOrder(nSavOrd)
	dbSelectArea(xAlias)
Return lRetorno

	****************************************
User Function RDIBF001(npValor, cpFaixa)
	****************************************
	Local lRet := CValToChar(npValor) $ cpFaixa
Return(lRet)

	*****************************
Static Function fEntre(v1,v2)
	*****************************
	Local xValue := &(xReadVar)
return (xValue >= v1 .And. xValue <= v2)
