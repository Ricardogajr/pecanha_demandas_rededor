#Include 'Protheus.ch'
Static aCposAtu	:= {}
Static cCodQZ1	:= ''
Static cTabQZ1	:= ''
Static cPath	:= ''
Static lNMenu	:= .F.
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RDI009
@type function
@author Cesar Escobar 
@since 04/09/2017
@version 1.0
@param cCdCdQZ1, caracter, (Codigo da tabela do importador)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function RDI009(cCdCdQZ1)
    
    Local lRet := .F. 
	Processa( {|| lRet := fProcessa(cCdCdQZ1) }, "Aguarde...", "Iniciando a importaÁ„o...",.F.)
Return lRet
	
Static Function fProcessa(cCdCdQZ1)
    Local lRet      := .F.	
	Local cCposTMP	:= ''
	Local aAreaAtu	:= GetArea()
	Local cNmTmpTb	:= ""
	Local nX		:= 0
	Default	cCdCdQZ1:= ''
	
	cCodQZ1	:= QZ1->QZ1_CODIGO
	cTabQZ1	:= ALLTRIM(QZ1->QZ1_DESTIN) 
	cPath   := U_GetDir(101) + AllTrim(QZ1->QZ1_DESTIN) + "\" 
	
	IncProc("Carregando os campos para validaÁ„o")
	//Carrega os campos da QZ2
	CarreQZ2(cCodQZ1,@aCposAtu)
	
	IncProc("Montando os campos para validaÁ„o")
	//Monta campos para criar tabela intermedi·ria
	MntCpTMP(@cCposTMP)
	
	cNmTmpTb := Alltrim(GetNewPar('FS_RDI001','ARQ'))+cTabQZ1
	//Cria tabelas para importar dados do arquivo e quebrar processamentos
	IncProc("Criando a tabela tempor·ria")
	If CriaTMP(cCposTMP,lNMenu,cNmTmpTb)
                   
       aArqsTXT := U_fDirectory(cPath,Upper(Alltrim(cTabQZ1))+"*.TXT")
       
       If Empty(aArqsTXT)
           MsgStop("N„o h· arquivos para serem processados! Verifique.")
           Return
       Endif
       
       lRet := U_RDI005(cNmTmpTb,  aArqsTXT )
       
       If ! IsInCallStack( 'U_RDI008' )
          If lRet
             MsgInfo("Processamento concluÌdo com sucesso!")
          Else
             MsgStop("Erro durante o processamento! Verifique.")
          EndIf
	   Endif
	EndIf
	
	aCposAtu	:= {}
	cCodQZ1		:= ''
	cTabQZ1		:= ''
	cCposTMP	:= ''
	
	RestArea(aAreaAtu)
	
Return lRet
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarreQZ2
Carrego os campos da QZ2 conforme layout configurado
@type function
@author Cris
@since 28/06/2017
@version 1.0
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function CarreQZ2(cCodAtu,aCpos)

	Local aArea		:= GetArea()
	Local aAreaQZ2	:= QZ2->(GetArea())

		dbSelectArea('QZ2')
		QZ2->(dbSetOrder(1))
		if QZ2->(dbSeek(xFilial('QZ2')+cCodAtu))
		
			While xFilial('QZ2')+cCodAtu == QZ2->QZ2_FILIAL+QZ2->QZ2_CODEXT

				aAdd(aCpos,{QZ2->QZ2_CPODES,QZ2->QZ2_REJEIT,QZ2->QZ2_TIPDES,QZ2->QZ2_TAMDES})
				
				QZ2->(dbSkip())
				
			EndDo
			
		EndIf
		
	RestArea(aArea)
	RestArea(aAreaQZ2)
	
Return 
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MntCpTMP
Monta campos da tabela itermedi„ria de detalhe
@type function
@author Cris
@since 28/06/2017
@version 1.0
@param cCposTMP, character, (Descri„„o do par„metro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function MntCpTMP(cCposTMP)

	Local iCpo		:= 0
	Local cTpCpo	:= ''
	Local cTamCpo	:= ''

		cCposTMP	:= " NumeroLote	varchar(15) NOT NULL         "+CRLF
		cCposTMP	+= ", LINHA NUMBER DEFAULT 0 NOT NULL ENABLE "+CRLF			
		
		For iCpo := 1 to len(aCposAtu)
		
			//monta o  tipo do campo
			if aCposAtu[iCpo][3] == 'D'
		
				//caso a barra seja enviada soma mais 2 para garantir a grava„„o do dado por inteiro
				cTamCpo		:= StrZero(val(aCposAtu[iCpo][4]),3)
			
			Else
			
				cTamCpo		:= aCposAtu[iCpo][4]
						
			EndIf
			If aCposAtu[iCpo][3] = 'N'
				cCposTMP	+= ","+Alltrim(aCposAtu[iCpo][1])+" NUMBER DEFAULT 0 "+CRLF
				
			Else
				cCposTMP	+= ","+Alltrim(aCposAtu[iCpo][1])+" varchar("+cTamCpo+") DEFAULT '"+space(Val(cTamCpo))+"'  NULL "+CRLF			
			Endif
			//se campo estiver configurado para efetuar valida„„o, cria  campo de status de valida„„o
			if aCposAtu[iCpo][2] = 'S'
			
				cCposTMP	+= ",VLD"+Alltrim(aCposAtu[iCpo][1])+" varchar(26) DEFAULT ' ' NULL "+CRLF	
			
			EndIf
			
		Next iCpo
		
		cCposTMP	+= ",Duplic NUMBER DEFAULT 0 NULL "+CRLF
		cCposTMP	+= ",Registro_Valido varchar(26) DEFAULT ' '  NULL "+CRLF	
		cCposTMP	+= ",DataHoraMig varchar(26) DEFAULT ' '  NULL "+CRLF
		cCposTMP	+= ",DataHoraTrf varchar(26)  DEFAULT ' ' NULL "+CRLF	
		cCposTMP	+= ",arquivo varchar(100)  DEFAULT ' ' NULL "+CRLF	
		cCposTMP	+= ", PRIMARY KEY (NumeroLote,Linha,RECNO)"+CRLF	
						
Return 
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaTMP
Executa a CriaÁ„o da tabela intermedi·ria
@type function
@author Cris
@since 28/06/2017
@version 1.0
@param cCposTMP, character, (Descri„„o do par„metro)
@param lNMenu, l„gico, .T. chamado via job, .F. Chamado via menu.
@return ${lCriou}, ${.T. criou a tabela .F. n„o criou a tabela}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function CriaTMP(cCposTMP,lNMenu,cNmTmpTb)

	Local cCriaTMP	:= ''
	Local lCriou	:= .T.
	Local _RetExec	
	Local cCriaSeq  := ""
	
	//Se conseguiu criar tabela Resumo prossegui e verifica se a tabela detalhe n„o existir
	If !MsFile(cNmTmpTb)//len(U_ListTab(cNmTmpTb)) == 0

		//Cria a tabela que conter„ as linhas			
		cCriaTMP	:=	"	CREATE TABLE "+cNmTmpTb+" ( "+CRLF
		cCriaTMP	+=	"	"+cCposTMP+CRLF
		cCriaTMP	+=	"	)"+CRLF	
			
		_RetExec:=  TcSQLExec(cCriaTMP)
	
		If _RetExec < 0 

			_RetExec = TCSQLERROR()
			MSGALERT(AllTrim(_RetExec),"N„o foi possÌvel criar a tabela, a rotina n„o continuar· sendo executada!")
			lCriou	:= .F.	
		Else
			TCSqlExec("DROP SEQUENCE LINHA"+cNmTmpTb)
			cCriaSeq	:=	"CREATE SEQUENCE LINHA"+cNmTmpTb+" START WITH 1  INCREMENT BY 1"+CRLF  
	
			_RetExec = TcSQLExec(cCriaSeq)
			
			if _RetExec < 0 
				_RetExec = TCSQLERROR()
				MSGALERT(AllTrim(_RetExec),"N„o foi possÌvel criar a sequÍncia, a rotina n„o continuar· sendo executada!")
				lCriou	:= .F.
			EndIf
			
		EndIf 
	
	Else

		TCSqlExec("DROP SEQUENCE LINHA"+cNmTmpTb)
		TCSqlExec("CREATE SEQUENCE LINHA"+cNmTmpTb+" START WITH 1  INCREMENT BY 1")
	//	Aviso("EXISTENTE - CriaÁ„o de Tabela intermedi·ria", 'Tabela intermedi·ria n„o foi criada novamente, pois j· consta na base.('+cNmTmpTb+')', {'OK'},3)
	//	lCriou	:= .F.	
				
	EndIf
			
Return lCriou

