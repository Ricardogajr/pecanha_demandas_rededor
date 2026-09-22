#Include 'Protheus.ch'

/*
{Protheus.doc} F0100201()
Verifica se funcionário existe, se existe ele verifica demissão e motivo
@Author     Henrique Madureira
@Since      08/04/2016
@Version    P12.7
@Project    MAN00000462901_EF_002
@Param      cCurri
@Return	 lRet
*/
User Function F0100201(l150CDT)
	
	Local aAreas	:= {SRA->(GetArea()), RD0->(GetArea()), GetArea()}
	Local nMes	:= 0
	Local nCont	:= 0
	Local cTpResci	:= ""
	Local cCandiCPF:= ""
	Local cMsg	:= ""
	Local cNewDt	:= ""
	Local dNewDt
	Local lRet	:= .T.
	Local cMat	:= ""
	Local dDemissa
	Local cDemissa	:= ""
	Local cFilSra	:= ""
	Local nPosRec	:= 0
	Local nPrzDia	:= 0
	
	DEFAULT l150CDT := .F.
	
	If !(FWIsInCallStack('RSPM001'))
		If l150CDT .Or. !(PARAMIXB[1])->TRX_CHECK
			
			SRA->(dbSetOrder(5))
			If l150CDT
				cCandiCPF := SQG->QG_CIC
			Else
				cCandiCPF := POSICIONE("SQG", 1, xFilial("SQG") + (PARAMIXB[1])->TRX_CURRIC, "QG_CIC")
			EndIf
			
			If SelectSRA(cCandiCPF, @cFilSra, @cMat, @dDemissa)
				cTpResci := POSICIONE("SRG", 2, cFilSra + cMat + "RES", "RG_TIPORES")
				
				//-Posiciona a Tabela Auxiliar e verifica o Prazo de Recontratação
				nPosRec := fPosTab("U001", cTpResci, "=", 4 )
				If nPosRec > 0
					nPrzDia := fTabela("U001", nPosRec, 6, )
					nPrzDia := Iif(ValType(nPrzDia) == "C", Val(nPrzDia), nPrzDia)
				EndIf
				If nPrzDia = 999
					//Demissão por justa causa:
					cMsg := "O ex-funcionário foi desligado da companhia por Justa Causa."
					cMsg += " Sua recontratação não é permitida."
					lRet := .F.
				Else
					nMes := TpResc01(cTpResci)
					
					dNewDt := DaySum(dDemissa, nMes)
					nCont := dDatabase - dDemissa
						
					cDemissa := cValToChar(dDemissa)
					cNewDt := cValToChar(dNewDt)
					
					If nMes != 0
						If nMes != 999
							If nCont <= nMes
								cMsg := "O ex-funcionário foi desligado da companhia em " + cDemissa + ". "
								cMsg += "Sua recontratação só será permitida à partir de " + cNewDt + ", "
								cMsg += "após verificação de referências com seu antigo gestor/área."
								lRet := .F.
							Else
								//Demissão sem justa causa:
								cMsg := "Colaborador desligado sem justa. Para recontratação, buscar referências do gestor."
							EndIf
						Else
							//Demissão por justa causa:
							cMsg := "O ex-funcionário foi desligado da companhia por Justa Causa."
							cMsg += " Sua recontratação não é permitida."
							lRet := .F.
						EndIf
					EndIf
				EndIf
				
				If !Empty(cMsg)
					Help( , , 'HELP', , cMsg, 1, 0)
				EndIf
			EndIf
		EndIf
	EndIf
	
	AEval(aAreas, {|x| RestArea(x)} )
	
Return lRet

/*
{Protheus.doc} TpResc01()
Verifica se existe o tipo de rescisão do funcionário na U001
@Author     Henrique Madureira
@Since      11/04/2016
@Version    P12.7
@Project    MAN00000462901_EF_002
@Param		 cTpResci
@Param		 cDtResci
@Return	 nDias
*/
Static Function TpResc01(cTpResci)
	
	Local aArea 		:= GetArea()
	Local aAreaRcb	:= RCB->(GetArea())
	Local aAreaRcc	:= RCC->(GetArea())
	Local cAux			:= ""
	Local aRCB			:= {}
	Local aVAL			:= {}
	Local aVAL2		:= {}
	Local nAux			:= 0
	Local nCnt			:= 0
	Local nDias		:= 0
	
	//Cria array com o tamanho dos campos da tabela
	RCB->(dbSetOrder(1))
	RCB->(dbGoTop())
	
	WHILE RCB->(!EOF())
		If RCB->RCB_CODIGO == "U001"
			AAdd(aRCB, RCB->RCB_TAMAN)
		EndIf
		RCB->(dbSkip())
	ENDDO
	
	//Busca na tabela RCC as rescisões da tabela U001 e acrescenta em um array
	RCC->(dbSetOrder(1))
	RCC->(dbGoTop())
	
	WHILE RCC->(!EOF())
		If RCC->RCC_CODIGO == "U001"
			cAux := ALLTRIM(RCC->RCC_CONTEU)
			aVAL := {}
			nAux := 1
			WHILE nAux <= LEN(aRCB)
				AAdd(aVAL, {nAux, SUBSTR(cAux, 0, aRCB[nAux])})
				cAux := SUBSTR(cAux, aRCB[nAux] + 1)
				nAux++
			ENDDO
			AAdd(aVAL2, aVAL)
		EndIf
		RCC->(dbSkip())
		
	ENDDO
	
	// Verifica se a rescisão do candidato esta cadastrado na tabela U001
	For nCnt := 1 To Len(aVAL2)
		
		If aVAL2[nCnt][1][2] == cTpResci
			nDias := Val(aVAL2[nCnt][3][2])
		EndIf
		
	Next
	
	RestArea(aAreaRcc)
	RestArea(aAreaRcb)
	RestArea(aArea)
	
Return nDias

/*/{Protheus.doc} SelectSRA

@type function
@author alexandre.arume
@since 14/12/2016
@version 1.0
@param cCPF, character, (Descrição do parâmetro)
@param cMat, character, (Descrição do parâmetro)
@param cDemissa, character, (Descrição do parâmetro)
@return ${lRet},  ${return_description}

/*/
Static Function SelectSRA(cCPF, cFilSra, cMat, dDemissa)
	
	Local cQuery 	:= ""
	Local cAlias 	:= GetNextAlias()
	Local lRet		:= .F.
	
	//cQuery := "SELECT RA_FILIAL, RA_MAT, RA_DEMISSA "
	//cQuery += "FROM " + RetSqlName("SRA") + " "
	//cQuery += "WHERE RA_CIC = '" + cCPF + "'"
	//cQuery := ChangeQuery(cQuery)
	

	cQuery := " SELECT * 
	cQuery += " FROM
	cQuery += " (
	cQuery += " SELECT MAX(R_E_C_N_O_) RECNO, RA_FILIAL, RA_MAT, RA_DEMISSA
	cQuery += "  FROM " + RetSqlName("SRA") + " "
	cQuery += " WHERE RA_CIC = '" + cCPF + "'"
	cQuery += " AND D_E_L_E_T_ = ''
	cQuery += " GROUP BY RA_FILIAL, RA_MAT, RA_DEMISSA
	cQuery += " ORDER BY RECNO DESC
	cQuery += " )
	cQuery += " WHERE ROWNUM = 1
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T., "TOPCONN", TCGenQry( , ,cQuery ), cAlias, .F., .T.)

	If !(cAlias)->(Eof())
		cMat := (cAlias)->RA_MAT
		dDemissa := Iif(!Empty((cAlias)->RA_DEMISSA), SToD((cAlias)->RA_DEMISSA), SToD(""))
		cFilSra := (cAlias)->RA_FILIAL
		lRet := .T.
	EndIf
	
	(cAlias)->(DbCloseArea())
	
Return lRet
