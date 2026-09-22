#Include 'Protheus.ch'
Static lNMenu	:= Isblind() 
Static cPrfTab	:= Alltrim(SuperGetMV('ES_PRFTBMG',,'ARQ'))
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MGMIGSD3
(long_description)
@type function
@author Cris
@since 28/08/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///---------------------------------------------------------------------------------------------------------------------------
User Function MGMIGSD3()

	Local aArea		:= FWGetArea()
	Local aLotes	:= {}
	Local nLote		:= 0	
		
		if MsgYesNo('Deseja efetivar lotes pendentes?')		
			
			LotePend(@aLotes)
			
			For nLote := 1 to len(aLotes)
				
				Conout('Iniciando inclusão na tabela definitiva referente aos dados contidos no lote '+aLotes[nLote]+' Data '+Dtoc(Msdate())+' hora '+time())
			
				if !lNMenu
				
					FWMsgRun(,{||  EfetSD3(aLotes[nLote]) },'Aguarde....' ,'Gravando registros do lote '+aLotes[nLote]) 
					
				Else
				
					EfetSD3(aLotes[nLote])
				
				EndIf
				
				Conout('Término inclusão na tabela definitiva referente aos dados contidos no  lote '+aLotes[nLote]+' Data '+Dtoc(Msdate())+' hora '+time())
						
			Next nLote
			
			
		EndIf

	Aviso("TÉRMINO - EFETIVAÇÃO", 'Efetivação finalizada.', {'OK'},3)
	
	RestArea(aArea)
	
Return
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LotePend
(long_description)
@type function
@author Cris
@since 24/08/2017
@version 1.0
@param aLotes, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function LotePend(aLotes)

	Local cQry		:= ''
	Local cTabLt	:= GetNextAlias()
	
		//Descomentar e substituir pelo select abaixo caso a tabela RESUMO tenha sido utilizada para controle do LOAD DATA, caso contrário, não utilizar
		/*
		cQry	:= "	SELECT NUMEROLOTE "+CRLF
		cQry	+= "	FROM "+cPrfTab+"SD3_RESUMO	 "+CRLF
		cQry	+= "	WHERE StatusImp	= '0' "+CRLF
		cQry	+= "	  AND StatusVld	= '1' "+CRLF
			*/
		if len(U_TabExist(+cPrfTab+"SD3")) > 0
			
			cQry	:= "	SELECT DISTINCT(NUMEROLOTE) "+CRLF
			cQry	+= "	FROM "+cPrfTab+"SD3 "+CRLF
			cQry	+= "	WHERE REGISTRO_VALIDO <> ' ' "+CRLF
			cQry	+= "	  AND DATAHORAMIG = ' '"+CRLF				
													
			cQry := ChangeQuery(cQry)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cTabLt,.T.,.T.)				
			
			if !(cTabLt)->(Eof())	
			
				While  !(cTabLt)->(Eof())	
				
					aAdd(aLotes,(cTabLt)->NUMEROLOTE)
				
				(cTabLt)->(dbSkip())
				EndDo
						
			EndIf
		
		EndIf
		
		(cTabLt)->(dbCloseArea())
		
Return 
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EfetSD3
(long_description)
@type function
@author Cris
@since 28/08/2017
@version 1.0
@param cNumLAtu, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function EfetSD3(cNumLAtu)

	Local cInsert	:= ''
	Local _cRetSQL	
	
		cInsert	:= "	INSERT INTO "+REtSqlName("SD3")+"(	D3_FILIAL,D3_TM,D3_COD,D3_UM,D3_QUANT,D3_CF,D3_CONTA,D3_OP,D3_LOCAL,"+CRLF
		cInsert	+= "										D3_DOC,D3_EMISSAO,D3_GRUPO,D3_CUSTO1,D3_CUSTO2,"+CRLF
		cInsert	+= "		                 				D3_CUSTO3,D3_CUSTO4,D3_CUSTO5,D3_CC,D3_PARCTOT,D3_ESTORNO,D3_NUMSEQ,D3_SEGUM,"+CRLF
		cInsert	+= "		                 				D3_QTSEGUM,D3_TIPO,D3_NIVEL,D3_USUARIO,D3_REGWMS,"+CRLF
		cInsert	+= "						         		D3_PERDA,D3_DTLANC,D3_TRT,D3_CHAVE,D3_IDENT,D3_SEQCALC,D3_RATEIO,"+CRLF
		cInsert	+= "										D3_LOTECTL,D3_NUMLOTE,D3_DTVALID,D3_LOCALIZ,D3_NUMSERI,D3_CUSFF1,D3_CUSFF2,D3_CUSFF3,"+CRLF
		cInsert	+= "										D3_CUSFF4,D3_CUSFF5,D3_ITEM,D3_OK,D3_ITEMCTA,D3_CLVL,D3_PROJPMS,D3_TASKPMS,"+CRLF
		cInsert	+= "	                   					D3_ORDEM,D3_SERVIC,D3_STSERV,D3_OSTEC,D3_POTENCI,D3_TPESTR,D3_REGATEN,D3_ITEMSWN,"+CRLF
		cInsert	+= "										D3_DOCSWN,D3_ITEMGRD,D3_STATUS,D3_CUSRP1,D3_CUSRP2,D3_CUSRP3,D3_CUSRP4,D3_CUSRP5,"+CRLF
		cInsert	+= "	                    				D3_CMRP,D3_MOEDRP,D3_REVISAO,D3_EMPOP,D3_CMFIXO,D3_PMACNUT,D3_PMICNUT,D3_DIACTB,"+CRLF
		cInsert	+= "										D3_GARANTI,D3_NODIA,D3_MOEDA,D3_NRBPIMS,D3_QTGANHO,D3_QTMAIOR,D3_CHAVEF1,D3_PERIMP,"+CRLF
		cInsert	+= "	                    				D3_VLRVI,D3_NUMSA,D3_NRABATE,D3_CODLAN,D3_OKISS,D3_ITEMSA,D3_VLRPD,D3_TEATF,D3_CODSAF,"+CRLF
		cInsert	+= "	                    				D3_HAWB,D3_XSETOR,D3_XINVENT,D3_XCONSIG,D3_XFORN,D3_XLJFOR,D3_XHORMOV,D3_XID,D3_XIDEXT,"+CRLF
		cInsert	+= "	 									D3_XNOTA,D3_XSERIE,D_E_L_E_T_,R_E_C_N_O_)"+CRLF
		cInsert	+= "	                (SELECT "+CRLF
		cInsert	+= "	                ARQ.D3_FILIAL,"+CRLF
		cInsert	+= "	                ARQ.D3_TM,"+CRLF
		cInsert	+= "	                ARQ.D3_COD,"+CRLF
		cInsert	+= "	                ARQ.D3_UM,"+CRLF
		cInsert	+= "	                 (CASE "+CRLF
		cInsert	+= "	                		WHEN ARQ.D3_QUANT = '            ' THEN 0"+CRLF
		cInsert	+= "	                 		ELSE TO_NUMBER(replace(D3_QUANT,'.',','))"+CRLF
		cInsert	+= "	                 END) QUANT1,"+CRLF
		cInsert	+= "	               (SELECT SF5.F5_TIPO"+CRLF
 		cInsert	+= "	               FROM "+RetSqlName("SF5")+" SF5"+CRLF
 		cInsert	+= "	               WHERE SF5.F5_FILIAL = '"+xFilial("SF5")+"' "+CRLF
 		cInsert	+= "	                 AND SF5.F5_CODIGO = ARQ.D3_TM "+CRLF
 		cInsert	+= "	                 AND SF5.D_E_L_E_T_  <> '*')||(CASE "+CRLF
 		cInsert	+= "	                                                 WHEN ( SELECT SF5.F5_VAL "+CRLF
		cInsert	+= "	                                                          FROM  "+RetSqlName("SF5")+" SF5"+CRLF
		cInsert	+= "	                                                          WHERE SF5.F5_FILIAL = '"+xFilial("SF5")+"' "+CRLF
		cInsert	+= "	                                                            AND SF5.F5_CODIGO = ARQ.D3_TM "+CRLF
		cInsert	+= "	                                                            AND SF5.D_E_L_E_T_  <> '*')='S' THEN 'E6' "+CRLF
 		cInsert	+= "	                                                		ELSE 'E0'"+CRLF
 		cInsert	+= "	                                                 END) TM,"+CRLF
		cInsert	+= "	                (SELECT B1_CONTA "+CRLF
		cInsert	+= "	                FROM "+RetSqlName("SB1")+" "+CRLF
		cInsert	+= "	                WHERE B1_FILIAL = '"+xFilial("SB1")+"' "+CRLF
 		cInsert	+= "                	  AND B1_COD = D3_COD"+CRLF
		cInsert	+= "                 	  AND D_E_L_E_T_  <> '*') CONTA,"+CRLF //ARQ.D3_CONTA,
		cInsert	+= "               ' ', "+CRLF
 		cInsert	+= "               ARQ.D3_LOCAL,"+CRLF
		cInsert	+= "                ARQ.D3_DOC,"+CRLF
		cInsert	+= "                SUBSTR(ARQ.D3_EMISSAO,7,4)||SUBSTR(ARQ.D3_EMISSAO,4,2)||SUBSTR(ARQ.D3_EMISSAO,1,2),"+CRLF
		cInsert	+= "                (SELECT B1_GRUPO "+CRLF
		cInsert	+= "                FROM "+RetSqlName("SB1")+" "+CRLF
		cInsert	+= "                WHERE B1_FILIAL = '"+xFilial("SB1")+"'"+CRLF
		cInsert	+= "                  AND B1_COD = D3_COD"+CRLF
		cInsert	+= "                  AND D_E_L_E_T_  <> '*') GRUPO,"+CRLF
 		cInsert	+= "              (CASE "+CRLF
		cInsert	+= "                	WHEN ARQ.D3_CUSTO1 = '              ' THEN 0 "+CRLF
		cInsert	+= "                	WHEN ARQ.D3_CUSTO1 IS NULL THEN 0 "+CRLF
 		cInsert	+= "                	ELSE TO_NUMBER(replace(D3_CUSTO1,'.',','))"+CRLF
		cInsert	+= "                 END) CUSTO1,"+CRLF
		cInsert	+= "                0,0,0,0,"+CRLF
		cInsert	+= "                ARQ.D3_CC,"+CRLF
		cInsert	+= "                ' ',' ',' ',' ', 0,"+CRLF
		cInsert	+= "                (SELECT B1_TIPO "+CRLF
 		cInsert	+= "                FROM "+RetSqlName("SB1")+" "+CRLF
		cInsert	+= "                WHERE B1_FILIAL = '        '"+CRLF
		cInsert	+= "                  AND B1_COD = D3_COD"+CRLF
		cInsert	+= "                  AND D_E_L_E_T_  <> '*') TIPO,"+CRLF
		cInsert	+= "                ' ',"+CRLF
		cInsert	+= "                'MIGRACAO',"+CRLF
 		cInsert	+= "               ' ',0,' ',' ','E0', ' ',' ', 0,' ',' ',' ',' ',' ',0,0,0,0,0,"+CRLF
 		cInsert	+= "              ARQ.D3_ITEM,"+CRLF
 		cInsert	+= "             ' ', ' ',' ',' ',' ',' ',' ', '1',' ',0,' ',' ',' ',' ',' ',' ',0,0,0,0, 0,0,' ',' ', ' ',0, 0,0,' ','N',"+CRLF
 		cInsert	+= "			  ' ', ' ',' ',0,0, ' ', 0, 0,' ', ' ',' ',' ',' ',0, ' ',' ', ' ',"+CRLF
 		cInsert	+= "               (CASE "+CRLF
 		cInsert	+= "                 	WHEN ARQ.D3_XINVENT = ' ' THEN 'N'"+CRLF
		cInsert	+= "                  	ELSE ARQ.D3_XINVENT"+CRLF
		cInsert	+= "                END) XINVENT,"+CRLF
		cInsert	+= "                (CASE "+CRLF
		cInsert	+= "                  	WHEN ARQ.D3_XCONSIG = ' ' THEN 'N'"+CRLF
		cInsert	+= "                 	ELSE ARQ.D3_XCONSIG"+CRLF
		cInsert	+= "               END) XCONSIG,"+CRLF
		cInsert	+= "                ' ',' ',' ',' ',' ', ' ',' ',' ',' ',"+CRLF
		cInsert	+= "                 NVL((SELECT MAX(R_E_C_N_O_) FROM "+RetSqlName("SD3")+"), 0) + ROW_NUMBER() "+CRLF
 		cInsert	+= "  				 OVER(PARTITION BY D3_FILIAL ORDER BY D3_FILIAL) RECNO "+CRLF
 		cInsert	+= "                FROM "+cPrfTab+"SD3 ARQ"+CRLF
		cInsert	+= "                 WHERE NUMEROLOTE = '"+cNumLAtu+"'"+CRLF
		cInsert	+= "                   AND REGISTRO_VALIDO <> ' ')"+CRLF
		
		Conout('Iniciando o controle de transação. Lote '+cNumLAtu+' na data '+Dtoc(MsDate())+' hora '+time() )		
		
		BEGIN TRANSACTION
		
		_cRetUpd	:=  TcSQLExec(cInsert)
		
		END TRANSACTION
					
		Conout('Terminando o controle de transação. Lote '+cNumLAtu+' na data '+Dtoc(MsDate())+' hora '+time() )		
	
		If !(_cRetUpd==0) 

			_cRetUpd = TcSqlError()
		
			if !lNMenu
			
				MsgAlert(AllTrim(_cRetUpd),"Problemas na inclusão da tabela efetiva!")

			EndIf
		
		Else
		
			/*
			cUpdAtu	:= "	UPDATE ARQUIVOSD3_RESUMO "+CRLF			
			cUpdAtu	+= "	SET STATUSIMP = '1' "+CRLF
			cUpdAtu	+= "	WHERE NUMEROLOTE = '"+cNumLAtu+"'  "+CRLF			 
			*/
			cUpdAtu	:= "	UPDATE "+cPrfTab+"SD3 "+CRLF
			cUpdAtu	+= "	SET DATAHORAMIG =  (SELECT TO_CHAR (CURRENT_TIMESTAMP, 'yyyymmddhh:mi:ss') FROM DUAL) "+CRLF
			cUpdAtu	+= "	WHERE NUMEROLOTE = '"+cNumLAtu+"'  "+CRLF	
			cUpdAtu	+= "	  AND DATAHORAMIG = ' ' "+CRLF
															
			Conout('Início da atualização da tabela resumo. Lote '+cNumLAtu+' na data '+Dtoc(MsDate())+' hora '+time() )
					
			BEGIN TRANSACTION
		
				_cRetUpd	:=  TcSQLExec(cUpdAtu)
		
			END TRANSACTION		
			
			Conout('Terminando da atualização da tabela resumo. Lote '+cNumLAtu+' na data '+Dtoc(MsDate())+' hora '+time() )
		
			If !(_cRetUpd==0) 
	
				_cRetUpd = TcSqlError()
			
				if !lNMenu
				
					MsgAlert(AllTrim(_cRetUpd),"Atualização da tabela Resumo não realizada!")
	
				EndIf
			
			EndIf
		
		EndIf	
		
		X31UPDTABLE("SD3")
		               
Return
