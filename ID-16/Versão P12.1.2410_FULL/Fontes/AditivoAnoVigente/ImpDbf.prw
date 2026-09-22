#Include 'Protheus.ch'
#Include "TopConn.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "TRYEXCEPTION.CH"
 
#DEFINE F_NAME 	1	
#DEFINE F_SIZE 	2	
#DEFINE F_DATE 	3	
#DEFINE F_TIME 	4	
#DEFINE F_ATT  	5	

#DEFINE C_KEYLOG  "IMPDBF"

#DEFINE C_PATH       "\sigadoc\RAT\"
#DEFINE C_PATH_LOG   "\sigadoc\RAT\logs\"

#DEFINE C_EXT_PAD 	 "*.dbf")

User Function ImpDbf()
    Local bProc    := {|lAbort| Exec(lAbort,aFiles) }
    Local aFiles   := {} 
    Private lAbort   := .F.
    Private oProcess := Nil
    
    If ChkFiles(@aFiles)
	   oProcess := MsNewProcess():New( bProc,"Aguarde...", 'Iniciando o processamento...', .T. )
	   oProcess:Activate()
	Endif
Return 

***********************************
Static function Exec(lAbort,aFiles)
***********************************
   Local aFiles   := {}
   Local cPath    := C_PATH //"\sigadoc\Roberto\FIN\"
   Local cAlias   := GetNextAlias()
   Local x,f      := 0
   Local cFileName:= ""
   Local aFields  := {}
   //Local nSeek    := Len(SX3->X3_CAMPO)
   Local nFCount  := 0
   Local nLidos   := 0
   Local nErros   := 0
   Local xValue   
   Local nReg     := 0
   Local nRegTot  := 0
   Local aAreaSx3 := SA3->(FWGetArea())
   
   Private cFileNmLog := GetFileLog(C_KEYLOG)
   
   //aFiles := DIRECTORY(cPath + "*.dbf")
   
   If Empty(aFiles)
      fMsgStop('Nenhum arquivo encontrado!'+chr(13)+cPath, {})
      return .F.
   Endif  
   
   oProcess:SetRegua1(Len(aFiles))
   
   //SX3->(DbSetOrder(2)) //X3_CAMPO
   For x := 1 To Len(aFiles)

       cAlias    := Left(aFiles[x,F_NAME],3)
       cAliasx   := FileNoExt(aFiles[x,F_NAME])
       cFileName := cPath + aFiles[x,F_NAME]

       oProcess:IncRegua1(StrTran('Importando "{1}"...',"{1}",aFiles[x,F_NAME]))
       
       If (Select(cAliasx) > 0)
          (cAliasx)->(dbCloseArea())
       Endif     
       
       If ! File(cFileName) 
          fMsgStop('Arquivo não encontrado !'+CHR(13)+'{1}',{cFileName})
          Loop
       Endif
       
       dbSelectArea(cAlias)
       
       U_CriaExcl(cAliasx) //DbUseArea(.T., "DBFCDXADS", FileNoExt(cFileName), cAliasx, .F., .F.)
       If (cAliasx)->(Eof())
          Loop
       Endif
       
       nRegTot := (cAliasx)->(LASTREC())
       
       oProcess:SetRegua2( nRegTot )
       
       aFields := (cAliasx)->(dbstruct())
       nFCount := (cAlias)->(FCount())
       
       nReg   := 0
       nLidos := 0
       nErros := 0
       While (cAliasx)->(!Eof())
       
             nReg++

             oProcess:IncRegua2(StrTran(StrTran('Registro {1} de {2}...',"{1}",cValToChar(nReg)),"{2}",cValToChar(nRegTot))) 
             
             TRYEXCEPTION
             
                (cAlias)->( DBAppend( .T. ) )
                
                For f := 1 To Len(aFields)
                    If Empty(FWSX3Util():GetFieldType(aFields[f,1])) //SX3->(!DbSeek(PadR(aFields[f,1],nSeek)))
                       Loop
                    Endif
                    
                    xValue := (cAliasx)->(FieldGet((cAliasx)->(FieldPos(aFields[f,1]))))
                    If (GetSx3Cache(aFields[f,1], 'X3_TIPO') == "L") .And. ValType(xValue) != "L"
                       If Upper(xValue) == "T"
                          xValue := .T.
                       Else
                          xValue := .F.
                       Endif
                    Endif
                    
                    (cAlias)->(FieldPut((cAlias)->(FieldPos(aFields[f,1])),xValue))
                Next f
                
                (cAlias)->(MsUnLock())
                (cAlias)->(DbCommit())

                nLidos++
             CATCHEXCEPTION USING oException
	             IF ( ValType( oException ) == "O" )
	                //Alert(oException:DESCRIPTION)
	                AddLogErr(C_KEYLOG,oException:DESCRIPTION,{})
	                oException := nil
	                nErros++
	             EndIF	                     
             ENDEXCEPTION	
             
             (cAliasx)->(DbSkip())
             
             //ProcessMessages()
       Enddo
       
       AddLogInf(C_KEYLOG,Replicate("=",100),{})
       AddLogInf(C_KEYLOG,PadC("* * * R E S U M O * * *"          ,100),{})
       AddLogInf(C_KEYLOG,PadR("Arquivo de carga ............ {1}",100),{cFileName})
       AddLogInf(C_KEYLOG,PadR("Alias ....................... {1}",100),{cAlias})
       AddLogInf(C_KEYLOG,PadR("Tabela de destino ........... {1}",100),{RetSqlName(cAlias)})
       AddLogInf(C_KEYLOG,PadR("Total de registros .......... {1}",100),{nRegTot})
       AddLogErr(C_KEYLOG,PadR("Registros rejeitados ........ {1}",100),{nErros})
       AddLogInf(C_KEYLOG,PadR("Registros importados ........ {1}",100),{nLidos})
       AddLogInf(C_KEYLOG,Replicate("=",100),{})
       
   Next
   
   If (Select(cAlias) > 0)
      (cAlias)->(dbCloseArea())
   Endif 
   
   //OpenLog(cFileNmLog)
   
   SX3->(RestArea(aAreaSx3))
   
Return .T.

**************************************
Static Function fMsgStop(cMsg,aParams)
**************************************
	Local cMessage := OemToAnsi(cMsg)
	Local nX       := 0

	Default aParams := {}
	Default lBack   := .F.
   
	For nX := 1 To Len(aParams)
		cMessage := StrTran(cMessage,"{"+cValToChar(nX)+"}",cValToChar(aParams[nX]))
	Next nX
   
	MsgStop(cMessage)
	
Return nil

//--Rotinas de Log.
/**
 * Grava log
 *
 * @author Roberto Amâncio Teixeira
 * @date 27/06/2017
 * 
 * @param caracter Indentificador do LOG: INF = Informação, WAR = Alerta, ERR = Erro
 * @param caracter Mensagem a ser gravada no LOG.
 * @param array Parâmetros para mensagem. 
 * @return nil
*/ 
*****************************************************
Static Function AddLog(cKeyLog,cTypeLog,cMsg,aParams)
*****************************************************
	Local cFileLog  := cFileNmLog
	Local cDirLog   := GetPathLog()
	Local cMessage  := OemToAnsi(cMsg)
   
	Default aParams := {}
   
	If !ExistDir ( cDirLog )
		If !FWMakeDir(cDirLog,.F.)
			ConOut( "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) )
			return nil
		Endif
	Endif
   
	For nX := 1 To Len(aParams)
		cMessage := StrTran(cMessage,"{"+cValToChar(nX)+"}",cValToChar(aParams[nX]))
	Next nX
   
	cMessage := cTypeLog + '-' + DtoS(Date()) + ' ' + Time() + '-' + cMessage + CRLF
                               
	If File(cFileLog)
		nHandle := fOpen(cFileLog,FO_READWRITE + FO_SHARED)
	Else
		nHandle := fCreate(cFileLog,FC_NORMAL)
	Endif
	
	fSeek(nHandle, 0, FS_END)
	
	fWrite(nHandle,cMessage)
   
	fClose(nHandle)
return nil

/**
 * Grava log de erro (ERR)
 *
 * @author Roberto Amâncio Teixeira
 * @date 27/06/2017
 * 
 * @param caracter Indentificador do LOG.
 * @param caracter Mensagem a ser gravada no LOG.
 * @param array Parâmetros para mensagem. 
 * @return nil
*/ 
***********************************************
Static Function AddLogErr(cKeyLog,cMsg,aParams)
***********************************************
	AddLog(cKeyLog,"ERR",cMsg,aParams)
return nil

/**
 * Grava log de erro (ERR)
 *
 * @author Roberto Amâncio Teixeira
 * @date 27/06/2017
 * 
 * @param caracter Indentificador do LOG.
 * @param caracter Mensagem a ser gravada no LOG.
 * @param array Parâmetros para mensagem. 
 * @return nil
*/ 
****************************************
Static Function AddLogsErr(aMsg,aParams)
****************************************
    Local nX := 0

	AddLog(C_KEYLOG,"ERR",Replicate('-',100),Nil)
    For nX := 1 To Len(aMsg)
	    AddLog(C_KEYLOG,"ERR",aMsg[nX],aParams)
	Next
	AddLog(C_KEYLOG,"ERR",Replicate('-',100),Nil)
	
return nil


/**
 * Grava log de erro (INF)
 *
 * @author Roberto Amâncio Teixeira
 * @date 27/06/2017
 * 
 * @param caracter Indentificador do LOG.
 * @param caracter Mensagem a ser gravada no LOG.
 * @param array Parâmetros para mensagem. 
 * @return nil
*/ 
***********************************************
Static Function AddLogInf(cKeyLog,cMsg,aParams)
***********************************************
	AddLog(cKeyLog,"INF",cMsg,aParams)
return nil

/**
 * Grava log de erro (WAR)
 *
 * @author Roberto Amâncio Teixeira
 * @date 27/06/2017
 * 
 * @param caracter Indentificador do LOG.
 * @param caracter Mensagem a ser gravada no LOG.
 * @param array Parâmetros para mensagem. 
 * @return nil
*/ 
***********************************************
Static Function AddLogWar(cKeyLog,cMsg,aParams)
***********************************************
	AddLog(cKeyLog,"WAR",cMsg,aParams)
return nil

/**
 * Retorna o nome do arquivo de Log, conforme a chave (cKeyLog)
 *
 * @author Roberto Amâncio Teixeira
 * @date 27/06/2017
 * 
 * @return caracter
*/ 
***********************************
Static Function GetFileLog(cKeyLog)
***********************************
	Local cDirLog  := GetPathLog()
	Local cSufixo  := "9"
	Local bLogFile := {|| cSufixo := Soma1(cSufixo), cDirLog + cKeyLog + "_" + DtoS(Date()) + "_" + cSufixo + ".txt" }
	Local cRet     := ""
	
	cRet := Eval(bLogFile)
	While File(cRet)
	      cRet := Eval(bLogFile)
	EndDo
	
return cRet

/**
 * Retorna o nome do arquivo de Log, conforme a chave (cKeyLog)
 *
 * @author Roberto Amâncio Teixeira
 * @date 27/06/2017
 * 
 * @return caracter
*/
****************************
Static Function GetPathLog()
****************************
return C_PATH_LOG

**********************************
Static Function OpenLog(cFileName)
**********************************
   Local cLocalFile := ""
   Local cMsg       := If(File(cFileName),"","Arquivo de LOG não encontrado! Verifique.")
   Local lRet       := Empty(cMsg)
   Local lCopyOk    := .F.
   
   If lRet
      cLocalFile := U_GetTmpPath(.T.) + right(cFileName,LEN(cFileName)-RAT("\",cFileName))
      MsgRun( "Aguarde..." , "Gerando o log..." , { || lCopyOk := CpyS2T(cFileName,U_GetTmpPath(.T.)) } )
      If lCopyOk .And. File(cLocalFile) 
         ShellExecute("Open",cLocalFile,"","",3)	// 1 = Normal, 2 = Minimizado, 3 = Maximizado
      Endif
   Else
      MsgStop(cMsg)
   Endif
   
Return lRet

********************************
Static Function ChkFiles(aFiles)    
********************************
    Local lRet      := .T.
	Local _stru     := {}
	Local aCpoBro   := {}
	Local aCores    := {}
	Local oDlg      := nil
	LOcal cArqTmp   := ""

	Static cAlias := GetNextAlias()   
	Static oMark   
	Static cMark   := GetMark()   

	Private lInverte := .F.     

	//Cria um arquivo de Apoio
	AADD(_stru,{"OK"     ,"C"	,02,0})
	AADD(_stru,{"Nome"   ,"C"	,25,0})
	AADD(_stru,{"Tamanho","N"	,15,0})
	AADD(_stru,{"Data"   ,"D"	,08,0})
	AADD(_stru,{"Hora"   ,"C"	,08,0}) 
	
	aCpoBro := {{ "OK"			,, " "        ,""},;
				{ "Nome"		,, "Nome"     ,""},;			
				{ "Tamanho"		,, "Tamanho"  ,""},;
				{ "Data"		,, "Data"     ,""},;			
				{ "Hora"		,, "Hora"     ,""}}

	If (Select(cAlias) > 0)
      (cAlias)->(DbCloseArea())
	Endif
	
	oTempTable := FWTemporaryTable():New(cAlias) //cArqTmp := Criatrab(_stru,.T.)
	oTemptable:SetFields( _stru ) //DBUSEAREA(.t.,,cArqTmp,cAlias)
	oTempTable:Create()
	For nX := 1 To Len(aFiles)
		DbSelectArea(cAlias)	
		RecLock(cAlias,.T.)
		(cAlias)->Nome    :=  aFiles[nX,F_NAME]
		(cAlias)->Tamanho :=  aFiles[nX,F_SIZE]
		(cAlias)->Data    :=  aFiles[nX,F_DATE]
		(cAlias)->Hora    :=  aFiles[nX,F_TIME]
		(cAlias)->OK  	  :=  cMark //Iif((AScan(aCposBK,{|x| x == AllTrim(aFields[nX,1])})>0),cMark,"")
		MsunLock()	
	Next
	
	aCpoBro := {{ "OK"			,, " "        ,""},;
				{ "Nome"		,, "Nome"     ,""},;			
				{ "Tamanho"		,, "Tamanho"  ,""},;
				{ "Data"		,, "Data"     ,""},;			
				{ "Hora"		,, "Hora"     ,""}}

	DbSelectArea(cAlias)
	DbGotop()
	
    oDlg := TDialog():New(000, 000, 200, 400, "Selecione os arquivos a serem importados",,,,,,,,, .T.)
	
       oMark := FwMarkBrowse():New() //MsSelect():New(cAlias,"OK","",aCpoBro,@lInverte,@cMark,{17,1,150,295},,,oDlg,,aCores)
	   oMark:SetTemporary(.T.)
	   oMark:SetAlias(cAlias)
	   oMark:SetColumns(aCpoBro)
	   oMark:SetFieldMark("OK")
       oMark:bMark := {| | SetMark(@oMark,cAlias,cMark)}
	   
	   oMark:Activate()
	oDlg:Active(,,,.T., /*bValid*/,, /*[ bInit ]*/,,)
	
	aFiles := {}
    (cAlias)->(DbGotop())
    (cAlias)->(DbEval({|| Aadd(Nome,Tamanho,Data,Hora) },{|| OK == cMark}))
    
Return (!Empty(aFiles))

//Funcao executada ao Marcar/Desmarcar um registro.   
*******************************************
Static Function SetMark(oMark,cAlias,cMark)
*******************************************
	RecLock(cAlias,.F.)
	If Marked("OK")	
		(cAlias)->OK := cMark
    Else	
		(cAlias)->OK := ""
	Endif             
	(cAlias)->(MsUnlock())
	oMark:oBrowse:Refresh()
Return()
