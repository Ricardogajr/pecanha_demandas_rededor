#Include 'Protheus.ch'

#Define cPerg Padr("FSW1302800",10)
/*
{Protheus.doc} F1302800()
Informações do Relatório de Solicitações
@Author     Henrique Madureira
@Since      05/02/2018
@Version    P12.1.07
@Project    MAN0000007423048_EF_028
@Param		cCodigo, caracter, código do tipo de solicitação
@Return 	aDadosSol, dados da solicitação
*/
User Function F1302800(cCodigo)

	Local aDadosSol := {}
	Default cCodigo := ""

	aDadosSol := U_F1302810(cCodigo)
	
Return aDadosSol

/*
{Protheus.doc} F1302810()
Busca as informações do Relatório de Solicitações
@Author     Henrique Madureira
@Since      05/02/2018
@Version    P12.1.07
@Project    MAN0000007423048_EF_028
@Param		cCodigo, caracter, código do tipo de solicitação
@Return 	aDadosSol, dados da solicitação
*/
User Function F1302810(cCodigo)

	Local cEOL      := CHR(13) + CHR(10)
	Local cAliasTmp := "TMP"
	Local cQuery    := ""
	Local aAux      := {}
	Local cCPFSolic := ""
	Local cFilVaga	:= ""
	Local cCodVaga	:= ""
	Local aCandidato:= {"",""}
	
	
	Default cCodigo := ""
	
	MakeSqlExpr( cPerg )
	
	cQuery := "SELECT RH3_FILIAL, RH3_CODIGO, RH3_MAT, RH3_STATUS, RH3_DTSOLI, "
	cQuery += "       RH3_DTATEN, RH3_FILINI, RH3_MATINI, RH3_FILAPR, RH3_MATAPR, "
	cQuery += "       RH3_XTPCTM, RH3_XCODAL, RH3_XFILAP, RH3_XMATAP, RH3_XDTAPV, RH3_VISAO, RH3_NVLAPR "
	cQuery += "FROM " + RETSQLNAME('RH3') + " RH3 "
	cQuery += "WHERE RH3.D_E_L_E_T_ = ' ' "
 	cQuery += "      AND RH3_XTPCTM = '" + cCodigo + "' "
	
	If !(EMPTY(MV_PAR01))
		cQuery += "      AND " + MV_PAR01 + " "
	EndIf
	If !(EMPTY(MV_PAR02))
		cQuery += "      AND " + MV_PAR02 + " "
	EndIf
	If !(Empty(MV_PAR03)) .AND. !(Empty(MV_PAR04))
		cQuery += " AND RH3_DTSOLI BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
	EndIf
	cQuery += "ORDER BY RH3_FILIAL, RH3_CODIGO "
		
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp)

	

	While (cAliasTmp)->(!(EOF()))
		aPa5Inf  := U_F1302813((cAliasTmp)->RH3_FILIAL, (cAliasTmp)->RH3_CODIGO)
		aRespons := U_F1302811( (cAliasTmp)->RH3_FILAPR,;
								(cAliasTmp)->RH3_MATAPR,;
								(cAliasTmp)->RH3_XCODAL,;
								(cAliasTmp)->RH3_NVLAPR,;
								(cAliasTmp)->RH3_FILIAL)
		
		cCPFSolic := POSICIONE("SRA",1,(cAliasTmp)->RH3_FILINI + (cAliasTmp)->RH3_MATINI,"RA_CIC")
		
		If cCodigo == "004"
			aCandidato := U_F1302815((cAliasTmp)->RH3_FILIAL, (cAliasTmp)->RH3_CODIGO,(cAliasTmp)->RH3_XTPCTM) 
		EndIf 
		
		AADD(aAux, {;
					aPa5Inf[5],;//Departamento Efetivação
					aPa5Inf[4],;//Analista Reponsavel
					aRespons[1],;//Matrícula Aprovador
					aRespons[2],;//Nome Aprovador
					aRespons[3],;//CPF Aprovador
					aRespons[4],;//Cargo Aprovador
					aRespons[5],;//Departamento Aprovador
					aRespons[6],;//Centro de custo Aprovador
					aRespons[7],;//Função Aprovador 
					POSICIONE("RD0",12,XFILIAL("RD0") + (cAliasTmp)->RH3_MATINI, "RD0_LOGIN"),;//Login Solicitante
					(cAliasTmp)->RH3_CODIGO,;//Chamado
					(cAliasTmp)->RH3_MAT,;//Matricula solicitado-12
					IIF(VAL((cAliasTmp)->RH3_STATUS)==1,"Em processo de aprovação",IIF(VAL((cAliasTmp)->RH3_STATUS)==2,"Atendida",IIF(VAL((cAliasTmp)->RH3_STATUS)==3,"Reprovada","Aguardando Efetivação do RH"))),;//Status
					aPa5Inf[9],;//Data de Abertura-14
					(cAliasTmp)->RH3_DTATEN,;//Data de fechamento
					(cAliasTmp)->RH3_FILINI,;//Unidade Solicitante
					(cAliasTmp)->RH3_FILAPR,;//Unidade Aprovação
					(cAliasTmp)->RH3_XDTAPV,;//Data de Aprovação-18
					aPa5Inf[1],;//Hora
					aPa5Inf[2],; //"Data Conclusão" // ticket n° 3345642 - 415966 - Paulo Dias - Inclusão de coluna
					aPa5Inf[3],;//Unidade Efetivação
					POSICIONE("SRA",1,(cAliasTmp)->RH3_FILIAL + (cAliasTmp)->RH3_MAT,"RA_NOME"),;//--22
					POSICIONE("SRA",1,(cAliasTmp)->RH3_FILIAL + (cAliasTmp)->RH3_MAT,"RA_CIC"),;//--23
					POSICIONE("SRA",1,(cAliasTmp)->RH3_FILIAL + (cAliasTmp)->RH3_MAT,"RA_CARGO"),;//--24
					POSICIONE("SRA",1,(cAliasTmp)->RH3_FILIAL + (cAliasTmp)->RH3_MAT,"RA_DEPTO"),;//--25
					POSICIONE("SRA",1,(cAliasTmp)->RH3_FILIAL + (cAliasTmp)->RH3_MAT,"RA_CC"),;//--26
					(cAliasTmp)->RH3_MATINI,;//--27
					POSICIONE("SRA",1,(cAliasTmp)->RH3_FILINI + (cAliasTmp)->RH3_MATINI,"RA_NOME"),;//--28
					cCPFSolic,;//--29
					POSICIONE("PAB",1,XFILIAL("PAB") + (cAliasTmp)->RH3_XCODAL,"PAB_SOLDES"),;//--30
					POSICIONE("PAB",1,XFILIAL("PAB") + (cAliasTmp)->RH3_XCODAL,"PAB_GRPDES"),;//--31
					aPa5Inf[6],;//--32
					aCandidato[1],;//33 - Telefone do candidato
					aCandidato[2],;//34 - Data de nascimento do candidato
					aPa5Inf[7],; //35 "AGUARDANDO EFETIVACAO DO RH" // ticket n° 3345642 - 415966 - Paulo Dias - Inclusão de coluna
					aPa5Inf[8]; //36 "FAP (RE) EFETIVADA" // ticket n° 3345642 - 415966 - Paulo Dias - Inclusão de coluna
					})
		
		aAuxH4   := U_F1302812((cAliasTmp)->RH3_FILIAL, (cAliasTmp)->RH3_CODIGO)		
		If !(EMPTY(aAuxH4)) .AND. cCodigo == '004' 
			If (cAliasTmp)->RH3_XTPCTM == '004'
				cFilVaga	:= AllTrim(IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_FILVAG"})) = 0,'',aAuxH4[var][2]))
				cCodVaga	:= AllTrim(IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_CDVAGA"})) = 0,'',aAuxH4[var][2]))
				
				SQS->(DbSetOrder(1))
				SQS->(DbSeek(cFilVaga + cCodVaga))
				
				AADD(aAux[Len(aAux)],{;
				SQS->QS_VAGA,;
				SQS->QS_XJORN,;
				SQS->QS_FUNCAO,;
				Posicione("RCL", 2, SQS->QS_FILPOST + SQS->QS_POSTO, "RCL_DEPTO"),;
				SQS->QS_CC,;
				SQS->QS_XTURNO +'-'+SQS->QS_XDESTUR,;
				IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_VLVAGA"})) = 0,'',aAuxH4[var][2]),;
				IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_SLFECH"})) = 0,'',aAuxH4[var][2]),;
				IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_NMCAND"})) = 0,'',aAuxH4[var][2]),;
				IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_CPFCAN"})) = 0,'',aAuxH4[var][2]),;
				IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_DTADMI"})) = 0,'',aAuxH4[var][2]),;
				IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_TIPOFA"})) = 0,'',aAuxH4[var][2]),;
				SQS->QS_XSOLFIL,;
				SQS->QS_XSOLPTL,;
				IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_CARGO"})) = 0,'',aAuxH4[var][2]),; //Thais Paiva - 14531848
				IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_FILCAN"})) = 0,'',aAuxH4[var][2]),; //Thais Paiva - 14531848
				IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_CC"})) = 0,'',aAuxH4[var][2]),; //Thais Paiva - 14531848
				IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_MATCOL"})) = 0,'',aAuxH4[var][2]),; //Thais Paiva - 14531848
				IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_SALFUN"})) = 0,'',aAuxH4[var][2]); //Thais Paiva - 14531848
				})
			EndIf
		EndIf
	
		If !(EMPTY(aAuxH4)) .AND. cCodigo =="005"
			AADD(aAux[Len(aAux)],{;
			IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "P10_DTSOLI"})) = 0,'',aAuxH4[var][2]),;
			IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "P10_CODRES"})) = 0,'',aAuxH4[var][2]),;
			IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "P10_DESRES"})) = 0,'',aAuxH4[var][2]),;
			IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "P10_MOTIVO"})) = 0,'',aAuxH4[var][2]),;
			IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "P10_DTDEMI"})) = 0,'',aAuxH4[var][2]);
			})
		EndIf
	
		If !(EMPTY(aAuxH4)) .AND. cCodigo =="006"
			AADD(aAux[Len(aAux)],{;
			IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_D_FUNC"})) = 0,'',aAuxH4[var][2]),;
			IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_SALATU"})) = 0,'',aAuxH4[var][2]),;
			IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA_SALARIO"})) = 0,'',aAuxH4[var][2]),;
			IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_H_M_AT"})) = 0,'',aAuxH4[var][2]),;
			IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_H_S_AT"})) = 0,'',aAuxH4[var][2]),;
			IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_H_D_AT"})) = 0,'',aAuxH4[var][2]),;
			IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA_HRSMES"}))  = 0,'',aAuxH4[var][2]),;
			IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA_HRSEMAN"})) = 0,'',aAuxH4[var][2]),;
			IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA_HRSDIA"}))  = 0,'',aAuxH4[var][2]),;
			IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_CCATU"}))  = 0,'',aAuxH4[var][2]),;
			IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_D_CCAT"})) = 0,'',aAuxH4[var][2]),;
			IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_DEPTOA"})) = 0,'',aAuxH4[var][2]),;
			IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA_CC"}) )     = 0,'',aAuxH4[var][2]),;
			IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_D_CC_D"})) = 0,'',aAuxH4[var][2]),;
			IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA_DEPTO"}))   = 0,'',aAuxH4[var][2]),;
			IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_D_DEPD"})) = 0,'',aAuxH4[var][2]),;
			IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_OBSINC"})) = 0,'',aAuxH4[var][2]),;
			IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA_CODFUNC"})) = 0,'',aAuxH4[var][2]),;
			IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_FILIAL"})) = 0,'',aAuxH4[var][2]),;
			IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA_FILIAL"}))  = 0,'',aAuxH4[var][2]);
			})
		EndIf
		
		(cAliasTmp)->(DbSkip())
	End
	(cAliasTmp)->(DbCloseArea())

Return aAux

/*
{Protheus.doc} F1302811()
Busca as informações do Aprovador
@Author     Henrique Madureira
@Since      05/02/2018
@Version    P12.1.07
@Project    MAN0000007423048_EF_028
@Param		cFilSra,   caracter, filial do aprovador
@Param		cMatriSra, caracter, matricula do aprovador
@Param		cCodAlc,   caracter, código da alçada
@Param		cNvlAlc,   caratcer, item da alçada
@Param		cFilSol,   caracter, filial da solicitação
@Return 	aAux, dados do aprovador
*/
User function F1302811(cFilSra,cMatriSra, cCodAlc, cNvlAlc, cFilSol)

	Local cAliRh4  := "RETRH4"
	Local cPosto   := ""
	Local cMatri   := ""
	Local cNome    := ""
	Local cQuery   := ""
	Local aAux     := {}
	Local cPostApr := ""
	Local cCic     := ""
	Local cCargo   := ""
	Local cDepto   := ""
	Local cCc      := ""
	Local cFuncao  := ""

	Default cFilSra   := ""
	Default cMatriSra := ""

	If PAC->(DbSeek(xFilial("PAC")+ cCodAlc + PADL(cValToChar(cNvlAlc),2,"0")))
		If PA9->(DbSeek(xFilial("PA9")+ PAC->PAC_CODPOS + cFilSol))
			While PA9->(PA9_FILIAL + PA9_CODIGO + PA9_FILSOL)== xFilial("PA9")+ PAC->PAC_CODPOS + cFilSol
				cPostApr += "RCX.RCX_FILIAL ='"+PA9->PA9_FILAPR+"' AND RCX.RCX_POSTO = '"+PA9->PA9_POSAPR+"' " 
				cPostApr += " OR "
				PA9->(DbSkip())
			EndDo	
		EndIf
	EndIf
	
	If PAC->(DbSeek(xFilial("PAC")+ cCodAlc + PADL(cValToChar(cNvlAlc),2,"0")))
		If !Empty(PAC->PAC_CODLG) .And. PAC->PAC_VINCL == "1" .And. PAH->(DbSeek(xFilial("PAH")+ PAC->PAC_CODLG))
			While PAH->(PAH_FILIAL + PAH_CODIGO)== xFilial("PAH")+ PAC->PAC_CODLG
				cPostApr += "RCX.RCX_FILIAL ='"+PAH->PAH_FILPOS+"' AND RCX.RCX_POSTO = '"+PAH->PAH_POSTO+"' " 
				cPostApr += " OR "
				PAH->(DbSkip())
			EndDo
		EndIf
	EndIf	
      
	cPosto := POSICIONE("SRA",1,cFilSra + cMatriSra,"RA_POSTO")
	cPostApr += "RCX.RCX_FILIAL ='"+cFilSra+"' AND RCX.RCX_POSTO = '"+cPosto+"' "
	
	If !(EMPTY(cPosto))
		cQuery := "SELECT SRA.RA_FILIAL, "
		cQuery += "       SRA.RA_MAT, "
		cQuery += "       SRA.RA_NOME, "
		cQuery += "       SRA.RA_CIC, "
		cQuery += "       SRA.RA_CARGO, "
		cQuery += "       SRA.RA_DEPTO, "
		cQuery += "       SRA.RA_CC, "
		cQuery += "       SRA.RA_CODFUNC "
		cQuery += "FROM " + RetSqlName("RCX") + " RCX "
		cQuery += "INNER JOIN " + RetSqlName("SRA") + " SRA  "
		cQuery += "ON SRA.RA_FILIAL = RCX.RCX_FILIAL "
		cQuery += "AND SRA.RA_MAT = RCX.RCX_MATFUN "
		cQuery += "AND SRA.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE ("+cPostApr+")"
		cQuery += "  AND RCX.RCX_SUBST = '2' "
		cQuery += "  AND RCX.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliRh4)

		DbSelectArea(cAliRh4)
		While !(cAliRh4)->(EOF())
			If Empty(cMatri) .AND. Empty(cNome) 
				cMatri  += "" + (cAliRh4)->(RA_MAT)     + ""
				cNome   += "" + (cAliRh4)->(RA_NOME)    + ""
				cCic    += "" + (cAliRh4)->(RA_CIC)     + ""
				cCargo  += "" + (cAliRh4)->(RA_CARGO)   + ""
				cDepto  += "" + (cAliRh4)->(RA_DEPTO)   + ""
				cCc     += "" + (cAliRh4)->(RA_CC)      + ""
				cFuncao += "" + (cAliRh4)->(RA_CODFUNC) + ""
			Else
				cMatri  += "," + (cAliRh4)->(RA_MAT)     + ""
				cNome   += "," + (cAliRh4)->(RA_NOME)    + ""
				cCic    += "," + (cAliRh4)->(RA_CIC)     + ""
				cCargo  += "," + (cAliRh4)->(RA_CARGO)   + ""
				cDepto  += "," + (cAliRh4)->(RA_DEPTO)   + ""
				cCc     += "," + (cAliRh4)->(RA_CC)      + ""
				cFuncao += "," + (cAliRh4)->(RA_CODFUNC) + ""
			EndIf
			(cAliRh4)->(DbSkip())
		End
		(cAliRh4)->(DbCloseArea())
	EndIf

	AADD(aAux,cMatri)
	AADD(aAux,cNome)
	AADD(aAux,cCic)
	AADD(aAux,cCargo)
	AADD(aAux,cDepto)
	AADD(aAux,cCc)
	AADD(aAux,cFuncao)
	
Return aAux

/*
{Protheus.doc} F1302812()
Busca as informações da RH4
@Author     Henrique Madureira
@Since      05/02/2018
@Version    P12.1.07
@Project    MAN0000007423048_EF_028
@Param		cFilRh3, caracter, filial da solicitação
@Param		cCodSol, caracter, codigo da solicitação
@Return 	aAux, dados da solicitação no RH4
*/
User Function F1302812(cFilRh3,cCodSol)
	
	Local aArea   := GetArea()
	Local cQuery  := ''
	Local cAliRh4 := 'RH4INF'
	Local aAux    := {}

	cQuery := "SELECT RH4_CAMPO, RH4_VALNOV, R_E_C_N_O_ AS RECNO  "
	cQuery += "FROM	" + RetSqlName("RH4") + " "
	cQuery += "WHERE RH4_CODIGO = '" + cCodSol + "' "
	cQuery += "		AND RH4_FILIAL = '" + cFilRh3 + "' "
	cQuery += "     AND D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY RH4_ITEM "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliRh4)
	
	DbSelectArea(cAliRh4)
	While !(cAliRh4)->(EOF())
		DO CASE
		CASE (cAliRh4)->RH4_CAMPO == "P10_MOTIVO"
			RH4->(DbGoTo((cAliRh4)->RECNO))
			AADD(aAux, {(cAliRh4)->RH4_CAMPO,RH4->RH4_XOBS})
		CASE ALLTRIM((cAliRh4)->RH4_CAMPO) == "TMP_OBS"
			RH4->(DbGoTo((cAliRh4)->RECNO))
			AADD(aAux, {(cAliRh4)->RH4_CAMPO,RH4->RH4_XOBS})
		CASE ALLTRIM((cAliRh4)->RH4_CAMPO) == "TMP_OBSINC"
			RH4->(DbGoTo((cAliRh4)->RECNO))
			AADD(aAux, {(cAliRh4)->RH4_CAMPO,RH4->RH4_XOBS})
		OTHERWISE
			AADD(aAux, {(cAliRh4)->RH4_CAMPO,(cAliRh4)->RH4_VALNOV})
		ENDCASE
		
		(cAliRh4)->(DbSkip())
	End
	(cAliRh4)->(DbCloseArea())
	
	RestArea(aArea)
	
Return aAux

/*
{Protheus.doc} F1302813()
Busca as informações da solicitação nos indicadores
@Author     Henrique Madureira
@Since      05/02/2018
@Version    P12.1.07
@Project    MAN0000007423048_EF_028
@Param		cFiliSol, caracter, filial da solicitação
@Param		cCodSol , caracter, codigo da solicitação
@Return 	array com dados da solicitação no RH4
*/
User Function F1302813(cFiliSol,cCodSol)
	
	Local aArea    := GetArea()
	Local aAreaPa5 := PA5->(GetArea())
	Local cQuery   := ''
	Local cAliPa5  := 'PA5INF'
	Local cXhora   := ''
	Local cXdata   := ''
	Local cXunida  := ''
	Local cXaprov  := ''
	Local cXseapv  := ''
	Local cXstat   := ''
	Local cVar1    := ''
	Local cVar2    := ''
	Local cVar3    := ''
	Local cVar4    := '' 
	
	Default cFiliSol := ""
	Default cCodSol  := ""
	
//	cQuery := "SELECT MAX(R_E_C_N_O_) AS RECNO  " // ticket n° 3345642 - 415966 - Paulo Dias - comentado
	cQuery := "SELECT PA5.PA5_XDATA,UPPER(PA5.PA5_XSTAT)AS PA5_XSTAT,PA5.PA5_XUNAPR,PA5.PA5_XSEAPV,PA5.PA5_XAPROV,PA5.PA5_XHORA,PA5.PA5_XDATA,PA5_XCODEV  " 
	cQuery += "FROM	" + RetSqlName("PA5") + " PA5 "
	//cQuery += "WHERE PA5_XNRSOL >= '32535' " // QS_XSOLPTL
	//cQuery += "		AND PA5.PA5_FILIAL = '01310004' " // RH3_FILIAL
	cQuery += "WHERE PA5_XNRSOL = '"+cCodSol+"' "
	cQuery += "		AND PA5_FILIAL = '"+cFiliSol+"' " 
	cQuery += "     AND PA5.D_E_L_E_T_ = ' ' "
	//cQuery += "     AND TRIM(PA5.PA5_XCODEV) = '002'"
	cQuery += "     AND (Upper(TRIM(PA5.PA5_XSTAT)) = 'CONCLUÍDA'" 
	cQuery += "         OR Upper(TRIM(PA5.PA5_XSTAT)) = 'AGUARDANDO EFETIVAÇÃO DO RH'"
	cQuery += "         OR Upper(TRIM(PA5.PA5_XSTAT)) = 'EFETIVAÇÃO ATENDIDA'"
	cQuery += "         OR Upper(TRIM(PA5.PA5_XSTAT)) = 'SOLICITAÇÃO ABERTA'"
	cQuery += "         OR Upper(TRIM(PA5.PA5_XSTAT)) = 'SOLICITACAO ABERTA')"                                                                                  
	cQuery += " ORDER BY PA5.PA5_XNRSOL,PA5.PA5_XDATA "  
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliPa5)
	
//	If !(cAliPa5)->(EOF()) // ticket n° 3345642 - 415966 - Paulo Dias - Linha comentada
	While !(cAliPa5)->(EOF()) 
	
		//DbSelectArea("PA5") 
		//PA5->(DbGoTo((cAliPa5)->RECNO))// ticket n° 3345642 - 415966 - Paulo Dias - Linha comentada
		//cXhora  := PA5->PA5_XHORA
		//cXdata  := PA5->PA5_XDATA
		cXhora  :=(cAliPa5)->PA5_XHORA
		cXdata  :=(cAliPa5)->PA5_XDATA
	
		// ticket n° 3345642 - 415966 - Paulo Dias - Amarração para retorno de dados do campo PA5_XDATA conforme status
			If Empty(cVar1) .AND. AllTrim(NoAcento((cAliPa5)->PA5_XSTAT)) $ NoAcento("CONCLUÍDA")
						cVar1 := (cAliPa5)->PA5_XDATA
			EndIf	
						
			If Empty(cVar2) .AND. AllTrim(NoAcento((cAliPa5)->PA5_XSTAT)) $ NoAcento("AGUARDANDO EFETIVAÇÃO DO RH")
						cVar2 :=  (cAliPa5)->PA5_XDATA
			EndIf	
						
			If Empty(cVar3) .AND. AllTrim(NoAcento((cAliPa5)->PA5_XSTAT)) $ NoAcento("EFETIVAÇÃO ATENDIDA")
						cVar3 :=  (cAliPa5)->PA5_XDATA
			
			EndIf	
					
			If Empty(cVar4) .AND. (AllTrim(NoAcento((cAliPa5)->PA5_XSTAT)) $ NoAcento("SOLICITAÇÃO ABERTA").OR. AllTrim(NoAcento((cAliPa5)->PA5_XSTAT)) $ NoAcento("SOLICITACAO ABERTA"))
						cVar4 :=  (cAliPa5)->PA5_XDATA
			EndIf	
		// Fim - Paulo Dias
			
			If !(EMPTY((cAliPa5)->PA5_XUNAPR)).AND. AllTrim(NoAcento((cAliPa5)->PA5_XSTAT)) $ NoAcento("EFETIVAÇÃO ATENDIDA")
				cXunida := (cAliPa5)->PA5_XUNAPR
			Else
				cXunida := ""
			EndIf
			If !(EMPTY((cAliPa5)->PA5_XAPROV)).AND. AllTrim(NoAcento((cAliPa5)->PA5_XSTAT)) $ NoAcento("EFETIVAÇÃO ATENDIDA")
				cXaprov := (cAliPa5)->PA5_XAPROV
			Else
				cXaprov := ""
			EndIf
			If !(EMPTY((cAliPa5)->PA5_XSEAPV)).AND. AllTrim(NoAcento((cAliPa5)->PA5_XSTAT)) $ NoAcento("EFETIVAÇÃO ATENDIDA")
				cXseapv := (cAliPa5)->PA5_XSEAPV
			Else
				cXseapv := ""
			EndIf
			If !(EMPTY((cAliPa5)->PA5_XSTAT)).AND. AllTrim(NoAcento((cAliPa5)->PA5_XSTAT)) $ NoAcento("EFETIVAÇÃO ATENDIDA")
				cXstat := (cAliPa5)->PA5_XSTAT
			Else
				cXstat := ""
			EndIf
			
		(cAliPa5)->(DbSkip())
	EndDo
//	EndIf
	
	(cAliPa5)->(DbCloseArea())
	//PA5->(DbCloseArea()) // ticket n° 3345642 - 415966 - Paulo Dias - Linha comentada
	RestArea(aAreaPa5)
	RestArea(aArea)
	
Return {cXhora, cVar1, cXunida, cXaprov, cXseapv, cXstat, cVar2, cVar3, cVar4} // ticket n° 3345642 - 415966 - Paulo Dias - adição de parâmetros

/*
{Protheus.doc} F1302814()
Filtro da consulta padrão da RH3
@Author     Bruno de Oliveira
@Since      05/02/2018
@Version    P12.1.07
@Project    MAN0000007423048_EF_028
@Return 	cRet, condição do filtro
*/
User Function F1302814()

	Local cRet := ""
	
	If FunName() == "F1302801"
		cRet := "RH3->RH3_XTPCTM = '005' "
	ElseIf FunName() == "F1302802"
		cRet := "RH3->RH3_XTPCTM = '006' "
	ElseIf FunName() == "F1302803"
		cRet := "RH3->RH3_XTPCTM = '004' "
	EndIf
	
Return cRet

/*
{Protheus.doc} F1302815()
Busca informações do candidato
@Author     Bruno de Oliveira
@Since      05/02/2018
@Version    P12.1.07
@Project    MAN0000007423048_EF_028
@Param		cFilSol, caracter, filial da solicitação
@Param		cCodSol, caracter, Código da solicitação
@Param		cTipSol, caracter, Tipo da solicitação
@Return 	aReturn, dados do candidato
*/
User Function F1302815(cFilSol, cCodSol, cTipSol)

	Local aReturn    := {}
	Local cQuery     := ""
	Local cAlias1    := GetNextAlias()
	Local cCodCandit := ""
	Local cTelef     := ""
	Local dDtNasc    := ""
	
	
	If cTipSol == '004'
		cQuery := "SELECT RH4_CAMPO, RH4_VALNOV, R_E_C_N_O_ AS RECNO  "
		cQuery += "FROM	" + RetSqlName("RH4") + " "
		cQuery += "WHERE RH4_CODIGO = '" + cCodSol + "' "
		cQuery += "AND RH4_FILIAL = '" + cFilSol + "' "
		cQuery += "AND D_E_L_E_T_ = ' ' "
		cQuery += "ORDER BY RH4_ITEM "
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1)
		
		DbSelectArea(cAlias1)
		While !(cAlias1)->(EOF())
		
			If (cAlias1)->RH4_CAMPO == "PA2_CDCAND" 
				cCodCandit := ALLTRIM((cAlias1)->RH4_VALNOV)
				Exit
			EndIf	
			
		(cAlias1)->(DbSkip())
		End
		
		cTelef  := Posicione("SQG",1,xFilial("SQG")+cCodCandit,"QG_FONE")
		dDtNasc := Posicione("SQG",1,xFilial("SQG")+cCodCandit,"QG_DTNASC")
		
		AADD(aReturn, cTelef)
		AADD(aReturn, DTOC(dDtNasc))
		
	Else
		AADD(aReturn, "")
		AADD(aReturn, "/  /")
	EndIf
 
 	(cAlias1)->(DbCloseArea())
Return aReturn
