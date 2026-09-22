#Include 'Protheus.ch'

/*
{Protheus.doc} F0600107()
Envio do SRA para o Apdata

@Author     Nairan
@Since      25/08/2017
@Version    P12.1.07
@Project    
*/
User Function F0600107()
	If VldPA6(SRA->RA_FILIAL, SRA->RA_MAT)
		U_F0600901("F0600101",;		// cFunc
					SRA->(RECNO()),;// nRecno
					"SRA",;			// cAliasTrb
					SRA->RA_FILIAL + SRA->RA_MAT,; // cChave
					"",;			// cObs
					CTOD(""),;		// Data de envio
					"INSERT",;		// Operacao
					SRA->RA_FILIAL)
	ElseIf VldAltPA6(SRA->RA_FILIAL, SRA->RA_MAT)
		U_F0600901("F0600101",;		// cFunc
					SRA->(RECNO()),;// nRecno
					"SRA",;			// cAliasTrb
					SRA->RA_FILIAL + SRA->RA_MAT,; // cChave
					"",;			// cObs
					CTOD(""),;		// Data de envio
					"UPDATE",;		// Operacao	
					SRA->RA_FILIAL)
	EndIf
Return

///////////////////////////////////////////////
// Valida se já existe registro de 			 //
// integração para a matrícula na tabela PA6 //
///////////////////////////////////////////////
Static Function VldPA6(cFilSRA,cMat)
	Local cAliasTrb	:= GetNextAlias()
	Local cQuery	:= ""
	Local lRet		:= .T.
	
	cQuery := " SELECT PA6_ID "
	cQuery += " FROM " + RetSqlName("PA6") + " "
	cQuery += " WHERE PA6_ALIAS = 'SRA' "
	cQuery += " AND Trim(PA6_CHALIA) = '"+cFilSRA+cMat+"' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T., "TOPCONN", TCGenQry( ,,cQuery ), cAliasTrb, .F., .T.)
	
	If (cAliasTrb)->(!EOF())
		lRet := .F.
	EndIf
	
	(cAliasTrb)->(DbCloseArea())

Return lRet

///////////////////////////////////////////////
// Valida se já existe registro de 			 //
// integração de alteração para a matrícula  //
// na para a matrícula na tabela PA6         //
///////////////////////////////////////////////
Static Function VldAltPA6(cFilSRA,cMat)
	Local cAliasTrb	:= GetNextAlias()
	Local cQuery	:= ""
	Local lRet		:= .T.
	
	cQuery := " SELECT PA6_ID "
	cQuery += " FROM " + RetSqlName("PA6") + " "
	cQuery += " WHERE PA6_ALIAS = 'SRA' "
	cQuery += " AND Trim(PA6_CHALIA) = '"+cFilSRA+cMat+"' "
	cQuery += " AND PA6_OPERAC = 'UPDATE' "
	cQuery += " AND PA6_DATENV = '        ' "	
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T., "TOPCONN", TCGenQry( ,,cQuery ), cAliasTrb, .F., .T.)
	
	If (cAliasTrb)->(!EOF())
		lRet := .F.
	EndIf
	
	(cAliasTrb)->(DbCloseArea())

Return lRet
