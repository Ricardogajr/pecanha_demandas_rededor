/*/{Protheus.doc} MT103BDP
Bloqueia ou não o acols de duplicatas na geração de NF
@author 	Lucas Miranda de Aguiar
@since 		18/03/2021
@version 	1.0
@param
@param
@return	lógico
/*/

User Function MT103BDP()


	Local lRet := .F.
	 
	lRet := U_CKDUPFIX()// Função criada para verificar se o fornecedor é data fixa e se o usuário pode alterar a duplicata

Return lret

