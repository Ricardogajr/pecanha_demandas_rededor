#INCLUDE "Protheus.ch"
                                    
/*
{Protheus.doc}  MT120FOL()
Ponto de entrada chamado na montagem dos Folders da tela do Pedido de Compra, usado para incluir o campo de Desconto Financeiro
@Author  Ramon Teodoro e Silva	
@Since   17/04/2017       
@Version P12.7
*/

User Function MT120FOL() 

Local aArea    := GetArea()
Local lRet     := .T.
Local nOpc     := PARAMIXB[1]
Local aPosGet  := PARAMIXB[2]
Local cNumPed  := SC7->C7_NUM
Local nDescF   := 0

Public nXDesFin := 0 

If nOpc <> 3
	nXDesFin := SC7->C7_XDESFIN
EndIf 

@ 027,aPosGet[9,1] SAY OemToAnsi('Desc. Financeiro:') OF oFolder:aDialogs[4] PIXEL SIZE 048,009
@ 026,aPosGet[9,2] MSGET nXDesFin PICTURE PesqPict('SC7','C7_XDESFIN') OF oFolder:aDialogs[4] PIXEL SIZE 030,009 HASBUTTON
@ 027,aPosGet[9,3] SAY '%'        OF  oFolder:aDialogs[4] PIXEL SIZE 011,009 
                
RestArea(aArea)   
Return lRet


