/*/
=========================================================================================
Data      : 07/03/2019
-----------------------------------------------------------------------------------------
Autor     : Thiago Gï¿½es 
-----------------------------------------------------------------------------------------
Descricao : relatório de Classiicacao
-----------------------------------------------------------------------------------------
Partida   : Menu de Usuï¿½rio
=========================================================================================
/*/

#include "PROTHEUS.CH"	
#Include "TOPCONN.Ch"
#Include "TOTVS.CH"
#Include "RWMAKE.ch"

User Function RDORRA04

	Local _aArea 	  	:= FWGetArea()
	Local _cPerg 	  	:= 'RELCLASS'
	Local _cDescPar01 	:= ' '
	Private cEol        := chr(13)+chr(10)
   	Private cAlias 		:= GetNextAlias() 
    Private cAliasEst 	:= GetNextAlias()   
    Private cNomInd  	:= "RDORRA04" + "9"+StrZero(Seconds(),5,0)
 	Private cDriver		:= __LocalDriver
 	Private cExtens		:= '.DTC'
 	Private cIndArqA	:= Subs(cNomInd,1,7)+"A"
 	Private cIndArqB	:= Subs(cNomInd,1,7)+"B"
 	Private aStruct		:=  {}

	//FAJUSTSX1( _cPerg ) Thais Paiva - Compatibilizaï¿½ï¿½o P27

	If ! Pergunte( _cPerg, .T. )
		Return
	EndIf

	Processa( {|| FRDORRB()}, "Aguarde...","Processando relatório Documentos à Classificar...", .F. )

	RestArea( _aArea )

Return

***********************
Static Function FRDORRB
***********************

	Local _cPath := "C:\REL_CLASSIFICAR\" 
	Local _cArq := "CLASSIFICAR"+"_"+StrZero(Seconds(),5,0)+".CSV"
	Local _lArqCsv 
	Local _cLin  
	Local _cScript := "C:\REL_CLASSIFICAR\CLASSIFICAR"
	Local _cEscrev
//	Local _cEol := "CHR(13)+CHR(10)"
	Local _cQry := " " 
	Local _cQry2:= " "
	Local _nContar := 0 
	Local _lGerouExc := .F.     
	Local nY  := 0
	Local aProdut := {}
	Local cClassAut := "NÃO"
	Local lAuto := .T.

	ProcRegua( _nContar )

	MONTADIR( _cPath )

	FERASE( _cPath + _cArq )

	If ! File( "C:\REL_CLASSIFICAR\CLASSIFICAR.BAT" )
		_lArqCsv := FCreate( "C:\REL_CLASSIFICAR\CLASSIFICAR.BAT", 0 )
		_cLin    := "ECHO OFF" + cEOL
		_cLin    += "del C:\REL_CLASSIFICAR\*CLASSIFICAR*.csv" + cEOL
		fWrite( _lArqCsv, _cLin, _lArqCsv )
		fClose( _lArqCsv )
	EndIf

	If File( "C:\REL_CLASSIFICAR\CLASSIFICAR.CSV" )
		Shellexecute( "Open", "C:\REL_CLASSIFICAR\CLASSIFICAR.BAT", " /k dir ", "c:\", 1 )
	EndIf

// filial, data, lote, sblote, documento, linha, valor, ,debito, credito,  ccd, ccc, itemd, itemc,hist, tiposald, manual, origem , lp     

	_cQry += " 	SELECT 	A.F1_FILIAL,  "+cEol
	_cQry += " 	    A.F1_DOC, "+cEol
	_cQry += " 	    A.F1_SERIE, "+cEol
	_cQry += " 	    A.F1_FORNECE, "+cEol
	_cQry += "		A.F1_XTIPO , "+cEol
	_cQry += " 	    A.F1_LOJA, "+cEol
	_cQry += "		A.F1_XDTEXCE, "+cEol//Exceção dt fixa
	_cQry += "		A.F1_XDTRECU, "+cEol//DATA DA RECUSA (SF1)
	_cQry += "		A.F1_RECBMTO, "+cEol//DATA DO RECEBIMENTO (SF1
	_cQry += "      A.F1_XUSRIN, "+cEol//Hora da liberação do documento.
	_cQry += " 	    A.C7_XNOMFOR, "+cEol
	_cQry += " 	    A.F1_EMISSAO, "+cEol
	_cQry += " 	    A.F1_DTDIGIT, "+cEol
	_cQry += " 	    A.F1_XDTVNF, "+cEol
	_cQry += " 	    A.F1_XSTRECU, "+cEol
	_cQry += " 	    SUM(A.C7_TOTAL) C7_TOTAL, "+cEol
	//_cQry += " 	    A.C7_PRODUTO,  "+cEol
	//_cQry += " 	 	A.C7_DESCRI, "+cEol
	_cQry += " 	    A.C7_NUM,  "+cEol
	_cQry += " 	    A.C7_XUSR,  "+cEol//NOME DO SOLICITANTE (SC7)
	_cQry += " 	    A.C7_COND,  "+cEol//Cond. Pagto
	_cQry += " 	    A.ANEXO "+cEol
	_cQry += " 	  FROM ( "+cEol
	_cQry += " SELECT "+cEol
	_cQry += " 	F1_FILIAL,F1_DOC,F1_SERIE,F1_FORNECE,C7_XNOMFOR,F1_EMISSAO,F1_DTDIGIT,F1_XDTVNF,F1_XSTRECU,C7_TOTAL, "+cEol
	_cQry += " 	C7_NUM, "+cEoL
	_cQry += "  CASE WHEN (SELECT DISTINCT(P09_CODORI) FROM P09010 WHERE P09_FILIAL = F1_FILIAL AND P09_CODORI = F1_DOC||F1_SERIE||F1_FORNECE||F1_LOJA AND D_E_L_E_T_ = ' ') IS NOT NULL THEN 'S' ELSE 'N' END AS ANEXO, "+cEoL
	_cQry += "  F1_XDTEXCE,F1_XDTRECU,F1_RECBMTO,F1_XUSRIN,C7_XUSR,C7_COND,F1_LOJA,F1_XTIPO "+cEol
	_cQry += " 	FROM "+RetSqlName("SF1") +" F1 "+cEol
	_cQry += " 	INNER JOIN "+RetSqlName("SC7") +" C7 ON C7_FILIAL = F1_FILIAL "+cEol
	_cQry += " 	    AND C7_FORNECE = F1_FORNECE "+cEol
	_cQry += " 	    AND C7_LOJA =  F1_LOJA "+cEol
	_cQry += " 	    AND C7_XDOC = F1_DOC "+cEol
	_cQry += " 	    AND C7_XSERIE = F1_SERIE "+cEol
	_cQry += " 	   AND C7.D_E_L_E_T_ = F1.D_E_L_E_T_ "+cEol
	/*/_cQry += " 	LEFT JOIN "+RetSqlName("P09") +" P09 ON P09_FILIAL = F1_FILIAL "+cEol
	_cQry += " 	    AND SUBSTR(P09_CODORI,1,9)  = F1_DOC "+cEol
	_cQry += " 	    AND SUBSTR(P09_CODORI,10,3) = F1_SERIE  "+cEol
	_cQry += " 	    AND SUBSTR(P09_CODORI,13,6) = F1_FORNECE "+cEol
	_cQry += " 	    AND SUBSTR(P09_CODORI,19,2) = F1_LOJA "+cEol
	_cQry += " 	    AND P09.D_E_L_E_T_ = ''  "+cEol/*/
	_cQry += " 	WHERE F1.D_E_L_E_T_ = ' '  "+cEol
	_cQry += " 	    AND F1_FILIAL  BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"+cEol
	_cQry += " 	    AND F1_DTDIGIT BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"'"+cEol
	//_cQry += " 	    AND F1_XDTVNF  BETWEEN '"+DTOS(MV_PAR05)+"' AND '"+DTOS(MV_PAR06)+"'"+cEol
	_cQry += " 	    AND C7_XSOLPAG <> ' ' "+cEol

	if MV_PAR05 <> 3
		_cQry += " 	    AND P09_CODORI IS " + IIF(MV_PAR05 == 1,'NOT','') + " NULL " + cEol
	endif

	if MV_PAR06 == 1 //Recusado
		_cQry += " 	    AND (F1_XSTRECU = 'R') "+cEol
	elseif MV_PAR06 == 2 //Corrigido
		_cQry += " 	    AND (F1_XSTRECU = 'C') "+cEol
	elseif MV_PAR06 == 4 //Em branco
		_cQry += " 	    AND (F1_XSTRECU = '') "+cEol
	endif
	
	_cQry += " 	    AND F1_XSOLPAG <> ' ' "+cEol
	_cQry += " 	    AND F1_STATUS <> 'A' ) A "+cEol
	_cQry += " 	GROUP BY A.F1_FILIAL,A.F1_DOC,A.F1_SERIE, A.F1_FORNECE, A.ANEXO,A.C7_XNOMFOR,A.F1_EMISSAO,A.F1_DTDIGIT,A.F1_XDTVNF,A.F1_XSTRECU,A.C7_NUM,A.F1_XDTEXCE,A.F1_XDTRECU,A.F1_RECBMTO,A.F1_XUSRIN,A.C7_XUSR,A.C7_COND,A.F1_LOJA,A.F1_XTIPO "+cEol
	_cQry += " 	ORDER BY F1_FILIAL, F1_DOC, F1_EMISSAO "+cEol
    
  	_cQry := ChangeQuery( _cQry )

   //	DdbUsearea(.T.,"TOPCONN",TCGenQry(,,_cQry), 'TCT2') 
   //TCQUERY _cQry NEW ALIAS 'TCT2'
   	DbUseArea(.F., "TOPCONN", TcGenQry(,, _cQry), cAlias, .f., .f.) 
	DbSelectArea(cAlias) 

 //	If Select( 'TCT2' ) > 0; TCT2->( DbCloseArea() ); EndIf
	//TCQUERY _cQry NEW ALIAS 'TCT2'
    
	dbSelectArea(cAlias)             
	(cAlias)->( DbGoTop() )
	
 	If Select(cAlias) >0 
		_lGerouExc := .T.

		_lArqCsv := FCreate( _cScript + ".CSV", 0 )
        
       // _cQry += " 	F1_FILIAL,F1_DOC,F1_SERIE,F1_FORNECE,C7_XNOMFOR,F1_EMISSAO,F1_DTDIGIT,F1_STATUS,F1_XDTVNF,F1_XSTRECU,C7_TOTAL,C7_PRODUTO, "+cEol 
	   // _cQry += " 	C7_DESCRI,C7_NUM  "+cEol
	
 		_cEscrev := 'DOCUMENTOS DE COMPRAS A CLASSIFICAR' + cEOL
		_cEscrev += 'TIPO PAG; FILIAL; NOTA FISCAL; SERIE; FORNECEDOR; NOME FORNECEDOR; CONDIÇÃO DE PAGAMENTO; FORN DT FIXA; EXCEÇÃO DT FIXA; EMISSAO; DT DIGITAÇÃO; DATA DE RECEBIMENTO; DATA VENCIMENTO; TOTAL PEDIDO; PRODUTO; DESCRICAO; STATUS RECUSA; DATA DA RECUSA; NUM PEDIDO; NOME DO SOLICITANTE; POSSUI ANEXO'+ cEOL
		    
 	   	fWrite( _lArqCsv, _cEscrev, _lArqCsv )
	   	
 	  	//(cAlias)->( DbGoTop() )
    	
    	//cDtFim := Dtos( MV_PAR03 )
    	//cFilProc :=  MV_PAR04 
    	
    	//_Estornos( cDtini,cDtfim,cFilProc )
        
    //    If Select(cAliasEst) > 0 ; (cAliasEst)->(dbCloseArea()) ;  EndIf
        
	    //dbSelectArea(cAliasEst)
		//(cAliasEst)->( dbSetOrder( 1 ) ) 
		//(cAliasEst)->(dbGoTop())

    	While (cAlias)->( ! Eof() )    
//    		(cAliasEst)->(dbGoTop())
			IncProc( "Gerando dados Relatorio..." )
//		      If !((cAliasEst)->(dbSeek(((cAlias)->(CT2_LOTE+CT2_SBLOTE+CT2_CREDIT+CT2_DEBITO+cValToChar(CT2_VALOR))))))
//		        	If MV_PAR01 == 1
//	_cQry += " 	,,,,,,,,,,,, "+cEol 
//	_cQry += " 	,  "+cEol

// campo c7_xeraut, conversao do campo que eh memo.
			_cMemo := ""
			DBSELECTAREA("SC7")
			DBSETORDER(1)
			IF DBSEEK((cAlias)->F1_FILIAL + (cAlias)->C7_NUM)
				For _nX := 1 to MlCount(SC7->C7_XERAUT,150)
					_cMemo += Alltrim(MemoLine(SC7->C7_XERAUT,150,_nX)) + " "
				Next _nX
			ENDIF

			SC7->(DbSetOrder(1))
			If SC7->( DbSeek((cAlias)->F1_FILIAL+(cAlias)->C7_NUM))
				While (SC7->(!EOF()) .And. SC7->C7_FILIAL == (cAlias)->F1_FILIAL .And. SC7->C7_NUM == (cAlias)->C7_NUM)
					AADD(aProdut,SC7->C7_PRODUTO)
					SC7->(DbSkip())
				EndDo

				DbSelectArea("P38")
				DbSetOrder(1)

				For nY := 01 To Len(aProdut)

					If !(P38->(DbSeek(xFilial("P38")+aProdut[nY])))
						lAuto := .F.
						Exit
					EndIf

					If lAuto
						cClassAut := "SIM"
					EndIf
				Next nY

			EndIf

			_cEscrev := +  (cAlias)->F1_XTIPO + ';';
				+ "'"+ (cAlias)->F1_FILIAL 		+ ';';
				+ (cAlias)->F1_DOC				    + ';' ;
				+ "'" + (cAlias)->F1_SERIE 			+ ';';
				+ "'" + (cAlias)->F1_FORNECE		+ ';';
				+ (cAlias)->C7_XNOMFOR				+ ';';
				+  (cAlias)->C7_COND + ';';
				+ Iif(Posicione("SA2",1,xFilial("SA2")+(cAlias)->F1_FORNECE+(cAlias)->F1_LOJA,"SA2->A2_XDTFIX") == "1","Sim","Não") + ';';
				+ Iif((cAlias)->F1_XDTEXCE == "1","Sim","Não") + ';';
				+ Dtoc( Stod( (cAlias)->F1_EMISSAO))+ ';';
				+ Dtoc( Stod( (cAlias)->F1_DTDIGIT))+ ';';
				+ Dtoc(stod((cAlias)->F1_RECBMTO)) + ';';
				+ Dtoc( Stod( (cAlias)->F1_XDTVNF))	+ ';';
				+ TransForm( (cAlias)->C7_TOTAL, '@E 9,999,999,999,999.99' ) + ';' ;
				+ (cAlias)->F1_XSTRECU				+ ';';
				+  Dtoc( Stod( (cAlias)->F1_XDTRECU)) 			+ ';';
				+ "'" + (cAlias)->C7_NUM		    + ';';
				+  AllTrim(GetUsrFull((cAlias)->C7_XUSR)) + ';';
				+ (cAlias)->ANEXO				    + ';'; 
				+ cClassAut                             +';';
				+ (cAlias)->F1_XUSRIN                            +';';
				+ Iif(Posicione("SA2",1,xFilial("SA2")+(cAlias)->F1_FORNECE+(cAlias)->F1_LOJA,"SA2->A2_XRISSAC") == "S","Sim","Não")                             +';';
				+ _cMemo				    +		cEOL

//					+ Iif( Empty((cAlias)->CT2_CCD), ' ',"'" + (cAlias)->CT2_CCD) + ';'; 
// 			  		+ Dtoc( Stod( (cAlias)->E5_DATA))	+ ';'; 
					fWrite( _lArqCsv, _cEscrev, _lArqCsv )
			(cAlias)->( DbSkip() )
		EndDo
		_lGerouExc := .T.
    EndIf
    
	If _lGerouExc
		fClose( _lArqCsv )

		Aviso( 'INFO', 'O Relatorio de documentos a Classificar está finalizado,' +;
	                   ' seu excel será aberto.', { 'Fechar' } )

	    Shellexecute( "Open", _cScript + ".CSV", " /k dir ", "c:\", 1 )
	EndIf
	
	(cAlias)->( dbCloseArea() )
	If File( cNomInd + cExtens )     //Elimina o arquivo de trabalho
		Ferase( cNomInd + cExtens )
		Ferase( cIndArqB + OrdBagExt() )
	EndIf
	
Return

Static Function GetUsrFull(_cCodigo)

Return UsrFullName(_cCodigo)

/*Inï¿½cio - Thais Paiva - Compatibilizaï¿½ï¿½o P27
***********************************
Static Function FAJUSTSX1( _cPerg )
***********************************

	Local _aSx1 := {}, _cCampo
	Local _Z := 0
	Local _X1 := 0

	AADD( _aSx1, { "GRUPO","ORDEM","PERGUNT"      , "PERSPA"       	, "PERENG"     	, "VARIAVL", "TIPO", "TAMANHO", "DECIMAL", "PRESEL", "GSC", "VALID", "VAR01"   , "F3", "DEF01" 			, "DEF02"       , "DEF03"   , "DEF04"       , "DEF05"          , "HELP" } )
	AADD( _aSx1, { _cPerg , "01"  , "Filial de  ?", "ï¿½Filial de?"  	, "Filial de?" 	, "mv_ch1" , "C"   , 08       , 0        , 0       , "C"  , ""     , "mv_par01", "SM0"  , ""			, ""			, ""		, ""			, ""			   , ""     } )
	AADD( _aSx1, { _cPerg , "02"  , "Filial Ate ?", "ï¿½Filial Ate?"	,"Filial Ate?"	, "mv_ch2" , "C"   , 08       , 0        , 0       , "G"  , ""     , "mv_par02", "SM0"  , ""			, ""            , ""        , ""            , ""               , ""     } )
	AADD( _aSx1, { _cPerg , "03"  , "Digit De ?","ï¿½Digit De ? "   	, "Digit De ?"  , "mv_ch3" , "D"   , 08       , 0        , 0       , "G"  , ""     , "mv_par03", ""  	, ""			, ""            , ""        , ""            , ""               , ""     } )
	AADD( _aSx1, { _cPerg , "04"  , "Digit Ate ?", "ï¿½Digit Ate ? " 	, "Digit Ate ?" , "mv_ch4" , "D"   , 08       , 0        , 0       , "G"  , ""     , "mv_par04", ""		, ""			, ""            , ""        , ""            , ""               , ""     } )
	//AADD( _aSx1, { _cPerg , "05"  , "Vencto De ?","ï¿½Vencto De ? "   , "Vencto De ?" , "mv_ch5" , "D"   , 08       , 0        , 0       , "G"  , ""     , "mv_par05", "" 	, ""			, ""            , ""        , ""            , ""               , ""     } )
	//AADD( _aSx1, { _cPerg , "06"  , "Vencto Ate ?", "ï¿½Vencto Ate? " , "Vencto Ate?" , "mv_ch6" , "D"   , 08       , 0        , 0       , "G"  , ""     , "mv_par06", ""		, ""			, ""           	, ""        , ""            , ""               , ""     } )
	AADD( _aSx1, { _cPerg , "05"  , "Possui Anexo ?", "ï¿½Possui Anexo? " , "Possui Anexo?" , 			"mv_ch5" , "C"   , 08 , 0 , 0  , "C"  , "" 	   , "mv_par04", ""     , "1=Sim"		, "2=Nï¿½o" 		, "3=Todos" 		, "" 			, "" 			   , "" 	} )
	AADD( _aSx1, { _cPerg , "06"  , "Status de Recusa ?", "ï¿½Status de Recusa? " , "Status de Recusa?" , "mv_ch6" , "C"   , 08 , 0 , 0  , "C"  , ""     , "mv_par06", ""     , "1=Recusado" 	, "2=Corrigido"	, "3=Todos"	, "4=Em Branco" 			, "" 			   , "" 	} )

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
Fim - Thais Paiva - Compatibilizaï¿½ï¿½o P27*/
