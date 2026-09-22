#Include 'Protheus.ch'
#include "TBICONN.CH"

/*{Protheus.doc} F1301112
Função chamada no Job, que seleciona os registros da RH3
@project	MAN0000007423048_EF_011
@author 	bruno.rosa
@since 		23/11/2017
@return 	${return}, ${return_description}
@param		aParam, array, Empresa e Filial
 
*/
User Function F1301112(aParam)
	
	Local cQuery 	:= ""
	Local cAlias1	:= GetNextAlias()
	Local cEmpIni   := IIF(ValType(aParam) == "A", aParam[1], cEmpAnt)
	Local cFilIni   := IIF(ValType(aParam) == "A", aParam[2], cFilAnt)
	Local lOk		:= .F.
	Local dDtAtual  := Date()
	
	Default aParam := {'01', '01010002'}
	
	// Verifica se já existe um Job em execução com o mesmo nome.
	If !LockByName("F1301112_" + cEmpIni, .F. ,.F.)
		Conout("F1301112 - Ja existe um Job com mesmo nome em execucao!")
	Else
		If !RpcSetEnv( cEmpIni, cFilIni,,,"GPE",, /*aFiles*/ )
			Conout("F1301112 - Nao foi possivel inicializar o ambiente.")
		Else	
			dDtAtual  := dDatabase
			cQuery := " SELECT PAJ_FILIAL, PAJ_CODIGO, PAJ_FILSUB, PAJ_MATSUB, PAJ_FILFUN, PAJ_MATFUN"
			cQuery += " FROM " + RetSqlName("PAJ") + " PAJ"
			cQuery += " WHERE PAJ_STATUS = '1' AND"
			cQuery += " PAJ.PAJ_DTINI <= '" + DTOS(dDtAtual) + "' AND"
		    cQuery += " (PAJ.PAJ_DTFIM >= '" + DTOS(dDtAtual) + "' OR PAJ.PAJ_DTFIM >= '        ') " 
			cQuery += " AND PAJ.D_E_L_E_T_ = ' ' "
			cQuery += " ORDER BY PAJ_FILIAL, PAJ_CODIGO "
			
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T., "TOPCONN", TCGenQry( ,,cQuery ), cAlias1, .F., .T.)
			
			While !(cAlias1)->(Eof())
			
				cAlias2	:= GetNextAlias()
					
				Begin Transaction
					
					cQuery2 := " SELECT RH3_FILIAL, RH3_CODIGO"
					cQuery2 += " FROM " + RetSqlName("RH3") + " RH3"
					cQuery2 += " WHERE RH3_STATUS = '1' AND"
					cQuery2 += " RH3.RH3_XTPCTM <> ' ' AND"
					cQuery2 += " RH3.RH3_FILAPR = '" + (cAlias1)->(PAJ_FILSUB) + "' AND"
				    cQuery2 += " RH3.RH3_MATAPR = '" + (cAlias1)->(PAJ_MATSUB) + "' " 
					cQuery2 += " AND RH3.D_E_L_E_T_ = ' ' "
					cQuery2 += " ORDER BY RH3_FILIAL, RH3_CODIGO "
					
					cQuery2 := ChangeQuery(cQuery2)
					dbUseArea(.T., "TOPCONN", TCGenQry( ,,cQuery2 ), cAlias2, .F., .T.)
							
					While !(cAlias2)->(Eof())
					
						aAreaRh3 := RH3->(GetArea())
						
						RH3->(DbSetOrder(1))
						If RH3->(DbSeek((cAlias2)->RH3_FILIAL+(cAlias2)->RH3_CODIGO))
							RecLock("RH3",.F.)
							RH3->RH3_FILAPR := (cAlias1)->(PAJ_FILFUN)
							RH3->RH3_MATAPR := (cAlias1)->(PAJ_MATFUN)
							RH3->RH3_XSUBST := "S"
							RH3->RH3_XFILSU := (cAlias1)->(PAJ_FILSUB)
							RH3->RH3_XMATSU := (cAlias1)->(PAJ_MATSUB)
							RH3->(MsUnLock())
							lOk := .T.
						EndIf
					
					(cAlias2)->(dbSkip())				
					End
					  
					If lOk 
						PAJ->(DbSetOrder(1))
						If PAJ->(DbSeek((cAlias1)->PAJ_FILIAL+(cAlias1)->PAJ_CODIGO))
							RecLock("PAJ",.F.)
							PAJ->PAJ_STATUS := "2" //Ativo
							PAJ->(MsUnLock())
						EndIf
					EndIf

				End Transaction	
			
			(cAlias1)->(dbSkip())				
			End
			
			RpcClearEnv() // Desconecta ambiente.
			
		EndIf
		
		UnLockByName("F1301112_" + cEmpIni, .F., .F.)
		
	EndIf
	
Return