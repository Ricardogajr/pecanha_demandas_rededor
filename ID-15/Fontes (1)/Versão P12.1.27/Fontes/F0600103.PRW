#include "protheus.ch"
#include "TBICONN.CH"

/*/{Protheus.doc} TsJ00103

@project	MAN0000007423040_EF_001
@type 		function
@author 	alexandre.arume
@since 		09/11/2016
@version 	1.0
@return 	${return}, ${return_description}

/*/
User Function TsJ00103()
	Local aVet := {'01', '01010002'}
	U_F0600103(aVet)      
Return

/*/{Protheus.doc} F0600103
Função chamada no Job, que seleciona os registros da PA6 para serem integrados para a tabela intermediária.

@project	MAN0000007423040_EF_001
@type 		function
@author 	alexandre.arume
@since 		09/11/2016
@version 	1.0
@return 	${return}, ${return_description}
@param aParam, array, Empresa e Filial
 
/*/
User Function F0600103(aParam)
	
	Local cQuery 	:= ""
	Local cAlias	:= GetNextAlias()
	Local dDtIni    := Date()
	Local cHora     := Time()
	Local cEmpIni   := IIF(ValType(aParam) == "A", aParam[1], cEmpAnt)
	Local cFilIni   := IIF(ValType(aParam) == "A", aParam[2], cFilAnt)
	Local cId		:= ""
	Local lOk		:= .T.
	
	// Verifica se já existe um Job em execução com o mesmo nome.
	If !LockByName("F0600103_" + cEmpIni, .F. ,.F.)
		Conout("F0600103 - Ja existe um Job com mesmo nome em execucao!")
	Else
	
		ConOut("**************************************************************************")
		ConOut("* F0600103: Integracao dos Cadastro						 				 *")
		ConOut("* Inicio: " + Dtos(dDtIni) + " - " + cHora + "                   		 	 *")
		ConOut("* Montagem do ambiente na empresa " + cEmpIni + " - " + cFilIni + " 		 *")
		Conout("* F0600103 - Inicio Thread: '" + cValToChar(ThreadID()) 				)
		ConOut("**************************************************************************")
		
		If !RpcSetEnv( cEmpIni, cFilIni,,,"FAT",, /*aFiles*/ )
			Conout("F0600103 - Nao foi possivel inicializar o ambiente.")
		Else	
	
			cQuery := " SELECT PA6_ID, PA6_ALIAS, PA6_CHALIA, PA6_OPERAC, PA6_RECNOT, PA6_FUNC, "
			cQuery += "  R_E_C_N_O_ RECPA6 "
			cQuery += " FROM " + RetSqlName("PA6") + " "
			cQuery += " WHERE PA6_FILIAL = '" + xFilial("PA6") + "' "
			cQuery += " AND D_E_L_E_T_ = ' ' "
			cQuery += " AND PA6_DATENV = ' ' "
			//?cQuery += " ORDER BY PA6_DATA ASC, PA6_HORA ASC, PA6_RECNOT ASC "
			cQuery += " ORDER BY PA6_DATA ASC, PA6_HORA ASC, RECPA6 ASC "
			cQuery := ChangeQuery(cQuery)
			
			dbUseArea(.T., "TOPCONN", TCGenQry( ,,cQuery ), cAlias, .F., .T.)
			
			Do While !(cAlias)->(Eof())
					
				Begin Transaction
				
					cId := AllTrim((cAlias)->PA6_ID)
					
					Do Case
					// EF 001 - Cadastro de Funcionários.
					Case (cAlias)->PA6_ALIAS == "SRA"
						lOk := U_F0600101(cId,(cAlias)->PA6_RECNOT)

					// EF 002 - Cadastro de Afastamentos.
					Case (cAlias)->PA6_ALIAS == "SR8"
						lOk := U_F0600201(cId, (cAlias)->PA6_OPERAC, (cAlias)->PA6_RECNOT)
						
					// EF 003 - Atualização de Dados Contratuais.
					Case (cAlias)->PA6_ALIAS == "SPF"
						lOk := U_F0600301((cAlias)->PA6_ALIAS, cId, (cAlias)->PA6_OPERAC, (cAlias)->PA6_RECNOT, "1")
						
					// EF 003 - Atualização de Dados Contratuais.
					Case (cAlias)->PA6_ALIAS == "SR3"
						lOk := U_F0600301((cAlias)->PA6_ALIAS, cId, (cAlias)->PA6_OPERAC, (cAlias)->PA6_RECNOT, "2")
						
					// EF 003 - Atualização de Dados Contratuais.
					Case (cAlias)->PA6_ALIAS == "SR7"
						lOk := U_F0600301((cAlias)->PA6_ALIAS, cId, (cAlias)->PA6_OPERAC, (cAlias)->PA6_RECNOT, "3")
						
					// EF 003 - Atualização de Dados Contratuais.
					Case (cAlias)->PA6_ALIAS == "SR9"
						lOk := U_F0600301((cAlias)->PA6_ALIAS, cId, (cAlias)->PA6_OPERAC, (cAlias)->PA6_RECNOT)
						
					// EF 005 - Cadastro de Férias.
					Case (cAlias)->PA6_ALIAS == "SRH"
						lOk := U_F0600501(cId, (cAlias)->PA6_OPERAC, (cAlias)->PA6_RECNOT)
						
					// EF 007 - Transferencias.
					Case (cAlias)->PA6_ALIAS == "SRE"
						
						If AllTrim((cAlias)->PA6_FUNC) == "F0600301"
							lOk := U_F0600301((cAlias)->PA6_ALIAS, cId, (cAlias)->PA6_OPERAC, (cAlias)->PA6_RECNOT, "6")
						Else
							lOk := U_F0600701(cId, (cAlias)->PA6_OPERAC, (cAlias)->PA6_RECNOT)
						EndIf
						
					// EF 006 - Aprovacao Recisao
					Case (cAlias)->PA6_ALIAS == "RH3"
						lOk := U_F0600602(cId, "RH3", (cAlias)->PA6_RECNOT, (cAlias)->PA6_OPERAC)						
						
					// EF 011 - Exclusao Calculo Rescisao
					Case (cAlias)->PA6_ALIAS == "SRG"
						If AllTrim((cAlias)->PA6_FUNC) == "F0601101" 
							lOk := U_F0601101(cId, "SRG", (cAlias)->RECPA6, (cAlias)->PA6_OPERAC)	
						Else
							lOk := U_F0600602(cId, "SRG", (cAlias)->PA6_RECNOT, (cAlias)->PA6_OPERAC)						
						Endif		

					EndCase

					If lOk 
						UpdatePA6(cId)
					Else
						DisarmTran()
					EndIf
				End Transaction	
			
			(cAlias)->(dbSkip())
					
				
			EndDo
			
			RpcClearEnv() // Desconecta ambiente.
			
		EndIf
		
		Conout("F0600103 - Final Thread: " + cValToChar(ThreadID()))
		
		UnLockByName("F0600103_" + cEmpIni, .F., .F.)
		
	EndIf
	
Return

/*/{Protheus.doc} UpdatePA6
Atualiza data de envio.

@project	MAN0000007423040_EF_001
@type 		function
@author 	alexandre.arume
@since 		09/11/2016
@version 	1.0
@return 	${return}, ${return_description}

/*/
Static Function UpdatePA6(cId)
	
	dbSelectArea("PA6")
	PA6->(dbSetOrder(1))
	If PA6->(DbSeek(FWXFILIAL("PA6") + cId))
		
		RecLock("PA6", .F.)
		PA6->PA6_DATENV := Date()
		PA6->(MsUnlock())
		
	EndIf
	
Return
