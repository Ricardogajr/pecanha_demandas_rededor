#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} F1206701
@Obs     Importação do arquivo .CSV para tabela SBZ
@Author  Lucas Graglia Cardozo
@Since   13/12/2018
@Version 12
@Project TEWBTY - Rede D'or São Luíz S.A - MAN0000007423048_EF_67 – Importação do arquivo .CSV para tabela SBZ
@Return
/*/
User Function F1206701()

	Local aArea    := GetArea()

	Local cPerg    := "FSW1206701"
	Local cTitulo  := "Importação do arquivo .CSV para tabela SBZ"

	Local nOpcao   := 0

	Local aButtons := {}
	Local aSays    := {}

	Private oProcess := Nil

	Pergunte(cPerg, .F.)

	AADD(aSays,OemToAnsi("Importação do arquivo .CSV para tabela SBZ"))
	AADD(aSays,"")
	AADD(aSays,OemToAnsi("Clique no botão PARAM para informar o arquivo que será importado."))
	AADD(aSays,"")
	AADD(aSays,OemToAnsi("Após isso, clique no botão OK."))

	AADD(aButtons, { 1, .T., {|o| nOpcao := 1, o:oWnd:End()}} )
	AADD(aButtons, { 2, .T., {|o| nOpcao := 2, o:oWnd:End()}} )
	AADD(aButtons, { 5, .T., {| | Pergunte(cPerg, .T.)     }} )

	FormBatch(cTitulo, aSays, aButtons,, 200, 530)

	If nOpcao = 1
		oProcess := MsNewProcess():New( { || F1206702(MV_PAR01) }, cTitulo, "Aguarde...", .F. )
		oProcess:Activate()
	EndIf

	RestArea(aArea)

Return

/*/{Protheus.doc} F1206702
@Obs     Função para Inclusão de Arquivo .CSV
@Author  Lucas Graglia Cardozo
@Since   13/12/2018
@Version 12
@Project TEWBTY - Rede D'or São Luíz S.A - MAN0000007423048_EF_67 – Importação do arquivo .CSV para tabela SBZ
@Return
/*/
Static Function F1206702(cArquivo)

	Local cFil      := ""
	Local cDados    := ""
	Local cLinha    := ""
	Local cProduto  := ""
	Local cArmazem  := ""

	Local nI        := 0
	Local nA        := 0
	Local nHdl      := 0
	Local nTamArq   := 0
	Local nTamLinha := 0
	Local nLinhas   := 0

	Local nCont     := 1

	Local aSepara   := {}
	Local aCampos   := {}
	Local aDados    := {}
	Local aLogsCab  := {}
	Local aLogsITE  := {}
	Local aLogsMsg  := {}

	Local lLogsCab   := .F.
	Local lExist     := .F.
	Local lOperation := .F.

	Default cArquivo := ""

	If (Upper(Right(AllTrim(cArquivo), 4)) != ".CSV" )
		MsgStop("Apenas arquivos com extensão CSV são aceitos!" + CRLF + "Verifique o arquivo informado!", "Atenção")
		Return
	EndIf

	If !File(cArquivo)
		MsgStop("O arquivo " + AllTrim(cArquivo) + " não existe, favor informar um arquivo existente!", "Atenção")
		Return
	EndIf

	nHdl := fOpen(cArquivo)

	If nHdl == -1
		If fError() == 516
			Alert("Feche a planilha que gerou o Arquivo.")
		EndIf
	EndIf

	If nHdl == -1
		MsgAlert("O arquivo de nome " + AllTrim(cArquivo) + " nao pode ser aberto! Verifique os parametros.", "Atencao!")
		Return
	Endif

	fSeek(nHdl, 0, 0)	
	nTamArq := fSeek(nHdl, 0, 2)	
	fSeek(nHdl, 0, 0)	
	fClose(nHdl)
	FT_fUse(cArquivo)   
	FT_fGoTop()        
	nTamLinha := Len(FT_fReadln()) 
	FT_fGoTop()	
	nLinhas := nTamArq / nTamLinha

	oProcess:SetRegua1(nLinhas) 

	While !FT_FEOF()
		oProcess:IncRegua1("Validando Linha: " + Alltrim(Str(nCont)))
		cLinha := FT_FREADLN()

		If !Empty(cLinha)
			AADD(aSepara, Separa(cLinha, ";", .T.))	
		EndIf

		FT_FSKIP()
		nCont++
	EndDo

	FT_FUse()
	fClose(nHdl)

	AADD(aCampos, aSepara[1])

	If aCampos[1][1] != "BZ_FILIAL"
		MsgStop("O Primeiro Campo da planilha de importação deve ser BZ_FILIAL.")
		Return
	ElseIf aCampos[1][2] != "BZ_COD"
		MsgStop("O Segundo Campo da planilha de importação deve ser BZ_COD.")
		Return
	ElseIf aCampos[1][3] != "BZ_LOCPAD"
		MsgStop("O Terceiro Campo da planilha de importação deve ser BZ_LOCPAD.")
		Return
	EndIf

	For nI := 2 To Len(aSepara)
		AADD(aDados, aSepara[nI])
	Next nI

	SX3->(DbSetOrder(2))
	For nA := 1 To Len(aCampos[1])
		oProcess:IncRegua1("Validando Campo: " + aCampos[1][nA])

		If !SX3->(DbSeek(aCampos[1][nA]))
			MsgStop("O campo " + aCampos[1][nA] + " ,informado no Arquivo de Importação não existe no Protheus, favor revise o Arquivo de Importação!" )
			Return
		EndIf
	Next nA

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	DbSelectArea("SBZ")
	SBZ->(DbSetOrder(1))

	DbSelectArea("NNR")
	NNR->(DbSetOrder(1))

	For nI := 1 To Len(aDados)
		cFil := aDados[nI][1]
		lExist := FWFilExist(cEmpAnt, cFil)
		If !lExist			
			If !lLogsCab 
				aLogsCab := aCampos
				lLogsCab := .T.
			EndIf
			AADD(aLogsITE, aDados[nI])
			AADD(aLogsMsg, {"A Filial: " + cFil + ", não existe no Protheus."})			
			Loop
		EndIf

		cProduto := aDados[nI][2]
		SB1->(DbGoTop())
		If !SB1->(DbSeek(xFilial("SB1") + cProduto))			
			If !lLogsCab 
				aLogsCab := aCampos
				lLogsCab := .T.
			EndIf
			AADD(aLogsITE, aDados[nI])
			AADD(aLogsMsg, {"O Produto: " + cProduto + ", não existe no Cadastro de Produtos do Protheus."})					
			Loop 
		EndIf

		cArmazem := aDados[nI][3]
		NNR->(DbGoTop())
		If !NNR->(DbSeek(cFil + cArmazem))		
			If !lLogsCab 
				aLogsCab := aCampos
				lLogsCab := .T.
			EndIf
			AADD(aLogsITE, aDados[nI])
			AADD(aLogsMsg, {"O Armazem: " + cArmazem + ", não existe no Cadastro de Armazem do Protheus."})			
			Loop 
		EndIf

		If !SBZ->(DbSeek(cFil + cProduto))
			oProcess:IncRegua1("Incluindo o Produto: " + AllTrim(cProduto))
			lOperation :=	.T.
		Else
			oProcess:IncRegua1("Atualizando o Produto: " + AllTrim(cProduto))
			lOperation :=	.F.
		EndIf

		RecLock("SBZ", lOperation)
		For nA := 1 To Len(aCampos[1])

			cDados := aDados[nI][nA]

			If ValType(&("SBZ->" + aCampos[1][nA])) == "D"
				cDados := cTOd(aDados[nI][nA])
			ElseIf ValType(&("SBZ->" + aCampos[1][nA])) == "N"
				cDados := Val(aDados[nI][nA])
			EndIf
			// ticket n° 11475210
			If aCampos[1][nA] <> 'BZ_XDESSB2' .And.  aCampos[1][nA] <> 'BZ_XDESSB3' .And. ;
				 aCampos[1][nA] <> 'BZ_XDESSB4' .And. aCampos[1][nA] <> 'BZ_XDESSB5' .And. ;
				 aCampos[1][nA] <> 'BZ_XDESCSB' .And. aCampos[1][nA] <> 'BZ_XDESCFO'
				&("SBZ->" + aCampos[1][nA]) := cDados
			EndIf 
			
			//Inicio - Thais Paiva - 11475210
			If aCampos[1][nA] == "BZ_XSUBIST"
				SBZ->BZ_XDESCSB := Posicione("SB1",1,xFilial("SB1")+cDados,"B1_DESC")
			ElseIf aCampos[1][nA] == "BZ_XSUBIS2"
				SBZ->BZ_XDESSB2 := Posicione("SB1",1,xFilial("SB1")+cDados,"B1_DESC")
			ElseIf aCampos[1][nA] == "BZ_XSUBIS3"
				SBZ->BZ_XDESSB3 := Posicione("SB1",1,xFilial("SB1")+cDados,"B1_DESC")
			ElseIf aCampos[1][nA] == "BZ_XSUBIS4"
				SBZ->BZ_XDESSB4 := Posicione("SB1",1,xFilial("SB1")+cDados,"B1_DESC")
			ElseIf aCampos[1][nA] == "BZ_XSUBIS5"
				SBZ->BZ_XDESSB5 := Posicione("SB1",1,xFilial("SB1")+cDados,"B1_DESC")
			ElseIf aCampos[1][nA] == "BZ_XFORNEC"
				SBZ->BZ_XDESCFO := Posicione("SA2",1,xFilial("SA2")+cDados,"A2_NOME")
			EndIf
			//Fim - Thais Paiva - 11475210

			// ticket n° 1147510
			/*
			If !Empty(SBZ->BZ_XDESSB2) .And. !Empty(SBZ->BZ_XDESSB3) .And. ;
				!Empty(SBZ->BZ_XDESSB4) .And. !Empty(SBZ->BZ_XDESSB5)
				If nA == Len(aCampos[1])
					SBZ->(MsUnlock())
					Exit
				EndIf 
			EndIf
			// Fim
			*/

		Next nA
		SBZ->(MsUnlock()) 

		Sleep(100)
	Next nI

	NRR->(DbCloseArea())
	SBZ->(DbCloseArea())
	SB1->(DbCloseArea())

	If !Empty(aLogsITE)
		F1206703(aLogsCab, aLogsITE, aLogsMsg)
	EndIf

	oProcess:IncRegua1("Atualização Finalizada...")

Return

/*/{Protheus.doc} F1206703
@Obs     Função para geração de planilha de LOGS
@Author  Lucas Graglia Cardozo
@Since   19/12/2018
@Version 12
@Project TEWBTY - Rede D'or São Luíz S.A - MAN0000007423048_EF_67 – Importação do arquivo .CSV para tabela SBZ
@Return
/*/
Static Function F1206703(aLogsCab, aLogsITE, aLogsMsg)

	Local aArea      := GetArea()

	Local cArquivo   := "Logs.xls"	
	Local cPath      := GetTempPath()

	Local oFWExcel := Nil
	//Local oExcel     := Nil	Thiago Marques - 23781643 - 12/06/2025 - Removido pois não é mais usado.

	Local nX         := 0
	Local nLog       := 0
	Local nLogAtu    := 0
	Local nTamLog    := 0
	Local nTamLogAtu := 0
	
	Local aLinhaLog  := {}

	Default aLogsCab := {}
	Default aLogsITE := {}
	Default aLogsMsg := {}
	
//	If !ApOleClient("MSExcel")
//		MsgAlert("Microsoft Excel não instalado!")
//		Return
//	EndIf

	oFWExcel := FWMsExcelEx():New()
	oFWExcel:AddworkSheet("Logs") 	
	oFWExcel:AddTable("Logs", "Logs de Importacao")

	For nX := 1 To Len(aLogsCab[1])
		If nX <= Len(aLogsCab[1])
			oFWExcel:AddColumn("Logs", "Logs de Importacao", aLogsCab[1][nX], 1, 1) 
		EndIf
	Next nX
	
	oFWExcel:AddColumn("Logs", "Logs de Importacao", "Motivo", 1, 1) 

	nTamLog := Len(aLogsITE)

	For nLog := 1 To nTamLog
		nTamLogAtu := Len(aLogsITE[nLog])
		For nLogAtu := 1 To nTamLogAtu
			AAdd(aLinhaLog, aLogsITE[nLog][nLogAtu]) 
		Next nLogAtu
		AAdd(aLinhaLog, aLogsMsg[nLog][1]) 
		oFWExcel:AddRow("Logs", "Logs de Importacao", aLinhaLog)
		aLinhaLog := {}
	Next nLog

	oFWExcel:Activate()
	oFWExcel:GetXMLFile(cPath + cArquivo)

	/* Thiago Marques - 23781643 - 12/06/2025 - Função removida pois não é mais usada, adicionada o ShellExecute para chamar direto do S.O.
	oExcel := MsExcel():New()            
	oExcel:WorkBooks:Open(cPath + cArquivo)     
	oExcel:SetVisible(.T.)                 
	oExcel:Destroy()*/
	ShellExecute("Open", "excel.exe", cPath + cArquivo, "", 3)

	RestArea(aArea)

Return
