#Include 'Protheus.ch'
#Include "report.ch"

/*{Protheus.doc} F0300301
Processamento do Relatorio de Plano de Sucessao
@owner      Ademar Fernandes
@author     Ademar Fernandes
@since      17/11/2016
@param      NIL
@return     NIL
@project    MAN00000463701_EF_003
@version    P 12.1.7
@obs        Observacoes
*/
User Function F0300301()

Local aSays		:= {}
Local aButtons	:= {}
Local nOpca 	:= 0

Private cPerg		:= "FSW0300301"	// Gp. perguntas sobre a importacao
Private cCond		:= "1"			// Variavel utilizada na funcao gpRCHFiltro() Consulta Padrao - 1 = Periodos Abertos
Private cRot		:= ""
Private cProcesso	:= ""

cCadastro := OemToAnsi("Plano de Sucessão")

Pergunte(cPerg,.F.)

AAdd(aSays,OemToAnsi("Esta rotina realiza o processo de Plano de Sucessão.") + CRLF )
AAdd(aSays,OemToAnsi("") + CRLF )
AAdd(aSays,OemToAnsi("") )

AAdd(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.)  } } )
AAdd(aButtons, { 1,.T.,{|o| nOpca := 1,FechaBatch() }} )
AAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )
If nOpca == 1
	Processa( {|lEnd| F0300301a()}, "Processando: " + cCadastro )
EndIf

Return( Nil )

/*{Protheus.doc} F0300301a
Monta a tela inicial mostrando os Eixos (X e Y) e as opçoes de Quadrantes
@author     Ademar Fernandes
@since      17/11/2016
@param      NIL
@return     NIL
@project    MAN00000463701_EF_003
*/
Static Function F0300301a()
Local nX	 := 0
Local cRet	 := ""
Local aSize  := MsAdvSize( .T. )
Local oMark1   
Local oBrowse
Local oBrowse2
   
Private aBrwse := {}
Private aBrwse2  := {}
Private aTab_Fol := {}
Private oOk := LoadBitmap( nil, "LBOK" )
Private oNo := LoadBitmap( nil, "LBNO" )

//-fCarrTab( @aTab_Fol,cCodTab,dDataRef )
fCarrTab( @aTab_Fol,"U003",dDataBase )
//-fTabela( cCodTab,nLinTab,nColTab,dDataRef,cFilTab )
//?cRet := fTabela( "U003",1,5,dDataBase,/*cFilTab*/ )

If Len(aTab_Fol) > 0
	//-Monta os itens da Tela 1
	For nX := 1 to Len(aTab_Fol)
		AAdd(aBrwse, {	.F.,;				//-01
						aTab_Fol[nX,05],;	//-02
						Str(aTab_Fol[nX,06],6,2) + " a " + Str(aTab_Fol[nX,07],6,2),;	//-03
						Str(aTab_Fol[nX,08],6,2) + " a " + Str(aTab_Fol[nX,09],6,2),;	//-04
						Str(aTab_Fol[nX,10],6,2) + " a " + Str(aTab_Fol[nX,11],6,2),;	//-05
						Str(aTab_Fol[nX,12],6,2) + " a " + Str(aTab_Fol[nX,13],6,2),;	//-06
						aTab_Fol[nX,06],;	//-07
						aTab_Fol[nX,07],;	//-08
						aTab_Fol[nX,08],;	//-09
						aTab_Fol[nX,09],;	//-10
						aTab_Fol[nX,10],;	//-11
						aTab_Fol[nX,11],;	//-12
						aTab_Fol[nX,12],;	//-13
						aTab_Fol[nX,13];	//-14
					})
	Next nX
	
	//-Monta os itens da Tela 2
	AAdd(aBrwse2, {.T., "B1 x B2", MV_PAR07 })	//-"A"
	AAdd(aBrwse2, {.T., "B1 x C2", MV_PAR08 })	//-"B"
	AAdd(aBrwse2, {.T., "B1 x D2", MV_PAR09 })	//-"C"
	AAdd(aBrwse2, {.T., "B1 x E2", MV_PAR10 })	//-"D"
	AAdd(aBrwse2, {.T., "C1 x B2", MV_PAR11 })	//-"E"
	AAdd(aBrwse2, {.T., "C1 x C2", MV_PAR12 })	//-"F"
	AAdd(aBrwse2, {.T., "C1 x D2", MV_PAR13 })	//-"G"
	AAdd(aBrwse2, {.T., "C1 x E2", MV_PAR14 })	//-"H"
	AAdd(aBrwse2, {.T., "D1 x B2", MV_PAR15 })	//-"I"
	AAdd(aBrwse2, {.T., "D1 x C2", MV_PAR16 })	//-"J"
	AAdd(aBrwse2, {.T., "D1 x D2", MV_PAR17 })	//-"K"
	AAdd(aBrwse2, {.T., "D1 x E2", MV_PAR18 })	//-"L"
	AAdd(aBrwse2, {.T., "E1 x B2", MV_PAR19 })	//-"M"
	AAdd(aBrwse2, {.T., "E1 x C2", MV_PAR20 })	//-"N"
	AAdd(aBrwse2, {.T., "E1 x D2", MV_PAR21 })	//-"O"
	AAdd(aBrwse2, {.T., "E1 x E2", MV_PAR22 })	//-"P"
	
	DEFINE MSDIALOG oDlg From 50,50 to aSize[6]-100,aSize[5]-500 Title cCadastro Of oMainWnd Pixel
	
	oFWLayer := FWLayer():new()
	oFWLayer :Init(oDlg)
	oFWLayer:addLine('Lin01',30,.T.)	//-25 = Altura da Janela 1
	oFWLayer:addLine('Lin02',60,.T.)	//-65 = Altura da Janela 2

	//-TCBrowse():New(	[nRow],[nCol],[nWidth],[nHeight],[bLine],[aHeaders],[aColSizes],[oWnd],
	//-					[cField],[uValue1],[uValue2],[bChange],[bLDblClick],[bRClick],[oFont],[oCursor],[nClrFore],[nClrBack],
	//-					[cMsg],[uParam20],[cAlias],[lPixel],[bWhen],[uParam24],[bValid],[lHScroll],[lVScroll])
	
	//-Monta o Browse 1
	oFWLayer:addCollumn(cCadastro,100,.T.,'Lin01')
	oFWLayer:addWindow (cCadastro,"Win01","Cadastro de Eixos",100,.F.,.F., ,'Lin01')
	oWin01  := oFWLayer:GetWinPanel(cCadastro,"Win01",'Lin01')
	
	//?oBrowse := TCBrowse():New( 005, 001, 100, 100,,,, oWin01,,,,, {||},,,,,,,.F.,,.T.,,.F.,,,) 
	oBrowse := TCBrowse():New(005,001,(aSize[4]/5),(aSize[4]/5),,,, oWin01,,,,, {||},,,,,,,.F.,,.T.,,.F.,,,) 
	oBrowse:SetArray(aBrwse) 
	oBrowse:AddColumn(TCColumn():New('Eixo'	,{||aBrwse[oBrowse:nAt,02] },,,,'CENTER',,.F.,.F.,,,,.F.,))
	oBrowse:AddColumn(TCColumn():New('B'	,{||aBrwse[oBrowse:nAt,03] },,,,'CENTER',,.F.,.F.,,,,.F.,))
	oBrowse:AddColumn(TCColumn():New('C'	,{||aBrwse[oBrowse:nAt,04] },,,,'CENTER',,.F.,.F.,,,,.F.,))
	oBrowse:AddColumn(TCColumn():New('D'	,{||aBrwse[oBrowse:nAt,05] },,,,'CENTER',,.F.,.F.,,,,.F.,))
	oBrowse:AddColumn(TCColumn():New('E'	,{||aBrwse[oBrowse:nAt,06] },,,,'CENTER',,.F.,.F.,,,,.F.,))
	oBrowse:AddColumn(TCColumn():New(''		,							,,,,'LEFT',,.F.,.F.,,,,.F.,))
	oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	 
	//-Monta o Browse 2
	oFWLayer:addCollumn(cCadastro,100,.T.,'Lin02')
	oFWLayer:addWindow (cCadastro,"Win02","Opções para processamento",100,.F.,.F., ,'Lin02')
	oWin02  := oFWLayer:GetWinPanel(cCadastro,"Win02",'Lin02')
	
	//?oBrowse2 := TCBrowse():New( 020, 001, 100, 100,,,, oWin02,,,,, {||},,,,,,,.F.,,.T.,,.F.,,,) 
	oBrowse2 := TCBrowse():New(aSize[2],001,(aSize[4]/5),(aSize[4]/5),,,, oWin02,,,,, {||},,,,,,,.F.,,.T.,,.F.,,,) 
	oBrowse2:SetArray(aBrwse2) 
	oBrowse2:AddColumn(TCColumn():New(' '		,{|| if(aBrwse2[oBrowse2:nAt,01],oOk,oNo) },,,,'LEFT',10,.T.,.T.,,,,.F.,))
	oBrowse2:AddColumn(TCColumn():New('Quadrantes',{||aBrwse2[oBrowse2:nAt,02] },,,,'CENTER',,.F.,.F.,,,,.F.,))
	oBrowse2:AddColumn(TCColumn():New('Resultados',{||aBrwse2[oBrowse2:nAt,03] },,,,'CENTER',,.F.,.F.,,,,.F.,))
	oBrowse2:AddColumn(TCColumn():New(''		  ,								,,,,'LEFT',,.F.,.F.,,,,.F.,))
	oBrowse2:bHeaderClick := {|o,x| marcaCkb(aBrwse2) , oBrowse2:refresh()}
	oBrowse2:bLDblClick   := {|z,x| aBrwse2[oBrowse2:nAt,01] := !(aBrwse2[oBrowse2:nAt,01] ) }
	oBrowse2:Align := CONTROL_ALIGN_ALLCLIENT
	/* 
	TButton():New( 270, 320, "Confirmar",oDlg,{|| F0300301b(aBrwse,aBrwse2),oDlg:End()},40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 270, 365, "Fechar"	,oDlg,{|| oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	*/
	TButton():New((aSize[4]-100),020, "Confirmar",oDlg,{|| F0300301b(aBrwse,aBrwse2),oDlg:End()},40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New((aSize[4]-100),065, "Fechar"	,oDlg,{|| oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	     
	Activate MsDialog oDlg Centered
EndIf
Return

/*{Protheus.doc} F0300301b
Realiza o pre-processamento do relatorio
@author     Ademar Fernandes
@since      21/11/2016
@param      aEixos:  valores do eixo X e do eixo Y
@param      aOpcoes: quadrantes existentes para processamento
@return     NIL
@project    MAN00000463701_EF_003
*/
Static Function F0300301b(aEixos,aOpcoes)
Local nY := 0
Local nI := 0
Local lCont := .T.
Local cFiltro1 := ""
Local cFiltro2 := ""
Local cFiltro3 := ""
Local aSem2AVA := {}
Local aCom2AVA := {}
Local cADOant
Local cMySql

Default aEixos  := {}
Default aOpcoes := {}

If MV_PAR05 = NIL .Or. Empty(MV_PAR05)
	MV_PAR05 := 2
EndIf

//-Verifica se existem opçoes marcadas
For nY := 1 to Len(aOpcoes) 
	If !aOpcoes[nY,01]
		//?Alert("Item desmarcado: " + Str(nY,5,0))
		lCont := .F.
	Else
		lCont := .T.
		Exit
	EndIf
Next nY

If !lCont
	MsgAlert(OemToAnsi("É necesário deixar alguns Quadrantes marcados para continuar o processamento!"),;
			OemToAnsi("Atenção."))
	Return(.F.)
EndIf

dbSelectArea("RDD")
RDD->(dbSetOrder(2))	//-RDD_FILIAL + RDD_CODADO + RDD_CODAVA + RDD_CODCOM + RDD_ITECOM + RDD_CODNET

MakeSqlExpr("FSW0300301")
cFiltro1 := MV_PAR01	//-Filial
If !Empty(cFiltro1)
	cFiltro1 := Iif(cFiltro1==FWxFilial("RDD"),cFiltro1,FWxFilial("RDD"))
EndIf
cFiltro1 := Iif( Empty(cFiltro1),"%%","% AND RDD_FILIAL ='" + cFiltro1 + "' %")

cFiltro2 := SUBSTRING(mv_par02, 02, LEN(mv_par02) - 02)	//-Matriculas
//cFiltro2 := STRTRAN(cFiltro2, 'BETWEEN', 'RDD_CODADO BETWEEN ')
//cFiltro2 := STRTRAN(cFiltro2, 'IN'     , 'RDD_CODADO IN '     )
cFiltro2 := Iif( Empty(cFiltro2),"%%","% AND " + cFiltro2 + "%")

//-------------------------------------------------------------
//-Verifica se todas as pessoas da query tem as duas Avaliaçoes
//-------------------------------------------------------------
/*
SELECT RDD_FILIAL,RDD_CODADO,RDD_CODAVA,RDD_CODCOM,SUM(RDD_RESOBT) AS PONTOS 
FROM DB2.RDD990 RDD 
WHERE RDD.D_E_L_E_T_= ' ' AND RDD_FILIAL =  '  ' 
AND ( RDD_CODAVA =  '000001' OR RDD_CODAVA =  '000003' )     
AND (RDD_CODADO IN('000169','000181')) AND RDD_CODADO NOT IN ('000181')   
GROUP BY RDD_FILIAL,RDD_CODADO,RDD_CODAVA,RDD_CODCOM 
ORDER BY RDD_FILIAL,RDD_CODADO,RDD_CODAVA,RDD_CODCOM
*/
Iif( Select('CODAVA1') > 0,CODAVA1->(dbCloseArea()),Nil )
BeginSql alias 'CODAVA1'
	SELECT RDD_FILIAL,RDD_CODADO,RDD_CODAVA,RDD_CODCOM,SUM(RDD_RESOBT) AS PONTOS 
	FROM %Table:RDD% RDD
	WHERE RDD.%NotDel% %EXP:cFiltro1% 
	AND ( RDD_CODAVA = %EXP:MV_PAR03% OR RDD_CODAVA = %EXP:MV_PAR04% )
	%EXP:cFiltro2%
	GROUP BY RDD_FILIAL,RDD_CODADO,RDD_CODAVA,RDD_CODCOM
	ORDER BY RDD_FILIAL,RDD_CODADO,RDD_CODAVA,RDD_CODCOM
EndSql

If Eof()
	MsgAlert(OemToAnsi("Não existem Avaliados a serem analisados para os parâmetros informados!"),;
			OemToAnsi("Atenção."))
	Return(.F.)
EndIf

nCont := 1
cADOant := CODAVA1->RDD_CODADO
While !Eof()
	
	CODAVA1->(dbSkip())
	If !Eof()
		nCont += 1
		
		If nCont <> 1 .And. !( CODAVA1->RDD_CODADO == cADOant )
			If nCont <= 2
				AAdd(aSem2AVA, cADOant)
			EndIf
			nCont := 1
			cADOant := CODAVA1->RDD_CODADO
		EndIf
	Else
		If nCont = 1
			AAdd(aSem2AVA, cADOant)
		EndIf
	EndIf
EndDo

//-Converte Array pra SQL - ArrToSql
cMySql := ""
If Len(aSem2AVA) > 0
	For nI := 1 to Len(aSem2AVA)
		cMySql := cMySql + "'" + aSem2AVA[nI] + "',"
	Next
	cMySql := SubStr(cMySql,1,(Len(cMySql)-1))
EndIf
cFiltro3 := Iif( Empty(cMySql),"%%","% AND RDD_CODADO NOT IN (" + cMySql + ") %")

cFiltro3 := StrTran(cFiltro2,"%","") + StrTran(cFiltro3,"%","")
cFiltro3 := Iif( Empty(cFiltro3),"%%","% " + cFiltro3 + " %")

//------------------------------------------------------------------------------------
//-Executa a query novamente excluindo todas as pessoas que NAO tem as duas Avaliaçoes
//------------------------------------------------------------------------------------
dbSelectArea("RDD")
Iif( Select('CODAVA2') > 0,CODAVA2->(dbCloseArea()),Nil )
BeginSql alias 'CODAVA2'
	SELECT RDD_FILIAL,RDD_CODADO,RDD_CODAVA,RDD_CODCOM,SUM(RDD_RESOBT) AS PONTOS 
	FROM %Table:RDD% RDD
	WHERE RDD.%NotDel% %EXP:cFiltro1% 
	AND ( RDD_CODAVA = %EXP:MV_PAR03% OR RDD_CODAVA = %EXP:MV_PAR04% )
	%EXP:cFiltro3%
	GROUP BY RDD_FILIAL,RDD_CODADO,RDD_CODAVA,RDD_CODCOM
	ORDER BY RDD_FILIAL,RDD_CODADO,RDD_CODAVA,RDD_CODCOM
EndSql

If Eof()
	MsgAlert(OemToAnsi("Não existem Avaliados a serem analisados para os parâmetros informados!"),;
			OemToAnsi("Atenção."))
	Return(.F.)
EndIf

While !Eof()
	
	AAdd(aCom2AVA, {RDD_FILIAL,RDD_CODADO,RDD_CODAVA,RDD_CODCOM,PONTOS})
	
	CODAVA2->(dbSkip())
EndDo

//-Chama a funcao pra gerar o Excel ou Relatorio
If Len(aCom2AVA) > 0
	
	aSort(aCom2AVA,,,{|x,y| x[1] + x[2] + x[3] + x[4] < y[1] + y[2] + y[3] + y[4]})
	
	If MV_PAR05 = 1
		Processa({|| F0300301c(aEixos,aOpcoes,cFiltro1,cFiltro3,aCom2AVA)}, OemToAnsi("Aguarde"), OemToAnsi("Processando os dados..."),.F. )
	Else
//?		Processa({|| F0300301d(aEixos,aOpcoes,cFiltro1,cFiltro3,aCom2AVA)}, OemToAnsi("Aguarde"), OemToAnsi("Processando os dados..."),.F. )
		MsgRun( "Processando os dados, Aguarde...","",{|| CursorWait(),F0300301d(aEixos,aOpcoes,cFiltro1,cFiltro3,aCom2AVA),CursorArrow()} )
	EndIf
EndIf
Return

/*{Protheus.doc} F0300301c
Realiza o processamento e gera o relatorio em Excel
@author     Ademar Fernandes
@since      24/11/2016
@param      aEixos:  valores do eixo X e do eixo Y
@param      aOpcoes: quadrantes existentes para processamento
@param      cFiltro1: filtro para usar na query geral
@param      cFiltro3: filtro para usar na query geral
@param      aCom2AVA: array com as pessoas possiveis de impressao
@return     NIL
@project    MAN00000463701_EF_003
*/
Static Function F0300301c(aEixos,aOpcoes,cFiltro1,cFiltro3,aCom2AVA)
Local lRet
Local oExcel := FWMsExcelEx():New()
Local cWorkSheet:= ""
Local cMyTable	:= ""
Local cOpc		:= ""
Local nPosAux	:= 0

Default aEixos  := {}
Default aOpcoes := {}
Default aCom2AVA:= {}

//------------------------------------------------------------------------------------
//-Executa a query novamente excluindo todas as pessoas que NAO tem as duas Avaliaçoes
//------------------------------------------------------------------------------------
/*
SELECT DISTINCT RDD_FILIAL,RDD_CODADO,RDD_CODAVA,RDD_CODCOM,RDD_DTIAVA,RD0_NOME
,RD0_CC,CTT_DESC01 ,RA_CARGO,Q3_DESCSUM ,RA_CODFUNC,RJ_DESC ,RA_DEPTO,QB_DESCRIC
FROM DB2.RDD990 RDD 
INNER JOIN DB2.RD0990 RD0 ON RD0.D_E_L_E_T_= ' ' AND RD0_CODIGO = RDD_CODADO
LEFT  JOIN DB2.CTT990 CTT ON CTT.D_E_L_E_T_= ' ' AND CTT_CUSTO = RD0_CC
LEFT  JOIN DB2.SRA990 SRA ON SRA.D_E_L_E_T_= ' ' AND RA_CIC = RD0_CIC
LEFT  JOIN DB2.SQ3990 SQ3 ON SQ3.D_E_L_E_T_= ' ' AND Q3_CARGO = RA_CARGO
LEFT  JOIN DB2.SRJ990 SRJ ON SRJ.D_E_L_E_T_= ' ' AND RJ_FUNCAO = RA_CODFUNC
LEFT  JOIN DB2.SQB990 SQB ON SQB.D_E_L_E_T_= ' ' AND QB_DEPTO = RA_DEPTO
WHERE RDD.D_E_L_E_T_= ' ' AND RDD_FILIAL =  '  ' 
AND ( RDD_CODAVA =  '000001' OR RDD_CODAVA =  '000003' )
AND (RDD_CODADO IN('000169','000181'))  AND RDD_CODADO NOT IN ('000181')  
ORDER BY RDD_FILIAL,RDD_CODADO,RDD_CODAVA,RDD_CODCOM
*/
dbSelectArea("RDD")
Iif( Select('CODAVA3') > 0,CODAVA3->(dbCloseArea()),Nil )
BeginSql alias 'CODAVA3'
	SELECT DISTINCT RDD_FILIAL,RDD_CODADO,RDD_CODAVA,RDD_CODCOM,RD0_NOME
	,RD0_CC,CTT_DESC01
	,RA_CARGO,Q3_DESCSUM
	,RA_CODFUNC,RJ_DESC
	,RA_DEPTO,QB_DESCRIC
	FROM %Table:RDD% RDD
	INNER JOIN %Table:RD0% RD0 ON RD0.%NotDel% AND RD0_CODIGO = RDD_CODADO
	LEFT  JOIN %Table:CTT% CTT ON CTT.%NotDel% AND CTT_CUSTO = RD0_CC
	LEFT  JOIN %Table:SRA% SRA ON SRA.%NotDel% AND RA_CIC = RD0_CIC
	LEFT  JOIN %Table:SQ3% SQ3 ON SQ3.%NotDel% AND Q3_CARGO = RA_CARGO
	LEFT  JOIN %Table:SRJ% SRJ ON SRJ.%NotDel% AND RJ_FUNCAO = RA_CODFUNC
	LEFT  JOIN %Table:SQB% SQB ON SQB.%NotDel% AND QB_DEPTO = RA_DEPTO
	WHERE RDD.%NotDel% %EXP:cFiltro1% 
	AND ( RDD_CODAVA = %EXP:MV_PAR03% OR RDD_CODAVA = %EXP:MV_PAR04% )
	%EXP:cFiltro3%
	ORDER BY RDD_FILIAL,RDD_CODADO,RDD_CODAVA,RDD_CODCOM
EndSql

While !Eof()
	
	//-Posiciona no array pra pegar os valores das avaliaçoes
	//-AAdd(aCom2AVA, {RDD_FILIAL,RDD_CODADO,RDD_CODAVA,RDD_CODCOM,PONTOS})
	nPosAux := AScan(aCom2AVA,{|x| x[1] + x[2] == CODAVA3->(RDD_FILIAL + RDD_CODADO) })
	
	If aTab_Fol[1,5] == "X"
		If aCom2AVA[nPosAux + 1,5] >= aTab_Fol[1,6] .And. aCom2AVA[nPosAux + 1,5] <= aTab_Fol[1,7]
			cOpc := "B"  
		ElseIf aCom2AVA[nPosAux + 1,5] >= aTab_Fol[1,8] .And. aCom2AVA[nPosAux + 1,5] <= aTab_Fol[1,9]
			cOpc := "C"  
		ElseIf aCom2AVA[nPosAux + 1,5] >= aTab_Fol[1,10] .And. aCom2AVA[nPosAux + 1,5] <= aTab_Fol[1,11]
			cOpc := "D"  
		ElseIf aCom2AVA[nPosAux + 1,5] >= aTab_Fol[1,12] .And. aCom2AVA[nPosAux + 1,5] <= aTab_Fol[1,13]
			cOpc := "E"  
		EndIf
	EndIf
	If aTab_Fol[2,5] == "Y"
		If aCom2AVA[nPosAux,5] >= aTab_Fol[2,6] .And. aCom2AVA[nPosAux,5] <= aTab_Fol[2,7]
			cOpc += "1"  
		ElseIf aCom2AVA[nPosAux,5] >= aTab_Fol[2,8] .And. aCom2AVA[nPosAux,5] <= aTab_Fol[2,9]
			cOpc += "2"  
		ElseIf aCom2AVA[nPosAux,5] >= aTab_Fol[2,10] .And. aCom2AVA[nPosAux,5] <= aTab_Fol[2,11]
			cOpc += "3"  
		ElseIf aCom2AVA[nPosAux,5] >= aTab_Fol[2,12] .And. aCom2AVA[nPosAux,5] <= aTab_Fol[2,13]
			cOpc += "4"  
		EndIf
	EndIf
	
	//-Monta a plainha pro Excel
	cWorkSheet	:= ("" + RDD_CODADO)
	cMyTable	:= ("Plano de Sucessao-" + RDD_CODADO)
	oExcel:AddworkSheet(cWorkSheet)
	oExcel:AddTable(cWorkSheet,cMyTable)
	//-AddColumn(< cWorkSheet >, < cTable >, < cColumn >, < nAlign >, < nFormat >, < lTotal >)-> NIL
	oExcel:AddColumn(cWorkSheet,cMyTable,"Score Executivo (eixo Y)",1,1)	//-Col01
	oExcel:AddColumn(cWorkSheet,cMyTable,"",2,1)							//-Col02
	oExcel:AddColumn(cWorkSheet,cMyTable,"",2,1)							//-Col03
	oExcel:AddColumn(cWorkSheet,cMyTable,"",2,1)							//-Col04
	oExcel:AddColumn(cWorkSheet,cMyTable,"",2,1)							//-Col05
	//-AddRow(< cWorkSheet >, < cTable >, < aRow >)-> NIL
	oExcel:AddRow(cWorkSheet,cMyTable,{aEixos[2,6], Iif(cOpc=="B4" .And. aOpcoes[04,1],"X",""),;
													Iif(cOpc=="C4" .And. aOpcoes[08,1],"X",""),;
													Iif(cOpc=="D4" .And. aOpcoes[12,1],"X",""),;
													Iif(cOpc=="E4" .And. aOpcoes[16,1],"X","")})
	oExcel:AddRow(cWorkSheet,cMyTable,{aEixos[2,5], Iif(cOpc=="B3" .And. aOpcoes[03,1],"X",""),;
													Iif(cOpc=="C3" .And. aOpcoes[07,1],"X",""),;
													Iif(cOpc=="D3" .And. aOpcoes[11,1],"X",""),;
													Iif(cOpc=="E3" .And. aOpcoes[15,1],"X","")})
	oExcel:AddRow(cWorkSheet,cMyTable,{aEixos[2,4], Iif(cOpc=="B2" .And. aOpcoes[02,1],"X",""),;
													Iif(cOpc=="C2" .And. aOpcoes[06,1],"X",""),;
													Iif(cOpc=="D2" .And. aOpcoes[10,1],"X",""),;
													Iif(cOpc=="E2" .And. aOpcoes[14,1],"X","")})
	oExcel:AddRow(cWorkSheet,cMyTable,{aEixos[2,3], Iif(cOpc=="B1" .And. aOpcoes[01,1],"X",""),;
													Iif(cOpc=="C1" .And. aOpcoes[05,1],"X",""),;
													Iif(cOpc=="D1" .And. aOpcoes[09,1],"X",""),;
													Iif(cOpc=="E1" .And. aOpcoes[13,1],"X","")})
	oExcel:AddRow(cWorkSheet,cMyTable,{"",aEixos[1,3],aEixos[1,4],aEixos[1,5],aEixos[1,6]})
	oExcel:AddRow(cWorkSheet,cMyTable,{"","Avaliação por Competência (eixo X)","","",""})
	oExcel:AddRow(cWorkSheet,cMyTable,{"","","","",""})	//-PULA LINHA
	oExcel:AddRow(cWorkSheet,cMyTable,{"","","","",""})	//-PULA LINHA
	oExcel:AddRow(cWorkSheet,cMyTable,{"Matrícula"	,RDD_CODADO				,"","",""})
	oExcel:AddRow(cWorkSheet,cMyTable,{"Funcionário",RD0_NOME				,"","",""})
	oExcel:AddRow(cWorkSheet,cMyTable,{"Cargo"		,RA_CARGO + "-" + Q3_DESCSUM,"","",""})
	oExcel:AddRow(cWorkSheet,cMyTable,{"Função"		,RA_CODFUNC + "-" + RJ_DESC	,"","",""})
	oExcel:AddRow(cWorkSheet,cMyTable,{"Setor"		,RA_DEPTO + "-" + QB_DESCRIC,"","",""})
	oExcel:AddRow(cWorkSheet,cMyTable,{"C.Custo"	,RD0_CC + "-" + CTT_DESC01	,"","",""})

	CODAVA3->(dbSkip())
	If !Eof()
		CODAVA3->(dbSkip())	//-Pula novamente pois tem 2x a mesma pessoa (2 avaliaçoes)
	EndIf
EndDo
If !(EMPTY(MV_PAR06))
	cCaminho := MV_PAR06
EndIf
cNomeArq := "PS" + StrTran(DTOS(date()),"/","") + StrTran(time(),":","") + ".xml"
oExcel:Activate()
oExcel:GetXMLFile(cCaminho + cNomeArq)

MsgAlert(OemToAnsi("Foi gerado no subdiretório " + cCaminho + cNomeArq + " do Protheus o arquivo: " + cNomeArq),;
		OemToAnsi("Atenção."))

Return

/*{Protheus.doc} F0300301d
Realiza o processamento e gera o relatorio
@author     Ademar Fernandes
@since      25/11/2016
@param      aEixos:  valores do eixo X e do eixo Y
@param      aOpcoes: quadrantes existentes para processamento
@param      cFiltro1: filtro para usar na query geral
@param      cFiltro3: filtro para usar na query geral
@param      aCom2AVA: array com as pessoas possiveis de impressao
@return     NIL
@project    MAN00000463701_EF_003
*/
Static Function F0300301d(aEixos,aOpcoes,cFiltro1,cFiltro3,aCom2AVA)
Local lRet

Default aEixos  := {}
Default aOpcoes := {}
Default aCom2AVA:= {}

// Interface de impressao
oReport1 := ReportDef(aEixos,aOpcoes,cFiltro1,cFiltro3,aCom2AVA)
oReport1:PrintDialog()
Return

/*{Protheus.doc} ReportDef
Processamento do relatorio
@author     Ademar Fernandes
@since      25/11/2016
@param      aEixos:  valores do eixo X e do eixo Y
@param      aOpcoes: quadrantes existentes para processamento
@param      cFiltro1: filtro para usar na query geral
@param      cFiltro3: filtro para usar na query geral
@param      aCom2AVA: array com as pessoas possiveis de impressao
@return     NIL
@project    MAN00000463701_EF_003
*/
Static Function ReportDef(aEixos,aOpcoes,cFiltro1,cFiltro3,aCom2AVA)
Local oReport
Local oSection1
Local oSection2

oReport := TReport():New("F0300301",("Relatório de Plano de Sucessão"),"FSW0300301",{|oReport| PrintRep(oReport,aEixos,aOpcoes,cFiltro1,cFiltro3,aCom2AVA)},"FSW0300301")
oReport:SetTotalInLine(.T.)

DEFINE SECTION oSection1 OF oReport TITLE "Secao1" TABLES "RDD","RD0","SRA","SQ3","SQB","SRJ"
oSection1:SetLineStyle()
oSection1:SetCharSeparator(" ")

DEFINE SECTION oSection2 OF oSection1 TITLE "Secao2" TABLES "RDD","RD0","SRA","SQ3","SQB","SRJ"

DEFINE CELL NAME "RDD_CODADO"	OF oSection2 TITLE "Matrícula"			SIZE 20 BLOCK {|| RDD_CODADO}
DEFINE CELL NAME "RD0_NOME"		OF oSection2 TITLE "Nome Funcionário"	SIZE 70 BLOCK {|| RD0_NOME}
DEFINE CELL NAME "RA_CARGO"		OF oSection2 TITLE "Cargo"				SIZE 70 BLOCK {|| RA_CARGO + "-" + Q3_DESCSUM}
DEFINE CELL NAME "RA_CODFUNC"	OF oSection2 TITLE "Função"				SIZE 70 BLOCK {|| RA_CODFUNC + "-" + RJ_DESC}
DEFINE CELL NAME "RA_DEPTO"		OF oSection2 TITLE "Setor"				SIZE 70 BLOCK {|| RA_DEPTO + "-" + QB_DESCRIC}
DEFINE CELL NAME "RD0_CC"		OF oSection2 TITLE "C.Custo"			SIZE 70 BLOCK {|| RD0_CC + "-" + CTT_DESC01}
DEFINE CELL NAME "SCORE"		OF oSection2 TITLE "Score Executivo"	SIZE 15 BLOCK {|| QTD_SCORE} PICTURE "@E 999.99"
DEFINE CELL NAME "AVALCOMP"		OF oSection2 TITLE "Aval.p/Competência"	SIZE 15 BLOCK {|| QTD_COMPET} PICTURE "@E 999.99"
DEFINE CELL NAME "QUADRANTE"	OF oSection2 TITLE "Quadrante"			SIZE 70 BLOCK {|| QUADRANTE}
DEFINE CELL NAME "RDD_DTIAVA"	OF oSection2 TITLE "Dt.Avaliação"		SIZE 30 BLOCK {|| RDD_DTIAVA}

Return oReport

/*{Protheus.doc} PrintRep
Processamento do relatorio
@author     Ademar Fernandes
@since      25/11/2016
@param      aEixos:  valores do eixo X e do eixo Y
@param      aOpcoes: quadrantes existentes para processamento
@param      cFiltro1: filtro para usar na query geral
@param      cFiltro3: filtro para usar na query geral
@param      aCom2AVA: array com as pessoas possiveis de impressao
@return     NIL
@project    MAN00000463701_EF_003
*/
Static Function PrintRep(oReport,aEixos,aOpcoes,cFiltro1,cFiltro3,aCom2AVA)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local cFiltro 	:= ""
Local cSituacao	:= ""
Local cSitQuery	:= ""
Local nReg		:= 0
Local nOrdem	:= 0
Local nPosAux	:= 0
Local aFields := {}
Local oTempTable
Local cQuery
Local cArqSql
Local cMyAlias := GetNextAlias()
Local cAliasQry:= GetNextAlias()
Local cQuadrant:= ""

nOrdem := oReport:GetOrder()

//-------------------
//Criação do objeto
//-------------------
oTempTable := FWTemporaryTable():New( cMyAlias )

//--------------------------
//Monta os campos da tabela
//--------------------------
AAdd(aFields,{"RDD_FILIAL"	,"C",TamSX3("RDD_FILIAL")[1],0})
AAdd(aFields,{"RDD_CODADO"	,"C",TamSX3("RDD_CODADO")[1],0})
AAdd(aFields,{"RDD_CODAVA"	,"C",TamSX3("RDD_CODAVA")[1],0})
AAdd(aFields,{"RDD_CODCOM"	,"C",TamSX3("RDD_CODCOM")[1],0})
AAdd(aFields,{"RDD_DTIAVA"	,"C",TamSX3("RDD_DTIAVA")[1],0})
AAdd(aFields,{"RD0_NOME"	,"C",TamSX3("RD0_NOME")[1],0})
AAdd(aFields,{"RD0_CC"		,"C",TamSX3("RD0_CC")[1],0})
AAdd(aFields,{"CTT_DESC01"	,"C",TamSX3("CTT_DESC01")[1],0})
AAdd(aFields,{"RA_CARGO"	,"C",TamSX3("RA_CARGO")[1],0})
AAdd(aFields,{"Q3_DESCSUM"	,"C",TamSX3("Q3_DESCSUM")[1],0})
AAdd(aFields,{"RA_CODFUNC"	,"C",TamSX3("RA_CODFUNC")[1],0})
AAdd(aFields,{"RJ_DESC"		,"C",TamSX3("RJ_DESC")[1],0})
AAdd(aFields,{"RA_DEPTO"	,"C",TamSX3("RA_DEPTO")[1],0})
AAdd(aFields,{"QB_DESCRIC"	,"C",TamSX3("QB_DESCRIC")[1],0})
AAdd(aFields,{"QTD_SCORE"	,"N",06,2})
AAdd(aFields,{"QTD_COMPET"	,"N",06,2})
AAdd(aFields,{"QUADRANTE"	,"C",15,0})

oTemptable:SetFields( aFields )
oTempTable:AddIndex("indice1", {"RDD_FILIAL","RDD_CODADO"} )
oTempTable:AddIndex("indice2", {"RDD_FILIAL","RD0_NOME"} )

//------------------
//Criação da tabela
//------------------
oTempTable:Create()

//------------------------------------------------------------------------------------
//-Executa a query novamente excluindo todas as pessoas que NAO tem as duas Avaliaçoes
//------------------------------------------------------------------------------------
dbSelectArea("RDD")
Iif( Select('CODAVA4') > 0,CODAVA4->(dbCloseArea()),Nil )
BeginSql alias 'CODAVA4'
	SELECT DISTINCT RDD_FILIAL,RDD_CODADO,RDD_CODAVA,RDD_CODCOM,RDD_DTIAVA,RD0_NOME
	,RD0_CC,CTT_DESC01
	,RA_CARGO,Q3_DESCSUM
	,RA_CODFUNC,RJ_DESC
	,RA_DEPTO,QB_DESCRIC
	FROM %Table:RDD% RDD
	INNER JOIN %Table:RD0% RD0 ON RD0.%NotDel% AND RD0_CODIGO = RDD_CODADO
	LEFT  JOIN %Table:CTT% CTT ON CTT.%NotDel% AND CTT_CUSTO = RD0_CC
	LEFT  JOIN %Table:SRA% SRA ON SRA.%NotDel% AND RA_CIC = RD0_CIC
	LEFT  JOIN %Table:SQ3% SQ3 ON SQ3.%NotDel% AND Q3_CARGO = RA_CARGO
	LEFT  JOIN %Table:SRJ% SRJ ON SRJ.%NotDel% AND RJ_FUNCAO = RA_CODFUNC
	LEFT  JOIN %Table:SQB% SQB ON SQB.%NotDel% AND QB_DEPTO = RA_DEPTO
	WHERE RDD.%NotDel% %EXP:cFiltro1% 
	AND ( RDD_CODAVA = %EXP:MV_PAR03% OR RDD_CODAVA = %EXP:MV_PAR04% )
	%EXP:cFiltro3%
	ORDER BY RDD_FILIAL,RDD_CODADO,RDD_CODAVA,RDD_CODCOM
EndSql

While !Eof()
	
	cQuadrant := ""
	
	//-Posiciona no array pra pegar os valores das avaliaçoes
	//-AAdd(aCom2AVA, {RDD_FILIAL,RDD_CODADO,RDD_CODAVA,RDD_CODCOM,PONTOS})
	nPosAux := AScan(aCom2AVA,{|x| x[1] + x[2] == CODAVA4->(RDD_FILIAL + RDD_CODADO) })
	
	//-Grava o arquivo temporario
	dbSelectArea(cMyAlias)
	RecLock(cMyAlias,.T.)
	(cMyAlias)->RDD_FILIAL	:= CODAVA4->RDD_FILIAL
	(cMyAlias)->RDD_CODADO	:= CODAVA4->RDD_CODADO
	(cMyAlias)->RDD_CODAVA	:= CODAVA4->RDD_CODAVA
	(cMyAlias)->RDD_CODCOM	:= CODAVA4->RDD_CODCOM
	(cMyAlias)->RDD_DTIAVA	:= CODAVA4->RDD_DTIAVA
	(cMyAlias)->RD0_NOME	:= CODAVA4->RD0_NOME
	(cMyAlias)->RD0_CC		:= CODAVA4->RD0_CC
	(cMyAlias)->CTT_DESC01	:= CODAVA4->CTT_DESC01
	(cMyAlias)->RA_CARGO	:= CODAVA4->RA_CARGO
	(cMyAlias)->Q3_DESCSUM	:= CODAVA4->Q3_DESCSUM
	(cMyAlias)->RA_CODFUNC	:= CODAVA4->RA_CODFUNC
	(cMyAlias)->RJ_DESC		:= CODAVA4->RJ_DESC
	(cMyAlias)->RA_DEPTO	:= CODAVA4->RA_DEPTO
	(cMyAlias)->QB_DESCRIC	:= CODAVA4->QB_DESCRIC
	(cMyAlias)->QTD_SCORE	:= Iif(nPosAux>0, aCom2AVA[nPosAux,5],0)
	(cMyAlias)->QTD_COMPET	:= Iif(nPosAux>0, aCom2AVA[nPosAux + 1,5],0)
	//-Enquadra o Score x Compet e acha o Quadrante
	/* ### aBrwse[] - de 7 a 14 ###
	AAdd(aBrwse2, {.T., "B1 x B2", MV_PAR07 })	//-"A"
	AAdd(aBrwse2, {.T., "B1 x C2", MV_PAR08 })	//-"B"
	AAdd(aBrwse2, {.T., "B1 x D2", MV_PAR09 })	//-"C"
	AAdd(aBrwse2, {.T., "B1 x E2", MV_PAR10 })	//-"D"
	AAdd(aBrwse2, {.T., "C1 x B2", MV_PAR11 })	//-"E"
	AAdd(aBrwse2, {.T., "C1 x C2", MV_PAR12 })	//-"F"
	AAdd(aBrwse2, {.T., "C1 x D2", MV_PAR13 })	//-"G"
	AAdd(aBrwse2, {.T., "C1 x E2", MV_PAR14 })	//-"H"
	AAdd(aBrwse2, {.T., "D1 x B2", MV_PAR15 })	//-"I"
	AAdd(aBrwse2, {.T., "D1 x C2", MV_PAR16 })	//-"J"
	AAdd(aBrwse2, {.T., "D1 x D2", MV_PAR17 })	//-"K"
	AAdd(aBrwse2, {.T., "D1 x E2", MV_PAR18 })	//-"L"
	AAdd(aBrwse2, {.T., "E1 x B2", MV_PAR19 })	//-"M"
	AAdd(aBrwse2, {.T., "E1 x C2", MV_PAR20 })	//-"N"
	AAdd(aBrwse2, {.T., "E1 x D2", MV_PAR21 })	//-"O"
	AAdd(aBrwse2, {.T., "E1 x E2", MV_PAR22 })	//-"P"
	*/
	If ( aCom2AVA[nPosAux + 1,5] >= aBrwse[01,07] .And. aCom2AVA[nPosAux + 1,5] <= aBrwse[01,08] ) .And.;
		( aCom2AVA[nPosAux,5] >= aBrwse[02,07] .And. aCom2AVA[nPosAux,5] <= aBrwse[02,08] )
		cQuadrant := MV_PAR07
	
	ElseIf ( aCom2AVA[nPosAux + 1,5] >= aBrwse[01,07] .And. aCom2AVA[nPosAux + 1,5] <= aBrwse[01,08] ) .And.;
		( aCom2AVA[nPosAux,5] >= aBrwse[02,09] .And. aCom2AVA[nPosAux,5] <= aBrwse[02,10] )
		cQuadrant := MV_PAR08
	
	ElseIf ( aCom2AVA[nPosAux + 1,5] >= aBrwse[01,07] .And. aCom2AVA[nPosAux + 1,5] <= aBrwse[01,08] ) .And.;
		( aCom2AVA[nPosAux,5] >= aBrwse[02,11] .And. aCom2AVA[nPosAux,5] <= aBrwse[02,12] )
		cQuadrant := MV_PAR09
	
	ElseIf ( aCom2AVA[nPosAux + 1,5] >= aBrwse[01,07] .And. aCom2AVA[nPosAux + 1,5] <= aBrwse[01,08] ) .And.;
		( aCom2AVA[nPosAux,5] >= aBrwse[02,13] .And. aCom2AVA[nPosAux,5] <= aBrwse[02,14] )
		cQuadrant := MV_PAR10
	//-
	ElseIf ( aCom2AVA[nPosAux + 1,5] >= aBrwse[01,09] .And. aCom2AVA[nPosAux + 1,5] <= aBrwse[01,10] ) .And.;
		( aCom2AVA[nPosAux,5] >= aBrwse[02,07] .And. aCom2AVA[nPosAux,5] <= aBrwse[02,08] )
		cQuadrant := MV_PAR11
	
	ElseIf ( aCom2AVA[nPosAux + 1,5] >= aBrwse[01,09] .And. aCom2AVA[nPosAux + 1,5] <= aBrwse[01,10] ) .And.;
		( aCom2AVA[nPosAux,5] >= aBrwse[02,09] .And. aCom2AVA[nPosAux,5] <= aBrwse[02,10] )
		cQuadrant := MV_PAR12
	
	ElseIf ( aCom2AVA[nPosAux + 1,5] >= aBrwse[01,09] .And. aCom2AVA[nPosAux + 1,5] <= aBrwse[01,10] ) .And.;
		( aCom2AVA[nPosAux,5] >= aBrwse[02,11] .And. aCom2AVA[nPosAux,5] <= aBrwse[02,12] )
		cQuadrant := MV_PAR13
	
	ElseIf ( aCom2AVA[nPosAux + 1,5] >= aBrwse[01,09] .And. aCom2AVA[nPosAux + 1,5] <= aBrwse[01,10] ) .And.;
		( aCom2AVA[nPosAux,5] >= aBrwse[02,13] .And. aCom2AVA[nPosAux,5] <= aBrwse[02,14] )
		cQuadrant := MV_PAR14
	//-
	ElseIf ( aCom2AVA[nPosAux + 1,5] >= aBrwse[01,11] .And. aCom2AVA[nPosAux + 1,5] <= aBrwse[01,12] ) .And.;
		( aCom2AVA[nPosAux,5] >= aBrwse[02,07] .And. aCom2AVA[nPosAux,5] <= aBrwse[02,08] )
		cQuadrant := MV_PAR15
	
	ElseIf ( aCom2AVA[nPosAux + 1,5] >= aBrwse[01,11] .And. aCom2AVA[nPosAux + 1,5] <= aBrwse[01,12] ) .And.;
		( aCom2AVA[nPosAux,5] >= aBrwse[02,09] .And. aCom2AVA[nPosAux,5] <= aBrwse[02,10] )
		cQuadrant := MV_PAR16
	
	ElseIf ( aCom2AVA[nPosAux + 1,5] >= aBrwse[01,11] .And. aCom2AVA[nPosAux + 1,5] <= aBrwse[01,12] ) .And.;
		( aCom2AVA[nPosAux,5] >= aBrwse[02,11] .And. aCom2AVA[nPosAux,5] <= aBrwse[02,12] )
		cQuadrant := MV_PAR17
	
	ElseIf ( aCom2AVA[nPosAux + 1,5] >= aBrwse[01,11] .And. aCom2AVA[nPosAux + 1,5] <= aBrwse[01,12] ) .And.;
		( aCom2AVA[nPosAux,5] >= aBrwse[02,13] .And. aCom2AVA[nPosAux,5] <= aBrwse[02,14] )
		cQuadrant := MV_PAR18
	//-
	ElseIf ( aCom2AVA[nPosAux + 1,5] >= aBrwse[01,13] .And. aCom2AVA[nPosAux + 1,5] <= aBrwse[01,14] ) .And.;
		( aCom2AVA[nPosAux,5] >= aBrwse[02,07] .And. aCom2AVA[nPosAux,5] <= aBrwse[02,08] )
		cQuadrant := MV_PAR19
	
	ElseIf ( aCom2AVA[nPosAux + 1,5] >= aBrwse[01,13] .And. aCom2AVA[nPosAux + 1,5] <= aBrwse[01,14] ) .And.;
		( aCom2AVA[nPosAux,5] >= aBrwse[02,09] .And. aCom2AVA[nPosAux,5] <= aBrwse[02,10] )
		cQuadrant := MV_PAR20
	
	ElseIf ( aCom2AVA[nPosAux + 1,5] >= aBrwse[01,13] .And. aCom2AVA[nPosAux + 1,5] <= aBrwse[01,14] ) .And.;
		( aCom2AVA[nPosAux,5] >= aBrwse[02,11] .And. aCom2AVA[nPosAux,5] <= aBrwse[02,12] )
		cQuadrant := MV_PAR21
	
	ElseIf ( aCom2AVA[nPosAux + 1,5] >= aBrwse[01,13] .And. aCom2AVA[nPosAux + 1,5] <= aBrwse[01,14] ) .And.;
		( aCom2AVA[nPosAux,5] >= aBrwse[02,13] .And. aCom2AVA[nPosAux,5] <= aBrwse[02,14] )
		cQuadrant := MV_PAR22
	
	EndIf
	(cMyAlias)->QUADRANTE	:= cQuadrant
	(cMyAlias)->(MsUnLock())
	
	dbSelectArea("CODAVA4")
	CODAVA4->(dbSkip())
	If !Eof()
		CODAVA4->(dbSkip())
	EndIf
EndDo

//------------------------------------
//Executa query para leitura da tabela
//------------------------------------
cQuery := "select * from " + oTempTable:GetRealName()
cArqSql	:= "%" + oTempTable:GetRealName() + "%"

BEGIN REPORT QUERY oSection1
//?MPSysOpenQuery( cQuery, 'QRYTMP' )
BeginSql alias cAliasQry
	SELECT	*
	FROM %exp:cArqSql%
	ORDER BY 1,3
EndSql
END REPORT QUERY oSection1

oReport:SetTitle(OemToAnsi("Relatório de Plano de Sucessão"))

oSection2:SetParentQuery(.T.)
//oSection2:SetParentFilter({|cParam|(cAls01)->PF_REGRAPA == cParam},{||(cAls01)->PF_REGRAPA})

oSection1:Print()

//---------------------------------
//Exclui a tabela 
//---------------------------------
oTempTable:Delete() 

Return

/*{Protheus.doc} marcaCkb
Marca e desmarca todos
@author     Ademar Fernandes
@since      06/12/2016
@param      aBrwse2:  valores do segundo browse
@return     lRet
@project    MAN00000463701_EF_003
*/
Static Function marcaCkb(aBrwse2)

Local aArea		:= GetArea() 
Local lRet		:= .T.		   								// Retorno da rotina. 
Local lGoTop	:= .T.										// Posiciona no primeiro registro.
Local nI 		:= 0

For nI := 1 to Len(aBrwse2)

	If aBrwse2[nI,1] == !aBrwse2[nI,01]
		aBrwse2[nI,1]  := aBrwse2[nI,01]
	Else
		aBrwse2[nI,1]  := !(aBrwse2[nI,01] )
	EndIf
	
Next nI

RestArea(aArea)

Return lRet
