#Include 'Protheus.ch'
#Include 'Report.ch'

#Define cPerg Padr("FSW1302800",10)
/*
{Protheus.doc} F1302802()
Relatório de Solicitações de Movimentação de Pessoal
@Author     Henrique Madureira
@Since      05/02/2018
@Version    P12.1.07
@Project    MAN0000007423048_EF_028
*/
User Function F1302802()

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

	oReport := TReport():New("FSW1302802","Movimentação de Pessoal","FSW1302802",{|oReport| ReportPrint(oReport)},"Movimentação de Pessoal")
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)

	Pergunte(cPerg, .F.)

	oSection:= TRSection():New(oReport,	 "Relatório de Solicitações", {"Relatório de Solicitações"}, , .F., .T.)
	TRCell():New(oSection, "PA5_XSEAPV", "RH3", NoAcento("Departamento Efetivaçao"  ), "@!", TAMSX3("PA5_XSEAPV")[1], .T.) //01
	TRCell():New(oSection, "PA5_XAPROV", "RH3", NoAcento("Analista Responsável"     ), "@!", TAMSX3("PA5_XAPROV")[1], .T.) //02
	TRCell():New(oSection, "TMP_MAT"   , "RH3", NoAcento("Matrícula Aprovador"      ), "@!", 30, .T.)                      //03
	TRCell():New(oSection, "TMP_NOME"  , "RH3", NoAcento("Nome Aprovador"           ), "@!", 30, .T.)                      //04
	TRCell():New(oSection, "TMP_CPF"   , "RH3", NoAcento("CPF Aprovador"            ), "@!", 30, .T.)                      //05
	TRCell():New(oSection, "TMP_CARGO" , "RH3", NoAcento("Cargo Aprovador"          ), "@!", 30, .T.)                      //06
	TRCell():New(oSection, "TMP_DEPTO" , "RH3", NoAcento("Departamento Aprovador"   ), "@!", 30, .T.)                      //07
	TRCell():New(oSection, "TMP_CC"    , "RH3", NoAcento("Centro de Custo Aprovador"), "@!", 30, .T.)                      //08
	TRCell():New(oSection, "TMP_FUNCAO", "RH3", NoAcento("Funçao Aprovador"         ), "@!", 30, .T.)                      //09
	TRCell():New(oSection, "RH3_MAT"   , "RH3", NoAcento("Matrícula Solicitado"     ), "@!", TAMSX3("RH3_MAT")[1], .T.)    //10
	TRCell():New(oSection, "RA_NOME"   , "RH3", NoAcento("Nome Solicitado"          ), "@!", TAMSX3("RA_NOME")[1], .T.)    //11
	TRCell():New(oSection, "RA_CIC"    , "RH3", NoAcento("CPF Solicitado"           ), "@!", TAMSX3("RA_CIC")[1], .T.)     //12
	TRCell():New(oSection, "RA_MATSOLC", "RH3", NoAcento("Matrícula Solicitante"    ), "@!", TAMSX3("RA_MAT")[1], .T.)     //13
	TRCell():New(oSection, "RA_NOMESOL", "RH3", NoAcento("Nome Solicitante"         ), "@!", TAMSX3("RA_NOME")[1], .T.)    //14
	TRCell():New(oSection, "RA_CICSOLC", "RH3", NoAcento("CPF Solicitante"          ), "@!", TAMSX3("RA_CIC")[1], .T.)     //15
	TRCell():New(oSection, "RD0_LOGIN" , "RH3", NoAcento("Login Solicitante"        ), "@!", TAMSX3("RD0_LOGIN")[1], .T.)  //16
	TRCell():New(oSection, "TMP_H_M_AT", "RH3", NoAcento("Carga Horária Atual"      ), "@!", 30, .T.)                      //17
	TRCell():New(oSection, "RA_HRSMES" , "RH3", NoAcento("Carga Horário Proposta"   ), "@!", 30, .T.)                      //18
	TRCell():New(oSection, "TMP_D_FUNC", "RH3", NoAcento("Cargo Atual"              ), "@!", 30, .T.)                      //19
	TRCell():New(oSection, "RA_CODFUNC", "RH3", NoAcento("Cargo proposto"           ), "@!", 30, .T.)                      //20
	TRCell():New(oSection, "TMP_DEPTOA", "RH3", NoAcento("Departamento Atual"       ), "@!", 30, .T.)                      //21
	TRCell():New(oSection, "RA_DEPTO"  , "RH3", NoAcento("Departamento Proposto"    ), "@!", 30, .T.)                      //22
	TRCell():New(oSection, "TMP_CCATU" , "RH3", NoAcento("Centro de Custo Atual"    ), "@!", 30, .T.)                      //23
	TRCell():New(oSection, "RA_CC"     , "RH3", NoAcento("Centro de Custo Proposto" ), "@!", 30, .T.)                      //24
	TRCell():New(oSection, "TMP_H_D_AT", "RH3", NoAcento("Horário Atual"            ), "@!", 30, .T.)                      //25
	TRCell():New(oSection, "RA_HRSDIA" , "RH3", NoAcento("Horário Proposto"         ), "@!", 30, .T.)                      //26
	TRCell():New(oSection, "TMP_SALATU", "RH3", NoAcento("Salário Atual"            ), "@!", 30, .T.)                      //27
	TRCell():New(oSection, "RA_SALARIO", "RH3", NoAcento("Salário Proposto"         ), "@!", 30, .T.)                      //28
	TRCell():New(oSection, "TMP_FILIAL", "RH3", NoAcento("Filial Atual"             ), "@!", 30, .T.)                      //29
	TRCell():New(oSection, "RA_FILIAL" , "RH3", NoAcento("Filial Proposta"          ), "@!", 30, .T.)                      //30
	TRCell():New(oSection, "RH3_CODIGO", "RH3", NoAcento("Chamado"                  ), "@!", TAMSX3("RH3_CODIGO")[1], .T.) //31
	TRCell():New(oSection, "RH3_DTSOLI", "RH3", NoAcento("Data de Abertura"         ), "@!", TAMSX3("RH3_DTSOLI")[1], .T.) //32
	TRCell():New(oSection, "RH3_XDTAPV", "RH3", NoAcento("Data de Aprovaçao"        ), "@!", TAMSX3("RH3_XDTAPV")[1], .T.) //33
	TRCell():New(oSection, "RH3_DTATEN", "RH3", NoAcento("Data de Fechamento"       ), "@!", TAMSX3("RH3_DTATEN")[1], .T.) //34
	TRCell():New(oSection, "TMP_DESCRI", "RH3", NoAcento("Descriçao"                ), "@!", TAMSX3("Q3_DESCSUM")[1], .T.) //35
	TRCell():New(oSection, "TMP_FECHAD", "RH3", NoAcento("Fechado"                  ), "@!", 30, .T.)                      //36
	TRCell():New(oSection, "PA5_XDATA" , "RH3", NoAcento("Data"                     ), "@!", TAMSX3("PA5_XDATA")[1], .T.)  //37
	TRCell():New(oSection, "PA5_XHORA" , "RH3", NoAcento("Hora"                     ), "@!", TAMSX3("PA5_XHORA")[1], .T.)  //38
	TRCell():New(oSection, "TMP_OBS"   , "RH3", NoAcento("Observaçao da Solicitaçao"), "@!", 30, .T.)                      //39
	TRCell():New(oSection, "RH3_STATUS", "RH3", NoAcento("Status"                   ), "@!", TAMSX3("RH3_STATUS")[1], .T.) //40
	TRCell():New(oSection, "RH3_FILAPR", "RH3", NoAcento("Unidade Aprovaçao"        ), "@!", TAMSX3("RH3_FILIAL")[1], .T.) //41
	TRCell():New(oSection, "RH3_FILINI", "RH3", NoAcento("Unidade Solicitante"      ), "@!", TAMSX3("RH3_FILINI")[1], .T.) //42
	TRCell():New(oSection, "PA5_XUNAPR", "RH3", NoAcento("Unidade Efetivaçao"       ), "@!", TAMSX3("PA5_XUNAPR")[1], .T.) //43
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
	
	Local oSection   := oReport:Section(1)
	Local aDados     := {}
	Local nCnt       := 0
	Local cCargo     := ""
	Local cQryRH4    := ""
	Local cAliasRH   := ""
	Local cCodCargo  := ""
	Local cNomeCargo := ""
	
	If oReport:nDevice == 1 .OR. oReport:nDevice == 6
		MsgInfo("Não é possível imprimir o relatório em PDF ")
		oReport:CancelPrint()
		Return( Nil )
	EndIf
	
	aDados := U_F1302800("006")
	
	If !(EMPTY(aDados))
		oReport:SetMeter(Len(aDados))
		oReport:IncMeter()
		For nCnt:= 1 to Len(aDados)
			If oReport:Cancel()
				Exit
			EndIf
			oSection:Init()
			oReport:IncMeter()
			oSection:Cell("PA5_XSEAPV"):SetValue(aDados[nCnt][1]) //01
			oSection:Cell("PA5_XAPROV"):SetValue(aDados[nCnt][2]) //02
			oSection:Cell("TMP_MAT"   ):SetValue(aDados[nCnt][3]) //03
			oSection:Cell("TMP_NOME"  ):SetValue(aDados[nCnt][4]) //04
			oSection:Cell("TMP_CPF"   ):SetValue(aDados[nCnt][5]) //05
			oSection:Cell("TMP_CARGO" ):SetValue(AllTrim(aDados[nCnt][6]) + ' | ' + If(!Empty(aDados[nCnt][6]),POSICIONE("SQ3",1,xFilial("SQ3") + SubStr(aDados[nCnt][6],1,TAMSX3("RA_CARGO")[1]), "Q3_DESCSUM"),"")) //06
			oSection:Cell("TMP_DEPTO" ):SetValue(AllTrim(aDados[nCnt][7]) + ' | ' + If(!Empty(aDados[nCnt][7]),POSICIONE("SQB",1,xFilial("SQB") + aDados[nCnt][7], "QB_DESCRIC"),""))                                 //07
			oSection:Cell("TMP_CC"    ):SetValue(AllTrim(aDados[nCnt][8]) + ' | ' + If(!Empty(aDados[nCnt][8]),POSICIONE("CTT",1,xFilial("CTT") + aDados[nCnt][8], "CTT_DESC01"),""))                                 //08
			oSection:Cell("TMP_FUNCAO"):SetValue(AllTrim(aDados[nCnt][9]) + ' | ' + If(!Empty(aDados[nCnt][9]),POSICIONE("SRJ",1,xFilial("SRJ") + aDados[nCnt][9], "RJ_DESC"),""))                                    //09
			oSection:Cell("RH3_MAT"   ):SetValue(aDados[nCnt][12]) //10
			oSection:Cell("RA_NOME"   ):SetValue(aDados[nCnt][22]) //11
			oSection:Cell("RA_CIC"    ):SetValue(aDados[nCnt][23]) //12
			oSection:Cell("RA_MATSOLC"):SetValue(aDados[nCnt][27]) //13
			oSection:Cell("RA_NOMESOL"):SetValue(aDados[nCnt][28]) //14
			oSection:Cell("RA_CICSOLC"):SetValue(aDados[nCnt][29]) //15
			oSection:Cell("RD0_LOGIN" ):SetValue(aDados[nCnt][10]) //16
			If Len(aDados[nCnt]) >= 37
			
				// Ticket No. 3533232 - 418497 - Don Junior - Correção posto atual
				cAliasRH   := GetNextAlias()
				cCodCargo  := ""
				cNomeCargo := ""
				
				cQryRH4 := "SELECT RH4.RH4_CAMPO, RH4.RH4_VALNOV "
				cQryRH4 += "FROM	" + RetSqlName("RH4") + " RH4 "
				cQryRH4 += "WHERE RH4.D_E_L_E_T_ = ' ' "
				cQryRH4 += "AND RH4.RH4_CODIGO = '" + aDados[nCnt][11] + "' "     // Campo Chamado 
				cQryRH4 += "AND RH4.RH4_FILIAL = '" + aDados[nCnt][37][19] + "' " // Campo Filial Atual
				cQryRH4 += "AND (RH4.RH4_CAMPO = 'TMP_FUNCAO' " 
				cQryRH4 += " OR  RH4.RH4_CAMPO = 'TMP_D_FUNC') "
				cQryRH4 += "GROUP BY RH4.RH4_CAMPO, RH4.RH4_VALNOV "
				
				cQryRH4 := ChangeQuery(cQryRH4)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRH4),cAliasRH)
				
				DbSelectArea(cAliasRH)
				While !(cAliasRH)->(EOF())
					If (cAliasRH)->RH4_CAMPO == "TMP_FUNCAO" 
						cCodCargo := AllTrim((cAliasRH)->RH4_VALNOV)
					ElseIf (cAliasRH)->RH4_CAMPO == "TMP_D_FUNC" 
						cNomeCargo := AllTrim((cAliasRH)->RH4_VALNOV)
					EndIf
				(cAliasRH)->(DbSkip())
				EndDo
				(cAliasRH)->(DbCloseArea())
				
				//cCargo	:= POSICIONE("SRA",1,AllTrim(aDados[nCnt][37][19]) + aDados[nCnt][12],"RA_CARGO")
				oSection:Cell("TMP_H_M_AT"):SetValue(aDados[nCnt][37][4])                                     //17
				oSection:Cell("RA_HRSMES" ):SetValue(aDados[nCnt][37][7])                                     //18
				//oSection:Cell("TMP_D_FUNC"):SetValue(cCargo + " | " + POSICIONE("SQ3",1,xFilial("SQ3") + SubStr(cCargo,1,TAMSX3("RA_CARGO")[1]), "Q3_DESCSUM"))                                        //19
                oSection:Cell("TMP_D_FUNC"):SetValue(cCodCargo + " | " + cNomeCargo)                          //19
				oSection:Cell("RA_CODFUNC"):SetValue(AllTrim(aDados[nCnt][37][18]) + ' | ' + If(!Empty(aDados[nCnt][37][18]),POSICIONE("SRJ",1,xFilial("SRJ") + aDados[nCnt][37][18], "RJ_DESC"),""))    //20
				oSection:Cell("TMP_DEPTOA"):SetValue(AllTrim(aDados[nCnt][37][12]) + ' | ' + If(!Empty(aDados[nCnt][37][12]),POSICIONE("SQB",1,xFilial("SQB") + aDados[nCnt][37][12], "QB_DESCRIC"),"")) //21
				oSection:Cell("RA_DEPTO"  ):SetValue(AllTrim(aDados[nCnt][37][15]) + ' | ' + If(!Empty(aDados[nCnt][37][15]),POSICIONE("SQB",1,xFilial("SQB") + aDados[nCnt][37][15], "QB_DESCRIC"),"")) //22
				oSection:Cell("TMP_CCATU" ):SetValue(AllTrim(aDados[nCnt][37][10]) + ' | ' + If(!Empty(aDados[nCnt][37][10]),POSICIONE("CTT",1,xFilial("CTT") + aDados[nCnt][37][10], "CTT_DESC01"),"")) //23
				oSection:Cell("RA_CC"     ):SetValue(AllTrim(aDados[nCnt][37][13]) + ' | ' + If(!Empty(aDados[nCnt][37][13]),POSICIONE("CTT",1,xFilial("CTT") + aDados[nCnt][37][13], "CTT_DESC01"),"")) //24
				oSection:Cell("TMP_H_D_AT"):SetValue(aDados[nCnt][37][6])  //25
				oSection:Cell("RA_HRSDIA" ):SetValue(aDados[nCnt][37][9])  //26
				oSection:Cell("TMP_SALATU"):SetValue(aDados[nCnt][37][2])  //27
				oSection:Cell("RA_SALARIO"):SetValue(aDados[nCnt][37][3])  //28
				oSection:Cell("TMP_FILIAL"):SetValue(AllTrim(aDados[nCnt][37][19]) + " | " + If(!Empty(aDados[nCnt][37][19]), FWFILIALNAME(,aDados[nCnt][37][19]), "")) //29
				oSection:Cell("RA_FILIAL" ):SetValue(AllTrim(aDados[nCnt][37][20]) + " | " + If(!Empty(aDados[nCnt][37][20]), FWFILIALNAME(,aDados[nCnt][37][20]), "")) //30
				oSection:Cell("TMP_OBS"   ):SetValue(aDados[nCnt][37][17]) //31
			EndIf
			oSection:Cell("RH3_CODIGO"):SetValue(aDados[nCnt][11])             //32
			oSection:Cell("RH3_DTSOLI"):SetValue(DTOC(STOD(aDados[nCnt][14]))) //33
			oSection:Cell("RH3_XDTAPV"):SetValue(DTOC(STOD(aDados[nCnt][18]))) //34
			oSection:Cell("RH3_DTATEN"):SetValue(DTOC(STOD(aDados[nCnt][15]))) //35
			oSection:Cell("TMP_DESCRI"):SetValue(ALLTRIM(aDados[nCnt][30]) + " | " + ALLTRIM(aDados[nCnt][31])) //36
			oSection:Cell("TMP_FECHAD"):SetValue(aDados[nCnt][32])             //37
			oSection:Cell("PA5_XDATA" ):SetValue(aDados[nCnt][20])             //38
			oSection:Cell("PA5_XHORA" ):SetValue(aDados[nCnt][19])             //39
			oSection:Cell("RH3_STATUS"):SetValue(aDados[nCnt][13])             //40
			oSection:Cell("RH3_FILAPR"):SetValue(aDados[nCnt][17] + " | " + If(!Empty(aDados[nCnt][17]), FWFILIALNAME(,aDados[nCnt][17]), "")) //41
			oSection:Cell("RH3_FILINI"):SetValue(aDados[nCnt][16] + " | " + If(!Empty(aDados[nCnt][16]), FWFILIALNAME(,aDados[nCnt][16]), "")) //42
			oSection:Cell("PA5_XUNAPR"):SetValue(aDados[nCnt][21] + " | " + If(!Empty(aDados[nCnt][21]), FWFILIALNAME(,aDados[nCnt][21]), "")) //43
						
			oSection:PrintLine()
		Next
	
		oSection:Finish()
	EndIf
	
Return