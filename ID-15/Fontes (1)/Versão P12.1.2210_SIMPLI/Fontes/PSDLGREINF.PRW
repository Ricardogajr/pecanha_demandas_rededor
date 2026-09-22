/*/
==================================================================================
Dt Ajustes : 16/01/2019
----------------------------------------------------------------------------------
Autor      : ................
Ajustes    : Daniel Machado
----------------------------------------------------------------------------------
Descricao  : Tratamento para a fun��o DLGREINF referente ao REINF
----------------------------------------------------------------------------------
Partida    : Ponto de Entrada - MT100AGR e FSPE0020
==================================================================================
/*/

#INCLUDE "PROTHEUS.CH"
#Include "TopConn.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FILEIO.CH"

User Function LoadSX5( cCampo )

	Local aItens  := {}
	Local cTabela := GetAdvFVal( 'SX3', 'X3_F3', cCampo,2, '' )
	Local _aSx5Tab	:= {} //Thais Paiva - Compatibiliza��o P27

	aAdd( aItens, "  " )
	
	//In�cio - Thais Paiva - Compatibiliza��o P27
	//DbSelectArea( 'SX5' )

	//If SX5->( DbSeek( xFilial( 'SX5' ) + Alltrim( cTabela ) ) )
		//While SX5->( ! Eof() ) .And. ( Alltrim( SX5->X5_TABELA ) == Alltrim( cTabela ) )
	_aSx5Tab := U_SX5UTILI("A",Alltrim(cTabela))
	For _nX5 := 1 to Len(_aSx5Tab)
			//cLinha := AllTrim( SX5->( X5_CHAVE ) ) + "=" + AllTrim( SX5->X5_DESCRI )
		cLinha := AllTrim(_aSx5Tab[_nX5][3]) + "=" + AllTrim( _aSx5Tab[_nX5][4] )
		aAdd( aItens, cLinha )
	Next _nX5
			//SX5->( DbSkip() )
		//End
	//EndIf
	//Fim - Thais Paiva - Compatibiliza��o P27

Return( aItens )

*******************************
User Function LoadSX3( cCampo )
*******************************

	Local aItens := {}
	Local aCombo := RetSX3Box( GetSX3Cache( cCampo, "X3_CBOX" ),,, 1 )

	For nx = 1 to Len( aCombo )
	   aAdd( aItens, aCombo[nx][1] )
	Next nx

Return( aItens )

***********************                                                                                                      
User Function CalcD15()
***********************

	If NE2_SERV15 > nE2_BASEINS
		Aviso( "Informa��o","O valor do campo Bas.Serv.E15 R$ " + Alltrim( Transform( ne2_serv15, "@E 999,999,999.99" ) ) + " deve ser menor ou igual ao valor do INSS R$ " + Alltrim( Transform(nE2_INSS, "@E 999,999,999.99" ) ) + " !", { "Ok" } )
	    LOK := .F.
	Else
		If nE2_SERV15 < 0
			Aviso( "Informa��o", "O valor do campo Bas.Serv.E15 esta Negativo", { "Ok" } )
			LOK := .F.
	    Else
	      	If NE2_SERV15 > 0.00
	      		nE2_INSS15 := Round( ( ( nE2_SERV15 * 4 ) / 100 ), 2 )
	      	Else
	      		nE2_INSS15 := 0.00
	      	EndIf

	    	nE2_VLADIC := Round( nE2_INSS15 + nE2_INSS20 + nE2_INSS25, 2 )

	    	oXVLADIC:refresh()

	    	nE2_VALOR := Round( (cal_BASEINS) - nE2_VLADIC - nE2_INSS - nE2_IRRF - if(!lMRETISS ,0,if(cRecIss = "1",0,nE2_ISS)), 2 )
		
	    	oXVLTOTAL:refresh()

	    	LOK := .T.
	    EndIf
	EndIf

Return( LOK )

***********************                                                                                                      
User Function CalcD20()
***********************

	If NE2_SERV20 > nE2_BASEINS
		Aviso( "Informa��o", "O valor do campo Bas.Serv.E20 R$" + Alltrim( Transform( ne2_serv20, "@E 999,999,999.99" ) ) + " deve ser menor ou igual ao do valor Base INSS R$" + Alltrim( Transform( nE2_INSS, "@E 999,999,999.99" ) ) + " !", { "Ok" } )
		LOK := .F.
	Else
		If nE2_SERV20 < 0
			Aviso( "Informa��o", "O valor do campo Bas.Serv.E20 esta Negativo", { "Ok" } )
			LOK := .F.
		Else
			If NE2_SERV20 > 0.00
				nE2_INSS20 := Round( ( ( nE2_SERV20 * 3 ) / 100 ), 2 )
			Else
				nE2_INSS20 := 0.00
			EndIf

			nE2_VLADIC := Round( nE2_INSS15 + nE2_INSS20 + nE2_INSS25, 2 )

			oXVLADIC:refresh()

			nE2_VALOR := Round( (cal_BASEINS) - nE2_VLADIC - nE2_INSS - nE2_IRRF - if(!lMRETISS ,0,if(cRecIss = "1",0,nE2_ISS)), 2 )
		
			oXVLTOTAL:refresh()

			LOK := .T.
		EndIf
	EndIf

Return( LOK )

***********************                                                                                                      
User Function CalcD25()
***********************

	If NE2_SERV25 > nE2_BASEINS
		Aviso( "Informa��o", "O valor do campo Bas.Serv.E25 R$ " + Alltrim( Transform( ne2_serv20, "@E 999,999,999.99" ) ) + " deve ser menor ou igual ao do valor Base INSS R$" + Alltrim( Transform( nE2_INSS, "@E 999,999,999.99" ) ) + " !", { "Ok" } )
	    LOK := .F.
	Else
	    If nE2_SERV25 < 0
	    	Aviso( "Informa��o", "O valor do campo Bas.Serv.E25 esta Negativo", { "Ok" } )
	    	LOK := .F.
	    Else
	       	If NE2_SERV25 > 0.00
	       		nE2_INSS25 := Round( ( ( nE2_SERV25 * 2 ) / 100 ), 2 )
	       	Else
	       		nE2_INSS25 := 0.00
	       	EndIf

	       	nE2_VLADIC := Round( nE2_INSS15 + nE2_INSS20 + nE2_INSS25, 2 )

	       	oXVLADIC:refresh()
	       	
	       	nE2_VALOR := Round( (cal_BASEINS) - nE2_VLADIC - nE2_INSS - nE2_IRRF - if(!lMRETISS ,0,if(cRecIss = "1",0,nE2_ISS)), 2 )
		 	oXVLTOTAL:refresh()

	       	LOK := .T.
       EndIf
	EndIf

Return( LOK )

******************************
User Function Calcins( comf5 )
******************************

	Local lCalcinss := .T.
	Local cNaturez  := ''
	Local lnTaxa    := 0.00, _nPosAliq := 0

	cNaturez := alltrim( MAFISRET( , "NF_NATUREZA" ) )

	DbSelectArea( "SED" )
	SED->( DbSetOrder( 1 ) )

	If SED->( DbSeek( xFilial( "SED" ) + cNaturez ) )

		If SED->ED_CALCINS == "S"
			lCalcInss := .T.
		ElseIf SED->ED_CALCINS == "N"
			lCalcInss := .F.
		EndIf

	EndIf

	_nPosAliq := aScan( aHeader, { |x| AllTrim( Upper( X[2] ) ) == "D1_ALIQINS" } )

	If aCols[n][_nPosAliq] <> 11 .And. aCols[n][_nPosAliq] <> 3.5 .And. aCols[n][_nPosAliq] <> 5 .And. aCols[n][_nPosAliq] <> 0
		Aviso( 'Aten��o', 'Sua aliquota informada para INSS n�o est� de acordo com o definido, verifique!', { 'Volta' } )
		aCols[n][_nPosAliq] := 0
		Return
	EndIf

	If lCalcInss .Or. aCols[n][_nPosAliq] > 0
		If aCols[n][_nPosAliq] == 11.00
			lnTaxa     := 11
			cE2_XICPRB := 0
			aE2_XICPRB := "0=Retencao 11% "
		ElseIf aCols[n][_nPosAliq] == 3.50
			lnTaxa     := 3.5
			cE2_XICPRB := 1
			aE2_XICPRB := "1=Retencao 3,5%"
		ElseIf aCols[n][_nPosAliq] == 5.00
			lnTaxa     := 5
			cE2_XICPRB := 2
			aE2_XICPRB := "2=Retencao 5%  "
		ElseIf aCols[n][_nPosAliq] == 0.00
			lnTaxa      := 0
			cE2_XICPRB  := "3"
			aE2_XICPRB  := "3=             "
			cE2_XTPSERV := ""
		EndIf
	Else
		lnTaxa      := 0
		cE2_XICPRB  := "3"
		cE2_XTPSERV := ""
		aE2_XICPRB  := "3=             "
	EndIf    

	If lnTaxa > 0 .And. nE2_BASEINS > 0
		nE2_INSS := Round( ( ( nE2_BASEINS * lnTaxa ) / 100 ) - nE2_RETSUB, 2 )
	Else
		nE2_INSS := 0
	EndIf

	nE2_VALOR := Round( (cal_BASEINS) - nE2_VLADIC - nE2_INSS - nE2_IRRF - if(!lMRETISS ,0,if(cRecIss = "1",0,nE2_ISS)), 2 )
		
	If comf5 = "com"
		oXVLINSS:refresh()
		oXVLTOTAL:refresh()
	EndIf

Return

******************************                                                                                                      
User Function Calcin2( comf5 )
******************************

	Local lCalcinss := .T.
	Local cNaturez  := ''

	lnTaxa := 0

	If cValToChar( cE2_XICPRB ) = "0"
		lnTaxa := 11
	ElseIf cValToChar( cE2_XICPRB ) = "1"
		lnTaxa := 3.5
	ElseIf cValToChar( cE2_XICPRB ) = "2"
		lnTaxa := 5
	EndIf

	nE2_INSS := Round( ( nE2_BASEINS * lnTaxa ) / 100, 2 )

	If nE2_INSS > NE2_BASEINS
		lCalcinss := .F.
		Aviso( "Informa��o", "O valor do Inss Esta Maior que a Base Inss", { "Ok" } )
	EndIf

	If nE2_INSS < 0
		lCalcinss := .F.
		Aviso( "Informa��o", "O valor do Inss Esta Negativo ", { "Ok" } )
	EndIf

	If Round( nE2_RETSUB, 2 ) > Round( nE2_INSS, 2 )
		lCalcinss := .F.
		Aviso( "Informa��o", "O valor do campo Vl.Ret.S.Sub R$" + Alltrim( Transform( nE2_RETSUB, "@E 999,999,999.99" ) ) + " deve ser menor ou igual ao do valor INSS R$" + Alltrim( Transform( nE2_INSS, "@E 999,999,999.99" ) ) + " !", { "Ok" } )
	EndIf

	nE2_VALOR := Round( (cal_BASEINS) - nE2_VLADIC - nE2_INSS - nE2_IRRF - if(!lMRETISS ,0,if(cRecIss = "1",0,nE2_ISS)), 2 )
		
	If comf5 = "com"
		oXVLINSS:refresh()
		oXVLTOTAL:refresh()
	EndIf     

Return lCalcinss

******************************                                                                                                      
User Function Calcin3( comf5 )
******************************

	Local lCalcinss := .T.
	Local cNaturez  := ''

	If nE2_INSS > nE2_BASEINS
	   lCalcinss := .F.
	   Aviso( "Informa��o", "O valor do campo Val Inss R$ " + Alltrim( Transform( nE2_INSS, "@E 999,999,999.99" ) ) + " Esta Maior que a Base Inss R$" + " !", { "Ok" } )
	EndIf

	If nE2_INSS < 0
		lCalcinss := .F.
		Aviso( "Informa��o", "O valor do Inss Esta Negativo ", { "Ok" } )
	EndIf

	If lCalcinss
		nE2_VALOR := Round( (cal_BASEINS) - nE2_VLADIC - nE2_INSS - nE2_IRRF - if(!lMRETISS ,0,if(cRecIss = "1",0,nE2_ISS)), 2 )
	EndIf

	If comf5 = "com"
		oXVLINSS:refresh()
		oXVLTOTAL:refresh()
	EndIf

Return lCalcinss

******************************                                                                                                      
User Function Calcin4( comf5 )
******************************

	Local lCalcinss := .T.
	Local cNaturez  := ''

	nCALCINSS := 0.00

	If Round( nE2_RETSUB, 2 ) < 0
		lCalcinss := .F.
		Aviso( "Informa��o", "O valor do campo Vl.Ret.S.Sub esta Negativo", { "Ok" } )
	EndIf

	If lCalcinss
		lnTaxa := 0
		If cValToChar( cE2_XICPRB ) = "0"
			lnTaxa := 11
		ElseIf cValToChar( cE2_XICPRB ) = "1"
			lnTaxa := 3.5
		ElseIf cValToChar( cE2_XICPRB ) = "2"
			lnTaxa := 5
		EndIf

		nCALCINSS := ( ( nE2_BASEINS * lnTaxa ) / 100 )

		If Round( nCALCINSS, 2 ) >= Round( nE2_RETSUB, 2 )
			nE2_INSS := Round( nCALCINSS - nE2_RETSUB, 2 )
		Else
			NE2_INSS := 0
		EndIf
	EndIf

	If Round( nE2_RETSUB, 2 ) > Round( nCALCINSS, 2 )
		lCalcinss := .F.
		Aviso( "Informa��o", "O valor do campo Vl.Ret.S.Sub R$ " + Alltrim( Transform( nE2_RETSUB, "@E 999,999,999.99" ) ) + " deve ser menor ou igual ao do valor INSS R$" + Alltrim( Transform( nCALCINSS, "@E 999,999,999.99" ) ) + " !", { "Ok" } )
	EndIf

	If lCalcinss
		nE2_VALOR := Round( (cal_BASEINS) - nE2_VLADIC - nE2_INSS - nE2_IRRF - if(!lMRETISS ,0,if(cRecIss = "1",0,nE2_ISS)), 2 )
	EndIf

	If comf5 = "com"
		oXVLINSS:refresh()
		oXVLTOTAL:refresh()
	EndIf

Return lCalcinss

**********************
User Function Vldcno()
**********************

	Local lOk := .T.

	If cValToChar( cE2_XIOBRA ) = "1" .or. cValToChar( cE2_XIOBRA ) = "2"
		If Len( alltrim( cE2_XCNO ) ) = 0
			lOk := .F.
			Aviso( "Informa��o", "O Nr do CNO est� em branco", { "Ok" } )
		EndIf
	EndIf

Return lOk

**********************
User Function vldtp1()
**********************

	Local lOk := .T.

	If ( cValToChar( cE2_XICPRB ) != "3" ) .AND. cValToChar( cE2_XICPRB ) != "2" .And. lContinua
		If Len( Alltrim( cValToChar( cE2_XTPSERV ) ) ) = 0
			lOk := .F.
			Aviso( "Informa��o", "Selecionar um Tipo de Servico", { "Ok" } )
		EndIf
	EndIf

Return lOk

******************************
User Function Calcin5( comf5 )
******************************

	Local lOk := .T.

	If nE2_BASEINS < 0
		lOk := .F.
		Aviso( "Informa��o", "Base Inss com Valor Negativo", { "Ok" } )
		Return lOk
	EndIf

	If nE2_BASEINS > cal_BASEINS
		lOk := .F.
		Aviso( "Informa��o", "Base Inss R$ " + Alltrim( Transform( nE2_BASEINS, "@E 999,999,999.99" ) ) + " Maior que o Total da Nota R$" + Alltrim( Transform( cal_BASEINS, "@E 999,999,999.99" ) ) + " !", { "Ok" } )
		Return lOk
	EndIf

	if lOk
		lnTaxa := 0		

		If ( cValToChar(cE2_XICPRB) = "0" )
			lnTaxa := 11
		ElseIf ( cValToChar(cE2_XICPRB) = "1" )
			lnTaxa := 3.5
		ElseIf ( cValToChar(cE2_XICPRB) = "2" )
			lnTaxa := 5
		EndIf

		nCALCINSS := Round( ( ( nE2_BASEINS * lnTaxa ) / 100 ), 2 )

		If Round( nCALCINSS, 2 ) >= Round( nE2_RETSUB, 2 )
			nE2_INSS := Round( nCALCINSS - nE2_RETSUB, 2 )
		Else
			NE2_INSS := 0
		EndIf

		nE2_VALOR := Round( (cal_BASEINS) - nE2_VLADIC - nE2_INSS - nE2_IRRF - if(!lMRETISS ,0,if(cRecIss = "1",0,nE2_ISS)), 2 )
			
	EndIf

	If comf5 = "com"
		oXVLINSS:refresh()
		oXVLTOTAL:refresh()
	EndIf

Return lOk

***********************************
User Function DlgReinf( lContinua )
***********************************

	#Define STR_PULA Chr(13)+Chr(10)

	Local cTitulo := "Informa��es do REINF"
	Local lXmlImp := .T.
	Local ind     := 0, _oFont, _lExist := .T.

	Private cNomeFor    := Alltrim( Posicione( "SA2", 1, xFilial( "SA2" ) + MAFISRET( , "NF_CODCLIFOR" ) + MAFISRET( , "NF_LOJA" ), "A2_NOME" ) )
	Private aE2_XICPRB  := {}
	Private aE2_XIOBRA  := {}
	Private aRet1       := TamSX3( "E2_CNO" )
	Private aE2_XTPSERV := U_LoadSX5( "E2_TPESOC" )
	Private lMRETISS    := .F.
	Private oTpServ
	Private oXICPRB
	Private oXVLADIC
	Private oVLTOTAL
	Private oXVLINSS
	Private oRETSUB
	Private oSERV15
	Private oSERV20
	Private oSERV25
	Private oXCNO
	Private oE2_BASEINS
	Private oE2_INSS
	Private oE2_VALOR
	Private oE2_IRRF
	Private oE2_ISS
	Private oE2_COFINS
	Private oE2_PIS
	Private oE2_CSLL
	Private	_nAux

	Public aimpostos   := MAFISRET( , "NF_IMPOSTOS" )
	Public aimpostos2  := MAFISRET( , "NF_IMPOSTOS2" )
	Public cE2_NUM     := @CNFISCAL
	Public cE2_PREFIXO := @CSERIE
	Public cE2_FORNEC  := MAFISRET( , "NF_CODCLIFOR" )
	Public cE2_Loja    := MAFISRET( , "NF_LOJA" )
	Public cRecIss     := MAFISRET(,"NF_RECISS")
	Public cE2_XICPRB  := ""
	Public cE2_XCNO    := Space( aRet1[1] ), _cE2_DESCXCNO
	Public cE2_XTPSERV := "  "
	Public cE2_XIOBRA  := "0"
	Public cal_BASEINS := Round( MAFISRET( , "NF_TOTAL" ), 2 )
	Public nE2_INSS    := Round( MAFISRET( , "NF_VALINS" ), 2 )
	Public nE2_RETSUB  := 0.00
	Public nE2_SERV15  := 0.00
	Public nE2_SERV20  := 0.00
	Public nE2_SERV25  := 0.00
	Public nE2_VLADIC  := 0.00
	Public nE2_INSS15  := 0.00
	Public nE2_INSS20  := 0.00
	Public nE2_INSS25  := 0.00
	Public nE2_VALOR   := Round( MAFISRET( , "NF_TOTAL"  ), 2 )
	Public nE2_IRRF    := Round( MAFISRET( , "NF_VALIRR" ), 2 )
	Public nE2_ISS     := Round( MAFISRET( , "NF_VALISS" ), 2 )
	Public nE2_COFINS  := Round( MAFISRET( , "NF_VALCOF" ), 2 )
	Public nE2_PIS     := Round( MAFISRET( , "NF_VALPIS" ), 2 )
	Public nE2_CSLL    := Round( MAFISRET( , "NF_VALCSL" ), 2 )
	Public tbiss       := MAFISRET( , "NF_ISS"    )

	lMRETISS := u_RetIss()

	If lMRETISS
		//cRecIss = "1"
	EndIf

	//If cRecIss <> "1" yan
//	If (cRecIss = "1" .or. ( cRecIss = "1" .and. Len(aRecSE2) >= 1 ) )
//		nE2_VALOR := nE2_VALOR + nE2_ISS
//		nE2_ISS := 0
////	ElseIf cRecIss = "2"
////		nE2_VALOR := nE2_VALOR - nE2_ISS
//	EndIf

	aAdd( aE2_XIOBRA, "0=Nao e obra               " )
	aAdd( aE2_XIOBRA, "1=Obra - Empreitada Total  " )
	aAdd( aE2_XIOBRA, "2=Obra - Empreitada Parcial" )

	u_calcins( "sem" )

	_oFont  := TFont():New( 'Courier new',, -11, .T.,,,,,, .F., .F. )
	_oFont1 := TFont():New( 'Arial'      ,, -14, .T.,,,,,, .T., .T. )

	DEFINE MSDIALOG oDlg1 TITLE OemToAnsi( cTitulo ) From 000,000 to 530,600 of oMainWnd PIXEL Style DS_MODALFRAME

		oDlg1:lEscClose := .F.

		@ 012, 002 To 026, 300 Of oDlg1 Pixel
		@ 029, 002 To 220, 300 Of oDlg1 Pixel

		@ 015,015 Say "Nota Fiscal/Serie " + cE2_NUM + ' ' + Alltrim( cE2_PREFIXO ) + ' ' + "Fornecedor: " + Substr( cNomeFor, 1, 30 ) FONT _oFont1 Color CLR_BLACK of oDlg1 Pixel

		@ 032,015 Say "Calcula INSS  " FONT _oFont Color CLR_HBLUE of oDlg1 Pixel
		@ 030,075 Msget oXICPRB Var aE2_XICPRB When .F. Size 70, 10 Of oDlg1 Pixel // On Change u_calcin2( "com" )

		oXICPRB:bHelp := { || ShowHelpCpo( "cE2_XICPRB", { "Calcular o valor do INSS" }, 2, { " " }, 2 ) }

		@ 050,015 Say "Base INSS  " FONT _oFont Color CLR_HBLUE of oDlg1 Pixel
		@ 048,075 Msget oE2_BASEINS var nE2_BASEINS When .F. Size 070, 011 of oDlg1 Pixel Picture X3Picture( "E2_XVLSV25" ) VALID U_CALCIN5( "com" )

		oE2_BASEINS:bHelp := { || ShowHelpCpo( "E2_BASEINS", { GetHlpSoluc( "E2_BASEINS" )[1] }, 2, { GetHlpSoluc( "E2_BASEINS" )[2] }, 2 ) }

		@ 062,015 Say "Valor INSS  " FONT _oFont Color CLR_HBLUE of oDlg1 Pixel
		@ 060,075 Msget oXVLINSS VAR nE2_INSS When .F. Size 070, 011 of oDlg1 Pixel When .T. Picture X3Picture( "E2_INSS" ) VALID u_calcin3( "com" )

		oXVLINSS:bHelp := { || ShowHelpCpo( "E2_INSS", { GetHlpSoluc( "E2_INSS" )[1] }, 2, { GetHlpSoluc( "E2_INSS" )[2] }, 2 ) }

		@ 077,015 Say "Tipo Servico  " FONT _oFont Color CLR_HBLUE of oDlg1 Pixel
		@ 075,075 MSCOMBOBOX oTpServ VAR cE2_XTPSERV ITEMS aE2_XTPSERV When alltrim( cE2_XICPRB ) != "3" .AND. alltrim( cE2_XICPRB ) != "2" SIZE 130, 50 OF oDlg1 PIXEL VALID u_vldtp1()

		oTpServ:bHelp := { || ShowHelpCpo( "E2_TPESOC", { GetHlpSoluc( "E2_TPESOC" )[1] }, 2, { GetHlpSoluc( "E2_TPESOC" )[2] }, 2 ) }

		@ 092,015 Say "Ind.Obra    " FONT _oFont Color CLR_HBLUE of oDlg1 Pixel
		@ 090,075 ComboBox oXIOBRA Var cE2_XIOBRA Items aE2_XIOBRA Size 130, 50 OF oDlg1 PIXEL

		oXIOBRA:bHelp := { || ShowHelpCpo( "E2_XIOBRA", { "Indicativo de Presta��o de Servi�os em" + STR_PULA + "Obra de Constru��o Civil" }, 2, { " " }, 2 ) }

		@ 107,015 Say "Nr.CNO      " FONT _oFont Color CLR_HBLUE of oDlg1 Pixel
		@ 105,075 Msget oXCNO Var cE2_XCNO Valid( If( ! Empty( cE2_XCNO ), ( _cE2_DESCXCNO := SON->ON_CNO, _lExist := ExistCpo( 'SON', cE2_XCNO, 1 ) ), .T. ), If( _lExist, If( Alltrim( cE2_XIOBRA ) <> "0" .And. Empty( cE2_XCNO ), ( Aviso( "Aten��o", "Se o tipo de servi�o for obra, o campo (Nr.CNO) deve ser informado.", { "Sair" } ), .F. ), ( _cE2_DESCXCNO := SON->ON_CNO, .T. ) ), ( If( ! _lExist .And. Alltrim( cE2_XIOBRA ) = "0" .And. Empty( cE2_XCNO ), .T., .F. ) ) ) ) Size 070,011  of oDlg1 Pixel When alltrim( cE2_XIOBRA ) != "0" F3 "SON"

		oXCNO:bHelp := { || ShowHelpCpo( "E2_CNO", { GetHlpSoluc( "E2_CNO" )[1] }, 2, { GetHlpSoluc( "E2_CNO" )[2] }, 2 ) }

		@ 122,015 Say "Vl.Ret.S.Sub" FONT _oFont Color CLR_HBLUE of oDlg1 Pixel
		@ 120,075 Msget oRETSUB VAR nE2_RETSUB Size 070, 011 of oDlg1 Pixel When .T. Picture X3Picture( "E2_XVLRETS" ) VALID u_calcin4( "com" )

		oRETSUB:bHelp := { || ShowHelpCpo( "E2_XVLRETS", { GetHlpSoluc( "E2_XVLRETS" )[1] }, 2, { GetHlpSoluc( "E2_XVLRETS" )[2] }, 2 ) }

		@ 137,015 Say "Bas.Serv.E15" FONT _oFont Color CLR_HBLUE of oDlg1 Pixel
		@ 135,075 Msget oSERV15 VAR nE2_SERV15 Size 070,011  of oDlg1 Pixel When .T. Picture X3Picture("E2_XVLSV15") VALID u_calcd15()

		oSERV15:bHelp := { || ShowHelpCpo( "E2_XVLSV15", { GetHlpSoluc( "E2_XVLSV15" )[1] }, 2, { GetHlpSoluc( "E2_XVLSV15" )[2] }, 2 ) }

		@ 152,015 Say "Bas.Serv.E20" FONT _oFont Color CLR_HBLUE of oDlg1 Pixel
		@ 150,075 Msget oSERV20 VAR nE2_SERV20 Size 070, 011 of oDlg1 Pixel When .T. Picture X3Picture( "E2_XVLSV20" ) VALID u_calcd20()

		oSERV20:bHelp := { || ShowHelpCpo( "E2_XVLSV20", { GetHlpSoluc( "E2_XVLSV20" )[1] }, 2, { GetHlpSoluc( "E2_XVLSV20" )[2] }, 2 ) }

		@ 167,015 Say "Bas.Serv.E25" FONT _oFont Color CLR_HBLUE of oDlg1 Pixel
		@ 165,075 Msget oSERV25 VAR nE2_SERV25 Size 070, 011 of oDlg1 Pixel When .T. Picture X3Picture( "E2_XVLSV25" ) VALID u_calcd25()

		oSERV25:bHelp := { || ShowHelpCpo( "E2_XVLSV25", { GetHlpSoluc( "E2_XVLSV25" )[1] }, 2, { GetHlpSoluc( "E2_XVLSV25" )[2] }, 2 ) }

		@ 182,015 Say "Vlr.Adic   " FONT _oFont Color CLR_HBLUE of oDlg1 Pixel
		@ 180,075 Msget oXVLADIC VAR nE2_VLADIC When .F. Size 070, 011 of oDlg1 Pixel When .T. Picture X3Picture( "E2_XVLSV25" )

		oXVLADIC:bHelp := { || ShowHelpCpo( "E2_XVLADIC", { GetHlpSoluc( "E2_XVLADIC" )[1] }, 2, { GetHlpSoluc( "E2_XVLADIC" )[2] }, 2 ) }
		
		
//		_nAux			:= nE2_VALOR
//		if(!lMRETISS)
//			nE2_VALOR	:= nE2_VALOR + nE2_ISS
//		endif
		
		nE2_VALOR := Round( (cal_BASEINS) - nE2_VLADIC - nE2_INSS - nE2_IRRF - if(!lMRETISS ,0,if(cRecIss = "1",0,nE2_ISS)), 2 )
		
		@ 197,015 Say "Total Titulo " FONT _oFont Color CLR_HBLUE of oDlg1 Pixel
		@ 195,075 Msget oXVLTOTAL VAR nE2_VALOR Size 070, 011 of oDlg1 Pixel When .F. Picture X3Picture( "E2_XVLSV25" )
		
//		nE2_VALOR		:= _nAux
		
		oXVLTOTAL:bHelp := { || ShowHelpCpo( "E2_VALOR", { GetHlpSoluc( "E2_VALOR" )[1] }, 2, { GetHlpSoluc( "E2_VALOR" )[2] },2 ) }

		@ 235,002 BUTTON "&Confirmar" of oDlg1 pixel SIZE 148, 20 ACTION ( lContinua := FTUDOOK(), If( lContinua, oDlg1:End(), ) )
		@ 235,151 BUTTON "&Cancelar"  of oDlg1 pixel SIZE 148, 20 ACTION ( lContinua := .F.      , oDlg1:End()                   )

		oXVLTOTAL:refresh()
		oTpServ:SetFocus()

	ACTIVATE MSDIALOG oDlg1 CENTERED

Return lContinua

************************
Static Function FTUDOOK
************************

	Local _lRetOk := .T.

	If ( cValToChar( cE2_XICPRB ) != "3" ) .AND. cValToChar( cE2_XICPRB ) != "2"
		If Len( Alltrim( cValToChar( cE2_XTPSERV ) ) ) = 0
			_lRetOk := .F.
			Aviso( "Informa��o", "Selecionar um Tipo de Servico", { "Ok" } )
		EndIf
	EndIf

	If Alltrim( cE2_XIOBRA ) <> "0" .And. Empty( cE2_XCNO )
		Aviso( "Aten��o", "Se o tipo de servi�o for obra, este campo (Nr.CNO) deve ser informado.", { "Sair" } )
		_lRetOk := .F.
	EndIf

Return _lRetOk

**********************
User Function RetIss()
**********************

	Local lRet := .F.

	DBSELECTAREA( "SX6" )

	lRet := ( GETMV( "MV_MRETISS" ) = "1")

Return lRet