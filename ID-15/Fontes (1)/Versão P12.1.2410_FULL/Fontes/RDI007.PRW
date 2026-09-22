#Include 'Protheus.ch'
Static aCposAtu	:= {}
Static cCodQZ1	:= ''
Static cTabQZ1	:= ''
Static lNMenu	:= .F.
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RDI007
Rotina para criar as tabelas intermediárias com o objetivo de carregar todos os arquivos enviados sem validá-los e posterior-
mente  validados para uma outra etapa incluir os registros na tabela destino(pré requisito: layout de arquivos validados e acor-
dados pelo cliente). Rotina pode ser acionada via menu e via startjob.
@type function
@author Cris
@since 28/06/2017
@version 1.0
@param cCdCdQZ1, caracter, (Codigo da tabela do importador)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function RDI007(cCdCdQZ1)
	
	Local cCposTMP	:= ''
	Local aAreaAtu	:= GetArea()
	Default	cCdCdQZ1:= ''
		
		lNMenu	:= Isblind()
		
		if !lNMenu
		
			if !MsgYesNo('Deseja continuar checagem/inclusão de tabela temporária?')
				
				RestArea(aAreaAtu)
				Return
			
			Else
					
				cCodQZ1	:= QZ1->QZ1_CODIGO
				cTabQZ1	:= ALLTRIM(QZ1->QZ1_DESTIN) 
				
			EndIf
		
		Elseif lNMenu .AND. Empty(cCdCdQZ1)
			
			Conout('RDI007: Codigo do cadastro não informado!')
			RestArea(aAreaAtu)
			Return
		
		Elseif lNMenu .AND. Empty(cCdCdQZ1)
		
			dbSelectArea("QZ1")
			QZ1->(dbSetOrder(1))
			if QZ1->(dbSeek(xFilial("QZ1")+cCdCdQZ1))
								
				cCodQZ1	:= QZ1->QZ1_CODIGO
				cTabQZ1	:= ALLTRIM(QZ1->QZ1_DESTIN) 
							
			EndIf
			
		EndIf
		
		//Carrega os campos da QZ2
		CARREQZ2(cCodQZ1,@aCposAtu)
		
		//Monta campos para criar tabela intermediária
		MntCpTMP(@cCposTMP)
		
		//Cria tabelas para importar dados do arquivo e quebrar processamentos
		if CriaTMP(cCposTMP,lNMenu)

			//Envia e-mail????? Criar tabela Origens X Responsabilidades
		
		EndIf
		
		aCposAtu	:= {}
		cCodQZ1		:= ''
		cTabQZ1		:= ''
		cCposTMP	:= ''
		
		RestArea(aAreaAtu)
		
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
    Local aAreaSx3  := SX3->(GetArea())
    Local nSeek     := 10 //ALTERADO POR THIAGO GOES EM 28/07/2020
    
    SX3->(dbSetOrder(2)) //X3_CAMPO
    AEval(aCposAtu,{|c| c[4] := If(Empty(c[4]) .And. SX3->(DbSeek(PadR(c[1],nSeek))),cValToChar(GetSx3Cache( c[1] ,"X3_TAMANHO")),c[4])})  

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
				cCposTMP	+= ","+Alltrim(aCposAtu[iCpo][1])+" CHAR("+cTamCpo+") DEFAULT '"+space(Val(cTamCpo))+"' NOT NULL ENABLE "+CRLF			
			Endif
			//se campo estiver configurado para efetuar validaãão, cria  campo de status de validaãão
			if aCposAtu[iCpo][2] = 'S'
			
				cCposTMP	+= ",VLD"+Alltrim(aCposAtu[iCpo][1])+" VARCHAR2(26) DEFAULT ' ' NULL "+CRLF	
			
			EndIf
			
		Next iCpo 	
		
		cCposTMP	+= ",Duplic NUMBER DEFAULT 0 NULL "+CRLF
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
	Local cNmTmpTb	:= Alltrim(GetNewPar('FS_RDI001','ARQ'))+cTabQZ1
	Local _RetExec
	Local aUnique   := U_GetUnique(cTabQZ1)
	

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
			    cCriaTMP	:= U_FormatStr("	CREATE UNIQUE INDEX "+cNmTmpTb+"_BUSINESS ON "+cNmTmpTb+" (NumeroLote,{1}) ",{cCriaTMP})
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
                  
			       cCriaTMP	:= U_FormatStr("	CREATE UNIQUE INDEX "+cNmTmpTb+"_BUSINESS ON "+cNmTmpTb+" (NumeroLote,{1}) ",{cCriaTMP})
			       
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

//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarreQZ2
Carrego os campos da QZ2 conforme layout configurado
@type function
@author Cris
@since 28/06/2017
@version 1.0
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function CARREQZ2(cCodAtu,aCpos)

	Local aArea		:= GetArea()
	Local aAreaQZ2	:= QZ2->(GetArea())

		dbSelectArea('QZ2')
		QZ2->(dbSetOrder(1))
		if QZ2->(dbSeek(xFilial('QZ2')+cCodAtu))
		
			While QZ2->(!Eof()) .And. xFilial('QZ2')+cCodAtu == QZ2->QZ2_FILIAL+QZ2->QZ2_CODEXT

				aAdd(aCpos,{QZ2->QZ2_CPODES,QZ2->QZ2_REJEIT,QZ2->QZ2_TIPDES,QZ2->QZ2_TAMDES})
				
				QZ2->(dbSkip())
				
			EndDo
			
		EndIf
		
	RestArea(aArea)
	RestArea(aAreaQZ2)
	
Return 
