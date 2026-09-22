#include "Protheus.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} RED1M001
Ponto de entrada que corrige a numeração do campo de número do atestado
médico (TNY_NATEST) em casos em que foram geradas numerações iguais para
fichas médicas diferentes.

@type    function
@author  Julia Kondlatsch
@since   21/01/2019
@sample  MDTLOAD1()

@return  Nil, Sempre Nulo
/*/
//-------------------------------------------------------------------
User Function RED1M001( cFilExec )

	Default cFilExec := cFilAnt

	Processa({ |lEnd| U_UpdateTab( cFilExec ) },'Aguarde... Corrigindo a numeração dos Atestados Médicos (TNY) e tabelas ralacionadas' )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} function
Executa o update da Tabela TNY e outras tabelas relacionadas.

@type    function
@author  Julia Kondlatsch
@since   21/01/2019
@sample  UpdateTNY()
@param   param, param_type, param_descr

@return  lRet, Lógico, Verdadeiro se a atualização foi processada
normalmente
/*/
//-------------------------------------------------------------------
User Function UpdateTab( cFilExec )

	Local nCID
	Local lRet    := .T.
	Local cQryTNY := GetNextAlias()
	Local cAlsRF0 := GetNextAlias()
	Local lR8Ates := SR8->(FieldPos("R8_NATEST")) > 0
	Local nIndSR8 := f685RetOrder("SR8","R8_FILIAL+R8_NATEST")
	Local aTKI    := {}
	Local cNAtest := ''
	Local aAreaTNY := {}
	Local cFilTNY := xFilial( "TNY" , cFilExec )
	Local cFilOld := cFilAnt

	//Ajusta Filial Atual
	If cFilAnt <> cFilExec
		cFilAnt := cFilExec
	EndIf

	BeginSQL Alias cQryTNY

			SELECT TNY2.R_E_C_N_O_ RECREG, TNY2.TNY_FILIAL, TNY2.TNY_NUMFIC, TNY2.TNY_NATEST FROM %table:TNY% TNY2
			WHERE TNY2.%notDel% AND TNY2.TNY_FILIAL = %exp:cFilTNY% AND
				TNY2.TNY_NATEST IN (
					SELECT TNY.TNY_NATEST FROM %table:TNY% TNY
						WHERE TNY.%notDel% AND TNY.TNY_FILIAL = %exp:cFilTNY%
						GROUP BY TNY.TNY_NATEST
						HAVING COUNT(TNY.TNY_NATEST) > 1
				) ORDER BY
				TNY2.TNY_FILIAL, TNY2.TNY_NATEST, TNY2.TNY_NUMFIC

	EndSQL

	dbSelectArea( cQryTNY )
	While ( cQryTNY )->( !EoF() )

		dbSelectArea( 'TNY' )
		dbGoTo( ( cQryTNY )->RECREG )
		If cNAtest <> TNY->TNY_NATEST

			cNAtest := TNY->TNY_NATEST
			aTKI := {}

			dbSelectArea( "TKI" )
			dbSetOrder( 1 )
			dbSeek( xFilial( "TKI" , ( cQryTNY )->TNY_FILIAL ) + TNY->TNY_NATEST )
			While TKI->( !EoF() ) .And. TKI->TKI_FILIAL == xFilial( "TKI" , ( cQryTNY )->TNY_FILIAL ) .And. ;
					TKI->TKI_NATEST == TNY->TNY_NATEST

				aAdd( aTKI , { TKI->TKI_GRPCID, TKI->TKI_CID })

				TKI->( dbSkip() )
			End

		Else

			cNewAtest := GETSXENum( 'TNY' , 'TNY_NATEST' , , 2 )

			// Ajusta TNY - Atestados Médicos
			Reclock('TNY',.F.)
				TNY->TNY_NATEST := cNewAtest
			TNY->(MsUnlock())

			// Ajusta TNY - continuações de atestado
			aAreaTNY := GetArea()
			dbSelectArea( 'TNY' )
			dbSetOrder( 6 )//TNY_FILIAL + TNY_ATEANT
			dbSeek( xFilial('TNY', ( cQryTNY )->TNY_FILIAL ) + ( cQryTNY )->TNY_NATEST )
			While TNY->( !EoF() ) .And. TNY->TNY_FILIAL == xFilial('TNY', ( cQryTNY )->TNY_FILIAL ) .And. ;
				TNY->TNY_ATEANT == ( cQryTNY )->TNY_NATEST

				If TNY->TNY_NUMFIC == ( cQryTNY )->TNY_NUMFIC
					RecLock('TNY',.F.)
						TNY->TNY_ATEANT := cNewAtest
					TNY->( MsUnLock() )
				EndIf

				TNY->( dbSkip() )

			EndDo
			RestArea(aAreaTNY)

			// Ajusta TKI - CID complementar para Atestado
			For nCID := 1 To Len( aTKI )
				dbSelectArea( "TKI" )
				dbSetOrder( 1 )
				If !dbSeek( xFilial( "TKI" , ( cQryTNY )->TNY_FILIAL ) + cNewAtest + aTKI[ nCID, 1 ] + aTKI[ nCID, 2 ] )
					RecLock( "TKI" , .T. )
					TKI->TKI_FILIAL := xFilial( "TKI" , ( cQryTNY )->TNY_FILIAL )
					TKI->TKI_NATEST := cNewAtest
					TKI->TKI_GRPCID := aTKI[ nCID, 1 ]
					TKI->TKI_CID    := aTKI[ nCID, 2 ]
					TKI->( MsUnLock() )
				EndIf
			Next nCID

			ConfirmSX8()

		EndIf

		( cQryTNY )->( dbSkip() )

	End

	// Retorna a Filial de Origem
	If cFilOld <> cFilAnt
		cFilAnt := cFilOld
	EndIf

Return lRet
