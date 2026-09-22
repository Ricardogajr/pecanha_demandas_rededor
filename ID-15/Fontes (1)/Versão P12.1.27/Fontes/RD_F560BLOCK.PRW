#Include 'Protheus.ch' 

/*
{Protheus.doc}  F560BLOCK 
Ponto de entrada para validar se existe título em aberto para repor a despesa em questão 
@Author  Ramon Teodoro e Silva	
@Since   22/08/2018       
@Version P12.7
*/

User Function F560BLOCK()

Local lRet   := .F.
Local cCaixa := SEU->EU_CAIXA 
Local aArea  := GetArea()
Local cQuery := ""
Local cAliasCx 	:= GetNextAlias()

If !Empty(SEU->EU_XNUMTIT) 

	cQuery := "SELECT R_E_C_N_O_ RECCX FROM " + RetSqlName("SE2")
	cQuery += " WHERE E2_FILIAL = '" + xFilial("SE2") + "' AND E2_XCAIXIN = '" + cCaixa + "' AND "
	cQuery += " E2_SALDO > 0 AND D_E_L_E_T_ = ''"
	cQuery := ChangeQuery( cQuery ) 
	
	If Select(cAliasCx) > 0
		(cAliasCx)->(DbCloseArea())
	EndIf
				
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCx,.F.,.T.)
	
	If (cAliasCx)->(!Eof())
		MsgStop("Não é possível cancelar essa despesa, já existe um título a pagar para reposição deste caixinha.")
		lRet   := .T.
	EndIf

	(cAliasCx)->(DbCloseArea())

EndIf

RestArea(aArea)

Return lRet

