#Include 'Protheus.ch'
Static cDtIni	:= ''
Static cHrIni	:= '' 
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MGCMVSA1
Analisa se os clientes cadastrados possuem vinculo com movimentação financeira
@type function
@author Cris
@since 09/08/2017
@version 1.0
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function MGCMVSA1()
	
	Local aEmpresa	:= {}
	Local nEmp		:= 0
	Local cPesqTab	:= ''
		
		//checa se existe e senão existe cria.
		if CriaTMP()
		
			//carrega as empresas existentes no De PAra			
			Processa( {|| CarrEmp(@aEmpresa,'')},'Carregando dados da empresa..')

			//Busca para cada empresa os Clientes associados na tabela de titulo
			For nEmp	:= 1 to len(aEmpresa)
				
				cTabRet	:= GetNextAlias()
				cPesqTab	:= 'SE1'+aEmpresa[nEmp]+'0'		
				
				cDtIni	:= Dtos(Msdate())
				cHrIni	:= Time()
				
				//Grava log de iniciação para entender os tempos de processamento entre uma tabela para outra
				Processa( {|| GrvLgEmp(aEmpresa[nEmp],cPesqTab,1)},'Iniciando gravação de log de processamento da empresa '+aEmpresa[nEmp]+'...')
					
				//Se a tabela existir para a empresa pesquisada, efetua a busca
				if len(U_TabExist(cPesqTab)) > 0
					
					//Monta a Query com o distinct
					Processa( {|| BuscTit(@cTabRet,cPesqTab)},'Analisando movimentações financeiras x clientes...')								
		
					//Grava na tabela temporária caso necessário
					if !(cTabRet)->(Eof())
											
						Processa( {|| GrvClien(cTabRet,cPesqTab)},'Gravando códigos de clientes...')	
							
					EndIf
					
					//Grava log de finalização
					Processa( {|| GrvLgEmp(aEmpresa[nEmp],cPesqTab,2)},'Finalizando gravação de log de processamento da empresa '+aEmpresa[nEmp]+'...')	
				Else
					
					//Grava log de finalização
					Processa( {|| GrvLgEmp(aEmpresa[nEmp],cPesqTab,2)},'Finalizando gravação de log de processamento da empresa '+aEmpresa[nEmp]+'...')
				EndIf
		
				cDtIni	:= ''
				cHrIni	:= ''
							
			Next nEmp
		
			Aviso("ANÁLISE FINALIZADA", 'Análise finalizada verifique a tabela TMPCLIENTE_MVTO e/ou gere a exportação de clientes.', {'OK'},3)

		EndIf

Return
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaTMP
Cria tabela temporária
@type function
@author Cris
@since 13/06/2017
@version 1.0
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function CriaTMP()

	Local aResul 	:= {}
	Local lNCriou	:= .F.
	Local _RetSql	:= ''

	BEGIN TRANSACTION
		
		//Cliente x Mvto.
		/*cQryTMP	:=	"	DROP TABLE TMPCLIENTE_MVTO"	
		_RetSql	:=  TcSQLExec(cQryTMP)
		
		//Cliente x Mvto. LOG
		cQryTMP	:=	"	DROP TABLE TMPCLIENTE_MVTO_LOG"	
		_RetSql	:=  TcSQLExec(cQryTMP)
		*/
		aResul	:= u_TabExist('TMPCLIENTE_MVTO')
		
		//Se não existe, a cria
		if (lNCriou	:= (len(aResul) == 0))

			cQryTMP	:=	"	CREATE TABLE TMPCLIENTE_MVTO ( "+CRLF
			cQryTMP	+=	"										CLIENTE varchar(6) NOT NULL, "+CRLF
			cQryTMP	+=	"										LOJA varchar(02) NOT NULL,"+CRLF
			cQryTMP	+=	"										MVTO varchar(01) NULL,
			cQryTMP	+=	"										TABELA varchar(06) NULL,
			cQryTMP	+=	"										CNPJ_CPF varchar(14) NULL )"+CRLF
										
			_RetSql:=  TcSQLExec(cQryTMP)
				
			If !(_RetSql==0)
			
					_RetSql = TcSQLError()

					MsgAlert(AllTrim(_RetSql),"Erro na criação da Tabela de Cliente X Mvto.Financeiros. Contactar Administrador do Sistema ")
	
					lNCriou	:= .T.
			
			Else 
				
				//Se foi criada, inclui o indice
				cQryTMP	:=	"	CREATE UNIQUE INDEX idx_cli_loj_mvto ON TMPCLIENTE_MVTO (CLIENTE,LOJA) "+CRLF  
										
				_RetSql:=  TcSQLExec(cQryTMP)
					
				If !(_RetSql==0)
				
						_RetSql = TcSQLError()
	
						MsgAlert(AllTrim(_RetSql),"Erro na criação do indice da Tabela de Cliente X Mvto.Financeiros. Contactar Administrador do Sistema ")
		
						lNCriou	:= .T.
				Else
					if len(aResul	:= u_TabExist('TMPCLIENTE_MVTO_LOG')) == 0
						//Se o indice foi criado, inclui a tabela de Log
					 	cQryTMP	:=	"	CREATE TABLE TMPCLIENTE_MVTO_LOG ( "+CRLF
						cQryTMP	+=	"										EMPRESA 			varchar(02)	NOT NULL, "+CRLF
						cQryTMP	+=	"										TABELA 				varchar(08)	NOT NULL, "+CRLF
						cQryTMP	+=	"										DATA_INICIAL_CONS 	varchar(08) NULL,"+CRLF
						cQryTMP	+=	"										DATA_FINAL_CONS 	Varchar(08) NULL,
						cQryTMP	+=	"										HORA_INICIAL_CONS 	varchar(08) NULL,
						cQryTMP	+=	"										HORA_FINAL_CONS 	varchar(08) NULL )"+CRLF
														
						_RetSql:=  TcSQLExec(cQryTMP)
					
						If !(_RetSql==0)
						
								_RetSql = TcSQLError()
			
								MsgAlert(AllTrim(_RetSql),"Erro na criação da Tabela de LOG Cliente X Mvto.Financeiros. Contactar Administrador do Sistema ")
				
								lNCriou	:= .T.
						
						Else 
					
							//Se foi criada, inclui o indice
							cQryTMP	:=	"	CREATE UNIQUE INDEX idx_cli_loj_mvto_log ON TMPCLIENTE_MVTO_LOG (EMPRESA, DATA_INICIAL_CONS,HORA_INICIAL_CONS) "+CRLF  
												
							_RetSql:=  TcSQLExec(cQryTMP)
						
							If !(_RetSql==0)
							
									_RetSql = TcSQLError()
				
									MsgAlert(AllTrim(_RetSql),"Erro na criação do indice da Tabela LOG de Cliente X Mvto.Financeiros. Contactar Administrador do Sistema ")
					
									lNCriou	:= .T.	
							Else
														
								lNCriou	:= .F.
							
							EndIf
							
						EndIf
					EndIf
				EndIf
				
			EndIf  
		  						
		EndIf
	
	END TRANSACTION
		
Return !lNCriou
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarrEmp
(long_description)
@type function
@author Cris
@since 29/05/2017
@version 1.0
@param aEmpresa, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function CarrEmp(aEmpresa,cNEmp)

	Local cQrySZX	:= ''
	Local cTabSZX	:= GetNextAlias()
	Default cNEmp	:= ''
	
		cQrySZX	:= "	SELECT DISTINCT(SUBSTRING(ZX_EMPFIL,1,2)) AS EMPRESA "+CRLF
		cQrySZX	+= "	FROM "+RetSqlName("SZX")+" "+CRLF
		cQrySZX	+= "		WHERE D_E_L_E_T_ = ' ' "+CRLF
		
		if !Empty(cNEmp)
		
			cQrySZX	+= "	AND SUBSTRING(ZX_EMPFIL,1,2) NOT IN ('"+cNEmp+"') "+CRLF	
					
		EndIf
		
		cQrySZX	+= "		ORDER BY EMPRESA "+CRLF
		
		cQrySZX := ChangeQuery(cQrySZX)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySZX),cTabSZX,.T.,.T.)	
		
		if !(cTabSZX)->(Eof())
		
			While !(cTabSZX)->(Eof())
			
				aAdd(aEmpresa,(cTabSZX)->EMPRESA)
				
				(cTabSZX)->(dbSkip())
				
			EndDo
			
		EndIf	
		
		(cTabSZX)->(dbCloseArea())	
		
Return
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BuscTit
(long_description)
@type function
@author Cris
@since 13/06/2017
@version 1.0
@param cTabRet, character, (Descrição do parâmetro)
@param cEmpAtu, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function BuscTit(cTabRet,cPesqTab)	

	Local cQryAtu	:= ''

		cQryAtu	:= "	SELECT DISTINCT(E1_CLIENTE) CLIENTE, E1_LOJA LOJA,"+CRLF
		cQryAtu	+= "														 NVL(( SELECT A1_CGC "+CRLF
 		cQryAtu	+= "	                                           					FROM "+RetSqlName("SA1")+" "+CRLF
  		cQryAtu	+= "	                                          					WHERE A1_FILIAL = ' ' "+CRLF
  		cQryAtu	+= "	                                            				  AND  A1_COD = E1_CLIENTE "+CRLF
 		cQryAtu	+= "	                                            				  AND A1_LOJA = E1_LOJA "+CRLF
   		cQryAtu	+= "	                                           					  AND D_E_L_E_T_ = ' ' ),' ') AS CNPJ_CPF "+CRLF
		cQryAtu	+= "	FROM "+cPesqTab+" "+CRLF
		cQryAtu	+= "	WHERE D_E_L_E_T_ =' ' "+CRLF
		cQryAtu	+= "	 AND NOT EXISTS (SELECT TMP.CLIENTE "+CRLF
		cQryAtu	+= "	 				 FROM TMPCLIENTE_MVTO TMP "+CRLF			
		cQryAtu	+= "	 				 WHERE TMP.CLIENTE	= E1_CLIENTE "+CRLF
		cQryAtu	+= "	 				   AND TMP.LOJA 	= E1_LOJA)  "+CRLF
											
		cQryAtu := ChangeQuery(cQryAtu)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryAtu),cTabRet,.T.,.T.)	

		ProcRegua((cTabRet)->(LastRec()))

Return 
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GrvClien
Grava dados 
@type function
@author Cris
@since 01/06/2017
@version 1.0
@param cTabRet, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function GrvClien(cTabRet,cTabAtu)

	Local cInsert	:= ''
	Local nCntReg	:= 0
	Local nRegAtu	:= 0
	
		(cTabRet)->(dbGotop())

		While !(cTabRet)->(Eof())
	
			IncProc('Gravando '+(cTabRet)->CLIENTE+(cTabRet)->LOJA+' '+Alltrim(Str(nRegAtu	:= nRegAtu + 1))+'/'+Alltrim(Str(nCntReg)))

			Begin  Transaction
							
				cInsert	:= "	INSERT INTO TMPCLIENTE_MVTO(CLIENTE,LOJA,MVTO,TABELA,CNPJ_CPF)"+CRLF
				cInsert	+= "		VALUES ('"+(cTabRet)->CLIENTE+"','"+(cTabRet)->LOJA+"','S','"+cTabAtu+"','"+(cTabRet)->CNPJ_CPF+"')"+CRLF

				_RetSql:=  TcSQLExec(cInsert)
				
			End Transaction
					
			If !(_RetSql==0)
			
				_RetSql := TcSQLError()
				MsgAlert(AllTrim(_RetSql),"Erro na criação da Tabela. Contactar Administrador do Sistema ")
				
			endIf	
						
			(cTabRet)->(dbSkip())
			
		EndDo
		
		(cTabRet)->(dbCloseArea())
		
Return 
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GrvLgEmp
Manutenção do Log
@type function
@author Cris
@since 13/06/2017
@version 1.0
@param cEmpAtu, character, (Descrição do parâmetro)
@param cPesqTab, character, (Descrição do parâmetro)
@param nAcao, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function GrvLgEmp(cEmpAtu,cPesqTab,nAcao)

	Local cInsUpd	:= ''
	Local _RetSql	:= ''

		BEGIN TRANSACTION
				
			//Se Inclui
			if nAcao == 1
			
				cInsUpd	:= " INSERT INTO TMPCLIENTE_MVTO_LOG(EMPRESA,TABELA,DATA_INICIAL_CONS,HORA_INICIAL_CONS)"+CRLF
				cInsUpd	+= "		VALUES ('"+cEmpAtu+"','"+cPesqTab+"','"+cDtini+"','"+cHrIni+"') "+CRLF				
				
				_RetSql:=  TcSQLExec(cInsUpd)
		
				If !(_RetSql==0)
				
					_RetSql := TcSQLError()
					MsgAlert(AllTrim(_RetSql),"Erro na inclusão de linha de log. Contactar Administrador do Sistema ")
					
				endIf			
			
			//Se altera
			Elseif nAcao == 2
			
				//deixar o conteúdo das gravações de data final e da hora final no momento da gravação do log, 
				//para entender o início e fim de cada item de gravação de cada tabela
				cInsUpd	:= " UPDATE TMPCLIENTE_MVTO_LOG "+CRLF
				cInsUpd	+= " SET DATA_FINAL_CONS = '"+Dtos(MsDate())+"',HORA_FINAL_CONS = '"+Time()+"'	"+CRLF	
				cInsUpd	+= " WHERE EMPRESA = '"+cEmpAtu+"' "+CRLF
				cInsUpd	+= "   AND TABELA = '"+cPesqTab+"' "+CRLF	
				cInsUpd	+= "   AND DATA_INICIAL_CONS = '"+cDtini+"' "+CRLF	
				cInsUpd	+= "   AND HORA_INICIAL_CONS = '"+cHrIni+"' "+CRLF					
				
				_RetSql:=  TcSQLExec(cInsUpd)
		
				If !(_RetSql==0)
				
					_RetSql := TcSQLError()
					MsgAlert(AllTrim(_RetSql),"Erro na atualização da linha de log. Contactar Administrador do Sistema ")
					
				EndIf			
							
			EndIf	
	
		END TRANSACTION
			
Return 
