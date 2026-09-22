#include "protheus.ch"

/*/{Protheus.doc} F0600101
Integração de Cadastro de Funcionários.

@project	MAN0000007423040_EF_001
@type 		function
@author 	alexandre.arume
@since 		31/10/2016
@version 	1.0
@param 		cId, character, Id
@param 		nRecno, numerico, Recno do Registro
@return 	lRet, Integração com sucesso ou não.

/*/
User Function F0600101(cId,nRecno)
	
	Local aAreaPA6		:= PA6->(GetArea())
	Local cTbl			:= "EF06001"
	Local aTblStru		:= {{"EF06001_ID", "VARCHAR", 32},;
							{"EF06001_EMPRESA", "VARCHAR", 2},;
							{"EF06001_FILIAL", "VARCHAR", 8},;
							{"EF06001_MATRICULA", "VARCHAR", 6},;
							{"EF06001_CPF", "VARCHAR", 11},;
							{"EF06001_NOME", "VARCHAR", 30},;
							{"EF06001_NOMECOMP", "VARCHAR", 70},;
							{"EF06001_PIS", "VARCHAR", 12},;
							{"EF06001_SINDICA", "VARCHAR", 2},;
							{"EF06001_CATFUNC", "VARCHAR", 1},;
							{"EF06001_ADMISSA", "VARCHAR", 8},;
							{"EF06001_DTNASC", "VARCHAR", 8},;
							{"EF06001_NACIONA", "VARCHAR", 2},;
							{"EF06001_TIPOADM", "VARCHAR", 2},;
							{"EF06001_SALARIO", "VARCHAR", 15},;
							{"EF06001_SEXO", "VARCHAR", 1},;
							{"EF06001_CARGO", "VARCHAR", 5},;
							{"EF06001_DDDFONE", "VARCHAR", 3},; // ticket n° 6207123 - 415966 - Paulo Dias - ajuste campos para insert na EF06001
							{"EF06001_TELEFON", "VARCHAR", 20},;
							{"EF06001_CC", "VARCHAR", 11},;
							{"EF06001_TNOTRAB", "VARCHAR", 3},;
							{"EF06001_HRSMES", "VARCHAR", 8},;
							{"EF06001_XMARPTO", "VARCHAR", 1},;
							{"EF06001_DTTRANSAC", "VARCHAR", 8},;
							{"EF06001_HRTRANSAC", "VARCHAR", 8},;
							{"EF06001_OPERACAO", "VARCHAR", 6},;
							{"EF06001_STATUS", "VARCHAR", 10},;
							{"EF06001_DTPROCESS", "VARCHAR", 8},;
							{"EF06001_HRPROCESS", "VARCHAR", 8},;
							{"EF06001_OBSERVA", "VARCHAR", 700}}
	Local aValues		:= {}
	Local lRet			:= .T.
	dbSelectArea("SRA")
	dbGoTo(nRecno)
	aValues 	:= {cId,;
					SM0->M0_CODIGO,;
					SRA->RA_FILIAL,;
					SRA->RA_MAT,;
					SRA->RA_CIC,;
					SRA->RA_NOME,;
					SRA->RA_NOMECMP,;
					SRA->RA_PIS,;
					SRA->RA_SINDICA,;
					SRA->RA_CATFUNC,;
					SRA->RA_ADMISSA,;
					SRA->RA_NASC,;
					SRA->RA_NACIONA,;
					SRA->RA_TIPOADM,;
					SRA->RA_SALARIO,;
					SRA->RA_SEXO,;
					SRA->RA_CARGO,;
					Left(SRA->RA_DDDFONE,2),; // ticket n° 6207123 - 415966 - Paulo Dias - solicitação do gerente de TI Alexandre para ajuste do campo, onde integração espera tamanho 2
					SRA->RA_TELEFON,;
					SRA->RA_CC,;
					SRA->RA_TNOTRAB,;
					SRA->RA_HRSMES,;
					SRA->RA_XMARPTO,;
					dDataBase,;
					TIME(),;
					POSICIONE("PA6",1,SRA->RA_FILIAL+cId,"PA6_OPERAC"),;
					"1",;
					"",;
					"",;
					""}
	
	// Gravação na tabela de interface.
	lRet := U_F0600102(cTbl, aTblStru, aValues)
	RestArea(aAreaPA6)
Return lRet
