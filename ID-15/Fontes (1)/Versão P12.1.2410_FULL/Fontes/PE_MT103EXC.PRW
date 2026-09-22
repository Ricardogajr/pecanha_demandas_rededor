#include "totvs.ch"

/*/{Protheus.doc} MT103EXC
Valida exclusão do documento de entrada.
@type User function
@author anieli.rodrigues
@since 20/02/2017
@version 12.7
@project MAN0000007423041_EF_033
@return lRet
/*/

User Function MT103EXC()

	Local lRet	    := .T.
	Local lFilSimp  := U_VALSIMP(cFilAnt)
	Local aArea	    := GetArea()
	Local cAliasSC7 := GetNextAlias()
	Local cQuery    := ""

	if lFilSimp
		//Se for da rotina automatica de carga de titulos, retorna true.
		if FWIsInCallStack("U_RDCAR02") .Or.  FWIsInCallStack("U_S0100401") .Or. FWIsInCallStack("U_F010101A")  .Or. FwIsInCallStack("MATA094")  .Or. FwIsInCallStack("U_XMATA094")
			Return .T.
		endif

		cQuery += " SELECT Count(C7_XDOC) PEDIDOS"
		cQuery += " FROM " + RetSqlName("SC7")
		cQuery += " WHERE C7_XDOC  = '" + SF1->F1_DOC + "'"
		cQuery += " AND C7_XSERIE  = '" + SF1->F1_SERIE + "'"
		cQuery += " AND C7_FORNECE = '" + SF1->F1_FORNECE + "'"
		cQuery += " AND C7_LOJA    = '" + SF1->F1_LOJA + "'"
		cQuery += " AND C7_XTPSP    != '1'"
		cQuery += " AND D_E_L_E_T_ = ''"

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAliasSC7, .T., .T.)

		If (cAliasSC7)->(PEDIDOS) > 0
			Help(,,'EXTERNO',,'Não é possível realizar a exclusão manual de documentos originados pela Solicitação de pagamento de materiais',1,0)
			lRet := .F.
		EndIf

		(cAliasSC7)->(DbCloseArea())
		RestArea(aArea)

	else
		lRet := U_F0703303()
	endif

Return lRet

