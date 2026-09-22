#include 'protheus.ch'
#include 'parmtype.ch'
#include "Fileio.ch"
#Include "TopConn.ch"

#DEFINE CRLF Chr(13)+Chr(10)

#DEFINE C_CRLF     	CHR(13) + CHR(10)
#DEFINE N_BUF_SIZE 	1024

#DEFINE SGBD_ORACLE  01
#DEFINE SGBD_MSSQL   02


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
********************************
User Function RDI004(cTab, cArq)
********************************
    Local lRet       := .F.
    Local bProc      := {|lAbort| lRet := ExecMain(cTab,cArq) }
    Private lAbort   := .F.
    Private oProcess := Nil
    
	oProcess := MsNewProcess():New( bProc,"Aguarde...", 'Importando os dados para a tabela '+RetSqlName(Alltrim(QZ1->QZ1_DESTINO))+'...', .T. )
	oProcess:Activate()

Return lRet

************************************
Static Function ExecMain(cTab, cArq)
************************************
	Local lRet 		:= .T.
	Local cTempPath := U_GetTmpMigra()
	Local cSqlLdr 	:= U_GetCnxLdr() 
	Local lExec     := .T.
	Local cOrigem   := ""
	Local nRegAct   := 0
	Local nRegTot   := 0
	Local aCposAtu  := {}
	Local cDelim    := ";"
	Local cPrefixo  := ""
	Local nSeqJump  := GETNEWPAR("MV_XMIGJMP", 10)
	Local bMove     := {||U_CopyS2T({U_FileName(cArqCTL,.F.)+".*"},U_PathRelat(cArqCTL),,.T.)}
   Local nX, nArq
   
   Private cFileData := cArq  
	Private cAliTab   := Left(AllTrim(cTab),3)
	Private aArqsTXT  := {}
	Private aStruct   := {} 
	Private cNomeArq  := cAliTab + DToS(DDatabase) + STRTRAN(TIME(),":","") 
	Private cArqCTL   := cTempPath + cNomeArq + ".ctl"
	Private cArqBAT   := cTempPath + cNomeArq + ".bat"
	Private nHdlCTL   := 0
	Private nHdlBAT   := 0
	Private cTempTab  := ""
	Private cSequence := ""
	Private aCpos	  := {}
	Private cStatLog  := "OK"
	Private cPathTXT  := Left(cFileData,RAT("\",cFileData))
    Private nLote     := GetMV('FS_RDI002')
    Private lIsFile   := .T.
	
	Private cXMigLt   := ""
   
    PutMv("FS_RDI002",++nLote)
	
	If ! U_fMkWrkDir(cTempPath)
		return .F.
	EndIf
	
	If Empty(cSqlLdr)
	   return .F.
	Endif
	
    If  UPPER(Right(cFileData,4)) == ".TXT"
        aArqsTXT := u_fDirectory(cPathTXT,RetFileName(cFileData)+".TXT") //Directory(cPathTXT)
    ElseIf U_fExistDir(cPathTXT)
        aArqsTXT := u_fDirectory(cPathTXT,Upper(Alltrim(cAliTab))+"*.TXT")
        lIsFile := .F.
    Else
        MsgStop("Sr. Usuário: "+Upper(Alltrim(cUserName))+Chr(13)+" Favor Verificar...","Pasta Não Encontrada"+Chr(13)+cPathTXT)
    EndIf
    
    If Empty(aArqsTXT)
        MsgStop("Não há arquivos para serem processados! Verifique.")
        Return .F.
    Endif

	cTempTab  := cTab //+ "W"
	cSequence := "RECNO" + cAliTab
	
	If !MsFile(cTempTab)
	   DbSelectArea(cAliTab)
	   aStruct := (cAliTab)->(DBSTRUCT())
	   FWDBCreate( cTempTab , aStruct , "TOPCONN" , .T. )
	EndIf
	
	nRegTot := U_CountReg(0,aArqsTXT)
	
	cXMigLt  := DToS(Date()) + " " + Time() + " KIT" + Strzero(nLote,7)
	
	oProcess:SetRegua1( Len(aArqsTXT) )
	oProcess:SetRegua2( nRegTot )
	
    For nArq := 1 To Len(aArqsTXT)
        If lAbort
           MsgStop("Processamento cancelado pelo usuário!")
           Exit
        Endif
        oProcess:nMeter1 := nArq - 1
        oProcess:IncRegua1(aArqsTXT[nArq,1] + ' ('+ CValToChar(nArq) +"/"+ CValToChar(Len(aArqsTXT))+')')
        oProcess:nMeter2 := oProcess:nMeter2 - 1 
        oProcess:IncRegua2(StrTran(StrTran("Registros processados {1}/{2}.","{1}",Transform(nRegAct,"@E 99,999,999")),"{2}",Transform(nRegTot,"@E 99,999,999")))  

    	 cFileData := If(lIsFile,cArq, cPathTXT + Alltrim(aArqsTXT[nArq,1]))
	    cNomeArq  :=  cAliTab + DToS(DDatabase) + STRTRAN(TIME(),":","") 
	    cArqCTL   := cTempPath + cNomeArq + ".ctl"
	    cArqBAT   := cTempPath + cNomeArq + ".bat"
	    
	    aCpos	  := U_GetHeader(cFileData,@cDelim) //SelSX3(cAliTab)
	    
	    If Empty(aCpos)
           MsgStop('Não foi possível obter o cabeçalho do arquivo!'+CRLF+cFileData)
           Exit
	    Endif
	
	    nHdlCTL := NewFile(cArqCTL,0)
	     
	    If nHdlCTL >= 0
           //FWRITE( nHdlCTL," alter session set nls_numeric_characters=',.'"+CRLF) 
           FWRITE( nHdlCTL, "load data" + CRLF)
           FWRITE( nHdlCTL, "infile '" + U_FileInCfg(cFileData,"\ORIGEM\"+cAliTab) + "' " + '"str ' +  "'\r\n'" + '"' + CRLF)
           FWRITE( nHdlCTL, "badfile '" + StrTran(Upper(U_FileInCfg(cArqBAT,"\TEMP\")),".BAT",".BAD") +"'" + CRLF )
           FWRITE( nHdlCTL, "append" + CRLF)
           FWRITE( nHdlCTL, "into table " + cTempTab + CRLF)
           FWRITE( nHdlCTL, StrTran("fields terminated by '{1}'","{1}",cDelim) + CRLF)
           //FWRITE( nHdlCTL, "OPTIONALLY ENCLOSED BY '" + '"' + "' AND '" + '"' + "'" + CRLF)
           FWRITE( nHdlCTL, "trailing nullcols" + CRLF)
           FWRITE( nHdlCTL, "(" + CRLF)
           
           cPrefixo := ""
	       For nX := 1 To Len(aCpos)
	            If ("_XMIGLT" $ aCpos[nX][3])
	               Loop
	            Endif
	            
	    		If ("_FILIAL" $ aCpos[nX][3]) .OR. ("_FILORIG" $ aCpos[nX][3])
					FWRITE( nHdlCTL, aCpos[nX][3] + ' "COALESCE(CASE WHEN LENGTH(RTRIM(LTRIM(:' + aCpos[nX][3] + '))) > 4 THEN :' + aCpos[nX][3] + ' ELSE (SELECT ZX_FILIALP FROM SZX010 WHERE ZX_FILIAL = ' + "' ' AND ZX_EMPFIL = :" + aCpos[nX][3] + ")END,' ')"+'",' + CRLF)
					cPrefixo := Left(aCpos[nX][3],AT("_",aCpos[nX][3]))
	    		ElseIf aCpos[nX][4] == "N"
				    //FWRITE( nHdlCTL, StrTran(StrTran("{1} {2}COALESCE(to_number(replace(case when (InStr(:{1},'-')>0) then substr(:{1},InStr(:{1},'-')) else :{1} end,'.',',')),0){2},","{2}",'"'),"{1}",AllTrim(aCpos[nX][3])) + CRLF)
				    //FWRITE( nHdlCTL, U_FormatStr("{1} {2}TO_NUMBER(:{1}, '9999999999999999D99999999', 'NLS_NUMERIC_CHARACTERS = ''.,'''){2},",{AllTrim(aCpos[nX][3]),CHR(34)}) + CRLF)
                //If aCpos[nX][6] > 0
                 // cMascara := Replicate('9',((aCpos[nX][5])-(aCpos[nX][6])-1))+'D'+replicate('9', (aCpos[nX][6]))
                   cMascara := "9999999999999999D99999999"
                                                                
         			// FWRITE( nHdlCTL, U_FormatStr("{1} {2}(TO_NUMBER(NVL(TRANSLATE(:{1},'.',','),0), '"+cMascara+"', 'NLS_NUMERIC_CHARACTERS = '',.''')){2},",{AllTrim(aCpos[nX][3]),CHR(34)}) + CRLF)
                   FWRITE( nHdlCTL, U_FormatStr("{1} {2}(TO_NUMBER(NVL(TRANSLATE(:{1},',','.'),0), '"+cMascara+"', 'NLS_NUMERIC_CHARACTERS = ''.,''')){2},",{AllTrim(aCpos[nX][3]),CHR(34)}) + CRLF)
                   //FWRITE( nHdlCTL, U_FormatStr("{1} {2}TO_NUMBER(TRANSLATE(:{1},',','.'), '9999999999999999D99999999', 'NLS_NUMERIC_CHARACTERS = ''.,'''){2},",{AllTrim(aCpos[nX][3]),CHR(34)}) + CRLF)
                //Else
               //    cMascara := Replicate('9',aCpos[nX][5])
               //    FWRITE( nHdlCTL, U_FormatStr("{1} {2}(TO_NUMBER(NVL(TRANSLATE(:{1},'.',','),''))){2},",{AllTrim(aCpos[nX][3]),CHR(34)}) + CRLF)
               //EndIf
            ElseIf   aCpos[nX][4] == "M"
                //FWRITE( nHdlCTL, aCpos[nX][3] + ' "COALESCE(UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR('+ aCpos[nX][3] +', 4000,1)) ",' + CRLF)
	    		Else
	    		    cOrigem := GetOrigem(aCpos[nX][3])
	    		    If ! Empty(cOrigem)
	    			   FWRITE( nHdlCTL, aCpos[nX][3] + ' "COALESCE('+cOrigem+", ' ')" + '",' + CRLF)
	    		    Else
  			           FWRITE( nHdlCTL, aCpos[nX][3] + ' "COALESCE(SUBSTR(:' + aCpos[nX][3] + ",1," + AllTrim(cValToChar( aCpos[nX][5])) + "), ' ')" + '",' + CRLF)
	    			Endif
	    		EndIf
	        Next
	    	
	    	If ! Empty( TamSx3(cPrefixo + "XMIGLT") ) // .And. ( AScan(aCpos, {|c| c[3] == cPrefixo + "XMIGLT" }) == 0 )
               FWRITE( nHdlCTL, cPrefixo + 'XMIGLT "' + "'" + cXMigLt + "'" + '",' + CRLF)
	    	Endif
	    	
	    	FWRITE( nHdlCTL, 'R_E_C_N_O_ "' + cSequence + '.NEXTVAL"' + CRLF)
	    	//FWRITE( nHdlCTL, 'R_E_C_N_O_ sequence(max)' + CRLF)
	    	FWRITE( nHdlCTL, ")" + CRLF)
	    			
	    	nHdlBAT := NewFile(cArqBAT, 0)
	    	If nHdlBAT >= 0
				FWRITE(nHdlBAT, "@echo off" + CRLF)
            //FWRITE(nHdlBAT,'NLS_LANG=AMERICAN_AMERICA.WE8MSWIN1252' + CRLF)
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
	       if ! U_CreateSeq(cSequence,cAliTab,.F.,(U_CountReg(nArq,aArqsTXT)+nSeqJump)-1) //nRegTot - 1, pois CreateSeq já incrementa MAX(R_E_C_N_O_)+1...
	          Return .F.
	       Endif
           
	       if lRet
	          lRet := Before_Exec(cTempTab)
	       Endif
           
           If lRet .And. (lRet := Exec(nArq))
              nRegAct += U_CountReg(nArq,aArqsTXT)
              oProcess:nMeter2 := nRegAct-1
              oProcess:IncRegua2(StrTran(StrTran("Registros processados {1}/{2}.","{1}",Transform(nRegAct,"@E 99,999,999")),"{2}",Transform(nRegTot,"@E 99,999,999")))  
           Endif
           
           //Tenta sincronizar o campo R_E_C_N_O_ com o DBAccess
           TcRefresh(cAliTab)
           
	       if lRet
	          lRet := After_Exec(cTempTab)
	       Endif
           
	    EndIf
	    
	    U_RDIIF001(bMove,"Aguarde...","Copiando os arquivos resultantes...")
	    
	    ProcessMessages()
	Next  
return lRet

**************************
Static Function Exec(nTxt)
**************************
   Local lRet      := .T.
   Local nTotLinha := aArqsTXT[nTxt,Len(aArqsTXT[nTxt])]  
   Local cBadFile  := StrTran(UPPER(cArqBAT),".BAT",".BAD")
   Local nTotSave  := nTotLinha

   RecLock("QZ3",.t.)
            QZ3->QZ3_UKEY    := Upper(Alltrim(cAliTAB))+"-"+FWTimeStamp(3,dDatabase,Time())+FWTimeStamp(4,dDatabase,Time())
            QZ3->QZ3_NUMLOT  := Strzero(nLote,10)
            QZ3->QZ3_CODPRC  := QZ1->QZ1_CODIGO
            QZ3->QZ3_CODTAB  := Upper(Alltrim(cAliTab))
            QZ3->QZ3_DATAIN  := dDataBase
            QZ3->QZ3_HORAIN  := time()
            QZ3->QZ3_FRONT   := Upper(Subs(Alltrim(aArqsTXT[nTXT,1]),At("_",Alltrim(aArqsTXT[nTXT,1]))+1,At("_",Subs(Alltrim(aArqsTXT[nTXT,1]),At("_",Alltrim(aArqsTXT[nTXT,1]))+1))-1))
            QZ3->QZ3_ARQUIV  := Upper(Alltrim(aArqsTXT[nTXT,1]))
            QZ3->QZ3_DATATX  := aArqsTXT[nTXT,3]
            QZ3->QZ3_HORATX  := aArqsTXT[nTXT,4]
            QZ3->QZ3_CODUSE  := Alltrim(cUserName)
            QZ3->QZ3_AMBIEN  := Alltrim(GetEnvServer())
            QZ3->QZ3_TIMSTA  := FWTimeStamp(2,Date(),Time())
            QZ3->QZ3_VALIDA  := "S"
            QZ3->QZ3_MAXREC  := U_GetMaxRecno( Upper(Alltrim(cAliTab)) )
            
            If ( QZ3->(FieldPos("QZ3_XMIGLT")) > 0 )
               QZ3->QZ3_XMIGLT := cXMigLt
            Endif
   QZ3->(MsUnLock())
   
   Curdir(U_GetDir(103))
   
   lRet := U_RunBat(cArqBAT)
   
   If File(cArqBAT)
      ferase(cArqBAT)
   Endif
   
   If File(cBadFile)
      nTotSave := (nTotLinha - GetLastRec(cBadFile))      
   Endif
   
   RecLock("QZ3",.f.)
            QZ3->QZ3_TOTLIN  := nTotLinha
            QZ3->QZ3_TOTGRA  := nTotSave
            QZ3->QZ3_DATAFI  := Date()
            QZ3->QZ3_HORAFI  := Time()
            QZ3->QZ3_STATLOG := If(nTotLinha == nTotSave,"OK","LOG")
   QZ3->(MsUnLock())
   
   U_MoveRead(aArqsTXT,Strzero(nLote,10))
   
   ProcessMessages()
   
Return lRet


Static Function SelSX3(cTabAtu)
		
	Local aAreaSX3	:= SX3->(GetArea())
	Local aRetCpos	:= {}
	Local aSE1Brw := FWSX3Util():GetAllFields(cTabAtu , .F. )
   Local nx
		
   For nx:=1 To Len(aSE1Brw)
      cCampo:= AllTrim(aSE1Brw[nX])
      If GetSx3Cache( cCampo ,"X3_CONTEXT") <> "V"
         aAdd(aRetCpos,{GetSx3Cache( cCampo ,"X3_ARQUIVO"),;
                        GetSx3Cache( cCampo ,"X3_ORDEM"),;
                        GetSx3Cache( cCampo ,"X3_CAMPO"),;
                        GetSx3Cache( cCampo ,"X3_TIPO"),;
                        GetSx3Cache( cCampo ,"X3_TAMANHO"),;
                        GetSx3Cache( cCampo ,"X3_DECIMAL"),;
                        GetSx3Cache( cCampo ,"X3_TITULO"),;
                        GetSx3Cache( cCampo ,"X3_VALID"),;
                        GetSx3Cache( cCampo ,"X3_RELACAO"),;
                        GetSx3Cache( cCampo ,"X3_CONTEXT"),;
                        GetSx3Cache( cCampo ,"X3_OBRIGAT")})
      EndIf
   Next
	
	RestArea(aAreaSX3)
	
Return aRetCpos

***********************************
Static Function ExistSeq(cSequence)
***********************************
   Local cAlias := GetNextAlias()
   Local cQuery := "SELECT 1 FROM user_sequences WHERE sequence_name = '{1}'"
   Local lRet   := .F.
   
   cQuery := StrTran(cQuery,"{1}",cSequence)
   
   TCQUERY cQuery NEW ALIAS (cAlias)
   
   lRet := (cAlias)->(!Eof())
   
   If Select(cAlias) > 0   ; (cAlias)->(DbCloseArea()) ; Endif
   
Return lRet

*******************************************************
User Function CreateSeq(cSequence,cAlias,lDesc,nJump)
*******************************************************
   Local lRet   := .T.
   Local nStart := 1
   
   Default cAlias := ""
   Default lDesc  := .F.
   Default nJump  := 0
   
   If ExistSeq(cSequence)
      lRet := (TCSqlExec("DROP SEQUENCE " + cSequence)  >= 0)
   Endif
   
   If lRet
      If ! Empty(cAlias)
         nStart := GetNextRecno(cAlias) 
      Endif
      If lDesc
         lRet   := (TCSqlExec("CREATE SEQUENCE " + cSequence + " NOCACHE MINVALUE "+cValToChar(nStart)+" MAXVALUE "+cValToChar(nStart+nJump)+" START WITH "+cValToChar(nStart+nJump)+" INCREMENT BY -1") >= 0)
      Else
         lRet   := (TCSqlExec("CREATE SEQUENCE " + cSequence + " START WITH "+cValToChar(nStart+nJump)+" INCREMENT BY 1") >= 0)
      Endif
   Endif
   
   If !lRet 
      MsgStop('Não foi possível recriar a sequência "'+cSequence+'".'+CRLF+ TCSQLError())
   Endif
   
Return lRet
	
*************************************
Static Function GetLastRec(cFileName)
*************************************
	Local nRet    := 0
	Local nHandle := U_OpenFile(cFileName,FO_READ + FO_SHARED)
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


**********************************************
User Function fDirectory(cPath,cMask,lCount)
**********************************************
   Local aRet   := Directory(cPath + cMask)
   Local bExec  := {|| Aeval(aRet,{|x| ASize(x,Len(x)+2), x[Len(x)-1] := cPath + AllTrim(x[1]), x[Len(x)] := If(lCount,(GetLastRec( x[Len(x)-1] )-1),0) }) }
   
   Default lCount := .T.

   MsgRun('Obtendo informações do(s) arquivo(s)...',"Aguarde...",bExec)   

Return aRet   
   
***********************************   
Static Function GetOrigem(cCpoDest)
***********************************   
   Local cAlias := GetNextAlias()
   Local cRet   := ""
   Local cQuery := "SELECT TRIM(QZ2.QZ2_CPOORI) ORIGEM FROM "+RetSqlName("QZ2")+;
                   " QZ2 WHERE ROWNUM=1 AND QZ2.QZ2_CODEXT='"+QZ1->QZ1_CODIGO+"' AND QZ2.QZ2_CPODES='{1}' AND QZ2.D_E_L_E_T_=' ' AND QZ2.QZ2_CPODES<>QZ2.QZ2_CPOORI"
   
   cQuery := StrTran(cQuery,"{1}",cCpoDest)
   
   TCQUERY cQuery NEW ALIAS (cAlias)
   If (cAlias)->(!Eof())
      cRet := AllTrim((cAlias)->ORIGEM)
   Endif
   
   If Select(cAlias) > 0   ; (cAlias)->(DbCloseArea()) ; Endif
Return cRet

*************************************
User Function CountReg(nIdx,aFiles)
*************************************
    Local nRet := 0
    
    Default nIdx := 0
     
    If (nIdx > 0)
       nRet := aFiles[nIdx,Len(aFiles[nIdx])]
    Else 
       AEval(aFiles,{|x| nRet += x[Len(x)]})
    Endif 
    
Return nRet

*******************************************
User Function GetHeader(cFileName,cDelim)
*******************************************
	Local aRet      := {}
	Local aAux      := {}
	Local nX        := 0
    Local nHandle   := U_OpenFile(cFileName,FO_READ + FO_SHARED)
	Local nBuffer   := 1024
	Local cEOL      := CRLF
	Local cRow      := ""
	Local cRead     := Space(nBuffer)
	Local nReturn   := 0
	Local nPosEol   := 0
	Local nSize     := 0 //ALTERADO POR THIAGO GÓES EM 28/07/2020
	Local aAreaSX3  := SX3->(GetArea())
	Local cDelimHdr := ";"
	Local lValid    := .T.

	Default cDelim  := ";"  

    If ( nHandle = -1 )
       MSgInfo("Não foi possivel abrir o arquivo "+CRLF+CRLF+cFileName)
       return .F. 
    Endif 

	fSeek(nHandle,0,0) // Posiciona no início do arquivo
   
	While (FRead(nHandle,@cRead,nBuffer) > 0) .OR. (At(cEOL,cRow) != 0)
		cRow += cRead
		cRead := Space(nBuffer)
         
		nPosEol := At(cEOL,cRow)
		If (nPosEol != 0)
			nReturn := (Len(Substr(cRow,nPosEol + Len(cEOL),Len(cRow) - nPosEol + Len(cEOL))) * -1)
			fSeek(nHandle, nReturn, FS_RELATIVE) //retorna a quantidade de bytes excedentes à CRLF.
			cRow := ExCRLF(Substr(cRow,1,nPosEol))
			Exit
		Endif
	EndDo
    fClose(nHandle)
    
    If (At(CHR(34) + CHR(165) + CHR(34),cRow) > 0)
       cDelimHdr := CHR(34) + CHR(165) + CHR(34)
       cDelim    := CHR(165)
    ElseIf (At(CHR(165),cRow) > 0)
       cDelimHdr := CHR(165)
       cDelim    := CHR(165)
    ElseIf (At(CHR(167),cRow) > 0)
       cDelimHdr := CHR(167)
       cDelim    := CHR(167)
    Endif
   
	aAux := StrTokArr(StrTran(cRow,chr(32),""),cDelimHdr)

	If Empty(aAux)
		MsgStop('O arquivo está vazio! Verifique')
		Return {}
	Endif

   nSize := 10
   
   dbSelectArea('SX3')
	SX3->(dbSetOrder(2))
   
	For nX := 1 To Len(aAux)
		If ! SX3->(dbSeek(PadR( aAux[nX], nSize )) ) .OR. ( GetSx3Cache( aAux[nX] ,"X3_CONTEXT") == "V" ) 
		   MsgStop('Campo "'+Alltrim(aAux[nX])+'" Não Encontrado no Dicionário Protheus!'+CRLF+CRLF+"AÇÃO: Retire este da origem ou crie-o no dicionário.")
		   lValid := .F.
		   Loop
		Endif
		aAdd(aRet,{GetSx3Cache( aAux[nX] ,"X3_ARQUIVO"),;
                 GetSx3Cache( aAux[nX] ,"X3_ORDEM"),;
                 GetSx3Cache( aAux[nX] ,"X3_CAMPO"),;
                 GetSx3Cache( aAux[nX] ,"X3_TIPO"),;
                 GetSx3Cache( aAux[nX] ,"X3_TAMANHO"),;
                 GetSx3Cache( aAux[nX] ,"X3_DECIMAL"),;
                 GetSx3Cache( aAux[nX] ,"X3_TITULO"),;
					  GetSx3Cache( aAux[nX] ,"X3_VALID"),;
                 GetSx3Cache( aAux[nX] ,"X3_RELACAO"),;
                 GetSx3Cache( aAux[nX] ,"X3_CONTEXT"),;
                 GetSx3Cache( aAux[nX] ,"X3_OBRIGAT")})
	Next 
	RestArea(aAreaSX3)
	
	AEval(aRet,{|x| x[3] := AllTrim(x[3]) })
	
	If ! lValid
	   aRet := {}
	Endif
	
Return aRet

***************************
Static Function ExCRLF(c,b)
***************************
	Local cRet := c
	Local nX   := 1
   
	Default b := CRLF
   
	For nX := 1 To Len(b)
		cRet := StrTran(cRet,Substr(b,nX,1),"")
	Next nX
   
Return cRet

************************************
Static Function fFileNoEx(cFileName)
************************************
   Local cRet    := cFileName
   Local nPosIni := RAT("\",cRet)+1
   Local nPosFin := (RAT(".",cRet) - nPosIni)
   
   nPosIni := If(nPosIni == 0,1        ,nPosIni)
   nPosFin := If(nPosFin == 0,Len(cRet),nPosFin)

   cRet := Substr(cRet,nPosIni,nPosFin)
   
return cRet
 

************************************
Static Function FilePath(cFileName)
************************************
   Local cRet    := cFileName
   Local nPosFin := RAT("\",cRet)

   cRet := Substr(cRet,1,nPosFin)
   
return cRet
 
************************************
Static Function GetNextRecno(cAlias)
************************************
   Local cTable    := RetSqlName(cAlias)
   Local nRet      := 1
   Local cQuery    := "SELECT MAX(R_E_C_N_O_)+1 RECNO FROM "+cTable
   Local cAliasTmp := GetNextAlias()
   
   TCQUERY cQuery NEW ALIAS (cAliasTmp)
   
   If (cAliasTmp)->(!Eof())
      nRet := (cAliasTmp)->RECNO
   Endif
   
   If nRet == 0
      nRet := 1
   endif
   
   If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif
   
return nRet

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
      lRet := &(cFunction+'()')
   Endif
   
return lRet
   

***********************************
User Function GetMaxRecno(cAlias)
***********************************
   Local cTable    := RetSqlName(cAlias)
   Local nRet      := 1
   Local cQuery    := "SELECT MAX(R_E_C_N_O_) RECNO FROM "+cTable
   Local cAliasTmp := GetNextAlias()

   If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif
   
   TCQUERY cQuery NEW ALIAS (cAliasTmp)
   
   If (cAliasTmp)->(!Eof())
      nRet := (cAliasTmp)->RECNO
   Endif
   
   If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif
   
return nRet

****************************************   
Static Function NewFile(cFileName,nMode)
****************************************
   Local nRet := 0
   
   Default nMode := 0
   
   cFileName := U_PathRelat(cFileName,,.F.)
   nRet      := FCreate(cFileName,nMode)
   
Return nRet   
