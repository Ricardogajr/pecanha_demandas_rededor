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
//Programa............: ETX_CDRET()
//Autor...............: THIAGO PEREIRA
//Data................: 07/03/2021
//Descricao / Objetivo: Aglutinação de Títulos - Alteração do Código de Retenção  
//=============================================================================================================================

User Function ETX_CDRET(cNumero,cCodINS)                                                                                                          
//============================================================================================================================= 

Local oButton1
Local oButton2
Local oCodRet
Local oGroup1
Local oSay1
Local oSay2
Static oDlgEst
Private cCodRet  := cCodINS
Private cCodRetX := cCodINS       

DEFINE MSDIALOG oDlgEst TITLE "Alteração do Título [ "+cNumero+" ]" FROM C(000), C(000)  TO C(095), C(260) COLORS 0, 16777215 PIXEL
    @ C(001), C(004) GROUP oGroup1 TO C(045), C(128) OF oDlgEst COLOR 16711680, 16777215 PIXEL
    @ C(012), C(011) SAY oSay1 PROMPT "Código de Retenção de INSS:" SIZE 078, 007 OF oDlgEst COLORS 16711680, 16777215 PIXEL
    @ C(010), C(092) MSGET oCodRet VAR cCodRet SIZE 033, 010 OF oDlgEst COLORS 0, 16777215 F3 "38" PIXEL
    @ C(029), C(033) BUTTON oButton1 PROMPT "Confirmar" SIZE 037, 012 OF oDlgEst ACTION fConfirmar(cCodRet,1) PIXEL
    @ C(029), C(085) BUTTON oButton2 PROMPT "Voltar" SIZE 037, 012 OF oDlgEst    ACTION fConfirmar(cCodRetX,2) PIXEL
ACTIVATE MSDIALOG oDlgEst CENTERED

Return (cCodRet)

//============================================================================================================================= 
Static Function fConfirmar(pCodRet,nPar)  
//============================================================================================================================= 
cCodRet := If(nPar=2,cCodRetX,pCodRet)
oDlgEst:End()
Return cCodRet

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
