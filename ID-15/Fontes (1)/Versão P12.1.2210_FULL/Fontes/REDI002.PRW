#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "topconn.ch"



/*/{Protheus.doc} REDI002
//TODO Descrição função para leitura e importação dos arquivos de compras.
@author Ricardo Junior
@since 07/06/2019
@version 1.0
@return Nil

@type function
/*/
User Function REDI002()

	Local cDirectory 	:= ""
	Local cMainPath 	:= "C:\"
	Local aArquivos 	:= {}
	Local cDriver		:= ""
	Local lRet 			:= .T.
	Private aLog 		:= {}
	Private cTabela     := ""
	Private _nLinha     := 0
	Private lPrim 		:= .T.
	Private cRot        := ""
	Private cMaster     := ""
	Private cIndexF3	:= ""
	Private oModel      := Nil
	Private cCampoAtu	:= ""
	Private aExec		:= {}
	Private _nQtdOK 	:= 00
	Private _nQtdError 	:= 00
	Private lValidou	:= .F.

	cDriver := "|- LOCAL -|"

	While lRet
		cDirectory 	:= AllTrim(cGetFile('*.csv|*.csv','Importação Dados Administração de Compras', 0,cMainPath, .T., GETF_MULTISELECT + GETF_LOCALHARD, .T.))
		aArquivos 	:= Separa(cDirectory, "|")

		If Len(aArquivos) > 0
			Processa( {|| fValidaTxt(aArquivos)}, "Aguarde...", "Validando arquivos selecionados...",.F.)
		Else
			lRet := .F.
			Alert("Não foram selecionados arquivos para importação.")
		Endif
		aLog		:= {}
		//_nQtdOK 	:= 00
		//_nQtdError 	:= 00
		DbSkip()
	EndDo
Return

Static Function fValidaTxt(aArquivos)
	Local nX 		:= 00
	Local aDados 	:= {}
	Local lAuto     := .F.
	Local nY
	For nX := 01 To Len(aArquivos)
		FT_FUSE(AllTrim(aArquivos[nX]))
		nLastRec := FT_FLASTREC()
		_nLinha := 0
		aAdd(aLog, {"-----------------------------------------------------------", 0})
		aAdd(aLog, {"Iniciando leitura do arquivo: " + aArquivos[nX], 0})
		aAdd(aLog, {"Data da importação: " + DToC(dDataBase), 0})
		aAdd(aLog, {"Importação realizada pelo usuário: " + cUserName, 0})
		aAdd(aLog, {"-----------------------------------------------------------", 0})
		If nLastRec <= 0
			aAdd(aLog, {"O Arquivo: " + aArquivos[nX] +" está vazio.", 0})
			Loop
		EndIf
		ProcRegua(nLastRec)
		FT_FGOTOP()
		lPrim := .T.
		While !FT_FEOF()
			IncProc("Lendo arquivo texto..." + aArquivos[nX] + " Linha " + cValToChar(_nLinha) )
			cLinha := FT_FREADLN()
			_nLinha := _nLinha + 1
			If lPrim
				aCampos := Separa(cLinha,";",.F.)
				lPrim := .F.
				If Len(aCampos) > 0
					If fBuscaTabela(aCampos)
						If MVGetCus("MV_XCARMVC",.F.)
							Do Case
							Case cTabela == "SAK"
								cRot := "MATA095"
								cMaster := 	"SAKMASTER"
								lAuto := .T.
							Case cTabela == "SAI"
								cRot := "MATA084"
								cMaster := "SAI"
								cMaster2:= "SAI_GD"
								lAuto := .T.
							Case cTabela == "DHL"
								cRot := "COMA210"
								cMaster := "ModelDHL"
								lAuto := .T.
							EndCase
						EndIf
						If lAuto
							oModel := FWLoadModel(cRot)
						EndIf
						If fValidaDic(aCampos, aArquivos[nX], cLinha)
							FT_FSKIP()
						Else
							Exit
						EndIf
					Else
						Exit
					EndIf
				Else
					aAdd(aLog,{"Arquivo["+aArquivos[nX]+"] não possui cabeçalho!", _nLinha})
					Exit
				EndIf
			Else
				aAdd(aDados, Separa(cLinha,";",.T.))
				For nY := 01 To Len(aCampos)
					If TamSX3(aCampos[nY])[03] == "N"
						aAdd(aExec,{aCampos[nY], Val(aDados[01][nY])})
					Else
						aAdd(aExec,{aCampos[nY], aDados[01][nY]})
					EndIf
				Next nY
				If !lAuto
					Begin Transaction
						lValidou := .F.
						lRet := fExec(aExec)
						If !lRet
							If !lRet == NIL
								_nQtdError++
								DisarmTransaction()
							EndIf
						Else
							_nQtdOK++
						EndIf
					End Transaction
				Else
					FMVC(aExec)
				EndIf
				aDados := {}
				aExec  := {}
				FT_FSKIP()
			EndIf
		EndDo
		aAdd(aLog, {"-----------------------------------------------------------", 0})
		aAdd(aLog, {"TOTAL DE REGISTROS: IMPORTADOS "+ cValToChar(_nQtdOk) +" ERROS "+ cValToChar(_nQtdError), 0})
		_nQtdOK 	:= 00
		_nQtdError 	:= 00
	Next nX
	FT_FUSE()
	fGeraLog()
Return

Static Function fValidaDic(aCampos, cArquivo, cLinha)

	Local nX 		:= 00
	Local cNotField := ""
	Local lRet 		:= .T.
	Local aArea 	:= GetArea()

	DbSelectArea('SX3')
	SX3->(DbSetOrder(2))
	For nX := 01 To Len(aCampos)
		If !SX3->(DbSeek(PadR(aCampos[nX],10)))
			cNotField += AllTrim(aCampos[nX]) + "|"
			lRet := .F.
		EndIf
	Next nX
	cNotField := SubStr(cNotField,1,len(cNotField)-1)
	If !Empty(cNotField)
		aAdd(aLog, {"OS campos [" + cNotField +"] não foram encontrados no dicionario. ARQUIVO[" +AllTrim(cArquivo)+"]", 0})
	EndIf
	RestArea(aArea)
Return lRet

Static Function fGeraLog()
	Local nX 	:= 01
	Local aArea := GetArea()
	Local cCaminho := SuperGetMv("MV_XDIRCAR",, "C:\tmp\")
	Local cArq := "log_"+FWTimeStamp()+".txt"

	If !ExistDir(cCaminho)
		If !MakeDir(cCaminho)
			MsgAlert('Não foi possivel criar o arquivo de log, por favor, contate o admnistrador do sistema.')
		EndIf
	EndIf

	nHandle := FCreate(cCaminho+cArq)

	aAdd(aLog, {"-----------------------------------------------------------", 0})
	aAdd(aLog, {"Fim do LOG", 0})
	aAdd(aLog, {"-----------------------------------------------------------", 0})

	If nHandle == -1
		MsgStop('Erro de abertura : FERROR '+Str(FError(), 04))
	Else
		For nX := 01 To Len(aLog)
			FWrite(nHandle, aLog[nX][01] + iIf(aLog[nX][02] > 0,  " Linha: " + cValToChar(aLog[nX][02]), " ") + CRLF, 1024) // Insere texto no arquivo
		Next
	Endif

	fclose(nHandle)                   // Fecha arquivo
	MsgAlert('Processo arquivo de log 	 [ '+ cCaminho + cArq +' ].')
	shellExecute("Open", cCaminho + cArq,"", cCaminho, 3)
	RestArea(aArea)
Return

Static Function fBuscaTabela(aCampos)
	Local cMvTab := SuperGetMV("MV_XTABCOM",,"SAI|SAL|SAJ|SAK|DHL|PZX|PZY|SY1|P21|P02")
	Local lRet   := .T.

	cTabela := SubStr(aCampos[1], 01, At("_", aCampos[01]) -1)
	If cTabela $ cMvTab
		If Len(cTabela) == 2
			cTabela := "S"+cTabela
		ElseIf Len(cTabela) <= 1
			aAdd(aLog,{ cTabela + " inexistente! ", 0 })
			Return
		EndIf
	Else
		aAdd(aLog,{"A Tabela " + cTabela + " não pertence ao grupo de tabelas de importação", 0})
		lRet := .F.
	EndIf
Return lRet

Static Function fExec(aExec)
	Local nX 	:= 00
	Local cInd 	:= ""
	Local lRet  := .T.
	Local aArea := GetArea()
	Local oError := ErrorBlock({|e| aAdd(aLog,{"Mensagem de Erro: " +chr(10)+ e:Description,0}) })
	Local lOk   := .F.
	Local nContador := 0
	Local nZ	:= 0
	Local lInc	:= .T.
	Local cGrpUsr := ""
	Local cCodUsrAi := ""
	Local cNumeroY1 := ""
	Local aSE1Brw := {}
	Default aExec := {}
	Private cCodTmp := ""
	Private cCodY1 := ""

	DbSelectArea(cTabela)
	DbSetOrder(1)

	If cTabela == "SY1"
		cFilAnt := aExec[01][02]
		cCodTmp := SY1->(GetSX8Num("SY1","Y1_COD"))
	EndIf

	If SX2->(DbSeek(cTabela))
		xRetorno := FwSX2Util():GetSX2data(cTabela, {"X2_MODO"})[1][2]
	Endif

	cInd := fBuscaInd(aExec)

	If !lRet .Or. Empty(cInd)
		For nZ := 1 to Len(aExec)
			//If ValType(aExec[nZ][02]) == "N"
			//	If AllTrim(aExec[nZ][02]) == 0
			//		nContador++
			//	EndIf
			If AllTrim(aExec[nZ][02]) == ""
				nContador++
			EndIf
			If nContador >= Len(aExec)
				aAdd(aLog, {"A linha está com todos os campos em branco.", _nLinha})
				lOk := .F.
			EndIf
		Next nZ
		Return lOk
	EndIf

	If DbSeek(cInd)
		lInc := .F.
		RegToMemory(cTabela,.F.,.F.,.F.)
	Else
		lInc := .T.
		RegToMemory(cTabela,.T.,.F.,.F.)
	EndIf

	DbSelectArea('SX3')
	SX3->(DbSetOrder(1))
	SX3->(DbSeek(cTabela))
	RecLock(cTabela,lInc)
	Begin Sequence
		aSE1Brw := FWSX3Util():GetAllFields( cTabela , .F. )
		For nX:=1 TO Len(aSE1Brw)
			cCampo:= AllTrim(aSE1Brw[nX])
			nPos := aScan(aExec, {|x| AllTrim(x[1]) == AllTrim(GetSx3Cache( cCampo ,"X3_CAMPO"))})
			If nPos == 0 .And. AllTrim(GetSx3Cache( cCampo ,"X3_CONTEXT")) != "V"
				If X3Obrigat(GetSx3Cache( cCampo ,"X3_CAMPO"))
					aAdd(aLog, {"O Campo " + GetSx3Cache( cCampo ,"X3_CAMPO") + " é obrigatorio e não esta na arquivo, por favor, verificar.", _nLinha})
					Break
				EndIf
				//SX3->(DbSkip())
				Loop
			EndIf
			If AllTrim(GetSx3Cache( cCampo ,"X3_CONTEXT")) != "V"
				If AllTrim(GetSx3Cache( cCampo ,"X3_TIPO")) == "N"
					(cTabela)->&(aExec[nPos][01]) := iIf(ValType(aExec[nPos][02]) == "N", aExec[nPos][02], Val(aExec[nPos][02]))
					M->&(aExec[nPos][01]) := iIf(ValType(aExec[nPos][02]) == "N", aExec[nPos][02], Val(aExec[nPos][02]))
				ElseIf AllTrim(GetSx3Cache( cCampo ,"X3_TIPO")) == "L"
					(cTabela)->&(aExec[nPos][01]) := iIf(ValType(aExec[nPos][02]) == "L", aExec[nPos][02], iIf(aExec[nPos][02]=="VERDADEIRO",.T.,.F.))
					M->&(aExec[nPos][01]) := iIf(ValType(aExec[nPos][02]) == "L", aExec[nPos][02], iIf(aExec[nPos][02]=="VERDADEIRO",.T.,.F.))
				Else
					If cTabela == "SAI"
						If AllTrim(aExec[2][2]) != "******"
							cCodUsrAi := NameFull(AllTrim(aExec[2][2]))
							If AllTrim(cCodUsrAi) == ""
								aAdd(aLog, {"O usuário " + aExec[2][2] + " não existe no Protheus. ", _nLinha})
								lOk := .F.

								Break
							EndIf
						EndIf
						cGrpUsr := GrpRetName(aExec[3][2])
						If AllTrim(cGrpUsr) == ""
							aAdd(aLog, {"O grupo de usuários " + aExec[3][2] + " não existe no Protheus. ", _nLinha})
							lOk := .F.

							Break
						EndIf
					EndIf

					If !lInc
						If AllTrim(UPPER((cTabela)->&(aExec[nPos][01]))) == ALLTRIM(UPPER(aExec[nPos][02]))
							(cTabela)->&(aExec[nPos][01]) := aExec[nPos][02]
							M->&(aExec[nPos][01]) := aExec[nPos][02]
						Else
							If aExec[nPos][01] $ MVGetCus("MV_XCPDIF","AK_APROSUP|AL_APROSUP")
								(cTabela)->&(aExec[nPos][01]) := aExec[nPos][02]
								M->&(aExec[nPos][01]) := aExec[nPos][02]
							Else
								aAdd(aLog, {"O Registro " + cInd + " já existe e esta com o conteudo do campo "+aExec[nPos][01]+" diferente.  TABELA: "+AllTrim((cTabela)->&(aExec[nPos][01]))+"  ARQUIVO: "+AllTrim(aExec[nPos][02])+".", _nLinha})
								lOk := .F.
								If cTabela == "SY1"
									ConfirmSX8()
								EndIf
								Break
							EndIf
						EndIf
					Else
						///Teste Gambiarra
						//If (cTabela)->&(aExec[nPos][01]) == "Y1_COD"
						//	cCodY1 := aExec[nPos][02] //Guarda o código da Y1 para a linha selecionada
						//	(cTabela)->&(aExec[nPos][01]) := cCodTmp
						//Else
						(cTabela)->&(aExec[nPos][01]) := aExec[nPos][02]
						//EndIf
						M->&(aExec[nPos][01]) := aExec[nPos][02]
					EndIf
				EndIf
				If X3Obrigat(GetSx3Cache( cCampo ,"X3_CAMPO"))
					If Empty(aExec[nPos][02] )
						aAdd(aLog, {"O Campo " + GetSx3Cache( cCampo ,"X3_CAMPO") + " é obrigatorio e esta vazio, por favor, verificar o arquivo.", _nLinha})
						If cTabela == "SY1"
							ConfirmSX8()
						EndIf
						Break
					Endif
				Else
					If Empty(aExec[nPos][02])
						//SX3->(DbSkip())
						Loop
					Endif
				EndIf

				If (!Empty(GetSx3Cache( cCampo ,"X3_VALID")) .Or. !Empty(GetSx3Cache( cCampo ,"X3_VLDUSER")))
					cIndexF3 := aExec[01][02] + iIf(ValType(aExec[nPos][02]) != "C", cValToChar(aExec[nPos][02]), aExec[nPos][02])
					cCampoAtu := aExec[nPos][01]
					__ReadVar := cCampoAtu
					cVldPad := GetSx3Cache( cCampo ,"X3_VALID")
					cVldUsr := GetSx3Cache( cCampo ,"X3_VLDUSER")
					If !Empty(cVldPad)
						If "FwFldGet(" $ cVldPad
							//SX3->(DbSkip())
							Loop
						EndIf
						If "EXISTCHAV" $ UPPER(ALLTRIM(cVldPad)) .Or. At("EXISTCPO(", UPPER(AllTrim(cVldPad))) > 0
							If "cGrCom" $ cVldPad
								cVldPad := Replace(cVldPad, "cGrCom", "M->"+cCampoAtu )
							EndIf
							cVldPad := Replace(UPPER(ALLTRIM(cVldPad)), "EXISTCPO(", "U_XEXICPO(" )
							cVldPad := Replace(UPPER(ALLTRIM(cVldPad)), "EXISTCHAV(", "U_XEXICHV(" )
						EndIf
						If "POSITIVO()" $ cVldPad
							cVldPad := StrTran(cVldPad,("POSITIVO()"),"(M->"+cCampoAtu+">=0)")
						EndIf
						If "USREXIST(" $ cVldPad
							If !UsrExist(aExec[nPos][02])
								aAdd(aLog, {"O Usuário "+ aExec[nPos][02] +" não existe.", _nLinha})
								lOk := .F.
								If cTabela == "SY1"
									ConfirmSX8()
								EndIf
								Break
							Else
								lOk := .T.
							EndIf
						EndIf
						If "A084User()" $ cVldPad
							aAreaAI:= SAI->(GetArea())
							SAI->(DbSetOrder(2))
							If !SAI->(MsSeek(cIndexF3))
								aAdd(aLog, {"O Usuário "+ aExec[nPos][02] +" não existe.", _nLinha})
								lOk := .F.
								If cTabela == "SY1"
									ConfirmSX8()
								EndIf
								Break
							Else
								lOk := .T.
							EndIf
							RestArea(aAreaAI)
						EndIf
						If "A114APROV()" $ cVldPad
							cVldPad := Replace(UPPER(ALLTRIM(cVldPad)), "A114APROV()", "U_A114APROV()" )
						EndIf
						If "A095ChkVal(" $ cVldPad
							lOk := .T.
						EndIf
						If !lOk
							lOk := &(cVldPad)
						EndIf
					EndIf
					If !lOk .And. !Empty(cVldUsr)
						If "FwFldGet(" $ cVldUsr
							//SX3->(DbSkip())
							Loop
						EndIf
						If "EXISTCHAV" $ UPPER(ALLTRIM(cVldUsr)) .Or. At("EXISTCPO(", UPPER(AllTrim(cVldUsr))) > 0
							If "cGrCom"$ cVldUsr
								cVldUsr := Replace(cVldUsr, "cGrCom", "M->"+cCampoAtu )
							EndIf
							cVldUsr := Replace(UPPER(ALLTRIM(cVldUsr)), "EXISTCPO(", "U_XEXICPO(" )
							cVldUsr := Replace(UPPER(ALLTRIM(cVldUsr)), "EXISTCHAV(", "U_XEXICHV(" )
						EndIf
						If "POSITIVO()" $ cVldUsr
							cVldUsr := StrTran(cVldUsr,("POSITIVO()"),"(M->"+cCampoAtu+">=0)")
						EndIf
						If "UsrExist(" $ cVldUsr
							If !UsrExist(aExec[nPos][02])
								aAdd(aLog, {"O Usuário "+ aExec[nPos][02] +" não existe.", _nLinha})
								lOk := .F.
								If cTabela == "SY1"
									ConfirmSX8()
								EndIf
								Break
							Else
								lOk := .T.
							EndIf
						EndIf
						If "A084User()" $ cVldUsr
							aAreaAI:= SAI->(GetArea())
							SAI->(DbSetOrder(2))
							If !SAI->(MsSeek(cIndexF3))
								aAdd(aLog, {"O Usuário "+ aExec[nPos][02] +" não existe.", _nLinha})
								lOk := .F.
								If cTabela == "SY1"
									ConfirmSX8()
								EndIf
								Break
							Else
								lOk := .T.
							EndIf
							RestArea(aAreaAI)
						EndIf
						If "A095ChkVal(" $ cVldUsr
							lOk := .T.
						EndIf
						If "A114APROV()" $ cVldUsr
							cVldUsr := Replace(UPPER(ALLTRIM(cVldUsr)), "A114APROV()", "U_A114APROV()" )
						EndIf
						If !lOk
							lOk := &(cVldUsr)
						EndIf
					EndIf
					If cTabela == "SAJ"
						If lOK
							lOk := fValSAJ()
							If !lOK
								aAdd(aLog, {"Não existe cadastro para o usuário " +aExec[4][2]+" na filial " +aExec[1][2]+ " da tabela SY1.", _nLinha})
								If cTabela == "SY1"
									ConfirmSX8()
								EndIf
								Break
							EndIf
						EndIf
					EndIF
					If cTabela == "SY1"
						If lOk
							lAchou := .F.
							If lValidou == .F.
								lAchou := fValY1()
								If lAchou
									aAdd(aLog, {"O Usuário "+ aExec[4][2] +" já está cadastrado nessa filial.", _nLinha})
									lOk := .F.
									If cTabela == "SY1"
										ConfirmSX8()
									EndIf
									Break
								EndIf
							EndIf
						EndIf
					EndIf
					If !lOk
						Exit
					Else
						//		If cTabela == "SY1"
						//			fCodY1()
						//		EndIf
					EndIf
				EndIf
			EndIf
		Next
		Recover
		ErrorBlock(oError)
	End Sequence
	RestArea(aArea)
Return lOk

Static Function FMVC(aExec)
	Local aArea		 	:= GetArea()
	Local nX         	:= 0
	Local oError 		:= ErrorBlock({|e| aAdd(aLog,{"Mensagem de Erro: " +chr(10)+ e:Description,0}) })
	Private lMsErroAuto := .F.
	Private aRotina    	:= {}

	cInd := fBuscaInd(aExec)

	If Empty(cInd)
		Return
	EndIf

	DbSelectArea(cTabela)
	DbSetOrder(01)
	If (cTabela)->(MsSeek(cInd))
		nOperacao := MODEL_OPERATION_UPDATE
	Else
		nOperacao := MODEL_OPERATION_INSERT
	EndIf
	Begin Sequence
		FWMVCRotAuto(	oModel,;                         //Model
		cTabela,;                        //Alias
		nOperacao,;        				 //Operacao
		{{cMaster, aExec}})          //Dados
		Recover
		Break
	End Sequence
	If lMsErroAuto
		aAdd(aLog,{MostraErro("C:\"), _nLinha})
	EndIf
	ErrorBlock(oError)
	RestArea(aArea)
Return

Static Function fBuscaInd(aExec)
	Local aInd 		:= {}
	Local nX   		:= 00
	Local cInd 		:= ""

	If AllTrim(cTabela) == "SAI"
		If aExec[2][2] == "******"
			DbSelectArea(cTabela)
			DbSetOrder(01)
		Else
			DbSelectArea(cTabela)
			DbSetOrder(02)
		EndIf
	Else
		DbSelectArea(cTabela)
		DbSetOrder(01)
	EndIf
	If SX2->(DbSeek(cTabela))
		xRetorno := FwSX2Util():GetSX2data(cTabela, {"X2_MODO"})[1][2]
	Endif

	aInd := Separa(IndexKey(), "+", .F.)

	For nX := 01 To Len(aInd)
		nIdx := aScan(aExec,{|x| AllTrim(x[1]) == AllTrim(aInd[nX])})
		If  nIdx > 0
			If "FILIAL" $ aExec[nIdx][01]
				If xRetorno == "E"
					//If Empty(aExec[nIdx][02])
					//	aAdd(aLog, {"A filial do arquivo esta em branco.", _nLinha})
					//	lRet := .F.
					//	Exit
					If !FWFilExist(cEmpAnt, aExec[nIdx][02])
						aAdd(aLog, {"A filial " + aExec[nIdx][02] + " do arquivo não existe.", _nLinha})
						lRet := .F.
						Exit
					Else
						cInd += aExec[nIdx][2]
					EndIf
				Else
					cInd += xFilial(cTabela)
				EndIf
			Else
				cInd += aExec[nIdx][2]
			EndIf
		Else
			aAdd(aLog, {"O Campo " + aInd[nX] + " Não existe na tabela e faz parte do indice", 0})
			cInd := ""
			Exit
		EndIf
	Next nX

Return cInd

User Function XEXICPO(cAlias,cValor,nOrdem)
	Local aArea	:= GetArea()
	Local lRet 	:= .T.
	Local xRetorno := ""

	Default cValor := ""
	Default nOrdem	:= 01
	If AllTrim(cAlias) == "SX5"
		cValor := xFilial(cAlias)+cValor
	ElseIf AllTrim(cAlias) == "SBM"
		cValor := xFilial(cAlias)+cValor
	Else
		cValor := fGetFilial(cAlias, aExec[01][02]) + aExec[nPos][2]
	EndIf

	DbselectArea(cAlias)
	DbSetOrder(nOrdem)
	If DbSeek(cValor)
		lRet := .T.
	Else
		lRet := .F.
		aAdd(aLog, {"Registro "+ cValor +" não existe na tabela " + cAlias, _nLinha})
		Break
	EndIf
	RestArea(aArea)
Return lRet

User Function XEXICHV(cAlias,cValor,nOrdem)
	Local lRet 	:= .T.
Return lRet

Static Function UsrExist(cUser)
	Local aArea := GetArea()
	Local lRet 		:= .F.

	PswOrder(1)
	If PswSeek(cUser)
		lRet := .T.
	EndIf
	RestArea(aArea)
Return lRet


User Function A114Aprov()
	Local lRet      	:= .T.
	Local nPosFilial    := aScan(aExec, {|x| AllTrim(x[1]) == AllTrim("AL_FILIAL")})
	Local nPosCod    	:= aScan(aExec, {|x| AllTrim(x[1]) == AllTrim("AL_COD")})
	Local nPosUser      := aScan(aExec, {|x| AllTrim(x[1]) == AllTrim("AL_USER")})
	Local nPosAprov     := aScan(aExec, {|x| AllTrim(x[1]) == AllTrim("AL_APROV")})
	Local nPosItem    	:= aScan(aExec, {|x| AllTrim(x[1]) == AllTrim("AL_ITEM")})
	Local aArea			:= GetArea()

	cFilSAK := fGetFilial("SAK", aExec[nPosFilial][2])
	SAK->(DbSetOrder(1))
	If SAK->(DbSeek(cFilSAK+aExec[nPosAprov][2]))
		cFilSAL := fGetFilial("SAL", aExec[nPosFilial][2])
		If SAL->(DbSeek(cFilSAL + aExec[nPosCod][2]))
			While !SAL->(Eof()) .And. cFilSAL + aExec[nPosCod][2] == SAL->AL_FILIAL + SAL->AL_COD
				If SAL->AL_USER == aExec[nPosUser][2]  .And. SAL->AL_APROV == aExec[nPosAprov][2] .And. AllTrim(SAL->AL_ITEM) != aExec[nPosItem][2]
					aAdd(aLog, {"Filial "+cFilSAL+" Codigo do aprovador "+ SAL->AL_APROV + " já existe no grupo " +SAL->AL_COD+" JAGRAVADO. SAL", _nLinha})
					lRet := .F.
					Exit
				EndIf
				SAL->(DbSkip())
			EndDo
		EndIf
	Else
		aAdd(aLog, {"SAK - "+ aExec[nPosAprov][2] +" NÃO EXISTE.", _nLinha})
		lRet := .F.
	EndIf
	RestArea(aArea)
Return lRet

Static Function fGetFilial(cTab, cConteudo)

	Local cFilArq := ""

	Default cConteudo := xFilial(cTab)

	If SX2->(DbSeek(cTab))
		xRetorno := FwSX2Util():GetSX2data(cTabela, {"X2_MODO"})[1][2]
	Endif

	If xRetorno == "E"
		cFilArq := cConteudo
	Else
		cFilArq := xFilial(cTab)
	EndIf

Return cFilArq


Static Function fValY1()

	Local aArea := GetArea()
	Local cAliasR := GetNextAlias()
	Local cQuery := ""
	Local lAchou := .F.


	cQuery := " SELECT * "
	cQuery += "   FROM " + RetSQLName(cTabela)
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND Y1_FILIAL = '"+aExec[1][2]+"'"
	cQuery += " AND Y1_USER = '"+aExec[4][2]+"'"

	If Select( cAliasR ) > 0
		( cAliasR )->( DbCloseArea() )
	EndIf

	TCQUERY ( cQuery ) ALIAS ( cAliasR ) NEW

	If !( cAliasR )->( Eof() )
		lAchou := .T.
	EndIf
	( cAliasR )->( DbCloseArea() )

	lValidou := .T.
	RestArea(aArea)

Return lAchou

Static Function fValSAJ()

	Local aArea := GetArea()
	Local cAliasR := GetNextAlias()
	Local cQuery := ""
	Local lAchou := .F.


	cQuery := " SELECT * "
	cQuery += "   FROM " + RetSQLName("SY1")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND Y1_FILIAL = '"+aExec[1][2]+"'"
	cQuery += " AND Y1_USER = '"+aExec[4][2]+"'"

	TCQUERY ( cQuery ) ALIAS ( cAliasR ) NEW

	If !( cAliasR )->( Eof() )
		lAchou := .T.
	EndIf
	( cAliasR )->( DbCloseArea() )


	RestArea(aArea)

Return lAchou



Static Function fCodY1()

	Local aArea := GetArea()
	Local cUpdate := ""


	cUpdate := "	UPDATE " + RetSQLName( "SY1" )
	cUpdate += " 	   SET Y1_COD 	= '"+cCodY1+"'"
	cUpdate += "	 WHERE D_E_L_E_T_ 	= ' ' AND "
	cUpdate += "	 Y1_USER =  '"+aExec[4][2]+"' "
	cUpdate += " AND Y1_FILIAL = '"+aExec[1][2]+"'"

	If TcSQLExec( cUpdate ) != 0
		Conout("Erro ao tentar atualizar a tabela SC9" + CRLF + TcSQLError())
	Else
		(SY1)->( DBCommit() )
	EndIf

	RestArea(aArea)
Return
Static Function MVGetCus(cParam1, cParam2)
Return SuperGetMv(cParam1,,cParam2)
/////////
Static Function NameFull(cParam1)
Return UsrFullName(cParam1)
