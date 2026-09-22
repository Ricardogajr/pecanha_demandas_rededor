#include "protheus.ch"

/*/{Protheus.doc} F0600301
Atualização de Dados Contratuais com ApData (Troca de Turno).

@project	MAN0000007423040_EF_001
@type 		function
@author 	alexandre.arume
@since 		31/10/2016
@version 	1.0
@param 		cAliasTrb, character, Alias da tabela
@param 		cId, character, Id
@param 		cOper, character, Operacao - upsert ou delete
@param 		nRecno, numerico, Número do registro
@param 		cMot, character, Motivos
@return 	${return}, ${return_description}

/*/
User Function F0600301(cAliasTrb, cId, cOper, nRecno, cMot)
	
	Local cTbl			:= "EF06003"
	Local aTblStru		:= {{"EF06003_ID", "VARCHAR", 32},;
							{"EF06003_FILIAL", "VARCHAR", 8},;
							{"EF06003_MATRICULA", "VARCHAR", 6},;
							{"EF06003_DTMOV", "VARCHAR", 8},;
							{"EF06003_SIND_CARGHR", "VARCHAR", 8},;
							{"EF06003_SINDICATO", "VARCHAR", 2},;
							{"EF06003_FUNCAO", "VARCHAR", 5},;
							{"EF06003_CC", "VARCHAR", 11},;
							{"EF06003_TURNO", "VARCHAR", 3},;
							{"EF06003_CARGHR", "VARCHAR", 8},;
							{"EF06003_SALARIO", "VARCHAR", 12},;
							{"EF06003_TIPO", "VARCHAR", 3},;
							{"EF06003_VALOR", "VARCHAR", 15},;
							{"EF06003_TURNODE", "VARCHAR", 3},;
							{"EF06003_SEQUEDE", "VARCHAR", 2},;
							{"EF06003_REGRADE", "VARCHAR", 2},;
							{"EF06003_TURONPA", "VARCHAR", 3},;
							{"EF06003_SEQUEPA", "VARCHAR", 2},;
							{"EF06003_REGRAPA", "VARCHAR", 2},;
							{"EF06003_JORNDE", "VARCHAR", 5},;
							{"EF06003_JORNPA", "VARCHAR", 5},;
							{"EF06003_MOTIVO", "VARCHAR", 1},;
							{"EF06003_DTTRANSAC", "VARCHAR", 8},;
							{"EF06003_HRTRANSAC", "VARCHAR", 8},;
							{"EF06003_OPERACAO", "VARCHAR", 6},;
							{"EF06003_STATUS", "VARCHAR", 1},;
							{"EF06003_DTPROCESS", "VARCHAR", 8},;
							{"EF06003_HRPROCESS", "VARCHAR", 8},;
							{"EF06003_OBSERVA", "VARCHAR", 700}}
	Local aValues		:= {}
	Local lRet			:= .T.
	Local aAreaSRA		:= {}
	Local aAreaSR3		:= {}
	
	// Troca de Turno.
	If cAliasTrb == "SPF"
	
		dbSelectArea("SPF")
		dbGoTo(nRecno)
	
		aValues := {cId,;
					SPF->PF_FILIAL,;
					SPF->PF_MAT,;
					SPF->PF_DATA,;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					SPF->PF_TURNODE,;
					SPF->PF_SEQUEDE,;
					SPF->PF_REGRADE,;
					SPF->PF_TURNOPA,;
					SPF->PF_SEQUEPA,;
					SPF->PF_REGRAPA,;
					SPF->PF_JORNADE,;
					SPF->PF_JORNAPA,;
					cMot,; // Motivo
					dDataBase,;
					TIME(),;
					cOper,;
					"1",;
					"",;
					"",;
					""}
	
	// Atualização Cadastral.					
	ElseIf cAliasTrb == "SR3"
	
		dbSelectArea("SR3")
		SR3->(dbGoTo(nRecno))
	
		aValues := {cId,;
					SR3->R3_FILIAL,;
					SR3->R3_MAT,;
					SR3->R3_DATA,;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					SR3->R3_TIPO,;
					SR3->R3_VALOR,;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"2",; // Motivo
					dDataBase,;
					TIME(),;
					cOper,;
					"1",;
					"",;
					"",;
					""}
	
	// Troca de Função.
	ElseIf cAliasTrb == "SR7"
	
		dbSelectArea("SR7")
		SR7->(dbGoTo(nRecno))
	
		aAreaSRA := SRA->(GetArea())
		
		dbSelectArea("SRA")
		SRA->(dbSetOrder(1))
		SRA->(DbSeek(xFilial("SRA") + SR7->R7_MAT))
		
		aAreaSR3 := SR3->(GetArea())
		
		dbSelectArea("SR3")
		SR3->(dbSetOrder(1))
		SR3->(DbSeek(xFilial("SR3") + SR7->R7_MAT + DTOS(SR7->R7_DATA) + SR7->R7_TIPO))
		
		aValues := {cId,;
					SR7->R7_FILIAL,;
					SR7->R7_MAT,;
					SR7->R7_DATA,;
					"",;
					SRA->RA_SINDICA,;
					SR7->R7_FUNCAO,;
					SRA->RA_CC,;
					SRA->RA_TNOTRAB,;
					SRA->RA_HRSMES,;
					SRA->RA_SALARIO,;
					SR3->R3_TIPO,;
					SR3->R3_VALOR,;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"3",; // Motivo
					dDataBase,;
					TIME(),;
					cOper,;
					"1",;
					"",;
					"",;
					""}
					
		RestArea(aAreaSRA)
		RestArea(aAreaSR3)
						
	// Troca de Sindicato/Carga Horária.
	ElseIf cAliasTrb == "SR9"

		dbSelectArea("SR9")
		SR9->(dbGoTo(nRecno))	
		aValues := {cId,;
					SR9->R9_FILIAL,;
					SR9->R9_MAT,;
					SR9->R9_DATA,;
					"",;
					IIF(AllTrim(SR9->R9_CAMPO) == "RA_SINDICA",Left(SR9->R9_DESC, 2),""),;
					"",;
					"",;
					"",;
					IIF(AllTrim(SR9->R9_CAMPO) == "RA_HRSMES",SubSTR(Alltrim(SR9->R9_DESC),1,AT(",",Alltrim(SR9->R9_DESC))-1),""),;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					IIf(AllTrim(SR9->R9_CAMPO) == "RA_SINDICA", "4", "5"),; // Motivo
					dDataBase,;
					TIME(),;
					cOper,;
					"1",;
					"",;
					"",;
					""}
					
	// Centro de Custo.
	ElseIf cAliasTrb == "SRE"
	
		dbSelectArea("SRE")
		SRE->(dbGoTo(nRecno))
	
		aValues := {cId,;
					Left(SRE->RE_FILIALD,8),;
					SRE->RE_MATP,;
					SRE->RE_DATA,;
					"",;
					"",;
					"",;
					SRE->RE_CCP,;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					cMot,; // Motivo
					dDataBase,;
					TIME(),;
					cOper,;
					"1",;
					"",;
					"",;
					""}
						
	EndIf
	
	// Gravação na tabela de interface.
	lRet := U_F0600102(cTbl, aTblStru, aValues)
	
Return lRet
