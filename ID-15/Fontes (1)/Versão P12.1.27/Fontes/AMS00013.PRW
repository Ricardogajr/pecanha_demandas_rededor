#Include 'Protheus.ch'

//////////////////////////////////////////////////////////////////////////////////////////
//+------------------------------------------------------------------------------------+//
//| PROJETO CONECTA REDE DOR    |  MODULO | SIGAGPE                                    |//
//+------------------------------------------------------------------------------------+//
//| PROGRAMA  | AMS00013 | AUTOR | Paulo Dias               | DATA | 12/04/2018        |//
//+------------------------------------------------------------------------------------+//
//| DESCRICAO  | Função: Gravação de registro do CNS nas tabelas correspondentes à SRA |//
//+------------------------------------------------------------------------------------+//
//////////////////////////////////////////////////////////////////////////////////////////


User Function AMS00013()
    Local aArea    := GetArea()
    //Local cQrySRB := "" 
	//Local cAliSRB := GetNextAlias()
	Local cQryRHK := ""
	Local cAliRHK := GetNextAlias()
	Local cQryRHL := ""
	Local cAliRHL := GetNextAlias()
	Local cQryRHM := ""
	Local cAliRHM := GetNextAlias()
	Local cQryRHO := ""
	Local cAliRHO := GetNextAlias()
	
	
	If !EMPTY(SRA->RA_XCNS) .AND. (INCLUI .OR. ALTERA)
		
	/*
		cQrySRB := "SELECT SRB.R_E_C_N_O_ RECNO  "
		cQrySRB += "FROM " + RetSqlName("SRB") + " SRB  " 
		cQrySRB += "INNER JOIN " + RetSqlName("SRA") + " SRA  " 
		cQrySRB += "ON RB_FILIAL = RA_FILIAL  "
		cQrySRB += "AND RB_MAT = RA_MAT "
		cQrySRB += "WHERE SRB.D_E_L_E_T_ = ' '  "
		cQrySRB += "AND SRA.D_E_L_E_T_ = ' '  "•
		cQrySRB += "AND RA_MAT = '" + SRA->RA_MAT + "'"
		
		cQrySRB := ChangeQuery(cQrySRB)

		If Select(cAliSRB) > 0
			DbSelectArea(cAliSRB)
			(cAliSRB)->(DbCloseArea())
		EndIf

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQrySRB),cAliSRB, .F., .T.)
		dbSelectArea(cAliSRB)	

		While (cAliSRB)->(!EOF())
			DbSelectArea("SRB")
			DbSetOrder(1)
			SRB->(DbGoTo((cAliSRB)->RECNO))
			RecLock("SRB",.F.)
			SRB->RB_XCNS := SRA->RA_XCNS
			SRB->(MsUnLock())
			(cAliSRB)->(DbSkip())
		EndDo
	*/
		cQryRHK := "SELECT RHK.R_E_C_N_O_ RECNO  "
		cQryRHK += "FROM " + RetSqlName("RHK") + " RHK  " 
		cQryRHK += "INNER JOIN " + RetSqlName("SRA") + " SRA  " 
		cQryRHK += "ON RHK_FILIAL = RA_FILIAL  "
		cQryRHK += "AND RHK_MAT = RA_MAT "
        cQryRHK += "WHERE RHK.D_E_L_E_T_ = ' '  "
		cQryRHK += "AND SRA.D_E_L_E_T_ = ' '  "
        cQryRHK += "AND RA_MAT = '" + SRA->RA_MAT + "'"
		
        cQryRHK := ChangeQuery(cQryRHK)

		If Select(cAliRHK) > 0
			DbSelectArea(cAliRHK)
			(cAliRHK)->(DbCloseArea())
		EndIf

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryRHK),cAliRHK, .F., .T.)
		dbSelectArea(cAliRHK)	

		While (cAliRHK)->(!EOF())
			DbSelectArea("RHK")
			DbSetOrder(1)
			RHK->(DbGoTo((cAliRHK)->RECNO))
			RecLock("RHK",.F.)
			RHK->RHK_XCNS := SRA->RA_XCNS
			RHK->(MsUnLock())
			(cAliRHK)->(DbSkip())
		EndDo

		cQryRHL := "SELECT RHL.R_E_C_N_O_ RECNO  "
		cQryRHL += "FROM " + RetSqlName("RHL") + " RHL  " 
		cQryRHL += "INNER JOIN " + RetSqlName("SRA") + " SRA  "
        cQryRHL += "ON RA_FILIAL = RHL_FILIAL  "
		cQryRHL += "AND RA_MAT = RHL_MAT " 
		cQryRHL += "WHERE RHL.D_E_L_E_T_ = ' '  "
		cQryRHL += "AND SRA.D_E_L_E_T_ = ' '  "
        cQryRHL += "AND RA_MAT = '" + SRA->RA_MAT + "'"
	  
		cQryRHL := ChangeQuery(cQryRHL)

		If Select(cAliRHL) > 0
			DbSelectArea(cAliRHL)
			(cAliRHL)->(DbCloseArea())
		EndIf

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryRHL),cAliRHL, .F., .T.)
		dbSelectArea(cAliRHL)	

		While (cAliRHL)->(!EOF())
			DbSelectArea("RHL")
			DbSetOrder(1)
			RHL->(DbGoTo((cAliRHL)->RECNO))
			RecLock("RHL",.F.)
			RHL->RHL_XCNS := SRA->RA_XCNS
			RHL->(MsUnLock())
			(cAliRHL)->(DbSkip())
		EndDo
	
		cQryRHM := "SELECT RHM.R_E_C_N_O_ RECNO  "
		cQryRHM += "FROM " + RetSqlName("RHM") + " RHM  " 
		cQryRHM += "INNER JOIN " + RetSqlName("SRA") + " SRA  "
        cQryRHM += "ON RHM_FILIAL = RA_FILIAL  "
		cQryRHM += "AND RHM_MAT = RA_MAT " 
		cQryRHM += "WHERE RHM.D_E_L_E_T_ = ' '  "
		cQryRHM += "AND SRA.D_E_L_E_T_ = ' '  "
        cQryRHM += "AND RA_MAT = '" + SRA->RA_MAT + "'"
	  
		cQryRHM := ChangeQuery(cQryRHM)

		If Select(cAliRHM) > 0
			DbSelectArea(cAliRHM)
			(cAliRHM)->(DbCloseArea())
		EndIf

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryRHM),cAliRHM, .F., .T.)
		dbSelectArea(cAliRHM)	

		While (cAliRHM)->(!EOF())
			DbSelectArea("RHM")
			DbSetOrder(1)
			RHM->(DbGoTo((cAliRHM)->RECNO))
			RecLock("RHM",.F.)
			RHM->RHM_XCNS := SRA->RA_XCNS
			RHM->(MsUnLock())
			(cAliRHM)->(DbSkip())
		EndDo

		cQryRHO := "SELECT RHO.R_E_C_N_O_ RECNO  "
		cQryRHO += "FROM " + RetSqlName("RHO") + " RHO  " 
		cQryRHO += "INNER JOIN " + RetSqlName("SRA") + " SRA  "
        cQryRHO += "ON RHO_FILIAL = RA_FILIAL  "
		cQryRHO += "AND RHO_MAT = RA_MAT " 
		cQryRHO += "WHERE RHO.D_E_L_E_T_ = ' '  "
		cQryRHO += "AND SRA.D_E_L_E_T_ = ' '  "
        cQryRHO += "AND RA_MAT = '" + SRA->RA_MAT + "'"
	  
		cQryRHO := ChangeQuery(cQryRHO)

		If Select(cAliRHO) > 0
			DbSelectArea(cAliRHO)
			(cAliRHO)->(DbCloseArea())
		EndIf

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryRHO),cAliRHO, .F., .T.)
		dbSelectArea(cAliRHO)	

		While (cAliRHO)->(!EOF())
			DbSelectArea("RHO")
			DbSetOrder(1)
			RHO->(DbGoTo((cAliRHO)->RECNO))
			RecLock("RHO",.F.)
			RHO->RHO_XCNS := SRA->RA_XCNS
			RHO->(MsUnLock())
			(cAliRHO)->(DbSkip())
		EndDo
	EndIf
	RestArea(aArea)
Return