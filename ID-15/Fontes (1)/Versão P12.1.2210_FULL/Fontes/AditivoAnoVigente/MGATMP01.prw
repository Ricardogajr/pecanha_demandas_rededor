#Include 'Protheus.ch'
#INCLUDE "FILEIO.CH"

Static aCposAtu	:= {} 
Static cCodZVJ	:= ''
Static cTabZVJ	:= '' 
Static cPath	:= ''
Static lNMenu	:= .F.
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MGATMP01
@type function
@author Cesar Escobar 
@since 04/09/2017
@version 1.0
@param cCdCdZVJ, caracter, (Codigo da tabela do importador)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function MGATMP01(cCdCdZVJ)
     
    Private lAutoExec  := (Type("__lPackage") == "L" .And. __lPackage)

	Processa( {|| fProcessa(cCdCdZVJ) }, "Aguarde...", "Iniciando a importaÁ„o...",.F.)
Return
	
Static Function fProcessa(cCdCdZVJ)	
	Local cCposTMP	:= ''
	Local aAreaAtu	:= FWGetArea()
	Local cNmTmpTb	:= ""
	Local nX		:= 0
	Default	cCdCdZVJ:= ''
		
		lNMenu	:= Isblind()
		
		if !lNMenu
		
			if !lAutoExec .AND. !MsgYesNo('Deseja continuar a importaÁ„o?')
				
				RestArea(aAreaAtu)
				Return
			
			Else
				cCodZVJ	:= ZVJ->ZVJ_CODIGO
				cTabZVJ	:= ALLTRIM(ZVJ->ZVJ_DESTIN) 
				cPath   := Left(AllTrim(ZVJ->ZVJ_DIRIMP),RAT("\",AllTrim(ZVJ->ZVJ_DIRIMP))) 	
			EndIf
		
		Elseif lNMenu .AND. Empty(cCdCdZVJ)
		
			Conout('MGATMP00: Codigo do cadastro n„o informado!')
			RestArea(aAreaAtu)
			Return
		
		Elseif lNMenu .AND. Empty(cCdCdZVJ)
		
			dbSelectArea("ZVJ")
			ZVJ->(dbSetOrder(1))
			if ZVJ->(dbSeek(xFilial("ZVJ")+cCdCdZVJ))
				cCodZVJ	:= ZVJ->ZVJ_CODIGO
				cTabZVJ	:= ALLTRIM(ZVJ->ZVJ_DESTIN) 
				cPath   := Left(AllTrim(ZVJ->ZVJ_DIRIMP),RAT("\",AllTrim(ZVJ->ZVJ_DIRIMP))) 	
			EndIf
			
		EndIf

		IncProc("Carregando os campos para validaÁ„o")
		//Carrega os campos da ZVK
		CarreZVK(cCodZVJ,@aCposAtu)
		
		IncProc("Montando os campos para validaÁ„o")
		//Monta campos para criar tabela intermedi·ria
		MntCpTMP(@cCposTMP)
		
		cNmTmpTb := Alltrim(SuperGetMV('ES_PRFTBMG',,'ARQ'))+cTabZVJ
		//Cria tabelas para importar dados do arquivo e quebrar processamentos
		IncProc("Criando a tabela tempor·ria")
		If CriaTMP(cCposTMP,lNMenu,cNmTmpTb)
                       
           aArqsTXT := fDirectory(cPath,Upper(Alltrim(cTabZVJ))+"*.TXT")
           
           If Empty(aArqsTXT)
               MsgStop("N„o h· arquivos para serem processados! Verifique.")
               Return
           Endif
           
           If U_ImpTab3(cNmTmpTb,  aArqsTXT )
              If !lAutoExec
                 MsgInfo("Processamento concluÌdo com sucesso!")
              Endif
           Else
              MsgStop("Erro durante o processamento! Verifique.")
           EndIf
		
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
Static Function CarreZVK(cCodAtu,aCpos)

	Local aArea		:= FWGetArea()
	Local aAreaZVK	:= ZVK->(FWGetArea())

		dbSelectArea('ZVK')
		ZVK->(dbSetOrder(1))
		if ZVK->(dbSeek(xFilial('ZVK')+cCodAtu))
		
			While xFilial('ZVK')+cCodAtu == ZVK->ZVK_FILIAL+ZVK->ZVK_CODEXT

				aAdd(aCpos,{ZVK->ZVK_CPODES,ZVK->ZVK_REJEIT,ZVK->ZVK_TIPDES,ZVK->ZVK_TAMDES})
				
				ZVK->(dbSkip())
				
			EndDo
			
		EndIf
		
	RestArea(aArea)
	RestArea(aAreaZVK)
	
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
		
		cCposTMP	+= ",Duplic varchar(26) DEFAULT ' ' NULL "+CRLF
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
	If !MsFile(cNmTmpTb)

		//Cria a tabela que conter„ as linhas			
		cCriaTMP	:=	"	CREATE TABLE "+cNmTmpTb+" ( "+CRLF
		cCriaTMP	+=	"	"+cCposTMP+CRLF
		cCriaTMP	+=	"	)"+CRLF	
			
		_RetExec:=  TcSQLExec(cCriaTMP)
	
		If _RetExec < 0 

			_RetExec = TCSQLERROR()
			MsgAlert(AllTrim(_RetExec),"N„o foi possÌvel criar a tabela, a rotina n„o continuar· sendo executada!")
			lCriou	:= .F.	
		Else
			TCSqlExec("DROP SEQUENCE LINHA"+cNmTmpTb)
			cCriaSeq	:=	"CREATE SEQUENCE LINHA"+cNmTmpTb+" START WITH 1  INCREMENT BY 1"+CRLF  
	
			_RetExec = TcSQLExec(cCriaSeq)
			
			if _RetExec < 0 
				_RetExec = TCSQLERROR()
				MsgAlert(AllTrim(_RetExec),"N„o foi possÌvel criar a sequÍncia, a rotina n„o continuar· sendo executada!")
				lCriou	:= .F.
			EndIf
			
		EndIf 
	
	Else

		TCSqlExec("DROP SEQUENCE LINHA"+cNmTmpTb)
		TCSqlExec("CREATE SEQUENCE LINHA"+cNmTmpTb+" START WITH 1  INCREMENT BY 1")
				
	EndIf
			
Return lCriou

**********************************************
Static Function fDirectory(cPath,cMask,lCount)
**********************************************
   Local cServer:= Alltrim(SuperGetMV('MV_XIMPIP',,''))
   Local aRet   := Directory(cPath + cMask)
   Local bExec  := {|| Aeval(aRet,{|x| ASize(x,Len(x)+2), x[Len(x)-1] := cPath + AllTrim(x[1]), x[Len(x)] := If(lCount,(GetLastRec( x[Len(x)-1] )-1),0) }) }
   
   Default lCount := .T.

   MsgRun('Obtendo informaÁıes do(s) arquivo(s)...',"Aguarde...",bExec)   

Return aRet   


*************************************
Static Function GetLastRec(cFileName)
*************************************
	Local nRet    := 0
	Local nHandle := FOpen(cFileName,FO_READWRITE + FO_SHARED)
	Local nBuffer := 1024
	Local cEOL    := CRLF
	Local cRow    := ""
	Local cNewRow := ""
	Local cRead   := Space(nBuffer)
	Local nPosEol := 0
	Local nSkip   := 0
    Local bErrorBlock := ErrorBlock( {|e| Alert("nRet == "+cValToChar(nRet)+" Len(cRow)== "+cValToChar(Len(cRow))) } ) 
	
	
   	If ( nHandle = -1 )
    	MSgInfo("N„o foi possivel abrir o arquivo "+CRLF+CRLF+cFileName)
      	return .F. 
   	Endif 

	fSeek(nHandle,0,0) // Posiciona no inÌcio do arquivo
   
    BEGIN SEQUENCE
   
	While (FRead(nHandle,@cRead,nBuffer) > 0) 
		cRow += cRead
		cRead := Space(nBuffer)
		nPosEol := At(cEOL,cRow)
		If (nPosEol != 0)
			nRet++
			cNewRow := Left(cRow,nPosEol - 1)
			nSkip   := Len(cRow) - (Len(cEOL) + Len(cNewRow))
			fSeek(nHandle,(nSkip * -1),FS_RELATIVE) //Volta o ponteiro para o inÌcio da prÛxima linha
			cRow    :=  ""
		Endif
	EndDo

    END SEQUENCE
    ErrorBlock(bErrorBlock)
	
    fClose(nHandle)
Return nRet
