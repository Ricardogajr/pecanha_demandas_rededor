#INCLUDE 'PROTHEUS.CH'

/*{Protheus.doc} F1200706
Exibe tela de seleção de contratos por agrupamento.
@author 	Paulo Krüger
@since 		17/08/2017
@version 	P12.7
@Project    MAN0000007423046
@Return 	Nil
*/
User Function F1200706() 
 
Local	aAreaCNA	:= CNA->(GetArea())	
Local	cTabPrc		:= ""
Local	cForn		:= ""

Local	cId			:=	''
Local	nI			:=	0
Local	aTlDimens	:=	{}
Local	aListAux	:=	{} 	
Local	aObjects	:=	{}
Local 	aButtons1 	:= 	{}
Local	cNmFilCtr	:=	''
Local	cNmFilAut	:=	''
Local	nSM0Recno	:=	0

Private oNoMarked
Private oMarked
Private oList
Private aList 		:= {}

oNoMarked   := LoadBitmap(GetResources(), 'LBNO')
oMarked     := LoadBitmap(GetResources(), 'LBOK')
cId			:= aSelContr[01][01]
aTlDimens	:= MsAdvSize(.T.)

For nI := 01 To Len(aSelContr[01][06])
	cTabPrc		:= ""
	cForn		:= ""

	nSM0Recno	:=	SM0->(Recno())
	cNmFilCtr	:=	Alltrim(POSICIONE('SM0',01,cEmpAnt + aSelContr[01][06][nI][04],'M0_FILIAL'))
	cNmFilAut	:=	Alltrim(POSICIONE('SM0',01,cEmpAnt + aSelContr[01][06][nI][15],'M0_FILIAL'))
	SM0->(DbGoTo(nSM0Recno))

	CNA->(DbSetOrder(1))
	If CNA->(DbSeek(aSelContr[01][06][nI][04] + aSelContr[01][06][nI][05] + aSelContr[01][06][nI][06] + aSelContr[01][06][nI][10]))
		cTabPrc		:= CNA->CNA_XTABPC
		cForn		:= POSICIONE("SA2",1,xFilial("SA2") + CNA->(CNA_FORNEC + CNA_LJFORN), "A2_NREDUZ")
	EndIf
//                  Contrato                 , Vigência                  , Filial                    , Nome da filial , Tabela de Preço    , Nome Fornecedor     , Filial autorizada        , Nome da filial autorizada, ID
	aListAux:={.F., aSelContr[01][06][nI][05], aSelContr[01][06][nI][07] , aSelContr[01][06][nI][04] , cNmFilCtr      , cTabPrc            , cForn               , aSelContr[01][06][nI][15], cNmFilAut                , cId}
	AAdd(aList, aListAux)
Next nI

AAdd(aObjects, {100, 50, .T., .T., .T.})
aInfo		:= {aTlDimens[1], aTlDimens[2], aTlDimens[3], aTlDimens[4], 5, 5}
aPosObjH	:= MsObjSize(aInfo, aObjects, .T., .F.)
oTFont		:= TFont():New('Courier new', ,-16, .T., .T.)

DEFINE MSDIALOG oDlg TITLE 'Seleção de contrato'  FROM aTlDimens[7], 00 TO 400, 1200 OF oMainWnd PIXEL
oPanelTop:= tPanel():New(0, 0, 	'Filial: '           + AllTrim(cNmFilAut)         + '|' + ;
								'Produto: '          + AllTrim(aSelContr[01][03]) + '|' + ;
								'Local de estoque: ' + AllTrim(aSelContr[01][04]) + '|' + ;
								'Centro de Custo: '  + Alltrim(aSelContr[01][05]), oDlg, oTFont, .T., ,, CLR_HGRAY, 00, 020)
oPanelTop:align:= CONTROL_ALIGN_TOP
@ 30, 10 LISTBOX oList VAR cLbx1 FIELDS HEADER ''	, 'Contrato'					;
													, 'Vigência'					;
													, 'Filial'						;
													, 'Nome da filial'				;
													, 'Tabela Preço'				;
													, 'Nome Fornecedor'				;
													, 'Filial autorizada'			;
													, 'Nome da filial autorizada'	;
													, 'Id' SIZE 500, 400 OF oDlg ON DBLCLICK (F12706MARK()) PIXEL

oList:align:= CONTROL_ALIGN_ALLCLIENT
oList:SetArray(aList)
			
// Monta a linha a ser exibina no Browse
oList:bLine := {||{ Iif(	aList[oList:nAt, 01], oMarked, oNoMarked), ;
							aList[oList:nAt, 02], 	;
							aList[oList:nAt, 03], 	;
							aList[oList:nAt, 04], 	;
							aList[oList:nAt, 05], 	;
							aList[oList:nAt, 06], 	;
							aList[oList:nAt, 07], 	;
							aList[oList:nAt, 08], 	;
							aList[oList:nAt, 09], 	;
							aList[oList:nAt, 10]} }
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| lRet := U_F1200707(oList,aSelContr), oDlg:End() }, {||lRet:= .F., oDlg:End()}, ,aButtons1)
RestArea(aAreaCNA)
Return

/*
{Protheus.doc} F12706MARK()
Marca/Desmarca registro
@Author		Paulo Krüger
@since 		17/08/2017
@Version	P12.7
@Project    MAN00000462901_EF_001	
*/

Static Function F12706MARK()
	Local nX:= 0

	For nX:= 1 to Len(aList)
		aList[nX][1] := .F.
	Next nX
	
	aList[oList:nAT, 1] := !aList[oList:nAT, 1]
	oList:Refresh()
Return

/*
{Protheus.doc} fCloseDlg()
Fecha janelas.
@Author		Paulo Krüger
@since 		17/08/2017
@Version	P12.7
@Project    MAN00000462901_EF_001	
*/
Static Function fCloseDlg(oDlg,oMrkBrowse)

	oDlg:END()
	CloseBrowse()

Return