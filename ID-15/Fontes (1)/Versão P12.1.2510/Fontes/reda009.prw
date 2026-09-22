#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'
#Include 'FONT.CH'
#Include 'COLORS.CH'

/*/{Protheus.doc} REDA009
O objetivo é permitir ao usuário manipular a barra de botões nas rotinas de visualização, inclusão, 
Alteração e exclusão de solcitação de compras, para inclusão de uma observação na Solictação de Compras corrente.
Rotina de Solicitação de Compras MATA110()
@type function
@author Ricardo da Silva
@since 23/10/2017
@version 1.0
@return .T.
/*/
User Function REDA009()

Local aAreaSC1 		:= SC1->(GetArea())

Private nRecno 		:= SC1->(Recno())

	// Carrega Tela com Observação
	REDA09TEL()
                                                                                                                               
RestArea(aAreaSC1)
	
Return( .T. )

////////////////////////////////////////////////////////////////
/* Tela para Inserção da Observação na Solicitação de Compras */
////////////////////////////////////////////////////////////////
Static Function REDA09TEL()

//TMultiGet():New( [ nRow ], [ nCol ], [ bSetGet ], [ oWnd ], [ nWidth ], [ nHeight ], [ oFont ], [ uParam8 ], [ uParam9 ], [ uParam10 ], [ uParam11 ], [ lPixel ], [ uParam13 ], [ uParam14 ], [ bWhen ], [ uParam16 ], [ uParam17 ], [ lReadOnly ], [ bValid ], [ uParam20 ], [ uParam21 ], [ lNoBorder ], [ lVScroll ], [ cLabelText ], [ nLabelPos ], [ oLabelFont ], [ nLabelColor ] )

Private cObsSC     := If(Empty(pIncObsSC),Space(254),pIncObsSC)

// Verifica se Observação já foi preenchida
If ( !Empty(SC1->C1_XINFPAC) .And. !INCLUI .And.  Empty(cObsSC))
	// Carrega Observação
	cObsSC := fGetObs()
EndIf

pIncObsSC := cObsSC
 
// Monta Tela do usuário para inserção da Observação da Solicitação de Compras
SetPrvt("oDlgObsSC","oGrpObs","oSayObs","oSaySText","oObsSC","oBtnConfirmar","oBtnSair")

oDlgObsSC	:= MSDialog():New( 086,233,422,1051,"Observação da Solicitação de Compras",,,.F.,,,,,,.T.,,,.T. )
oGrpObs 	:= TGroup():New( 004,008,156,316,"Observação",oDlgObsSC,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSayObs 	:= TSay():New( 020,016,{||"Descrição"},oGrpObs,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,028,008)
oObsSC  	:= TMultiGet():New( 020,044,{|u| If(PCount()>0,cObsSC:=u,cObsSC)},oDlgObsSC, 260, 122,,,,,, .T.,,,,,,!(INCLUI .Or. ALTERA .OR. LCOPIA),/*{|| LerTamText()}*/,,,,,,,,)

oBtnConfir 	:= TButton():New( 008,328,"&Confirmar <Alt+ C>",oDlgObsSC,{||RedaGrvSC1()}   ,064,012,,,,.T.,,"",,,,.F. )
oBtnSair   	:= TButton():New( 027,328,"&Sair <Alt+S>"      ,oDlgObsSC,{||cObsSC := pIncObsSC, oDlgObsSC:End()},064,012,,,,.T.,,"",,,,.F. )

oDlgObsSC:Activate(,,,.T.)

Return( .T. )

/////////////////////////////////////////////////////////////////////
/* Valida tamanho do conteúdo digitado em no máximo 254 caracteres */
/////////////////////////////////////////////////////////////////////
Static Function LerTamText()

Local lReturn  := .T.

//oSaySText := TSay():New( 310,016,{||cLinCont},oGrpObs,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,028,008)

// Verifica se o número de caracteres digitados excedeu 254 caracteres 
If Len(cObsSc) > 254
	Aviso("Número de caracteres", "Foi excedido o número de 254 caracteres, " + "foram digitados " +  cValToChar(Len(cObsSc)) + " !", {"Ok"})
	lReturn  := .F.
EndIf
 
Return( lReturn )

////////////////////////////////////////////////////////////////////////
/* Grava a observação nos Itens da Solicitação de Compras selecionada */
////////////////////////////////////////////////////////////////////////
Static Function RedaGrvSC1()

Local lcFilial  := ""
Local lcNum 	:= "" 
Local lTamanho  := .F.

cObsSC := fFormatText()	
lTamanho := LerTamText()

If lTamanho
	If INCLUI .Or. ALTERA .Or. LCOPIA
		pIncObsSC := cObsSC
	EndIf				
	/*
	Else 	
		lcFilial  	:= SC1->C1_FILIAL
		lcNum 		:= SC1->C1_NUM
		pIncObsSC	:= cObsSC
			
		SC1->(DbSetOrder(01))
		SC1->(DbGoTop())
		// Posiciono no primeiro Item da SC para grava a Observação digitada
		If SC1->(DbSeek(lcFilial+lcNum))                                                                                                                            		
			While !SC1->(Eof()) .And. SC1->C1_FILIAL == lcFilial .And. SC1->C1_NUM == lcNum  			 
				RecLock("SC1", .F.)
					SC1->C1_XINFPAC := cObsSC 
				SC1->(MsUnLock())			    
			    SC1->(DbSkip())				
			EndDo		
		EndIf		
	EndIf
	*/	
	// Posiciono no primeiro registro da SC selecionada
	SC1->( DbGoTo( nRecno ) )
	// Fecho a janela de Dialogo
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
*--------------------------------*
Static Function fGetObs()
*--------------------------------*
	Local cObs := ""
	
	SC1->(DbGoTo(nRecno))
	cObs := SC1->C1_XINFPAC
	
Return cObs