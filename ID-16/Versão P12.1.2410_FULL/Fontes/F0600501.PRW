#include "protheus.ch"

/*/{Protheus.doc} F0600501
Integração de Cadastro de Férias.

@project	MAN0000007423040_EF_001
@type 		function
@author 	alexandre.arume
@since 		27/10/2016
@version 	1.0
@param 		cId, character, Id
@param 		cOper, character, Operacao - upsert ou delete
@param 		nRecno, numero, numero do registro
@return 	lRet, Integração com sucesso ou não.

/*/
User Function F0600501(cId, cOper, nRecno)
	
	Local cTbl			:= "EF06005"
	Local aTblStru		:= {{"EF06005_ID", "VARCHAR", 32},;
							{"EF06005_FILIAL", "VARCHAR", 8},;
							{"EF06005_MATRICULA", "VARCHAR", 6},;
							{"EF06005_DTINIFERIAS", "VARCHAR", 8},;
							{"EF06005_DTFIMFERIAS", "VARCHAR", 8},;
							{"EF06005_DTTRANSAC", "VARCHAR", 8},;
							{"EF06005_HRTRANSAC", "VARCHAR", 8},;
							{"EF06005_OPERACAO", "VARCHAR", 6},;
							{"EF06005_STATUS", "VARCHAR", 1},;
							{"EF06005_DTPROCESS", "VARCHAR", 8},;
							{"EF06005_HRPROCESS", "VARCHAR", 8},;
							{"EF06005_OBSERVA", "VARCHAR", 700}}
	Local aValues		:= {}
	Local lRet			:= .T.
	
	dbSelectArea("SRH")
	dbGoTo(nRecno)
	
	aValues 	:= {cId,;
					SRH->RH_FILIAL,;
					SRH->RH_MAT,;
					SRH->RH_DATAINI,;
					SRH->RH_DATAFIM,;
					dDataBase,;
					TIME(),;
					cOper,;
					"1",;
					"",;
					"",;
					""}
	
	// Gravação na tabela de interface.
	lRet := U_F0600102(cTbl, aTblStru, aValues)
	
Return .T.
