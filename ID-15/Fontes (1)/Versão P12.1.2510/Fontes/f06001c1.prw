#INCLUDE "TOTVS.CH"

Static oDbApData := Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} F06001C1
Função para abrir Conexão com o banco ApData 
 
@author Eduardo Fernandes 
@since  04/11/2016
@return lRet,  lógico  

@param   cMsgError, caracter, Mensagem de Erro
@project MAN0000007423040_EF_004
@cliente Rededor
@version P12.1.7
             
/*/
//-----------------------------------------------------------------------
User Function F06001C1(cMsgError)
Local lRet    := .T.
Local cDBMS   := GETMV("FS_DBMS")
Local cBanco  := GETMV("FS_DTBASE")
Local cServer := GETMV("FS_SERVER")
Local nPort	:= Val(GETMV("FS_PORT"))	

Default cMsgError := ""						
							
If Empty(cDBMS) .Or. Empty(cBanco) .Or. Empty(cServer) .Or. Empty(nPort)
	cMsgError := "Parametros de conexao nao preenchidos FS_DBMS|FS_DTBASE|FS_SERVER|FS_PORT"
	lRet := .F.	
Else	
	
	If ValType(oDbApData) == "O" .And. oDbApData:HasConnection()	
		cMsgError := "Conexão com o ApData ja esta Ativa"
		lRet := .F.
	Else		
		//------------------------------------------------
		// Cria classe de conexao com o banco da SCI
		//------------------------------------------------ 
		oDbApData := FWDBAccess():New(cDBMS + "/" + cBanco, cServer, nPort)
		oDbApData:SetConsoleError( .T. )																		
											
		// Conexao com base Externa
		If !oDbApData:OpenConnection()
			cMsgError := "Falha Conexão com a base Externa - Erro: " + AllTrim( oDbApData:ErrorMessage() )		
			lRet := .F.
		EndIf
	Endif	
Endif

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} F06001C2
Função para fechar Conexão com o banco ApData 
 
@author Eduardo Fernandes 
@since  04/11/2016
@param  cMsgError, caracter, Mensagem de Erro
@return lRet,  lógico  

@project MAN0000007423040_EF_004
@cliente Rededor
@version P12.1.7
             
/*/
//-----------------------------------------------------------------------
User Function F06001C2(cMsgError)
Local lRet := .T.

Default cMsgError := ""

If ValType(oDbApData) == "O" .And. !oDbApData:HasConnection()	
	cMsgError := "Conexao com o ApData nao esta Ativa"
	lRet := .F.
Else
	//------------------------------------------
	// Fecha Conexao com o Banco de Integracao //
	//------------------------------------------
	oDbApData:CloseConnection()
	oDbApData:Finish()
Endif

oDbApData := Nil

Return lRet

//--------------------------------------------------------------------------
/*{Protheus.doc} F06001C3
Funcao para Criar tabela no Banco do ApData

@author     Eduardo Fernandes
@since      04/11/2016

@Param		 aTblStru, array
@Param		 cTbl, caracter
@Param		 cMsgError, caracter
@return     lRet, lógico
@version    P12.1.7
@project    MAN0000007423040_EF_004
*/
//--------------------------------------------------------------------------
User Function F06001C3(cTbl, aTblStru, cMsgError)
Local nI 		 := 0
Local lRet 	 := .T.
Local cCommand := ""
Local cOwner	:= GetMV('FS_OWNER',,'')
Local aVet		:= {}

Default cMsgError := ""

//Valida parametros
If Empty(cTbl)
	cMsgError := "Tabela nao informada nos parametros"
ElseIf Len(aTblStru) == 0
	cMsgError := "Array de Estrutura da tabela " + cTbl + " nao informado nos parametros"
Endif	 

If ValType(oDbApData) == "O" .And. !oDbApData:HasConnection()	
	cMsgError := "Conexao com o ApData nao esta Ativa"
	lRet := .F.
ElseIf Empty(cMsgError)
	If !oDbApData:FileExists(cTbl)
		cCommand := "CREATE TABLE " + cOwner + cTbl + "( "
		cCommand += cTbl + "_FILIAL " + IIf(TcGetDb() = "ORACLE", "VARCHAR2", "VARCHAR") + " (008), "
		For nI := 1 To Len(aTblStru)
			aVet := StrTokArr2(aTblStru[nI][1], "_", .T.)
			If Len(aVet) > 1 .AND. aVet[2] == "FILIAL"
				Loop
			Else	 
				cCommand += aTblStru[nI][1] + " " + Iif(aTblStru[nI][2] == "VARCHAR", Iif(TcGetDb() = "ORACLE", "VARCHAR2", "VARCHAR") + "(" + StrZero(aTblStru[nI][3], 3) + ")", aTblStru[nI][2]) + ", "
			Endif	
		Next
		cCommand := Left(cCommand, Len(cCommand) - 2) + ")"	 
	
		lRet := oDbApData:SQLExec(cCommand)
		If oDbApData:HasError()
			cMsgErr += "Erro: [" + AllTrim(Str(oDbApData:SqlError())) + "] na criacao da tabela: " + cTbl + " - " + AllTrim(oDbApData:ErrorMessage())  	
	    	ConOut( cMsgErr )  
		EndIf
		
		//------------------------------------------------
		// Cria indice na tabela Interface p/ Otimizar
		// Performance de Querys - Adic Edu em 21/11/16
		//------------------------------------------------ 
		If lRet
			cCommand := "CREATE INDEX T_" + cTbl + "_IDX ON " + cOwner + cTbl + " (" + cTbl + "_FILIAL," + cTbl + "_DTTRANSAC," + cTbl + "_HRTRANSAC," + cTbl + "_STATUS)"
			lRet := oDbApData:SQLExec(cCommand)
			If oDbApData:HasError()
				cMsgErr += "Erro: [" + AllTrim(Str(oDbApData:SqlError())) + "] na criacao da tabela: " + cTbl + " - " + AllTrim(oDbApData:ErrorMessage())  	
		    	ConOut( cMsgErr )
		    Endif	  			
		Endif	
	Endif
Else
	lRet := .F.	
Endif

Return lRet

//--------------------------------------------------------------------------
/*{Protheus.doc} F06001C4
Funcao generica para Inserir registros no Banco do ApData

@author     Eduardo Fernandes
@since      04/11/2016

@Param		cTbl, caracter, nome da tabela
@Param		aTblStru, array, estrutura da tabela
@param      aValues, array, valores a serem inseridos na tabela
@Param		cMsgError, caracter, Mensagem de erro
@return     lRet, lógico
@version    P12.1.7
@project    MAN0000007423040_EF_004
*/
//--------------------------------------------------------------------------
User Function F06001C4(cTbl, aTblStru, aValues, cMsgError)
Local nI 		  := 0
Local lRet 	  := .T.
Local cCommand  := ""
Local c1List := ""
Local cOwner	:= GetMV('FS_OWNER',,'')

Default cMsgError := ""

//Valida parametros
If Empty(cTbl)
	cMsgError := "Tabela nao informada nos parametros"
ElseIf Len(aTblStru) == 0
	cMsgError := "Array de Estrutura da tabela " + cTbl + " nao informado nos parametros"
ElseIf Len(aValues) == 0
	cMsgError := "Array de Valores da tabela " + cTbl + " nao informado nos parametros"
Endif	 

If ValType(oDbApData) <> "O" .And. !oDbApData:HasConnection()	
	cMsgError := "Conexao com o ApData nao esta Ativa"
	lRet := .F.
ElseIf Empty(cMsgError)
	If oDbApData:FileExists(cTbl)
		//Monta Lista Campos
		 AEval(aTblStru, {|x| c1List += x[1] + ", "})
	
		cCommand := "INSERT INTO " + cOwner + cTbl + " (" + Left(c1List, Len(c1List) - 2) + ") VALUES ("	
		For nI := 1 To Len(aValues)
			cCommand += "'" + Iif(ValType(aValues[nI]) == "N", AllTrim(Str(aValues[nI])), Iif(ValType(aValues[nI]) == "D", DToS(aValues[nI]), aValues[nI])) + "', "
		Next			
		cCommand := Left(cCommand, Len(cCommand) - 2) + ") "
		//cCommand += " COMMIT "
	
		lRet := oDbApData:SQLExec(cCommand)
		If oDbApData:HasError()
			cMsgError += "Erro: [" + AllTrim(Str(oDbApData:SqlError())) + "] na criacao da tabela: " + cTbl + " - " + AllTrim(oDbApData:ErrorMessage())  	
		EndIf
	Endif
Else
	lRet := .F.
Endif

Return lRet

//--------------------------------------------------------------------------
/*{Protheus.doc} F06001C5
Funcao para executar SCRIPT (UPDATE/DELETE) no Banco do ApData

@author     Eduardo Fernandes
@since      07/11/2016

@Param		cCommand, caracter, comando a ser executado
@Param		cMsgError, caracter, Mensagem de erro
@return     lRet, lógico
@version    P12.1.7
@project    MAN0000007423040_EF_004
*/
//--------------------------------------------------------------------------
User Function F06001C5(cCommand, cMsgError)
Local lRet 	 := .T.

Default cMsgError := ""

If Empty(cCommand)	
	cMsgError := "Parametro de script vazio"
	lRet := .F.
Endif	
	
If ValType(oDbApData) <> "O" .And. !oDbApData:HasConnection()	
	cMsgError := "Conexao com o ApData nao esta Ativa"
	lRet := .F.
ElseIf Empty(cMsgError)
	If !oDbApData:SQLExec(cCommand)
 		cMsgError := "Erro na atualizacao dos dados - Erro: [" + AllTrim(oDbApData:ErrorMessage()) + "]"
		lRet := .F.
	Endif			
Endif		 

Return lRet

//--------------------------------------------------------------------------
/*{Protheus.doc} F06001C6
Funcao para SELECT no Banco do ApData

@author     Eduardo Fernandes
@since      07/11/2016

@Param		cQuery, caracter, consulta a ser realizada no banco
@Param		cAliasTMP, caracter, Alias temporário
@Param		cMsgError, caracter, mensagem de erro
@return     lRet, lógico
@version    P12.1.7
@project    MAN0000007423040_EF_004
*/
//--------------------------------------------------------------------------
User Function F06001C6(cQuery, cAliasTMP, cMsgError)
Local lRet 	 := .T.

Default cMsgError := ""

If Empty(cQuery)	
	cMsgError := "Parametro de query vazio"
	lRet := .F.
ElseIf Empty(cAliasTMP)
	cMsgError := "Parametro de Alias nao informado"
	lRet := .F.
Endif	
	
If ValType(oDbApData) <> "O" .And. !oDbApData:HasConnection()	
	cMsgError := "Conexao com o ApData nao esta Ativa"
	lRet := .F.
ElseIf Empty(cMsgError)
	
	If Select(cAliasTMP) > 0
		(cAliasTMP)->(dbCloseArea())
	Endif
	
	oDbApData:NewAlias( cQuery , cAliasTMP )
	If oDbApData:HasError()
		cMsgError := "Erro na selecao dos dados na tabela " + cAliasTMP + " - " + AllTrim(oDbApData:ErrorMessage())
		lRet := .F.	
	Endif	
Endif		 

Return lRet