//-----------------------------------------------------------------------
/*/{Protheus.doc} F0501702
Valida se o usuário possui ou não direito de alteração de registros gerados via integração ApData
 
@author Nairan Alves Silva
@since  07/12/2017
@return Nil  

@project MAN0000007423048_EF_019
@cliente Rededor
@version P12.1.7
             
/*/
//-----------------------------------------------------------------------
User Function F0501702(cIdUser)

Local cQuery	:= ""
Local cNewAlias	:= GetNextAlias()
Local lRet		:= .F.

cQuery := " SELECT RCC_SEQUEN "
cQuery += " FROM " + RetSqlName("RCC") + " "
cQuery += " WHERE RCC_CODIGO = 'U015' "
cQuery += " AND RCC_CONTEU LIKE '%"+cIdUser+"%' "
cQuery += " AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TCGenQry( ,,cQuery ), cNewAlias, .F., .T.)
		
If (cNewAlias)->(!EOF())
	lRet := .T.
EndIf

(cNewAlias)->(DbCloseArea())

Return lRet