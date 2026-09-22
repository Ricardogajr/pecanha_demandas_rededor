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

#DEFINE N_FL_PARAMS		03
#DEFINE N_FL_EXEC		04
#DEFINE N_FL_SUMMARY    05

#DEFINE C_KEYLOG        "RDI008"

#DEFINE C_CD_NEW "<< NOVO >>"

#xtranslate bSetGet(<uVar>)       =>  {|u| If(PCount() == 0, <uVar>,<uVar> := u)}
	
User Function RDI008()
	WizCfgParam()
Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} 
Função que monta as etapas doWizard de Configurações  

@author Roberto Amâncio Teixeira
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
	
	Private cWorkDir  := U_GetDir(101)
	Private cPacote   := ""
	Private aCposINI[1]
	Private aCposINI[2]
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
    Private bPreview    := {|| PreviewLog(.F.,AllTrim((cAliasRes)->QZ1_CODIGO),cDataIni,cDataIni,AllTrim((cAliasRes)->ARQLOG)) }
    Private lChkMark    := .F.
    Private lChkSalvar  := .T.
    Private lChkExec    := .T.
    Private lChkDic     := .T.
    Private oGetPesq    := nil
    Private cGetPesq    := Space(25)
    Private oChkMark    := nil
    Private oGetTit     := nil
    Private oGetNom     := nil
    

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
    
    Private bColChk     := {|| IF((cAliasRes)->CHECK,oChecked,oUnChecked) }
    Private bColFull    := {|| IF((cAliasRes)->FULL,oChecked,oUnChecked) }
    Private bColValid   := {|| If((cAliasRes)->FULL,oLegFull,IF(Empty((cAliasRes)->VALID) ,oPending,If((cAliasRes)->VALID=="1" ,oValid,oInvalid))) }
    Private bColStatus  := {|| IF(Empty((cAliasRes)->STATUS),If((cAliasRes)->FULL,oLegFull,oWaiting),If((cAliasRes)->STATUS=="1",oRunning,If((cAliasRes)->STATUS=="3",oError,oSuccess))) }
    Private bColTpImp   := {|| GetTpImp((cAliasRes)->QZ1_TPIMP) }
    Private bRefresh    := {|| If(Empty((cAliasRes)->REFRESH),oRefreshOn,If((cAliasRes)->REFRESH == "1",oRefreshOff,oRefreshWar)) }
    
    Private oBtnExc     := Nil
    Private oCmbPkg     := Nil
    Private b_vk_f3     := SetKey(VK_F3)
    	    
    Static aTipoImp     := GetCBoxSX3("QZ1_TPIMP")
	
	//fBefShow()
	
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
   
   fBefShow()   
   
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

**************************
Static Function fBefShow()
**************************
   If U_fMkWrkDir(cWorkDir)
      GetPkgList()
   Endif
   fLoadVars()
Return      

***************************
Static Function fLoadVars() 
***************************
   Local nX       := 0

   aProcess := {}
   
   If lNewPkg
      lChkMark    := .F.
      cPacote     := U_NextNum("QZ0","QZ0_PACOTE",.T.) 
      aCposINI[1] := cPacote
      aCposINI[2] := Space(TamSx3("QZ0_DESCRI")[1])		//Descrição pacote
   Else
      lChkMark    := .T.
      aProcess    := GetProcess()
   Endif  
   aCposINI[1]    := cPacote	//Nome pacote.
   
   If (ValType(oBtnExc) == "O")
      oBtnExc:lActive := ! lNewPkg
   Endif
   
   If (ValType(oGetTit) == "O")
      oGetTit:CtrlRefresh()
   Endif
   
   If (ValType(oGetNom) == "O")
      oGetNom:CtrlRefresh()
   Endif
   
Return 

****************************
Static Function GetProcess()
****************************
   Local aRet      := {}
   Local cQuery    := ""
   Local cAliasTmp := GetNextAlias()

   cQuery := "SELECT QZ0.QZ0_PACOTE, QZ0.QZ0_DESCRI, QZ0.QZ0_CODPRC, QZ0.QZ0_ORDEM, QZ0.QZ0_FULL " + CRLF
   cQuery += "FROM "+RetSqlName("QZ0")+" QZ0                                                     " + CRLF
   cQuery += "WHERE QZ0.D_E_L_E_T_=' '                                                           " + CRLF
   cQuery += "AND QZ0.QZ0_PACOTE ='"+cPacote+"'                                                  " + CRLF
   cQuery += "AND QZ0.QZ0_FILIAL ='"+xFilial("QZ0")+"'                                           " + CRLF
   cQuery += "ORDER BY QZ0.QZ0_ORDEM                                                             "
   
   TCQUERY cQuery NEW ALIAS (cAliasTmp)

   TCSetField(cAliasTmp,"QZ0_FULL","L")
   
   aCposINI[2] := ""
   
   While (cAliasTmp)->(!Eof())
   
         aCposINI[2] := (cAliasTmp)->QZ0_DESCRI
         
         Aadd(aRet,{(cAliasTmp)->QZ0_CODPRC,(cAliasTmp)->QZ0_FULL,(cAliasTmp)->QZ0_ORDEM})

         (cAliasTmp)->(DbSkip(1))
   Enddo
   
   If ( Select(cAliasTmp) > 0 )
      (cAliasTmp)->(DbCloseArea())
   Endif
  
 Return aRet 

****************************
Static Function GetPkgList()
****************************
   Local aFiles    := {}
   Local cQuery    := ""
   Local cAliasTmp := GetNextAlias()

   aFilesPkg := {}

   cQuery := "SELECT DISTINCT QZ0.QZ0_PACOTE, QZ0.QZ0_DESCRI    " + CRLF
   cQuery += "FROM "+RetSqlName("QZ0")+" QZ0                    " + CRLF
   cQuery += "WHERE QZ0.D_E_L_E_T_=' '                          " + CRLF
   cQuery += "AND QZ0.QZ0_FILIAL ='"+xFilial("QZ0")+"'          " + CRLF
   cQuery += "ORDER BY QZ0.QZ0_DESCRI                           "
   
   TCQUERY cQuery NEW ALIAS (cAliasTmp)
   
   While (cAliasTmp)->(!Eof())
         
         AADD(aFilesPkg,{(cAliasTmp)->QZ0_PACOTE,(cAliasTmp)->QZ0_DESCRI})
         
         (cAliasTmp)->(DbSkip(1))
   Enddo
   
   If ( Select(cAliasTmp) > 0 )
      (cAliasTmp)->(DbCloseArea())
   Endif
   
 Return 

********************************
Static Function ShowIni(oWizard)
********************************
   Local oPanel  := oWizard:oMPanel[oWizard:nPanel]
   Local bBtnExc := {|| DeletePkg(cPacote) } 
   Local bPsqPkg := {|| PsqPkg() }
   
   SetKey(VK_F3,bPsqPkg)   
   
   oCmbPkg := TComboBox():New(20,15,{|u|if(PCount()>0,aCposINI[3]:=u,aCposINI[3])},; 
                 {},255,20,oPanel,,{||ComboIni(aCposINI[3])},,,,.T.,,,,,,,,,'aCposINI[3]',;
                 "Selecione:",1)
   
   TBtnBmp2():New(oCmbPkg:nTop + (oCmbPkg:nTop/2.5),oCmbPkg:nRight + 2,50,30,'FWSTD_LOOKUP.PNG',,,,bPsqPkg,oPanel,"< F3 > Pesquisar pacote...",,.T. )
                 
   SetCmbPkg()                      

   oGetTit := TGet():New( 45,15,{|u|If(PCount()>0,aCposINI[2]:=u,aCposINI[2]+Space(50-Len(aCposINI[2])))},;
   				oPanel,280,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,aCposINI[2],,,,;
   				/*uParam28*/,/* uParam29*/,/*uParam30*/,"Descricao:",1)

   oGetNom := TGet():New( 70,15,{||aCposINI[1]},oPanel,096,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,aCposINI[1],,,,;
   				/*uParam28*/,/* uParam29*/,/*uParam30*/,"Pacote:",1)
   				
   oBtnExc := TBtnBmp2():New(oGetNom:nBottom + 30,015,50,30,'BMPDEL.PNG',,,,bBtnExc,oPanel,"Excluir pacote",,.T. )
   
   oBtnExc:lActive := ! lNewPkg
   				
   oGetNom:Disable()
   
Return 

********************************
Static Function ComboIni(cValue)
********************************
  
   lNewPkg := (cValue == C_CD_NEW)
   cPacote := cValue
   
   fLoadVars()
return

*************************
Static Function SavePkg()
*************************
   Local cProcess := ""
   Local lExists  := .F.
   Local cFilQZ0  := xFilial("QZ0")
   
   If !lChkSalvar
      Return .T.
   Endif

   If ! lNewPkg 
      DeletePkg(cPacote,.F.)
   Endif
   
   (cAliasRes)->(DbSetOrder(1)) //ORDEM
   (cAliasRes)->(DbGotop())
   While (cAliasRes)->(!Eof())
         cProcess := AllTrim((cAliasRes)->QZ1_DESTIN)
         
         lExists := QZ0->(MsSeek(xFilial("QZ0") + cPacote + (cAliasRes)->QZ1_CODIGO))
         
         QZ0->(RecLock("QZ0",!lExists))
         QZ0->QZ0_FILIAL := xFilial("QZ0")
         QZ0->QZ0_PACOTE := AllTrim(aCposINI[1]) //codigo
         QZ0->QZ0_DESCRI := AllTrim(aCposINI[2]) //descrição
         QZ0->QZ0_CODPRC := (cAliasRes)->QZ1_CODIGO
         QZ0->QZ0_FULL   := (cAliasRes)->FULL
         QZ0->QZ0_ORDEM  := (cAliasRes)->ORDEM 
         
         QZ0->(MsUnLock("QZ0"))

         (cAliasRes)->(DbSkip(1))
   EndDo
   
Return .T.

**************************
Static Function ExecSave()
**************************
   Local lRet  := .F.
   Local bExec := {|| lRet := SavePkg() }
   
   MsgRun( "Salvando o pacote...", "Aguarde..." , bExec )
   
return lRet      


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
	
	aStruct := { {"CHECK"     , "L", 001                    , 00},;
		         {"FULL"      , "L", 001                    , 00},;
		         {"VALID"     , "C", 001                    , 00},;
		         {"STATUS"    , "C", 001                    , 00},;
		         {"REFRESH"   , "C", 001                    , 00},;
		         {"DTINI"     , "C", 010                    , 00},;
		         {"HRINI"     , "C", 008                    , 00},;
		         {"DTFIN"     , "C", 010                    , 00},;
		         {"HRFIN"     , "C", 008                    , 00},;
		         {"TOTAL"     , "N", 015                    , 00},;
		         {"GRAVADOS"  , "N", 015                    , 00},;
		         {"TEMPO"     , "C", 008                    , 00},;
		         {"ORDEM"     , "N", 002                    , 00},;
		         {"ARQLOG"    , "C", 200                    , 00},;
		         {"QZ1_CODIGO", "C", TamSx3("QZ1_CODIGO")[1], 00},;
                 {"QZ1_DESTIN", "C", TamSx3("QZ1_DESTIN")[1], 00},;
                 {"QZ1_TPIMP" , "C", TamSx3("QZ1_TPIMP" )[1], 00},;
                 {"QZ1_DESC"  , "C", TamSx3("QZ1_DESC"  )[1], 00}}
		         
   
   If (Select(cAlias) == 0)
      //Cria a tabela temporária
      oTempTable := FWTemporaryTable():New( cAlias )
      oTemptable:SetFields( aStruct )
      oTempTable:AddIndex("01", {"ORDEM"} )
      oTempTable:AddIndex("01", {"QZ1_DESTIN"} )
      oTempTable:Create()
   Else
      (cAlias)->(__dbZap())
   Endif
   
   cQuery += "SELECT QZ1.QZ1_CODIGO, QZ1.QZ1_DESTIN, QZ1.QZ1_TPIMP, QZ1.QZ1_DESC                 " + CRLF
   cQuery += "FROM "+RetSqlName("QZ1")+" QZ1                                                     " + CRLF
   cQuery += "WHERE QZ1.D_E_L_E_T_=' '                                                           " + CRLF
   cQuery += "AND QZ1.QZ1_TPIMP <> ' '                                                           " + CRLF
   cQuery += "ORDER BY QZ1.QZ1_DESTIN				                                             "
      
   TCQUERY cQuery NEW ALIAS (cAliasTmp)
   
   While (cAliasTmp)->(!Eof())
         nProcess := AScan(aProcess,{|x| x[1] == AllTrim((cAliasTmp)->QZ1_CODIGO)})
         
         RecLock(cAlias,.T.)
         (cAlias)->CHECK   := (nProcess > 0)
         (cAlias)->FULL    := (nProcess > 0) .And. aProcess[nProcess,2]
         (cAlias)->VALID   := " "
         (cAlias)->STATUS  := " "
         (cAlias)->REFRESH := " "
         //(cAlias)->ORDEM   := If(nProcess>0,aProcess[nProcess,3],(cAlias)->(Recno()))
         (cAlias)->ORDEM   := If(nProcess>0,aProcess[nProcess,3],0)
         (cAlias)->ARQLOG  := ""
         For nX := 1 To (cAlias)->(FCount())
             If (cAlias)->(FieldName(nX)) $ "CHECK|FULL|VALID|STATUS|REFRESH|DTINI|HRINI|DTFIN|HRFIN|TOTAL|GRAVADOS|TEMPO|ORDEM|ARQLOG"
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
   IF (cAliasRes)->CHECK .AND. (cAliasRes)->(RecLock(cAliasRes,.F.))
      (cAliasRes)->FULL := !(cAliasRes)->FULL
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
               (cAliasRes)->CHECK := !(cAliasRes)->CHECK
               If !(cAliasRes)->CHECK
                  (cAliasRes)->FULL   := .F.
                  (cAliasRes)->VALID  := " "
                  (cAliasRes)->STATUS := " "
               Endif 
               (cAliasRes)->(MsUnLock())
            EndIf
            (cAliasRes)->(DbSkip())
      End
      (cAliasRes)->(DbGoTop())
   Else
      If (cAliasRes)->(!Eof()) .And. (cAliasRes)->(!Bof())
         (cAliasRes)->(RecLock(cAliasRes,.F.))
         (cAliasRes)->CHECK := !(cAliasRes)->CHECK
         If !(cAliasRes)->CHECK
            (cAliasRes)->FULL   := .F.
            (cAliasRes)->VALID  := " "
            (cAliasRes)->STATUS := " "
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
      bFilter  := {|| CHECK }
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
      bFilter := {|| AT(AllTrim(cGetPesq),AllTrim((cAliasRes)->QZ1_DESC))>0 .OR. cGetPesq $ (cAliasRes)->QZ1_DESTIN }
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
   
   aSize := aSize    := {010,020,020,CalcFieldSize("C",TamSx3("QZ1_DESC")[1],0,"@!","Descrição"),CalcFieldSize("C",TamSx3("QZ1_DESTIN")[1],0,"@!","Destino"  )}
   aSize[4] := aSize[4] - (aSize[1]+aSize[2]+aSize[3]) 
   
   bFilMark := {|| SetFilMark(lChkMark,oBrwPrc) }
   
   oBrwPrc := TcBrowse():New(0,0,0,0,,,,oPanel,,,,,,,,,,,,.F.,cAliasRes,.T.,,.F.,,,.F.)

      oBrwPrc:AddColumn(TCColumn():New(" "         ,bColChk                      ,"",,,"CENTER" ,aSize[01],.T.,.F.,,,,.F.)) 
      oBrwPrc:AddColumn(TCColumn():New("Full"      ,bColFull                     ,"",,,"CENTER" ,aSize[02],.T.,.F.,,,,.F.))
      oBrwPrc:AddColumn(TCColumn():New("OK"        ,bColValid                    ,"",,,"CENTER" ,aSize[03],.T.,.F.,,,,.F.))
      oBrwPrc:AddColumn(TCColumn():New("Descrição" ,{||(cAliasRes)->QZ1_DESC    },"",,,"LEFT"   ,aSize[04],.F.,.F.,,,,.F.))
      oBrwPrc:AddColumn(TCColumn():New("Destino"   ,{||(cAliasRes)->QZ1_DESTIN  },"",,,"LEFT"   ,aSize[05],.F.,.F.,,,,.F.))
      oBrwPrc:AddColumn(TCColumn():New("Tipo"      ,bColTpImp                    ,"",,,"LEFT"   ,CalcFieldSize("C",TamSx3("QZ1_DESTIN")[1]/2,0,"@!","Tipo"  ),.F.,.F.,,,,.F.))
              
      oBrwPrc:bLDblClick   := bLDblClick
      oBrwPrc:bHeaderClick := bHeaderClick
      
      oBrwPrc:Align := CONTROL_ALIGN_ALLCLIENT
      
      oBrwPrc:SetPopup(Eval({|m|;
         m:Add(TMenuItem():New(oPanel,             ;
         "Carga full"  ,,,,bCargaFull,"UPDWARNING17.PNG","UPDWARNING17.PNG",,,,,,,.T.)), ;
      , m },TMenu():New(0,0,0,0,.T.)))

   oPnl1Bottom:= TPanel():New(00,00,,oPanel,,.T.,,,,000,28)
   oPnl1Bottom:Align := CONTROL_ALIGN_BOTTOM       
   oChkMark := TCheckBox():New((oPnl1Bottom:nTop/2)+10,05,'Exibir somente selecionados',bSetGet(lChkMark),oPnl1Bottom,150,050,,bFilMark,;
                                /* oFont */, /* bValid */, /* nClrText */, /* nClrPane */, /* uParam14 */, /* lPixel */, /* cMsg */, /* uParam17 */, /* bWhen */ )

   oGetPesq := TGet():New((oPnl1Bottom:nTop/2)+10,(oPnl1Bottom:NCLIENTWIDTH/2)-110,bSetGet(cGetPesq),oPnl1Bottom,;
               080,009,"@!",{|| Pesquisar() },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cGetPesq,,,,/*uParam28*/,/* uParam29*/,/*uParam30*/,"Pesquisar:",2)

   SetFilMark((!lNewPkg),oBrwPrc) //Força a exibição de todos os processos (QZ1).
   
return .T.       

*********************************       
Static Function ShowExec(oWizard)
*********************************
   Local oPanel      := oWizard:oMPanel[N_FL_EXEC] 
   Local nRegTot     := (cAliasRes)->(LastRec())
   Local bOrdUp      := {|| SetOrdem(.F.,oBrwExe)}
   Local bOrdDown    := {|| SetOrdem(.T.,oBrwExe)}
   Local bExRefresh  := {|| VldRefresh()  } //{|| alert( (cAliasRes)->QZ1_DESTIN + " Código:"+ (cAliasRes)->QZ1_CODIGO ) }
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
      oBrwExe:AddColumn(TCColumn():New("Descrição" ,{||(cAliasRes)->QZ1_DESC    },"",,,"LEFT"   ,CalcFieldSize("C",TamSx3("QZ1_DESC")[1]/2  ,0,"@!","Descrição"),.F.,.F.,,,,.F.))
      oBrwExe:AddColumn(TCColumn():New("Destino"   ,{||(cAliasRes)->QZ1_DESTIN  },"",,,"LEFT"   ,CalcFieldSize("C",TamSx3("QZ1_DESTIN")[1]/2,0,"@!","Destino"  ),.F.,.F.,,,,.F.))
      oBrwExe:AddColumn(TCColumn():New("Tipo"      ,bColTpImp                    ,"",,,"LEFT"   ,CalcFieldSize("C",TamSx3("QZ1_TPIMP")[1]/2 ,0,"@!","Tipo"  )   ,.F.,.F.,,,,.F.))
              
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
      
      TCheckBox():New((oPnl2Bottom:nTop/2),05,'Salvar alterações'       ,bSetGet(lChkSalvar),oPnl2Bottom,150,030,,{||.T.                },;
                                   /* oFont */, /* bValid */, /* nClrText */, /* nClrPane */, /* uParam14 */, /* lPixel */, /* cMsg */, /* uParam17 */, /* bWhen */ )
      TCheckBox():New((oPnl2Bottom:nTop/2)+10,05,'Executar'             ,bSetGet(lChkExec)  ,oPnl2Bottom,150,030,,{||ChangeExec(oWizard)},;
                                   /* oFont */, /* bValid */, /* nClrText */, /* nClrPane */, /* uParam14 */, /* lPixel */, /* cMsg */, /* uParam17 */, /* bWhen */ )
      TCheckBox():New((oPnl2Bottom:nTop/2)+10,155,'Validar c/Dicionário',bSetGet(lChkDic)   ,oPnl2Bottom,150,030,,{||.T.                },;
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
         oBrwRes:AddColumn(TCColumn():New("Descrição"  ,{||(cAliasRes)->QZ1_DESC    },"",,,"LEFT"   ,CalcFieldSize("C",TamSx3("QZ1_DESC")[1]/2  ,0,"@!","Descrição"   ),.F.,.F.,,,,.F.))
         oBrwRes:AddColumn(TCColumn():New("Destino"    ,{||(cAliasRes)->QZ1_DESTIN  },"",,,"LEFT"   ,CalcFieldSize("C",TamSx3("QZ1_DESTIN")[1]/2,0,"@!","Destino"     ),.F.,.F.,,,,.F.))
         oBrwRes:AddColumn(TCColumn():New("Tipo"       ,bColTpImp                    ,"",,,"LEFT"   ,CalcFieldSize("C",TamSx3("QZ1_TPIMP")[1]/2 ,0,"@!","Tipo"        ),.F.,.F.,,,,.F.))

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
   Local aAreaQZ1   := QZ1->(GetArea())
   Local lSuccess   := .F.
   Local cFileLog   := ""
   Local cProcess   := ""
   Local cCodPrc    := ""
   Local lPreVldEx  := .F.
   Local bPreVldEx  := {|| lPreVldEx := PreVldExec(oWizard) }
   Local lStop      := .F.
   
   If lChkSalvar 
      ExecSave()
   Endif
   
   If !lChkExec
      return .T.
   Endif
   
   (cAliasRes)->(DbGotop())
   (cAliasRes)->(DbEval({|| If(CHECK,Aadd(aRec,Recno()),) }))
   nTot := Len(aRec)
   
   If nTot == 0
      QZ1->(RestArea(aAreaQZ1))
      return .F.
   Endif
   
   MsgRun( "Validando os processos..." , "Aguarde..." , bPreVldEx )   
   If ! lPreVldEx
      return .F.
   Endif

   cDataIni := DtoS(dDataBase)
   cHoraIni := Time()
   
   QZ1->(DbSetOrder(1)) //QZ1_FILIAL+QZ1_CODIGO
   oWizard:DisableButtons()
   
   BEGIN SEQUENCE
   
      oMtrProc:SetTotal(nTot)
      
      For nX := 1 To Len(aRec)
          
          If lStop
             Exit
          Endif
          
          (cAliasRes)->(DbGoTo(aRec[nX]))
          
          If ! QZ1->(MsSeek(xFilial("QZ1")+(cAliasRes)->QZ1_CODIGO))
             Loop
          Endif

          cCodPrc  := AllTrim((cAliasRes)->QZ1_CODIGO)
          cProcess := AllTrim((cAliasRes)->QZ1_DESTIN)
          
          oSayMsg1:SetText(StrTran('Importando "{1}"...',"{1}",AllTrim((cAliasRes)->QZ1_DESC)))
          If (cAliasRes)->(RecLock(cAliasRes,.F.))
             (cAliasRes)->STATUS := "1"
             (cAliasRes)->(MsUnLock())
          EndIf
          oMtrProc:Set(nPrc)
          
          oBrwExe:Refresh()
          ProcessMessages()
          
          If (cAliasRes)->QZ1_TPIMP == "3" .And. ! CriaTabTmp()
             (cAliasRes)->(RecLock(cAliasRes,.F.))
             (cAliasRes)->STATUS := "3" //ERROR
             (cAliasRes)->(MsUnLock())
             nPrc++
             oBrwExe:Skip(1)
             Loop
          Endif
          
          If TruncaTab() 
             If ! U_SelectImp()
                (cAliasRes)->(RecLock(cAliasRes,.F.))
                (cAliasRes)->STATUS := "3" //ERROR
                (cAliasRes)->(MsUnLock())
                nPrc++

                lStop := MsgYesNo(U_FormatStr('A importação da {1} ({2}) falhou!'+CRLF+;
                             ' Deseja interromper a execução do pacote?',{cProcess,AllTrim(FWX2Nome(cProcess))}))
                
                oBrwExe:Skip(1)
                Loop
             Endif
          Endif
          
          aResumo := GetStatPrc(cDataIni,cHoraIni) //Obtém o status do processo
          
          lSuccess := ! Empty(aResumo) .And. (aResumo[1,3] > 0 .and. aResumo[1,3] == aResumo[1,4]) 
          
          (cAliasRes)->(RecLock(cAliasRes,.F.))
          IF lSuccess
             (cAliasRes)->STATUS := "9" //SUCCESS
          Else
             (cAliasRes)->STATUS := "3" //ERROR
          EndIf
          
          MsgRun( "Gerando o log... ("+cProcess+")" , "Aguarde..." , { || cFileLog := u_GeraRela(cCodPrc,cDataIni,cHoraIni) } )
                    
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
      
      If lStop
         MsgStop("Processo interrompido!")
      Else
         MsgInfo("Processo concluído!")
      Endif
   END SEQUENCE

   oWizard:EnableButtons()
   
   QZ1->(RestArea(aAreaQZ1))
   
   __lPackage := .F.
   
Return lRet 

*********************************************
Static Function GetStatPrc(cDataRef,cHoraRef)
*********************************************
   Local aRet      := {}
   Local cCodProc  := AllTrim(QZ1->QZ1_CODIGO)
   Local cProcesso := AllTrim(QZ1->QZ1_DESTIN)
   Local cTpImp    := AllTrim(QZ1->QZ1_TPIMP)
   Local cQryAna   := ""
   Local cQrySin   := ""
   Local cAliasSin := GetNextAlias()
   Local nX        := 0
    
   Do Case
      Case ( cTpImp $ "1|2|3" ) //Validação (QZ1/QZ2)/SQL Loader
           cQrySin += "SELECT QZ3.QZ3_NUMLOT NUMLOTE, QZ3.QZ3_CODTAB TABELA, QZ3.QZ3_TOTLIN TOTLINH, QZ3.QZ3_TOTGRA TOTGRAV,                                                                                                     " + CRLF
           cQrySin += "    TO_CHAR(TO_DATE(QZ3.QZ3_DATAIN,'YYYYMMDD'),'DD/MM/YYYY') DATAINI, QZ3.QZ3_HORAIN HORAINI, TO_CHAR(TO_DATE(QZ3.QZ3_DATAFI,'YYYYMMDD'),'DD/MM/YYYY') DATAFIM, QZ3.QZ3_HORAFI HORAFIM,                  " + CRLF
           cQrySin += "    LPAD(trunc(( (TO_DATE(QZ3.QZ3_DATAFI||' '||QZ3.QZ3_HORAFI,'YYYYMMDD HH24:MI:SS')-TO_DATE(QZ3.QZ3_DATAIN||' '||QZ3.QZ3_HORAIN,'YYYYMMDD HH24:MI:SS')) * 86400 / 3600)),2,'0') ||':' ||                " + CRLF
           cQrySin += "    LPAD(trunc(mod( (TO_DATE(QZ3.QZ3_DATAFI||' '||QZ3.QZ3_HORAFI,'YYYYMMDD HH24:MI:SS') - TO_DATE(QZ3.QZ3_DATAIN||' '||QZ3.QZ3_HORAIN,'YYYYMMDD HH24:MI:SS')) * 86400 , 3600 ) / 60 ),2,'0') || ':'||    " + CRLF
           cQrySin += "    LPAD(trunc(mod ( mod ( (TO_DATE(QZ3.QZ3_DATAFI||' '||QZ3.QZ3_HORAFI,'YYYYMMDD HH24:MI:SS') - TO_DATE(QZ3.QZ3_DATAIN||' '||QZ3.QZ3_HORAIN,'YYYYMMDD HH24:MI:SS')) * 86400, 3600 ), 60 )),2,'0') Tempo," + CRLF
           cQrySin += "    QZ3.QZ3_MAXREC, QZ3.QZ3_ARQUIV, QZ3.QZ3_URI                                                                                                                                                            " + CRLF
           cQrySin += "FROM "+RetSqlName("QZ3")+" QZ3                                                                                                                                                                           " + CRLF
           cQrySin += "WHERE QZ3.D_E_L_E_T_ = ' '                                                                                                                                                                               " + CRLF
           cQrySin += "  AND QZ3.QZ3_DATAFI <> ' ' AND QZ3.QZ3_HORAIN <> ' '                                                                                                                                                    " + CRLF
           cQrySin += "  AND QZ3.QZ3_DATAIN >= '"+cDataRef+"' AND TRIM(QZ3.QZ3_HORAIN) >= '"+cHoraRef+"'                                                                                                                        " + CRLF
           cQrySin += "  AND QZ3.QZ3_XMIGLT = (SELECT MAX(XQZ3.QZ3_XMIGLT) FROM "+RetSqlName("QZ3")+" XQZ3 WHERE XQZ3.D_E_L_E_T_=' ' AND XQZ3.QZ3_CODPRC = '"+cCodProc+"'  )                                                       " + CRLF		   
           cQrySin += "ORDER BY QZ3.QZ3_UKEY                                                                                                                                                                                     "
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


**********************************************************************
User Function PreviewL(lGerar,cCodProc,cDataRef,cHoraRef,cFileRpt)
**********************************************************************
   Local cLocalFile := "" 
   Local cFileName  := ""
   Local cProcesso  := ""
   Local bGeraRpt   := {|| cFileName := u_GeraRela(cCodProc,cDataRef,cHoraRef) }
   Local lRet       := .T.
   Local lCopyOk    := .F.
   
   Default cFileRpt := ""
   
   If !lGerar .And. ! File(cFileRpt)
      MsgStop("Não foi possível localizar o arquivo de relatório! Verifique.")
      return .F.
   Endif
   
   If lGerar
      MsgRun("Gerando o log...", "Aguarde...", bGeraRpt)
   Else
      cFileName := cFileRpt
   Endif
   
   lRet := File(cFileName)
   
   If lRet
      cLocalFile := U_GetDir(302) + U_FileName(cFileName)
      
      MsgRun( "Abrindo o arquivo de log...", "Aguarde...", { || lCopyOk := CpyS2T(cFileName,U_GetDir(302)) } )
      
      lRet := lCopyOk .And. File(cLocalFile)
      If lRet 
         //ShellExecute("Open",cLocalFile,"","",3)	// 1 = Normal, 2 = Minimizado, 3 = Maximizado
         ShellExecute("open","excel.exe",'"' + cLocalFile + '"',"",3)
      Endif
   Endif
   
Return lRet

*****************************************************
User Function GeraRela(cCodProc,cDataRef,cHoraRef)
*****************************************************
   Local lRet       := .T.
   Local cTpImp     := AllTrim(QZ1->QZ1_TPIMP)
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
   Local aAreaQZ4   := QZ4->(GetArea())
   Local cProcesso := AllTrim(QZ1->QZ1_DESTIN)

   Default cCodProc  := QZ1->QZ1_CODIGO
   Default cDataRef  := "19000101"
   Default cHoraRef  := "00:00:00"
   
   If ( cTpImp $ "1|2|3" )
      aHeadSin2 := {"FILIAL", "COD.LOG", "DESCRIÇÃO", "CAMPO", "DESCR.CAMPO", "QTD.OCORRÊNCIAS"}
   Endif
   
   cFileRpt   := GetFileRpt(cProcesso)
   
   Do Case
      Case ( cTpImp $ "1|2|3" ) //Validação (QZ1/QZ2)/SQL Loader
           //Sintético (Cabeçalho)
           cQrySin1 += "SELECT QZ3.QZ3_XMIGLT, QZ3.QZ3_NUMLOT NUMLOTE, QZ3.QZ3_CODTAB TABELA, QZ3.QZ3_TOTLIN TOTLINH, QZ3.QZ3_TOTGRA TOTGRAV,                                                                                      " + CRLF
           cQrySin1 += "    TO_CHAR(TO_DATE(QZ3.QZ3_DATAIN,'YYYYMMDD'),'DD/MM/YYYY') DATAINI, QZ3.QZ3_HORAIN HORAINI, TO_CHAR(TO_DATE(QZ3.QZ3_DATAFI,'YYYYMMDD'),'DD/MM/YYYY') DATAFIM, QZ3.QZ3_HORAFI HORAFIM,                  " + CRLF
           cQrySin1 += "    LPAD(trunc(( (TO_DATE(QZ3.QZ3_DATAFI||' '||QZ3.QZ3_HORAFI,'YYYYMMDD HH24:MI:SS')-TO_DATE(QZ3.QZ3_DATAIN||' '||QZ3.QZ3_HORAIN,'YYYYMMDD HH24:MI:SS')) * 86400 / 3600)),2,'0') ||':' ||                " + CRLF
           cQrySin1 += "    LPAD(trunc(mod( (TO_DATE(QZ3.QZ3_DATAFI||' '||QZ3.QZ3_HORAFI,'YYYYMMDD HH24:MI:SS') - TO_DATE(QZ3.QZ3_DATAIN||' '||QZ3.QZ3_HORAIN,'YYYYMMDD HH24:MI:SS')) * 86400 , 3600 ) / 60 ),2,'0') || ':'||    " + CRLF
           cQrySin1 += "    LPAD(trunc(mod ( mod ( (TO_DATE(QZ3.QZ3_DATAFI||' '||QZ3.QZ3_HORAFI,'YYYYMMDD HH24:MI:SS') - TO_DATE(QZ3.QZ3_DATAIN||' '||QZ3.QZ3_HORAIN,'YYYYMMDD HH24:MI:SS')) * 86400, 3600 ), 60 )),2,'0') Tempo," + CRLF
           cQrySin1 += "    QZ3.QZ3_MAXREC, QZ3.QZ3_ARQUIV, QZ3.QZ3_URI                                                                                                                                                            " + CRLF
           cQrySin1 += "FROM "+RetSqlName("QZ3")+" QZ3                                                                                                                                                                           " + CRLF
           cQrySin1 += "WHERE QZ3.D_E_L_E_T_ = ' '                                                                                                                                                                               " + CRLF
           cQrySin1 += "  AND QZ3.QZ3_DATAFI <> ' ' AND QZ3.QZ3_HORAIN <> ' '                                                                                                                                                    " + CRLF
           cQrySin1 += "  AND QZ3.QZ3_XMIGLT = (SELECT MAX(XQZ3.QZ3_XMIGLT) FROM "+RetSqlName("QZ3")+" XQZ3 WHERE XQZ3.D_E_L_E_T_=' ' AND XQZ3.QZ3_CODPRC = '"+cCodProc+"'  )                                                       " + CRLF		   
           cQrySin1 += "ORDER BY QZ3.QZ3_UKEY                                                                                                                                                                                     "
           
           //Sintético Ocorrências
           cQrySin2 += "SELECT QZ4.QZ4_FILIAL, QZ4.QZ4_CODLOG, QZ4.QZ4_DESCLO, QZ4.QZ4_CODCPO, QZ4.QZ4_DESCPO, COUNT(1) QTD    "+CRLF
           cQrySin2 += "FROM "+RetSqlName("QZ3") +" QZ3                                                                  " + CRLF
           cQrySin2 += "INNER JOIN "+RetSqlName("QZ4") +" QZ4 ON QZ4.D_E_L_E_T_=' ' AND QZ4.QZ4_UKEYP=QZ3.QZ3_UKEY       " + CRLF
           cQrySin2 += "WHERE QZ3.D_E_L_E_T_=' '                                                                         " + CRLF
           cQrySin2 += "  AND QZ3.QZ3_DATAFI <> ' ' AND QZ3.QZ3_HORAIN <> ' '                                            " + CRLF
           cQrySin2 += "  AND QZ3.QZ3_XMIGLT = (SELECT MAX(XQZ3.QZ3_XMIGLT)                                              " + CRLF
           cQrySin2 += "                       FROM "+RetSqlName("QZ3") +" XQZ3 WHERE XQZ3.D_E_L_E_T_=' '                " + CRLF
           cQrySin2 += "                       AND XQZ3.QZ3_CODPRC = '"+cCodProc+"')                                     " + CRLF
           cQrySin2 += "GROUP BY QZ4.QZ4_FILIAL, QZ4.QZ4_CODLOG, QZ4.QZ4_DESCLO, QZ4.QZ4_CODCPO, QZ4.QZ4_DESCPO          " + CRLF
           cQrySin2 += "ORDER BY QZ4.QZ4_FILIAL, QZ4.QZ4_CODLOG                                                          "            /*
           ** Analítico (QZ3/QZ4)
           */
           cQryAna += "SELECT QZ4.QZ4_NUMLIN LINHA, QZ4.QZ4_CODLOG CODLOG,           " + CRLF
           cQryAna += "  QZ4.QZ4_DESCLO DESCRICAO, QZ4.QZ4_CODCPO CAMPO, QZ4.QZ4_DESCPO DESC_CAMPO, QZ4.QZ4_CONTEU CONTEUDO, QZ4.QZ4_VALID VALIDACAO, " + CRLF
           cQryAna += " TRIM(QZ3.QZ3_BKEY) HBKEY, TRIM(QZ4.QZ4_BKEY) BKEY "
           cQryAna += "FROM "+RetSqlName("QZ3") +" QZ3                                                                  " + CRLF
           cQryAna += "INNER JOIN "+RetSqlName("QZ4") +" QZ4 ON QZ4.D_E_L_E_T_=' ' AND QZ4.QZ4_UKEYP=QZ3.QZ3_UKEY         " + CRLF
           cQryAna += "WHERE QZ3.D_E_L_E_T_=' '                                                                         " + CRLF
           cQryAna += "  AND QZ3.QZ3_DATAFI <> ' ' AND QZ3.QZ3_HORAIN <> ' '                                            " + CRLF
           cQryAna += "  AND QZ3.QZ3_XMIGLT = (SELECT MAX(XQZ3.QZ3_XMIGLT)                                                " + CRLF
           cQryAna += "                       FROM "+RetSqlName("QZ3") +" XQZ3 WHERE XQZ3.D_E_L_E_T_=' '                " + CRLF
           cQryAna += "                       AND XQZ3.QZ3_CODPRC = '"+cCodProc+"')                                      " + CRLF
           cQryAna += "ORDER BY QZ4.QZ4_UKEY                                                                                                            " 
      Otherwise
           MsgStop("Não foi possível identificar o método de importação utilizado! Verifique.")
           return ""
   EndCase
   
   If File(cFileRpt)
      nHandle := U_OpenFile(cFileRpt)
   Else
      nHandle := U_NewFile(cFileRpt)
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
             cRow += If((cAliasSin1)->(Field(nX)) == "QZ3_URI","",CHR(160))+cValToChar((cAliasSin1)->(FieldGet(nX)))
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
          If     ( (cAliasAna)->(FieldName(nX)) == "HBKEY")
             Aadd(aHeadAna, (cAliasAna)->HBKEY )
          ElseIf ( (cAliasAna)->(FieldName(nX)) != "BKEY")
             Aadd(aHeadAna, (cAliasAna)->(FieldName(nX)) )
          Endif
      Next
   
	  FWrite(nHandle,CRLF)
      FWrite(nHandle,"A N A L Í T I C O  ("+cProcesso+");;;;;;;*** CHAVE DE NEGÓCIO ***" + CRLF)
      cRow := ""
      AEval(aHeadAna,{|h| cRow += (h + ";")})
	  FWrite(nHandle,cRow  + CRLF)
   Endif

   QZ4->(DbSetOrder(1)) //QZ4_FILIAL + QZ4_UKEY
      
   While (cAliasAna)->(!Eof())
         cRow := ""
         For nX := 1 To nFCount 
             If ( (cAliasAna)->(FieldName(nX)) != "HBKEY")
                If ( (cAliasAna)->(FieldName(nX)) == "BKEY")
                   cRow += CHR(160)+StrTran((cAliasAna)->(FieldGet(nX)),";",";"+CHR(160))
                Else
                   cRow += CHR(160)+cValToChar((cAliasAna)->(FieldGet(nX)))
                Endif
                
                If nX < nFCount
                   cRow += ";"
                Endif
                
             Endif
         Next nX
	     FWrite(nHandle,cRow + CRLF)
         
         (cAliasAna)->(DbSkip(1))
   Enddo

   If ( Select(cAliasAna) > 0 )
      (cAliasAna)->(DbCloseArea())
   Endif
   
   FClose(nHandle)
   
   RestArea(aAreaQZ4)
   
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
	Local cDirLog  := U_GetDir(102)
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
   Local nRec1 := oBrw:nAT  //(cAliasRes)->(Recno())
   Local nRec2 := 0
   Local nOrd1 := (cAliasRes)->ORDEM
   Local nOrd2 := 0

   If lDown .And. (cAliasRes)->(!Eof())
      oBrw:Skip(1) //(cAliasRes)->(DbSkip(1))
      nRec2 := oBrw:nAT  //(cAliasRes)->(Recno())
      nOrd2 := (cAliasRes)->ORDEM
   Endif
   
   If !lDown .And. (cAliasRes)->(!Bof())
      oBrw:Skip(-1) //(cAliasRes)->(DbSkip(-1))
      nRec2 := oBrw:nAT  //(cAliasRes)->(Recno())
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
   
   //teste
   //GETDREFRESH(oBrw) 
         
Return lRet

***************************
Static Function TruncaTab()
***************************
   Local lRet      := .T.
   Local cTpImp    := AllTrim((cAliasRes)->QZ1_TPIMP)
   Local lTruncar  := (cAliasRes)->FULL
   Local aCommands := {}
   Local nX        := 0
   Local cDestin   := AllTrim((cAliasRes)->QZ1_DESTIN)
   Local cTarget   := RetSqlName(cDestin)
   Local cSequence := cTarget+"_SEQ"

   /*  Recria a sequence da tabela */
   lRet := U_CreateSeq(cSequence,cDestin)
   If !lRet
      return .F. 
   Endif
   /*FIM:  Recria a sequence da tabela */
   
   If !lTruncar
      Return .T.
   Endif
   
   If cTpImp $ "1|2" //Validação (QZ1/QZ2) ou MsExecAuto
      Aadd(aCommands,"TRUNCATE TABLE "+cTarget)
   ElseIf cTpImp == "3" //Stored Procedure
      Aadd(aCommands,"TRUNCATE TABLE "+cTarget)
      Aadd(aCommands,StrTran("DELETE FROM ARQ{1} WHERE NUMEROLOTE = (SELECT MAX(NUMEROLOTE) FROM ARQ{1})","{1}",cDestin))
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
   
   SetKey(VK_F3,b_vk_f3)

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
   Local lStatus   := .F.
   Local lRefresh  := .F.
   
   (cAliasRes)->(DbGotop())
   While (cAliasRes)->(!Eof())
         If ! (cAliasRes)->CHECK
            (cAliasRes)->(DbSkip(1))
            Loop     
         Endif
         
         cProcesso := AllTrim(QZ1->QZ1_DESTIN)
         
         U_RDI002((cAliasRes)->QZ1_CODIGO,.F.,.T.,@nRetSinc)
         
         //nRetSinc := 0 
         
         cPath := If(__nLocalLdr == 1,__RootClt,U_GetDir(101)) + AllTrim((cAliasRes)->QZ1_DESTIN) + "\"
         cPath := Left(cPath,RAT("\",cPath))
         cMask := AllTrim((cAliasRes)->QZ1_DESTIN)+'*.TXT'
         
         aFiles := Directory(cPath + cMask)
         
         IF (cAliasRes)->(RecLock(cAliasRes,.F.))
            (cAliasRes)->STATUS  := If(Empty(aFiles),"3"," ")
            (cAliasRes)->REFRESH := If(nRetSinc == 0," ",cValToChar(nRetSinc))
            (cAliasRes)->(MsUnLock())
         EndIf
         
         lStatus  := ( (cAliasRes)->STATUS != "3" )
         lRefresh := Empty((cAliasRes)->REFRESH) .OR. ( ! lChkDic )
         
         If lRet 
            lRet := (lStatus .And. lRefresh) 
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
   Local cProcesso  := AllTrim((cAliasRes)->QZ1_DESTIN)
   Local cCmdTab    := ""
   Local cCmdLog    := ""
   Local cCmdRes    := ""
   Local cNomTab    := Alltrim(GetNewPar('FS_RDI001','ARQ'))+cProcesso
   Local cNomLog    := cNomTab+"_LOG"                                    
   Local cNomRes    := cNomTab+"_RESUMO"        
   Local aUnique    := U_GetUnique(cProcesso)
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
      cCmdRes += "CREATE TABLE "+cNomRes+"                          "+CRLF
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
         MSGALERT(AllTrim(TCSQLERROR()),'Não foi possível criar a tabela "'+cNomTab+'".')
         return .F.
      Endif
      
      If ! Empty(aUnique)
           cCmdInd := ArrTokStr(aUnique,",")
           cCmdInd := U_FormatStr("CREATE UNIQUE INDEX "+cNomTab+"_BUSINESS ON "+cNomTab+" (NumeroLote,{1}) ",{cCmdInd})
           If (TcSQLExec(cCmdInd) != 0)
              MSGALERT(AllTrim(TCSQLERROR()),'Erro durante a criação do índice "'+cNomTab+'_BUSINESS".')
              return .F.
           Endif
      Endif
   Endif
   
   If ! Empty(cCmdLog) 
      If (TcSQLExec(cCmdLog) != 0)
         MSGALERT(AllTrim(TCSQLERROR()),'Não foi possível criar a tabela "'+cNomLog+'".')
      Endif
   Endif

   If ! Empty(cCmdRes) 
      If (TcSQLExec(cCmdRes) != 0)
         MSGALERT(AllTrim(TCSQLERROR()),'Não foi possível criar a tabela "'+cNomRes+'".')
      Else
         cCmdRes := "CREATE UNIQUE INDEX "+cNomRes+"_UNQ ON "+cNomRes+" (NumeroLote,Nome_Arquivo) "  
         If (TcSQLExec(cCmdRes) != 0)
            MSGALERT(AllTrim(TCSQLERROR()),'Erro durante a criação do índice "'+cNomRes+'_UNQ".')
         Endif
      Endif
   Endif
   
   lRet := MsFile(cNomTab) .And. MsFile(cNomLog) .And. MsFile(cNomRes)
    
return lRet   

***************************************
Static Function GetScriptTb(cTableName)
***************************************
   Local cRet       := ""
   Local cProcesso  := AllTrim((cAliasRes)->QZ1_DESTIN)
   Local aAreaQZ1   := QZ1->(GetArea())
   Local aAreaQZ2   := QZ2->(GetArea())
   Local aAreaSX3   := SX3->(GetArea())
   Local nSeek      := 10
   Local cTam       := ""
   Local cCampo     := ""

   SX3->(DbSetOrder(2)) //X3_CAMPO
   QZ2->(DbSetOrder(1)) //QZ2_FILIAL+QZ2_CODEXT+QZ2_SEQ
   QZ1->(DbSetOrder(1)) //QZ1_DESTIN
   
   If QZ1->(!MsSeek(xFilial("QZ1")+(cAliasRes)->QZ1_CODIGO))
      SX3->(RestArea(aAreaSX3))
      QZ1->(RestArea(aAreaQZ1))
      QZ2->(RestArea(aAreaQZ2))
      return ""
   Endif
   
   If QZ2->(!MsSeek(QZ1->QZ1_FILIAL + QZ1->QZ1_CODIGO))
      return ""
   Endif
   
   cRet += "CREATE TABLE "+cTableName+"                       "+CRLF
   cRet += "(NUMEROLOTE CHAR(15 BYTE) NOT NULL ENABLE,        "+CRLF
   cRet += " LINHA NUMBER DEFAULT 0 NOT NULL ENABLE,          "+CRLF
   cRet += " DUPLIC NUMBER DEFAULT 0,                         "+CRLF
   cRet += " REGISTRO_VALIDO CHAR(26 BYTE) DEFAULT ' ',       "+CRLF
   cRet += " DATAHORAMIG CHAR(26 BYTE) DEFAULT ' ',           "+CRLF
   cRet += " DATAHORATRF CHAR(26 BYTE) DEFAULT ' ',           "+CRLF
   cRet += " ARQUIVO CHAR(100 BYTE) DEFAULT ' ',              "+CRLF
   cRet += " RECNO NUMBER DEFAULT 0.0,                        "+CRLF    
   
   While QZ2->(!Eof()) .And. QZ2->QZ2_FILIAL == QZ1->QZ1_FILIAL .And. QZ2->QZ2_CODEXT == QZ1->QZ1_CODIGO
        
        cCampo := AllTrim(QZ2->QZ2_CPODES)
        If SX3->(MsSeek(PadR(cCampo,nSeek)))
           cTam := cValToChar(GetSx3Cache( cCampo ,"X3_TAMANHO"))
           Do Case 
              Case (GetSx3Cache( cCampo ,"X3_TIPO") == "N")
                   cRet += cCampo + " NUMBER DEFAULT 0 NULL," + CRLF
              Otherwise
                   cRet += cCampo + " CHAR("+cTam+") DEFAULT '"+Space(Val(cTam))+"' NULL," + CRLF
           EndCase
        Endif
        
        QZ2->(DbSkip(1))
   Enddo
   
   cRet += " PRIMARY KEY (NUMEROLOTE, LINHA, RECNO)) "
   
   SX3->(RestArea(aAreaSX3))
   QZ1->(RestArea(aAreaQZ1))
   QZ2->(RestArea(aAreaQZ2))
   
return cRet   

**********************************
Static Function GetCBoxSX3(cField)
**********************************
   Local aRet := {}
   Local aAux := {}
   Local cCombo
   Local aAreaSx3 := SX3->(GetArea())
   
   dbSelectArea("SX3")
   dbSetOrder(2)
   If dbSeek( cField )   
     cCombo  := AllTrim(X3Cbox())
     If (cCombo != "")
        aAux := StrTokArr(cCombo, ";" )
        AEval(aAux,{|x| Aadd(aRet,StrTokArr(x, "=" )) })
     Endif
   EndIf

   RestArea(aAreaSx3)   
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
   
   U_RDI002((cAliasRes)->QZ1_CODIGO,.T.,.T.,@nRetSinc)
   
   IF (cAliasRes)->(RecLock(cAliasRes,.F.))
      (cAliasRes)->REFRESH := If(nRetSinc == 0," ",cValToChar(nRetSinc))
      (cAliasRes)->(MsUnLock())
   EndIf
   
   oBrwExe:Refresh()
return nil
      
*******************************************
Static Function DeletePkg(cCodigo,lConfirm)
*******************************************
   Local aAreaQZ0 := QZ0->(GetArea())
   Local cFilQZ0  := xFilial("QZ0")
   
   Default lConfirm := .T.
   
   If lNewPkg
      return .F.
   Endif
   
   If lConfirm .And. ! MsgYesNo(U_FormatStr('Confirma a exclusão do pacote "{1}"?',{cCodigo}))
      return .F.
   Endif
   
   QZ0->(DbSetOrder(1))
   
   If ! QZ0->(MsSeek(cFilQZ0 + cCodigo))
      MsgStop(U_FormatStr('Não foi possível localizar o pacote "{1}"!',{cCodigo}))
      return .F.
   Endif
      
   While QZ0->(!Eof()) .And. QZ0->QZ0_FILIAL == cFilQZ0 .And. QZ0->QZ0_PACOTE == cCodigo
         QZ0->(RecLock("QZ0",.F.))
         QZ0->(DbDelete())
         QZ0->(MsUnLock())
   	
         QZ0->(DbSkip())
   EndDo
   
   QZ0->(RestArea(aAreaQZ0))
   
   If lConfirm
      lNewPkg := .T.
      GetPkgList()
      SetCmbPkg()
      fLoadVars()
   Endif
   
Return .T.      

**********************************
Static Function SetCmbPkg(cCodigo)
**********************************
   Local aItens  := {C_CD_NEW + '=Novo pacote.'}
   Local nX      := 0
   Local nT      := Len(aFilesPkg)
   Local nIdx    := 0
   
   Default cCodigo := ""
   
   If ValType(oCmbPkg) != "O"
      return 
   Endif

   For nX := 1 To nT
       AADD(aItens,aFilesPkg[nX,1]+"="+aFilesPkg[nX,2])
       
       If ! Empty(cCodigo) .And. ( cCodigo == aFilesPkg[nX,1])
          nIdx := Len(aItens)
       Endif
   Next nX
   
   If lNewPkg
      aCposINI[3] := aItens[1]
   Endif
   
   oCmbPkg:SetItems( aItens )
   
   If (nIdx > 0)
      oCmbPkg:Select(nIdx)
   Endif
   
Return

************************
Static Function PsqPkg()
************************
   Local aValues := {}
   Local nLen    := Len(oCmbPkg:aItems)
   Local nX      := 0
   Local cCodigo := U_RDI010()
   
   If Empty(cCodigo)
      return nil
   Endif
   
   AEval(oCmbPkg:aItems, {|i| Aadd(aValues,StrToKArr2(i,"=")[1]) })
   
   For nX := 1 To nLen
       If ( cCodigo == aValues[nX] )
          oCmbPkg:Select(nX)
          Exit
       Endif
   Next nX 

return nil


