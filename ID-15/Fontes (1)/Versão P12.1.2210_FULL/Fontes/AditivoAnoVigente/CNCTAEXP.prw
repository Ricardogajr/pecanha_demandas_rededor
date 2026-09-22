#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "xmlxfun.ch"
#include "TCBROWSE.CH"
#Include "TopConn.ch"
#include "fileio.ch" 
#INCLUDE "TRYEXCEPTION.CH"
#Include 'tbiconn.ch'


#DEFINE F_NAME 	1	
#DEFINE F_SIZE 	2	
#DEFINE F_DATE 	3	
#DEFINE F_TIME 	4	
#DEFINE F_ATT  	5

#DEFINE N_FL_PARAMS		04
#DEFINE N_FL_CONFIG		05


#DEFINE C_OPEN_MACRO	"{"
#DEFINE C_CLOS_MACRO	"}"

#DEFINE N_CNT_FLUSH 10000

#DEFINE C_CD_NEW "<< NOVO >>"
#DEFINE C_DS_NEW C_CD_NEW + '=Novo pacote.'

User Function CNCTAEXP() 
Private oTempTab01
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
	Local bInit      := {|| .T. }
	Local bWhen      := {|| .T. }
	
	Private cWorkDir  := U_GetDirc(505)
	Private cXmlPkg   := ""
	Private oXmlPkg   := nil
	Private aFilesPkg := {}
	Private oProcess  := nil
	
	Private lNewPkg := .T.
	Private aCposINI[3]
	Private aCposSQL[1]
	Private aCposTAR[1]
	Private cTabAlias   := Space(3)
	Private aDelimiters := {";",CHR(167),CHR(165)}
	Private oCbxDelim   := nil
	Private cAliasSql   := GetNextAlias()
    Private cAliasRes   := GetNextAlias()
    Private cFileRes    := ""
	Private oPanel    
	Private aOldPar     := {}
    Private bEditPar    := {|| EditParam(oBrwRes) }
    Private bPreview    := {|| PreviewPar(oBrwRes) }
    Private oCmbPkg     := Nil

    Private cDelimiter  := Space(1)
    Private lChkSalvar  := .T.
    Private lChkExec    := .T.
    Private lChkDelet   := .F.
    Private lChkSTrim   := .T.
    
    Private aExFields := {"R_E_C_N_O_","R_E_C_D_E_L_"}
    Private aKeyUniq  := {}
    
	Private aParams   := {}
	Private cFldsExct := Space(100)  //Campos que não deverão ser "tratados" durante a exportação.
	Private oBtnExcept:= Nil
	Private aExcepts  := {}
	Private aEmpsDef  := {}
	Private aFiliais  := {}
	Private nFiliais  := 0
    
	fBefShow(cAliasRes)
	
	oWizard := APWizard():New(OemToAnsi("Assistente de Exportação"),OemToAnsi("Assistente de configuração de pacotes de exportação."),;
												OemToAnsi("Assistente de Exportação"),;
												OemToAnsi("Este assistente o auxiliará na configuração de um pacote de exportação de dados."),{||.T.},{||.T.},.F.)

	oWizard:NewPanel(OemToAnsi("Seleção do Pacote"),OemToAnsi("Informe o pacote de exportação a ser configurado."),{||.T.},{||.T.},{||.T.},.T.,{||fMontaIni(@oWizard)})

	oWizard:NewPanel(OemToAnsi("Origem dos Dados"),OemToAnsi("Forneça o comando (SQL) para a extração dos dados."),{||.T.},{||CriaResult(cAliasRes)},{||.T.},.T.,{||fMontaSQL(@oWizard)})

	oWizard:NewPanel(OemToAnsi("Parêmtros"),OemToAnsi("Defina os parâmetros a serem utilizados pela consulta."),{||.T.},{||.T.},{||.T.},.T.,{||.T.})
	
      oBrwRes:=TcBrowse():New(0,0,0,0,,,,oWizard:oMPanel[N_FL_PARAMS],,,,,,,,,,,,.F.,cAliasRes,.T.,,.F.,,,.F.)
      
         oBrwRes:AddColumn(TCColumn():New("Parâmetro"   ,{||(cAliasRes)->NMPAR   },"",,,"LEFT" ,CalcFieldSize("C",020,0,"@!","Parâmetro")     ,.F.,.F.,,,,.F.))
         oBrwRes:AddColumn(TCColumn():New("Descrição"   ,{||(cAliasRes)->DSPAR   },"",,,"LEFT" ,CalcFieldSize("C",025,0,""  ,"Descrição")     ,.F.,.F.,,,,.F.))
                 
         oBrwRes:bLDblClick := bEditPar
         oBrwRes:Align      := CONTROL_ALIGN_ALLCLIENT
         
        oBrwRes:SetPopup(Eval({|m|;
        	m:Add(TMenuItem():New(oWizard:oMPanel[N_FL_PARAMS],             ;
        	"Editar"      ,,,,bEditPar,"ALT_CAD"  ,"ALT_CAD"  ,,,,,,,.T.)), ;
        	m:Add(TMenuItem():New(oWizard:oMPanel[N_FL_PARAMS],             ;
        	"Preview"     ,,,,bPreview,"BMPVISUAL","BMPVISUAL",,,,,,,.T.)), ;
        , m },TMenu():New(0,0,0,0,.T.)))

	oWizard:NewPanel(OemToAnsi("Configurações"),OemToAnsi("Configurações para a finalização do assistente."),{||.T.},{||.T.},;
	                    {||Exec(aFiliais)},.T.,{||.T.})    

      oObj := TGet():New(020                     ,15,{|u|If(PCount()>0,cTabAlias:=u,cTabAlias)},;
              oWizard:oMPanel[N_FL_CONFIG],060,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTabAlias,,,,/*uParam28*/,/* uParam29*/,/*uParam30*/,"Alias:",1)
                                   
      oCbxDelim := TComboBox():New(oObj:nTop+03,15,{|u|if(PCount()>0,cDelimiter:=u,cDelimiter)},; 
                 aDelimiters,120,16,oWizard:oMPanel[N_FL_CONFIG],,{||.T.},,,,.T.,,,,,,,,,'cDelimiter',"Separador:",1)     

      TCheckBox():New((oObj:nTop+30) ,15,'Retirar espaços de campos caracter',bSetGet(lChkSTrim),oWizard:oMPanel[N_FL_CONFIG],150,030,,{||ChangeTrim()},; 
                                   /* oFont */, /* bValid */, /* nClrText */, /* nClrPane */, /* uParam14 */, /* lPixel */, /* cMsg */, /* uParam17 */, /* bWhen */ )
      
      oBtnExcept := TButton():New((oObj:nTop+30),200,"Excessões",oWizard:oMPanel[N_FL_CONFIG],{|| SetExcept() },085,012,,,,.T.)
                                   
      TCheckBox():New((oObj:nTop+60) ,15,'Salvar alterações'          ,bSetGet(lChkSalvar),oWizard:oMPanel[N_FL_CONFIG],150,030,,{||.T.},;
                                   /* oFont */, /* bValid */, /* nClrText */, /* nClrPane */, /* uParam14 */, /* lPixel */, /* cMsg */, /* uParam17 */, /* bWhen */ )
      TCheckBox():New((oObj:nTop+72) ,15,'Executar'                   ,bSetGet(lChkExec)  ,oWizard:oMPanel[N_FL_CONFIG],150,030,,{||ChangeExec(oWizard)},;
                                   /* oFont */, /* bValid */, /* nClrText */, /* nClrPane */, /* uParam14 */, /* lPixel */, /* cMsg */, /* uParam17 */, /* bWhen */ )
      TCheckBox():New((oObj:nTop+84) ,15,'Excluir arquivos anteriores',bSetGet(lChkDelet) ,oWizard:oMPanel[N_FL_CONFIG],150,030,,{||ChangeExec(oWizard)},;
                                   /* oFont */, /* bValid */, /* nClrText */, /* nClrPane */, /* uParam14 */, /* lPixel */, /* cMsg */, /* uParam17 */, /* bWhen */ )


	oWizard:Activate(.T.,bValid,bInit,bWhen)	
	
Return Nil

**************************
Static Function Finalize()
**************************
   If (Select(cAliasRes) > 0)
      (cAliasRes)->(dbclosearea())
      /*If File(cFileRes + GetDBExtension())
         FErase(cFileRes + GetDBExtension())
      Endif
      If File(cFileRes + OrdBagExt())
         FErase(cFileRes + OrdBagExt())
      Endif*/
	  oTempTab01:Delete()
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
Static Function fBefShow(cAliasRes) //Before Show
**************************
   CriaResult(cAliasRes)
   
   If U_fMkWrkDir(cWorkDir)
      GetPkgList()
   Endif
   
   LoadVars()
Return      

**************************
Static Function LoadVars() 
**************************
   Local xValue 
   Local cTipo     := ""
   Local nX
   
   LoadDefs() 
   
   oXmlPkg := fGetXML("")
   lNewPkg := (VALTYPE(oXmlPkg) != "O")
   
   If lNewPkg
      cXmlPkg     := CriaTrab(,.F.) + ".xml"
      aCposINI[2] := Space(50)		//Descrição pacote.
      aCposSQL[1] := Space(250)		//Select
      aCposTAR[1] := Space(50)
      aOldPar     := {}
      cTabAlias   := Space(3)
      cDelimiter  := ";"
      cFldsExct   := Space(100)
      aExcepts    := {}
   Else
  	  cXmlPkg     := oXmlPkg:_Package:_Name:Text
      aCposINI[2] := oXmlPkg:_Package:_Description:Text	//Descrição pacote.
      aCposSQL[1] := oXmlPkg:_Package:_Select:Text	//Select
      cTabAlias   := oXmlPkg:_Package:_Alias:Text
      cDelimiter  := oXmlPkg:_Package:_Delimiter:Text
      lChkSTrim   := (Upper(AllTrim(oXmlPkg:_Package:_Trim:Text)) == "TRUE")

      If (type("oXmlPkg:_Package:_FldExcept") == "O")
         cFldsExct   := PadR(oXmlPkg:_Package:_FldExcept:Text,100)
         aExcepts    := StrTokArr(oXmlPkg:_Package:_FldExcept:Text,",")
      Endif
      
     
      If (type("oXmlPkg:_Package:_Empresas") == "O")
         aFiliais  := &( "{" + oXmlPkg:_Package:_Empresas:Text + "}" )
      Endif
      
      
      nFiliais := Len(aFiliais)
      
      If (Type("oXmlPkg:_Package:_Params") == "O")
         aNodes1 :=  ClassDataArr(oXmlPkg:_Package:_Params)
         For nX := 1 To Len(aNodes1)
             If (ValType(aNodes1[nX,2]) != "O")
                Loop
             Endif
             
             cTipo  := AllTrim(aNodes1[nX,2]:_TIPO:Text)
             xValue := aNodes1[nX,2]:_VALUE:Text

             Aadd(aOldPar,{":"+aNodes1[nX,2]:RealName,aNodes1[nX,2]:_CAMPO:Text,aNodes1[nX,2]:_DSPAR:Text,cTipo,;
             	  aNodes1[nX,2]:_PICTURE:Text,aNodes1[nX,2]:_F3:Text,VAL(aNodes1[nX,2]:_TAMANHO:Text),VAL(aNodes1[nX,2]:_DECIMAL1:Text),xValue})
         Next nX
      Endif
      
   Endif  
   aCposINI[1] := cXmlPkg	//Nome pacote.
   
   SelDelim(cDelimiter)
   
   lChkDelet := .F.

Return

**************************
Static Function LoadDefs() 
**************************
   Local cDir      := U_GetDirc(404)
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
	Local cDir   := U_GetDirc(505) //WorkDir
	Local aFiles := DIRECTORY(cDir + "*.xml")  
	Local nX     := 0, nT := Len(aFiles)    
	Local cFile  := ""
	Local oXml   := nil
	Local cError := cWarning := ""

 	aFilesPkg := {}
 
 	For nX := 1 To nT
		oXml := fGetXML(cWorkDir + aFiles[nX,F_NAME])
      
      If (ValType(oXml) == "O")
		   AADD(aFilesPkg,{aFiles[nX,F_NAME],AllTrim(oXml:_Package:_Description:Text),aFiles[nX,F_DATE],aFiles[nX,F_TIME]})
		   
	      FreeObj(oXml)
		Endif
	Next nX                     
Return 

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
   
   For nX := 1 To nT
       AADD(aItens,aFilesPkg[nX,1]+"="+aFilesPkg[nX,2])
   Next nX
   
   If lNewPkg
      aCposINI[3] := aItens[1] //C_DS_NEW
   Endif
   
   oCmbPkg := TComboBox():New(20,15,{|u|if(PCount()>0,aCposINI[3]:=u,aCposINI[3])},; 
                   aItens,280,20,oPanel,,{||fComboIni(aCposINI[3],oGetNom,oGetTit)},,,,.T.,,,,,,,,,'aCposINI[3]',"Selecione:",1)
                   
   SetCmbPkg()                      

   oGetTit := TGet():New( 45,15,{|u|If(PCount()>0,aCposINI[2]:=u,aCposINI[2]+Space(50-Len(aCposINI[2])))},;
                         oPanel,280,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,aCposINI[2],,,,/*uParam28*/,;
                         /* uParam29*/,/*uParam30*/,"Descricao:",1)

   oGetNom := TGet():New( 70,15,{||aCposINI[1]},oPanel,096,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,aCposINI[1],,,,;
                         /*uParam28*/,/* uParam29*/,/*uParam30*/,"Pacote:",1)  
	
   oGetNom:Disable()
   
   TBtnBmp2():New(oGetNom:nBottom + 30,015,50,30,'BMPDEL.PNG',,,,bBtnExc,oPanel,"Excluir pacote",,.T. )
   
Return 

**********************************
Static Function fMontaSQL(oWizard)
**********************************
   Local oPanel := oWizard:oMPanel[oWizard:nPanel]
   Local oGetSql := nil   

   oGetSql := TMultiget():New(012,015,{|u|if(Pcount()>0,aCposSQL[1]:=u,aCposSQL[1])},oPanel,270,100,,,,,,.T.,,,,,,,;
                {||.T.},,,,.T.,"Consulta SQL:",1)
   
   TButton():New(005                   ,200,"Facilitador SQL",oPanel,{|| fFacilSql() },085,012,,,,.T.)
   TButton():New((oGetSql:nBottom/2)+10,200,"Empresas"       ,oPanel,{|| fEmpresas() },085,012,,,,.T.)
   
Return .T.     

***************************
Static Function fFacilSql()    
***************************
	Local aAreaSX2:= SX2->(FWGetArea())
	Local cQuery  := "SELECT "+CRLF+"{3} "+CRLF+"FROM {2} {1}"  
	Local cWhere  := ""
	Local cChave  := ""
	Local cArquivo:= ""
	Local aFields := {}               
	Local cFields := ""
	Local cAliasSx2 := GetNextAlias()
	Local cQryX2 := ""
   Local nX
   Local oGet
   Local cRetCon 
   // := "X2_CHAVE"
	//ConPad1( , , ,'ZZUSUV', cRetCon/*cCampoRet*/, /*lGet*/,.F./*lOnlyView*/,/*cVar*/,/*oGet*/, /*uContent*/)
	If !ConPad1(,,,"HSPSX2",,, .F.,cRetCon , oGet )
       FWRestArea(aAreaSX2)
	   Return .F.
	Endif    

	 cQryX2 := " SELECT X2_CHAVE AS CHAVEX2, X2_ARQUIVO AS ARQUIVOX2"
    cQryX2 += " FROM "+RetSQLName("SX2") + " SX2  "
    cQryX2 += " WHERE D_E_L_E_T_= ' ' "
    cQryX2 += " AND X2_CHAVE   = '"+SX2->X2_CHAVE+"'"
    cQryX2 += " AND X2_ARQUIVO = '"+SX2->X2_ARQUIVO+"'"

    cQryX2 := ChangeQuery(cQryX2)
    dbUseArea(.T., 'TOPCONN', TcGenQry(,,cQryX2), cAliasSx2)
	
	
	cChave   := AllTrim((cAliasSx2)->CHAVEX2)
	cArquivo := AllTrim((cAliasSx2)->ARQUIVOX2)

   If Select(cChave) == 0
      dbSelectArea( cChave )
   Endif

	aFields := &(cChave+"->(DbStruct())")
	For nX := 1 To Len(aFields)
        If (AScan(aExFields,{|e| e == aFields[nX,1] }) > 0) .OR. ( "_XMIGLT" $ aFields[nX,1] )
           Loop
        Endif
        If ! Empty(AllTrim(xFilial(cChave))) .And. (("_FILIAL" $ aFields[nX,1]) .OR. ("_FILORI" $ aFields[nX,1]))
	       //cFields += CHR(9) + "'"+cEmpAnt+"'||"+cChave + "."+ aFields[nX,1] + " " + aFields[nX,1]+ "," + CRLF
	       cFields += CHR(9) + "{cEmpAnt}||"+cChave + "."+ aFields[nX,1] + " " + aFields[nX,1]+ "," + CRLF
        Else 
	       cFields += If(X3User(aFields[nX,1]),"---","") + CHR(9) + cChave + "."+ aFields[nX,1] + "," + CRLF
	    Endif
	Next nX
	cFields := Left(cFields,RAT(",",cFields)-1)
	
	cQuery := StrTran(StrTran(StrTran(cQuery,"{1}",cChave),"{2}",cArquivo),"{3}",cFields)
	cWhere := StrTran("WHERE {1}.D_E_L_E_T_=' '","{1}",cChave)
	
	aCposSQL[1] := cQuery + CRLF + cWhere
	
   FWRestArea(aAreaSX2)
Return .T.

******************************
Static Function X3User(cField)
******************************
   Local lRet := ( GetSx3Cache(cField,"X3_PROPRI") == "U" )
Return lRet   
         
************************************************
Static Function fComboIni(cValue,oGetNom,oGetTit)
************************************************
   lNewPkg := (cValue == C_CD_NEW)
   cXmlPkg := cValue
   LoadVars()
return

***********************
Static Function fSave(aFiliais)
***********************
   Local cArqXML  := cWorkDir + cXmlPkg
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
   AADD(aRet,StrTran("	<Name>%Name%</Name>","%Name%",aCposINI[1]) )
   AADD(aRet,StrTran("	<Description>%Description%</Description>","%Description%",AllTrim(aCposINI[2]))) 
   AADD(aRet,StrTran("	<Select><![CDATA[%Select%]]></Select>","%Select%",AllTrim(aCposSQL[1])))
   AADD(aRet,StrTran("	<Alias>%Alias%</Alias>","%Alias%",cTabAlias))
   AADD(aRet,StrTran("	<Delimiter>%Delimiter%</Delimiter>","%Delimiter%",cDelimiter))
   AADD(aRet,StrTran("	<Trim>%Trim%</Trim>","%Trim%",If(lChkSTrim,"True","False")))
   AADD(aRet,StrTran("	<FldExcept>%FldExcept%</FldExcept>","%FldExcept%",cFldsExct))
   AADD(aRet,StrTran("	<Empresas>%Empresas%</Empresas>","%Empresas%",ArrTokStr(aFiliais,",")))
   
   AADD(aRet,"	<Params>")
   (cAliasRes)->(DbGotop())
   While (cAliasRes)->(!Eof())
         cValue := ""
         /*
         If ! Empty(aParams)
            nIdx := AScan(aParams,{|p| Alltrim(p[1]) == AllTrim((cAliasRes)->NMPAR) })
            If (nIdx > 0)
               cValue := aParams[nIdx,9]
            Endif
         Endif
         */
         Aadd(aRet,StrTran("	<{1}>","{1}",AllTrim(StrTran((cAliasRes)->NMPAR,":",""))))
         Aadd(aRet,StrTran("		<CAMPO>{1}</CAMPO>"    ,"{1}",AllTrim((cAliasRes)->CAMPO)))
         Aadd(aRet,StrTran("		<TAMANHO>{1}</TAMANHO>","{1}",CValToChar((cAliasRes)->TAMANHO)))
         Aadd(aRet,StrTran("		<DECIMAL>{1}</DECIMAL>","{1}",CValToChar((cAliasRes)->DECIMAL1)))
         Aadd(aRet,StrTran("		<DSPAR>{1}</DSPAR>"    ,"{1}",AllTrim((cAliasRes)->DSPAR)))
         Aadd(aRet,StrTran("		<TIPO>{1}</TIPO>"      ,"{1}",AllTrim((cAliasRes)->TIPO)))
         Aadd(aRet,StrTran("		<PICTURE>{1}</PICTURE>","{1}",AllTrim((cAliasRes)->PICTURE)))
         Aadd(aRet,StrTran("		<F3>{1}</F3>"          ,"{1}",AllTrim((cAliasRes)->F3)))
         Aadd(aRet,StrTran("		<VALUE>{1}</VALUE>"    ,"{1}",cValue))
         Aadd(aRet,StrTran("	</{1}>","{1}",AllTrim(StrTran((cAliasRes)->NMPAR,":",""))))
         (cAliasRes)->(DbSkip(1))
   EndDo
   AADD(aRet,"	</Params>")
   AADD(aRet,"</Package>")
                 
   For nX := 1 To Len(aRet)
      FWrite(nHdl,aRet[nX] + CRLF)
   Next     
   FClose(nHdl)
   
   If ! Empty(aFiliais)
      SaveDef(aFiliais)
   Endif

Return .T.

*************************
Static Function SaveDef(aFiliais)
*************************
   Local cArqXML  := U_GetDirc(404) + "DEFAULT.xml"
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
  	Local lRet := .T.
  
  	lRet := Finalize()
  
    If lRet 
	   If (Select(cAliasSql) > 0)
	      (cAliasSql)->(dbCloseArea())
	   Endif
	Endif
                              
return lRet

**********************************
Static function CriaResult(cAlias)
**********************************
   Local lRet      := .F.
	Local aStruct   := {}
	Local nX        := 0
	Local nIdx      := 0
	
	If Empty(cAlias)
	   return .F.
	Endif

	aStruct := {{"NMPAR"    , "C", 020 , 00},;
               {"CAMPO"    , "C", 010 , 00},;
               {"TAMANHO"  , "N", 010 , 00},;
               {"DECIMAL1"  , "N", 003 , 00},;
		         {"DSPAR"    , "C", 025 , 00},;
		         {"TIPO"     , "C", 001 , 00},;
		         {"PICTURE"  , "C", 020 , 00},;
		         {"F3"       , "C", 006 , 00}}
   
   If (Select(cAlias) == 0)
      //Cria a tabela temporária
      oTempTab01:=FWTemporaryTable():New(cAlias) //cFileRes := CriaTrab(aStruct,.T.)
      oTemptab01:SetFields( aStruct ) //dbUseArea(.T.,RDDSetDefault(),cFileRes,cAlias,.F.,.F.)
	   oTempTab01:Create()
   Else
      //(cAlias)->(DBCloseArea())
	   (cAlias)->(__dbZap())
      //(cAlias)->(DBCloseArea())
   Endif

   aParams   := GetParams(aCposSQL[1])
   
   If Empty(aParams)
      Return .T.
   Endif
   
   For nX := 1 To Len(aParams)
       //Restaura os valores dos parâmetros.
       nIdx := AScan(aOldPar,{|p| AllTrim(p[1]) == AllTrim(aParams[nX,1])})
       If nIdx > 0 
          aParams[nX,3] := aOldPar[nIdx,3] // Descrição do parâmetro
          aParams[nX,9] := aOldPar[nIdx,9] // Valor
       Endif
       //FIM: Restaura os valores dos parâmetros.
        
   	 RecLock(cAlias, .T. )
         (cAlias)->NMPAR     := aParams[nX,1]
         (cAlias)->CAMPO     := aParams[nX,2]
         (cAlias)->DSPAR     := aParams[nX,3]
         (cAlias)->TIPO      := aParams[nX,4]
         (cAlias)->PICTURE   := aParams[nX,5]
         (cAlias)->F3        := aParams[nX,6]
         (cAlias)->TAMANHO   := aParams[nX,7]
         (cAlias)->DECIMAL1   := aParams[nX,8]
       (cAlias)->(MsUnLock())
   Next nX

   (cAlias)->(DbGotop())
   
   lRet := (cAlias)->(!Eof())

   If lRet .And. Type("oBrwRes") == "O"
      oBrwRes:ResetLen()
      oBrwRes:GetBrowse():Refresh()
      oBrwRes:Refresh()
      oBrwRes:GoTop()
      oBrwRes:DrawSelect()
   Endif
   
Return lRet 

********************************
Static Function EditParam(oGrid)
********************************
   Local aParam   := {}
   Local aRet     := {}
   Local cDesPar  := PadL((cAliasRes)->DSPAR,Len((cAliasRes)->DSPAR))
   
   If (cAliasRes)->(Eof()) 
      return .F.
   Endif
   
   aParam := {{1,(cAliasRes)->DSPAR,cDesPar,"",".T.","",".T.",100,.T.}}
   	
   //If !ParamBox(aParam ,"Nova descrição do Parâmetro",aRet)
   If Empty(AllTrim( cDesPar := FWInputBox("Nova descrição do parâmetro", cDesPar) ))
      oGrid:Refresh()
      return .F.
   Endif
   
   (cAliasRes)->(RecLock(cAliasRes,.F.))
   (cAliasRes)->DSPAR := cDesPar 
   (cAliasRes)->(MsUnLock())
   
   oGrid:Refresh()
   
return .T.   

*********************************
Static Function PreviewPar(oGrid)
*********************************
   Local aParamBox := {}
   Local aRet      := {}
   Local nFt       := 2.5
   Local xDefault  
  
   (cAliasRes)->(DbGoTop())
   While (cAliasRes)->(!Eof())
         Do Case
            Case ((cAliasRes)->TIPO == "D")
                 xDefault := Ctod("")
            Case ((cAliasRes)->TIPO == "N")
                 xDefault := Val("0" + If((cAliasRes)->DECIMAL1 > 0,"." + Replicate("0",(cAliasRes)->DECIMAL1),""))
            Otherwise
                 xDefault := Space((cAliasRes)->TAMANHO) 
         EndCase
         Aadd(aParamBox,{1,(cAliasRes)->DSPAR,xDefault,(cAliasRes)->PICTURE,".T.",(cAliasRes)->F3,".T.",(cAliasRes)->TAMANHO*nFt,.F.})
         
         (cAliasRes)->(DbSkip(1))
   EndDo
      
   If !ParamBox(aParamBox ,"Parâmetros",aRet)
      (cAliasRes)->(DbGoTop())
      oGrid:Refresh()
      return .F.
   Endif
   
   (cAliasRes)->(DbGoTop())
   oGrid:Refresh()
Return .T.
   
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
Static Function ChangeTrim()
****************************
   oBtnExcept:SetEnable(lChkSTrim)
   oBtnExcept:Refresh()
return .T.

**********************************    
Static Function SetParams(cQuery)
**********************************
   Local lRet   := .T.
   Local aValues:= {}
   Local nX     := 0
   Local cValue := ""
   Local aParValues := {}

   cQuery   := AllTrim(aCposSQL[1])
   
   If !Empty(aParams)
      For nX := 1 To Len(aParams)
          Aadd(aParValues,{1,aParams[nX,3],If(aParams[nX,9] == "",CriaVar(aParams[nX,2]),aParams[nX,9]),aParams[nX,5],".T.",aParams[nX,6],".T.",aParams[nX,7]*6,.F.})
      Next
      
      If !ParamBox(aParValues,"Parâmetros",aValues)
         return .F.   
      Endif
      
      For nX := 1 To Len(aParams) 
          cValue := aValues[nX]
          aParams[nX,9] := cValToChar(cValue)
          Do Case
             Case (aParams[nX,4] == "C")
             	  cValue := "'"+cValue+"'"
             Case (aParams[nX,4] == "D")
             	  cValue := "'"+DToS(cValue)+"'"
             OtherWise
                  cValue := cValToChar(cValue)
          EndCase
          cQuery := StrTran(cQuery,aParams[nX,1],cValue)
      Next
   Endif
   
return .T.
   
*****************************************
Static Function Exportar(oProcess,lAbort)
*****************************************
   Local lRet      := .T.
   Local cQuery    := AllTrim(aCposSQL[1])
   Local cAlias    := GetNextAlias()
   Local cPath     := U_GetDirc(606) + cTabAlias+"\"
   //Local cPath     := U_GetDirc(400) 
   Local nTotRec   := 0
   Local nRecno    := 0
   Local nFCount   := 0
   Local xValue    
   Local aData     := {}
   Local aRow      := {}
   Local cRow      := ""
   Local aEmps     := {} //{ Cod.Emp, Cod.Filial, Tabela, cQuery }
   Local aTabs     := {}
   Local cFileName := ""
   Local lExcept   := .F.
   Local nEmpsQt   := 0
   Local Nx,nE
   
   If !U_fMkWrkDir(cPath)
      MsgStop("Não foi possível criar o diretório para exportação!"+CRLF+cPath)
      Return .F.
   Endif
   
   If lChkDelet
      DelTarget(cPath)
   Endif
   
   If ! SetParams(@cQuery)
      MsgStop("Execução cancelada!")
      return .F.
   Endif
   
   aEmps   := Compilar(cQuery)
   nEmpsQt := Len(aEmps)
   
   aKeyUniq := GetUnique(cTabAlias)

   oProcess:SetRegua1(nEmpsQt)
   
   For nE := 1 To Len(aEmps)

       oProcess:IncRegua1(U_FmtStr('Processando empresa "{1}", filial "{2}"...',{aEmps[nE,1],aEmps[nE,2]}))
       
       cFileName := aEmps[nE,3] + "_" + DToS(Date()) + "_" + StrTran(Time(),":","") + ".TXT" 
       cFileName := cPath + cTabAlias+cFileName
       
       cQuery := aEmps[nE,4]
       
       If (Select(cAlias) > 0) 
          (cAlias)->(DbCloseArea())
       Endif
       
       TRYEXCEPTION       
           
           TCQUERY cQuery NEW ALIAS (cAlias)
           
       CATCHEXCEPTION USING oException
           IF ( ValType( oException ) == "O" )
              Alert(oException:DESCRIPTION)
              oException := nil
              lExcept    := .T.
           EndIF	                     
       ENDEXCEPTION	
       
       If lExcept
          lExcept := .F.
          Loop
       Endif
       
       If (cAlias)->(Eof())
          Loop
       Endif
       
       nFCount := (cAlias)->(FCount()) 
       
       If nE == 1
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
      EndIf 

       nRecno  := 0
       nTotRec := Contar(cAlias,"!Eof()")
       (cAlias)->(DbGoTop())
       
       oProcess:SetRegua2(nTotRec)
       
       While !lAbort .And. (cAlias)->(!Eof())
           nRecno++
           oProcess:IncRegua2("Exportando o registro "+cValToChar(nRecno)+" de "+cValToChar(nTotRec)+"...")
           
           aRow := {} //Array(nFCount)
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
                       If lChkSTrim .And. ( Ascan(aKeyUniq,{|f| f == AllTrim((cAlias)->(FieldName(nX)))}) == 0 ) .And.;
                          .Not. ( AllTrim((cAlias)->(FieldName(nX))) $ cFldsExct)
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
           
           If (Mod(Len(aData),N_CNT_FLUSH) == 0)
              FileFlush(cFileName,aData)
              aData := {}
           Endif         
           
           (cAlias)->(DbSkip())         
       EndDo
       
       FileFlush(cFileName,aData)
       
       If (Select(cAlias) > 0) 
          (cAlias)->(DbCloseArea())
       Endif
       
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

**********************
Static Function Exec(aFiliais)
**********************
   Local lRet      := .T.
   Local lAbort    := .F.
   Local bExec     := {|| lRet := Exportar(oProcess,@lAbort) }
   
   //Salva o pacote antes da execução...
   fSave(aFiliais) 
   //FIM: Salva o pacote antes da execução...
   
   If lChkExec   
      oProcess:= MsNewProcess():New( bExec ,"["+cTabAlias+"] Exportando arquivo...",,,.T.)
      oProcess:Activate()
      FreeObj(oProcess)
   Endif
   
   //Salva o pacote depois da execução...
   fSave(aFiliais) 
   //FIM: Salva o pacote depois da execução...
   
Return lRet    

********************************
Static Function SelDelim(cDelim)
********************************
   Local nIdx := Ascan(aDelimiters,{|x| x == cDelim})
   If nIdx == 0
      nIdx := 1
   Endif
   
   If ValType(oCbxDelim) == "O"
      oCbxDelim:Select(nIdx)
      oCbxDelim:Refresh()
   Endif
Return

************************************
Static Function GetUnique(cAliasTab)
************************************
   Local aRet      := {}
   Local cAlias    := GetNextAlias()
   Local cTable    := RetSqlName(cAliasTab)
   Local cQuery    := ""
   
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
         Aadd(aRet,AllTrim((cAlias)->column_name))
         (cAlias)->(DbSkip(1))
   EndDo
   
   If (Select(cAlias) > 0) 
      (cAlias)->(DbCloseArea())
   Endif
   
Return aRet

***************************
Static Function SetExcept()    
***************************
   Local _stru   := {}
   Local aCpoBro := {}
   Local aFields := {}               
   Local aCores  := {}
   Local lConfirm:= .T.
   
   Local cAlias    := GetNextAlias()
   Local cArqTmpBk := GetNextAlias()
   Local oMark     := Nil   
   Local cMark     := GetMark()
   Local cSql      := StrTran(StrTran(AllTrim(UPPER(aCposSQL[1])),CHR(10),CHR(32)),CHR(9),"")   
   Local nX
   
   Private lInverte := .F.     
   
   //Cria um arquivo de Apoio
   AADD(_stru,{"OK"   ,"C",002,000})
   AADD(_stru,{"FIELD","C",012,000})
   AADD(_stru,{"DESCRI" ,"C",040,000})
                           
   If (Select(cAlias) > 0)
     (cAlias)->(DbCloseArea())
   Endif
   
   oTempTab02 := FWTemporaryTable():New(cAlias) //cArqTmpBk := Criatrab(_stru,.T.)
   oTemptab02:SetFields( _stru ) //DBUSEAREA(.t.,,cArqTmpBk,cAlias)
   oTempTab02:Create()
   cSql := Substr(cSql,1,AT("WHERE",cSql)-1)
   cSql := cSql + " WHERE ROWNUM = 0"

   cSql := Compilar(cSql)[1,4]
   
   MsgRun( "Analisando o ResultSet..." , "Aguarde..." , { || U_fQryStruct(cSql,aFields)} )
   
   If Empty(aFields)
      return .F.
   Endif
   
   For nX := 1 To Len(aFields)
       DbSelectArea(cAlias)	
       RecLock(cAlias,.T.)
       (cAlias)->FIELD  :=  aFields[nX,1]
       (cAlias)->DESCRI   :=  GetX3Desc(aFields[nX,1])
       (cAlias)->OK  	:=  Iif((AScan(aExcepts,{|x| x == AllTrim(aFields[nX,1])})>0),cMark,"")
       MsunLock()	
   Next
   
   aCpoBro := {{ "OK"      ,, " "         ,"@!"},;
   			   { "FIELD"   ,, "Campo"     ,"@!"},;			
   			   { "DESCRI"    ,, "Descrição" ,"@!"}}			
   
   DbSelectArea(cAlias)
   DbGotop()
   
   //Cria a MsSelect                   
   oWindow    := TDialog():New(180,180,450,680,'Selecione os campos que não serão tratados',,,,,CLR_BLACK,CLR_WHITE,,,.T.)
   
   oPnl1Bottom := TPanel():New(00,00,,oWindow,,.T.,,,,000,28)
   oPnl1Bottom :Align := CONTROL_ALIGN_BOTTOM       
   
   oMark:= FwMarkBrowse():New() //MsSelect():New(cAlias,"OK","",aCpoBro,@lInverte,@cMark,{17,1,150,295},,,oWindow,,aCores)
   oMark:SetTemporary(.T.)
   oMark:SetAlias(cAlias)
   oMark:SetColumns(aCpoBro)
   oMark:SetFieldMark("OK")
   oMark:SetOwner( oWindow )
   oMark:bMark := {| | FldMark(@oMark,cAlias,cMark)}
   oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   oMark:Activate()

   TButton():New((oPnl1Bottom:nTop/2)+10,(oPnl1Bottom:NCLIENTWIDTH/2)-220,"Cancelar" ,oPnl1Bottom,{|| lConfirm := .F. , oWindow:End() },085,012,,,,.T.)
   TButton():New((oPnl1Bottom:nTop/2)+10,(oPnl1Bottom:NCLIENTWIDTH/2)-110,"Confirmar",oPnl1Bottom,{|| lConfirm := .T. , oWindow:End() },085,012,,,,.T.)
   

   oWindow:Activate(,,,.T.,{||.T. },,{||.T. } )
   
   If lConfirm
      aExcepts := {}
      (cAlias)->(DbGoTop())
      (cAlias)->(DBEval({|| If((cAlias)->OK == cMark, Aadd(aExcepts, AllTrim((cAlias)->FIELD)),) }))
      
      cFldsExct := ArrTokStr(aExcepts,",")
   Endif
   
   If (Select(cAlias) > 0)
      (cAlias)->(dbclosearea())
      /*If File(cFileRes + GetDBExtension())
         FErase(cFileRes + GetDBExtension())
      Endif
      If File(cFileRes + OrdBagExt())
         FErase(cFileRes + OrdBagExt())
      Endif*/
	  oTempTab02:Delete()
   Endif
	
Return .T.

//Funcao executada ao Marcar/Desmarcar um registro.   
*******************************************
Static Function FldMark(oMark,cAlias,cMark)
*******************************************
   Local cField := AllTrim((cAlias)->FIELD)
   Local nPos := AScan(aExcepts,{|x| x == cField})
   Local lMark := .F.

	//RecLock(cAlias,.F.)
	If Marked(cMark)	
		//(cAlias)->OK := cMark
      lMark :=  .T. 
		If (nPos == 0)
		   AADD(aExcepts,cField)
		Endif
	Else	
		(cAlias)->OK := ""
		If (nPos > 0)
		   ADel(aExcepts,nPos)
		   ASize(aExcepts,Len(aExcepts)-1)
		Endif
	Endif             
	//MSUNLOCK()
	oMark:oBrowse:Refresh()
Return lMark

*********************************
Static Function GetX3Desc(cField)
*********************************

   Local cRet := ""
   Local aArea := FWGetArea()
 
   dbSelectArea("SX3")
   dbSetOrder(2)
   If dbSeek( cField )
      cRet := X3Descric() //X3Titulo()
   EndIf
   
   RestArea(aArea)
Return cRet
  
***************************
Static Function fEmpresas()
***************************
   Local _stru:={}
   Local aCpoBro := {}
   Local aFields := {}
   Local aCores  := {}
   Local lConfirm:= .F.
   Local aAreaSM0:= SM0->(FWGetArea())
   
   Local cAlias    := GetNextAlias()
   Local cArqTmp   := GetNextAlias()
   Local oMark     := Nil   
   Local cMark     := GetMark()
   Local lChkTodos := .F.
   Local oFontQtd  := TFont():New('Tahoma',,-018,,.T.)
   Local bRestore  := {|| EmpAll(.F.,oMark,cAlias,cMark), SetEmpsDef(cAlias,cMark,oMark) }
   
   Local nYPos     := 0
   Local nXPos     := 0
   Local nContFlds := 0
   Local aColumns := {}
   
   Private lInverte  := .F.
   Private oSayQtd   := Nil     
   Private lChkSoChk := .F. 

   //Cria um arquivo de Apoio
   AADD(_stru,{"OK"     ,"C",002,000})
   AADD(_stru,{"CD_EMP" ,"C",002,000})
   AADD(_stru,{"CD_FIL" ,"C",012,000})
   AADD(_stru,{"DS_FIL" ,"C",041,000})
   AADD(_stru,{"DS_EMP" ,"C",040,000})
   AADD(_stru,{"DS_COM" ,"C",060,000})
                           
   If (Select(cAlias) > 0)
      (cAlias)->(DbCloseArea())
   Endif
   
   oTempTab03 := FWTemporaryTable():New(cAlias) //cArqTmp := Criatrab(_stru,.T.)
   oTemptab03:SetFields( _stru ) //DBUSEAREA(.t.,,cArqTmp,cAlias)
   oTempTab03:Create()
   SM0->(DbGoTop())
   While SM0->(!Eof()) 
       RecLock(cAlias,.T.)
       (cAlias)->OK  	:=  SPACE(2) //Iif((AScan(aFiliais,{|x| x[1] == AllTrim(SM0->M0_CODIGO) .and. x[2] == AllTrim(SM0->M0_CODFIL) })>0),cMark,"")
       (cAlias)->CD_EMP := SM0->M0_CODIGO
       (cAlias)->CD_FIL := SM0->M0_CODFIL
       (cAlias)->DS_FIL := SM0->M0_FILIAL
       (cAlias)->DS_EMP := SM0->M0_NOME
       (cAlias)->DS_COM := SM0->M0_NOMECOM
       (cAlias)->(MsUnlock())
       
       SM0->(DbSkip(1))
   EndDo
   RestArea(aAreaSM0)
   //aAdd(aCpos,{"Bem", "T9_CODBEM", "C", TAMSX3('T9_CODBEM')[1], 0 })
   aCpoBro := {{ "OK"      , " "              ,2,0 ,"@!","C"},;
               { "CD_EMP"  , "Cod.Emp."       ,2,0 ,"@!","C"},;
               { "CD_FIL"  , "Cod.Fil."       ,12,0,"@!","C"},;
               { "DS_FIL"  , "Filial"         ,41,0,"@!","C"},;
               { "DS_EMP"  , "Empresa"        ,40,0,"@!","C"},;
               { "DS_COM"  , "Nome Comercial" ,60,0,"@!","C"}}
   
   //AADD( aFields, { "E1_EMISSAO", "Emissão"  , GetSx3Cache( "E1_EMISSAO", "X3_TAMANHO" ), GetSx3Cache( "E1_EMISSAO", "X3_DECIMAL" ), GetSx3Cache( "E1_EMISSAO", "X3_PICTURE" ), GetSx3Cache( "E1_EMISSAO", "X3_TIPO" ) } )
   //AADD( aFields, { "E1_IDCNAB" , "IDCNAB"   , GetSx3Cache( "E1_IDCNAB" , "X3_TAMANHO" ), GetSx3Cache( "E1_IDCNAB" , "X3_DECIMAL" ), GetSx3Cache( "E1_IDCNAB" , "X3_PICTURE" ), GetSx3Cache( "E1_IDCNAB" , "X3_TIPO" ) } )

   For nContFlds := 1 To Len( aCpoBro )
	   AADD( aColumns, FWBrwColumn():New() )

	   aColumns[Len( aColumns )]:SetData( &( "{ || " + aCpoBro[nContFlds][1] + " }" ) )
      aColumns[Len( aColumns )]:SetTitle( aCpoBro[nContFlds][2] )
      aColumns[Len( aColumns )]:SetSize( aCpoBro[nContFlds][3] )
      aColumns[Len( aColumns )]:SetDecimal( aCpoBro[nContFlds][4] )
      aColumns[Len( aColumns )]:SetPicture( aCpoBro[nContFlds][5] )
      aColumns[Len( aColumns )]:SetType( aCpoBro[nContFlds][6]) 
      aColumns[Len( aColumns )]:SetID( aCpoBro[nContFlds]  )
   Next nContFlds

   DbSelectArea(cAlias)
   DbGotop()
   
   //Cria a MsSelect                   
   oWindow    := TDialog():New(180,180,550,720,'Selecione as Empresas/Filiais',,,,,CLR_BLACK,CLR_WHITE,,,.T.)
   
   oPnl1Bottom := TPanel():New(00,00,,oWindow,,.T.,,,,000,40)
   oPnl1Bottom :Align := CONTROL_ALIGN_BOTTOM       
   
   oMark:=FwMarkBrowse():New() //MsSelect():New(cAlias,"OK","",aCpoBro,@lInverte,@cMark,{17,1,150,295},,,oWindow,,aCores)
   oMark:SetTemporary(.T.)
   oMark:SetAlias(cAlias)
   oMark:SetColumns(aColumns)
   oMark:SetFieldMark("OK")
   oMark:SETOWNER(oWindow)
   oMark:SETWALKTHRU( .F. )
   oMark:SETAMBIENTE( .F. )
   //oMark:AddButton( "Confirmar", { || ( lRetorn := .T., oMark:Disable() )} )
   //oMark:AddButton( "Cancelar" , { || ( lNoOk := .T., oMark:Disable() ) } )
   //cMarca := oMark:Mark()
   oMark:DisableReport()
   oMark:DisableDetails()
   oMark:bMark         := {|| EmpMark(@oMark,cAlias,cMark) }
   //oMark:oBrowse:bHeaderClick  := {|| Alert("bHeaderClick") }
   //oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   
   TCheckBox():New(003,005,"Marcar/Desmarcar Todos" ,bSetGet(lChkTodos),oPnl1Bottom,080,030,,{||EmpAll(lChkTodos,oMark,cAlias,cMark)},;
                                   /* oFont */, /* bValid */, /* nClrText */, /* nClrPane */, /* uParam14 */, /* lPixel */, /* cMsg */, /* uParam17 */, /* bWhen */ )
   TCheckBox():New(011,005,"Exibir somente marcados",bSetGet(lChkSoChk),oPnl1Bottom,080,030,,{||SetSoCheck(oMark)                   },;
                                   /* oFont */, /* bValid */, /* nClrText */, /* nClrPane */, /* uParam14 */, /* lPixel */, /* cMsg */, /* uParam17 */, /* bWhen */ )

   nXPos  := (oPnl1Bottom:NCLIENTWIDTH/2)
   nYPos  := (40 - 12) / 2  

   oSayQtd := TSay():New(001,nXPos-070,{||SetQtdEmp(oSayQtd)}, oPnl1Bottom,,oFontQtd,,,,.T.,,,065,010,,,,,,.F.  ,1,2)
   
   TBtnBmp2():New(nYPos + 24,005,025,025,'NG_ICO_RETOSM.PNG',,,,bRestore,oPnl1Bottom,"Restaurar empresas da última execução",,.T. )

   TButton():New(nYPos,nXPos-140,"Cancelar" ,oPnl1Bottom,{|| lConfirm := .F. , oWindow:End() },065,012,,,,.T.)
   TButton():New(nYPos,nXPos-070,"Confirmar",oPnl1Bottom,{|| lConfirm := .T. , oWindow:End() },065,012,,,,.T.)
   
   oMark:Activate()
   
   //TButton():New(nYPos,nXPos-140,"Cancelar" ,oWindow,{|| lConfirm := .F. , oWindow:End() },065,012,,,,.T.)
   //TButton():New(nYPos,nXPos-070,"Confirmar",oWindow,{|| lConfirm := .T. , oWindow:End() },065,012,,,,.T.)
   
   oWindow:Activate(,,,.T.,{||.T. },,{||.T. } )
   
   If lConfirm
      //aFiliais := {}
      (cAlias)->(DbGoTop())
      (cAlias)->(DBEval({|| If((cAlias)->OK == cMark, Aadd(aFiliais, {AllTrim((cAlias)->CD_EMP),AllTrim((cAlias)->CD_FIL)}),) }))
   Endif
   
   nFiliais := Len(aFiliais)
   
   If (Select(cAlias) > 0)
      (cAlias)->(dbclosearea())
      /*If File(cFileRes + GetDBExtension())
         FErase(cFileRes + GetDBExtension())
      Endif
      If File(cFileRes + OrdBagExt())
         FErase(cFileRes + OrdBagExt())
      Endif*/
	  oTempTab03:Delete()
   Endif
   
Return .T.

****************************************
Static Function SetEmpsDef(cAlias,cMark,oMark)
****************************************
   Local aArea := (cAlias)->(FWGetArea())
   Local cMarca := oMark:Mark()
   //Local cField := cCodFil
   //Local nPos := AScan(aFiliais,{|x| x[1] + x[2] == cCodEmp+cCodFil})

   oMark:IsMark( cMark ) 
   
   If Empty(aEmpsDef)
      MsgInfo("Não há dados para a restauração! Verifique.")
      return .F.
   Endif

   (cAlias)->(DbGoTop())
   While (cAlias)->(!Eof()) 

       RecLock(cAlias,.F.)
       (cAlias)->OK  	:=  Iif((AScan(aEmpsDef,{|x| x[1] == AllTrim((cAlias)->CD_EMP) .and. x[2] == AllTrim((cAlias)->CD_FIL) })>0),cMark,"")
       (cAlias)->(MsUnlock())
       
       (cAlias)->(DbSkip(1))
   EndDo
   
   nFiliais := Len(aEmpsDef)
   
   (cAlias)->(RestArea(aArea))
return .T.


//Funcao executada ao Marcar/Desmarcar um registro.
*******************************************
Static Function EmpMark(oMark,cAlias,cMark)
*******************************************
   Local cCodEmp := AllTrim((cAlias)->CD_EMP)
   Local cCodFil := AllTrim((cAlias)->CD_FIL)
   Local cMarca := oMark:Mark()
   Local cField := cCodFil
   Local nPos := AScan(aFiliais,{|x| x[1] + x[2] == cCodEmp+cCodFil})

   oMark:IsMark( cMark ) 

   RecLock(cAlias,.F.)
   If (cAlias)->OK == cMarca
      If (nPos == 0)
		   AADD(aFiliais,{cCodEmp,cCodFil})
		Endif
  //    (cAlias)->OK := cMark
      nFiliais++
   Else
      (cAlias)->OK := ""
      If (nPos > 0)
		   ADel(aFiliais,nPos)
		   ASize(aFiliais,Len(aFiliais)-1)
		Endif
      nFiliais--
   Endif             
   (cAlias)->(MSUNLOCK())
   
   oMark:oBrowse:Refresh()
   
   SetQtdEmp(oSayQtd)
Return nil

//Funcao executada ao Marcar/Desmarcar um registro.
***********************************************
Static Function EmpAll(lAll,oMark,cAlias,cMark)
***********************************************
   Local aArea := (cAlias)->(FWGetArea())
   Local nCnt  := 0
   
   (cAlias)->(DbGotop())
   While (cAlias)->(!Eof())
         RecLock(cAlias,.F.)
         (cAlias)->OK := If(lAll,cMark,"  ")
         (cAlias)->(MSUNLOCK())
         
         If lAll
            nCnt++
         Endif
         
         (cAlias)->(DbSkip(1))
   EndDo
   RestArea(aArea)
   
   oMark:oBrowse:Refresh()
   
   nFiliais := nCnt
   
   SetQtdEmp(oSayQtd)
Return()  

*********************************
Static Function MacExec( cMacro )
*********************************
   Local bBlock:=ErrorBlock()
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

********************************
Static Function Compilar(cQuery)
********************************
   Local aRet       := aClone(aFiliais)
   //Local cQry       := StrTran(StrTran(StrTran(cQuery,CHR(9),""),CHR(32),""),CRLF,"")
   Local cQry       := StrTran(StrTran(cQuery,CHR(10),CHR(32)),CHR(9),"")
   Local aMacros    := {} // 1=Macro,2=Comando,3=Resultado (Ex. { "{Table("SA1")}","Table("SA1")","SA1010" } )
   Local nX         := 0
   Local nF         := 0
   Local cBkpEmp    := cEmpAnt
   Local cBkpFil    := cFilAnt
   Local cMacro     := ""
   Local nPosIni    := AT(C_OPEN_MACRO,cQry)
   Local nPosFin    := AT(C_CLOS_MACRO,cQry)
   Local cTable     := ""

   If (nPosIni == 0)
      aRet := {{cEmpAnt,cFilAnt,RetSqlName(cTabAlias),cQuery}}
      return aRet
   Endif

   If Empty(aRet)
      aRet := {{cEmpAnt,cFilAnt}}
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
      aRet := {{cEmpAnt,cFilAnt,RetSqlName(cTabAlias),cQuery}}
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
   /*OpenSxs(,,,,cEmpAnt,cAliasSx2,"SX2",,.F.)
   If Select(cAliasSx2) == 0
      MsgStop('Não foi possível abrir a SX2 da empresa "'+cEmpAnt+'".')
      return cRet 
   EndIf*/
   cQuery := " SELECT X2_CHAVE AS CHAVEX2, X2_ARQUIVO AS ARQUIVOX2"
   cQuery += " FROM "+RetSQLName("SX2") + " SX2  "
   cQuery += " WHERE D_E_L_E_T_= ' ' "
   
   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T., 'TOPCONN', TcGenQry(,,cQuery), cAliasSx2)
   
   If (cAliasSx2)->(Eof())
	  MsgStop('Não foi possível abrir a SX2 da empresa "'+cEmpAnt+'".')
      return cRet 
   EndIf
   //(cAliasSx2)->(dbSetOrder(1))
   
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

***************************
Static Function DeletePkg()
***************************
   Local cFileName := cWorkDir + cXmlPkg
   Local lExists   := File(cFileName) 
   
   If lNewPkg
      return .F.
   Endif
   
   lRet := lExists .And. MsgYesNo('Confirma a exclusão do pacote?')
   
   If lRet
      FErase(cFileName)

      lNewPkg := .T.
      GetPkgList()
      SetCmbPkg()
      LoadVars()
   Endif
   
Return lRet      

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

********************************
Static Function DelTarget(cPath)
********************************
   Local cMask  := cPath + "*.txt"
   Local aFiles := Directory(cMask)
   
   AEval(aFiles,{|f| FErase(cPath + f[F_NAME]) })
   
Return 
   
*******************************
Static Function SetQtdEmp(oSay)
*******************************
   Local cRet := StrZero(nFiliais,3)
   
   If ( VALTYPE(oSay) == "O" )
      oSay:SetText(cRet)
      //oSay:CtrlRefresh()
   Endif
   
Return cRet      

*********************************
Static Function SetSoCheck(oMark)
*********************************
   Local lFilter := lChkSoChk
   Local cAlias  := oMark:oBrowse:cAlias
   Local bFilter := {|| ! Empty((cAlias)->OK) }
   
   If ! lFilter
      bFilter := {|| .T. }
      cFilChk := ""
   Endif
   
   (cAlias)->(DbSetFilter(bFilter,""))
   (cAlias)->(DbGoTop())
   
   oMark:oBrowse:GoUp()
   oMark:oBrowse:Refresh()
   
Return nil   

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
   //Local nSize    := Len(SX3->X3_CAMPO)
   Local aAreaSx3 := SX3->(FWGetArea())
  
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
   
   //SX3->(DbSetOrder(2)) //X3_CAMPO
   
   For nX := 1 To Len(aParams)
       cParam := aParams[nX]
       cField := Substr(aParams[nX],2)
       If ( AT("__",cField) > 0 )
          cField := Substr(cField,1,AT("__",cField)-1)
       Endif
       //cField := PadR(cField,nSize)
       If !Empty(FWSX3Util():GetFieldType(cField)) //SX3->(dbSeek(cField))
          Aadd(aRet,{cParam,cField,X3DescriC(),GetSx3Cache(cField, 'X3_TIPO'),GetSx3Cache(cField, 'X3_PICTURE'),GetSx3Cache(cField, 'X3_F3'),GetSx3Cache(cField, 'X3_TAMANHO'),GetSx3Cache(cField, 'X3_DECIMAL'),""})
       Else
          MsgStop(StrTran('Parâmetro "{1}" é inválido! Verifique.',"{1}",cParam))
       Endif
   Next nX
   
   AEval(aRet,{|a| a[3] := AllTrim(a[3]), a[5] := AllTrim(a[5]), a[6] := AllTrim(a[6])})  
   aSort( aRet,,, { |x,y| x[1] < y[1] } )
   
   SX3->(RestArea(aAreaSx3))
   
return aRet   
