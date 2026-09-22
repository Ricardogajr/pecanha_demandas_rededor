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
//Programa............: ETX_COMP()
//Autor...............: THIAGO PEREIRA
//Data................: 06/03/2021
//Descricao / Objetivo: Aglutinação de Títulos - Compposição dos Títulos Aglutinadores (AGI) 
//=============================================================================================================================

User Function ETX_COMP()
//=============================================================================================================================

Private cCadastro := "Aglutinação de Títulos a Pagar (INSS)-Composição"
Private aRotina   := MenuDef()
Private cDelFunc  := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cString   := "SE2"  
Private cMV_INSS  := SuperGetMv("MV_INSS",.F.,.F.) 
Private cMV_XINSS := SuperGetMv("MV_XINSS",.F.,.F.)  
Private cFiltro   := ""

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

cMV_XINSS := REPLACE(REPLACE(ALLTRIM(cMV_INSS)+"|"+ALLTRIM(cMV_XINSS),'"',''),',','|')+"|"
cFiltro := "E2_XNUMAGL = ' ' AND E2_TITPAI = ' ' AND E2_PREFIXO = 'AGI' AND E2_TIPO = 'INS'"  
cFiltro := Replace(cFiltro,"',')'","')")

dbSelectArea("SE2")
dbSetOrder(1)
dbSelectArea(cString)
mBrowse(6,1,22,75,cString,,,,,,,,,,,,,,cFiltro,,,,)  
Return

//=============================================================================================================================
User Function ETX_XCOMP()     
//=============================================================================================================================
Local oButton1
Local oGroup1        
Local nRecno := SE2->(RECNO())
Static oDlgComp   

dbSelectArea("SE2")
SE2->(dbGoTo(nRecno))

DEFINE MSDIALOG oDlgComp TITLE "Composição do Título AGI [ "+SE2->E2_NUM+" ]" FROM C(000), C(000)  TO C(360), C(1000) COLORS 0, 16777215 PIXEL
    fMSNewGe1()
    @ C(155), C(000) GROUP oGroup1 TO 179, 498 OF oDlgComp COLOR 0, 16777215 PIXEL
    @ C(162), C(406) BUTTON oButton1 PROMPT "Voltar" SIZE 037, 012 OF oDlgComp ACTION oDlgComp:End() PIXEL
ACTIVATE MSDIALOG oDlgComp CENTERED

Return

//=============================================================================================================================
Static Function fMSNewGe1()
//=============================================================================================================================
Local nX
Local aHeaderEx    := {}
Local aColsEx      := {}
Local aFieldFill   := {}
Local aFields      := {"E2_FILIAL","E2_FILORIG","E2_NUM" ,"E2_PREFIXO","E2_PARCELA","E2_TIPO","E2_EMISSAO","E2_VENCTO","E2_VENCREA","E2_CODINS","E2_VALOR" ,"E2_XVJUROS","E2_XVMULTA","E2_BASEINS"  ,"E1_NUM" ,"E1_PREFIXO","E1_PARCELA","E1_TIPO","E1_CLIENTE","E1_LOJA","A2_NOME" ,"A2_CGC"}
Local aTitulo      := {"Fil"      ,"Fil Orig"  ,"Num Tit","Pref"      ,"Prc"       ,"Tipo"   ,"Dt Emissão","Dt Vencto","Vct Real"  ,"Cod Ret"  ,"Valor Tit","Vlr Juros" ,"Vlr Multa" ,"Base Cálculo","Tit Pai","Prf Pai"   ,"Prc Pai"   ,"Tip Pai","Forn Pai"  ,"Loj Pai","Nome Pai","CGC Pai"}
Local aValores     := {"E2_FILIAL","E2_FILORIG","E2_NUM" ,"E2_PREFIXO","E2_PARCELA","E2_TIPO","E2_EMISSAO","E2_VENCTO","E2_VENCREA" ,"E2_CODINS","E2_VALOR" ,"E2_XVJUROS","E2_XVMULTA","E2_BASEINS"}
Local aAlterFields := {}  
Local nRecno       := SE2->(RECNO())
Local cPrfPai      := ""
Local cNumPai      := ""
Local cPrcPai      := ""
Local cTipPai      := ""
Local cFornPai     := ""
Local  cLojPai     := ""
Static oMSNewGe1

DbSelectArea("SE2")
SE2->( dbGoTo(nRecno))   
If SE2->E2_PREFIXO <> "AGI"   
   MsgStop("Este Título não é um Aglutinador","Erro") 
   oDlgComp:End()
   Return
Endif
//Início - Thais Paiva - 11586347
//DbSelectArea("SX3")
//SX3->(DbSetOrder(2))
For nX := 1 to Len(aFields)
    //If SX3->(DbSeek(aFields[nX]))
      /* Aadd(aHeaderEx, {AllTrim(aTitulo[nX]),;
                        SX3->X3_CAMPO       ,;
                        SX3->X3_PICTURE     ,;
                        SX3->X3_TAMANHO     ,;
                        SX3->X3_DECIMAL     ,;
                        SX3->X3_VALID       ,;
                        SX3->X3_USADO       ,;
                        SX3->X3_TIPO        ,;
                        SX3->X3_F3          ,;
                        SX3->X3_CONTEXT     ,;
                        SX3->X3_CBOX        ,;
                        SX3->X3_RELACAO})*/
		aAdd(aHeaderEx,{AllTrim(aTitulo[nX]),;
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
aColsEx := {}
If select("RS_SEX") > 0
   dbSelectArea("RS_SEX") 
   dbCloseArea("RS_SEX") 
Endif
cQuery := " SELECT E2_EMISSAO,E2_VENCTO,E2_VENCREA,E2_FILIAL,E2_FILORIG,E2_NATUREZ,E2_CODINS"
cQuery += " ,E2_FORNECE,E2_LOJA,E2_NOMFOR,E2_NUM,E2_TIPO,E2_PREFIXO,E2_PARCELA,E2_HIST,E2_VALOR"
cQuery += " ,E2_XVJUROS,E2_XVMULTA,E2_TITPAI,E2_BASEINS"
cQuery += " FROM "+RetSqlName("SE2")
cQuery += " WHERE D_E_L_E_T_ = ' '"
cQuery += " AND E2_XNUMAGL = '"+SE2->E2_FILORIG+SE2->E2_NUM+"'"
cQuery += " ORDER BY E2_EMISSAO,E2_CODINS,E2_FILORIG,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO"

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "RS_SEX", .F., .T.)  		
dbSelectArea("RS_SEX") 
RS_SEX->(DbGoTop())

While RS_SEX->(!Eof()) 
      aAdd(aColsEx,{})	
      For nX := 1 to LEN(aFields)
          If Left(aHeaderEx[nX,2],2)= "E2"  
             If aHeaderEx[nX,8] = "D"   
                aAdd(aColsEx[Len(aColsEx)],STOD(RS_SEX->&(aHeaderEx[nX,2])))
             Else    
                aAdd(aColsEx[Len(aColsEx)],RS_SEX->&(aHeaderEx[nX,2]))
             Endif      
          Endif   
      Next nX     
      cPrfPai  := SUBSTR(RS_SEX->E2_TITPAI,1,TamSX3("E2_PREFIXO")[1])
      cNumPai  := SUBSTR(RS_SEX->E2_TITPAI,TamSX3("E2_PREFIXO")[1]+1,TamSX3("E2_NUM")[1])
      cPrcPai  := SUBSTR(RS_SEX->E2_TITPAI,TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+1,TamSX3("E2_PARCELA")[1])
      cTipPai  := SUBSTR(RS_SEX->E2_TITPAI,TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+1,TamSX3("E2_TIPO")[1])
      cFornPai := SUBSTR(RS_SEX->E2_TITPAI,TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+TamSX3("E2_TIPO")[1]+1,TamSX3("E2_FORNECE")[1])
       cLojPai := SUBSTR(RS_SEX->E2_TITPAI,TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+TamSX3("E2_TIPO")[1]+TamSX3("E2_FORNECE")[1]+1,TamSX3("E2_LOJA")[1])        
      dbSelectArea("SA2")
      SA2->(DBSETORDER(1))	
      SA2->(DbSeek(xfilial("SA2")+cFornPai+cLojPai))
      aAdd(aColsEx[Len(aColsEx)],cNumPai)
      aAdd(aColsEx[Len(aColsEx)],cPrfPai)
      aAdd(aColsEx[Len(aColsEx)],cPrcPai)
      aAdd(aColsEx[Len(aColsEx)],cTipPai)
      aAdd(aColsEx[Len(aColsEx)],cFornPai)      
      aAdd(aColsEx[Len(aColsEx)],cLojPai)            
      aAdd(aColsEx[Len(aColsEx)],SA2->A2_NOME)       
      aAdd(aColsEx[Len(aColsEx)],SA2->A2_CGC)         
      aAdd(aColsEx[Len(aColsEx)],.F.) 
      RS_SEX->(DbSkip())       
Enddo  

If Len(aColsEx) == 0     
   MsgStop("Não existe título relacionado a este Aglutinador","Erro") 
   oDlgComp:End()
   Return
Endif   

oMSNewGe1 := MsNewGetDados():New( C(003), C(000), C(150), C(498), GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgComp, aHeaderEx, aColsEx)

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

//=============================================================================================================================
Static Function MenuDef()
//=============================================================================================================================  
Local axRotina := {}

aAdd(axRotina,{"Visualizar","AxVisual"         ,0,02})
aAdd(axRotina,{"Composição","U_ETX_XCOMP()"    ,0,08})
aAdd(axRotina,{"Imprimir"  ,"U_ETX_RELAT(1,{})",0,09})
Return axRotina
