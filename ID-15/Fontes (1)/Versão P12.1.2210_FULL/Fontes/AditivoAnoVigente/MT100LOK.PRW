//Bibliotecas
#Include "TOTVS.ch" 
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

/*/{Protheus.doc} User Function MT100LOK
P.E. após inclusão da SF1
@type  Function
@author Thiago Goes
@since 08/05/2024
@version version
/*/
 
User Function MT100LOK()

Local lExecuta := ParamIxb[1]// Validações do usuário para inclusão ou alteração do item na NF de Despesas de Importação
Local lAtuAtf  := IIF(SF4->F4_ATUATF == "S", .T., .F.)

//Local cTesEnt,cTesSai,cTesSai1
Local nPosTes,nPosCodPro,nPosUM,nPosQuant,nPosVUnit,nPosLocal,nPosNFOri,nPosItemNF
Local cTes,cCodPro,cUM,nQuant,nVUnit,cLocal,cNFOri,cItemNF

Local aOccurs := {}

Local cField    := ""
Local cField2   := ""

Private lShow         := .T.
Private lWarnings     := .F.
Private nOutRet       := 0

Private lChkErrors    := .F.
Private cTitulo := ""

Private aLogs := {}

nPosTes := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "D1_TES"})
cTes := aCols[N][nPosTes]

nPosCC := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "D1_CC"})
cCC := aCols[N][nPosCC]

If lAtuAtf 
    If !Empty(cCC) .and. !Empty(cTes)
        If SubString(AllTrim(cCC),1,2) <> "04"
            cTitulo := " Cadastros X Rotina de Cálculo de rateio"

            cField  := cTes
            
            Aadd(aLogs,{GR_ERR,cField,TP_NOPROTH,FmtStr('A TES informada "{1}" só pode ser selecionada para os centros de custos iniciados em "04", Linha :'+strzero(N,2),{cField})})
        
            nOutRet := 0

            If     ( AScan(aLogs,{|l| l[1] == GR_ERR }) != 0 )
                nOutRet := GR_ERR
            ElseIf ( AScan(aLogs,{|l| l[1] == GR_WAR }) != 0 )
                nOutRet := GR_WAR
            Endif

            lRet := ShowResult(aLogs)
            If lChkErrors //Se corrigiu somente os erros...
                nOutRet := If(( AScan(aLogs,{|l| l[1] == GR_WAR }) != 0 ), GR_WAR, 0)
            Else
                nOutRet := 0
            Endif
    
            lExecuta := .F.
        EndIf 
    EndIf 
Elseif SubString(AllTrim(cCC),1,2) = "04"
      cTitulo := " Cadastros X Rotina de Cálculo de rateio"

            cField  := cTes
            
            Aadd(aLogs,{GR_ERR,cField,TP_NOPROTH,FmtStr('A TES informada "{1}" não pode ser selecionada para os centros de custos iniciados em "04", Linha :'+strzero(N,2),{cField})})
        
            nOutRet := 0

            If     ( AScan(aLogs,{|l| l[1] == GR_ERR }) != 0 )
                nOutRet := GR_ERR
            ElseIf ( AScan(aLogs,{|l| l[1] == GR_WAR }) != 0 )
                nOutRet := GR_WAR
            Endif

            lRet := ShowResult(aLogs)
            If lChkErrors //Se corrigiu somente os erros...
                nOutRet := If(( AScan(aLogs,{|l| l[1] == GR_WAR }) != 0 ), GR_WAR, 0)
            Else
                nOutRet := 0
            Endif
    
            lExecuta := .F.
EndIf 


Return (lExecuta)


*******************************************
Static Function ShowResult(aOccurs)
*******************************************
   Local lRet       := .T.
   Local aNodes     := {}
   Local oBtnCanc   := nil
   Local oBtnCont   := nil
   Local bCancelar  := {|| lRet := .F., oDlg:End() } 
   Local bConfirmar := {|| lRet := .T., oDlg:End() }
   //Local bFilMark   := {|| SetMarkErr(lChkErrors), LoadTree(oTree,aOccurs,aNodes,aDados,lChkErrors) }
   Local aHeader    := { "TIPO","CAMPO","DESCRICAO" }
   Local bExcel     := {|| U_Arr2Excel(aHeader,aDados,{||cTitulo})}
   Local aDados     := {}
   
   Static oDlg     
        
   DEFINE DIALOG oDlg TITLE cTitulo FROM 180,180 TO 640,820 PIXEL
   
   oPnl1Bottom:= TPanel():New(00,00,,oDlg,,.T.,,,,000,028)
   oPnl1Bottom:Align := CONTROL_ALIGN_BOTTOM
   
   //TCheckBox():New((oPnl1Bottom:nTop/2)+10,05,'Corrigir somente erros',bSetGet(lChkErrors),oPnl1Bottom,150,050,,bFilMark,;
   //                             /* oFont */, /* bValid */, /* nClrText */, /* nClrPane */, /* uParam14 */, /* lPixel */, /* cMsg */, /* uParam17 */, /* bWhen */ )

   oBtnExcel := TBtnBmp2():New(000,000,100,30,'PMSEXCEL',,,,;
                               bExcel,oPnl1Bottom,"Exportar para Excel...",,.T. )
   oBtnCanc  := TBtnBmp2():New(000,000,100,30,'PCOFXCANCEL.PNG',,,,bCancelar ,oPnl1Bottom,"Cancelar"               ,,.T. )
   oBtnCont  := TBtnBmp2():New(000,000,100,30,'PMSRRFSH.PNG'   ,,,,bConfirmar,oPnl1Bottom,"Continuar",,.T. )

   oBtnCont:Align  := CONTROL_ALIGN_RIGHT
   oBtnCanc:Align  := CONTROL_ALIGN_RIGHT
   oBtnExcel:Align := CONTROL_ALIGN_RIGHT
   
   oTree := DbTree():New(062,000,240,260,oDlg,,,.T.,/*lDisable*/,/*oFont*/)
   oTree:Align := CONTROL_ALIGN_ALLCLIENT
   
   LoadTree(oTree,aOccurs,aNodes,aDados,lChkErrors)
   
   //oTree:PTSendTree(aNodes)
   
  ACTIVATE DIALOG oDlg CENTERED
   
Return lRet    


********************************
Static Function FmtStr(cStr,aArgs)
********************************
   Local nX   := 0
   Local cRet := cStr
   For nX := 1 To Len(aArgs)
       cRet := StrTran(cRet,"{"+cValToChar(nX)+"}",cValToChar(aArgs[nX]))
   Next nX
Return cRet   

/*
************************************************
** Exporta um Array para Excel
**
************************************************
*/

User Function Arr2Excel(aHeader,aCols,bTitulo)

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
Return
