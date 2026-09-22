#include "totvs.ch"

/*/{Protheus.doc} F0703306
Inserção de filtros adicionais no processamento dos livros fiscais
@type User function
@author anieli.rodrigues
@since 20/02/2017
@version 12.7
@param cAliQry, caractere, alias da query processada pela rotina padrão
@project	MAN0000007423041_EF_033
@return lRet
/*/

User Function F0703306(cAliQry)

	Local lRet := .T. 
	
	If !Empty((cAliQry)->F1_XID)
		Help(,,"EXTERNO",,"Não é possível realizar o reprocessamento da nota fiscal " + (cAliQry)->F1_DOC + ", Série " + (cAliQry)->F1_SERIE + ", Fornecedor " + (cAliQry)->F1_FORNECE + ", Loja " + (cAliQry)->F1_LOJA + " pois este documento foi originado pela integração",1,0)
		lRet := .F. 
	EndIf 
	
Return lRet  