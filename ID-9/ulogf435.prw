#Include "TOTVS.ch"
/*/{Protheus.doc} uLogF435
Função responsável por gerar o arquivo de log para o XFINA435
@type function
@version P122410 
@author Ricardo Junior
@since 3/3/2026
@param aDados, array, dados para escrever no arquivo
@param cFunName, character, nome da função
@return variant, nulo
/*/
User Function uLogF435(aDados, cFunName, cErr)
	Local cNome 	:= cFilAnt + "_" + FWTimeStamp(1) + "_log.txt"
	Local nX 		:= 0
	Local cPasta 	:= ""
	Local cCaminho 	:= ""
	Local cArq 		:= ""

	Default aDados   := {}
	Default cFunName := "XFINA435"
	Default cErr := ""
	//RpcSetEnv("01", "01310002") - Utilizado para teste

	cPasta 	    := "SIGADOC/system_logs"
	cCaminho 	:= cPasta + "/" + cFunName + "/" + DToS(Date())
	cArq 		:= cCaminho + "/" + cNome
	//Cria o arquivo
	if !ExistDir(cCaminho)
		aDirs := StrToArray(cCaminho, "/")
		cAux := ""
		For nX := 1 To Len(aDirs)
			cAux += aDirs[nX] + "/"
			if !ExistDir(cAux)
				MakeDir(cAux)
			endif
		next nX
	endif

	If File(cArq)
		FErase(cArq)//Se existir, apaga.
	EndIf

	oFWriter := FWFileWriter():New(cArq, .T.)

	If !(oFWriter:Create())
		Final("Houve um erro ao criar o arquivo - " + oFWriter:Error():Message)
		Return
	endif

	oFWriter:Write("--------------------------------------------------------------------------" + CRLF)
	oFWriter:Write("Função (FunName):  " + cFunName + CRLF)
	oFWriter:Write("Ambiente:          " + GetEnvServer() + CRLF)
	oFWriter:Write("Log iniciado, data [" + dToC(Date()) + "] e hora [" + Time() + "]" + CRLF)
	oFWriter:Write("--------------------------------------------------------------------------" + CRLF)
	if !Empty(cErr)
		oFWriter:Write("OCORREU ERROR LOG NA ROTINA: " + CRLF + AllTrim(cErr) + CRLF)
	else
		For nX := 01 To Len(aDados)
			oFWriter:Write(" Linha: " + cValToChar(aDados[nX][2]) + " - " + aDados[nX][1] + CRLF)
		Next nX
	endif
	oFWriter:Write("--------------------------------------------------------------------------" + CRLF)
	oFWriter:Write("FIM DO LOG" + CRLF)
	oFWriter:Write("--------------------------------------------------------------------------" + CRLF)
	oFWriter:Close()
Return

/*/{Protheus.doc} GetLog435
Função responsável por abrir o log da rotina XFINA435
@type function
@version P12 
@author Ricardo Junior
@since 3/12/2026
@return variant, Null
/*/
User Function GetLog435()
	Local cDir    := "\SIGADOC\system_logs\XFINA435\"//GetSrvProfString("RootPath","") + "SIGADOC\" + SuperGetMv("MV_XFSLOG",,"system_logs") + "\uLogF435\"
	Local aArqs   := {}
	Local aLista  := {}
	Local i       := 0
	Local nX	  := 0

	aArqs := Directory(cDir + "*", "D")
	If Len(aArqs) <= 2
		FWAlertInfo("Nenhum arquivo encontrado em: " + cDir, "Atenção")
		Return
	EndIf

	DEFINE DIALOG oDlg TITLE "Logs rotina XFINA435" FROM 180,180 TO 550,700 PIXEL	    // Cria a Tree
	oTree := DbTree():New(0,0,160,260,oDlg,,,.T.)		    // Insere itens

	cSeq := "000001"
	cDateAux := DToS(Date() - SuperGetMv("MV_XDF435",,1))
	For i := 1 To Len(aArqs)
		if "." $ aArqs[i][1] .Or. aArqs[i][1] <= cDateAux
			Loop
		endif
		oTree:AddItem(aArqs[i][1]+ Space(50), cSeq, "FOLDER5" ,"FOLDER6",,,1)
		aAux := Directory(cDir + aArqs[i][1]+ "\*", "A")
		cSeqAux := "000"
		For nX := 01 To Len(aAux)
			cSeqAux := Soma1(cSeqAux)
			If oTree:TreeSeek(cSeq)
				oTree:AddItem(aAux[nX][1] + Space(30), cSeq + "." +cSeqAux, "DBG05",,,,2)
				aAdd(aLista, {aAux[nX][1], cDir + aArqs[i][1]+ "\" +aAux[nX][1]})  // aArqs[i][1] = nome do arquivo
			endif
		Next nX
		cSeq := Soma1(cSeq)
	Next i

	oTree:TreeSeek("000001")
	TButton():New( 172,02,"Baixar", oDlg,{|| fGetArq(oTree:GetPrompt(.T.), aLista) }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 172,52,"Sair", oDlg,{|| oDlg:end() }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE DIALOG oDlg CENTERED
	//oTree:EndTree()
Return

/*/{Protheus.doc} fGetArq
Baixa o arquivo do servidor
@type function
@version P12 
@author Ricardo Junior
@since 3/11/2026
@return variant, Null
/*/
Static function fGetArq(cArq, aLista)
	Local nPos := aScan(aLista, {|x| AllTrim(x[1]) == AllTrim(cArq)})

	if nPos > 0
		cArqAux  := aLista[nPos][2]
		cGetTemp := GetTempPath(.T., .F.)

		If CpyS2T(cArqAux, cGetTemp)
			aName := StrToArray(cArqAux, "\")
			ShellExecute("open", cGetTemp + "\" + aName[Len(aName)], "", "C:\", 1)
		Else
			FwAviso("Não foi possível baixar o arquivo: " + cArqAux)
		EndIf
	else
		FwAviso("Não foi possível baixar o arquivo: " + cArq)
	endif
Return
