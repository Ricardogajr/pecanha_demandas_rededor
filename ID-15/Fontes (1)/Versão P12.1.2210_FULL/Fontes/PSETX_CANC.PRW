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
//Programa............: ETX_CANC()
//Autor...............: THIAGO PEREIRA
//Data................: 07*03/2021
//Descricao / Objetivo: Aglutinação de Títulos - Estorno  
//=============================================================================================================================

User Function ETX_CANC()
//=============================================================================================================================

Local lPanelFin     := If (FindFunction("IsPanelFin"),IsPanelFin(),.F.)     
Local lOK           := .F.
Local nX
Private aButtons    := {}
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
Private cCadastro   := OEMTOANSI("Estorno de Títulos a Pagar (INSS)")
Private cMark       := GetMark()
Private cArq        := "" 
Private aSays       := {}        
Private aBotoes     := {}   
Private aXCores     := {}
Private cPerg       := "AGLRELT"  
Private aCabec      := {}  
Private aDados      := {}  
Private afields     := {"E2_EMISSAO","E2_VENCTO","E2_VENCREA"  ,"E2_FILIAL","E2_FILORIG","E2_NUM" ,"E2_TIPO","E2_PREFIXO","E2_PARCELA","E2_NATUREZ","E2_CODINS","E2_VALOR","E2_FORNECE","E2_LOJA","E2_NOMFOR","E2_HIST"} 
Private aTitulo     := {"Dt Emissão","Dt Vencto","Dt Vct Real" ,"Filial"   ,"Fil Orig"  ,"Num Tit","Tipo"   ,"Pref"      ,"Parc"      ,"Nat Financ","Cod Ret"  ,"Vr Titulo","Fornece"   ,"Loja"   ,"NomFor"  ,"Histórico"} 
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
Private cMV_FORINSS := LEFT(GetMV("MV_FORINSS")+SPACE(10),TamSX3("E2_FORNECE")[1])
Private cMV_LOJINSS := STRZERO(0,TamSX3("E2_LOJA")[1])     
Private aLogErr     := {}
Private aLogErr2    := {}
Private aRegErr     := {}   

Private cNumAGL     := ""    
Private aDados      := {}
Private oDlgCanc                   
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

/*
cMV_XINSS := Replace(cMV_XINSS,'"','')   
cMV_XINSS := REPLACE(REPLACE(ALLTRIM(cMV_INSS)+"|"+ALLTRIM(cMV_XINSS),'"',''),',','|')+"|"
*/

If !Pergunte(cPerg)
   Return
Endif  

bOk1 := {|| nOpca := 1,oDlgCanc:End()}
bOk2 := {|| nOpca := 2,U_AGL_FCSELEC(1)}  //Salvar/Confirmar
bOk3 := {|| U_AGL_FCSELEC(2)} //Selecionar Registro posicionado

aXCores := {} 

MsgRun("Selecionando registros, Aguarde...","",{|| CursorWait(), fMontaE2(1) ,CursorArrow()}) 
Return

//=============================================================================================================================
Static Function fMontaE2(p_Par)
//=============================================================================================================================
Local aCampos     := {}  
Local astru       :={}
Local nX          := 0    

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
//Fim - Thais Paiva - 11586347

If select("RS_SEX") > 0
   dbSelectArea("RS_SEX") 
   dbCloseArea("RS_SEX") 
Endif
cQuery := " SELECT R_E_C_N_O_ E2_RECNO,E2_EMISSAO,E2_VENCTO,E2_VENCREA,E2_FILIAL,E2_FILORIG,E2_NATUREZ,E2_CODINS,E2_FORNECE,E2_LOJA,E2_NOMFOR,E2_NUM,E2_TIPO,E2_PREFIXO,E2_PARCELA,E2_HIST,E2_VALOR"
cQuery += " FROM "+RetSqlName("SE2")
cQuery += " WHERE D_E_L_E_T_ = ' '"
cQuery += " AND E2_XNUMAGL = ' '"
cQuery += " AND E2_PREFIXO = 'AGI'"   
cQuery += " AND E2_TIPO = 'INS'"
cQuery += " AND E2_SALDO > 0 "
cQuery += " AND E2_BAIXA = ' '"    
cQuery += " AND E2_FORNECE IN ('"+cMV_FORINSS+"','INPS','UNIAO')"
//cQuery += " AND E2_NATUREZ IN ('" + ALLTRIM(cMV_XINSS)+"')"
cQuery += " AND E2_NATUREZ = '"+Replace(cMV_XINSS,'"','')+"'"
cQuery += " AND E2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"   
if !Empty(MV_PAR03) .AND. !Empty(MV_PAR04)
   cQuery += " AND E2_EMIS1   BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"'" 
ELSEIF Empty(MV_PAR03) .AND. !Empty(MV_PAR04)
   cQuery += " AND E2_EMIS1   <=  '" + DTOS(MV_PAR04)+"'" 
ELSEIF !Empty(MV_PAR03) .AND. Empty(MV_PAR04)
   cQuery += " AND E2_EMIS1   >=  '" + DTOS(MV_PAR03)+"'" 
EndIf
cQuery += " AND E2_FILORIG BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'" 
cQuery += " ORDER BY E2_EMISSAO,E2_CODRET,E2_FILORIG,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO"
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "RS_SEX", .F., .T.)  		
dbSelectArea("RS_SEX") 
RS_SEX->(DbGoTop())
While RS_SEX->(!Eof()) 
      RECLOCK("TRB",.T.) 		
      For nX := 1 to LEN(apHeaderEx) 
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
      Next nX    
      TRB->E2_RECNO   := RS_SEX->E2_RECNO
      TRB->(MSUNLOCK())    
      RS_SEX->(DbSkip())       
Enddo            		              
                        
DEFINE MSDIALOG oDlgCanc TITLE "Estorno de Títulos a Pagar (INSS)" From aSize[1],aSize[2] To aSize[3],aSize[4] OF oMainWnd PIXEL 
       oDlgCanc:lMaximized := .T.    

 	   oMark := MsSelect():New("TRB","E2_OK","",aCampos,@lInverte,@cMark,{40,oDlgCanc:nLeft+1,oDlgCanc:nBottom-335,oDlgCanc:nRight-660},,,,,,)       
	   oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT // Somente Interface MDI
       oMark:oBrowse:lHasMark := .T.
       oMark:oBrowse:lCanAllMark:=.T.
	   oMark:bMark := {|| U_AGL_FCSELEC(3)}
	   oMark:bAval	:= {|| U_AGL_FCSELEC(4)} //Marcar/Desmarcar 
	   oMark:oBrowse:lhasMark = .t.
	   oMark:oBrowse:lCanAllmark := .t.
	   oMark:oBrowse:bAllMark := { || U_AGL_FCSELEC(5) } //Marcar/Desmarcar Todos
	   oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT	
       dbSelectArea("TRB")
       TRB->(dbGoTop())
       oMark:oBrowse:Refresh()

ACTIVATE MSDIALOG oDlgCanc ON INIT (EnchoiceBar(oDlgCanc,{||(Eval(bOk2),If(lVldAd,Eval(bOk1),Eval(bOk3)))},{||nOpca := 1,oDlgCanc:End()},,aButtons)) CENTER

oTempTable:Delete() //Thais Paiva - 11586347
Return 

//============================================================================================================================= 
User Function AGL_FCSELEC(p_Par)   // Função para gravar marca no campo se não estiver  AGL_FCSELEC(4)
//============================================================================================================================= 

Local aPar      := {"Salvar/Confirmar","Marcar","","Marcar/Desmarcar","Marcar/Desmarcar Todos","","","","",""}
Local nX        := 0
Local aCodRet   := {}
Local nX        := 0                   
Local aTitRel   := {}
Local aCabec    := {}
Local aPlanilha := {}
Local  apColsEx := {}

If p_Par = 5 //"Marcar/Desmarcar Todos"   
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

If p_Par = 4 //Marcar/Desmarcar 
   If RecLock( 'TRB', .F. )   
      If TRB->E2_OK = cMark	
         TRB->E2_OK := SPACE(02)		
      Else                            
         TRB->E2_OK := cMark	
      Endif    
      TRB->(MsUnLock())	
   Endif   
EndIf   
dbSelectArea("TRB")
If p_Par <> 13 .AND. p_Par <> 4
   TRB->(dbGoTop())
Endif
oMark:oBrowse:Refresh() 
If p_Par = 1 //"Salvar/Confirmar"   
   If !MsgYesNo("Confirma o Estorno de Títulos Aglutinadores de INSS?")
      Return
   Endif 
   Processa({|lEnd| fEstornar(@lEnd)}, "Aguarde...", "Estornado os Títulos Aglutinadores...", .T.)
   Return
Endif

Return

//=============================================================================================================================
Static Function fEstornar()   
//=============================================================================================================================  
Local nX        := 0    
Local nLoop     := 0   
Local nVezes     := 0   
Local fExec     := .F.
Local cNumSE2   := ""  
Local nValor    := 0
Local nBaseCalc := 0
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
Local nPProduto   := 0   
Local nSE2        := 0    
Local cFilBkp     := 0  
Local nCanc       := 0
Local nQtde       := 0 
Local nSALDUP     := 0 //- Sld Duplict    
Local lRet := .T. //Thais Paiva - 11586347

aTRB := {}
dbSelectArea("TRB")
TRB->(DbGotop())
While !Eof() 
      RecLock( 'TRB', .F. )   
      If !(TRB->E2_OK = cMark) 
         TRB->(DbDelete())
         TRB->(Msunlock())
      Endif
      TRB->(dbSkip())
Enddo 
cFilBkp := cFilAnt 
dbSelectArea("TRB")
TRB->(DbGotop())
While TRB->(!Eof()) // Thais Paiva - 11586347
	aDados := {}        
	cFilBkp := cFilAnt 
	If TRB->E2_OK = cMark
		BEGIN TRANSACTION   
		cFilAnt := TRB->E2_FILIAL
		aDados := {}
		cFilAnt := TRB->E2_FILIAL
		RegToMemory("SE2")
		IncProc("Aglutinador = "+TRB->E2_NUM)    
		aAdd(aDados,{"E2_FILIAL" ,TRB->E2_FILIAL       ,Nil})
		aAdd(aDados,{"E2_NUM"    ,TRB->E2_NUM          ,Nil})
		aAdd(aDados,{"E2_PREFIXO",TRB->E2_PREFIXO      ,Nil})
		aAdd(aDados,{"E2_PARCELA",TRB->E2_PARCELA      ,Nil})
		aAdd(aDados,{"E2_TIPO"   ,TRB->E2_TIPO         ,Nil})
		aAdd(aDados,{"E2_FORNECE",TRB->E2_FORNECE      ,Nil})
		aAdd(aDados,{"E2_LOJA"   ,TRB->E2_LOJA         ,Nil})
		aAdd(aDados,{"E2_EMISSAO",TRB->E2_EMISSAO      ,Nil})
		aAdd(aDados,{"E2_VENCTO" ,TRB->E2_VENCTO       ,Nil})
		aAdd(aDados,{"E2_VALOR"  ,TRB->E2_VALOR        ,Nil}) 
		lMsErroAuto := .F.
		MsExecAuto({ |x,y,z| FINA050(x,y,z)},aDados,,5)   
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
				nSALDUP     := 0 //- Sld Duplict    
				for nCanc := 1 to 10000
					nqtde := 0
					dbSelectArea("SE2")
					DBSETORDER(22)
					IF SE2->(DBSEEK(TRB->E2_FILIAL+TRB->E2_NUM))
						WHILE !EOF() .AND. ;
							ALLTRIM(SE2->E2_XNUMAGL) == (TRB->E2_FILIAL+TRB->E2_NUM)
							IF ALLTRIM(SE2->E2_XNUMAGL) == (TRB->E2_FILIAL+TRB->E2_NUM)
								NQTDE += 1
								RECLOCK("SE2",.F.)
								SE2->E2_XNUMAGL := ''
								SE2->E2_BAIXA := CTOD("  /  /    ")
								SE2->E2_VALLIQ := SE2->E2_VALOR
								SE2->E2_SALDO := SE2->E2_VALOR
								SE2->(MSUNLOCK())
								DBSELECTAREA("SA2")
								DBSETORDER(1)
								IF SA2->(DBSEEK(XFILIAL("SA2")+SE2->E2_FORNECE+ SE2->E2_LOJA))
									RECLOCK("SA2",.F.)
									SA2->A2_SALDUP := SA2->A2_SALDUP + SE2->E2_VALOR
									SA2->(MSUNLOCK())
								EndIf
								SA2->(DbCloseArea()) //Thais Paiva - 11586347
							EndIf
							SE2->(DBSKIP())
						Enddo
					ELSE
						NQTDE := 0
					EndIf
					SE2->(DbCloseArea()) //Thais Paiva - 11586347
					IF NQTDE = 0
						NCANC := 10000
					EndIf
				NEXT NCANC
			Endif //Thais Paiva - 11586347

		RecLock( 'TRB', .F. )             
		TRB->(DbDelete())
		TRB->(Msunlock())          
		END TRANSACTION 
	Endif         
	cFilAnt := cFilBkp    
	TRB->(dbSkip())  
Enddo                    
Return

//====================================================================================
Static Function ZRetLog(aErr,cLit)
//====================================================================================
Local nI
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
