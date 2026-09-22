/*/
=========================================================================================
Data      : 07/03/2019
-----------------------------------------------------------------------------------------
Autor     : Thiago Góes 
-----------------------------------------------------------------------------------------
Descricao : Relatório de duplicidades contábil.
-----------------------------------------------------------------------------------------
Partida   : Menu de Usuário
=========================================================================================
/*/

#include "PROTHEUS.CH"
#Include "TOPCONN.Ch"
#Include "TOTVS.CH"
#Include "RWMAKE.ch"

User Function RDORRA03

	Local _aArea 	  := GetArea()
	Local _cPerg 	  := 'RELDUPLIC'
	Local _cDescPar01 := ''
	Private cEol        := chr(13)+chr(10)
	Private cAlias := GetNextAlias()
 	Private cAliasEst := GetNextAlias()
 	Private cNomInd := "RDORRA03" + "9"+StrZero(Seconds(),5,0)
 	Private cDriver := __LocalDriver
 	Private cExtens := ".DTC"
 	Private cIndArqA := Subs(cNomInd,1,7)+"A"
 	Private cIndArqB := Subs(cNomInd,1,7)+"B"
 	Private aStruct := {}
	

	//FAJUSTSX1( _cPerg ) Thais Paiva - Compatibilização P27

	If ! Pergunte( _cPerg, .T. )
		Return
	EndIf

 //	If MV_PAR01 = 1
 //		_cDescPar01 := "Receber/Provisão"
//	ElseIF MV_PAR01 = 2
	If MV_PAR01 = 1
		_cDescPar01 := "Dup.Provisão"
	ElseIf MV_PAR01 = 2
		_cDescPar01 := "Dup.Baixas"
	EndIf
    
    
	//FRDORRB() // processamento
	//Processa( {|_lEnd| FRDORRB( @_lEnd ) }, "Aguarde...","Processando documentos com inconsistencias...", .T. ) 
	Processa( {|| FRDORRB()}, "Aguarde...","Processando documentos com duplicidades...", .F. )
	//If _lEnd
	//	Return .F.
	//EndIf

	RestArea( _aArea )

Return

***********************
Static Function FRDORRB
***********************

	Local _cPath := "C:\REL_DUPLICIDADES\" 
	Local _cArq := "F1E2COMCTB.CSV"
	Local _lArqCsv 
	Local _cLin  
	Local _cScript := "C:\REL_DUPLICIDADES\F1E2COMCTB"
	Local _cEscrev
//	Local _cEol := "CHR(13)+CHR(10)"
	Local _cQry := ""
	Local _cQry2:= ""
	Local _nContar := 0 
	Local _lGerouExc := .F.     

	ProcRegua( _nContar )

	MONTADIR( _cPath )

	FERASE( _cPath + _cArq )

	If ! File( "C:\REL_DUPLICIDADES\F1E2COMCTB.BAT" )
		_lArqCsv := FCreate( "C:\REL_DUPLICIDADES\F1E2COMCTB.BAT", 0 )
		_cLin    := "ECHO OFF" + cEOL
		_cLin    += "del c:\rel_duplicidades\*F1E2COMCTB*.csv" + cEOL
		fWrite( _lArqCsv, _cLin, _lArqCsv )
		fClose( _lArqCsv )
	EndIf

	If File( "C:\REL_DUPLICIDADES\F1E2COMCTB.CSV" )
		Shellexecute( "Open", "C:\REL_DUPLICIDADES\F1E2COMCTB.BAT", " /k dir ", "c:\", 1 )
	EndIf
	//Início - Alteração da Query para retirar espaçõs desnecessários - Thais Paiva - 04/12/2020
// filial, data, lote, sblote, documento, linha, valor, ,debito, credito,  ccd, ccc, itemd, itemc,hist, tiposald, manual, origem , lp     
    _cQry := " SELECT CT2_FILIAL,"+cEol
    _cQry += "CT2_DATA,"+cEol
    _cQry += "CT2_LOTE,"+cEol
	_cQry += "CT2_SBLOTE,"+cEol
	_cQry += "CT2_DOC,"+cEol
	_cQry += "CT2_LINHA,"+cEol
	_cQry += "CT2_VALOR,"+cEol
	_cQry += "CT2_DEBITO,"+cEol
	_cQry += "CT2_CREDIT,"+cEol  
	_cQry += "CT2_HIST,"+cEol
	_cQry += "CT2_CCD,"+cEol
	_cQry += "CT2_CCC,"+cEol
	_cQry += "CT2_ITEMD,"+cEol
	_cQry += "CT2_ITEMC,"+cEol
	_cQry += "CT2_TPSALD,"+cEol
	_cQry += "CT2_MANUAL,"+cEol
	_cQry += "CT2_ORIGEM,"+cEol
	_cQry += "CT2_LP,"+cEol
	_cQry += "CT2_ROTINA,"+cEol
	_cQry += "CT2_KEY"+cEol
	
//	If MV_PAR01 == 2
// 		_cQry += "  ,E2_NUM, 		"+cEol
// 		_cQry += "  E2_PREFIXO,	"+cEol 
// 		_cQry += "  E2_FORNECE,	"+cEol 
// 		_cQry += "  E2_NOMFOR,	"+cEol  
// 		_cQry += "  E2_EMISSAO,	"+cEol 
// 		_cQry += "  E2_EMIS1,	"+cEol 
// 		_cQry += "  E2_VALOR 	"+cEol
   	If MV_PAR01 == 1
   		_cQry += ",E5_DATA,"+cEol 
    	_cQry += "E5_DTDIGIT,"+cEol 
    	_cQry += "E5_TIPO,"+cEol 
    	_cQry += "E5_MOEDA,"+cEol 
    	_cQry += "E5_VALOR,"+cEol 
    	_cQry += "E5_NATUREZ,"+cEol  
    	_cQry += "E5_BANCO,"+cEol 
    	_cQry += "E5_AGENCIA,"+cEol 
    	_cQry += "E5_CONTA,"+cEol 
    	_cQry += "E5_NUMCHEQ,"+cEol 
    	_cQry += "E5_DOCUMEN"+cEol
   
   	ElseIf MV_PAR01 == 2
 		_cQry += ",F1_DOC,"+cEol
		_cQry += "F1_SERIE,"+cEol
		_cQry += "F1_FORNECE,"+cEol
		_cQry += "A2_NREDUZ ,"+cEol
		_cQry += "F1_EMISSAO,"+cEol
		_cQry += "F1_DTDIGIT,"+cEol
		_cQry += "F1_VALBRUT"+cEol
    
   	EndIf

	_cQry += "	FROM  "+RetSqlName("CT2") +" CT2 "+cEol 
    
    /*
    If MV_PAR01 == 1

    		_cQry += " INNER JOIN "+RetSqlName("SE2")+" E2 ON SUBSTR( CT2_KEY, 12, 9 ) = E2_NUM "+cEol
    		_cQry += " 	AND E2_LA <> ' '                             "+cEol
			_cQry += " 	AND CT2_DATA = E2_EMIS1 AND E2_XID = ' '     "+cEol
			_cQry += "  AND E2_XMIGLT = ' '                          "+cEol
			_cQry += "  AND SUBSTR( CT2_KEY, 1, 8 ) 	= E2_FILIAL	 "+cEol
			_cQry += " 	AND E2_EMIS1 					= CT2_DATA 	 "+cEol
			_cQry += " 	AND SUBSTR( CT2_KEY, 9, 3 ) 	= E2_PREFIXO "+cEol
			_cQry += " 	AND SUBSTR( CT2_KEY, 21, 1 ) 	= E2_PARCELA "+cEol
			_cQry += " 	AND SUBSTR( CT2_KEY, 22, 3 ) 	= E2_TIPO    "+cEol 
			_cQry += "  AND SUBSTR( CT2_KEY, 25, 6 ) 	= E2_FORNECE "+cEol
            _cQry += "  AND E2.D_E_L_E_T_ = CT2.D_E_L_E_T_ 			 "+cEol
            _cQry += "  AND E2_FILIAL = CT2_FILIAL					 "+cEol
    */
    
    If MV_PAR01 ==  1 
			_cQry += "  INNER JOIN "+RetSqlName("SE5")+" E5 ON SUBSTR( CT2_KEY, 11, 3 ) = E5_PREFIXO AND SUBSTR( CT2_KEY, 14, 9 ) = E5_NUMERO "+cEol
			_cQry += "AND E5.D_E_L_E_T_ = CT2.D_E_L_E_T_ "+cEol
			_cQry += "AND E5_DTDIGIT = CT2_DATA "+cEol
			_cQry += "AND E5_FILIAL = CT2_FILIAL " +cEol
			
			If MV_PAR01 == 1
				_cQry += "AND E5_RECPAG = 'P' "+cEol
			EndIf

			_cQry += "AND E5_TIPODOC IN ( 'PA', 'RA', 'BA', 'VL', 'V2', 'AP', 'EP', 'PE', 'RF', 'IF', 'CP', 'TL', 'ES', 'TR', 'DB', 'OD', 'LJ', 'E2', 'TE', '  ' ) "+cEol
			_cQry += "AND (E5_LA <> ' ' OR ((E5_ORDREC||E5_SERREC) <> ' ' AND E5_TIPODOC = 'BA')) " +cEol
			_cQry += "AND E5_MOTBX <> 'DSD' "+cEol
			_cQry += "AND SUBSTR(CT2_KEY,1,8 ) = E5_FILIAL " +cEol
			_cQry += "AND SUBSTR(CT2_KEY,9,2 ) = E5_TIPODOC "+cEol
			_cQry += "AND SUBSTR(CT2_KEY,23,1 ) = E5_PARCELA "+cEol
			_cQry += "AND SUBSTR(CT2_KEY,24,3 ) = E5_TIPO "+cEol
			_cQry += "AND SUBSTR(CT2_KEY,27,8 ) = E5_DATA "+cEol 
			_cQry += "AND SUBSTR(CT2_KEY,35,6 ) = E5_CLIFOR "+cEol
			_cQry += "AND SUBSTR(CT2_KEY,41,2 ) = E5_LOJA "+cEol 
			_cQry += "AND SUBSTR(CT2_KEY,43,2 ) = E5_SEQ "+cEol
      
	ElseIf MV_PAR01 ==  2

			_cQry += "INNER JOIN "+RetSqlName("SF1")+" F1 ON SUBSTR(CT2_KEY,9,9) = F1_DOC "+cEol
			_cQry += "AND SUBSTR( CT2_KEY, 18, 3 ) = F1_SERIE "+cEol
			_cQry += "AND SUBSTR( CT2_KEY, 21, 6 ) = F1_FORNECE "+cEol
			_cQry += "AND F1.D_E_L_E_T_ = CT2.D_E_L_E_T_ "+cEol
			_cQry += "AND CT2_DATA = F1_DTLANC "+cEol
			_cQry += "AND SUBSTR( CT2_KEY, 1, 8 ) = F1_FILIAL  "+cEol
			_cQry += "INNER JOIN "+RetSqlName("SA2")+" A2 ON A2_COD = F1_FORNECE "+cEol
			_cQry += "AND A2_LOJA = F1_LOJA "+cEol
			_cQry += "AND A2.D_E_L_E_T_ = F1.D_E_L_E_T_ "+cEol

	EndIf
    
	_cQry += "WHERE (CT2_FILIAL||CT2_VALOR||CT2_DEBITO||CT2_CREDIT||CT2_CCC||CT2_CCD||CT2_AT01DB||CT2_AT01CR IN "+cEol
	_cQry += "(SELECT a.FILIAL|| a.VALOR|| a.DEBITO||a.CREDITO||a.CUSTOC||a.CUSTOD||a.ATIVDB||a.ATIVCR "+cEol                                                                                           
	_cQry += "FROM( "
	_cQry += "SELECT CT2_FILIAL FILIAL,CT2_VALOR VALOR,CT2_DEBITO DEBITO, CT2_CREDIT CREDITO,CT2_CCC CUSTOC,CT2_CCD CUSTOD,CT2_AT01DB ATIVDB,CT2_AT01CR ATIVCR, COUNT(*) QTD "+cEol
	_cQry += "from "+RetSqlName("CT2")+" tab1 "+cEol
	_cQry += "WHERE CT2_DATA BETWEEN '"+ Dtos( MV_PAR02 ) +"' AND '"+ Dtos( MV_PAR03 ) +"' " +cEol
	_cQry += "AND D_E_L_E_T_ = ' ' " +cEol
	_cQry += "AND CT2_FILIAL = '"+MV_PAR04+"' "+cEol
	_cQry += "AND CT2_TPSALD = '1' "+cEol

	_cQry += "AND CT2_AT01CR <> ' ' "+cEol
	_cQry += "GROUP BY CT2_FILIAL,CT2_VALOR,CT2_DEBITO, CT2_CREDIT,CT2_CCC,CT2_CCD,CT2_AT01DB,CT2_AT01CR ) A "+cEol
	_cQry += "WHERE a.QTD > 1 "+cEol
	_cQry += "GROUP BY a.filial, a.valor,a.debito, a.credito, a.CUSTOD,a.CUSTOC,a.ATIVDB,a.ATIVCR)) "+cEol
	_cQry += "AND CT2.D_E_L_E_T_ = ' ' "+cEol
	_cQry += "AND CT2_VALOR > 0 "+cEol
	_cQry += "AND CT2_XMIGLT =  ' ' "+cEol
	_cQry += "AND CT2_LOTE <> '008890' "+cEol
	_cQry += "AND CT2_FILIAL = '"+MV_PAR04+"' "+cEol
	_cQry += "AND CT2_VALOR > 0 "+cEol
	_cQry += "AND CT2_TPSALD = '1' "+cEol
	_cQry += "AND CT2_AGLUT = '1' "+cEol
	_cQry += "AND CT2_AT01CR <> ' ' "+cEol
	_cQry += "AND CT2_ROTINA NOT IN ('GPEM110') "+cEol
	
	_cQry +="AND CT2_LP NOT IN ('502','514', '515', '531', '564', '565', '578', '579', '589', '655', '805') "+cEol
	_cQry += "ORDER BY CT2_FILIAL, CT2_VALOR, CT2_DATA "+cEol

  	_cQry := ChangeQuery( _cQry )
	//Fim - Alteração da Query para retirar espaçõs desnecessários - Thais Paiva - 04/12/2020

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
       
 		//If MV_PAR01 == 1
        //	_cEscrev := 'MOVIMENTO DE COMPRAS CONTABILIZADOS' + cEOL
		//	_cEscrev += 'FILIAL; DATA CONTÁBIL;LOTE;SUB LOTE;DOCUMENTO CONTÁBIL;LINHA; VALOR CONTÁBIL;DÉBITO;CRÉDITO;'+;
		//				'HISTORICO;CCUSTO DEBITO;CCUSTO CRÉDITO;ITEM DÉBITO; ITEM CRÉDITO;TIPO SALDO; MANUAL; ORIGEM; LP; ROTINA;' +;
		 //           	'NUMERO;PREFIXO;FORNECEDOR;NOME FORNECEDOR;DT EMISSÃO;DATA DIGITAÇÃO;VALOR BRUTO' + cEOL
            
        If MV_PAR01 == 2
			_cEscrev := 'MOVIMENTO DE COMPRAS CONTABILIZADOS' + cEOL
			_cEscrev += 'FILIAL; DATA CONTÁBIL;LOTE;SUB LOTE;DOCUMENTO CONTÁBIL;LINHA; VALOR CONTÁBIL;DÉBITO;CRÉDITO;'+;
						'HISTORICO;CCUSTO DEBITO;CCUSTO CRÉDITO;ITEM DÉBITO; ITEM CRÉDITO;TIPO SALDO; MANUAL; ORIGEM; LP; ROTINA;' +;
						'NOTA FISCAL;SERIE;FORNECEDOR;NOME FANTASIA;EMISSÃO DA NF;DATA DA DIGITAÇÃO;VALOR DA NOTA' + cEOL
		ElseIf MV_PAR01 == 1
        
			_cEscrev := 'MOVIMENTO DE BAIXAS CONTABILIZADOS' + cEOL
			_cEscrev += 'FILIAL; DATA CONTÁBIL;LOTE;SUB LOTE;DOCUMENTO CONTÁBIL;LINHA; VALOR CONTÁBIL;DÉBITO;CRÉDITO;'+;
						'HISTORICO;CCUSTO DEBITO;CCUSTO CRÉDITO;ITEM DÉBITO; ITEM CRÉDITO;TIPO SALDO; MANUAL; ORIGEM; LP; ROTINA;' +;
	       			    'DATA BAIXA;DT DIGITAÇÃO;TIPO;MOEDA;VALOR BAIXA;NATUREZA;BANCO;AGENCIA;CONTA;CHEQUE;DOCUMENTO' + cEOL   
	    Else
	    	_cEscrev := 'MOVIMENTO DE BAIXAS CONTABILIZADOS' + cEOL
			_cEscrev += 'FILIAL; DATA CONTÁBIL;LOTE;SUB LOTE;DOCUMENTO CONTÁBIL;LINHA; VALOR CONTÁBIL;DÉBITO;CRÉDITO;'+;
						'HISTORICO;CCUSTO DEBITO;CCUSTO CRÉDITO;ITEM DÉBITO; ITEM CRÉDITO;TIPO SALDO; MANUAL; ORIGEM; LP; ROTINA' + cEOL 
	    
        EndIf
	   
	   	fWrite( _lArqCsv, _cEscrev, _lArqCsv )
	   	
	   	 //CT2_FILIAL ,CT2_DATA , CT2_LOTE,CT2_SBLOTE, CT2_DOC,CT2_LINHA,CT2_VALOR, 
 	   	//CT2_DEBITO,CT2_CREDIT,	CT2_HIST, CT2_CCD ,	 CT2_CCC ,CT2_ITEMD , CT2_ITEMC , 
   		//CT2_TPSALD , CT2_MANUAL , CT2_ORIGEM , CT2_LP, CT2_ROTINA
    	(cAlias)->( DbGoTop() )

		cDtIni := Dtos( MV_PAR02 )
		cDtFim := Dtos( MV_PAR03 )
		cFilProc := MV_PAR04
		
		_Estornos( cDtini,cDtfim,cFilProc )
		
		
		
		dbSelectArea(cAliasEst)
		(cAliasEst)->( dbSetOrder( 1 ) )
		(cAliasEst)->(dbGoTop())
		
		While (cAlias)->( ! Eof() )
			(cAliasEst)->(dbGoTop())
			IncProc( "Gerando dados Relatorio..." )
            If !((cAliasEst)->(dbSeek(((cAlias)->(CT2_LOTE+CT2_SBLOTE+CT2_CREDIT+CT2_DEBITO+cValToChar(CT2_VALOR))))))
				If MV_PAR01 == 1
				   _cEscrev := "'"+ (cAlias)->CT2_FILIAL + ';';
							+ Dtoc( Stod( (cAlias)->CT2_DATA ) ) + ';' ;
							+ "'" + (cAlias)->CT2_LOTE + ';';
							+ "'" + (cAlias)->CT2_SBLOTE + ';';
							+ "'" + (cAlias)->CT2_DOC + ';';
							+ (cAlias)->CT2_LINHA+';';
							+ TransForm( (cAlias)->CT2_VALOR, '@E 9,999,999,999,999.99' ) + ';' ;
							+ Iif( Empty((cAlias)->CT2_DEBITO), ' ', "'" + (cAlias)->CT2_DEBITO ) + ';'; 
							+ Iif( Empty((cAlias)->CT2_CREDIT), ' ', "'" + (cAlias)->CT2_CREDIT )+ ';'; 
							+ (cAlias)->CT2_HIST + ';'; 
							+ Iif( Empty((cAlias)->CT2_CCD), ' ',"'" + (cAlias)->CT2_CCD) + ';'; 
							+ Iif( Empty((cAlias)->CT2_CCC), ' ',"'" + (cAlias)->CT2_CCC) + ';';
							+ (cAlias)->CT2_ITEMD + ';';
							+ (cAlias)->CT2_ITEMC + ';';
							+ (cAlias)->CT2_TPSALD + ';';
							+ (cAlias)->CT2_MANUAL + ';';
							+ (cAlias)->CT2_ORIGEM + ';';
							+ (cAlias)->CT2_LP + ';';
							+ (cAlias)->CT2_ROTINA+';';
							+ Dtoc( Stod( (cAlias)->E5_DATA))	+ ';'; 
							+ Dtoc( Stod( (cAlias)->E5_DTDIGIT))+ ';'; 
							+ (cAlias)->E5_TIPO	+ ';';
							+ (cAlias)->E5_MOEDA	+ ';'; 
							+ TransForm( (cAlias)->E5_VALOR, '@E 99,999,999,999.99' ) + ';';
							+ "'" + (cAlias)->E5_NATUREZ+ ';';
							+ "'" + (cAlias)->E5_BANCO	+ ';'; 
							+ "'" + (cAlias)->E5_AGENCIA+ ';';
							+ "'" + (cAlias)->E5_CONTA	+ ';'; 
							+ Iif( Empty((cAlias)->E5_NUMCHEQ), ' ',"'" + (cAlias)->E5_NUMCHEQ)  + ';';
							+ "'" + (cAlias)->E5_DOCUMEN  +';'+cEOL
				// F1_DOC ,F1_SERIE ,F1_FORNECE, A2_NREDUZ, F1_EMISSAO  ,F1_DTDIGIT, F1_VALBRUT
				ElseIf MV_PAR01 == 2
					   _cEscrev := "'"  + (cAlias)->CT2_FILIAL + ';';
							+ Dtoc( Stod( (cAlias)->CT2_DATA ) ) + ';' ;
							+ "'" + (cAlias)->CT2_LOTE + ';';
							+ "'" + (cAlias)->CT2_SBLOTE + ';';
							+ "'" + (cAlias)->CT2_DOC + ';';
							+ (cAlias)->CT2_LINHA+';';
							+ TransForm( (cAlias)->CT2_VALOR, '@E 9,999,999,999,999.99' ) + ';' ;
							+ Iif( Empty((cAlias)->CT2_DEBITO), ' ',"'" + (cAlias)->CT2_DEBITO) + ';'; 
							+ Iif( Empty((cAlias)->CT2_CREDIT), ' ',"'" + (cAlias)->CT2_CREDIT) + ';'; 
							+ "'" + (cAlias)->CT2_HIST + ';'; 
							+ Iif( Empty((cAlias)->CT2_CCD), ' ',"'" + (cAlias)->CT2_CCD) + ';'; 
							+ Iif( Empty((cAlias)->CT2_CCC), ' ',"'" + (cAlias)->CT2_CCC) + ';';
							+ (cAlias)->CT2_ITEMD + ';';
							+ (cAlias)->CT2_ITEMC + ';';
							+ (cAlias)->CT2_TPSALD + ';';
							+ (cAlias)->CT2_MANUAL + ';';
							+ "'" + (cAlias)->CT2_ORIGEM + ';';
							+ (cAlias)->CT2_LP + ';';
							+ "'" + (cAlias)->CT2_ROTINA+';';
							+ "'" + (cAlias)->F1_DOC + ';'; 
							+ "'" + (cAlias)->F1_SERIE + ';'; 
							+ "'" + (cAlias)->F1_FORNECE + ';'; 
							+ "'" + (cAlias)->A2_NREDUZ + ';'; 
							+ Dtoc( Stod( (cAlias)->F1_EMISSAO ) ) + ';'; 
							+ Dtoc( Stod( (cAlias)->F1_DTDIGIT ) ) + ';'; 
							+ TransForm( (cAlias)->F1_VALBRUT, '@E 99,999,999,999.99' )+';'+cEOL
				Else
					_cEscrev := "'" + (cAlias)->CT2_FILIAL + ';';
							+ Dtoc( Stod( (cAlias)->CT2_DATA ) ) + ';' ;
							+ "'" + (cAlias)->CT2_LOTE + ';';
							+ "'" + (cAlias)->CT2_SBLOTE + ';';
							+ "'" + (cAlias)->CT2_DOC + ';';
							+ (cAlias)->CT2_LINHA+';';
							+ TransForm( (cAlias)->CT2_VALOR, '@E 9,999,999,999,999.99' ) + ';' ;
							+ Iif( Empty((cAlias)->CT2_DEBITO), ' ',"'" + (cAlias)->CT2_DEBITO) + ';'; 
							+ Iif( Empty((cAlias)->CT2_CREDIT), ' ',"'" + (cAlias)->CT2_CREDIT) + ';'; 
							+ (cAlias)->CT2_HIST + ';'; 
							+ Iif( Empty((cAlias)->CT2_CCD), ' ',"'" + (cAlias)->CT2_CCD) + ';'; 
							+ Iif( Empty((cAlias)->CT2_CCC), ' ',"'" + (cAlias)->CT2_CCC) + ';';
							+ (cAlias)->CT2_ITEMD + ';';
							+ (cAlias)->CT2_ITEMC + ';';
							+ (cAlias)->CT2_TPSALD + ';';
							+ (cAlias)->CT2_MANUAL + ';';
							+ (cAlias)->CT2_ORIGEM + ';';
							+ (cAlias)->CT2_LP + ';';
							+ (cAlias)->CT2_ROTINA+';'+cEOL 
				
				EndIf  
				fWrite( _lArqCsv, _cEscrev, _lArqCsv )
			EndIf
			(cAlias)->( DbSkip() )
		EndDo
	EndIf

	If _lGerouExc
		fClose( _lArqCsv )

		Aviso( 'INFO', 'O processamento de documentos contabilizados está terminado ' +;
	                   'e seu excel será aberto.', { 'Fechar' } )

	    Shellexecute( "Open", _cScript + ".CSV", " /k dir ", "c:\", 1 )
	EndIf
	
	(cAliasEst)->( dbCloseArea() )
 	If File( cNomInd + cExtens )
		Ferase( cNomInd + cExtens )
 	
		Ferase( cIndArqB + OrdBagExt() )
 	EndIf
	oTempTable:Delete() //Thais Paiva - 04/12/2020
Return

/*Início - Thais Paiva - Compatibilização P27
***********************************
Static Function FAJUSTSX1( _cPerg )
***********************************

	Local _aSx1 := {}, _cCampo

	AADD( _aSx1, { "GRUPO","ORDEM","PERGUNT"         , "PERSPA"      , "PERENG"     , "VARIAVL", "TIPO", "TAMANHO", "DECIMAL", "PRESEL", "GSC", "VALID", "VAR01"   , "F3", "DEF01"           , "DEF02"         , "DEF03"         , "DEF04"       , "DEF05"          , "HELP" } )
	AADD( _aSx1, { _cPerg , "01"  , "Carteira ?"     , "¿Carteira ?" , "Portfolio ?", "mv_ch1" , "N"   , 01       , 0        , 4       , "C"  , ""     , "mv_par01", ""  , "Duplic Baixas", "Duplic Provisão", "Duplicidades", "", "", ""     } )
	AADD( _aSx1, { _cPerg , "02"  , "Da Data ?      ", "¿De Fecha ? ", "From Date ?", "mv_ch2" , "D"   , 08       , 0        , 0       , "G"  , ""     , "mv_par02", ""  , ""                , ""              , ""              , ""            , ""               , ""     } )
	AADD( _aSx1, { _cPerg , "03"  , "Até a Data ?   ", "¿A Fecha ? " , "To Date ?"  , "mv_ch3" , "D"   , 08       , 0        , 0       , "G"  , ""     , "mv_par03", ""  , ""                , ""              , ""              , ""            , ""               , ""     } )
	AADD( _aSx1, { _cPerg , "04"  , "Filial ?   	", "¿Filial ? "  , "Filial ?"   , "mv_ch4" , "C"   , 08       , 0        , 0       , "G"  , ""     , "mv_par04", "SM0",""             , ""              , ""              , ""            , ""               , ""     } )

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

static function _Estornos( cDtini,cDtfim,cFilProc )
 
 Local _cQry2 := " "
 Local cChave := " "
 
 
 _cQry2 := " SELECT CT2_FILIAL,CT2_LOTE,CT2_SBLOTE,CT2_DOC, CT2_VALOR,CT2_HIST,CT2_KEY, CT2_AT01DB, CT2_AT01CR, CT2_ORIGEM,CT2_DEBITO,CT2_CREDIT" +cEol
 _cQry2 += " From "+RetSqlName("CT2")+" TAB1 "+cEol
 _cQry2 += " WHERE TAB1.CT2_XMIGLT = ' ' "+cEol
 _cQry2 += " AND TAB1.CT2_DATA BETWEEN '" + cDtini + "' AND '" + cDtFim + "' "+cEol
 _cQry2 += " AND TAB1.CT2_FILIAL = '" +cFilProc+ "' "+cEol
 _cQry2 += " AND TAB1.D_E_L_E_T_ = ' ' "+cEol
 _cQry2 += " AND TAB1.CT2_LOTE <> '008890' "+cEol
 _cQry2 += " AND TAB1.CT2_VALOR > 0 "+cEol
 _cQry2 += " AND TAB1.CT2_TPSALD = '1' "+cEol
 _cQry2 += " AND ((TAB1.CT2_ROTINA NOT IN ( 'CTBA102', 'CTBA500','GPEM110') "+cEol
 _cQry2 += " AND TAB1.CT2_LP IN ('502', '514', '515', '531', '564', '565', '578', '579', '589', '655', '805') "+cEol
 _cQry2 += " AND TAB1.CT2_HIST LIKE 'EST%')) " +cEol
 
 
 AADD(aStruct, {"CT2_FILIAL" , TamSx3("CT2_FILIAL")[3], TamSx3("CT2_FILIAL")[1], TamSx3("CT2_FILIAL")[2] })
 AADD(aStruct, {"CT2_LOTE" , TamSx3("CT2_LOTE")[3] , TamSx3("CT2_LOTE")[1] , TamSx3("CT2_LOTE")[2] })
 AADD(aStruct, {"CT2_SBLOTE" , TamSx3("CT2_SBLOTE")[3], TamSx3("CT2_SBLOTE")[1], TamSx3("CT2_SBLOTE")[2] })
 AADD(aStruct, {"CT2_VALOR" , TamSx3("CT2_VALOR")[3] , TamSx3("CT2_VALOR")[1] , TamSx3("CT2_VALOR")[2] })
 AADD(aStruct, {"CT2_KEY" , TamSx3("CT2_KEY")[3] , TamSx3("CT2_KEY")[1] , TamSx3("CT2_KEY")[2] })
 AADD(aStruct, {"CT2_AT01DB" , TamSx3("CT2_AT01DB")[3], TamSx3("CT2_AT01DB")[1], TamSx3("CT2_AT01DB")[2] })
 AADD(aStruct, {"CT2_AT01CR" , TamSx3("CT2_AT01CR")[3], TamSx3("CT2_AT01CR")[1], TamSx3("CT2_AT01CR")[2] })
 AADD(aStruct, {"CT2_ORIGEM" , TamSx3("CT2_ORIGEM")[3], TamSx3("CT2_ORIGEM")[1], TamSx3("CT2_ORIGEM")[2] })
 AADD(aStruct, {"CT2_DEBITO" , TamSx3("CT2_DEBITO")[3], TamSx3("CT2_DEBITO")[1], TamSx3("CT2_DEBITO")[2] })
 AADD(aStruct, {"CT2_CREDIT" , TamSx3("CT2_CREDIT")[3], TamSx3("CT2_CREDIT")[1], TamSx3("CT2_CREDIT")[2] })
 
 //Início - Thais Paiva - Compatibilização P27
 //cArqTrab := CriaTrab( aStruct, .F. )
 
 //dbCreate( cNomInd, aStruct, cDriver )
 //dbUseArea( .T. ,, cNomInd, cAliasEst, .T. , .F. )

 
// cChave := "CT2_LOTE+CT2_SBLOTE+CT2_DEBITO+CT2_CREDIT+cValtoChar(CT2_VALOR)"

oTempTable := FWTemporaryTable():New( cAliasEst )
oTemptable:SetFields( aStruct )
oTempTable:AddIndex( '01' , { "CT2_LOTE","CT2_SBLOTE","CT2_DEBITO","CT2_CREDIT","cValtoChar(CT2_VALOR)"} )
oTempTable:Create()
 
 
 //IndRegua( cAliasEst, cIndArqA,cChave,,,"Selecionando Registros...")
 //IndRegua( cAliasEst, cIndArqB,"CT2_KEY",,,"Selecionando Registros...")
 
 //dbClearIndex()
 //dbSetIndex( cIndArqA + OrdBagExt() )
 //dbSetIndex( cIndArqB + OrdBagExt() )
 //Fim - Thais Paiva - Compatibilização P27
 
 SqlToTrb( _cQry2, aStruct, cAliasEst )
 
 
 (cAliasEst)->( dbSetOrder( 1 ) )
 
 
return _cQry2
 
static function AtivDB( cDtini,cDtfim,cFilProc,cFilProc,cDtini )
local _cQry := ""
 
_cQry += " SELECT CT2_FILIAL, "+ cEOL
_cQry += " CT2_DATA, "+ cEOL
_cQry += " CT2_LOTE, "+ cEOL
_cQry += " CT2_SBLOTE, "+ cEOL
_cQry += " CT2_DOC, "+ cEOL
_cQry += " CT2_LINHA, "+ cEOL
_cQry += " CT2_VALOR, "+ cEOL
_cQry += " CT2_DEBITO, "+ cEOL
_cQry += " CT2_CREDIT, "+ cEOL
_cQry += " CT2_HIST, "+ cEOL
_cQry += " CT2_CCD, "+ cEOL
_cQry += " CT2_CCC, "+ cEOL
_cQry += " CT2_ITEMD, "+ cEOL
_cQry += " CT2_ITEMC, "+ cEOL
_cQry += " CT2_TPSALD, "+ cEOL
_cQry += " CT2_MANUAL, "+ cEOL
_cQry += " CT2_ORIGEM, "+ cEOL
_cQry += " CT2_LP, "+ cEOL
_cQry += " CT2_ROTINA, "+ cEOL
_cQry += " CT2_KEY "+ cEOL
_cQry += " FROM "+RetSqlName("CT2")+" CT2 "+ cEOL
_cQry += " WHERE (CT2_FILIAL|| CT2_VALOR||CT2_AT01DB||CT2_AT01CR) IN "+ cEOL
_cQry += " (SELECT a.FILIAL|| a.VALOR|| a.ATIVCR||a.ATIVDB "+ cEOL
_cQry += " FROM( SELECT CT2_FILIAL FILIAL,CT2_VALOR VALOR,CT2_AT01DB ATIVDB,CT2_AT01CR ATIVCR, COUNT(*) QTD "+ cEOL
_cQry += " FROM "+RetSqlName("CT2")+" tab1 "+ cEOL
_cQry += " WHERE CT2_DATA BETWEEN '" + cDtini + "' AND '" + cDtfim + "' "+ cEOL
_cQry += " AND D_E_L_E_T_ = ' ' "+ cEOL
_cQry += " AND CT2_FILIAL = '" + cFilProc + "' "+ cEOL
_cQry += " AND CT2_TPSALD = '1' "+ cEOL
 
_cQry += " GROUP BY CT2_FILIAL,CT2_VALOR,CT2_AT01DB,CT2_AT01CR ) A "+ cEOL
_cQry += " WHERE a.QTD > 1 "+ cEOL
_cQry += " GROUP BY a.filial, a.valor,a.ATIVDB,a.ATIVCR) "+ cEOL
_cQry += " AND CT2.D_E_L_E_T_ = ' ' "+ cEOL
_cQry += " AND CT2_VALOR > 0 "+ cEOL
_cQry += " AND CT2_XMIGLT = ' ' "+ cEOL
_cQry += " AND CT2_LOTE <> '008890' "+ cEOL
_cQry += " AND CT2_FILIAL = '" + cFilProc + "' "+ cEOL
_cQry += " AND CT2_VALOR > 0 "+ cEOL
_cQry += " AND CT2_TPSALD = '1' "+ cEOL
 
_cQry += " AND CT2_ROTINA NOT IN ('GPEM110') "+ cEOL
_cQry += " AND CT2_DATA >= '" + cDtini + "' "+ cEOL
_cQry += " AND CT2_AT01CR <> ' ' "+ cEOL
_cQry += " ORDER BY CT2_FILIAL, CT2_VALOR, CT2_HIST, CT2_ORIGEM "
 
return _cQry
 