#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'
#Include 'FONT.CH'
#Include 'COLORS.CH'

/*/{Protheus.doc} REDA011
O objetivo é permitir ao usuário manipular a barra de botões nas rotinas de visualização, inclusão, 
Alteração e exclusão de Pedido de Compra, para inclusão de uma observação no Pedido de Compra corrente.
Rotina de Pedido de Compras MATA120()
@type function
@author Ricardo da Silva
@since 25/10/2017
@version 1.0
@return .T.
/*/
User Function REDA011()

Local aAreaSC7 		:= SC7->(GetArea())

Private nRecno 		:= SC7->( Recno() )
			
	// Carrega Tela com Observação
	REDA11TEL()
                                                                                                                               
RestArea(aAreaSC7)
	
Return( .T. )

////////////////////////////////////////////////////////////////
/* Tela para Inserção da Observação no Pedido de Compras      */
////////////////////////////////////////////////////////////////
Static Function REDA11TEL()

//TMultiGet():New( [ nRow ], [ nCol ], [ bSetGet ], [ oWnd ], [ nWidth ], [ nHeight ], [ oFont ], [ uParam8 ], [ uParam9 ], [ uParam10 ], [ uParam11 ], [ lPixel ], [ uParam13 ], [ uParam14 ], [ bWhen ], [ uParam16 ], [ uParam17 ], [ lReadOnly ], [ bValid ], [ uParam20 ], [ uParam21 ], [ lNoBorder ], [ lVScroll ], [ cLabelText ], [ nLabelPos ], [ oLabelFont ], [ nLabelColor ] )
Local cObsSCIni	 	:= ""
Local cObscopi   	:= ""
Local cBusca     	:= ""
Local cPedido    	:= SC7->C7_NUM
Local cPosiciona 	:= ""
Private nPosNumSc 	:= aScan(aHeader, {|x| AllTrim(x[2]) == "C7_NUMSC"})
Private nPosIteSc 	:= aScan(aHeader, {|x| AllTrim(x[2]) == "C7_ITEMSC"})
Private nPosInfPac 	:= aScan(aHeader, {|x| AllTrim(x[2]) == "C7_XINFPAC"})
//Private cObsSC   := Space(254)

cObsSC     := If(Type("cObsSC") == "C", cObsSC, Space(254))
// Verifico se Observação já foi preenchida
If !Empty(AllTrim(SC7->C7_XINFPAC)) .And. ALTERA .And. Empty(AllTrim(cObsSC))
	// Carrega Observação
	For nX := 01 To Len(aCols)
		lDelet := aCols[nX][Len(aHeader)+1]
		If !lDelet
			cObsSC := AllTrim(aCols[nX][nPosInfPac])
			Exit
		EndIf		
	Next nX	
Else
     If !lCop .And. Empty(cObsSC) .And. Empty(AllTrim(aCols[1][nPosInfPac]))
		For nX := 01 To Len(aCols)
			lDelet := aCols[nX][Len(aHeader)+1]
			If !lDelet
				cObsSC := Posicione("SC1",1,xFilial("SC1") + aCols[nX][nPosNumSc] + aCols[nX][nPosIteSc], "C1_XINFPAC")
				Exit
			EndIf		
		Next nX	
	Else
 	    For nX := 01 To Len (aCols)
			lDelet := aCols[nX][Len (aHeader) +1]
			If !lDelet
 	            cObsSC := AllTrim(aCols[nX][nPosInfPac])
				Exit
			EndIf
		Next nX
 	EndIf
EndIf

cObsSCIni := cObsSC

// Monta Tela do usuário para inserção da Observação da Solicitação de Compras
SetPrvt("oDlgObsSC","oGrpObs","oSayObs","oSaySText","oObsSC","oBtnConfirmar","oBtnSair")

oDlgObsSC	:= MSDialog():New( 086,233,422,1051,"Observação da Solicitação de Compras",,,.F.,,,,,,.T.,,,.T. )
oGrpObs 	:= TGroup():New( 004,008,156,316,"Observação",oDlgObsSC,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSayObs 	:= TSay():New( 020,016,{||"Descrição"},oGrpObs,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,028,008)
oObsSC  	:= TMultiGet():New( 020,044,{|u| If(PCount()>0,cObsSC:=u,cObsSC)},oDlgObsSC, 260, 122,,,,,, .T.,,,,,,!(INCLUI .Or. ALTERA .Or. lCop),,,,,,,,,)

oBtnConfir 	:= TButton():New( 008,328,"&Confirmar <Alt+ C>",oDlgObsSC,{||RedaGrvSC7()}   ,064,012,,,,.T.,,"",,,,.F. )
oBtnSair   	:= TButton():New( 027,328,"&Sair <Alt+S>"      ,oDlgObsSC,{||cObsSC := cObsSCIni, oDlgObsSC:End()},064,012,,,,.T.,,"",,,,.F. )

oDlgObsSC:Activate(,,,.T.)


Return( .T. )

/////////////////////////////////////////////////////////////////////
/* Valida tamanho do conteúdo digitado em no máximo 254 caracteres */
/////////////////////////////////////////////////////////////////////
Static Function LerTamText()

Local cLinCont := AllTrim(CValToChar(oObsSC:nPos))
Local lReturn  := .T.

oSaySText := TSay():New( 310,016,{||cLinCont},oGrpObs,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,028,008)

// Verifica se o número de caracteres digitados excedeu 254 caracteres 
If ( Len(AllTrim(cObsSC)) > 254 )
	Aviso("Número de caracteres", "Foi excedido o número de 254 caracteres, " + "foram digitados " + cValTochar(Len(AllTrim(cObsSC))) + " !", {"Ok"})
	lReturn  := .F.
EndIf
 
Return( lReturn )

////////////////////////////////////////////////////////////////////////
/* Grava a observação nos Itens do Pedido de Compras selecionado      */
////////////////////////////////////////////////////////////////////////
Static Function RedaGrvSC7()                                                                                                

Local lcFilial  := ""
Local lcNumPed 	:= "" 
Local lcItemPed	:= ""
Local lcSequenc	:= ""

Local lcNumSC 	:= "" 
Local lcItemSC	:= ""
Local lTamanho  := .F.

cObsSC 		:= fFormatText()
lTamanho 	:= LerTamText()

If lTamanho	
	cFil  		:= SC7->C7_FILIAL
	cNumPed		:= SC7->C7_NUM
	cItemPed	:= SC7->C7_ITEM
	SC7->(DbGoTop())
	SC7->(DbSetOrder(01))
	If SC7->(DbSeek(cFil+cNumPed+cItemPed))                                                                                                                            				
		For nX := 01 To Len(aCols)
			aCols[nX][nPosInfPac] := cObsSC
		Next nX										
	EndIf
	SC7->( DbGoTo( nRecno ) )
	oDlgObsSC:End()
EndIf
    
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