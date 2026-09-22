#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDef.CH"

/*
Funcao.: DORTI002 - Conferência de DIRF
Autor..: Mauricio Siqueira
Data...: 29/01/25
Versão.: Protheus12
Menu...: SIGAGPE\MISCELANEA\DIRF\Conferência Rede Dor
*/
USER FUNCTION DORTI002()  

Local aArea   := FWGetArea()

Private cPerg   := Padr("DORTI002",10)
Private cEol    := CHR(13)+CHR(10)
Private cPer    := "" 

//ValidPerg()

If Pergunte(cPerg)
   Processa({|| DORTI002A()  , "Gerando a planilha...  ]"})
EndIf 

FWRestArea(aArea)

Return


/*
Função 	DORTI002A - (Gerando o relatório...)
Return	lRet
*/
Static Function DORTI002A()

Local aArea     := FWGetArea()
Local oExcel
Local cArqSai   := "C:\TEMP\DIRF_" + DToS(Date()) + "_" + StrTran(Time(), ":", "-") + ".XML"
Local cQRYRHS   := ""
Local cQRYRHP   := ""
Local cQRYRU6   := ""
Local cQRYSRR   := ""
Local cQRYSRD   := ""
Local nRegTot   := 0
Local nRegAtu   := 0
Local lAbriu    := .F.
Local lTemReg   := .F.

// Tratamento para a Ficha Financeira...
If MV_PAR07 = 1
   cQRYSRD := "SELECT * FROM " + RetSqlName("SRD") + " SRD "
   cQRYSRD += "WHERE "                                  
   cQRYSRD += "    RD_FILIAL >= "  + "'" + MV_PAR01 + "'"       
   cQRYSRD += "AND RD_FILIAL <= "  + "'" + MV_PAR02 + "'"     
   cQRYSRD += "AND RD_MAT >= "     + "'" + MV_PAR03 + "'"
   cQRYSRD += "AND RD_MAT <= "     + "'" + MV_PAR04 + "'"
   cQRYSRD += "AND RD_DATPGT >= "  + "'" + DTOS(MV_PAR05) + "'"
   cQRYSRD += "AND RD_DATPGT <= "  + "'" + DTOS(MV_PAR06) + "'"
   cQRYSRD += "AND SRD.D_E_L_E_T_ = ' '
   cQRYSRD += "ORDER BY RD_FILIAL, RD_MAT, RD_DATPGT, RD_PD"

   If Select("QRY_SRD") > 0
      QRY_SRD->(DbCloseArea())
   EndIf
   TCQuery cQRYSRD New Alias "QRY_SRD"

   Count to nRegTot
   If nRegTot > 0
      lTemReg := .T.
   
      ProcRegua(nRegTot)
      QRY_SRD->(DbGoTop())

      oExcel := FWMsExcelEx():New()
      lAbriu := .T.

      // Aba 1 SRD...
      oExcel:AddworkSheet("SRD")
      oExcel:AddTable("SRD","Ficha Financeira")
	  oExcel:AddColumn("SRD","Ficha Financeira","RD_FILIAL",1,1)
	  oExcel:AddColumn("SRD","Ficha Financeira","RD_MAT",1,1)
	  oExcel:AddColumn("SRD","Ficha Financeira","RD_DATPGT",1,1,.f.) 
	  oExcel:AddColumn("SRD","Ficha Financeira","RD_DATARQ",1,1,.f.)
	  oExcel:AddColumn("SRD","Ficha Financeira","RD_PD",1,1,.f.)  
	  oExcel:AddColumn("SRD","Ficha Financeira","RD_VALOR",1,2,.f.)
	  oExcel:AddColumn("SRD","Ficha Financeira","RD_HORAS",1,2,.f.)  
	  oExcel:AddColumn("SRD","Ficha Financeira","RD_IR",1,1,.f.) 
	  oExcel:AddColumn("SRD","Ficha Financeira","RD_TRIBIR",1,1,.f.) 
	  oExcel:AddColumn("SRD","Ficha Financeira","RD_INSS",1,1,.f.)
	  oExcel:AddColumn("SRD","Ficha Financeira","RD_FGTS",1,1,.f.)   
	  oExcel:AddColumn("SRD","Ficha Financeira","RD_ROTEIR",1,1,.f.)
	  oExcel:AddColumn("SRD","Ficha Financeira","RD_TIPO1",1,1,.f.)
	  oExcel:AddColumn("SRD","Ficha Financeira","RD_CC",1,1,.f.) 
	  oExcel:AddColumn("SRD","Ficha Financeira","RD_EMPRESA",1,1,.f.) 
	  oExcel:AddColumn("SRD","Ficha Financeira","RD_TIPO2",1,1,.f.)
	  oExcel:AddColumn("SRD","Ficha Financeira","RD_PROCES",1,1,.f.) 
	  oExcel:AddColumn("SRD","Ficha Financeira","RD_PERIODO",1,1,.f.) 
	  oExcel:AddColumn("SRD","Ficha Financeira","RD_SEMANA",1,1,.f.)  

      While !QRY_SRD->(Eof())
         nRegAtu ++
	     IncProc("Incluindo SRD "+ cValToChar(nRegAtu) + " de " + cValToChar(nRegTot) + "...")

         oExcel:AddRow("SRD", "Ficha Financeira", ;
	        {RD_FILIAL,;
	         RD_MAT,;
		     STOD(RD_DATPGT),;
		     RD_DATARQ,;
    	     RD_PD,;
		     RD_VALOR,;
		     RD_HORAS,;
			 RD_IR,;
		     RD_TRIBIR,;
			 RD_INSS,;
			 RD_FGTS,;
		     RD_ROTEIR,;
		     RD_TIPO1,;
			 RD_CC,;
			 RD_EMPRESA,;
		     RD_TIPO2,;
			 RD_PROCES,;
		     RD_PERIODO,;
		     RD_SEMANA})

		   QRY_SRD->(DbSkip())
   	   EndDo
	EndIf
	QRY_SRD->(DbCloseArea())
EndIf

// Tratamento para Férias & Rescisoes...
If MV_PAR08 = 1
   nRegTot := 0
   nRegAtu := 0

   cQRYSRR := "SELECT * FROM " + RetSqlName("SRR") + " SRR "
   cQRYSRR += "WHERE "                                  
   cQRYSRR += "    RR_FILIAL >= "  + "'" + MV_PAR01 + "'"       
   cQRYSRR += "AND RR_FILIAL <= "  + "'" + MV_PAR02 + "'"     
   cQRYSRR += "AND RR_MAT >= "     + "'" + MV_PAR03 + "'"
   cQRYSRR += "AND RR_MAT <= "     + "'" + MV_PAR04 + "'"
   cQRYSRR += "AND RR_DATAPAG >= " + "'" + DTOS(MV_PAR05) + "'"
   cQRYSRR += "AND RR_DATAPAG <= " + "'" + DTOS(MV_PAR06) + "'"
   cQRYSRR += "AND SRR.D_E_L_E_T_ = ' '
   cQRYSRR += "ORDER BY RR_FILIAL, RR_MAT, RR_DATAPAG, RR_PD"

   If Select("QRY_SRR") > 0
      QRY_SRR->(DbCloseArea())
   EndIf
   TCQuery cQRYSRR New Alias "QRY_SRR"

   Count to nRegTot
   If nRegTot > 0
      lTemReg := .T.
   
      ProcRegua(nRegTot)
      QRY_SRR->(DbGoTop())

      If !lAbriu
         oExcel := FWMsExcelEx():New()
	     lAbriu := .T.
      EndIf

      // Aba 2 SRR...
      oExcel:AddworkSheet("SRR")
      oExcel:AddTable("SRR","Ferias & Rescisoes")
	   oExcel:AddColumn("SRR","Ferias & Rescisoes","RR_FILIAL",1,1)
	   oExcel:AddColumn("SRR","Ferias & Rescisoes","RR_MAT",1,1)
	   oExcel:AddColumn("SRR","Ferias & Rescisoes","RR_DATAPAG",1,1,.f.)
	   oExcel:AddColumn("SRR","Ferias & Rescisoes","RR_PD",1,1,.f.)  
	   oExcel:AddColumn("SRR","Ferias & Rescisoes","RR_VALOR",1,2,.f.)
	   oExcel:AddColumn("SRR","Ferias & Rescisoes","RR_HORAS",1,2,.f.)  
      oExcel:AddColumn("SRR","Ferias & Rescisoes","RR_TRIBIR",1,1,.f.)
	   oExcel:AddColumn("SRR","Ferias & Rescisoes","RR_ROTEIR",1,1,.f.)
	   oExcel:AddColumn("SRR","Ferias & Rescisoes","RR_DATA",1,1,.f.)
	   oExcel:AddColumn("SRR","Ferias & Rescisoes","RR_TIPO3",1,1,.f.) 
	   oExcel:AddColumn("SRR","Ferias & Rescisoes","RR_TIPO1",1,1,.f.)
	   oExcel:AddColumn("SRR","Ferias & Rescisoes","RR_TIPO2",1,1,.f.)
	   oExcel:AddColumn("SRR","Ferias & Rescisoes","RR_PERIODO",1,1,.f.) 
	   oExcel:AddColumn("SRR","Ferias & Rescisoes","RR_SEMANA",1,1,.f.)
	   oExcel:AddColumn("SRR","Ferias & Rescisoes","RR_CC",1,1,.f.) 
	   oExcel:AddColumn("SRR","Ferias & Rescisoes","RR_PROCES",1,1,.f.) 

      While !QRY_SRR->(Eof())
         nRegAtu ++
	      IncProc("Incluindo SRR "+ cValToChar(nRegAtu) + " de " + cValToChar(nRegTot) + "...")

         oExcel:AddRow("SRR", "Ferias & Rescisoes", ;
	        {RR_FILIAL,;
	         RR_MAT,;
		     STOD(RR_DATAPAG),;
			  RR_PD,;
		     RR_VALOR,;
		     RR_HORAS,;
		     RR_TRIBIR,;
		     RR_ROTEIR,;
		     STOD(RR_DATA),;
		     RR_TIPO3,;
		     RR_TIPO1,;
		     RR_TIPO2,;
		     RR_PERIODO,;
		     RR_SEMANA,;
		     RR_CC,;
		     RR_PROCES})

		   QRY_SRR->(DbSkip())
   	   EndDo
	EndIf
	QRY_SRR->(DbCloseArea())
EndIf

// Plano de Saúde...
IF MV_PAR09 = 1
   nRegTot := 0
   nRegAtu := 0

   // Tratamento para Historico Calculo Plano Saude...
   cQRYRHS := "SELECT * FROM " + RetSqlName("RHS") + " RHS "
   cQRYRHS += "WHERE "                                  
   cQRYRHS += "    RHS_FILIAL >= " + "'" + MV_PAR01 + "'"       
   cQRYRHS += "AND RHS_FILIAL <= " + "'" + MV_PAR02 + "'"     
   cQRYRHS += "AND RHS_MAT >= "    + "'" + MV_PAR03 + "'"
   cQRYRHS += "AND RHS_MAT <= "    + "'" + MV_PAR04 + "'"
   cQRYRHS += "AND RHS_DATPGT >= " + "'" + DTOS(MV_PAR05) + "'"
   cQRYRHS += "AND RHS_DATPGT <= " + "'" + DTOS(MV_PAR06) + "'"
   cQRYRHS += "AND RHS.D_E_L_E_T_ = ' '
   cQRYRHS += "ORDER BY RHS_FILIAL, RHS_MAT, RHS_DATPGT, RHS_PD"

   If Select("QRY_RHS") > 0
      QRY_RHS->(DbCloseArea())
   EndIf
   TCQuery cQryRHS New Alias "QRY_RHS"

   Count to nRegTot
   If nRegTot > 0
      lTemReg := .T.

      ProcRegua(nRegTot)
      QRY_RHS->(DbGoTop())

      If !lAbriu
         oExcel := FWMsExcelEx():New()
         lAbriu := .T.
	  EndIf
   
      // Aba 3 RHS (RHS)...
      oExcel:AddworkSheet("RHS")
      oExcel:AddTable("RHS","Calculo de Plano de Saude")
      oExcel:AddColumn("RHS","Calculo de Plano de Saude","RHS_FILIAL",1,1)
      oExcel:AddColumn("RHS","Calculo de Plano de Saude","RHS_MAT",1,1)
      oExcel:AddColumn("RHS","Calculo de Plano de Saude","RHS_DATPGT ",1,1,.f.) 
      oExcel:AddColumn("RHS","Calculo de Plano de Saude","RHS_PD",1,1,.f.)  
      oExcel:AddColumn("RHS","Calculo de Plano de Saude","RHS_VLRFUN",1,2,.f.)
      oExcel:AddColumn("RHS","Calculo de Plano de Saude","RHS_VLREMP",1,2,.f.) 
      oExcel:AddColumn("RHS","Calculo de Plano de Saude","RHS_DATA",1,1)
      oExcel:AddColumn("RHS","Calculo de Plano de Saude","RHS_ORIGEM",1,1)
      oExcel:AddColumn("RHS","Calculo de Plano de Saude","RHS_CODIGO",1,1)   
      oExcel:AddColumn("RHS","Calculo de Plano de Saude","RHS_TPLAN",1,1)
      oExcel:AddColumn("RHS","Calculo de Plano de Saude","RHS_TPFORN",1,1)
      oExcel:AddColumn("RHS","Calculo de Plano de Saude","RHS_CODFOR",1,1)
      oExcel:AddColumn("RHS","Calculo de Plano de Saude","RHS_TPPLAN",1,1)
      oExcel:AddColumn("RHS","Calculo de Plano de Saude","RHS_PLANO",1,1,.f.)  
      oExcel:AddColumn("RHS","Calculo de Plano de Saude","RHS_COMPPG ",1,1,.f.) 
      oExcel:AddColumn("RHS","Calculo de Plano de Saude","RHS_DTHRGR",1,1,.f.) 

      While !QRY_RHS->(Eof())
         nRegAtu ++
	      IncProc("Incluindo RHS "+ cValToChar(nRegAtu) + " de " + cValToChar(nRegTot) + "...")

         oExcel:AddRow("RHS", "Calculo de Plano de Saude", ;
	        {RHS_FILIAL,;
	         RHS_MAT,;
 		     STOD(RHS_DATPGT),;
		     RHS_PD,;
 		     RHS_VLRFUN,;
 		     RHS_VLREMP,;
    	     STOD(RHS_DATA),;
		     RHS_ORIGEM,;
		     RHS_CODIGO,;
		     RHS_TPLAN,;
		     RHS_TPFORN,;
		     RHS_CODFOR,;
		     RHS_TPPLAN,;
		     RHS_PLANO,; 
 		     RHS_COMPPG,;
 		     STOD(RHS_DTHRGR) })

   	   	   Qry_RHS->(DbSkip())
  	   EndDo
	EndIf
	QRY_RHS->(DbCloseArea())

   // Tratamento para Hist. Co-partic. e Reembolso...
   nRegTot := 0
   nRegAtu := 0

   cQRYRHP := "SELECT * FROM " + RetSqlName("RHP") + " RHP "
   cQRYRHP += "WHERE "                                  
   cQRYRHP += "    RHP_FILIAL >= " + "'" + MV_PAR01 + "'"       
   cQRYRHP += "AND RHP_FILIAL <= " + "'" + MV_PAR02 + "'"     
   cQRYRHP += "AND RHP_MAT >= "    + "'" + MV_PAR03 + "'"
   cQRYRHP += "AND RHP_MAT <= "    + "'" + MV_PAR04 + "'"
   cQRYRHP += "AND RHP_DATPGT >= " + "'" + DTOS(MV_PAR05) + "'"
   cQRYRHP += "AND RHP_DATPGT <= " + "'" + DTOS(MV_PAR06) + "'"
   cQRYRHP += "AND RHP.D_E_L_E_T_ = ' '
   cQRYRHS += "ORDER BY RHP_FILIAL, RHP_MAT, RHP_DATPGT, RHP_PD"

   If Select("QRY_RHP") > 0
      QRY_RHP->(DbCloseArea())
   EndIf
   TCQuery cQRYRHP New Alias "QRY_RHP"

   Count to nRegTot
   If nRegTot > 0
      lTemReg := .T.

      ProcRegua(nRegTot)
      QRY_RHP->(DbGoTop())

      If !lAbriu
         oExcel := FWMsExcelEx():New()
         lAbriu := .T.
	  EndIf

      // Aba 4 RHP (RHP)...
      oExcel:AddworkSheet("RHP")
      oExcel:AddTable("RHP","Co-participacao & Reembolso")
      oExcel:AddColumn("RHP","Co-participacao & Reembolso","RHP_FILIAL",1,1)
      oExcel:AddColumn("RHP","Co-participacao & Reembolso","RHP_MAT",1,1)
      oExcel:AddColumn("RHP","Co-participacao & Reembolso","RHS_DATPGT",1,1,.f.) 
      oExcel:AddColumn("RHP","Co-participacao & Reembolso","RHP_PD",1,1,.f.)  
      oExcel:AddColumn("RHP","Co-participacao & Reembolso","RHP_VLRFUN",1,2,.f.)
      oExcel:AddColumn("RHP","Co-participacao & Reembolso","RHP_VLREMP",1,2,.f.) 
      oExcel:AddColumn("RHP","Co-participacao & Reembolso","RHP_DTOCOR",1,1)
      oExcel:AddColumn("RHP","Co-participacao & Reembolso","RHP_ORIGEM",1,1)
      oExcel:AddColumn("RHP","Co-participacao & Reembolso","RHP_TPFORN",1,1)
      oExcel:AddColumn("RHP","Co-participacao & Reembolso","RHP_CODFOR",1,1)
      oExcel:AddColumn("RHP","Co-participacao & Reembolso","RHP_CODIGO",1,1)   
      oExcel:AddColumn("RHP","Co-participacao & Reembolso","RHP_TPLAN",1,1)
      oExcel:AddColumn("RHP","Co-participacao & Reembolso","RHP_COMPPG",1,1,.f.) 
      oExcel:AddColumn("RHP","Co-participacao & Reembolso","RHP_OBSERV",1,1,.f.) 
      oExcel:AddColumn("RHP","Co-participacao & Reembolso","RHS_DTHRGR",1,1,.f.) 

      While !QRY_RHP->(Eof())
         nRegAtu ++
	     IncProc("Incluindo RHP "+ cValToChar(nRegAtu) + " de " + cValToChar(nRegTot) + "...")

         oExcel:AddRow("RHP", "Co-participacao & Reembolso", ;
	        {RHP_FILIAL,;
	         RHP_MAT,;
		     STOD(RHP_DATPGT),;
		     RHP_PD,;
		     RHP_VLRFUN,;
		     RHP_VLREMP,;
     	     STOD(RHP_DTOCOR),;
	 	     RHP_ORIGEM,;
	 	     RHP_TPFORN,;
 		     RHP_CODFOR,; 
		     RHP_CODIGO,; 
		     RHP_TPLAN,; 
		     RHP_COMPPG,;
		     RHP_OBSERV,;
		     STOD(RHP_DTHRGR) })

		   QRY_RHP->(DbSkip())
	   EndDo
	EndIf
	QRY_RHP->(DbCloseArea())

EndIf

// Tratamento para Dedução por Dependentes...
If MV_PAR10 = 1
   nRegTot := 0
   nRegAtu := 0

   cQRYRU6 := "SELECT * FROM " + RetSqlName("RU6") + " RU6 "
   cQRYRU6 += "WHERE "                                  
   cQRYRU6 += "    RU6_FILIAL >= " + "'" + MV_PAR01 + "'"       
   cQRYRU6 += "AND RU6_FILIAL <= " + "'" + MV_PAR02 + "'"     
   cQRYRU6 += "AND RU6_MAT >= "    + "'" + MV_PAR03 + "'"
   cQRYRU6 += "AND RU6_MAT <= "    + "'" + MV_PAR04 + "'"
   cQRYRU6 += "AND RU6_DTPGTO >= " + "'" + DTOS(MV_PAR05) + "'"
   cQRYRU6 += "AND RU6_DTPGTO <= " + "'" + DTOS(MV_PAR06) + "'"
   cQRYRU6 += "AND RU6.D_E_L_E_T_ = ' '
   cQRYRU6 += "ORDER BY RU6_FILIAL, RU6_MAT, RU6_DTPGTO"

   If Select("QRY_RU6") > 0
      QRY_RU6->(DbCloseArea())
   EndIf
   TCQuery cQRYRU6 New Alias "QRY_RU6"

   Count to nRegTot
   If nRegTot > 0
      lTemReg := .T.
   
      ProcRegua(nRegTot)
      QRY_RU6->(DbGoTop())

      If !lAbriu
         oExcel := FWMsExcelEx():New()
	     lAbriu := .T.
      EndIf

      // Aba 5 RU6 (Dedução por Dependente)...
      oExcel:AddworkSheet("RU6")
      oExcel:AddTable("RU6","Deducoes de Dependentes")
      oExcel:AddColumn("RU6","Deducoes de Dependentes","RU6_FILIAL",1,1)
      oExcel:AddColumn("RU6","Deducoes de Dependentes","RU6_MAT",1,1)
      oExcel:AddColumn("RU6","Deducoes de Dependentes","RU6_DTPGTO",1,1,.f.) 
      oExcel:AddColumn("RU6","Deducoes de Dependentes","RU6_VLRDED",1,2,.f.)
      oExcel:AddColumn("RU6","Deducoes de Dependentes","RU6_TPREND",1,1,.f.) 
      oExcel:AddColumn("RU6","Deducoes de Dependentes","RU6_CODSRB",1,1,.f.)  
      oExcel:AddColumn("RU6","Deducoes de Dependentes","RU6_DTMOV",1,1,.f.)
      oExcel:AddColumn("RU6","Deducoes de Dependentes","RU6_SEQMOV",1,1,.f.)  
      oExcel:AddColumn("RU6","Deducoes de Dependentes","RU6_TPMOV",1,1,.f.)
      oExcel:AddColumn("RU6","Deducoes de Dependentes","RU6_COMPET",1,1,.f.)
      oExcel:AddColumn("RU6","Deducoes de Dependentes","RU6_SEMANA",1,1,.f.) 
      oExcel:AddColumn("RU6","Deducoes de Dependentes","RU6_TPCAL",1,1,.f.)

      While !QRY_RU6->(Eof())
         nRegAtu ++
	     IncProc("Incluindo RU6 "+ cValToChar(nRegAtu) + " de " + cValToChar(nRegTot) + "...")

         oExcel:AddRow("RU6", "Deducoes de Dependentes", ;
	        {RU6_FILIAL,;
	         RU6_MAT,;
		     STOD(RU6_DTPGTO),;
		     RU6_VLRDED,;
		     RU6_TPREND,;
    	     RU6_CODSRB,;
		     STOD(RU6_DTMOV),;
		     RU6_SEQMOV,;
		     RU6_TPMOV,;
		     RU6_COMPET,;
		     RU6_SEMANA,;
		     RU6_TPCAL})

		   QRY_RU6->(DbSkip())
   	   EndDo
	EndIf
	QRY_RU6->(DbCloseArea())
EndIf

// Abre e exibe o resultado...
If lTemReg
   oExcel:Activate()
   oExcel:GetXMLFile(cArqSai)

   // IF ApOleClient("MsExcel")
   //    oExcelApp := MsExcel():New()
	//   oExcelApp:WorkBooks:Open(cArqSai)
	//   oExcelApp:SetVisible(.T.)
	//   oExcelApp:Destroy()
   //    FwAlertInfo("Planilha Gerada !", "Verifique o Excel !")
   // Else
      ShellExecute("open",cArqSai,"","",1)
   // EndIf

Else
   FwAlertError("Parâmetros sem nenhum registro !","Atenção !")
EndIf

FWRestArea(aArea)

RETURN()
				

/*
Função 	ValidPerg - (Validar perguntas da rotina...)
Return	lRet
*/
// Static Function ValidPerg()

// Local i,j    := 0
// Local aRegs  := {}

// dbSelectArea("SX1")
// dbSetOrder(1)       

// /*          Grupo/Ordem  /Pergunta                                                         /Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid       /Var01     /Def01               /Defspa1/Defeng1/Cnt01/Var02/Def02             /Defesp2/Defeng2/Cnt02/Var03/Def03/Defspa3  /defeng3/Cnt03/Var04/Def04/Defspa4/Defeng4/Cnt04/Var05/Def05/Defspa5/Defeng5/Cnt05/F3   /PYME/grpsxg  /HELP /PICTURE*/
// //Aadd(aRegs,{"GRUPO","ORDEM","PERGUNT"                       ,"VARIAVL","TIPO","TAMANHO","DECIMAL","GSC","VALID","VAR01"   ,"DEF01","SPA","ENG","CON1","VAR2","DEF2","SPA","ENG","CON2","VAR3","DEF3","SPA","ENG","CON3","VAR4","DEF4","SPA","ENG","CON4","VAR5","DEF5","SPA","ENG","CON5", "F3"  ,  ,  ,"HELP"
// Aadd(aRegs,{cPerg  ,"01"   ,"Filial De....................?", "", "", "MV_CH1" ,"C" ,08 ,0 ,0 ,"G" ,""           ,"MV_PAR01", ""    , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  , "XM0" ,"","033",".RHFILDE." })
// Aadd(aRegs,{cPerg  ,"02"   ,"Filial Ate...................?", "", "", "MV_CH2" ,"C" ,08 ,0 ,0 ,"G" ,"NaoVazio"   ,"MV_PAR02", ""    , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  , "XM0" ,"","033",".RHFILAT." })
// Aadd(aRegs,{cPerg  ,"03"   ,"Matricula De.................?", "", "", "MV_CH3" ,"C" ,06 ,0 ,0 ,"G" ,""           ,"MV_PAR03", ""    , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  , "SRA" ,"","121",".RHMATD."  })
// Aadd(aRegs,{cPerg  ,"04"   ,"Matricula Ate................?", "", "", "MV_CH4" ,"C" ,06 ,0 ,0 ,"G" ,"NaoVazio"   ,"MV_PAR04", ""    , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  , "SRA" ,"","121",".RHMATA."  })
// Aadd(aRegs,{cPerg  ,"05"   ,"Data de Pagamento De.........?", "", "", "MV_CH5" ,"D" ,08 ,0 ,0 ,"G" ,"NaoVazio"   ,"MV_PAR05", ""    , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""   ,"",""   ,"",""       })
// Aadd(aRegs,{cPerg  ,"06"   ,"Data de Pagamento Ate........?", "", "", "MV_CH6" ,"D" ,08 ,0 ,0 ,"G" ,"NaoVazio"   ,"MV_PAR06", ""    , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""   ,"",""   ,"",""       })
// Aadd(aRegs,{cPerg  ,"07"   ,"Ficha Financeira.............?", "", "", "MV_CH7" ,"N" ,01 ,0 ,0 ,"C" ,"NaoVazio"   ,"MV_PAR07", "Sim" , ""  , ""  ,  ""  ,  ""  , "Nao", ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""   ,"",""   ,""          }) 
// Aadd(aRegs,{cPerg  ,"08"   ,"Ferias / Rescisoes...........?", "", "", "MV_CH8" ,"N" ,01 ,0 ,0 ,"C" ,"NaoVazio"   ,"MV_PAR08", "Sim" , ""  , ""  ,  ""  ,  ""  , "Nao", ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""   ,"",""   ,""          }) 
// Aadd(aRegs,{cPerg  ,"09"   ,"Plano de Saude...............?", "", "", "MV_CH9" ,"N" ,01 ,0 ,0 ,"C" ,"NaoVazio"   ,"MV_PAR09", "Sim" , ""  , ""  ,  ""  ,  ""  , "Nao", ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""   ,"",""   ,""          }) 
// Aadd(aRegs,{cPerg  ,"10"   ,"Deducao Por Dependente.......?", "", "", "MV_CHA" ,"N" ,01 ,0 ,0 ,"C" ,"NaoVazio"   ,"MV_PAR10", "Sim" , ""  , ""  ,  ""  ,  ""  , "Nao", ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""  ,  ""  , ""  , ""  ,  ""  ,  ""   ,"",""   ,""          }) 

// For i := 1 to Len(aRegs)
// 	If !dbSeek(cPerg+aRegs[i,2])
// 		RecLock("SX1",.T.)
// 		For j:=1 to FCount()
// 			If j <= Len(aRegs[i])
// 				FieldPut(j,aRegs[i,j])
// 			Endif                                                                                              
// 		Next j
// 		MsUnlock()
// 	Endif
// Next i

// Return .t.
