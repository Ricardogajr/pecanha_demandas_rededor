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
//Programa............: ETX_BRWS()
//Autor...............: THIAGO PEREIRA
//Data................: 06/03/2021
//Descricao / Objetivo: Aglutinação de Títulos - Tela Principal  
//Cliente             :  REDE DOR
//=============================================================================================================================
User Function ETX_BRWS()
//=============================================================================================================================

//=============================================================================================================================
Private cCadastro := "Aglutinação de Títulos a Pagar (INSS)"
Private aRotina   := MenuDef()
Private cDelFunc  := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cString   := "SE2"  
Private aYCores    := {} 
Private cFiltro   := ""
Private MVINSS  := SuperGetMv("MV_INSS",.F.,.F.) 
Private MVXINSS := SuperGetMv("MV_XINSS",.F.,.F.)   
Private aSays     := {}
Private aBotoes   := {} 
Private lOK       := .F.
 
  
If VALTYPE(MVINSS) = "L"
   If !MVINSS
     MVINSS := ""
   Endif  
Endif     
If VALTYPE(MVXINSS) = "L"
   If !MVXINSS
       MVXINSS := ALLTRIM(MVINSS)
   Endif  
Endif     

If ALLTRIM(MVINSS) = ""
   MsgStop("Não existe o parâmetro Padrão MV_INSS, favor corrigir","Erro")
   Return
Endif  

XFILNAT := ALLTRIM(MVINSS)
IF !EMPTY(MVXINSS)
   XFILNAT +=  ALLTRIM(MVXINSS)
ENDIF

/*cFiltro := " E2_PREFIXO = 'AGI' OR ( E2_XNUMAGL=' ' "
CFILTRO += " AND E2_TITPAI <> ' ' " 
CFILTRO += " AND E2_TIPO ='INS'  "
//CFILTRO += " AND E2_NATUREZ IN ("+ XFILNAT + ")  )  "   Thais Paiva - 11586347
CFILTRO += " AND E2_NATUREZ IN ('"+ XFILNAT +"')  )  "   */

aSays := {}
aAdd(aSays,"Este programa tem por objetivo Aglutinação de Títulos a Pagar (INSS)")
aAdd(aSays,"As Aglutinaçãões serão feitas, por:")      
aAdd(aSays,"Mes/Ano Emissão")   
aAdd(aSays,"Natureza Financeira")       


aAdd(aBotoes, {1, .T., {|o| lOk := .T.,o:oWnd:End()}})
aAdd(aBotoes, {2, .T., {|o| o:oWnd:End()}})
FormBatch("Aglutinação de Títulos a Pagar (INSS)", aSays, aBotoes,,, 650)

If !lOk
   Return
Endif   

dbSelectArea(cString)
dbSetOrder(1)

//mBrowse(6,1,22,75,cString,,,,,,,,,,,,,,cFiltro,,,,)
mBrowse(6,1,22,75,cString)   


Return

//=============================================================================================================================
User Function AGL_SF04()  
//=============================================================================================================================  
Local nRecno := SE2->(RECNO())  
Local cCodINSS := ""
Local cDIRF   := ""

SE2->( dbGoTo(nRecno))   
cCodINSS := U_ETX_CDRET(SE2->E2_NUM,SE2->E2_CODINS)       
RecLock( "SE2",.F.)  
SE2->E2_CODINS := cCodINSS
SE2->(MsUnLock())      
Return

//=============================================================================================================================
Static Function MenuDef()
//=============================================================================================================================  
Local axRotina := {}

aAdd(axRotina,{"Pesquisa"  ,"AxPesqui"         ,0,01})
aAdd(axRotina,{"Visualizar","AxVisual"         ,0,02})
aAdd(axRotina,{"Alterar"   ,"U_AGL_SF04()"     ,0,04}) 
aAdd(axRotina,{"Aglutinar" ,"U_AGL_MRKB()"     ,0,06})
aAdd(axRotina,{"Estornar"  ,"U_ETX_CANC"       ,0,07})
aAdd(axRotina,{"Composição","U_ETX_COMP()"     ,0,08})
aAdd(axRotina,{"Imprimir"  ,"U_ETX_RELAT(1,{})",0,09})

Return axRotina
