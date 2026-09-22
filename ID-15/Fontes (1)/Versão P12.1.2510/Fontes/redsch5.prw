#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} REDSCH5
//TODO Schedule responsável por executar função que envia email de pedidos de sp que estão pendentes de aprovação.
//Envia por filial.
@author Ricardo Junior
@since 17/07/2019
@version 1.0
@return Nil
@type function
/*/
User Function REDSCH5(aEmpFil)
	U_ENVMAILPC(aEmpFil[2])
Return