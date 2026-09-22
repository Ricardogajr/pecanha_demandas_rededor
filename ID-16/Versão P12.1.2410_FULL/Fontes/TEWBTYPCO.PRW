#INCLUDE "protheus.ch"

/*
{Protheus.doc} TEWBTYPCO()
Programa com funções auxiliares do PCO
@Author     Ramon Teodoro
@Since      30/08/2017       
@Version    P12.7
@Return     lRet
*/
//
//Programa  PCOI001   Autor:  Artur Vilar 	      		Data   27/04/16 
//Desc.     Rotina que identifica a integração ou não com módulo PCO
//Uso       SIGAPCO                                                   
//                                                   
// IIF(PCOI001(C7_UNIDADE, C7_CC, C7_CONTA)==.t.,0) 


User Function PCOI001(cUnidade, cCcusto, cConta, cTpMov )  
                  
Local lRet    := .T.
Local aArea   := GetArea()    
Local cIntUni := ""       
Local cIntCC  := ""       
Local cIntCon := ""       

If Alltrim(cTpMov) == "B"
	cIntUni := Posicione("AMF",1,xFilial("AMF")+cUnidade,"AMF_XPCOBL")       
	cIntCC  := Posicione("CTT",1,xFilial("CTT")+cCCusto,"CTT_XPCOBL")       
	cIntCon := Posicione("CT1",1,xFilial("CT1")+cConta,"CT1_XPCOBL")       
Else
	cIntUni := Posicione("AMF",1,xFilial("AMF")+cUnidade,"AMF_XPCOIN")       
	cIntCC  := Posicione("CTT",1,xFilial("CTT")+cCCusto,"CTT_XPCOIN")       
	cIntCon := Posicione("CT1",1,xFilial("CT1")+cConta,"CT1_XPCOIN")       
EndIf


If cIntUni=='1' .and. cIntCC=='1' .and. cIntCon=='1'    
   lRet  := .T.
Else
   lRet  := .F.
EndIf                              

RestArea(aArea)

Return lRet



//
//Programa  PCOI001   Autor:  Artur Vilar 	      		Data   29/08/17 
//Desc.     Rotina que identifica a integração ou não com módulo PCO para integração dos saldos contábeis e depreciação do ativo fixo
//Uso       SIGAPCO                                                   
//                                                   
// IIF(PCOI002(C7_UNIDADE)==.t.,0) 

User Function PCOI002(cUnidade )  
                  
Local lRet    := .T.
Local aArea   := GetArea()    
Local cIntUni := ""       
     
cIntUni := Posicione("AMF",1,xFilial("AMF")+cUnidade,"AMF_XPCOIN")       

If cIntUni=='1' 
   lRet  := .T.
Else
   lRet  := .F.
EndIf                              

RestArea(aArea)

Return lRet







 


