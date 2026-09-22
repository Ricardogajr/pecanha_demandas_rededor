#include 'TOTVS.ch'

/*/{Protheus.doc} Gp010ValPE
	
	Ponto de Entrada antes de efetivar inclusão/alteração de cadastro de funcionario
	verifica se matricula existe , somente se for rotina de inclusão.

	@type  Function
	@author Cleiton Genuino da Silva
	@since 29/11/2023
	@version 12.1.2210
	@return logical, Retorna verdadeiro se validado todos os campos caso contrario falso

	/*/
User Function Gp010ValPE()
	Local _Mat    := M->RA_MAT      as character
	Local aArea   := GetArea()      as array
	Local cAlias1 := GetNextAlias() as character
	Local cQuery  := ""             as character
	Local lMatRet := .t.            as logical
	Local cFicMed := ""
	// 416094  - Rogerio Carvalho - 02/03/2018
	// Ponto de Entrada antes de efetivar inclusão/alteração de cadastro de funcionario
	// verifica se matricula existe , somente se for rotina de inclusão.

	//Valida pelos parametros se essa empresa irá executar essas chamadas.
	If FindFunction('VALIDEMP')
		If !U_VALIDEMP()
			Return lMatRet
		EndIf
	EndIf

	If FindFunction("U_RHDIVE02") .And. ! EXCLUI 
		lMatRet := U_RHDIVE02()
	Endif

	If ExistBlock("FSPE0026")
		If !( ExecBlock("FSPE0026",.F.,.F.) )
			lMatRet := .F.
			Return(lMatRet)
		EndIf
	Endif
	
	If Inclui

		// 416094 - Rogerio Carvalho - 02/03/2018
		// faz a query considerando todas matriculas da tabela SRA , inclusive os registro deletados
		// a sequencia do numero de matricula considera todos os numeros criados
		cQuery := " SELECT RA_MAT "
		cQuery += " FROM " + RetSqlName("SRA") + " "
		cQuery += " ORDER BY RA_MAT "

		cQuery := ChangeQuery(cQuery)

		//cQuery += "WHERE D_E_L_E_T_ = ' ' " // Rogerio Carvalho - 02/03/2018

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery),cAlias1)

		While !(cAlias1)->(EOF())

			If (cAlias1)->RA_MAT == _MAT
				Alert("Essa matricula já existe no cadastro. Favor informar a equipe de operações para que seja corrigido o numerador automático")
				// Rogerio Carvalho - 02/03/2018
				// retorna false impedindo o cadastro de ser inserido , caso o numero de matricula já exista
				lMatRet := .f.

			Endif

			DbSkip()

		End

		(cAlias1)-> (DbCloseArea())

		RestArea(aArea)

		// 416094 - Rogerio Carvalho - AMS Rio - 01/07/2018 - DOR04520620
		// Integração Cadastro de Funcionários
		M->RA_XDTOPER := date()
		M->RA_XHROPER := time()

		//Laura Peghini - 05/11/2025
		//Atualiza dados na ficha médica
		//Criada função pra buscar a ultima ficha médica criada para a pessoa - 02/04/2026
		cFicMed := GetFichaMedica(cFilAnt,M->RA_CIC)
		DbSelectArea("TM0")
		TM0->(DbSetOrder(1))
		If TM0->(DbSeek(cFilAnt+cFicMed))
			TM0->(Reclock('TM0',.F.))
				TM0->TM0_FILFUN := cFilAnt
				TM0->TM0_MAT := M->RA_MAT 
			TM0->(MsUnlock())
		EndIf
		TM0->(DbCloseArea())

	Else

		M->RA_XDTOPER := date()
		M->RA_XHROPER := time()
		// 416094 - Rogerio Carvalho - AMS Rio - 13/07/2018 - DOR04520620
		// Alteração Cadastral/Contratual : Verifica se o turno foi alterado
		If Altera
			cMtnotrab := M->RA_TNOTRAB
			cStnotrab := SRA->RA_TNOTRAB
			cMsindica := M->RA_SINDICA
			cSsindica := SRA->RA_SINDICA
			cMpis	  := M->RA_PIS
			cSpis	  := SRA->RA_PIS
			cMNomCp	  := M->RA_NOMECMP
			cSNomCp   := SRA->RA_NOMECMP
			cMNacio	  := M->RA_NACIONA //Thais Paiva - 14205299
			cSNacio   := SRA->RA_NACIONA //Thais Paiva - 14205299
			

			IF cStnotrab <> cMtnotrab

				DbSelectArea("SPF")
				SPF->(DbSetOrder(1))
				SPF->(DbGotop())

				If SPF->(DbSeek(xFilial("SPF") + alltrim(M->RA_MAT) + alltrim(ddatabase)))

					RecLock("SPF",.F.)
					SPF->PF_XDTOPER := date()
					SPF->PF_XHROPER := time()
					SPF->(MsUnlock())

				Endif
				SPF->(DbCloseArea())
			Endif

			If cSsindica <> cMsindica
				dbSelectArea("SR9")
				If SR9->(Reclock('SR9',.T.))
					SR9->R9_FILIAL	:= cFilant
					SR9->R9_MAT		:= M->RA_MAT
					SR9->R9_DATA	:= date()
					SR9->R9_CAMPO 	:= "RA_SINDICA"
					SR9->R9_DESC	:= cMsindica
					SR9->R9_XDTOPER := date()
					SR9->R9_XHROPER := time()
					SR9->R9_XINTINC := " "
					SR9->R9_XIDINC  := "                                "
					SR9->(MsUnlock())

				EndIf
			Endif

			//Inclusão do nome completo na SR9 
			If cMNomCp <> cSNomCp
				dbSelectArea("SR9")
				If SR9->(Reclock('SR9',.T.))
					SR9->R9_FILIAL	:= cFilant
					SR9->R9_MAT		:= M->RA_MAT
					SR9->R9_DATA	:= date()
					SR9->R9_CAMPO 	:= "RA_NOMECMP"
					SR9->R9_DESC	:= cMNomCp
					SR9->R9_XDTOPER := date()
					SR9->R9_XHROPER := time()
					SR9->R9_XINTINC := " "
					SR9->R9_XIDINC  := "                                "
					SR9->(MsUnlock())

				EndIf
			EndIf
			
			//Início Inclusão da Nacionalidade na SR9 Thais Paiva - 14205299
			If cMNacio <> cSNacio
				dbSelectArea("SR9")
				If SR9->(Reclock('SR9',.T.))
					SR9->R9_FILIAL	:= cFilant
					SR9->R9_MAT		:= M->RA_MAT
					SR9->R9_DATA	:= date()
					SR9->R9_CAMPO 	:= "RA_NACIONA"
					SR9->R9_DESC	:= cMNacio
					SR9->R9_XDTOPER := date()
					SR9->R9_XHROPER := time()
					SR9->R9_XINTINC := " "
					SR9->R9_XIDINC  := "                                "
					SR9->(MsUnlock())
				EndIf
			Endif
			//Fim Thais Paiva - 14205299

			//Laura Peghini - 05/11/2025
			//Atualiza dados na ficha médica
			//Criada função pra buscar a ultima ficha médica criada para a pessoa - 02/04/2026
			cFicMed := GetFichaMedica(cFilAnt,M->RA_CIC)
			DbSelectArea("TM0")
			TM0->(DbSetOrder(1))
			If TM0->(DbSeek(cFilAnt+cFicMed))
				If Empty(TM0->TM0_FILFUN) .OR. Empty(TM0->TM0_MAT)
					TM0->(Reclock('TM0',.F.))
						TM0->TM0_FILFUN := cFilAnt
						TM0->TM0_MAT := M->RA_MAT
					TM0->(MsUnlock())
				EndIf
			EndIf
			TM0->(DbCloseArea())

		Endif
		// Fim - 416094 - Rogerio Carvalho - AMS Rio - 13/07/2018 - DOR04520620
	Endif

	RestArea(aArea)

Return lMatRet

/*/{Protheus.doc} GetFichaMedica
@type  Function
@author user
@since 02/04/2026
@version version
@param cFilAnt, matricula
@return cNumFicMed
/*/
Static Function GetFichaMedica(cFilAnt,cCpfFunc)

Local cArea01 	 := GetArea()
Local cQuery 	 := ""
Local cAliasTrb  := GetNextAlias()
Local cRecnoTM0  := 0
Local cNumFicMed := ""
	
	cQuery := " SELECT MAX(R_E_C_N_O_) AS RECTM0 "
	cQUery += " FROM "+ RetSqlName("TM0")+ " TM0"
	cQuery += " WHERE TM0_FILIAL = '"+cFilAnt+"' "
	cQuery += " AND TM0_CPF = '"+cCpfFunc+"' "
	cQuery += " AND TM0.D_E_L_E_T_ = '' "

	PLSQuery( cQuery, cAliasTrb )
	(cAliasTrb)->(DBGoTop())
    If !(cAliasTrb)->(Eof())
		cRecnoTM0 := (cAliasTrb)->RECTM0
	EndIf
	(cAliasTrb)->(DbCloseArea())

	DbSelectArea("TM0")
	TM0->(DbGoTo(cRecnoTM0))
	cNumFicMed := TM0->TM0_NUMFIC
	TM0->(DbCloseArea())
	RestArea(cArea01)

Return cNumFicMed
