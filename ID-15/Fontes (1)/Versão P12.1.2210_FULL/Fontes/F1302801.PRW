#Include 'Protheus.ch'
#Include 'Report.ch'

#Define cPerg Padr("FSW1302800",10)
/*
{Protheus.doc} F1302801()
Relatório de Solicitações de Desligamento
@Author     Henrique Madureira
@Since      05/02/2018
@Version    P12.1.07
@Project    MAN0000007423048_EF_028
*/
User Function F1302801()

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

	oReport := TReport():New("FSW1302801","Solicitação de Desligamento","FSW1302801",{|oReport| ReportPrint(oReport)},"Solicitação de Desligamento")
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)

	Pergunte(cPerg, .F.)

	oSection:= TRSection():New(oReport,	 "Relatório de Solicitações", {"Relatório de Solicitações"}, , .F., .T.)
	TRCell():New(oSection, "PA5_XSEAPV", "RH3", NoAcento("Departamento Efetivaçao"   ), "@!", TAMSX3("PA5_XSEAPV")[1], .T.)
	TRCell():New(oSection, "PA5_XAPROV", "RH3", NoAcento("Analista Responsável"      ), "@!", TAMSX3("PA5_XAPROV")[1], .T.)
	TRCell():New(oSection, "TMP_MAT"   , "RH3", NoAcento("Matrícula Aprovador"       ), "@!", 30, .T.)
	TRCell():New(oSection, "TMP_NOME"  , "RH3", NoAcento("Nome Aprovador"            ), "@!", 30, .T.)
	TRCell():New(oSection, "TMP_CPF"   , "RH3", NoAcento("CPF Aprovador"             ), "@!", 30, .T.)
	TRCell():New(oSection, "TMP_CARGO" , "RH3", NoAcento("Cargo Aprovador"           ), "@!", 30, .T.)
	TRCell():New(oSection, "TMP_DEPTO" , "RH3", NoAcento("Departamento Aprovador"    ), "@!", 30, .T.)
	TRCell():New(oSection, "TMP_CC"    , "RH3", NoAcento("Centro de Custo Aprovador" ), "@!", 30, .T.)
	TRCell():New(oSection, "TMP_FUNCAO", "RH3", NoAcento("Funçao Aprovador"          ), "@!", 30, .T.)
	TRCell():New(oSection, "RH3_MAT"   , "RH3", NoAcento("Matrícula Solicitado"      ), "@!", TAMSX3("RH3_MAT")[1], .T.)
	TRCell():New(oSection, "RA_NOME"   , "RH3", NoAcento("Nome Solicitado"           ), "@!", TAMSX3("RA_NOME")[1], .T.)
	TRCell():New(oSection, "RA_CIC"    , "RH3", NoAcento("CPF Solicitado"            ), "@!", TAMSX3("RA_CIC")[1], .T.)
	TRCell():New(oSection, "RA_CARGO"  , "RH3", NoAcento("Cargo solicitado"          ), "@!", 30, .T.)
	TRCell():New(oSection, "RA_DEPTO"  , "RH3", NoAcento("Departamento Solicitado"   ), "@!", 30, .T.)
	TRCell():New(oSection, "RA_CC"     , "RH3", NoAcento("Centro de Custo Solicitado"), "@!", 30, .T.)
	TRCell():New(oSection, "RA_MATSOLC", "RH3", NoAcento("Matrícula Solicitante"     ), "@!", TAMSX3("RA_MAT")[1], .T.)
	TRCell():New(oSection, "RA_NOMESOL", "RH3", NoAcento("Nome Solicitante"          ), "@!", TAMSX3("RA_NOME")[1], .T.)
	TRCell():New(oSection, "RA_CICSOLC", "RH3", NoAcento("CPF Solicitante"           ), "@!", TAMSX3("RA_CIC")[1], .T.)
	TRCell():New(oSection, "RD0_LOGIN" , "RH3", NoAcento("Login Solicitante"         ), "@!", TAMSX3("RD0_LOGIN")[1], .T.)
	TRCell():New(oSection, "RH3_CODIGO", "RH3", NoAcento("Chamado"                   ), "@!", TAMSX3("RH3_CODIGO")[1], .T.)
	TRCell():New(oSection, "RH3_DTSOLI", "RH3", NoAcento("Data de Abertura"          ), "@!", TAMSX3("RH3_DTSOLI")[1], .T.)
	TRCell():New(oSection, "RH3_XDTAPV", "RH3", NoAcento("Data de Aprovaçao"         ), "@!", TAMSX3("RH3_XDTAPV")[1], .T.)
	TRCell():New(oSection, "P10_DTDEMI", "RH3", NoAcento("Data de Desligamento"      ), "@!", TAMSX3("RH3_XDTAPV")[1], .T.)
	TRCell():New(oSection, "RH3_DTATEN", "RH3", NoAcento("Data de Fechamento"        ), "@!", TAMSX3("RH3_DTATEN")[1], .T.)
	TRCell():New(oSection, "TMP_DESCRI", "RH3", NoAcento("Descriçao"                 ), "@!", 30, .T.)
	TRCell():New(oSection, "RH3_STATUS", "RH3", NoAcento("Status"                    ), "@!", TAMSX3("RH3_STATUS")[1], .T.)
	TRCell():New(oSection, "PA5_XDATA" , "RH3", NoAcento("Data"                      ), "@!", TAMSX3("PA5_XDATA")[1], .T.)
	TRCell():New(oSection, "PA5_XHORA" , "RH3", NoAcento("Hora"                      ), "@!", TAMSX3("PA5_XHORA")[1], .T.)
	TRCell():New(oSection, "P10_CODRES", "RH3", NoAcento("Tipo de Desligamento"      ), "@!", 50, .T.)
	TRCell():New(oSection, "P10_MOTIVO", "RH3", NoAcento("Observaçao da Solicitaçao" ), "@!", 100, .T.)
	TRCell():New(oSection, "RH3_FILAPR", "RH3", NoAcento("Unidade Aprovaçao"         ), "@!", TAMSX3("RH3_FILAPR")[1], .T.)
	TRCell():New(oSection, "RH3_FILINI", "RH3", NoAcento("Unidade Solicitante"       ), "@!", TAMSX3("RH3_FILINI")[1], .T.)
	TRCell():New(oSection, "PA5_XUNAPR", "RH3", NoAcento("Unidade Efetivaçao"        ), "@!", TAMSX3("PA5_XUNAPR")[1], .T.)
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

	Local oSection := oReport:Section(1)
	Local aDados   := {}
	Local nCnt     := 0
	
	If oReport:nDevice == 1 .OR. oReport:nDevice == 6
		MsgInfo("Não é possível imprimir o relatório em PDF ")
		oReport:CancelPrint()
		Return( Nil )
	EndIf
	
	aDados := U_F1302800("005")
	
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
			oSection:Cell("TMP_CARGO" ):SetValue(aDados[nCnt][6] + ' | ' + If(!Empty(aDados[nCnt][6]),POSICIONE("SQ3",1,xFilial("SQ3") + SubStr(aDados[nCnt][6],1,TAMSX3("RA_CARGO")[1]), "Q3_DESCSUM"),""))
			oSection:Cell("TMP_DEPTO" ):SetValue(aDados[nCnt][7] + ' | ' + If(!Empty(aDados[nCnt][7]),POSICIONE("SQB",1,xFilial("SQB") + aDados[nCnt][7], "QB_DESCRIC"),""))
			oSection:Cell("TMP_CC"    ):SetValue(aDados[nCnt][8] + ' | ' + If(!Empty(aDados[nCnt][8]),POSICIONE("CTT",1,xFilial("CTT") + aDados[nCnt][8], "CTT_DESC01"),"")) 
			oSection:Cell("TMP_FUNCAO"):SetValue(aDados[nCnt][9] + ' | ' + If(!Empty(aDados[nCnt][9]),POSICIONE("SRJ",1,xFilial("SRJ") + aDados[nCnt][9], "RJ_DESC"),""))
			oSection:Cell("RH3_MAT"   ):SetValue(aDados[nCnt][12])
			oSection:Cell("RA_NOME"   ):SetValue(aDados[nCnt][22])
			oSection:Cell("RA_CIC"    ):SetValue(aDados[nCnt][23])
			oSection:Cell("RA_CARGO"  ):SetValue(aDados[nCnt][24] + ' | ' + If(!Empty(aDados[nCnt][24]),POSICIONE("SQ3",1,xFilial("SQ3") + SubStr(aDados[nCnt][24],1,TAMSX3("RA_CARGO")[1]), "Q3_DESCSUM"),""))
			oSection:Cell("RA_DEPTO"  ):SetValue(aDados[nCnt][25] + ' | ' + If(!Empty(aDados[nCnt][25]),POSICIONE("SQB",1,xFilial("SQB") + aDados[nCnt][25], "QB_DESCRIC"),""))
			oSection:Cell("RA_CC"     ):SetValue(aDados[nCnt][26] + ' | ' + If(!Empty(aDados[nCnt][26]),POSICIONE("CTT",1,xFilial("CTT") + aDados[nCnt][26], "CTT_DESC01"),"")) 
			oSection:Cell("RA_MATSOLC"):SetValue(aDados[nCnt][27])
			oSection:Cell("RA_NOMESOL"):SetValue(aDados[nCnt][28])
			oSection:Cell("RA_CICSOLC"):SetValue(aDados[nCnt][29])
			oSection:Cell("RD0_LOGIN" ):SetValue(aDados[nCnt][10])
			oSection:Cell("RH3_CODIGO"):SetValue(aDados[nCnt][11])
			oSection:Cell("RH3_DTSOLI"):SetValue(STOD(aDados[nCnt][14]))
			oSection:Cell("RH3_XDTAPV"):SetValue(STOD(aDados[nCnt][18]))
			If Len(aDados[nCnt]) >= 37 // ticket n° 4366494 - 415966 - Paulo Dias - reposicionamento do array, necessário após melhoria do relatório de admissão no fonte de chamada
				oSection:Cell("P10_CODRES"):SetValue(ALLTRIM(aDados[nCnt][37][2]) + " - " + ALLTRIM(aDados[nCnt][37][3]))
				oSection:Cell("P10_DTDEMI"):SetValue(If(Len(AllTrim(aDados[nCnt][37][5])) > 8, aDados[nCnt][37][5], DTOC(STOD(AllTrim(aDados[nCnt][37][5])))))
				oSection:Cell("P10_MOTIVO"):SetValue(aDados[nCnt][37][4])
			EndIf
			oSection:Cell("RH3_DTATEN"):SetValue(DTOC(STOD(aDados[nCnt][15])))
			oSection:Cell("TMP_DESCRI"):SetValue(ALLTRIM(aDados[nCnt][30]) + " - " + ALLTRIM(aDados[nCnt][31]))
			oSection:Cell("RH3_STATUS"):SetValue(aDados[nCnt][13])
			oSection:Cell("PA5_XDATA" ):SetValue(aDados[nCnt][20])
			oSection:Cell("PA5_XHORA" ):SetValue(aDados[nCnt][19])
			oSection:Cell("RH3_FILAPR"):SetValue(aDados[nCnt][17] + " | " + If(!Empty(aDados[nCnt][17]), FWFILIALNAME(,aDados[nCnt][17]), ""))
			oSection:Cell("RH3_FILINI"):SetValue(aDados[nCnt][16] + " | " + If(!Empty(aDados[nCnt][16]), FWFILIALNAME(,aDados[nCnt][16]), ""))
			oSection:Cell("PA5_XUNAPR"):SetValue(aDados[nCnt][21] + " | " + If(!Empty(aDados[nCnt][21]), FWFILIALNAME(,aDados[nCnt][21]), ""))
			oSection:PrintLine()
		Next
	
		oSection:Finish()
	EndIf
	
Return