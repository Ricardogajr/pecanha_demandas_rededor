#include 'protheus.ch'
#include 'parmtype.ch'
#include "Fileio.ch"

#DEFINE CRLF Chr(13)+Chr(10)

//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RDI004
@type function
@author Cesar Escobar	
@since 28/08/2017
@version 1.0
@param cTab, character, (Nome da tabela que serï¿½ importada)
@param cArq, character, (Caminho e nome do arquivo com extensï¿½o que serï¿½ importado )
@param FS_RDI003, caracter (parametro para armazenar os dados do comando sqlldr)
@return ${cTempTab}, ${Nome da tabela criada para armazenar os dados}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function RDI006(cTab, cArq)
	
	Local lRet 		:= .T.
	Local cTempPath := U_GetTmpMigra()
	Local cSqlLdr 	:= U_GetCnxLdr()
	Local cAliTab 	:= cTab
	Local cNomeArq  :=  cAliTab + DToS(DDatabase) + STRTRAN(TIME(),":","") 
	Local cArqCTL   := cTempPath + cNomeArq + ".ctl"
	Local cArqBAT   := cTempPath + cNomeArq + ".bat"
	Local nHdlCTL   := 0
	Local nHdlBAT   := 0
	Local cTempTab  := ""
	Local cSequence := ""
	Local cQry      := ""
    Local nRetQry   := 0
	Local bMove     := {||U_CopyS2T({U_FileName(cArqCTL,.F.)+".*"},U_PathRelat(cArqCTL),,.T.)}
	
	If !U_fExistDir(cTempPath )
		U_fMkWrkDir(cTempPath)
	EndIf
	
	If Empty(cSqlLdr)
	   return .F.
	Endif

	//cAliTab := Substr(cTab,1,3)

	DbSelectArea(cAliTab)
	
	cTempTab := "Z" + cTab 
	cSequence := "RECNO" + cAliTab
	
	cQry := "CREATE TABLE " + cTempTab
	cQry += " (LINHAO VARCHAR2(4000 BYTE),NUMLINHA NUMBER(10))"
	
	If MsFile(cTempTab)
	   TCSqlExec("DROP TABLE " + cTempTab)
	EndIf
	
    nRetQry := TCSqlExec(cQry)

    cMSGerr := tcsqlerror()
    
    If (nRetQry < 0)
       MsgStop("Erro durante a criação da tabela temporária!"+CRLF+cMSGerr)
       return ""
    Endif
	
	TCSqlExec("DROP SEQUENCE " + cSequence)
	TCSqlExec("CREATE SEQUENCE " + cSequence + " START WITH 0 INCREMENT BY 1 MINVALUE 0")
	
	nHdlCTL := U_NewFile(cArqCTL, 0)
	
	If nHdlCTL >= 0
		FWRITE( nHdlCTL, "load data" + CRLF)
        FWRITE( nHdlCTL, "infile '" + U_FileInCfg(cArq,"\ORIGEM\"+cTab) + "' " + '"str ' +  "'\r\n'" + '"' + CRLF)
        FWRITE( nHdlCTL, "badfile '" + StrTran(Upper(U_FileInCfg(cArqBAT,"\TEMP\")),".BAT",".BAD") +"'" + CRLF )
		FWRITE( nHdlCTL, "append" + CRLF)
		FWRITE( nHdlCTL, "into table " + cTempTab + CRLF)
		FWRITE( nHdlCTL, "fields terminated by '\r\n'" + CRLF)
		FWRITE( nHdlCTL, "trailing nullcols" + CRLF)
		FWRITE( nHdlCTL, "(" + CRLF)
		FWRITE( nHdlCTL, "LINHAO CHAR(4000)," + CRLF)
		FWRITE( nHdlCTL, 'NUMLINHA "' + cSequence + '.NEXTVAL"' + CRLF)
		FWRITE( nHdlCTL, ")" + CRLF)
				
		nHdlBAT := U_NewFile(cArqBAT, 0)
		If nHdlBAT >= 0
		   FWRITE(nHdlBAT, "@echo off" + CRLF)
		   //FWRITE(nHdlBAT, 'attrib +h "'+cArqBAT+'"' + CRLF)
           FWRITE(nHdlBAT, cSqlLdr + " CONTROL='" + U_FileInCfg(cArqCTL,"\TEMP\") +;
				           "' log='"+StrTran(Upper(U_FileInCfg(cArqBAT,"\TEMP\")),".BAT",".LOG") + "'  ERRORS=999999999" + CRLF)
		   
		   //FWRITE(nHdlBAT, 'del /Q "'+cArqBAT+'"' + CRLF)
		   FCLOSE(nHdlBAT)
		Else
			/*Aviso("Nï¿½o criou o arquivo BAT")*/	
		EndIf
		
		FCLOSE(nHdlCTL)
	
	Else
		/*Aviso("Nï¿½o criou o arquivo CTL")*/
		lRet := .F.
	EndIf
	
	If lRet
	    Curdir(U_GetDir(103))
		If U_RunBat(cArqBAT)
		   lRet := Before_Exec(Right(cTempTab,3))
		   If ! lRet
		      cTempTab := ""
		   Endif
		EndIf 
	EndIf
	
    If File(cArqBAT)
       ferase(cArqBAT)
    Endif
    
	U_RDIIF001(bMove,"Aguarde...","Copiando os arquivos resultantes...")
	
return cTempTab

*********************************
Static Function SetDelim(cTabTmp)
*********************************
   Local cCmd1 := "UPDATE {1} SET LINHAO = REPLACE(LINHAO,';',',') WHERE ( INSTR(LINHAO,CHR(165)) > 0) AND ( INSTR(LINHAO,';') > 0)"
   Local cCmd2 := "UPDATE {1} SET LINHAO = REPLACE(REPLACE(LINHAO,CHR(34)||CHR(165)||CHR(34),';'),CHR(34),'') WHERE ( INSTR(LINHAO,CHR(165)) > 0)"
   Local cCmd3 := "UPDATE {1} SET LINHAO = REPLACE(LINHAO,CHR(165),';') WHERE ( INSTR(LINHAO,CHR(165)) > 0)"
   
   cCmd1 := StrTran(cCmd1,"{1}",cTabTmp)
   cCmd2 := StrTran(cCmd2,"{1}",cTabTmp)
   cCmd3 := StrTran(cCmd3,"{1}",cTabTmp)
   
   If TcSqlExec(cCmd1) < 0
      MsgAlert("Erro na Construção da sentença sql (cmd1): " + CHR(13) + TCSqlError())
      Return .F.
   Endif
   
   If TcSqlExec(cCmd2) < 0
      MsgAlert("Erro na Construção da sentença sql (cmd2): " + CHR(13) + TCSqlError())
      Return .F.
   Endif     

   If TcSqlExec(cCmd3) < 0
      MsgAlert("Erro na Construção da sentença sql (cmd3): " + CHR(13) + TCSqlError())
      Return .F.
   Endif     
        
Return .T.     
   
************************************   
Static Function Before_Exec(cDestin)
************************************
   Local lRet      := .T.
   Local cFunction := "U_RDIBEx"+AllTrim(cDestin)
   
   If FindFunction(cFunction)
      lRet := &(cFunction + StrTran('("{1}")',"{1}",cDestin) )
   Endif
   
return lRet
   
***********************************
Static Function After_Exec(cDestin)
***********************************
   Local lRet      := .T.
   Local cFunction := "U_RDIAEx"+AllTrim(cDestin)
   
   If FindFunction(cFunction)
      lRet := &(cFunction+'()')
   Endif
   
return lRet
   