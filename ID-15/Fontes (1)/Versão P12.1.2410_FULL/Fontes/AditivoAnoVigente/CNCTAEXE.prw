#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "xmlxfun.ch"
#include "TCBROWSE.CH"
#Include "TopConn.ch" 

#DEFINE F_NAME 	1	
#DEFINE F_SIZE 	2	
#DEFINE F_DATE 	3	
#DEFINE F_TIME 	4	
#DEFINE F_ATT  	5

#DEFINE GP_SIZEPAR	20 * 1.6
#DEFINE GP_SIZETIP	20 * 1.6
#DEFINE GP_SIZEPCT	20 * 1.6
#DEFINE GP_SIZEDES	40 * 1.6

#DEFINE N_FL_PARAMS		03
#DEFINE N_FL_EXEC		04
#DEFINE N_FL_SUMMARY    05

#DEFINE C_KEYLOG        "CNCTAEXE"

#xtranslate bSetGet(<uVar>)       =>  {|u| If(PCount() == 0, <uVar>,<uVar> := u)}
	
User Function CNCTAEXE()
	WizCfgParam()
Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} 
Função que monta as etapas doWizard de Configurações  

@author Roberto Amâncio Teixeira (robertosiga@gmail.com)
@since 20/07/2015	
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function WizCfgParam() 
	Local oWizard
	Local bValid     := {|| fWzValid() }
	Local bInit      := {|| Initialization() }
	Local bWhen      := {|| .T. }

    Private cDataIni := "" 
    Private cHoraIni := ""
    Private cDataFin := ""
    Private cHoraFin := ""
	
	Private oBrwPrc   := Nil
	Private oBrwExe   := Nil
	Private oBrwRes   := Nil
	Private oMtrProc  := Nil
	Private oSayMsg1  := Nil
	
	Private cWorkDir  := GetDir(0)
	Private cXmlPkg   := ""
	Private oXmlPkg   := nil
	Private aCposINI[3]
	Private aFilesPkg := {}  
	
	Private lNewPkg     := .T.
	Private aProcess    := {}
	
	Private oFntMsg1    := TFont():New('Tahoma',,-11,.T.) 

    Private cAliasRes   := GetNextAlias()
    Private cFileRes    := ""
    Private bLDblClick  := {||GrdSelect(.F.)}
    Private bHeaderClick:= {||GrdSelect(.T.)}
    Private bCargaFull  := {||SetFull()}
    Private bPreview    := {|| U_PrvLog(.F.,AllTrim((cAliasRes)->ZVJ_CODIGO),cDataIni,cDataIni,AllTrim((cAliasRes)->ARQLOG)) }
    Private lChkMark    := .F.
    Private lChkSalvar  := .T.
    Private lChkExec    := .T.
    Private oGetPesq    := Nil
    Private cGetPesq    := Space(25)

    Private oChecked    := LoadBitMap(GetResources(),"LBOK")
    Private oUnChecked  := LoadBitMap(GetResources(),"LBNO")
    Private oPending    := LoadBitMap(GetResources(),"BR_AZUL_CLARO")    
    Private oValid      := LoadBitMap(GetResources(),"BR_VERDE") 
    Private oInvalid    := LoadBitMap(GetResources(),"BR_VERMELHO")

    Private oWaiting     := LoadBitMap(GetResources(),"BR_VERDE")
    Private oRunning     := LoadBitMap(GetResources(),"DBG3")
    Private oSuccess     := LoadBitMap(GetResources(),"CHECKOK.BMP")
    Private oError       := LoadBitMap(GetResources(),"BR_CANCEL")
    Private oLegFull     := LoadBitMap(GetResources(),"UPDWARNING17.PNG")
    
    Private oRefreshOn   := oWaiting //LoadBitMap(GetResources(),"CHECKOK.BMP")
    Private oRefreshOff  := oError //LoadBitMap(GetResources(),"RELOAD1.BMP")
    Private oRefreshWar  := LoadBitMap(GetResources(),"BR_AMARELO") //LoadBitMap(GetResources(),"RELOAD1.BMP")
    
    Private bColChk     := {|| IF((cAliasRes)->XCHECK,oChecked,oUnChecked) }
    Private bColFull    := {|| IF((cAliasRes)->XFULL,oChecked,oUnChecked) }
    Private bColValid   := {|| If((cAliasRes)->XFULL,oLegFull,IF(Empty((cAliasRes)->XVALID) ,oPending,If((cAliasRes)->XVALID=="1" ,oValid,oInvalid))) }
    Private bColStatus  := {|| IF(Empty((cAliasRes)->XSTATUS),If((cAliasRes)->XFULL,oLegFull,oWaiting),If((cAliasRes)->XSTATUS=="1",oRunning,If((cAliasRes)->XSTATUS=="3",oError,oSuccess))) }
    Private bColTpImp   := {|| GetTpImp((cAliasRes)->ZVJ_TPIMP) }
    Private bRefresh    := {|| If(Empty((cAliasRes)->XREFRESH),oRefreshOn,If((cAliasRes)->XREFRESH == "1",oRefreshOff,oRefreshWar)) }
    
    	    
    Static aTipoImp     := GetCBoxSX3("ZVJ_TPIMP")
	
	fBefShow()
	
	oWizard := APWizard():New(OemToAnsi("Assistente de Execução"),OemToAnsi("Assistente de execução de pacotes de importação."),;
												OemToAnsi("Assistente de Execução"),;
												OemToAnsi("Este assistente o auxiliará na configuração de um pacote de importação de dados."),{||.T.},{||.T.},.F.,"E5")

	oWizard:NewPanel(OemToAnsi("Seleção do Pacote"),OemToAnsi("Informe o pacote de execução a ser configurado."),{||.T.},{||InitPkg()},{||.T.},.T.,{||ShowIni(@oWizard)})

	oWizard:NewPanel(OemToAnsi("Processos"),OemToAnsi("Selecione os processos de importação a serem executados."),{||.T.},{||.T.},{||.T.},.T.,{||ShowProcess(oWizard)})

	oWizard:NewPanel(OemToAnsi("Execução do Pacote"),;
	     OemToAnsi('Clique em "Avançar" para iniciar a execução ou com o botão direito do mouse sobre a grade,'+CRLF+;
	               'defina a ordem de execução dos processos.'),{||.T.},{|| Exec(oWizard) },{|| .T. },.T.,{||ShowExec(oWizard)})

	oWizard:NewPanel(OemToAnsi("Resumo"),OemToAnsi('Resumo da execução do pacote.'),{||.F.},{||.F.},{|| .T. },.T.,{||ShowSummary(oWizard)})
	                    
	oWizard:Activate(.T.,bValid,bInit,bWhen)	
	
Return Nil

********************************
Static Function Initialization()
********************************
   Public __lPackage := .T.

Return .T.

**************************
Static Function Finalize()
**************************
   __lPackage := .F.
   If (Select(cAliasRes) > 0)
      (cAliasRes)->(dbclosearea())
      If File(cFileRes + GetDBExtension())
         FErase(cFileRes + GetDBExtension())
      Endif
      If File(cFileRes +"_01"+OrdBagExt())
         FErase(cFileRes +"_01"+OrdBagExt())
      Endif
      If File(cFileRes +"_02"+OrdBagExt())
         FErase(cFileRes +"_02"+OrdBagExt())
      Endif
   Endif

Return .T.   

************************************************
Static Function fGetXML(cFileName)       
************************************************                       
   Local cFile    := cWorkDir + Iif(!Empty(cFileName),cFileName,cXmlPkg)
   Local cError   := ""
   Local cWarning := ""
   Local oRetXml  := Iif(File(cFile),XmlParserFile(cFile, "", @cError, @cWarning),nil)
   
   If ((cError <> "") .OR. (cWarning <> ""))
      MsgStop("Erro: " + cError + " Aviso:" + cWarning,"Erro XML")
   Endif
Return oRetXml

**************************
Static Function fBefShow()
**************************
   If U_fMkDirkit(cWorkDir)
      fGetPkgList()
   Endif
   fLoadVars()
Return      

***************************
Static Function fLoadVars() 
***************************
   Local aNodes1  := {} 
   Local nX       := 0

   aProcess := {}
   oXmlPkg  := fGetXML("")
   lNewPkg  := (VALTYPE(oXmlPkg) != "O")
   
   If lNewPkg
      lChkMark := .F.
      cXmlPkg := CriaTrab(,.F.) + ".pkg"
      aCposINI[2] := Space(50)		//Descrição pacote.
   Else
      lChkMark := .T.
  	  cXmlPkg := oXmlPkg:_Package:_Name:Text
      aCposINI[2] := oXmlPkg:_Package:_Description:Text	//Descrição pacote.

      If (Type("oXmlPkg:_Package:_Process") == "O")
         aNodes1 :=  ClassDataArr(oXmlPkg:_Package:_Process)
         For nX := 1 To Len(aNodes1)
             If (ValType(aNodes1[nX,2]) != "O")
                Loop
             Endif
             Aadd(aProcess,{aNodes1[nX,2]:_Codigo:Text,aNodes1[nX,2]:_Tabela:Text,("T" $ aNodes1[nX,2]:_Full:Text),Val(aNodes1[nX,2]:_Ordem:Text)})
         Next nX
      Endif
   Endif  
   aCposINI[1] := cXmlPkg	//Nome pacote.
   
Return 

*****************************
Static Function fGetPkgList()
*****************************
	Local cDir   := GetDir(0) 
	Local aFiles := DIRECTORY(cDir + "*.pkg")  
	Local nX := 0, nT := Len(aFiles)    
	Local cFile := ""
	Local oXml := nil
	Local cError := cWarning := ""

 	aFilesPkg := {}
 
 	For nX := 1 To nT
		oXml := fGetXML(aFiles[nX,F_NAME])
      
      If (ValType(oXml) == "O")
		   AADD(aFilesPkg,{aFiles[nX,F_NAME],AllTrim(oXml:_Package:_Description:Text),aFiles[nX,F_DATE],aFiles[nX,F_TIME]})
		   
	      FreeObj(oXml)
		Endif
	Next nX                     
Return 

********************************
Static Function ShowIni(oWizard)
********************************
   Local oPanel := oWizard:oMPanel[oWizard:nPanel]
   Local aItens := {'<< NOVO >>=Novo pacote.'}
   Local nX := 0
   Local nT := Len(aFilesPkg)
   Local oGetTit := nil
   Local oGetNom := nil   
   
   For nX := 1 To nT
       AADD(aItens,aFilesPkg[nX,1]+"="+aFilesPkg[nX,2])
   Next nX
   
   If lNewPkg
      aCposINI[3] := aItens[1]
   Endif
   
   TComboBox():New(20,15,{|u|if(PCount()>0,aCposINI[3]:=u,aCposINI[3])},; 
                 aItens,280,20,oPanel,,{||fComboIni(aCposINI[3])},,,,.T.,,,,,,,,,'aCposINI[3]',;
                 "Selecione:",1)     

   oGetTit := TGet():New( 45,15,{|u|If(PCount()>0,aCposINI[2]:=u,aCposINI[2]+Space(50-Len(aCposINI[2])))},oPanel,280,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,aCposINI[2],,,,;
   /*uParam28*/,/* uParam29*/,/*uParam30*/,"Descricao:",1)

   oGetNom := TGet():New( 70,15,{||aCposINI[1]},oPanel,096,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,aCposINI[1],,,,;
   /*uParam28*/,/* uParam29*/,/*uParam30*/,"Pacote:",1)  
	
   oGetNom:Disable()
   
Return 

*********************************
Static Function fComboIni(cValue)
*********************************
  
   lNewPkg := (cValue == "<< NOVO >>")
   cXmlPkg := cValue

   fLoadVars()
return

*************************
Static Function SavePkg()
*************************
   Local cArqXML   := cWorkDir + cXmlPkg
   Local aRet      := {}
   Local nX        := 0
   Local nHdl      := 0                        
   Local cProcess  := ""
   
   If !lChkSalvar
      Return .T.
   Endif

   nHdl := fCreate(cArqXML)
   If nHdl == -1
	   MsgAlert("O arquivo de nome " + cArqXML + " nao pode ser criado.","Atenção")
	   Return .F.
   Endif         
   
   AADD(aRet, '<?xml version="1.0" encoding="ISO-8859-1"?>')
   AADD(aRet,"<Package>")
   AADD(aRet,"	<Name>"+AllTrim(aCposINI[1])+"</Name>")
   AADD(aRet,"	<Description>"+AllTrim(aCposINI[2])+"</Description>")
   AADD(aRet,"	<LastExec>")
   AADD(aRet,"		<DataIni>"+cDataIni+"</DataIni>")
   AADD(aRet,"		<HoraIni>"+cHoraIni+"</HoraIni>")
   AADD(aRet,"		<DataFin>"+cDataFin+"</DataFin>")
   AADD(aRet,"		<HoraFin>"+cHoraFin+"</HoraFin>")
   AADD(aRet,"	</LastExec>")

   AADD(aRet,"	<Process>")
   (cAliasRes)->(DbSetOrder(1)) //ORDEM
   (cAliasRes)->(DbGotop())
   While (cAliasRes)->(!Eof())
         cProcess := AllTrim((cAliasRes)->ZVJ_DESTIN)
         AADD(aRet,"		<P"+(cAliasRes)->ZVJ_CODIGO+">")
         AADD(aRet,"			<Codigo>"+(cAliasRes)->ZVJ_CODIGO+"</Codigo>")
         AADD(aRet,"			<Tabela>"+cProcess+"</Tabela>")
         AADD(aRet,"			<DataIni>"+(cAliasRes)->DTINI+"</DataIni>")
         AADD(aRet,"			<HoraIni>"+(cAliasRes)->HRINI+"</HoraIni>")
         AADD(aRet,"			<DataFin>"+(cAliasRes)->DTFIN+"</DataFin>")
         AADD(aRet,"			<HoraFin>"+(cAliasRes)->HRFIN+"</HoraFin>")
         AADD(aRet,"			<Tempo>"+(cAliasRes)->TEMPO+"</Tempo>")
         AADD(aRet,"			<Total>"+cValToChar((cAliasRes)->TOTAL)+"</Total>")
         AADD(aRet,"			<Gravados>"+cValToChar((cAliasRes)->GRAVADOS)+"</Gravados>")
         AADD(aRet,"			<Full>"+cValToChar((cAliasRes)->XFULL)+"</Full>")
         AADD(aRet,"			<Ordem>"+cValToChar((cAliasRes)->ORDEM)+"</Ordem>")
         AADD(aRet,"		</P"+(cAliasRes)->ZVJ_CODIGO+">")
         (cAliasRes)->(DbSkip(1))
   EndDo
   AADD(aRet,"	</Process>")
             
   AADD(aRet,"</Package>")
                 
   For nX := 1 To Len(aRet)
      FWrite(nHdl,aRet[nX] + CRLF)
   Next     
   FClose(nHdl)

   //MsgAlert("O arquivo de nome " + CRLF + cArqXML + " foi salvo.","Atenção")

Return .T.

***********************************************
Static Function fWzValid()
***********************************************
  	Local lRet := .T.
  
  	lRet := Finalize()
  
return lRet

********************************
Static function CriaTemp(cAlias)
********************************
   Local lRet      := .T.
	Local aStruct   := {}
	Local nX        := 0
	Local cQuery    := ""
	Local cAliasTmp := GetNextAlias()
   Local nProcess  := 0
	
	If Empty(cAlias)
	   return .F.
	Endif
	
	 AAdd( aStruct,{"XCHECK"     , "L", 001                    , 0})
	 AAdd( aStruct,{"XFULL"      , "L", 001                    , 0})
	 AAdd( aStruct,{"XVALID"     , "C", 001                    , 0})
	 AAdd( aStruct,{"XSTATUS"    , "C", 001                    , 0})
	 AAdd( aStruct,{"XREFRESH"   , "C", 001                    , 0})
	 AAdd( aStruct,{"DTINI"     , "C", 010                    , 0})
	 AAdd( aStruct,{"HRINI"     , "C", 008                    , 0})
	 AAdd( aStruct,{"DTFIN"     , "C", 010                    , 0})
	 AAdd( aStruct,{"HRFIN"     , "C", 008                    , 0})
	 AAdd( aStruct,{"TOTAL"     , "N", 015                    , 0})
	 AAdd( aStruct,{"GRAVADOS"  , "N", 015                    , 0})
	 AAdd( aStruct,{"TEMPO"     , "C", 008                    , 0})
	 AAdd( aStruct,{"ORDEM"     , "N", 010                    , 0})
	 AAdd( aStruct,{"ARQLOG"    , "C", TamSx3("ZVJ_DIRIMP")[1], 0})
	 AAdd( aStruct,{"ZVJ_CODIGO", "C", TamSx3("ZVJ_CODIGO")[1], 0})
    AAdd( aStruct,{"ZVJ_DESTIN", "C", TamSx3("ZVJ_DESTIN")[1], 0})
    AAdd( aStruct,{"ZVJ_TPIMP" , "C", TamSx3("ZVJ_TPIMP" )[1], 0})
    AAdd( aStruct,{"ZVJ_DESC"  , "C", TamSx3("ZVJ_DESC"  )[1], 0})
	 AAdd( aStruct,{"ZVJ_DIRIMP", "C", TamSx3("ZVJ_DIRIMP")[1], 0})
   
   //oTempTable := FWTemporaryTable():New( cAlias ) 
   //oTempTable:Delete() 

   
//Cria índice com colunas setadas anteriormente
//oTempTable:AddIndex("INDICE1", {"FILIAL", "COD", "PRODUT"} )
//oTempTable:AddIndex("INDICE2", {"PRODUT", "LOTE"} )
 
//Efetua a criação da tabela
//oTempTable:Create()

   If (Select(cAlias) == 0)
      //Cria a tabela temporária
      oTempTable := FWTemporaryTable():New( cAlias ) //cFileRes := CriaTrab(aStruct,.T.)
      oTemptable:SetFields( aStruct ) //dbUseArea(.T.,RDDSetDefault(),cFileRes,cAlias,.F.,.F.)
      oTempTable:AddIndex( "1" , { "ORDEM" } ) //IndRegua(cAlias,cFileRes+"_01","ORDEM"     ,,," Aguarde, indexando os dados... ")
      oTempTable:AddIndex( "2" , { "ZVJ_DESTIN" } ) //IndRegua(cAlias,cFileRes+"_02","ZVJ_DESTIN",,," Aguarde, indexando os dados.. ")
      oTempTable:Create()
      /*(cAlias)->(DBClearIndex())
      (cAlias)->(DbSetIndex(cFileRes+"_01"+OrdBagExt())) 
      (cAlias)->(DbSetIndex(cFileRes+"_02"+OrdBagExt())) */
   Else
      //oTempTable:Delete() 
      //(cAlias)->(__dbZap())
		IF Select(cAlias)<>0
			(cAlias)->(DBCloseArea())
			oTempTable:Zap()
		EndIF
   Endif
   
   cQuery += "SELECT ZVJ.ZVJ_CODIGO, ZVJ.ZVJ_DESTIN, ZVJ.ZVJ_TPIMP, ZVJ.ZVJ_DESC, ZVJ.ZVJ_DIRIMP " + CRLF
   cQuery += "FROM "+RetSqlName("ZVJ")+" ZVJ                                                     " + CRLF
   cQuery += "WHERE ZVJ.D_E_L_E_T_=' '                                                           " + CRLF
   cQuery += "AND ZVJ.ZVJ_TPIMP <> ' '                                                           " + CRLF
   cQuery += "ORDER BY ZVJ.ZVJ_DESTIN				                                             "
      
   TCQUERY cQuery NEW ALIAS (cAliasTmp)
   
   While (cAliasTmp)->(!Eof())
         nProcess := AScan(aProcess,{|x| x[1] == AllTrim((cAliasTmp)->ZVJ_CODIGO)})
         
         RecLock(cAlias,.T.)
         (cAlias)->XCHECK   := (nProcess > 0)
         (cAlias)->XFULL    := (nProcess > 0) .And. aProcess[nProcess,3]
         (cAlias)->XVALID   := " "
         (cAlias)->XSTATUS  := " "
         (cAlias)->XREFRESH := " "
         (cAlias)->ORDEM   := If(nProcess>0,aProcess[nProcess,4],(cAlias)->(Recno()))
         (cAlias)->ARQLOG  := ""
         For nX := 1 To (cAlias)->(FCount())
             If (cAlias)->(FieldName(nX)) $ "XCHECK|XFULL|XVALID|XSTATUS|XREFRESH|DTINI|HRINI|DTFIN|HRFIN|TOTAL|GRAVADOS|TEMPO|ORDEM|ARQLOG"
                Loop
             Endif
             (cAlias)->(FieldPut(nX, (cAliasTmp)->(FieldGet((cAliasTmp)->(FieldPos( (cAlias)->(FieldName(nX)) ))))))
         Next nX 
         (cAlias)->(MsUnLock())
         
         (cAliasTmp)->(DbSkip(1))
   EndDo   

   (cAlias)->(DbGotop())
   
   lRet := (cAlias)->(!Eof())

   If lRet .And. Type("oBrwPrc") == "O"
      oBrwPrc:ResetLen()
      oBrwPrc:Refresh()
      oBrwPrc:GoTop()
   Endif
   
Return lRet 

*************************
Static Function SetFull()
*************************
   IF (cAliasRes)->XCHECK .AND. (cAliasRes)->(RecLock(cAliasRes,.F.))
      (cAliasRes)->XFULL := !(cAliasRes)->XFULL
      (cAliasRes)->(MsUnLock())
   EndIf
   oBrwPrc:Refresh()
Return nil

*******************************
Static Function GrdSelect(lAll)
*******************************
   If lAll
      (cAliasRes)->(DbGoTop())     
      While (cAliasRes)->(!Eof())
            IF (cAliasRes)->(RecLock(cAliasRes,.F.))
               (cAliasRes)->XCHECK := !(cAliasRes)->XCHECK
               If !(cAliasRes)->XCHECK
                  (cAliasRes)->XFULL   := .F.
                  (cAliasRes)->XVALID  := " "
                  (cAliasRes)->XSTATUS := " "
               Endif 
               (cAliasRes)->(MsUnLock())
            EndIf
            (cAliasRes)->(DbSkip())
      End
      (cAliasRes)->(DbGoTop())
   Else
      If (cAliasRes)->(!Eof()) .And. (cAliasRes)->(!Bof())
         (cAliasRes)->(RecLock(cAliasRes,.F.))
         (cAliasRes)->XCHECK := !(cAliasRes)->XCHECK
         If !(cAliasRes)->XCHECK
            (cAliasRes)->XFULL   := .F.
            (cAliasRes)->XVALID  := " "
            (cAliasRes)->XSTATUS := " "
         Endif 
         (cAliasRes)->(MsUnLock())
      Endif
   Endif
   
   oBrwPrc:ResetLen()
   oBrwPrc:Refresh()
Return nil 

***************************************
Static Function SetFilMark(lValue,oBrw)
***************************************
   Local bFilter := {|| .T. }
   
   lChkMark := lValue
   
   If lValue
      bFilter  := {|| XCHECK }
   Endif

   (cAliasRes)->(DbSetFilter(bFilter,""))
   (cAliasRes)->(DbGoTop())

   oBrw:ResetLen()
   oBrw:Refresh()
   
   cGetPesq := Space(25)
   oGetPesq:CtrlRefresh()
return .T.

***************************
Static Function Pesquisar()
***************************
   Local bFilter := {|| .T. }
   
   If ! Empty(AllTrim(cGetPesq))
      lChkMark:= .F.
      bFilter := {|| AT(AllTrim(cGetPesq),AllTrim((cAliasRes)->ZVJ_DESC))>0 .OR. cGetPesq $ (cAliasRes)->ZVJ_DESTIN }
   Endif
   
   (cAliasRes)->(DbSetFilter(bFilter,""))
   (cAliasRes)->(DbGoTop())

   oBrwPrc:ResetLen()
   oBrwPrc:Refresh() 

Return .T.

************************************       
Static Function ShowProcess(oWizard)
************************************
   Local oPanel   := oWizard:oMPanel[N_FL_PARAMS]
   Local bFilMark := {|| }
   Local aSize    := {}
   
   If (ValType(oBrwPrc) == "O")
      Return .T.
   Endif
   
   aSize    := {010,020,020,CalcFieldSize("C",TamSx3("ZVJ_DESC")[1],0,"@!","Descrição"),CalcFieldSize("C",TamSx3("ZVJ_DESTIN")[1],0,"@!","Destino"  )}
   aSize[4] := aSize[4] - (aSize[1]+aSize[2]+aSize[3]) 
   
   bFilMark := {|| SetFilMark(lChkMark,oBrwPrc) }

   oBrwPrc := TcBrowse():New(0,0,0,0,,,,oPanel,,,,,,,,,,,,.F.,cAliasRes,.T.,,.F.,,,.F.)

      oBrwPrc:AddColumn(TCColumn():New(" "         ,bColChk                      ,"",,,"CENTER" ,aSize[01],.T.,.F.,,,,.F.)) 
      oBrwPrc:AddColumn(TCColumn():New("Full"      ,bColFull                     ,"",,,"CENTER" ,aSize[02],.T.,.F.,,,,.F.))
      oBrwPrc:AddColumn(TCColumn():New("OK"        ,bColValid                    ,"",,,"CENTER" ,aSize[03],.T.,.F.,,,,.F.))
      oBrwPrc:AddColumn(TCColumn():New("Descrição" ,{||(cAliasRes)->ZVJ_DESC    },"",,,"LEFT"   ,aSize[04],.F.,.F.,,,,.F.))
      oBrwPrc:AddColumn(TCColumn():New("Destino"   ,{||(cAliasRes)->ZVJ_DESTIN  },"",,,"LEFT"   ,aSize[05],.F.,.F.,,,,.F.))
      oBrwPrc:AddColumn(TCColumn():New("Tipo"      ,bColTpImp                    ,"",,,"LEFT"   ,CalcFieldSize("C",TamSx3("ZVJ_DESTIN")[1]/2,0,"@!","Tipo"  ),.F.,.F.,,,,.F.))
      
              
      oBrwPrc:bLDblClick   := bLDblClick
      oBrwPrc:bHeaderClick := bHeaderClick
      
      oBrwPrc:Align      := CONTROL_ALIGN_ALLCLIENT
      
      oBrwPrc:SetPopup(Eval({|m|;
         m:Add(TMenuItem():New(oPanel,             ;
         "Carga full"  ,,,,bCargaFull,"UPDWARNING17.PNG","UPDWARNING17.PNG",,,,,,,.T.)), ;
      , m },TMenu():New(0,0,0,0,.T.)))

   oPnl1Bottom:= TPanel():New(00,00,,oPanel,,.T.,,,,000,28)
   oPnl1Bottom:Align := CONTROL_ALIGN_BOTTOM       
   TCheckBox():New((oPnl1Bottom:nTop/2)+10,05,'Exibir somente selecionados',bSetGet(lChkMark),oPnl1Bottom,150,050,,bFilMark,;
                                /* oFont */, /* bValid */, /* nClrText */, /* nClrPane */, /* uParam14 */, /* lPixel */, /* cMsg */, /* uParam17 */, /* bWhen */ )

   oGetPesq := TGet():New((oPnl1Bottom:nTop/2)+10,(oPnl1Bottom:NCLIENTWIDTH/2)-110,bSetGet(cGetPesq),oPnl1Bottom,;
               080,009,"@!",{|| Pesquisar() },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cGetPesq,,,,/*uParam28*/,/* uParam29*/,/*uParam30*/,"Pesquisar:",2)

   SetFilMark(.F.,oBrwPrc) //Força a exibição de todos os processos (ZVJ).
   
return .T.       

*********************************       
Static Function ShowExec(oWizard)
*********************************
   Local oPanel      := oWizard:oMPanel[N_FL_EXEC] 
   Local nRegTot     := (cAliasRes)->(LastRec())
   Local bOrdUp      := {|| SetOrdem(.F.,oBrwExe)}
   Local bOrdDown    := {|| SetOrdem(.T.,oBrwExe)} 
   Local bExRefresh  := {|| VldRefresh()  } //{|| alert( (cAliasRes)->ZVJ_DESTIN + " Código:"+ (cAliasRes)->ZVJ_CODIGO ) }
   Local oBtnUp      := Nil
   Local oBtnDown    := Nil
   Local oBtnSinc    := Nil
    
   If (ValType(oBrwExe) == "O")
      //Exibe somente os processos selecionados.
      SetFilMark(.T.,oBrwExe)
      Return .T.
   Endif
   
   oBrwExe:=TcBrowse():New(0,0,0,0,,,,oPanel,,,,,,,,,,,,.F.,cAliasRes,.T.,,.F.,,,.F.)
      
      oBrwExe:AddColumn(TCColumn():New("Arq."      ,bColStatus                    ,"",,,"CENTER" ,10                                                           ,.T.,.F.,,,,.F.))
      oBrwExe:AddColumn(TCColumn():New("Sinc."     ,bRefresh                      ,"",,,"CENTER" ,10                                                           ,.T.,.F.,,,,.F.))
      oBrwExe:AddColumn(TCColumn():New("Descrição" ,{||(cAliasRes)->ZVJ_DESC    },"",,,"LEFT"   ,CalcFieldSize("C",TamSx3("ZVJ_DESC")[1]/2  ,0,"@!","Descrição"),.F.,.F.,,,,.F.))
      oBrwExe:AddColumn(TCColumn():New("Destino"   ,{||(cAliasRes)->ZVJ_DESTIN  },"",,,"LEFT"   ,CalcFieldSize("C",TamSx3("ZVJ_DESTIN")[1]/2,0,"@!","Destino"  ),.F.,.F.,,,,.F.))
      oBrwExe:AddColumn(TCColumn():New("Tipo"      ,bColTpImp                    ,"",,,"LEFT"   ,CalcFieldSize("C",TamSx3("ZVJ_TPIMP")[1]/2 ,0,"@!","Tipo"  )   ,.F.,.F.,,,,.F.))
              
      oBrwExe:Align      := CONTROL_ALIGN_ALLCLIENT
        
      oBrwExe:SetPopup(Eval({|m|;
        	m:Add(TMenuItem():New(oPanel,                                                      ;
        	"Subir"      ,,,,bOrdUp     ,"UP"               ,"UP"               ,,,,,,,.T.)),;
        	m:Add(TMenuItem():New(oPanel,                                                      ;
        	"Descer"     ,,,,bOrdDown   ,"DOWN"             ,"DOWN"             ,,,,,,,.T.)),;
        	m:Add(TMenuItem():New(oPanel,                                                      ;
        	"Sincronizar",,,,bExRefresh ,"NG_ICO_RETOSM.PNG","NG_ICO_RETOSM.PNG",,,,,,,.T.)) ;
      , m },TMenu():New(0,0,0,0,.T.)))
         
      oMtrProc := TMeter():New(000,000,bSetGet(nRegTot),nRegTot,oPanel,260,12,,.T.)
      oSayMsg1 := TSay():New(000,000,{||"..." }, oPanel,, oFntMsg1,,,,.T.,CLR_HBLUE,CLR_BLACK,260,10,,,,,,.T.)
      
	  oPnl2Bottom:= TPanel():New(00,00,,oPanel,,.T.,,,,000,18)
      oPnl2Bottom:Align := CONTROL_ALIGN_BOTTOM       
      TCheckBox():New((oPnl2Bottom:nTop/2),05,'Salvar alterações',bSetGet(lChkSalvar),oPnl2Bottom,150,030,,{||.T.},;
                                   /* oFont */, /* bValid */, /* nClrText */, /* nClrPane */, /* uParam14 */, /* lPixel */, /* cMsg */, /* uParam17 */, /* bWhen */ )
      TCheckBox():New((oPnl2Bottom:nTop/2)+10,05,'Executar',bSetGet(lChkExec),oPnl2Bottom,150,030,,{||ChangeExec(oWizard)},;
                                   /* oFont */, /* bValid */, /* nClrText */, /* nClrPane */, /* uParam14 */, /* lPixel */, /* cMsg */, /* uParam17 */, /* bWhen */ )

      //PMSRRFSH.PNG
      oBtnSinc := TBtnBmp2():New(000,000,50,30,'NG_ICO_RETOSM.PNG',,,,bExRefresh,oPnl2Bottom,"Sincronizar",,.T. )
      oBtnUp   := TBtnBmp2():New(000,000,50,30,'UP'               ,,,,bOrdUp    ,oPnl2Bottom,"Posiciona acima",,.T. )
      oBtnDown := TBtnBmp2():New(000,000,50,30,'DOWN'             ,,,,bOrdDown  ,oPnl2Bottom,"Posiciona abaixo",,.T. )

      oBtnDown:Align := CONTROL_ALIGN_RIGHT
      oBtnUp:Align   := CONTROL_ALIGN_RIGHT
      oBtnSinc:Align := CONTROL_ALIGN_RIGHT

      oSayMsg1:Align := CONTROL_ALIGN_BOTTOM
      oMtrProc:Align := CONTROL_ALIGN_BOTTOM

   //Exibe somente os processos selecionados.
   SetFilMark(.T.,oBrwExe)
                                   	                    
Return .T.

************************************       
Static Function ShowSummary(oWizard)
************************************
   Local oPanel  := oWizard:oMPanel[N_FL_SUMMARY]
   
   If !lChkExec
      Return .T.
   Endif
   
   If (ValType(oBrwRes) == "O")
      //Exibe somente os processos selecionados.
      SetFilMark(.T.,oBrwRes)
      Return .F.
   Endif
   
   oBrwRes:=TcBrowse():New(0,0,0,0,,,,oPanel,,,,,,,,,,,,.F.,cAliasRes,.T.,,.F.,,,.F.)
      
         oBrwRes:AddColumn(TCColumn():New(" "          ,bColStatus                    ,"",,,"CENTER" ,10                                                               ,.T.,.F.,,,,.F.))
         oBrwRes:AddColumn(TCColumn():New("Descrição"  ,{||(cAliasRes)->ZVJ_DESC    },"",,,"LEFT"   ,CalcFieldSize("C",TamSx3("ZVJ_DESC")[1]/2  ,0,"@!","Descrição"   ),.F.,.F.,,,,.F.))
         oBrwRes:AddColumn(TCColumn():New("Destino"    ,{||(cAliasRes)->ZVJ_DESTIN  },"",,,"LEFT"   ,CalcFieldSize("C",TamSx3("ZVJ_DESTIN")[1]/2,0,"@!","Destino"     ),.F.,.F.,,,,.F.))
         oBrwRes:AddColumn(TCColumn():New("Tipo"       ,bColTpImp                    ,"",,,"LEFT"   ,CalcFieldSize("C",TamSx3("ZVJ_TPIMP")[1]/2 ,0,"@!","Tipo"        ),.F.,.F.,,,,.F.))

         oBrwRes:AddColumn(TCColumn():New("Total"      ,{||(cAliasRes)->TOTAL       },"",,,"RIGHT"  ,CalcFieldSize("C",015                    ,0,"99,999,999","Total"       ),.F.,.F.,,,,.F.))
         oBrwRes:AddColumn(TCColumn():New("Importados" ,{||(cAliasRes)->GRAVADOS    },"",,,"RIGHT"  ,CalcFieldSize("C",015                    ,0,"99,999,999","Importados"  ),.F.,.F.,,,,.F.))
         oBrwRes:AddColumn(TCColumn():New("Data Inic." ,{||(cAliasRes)->DTINI       },"",,,"CENTER" ,CalcFieldSize("C",010                    ,0,""          ,"Data Inic."  ),.F.,.F.,,,,.F.))
         oBrwRes:AddColumn(TCColumn():New("Hora Inic." ,{||(cAliasRes)->HRINI       },"",,,"CENTER" ,CalcFieldSize("C",010                    ,0,""          ,"Hora Inic."  ),.F.,.F.,,,,.F.))
         oBrwRes:AddColumn(TCColumn():New("Data Final" ,{||(cAliasRes)->DTFIN       },"",,,"CENTER" ,CalcFieldSize("C",010                    ,0,""          ,"Data Final"  ),.F.,.F.,,,,.F.))
         oBrwRes:AddColumn(TCColumn():New("Hora Final" ,{||(cAliasRes)->HRFIN       },"",,,"CENTER" ,CalcFieldSize("C",010                    ,0,""          ,"Hora Final"  ),.F.,.F.,,,,.F.))
         oBrwRes:AddColumn(TCColumn():New("Tempo"      ,{||(cAliasRes)->TEMPO       },"",,,"CENTER" ,CalcFieldSize("C",010                    ,0,""          ,"Tempo"       ),.F.,.F.,,,,.F.))
                 
         oBrwRes:Align      := CONTROL_ALIGN_ALLCLIENT
         
         oBrwRes:SetPopup(Eval({|m|;
            m:Add(TMenuItem():New(oPanel,             ;
            "Visualizar Log"     ,,,,bPreview,"BMPVISUAL","BMPVISUAL",,,,,,,.T.)), ;
         , m },TMenu():New(0,0,0,0,.T.)))

      
   //Exibe somente os processos selecionados.
   SetFilMark(.T.,oBrwRes)
Return .T.

*****************************
Static Function Exec(oWizard)
*****************************
   Local lRet       := .T.
   Local nPrc       := 1
   Local aRec       := {}
   Local aResumo    := {}
   Local nX         := 0
   Local aAreaZVJ   := ZVJ->(FWGetArea())
   Local lSuccess   := .F.
   Local cFileLog   := ""
   Local cProcess   := ""
   Local cCodPrc    := ""
   Local lPreVldEx  := .F.
   Local bPreVldEx  := {|| lPreVldEx := PreVldExec() }
   
   If lChkSalvar 
      SavePkg()
   Endif
   
   If !lChkExec
      return .T.
   Endif
   
   (cAliasRes)->(DbGotop())
   (cAliasRes)->(DbEval({|| If(XCHECK,Aadd(aRec,Recno()),) }))
   nTot := Len(aRec)
   
   If nTot == 0
      ZVJ->(FWRestArea(aAreaZVJ))
      return .F.
   Endif
   
   MsgRun( "Validando os processos..." , "Aguarde..." , bPreVldEx )   
   If ! lPreVldEx
      return .F.
   Endif

   cDataIni := DtoS(dDataBase)
   cHoraIni := Time()
   
   ZVJ->(DbSetOrder(1)) //ZVJ_FILIAL+ZVJ_CODIGO
   oWizard:DisableButtons()
   
   BEGIN SEQUENCE
   
      oMtrProc:SetTotal(nTot)
      
      For nX := 1 To Len(aRec)
          
          (cAliasRes)->(DbGoTo(aRec[nX]))
          
          If ! ZVJ->(MsSeek(xFilial("ZVJ")+(cAliasRes)->ZVJ_CODIGO))
             Loop
          Endif

          cCodPrc  := AllTrim((cAliasRes)->ZVJ_CODIGO)
          cProcess := AllTrim((cAliasRes)->ZVJ_DESTIN)
          
          oSayMsg1:SetText(StrTran('Importando "{1}"...',"{1}",AllTrim((cAliasRes)->ZVJ_DESC)))
          If (cAliasRes)->(RecLock(cAliasRes,.F.))
             (cAliasRes)->XSTATUS := "1"
             (cAliasRes)->(MsUnLock())
          EndIf
          oMtrProc:Set(nPrc)
          
          oBrwExe:Refresh()
          ProcessMessages()
          
          If AT((cAliasRes)->ZVJ_TPIMP,"3|5") > 0 .And. ! CriaTabTmp()
             (cAliasRes)->(RecLock(cAliasRes,.F.))
             (cAliasRes)->XSTATUS := "3" //ERROR
             (cAliasRes)->(MsUnLock())
             nPrc++
             oBrwExe:Skip(1)
             Loop
          Endif
          
          If TruncaTab() 
             SelectImp()
          Endif
          
          aResumo := GetStatPrc(cDataIni,cHoraIni) //Obtém o status do processo
          
          lSuccess := ! Empty(aResumo) .And. (aResumo[1,3] > 0 .and. aResumo[1,3] == aResumo[1,4]) 
          
          (cAliasRes)->(RecLock(cAliasRes,.F.))
          IF lSuccess
             (cAliasRes)->XSTATUS := "9" //SUCCESS
          Else
             (cAliasRes)->XSTATUS := "3" //ERROR
          EndIf
          
          MsgRun( "Gerando o log... ("+cProcess+")" , "Aguarde..." , { || cFileLog := u_GerRel(cCodPrc,cDataIni,cHoraIni) } )
                    
          If ! Empty(aResumo)
             (cAliasRes)->DTINI     := aResumo[1,5]
             (cAliasRes)->HRINI     := aResumo[1,6]
             (cAliasRes)->DTFIN     := aResumo[1,7]
             (cAliasRes)->HRFIN     := aResumo[1,8]
             (cAliasRes)->TOTAL     := aResumo[1,3]
             (cAliasRes)->GRAVADOS  := aResumo[1,4]
             (cAliasRes)->TEMPO     := aResumo[1,9]
             (cAliasRes)->ARQLOG    := cFileLog
          Endif
          (cAliasRes)->(MsUnLock())
          
          nPrc++
          
          oBrwExe:Skip(1)
          oBrwExe:Refresh()
          	
          ProcessMessages()
      Next
      
      cDataFin := DtoS(dDataBase)
      cHoraFin := Time()
      
      oBrwExe:GoTop()
      oBrwExe:Refresh()
      
      MsgInfo("Processo concluído!")
   END SEQUENCE

   oWizard:EnableButtons()
   
   ZVJ->(FWRestArea(aAreaZVJ))
   
   __lPackage := .F.
   
Return lRet 

*********************************************
Static Function GetStatPrc(cDataRef,cHoraRef)
*********************************************
   Local aRet      := {}
   Local cCodProc  := AllTrim(ZVJ->ZVJ_CODIGO)
   Local cProcesso := AllTrim(ZVJ->ZVJ_DESTIN)
   Local cTpImp    := AllTrim(ZVJ->ZVJ_TPIMP)
   Local cQryAna   := ""
   Local cQrySin   := ""
   Local cAliasSin := GetNextAlias()
   Local nX        := 0
    
   Do Case
      Case ( cTpImp $ "1|2|4" ) //Validação (ZVJ/ZVK)/SQL Loader
           cQrySin += "SELECT SZ2.Z2_NUMLOTE NUMLOTE, SZ2.Z2_CODTAB TABELA, SZ2.Z2_TOTLINH TOTLINH, SZ2.Z2_TOTGRAV TOTGRAV,                                                                                                     " + CRLF
           cQrySin += "    TO_CHAR(TO_DATE(SZ2.Z2_DATAINI,'YYYYMMDD'),'DD/MM/YYYY') DATAINI, SZ2.Z2_HORAINI HORAINI, TO_CHAR(TO_DATE(SZ2.Z2_DATAFIM,'YYYYMMDD'),'DD/MM/YYYY') DATAFIM, SZ2.Z2_HORAFIM HORAFIM,                  " + CRLF
           cQrySin += "    LPAD(trunc(( (TO_DATE(SZ2.Z2_DATAFIM||' '||SZ2.Z2_HORAFIM,'YYYYMMDD HH24:MI:SS')-TO_DATE(SZ2.Z2_DATAINI||' '||SZ2.Z2_HORAINI,'YYYYMMDD HH24:MI:SS')) * 86400 / 3600)),2,'0') ||':' ||                " + CRLF
           cQrySin += "    LPAD(trunc(mod( (TO_DATE(SZ2.Z2_DATAFIM||' '||SZ2.Z2_HORAFIM,'YYYYMMDD HH24:MI:SS') - TO_DATE(SZ2.Z2_DATAINI||' '||SZ2.Z2_HORAINI,'YYYYMMDD HH24:MI:SS')) * 86400 , 3600 ) / 60 ),2,'0') || ':'||    " + CRLF
           cQrySin += "    LPAD(trunc(mod ( mod ( (TO_DATE(SZ2.Z2_DATAFIM||' '||SZ2.Z2_HORAFIM,'YYYYMMDD HH24:MI:SS') - TO_DATE(SZ2.Z2_DATAINI||' '||SZ2.Z2_HORAINI,'YYYYMMDD HH24:MI:SS')) * 86400, 3600 ), 60 )),2,'0') Tempo," + CRLF
           cQrySin += "    SZ2.Z2_MAXREC, SZ2.Z2_ARQUIVO, SZ2.Z2_URI                                                                                                                                                            " + CRLF
           cQrySin += "FROM "+RetSqlName("SZ2")+" SZ2                                                                                                                                                                           " + CRLF
           cQrySin += "WHERE SZ2.D_E_L_E_T_ = ' '                                                                                                                                                                               " + CRLF
           cQrySin += "  AND SZ2.Z2_DATAFIM <> ' ' AND SZ2.Z2_HORAINI <> ' '                                                                                                                                                    " + CRLF
           cQrySin += "  AND SZ2.Z2_DATAINI >= '"+cDataRef+"' AND TRIM(SZ2.Z2_HORAINI) >= '"+cHoraRef+"'                                                                                                                        " + CRLF
           cQrySin += "  AND SZ2.Z2_XMIGLT = (SELECT MAX(XSZ2.Z2_XMIGLT) FROM "+RetSqlName("SZ2")+" XSZ2 WHERE XSZ2.D_E_L_E_T_=' ' AND XSZ2.Z2_CODPRC = '"+cCodProc+"'  )                                                       " + CRLF		   
           cQrySin += "ORDER BY SZ2.Z2_UKEY                                                                                                                                                                                     "
           
      Case ( AT(cTpImp,"3|5") > 0 ) //Stored Procedure/Banco.
           cQrySin += "SELECT RES.NUMEROLOTE NUMLOTE, '"+cProcesso+"' TABELA, RES.QTDE_REGISTROS TOTLINH, RES.QTDE_LNLIDAS TOTGRAV,                                                                                                " + CRLF
           cQrySin += "   TO_CHAR(TO_DATE(RES.DATA_INICIAL,'YYYYMMDD'),'DD/MM/YYYY') DATAINI, RES.HORA_INICIAL HORAINI,                                                                                                            " + CRLF
           cQrySin += "   TO_CHAR(TO_DATE(RES.DATA_FINAL,'YYYYMMDD'),'DD/MM/YYYY') DATAFIM, RES.HORA_FINAL HORAFIM,                                                                                                                " + CRLF
           cQrySin += "   LPAD(trunc(( (TO_DATE(RES.DATA_FINAL||' '||RES.HORA_FINAL,'YYYYMMDD HH24:MI:SS')-TO_DATE(RES.DATA_INICIAL||' '||RES.HORA_INICIAL,'YYYYMMDD HH24:MI:SS')) * 86400 / 3600)),2,'0') ||':' ||                " + CRLF
           cQrySin += "   LPAD(trunc(mod( (TO_DATE(RES.DATA_FINAL||' '||RES.HORA_FINAL,'YYYYMMDD HH24:MI:SS') - TO_DATE(RES.DATA_INICIAL||' '||RES.HORA_INICIAL,'YYYYMMDD HH24:MI:SS')) * 86400 , 3600 ) / 60 ),2,'0') || ':'||    " + CRLF
           cQrySin += "   LPAD(trunc(mod ( mod ( (TO_DATE(RES.DATA_FINAL||' '||RES.HORA_FINAL,'YYYYMMDD HH24:MI:SS') - TO_DATE(RES.DATA_INICIAL||' '||RES.HORA_INICIAL,'YYYYMMDD HH24:MI:SS')) * 86400, 3600 ), 60 )),2,'0') Tempo," + CRLF
           cQrySin += "   RES.MAXRECNO                                                                                                                                                                                             " + CRLF
           cQrySin += "FROM ARQ"+cProcesso+"_RESUMO RES                                                                                                                                                                            " + CRLF
           cQrySin += "WHERE RES.NUMEROLOTE = (SELECT MAX(R.NUMEROLOTE) FROM ARQ"+cProcesso+"_RESUMO R)                                                                                                                            " + CRLF
           cQrySin += "   AND RES.DATA_INICIAL >= '"+cDataRef+"' AND RES.HORA_INICIAL >= '"+cHoraRef+"'                                                                                                                            "
      Otherwise
           MsgStop("Não foi possível identificar o método de importação utilizado! Verifique.")
           return {}
   EndCase
   
   If ( Select(cAliasSin) > 0 )
      (cAliasSin)->(DbCloseArea())
   Endif
   
   TCQUERY cQrySin NEW ALIAS (cAliasSin)
   
   nFCount := (cAliasSin)->(FCount())
   Aadd(aRet,Array(nFCount))
   For nX := 1 To nFCount 
       aRet[Len(aRet),nX] := (cAliasSin)->(FieldGet(nX))
   Next nX 

   If ( Select(cAliasSin) > 0 )
      (cAliasSin)->(DbCloseArea())
   Endif
      
Return aRet 

**********************************
Static Function GetDir(nDir)                     
// 0 = WorkDir ("\CNCTAEXP\")
// 1 = ExpDir ("\CNCTAEXP\exp")
// 2 = ZipDir ("\CNCTAEXP\zip")
// 3 = DirRmt ("C:\CNCTAEXP\exp")
**********************************
  //Local cRootPath   := GetSrvProfString("RootPath","") + "\sigadoc\"   //--- "\sigadoc_hml\"
  Local cRootPath   := "\sigadoc\"
  Local cRet        := ""

  If (AT(":",cRootPath) > 0)
     cRootPath := Substr(cRootPath,AT(":",cRootPath)+1)
  Endif
  
   Do Case
         Case (nDir == 0) 
              cRet := cRootPath + "CNCTAPKG\"
         Case (nDir == 1)
              cRet := cRootPath + "CNCTAPKG\LOGS\"
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

*****************************************************
User Function GerRel(cCodProc,cDataRef,cHoraRef)
*****************************************************
   Local lRet       := .T.
   Local cTpImp     := AllTrim(ZVJ->ZVJ_TPIMP)
   Local cQryAna    := ""
   Local cQrySin1   := ""
   Local cQrySin2   := ""
   Local cAliasSin1 := GetNextAlias()
   Local cAliasSin2 := GetNextAlias()
   Local cAliasAna  := GetNextAlias()
   Local cFileRpt   := ""
   Local aHeadSin1  := {"ID CARGA","NR.LOTE","TABELA","TOTAL REGISTROS","IMPORTADOS","DATA INI.","HORA INI.","DATA FIN.","HORA FIN.","TEMPO","ULT.RECNO","ARQUIVO","URI Anexo"}
   Local aHeadSin2  := {"ARQUIVO","DESCRIÇÃO","CAMPO","QTD.OCORRÊNCIAS"}
   Local aHeadAna   := {}
   Local cRow       := ""
   Local nX         := 0
   Local aAreaSZ3   := SZ3->(FWGetArea())
   Local cProcesso := AllTrim(ZVJ->ZVJ_DESTIN)

   Default cCodProc  := ZVJ->ZVJ_CODIGO
   Default cDataRef  := "19000101"
   Default cHoraRef  := "00:00:00"
   
   If ( cTpImp $ "1|2" )
      aHeadSin2 := {"FILIAL", "COD.LOG", "DESCRIÇÃO", "CAMPO", "DESCR.CAMPO", "QTD.OCORRÊNCIAS"}
   ElseIf ( cTpImp == "4" )
      aHeadSin2 := {"FILIAL", "OCORRÊNCIA", "QUANTIDADE"}
   Endif
   
   cFileRpt   := GetFileRpt(cProcesso)
   
   Do Case
      Case ( cTpImp $ "1|2|4" ) //Validação (ZVJ/ZVK)/SQL Loader
           //Sintético (Cabeçalho)
           cQrySin1 += "SELECT SZ2.Z2_XMIGLT, SZ2.Z2_NUMLOTE NUMLOTE, SZ2.Z2_CODTAB TABELA, SZ2.Z2_TOTLINH TOTLINH, SZ2.Z2_TOTGRAV TOTGRAV,                                                                                      " + CRLF
           cQrySin1 += "    TO_CHAR(TO_DATE(SZ2.Z2_DATAINI,'YYYYMMDD'),'DD/MM/YYYY') DATAINI, SZ2.Z2_HORAINI HORAINI, TO_CHAR(TO_DATE(SZ2.Z2_DATAFIM,'YYYYMMDD'),'DD/MM/YYYY') DATAFIM, SZ2.Z2_HORAFIM HORAFIM,                  " + CRLF
           cQrySin1 += "    LPAD(trunc(( (TO_DATE(SZ2.Z2_DATAFIM||' '||SZ2.Z2_HORAFIM,'YYYYMMDD HH24:MI:SS')-TO_DATE(SZ2.Z2_DATAINI||' '||SZ2.Z2_HORAINI,'YYYYMMDD HH24:MI:SS')) * 86400 / 3600)),2,'0') ||':' ||                " + CRLF
           cQrySin1 += "    LPAD(trunc(mod( (TO_DATE(SZ2.Z2_DATAFIM||' '||SZ2.Z2_HORAFIM,'YYYYMMDD HH24:MI:SS') - TO_DATE(SZ2.Z2_DATAINI||' '||SZ2.Z2_HORAINI,'YYYYMMDD HH24:MI:SS')) * 86400 , 3600 ) / 60 ),2,'0') || ':'||    " + CRLF
           cQrySin1 += "    LPAD(trunc(mod ( mod ( (TO_DATE(SZ2.Z2_DATAFIM||' '||SZ2.Z2_HORAFIM,'YYYYMMDD HH24:MI:SS') - TO_DATE(SZ2.Z2_DATAINI||' '||SZ2.Z2_HORAINI,'YYYYMMDD HH24:MI:SS')) * 86400, 3600 ), 60 )),2,'0') Tempo," + CRLF
           cQrySin1 += "    SZ2.Z2_MAXREC, SZ2.Z2_ARQUIVO, SZ2.Z2_URI                                                                                                                                                            " + CRLF
           cQrySin1 += "FROM "+RetSqlName("SZ2")+" SZ2                                                                                                                                                                           " + CRLF
           cQrySin1 += "WHERE SZ2.D_E_L_E_T_ = ' '                                                                                                                                                                               " + CRLF
           cQrySin1 += "  AND SZ2.Z2_DATAFIM <> ' ' AND SZ2.Z2_HORAINI <> ' '                                                                                                                                                    " + CRLF
           cQrySin1 += "  AND SZ2.Z2_XMIGLT = (SELECT MAX(XSZ2.Z2_XMIGLT) FROM "+RetSqlName("SZ2")+" XSZ2 WHERE XSZ2.D_E_L_E_T_=' ' AND XSZ2.Z2_CODPRC = '"+cCodProc+"'  )                                                       " + CRLF		   
           cQrySin1 += "ORDER BY SZ2.Z2_UKEY                                                                                                                                                                                     "
           
           //Sintético Ocorrências
           If ( cTpImp == "4" )
              cQrySin2 += "SELECT SZ3.Z3_FILIAL, SZ3.Z3_DESCLOG, COUNT(1) QTD                                                    "+CRLF           
           Else
              cQrySin2 += "SELECT SZ3.Z3_FILIAL, SZ3.Z3_CODLOG, SZ3.Z3_DESCLOG, SZ3.Z3_CODCPO, SZ3.Z3_DESCPO, COUNT(1) QTD       "+CRLF
           Endif
           cQrySin2 += "FROM "+RetSqlName("SZ2") +" SZ2                                                                  " + CRLF
           cQrySin2 += "INNER JOIN "+RetSqlName("SZ3") +" SZ3 ON SZ3.D_E_L_E_T_=' ' AND SZ3.Z3_UKEYP=SZ2.Z2_UKEY         " + CRLF
           cQrySin2 += "WHERE SZ2.D_E_L_E_T_=' '                                                                         " + CRLF
           cQrySin2 += "  AND SZ2.Z2_DATAFIM <> ' ' AND SZ2.Z2_HORAINI <> ' '                                            " + CRLF
           cQrySin2 += "  AND SZ2.Z2_XMIGLT = (SELECT MAX(XSZ2.Z2_XMIGLT)                                                " + CRLF
           cQrySin2 += "                       FROM "+RetSqlName("SZ2") +" XSZ2 WHERE XSZ2.D_E_L_E_T_=' '                " + CRLF
           cQrySin2 += "                       AND XSZ2.Z2_CODPRC = '"+cCodProc+"')                                      " + CRLF
           cQrySin2 += "GROUP BY SZ3.Z3_FILIAL, SZ3.Z3_CODLOG, SZ3.Z3_DESCLOG, SZ3.Z3_CODCPO, SZ3.Z3_DESCPO              " + CRLF
           cQrySin2 += "ORDER BY SZ3.Z3_FILIAL, SZ3.Z3_CODLOG                                                            "            /*
           ** Analítico (SZ2/SZ3)
           */
           If ( cTpImp $ "1|2" ) //Validação ou SqlLoader
              cQryAna += "SELECT SZ3.Z3_NUMLOTE LOTE, SZ3.Z3_DATALOG DATA, SZ3.Z3_CODTAB TABELA, SZ3.Z3_NUMLINH LINHA, SZ3.Z3_CODLOG CODLOG,           " + CRLF
              cQryAna += "  SZ3.Z3_DESCLOG DESCRICAO, SZ3.Z3_CODCPO CAMPO, SZ3.Z3_DESCPO DESC_CAMPO, SZ3.Z3_CONTEUD CONTEUDO, SZ3.Z3_VALID VALIDACAO   " + CRLF
           ElseIf ( cTpImp == "4" ) //MsExecAuto
              cQryAna += "SELECT SZ3.Z3_FILIAL FILIAL, SZ3.Z3_CONTEUD CHAVE, SZ3.Z3_DESCLOG OCORRENCIA                                                 " + CRLF
           Endif
           cQryAna += "FROM "+RetSqlName("SZ2") +" SZ2                                                                  " + CRLF
           cQryAna += "INNER JOIN "+RetSqlName("SZ3") +" SZ3 ON SZ3.D_E_L_E_T_=' ' AND SZ3.Z3_UKEYP=SZ2.Z2_UKEY         " + CRLF
           cQryAna += "WHERE SZ2.D_E_L_E_T_=' '                                                                         " + CRLF
           cQryAna += "  AND SZ2.Z2_DATAFIM <> ' ' AND SZ2.Z2_HORAINI <> ' '                                            " + CRLF
           cQryAna += "  AND SZ2.Z2_XMIGLT = (SELECT MAX(XSZ2.Z2_XMIGLT)                                                " + CRLF
           cQryAna += "                       FROM "+RetSqlName("SZ2") +" XSZ2 WHERE XSZ2.D_E_L_E_T_=' '                " + CRLF
           cQryAna += "                       AND XSZ2.Z2_CODPRC = '"+cCodProc+"')                                      " + CRLF
           cQryAna += "ORDER BY SZ3.Z3_UKEY                                                                                                            " 
                      
      Case ( AT(cTpImp,"3|5") > 0 ) //Stored Procedure/Banco.
           //Sintético (Cabeçalho)
           cQrySin1 += "SELECT RES.NUMEROLOTE NUMLOTE, '"+cProcesso+"' TABELA, RES.QTDE_REGISTROS TOTLINH, RES.QTDE_LNLIDAS TOTGRAV,                                                                                                " + CRLF
           cQrySin1 += "   TO_CHAR(TO_DATE(RES.DATA_INICIAL,'YYYYMMDD'),'DD/MM/YYYY') DATAINI, RES.HORA_INICIAL HORAINI,                                                                                                            " + CRLF
           cQrySin1 += "   TO_CHAR(TO_DATE(RES.DATA_FINAL,'YYYYMMDD'),'DD/MM/YYYY') DATAFIM, RES.HORA_FINAL HORAFIM,                                                                                                                " + CRLF
           cQrySin1 += "   LPAD(trunc(( (TO_DATE(RES.DATA_FINAL||' '||RES.HORA_FINAL,'YYYYMMDD HH24:MI:SS')-TO_DATE(RES.DATA_INICIAL||' '||RES.HORA_INICIAL,'YYYYMMDD HH24:MI:SS')) * 86400 / 3600)),2,'0') ||':' ||                " + CRLF
           cQrySin1 += "   LPAD(trunc(mod( (TO_DATE(RES.DATA_FINAL||' '||RES.HORA_FINAL,'YYYYMMDD HH24:MI:SS') - TO_DATE(RES.DATA_INICIAL||' '||RES.HORA_INICIAL,'YYYYMMDD HH24:MI:SS')) * 86400 , 3600 ) / 60 ),2,'0') || ':'||    " + CRLF
           cQrySin1 += "   LPAD(trunc(mod ( mod ( (TO_DATE(RES.DATA_FINAL||' '||RES.HORA_FINAL,'YYYYMMDD HH24:MI:SS') - TO_DATE(RES.DATA_INICIAL||' '||RES.HORA_INICIAL,'YYYYMMDD HH24:MI:SS')) * 86400, 3600 ), 60 )),2,'0') Tempo," + CRLF
           cQrySin1 += "   RES.MAXRECNO                                                                                                                                                                                             " + CRLF
           cQrySin1 += "FROM ARQ"+cProcesso+"_RESUMO RES                                                                                                                                                                            " + CRLF
           cQrySin1 += "WHERE RES.NUMEROLOTE = (SELECT MAX(R.NUMEROLOTE) FROM ARQ"+cProcesso+"_RESUMO R)                                                                                                                            " + CRLF
           cQrySin1 += "   AND RES.DATA_INICIAL >= '"+cDataRef+"' AND RES.HORA_INICIAL >= '"+cHoraRef+"'                                                                                                                            "
           //SP: Sintético Ocorrências
           cQrySin2 += "SELECT LOG.NOME_ARQUIVO ARQUIVO, LOG.DESC_ERRO DESCRICAO, LOG.DESC_CAMPO CAMPO, COUNT(1) QTD "+CRLF
           cQrySin2 += "FROM ARQ"+cProcesso+"_LOG LOG                                                                "+CRLF
           cQrySin2 += "WHERE LOG.NUMEROLOTE = (SELECT MAX(R.NUMEROLOTE) FROM ARQ"+cProcesso+"_RESUMO R)             "+CRLF
           cQrySin2 += "GROUP BY LOG.NOME_ARQUIVO, LOG.DESC_ERRO, LOG.DESC_CAMPO                                     "+CRLF
           cQrySin2 += "ORDER BY LOG.NOME_ARQUIVO, COUNT(1) DESC                                                     "
           
           //Analítico (Stored Procedure)
           cQryAna += "SELECT LG.NUMEROLOTE, LG.NOME_ARQUIVO, LG.LINHA, LG.CHAVE, LG.DESC_CAMPO, LG.CONTEUDO_CAMPO, LG.DESC_ERRO " + CRLF
           cQryAna += "FROM ARQ"+cProcesso+"_LOG LG                                                                              " + CRLF
           cQryAna += "WHERE LG.NUMEROLOTE = (SELECT MAX(R.NUMEROLOTE) FROM ARQ"+cProcesso+"_RESUMO R                            " + CRLF
           cQryAna += "                       WHERE R.DATA_INICIAL >= '"+cDataRef+"' AND R.HORA_INICIAL >= '"+cHoraRef+"')       " 
           
      Otherwise
           MsgStop("Não foi possível identificar o método de importação utilizado! Verifique.")
           return ""
   EndCase
   
   If File(cFileRpt)
      nHandle := FOpen(cFileRpt)
   Else
      nHandle := FCreate(cFileRpt)
   Endif

   If nHandle = -1
      MsgStop("Erro ao criar arquivo - ferror " + Str(FError()))
      Return ""
   Endif

   ////////////////////////////////////////////////////////////////////////////////////////////////
   // Sintético (Cabeçalho)
   ////////////////////////////////////////////////////////////////////////////////////////////////
   TCQUERY cQrySin1 NEW ALIAS (cAliasSin1)
   
   If (cAliasSin1)->(!Eof())
      FWrite(nHandle,"R E S U M O   D O   P R O C E S S O   ("+cProcesso+")" + CRLF)
      cRow := ""
      AEval(aHeadSin1,{|h| cRow += (h + ";")})
      FWrite(nHandle,cRow  + CRLF)
   Endif
   
   nFCount := (cAliasSin1)->(FCount())
   
   While (cAliasSin1)->(!Eof())
         cRow := ""
         For nX := 1 To nFCount 
             cRow += If((cAliasSin1)->(Field(nX)) == "Z2_URI","",CHR(160))+cValToChar((cAliasSin1)->(FieldGet(nX)))
             If nX < nFCount
                cRow += ";"
             Endif
         Next nX
	     FWrite(nHandle,cRow + CRLF)
         
         (cAliasSin1)->(DbSkip(1))
   Enddo

   If ( Select(cAliasSin1) > 0 )
      (cAliasSin1)->(DbCloseArea())
   Endif

   ////////////////////////////////////////////////////////////////////////////////////////////////
   // Sintético Ocorrências
   ////////////////////////////////////////////////////////////////////////////////////////////////
   TCQUERY cQrySin2 NEW ALIAS (cAliasSin2)
   
   If (cAliasSin2)->(!Eof())
	  FWrite(nHandle,CRLF)
      FWrite(nHandle,"O C O R R Ê N C I A S   ("+cProcesso+")" + CRLF)
      cRow := ""
      AEval(aHeadSin2,{|h| cRow += (h + ";")})
	  FWrite(nHandle,cRow  + CRLF)
   Endif
   
   nFCount := (cAliasSin2)->(FCount())

   While (cAliasSin2)->(!Eof())
         cRow := ""
         For nX := 1 To nFCount 
             cRow += CHR(160)+cValToChar((cAliasSin2)->(FieldGet(nX)))
             If nX < nFCount
                cRow += ";"
             Endif
         Next nX
	     FWrite(nHandle,cRow + CRLF)
         
         (cAliasSin2)->(DbSkip(1))
   Enddo

   If ( Select(cAliasSin2) > 0 )
      (cAliasSin2)->(DbCloseArea())
   Endif
   
   ////////////////////////////////////////////////////////////////////////////////////////////////
   // Analítico
   ////////////////////////////////////////////////////////////////////////////////////////////////
   TCQUERY cQryAna NEW ALIAS (cAliasAna)
   
   If (cAliasAna)->(!Eof())
      nFCount  := (cAliasAna)->(FCount())
      For nX := 1 To nFCount
          Aadd(aHeadAna, (cAliasAna)->(FieldName(nX)) )
      Next
   
	  FWrite(nHandle,CRLF)
      FWrite(nHandle,"A N A L Í T I C O  ("+cProcesso+")" + CRLF)
      cRow := ""
      AEval(aHeadAna,{|h| cRow += (h + ";")})
	  FWrite(nHandle,cRow  + CRLF)
   Endif

   SZ3->(DbSetOrder(1)) //Z3_FILIAL + Z3_UKEY
      
   While (cAliasAna)->(!Eof())
         cRow := ""
         For nX := 1 To nFCount 
             
             cRow += CHR(160)+cValToChar((cAliasAna)->(FieldGet(nX)))

             If nX < nFCount
                cRow += ";"
             Endif
         Next nX
	     FWrite(nHandle,cRow + CRLF)
         
         (cAliasAna)->(DbSkip(1))
   Enddo

   If ( Select(cAliasAna) > 0 )
      (cAliasAna)->(DbCloseArea())
   Endif
   
   FClose(nHandle)
   
   FWRestArea(aAreaSZ3)
   
Return cFileRpt 

/**
 * Retorna o nome do arquivo de Relatório, conforme a chave (cKeyLog)
 *
 * @author Roberto Amâncio Teixeira
 * @date 17/11/2017
 * 
 * @return caracter
*/ 
***********************************
Static Function GetFileRpt(cKeyLog)
***********************************
	Local cDirLog  := GetDir(1)
	Local cSufixo  := "9"
	Local bLogFile := {|| cSufixo := Soma1(cSufixo), cDirLog + cKeyLog + "_" + DtoS(Date()) + "_" + cSufixo + ".csv" }
	
	cRet := Eval(bLogFile)
	While File(cRet)
		  cRet := Eval(bLogFile)
	EndDo
	
return cRet

************************************
Static Function SetOrdem(lDown,oBrw)
************************************
   Local lRet  := .F.
   Local nRec1 := (cAliasRes)->(Recno())
   Local nRec2 := 0
   Local nOrd1 := (cAliasRes)->ORDEM
   Local nOrd2 := 0

   If lDown .And. (cAliasRes)->(!Eof())
      (cAliasRes)->(DbSkip(1))
      nRec2 := (cAliasRes)->(Recno())
      nOrd2 := (cAliasRes)->ORDEM
   Endif
   
   If !lDown .And. (cAliasRes)->(!Bof())
      (cAliasRes)->(DbSkip(-1))
      nRec2 := (cAliasRes)->(Recno())
      nOrd2 := (cAliasRes)->ORDEM
   Endif
   
   lRet := (nRec2 > 0) .And. (nOrd1 != nOrd2) .And. ( (lDown .And. (cAliasRes)->(!Eof())) .OR. (!lDown .And. (cAliasRes)->(!Bof())) ) 
   
   If lRet
      //Está posicionado em nRec2
      RecLock(cAliasRes,.F.)
      (cAliasRes)->ORDEM  := nOrd1 //Seta a ordem de nRec1 para nRec2.
      
      (cAliasRes)->(DbGoTo(nRec1)) //Reposiciona em nRec1 e seta a ordem para nOrd2.
      (cAliasRes)->ORDEM  := nOrd2 //Seta a ordem de nRec1 para nRec2.
      
      (cAliasRes)->(MsUnLock())
   Endif
         
   oBrw:Refresh() 
         
Return lRet

***************************
Static Function TruncaTab()
***************************
   Local lRet      := .T.
   Local cTpImp    := AllTrim((cAliasRes)->ZVJ_TPIMP)
   Local lTruncar  := (cAliasRes)->XFULL
   Local aCommands := {}
   Local nX        := 0
   Local cDestin   := AllTrim((cAliasRes)->ZVJ_DESTIN)
   Local cTarget   := RetSqlName(cDestin)
   Local cSequence := cTarget+"_SEQ"

   /*  Recria a sequence da tabela */
   //lRet := CreateSeq(cSequence,cDestin)
   //If !lRet
   //   return .F. 
   //Endif
   /*FIM:  Recria a sequence da tabela */

   ExistSeq(cSequence)
   
   If !lTruncar
      Return .T.
   Endif
   
   If cTpImp $ "1|2|4" //Validação (ZVJ/ZVK) ou MsExecAuto
      Aadd(aCommands,"TRUNCATE TABLE "+cTarget)
   ElseIf AT(cTpImp,"3|5") > 0 //Stored Procedure OU SP s/Loader
      Aadd(aCommands,"TRUNCATE TABLE "+cTarget)
      If (cTpImp == "3")
         Aadd(aCommands,StrTran("DELETE FROM ARQ{1} WHERE NUMEROLOTE = (SELECT MAX(NUMEROLOTE) FROM ARQ{1})","{1}",cDestin))
      Endif
      Aadd(aCommands,StrTran("DELETE FROM ARQ{1}_LOG WHERE NUMEROLOTE = (SELECT MAX(NUMEROLOTE) FROM ARQ{1})","{1}",cDestin))
      Aadd(aCommands,StrTran("DELETE FROM ARQ{1}_RESUMO WHERE NUMEROLOTE = (SELECT MAX(NUMEROLOTE) FROM ARQ{1})","{1}",cDestin))
   Endif
   
   For nX := 1 To Len(aCommands)
       If (TCSQLExec(aCommands[nX]) < 0)
          MsgStop("Erro ao executar o comando: " +CRLF + aCommands[nX] + CRLF + CRLF + TCSQLError())
          lRet := .F.
          Exit
       Endif
   Next nX
   
Return lRet   
   
*************************   
Static Function InitPkg()
*************************
   Local lRet     := .T.
   Local bCriaTmp := {|| lRet := CriaTemp(cAliasRes) }
   
   MsgRun( "Inicializando o pacote de importação..." , "Aguarde..." , bCriaTmp )

Return lRet
    
***********************************    
Static Function ChangeExec(oWizard)
***********************************
   If lChkExec
      oWizard:SetFinish()
   Else
      oWizard:RefreshButtons()
   Endif
return .T.   

****************************
Static Function PreVldExec()
****************************
   Local lRet      := .T.
   Local aFiles    := {}
   Local cMask     := ""
   Local cPath     := ""
   Local cProcesso := "" 
   Local nRetSinc  := 0
   Local cTpImp    := ""
   
   (cAliasRes)->(DbGotop())
   While (cAliasRes)->(!Eof())
         If ! (cAliasRes)->XCHECK
            (cAliasRes)->(DbSkip(1))
            Loop     
         Endif
         
         cProcesso := AllTrim((cAliasRes)->ZVJ_DESTIN)
         cTpImp    := AllTrim((cAliasRes)->ZVJ_TPIMP)         
         
         U_CNCTAVLD((cAliasRes)->ZVJ_CODIGO,.F.,.T.,@nRetSinc)
         
         nRetSinc := 0 //teste,roberto,carga em 2018-06-25
         
         cPath := AllTrim((cAliasRes)->ZVJ_DIRIMP)
         cPath := Left(cPath,RAT("\",cPath))
         cMask := AllTrim((cAliasRes)->ZVJ_DESTIN)+'*.TXT'
         
         aFiles := Directory(cPath + cMask)
         
         IF (cAliasRes)->(RecLock(cAliasRes,.F.))
            (cAliasRes)->XSTATUS  := If(cTpImp == "5"," ",If(Empty(aFiles),"3"," "))
            (cAliasRes)->XREFRESH := If(nRetSinc == 0," ",cValToChar(nRetSinc))
            (cAliasRes)->(MsUnLock())
         EndIf
         
         If lRet .And. ((cAliasRes)->XSTATUS == "3")
            lRet := .F.
         Endif
         
         (cAliasRes)->(DbSkip(1))
   Enddo 

   (cAliasRes)->(DbGotop())
   oBrwExe:Refresh()
   
return lRet   

****************************
Static Function CriaTabTmp()
****************************
   Local lRet       := .T.
   Local cProcesso  := AllTrim((cAliasRes)->ZVJ_DESTIN)
   Local cCmdTab    := ""
   Local cCmdLog    := ""
   Local cCmdRes    := ""
   Local cNomTab    := Alltrim(SuperGetMV('ES_PRFTBMG',,'ARQ'))+cProcesso
   Local cNomLog    := cNomTab+"_LOG"                                    
   Local cNomRes    := cNomTab+"_RESUMO"        
   Local aUnique    := GetUnique(cProcesso)
   Local cCmdInd    := ""
   
   If MsFile(cNomTab) .And. MsFile(cNomLog) .And. MsFile(cNomRes)
      Return .T.
   Endif
   
   If !MsFile(cNomTab)
      cCmdTab := GetScriptTb(cNomTab)
   Endif

   If !MsFile(cNomLog)
       cCmdLog += "CREATE TABLE "+cNomLog+"                          "+CRLF
       cCmdLog += "( NUMEROLOTE CHAR(15 BYTE) NOT NULL ENABLE,       "+CRLF
       cCmdLog += "  NOME_ARQUIVO CHAR(100 BYTE) NOT NULL ENABLE,    "+CRLF
       cCmdLog += "  LINHA NUMBER DEFAULT 0 NULL,                    "+CRLF
       cCmdLog += "  CHAVE CHAR(300 BYTE) NOT NULL ENABLE,           "+CRLF
       cCmdLog += "  DESC_CAMPO CHAR(15 BYTE) NOT NULL ENABLE,       "+CRLF
       cCmdLog += "  CONTEUDO_CAMPO CHAR(300 BYTE) NOT NULL ENABLE,  "+CRLF
       cCmdLog += "  DESC_ERRO CHAR(300 BYTE) NOT NULL ENABLE)       "   
   Endif   
   
   If !MsFile(cNomRes)
      cCmdRes += "CREATE TABLE "+cNomRes+"                      "+CRLF
      cCmdRes += "(NUMEROLOTE CHAR(15 BYTE) NOT NULL ENABLE,    "+CRLF
      cCmdRes += " DATA_INICIAL CHAR(8 BYTE) NOT NULL ENABLE,   "+CRLF
      cCmdRes += " HORA_INICIAL CHAR(8 BYTE) NOT NULL ENABLE,   "+CRLF
      cCmdRes += " NOME_ARQUIVO CHAR(100 BYTE) NOT NULL ENABLE, "+CRLF
      cCmdRes += " QTDE_REGISTROS NUMBER(*,0),                  "+CRLF
      cCmdRes += " TAMANHO_KB FLOAT(126),                       "+CRLF
      cCmdRes += " QTDE_LNLIDAS NUMBER(*,0),                    "+CRLF
      cCmdRes += " DATA_FINAL CHAR(8 BYTE),                     "+CRLF
      cCmdRes += " HORA_FINAL CHAR(8 BYTE),                     "+CRLF
      cCmdRes += " XMIGLT CHAR(28 BYTE) DEFAULT ' ',            "+CRLF
      cCmdRes += " STATUSVLD CHAR(1 BYTE) DEFAULT ' ',          "+CRLF
      cCmdRes += " STATUSIMP CHAR(1 BYTE) DEFAULT ' ',          "+CRLF
      cCmdRes += " STATUSTRF CHAR(1 BYTE) DEFAULT ' ')          "   
   Endif
   
   If ! Empty(cCmdTab) 
      If (TcSQLExec(cCmdTab) != 0)
         MsgAlert(AllTrim(TCSQLERROR()),'Não foi possível criar a tabela "'+cNomTab+'".')
         return .F.
      Endif
      
      If ! Empty(aUnique)
           cCmdInd := ArrTokStr(aUnique,",")
           cCmdInd := U_FmtStr("CREATE UNIQUE INDEX "+cNomTab+"_BUSINESS ON "+cNomTab+" (NumeroLote,{1}) ",{cCmdInd})
           If (TcSQLExec(cCmdInd) != 0)
              MsgAlert(AllTrim(TCSQLERROR()),'Erro durante a criação do índice "'+cNomTab+'_BUSINESS".')
              return .F.
           Endif
      Endif
   Endif
   
   If ! Empty(cCmdLog) 
      If (TcSQLExec(cCmdLog) != 0)
         MsgAlert(AllTrim(TCSQLERROR()),'Não foi possível criar a tabela "'+cNomLog+'".')
      Endif
   Endif

   If ! Empty(cCmdRes) 
      If (TcSQLExec(cCmdRes) != 0)
         MsgAlert(AllTrim(TCSQLERROR()),'Não foi possível criar a tabela "'+cNomRes+'".')
      Else
         cCmdRes := "CREATE UNIQUE INDEX "+cNomRes+"_UNQ ON "+cNomRes+" (NumeroLote,Nome_Arquivo) "  
         If (TcSQLExec(cCmdRes) != 0)
            MsgAlert(AllTrim(TCSQLERROR()),'Erro durante a criação do índice "'+cNomRes+'_UNQ".')
         Endif
      Endif
   Endif
   
   lRet := MsFile(cNomTab) .And. MsFile(cNomLog) .And. MsFile(cNomRes)
    
return lRet   

***************************************
Static Function GetScriptTb(cTableName)
***************************************
   Local cRet       := ""
   Local cProcesso  := AllTrim((cAliasRes)->ZVJ_DESTIN)
   Local aAreaZVJ   := ZVJ->(FWGetArea())
   Local aAreaZVK   := ZVK->(FWGetArea())
   Local aAreaSX3   := SX3->(FWGetArea())
   //Local nSeek      := Len(SX3->X3_CAMPO)
   Local cTam       := ""
   Local cCampo     := ""

   //SX3->(DbSetOrder(2)) //X3_CAMPO
   ZVK->(DbSetOrder(1)) //ZVK_FILIAL+ZVK_CODEXT+ZVK_SEQ
   ZVJ->(DbSetOrder(1)) //ZVJ_DESTIN
   
   If ZVJ->(!MsSeek(xFilial("ZVJ")+(cAliasRes)->ZVJ_CODIGO))
      SX3->(FWRestArea(aAreaSX3))
      ZVJ->(FWRestArea(aAreaZVJ))
      ZVK->(FWRestArea(aAreaZVK))
      return ""
   Endif
   
   If ZVK->(!MsSeek(ZVJ->ZVJ_FILIAL + ZVJ->ZVJ_CODIGO))
      return ""
   Endif
   
   cRet += "CREATE TABLE "+cTableName+"                       "+CRLF
   cRet += "(NUMEROLOTE CHAR(15 BYTE) NOT NULL ENABLE,        "+CRLF
   cRet += " LINHA NUMBER DEFAULT 0 NOT NULL ENABLE,          "+CRLF
   cRet += " DUPLIC CHAR(26 BYTE) DEFAULT ' ',                "+CRLF
   cRet += " REGISTRO_VALIDO CHAR(26 BYTE) DEFAULT ' ',       "+CRLF
   cRet += " DATAHORAMIG CHAR(26 BYTE) DEFAULT ' ',           "+CRLF
   cRet += " DATAHORATRF CHAR(26 BYTE) DEFAULT ' ',           "+CRLF
   cRet += " ARQUIVO CHAR(100 BYTE) DEFAULT ' ',              "+CRLF
   cRet += " RECNO NUMBER DEFAULT 0.0,                        "+CRLF    
   
   While ZVK->(!Eof()) .And. ZVK->ZVK_FILIAL == ZVJ->ZVJ_FILIAL .And. ZVK->ZVK_CODEXT == ZVJ->ZVJ_CODIGO
        
        cCampo := AllTrim(ZVK->ZVK_CPODES)
        If !Empty(FWSX3Util():GetFieldType(cCampo)) //SX3->(MsSeek(PadR(cCampo,nSeek)))
           cTam := cValToChar(GetSx3Cache(cCampo, 'X3_TAMANHO'))
           Do Case 
              Case (GetSx3Cache(cCampo, 'X3_TIPO') == "N")
                   cRet += cCampo + " NUMBER DEFAULT 0 NULL," + CRLF
              Otherwise
                   cRet += cCampo + " CHAR("+cTam+") DEFAULT '"+Space(Val(cTam))+"' NULL," + CRLF
           EndCase
        Endif
        
        ZVK->(DbSkip(1))
   Enddo
   
   cRet += " PRIMARY KEY (NUMEROLOTE, LINHA, RECNO)) "
   
   //SX3->(FWRestArea(aAreaSX3))
   ZVJ->(FWRestArea(aAreaZVJ))
   ZVK->(FWRestArea(aAreaZVK))
   
return cRet   

**********************************
Static Function GetCBoxSX3(cField)
**********************************
   Local aRet := {}
   Local aAux := {}
   Local cCombo
   Local aAreaSx3 := SX3->(FWGetArea())
   
   dbSelectArea("SX3")
   dbSetOrder(2)
   If dbSeek( cField )   
     cCombo  := AllTrim(X3Cbox())
     If (cCombo != "")
        aAux := StrTokArr(cCombo, ";" )
        AEval(aAux,{|x| Aadd(aRet,StrTokArr(x, "=" )) })
     Endif
   EndIf

   FWRestArea(aAreaSx3)   
Return aRet

********************************
Static Function GetTpImp(cValue)
********************************
   Local cRet := ""
   Local nIdx := AScan(aTipoImp,{|x| x[1] == cValue})
   
   If nIdx > 0
      cRet := aTipoImp[nIdx,2]
   Endif

Return cRet

****************************
Static Function VldRefresh()
****************************
   Local nRetSinc := 0
   
   U_CNCTAVLD((cAliasRes)->ZVJ_CODIGO,.T.,.T.,@nRetSinc)
   
   IF (cAliasRes)->(RecLock(cAliasRes,.F.))
      (cAliasRes)->XREFRESH := If(nRetSinc == 0," ",cValToChar(nRetSinc))
      (cAliasRes)->(MsUnLock())
   EndIf
   
   oBrwExe:Refresh()
return nil

***************************
Static Function SelectImp()
***************************
    Local cTpImp := AllTrim(ZVJ->ZVJ_TPIMP)
    Local cAlias := AllTrim(ZVJ->ZVJ_DESTIN)
    
    
    EnableTrig(RetSqlName(cAlias),.F.)
    
    Do Case
       Case ( cTpImp == "1" ) //SQL Loader
       
            U_IMPTAB(RetSqlName(AllTrim(ZVJ->ZVJ_DESTIN)),AllTrim(ZVJ->ZVJ_DIRIMP))
            
       Case ( cTpImp == "2" ) //Validação (ZVJ/ZVK)
       
            U_DORCHARGE()
            
       Case ( cTpImp == "3" ) //Stored Procedure/Banco.
       
            U_MGATMP01()
            
       Case ( cTpImp == "4" ) //MsExecAuto: rotina automática Protheus.
       
            ExecAuto(AllTrim(ZVJ->ZVJ_DESTIN))

       Case ( cTpImp == "5" ) //Stored Procedure S/Loader
            
            U_SPNLDR(AllTrim(ZVJ->ZVJ_DESTIN))            
            
       Otherwise
           
            MsgStop("Não foi possível identificar o método de importação utilizado! Verifique.")
           
    EndCase 

    EnableTrig(RetSqlName(cAlias),.T.)
       
Return      

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

   If lRet
      cSequenc := Alltrim((cAlias)->SEQUENCE_NAME)
      lStart := (TCSqlExec("select "+cSequenc+".nextval from dual")  >= 0)
   Endif
   
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

