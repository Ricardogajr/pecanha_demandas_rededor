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
@param cTab, character, (Nome da tabela que serï¿½ importada)
@param cArq, character, (Caminho e nome do arquivo com extensï¿½o que serï¿½ importado )
@param MV_XSQLLDR, caracter (parametro para armazenar os dados do comando sqlldr)
@return ${cTempTab}, ${Nome da tabela criada para armazenar os dados}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function IMPTAB2(cTab, cArq)
	
	Local lRet 		:= .T.
	Local cIp		:= Alltrim(SuperGetMV('MV_XIMPIP',,''))
	Local cTempPath := U_GetTmpKit()
	Local cSqlLdr 	:= U_GetCnxKit() //AllTrim(GetMv("MV_XSQLLDR"))
	Local cAliTab 	:= cTab
	Local cNomeArq  := cAliTab + DToS(DDatabase) + STRTRAN(TIME(),":","") 
	Local cArqCTL   := cTempPath + cNomeArq + ".ctl"
	Local cArqBAT   := cTempPath + cNomeArq + ".bat"
	Local nHdlCTL   := 0
	Local nHdlBAT   := 0
	Local cTempTab  := ""
	Local cSequence := ""
	Local cQry      := ""
    Local nRetQry   := 0
	Private lCopyCTLOk := .F.
	
	If !ExistDir( cTempPath )
		MakeDir(cTempPath)
	EndIf
	
	If Empty(cSqlLdr)
	   return .F.
	Endif
	

	
	//cAliTab := Substr(cTab,1,3)

	DbSelectArea(cAliTab)
	
	cTempTab := "Z" + cTab 
	cSequence := "RECNO" + cAliTab
	
	//ExistSeq(cSequence)

	cQry := "CREATE TABLE " + cTempTab
	cQry += " (LINHAO VARCHAR2(4000 BYTE),NUMLINHA NUMBER(10))"
	
	If !MsFile(cTempTab)
		nRetQry := TCSqlExec(cQry)
	Else
		nRetQry := TCSqlExec("TRUNCATE TABLE " + cTempTab)
	EndIf

    cMSGerr := tcsqlerror()
    
    If (nRetQry < 0)
       MsgStop("Erro durante a criação da tabela temporária!"+CRLF+cMSGerr)
       return ""
    Endif
	
	TCSqlExec("DROP SEQUENCE " + cSequence)
	TCSqlExec("CREATE SEQUENCE " + cSequence + " START WITH 0 INCREMENT BY 1 MINVALUE 0")
	
	nHdlCTL := FCREATE(cArqCTL, 0)
	
	If nHdlCTL >= 0
		FWRITE( nHdlCTL, "load data" + CRLF)
		FWRITE( nHdlCTL, "infile '" + cIp + cArq + "' " + '"str ' +  "'\r\n'" + '"' + CRLF)
		FWRITE( nHdlCTL, "append" + CRLF)
		FWRITE( nHdlCTL, "into table " + cTempTab + CRLF)
		FWRITE( nHdlCTL, "fields terminated by '\r\n'" + CRLF)
		FWRITE( nHdlCTL, "trailing nullcols" + CRLF)
		FWRITE( nHdlCTL, "(" + CRLF)
		FWRITE( nHdlCTL, "LINHAO CHAR(4000)," + CRLF)
		FWRITE( nHdlCTL, 'NUMLINHA "' + cSequence + '.NEXTVAL"' + CRLF)
		FWRITE( nHdlCTL, ")" + CRLF)
				
		nHdlBAT := FCREATE(cArqBAT, 0)
			If nHdlBAT >= 0
				FWRITE(nHdlBAT, "cmd.exe /c chcp 1252" + CRLF)
				FWRITE(nHdlBAT, "@echo off" + CRLF)
				If __nLocalLdr == 1
				//FWRITE(nHdlBAT, 'attrib +h "'+cArqBAT+'"' + CRLF)
					FWRITE(nHdlBAT, cSqlLdr + " CONTROL=" + cArqCTL + "  ERRORS=999999999 skip=0" + CRLF)
				Else 
					cFctlLocal := U_GetDirc(300)+FileName(cArqCTL)
					FWRITE(nHdlBAT, cSqlLdr + " CONTROL=" + cFCTLLocal + "  ERRORS=999999999 skip=0" + CRLF)
				EndIf 
			//FWRITE(nHdlBAT, 'del /Q "'+cArqBAT+'"' + CRLF)
		
			FCLOSE(nHdlBAT)
			Else
			/*Aviso("Não criou o arquivo BAT")*/	
			EndIf
		
			FCLOSE(nHdlCTL)
			lCopyCTLOk := CpyS2T(cArqCTL,U_GetDirc(300))
		
		FCLOSE(nHdlCTL)
	
	Else
		/*Aviso("Nï¿½o criou o arquivo CTL")*/
		lRet := .F.
	EndIf
	
	If lRet
		If lCopyCTLOk
			lRet := U_RunBatM(cArqBAT)
		Else 
			If !(WaitRunSrv(cArqBAT, 1) != 0)
				Alert("Erro no arquivo "+Chr(13)+cArqBAT+Chr(13)+"Processamento interrompido.")
				lRet := .F.
				If File(cArqBAT)
					ferase(cArqBAT)
				Endif
				//Exit
			EndIf 
		EndIf 
	EndIf
	
    If File(cArqBAT)
       ferase(cArqBAT)
    Endif

	aArqTxt := {cArq}

	U_MoveRead(aArqsTXT,Strzero(nLote,10))

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
   Local cFunction := "U_EBEx"+AllTrim(cDestin)
   
   If FindFunction(cFunction)
      lRet := &(cFunction + StrTran('("{1}")',"{1}",cDestin) )
   Endif
   
return lRet
   
***********************************
Static Function After_Exec(cDestin)
***********************************
   Local lRet      := .T.
   Local cFunction := "U_EAEx"+AllTrim(cDestin)
   
   If FindFunction(cFunction)
      lRet := &(cFunction+'()')
   Endif
   
return lRet

	
*************************************
Static Function GetLastRec(cFileName)
*************************************
	Local nRet    := 0
	Local nHandle := FOpen(cFileName,FO_READ + FO_SHARED)
	Local nBuffer := 1024
	Local cEOL    := CRLF
	Local cRow    := ""
	Local cNewRow := ""
	Local cRead   := Space(nBuffer)
	Local nPosEol := 0
	Local nSkip   := 0
    Local bErrorBlock := ErrorBlock( {|e| Alert("nRet == "+cValToChar(nRet)+" Len(cRow)== "+cValToChar(Len(cRow))) } ) 
	
	
   	If ( nHandle = -1 )
    	MSgInfo("Não foi possivel abrir o arquivo "+CRLF+CRLF+cFileName)
      	return .F. 
   	Endif 

	fSeek(nHandle,0,0) // Posiciona no início do arquivo
   
    BEGIN SEQUENCE
   
	While (FRead(nHandle,@cRead,nBuffer) > 0) 
		cRow += cRead
		cRead := Space(nBuffer)
		nPosEol := At(cEOL,cRow)
		If (nPosEol != 0)
			nRet++
			cNewRow := Left(cRow,nPosEol - 1)
			nSkip   := Len(cRow) - (Len(cEOL) + Len(cNewRow))
			fSeek(nHandle,(nSkip * -1),FS_RELATIVE) //Volta o ponteiro para o início da próxima linha
			cRow    :=  ""
		Endif
	EndDo

    END SEQUENCE
    ErrorBlock(bErrorBlock)
	
    fClose(nHandle)
Return nRet


****************************************
Static Function FileName(cFullName,lExt)
****************************************
   Local cDrive, cDir, cArq, cExt
   Local cRet := ""
   
   Default lExt := .T.

   SplitPath( cFullName, @cDrive, @cDir, @cArq, @cExt )
   
   cRet := cArq + If(lExt,cExt,"")

Return cRet   


***********************************
Static Function ExistSeq(cSequence)
***********************************
   Local cAlias := GetNextAlias()
   Local cQuery := "SELECT SEQUENCE_NAME FROM all_sequences WHERE sequence_name = '{1}'"
   Local lRet   := .F.
   Local cSequenc := ""
   Local lStart := .F.
   
   cQuery := StrTran(cQuery,"{1}",cSequence)
   
   TCQUERY cQuery NEW ALIAS (cAlias)
   
   lRet := (cAlias)->(!Eof())

   //If lRet
   //   cSequenc := Alltrim((cAlias)->SEQUENCE_NAME)
   //   lStart := (TCSqlExec("select "+cSequenc+".nextval from dual")  >= 0)
   //Endif
   
   If Select(cAlias) > 0   ; (cAlias)->(DbCloseArea()) ; Endif

Return lRet
