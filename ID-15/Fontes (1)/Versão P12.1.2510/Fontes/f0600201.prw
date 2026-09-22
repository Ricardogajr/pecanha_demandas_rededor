#include "protheus.ch"

/*/{Protheus.doc} F0600201
Integração de Cadastro de Afastamentos Protheus com legado Rede D’or.

@project	MAN0000007423040_EF_001
@type 		function
@author 	alexandre.arume
@since 		31/10/2016
@version 	1.0
@param 		cId, character, Id
@param 		cOper, character, Operacao - upsert ou delete
@param 		nRecno, numerico, Número do registro sendo inserido
@return 	lRet, Integração com sucesso ou não.

/*/
User Function F0600201(cId, cOper, nRecno)
	
	Local cTbl			:= "EF06002"
	Local aTblStru		:= {{"EF06002_ID", "VARCHAR", 32},;
							{"EF06002_FILIAL", "VARCHAR", 8},;
							{"EF06002_MATRICULA", "VARCHAR", 6},;
							{"EF06002_DTINIAFAST", "VARCHAR", 8},;
							{"EF06002_TIPOAFAST", "VARCHAR", 3},;
							{"EF06002_DTFIMAFAST", "VARCHAR", 8},;
							{"EF06002_DTTRANSAC", "VARCHAR", 8},;
							{"EF06002_HRTRANSAC", "VARCHAR", 8},;
							{"EF06002_OPERACAO", "VARCHAR", 6},;
							{"EF06002_STATUS", "VARCHAR", 1},;
							{"EF06002_DTPROCESS", "VARCHAR", 8},;
							{"EF06002_HRPROCESS", "VARCHAR", 8},;
							{"EF06002_OBSERVA", "VARCHAR", 700}}
	Local aValues		:= {}
	Local lRet			:= .T.
	
	dbSelectArea("SR8")
	dbGoTo(nRecno)
	
	aValues 	:= {cId,;
					SR8->R8_FILIAL,;
					SR8->R8_MAT,;
					SR8->R8_DATAINI,;
					SR8->R8_TIPOAFA,;
					SR8->R8_DATAFIM,;
					dDataBase,;
					TIME(),;
					cOper,;
					"1",;
					"",;
					"",;
					""}
	
	// Gravação na tabela de interface.
	lRet := U_F0600102(cTbl, aTblStru, aValues)
	
Return lRet
