#include 'protheus.ch'
#include 'parmtype.ch'
#include "Fileio.ch"
#Include "TopConn.ch"
 

#DEFINE CRLF Chr(13)+Chr(10)
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IMPTAB
@type function
@author Cesar Escobar	
@since 28/08/2017
@version 1.0
@param cTab, character, (Nome da tabela que será importada)
@param cArq, character, (Caminho e nome do arquivo com extensão que será importado )
@param MV_XSQLLDR, caracter (parametro para armazenar os dados do comando sqlldr)
@return ${cTempTab}, ${Nome da tabela criada para armazenar os dados}
/*///---------------------------------------------------------------------------------------------------------------------------

User Function IMPTAB3(cTab, aFiles)
	
	Local lRet 		:= .T.
	Local cIp		:= Alltrim(SuperGetMV('MV_XIMPIP',,''))
	Local cTempPath := U_GetTmpPath() + "migra\"
	Local cSqlLdr 	:= U_GetCnxLdr() //AllTrim(GetMv("MV_XSQLLDR"))
	Local cNomeArq  :=  UPPER(RIGHT(cTab,3)) + DToS(DDatabase) + STRTRAN(TIME(),":","") 
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
	Local cDataIni  := DTos(Date())
	Local cHoraIni  := Time()
	Local cSpName   := ""
	Local dDataMov  := ""
	Local cDataMov  := ""
	
	Private cAliasTab := UPPER(RIGHT(cTab,3))

	Public aCpos	:= {}
	
	If !ExistDir( cTempPath )
		nRet := MakeDir(cTempPath)
		if nRet != 0
			Alert( "Não foi possível criar o diretório. Erro: " + cTempPath )
		endif
	EndIf
	
	If Empty(cSqlLdr)
	   return .F.
	Endif
	
	cTempTab :=  cTab 
	cLote    := StrZero(GetLote(cAliasTab),15)
    PutMv("DOR_CHARGE",Val(cLote)+1)
	
	ProcRegua(Len(aFiles))
	For nZ := 1 To Len(aFiles)
	    cArq := aFiles[nZ,1]
	    aCpos	  :=StaticCall(IMPTAB,GetHeader,aFiles[nZ,6],@cDelim)
		If Empty(aCpos)
		   MsgStop("Não foi possível obter os dados do cabeçalho do arquivo! Verifique.")
		   IncProc(" ")
		   return
		Endif
		
		IncProc("Executando o SqlLoader..."+CHR(13)+CHR(13)+"Arquivo: "+cArq)
		
		nHdlCTL := FCREATE(cArqCTL, 0)
		
		If nHdlCTL >= 0
			FWRITE( nHdlCTL, "load data" + CRLF)
			FWRITE( nHdlCTL, "infile '" + cIp + aFiles[nZ,6] + "' " + '"str ' +  "'\r\n'" + '"' + CRLF)
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
                    FWRITE( nHdlCTL, StrTran(StrTran("{1} {2}COALESCE(to_number(replace(case when (InStr(:{1},'-')>0) then substr(:{1},InStr(:{1},'-')) else :{1} end,'.',',')),0){2},","{2}",'"'),"{1}",AllTrim(aCpos[nX][3])) + CRLF)
                ElseIf aCpos[nX][4] == "D"  
                    /* Roberto em 19/01/2019: alteração para permitir que campos datas possam vir nos formatos DD/MM/YYYY e YYYYMMDD:
					FWRITE( nHdlCTL, aCpos[nX][3] + ' "COALESCE((CASE WHEN  LENGTH(RTRIM(LTRIM(SUBSTR(:' +  aCpos[nX][3] + ',7,4)))) = 2 THEN ' + "'20' || SUBSTR(:" +  aCpos[nX][3] + ",7,2) ELSE SUBSTR(:" +  aCpos[nX][3] + ",7,4) END) " + ' || SUBSTR(:' +  aCpos[nX][3] + ',4,2) || SUBSTR(:' +  aCpos[nX][3] + ',1,2),' + "' ' " + ')",' + CRLF)
					*/
					FWRITE( nHdlCTL, U_FmtStr("{1} "+"{2}COALESCE( TO_CHAR( TO_DATE( LTRIM(TRIM(:{1})), DECODE(INSTR(:{1},'/'),3,'DD/MM/YYYY','YYYYMMDD') ) , 'YYYYMMDD' ),' '){2}," + CRLF,{aCpos[nX][3],CHR(34)}) )
				Else
					FWRITE( nHdlCTL, aCpos[nX][3] + ' "COALESCE(SUBSTR(:' + aCpos[nX][3] + ",1," + AllTrim(cValToChar( aCpos[nX][5])) + "), ' ')" + '",' + CRLF)
				EndIf
			Next nX
			
	        FWRITE( nHdlCTL, 'DUPLIC "COALESCE(:DUPLIC, ' + "' '" + ')",' + CRLF)
	        FWRITE( nHdlCTL, 'REGISTRO_VALIDO "COALESCE(:REGISTRO_VALIDO, ' + "' '" + ')",' + CRLF)
	        FWRITE( nHdlCTL, 'DATAHORAMIG "COALESCE(:DATAHORAMIG, ' + "' '" + ')",' + CRLF)
	        FWRITE( nHdlCTL, 'DATAHORATRF "COALESCE(:DATAHORATRF, ' + "' '" + ')",' + CRLF)
	        FWRITE( nHdlCTL, 'NUMEROLOTE "COALESCE(:NUMEROLOTE,' + "'" + cLote + "'" + ')",' + CRLF)
	        FWRITE( nHdlCTL, 'ARQUIVO "' + "'" + AllTrim(cArq) + "'" + '",' + CRLF)
	        FWRITE( nHdlCTL, 'LINHA "LINHA' + cTempTab + '.NEXTVAL"' + CRLF)
			FWRITE( nHdlCTL, ")" + CRLF)
					
			nHdlBAT := FCREATE(cArqBAT, 0)
			If nHdlBAT >= 0
				FWRITE(nHdlBAT, "@echo off" + CRLF)
				//FWRITE(nHdlBAT, 'attrib +h "'+cArqBAT+'"' + CRLF)
				FWRITE(nHdlBAT, cSqlLdr + " CONTROL=" + cArqCTL + "  ERRORS=999999999 skip=1" + CRLF)
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
			If WaitRun(cArqBAT, 1) != 0
				Alert("Erro no arquivo "+Chr(13)+cArqBAT+Chr(13)+"Processamento interrompido.")
                If File(cArqBAT)
                   //ferase(cArqBAT)
                Endif
	            lRet := .F.
	            Exit
			EndIf 
		EndIf
		
        If File(cArqBAT)
           //ferase(cArqBAT)
        Endif
	Next nZ
	
	if lRet
	   lRet := Before_Exec(cAliasTab)
	Endif
	
	if lRet
	    cSpName := "MIG_P12_" + cAliasTab
		If TCSPExist(cSpName)
		    /*
		    ** Inicia o monitoramento do R_E_C_N_O_...
		    */
		    StartJob("U_STARTMNT",GetEnvServer(),.F.,cAliasTab,cLote)
		    //U_StartMnt(cAliasTab,cLote)
		    /*
		    **
		    */
		    If ( cAliasTab == "SD3" )
		       dDataMov  := SuperGetMV("MV_ULMES",.F.,"19000101")
	           If ! Empty(dDataMov)
	              cDataMov := DTOS(dDataMov + 1)
	           Else 
	              cDataMov := "19000101"
	           Endif
			   aResult := TCSpExec(cSpName, cLote, cDataIni, cHoraIni, (cDataMov+RIGHT(GETSXENUM("SD3","D3_SEQCALC") ,6)) )
		    Else 
			   aResult := TCSpExec(cSpName, cLote, cDataIni, cHoraIni)
			Endif
			lRet := Empty(AllTrim(TcSqlError()))
			IF !lRet
		       MsgStop('Erro na execução da Stored Procedure : '+chr(13)+TcSqlError())
		    Endif
		Else
			IncProc("Não encontrou a procedure MIG_P12_" + cAliasTab )
		EndIf	
	Endif

    /*
    ** FINALIZA o monitoramento do R_E_C_N_O_...
    */
	U_FinalMnt(cAliasTab,cLote)
	
	if lRet
	   lRet := After_Exec(cAliasTab)
	Endif
	
return lRet

************************************
Static Function Before_Exec(cDestin)
************************************
   Local lRet      := .T.
   Local cFunction := "U_EBEx"+AllTrim(cDestin)
   
   If FindFunction(cFunction)
      lRet := &(cFunction+'()')
   Endif
   
return lRet
   
***********************************
Static Function After_Exec(cDestin)
***********************************
   Local lRet      := .T.
   Local cFunction := "U_EAEx"+AllTrim(cDestin)
   
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
