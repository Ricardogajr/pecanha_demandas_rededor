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
//Programa............: ETX_RELAT()
//Autor...............: THIAGO PEREIRA 
//Data................: 06/03/2020
//Descricao / Objetivo: Aglutinação de Títulos - Relatório - tela de Títulos Aglutinadores  
//=============================================================================================================================
User Function ETX_RELAT(pTipo,paAglut)   
//=============================================================================================================================                     

Local nTipo  := pTipo
Local aAglut := paAglut
Local cPerg  := "ETXRELT" 
Local oButton1
Local oButton3
Local oGroup1

Static oDlgAgl

Private oTotais
Private cMV_FORINSS := LEFT(ALLTRIM(GetMV("MV_FORINSS"))+SPACE(10),TamSX3("E2_FORNECE")[1])    
Private cMV_LOJINSS := STRZERO(0,TamSX3("E2_LOJA")[1]) 
Private cMV_INSS    := Replace(GetMV("MV_INSS"),'"','')  
Private cPrefixo    := LEFT("AGI"+SPACE(10),TamSX3("E2_PREFIXO")[1])    
Private cTipo       := LEFT("INS"+SPACE(10),TamSX3("E2_TIPO")[1])  
Private cParcela    := LEFT("1"+SPACE(10),TamSX3("E2_PARCELA")[1])    
Private nConAGL     := 0
Private nConITE     := 0 
Private oTotais  
Private cTotais     := SPACE(100)   

Default nTipo := 1
Default aAglut := {}

DEFINE FONT oArial12B NAME "Arial" SIZE 0,-12 BOLD

If nTipo = 1  
   If !Pergunte(cPerg)
      Return
   Endif  
   aAglut := fSelecao()
   If Len(aAglut) = 0
      MsgStop("Não existe registro a ser impresso","Erro") 
      Return   
   Endif   
Endif   

DEFINE MSDIALOG oDlgAgl TITLE "Titulos Aglutinadores gerados" FROM C(000), C(000)  TO C(430), C(500) COLORS 0, 16777215 PIXEL     
       @ C(192), (001) GROUP oGroup1 TO C(214), (248) OF oDlgAgl COLOR 0, 16777215 PIXEL
       @ C(199), (010) BUTTON oButton1 PROMPT "Imprimir" SIZE 037, 012 OF oDlgAgl ACTION fImprimir(pTipo,aAglut) PIXEL
       //@ C(199), (203) BUTTON oButton3 PROMPT "Sair" SIZE 037, 012 OF oDlgAgl ACTION oDlgAgl:End() PIXEL Thais Paiva - 11586347
	   @ C(199), (203) BUTTON oButton3 PROMPT "Sair" SIZE 037, 012 OF oDlgAgl ACTION Close(oDlgAgl) PIXEL
       @ C(168), (001) GROUP oGroup2 TO C(192), C(248) PROMPT "Totais" OF oDlgAgl COLOR 16711680, 16777215 PIXEL
       @ C(175), C(011) MSGET oTotais VAR cTotais SIZE C(233), C(013) FONT oArial12B OF oDlgAgl COLOR 16711680, 16777215 READONLY PIXEL
       fMSNewGe1(pTipo,aAglut)      
ACTIVATE MSDIALOG oDlgAgl CENTERED

Return

//============================================================================================================================= 
Static Function fMSNewGe1(nTipo,aAglut)
//============================================================================================================================= 
Local nX           := 0
Local nY           := 0
Local aHeaderEx    := {}
Local aColsEx      := {}
Local aFieldFill   := {}
Local aFields      := {"E2_FILIAL","E2_XNUMAGL","E2_EMISSAO","E2_EMISSAO","E2_CODINS","E2_VALOR","E2_BASEINS"} 
Local aAlterFields := {}    
Local cFxFilial    := ""
Local cFornPai     := ""
Local cLojPai        := ""
Local cNumAGL      := "" 
Static oMSNewGe1   

//Início - Thais Paiva - 11586347
//SX3->(DbSetOrder(2))
 For nX := 1 to Len(aFields)
      //If SX3->(DbSeek(aFields[nX]))
         /*Aadd(aHeaderEx,{AllTrim(X3Titulo()),;
                         SX3->X3_CAMPO,;
                         SX3->X3_PICTURE,;
                         SX3->X3_TAMANHO,;
                         SX3->X3_DECIMAL,;
                         SX3->X3_VALID,;
                         SX3->X3_USADO,;
                         SX3->X3_TIPO,;
                         SX3->X3_F3,;
                         SX3->X3_CONTEXT,;
                         SX3->X3_CBOX,;
                         SX3->X3_RELACAO})*/
   aAdd(aHeaderEx,{Alltrim(GetSx3Cache(aFields[nX], 'X3_TITULO')),;
                     GetSx3Cache(aFields[nX], 'X3_CAMPO'),;
                     GetSx3Cache(aFields[nX], 'X3_PICTURE'),;
                     GetSx3Cache(aFields[nX], 'X3_TAMANHO'),;
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
nConAGL := 0
aColsEx := {}
For nY := 1 to Len(aAglut) 
    If Len(aAglut[nY]) = Len(aFields)
       aAdd(aColsEx,{}) 
       For nX := 1 to Len(aFields)
          aAdd(aColsEx[Len(aColsEx)],aAglut[nY,nX])
       Next nX 
       nConAGL += aAglut[nY,6]          
       aAdd(aColsEx[Len(aColsEx)],.F.) 
    Else
       nX := nX      
    Endif    
Next nY 

cTotais :="Títulos Aglutinadores: Quantidade:     "+ALLTRIM(STR(LEN(aColsEx)))+SPACE(60)+"Valor Total: "+ALLTRIM(TRANSFORM(nConAGL,"@E 999,999,999.99"))  
  oMSNewGe1 := MsNewGetDados():New( C(005), C(000), C(167), C(248), GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgAgl, aHeaderEx, aColsEx)
oTotais:SetText(cTotais)
oTotais:CtrlRefresh()

Return

//=================================================================================================
Static Function fSelecao()
//=================================================================================================
Local aLinha  := {}
Local aItens  := {}   

If select("RS_REL") > 0
   dbSelectArea("RS_REL") 
   dbCloseArea("RS_REL") 
Endif

cQuery := " SELECT E2_FILIAL,E2_NUM,E2_EMISSAO,E2_CODINS,E2_VALOR,E2_BASEINS"
cQuery += " FROM "+RetSqlName("SE2")
cQuery += " WHERE D_E_L_E_T_ = ' '"
cQuery += " AND E2_XNUMAGL = ' '"
cQuery += " AND E2_PREFIXO = 'AGI'"   
cQuery += " AND E2_TIPO = 'INS'"   
cQuery += " AND E2_FORNECE IN ('"+cMV_FORINSS+"','INPS','UNIAO')"
cQuery += " AND E2_NATUREZ = '"+Replace(cMV_INSS,'"','')+"'"
cQuery += " AND E2_FILIAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"     
cQuery += " AND E2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"       
cQuery += " AND E2_EMIS1   BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"'" 
cQuery += " AND E2_FILORIG BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'" 
cQuery += " ORDER BY E2_EMISSAO,E2_NUM"

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "RS_REL", .F., .T.)  		
dbSelectArea("RS_REL") 
RS_REL->(DbGoTop())

While RS_REL->(!Eof()) 
      aLinha := {RS_REL->E2_FILIAL,RS_REL->E2_NUM,FirstDate(STOD(RS_REL->E2_EMISSAO)),LastDate(STOD(RS_REL->E2_EMISSAO)),RS_REL->E2_CODINS,RS_REL->E2_VALOR,RS_REL->E2_BASEINS}		
      aAdd(aItens,aLinha) 
      nConAGL += RS_REL->E2_VALOR
      RS_REL->(DbSkip())       
Enddo  

Return (aItens)

//=================================================================================================
Static Function fImprimir(pTipo,aAglut)
//=================================================================================================
Local aHeaderEx := {}
Local aColsEx   := {}                                                                                                                                               
Local cQuery    := ""
Local aFields   := {"E2_XNUMAGL","E2_FILORIG","E2_NUM","E2_TIPO","E2_PREFIXO","A2_COD" ,"A2_LOJA","A2_NREDUZ","A2_CGC","E1_NUM","E2_EMISSAO","E2_EMIS1","E2_VENCREA","E2_VALOR"  ,"E2_BASEINS","E2_XVJUROS","E2_XVMULTA","E1_VALOR","E2_CODINS"}
Local aCabec1   := {"Número"    ,"Fil"      ,"Número" ,"Tp "    ,"Pref"      ,"Código" ,"Loja"   ,"Nome"     ,"CNPJ  ","Título","Data de"   ,"Data    ","Data   "   ,"     Valor","Base"     ,"Valor"    ,"Valor"   ,"Valor"   ,"Cód."}
Local aCabec2   := {"Aglut."    ,"Ori"      ,"Título" ,"Tít"    ,"."         ,"Fornec.","Forn"   ,"Fantasia" ,"Origem","Origem","Emissão"   ,"Contábil","Vct Real"  ,"Principal" ,"Cálculo"  ,"Juros"    ,"Multa"   ,"Total"   ,"Ret."}
Local aTotais   := {}                                                                                                                                                                                                       
Local nLoop     := 0
Local cFilPai   := ""
Local cPrfPai   := ""
Local cNumPai   := ""
Local cPrcPai   := ""
Local cTipPai   := ""
Local cFornPai  := ""
Local cLojPai   := ""
Local nTotalReg := 0
Local cPerg     := "AGLRELT" 
Local nX1       := 0
Local nX2       := 0
Local nX3       := 0
Local nX4       := 0
Local nX5       := 0
Local nTotal    := 0  

//Início - Thais Paiva - 11586347
//SX3->(DbSetOrder(2))
 For nX := 1 to Len(aFields)
      //If SX3->(DbSeek(aFields[nX]))
         /*Aadd(aHeaderEx,{aCabec1[nX],;
                         SX3->X3_CAMPO,;
                         If(SX3->X3_DECIMAL>0,"@E 999,999,999.99",SX3->X3_PICTURE),;
                         If(SX3->X3_TIPO="D",10,If(SX3->X3_DECIMAL>0,14,SX3->X3_TAMANHO)),;
                         SX3->X3_DECIMAL,;
                         SX3->X3_VALID,;
                         SX3->X3_USADO,;
                         SX3->X3_TIPO,;
                         SX3->X3_F3,;
                         SX3->X3_CONTEXT,;
                         SX3->X3_CBOX,;
                         SX3->X3_RELACAO})*/
		aAdd(aHeaderEx,{aCabec1[nX],;
                      GetSx3Cache(aFields[nX], 'X3_CAMPO'),;
                      If(GetSx3Cache(aFields[nX], 'X3_DECIMAL')>0,"@E 999,999,999.99",GetSx3Cache(aFields[nX], 'X3_PICTURE')),;
                      If(GetSx3Cache(aFields[nX], 'X3_TIPO')=="D",10,If(GetSx3Cache(aFields[nX], 'X3_DECIMAL')>0,14,GetSx3Cache(aFields[nX], 'X3_TAMANHO'))),;
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
For nX := 1 to Len(aHeaderEx)
     aAdd(aTotais,If(aHeaderEx[nX,8]="N",0,SPACE(aHeaderEx[nX,4])))
Next nX
aItens := {}
nTotalReg := Len(aAglut)
For nLoop := 1 to Len(aAglut) 
    /*Início Thais Paiva - 11586347
	dbSelectArea("SE2")
    SE2->(DBSETORDER(1)) 
    MsSeek("SE2")	 
    SE2->(DbSeek(aAglut[nLoop,1]+cPrefixo+aAglut[nLoop,2]+cParcela+cTipo+cMV_FORINSS+cMV_LOJINSS))*/
    If select("RS_SEX") > 0
       dbSelectArea("RS_SEX") 
       dbCloseArea("RS_SEX") 
    Endif
    cQuery := "SELECT E2_XNUMAGL,E2_FILORIG,E2_NUM ,E2_TIPO,E2_PREFIXO,E2_PARCELA,E2_NATUREZ,E2_TITPAI,E2_EMISSAO,E2_EMIS1,E2_VENCREA,E2_VALOR,E2_BASEINS,E2_XVJUROS,E2_XVMULTA,E2_CODINS"
    cQuery += " FROM "+RetSqlName("SE2")
    cQuery += " WHERE E2_NATUREZ = '"+Replace(cMV_INSS,'"','')+"'"
	cQuery += " AND E2_PREFIXO <> 'AGI'"  
	cQuery += " AND E2_TIPO = 'INS'"
	cQuery += " AND E2_FORNECE IN ('"+cMV_FORINSS+"','INPS','UNIAO')"
	cQuery += " AND E2_XNUMAGL = '"+aAglut[nLoop,1]+aAglut[nLoop,2]+"'"
	cQuery += " AND E2_TITPAI <> ' '"
	cQuery += " AND E2_VALLIQ = 0 "
	cQuery += " AND E2_SALDO = 0 "
	cQuery += " AND D_E_L_E_T_ = ' '"
    cQuery += " ORDER BY E2_EMISSAO,E2_NUM"
    dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "RS_SEX", .F., .T.)  		
    dbSelectArea("RS_SEX") 
    RS_SEX->(DbGoTop())
    While RS_SEX->(!Eof())   
          aLinha := {}
          nTotalReg += 1
          cPrfPai  := SUBSTR(RS_SEX->E2_TITPAI,1,TamSX3("E2_PREFIXO")[1])
          cNumPai  := SUBSTR(RS_SEX->E2_TITPAI,TamSX3("E2_PREFIXO")[1]+1,TamSX3("E2_NUM")[1])
          cPrcPai  := SUBSTR(RS_SEX->E2_TITPAI,TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+1,TamSX3("E2_PARCELA")[1])
          cTipPai  := SUBSTR(RS_SEX->E2_TITPAI,TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+1,TamSX3("E2_TIPO")[1])
          cFornPai := SUBSTR(RS_SEX->E2_TITPAI,TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+TamSX3("E2_TIPO")[1]+1,TamSX3("E2_FORNECE")[1])
          cLojPai  := SUBSTR(RS_SEX->E2_TITPAI,TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+TamSX3("E2_TIPO")[1]+TamSX3("E2_FORNECE")[1]+1,TamSX3("E2_LOJA")[1])        
          /*DbSelectArea("SA2")
          SA2->(DBSETORDER(1))	
          If SA2->(DbSeek(xFilial("SA2")+cFornPai+cLojPai))
          Else   
            If SA2->(DbSeek(XFILIAL("SA2")+cFornPai+cLojPai))  
            Endif
          Endif             */
          aAdd(aLinha,RS_SEX->E2_XNUMAGL)
          aAdd(aLinha,RS_SEX->E2_FILORIG)
          aAdd(aLinha,RS_SEX->E2_NUM) 
          aAdd(aLinha,RS_SEX->E2_TIPO)
          aAdd(aLinha,RS_SEX->E2_PREFIXO)
          aAdd(aLinha,POSICIONE("SA2",1,xFilial("SA2")+cFornPai+cLojPai,"A2_COD"))//aAdd(aLinha,SA2->A2_COD)
          aAdd(aLinha,POSICIONE("SA2",1,xFilial("SA2")+cFornPai+cLojPai,"A2_LOJA"))//aAdd(aLinha,SA2->A2_LOJA) 
          aAdd(aLinha,POSICIONE("SA2",1,xFilial("SA2")+cFornPai+cLojPai,"A2_NREDUZ"))//aAdd(aLinha,SA2->A2_NREDUZ) 
          aAdd(aLinha,POSICIONE("SA2",1,xFilial("SA2")+cFornPai+cLojPai,"A2_CGC"))//aAdd(aLinha,SA2->A2_CGC) Thais 
          aAdd(aLinha,cNumPai)
          aAdd(aLinha,STOD(RS_SEX->E2_EMISSAO))
          aAdd(aLinha,STOD(RS_SEX->E2_EMIS1))
          aAdd(aLinha,STOD(RS_SEX->E2_VENCREA))
          aAdd(aLinha,RS_SEX->E2_VALOR)
          aAdd(aLinha,RS_SEX->E2_BASEINS)
          aAdd(aLinha,RS_SEX->E2_XVJUROS)
          aAdd(aLinha,RS_SEX->E2_XVMULTA)
          aAdd(aLinha,RS_SEX->E2_VALOR+RS_SEX->E2_XVJUROS+RS_SEX->E2_XVMULTA)
          aAdd(aLinha,RS_SEX->E2_CODINS)
          aAdd(aItens,aLinha)
		  
          //-------------------------------------------------------
          //Montando array de total geral     
          //-------------------------------------------------------          
          aTotais[01] := "TOT GERAL"
          aTotais[08] :=  STRZERO(Len(aAglut),3)+" TIT AGI" 
          aTotais[14] +=RS_SEX->E2_VALOR
          aTotais[15] +=RS_SEX->E2_BASEINS
          aTotais[16] += RS_SEX->E2_XVJUROS
          aTotais[17] += RS_SEX->E2_XVMULTA
          aTotais[18] += RS_SEX->E2_VALOR+RS_SEX->E2_XVJUROS+RS_SEX->E2_XVMULTA
          //-------------------------------------------------------                    
          RS_SEX->(DbSkip())       
    Enddo     
    nTotalReg += 1
    aLinha := {}
	
	dbSelectArea("SE2") 
    SE2->(DBSETORDER(1))  
    SE2->(DbSeek(aAglut[nLoop,1]+cPrefixo+aAglut[nLoop,2]+cParcela+cTipo+cMV_FORINSS+cMV_LOJINSS))
    
	dbSelectArea("SA2")
    SA2->(DBSETORDER(1))	
    SA2->(DbSeek(xfilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))
    aAdd(aLinha,"===>TOTAL")
    aAdd(aLinha,SE2->E2_FILORIG)
    aAdd(aLinha,SE2->E2_NUM) 
    aAdd(aLinha,SE2->E2_TIPO)
    aAdd(aLinha,SE2->E2_PREFIXO)
    aAdd(aLinha,SA2->A2_COD)
    aAdd(aLinha,SA2->A2_LOJA)
    aAdd(aLinha,SA2->A2_NREDUZ)
    aAdd(aLinha,SA2->A2_CGC)
    aAdd(aLinha,cNumPai)
    aAdd(aLinha,SE2->E2_EMISSAO)
    aAdd(aLinha,SE2->E2_EMIS1)
    aAdd(aLinha,SE2->E2_VENCREA)
    aAdd(aLinha,SE2->E2_VALOR)
    aAdd(aLinha,SE2->E2_BASEINS)      
    aAdd(aLinha,SE2->E2_XVJUROS)
    aAdd(aLinha,SE2->E2_XVMULTA)    
    aAdd(aLinha,SE2->E2_VALOR+SE2->E2_XVJUROS+SE2->E2_XVMULTA)
    aAdd(aLinha,SE2->E2_CODINS)
    aAdd(aItens,aLinha) 
    nTotalReg += 1     
    nTotal += SE2->E2_VALOR
	
	SA2->(DbCloseArea()) 
	SE2->(DbCloseArea()) 
	//Fim - Thais Paiva - 11586347
	
Next nLoop  
aAdd(aItens,aTotais)
U_ETX_RELT(1,"AGL_RELT","RELAÇÃO DE TÍTULOS AGLUTINADOS DE INSS A PAGAR","SE2",aCabec1,aCabec2,aHeaderEx,aItens,nTotalReg,cPerg,"xx")
oDlgAgl:End()
Return

//=================================================================================================
Static Function C(nTam)                                                                            
//=================================================================================================
Local nEx := nTam
Local nHRes	:= oMainWnd:nClientWidth			// Resolucao horizontal do monitor
If nHRes == 640									// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
	nTam *= 0.8
ElseIf ( nHRes == 798 ) .OR. ( nHRes == 800 )	// Resolucao 800x600
	nTam *= 1
Else											// Resolucao 1024x768 e acima
	nTam *= 1.28
EndIf
If "MP8" $ oApp:cVersion
	If ( Alltrim( GetTheme() ) == "FLAT" ) .OR. SetMdiChild()
		nTam *= 0.90
	EndIf
EndIf
Return Int(nTam)
