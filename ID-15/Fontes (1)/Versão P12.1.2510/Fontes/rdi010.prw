#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TopConn.ch"
#include "TCBROWSE.CH"

// Alinhamento do método addInLayout
#define LAYOUT_ALIGN_LEFT     1
#define LAYOUT_ALIGN_RIGHT    2
#define LAYOUT_ALIGN_HCENTER  4
#define LAYOUT_ALIGN_TOP      32
#define LAYOUT_ALIGN_BOTTOM   64
#define LAYOUT_ALIGN_VCENTER  128

// Alinhamento para preenchimento dos componentes no TLinearLayout
#define LAYOUT_LINEAR_L2R 0 // LEFT TO RIGHT
#define LAYOUT_LINEAR_R2L 1 // RIGHT TO LEFT
#define LAYOUT_LINEAR_T2B 2 // TOP TO BOTTOM
#define LAYOUT_LINEAR_B2T 3 // BOTTOM TO TOP

User function RDI010()
   
   Local cRet := ""
   Local aAreaQZ1   := QZ1->(GetArea())
   
   cRet := Exec()

   QZ1->(RestArea(aAreaQZ1))
   
return cRet   

**********************
Static function Exec()
**********************
   Local oPnlTop     := nil
   Local oPnlBtm     := nil
   Local oBtnPsq     := nil
   Local oBtnConf    := nil
   Local oBtnCanc    := nil
   Local oFnt12AriB  := TFont():New( "Arial" ,,-12,,.T.,,,,,.F. )
   Local oFnt21AriB  := TFont():New( "Tahoma",,-21,,.T.,,,,,.F. )
   Local bPsqExec    := {|| LoadData() }
   Local bSaveKey    := SetKey(VK_F5)  
   Local bSelect     := {|| cActPkg := aMstData[oBrwMaster:nAT,2],oDlgPsq:End() } 
   Local bCancel     := {|| cActPkg := "", oDlgPsq:End() }
   Local aMHeader    := {}
   Local aMSize      := {} 
   Local aDHeader    := {}
   Local aDSize      := {}
   
   Private cPesq      := SPACE(030)
   Private oDlgPsq
   Private oGetPsq    := nil
   Private oBrwMaster := nil
   Private oBrwDetail := nil
   Private aAllData   := {}
   Private aMstData   := {}
   Private aDtlData   := {}
   Private cActPkg    := ""
   Private cFilPkg    := ""
   
   SetKey(VK_F5,bPsqExec)
   
   LoadData()
   
   oDlgPsq := TDialog():New(050,050,0480,0700,"Pesquisa Pacotes de Importação",,,,,,,,,.T.)

   oPnlTop := TPanel():New(00,00,,oDlgPsq,,.T.,,,,000,020)
   oPnlTop:Align := CONTROL_ALIGN_TOP

   oBtnPsq := TBtnBmp2():New(000,000,050,050,'BRW_FILTRO.PNG',,,,bPsqExec,oPnlTop,"Pesquisar...",,.T. )
   oBtnPsq:Align := CONTROL_ALIGN_RIGHT

   oGetPsq := TGet():New(005,005,bSetGet(cPesq),oPnlTop,280,018,"@!",bPsqExec,0,,oFnt21AriB,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cPesq,,,,;
   				/*uParam28*/,/* uParam29*/,/*uParam30*/,/*"Pesquisar:"*/,/* 1 */,oFnt12AriB)
   oGetPsq:Align := CONTROL_ALIGN_ALLCLIENT 
   
   //oGetPsq:BLOSTFOCUS := bPsqExec
   
   oPnlBtm := TPanel():New(00,00,,oDlgPsq,,.T.,,,,000,28)
   oPnlBtm:Align := CONTROL_ALIGN_BOTTOM
   
   oBtnConf := TBtnBmp2():New(000,000,050,050,'NGBIOALERTA_02.PNG',,,,bSelect,oPnlBtm,"Selecionar",,.T. )
   oBtnConf:Align := CONTROL_ALIGN_RIGHT

   oBtnCanc := TBtnBmp2():New(000,000,050,050,'NGBIOALERTA_03.PNG',,,,bCancel,oPnlBtm,"Cancelar"  ,,.T. )
   oBtnCanc:Align := CONTROL_ALIGN_RIGHT
   
   
   oSplitter := TSplitter():New( 000, 000, oDlgPsq,000,000, 1 )
   oSplitter:Align  := CONTROL_ALIGN_ALLCLIENT
      
   aMHeader := {"Descrição","Pacote"}
   aMSize   := { CalcFieldSize("C",TamSx3("QZ0_DESCRI")[1],0,"@!","Descrição"),;
                 CalcFieldSize("C",TamSx3("QZ0_PACOTE")[1],0,"@!","Pacote") }
                 
   aDHeader := {"Ordem","Processo","Destino","Tipo Carga","Descrição"}
   aDSize   := { CalcFieldSize("C",TamSx3("QZ0_ORDEM")[1]   ,0,"@!","Ordem")   ,;
                 CalcFieldSize("C",TamSx3("QZ1_CODIGO")[1]  ,0,"@!","Processo")   ,;
                 CalcFieldSize("C",TamSx3("QZ1_DESTIN")[1]/2,0,"@!","Destino")    ,;
                 CalcFieldSize("C",TamSx3("QZ1_TPIMP")[1]   ,0,"@!","Tipo Carga") ,;
                 CalcFieldSize("C",TamSx3("QZ1_DESC")[1]    ,0,"@!","Descrição")  }

   //Browse Master
   oBrwMaster   := TCBrowse():New(0,0,680,250,,aMHeader,aMSize,oSplitter,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
      oBrwMaster:lHScroll    := .F.
      oBrwMaster:aHeaders    := aMHeader
      oBrwMaster:aColSizes   := aMSize
      oBrwMaster:SetArray(aMstData)
      oBrwMaster:bLine       := {|| FilterD(aMstData[oBrwMaster:nAT,2]), {aMstData[oBrwMaster:nAT,1],aMstData[oBrwMaster:nAT,2]} }
      oBrwMaster:bLDblClick  := bSelect
      //oBrwMaster:bGotFocus   := {|| FilterD(aMstData[oBrwMaster:nAT,2])}
   //FIM: Browse Master.
   
   //Browse Detail
   oBrwDetail := TcBrowse():New(0,0,680,250,,aDHeader,aDSize,oSplitter,,,,,,,,,,,,.F.,,.T.,,.F.,,,.F.)
      //oBrwDetail:Align     := CONTROL_ALIGN_ALLCLIENT
      oBrwDetail:lHScroll  := .F.
      oBrwDetail:aHeaders  := aDHeader
      oBrwDetail:aColSizes := aDSize
      oBrwDetail:SetArray(aDtlData)
      oBrwDetail:bLine     := {|| { aDtlData[oBrwDetail:nAT,1],aDtlData[oBrwDetail:nAT,2],;
                                    aDtlData[oBrwDetail:nAT,3],aDtlData[oBrwDetail:nAT,4], aDtlData[oBrwDetail:nAT,5] } }
      oBrwDetail:bLDblClick  := bSelect
   //FIM: Browse Detail
   
   oSplitter:MoveToFirst(oBrwMaster)
   oSplitter:moveToLast(oBrwDetail)
   
   oDlgPsq:Activate(,,,.T.)
   
   SetKey(VK_F5,bSaveKey)
   
return cActPkg

**************************
Static Function LoadData()
**************************
   Local cAlsTemp      := GetNextAlias()
   Local cQuery        := ""
   Local cPsq          := "%"+AllTrim(cPesq)+"%"
   Local nX := nFCount := 0
   Local aRow          := {}
   
   cQuery += "SELECT QZ0.QZ0_PACOTE, QZ0.QZ0_DESCRI, QZ1.QZ1_CODIGO, QZ1.QZ1_DESTIN, QZ1.QZ1_DESC,           " + CRLF
   cQuery += "ROW_NUMBER() OVER (PARTITION BY QZ0.QZ0_PACOTE ORDER BY QZ0.QZ0_PACOTE, QZ0.QZ0_ORDEM) ORDEM,  " + CRLF
   cQuery += "DECODE(QZ1.QZ1_TPIMP,'1','Sql Loader','2','Validação','3','Stored Procedure') QZ1_TPIMP        " + CRLF
   cQuery += "FROM "+RetSqlName("QZ0")+" QZ0                                                                 " + CRLF
   cQuery += "INNER JOIN "+RetSqlName("QZ1")+" QZ1 ON QZ1.QZ1_CODIGO=QZ0.QZ0_CODPRC AND QZ1.D_E_L_E_T_=' '   " + CRLF
   cQuery += "WHERE QZ0.D_E_L_E_T_=' '                                                                       " + CRLF
   
   If ! Empty(cPsq)
      cQuery += "AND QZ0.QZ0_PACOTE IN(SELECT XQZ0.QZ0_PACOTE FROM "+RetSqlName("QZ0")+" XQZ0                       " + CRLF
      cQuery += "INNER JOIN "+RetSqlName("QZ1")+" XQZ1 ON XQZ1.QZ1_CODIGO=XQZ0.QZ0_CODPRC AND XQZ1.D_E_L_E_T_=' '   " + CRLF
      cQuery += "WHERE XQZ0.D_E_L_E_T_=' ' AND ( XQZ0.QZ0_DESCRI LIKE '"+cPsq+"' OR XQZ1.QZ1_DESC LIKE '"+cPsq+"'   " + CRLF
	  cQuery += "OR XQZ1.QZ1_DESTIN LIKE '"+cPsq+"') ) "     
   Endif
   
   cQuery += "ORDER BY QZ0.QZ0_PACOTE, QZ0.QZ0_ORDEM                                                            "
   
   cAlsTemp := MPSysOpenQuery( cQuery  )

   If (cAlsTemp)->(Eof())
      MsgStop("Nenhuma correspondência foi encontrada!")
      oGetPsq:SetFocus()
      If ( Select(cAlsTemp) > 0 )
         (cAlsTemp)->(DbCloseArea())
      Endif
	  
      return .F.
   Endif
   
   nFCount := (cAlsTemp)->( FCount() )
   
   aAllData := {}
   
   While (cAlsTemp)->(!Eof())
   
         aRow := Array(nFCount)
         
         For nX := 1 To nFCount
             aRow[nX] := (cAlsTemp)->(FieldGet(nX)) 
         Next nX
         
         Aadd(aAllData,aRow)         

         (cAlsTemp)->(DbSkip(1))
   EndDo
   
   If ( Select(cAlsTemp) > 0 )
      (cAlsTemp)->(DbCloseArea())
   Endif
   
   LoadMaster()
   
Return .T.  

****************************
Static Function LoadMaster()
****************************
   Local nX   := 0 
   Local nLen := Len(aAllData)
   Local bLine:= {||}
   
   aMstData := {}
   
   If Empty(aAllData)
      Return nil
   Endif
   
   For nX := 1 To nLen
       If (AScan(aMstData,{|m| m[2] == aAllData[nX,1]}) == 0)
          Aadd(aMstData,{aAllData[nX,2],aAllData[nX,1]})
       Endif
   Next nX

   If ( Type("oBrwMaster") == "O" ) 
      bLine := oBrwMaster:bLine
      oBrwMaster:SetArray(aMstData)
      oBrwMaster:bLine := bLine
      //oBrwMaster:ResetLen()
      //oBrwMaster:Refresh()
      oBrwMaster:DrawSelect()
      oBrwMaster:GoTop()
      oBrwMaster:SetFocus()

      Eval(oBrwMaster:bLine)
   Endif
   
return nil   
   
********************************
Static Function FilterD(cCodigo)
********************************
   Local nX       := 0 
   Local nLen     := Len(aAllData)
   Local bLine    := {||}
   
   If Empty(aAllData) .OR. Empty(cCodigo)
      return nil
   Endif
   
   If (cFilPkg == cCodigo)
      return nil
   Endif
   
   cFilPkg  := cCodigo
   
   aDtlData := {}
   
   For nX := 1 To nLen
       If (AllTrim(aAllData[nX,1]) == AllTrim(cCodigo))
          Aadd(aDtlData,{aAllData[nX,6],aAllData[nX,3],aAllData[nX,4],aAllData[nX,7],aAllData[nX,5]})
       Endif
   Next nX
   
   If ( Type("oBrwDetail") == "O")
      bLine    := oBrwDetail:bLine
      oBrwDetail:SetArray({})
      oBrwDetail:ResetLen()
      oBrwDetail:SetArray(aDtlData)
      oBrwDetail:ResetLen()
      oBrwDetail:Refresh()
      oBrwDetail:bLine := bLine
      oBrwDetail:DrawSelect()
      oBrwDetail:GoTop()
   Endif
   
return nil   

   