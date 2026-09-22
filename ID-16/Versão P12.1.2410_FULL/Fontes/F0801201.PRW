#INCLUDE "PROTHEUS.CH"
/*
{Protheus.doc} F0801201()
Grava as informações na tabela PAL no momento da inclusão/aprovação de solicitações
@Author		Nairan Alves
@Since		27/03/2018
@Version	P12.7
@Project    
@Return	 Nil
*/
User Function F0801201(cFilApr, cMatApr, cFilSol, cCodSol, nNvlAlc, cCodAlc )

	Local cAliRh4 := "RETRH4"
	Local cPosto  := ""
	Local cMatri  := ""
	Local cNome   := ""
	Local cQuery  := ""
	Local cPostApr := ""

	Default cFilApr   := ""
	Default cMatApr := ""

	PA9->(DbSetOrder(2))

	If PAC->(DbSeek(xFilial("PAC")+ cCodAlc + PADL(cValToChar(nNvlAlc),2,"0")))
		If PA9->(DbSeek(xFilial("PA9")+ PAC->PAC_CODPOS + cFilSol))
			While PA9->(PA9_FILIAL + PA9_CODIGO + PA9_FILSOL)== xFilial("PA9")+ PAC->PAC_CODPOS + cFilSol
				cPostApr += "RCX.RCX_FILIAL ='"+PA9->PA9_FILAPR+"' AND RCX.RCX_POSTO = '"+PA9->PA9_POSAPR+"' " 
				cPostApr += " OR "
				PA9->(DbSkip())
			EndDo	
		EndIf
	EndIf
	
	cPosto := POSICIONE("SRA",1,cFilApr + cMatApr,"RA_POSTO")
	
	cPostApr += "RCX.RCX_FILIAL ='"+cFilApr+"' AND RCX.RCX_POSTO = '"+cPosto+"' " 

	cQuery := "SELECT SRA.RA_FILIAL, "
	cQuery += "       SRA.RA_MAT, "
	cQuery += "       SRA.RA_NOME "
	cQuery += "FROM " + RetSqlName("RCX") + " RCX "
	cQuery += "INNER JOIN " + RetSqlName("SRA") + " SRA  "
	cQuery += "ON SRA.RA_FILIAL = RCX.RCX_FILIAL "
	cQuery += "AND SRA.RA_MAT = RCX.RCX_MATFUN "
	cQuery += "AND SRA.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE ("+cPostApr+")"
	cQuery += "  AND RCX.RCX_SUBST = '2' "
	cQuery += "  AND RCX.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliRh4)

	DbSelectArea(cAliRh4)
	While ! (cAliRh4)->(EOF())
		RecLock("PAL",.T.)
			PAL->PAL_MATAPR	:= (cAliRh4)->(RA_MAT)
			PAL->PAL_FILSOL	:= cFilSol 
			PAL->PAL_NUMSOL	:= cCodSol
			PAL->PAL_NIVSOL	:= PADL(cValToChar(nNvlAlc),2,"0")
		PAL->(MsUnLock())
		(cAliRh4)->(DbSkip())
	End
	(cAliRh4)->(DbCloseArea())

Return 
