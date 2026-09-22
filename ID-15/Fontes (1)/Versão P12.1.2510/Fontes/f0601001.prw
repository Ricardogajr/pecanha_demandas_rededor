#Include 'Protheus.ch'

/*/{Protheus.doc}  F0601001

@Author Nairan Alves Silva - Lucas Graglia Cardozo
@Since  16/11/2016
@Sample U_F0601001()

@Param aDados, array, [1] Nome Aba, [2] Nome Tabela, [3] aHeader, [4] Campos

@Obs Rotina Responsável por Exibir o Log das Integrações Realizadas Entre Protheus e ApData.

@Project MAN0000007423040_EF_010

/*/

User Function F0601001(aDados)
	
	Local aAbas		:= {}
	Local nX		:= 0
	Local nY		:= 0
	Local aListBoxs	:= {}
	Local aCampos	:= {}
	Local aInfs		:= {}
	Local aTabs		:= {}
	Local aBrowse	:= {}
	Local aDicBrw	:= {}
	Local aHeader	:= {}
	Local cbLine	:= ""
	Local cSep		:= ""
	Local oDlg		:= Nil
	Local oPanel	:= Nil
	Local cPerg    	:= "FSWF060101" //PadR ("FSWF060101", Len(SX1->X1_GRUPO)) Thais Paiva - Compatibilização P27
	Local nLimite 	:= GETMV("MV_F6101",,5000)
	Local cTabsErr	:= ""
	Local aTFolder	:= {}
	
	Private oDicBrw	:= Nil
	Default aDados := {}
		
	pergunte(cPerg,.T.)	
	
	//Alterar para Validar a estrutura do Array
	If Empty(aDados)
		Alert("Dados Incorretos")
		Return
	Endif
	
	For nX := 1 To Len(aDados)
		If Len(StrTokArr2(aDados[nX][3],",")) <> Len(StrTokArr2(aDados[nX][4],","))
			Conout("Estrutura aHeader diferente aCols para ABA: " + aDados[nX][1])
			Loop
		Endif	
		AAdd(aAbas,aDados[nX][1])
		AAdd(aTabs,aDados[nX][2])
		AAdd(aHeader,aDados[nX][3])
		AAdd(aListBoxs,StrTokArr2(aDados[nX][3],","))
		AAdd(aCampos,aDados[nX][4])
	Next
	
	aBrowse	:= AClone(aAbas)
	aInfs		:= AClone(aAbas)
	aDicBrw	:= AClone(aAbas)
	aTFolder	:= AClone(aAbas)
	
	
	DEFINE DIALOG oDlg TITLE "Consulta de Log Tabelas de Interface" FROM 000, 000  TO 420, 900 PIXEL
	
	// Cria a Folder
	oTFolder := TFolder():New( 0,0,aTFolder,,oDlg,,,,.T.,,560,484 )
	oTFolder :align:= CONTROL_ALIGN_ALLCLIENT
	
	oPanel:= tPanel():New(010,010,,,,.T.,,,,030,030)
	@ 010, 200 BUTTON oButton4 PROMPT "Atualizar Aba"	 	SIZE 037, 012 OF oPanel PIXEL ACTION AtuTabs(aTabs, aCampos, aAbas, cTabsErr, oTFolder, aInfs, aBrowse)
	@ 010, 250 BUTTON oButton4 PROMPT "Reprocessar"	 		SIZE 037, 012 OF oPanel PIXEL ACTION Reproc(aBrowse[oTFolder:nOption],aTabs[oTFolder:nOption])
	@ 010, 300 BUTTON oButton1 PROMPT "Legenda" 			SIZE 037, 012 OF oPanel PIXEL ACTION Leadleg()
	@ 010, 350 BUTTON oButton2 PROMPT "Exp. Excel" 			SIZE 037, 012 OF oPanel PIXEL ACTION processa( {|| ExpExel(aTabs[oTFolder:nOption],aCampos[oTFolder:nOption],aHeader[oTFolder:nOption]) }, "Aguarde...", "Exportando para Excel.", .f.)
	@ 010, 400 BUTTON oButton3 PROMPT "Sair" 				SIZE 037, 012 OF oPanel PIXEL ACTION oDlg:End()
	oPanel:align:= CONTROL_ALIGN_BOTTOM
	//AtuAba(@oTFolder)
	//oTFolder:bSetOption := {|nAba| AtuAba(@oTFolder,nAba)}
	
	For nX := 1 To Len(aAbas)
		//Fazer aqui a chamada para o preenchimento correto do Array
		processa( {|| aInfs[nX] := AClone(CarArray(aTabs[nX],aCampos[nX],aAbas[nX], @cTabsErr)) }, "Aguarde...", "Executando rotina.", .f.)
		aBrowse[nX] := TWBrowse():New( 01 , 01, 260,184,,aListBoxs[nX],,oTFolder:aDialogs[nX],,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
		aBrowse[nX]:SetArray(aInfs[nX])
		
		cSep 	:= ""
		cbLine := "{||{" 
		If Len(aInfs[nX]) > 0 //Adic p corrigir ERRO Array Of Bounds
			For nY := 1 To Len(aInfs[nX][01])
				cbLine += cSep + "aInfs[" + AllTrim(Str(nX)) + "][aBrowse[" + AllTrim(Str(nX)) + "]:nAt," + AllTrim(Str(nY)) + "]"
				cSep := ','
			Next
		Endif	
		cbLine += "}}"
		
		aBrowse[nX]:bLine := &(cbLine)
		aBrowse[nX]:align:= CONTROL_ALIGN_ALLCLIENT
	Next
	
	If !Empty(cTabsErr)
		Aviso("Aviso", "O filtro selecionado ultrapassou o limite de " + cValToChar(nLimite) + " registros para as abas " + Left(cTabsErr, Len(cTabsErr)-2) + ". Melhore o filtro selecionado ou importe a consulta para Excel.")
	EndIf
	
	ACTIVATE DIALOG oDlg CENTERED
	
Return

////////////////////////////////////////////
//Carrega o array com os dados do listbox //
////////////////////////////////////////////
Static Function CarArray(cTab, cCampos, cAba, cTabsErr)
	
	Local cMsgError 	:= ""
	Local cQuery    	:= ""
	Local cNewAlias 	:= cTab
	Local aConsul 	:= {}
	Local nNumRec 	:= 0
	Local nX			:= 0
	Local nY			:= 0
	Local nLimite 	:= GETMV("MV_F6101",,5000)
	Local aCampos		:= StrTokArr2(cCampos,",")
	Local cAux			:=	""
	Local nPos			:= 0
	
	ProcRegua(nLimite)
	
	For nX := 1 To Len(aCampos)
		nPos := AT("_", AllTrim(aCampos[nX])) + 1
		cAux += aCampos[nX] + "   " + SubStr(AllTrim(aCampos[nX]),nPos,10)
		If nX  != Len(aCampos)
			cAux += " , "
		EndIf
	Next
	
	// Conexao com base Externa
	If !U_F06001C1(@cMsgError)
		Conout(cMsgError)
		Return .F.
	EndIf
	
	// Consulta Registros A PROCESSAR
	cQuery := " SELECT " + cAux + " "
	cQuery += " FROM " + cTab + " "
	cQuery += " WHERE "
	/*If 	cTab == "EF06007"
		cQuery += " " + cTab + "_FILIALORI = '" + cFilAnt + "' " "
	Else
		cQuery += " " + cTab + "_FILIAL = '" + cFilAnt + "' " "
	Endif
	*/
	
	cQuery += " "    + cTab + "_FILIAL >= '" + MV_PAR10 + "' " 
	cQuery += " AND " + cTab + "_FILIAL <= '" + MV_PAR11 + "' " 	
	
	If !Empty(MV_PAR01) .And. !Empty(MV_PAR02)
		cQuery += " AND " + cTab + "_DTTRANSAC >= '" + dtos(MV_PAR01) + "' "
		cQuery += " AND " + cTab + "_DTTRANSAC <= '" + dtos(MV_PAR02) + "' "
	EndIF
	If !Empty(MV_PAR03) .And. !Empty(MV_PAR04)
		cQuery += " AND " + cTab + "_HRTRANSAC >= '" + MV_PAR03 + "' "
		cQuery += " AND " + cTab + "_HRTRANSAC <= '" + MV_PAR04 + "' "
	EndIf
	If !Empty(MV_PAR09) .And. MV_PAR09 <= 4
		cQuery += " AND " + cTab + "_STATUS = '" + cValToChar(MV_PAR09) + "' "
	EndIf
	If !Empty(MV_PAR05) .And. !Empty(MV_PAR06) .And. MV_PAR09 <= 4
		cQuery += " AND " + cTab + "_DTPROCESS >= '" + dtos(MV_PAR05) + "' "
		cQuery += " AND " + cTab + "_DTPROCESS <= '" + dtos(MV_PAR06) + "' "
	EndIf
	If !Empty(MV_PAR07) .And. !Empty(MV_PAR08) .And. MV_PAR09 <= 4
		cQuery += " AND " + cTab + "_HRPROCESS >= '" + MV_PAR07 + "' "
		cQuery += " AND " + cTab + "_HRPROCESS <= '" + MV_PAR08 + "' "
	EndIf
	
	//Funcao para SELECT no Banco do ApData
	If U_F06001C6(cQuery, cNewAlias, @cMsgError)
		If Select(cNewAlias) > 0
			Count To nNumRec
			(cNewAlias)->(DbGoTop())
			
			If nNumRec > nLimite
				cTabsErr += "'" + cAba + "', "
			EndIf
			
			For nX := 1 To nLimite
				
				If (cNewAlias)->(EOF()) .And. nX > 1
					Exit
				Endif		
				AAdd(aConsul,StrTokArr2(cCampos,","))
				nPos := AT("_", AllTrim(aConsul[nX][1])) + 1
				For nY := 1 To Len(aConsul[1])	
					If nY == 1
						aConsul[nX][nY] := RetStatus((cNewAlias)->&(SubStr(AllTrim(aConsul[nX][nY]),nPos,10)))
					Else
						aConsul[nX][nY] := StrTran(StrTran((cNewAlias)->&(SubStr(AllTrim(aConsul[nX][nY]),nPos,10)),";","."),CHAR(10),)
					Endif
				Next		
				(cNewAlias)->(dBSkip())
				IncProc("Executando rotina.")
			Next
			//Fecha a area
			(cNewAlias)->(DbCloseArea())
		Endif
	Else
		AAdd(aConsul, {cMsgError})
	Endif
	
	// Fecha Conexao com o Banco de Integracao
	cMsgError := ""
	U_F06001C2(@cMsgError)
	
Return aConsul

/////////////////////////////////////
// Reprocessa o Arquivo já enviado //
/////////////////////////////////////

Static Function Reproc(oBrowse,cTab)
Local nAt 			:= oBrowse:nAt
Local aHeader		:= AClone(oBrowse:aHeaders)
Local aCols			:= AClone(oBrowse:aArray)
Local aAreaPA6		:= PA6->(GetArea())
Local nPosId		:= AScan(aHeader,{|x| Upper(Alltrim(x))=="ID"}) 
Local nPosFil		:= AScan(aHeader,{|x| Upper(Alltrim(x))=="FILIAL"}) 

PA6->(DbSetOrder(1))
If PA6->(DbSeek(AllTrim(aCols[nAt][nPosFil]) + AllTrim(aCols[nAt][nPosId])))
	U_F0600901(PA6->PA6_FUNC,PA6->PA6_RECNOT,PA6->PA6_ALIAS,PA6->PA6_CHALIAS,PA6->PA6_OBS,CTOD(""),PA6->PA6_OPERAC, PA6->PA6_FILIAL)
	StartJob("U_F0600103",GetEnvServer(),.F.,{"01",AllTrim(aCols[nAt][nPosFil])})
	Aviso("Atenção","Dados reprocessados com sucesso.")
Else
	Alert("Não foi possível reprocessar os dados.")
EndIf

RestArea(aAreaPA6)
Return
///////////////////////
//Exporta para Excel	//
///////////////////////
Static Function ExpExel(cTab,cCampos,cHeader)
	
	Local cMsgError 	:= ""
	Local cQuery    	:= ""
	Local cNewAlias 	:= cTab
	Local aConsul		:= {}
	Local cTxt			:= StrTran(cHeader,",",";") + CRLF
	Local nNumRec 	:= 0
	Local nX			:= 0
	Local nY			:= 0
	Local nHandle		:= 0
	Local cArqLoc		:= GetTempPath()
	Local cNomeArq	:= DTOS(date()) + StrTran(Time(),":","") + '.CSV'
	Local aCampos		:= StrTokArr2(cCampos,",")
	Local cAux			:=	""
	Local nPos			:= 0
	
	ProcRegua(nNumRec)
	
	For nX := 1 To Len(aCampos)
		nPos := AT("_", AllTrim(aCampos[nX])) + 1
		cAux += aCampos[nX] + "   " + SubStr(AllTrim(aCampos[nX]),nPos,10)
		If nX  != Len(aCampos)
			cAux += " , "
		EndIf
	Next
	
	// Conexao com base Externa
	If !U_F06001C1(@cMsgError)
		Conout(cMsgError)
		Return .F.
	EndIf
	
	// Consulta Registros A PROCESSAR
	cQuery := " SELECT " + cAux + " "
	cQuery += " FROM " + cTab + " "
	cQuery += " WHERE "	
	
	cQuery += " "    + cTab + "_FILIAL >= '" + MV_PAR10 + "' " 
	cQuery += " AND " + cTab + "_FILIAL <= '" + MV_PAR11 + "' " 
	
	If !Empty(MV_PAR01) .And. !Empty(MV_PAR02)
		cQuery += " AND " + cTab + "_DTTRANSAC >= '" + dtos(MV_PAR01) + "' "
		cQuery += " AND " + cTab + "_DTTRANSAC <= '" + dtos(MV_PAR02) + "' "
	EndIF
	If !Empty(MV_PAR03) .And. !Empty(MV_PAR04) 
		cQuery += " AND " + cTab + "_HRTRANSAC >= '" + MV_PAR03 + "' "
		cQuery += " AND " + cTab + "_HRTRANSAC <= '" + MV_PAR04 + "' "
	EndIf
	If !Empty(MV_PAR09) .And. MV_PAR09 <= 4
		cQuery += " AND " + cTab + "_STATUS = '" + cvaltochar(MV_PAR09) + "' "
	EndIf
	If !Empty(MV_PAR05) .And. !Empty(MV_PAR06) .And. MV_PAR09 <= 4
		cQuery += " AND " + cTab + "_DTPROCESS >= '" + dtos(MV_PAR05) + "' "
		cQuery += " AND " + cTab + "_DTPROCESS <= '" + dtos(MV_PAR06) + "' "
	EndIf
	If !Empty(MV_PAR07) .And. !Empty(MV_PAR08) .And. MV_PAR09 <= 4
		cQuery += " AND " + cTab + "_HRPROCESS >= '" + MV_PAR07 + "' "
		cQuery += " AND " + cTab + "_HRPROCESS <= '" + MV_PAR08 + "' "
	EndIf
	
	//Funcao para SELECT no Banco do ApData
	If U_F06001C6(cQuery, cNewAlias, @cMsgError)
		If Select(cNewAlias) > 0
			Count To nNumRec
			(cNewAlias)->(DbGoTop())
			nHandle := FCREATE(cArqLoc + cNomeArq)
			If nHandle < 0
				Alert("Erro na geração do Arquivo")
			Endif
			nX := 0
			
			For nX := 1 to nNumRec
				
				AAdd(aConsul,StrTokArr2(cCampos,","))
				nPos := AT("_", AllTrim(aConsul[nX][1])) + 1
				For nY := 1 To Len(aConsul[1])
					cTxt += StrTran(StrTran((cNewAlias)->&(SubStr(AllTrim(aConsul[nX][nY]),nPos,10)),";","."),CHAR(10),) + ";"
				Next
				cTxt += + CRLF
				FWrite(nHandle,cTxt)
				cTxt := ""
				(cNewAlias)->(dBSkip())
				IncProc("Exportando dados para Excel.")
				
			Next
			//Fecha a area
			FClose(nHandle)
			(cNewAlias)->(DbCloseArea())
			shellExecute("Open", cArqLoc + cNomeArq,"Null" , "C:\", 1 )
		Endif
	Endif
	
	// Fecha Conexao com o Banco de Integracao
	cMsgError := ""
	U_F06001C2(@cMsgError)
	
Return Nil

////////////////////////////////
//Retorna as cores da legenda //
////////////////////////////////

Static Function RetStatus(cStatus)
	Local cRet	:= ""
	cStatus := AllTrim(cStatus)
	If Empty(cStatus)
		cRet := LoadBitmap(GetResources(), "BR_BRANCO")
	ElseIf cStatus == '1'
		cRet := LoadBitmap(GetResources(), "BR_AZUL")
	ElseIf cStatus == '2'
		cRet := LoadBitmap(GetResources(), "BR_AMARELO")
	ElseIf cStatus == '3'
		cRet := LoadBitmap(GetResources(), "BR_VERDE")
	ElseIf cStatus == '4'
		cRet := LoadBitmap(GetResources(), "BR_VERMELHO")
	Endif
	
Return cRet

//////////////////////
// Adiciona Legenda //
//////////////////////

Static Function Leadleg()
	
	Local aLegenda
	
	aLegenda := {{"BR_BRANCO","Sem Registro"},;
		{"BR_AZUL","Enviado"},;
		{"BR_AMARELO", "Processando"},;
		{"BR_VERDE", "Processado"},;
		{"BR_VERMELHO","Erro"}}
	
	BrwLegenda(Padc("Legenda",60,''),"Legenda",aLegenda)
	
Return

Static Function AtuTabs(aTabs, aCampos, aAbas, cTabsErr, oTFolder, aInfs, aBrowse)
	
	Local nX	:= oTFolder:nOption
	Local nY	:= 0
	
	processa( {|| aInfs[nX] := AClone(CarArray(aTabs[nX],aCampos[nX],aAbas[nX], @cTabsErr)) }, "Aguarde...", "Executando rotina.", .f.)
	aBrowse[nX]:SetArray(aInfs[nX])
		
	cSep 	:= ""
	cbLine := "{||{" 
	If Len(aInfs[nX]) > 0 //Adic p corrigir ERRO Array Of Bounds
		For nY := 1 To Len(aInfs[nX][01])
			cbLine += cSep + "aInfs[" + AllTrim(Str(nX)) + "][aBrowse[" + AllTrim(Str(nX)) + "]:nAt," + AllTrim(Str(nY)) + "]"
			cSep := ','
		Next
	Endif	
	cbLine += "}}"
	
	aBrowse[nX]:bLine := &(cbLine)
		
Return