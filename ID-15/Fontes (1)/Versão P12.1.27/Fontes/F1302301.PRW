#Include 'Protheus.ch'

/*
{Protheus.doc} F1302301()
Gravação da chave na tabela RH3
@Author     Bruno de Oliveira
@Since      26/12/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_023
*/
User Function F1302301()
	
	Local cQueryChv := ""
	Local cAlias1   := ""
	Local nCnt      := 0
	
	DbSelectArea("RH3")
	RH3->(DbSetOrder(1))
	RH3->(DbGoTop())
	While RH3->(!EOF())
		
		If Empty(RH3->RH3_XCHAVE)
			cAlias1 := GetNextAlias()
			
			cQueryChv := "SELECT RD4_CHAVE "
			cQueryChv += "FROM " + RetSqlName("RCX") + " RCX "
			cQueryChv += "INNER JOIN " + RetSqlName("RD4") + " RD4 ON(RD4.RD4_FILIDE = RCX.RCX_FILIAL AND "
			cQueryChv += "RD4.RD4_CODIDE = RCX.RCX_POSTO AND RD4.D_E_L_E_T_ = ' ') "
			cQueryChv += "WHERE RCX.RCX_FILFUN = '" + RH3->RH3_FILINI  + "' AND "
			cQueryChv += "RCX.RCX_MATFUN = '" + RH3->RH3_MATINI + "' AND "
			cQueryChv += "RD4.RD4_CODIGO = '" + RH3->RH3_VISAO + "' AND "
			cQueryChv += "RCX.D_E_L_E_T_ = ' '"
			
			cQueryChv := ChangeQuery(cQueryChv)
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryChv),cAlias1,.T.,.T.)
			
			If !(cAlias1)->(EOF())
				RecLock("RH3",.F.)
				RH3->RH3_XCHAVE := (cAlias1)->RD4_CHAVE
				RH3->(MsUnLock())
				nCnt := nCnt + 1
			EndIf
			
			(cAlias1)->(DbCloseArea())
		EndIf
		
		RH3->(DbSkip())
	End
	
	If nCnt > 0
		MsgAlert("Registro(s) Processado(s)")
	EndIf
	
Return

/*
{Protheus.doc} F1302302()
Gravação da visão na tabela RH3
@Author     Bruno de Oliveira
@Since      27/12/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_023
*/
User Function F1302302()
	
	Local cQuery  := ""
	Local cAlias1 := ""
	Local nCnt    := 0
	
	DbSelectArea("RH3")
	RH3->(DbSetOrder(1))
	RH3->(DbGoTop())
	While RH3->(!EOF())
		
		If Empty(RH3->RH3_VISAO)
			cAlias1 := GetNextAlias()
			
			cQuery := "SELECT PAB_VISAO "
			cQuery += "FROM " + RetSqlName("PAB") + " PAB "
			cQuery += "WHERE PAB.PAB_CODIGO = '" + RH3->RH3_XCODAL + "' AND "
			cQuery += "PAB.D_E_L_E_T_ = ' '"
			
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1,.T.,.T.)
			
			If !(cAlias1)->(EOF())
				RecLock("RH3",.F.)
				RH3->RH3_VISAO := (cAlias1)->PAB_VISAO
				RH3->(MsUnLock())
				nCnt := nCnt + 1
			EndIf
			
			(cAlias1)->(DbCloseArea())
		EndIf
		
		RH3->(DbSkip())
	End
	
	If nCnt > 0
		MsgAlert("Registro(s) Processado(s)")
	EndIf
	
Return