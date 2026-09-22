#include "protheus.ch"
/*/{Protheus.doc} FEXTITNFE
Função responsável por excluir os titulos de legado NFE do simplificado.
@type function
@version P122410
@author ricar
@since 7/15/2026
@param cFil, character, Filial
@param cNum, character, Numero
@param cFornece, character, Fornecedor
@param cLoja, character, Loja
@param cPrefixo, character, Prefixo
@return variant, return_description
/*/
User Function EXCTITNFE(cFil, cNum, cFornece, cLoja, cPrefixo)
	Local lFilSimp := U_VALSIMP(cFilAnt)
	Local cAliasE2 := GetNextAlias()
    
    Private lMsErroAuto := .F.

	Default cChavE2 := ""

	if lFilSimp
		cQuery := " SELECT E2_FILIAL, E2_NUM, E2_PREFIXO, E2_PARCELA, E2_FORNECE, E2_LOJA FROM " + RetSqlName("SE2") + " SE2 " + CRLF
		cQuery += " WHERE D_E_L_E_T_ = ' ' "  + CRLF
		cQuery += " AND E2_FILIAL = '"+cFil+"'"  + CRLF
		cQuery += " AND E2_NUM = '"+cNum+"'"  + CRLF
		cQuery += " AND E2_FORNECE = '"+cFornece+"'"  + CRLF
		cQuery += " AND E2_LOJA = '"+cLoja+"'"  + CRLF
		cQuery += " AND E2_PREFIXO = '"+cPrefixo+"'"  + CRLF
		cQuery += " AND E2_TIPO = 'NFE'"  + CRLF

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAliasE2, .T., .T.)

		While !(cAliasE2)->(Eof()) 
			aExcTit := {}
			AAdd(aExcTit,{"E2_NUM" 		,(cAliasE2)->E2_NUM		,NIL})
			AAdd(aExcTit,{"E2_PREFIXO"	,(cAliasE2)->E2_PREFIXO	,NIL})
			AAdd(aExcTit,{"E2_PARCELA"	,(cAliasE2)->E2_PARCELA	,NIL})
			AAdd(aExcTit,{"E2_TIPO"		,"NFE"			    	,NIL})
			AAdd(aExcTit,{"E2_FORNECE"	,(cAliasE2)->E2_FORNECE	,NIL})
			AAdd(aExcTit,{"E2_LOJA"		,(cAliasE2)->E2_LOJA	,NIL})

			MsExecAuto({|x,y,z| FINA050(x,y,z)},aExcTit,,5)

			If lMsErroAuto
				MostraErro()
			EndIf
			(cAliasE2)->(DbSkip())
		EndDo
	EndIf

    (cAliasE2)->(DbCloseArea())

Return
