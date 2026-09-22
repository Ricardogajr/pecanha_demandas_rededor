#Include 'Protheus.ch'

/*
{Protheus.doc} GP010FIMPE()
O ponto de entrada será chamado após o término da gravação de todos os dados e execução de todas as integrações.

@Author     Henrique
@Since      23/11/2016
@Version    P12.1.07
@Project    
*/
User Function GP010FIMPE()

	Local cFilSRA := cFilant
	Local cMatSRA := SRA->RA_MAT
	Local dDataSRA := date()	
	Local cFilMat  := SRA->RA_FILIAL
	Local cPostMat := SRA->RA_POSTO 

	//Valida pelos parametros se essa empresa irá executar essas chamadas.
	If !U_VALIDEMP()
		Return
	EndIf
	
	// 416094 - Rogerio Carvalho - AMS Rio - 17/10/2018 DOR05218784 - Melhoria Transferencia entre Postos
	U_AmsCntSt(cFilMat,cPostMat) // Ao cadastrar novo funcionario , recontar titulares e substitutos do posto
	// Fim 416094 - Rogerio Carvalho - AMS Rio - 17/10/2018 - DOR05218784 - Melhoria Transferencia entre Postos

	// 416094 - Rogerio Carvalho - AMS Rio - 13/07/2018 - DOR04520620
	// Função abaixo desligada, pois está sendo a integração está sendo feita por JOB  
	//U_F0600107() 			
	// Fim 416094 - Rogerio Carvalho - AMS Rio - 13/07/2018 - DOR04520620

	cQuerySR9 := " UPDATE "+ RetSqlName("SR9")   
	cQuerySR9 += " SET R9_XDTOPER = '"+dtos(date())+"' , "
	cQuerySR9 += " R9_XHROPER = '"+time()+"' "	
	cQuerySR9 += " WHERE D_E_L_E_T_= ' ' "
	cQuerySR9 += " AND R9_FILIAL = '"+cFilSRA+ "' "
	cQuerySR9 += " AND R9_MAT = '"+cMatSRA+"' "
	//cQuerySR9 += " AND R9_CAMPO IN ('RA_PIS    ','RA_HRSMES ') " Thais Paiva - 14205299
	cQuerySR9 += " AND R9_CAMPO IN ('RA_PIS    ','RA_HRSMES ','RA_NOME','RA_CIC','RA_VIEMRAI','RA_ADMISSA','RA_NASC'," //Thais Paiva - 14205299
	cQuerySR9 += " 'RA_NACIONA','RA_TIPOADM','RA_SEXO','RA_DDDFONE','RA_TELEFON')" //Thais Paiva - 14205299
	cQuerySR9 += " AND R9_DATA = '"+dtos(date())+"' "
	cQuerySR9 += " AND R9_XDTOPER = '        ' "
	cQuerySR9 += " AND R9_XHROPER = '        ' "				
		
	nExecSql := TCSQLEXEC(cQuerySR9) 

Return
