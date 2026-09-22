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
//Programa............: FA050UPD()
//Autor...............: THIAGO PEREIRA
//Data................: 06/03/2021
//Descricao / Objetivo: Poto de Entrada para n�o permitir Exclus�o de Titulos Aglutinadores/Aglutinados de INSS 
//=============================================================================================================================
User Function FA050UPD()     //Primeiro a entrar em qualquer atualiza��o //.T./.F. - Se retornar .F. a inclus�o / altera��o / exclus�o n�o ter� prosseguimento.
//============================================================================================================================= 
Local aAreaE2 := SE2->(GetArea())
Local cMsg        := ""   // Function FA050Inclu(cAlias,nReg,nOpc,cRec1,cRec2,lSubst)     _Opc      
Local cMV_FORINSS := GetMV("MV_FORINSS")
Local cMV_LOJINSS := STRZERO(0,TamSX3("E2_LOJA")[1]) 
Local lRet        := .T.
Local nRecno      := SE2->(RECNO()) 

If _Opc = 5
   If !(UPPER(ALLTRIM(funname())) $ "ETX_BRWS|AGL_MRKB|ETX_CANC")
      If SE2->E2_PREFIXO = "AGI" .AND. SE2->E2_TIPO = "INS" .AND. SE2->E2_FORNECE = cMV_FORINSS  
         MsgStop("Este T�tulo � um Aglutinador de INSS, para a Exclus�o, deve-se utilizar a Rotina de Aglutina��o de INSS","Erro")   
         lRet := .F.
      Endif      
      If ALLTRIM(SE2->E2_XNUMAGL) <> ""
         MsgStop("Este T�tulo deu origem a um Aglutinador de INSS, para a Cancelar a Baixa, deve-se utilizar a Rotina de Aglutina��o de INSS","Erro")   
         lRet := .F.
      Endif                                                                      
   Endif
Endif   

	If (lRet .And. !INCLUI .And. !ALTERA)
		U_FLJMUNIC()//Fun��o para mudar a loja do fornecedor de titulo de ISS para 1 caso exista.
	EndIf

RestArea(aAreaE2)
Return  lRet
