/*/
==================================================================================
Data      : 13/06/2018
----------------------------------------------------------------------------------
Autor     : Daniel Machado
----------------------------------------------------------------------------------
Descricao : Importar ativo por meio de *.CSV.
----------------------------------------------------------------------------------
Partida   : Menu de usuário
==================================================================================
/*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.Ch"
#INCLUDE "RWMAKE.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "Fileio.ch"
#INCLUDE "hbutton.ch"

User Function RDORATA1

	Local _oDlg
	Local _aArea  := GetArea()
	Local _lOk    := .F.
	Local _lYesNo := .T., _cQry := "", _bOk := .F.

	Private _cArquivo := Space( 100 )
	Private _nPosCbas := 0
	Private _nPosItem := 0
	Private _nPosGrup := 0
	Private _nLin     := 15
	Private _nCol1    := 16
	Private _nCol2    := 40
	Private _nCol3    := 290
	Private _aCposN1  := {}
	Private _aCposN3  := {}, _aSn1 := {}, _aSn3 := {}, _nLenExec := 0, nRadio
	Private _aItens   := {}, _lContItem := .F., _aAcolsN1 := {}, _aAcolsN3 := {}, _lRetPerg := 0, _lOkTela1 := .F., _cCbase := 0, _aCBase := {}
	Private _lOld     := 0, _nPosChapa := 0, _lIncCbas := .F., _lN3histor := .F., _nNfical := 0, _nDescr := 0, _nN3Tipo := 0

	_lRetPerg := FTELPERG()

	If _lRetPerg = 0 .Or. ! _lOkTela1
		If _lRetPerg > 0 .And. ! _lOkTela1
			Aviso( 'Aviso', 'Nenhuma opção foi selecionada!', { 'Sair' } )
		EndIf
		RestArea( _aArea )
		Return
	ElseIf _lRetPerg = 2 .And. _lOkTela1
		FTELABRAN()
		RestArea( _aArea )
		Return
	EndIf

	Set Deleted On

	Define MsDialog _oDlg Title "Diretório" From 08,15 To 15, 97 Of GetWndDefault()

		@ 001, 1.5 TO 034, 325 OF _oDlg PIXEL
		@ 035, 1.5 TO 052, 325 OF _oDlg PIXEL

		@ _nLin, _nCol1 Say "Diretorio:"  Size 050, 10 Of _oDlg Pixel
		@ _nLin, _nCol2 MsGet _cArquivo   Size 250, 08 Of _oDlg Pixel

		@ _nLin, _nCol3 Button "…"  Size 010, 10 Action Eval( { || _lok := SelectFile() } ) Of _oDlg Pixel

		@ 037, 005 Button OemToAnsi( "Incluir"  ) Size 156, 12 Font _oDlg:oFont Action ( _lYesNo := .T., If( _lok, _oDlg:End(), MsgAlert( "Selecione um arquivo válido para prosseguir" ) ) ) Of _oDlg Pixel
		@ 037, 164 Button OemToAnsi( "Cancelar" ) Size 156, 12 Font _oDlg:oFont Action ( _lOk    := .F., _oDlg:End() ) Of _oDlg Pixel

	Activate MSDIALOG _oDlg Centered

	If ! _lOk
		RestArea( _aArea )
		Return
	EndIf

	Processa( { | _lEnd | _LOK := FLerAtivo( @_lEnd ) }, 'Efetuando leitura do arquivo', "Aguarde...", .T. )

	If _lYesNo .And. _LOK .And. _lOld = 0
		FMONTACOLS()
	EndIf

	RestArea( _aArea )

Return

**************************
Static Function SelectFile
**************************

	Local _cMaskDir     := "Arquivos Microsoft Excel (*.csv) |*.csv|"
	Local _cTitTela     := "Arquivo para a integracao"
	Local _lInfoOpen    := .T.
	Local _lDirServidor := .T.
	Local _lRet         := .T.
	Local _cOldFile     := _cArquivo

	_cArquivo := cGetFile( _cMaskDir, _cTitTela,, _cArquivo, _lInfoOpen, ( GETF_LOCALHARD + GETF_NETWORKDRIVE ), _lDirServidor )

	If ! File( _cArquivo ) .And. ! Empty( _cArquivo )
		MsgStop( "Arquivo Não Existe!" )
		_cArquivo := _cOldFile
		_lRet := .F.
	ElseIf Empty( _cArquivo )
		_lRet := .F.
	EndIf

Return _lRet

**********************************
Static Function FLerAtivo( _lEnd )
**********************************

	Local _aArea   := GetArea()
	Local _lRet    := .T.
	Local _nxCpoN1 := 0
	Local _nxCpoN3 := 0
	Local _lSn3    := .F.
	Local _lItens  := .F.
	Local _aTpCpo  := {}
	Local _nCont   := 1
	Local _nVetN1  := 0
	Local _nVetN3  := 0
	Local _aPosCpo := {}
	Local _aTexto  := {}
	Local _cTexto  := ""
	Local _cAjstIt := {}
	Local _nTamArq, _nTamLinha, _cFile, _nHandle, _nItemPos := 0

	_cFile := _cArquivo

	_nHandle := FOPEN( _cFile, FC_NORMAL )

	If _nHandle = - 1
		MsgInfo( "Aviso", "Problema ao abrir o arquivo, verifique!", { "Fechar" } )
		Return .F.
	EndIf

	_nTamArq := FSEEK( _nHandle, 0, 2 )

	FSEEK( _nHandle, 0, 0 )

	FT_FUse( _cFile )
	FT_FGoTop()

   	_nTamLinha := Len( FT_FREADLN() )

	FT_FGOTOP()

	_nLinhas := FT_FLastRec() 

	ProcRegua( _nLinhas )

	Do While ! FT_FEOF() .And. _nLinhas >= _nCont

		If _lEnd
			Return .F.
		EndIf

		IncProc( "Lendo " + Alltrim( Str( _nCont ) ) + " linhas de " + Alltrim( Str( _nLinhas ) ) )

		If _nCont > _nLinhas
			Exit
		EndIf

		If ! Empty( FT_FReadLn() )

			For _rf := 1 To Len( Alltrim( FT_FReadLn() ) )

				If Substr( FT_FReadLn(), _rf, 1 ) <> ";"

					If _nCont = 1
						If Substr( FT_FReadLn(), _rf, 3 ) = "N3_"
							_lSn3 := .T.
							_nVetN3++
						ElseIf Substr( FT_FReadLn(), _rf, 3 ) = "N1_"
							_nVetN1++
						EndIf
					Else
						_lItens := .T.
					EndIf

					_cTexto := _cTexto + Substr( FT_FReadLn(), _rf, 1 )

				ElseIf Substr( FT_FReadLn(), _rf - 1, 1 ) = ";" .And. Substr( FT_FReadLn(), _rf, 1 ) = ";" .And. _nCont <> 1

					_nItemPos++

					AADD( _aTexto, { "", _lSn3, _lItens, "", 0 } )

				ElseIf ! Empty ( Alltrim( _cTexto ) ) .And. _cTexto <> Chr(13) + Chr(10)

					If UPPER( Alltrim( _cTexto ) ) = "N1_CBASE" .And. _nCont = 1
						_nPosCbas := Len( _aTexto ) + 1
					ElseIf UPPER( Alltrim( _cTexto ) ) = "N1_ITEM" .And. _nCont = 1
						_nPosItem := Len( _aTexto ) + 1
					ElseIf UPPER( Alltrim( _cTexto ) ) = "N1_GRUPO" .And. _nCont = 1
						_nPosGrup := Len( _aTexto ) + 1
					ElseIf UPPER( Alltrim( _cTexto ) ) = "N1_NFISCAL" .And. _nCont = 1
						_nNfical := Len( _aTexto ) + 1
					ElseIf UPPER( Alltrim( _cTexto ) ) = "N1_DESCRIC" .And. _nCont = 1
						_nDescr  := Len( _aTexto ) + 1
					EndIf

					If _nCont = 1
						SX3->( DbSetOrder( 2 ) )
						If ! SX3->( DbSeek( UPPER( Alltrim( _cTexto ) ) ) )
							Aviso( "Atenção", "O campo " + UPPER( Alltrim( _cTexto ) ) + " não existe no dicionário, verifique.", { "Sair" } )
							Return .F.
						EndIf
					EndIf

					If _nCont = 1
						If UPPER( Alltrim( _cTexto ) ) = "N1_CHAPA"
							_nPosChapa := Len( _aTexto ) + 1
						EndIf
						AADD( _aPosCpo, { TamSX3( UPPER( Alltrim( _cTexto ) ) )[3] } )
					Else
						_nItemPos++
					EndIf

					AADD( _aTexto, { UPPER( Alltrim( _cTexto ) ), _lSn3, _lItens, If( _nCont = 1, TamSX3( UPPER( Alltrim( _cTexto ) ) )[3], _aPosCpo[_nItemPos][1] ) } )

					_cTexto := ""
					_lSn3   := .F.

				EndIf

			Next _rf

			If ! Empty( Alltrim( _cTexto ) ) .And. _cTexto <> Chr(13) + Chr(10)
				If _nCont = 1
					If UPPER( Alltrim( _cTexto ) ) = "N1_CHAPA"
						_nPosChapa := Len( _aTexto ) + 1
					EndIf
					AADD( _aPosCpo, { TamSX3( UPPER( Alltrim( _cTexto ) ) )[3] } )
				Else
					_nItemPos++
				EndIf

				If UPPER( Alltrim( _cTexto ) ) = "N3_HISTOR"
					_lN3histor := .T.
				EndIf

				AADD( _aTexto, { UPPER( Alltrim( _cTexto ) ), _lSn3, _lItens, If( _nCont = 1, TamSX3( UPPER( Alltrim( _cTexto ) ) )[3], _aPosCpo[_nItemPos][1] ) } )

			EndIf

			If _nPosCbas = 0 .And. _nCont = 1
				AADD( _aTexto, { UPPER( Alltrim( "N1_CBASE" ) ), .F., _lItens, TamSX3( UPPER( Alltrim( "N1_CBASE" ) ) )[3] } )
				AADD( _aPosCpo, { TamSX3( "N1_CBASE" )[3] } )
				_nVetN1++
				_lIncCbas := .T.
				_nPosCbas := Len( _aTexto )
			EndIf

			_cTexto   := ""
			_nItemPos := 0

			If _nCont = 1
				_aCposN1 := Array( _nVetN1, _nLinhas )
				_aCposN3 := Array( _nVetN3, _nLinhas )
			EndIf

			For _nx := 1 To Len( _aTexto )
				If _nCont = 1
					If _aTexto[_nx][2]
						_nxCpoN3++
						AADD( _aTpCpo, { _aTexto[_nx][2] } )
						_aCposN3[_nxCpoN3][_nCont] := _aTexto[_nx][1]
					ElseIf ! _aTexto[_nx][2]
						_nxCpoN1++
						AADD( _aTpCpo, { _aTexto[_nx][2] } )
						_aCposN1[_nxCpoN1][_nCont] := _aTexto[_nx][1]
					EndIf
				Else
					If _aTpCpo[_nx][1]
						_nxCpoN3++
						_aCposN3[_nxCpoN3][_nCont] := If( _aTexto[_nx][4] = "N", ( _aTexto[_nx][1] := StrTran( _aTexto[_nx][1], ".", "" ), Val( StrTran( _aTexto[_nx][1], ",", "." ) ) ), If( _aTexto[_nx][4] = "D", Ctod( _aTexto[_nx][1] ), _aTexto[_nx][1] ) )
					ElseIf ! _aTpCpo[_nx][1]
						_nxCpoN1++
						_aCposN1[_nxCpoN1][_nCont] := If( _aTexto[_nx][4] = "N", ( _aTexto[_nx][1] := StrTran( _aTexto[_nx][1], ".", "" ), Val( StrTran( _aTexto[_nx][1], ",", "." ) ) ), If( _aTexto[_nx][4] = "D", Ctod( _aTexto[_nx][1] ), _aTexto[_nx][1] ) )
					EndIf
				EndIf
			Next _nx

		EndIf

		_aTexto  := {}
		_cTexto  := ""
		_cAjstIt := {}
		_nxCpoN1 := 0
		_nxCpoN3 := 0

		FT_FSKIP()

		If ! FT_FEOF()
			_nCont++
		EndIf

	EndDo

	IncProc( "Lendo " + Alltrim( Str( _nCont ) ) + " linhas de " + Alltrim( Str( _nLinhas ) ) )

	If Len( _aCposN1 ) = 0 .Or. Len( _aCposN3 ) = 0
		_lRet := .F.
	EndIf

	fClose( _cArquivo  )

Return _lRet

***********************************
Static Function FIncluiAtv( _lEnd )
***********************************

	Local _ItensT   := {}, _aParamAuto := {}
	Local _nCont    := 1
	Local _lPrim    := .T.
	Local _aGrupo   := {}
	Local _cQry     := ""
	Local _cPath    := "C:\LOG_IMPORT_ATF\"
	Local _cNomeArq := "LOGERROR_" + cUserName + "_" + Dtos( Date() ) + "_"

	AADD( _aParamAuto, { "MV_PAR01", 2 } )
    AADD( _aParamAuto, { "MV_PAR02", 1 } )
    AADD( _aParamAuto, { "MV_PAR03", 1 } )
    AADD( _aParamAuto, { "MV_PAR04", 2 } )
    AADD( _aParamAuto, { "MV_PAR05", 2 } )

	MONTADIR( _cPath )

	lMsErroAuto := .F.

	ProcRegua( Len( _aItens ) )

	IncProc()

	For _kd := 1 To _nLenExec

		If _lEnd
			DisarmTransaction()
			Break
			Return
		EndIf

		IncProc( "Incluindo " + Alltrim( Str( _nCont ) ) + " item de " + Alltrim( Str( Len( _aSn1[_nLenExec] ) ) ) )

		_ItensT := {}

		AADD( _aSn1, { 'N1_FILIAL', xFilial( "SN1" ), NIL } )

		AADD( _ItensT, _aSn3 )

		MSExecAuto( { | X, Y, Z | ATFA012( X, Y, Z ) } , _aSn1 , _ItensT, 3, _aParamAuto )

		If lMsErroAuto
			MostraErro( _cPath, _cNomeArq + Substr( Time(), 1, 2 ) + Substr( Time(), 4, 2 ) + Substr( Time(), 7, 2 ) + "_Linha_" + Alltrim( Str( _kd ) ) + ".LOG" )
		Else
			RecLock( "SN1", .F. )
		//	If _nPosChapa > 0 
		//		SN1->N1_CHAPA  := _aCposN1[_nPosChapa][_kd]+1
		//	EndIf
			SN1->N1_STATUS := "1"
			SN1->( MsUnLock() )
			If SNG->( DbSeek( xFilial( 'SNG' ) + Substr( SN3->N3_CBASE, 1, 4 ) ) )
				RecLock( "SN3", .F. )
				SN3->N3_TXDEPR1 := SNG->NG_TXDEPR1
				SN3->N3_DLANCTO := dDataBase
				SN3->( MsUnLock() )
			EndIf
		EndIf

		_nCont++

	Next _kd

Return

************************
Static Function FTELPERG
************************

	Local _oDlg, oRadio

	DEFINE MSDIALOG _oDlg TITLE 'Atualização de Ativos' FROM 0,0 TO 120, 230 PIXEL Style DS_MODALFRAME

		_oDlg:lEscClose := .F.

		nRadio := 0
		oRadio := TRadMenu():New ( 05, 30, { 'Importar Tabela ?', 'Criar Tabela ?' },, _oDlg,,,,,,,, 200, 200,,,, .T. )

		oRadio:bSetGet := { |u|Iif ( PCount() == 0, nRadio, nRadio := u ) }

		@ 037, 020 Button OemToAnsi( "Confirmar" ) Size 30, 12 Font _oDlg:oFont Action ( _lOkTela1 := .T., If( nRadio > 0, _oDlg:End(), Aviso( 'Atenção', 'Nenhuma opção selecionada!', { 'Voltar' } ) ) ) Of _oDlg Pixel
		@ 037, 070 Button OemToAnsi( "Cancelar"  ) Size 30, 12 Font _oDlg:oFont Action ( _lOkTela1 := .F., If( nRadio > 0, ( nRadio := 0, _oDlg:End() ), _oDlg:End()                                   ) ) Of _oDlg Pixel

	ACTIVATE MSDIALOG _oDlg CENTERED

Return nRadio

*************************
Static Function FTELABRAN
*************************

	Local _lExit := .F., _bOk := .F.
	Local _aCmpSN1	:= {} //Thais Paiva - Compatibilização P27
	Local _aCmpSN3	:= {} //Thais Paiva - Compatibilização P27

	Private _oTree, _oDlgSel, _aItSel := {}, _oList, _nList := 1, _nItens := 0, _nItSn1, _nItSn3, _nItAdd := 1, _nUltCpoN1 := 0, _nUltCpoN3 := 0
	Private _aCpoN1 := {}, _aCpoN3 := {}, _nIniN3 := 0, _nItObrigat := 0, _aCpoObrigat := {}
	//Início - Thais Paiva - Compatibilização P27
	//SX3->( DbSetOrder( 1 ) )

	DEFINE DIALOG _oDlgSel TITLE "Seleção de campos - Impotação de Bens" FROM 300, 180 TO 550, 700 PIXEL Style DS_MODALFRAME

		_oDlgSel:lEscClose := .F.

		_oList := tListBox():New( 1, 145, { |u| If( Pcount() > 0, _nList:= u, _nList ) }, _aItSel, 117, 124,, _oDlgSel,,,, .T. )
		_oTree := DbTree():New( 1, 1, 125, 120, _oDlgSel,,, .T. )

		_oTree:AddItem( "Cadastro de Ativo SN1", "001", "RPMTABLE" ,,,, 1 )

		_nItSn1 := 1

		//SX3->( DbSeek( 'SN101' ) )
		_aCmpSN1 := FWSX3Util():GetAllFields( "SN1" , .T. )

		_nNivel := 2

		//Do While SX3->( ! Eof() ) .And. SX3->X3_ARQUIVO = 'SN1'
		For _nN1 := 1 to Len(_aCmpSN1)
			//If X3USO( SX3->X3_USADO ) .And. ! X3Obrigat( SX3->X3_CAMPO ) .And. Alltrim( SX3->X3_CAMPO ) <> 'N1_GRUPO'
			If X3USO( GetSx3Cache(_aCmpSN1[_nN1], 'X3_USADO') ) .And. ! X3Obrigat( _aCmpSN1[_nN1] ) .And. Alltrim( _aCmpSN1[_nN1]) <> 'N1_GRUPO'
				//_oTree:AddItem( SX3->X3_CAMPO, StrZero( _nNivel, 3 ), "MDIRUN" ,,,, 2 )
				_oTree:AddItem( _aCmpSN1[_nN1], StrZero( _nNivel, 3 ), "MDIRUN" ,,,, 2 )

				//AADD( _aCpoN1, SX3->X3_CAMPO )
				AADD( _aCpoN1, _aCmpSN1[_nN1] )
				AADD( _aCpoN1, _nNivel )

				_nNivel++
				_nUltCpoN1++
			//ElseIf ( X3USO( SX3->X3_USADO ) .And. X3Obrigat( SX3->X3_CAMPO ) ) .Or. Alltrim( SX3->X3_CAMPO ) = 'N1_GRUPO'
			ElseIf ( X3USO( GetSx3Cache(_aCmpSN1[_nN1], 'X3_USADO')) .And. X3Obrigat( _aCmpSN1[_nN1] ) ) .Or. Alltrim( _aCmpSN1[_nN1] ) == 'N1_GRUPO'
				_nItObrigat++
				//AADD( _aCpoObrigat, SX3->X3_CAMPO )
				AADD( _aCpoObrigat, _aCmpSN1[_nN1] )
				//_oList:ADD( SX3->X3_CAMPO, _nItObrigat )
				_oList:ADD( _aCmpSN1[_nN1], _nItObrigat )
			EndIf

			//SX3->( DbSkip() )
		//EndDo
		Next _nN1
		
		_oTree:AddItem( "Cadastro de Ativo SN3", StrZero( _nNivel, 3 ), "RPMTABLE" ,,,, 1 )

		_oTree:TreeSeek( StrZero( _nNivel, 3 ) )

		_nItSn3 := _nNivel
		_nIniN3 := _nNivel

		_nNivel++

		//SX3->( DbSeek( 'SN301' ) )
		_aCmpSN3 := FWSX3Util():GetAllFields( "SN3" , .T. )

		//Do While SX3->( ! Eof() ) .And. SX3->X3_ARQUIVO = 'SN3'
		For _nN3 := 1 to Len(_aCmpSN3)
			//If X3USO( SX3->X3_USADO ) .And. ! X3Obrigat( SX3->X3_CAMPO ) .And. ! Alltrim( SX3->X3_CAMPO ) $ 'N3_CUSTBEM|N3_VORIG1|N3_TXDEPR1'
			If X3USO( GetSx3Cache(_aCmpSN3[_nN3], 'X3_USADO') ) .And. ! X3Obrigat( _aCmpSN3[_nN3] ) .And. ! Alltrim(GetSx3Cache(_aCmpSN3[_nN3], 'X3_CAMPO')) $ 'N3_CUSTBEM|N3_VORIG1|N3_TXDEPR1'
				//_oTree:AddItem( SX3->X3_CAMPO, StrZero( _nNivel, 3 ), "MDIRUN" ,,,, 2 )
				_oTree:AddItem( _aCmpSN3[_nN3], StrZero( _nNivel, 3 ), "MDIRUN" ,,,, 2 )

				AADD( _aCpoN3, _aCmpSN3[_nN3] )
				AADD( _aCpoN3, _nNivel)

				_nNivel++
				_nUltCpoN3++
			//ElseIf ( X3USO( SX3->X3_USADO ) .And. X3Obrigat( SX3->X3_CAMPO ) ) .Or. Alltrim( SX3->X3_CAMPO ) $ 'N3_CUSTBEM|N3_VORIG1|N3_TXDEPR1'
			ElseIf ( X3USO( GetSx3Cache(_aCmpSN3[_nN3], 'X3_USADO') ) .And. X3Obrigat( _aCmpSN3[_nN3] ) ) .Or. Alltrim( _aCmpSN3[_nN3] ) $ 'N3_CUSTBEM|N3_VORIG1|N3_TXDEPR1'
				_nItObrigat++
				//AADD( _aCpoObrigat, SX3->X3_CAMPO )
				AADD( _aCpoObrigat, _aCmpSN3[_nN3] )
				//_oList:ADD( SX3->X3_CAMPO, _nItObrigat )
				_oList:ADD( _aCmpSN3[_nN3], _nItObrigat )
			EndIf

			//SX3->( DbSkip() )
		//EndDo
		Next _nN3
		//Fim - Thais Paiva - Compatibilização P27

		@ 020, 247 BTNBMP oWindow RESOURCE "PMSSETADIR" SIZE 40,40 DESIGN ACTION( FINCCPO( 1 )                                         ) OF _oDlgSel MESSAGE "Adicionar Campo"
		@ 050, 247 BTNBMP oWindow RESOURCE "PGNEXT"     SIZE 40,40 DESIGN ACTION( FINCCPO( 2 )                                         ) OF _oDlgSel MESSAGE "Adicionar Todos os Campos"
		@ 090, 247 BTNBMP oWindow RESOURCE "FINAL"      SIZE 40,40 DESIGN ACTION( _oDlgSel:End()                                       ) OF _oDlgSel MESSAGE "Sair"
		@ 130, 247 BTNBMP oWindow RESOURCE "PMSSETAESQ" SIZE 40,40 DESIGN ACTION( FREMCPO( 1 )                                         ) OF _oDlgSel MESSAGE "Remover Campo"
		@ 160, 247 BTNBMP oWindow RESOURCE "PGPREV"     SIZE 40,40 DESIGN ACTION( FREMCPO( 2 )                                         ) OF _oDlgSel MESSAGE "Remover Todos os Campos"
		@ 200, 247 BTNBMP oWindow RESOURCE "PCOFXOK"    SIZE 40,40 DESIGN ACTION( _lExit := .T., _bOk := FMONTACOLS(), 	_oDlgSel:End() ) OF _oDlgSel MESSAGE "Confirmar"

		_oTree:EndTree()

	ACTIVATE DIALOG _oDlgSel CENTERED

Return _bOk

**************************
Static Function FMONTACOLS
**************************

	Local _bOk := .F., _lHistorOk := .F.

	If nRadio = 2
		For _xn := 1 To Len( _oList:aItems )
			If Substr( _oList:aItems[_xn], 1, 2 ) = 'N1'
				AADD( _aAcolsN1, _oList:aItems[_xn] )
			Else
				AADD( _aAcolsN3, _oList:aItems[_xn] )
			EndIf
		Next _xn
	Else
		For _xn := 1 To Len( _aCposN1 )
			AADD( _aAcolsN1, _aCposN1[_xn][1] )
		Next _xn
		For _xn := 1 To Len( _aCposN3 )
			If _aCposN3[_xn][1] = 'N3_HISTOR'
				_lHistorOk := .T.
			EndIf
			AADD( _aAcolsN3, _aCposN3[_xn][1] )
		Next _xn
		If ! _lHistorOk
			AADD( _aAcolsN3, 'N3_HISTOR' )
			AADD( _aCposN3, Array( Len( _aCposN3[1] ) ) )
			For _xn := 1 To Len( _aCposN3[1] )
				_aCposN3[Len( _aCposN3 )][_xn] := If( _xn = 1, 'N3_HISTOR', 'IMPORTACAO AUTOMATICA' )
			Next _xn
		EndIf
	EndIf

	_bOk := FMONTTELA()

Return _bOk

**************************
Static Function FMONTTELA
**************************

	Local _nTop     := 61
	Local _nLeft    := 0
	Local _nBottom  := 300
	Local _nRight   := 678
	Local _nMax     := 9999
	Local _nStyle   := GD_INSERT + GD_UPDATE + GD_DELETE
	Local _aHead    := {}
	Local _aDados   := {}
	Local _aAlter   := {}
	Local _cFieldOk := "AllwaysTrue"
	Local _cLinhaOk := "U_FCLINHAOK()"
	Local _cTudoOk  := "AllwaysTrue"
	Local _cDelOk   := "U_FCDELETOK()"
	Local _aButtons := {}, _bOk := .F.
	Local _lFont, _oFont, _cFont, _cTitulo, _oWnd, _nPosTp := {}, _nPosCsv := 0, _aCBasePri := {}, _cGrupo := '', _aCBaseCod := {}

	Private _nUsado := 0, _oAtuSn, _oGetTot, _nTotSzp := 0
	
	//Início - Thais Paiva - Compatibilização P27
	//SX3->( DbSetOrder( 2 ) )

	For _xn := 1 To Len( _aAcolsN1 )
		//SX3->( DbSeek( _aAcolsN1[_xn] ) )

		_nUsado := _nUsado + 1

		//If ! Alltrim( SX3->X3_CAMPO ) $ 'N1_CBASE|N1_AQUISIC'
		If ! Alltrim( GetSx3Cache(_aAcolsN1[_xn], 'X3_CAMPO') ) $ 'N1_CBASE|N1_AQUISIC'
			//AADD( _aAlter, SX3->X3_CAMPO )
			AADD( _aAlter, GetSx3Cache(_aAcolsN1[_xn], 'X3_CAMPO') )
		EndIf

		//AADD( _nPosTp, SX3->X3_TIPO )
		AADD( _nPosTp, GetSx3Cache(_aAcolsN1[_xn], 'X3_TIPO') )
		//AADD( _aHead, { TRIM( SX3->X3_TITULO ), Alltrim( SX3->X3_CAMPO ), SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
		//                'U_FVALIDCPO("' + SX3->X3_F3 + '")', SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, "" } )
		AADD( _aHead, { ALLTRIM( GetSx3Cache(_aAcolsN1[_xn], 'X3_TITULO') ), Alltrim( GetSx3Cache(_aAcolsN1[_xn], 'X3_CAMPO') ), ;
								 GetSx3Cache(_aAcolsN1[_xn], 'X3_PICTURE'), GetSx3Cache(_aAcolsN1[_xn], 'X3_TAMANHO'), ;
								 GetSx3Cache(_aAcolsN1[_xn], 'X3_DECIMAL'), 'U_FVALIDCPO("' + GetSx3Cache(_aAcolsN1[_xn], 'X3_F3') + '")', ;
								 GetSx3Cache(_aAcolsN1[_xn], 'X3_USADO'), GetSx3Cache(_aAcolsN1[_xn], 'X3_TIPO'), GetSx3Cache(_aAcolsN1[_xn], 'X3_F3'), "" } )
	Next _xn

	For _xn := 1 To Len( _aAcolsN3 )
		//SX3->( DbSeek( _aAcolsN3[_xn] ) )

		_nUsado := _nUsado + 1

		//If ! Alltrim( SX3->X3_CAMPO ) $ 'N3_TIPO|N3_CCONTAB|N3_TXDEPR1'
			//AADD( _aAlter, SX3->X3_CAMPO )
		If ! Alltrim( _aAcolsN3[_xn] ) $ 'N3_TIPO|N3_CCONTAB|N3_TXDEPR1'
			AADD( _aAlter, _aAcolsN3[_xn] )
		EndIf

		//AADD( _nPosTp, SX3->X3_TIPO )
		//AADD( _aHead, { TRIM( SX3->X3_TITULO ), Alltrim( SX3->X3_CAMPO ), SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
		//                'U_FVALIDCPO("' + SX3->X3_F3 + '")', SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, "" } )
		AADD( _nPosTp, GetSx3Cache(_aAcolsN3[_xn], 'X3_TIPO') )
		AADD( _aHead, { ALLTRIM( GetSx3Cache(_aAcolsN3[_xn], 'X3_TITULO') ), Alltrim( GetSx3Cache(_aAcolsN3[_xn], 'X3_CAMPO') ), ;
								 GetSx3Cache(_aAcolsN3[_xn], 'X3_PICTURE'), GetSx3Cache(_aAcolsN3[_xn], 'X3_TAMANHO'), ;
								 GetSx3Cache(_aAcolsN3[_xn], 'X3_DECIMAL'), 'U_FVALIDCPO("' + GetSx3Cache(_aAcolsN3[_xn], 'X3_F3') + '")', ;
								 GetSx3Cache(_aAcolsN3[_xn], 'X3_USADO'), GetSx3Cache(_aAcolsN3[_xn], 'X3_TIPO'), GetSx3Cache(_aAcolsN3[_xn], 'X3_F3'), "" } )
	Next _xn
	//Fim - Thais Paiva - Compatibilização P27

	If nRadio = 2
		_aDados := { Array( _nUsado + 1 ) }
		_aDados[1, _nUsado + 1] := .F.
	Else
		_aDados := {}
	EndIf

	If nRadio = 2
		For _xn := 1 To Len( _aHead )
			If _nPosTp[_xn] = 'N'
				_aDados[1][_xn] := 0
			ElseIf _nPosTp[_xn] = 'D'
				_aDados[1][_xn] := dDataBase
			Else
				_aDados[1][_xn] := Space( _aHead[_xn][4] )
			EndIf
		Next _xn
	Else
		For _xn := 1 To ( Len( _aCposN1[1] ) - 1 )
			AADD( _aDados, Array( _nUsado + 1 ) )
			For _xd := 1 To Len( _aHead )
				_aDados[_xn][_xd] := If( _xd <= Len( _aCposN1 ), _aCposN1[_xd][_xn + 1], _aCposN3[_xd - ( Len( _aCposN1 ))][_xn + 1] ) 

				If _aHead[_xd][2] = "N3_VORIG1"
					_nTotSzp := _nTotSzp + _aDados[_xn][_xd]
				EndIf
				If _aHead[_xd][2] = "N1_GRUPO"
					_cGrupo := _aDados[_xn][_xd]
				EndIf
				If _aHead[_xd][2] = "N1_CBASE" .And. aScan( _aCBasePri, _cGrupo ) = 0
					AADD( _aCBasePri, _cGrupo  )

					_cQry := " SELECT MAX( N1_CBASE ) N1_CBASE FROM " + RETSQLNAME( "SN1" ) + " (NOLOCK) WHERE "
					_cQry += " D_E_L_E_T_ = ' ' AND N1_FILIAL = '" + xFilial( "SN1" ) + "' AND "
					_cQry += " SUBSTRING( N1_CBASE, 1, 4 ) = '" + _cGrupo + "' "
					_cQry += " ORDER BY N1_CBASE "

					_cQry := ChangeQuery( _cQry )

					If Select( "TMP" ) > 0; TMP->( DbCloseArea() ); EndIf
					DbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQry ), "TMP", .T., .F. )

					TMP->( DbGoTop() )

					If Select( "TMP" ) > 0
						_aDados[_xn][_xd] := _cGrupo + Soma1( Substr( TMP->N1_CBASE, 5, 6  ) )
					Else
						_aDados[_xn][_xd] := _cGrupo + "000001"
					EndIf
					AADD( _aCBaseCod, _aDados[_xn][_xd] )
				ElseIf _aHead[_xd][2] = "N1_CBASE" .And. aScan( _aCBasePri, _cGrupo ) > 0
					_aDados[_xn][_xd] := Substr( _aCBaseCod[aScan( _aCBasePri, _cGrupo )], 1, 4 ) + Soma1( Substr( _aCBaseCod[aScan( _aCBasePri, _cGrupo )], 5, 6 ) )
					_aCBaseCod[aScan( _aCBasePri, _cGrupo )] := _aDados[_xn][_xd]
				EndIf
			Next _xd
			_aDados[1, _nUsado + 1] := .F.
		Next _xn
	EndIf

	_cTitulo := 'Preparar Importação'

	DEFINE Font _oFont Name "Arial"   Size 0, -11 Bold
	DEFINE Font _lFont Name "Calibri" Size 0, -10 Bold
	DEFINE Font _cFont Name "Calibri" Size 0, -40 Bold

 	DEFINE MSDIALOG _oWnd FROM -1, -1 TO 690, 1368 TITLE OemToAnsi( _cTitulo ) COLOR CLR_RED OF _oWnd Pixel Style DS_MODALFRAME

 	_oWnd:lEscClose  := .F.
	_oWnd:lMaximized := .T.

	@ 032, 001 TO 060, 715 OF _oWnd PIXEL

	@ 038, 300 Say OemToAnsi( "Valor Total" ) Font _oFont COLOR CLR_HBLUE OF _oWnd Pixel
	@ 037, 345 MsGet _oGetTot Var _nTotSzp Picture "@E 999,999,999,999.99" Size 080, 010 Pixel When .F.

	_oAtuSn := MsNewGetDados():New( _nTop, _nLeft, _nBottom, _nRight, _nStyle, _cLinhaOk, _cTudoOk,;
	                             /*[ cIniCpos]*/, _aAlter, /*[ nFreeze]*/, _nMax, /*_cFieldOk*/,;
	                             /*[ cSuperDel]*/, _cDelOk, _oWnd, _aHead, _aDados, /*_uChange*/, /*[ cTela]*/ )

    ACTIVATE MSDIALOG _oWnd ON INIT ( EnchoiceBar( _oWnd, { || _bOk := .T., ( _bOk := FCONFIRATF(), If( _bOk, _oWnd:End(), ) ) }, { || _oWnd:End() },, @_aButtons ) )

Return _bOk

***************************
Static Function FCONFIRATF
***************************

	Local _lRetFinal := .T.
	Local nDeprAcum := 0
	Local nValAquis := 0
	Local lBaixa    := .F.
	Local cBase     := "" 
	Local cSerie    := ""
	Local cNota     := ""
	Local cChapa    := ""

	For _xn := 1 To Len( _oAtuSn:aCols )
		lBaixa := .F.
		If ! _oAtuSn:aCols[_xn][_nUsado + 1]
			_nLenExec++
		EndIf
		For _xd := 1 To Len( _oAtuSn:aHeader )
			If Alltrim( _oAtuSn:aHeader[_xd][2] ) = "N3_VRDACM1"
				nDeprAcum := _oAtuSn:aCols[_xn][_xd]
			ElseIf Alltrim( _oAtuSn:aHeader[_xd][2] ) = "N3_VORIG1"
				nValAquis := _oAtuSn:aCols[_xn][_xd]
			ElseIf Alltrim( _oAtuSn:aHeader[_xd][2] ) = "N1_CBASE"
				cBase 	:= _oAtuSn:aCols[_xn][_xd]
			ElseIf Alltrim( _oAtuSn:aHeader[_xd][2] ) = "N1_NSERIE"
				cSerie 	:= _oAtuSn:aCols[_xn][_xd]
			ElseIf Alltrim( _oAtuSn:aHeader[_xd][2] ) = "N1_NFISCAL"
				cNota	:= _oAtuSn:aCols[_xn][_xd]
			ElseIf Alltrim( _oAtuSn:aHeader[_xd][2] ) = "N1_CHAPA"
				cChapa	:= _oAtuSn:aCols[_xn][_xd]
			EndIf

			//N1_NSERIE, N1_NFISCAL

		//cBase,cTipo,cTpSaldo,cMotivo,cNf,cSerieNf
			If Substr( _oAtuSn:aHeader[_xd][2], 1, 2 ) = 'N1' .And. ! _oAtuSn:aCols[_xn][_nUsado + 1]
				If Alltrim( _oAtuSn:aHeader[_xd][2] ) = "N1_NFISCAL" .OR. Alltrim( _oAtuSn:aHeader[_xd][2] ) = "N1_NSERIE" .OR. Alltrim( _oAtuSn:aHeader[_xd][2] ) = "N1_CHAPA"
					AADD( _aSn1, { _oAtuSn:aHeader[_xd][2], _oAtuSn:aCols[_xn][_xd], NIL } )
				ElseIf Empty( _oAtuSn:aCols[_xn][_xd] )
					Aviso( 'Atenção', 'O campo ' + Alltrim( _oAtuSn:aHeader[_xd][2] ) + ' não foi preenchido na linha ' + Alltrim( Str( _xn ) ) + ', verifique.', { 'Voltar' } )
					_lRetFinal := .F.
					_aSn1      := {}
					_aSn3      := {}
					Exit
				EndIf
				AADD( _aSn1, { _oAtuSn:aHeader[_xd][2], _oAtuSn:aCols[_xn][_xd], NIL } )
				// N3_VRDMES1 ,N3_VRDACM1
			ElseIf ! _oAtuSn:aCols[_xn][_nUsado + 1]
				If Empty( _oAtuSn:aCols[_xn][_xd] )
					If Alltrim( _oAtuSn:aHeader[_xd][2] ) = "N3_TXDEPR1"
						If SNG->( DbSeek( xFilial( 'SNG' ) + _oAtuSn:aCols[_xn][1] ) )
							If SNG->NG_TXDEPR1 = 0
								AADD( _aSn3, { _oAtuSn:aHeader[_xd][2], _oAtuSn:aCols[_xn][_xd], NIL } )
							EndIf
						EndIf
					ElseIf Alltrim( _oAtuSn:aHeader[_xd][2] ) = "N3_DTBAIXA"
						AADD( _aSn3, { _oAtuSn:aHeader[_xd][2], _oAtuSn:aCols[_xn][_xd], NIL } )
					ElseIf Alltrim( _oAtuSn:aHeader[_xd][2] ) = "N3_VRDMES1"
						AADD( _aSn3, { _oAtuSn:aHeader[_xd][2], _oAtuSn:aCols[_xn][_xd], NIL } )
					ElseIf Alltrim( _oAtuSn:aHeader[_xd][2] ) = "N3_VRDACM1"
						AADD( _aSn3, { _oAtuSn:aHeader[_xd][2], _oAtuSn:aCols[_xn][_xd], NIL } )
					Else
						Aviso( 'Atenção', 'O campo ' + Alltrim( _oAtuSn:aHeader[_xd][2] ) + ' não foi preenchido na linha ' + Alltrim( Str( _xn ) ) + ', verifique.', { 'Voltar' } )
						_lRetFinal := .F.
						_aSn1      := {}
						_aSn3      := {}
						Exit
					EndIf
				EndIf
				AADD( _aSn3, { _oAtuSn:aHeader[_xd][2], _oAtuSn:aCols[_xn][_xd], NIL } )
			EndIf
		Next _xd
		If ! _lRetFinal
			Exit
		EndIf
		If _lRetFinal
			Begin Transaction
				Processa( { | _lEnd | FIncluiAtv( @_lEnd ) }, 'Incluindo Registro(s)', "Aguarde...", .T. )
			End Transaction

			_aSn1     := {}
			_aSn3     := {}
			_nLenExec := 0
		EndIf

//		If nDeprAcum >= nValAquis
//			If !U_EAATF036(cBase,cNota,cSerie)
//				Aviso( 'Atenção', 'A Baixa do Bem:  ' + Alltrim(cBase) + ' não foi realizada , verifique.', { 'Voltar' } )
//				// não foi possivel baixar, incluir uma exclusao do item. e incluir uma msg.
//			EndIf
//		EndIf

/*
pesquisar o header N3_VRDACM1 + o header N3_VORIG1 
se o valor da N3_VRDACM1 >= N3_VORIG1
EXECUTAR EXEC AUTO
User Function EAATF036(cBase,cMotivo,cNf,cSerieNf)
Local aArea := GetArea()
Local cBase := "0000000005"
Local cItem := "0001"
Local cTipo := "01"
Local cTpSaldo := "1"
Local cBaixa := "0"
Local nQtdAtu := 1
Local nQtdBaixa := 1
*/

	Next _xn

Return _lRetFinal

***********************
User Function FCDELETOK
***********************

	Local _lRetDel := .T.

	_nTotSzp := 0

	For _xn := 1 To Len( _oAtuSn:aCols )
		If ! _oAtuSn:aCols[_xn][_nUsado + 1]
			If _xn <> n
				_nTotSzp := _nTotSzp + _oAtuSn:aCols[_xn][aScan( _oAtuSn:aHeader, { |x| Alltrim( x[ 2 ] ) = "N3_VORIG1" } )]
			EndIf
		ElseIf _oAtuSn:aCols[n][_nUsado + 1]
			If _xn = n 
				_nTotSzp := _nTotSzp + _oAtuSn:aCols[_xn][aScan( _oAtuSn:aHeader, { |x| Alltrim( x[ 2 ] ) = "N3_VORIG1" } )]
			EndIf
		EndIf
	Next _xn

	_oGetTot:Refresh()

Return _lRetDel

***********************
User Function FCLINHAOK
***********************

	Local _lRetLinhaOk := .T., _xn

	For _xn := 1 To Len( _oAtuSn:aHeader )
		If Empty( _oAtuSn:aCols[n][_xn] ) 
				If Alltrim( _oAtuSn:aHeader[_xn][2] ) = "N3_TXDEPR1"
					If SNG->( DbSeek( xFilial( 'SNG' ) + _oAtuSn:aCols[n][1] ) )
						If SNG->NG_TXDEPR1 = 0
							Exit
						EndIf
					EndIf
				Elseif Alltrim( _oAtuSn:aHeader[_xn][2] ) = "N3_VRDMES1" 
					_oAtuSn:aCols[n][_xn] := 0
				Elseif Alltrim( _oAtuSn:aHeader[_xn][2] ) = "N3_VRDACM1"
					_oAtuSn:aCols[n][_xn] := 0
				EndIf
				If (Alltrim(_oAtuSn:aHeader[_xn][2]) <> "N1_NFISCAL" .AND. Alltrim(_oAtuSn:aHeader[_xn][2]) <> "N1_NSERIE" .AND. Alltrim( _oAtuSn:aHeader[_xn][2] ) <> "N1_CHAPA" .AND. Alltrim( _oAtuSn:aHeader[_xn][2] ) <> "N3_VRDMES1" .AND. Alltrim( _oAtuSn:aHeader[_xn][2] ) <> "N3_VRDACM1")
					Aviso( 'Atenção', 'O campo ' + Alltrim( _oAtuSn:aHeader[_xn][2] ) + ' não foi preenchido, verifique.', { 'Voltar' } )
					_lRetLinhaOk := .F.
					Exit
				EndIf		
		EndIf
	Next _xn

Return _lRetLinhaOk

*********************************
User Function FVALIDCPO( _lPar3 )
*********************************
Local cAliaxb := GetNextAlias()
Local _lRetCpo := .T.
Local _aAreaXB := GetArea()
	If ! Empty( _lPar3 )
		BeginSql Alias cAliaxb //SXB->( DbSetOrder( 1 ) )
			SELECT XB_CONTEM AS CONTEM
			FROM %table:SXB% 
			WHERE XB_FILIAL >= %Exp:xFilial("SXB")%
			AND XB_ALIAS = %Exp:_lPar3%
		EndSql
		DbSelectArea(cAliaxb)
		(cAliaxb)->(DbGoTop())
		If cAliaxb->(!EOF()) //SXB->( DbSeek( _lPar3 ) )
			//If Alltrim( SXB->XB_ALIAS ) = Alltrim( _lPar3 )
			_lPar3 := Alltrim( (cAliaxb)->CONTEM )
			_lRetCpo := ExistCpo( _lPar3, &__ReadVar )
			//Else
				//_lRetCpo := ExistCpo( 'SX5', Alltrim( _lPar3 ) + &__ReadVar )
			//EndIf
		Else
			_lRetCpo := ExistCpo( 'SX5', Alltrim( _lPar3 ) + &__ReadVar )
		EndIf
	EndIf

	If _lRetCpo
		If __ReadVar = "M->N1_GRUPO"
			_cQry := " SELECT MAX( N1_CBASE ) N1_CBASE FROM " + RETSQLNAME( "SN1" ) + " (NOLOCK) WHERE "
			_cQry += " D_E_L_E_T_ = ' ' AND N1_FILIAL = '" + xFilial( "SN1" ) + "' AND "
			_cQry += " SUBSTRING( N1_CBASE, 1, 4 ) = '" + &__ReadVar + "' "
			_cQry += " ORDER BY N1_CBASE "

			_cQry := ChangeQuery( _cQry )

			If Select( "TMP" ) > 0; TMP->( DbCloseArea() ); EndIf
			DbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQry ), "TMP", .T., .F. )

			TMP->( DbGoTop() )

 			_cCbase := aScan( _aCBase, &__ReadVar) // + Soma1( Substr( TMP->N1_CBASE, 5, 6  ) ) ) //comentado por Thiago Góes 02/04/2019

			If Select( "TMP" ) > 0 .Or. _cCbase > 0
				If _cCbase = 0
					_oAtuSn:aCols[n][aScan( _oAtuSn:aHeader, { |x| Alltrim( x[ 2 ] ) = "N1_CBASE"  } )] := &__ReadVar + Soma1( Substr( TMP->N1_CBASE, 5, 6  ) )
					If _cCbase = 0
						AADD( _aCBase, &__ReadVar + Soma1( Substr( TMP->N1_CBASE, 5, 6  ) ) )
					Else
					   	If aScan( _oAtuSn:aHeader, { |x| Alltrim( x[ 2 ] ) = "N1_CBASE"  } ) >0 //Incluido por Thiago Góes 01/04/2019 
					   		_aCBase[_cCbase] := &__ReadVar + Soma1( Substr( TMP->N1_CBASE, 5, 6  ) ) 
					   	EndIf
					EndIf
				Else
					_oAtuSn:aCols[n][aScan( _oAtuSn:aHeader, { |x| Alltrim( x[ 2 ] ) = "N1_CBASE"  } )] := Substr( _aCBase[_cCbase], 1, 4 ) + StrZero( Val( Substr( _aCBase[_cCbase], 5, 6 ) ) + 1, 6 )
					If _cCbase = 0
						AADD( _aCBase, Substr( _aCBase[_cCbase], 1, 4 ) + StrZero( Val( Substr( _aCBase[_cCbase], 5, 6 ) ) + 1, 6 ) )
					Else
						If aScan( _oAtuSn:aHeader, { |x| Alltrim( x[ 2 ] ) = "N1_CBASE"  } ) >0 //Incluido por Thiago Góes 01/04/2019 
							_aCBase[_cCbase] := Substr( _aCBase[_cCbase], 1, 4 ) + StrZero( Val( Substr( _aCBase[_cCbase], 5, 6 ) ) + 1, 6 )
						EndIf
					EndIf
				EndIf
			Else
				_oAtuSn:aCols[n][aScan( _oAtuSn:aHeader, { |x| Alltrim( x[ 2 ] ) = "N1_CBASE"  } )] := &__ReadVar + "000001"
				If _cCbase = 0
					AADD( _aCBase, &__ReadVar + "000001" )
				Else
					_aCBase[_cCbase] := &__ReadVar + "000001"
				EndIf
			EndIf
			//_oAtuSn:aCols[n][aScan( _oAtuSn:aHeader, { |x| Alltrim( x[ 2 ] ) = "N1_ITEM"    } )] := '0001'
			_oAtuSn:aCols[n][aScan( _oAtuSn:aHeader, { |x| Alltrim( x[ 2 ] ) = "N3_TIPO"    } )] := '01'
			_oAtuSn:aCols[n][aScan( _oAtuSn:aHeader, { |x| Alltrim( x[ 2 ] ) = "N3_CCONTAB" } )] := Posicione( 'SNG', 1, xFilial( 'SNG' ) + &__ReadVar, 'NG_CCONTAB' )
			_oAtuSn:aCols[n][aScan( _oAtuSn:aHeader, { |x| Alltrim( x[ 2 ] ) = "N3_TXDEPR1" } )] := Posicione( 'SNG', 1, xFilial( 'SNG' ) + &__ReadVar, 'NG_TXDEPR1' )
			_oAtuSn:Refresh()
		EndIf
		If __ReadVar = 'M->N3_VORIG1'
			If ! POSITIVO( &__ReadVar )
				Return .F.
			EndIf
			_nTotSzp := &__ReadVar
			For _xn := 1 To Len( _oAtuSn:aCols )
				If _xn <> n
					_nTotSzp := _nTotSzp + _oAtuSn:aCols[_xn][aScan( _oAtuSn:aHeader, { |x| Alltrim( x[ 2 ] ) = "N3_VORIG1" } )]
				EndIf
			Next _xn
			_oGetTot:Refresh()			
		EndIf
		If __ReadVar = 'M->N1_ITEM'
			If n = 1
				Aviso( 'Aviso', 'Este campo não pode ser alterado no primeiro item do registro.', { 'Sair' } )
				Return .F.
			EndIf
			_cNovaCbase := FWInputBox( 'Informe o no código do bem com base no anterior.', _oAtuSn:aCols[n][aScan( _oAtuSn:aHeader, { |x| Alltrim( x[ 2 ] ) = "N1_CBASE" } )] )
			If Empty( _cNovaCbase )
				Aviso( 'Aviso', 'Novo código não informado, refaça a operação.', { 'Voltar' } )
				Return .F.
			ElseIf Substr( _cNovaCbase, 1, 4 ) <> _oAtuSn:aCols[n][aScan( _oAtuSn:aHeader, { |x| Alltrim( x[ 2 ] ) = "N1_GRUPO" } )]
				Aviso( 'Aviso', 'Novo código não respeitou a regra de preenchimento, refaça a operação.', { 'Voltar' } )
				Return .F.
			ElseIf aScan( _oAtuSn:aCols, _cNovaCbase )
				Aviso( 'Aviso', 'Novo código já existe no registro, refaça a operação.', { 'Voltar' } )
				Return .F.
			Else
				_oAtuSn:aCols[n][aScan( _oAtuSn:aHeader, { |x| Alltrim( x[ 2 ] ) = "N1_CBASE" } )] := Alltrim( _cNovaCbase )
				_oAtuSn:Refresh()
			EndIf
		EndIf
	EndIf
RestArea(_aAreaXB)
Return _lRetCpo

*********************************
Static Function FINCCPO( _nPar1 )
*********************************

	If _nPar1 = 1

		If _oTree:Nivel() > 1 .Or. MsgYesNo( "Nenhum campo foi selecionado, deseja incluir todos os campos do arquivo " + _oTree:GetPrompt( .T. ) + " ?" )

			_nItens := Val( _oTree:GetCargo() )

			If _oTree:Nivel() > 1

				_nItens++
				_nItAdd++

				_oList:ADD( _oTree:GetPrompt( .T. ), _nItAdd + _nItObrigat )

				_oTree:TreeSeek( _oTree:GetCargo() )
				_oTree:DelItem()

				_oList:Refresh()

			Else

				If ! _oTree:TreeSeek( StrZero( _nItens + 1, 3 ) )
					Do While .T.
						_nItens++
						If _oTree:TreeSeek( StrZero( _nItens + 1, 3 ) )  .Or. ( If( Substr( _oTree:GetPrompt( .T. ), 1, 2 ) = 'N1', ( _nItens > _nUltCpoN1 ), ( _nItens > _nUltCpoN3 ) ) )
							Exit
						EndIf
					EndDo
				EndIf

				While ( _oTree:Nivel() > 1 )

					_nItens++
					_nItAdd++

					_oList:ADD( _oTree:GetPrompt( .T. ), _nItAdd + _nItObrigat )

					_oTree:TreeSeek( _oTree:GetCargo() )
					_oTree:DelItem()

					_oList:Refresh()

					If ! _oTree:TreeSeek( StrZero( _nItens + 1, 3 ) )
						Do While .T.
							_nItens++
							If _oTree:TreeSeek( StrZero( _nItens + 1, 3 ) )  .Or. ( If( Substr( _oTree:GetPrompt( .T. ), 1, 2 ) = 'N1', ( _nItens > _nUltCpoN1 ), ( _nItens > _nUltCpoN3 ) ) )
								Exit
							EndIf
						EndDo
					EndIf

				End

			EndIf

		EndIf

	Else

		If Substr( _oTree:GetPrompt( .T. ), 1, 2 ) = 'N1' .Or. Substr( _oTree:GetPrompt( .T. ), Len( _oTree:GetPrompt( .T. ) ) - 1, 2 ) = 'N1'

			_nItSn1++

			If ! _oTree:TreeSeek( StrZero( _nItSn1, 3 ) )
				Do While .T.
					_nItSn1++
					If _oTree:TreeSeek( StrZero( _nItSn1, 3 ) ) .Or. _nItSn1 > _nUltCpoN1
						Exit
					EndIf
				EndDo
			EndIf

			While ( _oTree:Nivel() > 1 )

				_nItAdd++

				_oList:ADD( _oTree:GetPrompt( .T. ), _nItAdd + _nItObrigat )

				_oTree:TreeSeek( _oTree:GetCargo() )
				_oTree:DelItem()

				_oList:Refresh()

				_nItSn1++

				If ! _oTree:TreeSeek( StrZero( _nItSn1, 3 ) )
					Do While .T.
						_nItSn1++
						If _oTree:TreeSeek( StrZero( _nItSn1, 3 ) ) .Or. _nItSn1 > _nUltCpoN1
							Exit
						EndIf
					EndDo
				EndIf

			End

		ElseIf Substr( _oTree:GetPrompt( .T. ), 1, 2 ) = 'N3' .Or. Substr( _oTree:GetPrompt( .T. ), Len( _oTree:GetPrompt( .T. ) ) - 1, 2 ) = 'N3'

			_nItSn3++

			If ! _oTree:TreeSeek( StrZero( _nItSn3, 3 ) )
				Do While .T.
					_nItSn3++
					If _oTree:TreeSeek( StrZero( _nItSn3, 3 ) ) .Or. _nItSn3 > _nUltCpoN3
						Exit
					EndIf
				EndDo
			EndIf

			While ( _oTree:Nivel() > 1 )

				_nItAdd++

				_oList:ADD( _oTree:GetPrompt( .T. ), _nItAdd + _nItObrigat )

				_oTree:TreeSeek( _oTree:GetCargo() )
				_oTree:DelItem()

				_oList:Refresh()

				_nItSn3++

				If ! _oTree:TreeSeek( StrZero( _nItSn3, 3 ) )
					Do While .T.
						_nItSn3++
						If _oTree:TreeSeek( StrZero( _nItSn3, 3 ) ) .Or. _nItSn3 > _nUltCpoN3
							Exit
						EndIf
					EndDo
				EndIf

			End

		EndIf

	EndIf

Return

*********************************
Static Function FREMCPO( _nPar2 )
*********************************

	Local _xn, _lPriSn3 := .T., _lPriSn1 := .T., _nCpoObrig := 0

	If Len( _oList:aItems ) > 0
		If _nPar2 = 1
			_nCpoObrig := aScan( _aCpoObrigat, _oList:aItems[_oList:nAt] )
			If _oList:aItems[_oList:nAt] = If( _nCpoObrig = 0, 'SEMCAMPO', _aCpoObrigat[_nCpoObrig] )
				Aviso( "Atenção", "Este campo é obrigatório, não pode ser removido.", { "Voltar" } )
				Return
			EndIf
			If Substr( _oList:aItems[_oList:nAt], 1, 2 ) = 'N1'
				_oTree:AddItem( _oList:aItems[_oList:nAt], StrZero( _aCpoN1[aScan( _aCpoN1, _oList:aItems[_oList:nAt] ) + 1 ], 3 ), "MDIRUN" ,,,, 2 )
				_oList:Del( _oList:nAt )
			ElseIf Substr( _oList:aItems[_oList:nAt], 1, 2 ) = 'N3'
				_oTree:AddItem( _oList:aItems[_oList:nAt], StrZero( _aCpoN3[aScan( _aCpoN3, _oList:aItems[_oList:nAt] ) + 1 ], 3 ), "MDIRUN" ,,,, 2 )
				_oList:Del( _oList:nAt )
			EndIf
		Else
			_xn := Len( _oList:aItems )
			Do While _xn > 1
				Do While _xn > 1
					If Substr( _oList:aItems[_oList:nAt], 1, 2 ) = 'N1'
						If _lPriSn1
							_oTree:TreeSeek( '001' )
							_lPriSn1 := .F.
						EndIf
						If _oList:aItems[_oList:nAt] <> If( aScan( _aCpoObrigat, _oList:aItems[_oList:nAt] ) = 0, '', _aCpoObrigat[aScan( _aCpoObrigat, _oList:aItems[_oList:nAt] )] )
							_xn := Len( _oList:aItems )
							_oTree:AddItem( _oList:aItems[_xn], StrZero( _aCpoN1[aScan( _aCpoN1, _oList:aItems[_oList:nAt] ) + 1 ], 3 ), "MDIRUN" ,,,, 2 )
							_oList:Del( _oList:nAt )
						Else
							_xn := _xn - 1
						EndIf
					Else
						Exit
					EndIf
				EndDo
				Do While _xn > 1
					If Substr( _oList:aItems[_oList:nAt], 1, 2 ) = 'N3'
						If _lPriSn3
							_oTree:TreeSeek( StrZero( _nIniN3, 3 ) )
							_lPriSn3 := .F.
						EndIf
						If _oList:aItems[_oList:nAt] <> If( aScan( _aCpoObrigat, _oList:aItems[_oList:nAt] ) = 0, '', _aCpoObrigat[aScan( _aCpoObrigat, _oList:aItems[_oList:nAt] )] )
							_xn := Len( _oList:aItems )
							_oTree:AddItem( _oList:aItems[_xn], StrZero( _aCpoN3[aScan( _aCpoN3, _oList:aItems[_oList:nAt] ) + 1 ], 3 ), "MDIRUN" ,,,, 2 )
							_oList:Del( _oList:nAt )
						Else
							_xn := _xn - 1
						EndIf
					Else
						Exit
					EndIf
				EndDo
			EndDo
		EndIf
		_oList:Refresh()
	EndIf

Return
