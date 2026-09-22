#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออออออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบ Programa  ณ IMPORTFOR                              บ Data ณ 29/12/2015 บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบ Autor     ณ Microsiga                                                  บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Descricao ณ Rotina para a importa็ใo dos Fornecedores do template CSV  บฑฑ
ฑฑบ           ณ para o ERP Protheus.                                       บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Sintaxe   ณ IMPORTFOR()                                                บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno   ณ nil                                                        บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso       ณ Rede Dor Sใo Luiz                                          บฑฑ
ฑฑศอออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 
User Function IMPORTFOR()

	Local oGroup
	Local oRadio
	Local nRadio    := 1
	Local aRet		:= {}
	Local aArea		:= GetArea()
	Local cArq      := ""

	Local cOrigem	:= GetMV("MV_XDIRFOR")+"\IMPORTAR\"  //GETMV("MV_PATH")+"IMPORTAR\"
	Local cDestino	:= GetMV("MV_XDIRFOR")+"\IMPORTADO\" //GETMV("MV_PATH")+"IMPORTADO\"

	Local lConv     := .F.

	Private aErros  := {}
	Private aLog    := {}

	Private cArquivo := Space(150)
	Private lOk      := .F.
	Private bOk      := { || If(u_ValidaDir(cArquivo), (lOk:=.T.,oDlg:End()) ,) }
	Private bCancel  := { || lOk:=.F.,oDlg:End() }
	Private lEnd     := .F.
	Private nHandle

	U_fCriaDirMA(cOrigem)
	U_fCriaDirMA(cDestino)

	Define MsDialog oDlg Title "Importa็ใo dos Fornecedores" From 08,10 To 30,120 Of GetWndDefault()

	@ 40,16  Say 	"Diretorio:" 	Size 050,10 Of oDlg Pixel
	@ 40,40  MsGet 	cArquivo 		Size 230,08 Of oDlg Pixel
	@ 40,275 Button "…" 			Size 010,10 Action Eval({|| cArquivo:=u_SelectFile() }) Of oDlg Pixel
	@ 60,55  GROUP oGroup TO 90,117 PROMPT " Gera็ใo de Arquivo " OF oDlg COLOR 0, 16777215 PIXEL
	@ 70,60  RADIO oRadio VAR nRadio ITEMS "EXCEL","TXT" SIZE 040, 010 OF oDlg COLOR 0, 16777215 PIXEL

	Activate MsDialog oDlg Centered On Init (EnchoiceBar(oDlg,bOk,bCancel))

	If lOk
		oProcess:=MsNewProcess():New( { |lEnd| lConv:=u_ImpForCSV(cArquivo, @lEnd)}, "Importa็ใo de Fornecedores", "Processando arquivo de Fornecedores", .T. )
		oProcess:Activate()
		If lConv
			cArq := SUBSTR(cArquivo,RAT("\", cArquivo)+1,LEN(cArquivo))
			cArq := Substr(cArq,1,Len(cArq)-4) +"_"+Day2Str(Date())+"_"+Month2Str(Date())+"_"+Year2Str(Date())+"_"+SUBSTR(Time(), 1, 2)+"_"+SUBSTR(Time(), 4, 2)+"_"+SUBSTR(Time(), 7, 2)+Substr(cArq, Len(cArq)-3, Len(cArq))
			If FRENAME ( cArquivo , cDestino+cArq ) == -1
				MsgInfo("Nใo foi possํvel mover o arquivo "+ cArquivo +" para o " + cDestino+cArq)
			Else
				MsgInfo("O Arquivo foi movido do local [ "+ cArquivo +" ] para o  [ " + cDestino+cArq + " ]. ")
			EndIf
			fClose(cArquivo)
			fClose(nHandle)

			// cria arquivo de LOG
			u_CRIARLOG(aLog, SUBSTR(cArq,1,LEN(cArq)-4), 6)
			If nRadio == 1
				// gera arquivo excel
				u_GeraExcel(aErros, SUBSTR(cArq,1,LEN(cArq)-4))
			Else
				// gera arquivo txt
				oProcess1:=MsNewProcess():New( { |lEnd| u_GeraTxt(aErros, SUBSTR(cArq,1,LEN(cArq)-4))}, "Importa็ใo dos Funcionarios", "Gerando arquivo TXT", .F. )
				oProcess1:Activate()
			EndIf
			// Mover arquivo
		EndIf

	EndIf

	RestArea(aArea)

Return

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	ฑฑษอออออออออออัออออออออออออออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
	ฑฑบ Programa  ณ IMPFORCSV                              บ Data ณ 29/12/2015 บฑฑ
	ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
	ฑฑบ Autor     ณ Microsiga                                                  บฑฑ
	ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
	ฑฑบ Descricao ณ Rotina para a importa็ใo dos Fornecedores do template CSV  บฑฑ
	ฑฑบ           ณ para o ERP Protheus.                                       บฑฑ
	ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
	ฑฑบ Sintaxe   ณ IMPFORCSV(cArq, lEnd)                                      บฑฑ
	ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
	ฑฑบ Retorno   ณ Logico                                                     บฑฑ
	ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
	ฑฑบ Uso       ณ Rede Dor Sใo Luiz                                          บฑฑ
	ฑฑศอออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function ImpForCSV(cArq, lEnd)

	Local aArea		:= GetArea()
	Local aTables	:= {}
	Local aVetor    := {}
	Local aDados    := {}

	Local cLinha
	Local lGrava    := .T.
	Local nTot      := 0
	Local nCont     := 1
	Local nAtual    := 0
	Local nTimeIni  := 0
	Local nLinTit   := 0 //2  // Total de linhas do Cabe็alho
	Local nTotTit   := 2 // limite das linhas do cabecalho
	Local w := 0
	Local aCampos 	:= {}
	Local aCoors 	:= MsAdvSize()

	Private lMsErroAuto := .F.

	Private cPath       := GetMV("MV_XDIRFOR")+"\LOG\" //GETMV("MV_PATH")+"LOG\"

	Private cCampo   := ""
	Private lObrigat := .T.
	Private cTipo    := ""
	Private nTamanho := 0
	Private nDecimal := 0
	Private cValida  := ""
	Private aValida  := {}

	If (nHandle := FT_FUse(AllTrim(cArq)))== -1
		Help(" ",1,"NOFILEIMPOR")
		RestInter()
		Return .F.
	EndIf

	nTot := FT_FLASTREC()

	FT_FGOTOP()

// Tratamento do cabe็alho
	While nLinTit <= nTotTit .AND. !Ft_FEof()
		cLinha := FT_FREADLN()
		If LEN(cLinha) == 1023
			nLinTit++
			FT_FSKIP()
			cConLinha := FT_FREADLN()
			While LEN(cConLinha) == 1023
				cLinha += cConLinha
				nLinTit++
				FT_FSKIP()
				cConLinha := FT_FREADLN()
			EndDo
			cLinha += cConLinha
			nLinTit := nTotTit + 1
		EndIf
		aCampos := SEPARA(cLinha,";",.T.)
		cLinha += ";DESC. ERRO"

		If u_VERTEMPL(aCampos[1], "SA2", "A2")
			Return .F.
		EndIf

		nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "A2_FILIAL" })
		nPosCod := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "A2_COD" })
		nPosLoj := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "A2_LOJA" })
		nPosNom := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "A2_NOME" })
		nPosNre := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "A2_NREDUZ" })
		nPosCgc := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "A2_CGC" })
		nPosCOdM:= aScan(aCampos,{ |x| Upper(AllTrim(x)) == "A2_CODMUN" })

		AADD( aErros, cLinha )
		cLinha := ""
		Ft_FSkip()

	EndDo

	oProcess:SetRegua1( nTot )
	oProcess:SetRegua2( int(ntot/100) )

// Processa os dados do template
	Do While !FT_FEOF()
		oProcess:IncRegua1("Registros processados : " + ALLTRIM(STR(nCont)) )
		cLinha := FT_FREADLN()

		aVetor := {}

		If lEnd
			MsgInfo("Importa็ใo cancelada!","Fim")
			Return .F.
		Endif

		If LEN(cLinha) == 1023
			FT_FSKIP()
			cConLinha := FT_FREADLN()
			While LEN(cConLinha) == 1023
				cLinha += cConLinha
				FT_FSKIP()
				cConLinha := FT_FREADLN()
			EndDo
			cLinha += cConLinha
		EndIf

		nAtual++
		If (nAtual % 100) = 1
			nTimeIni := Seconds()
		EndIf
		If (nAtual % 100) = 0
			oProcess:IncRegua2( "Tempo Restante - (" + U_EstTime(ntot,nAtual,(nAtual-100),nTimeIni) + ")" )
		EndIf

		//aDados := STRTOKARR(cLinha,";")   // A fun็ใo SEPARA e a fun็ใo STRTOKARR, converte uma string em um array, o SEPARA converte os espa็os em branco
		aDados := SEPARA(cLinha,";",.T.)
		For W:=1 To LEN(aCampos)
			If aDados[W] <> ""
			/*
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Rotina utilizada para carregar os valores do campo da X3. ณ
			//ณ cCampo    := ALLTRIM(SX3->X3_CAMPO)                       ณ
			//ณ lObrigat  := X3OBRIGAT(SX3->X3_CAMPO)                     ณ
			//ณ cTipo     := SX3->X3_TIPO                                 ณ
			//ณ nTamanho  := SX3->X3_TAMANHO                              ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			*/
				nPosDtFix  := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "A2_XDTFIX" })
				if nPosDtFix == 0
					lGrava := .F.
					cErro := cLinha+";NรO ENCONTROU O CAMPO DATA FIXA NO LAYOUT."
					AADD( aErros, cErro )
					Exit
				endif

				u_ConfCpo(aCampos[W], W)

				if !EMPTY(GetSx3Cache(aCampos[W],"X3_CAMPO")) // se nao existe no sx3, pula
					// VERIFICACAO CAMPO CODMUN
					IF ALLTRIM(ACAMPOS[W]) == "A2_COD_MUN" .and. !Empty(VALCODMUN(ADADOS[W], ACAMPOS, ADADOS))
						ADADOS[W] := VALCODMUN(ADADOS[W], ACAMPOS, ADADOS)
					elseif ALLTRIM(ACAMPOS[W]) == "A2_COD_MUN" .and. Empty(VALCODMUN(ADADOS[W], ACAMPOS, ADADOS))
						lGrava := .F.
						cErro := cLinha+";NรO ENCONTROU O CODIGO DO MUNICIPIO."
						AADD( aErros, cErro )
					Elseif ALLTRIM(ACAMPOS[W]) == "A2_INSCR"
						nPosEst := aScan(ACAMPOS,{ |x| Upper(AllTrim(x)) == "A2_EST" })
						lGrava := IE(aDados[W],aDados[nPosEst], .F.) .And. A020VldUCod()
						cErro := cLinha+";"+ "A2_INSCR="+aDados[W]+ " - A Inscri็ใo estadual informada esta invalida para esta unidade federativa."
						AADD( aErros, cErro )
					Elseif ALLTRIM(ACAMPOS[W]) == "A2_XDTFIX"
						if Empty(aDados[W])
							nPosCgc := aScan(ACAMPOS,{ |x| Upper(AllTrim(x)) == "A2_CGC" })
							lGrava := .F.
							cErro := cLinha+";"+ "Campo Data fixa do fornecedor CGC: "+aDados[nPosCgc]+" nใo preenchida."
							AADD( aErros, cErro )
						endif
					ELSE
						// CONVERTER OS DADOS PARA INSERวรO NO BANCO DE DADOS
						Do Case
						Case cTipo == 'D'
							If AT("/", aDados[W]) > 0
								aDados[W] := IIf(EMPTY(aDados[W]),CTOD("  /  /    "),CTOD(aDados[W]))
							Else
								aDados[W] := IIf(EMPTY(aDados[W]),CTOD("  /  /    "),STOD(aDados[W]))
							EndIf
						Case cTipo == 'N'
							aDados[W] := IIf(EMPTY(aDados[W]),0,VAL(STRTRAN(aDados[W],",",".")))
						Case cTipo == 'M'
							aDados[W] := IIf(EMPTY(aDados[W]),"",MSMM(aDados[W]))
						EndCase
					endif
					If (nPosFil = 0) .OR. (W = nPosFil)
						AADD(aVetor, {"A2_FILIAL", xFilial("SA2"), Nil})
					ElseIf !EMPTY(aDados[W])
						AADD(aVetor, {aCampos[W], aDados[W], Nil})
					EndIf

				else
					if !empty(aCampos[w])
						cErro := "Verifique o campo " + aCampos[W] + ". Ele nใo existe no SX3. "
						AADD( aErros, cErro )
					endif
				EndIf
			endif
		Next W

		If lGrava
			If !EMPTY(aVetor)
				//aVetor  := {}
				dbSelectArea("SA2")
				SA2->( dbsetorder(3) )
				SA2->( dbGoTop() )
				If SA2->( dbseek(xFilial("SA2")+aDados[nPosCgc]) )
					cErro := cLinha+";Fornecedor jแ cadastrado para este CNPJ."
					AADD( aErros, cErro )

					AADD(aLog,{"A2_COD"    ,aDados[nPosCod] ,Nil})
					AADD(aLog,{"A2_LOJA"   ,aDados[nPosLoj] ,Nil})
					AADD(aLog,{"A2_NOME"   ,aDados[nPosNom] ,Nil})
					AADD(aLog,{"A2_NREDUZ" ,aDados[nPosNre] ,Nil})
					AADD(aLog,{"A2_CGC"    ,aDados[nPosCgc] ,Nil})
					AADD(aLog,{"ERRO" 	   ,"Fornecedor jแ cadastrado para este CNPJ." ,Nil})
				Else
					/*oModel := FWLoadModel('MATA020')
					nOpc := 3
					oModel:SetOperation(nOpc)
					oModel:Activate()

					For nX := 01 To Len(aVetor)
						oModel:SetValue('SA2MASTER',aVetor[nX][1] ,aVetor[nX][2])
					Next nX
					//Executando execauto mvc Fornecedor.
					If oModel:VldData()
						oModel:CommitData()
					Else
						//aError := oModel:GetErrorMessage()
						//alerta(aError[MODEL_MSGERR_MESSAGE]+"/"+aError[MODEL_MSGERR_SOLUCTION])
						//lRetorno := .F.

						cNomArqErro := "ARQLOG.LOG"
						cErroTemp := aError[MODEL_MSGERR_MESSAGE]+"/"+aError[MODEL_MSGERR_SOLUCTION]//Mostraerro(cPath, cNomArqErro)
						nLinhas   := MLCount(cErroTemp)
						cBuffer   := ""
						cCampo    := ""
						cDescErro := ""
						cConteudo := ""
						nErrLin   := 1
						lOpErro   := .T.
						lErro     := .T.
						cBuffer   := RTrim(MemoLine(cErroTemp,,nErrLin))
						//Carrega o nome do campo
						While (nErrLin <= nLinhas)
							nErrLin++
							cBuffer:=RTrim(MemoLine(cErroTemp,,nErrLin))
							If lErro
								If ALLTRIM(cBuffer) <> ""
									cDescErro += cBuffer+" "
								Else
									lErro := .F.
								EndIf
							EndIf
							If (Upper(SubStr(cBuffer,Len(cBuffer)-7,Len(cBuffer))) == "INVALIDO")
								cCampo    := cBuffer

								//xTemp     := AT("-",cBuffer)
								//cCampo    := AllTrim(SubStr(cBuffer,xTemp+1,AT(":",cBuffer)-xTemp-2))
								//cConteudo := cBuffer
								Exit
							EndIf
						EndDo

						FERASE(cPath+cNomArqErro)

						cLinha += ";"+cDescErro+" - "+cCampo
						AADD( aErros, cLinha )

						AADD(aLog,{"A2_COD"    ,aDados[nPosCod] ,Nil})
						AADD(aLog,{"A2_LOJA"   ,aDados[nPosLoj] ,Nil})
						AADD(aLog,{"A2_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"A2_NREDUZ" ,aDados[nPosNre] ,Nil})
						AADD(aLog,{"A2_CGC"    ,aDados[nPosCgc] ,Nil})
						AADD(aLog,{"ERRO" 	   ,cDescErro+" - "+cCampo ,Nil})

						lMsErroAuto := .F.

					Endif
					oModel:DeActivate()
					oModel:Destroy()
					*/
					//comentado para utilizar o execauto mvc


					MSExecAuto({|x,y| Mata020(x,y)},aVetor,3)

					If lMsErroAuto
						//	MostraErro()
						cNomArqErro := "ARQLOG.LOG"
						cErroTemp := Mostraerro(cPath, cNomArqErro)
						nLinhas   := MLCount(cErroTemp)
						cBuffer   := ""
						cCampo    := ""
						cDescErro := ""
						cConteudo := ""
						nErrLin   := 1
						lOpErro   := .T.
						lErro     := .T.
						cBuffer   := RTrim(MemoLine(cErroTemp,,nErrLin))
						//Carrega o nome do campo
						While (nErrLin <= nLinhas)
							nErrLin++
							cBuffer:=RTrim(MemoLine(cErroTemp,,nErrLin))
							If lErro
								If ALLTRIM(cBuffer) <> ""
									cDescErro += cBuffer+" "
								Else
									lErro := .F.
								EndIf
							EndIf
							If (Upper(SubStr(cBuffer,Len(cBuffer)-7,Len(cBuffer))) == "INVALIDO")
								cCampo    := cBuffer

								//xTemp     := AT("-",cBuffer)
								//cCampo    := AllTrim(SubStr(cBuffer,xTemp+1,AT(":",cBuffer)-xTemp-2))
								//cConteudo := cBuffer
								Exit
							EndIf
						EndDo

						FERASE(cPath+cNomArqErro)

						cLinha += ";"+cDescErro+" - "+cCampo
						AADD( aErros, cLinha )

						AADD(aLog,{"A2_COD"    ,aDados[nPosCod] ,Nil})
						AADD(aLog,{"A2_LOJA"   ,aDados[nPosLoj] ,Nil})
						AADD(aLog,{"A2_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"A2_NREDUZ" ,aDados[nPosNre] ,Nil})
						AADD(aLog,{"A2_CGC"    ,aDados[nPosCgc] ,Nil})
						AADD(aLog,{"ERRO" 	   ,cDescErro+" - "+cCampo ,Nil})

						lMsErroAuto := .F.
					Else

					Endif
				EndIf
			EndIf
		Else
			lGrava := .T.
		EndIF

		FT_FSKIP()
		nCont++
	EndDo

	FT_FUSE()

	Aviso("Finalizado","Leitura do arquivo realizada com sucesso",{"Fechar"})

	RestArea(aArea)

Return .T.

sTATIC Function VALCODMUN(XCODMUN, XCPO, XDADOS )

	LOCAL XRET := ""
	lOCAL XPOSUF  := aScan(XCPO,{ |x| Upper(AllTrim(x)) == "A2_EST" })
	lOCAL XPOSCID := aScan(XCPO,{ |x| Upper(AllTrim(x)) == "A2_MUN" })

	DBSELECTAREA("CC2")
	DBSETORDER(4)
	IF DBSEEK(XFILIAL("CC2")+ XDADOS[XPOSUF] + ALLTRIM(XDADOS[XPOSCID]))
		XRET := CC2->CC2_CODMUN
	Else
		XRET := ""
	EndIF

RETURN XRET


