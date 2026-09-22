#Include 'Protheus.ch'
/*
{Protheus.doc} F0200305()
Pega Nome do funcionário e E-mail do responsavel
@Author     Henrique Madureira
@Since      20/05/2016
@Version    P12.7
@Project    MAN00000463301_EF_003
@param cFilApr, characters, descricao
@param cMatrApr, characters, descricao
@param cTreina, characters, descricao
@param cCurso, characters, descricao
@param cTurma, characters, descricao
@Return     aArry
*/
User Function F0200305(cFilApr, cMatrApr, cTreina, cCurso, cTurma)
	Local aArea 		:= GetArea()
	Local cQuery 		:= ''
	Local cEmail 		:= ''
	Local cNome		:= ''
	Local cNmTreina	:= ''
	Local cString		:= ''
	Local cAliasRa2	:= 'InRa2'
	Local aArry		:= {}

	cEmail := POSICIONE("SRA",1,cFilApr + cMatrApr, "RA_EMAIL")
	cNome  := POSICIONE("SRA",1,cFilApr + cMatrApr, "RA_NOME")
	If ! Empty(cTreina)
		// Pega nome do treinamento
		cQuery := "SELECT	RA2_DESC "
		cQuery += "FROM	" + RetSqlName("RA2") + "  "
		cQuery += "WHERE	RA2_CALEND = " + cTreina + " "
		cQuery += " AND RA2_CURSO = " + cCurso + " "
		cQuery += " AND RA2_TURMA =" + cTurma + " "
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRa2)
		
		DbSelectArea(cAliasRa2)
		While ! (cAliasRa2)->(EOF())
			cNmTreina := (cAliasRa2)->RA2_DESC
			(cAliasRa2)->(DbSkip())
		End
		(cAliasRa2)->(DbCloseArea())
	EndIf
	
	
	// Adiciona informação no Array
	AAdd(aArry, cNome)
	AAdd(aArry, cEmail)
	AAdd(aArry, cNmTreina)
	
	RestArea(aArea)
	
Return aArry

