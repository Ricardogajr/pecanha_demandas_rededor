#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"           
#INCLUDE "TRYEXCEPTION.CH"
#include "fileio.ch"
#include "Directry.ch"

#DEFINE	DBS_NAME  1
#DEFINE	DBS_TYPE  2
#DEFINE	DBS_LEN   3
#DEFINE	DBS_DEC   4

#DEFINE SRV_APPROOT "\SIGADOC\KITMIGRACAO\"

***************************************************
Static Function fQryStruct(cQuery,aFields,cSaveAlias)
*****************************************************
   Local cAlias := GetNextAlias()
   Local lRet := .T.                
   Local lSaveAlias := (ValType(cSaveAlias) == "C")

   TRYEXCEPTION
      
      TCQUERY cQuery NEW ALIAS (cAlias)
      
      aFields := (cAlias)->(DBSTRUCT())
            
      If (lSaveAlias)
         cSaveAlias := cAlias
      Else
         (cAlias)->(dbCloseArea())
      Endif
      
   CATCHEXCEPTION USING oException
   	   IF ( ValType( oException ) == "O" )
   	      Alert(oException:DESCRIPTION)
   	      oException := nil
   	      lRet := .F.
   	   EndIF	                     
   ENDEXCEPTION	
   
Return lRet

/*********************************************/
Static Function Betwn(xVar,xValue1,xValue2)
/*********************************************/
Return (xVar >= xValue1 .AND. xVar <= xValue2)

*******************************************
User Function GetDir(nDir)
// 100 == Path relativo no server
// 200 == Path absoluto no server
// 300 == Path absoluto no remote (__RootClt)
// 00 -> "\SIGADOC\KITMIGRACAO\"
// 01 -> "\SIGADOC\KITMIGRACAO\ORIGEM\"
// 02 -> "\SIGADOC\KITMIGRACAO\LOGS\"
// 03 -> "\SIGADOC\KITMIGRACAO\TEMP\"
*******************************************
   Local cRootMigra  := SUBSTR(SRV_APPROOT,2) //SRV_APPROOT sem a primeira barra "\"
   Local cRootPath   := cRootMigra 
   Local cRet        := ""
   
   Do Case
      Case Betwn(nDir,200,299)
           cRootPath := GetSrvProfString("ROOTPATH","")
           If ( Substr(cRootPath,Len(cRootPath),1) != "\" )
              cRootPath += "\"
           Endif
           cRootPath += cRootMigra
      Case Betwn(nDir,300,399)
           cRootPath := __RootClt
   EndCase
   
   If (AT(":",cRootPath) == 0) .And. ( Substr(cRootPath,1,1) != "\" )
      cRootPath := "\" + cRootPath
   Endif
   
   Do Case
         Case ( Mod(nDir,100) == 1 )
              cRet := cRootPath + "ORIGEM\"
         Case ( Mod(nDir,100) == 2 )
              cRet := cRootPath + "LOGS\"
         Case ( Mod(nDir,100) == 3 )
              cRet := cRootPath + "TEMP\"
         Otherwise 
              cRet := cRootPath
   EndCase 
   
   If ! U_fMkWrkDir(cRet)
      MsgStop("Não foi possível criar o diretório: "+CRLF+cRet+CRLF+CRLF+CValToChar(fError()))
      Return cRet
   Endif
   
   cRet := AllTrim(cRet)
   
   If ( Substr(cRet,Len(cRet),1) != "\" )
      cRet += "\"
   Endif

Return cRet

*******************************
User Function fMkWrkDir(cDir)
*******************************
   Local lRet := .T.
   
   cDir := U_PathRelat(cDir)

   If ! ExistDir( cDir )
      lRet := FWMakeDir(cDir,.F.)
   Endif

   If !lRet
      //MsErro( "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) )
   EndIf
   
Return lRet
                                                   

*******************************
Static Function GetParams(cSql)
*******************************
   Local aRet     := {}
   Local aParams  := {}
   Local cParam   := ""
   Local cField   := ""
   Local cDelim1  := ":"
   Local cDelim2  := chr(32)
   Local nX       := 0
   Local nSize    := 10
   Local aAreaSx3 := SX3->(GetArea())
  
   cSql := AllTrim(cSql)+chr(32)
   cSql := StrTran(StrTran(cSql,chr(13),chr(32)),chr(10),chr(32))
   
   While (AT(cDelim1,cSql) > 0)
         cParam := Substr(cSql,AT(cDelim1,cSql),AT(cDelim2,Substr(cSql,AT(cDelim1,cSql)))-1)
         cSql   := StrTran(cSql,cParam,"")
         
         Aadd(aParams,cParam) //Acrescenta o nome do campo correspondente ao parâmetro.
   Enddo
   
   If Empty(aParams)
      Return {}
   Endif
   
   SX3->(DbSetOrder(2)) //X3_CAMPO
   
   For nX := 1 To Len(aParams)
       cParam := aParams[nX]
       cField := Substr(aParams[nX],2)
       If ( AT("__",cField) > 0 )
          cField := Substr(cField,1,AT("__",cField)-1)
       Endif
       cField := PadR(cField,nSize)
       If SX3->(dbSeek(cField))
          Aadd(aRet,{cParam,cField,X3DescriC(),;
                     GetSx3Cache( cField ,"X3_TIPO"),;
                     GetSx3Cache( cField ,"X3_PICTURE"),;
                     GetSx3Cache( cField ,"X3_F3"),;
                     GetSx3Cache( cField ,"X3_TAMANHO"),;
                     GetSx3Cache( cField ,"X3_DECIMAL"),""})
       Else
          MsgStop(StrTran('Parâmetro "{1}" é inválido! Verifique.',"{1}",cParam))
       //   Aadd(aRet,{cParam,"",PadR("<<< Descrição >>>",25),"C"         ,""             ,""        ,020            ,000            }) 
       Endif
   Next nX
   
   AEval(aRet,{|a| a[3] := AllTrim(a[3]), a[5] := AllTrim(a[5]), a[6] := AllTrim(a[6])})  
   aSort( aRet,,, { |x,y| x[1] < y[1] } )
   
   SX3->(RestArea(aAreaSx3))
   
return aRet   
   

****************************
Static function GetTmpPath()
****************************
   Local cRet   := ""
   
   cRet := GetEnvLocal("USERPROFILE")
  
   If ! Empty(cRet) .And. ( Right(cRet,1) != "\" )
      cRet += "\"
   Endif
   
   If ! U_fExistDir( cRet ) .And. ! U_fMkWrkDir(cRet)
      MsgStop("Não foi possível criar o diretório: "+CRLF+cRet+CRLF+CRLF+fError())
   Endif
  
return cRet

*****************************
User function GetTmpMigra()
*****************************
   Local cRet   := ""
   
   cRet := U_GetDir(203)
   
   If ! Empty(cRet) .And. ( Right(cRet,1) != "\" )
      cRet += "\"
   Endif
   
   //cRet += "migra\"
   
   If ! U_fExistDir( cRet ) .And. ! U_fMkWrkDir(cRet)
      MsgStop("Não foi possível criar o diretório: "+CRLF+cRet+CRLF+CRLF+fError())
   Endif
  
return cRet

*************************************************
User Function PathRelat(cPath,cStart,lOnlyPath)
*************************************************
   Local cRet   := cPath
   Local nStart := 0 

   Default cStart    := SRV_APPROOT
   Default lOnlyPath := .T.
   
   nStart := AT(Upper(cStart),Upper(cRet))

   cRet := Substr(cRet,nStart)   
   
   If lOnlyPath
      cRet   := Substr(cRet,1,RAT("\",cRet))
   Endif
   
Return cRet   

*********************************
Static function GetEnvLocal(cVar)
*********************************
   Local cRet     := ""
   Local cPath    := GetTempPath(.T.)
   Local cFileName:= CriaTrab(,.F.)
   Local cTxtTmp  := cPath + cFileName+".txt"
   Local cBatTmp  := cPath + cFileName+".bat"
   Local cCmd     := "SET "+cVar+" > "+cTxtTmp
   Local nHandle  := 0
   Local cRow     := ""
   
   nHandle := U_NewFile(cBatTmp, 0)
   If nHandle == -1
	   MsgStop("O arquivo de nome " + cBatTmp + " nao pode ser criado.")
	   Return ""
   Endif         
   FWrite(nHandle,"@ECHO OFF"      + CRLF)
   FWrite(nHandle,cCmd             + CRLF)
   
   FClose(nHandle)
   
   If File(cBatTmp)
      If ( WaitRun(cBatTmp) == 0 ) 
         If File(cTxtTmp)
            nHandle := U_OpenFile(cTxtTmp,FO_READ)
            If ( GetRow(nHandle,@cRow) > 0 )
               cRet := Substr(cRow,AT("=",cRow)+1)
            Else 
               MsgStop(StrTran('Variável "{1}" não definida no S.O.',"{1}",cVar))
            Endif
            FClose(nHandle)
         Else
            MsgStop("Arquivo de despejo não encontrádo! ("+cTxtTmp+")")
         Endif      
      Else
         MsgStop("Erro durante a execução do arquivo de lote! ("+cBatTmp+")")      
      Endif
   Else
      MsgStop("Arquivo de lote não encontrádo! ("+cBatTmp+")")      
   Endif 
   
   If File(cBatTmp)
      FErase(cBatTmp)
   Endif
   
   If File(cTxtTmp)
      FErase(cTxtTmp)
   Endif
   
Return cRet   
   
   
************************************
Static Function GetRow(nHandle,cRow)
************************************
	Local nBuffer := 1024
	Local cEOL    := CRLF
	Local nRet    := 0
	Local cRead   := Space(nBuffer)
	Local nPosEol := 0
	Local nLoop   := 50
	
	cRow := ""
	
	While (nLoop > 0) .OR. ((nRet += FRead(nHandle,@cRead,nBuffer)) > 0)
	    nLoop-- //Envitar loop infinito... 
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

****************************    
Static Function fTeste(cMsg)
****************************
   MsgAlert(cMsg)
Return nil


********************************************************************
** Configura a conexão com o SGBD utilizado pelo Loader (sqlldr.exe)
User Function SetCfgCnx()
********************************************************************
   Local lRet      := .F.
   Local cParName  := "FS_RDI003"
   Local aParamBox := {}
   Local nFt       := 2.5
   Local aResult   := {}
   Local cValue    := ""
   Local cUsr      := Space(30)
   Local cPwd      := Space(30)
   Local cSrv      := Space(30)
   Local nPos1     := 0
   Local nPos2     := 0
   
   If ! U_RDIBF006(cParName)
      MsgStop(U_FormatStr('O parâmetro "{1}" não encontrado! Verifique.',{cParName}),"Parâmetro")
      Return .F.
   Endif
   
   cValue    := U_GetCnxLdr()
   
   cValue    := AllTrim(StrTran(StrTran(AllTrim(cValue),"sqlldr",''),"SQLLDR",''))
   
   nPos1     := At("/",cValue) 
   nPos2     := RAT("@",cValue)
   If (nPos1 > 0) .And. (nPos2 > 0)
      cUsr := PadR(Substr(cValue,1,nPos1-1),30)
      cPwd := PadR(Substr(cValue,nPos1+1,nPos2-1),30)
      cSrv := PadR(Substr(cValue,nPos2+1,30     ),30)
   Endif
  
   Aadd(aParamBox,{1,"Usuário",cUsr,"",".T.","",".T.",30*nFt,.T.})
   Aadd(aParamBox,{8,"Senha"  ,cPwd,"",".T.","",".T.",30*nFt,.T.})
   Aadd(aParamBox,{1,"Serviço",cSrv,"",".T.","",".T.",30*nFt,.T.})

   If !ParamBox(aParamBox ,"Parâmetros da Conexão",aResult)
      return .F.
   Endif
   
   If ( lRet := MSGYESNO("Confirma os parâmetros digitados?", "Salvando") )
      cValue := U_FormatStr("sqlldr {1}/{2}@{3}",{AllTrim(aResult[1]),AllTrim(aResult[2]),AllTrim(aResult[3])})
      cValue := fRC4Crypt(cValue,,.T.)

      PUTMV(cParName,cValue)
      
      lRet := .T.
   Endif
   
Return lRet

***********************************************
Static Function fRC4Crypt(cValue,cKey,lEncrypt)
***********************************************
  Local cRet := ""
  Local nX   := 0
  Local nLen := 0
  Local cHex := ""
  
  Default cKey := GetEnvServer() //AllTrim(GetEnv("COMPUTERNAME")) + GetEnvServer()
  
  cValue := AllTrim(cValue)
  cKey   := AllTrim(cKey)
  
  If Empty(cValue) .OR. Empty(cKey)
     return ""
  Endif

  nLen := Len(cValue)
  
  If lEncrypt
     cRet := Embaralha(RC4Crypt(cValue,cKey,.T.),0)
  Else
     cRet := ""
     cValue := Embaralha(cValue,1)
     For nX := 1 To nLen Step 2
         cHex := Substr(cValue,nX,2)
         cRet += chr(CTON(cHex, 16))
     Next nX 
     cRet := RC4Crypt(cRet  ,cKey,.F.)
  Endif
  
Return cRet

***********************************
User Function FormatStr(cStr,aArgs)
***********************************
   Local nX   := 0
   Local cRet := cStr
   For nX := 1 To Len(aArgs)
       cRet := StrTran(cRet,"{"+cValToChar(nX)+"}",cValToChar(aArgs[nX]))
   Next nX
Return cRet   

***************************************
** Retorna a string de conexão (sqlldr)
**
User Function GetCnxLdr()
***************************************
   Local cParName := "FS_RDI003"
   Local cRet     := AllTrim(GETMV(cParName))
   
   If Empty(cRet)
      If ! U_RDIBF006(cParName)
         MsgStop(U_FormatStr('Parâmetro "{1}" não definido! Verifique.',{"FS_RDI003"}))
      Endif
      return ""
   Endif
   cRet := fRC4Crypt(cRet,,.F.)
   
   If ( AT("@",cRet) == 0 )
      MsgStop("Erro ao decriptografar a conexão!"+CRLF+CRLF+"Reconfigure este parâmetro e tente novamente.")
      return ""
   Endif
   //FWInputBox("Conexão", cRet)
Return cRet

***************************************************
** Verifica a existência (.T.) do parâmetro em SX6.
**
User Function RDIBF006(cParName)
***************************************************
   Local nSize    := 10
   Local lRet     := .F.
   Local aAreaSx6 := SX6->(GetArea())
   
   SX6->(dbSetOrder(1))
   
   lRet := SX6->(MsSeek(xFilial("SX6") + PADR(cParName,nSize)))
   
   SX6->(RestArea(aAreaSx6))
   
Return lRet

**************************************************
** Exporta um Array para Excel
**
User Function Array2Excel(aHeader,aCols,cTitulo)
**************************************************
   Local aDados      := {}
   Local aRow        := {}
   Local nX := nY    := 0
   Local nHCount     := Len(aHeader)
   Local nDCount     := 0
   Local oFWExcel
   Local oExcel
   Local cFileName   := GetTempPath()+GetNextAlias()+'.xml'
   Local cWorkSheet  := "Resultado"
   
   Static cTitulo    := ""
   
   If (Len(aCols) == 0)
      MsgStop("Não há dados para serem exportados!")
      Return .F.
   Endif
   
   For nY := 1 To Len(aCols)
       
       aRow := Array(nHCount)
       For nX := 1 To nHCount
           If ValType(aCols[nY,nX]) == "C"
              aRow[nX] := CHR(160)+aCols[nY,nX]
           Else
              aRow[nX] := aCols[nX]
           Endif
       Next
   
       Aadd(aDados,aRow)   
   Next

   nDCount := Len(aDados)
   
   oFWExcel := FWMsExcelEx():New()
      
      oFWExcel:AddworkSheet(cWorkSheet)
      
      oFWExcel:AddTable(cWorkSheet,cTitulo)
      
	  For nX := 1 To nHCount
	      oFWExcel:AddColumn(cWorkSheet,cTitulo,aHeader[nX],1,1) 
      Next nX
	  
	  For nX := 1 To nDCount
          oFWExcel:AddRow(cWorkSheet,cTitulo,aDados[nX])
	  Next

    oFWExcel:Activate()
    oFWExcel:GetXMLFile(cFileName)

    oExcel := MsExcel():New()            //Abre uma nova conexão com Excel
    oExcel:WorkBooks:Open(cFileName)     //Abre uma planilha
    oExcel:SetVisible(.T.)               //Visualiza a planilha
    oExcel:Destroy()                     //Encerra o processo do gerenciador de tarefas
    
    If File(cFileName)
       fErase(cFileName)
    Endif
Return .T.


***********************************
User Function SPCompile(cObjName)
***********************************
   Local lRet       := .T.
   Local cCmd       := U_FormatStr("ALTER PROCEDURE {1} COMPILE",{cObjName})
   Local cQuery     := ""
   Local cAliasTmp  := GetNextAlias()
   
   cQuery += "SELECT object_name obj                          " + CRLF
   cQuery += "FROM   dba_objects                              " + CRLF
   cQuery += "WHERE status = 'INVALID'                        " + CRLF
   cQuery += "and owner = (SELECT sys.login_user() FROM DUAL) " + CRLF
   cQuery += "and object_type = 'PROCEDURE'                   " + CRLF
   cQuery += "and OBJECT_NAME = '"+cObjName+"'                " 

   TCQUERY cQuery NEW ALIAS (cAliasTmp)
   
   lRet := (cAliasTmp)->(Eof())
   
   If ! lRet
       If (TCSQLExec(cCmd) < 0)
          MsgStop("Erro ao executar o comando: " +CRLF + cCmd + CRLF + CRLF + TCSQLError())
          lRet := .F.
       Endif
       
       If ( Select(cAliasTmp) > 0 )
          (cAliasTmp)->(DbCloseArea())
       Endif
       
       TCQUERY cQuery NEW ALIAS (cAliasTmp)
       
       lRet := (cAliasTmp)->(Eof())
   Endif
   
   If ( Select(cAliasTmp) > 0 )
      (cAliasTmp)->(DbCloseArea())
   Endif
   
return lRet   

*********************************************
User Function RDIIF001(bAction,cHeader,cText)
*********************************************
   Default cHeader := "Executando..."
   Default cText   := "Aguarde..."

   MsgRun (cText,cHeader,bAction)
   
return nil

****************************************
User Function RDIIF002(cAlias,cFileName)
****************************************
   Local cFile := cDrive := cDir := cNome := cExt := ""
   Local cRet  := U_GetDir(201)
   
   SplitPath( cFileName , @cDrive, @cDir, @cNome, @cExt )
   
   cFile := cNome + cExt
   
   If ( Right(cRet,1) != "\" )
      cRet += "\"
   Endif

   cRet += cAlias + "\" + cFile
    
return cRet

*****************************************
User Function FileInCfg(cFileName,cSub)
*****************************************
   Local cFile := ""
   Local cRet  := U_GetDir(200)
   
   Default cSub := ""
   
   If ( __nLocalLdr != 1 )
      cRet := GetNewPar("FS_RDI004","")
   Endif
   
   cRet := AllTrim(cRet)
   If ( Substr(cRet,Len(cRet),1) != "\" )
      cRet += "\"
   Endif
   
   cFile := U_FileName(cFileName)
   
   If ! Empty(cSub)
      If ( Left(cSub,1) == "\" )
         cSub := Substr(cSub,2)
      Endif
      
      If ( Right(cSub,1) != "\" )
         cSub += "\"
      Endif
   Endif

   cRet += cSub + cFile
    
return cRet

/***********************************************
/* nType: 1=Informação, 2=Aviso, 3=Error
*/
User Function RDIFMsg(cStr,aArgs,nType,cCaption)
************************************************
   Local cMessage := U_FormatStr(cStr,aArgs)
   
   Default nType    := 1 //Informação
   Default cCaption := nil
   
   Do Case
      Case ( nType == 2)
           MsgAlert(cMessage,cCaption)
      Case ( nType == 3)
           MsgStop(cMessage,cCaption)
      Otherwise
           MsgInfo(cMessage,cCaption)
   EndCase
   
Return    

***********************************
Static Function MyWaitRun(cExeName)
***********************************
   Local lRet  := .F.
   Local cPath := U_GetTmpMigra()
   
   If __nLocalLdr == 1
      lRet := WaitRunSrv(cExeName, .T., cPath )
   Else
      lRet := ( WaitRun(cExeName,1) == 0 )
   Endif
   
Return lRet

********************************
User Function RunBat(cFileBat)
********************************
   Local lRet      := .F.
   Local cPath     := U_GetTmpMigra()   
   Local cFileName := cPath + U_FileName(cFileBat)
   
   If __nLocalLdr == 1	
      lRet := WaitRunSrv(cFileName, .T., cPath )
   Else
      lRet := ( WaitRun( U_FileInCfg(cFileName,"\TEMP\") ,1) == 0 )
   Endif
   
Return lRet

****************************************
User Function FileName(cFullName,lExt)
****************************************
   Local cRet := Substr(cFullName,RAT("\",cFullName)+1)
   Local nPos := RAT(".",cRet)
   
   Default lExt := .T.
   
   If ! lExt .And. nPos > 0
      cRet := Left(cRet,nPos-1)
   Endif
   
return cRet

**********************************
Static Function FilePath(FullName)
**********************************
return Substr(cFullName,1,RAT("\",cFullName))


********************************
User Function fExistDir(cPath)
********************************
   Local cAux := U_PathRelat(cPath)
   Local lRet := ExistDir(cAux)
Return lRet   

****************************************   
User Function NewFile(cFileName,nMode)
****************************************
   Local nRet := 0
   
   Default nMode := 0
   
   cFileName := U_PathRelat(cFileName,,.F.)
   nRet      := FCreate(cFileName,nMode)
   
Return nRet

*****************************************   
User Function OpenFile(cFileName,nMode)
*****************************************
   Local nRet := 0
   
   Default nMode := 0
   
   cFileName := U_PathRelat(cFileName,,.F.)
   nRet      := FOpen(cFileName,nMode)
   
Return nRet   

*******************************************************
User Function CopyS2T(aMasks,cPathSrv,cPathClt,lMove)
*******************************************************
   Local lRet      := .F.
   Local aAuxFiles := {}
   Local cMask     := "*"
   Local cFileName := "" 
   Local nY := nX  := 0
   Local cError    := ""
   Local bMsg      := {|| U_FormatStr('Copiando "{1}" para o servidor...',{aAuxFiles[nX,F_NAME]}) }
   Local bExec     := {|| lRet := CpyS2T(cFileName,cPathClt,.T.) } 
   Local cDrive    := ""
   Local cUnidades := "A:B:C:D:E:F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z:"
   Local cCaption  := "CopyS2T"
   
   Default cPathClt := __RootClt + If(Right(__RootClt,1)!="\","\","") + "TEMP\"  
   Default lMove    := .F.
   
   cDrive := Upper(Left(cPathClt,AT(":",cPathClt)))
   If ! ( cDrive $ cUnidades )
      U_RDIFMsg('O parâmetro "FS_RDI005" não possui uma unidade lógica válida!'+CRLF+'"{1}"',{cPathClt},3,cCaption)
	  Return .F.
   Endif
   
   If ( Right(cPathSrv,Len(cPathSrv)) != "\" )
      cPathSrv += "\"
   Endif
   
   For nY := 1 To Len(aMasks)
       
	   cMask := aMasks[nY]
	   
       aAuxFiles := Directory(cPathSrv + cMask)
       For nX := 1 To Len(aAuxFiles)
           cFileName := cPathSrv + aAuxFiles[nX,1]
           MsgRun ( Eval(bMsg), "Aguarde...", bExec )
           If ! lRet
              cError := cValToChar(FError())
              U_RDIFMsg('Não foi possível copiar o arquivo "{1}" do servidor. {2}',{cFileName,CRLF+CRLF+cError},3,cCaption)
              Exit
           Endif
       Next nX
   Next nY
   
Return lRet

**************************************
User Function MoveRead(aFiles,cLote)
**************************************
   Local cPath     := U_PathRelat(aFiles[1,6])
   Local cDest     := "LIDOS\Lote_"+cLote+"_"+Dtos(dDataBase)+"_"+Replace(Time(),':',"")+"\"
   Local nX        := 0
   
   cPath += cDest
   
   If ! U_fMkWrkDir(cPath)
      Return .F.
   Endif 
   
   For nX := 1 To Len(aFiles)
       If __CopyFile(aFiles[1,6], cPath + aFiles[1,1] )
          fErase(aFiles[1,6])
       Endif
   Next nX
   
return .T.   

*******************************************
User Function NextNum(cAlias,cField,lSum)
*******************************************
   Local nTamFld    := TamSx3(cField)[1]
   Local cRet       := Replicate("0",nTamFld)
   Local cQuery     := ""
   Local cAliasTmp  := GetNextAlias()
   
   Default lSum := .T.

   If ( Select(cAliasTmp) > 0 )
      (cAliasTmp)->(DbCloseArea())
   Endif
   
   cQuery := U_FormatStr("SELECT MAX({1}) RESULT FROM {2} WHERE D_E_L_E_T_=' '",{cField,RetSqlName(cAlias)})

   TCQUERY cQuery NEW ALIAS (cAliasTmp)
   
   If (cAliasTmp)->(!Eof())
      cRet := (cAliasTmp)->RESULT
   Endif
   
   If lSum
      cRet := Soma1(cRet)
   Endif

   If ( Select(cAliasTmp) > 0 )
      (cAliasTmp)->(DbCloseArea())
   Endif
   
Return cRet   

*************************************
User Function EraseAll(cPath,cMask)
*************************************
   Local lRet   := .T.
   Local aFiles := {}
   Local nX     := 0
   
   
   If ! Empty(cPath) .And. ( Right(cPath,1) != "\" )
      cPath += "\"
   Endif
   
   aFiles := Directory(cPath + cMask)
   
   For nX := 1 To Len(aFiles)
       lRet := (FErase(cPath + aFiles[nX,1]) == 0)
       If ! lRet
          Exit
       Endif
   Next nX

Return lRet   

***************************
User Function AjustLote()
***************************
   Local nRet      := 1
   Local cQuery    := ""
   Local cAliasTmp := GetNextAlias()
   Local nLoteAt   := GetNewPar('FS_RDI002',0)
   
   cQuery += "SELECT MAX(TO_NUMBER(QZ3.QZ3_NUMLOT)) LOTE FROM QZ3010 QZ3 WHERE QZ3.D_E_L_E_T_=' '"
   
   TCQUERY cQuery NEW ALIAS (cAliasTmp)
   
   If (cAliasTmp)->(!Eof())
      nRet := (cAliasTmp)->LOTE
   Endif
   
   If ( nLoteAt < nRet )
      PutMv("FS_RDI002",++nRet)
   Else 
      nRet := nLoteAt
   Endif

   If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif
   
return nRet

********************************
Static Function AlsExist(cAlias)
********************************
   Local lRet := .F.
   
   lRet := SX2->( dbSeek( cAlias ) )
   
Return lRet
