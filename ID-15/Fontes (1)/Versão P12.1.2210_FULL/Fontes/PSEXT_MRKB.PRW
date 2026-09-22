#INCLUDE "PROTHEUS.CH"        
#INCLUDE "TOPCONN.CH" 
#include "rwmake.ch"  
#include "fileio.ch"    
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#Include "DBTREE.CH"
#Include "HBUTTON.CH"
#Define XENTERX Chr(13)+Chr(10) 
//=============================================================================================================================   
//Programa............: AGL_MRKB()
//Autor...............: Thiago Pereira 
//Data................: 06/03/2021
//Descricao / Objetivo: Aglutinação de Títulos - Seleção   
//=============================================================================================================================
User Function AGL_MRKB()
//=============================================================================================================================

Local lPanelFin     := If (FindFunction("IsPanelFin"),IsPanelFin(),.F.)     
Local lOK           := .F.

Private axButtons    := {}
Private aSize       := MSADVSIZE()	  
Private nOpca       := 0	
Private nValor      := 0   
Private nQtdTit     := 0
Private lInverte    := .F.
Private lVldAD	     := .T.  
Private cNumbor     := SPACE(6)  
Private cMark       := GetMark( )  
Private lMark       := .T.
Private aRotina     := {}
Private cCadastro   := OEMTOANSI("Aglutinação de Títulos a Pagar (INSS)-Seleção")
Private cMark       := GetMark()
Private cArq        := "" 
Private aSays       := {}        
Private aBotoes     := {}   
Private aXCores     := {}
Private cPerg       := "AGLP02"  
Private aCabec      := {}  
Private aDados      := {}  
Private afields     := {"E2_EMISSAO","E2_VENCTO","E2_VENCREA"  ,"E2_FILIAL","E2_FILORIG","E2_NUM" ,"E2_TIPO","E2_PREFIXO","E2_PARCELA","E2_NATUREZ","E2_CODINS","E2_VALOR","E2_XVJUROS","E2_XVMULTA","E2_BASEINS","E2_FORNECE","E2_LOJA","E2_NOMFOR","E1_NUM","E1_TIPO","E1_CLIENTE","E1_LOJA","A2_NOME" ,"A2_CGC"   ,"E2_HIST"  ,"E2_TITPAI"} 
Private aTitulo     := {"Dt Emissão","Dt Vencto","Dt Vct Real" ,"Filial"   ,"Fil Orig"  ,"Num Tit","Tipo"   ,"Pref"      ,"Parc"      ,"Nat Financ","Cod INS"  ,"Vr Titulo","Vr Juros" ,"Vr Multa" ,"Base Calc ","Fornece"   ,"Loja"   ,"NomFor"   ,"Tit Pai","Tp Pai","Forn Pai"  ,"Lj Pai" ,"Nome Pai","CNPJ Pai","Histórico" ,"Chave Titulo Pai"} 
Private cAnoMes1    := ""
Private cAnoMes2    := ""  
Private cData01     := ""
Private cData02     := ""       
Private apHeaderEx  := {}
Private apColsEx    := {}
Private cMV_INSS    := SuperGetMv("MV_INSS",.F.,.F.) 
Private cMV_XINSS   := SuperGetMv("MV_XINSS",.F.,.F.)   
Private cMV_XE2CCD  := GetMv("MV_XE2CCD")
Private cMV_XE2CLVD := GetMv("MV_XE2CLVD")
Private cMV_XE2ITEM := GetMv("MV_XE2ITEM")       
Private cMV_XSERINS := GetMv("MV_XSERINS")       
Private cMV_FORINSS := LEFT(GetMV("MV_FORINSS")+SPACE(10),TamSX3("E2_FORNECE")[1])
Private cMV_LOJINSS := STRZERO(0,TamSX3("E2_LOJA")[1])     
Private aLogErr     := {}
Private aLogErr2    := {}
Private aRegErr     := {}   

Private cNumAGL     := ""    
Private aDados      := {}
Private oDlg1MKB                   
Private oMark   
Private oPanel     
Private bOk1
Private bOk2
Private bOk3        
Private oFnt      
Private cxBMP     := ""    
Private lMsErroAuto := .F. 

//Início - Thais Paiva - 11586347
//dbSelectArea("SX3")
//SX3->(DbSetOrder(2))
For nX := 1 to Len(aFields)
    //If SX3->(DbSeek(aFields[nX]))
	   /*aAdd(apHeaderEx,{aTitulo[nX],;
                      SX3->X3_CAMPO,;
                      SX3->X3_PICTURE,;
                      If(SX3->X3_TIPO="D",10,SX3->X3_TAMANHO),;
                      SX3->X3_DECIMAL,;
                      SX3->X3_VALID,;
                      SX3->X3_USADO,;
                      SX3->X3_TIPO,;
                      SX3->X3_F3,;
                      SX3->X3_CONTEXT,;
                      SX3->X3_CBOX,;
                      SX3->X3_RELACAO})*/
   aAdd(apHeaderEx,{aTitulo[nX],;
                     GetSx3Cache(aFields[nX], 'X3_CAMPO'),;
                     GetSx3Cache(aFields[nX], 'X3_PICTURE'),;
                     If(GetSx3Cache(aFields[nX], 'X3_TIPO')="D",10,GetSx3Cache(aFields[nX], 'X3_TAMANHO')),;
                     GetSx3Cache(aFields[nX], 'X3_DECIMAL'),;
                     GetSx3Cache(aFields[nX], 'X3_VALID'),;
                     GetSx3Cache(aFields[nX], 'X3_USADO'),;
                     GetSx3Cache(aFields[nX], 'X3_TIPO'),;
                     GetSx3Cache(aFields[nX], 'X3_F3'),;
                     GetSx3Cache(aFields[nX], 'X3_CONTEXT'),;
                     GetSx3Cache(aFields[nX], 'X3_CBOX'),;
                     GetSx3Cache(aFields[nX], 'X3_RELACAO')})
    //Endif
    //Fim - Thais Paiva - 11586347
Next nX

If VALTYPE(cMV_INSS) = "L"
   If !cMV_INSS
     cMV_INSS := ""
   Endif  
Endif     
If VALTYPE(cMV_XINSS) = "L"
   If !cMV_XINSS
       cMV_XINSS := ALLTRIM(cMV_INSS)
   Endif  
Endif     
If ALLTRIM(cMV_INSS) = ""
   MsgStop("Não existe o parâmetro Padrão MV_INSS, favor corrigir","Erro")
   Return
Endif 

if Empty(cmv_xinss)
   cmv_xinss := STRTRAN(cMV_INSS,",","")
Endif

cMV_INSS := STRTRAN(cMV_INSS,",","")
cmv_xinss := STRTRAN(cMV_xINSS,",","")
cmv_xinss := STRTRAN(cMV_xINSS,"'","")

If !Pergunte(cPerg)
 Return
Endif  

If ALLTRIM(MV_PAR07) = ""
   MsgStop("Filial de destino não informada","Erro") 
   Return
Endif   
If EMPTY(MV_PAR09) .OR.  MV_PAR09 < dDataBase
   MsgStop("Data de Vencimento inválida","Erro") 
   Return
Endif 
cxBMP := "OK"

aadd(axButtons,{'DBG05'   ,{|| U_AGL_FSELEC(13)},'Alterar','Alterar'})   

bOk1 := {|| nOpca := 1,oDlg1MKB:End()}
bOk2 := {|| nOpca := 2,U_AGL_FSELEC(1)}  //Salvar/Confirmar
bOk3 := {|| U_AGL_FSELEC(2)} //Selecionar Registro posicionado

aXCores := {} 

MsgRun("Selecionando registros, Aguarde...","",{|| CursorWait(), fMontaE2(1) ,CursorArrow()}) 
Return

//=============================================================================================================================
Static Function fMontaE2(p_Par)
//=============================================================================================================================
Local aCampos     := {}  
Local astru       :={}
Local nX          := 0    
Local cFilPai     := ""
Local cPrfPai     := ""
Local cNumPai     := ""
Local cPrcPai     := "" 
Local cTipPai     := ""
Local cFornPai    := ""
Local cLojPai       := ""
Local _cXINSS := STRTRAN(cMV_XINSS,'"','') //Thais Paiva - 11586347

aAdd(astru,{"E2_OK","C",2,0})
aadd(aCampos,{"E2_OK","",""})

//dbSelectArea("SX3") Thais Paiva - 11586347
//SX3->(DbSetOrder(2)) Thais Paiva - 11586347
For nX := 1 to Len(apHeaderEx)
    aAdd(astru,{apHeaderEx[nX,2],apHeaderEx[nX,8],apHeaderEx[nX,4],apHeaderEx[nX,5]})  
     aadd(aCampos,{apHeaderEx[nX,2],"",AllTrim(aTitulo[nX]),apHeaderEx[nX,3]})            
Next nX
aAdd(astru,{"E2_RECNO","N",15,0})
     aadd(aCampos,{"E2_RECNO","","Recno","E@ 999999999999999"})  
If select("TRB") > 0
   dbSelectArea("TRB") 
   dbCloseArea("TRB") 
Endif
//Início - Thais Paiva - 11586347
//cArq:="T_"+Criatrab(,.F.)
//MsCreate(cArq,astru,"DBFCDX") 
//dbUseArea(.T.,"DBFCDX",cArq,"TRB",.T.,.F.)
oTempTable := FWTemporaryTable():New( "TRB" )
oTemptable:SetFields( astru )
oTempTable:AddIndex("01", {"E2_RECNO"} )
oTempTable:Create()


If select("RS_SEX") > 0
   dbSelectArea("RS_SEX") 
   dbCloseArea("RS_SEX") 
Endif

cQuery := " SELECT E2.R_E_C_N_O_ E2_RECNO,E2_EMISSAO,E2_VENCTO,E2_VENCREA,E2_FILIAL,E2_FILORIG,E2_NATUREZ,E2_CODINS,E2_FORNECE,"
cQuery += " E2_LOJA,E2_NOMFOR,E2_NUM,E2_TIPO,E2_PREFIXO,E2_PARCELA,A2_NOME,A2_CGC,E2_HIST,E2_VALOR,E2_XVJUROS,E2_XVMULTA,E2_TITPAI,E2_BASEINS"
cQuery += " FROM "+RetSqlName("SE2")+" E2, "+RetSqlName("SA2")+" A2" 
cQuery += " WHERE A2_FILIAL = '"+XFILIAL("SA2")+"'"
cQuery += " AND E2_PREFIXO <> 'AGI'"  
cQuery += " AND E2_TIPO = 'INS'"
cQuery += " AND E2_FORNECE IN ('"+cMV_FORINSS+"','INPS','UNIAO')"
cQuery += " AND A2_COD = E2_FORNECE"
cQuery += " AND A2_LOJA = E2_LOJA"                    
cQuery += " AND E2_XNUMAGL = ' '" 
cQuery += " AND E2_TITPAI <> ' '"
cQuery += " AND E2_SALDO > 0 "
cQuery += " AND E2_BAIXA = ' '"    
//cQuery += " AND E2_NATUREZ IN ('"+(ALLTRIM(cMV_XINSS))+"')" 
cQuery += " AND E2_NATUREZ IN ('"+(ALLTRIM(_cXINSS))+"')"
cQuery += " AND E2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"       
cQuery += " AND E2_EMIS1   BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"'" 
cQuery += " AND E2_FILORIG BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'" 
cQuery += " AND E2.D_E_L_E_T_ = ' '"
cQuery += " AND A2.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY E2_EMISSAO,E2_CODINS,E2_FILORIG,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO"
//Fim - Thais Paiva - 11586347

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "RS_SEX", .F., .T.)  		
dbSelectArea("RS_SEX") 
RS_SEX->(DbGoTop())
While RS_SEX->(!Eof()) 
      RECLOCK("TRB",.T.) 		
      For nX := 1 to LEN(apHeaderEx) 
          If LEFT(apHeaderEx[nX,2],2) = "E2" 
             If apHeaderEx[nX,8] = "D"   
                TRB->&(apHeaderEx[nX,2]) := STOD(RS_SEX->&(apHeaderEx[nX,2]))
             Endif   
             If apHeaderEx[nX,8] = "N"   
                TRB->&(apHeaderEx[nX,2]) := RS_SEX->&(apHeaderEx[nX,2])    
                nValor += RS_SEX->&(apHeaderEx[nX,2])
             Endif      
             If apHeaderEx[nX,8] = "C"   
                TRB->&(apHeaderEx[nX,2]) := RS_SEX->&(apHeaderEx[nX,2])
             Endif                 
          Endif
      Next nX              
         cPrfPai   := SUBSTR(RS_SEX->E2_TITPAI,1,TamSX3("E2_PREFIXO")[1])
         cNumPai   := SUBSTR(RS_SEX->E2_TITPAI,TamSX3("E2_PREFIXO")[1]+1,TamSX3("E2_NUM")[1])
         cPrcPai   := SUBSTR(RS_SEX->E2_TITPAI,TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+1,TamSX3("E2_PARCELA")[1])
         cTipPai   := SUBSTR(RS_SEX->E2_TITPAI,TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+1,TamSX3("E2_TIPO")[1])
         cFornPai  := SUBSTR(RS_SEX->E2_TITPAI,TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+TamSX3("E2_TIPO")[1]+1,TamSX3("E2_FORNECE")[1])
         cLojPai   := SUBSTR(RS_SEX->E2_TITPAI,TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+TamSX3("E2_TIPO")[1]+TamSX3("E2_FORNECE")[1]+1,TamSX3("E2_LOJA")[1])        

      dbSelectArea("SA2")
      SA2->(DBSETORDER(1))	
      SA2->(DbSeek(xfilial("SA2")+cFornPai+cLojPai))
      For nX := 1 to LEN(apHeaderEx) 
          If LEFT(apHeaderEx[nX,2],2) = "A2" 
             If apHeaderEx[nX,8] = "D"   
                TRB->&(apHeaderEx[nX,2]) := STOD(SA2->&(apHeaderEx[nX,2]))
             Endif   
             If apHeaderEx[nX,8] = "N"   
                TRB->&(apHeaderEx[nX,2]) := SA2->&(apHeaderEx[nX,2])    
                nValor += RS_SEX->&(apHeaderEx[nX,2])
             Endif      
             If apHeaderEx[nX,8] = "C"   
                TRB->&(apHeaderEx[nX,2]) := SA2->&(apHeaderEx[nX,2])
             Endif                 
          Endif   
      Next nX    
      TRB->E1_NUM     := cNumPai
      TRB->E1_TIPO    := cTipPai
      TRB->E1_CLIENTE := cFornPai
      TRB->E1_LOJA    := cLojPai
      TRB->E2_RECNO   := RS_SEX->E2_RECNO
      TRB->(MSUNLOCK())    
      RS_SEX->(DbSkip())       
Enddo            		              
                        
DEFINE MSDIALOG oDlg1MKB TITLE "Aglutinação de Títulos INSS a Pagar" From aSize[1],aSize[2] To aSize[3],aSize[4] OF oMainWnd PIXEL 
       oDlg1MKB:lMaximized := .T.    
 	   oMark := MsSelect():New("TRB","E2_OK","",aCampos,@lInverte,@cMark,{40,oDlg1MKB:nLeft+1,oDlg1MKB:nBottom-335,oDlg1MKB:nRight-660},,,,,,)       
	   oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT // Somente Interface MDI
       oMark:oBrowse:lHasMark := .T.
       oMark:oBrowse:lCanAllMark:=.T.
	   oMark:bMark := {|| U_AGL_FSELEC(3)}
	   oMark:bAval	:= {|| U_AGL_FSELEC(4)} //Marcar/Desmarcar 
	   oMark:oBrowse:lhasMark = .t.
	   oMark:oBrowse:lCanAllmark := .t.
	   oMark:oBrowse:bAllMark := { || U_AGL_FSELEC(5) } //Marcar/Desmarcar Todos
	   oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT	
       dbSelectArea("TRB")
       TRB->(dbGoTop())
       oMark:oBrowse:Refresh()
ACTIVATE MSDIALOG oDlg1MKB ON INIT (EnchoiceBar(oDlg1MKB,{||(Eval(bOk2),If(lVldAd,Eval(bOk1),Eval(bOk3)))},{||nOpca := 1,oDlg1MKB:End()},,axButtons)) CENTER

oTempTable:Delete() //Thais Paiva - 11586347

Return 

//============================================================================================================================= 
User Function AGL_FSELEC(p_Par)   // Função para gravar marca no campo se não esti  
//============================================================================================================================= 
Local nxPar     := p_Par
Local aPar      := {"Salvar/Confirmar","Marcar","","Marcar/Desmarcar","Marcar/Desmarcar Todos","","","","",""}
Local nX        := 0
Local cCodINSS  := ""
Local nX        := 0                   
Local aTitRel   := {}
Local aCabec    := {}
Local aPlanilha := {}
Local  apColsEx := {}

If nxPar = 1 //"Salvar/Confirmar"   
   //If ApMsgYesNo("Confirma a Aglutinação dos Títulos?")
      Processa({|lEnd| fGerar(@lEnd)}, "Aguarde...", "Gerando os Títulos Aglutinadores...", .T.)
      oDlg1MKB:End()
      Return
Endif

If nxPar = 2 //"Atualizar"   
   dbSelectArea("TRB")
   TRB->(DbGotop())
Endif

If nxPar = 4 //Marcar/Desmarcar 
   If RecLock( 'TRB', .F. )   
      If TRB->E2_OK = cMark	
         TRB->E2_OK := SPACE(02)		
      Else                            
         TRB->E2_OK := cMark	
      Endif    
      TRB->(MsUnLock())	
   Endif   
EndIf   

If nxPar = 5 //"Marcar/Desmarcar Todos"   
   dbSelectArea("TRB")
TRB->(DbGotop())
   While !Eof()	   
         If RecLock( 'TRB', .F. )   
            TRB->E2_OK := If(lMark,cMark,SPACE(02))		   
            TRB->(MsUnLock())	
         Endif
         TRB->(dbSkip())
   Enddo 
   lMark := If(lMark,.F.,.T.)
EndIf

If nxPar = 13 //Alterar E2_CODINS    
   cCodINSS := U_EXT_CDRET(TRB->E2_NUM,TRB->E2_CODINS)    
   If RecLock( 'TRB',.F.)          	
      TRB->E2_OK     := cMark
      TRB->E2_CODINS := cCodINSS
      TRB->(MsUnLock())	
   Endif                       
   dbSelectArea("SE2")
   SE2->( dbGoTo(TRB->E2_RECNO)) 
   RecLock( "SE2",.F.)  
   SE2->E2_CODINS := cCodINSS
    SE2->(MsUnLock())      
EndIf 

If nxPar = 14 //Relatório
   apColsEx := {}
   dbSelectArea("TRB")
TRB->(DbGotop())
   While !Eof()	   
      aAdd(apColsEx, {})  
      For nX := 1 to LEN(apHeaderEx)
          aAdd(apColsEx[Len(apColsEx)],TRB->&(apHeaderEx[nX,2]))
      Next nX
      aAdd(apColsEx[Len(apColsEx)],.F.)                            
      TRB->(dbSkip())            
   Enddo      
   aTitRel := {}
   aAdd(aTitRel,{"Aglutinação de Titulos a Pagar de INSS"})   
   aAdd(aTitRel,{""})     
   aAdd(aTitRel,{"Referência [ "+DTOC(MV_PAR01)+" á "+DTOC(MV_PAR02)+" ]"})   
   nX := 1     
   U_ETX_RELT(1,"AGL_AGLU","Aglutinação de Titulos a Pagar de INSS","SE2",aTitRel,apHeaderEx,apColsEx,nX,"EXPRELT","E2_TITPAI") 
   oDlg1MKB:End()
   Return
EndIf 

If nxPar = 15 //Excel
   apColsEx := {}
   dbSelectArea("TRB")
   TRB->(DbGotop())
   While !Eof()	   
      aAdd(apColsEx, {})  
      For nX := 1 to LEN(apHeaderEx) 
          aAdd(apColsEx[Len(apColsEx)],TRB->&(apHeaderEx[nX,2]))
      Next nX
      aAdd(apColsEx[Len(apColsEx)],.F.)                            
      TRB->(dbSkip())
   Enddo      
   aPlanilha := {}
   aAdd(aCabec,apHeaderEx)   //acolsex     
   aAdd(aPlanilha,{aCabec,apColsEx,"Aglutinação de Titulos a Pagar de INSS","Aglutinação de Titulos a Pagar de INSS emitido em: ["+DTOC(dDataBase)+"] Período: [ "+DTOC(MV_PAR01)+" á "+DTOC(MV_PAR02)+" ]","1"})
   ExecBlock("AGL_EXCEL",.F.,.F.,{Len(apHeaderEx),"Aglutinação de Titulos a Pagar de INSS",aPlanilha})  
   oDlg1MKB:End()
   Return                        
EndIf 

dbSelectArea("TRB")
If p_Par <> 13 .AND. p_Par <> 4
   TRB->(dbGoTop())
Endif
oMark:oBrowse:Refresh() 
Return

//=============================================================================================================================
Static Function fGerar()   
//=============================================================================================================================  
Local nX        := 0    
Local nLoop     := 0   
Local nVezes     := 0   
Local fExec     := .F.
Local cNumSE2   := ""  
Local nValor    := 0
Local nBaseCalc := 0
Local nxVJuros  := 0
Local nXVMulta  := 0
Local cMesAno1  := "" 
Local cMesAno2  := ""
Local cCodRet   := "" 
Local aCabec    := {}
Local aDados    := {}       
Local aLinha    := {}  
Local aTRB      := {}  
Local lWhile    := .T.
Local dDEmis1   :=  dDataBase
Local dDEmis2   :=  dDataBase
Local cCodRet   :=  ""
Local aAglut      := {}
Local nCount      := 0
Local nVezes      := 0 
Local nPProduto	  := 0   
Local nSE2        := 0
Local cFilBkp     := "" 

aTRB := {}
dbSelectArea("TRB")
TRB->(DbGotop())
While !Eof() 
      RecLock( 'TRB', .F. )   
      If TRB->E2_OK = cMark    
         //TRB->E2_CODINS := If(ALLTRIM(TRB->E2_CODINS)="",MV_PAR08,TRB->E2_CODINS)      
         TRB->E2_CODINS := MV_PAR08
      Else   
         TRB->(DbDelete())
      Endif    
      TRB->(Msunlock())
      TRB->(dbSkip())
Enddo 

dbSelectArea("TRB")
TRB->(DbGotop())
While !Eof() 
      aLinha := {}	   
      dDEmis1 :=  FirstDate(TRB->E2_EMISSAO)
      dDEmis2 :=  LastDate(TRB->E2_EMISSAO)   
      nPProduto := aScan(aTRB,{|x| DTOS(x[3])+DTOS(x[4])+ALLTRIM(x[5])==DTOS(dDEmis1)+DTOS(dDEmis2)+ALLTRIM(TRB->E2_CODINS)})  
      If nPProduto = 0 
         aLinha := {MV_PAR07,"",dDEmis1,dDEmis2,TRB->E2_CODINS,TRB->E2_VALOR,TRB->E2_BASEINS,TRB->E2_XVJUROS,TRB->E2_XVMULTA}          
         aAdd(aTRB,aLinha)
      Else  
         aTRB[nPProduto,6] += TRB->E2_VALOR
         aTRB[nPProduto,7] += TRB->E2_BASEINS            
         aTRB[nPProduto,8] += TRB->E2_XVJUROS 
         aTRB[nPProduto,9] += TRB->E2_XVMULTA                         
      Endif   
      TRB->(dbSkip())
Enddo 
TRB->(dbGoTop())
oMark:oBrowse:Refresh() 
For nVezes := 1 to LEN(aTRB)
    dDEmis1   := aTRB[nVezes,3]
    dDEmis2   := aTRB[nVezes,4]
    cCodRet   := aTRB[nVezes,5]
    nValor    := aTRB[nVezes,6]     
    nBaseCalc := aTRB[nVezes,7]  
    nxVJuros  := aTRB[nVezes,8]  
    nXVMulta  := aTRB[nVezes,9]         
    aDados := {}  
    BEGIN TRANSACTION
	cFilBkp     := cFilAnt
	cFilAnt := MV_PAR07
	cNumAGL   := ProcCodigo()           
	/*         For nLoop := 1 to 10000 // aqui
	/*            dbSelectArea("SE2")
	SE2->(DBSETORDER(1)) 
	MsSeek("SE2")	 
	SE2->(dbGoTop()) 
	If SE2->(dbSeek(MV_PAR07+"AGI"+SUBSTR(cNumAGL,3,9)+LEFT("1"+SPACE(5),TamSX3("E2_PARCELA")[1])+"INS"+cMV_FORINSS+cMV_LOJINSS))
	// cNumAGL := SPACE(TamSX3("E2_XNUMAGL")[1])
	cNumAGL := Val(cNumAGL)+1
	cNumAGL := Strzero(cNumAGL,TamSX3("E2_XNUMAGL")[1])
	Else   
	nLoop := 10000
	Endif
	Next nLoop    */    
	//         cNumAGL := SUBSTR(cNumAGL,3,9)
	aTRB[nVezes,2] := cNumAGL   
	dbSelectArea("SA2")
	SA2->(DBSETORDER(1))	
	SA2->(DbSeek(xfilial("SA2")+cMV_FORINSS+cMV_LOJINSS))

	aDados := {}   
	RegToMemory("SE2")
	IncProc("Fornecedor:"+AllTrim(TRB->E2_NOMFOR)+" ,Aglutinador = "+cNumAGL)    
	aAdd(aDados,{"E2_FILIAL" ,MV_PAR07                ,Nil}) 
	aAdd(aDados,{"E2_FILORIG",MV_PAR07                ,Nil})
	aAdd(aDados,{"E2_NUM"    ,cNumAgl                 ,Nil})      
	aAdd(aDados,{"E2_PREFIXO","AGI"                   ,Nil})
	aAdd(aDados,{"E2_PARCELA",LEFT("1"+SPACE(5),TamSX3("E2_PARCELA")[1]),Nil})
	aAdd(aDados,{"E2_TIPO"   ,"INS"                    ,Nil})
	aAdd(aDados,{"E2_FORNECE",cMV_FORINSS              ,Nil})
	aAdd(aDados,{"E2_LOJA   ",cMV_LOJINSS              ,Nil})
	aAdd(aDados,{"E2_NOMFOR ",SA2->A2_NREDUZ           ,Nil})          
	aAdd(aDados,{"E2_XSERIE ",cMV_XSERINS             ,Nil})            
	aAdd(aDados,{"E2_EMISSAO",ddatabase                ,Nil})
	aAdd(aDados,{"E2_VENCTO" ,MV_PAR09                 ,Nil})        
	aAdd(aDados,{"E2_VENCORI",MV_PAR09                 ,Nil})           
	aAdd(aDados,{"E2_VENCREA",datavalida(MV_PAR09,.T.) ,Nil})              
	aAdd(aDados,{"E2_VALOR"  ,nValor                   ,Nil})
	aAdd(aDados,{"E2_SALDO"  ,nValor                   ,Nil})          
	aAdd(aDados,{"E2_VLCRUZ" ,nValor                   ,Nil})            
	aAdd(aDados,{"E2_BASEINS",nBaseCalc                ,Nil})                       
	aAdd(aDados,{"E2_XVJUROS",nXVJuros                 ,Nil}) 
	aAdd(aDados,{"E2_XVMULTA",nXVMulta                 ,Nil})                     
	aAdd(aDados,{"E2_MOEDA"  ,1                        ,Nil})          
	aAdd(aDados,{"E2_EMIS1"  ,ddatabase                ,Nil})          
	aAdd(aDados,{"E2_HIST"   ,"Título Aglutinador INSS",Nil})
	aAdd(aDados,{"E2_NATUREZ",&(cMV_INSS)              ,Nil})  
	aAdd(aDados,{"E2_CCD"    ,cMV_XE2CCD               ,Nil})
	aAdd(aDados,{"E2_ITEMD"  ,cMV_XE2ITEM              ,Nil})
	aAdd(aDados,{"E2_CLVLDB" ,cMV_XE2CLVD              ,Nil})   
	aAdd(aDados,{"E2_ORIGEM" ,"FINA050"                ,Nil})  
	aAdd(aDados,{"E2_NUMTIT" ,"AGL_BRWS"               ,Nil})            
	aAdd(aDados,{"E2_CODINS" ,aTRB[nVezes,5]           ,Nil})           
	lMsErroAuto := .F.
	MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aDados,, 3)    
	If lMsErroAuto  
		If (!IsBlind())
			MostraErro()
		EndIf  
		aLogErr  := GetAutoGRLog()
		aLogErr2 := ZRetLog( aLogErr, "" )
		DisarmTransaction()             
		//Return Início - Thais Paiva - 11586347
		lRet := .F.
	Else
		lRet := .T.
	Endif  
	If lRet //Fim - Thais Paiva - 11586347
		TRB->(dbGoTop())          
		While TRB->(!Eof()) //Thais Paiva - 11586347
			//RecLock("TRB",.F.) Thais Paiva - 11586347
			If TRB->E2_OK = cMark .AND. ALLTRIM(TRB->E2_FORNECE) = ALLTRIM(cMV_FORINSS) .AND. ALLTRIM(TRB->E2_LOJA) = ALLTRIM(cMV_LOJINSS) .AND. ALLTRIM(TRB->E2_CODINS) = ALLTRIM(cCodRet) .AND. DTOS(TRB->E2_EMISSAO) >= DTOS(dDEmis1) .AND. DTOS(TRB->E2_EMISSAO) <= DTOS(dDEmis2)
				dbSelectArea("SE2")
				SE2->(dbSetOrder(1))
				If SE2->(DbSeek(TRB->E2_FILIAL+TRB->E2_PREFIXO+TRB->E2_NUM+TRB->E2_PARCELA+TRB->E2_TIPO+TRB->E2_FORNECE+TRB->E2_LOJA))  
					RecLock("SE2",.F.)    
					SE2->E2_XNUMAGL := MV_PAR07+cNumAGL
					SE2->E2_BAIXA   := dDATABASE
					SE2->E2_VALLIQ  := 0
					SE2->E2_SALDO   := 0                                                                           
					SE2->(MsUnlock()) 
					dbSelectArea("SA2")   
					SA2->(dbSetorder(1))  
					If SA2->(dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))  
						RecLock("SA2",.F.)
						SA2->A2_SALDUP := SA2->A2_SALDUP - SE2->E2_VALOR 
						SA2->(MsUnlock())                  
					Endif    
					SA2->(DbCloseArea())  //Thais Paiva - 11586347                                        
				Endif   
				SE2->(DbCloseArea())    //Thais Paiva - 11586347               
				//TRB->(DbDelete()) Thais Paiva - 11586347    
				//TRB->(Msunlock()) Thais Paiva - 11586347
			Endif 
			TRB->(dbSkip())
		Enddo                    
		aLinha := {MV_PAR07,cNumAGL,dDEmis1,dDEmis2,aTRB[nVezes,5],nValor,nBaseCalc}   
		aAdd(aAglut,aLinha)           
		cFilAnt := cFilBkp
	EndIf //Thais Paiva - 11586347
    END TRANSACTION 
Next nVezes

//Início - Thais Paiva - 11586347    
TRB->(dbGoTop())
While TRB->(!Eof())
	RecLock("TRB",.F.) 	   
	If TRB->E2_OK = cMark .AND. ALLTRIM(TRB->E2_FORNECE) = ALLTRIM(cMV_FORINSS) .AND. ALLTRIM(TRB->E2_LOJA) = ALLTRIM(cMV_LOJINSS) .AND. ALLTRIM(TRB->E2_CODINS) = ALLTRIM(cCodRet) .AND. DTOS(TRB->E2_EMISSAO) >= DTOS(dDEmis1) .AND. DTOS(TRB->E2_EMISSAO) <= DTOS(dDEmis2)
		TRB->(DbDelete()) 
	EndIf
	TRB->(Msunlock())   
	TRB->(dbSkip())
Enddo     
//Fim - Thais Paiva - 11586347    	
			
If Len(aAglut) > 0 
   U_ETX_RELAT(2,aAglut)
Else    
  MsgStop("Nenhum Título Aglutinador foi gerado","Erro") 
Endif
Return

//====================================================================================
Static Function ZRetLog(aErr,cLit)
//====================================================================================
lHelp   := .F.
lTabela := .F.
cLinha  := ""
aRet    := {}
nI      := 0

For nI := 1 to LEN(aErr)
	cLinha  := UPPER( aErr[nI] )
	cLinha  := STRTRAN( cLinha,CHR(13), " " )
	cLinha  := STRTRAN( cLinha,CHR(10), " " )	
	If SUBS(cLinha, 1, 4 ) == 'HELP'
		lHelp := .T.
	EndIf	
	If SUBS( cLinha, 1, 6 ) == 'TABELA'
		lHelp   := .F.
		lTabela := .T.
	EndIf	
	If  lHelp .or. ( lTabela .AND. '< -- INVALIDO' $  cLinha )
		aAdd( aRet,  cLinha )
	EndIf	
Next
Return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ProcCodigo    º Autor ³THIAGO PEREIRA     º Data ³03/04/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Busca Proximo Codigo Cliente                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcCodigo(pFILORI)

LOCAL cCodigo

c_query := " SELECT MAX(E2_NUM) AS UCOD FROM "+RetSqlname("SE2") 
c_Query += " WHERE D_E_L_E_T_ = ' '  and E2_PREFIXO = 'AGI' "
if !empty(pFILORI)
   c_query += " AND E2_FILIAL = '" +alltrim(pfilori) + "' " 
Endif


TCQUERY c_Query ALIAS "TRC" NEW
	
dbselectarea("TRC")
If ! Empty(TRC->UCOD)
	cCodigo := TRC->UCOD
Else
	cCodigo := "000000001"
Endif

TRC->(DbClosearea())

nCodigo := Val(cCodigo)+1
cCodigo := Strzero(nCodigo,TamSX3("E2_NUM")[1])

Return(cCodigo)          

