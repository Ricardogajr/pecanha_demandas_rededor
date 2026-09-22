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
//+ EXEMPLO   | u_DORCHARGE("TN0","\SIGADOC\MIGRAÇÃO\TN0\")                     +//
//+ EXEMPLO   | u_DORCHARGE("TN0","R:\MIGRAÇÃO\TN0\")                           +//
//+-----------------------------------------------------------------------------+//

User Function DORCHARGE(Param1,Param2)


	Local _cArquivo:= " "

	Param1 := AllTrim(ZVJ->ZVJ_DESTIN)
	Param2 := AllTrim(ZVJ->ZVJ_DIRIMP)

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

	Private lAutoExec  := (Type("__lPackage") == "L" .And. __lPackage)

	Private aLinhaTXT := {}
	Private aHeaderTXT:= {}
	Private cPathTXT  :=  Param2
	Private nLote     := 0
	Private oProcess
	Private aKeyData  := {}

	Public dDtLogIni := Date()
	Public cHrLogIni := Time()
	Public cXMigLt   := ""

///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Rotina Principal                                                            |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////

	fCHARGE_A()
	fCHARGE_B(@_cArquivo)

Return
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Seleciona Arquivo(s) TXT                                                    |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fCHARGE_B(_cArquivo)

	Local aArea:= FWGetArea()
	Local nTXT := 0
	Local cLotes := ""
	Local lContinua := .F.
	Local cIp		:= Alltrim(SuperGetMV('MV_XIMPIP',,''))


	If  UPPER(Right(cPathTXT,4)) == ".TXT"
		lContinua := .T.
		aArqsTXT := fDirectory(Left(cPathTXT,RAT("\",cPathTXT)),Substr(cPathTXT,RAT("\",cPathTXT)+1),.T.)
	ElseIf ExistDir(cPathTXT)
		lContinua := .T.
		aArqsTXT := fDirectory(cPathTXT,Upper(Alltrim(cAliasTAB))+"*.TXT",.T.)
	Else
		MsgStop("Sr. Usuário: "+Upper(Alltrim(cUserName))+Chr(13)+" Favor Verificar...","Pasta Não Encontrada"+Chr(13)+cPathTXT)
	EndIf

	If lContinua
		If Len(aArqsTXT) > 0

			aSort(aArqsTXT,,,{|x,y| x[1] < y[1]})

			If lAutoExec .OR. MsgYesNo("Confirma a Migração de [ "+Alltrim(Str(Len(aArqsTXT)))+" ] Arquivo(s) TXT ???", "Tabela [ "+cNomTabTMP+" ]")

				fCHARGE_D(cAliasTAB)

				nLote := GetMV('DOR_CHARGE')
				PutMv("DOR_CHARGE",++nLote)
				cLotes += "/"+Alltrim(Str(nLote))

				cXMigLt := DToS(dDtLogIni) + " " + cHrLogIni + " " + Strzero(nLote,10)

				For nTXT := 1 To Len(aArqsTXT)

					nTotLinha := CountReg(0,aArqsTXT)

					If  UPPER(Right(cPathTXT,4)) == ".TXT"
						cTmpTabDB := u_IMPTAB2(cAliasTAB,cPathTXT)
					Else
						//cTmpTabDB := u_IMPTAB2(cAliasTAB,STRTRAN(cPathTXT,"R:\","\SIGADOC\")+aArqsTXT[nTXT,1])
						cTmpTabDB := u_IMPTAB2(cAliasTAB,cPathTXT+aArqsTXT[nTXT,1])
					EndIf

					If Empty(cTmpTabDB)
						MsgStop("Não foi possível carregar os dados!"+CRLF+CRLF+"Processamento interrompido.")
						Exit
					Endif

					//fCHARGE_R(nTXT) //rename
					oProcess:= MsNewProcess():New( { || fCHARGE_Z(oProcess,aCampos,cAliasTAB,nTXT,Len(aArqsTXT)) },;
						"["+cAliasTAB+"] Gravando no Banco de Dados "+"[Lote: "+Alltrim(Str(nLote))+"]",,,.T.)
					oProcess:Activate()
					FreeObj(oProcess)

				Next nTXT

				FWRestArea(aArea)

				If nTotLinha > 1 .And. !lAutoExec
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
		EndIf


	EndIf

	FWRestArea(aArea)

Return
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Processa Registros                                                          |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fCHARGE_Z(oObj,aCampos,cAliasTAB,nTXT,nTotArqs)

	Local aArea := FWGetArea()
	Local h := 0
	Local j := 0
	Local aLOG := {}
	Local nLOG := 0
	Local cHeader    := ""
	Local cCabecTXT  := ""
	Local cEncodeUTF8:= ""
	Local cDecodeUTF8:= ""
	Local nTotOkDB   := 0
	Local cQry       := ""
	Local cDelim     := ";"
	Local cFilOld    := cFilAnt
	Local aUnique    := GetUnique(cAliasTAB)
	Local lUnique    := !Empty(aUnique)
	Local cTabDest   := RetSqlName(cAliasTAB)

	Public cLine     := ''

	If ( Select(cTmpTabDB) > 0)
		(cTmpTabDB)->(dbCloseArea())
	Endif

	cQry := "SELECT * FROM " + cTmpTabDB + " order by numlinha"
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cTmpTabDB, .F., .F.)
//DbUseArea(.T.,"TOPCONN",cTmpTabDB,cTmpTabDB,.f.,.f.) 
	DbSelectArea(cTmpTabDB)
//(cTmpTabDB)->(DbGoBottom())
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

		If "U_MGSM0DP1" $ cDeParaFIL
			MyRegToMem(cAliasTAB,.t.,.t.,.f.)
			&("M->"+Alltrim((aCampos[aScan(aCampos,{|x| x[1] == cAliasTAB .And. "_FILIAL" $ Alltrim(x[2])}),2]))) := aLinhaTXT[(AScan(aHeaderTXT,{|x| Alltrim(x) == Alltrim((aCampos[aScan(aCampos,{|x| x[1] == cAliasTAB .And. "_FILIAL" $ Alltrim(x[2])}),2]))},,))]
			cCodFilial := &(cDeParaFIL)
		Else
			cCodFilial := aLinhaTXT[(AScan(aHeaderTXT,{|x| Alltrim(x) == Alltrim((aCampos[aScan(aCampos,{|f| f[1] == cAliasTAB .And. "_FILIAL" $ Alltrim(f[2])}),2]))},,))]
		EndIf
		cFilAnt := cCodFilial //Altera a filial corrente.

		If (cTmpTabDB)->NUMLINHA == 1
			If Len(aLOG) > 0
				For nLOG := 1 to  Len(aLOG)
					fCHARGE_Z3(aLOG[nLOG,1],aLOG[nLOG,2],aLOG[nLOG,3],aLOG[nLOG,4],aLOG[nLOG,5],aLOG[nLOG,6])
				Next nLOG
			EndIf
			lLOG := .f.
			DbSelectArea("SZ2")
			RecLock("SZ2",.f.)
			SZ2->Z2_FILIAL := xFilial("SZ2") //cCodFilial
			SZ2->Z2_ARQCAB := cHeader
			SZ2->(MsUnLock())
		EndIf

		If Len(aLinhaTXT) > Len(aHeaderTXT)
			aDel(aLinhaTXT,Len(aLinhaTXT))
			aSize(aLinhaTXT,Len(aHeaderTXT))
		EndIf

//  SetInit()

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

	Enddo

	DbSelectArea("SZ2")
	RecLock("SZ2",.f.)
	SZ2->Z2_TOTLINH := nContaLin
	SZ2->Z2_TOTGRAV := nGravou
	SZ2->Z2_DATAFIM := Date()
	SZ2->Z2_HORAFIM := Time()
	SZ2->Z2_STATLOG := cStatLog
	SZ2->(MsUnLock())

	FWRestArea(aArea)

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

		xValor   := aLinhaTXT[aDadosVLD[v,4]]
		cCodCpo  := aDadosVLD[v,1] //AllTrim(aCampos[v][2])
		cDesCpo  := Alltrim(aCampos[aDadosVLD[v,2],8]) //AllTrim(aCampos[v][8])
		cValida  := Upper(Alltrim(aValida[aDadosVLD[v,3],3])) //Upper(Alltrim(AllTrim(aCampos[v][7])))
		cTipo    := aCampos[aDadosVLD[v,2],3] //AllTrim(aCampos[v][3])
		lObrigat := aValida[aDadosVLD[v,3],20] //aValida[aDadosVLD[v,3],20]

		If ( cTipo == "C")
			nLenSx3  := aCampos[aDadosVLD[v,2],4]
			nLenVar  := Len(xValor)
			If (nLenVar >  nLenSx3)
				fCHARGE_Z3("00013",U_FmtStr("O tamanho do conteúdo ({1}) excede a capacidade ({2}) do campo!",{nLenVar,nLenSx3}),cCodCpo,cDesCpo,xValor,cValida)
				Loop
			Endif
		Endif

		If aValida[aDadosVLD[v,3],20] .OR. ( ! Empty(Upper(Alltrim(aValida[aDadosVLD[v,3],3]))) )
			//cCodCpo,cDesCpo,cTipo,cValida,_Conteudo,cHelp,lObrigat
			//aValidData(aDadosVLD[v,1],Alltrim(aCampos[aDadosVLD[v,2],8]),aCampos[aDadosVLD[v,2],3],Upper(Alltrim(aValida[aDadosVLD[v,3],3])),aLinhaTXT[aDadosVLD[v,4]],Nil,aValida[aDadosVLD[v,3],20])
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

	Local lRetVLD  := .f.
	Local cValid   := cValida
	Local xValue   := cValToChar(_Conteudo)
	Local xRetVld
	Local lExcept    := .F.

	If lObrigat
		Do Case
		Case ( cTipo == "N" )
			xValue := GetDtoVal(xValue)
		Case ( cTipo == "D" )
			If ( "/" $ xValue )
				If (AT('/',xValue) > 0)
					xValue := CToD(xValue)
				Else
					xValue := SToD(xValue)
				Endif
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

	If At("EXISTCPO",cValid) > 0
		cValid := Replace(cValida,"EXISTCPO(", "U_EXISTCPO('"+&("M->"+cCodCpo)+"'," )
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
		cValid := Replace(cValid, "EXISTCHAV(", "U_EXISTCHAV(" )
	EndIf
	If "VALCTASUP" $ cValid
		cValid := Replace(cValid, "VALCTASUP(", "U_VALCTASUP(" )
	EndIf
	If "PERTENCE" $ cValid
		cValid := Replace(cValid, "PERTENCE(", "U_PERTENCE('"+&("M->"+cCodCpo)+"'," )
	EndIf
	If "FREEFORUSE" $ cValid
		cValid := Replace(cValid, "FREEFORUSE(", "FREEFORUSE('"+&("M->"+cCodCpo)+"'," )
	EndIf

	If !Empty(cValid)

//    xRetVld := &(cValid)

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


		If Valtype(xRetVld) = "C"
			cValid := xRetVld
		Else
			lRetVLD := xRetVld
			If !lRetVLD
				If cHelp == NIL
					//HELP
				Else
					//HELP
				EndIF
				If cTipo == "N"
					fCHARGE_Z3("00002","Não é Permitido Valor Zero",cCodCpo,cDesCpo,_Conteudo,cValida)
				Else
					If "NAOVAZIO()" $ cValida
						fCHARGE_Z3("00003","Não é Permitido Vazio",cCodCpo,cDesCpo,_Conteudo,cValida)
					ElseIf "EXISTCPO" $ cValida .Or. "U_VLDCOD" $ cValida
						fCHARGE_Z3("00004","Código Não Cadastrado",cCodCpo,cDesCpo,_Conteudo,cValida)
					ElseIf "EXISTCHAV" $ cValid
						fCHARGE_Z3("00005","Já Existe Registro com esta Informação",cCodCpo,cDesCpo,_Conteudo,cValida)
					ElseIf "PERTENCE" $ cValid
						fCHARGE_Z3("00006","Conteúdo Não Pertence",cCodCpo,cDesCpo,_Conteudo,cValida)
					ElseIf "VALCTASUP" $ cValid
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
					EndIf
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
						&("M->"+(Alltrim(aHeaderTXT[i]))) := PADR(cVar,aCampos[nPosSX3,4])
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

	DbSelectArea("SZ2")
	RecLock("SZ2",.t.)
	SZ2->Z2_UKEY    := Upper(Alltrim(cAliasTAB))+"-"+FWTimeStamp(3,dDatabase,Time())+FWTimeStamp(4,dDatabase,Time())
	SZ2->Z2_NUMLOTE := Strzero(nLote,10)
	SZ2->Z2_CODPRC  := ZVJ->ZVJ_CODIGO
	SZ2->Z2_CODTAB  := Upper(Alltrim(cAliasTAB))
	SZ2->Z2_DATAINI := dDtLogIni
	SZ2->Z2_HORAINI := Time() //cHrLogIni
	SZ2->Z2_FRONT   := Upper(Subs(Alltrim(aArqsTXT[nTXT,1]),At("_",Alltrim(aArqsTXT[nTXT,1]))+1,At("_",Subs(Alltrim(aArqsTXT[nTXT,1]),At("_",Alltrim(aArqsTXT[nTXT,1]))+1))-1))
	SZ2->Z2_ARQUIVO := Upper(Alltrim(aArqsTXT[nTXT,1]))
	SZ2->Z2_DATATXT := aArqsTXT[nTXT,3]
	SZ2->Z2_HORATXT := aArqsTXT[nTXT,4]
	SZ2->Z2_CODUSER := Alltrim(cUserName)
	SZ2->Z2_AMBIENT := Alltrim(GetEnvServer())
	SZ2->Z2_TIMSTAM := FWTimeStamp(2,Date(),Time())
	SZ2->Z2_VALIDA  := "S"
	SZ2->Z2_MAXREC  := GetMaxRecno(Upper(Alltrim(cAliasTAB)) )
	If ( SZ2->(FieldPos("Z2_XMIGLT")) > 0 )
		SZ2->Z2_XMIGLT := cXMigLt
	Endif
	SZ2->(MsUnLock())

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

	DbSelectArea("SZ3")
	RecLock("SZ3",.t.)
	SZ3->Z3_FILIAL  := xFilial("SZ3") //cCodFilial
	SZ3->Z3_UKEY    := Upper(Alltrim(cAliasTAB))+"-"+FWTimeStamp(3,Date(),Time())+FWTimeStamp(4,Date(),Time())+Alltrim(Str(nSeq))
	SZ3->Z3_NUMLOTE := SZ2->Z2_NUMLOTE
	SZ3->Z3_DATALOG := dDataLog
	SZ3->Z3_CODTAB  := SZ2->Z2_CODTAB
	SZ3->Z3_NUMLINH := (cTmpTabDB)->NUMLINHA
	SZ3->Z3_SEQLOG  := nSeq
	SZ3->Z3_CODCPO  := Param3
	SZ3->Z3_DESCPO  := Param4
	SZ3->Z3_CONTEUD := Param5
	SZ3->Z3_VALID   := Param6
	SZ3->Z3_UKEYP   := SZ2->Z2_UKEY
	SZ3->Z3_CODLOG  := Param1
	SZ3->Z3_DESCLOG := Param2
	SZ3->Z3_TIMSTAM := FWTimeStamp(2,Date(),Time())
	SZ3->(MsUnLock())

	cStatLog := "LOG"

Return

///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Renomeia Arquivos TXT                                                      |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fCHARGE_R(nTXT)

	Local cPathLido := "Lote_"+Alltrim(Str(nLote))+"_"+Dtos(dDtLogIni)+"_"+Replace(cHrLogIni,':',"")+"\"

	If !(ExistDir(Upper(cPathTXT+"\LIDOS\")))
		Makedir(Upper(cPathTXT+"\LIDOS\"))
	EndIf
	If !(ExistDir(Upper(cPathTXT+"\LIDOS\"+cPathLido)))
		Makedir(Upper(cPathTXT+"\LIDOS\"+cPathLido))
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
	Local aArea    := FWGetArea()
	Local aAreaSX3 := SX3->(FWGetArea())
	Local _aCmpX3 := {}
	Default lInc := .f.
	Default lDic := .t.
	Default lInitPad := .t.
//Default __HasSNPrvt := ( FindFunction('_SETNAMEDPRVT') )

//If (cStack != NIL ) .And. (! __HasSNPrvt)
	If (cStack != NIL ) .And. (! FindFunction('_SETNAMEDPRVT') )
		UserException( 'Cannot find function _SetNamedPrvt' )
	EndIf

	If lDic
		//DbSelectArea("SX3")
		//DbSetOrder(1)
		_aCmpX3 := FWSX3Util():GetAllFields(cAlias , .T. )
		For nX := 1 to Len(_aCmpX3) //While SX3->(!Eof()) .and. SX3->X3_ARQUIVO == cAlias
			//DbSelectArea(cAlias)
			If GetSx3Cache(_aCmpX3[nX], 'X3_CONTEXT') == "V" .or. lInc
				If (cStack == NIL )
					If Type("M->"+Trim(GetSx3Cache(_aCmpX3[nX], 'X3_CAMPO')))=='U'
						_SetOwnerPrvt(Trim(GetSx3Cache(_aCmpX3[nX], 'X3_CAMPO')),CriaVar(Trim(GetSx3Cache(_aCmpX3[nX], 'X3_CAMPO')),lInitPad))
					Else
						&("M->"+Trim(GetSx3Cache(_aCmpX3[nX], 'X3_CAMPO'))) := CriaVar(Trim(GetSx3Cache(_aCmpX3[nX], 'X3_CAMPO')),lInitPad)
					EndIf
				Else
					_SetNamedPrvt(Trim(GetSx3Cache(_aCmpX3[nX], 'X3_CAMPO')),CriaVar(Trim(GetSx3Cache(_aCmpX3[nX], 'X3_CAMPO')),lInitPad), cStack)
				EndIf
			Else
				cCpo := (cAlias+"->"+Trim(GetSx3Cache(_aCmpX3[nX], 'X3_CAMPO')))
				If (cStack == NIL)
					If Type("M->"+Trim(GetSx3Cache(_aCmpX3[nX], 'X3_CAMPO')))=='U'
						_SetOwnerPrvt(Trim(GetSx3Cache(_aCmpX3[nX], 'X3_CAMPO')),&cCpo)
					Else
						&("M->"+Trim(GetSx3Cache(_aCmpX3[nX], 'X3_CAMPO'))) := &cCpo
					EndIf
				Else
					_SetNamedPrvt(Trim(GetSx3Cache(_aCmpX3[nX], 'X3_CAMPO')),&cCpo, cStack)
				EndIf
			EndIf
			//DbSelectArea("SX3")
			//SX3->(DbSkip())
		Next nX //EndDo
	Else
		dbSelectArea(cAlias)
		For nX := 1 To FCount()
			If (lInc)
				cCpo := CriaVar(Trim(FieldName(nX)),lInitPad)
			Else
				cCpo := &("M->"+Trim(FieldName(nX)))
			EndIf
			If (cStack == NIL)
				If Type("M->"+Trim(GetSx3Cache(FieldName(nX), 'X3_CAMPO')))=='U'
					_SetOwnerPrvt(Trim(FieldName(nX)),cCpo)
				Else
					&("M->"+Trim(FieldName(nX))) := cCpo
				EndIf
			Else
				_SetNamedPrvt(Trim(FieldName(nX)),cCpo, cStack)
			EndIf
		Next nX
	EndIf

	FWRestArea(aAreaSX3)
	FWRestArea(aArea)

Return(Nil)
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Incrementa Arrays                                                           |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fCHARGE_D(cAliasTAB)
	Local _aCmpX3 := {}
	Local cQuery   := ""
	Local nRecPARAM:= 0
	Local aAreaSX3 := SX3->(FWGetArea())
	Local nX := 0
	cQuery += "Select Distinct "+cCrLf
	cQuery += " ZVJ.ZVJ_DESTIN,"+cCrLf
	cQuery += " ZVJ.ZVJ_ORIGEM,"+cCrLf
	cQuery += " ZVJ.ZVJ_CODIGO,"+cCrLf
	cQuery += " ZVJ.ZVJ_REJEIT,"+cCrLf
	cQuery += " ZVJ.ZVJ_INDORI,"+cCrLf
	cQuery += " ZVJ.ZVJ_CHVPSQ,"+cCrLf
	cQuery += " ZVJ.ZVJ_DIRIMP,"+cCrLf
	cQuery += " ZVJ.R_E_C_N_O_ AS ZVJRECNO,"+cCrLf
	cQuery += " ZVK.ZVK_CODEXT,"+cCrLf
	cQuery += " ZVK.ZVK_SEQ,"+cCrLf
	cQuery += " ZVK.ZVK_CPOORI,"+cCrLf
	cQuery += " ZVK.ZVK_CPODES,"+cCrLf
	cQuery += " ZVK.ZVK_VALIDA,"+cCrLf
	cQuery += " ZVK.ZVK_VLDPRO,"+cCrLf
	cQuery += " ZVK.ZVK_PROVLD,"+cCrLf
	cQuery += " ZVK.ZVK_REJEIT,"+cCrLf
	cQuery += " ZVK.ZVK_DECDES,"+cCrLf
	cQuery += " ZVK.ZVK_OBRDES,"+cCrLf
	cQuery += " ZVK.R_E_C_N_O_ AS ZVKRECNO"+cCrLf
	cQuery += " From "+RetSqlName("ZVJ")+" ZVJ "+cCrLf
	cQuery += " Inner Join "+RetSqlName("ZVK")+" ZVK On "+cCrLf
	cQuery += " ZVJ.ZVJ_CODIGO = ZVK.ZVK_CODEXT And ZVK.D_E_L_E_T_ = ' ' "+cCrLf
	cQuery += " Where ZVJ.D_E_L_E_T_ = ' '  And ZVJ.ZVJ_DESTIN = '"+cAliasTAB+"' And ZVJ.ZVJ_DIRIMP <> ' ' "+cCrLf
	cQuery += "Order By ZVJ_ORIGEM,ZVK.ZVK_SEQ"

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
			{TMPPARAM->ZVJ_DESTIN,;
			TMPPARAM->ZVK_CPODES,;
			TMPPARAM->ZVK_VALIDA,;
			TMPPARAM->ZVK_CPOORI,;
			TMPPARAM->ZVJ_DIRIMP,;
			TMPPARAM->ZVJ_ORIGEM,;
			TMPPARAM->ZVJ_CODIGO,;
			TMPPARAM->ZVJ_REJEIT,;
			TMPPARAM->ZVJ_INDORI,;
			TMPPARAM->ZVJ_CHVPSQ,;
			TMPPARAM->ZVJRECNO,;
			TMPPARAM->ZVK_CODEXT,;
			TMPPARAM->ZVK_SEQ,;
			TMPPARAM->ZVK_VLDPRO,;
			TMPPARAM->ZVK_PROVLD,;
			TMPPARAM->ZVK_REJEIT,;
			TMPPARAM->ZVK_DECDES,;
			TMPPARAM->ZVK_OBRDES,;
			TMPPARAM->ZVKRECNO,;
			fObrigat(TMPPARAM->ZVK_CPODES)})

		If "U_MGSM0DP1" $ TMPPARAM->ZVK_CPOORI
			cDeParaFIL := TMPPARAM->ZVK_CPOORI
		EndIf
		If "U_MGCTTDP1" $ TMPPARAM->ZVK_CPOORI
			cDeParaCC := TMPPARAM->ZVK_CPOORI
		EndIf

		DbSelectArea("TMPPARAM")
		TMPPARAM->(DbSkip())
	EndDo

	aSort(aValida,,,{|x,y| x[2] < y[2]})

	If Select("TMPPARAM") > 0
		DbSelectArea("TMPPARAM")
		("TMPPARAM")->(DbCloseArea())
	Endif

	//DbSelectArea("SX3")
	//SX3->(DbSetOrder(1))
	_aCmpX3 := FWSX3Util():GetAllFields(cAliasTAB, .F. )
	If Len(_aCmpX3) > 0 //SX3->(DbSeek(cAliasTAB))
		aCampos := {}
		For nX := 1 to Len(_aCmpX3) //While SX3->X3_ARQUIVO == cAliasTAB .And. SX3->(!Eof())
			//If SX3->X3_CONTEXT <> "V"
				aAdd(aCampos,{GetSx3Cache(_aCmpX3[nX], 'X3_ARQUIVO'),;
					GetSx3Cache(_aCmpX3[nX], 'X3_CAMPO'),;
					GetSx3Cache(_aCmpX3[nX], 'X3_TIPO'),;
					GetSx3Cache(_aCmpX3[nX], 'X3_TAMANHO'),;
					GetSx3Cache(_aCmpX3[nX], 'X3_DECIMAL'),;
					GetSx3Cache(_aCmpX3[nX], 'X3_PICTURE'),;
					GetSx3Cache(_aCmpX3[nX], 'X3_VALID'),;
					GetSx3Cache(_aCmpX3[nX], 'X3_DESCRIC'),;
					fObrigat(GetSx3Cache(_aCmpX3[nX], 'X3_CAMPO'))})
			//EndIf
			//SX3->(DbSkip())
		Next nX //EndDo

		aSort(aCampos,,,{|x,y| x[2] < y[2]})

	Else
		MsgStop("Tabela Selecionada [ "+cAliasTAB+" ], Não Encontrado no Dicionário Protheus !!!"+Chr(13)+;
			"Sr. Usuário: "+Upper(Alltrim(cUserName))+Chr(13)+" Favor Verificar..","*** TABELA PROTHEUS INVÁLIDA ***")
	EndIf

	FWRestArea(aAreaSX3)

Return
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Seleciona Registros da SX2                                                  |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fCHARGE_A()
	Local aReturn := {}
	Local aAreaSX2 := SX2->(FWGetArea())

	//DbSelectArea("SX2")
	//SX2->(DbSetOrder(1))
	aReturn:= FwSX2Util():GetSX2data(cAliasTAB, {"X2_CHAVE","X2_NOME"})  //SX2->(DbSeek(cAliasTAB))
	cNomTabTMP := aReturn[1][2]+' - '+Alltrim(aReturn[2][2])
	DbSelectArea(cAliasTAB)
	nPosInd := RetIndex(cAliasTAB)
	cDesInd := (cAliasTAB)->(IndexKey())

	FWRestArea(aAreaSX2)

Return

Static Function VALIDASM0(cTabAtu,cCnt)

	Local aArea		:= FWGetArea()
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

	FWRestArea(aArea)

Return {.T.,''}
/*
User Function MIGRATXT()

Rpcsetenv('01','01010001')
u_DORCHARGE("SD3","C:\MIGRACAO\SD3\")

Return
*/

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

	If cField == "ACV_GRUPO"
		Return .F.
	EndIf
   
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

	nHandle   := FOpen(cFileName,FO_READ + FO_SHARED)
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
			//If Left(cExpr,1) == '"' .OR. Left(cExpr,1) == "'"
			aLinhaTXT[nX] := &(cExpr)
			//Endif
		Endif
	Next nX

Return

	************************************
Static Function GetUnique(cTabAlias)
	************************************
	Local aRet      := {}
	Local cAlias    := GetNextAlias()
	Local cTable    := RetSqlName(cTabAlias)
	Local cQuery    := ""
	Local aEx       := {"R_E_C_D_E_L_","R_E_C_N_O_","D_E_L_E_T_"}

	If Empty(cTable)
		return {}
	Endif

	cQuery += "SELECT c.column_name                       " + CRLF
	cQuery += "  FROM user_indexes i, user_ind_columns c  " + CRLF
	cQuery += " WHERE i.table_name  = '"+cTable+"'        " + CRLF
	cQuery += "   AND i.uniqueness  = 'UNIQUE'            " + CRLF
	cQuery += "   AND i.index_name  = c.index_name        " + CRLF
	cQuery += "   AND i.table_name  = c.table_name        " + CRLF
	cQuery += "ORDER BY c.column_position                 "


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
			cQuery += U_FmtStr(" AND {1}={2}",{cField,cValue})
		Else
			cQuery += U_FmtStr(" AND {1}='{2}'",{cField,cValue})
		Endif
	Next

	TCQUERY cQuery NEW ALIAS (cAlias)

	lRet := ( (cAlias)->(!Eof()) .And. ( (cAlias)->EXISTE == 1 )  )

	If (Select(cAlias) > 0)
		(cAlias)->(DbCloseArea())
	Endif

Return lRet

**********************************************
Static Function fDirectory(cPath,cMask,lCount)
**********************************************
   Local cServer:= Alltrim(SuperGetMV('MV_XIMPIP',,''))
   Local aRet   := Directory(cPath + cMask)
   Local bExec  := {|| Aeval(aRet,{|x| ASize(x,Len(x)+2), x[Len(x)-1] := cPath + AllTrim(x[1]), x[Len(x)] := If(lCount,(GetLastRec( x[Len(x)-1] )-1),0) }) }
   
   Default lCount := .T.

   MsgRun('Obtendo informações do(s) arquivo(s)...',"Aguarde...",bExec)   

Return aRet   

*************************************
Static Function CountReg(nIdx,aFiles)
*************************************
    Local nRet := 0
    
    Default nIdx := 0
     
    If (nIdx > 0)
       nRet := aFiles[nIdx,Len(aFiles[nIdx])]
    Else 
       AEval(aFiles,{|x| nRet += x[Len(x)]})
    Endif 
    
Return nRet

***********************************
Static Function GetMaxRecno(cAlias)
***********************************
   Local cTable    := RetSqlName(cAlias)
   Local nRet      := 1
   Local cQuery    := "SELECT MAX(R_E_C_N_O_) RECNO FROM "+cTable
   Local cAliasTmp := GetNextAlias()

   If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif
   
   TCQUERY cQuery NEW ALIAS (cAliasTmp)
   
   If (cAliasTmp)->(!Eof())
      nRet := (cAliasTmp)->RECNO
   Endif
   
   If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif
   
return nRet

	
*************************************
Static Function GetLastRec(cFileName)
*************************************
	Local nRet    := 0
	Local nHandle := FOpen(cFileName,FO_READ + FO_SHARED)
	Local nBuffer := 1024
	Local cEOL    := CRLF
	Local cRow    := ""
	Local cNewRow := ""
	Local cRead   := Space(nBuffer)
	Local nPosEol := 0
	Local nSkip   := 0
    Local bErrorBlock := ErrorBlock( {|e| Alert("nRet == "+cValToChar(nRet)+" Len(cRow)== "+cValToChar(Len(cRow))) } ) 
	
	
   	If ( nHandle = -1 )
    	MSgInfo("Não foi possivel abrir o arquivo "+CRLF+CRLF+cFileName)
      	return .F. 
   	Endif 

	fSeek(nHandle,0,0) // Posiciona no início do arquivo
   
    BEGIN SEQUENCE
   
	While (FRead(nHandle,@cRead,nBuffer) > 0) 
		cRow += cRead
		cRead := Space(nBuffer)
		nPosEol := At(cEOL,cRow)
		If (nPosEol != 0)
			nRet++
			cNewRow := Left(cRow,nPosEol - 1)
			nSkip   := Len(cRow) - (Len(cEOL) + Len(cNewRow))
			fSeek(nHandle,(nSkip * -1),FS_RELATIVE) //Volta o ponteiro para o início da próxima linha
			cRow    :=  ""
		Endif
	EndDo

    END SEQUENCE
    ErrorBlock(bErrorBlock)
	
    fClose(nHandle)
Return nRet
