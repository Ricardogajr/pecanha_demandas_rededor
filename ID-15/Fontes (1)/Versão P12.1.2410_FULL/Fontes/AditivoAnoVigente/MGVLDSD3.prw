#Include 'Protheus.ch'
Static lNMenu	:= IsBlind()
Static cPrfTab	:= Alltrim(SuperGetMV('ES_PRFTBMG',,'ARQ'))
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MGVLDSD3 
Efetua as validações 
@type function
@author Cris
@since 21/08/2017
@version 1.0
@param cNumLote, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function MGVLDSD3()//(cNumLote)

	Local aLotes	:= {}
	Local nLote		:= 0
	Default cNumLote := ''
	
		if Empty(cNumLote)
		
			LotePend(@aLotes)
		
			For nLote := 1 to len(aLotes)
				
				Conout('Iniciando validações do lote '+aLotes[nLote])
						
				if !lNMenu
				
					FWMsgRun(,{|| MGUPDSD3(aLotes[nLote]) },'Aguarde....' ,'Validando registros do lote '+aLotes[nLote]) 
					
				Else
				
					MGUPDSD3(aLotes[nLote])
				
				EndIf
				
				Conout('Término das validações do lote '+aLotes[nLote])	
						
			Next nLote
		
		Else
								
			if !lNMenu
			
				FWMsgRun(,{|| MGUPDSD3(aLotes[nLote]) },'Aguarde....' ,'Validando registros do lote '+aLotes[nLote]) 
				
			Else
			
				MGUPDSD3(aLotes[nLote])
			
			EndIf
			
		EndIf
		
		Aviso("TÉRMINO - VALIDAÇÃO", 'Validação finalizada.', {'OK'},3)
		
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
	
		/*
		cQry	:= "	SELECT NUMEROLOTE "+CRLF
		cQry	+= "	FROM "+cPrfTab+"SD3_RESUMO	 "+CRLF
		cQry	+= "	WHERE StatusImp	= '0' "+CRLF
		cQry	+= "	  AND StatusVld	= ' ' "+CRLF
		*/
		if len(U_TabExist(cPrfTab+"SD3")) > 0
		
			cQry	:= "	SELECT DISTINCT(NUMEROLOTE)  "+CRLF
			cQry	+= "	FROM "+cPrfTab+"SD3  "+CRLF
			cQry	+= "	WHERE REGISTRO_VALIDO = ' '  "+CRLF
			cQry	+= "	  AND DATAHORAMIG = ' ' "+CRLF
											
			cQry := ChangeQuery(cQry)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cTabLt,.T.,.T.)				
			
			if !(cTabLt)->(Eof())	
			
				While  !(cTabLt)->(Eof())	
				
					aAdd(aLotes,(cTabLt)->NUMEROLOTE)
				
				    (cTabLt)->(dbSkip())
				EndDo
						
			EndIf
		
		Else
		
			Aviso("INEXISTENTE - VALIDAÇÃO", 'Tabela intermediária não existente '+cPrfTab+'SD3'+'.', {'OK'},3)
		
		EndIf
		
		(cTabLt)->(dbCloseArea())
		
Return 
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MGUPDSD3
Efetua a validação do lote informado
@type function
@author Cris
@since 24/08/2017
@version 1.0
@param cNumLote, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function MGUPDSD3(cNumLote)

	Local cUpdAtu	:= ''
	Local _cRetUpd
	
		//Retirar primeiro update D3_ITEM quando os fronts começarem a enviar este campo preenchido.
		cUpdAtu	:= "	UPDATE "+cPrfTab+"SD3 "+CRLF
		cUpdAtu	+= "	SET D3_ITEM = '0001' "+CRLF	
		cUpdAtu	+= "	WHERE NUMEROLOTE = '"+cNumLote+"' "+CRLF
		cUpdAtu	+= "	  AND D3_ITEM = '    ' "+CRLF		
		
		Conout('Iniciando UPDATE item. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
					
		BEGIN TRANSACTION
		
			_cRetUpd	:=  TcSQLExec(cUpdAtu)
		
		END TRANSACTION
				
		
		Conout('Terminando UPDATE item. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
				
		//1.Validando se a Filial existe
		cUpdAtu	:= "	UPDATE "+cPrfTab+"SD3 "+CRLF
		cUpdAtu	+= "	SET VLDD3_FILIAL = (SELECT TO_CHAR (CURRENT_TIMESTAMP, 'yyyymmddhh:mi:ss') FROM DUAL) "+CRLF
		cUpdAtu	+= "	WHERE NUMEROLOTE = '"+cNumLote+"' "+CRLF
		cUpdAtu	+= "	  AND  VLDD3_FILIAL = ' ' "+CRLF//1 espaço 
		cUpdAtu	+= "	  AND EXISTS(SELECT ZX_EMPFIL "+CRLF
		cUpdAtu	+= "				 FROM "+RetSqlName("SZX")+" "+CRLF
		cUpdAtu	+= "                 WHERE D_E_L_E_T_ = ' ' "+CRLF
		cUpdAtu	+= "                   AND ZX_FILIAL = '"+xFilial("SZX")+"' "+CRLF
		cUpdAtu	+= "                   AND D3_FILIAL = ZX_FILIALP) "+CRLF
		
		Conout('Iniciando a primeira validação referente ao código da filial. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
		
		BEGIN TRANSACTION
		
			_cRetUpd	:=  TcSQLExec(cUpdAtu)
		
		END TRANSACTION
		
		Conout('Terminando a primeira validação referente ao código da filial. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
				
		If !(_cRetUpd==0) 

			_cRetUpd = TcSqlError()
		
			if !lNMenu
			
				MsgAlert(AllTrim(_cRetUpd),"Atualização de validação de filial não realizada!")

			EndIf
			
		EndIf
		
		//2.Validando se o código da TM existe
		cUpdAtu	:= "	UPDATE "+cPrfTab+"SD3 "+CRLF
		cUpdAtu	+= " 	SET VLDD3_TM = (SELECT TO_CHAR (CURRENT_TIMESTAMP, 'yyyymmddhh:mi:ss') FROM DUAL)"+CRLF
		cUpdAtu	+= "	WHERE NUMEROLOTE = '"+cNumLote+"' "+CRLF
		cUpdAtu	+= "	  AND  VLDD3_TM = ' ' "+CRLF//1 espaço 
		cUpdAtu	+= " 	  AND EXISTS( SELECT F5_CODIGO"+CRLF
		cUpdAtu	+= " 	              FROM "+RetSqlName("SF5")+" "+CRLF
		cUpdAtu	+= " 	              WHERE F5_FILIAL = '"+xFilial("SF5")+"' "+CRLF
		cUpdAtu	+= " 	                AND F5_CODIGO = D3_TM "+CRLF
		cUpdAtu	+= "                    AND  D_E_L_E_T_ = ' ')"+CRLF
		
		Conout('Iniciando a segunda validação referente ao código do TM. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
	
		BEGIN TRANSACTION
		
			_cRetUpd	:=  TcSQLExec(cUpdAtu)
		
		END TRANSACTION
		
		Conout('Terminando a segunda validação referente ao código do TM. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
			
		If !(_cRetUpd==0) 

			_cRetUpd = TcSqlError()
		
			if !lNMenu
			
				MsgAlert(AllTrim(_cRetUpd),"Atualização de validação de TM não realizada!")

			EndIf
			
		EndIf
		
		//3.Validando código de produto existe
		cUpdAtu	:= "	UPDATE "+cPrfTab+"SD3 "+CRLF
		cUpdAtu	+= " 	SET VLDD3_COD =  (SELECT TO_CHAR (CURRENT_TIMESTAMP, 'yyyymmddhh:mi:ss') FROM DUAL) "+CRLF
		cUpdAtu	+= "	WHERE NUMEROLOTE = '"+cNumLote+"' "+CRLF
		cUpdAtu	+= "	  AND  VLDD3_COD = ' ' "+CRLF//1 espaço 
		cUpdAtu	+= "	  AND EXISTS (	SELECT B1_COD "+CRLF
		cUpdAtu	+= "     				FROM "+RetSqlName("SB1")+" "+CRLF
		cUpdAtu	+= "   		            WHERE B1_FILIAL = '"+xFilial("SB1")+"' "+CRLF
		cUpdAtu	+= " 					  AND B1_COD = D3_COD "+CRLF
		cUpdAtu	+= " 					  AND D_E_L_E_T_ = ' ') "+CRLF
		
		Conout('Iniciando a terceira validação referente ao código do produto. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
	
		BEGIN TRANSACTION
		
			_cRetUpd	:=  TcSQLExec(cUpdAtu)
		
		END TRANSACTION
		
		Conout('Terminando a terceira validação referente ao código do produto. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
			
		If !(_cRetUpd==0) 

			_cRetUpd = TcSqlError()
		
			if !lNMenu
			
				MsgAlert(AllTrim(_cRetUpd),"Atualização de validação de código de produto não realizada!")

			EndIf
			
		EndIf
				
		//4.Validando unidade de medida existe
		//Em um movimentação interna por vias padrões a unidade de medida é carregada a partir da SB1, por isso 
		//a validação esta baseada no cadastro.
		/*	cUpdAtu	:= "	UPDATE "+cPrfTab+"SD3 "+CRLF
		cUpdAtu	+= "	SET VLDD3_UM = (SELECT TO_CHAR (CURRENT_TIMESTAMP, 'yyyymmddhh:mi:ss') FROM DUAL) "+CRLF
		cUpdAtu	+= "	WHERE NUMEROLOTE = '"+cNumLote+"' "+CRLF
		cUpdAtu	+= "	  AND  VLDD3_UM = ' ' "+CRLF//1 espaço 
		cUpdAtu	+= "	  AND EXISTS(SELECT B1_COD	 "+CRLF
		cUpdAtu	+= "	  			 FROM "+RetSqlName("SB1")+"  "+CRLF
		cUpdAtu	+= "	  			 WHERE B1_FILIAL = '"+xFilial("SB1")+"' "+CRLF
		cUpdAtu	+= "	  			   AND B1_COD = D3_COD "+CRLF
		cUpdAtu	+= "	  			   AND B1_UM = D3_UM "+CRLF				
		cUpdAtu	+= "	               AND D_E_L_E_T_ = ' ') "+CRLF	
			*/
         
         // caso seja acordado somente para validar no cadastro da Unidade de Medida		
		cUpdAtu	:= "	UPDATE "+cPrfTab+"SD3 "+CRLF
		cUpdAtu	+= "	SET VLDD3_UM = (SELECT TO_CHAR (CURRENT_TIMESTAMP, 'yyyymmddhh:mi:ss') FROM DUAL) "+CRLF
		cUpdAtu	+= "	WHERE NUMEROLOTE = '"+cNumLote+"' "+CRLF	
		cUpdAtu	+= "	  AND  VLDD3_UM = ' ' "+CRLF//1 espaço 
		cUpdAtu	+= "	  AND EXISTS(SELECT AH_UNIMED "+CRLF
		cUpdAtu	+= "	              FROM "+RetSqlName("SAH")+"  "+CRLF
		cUpdAtu	+= "	              WHERE AH_FILIAL = '"+xFilial("SAH")+"' "+CRLF
		cUpdAtu	+= "	                AND AH_UNIMED = D3_UM "+CRLF
		cUpdAtu	+= "	                AND D_E_L_E_T_ = ' ') "+CRLF
		
		Conout('Iniciando a quarta validação referente ao código da unidade de medida. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
	
		BEGIN TRANSACTION
		
			_cRetUpd	:=  TcSQLExec(cUpdAtu)
		
		END TRANSACTION
		
		Conout('Terminando a quarta validação referente ao código da unidade de medida. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
			
		If !(_cRetUpd==0) 

			_cRetUpd = TcSqlError()
		
			if !lNMenu
			
				MsgAlert(AllTrim(_cRetUpd),"Atualização de validação de unidade de medida não realizada!")

			EndIf
			
		EndIf
					
		//5.Validando a quantidade informada é positiva
		cUpdAtu	:= "	UPDATE "+cPrfTab+"SD3 "+CRLF
		cUpdAtu	+= "	SET VLDD3_QUANT = (SELECT TO_CHAR (CURRENT_TIMESTAMP, 'yyyymmddhh:mi:ss') FROM DUAL)"+CRLF
		cUpdAtu	+= "	WHERE NUMEROLOTE = '"+cNumLote+"' "+CRLF
		cUpdAtu	+= "	  AND  VLDD3_QUANT = ' ' "+CRLF//1 espaço 
		cUpdAtu	+= "	  AND D3_QUANT > 0 "+CRLF
				
		Conout('Iniciando a quinta validação referente a quantidade. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
	
		BEGIN TRANSACTION
		
			_cRetUpd	:=  TcSQLExec(cUpdAtu)
		
		END TRANSACTION
		
		Conout('Terminando quinta validação referente a quantidade. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
	
		If !(_cRetUpd==0) 

			_cRetUpd = TcSqlError()
		
			if !lNMenu
			
				MsgAlert(AllTrim(_cRetUpd),"Atualização de validação de quantidade não realizada!")

			EndIf
			
		EndIf
					
       //6.Validando se o armazém existe
		cUpdAtu	:= "	UPDATE "+cPrfTab+"SD3 "+CRLF
		cUpdAtu	+= "	   SET VLDD3_LOCAL =(SELECT TO_CHAR (CURRENT_TIMESTAMP, 'yyyymmddhh:mi:ss') FROM DUAL) "+CRLF
		cUpdAtu	+= "	WHERE NUMEROLOTE = '"+cNumLote+"' "+CRLF
		cUpdAtu	+= "	  AND  VLDD3_LOCAL = ' ' "+CRLF//1 espaço 
		cUpdAtu	+= "	  AND EXISTS(SELECT NNR_CODIGO "+CRLF
		cUpdAtu	+= "	             FROM "+RetSqlName("NNR")+" "+CRLF
		cUpdAtu	+= "	             WHERE NNR_FILIAL = D3_FILIAL "+CRLF
		cUpdAtu	+= "	               AND NNR_CODIGO = D3_LOCAL "+CRLF
		cUpdAtu	+= "	               AND D_E_L_E_T_ = ' ')  "+CRLF 
				
		Conout('Iniciando a sexta validação referente ao codigo do armazém. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
	
		BEGIN TRANSACTION
		
			_cRetUpd	:=  TcSQLExec(cUpdAtu)
		
		END TRANSACTION
		
		Conout('Terminando a sexta validação referente ao código do armazém. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
	
		If !(_cRetUpd==0) 

			_cRetUpd = TcSqlError()
		
			if !lNMenu
			
				MsgAlert(AllTrim(_cRetUpd),"Atualização de validação de local de armazém não realizada!")

			EndIf
			
		EndIf
					
		//7.Validando se a data de emissão foi preenchida
		cUpdAtu	:= "	UPDATE "+cPrfTab+"SD3 "+CRLF
		cUpdAtu	+= "	   SET VLDD3_EMISSAO =(SELECT TO_CHAR (CURRENT_TIMESTAMP, 'yyyymmddhh:mi:ss') FROM DUAL) "+CRLF
		cUpdAtu	+= "	WHERE NUMEROLOTE = '"+cNumLote+"' "+CRLF
		cUpdAtu	+= "	  AND D3_EMISSAO <> '        '  "+CRLF
		cUpdAtu	+= "	  AND VLDD3_EMISSAO = ' ' "+CRLF//1 espaço 	
		cUpdAtu	+= "	  AND SUBSTR(D3_EMISSAO,3,1) = '/'  "+CRLF
		cUpdAtu	+= "	  AND SUBSTR(D3_EMISSAO,6,1) = '/'  "+CRLF
		cUpdAtu	+= "	  AND SUBSTR(D3_EMISSAO,4,2) <= 12  "+CRLF
											
		Conout('Iniciando a sétima validação referente a data de emissão. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
	
		BEGIN TRANSACTION
		
			_cRetUpd	:=  TcSQLExec(cUpdAtu)
		
		END TRANSACTION
		
		Conout('Terminando a sétima validação referente a data de emissão. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
	
		If !(_cRetUpd==0) 

			_cRetUpd = TcSqlError()
		
			if !lNMenu
			
				MsgAlert(AllTrim(_cRetUpd),"Atualização de validação de Data de Emissão não realizada!")

			EndIf
			
		EndIf
						
		//8.Validando se o Centro de Custo existe
		cUpdAtu	:= "	UPDATE "+cPrfTab+"SD3 "+CRLF
		cUpdAtu	+= "	  SET VLDD3_CC =(SELECT TO_CHAR (CURRENT_TIMESTAMP, 'yyyymmddhh:mi:ss') FROM DUAL) "+CRLF
		cUpdAtu	+= "	WHERE NUMEROLOTE = '"+cNumLote+"' "+CRLF
		cUpdAtu	+= "	  AND VLDD3_CC = ' ' "+CRLF//1 espaço 	
		cUpdAtu	+= "	  AND EXISTS(SELECT CTT_CUSTO "+CRLF
		cUpdAtu	+= "	              FROM "+RetSqlName("CTT")+" "+CRLF
		cUpdAtu	+= "	              WHERE CTT_FILIAL = '"+xFilial("CTT")+"' "+CRLF
		cUpdAtu	+= "	              AND CTT_CUSTO = D3_CC "+CRLF
		cUpdAtu	+= "	              AND D_E_L_E_T_ = ' ') "+CRLF
				
		Conout('Iniciando a oitava validação referente ao centro de custo. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
	
		BEGIN TRANSACTION
		
			_cRetUpd	:=  TcSQLExec(cUpdAtu)
		
		END TRANSACTION
		
		Conout('Terminando a oitava validação referente ao centro de custo. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
	
		If !(_cRetUpd==0) 

			_cRetUpd = TcSqlError()
		
			if !lNMenu
			
				MsgAlert(AllTrim(_cRetUpd),"Atualização de validação de Centro de Custo não realizada!")

			EndIf
			
		EndIf
					
		//9.validando se Número do documento foi preenchido
		cUpdAtu	:= "	UPDATE "+cPrfTab+"SD3 "+CRLF
		cUpdAtu	+= "	  SET VLDD3_DOC  =(SELECT TO_CHAR (CURRENT_TIMESTAMP, 'yyyymmddhh:mi:ss') FROM DUAL) "+CRLF
		cUpdAtu	+= "	WHERE NUMEROLOTE = '"+cNumLote+"' "+CRLF
		cUpdAtu	+= "	  AND D3_DOC <> '         ' "+CRLF//9 ESPAÇOS VAZIOS
		cUpdAtu	+= "	  AND VLDD3_DOC = ' ' "+CRLF	//1 espaço 					
				
		Conout('Iniciando a nona validação referente ao número do documento. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
	
		BEGIN TRANSACTION
		
			_cRetUpd	:=  TcSQLExec(cUpdAtu)
		
		END TRANSACTION
		
		Conout('Terminando a nona validação referente ao número do documento. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
		
		If !(_cRetUpd==0) 

			_cRetUpd = TcSqlError()
		
			if !lNMenu
			
				MsgAlert(AllTrim(_cRetUpd),"Atualização de validação de Número do Documento não realizada!")

			EndIf
			
		EndIf
		
		//10.Validando se o item foi preenchido
		cUpdAtu	:= "	UPDATE "+cPrfTab+"SD3 "+CRLF
		cUpdAtu	+= "	  SET VLDD3_ITEM  = (SELECT TO_CHAR (CURRENT_TIMESTAMP, 'yyyymmddhh:mi:ss') FROM DUAL) "+CRLF
		cUpdAtu	+= "	WHERE NUMEROLOTE = '"+cNumLote+"' "+CRLF
		cUpdAtu	+= "	  AND D3_ITEM <> '    ' "+CRLF	//4 ESPAÇOS VAZIOS	
		cUpdAtu	+= "	  AND VLDD3_ITEM = ' ' "+CRLF//1 espaço 				
				
		Conout('Iniciando a décima validação referente ao item. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
	
		BEGIN TRANSACTION
		
			_cRetUpd	:=  TcSQLExec(cUpdAtu)
		
		END TRANSACTION
		
		Conout('Terminando a décima validação referente ao item. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
	
		If !(_cRetUpd==0) 

			_cRetUpd = TcSqlError()
		
			if !lNMenu
			
				MsgAlert(AllTrim(_cRetUpd),"Atualização de validação do Item não realizada!")

			EndIf
			
		EndIf
	
		//11.Validando a conta contábil
	/*	cUpdAtu	:= "	UPDATE "+cPrfTab+"SD3 "+CRLF
		cUpdAtu	+= "	  SET VLDD3_CONTA =(SELECT TO_CHAR (CURRENT_TIMESTAMP, 'yyyymmddhh:mi:ss') FROM DUAL) "+CRLF
		cUpdAtu	+= "	WHERE NUMEROLOTE = '"+cNumLote+"' "+CRLF
		cUpdAtu	+= "	  AND VLDD3_CONTA = ' ' "+CRLF//1 espaço 
         // caso seja acordado somente para validar no cadastro de conta contábil a partir da propria mvto ou se estiver vazio a partir da SB1
  		cUpdAtu	+= "	       AND EXISTS(SELECT CT1_CONTA  "+CRLF
		cUpdAtu	+= "	  	              FROM "+RetSqlName("CT1")+"  "+CRLF
		cUpdAtu	+= "	  	              WHERE CT1_FILIAL = '        '  "+CRLF
		cUpdAtu	+= "	  	              AND CT1_CONTA = (CASE "+CRLF
 		cUpdAtu	+= "	                                   WHEN D3_CONTA = '                    ' THEN ( SELECT B1CONTA.B1_CONTA  "+CRLF
 		cUpdAtu	+= "	                                                                                 FROM SB1010 B1CONTA "+CRLF
 		cUpdAtu	+= "	                                                                                 WHERE B1CONTA.B1_FILIAL = '        '   "+CRLF
 		cUpdAtu	+= "	                                                                                   AND B1CONTA.B1_COD = D3_COD "+CRLF
 		cUpdAtu	+= "	                                                                                   AND B1CONTA.D_E_L_E_T_ = ' ') "+CRLF
		cUpdAtu	+= "	                                    ELSE D3_CONTA "+CRLF
		cUpdAtu	+= "	                                  END )  "+CRLF
		cUpdAtu	+= "	  	              AND D_E_L_E_T_ = ' ') "+CRLF	              	
    
    	/*	cUpdAtu	+= "	  AND D3_CONTA <> '                    ' "+CRLF//20 espaços		
		cUpdAtu	+= "	  AND EXISTS(SELECT CT1_CONTA "+CRLF
		cUpdAtu	+= "	              FROM "+RetSqlName("CT1")+" "+CRLF
		cUpdAtu	+= "	              WHERE CT1_FILIAL = '"+xFilial("CT1")+"' "+CRLF
		cUpdAtu	+= "	              AND CT1_CONTA = D3_CONTA "+CRLF
		cUpdAtu	+= "	              AND D_E_L_E_T_ = ' ') "+CRLF
		*/         
	/*	     				
		Conout('Iniciando a décima primeira validação referente a conta contábil. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
	
		BEGIN TRANSACTION
		
			_cRetUpd	:=  TcSQLExec(cUpdAtu)
		
		END TRANSACTION
		
		Conout('Terminando a décima primeira validação referente a conta contábil. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
	
		If !(_cRetUpd==0) 

			_cRetUpd = TcSqlError()
		
			if !lNMenu
			
				MsgAlert(AllTrim(_cRetUpd),"Atualização de validação da Conta Contábil não realizada!")

			EndIf
			
		EndIf
	*/
													
		/*cUpdAtu	+= "	  AND EXISTS(SELECT B1_COD "+CRLF
		cUpdAtu	+= "	              FROM "+RetSqlName("SB1")+" "+CRLF
		cUpdAtu	+= "	              WHERE B1_FILIAL = '"+xFilial("SB1")+"' "+CRLF
		cUpdAtu	+= "	              AND B1_COD = D3_COD "+CRLF
		cUpdAtu	+= "	              AND B1_GRUPO = D3_GRUPO "+CRLF
		cUpdAtu	+= "	              AND D_E_L_E_T_ = ' ') "+CRLF
		*/
		/*
		//12.Validando o grupo do produto
		cUpdAtu	:= "	UPDATE "+cPrfTab+"SD3 "+CRLF
		cUpdAtu	+= "	  SET VLDD3_GRUPO =(SELECT TO_CHAR (CURRENT_TIMESTAMP, 'yyyymmddhh:mi:ss') FROM DUAL) "+CRLF
		cUpdAtu	+= "	WHERE NUMEROLOTE = '"+cNumLote+"' "+CRLF
		cUpdAtu	+= "	  AND VLDD3_GRUPO = ' ' "+CRLF//1 espaço 
		  //caso seja acordado somente para validar no cadastro de conta contábil				
		cUpdAtu	+= "	  AND EXISTS( SELECT BM_GRUPO	 "+CRLF
		cUpdAtu	+= "	  			  FROM "+RetSqlName("SBM")+" "+CRLF
		cUpdAtu	+= "	              WHERE BM_FILIAL = '"+xFilial("SBM")+"' "+CRLF  
		cUpdAtu	+= "	                AND BM_GRUPO = D3_GRUPO "+CRLF
		cUpdAtu	+= "	                AND D_E_L_E_T_ = ' ') "+CRLF

		Conout('Iniciando a décima segunda validação referente ao grupo do produto. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
	
		BEGIN TRANSACTION
		
			_cRetUpd	:=  TcSQLExec(cUpdAtu)
		
		END TRANSACTION
		
		Conout('Terminando a décima segunda validação referente ao grupo do produto. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
	
		If !(_cRetUpd==0) 

			_cRetUpd = TcSqlError()
		
			if !lNMenu
			
				MsgAlert(AllTrim(_cRetUpd),"Atualização de validação do grupo do produto não realizada!")

			EndIf
			
		EndIf
	
		//13.Validando o tipo do material do produto
		//Na inclusão manual de uma mvto interna este campo é preenchido automaticamente com base
		//no cadastro de produto.
		/*cUpdAtu	:= "	UPDATE "+cPrfTab+"SD3 "+CRLF
		cUpdAtu	+= "	  SET VLDD3_TIPO =(SELECT TO_CHAR (CURRENT_TIMESTAMP, 'yyyymmddhh:mi:ss') FROM DUAL) "+CRLF
		cUpdAtu	+= "	WHERE NUMEROLOTE = '"+cNumLote+"' "+CRLF
		cUpdAtu	+= "	  AND VLDD3_TIPO = ' ' "+CRLF//1 espaço 	
		cUpdAtu	+= "	  AND EXISTS(SELECT B1_COD "+CRLF
		cUpdAtu	+= "	              FROM "+RetSqlName("SB1")+" "+CRLF
		cUpdAtu	+= "	              WHERE B1_FILIAL = '"+xFilial("SB1")+"' "+CRLF
		cUpdAtu	+= "	              AND B1_COD = D3_COD "+CRLF
		cUpdAtu	+= "	              AND B1_TIPO = D3_TIPO "+CRLF
		cUpdAtu	+= "	              AND D_E_L_E_T_ = ' ') "+CRLF
				
		Conout('Iniciando a décima terceira validação referente ao tipo do produto. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
	
		BEGIN TRANSACTION
		
			_cRetUpd	:=  TcSQLExec(cUpdAtu)
		
		END TRANSACTION
		
		Conout('Terminando a décima terceira validação referente ao tipo do produto. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
	
		If !(_cRetUpd==0) 

			_cRetUpd = TcSqlError()
		
			if !lNMenu
			
				MsgAlert(AllTrim(_cRetUpd),"Atualização de validação do tipo do produto não realizada!")

			EndIf
			
		EndIf		
			*/
												
		//14.Indica se o registro não esta em duplicidade		
		cUpdAtu	:= "	UPDATE "+cPrfTab+"SD3 "+CRLF
		cUpdAtu	+= "	SET DUPLIC = (SELECT TO_CHAR (CURRENT_TIMESTAMP, 'yyyymmddhh:mi:ss') FROM DUAL) "+CRLF
		cUpdAtu	+= "	WHERE NUMEROLOTE = '"+cNumLote+"'  "+CRLF
		cUpdAtu	+= "	  AND DUPLIC = ' ' "+CRLF //1 espaço 	
		cUpdAtu	+= "	AND LINHA IN (SELECT LINHA "+CRLF
		cUpdAtu	+= "	              FROM (SELECT D3_FILIAL,D3_COD,D3_LOCAL,D3_TM,D3_EMISSAO,D3_DOC,D3_ITEM,LINHA, "+CRLF
		cUpdAtu	+= "	                    ROW_NUMBER() OVER (PARTITION BY D3_FILIAL,D3_COD,D3_LOCAL,D3_TM,D3_EMISSAO,D3_DOC,D3_ITEM ORDER BY NUMEROLOTE,LINHA) NUM "+CRLF
		cUpdAtu	+= "	                    FROM "+cPrfTab+"SD3 "+CRLF
		cUpdAtu	+= "	                    WHERE NUMEROLOTE = '"+cNumLote+"'  "+CRLF
		cUpdAtu	+= "	                    )  "+CRLF
		cUpdAtu	+= "	              WHERE NUM > 1) "+CRLF
					
		Conout('Iniciando a décima quarta validação referente a duplicidades. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
	
		BEGIN TRANSACTION
		
		_cRetUpd	:=  TcSQLExec(cUpdAtu)
		
		END TRANSACTION
		
		Conout('Terminando a décima quarta validação referente  a duplicidades.  Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
	
		If !(_cRetUpd==0) 

			_cRetUpd = TcSqlError()
		
			if !lNMenu
			
				MsgAlert(AllTrim(_cRetUpd),"Atualização de validação da duplicidade não realizada!")

			EndIf
			
		EndIf	
		
		//15.Verifica se a linha esta totalmente validada, se sim, a disponibiliza para efetivação.
		cUpdAtu	:= "	UPDATE "+cPrfTab+"SD3 "+CRLF
		cUpdAtu	+= "    SET REGISTRO_VALIDO = (SELECT TO_CHAR (CURRENT_TIMESTAMP, 'yyyymmddhh:mi:ss') FROM DUAL)   "+CRLF	
		cUpdAtu	+= "	WHERE NUMEROLOTE = '"+cNumLote+"'  "+CRLF
		cUpdAtu	+= "	  AND REGISTRO_VALIDO = ' ' "+CRLF	//1 espaço 
		cUpdAtu	+= "	  AND LINHA IN (	SELECT LINHA "+CRLF
		cUpdAtu	+= "						FROM "+cPrfTab+"SD3  "+CRLF
		cUpdAtu	+= "						WHERE NUMEROLOTE = '"+cNumLote+"'  "+CRLF
		cUpdAtu	+= "						  AND VLDD3_FILIAL <> ' ' "+CRLF//1 espaço 
		cUpdAtu	+= "						  AND VLDD3_TM <> ' ' "+CRLF//1 espaço 
		cUpdAtu	+= "						  AND VLDD3_COD <> ' ' "+CRLF//1 espaço 
		cUpdAtu	+= "						  AND VLDD3_UM <> ' ' "+CRLF//1 espaço 
		cUpdAtu	+= "						  AND VLDD3_QUANT <> ' ' "+CRLF//1 espaço 
		cUpdAtu	+= "						  AND VLDD3_LOCAL <> ' ' "+CRLF//1 espaço 
		cUpdAtu	+= "						  AND VLDD3_EMISSAO <> ' ' "+CRLF//1 espaço 
		cUpdAtu	+= "						  AND VLDD3_CC <> ' ' "+CRLF//1 espaço 
		cUpdAtu	+= "						  AND VLDD3_DOC <> ' ' "+CRLF//1 espaço 
		cUpdAtu	+= "						  AND VLDD3_ITEM <> ' ' "+CRLF//1 espaço 
/*		cUpdAtu	+= "						  AND VLDD3_CONTA <> ' ' "+CRLF		//1 espaço 
		cUpdAtu	+= "						  AND VLDD3_TIPO <> ' ' "+CRLF//1 espaço 
		cUpdAtu	+= "						  AND VLDD3_GRUPO <> ' ' "+CRLF*///1 espaço 
		cUpdAtu	+= "						  AND DUPLIC = ' ' "+CRLF//1 espaço 
		cUpdAtu	+= "						  AND REGISTRO_VALIDO = ' ') "+CRLF//1 espaço 
						
		Conout('Iniciando a última validação referente a validação total de cada linha. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
	
		BEGIN TRANSACTION
		
		_cRetUpd	:=  TcSQLExec(cUpdAtu)
		
		END TRANSACTION
		
		Conout('Terminando a última validação referente a validação total de cada linha. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
	
		If !(_cRetUpd==0) 

			_cRetUpd = TcSqlError()
		
			if !lNMenu
			
				MsgAlert(AllTrim(_cRetUpd),"Atualização de validação da total de cada linha não realizada!")

			EndIf
		
		Else
		
			// CASO A TABELA RESUMO SEJA UTILIZADA.
			/*
			cUpdAtu	:= "	UPDATE "+cPrfTab+"SD3_RESUMO "+CRLF			
			cUpdAtu	+= "	SET STATUSVLD = '1' "+CRLF
			cUpdAtu	+= "	WHERE NUMEROLOTE = '"+cNumLote+"'  "+CRLF			 
		
			Conout('Início da atualização da tabela resumo. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
					
			BEGIN TRANSACTION
		
				_cRetUpd	:=  TcSQLExec(cUpdAtu)
		
			END TRANSACTION		
			
			Conout('Terminando da atualização da tabela resumo. Lote '+cNumLote+' na data '+Dtoc(MsDate())+' hora '+time() )
		
			If !(_cRetUpd==0) 
	
				_cRetUpd = TcSqlError()
			
				if !lNMenu
				
					MsgAlert(AllTrim(_cRetUpd),"Atualização da tabela Resumo não realizada!")
	
				EndIf
			
			EndIf
			*/
		EndIf	
							      				      
Return
