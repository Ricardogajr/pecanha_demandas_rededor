#include "PROTHEUS.CH"
#include "TCBROWSE.CH"
#include "fileio.ch"
#Include "TopConn.ch"
#INCLUDE "TRYEXCEPTION.CH"

#DEFINE C_CRLF     	CHR(13) + CHR(10)
#DEFINE N_BUF_SIZE 	1024

#DEFINE C_KEYLOG	"SE2_EXAUTO"

#DEFINE F_NAME	1
#DEFINE F_SIZE	2
#DEFINE F_DATE	3
#DEFINE F_TIME	4
#DEFINE F_ATT	5

#DEFINE N_PacketRecords 150

#DEFINE C_ROTINA "FINA050"

#DEFINE GLB_LOG_FILE   "cLogFile"
#DEFINE GLB_TAB_ALIAS  "cTabAlias"
#DEFINE GLB_REG_TOT    "Tot"+STRTRAN(SerialNumber('C:'),'-') //Quantidade total de registros.
#DEFINE GLB_REG_ERR    "Err"+STRTRAN(SerialNumber('C:'),'-') //Quantidade de registros com erros.
#DEFINE GLB_SUSPEND    "Suspend"+STRTRAN(SerialNumber('C:'),'-') //Se "1", processamento interrompido.
#DEFINE GLB_SZ2_RECNO  "SZ2Recno"+STRTRAN(SerialNumber('C:'),'-') //Recno da SZ2 atual/corrente...
#DEFINE GLB_E2_XMIGLT  "E2_XMIGLT"+STRTRAN(SerialNumber('C:'),'-') //Lote da carga

#xtranslate bSetGet(<uVar>)       =>  {|u| If(PCount() == 0, <uVar>,<uVar> := u)}

User Function ExAutoSE2()
	Local aArea        := GetArea()
	Local cTabAlias    := TabAlias(UPPER(AllTrim(ZVJ->ZVJ_DESTIN)))

	Private cCodProc    := AllTrim(ZVJ->ZVJ_CODIGO)
	Private cSourcePath := Left(AllTrim(ZVJ->ZVJ_DIRIMP),RAT("\",AllTrim(ZVJ->ZVJ_DIRIMP))) 	
	Private aFiles      := StaticCall(IMPTAB,fDirectory,cSourcePath,TabAlias()+"*.TXT",.T.)
	Private oProcess    := Nil
    Private cSeparator  := ";"
    Private cFileName   := ""
    Private aUnique     := GetUnique(TabAlias())
    Private cTabDesc    := FWX2Nome( TabAlias() )
    Private nNumLote    := GetMV('DOR_CHARGE')
	
	If Empty(aFiles)
	    MsgStop("Não há arquivos para serem processados! Verifique.")
	    Return .F.
	Endif

	Reset()
	
	oProcess := MsNewProcess():New( { | lEnd | lRet := Process(@oProcess,@lEnd) },;
                                   "Dados da Origem", "Aguarde, preparando os dados...", .F. )
	oProcess:Activate()
	
	Reset()
	
	RestArea(aArea)
	
return .T.

***********************
Static Function Reset()
***********************
   ClearGlbValue(GLB_LOG_FILE)
   ClearGlbValue(GLB_TAB_ALIAS)
   ClearGlbValue(GLB_REG_TOT)
   ClearGlbValue(GLB_REG_ERR)
   ClearGlbValue(GLB_SUSPEND)
   ClearGlbValue(GLB_SZ2_RECNO)
   ClearGlbValue(GLB_E2_XMIGLT)
return .T.


**************************************   
Static Function Process(oProcess,lEnd)
**************************************
   Local nX, nY      := 0
   Local cCodFil     := ""
   Local aHeader     := {}
   Local aRows       := {}
   Local aFiliais    := {}
   Local aStruct     := {}
   Local nHandle     := 0 
   Local bOpen       := {|| nHandle := OpenFile(cFileName,@cSeparator,@aHeader,@aStruct) }
   Local nGerLinha   := 0 //Total de Linhas dos arquivos TXT's - no caso de haver mais de um arquivo p/lote.
   Local nTotLinha   := 0 //Total de Linhas do arquivo TXT
   Local nRecInvalid := 0 //Linhas rejeitadas durante a leitura do TXT
   Local nGerSave    := 0
   Local nTotSave    := 0 //Total de linhas salvas/processadas com sucesso.
   Local oProcess1   := nil
   Local aAreaSZ2    := SZ2->(GetArea())
   Local cXMigLt     := ""
   
   PutMv("DOR_CHARGE",++nNumLote)
   
   cXMigLt := DToS(Date()) + " " + Time() + " " + Strzero(nNumLote,10)
   SetGlb(GLB_E2_XMIGLT,cXMigLt)
   
   Aeval(aFiles,{|x| ASize(x,Len(x)+1) })
    
   oProcess:SetRegua1(Len(aFiles))
   
   For nX := 1 To Len(aFiles)
       
       ProcessMessages()

       If lEnd
          MsgStop("Processamento interrompido pelo usuário!")
          Exit
       Endif
       
       nTotLinha := aFiles[nX,7]
       nTotSave  := 0
       cFileName := aFiles[nX,6]
       
       oProcess:IncRegua1('Processando arquivo "'+cValToChar(nX)+"/"+cValToChar(Len(aFiles))+'"...')
       
       AddLogInf( Replicate("*",100))
       AddLogInf( 'Processando o arquivo "{1}"...' , {aFiles[nX,F_NAME]})
       AddLogInf( Replicate("*",100))
       
       /* Obtém os dados do arquivo */
       aHeader := {}
       aStruct := {}
       
       MsgRun('Obtendo informações do arquivo...',"Aguarde...",bOpen)   
       
       If ( nHandle == -1 )
          Loop
       Endif
       
       aFiles[nX,8] := TabAlias()+"-"+FWTimeStamp(3,dDatabase,Time())+FWTimeStamp(4,dDatabase,Time())
       
       RecLock("SZ2",.t.)
          SZ2->Z2_UKEY    := aFiles[nX,8]
          SZ2->Z2_NUMLOTE := Strzero(nNumLote,10)
          SZ2->Z2_CODPRC  := ZVJ->ZVJ_CODIGO
          SZ2->Z2_CODTAB  := TabAlias()
          SZ2->Z2_DATAINI := dDataBase
          SZ2->Z2_HORAINI := time()
          SZ2->Z2_FRONT   := Upper(Subs(Alltrim(aFiles[nX,1]),At("_",Alltrim(aFiles[nX,1]))+1,At("_",Subs(Alltrim(aFiles[nX,1]),At("_",Alltrim(aFiles[nX,1]))+1))-1))
          SZ2->Z2_ARQUIVO := Upper(Alltrim(aFiles[nX,1]))
          SZ2->Z2_DATATXT := aFiles[nX,3]
          SZ2->Z2_HORATXT := aFiles[nX,4]
          SZ2->Z2_CODUSER := Alltrim(cUserName)
          SZ2->Z2_AMBIENT := Alltrim(GetEnvServer())
          SZ2->Z2_TIMSTAM := FWTimeStamp(2,Date(),Time())
          SZ2->Z2_VALIDA  := "S"
          SZ2->Z2_MAXREC  := StaticCall( IMPTAB,GetMaxRecno,TabAlias() )
          SZ2->Z2_URI     := GetLogURI()
          
          If ( SZ2->(FieldPos("Z2_XMIGLT")) > 0 )
               SZ2->Z2_XMIGLT := cXMigLt
          Endif
          
       SZ2->(MsUnLock())
       
       SetGlb(GLB_SZ2_RECNO,SZ2->(Recno()))
       
       AddLogInf( 'Nome qualificado			{1}', {aFiles[nX,6]})
       AddLogInf( 'Data						{1}', {aFiles[nX,F_DATE]})
       AddLogInf( 'Hora						{1}', {aFiles[nX,F_TIME]})
       AddLogInf( 'Tamanho em bytes			{1}', {aFiles[nX,F_SIZE]})
       AddLogInf( 'Quantidade de registros	{1}', {nTotLinha})
       AddLogInf( Replicate("=",100))
       
       aRows  := ReadData(oProcess,lEnd,nHandle,aHeader,aStruct,aFiliais,nTotLinha)
       
       If Empty(aRows)
          RecLock("SZ2",.f.)
             SZ2->Z2_TOTLINH := nTotLinha
             SZ2->Z2_TOTGRAV := 0
             SZ2->Z2_DATAFIM := Date()
             SZ2->Z2_HORAFIM := Time()
             SZ2->Z2_STATLOG := "LOG"
          SZ2->(MsUnLock())
          
          Loop
       Endif
       
       nRecInvalid := nTotLinha - Len(aRows)
       
       aSort( aFiliais,,, { |x,y| x[1] < y[1] } )
       aSort( aRows   ,,, { |x,y| x[1,2] < y[1,2] } )
       
       oProcess1 := MsNewProcess():New( { | lEnd | Gravar(@oProcess1,@lEnd,aFiliais,aRows) },;
                                  FWX2Nome( TabAlias() ), "Aguarde, gravando...", .F. )
       oProcess1:Activate()
       
       nTotLinha := Len(aRows)
       
       nTotSave := nTotLinha - ( nRecInvalid + GetNum(GLB_REG_ERR) )
       
       RecLock("SZ2",.f.)
          SZ2->Z2_TOTLINH := nTotLinha
          SZ2->Z2_TOTGRAV := nTotSave
          SZ2->Z2_DATAFIM := Date()
          SZ2->Z2_HORAFIM := Time()
          SZ2->Z2_STATLOG := If(nTotLinha == nTotSave,"OK","LOG")
       SZ2->(MsUnLock())
       
       nGerLinha += nTotLinha
       nGerSave  += nTotSave
   Next nX
   
   RestArea(aAreaSZ2)
   
return nil

****************************************************
Static Function Gravar(oProcess,lEnd,aFiliais,aRows)
****************************************************
   Local nR        := 0
   Local nPack     := N_PacketRecords 
   Local aPack     := {}
   Local nTotFil   := Len(aFiliais)
   Local nTotReg   := Len(aRows)
   Local nLenTot   := Len( cValToChar( nTotReg ) )
   Local cCodFil   := ""
   Local cNewFil   := ""
   Local bExec     := {|| ChangeEmp(cCodFil,aPack) }
  
   oProcess:SetRegua1(nTotFil)
   oProcess:SetRegua2(nTotReg)
   
   SetGlb(GLB_REG_ERR,0)
   
   For nR := 1 To nTotReg

       oProcess:IncRegua2( 'Empacotando o registro "'+StrZero(nR-1,nLenTot)+"/"+cValToChar(nTotReg)+'"...' )

       cNewFil := U_MGSM0DP1("",aRows[nR][1,2])
       If cCodFil <> cNewFil
          If ! Empty(aPack) 
             MsgRun('Executando FINA050 para Filial "{1}"...',"Aguarde...", bExec )   
             aPack := {} 
          Endif
          cCodFil := cNewFil
          oProcess:IncRegua1( FWFilialName(,cCodFil,1) )
       ElseIf ! Empty(aPack) .And. ( Mod(Len(aPack),nPack) == 0 ) 
          MsgRun('Executando a rotina automática FINA050...',"Aguarde...", bExec )   
          aPack := {}
       Endif
       
       Aadd(aPack,aRows[nR])
   
   Next nR

   If ! Empty(aPack)
      MsgRun('Executando a rotina automática FINA050...',"Aguarde...", bExec )   
   Endif
    
return nil

*****************************************
Static Function ChangeEmp( cFil, aDados )
*****************************************
   Local lRpcSet   := !( cFil == cFilAnt )
   Local lRet      := .F.
   Local cInterNet := __cInterNet
   Local lPYME     := __lPYME
   Local oWnd      := If(Type("oMainWnd")=="O",oMainWnd,nil)
   Local lSuspend  := .F.

   If lRpcSet
      oMainWnd    := Nil
      __cInterNet := Nil
      __lPYME     := .F.
   Endif
   
   If !( lRpcSet )
      lRet := U_ExecAuto(cEmpAnt,cFil,lRpcSet,aDados,aUnique,lSuspend,cCodProc)
   else
      lRet := StartJob("U_ExecAuto" ,GetEnvServer(),.T.,cEmpAnt,cFil,lRpcSet,aDados,aUnique,lSuspend,cCodProc)
   endif
   
   If lRpcSet
      oMainWnd    := oWnd    
      __cInterNet := cInterNet
      __lPYME     := lPYME
   Endif
   
Return( lRet )

***********************************************************************
User function ExecAuto(cEmp,cFil,lRpcSet,aDados,aKey,lSuspend,cCodProc)
***********************************************************************
	Local lRet        := .T.
	Local nX          := 0
	Local nCount      := 0
	Local aRow        := {}
	Local aLog        := {}
	Local aFormulas   := {}
	Local nPosNum     := 0
    Local bErrorBlock := ErrorBlock( {|e|lErros := .T., ExAutError(GetKey(aKey,aRow),e:Description) } )
	Local nErros      := 0
    Local lErros      := .F.   
    Local bSuspend    := {|| lSuspend  }
    Local nDados      := Len(aDados)
    Local nRecnoSZ2   := GetNum(GLB_SZ2_RECNO)
    Local cKey        := ""
    Local nKey        := 0
    Local cXMigLt     := GetGlbValue(GLB_E2_XMIGLT)

    Private lMsHelpAuto    := .T.
    Private lMsErroAuto    := .F. 
    Private lAutoErrNoFile := .T.
    
    Public ___XMIGLT       := nil
    
    Default lRpcSet := .F.
    
    If lRpcSet
       BEGIN SEQUENCE
	      RpcSetType( 3 )
	      RpcSetEnv( cEmp, cFil )
       END SEQUENCE
    Endif
    
    ErrorBlock(bErrorBlock)

    If (cEmp != cEmpAnt) .OR. (cFil != cFilAnt)
       AddLogErr('Não foi possível carregar o ambiente da empresa "{1} - {2}".',{cEmpAnt,cFil,FWFilialName(cEmpAnt,cFil,2)})
       Inc(GLB_REG_ERR,nDados)
       return .F.
    Endif
    
    AddLogInf(Replicate("=",100),nil)
    AddLogInf('Processando  "{3}" registro(s), Empresa "{1} - {2}".',{cFil,FWFilialName(,cFil,2),Len(aDados)})
    AddLogInf(Replicate("=",100),nil)
    
    If ( SZ2->(Recno()) != nRecnoSZ2 )
       SZ2->(DbGoTo(nRecnoSZ2))
    Endif
    
    For nX := 1 To nDados
        
        If Eval(bSuspend)
           Exit
        Endif

        aRow := aDados[nX]
        
        If ! SetZVK(aFormulas,aRow,cCodProc)
           nPosNum := AScan(aRow,{|x| x[1] == "E2_NUM"})
           AddLogErr('Erro ao aplicar as fórmulas ao documento "{1}", filial "{2}"!',{aRow[nPosNum,2],cFilAnt})
           AddLogErr(Replicate("-",100),nil)

           LogSZ3(cFilAnt,{FmtStr('Erro ao aplicar as fórmulas ao documento "{1}", filial "{2}"!',{aRow[nPosNum,2],cFilAnt})},GetKey(aKey,aRow)) 
           
           lErros := .T.
           nErros++
           Loop        
        Endif

        aRow := FWVetByDic( aRow, TabAlias(), .F., 1 )
        nPosNum := AScan(aRow,{|x| x[1] == "E2_NUM"})
        
        ___XMIGLT       := cXMigLt
        
        lMsErroAuto := .F.	
        MSExecAuto({|x,y,z| Fina050(x,y,z)},aRow,,3) //3=Inclusão, 4=Alteração, 5=Exclusão
        
        ___XMIGLT       := Nil
        
        
        If lMsErroAuto
           AddLogErr(Replicate("-",100),nil)
           AddLogErr('Erro ao incluir o documento "{1}", filial "{2}"!',{aRow[nPosNum,2],cFilAnt})
           aLog := GetAutoGRLog()
           AddLogsErr(aLog)

           LogSZ3(cFilAnt,aLog,GetKey(aKey,aRow)) 
           
           lErros := .T.
           nErros++
        Endif
            
        ProcessMessages()
    
    Next nX 
    
    Inc(GLB_REG_ERR,nErros)
	
	If lRpcSet
	   RpcClearEnv()
	Endif
    
Return lRet

******************************************
Static Function ExAutError(cKey,cMsgError)
******************************************
   Local cMsg := FmtStr("Erro durante o processamento do registro {1}:{2}",{cKey,CRLF + cMsgError})
   AddLogErr(Replicate("@",100),nil)
   AddLogErr(cMsg              ,nil)
   AddLogErr(Replicate("@",100),nil)
Return nil

**************************************
Static function GetKey(aKey,aRow,cSep)
**************************************
   Local cRet := ""
   Local nX   := 0
   Local nLen := 0
   Local nPos := 0

   Default aKey := {}
   Default aRow := {}    
   Default cSep := "|"
   
   nLen := Len(aKey)
   
   For nX := 1 To nLen
       nPos := AScan(aRow,{|r| r[1] == aKey[nX]})
       If nPos > 0
          cRet += aRow[nPos,2] + If(nX < nLen,cSep,"")
       Endif
   Next
   
Return cRet   

********************************************************************************
Static function ReadData(oProcess,lEnd,nHandle,aHeader,aStruct,aFiliais,nQtdReg)
********************************************************************************
	Local aRet      := {}
	Local aField    := {}
	Local aRow      := {}
	Local nX, nY    := 0
	Local nRowNum    := 0
	Local cRow      := ""
	Local xData     := nil
	Local cFilCod   := ""
	Local nPosLot   := 0
	Local cXMigLt   := GetGlbValue(GLB_E2_XMIGLT)
    //Filiais para De-Para
	Local nFilial   := AScan(aHeader,{|x| x == "E2_FILIAL"})

    If Empty(aHeader)
       fMsgStop('Não foi possível obter o cabeçalho do arquivo! Verifique.',nil,.T.)
       return {}
    Endif

	oProcess:SetRegua2( nQtdReg )

	While (GetRow(nHandle,@cRow) > 0) .And. !lEnd

		aData := Separa(cRow,cSeparator,.T.)
		
		If (Len(aData) != Len(aStruct))
			AddLogErr(Replicate("*",100))
			AddLogErr('Os dados do registro "{1}" diverge do cabeçalho (Dados: {2}/Cabeçalho:{3}).',{nRowNum+1,Len(aData),Len(aStruct)})
			AddLogErr(Replicate("*",100))
			nRowNum++
			Loop
		Endif

		nRowNum++
	  
		oProcess:IncRegua2( StrTran(StrTran('Lendo o registro {1}/{2}',"{1}",cValToChar(nRowNum)),"{2}",cValToChar(nQtdReg)) )
		ProcessMessages()
	  
	    aRow := {}
		For nX := 1 To Len(aStruct)
            
			xData := aData[nX]
			
			If Empty(xData)
			   Do Case
			      Case aStruct[nX,2] == "N"
			           xData := 0
			      Case aStruct[nX,2] == "D"
			           xData := CToD("")
			      Case aStruct[nX,2] == "L"
			           xData := .F.
			      Otherwise
			           xData := CriaVar(aStruct[nX,1])
			   EndCase
			Else
			   Do Case
			      Case aStruct[nX,2] == "N"
			           xData := Val(xData)
			      Case aStruct[nX,2] == "D"
			           xData := StoD(xData)
			      Case aStruct[nX,2] == "L"
			           xData := ('T' $ Upper(xData))
			      Case aStruct[nX,2] == "C"
			           xData := PadR(xData,aStruct[nX,3])
			   EndCase
			Endif
			
			Aadd(aRow,{aStruct[nX,1],xData,nil})
			
		Next nX

        nPosLot := AScan(aRow,{|f| f[1] == "E2_XMIGLT"})
        If ( nPosLot == 0 )
	       Aadd(aRow,{"E2_XMIGLT",If(Empty(cXMigLt),"ERRO", cXMigLt),nil})
	    ElseIf Empty(AllTrim(aRow[nPosLot,2]))
	       aRow[nPosLot,2] := cXMigLt
	    Endif
		
		Aadd(aRet,aRow)
	  
		//Grava o código da empresa/filial em aFiliais
		cFilCod := U_MGSM0DP1("",aRet[Len(aRet),nFilial][2])
		nPosEmp := AScan(aFiliais,{|e| e[1] == cFilCod})
		If ( nPosEmp == 0 )
			Aadd(aFiliais,{cFilCod,nQtdReg}) //{Filial,Total Registros}
		Endif
		//FIM: Grava o código da empresa/filial em aFiliais.

	Enddo
	
	FClose(nHandle)
   
Return aRet


**********************************************************
Static Function OpenFile(cFile,cSeparator,aHeader,aStruct)
**********************************************************
   Local nRet := 0
   
   nRet := FOpen(cFile,FO_READ + FO_SHARED)
   If ( nRet == -1 )
      MSgInfo("Não foi possivel abrir o arquivo"+CRLF+cFile+CRLF+"ERRO:"+CRLF+FERROR())
      return nRet
   Endif
   
   aHeader := GetHeader(nRet,@aStruct)

return nRet   

******************************************
Static Function GetHeader(nHandle,aStruct)
******************************************
	Local aRet    := {}
	Local nX      := 0
	Local nBuffer := N_BUF_SIZE
	Local cEOL    := C_CRLF
	Local nLenEOL := Len(cEOL)
	Local cRow    := ""
	Local cRead   := Space(nBuffer)
	Local nReturn := 0
	Local nPosEol := 0
	Local nX      := 0
	Local aField  := {}

	fSeek(nHandle,0,0) // Posiciona no início do arquivo
   
	While (FRead(nHandle,@cRead,nBuffer) > 0) .OR. (At(cEOL,cRow) != 0)
		cRow += cRead
		cRead := Space(nBuffer)
         
		nPosEol := At(cEOL,cRow)
		If (nPosEol != 0)
			nReturn := (Len(Substr(cRow,nPosEol + nLenEOL,Len(cRow) - nPosEol + nLenEOL)) * -1)
			fSeek(nHandle, nReturn, FS_RELATIVE) //retorna a quantidade de bytes excedentes à CRLF.
			cRow := ExCRLF(Substr(cRow,1,nPosEol),cEOL)
			Exit
		Endif
	EndDo

	cSeparator := ";"
	Do Case
	   Case ( CHR(165) $ cRow )
	        cSeparator := CHR(165) //¥
	   Case ( CHR(167) $ cRow )
	        cSeparator := CHR(167) //§
	EndCase
    
	aRet := StrTokArr(StrTran(cRow,chr(32),""),cSeparator)

	If Empty(aRet)
		fMsgStop('O arquivo está vazio! Verifique')
		Return {}
	Endif
   
	AEval(aRet,{|f| f := AllTrim(f)})
	
    For nX := 1 To Len(aUnique)
	    If ( AScan(aRet,{|f| AllTrim(f) == aUnique[nX]}) == 0)
            AddLogErr('-')
	    	AddLogErr('O campo "{1}" não foi encontrado no dicionário! Verifique.',{aUnique[nX]})
            AddLogErr('-')
	    	Return {}
	    Endif
	Next nX
   
	If ( Len(aRet) == Len(aUnique) )
		fMsgStop('O arquivo não possue dados para a atualização! Verifique.')
		Return {}
	Endif
	
   //Verifica os campos no dicionário da empresa corrente.
	For nX := 1 To Len(aRet)
		aField := TamSx3(aRet[nX])
		If Empty(aField)
			fMsgStop('O campo "{1}" não existe no dicionário! Verifique.',{aRet[nX]})
			return {}
		Endif
		Aadd(aStruct,{aRet[nX],aField[3],aField[1],aField[2]})
	Next nX
	

Return aRet

************************************
Static Function GetRow(nHandle,cRow)
************************************
	Local nBuffer := N_BUF_SIZE
	Local cEOL    := C_CRLF
	Local nLenEOL := Len(cEOL)
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
			nSkip   := Len(cRow) - (nLenEOL + Len(cNewRow))
			fSeek(nHandle,(nSkip * -1),FS_RELATIVE) //Volta o ponteiro para o início da próxima linha
			cRow    :=  cNewRow
			Exit
		Endif
	EndDo

Return nRet

***************************
Static Function ExCRLF(c,b)
***************************
	Local cRet := c
	Local nX   := 1
   
	Default b := CRLF
   
	For nX := 1 To Len(b)
		cRet := StrTran(cRet,Substr(b,nX,1))
	Next nX
   
Return cRet

*********************************
Static Function GetLastRec(cFile)
*********************************
	Local nRet    := 0
	Local nHandle := 0
	Local nBuffer := N_BUF_SIZE
	Local cEOL    := C_CRLF
	Local nLenEOL := Len(cEOL)
	Local cRow    := ""
	Local cNewRow := ""
	Local cRead   := Space(nBuffer)
	Local nPosEol := 0
	Local nSkip   := 0

   	nHandle := FOpen(cFile,FO_READ + FO_SHARED)
	If ( nHandle == -1 )
	   MSgInfo("Não foi possivel abrir o arquivo "+CRLF+CRLF+cFile)
	   return 0
	Endif

   //nBufTot := FSeek(nHandle,0,2) // Lê o tamanho do arquivo em Bytes (
	fSeek(nHandle,0,0) // Posiciona no início do arquivo
   
	While (FRead(nHandle,@cRead,nBuffer) > 0) 
		cRow += cRead
		cRead := Space(nBuffer)
		nPosEol := At(cEOL,cRow)
		If (nPosEol != 0)
			nRet++
			cNewRow := Left(cRow,nPosEol - 1)
			nSkip   := Len(cRow) - (nLenEOL + Len(cNewRow))
			fSeek(nHandle,(nSkip * -1),FS_RELATIVE) //Volta o ponteiro para o início da próxima linha
			cRow    :=  ""
		Endif
	EndDo
    
    If nRet > 0
       nRet-- //Retira da contagem a linha do cabeçalho.
    Endif
    
    FClose(nHandle)
        
Return nRet

/////////////////////////////////////////////////////////////////////////
//--Rotinas de Log.
/////////////////////////////////////////////////////////////////////////
/**
 * Retorna o nome do arquivo de Log, conforme a chave (cKeyLog)
 *
 * @author Roberto Amâncio Teixeira
 * @date 27/06/2017
 * 
 * @return caracter
*/ 
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
	Local cGlbVar  := GetGlbValue(GLB_LOG_FILE)
	Local cRet     := cGlbVar
	
	If ( cGlbVar == "" )
	   cRet := Eval(bLogFile)
	   While File(cRet)
		     cRet := Eval(bLogFile)
	   EndDo
       PutGlbValue(GLB_LOG_FILE,cRet)
    Else
       cRet := cGlbVar 
    Endif    
	
return cRet

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
*********************************************
Static Function AddLog(cTypeLog,cMsg,aParams)
*********************************************
	Local cFileLog  := GetFileLog(C_KEYLOG)
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
		nHandle := fOpen(cFileLog,FO_READWRITE)
	Else
		nHandle := fCreate(cFileLog,FC_NORMAL)
	Endif
	
   If nHandle = -1
      MsgStop("Erro ao criar arquivo - ferror " + Str(FError()))
      Return nil
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
***************************************
Static Function AddLogErr(cMsg,aParams)
***************************************
	AddLog("ERR",cMsg,aParams)
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

	AddLog("ERR",Replicate('-',100),Nil)
    For nX := 1 To Len(aMsg)
	    AddLog("ERR",aMsg[nX],aParams)
	Next
	AddLog("ERR",Replicate('-',100),Nil)
	
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
***************************************
Static Function AddLogInf(cMsg,aParams)
***************************************
	AddLog("INF",cMsg,aParams)
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
***************************************
Static Function AddLogWar(cMsg,aParams)
***************************************
	AddLog("WAR",cMsg,aParams)
return nil


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
return "\SIGADOC\CNCTAPKG\LOGS\"

*********************************************
Static Function fMsgError(cMsg,aParams,lBack)
*********************************************
  
	If lBack
		AddLogErr(cMsg,aParams)
	Else
		fMsgStop(cMsg,aParams)
	Endif
   
Return nil

********************************************
Static Function fMsgStop(cMsg,aParams,lBack)
********************************************
	Local cMessage := OemToAnsi(cMsg)
	Local nX       := 0

	Default aParams := {}
	Default lBack   := .F.
   
	For nX := 1 To Len(aParams)
		cMessage := StrTran(cMessage,"{"+cValToChar(nX)+"}",cValToChar(aParams[nX]))
	Next nX

    AddLogErr(cMessage)
   
	If !lBack
	   MsgStop(cMessage)
	Endif
Return nil

//--FIM: Rotinas de Log.   

************************************
Static Function GetUnique(cTabAlias)
************************************
   Local aRet      := {}
   Local cAlias    := GetNextAlias()
   Local cTable    := RetSqlName(cTabAlias)
   Local cQuery    := ""
   Local aEx       := {"R_E_C_D_E_L_","R_E_C_N_O_","D_E_L_E_T_"}
   
   If Empty(cTable)
      return {}
   Endif

   cQuery += "SELECT c.column_name                                                                             " + CRLF
   cQuery += "  FROM sys.all_indexes i, sys.all_ind_columns c                                                  " + CRLF
   cQuery += " WHERE i.table_name  = '"+cTable+"'                                                              " + CRLF
   cQuery += "   AND i.uniqueness  = 'UNIQUE'                                                                  " + CRLF
   cQuery += "   AND i.index_name  = c.index_name                                                              " + CRLF
   cQuery += "   AND i.table_owner = c.table_owner                                                             " + CRLF
   cQuery += "   AND i.table_name  = c.table_name                                                              " + CRLF
   cQuery += "   AND i.owner       = c.index_owner                                                             " + CRLF
   cQuery += "   AND c.index_name IN (SELECT index_name FROM sys.all_ind_columns WHERE column_position = 2)    " + CRLF
   cQuery += "ORDER BY c.column_position                                                                       "     
   
   TCQUERY cQuery NEW ALIAS (cAlias)
   
   While (cAlias)->(!Eof())
         If ( AScan(aEx, {| f | f == AllTrim((cAlias)->column_name) }) == 0 )
            Aadd(aRet,AllTrim((cAlias)->column_name))
         Endif
         (cAlias)->(DbSkip(1))
   EndDo
   
   If (Select(cAlias) > 0) 
      (cAlias)->(DbCloseArea())
   Endif
   
Return aRet


*****************************************
Static function LogSZ3(cCodFil,aLog,cKey)
*****************************************
   Local nSeq    := GetSeqSZ3(SZ2->Z2_UKEY)
   Local cMsg    := StrTran(StrTran(AllTrim(aLog[1]),CHR(13)),CHR(10))
   Local bGetMsg := {|x| cMsg += If( ("ERRO" $ Upper(x)) .OR. ("INVALIDO" $ Upper(x)),StrTran(StrTran(AllTrim(x),CHR(13)),CHR(10)) + CRLF,"") } 
   
   AEval(aLog,bGetMsg)
   
   DbSelectArea("SZ3")
   RecLock("SZ3",.T.)
            SZ3->Z3_FILIAL  := xFilial("SZ3") //cCodFil       
            SZ3->Z3_UKEY    := TabAlias()+"-"+FWTimeStamp(3,Date(),Time())+FWTimeStamp(4,Date(),Time())+Alltrim(Str(nSeq))
            SZ3->Z3_NUMLOTE := SZ2->Z2_NUMLOTE
            SZ3->Z3_DATALOG := dDataBase
            SZ3->Z3_CODTAB  := TabAlias()
            SZ3->Z3_NUMLINH := 0
            SZ3->Z3_SEQLOG  := nSeq
            SZ3->Z3_CODCPO  := C_ROTINA
            SZ3->Z3_DESCPO  := "Rotina automática "+C_ROTINA
            SZ3->Z3_CONTEUD := "BK -> "+cKey
            SZ3->Z3_VALID   := ""
            SZ3->Z3_UKEYP   := SZ2->Z2_UKEY
            SZ3->Z3_CODLOG  := "AUTO"
            SZ3->Z3_DESCLOG := StrTran(StrTran(AllTrim(aLog[1]),CHR(13)),CHR(10))
            SZ3->Z3_TIMSTAM := FWTimeStamp(2,Date(),Time())
            
   SZ3->(MsUnLock())
   
Return nil
   
*********************************
Static Function GetSeqSZ3(cUKEYP)
*********************************
   Local nRet      := 1
   Local cQuery    := "SELECT MAX(Z3_SEQLOG) SEQLOG FROM "+RetSqlName("SZ3")+" WHERE Z3_UKEYP='"+cUKEYP+"' AND D_E_L_E_T_=' ' " 
   Local cAliasTmp := GetNextAlias()
   
   TCQUERY cQuery NEW ALIAS (cAliasTmp)
   
   If (cAliasTmp)->(!Eof()) .And. (cAliasTmp)->SEQLOG > 0
      nRet := (cAliasTmp)->SEQLOG + 1
   Endif
   
   If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif
   
return nRet

***********************************************
Static Function SetZVK(aFormulas,aReg,cCodProc)
***********************************************
   Local lRet      := .T.
   Local cQuery    := "" 
   Local cAliasTmp := GetNextAlias()
   Local nPos      := 0
   Local cFormula  := ""
   Local xValue    := nil
   
   If LoadVars(aReg) .And. .Not. Empty(aFormulas)
      lRet := ApplyFormulas(aFormulas,aReg)
      return lRet
   Endif
   
   cQuery += "SELECT ZVK.ZVK_CPOORI, ZVK.ZVK_CPODES      " + CRLF
   cQuery += "FROM "+RetSqlName("ZVK")+" ZVK             " + CRLF
   cQuery += "WHERE ZVK.ZVK_CODEXT = '"+cCodProc+"'      " + CRLF
   cQuery += "AND ZVK.ZVK_CPODES <> ZVK.ZVK_CPOORI       " + CRLF
   cQuery += "AND ZVK.D_E_L_E_T_=' '                     " + CRLF
   cQuery += "ORDER BY ZVK.ZVK_SEQ                       " + CRLF
   
   TCQUERY cQuery NEW ALIAS (cAliasTmp)
   
   /*
   If (cAliasTmp)->(!Eof())
      If ! LoadVars(aReg) //Carrega aReg nas variáveis MEMVAR (M->NOM_VARIÁVEL)
         If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif
         Return .F.
      Endif
   Endif
   */
   
   While (cAliasTmp)->(!Eof())
         
        nPos := AScan(aReg,{|x| x[1] == AllTrim((cAliasTmp)->ZVK_CPODES)})
        If ( nPos == 0 ) 
           (cAliasTmp)->(DbSkip(1))
           Loop
        Endif
        
        Aadd(aFormulas,{AllTrim((cAliasTmp)->ZVK_CPODES),AllTrim((cAliasTmp)->ZVK_CPOORI)})

        (cAliasTmp)->(DbSkip(1))
   EndDo

   If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif
   
   If ! Empty(aFormulas)
      lRet := ApplyFormulas(aFormulas,aReg)
   Endif
   
Return lRet

*********************************************
Static Function ApplyFormulas(aFormulas,aReg)
*********************************************
   Local lRet      := .T.
   Local lSuccess  := .T.
   Local nLenForm  := Len(aFormulas)
   Local nPos      := 0
   Local nX        := 0
   Local xValue    := nil
   
   For nX := 1 To nLenForm
        nPos := AScan(aReg,{|x| x[1] == aFormulas[nX,1]})
        If ( nPos == 0 ) 
           Loop
        Endif
        
        lSuccess := ExFormula(aFormulas[nX,1],aFormulas[nX,2], @xValue)
        
        If lSuccess
           aReg[nPos,2] := xValue
        Else
           lRet := .F. //Aplica todas as fórmulas ao registro, mas o invalida se uma delas falhar...
        Endif
   Next nX
   
Return lRet    

***************************************************
Static Function ExFormula( cTarget, cForm, xValue )
***************************************************
   Local lRet   := .F.
   Local cField := AllTrim(cTarget)
   Local aField := TamSx3(cField) 

   TRYEXCEPTION       
       
       xValue := &cForm
       
       If ( lRet := ( ValType(xValue) == aField[3] ) )
          If ( ValType(xValue) == "C" )
             xValue := PadR(xValue,aField[1])          
          Endif
       Else
          AddLogErr(Replicate('-',100))
          AddLogErr('Campo destino "{1}" aguarda um valor do tipo "{2}".'+CRLF+'O tipo retornado pela fórmula é "{3}".', {cField,aField[3],ValType(xValue)})
          AddLogErr(Replicate('-',100))
       Endif
       
   CATCHEXCEPTION USING oException
       IF ( ValType( oException ) == "O" )
          AddLogErr(Replicate('-',100))
          AddLogErr('Campo destino "{1}", erro ao compilar a fórmula:'+CRLF+'-> {2}'+CRLF+'-> {3}', {cField,chr(9)+cForm,chr(9)+oException:DESCRIPTION})
          AddLogErr(Replicate('-',100))
          oException := nil
       EndIF	                     
   ENDEXCEPTION	
   
Return lRet

******************************
Static Function LoadVars(aReg)
******************************
   Local nPos      := 0
   Local lRet      := .T.
   Local cField    := ""
   Local xValor    := nil
   Local nX        := 0
   Local aAreaSx3  := SX3->(GetArea())
   Local cAlias    := TabAlias() 
   
   SX3->(DbSetOrder(1))
   If ! SX3->(MsSeek(cAlias))
      SX3->(RestArea(aAreaSx3))
      return .F.
   Endif
   
   While ( SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias)
        
        If (SX3->X3_CONTEXT == "V")
           SX3->(DbSkip(1))
           Loop
        Endif

        cField := AllTrim(SX3->X3_CAMPO)
        
        nPos := AScan(aReg,{|x| x[1] == cField})
        
        If ( nPos == 0 )
           xValue := CriaVar(cField)          
        Else
           xValue := aReg[nPos,2]
        Endif
        
        If Type("M->"+cField)=='U'
           _SetOwnerPrvt(cField,xValue) 
        Else
           &("M->"+cField) := xValue
        EndIf
        
        SX3->(DbSkip(1))
   EndDo
   
   SX3->(RestArea(aAreaSx3)) 

Return lRet   
   

********************************
Static Function TabAlias(cAlias)
********************************
	Local cRet     := cAlias
	
	Default cAlias := ""
	
	If Empty(cAlias)
	   cRet := GetGlbValue(GLB_TAB_ALIAS)
	Else
       PutGlbValue(GLB_TAB_ALIAS,cRet)
	Endif
      
Return cRet

*********************************
Static Function Inc(cGlbKey,nInc)
*********************************
   Local cValue := 	AllTrim(GetGlbValue(cGlbKey))
   Local nRet   := 0

   Default nInc   := 1
   
   If cValue == ""
      nRet := nInc
   Else
      nRet := GetDtoVal(cValue) + nInc
   Endif
   
   SetGlb(cGlbKey,cValToChar(nRet))
   
return nRet

**************************************
Static Function SetGlb(cGlbKey,xValue)
**************************************
   PutGlbValue(cGlbKey,cValToChar(xValue))
Return nil

*******************************
Static Function GetNum(cGlbKey)
*******************************
   Local cValue := GetGlbValue(cGlbKey)
   Local nRet   := 0
   
   If cValue != ""
      nRet := GetDtoVal(cValue)
   Endif
   
Return nRet

***************************
Static Function GetLogURI()
***************************
   Local cRet      := "file:{1}{2}"
   Local cIp       := StrTran( Alltrim(SuperGetMV('MV_XIMPIP',,'')),"\","/") 
   Local cFileLog  := StrTran( GetFileLog(C_KEYLOG) ,"\","/")
   
   cRet := FmtStr(cRet,{ cIp, cFileLog })
Return cRet   
   
**********************************
Static Function FmtStr(cCmd,aArgs)
**********************************
   Local nX   := 0
   Local cRet := cCmd
   For nX := 1 To Len(aArgs)
       cRet := StrTran(cRet,"{"+cValToChar(nX)+"}",cValToChar(aArgs[nX]))
   Next nX
Return cRet   

**************************************
Static Function GetForn(cCodigo,cLoja)
**************************************
   Local cRet      := ""
   Local cQuery    := "SELECT GetDeParaForn('"+cCodigo+"','"+cLoja+"') CODIGO FROM DUAL" 
   Local cAliasTmp := GetNextAlias()
   
   TCQUERY cQuery NEW ALIAS (cAliasTmp)
   
   If (cAliasTmp)->(!Eof()) //.And. .Not. ( "?_" $ (cAliasTmp)->CODIGO )
      cRet := AllTrim( (cAliasTmp)->CODIGO )
   Endif
   
   If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif
   
Return cRet

*********************************
Static Function GetTitPai(cValue)
*********************************
   Local cRet  := AllTrim(cValue)
   Local cForn := ""
   
   If Empty(cRet) .OR. ( Len(cRet) < 24 )
      Return cRet
   Endif

   cForn := GetForn(Substr(cRet,17,6),Substr(cRet,23,2))
   
   If ( "?_" $ cForn ) .OR. Empty(cForn )
      UserException(FmtStr('Erro durante o De-Para de fornecedor! Código "{1}".', {cForn}))
   Endif  
   
   cForn := cForn + "01" //Concatena o código do fornecedor com a loja.
   
   cRet := Stuff(cRet,17,Len(cForn)) 
   
Return cRet        
   
