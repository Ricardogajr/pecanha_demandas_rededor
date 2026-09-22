#include 'protheus.ch'

/*{Protheus.doc} ConvUM
Função para tratamento da unidade de medida, quando B1_UM (unidade de consumo) 
for diferente de B1_XTERUM (unidade de estoque), porque na RDSL foi convencionado 
que a conversão padrão é da unidade de compra (B1_SEGUM) para a unidade de estoque (B1_XTERUM), 
então quando unidade de consumo for diferente de unidade de estoque, temos que converter 
primeiro de B1_SEGUM para B1_XTERUM e na sequencia converter de B1_XTERUM para B1_UM 
ou vice-versa quando o campo digitado for da 2ª. unidade de medida.

@author 
@since 15/12/2017
@project Rede Dor
@return NIL
*/

User Function ConvUM()
           
Local nQtd1 := PARAMIXB[1]	//Quantidade na 1ª Unidade Medida
Local nQtd2 := PARAMIXB[2]	//Quantidade na 2ª Unidade Medida
Local nUnid := PARAMIXB[3]	//Indica se é a Unidade de Medida "1 ou 2"
Local nQtd  := PARAMIXB[4]	//Quantidade já convertida podendo ser tratada
Local nRet := nQtd
Local aArea := GetArea()
           
If SB1->B1_UM <> SB1->B1_XTERUM 

	If nUnid == 2	
		//Converter primeiro de consumo para estoque
		If SB1->B1_XTCONV2 == "M"	
			nRet := nQtd1 * SB1->B1_XCONV2  
		ElseIf SB1->B1_XTCONV2 == "D"	
			nRet := nQtd1 / SB1->B1_XCONV2	
		EndIf
	
		//Converter depois de estoque para compra
		If SB1->B1_TIPCONV == "M"
			nRet := nRet * SB1->B1_CONV
		ElseIF SB1->B1_TIPCONV == "D"
			nRet := nRet / SB1->B1_CONV
		EndIf
		
	ElseIf nUnid == 1
		//Converter primeiro de compra para estoque
		If SB1->B1_TIPCONV == "M"
			nRet := nQtd2 / SB1->B1_CONV
		ElseIf SB1->B1_TIPCONV == "D"
			nRet := nQtd2 * SB1->B1_CONV
		EndIf 
		
		//Converter depois de estoque para consumo
		If SB1->B1_XTCONV2 == "M"	
			nRet := nRet / SB1->B1_XCONV2	
		ElseIf SB1->B1_XTCONV2 == "D"	
			nRet := nRet * SB1->B1_XCONV2	
		EndIf
	EndIf

EndIf

RestArea(aArea)

Return nRet