#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#include "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF Chr(13) + Chr(10)

//////////////////////////////////////////////////////////////////////////////////////
//+--------------------------------------------------------------------------------+//
//| PROGRAMA  | AMS00015 | AUTORA| Thais Paiva              | DATA | 09/12/2020    |//
//+--------------------------------------------------------------------------------+//
//| DESCRICAO  | Função: Importação de arquivo CSV para inclusão de solicitação de |//
//|            | compras                                                           |//
//+--------------------------------------------------------------------------------+//
//////////////////////////////////////////////////////////////////////////////////////

User Function AMS00015()

Local aArea    := GetArea()

Local cPerg    := "AMS00015"
Local cTitulo  := "Importação do arquivo .CSV para tabela SC1"

Local nOpcao   := 0

Local aButtons := {}
Local aSays    := {}

Private oProcess := Nil

Pergunte(cPerg, .F.)

AADD(aSays,OemToAnsi("Importação do arquivo .CSV para tabela SC1"))
AADD(aSays,"")
AADD(aSays,OemToAnsi("Clique no botão PARAM para informar o arquivo que será importado."))
AADD(aSays,"")
AADD(aSays,OemToAnsi("Após isso, clique no botão OK."))

AADD(aButtons, { 1, .T., {|o| nOpcao := 1, o:oWnd:End()}} )
AADD(aButtons, { 2, .T., {|o| nOpcao := 2, o:oWnd:End()}} )
AADD(aButtons, { 5, .T., {| | Pergunte(cPerg, .T.)     }} )

FormBatch(cTitulo, aSays, aButtons,, 200, 530)

If nOpcao = 1
	oProcess := MsNewProcess():New( { || AMS00015A(MV_PAR01,MV_PAR02) }, cTitulo, "Aguarde...", .F. )
	oProcess:Activate()
EndIf

RestArea(aArea)

Return

//////////////////////////////////////////////////////////////////////////////////////
//+--------------------------------------------------------------------------------+//
//| PROGRAMA  | AMS00015A| AUTORA| Thais Paiva              | DATA | 09/12/2020    |//
//+--------------------------------------------------------------------------------+//
//| DESCRICAO  | Função: Importação de arquivo CSV para inclusão de solicitação de |//
//|            | compras                                                           |//
//+--------------------------------------------------------------------------------+//
//////////////////////////////////////////////////////////////////////////////////////

Static Function AMS00015A(cArquivo,cLogComp)
Local cFilAux	:= cFilAnt
Local cFil      := Substr(cNumEmp,3)
Local cLinha    := ""
Local nI        := 0
Local nA        := 0
Local nHdl      := 0
Local nTamArq   := 0
Local nTamLinha := 0
Local nLinhas   := 0
Local nCont     := 1
Local aSepara   := {}
Local aCabec    := {}
Local aItens    := {}
Local aLinha	:= {}
Local aLogsImp  := {}
Local _cNumSol	:= ""
Local nVunit	:= 0
Local _aMsgLog	:= {}
Local cMsgLog	:= ""
Local aLogAuto := {}
Local cErroAuto := ""
Local _nPos := 0
Local _aAux := {}
Local nTotal      := 0
Local nAtual      := 0
Local cSetor := ""
Local cCCusto := ""
Local nCabec := 0
Local _cUsuDt := DTOS(dDataBase)+__cUserId
Local lLocal := .F.
Local _cMsgLog := ""
Private cConta := ""
Private lMsErroAuto := .F.
Private lMsHelpAuto := .F.
Private INCLUI := .T.
Private ALTERA := .F.
Private lAutoErrNoFile:= .T.
Private lLogComp := .F.


Default cArquivo := ""
Default cLogComp := 1

If cLogComp == 2
	lLogComp := .T.
EndIf

cFilAnt := cFil

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
nLinhas := FT_FLastRec()

oProcess:SetRegua1(nLinhas) 

While !FT_FEOF()

	oProcess:IncRegua1("Validando Linha: " + Alltrim(Str(nCont)))
	cLinha := FT_FREADLN()
	
	If !("FIM DO UPLOAD"$ UPPER(ALLTRIM(cLinha)) )
	
		If cLinha $ ("C1_PRODUTO;C1_OBS;C1_QUANT;C1_XTPSC;C1_XMOTIVO;C1_LOCAL;C1_XCODSET;")
			_nPos := Len(cLinha)
			If Substr(cLinha,_nPos) == ";"
				cLinha := Substr(cLinha,1,_nPos-1)
			EndIf
		EndIf
		
		nTotal := 0

		_nPos := 0
		
		For nAtual := 1 To Len(cLinha)
			//Se a posição atual for igual ao caracter procurado, incrementa o valor
			If SubStr(cLinha, nAtual, 1) == ";" .AND. nTotal <= 6
				nTotal++
			ElseIf SubStr(cLinha, nAtual-1, 1) == ";" .AND. nTotal > 6
				nTotal++
				_nPos := nAtual-1
				Exit
			EndIf
			
		Next nAtual
		
		nAtual := 0

		If nTotal > 6 .AND. SubStr(cLinha, _nPos, 1) == ";"
			cLinha := Substr(cLinha,1,_nPos-1)
		EndIf
		
		_nPos := 0

		If !Empty(cLinha)
			aSepara := Separa(cLinha, ";", .T.)
				
			If Len(aSepara) > 7 .AND. nCont == 1
					
				MsgAlert("O arquivo de nome " + AllTrim(cArquivo) + " excedeu o número de colunas. Total de colunas do arquivo na linha: "+Str(nCont), "Atencao!")
				Return
					
			EndIf

			If Empty(Alltrim(aSepara[1]))
				FT_FSKIP()
				nCont++
				LOOP	
			EndIf
		Else
			FT_FSKIP()
			nCont++
			LOOP
		EndIf

		_nPos := 0
					
		If nCont > 1 .and. Alltrim(aSepara[1]) == "C1_PRODUTO" 
			Begin Transaction
			cA110Num := ""
			_cNumSol := GetSX8Num("SC1","C1_NUM")	
			aAdd(aCabec,{"C1_FILIAL", cFil})	
			aAdd(aCabec,{"C1_NUM"    , _cNumSol})		
			aAdd(aCabec,{"C1_EMISSAO", dDataBase})	
			aAdd(aCabec,{"C1_SOLICIT", __cUserId })
			aAdd(aCabec,{"C1_FILENT", cFil})	
			MSExecAuto({|x,y,z| mata110(x,y,z)},aCabec, aItens,3)
			nCabec++
			If nCabec > 1
				aadd(aAdd(aLogsImp,{"FILIAL","NÚMERO SC","ITEM","PRODUTO","MSG ITEM","MSG INCLUSÃO SC"}))
			EndIf
			If !lMsErroAuto
				for _nIt := 1 to Len(aItens)
					If len(_aMsgLog) >= _nIt
						cMsgLog := _aMsgLog[_nIt][2]
					EndIf
					If Empty(Alltrim(cMsgLog)) .AND. _nIt == 1 .AND. !lLogComp
						aadd(aAdd(aLogsImp,{cFil,_cNumSol,aItens[_nIt][1][2],aItens[_nIt][2][2],"SC Incluída com Sucesso",""}))
					ElseIf _nIt == 1 .AND. lLogComp
						aadd(aAdd(aLogsImp,{cFil,_cNumSol,aItens[_nIt][1][2],aItens[_nIt][2][2],"","SC Incluída com Sucesso"}))
					Else
						aadd(aAdd(aLogsImp,{cFil,_cNumSol,aItens[_nIt][1][2],aItens[_nIt][2][2],cMsgLog,""}))
					EndIf
					cMsgLog := "" 
				Next _nIt
				ConfirmSX8()
			Else
				for _nIt := 1 to Len(aItens)
					If len(_aMsgLog) >= _nIt
						cMsgLog := _aMsgLog[_nIt][2]
					EndIf
					aLogAuto := GetAutoGRLog()
					For nAux := 1 To Len(aLogAuto)
						//Início - Chamado: 11455012
						If "INVALIDO" $ UPPER(aLogAuto[nAux]) .OR. "ERRO" $ UPPER(aLogAuto[nAux]) .OR. "INCONSISTENCIA" $ UPPER(aLogAuto[nAux])
							If !Empty(cErroAuto)
								cErroAuto += " - "
							EndIf
							cErroAuto += Alltrim(aLogAuto[nAux])
						EndIf
						//Fim - Chamado: 11455012
					Next nAux
					If _nIt == 1 .AND. !lLogComp
						aadd(aAdd(aLogsImp,{cFil,_cNumSol,aItens[_nIt][1][2],aItens[_nIt][2][2],"SC não incluída. "+cMsgLog,""}))
					ElseIf Empty(Alltrim(cErroAuto))
						aadd(aAdd(aLogsImp,{cFil,_cNumSol,aItens[_nIt][1][2],aItens[_nIt][2][2],cMsgLog,""}))
					Else
						aadd(aAdd(aLogsImp,{cFil,_cNumSol,aItens[_nIt][1][2],aItens[_nIt][2][2],cMsgLog,"SC não incluída: "+cErroAuto}))
					EndIf
					cMsgLog := ""
					cErroAuto := ""
				Next _nIt		
				ROLLBACKSX8()
				DisarmTransaction()
			EndIf
			nI := 0
			aItens := {}
			_aMsgLog := {}
			aLogAuto := {}
			lMsErroAuto := .F.
			cA110Num := ""
			aCabec := {}
			End Transaction
		ElseIf !(Alltrim(aSepara[1]) == "C1_PRODUTO")
			nI++
			nVunit := Posicione("SBZ",1,xFilial("SBZ")+aSepara[1],"BZ_UPRC")
			
			If !Empty(Alltrim(aSepara[7]))
				cCodSet := aSepara[7]
				cSetor := Alltrim(Posicione("P11",1,xFilial("P11")+cCodSet,"P11_DESC"))
				cCCusto := Alltrim(Posicione("P11",1,xFilial("P11")+cCodSet,"P11_CCUSTO"))
			Else
				cCodSet := ""
			EndIf
			
			_cMsgLog := AMS00015V(aSepara[4],aSepara[5],aSepara[1],val(aSepara[3]))
			
			_aAreaNR := GetArea()
			DbSelectArea("NNR")
			If DbSeek(xFilial("NNR")+aSepara[6])
				lLocal := .T.
				If Empty(cCCusto)
					cCCusto := Alltrim(NNR->NNR_XCUSTO)
				EndIf		
			Else
				lLocal := .F.
				If !Empty(Alltrim(_cMsgLog))
					_cMsgLog += CRLF
				EndIf
				_cMsgLog += "Local não encontrado!"	
			EndIf
			RestArea(_aAreaNR)
			
			If Empty(cCCusto) .AND. lLocal
				If !Empty(Alltrim(_cMsgLog))
					_cMsgLog += CRLF
				EndIf
				_cMsgLog += "Centro de custo não encontrado, favor verificar o cadastro do Centro de Custo!"	
			EndIf
			
			aAdd(_aMsgLog,{StrZero(nI, 4),_cMsgLog})
			
			aAdd(aLinha,{"C1_ITEM", StrZero(nI, 4), Nil})			
			aAdd(aLinha,{"C1_PRODUTO", aSepara[1], Nil})
			aAdd(aLinha,{"C1_OBS", aSepara[2], Nil})
			aAdd(aLinha,{"C1_QUANT", val(aSepara[3]), Nil})
			aAdd(aLinha,{"C1_VUNIT", Iif(nVunit == 0, 1,nVunit), Nil})
			aAdd(aLinha,{"C1_XTPSC", aSepara[4], Nil})
			aAdd(aLinha,{"C1_XMOTIVO", aSepara[5], Nil})
			aAdd(aLinha,{"C1_LOCAL", aSepara[6], Nil})
			aAdd(aLinha,{"C1_XCODSET", cCodSet, Nil})
			aAdd(aLinha,{"C1_XUSDTUP", _cUsuDt, Nil})
			aAdd(aLinha,{"C1_CC", cCCusto, Nil})
			aAdd(aLinha,{"C1_XSETOR", cSetor, Nil})
			aAdd(aLinha,{"C1_CONTA", cConta, Nil})
			
			aAdd(aItens,aLinha)
			aLinha := {}
			_cMsgLog := ""
		
		EndIf
		aSepara := {}
		FT_FSKIP()
		nCont++
		cConta := ""
		nVunit := 0
		cCCusto := ""
		cSetor := ""
		cCodSet := ""
		aCabec := {}
	Else
		Exit
	EndIf
EndDo

Begin Transaction
cA110Num := ""
_cNumSol := GetSX8Num("SC1","C1_NUM")	
aCabec := {}
aAdd(aCabec,{"C1_FILIAL", cFil})	
aAdd(aCabec,{"C1_NUM"    , _cNumSol})		
aAdd(aCabec,{"C1_EMISSAO", dDataBase})	
aAdd(aCabec,{"C1_SOLICIT", __cUserId })
aAdd(aCabec,{"C1_FILENT", cFil})	
MSExecAuto({|x,y,z| mata110(x,y,z)},aCabec, aItens,3)
nCabec++
If nCabec > 1
	aadd(aAdd(aLogsImp,{"FILIAL","NÚMERO SC","ITEM","PRODUTO","MSG ITEM","MSG INCLUSÃO SC"}))
EndIf
If !lMsErroAuto
	for _nIt := 1 to Len(aItens)
		If len(_aMsgLog) >= _nIt
			cMsgLog := _aMsgLog[_nIt][2]
		EndIf
		If Empty(Alltrim(cMsgLog)) .AND. _nIt == 1  .AND. !lLogComp
			aadd(aAdd(aLogsImp,{cFil,_cNumSol,aItens[_nIt][1][2],aItens[_nIt][2][2],"SC Incluída com Sucesso",""}))
		ElseIf _nIt == 1 .AND. lLogComp
			aadd(aAdd(aLogsImp,{cFil,_cNumSol,aItens[_nIt][1][2],aItens[_nIt][2][2],"","SC Incluída com Sucesso"}))
		Else
			aadd(aAdd(aLogsImp,{cFil,_cNumSol,aItens[_nIt][1][2],aItens[_nIt][2][2],cMsgLog,""}))
		EndIf
		cMsgLog := "" 
	Next _nIt
	ConfirmSX8()
Else
	for _nIt := 1 to Len(aItens)
		If len(_aMsgLog) >= _nIt
			cMsgLog := _aMsgLog[_nIt][2]
		EndIf
		aLogAuto := GetAutoGRLog()
		For nAux := 1 To Len(aLogAuto)
			//Início - Chamado: 11455012
			If "INVALIDO" $ UPPER(aLogAuto[nAux]) .OR. "ERRO" $ UPPER(aLogAuto[nAux]) .OR. "INCONSISTENCIA" $ UPPER(aLogAuto[nAux])
				If !Empty(cErroAuto)
					cErroAuto += " - "
				EndIf
				cErroAuto += Alltrim(aLogAuto[nAux])
			EndIf
			//Fim - Chamado: 11455012
		Next nAux
		If _nIt == 1 .AND. !lLogComp
			aadd(aAdd(aLogsImp,{cFil,_cNumSol,aItens[_nIt][1][2],aItens[_nIt][2][2],"SC não incluída. "+cMsgLog,""}))
		ElseIf Empty(Alltrim(cErroAuto))
			aadd(aAdd(aLogsImp,{cFil,_cNumSol,aItens[_nIt][1][2],aItens[_nIt][2][2],cMsgLog,""}))
		Else
			aadd(aAdd(aLogsImp,{cFil,_cNumSol,aItens[_nIt][1][2],aItens[_nIt][2][2],cMsgLog,"SC não incluída: "+cErroAuto}))
		EndIf
		cMsgLog := ""
		cErroAuto := ""
	Next _nIt	
	ROLLBACKSX8()	
	DisarmTransaction()
EndIf
lMsErroAuto := .F.
nI := 0
aItens := {}
_aMsgLog := {}
aLogAuto := {}
aCabec := {}
nCabec := 0
cA110Num := ""
End Transaction

FT_FUse()
fClose(nHdl)

If !Empty(aLogsImp)
	AMS00015B(aLogsImp)
EndIf

oProcess:IncRegua1("Atualização Finalizada...")
cFilAnt := cFilAux

Return

//////////////////////////////////////////////////////////////////////////////////////
//+--------------------------------------------------------------------------------+//
//| PROGRAMA  | AMS00015B| AUTORA| Thais Paiva              | DATA | 09/12/2020    |//
//+--------------------------------------------------------------------------------+//
//| DESCRICAO  | Função: Geração do Log                                            |//
//+--------------------------------------------------------------------------------+//
//////////////////////////////////////////////////////////////////////////////////////
Static Function AMS00015B(aLogsImp)

	Local aArea      := GetArea()

	Local cArquivo   := "AMS00015"+DTOS(ddatabase)+STRTRAN(Time(),":","")+"LOGIMP.xls"	
	Local cPath      := GetTempPath()

	Local oFWExcel := Nil
	Local oExcel     := Nil	

	Local nX         := 0
	Local nLog       := 0
	Local nLogAtu    := 0
	Local nTamLog    := 0
	Local nTamLogAtu := 0
	
	Local aLinhaLog  := {}

	Default aLogsCab := {}
	Default aLogsITE := {}
	Default aLogsMsg := {}

	
//	
//	If !ApOleClient("MSExcel")
//		MsgAlert("Microsoft Excel não instalado!")
//		Return
//	EndIf

	oFWExcel:= FWMsExcelex():New()
	oFWExcel:AddworkSheet("Logs") 	
	oFWExcel:AddTable("Logs", "Logs de Importacao")

	oFWExcel:AddColumn("Logs", "Logs de Importacao", "FILIAL", 1, 1,.F.) 
	oFWExcel:AddColumn("Logs", "Logs de Importacao", "NÚMERO SC", 1, 1,.F.) 
	oFWExcel:AddColumn("Logs", "Logs de Importacao", "ITEM", 1, 1,.F.) 
	oFWExcel:AddColumn("Logs", "Logs de Importacao", "PRODUTO", 1, 1,.F.) 
	oFWExcel:AddColumn("Logs", "Logs de Importacao", "MSG ITEM", 1, 1,.F.) 
    If lLogComp
		oFWExcel:AddColumn("Logs", "Logs de Importacao", "MSG INCLUSÃO SC", 1, 1,.F.) 
	EndIf

	nTamLog := Len(aLogsImp)

	If lLogComp
		For nLog := 1 To nTamLog
			oFWExcel:AddRow("Logs", "Logs de Importacao", {aLogsImp[nLog][1],;
															aLogsImp[nLog][2],;
															aLogsImp[nLog][3],;
															aLogsImp[nLog][4],;
															aLogsImp[nLog][5],;
															aLogsImp[nLog][6]})
															
		Next nLog
	Else
		For nLog := 1 To nTamLog
			oFWExcel:AddRow("Logs", "Logs de Importacao", {aLogsImp[nLog][1],;
															aLogsImp[nLog][2],;
															aLogsImp[nLog][3],;
															aLogsImp[nLog][4],;
															aLogsImp[nLog][5]})
		Next nLog
	EndIf

	oFWExcel:Activate()
	oFWExcel:GetXMLFile(cPath + cArquivo)

//	oExcel := MsExcel():New()            
//	oExcel:WorkBooks:Open(cPath + cArquivo)     
//	oExcel:SetVisible(.T.)                 
//	oExcel:Destroy()         

ShellExecute("Open", cArquivo, "", cPath , 1 )               

	RestArea(aArea)

Return

//////////////////////////////////////////////////////////////////////////////////////
//+--------------------------------------------------------------------------------+//
//| PROGRAMA  | AMS00015V| AUTORA| Thais Paiva              | DATA | 14/12/2020    |//
//+--------------------------------------------------------------------------------+//
//| DESCRICAO  | Função: Validações                                                |//
//+--------------------------------------------------------------------------------+//
//////////////////////////////////////////////////////////////////////////////////////
Static Function AMS00015V(cTipo,cMotivo,cProduto,nQuant)

Local cRet 		:= "|"
Local cRetGrp	:= ""
Local cQuery	:= ""
Local nX		:= 0
Local aRetGrp	:= {}
Local _cMsg := ""
Local aArea 	:= GetArea()

DbSelectArea("PZZ")
DbSetOrder(1)
If !DbSeek(xFilial("PZZ")+cTipo+cMotivo)
	_cMsg := "O Tipo da SC "+Alltrim(cTipo)+" e o Motivo "+Alltrim(cMotivo)+" não possuem amarração na tabela PZZ."
EndIf

cQuery := "SELECT AI_XTPSC, AI_GRUSER FROM " + RetSqlName("SAI")
cQuery += "		WHERE AI_FILIAL = '" + xFilial("SAI") + "' AND AI_USER = '" + __cUserID + "'  AND D_E_L_E_T_= ' '"

TcQuery cQuery New Alias "AITMP"

// Não encontrou o Usuário
If ( AITMP->(Eof()) )
	// Busco pelo Grupo para identificar o Usuário
	aRetGrp := fUserGrp()	 
EndIf 

cQuery := ""

If ( Len( aRetGrp ) > 0 )
	If ( Select("AITMP") > 0 )
		DbCloseArea("AITMP")
	EndIf
	// Monto a string com os Grupos ao qual o Usuário corrente pertence
	For nX := 1 To Len( aRetGrp )
		cRetGrp += aRetGrp[nX] + ","
	Next nX
	// Removo a virgula do final da string
	cRetGrp := SubStr( cRetGrp, 1, Len(cRetGrp)-1 )
	
	cQuery := "SELECT AI_XTPSC, AI_USER, AI_GRUSER FROM "+ RetSqlName("SAI")
	cQuery += "		WHERE AI_FILIAL = '" + xFilial("SAI") + "' AND AI_GRUSER IN " + FormatIn( cRetGrp, "," ) + " AND D_E_L_E_T_= ' '"
	
	TcQuery cQuery New Alias "AITMP"
EndIf

If (!AITMP->(Eof()))
	While (!AITMP->(Eof()))
		cRet += AllTrim( AITMP->AI_XTPSC ) 
		AITMP->( DbSkip() )
	EndDo
EndIf

// Realizo a validação do Tipo da SC
If !(cTipo $ cRet)
	If !Empty(_cMsg)
		_cMsg += CRLF
	EndIf
	_cMsg += "Solicitante não tem permissão para incluir SC do tipo informado!!"
EndIf
	
DbSelectArea("AITMP")
DbCloseArea()

DbSelectArea("SB1")
DbSetOrder(1)
If DbSeek(xFilial("SB1")+cProduto)
	If SB1->B1_XESTOQ == 'S'
		If SB1->B1_GRUPO $ "0027/0029/0033/0077/0055"      
			cConta := Alltrim(POSICIONE("SBM",1,XFILIAL("SBM")+SB1->B1_GRUPO,"BM_XCONTA"))
		Else
			cConta := Alltrim(POSICIONE("SBM",1,XFILIAL("SBM")+SB1->B1_GRUPO,"BM_XCTPAT"))
		EndIf			
	Else
		cConta := Alltrim(POSICIONE("SBM",1,XFILIAL("SBM")+SB1->B1_GRUPO,"BM_XCONTA"))
		If Empty(cConta)
			cConta := Alltrim(POSICIONE("SBM",1,XFILIAL("SBM")+SB1->B1_GRUPO,"BM_XCTPAT"))
		EndIf
	EndIf
Else
	If !Empty(_cMsg)
		_cMsg += CRLF
	EndIf
	_cMsg += "Produto "+Alltrim(cProduto)+" não encontrado, favor verificar o cadastro do PRODUTO."
EndIf

If Empty(cConta)
	If !Empty(_cMsg)
		_cMsg += CRLF
	EndIf
	_cMsg += "Conta não encontrada, favor verificar."
EndIf

DbSelectArea("P17")
DbSetOrder(1)
If DbSeek(xFilial("P17")+PADR(cProduto,15)+cFilAnt)
	If P17->P17_BLOQ == "S"
		If !Empty(_cMsg)
			_cMsg += CRLF
		EndIf
		_cMsg += "Produto "+Alltrim(cProduto)+" bloqueado - P17"
	EndIf
EndIf


DbSelectArea("SBZ")
DbSetOrder(1)
If DbSeek(xFilial("SBZ")+cProduto)
	If SBZ->BZ_QE > 0 .AND. Alltrim(cProduto) == Alltrim(SBZ->BZ_COD)
		nResult := Mod(nQuant,SBZ->BZ_QE)
		If nResult <> 0
			If !Empty(_cMsg)
				_cMsg += CRLF
			EndIf
			_cMsg += "A Quantidade do item deve ser múltiplo de " + cVAltochar(SBZ->BZ_QE) + ", conforme a Quantidade por Embalagem informada no cadastro Indicador de Produtos!"
		Endif
	Endif
Endif

RestArea(aArea)
	
Return( _cMsg )


//////////////////////////////////////////////////////////////////////////////////////
//+--------------------------------------------------------------------------------+//
//| PROGRAMA  | AMS00015G| AUTORA| Thais Paiva              | DATA | 14/12/2020    |//
//+--------------------------------------------------------------------------------+//
//| DESCRICAO  | Função: Retorno o campo AI_GRUSER                                 |//
//+--------------------------------------------------------------------------------+//
//////////////////////////////////////////////////////////////////////////////////////
*/
Static Function fUserGrp()
Local aUserGrp	:= {}
Local aGrupos 	:= {}

PswOrder(1)
If (  PswSeek( __cUserId, .T. ) )
	// Retorna os Grupos
	aGrupos := Pswret(1)
	// O usuario corrente faz parte do grupo
	aUserGrp := aGrupos[1][10]
EndIf
	
Return( aUserGrp )
