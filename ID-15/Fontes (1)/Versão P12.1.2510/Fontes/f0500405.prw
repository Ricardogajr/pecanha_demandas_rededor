#Include 'Protheus.ch'
Static lBOracle	:= Trim(TcGetDb()) = 'ORACLE'
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F0500405
(Retorna os responsáveis pela aprovação ou o primeiro responsável pela aprovação
@type User function
@author Cris
@since 09/11/2016
@param cVisao, character, (Descrição do parâmetro)
@param @cFilResp, $character, (Filial do aprovador )
@param @cMatResp, $character, (Matricula do aprovador)
@param @cEmailRe, $character, (email do aprovador)
@param @lTodos, $Logico, (.T. carrega todos os aprovadores da visão,.F. não carrega)
@param @aResp, $array, (array contendo todos  os aprovadores da visão quando lTodos estiver como .T.)
@version P12.1.7
@Project MAN0000007423039_EF_004
@return ${return}, ${não há}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function F0500405(cVisao,cFilResp,cMatResp,cEmailRe,lTodos,aResp)
	
	Local cQry		:= ''
	Local cTabResp	:= GetNextAlias()
	Local cTipOrg	:= ''
	
	Default cVisao		:= ""
	Default cFilResp	:= ""
	Default cMatResp	:= ""
	Default cEmailRe	:= ""
	Default lTodos		:= .F.
	Default aResp		:= {}
	
	TipoOrg(@cTipOrg, cVisao)
	
	if cTipOrg == '1'
		
		cQry	:= " SELECT RA_FILIAL FILMAT, RA_MAT MATRIC, RA_DEPTO DEPTOMAT,'' DESCRI,RA_CC CCMAT, RA_EMAIL EMAILMAT " + CRLF
		cQry	+= " FROM " + RetSqlName("SRA") + " (NOLOCK) " + CRLF
		
		if !lBOracle
			
			cQry	+= " WHERE RA_FILIAL + RA_MAT IN ( " + CRLF
			cQry	+= " 							SELECT RCX_FILFUN + RCX_MATFUN " + CRLF
		Else
			
			cQry	+= " WHERE RA_FILIAL||RA_MAT IN ( " + CRLF
			cQry	+= " 							SELECT RCX_FILFUN||RCX_MATFUN " + CRLF
		EndIf
		
		cQry	+= " 							FROM " + RetSqlName("RCX") + " (NOLOCK) " + CRLF
		cQry	+= " 							WHERE RCX_FILIAL = '" + FwxFilial("RCX") + "' " + CRLF
		cQry	+= " 			 				  AND D_E_L_E_T_ = '' " + CRLF
		cQry	+= " 			  				  AND RCX_MATFUN <> '' " + CRLF
		cQry	+= " 			  				  AND RCX_POSTO   " + CRLF
		
	Elseif cTipOrg == '2'
		
		cQry	:= " SELECT SQB.QB_FILRESP FILMAT, SQB.QB_MATRESP MATRIC, SQB.QB_DEPTO DEPTOMAT, " + CRLF
		cQry	+= "        SQB.QB_DESCRIC DESCRI, SQB.QB_CC CCMAT, SRA.RA_EMAIL AS EMAILMAT " + CRLF
		cQry	+= " FROM " + RetSqlName("SQB") + "  SQB (NOLOCK) " + CRLF
		cQry	+= " INNER JOIN " + RetSqlName("SRA") + " SRA (NOLOCK) " + CRLF
		cQry	+= "          ON SRA.RA_FILIAL = SQB.QB_FILRESP " + CRLF
		cQry	+= " 		 AND SRA.RA_MAT = SQB.QB_MATRESP  " + CRLF
		cQry	+= " 		 AND SRA.D_E_L_E_T_ = '' " + CRLF
		cQry	+= " WHERE SQB.D_E_L_E_T_ = '' " + CRLF
		cQry	+= "   AND SQB.QB_FILIAL = '" + xFilial("SQB") + "' " + CRLF
		cQry	+= "   AND SQB.QB_DEPTO " + CRLF
	EndIf
	
	If cTipOrg $ '1*2'
	
		If !lTodos
			cQry	+= " 		 = " + CRLF
		Else
			cQry	+= " 		IN " + CRLF
		EndIf
		
		cQry	+= " 		 		( " + CRLF
		cQry	+= " 					SELECT RD4_CODIDE " + CRLF
		cQry	+= " 					FROM " + RetSqlName("RD4") + " (NOLOCK) " + CRLF
		cQry	+= " 					WHERE RD4_FILIAL  = '" + xFilial("RD4") + "' " + CRLF
		cQry	+= " 					  AND RD4_CODIGO = '" + cVisao + "' " + CRLF
		
		if !lTodos
			cQry	+= " 					  AND RD4_ITEM = (SELECT MAX(RD4_ITEM) " + CRLF
			cQry	+= " 									   FROM " + RetSqlName("RD4") + " (NOLOCK) " + CRLF
			cQry	+= " 										WHERE RD4_FILIAL  = '" + xFilial("RD4") + "' " + CRLF
			cQry	+= " 										  AND RD4_CODIGO = '" + cVisao + "' " + CRLF
			cQry	+= " 										  AND D_E_L_E_T_ = '') " + CRLF
		EndIf
		cQry	+= "                    AND D_E_L_E_T_ = '') " + CRLF
		
		cQry := ChangeQuery(cQry)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cTabResp,.T.,.T.)
		
		if !(cTabResp)->(Eof())
			
			While  !(cTabResp)->(Eof())
				
				if !lTodos
					cFilResp	:= (cTabResp)->FILMAT
					cMatResp	:= (cTabResp)->MATRIC
					cEmailRe	:= (cTabResp)->EMAILMAT
				Else
					AAdd(aResp,{(cTabResp)->FILMAT,(cTabResp)->MATRIC,(cTabResp)->EMAILMAT})
				EndIf
				
				(cTabResp)->(dbSkip())
			EndDo
		Else
			cFilResp	:= ""
			cMatResp	:= ""
			cEmailRe	:= ""
		EndIF
		
		(cTabResp)->(dbCloseArea())
	EndIf
Return
