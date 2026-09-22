#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

/*{Protheus.doc} F0801301
Relacao de Postos x Ocupantes 
*/
User Function F0801301()
	
	Local aArea 		:= GetArea()
	Private cAliasQry	:= "RCLQRY"
	Private LINRESERV	:= 0
	Private LINDISPON	:= 0
	Private aSolAll	:= {}
	Private oReport
	
	//VERIFICA AS PERGUNTAS SELECIONADAS
	Pergunte("FSW0801301",.F.)
	
	oReport := ReportDef()
	oReport:PrintDialog()
	
	RestArea(aArea)
Return

/*{Protheus.doc} ReportDef
*/
Static Function ReportDef()
	//Local oReport
	Local oSection1
	Local oSection2
	Local oSection3
	Local oSection4
	
	Private aOrd		:= {OemToAnsi("Departamento / Posto")}	//
	Private cTitulo	:= OemToAnsi("Relatorio de Postos x Ocupantes")	//
	
	//CRIACAO DOS COMPONENTES DE IMPRESSAO
	DEFINE REPORT oReport NAME "ORGR060" TITLE cTitulo PARAMETER "FSW0801301" ACTION {|oReport| ORG60Imp(oReport)} DESCRIPTION OemtoAnsi("Emite relacao de Postos com seus Ocupantes atuais e anteriores.")	//
	
	DEFINE SECTION oSection1 OF oReport TITLE OemToAnsi("Departamento") TABLES "RCL", "SQB" ORDERS aOrd	//
	DEFINE CELL NAME "RCL_FILIAL"  	OF oSection1 ALIAS cAliasQry
	DEFINE CELL NAME "RCL_DEPTO"  	OF oSection1 ALIAS cAliasQry
	DEFINE CELL NAME "QB_DESCRIC" 	OF oSection1 ALIAS cAliasQry
	
	DEFINE SECTION oSection2 OF oSection1 TITLE OemToAnsi("Postos") TABLES "RCL", "SQ3", "SRJ" ORDERS aOrd	 //
	DEFINE CELL NAME "RCL_POSTO"	OF oSection2 ALIAS cAliasQry TITLE OemToAnsi("Posto") SIZE TamSx3("RCL_POSTO")[1]+2	//
	DEFINE CELL NAME "RCL_CARGO"	OF oSection2 ALIAS cAliasQry TITLE OemToAnsi("Cargo") SIZE 10	//
	DEFINE CELL NAME "Q3_DESCSUM"	OF oSection2 ALIAS cAliasQry
	DEFINE CELL NAME "RCL_FUNCAO"	OF oSection2 ALIAS cAliasQry TITLE OemToAnsi("Funcao") SIZE 10	//
	DEFINE CELL NAME "RJ_DESC"	OF oSection2 ALIAS cAliasQry
	DEFINE CELL NAME "RCL_NPOSTO"	OF oSection2 ALIAS cAliasQry TITLE OemToAnsi("Maximo") SIZE 10 //
	DEFINE CELL NAME "RCL_OPOSTO"	OF oSection2 ALIAS cAliasQry TITLE OemToAnsi("Ocupados") SIZE 10 //
	DEFINE CELL NAME "LINRESERV"  OF oSection2 TITLE OemToAnsi("Reservados") SIZE 10 BLOCK {|| LINRESERV }
	DEFINE CELL NAME "LINDISPON"  OF oSection2 TITLE OemToAnsi("Disponiveis") SIZE 10 BLOCK {|| LINDISPON }
	
	DEFINE SECTION oSection3 OF oSection2 TITLE OemToAnsi("Historico") TABLES "RCX", "RD0", "SRA", "RH3", "P10", "PA7" ORDERS aOrd	//
	DEFINE CELL NAME "RCX_DTINI"		OF oSection3 ALIAS cAliasQry
	DEFINE CELL NAME "RCX_DTFIM"		OF oSection3 ALIAS cAliasQry
	DEFINE CELL NAME "FILOCU"  		OF oSection3 TITLE OemToAnsi("Fil. Ocupante") ;  //
	BLOCK{|| IIF((cAliasQry)->RCX_TIPOCU == "1", (cAliasQry)->RCX_FILFUN, (cAliasQry)->RCX_FILOCU) }
	DEFINE CELL NAME "CODOCU"		OF oSection3 TITLE OemToAnsi("Cod. Ocupante") ; //
	BLOCK{|| IIF((cAliasQry)->RCX_TIPOCU == "1", (cAliasQry)->RCX_MATFUN, (cAliasQry)->RCX_CODOCU ) }
	DEFINE CELL NAME "NOMEOCU"		OF oSection3 TITLE OemToAnsi("Nome Ocupante") SIZE 10 ; //
	BLOCK{|| IIF((cAliasQry)->RCX_TIPOCU == "1", (cAliasQry)->RA_NOME, (cAliasQry)->RD0_NOME ) }
	DEFINE CELL NAME "SUBST"			OF oSection3 TITLE "Titular?" SIZE 10 ;		//
	BLOCK{|| IIF((cAliasQry)->RCX_SUBST == "1", "Substituto", "Titular") }  // ###
	
	// Jamer Nunes Pedroso - 22/05/2017
	DEFINE SECTION oSection4 OF oSection3 TITLE OemToAnsi("Solicitaçoes") TABLES  "SRA", "RH3", "P10", "PA7" ORDERS aOrd
	
	DEFINE CELL NAME "RH3_DTSOLI"	OF oSection4  TITLE OemToAnsi("Data Solic.") SIZE 10         BLOCK{|| Stod(aSolRh3[1]) }
	DEFINE CELL NAME "RH3_CODIGO"	OF oSection4 TITLE OemToAnsi("Cod.Solic.") SIZE 10     BLOCK{|| aSolRh3[2] }
//?	DEFINE CELL NAME "P10_COD"	OF oSection4 TITLE OemToAnsi("Cod.Solic.Proteus") SIZE 10   BLOCK{|| aSolRh3[3] }
	DEFINE CELL NAME "RH3_XTPCTM"	OF oSection4 TITLE OemToAnsi("Cod.Tipo Solic.") SIZE 10     BLOCK{|| aSolRh3[4] }
	DEFINE CELL NAME "PA7_DESCR"	OF oSection4 TITLE OemToAnsi("Desc.Tipo Solic.") SIZE 10   BLOCK{|| aSolRh3[5] }
	DEFINE CELL NAME "RH3_FILINI"	OF oSection4 TITLE OemToAnsi("Filial Solicitante") SIZE 10  BLOCK{|| aSolRh3[6] }
	DEFINE CELL NAME "RH3_MATINI"	OF oSection4 TITLE OemToAnsi("Mat.Solicitante") SIZE 10     BLOCK{|| aSolRh3[7] }
	DEFINE CELL NAME "NOMESOLIC"	OF oSection4 TITLE OemToAnsi("Nome Solicitante") SIZE 10   BLOCK{|| aSolRh3[8] }
	DEFINE CELL NAME "RH3_STATUS"	OF oSection4 TITLE OemToAnsi("Status Solic.") SIZE 10      BLOCK{|| aSolRh3[9] }
	
	oSection2:SetLeftMargin(02)
	oSection3:SetLeftMargin(08)
	oSection4:SetLeftMargin(08)
	
	oReport:SetColSpace(2)
Return(oReport)

/*{Protheus.doc} ORG60Imp
@param oReport, object, descricao
*/
Static Function ORG60Imp(oReport)
	Local oSection1	:= oReport:Section(1)			//Departamentos
	Local oSection2	:= oReport:Section(1):Section(1)  	//Postos
	Local oSection3	:= oSection2:Section(1)			//Historico
	Local oSection4	:= oSection3:Section(1)			//Historico
	
	Local cTitPos		:= ""
	Local nReg		:= 0
	Local oBreakPost
	Local cGRPSOL		:= SuperGetMv("FS_GRPSOL",,"002001/006003/006005/006006/006007/006008/006010/")
	Local nQ			:= 0
	Local nCtSol		:= 0
	Local cArrStatus	:= ""
	/*
	mv_par01	Filial?
	mv_par02	Departamento?
	mv_par03	Posto?
	mv_par04	Status a Imprimir?
	mv_par05	Exibe Substituto (Nao/Sim)?
	mv_par06	Tipo de Relatorio (Analitico/Sintetico)?
	mv_par07	Gerar Relatório ou Planilha?
	*/
	Private aSolRh3
	Private cStatus	:= ""	//-1=Livre;2=Ocupado;3=Congelado;4=Cancelado
	
	Private cOrdem		:= ""
	Private cSts		:= MV_PAR04						// Status a Imprimir
	//?Private cSubst	:= IIF(MV_PAR05==1, '2', "%" + "'1', '2'" + "%" )	// Exibe substitutos
	Private cSubst		:= IIF(MV_PAR05==1, "'2'", "'1','2'")	// Exibe substitutos (Nao/Sim)
	Private lAnalit	    := Iif(MV_PAR06==1, .T.,.F.)			// Analitico / Sintetico
	Private cQ1grpSol	:= " ( "
	If (oReport:nDevice == 4 .And. oReport:nExcelPrintType == 3) //?.Or. oReport:nExcelPrintType == 2) )
	    MsgInfo("Nao imprime em Tipo Planilha e Formato de Tabela ")
	    oReport:CancelPrint()
	    Return( Nil )
	EndIf
	
	//-Ajusta a variavel para Query
	//-( RH3b.RH3_XTPCTM IN ('006') AND PAB_GRPSOL IN ('003','005','006','007','008','010') )
	//-SuperGetMv("FS_GRPSOL",,"002001/006003/006005/006006/006007/006008/006010")

	aGrupos := Separa(cGRPSOL,"/")
	aGrupos := ASort(aGrupos)
	nQ := 1
	While nQ <= Len(aGrupos)
	   cGrp    := Left(aGrupos[nQ],3)
	   cSubGrp := ""
	   While nQ <= Len(aGrupos) .And.;
	         Left(aGrupos[nQ],3) == cGrp
		     cSubGrp+=Right(aGrupos[nQ],3)+","
	      nQ++
	   End
	   cSubGrp   := Left(cSubGrp,Len(cSubGrp)-1)
       cQ1grpSol += "( RH3_XTPCTM IN ('"+cGrp+"') AND PAB_GRPSOL IN "+FormatIn(cSubGrp,",")+" ) "
	   If nQ <= Len(aGrupos)
		  cQ1grpSol += " OR "
	   EndIf
    End
    /*
	For nQ := 1 to Len(Alltrim(cGRPSOL))
		cQ1grpSol += "( RH3_XTPCTM IN ('"+Subs(cGRPSOL,nQ,3)
		nQ += 3
		cQ1grpSol += "') AND PAB_GRPSOL IN ('"+Subs(cGRPSOL,nQ,3)+"') ) "
		nQ += 3
		If ( nQ+1 ) <= Len(Alltrim(cGRPSOL))
			cQ1grpSol += " OR "
		EndIf
	Next nQ
	*/
	cQ1grpSol += " ) "
	cQ1grpSol := Iif(Alltrim(cQ1grpSol) == " (  ) ", "", cQ1grpSol)
	
	If lAnalit
		oSection3:Enable()
		oSection4:Enable()
	Else
		oSection3:Disable()
		oSection4:Disable()
		cSubst := "'2'"
	EndIf
	
	If MV_PAR05 == 1
		oSection3:Cell("SUBST"):Disable()
	Endif
	
	//MODIFICA VARIAVEIS PARA A QUERY
	cStatus := ""
	For nReg:=1 to Len(cSts)
		cStatus += "'"+Subs(cSts,nReg,1)+"'"
		If ( nReg+1 ) <= Len(cSts)
			cStatus += ","
		Endif
	Next nReg
	//?cStatus := "%" + cStatus + "%"	//-1=Livre;2=Ocupado;3=Congelado;4=Cancelado
	
	//TRANSFORMA PARAMETROS DO TIPO RANGE EM EXPRESSAO ADVPL PARA SER UTILIZADA NO FILTRO
	MakeSqlExpr("FSW0801301")
	
	DEFINE BREAK oBreakPost OF oSection1 WHEN oSection1:Cell("RCL_DEPTO") TITLE "Total de Postos" //
	
	oBreakPost:OnBreak({|x|cTitPos:="Total de Postos"})
	oBreakPost:SetTotalText({||cTitPos})
	
	DEFINE FUNCTION FROM oSection2:Cell("RCL_POSTO") FUNCTION COUNT BREAK oBreakPost TITLE "Postos " NO END SECTION //
	DEFINE FUNCTION FROM oSection2:Cell("RCL_NPOSTO") FUNCTION SUM BREAK oBreakPost TITLE "Quantidade Maxima " NO END SECTION //
	DEFINE FUNCTION FROM oSection2:Cell("RCL_OPOSTO") FUNCTION SUM BREAK oBreakPost TITLE "Quantidade Ocupados " NO END SECTION //
	DEFINE FUNCTION FROM oSection2:Cell("LINRESERV") FUNCTION SUM BREAK oBreakPost TITLE "Quantidade Reservados " NO END SECTION //
	DEFINE FUNCTION FROM oSection2:Cell("LINDISPON") FUNCTION SUM BREAK oBreakPost TITLE "Quantidade Disponivel " NO END SECTION //
	oSection1:SetTotalInLine(.T.)
	
	//-Verifica se vai imprimir via Relatorio ou Planilha (Excel)
	If mv_par07 = 2//-Planilha
		
		fQryAnalit()
		fGeraPlan()
		oReport:SetPreview(.F.)
		
		//Início - Thais Paiva - 8975363
		If oReport:nDevice == 4
		
			oSection2:SetParentQuery(.T.)
			oSection2:SetParentFilter({|cParam|(cAliasQry)->RCL_FILIAL+(cAliasQry)->RCL_DEPTO == cParam },{||(cAliasQry)->RCL_FILIAL+(cAliasQry)->RCL_DEPTO })
			
			oSection3:SetParentQuery(.T.)
			oSection3:SetParentFilter( { |cParam| (cAliasQry)->RCX_FILIAL+(cAliasQry)->RCX_POSTO == cParam },{ || (cAliasQry)->RCL_FILIAL+(cAliasQry)->RCL_POSTO })
			
			//INICIO DA IMPRESSAO DO FLUXO DO RELATORIO
			oReport:SetMeter( (cAliasQry)->(LastRec()) )
			
			dbSelectArea(cAliasQry)
			dbGoTop()
			While (cAliasQry)->(!Eof())
				
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				
				cFilTrb := (cAliasQry)->RCL_FILIAL
				cDepTrb := (cAliasQry)->RCL_DEPTO
				cPosTrb := (cAliasQry)->RCL_POSTO
				cCarTrb := (cAliasQry)->RCL_CARGO
				cFunTrb := (cAliasQry)->RCL_FUNCAO
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Impressao da Primeira Secao...     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oSection1:Init()
				oSection1:PrintLine()
				
				lFirst := .T.
				While !Eof() .And. RCL_FILIAL+RCL_DEPTO == cFilTrb+cDepTrb
					
					If lFirst
						//fVerReserv(oReport,cAliasQry) - Andre Carralero - 12041776
           				LINRESERV := (cAliasQry)->RESERVADOS
	                    LINDISPON := ((cAliasQry)->RCL_NPOSTO - (cAliasQry)->RCL_OPOSTO - LINRESERV)

						oSection2:Init()
						oSection2:PrintLine()
						lFirst := .F.
						
					ElseIf !( RCL_POSTO+RCL_CARGO+RCL_FUNCAO == cPosTrb+cCarTrb+cFunTrb )
						oSection2:Finish()
						//fVerReserv(oReport,cAliasQry) - Andre Carralero - 12041776
           				LINRESERV := (cAliasQry)->RESERVADOS
	                    LINDISPON := ((cAliasQry)->RCL_NPOSTO - (cAliasQry)->RCL_OPOSTO - LINRESERV)
						oSection2:Init()
						oSection2:PrintLine()
						
						cPosTrb := (cAliasQry)->RCL_POSTO
						cCarTrb := (cAliasQry)->RCL_CARGO
						cFunTrb := (cAliasQry)->RCL_FUNCAO
					EndIf
					
					If lAnalit
						oSection3:Init()
						cSolTrb := ""
						aSolAll := {}
						aHIst := {}
						While !Eof() .And. (cAliasQry)->(RCL_FILIAL+RCL_DEPTO+RCL_POSTO) == cFilTrb+cDepTrb+cPosTrb
							
							if ascan(aHist,{|x| x == (cAliasQry)->(RCX_FILFUN+RCX_MATFUN) }) == 0
								aadd(aHIst,(cAliasQry)->(RCX_FILFUN+RCX_MATFUN))
								oSection3:PrintLine()
								dbSelectArea(cAliasQry)
							endif
							
							if !Empty((cAliasQry)->RH3_CODIGO) .and. cSolTrb <> (cAliasQry)->RH3_FILIAL+(cAliasQry)->RH3_CODIGO+(cAliasQry)->FILIAL+(cAliasQry)->RCL_DEPTO+(cAliasQry)->POSTO
								
								if ascan(aSolAll,{|x| x[2]==(cAliasQry)->RH3_CODIGO .and. x[10]==(cAliasQry)->RH3_FILIAL}) == 0
									If (cAliasQry)->RH3_STATUS == "1"
										cArrStatus := (cAliasQry)->RH3_STATUS + "-Em processo de aprovacao" 
									ElseIf (cAliasQry)->RH3_STATUS == "2"
										cArrStatus := (cAliasQry)->RH3_STATUS + "-Atendida"
									ElseIf (cAliasQry)->RH3_STATUS == "3"
										cArrStatus := (cAliasQry)->RH3_STATUS + "-Reprovada"
									ElseIf (cAliasQry)->RH3_STATUS == "4"
										cArrStatus := (cAliasQry)->RH3_STATUS + "-Aguardando Efetivacao do RH"
									Else
										cArrStatus := (cAliasQry)->RH3_STATUS
									EndIf
									aadd( aSolAll,;
										{(cAliasQry)->RH3_DTSOLI;
										,(cAliasQry)->RH3_CODIGO;
										,(cAliasQry)->P10_COD;
										,(cAliasQry)->RH3_XTPCTM;
										,(cAliasQry)->PA7_DESCR;
										,(cAliasQry)->RH3_FILINI;
										,(cAliasQry)->RH3_MATINI;
										,(cAliasQry)->(POSICIONE('SRA',1,(cAliasQry)->RH3_FILINI+(cAliasQry)->RH3_MATINI,"RA_NOME"));
										,cArrStatus;
										,(cAliasQry)->RH3_FILIAL} )
								endif
							endif
							
							cSolTrb := (cAliasQry)->RH3_FILIAL+(cAliasQry)->RH3_CODIGO+(cAliasQry)->FILIAL+(cAliasQry)->RCL_DEPTO+(cAliasQry)->POSTO
							dbSkip()
						EndDo
						
						oSection4:Init()
						for nCtSol := 1 to Len(aSolAll)
							aSolRh3 := aSolAll[nCtSol]
							oSection4:PrintLine()
							aSolRh3 := {}
						next 1
						aSolall := {}
						
						oSection2:Finish()
						oSection3:Finish()
						oSection4:Finish()
					Else
						dbSelectArea(cAliasQry)
						dbSkip()
					EndIf
				EndDo
				oSection1:Finish()
			EndDo
		EndIf
		//Fim - Thais Paiva - 8975363
		
	Else			//-Relatorio
		If lAnalit
			
			fQryAnalit()
			
		Else	//-Sintetico
			cQuery := "SELECT DISTINCT "
			cQuery += "RCL_FILIAL,RCL_DEPTO,RCL_POSTO,RCL_CARGO,RCL_FUNCAO, "
			cQuery += "RCL_NPOSTO,RCL_OPOSTO,RESERV.RESERVADOS "
			cQuery += "FROM " + RetSqlName("RCL") + " RCL "
			cQuery += "LEFT JOIN " + RetSqlName("SQ3") + " SQ3 ON Q3_CARGO = RCL_CARGO AND SQ3.D_E_L_E_T_ = ' ' "
			cQuery += "LEFT JOIN " + RetSqlName("SQB") + " SQB ON QB_DEPTO = RCL_DEPTO AND QB_FILIAL = RCL_FILIAL AND SQB.D_E_L_E_T_ = ' ' "
			cQuery += "LEFT JOIN " + RetSqlName("SRJ") + " SRJ ON RJ_FUNCAO = RCL_FUNCAO AND SRJ.D_E_L_E_T_ = ' ' "
        	cQuery += " LEFT JOIN (SELECT RPAD(RH4f.RH4_VALNOV,8,' ') FILIAL,RPAD(RH4p.RH4_VALNOV,9,' ') POSTO, COUNT(*) RESERVADOS "
        	cQuery += "              FROM "+RetSqlName("RH3")+" RH3b "
        	cQuery += "             inner JOIN "+RetSqlName("RH4")+" RH4f "
        	cQuery += "                ON RH4f.RH4_FILIAL = RH3b.RH3_FILIAL  "
        	cQuery += "               AND RH4f.RH4_CODIGO = RH3b.RH3_CODIGO  "
        	cQuery += "               AND RH4f.RH4_CAMPO = RPAD(DECODE( RH3b.RH3_XTPCTM, '002', 'QS_FILPOST','006','RA_FILIAL'),10,' ')  "
        	cQuery += "               AND RH4f.D_E_L_E_T_ = ' '  "
        	cQuery += "             inner JOIN "+RetSqlName("RH4")+" RH4p "
        	cQuery += "                ON RH4p.RH4_FILIAL = RH3b.RH3_FILIAL  "
        	cQuery += "               AND RH4p.RH4_CODIGO = RH3b.RH3_CODIGO  "
        	cQuery += "               AND RH4p.RH4_CAMPO = RPAD(DECODE( RH3b.RH3_XTPCTM, '002', 'QS_POSTO','006','RA_POSTO'),10, ' ')  "
        	cQuery += "               AND RH4p.D_E_L_E_T_ = ' '  "
        	cQuery += "             INNER JOIN "+RetSqlName("PAB")+" PAB "
        	cQuery += "                ON PAB.D_E_L_E_T_ = ' '  "
        	cQuery += "               AND RH3_XCODAL = PAB_CODIGO "
        	cQuery += "               AND RH3_XTPCTM = PAB_TPSOLI  "
        	cQuery += "             WHERE RH3b.D_E_L_E_T_ = ' ' "
			//chamado 12041776
			//Marcelo Amaral Totvs
			//correção na query de reservados
//        	cQuery += "               AND (RPAD(RH4f.RH4_VALNOV,8,' ') IN('01310055')) "
        	cQuery += "               AND " + cQ1grpSol
        	cQuery += "               AND ( EXISTS  (SELECT 1 "
        	cQuery += "                                FROM "+RetSqlName("SQS")+" SQS   "
        	cQuery += "                               WHERE SQS.QS_XSOLFIL = RH3b.RH3_FILIAL  "
        	cQuery += "                                 AND SQS.QS_XSOLPTL = RH3b.RH3_CODIGO "
        	cQuery += "                                 AND SQS.D_E_L_E_T_ = ' ' "
        	cQuery += "                                 AND SQS.QS_XSTATUS in ('1','2','3','4','8') "
        	cQuery += "                                 AND ROWNUM = 1  ) "
        	cQuery += "                              OR RH3b.RH3_STATUS IN ('1','4') ) "
        	cQuery += "             GROUP BY RPAD(RH4f.RH4_VALNOV,8,' '),RPAD(RH4p.RH4_VALNOV,9,' ')) RESERV "
            cQuery += "   ON RESERV.FILIAL = RCL.RCL_FILIAL "
            cQuery += "  AND RESERV.POSTO  = RCL.RCL_POSTO "
			cQuery += " WHERE "
			cQuery += " RCL_STATUS IN ("+cStatus+") AND RCL.D_E_L_E_T_ = ' ' "
			If !Empty(MV_PAR01)
				cQuery += " AND "+Alltrim(MV_PAR01)+" "
			EndIf
			If !Empty(MV_PAR02)
				cQuery += " AND "+Alltrim(MV_PAR02)+" "
			EndIf
			If !Empty(MV_PAR03)
				cQuery += " AND "+Alltrim(MV_PAR03)+" "
			EndIf
			cQuery += " ORDER BY RCL_FILIAL,RCL_DEPTO,RCL_POSTO "
			
			//cQuery := ChangeQuery(cQuery)
			dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAliasQry, .T., .T.)
			
			//chamado 12041776
			//Marcelo Amaral Totvs
			//correção na query de reservados
			memowrite("c:\temp\F0801301_1"+".txt",cQuery)

			If lAnalit
				TCSETFIELD(cAliasQry,"RCX_DTINI","D",08,0)
				TCSETFIELD(cAliasQry,"RCX_DTFIM","D",08,0)
			EndIf
			TCSETFIELD(cAliasQry,"RESERVADOS","N",12,2)
			TCSETFIELD(cAliasQry,"DISPONIVEL","N",12,2)
		EndIf
		
		oSection2:SetParentQuery(.T.)
		oSection2:SetParentFilter({|cParam|(cAliasQry)->RCL_FILIAL+(cAliasQry)->RCL_DEPTO == cParam },{||(cAliasQry)->RCL_FILIAL+(cAliasQry)->RCL_DEPTO })
		
		oSection3:SetParentQuery(.T.)
		oSection3:SetParentFilter( { |cParam| (cAliasQry)->RCX_FILIAL+(cAliasQry)->RCX_POSTO == cParam },{ || (cAliasQry)->RCL_FILIAL+(cAliasQry)->RCL_POSTO })
		
		//INICIO DA IMPRESSAO DO FLUXO DO RELATORIO
		oReport:SetMeter( (cAliasQry)->(LastRec()) )
		
		dbSelectArea(cAliasQry)
		dbGoTop()
		While (cAliasQry)->(!Eof())
			
			oReport:IncMeter()
			If oReport:Cancel()
				Exit
			EndIf
			
			cFilTrb := (cAliasQry)->RCL_FILIAL
			cDepTrb := (cAliasQry)->RCL_DEPTO
			cPosTrb := (cAliasQry)->RCL_POSTO
			cCarTrb := (cAliasQry)->RCL_CARGO
			cFunTrb := (cAliasQry)->RCL_FUNCAO
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Impressao da Primeira Secao...     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oSection1:Init()
			oSection1:PrintLine()
			
			lFirst := .T.
			While !Eof() .And. RCL_FILIAL+RCL_DEPTO == cFilTrb+cDepTrb
				
				If lFirst
   				    //fVerReserv(oReport,cAliasQry) - Andre Carralero - 12041776
      				LINRESERV := (cAliasQry)->RESERVADOS
                    LINDISPON := ((cAliasQry)->RCL_NPOSTO - (cAliasQry)->RCL_OPOSTO - LINRESERV)

					oSection2:Init()
					oSection2:PrintLine()
					lFirst := .F.
					
				ElseIf !( RCL_POSTO+RCL_CARGO+RCL_FUNCAO == cPosTrb+cCarTrb+cFunTrb )
					oSection2:Finish()
					//fVerReserv(oReport,cAliasQry) - Andre Carralero - 12041776
       				LINRESERV := (cAliasQry)->RESERVADOS
                    LINDISPON := ((cAliasQry)->RCL_NPOSTO - (cAliasQry)->RCL_OPOSTO - LINRESERV)
					oSection2:Init()
					oSection2:PrintLine()
					
					cPosTrb := (cAliasQry)->RCL_POSTO
					cCarTrb := (cAliasQry)->RCL_CARGO
					cFunTrb := (cAliasQry)->RCL_FUNCAO
				EndIf
				
				If lAnalit
					oSection3:Init()
					cSolTrb := ""
					aSolAll := {}
					aHIst := {}
					While !Eof() .And. (cAliasQry)->(RCL_FILIAL+RCL_DEPTO+RCL_POSTO) == cFilTrb+cDepTrb+cPosTrb
						
						if ascan(aHist,{|x| x == (cAliasQry)->(RCX_FILFUN+RCX_MATFUN) }) == 0
							aadd(aHIst,(cAliasQry)->(RCX_FILFUN+RCX_MATFUN))
							oSection3:PrintLine()
							dbSelectArea(cAliasQry)
						endif
						
						if !Empty((cAliasQry)->RH3_CODIGO) .and. cSolTrb <> (cAliasQry)->RH3_FILIAL+(cAliasQry)->RH3_CODIGO+(cAliasQry)->FILIAL+(cAliasQry)->RCL_DEPTO+(cAliasQry)->POSTO
							
							if ascan(aSolAll,{|x| x[2]==(cAliasQry)->RH3_CODIGO .and. x[10]==(cAliasQry)->RH3_FILIAL}) == 0
								If (cAliasQry)->RH3_STATUS == "1"
									cArrStatus := (cAliasQry)->RH3_STATUS + "-Em processo de aprovacao" 
								ElseIf (cAliasQry)->RH3_STATUS == "2"
									cArrStatus := (cAliasQry)->RH3_STATUS + "-Atendida"
								ElseIf (cAliasQry)->RH3_STATUS == "3"
									cArrStatus := (cAliasQry)->RH3_STATUS + "-Reprovada"
								ElseIf (cAliasQry)->RH3_STATUS == "4"
									cArrStatus := (cAliasQry)->RH3_STATUS + "-Aguardando Efetivacao do RH"
								Else
									cArrStatus := (cAliasQry)->RH3_STATUS
								EndIf
								aadd( aSolAll,;
									{(cAliasQry)->RH3_DTSOLI;
									,(cAliasQry)->RH3_CODIGO;
									,(cAliasQry)->P10_COD;
									,(cAliasQry)->RH3_XTPCTM;
									,(cAliasQry)->PA7_DESCR;
									,(cAliasQry)->RH3_FILINI;
									,(cAliasQry)->RH3_MATINI;
									,(cAliasQry)->(POSICIONE('SRA',1,(cAliasQry)->RH3_FILINI+(cAliasQry)->RH3_MATINI,"RA_NOME"));
									,cArrStatus;
									,(cAliasQry)->RH3_FILIAL} )
							endif
						endif
						
						cSolTrb := (cAliasQry)->RH3_FILIAL+(cAliasQry)->RH3_CODIGO+(cAliasQry)->FILIAL+(cAliasQry)->RCL_DEPTO+(cAliasQry)->POSTO
						dbSkip()
					EndDo
					
					oSection4:Init()
					for nCtSol := 1 to Len(aSolAll)
						aSolRh3 := aSolAll[nCtSol]
						oSection4:PrintLine()
						aSolRh3 := {}
					next 1
					aSolall := {}
					
					oSection2:Finish()
					oSection3:Finish()
					oSection4:Finish()
				Else
					dbSelectArea(cAliasQry)
					dbSkip()
				EndIf
			EndDo
			oSection1:Finish()
		EndDo
	EndIf
	
	dbSelectArea(cAliasQry)
	dbCloseArea()
Return

/*{Protheus.doc} fVerReserv
@param oReport, object, descricao
@param cAliasQry, characters, descricao
*/
Static Function fVerReserv(oReport,cAliasQry)
	Local cQuery
	Local a1Area := GetArea()
	Local cAlias2Qry := GetNextAlias()
	
	LINRESERV := 0
	LINDISPON := 0
	/* 
	mv_par01	Filial?  
	mv_par02	Departamento?
	mv_par03	Posto?
	mv_par04	Status a Imprimir?
	mv_par05	Exibe Substituto (Nao/Sim)?
	mv_par06	Tipo de Relatorio (Analitico/Sintetico)?
	mv_par07	Gerar Relatório ou Planilha?
	*/
	 //ticket n° 3557613 - 415966 - Paulo Dias - ajuste na query para contagem de reservados  
	
	cQuery := "SELECT COUNT( * ) RESERVADOS FROM "
	cQuery +="(SELECT "
	cQuery +=" RH4F.RH4_CAMPO RH4f_DEF, RH4p.RH4_CAMPO RH4p_DEF, RPAD(RH4f.RH4_VALNOV,8,' ') FILIAL, RPAD(RH4p.RH4_VALNOV,9,' ') POSTO, RH3b.RH3_XTPCTM, "
	cQuery +=" RH3b.RH3_FILIAL, RH3b.RH3_CODIGO "
	cQuery +=" FROM RH3010 RH3b "
	cQuery +=" left JOIN RH4010 RH4f ON RH4f.RH4_FILIAL = RH3b.RH3_FILIAL "
	cQuery +=" AND RH4f.RH4_CODIGO = RH3b.RH3_CODIGO "
	cQuery +=" AND RH4f.RH4_CAMPO = RPAD(DECODE( RH3b.RH3_XTPCTM, '002', 'QS_FILPOST','006','RA_FILIAL'),10,' ') "
	cQuery +=" left JOIN RH4010 RH4p ON RH4p.RH4_FILIAL = RH3b.RH3_FILIAL "
	cQuery +=" AND RH4p.RH4_CODIGO = RH3b.RH3_CODIGO "
	cQuery +=" AND RH4p.RH4_CAMPO = RPAD(DECODE( RH3b.RH3_XTPCTM, '002', 'QS_POSTO','006','RA_POSTO'),10, ' ') "
	cQuery +=" AND RH4p.D_E_L_E_T_ <> '*' "
	cQuery +=" INNER JOIN  PAB010 PAB ON PAB.D_E_L_E_T_ = ' ' "
	cQuery +=" AND RH3_XCODAL = PAB_CODIGO AND RH3_XTPCTM = PAB_TPSOLI "
	cQuery +=" AND " + cQ1grpSol
	cQuery +=" WHERE RH3b.D_E_L_E_T_ = ' ' "
	cQuery +=" AND ( EXISTS  (SELECT 1 FROM SQS010 SQS   WHERE SQS.QS_XSOLFIL = RH3b.RH3_FILIAL "
	cQuery +=" AND   SQS.QS_XSOLPTL = RH3b.RH3_CODIGO "  
	cQuery +="AND   SQS.D_E_L_E_T_ = ' ' "
	
	// Chamado No.5452731 - 418497 - Don Junior - retirada status '9' (reservado) - Melhoria Gavina
//	cQuery +=" AND   SQS.QS_XSTATUS in ('1','2','3','4','8','9')   AND   ROWNUM = 1  )    OR RH3b.RH3_STATUS IN ('1','4') ) "
	cQuery +=" AND   SQS.QS_XSTATUS in ('1','2','3','4','8')   AND   ROWNUM = 1  )    OR RH3b.RH3_STATUS IN ('1','4') ) "

	cQuery +=" ) RALL "
	If lAnalit
		cQuery +=" WHERE RALL.FILIAL = '"+(cAliasQry)->FILIAL+"' AND RALL.POSTO = '"+(cAliasQry)->POSTO+"' "
	Else
		cQuery +=" WHERE RALL.FILIAL = '"+(cAliasQry)->RCL_FILIAL+"' AND RALL.POSTO = '"+(cAliasQry)->RCL_POSTO+"' "
	EndIf
	
	//cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAlias2Qry, .T., .T.)

	//chamado 12041776
	//Marcelo Amaral Totvs
	//correção na query de reservados
	memowrite("c:\temp\F0801301_2"+".txt",cQuery)

	LINRESERV := (cAlias2Qry)->RESERVADOS
	LINDISPON := ((cAliasQry)->RCL_NPOSTO - (cAliasQry)->RCL_OPOSTO - LINRESERV)
	
	dbSelectArea(cAlias2Qry)
	dbCloseArea()
	
	RestArea(a1Area)
Return .t.

/*{Protheus.doc} ImpCleanLine
@param oSection1, object, descricao
@param oSection2, object, descricao
@param oSection3, object, descricao
*/
Static Function ImpCleanLine(oSection1,oSection2,oSection3)
	
	oSection1:Cell("RCL_FILIAL"):SetValue("")
	oSection1:Cell("RCL_DEPTO" ):SetValue("")
	oSection1:Cell("QB_DESCRIC"):SetValue("")
	
	oSection2:Cell("RCL_POSTO" ):SetValue("")
	oSection2:Cell("RCL_CARGO" ):SetValue("")
	oSection2:Cell("Q3_DESCSUM"):SetValue("")
	oSection2:Cell("RCL_FUNCAO"):SetValue("")
	oSection2:Cell("RJ_DESC"   ):SetValue("")
	oSection2:Cell("RCL_NPOSTO"):SetValue("")
	oSection2:Cell("RCL_OPOSTO"):SetValue("")
	oSection2:Cell("LINRESERV" ):SetValue("")
	oSection2:Cell("LINDISPON" ):SetValue("")
	
	oSection3:Cell("RCX_DTINI" ):SetValue("")
	oSection3:Cell("RCX_DTFIM" ):SetValue("")
	oSection3:Cell("FILOCU"    ):SetValue("")
	oSection3:Cell("CODOCU"	   ):SetValue("")
	oSection3:Cell("NOMEOCU"   ):SetValue("'Solicitação ==>:'")
	oSection3:Cell("SUBST"     ):SetValue("")
	
	oSection1:PrintLine()
	oSection2:PrintLine()
	oSection3:PrintLine()
Return(.T.)

/*{Protheus.doc} fQryAnalit
*/
//ticket n° 3557613 - 415966 - Paulo Dias - ajuste na query para solicitações
Static Function fQryAnalit()
	Local cQuery
	cQuery := "SELECT DISTINCT"
	cQuery += " 'QUERY NOVA' ORIGEM, RCL_FILIAL, RCL_DEPTO, QB_DESCRIC, RCL_POSTO, RCL_CARGO, Q3_DESCSUM, RCL_FUNCAO, RJ_DESC, "
	cQuery += " RCL_SALAR, RCL_BENEF, RCL_ENCARG, RCL_NPOSTO, RCL_OPOSTO, RH3_FILIAL, RALL.POSTO, RALL.FILIAL, "
	cQuery += " RCX_DTINI, RCX_DTFIM, RCX_FILOCU, RCX_FILFUN, RCX_CODOCU, RCX_TIPOCU, RCX_POSTO, RCX_FILIAL, RCX_MATFUN, RA_NOME, RCX_SUBST, "
	cQuery += " RH3_DTSOLI, RH3_CODIGO, P10_COD, RH3_XTPCTM, PA7_DESCR, RH3_FILINI, RH3_MATINI, RH3_STATUS,RESERV.RESERVADOS "
	//chamado 12041776
	//Marcelo Amaral Totvs
	//invalid field name in Alias RCLQRY->RD0_NOME on { ||IIF((CALIASQRY)->RCX_TIPOCU=="1",
	//(CALIASQRY)->RA_NOME,(CALIASQRY)->RD0_NOME)}(F0801301.PRW) 02/08/2021 17:09:32 line : 64
	//If !(mv_par07 = 2)	//-Planilha
		cQuery += ", RD0_NOME "
	//EndIf
	cQuery += " FROM "+RetSqlName("RCL")+" RCL LEFT JOIN "
	cQuery += " ( SELECT  RH4F.RH4_CAMPO RH4f_DEF, RH4p.RH4_CAMPO RH4p_DEF, RPAD(RH4f.RH4_VALNOV,8,' ') FILIAL, RPAD(RH4p.RH4_VALNOV,9,' ') POSTO, "
	cQuery += "     RH3.RH3_XTPCTM,  RH3.RH3_FILIAL, RH3.RH3_FILINI, RH3.RH3_CODIGO,RH3.RH3_DTSOLI,RH3_MATINI,RH3_STATUS,PA7_DESCR "
	cQuery += "     FROM "+RetSqlName("RH3")+" RH3 "
	cQuery += " LEFT JOIN "+RetSqlName("RH4")+" RH4f ON RH4f.RH4_FILIAL = RH3.RH3_FILIAL "
	cQuery += "          AND RH4f.RH4_CODIGO = RH3.RH3_CODIGO "
	cQuery += "          AND RH4f.RH4_CAMPO = RPAD( DECODE( RH3_XTPCTM, '002', 'QS_FILPOST','006','RA_FILIAL'),10, ' ') "
	cQuery += "          AND RH4f.D_E_L_E_T_ <> '*' "
	cQuery += " LEFT JOIN "+RetSqlName("RH4")+" RH4p ON RH4p.RH4_FILIAL = RH3.RH3_FILIAL "
	cQuery += "          AND RH4p.RH4_CODIGO = RH3.RH3_CODIGO "
	cQuery += "          AND RH4p.RH4_CAMPO = RPAD( DECODE( RH3_XTPCTM, '002', 'QS_POSTO','006','RA_POSTO'),10, ' ') "
	cQuery += "          AND RH4p.D_E_L_E_T_ <> '*' "
	cQuery += " INNER JOIN  "+RetSqlName("PAB")+" PAB ON PAB.D_E_L_E_T_ = ' ' AND RH3_XCODAL = PAB_CODIGO AND RH3_XTPCTM = PAB_TPSOLI "
	cQuery += "  LEFT JOIN (SELECT PA7_CODIGO,MAX(PA7_DESCR) PA7_DESCR "
	cQuery += "               FROM "+RetSqlName("PA7")
	cQuery += "              WHERE D_E_L_E_T_ = ' ' "
	cQuery += "              GROUP BY PA7_CODIGO) PA7 "
	cQuery += "   ON PA7_CODIGO = RH3_XTPCTM  "
	// Andre Carralero - 12041776
	//cQuery += " LEFT JOIN "+RetSqlName("PA7")+" PA7 ON PA7_CODIGO = RH3_XTPCTM  and PA7.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE  RH3.D_E_L_E_T_ = ' ' "
	cQuery += " AND " + cQ1grpSol
	cQuery += " AND (EXISTS (SELECT 1 FROM "+RetSqlName("SQS")+" SQS "
	cQuery += "             WHERE SQS.QS_XSOLFIL = RH3.RH3_FILIAL "
	cQuery += "             AND   SQS.QS_XSOLPTL = RH3.RH3_CODIGO "
	cQuery += "             AND   SQS.D_E_L_E_T_ = ' ' "

	// Chamado No.5452731 - 418497 - Don Junior - retirada status '9' (reservado) - Melhoria Gavina
	//cQuery += "             AND   SQS.QS_XSTATUS in ('1','2','3','4','8','9') "
	cQuery += "             AND   SQS.QS_XSTATUS in ('1','2','3','4','8') "

	cQuery += "             AND   ROWNUM = 1 ) "
	cQuery += " AND RH3_STATUS IN ('1','2','4') "
	cQuery += " OR RH3_STATUS IN ('1','4')) "
	cQuery += " ) RALL"
	cQuery += " ON RALL.FILIAL = RCL_FILIAL AND RALL.POSTO = RCL.RCL_POSTO   AND RCL.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN  "+RetSqlName("RCX")+" RCX"
	cQuery += " ON RCX.RCX_FILIAL = RCL.RCL_FILIAL AND RCX.RCX_POSTO = RCL.RCL_POSTO and RCX.D_E_L_E_T_ = ' '"
	cQuery += " LEFT JOIN  "+RetSqlName("SRA")+" SRA ON RCX_MATFUN = RA_MAT AND RCX_FILFUN = RA_FILIAL AND SRA.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN  "+RetSqlName("P10")+" P10 ON RH3_CODIGO = P10_CODRH3 AND RH3_FILINI = P10_FILIAL AND P10.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN  "+RetSqlName("RD0")+" RD0 ON RCX_CODOCU = RD0_CODIGO AND RCX_FILOCU = RD0_FILIAL AND RD0.D_E_L_E_T_ = ' '"
	cQuery += " LEFT JOIN  "+RetSqlName("SQ3")+" SQ3 ON Q3_CARGO = RCL.RCL_CARGO AND SQ3.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN  "+RetSqlName("SQB")+" SQB ON QB_DEPTO = RCL.RCL_DEPTO AND QB_FILIAL = RCL_FILIAL AND SQB.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN  "+RetSqlName("SRJ")+" SRJ ON RJ_FUNCAO = RCL.RCL_FUNCAO AND SRJ.D_E_L_E_T_ = ' '"
	
	cQuery += " LEFT JOIN (SELECT RPAD(RH4f.RH4_VALNOV,8,' ') FILIAL,RPAD(RH4p.RH4_VALNOV,9,' ') POSTO, COUNT(*) RESERVADOS "
	cQuery += "              FROM "+RetSqlName("RH3")+" RH3b "
	cQuery += "             inner JOIN "+RetSqlName("RH4")+" RH4f "
	cQuery += "                ON RH4f.RH4_FILIAL = RH3b.RH3_FILIAL  "
	cQuery += "               AND RH4f.RH4_CODIGO = RH3b.RH3_CODIGO  "
	cQuery += "               AND RH4f.RH4_CAMPO = RPAD(DECODE( RH3b.RH3_XTPCTM, '002', 'QS_FILPOST','006','RA_FILIAL'),10,' ')  "
	cQuery += "               AND RH4f.D_E_L_E_T_ = ' '  "
	cQuery += "             inner JOIN "+RetSqlName("RH4")+" RH4p "
	cQuery += "                ON RH4p.RH4_FILIAL = RH3b.RH3_FILIAL  "
	cQuery += "               AND RH4p.RH4_CODIGO = RH3b.RH3_CODIGO  "
	cQuery += "               AND RH4p.RH4_CAMPO = RPAD(DECODE( RH3b.RH3_XTPCTM, '002', 'QS_POSTO','006','RA_POSTO'),10, ' ')  "
	cQuery += "               AND RH4p.D_E_L_E_T_ = ' '  "
	cQuery += "             INNER JOIN "+RetSqlName("PAB")+" PAB "
	cQuery += "                ON PAB.D_E_L_E_T_ = ' '  "
	cQuery += "               AND RH3_XCODAL = PAB_CODIGO "
	cQuery += "               AND RH3_XTPCTM = PAB_TPSOLI  "
	cQuery += "             WHERE RH3b.D_E_L_E_T_ = ' ' "
	//chamado 12041776
	//Marcelo Amaral Totvs
	//correção na query de reservados
//	cQuery += "               AND (RPAD(RH4f.RH4_VALNOV,8,' ') IN('01310055')) "
	cQuery += "               AND " + cQ1grpSol
	cQuery += "               AND ( EXISTS  (SELECT 1 "
	cQuery += "                                FROM "+RetSqlName("SQS")+" SQS   "
	cQuery += "                               WHERE SQS.QS_XSOLFIL = RH3b.RH3_FILIAL  "
	cQuery += "                                 AND SQS.QS_XSOLPTL = RH3b.RH3_CODIGO "
	cQuery += "                                 AND SQS.D_E_L_E_T_ = ' ' "
	cQuery += "                                 AND SQS.QS_XSTATUS in ('1','2','3','4','8') "
	cQuery += "                                 AND ROWNUM = 1  ) "
	cQuery += "                              OR RH3b.RH3_STATUS IN ('1','4') ) "
	cQuery += "             GROUP BY RPAD(RH4f.RH4_VALNOV,8,' '),RPAD(RH4p.RH4_VALNOV,9,' ')) RESERV "
	If lAnalit
	   cQuery += "   ON RESERV.FILIAL = RALL.FILIAL "
	   cQuery += "  AND RESERV.POSTO  = RALL.POSTO "
	Else
	   cQuery += "   ON RESERV.FILIAL = RCL.RCL_FILIAL "
	   cQuery += "  AND RESERV.POSTO  = RCL.RCL_POSTO "
	EndIf
	cQuery += " WHERE "
	cQuery += " RCL_STATUS IN ("+cStatus+") AND RCL.D_E_L_E_T_ = ' ' "
	If !Empty(MV_PAR01)
		cQuery += " AND "+Alltrim(MV_PAR01)+" "
	EndIf
	If !Empty(MV_PAR02)
		cQuery += " AND "+Alltrim(MV_PAR02)+" "
	EndIf
	If !Empty(MV_PAR03)
		cQuery += " AND "+Alltrim(MV_PAR03)+" "
	EndIf
	cQuery += " ORDER BY RCL_FILIAL,RCL_DEPTO,RCL_POSTO, RCX_FILFUN, RCX_MATFUN "
	
	//cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAliasQry, .T., .T.)

	//chamado 12041776
	//Marcelo Amaral Totvs
	//correção na query de reservados
	memowrite("c:\temp\F0801301_3"+".txt",cQuery)
	
	//?If lAnalit
		TCSETFIELD(cAliasQry,"RCX_DTINI","D",08,0)
		TCSETFIELD(cAliasQry,"RCX_DTFIM","D",08,0)
	//?EndIf
	TCSETFIELD(cAliasQry,"RESERVADOS","N",12,2)
	TCSETFIELD(cAliasQry,"DISPONIVEL","N",12,2)
Return

/*{Protheus.doc} fGeraPlan
*/
Static Function fGeraPlan()
	Local oExcelApp := MsExcel():New()
	//??Local oExcelApp := FwMsExcel():New()
	Local nAux  := 0
	Local nPos  := 0
	Local nSol	:= 0
	Local cPath := "" //GetTempPath() Thais Paiva - 8975363
	Local cArq  := "FS"+dTos(dDataBase)+StrTran(time(),':','')
	Local cQry  := ""
	Local cEOL  := CHR(13)+CHR(10)
	Local aStru := DbStruct()
	Local cMyChav := ""
	Local cMy2Chav := ""
	Local cIgnCpos := ""

	Local cOcup := "" // ticket n° 8848019 
	
	//Início - Thais Paiva - 8975363
	If oReport:nDevice == 4 
		cPath := oReport:cdir
	Else
		cPath := GetTempPath()
	EndIf
	//Fim - Thais Paiva - 8975363
	
	// Para instanciar e configurar o objeto da String
	oTString        := TCString():New() 
	oTString:cPath  := cPath 
	oTString:cArq   := cArq+".csv"	//?cNome + ".xml" 
	oTString:Clear()

	//-Grava o Array das Solicitações
	cMyChav := ""
	While !Eof()
		if !Empty(RH3_CODIGO) .and. !(cMyChav == RH3_FILIAL+RH3_CODIGO+RCL_FILIAL+RCL_DEPTO+RCL_POSTO)
			
			if ascan(aSolAll,{|x| x[2]==RH3_CODIGO .and. x[10]==RH3_FILIAL}) == 0
				If RH3_STATUS == "1"
					cArrStatus := RH3_STATUS + "-Em processo de aprovacao" 
				ElseIf RH3_STATUS == "2"
					cArrStatus := RH3_STATUS + "-Atendida"
				ElseIf RH3_STATUS == "3"
					cArrStatus := RH3_STATUS + "-Reprovada"
				ElseIf RH3_STATUS == "4"
					cArrStatus := RH3_STATUS + "-Aguardando Efetivacao do RH"
				Else
					cArrStatus := RH3_STATUS
				EndIf
				//fVerReserv(oReport,cAliasQry) - Andre Carralero - 12041776
   				LINRESERV := (cAliasQry)->RESERVADOS
                LINDISPON := ((cAliasQry)->RCL_NPOSTO - (cAliasQry)->RCL_OPOSTO - LINRESERV)

				aAdd( aSolAll,;
					{RH3_DTSOLI;	//-01
					,RH3_CODIGO;	//-02
					,P10_COD;		//-03
					,RH3_XTPCTM;	//-04
					,PA7_DESCR;	//-05
					,RH3_FILINI;	//-06
					,RH3_MATINI;	//-07
					,(POSICIONE('SRA',1,RH3_FILINI+RH3_MATINI,"RA_NOME"));	//-08
					,cArrStatus;	//-09
					,RH3_FILIAL;	//-10
					,RCL_FILIAL;	//-11
					,RCL_DEPTO;	//-12
					,RCL_POSTO;	//-13
					,"";		//-14
					,RCL_CARGO;	//-15
					,Q3_DESCSUM;//-16
					,RCL_FUNCAO;//-17
					,RJ_DESC;//-18
					,Str(RCL_NPOSTO,3,0);//-19
					,Str(RCL_OPOSTO,3,0);//-20
					,Str(LINRESERV,3,0);//-21
					,Str(LINDISPON,3,0);//-22
					,RCX_DTINI;//-23
					,RCX_DTFIM;//-24
					,IIF(Empty(cArrStatus),RCX_FILFUN,"");//-25
					,IIF(Empty(cArrStatus),RCX_TIPOCU,"");//-26
					,IIF(Empty(cArrStatus),RCX_FILIAL,"");//-27
					,IIF(Empty(cArrStatus),RCX_MATFUN,"");//-28
					,IIF(Empty(cArrStatus),RA_NOME,"");//-29
					,IIF(Empty(cArrStatus),RCX_SUBST,"")} ) //-30		
			endif
			
			cMyChav := RH3_FILIAL+RH3_CODIGO+RCL_FILIAL+RCL_DEPTO+RCL_POSTO
		endif
		dbSkip()
	EndDo

	//-Inclui o cabeçalho no arquivo
	cQry := "RCL_FILIAL;RCL_DEPTO;QB_DESCRIC;RCL_POSTO;RCL_CARGO;Q3_DESCSUM;RCL_FUNCAO;RJ_DESC;"
	cQry += "RCL_NPOSTO;RCL_OPOSTO;RESERVADO;DISPONIVEL;RCX_DTINI;RCX_DTFIM;RCX_FILFUN;"
	cQry += "RCX_TIPOCU;RCX_FILIAL;RCX_MATFUN;RA_NOME;RCX_SUBST;"
	//-Cabeçalho das solicitações
	cQry += "RH3_DTSOLI;RH3_CODIGO;RH3_XTPCTM;PA7_DESCR;RH3_FILINI;RH3_MATINI;NOMESOLIC;RH3_STATUS"
	cQry += cEOL

	//chamado 12041776
	//Marcelo Amaral Totvs
	oTString:SetString(cQry)
	cQry := ""

	//-Inclui os registros no arquivo
	dbGoTop()
	cMyChav := ""
	cMy2Chav := ""
	While !Eof()
		
		//-Verifica se tem Solicitações para gerar
		If !(cMyChav == RH3_FILIAL+RH3_CODIGO+RCL_FILIAL+RCL_DEPTO+RCL_POSTO)
			nPos := 0
			If Len(aSolAll) > 0 .And. ;
				(( nPos := aScan(aSolAll,{|x| x[10]==RH3_FILIAL .and. x[02]==RH3_CODIGO .and. x[11]==RCL_FILIAL .and. x[12]==RCL_DEPTO .and. x[13]==RCL_POSTO })) > 0 )
				
				For nSol := nPos to Len(aSolAll)
					If aSolAll[nSol,10]+aSolAll[nSol,02]+aSolAll[nSol,11]+aSolAll[nSol,12]+aSolAll[nSol,13] == RH3_FILIAL+RH3_CODIGO+RCL_FILIAL+RCL_DEPTO+RCL_POSTO
						
						If Empty(aSolAll[nSol,14])
							aSolAll[nSol,14] := "x"
							cQry += "'"+AllTrim(aSolAll[nSol,11]) + ";"
							cQry += "'"+AllTrim(aSolAll[nSol,12]) + ";"       
//							cQry += "'"+POSICIONE('SQB',1,xFilial("SQB")+AllTrim(aSolAll[nSol,12]),"QB_DESCRIC") + ";"
							cQry += "'"+POSICIONE('SQB',1,RCL_FILIAL+AllTrim(aSolAll[nSol,12]),"QB_DESCRIC") + ";"							
							cQry += "'"+AllTrim(aSolAll[nSol,13]) + ";"
							cQry += "'"+AllTrim(aSolAll[nSol,15]) + ";"
							cQry += "'"+AllTrim(aSolAll[nSol,16]) + ";"
							cQry += "'"+AllTrim(aSolAll[nSol,17]) + ";"
							cQry += "'"+AllTrim(aSolAll[nSol,18]) + ";"
							cQry += ""+AllTrim(aSolAll[nSol,19]) + ";"
							cQry += ""+AllTrim(aSolAll[nSol,20]) + ";"
							cQry += ""+AllTrim(aSolAll[nSol,21]) + ";"
							cQry += ""+AllTrim(aSolAll[nSol,22]) + ";"
							cQry += ""+ DTOC(STOD(AllTrim(aSolAll[nSol,23]))) + ";"
							cQry += ""+ DTOC(STOD(AllTrim(aSolAll[nSol,24]))) + ";"
							cQry += "'"+AllTrim(aSolAll[nSol,25]) + ";"
							cQry += "'"+AllTrim(aSolAll[nSol,26]) + ";"
							cQry += "'"+AllTrim(aSolAll[nSol,27]) + ";"
							cQry += "'"+AllTrim(aSolAll[nSol,28]) + ";"
							cQry += "'"+AllTrim(aSolAll[nSol,29]) + ";"
							cQry += "'"+AllTrim(aSolAll[nSol,30]) + ";"							
							cQry += DTOC(STOD(AllTrim(aSolAll[nSol,01])))+ ";"
							cQry += "'"+AllTrim(aSolAll[nSol,02]) + ";"
							cQry += "'"+AllTrim(aSolAll[nSol,04]) + ";"
							cQry += AllTrim(aSolAll[nSol,05]) + ";"
							cQry += "'"+AllTrim(aSolAll[nSol,06]) + ";"
							cQry += "'"+AllTrim(aSolAll[nSol,07]) + ";"
							cQry += AllTrim(aSolAll[nSol,08]) + ";"
							cQry += AllTrim(aSolAll[nSol,09]) + ";"
							cQry += cEOL
							
							cOcup  := AllTrim(aSolAll[1,20]) // ticket n° 8848019 -- atribuição do dado em RCL_OPOSTO
							//-Carrega a linha no objeto/array
							oTString:SetString(cQry)
							cQry := ""
						EndIf
					Else
						Exit
					EndIf	
				Next nSol
			EndIf
			
			cMyChav := RH3_FILIAL+RH3_CODIGO+RCL_FILIAL+RCL_DEPTO+RCL_POSTO
		EndIf

		If !( cMy2Chav == RCL_FILIAL+RCL_DEPTO+RCL_POSTO+DTOS(RCX_DTINI)+RCX_FILIAL+RCX_MATFUN )
				cIgnCpos := "RH3_DTSOLI;RH3_CODIGO;P10_COD;RH3_XTPCTM;PA7_DESCR;RH3_FILINI;RH3_MATINI;NOMESOLIC;RH3_STATUS;RALL.POSTO;RALL.FILIAL"
				cIgnCpos += ";POSTOSOL;RCL_SALAR;RCL_BENEF;RCL_ENCARG;RH3_FILIAL;RCX_FILOCU;RCX_CODOCU;RCX_POSTO;RESERVADOS"	//-Excluidos conf.nova solicitação
				For nAux := 2 To Len(aStru)
					If !( aStru[nAux][1] $ cIgnCpos )
						If aStru[nAux][2] == "N"
							cQry += StrTran(AllTrim(Str((&(aStru[nAux][1])),TamSx3(aStru[nAux][1])[1],TamSx3(aStru[nAux][1])[2])),".",",") + ";"
						ElseIf aStru[nAux][2] == "D"
							cQry += DTOC(&(aStru[nAux][1])) + ";"
						Else
							cQry += AllTrim("'"+(&(aStru[nAux][1]))) + ";"
						EndIf
					EndIf
					
					//-Busca o Reservado e Disponivel do Posto
					If aStru[nAux][1] == "RCL_OPOSTO"
						//fVerReserv(oReport,cAliasQry) - Andre Carralero - 12041776
						LINRESERV := (cAliasQry)->RESERVADOS
	                    LINDISPON := ((cAliasQry)->RCL_NPOSTO - (cAliasQry)->RCL_OPOSTO - LINRESERV)

						cQry += Str(LINRESERV,3,0)+";"	//-Reservado
						cQry += Str(LINDISPON,3,0)+";"	//-Disponivel
					EndIf
				Next nAux
				cQry += cEOL
				
				//If cOcup <> "0" // ticket n° 8848019 -- Validação se há movimentação de abertura de vaga com ocupantes para não gerar linha dupliicada caso contrário
				//chamado 12041776
				//Marcelo Amaral Totvs
				If (cAliasQry)->RCL_OPOSTO != 0 .or. ("1" $ cStatus .and. (cAliasQry)->RCL_OPOSTO = 0)
					oTString:SetString(cQry)
				Endif 

				//-Carrega a linha no objeto/array
				//oTString:SetString(cQry)
				cQry := ""
		EndIf
		
		cMy2Chav := RCL_FILIAL+RCL_DEPTO+RCL_POSTO+DTOS(RCX_DTINI)+RCX_FILIAL+RCX_MATFUN
		
		dbSkip()
	EndDo
	
	// Para gerar o arquivo no caminho e no nome de arquivo indicado no atributo cPath
	oTString:Str2File() 
	
	//Início - Thais Paiva - 8975363
	If oReport:nDevice == 4 
		CpyS2T("\SYSTEM\"+cArq, cPath) 
	EndIf
	//Fim - Thais Paiva - 8975363
	
	Aviso('Relatório de Postos',"Gerado o arquivo: " + oTString:cArq, {'OK'}, 1)
	
	//-Chama o Excel e abre o arquivo gerado
	oExcelApp:WorkBooks:Open(oTString:cPath + oTString:cArq)
	oExcelApp:SetVisible(.T.)
	/*?
	oExcelApp:Activate()
	oExcelApp:GetXMLFile(oTString:cPath + oTString:cArq)
	oExcelApp:DeActivate()
	?*/
Return
