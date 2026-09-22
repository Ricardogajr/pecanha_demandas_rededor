#include "TOTVS.ch"

/*/{Protheus.doc} F0600701
Integração de Cadastro de Troca de Empresas.

@project	MAN0000007423040_EF_007
@type 		function
@author 	alexandre.arume
@since 		04/11/2016
@version 	1.0
@param cId, characters, descricao
@param cOper, characters, descricao
@param nRecno, numeric, descricao
@return 	$lRet, Integração com sucesso ou não.

/*/
User Function F0600701(cId, cOper, nRecno)
	
	Local cTbl			:= "EF06007"
	Local aTblStru		:= {{"EF06007_FILIAL", "VARCHAR", 8},;  // ticket n° 6051318 - 415966 - Paulo Dias - add coluna para o "where" no monitor na EF06007
							{"EF06007_ID", "VARCHAR", 32},;
							{"EF06007_FILIALORI", "VARCHAR", 8},;
							{"EF06007_MATRICORI", "VARCHAR", 6},;
							{"EF06007_CCUSTOORI", "VARCHAR", 11},;
							{"EF06007_DEPTOORI", "VARCHAR", 9},;
							{"EF06007_PROCORI", "VARCHAR", 5},;
							{"EF06007_ITEMORI", "VARCHAR", 11},; // ticket n° 6051318 - 415966 - Paulo Dias - ajuste campos para insert na EF06007 
							{"EF06007_CLVLOR", "VARCHAR", 11},;  // ticket n° 6051318 - 415966 - Paulo Dias - ajuste campos para insert na EF06007
							{"EF06007_FILIALDST", "VARCHAR", 8},;
							{"EF06007_MATRICDST", "VARCHAR", 6},;
							{"EF06007_CCUSTODST", "VARCHAR", 11},;
							{"EF06007_DEPTODST", "VARCHAR", 9},;
							{"EF06007_PROCDST", "VARCHAR", 5},;
							{"EF06007_ITEMDST", "VARCHAR", 11},; // ticket n° 6051318 - 415966 - Paulo Dias - ajuste campos para insert na EF06007
							{"EF06007_CLVLDST", "VARCHAR", 11},; // ticket n° 6051318 - 415966 - Paulo Dias - ajuste campos para insert na EF06007
							{"EF06007_DTTRANSF", "VARCHAR", 8},;
							{"EF06007_DTTRANSAC", "VARCHAR", 8},;
							{"EF06007_HRTRANSAC", "VARCHAR", 8},;
							{"EF06007_OPERACAO", "VARCHAR", 6},;
							{"EF06007_STATUS", "VARCHAR", 1},;
							{"EF06007_DTPROCESS", "VARCHAR", 8},;
							{"EF06007_HRPROCESS", "VARCHAR", 8},;
							{"EF06007_OBSERVA", "VARCHAR", 700}}
	Local aValues		:= {}
	Local lRet			:= .T.
	
	dbSelectArea("SRE")
	dbGoTo(nRecno)
	
	aValues := {Left(SRE->RE_FILIALD,8),; // ticket n° 6051318 - 415966 - Paulo Dias - add coluna para o "where" no monitor na EF06007
				cId,; 
				Left(SRE->RE_FILIALD,8),; // ticket n° 6051318 - 415966 - Paulo Dias - ajuste campos para insert na EF06007 
				SRE->RE_MATD,;
				SRE->RE_CCD,; 
				SRE->RE_DEPTOD,; 
				SRE->RE_PROCESD,; 
				Left(SRE->RE_ITEMD,9),; // ticket n° 6051318 - 415966 - Paulo Dias - ajuste campos para insert na EF06007 
				Left(SRE->RE_CLVLD,9),; // ticket n° 6051318 - 415966 - Paulo Dias - ajuste campos para insert na EF06007 
				Left(SRE->RE_FILIALP,8),; 
				SRE->RE_MATP,; 
				SRE->RE_CCP,; 
				SRE->RE_DEPTOP,; 
				SRE->RE_PROCESP,; 
				Left(SRE->RE_ITEMP,9),; // ticket n° 6051318 - 415966 - Paulo Dias - ajuste campos para insert na EF06007 
				Left(SRE->RE_CLVLP,9),; // ticket n° 6051318 - 415966 - Paulo Dias - ajuste campos para insert na EF06007 
				SRE->RE_DATA,; 
				dDataBase,; 
				TIME(),;  
				"UPSERT",; 
				"1",; 
				"",; 
				"",; 
				""} 
	
	// Gravação na tabela de interface.
	lRet := U_F0600102(cTbl, aTblStru, aValues)
		
Return lRet
