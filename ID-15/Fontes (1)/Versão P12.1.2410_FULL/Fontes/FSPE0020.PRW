/*/
==================================================================================
Dt Ajustes : 16/01/2019
----------------------------------------------------------------------------------
Autor      : ...............
Ajustes    : Daniel Machado
----------------------------------------------------------------------------------
Descricao  : Trata os impostos gerados 
----------------------------------------------------------------------------------
Partida    : Ponto de Entrada - MT100AGR e FSPE0020
==================================================================================
/*/

User Function Fspe0020()

	Local lOk    := .F.
	Local lOkTes := .F.
	Local lOkIte := .F.

	Private lOkRet := .T.

	Public lContinua   := .F.
	Public nE2_BASEINS := If( MAFISRET( , "NF_BASEINS" ) > 0, MAFISRET( , "NF_BASEINS" ), 0 )
	Public nE2_INSS    := If( MAFISRET( , "NF_VALINS"  ) > 0, Round( MAFISRET( , "NF_VALINS" ), 2 ), 0 )
	Public nE2_VALOR   := MAFISRET( , "NF_TOTAL" )
	Public nE2_RETSUB  := 0
	Public nE2_VLADIC  := 0
	Public nE2_SERV15  := 0
	Public nE2_SERV20  := 0
	Public nE2_SERV25  := 0
	Public cE2_XIOBRA  := ""
	Public cE2_XTPSERV := ""
	Public _lDlgPasR   := .F.

	If IsBlind()
		lOk := .T.
	EndIf

	If ! l103Class .AND. ! Inclui
		Return lOkRet
	EndIf

	If ! lOk
		lOk       := Valid_Tes( lOkRet )
		lContinua := lOk
	EndIf

	If ! lOk .And. lContinua
		lOk       := Valid_Item( lOkRet )
		lContinua := lOk
	EndIf

Return lContinua

*********************************
Static Procedure Valid_Tes( lOk )
*********************************

	Local aReaTes := GetArea()
	Local n       := len( aCols )
	Local nPosTes := aScan( aHeader, { |x| AllTrim( Upper( X[2] ) ) == "D1_TES" } )
	Local cIss    := ""

	If ! Empty( aCols[n][nPosTes] )
		cTes := aCols[n][nPosTes]

		dbselectarea( "SF4" )                  
		SF4->( dbSetOrder( 1 ) )

		If SF4->( MsSeek( xFilial( "SF4" ) + cTes ) )
			If SF4->F4_ISS = "S"
				If nE2_BASEINS > 0
					_lDlgPasR := .T.
					lOk := U_DlgReinf( lContinua )
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea( aReaTes )

Return lOk

*********************************
Static Procedure Valid_Item( lOk )
*********************************

	Local aReaItem := GetArea()
	Local n        := len( aCols )
	Local nPosIte  := aScan( aHeader, { |x| AllTrim( Upper( X[2] ) ) == "D1_COD" } )

	If ! Empty( aCols[n][nPosIte] )
		cIte := aCols[n][nPosIte]

		dbselectarea( "SB1" )
		SB1->( dbSetOrder( 1 ) )

		If SB1->( MsSeek( xFilial( "SB1" ) + cIte ) )
			If SB1->B1_XESTOQ = "S" .And. nE2_BASEINS > 0
				_lDlgPasR := .T.
				lOk := U_DlgReinf( lContinua )
			EndIf
		EndIf
	EndIf

	RestArea( aReaItem )

Return lOk