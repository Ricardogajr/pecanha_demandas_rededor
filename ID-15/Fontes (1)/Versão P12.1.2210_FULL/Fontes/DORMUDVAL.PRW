#INCLUDE "RWMAKE.CH"
#Include "Protheus.ch"

/*================================================================================================================================================ 
//  Funcao alterar o valor importado do txt qdo for 0 para 0.01 para calculo do saldo do VT ( DorSaldoVT )  
@author     A.Shibao
@since      17/01/17
@param		
@version    P12
@return      
@project 
@client    RedeDor     
//================================================================================================================================================*/
User Function DorMudVal(cDpr) 

Private cDePara := ''

If VAL(alltrim(cDpr)) == 0
	cDePara := 0.01
Else
	cDePara := cDpr
Endif

Return(cDePara)
