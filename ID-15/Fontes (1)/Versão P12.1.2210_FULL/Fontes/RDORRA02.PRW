/*/
==================================================================================
Data      : 07/02/2019
----------------------------------------------------------------------------------
Autor     : Daniel Machado
----------------------------------------------------------------------------------
Descricao : Relatório de Balancete com saldo virtual.
----------------------------------------------------------------------------------
Partida   : Menu de usuário
==================================================================================
/*/

#Include "TOPCONN.Ch"
#Include "RWMAKE.ch"
#Include "TOTVS.CH"
#Include "PROTHEUS.Ch"       

User Function RDORRA02

	Local _aArea := GetArea()

	Private _lGerouPadrao := .F.

	FWMsgRun(, { || FRDORRA02() }, 'Processando', 'Processando a rotina...' )

	If ! _lGerouPadrao
		Processa( { || FRDORRA03() }, 'Balancete com saldo virtual', "Aguarde...", .F. )
	Else
		CTBR040()
	EndIf

	RestArea( _aArea )

Return

**************************
Static Function FRDORRA02
**************************

	Local _dData

	_dData := GetCv7Date( '1', '01' )

	If dDataBase <= _dData
		CV7->( DbSetOrder( 1 ) )
		If CV7->( DbSeek( xFilial( 'CV7' ) + '011' ) )
			Do While CV7->( ! Eof() ) .And. CV7->CV7_FILIAL = xFilial( 'CV7' )
				If CV7->CV7_DATA = _dData
					RecLock( 'CV7', .F. )
						CV7->CV7_DATA := LastDate( MonthSub( dDataBase, 1 ) )
					CV7->( MsUnLock() )
					_dData := CV7->CV7_DATA
					Exit
				EndIf
			EndDo
		EndIf
	EndIf

	If dDataBase > _dData
		CTBA190( .T., FirstYDate( dDataBase ), dDataBase, cFilAnt, cFilAnt, '1', .T., '01' )
	EndIf

	_dData := GetCv7Date( '1', '01' )

	If ! dDataBase > _dData
		If MsgYesNo( "O saldo contábil está reprocessado até a data base do sistema - " + Dtoc( dDatabase ) + ", deseja emitir o relatório padrão?" )
			_lGerouPadrao := .T.
			Return
		EndIf
	EndIf

Return

*************************
Static Function FRDORRA03
*************************

	Local _cQry, _dDtSldAnt := LastDate( MonthSub( dDataBase , 1 ) ), _nValDeb := 0, _nValCre := 0, _cConta, _RecNoSxb
	Local _cConteXb, _cDeEngXb, _cDeSpaXb, _cDescrXb, _cColunXb, _cSeqXb, _cTipoXb, _RecNoSxb, _aSaldos := 0, _dDataIni := '19800101'
	Local _oDlg, _cCondAnt := '', _cCondMov := '', _nLinha := 0, _nContar := 0, _cEscrev
	Local _cPath := "C:\REL_BALVIRTUAL\", _cArq := "BALVIRTUAL.CSV", _cEOL := "CHR(13)+CHR(10)", _cDescCta, _lPedExc := .F.
	Local _lArqCsv, _cLin, _lGerExcel := .T., _cScript := "C:\REL_BALVIRTUAL\RELBALVIRTUAL", _nList := 1
	Local _aList := {}, _aListAux, _cPerg := 'RDORRA02'

	MONTADIR( _cPath )

	FERASE( _cPath + _cArq )

	If ! File( "C:\REL_BALVIRTUAL\DELVIRTUAL.BAT" )
		_lArqCsv := FCreate( "C:\REL_BALVIRTUAL\DELBALVIRTUAL.BAT", 0 )
		_cLin    := "ECHO OFF" + &_cEOL
		_cLin    += "del c:\rel_balvirtual\*relbalvirtual*.csv" + &_cEOL
		fWrite( _lArqCsv, _cLin, _lArqCsv )
		fClose( _lArqCsv )
	EndIf

	Shellexecute( "Open", "C:\REL_BALVIRTUAL\DELBALVIRTUAL.BAT", " /k dir ", "c:\", 1 )

	/*If ! SXB->( DbSeek( 'XVIRTU' ) )
		If SXB->( DbSeek( 'CT1' ) )
			Do While SXB->( ! Eof() ) .And. Alltrim( SXB->XB_ALIAS ) == 'CT1'
				IncProc( "Verificando consulta padrão" )
				_RecNoSxb := SXB->( RecNo() )
				_cTipoXb  := SXB->XB_TIPO
				_cSeqXb   := SXB->XB_SEQ
				_cColunXb := SXB->XB_COLUNA
				_cDescrXb := If( SXB->XB_TIPO = '1' .And. SXB->XB_SEQ = '01', 'Cta Cont. Analitica', SXB->XB_DESCRI )
				_cDeSpaXb := SXB->XB_DESCSPA
				_cDeEngXb := SXB->XB_DESCENG
				_cConteXb := SXB->XB_CONTEM
				RecLock( "SXB", .T. )
					SXB->XB_ALIAS   := 'XVIRTU'
					SXB->XB_TIPO    := _cTipoXb
					SXB->XB_SEQ     := _cSeqXb
					SXB->XB_COLUNA  := _cColunXb
					SXB->XB_DESCRI  := _cDescrXb
					SXB->XB_DESCSPA := _cDeSpaXb
					SXB->XB_DESCENG := _cDeEngXb
					SXB->XB_CONTEM  := _cConteXb
				SXB->( MsUnLock() )
				SXB->( DbGoTo( _RecNoSxb ) )
				SXB->( DbSetOrder( 1 ) )
				SXB->( DbSkip() )
			EndDo
			RecLock( 'SXB', .T. )
				SXB->XB_ALIAS   := 'XVIRTU'
				SXB->XB_TIPO    := '6'
				SXB->XB_SEQ     := '01'
				SXB->XB_CONTEM  := "CT1->CT1_CLASSE = '2' .AND. CT1->CT1_BLOQ = '2'"
			SXB->( MsUnLock() )
		Else
			Aviso( 'Atenção', 'Não existe consulta, (CT1), padrão cadastrada para esta rotina, contate o administrador.', { 'Sair' } )
			Return
		EndIf
	EndIf*/

	_lArqCsv := FCreate( _cScript + ".CSV", 0 )

	If _lArqCsv == - 1 .Or. ! File( _cScript + ".CSV" )
		If ! MsgYesNo( "Arquivo [" + _cScript + ".CSV] não pode ser criado corretamente, deseja proceguir sem gerar excel?" )
			fClose( _lArqCsv )
			_cScript := ""
			Return
		EndIf
		fClose( _lArqCsv )
		_cScript   := ""
		_lGerExcel := .F.
	EndIf

	//FAJUSTSX1( _cPerg ) Thais Paiva - Compatibilização P27

	If ! Pergunte( _cPerg, .T. )
		Return
	EndIf

	If _lGerExcel
		_cEscrev := 'Conta;'
		_cEscrev += 'Saldo Anterior;'
		_cEscrev += 'Débito;'
		_cEscrev += 'Crédito;'
		_cEscrev += 'Mov Período;'
		_cEscrev += 'Saldo Atual'
		_cEscrev := _cEscrev + &_cEOL

		fWrite( _lArqCsv, _cEscrev, _lArqCsv )
	EndIf

	_cQry := " SELECT DISTINCT( CT1_CONTA ) CT1_CONTA, CT1_DESC01 FROM " + RETSQLNAME( "CT1" ) + " CT1 (NOLOCK), " + RETSQLNAME( "CT2" ) + " CT2 (NOLOCK) WHERE "
	_cQry += " CT1.D_E_L_E_T_ = ' ' AND CT2.D_E_L_E_T_ = ' ' AND CT1_CLASSE = '2' AND CT1_FILIAL = '" + xFilial( "CT1" ) + "' AND "
	_cQry += " CT2_FILIAL = '" + xFilial( 'CT2' ) + "' AND SUBSTRING( CT2_LOTE, 1, 4 ) <> 'APUR' AND CT2_VLR01 > 0 AND "
	_cQry += " CT2_DATA >= '" + _dDataIni + "' AND CT2_DATA <= '" + Dtos( _dDtSldAnt ) + "' AND "
	_cQry += " ( CT2_DEBITO = CT1_CONTA OR CT2_CREDIT = CT1_CONTA ) AND "
	_cQry += " CT1_CONTA >= '" + MV_PAR01 + "' AND CT1_CONTA <= '" + MV_PAR02 + "' AND CT1_BLOQ = '2' "
	_cQry += " ORDER BY CT1_CONTA "

	_cQry := ChangeQuery( _cQry )

	IncProc( "Selecionando registros..." )

	If Select( 'TDPM' ) > 0; TDPM->( DbCloseArea() ); EndIf
	TCQUERY _cQry NEW ALIAS 'TDPM'

	TDPM->( DbGoTop() )

	_nContar := Contar( "TDPM", "!EOF()" )

	If _nContar < 1
		Aviso( 'Antenção', 'Relatório vazio para este período!', { 'Sair' } )
		Return
	EndIf

	TDPM->( DbGoTop() )

	ProcRegua( _nContar )

	Do While TDPM->( ! Eof() )

		IncProc( "Processando dados..." )

		_cConta := TDPM->CT1_CONTA

		If Val( Substr( _cConta, 1, 1 ) ) > 2
			_cQry := " SELECT MAX( CT2_DATA ) CT2_DATA FROM " + RETSQLNAME( 'CT2' ) + " (NOLOCK) WHERE "
			_cQry += " D_E_L_E_T_ = ' ' AND CT2_FILIAL = '" + xFilial( 'CT2' ) + "' AND SUBSTRING( CT2_LOTE, 1, 4 ) = 'APUR' "
			_cQry += " ORDER BY CT2_DATA "

			_cQry := ChangeQuery( _cQry )

			If Select( 'TAPU' ) > 0; TAPU->( DbCloseArea() ); EndIf
			DbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQry ), "TAPU", .T., .F. )

			TAPU->( DbGoTop() )

			_dDataIni := Dtos( FirstYDate( Stod( Alltrim( Str( Val(Substr( TAPU->CT2_DATA, 1, 4 ) ) + 1 ) ) + Substr( TAPU->CT2_DATA, 5, 4 ) ) ) )
		EndIf

		_cQry := " SELECT SUM( CT2_VALOR ) CT2_VALOR FROM " + RETSQLNAME( 'CT2' ) + " WHERE "
		_cQry += " D_E_L_E_T_ = ' ' AND CT2_TPSALD = '1' AND CT2_DC <> '4' AND CT2_FILIAL = '" + xFilial( 'CT2' ) + "' AND " 
		_cQry += " CT2_DATA >= '" + _dDataIni + "' AND CT2_DATA <= '" + Dtos( _dDtSldAnt ) + "' AND "
		_cQry += " CT2_DEBITO = '" + _cConta + "' AND SUBSTRING( CT2_LOTE, 1, 4 ) <> 'APUR' "

		_cQry := ChangeQuery( _cQry )

		If Select( 'TDEB' ) > 0; TDEB->( DbCloseArea() ); EndIf
		TCQUERY _cQry NEW ALIAS 'TDEB'

		TDEB->( DbGoTop() )

		If TDEB->( ! Eof() )
			_nValDeb := TDEB->CT2_VALOR
		EndIf

		_cQry := " SELECT SUM( CT2_VALOR ) CT2_VALOR FROM " + RETSQLNAME( 'CT2' ) + " WHERE "
		_cQry += " D_E_L_E_T_ = ' ' AND CT2_TPSALD = '1' AND CT2_DC <> '4' AND CT2_FILIAL = '" + xFilial( 'CT2' ) + "' AND " 
		_cQry += " CT2_DATA >= '" + _dDataIni + "' AND CT2_DATA <= '" + Dtos( _dDtSldAnt ) + "' AND "
		_cQry += " CT2_CREDIT = '" + _cConta + "' AND SUBSTRING( CT2_LOTE, 1, 4 ) <> 'APUR' "

		_cQry := ChangeQuery( _cQry )

		If Select( 'TCRED' ) > 0; TCRED->( DbCloseArea() ); EndIf
		TCQUERY _cQry NEW ALIAS 'TCRED'

		TCRED->( DbGoTop() )

		If TCRED->( ! Eof() )
			_nValCre := TCRED->CT2_VALOR
		EndIf

		_aSaldos := _nValDeb - _nValCre

		If CT1->CT1_NORMAL = '1'
			If _nValDeb > _nValCre
				_cCondAnt := 'D'
			Else
				_cCondAnt := 'C'
			EndIf
		Else
			If _nValDeb < _nValCre
				_cCondAnt := 'C'
			Else
				_cCondAnt := 'D'
			EndIf
		EndIf

		_cQry := " SELECT SUM( CT2_VALOR ) CT2_VALOR FROM " + RETSQLNAME( 'CT2' ) + " WHERE "
		_cQry += " D_E_L_E_T_ = ' ' AND CT2_TPSALD = '1' AND CT2_DC <> '4' AND CT2_FILIAL = '" + xFilial( 'CT2' ) + "' AND " 
		_cQry += " CT2_DATA >= '" + Dtos( FirstDate( dDataBase ) ) + "' AND CT2_DATA <= '" + Dtos( dDataBase ) + "' AND "
		_cQry += " CT2_DEBITO = '" + _cConta + "' AND SUBSTRING( CT2_LOTE, 1, 4 ) <> 'APUR' "

		_cQry := ChangeQuery( _cQry )

		If Select( 'TDEB' ) > 0; TDEB->( DbCloseArea() ); EndIf
		TCQUERY _cQry NEW ALIAS 'TDEB'

		TDEB->( DbGoTop() )

		If TDEB->( ! Eof() )
			_nValDeb := TDEB->CT2_VALOR
		EndIf

		_cQry := " SELECT SUM( CT2_VALOR ) CT2_VALOR FROM " + RETSQLNAME( 'CT2' ) + " WHERE "
		_cQry += " D_E_L_E_T_ = ' ' AND CT2_TPSALD = '1' AND CT2_DC <> '4' AND CT2_FILIAL = '" + xFilial( 'CT2' ) + "' AND " 
		_cQry += " CT2_DATA >= '" + Dtos( FirstDate( dDataBase ) ) + "' AND CT2_DATA <= '" + Dtos( dDataBase ) + "' AND "
		_cQry += " CT2_CREDIT = '" + _cConta + "' AND SUBSTRING( CT2_LOTE, 1, 4 ) <> 'APUR' "

		_cQry := ChangeQuery( _cQry )

		If Select( 'TCRED' ) > 0; TCRED->( DbCloseArea() ); EndIf
		TCQUERY _cQry NEW ALIAS 'TCRED'

		TCRED->( DbGoTop() )

		If TCRED->( ! Eof() )
			_nValCre := TCRED->CT2_VALOR
		EndIf

		If ( _nValDeb + _nValCre ) <> 0
			If CT1->CT1_NORMAL = '1'
				If _nValDeb > _nValCre
					_cCondMov := 'D'
				Else
					_cCondMov := 'C'
				EndIf
			Else
				If _nValDeb < _nValCre
					_cCondMov := 'C'
				Else
					_cCondMov := 'D'
				EndIf
			EndIf
		Else
			_cCondMov := _cCondAnt
		EndIf

		If _cCondMov = 'D'
			_nSalAtu := _aSaldos - ( _nValCre - _nValDeb )
		Else
			_nSalAtu := _aSaldos + ( _nValDeb - _nValCre )
			If _nSalAtu < 0
				_nSalAtu := ( _nSalAtu ) * ( - 1 )
			EndIf
		EndIf
		If _aSaldos <> 0 .Or. _nValDeb <> 0 .Or. _nValCre <> 0 .Or. _nSalAtu <> 0
			_nMovPeri := Round( If( ( _nValDeb - _nValCre ) < 0,( ( _nValDeb - _nValCre ) * - 1 ), ( _nValDeb - _nValCre ) ), 2 )
			_nMovPeri := StrTran( Alltrim( Str( _nMovPeri ) ), '.', ',' )
			_cDescCta := Alltrim( StrTran( StrTran( FwCutOff( TDPM->CT1_DESC01, .T. ), "'", "" ), '"', '' ) )
			_nSpace   := 50 - Len( Substr( _cDescCta, 1, 22 ) )
			_nSpSld   := 26 - Len( Alltrim( Str( _aSaldos ) ) )
			_nSpDeb   := 26 - Len( Alltrim( Str( _nValDeb ) ) )
			_nSpCre   := 26 - Len( Alltrim( Str( _nValCre ) ) )
			_nSpMov   := 26 - Len( _nMovPeri                  )
			_nSpAtu   := 26 - Len( Alltrim( Str( _nSalAtu ) ) )

			_aListAux := { Alltrim( _cConta ) + ' - ' + _cDescCta,;
			               Alltrim( Str( Round( If( _aSaldos < 0, ( _aSaldos ) * ( - 1 ), _aSaldos ), 2 ) ) ) + ' ' + _cCondAnt,;
			               Alltrim( Str( Round( _nValDeb, 2 ) ) ), Alltrim( Str( Round( _nValCre, 2 ) ) ),;
			               _nMovPeri + ' ' + If( Val( _nMovPeri ) > 0, _cCondMov, '' ),;
			               Alltrim( Str( Round( If( _nSalAtu < 0, ( _nSalAtu * ( -1 ) ), _nSalAtu ), 2 ) ) ) + ' ' + _cCondMov }

			AADD( _aList, _aListAux )

			If _lGerExcel
				_cEscrev  := Alltrim( _cConta ) + ' - ' + Alltrim( StrTran( StrTran( FwCutOff( TDPM->CT1_DESC01, .T. ), "'", "" ), '"', '' ) ) + ';' +;
				             StrTran( Alltrim( Str( Round( If( _aSaldos < 0, ( _aSaldos ) * ( - 1 ), _aSaldos ), 2 ) ) ), '.', ',' ) + ' ' +;
				             _cCondAnt + ';' + StrTran( Alltrim( Str( Round( _nValDeb, 2 ) ) ), '.', ',' ) + ';' +;
				             StrTran( Alltrim( Str( Round( _nValCre, 2 ) ) ), '.', ',' ) + ';' + _nMovPeri + ' ' + _cCondMov + ';' +;
				             StrTran( Alltrim( Str( Round( If( _nSalAtu < 0, ( _nSalAtu * ( -1 ) ), _nSalAtu ), 2 ) ) ), '.', ',' ) + ' ' + _cCondMov
				_cEscrev  := _cEscrev + &_cEOL

				fWrite( _lArqCsv, _cEscrev, _lArqCsv )
			EndIf
		EndIf
		TDPM->( DbSkip() )
	EndDo

	_nLinha := 1

	ProcRegua( Len( _aList ) )

	fClose( _lArqCsv )

	If Len( _aList ) > 0
		Define Font _oFont Name 'Courier New' Size 0, -15

		DEFINE MSDIALOG _oDlg FROM 0,0 TO 400, 400 PIXEL TITLE 'Balancete com saldo virtual - ' + Alltrim( Str( Len( _aList ) ) ) + ' linhas.'
			_oDlg:lMaximized := .T.

			_oList := TCBrowse():New( 001 , 001, 675, 275,, { 'Conta', 'Saldo Anterior', 'Débito', 'Crédito', 'Mov Período', 'Saldo Atual' }, { 20, 50, 50, 50 },;
			                          _oDlg,,,,, { || },, _oFont,,,,, .F.,, .T.,, .F.,,, )

			_oList:SetArray( _aList )
			_oList:bLine := { || { _aList[_oList:nAt, 01], _aList[_oList:nAt,02],_aList[_oList:nAT, 03],;
		                      _aList[_oList:nAT, 04], _aList[_oList:nAT, 05], _aList[_oList:nAT, 06] } }

			oButton := tButton():New( 280, 001, 'Sair'       , _oDlg, { || _oDlg:End()                      }, 337, 020,,,, .T. )
			oButton := tButton():New( 280, 339, 'Gerar Excel', _oDlg, { || ( _lPedExc := .T., _oDlg:End() ) }, 337, 020,,,, .T. )
		ACTIVATE MSDIALOG _oDlg CENTERED
	EndIf

	If _lGerExcel .And. _lPedExc
		Shellexecute( "Open", _cScript + ".CSV", " /k dir ", "c:\", 1 )
	EndIf

Return

/*Início - Thais Paiva - Compatibilização P27
***********************************
Static Function FAJUSTSX1( _cPerg )
***********************************

	Local _aSx1 := {}, _cCampo

	AADD( _aSx1, { "GRUPO","ORDEM","PERGUNT"         , "PERSPA"      , "PERENG"           , "VARIAVL", "TIPO", "TAMANHO", "DECIMAL", "PRESEL", "GSC", "VALID", "VAR01"   , "F3"    , "DEF01" , "DEF02", "DEF03", "DEF04", "DEF05", "HELP" } )
	AADD( _aSx1, { _cPerg , "01"  , "Conta Inicial ?", "¿De Cuenta ?", "Initial Account ?", "mv_ch1" , "C"   , 20       , 0        , 0       , "G"  , ""     , "mv_par01", "XVIRTU", ""      , ""     , ""     , ""     , ""     , ""     } )
	AADD( _aSx1, { _cPerg , "02"  , "Conta Final ?  ", "¿A Cuenta ? ", "Final Account ?  ", "mv_ch2" , "C"   , 20       , 0        , 0       , "G"  , ""     , "mv_par02", "XVIRTU", ""      , ""     , ""     , ""     , ""     , ""     } )

	DbSelectArea( "SX1" )
	SX1->( DbSetOrder( 1 ) )

	If SX1->( ! DbSeek( _cPerg + _aSx1[Len( _aSx1 ), 2] ) )
		SX1->( DbSeek( _cPerg ) )
		While SX1->( ! Eof() ) .And. Alltrim( SX1->X1_GRUPO ) == Alltrim( _cPerg )
			SX1->( Reclock( "SX1", .F., .F. ) )
			SX1->( DbDelete() )
			SX1->( MsunLock() )
			SX1->( DbSkip() )
		End
		For _X1 := 2 To Len( _aSX1 )
			SX1->( RecLock( "SX1", .T. ) )
			For _Z := 1 To Len( _aSX1[1] )
				_cCampo := "X1_" + _aSX1[1, _Z]
				SX1->( FieldPut( FieldPos( _cCampo ), _aSx1[_X1, _Z] ) )
			Next
			SX1->( MsunLock() )
		Next
	EndIf

Return
Fim - Thais Paiva - Compatibilização P27*/