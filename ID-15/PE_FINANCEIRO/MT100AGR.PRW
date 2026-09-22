/* ========================================================== *
 * Rotina: MT100AGRa | Autor: Andre Oliveira| Data: 29/08/2013*
 * ---------------------------------------------------------- *
 * Desc. : Ponto de entrada para preencher a CD5, Complemento *
 *         de Importação                                      *
 *                                                            *
 * Ajustes referentes ao REINF mencionado na documentação     *
 * MIT031 ID1462 INTERNO 876 - DATA 16/01/2019.               *
 * Daniel Machado                                             *
 * ========================================================== */
//***************************************| 
//Alterado por André Oliveira 17/09/2013 |
//***************************************|

#INCLUDE "RWMAKE.CH"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#include "topconn.ch"

User Function MT100AGR()

	Local lRet      := .T.
	Local nQTDPARC  := 0
	Local Cquery    := ""
	Local SE2T      := GetNextAlias()
	Local lMRETISS  := .F.
	Local _lPadrao  := VerPadrao( "650" )
	Local _cArquivo := " "
	Local _nTotal   := 0, _nVlrLinq := 0, _nNumParc := 0
	Local _nHdlPrv  := ""
	Local _cQry, _nRecNoE2, _cParcIns := '', _nRecNoIns := 0, _cFornecPrin, _aArea := GetArea(), _lGeraIns := .T.

	Public vcE2_BASEINS := 0
	Public vcE2_INSS    := 0
	Public vcE2_RETSUB  := 0                       
	Public vcE2_VLADIC  := 0
	Public vcE2_SERV15  := 0
	Public vcE2_SERV20  := 0
	Public vcE2_SERV25  := 0       
	Public vcE2_XCNO    := ""

	Private aAreaSF1    := SF1->( GetArea() )
	Private cDocNFE     := " "
	Private cSerNFE     := " "
	Private cForNFE     := " "
	Private cLojNFE     := " "
	Private cEmiNFE     := " "
	Private cNomeFo     := " "
	Private ce2_Prefixo := " "
	Private ce2_Num     := " "
	Private ce2_parcela := " "
	Private ce2_tipo    := " "
	Private ce2_fornece := " "
	Private ce2_loja    := " "
	Private nAuxCalc    := 0, _nParcE2 := 0, _nDeferen := 0, _nAux

	
	
	_nRecNoE2 := SE2->( RecNo() )

	If IsInCallStack( "MATA103" )
		If Type( 'l103Auto' ) == 'U' .Or. ! IsBlind()
			l103Auto := .F.
	    Else
	    	l103Auto := .T.
	    EndIf
	Else
		l103Auto := .F.
	EndIf

	&& Inicio da tratativa para Reinf. Por favor, realize qualquer tratamento antes desta linha. 17/01/19

	If ! l103Auto .AND. ( Inclui .or. Altera .or. l103Class ) .And. If( Type( '_lDlgPasR' ) <> 'U', _lDlgPasR, .F. )

		_cQry := " SELECT R_E_C_N_O_  E2RECNO FROM " + RETSQLNAME( "SE2" ) + " (NOLOCK) WHERE "
		_cQry += " D_E_L_E_T_ = ' ' AND E2_FILIAL = '" + xFilial( "SE2" ) + "' AND E2_NUM = '" + SE2->E2_NUM + "' AND "
		_cQry += " E2_FORNECE = '" + SE2->E2_FORNECE + "' AND E2_LOJA = '" + SE2->E2_LOJA + "' AND E2_PREFIXO = '" + SE2->E2_PREFIXO + "' "
		_cQry += " ORDER BY E2_NUM, E2_PARCELA "

		_cQry := ChangeQuery( _cQry )

		If Select( "TSE2P" ) > 0; TSE2P->( DbCloseArea() ); EndIf
		DbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQry ), "TSE2P", .T., .F. )

		TSE2P->( DbGoTop() )

		_nNumParc := Contar( 'TSE2P', '!Eof()' )

		TSE2P->( DbGoTop() )

		nE2_INSS     := Round( nE2_INSS, 2 )
		vcE2_BASEINS := Round( nE2_BASEINS, 2 )
		vcE2_INSS    := nE2_INSS
		vcE2_RETSUB  := nE2_RETSUB
		vcE2_VLADIC  := Round( nE2_VLADIC, 2 )
		vcE2_SERV15  := Round( nE2_SERV15, 2 )
		vcE2_SERV20  := Round( nE2_SERV20, 2 )
		vcE2_SERV25  := Round( nE2_SERV25, 2 )
		vcE2_XCNO    := cE2_XCNO
		cDocNFE      := @CNFISCAL
		cSerNFE      := @CSERIE
		cForNFE      := MAFISRET( , "NF_CODCLIFOR" )
		cLojNFE      := MAFISRET( , "NF_LOJA" )
		cEmiNFE      := DDEMISSAO
		cNomeFo      := Alltrim( Posicione( "SA2", 1, xFilial( "SA2" ) + cForNFE + cLojNFE, "A2_NOME" ) )
		ce2_Prefixo  := @CSERIE
		ce2_Num      := @CNFISCAL
		ce2_parcela  := ' '
		ce2_tipo     := MVNOTAFIS
		ce2_fornece  := MAFISRET( , "NF_CODCLIFOR" )
		ce2_loja     := MAFISRET( , "NF_LOJA" )

		Do While TSE2P->( ! Eof() )

			_nParcE2++

			SE2->( DbGoTo( TSE2P->E2RECNO ) )

			lMRETISS := U_RetIss()

			nAuxCalc := Round( If( _nNumParc >= 1,if(cRecIss = "1",nE2_VALOR + SE2->E2_ISS, nE2_VALOR), If( _nParcE2 > 0 .AND. _nParcE2 = 1, FVALPARC( _nParcE2 ), if(cRecIss = "1",SE2->E2_VALOR + SE2->E2_ISS, SE2->E2_VALOR)) ), 2 )
			
			_nAux := Round( (cal_BASEINS/_nNumParc) - nE2_VLADIC - nE2_INSS - nE2_IRRF - if(!lMRETISS ,0,if(cRecIss = "1",0,nE2_ISS)), 2 )
			
			//_nAux := (SE2->E2_VALOR/ /* numero de parcelas */) + (nAuxCalc-SE2->E2_VALOR)
//			If cRecIss <> "1" .And. SE2->E2_ISS > 0 .And. _nParcE2 > 0 .AND. _nParcE2 = 1
//				nAuxCalc := nAuxCalc - SE2->E2_ISS
//			EndIf

//			if (cRecIss = "1" )
//				nAuxCalc := nAuxCalc + SE2->E2_ISS
//			endif

			RecLock( "SE2", .F. )
				If _nParcE2 = 1
					SE2->E2_VALOR   := _nAux
					SE2->E2_SALDO   := _nAux
					SE2->E2_VLCRUZ  := _nAux
					SE2->E2_XVLLIQ  := nAuxCalc - ( SE2->( E2_PIS + E2_COFINS + E2_CSLL ) + If( SE2->E2_TRETISS = '2', SE2->E2_ISS, 0 ) + SE2->E2_DECRESC ) + SE2->( E2_MULTA + E2_JUROS + E2_ACRESC)
				//	SE2->E2_XVLLIQ  := SE2->E2_VALOR - ( SE2->( E2_PIS + E2_COFINS + E2_CSLL ) + If( SE2->E2_TRETISS = '2', SE2->E2_ISS, 0 ) + SE2->E2_DECRESC ) + SE2->( E2_MULTA + E2_JUROS + E2_ACRESC)
					SE2->E2_XVLRETS := vcE2_RETSUB
					SE2->E2_XVLSV15 := vcE2_SERV15
					SE2->E2_XVLSV20 := vcE2_SERV20
					SE2->E2_XVLSV25 := vcE2_SERV25
					SE2->E2_XVLADIC := vcE2_VLADIC
					If Round( nE2_INSS, 2 ) = 0
						SE2->E2_INSS := nE2_VLADIC
					Else
						SE2->E2_INSS := vcE2_INSS
					EndIf
					SE2->E2_BASEINS := vcE2_BASEINS
					SE2->E2_CNO     := vcE2_XCNO
					SE2->E2_XCNO    := _cE2_DESCXCNO
					SE2->E2_XIOBRA  := Alltrim( cE2_XIOBRA )
					SE2->E2_XTPSERV := cE2_XTPSERV
					SE2->E2_XICPRB  := If( Type( 'cE2_XICPRB' ) = 'N', Alltrim( Str( cE2_XICPRB ) ), cE2_XICPRB )
					SE2->E2_XVLADIC := nE2_VLADIC
				Else
					SE2->E2_XVLLIQ  := SE2->E2_VALOR - SE2->( E2_PIS + E2_COFINS + E2_CSLL ) + SE2->( E2_MULTA + E2_JUROS + E2_ACRESC - E2_DECRESC )
				EndIf

			SE2->( MsUnLock() )

			TSE2P->( DbSkip() )
		EndDo

		TSE2P->( DbGoTop() )

		If Type( 'nE2_BASEINS' ) = 'N'
			If nE2_BASEINS > 0
				SE2->( DbGoTo( TSE2P->E2RECNO ) )

				_cQry := " SELECT E2_VENCTO, E2_VENCREA, R_E_C_N_O_ INSRECNO FROM " + RETSQLNAME( "SE2" ) + " (NOLOCK) WHERE "
				_cQry += " D_E_L_E_T_ = ' ' AND E2_FORNECE = 'INPS' AND E2_FILIAL = '" + xFilial( 'SE2' ) + "' AND "
				_cQry += " E2_NUM = '" + SE2->E2_NUM + "' AND E2_PARCELA = '" + SE2->E2_PARCINS + "' AND E2_PREFIXO = '" + SE2->E2_PREFIXO + "' "

				_cQry := ChangeQuery( _cQry )

				If Select( 'TINS' ) > 0; TINS->( DbCloseArea() ); EndIf
				DbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQry ), "TINS", .T., .F. )

				TINS->( DbGoTop() )

				If TINS->( ! Eof() )
					SE2->( DbGoTo( TINS->INSRECNO ) )
					RecLock( 'SE2', .F. )
						SE2->E2_VALOR   := nE2_INSS
						SE2->E2_SALDO   := nE2_INSS
						SE2->E2_VLCRUZ  := nE2_INSS
					SE2->( MsUnLock() )
				EndIf

				If nE2_VLADIC > 0
					SE2->( DbGoTo( TSE2P->E2RECNO ) )

					_cE2_PREFIXO := SE2->E2_PREFIXO
					_cE2_NUM     := SE2->E2_NUM
					_dE2_EMISSAO := SE2->E2_EMISSAO
					_dE2_EMIS1   := SE2->E2_EMIS1
					_cE2_TITPAI  := SE2->( E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA )
					_nE2_RETINS  := SE2->E2_RETINS
					_cE2_CNPJRET := SE2->E2_CNPJRET
					_cFornecPrin := SE2->( E2_FORNECE + E2_LOJA )

					_cQry := " SELECT MAX( E2_MSIDENT ) E2_MSIDENT FROM " + RETSQLNAME( 'SE2' ) + " (NOLOCK) WHERE "
					_cQry += " D_E_L_E_T_ = ' ' AND E2_MSIDENT <> ' ' "

					_cQry := ChangeQuery( _cQry )

					If Select( "TIDENT" ) > 0; TIDENT->( DbCloseArea() ); EndIf
					DbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQry ), "TIDENT", .T., .F. )

					TIDENT->( DbGoTop() )

					_cE2_MSIDENT := Soma1( TIDENT->E2_MSIDENT,, .T. )

					_cQry := " SELECT E2_VENCTO, E2_VENCREA, R_E_C_N_O_ INSRECNO FROM " + RETSQLNAME( "SE2" ) + " (NOLOCK) WHERE "
					_cQry += " D_E_L_E_T_ = ' ' AND E2_FORNECE = 'INPS' AND E2_FILIAL = '" + xFilial( 'SE2' ) + "' AND "
					_cQry += " E2_NUM = '" + SE2->E2_NUM + "' AND E2_PARCELA = '" + SE2->E2_PARCINS + "' AND E2_PREFIXO = '" + SE2->E2_PREFIXO + "' "

					_cQry := ChangeQuery( _cQry )

					If Select( 'TINS' ) > 0; TINS->( DbCloseArea() ); EndIf
					DbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQry ), "TINS", .T., .F. )

					TINS->( DbGoTop() )

					If TINS->( ! Eof() )
						_dE2_VENCTO  := TINS->E2_VENCTO
						_dE2_VENCREA := TINS->E2_VENCREA
						_nRecNoIns   := TINS->INSRECNO
					Else
						_dE2_VENCTO  := SE2->E2_VENCTO
						_dE2_VENCREA := SE2->E2_VENCREA
					EndIf

					If _nRecNoIns > 0
						SE2->( MsUnLock() )
						SE2->( DbGoTo( _nRecNoIns ) )
						RecLock( "SE2", .F. )
						If Round( nE2_INSS, 2 ) = 0
							_lGeraIns       := .F.
							SE2->E2_VALOR   := nE2_VLADIC
							SE2->E2_SALDO   := nE2_VLADIC
							SE2->E2_VLCRUZ  := nE2_VLADIC
						Else
							SE2->E2_VALOR   := nE2_INSS
							SE2->E2_SALDO   := nE2_INSS
							SE2->E2_VLCRUZ  := nE2_INSS
						EndIf
						SE2->( MsUnLock() )
					EndIf

					If _lGeraIns .And. Round( nE2_VLADIC, 2 ) > 0
						_cQry := " SELECT E2_PARCELA FROM " + RETSQLNAME( "SE2" ) + " (NOLOCK) WHERE "
						_cQry += " D_E_L_E_T_ = ' ' AND E2_FORNECE = 'INPS' AND E2_FILIAL = '" + xFilial( 'SE2' ) + "' AND "
						_cQry += " E2_NUM = '" + SE2->E2_NUM + "' AND E2_PREFIXO = '" + SE2->E2_PREFIXO + "' "

						_cQry := ChangeQuery( _cQry )

						If Select( 'TINS' ) > 0; TINS->( DbCloseArea() ); EndIf
						DbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQry ), "TINS", .T., .F. )

						TINS->( DbGoTop() )

						Do While TINS->( ! Eof() )
							_cParcIns := Soma1( TINS->E2_PARCELA,, .T. )
							TINS->( DbSkip() )
						EndDo

						While .T.
							If SE2->( DbSeek( xFilial( 'SE2' ) + SE2->E2_PREFIXO + _cParcIns + SE2->E2_TIPO + 'INPS  00' ) )
								_cParcIns := Soma1( TINS->E2_PARCELA,, .T. )
							Else
								Exit
							EndIf
						End

						RecLock( "SE2", .T. )
							SE2->E2_FILIAL  := xFilial( "SE2" )
							SE2->E2_PREFIXO := _cE2_PREFIXO
							SE2->E2_NUM     := _cE2_NUM
							SE2->E2_EMISSAO := _dE2_EMISSAO
							SE2->E2_VENCTO  := If( Type( "_dE2_VENCTO" )  = 'C', Stod( _dE2_VENCTO  ), _dE2_VENCTO  )
							SE2->E2_VENCREA := If( Type( "_dE2_VENCREA" ) = 'C', Stod( _dE2_VENCREA ), _dE2_VENCREA )
							SE2->E2_EMIS1   := _dE2_EMIS1
							SE2->E2_TITPAI  := _cE2_TITPAI
							SE2->E2_RETINS  := _nE2_RETINS
							SE2->E2_MSIDENT := _cE2_MSIDENT
							SE2->E2_CNPJRET := Posicione( "SA2", 1, xFilial( 'SA2' ) + _cFornecPrin, 'A2_CGC' )
							SE2->E2_PARCELA := _cParcIns
							SE2->E2_TIPO    := 'INS'
							SE2->E2_NATUREZ := 'INSS'
							SE2->E2_FORNECE := 'INPS'
							SE2->E2_LOJA    := '00'
							SE2->E2_NOMFOR  := 'INPS'
							SE2->E2_VALOR   := nE2_VLADIC
							SE2->E2_LA      := 'S'
							SE2->E2_SALDO   := nE2_VLADIC
							SE2->E2_VENCORI := If( Type( "_dE2_VENCREA" ) = 'C', Stod( _dE2_VENCREA ), _dE2_VENCREA )
							SE2->E2_MOEDA   := 1
							SE2->E2_VLCRUZ  := nE2_VLADIC
							SE2->E2_ORIGEM  := 'MATA100'
							SE2->E2_DIRF    := '2'
							SE2->E2_FILORIG := xFilial( 'SE2' )
						SE2->( MsUnLock() )
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	SE2->( DbGoTo( _nRecNoE2 ) )

	If ! ( ! l103Auto .AND. ( Inclui .or. Altera .or. l103Class ) .And. If( Type( '_lDlgPasR' ) <> 'U', _lDlgPasR, .F. ) )

		_cQry := " DELETE " + RETSQLNAME( 'SE2' ) + " WHERE "
		_cQry += " D_E_L_E_T_ = ' ' AND E2_FILIAL = '" + xFilial( "SE2" ) + "' AND E2_NUM = '" + SE2->E2_NUM + "' AND E2_EMISSAO = '" + Dtos( SE2->E2_EMISSAO ) + "' AND " 
		_cQry += " E2_FORNECE = 'INPS' AND E2_PREFIXO = '" + SE2->E2_PREFIXO + "' "

		TCSQLEXEC( _cQry )

	EndIf

	RestArea( _aArea )

Return lRet

**********************************
Static Function FVALPARC( _nPar1 )
**********************************

	Local _nValorParc := 0
	Local lISSEmiss   := GetNewPar("MV_MRETISS","1") == "1"

	If _nPar1 = 1
		TSE2P->( DbSkip() )
		SE2->( DbGoTo( TSE2P->E2RECNO ) )
		_nValorParc := SE2->E2_VALOR - vcE2_VLADIC - ( SD1->D1_VALINS - nE2_RETSUB ) - SD1->D1_VALIRR - IIf(lIssEmiss, SD1->D1_VALISS, 0) 
		TSE2P->( DbGoTop() )
		SE2->( DbGoTo( TSE2P->E2RECNO ) )
	EndIf

Return _nValorParc