#INCLUDE 'PROTHEUS.CH'
/*/{Protheus.doc} MT120FIM

 	Ponto de entrada no final do processamento do Pedido de Compra.

	@Author  Paulo Krüger
	@Since   26/10/2016
	@Version P12.1.27
	@type  Function Static
	@Obs MAN00000463801_EF_001
		 MAN00000463801_EF_022 
/*/
user function mt120fim()
	local aArea    := getarea()
	local nOper    := paramixb[1]
	local cPedComp := paramixb[2]
	local nOpca    := paramixb[3]
	local cFil     := SC7->C7_FILIAL
	Local nRecno   := SC7->(RECNO())
	local cTipo    := "PC"
	local cNum     := cPedComp

//Tratativa temporária para alterar o CONAPRO (devido ao erro na rotina padrão.)
	DbSelectArea("SCR")
	SCR->(DbSetOrder(1))
	If SCR->(DbSeek(cFil + cTipo + cNum))
		While SCR->(!(EoF())) .And. SCR->CR_FILIAL == cFil .And. SCR->CR_TIPO == cTipo .And. AllTrim(SCR->CR_NUM) == cNum
			If SCR->CR_STATUS $ "01|02"
				SC7->(DbSetOrder(1))
				SC7->(MsSeek(cFil + AllTrim(cPedComp)))
				While SC7->(!Eof() .and. C7_FILIAL + C7_NUM== cFil + AllTrim(cPedComp))
					If SC7->C7_CONAPRO <> 'B'
						RecLock("SC7",.F.)
						SC7->C7_CONAPRO := "B"
						SC7->(MsUnlock())
					Endif
					SC7->(DbSkip())
				End
				Exit
			EndIf
			SCR->(DbSkip())
		End
	EndIf

	SC7->(DbGoto(nRecno))

//--[ Só processa a integração SE não for proveniente do schedule - F1200601/F1200600 ]
	if !isincallstack( 'u_f1200601' ) .AND. ;
			!isincallstack( 'U_F1200600' )

		if nOper == 4 .AND. nOpca == 1
			u_f0702207( cPedComp )
		endif

		if nOper == 3 .AND. nOpca == 1
			u_f07022cz( xfilial( 'SC7' ) , cPedComp , nOper ) // Alimenta campo C7_DATPRF (Previsão de entrega)
		endif

// ------------------------------------------------------------------
//      [ Exclui documentos anexos quando excluido o Pedido de Compra. ]
// ------------------------------------------------------------------
		if nOper == 5 .AND. nOpca == 1
			u_f0400105( 'MATA121' , xfilial( 'SC7' ) , cPedComp )
		endif

		if isincallstack( 'A120Copia' )  .AND. nOpca == 1
			u_f07022cy( cPedComp ) // limpa os campos de integração
		endif

// ------------------------------------------------------------------
//      if ( isincallstack( 'MATA131'    ) .OR. !isblind() ) .AND. ;
//          !isincallstack( 'U_F1303701' )
// ------------------------------------------------------------------

		if ( isincallstack( 'MATA131'    ) .OR. ;
				isincallstack( 'U_F1200600' )      )
// ------------------------------------------------------------------
//          .AND. !isincallstack( 'U_W1303701' ) .AND. !isincallstack( 'U_W0702601' )
// ------------------------------------------------------------------
			//u_f1600702( xfilial( 'CNE' ) , cPedComp )
			u_f1600701( xfilial( 'CNE' ) , cPedComp )
		endif

		//-----[ integração com fronts ws client para inclusão e para alteração ]
		u_f0702203( cPedComp , nOper , nOpca )

// ------------------------------------------------------------------
//      if nOper == 3 .AND. nOpca == 1
// ------------------------------------------------------------------
		if ( nOper == 3 .OR. nOper == 4 ) .AND. nOpca == 1
			u_f1201002( xfilial( 'SC7' ) , cPedComp )
		endif

		if nOper == 3 .AND. SC7->C7_XSOLPAG == '1'
			u_EnvMailPC( xfilial( 'SC7' ) , cPedComp )
		endif

//------[Projeto data programada ]---------------------------------
		if nOpca == 1
			u_DTPrograma( xfilial( 'SC7' ) , cPedComp ) // Alimenta campo C7_DATPRF com a data digitada na SC
		endif

		restarea( aArea )

	endif

return

// ------------------------------------------------------------------
// {Protheus.doc} GCTINTEGR()
// Executado quando vier do GCT.
// @Author  Thiago Oliveira
// @Since   03/05/2019
// @Version P12.7
// @Return  lógico
// ------------------------------------------------------------------    
user function GCTIntegr( nOper , cPedComp , nOpca , nRecSC7 )

// ------------------------------------------------------------------
	local   aArea    := SC7->( getarea( 'SC7' ))
	local   lOk      := .F.
// ------------------------------------------------------------------
	default nOper    := 3 // Inclui
	default cPedComp := ''
	default nOpca    := 1
	default nRecSC7  := 0
// ------------------------------------------------------------------

	if !empty( cPedComp ) .AND. nRecSC7 > 0

//------[ Alimenta campo C7_DATPRF (Previsão de entrega) ]-----------
		u_f07022cz( xfilial( 'SC7' ) , cPedComp , nOper )

//------[ Calcula o Desconto Por item e o valor total do pedido ]----
		//u_f1600702( xfilial( 'CNE' ) , cPedComp )
		u_f1600701( xfilial( 'CNE' ) , cPedComp )

//------[ Integração com fronts WS client para inclusão e para alteração ]
		u_f0702203( cPedComp , nOper , nOpca , nRecSC7 )

//------[Altera nome do fornecedor ]---------------------------------
		u_f1201002( xfilial( 'SC7' ) , cPedComp )

//------[Projeto data programada ]---------------------------------
		u_DTPrograma( xfilial( 'SC7' ), cPedComp ) // Alimenta campo C7_DATPRF com a data digitada na SC

		lOk := .T.

	endif

	restarea( aArea )

return

// ------------------------------------------------------------------
// [ fim de pe_mt120fim.prw ]
// ------------------------------------------------------------------
