#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} F1300302
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 18/10/2017
@version 6
@project MAN0000007423048_EF_003
@param cTree, characters, tree da pessoa no RD4
@param cVisao, characters, Visão informado nos parametros
@return cGeren, characters, Nome dos responsaveis pelo posto
@type function
/*/
user function F1300302(cTree, cVisao)
	//Criar rotina que busca concatenado os nomes dos gestores imediatos 
	Local cGeren := "VAZIO"
	Local cAliasAux := "TMPAUX"
	Local cQuery := ""

	Default cFilSoli := ""
	Default cMatSoli := ""
	Default cVisao := ""

	cQuery := "SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME FROM " + RETSQLNAME('SRA') + " SRA "
	cQuery += "WHERE SRA.D_E_L_E_T_ = ' ' "
	cQuery += "AND SRA.RA_FILIAL IN ( "
	cQuery += "	SELECT RCX.RCX_FILFUN FROM " + RETSQLNAME('RCX') + " RCX   "
	cQuery += "	WHERE RCX.D_E_L_E_T_ = ' '  "
	cQuery += "	AND RCX.RCX_FILIAL = ( "
	cQuery += "		SELECT RD4A.RD4_FILIDE FROM " + RETSQLNAME('RD4') + " RD4A WHERE RD4A.D_E_L_E_T_ = ' ' AND RD4A.RD4_ITEM = '" + cTree + "' "
	cQuery += "		AND RD4A.RD4_CODIGO = '" + cVisao + "') "
	cQuery += "	AND  RCX.RCX_POSTO = ( "
	cQuery += "		SELECT RD4_CODIDE FROM " + RETSQLNAME('RD4') + " RD4B WHERE RD4B.D_E_L_E_T_ = ' ' AND RD4B.RD4_ITEM = '" + cTree + "' "
	cQuery += "		AND RD4B.RD4_CODIGO = '" + cVisao + "')) "
	cQuery += "AND SRA.RA_MAT IN ( "
	cQuery += "	SELECT RCX.RCX_MATFUN FROM " + RETSQLNAME('RCX') + " RCX   "
	cQuery += "	WHERE RCX.D_E_L_E_T_ = ' '  "
	cQuery += "	AND RCX.RCX_FILIAL = ( "
	cQuery += "		SELECT RD4A.RD4_FILIDE FROM " + RETSQLNAME('RD4') + " RD4A WHERE RD4A.D_E_L_E_T_ = ' ' AND RD4A.RD4_ITEM = '" + cTree + "' "
	cQuery += "		AND RD4A.RD4_CODIGO = '" + cVisao + "') "
	cQuery += "	AND  RCX.RCX_POSTO = ( "
	cQuery += "		SELECT RD4_CODIDE FROM " + RETSQLNAME('RD4') + " RD4B WHERE RD4B.D_E_L_E_T_ = ' ' AND RD4B.RD4_ITEM = '" + cTree + "' "
	cQuery += "		AND RD4B.RD4_CODIGO = '" + cVisao + "') "
	cQuery += ") "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAux)


	While (cAliasAux)->(!(EOF()))
		If !(EMPTY(cGeren))
			cGeren += ", " + ALLTRIM((cAliasAux)->RA_NOME)
		Else
			cGeren += ALLTRIM((cAliasAux)->RA_NOME)
		EndIf
		(cAliasAux)->(DbSkip())
	End
	(cAliasAux)->(DbCloseArea())

return cGeren