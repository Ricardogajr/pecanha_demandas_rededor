#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'
#Include 'FONT.CH'
#Include 'COLORS.CH'

/*/{Protheus.doc} REDA010
O objetivo é permitir ao usuário manipular a barra de botões nas rotinas de visualização, inclusão, 
Alteração e exclusão de Preços da Cotação, para inclusão de uma observação na Cotação corrente.
Rotina de Preços da Cotação MATA150()
@type function
@author Ricardo da Silva
@since 24/10/2017
@version 1.0
@return .T.
/*/
User Function REDA010()

Local aAreaSC8 := SC8->(GetArea())
Private nRecno := 0

	//Identifico o Registro e posicono no mesmo
	//PosicCotacao()	
	If SC8->(DbSeek(xFilial("SC8") + cA150Num + cA150Forn + cA150Loj))
		// Carrega Tela com Observação
		REDA10TEL()
    EndIf                                                                                                                           
RestArea(aAreaSC8)
	
Return( .T. )

////////////////////////////////////////////////////////////////
/* Tela para Inserção da Observação no Preço de Cotação       */
////////////////////////////////////////////////////////////////
Static Function REDA10TEL()

//TMultiGet():New( [ nRow ], [ nCol ], [ bSetGet ], [ oWnd ], [ nWidth ], [ nHeight ], [ oFont ], [ uParam8 ], [ uParam9 ], [ uParam10 ], [ uParam11 ], [ lPixel ], [ uParam13 ], [ uParam14 ], [ bWhen ], [ uParam16 ], [ uParam17 ], [ lReadOnly ], [ bValid ], [ uParam20 ], [ uParam21 ], [ lNoBorder ], [ lVScroll ], [ cLabelText ], [ nLabelPos ], [ oLabelFont ], [ nLabelColor ] )
Local nPosNumSc:= 00
Local nPosIteSc:= 00
Local cObsSCIni:= ""

cObsSC     := If(Type("cObsSC") == "C", cObsSC, Space(254))

nPosNumSc := aScan(aHeader, {|x| AllTrim(x[2]) == "C8_NUMSC"})
nPosIteSc := aScan(aHeader, {|x| AllTrim(x[2]) == "C8_ITEMSC"})	

DbSelectArea("SC8")
SC8->(DbSetOrder(01))
//SC8->(DbGoTo(nRecno))

If !Empty(SC8->C8_XINFPAC) .And. Empty(cObsSC)
	cObsSC := SC8->C8_XINFPAC
ElseIf Empty(SC8->C8_XINFPAC)  .And. !Empty(aCols[1][nPosNumSc]) .And. Empty(cObsSC)	
	For nX := 01 To Len(aCols)
		lDelet := aCols[nX][Len(aHeader)+1]
		If !lDelet
			cObsSC := Posicione("SC1",1,xFilial("SC1") + aCols[nX][nPosNumSc] + aCols[nX][nPosIteSc], "C1_XINFPAC")
			Exit
		EndIf
	Next nX	
EndIf

cObsSCIni := cObsSC
 
SetPrvt("oDlgObsSC","oGrpObs","oSayObs","oSaySText","oObsSC","oBtnConfirmar","oBtnSair")

oDlgObsSC	:= MSDialog():New( 086,233,422,1051,"Observação da Solicitação de Compras",,,.F.,,,,,,.T.,,,.T. )
oGrpObs 	:= TGroup():New( 004,008,156,316,"Observação",oDlgObsSC,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSayObs 	:= TSay():New( 020,016,{||"Descrição"},oGrpObs,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,028,008)
oObsSC  	:= TMultiGet():New( 020,044,{|u| If(PCount()>0,cObsSC:=u,cObsSC)},oDlgObsSC, 260, 122,,,,,, .T.,,,,,,(INCLUI .Or. ALTERA),,,,,,,,,)

oBtnConfir 	:= TButton():New( 008,328,"&Confirmar <Alt+ C>",oDlgObsSC,{||RedaGrvSC8()}   ,064,012,,,,.T.,,"",,,,.F. )
oBtnSair   	:= TButton():New( 027,328,"&Sair <Alt+S>"      ,oDlgObsSC,{|| cObsSC := cObsSCIni, oDlgObsSC:End()},064,012,,,,.T.,,"",,,,.F. )

oDlgObsSC:Activate(,,,.T.)

Return( .T. )

/////////////////////////////////////////////////////////////////////
/* Valida tamanho do conteúdo digitado em no máximo 254 caracteres */
/////////////////////////////////////////////////////////////////////
Static Function LerTamText()

Local lReturn  := .T.

// Verifica se o número de caracteres digitados excedeu 254 caracteres 
If ( Len(AllTrim(cObsSC)) > 254 )
	Aviso("Número de caracteres", "Foi excedido o número de 254 caracteres, " + "foram digitados " +  cValTochar(Len(AllTrim(cObsSC))) + " !", {"Ok"})
	lReturn  := .F.
EndIf
 
Return( lReturn )

////////////////////////////////////////////////////////////////////////
/* Grava a observação nos Itens da Cotação selecionada                */
////////////////////////////////////////////////////////////////////////
Static Function RedaGrvSC8()   

Local cFil  	:= xFilial("SC8")
Local cNum 		:= cA150Num
Local cForn		:= cA150Forn
Local cLoja 	:= cA150Loj
Local Tamanho	:= .F.
Local aArea		:= GetArea()

cObsSc 	 := fFormatText()	
lTamanho := LerTamText()

//SC8->(DbGoTo(Recno()))

If lTamanho
	SC8->(DbSetOrder(01))		
	If SC8->(DbSeek( cFil + cNum + cForn + cLoja))                                                                                                                            
		While !SC8->(Eof()) .And. SC8->C8_FILIAL  == cFil .And. SC8->C8_NUM  == cNum .And. SC8->C8_FORNECE == cForn   .And. SC8->C8_LOJA == cLoja	 
			RecLock("SC8", .F.)	
				SC8->C8_XINFPAC := cObsSC  
			SC8->(MsUnLock())	    
		    SC8->(DbSkip())	
		End
	EndIf
	//SC8->(DbGoTo(nRecno))
	oDlgObsSC:End()	
EndIf

RestArea(aArea)
Return(.T.)

////////////////////////////////////////////////////////////////////////
/* Posiciona na Cotação de Preços selecionada na Grid                 */
////////////////////////////////////////////////////////////////////////
Static Function PosicCotacao()

Local lcNum 	:= aCols[1][01] // C8_NUM
Local lcItem 	:= aCols[1][02] // C8_ITEM
Local lcNumPro	:= aCols[1][03] // C8_NUMPRO
Local lcNumSC 	:= aCols[1][23] // C8_NUMSC
Local lcItemSC 	:= aCols[1][24] // C8_ITEMSC
//
Local cTabSc8   := RetSqlName("SC8")
Local cALiasSC8	:= "SC8TMP"
Local cQuery 	:= ""

cQuery := " SELECT R_E_C_N_O_ AS RECNO FROM " + cTabSc8 + " SC8 " + CRLF
cQuery += " WHERE D_E_L_E_T_ = ' ' "                            + CRLF
cQuery += " AND C8_FILIAL = " + "'" + xFilial("SC8") + "'" + "" + CRLF
cQuery += " AND C8_NUM    = " + "'" + lcNum          + "'" + "" + CRLF
cQuery += " AND C8_ITEM   = " + "'" + lcItem         + "'" + "" + CRLF
cQuery += " AND C8_NUMPRO = " + "'" + lcNumPro       + "'" + "" + CRLF
cQuery += " AND C8_NUMSC  = " + "'" + lcNumSC        + "'" + "" + CRLF
cQuery += " AND C8_ITEMSC = " + "'" + lcItemSC       + "'" + "" + CRLF
cQuery += " ORDER BY C8_FILIAL, C8_NUM, C8_FORNECE, C8_LOJA, C8_ITEM, C8_NUMPRO, C8_ITEMGRD "

If ( Select(cALiasSC8) > 0 )
	(cALiasSC8)->( DbCloseArea() )
EndIf

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC8,.T.,.T.)
nRecno := (cAliasSC8)->( RECNO )
//                                                                                                                           
(cALiasSC8)->( DbCloseArea() )

Return( .T. )

*----------------------------------------*
Static Function fFormatText()
*----------------------------------------*
	Local aAux	 := {}
	Local nX	 := 00
	Local cTexto := ""
	
	While "  " $ cObsSC 
		cObsSc := StrTran(cObsSC, "  ", " ")
	EndDo
	
	aAux := StrTokArr(cObsSc, ""+ chr(13)+chr(10))
	
	For nX := 01 To Len(aAux)
		cTexto += aAux[nX] + " "
    Next nX
    
Return cTexto