/*/
==================================================================================
Data      : 21/05/2018
----------------------------------------------------------------------------------
Autor     : Daniel Machado
----------------------------------------------------------------------------------
Descricao : Gerar relatório em DBF com dados da SD3.
----------------------------------------------------------------------------------
Partida   : Menu de usuário
==================================================================================
/*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.Ch"
#INCLUDE "RWMAKE.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FILEIO.ch"

User Function RDORRA01

	Local _cPerg := "RDORRELD3", _lOk := .F., _cPath := "C:\REL_SD3\", _cVet1 := "" , _cVet2 := ""
	Local _aArea := GetArea(), _cMensagem := ""

	Private _aSelFil := xFilial( "SD3" )
	Private _cEOL := "CHR(13)+CHR(10)", _aTelMark := {}, _cAliasDtc := "", _aStrutura := {}, _aStru2 := {}
	Private _lAllPar2 := .F., _lAllPar8 := .F., _lAllPar9 := .F., _lCancSele2 := .F., _lCancSele8 := .F., _lCancSele9 := .F.

	MONTADIR( _cPath )

	//FAjuSx1( _cPerg ) //Thais Paiva - Compatibilização P27

	_lOk := Pergunte( _cPerg, .T. )

	If ! _lOk .Or. ! U_FTSTPERI()
		Return
	EndIf

	If MV_PAR01 = 1
		_cMensagem := "Gerando Relatório Sintético"
	ElseIf MV_PAR01 = 2
		_cMensagem := "Gerando Relatório Analítico"
	ElseIf MV_PAR01 = 3
		_cMensagem := "Gerando Relatório Duplicados"
	EndIf

	If MV_PAR02 = 1
		_lCancSele2 := .F.
		_aSelFil    := FRDORREL2( 2 )
		If ! _aSelFil[2]
			Return
		Else
			_aSelFil := _aSelFil[1]
		EndIf
	EndIf
	If MV_PAR08 = 1
		_lCancSele8 := .F.
		_cVet1      := FRDORREL2( 8 )
		If ! _cVet1[2]
			Return
		Else
			_cVet1 := _cVet1[1]
		EndIf
	EndIf
	If MV_PAR09 = 1
		_lCancSele9 := .F.
		_cVet2      := FRDORREL2( 9 )
		If ! _cVet2[2]
			Return
		Else
			_cVet2 := _cVet2[1]
		EndIf
	EndIf

	Processa( { |_lEnd| FRDORREL3( @_lEnd, _cVet1 , _cVet2 ) }, _cMensagem, "Aguarde...", .F. )

	RestArea( _aArea )

Return

********************************************************
Static Function FRDORREL3( _lEnd, _cTpProd, _cTpMovim )
********************************************************

	Local _cQry, _cLin, _cColunas, _cFilial := If( MV_PAR02 = 1 .And. _lCancSele2, _aSelFil, + "'" + xFilial( "SD3" ) + "'" )
	Local _lArqCsv, _cTimeIni
	

	ProcRegua( 0 )

	FErase( "C:\REL_SD3\DELREL.BAT" )
	_lArqCsv := FCreate( "C:\REL_SD3\DELREL.BAT", 0 )
	_cLin    := "ECHO OFF" + &_cEOL
	//_cLin    += "del c:\rel_sd3\*relsd3*.dbf" + &_cEOL 9634835 - Thais Paiva
	_cLin    += "del c:\rel_sd3\*relsd3*.csv" + &_cEOL 
	
	//Início - 9634835 - Thais Paiva
	If _lArqCsv == -1
		MsgStop('Erro na criação do arquivo : FERROR '+str(ferror(),4))
	Else
	//Fim - 9634835 - Thais Paiva
		fWrite( _lArqCsv, _cLin )
		fClose( _lArqCsv )
	EndIf //9634835 - Thais Paiva

	Shellexecute( "Open", "C:\REL_SD3\DELREL.BAT", " /k dir ", "c:\", 0 )

	If MV_PAR01 >= 2
		_cColunas := " D3_FILIAL Filial, D3_TM TpMoviment, F5_TEXTO DescriTM, D3_COD Produto, B1_DESC DescriPROD, D3_QUANT Quantidade, D3_CONTA Conta, CT1_DESC01 DescriCONT, D3_GRUPO Tipo, BM_DESC DescriGRU," + &_cEOL +;
		             " D3_XFORN Fornecedor, D3_CC CentroCust, D3_XIDEXT Identific, D3_DOC Documento, D3_EMISSAO Emissao, " + &_cEOL +;
		             " CASE WHEN D3_TM >= '501' THEN D3_CUSTO1 * - 1 ELSE D3_CUSTO1 END AS CustoM1 " + &_cEOL
	ElseIf MV_PAR01 = 1
		_cColunas := " D3_FILIAL Filial, D3_TM TpMoviment, F5_TEXTO DescriTM, D3_CC CCusto, D3_XFILORI FILORIG, D3_XFILDES FILDEST," + &_cEOL +;
		             " CASE WHEN D3_TM >= '501' THEN SUM( D3_CUSTO1 ) * - 1 ELSE SUM( D3_CUSTO1 ) END AS CustoM1 " + &_cEOL
	EndIf

	If MV_PAR07 = "02"
		_cColunas := _cColunas + If( MV_PAR01 >= 2, ", D3_CUSTO2 CustoM2 ", ", SUM( D3_CUSTO2 ) CustoM2 " ) + &_cEOL
	ElseIf MV_PAR07 = "03"
		_cColunas := _cColunas + If( MV_PAR01 >= 2, ", D3_CUSTO3 CustoM3 ", ", SUM( D3_CUSTO3 ) CustoM3 " ) + &_cEOL
	ElseIf MV_PAR07 = "04"
		_cColunas := _cColunas + If( MV_PAR01 >= 2, ", D3_CUSTO4 CustoM4 ", ", SUM( D3_CUSTO4 ) CustoM4 " ) + &_cEOL
	ElseIf MV_PAR07 = "05"
		_cColunas := _cColunas + If( MV_PAR01 >= 2, ", D3_CUSTO5 CustoM5 ", ", SUM( D3_CUSTO5 ) CustoM5 " ) + &_cEOL
	EndIf

	If MV_PAR01 >= 2
		_cColunas  := _cColunas + ", D3_ESTORNO Estorno, D3_XCONSIG Consignado, D3_XFILORI FilOrigem, D3_XFILDES FilDestino, D3_XCONTA CTAContab"  + &_cEOL
	ElseIf MV_PAR01 = 1
		_cColunas  := _cColunas + ", D3_GRUPO Tipo, BM_DESC DescriGRU" + &_cEOL
	EndIf

	_cQry := " SELECT " + _cColunas
	_cQry += " FROM " + RETSQLNAME( "SD3" ) + " D3, " + RETSQLNAME( "SB1" ) + " B1, " + &_cEOL
	_cQry += RETSQLNAME( "SF5" ) + " F5, " + RETSQLNAME( "SBM" ) + " BM, " + RETSQLNAME( "CT1" ) + " CT1 " + &_cEOL
	_cQry += " WHERE " + &_cEOL

	If MV_PAR01 <> 3
		_cWhere := " D3.D_E_L_E_T_ = ' ' AND B1.D_E_L_E_T_ = ' ' AND F5.D_E_L_E_T_ = ' ' AND CT1.D_E_L_E_T_ = ' ' AND " + &_cEOL
	  	_cWhere += If( ! Empty( _cFilial ) .And. ! _lAllPar2, " D3_FILIAL IN (" + _cFilial + ") AND  " + &_cEOL, "" )
		_cWhere += " B1_FILIAL  = " + If( Empty( xFilial( "SB1" ) ), "'" + xFilial( "SB1" ) + "'", "D3_FILIAL" ) + " AND " + &_cEOL
		_cWhere += " F5_FILIAL  = " + If( Empty( xFilial( "SF5" ) ), "'" + xFilial( "SF5" ) + "'", "D3_FILIAL" ) + " AND " + &_cEOL
		_cWhere += " BM_FILIAL  = " + If( Empty( xFilial( "SBM" ) ), "'" + xFilial( "SBM" ) + "'", "D3_FILIAL" ) + " AND " + &_cEOL
		_cWhere += " CT1_FILIAL = " + If( Empty( xFilial( "CT1" ) ), "'" + xFilial( "CT1" ) + "'", "D3_FILIAL" ) + " AND " + &_cEOL
		_cWhere += " B1_COD = D3_COD AND F5_CODIGO = D3_TM AND BM_GRUPO = D3_GRUPO AND CT1_CONTA = D3_CONTA AND " + &_cEOL
		/*Início Thais Paiva 11832993
		_cWhere += " D3_EMISSAO >= '" + Dtos( MV_PAR03 ) + "' AND D3_EMISSAO <= '" + Dtos( MV_PAR04 ) + "' AND " + &_cEOL
		_cWhere += If( MV_PAR05 = 1 .AND. MV_PAR01 <> 3, " D3_ESTORNO = 'S' ", " D3_ESTORNO <> 'S' " ) + " AND " + &_cEOL
		_cWhere += If( MV_PAR06 = 2, " D3_CUSTO1 > 0 ", If( MV_PAR01 <> 3, "", " D3_CUSTO1 > 0 " ) ) + &_cEOL
		_cWhere += If( MV_PAR08 = 1 .And. _lCancSele8 .And. ! Empty( _cTpProd  ) .And. ! _lAllPar8, " AND D3_GRUPO IN (" + _cTpProd + ") " + &_cEOL, "" )
		_cWhere += If( MV_PAR09 = 1 .And. _lCancSele9 .And. ! Empty( _cTpMovim ) .And. ! _lAllPar9, " AND D3_TM    IN (" + _cTpMovim + ")" + &_cEOL, "" )*/
		_cWhere += " D3_EMISSAO >= '" + Dtos( MV_PAR03 ) + "' AND D3_EMISSAO <= '" + Dtos( MV_PAR04 ) + "' " + &_cEOL
		_cWhere += If( MV_PAR05 = 1 .AND. MV_PAR01 <> 3, "AND D3_ESTORNO = 'S' ", "AND D3_ESTORNO <> 'S' " ) + &_cEOL
		_cWhere += If( MV_PAR06 = 2, "AND D3_CUSTO1 > 0 ", If( MV_PAR01 <> 3, "", "AND D3_CUSTO1 > 0 " ) ) + &_cEOL
		_cWhere += If( MV_PAR08 = 1 .And. _lCancSele8 .And. ! Empty( _cTpProd  ) .And. ! _lAllPar8, " AND D3_GRUPO IN (" + _cTpProd + ") " + &_cEOL, "" )
		_cWhere += If( MV_PAR09 = 1 .And. _lCancSele9 .And. ! Empty( _cTpMovim ) .And. ! _lAllPar9, " AND D3_TM    IN (" + _cTpMovim + ")" + &_cEOL, "" )
		//Fim Thais Paiva 11832993

		_cQry += _cWhere
	EndIf

	If MV_PAR01 = 3
		_cQry += " D3.D_E_L_E_T_ = ' ' AND D3_XIDEXT <> ' ' AND " + &_cEOL
		_cQry += If( ! Empty( _cFilial ) .And. ! _lAllPar2, " D3_FILIAL IN (" + _cFilial + ") AND  " + &_cEOL, "" )
		_cQry += " EXISTS( SELECT D3_XIDEXT FROM " + RETSQLNAME( "SD3" ) + " SD3 " + &_cEOL
		_cQry += " WHERE " + &_cEOL
		_cQry += " SD3.D3_FILIAL = D3.D3_FILIAL AND SD3.D3_XIDEXT = D3.D3_XIDEXT AND SD3.D3_ESTORNO = D3.D3_ESTORNO " + &_cEOL
		_cQry += " GROUP BY SD3.D3_XIDEXT HAVING COUNT( SD3.D3_XIDEXT ) > 1 ) AND " + &_cEOL
		_cQry += " B1_FILIAL  = " + If( Empty( xFilial( "SB1" ) ), "'" + xFilial( "SB1" ) + "'", "D3_FILIAL" ) + " AND " + &_cEOL
		_cQry += " F5_FILIAL  = " + If( Empty( xFilial( "SF5" ) ), "'" + xFilial( "SF5" ) + "'", "D3_FILIAL" ) + " AND " + &_cEOL
		_cQry += " BM_FILIAL  = " + If( Empty( xFilial( "SBM" ) ), "'" + xFilial( "SBM" ) + "'", "D3_FILIAL" ) + " AND " + &_cEOL
		_cQry += " CT1_FILIAL = " + If( Empty( xFilial( "CT1" ) ), "'" + xFilial( "CT1" ) + "'", "D3_FILIAL" ) + " AND " + &_cEOL
		_cQry += " B1_COD = D3_COD AND F5_CODIGO = D3_TM AND BM_GRUPO = D3_GRUPO AND CT1_CONTA = D3_CONTA AND " + &_cEOL
		/*Início Thais Paiva 11832993
		_cQry += " D3_EMISSAO >= '" + Dtos( MV_PAR03 ) + "' AND D3_EMISSAO <= '" + Dtos( MV_PAR04 ) + "' AND " + &_cEOL
		_cQry += If( MV_PAR05 = 1 .AND. MV_PAR01 <> 3, " D3_ESTORNO = 'S' ", " D3_ESTORNO <> 'S' " ) + " AND " + &_cEOL
		_cQry += If( MV_PAR06 = 2, " D3_CUSTO1 > 0 ", If( MV_PAR01 <> 3, "", " D3_CUSTO1 > 0 " ) ) + &_cEOL
		_cQry += If( MV_PAR08 = 1 .And. _lCancSele8 .And. ! Empty( _cTpProd  ) .And. ! _lAllPar8, " AND D3_GRUPO IN (" + _cTpProd + ") " + &_cEOL, "" )
		_cQry += If( MV_PAR09 = 1 .And. _lCancSele9 .And. ! Empty( _cTpMovim ) .And. ! _lAllPar9, " AND D3_TM    IN (" + _cTpMovim + ")", "" )*/
		_cQry += " D3_EMISSAO >= '" + Dtos( MV_PAR03 ) + "' AND D3_EMISSAO <= '" + Dtos( MV_PAR04 ) + "' " + &_cEOL
		_cQry += If( MV_PAR05 = 1 .AND. MV_PAR01 <> 3, "AND D3_ESTORNO = 'S' ", "AND D3_ESTORNO <> 'S' " ) + &_cEOL
		_cQry += If( MV_PAR06 = 2, "AND D3_CUSTO1 > 0 ", If( MV_PAR01 <> 3, "", "AND D3_CUSTO1 > 0 " ) ) + &_cEOL
		_cQry += If( MV_PAR08 = 1 .And. _lCancSele8 .And. ! Empty( _cTpProd  ) .And. ! _lAllPar8, " AND D3_GRUPO IN (" + _cTpProd + ") " + &_cEOL, "" )
		_cQry += If( MV_PAR09 = 1 .And. _lCancSele9 .And. ! Empty( _cTpMovim ) .And. ! _lAllPar9, " AND D3_TM    IN (" + _cTpMovim + ")", "" )
		//Fim Thais Paiva 11832993
		_cQry += " ORDER BY D3.D3_FILIAL, D3.D3_XIDEXT "
	Else
		_cQry += If( MV_PAR01 = 1, " GROUP BY D3_FILIAL, D3_TM, F5_TEXTO, D3_GRUPO, BM_DESC, D3_CC, D3_XFILORI, D3_XFILDES ", " ORDER BY D3_FILIAL, D3_TM, D3_GRUPO, D3_EMISSAO " )
	EndIf

    IncProc( "Iniciando processamento da consulta no banco de dados" )

	_cTimeIni := Time()

	If Select( "TSD3" ) > 0; TSD3->( DbCloseArea() ); EndIf
	TCQUERY _cQry NEW ALIAS "TSD3"

	IncProc( "Iniciando configuração da estrutura do arquivo" )

	If MV_PAR01 = 1
		AADD( _aStrutura, { "Filial"    , TamSX3( "D3_FILIAL"  )[03], TamSX3( "D3_FILIAL"  )[01], 00 } )
	    AADD( _aStrutura, { "TpMoviment", TamSX3( "D3_TM"      )[03], TamSX3( "D3_TM"      )[01], 00 } )
	    AADD( _aStrutura, { "DescriTM"  , TamSX3( "F5_TEXTO"   )[03], TamSX3( "F5_TEXTO"   )[01], 00 } )
	    AADD( _aStrutura, { "CustoM1"   , TamSX3( "D3_CUSTO1"  )[03], TamSX3( "D3_CUSTO1"  )[01], 00 } )
	    AADD( _aStrutura, { "CCusto"    , TamSX3( "D3_CC"      )[03], TamSX3( "D3_CC"      )[01], 00 } )
	    AADD( _aStrutura, { "FilOrig"   , TamSX3( "D3_XFILORI" )[03], TamSX3( "D3_XFILORI" )[01], 00 } )
	    AADD( _aStrutura, { "FilDest"   , TamSX3( "D3_XFILDES" )[03], TamSX3( "D3_XFILDES" )[01], 00 } )
		AADD( _aStru2,    { "D3_FILIAL" } )
	    AADD( _aStru2,    { "D3_TM"     } )
	    AADD( _aStru2,    { "F5_TEXTO"  } )
	    AADD( _aStru2,    { "D3_CUSTO1" } )
	    AADD( _aStru2,    { "D3_CC"     } )
	    AADD( _aStru2,    { "D3_XFILORI" } )
	    AADD( _aStru2,    { "D3_XFILDES" } )
	    FADDCUST()
	    AADD( _aStrutura, { "Tipo"      , TamSX3( "D3_GRUPO"   )[03], TamSX3( "D3_GRUPO"   )[01], 00 } )
	    AADD( _aStrutura, { "DescriGRU" , TamSX3( "BM_DESC"    )[03], TamSX3( "BM_DESC"    )[01], 00 } )
	    AADD( _aStru2,    { "D3_GRUPO" } )
	    AADD( _aStru2,    { "BM_DESC"  } )
    Else
		AADD( _aStrutura, { "Filial"    , TamSX3( "D3_FILIAL"  )[03], TamSX3( "D3_FILIAL"  )[01], 00 } )
	    AADD( _aStrutura, { "TpMoviment", TamSX3( "D3_TM"      )[03], TamSX3( "D3_TM"      )[01], 00 } )
	    AADD( _aStrutura, { "DescriTM"  , TamSX3( "F5_TEXTO"   )[03], TamSX3( "F5_TEXTO"   )[01], 00 } )
	    AADD( _aStrutura, { "Quantidade", TamSX3( "D3_QUANT"   )[03], TamSX3( "D3_QUANT"   )[01], 00 } )
	    AADD( _aStrutura, { "Produto"   , TamSX3( "B1_COD"     )[03], TamSX3( "B1_COD"     )[01], 00 } )
	    AADD( _aStrutura, { "DescriPROD", TamSX3( "B1_DESC"    )[03], TamSX3( "B1_DESC"    )[01], 00 } )
	    AADD( _aStrutura, { "Conta"     , TamSX3( "D3_CONTA"   )[03], TamSX3( "D3_CONTA"   )[01], 00 } )
	    AADD( _aStrutura, { "DescriCONT", TamSX3( "CT1_DESC01" )[03], TamSX3( "CT1_DESC01" )[01], 00 } )
	    AADD( _aStrutura, { "Tipo"     	, TamSX3( "D3_GRUPO"   )[03], TamSX3( "D3_GRUPO"   )[01], 00 } )
	    AADD( _aStrutura, { "DescriGRU" , TamSX3( "BM_DESC"    )[03], TamSX3( "BM_DESC"    )[01], 00 } )
	    AADD( _aStrutura, { "Fornecedor", TamSX3( "D3_XFORN"   )[03], TamSX3( "D3_XFORN"   )[01], 00 } )
	    AADD( _aStrutura, { "CentroCust", TamSX3( "D3_CC"      )[03], TamSX3( "D3_CC"      )[01], 00 } )
	    AADD( _aStrutura, { "Identific" , TamSX3( "D3_XIDEXT"  )[03], TamSX3( "D3_XIDEXT"  )[01], 00 } )
	    AADD( _aStrutura, { "Documento" , TamSX3( "D3_DOC"     )[03], TamSX3( "D3_DOC"     )[01], 00 } )
	    AADD( _aStrutura, { "Emissao"   , TamSX3( "D3_EMISSAO" )[03], TamSX3( "D3_EMISSAO" )[01], 00 } )
	    AADD( _aStrutura, { "CustoM1"   , TamSX3( "D3_CUSTO1"  )[03], TamSX3( "D3_CUSTO1"  )[01], 00 } )

		AADD( _aStru2, { "D3_FILIAL"  } )
	    AADD( _aStru2, { "D3_TM"      } )
	    AADD( _aStru2, { "F5_TEXTO"   } )
	    AADD( _aStru2, { "D3_QUANT"   } )
	    AADD( _aStru2, { "B1_COD"     } )
	    AADD( _aStru2, { "B1_DESC"    } )
	    AADD( _aStru2, { "D3_CONTA"   } )
	    AADD( _aStru2, { "CT1_DESC01" } )
	    AADD( _aStru2, { "D3_GRUPO"   } )
	    AADD( _aStru2, { "BM_DESC"    } )
	    AADD( _aStru2, { "D3_XFORN"   } )
	    AADD( _aStru2, { "D3_CC"      } )
	    AADD( _aStru2, { "D3_XIDEXT"  } )
	    AADD( _aStru2, { "D3_DOC"     } )
	    AADD( _aStru2, { "D3_EMISSAO" } )
	    AADD( _aStru2, { "D3_CUSTO1"  } )

	    FADDCUST()

	    AADD( _aStrutura, { "Estorno"   , TamSX3( "D3_ESTORNO" )[03], TamSX3( "D3_ESTORNO" )[01], 00 } )
	    AADD( _aStrutura, { "Consignado", TamSX3( "D3_XCONSIG" )[03], TamSX3( "D3_XCONSIG" )[01], 00 } )
	    AADD( _aStrutura, { "FilOrigem" , TamSX3( "D3_XFILORI" )[03], TamSX3( "D3_XFILORI" )[01], 00 } )
	    AADD( _aStrutura, { "FilDestino", TamSX3( "D3_XFILDES" )[03], TamSX3( "D3_XFILDES" )[01], 00 } )
	    AADD( _aStrutura, { "CTAContab" , TamSX3( "D3_XCONTA"  )[03], TamSX3( "D3_XCONTA"  )[01], 00 } )

	    AADD( _aStru2, { "D3_ESTORNO" } )
	    AADD( _aStru2, { "D3_XCONSIG" } )
	    AADD( _aStru2, { "D3_XFILORI" } )
	    AADD( _aStru2, { "D3_XFILDES" } )
	    AADD( _aStru2, { "D3_XCONTA"  } )
    EndIf

	TSD3->( DbGoTop() )

	IncProc( "Contagem de registros" )

	_nContar := Contar( "TSD3", "!EOF()" )

	If _nContar = 0
		Aviso( "Atenção", "Consulta sem registros a processar, verifique os parâmetros e gere novamente.", { "Sair" } )
		Return
	EndIf

	IncProc( "Processando " + Alltrim( Str( _nContar ) ) + " registro(s)." )

	TSD3->( DbGoTop() )

	FGRVDTC()
		
	DbSelectArea( "TSD3" )

	IncProc( "Copiando arquivo para gerar planilha" )
	
	//_CopyFile( _cAliasDbf + GetDBExtension(), "RELSD3" + GetDBExtension() ) 9634835 - Thais Paiva
	_CopyFile( MsDocPath()+_cAliasDtc + ".CSV", "C:\REL_SD3\"+_cAliasDtc + ".CSV" ) 
	
	//Set Filter To 9634835 - Thais Paiva
	//Copy to &"RELSD3" VIA "CTREECDX" 9634835 - Thais Paiva

	IncProc( "Finalizando processo" )

	//( _cAliasDbf )->( dbCloseArea() ) 9634835 - Thais Paiva

	//FErase( _cAliasDbf + ".CSV" ) 9634835 - Thais Paiva

	//CpyS2T( "RELSD3.DBF", "C:\REL_SD3\", .T. ) 9634835 - Thais Paiva
	
	FClose( MsDocPath()+_cAliasDtc + ".CSV" ) //FClose( _cAliasDbf + ".DBF" ) 9634835 - Thais Paiva
	FErase( MsDocPath()+_cAliasDtc + ".CSV" ) //FErase( _cAliasDbf + ".DBF" ) 9634835 - Thais Paiva
	//FErase( "RELSD3.DBF" ) 9634835 - Thais Paiva
	//FErase( "RELSD3" + GetDBExtension() ) 9634835 - Thais Paiva

	Aviso( "Atenção", "Fim do processamento, tempo total " + ElapTime(  _cTimeIni, Time() ) + ".", { "Abrir Planilha" } )

	EXPEXCEL()

Return

***********************************
Static Function FRDORREL2( _MvPar )
***********************************

	Local _cQry, _TituTela, oDlgList, _cCampo1, _cCampo2, _nOk := 0, _nContar := 0, _xa := 0
	Local oAll     := "", _lAll := .F., _lRet := .F.
	Local oListMnu := ""
                                                  	
	Private _PMv := "", _aACols := {}

	If _MvPar = 2
		FRDORREL04( 2, 1 )

		_TituTela := "Selecione a Filial"
		_cCampo1  := "M0_CODFIL"
		_cCampo2  := "M0_FILIAL"

		DbSelectArea( "SM0" )

		SM0->( DbGoTop() )

		Do While SM0->( ! Eof() )
			_xa++
			AADD( _aACols, { ( Ascan( _aTelMark, { |x| x[1] == SM0->&_cCampo1 } ) <> 0 ), SM0->&_cCampo1, SM0->&_cCampo2, 00 } )
			If _aACols[_xa][1]
				_nContar++
			EndIf
			SM0->( DbSkip() )
		EndDo
		_xa := 0
		If _nContar = Len( _aAcols )
			_lAll := .T.
		EndIf
	ElseIf _MvPar = 8
		FRDORREL04( 8, 1 )

		_TituTela := "Tipo do produto"

		_cQry := " SELECT BM_GRUPO, BM_DESC FROM " + RETSQLNAME( "SBM" ) + " WHERE "
		_cQry += " D_E_L_E_T_ = ' ' AND BM_FILIAL = '" + xFilial( "SBM" ) + "' "
		_cQry += " ORDER BY BM_GRUPO "

		_cCampo1  := "BM_GRUPO"
		_cCampo2  := "BM_DESC"
	ElseIf _MvPar = 9
		FRDORREL04( 9, 1 )

		_TituTela := "Selecione o Tipo de Movimentação"

		_cQry := " SELECT F5_CODIGO, F5_TEXTO FROM " + RETSQLNAME( "SF5" ) + " WHERE "
		_cQry += " D_E_L_E_T_ = ' ' AND F5_FILIAL = '" + xFilial( "SF5" ) + "' "
		_cQry += " ORDER BY F5_CODIGO "

		_cCampo1  := "F5_CODIGO"
		_cCampo2  := "F5_TEXTO"
	EndIf

	If _MvPar <> 2
		If Select( "TRB" ) > 0; TRB->( DbCloseArea() ); EndIf
		TCQUERY _cQry NEW ALIAS "TRB"

		TRB->( DbGoTop() )

		If TRB->( Eof() )
			AADD( _aACols, { .F., "", "", 00 } )
		EndIf

		Do While TRB->( ! Eof() )
			_xa++
			AADD( _aACols, { ( Ascan( _aTelMark, { |x| Alltrim( x[1] ) == TRB->&_cCampo1 } ) <> 0 ), TRB->&_cCampo1, TRB->&_cCampo2, 00 } )

			TRB->( DbSkip() )

			If _aACols[_xa][1]
				_nContar++
			EndIf
		EndDo
		_xa := 0
		If _nContar = Len( _aAcols )
			_lAll := .T.
		EndIf
	EndIf

	oOk   := LoadBitmap( GetResources(), "LBOK" )
	oNo   := LoadBitmap( GetResources(), "LBNO" )
	bLine := { || { If( _aAcols[oListMnu:nAt, 1], oOk, oNo ),  _aAcols[oListMnu:nAt, 2], _aAcols[oListMnu:nAt, 3] } }

	DEFINE MSDIALOG oDlgList TITLE _TituTela FROM 0,0 TO 245,410 OF oMainWnd PIXEL Style DS_MODALFRAME

		@ 05,05 LISTBOX oListMnu FIELDS HEADER "", "Codigo", "Descricao" FIELDSIZES 14, 100,50 SIZE 160, 102 PIXEL OF oDlgList

		oListMnu:SetArray( _aAcols )
		oListMnu:bLine := bLine

		oListMnu:bLDblClick := { |nRowPix, nColPix, nKeyFlags| ValSelection( @_aAcols, oListMnu ), oListMnu:Refresh() }

	    @110,06 CHECKBOX oAll VAR _lAll PROMPT "Marcar/Desmarcar Todos" FONT oDlgList:oFont PIXEL SIZE 80, 09 OF oDlgList;
		ON CLICK ( Aeval( _aAcols, { |x, y| _aAcols[y][1] := If( _aAcols[y][4] = 99, .F., _lAll ) } ), oListMnu:Refresh() )

		DEFINE SBUTTON FROM 05,170 TYPE 1 ENABLE OF oDlgList ACTION ( _PMv := FGeraStr( _lAll ), _nOk := _MvPar, _lRet := .T., oDlgList:End() )
		DEFINE SBUTTON FROM 20,170 TYPE 2 ENABLE OF oDlgList ACTION oDlgList:End()

	ACTIVATE DIALOG oDlgList CENTERED

	If _MvPar = 2
		If _lAll
			_lAllPar2 := .T.
		EndIf
		FRDORREL04( 2, 2 )
	ElseIf _MvPar = 8
		If _lAll
			_lAllPar8 := .T.
		EndIf
		FRDORREL04( 8, 2 )
	ElseIf _MvPar = 9
		If _lAll
			_lAllPar9 := .T.
		EndIf
		FRDORREL04( 9, 2 )
	EndIf

Return( { _PMv, _lRet } )

*******************************************
Static Function FRDORREL04( _nPar, _nMark )
*******************************************

	Local _nHdle, _nTamArq, _cFile := "C:\REL_SD3\MVPARD3" + Alltrim( Str( _nPar ) ) + ".CSV", _cLinha := Space( 10 ), _lMvParCsv, _cLiMv := "", _lGrvMv := .F.
	Local _cGrvPosi := ""

	If File( _cFile ) .And. _nMark = 1
		_nHdle   := FOPEN( _cFile, 2 )
		_nTamArq := FSEEK( _nHdle, 0, 2 )

		FSEEK( _nHdle, 0, 0 )

		FREAD( _nHdle, _cLinha, _nTamArq )

		For _xn := 1 To Len( _cLinha )
			If Substr( _cLinha, _xn, 1 ) <> "|"
				_cGrvPosi := _cGrvPosi + Substr( _cLinha, _xn, 1 )
			Else
				AADD( _aTelMark, { _cGrvPosi } )
				_cGrvPosi := ""
			EndIf
		Next _xn
		FCLOSE( _nHdle )
		FERASE( _cFile )
	ElseIf _nMark = 2
		If ! File( _cFile )
			_lMvParCsv := FCreate( _cFile, 0 )
		Else
			_lMvParCsv := FOpen( _cFile, 2 )
			FSEEK( _lMvParCsv, 0, 0 )
			FCLOSE( _lMvParCsv )
			FERASE( _cFile )
			_lMvParCsv := FCreate( _cFile, 0 )
		EndIf

		For _xd := 1 To Len( _aAcols )
			If _aAcols[_xd][1]
				&( "_lCancSele" + Alltrim( Str( _nPar ) ) ) := .T.
				_lGrvMv := .T.
				_cLiMv  := _cLiMv + _aAcols[_xd][2] + "|"
			EndIf
		Next _xd
		If _lGrvMv
			fWrite( _lMvParCsv, _cLiMv, _lMvParCsv )
		EndIf
		FClose( _lMvParCsv )
	EndIf

Return

*************************************************
Static Function ValSelection( _aAcols, oListMnu )
*************************************************

	Local i
	Local nAt := oListMnu:nAt

	_aAcols[nAt, 1] := ! _aAcols[nAt, 1]

	If ( _aAcols[nAt, 4] = 99 )
		If _aAcols[nAt, 1]
			For i := 1 To Len( _aAcols )
				If i <> nAt
					_aAcols[i, 1] := .F.
				EndIf
			Next
		EndIf
	Else
		If ( i := Ascan( _aAcols, { |x| x[4] = 99 } ) ) <> 0
			_aAcols[i, 1] := .F.
		EndIf
	EndIf

Return

************************************
Static Function FGeraStr( _lProces )
************************************

	Local V_TmpStr := "'"

	If ! _lProces
		For _kj := 1 to Len( _aAcols )
			If _aAcols[ _kj, 1 ]
				V_TmpStr := V_TmpStr + Alltrim( _aAcols[_kj, 2] ) + "','"
		    Endif
		Next

		V_TmpStr := Substr( V_TmpStr, 1, Len( V_TmpStr ) - 2  )
	EndIf

Return( V_TmpStr )

/*Início - Thais Paiva - Compatibilização P27
*********************************
Static Function FAjuSx1( _cPerg )
*********************************

	Local _cHelp1, _cHelp2, _cHelp3, _cHelp4, _cHelp5, _cHelp6, _cHelp7, _cHelp8, _cHelp9

	_cHelp1 := "Selecione o tipo de relatório desejado:" + &_cEOL + "1 - Sintético;" + &_cEOL + "2 - Analítico;" + &_cEOL + "3 - Duplicados para localizar prováveis erros de integração." + &_cEOL + "Obs.: Só retorna duplicados caso a linha duplicada não esteja estornada."
	_cHelp2 := "Opção para marcar em quais filiais deseja gerar o relatório. Se não for selecionado, o relatório irá considerar a filial vigente." + &_cEOL + "Obs.: Será apresentado tela para seleção."
	_cHelp3 := "Selecione a data início do período para extração do relatório."
	_cHelp4 := "Selecione a data fim do período para extração do relatório." + &_cEOL + "Obs.: Lembrando que para relatórios analíticos ou duplicados, o período será considerado somente de um mês, para sintético no máximo três meses."
	_cHelp5 := "Permite considerar as movimentações estornadas." + &_cEOL + "Obs.: Está opção será desconsiderada para duplicados."
	_cHelp6 := "Permite considerar as movimentações não valorizadas." + &_cEOL + "Obs.: Está opção será desconsiderada para duplicados."
	_cHelp7 := "Defina outra moeda." + &_cEOL + "Caso queira refletir no relatório outra moeda, o mesmo apresenta a moeda corrente nacional e a moeda selecionada em outra coluna."
	_cHelp8 := "Quando não desconsiderado o tipo de produto, o relatório retorna todos os produtos que sofreram movimentações de estoque." + &_cEOL + "Obs.: Será apresentado tela para seleção."
	_cHelp9 := "Selecionar o tipo de movimentação de estoque; saída, entrada e seus respectivos códigos." + &_cEOL + "Será apresentado tela para seleção dos códigos correspondente."

	xPutSx1( _cPerg, "01", "Tipo de Relatório ?"    , "", "", "mv_ch1", "N", 01, 0, 1, "C", ""            , "    ", "", "S", "MV_PAR01", "Sintetico", "Sintetico", "Sintetico", "", "Analitico" , "Analitico" , "Analitico", "Duplicados", "Duplicados", "Duplicados", "", "", "", "", "", "", { _cHelp1 }, "", "" )
	xPutSx1( _cPerg, "02", "Seleciona Filiais ?"    , "", "", "mv_ch2", "N", 01, 0, 2, "C", ""            , "    ", "", "S", "MV_PAR02", "Sim"      , "Sim"      , "Sim"      , "", "Nao"       , "Nao"       , "Nao"      , "          ", "          ", "          ", "", "", "", "", "", "", { _cHelp2 }, "", "" )
	xPutSx1( _cPerg, "03", "Emissao De?"            , "", "", "mv_ch3", "D", 08, 0, 0, "G", ""            , "    ", "", "S", "MV_PAR03", ""         , ""         , ""         , "", ""          , ""          , ""         , "          ", "          ", "          ", "", "", "", "", "", "", { _cHelp3 }, "", "" )
	xPutSx1( _cPerg, "04", "Emissao Ate?"           , "", "", "mv_ch4", "D", 08, 0, 0, "G", "U_FTSTPERI()", "    ", "", "S", "MV_PAR04", ""         , ""         , ""         , "", ""          , ""          , ""         , "          ", "          ", "          ", "", "", "", "", "", "", { _cHelp4 }, "", "" )
	xPutSx1( _cPerg, "05", "Considera Estorno ?"    , "", "", "mv_ch5", "N", 01, 0, 2, "C", ""            , "    ", "", "S", "MV_PAR05", "Sim"      , "Sim"      , "Sim"      , "", "Nao"       , "Nao"       , "Nao"      , "          ", "          ", "          ", "", "", "", "", "", "", { _cHelp5 }, "", "" )
	xPutSx1( _cPerg, "06", "Nao Valorizados ?"      , "", "", "mv_ch6", "N", 01, 0, 2, "C", ""            , "    ", "", "S", "MV_PAR06", "Sim"      , "Sim"      , "Sim"      , "", "Nao"       , "Nao"       , "Nao"      , "          ", "          ", "          ", "", "", "", "", "", "", { _cHelp6 }, "", "" )
	xPutSx1( _cPerg, "07", "Moeda ?"                , "", "", "mv_ch7", "C", 02, 0, 0, "G", ""            , "CTO" , "", "S", "MV_PAR07", ""         , ""         , ""         , "", ""          , ""          , ""         , "          ", "          ", "          ", "", "", "", "", "", "", { _cHelp7 }, "", "" )
	xPutSx1( _cPerg, "08", "Tipo de Produto ?"      , "", "", "mv_ch8", "N", 01, 0, 2, "C", ""            , "    ", "", "S", "MV_PAR08", "Sim"      , "Sim"      , "Sim"      , "", "Nao"       , "Nao"       , "Nao"      , "          ", "          ", "          ", "", "", "", "", "", "", { _cHelp8 }, "", "" )
	xPutSx1( _cPerg, "09", "Tipo de movimentação ?" , "", "", "mv_ch9", "N", 01, 0, 2, "C", ""            , "    ", "", "S", "MV_PAR09", "Sim"      , "Sim"      , "Sim"      , "", "Nao"       , "Nao"       , "Nao"      , "          ", "          ", "          ", "", "", "", "", "", "", { _cHelp9 }, "", "" )

Return

*****************************************************************************************************************************************************
Static Function xPutSx1( _cGrupo, _cOrdem, _cPergunt, _cPerSpa, _cPerEng, _cVar, _cTipo, _nTamanho, _nDecimal, _nPresel, _cGSC, _cValid,;
                         _cF3, _cGrpSxg, _cPyme, _cVar01, _cDef01, _cDefSpa1, _cDefEng1, _cCnt01, _cDef02, _cDefSpa2, _cDefEng2,_cDef03, _cDefSpa3,;
                         _cDefEng3, _cDef04, _cDefSpa4, _cDefEng4, _cDef05, _cDefSpa5, _cDefEng5, _aHelpPor, _aHelpEng, _aHelpSpa, _cHelp )
*****************************************************************************************************************************************************

	Local _aArea := GetArea()
	Local _lPort := .F.
	Local _lSpa  := .F.
	Local _lIngl := .F.
	Local _cKey

	_cKey    := "P." + AllTrim( _cGrupo ) + AllTrim( _cOrdem ) + "."
	_cPyme   := If( _cPyme   = Nil, " ", _cPyme   )
	_cF3     := If( _cF3     = NIl, " ", _cF3     )
	_cGrpSxg := If( _cGrpSxg = Nil, " ", _cGrpSxg )
	_cCnt01  := If( _cCnt01  = Nil, "" , _cCnt01  )
	_cHelp   := If( _cHelp   = Nil, "" , _cHelp   )

	dbSelectArea( "SX1" ) 
	SX1->( dbSetOrder( 1 ) )

	_cGrupo := PadR( _cGrupo, Len( SX1->X1_GRUPO ) , " " )

	If !( DbSeek( _cGrupo + _cOrdem ) )

		_cPergunt := If( ! "?" $ _cPergunt .And. ! Empty( _cPergunt ), Alltrim( _cPergunt ) + " ?", _cPergunt )
		_cPerSpa  := If( ! "?" $ _cPerSpa  .And. ! Empty( _cPerSpa  ), Alltrim( _cPerSpa  ) + " ?", _cPerSpa  )
		_cPerEng  := If( ! "?" $ _cPerEng  .And. ! Empty( _cPerEng  ), Alltrim( _cPerEng  ) + " ?", _cPerEng  )

		Reclock( "SX1" , .T. )

		Replace X1_GRUPO   With _cGrupo 
		Replace X1_ORDEM   With _cOrdem 
		Replace X1_PERGUNT With _cPergunt 
		Replace X1_PERSPA  With _cPerSpa 
		Replace X1_PERENG  With _cPerEng 
		Replace X1_VARIAVL With _cVar 
		Replace X1_TIPO    With _cTipo 
		Replace X1_TAMANHO With _nTamanho 
		Replace X1_DECIMAL With _nDecimal 
		Replace X1_PRESEL  With _nPresel 
		Replace X1_GSC     With _cGSC 
		Replace X1_VALID   With _cValid 
		Replace X1_VAR01   With _cVar01 
		Replace X1_F3      With _cF3 
		Replace X1_GRPSXG  With _cGrpSxg 

		If Fieldpos( "X1_PYME" ) > 0
			If _cPyme != Nil
				Replace X1_PYME With _cPyme
          	EndIf 
		EndIf

		Replace X1_CNT01 With _cCnt01

		If _cGSC == "C"
			Replace X1_DEF01   With _cDef01
			Replace X1_DEFSPA1 With _cDefSpa1
			Replace X1_DEFENG1 With _cDefEng1
			Replace X1_DEF02   With _cDef02
			Replace X1_DEFSPA2 With _cDefSpa2
			Replace X1_DEFENG2 With _cDefEng2
			Replace X1_DEF03   With _cDef03
			Replace X1_DEFSPA3 With _cDefSpa3
			Replace X1_DEFENG3 With _cDefEng3
			Replace X1_DEF04   With _cDef04
			Replace X1_DEFSPA4 With _cDefSpa4
			Replace X1_DEFENG4 With _cDefEng4
			Replace X1_DEF05   With _cDef05
			Replace X1_DEFSPA5 With _cDefSpa5
			Replace X1_DEFENG5 With _cDefEng5
		EndIf

		Replace X1_HELP With _cHelp

		PutSX1Help( _cKey, _aHelpPor, _aHelpEng, _aHelpSpa, .T., "MODIFIED" )

		SX1->( MsUnlock() )
	Else
		_lPort := ! "?" $ X1_PERGUNT .And. ! Empty( SX1->X1_PERGUNT )
		_lSpa  := ! "?" $ X1_PERSPA  .And. ! Empty( SX1->X1_PERSPA  )
		_lIngl := ! "?" $ X1_PERENG  .And. ! Empty( SX1->X1_PERENG  )

		If _lPort .Or. _lSpa .Or. _lIngl
			RecLock( "SX1", .F. )
			If _lPort
				SX1->X1_PERGUNT := Alltrim( SX1->X1_PERGUNT ) + " ?"
			EndIf
			If _lSpa
				SX1->X1_PERSPA := Alltrim( SX1->X1_PERSPA   ) + " ?"
			EndIf
			If _lIngl
				SX1->X1_PERENG := Alltrim( SX1->X1_PERENG   ) + " ?"
			EndIf
			SX1->( MsUnLock() )
		EndIf
		If Empty( SX1->X1_HELP ) .Or. Alltrim( SX1->X1_HELP ) <> _aHelpPor[1]
			PutSX1Help( _cKey, _aHelpPor, _aHelpEng, _aHelpSpa, .T., "MODIFIED" )
		EndIf
	EndIf

	RestArea( _aArea )

Return

****************************************************************************************
Static Function PutSX1Help( _cKey, _aHelpPor, _aHelpEng, _aHelpSpa, _lUpdate, _cStatus )
****************************************************************************************

	Local _cFilePor   := "SIGAHLP.HLP"
	Local _cFileEng   := "SIGAHLE.HLE"
	Local _cFileSpa   := "SIGAHLS.HLS"
	Local _nRet
	Local _nT
	Local _nI
	Local _cLast
	Local _cNewMemo

	Default _aHelpPor := {}
	Default _aHelpEng := {}
	Default _aHelpSpa := {}
	Default _lUpdate  := .T.
	Default _cStatus  := ""

	If Empty( _cKey )
		Return
	EndIf

	If ! ( _cStatus $ "USER|MODIFIED|TEMPLATE" )
		_cStatus := NIL
	EndIf

	_cLast    := ""
	_cNewMemo := ""

	_nT := Len( _aHelpPor )

	For _nI := 1 to _nT
	   _cLast := Padr( _aHelpPor[_nI], Len( _aHelpPor[_nI] ) )
	   If _nI = _nT
	      _cLast := RTrim( _cLast )
	   EndIf
	   _cNewMemo += _cLast
	Next _nI

	If ! Empty( _cNewMemo )
		_nRet := SPF_SEEK( _cFilePor, _cKey, 1 )
		If _nRet < 0
			SPF_INSERT( _cFilePor, _cKey, _cStatus,, _cNewMemo )
		Else
			If _lUpdate
				SPF_UPDATE( _cFilePor, _nRet, _cKey, _cStatus,, _cNewMemo )
			EndIf
		EndIf
	EndIf

	_cLast    := ""
	_cNewMemo := ""

	_nT := Len( _aHelpEng )

	For _nI := 1 to _nT
	   _cLast := Padr( _aHelpEng[_nI], Len( _aHelpEng[_nI] ) )
	   If _nI = _nT
	      _cLast := RTrim( _cLast )
	   EndIf
	   _cNewMemo += _cLast
	Next

	If ! Empty( _cNewMemo )
		_nRet := SPF_SEEK( _cFileEng, _cKey, 1 )
		If _nRet < 0
			SPF_INSERT( _cFileEng, _cKey, _cStatus,, _cNewMemo )
		Else
			If _lUpdate
				SPF_UPDATE( _cFileEng, _nRet, _cKey, _cStatus,, _cNewMemo )
			EndIf
		EndIf
	EndIf

	_cLast    := ""
	_cNewMemo := ""

	_nT := Len( _aHelpSpa )

	For _nI:= 1 to _nT
	   _cLast := Padr( _aHelpSpa[_nI], Len( _aHelpSpa[_nI] ) )
	   If _nI = _nT
	      _cLast := RTrim( _cLast )
	   EndIf
	   _cNewMemo += _cLast
	Next

	If ! Empty( _cNewMemo )
		_nRet := SPF_SEEK( _cFileSpa, _cKey, 1 )
		If _nRet < 0
			SPF_INSERT( _cFileSpa, _cKey, _cStatus,, _cNewMemo )
		Else
			If _lUpdate
				SPF_UPDATE( _cFileSpa, _nRet, _cKey, _cStatus,, _cNewMemo )
			EndIf
		EndIf
	EndIf

Return
Fim - Thais Paiva Compatibilização P27*/

***********************
User Function FTSTPERI
***********************

	Local _lRet := .T.

	If MV_PAR01 = 1
		If ! ( MV_PAR04 - MV_PAR03 ) <= 90
			_lRet := .F.
			Aviso( "Atenção", "Para relatório sintético, a data não pode exceder 90 dias", { "Voltar" } )
		EndIf
	Else
		If ! ( MV_PAR04 - MV_PAR03 ) <= 30
			_lRet := .F.
			Aviso( "Atenção", "Para relatório " + If( MV_PAR01 = 2, "analítico", "de duplicados" ) + ", a data não pode exceder 30 dias", { "Voltar" } )
		EndIf
	EndIf

Return _lRet

***********************
Static Function FGRVDTC
***********************
	Local _cAlias := 'TSD3' //9634835 - Thais Paiva
	
	For _ng := 1 To Len( _aStru2 )
		TCSetField( 'TSD3', _aStrutura[_ng][1], TamSX3( _aStru2[_ng][1] )[03], TamSX3( _aStru2[_ng][1] )[01], TamSX3( _aStru2[_ng][1] )[02] )
	Next _ng
	
	
	//FCRIAARQ() 9634835 - Thais Paiva	
	FCRIAARQ(_cAlias,,_aStrutura)

Return

************************************
Static Function EXPEXCEL( _nSeqArq )
************************************

	Local oExcelApp

	If ! ApOleClient( 'MsExcel' )
	   Aviso( 'Atenção', 'MsExcel não instalado, pode ser que seu arquivo abra desconfigurado.', { "Gerar" } )
	   //Shellexecute( "Open", "C:\REL_SD3\RELSD3.DBF", " /k dir ", "c:\", 1 ) 9634835 - Thais Paiva
	   Shellexecute( "Open", "C:\REL_SD3\RELSD3.CSV", " /k dir ", "c:\", 1 ) 
	Else
		oExcelApp := MsExcel():New()
		//oExcelApp:WorkBooks:Open( "C:\REL_SD3\RELSD3.DBF" ) 9634835 - Thais Paiva
		oExcelApp:WorkBooks:Open( "C:\REL_SD3\RELSD3.CSV" ) 
		oExcelApp:SetVisible( .T. )
	EndIf

Return

************************
//Início - 9634835 - Thais Paiva
//Static Function FCRIAARQ 
Static Function FCRIAARQ(_cAlias,_cFiltro,aHeader)
************************
local cDirDocs  := MsDocPath()
Local cPath		:= "C:\REL_SD3\"
Local oExcelApp
Local cCrLf 	:= Chr(13) + Chr(10)
Local nX
local _cArq		:= ""

	//Início - Thais Paiva - Compatibilização P27
	//_cAliasDbf := CriaTrab( _aStrutura, .T. )
	//DbUseArea( .T., , _cAliasDbf,,.T., .F.)
	//DbSelectArea( _cAliasDbf )
	//oTempTable := FWTemporaryTable():New( _cAliasDbf )
	//oTemptable:SetFields( _aStrutura )
	//oTempTable:Create()
	//Fim - Thais Paiva - Compatibilização P27

_cAliasDtc := "RELSD3"

_cFiltro := iif(_cFiltro==NIL, "",_cFiltro)

if !empty(_cFiltro)
	(_cAlias)->(dbsetfilter({|| &(_cFiltro)} , _cFiltro))
endif

nHandle := MsfCreate(cDirDocs+""+_cAliasDtc+".CSV",0)
	
If nHandle > 0
// Grava o cabecalho do arquivo
		aEval(aHeader, {|e, nX| fWrite(nHandle, e[1] + If(nX < Len(aHeader), ";", "") ) } )
		fWrite(nHandle, cCrLf ) // Pula linha
		
		(_cAlias)->(dbgotop())
		while (_cAlias)->(!eof())
			
			for _ni := 1 to len(aHeader)
				
				_uValor := ""
				
				if aHeader[_ni,2] == "D" // Trata campos data
					_uValor := dtoc(&(_cAlias + "->" + aHeader[_ni,1]))
				elseif aHeader[_ni,2] == "N" // Trata campos numericos
					_uValor := transform(&(_cAlias + "->" + aHeader[_ni,1]),"@E 999,999,999.99")
				elseif aHeader[_ni,2] == "C" // Trata campos caracter
					_uValor := chr(160)+&(_cAlias + "->" + aHeader[_ni,1])
				endif
				
				if _ni <= len(aHeader)
					fWrite(nHandle, _uValor + ";" )
				endif
				
			next _ni
			
			fWrite(nHandle, cCrLf )
			
			(_cAlias)->(dbskip())
			
		enddo
		
		fClose(nHandle)
		
Else
		MsgAlert("Falha na criação do arquivo")
Endif
	
(_cAlias)->(dbclearfil())
//Fim - 9634835 - Thais Paiva	
Return

*************************
Static Function FADDCUST
*************************

	If MV_PAR07 = '02'
		AADD( _aStrutura, { 'CustoM2', TamSX3( 'D3_CUSTO2' )[03], TamSX3( 'D3_CUSTO2' )[01], 00 } )
		AADD( _aStru2,    { "D3_CUSTO2" } )
	ElseIf MV_PAR07 = '03'
		AADD( _aStrutura, { 'CustoM3', TamSX3( 'D3_CUSTO3' )[03], TamSX3( 'D3_CUSTO3' )[01], 00 } )
		AADD( _aStru2,    { "D3_CUSTO3" } )
	ElseIf MV_PAR07 = '04'
		AADD( _aStrutura, { 'CustoM4', TamSX3( 'D3_CUSTO4' )[03], TamSX3( 'D3_CUSTO4' )[01], 00 } )
		AADD( _aStru2,    { "D3_CUSTO4" } )
	ElseIf MV_PAR07 = '05'
		AADD( _aStrutura, { 'CustoM5', TamSX3( 'D3_CUSTO5' )[03], TamSX3( 'D3_CUSTO5' )[01], 00 } )
		AADD( _aStru2,    { "D3_CUSTO5" } )
	EndIf

Return
