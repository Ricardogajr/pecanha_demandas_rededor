#INCLUDE 'Protheus.ch'

/*{Protheus.doc} MDTA6854
Pto.Entrada criado após a inclusão do Atestado Médico, possibilitando a alteração da tabela TNY.

@author		Ademar Fernandes
@since		25/07/2017
@project	MAN0000007423045_EF_003 
*/
User Function MDTA6854()
	Local lRet := .T.
	Local aArea := GetArea()
	Local aSR8Reg
	Local nOpcao := PARAMIXB[1]
	Local nRecno := 0
	
	Local cAliSR8 := GetNextAlias()

	If FindFunction("U_F1100101")
		lRet := U_F1100101(nOpcao)
	EndIf

If nOpcao == 3 .OR. nOpcao == 4 
	U_DOR007RH() // ticket n° 3642635 - 415966 - Paulo Dias - melhoria blackout.
	// ticket n° 11669194 - gravação do campo R8_XHROPER via MDTA685
	If !(TNY->TNY_CODAFA $ "001|002")
		DbSelectArea("SR8")
		DbSetOrder(6)
		If DbSeek(xFilial("SR8")+TYZ->TYZ_MAT+DTOS(TNY->TNY_DTINIC)+TNY->TNY_CODAFA)
			RecLock("SR8",.F.)  
			SR8->R8_XHROPER := TIME()
			SR8->(MsUnlock())
		EndIf              
    EndIf
ElseIf  nOpcao == 5 // Tratamento para exclusão
	nRecno := TNY->(RECNO())

	cQrySR8 := " SELECT SR8.R_E_C_N_O_ RECNO, R8_MAT  "
    cQrySR8 += " FROM " + RetSqlName("SR8") + " SR8 , " 
	cQrySR8 += + RetSqlName("SRA") + " SRA , " 
	cQrySR8 += + RetSqlName("TNY") + " TNY   "
    cQrySR8 += " WHERE SR8.D_E_L_E_T_ = ' '  "
	cQrySR8 += " AND SRA.D_E_L_E_T_ = ' '  "
	cQrySR8 += " AND TNY.D_E_L_E_T_ = '*'  "
	cQrySR8 += " AND RA_FILIAL = R8_FILIAL  "
	cQrySR8 += " AND R8_FILIAL = TNY_FILIAL "
	cQrySR8 += " AND TNY_FILIAL = RA_FILIAL "
	cQrySR8 += " AND R8_MAT = RA_MAT "
	cQrySR8 += " AND TNY_TPEFD = R8_XTPEFD "
	cQrySR8 += " AND TNY_XQTDIA = R8_XDURAC "
	cQrySR8 += " AND R8_XDTINI = TNY_XDTSAI "
	cQrySR8 += " AND R8_XDTFIM = TNY_XDALT "
	cQrySR8 += " AND TNY_XDTBLK <> ' ' "
	cQrySR8 += " AND TNY.R_E_C_N_O_ =  " + cValToChar(nRecno)  

    cQrySR8 := ChangeQuery(cQrySR8)

        If Select(cAliSR8) > 0
            DbSelectArea(cAliSR8)
            (cAliSR8)->(DbCloseArea())
        EndIf

        dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQrySR8),cAliSR8, .F., .T.)
        dbSelectArea(cAliSR8)	

		While (cAliSR8)->(!EOF())
            DbSelectArea("SR8")
            DbSelectArea("TM0")
			SR8->(DbGoTo((cAliSR8)->RECNO))
			If (cAliSR8)->(R8_MAT) == TM0->TM0_MAT
				RecLock("SR8",.F.)
				SR8->( dbDelete() )
				SR8->(MsUnLock()) 
			EndIf 
		(cAliSR8)->(dbSkip())
		EndDo
Endif

	RestArea(aArea)
Return(lRet)
