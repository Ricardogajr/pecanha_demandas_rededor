#INCLUDE "TOTVS.CH"

//-----------------------------------------------------------------------
/*/{Protheus.doc} F0600601
Grava PA6 com dados do Alias informado
 
@author Eduardo Fernandes 
@since  19/12/2016
@param cFilTab, characters, descricao
@param cAliasTab, characters, descricao
@param cChavTab, characters, descricao
@param nRecTab, numeric, descricao
@param cOper, characters, descricao
@param cFunc, characters, descricao
@return Nil  

@project MAN0000007423040_EF_006
@cliente Rededor
@version P12.1.7
             
/*/

User Function F0600601(cFilTab, cAliasTab, cChavTab, nRecTab, cOper, cFunc)
Default cFunc := "F0600601"

	U_F0600901(cFunc,; // cFunc 
			nRecTab,; // nRecno 
			cAliasTab,; // cAliasTrb 
			cFilTab + cChavTab,; // cChave 
			"",; // cObs
			CTOD(""),; // Data de envio
			cOper,; // Operacao
			cFilTab) // Filial da Solicitação
			
	StartJob("U_F0600103",GetEnvServer(),.F.,{"01",xFilial("PA6")})
					
Return Nil
