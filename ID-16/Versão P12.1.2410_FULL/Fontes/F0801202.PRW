#INCLUDE "PROTHEUS.CH"
/*
{Protheus.doc} F0801202()
Atualiza tabela PAL para preencher as informações dos aprovadores das solicitações em aberto.
@Author		Nairan Alves
@Since		27/03/2018
@Version	P12.7
@Project    
@Return	 Nil
*/

User Function F0801202( )
	Local bAcao := {|lFim| AtuPAL(@lFim) }
		
	If MsgYesNo("Deseja atualizar os registros de alçada? Ao confirmar, o sistema entenderá que o novo processo de aprovação já está em produção","Atenção")
		Processa( bAcao, "Atualização de Aprovadores", "Atualizando registros", .T.)
	EndIf
	
Return

Static function AtuPAL(lFim)
	Local cQuery 	:= ""
	Local nCont		:= 0
	Local cAliRH3	:= "ALIASRH3"

	cQuery := "	SELECT RH3_FILAPR, RH3_MATAPR, RH3_FILIAL, RH3_CODIGO, RH3_NVLAPR, RH3_XCODAL " 
	cQuery += " FROM " + RetSqlName("RH3") + " RH3 "
	cQuery += " WHERE RH3_STATUS = '1' "
	cQuery += " AND D_E_L_E_T_ = ' ' "	
	cQuery += " ORDER BY RH3_FILIAL, RH3_CODIGO "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliRH3)

	DbSelectArea(cAliRH3)
	
	ProcRegua((cAliRH3)->(RecCount()))

	Begin Transaction	
		While ! (cAliRH3)->(EOF())

			IncProc('Solicitação:' + (cAliRH3)->RH3_FILIAL + " - " + (cAliRH3)->RH3_CODIGO)
			If lFim
				DisarmTransaction()
				Exit
			EndIf
			U_F0801201((cAliRH3)->RH3_FILAPR, (cAliRH3)->RH3_MATAPR, (cAliRH3)->RH3_FILIAL, (cAliRH3)->RH3_CODIGO, (cAliRH3)->RH3_NVLAPR, (cAliRH3)->RH3_XCODAL)
			nCont++
			(cAliRH3)->(DbSkip())
		End
	End Transaction
	(cAliRH3)->(DbCloseArea())		
	If !lFim
		Aviso('Atualização PAL',"Processo executado com sucesso. "+cValToChar(nCont)+" foram atualizados.", {'OK'}, 1)
	Else
		Aviso('Atualização PAL',"Processo Cancelado.", {'OK'}, 1)	
	EndIf
	
Return
