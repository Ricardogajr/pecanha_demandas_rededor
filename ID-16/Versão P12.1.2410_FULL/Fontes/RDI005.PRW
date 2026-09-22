#include 'protheus.ch'
#include 'parmtype.ch'
#include "Fileio.ch"
#Include "TopConn.ch"


#DEFINE CRLF Chr(13)+Chr(10)
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RDI004
@type function
@author Cesar Escobar	
@since 28/08/2017
@version 1.0
@param cTab, character, (Nome da tabela que será importada)
@param cArq, character, (Caminho e nome do arquivo com extensão que será importado )
@param FS_RDI003, caracter (parametro para armazenar os dados do comando sqlldr)
@return ${cTempTab}, ${Nome da tabela criada para armazenar os dados}
/*///---------------------------------------------------------------------------------------------------------------------------

User Function RDI005(cTab, aFiles)
	
	Local lRet 		:= .T.
	Local cTempPath := U_GetTmpMigra()
	Local cSqlLdr 	:= U_GetCnxLdr()
	Local cAlsPrc   := UPPER(RIGHT(cTab,3))
	Local cNomeArq  := cAlsPrc + DToS(DDatabase) + STRTRAN(TIME(),":","") 
	Local cArqCTL   := cTempPath + cNomeArq + ".ctl"
	Local cArqBAT   := cTempPath + cNomeArq + ".bat"
	Local nHdlCTL   := 0
	Local nHdlBAT   := 0
	Local cTempTab  := ""
    Local nX        := 0
	Local cLote     := ""
	Local aResult 	:= {}
	Local nRet      := 0
	Local cDelim    := ";"
	Local nZ        := 0
	Local cArq      := "" 
	Local cSpName   := ""
	Local cFileData := ""
	Local cDataIni  := DTos(Date())
	Local cHoraIni  := Time()

	Public aCpos	:= {}
	
	If !U_fExistDir(cTempPath )
		nRet := U_fMkWrkDir(cTempPath)
		if nRet != 0
			Alert( "Não foi possível criar o diretório. Erro: " + cTempPath )
		endif
	EndIf
	
	If Empty(cSqlLdr)
	   return .F.
	Endif
	
	cSpName := "STP_RDI_" + cAlsPrc
	
	If ! TCSPExist(cSpName)
	   MsgStop(U_FormatStr('Não encontrou a procedure "{1}".',{cSpName}))
	   return .F.
	Endif
	
	cTempTab :=  cTab 
	cLote    := StrZero(GetMV('FS_RDI002'),10)
    PutMv("FS_RDI002",Val(cLote)+1)
	
	ProcRegua(Len(aFiles))
	For nZ := 1 To Len(aFiles)
	    cArq := aFiles[nZ,1]
	    aCpos	  := U_GetHeader(aFiles[nZ,6],@cDelim)
		If Empty(aCpos)
		   MsgStop("Não foi possível obter os dados do cabeçalho do arquivo! Verifique.")
		   IncProc(" ")
		   return .F.
		Endif
		
		IncProc("Executando o SqlLoader..."+CHR(13)+CHR(13)+"Arquivo: "+cArq)
		
		nHdlCTL := U_NewFile(cArqCTL, 0)
		
		If nHdlCTL >= 0
		    
		    cFileData := U_FileInCfg(aFiles[nZ,6],"\ORIGEM\"+cAlsPrc)
		    
			FWRITE( nHdlCTL, "load data" + CRLF)
            FWRITE( nHdlCTL, "infile '" + cFileData + "' " + '"str ' +  "'\r\n'" + '"' + CRLF)
            FWRITE( nHdlCTL, "badfile '" + StrTran(Upper(U_FileInCfg(cArqBAT,"\TEMP\")),".BAT",".BAD") +"'" + CRLF )
			FWRITE( nHdlCTL, "append" + CRLF)
			FWRITE( nHdlCTL, "into table " + cTempTab + CRLF)
			
			If (Asc(cDelim) == 165)
			   FWRITE( nHdlCTL, "fields terminated by x'A5'" + CRLF)
			ElseIf (Asc(cDelim) == 167)
			   FWRITE( nHdlCTL, "fields terminated by x'A7'" + CRLF)
			Else
			   FWRITE( nHdlCTL, StrTran("fields terminated by '{1}'","{1}",cDelim) + CRLF)
			   //FWRITE( nHdlCTL, "OPTIONALLY ENCLOSED BY '" + '"' + "' AND '" + '"' + "'" + CRLF)
			Endif
			
			FWRITE( nHdlCTL, "trailing nullcols" + CRLF)
			FWRITE( nHdlCTL, "(" + CRLF)
			
			For nX := 1 To Len(aCpos)	
				If ("_FILIAL" $ aCpos[nX][3]) .OR. ("_FILORIG" $ aCpos[nX][3])
						FWRITE( nHdlCTL, aCpos[nX][3] + ' "COALESCE(CASE WHEN LENGTH(RTRIM(LTRIM(:' + aCpos[nX][3] + '))) > 4 THEN :' + aCpos[nX][3] + ' ELSE (SELECT ZX_FILIALP FROM SZX010 WHERE ZX_FILIAL = ' + "' ' AND ZX_EMPFIL = :" + aCpos[nX][3] + ")END,' ')"+'",' + CRLF)
				ElseIf aCpos[nX][4] == "N"
				    //FWRITE( nHdlCTL, U_FormatStr("{1} {2}TO_NUMBER(TRANSLATE(:{1},',','.'), '9999999999999999D99999999', 'NLS_NUMERIC_CHARACTERS = ''.,'''){2},",{AllTrim(aCpos[nX][3]),CHR(34)}) + CRLF)
				    //FWRITE( nHdlCTL, U_FormatStr("{1} {2}COALESCE(TO_NUMBER(TRANSLATE(:{1},',','.'), '9999999999999999D99999999', 'NLS_NUMERIC_CHARACTERS = '',.'''),0){2},",{AllTrim(aCpos[nX][3]),CHR(34)}) + CRLF)
					FWRITE( nHdlCTL, U_FormatStr("{1} {2}COALESCE(TO_NUMBER(TRANSLATE(:{1},',','.'), '9999999999999999D99999999', 'NLS_NUMERIC_CHARACTERS = ''.,'''),0){2},",{AllTrim(aCpos[nX][3]),CHR(34)}) + CRLF)
                ElseIf aCpos[nX][4] == "D"  // 21/10/2017
					FWRITE( nHdlCTL, aCpos[nX][3] + ' "COALESCE((CASE WHEN  LENGTH(RTRIM(LTRIM(SUBSTR(:' +  aCpos[nX][3] + ',7,4)))) = 2 THEN ' + "'20' || SUBSTR(:" +  aCpos[nX][3] + ",7,2) ELSE SUBSTR(:" +  aCpos[nX][3] + ",7,4) END) " + ' || SUBSTR(:' +  aCpos[nX][3] + ',4,2) || SUBSTR(:' +  aCpos[nX][3] + ',1,2),' + "' ' " + ')",' + CRLF)	
				Else
					FWRITE( nHdlCTL, aCpos[nX][3] + ' "COALESCE(SUBSTR(:' + aCpos[nX][3] + ",1," + AllTrim(cValToChar( aCpos[nX][5])) + "), ' ')" + '",' + CRLF)
				EndIf
			Next nX
			
	        //FWRITE( nHdlCTL, 'DUPLIC "COALESCE(:DUPLIC, ' + "0" + ')",' + CRLF)
	        FWRITE( nHdlCTL, 'REGISTRO_VALIDO "COALESCE(:REGISTRO_VALIDO, ' + "' '" + ')",' + CRLF)
	        FWRITE( nHdlCTL, 'DATAHORAMIG "COALESCE(:DATAHORAMIG, ' + "' '" + ')",' + CRLF)
	        FWRITE( nHdlCTL, 'DATAHORATRF "COALESCE(:DATAHORATRF, ' + "' '" + ')",' + CRLF)
	        FWRITE( nHdlCTL, 'NUMEROLOTE "COALESCE(:NUMEROLOTE,' + "'" + cLote + "'" + ')",' + CRLF)
	        FWRITE( nHdlCTL, 'ARQUIVO "' + "'" + AllTrim(cArq) + "'" + '",' + CRLF)
	        FWRITE( nHdlCTL, 'LINHA "LINHA' + cTempTab + '.NEXTVAL"' + CRLF)
			FWRITE( nHdlCTL, ")" + CRLF)
					
			nHdlBAT := U_NewFile(cArqBAT, 0)
			If nHdlBAT >= 0
				FWRITE(nHdlBAT, "@echo off" + CRLF)
				//FWRITE(nHdlBAT, 'attrib +h "'+cArqBAT+'"' + CRLF)
				FWRITE(nHdlBAT, cSqlLdr + " CONTROL='" + U_FileInCfg(cArqCTL,"\TEMP\") +;
				               "' log='"+StrTran(Upper(U_FileInCfg(cArqBAT,"\TEMP\")),".BAT",".LOG") + "'  ERRORS=999999999 skip=1" + CRLF)
				//FWRITE(nHdlBAT, 'del /Q "'+cArqBAT+'"' + CRLF)
				FCLOSE(nHdlBAT)
			Else
				/*Aviso("Não criou o arquivo BAT")*/	
			EndIf
			
			FCLOSE(nHdlCTL)
		
		Else
			/*Aviso("Não criou o arquivo CTL")*/
			lRet := .F.
		EndIf
		
		If lRet
		    Curdir(U_GetDir(103))
			If ! U_RunBat(cArqBAT) 
				Alert("Erro no arquivo "+Chr(13)+cArqBAT+Chr(13)+"Processamento interrompido.")
                If File(cArqBAT)
                   ferase(cArqBAT)
                Endif
	            lRet := .F.
	            Exit
			EndIf
		EndIf
		
        If File(cArqBAT)
           ferase(cArqBAT)
        Endif
	Next nZ

    U_MoveRead(aFiles,cLote)
	
	if lRet
	   lRet := Before_Exec(cAlsPrc)
	Endif

	if lRet
       If ! U_SPCompile(cSpName)
          MsgStop(U_FormatStr('Não foi possível compilar a SP "{1}".',{cSpName}))
          return .F.
       Endif
       aResult := TCSpExec(cSpName, cLote, cDataIni, cHoraIni)
       lRet    := Empty(AllTrim(TcSqlError()))
       IF !lRet
           MsgStop('Erro na execução da Stored Procedure : '+chr(13)+TcSqlError())
       Endif
	Endif

    //Tenta sincronizar o campo R_E_C_N_O_ com o DBAccess
	TcRefresh(cAlsPrc)
	TcRefresh("SZ3")
	TcRefresh("SZ4")
	
	if lRet
	   lRet := After_Exec(cAlsPrc)
	Endif
	
return lRet

************************************
Static Function Before_Exec(cDestin)
************************************
   Local lRet      := .T.
   Local cFunction := "U_RDIBEx"+AllTrim(cDestin)
   
   If FindFunction(cFunction)
      lRet := &(cFunction+'()')
   Endif
   
return lRet
   
***********************************
Static Function After_Exec(cDestin)
***********************************
   Local lRet      := .T.
   Local cFunction := "U_RDIAEx"+AllTrim(cDestin)
   
   If FindFunction(cFunction)
      lRet := &(cFunction + '()')
   Endif
   
return lRet


*******************************
Static Function GetLote(cAlias)
*******************************
   Local nRet      := 1
   Local cQuery    := ""
   Local cAliasTmp := GetNextAlias()
   
   cQuery += "SELECT TO_NUMBER(MAX(COALESCE(T.LOTE,'0'))) + 1 LOTE     " + CRLF
   cQuery += "FROM ( SELECT MAX(NUMEROLOTE) LOTE FROM ARQ{1}     UNION " + CRLF
   cQuery += "       SELECT MAX(NUMEROLOTE) LOTE FROM ARQ{1}_LOG UNION " + CRLF
   cQuery += "       SELECT MAX(NUMEROLOTE) LOTE FROM ARQ{1}_RESUMO) T "
   
   cQuery := StrTran(cQuery,"{1}",cAlias)
   
   TCQUERY cQuery NEW ALIAS (cAliasTmp)
   
   If (cAliasTmp)->(!Eof())
      nRet := (cAliasTmp)->LOTE
   Endif
   
   If nRet == 0
      nRet := 1
   endif
   
   If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif
   
return nRet

