#INCLUDE "PROTHEUS.CH"        
#INCLUDE "TOPCONN.CH" 
#include "rwmake.ch"  
#include "fileio.ch"    
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#Include "DBTREE.CH"
#Include "HBUTTON.CH"
#Define XENTERX Chr(13)+Chr(10) 

//==========================================================================================================================================================================================================================================================   
//Programa............: ETX_RELT()
//Autor...............: THIAGO PEREIRA 
//Data................: 06/03/2021
//Objetivo............: Função para Impressão Genérica de Relatórios
//==========================================================================================================================================================================================================================================================   

User Function ETX_RELT(pnCopias,pPrograma,pDescricao,pAlias,pCabec1,pCabec2,pHeaderx,pItens,pTotalReg,pcPerg,pNoCampo)
//==========================================================================================================================================================================================================================================================   

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "1"
Local cPict          := ""
Local titulo         := pDescricao
Local nLin           := 80
Local Cabec1         := ""
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd           := {}   
Private lEnd         := .F.  
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := pPrograma // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := pPrograma // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString      := "SE2"
Private aBox         := {}
Private axCabec      := {}
Private nX           := 0
Private nX1          := 0
Private nX2          := 0
Private nX3          := 0      
Private nX4          := 0  
Private aDados       := pItens
Private cNoCampo     := pNoCampo

For nX := 1 to Len(pHeaderx)
    If ALLTRIM(cNoCampo) = ""
       cNoCampo := "**##"
    Endif   
    If !(ALLTRIM(pHeaderx[nX,2]) $ cNoCampo)
       If LEN(ALLTRIM(pHeaderx[nX,11])) > 0
          cLinha  := ""
          cLinha := "{'"+Replace(ALLTRIM(pHeaderx[nX,11]),";","','")+"'}" 
          aBox := aClone(&cLinha)            
          nX2 := pHeaderx[nX,4]          
          For nX1 := 1 to LEN(aBox)  
              If LEN(ALLTRIM(aBox[nX1])) > nX2
                 nX2 := LEN(ALLTRIM(aBox[nX1]))
              Endif   
          Next nX1 
       Else   
          aBox := {}
      Endif
      aAdd(axCabec,{ALLTRIM(pHeaderx[nX,1]),;
                   pHeaderx[nX,2],;
                   pHeaderx[nX,3],;
                   If(pHeaderx[nX,4]>=40,pHeaderx[nX,4]-10,pHeaderx[nX,4]),;
                   pHeaderx[nX,5],;
                   pHeaderx[nX,6],;
                   pHeaderx[nX,7],;
                   pHeaderx[nX,8],;
                   pHeaderx[nX,9],;
                   pHeaderx[nX,10],;
                   aBox,;
                   pHeaderx[nX,12],;                             
                   0})
      If LEN(ALLTRIM(pHeaderx[nX,11])) > 0 
         nX2 := pHeaderx[nX,4]          
         For nX1 := 1 to LEN(aBox)  
             If LEN(ALLTRIM(aBox[nX1])) > nX2
                nX2 := LEN(ALLTRIM(aBox[nX1]))
             Endif   
         Next nX1 
         axCabec[nX,4] := nX2

       Endif   
   Endif
Next nX    
For nX := 1 to LEN(axCabec)  
    nX2 := axCabec[nX,4] 
    If Len(pCabec1[nX]) > nX2
       nX2 := Len(pCabec1[nX])
    Endif   
    If Len(pCabec2[nX]) > nX2
       nX2 := Len(pCabec2[nX])
    Endif  
    If ALLTRIM(axCabec[nX,8]) = "N" .AND. LEFT(ALLTRIM(axCabec[nX,3]),2) = "@E"   
       If nX2 > LEN(SUBSTR(ALLTRIM(axCabec[nX,3]),4,100))
          nX2 := LEN(SUBSTR(ALLTRIM(axCabec[nX,3]),4,100))+1
       Endif
    Endif 
    If ALLTRIM(axCabec[nX,8]) = "C" .AND. LEFT(ALLTRIM(axCabec[nX,3]),2) = "@R" 
       nX2 := LEN(ALLTRIM(axCabec[nX,3]))
    Endif                      
    axCabec[nX,4] := nX2    
    If ALLTRIM(axCabec[nX,8]) = "N"
       If nX2 > LEN(ALLTRIM(pCabec1[nX])) 
          nLin1 := nX2 - LEN(ALLTRIM(pCabec1[nX]))  
          pCabec1[nX] := Replicate("#",nLin1) + ALLTRIM(pCabec1[nX])
       Endif 
       If nX2 > LEN(ALLTRIM(pCabec2[nX])) 
          nLin1 := nX2 - LEN(ALLTRIM(pCabec2[nX]))  
          pCabec2[nX] := Replicate("#",nLin1) + ALLTRIM(pCabec2[nX])
       Endif 
    Endif
Next nX

nX2 := 0
Cabec1 := ""
Cabec2 := ""
For nX := 1 to LEN(axCabec)
    axCabec[nX,13] := nX2
    Cabec1 += LEFT(ALLTRIM(pCabec1[nX])+SPACE(100),axCabec[nX,4])+"#"
    Cabec2 += LEFT(ALLTRIM(pCabec2[nX])+SPACE(100),axCabec[nX,4])+"#"
    nX2 += axCabec[nX,4] + 1
Next nX    
Cabec1 := Replace(Cabec1,"#"," ")
Cabec2 := Replace(Cabec2,"#"," ")     
wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.T.)    
//wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)
If nLastKey == 27
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
   Return
Endif
nTipo := If(aReturn[4]==1,15,18)
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

//==========================================================================================================================================================================================================================================================   
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
//==========================================================================================================================================================================================================================================================   
Local nOrdem  
Local nXY := 0
nX  := 0
nX3 :=  LEN(aDados)-1
While nX <> nX3
    If lAbortPrint
       @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
       Exit
    Endif
    nX += 1
    If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
       Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
       nLin := 8
    Endif     
    nX2 := 0
    nLin := nLin + 1 // Avanca a linha de impressao 
    For nX1 := 1 to LEN(axCabec)    //axCabec[nX1,2]
        If axCabec[nX1,8]="C"
           If "CGC" $ axCabec[nX1,2]
              @nLin,axCabec[nX1,13] PSAY aDados[nX,nX1] Picture axCabec[nX1,3]
           Else          
              @nLin,axCabec[nX1,13] PSAY LEFT(ALLTRIM(aDados[nX,nX1])+SPACE(1000),axCabec[nX1,4])           
           Endif   
        Endif   
         If axCabec[nX1,8]="N"
           @nLin,axCabec[nX1,13] PSAY aDados[nX,nX1] Picture axCabec[nX1,3]
        Endif   
        If axCabec[nX1,8]="D"
           @nLin,axCabec[nX1,13] PSAY aDados[nX,nX1] 
        Endif             
     Next nX1       
     If ALLTRIM(aDados[nX,1]) = "===>TOTAL"   
        nLin := nLin + 1
     Endif
Enddo    
nLin := nLin + 1
If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
   Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
   nLin := 8
Endif    
nX2 := LEN(aDados)   
nLin += 1                   
For nX1 := 1 to LEN(axCabec)    
    If axCabec[nX1,8]="C"
       If "CGC" $ axCabec[nX1,2]
          @nLin,axCabec[nX1,13] PSAY aDados[nX2,nX1] //Picture axCabec[nX1,3]
       Else          
          @nLin,axCabec[nX1,13] PSAY LEFT(ALLTRIM(aDados[nX2,nX1])+SPACE(1000),axCabec[nX1,4])           
       Endif   
    Endif   
    If axCabec[nX1,8]="N"
       @nLin,axCabec[nX1,13] PSAY aDados[nX2,nX1] Picture axCabec[nX1,3]
    Endif   
    If axCabec[nX1,8]="D"
       @nLin,axCabec[nX1,13] PSAY aDados[nX2,nX1] 
    Endif             
Next nX1       

SET DEVICE TO SCREEN
If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif
MS_FLUSH()
Return
