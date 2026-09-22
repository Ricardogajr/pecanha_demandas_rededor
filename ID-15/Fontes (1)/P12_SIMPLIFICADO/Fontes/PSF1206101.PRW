#Include 'Protheus.ch'

/*
{Protheus.doc} F1206101()
Bloqueio da mesma descrição completa da SB1
@Author  Fabrica de Software
@Since   17/09/2018
@Project MAN0000007423048
@Param   cDescComp, caracter, Descrição complementar
@Return  lRet, permite ou não continuar o processo
*/
User Function F1206101(cDescComp)
	
	Local cPalavra := Alltrim(cDescComp)
	Local lRet     := .T.
	Local lEspaco  := .F. 
	Local nX       := 0
	Local cDescAux := ""
	Local cQuery   := ""
	Local cAlias1  := GetNextAlias()
	
	For nX := 1 to Len(cPalavra)
		If SubStr(cPalavra,nX,1) == " "
			If !lEspaço
				cDescAux += SubStr(cPalavra,nX,1)
			EndIf
			lEspaço := .T.
		ElseIf !lEspaco
			cDescAux += SubStr(cPalavra,nX,1)
			lEspaço := .F.
		EndIf
	Next
	
	If !Empty(cDescAux)
		cQuery += "SELECT B1_COD, B1_XDES "
		cQuery += "FROM " + RetSqlName("SB1") + " "
		cQuery += "WHERE B1_XDES = '" + cDescAux + "' " 
		cQuery += "AND D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAlias1, .T., .T.)
		
		If !(cAlias1)->(EOF())
			lRet := .F.
			Help( , , "Help", "F1206101", "Já existe descrição no cadastro de produto (código: " + (cAlias1)->B1_COD + "), não será permitido continuidade na operação.", 1, 0 )
		Else
			M->B1_XDES := cDescAux
		EndIf
		
		(cAlias1)->(DbCloseArea())
	EndIf
	
Return lRet

/*
{Protheus.doc} F1206102()
Bloqueio da mesma descrição completa da SB1 - via Integração
@Author  Fabrica de Software
@Since   17/09/2018
@Project MAN0000007423048
@Param   cDescComp, caracter, Descrição complementar
@Return  aRet, aRet[1] - permite ou não continuar o processo, aRet[2] - cDescComp ajustado
*/
User Function F1206102(cDescComp)
	
	Local cPalavra := Alltrim(cDescComp)
	Local aRet     := {}
	Local lEspaco  := .F. 
	Local nX       := 0
	Local cDescAux := ""
	Local cQuery   := ""
	Local cAlias1  := GetNextAlias()
	
	For nX := 1 to Len(cPalavra)
		If SubStr(cPalavra,nX,1) == " "
			If !lEspaço
				cDescAux += SubStr(cPalavra,nX,1)
			EndIf
			lEspaço := .T.
		ElseIf !lEspaco
			cDescAux += SubStr(cPalavra,nX,1)
			lEspaço := .F.
		EndIf
	Next
	
	cQuery += "SELECT B1_COD, B1_XDES "
	cQuery += "FROM " + RetSqlName("SB1") + " "
	cQuery += "WHERE B1_XDES = '" + cDescAux + "' " 
	cQuery += "AND D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAlias1, .T., .T.)
	
	If !(cAlias1)->(EOF())
		AADD(aRet,{.F.,""})
	Else
		AADD(aRet,{.T.,cDescAux})
	EndIf
	
	(cAlias1)->(DbCloseArea())
	
Return aRet