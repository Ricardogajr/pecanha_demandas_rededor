#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} F1207503
Rotina chamada a partir ponto de entrada MTALCALT para possibilitar a troca do código do aprovador.
@author Reinaldo Dias
@since  22/04/2019
@return cAprovSubs
@project MAN0000007423048_EF_74
@cliente Rededor
@version P12.1.17
/*/
 
User Function F1207503()
	Local cAreaSAK  := SAK->(GetArea())
	Local cAproOrig := SAL->AL_APROV

	IF SAK->(FieldPos('AK_APROSUP')) == 0 .Or. SAK->(FieldPos('AK_XDTINI')) == 0 .Or. SAK->(FieldPos('AK_XDTFIM')) == 0 .Or. SCR->(FieldPos('CR_XAPRO')) == 0
	   Help( , , 'Help', 'F1207503', 'Os campos AK_APROSUP ou AK_XDTINI ou AK_XDTFIM ou CR_XAPRO não foram encontrados no banco de dados! Por favor, verificar.', 1, 0 )
	   Return Nil
	Endif 
	

	SAK->(DBSetOrder(1)) //AK_FILIAL+AK_COD
	
	SAK->(MsSeek(xFilial("SAK")+cAproOrig))

	IF !Empty(SAK->AK_XSUBSTI) .And. !Empty(SAK->AK_XDTINI) .And. !Empty(SAK->AK_XDTFIM) 
		IF MsDate() >= SAK->AK_XDTINI .And. MsDate() <= SAK->AK_XDTFIM

		//Ajusta o aprovador na tabela de Documentos com Alçada      
		IF SAK->(MsSeek(xFilial("SAK")+SAK->AK_XSUBSTI))
			/*
			Reclock("SCR",.F.)
			SCR->CR_USERORI := SCR->CR_USER
			SCR->CR_XAPRO   := UsrFullName(SCR->CR_USER)
			SCR->CR_APRORI  := SCR->CR_APROV
			SCR->CR_USER    := SAK->AK_USER
			SCR->CR_APROV   := SAK->AK_COD*/
			aSCR := {}
			aAdd(aSCR,{	SCR->CR_FILIAL ,;
			SCR->CR_NUM                ,;
			SCR->CR_TIPO               ,;
			SCR->CR_GRUPO              ,;
			SCR->CR_XFORNEC            ,;
			UsrFullName(SAK->AK_USER)  ,;
			SCR->CR_TOTAL			   ,;
			SCR->CR_NIVEL              ,;
			SCR->CR_STATUS             ,;
			SCR->CR_EMISSAO            ,;
			SCR->CR_XNOMFOR            ,;
			SCR->CR_XCOMSOL            ,;
			SCR->CR_XDESCTP            ,;
			SCR->CR_XDOC               ,;
			SCR->CR_VALLIB             ,;
			SCR->CR_TIPOLIM            ,;
			SCR->CR_MOEDA              ,;
			SCR->CR_ITGRP              ,;
			SCR->CR_USER               ,;
			SCR->CR_XNOME   		   ,;
			SCR->CR_APROV              ,;
			SAK->AK_USER               ,;
			SAK->AK_COD                })
			
			Reclock("SCR",.T.)
			SCR->CR_FILIAL 	:= aSCR[1][1]
			SCR->CR_NUM 	:= aSCR[1][2]
			SCR->CR_TIPO 	:= aSCR[1][3]
			SCR->CR_GRUPO 	:= aSCR[1][4]
			SCR->CR_XFORNEC := aSCR[1][5]
			SCR->CR_XNOME 	:= aSCR[1][6]  
			SCR->CR_TOTAL	:= aSCR[1][7]
			SCR->CR_NIVEL 	:= aSCR[1][8]
			SCR->CR_STATUS 	:= aSCR[1][9]
			SCR->CR_EMISSAO	:= aSCR[1][10]
			SCR->CR_XNOMFOR	:= aSCR[1][11]
			SCR->CR_XCOMSOL := aSCR[1][12]
			SCR->CR_XDESCTP	:= aSCR[1][13]
			SCR->CR_XDOC 	:= aSCR[1][14]
			SCR->CR_TIPOLIM := aSCR[1][16]
			SCR->CR_MOEDA   := aSCR[1][17]
			SCR->CR_USERORI := aSCR[1][19]
			SCR->CR_XAPRO   := aSCR[1][20]
			SCR->CR_APRORI  := aSCR[1][21]
			SCR->CR_USER    := aSCR[1][22]
			SCR->CR_APROV   := aSCR[1][23]
			SCR->(MsUnlock())
			Endif	  
		Endif
		  
	Endif

	RestArea(cAreaSAK)

Return NIl
