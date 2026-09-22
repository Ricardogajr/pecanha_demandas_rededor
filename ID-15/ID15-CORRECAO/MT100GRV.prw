#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT100GRV
Está localizado na função a103Grava responsável pela gravação da Nota Fiscal.  Executado antes de iniciar o processo de gravação / exclusão de Nota de Entrada.
@type function
@version  P2410
@author Ricardo Junior
@since 7/21/2026
@return variant, lret
/*/
User Function MT100GRV()
	Local lDeleta := PARAMIXB[1]
	Local lFilSimp := U_VALSIMP(cFilAnt)
	Local lRet := .T.

	if lDeleta .And. lFilSimp
		if TitNFEBX(SF1->F1_FILIAL, SF1->F1_DOC, SF1->F1_FORNECE, SF1->F1_LOJA, SF1->F1_SERIE)
			Help( , , "Help", , "O Título esta em borderô ou já foi baixado. Não será possível a exclusão ou estorno do mesmo.", 1, 0)
			lRet := .F.
		else
			U_EXCTITNFE(SF1->F1_FILIAL, SF1->F1_DOC, SF1->F1_FORNECE, SF1->F1_LOJA, SF1->F1_SERIE)
		endif
	endif

Return lRet

/*/{Protheus.doc} GetTitulo
Verifica se o titulo já foi baixado ou esta em bordero.
@type function
@version P2410 
@author Ricardo Junior
@since 7/21/2026
@param cFil, character, Filial
@param cNum, character, Numero da nota
@param cFornece, character, Fornecedor
@param cLoja, character, Loja
@param cPrefixo, character, prefixo
@return variant, lret
/*/
Static Function TitNFEBX(cFil, cNum, cFornece, cLoja, cPrefixo)

	Local cAliasE2 := GetNextAlias()
	Local lRet := .F.
	Local cQuery := ""

	cQuery := " SELECT E2_FILIAL, E2_NUM, E2_PREFIXO, E2_PARCELA, E2_FORNECE, E2_LOJA, E2_NUMBOR, E2_BAIXA FROM " + RetSqlName("SE2") + " SE2 " + CRLF
	cQuery += " WHERE D_E_L_E_T_ = ' ' "  + CRLF
	cQuery += " AND E2_FILIAL = '"+cFil+"'"  + CRLF
	cQuery += " AND E2_NUM = '"+cNum+"'"  + CRLF
	cQuery += " AND E2_FORNECE = '"+cFornece+"'"  + CRLF
	cQuery += " AND E2_LOJA = '"+cLoja+"'"  + CRLF
	cQuery += " AND E2_PREFIXO = '"+cPrefixo+"'"  + CRLF
	cQuery += " AND E2_TIPO = 'NFE'"  + CRLF

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAliasE2, .T., .T.)

	if (cAliasE2)->(!Eof())
		if !Empty((cAliasE2)->E2_NUMBOR) .Or. !Empty((cAliasE2)->E2_BAIXA)
			lRet := .T.
		endif
	endif

Return lRet
