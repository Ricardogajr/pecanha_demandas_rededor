#Include 'Protheus.ch'
#include 'parmtype.ch'
#include "Fileio.ch"
#Include "TopConn.ch"
Static aCposAtu	:= {}
Static cCodZVJ	:= ''
Static cTabZVJ	:= ''
Static lNMenu	:= .F. 
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MGATMP00
Rotina para criar as tabelas intermediárias com o objetivo de carregar todos os arquivos enviados sem validá-los e posterior-
mente  validados para uma outra etapa incluir os registros na tabela destino(pré requisito: layout de arquivos validados e acor-
dados pelo cliente). Rotina pode ser acionada via menu e via startjob.
@type function
@author Cris
@since 28/06/2017
@version 1.0
@param cCdCdZVJ, caracter, (Codigo da tabela do importador)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function MGATMP00(cCdCdZVJ)
	
	Local cCposTMP	:= ''
	Local aAreaAtu	:= FWGetArea()
	Default	cCdCdZVJ:= ''
		
		lNMenu	:= Isblind()
		
		if !lNMenu
		
			if !MsgYesNo('Deseja continuar checagem/inclusão de tabela temporária?')
				
				RestArea(aAreaAtu)
				Return
			
			Else
					
				cCodZVJ	:= ZVJ->ZVJ_CODIGO
				cTabZVJ	:= ALLTRIM(ZVJ->ZVJ_DESTIN) 
				
			EndIf
		
		Elseif lNMenu .AND. Empty(cCdCdZVJ)
			
			Conout('MGATMP00: Codigo do cadastro não informado!')
			RestArea(aAreaAtu)
			Return
		
		Elseif lNMenu .AND. Empty(cCdCdZVJ)
		
			dbSelectArea("ZVJ")
			ZVJ->(dbSetOrder(1))
			if ZVJ->(dbSeek(xFilial("ZVJ")+cCdCdZVJ))
								
				cCodZVJ	:= ZVJ->ZVJ_CODIGO
				cTabZVJ	:= ALLTRIM(ZVJ->ZVJ_DESTIN) 
							
			EndIf
			
		EndIf
		
		//Carrega os campos da ZVK
		U_CarreZVK(cCodZVJ,@aCposAtu)
		
		//Monta campos para criar tabela intermediária
		MntCpTMP(@cCposTMP)
		
		//Cria tabelas para importar dados do arquivo e quebrar processamentos
		if CriaTMP(cCposTMP,lNMenu)

			//Envia e-mail????? Criar tabela Origens X Responsabilidades
		
		EndIf
		
		aCposAtu	:= {}
		cCodZVJ		:= ''
		cTabZVJ		:= ''
		cCposTMP	:= ''
		
		RestArea(aAreaAtu)
		
Return
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarreZVK
Carrego os campos da ZVK conforme layout configurado
@type function
@author Cris
@since 28/06/2017
@version 1.0
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function CarreZVK(cCodAtu,aCpos)

	Local aArea		:= FWGetArea()
	Local aAreaZVK	:= ZVK->(FWGetArea())

		dbSelectArea('ZVK')
		ZVK->(dbSetOrder(1))
		if ZVK->(dbSeek(xFilial('ZVK')+cCodAtu))
		
			While ZVK->(!Eof()) .And. xFilial('ZVK')+cCodAtu == ZVK->ZVK_FILIAL+ZVK->ZVK_CODEXT

				aAdd(aCpos,{ZVK->ZVK_CPODES,ZVK->ZVK_REJEIT,ZVK->ZVK_TIPDES,ZVK->ZVK_TAMDES})
				
				ZVK->(dbSkip())
				
			EndDo
			
		EndIf
		
	RestArea(aArea)
	RestArea(aAreaZVK)
	
Return 
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MntCpTMP
Monta campos da tabela itermediária de detalhe
@type function
@author Cris
@since 28/06/2017
@version 1.0
@param cCposTMP, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function MntCpTMP(cCposTMP)

	Local iCpo		:= 0
	Local cTpCpo	:= ''
	Local cTamCpo	:= ''
    Local aAreaSx3  := SX3->(FWGetArea())
    //Local nSeek     := Len(SX3->X3_CAMPO)
    
    //SX3->(dbSetOrder(2)) //X3_CAMPO
    AEval(aCposAtu,{|c| c[4] := If(Empty(c[4]) .And. !Empty(FWSX3Util():GetFieldType(c[1])),cValToChar(GetSx3Cache(c[1], 'X3_TAMANHO')),c[4])})  

		cCposTMP	:= " NumeroLote	varchar2(15) NOT NULL        "+CRLF
		cCposTMP	+= ", LINHA NUMBER DEFAULT 0 NOT NULL ENABLE "+CRLF			
		
		For iCpo := 1 to len(aCposAtu)
		
			//monta o  tipo do campo
			if aCposAtu[iCpo][3] == 'D'
		
				//caso a barra seja enviada soma mais 2 para garantir a gravaãão do dado por inteiro
				cTamCpo		:= StrZero(val(aCposAtu[iCpo][4]),3)
			
			Else
			
				cTamCpo		:= aCposAtu[iCpo][4]
						
			EndIf
			If aCposAtu[iCpo][3] = 'N'
				cCposTMP	+= ","+Alltrim(aCposAtu[iCpo][1])+" NUMBER DEFAULT 0 NOT NULL ENABLE "+CRLF
			Else 	
				cCposTMP	+= ","+Alltrim(aCposAtu[iCpo][1])+" CHAR("+cTamCpo+") DEFAULT '"+space(Val(cTamCpo))+"'  NOT NULL ENABLE "+CRLF			
			Endif
			//se campo estiver configurado para efetuar validaãão, cria  campo de status de validaãão
			if aCposAtu[iCpo][2] = 'S'
			
				cCposTMP	+= ",VLD"+Alltrim(aCposAtu[iCpo][1])+" VARCHAR2(26) DEFAULT ' ' NULL "+CRLF	
			
			EndIf
			
		Next iCpo 	
		
		cCposTMP	+= ",Duplic VARCHAR2(26) DEFAULT ' ' NULL "+CRLF
		cCposTMP	+= ",Registro_Valido VARCHAR2(26) DEFAULT ' '  NULL "+CRLF	
		cCposTMP	+= ",DataHoraMig VARCHAR2(26) DEFAULT ' '  NULL "+CRLF
		cCposTMP	+= ",DataHoraTrf VARCHAR2(26)  DEFAULT ' ' NULL "+CRLF	
		cCposTMP	+= ",arquivo VARCHAR2(100)  DEFAULT ' ' NULL "+CRLF
		cCposTMP	+= ",Recno NUMBER  DEFAULT 0 NULL "+CRLF	
		cCposTMP	+= ", PRIMARY KEY (NumeroLote,Linha,Recno)"+CRLF	
						
Return 
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaTMP
Executa a criação da tabela intermediária
@type function
@author Cris
@since 28/06/2017
@version 1.0
@param cCposTMP, character, (Descrição do parâmetro)
@param lNMenu, lógico, .T. chamado via job, .F. Chamado via menu.
@return ${lCriou}, ${.T. criou a tabela .F. não criou a tabela}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function CriaTMP(cCposTMP,lNMenu)

	Local cCriaTMP	:= ''
	Local lCriou	:= .T.
	Local cNmTmpTb	:= Alltrim(SuperGetMV('ES_PRFTBMG',,'ARQ'))+cTabZVJ
	Local _RetExec
	Local aUnique   := GetUnique(cTabZVJ)
	

	If MsFile(cNmTmpTb) .And. ( TcSQLExec("DROP TABLE "+cNmTmpTb) != 0 )
	   MsgAlert(AllTrim(TCSQLERROR()),"Não foi possível recriar a tabela, a rotina não continuará sendo executada!")
	   return .F.
	Endif

	If MsFile(cNmTmpTb+'_LOG') .And. ( TcSQLExec("DROP TABLE "+cNmTmpTb+"_LOG") != 0 )
	   MsgAlert(AllTrim(TCSQLERROR()),"Não foi possível recriar a tabela, a rotina não continuará sendo executada!")
	   return .F.
	Endif

	If MsFile(cNmTmpTb+'_RESUMO') .And. ( TcSQLExec("DROP TABLE "+cNmTmpTb+"_RESUMO") != 0 )
	   MsgAlert(AllTrim(TCSQLERROR()),"Não foi possível recriar a tabela, a rotina não continuará sendo executada!")
	   return .F.
	Endif

	if !MsFile(cNmTmpTb+'_LOG')
       cCriaTMP := "CREATE TABLE "+cNmTmpTb+"_LOG                          " + CRLF
       cCriaTMP += "   (NUMEROLOTE VARCHAR2(15 BYTE) NOT NULL ENABLE,      " + CRLF
       cCriaTMP += "	NOME_ARQUIVO VARCHAR2(100 BYTE) NOT NULL ENABLE,   " + CRLF
       cCriaTMP += "	LINHA NUMBER DEFAULT 0 NULL,                       " + CRLF
       cCriaTMP += "	CHAVE VARCHAR2(100 BYTE) NOT NULL ENABLE,          " + CRLF
       cCriaTMP += "	DESC_CAMPO VARCHAR2(15 BYTE) NOT NULL ENABLE,      " + CRLF
       cCriaTMP += "	CONTEUDO_CAMPO VARCHAR2(100 BYTE) NOT NULL ENABLE, " + CRLF
       cCriaTMP += "	DESC_ERRO VARCHAR2(100 BYTE) NOT NULL ENABLE       " + CRLF
       cCriaTMP += "   ) SEGMENT CREATION IMMEDIATE                       " 		
			
	   If (TcSQLExec(cCriaTMP) != 0)
          MsgAlert(AllTrim(TCSQLERROR()),". Não foi possível criar a tabela de LOG, a rotina não continuará sendo executada!")
          return .F.
	   Endif
	Endif  
	
	//Verifica se a tabela temporária já existe no banco, caso não exista a cria
	if !MsFile(cNmTmpTb+'_RESUMO')

		cCriaTMP	:=	"	CREATE TABLE "+cNmTmpTb+"_RESUMO ( "+CRLF
		cCriaTMP	+= " 										NumeroLote		VARCHAR2(015) NOT NULL,  "+CRLF
		cCriaTMP	+= " 										Data_Inicial	VARCHAR2(008) NOT NULL, "+CRLF
		cCriaTMP	+= " 										Hora_Inicial 	VARCHAR2(008) NOT NULL, "+CRLF
		cCriaTMP	+= " 										Nome_Arquivo	VARCHAR2(100) NOT NULL, "+CRLF	
		cCriaTMP	+= " 										Qtde_Registros 	int, "+CRLF
		cCriaTMP	+= " 										Tamanho_KB 		float, "+CRLF//decimal(10,2)
		cCriaTMP	+= " 										Qtde_lnLidas	int, "+CRLF
		cCriaTMP	+= " 										Data_Final 		VARCHAR2(008) NULL, "+CRLF
		cCriaTMP	+= " 										Hora_Final 		VARCHAR2(008) NULL, "+CRLF
		cCriaTMP	+= " 										XMIGLT 	 	    VARCHAR2(028) DEFAULT ' ' NULL, "+CRLF
		cCriaTMP	+= " 										StatusVld	 	VARCHAR2(001) DEFAULT ' ' NULL, "+CRLF
		cCriaTMP	+= " 										StatusImp	 	VARCHAR2(001) DEFAULT ' ' NULL, "+CRLF
		cCriaTMP	+= " 										StatusTrf	 	VARCHAR2(001) DEFAULT ' ' NULL, "+CRLF
		cCriaTMP	+= " 										MaxRecno	 	NUMBER, "+CRLF
		cCriaTMP	+= " 										LastRecno	    NUMBER, "+CRLF
        cCriaTMP	+= " 										MarginSaf	    NUMBER  "+CRLF		
		cCriaTMP	+=	"	)"+CRLF	
			
		_RetExec:=  TcSQLExec(cCriaTMP)
		
		//Se não criou não prossegui as outras criações
		If !(_RetExec==0) 

			_RetExec = TCSQLERROR()
			
			if !lNMenu
			
				MsgAlert(AllTrim(_RetExec),". Não foi possível criar a tabela, a rotina não continuará sendo executada!")
			
			Else
				
				Conout(AllTrim(_RetExec)+". Não foi possível criar a tabela, a rotina não continuará sendo executada!")	
				
			EndIf

		Else

			//cria o indice da tabela Resumo
			cCriaTMP	:=	"	CREATE UNIQUE INDEX "+cNmTmpTb+"_RESUMO_UNQ ON "+cNmTmpTb+"_RESUMO (NumeroLote,Nome_Arquivo) "+CRLF  
			
			_RetExec:=  TcSQLExec(cCriaTMP)
			//Se não criou o indice aborta as outras criações
			If !(_RetExec==0) 

				_RetExec = TCSQLERROR()
				
				if !lNMenu
				
					MsgAlert(AllTrim(_RetExec),"Não foi possível criar o indice, a rotina não continuará sendo executada e a tabela criada será cancelada!")
				
				Else
				
					Conout("Não foi possível criar o indice, a rotina não continuará sendo executada e a tabela criada será cancelada!"+_RetExec+' '+time()+' '+Dtoc(MsDate()))
					
				EndIf
				
				_RetExec :=  TcSQLExec("DROP TABLE "+cNmTmpTb+"_RESUMO" )				
				lCriou	:= .F.
			
			Else
				
				//Aviso("SUCESSO - Criação de Tabela Resumo", 'Tabela Resumo criada com sucesso.('+cNmTmpTb+'_RESUMO)', {'OK'},3)
				lCriou	:= .T.
								
			EndIf
		
		EndIf
	
	Else
		
		//Aviso("EXISTENTE - Criação de Tabela Resumo", 'Tabela Resumo não foi criada novamente, pois já consta na base.('+cNmTmpTb+'_RESUMO)', {'OK'},3)
		//Tabela já existe no banco
		lCriou	:= .F.
		
	EndIf
					
	//Se conseguiu criar tabela Resumo prossegui e verifica se a tabela detalhe não existir
	if lCriou 
	
	    If MsFile(cNmTmpTb)
	       If ( TcSQLExec("DROP TABLE "+cNmTmpTb) != 0 )
			  MsgAlert(AllTrim(TCSQLERROR()),"Não foi possível recriar a tabela, a rotina não continuará sendo executada!")
	          return .F.
	       Endif
	    Endif

		//Cria a tabela que conterá as linhas			
		cCriaTMP	:=	"	CREATE TABLE "+cNmTmpTb+" ( "+CRLF
		cCriaTMP	+=	"	"+cCposTMP+CRLF
		cCriaTMP	+=	"	)"+CRLF	
			
		_RetExec:=  TcSQLExec(cCriaTMP)
	
		If !(_RetExec==0) 

			_RetExec = TCSQLERROR()
			MsgAlert(AllTrim(_RetExec),"Não foi possível criar a tabela, a rotina não continuará sendo executada!")

		Else
		   If ! Empty(aUnique)
                cCriaTMP := ArrTokStr(aUnique,",")
			    cCriaTMP	:= U_FmtStr("	CREATE UNIQUE INDEX "+cNmTmpTb+"_BUSINESS ON "+cNmTmpTb+" (NumeroLote,{1}) ",{cCriaTMP})
			    _RetExec:=  TcSQLExec(cCriaTMP)  
			    If !(_RetExec==0) 
			        MsgStop("Não foi possível criar o índice de negócio!"+CRLF+TCSQLERROR())
			    Endif
           Endif			
           Aviso("SUCESSO - Criação de Tabela Intermediária", 'Tabela Intermediária criada com sucesso.('+cNmTmpTb+')', {'OK'},3)
           lCriou	:= .T.
		
		/*
			cCriaTMP	:=	"	CREATE UNIQUE INDEX "+cNmTmpTb+"_UNQ ON "+cNmTmpTb+" (NumeroLote,Linha) "+CRLF
			
			_RetExec:=  TcSQLExec(cCriaTMP)  
		
			If !(_RetExec==0) 

				_RetExec = TCSQLERROR()
				
				if !lNMenu
					
					MsgAlert(AllTrim(_RetExec),"Não foi possível criar o índice, a rotina não continuará sendo executada!")
				
				Else
				
					Conout("Não foi possível criar o índice, a rotina não continuará sendo executada!"+_RetExec+' '+time()+' '+Dtoc(MsDate()))
					
				EndIf
			Else
			
			   If ! Empty(aUnique)
                  
                   cCriaTMP := ArrTokStr(aUnique,",")
                  
			       cCriaTMP	:= U_FmtStr("	CREATE UNIQUE INDEX "+cNmTmpTb+"_BUSINESS ON "+cNmTmpTb+" (NumeroLote,{1}) ",{cCriaTMP})
			       
			       _RetExec:=  TcSQLExec(cCriaTMP)  
		           
			       If !(_RetExec==0) 
			       	    MsgStop("Não foi possível criar o índice de negócio!"+CRLF+TCSQLERROR())
			       Endif
                  
               Endif			

				Aviso("SUCESSO - Criação de Tabela Intermediária", 'Tabela Intermediária criada com sucesso.('+cNmTmpTb+')', {'OK'},3)
				lCriou	:= .T.

			EndIf
		*/
			
		EndIf
	
	Else

		Aviso("EXISTENTE - Criação de Tabela Intermediária", 'Tabela Intermediária não foi criada novamente, pois já consta na base.('+cNmTmpTb+')', {'OK'},3)
		lCriou	:= .F.	
				
	EndIf
			
Return lCriou

	************************************
Static Function GetUnique(cTabAlias)
	************************************
	Local aRet      := {}
	Local cAlias    := GetNextAlias()
	Local cTable    := RetSqlName(cTabAlias)
	Local cQuery    := ""
	Local aEx       := {"R_E_C_D_E_L_","R_E_C_N_O_","D_E_L_E_T_"}

	If Empty(cTable)
		return {}
	Endif

	cQuery += "SELECT c.column_name                       " + CRLF
	cQuery += "  FROM user_indexes i, user_ind_columns c  " + CRLF
	cQuery += " WHERE i.table_name  = '"+cTable+"'        " + CRLF
	cQuery += "   AND i.uniqueness  = 'UNIQUE'            " + CRLF
	cQuery += "   AND i.index_name  = c.index_name        " + CRLF
	cQuery += "   AND i.table_name  = c.table_name        " + CRLF
	cQuery += "ORDER BY c.column_position                 "


	TCQUERY cQuery NEW ALIAS (cAlias)

	While (cAlias)->(!Eof())
		If ( AScan(aEx, {| f | f == AllTrim((cAlias)->column_name) }) == 0 )
			Aadd(aRet,AllTrim((cAlias)->column_name))
		Endif
		(cAlias)->(DbSkip(1))
	EndDo

	If (Select(cAlias) > 0)
		(cAlias)->(DbCloseArea())
	Endif

Return aRet