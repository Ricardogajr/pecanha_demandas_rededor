/*/
=========================================================================================
Data      : 07/03/2019
-----------------------------------------------------------------------------------------
Autor     : Thiago Góes 
-----------------------------------------------------------------------------------------
Descricao : Relatório de Liberação do CAP
-----------------------------------------------------------------------------------------
Partida   : Menu de Usuário
=========================================================================================
/*/

#include "PROTHEUS.CH"	
#Include "TOPCONN.Ch"
#Include "TOTVS.CH"
#Include "RWMAKE.ch"

User Function RDORRA05

	Local _aArea 	  	:= GetArea()
	Local _cPerg 	  	:= 'RDORRA05'
	Local _cDescPar01 	:= ' '
	Private cEol        := chr(13)+chr(10)
   	Private cAliasTmp	:= GetNextAlias() 
    Private cAliasEst 	:= GetNextAlias()   
    Private cNomInd  	:= "RDORRA05" + "9"+StrZero(Seconds(),5,0)
 	Private cDriver		:= __LocalDriver
 	Private cExtens		:= '.DTC'
 	Private cIndArqA	:= Subs(cNomInd,1,7)+"A"
 	Private cIndArqB	:= Subs(cNomInd,1,7)+"B"
 	Private aStruct		:=  {}

	//FAJUSTSX1( _cPerg ) Thais Paiva - Compatibilização P27

	If ! Pergunte( _cPerg, .T. )
		Return
	EndIf
    
    //If lOk
//    oProcess := MsNewProcess():New( { | lEnd | FRDORRB( @lEnd, @oProcess) }, "Atualizando", "Processando Relatório de Liberação do CAP...", .T. )
//    oProcess:Activate()
    //EndIf

	Processa( {|| FRDORRB()}, "Aguarde...","Processando Relatório de Liberação do CAP...", .F. )

	RestArea( _aArea )

Return

***********************
Static Function FRDORRB
***********************

	Local _cPath := "C:\REL_LIBERACAO\" 
	Local _cArq := "LIBERACAO"+"_"+StrZero(Seconds(),5,0)+".CSV"
	Local _lArqCsv 
	Local _cLin  
	Local _cScript := "C:\REL_LIBERACAO\LIBERACAO"
	Local _cEscrev
//	Local _cEol := "CHR(13)+CHR(10)"
	Local _cQry := " " 
	Local _cQry2:= " "
	Local _nContar := 0 
	Local _lGerouExc := .F.     
	Local Nx := 0

 //	ProcRegua( _nContar )

	MONTADIR( _cPath )

	FERASE( _cPath + _cArq )

	If ! File( "C:\REL_LIBERACAO\LIBERACAO.BAT" )
		_lArqCsv := FCreate( "C:\REL_LIBERACAO\LIBERACAO.BAT", 0 )
		_cLin    := "ECHO OFF" + cEOL
		_cLin    += "del C:\REL_LIBERACAO\*LIBERACAO*.csv" + cEOL
		fWrite( _lArqCsv, _cLin, _lArqCsv )
		fClose( _lArqCsv )
	EndIf

	If File( "C:\REL_LIBERACAO\LIBERACAO.CSV" )
		Shellexecute( "Open", "C:\REL_LIBERACAO\LIBERACAO.BAT", " /k dir ", "c:\", 1 )
	EndIf
    

 _cQry := " SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_XTPREQ, E2_FORNECE, E2_NOMFOR, E2_EMISSAO, E2_VENCREA, E2_VALOR, E2_EMIS1, REPLACE(E2_HIST,';','/') E2_HIST, E2_XSTRECU, "+cEol
 _cQry += " 		  CASE WHEN P09_CODORI IS NOT NULL THEN 'S' ELSE 'N' END AS ANEXO " + cEol
 _cQry += "  FROM "+RetSqlName("SE2") +" E2 "+cEol
 _cQry += " 	LEFT JOIN "+RetSqlName("P09") +" P09 " + cEol
 _cQry += "	  ON P09_FILIAL = E2_FILIAL "+cEol
 _cQry += " 	    AND SUBSTR(P09_CODORI,1,9)  = E2_NUM "+cEol
 _cQry += " 	    AND SUBSTR(P09_CODORI,10,3) = E2_PREFIXO  "+cEol
 _cQry += " 	    AND SUBSTR(P09_CODORI,13,6) = E2_FORNECE "+cEol
 _cQry += " 	    AND SUBSTR(P09_CODORI,19,2) = E2_LOJA "+cEol
 _cQry += " 	    AND P09.D_E_L_E_T_ = E2.D_E_L_E_T_  "+cEol
 _cQry += "    WHERE E2_DATALIB = ' ' "+cEol 
 _cQry += "        AND (E2_TIPO <>  'TX' OR E2_PREFIXO IN ('AGI', 'AGP', 'AGL', 'GPE' )) "+cEol
 _cQry += "        AND E2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"+cEol
 //_cQry += "        AND E2_VENCREA BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"'"+cEol
 _cQry += "        AND E2_EMIS1 BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"'"+cEol
 _cQry += "        AND E2_BAIXA = ' ' AND E2.D_E_L_E_T_ = ' ' "  

 If MV_PAR05 <> 3
	_cQry += " 	      AND P09_CODORI IS " + IIF(MV_PAR05 == 1,'NOT','') + " NULL " + cEol
 Endif

 If MV_PAR06 == 1 //Recusado
	_cQry += " 	    AND (E2_XSTRECU = 'R') "+cEol
 ElseIf MV_PAR06 == 2 //Corrigido
	_cQry += " 	    AND (E2_XSTRECU = 'C') "+cEol
 ElseIf MV_PAR06 == 4 //Em branco
	_cQry += " 	    AND (E2_XSTRECU = '') "+cEol
 Endif
  
// 	_cQry := ChangeQuery( _cQry )

   //	DdbUsearea(.T.,"TOPCONN",TCGenQry(,,_cQry), 'TCT2') 
   //TCQUERY _cQry NEW ALIAS 'TCT2'
   	DbUseArea(.F., "TOPCONN", TcGenQry(,, _cQry), cAliasTmp, .f., .f.) 
	
//	If (cAliasTmp) >0; (cAliasTmp)->(dbCloseArea());EndIf 
	
	DbSelectArea(cAliasTmp) 
 	(cAliasTmp)->(dbGotop())
	
//  	Count to _nCount

 	(cAliasTmp)->(dbGotop())

 //	If Select( 'TCT2' ) > 0; TCT2->( DbCloseArea() ); EndIf
	//TCQUERY _cQry NEW ALIAS 'TCT2'
//      
 //oObj:SetRegua1(nTotal)
  // _nContar:= 1000
//   oProcess:SetRegua(_nContar)
   
    ProcRegua( _nContar )

    
//	dbSelectArea(cAliasTmp)             
//	(cAliasTmp)->( DbGoTop() )
	
	
	
 	If Select(cAliasTmp) >0 
		_lGerouExc := .T.

		_lArqCsv := FCreate( _cScript + ".CSV", 0 )
        
       // E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_XTPREQ, E2_FORNECE, E2_NOMFOR, E2_EMISSAO, E2_VENCREA, E2_VALOR, E2_EMIS1, E2_HIST
	   // _cQry += " 	C7_DESCRI,C7_NUM  "+cEol
	
 		_cEscrev := 'LIBERACAO DO CAP' + cEOL
		_cEscrev += 'FILIAL; PREFIXO;NUMERO;PARCELA;TIPO;TP REQUISICAO;FORNECE;NOME FORNECEDOR;EMISSAO;VENCTO REAL;VALOR; DATA CONTABIL; HISTORICO; POSSUI ANEXO; STATUS RECUSA;'+ cEOL
		    
 	   	fWrite( _lArqCsv, _cEscrev, _lArqCsv )
	   	
 	  	//(cAliasTmp)->( DbGoTop() )
    	
    	//cDtIni := Dtos( MV_PAR02 )
    	//cDtFim := Dtos( MV_PAR03 )
    	//cFilProc :=  MV_PAR04 
    	
    	//_Estornos( cDtini,cDtfim,cFilProc )
        
    //    If Select(cAliasTmpEst) > 0 ; (cAliasTmpEst)->(dbCloseArea()) ;  EndIf
        
	    //dbSelectArea(cAliasTmpEst)
		//(cAliasTmpEst)->( dbSetOrder( 1 ) ) 
		//(cAliasTmpEst)->(dbGoTop())

    	While (cAliasTmp)->( ! Eof() )
//    		Nx++    
//    		(cAliasTmpEst)->(dbGoTop())
  			IncProc( "Gerando dados Relatorio...")
//		      If !((cAliasTmpEst)->(dbSeek(((cAliasTmp)->(CT2_LOTE+CT2_SBLOTE+CT2_CREDIT+CT2_DEBITO+cValToChar(CT2_VALOR))))))
//		        	If MV_PAR01 == 1
//	_cQry += " 	,,,,,,,,,,,, "+cEol 
//	_cQry += " 	,  "+cEol
//E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_XTPREQ, E2_FORNECE, E2_NOMFOR, E2_EMISSAO, E2_VENCREA, E2_VALOR, E2_EMIS1, E2_HIST
		   _cEscrev := "'"+ (cAliasTmp)->E2_FILIAL 		+ ';';  
	                + (cAliasTmp)->E2_PREFIXO				+ ';' ;
           		   	+ "'" + (cAliasTmp)->E2_NUM 			+ ';';
  					+ "'" + (cAliasTmp)->E2_PARCELA		+ ';';  
  					+ (cAliasTmp)->E2_TIPO					+ ';';  
  					+ (cAliasTmp)->E2_XTPREQ 				+ ';';
  					+ "'" + (cAliasTmp)->E2_FORNECE		+ ';';
  			  		+ (cAliasTmp)->E2_NOMFOR				+ ';';
  			  	 	+ Dtoc( Stod( (cAliasTmp)->E2_EMISSAO))+ ';';
       			  	+ Dtoc( Stod( (cAliasTmp)->E2_VENCREA))+ ';';
   				    + TransForm( (cAliasTmp)->E2_VALOR, '@E 9,999,999,999,999.99' ) + ';' ;
      			 	+ Dtoc( Stod( (cAliasTmp)->E2_EMIS1))	+ ';';
   					+ (cAliasTmp)->E2_HIST			    	+ ';';
					+ (cAliasTmp)->ANEXO			    	+ ';';
					+ (cAliasTmp)->E2_XSTRECU				+ cEOL

					fWrite( _lArqCsv, _cEscrev, _lArqCsv )
			(cAliasTmp)->( DbSkip() )
		EndDo
		_lGerouExc := .T.
    EndIf
    
	If _lGerouExc
		fClose( _lArqCsv )

		Aviso( 'INFO', 'O Relatorio de LIBERACAO do CAP está finalizado,' +;
	                   ' seu excel será aberto.', { 'Fechar' } )

	    Shellexecute( "Open", _cScript + ".CSV", " /k dir ", "c:\", 1 )
	EndIf
	
	(cAliasTmp)->( dbCloseArea() )
	If File( cNomInd + cExtens )     //Elimina o arquivo de trabalho
		Ferase( cNomInd + cExtens )
		Ferase( cIndArqB + OrdBagExt() )
	EndIf
	
Return

/*Início - Thais Paiva - Compatibilização P27
***********************************
Static Function FAJUSTSX1( _cPerg )
***********************************

	Local _aSx1 := {}, _cCampo
	Local _X1 := 0
	Local _Z := 0

	AADD( _aSx1, { "GRUPO","ORDEM","PERGUNT"      	, "PERSPA"       	, "PERENG"     	, "VARIAVL", "TIPO", "TAMANHO", "DECIMAL", "PRESEL", "GSC", "VALID", "VAR01"   , "F3", "DEF01"           , "DEF02"         , "DEF03"         , "DEF04"       , "DEF05"          , "HELP" } )
	AADD( _aSx1, { _cPerg , "01"  , "Filial de  ?"	, "¿Filial de?"  	, "Filial de?" 	, "mv_ch1" , "C"   , 08       , 0        , 0       , "C"  , ""     , "mv_par01", "SM0"  , "", ""			  , ""				, ""			, ""			   , ""     } )
	AADD( _aSx1, { _cPerg , "02"  , "Filial Ate ?"	, "¿Filial Ate?"	,"Filial Ate?"	, "mv_ch2" , "C"   , 08       , 0        , 0       , "G"  , ""     , "mv_par02", "SM0"  , "", ""              , ""              , ""            , ""               , ""     } )
	//AADD( _aSx1, { _cPerg , "03"  , "Vencto De ?"	,"¿Vencto De ? "   	, "Vencto De ?" , "mv_ch3" , "D"   , 08       , 0        , 0       , "G"  , ""     , "mv_par03", ""  	, "", ""              , ""              , ""            , ""               , ""     } )
	//AADD( _aSx1, { _cPerg , "04"  , "Vencto Ate ?", "¿Vencto Ate ? " 	, "Vencto Ate ?" , "mv_ch4" , "D"   , 08       , 0        , 0       , "G"  , ""     , "mv_par04", ""		, "", ""              , ""              , ""            , ""               , ""     } )
	AADD( _aSx1, { _cPerg , "03"  , "Dt Cont. De ?","¿Dt Cont. De ? "   , "Dt Cont. De ?" , "mv_ch3" , "D"   , 08       , 0        , 0       , "G"  , ""     , "mv_par03", "" 	, "", ""              , ""              , ""            , ""               , ""     } )
	AADD( _aSx1, { _cPerg , "04"  , "Dt Cont. Ate ?", "¿Dt Cont. Ate ? " , "Dt Cont. Ate ?" , "mv_ch4" , "D"   , 08       , 0        , 0       , "G"  , ""     , "mv_par04", ""		, "", ""              , ""              , ""            , ""               , ""     } )
	AADD( _aSx1, { _cPerg , "05"  , "Possui Anexo ?", "¿Possui Anexo? " , "Possui Anexo?" , "mv_ch5" , "C"   , 08 , 0 , 0  , "C"  , "" 	   						, "mv_par05", ""     , "1=Sim"		, "2=Não" 		, "3=Todos" 		, "" 			, "" 			   , "" 	} )
	AADD( _aSx1, { _cPerg , "06"  , "Status de Recusa ?", "¿Status de Recusa? " , "Status de Recusa?" , "mv_ch6" , "C"   , 08 , 0 , 0  , "C"  , ""     			, "mv_par06", ""     , "1=Recusado" 	, "2=Corrigido"	, "3=Todos"	, "4=Em Branco" 			, "" 			   , "" 	} )

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
Fim Thais Paiva - Compatibilização P27*/