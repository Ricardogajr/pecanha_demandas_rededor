#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} fBuscaSolic
Valida se a solicitação de compras já existe no sistema.
@type function
@author Ricardo Junior
@since 17/07/2017
@version 1.0
@return lRet .T. valido, .F. não valido.
/*/
*-----------------------------------------------*
User Function fBuscaSolic(cChave, cIdBio)
*-----------------------------------------------*
	
	Local lRet 		:= .F.
	Local aArea		:= GetArea()
	Local cAliasSC1 := GetNextAlias()
	Local cQuery	:= ""
	
	cQuery += " SELECT C1_FILIAL " + CRLF
	cQuery += " ,C1_NUM " 		+ CRLF
	cQuery += " ,C1_ITEM " 		+ CRLF
	cQuery += " ,D_E_L_E_T_ " 	+ CRLF
	cQuery += " ,R_E_C_N_O_ " 	+ CRLF
	cQuery += " FROM "+ RetSqlName("SC1") +" SC1 " 	+ CRLF
	cQuery += " WHERE SC1.D_E_L_E_T_ = ' '" 			+ CRLF
	cQuery += " AND CONCAT(CONCAT(SC1.C1_FILIAL, SC1.C1_NUM), SC1.C1_ITEM) = '" + cChave + "'" 	+ CRLF
	cQuery += " AND SC1.C1_XIDBIO = '"+ cIdBio +"' " 	+ CRLF
	cQuery += " AND SC1.C1_QUJE < SC1.C1_QUANT " 	+ CRLF
	
	U_WsLogBio("fBuscaSolic - QUERY PARA VALIDAR SE A SOLICITACAO ESTA INTEGRADA", 1, cQuery)
	
	DbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC1,.T.,.T. )
		
	If !(cAliasSC1)->(Eof())
		lRet := .T.
	EndIf
	
	RestArea(aArea)
	
Return lRet