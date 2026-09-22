#include "protheus.ch"
#include "TOPCONN.CH"
/*/{Protheus.doc} F0600106
Função responsável pelas integrações de RH
@type User function
@author nairan.silva
@since 01/11/2016
@version 12.7
@param cNomAlias, character, Nome da Tabela
@project	MAN0000007423040_EF_001,MAN0000007423040_EF_002,
@project	MAN0000007423040_EF_003,MAN0000007423040_EF_005,MAN0000007423040_EF_007
@return Nil
/*/
User Function F0600106(cNomAlias)
Local cFuncF001	:= "GPEA010|TRMA100|RSPM001"
Local cFuncF002	:= "GPEA240|MDTA685|MDTA410|AMS00001|DOR007RH|U_DOR007RH|DOR008RH|U_DOR008RH|GPEA011"
Local cFuncF003	:= "GPEA010|TRMA100|PONA160|GPER200|GPEM690|CSAA080"
Local cFuncF005	:= "GPEM060|GPEM030"
Local cFuncF007	:= "GPEA180"

// 28/06/2018 : Rogerio Carvalho - AMS
// Desligando integracao via ponto de entrada para fazer por JOB
//If AllTrim(cNomAlias) == "SRA" 
//    If AllTrim(FunName()) $ cFuncF001 //Admissão
//		FldSettrigger(RA_FILIAL,8192 + 16384 + 32768,{|X,Y| U_F0600100(x,y)}) //-- Nairan: O PE CheckFile parou de funcionar na integração da SRA. Foi desenvolvido o PE 
//    EndIf
//Endif
// Fim - Rogerio Carvalho - AMS

// 28/05/2018 : Rogerio Carvalho - AMS
// Desligando integracao via ponto de entrada para fazer por JOB 
//If AllTrim(cNomAlias) == "SR8" //Afastamento
//	If AllTrim(FunName()) $ cFuncF002
//		FldSettrigger(R8_FILIAL,8192 + 16384 + 32768,{|X,Y| U_F0600200(x,y)})
//	Endif
//Endif
// Fim - Rogerio Carvalho - AMS

//If AllTrim(cNomAlias) == "SR9" //Carga Horária/Sindicato
//	If AllTrim(FunName()) $ cFuncF003
//		FldSettrigger(R9_FILIAL,8192 + 16384 + 32768,{|X,Y| U_F0600300(x,y,"SR9")})
//	EndIf
//Endif

//If AllTrim(cNomAlias) == "SR7"//Função
//	If AllTrim(FunName()) $ cFuncF003
//		FldSettrigger(R7_FILIAL,8192 + 16384 + 32768,{|X,Y| U_F0600300(x,y,"SR7")})
//	EndIf
//Endif

//If AllTrim(cNomAlias) == "SR3"//Salário
//	If AllTrim(FunName()) $ cFuncF003
//		FldSettrigger(R3_FILIAL,8192 + 16384 + 32768,{|X,Y| U_F0600300(x,y,"SR3")})
//	Endif
//Endif

//If AllTrim(cNomAlias) == "SPF"//Turno
//	If AllTrim(FunName()) $ cFuncF003
//		FldSettrigger(PF_FILIAL,8192 + 16384 + 32768,{|X,Y| U_F0600300(x,y,"SPF")})
//	Endif
//Endif

// 14/05/2018 : Rogerio Carvalho - AMS
// Desligando integracao via ponto de entrada para fazer por JOB 
// If AllTrim(cNomAlias) == "SRH"//Férias
//	 If AllTrim(FunName()) $ cFuncF005
//		FldSettrigger(RH_FILIAL,8192 + 16384 + 32768,{|X,Y| U_F0600500(x,y)})
//	 Endif
// Endif
// Fim - Rogerio Carvalho - AMS
/*  ticket n° 6051318 - 415966 - Paulo Dias - estrutura comentada..chamada da integração de transferência direto no F0600700
If AllTrim(cNomAlias) == "SRE"//Transferência
	If AllTrim(FunName()) $ cFuncF007
		FldSettrigger(RE_FILIAL,8192 + 16384 + 32768,{|X,Y| U_F0600700(x,y)})
	Endif
Endif

Return .T.
*/

/*/{Protheus.doc} F0600100
Integração com o Cadastro de Funcionário
@type User function
@author nairan.silva
@since 01/11/2016
@version 12.7
@param cCampo, character, Nome do Campo
@param nModo, numérico, Tipo de Operação
@project	MAN0000007423040_EF_001
@return Nil
/*/
User Function F0600100(cCampo,nModo)
Local nCodInsert 	:= 8192
Local aArea      	:= GetArea()
Local lRet			:= .T.
Local cOper			:= "UPSERT"

If nModo == nCodInsert
	
	U_F0600901("F0600101",; // cFunc 
				SRA->(RECNO()),; // nRecno 
				"SRA",; // cAliasTrb 
				SRA->RA_FILIAL + SRA->RA_MAT,; // cChave 
				"",; // cObs
				CTOD(""),; // Data de envio
				cOper) // Operacao
Endif

Return lRet

/*/{Protheus.doc} F0600200
Integração com o Cadastro de Afastamento
@type User function
@author nairan.silva
@since 01/11/2016
@version 12.7
@param cCampo, character, Nome do Campo
@param nModo, numérico, Tipo de Operação
@project	MAN0000007423040_EF_002
@return Nil
/*/
User Function F0600200(cCampo,nModo)
Local nCodDelete 	:= 32768
Local aArea      	:= GetArea()
Local lRet			:= .T.
Local cOper			:= Iif(nModo == nCodDelete, "DELETE", "UPSERT")
Local cCodAlt		:= 16384

If cCodAlt == nModo 	//Alteração Nairan 22/02/2017 - Solicitação do Ronaldo para integração com ApData
	U_F0600901("F0600201",; // cFunc 
				SR8->(RECNO()),; // nRecno 
				"SR8",; // cAliasTrb 
				SR8->R8_FILIAL + SR8->R8_MAT + DTOS(SR8->R8_DATAINI) + SR8->R8_TIPO,; // cChave 
				"",; // cObs
				CTOD(""),; // Data de envio
				"DELETE") // Operacao

	U_F0600901("F0600201",; // cFunc 
				SR8->(RECNO()),; // nRecno 
				"SR8",; // cAliasTrb 
				SR8->R8_FILIAL + SR8->R8_MAT + DTOS(SR8->R8_DATAINI) + SR8->R8_TIPO,; // cChave 
				"",; // cObs
				CTOD(""),; // Data de envio
				cOper) // Operacao
Else
	U_F0600901("F0600201",; // cFunc 
				SR8->(RECNO()),; // nRecno 
				"SR8",; // cAliasTrb 
				SR8->R8_FILIAL + SR8->R8_MAT + DTOS(SR8->R8_DATAINI) + SR8->R8_TIPO,; // cChave 
				"",; // cObs
				CTOD(""),; // Data de envio
				cOper) // Operacao
EndIf

Return lRet

/*/{Protheus.doc} F0600300
Cadastro de Alteração de Dados Contratuais
@type User function
@author nairan.silva
@since 01/11/2016
@version 12.7
@param cCampo, character, Nome do Campo
@param nModo, numérico, Tipo de Operação
@param cAliasTrb, character, Alias utilizado
@project	MAN0000007423040_EF_003
@return Nil
/*/
User Function F0600300(cCampo,nModo,cAliasTrb)
Local nCodDelete 	:= 32768
Local aArea      	:= GetArea()
Local lRet			:= .T.
Local cOper			:= Iif(nModo == nCodDelete, "DELETE", "UPSERT")

//If nModo != nCodDelete
	//lRet := U_F0600301(cAliasTrb)//Realiza a Chamada da função de integração F06003.
	
	// Troca de Turno.
	If cAliasTrb == "SPF"
	
		U_F0600901("F0600301",; // cFunc 
					SPF->(RECNO()),; // nRecno 
					"SPF",; // cAliasTrb 
					SPF->PF_FILIAL + SPF->PF_MAT + DTOS(SPF->PF_DATA),; // cChave 
					"",; // cObs
					CTOD(""),; // Data de envio
					cOper) // Operacao
								
	// Troca de Função.
	ElseIf cAliasTrb == "SR7"
	
		U_F0600901("F0600701",; // cFunc 
					SR7->(RECNO()),; // nRecno 
					"SR7",; // cAliasTrb 
					SR7->R7_FILIAL + SR7->R7_MAT + DTOS(SR7->R7_DATA) + SR7->R7_TIPO,; // cChave 
					"",; // cObs
					CTOD(""),; // Data de envio
					cOper) // Operacao
					
	// Troca de Sindicato/Carga Horária.
	ElseIf cAliasTrb == "SR9" .and. SR9->R9_CAMPO $ "|RA_HRSMES|RA_SINDICA|"
	
		U_F0600901("F0600301",; // cFunc 
					SR9->(RECNO()),; // nRecno 
					"SR9",; // cAliasTrb 
					SR9->R9_FILIAL + SR9->R9_MAT + SR9->R9_CAMPO + DTOS(SR9->R9_DATA),; // cChave 
					"",; // cObs
					CTOD(""),; // Data de envio
					cOper) // Operacao
					
	EndIf
						
//Endif

Return lRet

/*/{Protheus.doc} F0600500
Cadastro de Férias
@type User function
@author nairan.silva
@since 01/11/2016
@version 12.7
@param cCampo, character, Nome do Campo
@param nModo, numérico, Tipo de Operação
@project	MAN0000007423040_EF_005
@return Nil
/*/
User Function F0600500(cCampo,nModo)
Local nCodInsert := 8192
Local nCodDelete := 32768
Local aArea      := GetArea()
Local lRet		:= .T.
Local cOper		:= Iif(nModo == nCodDelete, "DELETE", "UPSERT")

If nModo == nCodInsert .OR. nModo == nCodDelete
	
	U_F0600901("F0600501",; // cFunc 
				SRH->(RECNO()),; // nRecno 
				"SRH",; // cAliasTrb 
				SRH->RH_FILIAL + SRH->RH_MAT + DTOS(SRH->RH_DATAINI),; // cChave 
				"",; // cObs
				CTOD(""),; // Data de envio
				cOper) // Operacao
Endif

Return lRet

/*/{Protheus.doc} F0600700
Integração com o Cadastro de Funcionário
@type User function
@author nairan.silva
@since 01/11/2016
@version 12.7
@param cCampo, character, Nome do Campo
@param nModo, numérico, Tipo de Operação
@project	MAN0000007423040_EF_007
@return Nil
/*/

/*
User Function F0600700(cCampo,nModo)
//Local nCodInsert := 8192
Local aArea         := GetArea()
Local lRet			:= .T.
Local cOper			:= "UPSERT"
Local cQuery        := "   "
Local cPA6IDa       := " "
Local cPA6IDb       := " "
Local cQryUPDa   	:= " "
Local cQryUPDb   	:= " "
//If nModo == nCodInsert

	 cQuery  := "SELECT RE_FILIALD,RE_FILIALP,RE_MATD,RE_MATP,RE_CCD,RE_CCP, SRE.R_E_C_N_O_ "
	 cQuery  += "FROM "+ RetSqlName("SRE") + " SRE " 
	 cQuery  += "WHERE SRE.D_E_L_E_T_ = ' ' "
	 //cQuery  += "AND RE_MATD = '171940' "
	 //cQuery  += "AND RE_MATD = '171940' "
	 cQuery  += "AND RE_XDTPA6 <> ' ' " //TESTE INVERSO PARA FACILITAR PROCESSO..DEPOIS INVERTER O SINAL
	 cQuery  += "AND RE_XIDINC = '                                    ' "  
	 cQuery  += "ORDER BY SRE.R_E_C_N_O_  "
	
	If Select("TSRE") > 0
		TSRE->(DbCloseArea())
	EndIf
	
	TCQUERY cQuery NEW ALIAS "TSRE"
	
	TSRE->( dbGoTop() )
	
 	While TSRE->(!Eof())

		If  TSRE->RE_CCD <> TSRE->RE_CCP

			cPA6IDa :=  U_F0600901("F0600301",; // cFunc 
						TSRE->(R_E_C_N_O_),; // nRecno 
						"SRE",; // cAliasTrb 
						TSRE->RE_FILIALD + TSRE->RE_MATD,; // cChave 
						"",; // cObs
						CTOD(""),; // Data de envio
						cOper,; // Operacao
						TSRE->RE_FILIALD)

		    cQryUPDa := "UPDATE "+ RetSqlName("SRE") + " SRE "   
			cQryUPDa += "SET RE_XIDINC = '" + cPA6IDa + "' , "
			cQryUPDa += "RE_XDTPA6 = '  '  " //aqui colocar função DATE(), após os testes
			//cQryUPDa += "RE_XDTPA6 = '" + Date() + "'   "
			cQryUPDa += "WHERE D_E_L_E_T_= ' ' "
			cQryUPDa += "AND RE_XIDINC = '                                    ' "	
			cQryUPDa +=	"AND RE_XDTPA6 <> ' ' "	
			cQryUPDa += "AND RE_FILIALD = '"+ TSRE->RE_FILIALD + "' "
			cQryUPDa += "AND RE_FILIALP = '"+ TSRE->RE_FILIALP + "' "
			cQryUPDa += "AND RE_MATD = '"+ TSRE->RE_MATD + "' "
			cQryUPDa += "AND RE_MATP = '"+ TSRE->RE_MATP + "' 

			nExecSql := TCSQLEXEC(cQryUPDa) 

				If nExecSql > 0
					If !lIntRot
							Conout ( "TRANSFERÊNCIAS - Erro na atualização de integração da tabela SRE." )
					Endif
				Endif
			
			cQryUPDa := " "
		
		EndIf
	
		If  TSRE->RE_FILIALD <> TSRE->RE_FILIALP .OR.;
			TSRE->RE_DEPTOD <> TSRE->RE_DEPTOP .OR.; 
			TSRE->RE_PROCESD <> TSRE->RE_PROCESP

			cPA6IDb :=  U_F0600901("F0600701",; // cFunc 
						TSRE->(R_E_C_N_O_),; // nRecno 
						"SRE",; // cAliasTrb 
						TSRE->RE_FILIALD + TSRE->RE_MATD,; // cChave 
						"",; // cObs
						CTOD(""),; // Data de envio
						cOper,; // Operacao
						TSRE->RE_FILIALD) 

		    cQryUPDb := "UPDATE "+ RetSqlName("SRE") + " SRE "  
			cQryUPDb += " SET RE_XIDINC = '" + cPA6IDb + "' , "
			cQryUPDb += "RE_XDTPA6 = '  '  " //aqui colocar função DATE(), após os testes
			cQryUPDb += "WHERE D_E_L_E_T_= ' ' "
			//cQryUPDb += "AND RE_XDTPA6 = '" + Date() + "'   "
			cQryUPDb += "AND RE_XIDINC = '                                    '"
			cQryUPDb +=	"AND RE_XDTPA6 <> ' ' "			
			cQryUPDb += "AND RE_FILIALD = '"+ TSRE->RE_FILIALD + "' "
			cQryUPDb += "AND RE_FILIALP = '"+ TSRE->RE_FILIALP + "' "
			cQryUPDb += "AND RE_MATD = '"+ TSRE->RE_MATD + "' "
			cQryUPDb += "AND RE_MATP = '"+ TSRE->RE_MATP + "' "

			nExecSql := TCSQLEXEC(cQryUPDb) 

				If nExecSql > 0
					If !lIntRot
							Conout ( "TRANSFERÊNCIAS - Erro na atualização de integração da tabela SRE." )
					Endif
				Endif
			
			cQryUPDb := " "
		
		EndIf
	
	TSRE->(dbskip())

	Enddo

	TSRE->(DbCloseArea())
	
	Restarea(aArea)

Return lRet 
*/