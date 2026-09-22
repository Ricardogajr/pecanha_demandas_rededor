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
//Programa............: UPDX6SIS12() =======
//Autor...............: Ramon Teodoro e Silva 
//Data................: 10/12/2020
//Descricao / Objetivo: Ajusta Dicionário de Dados - SX6 para os parâmetros FS_XDIRSIS 
//Cliente             : Rede Dor
//=============================================================================================================================
User Function UPDX6SIS12()
//=============================================================================================================================

Private aEmpresas  := {}
Private aArea := getArea()   
Private _cUsuario  := ""  
//Private dfcCamiLog := GetSrvProfString("StartPath","")

MsgRun("Carregando as informações das empresas.","Aguarde...",{||aEmpresas:=AdmGetFil(.T.,.F.)}) 
If Len(aEmpresas) > 0   
   fUPDTela()
Endif
Return .T.

//=============================================================================================================================
Static Function fUPDTela()                                                                                                     
//=============================================================================================================================
Local lRet := .T.
Private oTexto                                                                    
Private cTexto := ""
Private oDlgTela  

cTexto := " "

DEFINE MSDIALOG oDlgTela TITLE "Dicionário de Dados" FROM 000, 000  TO 500, 500 COLORS 0, 16777215 PIXEL
    @ 002, 000 GET oTexto VAR cTexto OF oDlgTela MULTILINE SIZE 244, 223 COLORS 0, 16777215 HSCROLL PIXEL
    @ 227, 001 GROUP oGroup1 TO 246, 246 OF oDlgTela COLOR 0, 16777215 PIXEL
    @ 232, 013 BUTTON oButton1 PROMPT "Executar" SIZE 037, 012 OF oDlgTela ACTION fUPDBase()  PIXEL
    @ 232, 203 BUTTON oButton2 PROMPT "Sair" SIZE 037, 012 OF oDlgTela ACTION oDlgTela:End() PIXEL    
ACTIVATE MSDIALOG oDlgTela CENTERED
Return lRet

//=============================================================================================================================
Static Function fUPDBase()                                                                                                     
//=============================================================================================================================
Local lRet    := .T.
Local nEmp    := 0
Local cChave  := ""

//cEmpBKP := cEmpAnt
//cFilBKP := cFilAnt 

cTexto := "==============================================================================="+Chr(13)+Chr(10)
cTexto += TIME()+" <=== Iniciando a atualização do Dicionário de Dados"+Chr(13)+Chr(10)
cTexto += "==============================================================================="+Chr(13)+Chr(10)

cTexto += TIME()+" <=== Processando empresa " +cEmpAnt+"-"+FWCompanyName()+Chr(13)+Chr(10)
oTexto:Refresh()   
oTexto:GoEnd() 
oDlgTela:Refresh()

DbSelectArea("SX6")
SX6->(DbSetOrder(1)) 

For nEmp := 1 to Len(aEmpresas)     
   
   DbSelectArea("SX6")
	SX6->(DbSetOrder(1))
   
   lIncAlt := (!SX6->(DbSeek(aEmpresas[nEmp] + "FS_XDIRSIS") ))
   Reclock("SX6", lIncAlt)
   If lIncAlt
      SX6->X6_FIL     := aEmpresas[nEmp]
      SX6->X6_VAR		 := "FS_XDIRSIS"
      SX6->X6_TIPO	 := "C"
      SX6->X6_DESCRIC := "Definição do diretório onde serão salvos os arquiv"
      SX6->X6_DESC1	 := "os SISPAG.                                   "
      SX6->X6_CONTEUD := "\REMESSA"
      SX6->X6_PROPRI	 := "U"
      cTexto += "Parâmetro FS_XDIRSIS criado com sucesso para filial " + aEmpresas[nEmp] + Chr(13)+Chr(10)
   Else
      SX6->X6_CONTEUD := "\REMESSA"
      cTexto += "Parâmetro FS_XDIRSIS alterado com sucesso para filial " + aEmpresas[nEmp] + Chr(13)+Chr(10)
   EndIf
   SX6->(MsUnlock())
   
   //cEmpAtu := SubStr(aEmpresas[nEmp],1,Len(FWSM0Layout(,1)))

   oTexto:Refresh()   
	oTexto:GoEnd() 
   oDlgTela:Refresh()    

Next nEmp

cTexto += "==============================================================================="+Chr(13)+Chr(10)
cTexto += TIME()+" <=== Atualização do Dicionário de Dados completa"+Chr(13)+Chr(10) 
cTexto += "==============================================================================="+Chr(13)+Chr(10)  
oTexto:Refresh()   
oTexto:GoEnd() 
oDlgTela:Refresh() 

cChave := "LogUpdX6P12-"+dtos(dDATABASE)+"-"+REPLACE(TIME(),":","-")+".TXT"
MemoWrite(cChave,cTexto) // Grava o arquivo de log no final do processamento de cada empresa   
MSGInfo("Arquivo de Log gerado em "+GetSrvProfString("Rootpath", "")+"\"+ALLTRIM(cChave), "Atualização SX6", 1, .t.)

RestArea( aArea ) 
Return lRet 

