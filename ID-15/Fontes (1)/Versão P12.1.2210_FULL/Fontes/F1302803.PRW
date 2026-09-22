#Include 'Protheus.ch'
#Include 'Report.ch'

#Define cPerg Padr("FSW1302800",10)
/*
{Protheus.doc} F1302803()
Relatório de Solicitações de Admissão
@Author     Henrique Madureira
@Since      05/02/2018
@Version    P12.1.07
@Project    MAN0000007423048_EF_028
*/
User Function F1302803()

	Local oReport := nil

	Pergunte(cPerg,.T.)
	oReport := RptDef()
	oReport:PrintDialog()

Return

/*
{Protheus.doc} RptDef()
Estrutura do relatório
@Author     Henrique Madureira
@Since      05/02/2018
@Version    P12.1.07
@Project    MAN0000007423048_EF_028
*/
Static Function RptDef()

	Local oReport  := Nil
	Local oSection := Nil
	Local oBreak
	Local oFunction

	oReport := TReport():New("FSW1302803","Admissão","FSW1302803",{|oReport| ReportPrint(oReport)},"Admissão")
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)

	Pergunte(cPerg, .F.)

	oSection:= TRSection():New(oReport,	 "Relatório de Solicitações", {"Relatório de Solicitações"}, , .F., .T.)
	TRCell():New(oSection, "PA5_XSEAPV", "RH3", NoAcento("Departamento Efetivação"   ), "@!", TAMSX3("PA5_XSEAPV")[1], .T.)
	TRCell():New(oSection, "PA5_XAPROV", "RH3", NoAcento("Analista Responsável"      ), "@!", TAMSX3("PA5_XAPROV")[1], .T.)
	TRCell():New(oSection, "TMP_MAT"   , "RH3", NoAcento("Matrícula Aprovador"       ), "@!", 30, .T.)
	TRCell():New(oSection, "TMP_NOME"  , "RH3", NoAcento("Nome Aprovador"            ), "@!", 30, .T.)
	TRCell():New(oSection, "TMP_CPF"   , "RH3", NoAcento("CPF Aprovador"             ), "@!", 30, .T.)
	TRCell():New(oSection, "TMP_CARGO" , "RH3", NoAcento("Cargo Aprovador"           ), "@!", 30, .T.)
	TRCell():New(oSection, "TMP_DEPTO" , "RH3", NoAcento("Departamento Aprovador"    ), "@!", 30, .T.)
	TRCell():New(oSection, "TMP_CC"    , "RH3", NoAcento("Centro de Custo Aprovador" ), "@!", 30, .T.)
	TRCell():New(oSection, "TMP_FUNCAO", "RH3", NoAcento("Função Aprovador"          ), "@!", 30, .T.)
	TRCell():New(oSection, "RA_MAT"    , "RH3", NoAcento("Matrícula Solicitante"     ), "@!", TAMSX3("RA_MAT")[1], .T.)
	TRCell():New(oSection, "RA_NOME"   , "RH3", NoAcento("Nome Solicitante"          ), "@!", TAMSX3("RA_NOME")[1], .T.)
	TRCell():New(oSection, "RA_CIC"    , "RH3", NoAcento("CPF Solicitante"           ), "@!", TAMSX3("RA_CIC")[1], .T.)
	TRCell():New(oSection, "RA_DEPTO"  , "RH3", NoAcento("Departamento Solicitante"  ), "@!", TAMSX3("RA_DEPTO")[1], .T.)
	TRCell():New(oSection, "RD0_LOGIN" , "RH3", NoAcento("Login Solicitante"         ), "@!", TAMSX3("RD0_LOGIN")[1], .T.)
	TRCell():New(oSection, "PA2_CDVAGA", "RH3", NoAcento("Vaga"                      ), "@!", 30, .T.)
	TRCell():New(oSection, "QS_XSOLFIL", "RH3", NoAcento("Filial Sol. Vaga"          ), "@!", 30, .T.)
	TRCell():New(oSection, "QS_XSOLPTL", "RH3", NoAcento("Sol. da Vaga"              ), "@!", 30, .T.)
	TRCell():New(oSection, "PA2_HRMES" , "RH3", NoAcento("Carga Horária"             ), "@!", 30, .T.)
	TRCell():New(oSection, "PA2_CARGO" , "RH3", NoAcento("Cargo Anterior"            ), "@!", 30, .T.) //Thais Paiva - 14531848
	TRCell():New(oSection, "TMP_CARGOV", "RH3", NoAcento("Cargo"                     ), "@!", 30, .T.) //Thais Paiva - 14531848
	TRCell():New(oSection, "PA2_DEPART", "RH3", NoAcento("Departamento"              ), "@!", 30, .T.)
	TRCell():New(oSection, "TMP_CCVAGA", "RH3", NoAcento("Centro de Custo da Vaga"   ), "@!", 30, .T.)
	TRCell():New(oSection, "TMP_DSCVAG", "RH3", NoAcento("Descrição Carga Horária"   ), "@!", 30, .T.)
	TRCell():New(oSection, "TMP_SALFUN", "RH3", NoAcento("Salário Anterior"          ), "@!", 30, .T.) //Thais Paiva - 14531848
	TRCell():New(oSection, "PA2_VLVAGA", "RH3", NoAcento("Salário da Vaga"           ), "@!", 30, .T.)
	TRCell():New(oSection, "PA2_FILCAN", "RH3", NoAcento("Filial do Candidato"       ), "@!", 30, .T.) //Thais Paiva - 14531848
	TRCell():New(oSection, "PA2_CC"	   , "RH3", NoAcento("Centro de Custo"		     ), "@!", 30, .T.) //Thais Paiva - 14531848
	TRCell():New(oSection, "TMP_MATCOL", "RH3", NoAcento("Matrícula"		     	 ), "@!", 30, .T.) //Thais Paiva - 14531848
	TRCell():New(oSection, "PA2_NMCAND", "RH3", NoAcento("Nome candidato"            ), "@!", 30, .T.)
	TRCell():New(oSection, "PA2_CPFCAN", "RH3", NoAcento("CPF"                       ), "@!", 30, .T.)
	TRCell():New(oSection, "RD0_FONE"  , "RH3", NoAcento("Telefone"                  ), "@!", 30, .T.)
	TRCell():New(oSection, "PA2_DTADMI", "RH3", NoAcento("Data de Admissão"          ), "@!", 30, .T.)
	TRCell():New(oSection, "RD0_DTNASC", "RH3", NoAcento("Data de Nascimento"        ), "@!", 30, .T.)
	TRCell():New(oSection, "RH3_CODIGO", "RH3", NoAcento("Número da FAP"             ), "@!", 30, .T.)
	TRCell():New(oSection, "cVar4"     , "   ", NoAcento("Data de Abertura da Vaga"  ), "@!", 30, .T.)
	TRCell():New(oSection, "RH3_XDTAPV", "RH3", NoAcento("Data de Aprovação"         ), "@!", 30, .T.)
	TRCell():New(oSection, "RH3_DTATEN", "RH3", NoAcento("Data de Fechamento"        ), "@!", 30, .T.)
	TRCell():New(oSection, "TMP_FECHAD", "RH3", NoAcento("Fechado"                   ), "@!", 30, .T.)
	TRCell():New(oSection, "cVar1"     , "   ", NoAcento("Data Conclusão"            ), "@!", 30, .T.) // ticket n° 3345642 - 415966 - Paulo Dias - Edição nome da coluna
	TRCell():New(oSection, "PA5_XHORA" , "RH3", NoAcento("Hora"                      ), "@!", TAMSX3("PA5_XHORA")[1], .T.)
	TRCell():New(oSection, "RH3_STATUS", "RH3", NoAcento("Status"                    ), "@!", TAMSX3("RH3_STATUS")[1], .T.)
	TRCell():New(oSection, "TMP_TIPOFA", "RH3", NoAcento("Tipo de Contratação"       ), "@!", 30, .T.)
	TRCell():New(oSection, "RH3_FILAPR", "RH3", NoAcento("Unidade Aprovação"         ), "@!", TAMSX3("RH3_FILAPR")[1], .T.)
	TRCell():New(oSection, "RH3_FILINI", "RH3", NoAcento("Unidade Solicitante"       ), "@!", TAMSX3("RH3_FILINI")[1], .T.)
	TRCell():New(oSection, "PA5_XUNAPR", "RH3", NoAcento("Unidade Efetivação"        ), "@!", TAMSX3("PA5_XUNAPR")[1], .T.)
	TRCell():New(oSection, "cVar2"     , "   ", NoAcento("Data efetivação do RH"     ), "@!", 30, .T.)  // ticket n° 3345642 - 415966 - Paulo Dias - Inclusão de coluna
	TRCell():New(oSection, "cVar3"     , "   ", NoAcento("FAP (RE) Efetivada"        ), "@!", 30, .T.)  // ticket n° 3345642 - 415966 - Paulo Dias - Inclusão de coluna

	oReport:SetTotalInLine(.F.)

	oSection:SetPageBreak(.T.)
	oSection:SetTotalText(" ")

Return(oReport)

/*
{Protheus.doc} ReportPrint()
Impressão dos dados no relatório
@Author     Henrique Madureira
@Since      05/02/2018
@Version    P12.1.07
@Project    MAN0000007423048_EF_028
@Param		oReport, objeto, estrutura do relatório
*/
Static Function ReportPrint(oReport)
	
	Local nCnt      := 0
	Local oSection  := oReport:Section(1)
	Local aDados    := {}
	Local cCodigo   := "004"
	
	Local oSection3


	Local aArea    := GetArea()
	Local aAreaPa5 := PA5->(GetArea())
	Local aAreaSQS := SQS->(GetArea())
	Local cQuery   := ''
	Local cQueryQS := ''
	Local cAliPa5  := 'PA5TMP'
	Local cAliSQS  := 'SQSTMP'
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
	
	If oReport:nDevice == 1 .OR. oReport:nDevice == 6
		MsgInfo("Não é possível imprimir o relatório em PDF ")
		oReport:CancelPrint()
		Return( Nil )
	EndIf
	
	aDados := U_F1302800(cCodigo)
	
	If !(EMPTY(aDados))
		oReport:SetMeter(Len(aDados))
		oReport:IncMeter()
		For nCnt:= 1 to Len(aDados)
			If oReport:Cancel()
				Exit
			EndIf
			
			oSection:Init()
			oReport:IncMeter()
			oSection:Cell("PA5_XSEAPV"):SetValue(aDados[nCnt][1])
			oSection:Cell("PA5_XAPROV"):SetValue(aDados[nCnt][2])
			oSection:Cell("TMP_MAT"   ):SetValue(aDados[nCnt][3])
			oSection:Cell("TMP_NOME"  ):SetValue(aDados[nCnt][4])
			oSection:Cell("TMP_CPF"   ):SetValue(aDados[nCnt][5])
			oSection:Cell("TMP_CARGO" ):SetValue(AllTrim(aDados[nCnt][6]) + ' | ' + If(!Empty(aDados[nCnt][6]),POSICIONE("SQ3",1,xFilial("SQ3") + SubStr(aDados[nCnt][6],1,TAMSX3("RA_CARGO")[1]), "Q3_DESCSUM"),""))
			oSection:Cell("TMP_DEPTO" ):SetValue(AllTrim(aDados[nCnt][7]) + ' | ' + If(!Empty(aDados[nCnt][7]),POSICIONE("SQB",1,xFilial("SQB") + aDados[nCnt][7], "QB_DESCRIC"),""))
			oSection:Cell("TMP_CC"    ):SetValue(AllTrim(aDados[nCnt][8]) + ' | ' + If(!Empty(aDados[nCnt][8]),POSICIONE("CTT",1,xFilial("CTT") + aDados[nCnt][8], "CTT_DESC01"),""))
			oSection:Cell("TMP_FUNCAO"):SetValue(AllTrim(aDados[nCnt][9]) + ' | ' + If(!Empty(aDados[nCnt][9]),POSICIONE("SRJ",1,xFilial("SRJ") + aDados[nCnt][9], "RJ_DESC"),""))
			oSection:Cell("RA_MAT"    ):SetValue(aDados[nCnt][12])
			oSection:Cell("RA_NOME"   ):SetValue(aDados[nCnt][28])
			oSection:Cell("RA_CIC"    ):SetValue(aDados[nCnt][29])
			oSection:Cell("RA_DEPTO"  ):SetValue(POSICIONE("SRA",1,aDados[nCnt][16]+aDados[nCnt][12],"RA_DEPTO")  + ' | ' + If(!Empty(aDados[nCnt][12]),POSICIONE("SQB",1,xFilial("SQB") + POSICIONE("SRA",1,aDados[nCnt][16]+aDados[nCnt][12],"RA_DEPTO"), "QB_DESCRIC"),""))
			oSection:Cell("RD0_LOGIN" ):SetValue(aDados[nCnt][10])
			If Len(aDados[nCnt]) >= 37
			// ticket n° 3345642 - 415966 - Paulo Dias - Tratamento para atribuição das datas conforme status
				cQuery := "SELECT PA5.PA5_XDATA,UPPER(PA5.PA5_XSTAT)AS PA5_XSTAT,PA5.PA5_XUNAPR,PA5.PA5_XSEAPV,PA5.PA5_XAPROV,PA5.PA5_XHORA,PA5.PA5_XDATA,PA5.PA5_XCODEV  " 
				cQuery += "FROM	" + RetSqlName("PA5") + " PA5 " 
				//cQuery += "WHERE PA5_XNRSOL = '32535' " // QS_XSOLPTL
				//cQuery += "		AND PA5.PA5_FILIAL = '01310004' " // RH3_FILIAL
				cQuery += "WHERE PA5_XNRSOL = '" + aDados[nCnt][37][14] + "' " // QS_XSOLPTL
				cQuery += "	  AND PA5.PA5_FILIAL = '" + aDados[nCnt][37][13] + "' " // RH3_FILIAL
				cQuery += "     AND PA5.D_E_L_E_T_ = ' ' "
				cQuery += "     AND TRIM(PA5.PA5_XCODEV) = '002'"
				cQuery += "     AND (Upper(TRIM(PA5.PA5_XSTAT)) = 'CONCLUÍDA'" 
				cQuery += "         OR Upper(TRIM(PA5.PA5_XSTAT)) = 'AGUARDANDO EFETIVAÇÃO DO RH'"
				cQuery += "         OR Upper(TRIM(PA5.PA5_XSTAT)) = 'SOLICITAÇÃO ABERTA'"
				//cQuery += "         AND (Upper(TRIM(PA5.PA5_XSTAT)) = 'SOLICITAÇÃO ABERTA')"
				cQuery += "         OR Upper(TRIM(PA5.PA5_XSTAT)) = 'SOLICITACAO ABERTA')"
				cQuery += " ORDER BY PA5.PA5_XNRSOL,PA5.PA5_XDATA " 
				
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliPa5)
				
				While !(cAliPa5)->(EOF()) 
				
					cXhora  :=(cAliPa5)->PA5_XHORA
					cXdata  :=(cAliPa5)->PA5_XDATA
					
					If Empty(cVar1) .AND. AllTrim(NoAcento((cAliPa5)->PA5_XSTAT)) $ NoAcento("CONCLUÍDA")
						cVar1 := (cAliPa5)->PA5_XDATA
					EndIf	
						
					If Empty(cVar2) .AND. AllTrim(NoAcento((cAliPa5)->PA5_XSTAT)) $ NoAcento("AGUARDANDO EFETIVAÇÃO DO RH")
						cVar2 :=  (cAliPa5)->PA5_XDATA
					EndIf	
						
					//If Empty(cVar3) .AND. AllTrim(NoAcento((cAliPa5)->PA5_XSTAT)) $ NoAcento("FAP (RE) EFETIVADA")
						//cVar3 :=  (cAliPa5)->PA5_XDATA
					//EndIf
					
					If Empty(cVar4) .AND. (AllTrim(NoAcento((cAliPa5)->PA5_XSTAT)) $ NoAcento("SOLICITAÇÃO ABERTA").OR. AllTrim(NoAcento((cAliPa5)->PA5_XSTAT)) $ NoAcento("SOLICITACAO ABERTA"))
						cVar4 :=  (cAliPa5)->PA5_XDATA
					EndIf	
					
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
				
				(cAliPa5)->(DbCloseArea())
				RestArea(aAreaPa5)
				
				
				/* Tratamento filial diferente entre PA5 e SQS */
				If Empty(cVar4) .OR. Empty(cVar2)
					
					cQueryQS := "SELECT SQS.QS_XSOLFIL, PA5.PA5_XDATA,PA5.PA5_XSTAT " 
					cQueryQS += "  FROM	 " + RetSqlName("SQS") + " SQS, " + RetSqlName("PA5") + " PA5 "   
					cQueryQS += " WHERE SQS.D_E_L_E_T_ = ' ' "
					cQueryQS += "   AND PA5.D_E_L_E_T_ = ' ' "
					cQueryQS += "   AND SQS.QS_XSOLFIL = '" + aDados[nCnt][37][13] + "' " 
					cQueryQS += "   AND SQS.QS_FILIAL  = PA5.PA5_FILIAL " 
					cQueryQS += "   AND PA5.PA5_XNRSOL = '"  + aDados[nCnt][11] + "' "
					cQueryQS += "   AND (Upper(TRIM(PA5.PA5_XSTAT)) = 'SOLICITAÇÃO ABERTA' "
					cQueryQS += "   	OR Upper(TRIM(PA5.PA5_XSTAT)) = 'AGUARDANDO EFETIVAÇÃO DO RH' )"
					
					
					
					cQueryQS := ChangeQuery(cQueryQS)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryQS),cAliSQS)
					
					While !(cAliSQS)->(EOF()) 
						
						If Empty(cVar2) .AND. AllTrim(NoAcento((cAliSQS)->PA5_XSTAT)) $ NoAcento("AGUARDANDO EFETIVAÇÃO DO RH")
							cVar2 :=  (cAliSQS)->PA5_XDATA
						EndIf		
										
						If Empty(cVar4) .AND. (AllTrim(NoAcento((cAliSQS)->PA5_XSTAT)) $ NoAcento("SOLICITAÇÃO ABERTA").OR. AllTrim(NoAcento((cAliSQS)->PA5_XSTAT)) $ NoAcento("SOLICITACAO ABERTA"))
							cVar4 :=  (cAliSQS)->PA5_XDATA
						EndIf		
						
					(cAliSQS)->(DbSkip())
					EndDo
					
					(cAliSQS)->(DbCloseArea())
					RestArea(aAreaSQS)
					
				EndIf
				
				RestArea(aArea)
				
			//Fim - Paulo Dias
			
				oSection:Cell("PA2_CDVAGA"):SetValue(aDados[nCnt][37][1])
				oSection:Cell("PA2_HRMES" ):SetValue(aDados[nCnt][37][2])
				oSection:Cell("PA2_CARGO" ):SetValue(Alltrim(aDados[nCnt][37][15]) + ' | ' + If(!Empty(Alltrim(aDados[nCnt][37][15])),POSICIONE("SQ3",1,xFilial("SQ3") + SubStr(aDados[nCnt][37][15],1,TAMSX3("RA_CARGO")[1]), "Q3_DESCSUM"),"")) //Thais Paiva - 14531848
				oSection:Cell("TMP_CARGOV"):SetValue(Alltrim(aDados[nCnt][37][3]) + ' | ' + If(!Empty(Alltrim(aDados[nCnt][37][3])),POSICIONE("SQ3",1,xFilial("SQ3") + SubStr(aDados[nCnt][37][3],1,TAMSX3("RA_CARGO")[1]), "Q3_DESCSUM"),"")) //Thais Paiva - 14531848
				oSection:Cell("PA2_DEPART"):SetValue(AllTrim(aDados[nCnt][37][4]) + ' | ' + If(!Empty(aDados[nCnt][37][4]),POSICIONE("SQB",1,xFilial("SQB") + aDados[nCnt][37][4], "QB_DESCRIC"),""))
				oSection:Cell("TMP_CCVAGA"):SetValue(aDados[nCnt][37][5] + ' | ' + If(!Empty(aDados[nCnt][37][5]),POSICIONE("CTT",1,xFilial("CTT") + aDados[nCnt][37][5], "CTT_DESC01"),""))
				oSection:Cell("TMP_DSCVAG"):SetValue(aDados[nCnt][37][6])
				oSection:Cell("TMP_SALFUN"):SetValue(aDados[nCnt][37][19]) //Thais Paiva - 14531848
				oSection:Cell("PA2_VLVAGA"):SetValue(aDados[nCnt][37][7])
				oSection:Cell("PA2_FILCAN"):SetValue(aDados[nCnt][37][16]) //Thais Paiva - 14531848
				oSection:Cell("PA2_CC"	  ):SetValue(aDados[nCnt][37][17]) //Thais Paiva - 14531848
				oSection:Cell("TMP_MATCOL"):SetValue(aDados[nCnt][37][18]) //Thais Paiva - 14531848
				oSection:Cell("PA2_NMCAND"):SetValue(aDados[nCnt][37][9])
				oSection:Cell("PA2_CPFCAN"):SetValue(aDados[nCnt][37][10])
				oSection:Cell("RD0_FONE"  ):SetValue(aDados[nCnt][33])
				oSection:Cell("PA2_DTADMI"):SetValue(aDados[nCnt][37][11])
				oSection:Cell("TMP_TIPOFA"):SetValue(aDados[nCnt][37][12])
				oSection:Cell("QS_XSOLFIL"):SetValue(aDados[nCnt][37][13] + " | " + If(!Empty(aDados[nCnt][37][13]), FWFILIALNAME(,aDados[nCnt][37][13]), ""))
				oSection:Cell("QS_XSOLPTL"):SetValue(aDados[nCnt][37][14])
			EndIf
			oSection:Cell("RD0_DTNASC"):SetValue(aDados[nCnt][34])
			oSection:Cell("RH3_CODIGO"):SetValue(aDados[nCnt][11]) // 37802
			oSection:Cell("cVar4"):SetValue(IIf(Empty(cVar4),CToD("  /  /  "),DToC(STOD(cVar4))))
			oSection:Cell("RH3_XDTAPV"):SetValue(DTOC(STOD(aDados[nCnt][18])))
			oSection:Cell("RH3_DTATEN"):SetValue(DTOC(STOD(aDados[nCnt][15])))
			oSection:Cell("TMP_FECHAD"):SetValue(aDados[nCnt][32])
			oSection:Cell("cVar1" ):SetValue(IIf(Empty(cVar1),CToD("  /  /  "),DToC(STOD(cVar1))))
			oSection:Cell("PA5_XHORA" ):SetValue(cXhora)
			oSection:Cell("RH3_STATUS"):SetValue(aDados[nCnt][13])
			oSection:Cell("RH3_FILAPR"):SetValue(aDados[nCnt][17] + " | " + If(!Empty(aDados[nCnt][17]), FWFILIALNAME(,aDados[nCnt][17]), ""))
			oSection:Cell("RH3_FILINI"):SetValue(aDados[nCnt][16] + " | " + If(!Empty(aDados[nCnt][16]), FWFILIALNAME(,aDados[nCnt][16]), ""))
			oSection:Cell("PA5_XUNAPR"):SetValue(aDados[nCnt][21] + " | " + If(!Empty(aDados[nCnt][21]), FWFILIALNAME(,aDados[nCnt][21]), ""))
			oSection:Cell("cVar2" ):SetValue(IIf(Empty(cVar2),CToD("  /  /  "),DToC(STOD(cVar2))))
			oSection:Cell("cVar3" ):SetValue(IIf(Empty(aDados[nCnt][36]),CToD("  /  /  "),DToC(STOD(aDados[nCnt][36]))))
			//oSection:Cell("cVar3" ):SetValue(IIf(Empty(cVar3),CToD("  /  /  "),DToC(STOD(cVar3))))
			
			oSection:PrintLine()
			cVar1 := ''
			cVar2 := ''
			cVar3 := ''
			cVar4 := ''
		Next
	
		oSection:Finish()
	EndIf
	
Return
