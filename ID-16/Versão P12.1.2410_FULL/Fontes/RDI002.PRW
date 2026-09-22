#Include 'Protheus.ch'

#DEFINE IMG_ND_ERR  "BR_CANCEL"
#DEFINE IMG_ND_WAR  "UPDWARNING17.PNG" /*"IC_20_X_CANCELAR.GIF" "BR_CANCEL.PNG" */

#DEFINE GR_ERR	1
#DEFINE GR_WAR	2

#DEFINE TP_TAMANHO	1
#DEFINE TP_DECIMAL	2
#DEFINE TP_OBRIGAT	3
#DEFINE TP_NOPROTH	4
#DEFINE TP_NOIMPOR	5
#DEFINE TP_TBNOEXS	6
#DEFINE TP_TYPEDIF	7

User Function RDI002(cCodigo,lShow,lWarnings,nOutRet)
     Local lRet    := .T.
     Local aOccurs := {}

     Default lShow         := .T.
     Default lWarnings     := .F.
     Default nOutRet       := 0
     
     Private lChkErrors    := .F.
     Private cTitulo := ""
     Private nDecimal,nTamanho,cTipo

     lRet := VldMain(cCodigo,aOccurs,lWarnings) .OR. Empty(aOccurs)
     
     nOutRet := 0
     If     ( AScan(aOccurs,{|l| l[1] == GR_ERR }) != 0 )
        nOutRet := GR_ERR
     ElseIf ( AScan(aOccurs,{|l| l[1] == GR_WAR }) != 0 )
        nOutRet := GR_WAR
     Endif
     
     If lShow .And. .Not. lRet 
        lRet := ShowResult(aOccurs,cCodigo)
        If lRet 
           If lChkErrors //Se corrigiu somente os erros...
              nOutRet := If(( AScan(aOccurs,{|l| l[1] == GR_WAR }) != 0 ), GR_WAR, 0)
           Else
              nOutRet := 0
           Endif
        Endif
     Endif
     
Return lRet

************************************************
Static Function VldMain(cCodigo,aLogs,lWarnings)
************************************************
   Local lRet      := .T.
   Local aAreaSX3  := SX3->(GetArea())
   Local aAreaQZ1  := QZ1->(GetArea())
   Local aAreaQZ2  := QZ2->(GetArea())
   Local cAlias    := ""
   Local aFields   := {}
   Local cField    := ""
   Local nSize     := 0 //ALTERADO POR THIAGO GOES EM 28/07/2020
   Local cObrigat  := ""
   Local lObrigat  := .F.
   Local lExist    := .F.
   Local aSE1Brw   := {}
   Local nX
   aLogs := {}
   
   SX3->(DbSetOrder(2)) //X3_CAMPO
   QZ1->(DbSetOrder(1)) //QZ1_FILIAL+QZ1_CODIGO
   QZ2->(DbSetOrder(1)) //QZ2_FILIAL+QZ2_CODEXT+QZ2_SEQ
   QZ1->(dbSeek(xFilial("QZ1") + cCodigo))
   QZ2->(dbSeek(xFilial("QZ2") + cCodigo))
   
   cAlias := AllTrim(QZ1->QZ1_DESTIN)
   
   cTitulo := cAlias+": Dicionário X Cadastro de Processos de Importação"
   
   While QZ2->(!Eof()) .And. QZ2->QZ2_CODEXT == cCodigo
         
         cField   := Alltrim(QZ2->QZ2_CPODES)
         
         If ( "_XMIGLT" $ cField )
            QZ2->(DbSkip(1))
            Loop
         Endif
         
         cObrigat := If(X3Obrigat(cField),"S","N")
          
         Aadd(aFields,cField)
         nSize := Len(cField)
         If ! SX3->(dbSeek(PadR(cField,nSize)))
            Aadd(aLogs,{GR_ERR,cField,TP_NOPROTH,U_FormatStr('O campo "{1}" não existe no dicionário!',{cField})})
            QZ2->(DbSkip())
            Loop
         Endif

         cTipo := FWSX3Util():GetFieldType(QZ2->QZ2_CPODES) //Alterado por Thiago Goes
         nTamanho := TAMSX3(QZ2->QZ2_CPODES)[1]
         nDecimal := TAMSX3(QZ2->QZ2_CPODES)[2]

         If QZ2->QZ2_TIPDES <> cTipo
            Aadd(aLogs,{GR_ERR,cField,TP_TYPEDIF,U_FormatStr('Campo "{1}", tipo ("{2}") está diferente no dicionário ("{3}")!',{cField,QZ2->QZ2_TIPDES,cTipo})})
         Endif

         If GetdToVal(QZ2->QZ2_TAMDES) <> nTamanho
            Aadd(aLogs,{GR_ERR,cField,TP_TAMANHO,U_FormatStr('Campo "{1}", tamanho ("{2}") está diferente no dicionário ("{3}")!',{cField,GetdToVal(QZ2->QZ2_TAMDES),nTamanho})})
         Endif
         
         If QZ2->QZ2_DECDES <> nDecimal
            Aadd(aLogs,{GR_ERR,cField,TP_DECIMAL,U_FormatStr('Campo "{1}", decimal ("{2}") está diferente no dicionário ("{3}")!',{cField,QZ2->QZ2_DECDES,GetSx3Cache( cField ,"X3_DECIMAL")})})
         Endif

         If QZ2->QZ2_OBRDES <> cObrigat 
            Aadd(aLogs,{If(( cObrigat == "S" ),GR_ERR,GR_WAR),cField,TP_OBRIGAT,U_FormatStr('Campo "{1}", obrigatóriedade ("{2}") está diferente no dicionário ("{3}")!',{cField,QZ2->QZ2_OBRDES,cObrigat})})
         Endif
         
         QZ2->(dbskip())
   Enddo
   
   SX3->(DbSetOrder(1)) //X3_ARQUIVO+X3_ORDEM
   If ! SX3->(DbSeek(cAlias))
      Aadd(aLogs,{GR_ERR,cAlias,TP_TBNOEXS,U_FormatStr('Tabela "{1}" não definida no dicionário!',{cAlias})})
      QZ1->(RestArea(aAreaQZ1))
      QZ2->(RestArea(aAreaQZ2))
      SX3->(RestArea(aAreaSX3))
      return .F.
   Endif
   aSE1Brw := FWSX3Util():GetAllFields( cAlias , .F. )   
   For nx:=1 To Len(aSE1Brw)

         cField   := AllTrim(aSE1Brw[nX])
         
         If GetSx3Cache( cField ,"X3_CONTEXT") == "V" .OR. ( "_XMIGLT" $ cField )
         Else

            lExist   := ( AScan(aFields,{|f| f == cField}) > 0 )
            
            If !lExist //As validações já foram realizadas no loop anterior...
            
               lObrigat := X3Obrigat(cField)
               
               If lObrigat
                  Aadd(aLogs,{GR_ERR,cField,TP_NOPROTH,U_FormatStr('O Campo "{1}" é OBRIGATÓRIO e não foi definido para a importação.',{cField})})
               Else
                  Aadd(aLogs,{GR_WAR,cField,TP_NOIMPOR,U_FormatStr('O Campo "{1}" não foi definido para a importação.',{cField})})
               Endif
            EndIf
         EndIf
   Next   
   QZ1->(RestArea(aAreaQZ1))
   QZ2->(RestArea(aAreaQZ2))
   SX3->(RestArea(aAreaSX3))
   
   lRet := Empty(aLogs) .OR. If(lWarnings,Empty(aLogs), ( AScan(aLogs,{|l| l[1] == GR_ERR }) == 0 ) )
   
return lRet

*******************************************
Static Function ShowResult(aOccurs,cCodigo)
*******************************************
   Local lRet       := .T.
   Local aNodes     := {}
   Local oBtnCanc   := nil
   Local oBtnCont   := nil
   Local bCancelar  := {|| lRet := .F., oDlg:End() } 
   Local bConfirmar := {|| lRet := ExecSinc(cCodigo,aOccurs), oDlg:End() }
   Local bFilMark   := {|| SetMarkErr(lChkErrors), LoadTree(oTree,aOccurs,aNodes,aDados,lChkErrors) }
   Local bExcel     := {|| U_RDIIF001({|| U_Array2Excel(aHeader,aDados,cTitulo) },"Aguarde...","Exportando para o Excel...") }
   Local aHeader    := { "TIPO","CAMPO","DESCRICAO" }
   Local aDados     := {}
   
   Static oDlg     
   
   Default cCodigo := ""
   
   DEFINE DIALOG oDlg TITLE cTitulo FROM 180,180 TO 640,820 PIXEL
   
   oPnl1Bottom:= TPanel():New(00,00,,oDlg,,.T.,,,,000,028)
   oPnl1Bottom:Align := CONTROL_ALIGN_BOTTOM
   
   TCheckBox():New((oPnl1Bottom:nTop/2)+10,005,'Corrigir somente erros',bSetGet(lChkErrors),oPnl1Bottom,150,050,,bFilMark,;
                                /* oFont */, /* bValid */, /* nClrText */, /* nClrPane */, /* uParam14 */, /* lPixel */, /* cMsg */, /* uParam17 */, /* bWhen */ )

   oBtnExcel := TBtnBmp2():New(000,000,100,30,'PMSEXCEL',,,,;
                               bExcel,oPnl1Bottom,"Exportar para Excel...",,.T. )
   oBtnCanc  := TBtnBmp2():New(000,000,100,30,'PCOFXCANCEL.PNG',,,,bCancelar ,oPnl1Bottom,"Cancelar"               ,,.T. )
   oBtnCont  := TBtnBmp2():New(000,000,100,30,'PMSRRFSH.PNG'   ,,,,bConfirmar,oPnl1Bottom,"Sincronizar e continuar",,.T. )

   oBtnCont:Align  := CONTROL_ALIGN_RIGHT
   oBtnCanc:Align  := CONTROL_ALIGN_RIGHT
   oBtnExcel:Align := CONTROL_ALIGN_RIGHT
   
   oTree := DbTree():New(062,000,240,260,oDlg,,,.T.,/*lDisable*/,/*oFont*/)
   oTree:Align := CONTROL_ALIGN_ALLCLIENT
   
   LoadTree(oTree,aOccurs,aNodes,aDados,lChkErrors)
   
   //oTree:PTSendTree(aNodes)
   
  ACTIVATE DIALOG oDlg CENTERED
   
Return lRet    

*****************************************
Static Function ExecSinc(cCodigo,aOccurs)
*****************************************
   Local lRet      := .T.
   Local bExecSinc := {|| lRet := SincCad(cCodigo,aOccurs) }

   MsgRun( "Sincronizando com o dicionário..." , "Aguarde..." , bExecSinc )   
   
return lRet   

****************************************
Static Function SincCad(cCodigo,aOccurs)
****************************************                                        
   Local lRet      := .T.
   Local aAreaSX3  := SX3->(GetArea())
   Local aAreaQZ1  := QZ1->(GetArea())
   Local aAreaQZ2  := QZ2->(GetArea())
   Local cAlias    := ""
   Local aFields   := {}
   Local cField    := ""
   Local nSize     := 0 //ALTERADO POR THIAGO GOES EM 28/07/2020
   Local lObrigat  := .F.
   Local lExist    := .F.
   Local nExist    := 0
   Local aOlds     := {}
   Local nSeq      := 0
   Local nX        := 0
   Local aScript   := {}
   Local aSE1Brw := {}
   Local nx
   
   Default cCodigo := QZ1->QZ1_CODIGO
   Default aOccurs := {}

   SX3->(DbSetOrder(2)) //X3_CAMPO
   QZ1->(DbSetOrder(1)) //QZ1_FILIAL+QZ1_CODIGO
   QZ2->(DbSetOrder(1)) //QZ2_FILIAL+QZ2_CODEXT+QZ2_SEQ
   QZ1->(dbSeek(xFilial("QZ1") + cCodigo))
   QZ2->(dbSeek(xFilial("QZ2") + cCodigo))
   
   cAlias := AllTrim(QZ1->QZ1_DESTIN)
   
   If lChkErrors
      For nX := 1 To Len(aOccurs)

          cField := aOccurs[nX,2]

          
         cTipo := FWSX3Util():GetFieldType(cField) //Alterado por Thiago Goes
         nTamanho := TAMSX3(cField)[1]
         nDecimal := TAMSX3(cField)[2]

      
          If aOccurs[nX,1] != GR_ERR .OR. ( "_XMIGLT" $ cField ) 
             Loop
          Endif
          nSize:= Len(cField)
          If ! SX3->(dbSeek(PadR(cField,nSize)))
             MsgStop(U_FormatStr('O campo "{1}" não existe no dicionário!',{cField}))
             Loop
          Endif

          Do Case
             Case aOccurs[nX,3] == TP_TYPEDIF
                  Aadd(aScript,U_FormatStr("UPDATE "+RetSqlName("QZ2")+" SET QZ2_TIPDES='{1}' WHERE D_E_L_E_T_=' ' AND QZ2_CODEXT='{2}' AND QZ2_CPODES='{3}'" ,{cTipo,cCodigo,cField}))
             Case aOccurs[nX,3] == TP_TAMANHO
                  Aadd(aScript,U_FormatStr("UPDATE "+RetSqlName("QZ2")+" SET QZ2_TAMDES='{1}' WHERE D_E_L_E_T_=' ' AND QZ2_CODEXT='{2}' AND QZ2_CPODES='{3}'" ,{nTamanho,cCodigo,cField}))
             Case aOccurs[nX,3] == TP_DECIMAL
                  Aadd(aScript,U_FormatStr("UPDATE "+RetSqlName("QZ2")+" SET QZ2_DECDES ={1}  WHERE D_E_L_E_T_=' ' AND QZ2_CODEXT='{2}' AND QZ2_CPODES='{3}'" ,{nDecimal,cCodigo,cField}))
             Case aOccurs[nX,3] == TP_OBRIGAT
                  Aadd(aScript,U_FormatStr("UPDATE "+RetSqlName("QZ2")+" SET QZ2_OBRDES='{1}' WHERE D_E_L_E_T_=' ' AND QZ2_CODEXT='{2}' AND QZ2_CPODES='{3}'" ,{If(X3Obrigat(cField),"S","N"),cCodigo,cField}))
          EndCase
              
      Next nX
      
      lRet := .T.
      For nX := 1 To Len(aScript)
          lRet := (TCSqlExec(aScript[nX])  >= 0)
          If ! lRet
             MsgStop("Erro durante a sincronização! Verifique." + CRLF + CRLF + TCSQLError() )
             Exit
          Endif
      Next nX

      QZ1->(RestArea(aAreaQZ1))
      QZ2->(RestArea(aAreaQZ2))
      SX3->(RestArea(aAreaSX3))
      
      Return .T.
   Endif
   
   While QZ2->(!Eof()) .And. QZ2->QZ2_CODEXT == cCodigo
         
         //If ( AllTrim(QZ2->QZ2_CPOORI) <> AllTrim(QZ2->QZ2_CPODES) )
            Aadd(aOlds,{AllTrim(QZ2->QZ2_CPODES),AllTrim(QZ2->QZ2_CPOORI),AllTrim(QZ2->QZ2_VALIDA),AllTrim(QZ2->QZ2_VLDPRO),AllTrim(QZ2->QZ2_RELACA)})
         //Endif
         
         QZ2->(RecLock("QZ2",.F.))
         QZ2->(DbDelete())
         QZ2->(MsUnLock())
         
         QZ2->(DbSkip(1))
   EndDo
   
   SX3->(DbSetOrder(1)) //X3_ARQUIVO+X3_ORDEM
   If ! SX3->(DbSeek(cAlias))
      MsgStop(U_FormatStr('Tabela "{1}" não definida no dicionário!',{cAlias}))
      QZ1->(RestArea(aAreaQZ1))
      QZ2->(RestArea(aAreaQZ2))
      SX3->(RestArea(aAreaSX3))
      return .F.
   Endif
   
   nSeq := 0
   aSE1Brw := FWSX3Util():GetAllFields( cAlias, .F. )
   For nx:=1 TO Len(aSE1Brw)

         cField   := AllTrim(aSE1Brw[nX])

         cTipo := FWSX3Util():GetFieldType(cField) //Alterado por Thiago Goes
         nTamanho := TAMSX3(cField)[1]
         nDecimal := TAMSX3(cField)[2]

         If GetSx3Cache( cField ,"X3_CONTEXT") == "V" .OR. ( "_XMIGLT" $ cField )
         Else         
            nSeq++
         
            nExist   := AScan(aOlds,{|f| f[1] == cField})
            lExist   := ( nExist > 0 )
            
            QZ2->(RecLock("QZ2",.T.))
            QZ2->QZ2_FILIAL    := xFilial("QZ2")
            QZ2->QZ2_CODEXT    := cCodigo
            QZ2->QZ2_SEQ       := StrZero(nSeq,3)
            QZ2->QZ2_CPODES    := cField
            QZ2->QZ2_TIPCPO    := "6" //Macro
            QZ2->QZ2_PROVLD    := "N" //Valida Protheus ? 
            QZ2->QZ2_REJEIT    := "N" //Rejeita registro ?
            QZ2->QZ2_DESCDE    := GetSx3Cache( cField ,"X3_DESCRIC")
            QZ2->QZ2_TIPDES    := cTipo
            QZ2->QZ2_TAMDES    := cValToChar(nTamanho)    
            QZ2->QZ2_DECDES    := nDecimal
            QZ2->QZ2_OBRDES    := If(X3Obrigat(cField),"S","N")
            QZ2->QZ2_PREDES    := GetSx3Cache( cField ,"X3_F3")
            QZ2->QZ2_VIRTUA    := "N"
            QZ2->QZ2_CBOXDE    := GetSx3Cache( cField ,"X3_CBOX")
            QZ2->QZ2_GRPSXG    := GetSx3Cache( cField ,"X3_GRPSXG")

            If lExist
               QZ2->QZ2_CPOORI    := aOlds[nExist,2]
               QZ2->QZ2_VALIDA    := aOlds[nExist,3]
               QZ2->QZ2_VLDPRO    := aOlds[nExist,4]
               QZ2->QZ2_RELACA    := aOlds[nExist,5]
            Else
               QZ2->QZ2_CPOORI    := cField
               QZ2->QZ2_VALIDA    := GetSx3Cache( cField ,"X3_VLDUSER")
               QZ2->QZ2_VLDPRO    := GetSx3Cache( cField ,"X3_VALID")
               QZ2->QZ2_RELACA    := GetSx3Cache( cField ,"X3_RELACAO") 
            Endif 
            QZ2->(MsUnLock("QZ2"))
         EndIf         
   Next
   QZ1->(RestArea(aAreaQZ1))
   QZ2->(RestArea(aAreaQZ2))
   SX3->(RestArea(aAreaSX3))

Return lRet

**********************************
Static Function SetMarkErr(lValue)
**********************************
   
   lChkErrors := lValue
   
return .T.

Static Function LoadTree(oTree,aOccurs,aNodes,aDados,lChkErrors)

   aNodes := {}
   aDados := {}

   aSort( aOccurs,,, { |x,y| x[1] < y[1] .And. x[2] < y[2] .And. x[3] < y[3] } )
   
   If ( AScan(aOccurs,{|x| x[1] == GR_ERR}) > 0 )
      Aadd(aNodes,{"00","ERR","","Erro(s)",IMG_ND_ERR,IMG_ND_ERR})
      AEval(aOccurs,{|o| If(o[1] == GR_ERR,(Aadd(aNodes,{"01",StrZero(Len(aNodes)+1,3),"",o[4],"",""}),Aadd(aDados,{"Erro",o[2],o[4]})),)})
   Endif

   If ( AScan(aOccurs,{|x| x[1] == GR_WAR}) > 0 )
      If ! lChkErrors
         Aadd(aNodes,{"00","WAR","","Alerta(s)",IMG_ND_WAR,IMG_ND_WAR})
      Endif
      AEval(aOccurs,{|o| If(o[1] == GR_WAR,(If(!lChkErrors,Aadd(aNodes,{"01",StrZero(Len(aNodes)+1,3),"",o[4],"",""}),),Aadd(aDados,{"Alerta",o[2],o[4]})),)})
   Endif

   //oTree:SetDisable()
   oTree:Reset()
   oTree:BeginUpdate()
   oTree:PTSendTree(aNodes)
   oTree:SetEnable()
   //oTree:EndUpdate()
   
return nil   
