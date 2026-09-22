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
********************************
User Function IMPTAB(cTab, cArq)
********************************
    Local bProc := {|lAbort| ExecMain(cTab,cArq) }
    Private lAbort := .F.
    Private oProcess := Nil
    
    Private lAutoExec  := (Type("__lPackage") == "L" .And. __lPackage)
    
    //Processa( bProc, 'Aguarde...', 'Importando os dados para a tabela '+RetSqlName(Alltrim(ZVJ->ZVJ_DESTINO))+'...' ,.T.)
    
	oProcess := MsNewProcess():New( bProc,"Aguarde...", 'Importando os dados para a tabela '+RetSqlName(Alltrim(ZVJ->ZVJ_DESTINO))+'...', .T. )
	oProcess:Activate()

Return 

************************************
Static Function ExecMain(cTab, cArq)
************************************
	Local lRet 		   := .T.
	Local cIp		   := Alltrim(SuperGetMV('MV_XIMPIP',,''))
	Local cTempPath   := U_GetTmpKit()
	Local cSqlLdr 	   := u_GetCnxKit() //AllTrim(GetMv("MV_XSQLLDR"))
	Local lExec       := .T.
	Local cOrigem     := ""
	Local nRegAct     := 0
	Local nRegTot     := 0
	Local aCposAtu    := {}
	Local cDelim      := ";"
	Local cPrefixo    := ""
	Local nSeqJump    := GETNEWPAR("MV_XMIGJMP", 10)
   Local nX
   Local nArq

	Private cXMigLt   := "" 
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
    Private nLote     := GetMV('DOR_CHARGE')
    Private lIsFile   := .T.
	Private nSGBD     := SuperGetMV('MV_XSGBD',,1)
   Private lCopyCTLOk := .F.
   Private cfCtlLocal := ""
   
   PutMv("DOR_CHARGE",++nLote)
	
	If !ExistDir( cTempPath )
		MakeDir(cTempPath)
	EndIf
	
	If Empty(cSqlLdr)
	   return .F.
	Endif
	
    If  UPPER(Right(cFileData,4)) == ".TXT"
        aArqsTXT := fDirectory(cPathTXT,RetFileName(cFileData)+".TXT") //Directory(cPathTXT)
    ElseIf ExistDir(cPathTXT)
        aArqsTXT := fDirectory(cPathTXT,Upper(Alltrim(cAliTab))+"*.TXT")
        lIsFile := .F.
    Else
        MsgStop("Sr. Usuário: "+Upper(Alltrim(cUserName))+Chr(13)+" Favor Verificar...","Pasta Não Encontrada"+Chr(13)+cPathTXT)
    EndIf
    
    If Empty(aArqsTXT)
        MsgStop("Não há arquivos para serem processados! Verifique.")
        Return
    Endif

	cTempTab  := cTab //+ "W"
	cSequence := "RECNO" + cAliTab
	
	If !MsFile(cTempTab)
	   DbSelectArea(cAliTab)
	   aStruct := (cAliTab)->(DBSTRUCT())
	   FWDBCreate( cTempTab , aStruct , "TOPCONN" , .T. )
	EndIf
	
	nRegTot := CountReg(0,aArqsTXT)
	/*
	if ! CreateSeq(cSequence,cAliTab,.T.,nRegTot-1) //nRegTot - 1, pois CreateSeq já incrementa MAX(R_E_C_N_O_)+1...
	   Return .F.
	Endif
	*/
   
   //ExistSeq(cSequence)
	
   cXMigLt  := DToS(Date()) + " " + Time() + " " + Strzero(nLote,10)
	
	oProcess:SetRegua1( Len(aArqsTXT) )
	oProcess:SetRegua2( nRegTot )
	
    /*
    ** Inicia o monitoramento do R_E_C_N_O_...
    */
    //StartJob("U_STARTMNT",GetEnvServer(),.F.,cAliTab,nLote,.T.)
	
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
	    
	    aCpos	  := GetHeader(cFileData,@cDelim) //SelSX3(cAliTab)
	    
	    If Empty(aCpos)
           MsgStop('Não foi possível obter o cabeçalho do arquivo!'+CRLF+cFileData)
           Exit
	    Endif
	
	    nHdlCTL := FCREATE(cArqCTL, 0)
	     
	    If nHdlCTL >= 0
           FWRITE( nHdlCTL, "load data" + CRLF)
           FWRITE( nHdlCTL, "infile '" + cIp + cFileData + "' " + '"str ' +  "'\r\n'" + '"' + CRLF)
           FWRITE( nHdlCTL, "badfile '" + FilePath(cArqBAT) + fFileNoEx(cArqBAT) +".BAD'" + CRLF )
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
				    FWRITE( nHdlCTL, StrTran(StrTran("{1} {2}COALESCE(to_number(replace(case when (InStr(:{1},'-')>0) then substr(:{1},InStr(:{1},'-')) else :{1} end,'.',',')),0){2},","{2}",'"'),"{1}",AllTrim(aCpos[nX][3])) + CRLF)
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
	    			
	    	nHdlBAT := FCREATE(cArqBAT, 0)
	    	If nHdlBAT >= 0
            FWRITE(nHdlBAT, "cmd.exe /c chcp 1252" + CRLF)
				FWRITE(nHdlBAT, "@echo off" + CRLF)
				If __nLocalLdr == 1
            //FWRITE(nHdlBAT, 'attrib +h "'+cArqBAT+'"' + CRLF)
				   FWRITE(nHdlBAT, cSqlLdr + " CONTROL=" + cArqCTL + "  ERRORS=999999999 skip=1" + CRLF)
            Else 
               cFctlLocal := U_GetDirc(300)+FileName(cArqCTL)
               FWRITE(nHdlBAT, cSqlLdr + " CONTROL=" + cFCTLLocal + "  ERRORS=999999999 skip=1" + CRLF)
            EndIf 
				//FWRITE(nHdlBAT, 'del /Q "'+cArqBAT+'"' + CRLF)
				FCLOSE(nHdlBAT)
	    	Else
	    		/*Aviso("Não criou o arquivo BAT")*/	
	    	EndIf
	    	
	    	FCLOSE(nHdlCTL)

         lCopyCTLOk := CpyS2T(cArqCTL,U_GetDirc(300))
      Else
	    	/*Aviso("Não criou o arquivo CTL")*/
	    	lRet := .F.
	    EndIf
	
	    If lRet
           //MsgRun(StrTran('Gravando os dados na tabela "{1}"...',"{1}",cTab),"Aguarde...",{|| lRet := Exec(nArq) })
           
	       //if ! CreateSeq(cSequence,cAliTab,.F.,(CountReg(nArq,aArqsTXT)+nSeqJump)-1) //nRegTot - 1, pois CreateSeq já incrementa MAX(R_E_C_N_O_)+1...
	       //   Return .F.
	       //Endif
           
	       if lRet
	          lRet := Before_Exec(cTempTab)
	       Endif
           
           If lRet .And. (lRet := Exec(nArq))
              nRegAct += CountReg(nArq,aArqsTXT)
              oProcess:nMeter2 := nRegAct-1
              oProcess:IncRegua2(StrTran(StrTran("Registros processados {1}/{2}.","{1}",Transform(nRegAct,"@E 99,999,999")),"{2}",Transform(nRegTot,"@E 99,999,999")))  
           Endif
           
	       if lRet
	          lRet := After_Exec(cTempTab)
	       Endif
           
	    EndIf
	    ProcessMessages()
	Next nArq
	
    /*
    ** FINALIZA o monitoramento do R_E_C_N_O_...
    */
	//U_FinalMnt(cAliTab,nLote)
	
return lRet

**************************
Static Function Exec(nTxt)
**************************
   Local lRet      := .T.
   Local nTotLinha := aArqsTXT[nTxt,Len(aArqsTXT[nTxt])]  //GetLastRec(cFileData)
   Local cBadFile  := FilePath(cArqBAT) + fFileNoEx(cArqBAT) + ".BAD"
   Local nTotSave  := nTotLinha
   Local nSZ2Rec   := 0

   RecLock("SZ2",.t.)
            SZ2->Z2_UKEY    := Upper(Alltrim(cAliTAB))+"-"+FWTimeStamp(3,dDatabase,Time())+FWTimeStamp(4,dDatabase,Time())
            SZ2->Z2_NUMLOTE := Strzero(nLote,10)
            SZ2->Z2_CODPRC  := ZVJ->ZVJ_CODIGO
            SZ2->Z2_CODTAB  := Upper(Alltrim(cAliTab))
            SZ2->Z2_DATAINI := dDataBase
            SZ2->Z2_HORAINI := time()
            SZ2->Z2_FRONT   := Upper(Subs(Alltrim(aArqsTXT[nTXT,1]),At("_",Alltrim(aArqsTXT[nTXT,1]))+1,At("_",Subs(Alltrim(aArqsTXT[nTXT,1]),At("_",Alltrim(aArqsTXT[nTXT,1]))+1))-1))
            SZ2->Z2_ARQUIVO := Upper(Alltrim(aArqsTXT[nTXT,1]))
            SZ2->Z2_DATATXT := aArqsTXT[nTXT,3]
            SZ2->Z2_HORATXT := aArqsTXT[nTXT,4]
            SZ2->Z2_CODUSER := Alltrim(cUserName)
            SZ2->Z2_AMBIENT := Alltrim(GetEnvServer())
            SZ2->Z2_TIMSTAM := FWTimeStamp(2,Date(),Time())
            SZ2->Z2_VALIDA  := "S"
            SZ2->Z2_MAXREC  := GetMaxRecno( Upper(Alltrim(cAliTab)) )
            
            If ( SZ2->(FieldPos("Z2_XMIGLT")) > 0 )
               SZ2->Z2_XMIGLT := cXMigLt
            Endif
   SZ2->(MsUnLock())
   
   nSZ2Rec := SZ2->(Recno())
   
   Do Case 
      Case nSGBD == SGBD_ORACLE
            lRet := U_RunBatM(cArqBAT)
      Case nSGBD == SGBD_MSSQL
           MsgStop("Em construção...")
      Otherwise
           MsgRun('Preparando os dados...',"Aguarde...",{|| lRet := LoadTemp(cTempTab,cFileData) })   
   EndCase
  
   
   If File(cArqBAT)
      ferase(cArqBAT)
   Endif
   
   
   If File(cBadFile)
      nTotSave := (nTotLinha - GetLastRec(cBadFile))      
   Endif

   SZ2->(DbGoTo(nSZ2Rec))   
   RecLock("SZ2",.f.)
            SZ2->Z2_TOTLINH := nTotLinha
            SZ2->Z2_TOTGRAV := nTotSave
            SZ2->Z2_DATAFIM := Date()
            SZ2->Z2_HORAFIM := Time()
            SZ2->Z2_STATLOG := If(nTotLinha == nTotSave,"OK","LOG")
   SZ2->(MsUnLock())
   
   TcRefresh(cAliTab)  
   TCRefresh(RetSqlName(cAliTab))   

   U_MoveRead(aArqsTXT,Strzero(nLote,10))
   
   ProcessMessages()
   
Return lRet


Static Function SelSX3(cTabAtu)
	Local _aCmpX3 := {}	
	Local aAreaSX3	:= SX3->(FWGetArea())
	Local aRetCpos	:= {}
	Local nX := 0
		//dbSelectArea('SX3')
		_aCmpX3 := FWSX3Util():GetAllFields(cTabAtu, .F. ) //SX3->(dbSetOrder(1))
		if Len(_aCmpX3) > 0 //SX3->(dbSeek(cTabAtu))
		
			For nX := 1 to len(_aCmpX3) //While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == cTabAtu
				//If SX3->X3_CONTEXT <> "V"
					aAdd(aRetCpos,{GetSx3Cache(_aCmpX3[nX], 'X3_ARQUIVO'),GetSx3Cache(_aCmpX3[nX], 'X3_ORDEM'), GetSx3Cache(_aCmpX3[nX], 'X3_CAMPO'),GetSx3Cache(_aCmpX3[nX], 'X3_TIPO'), GetSx3Cache(_aCmpX3[nX], 'X3_TAMANHO'), GetSx3Cache(_aCmpX3[nX], 'X3_DECIMAL'),GetSx3Cache(_aCmpX3[nX], 'X3_TITULO'),;
								GetSx3Cache(_aCmpX3[nX], 'X3_VALID'), GetSx3Cache(_aCmpX3[nX], 'X3_RELACAO'),GetSx3Cache(_aCmpX3[nX], 'X3_CONTEXT'), GetSx3Cache(_aCmpX3[nX], 'X3_OBRIGAT')})
				//EndIf
			    //SX3->(dbSkip())
			Next nX //EndDo
		
		EndIf
	
	FWRestArea(aAreaSX3)
	
Return aRetCpos

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

*******************************************************
Static Function CreateSeq(cSequence,cAlias,lDesc,nJump)
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


**********************************************
Static Function fDirectory(cPath,cMask,lCount)
**********************************************
   Local cServer:= Alltrim(SuperGetMV('MV_XIMPIP',,''))
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
   Local cQuery := "SELECT TRIM(ZVK.ZVK_CPOORI) ORIGEM FROM "+RetSqlName("ZVK")+;
                   " ZVK WHERE ROWNUM=1 AND ZVK.ZVK_CODEXT='"+ZVJ->ZVJ_CODIGO+"' AND ZVK.ZVK_CPODES='{1}' AND ZVK.D_E_L_E_T_=' ' AND ZVK.ZVK_CPODES<>ZVK.ZVK_CPOORI"
   
   cQuery := StrTran(cQuery,"{1}",cCpoDest)
   
   TCQUERY cQuery NEW ALIAS (cAlias)
   If (cAlias)->(!Eof())
      cRet := AllTrim((cAlias)->ORIGEM)
   Endif
   
   If Select(cAlias) > 0   ; (cAlias)->(DbCloseArea()) ; Endif
Return cRet

*************************************
Static Function CountReg(nIdx,aFiles)
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
Static Function GetHeader(cFileName,cDelim)
*******************************************
	Local aRet      := {}
	Local aAux      := {}
	Local nX        := 0
    Local nHandle   := FOpen(cFileName,FO_READ + FO_SHARED)
	Local nBuffer   := 1024
	Local cEOL      := CRLF
	Local cRow      := ""
	Local cRead     := Space(nBuffer)
	Local nReturn   := 0
	Local nPosEol   := 0
	//Local nSize     := Len(SX3->X3_CAMPO)
	Local aAreaSX3  := SX3->(FWGetArea())
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
   
	//dbSelectArea('SX3')
	//SX3->(dbSetOrder(2))
	For nX := 1 To Len(aAux)
		If Empty(FWSX3Util():GetFieldType(aAux[nX])) .OR. ( GetSx3Cache(aAux[nX], 'X3_CONTEXT') == "V" ) 
		   MsgStop('Campo "'+Alltrim(aAux[nX])+'" Não Encontrado no Dicionário Protheus!'+CRLF+CRLF+"AÇÃO: Retire este da origem ou crie-o no dicionário.")
		   lValid := .F.
		   Loop
		Endif
		aAdd(aRet,{GetSx3Cache(aAux[nX], 'X3_ARQUIVO'),GetSx3Cache(aAux[nX], 'X3_ORDEM'), GetSx3Cache(aAux[nX], 'X3_CAMPO'),GetSx3Cache(aAux[nX], 'X3_TIPO'), GetSx3Cache(aAux[nX], 'X3_TAMANHO'), GetSx3Cache(aAux[nX], 'X3_DECIMAL'),GetSx3Cache(aAux[nX], 'X3_TITULO'),;
							GetSx3Cache(aAux[nX], 'X3_VALID'), GetSx3Cache(aAux[nX], 'X3_RELACAO'),GetSx3Cache(aAux[nX], 'X3_CONTEXT'), GetSx3Cache(aAux[nX], 'X3_OBRIGAT')})
	Next 
	FWRestArea(aAreaSX3)
	
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
      lRet := &(cFunction+'()')
   Endif
   
return lRet
   

***********************************
Static Function GetMaxRecno(cAlias)
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

******************************************
Static Function LoadTemp(cTable,cFileName)
******************************************
   Local lRet    := .T.
   Local nPacket := 100 //Quantidade por "pacote de dados/insert"
   Local aPacket := {}
   Local nCount  := 0
   Local cRow    := ""
   Local nHandle := 0
   Local cCmd    := "INSERT INTO "+cTable+" (LINHAO,NUMLINHA) VALUES ('{1}',{2})"
   
   nHandle := FOpen(cFileName,FO_READ + FO_SHARED)
   If ( nHandle == -1 )
      MSgInfo("Não foi possivel abrir o arquivo"+CRLF+cFileName+CRLF+"ERRO:"+CRLF+FERROR())
      return .F.
   Endif

   While lRet .And. (GetRow(nHandle,@cRow) > 0) 
         
         Aadd(aPack, SetCmd(cCmd,{cRow,nCount}) )
         
         If ( Mod(Len(aPacket),nPacket) == 0 )
            lRet := CommitPack(aPacket)
            aPacket := {}
         Endif
         
         nCount++
   Enddo

   If lRet .And. ! Empty(aPacket)
      CommitPack(aPacket)
      aPacket := {}
   Endif

return lRet

*********************************
Static Function CommitPack(aPack)
*********************************
   Local nX     := 0
   Local nLen   := Len(aPack)
   
   For nX := 1 To nLen
       If TcSqlExec(aPack[nX]) < 0
          MsgAlert('Erro ao gravar linha "'+cValToChar(nX)+'"'+CRLF+TCSqlError())
          Return .F.
       Endif
   Next
   
return .T.   


************************************
Static Function GetRow(nHandle,cRow)
************************************
	Local nBuffer := N_BUF_SIZE
	Local cEOL    := C_CRLF
	Local nRet    := 0
	Local cRead   := Space(nBuffer)
	Local nReturn := 0
	Local nPosEol := 0
	
	cRow := ""
	
	While ((nRet += FRead(nHandle,@cRead,nBuffer)) > 0) 
		cRow += cRead
		cRead := Space(nBuffer)
		nPosEol := At(cEOL,cRow)
		If (nPosEol != 0)
			cNewRow := Left(cRow,nPosEol - 1)
			nSkip   := Len(cRow) - (Len(cEOL) + Len(cNewRow))
			fSeek(nHandle,(nSkip * -1),FS_RELATIVE) //Volta o ponteiro para o início da próxima linha
			cRow    :=  cNewRow
			Exit
		Endif
	EndDo

Return nRet

**********************************
Static Function SetCmd(cCmd,aArgs)
**********************************
   Local nX   := 0
   Local cRet := cCmd
   For nX := 1 To Len(aArgs)
       cRet := StrTran(cRet,"{"+cValToChar(nX)+"}",cValToChar(aArgs[nX]))
   Next nX
Return cRet



****************************************
Static Function FileName(cFullName,lExt)
****************************************
   Local cDrive, cDir, cArq, cExt
   Local cRet := ""
   
   Default lExt := .T.

   SplitPath( cFullName, @cDrive, @cDir, @cArq, @cExt )
   
   cRet := cArq + If(lExt,cExt,"")

Return cRet   

