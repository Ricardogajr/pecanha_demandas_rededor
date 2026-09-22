#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
/*
{Protheus.doc} CN121PED()
Ponto de entrada tratamento especifico antes da geração do pedido de compra ou venda
@Author		Ricardo Junior
@Since		15/09/2023
@Version	1.0
*/
User Function CN121PED()
    Local aRet := {}
    aRet := U_F1200718()//Ponto de entrada para tratamento de campos do pedido de compra
Return aRet
 