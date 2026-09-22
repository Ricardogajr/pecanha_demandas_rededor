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

User Function CNCTAVLD(cCodigo,lShow,lWarnings,nOutRet)
     Local lRet    := .T.
     Local aOccurs := {}

     Default lShow         := .T.
     Default lWarnings     := .F.
     Default nOutRet       := 0
     
     Private lChkErrors    := .F.
     Private cTitulo := ""
     
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
   Local aAreaSX3  := SX3->(FWGetArea())
   Local aAreaZVJ  := ZVJ->(FWGetArea())
   Local aAreaZVK  := ZVK->(FWGetArea())
   Local cAlias    := ""
   Local aFields   := {}
   Local cField    := ""
   Local _nC := 0 //nSize     := Len(SX3->X3_CAMPO)
   Local cObrigat  := ""
   Local lObrigat  := .F.
   Local lExist    := .F.
   Local _aCmpX3 := {}
   
   aLogs := {}
     SX3->(DbSetOrder(2)) //X3_CAMPO
   ZVJ->(DbSetOrder(1)) //ZVJ_FILIAL+ZVJ_CODIGO
   ZVK->(DbSetOrder(1)) //ZVK_FILIAL+ZVK_CODEXT+ZVK_SEQ
   ZVJ->(dbSeek(xFilial("ZVJ") + cCodigo))
   ZVK->(dbSeek(xFilial("ZVK") + cCodigo))
   
   cAlias := AllTrim(ZVJ->ZVJ_DESTIN)
   
   cTitulo := cAlias+": Dicionário X Cadastro de Processos de Importação"
   
   While ZVK->(!Eof()) .And. ZVK->ZVK_CODEXT == cCodigo
         
         cField   := Alltrim(ZVK->ZVK_CPODES)
         
         If ( "_XMIGLT" $ cField )
            ZVK->(DbSkip(1))
            Loop
         Endif
         
         cObrigat := If(X3Obrigat(cField),"S","N")
          
         Aadd(aFields,cField)
         
         If Empty(FWSX3Util():GetFieldType(cField)) //! SX3->(dbSeek(PadR(cField,nSize)))
            Aadd(aLogs,{GR_ERR,cField,TP_NOPROTH,U_FmtStr('O campo "{1}" não existe no dicionário!',{cField})})
            ZVK->(DbSkip())
            Loop
         Endif
         
         If ZVK->ZVK_TIPDES <> GetSx3Cache(cField, 'X3_TIPO')
            Aadd(aLogs,{GR_ERR,cField,TP_TYPEDIF,U_FmtStr('Campo "{1}", tipo ("{2}") está diferente no dicionário ("{3}")!',{cField,ZVK->ZVK_TIPDES,GetSx3Cache(cField, 'X3_TIPO')})})
         Endif

         If GetdToVal(ZVK->ZVK_TAMDES) <> GetSx3Cache(cField, 'X3_TAMANHO')
            Aadd(aLogs,{GR_ERR,cField,TP_TAMANHO,U_FmtStr('Campo "{1}", tamanho ("{2}") está diferente no dicionário ("{3}")!',{cField,GetdToVal(ZVK->ZVK_TAMDES),GetSx3Cache(cField, 'X3_TAMANHO')})})
         Endif
         
         If ZVK->ZVK_DECDES <> GetSx3Cache(cField, 'X3_DECIMAL')
            Aadd(aLogs,{GR_ERR,cField,TP_DECIMAL,U_FmtStr('Campo "{1}", decimal ("{2}") está diferente no dicionário ("{3}")!',{cField,ZVK->ZVK_DECDES,GetSx3Cache(cField, 'X3_DECIMAL')})})
         Endif

         If ZVK->ZVK_OBRDES <> cObrigat 
            Aadd(aLogs,{If(( cObrigat == "S" ),GR_ERR,GR_WAR),cField,TP_OBRIGAT,U_FmtStr('Campo "{1}", obrigatóriedade ("{2}") está diferente no dicionário ("{3}")!',{cField,ZVK->ZVK_OBRDES,cObrigat})})
         Endif
         
         ZVK->(dbskip())
   Enddo
   
   //SX3->(DbSetOrder(1)) //X3_ARQUIVO+X3_ORDEM
   If !(FwSX2Util():SeekX2File( cAlias )) //! SX3->(DbSeek(cAlias))
      Aadd(aLogs,{GR_ERR,cAlias,TP_TBNOEXS,U_FmtStr('Tabela "{1}" não definida no dicionário!',{cAlias})})
      ZVJ->(FWRestArea(aAreaZVJ))
      ZVK->(FWRestArea(aAreaZVK))
      SX3->(FWRestArea(aAreaSX3))
      return .F.
   Endif
   _aCmpX3 := FWSX3Util():GetAllFields(cAlias, .T. ) 
   For _nC := 1 to Len(_aCmpX3) //While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias

         cField   := Alltrim(GetSx3Cache(_aCmpX3[_nC], 'X3_CAMPO'))
         
         If GetSx3Cache(cField, 'X3_CONTEXT') == "V" .OR. ( "_XMIGLT" $ cField )
            //SX3->(DbSkip())
            Loop
         Endif

         lExist   := ( AScan(aFields,{|f| f == cField}) > 0 )
         
         If lExist //As validações já foram realizadas no loop anterior...
            //SX3->(DbSkip())
            Loop
         endif
         
         lObrigat := X3Obrigat(cField)
         
         If lObrigat
            Aadd(aLogs,{GR_ERR,cField,TP_NOPROTH,U_FmtStr('O Campo "{1}" é OBRIGATÓRIO e não foi definido para a importação.',{cField})})
         Else
            Aadd(aLogs,{GR_WAR,cField,TP_NOIMPOR,U_FmtStr('O Campo "{1}" não foi definido para a importação.',{cField})})
         Endif
         
         //SX3->(DbSkip())
   Next _nC //Enddo
   
   ZVJ->(FWRestArea(aAreaZVJ))
   ZVK->(FWRestArea(aAreaZVK))
   SX3->(FWRestArea(aAreaSX3))
   
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
   Local bExcel     := {|| U_Array2Excel(aHeader,aDados,{||cTitulo})}
   Local aHeader    := { "TIPO","CAMPO","DESCRICAO" }
   Local aDados     := {}
   
   Static oDlg     
   
   Default cCodigo := ""
   
   
   
   /*
   aSort( aOccurs,,, { |x,y| x[1] < y[1] .And. x[2] < y[2] .And. x[3] < y[3] } )
   
   If ( AScan(aOccurs,{|x| x[1] == GR_ERR}) > 0 )
      Aadd(aNodes,{"00","ERR","","Erro(s)",IMG_ND_ERR,IMG_ND_ERR})
      AEval(aOccurs,{|o| If(o[1] == GR_ERR,(Aadd(aNodes,{"01",StrZero(Len(aNodes)+1,3),"",o[4],"",""}),Aadd(aDados,{"Erro",o[2],o[4]})),)})
   Endif

   If ( AScan(aOccurs,{|x| x[1] == GR_WAR}) > 0 )
      Aadd(aNodes,{"00","WAR","","Alerta(s)",IMG_ND_WAR,IMG_ND_WAR})
      AEval(aOccurs,{|o| If(o[1] == GR_WAR,(Aadd(aNodes,{"01",StrZero(Len(aNodes)+1,3),"",o[4],"",""}),Aadd(aDados,{"Alerta",o[2],o[4]})),)})
   Endif
   */
                        
   DEFINE DIALOG oDlg TITLE cTitulo FROM 180,180 TO 640,820 PIXEL
   
   oPnl1Bottom:= TPanel():New(00,00,,oDlg,,.T.,,,,000,028)
   oPnl1Bottom:Align := CONTROL_ALIGN_BOTTOM
   
   TCheckBox():New((oPnl1Bottom:nTop/2)+10,05,'Corrigir somente erros',bSetGet(lChkErrors),oPnl1Bottom,150,050,,bFilMark,;
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
   Local aAreaSX3  := SX3->(FWGetArea())
   Local aAreaZVJ  := ZVJ->(FWGetArea())
   Local aAreaZVK  := ZVK->(FWGetArea())
   Local cAlias    := ""
   Local aFields   := {}
   Local cField    := ""
   //Local nSize     := Len(SX3->X3_CAMPO)
   Local lObrigat  := .F.
   Local lExist    := .F.
   Local nExist    := 0
   Local aOlds     := {}
   Local nSeq      := 0
   Local nX        := 0
   Local aScript   := {}
   LOcal _aCmpX3 := {}
   Default cCodigo := ZVJ->ZVJ_CODIGO
   Default aOccurs := {}

   SX3->(DbSetOrder(2)) //X3_CAMPO
   ZVJ->(DbSetOrder(1)) //ZVJ_FILIAL+ZVJ_CODIGO
   ZVK->(DbSetOrder(1)) //ZVK_FILIAL+ZVK_CODEXT+ZVK_SEQ
   ZVJ->(dbSeek(xFilial("ZVJ") + cCodigo))
   ZVK->(dbSeek(xFilial("ZVK") + cCodigo))
   
   cAlias := AllTrim(ZVJ->ZVJ_DESTIN)
   
   If lChkErrors
      For nX := 1 To Len(aOccurs)

          cField := aOccurs[nX,2]
      
          If aOccurs[nX,1] != GR_ERR .OR. ( "_XMIGLT" $ cField ) 
             Loop
          Endif
          
          If Empty(FWSX3Util():GetFieldType(cField)) //! SX3->(dbSeek(PadR(cField,nSize)))
             MsgStop(U_FmtStr('O campo "{1}" não existe no dicionário!',{cField}))
             Loop
          Endif

          Do Case
             Case aOccurs[nX,3] == TP_TYPEDIF
                  Aadd(aScript,U_FmtStr("UPDATE "+RetSqlName("ZVK")+" SET ZVK_TIPDES='{1}' WHERE D_E_L_E_T_=' ' AND ZVK_CODEXT='{2}' AND ZVK_CPODES='{3}'" ,{GetSx3Cache(cField, 'X3_TIPO'),cCodigo,cField}))
             Case aOccurs[nX,3] == TP_TAMANHO
                  Aadd(aScript,U_FmtStr("UPDATE "+RetSqlName("ZVK")+" SET ZVK_TAMDES='{1}' WHERE D_E_L_E_T_=' ' AND ZVK_CODEXT='{2}' AND ZVK_CPODES='{3}'" ,{GetSx3Cache(cField, 'X3_TAMANHO'),cCodigo,cField}))
             Case aOccurs[nX,3] == TP_DECIMAL
                  Aadd(aScript,U_FmtStr("UPDATE "+RetSqlName("ZVK")+" SET ZVK_DECDES ={1}  WHERE D_E_L_E_T_=' ' AND ZVK_CODEXT='{2}' AND ZVK_CPODES='{3}'" ,{GetSx3Cache(cField, 'X3_DECIMAL'),cCodigo,cField}))
             Case aOccurs[nX,3] == TP_OBRIGAT
                  Aadd(aScript,U_FmtStr("UPDATE "+RetSqlName("ZVK")+" SET ZVK_OBRDES='{1}' WHERE D_E_L_E_T_=' ' AND ZVK_CODEXT='{2}' AND ZVK_CPODES='{3}'" ,{If(X3Obrigat(cField),"S","N"),cCodigo,cField}))
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

      ZVJ->(FWRestArea(aAreaZVJ))
      ZVK->(FWRestArea(aAreaZVK))
      SX3->(FWRestArea(aAreaSX3))
      
      Return .T.
   Endif
   
   While ZVK->(!Eof()) .And. ZVK->ZVK_CODEXT == cCodigo
         
         If ( AllTrim(ZVK->ZVK_CPOORI) <> AllTrim(ZVK->ZVK_CPODES) )
            Aadd(aOlds,{AllTrim(ZVK->ZVK_CPODES),AllTrim(ZVK->ZVK_CPOORI),AllTrim(ZVK->ZVK_VALIDA),AllTrim(ZVK->ZVK_VLDPRO),AllTrim(ZVK->ZVK_RELACA)})
         Endif
         
         ZVK->(RecLock("ZVK",.F.))
         ZVK->(DbDelete())
         ZVK->(MsUnLock())
         
         ZVK->(DbSkip(1))
   EndDo
   
   //SX3->(DbSetOrder(1)) //X3_ARQUIVO+X3_ORDEM
   If !FwSX2Util():SeekX2File(cAlias) // SX3->(DbSeek(cAlias))
      MsgStop(U_FmtStr('Tabela "{1}" não definida no dicionário!',{cAlias}))
      ZVJ->(FWRestArea(aAreaZVJ))
      ZVK->(FWRestArea(aAreaZVK))
      SX3->(FWRestArea(aAreaSX3))
      return .F.
   Endif
   _aCmpX3 := FWSX3Util():GetAllFields(cAlias, .T. )
   nSeq := 0
   For nX := 1 to Len(_aCmpX3) //While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias

         cField   := Alltrim(GetSx3Cache(_aCmpX3[nX], 'X3_CAMPO'))
         
         If GetSx3Cache(cField, 'X3_CONTEXT') == "V" .OR. ( "_XMIGLT" $ cField )
            //SX3->(DbSkip())
            Loop
         Endif
         
         nSeq++
       
         nExist   := AScan(aOlds,{|f| f[1] == cField})
         lExist   := ( nExist > 0 )
         
         ZVK->(RecLock("ZVK",.T.))
         ZVK->ZVK_FILIAL    := xFilial("ZVK")
         ZVK->ZVK_CODEXT    := cCodigo
         ZVK->ZVK_SEQ       := StrZero(nSeq,3)
         ZVK->ZVK_CPODES    := cField
         ZVK->ZVK_TIPCPO    := "6" //Macro
         ZVK->ZVK_PROVLD    := "N" //Valida Protheus ? 
         ZVK->ZVK_REJEIT    := "N" //Rejeita registro ?
         ZVK->ZVK_DESCDE    := GetSx3Cache(cField, 'X3_DESCRIC')
         ZVK->ZVK_TIPDES    := GetSx3Cache(cField, 'X3_TIPO')
         ZVK->ZVK_TAMDES    := cValToChar(GetSx3Cache(cField, 'X3_TAMANHO'))    
         ZVK->ZVK_DECDES    := GetSx3Cache(cField, 'X3_DECIMAL')
         ZVK->ZVK_OBRDES    := If(X3Obrigat(cField),"S","N")
         ZVK->ZVK_PREDES    := GetSx3Cache(cField, 'X3_F3')
         ZVK->ZVK_VIRTUA    := "N"
         ZVK->ZVK_CBOXDE    := GetSx3Cache(cField, 'X3_CBOX')
         ZVK->ZVK_GRPSXG    := GetSx3Cache(cField, 'X3_GRPSXG')

         If lExist
            ZVK->ZVK_CPOORI    := aOlds[nExist,2]
            ZVK->ZVK_VALIDA    := aOlds[nExist,3]
            ZVK->ZVK_VLDPRO    := aOlds[nExist,4]
            ZVK->ZVK_RELACA    := aOlds[nExist,5]
         Else
            ZVK->ZVK_CPOORI    := cField
            ZVK->ZVK_VALIDA    := GetSx3Cache(cField, 'X3_VLDUSER')
            ZVK->ZVK_VLDPRO    := GetSx3Cache(cField, 'X3_VALID')
            ZVK->ZVK_RELACA    := GetSx3Cache(cField, 'X3_RELACAO')
         Endif 
         ZVK->(MsUnLock("ZVK"))
         
         //SX3->(DbSkip())
   Next nX //Enddo   

   ZVJ->(FWRestArea(aAreaZVJ))
   ZVK->(FWRestArea(aAreaZVK))
   SX3->(FWRestArea(aAreaSX3))

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
