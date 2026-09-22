#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "xmlxfun.ch"
#include "TCBROWSE.CH"
#Include "TopConn.ch"
#include "fileio.ch"
#INCLUDE "TRYEXCEPTION.CH" 

#DEFINE F_NAME 	1	
#DEFINE F_SIZE 	2	
#DEFINE F_DATE 	3	
#DEFINE F_TIME 	4	
#DEFINE F_ATT  	5

#DEFINE N_FL_PACK		03
#DEFINE N_FL_FILIAL		04
#DEFINE N_FL_CONFIG		05


#DEFINE C_OPEN_MACRO	"{"
#DEFINE C_CLOS_MACRO	"}"

#DEFINE N_CNT_FLUSH 10000

#DEFINE C_CD_NEW "<< NOVO >>"
#DEFINE C_DS_NEW C_CD_NEW + '=Novo pacote.'

#DEFINE C_KEYLOG	"CNCTAPKG"
#DEFINE N_LOG_LH	120
#DEFINE C_LOG_LHT   "@"
#DEFINE C_LOG_LHB   "#" 


User Function CNCTAPKG() 
	WizCfgParam()
Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} 
Função que monta as etapas doWizard de Configurações  

@author Roberto Amâncio Teixeira (robertosiga@gmail.com)
@since 23/08/2019	
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function WizCfgParam() 
	Local oWizard
	Local bValid        := {|| fWzValid() }
	Local bInit         := {|| .T. }
	Local bWhen         := {|| .T. }
	
	Local bNextPack     := {|| VldPgPkg() }
	
	Local aHEmp         := {" ","Empresa","Filial","Descrição"}
	Local aSEmp         := {006,020,020,040}

    Local bChkAllEmp    := {|| ChkAllEmp(lChkAllEmp) }
    Local nColPos       := 0
    
    Private cFileLog    := ""
	
	Private cWorkDir    := U_GetDir(0)
	Private cXmlPkg     := ""
	Private oXmlPkg     := nil
	Private aFilesPkg   := {}
	Private aPackages   := {}
	Private aParValues  := {}
    Private bEditPar    := {|| EditParam()}
    Private aBrwEmp     := {}
    Private oCmbPkg     := nil     	
	Private lNewPkg     := .T.
	Private aCposINI[3]
	Private cAliasPkg   := GetNextAlias()
    Private cFilePkg    := ""
	Private oPanel    

    Private lChkSalvar  := .T.
    Private lChkExec    := .T.
    Private lChkDelet   := .F.
    Private lChkAllEmp  := .F.
    
    Private oChecked    := LoadBitMap(GetResources(),"LBOK")
    Private oUnChecked  := LoadBitMap(GetResources(),"LBNO")
    Private oImgR       := LoadBitMap(GetResources(),"BR_VERMELHO .PNG")
    Private oImgG       := LoadBitMap(GetResources(),"BR_VERDE .PNG")
    Private oImgW       := LoadBitMap(GetResources(),"BR_BRANCO.PNG") //BSTART.PNG,FWLGN_CHK_CKD.PNG
    
    Private bColChk     := {|| IF((cAliasPkg)->CHECK,oChecked,oUnChecked) }
    Private bColPar     := {|| IF((cAliasPkg)->PARAMS == 0,oImgW,If((cAliasPkg)->PARAMS == 1,oImgR,oImgG)) }

    Private bChkPkg     := {||DblClkPkg(.F.)}
    Private bChkEmp     := {||DblClkEmp(.F.)}
    
    Private oGetTEmp    := nil
    Private nGetTEmp    := 0
    
    Private aGetFields  := {}
    
	Init()
	
	oWizard := APWizard():New(OemToAnsi("Assistente de Exportação"),OemToAnsi("Assistente de configuração de pacotes de exportação."),;
												OemToAnsi("Assistente de Exportação"),;
												OemToAnsi("Este assistente o auxiliará na configuração de um pacote de exportação de dados."),{||.T.},{||.T.},.F.)

	oWizard:NewPanel(OemToAnsi("Seleção do Pacote"),OemToAnsi("Informe o pacote de exportação a ser configurado."),{||.T.},{||.T.},{||.T.},.T.,{||fMontaIni(@oWizard)})

	oWizard:NewPanel(OemToAnsi("Pacotes de Exportação"),OemToAnsi("Selecione os pacotes que serão executados."),{||.T.},bNextPack,{||.T.},.T.,{||.T.})
	
      oPnl1Bottom := TPanel():New(00,00,,oWizard:oMPanel[N_FL_PACK],,.T.,,,,000,22)
      oPnl1Bottom :Align := CONTROL_ALIGN_BOTTOM       

      oBrwPkg:=TcBrowse():New(0,0,0,0,,,,oWizard:oMPanel[N_FL_PACK],,,,,,,,,,,,.F.,cAliasPkg,.T.,,.F.,,,.F.)

         oBrwPkg:AddColumn(TCColumn():New("   "       ,bColChk                 ,"",,,"CENTER" ,CalcFieldSize("L",020,0,"@!","   ")      ,.T.,.F.,,,,.F.)) 
         oBrwPkg:AddColumn(TCColumn():New("Parâmetro" ,bColPar                 ,"",,,"CENTER" ,CalcFieldSize("L",020,0,"@!","Parâmetro"),.T.,.F.,,,,.F.)) 
         oBrwPkg:AddColumn(TCColumn():New("Alias"     ,{||(cAliasPkg)->ALS    },"",,,"CENTER" ,CalcFieldSize("C",003,0,"@!","Alias")    ,.F.,.F.,,,,.F.))
         oBrwPkg:AddColumn(TCColumn():New("Descrição" ,{||(cAliasPkg)->DESCRI },"",,,"LEFT"   ,CalcFieldSize("C",040,0,"@!","Descrição"),.F.,.F.,,,,.F.))
                 
         oBrwPkg:bLDblClick := bChkPkg
         oBrwPkg:Align      := CONTROL_ALIGN_ALLCLIENT
         
         oBrwPkg:SetPopup(Eval({|m|;
            m:Add(TMenuItem():New(oWizard:oMPanel[N_FL_PACK],             ;
            "Editar parâmetro(s)" ,,,,bEditPar,"ALT_CAD"  ,"ALT_CAD"  ,,,,,,,.T.)), ;
         , m },TMenu():New(0,0,0,0,.T.)))

	oWizard:NewPanel(OemToAnsi("Empresas"),OemToAnsi("Selecione as empresas/filiais para a execução."),{||.T.},{||.T.},{||.T.},.T.,{||.T.})

      oPnl1Bottom := TPanel():New(00,00,,oWizard:oMPanel[N_FL_FILIAL],,.T.,,,,000,22)
      oPnl1Bottom :Align := CONTROL_ALIGN_BOTTOM
      
      
      TCheckBox():New((oPnl1Bottom:nTop/2)+08,05,'Marcar/Desmarcar Todos ',bSetGet(lChkAllEmp),oPnl1Bottom,150,050,,bChkAllEmp,;
                                /* oFont */, /* bValid */, /* nClrText */, /* nClrPane */, /* uParam14 */, /* lPixel */, /* cMsg */, /* uParam17 */, /* bWhen */ )
    
      nColPos := 235 //(oPnl1Bottom:nClientWidth - 070)
      oGetTEmp := TGet():New( 001, nColPos, bSetGet(nGetTEmp),oPnl1Bottom, ;
                              060, 010    , "9,999,999",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nGetTEmp",,,,.F.,,,"Quantidade",1 )

      oGetTEmp:Disable()

      oBrwEmp := TcBrowse():New(0 ,0 ,0 ,0 ,,aHEmp,aSEmp,oWizard:oMPanel[N_FL_FILIAL],,,,,,,,,,,,.F.,,.T.,,.F.,,,.F.)
         oBrwEmp:bLDblClick := bChkEmp
         oBrwEmp:SetArray(aBrwEmp)
         oBrwEmp:bLine := {||{ If(aBrwEmp[oBrwEmp:nAt,01],oChecked,oUnChecked),aBrwEmp[oBrwEmp:nAt,02],aBrwEmp[oBrwEmp:nAt,03],aBrwEmp[oBrwEmp:nAt,04] }}
         oBrwEmp:Align      := CONTROL_ALIGN_ALLCLIENT
         
	oWizard:NewPanel(OemToAnsi("Configurações"),OemToAnsi("Configurações do pacote."),{||.T.},{||.T.},{||Exec()},.T.,{||.T.})    

              TCheckBox():New(060,015        ,'Salvar alterações'          ,bSetGet(lChkSalvar),oWizard:oMPanel[N_FL_CONFIG],150,030,,{||.T.},;
                                   /* oFont */, /* bValid */, /* nClrText */, /* nClrPane */, /* uParam14 */, /* lPixel */, /* cMsg */, /* uParam17 */, /* bWhen */ )
              TCheckBox():New(072,15,'Executar'                   ,bSetGet(lChkExec)  ,oWizard:oMPanel[N_FL_CONFIG],150,030,,{|| },;
                                   /* oFont */, /* bValid */, /* nClrText */, /* nClrPane */, /* uParam14 */, /* lPixel */, /* cMsg */, /* uParam17 */, /* bWhen */ )
              TCheckBox():New(084,15,'Excluir arquivos anteriores',bSetGet(lChkDelet) ,oWizard:oMPanel[N_FL_CONFIG],150,030,,{|| },;
                                   /* oFont */, /* bValid */, /* nClrText */, /* nClrPane */, /* uParam14 */, /* lPixel */, /* cMsg */, /* uParam17 */, /* bWhen */ )


	oWizard:Activate(.T.,bValid,bInit,bWhen)	
	
Return Nil

**************************
Static Function Finalize()
**************************
   If (Select(cAliasPkg) > 0)
      (cAliasPkg)->(dbclosearea())
      /*If File(cFilePkg + GetDBExtension())
         FErase(cFilePkg + GetDBExtension())
      Endif*/
	  oTempTable:Delete()
   Endif
Return .T.   

**********************************
Static Function fGetXML(cFileName)       
**********************************                       
   Local cFile    := Iif(!Empty(cFileName),cFileName,cWorkDir + cXmlPkg)
   Local cError   := ""
   Local cWarning := ""
   Local oRetXml  := Iif(File(cFile),XmlParserFile(cFile, "", @cError, @cWarning),nil)
   
   If ((cError <> "") .OR. (cWarning <> ""))
      MsgStop("Erro: " + cError + " Aviso:" + cWarning,"Erro XML")
   Endif
Return oRetXml

**************************
Static Function Init() //Before Show
**************************
   Local aEmps := {}
   
   If Empty(aBrwEmp)
      aEmps := FWLoadSM0()
      AEval(aEmps,{|e| Aadd(aBrwEmp,{ .F.,e[1],e[2],e[7] }) })
   Endif
   
   If U_fMkWrkDir(cWorkDir)
      GetPkgList()
   Endif

   NewTmpPkg(cAliasPkg)
   
   LoadVars()
Return      

**************************
Static Function LoadVars() 
**************************
   Local xValue 
   Local nIdx      := 0
   Local nX := nY  := 0
   Local aParams   := {}
   Local cIdPack   := ""
   
   LoadDefs() 
   
   If ! Empty(aFilesPkg)
      nIdx := AScan(aFilesPkg,{|p| p:cPackage == cXmlPkg})
      If nIdx > 0
         oXmlPkg := aFilesPkg[nIdx]
      Endif
   Endif
   
   //oXmlPkg := fGetXML("")
   //lNewPkg := (  //(VALTYPE(oXmlPkg) != "O")

   UpdCheck()
      
   If lNewPkg
   
      cXmlPkg     := CriaTrab(,.F.) + ".PKG"
      aCposINI[1] := cXmlPkg 
      aCposINI[2] := Space(030)		//Descrição pacote.
      aCposINI[3] := C_DS_NEW 
      aParValues  := {}
      
      AEval(aBrwEmp,{|e| e[1] := .F. })
   Else
  	  cXmlPkg     := oXmlPkg:cPackage

      aCposINI[1] := oXmlPkg:cPackage 
      aCposINI[2] := oXmlPkg:cDesc
      aCposINI[3] := oXmlPkg:cPackage+"="+oXmlPkg:cDesc 
      
      For nX := 1 To Len(oXmlPkg:aParams)
          Aadd(aParValues,{oXmlPkg:aParams[nX,1],oXmlPkg:aParams[nX,2],oXmlPkg:aParams[nX,3],oXmlPkg:aParams[nX,4]})
      Next nX

      For nX := 1 To Len(oXmlPkg:aEmpresas)
          nIdx := AScan(aBrwEmp,{|e| e[2] == oXmlPkg:aEmpresas[nX,1] .And. e[3] == oXmlPkg:aEmpresas[nX,2] })
          If nIdx > 0
             aBrwEmp[nIdx,1] := .T.
          Endif  
      Next nX
      
   Endif  
   
   nGetTEmp := 0
   AEval(aBrwEmp,{|e| If(e[1],nGetTEmp++,)})
   If ValType(oGetTEmp) == "O"
      oGetTEmp:CtrlRefresh()
   Endif
   
Return

**************************
Static Function UpdCheck()
**************************
   Local aArea  := {}
   
   If Select(cAliasPkg) == 0
      Return
   Endif
   
   aArea := (cAliasPkg)->(FWGetArea())
   
   (cAliasPkg)->(DbGotop())
   While (cAliasPkg)->(!Eof())

         RecLock(cAliasPkg, .F. )
            (cAliasPkg)->CHECK     := ( ! lNewPkg ) .And. oXmlPkg:IsPresent((cAliasPkg)->ID)
         (cAliasPkg)->(MsUnLock())
         
         (cAliasPkg)->(DbSkip(1))
   EndDo
   
   (cAliasPkg)->(FWRestArea(aArea))
   
Return 

**************************
Static Function LoadDefs() 
**************************
   Local cDir      := U_GetDir(1)
   Local cFileDef  := cDir + "DEFAULT.xml"
   Local xValue 
   Local cTipo     := ""
   
   If ! File(cFileDef)
      return .F.
   Endif
   
   oFileXml := fGetXML(cFileDef)
   
   If Valtype(oFileXml) != "O"
      return .F.
   Endif
   
   aEmpsDef  := &( "{" + oFileXml:_Package:_Empresas:Text + "}" )

Return .T.
 

*****************************
Static Function GetPkgList()
*****************************
	Local aFiles := DIRECTORY(cWorkDir + "*.pkg")  
	Local nX     := 0, nT := Len(aFiles)    

 	FreeVar(aFilesPkg)
 	FreeVar(aPackages)
 
 	For nX :=1 To nT
		AADD(aFilesPkg,TPkgExp():New(aFiles[nX,F_NAME]))
	Next nX 
	
	aFiles := DIRECTORY(cWorkDir + "*.xml")
	nT := Len(aFiles)
 	For nX := 1 To nT
 	    If File(cWorkDir + aFiles[nX,F_NAME])
		   AADD(aPackages,TFileExp():New(aFiles[nX,F_NAME]))
		Endif
	Next nX
	                    
Return

*****************************
Static Function FreeVar(oVar)
*****************************
   
   Do Case
      Case ( ValType( oVar ) == "A" )
           AEval(oVar,{|a| If(ValType(a)=="O",FreeObj(a),) })
           ASize(oVar,0)
      Case ( ValType( oVar ) == "O" )
           FreeObj( oVar )
   EndCase
   
return

**********************************
Static Function fMontaINI(oWizard)
**********************************
   Local oPanel  := oWizard:oMPanel[oWizard:nPanel]
   Local aItens  := { C_DS_NEW }
   Local nX      := 0
   Local nT      := Len(aFilesPkg)
   Local oGetTit := nil
   Local oGetNom := nil  
   Local bBtnExc := {|| DeletePkg() }
   
   //If ! Empty(aCposINI[2])
   //   Return
   //Endif 
   
   For nX := 1 To nT
       AADD(aItens,aFilesPkg[nX]:cPackage+"="+aFilesPkg[nX]:cDesc)
   Next nX
   
   If lNewPkg
      aCposINI[3] := aItens[1] //C_DS_NEW
   Endif
   
   oCmbPkg := TComboBox():New(20,15,{|u|if(PCount()>0,aCposINI[3]:=u,aCposINI[3])},; 
                   aItens,280,20,oPanel,,{||fComboIni(aCposINI[3],oGetNom,oGetTit)},,,,.T.,,,,,,,,,'aCposINI[3]',"Selecione:",1)
                   
   SetCmbPkg()                      

   oGetTit := TGet():New( 45,15,{|u|If(PCount()>0,aCposINI[2]:=u,aCposINI[2]+Space(30-Len(aCposINI[2])))},;
                         oPanel,280,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,aCposINI[2],,,,/*uParam28*/,;
                         /* uParam29*/,/*uParam30*/,"Descricao:",1)

   oGetNom := TGet():New( 70,15,{||aCposINI[1]},oPanel,096,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,aCposINI[1],,,,;
                         /*uParam28*/,/* uParam29*/,/*uParam30*/,"Pacote:",1)  
	
   oGetNom:Disable()
   
   TBtnBmp2():New(oGetNom:nBottom + 30,015,50,30,'BMPDEL.PNG',,,,bBtnExc,oPanel,"Excluir pacote",,.T. )
   
Return 
         
************************************************
Static Function fComboIni(cValue,oGetNom,oGetTit)
************************************************
   lNewPkg := (cValue == C_CD_NEW)
   cXmlPkg := cValue
   LoadVars()
   
   If ValType(oGetNom) == "O"
      oGetNom:Refresh()
   Endif
   
   If ValType(oGetTit) == "O"
      oGetTit:Refresh()
   Endif
return

*************************
Static Function SavePkg()
*************************
   Local cArqXML  := cWorkDir + cXmlPkg
   Local aRet     := {}
   Local nX       := 0
   Local nHdl     := 0
   Local nIdx     := 0
   Local cValue   := ""
   Local aFiliais := {}
   Local cTemplate:= ""
   
   If !lChkSalvar
      return .F.
   Endif
   
   nHdl := fCreate(cArqXML)                        
   If nHdl == -1
	   MsgAlert("O arquivo de nome " + cArqXML + " nao pode ser criado.","Atenção")
	   Return .F.
   Endif         
   
   AEval(aBrwEmp,{|e| If(e[1],Aadd(aFiliais,{e[2],e[3]}),) })
   
   AADD(aRet, '<?xml version="1.0" encoding="ISO-8859-1"?>')
   AADD(aRet,"<PACKAGE>")
   AADD(aRet,StrTran("	<Name>%Name%</Name>","%Name%",aCposINI[1]) )
   AADD(aRet,StrTran("	<Description>%Description%</Description>","%Description%",AllTrim(aCposINI[2]))) 
   //AADD(aRet,StrTran("	<Empresas>%Empresas%</Empresas>","%Empresas%",ArrTokStr(aFiliais,",")))

   nX        := 1
   cTemplate := '		<PACK{1}><id>{2}</id><filename>{3}</filename></PACK{1}>'
   
   AADD(aRet,"	<PACKS>")
   (cAliasPkg)->(DbGotop())
   While (cAliasPkg)->(!Eof())

         If ! (cAliasPkg)->CHECK
            DelVPar((cAliasPkg)->ID)
            (cAliasPkg)->(DbSkip(1))
            Loop
         Endif
         
         Aadd(aRet, U_FmtStr(cTemplate,{StrZero(nX,2),(cAliasPkg)->ID,(cAliasPkg)->PACK}) )
         
         nX++
         
         (cAliasPkg)->(DbSkip(1))
   EndDo
   AADD(aRet,"	</PACKS>")

   //Grava parâmetros 
   NodesParam(@aRet)
   //Grava empresas
   NodesEmpr(@aRet)
   
   AADD(aRet,"</PACKAGE>")
                 
   For nX := 1 To Len(aRet)
      FWrite(nHdl,aRet[nX] + CRLF)
   Next     
   FClose(nHdl)
   
   //If ! Empty(aFiliais)
   //   SaveDef()
   //Endif

Return .T.

********************************
Static Function NodesParam(aXml)
********************************
   Local nY  := 0
   Local cTemplate := '		<PARAM{1}><packid>{2}</packid><name>{3}</name><field>{4}</field><value>{5}</value></PARAM{1}>'

   AADD(aXml,"	<PARAMS>")

   For nY := 1 To Len(aParValues)
       
       Aadd(aXml,U_FmtStr(cTemplate,{StrZero(nY,2),aParValues[nY,1],aParValues[nY,2],aParValues[nY,3],cValToChar(aParValues[nY,4])}))
       
   Next nY

   AADD(aXml,"	</PARAMS>")
       
Return 

*******************************
Static Function NodesEmpr(aXml)
*******************************
   Local nY  := 0
   Local cTemplate := '		<E{1}{2}><empresa>{1}</empresa><filial>{2}</filial></E{1}{2}>'

   AADD(aXml,"	<EMPRESAS>")

   For nY := 1 To Len(aBrwEmp)
       
       If ! aBrwEmp[nY,1]
          Loop
       Endif
       
       Aadd(aXml,U_FmtStr(cTemplate,{aBrwEmp[nY,2],aBrwEmp[nY,3]}))
       
   Next nY

   AADD(aXml,"	</EMPRESAS>")
       
Return 


*************************
Static Function SaveDef()
*************************
   Local cArqXML  := U_GetDir(1) + "DEFAULT.xml"
   Local aRet     := {}
   Local nX       := 0
   Local nHdl     := 0
   Local nIdx     := 0
   Local cValue   := ""
   
   If !lChkSalvar
      return .F.
   Endif
   
   nHdl := fCreate(cArqXML)                        
   If nHdl == -1
	   MsgAlert("O arquivo de nome " + cArqXML + " nao pode ser criado.","Atenção")
	   Return .F.
   Endif         
   
   AADD(aRet, '<?xml version="1.0" encoding="ISO-8859-1"?>')
   AADD(aRet,"<Package>")
   AADD(aRet,StrTran("	<Empresas>%Empresas%</Empresas>","%Empresas%",ArrTokStr(aFiliais,",")))
   AADD(aRet,"</Package>")
                 
   For nX := 1 To Len(aRet)
      FWrite(nHdl,aRet[nX] + CRLF)
   Next     
   FClose(nHdl)

Return .T.


***********************************************
Static Function fWzValid()
***********************************************
  	Local lRet := Finalize()
return lRet

*********************************
Static function NewTmpPkg(cAlias)
*********************************
   Local lRet      := .F.
   Local aStruct   := {}
   Local nX        := 0
   Local nIdx      := 0

   If Empty(aPackages)
      Return .T.
   Endif
   
   If Empty(cAlias)
      return .F.
   Endif
   
   If (Select(cAlias) != 0)
      return .T.
   Endif

   aStruct := { {"CHECK"    , "L", 001 , 00},;
                {"DESCRI"   , "C", 030 , 00},;
                {"PARAMS"   , "N", 001 , 00},;  //0 = Não tem parâmetro, 1 = Tem parâmetro, 2 = Parâmetro editado/pronto
                {"ID"       , "C", 008 , 00},;
                {"PACK"     , "C", 012 , 00},;
                {"ALS"      , "C", 003 , 00} }
   
   If (Select(cAlias) == 0)
      oTempTable := FWTemporaryTable():New(cAlias) //cFilePkg := CriaTrab(aStruct,.T.)
      oTemptable:SetFields( aStruct ) //dbUseArea(.T.,RDDSetDefault(),cFilePkg,cAlias,.F.,.F.)
	  oTempTable:Create()
   Else
      (cAlias)->(DBCloseArea())
	  (cAlias)->(__dbZap())
   Endif
   
   For nX := 1 To Len(aPackages)
       RecLock(cAlias, .T. )
          (cAlias)->CHECK     := .F.
          (cAlias)->DESCRI    := aPackages[nX]:cDesc
          (cAlias)->PARAMS    := If(!Empty(aPackages[nX]:aParams),1,0)
          (cAlias)->ID        := aPackages[nX]:cIdPack
          (cAlias)->PACK      := aPackages[nX]:cPackage
          (cAlias)->ALS       := aPackages[nX]:cAlsName
       (cAlias)->(MsUnLock())
   Next nX

   (cAlias)->(DbGotop())
   
   lRet := (cAlias)->(!Eof())

   If lRet .And. Type("oBrwPkg") == "O"
      oBrwPkg:ResetLen()
      oBrwPkg:GetBrowse():Refresh()
      oBrwPkg:Refresh()
      oBrwPkg:GoTop()
      oBrwPkg:DrawSelect()
   Endif
   
Return lRet 

*******************************
Static Function DblClkPkg(lAll)
*******************************
   If lAll
      (cAliasPkg)->(DbGoTop())     
      While (cAliasPkg)->(!Eof())
            IF (cAliasPkg)->(RecLock(cAliasPkg,.F.))
               (cAliasPkg)->CHECK := !(cAliasPkg)->CHECK
               If !(cAliasPkg)->CHECK .And. (cAliasPkg)->PARAMS == 2
                  (cAliasPkg)->PARAMS := 1
               Endif
               (cAliasPkg)->(MsUnLock())
            EndIf
            (cAliasPkg)->(DbSkip())
      End
      (cAliasPkg)->(DbGoTop())
   Else
      If (cAliasPkg)->(!Eof()) .And. (cAliasPkg)->(!Bof())
         (cAliasPkg)->(RecLock(cAliasPkg,.F.))
         (cAliasPkg)->CHECK := !(cAliasPkg)->CHECK
         If !(cAliasPkg)->CHECK .And. (cAliasPkg)->PARAMS == 2
            (cAliasPkg)->PARAMS := 1
         Endif
         (cAliasPkg)->(MsUnLock())
      Endif
   Endif
   
   oBrwPkg:ResetLen()
   oBrwPkg:Refresh()
Return nil 

*******************************
Static Function DblClkEmp(lAll)
*******************************
   Local nX := 0
   
   If lAll
      AEval(aBrwEmp,{|e| e[1] := lAll})
   Else
      aBrwEmp[oBrwEmp:nAT,1] := ! aBrwEmp[oBrwEmp:nAT,1]
   Endif

   nGetTEmp := 0
   AEval(aBrwEmp,{|e| If(e[1],nGetTEmp++,)})
   oGetTEmp:CtrlRefresh()
      
   oBrwEmp:ResetLen()
   oBrwEmp:Refresh()
Return nil 


***************************
Static Function EditParam()
***************************
   Local cIdPack   := (cAliasPkg)->ID
   Local aValues   := {}
   Local aParamBox := {}
   Local aRet      := {}
   Local nFt       := 6
   Local xDefault  
   Local xOldValue 
   Local nIdx      := 0
   Local nX        := 0
   Local cPar      := ""
   Local cFld      := ""
   Local cDsc      := ""
   Local cTip      := "C"
   Local cPct      := ""
   Local nTam      := 0
   Local nDec      := 0

   // Parametros da função Parambox()
   // -------------------------------
   // 1 - < aParametros > - Vetor com as configurações
   // 2 - < cTitle >      - Título da janela
   // 3 - < aRet >        - Vetor passador por referencia que contém o retorno dos parâmetros
   // 4 - < bOk >         - Code block para validar o botão Ok
   // 5 - < aButtons >    - Vetor com mais botões além dos botões de Ok e Cancel
   // 6 - < lCentered >   - Centralizar a janela
   // 7 - < nPosX >       - Se não centralizar janela coordenada X para início
   // 8 - < nPosY >       - Se não centralizar janela coordenada Y para início
   // 9 - < oDlgWizard >  - Utiliza o objeto da janela ativa
   //10 - < cLoad >       - Nome do perfil se caso for carregar
   //11 - < lCanSave >    - Salvar os dados informados nos parâmetros por perfil
   //12 - < lUserSave >   - Configuração por usuário

   Local lCanSave  := .F.
   Local lUserSave := .F.

   If (cAliasPkg)->PARAMS == 0
      Aviso("Atenção","Este pacote não possui parâmetro(s)! Verifique.",{"OK"},1)
      return .F.
   Endif
   
   If !(cAliasPkg)->CHECK
      Aviso("Atenção","O pacote não está selecionado.",{"OK"},1)
      return .F.
   Endif
   
   nIdx := AScan(aPackages,{|p| p:cIdPack == cIdPack})
   If ( nIdx == 0 )
      Aviso("Atenção","Parâmetro inválido! Verifique.",{"OK"},1)
      return .F.
   Endif
  
   For nX := 1 to Len(aPackages[nIdx]:aParams)
         
         cPar := aPackages[nIdx]:aParams[nX,1]
         cFld := aPackages[nIdx]:aParams[nX,2]
         cDsc := aPackages[nIdx]:aParams[nX,3]
         cTip := aPackages[nIdx]:aParams[nX,4]
         cPct := aPackages[nIdx]:aParams[nX,5]
         nTam := aPackages[nIdx]:aParams[nX,7]
         nDec := aPackages[nIdx]:aParams[nX,8]

         Aadd(aValues,{ cPar, cFld, })

         Do Case
            Case (cTip == "D")
                 xDefault := Ctod("")
            Case (cTip == "N")
                 xDefault := Val("0" + If(nDec > 0,"." + Replicate("0",nDec),""))
            Otherwise
                 xDefault := Space(nTam) 
         EndCase
         
         xOldValue := GetVPar(cIdPack,cPar,cFld)
         
         If ( ValType(xOldValue) != "U" )
            xDefault := xOldValue
         Endif 
         
         Aadd(aParamBox,{1,cDsc,xDefault,cPct,'.T.',aPackages[nIdx]:aParams[nX,6],'.T.',nTam*nFt,.F.})
   Next nX
      
   If ! ParamBox(aParamBox ,"Parâmetros",@aRet,,,,,,,,lCanSave,lUserSave)
      return .F.
   Endif

   RecLock(cAliasPkg, .F. )
      (cAliasPkg)->PARAMS := 2
   (cAliasPkg)->(MsUnLock())
   
   oBrwPkg:Refresh()
   
   For nX := 1 To Len(aRet)
       aValues[nX,3] := aRet[nX]
   Next
   
   SaveVPar(cIdPack,aValues)

Return .T.

*****************************************
Static Function SaveVPar(cIdPack,aValues)
*****************************************

   DelVPar(cIdPack)   
   AEval(aValues,{|v| Aadd(aParValues,{cIdPack,v[1],v[2],v[3]}) })
   
Return

********************************
Static Function DelVPar(cIdPack)
********************************
   Local aTemp     := {}
   
   AEval(aParValues,{|p| If(p[1] != cIdPack,Aadd(aTemp,p),)})
   
   aParValues := aClone(aTemp)
Return

**********************************************
Static Function GetVPar(cIdPack,cIdPar,cIdFld)
**********************************************
   Local nIdx := AScan(aParValues,{|p| p[1] == cIdPack .And. p[2] == cIdPar .And. p[3] == cIdFld })
   Local xRet := nil
   
   If nIdx > 0
      xRet := aParValues[nIdx,4]
   Endif
   
Return xRet    
   
**********************************
Static Function SetCmbPkg(cCodigo)
**********************************
   Local aItens  := {C_CD_NEW + '=Novo pacote.'}
   Local nX      := 0
   Local nT      := Len(aFilesPkg)
   Local nIdx    := 0
   Local cCodigo := cXmlPkg
   
   If ValType(oCmbPkg) != "O"
      return 
   Endif
   
   nIdx := oCmbPkg:nAT

   For nX := 1 To nT
       AADD(aItens,aFilesPkg[nX]:cPackage+"="+aFilesPkg[nX]:cDesc)
   Next nX
   
   If lNewPkg
      aCposINI[3] := aItens[1]
   Endif
   
   oCmbPkg:SetItems( aItens )
   
   If (nIdx > 0)
      oCmbPkg:Select(nIdx)
   Endif
   
Return
   
**********************
Static Function Exec()
**********************
   Local lRet       := .T.
   Local lAbort     := .F.
   Local bExec      := {|| lRet := Exportar(oProcess,oPack,@lAbort) }
   Local aArea      := {}
   Local oPack      := nil
                    
   Private oProcess := nil
   
   //Salva o pacote antes da execução...
   If lChkSalvar
      SavePkg()
   Endif 
   //FIM: Salva o pacote antes da execução...
   
   If lChkExec   
      
      cFileLog    := GetFileLog(Left(cXmlPkg,AT('.',cXmlPkg)-1))
      
      aArea := (cAliasPkg)->(FWGetArea())
      
      (cAliasPkg)->(DbGotop())
      While (cAliasPkg)->(!Eof())
            If (cAliasPkg)->CHECK
               
               oPack := GetPkgByID((cAliasPkg)->ID)
               
               If ValType(oPack) == "O"
                  oProcess:= MsNewProcess():New( bExec ,U_FmtStr('Exportando "{1}"...',{oPack:cAlsName}),,,.T.)
                  oProcess:Activate()
                  FreeObj(oProcess)
               Endif
               
            Endif
            
            (cAliasPkg)->(DbSkip(1))
      EndDo
      
      (cAliasPkg)->(FWRestArea(aArea))
      
   Endif
   
Return lRet    

**************************
Static Function VldPgPkg()
**************************
   Local lRet     := .T.
   Local aArea    := {}
   Local oPack    := nil
   Local lEmpty   := .T.
   
   aArea := (cAliasPkg)->(FWGetArea())
   
   (cAliasPkg)->(DbGotop())
   While lRet .And. (cAliasPkg)->(!Eof())
         
         If (cAliasPkg)->CHECK

            lEmpty := .F.

            lRet :=  ( (cAliasPkg)->PARAMS != 1 )
            If ! lRet 
               Aviso("Atenção",'Há parâmetros que não foram informados! Verifique.'+CRLF+CRLF+"Pacote: "+CRLF+(cAliasPkg)->DESCRI,{"OK"},1)
               Exit
            Endif
         Endif

         (cAliasPkg)->(DbSkip(1))
   EndDo
   
   (cAliasPkg)->(FWRestArea(aArea))

   If lEmpty 
      Aviso("Atenção","Não há processo selecionado! Verifique.",{"OK"},1)
   Endif
   
   lRet := lRet .And. ! lEmpty
    
Return lRet

***************************
Static Function DeletePkg()
***************************
   Local cFileName := ""
   Local lExists   := .F. 
   
   If lNewPkg .OR. ( Type("oXmlFile" ) != "O" )
      return .F.
   Endif
   
   cFileName := oXmlFile:cXmlFile
   lExists   := File(cFileName)
   
   lRet := lExists .And. MsgYesNo('Confirma a exclusão do pacote?')
   
   If lRet
      FErase(cFileName)

      lNewPkg := .T.
      GetPkgList()
      SetCmbPkg()
      LoadVars()
   Endif
   
Return lRet      


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

***********************************************
Static Function Exportar(oProcess,oPack,lAbort)
***********************************************
   Local lRet       := .T.
   Local cQuery     := AllTrim(oPack:cQuery)
   Local cAlias     := GetNextAlias()
   Local cPath      := oPack:cWorkDir + oPack:cAlsName +"\"
   Local cDelimiter := oPack:cDelimiter
   Local nTotRec    := 0
   Local nRecno     := 0
   Local nFCount    := 0
   Local xValue     
   Local aData      := {}
   Local aRow       := {}
   Local cRow       := ""
   Local aEmps      := {} //{ Cod.Emp, Cod.Filial, Tabela, cQuery }
   Local aTabs      := {}
   Local cFileName  := ""
   Local lExcept    := .F.
   Local nEmpsQt    := 0
   Local aExFields  := {"R_E_C_N_O_","R_E_C_D_E_L_"}
   Local lChkSTrim  := oPack:lSetTrim
   Local cFldsExct  := oPack:cFldExcept
   
   aGetFields  := {}   
   
   If ! U_fMkWrkDir(cPath)
      MsgStop( "Não foi possível criar o diretório para exportação!" + CRLF + cPath )
      Return .F.
   Endif
   
   If lChkDelet
      DelTarget(cPath)
   Endif
   
   If ! SetParams(oPack:cIdPack,@cQuery)
      MsgStop("Execução cancelada!")
      return .F.
   Endif

   aEmps   := Compilar(oPack:cAlsName,cQuery)
   nEmpsQt := Len(aEmps)
   
   aKeyUniq := GetUnique(oPack:cAlsName)  

   oProcess:SetRegua1(nEmpsQt)
   
   For nE := 1 To Len(aEmps)
       
       AddLogInf('Iniciando exportação da "{1}", Empresa "{2}"/"{3}"...',{oPack:cAlsName,aEmps[nE,1],aEmps[nE,2]},C_LOG_LHT)
       
       //---Imprime os valores dos Parâmetros no Log:
       PrintParam(oPack)
       
       oProcess:IncRegua1(U_FmtStr('Processando empresa "{1}", filial "{2}"...',{aEmps[nE,1],aEmps[nE,2]}))
       
       cFileName := oPack:cAlsName + "_" + aEmps[nE,3] + "_" + DToS(Date()) + "_" + StrTran(Time(),":","") + ".TXT" 
       cFileName := cPath + cFileName
       
       cQuery := aEmps[nE,4]
       
       If ! VldFields(cQuery)
          AddLogWar('Empresa "{1}/{2}", tabela "{3}": campo(s) inválido(s) na cláusula SELECT! Verifique.',{aEmps[nE,1],aEmps[nE,2],oPack:cAlsName},,C_LOG_LHB)
          Loop
       Endif
       
       If (Select(cAlias) > 0) 
          (cAlias)->(DbCloseArea())
       Endif
       
       TRYEXCEPTION       
           
           TCQUERY cQuery NEW ALIAS (cAlias)
           
       CATCHEXCEPTION USING oException
           IF ( ValType( oException ) == "O" )
              AddLogErr(Left(oException:DESCRIPTION,254),{})
              AddLogErr("Q  U  E  R  Y :" + CRLF + cQuery,,,C_LOG_LHB)
              oException := nil
              lExcept    := .T.
           EndIF
       ENDEXCEPTION	
       
       If lExcept
          lExcept := .F.
          Loop
       Endif
       
       If (cAlias)->(Eof())
          AddLogWar('Empresa "{1}/{2}", tabela "{3}": não há registros para a exportação!',{aEmps[nE,1],aEmps[nE,2],oPack:cAlsName},,C_LOG_LHB)
          Loop
       Endif
       
       nFCount := (cAlias)->(FCount())
       
       //Grava a linha do Header
       cRow := ""
       For nX := 1 To nFCount
           If (AScan(aExFields,{|e| e == (cAlias)->(FieldName(nX))}) > 0)
              Loop
           Endif
       
           cRow += (cAlias)->(FieldName(nX))
           If nX != nFCount
              cRow += cDelimiter
           Endif
       Next nX
       Aadd(aData,cRow)
       //Fim: Grava a linha do Header.
       
       nRecno  := 0
       nTotRec := Contar(cAlias,"!Eof()")
       (cAlias)->(DbGoTop())
       
       oProcess:SetRegua2(nTotRec)
       
       While !lAbort .And. (cAlias)->(!Eof())
           nRecno++
           oProcess:IncRegua2("Exportando o registro "+cValToChar(nRecno)+" de "+cValToChar(nTotRec)+"...")
           
           aRow := {} 
           For nX := 1 To nFCount
               If (AScan(aExFields,{|e| e == (cAlias)->(FieldName(nX))}) > 0)
                  Loop
               Endif
           
               xValue := (cAlias)->(FieldGet(nX))
               
               Do Case
                  Case (ValType(xValue) == "D")
                       xValue := DToC(xValue)
                  Case (ValType(xValue) == "N")
                       xValue := cValToChar(xValue)
                  OtherWise
                       xValue := FwCutOff(cValToChar(xValue),.F.)
                       If lChkSTrim .And. ( Ascan(aKeyUniq,{|f| f == AllTrim((cAlias)->(FieldName(nX)))}) == 0 ) .And. .Not. ( AllTrim((cAlias)->(FieldName(nX))) $ cFldsExct )
						  xValue := AllTrim(xValue)
                       Endif
               EndCase
               
               Aadd(aRow,xValue) 
                  
           Next nX
           
           cRow := ""
           For nX := 1 To Len(aRow)
               cRow += aRow[nX]
               If nX != Len(aRow)
                  cRow += cDelimiter
               Endif
           Next nX
           Aadd(aData,cRow)
           
           If ( Mod(Len(aData),N_CNT_FLUSH) == 0 )
              FileFlush(cFileName,aData)
              aData := {}
           Endif         
           
           (cAlias)->(DbSkip())
       EndDo
       
       FileFlush(cFileName,aData)
       
       If (Select(cAlias) > 0) 
          (cAlias)->(DbCloseArea())
       Endif
       
       AddLogInf('Arquivo "{1}" gerado com {2} registro(s).',{cFileName,nTotRec},,C_LOG_LHB)
       
       Aadd(aTabs,aEmps[nE,3])
       
   Next nE
   
Return lRet

******************************************
Static Function FileFlush(cFileName,aData)
******************************************
   Local nHandle := 0
   Local nX      := 0
   Local nRet    := Len(aData)
   
   If Empty(aData)
      return 0
   Endif
   
   If File(cFileName)
      nHandle := FOpen(cFileName,FO_WRITE)
   Else
      nHandle := FCreate(cFileName)
   Endif

   If nHandle = -1
      MsgStop("Erro ao criar arquivo - ferror " + Str(FError()))
      Return 0
   Endif
   
   fSeek(nHandle, 0, FS_END)
   
   For nX := 1 To Len(aData)
       FWrite(nHandle,aData[nX] + CRLF)
   Next nX
   
   aData := {}
   
   fClose(nHandle)
   
Return nRet

******************************************
Static Function Compilar(cTabAlias,cQuery)
******************************************
   Local aRet       := {}
   Local cTableName := RetSqlName(cTabAlias)
   Local cQry       := StrTran(StrTran(StrTran(cQuery,CHR(9),""),CHR(32),""),CRLF,"")
   Local aMacros    := {} // 1=Macro,2=Comando,3=Resultado (Ex. { "{Table("SA1")}","Table("SA1")","SA1010" } )
   Local nX         := 0
   Local nF         := 0
   Local cBkpEmp    := cEmpAnt
   Local cBkpFil    := cFilAnt
   Local cMacro     := ""
   Local nPosIni    := AT(C_OPEN_MACRO,cQry)
   Local nPosFin    := AT(C_CLOS_MACRO,cQry)
   Local cTable     := ""

   AEval(aBrwEmp,{|e| If(e[1],Aadd(aRet,{e[2],e[3],cTableName,cQuery}),) }) 
   
   If (nPosIni == 0)
      If Empty(aRet)
         aRet := {{cEmpAnt,cFilAnt,cTableName,cQuery}}
      Endif
      Return aRet
   Endif
   
   If Empty(aRet)
      Aadd(aRet,{cEmpAnt,cFilAnt})
   Endif
   
   AEval(aRet,{|f| ASize(f,Len(f)+2) })
   
   While nPosIni > 0 .And. nPosFin > 0
       cMacro := Substr(cQry,nPosIni,nPosFin-nPosIni+1)
       
       Aadd(aMacros,{cMacro,Substr(cMacro,2,Len(cMacro)-2),nil})
       
       cQry := Substr(cQry,nPosFin+1)
       
       nPosIni := AT(C_OPEN_MACRO,cQry)
       nPosFin := AT(C_CLOS_MACRO,cQry)
   EndDo
   
   /*
   ** Realiza a execução das macros
   */
   For nF := 1 To Len(aRet)
       cEmpAnt := aRet[nF,1]
       cFilAnt := aRet[nF,2]
       
       cQry := cQuery
       For nX := 1 To Len(aMacros)
           If ( "TABLE(" $ UPPER(aMacros[nX,1]) )
              cTable        := GetXTable(UPPER(aMacros[nX,2])) //GetTable(UPPER(aMacros[nX,2]))
              aMacros[nX,3] := cTable
           Else
              aMacros[nX,3] := "'"+MacExec(aMacros[nX,2])+"'"
           Endif
           cQry := StrTran(cQry,aMacros[nX,1],aMacros[nX,3])
       Next nX
       aRet[nF,3] := cTable
       aRet[nF,4] := cQry
   Next nF
   /*
   ** FIM: Realiza a execução das macros
   */

   cEmpAnt := cBkpEmp
   cFilAnt := cBkpFil
   
   If Empty(aRet)
      aRet := {{cEmpAnt,cFilAnt,cTableName,cQuery}}
   Endif
   
Return aRet

*********************************
Static Function GetXTable(cMacro)
*********************************
   Local cRet      := ""
   Local cAlias    := ""
   Local aAreaSx2  := SX2->(FWGetArea())
   Local cAliasSx2 := GetNextAlias()
   Local cQuery := ""
   //OpenSxs(,,,,cEmpAnt,cAliasSx2,"SX2",,.F.)
   cQuery := " SELECT X2_CHAVE AS CHAVEX2, X2_ARQUIVO AS ARQUIVOX2"
   cQuery += " FROM "+RetSQLName("SX2") + " SX2  "
   cQuery += " WHERE D_E_L_E_T_= ' ' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., 'TOPCONN', TcGenQry(,,cQuery), cAliasSx2)
   
   If Select(cAliasSx2) == 0
      MsgStop('Não foi possível abrir a SX2 da empresa "'+cEmpAnt+'".')
      return cRet 
   EndIf
   
   (cAliasSx2)->(dbSetOrder(1))
   
   cAlias := PadR( MacExec(cMacro) ,Len((cAliasSx2)->CHAVEX2))
         
   If (cAliasSx2)->(DbSeek( cAlias )) 
      cRet := AllTrim( (cAliasSx2)->ARQUIVOX2 )
   Endif
   
   If Select(cAliasSx2) > 0 
      DbSelectArea(cAliasSx2)
      DbCloseArea()
   Endif
   
   FWRestArea(aAreaSx2)
   
   If ! Empty(cRet) .And. ! TCCanOpen(cRet)  //! MsFile(cRet)
      ChkFile(cAlias) 
   Endif
   
return cRet

*********************************
Static Function MacExec( cMacro )
*********************************
   //Local bBlock:=ErrorBlock({|e| MsgAlert("Mensagem de Erro: " +chr(10)+ e:Description)})
   Local bBlock:=ErrorBlock({|e| AddLogErr('Erro de macro ('+cMacro+') '+CRLF+e:Description + e:ErrorStack,{},"=") })
   Local xRet  

   BEGIN SEQUENCE
	     xRet := cValToChar( &cMacro )
   END SEQUENCE
   ErrorBlock(bBlock)
Return xRet

*****************************
Static Function Table(cAlias)
*****************************
Return cAlias

*****************************************   
Static Function SetParams(cIdPack,cQuery)
*****************************************
   Local nX       := 0
   Local cValue   := ""
   Local aParams  := {}
   Local aFld     := {}
   Local cTipo    := "C"

   cQuery   := AllTrim(cQuery)
   
   AEval(aParValues,{|p| If(p[1] == cIdPack,Aadd(aParams,{p[2],p[3],p[4]}),) })  
   
   For nX := 1 To Len(aParams) 
       
	   cTipo := "C"
    	   
	   aFld  := TamSx3(aParams[nX,2])
	   
	   If ! Empty(aFld)
	      cTipo := aFld[3]
	   Endif

       cValue := aParams[nX,3]
	   
       Do Case
          Case (cTipo == "C")
          	  cValue := "'"+cValue+"'"
          Case (cTipo == "D")
          	  cValue := "'"+DToS(cValue)+"'"
          OtherWise
               cValue := cValToChar(cValue)
       EndCase
       cQuery := StrTran(cQuery,":"+aParams[nX,1],cValue)
	   
   Next
   
return .T.

********************************
Static Function DelTarget(cPath)
********************************
   Local cMask  := cPath + "*.txt"
   Local aFiles := Directory(cMask)
   
   AEval(aFiles,{|f| FErase(cPath + f[F_NAME]) })

   AEval(aFiles,{|f|If(!File(cPath + f[F_NAME]),AddLogWar(cPath + f[F_NAME]+CHR(9)+"Excluído com sucesso."),;
                                                AddLogErr(cPath + f[F_NAME]+CHR(9)+"Erro de exclusão!")) })
   
Return 

**********************************
Static Function GetPkgByID(cIdPack)
***********************************
   Local oRet := nil
   
   AEval(aPackages,{|p| if(p:cIdPack == cIdPack,(oRet := p),) })
   
Return oRet

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

   cQuery += "SELECT c.column_name                       " + CRLF
   cQuery += "  FROM user_indexes i, user_ind_columns c  " + CRLF
   cQuery += " WHERE i.table_name  = '"+cTable+"'        " + CRLF
   cQuery += "   AND i.uniqueness  = 'UNIQUE'            " + CRLF
   cQuery += "   AND i.index_name  = c.index_name        " + CRLF
   cQuery += "   AND i.table_name  = c.table_name        " + CRLF
   cQuery += "ORDER BY c.column_position                 "       
   
   
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

*********************************
Static Function ChkAllEmp(lValue)
*********************************
   AEval(aBrwEmp,{|e| e[1] := lValue})
   
   nGetTEmp := If(lValue,Len(aBrwEmp),0)

   oGetTEmp:CtrlRefresh()
   oBrwEmp:Refresh()
return .T.


/////////////////////////////////////////////////////////////////////////////////////////////////////
///// LOGS
/////////////////////////////////////////////////////////////////////////////////////////////////////
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
	
	cRet := Eval(bLogFile)
	While File(cRet)
	     cRet := Eval(bLogFile)
	EndDo
	
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
	Local cDirLog   := GetPathLog()
	Local cMessage  := ""
   
	Default aParams := {}
   
	If !ExistDir ( cDirLog )
		If !FWMakeDir(cDirLog,.F.)
			ConOut( "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) )
			return nil
		Endif
	Endif
	
	cMessage  := U_FmtStr( OemToAnsi(cMsg) ,aParams)
   
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
*************************************************
Static Function AddLogErr(cMsg,aParams,cTop,cDwn)
*************************************************
    Default cTop := ""
    Default cDwn := ""

    If ! Empty(cTop)
	   AddLog("ERR",Replicate(cTop,N_LOG_LH),{})
    Endif

	AddLog("ERR",cMsg,aParams)

    If ! Empty(cDwn)
	   AddLog("ERR",Replicate(cDwn,N_LOG_LH),{})
    Endif
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
*************************************************
Static Function AddLogInf(cMsg,aParams,cTop,cDwn)
*************************************************
    Default cTop := ""
    Default cDwn := ""

    If ! Empty(cTop)
	   AddLog("INF",Replicate(cTop,N_LOG_LH),{})
    Endif

	AddLog("INF",cMsg,aParams)

    If ! Empty(cDwn)
	   AddLog("INF",Replicate(cDwn,N_LOG_LH),{})
    Endif
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
*************************************************
Static Function AddLogWar(cMsg,aParams,cTop,cDwn)
*************************************************
    Default cTop := ""
    Default cDwn := ""

    If ! Empty(cTop)
	   AddLog("WAR",Replicate(cTop,N_LOG_LH),{})
    Endif

	AddLog("WAR",cMsg,aParams)

    If ! Empty(cDwn)
	   AddLog("WAR",Replicate(cDwn,N_LOG_LH),{})
    Endif
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
return "\SIGADOC\CNCTAEXP\LOGS\"

*********************************
Static Function PrintParam(oPack)
*********************************
   Local nX := 0
   
   If Empty(oPack:aParams)
      Return
   Endif

   AddLogInf("P A R Â M E T R O S:")
   
   For nX := 1 To Len(oPack:aParams) 
       AddLogInf(CHR(9)+'{1}'+CHR(9)+CHR(9)+CHR(9)+'[{2}]',{PadL(oPack:aParams[nX,3],25,chr(32)),CValToChar(GetVPar(oPack:cIdPack,oPack:aParams[nX,1],oPack:aParams[nX,2]))})
   Next nX
   
Return 
       
*********************************
Static Function VldFields(cQuery)
*********************************
   Local lRet      := .T.
   Local aAreaSx3  := SX2->(FWGetArea())
   Local cAlsSx3   := GetNextAlias()
   Local nPos1     := 0
   Local nPos2     := 0
   Local aFlds     := {}
   //Local nLenSx3   := Len(SX3->X3_CAMPO)
   Local nX        := 0

   //AddLogInf('Validando os campos da cláusula SELECT da consulta (query):')
   
   cQuery := FwCutOff(cQuery,.f.)
   nPos1  := AT("SELECT ",cQuery) + 6
   nPos2  := AT("FROM " ,cQuery) - nPos1
   aFlds  := StrTokArr2(Substr(cQuery,nPos1,nPos2),',')
   
   For nX := 1 To Len(aFlds)
       aFlds[nX] := AllTrim(aFlds[nX])
       If ( AT(CHR(32),aFlds[nX]) > 0 ) // Não valida coluna nomeadas ou expressões
	      AddLogWar('>>> A expressão [{1}], presente na cláusula SELECT, não será validada.',{aFlds[nX]})
          Loop
       Endif
       
       //--Retira o alias, exemplo: SA1.A1_COD para A1_COD
       nPos1     := AT('.',aFlds[nX])
       If nPos1 > 0
          aFlds[nX] := Substr(aFlds[nX],nPos1+1)
       Endif 
   Next nX
   
   /*OpenSxs(,,,,cEmpAnt,cAlsSx3,"SX3",,.F.)
   If Select(cAlsSx3) == 0
	  AddLogErr('Não foi possível abrir a SX3 da empresa "{1}".',{cEmpAnt})
      return .F. 
   EndIf*/

   //(cAlsSx3)->(dbSetOrder(2)) //--X3_CAMPO 

   For nX := 1 To Len(aFlds)
       If ( AT(CHR(32),aFlds[nX]) > 0 ) // Não valida coluna nomeadas ou expressões
          Loop
       Endif
   
       If Empty(FWSX3Util():GetFieldType(aFlds[nX])) //! (cAlsSx3)->( dbSeek(PadR(aFlds[nX],nLenSx3)) )
	      AddLogErr('>>> Campo "{1}" não existe no dicionário da empresa "{2}/{3}".',{aFlds[nX],cEmpAnt,cFilAnt})
		  lRet := .F.
	   Endif
   Next nX
   
   /*If Select(cAlsSx3) > 0 
      DbSelectArea(cAlsSx3)
      DbCloseArea()
   Endif*/
   
   FWRestArea(aAreaSx3)
   
return lRet
