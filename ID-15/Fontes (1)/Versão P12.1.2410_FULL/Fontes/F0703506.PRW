/*{Protheus.doc} F0703506
Caso TM não seja valorizada, força o valor 0 no custo do produto.
@author Nairan Alves Silva
@since 14/03/2018
@version 1.0
@Project 
@return LOGICO
*/

User Function F0703506()
	Local aAreaSF5	:= SF5->(GetArea())
	Local aAreaSD3	:= SD3->(GetArea())
	
	If SF5->(DbSeek(xFilial("SF5") + SD3->D3_TM))
		If SF5->F5_VAL = "N"
			RecLock("SD3",.F.)
			SD3->D3_CUSTO1	:= 0
			SD3->D3_CUSTO2	:= 0
			SD3->D3_CUSTO3	:= 0
			SD3->D3_CUSTO4	:= 0
			SD3->D3_CUSTO5	:= 0
			SD3->(MsUnlock())
		EndIf
	EndIf
	
	RestArea(aAreaSF5)
	RestArea(aAreaSD3)
Return