#INCLUDE "PROTHEUS.CH"
#INCLUDE "TRYEXCEPTION.CH"
#include "fileio.ch"

#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH" 
 

#DEFINE	DBS_NAME  1
#DEFINE	DBS_TYPE  2
#DEFINE	DBS_LEN   3
#DEFINE	DBS_DEC   4

***************************************************
User Function fQryStruct(cQuery,aFields,cSaveAlias)
***************************************************
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

**********************************
User Function GetDir(nDir)                     
// 0 = WorkDir ("\CNCTAEXP\")
// 1 = Default ("\CNCTAEXP\Default\")
// 2 = ZipDir ("\CNCTAEXP\zip\")
// 3 = DirRmt ("C:\CNCTAEXP\exp")
**********************************
  //Local cRootPath := GetSrvProfString ("ROOTPATH","")
  Local cRootPath   := "\sigadoc\"
  Local cRet        := ""

  If (AT(":",cRootPath) > 0)
     cRootPath := Substr(cRootPath,AT(":",cRootPath)+1)
  Endif
  
   Do Case
         Case (nDir == 0) 
              cRet := cRootPath + "CNCTAEXP\"
         Case (nDir == 1)
              cRet := cRootPath + "CNCTAEXP\DEFAULT\"
         Otherwise 
              cRet := cRootPath
   EndCase 
                               
   If !U_fMkWrkDir(cRet)
      cRet := cRootPath
   Endif
   
   cRet := AllTrim(cRet)
   
   If ( Substr(cRet,Len(cRet),1) != "\" )
      cRet += "\"
   Endif

Return cRet

************************************************
User Function fMkWrkDir(cDir)
************************************************
   Local lRet := .T.

   If !ExistDir ( cDir )
      lRet := FWMakeDir(cDir,.F.)
   Endif

   If !lRet
      //MsErro( "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) )
   EndIf
Return lRet
                                                   


**************************
User Function GetProcess()
**************************
	Local aFiles := DIRECTORY(U_GetDir(0) + "*.xml")  
	Local nX := 0, nT := Len(aFiles)    
	Local cFile := ""
	Local oXml := nil
	Local cError := cWarning := "" 
	Local aRet := {}  
	Local objPkg := Nil

 	aRet := {}
 
 	For nX := 1 To nT
		oXml := U_GetObjXML(aFiles[nX,1])
      If (ValType(oXml) == "O")

         objPkg := Package():New(;
		      FileNoExt(oXml:_Package:_Name:Text),;
			   oXml:_Package:_Description:Text,;
			   oXml:_Package:_Select:Text,;
			   oXml:_Package:_Bk:Text,;
			   oXml:_Package:_Target:Text)
         
		   AADD(aRet,{objPkg:cName,objPkg:cDescription,objPkg:cSelect,objPkg:cBk,objPkg:cTarget})
	      FreeObj(oXml)
		Endif
	Next nX  
	                   
Return aRet

************************************************
User Function GetObjXML(cFileName)       
************************************************                       
   Local cDir     := U_GetDir(0) //WorkDir
   Local cFile    := cDir + cFileName
   Local cError   := ""
   Local cWarning := ""
   Local oRetXml  := Iif(File(cFile),XmlParserFile(cFile, "", @cError, @cWarning),nil)
   
   If ((cError <> "") .OR. (cWarning <> ""))
      MsgStop("Erro: " + cError + " Aviso:" + cWarning,"Erro XML")
   Endif
Return oRetXml

************************************************************************************
*************************************************
CLASS Package                                    
*************************************************

// Declaracao das propriedades da Classe
DATA cName as String
DATA cDescription as String
DATA cSelect as String
DATA cBk as String
DATA cTarget as String

// Declaração dos Métodos da Classe
METHOD New(cPkgName, cDesc, cSel, cKey, cTar) CONSTRUCTOR

ENDCLASS

// Criação do construtor, onde atribuimos os valores default 
// para as propriedades e retornamos Self
METHOD New(cPkgName, cDesc, cSel, cKey, cTar) Class Package
  	::cName 		    := cPkgName
   ::cDescription  := cDesc
   ::cSelect 		 := cSel
	::cBk			    := cKey
	::cTarget 		 := cTar
Return Self

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
   Local nSize    := Len(SX3->X3_CAMPO)
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
          Aadd(aRet,{cParam,cField,X3DescriC(),SX3->X3_TIPO,SX3->X3_PICTURE,SX3->X3_F3,SX3->X3_TAMANHO,SX3->X3_DECIMAL,""})
       Else
          MsgStop(StrTran('Parâmetro "{1}" é inválido! Verifique.',"{1}",cParam))
       Endif
   Next nX
   
   AEval(aRet,{|a| a[3] := AllTrim(a[3]), a[5] := AllTrim(a[5]), a[6] := AllTrim(a[6])})  
   aSort( aRet,,, { |x,y| x[1] < y[1] } )
   
   SX3->(RestArea(aAreaSx3))
   
return aRet   
   

***********************************
User Function WaitEx(cCmd,cAppName)
***********************************
   Local lRet
   
   
return lRet   

********************************
User function GetTmpPath(lLocal)
********************************
  Local cRet := ""
  
  Default lLocal := .T.
  
  cRet := U_GetEnvLocal("USERPROFILE") + "\"
  
return cRet


*******************************
User function GetEnvLocal(cVar)
*******************************
   Local cRet     := ""
   Local cPath    := GetTempPath(.T.)
   Local cFileName:= CriaTrab(,.F.)
   Local cTxtTmp  := cPath + cFileName+".txt"
   Local cBatTmp  := cPath + cFileName+".bat"
   Local cCmd     := "SET "+cVar+" > "+cTxtTmp
   Local nHandle  := 0
   Local cRow     := ""
   
   nHandle := fCreate(cBatTmp, 0)
   If nHandle == -1
	   MsgStop("O arquivo de nome " + cBatTmp + " nao pode ser criado.")
	   Return ""
   Endif         
   FWrite(nHandle,"@ECHO OFF"      + CRLF)
   FWrite(nHandle,cCmd             + CRLF)
   
   FClose(nHandle)
   
   If File(cBatTmp)
      If (WaitRun(cBatTmp, 1)==0)
         If File(cTxtTmp)
            nHandle := FOpen(cTxtTmp,FO_READ)
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
   Local cParName  := "MV_XSQLLDR"
   Local aParamBox := {}
   Local nFt       := 2.5
   Local aResult   := {}
   Local cValue    := ""
   Local cUsr      := Space(30)
   Local cPwd      := Space(30)
   Local cSrv      := Space(30)
   Local nPos1     := 0
   Local nPos2     := 0
   
   If ! U_ExistPar(cParName)
      MsgStop(U_FmtStr('O parâmetro "{1}" não encontrado! Verifique.',{cParName}),"Parâmetro")
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
      cValue := U_FmtStr("sqlldr {1}/{2}@{3}",{AllTrim(aResult[1]),AllTrim(aResult[2]),AllTrim(aResult[3])})
      cValue := U_RC4Crypt(cValue,,.T.)

      PUTMV(cParName,cValue)
      
      lRet := .T.
   Endif
   
Return lRet

********************************************
User Function RC4Crypt(cValue,cKey,lEncrypt)
********************************************
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

********************************
User Function FmtStr(cStr,aArgs)
********************************
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
   Local cParName := "MV_XSQLLDR"
   Local cRet     := AllTrim(GETMV(cParName))
   
   If Empty(cRet)
      If ! U_ExistPar(cParName)
         MsgStop(U_FmtStr('Parâmetro "{1}" não definido! Verifique.',{"MV_XSQLLDR"}))
      Endif
      return ""
   Endif
   cRet := U_RC4Crypt(cRet,,.F.)
   
   If ( AT("@",cRet) == 0 )
      MsgStop("Erro ao decriptografar a conexão!"+CRLF+CRLF+"Reconfigure este parâmetro e tente novamente.")
      return ""
   Endif
   
   //FWInputBox("Conexão", cRet)
Return cRet

***************************************************
** Verifica a existência (.T.) do parâmetro em SX6.
**
User Function ExistPar(cParName)
***************************************************
   Local nSize    := Len(SX6->X6_VAR)
   Local lRet     := .F.
   Local aAreaSx6 := SX6->(GetArea())
   
   SX6->(dbSetOrder(1))
   
   lRet := SX6->(MsSeek(xFilial("SX6") + PADR(cParName,nSize)))
   
   SX6->(RestArea(aAreaSx6))
   
Return lRet

*********************************************************************
** Exporta um Grid para Excel, baseando-se no aHeader e aCols deste.
**
User Function Grid2Excel(aHeader,aCols,bTitulo)
*********************************************************************
   Local aCabExcel   := {}
   Local aItensExcel := {}
   Local aItem       := {}
   Local nX := nY    := 0
   
   Static bTitulo := {|| "" }
   
   If (Len(aCols) == 0)
      MsgStop("Não há dados para serem exportados!")
      Return .F.
   Endif
   
   AEval(aHeader,{|x| Aadd(aCabExcel,{x[01],x[08],x[04],x[05]}) })
   
   For nY := 1 To Len(aCols)
       
       aItem := Array(Len(aCabExcel))
       For nX := 1 To Len(aCabExcel)
           If aCabExcel[nX][2] == "C"
              aItem[nX] := CHR(160)+aCols[nY,nX]
           Else
              aItem[nX] := aCols[nY,nX]
           Endif
       Next
   
       Aadd(aItensExcel,aItem)   
   Next

   MsgRun("Exportando os Registros para o Excel...","Aguarde...",;
      {||DlgToExcel({{"GETDADOS",Eval(bTitulo),aCabExcel,aItensExcel}})})
      
Return .T.

************************************************
** Exporta um Array para Excel
**
User Function Array2Excel(aHeader,aCols,bTitulo)
************************************************
   Local aDados      := {}
   Local aItem       := {}
   Local nX := nY    := 0
   
   Static bTitulo := {|| "" }
   
   If (Len(aCols) == 0)
      MsgStop("Não há dados para serem exportados!")
      Return .F.
   Endif
   
   For nY := 1 To Len(aCols)
       
       aItem := Array(Len(aHeader))
       For nX := 1 To Len(aHeader)
           If ValType(aCols[nY,nX]) == "C"
              aItem[nX] := CHR(160)+aCols[nY,nX]
           Else
              aItem[nX] := aCols[nX]
           Endif
       Next
   
       Aadd(aDados,aItem)   
   Next

   MsgRun("Exportando os Registros para o Excel...","Aguarde...",;
      {||DlgToExcel({{"ARRAY",Eval(bTitulo),aHeader,aDados}})})
      
Return .T.

******************************
Static Function ExistTab(cTab)
******************************
   Local cAliasTmp := GetNextAlias()
   Local cQuery    := ""
   Local lRet      := .F.
   
   cQuery += "SELECT 1                   " + CRLF
   cQuery += "FROM user_tables t         " + CRLF
   cQuery += "where t.TABLE_NAME = '{1}' "   
   
   cQuery := StrTran(cQuery,"{1}",cTab)
   
   TCQUERY cQuery NEW ALIAS (cAliasTmp)
   
   lRet := (cAliasTmp)->(!Eof())
   
   If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif
   
Return lRet

***************************
Static Function NewTabMnt()
***************************
   Local cTableName := "CNCTAREC"
   Local lExist     := ExistTab(cTableName)
   Local cCmd       := "CREATE TABLE {1} (ALIAS VARCHAR(3) NOT NULL ENABLE,LOTE INT NOT NULL ENABLE,RECNO INT)"
   
   If lExist
      Return .T.
   Endif

   cCmd := U_FmtStr(cCmd,{cTableName})

   If (TcSQLExec(cCmd) != 0)
      APMsgAlert(AllTrim(TCSQLERROR()),'Não foi possível criar a tabela "'+cTableName+'".')
      Return .F.
   Endif
   
Return .T.

*********************************************
User Function StartMnt(cAlias,nLote,lRefresh)
*********************************************
   Local nSleep     := 5000 //5 Segundos...
   Local cInsert    := "INSERT INTO CNCTAREC (ALIAS,LOTE) VALUES ('{1}',{2})" 
   Local cQuery     := "SELECT 1 FROM CNCTAREC WHERE RECNO IS NULL AND ROWNUM=1 AND ALIAS='{1}' AND LOTE={2}"
   Local cAliasTmp  := GetNextAlias()
   Local nQtd       := 0
   
   Default lRefresh := .F.

   RpcSetType(3)
   RpcSetEnv("01","01")
   
   If ! NewTabMnt()
      APMsgAlert("Monitoramento",U_FmtStr('Não foi possível iniciar o monitoramento do processo "{1}".',{cAlias}))
      Return .F.
   Endif

   cInsert := U_FmtStr(cInsert,{cAlias,nLote})
   cQuery  := U_FmtStr(cQuery ,{cAlias,nLote})

   TCQUERY cQuery NEW ALIAS (cAliasTmp)
   
   If (cAliasTmp)->(Eof())
      If (TcSQLExec(cInsert) != 0)
         APMsgAlert(AllTrim(TCSQLERROR()),'Erro ao inserir na tabela "CNCTAREC".')
         Return .F.
      Endif
   Endif

   If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif
   
   TCQUERY cQuery NEW ALIAS (cAliasTmp)
   
   While (cAliasTmp)->(!Eof())
         
         nQtd++
         
         Sleep(nSleep)
               
         If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif

         TCQUERY cQuery NEW ALIAS (cAliasTmp)
         
         If lRefresh .And. ( nQtd == 2 )
            nQtd := 0
            TCRefresh(cAlias)
            TCRefresh(RetSqlName(cAlias))
         Endif

   EndDo

   If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif
   
   TCRefresh(cAlias)
   TCRefresh(RetSqlName(cAlias))
   
   RpcClearEnv()
   
Return .T.   
   
*******************************************
User Function FinalMnt(cAlias,nLote,nRecno)
*******************************************
    Local cCmd := "UPDATE CNCTAREC SET RECNO={3} WHERE RECNO IS NULL AND ALIAS='{1}' AND LOTE={2}"
    
    Default nRecno := -1

    cCmd  := U_FmtStr(cCmd,{cAlias,nLote,nRecno})

    If (TcSQLExec(cCmd) != 0)
       APMsgAlert(AllTrim(TCSQLERROR()),'Erro ao finalizar monitoramento (FinalMnt).')
       Return .F.
    Endif
   
   TCRefresh(cAlias)
   TCRefresh(RetSqlName(cAlias))
   
Return .T.
   
**********************************************
Static Function EnableTrig(cTableName,lEnable)
**********************************************
   Local cAlias := GetNextAlias()
   Local cQuery := ""
   Local cEnable:= If(lEnable,"enable","disable")
   
   cQuery += "select 'alter trigger '||t.table_owner||'.'||t.trigger_name||' {1}' SCRIPT     " + CRLF
   cQuery += "from USER_TRIGGERS t                                                            " + CRLF
   cQuery += "where t.base_object_type = 'TABLE'                                              " + CRLF
   cQuery += "AND t.table_name = '{2}'                                                        " + CRLF
   cQuery += "ORDER BY t.table_name                                                           "
   
   cQuery := u_FmtStr(cQuery,{cEnable,cTableName})

   TCQUERY cQuery NEW ALIAS (cAlias)
   
   While (cAlias)->(!Eof())
       cScript := AllTrim( (cAlias)->SCRIPT )
       If (TCSQLExec(cScript) < 0) 
          Aviso('Erro ao executar o script!',TCSQLError(),{"Fechar"},3)
       Endif
       (cAlias)->(DbSkip(1))
   Enddo
   
   If Select(cAlias) > 0   ; (cAlias)->(DbCloseArea()) ; Endif

return 

****************************************
Static Function FileName(cFullName,lExt)
****************************************
   Local cDrive, cDir, cArq, cExt
   Local cRet := ""
   
   Default lExt := .T.

   SplitPath( cFullName, @cDrive, @cDir, @cArq, @cExt )
   
   cRet := cArq + If(lExt,cExt,"")

Return cRet   
