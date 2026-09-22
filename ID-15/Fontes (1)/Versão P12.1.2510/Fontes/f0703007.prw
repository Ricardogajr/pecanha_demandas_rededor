/*{Protheus.doc} F0703007
Não permite a execução do custo médio MATA330
@author Nairan Alves Silva
@since 14/03/2018
@version 1.0
@Project 
@return LOGICO
*/
User Function F0703007()
	Local lRet	:= .F.
	
	Alert("Não é possíbel utilizar a rotina de cálculo de custo médio (MATA330). Para contabilização, utilize a rotina MATA331.")

Return lRet