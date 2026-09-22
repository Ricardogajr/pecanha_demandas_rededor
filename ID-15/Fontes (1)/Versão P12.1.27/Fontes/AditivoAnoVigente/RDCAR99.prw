#INCLUDE "protheus.ch"
/*/{Protheus.doc} RDCAR99
Rotina responsável por importar uma Solicitação de pagamento por planilha.
@type function
@version 1.0 
@author Ricardo Junior
@since 15/02/2023
@return nil, nulo
/*/
User Function RDCAR99()

	Local cDirectory 	:= ""
	Local cMainPath 	:= "C:\"
	Local aArquivos 	:= {}
	Local cDriver		:= ""
	Local lRet 			:= .T.
	Local aArea			:= GetArea()
	Private aLog 		:= {}
	Private cTabela     := ""
	Private _nLinha     := 0
	Private lPrim 		:= .T.
	Private cRot        := ""
	Private cMaster     := ""
	Private cIndexF3	:= ""
	Private cCampoAtu	:= ""
	Private aExec		:= {}
	Private _nQtdOK 	:= 00
	Private _nQtdError 	:= 00
	Private lValidou	:= .F.
	Private oProcess 	:= Nil

	cDriver := "|- LOCAL -|"

	cDirectory 	:= AllTrim(cGetFile('*.csv|*.csv','Importação do arquivo Solicitação de pagamento.', 0,cMainPath, .T., GETF_MULTISELECT + GETF_LOCALHARD, .T.))
	aArquivos 	:= Separa(cDirectory, "|")

	If Len(aArquivos) > 0
		//	Processa( {|| fValidaTxt(aArquivos)}, "Aguarde...", "Validando arquivos selecionados...",.F.)
		oProcess := MsNewProcess():New( { || fValidaTxt(aArquivos) } , "Validando arquivos selecionados..." , "Aguarde..." , .F. )
		oProcess:Activate()
	Else
		Alert("Não foram selecionados arquivos para importação.")
	Endif
	RestArea(aArea)
Return

/*/{Protheus.doc} fValidaTxt
Valida arquivo para importação.
@type function
@version 1.0 
@author Ricardo Junior
@since 2/15/2023
@param aArquivos, Array , arquivos selecionados.
@return nil, Nulo
/*/
Static function fValidaTxt(aArquivos)
	Local nX := 01
	Local nY := 01
	Local nA := 01
	Local aDados := {}
	Local aCab := {}
	Local aIt := {}
	Local aCabAux := {}
	Local aItAux := {}
	Local aError := {}
	oProcess:SetRegua1(Len(aArquivos))
	For nA := 01 To Len(aArquivos)
		FT_FUSE(AllTrim(aArquivos[nA]))
		nLastRec := FT_FLASTREC()
		_nLinha := 0
		oProcess:IncRegua1("Arquivo: ..." + SubStr(aArquivos[nA], Len(aArquivos[nA])-20, Len(aArquivos[nA])))

		/*aAdd(aLog, {"-----------------------------------------------------------", 0})
		aAdd(aLog, {"Iniciando leitura do arquivo: " + aArquivos[nX], 0})
		aAdd(aLog, {"Data da importação: " + DToC(dDataBase), 0})
		aAdd(aLog, {"Importação realizada pelo usuário: " + cUserName, 0})
		aAdd(aLog, {"-----------------------------------------------------------", 0})
		*/
		If nLastRec <= 0
			aAdd(aLog, {"O Arquivo: " + aArquivos[nA] +" está vazio.", 0})
			Loop
		EndIf

		//ProcRegua(nLastRec)
		FT_FGOTOP()
		lPrim := .T.
		lRet := .T.
		While !FT_FEOF()
			//IncProc("Lendo arquivo texto...    Linha: " + cValToChar(_nLinha) )
			cLinha := FT_FREADLN()
			_nLinha := _nLinha + 1
			if lPrim
				lPrim := .F.
				lSegun := .T.
			elseif lSegun
				aCabec := StrTokArr2(cLinha, ";",.T.)
				lSegun := .F.
				aRet := fvalidDic(aCabec)
				if !aRet[1]
					Alert(aRet[2])
					lRet := .F.
					Exit
				endif
			else
				aAdd(aDados, StrTokArr2(cLinha, ";",.T.))
			endif
			FT_FSKIP()
		EndDo
		if !lRet
			Return
		endif
		cCmpCabec := U_RDCAR99A('MODEL_SC7p')
		//cCmpCabec := "C7_EMISSAO|C7_FORNECE|C7_LOJA|C7_COND|C7_XTIPO|C7_XESPECI|C7_XDOC|C7_XSERIE|C7_XDTEMI|C7_XDTVEN|C7_XRETENC|C7_XNUMPRO|C7_XTPCJU"
		DbSelectArea("SE2")
		SE2->(DbSetOrder(06))
		nPosFil := aScan(aCabec, {|x| AllTrim(Upper(x)) == "C7_FILIAL" })
		nPosFor := aScan(aCabec, {|x| AllTrim(Upper(x)) == "C7_FORNECE" })
		nPosLoj := aScan(aCabec, {|x| AllTrim(Upper(x)) $ "C7_LOJA" })
		nPosSer := aScan(aCabec, {|x| AllTrim(Upper(x)) $ "C7_XSERIE" })
		nPosDoc := aScan(aCabec, {|x| AllTrim(Upper(x)) $ "C7_XDOC" })
		aSort(aDados, , , {|x, y| x[1]+x[3]+x[4]+x[8]+x[9]+x[13] < y[1]+y[3]+y[4]+y[8]+y[9]+y[13]})
		cChaveAux := PadR(aDados[1][nPosFil], TamSx3("C7_FILIAL")[01]);
			+PadR(aDados[1][nPosFor], TamSx3("C7_FORNECE")[01]);
			+PadR(aDados[1][nPosLoj], TamSx3("C7_LOJA")[01]);
			+PadR(aDados[1][nPosSer], TamSx3("C7_XSERIE")[01]);
			+PadR(aDados[1][nPosDoc], TamSx3("C7_XDOC")[01])
		cFilBkp := cFilAnt
		oProcess:SetRegua2(len(aDados))
		For nX := 01 To len(aDados)
			cFilAnt := PadR(aDados[nX][nPosFil], TamSx3("C7_FILIAL")[01])
			cChave :=  PadR(aDados[nX][nPosFil], TamSx3("C7_FILIAL")[01]);
				+PadR(aDados[nX][nPosFor], TamSx3("C7_FORNECE")[01]);
				+PadR(aDados[nX][nPosLoj], TamSx3("C7_LOJA")[01]);
				+PadR(aDados[nX][nPosSer], TamSx3("C7_XSERIE")[01]);
				+PadR(aDados[nX][nPosDoc], TamSx3("C7_XDOC")[01])
			oProcess:IncRegua2("Processando... "+cChave)
			//(cAliasSE2)->E2_FILIAL+(cAliasSE2)->E2_FORNECE+(cAliasSE2)->E2_LOJA+(cAliasSE2)->E2_PREFIXO+(cAliasSE2)->E2_NUM
			If cChave == cChaveAux
				If SE2->(!DbSeek(cChave))
					For nY := 01 To Len(aDados[nX])
						lExist := aCabec[nY] $ cCmpCabec
						if lExist
							aAdd(aCabAux, {aCabec[nY], aDados[nX][nY], Nil})
						else
							aAdd(aItAux, {aCabec[nY], aDados[nX][nY], Nil})
						endif
					next nY
				else
					FT_FSKIP()
					Loop
				endif
				if Len(aCab) <= 0
					aCab := aCabAux
				EndIf
				aAdd(aIt, aItAux)
			Else
				aAdd(aError, U_RDCAR98(aCab, aIt, 3, .F.))
				aCab := {}
				aIt := {}
				cFilAnt := PadR(aDados[nX][nPosFil], TamSx3("C7_FILIAL")[01])
				For nY := 01 To Len(aDados[nX])
					lExist := aCabec[nY] $ cCmpCabec
					if lExist
						aAdd(aCabAux, {aCabec[nY], aDados[nX][nY], Nil})
					else
						aAdd(aItAux, {aCabec[nY], aDados[nX][nY], Nil})
					endif
				next nY
				if Len(aCab) <= 0
					aCab := aCabAux
				EndIf
				aAdd(aIt, aItAux)
			EndIf
			cChaveAux := cChave
			aCabAux := {}
			aItAux := {}
		Next nX
		if Len(aCab) > 0 .And. Len(aIt) > 0
			aAdd(aError, U_RDCAR98(aCab, aIt, 3, .F.))
		endif
		aCab := {}
		aIt := {}
		aDados := {}
		aCabec := {}
	Next nA
	cFilAnt := cFilBkp
	GeraLog(aError)
	FT_FUSE()

return

/*/{Protheus.doc} fValidDic
Valida Campos do Dicionário.
@type function
@version 1.0
@author Ricardo Junior
@since 16/02/2023
@param aDados, array, Nome dos campos
@return lRet, Se validou.
/*/
Static function fValidDic(aDados)
	Local lRet := .T.
	Local nX := 00
	Local cMsg := ""

	DbSelectArea("SC7")
	for nX := 01 To Len(aDados)
		If FieldPos(aDados[nX]) <= 0
			lRet := .F.
			cMsg := "O Campo " + aDados[nX] + " não existe no dicionário de dados. Por favor, verificar."
			Exit
		endif
	next nX

return { lRet, cMsg }
/*/{Protheus.doc} GeraLog
description Gerar arquivo de log
@type function
@version 1.0
@author Ricardo Junior
@since 2/22/2023
@param aMessage, array, param_description
@return variant, return_description
/*/
Static Function GeraLog(aMessage)
	local cArqLog	:= "Log" + FwTimeStamp(1) + ".csv"
	local cPath 	:= ""
	local nHandle  	:= 00
	local nX,nY		:= 00
	Local cCRLF := Chr(13) + Chr(10)
	local cDirLog := GetTemppath()

	//fCriaDirMA(cDirLog)

	cPath := cDirLog + cArqLog

	nHandle := fcreate(cPath)
	If nHandle  >= 0
		fWrite(nHandle, "USUARIO:" + AllTrim(cUserName)+ ';' + "DATA:" + DToC(dDataBase) + ';' + "HORA:" +  Time() + ';'+ cCRLF )
		fWrite(nHandle, "FILIAL;NF;SERIE;FORNECE;NUMERO;MENSAGEM;"+ cCRLF )
		//fWrite(nHandle, Replicate("#",71) +CRLF)
		//fWrite(nHandle, "Data: " + FwTimeStamp(1) + CRLF )
		//fWrite(nHandle, "Total Registros: " + cValToChar(Len(aMessage)) + CRLF )
		//fWrite(nHandle, "Usuário: " + cUserName + CRLF )
		For nY := 01 To Len(aMessage)
			for nX := 01 To Len(aMessage[nY])//Ultima posição do log
				if ValType(aMessage[nY][nX]) == "C"
					fWrite(nHandle, aMessage[nY][nX] + ';' + cCRLF)
				endif
			Next nx
		next nY
	endif
	fWrite(nHandle, cCRLF)
	fclose(nHandle)
	shellExecute("Open", cPath,"Null" , "C:\", 1 )
return


User Function RDCAR99A(cModel)
	Local cCmpCabec := ""
	oModel2 := FWLoadModel('F0100401')
	oAux := oModel2:GetModel(cModel)
	oStrC7p := oAux:GetStruct()
	aAux := oStrC7p:GetFields()
	for nX := 01 To Len(aAux)
		cCmpCabec += aAux[nX][1] + "|"
	next nX

Return cCmpCabec
