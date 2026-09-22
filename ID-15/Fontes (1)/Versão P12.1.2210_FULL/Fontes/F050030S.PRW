#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH"
 

Static lTransf	:= .T.
Static lOutros	:= .T.
Static lTurno 	:= .T.
Static aCpos	   := {}
Static cFilNova	:= cFilAnt

/*{Protheus.doc} F050030S
Efetua a atualização quando solicitação aprovada
@type User Function

@version P12.1.7
@Project MAN0000007423039_EF_003
@return ${lVlDt}, ${.T. efetivado com sucesso  .F. não efetivado}
@param oModel, objeto, Modelo de Dados
*/
User Function F050030S(oModel)
	
	Local cFilSol	:= oModel:GetModel("RH3MASTER"):GetValue("RH3_FILIAL")
	Local cNumSol	:= oModel:GetModel("RH3MASTER"):GetValue("RH3_CODIGO")
	Local dDtaSol	:= oModel:GetModel("RH3MASTER"):GetValue("RH3_DTSOLI")
	Local cMatFun	:= oModel:GetModel("RH3MASTER"):GetValue("RH3_MAT")
	Local cVisaoA	:= oModel:GetModel("RH3MASTER"):GetValue("RH3_VISAO")
	Local cMatFap
	Local cTipoAtu	:= ''
	Local lVlDt		:= .T.
	Local cBlqSlTF	:= ''
	Local lExeTrans := .F.
	
	Private oGauge2
	Private cConDept	:= .F.
	Private cConProc	:= .F.
	Private cConPosto	:= .F.
	Private lGpea180Flt := .F.					//Verifica se havera filtro de Browse para o GPEA180

	dbSelectArea("RH4")
	RH4->(dbSetORder(1))
	aCpos := {}
	If RH4->(dbSeek(cFilSol+cNumSol))
		
		While cFilSol+cNumSol == RH4->(RH4_FILIAL+RH4_CODIGO)
			
			aAdd(aCpos,{RH4->RH4_CAMPO, RH4->RH4_VALNOV})

			RH4->(dbSkip())
		EndDo
		
		//Validar data da aprovação
		If  lVlDt	:= (VlDtAprov(lVlDt,dDtaSol) .AND. VldTransf( aCpos ) .AND. Valposto())
				
			lExeTrans := lTransf .AND. (lVlDt	:= MsgNoYes( "Confirma a Transferência?" + CRLF + CRLF + "ATENÇÃO: Após a confirmação NÃO SERÁ POSSÍVEL DESFAZER ESSA OPERAÇÃO!" ))
			
			Begin Transaction
			
				If lExeTrans
					FWMsgRun(,{|| lVlDt		:= AtTransf(oModel,aCpos,cFilSol,cMatFun) },"Processando...","Atualizando para a transferência. Aguarde!" )
				EndIf
					
				If lVlDt .AND. lOutros
					
					cFilSra := Alltrim(IIF((var := ASCAN(aCpos,{|x,y|  Alltrim(x[1]) == "TMP_FILVAG"})) = 0,'',aCpos[var][2]))
					cMatSra := Alltrim(IIF((var := ASCAN(aCpos,{|x,y|  Alltrim(x[1]) == "TMP_MATCOL"})) = 0,'',aCpos[var][2]))
					
					If aCpos <> Nil .AND. len(aCpos) > 0
						FWMsgRun(,{|| lVlDt	:= ATTurHor(aCpos,cFilSra,cMatSra,dDtaSol,aCpos) },"Processando...","Atualizando Carga Horária/Turno de trabalho. Aguarde!" )
					EndIf
						
					If lVlDt .AND. aCpos <> Nil .AND. len(aCpos) > 0
						FWMsgRun(,{|| lVlDt	:= AtCargo(aCpos,cFilSra,cMatSra,dDtaSol) },"Processando...","Atualizando Cargo. Aguarde!" )
					EndIf
						
					If lVlDt .AND. aCpos <> Nil .AND. len(aCpos) > 0 .AND. lTransf .AND. Alltrim(GetMV('FS_BLQSLTF')) == 'N'
						If lVlDt .AND. aCpos <> Nil .AND. len(aCpos) > 0
							FWMsgRun(,{|| lVlDt	:= AtSalari(aCpos,cFilSra,cMatSra,dDtaSol) },"Processando...","Atualizando Salário. Aguarde!" )
						EndIf
					EndIf
				EndIf
				//-Atualiza a vaga
				If lVlDt 
				    AtuVaga(aCpos)
				Endif
				
			End Transaction
		EndIf
	EndIf
	
	If lVlDt

		Aviso('SUCESSO - EFETIVAÇÃO',"A solicitação foi efetuada com sucesso. ",{'OK'},1)
		
		//Requisito N005 -  Indicadores: -067-Efetivada
		U_F0500201(cFilSol,cNumSol,'006')
	Else
		
		Aviso('NÃO EFETIVADA - EFETIVAÇÃO',"A solicitação não foi efetuada. ",{'OK'},1)
		//Monta e-mail para chamar rotina de envio e-mail para todos
	EndIf
	
	lTransf		:= .T.
	lOutros		:= .T.
	aCpos		:= {Nil,Nil,Nil,Nil,Nil}
	cFilNova	:= cFilAnt
Return lVlDt

/*{Protheus.doc} AtuVaga
*/
Static Function AtuVaga(aCpos)
	Local aAreaSQS	:=	SQS->(GetArea())
	Local nPosFilVg := ""
	Local nPosCodVg := ""
	Default aCpos := {}
	
	nPosFilVg := ASCAN(aCpos,{|x,y|  Alltrim(x[1]) == "TMP_FILVAG"})
	nPosCodVg := ASCAN(aCpos,{|x,y|  Alltrim(x[1]) == "PA2_CDVAGA"})
	
	SQS->(DbSetOrder(1))
	If !Empty(AllTrim(aCpos[nPosFilVg][2]) + AllTrim(aCpos[nPosCodVg][2])) .And. SQS->(DbSeek(AllTrim(aCpos[nPosFilVg][2]) + AllTrim(aCpos[nPosCodVg][2])))
		RecLock("SQS",.F.)
		SQS->QS_VAGAFEC += 1 
		SQS->QS_DTFECH  := Iif(Empty(SQS->QS_DTFECH) .And. SQS->(QS_NRVAGA = QS_VAGAFEC), dDataBase, ctod("//"))
		SQS->(MsUnLock())
	EndIf
	RestArea(aAreaSQS)
Return

/*{Protheus.doc} VlDtAprov
Valida a Data de aprovação da solicitação
@type function
@author Cris
@since 09/11/2016
@version 1.0
@param dDtaSol, data, (Descrição do parâmetro)
@version P12.1.7
@Project MAN0000007423039_EF_004
@return ${return}, ${não há}
*/
Static Function VlDtAprov(lVlDt,dDtaSol)
	
	Local lContin	:= .F.
	Local cDiaSol	:= Day(dDtaSol)
	Local cMesSol	:= Month(dDtaSol)
	Local cDiaAtu	:= Day(dDataBase)
	Local cMesAtu	:= Month(dDataBase)
	Local dDtTur	:= Ctod('16/'+Strzero(Month(dDataBase),2)+"/"+Str(Year(dDataBase)))
	Local dDataAtu	:= MSDATE()
	Local dMesBase
	 
	/*
	REGRA:
	Solicitações abertas até dia 20 do mês corrente, tem como base o mês corrente+1 e caso seja posterior será o mês+2
	Exemplo: 
	Data Solicitação 20/03/2017 -> Alteração salarial com início em 01/04/2017
	Data Solicitação 21/03/2017 -> Alteração salarial com início em 01/05/2017
	
	If DAY(dDtAtu) <= 20
		cAnoMes1 := SomaMesAno( dDtAtu )
	Else
		cAnoMes1 := SomaMesAno( dDtAtu )
		cAnoMes1 := SomaMesAno( cAnoMes1 )
	EndIf
	*/
		
	If cDiaSol <= 20
		dMesBase := SomaMesAno( dDtaSol )
	Else
		dMesBase := SomaMesAno( dDtaSol )
		dMesBase := SomaMesAno( dMesBase )
	EndIf

	If cDiaSol <= 20
		
		If ( MesAno(dDataAtu) >= dMesBase )
			lContin	:= .T.
		Else
			Help("",1, "Help", "Validação de Data de Aprovação(F050030S_04)", "Mês base menor que mês da data da solicitação. Efetivação não será realizada!" , 3, 0)
			lVlDt	:= .F.
		EndIf
		
	ElseIf ( MesAno(dDataAtu) >= dMesBase )
		lContin	:= .T.
	Else
		Help("",1, "Help", "Validação de Data de Aprovação(F050030S_05)", "Dia/Mês não permitido para efetivação para este tipo de solicitação aprovada!" , 3, 0)
		lVlDt	:= .F.
	EndIf
	
	If lContin		
		//Caso exista Troca de Turno
		If lTurno .AND. !lOutros .AND. ( MesAno(dDataAtu) < dMesBase )	//?cDiaAtu <> Day(dDtTur)
			
			Help("",1, "Help", "Validação de Data de Aprovação(F050030S_03)", "A efetivação para a Troca de Turno somente poderá ocorrer dia 16 ou o 1 dia mês posterior a data da solicitação!" , 3, 0)
			lVlDt	:= .F.
			
		Elseif !lTurno .AND. lOutros .AND. ( MesAno(dDataAtu) < dMesBase )	//?cDiaAtu <> Day(dDtTur)
			
			Help("",1, "Help", "Validação de Data de Aprovação(F050030S_02)", "As efetivações para este tipo de solicitação devem ser executadas a partir do dia 01 do mês posterior a data da solicitação!" , 3, 0)
			lVlDt	:= .F.
		EndIf
	EndIf
	
Return lVlDt

/*{Protheus.doc} AtSalari
Realiza a atualização salarial
@type function
@author Cris
@since 04/11/2016
@version P12.1.7
@Project MAN0000007423039_EF_004
@return lAtuSal, Se efetuou a atualização salarial
*/
Static Function AtSalari(aCpos,cFilFun,cMatFun,dDtaSol)
	
	Local aAreaSRA	:= SRA->(GetArea())
	Local nSalAnt	:= 0
	Local lAtuSal	:= .F.
	Local cTabNov	:= ""
	Local cTabNiv	:= ""
	Local cTabFxa	:= ""
	Local aFaixa	:= {}
	Local nX		:= 0
	Local nSalTran	:= 0 	
	Local nPosPrc	:= 0
	
	nSalAnt	:= SRA->RA_SALARIO
	
	SRA->(dbSetOrder(1))
	If SRA->(dbSeek(cFilFun+cMatFun))
	
		RCA->(dbSetOrder(1))
		If RCA->(dbSeek(FwxFilial("RCA")+"M_PERCTOL"))
			nPerTol	:= Val(RCA->RCA_CONTEU)
		EndIf
		
		nPosPrc := ASCAN(aCpos,{|x,y|  Alltrim(x[1]) == "PA2_SLFECH"})
		If nPosPrc > 0
			nSalTran	:= Val(StrTran((aCpos[nPosPrc][02]),",","."))//Val(StrTran(StrTran(Alltrim(aCpos[1][2]),".",""),",","."))
		Else
			nSalTran	:= SRA->RA_SALARIO
		EndIf
		SQ3->(DbSetOrder(1))
		If SQ3->(DbSeek(FwxFilial("SQ3")+SRA->RA_CODFUNC))
			aFaixa := BscFxSal(SRA->RA_CODFUNC, cFilFun, ,,SRA->RA_HRSMES)	
			If Len(aFaixa) >= 3
				If nSalTran <= aFaixa[1][3]+(aFaixa[1][3]*(nPerTol/100))
					cTabFxa := '01'
				ElseIf nSalTran > aFaixa[1][3]+(aFaixa[1][3]*(nPerTol/100)) .And. nSalTran <= aFaixa[2][3]+(aFaixa[2][3]*(nPerTol/100))
					cTabFxa := '02'
				Else
					cTabFxa := '03'
				EndIf
				cTabNov := SQ3->Q3_TABELA
				cTabNiv := SQ3->Q3_TABNIVE
			Else
				cTabNov := SQ3->Q3_TABELA
				cTabNiv := SQ3->Q3_TABNIVE
				cTabFxa	:= SRA->RA_TABFAIX
			EndIf
		Else
			cTabNov := SRA->RA_TABELA
			cTabNiv := SRA->RA_TABNIVE
			cTabFxa	:= SRA->RA_TABFAIX
		EndIf	
			
		SRA->(RecLock("SRA",.F.))
		// ticket n° 5784362 - 415966 - Paulo Dias - Ajuste nos campos salário e histórico salarial para gravar o valor na máscara correta, pegando da FAP
		//SRA->RA_SALARIO	:=  Val(StrTran(StrTran(IIF((var := ASCAN(aCpos,{|x,y|  Alltrim(x[1]) == "PA2_SLFECH"})) = 0,'',aCpos[var][2]),".",""),",","."))
		SRA->RA_SALARIO	:=  Val(IIF((var := ASCAN(aCpos,{|x,y|  Alltrim(x[1]) == "PA2_SLFECH"})) = 0,'',aCpos[var][2]))
		//SRA->RA_ANTEAUM	:=  Val(StrTran(StrTran(IIF((var := ASCAN(aCpos,{|x,y|  Alltrim(x[1]) == "PA2_SLFECH"})) = 0,'',aCpos[var][2]),".",""),",","."))//Conforme EF mantendo os dois iguais, para manter a integridade do calculo de Dissidio Retroativo.
		SRA->RA_ANTEAUM	:=  Val(IIF((var := ASCAN(aCpos,{|x,y|  Alltrim(x[1]) == "PA2_SLFECH"})) = 0,'',aCpos[var][2]))
		SRA->RA_TABELA 	:= cTabNov
		SRA->RA_TABNIVE := cTabNiv 
		SRA->RA_TABFAIX := cTabFxa		
		
		SRA->(MsUnlock())
		
		If SRA->RA_SALARIO == nSalAnt
			Help("",1, "Help", "Atualização Salarial(AtSalari_01)", "Não foi possível efetuar a atualização salarial. Efetue manualmente!" , 3, 0)
			//lAtuSal	:= .F.
		Else
			GrvSR3R7(aCpos,cFilFun,cMatFun,dDtaSol)
			//lAtuSal	:= .T.
		EndIf
		lAtuSal	:= .T. //ticket n° 7564864 - 415966 - Paulo Dias - o processo da FAP continua mesmo se o salário não sofrer alteração
	EndIf
	
	RestArea(aAreaSRA)
	
Return lAtuSal

/*{Protheus.doc} AtCargo
(long_description)
@type function
@author Cris
@since 04/11/2016
@version P12.1.7
@Project MAN0000007423039_EF_004
@return ${return}, ${não há}
*/
Static Function AtCargo(aCpos,cFilFun,cMatFun,dDtaSol)
	
	Local aAreaSRA	:= SRA->(GetArea())
	Local lAltCarg	:= .F.
	
	Local dDtAtu	:= Iif(dDtaSol <> NIL, dDtaSol, MsDate())	//?MsDate()
	Local cAnoMes1	:= ""

	If DAY(dDtAtu) <= 20
		cAnoMes1 := SomaMesAno( dDtAtu )
	Else
		cAnoMes1 := SomaMesAno( dDtAtu )
		cAnoMes1 := SomaMesAno( cAnoMes1 )
	EndIf
	
	dDtAtu := STOD( Alltrim(cAnoMes1) + "01" )
	
	dbSelectArea("SRA")
	SRA->(dbSetOrder(1))
	If SRA->(dbSeek(cFilFun+cMatFun))
		cInfSra := IIF((var := ASCAN(aCpos,{|x,y|  Alltrim(x[1]) == "TMP_CARGOV"})) = 0,'',aCpos[var][2])
		SRA->(RecLock("SRA",.F.))
		SRA->RA_CARGO	:= Alltrim(cInfSra)
		SRA->RA_CODFUNC	:= Alltrim(cInfSra)
		TN0->(DbSetOrder(5))
		If TN0->(DbSeek(SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_CODFUNC)) .Or. TN0->(DbSeek(SRA->RA_FILIAL+ "*          " + SRA->RA_CODFUNC))
			MDT180INT( SRA->RA_MAT, TN0->TN0_NUMRIS, .F., 4, SRA->RA_FILIAL )
		Else
			MDT180INT( SRA->RA_MAT, "", .T., 4, SRA->RA_FILIAL )		
		EndIf
		//-Atualiza se necessario as horas de Periculosidade e/ou Insalubridade
		If SRA->RA_HRSMES > 0
			If !( SRA->RA_HRSMES == SRA->RA_PERICUL ) .And. SRA->RA_ADCPERI == '2'
				SRA->RA_PERICUL := SRA->RA_HRSMES
			EndIf
			If !( SRA->RA_HRSMES == SRA->RA_INSMAX ) .And. SRA->RA_ADCINS == '2'
				SRA->RA_INSMAX := SRA->RA_HRSMES
			EndIf
		EndIf
		SRA->(MsUnlock())
		dDtOper := date()
	    cHrOper := time()		
		//Certifico que atualizou o cargo
		If (lAltCarg := (Alltrim(cInfSra) == SRA->RA_CARGO .AND. Alltrim(cInfSra) == SRA->RA_CODFUNC ))
			//Quando existir em única solicitação a alteração de Cargo com Salário,único log nas tabelas SR3 e SR7 deverá ser gerado,
			//portanto grava-se o cargo e  depois o salário.
			If aCpos == Nil
				
				//Tabelas de históricos de alteração salarial e cargo
				GrvSR3R7(aCpos,cFilFun,cMatFun,dDtaSol)
				
				//tabelas de histórico de alteração de campo
				GrvSR9a(cFilFun,cMatFun,dDtAtu/*Msdate()*/,'RA_CARGO',Alltrim(cInfSra),dDtOper,cHrOper)
			EndIf
			
			lAltCarg	:= .T.
		EndIf
	Else
		Help("",1, "Help", "INSUCESSO - Cargo(AtCargo_01)", "Não foi localizado o funcionário "+cMatFun+" na filial de destino "+cFilFun+". Os campos cargo/função não foram atualizados!" , 3, 0)
		lAltCarg	:= .F.
	EndIf
	
	RestArea(aAreaSRA)
	
Return lAltCarg

/*{Protheus.doc} GrvSR3R7
Gravação dos Historicos de Valores e Alterações Salariais
@author Cris
@since 09/11/2016
@version P12.1.7
@Project MAN0000007423039_EF_004
*/
Static Function GrvSR3R7(aCpos,cFilFun,cMatFun,dDtaSol)
	
	Local cAnoMes1	:= ""
	Local cSeq		:= ""
	Local cTpAumen	:= ""
	Local dDtAtu	:= Iif(dDtaSol <> NIL, dDtaSol, MsDate())	//?MsDate()
	Local nPosTpA	:= aScan( aCpos, {|x|, Alltrim(x[01]) == "PA2_TPALTS" })
	
	/*
	REGRA:
	Solicitações abertas até dia 20 do mês corrente, tem como base o mês corrente+1 e caso seja posterior será o mês+2
	Exemplo: 
	Data Solicitação 20/03/2017 -> Alteração salarial com início em 01/04/2017
	Data Solicitação 21/03/2017 -> Alteração salarial com início em 01/05/2017
	*/
	If DAY(dDtAtu) <= 20
		cAnoMes1 := SomaMesAno( dDtAtu )
	Else
		cAnoMes1 := SomaMesAno( dDtAtu )
		cAnoMes1 := SomaMesAno( cAnoMes1 )
	EndIf
	
	If nPosTpA > 0
		cTpAumen := Alltrim(aCpos[nPosTpA][2])
	EndIf
	
	dDtAtu := STOD( Alltrim(cAnoMes1) + "01" )
	
	dbSelectArea("SR3")
	SR3->(dbSetOrder(1))
	If SR3->(dbSeek(cFilFun+cMatFun+Dtos(dDtAtu)+Alltrim(aCpos[2][2])))
		
		While cFilFun+cMatFun+Dtos(dDtAtu) == SR3->(R3_FILIAL+R3_MAT+Dtos(R3_DATA))
			
			cSeq	:= SR3->R3_SEQ
			
			SR3->(dbSkip())
		EndDo
		
	EndIf
	
	SR3->(RecLock("SR3",.T.))
	SR3->R3_FILIAL  := cFilFun
	SR3->R3_MAT     := cMatFun
	SR3->R3_DATA    := dDtAtu
	SR3->R3_SEQ		:= StrZero(Val(cSeq)+1,1)
	SR3->R3_PD      := "000"
	SR3->R3_DESCPD  := "SALARIO BASE"
	SR3->R3_VALOR   := SRA->RA_SALARIO
	SR3->R3_TIPO    := cTpAumen
	SR3->R3_ANTEAUM	:= SRA->RA_SALARIO
	SR3->(MsUnLock())
	
	If IsInCallStack("AtSalari")
	    // 416094 - Rogerio Carvalho - AMS Rio - 01/07/2018 - DOR04520620		
		//Chama rotina de integração quando alteração salarial
		//U_F0600901("F0600301",; // cFunc
		//SR3->(RECNO()),; // nRecno
		//"SR3",; // cAliasTrb
		//SR3->R3_FILIAL + SR3->R3_MAT + DTOS(SR3->R3_DATA) + SR3->R3_TIPO,; // cChave
		//"",; // cObs
		//CTOD(""),; // Data de envio
		//"UPSERT") // Operacao
	EndIf
	
	dbSelectArea("SR7")
	SR7->(dbSetOrder(1))
	If SR7->(dbSeek(cFilFun+cMatFun+Dtos(dDtAtu)))
		
		While cFilFun+cMatFun+Dtos(dDtAtu) ==  SR7->(R7_FILIAL+R7_MAT+Dtos(R7_DATA))
			
			cSeq	:= SR7->R7_SEQ
			
			SR7->(dbSkip())
		EndDo
		
	EndIf
	
	dbSelectArea("SR7")
	If SR7->(RecLock("SR7",.T.))
		SR7->R7_FILIAL   := cFilFun
		SR7->R7_MAT      := cMatFun
		SR7->R7_DATA     := dDtAtu	//?MsDate()
		SR7->R7_TIPO     := cTpAumen//Alltrim(aCpos[2][2])
		SR7->R7_FUNCAO   := SRA->RA_CODFUNC
		SR7->R7_DESCFUN  := POSICIONE("SRJ",1,xFilial("SRJ")+SRA->RA_CODFUNC,"RJ_DESC")
		SR7->R7_TIPOPGT  := SRA->RA_TIPOPGT
		SR7->R7_CATFUNC  := SRA->RA_CATFUNC
		SR7->R7_USUARIO  := Alltrim(cUsername)+'|'+Alltrim(LogUserName())
		If SR7->( Type("R7_CARGO") ) # "U"
			SR7->R7_CARGO   := SRA->RA_CARGO
		EndIf
		If SR7->( Type("R7_DESCCAR") ) # "U"
			SR7->R7_DESCCAR	:= POSICIONE("SQ3",1,xFilial("SQ3")+SRA->RA_CARGO,"Q3_DESCSUM")
		EndIf
		SR7->R7_SEQ		:= StrZero(Val(cSeq)+1,1)
		
		SR7->( MsUnLock() )
	EndIf

	//U_F0600901("F0600301",; // cFunc 
	//			SR7->(RECNO()),; // nRecno 
	//			"SR7",; // cAliasTrb 
	//			SR7->R7_FILIAL + SR7->R7_MAT + DTOS(SR7->R7_DATA) + SR7->R7_TIPO,; // cChave 
	//			"",; // cObs
	//			CTOD(""),; // Data de envio
	//			"UPSERT") // Operacao
					
Return

/*{Protheus.doc} ATTurHor
Grava a Transferencia de Turno e o Historico dos dados do funcionário
@author Cris
@since 04/11/2016
@version P12.1.7
@Project MAN0000007423039_EF_004
@return ${return}, ${não há}
*/
Static Function ATTurHor(aCpos,cFilFun,cMatFun,dDtaSol,aCpCarg)
	
	Local aAreaSRA	:= SRA->(GetArea())
	Local aAreaSPF	:= {}
	Local cTurnAnt	:= ''
	Local cTSeqAnt	:= ''
	Local cRegrAnt	:= ''
	Local iCpoSRA	:= 0
	Local iCpoCg    := 0
	Local lAtuTurn	:= .T.
	Local nPosCpo	:= 0
	Local dDtAtu	:= Iif(dDtaSol <> NIL, dDtaSol, MsDate())
	Local cAnoMes1	:= ""
	Local cDescTur  := ""
	Local nPosHr    := 0
	Local nPosTrn   := 0
	Local nPosTrn2  := 0
	
	Default aCpos   := {}
	Default cFilFun := ""
	Default cMatFun := ""
	Default dDtaSol := CTOD("//")
	Default aCpCarg := {}
	
	/*
	REGRA:
	Solicitações abertas até dia 20 do mês corrente, tem como base o mês corrente+1 e caso seja posterior será o mês+2
	Exemplo: 
	Data Solicitação 20/03/2017 -> Alteração salarial com início em 01/04/2017
	Data Solicitação 21/03/2017 -> Alteração salarial com início em 01/05/2017
	*/
	If DAY(dDtAtu) <= 20
		cAnoMes1 := SomaMesAno( dDtAtu )
		dDtTur := STOD( Alltrim(cAnoMes1) + "16" )
	Else
		cAnoMes1 := SomaMesAno( dDtAtu )
		dDtTur := STOD( Alltrim(cAnoMes1) + "16" )
		cAnoMes1 := SomaMesAno( cAnoMes1 )
	EndIf
	
	dDtAtu := STOD( Alltrim(cAnoMes1) + "01" )
		
	//Garanto que realmente esta posicionado no funcionario relacionado a solicitação
	dbSelectArea("SRA")
	SRA->(dbSetOrder(1))
	If SRA->(dbSeek(cFilFun+cMatFun))
		
		cTurnAnt := SRA->RA_TNOTRAB
		cTSeqAnt := SRA->RA_SEQTURN
		cRegrAnt := SRA->RA_REGRA

		nPosHr	:= Ascan(aCpCarg,{|x,y| Alltrim(x[1]) == 'TMP_JORNVG'})		
		nPosTrn := aScan( aCpos, {|x|, Alltrim(x[01]) == "TMP_TURVAG" })
		nPosTrn2 := aScan( aCpos, {|x|, Alltrim(x[01]) == "RA_TNOTRAB" })
		
		SRA->(RecLock("SRA",.F.))
		For iCpoSRA	:= 1 to len(aCpos)
			
			if Posicione("SX3", 2, Alltrim(aCpos[iCpoSRA][1]), "X3_TIPO") == "N"
				&(aCpos[iCpoSRA][1])	:= Val(aCpos[iCpoSRA][2])
			Else
				&(aCpos[iCpoSRA][1])	:= aCpos[iCpoSRA][2]
			EndIf
			
		Next	
		
		For iCpoCg := 1 to len(aCpCarg)
			
			if Posicione("SX3", 2, Alltrim(aCpCarg[iCpoCg][1]), "X3_TIPO") == "N"
				&(aCpCarg[iCpoCg][1])	:= Val(aCpCarg[iCpoCg][2])
			Else
				&(aCpCarg[iCpoCg][1])	:= aCpCarg[iCpoCg][2]
			EndIf
			
		Next		
		If nPosHr > 0
			SRA->RA_HRSMES	:= Val(Alltrim(aCpCarg[nPosHr][2]))
			SRA->RA_HRSEMAN	:= (SRA->RA_HRSMES/5) //Val(Alltrim(aCpCarg[nPosHr][2]))
			SRA->RA_HRSDIA	:= (SRA->RA_HRSMES/30) //Val(Alltrim(aCpCarg[nPosHr][2]))			
		EndIF
		If !( SRA->RA_ADCINS$"1| ")
			SRA->RA_INSMAX := SRA->RA_HRSMES
		Endif
		
		If nPosTrn > 0 
			SRA->RA_TNOTRAB :=Alltrim(aCpCarg[nPosTrn ][2])
		EndIf

		// ID 1499
		If nPosTrn2 > 0 
			SRA->RA_TNOTRAB :=Alltrim(aCpCarg[nPosTrn2 ][2])
		EndIf

		
		SRA->(MsUnlock())

		aAreaSPF	:= SPF->(GetArea())
		
		dbSelectArea("SPF")//PONA160.PRW
		SPF->(dbSetOrder(1))
		If SPF->( RecLock( "SPF" , !SPF->(dbSeek(cFilFun+cMatFun) ) ))
			dDtOper := date()
			cHrOper := time()			
			SPF->PF_FILIAL	:= cFilFun
			SPF->PF_MAT		:= cMatFun
			SPF->PF_DATA	:= dDtTur
			SPF->PF_TURNODE	:= cTurnAnt
			SPF->PF_SEQUEDE := cTSeqAnt
			SPF->PF_REGRADE := cRegrAnt
			SPF->PF_TURNOPA	:= iif((nPosCpo := Ascan(aCpos,{|x,y| Alltrim(x[1]) == "TMP_TURVAG"})) > 0, Alltrim(aCpos[nPosCpo][2]),cTurnAnt)
			SPF->PF_SEQUEPA := cTSeqAnt//iif((nPosCpo := Ascan(aCpos,{|x,y| Alltrim(x[1]) == "RA_SEQTURN"})) > 0, Alltrim(aCpos[nPosCpo][2]),cTSeqAnt)
			SPF->PF_REGRAPA := cRegrAnt//iif((nPosCpo := Ascan(aCpos,{|x,y| Alltrim(x[1]) == "RA_REGRA"})) > 0, Alltrim(aCpos[nPosCpo][2]),cRegrAnt)
			SPF->PF_XDTOPER 	:= dDtOper
			SPF->PF_XHROPER 	:= cHrOper
			SPF->PF_XINTINC   := " "
			SPF->PF_XIDINC    := "                                "
			
			SPF->(MsUnLock())

		EndIf
        
        // 416094 - Rogerio Carvalho - AMS Rio - 01/07/2018 - DOR04520620
		//U_F0600901("F0600301",; // cFunc 
		//			SPF->(RECNO()),; // nRecno 
		//			"SPF",; // cAliasTrb 
		//			SPF->PF_FILIAL + SPF->PF_MAT + DTOS(SPF->PF_DATA),; // cChave 
		//			"",; // cObs
		//			CTOD(""),; // Data de envio
		//			"UPSERT") // Operacao

		
		RestArea(aAreaSPF)
		
		nPosTrn := aScan( aCpos, {|x|, Alltrim(x[01]) == "TMP_TURVAG" })//IIF((var := ASCAN(aCpos,{|x,y|  Alltrim(x[1]) == "PA2_TURNO"})) = 0,0,VAL(aCpos[var][2]))
		If nPosTrn > 0
			cDescTur := Posicione("SR6",1,xFilial("SR6")+ Alltrim(aCpos[nPosTrn][2]),"R6_DESC")
			GrvSR9a(cFilFun,cMatFun,dDtTur,'RA_TNOTRAB',cDescTur,dDtOper,cHrOper)
		EndIf
		
		nPosHr := Ascan(aCpCarg,{|x,y| Alltrim(x[1]) == 'TMP_JORNVG'})
		If nPosHr > 0 
			GrvSR9a(cFilFun,cMatFun,dDtAtu,'RA_HRSMES',Alltrim(aCpCarg[nPosHr][2]),dDtOper,cHrOper)
		EndIf

	EndIf
	
	RestArea(aAreaSRA)
	
Return lAtuTurn

/*{Protheus.doc} GrvSR9a
Grava Historico Dados Funcionarios
@author Cris
@since 24/11/2016
@version 1.0
@param cFilFun, character, Filial do funcionário
@param cMatFun, character, Matricula do Funcionário
@param dDtReal, data, Data real da alteração
@param cCpoAlt, character, Campo alterado
@param cCntAlt, character, novo valor do campo alterado
*/
Static Function GrvSR9a(cFilFun,cMatFun,dDtReal,cCpoAlt,cCntAlt,dDtOpSR9,cHrOpSR9)
	
	Local aAreaAtu	:= SR9->(GetArea())
	
	dbSelectArea("SR9")
	If SR9->(Reclock('SR9',.T.))
		SR9->R9_FILIAL := cFilFun
		SR9->R9_MAT    := cMatFun
		SR9->R9_DATA   := dDtReal
		SR9->R9_CAMPO  := cCpoAlt
		SR9->R9_DESC   := cCntAlt
		SR9->R9_XDTOPER := dDtOpSR9 //
		SR9->R9_XHROPER := cHrOpSR9
		SR9->R9_XINTINC := " "
		SR9->R9_XIDINC  := "                                "
		
		SR9->(MsUnlock())
	EndIf
    // 416094 - Rogerio Carvalho - AMS Rio - 01/07/2018 - DOR04520620
	//U_F0600901("F0600301",; // cFunc 
	//			SR9->(RECNO()),; // nRecno 
	//			"SR9",; // cAliasTrb 
	//			SR9->R9_FILIAL + SR9->R9_MAT + SR9->R9_CAMPO + DTOS(SR9->R9_DATA),; // cChave 
	//			"",; // cObs
	//			CTOD(""),; // Data de envio
	//			"UPSERT") // Operacao
					
	RestArea(aAreaAtu)
	
Return

/*{Protheus.doc} VldTransf
Valida os cadastros da transferencia na filial destino
@author Roberto Souza
@since 18/11/2016
@version P12.1.7
@Project MAN0000007423039_EF_004
@return ${return}, ${não há}
*/
Static Function VldTransf( aCpos )

	Local lRet 	:= .T.
	Local nScan	:= 0
	Local nTamFil 	:= Len(cFilAnt)
	Local cMsgErro:= ""
	Local aAreaAtu	:= {}
	
	If lTransf
	
		nScan := aScan( aCpos, {|x|, Alltrim(x[01]) == "PA2_FILCAN" })
		If nScan > 0
	
			cFilP := Padr(aCpos[nScan][02],nTamFil)
			cFilNova	:= cFilP
	
			// Verifica se mudou Depto - SQB
			If !Empty(AllTrim(xFilial("SQB")))
				nScan := aScan( aCpos, {|x|, Alltrim(x[01]) == "PA2_DEPART" })
				If nScan > 0
					cDeptoP := Alltrim(aCpos[nScan][02])
					
					aAreaAtu	:= SQB->(GetArea())
					
					//Verifica se o depto existe na filial destino
					DbSelectArea("SQB")
					SQB->(DbSetOrder(1))
					If !SQB->(DbSeek(cFilP+cDeptoP))
						cMsgErro +="Depto: "+AllTrim(cDeptoP) +" nâo existe na filial de destino: "+cFilP	+"."+CRLF
					EndIf
					
					RestArea(aAreaAtu)
				EndIf
			EndIf
			
			// Verifica se mudou CC - CTT
			If !Empty(AllTrim(xFilial("CTT")))
				nScan := aScan( aCpos, {|x|, Alltrim(x[01]) == "PA2_CC" })
				If nScan > 0
					cCCP := aCpos[nScan][02]
					//Verifica se o CC existe na filial destino
					
					aAreaAtu	:= CTT->(GetArea())
					
					DbSelectArea("CTT")
					CTT->(DbSetOrder(1))
					If !CTT->(DbSeek(cFilP+cCCP))
						cMsgErro +="C. Custo: "+AllTrim(cCCP) +" nâo existe na filial de destino: "+cFilP	+"."+CRLF
					EndIf
					
					RestArea(aAreaAtu)
				EndIf
			EndIf
			
			// Verifica se mudou Processo - RCJ
//			If !Empty(AllTrim(xFilial("RCJ")))
//				nScan := aScan( aCpos, {|x|, Alltrim(x[01]) == "RA_PROCES" })
//				If nScan > 0
//					cProcP := aCpos[nScan][02]
//					//Verifica se o Processo existe na filial destino
//					
//					aAreaAtu	:= RCJ->(GetArea())
//					
//					DbSelectArea("RCJ")
//					RCJ->(DbSetOrder(1))
//					If !RCJ->(DbSeek(cFilP+cProcP))
//						cMsgErro +="Processo: "+AllTrim(cProcP) +" nâo existe na filial de destino: "+cFilP	+"."+CRLF
//					EndIf
//					
//					RestArea(aAreaAtu)
//				EndIf
//			EndIf
			
			
			// Verifica se mudou Função - SRJ
			If !Empty(AllTrim(xFilial("SRJ")))
				nScan := aScan( aCpos, {|x|, Alltrim(x[01]) == "PA2_CARGO" })
				If nScan > 0
					cFuncP := aCpos[nScan][02]
					//Verifica se a função existe na filial destino
					aAreaAtu	:= SRJ->(GetArea())
					
					DbSelectArea("SRJ")
					SRJ->(DbSetOrder(1))
					If !SRJ->(DbSeek(cFilP+cFuncP))
						cMsgErro +="Função: "+AllTrim(cFuncP) +" nâo existe na filial de destino: "+cFilP	+"."+CRLF
					EndIf
					
					RestArea(aAreaAtu)
				EndIf
			EndIf
			/*
			RA_TNOTRAB	 SR6
			RA_SEQTURN SPJ
			RA_REGRA SPA
			*/
			If !Empty(cMsgErro)
				Aviso("Atenção",cMsgErro,{"ok"},2)
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
Return( lRet )

/*{Protheus.doc} AtTransf
(long_description)
@type function
@author Cris
@since 04/11/2016
@version P12.1.7
@Project MAN0000007423039_EF_004
@return ${return}, ${não há}
*/
Static Function AtTransf( oModel, aCpos, cFilFun, cMatFun )
	
	Local lRet    := .F.
	Local nScan		:= 0
	Local nTamFil	:= Len(cFilAnt)
	Local nTamMat	:= TAMSX3("RA_MAT")[1]
	Private lLote	:= .F.
	
	nScan := aScan( aCpos, {|x|, Alltrim(x[01]) == "PA2_FILCAN" })
	
	If nScan > 0
		cFilFun := Padr(aCpos[nScan][02],nTamFil)
		nScan := aScan( aCpos, {|x|, Alltrim(x[01]) == "TMP_MATCOL" })
		If nScan > 0
			cMatFun := Padr(aCpos[nScan][02],nTamMat)
			DbSelectArea("SRA")
			SRA->(DbSetOrder(1))
			If SRA->(DbSeek(cFilFun+cMatFun))
				cProces	 := SRA->RA_PROCES
				cProcesDe:= SRA->RA_PROCES
				cDeptoDe := SRA->RA_DEPTO
				lRet := TCFA040Atende(oModel,"2")
			Else
				lRet := .F.
			EndIf
		Else
			Alert ("Não foi possível encontrar a matrícula do usuário solicitado.")
		EndIf
	Else
		Alert ("Não foi possível encontrar a matrícula do usuário solicitado.")
	EndIf
	
Return( lRet )

/*{Protheus.doc} TCFA040Atende
Efetua a chamada de transferencia conforme o portal.
Obs . Não alterar o nome da Static Funcion pois está amarrado a IsCallStack dentro do padrão
@author 		Roberto Souza
@since 			17/11/2016
@version 		P12.1.7
@Project 		MAN0000007423039_EF_004
@Param			oModel, objeto, Modelo de dados
@return 		${return}, ${não há}
*/
Static Function TCFA040Atende( oModel, cStatus )
	
	Local oModRH3           := oModel:GetModel("RH3MASTER") //oModel:GetModel("TCFA040_RH3")
	Local lRet              := .F.
	Local nI                := 0
	Local cFilSra           := "" 
	Local cMatSra           := ""
	Local aAreaRH3			:= RH3->(GetArea())
	Local aAreaPA2			:= PA2->(GetArea())
	Local cFilBkp			:= cFilAnt
	
	Private cCadastro       := ""
	Private cTipSolicPortal := ""
	Private cFilFun         := ""
	Private cMatFun         := ""
	Private dFerDtIni       := CToD("")
	Private dFerDtFim       := CToD("")
	Private nFerDuracao     := 0
	Private cCodSolic       := oModRH3:GetValue("RH3_CODIGO") // RH3->RH3_CODIGO
	Private aCPosPortal     := {}
	Private bParamPortal    := {|| .T.}
	Private lUseSPJ         := If(cPaisLoc == "BRA",.T., SuperGetMv("MV_USESPJ",NIL,"0")  == "1" )
	Private cRH3Cod         := ''
	
	//variaveis usadas (RH3_TIPO = '2') na alteraÃ§Ã£o cadastral eSocial.
	Private aCpoSRA         := {}
	Private lMsErroAuto     := .F.
	Private lMsHelpAuto     := .T.
	Private lAutoErrNoFile  := .T.
	
	//variaveis usadas no GPEA050
	Private lIncSRA         := .T.
	Private lInitDesc
	Private lHabAba         := .F. //Variavel para habilitar a aba de ProgramaÃ§Ã£o de fÃ©rias
	Private cOrgCfg         := SuperGetMv("MV_ORGCFG", NIL, "0" )	//-- Controlde de Postos : 0-nÃ£o usa Sigaorg;1-Tem controle de postos; 2- nÃ£o tem  controle de postos
	Private cGsPubl         := SuperGetMv("MV_GSPUBL",,"1")
	Private cContrMat       := SuperGetMv("MV_MATRICU", NIL, "0")
	Private lCtrAutoMat     := .F.					//Checa se o controle Automatico de Matricula esta ativado e se havera transferencia de matricula
	
	If cGsPubl == "2" .And. GetMv("MV_VDFLOGO",,"0") <> "0"
		cGsPubl := "3"
	EndIf
	
	// **************************** Transferencia
	Private cCodTrasfPortal 	:= oModRH3:GetValue("RH3_CODIGO") // RH3->RH3_CODIGO
	
	//-- Variaveis utilizadas pelo GPEA180
	Private cItemClVl       := SuperGetMv( "MV_ITMCLVL", .F., "2" )
	Private lItemClVl       := SuperGetMv( "MV_ITMCLVL", .F., "2" ) $ "13"
	Private aLogTransf      := {}
	Private aTransfCols     := {}
	Private aTransf1Cols    := {}
	
	Private aNewIndexSRA    := {}
	Private bNewFiltroBrw   := {|| NIL }
	Private cMarkTransf     := GetMark()
	Private cRaOkTransSpc   := Space( TamSx3( "RA_OKTRANS" )[1] )
	Private lAbortPrint     := .F.
	
	Private LGERADEM        := .T.
	
	Private cObsTcfa040		:= ""
	Private _CITEM
	Private _CCLVL
	Private aTpAlt			:= {.F.,.F.,.F.}
	Private cCPFDe			:= ""
	Private cCPFAte			:= ""

	Private dDataTAF	    := CTOD("//") // ticket n° 9257953  
	Private lRobo           := .F. // ticket n° 9257953
// Ticket No. 4494084 - 418497 - Don Junior - correção variable does not exist LTPDESL on FMONTAHEADER(GPEA180.PRX) 
	Private lIntTAF	:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 )
	Private lTpDesl	:= lIntTAF .And. X3USADO('RE_DESL')	
	cCadastro               := OemToAnsi( "TransferË†ncias" )  //"TransferË†ncias"
	cTipSolicPortal         := "4"
		
	RH4->(DbSeek(RH3->(RH3_FILIAL + RH3_CODIGO)))
	DbSelectArea( "SRA" )
	SRA->(DbSetOrder( RetOrder( "SRA", "RA_FILIAL + RA_MAT") ))
	
	cFilSra := Alltrim(IIF((var := ASCAN(aCpos,{|x,y|  Alltrim(x[1]) == "PA2_FILCAN"})) = 0,'',aCpos[var][2]))
	cMatSra := Alltrim(IIF((var := ASCAN(aCpos,{|x,y|  Alltrim(x[1]) == "TMP_MATCOL"})) = 0,'',aCpos[var][2]))
	
	If SRA->(DbSeek(cFilSra + cMatSra))
		
		BEGIN TRANSACTION
			
			RecLock("SRA",.F.)
			SRA->RA_OKTRANS := cMarkTransf
			SRA->(MsUnlock())
			
		END TRANSACTION
		// Inicializa as variaveis com o destino do funcionÃ¡rio
		M->RE_EMPP     := cEmpAnt
		M->RE_FILIALP  := ""
		M->RE_MATP     := ""
		M->RE_DEPTOP   := ""
		M->RE_PROCESP  := ""
		M->RE_CCP      := ""
		M->RA_DESCCC   := ""
		M->RE_POSTOP   := ""
		M->RE_ITEMP	   := SRA->RA_ITEM
		M->RE_CLVLP	   := SRA->RA_CLVL
		M->RE_PROCESP  := SRA->RA_PROCES

		PA2->(DbSetOrder(6))
		PA2->(DbSeek(xFilial("PA2")+RH3->RH3_CODIGO))
		While !RH4->(Eof()) .AND. RH4->(RH4_FILIAL + RH4_CODIGO) == RH3->(RH3_FILIAL + RH3_CODIGO)
			If AllTrim(RH4->RH4_CAMPO) == "RE_EMPP"
				M->RE_EMPP := Left(RH4->RH4_VALNOV, Len(SRE->RE_EMPP))
			ElseIf AllTrim(RH4->RH4_CAMPO) == "RE_FILIALP" .Or. AllTrim(RH4->RH4_CAMPO) == "TMP_FILVAG"
				M->RE_FILIALP := Left(RH4->RH4_VALNOV, Len(SRA->RA_FILIAL))
			ElseIf AllTrim(RH4->RH4_CAMPO) == "RE_MATP" .Or. AllTrim(RH4->RH4_CAMPO) == "TMP_MATCOL"
				M->RE_MATP := Left(RH4->RH4_VALNOV, Len(SRE->RE_MATP))
			ElseIf AllTrim(RH4->RH4_CAMPO) == "RE_DEPTOP" .Or. AllTrim(RH4->RH4_CAMPO) == "TMP_DPTVAG"
				M->RE_DEPTOP := Left(RH4->RH4_VALNOV, Len(SRE->RE_DEPTOP))
			ElseIf AllTrim(RH4->RH4_CAMPO) == "RE_CCP" .Or. AllTrim(RH4->RH4_CAMPO) == "TMP_CCVAGA"
				M->RE_CCP    := Left(RH4->RH4_VALNOV, Len(SRE->RE_CCP))
				M->RA_DESCCC := fDesc("CTT",Left(RH4->RH4_VALNOV, Len(SRA->RA_CC)),"CTT_DESC01",,)//SRA->RA_FILIAL))
			ElseIf AllTrim(RH4->RH4_CAMPO) == "RE_POSTOP" .Or. AllTrim(RH4->RH4_CAMPO) == "TMP_POSTO"
				M->RE_POSTOP := Left(RH4->RH4_VALNOV, Len(SRE->RE_POSTOP))
			EndIf
			RH4->(DbSkip())
		EndDo
		If !Empty(cFilSra) //RH3->(DbSeek("0113000100351"))
			cFilAnt := cFilSra
			
			oBrwAux 		:= GetMBrowse()
		    oFilAux 		:= oBrwAux:FwFilter()			
			cSraFilter		:= oFilAux:GetExprSQL()
					 
			//TRATADO PARA NÃO ESTOURAR ERRO NO METODO GetExprSQL DO GPEA180.
			aBkpFilter := oBrwAux:oFwFilter:aFilter
			oBrwAux:oFwFilter:aFilter := {}
		
			SetFunName("GPEA180")
			lRet := ( Gpea180Mat("RH3",RH3->(recno()),2) == 1 )
			SetFunName("F050030S")

			oBrwAux:oFwFilter:aFilter := aBkpFilter
			cFilAnt := cFilBkp
		Else
			lRet := .F.
		EndIf
		//lRet := FS180MAT("RH3",RH3->(recno()),2,cFilSra,cMatSra, .F.)
	EndIf
	RestArea(aAreaPA2)
	RestArea(aAreaRH3)
Return( lRet )

/*{Protheus.doc} ValPosto
Valida se existe disponibilidade no posto de destino
@author Cris
@since 23/11/2016
@version P12.1.7
@Project MAN0000007423039_EF_004
@return lValPosto, ${.T. válido  .F. não valido}
*/
Static Function ValPosto()
	
	Local cDepto    := ''
	Local cFilAt    := ''
	Local cCCAt     := ''
	Local cCodCarg  := ''
	Local cQry      := ''
	Local nQtdePost := 0
	Local nPosCpo   := 0
	Local cTabAtu   := ''
	Local lValPosto := .T.
	Local aAreaSRA  := SRA->(GetArea())
	//Dados da Transferência
	//Lembrar que na transferência posso mudar filial, departamento,  centro de custo e/ou processo
	//Para o posto
	if aCpos <> Nil
		
		//Busca a informação da filial de Destino
		if (nPosCpo := Ascan(aCpos,{|x| Alltrim(x[1]) == 'TMP_FILVAG'})) > 0			
			cFilAt	:= Alltrim(aCpos[nPosCpo][2])
		EndIf
		
		//Busca a informação do Centro de Custo de Destino
		if (nPosCpo := Ascan(aCpos,{|x| Alltrim(x[1]) == 'PA2_CC'})) > 0			
			cCCAt	:= Alltrim(aCpos[nPosCpo][2])
		EndIf
		
		//Busca a informação do deparrtamento de Destino
		if (nPosCpo := Ascan(aCpos,{|x| Alltrim(x[1]) == 'TMP_DPTVAG'})) > 0		
			cDepto	:= Alltrim(aCpos[nPosCpo][2])
		EndIf
		
	EndIf
	
	//Dados do cargo
	if aCpos <> Nil
		
		if (nPosCpo := Ascan(aCpos,{|x| Alltrim(x[1]) == 'TMP_CARGOV'})) > 0			
			cCodCarg	:= Alltrim(aCpos[nPosCpo][2])
		EndIf
		
	EndIf
	
	if aCpos <> Nil .OR. aCpos <> Nil
		
		if Empty(cCodCarg) .OR. Empty(cFilAt) .OR. Empty(cDepto) .OR. Empty(cCCAt)
			
			dbSelectArea("SRA")
			SRA->(dbSetORder(1))
			if SRA->(dbSeek(RH3->RH3_FILIAL+RH3->RH3_MAT))
				
				cFilAt	:= iif(Empty(cFilAt),SRA->RA_FILIAL, cFilAt)
				cDepto	:= iif(Empty(cDepto),SRA->RA_DEPTO, cDepto)
				cCCAt	:= iif(Empty(cCCAt),SRA->RA_CC, cCCAt)
				cCodCarg:= iif(Empty(cCodCarg),SRA->RA_CARGO,cCodCarg)
			EndIf
			
		EndIf
		
		cTabAtu	:= GetNextAlias()
		
		cQry	:=  "	SELECT (RCL_NPOSTO-RCL_OPOSTO) AS QTDEDISPONIVEL "+CRLF
		cQry	+=  "		FROM "+RetSqlName("RCL")+" "+CRLF
		cQry	+=  "		WHERE RCL_FILIAL = '"+iif(!Empty(xFilial("RCL")),cFilAt,xFilial("RCL"))+"' "+CRLF
		cQry	+=  "		  AND RCL_DEPTO = '"+cDepto+"' "+CRLF
		cQry	+=  "		  AND RCL_CARGO IN ('','"+cCodCarg+"')"+CRLF
		cQry	+=  "		  AND D_E_L_E_T_ = ''"+CRLF
		cQry	+=  "		  AND (RCL_DTINI <= '"+Dtos(dDataBase)+"' OR RCL_DTINI = ' ' ) "+CRLF
		cQry	+=  "		  AND ("+CRLF
		cQry	+=  "		  		RCL_DTFIM >= '"+Dtos(dDataBase)+"' OR "+CRLF
		cQry	+=  "		  		RCL_DTFIM = ' '"+CRLF
		cQry	+=  "		   )"
		
		cQry := ChangeQuery(cQry)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cTabAtu,.T.,.T.)
		
		While !(cTabAtu)->(Eof())
			
			nQtdePost	+= (cTabAtu)->QTDEDISPONIVEL
			(cTabAtu)->(DbSkip())
		End	
		
		If nQtdePost != 0
			lValPosto	:= .T.
		Else			
			lValPosto	:= .F.
		EndIf
		
		if !lValPosto		
			//Ticket No. 4494084 - 418497 - Don Junior - Correção de mensagem para op usuário
			//Help("",1, "Help", "Validação da Posto(ValPosto_01)", "Para o cargo "+cCodCarg+", departamento "+cDepto+" e filial "+cFilAt+" não existe posto disponível!" , 3, 0)
			MsgAlert("Este posto está ocupado. Caso não realize a adequação, a quantidade de colaboradores existentes será maior que a quantidade prevista.")
			lValPosto	:= .T.
		EndIf
		
		(cTabAtu)->(dbCloseArea())
	EndIf
	RestArea(aAreaSRA)

Return lValPosto


Static Function FS180MAT(cAlias,nReg,nOpc,cFilOri,cMatOri, lAutoma)
	
	Local aArea			:= GetArea()
	Local aAreaSRA		:= SRA->( GetArea() )
	Local aAreaSM0		:= SM0->( GetArea() )
	Local aAreaSQB		:= SQB->( GetArea() )
	Local aAreaBckUp	:= {}
	Local aKeyRecnos	:= {}
	Local bGpea180Prc	:= { || Gpea180Prc() }
	Local bChkDataTrf	:= { || .T. }
	Local bChkEmpAte	:= { || .T. }
	Local bChkFilAte	:= { || .T. }
	Local bChkCcAte		:= { || .T. }
	Local bChkDptoAte	:= { || .T. }
	Local bChkPstoAte	:= { || .T. }
	Local bChkMatAte	:= { || .T. }
	Local bChkItemAte	:= { || .T. }
	Local bChkCLVLAte	:= { || .T. }
	Local bMsDialogVld	:= { || .T. }
	Local bChkQuality	:= { || .T. }
	Local cSvFilAnt		:= cFilAnt
	Local cSvEmpAnt		:= cEmpAnt
	Local cDescFil   	:= Space(35)
	Local cDescPara  	:= ""
	Local cDescPE    	:= ""
	Local cNome      	:= Space(35)
	Local cDptoDesc   	:= ""
	Local cDescEmpr		:= ""
	Local cDescCcAnt	:= ""
	Local cDescDptoAnt	:= ""
	Local cDescPostoAnt	:= ""
	Local cCcXb      	:= ""
	Local cDptoXb      	:= ""
	Local cEmpGru		:= ""
	Local cEmpFil		:= ""
	Local lRet1			:= .F.
	Local lRet2			:= .F.
	Local lRet3			:= .F.
	Local lRet4			:= .F.
	Local lRet5			:= .F.
	Local lSraLock		:= .F.
	Local lAvisoBlq 	:= .T.
	Local lBloqMat		:= SuperGetMv("MV_BLOQMAT",,.F.)  //Se .F. permitira alterar o numero da matricula destino na transferencia individual, caso contrario mantera sempre a matricula do funcionario
	Local nSavRecT		:= 0
	Local nSavRec		:= 0
	Local oDlg
	Local oGet
	Local oGet1
	Local oGet2
	Local oGet3
	Local oGet4
	Local oGet5
	Local oGet6
	Local oGet7
	Local oGet8
	Local oGet9
	Local oGet10
	Local oGet11
	Local oGet12
	Local oGet13
	Local oGet14
	Local cModAcces
	Local bSet15
	Local bSet24
	Local bChkItem 		:= { || .T. }
	Local bChkCLVL		:= { || .T. }
	Local cItXb			:= ""
	Local cClXb			:= ""
	Local lTopOk		:=	.F.
	Local nAmbCLASSIS 	:= 0
	Local nAmbTOP		:= 0
	Local nColAux		:= 0
	Local lTela			:= .F.
	Local lRet			:= .T.
	
	Private cFilAte   		:= ""
	Private cDptoAte  		:= ""
	Private cPostoAte 		:= ""
	Private cFuncAte 		:= ""
	Private cCcuAte   		:= ""
	//Inicializa as Statics
	PRIVATE __cArqTab := cArqTab
	
	PRIVATE __cEmpAnt := cEmpAnt
	PRIVATE __cLastEmp := cEmpAnt + cFilAnt
	PRIVATE __cMudEmp	:= __cLastEmp
	
	//Monta Array para o Relacionamento das Entidades
	Private aRelation 		:= {}
	Private __cFilAnt := cFilAnt
	Private lSraRelation	:= .F.
	BldArrRdZRel( @aRelation )
	lSraRelation := ( AScan( aRelation , { |x| Upper(AllTrim(x[1])) == "SRA" } ) > 0 )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis Privadas                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aInfo			:= {}
	Private lSI3Igual		:= .F.
	Private aKeyCcFilter	:= {}
	Private cAliasCc    	:= Iif( SuperGetMv("MV_MCONTAB") == "CTB" , "CTT" , "SI3" )
	Private cAliasDpto    	:= "SQB"
	Private cAliasFunc		:= "SRA"
	Private cAliasPost		:= "RCL"
	Private cAliasIt		:= "CTD"
	Private cAliasCL		:= "CTH"
	Private cAliasQry       := "RH4"
	Private cFilMat			:= Space(FWGETTAMFILIAL)
	Private cCcusto			:= " "
	Private cDpto			:= " "
	Private __cSvFilAnt		:= cFilAnt	//Salva a Filial Corrente
	Private __cSvEmpAnt		:= cEmpAnt	//Salva a Empresa Corrente
	Private dDataTra		:= Ctod("01/" + StrZero(Month(dDataBase),2) + "/" + StrZero(Year(dDataBase),4) , "DDMMYY" )
	Private cFilDe			:= Space(FWGETTAMFILIAL)
	Private cMatDe			:= ""
	Private cMatAuto		:= ""
	Private cNomeDe			:= ""
	Private cCcDe			:= ""
	Private cDptoDe			:= ""
	Private cPostoDe		:= ""
	Private lLote			:= ( ( SRA->( FieldPos( "RA_OKTRANS" ) ) > 0 ) .and. ( nOpc == 4 ) )
	Private lIntGPE  		:= If(GetMv("MV_QGINT",.F.,"N") == "S",.T.,.F.)
	Private cItemDe			:= ""
	Private cCLVLDe			:= ""
	Private cItem			:= ""
	Private cClasse 		:= ""
	Private cDescItD		:= ""
	Private cDEscClD		:= ""
	Private cTipoAte		:= ""
	Private cTabAte			:= ""
	Private cNivAte			:= ""
	Private cFaixAte		:= ""
	Private cOrgCfg			:= SuperGetMv("MV_ORGCFG", NIL, "0" )	//-- Controle de Postos : 0-não usa Sigaorg;1-Tem controle de postos; 2- não tem  controle de postos
	Private lReutMat  		:= SuperGetMv("MV_REUTMAT",.F.,.F.)  //Se .t. nao permitira alterar o numero da matricula destino e ira sobrepor caso seja por Lote e ja exista a matricula destino
	Private lCorpManage		:= fIsCorpManage()
	Private aLogTransf1		:= {}
	Private cFolMes			:= SuperGetMv("MV_FOLMES",, Space(08))
	Private cCatDe			:= ""
	Private cCPFDe			:= ""
	Private cCPFAte			:= ""
	Private cCTPSDe			:= ""
	Private dDtAltSal
	Private nSalarioAte		:= 0
	Private cBkpFunc		:= ""
	Private cBkpCarg		:= ""
	Private cEmpAte  	 	:= ""
	Private cUltEmp			:= ""
	Private cCgcDe    		:= ""
	Private cCgcPara  		:= ""
	Private cItemAte 		:= ""
	Private cCLVLAte 		:= ""
	Private cGhosth	  		:= " "
	Private cContrMat  		:= If(!lLote, SuperGetMv("MV_MATRICU",NIL,"0"), "")
	Private cCcDesc    		:= ""
	Private cItDesc    		:= ""
	Private cCLDesc    		:= ""
	Private lMatDif			:= .F.
	Private lCcDif	   		:= .F.
	Private lDptoDif  		:= .F.
	Private lPostoDif  		:= .F.
	Private lFilDif	  		:= .F.
	Private lEmpDif	  		:= .F.
	Private lCgcDif	  		:= .F.
	Private lDelNovo  		:= .F.
	Private lGravaNovo		:= .F.
	Private lDelAntigo 		:= .F.
	Private lRegrava   		:= .F.
	Private lMudaSra   		:= .F.
	Private lItemDif   		:= .F.
	Private lClvlDif  		:= .F.
	Private lCpfDif	  		:= .F.
	Private lConfirm		:= .F.
	Private lChSx8			:= .F.
	Private lGrvSx8			:= .F.
	Private lContrMat		:= (!Empty(cContrMat) .And. cContrMat != "0")
	Private nOpcA			:= 2
	Private aIndexSRA		:= {}
	
	// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// ³Verifica data base com o parametro FOLMES³
	// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lItemClVl .And. !lLote
		cItem	:= SRA->RA_ITEM
		cClasse	:= SRA->RA_CLVL
	EndIf
	
	IF !( lLote )
		__aMrkRecnos__	:= {}
		__aMrkKeys__	:= {}
		If SRA->RA_RESCRAI$'30/31'
			RestArea( aAreaSM0 )
			RestArea( aArea )
			RestArea( aAreaSRA )
			RestArea( aAreaSQB )
			Return
		EndIf
	EndIF
	
	Begin Sequence
		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Define Qual a Consulta Padrao para o Cadastro de Centros   de³
		³ Custo e a Chave de Filtro									   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		cCcXb			:= Iif( cAliasCc == "CTT" , "XTT" , "XI3" )
		aKeyCcFilter	:= { PrefixoCpo( cAliasCc ) + "_FILIAL" , PrefixoCpo( cAliasCc ) + "_CUSTO" }
		If lItemClVl
			cItXb		:= "CTD"
			cClXb		:= "CTH"
		EndIf
		
		cDptoXb		:= "SQB"
		cPostoXb	:= "RCLOR1"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nao Permitir que Funcionario de Outra Filial seja Transferido³
		//³ em Funcao de estar sendo Monstrado na mBrowse()              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*		IF ( SRA->RA_FILIAL != xFilial( "SRA" ) )
			Alert("É necessário realizar a efetivação através da filial do usuário efetivado: "+SRA->RA_FILIAL)
			lRet:= .F.
			Break
			
		EndIF
*/		
		// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		// ³Verifica se o calculo esta liberado      ³
		// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lLote .And. !fVldAccess( SRA->RA_FILIAL, Stod( cFolMes + "01" ), , .T., "FOL","1" )
			lRet:= .F.
			Break
		ElseIf !fVldAccess( SRA->RA_FILIAL, Stod( cFolMes + "01" ), , lAvisoBlq, "FOL","1" )
			lAvisoBlq := .F.
			lRet:= .F.
			Break
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no proximo Funcionario apos a Transferencia        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nSavRecT := SRA->( Recno() )
		SRA->( dbSkip() )
		If SRA->( !Eof() )
			nSavRec  := SRA->( Recno() )
			SRA->( dbGoTo(nSavRecT) )
		Else
			SRA->( dbGoTo(nSavRecT) )
			nSavRec := nSavRecT
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Variaveis de Gets da Transferencia                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cEmpAte		:= __cSvEmpAnt
		cFilAte		:= __cSvFilAnt
		
		cMatAte		:= SRA->RA_MAT
		//cDptoAte	:= SRA->RA_MAT
		
		//cCcuAte		:= Iif( ((Type("lLote") == "L") .and. lLote), Space(TamSx3("RA_CC")[1]), SRA->RA_CC )
		//cDptoAte	:= Iif( ((Type("lLote") == "L") .and. lLote), Space(TamSx3("RA_DEPTO")[1]), SRA->RA_DEPTO )
		
		
		If cOrgCfg == "1"
			//cPostoAte := Iif( ((Type("lLote") == "L") .and. lLote), Space(TamSx3("RA_POSTO")[1]), SRA->RA_POSTO )
		EndIf
		
		If lItemClVl
			//cItemAte	:= Iif( ((Type("lLote") == "L") .and. lLote), Space(TamSx3("RA_ITEM")[1]), SRA->RA_ITEM )
			//cCLVLAte	:= Iif( ((Type("lLote") == "L") .and. lLote), Space(TamSx3("RA_CLVL")[1]), SRA->RA_CLVL )
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega Informacoes da Empresa Origem                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fInfo(@aInfo,Sra->Ra_Filial)
		cDescEmpr	:= PadR(aInfo[3],35)	//?-
		cDescFil	:= PadR(aInfo[1],35)	//?-
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Obtem a Filial de Origem                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFilDe 		:= SRA->RA_FILIAL
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Bloco para Validacao da Empresa Ate                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bChkEmpAte	:= { || Ch_Emp(cEmpAte,@cDescPE) .and. CheckSX3("RE_EMPP") }
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Bloco para Validacao da Filial Ate                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bChkFilAte	:= { || Ch_Fil(cEmpAte , cFilAte , @cDescPara ) .and. CheckSX3("RE_FILIALP") }
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Bloco para Validacao do Centro de Custo Ate            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bChkCcAte	:= { || ConsCc() .and. CheckSX3("RE_CCP")  }
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Bloco para Validacao do Departamento Ate               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bChkDptoAte	:= { || ConsDepto() .and. CheckSX3("RE_DEPTOP")  }
		
		If (cOrgCfg == "1")
			bChkPstoAte	:= { || ConsPosto() .and. CheckSX3("RE_POSTOP") }
			
		EndIf
		
		If lItemClVl
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta Bloco para Validacao do Item Contabil  Ate             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			bChkItemAte	:= { || ConsIt(cFilAte,cItemAte,@cItDesc)  }
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta Bloco para Validacao do Item Contabil  Ate             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			bChkCLVLAte	:= { || ConsCL(cFilAte,cCLVLAte,@cCLDesc) }
		EndIf
		lLote := .F.
		IF !( lLote )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Trava Registro Do Cadastro                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea( "SRA" )
			SRA->(dbSetOrder(1))
			AAdd( __aMrkRecnos__ , nSavRecT )
			AAdd( __aMrkKeys__   , RA_FILIAL + RA_MAT )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Obtem a Matricula de Origem                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cMatDe  := SRA->RA_MAT
			cNomeDe := SRA->RA_NOME
			cCPFDe  := SRA->RA_CIC
			cCatDe  := SRA->RA_CATFUNC
			cCTPSDe := SRA->RA_NUMCP + SRA->RA_SERCP + SRA->RA_UFCP
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Obtem o Centro de Custo de Origem                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCcDe  		:= SRA->RA_CC
			cDescCcAnt	:= DescCc(cCcDe,__cSvFilAnt,NIL,.F.)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Obtem o Depto de Origem                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cDptoDe  		:= SRA->RA_DEPTO
			If Select("SQB")>0
				aAreaBckUp		:= SQB->( GetArea() )
				SQB->( dbSetOrder(1) )
			Endif
			cDescDptoAnt	:= fDesc('SQB',SRA->RA_DEPTO,'QB_DESCRIC')
			If !Empty(aAreaBckUp)
				RestArea(aAreaBckUp)
			EndIf
			
			If cOrgCfg == "1"
				cPostoDe 		:= SRA->RA_POSTO
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Obtem a Nome do funcionario                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lBloqMat
				cNome := SRA->RA_NOME
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Obtem o Item Contabil e Classe de Valor Origem               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lItemClVl
				cItemDe		:= SRA->RA_ITEM
				cDescItD	:= DescIt( cItemDe , SRA->RA_FILIAL , NIL )
				cCLVLDe 	:= SRA->RA_CLVL
				cDEscClD	:= DescCl( cCLVLDe , SRA->RA_FILIAL , NIL )
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Bloco para Validar a Data de Transferencia                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			bChkDataTrf	:= { || Ch_Dat(@dDataTra) .and. CheckSX3("RE_DATA") }
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta Bloco para Validacao da Matricula Ate                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			bChkMatAte	:= { || CheckSX3("RE_MATP") .and. ConsMat() }
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta Bloco para Validacao do Departamento Ate               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			bChkDptoAte	:= { || ConsDepto() .and. CheckSX3("RE_DEPTOP")  }
			
			If (cOrgCfg == "1")
				bChkPstoAte	:= { || ConsPosto() .and. CheckSX3("RE_POSTOP") }
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta Bloco para Validacao do bloqueio do PCO                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			bChkPCO		:= { || PcoVldLan('000086','01') .And. PcoVldLan('000086','02') }
			
			//Verifica se tem integracao com o Quality e se o usuario tem movimentacao nos ambientes de qualidade...
			
			If lIntGPE .and. GetMv("MV_QVLUSAR",.T.,"2") == "1"
				bChkQuality := { || QA_VLUSA(cFilAte,cMatAte,cEmpAte)}
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta Bloco para Validacao do Dialog                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			bChkItem 		:= { || ConsIt(cFilAte,cItemAte,@cItDesc) }
			bChkCLVL 		:= { || ConsCL(cFilAte,cCLVLAte,@cCLDesc) }
			If lItemClVl
				bMsDialogVld	:= { || IF( nOpca == 1 ,;
					(	Eval( bChkDataTrf );
					.and.;
					Eval( bChkEmpAte );
					.and.;
					Eval( bChkFilAte );
					.and.;
					Eval( bChkCcAte );
					.and.;
					Eval( bChkDptoAte );
					.and.;
					Eval( bChkItem );
					.and.;
					Eval( bChkCLVL );
					.and.;
					Eval( bChkMatAte );
					.and.;
					Eval( bChkPCO );
					.and.;
					Eval( bChkQuality );
					.and.;
					( cOrgCfg <> "1" .or. Eval(bChkPstoAte) );
					),;
					.T.;
					);
					}
			Else
				bMsDialogVld	:= { || IF( nOpca == 1 ,;
					(	Eval( bChkDataTrf );
					.and.;
					Eval( bChkEmpAte );
					.and.;
					Eval( bChkFilAte );
					.and.;
					Eval( bChkCcAte );
					.and.;
					Eval( bChkDptoAte );
					.and.;
					Eval( bChkMatAte );
					.and.;
					Eval( bChkPCO );
					.and.;
					Eval( bChkQuality );
					.and.;
					( cOrgCfg <> "1" .or. Eval(bChkPstoAte) );
					),;
					.T.;
					);
					}
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta Bloco para Validacao do bloqueio do PCO                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			bChkPCO := { || PcoVldBlq()  }
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta Bloco para Validacao do Dialog                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			bChkItem 		:= { || ConsIt(cFilAte,cItemAte,@cItDesc) }
			bChkCLVL 		:= { || ConsCL(cFilAte,cCLVLAte,@cCLDesc) }
			If lItemClVl
				bMsDialogVld	:= { || IF( nOpca == 1 ,;
					(	Eval( bChkEmpAte );
					.and.;
					Eval( bChkFilAte );
					.and.;
					Eval( bChkCcAte );
					.and.;
					Eval( bChkDptoAte );
					.and.;
					Eval( bChkItem );
					.and.;
					Eval( bChkCLVL );
					.and.;
					Eval( bChkPCO );
					.and.;
					Eval( bChkQuality );
					.and.;
					( cOrgCfg <> "1" .or. Eval(bChkPstoAte) );
					),;
					.T.;
					);
					}
			Else
				bMsDialogVld	:= { || IF( nOpca == 1 ,;
					(	Eval( bChkEmpAte );
					.and.;
					Eval( bChkFilAte );
					.and.;
					Eval( bChkCcAte );
					.and.;
					Eval( bChkDptoAte );
					.and.;
					Eval( bChkPCO );
					.and.;
					Eval( bChkQuality );
					.and.;
					( cOrgCfg <> "1" .or. Eval(bChkPstoAte) );
					),;
					.T.;
					);
					}
			EndIf
		EndIF
		PcoIniLan('000086')
		
		If !IsInCallStack("TCFA040")
			cDescPE := cDescEmpr
		Else
			cAliasQry := "LRH4"
			BeginSql alias cAliasQry
				SELECT RH4.RH4_CAMPO, RH4.RH4_VALNOV
				FROM %table:RH4% RH4
				WHERE RH4.RH4_CODIGO = %exp:RH3->RH3_CODIGO% AND
				RH4.RH4_CAMPO  = "RE_EMPP" 			 AND
				RH4.%notDel%
			EndSql
			
			If !(cAliasQry)->(eof())
				cEmpAte := rtrim((cAliasQry)->RH4_VALNOV)
				cDescPE := AllTrim(Posicione("SM0",1,cEmpAte,"M0_NOME"))
				cUltEmp := cEmpAte
			Endif
			(cAliasQry)->( DbCloseArea() )
		Endif
		
		If !IsInCallStack("TCFA040")
			cDescPara := cDescFil
		else
			cAliasQry := "LRH4"
			BeginSql alias cAliasQry
				SELECT RH4.RH4_CAMPO, RH4.RH4_VALNOV
				FROM %table:RH4% RH4
				WHERE RH4.RH4_CODIGO = %exp:RH3->RH3_CODIGO% AND
				RH4.RH4_CAMPO  = "RE_FILIALP"			 AND
				RH4.%notDel%
			EndSql
			
			If !(cAliasQry)->(eof())
				cFilAte := Substr((cAliasQry)->RH4_VALNOV,1,FWGETTAMFILIAL)
				cEmpAnt := cFilAte
				cDescPara := AllTrim(Posicione("SM0",1,cEmpAte + cFilAte,"M0_FILIAL"))
			Endif
			(cAliasQry)->( DbCloseArea() )
		Endif
		
		If !IsInCallStack("TCFA040")
			cCcDesc := cDescCcAnt
		Else
			cAliasQry := "LRH4"
			BeginSql alias cAliasQry
				SELECT RH4.RH4_CAMPO, RH4.RH4_VALNOV
				FROM %table:RH4% RH4
				WHERE RH4.RH4_CODIGO = %exp:RH3->RH3_CODIGO% AND
				RH4.RH4_CAMPO  = "RE_CCP" 			 AND
				RH4.%notDel%
			EndSql
			
			If !(cAliasQry)->(eof())
				cCcuAte := rtrim((cAliasQry)->RH4_VALNOV)
				(cAliasQry)->( DbCloseArea() )
				
				BeginSql alias cAliasQry
					SELECT RH4.RH4_CAMPO, RH4.RH4_VALNOV
					FROM %table:RH4% RH4
					WHERE RH4.RH4_CODIGO = %exp:RH3->RH3_CODIGO% AND
					RH4.RH4_CAMPO  = "TMP_DCCP" 			 AND
					RH4.%notDel%
				EndSql
				If (cAliasQry)->(eof())
					cCcDesc := ""
				Else
					cCcDesc := (cAliasQry)->RH4_VALNOV
				EndIf
			EndIf
			(cAliasQry)->( DbCloseArea() )
		EndIf
		
		If !IsInCallStack("TCFA040")
			cDptoDesc := cDescDptoAnt
		Else
			cAliasQry := "LRH4"
			BeginSql alias cAliasQry
				SELECT RH4.RH4_CAMPO, RH4.RH4_VALNOV
				FROM %table:RH4% RH4
				WHERE RH4.RH4_CODIGO = %exp:RH3->RH3_CODIGO% AND
				RH4.RH4_CAMPO  = "RE_DEPTOP" 			 AND
				RH4.%notDel%
			EndSql
			If !(cAliasQry)->(Eof())
				cDptoAte := rtrim((cAliasQry)->RH4_VALNOV)
				(cAliasQry)->( DbCloseArea() )
				
				BeginSql alias cAliasQry
					SELECT RH4.RH4_CAMPO, RH4.RH4_VALNOV
					FROM %table:RH4% RH4
					WHERE RH4.RH4_CODIGO = %exp:RH3->RH3_CODIGO% AND
					RH4.RH4_CAMPO  = "TMP_DDEPTOP" 		 AND
					RH4.%notDel%
				EndSql
				If (cAliasQry)->(eof())
					cDptoDesc := ""
				Else
					cDptoDesc := (cAliasQry)->RH4_VALNOV
				EndIf
				
			EndIf
			
			(cAliasQry)->( DbCloseArea() )
		EndIf
		
		If cOrgCfg == "1"
			
			If IsInCallStack("TCFA040")
				
				cAliasQry := "LRH4"
				BeginSql alias cAliasQry
					SELECT RH4.RH4_CAMPO, RH4.RH4_VALNOV
					FROM %table:RH4% RH4
					WHERE RH4.RH4_CODIGO = %exp:RH3->RH3_CODIGO% AND
					RH4.RH4_CAMPO  = "RE_POSTOP" 			 AND
					RH4.%notDel%
				EndSql
				
				If (cAliasQry)->(eof())
					cPostoAte := ""
				Else
					cPostoAte := (cAliasQry)->RH4_VALNOV
				EndIf
				
				(cAliasQry)->( DbCloseArea() )
			EndIf
			
		EndIf
		
		If lItemClVl
			cItDesc := cDescItD
			cCLDesc := cDEscClD
		EndIf
		
		bSet15 := {|| nOpcA := 1, lConfirm := .T. , oDlg:End()}
		bSet24 := {|| nOpcA := 2 , oDlg:End()}
		
		nOpcA := 1
		//ALTERAÇÔES PARA EXECUÇÃO AUTOMÁTICA
		
		//Dados Origem
		
		//cFilDe 		:= cFilOri
		//cMatDe		:= cMatOri
		
		
		If cCcuAte != cCcDe
			cMatAte := cMatDe
		EndIf
		
		If (__cMudEmp <> __cLastEmp) //cEmpAnt + cFilAnt
			fAbreTab()
			fMudaEmp(__cEmpAnt , __cFilAnt)
			RestArea( aAreaSRA )
		Else
			cFilAnt := __cFilAnt		// Sempre volto ao estado original.
		EndIf
		
		If  (nOpcA == 1) .And. (!Empty(SRA->RA_DEMISSA) .Or. (SRA->RA_SITFOLH == "D"))
			If !(MsgYesNo("TESTE"))
				nOpca := 2
			EndIf
		EndIf
		
		IF ( lLote )
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Transferencia nao pode ser posterior ao mes de calculo da folha ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			cFolMes := MesAno( dDataTra )
			If MesAno( dDataTra ) > cFolMes .Or. MesAno( dDataTra ) < cFolMes
				cMsg := OemToAnsi( "Transferencias não são permitidas em meses Posteriores ou Anteriores ao atual mês de cálculo da Folha de Pagamento " ) //"Transferencias não são permitidas em meses Posteriores ou Anteriores ao atual mês de cálculo da Folha de Pagamento "
				cMsg += "(" + SubStr( cFolMes, 5, 2 ) + "/" + SubStr( cFolMes, 1, 4 ) + ")."
				If lAutoma
					ConOut( cMsg )
				Else
					MsgAlert( OemToAnsi( cMsg ) )
				EndIf
				lRet:= .F.
				Break
			EndIf
			
			//"Transferˆncia em Lote"
			Proc2BarGauge( bGpea180Prc , OemToAnsi( cCadastro + " - " + "Transferˆncia em Lote" ) , NIL , NIL , .F. , .T. , .F. , .T. )
		Else
			If lItemClVl
				IF 	 (;
						( cEmpAte == __cSvEmpAnt );	//Mesma Empresa
					.and.;
						( cFilAte == cFilDe );		//Mesma Filial
					.and.;
						( cCcuAte == cCcDe );		//Mesmo Centro de Custo
					.and.;
						( cDptoAte == cDptoDe );	//Mesmo Departamento
					.and.;
						( cItemAte == cItemDe ); 	//Mesmo Item Contabil
					.and.;
						( cClvlAte == cClvlDe );	//Mesma Classe de Valor
					.and.;
						( cMatAte == cMatDe );		//Mesma Matricula
					.and.;
						( cOrgCfg <> "1" .or. cPostoDe == cPostoAte ); //Mesmo Posto
					)
					If lAutoma
						ConOut( "Empresa Igual" )
					Else
						Help(" ",1,"EMPREIGUAL")
					EndIf
					lRet:= .F.
					Break
				EndIF
				IF (;
						( cEmpAte == __cSvEmpAnt );	//Mesma Empresa
					.and.;
						( cFilAte == cFilDe );		//Mesma Filial
					.and.;
						( cCcuAte # cCcDe );		//Centro de Custo Diferente
					.and.;
						( cDptoAte # cDptoDe );		//Departamento Diferente
					.and.;
						( cItemAte # cItemDe );		//Item Contabil Diferente
					.and.;
						( cClvlAte # cClvlDe );		//Classe de Valor Diferente
					.and.;
						( cOrgCfg <> "1" .or. cPostoAte # cPostoDe );		//Posto Diferente
					.and.;
						( cMatAte # cMatDe );		//Matricula Diferente
					)
					If lAutoma
						ConOut( "Matricula Diferente" )
					Else
						Help(" ",1,"MATDIFEREN")
					EndIf
					lRet:= .F.
					Break
				EndIF
				
				If cFilAte != cFilDe
					lFilDif := .T.
				EndIf
				If cPostoDe != cPostoAte
					lPostoDif := .T.
				EndIf
				
				If cMatAte != cMatDe
					lMatDif := .T.
				EndIf
				
				If cFilAte != cFilDe
					lFilDif := .T.
				EndIf
				
				If cDptoAte != cDptoDe
					lDptoDif := .T.
				EndIf
				
				FS180Prc(lAutoma)
			Else
				IF 	 (;
						( cEmpAte == __cSvEmpAnt );	//Mesma Empresa
					.and.;
						( cFilAte == cFilDe );		//Mesma Filial
					.and.;
						( cCcuAte == cCcDe );		//Mesmo Centro de Custo
					.and.;
						( cDptoAte == cDptoDe );	//Mesmo Departamento
					.and.;
						( cOrgCfg <> "1" .or. cPostoAte == cPostoDe );		//Posto Diferente
					.and.;
						( cMatAte == cMatDe );		//Mesma Matricula
					)
					If lAutoma
						ConOut( "Empresa Igual " )
					Else
						Help(" ",1,"EMPREIGUAL")
					EndIf
					lRet:= .F.
					Break
				EndIF
				IF (;
						( cEmpAte == __cSvEmpAnt );	//Mesma Empresa
					.and.;
						( cFilAte == cFilDe );		//Mesma Filial
					.and.;
						( cCcuAte # cCcDe );		//Centro de Custo Diferente
					.and.;
						( cDptoAte # cDptoDe );		//Mesmo Departamento
					.and.;
						( cOrgCfg <> "1" .or. cPostoAte # cPostoDe );		//Posto Diferente
					.and.;
						( cMatAte # cMatDe );		//Matricula Diferenta
					)
					If lAutoma
						ConOut( "Matricula Diferente" )
					Else
						Help(" ",1,"MATDIFEREN")
					EndIf
					lRet:= .F.
					Break
				EndIF
				
				If cFilAte != cFilDe
					lFilDif := .T.
				EndIf
				If cPostoDe != cPostoAte
					lPostoDif := .T.
				EndIf
				
				If cMatAte != cMatDe
					lMatDif := .T.
				EndIf
				
				If cFilAte != cFilDe
					lFilDif := .T.
				EndIf
				
				If cDptoAte != cDptoDe
					lDptoDif := .T.
				EndIf
				
				FS180Prc(lAutoma)
				
			EndIf
		EndIF
		
	End Sequence
	
	IF !( lLote )
		IF ( lSraLock )
			Gpea180FreeLocks( __aMrkRecnos__[ 1 ] , __aMrkKeys__[ 1 ] )
		EndIF
	EndIF
	If (( lMatDif ) .and. !( lCcDif ) .and. !( lFilDif ) .and. !( lEmpDif ) .and. !( lDptoDif ))
		If MesAno(SRA->RA_ADMISSA) == alltrim(GetMv("MV_FOLMES")) .And. GetNewPar("MV_RMCLASS",.F.)
			If (lTopOk := _IntRMTpCon(@nAmbTOP,@nAmbCLASSIS))
				ClsIncPrf("U", "GPE180")
			Else
				MsgSTop("O registro não será integrado ao RM - Não existe ambiente instalado.") //"O registro não será integrado ao RM - Não existe ambiente instalado."
			EndIf
		Endif
	Endif
	
	If lContrMat .AND. lChSx8
		//Nao grava o numero automatico se houver alteracao do codigo gerado pelo sistema
		If !lGrvSx8 .Or. ( cMatAuto # cMatAte )
			RollBackSX8()
		Else
			If lEmpDif
				fMudaEmp(cEmpAte , cFilAte)
				ConfirmSx8()
				fMudaEmp(__cEmpAnt , __cFilAnt)
			Else
				ConfirmSx8()
			EndIF
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura Empresa e Filial de Entrada                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cEmpAnt	:= cSvEmpAnt
	cFilAnt := cSvFilAnt
	
	cAlias := "SRA"
	dbSelectArea( cAlias )
	( cAlias )->( MsUnlock() )
	IF !SRA->( DbSeek( cFilMat ) )
		SRA->( MsGoto( nSavRec ) )
	EndIF
	
	RestArea( aAreaSQB )
	RestArea( aAreaSM0 )
	RestArea( aArea )
	RestArea( aAreaSRA )
	
	
Return lRet

Static Function FS180Prc(lAutoma)
	
	Local aFilesTransf	:= {}
	Local aFilesOpen	:= {}
	Local aScopeCount	:= {}
	Local aLogTransf	:= If (!Empty( aLogTransf1 ), aLogTransf1, {} )
	Local aSraUpdRelRd0	:= {}
	Local bGpea180Tra	:= { || Gpea180Tra(aFilesTransf,cFilMat,lDelNovo,lGravaNovo,lDelAntigo,lRegrava) }
	Local bMakeLog		:= { || NIL }
	Local bSraUpdRelRd0 := { || NIL }
	Local cSraFilter	:= SRA->( dbFilter() )
	Local cFilSRA		:= cFilDe
	Local cMsgFk		:= ""
	Local lFilesTransf	:= .F.
	Local nProcRegua	:= SRA->( RecCount() )
	Local nSraNextRecno
	Local nSraOrder
	Local nLoop
	Local nLoops
	Local nSalAnt		:= SRA->RA_SALARIO
	Local lErroRateio	:= .F.
	Local lTSREP		:= SuperGetMv( "MV_TSREP" , NIL , .F. )
	Local cChaveSRE		:= ""
	Local aAreaSRA		:= {}
	Local lGP180VALID	:= ExistBlock("GP180VALID")
	Private oObjREP		:= Nil
	
	Private cTimeIni	:= Time()
	Private cCodFunc	:= Space(TamSx3("RCL_FUNCAO")[1])
	Private cCodCargo	:= Space(TamSx3("RCL_CARGO")[1])
	Private OTEXT
	Begin Sequence
		
		//--Carrega os Arquivos a Serem Transferidos
		If lAutoma
			lFilesTransf := FilesTransf(@aFilesTransf,@aFilesOpen)
		Else
			MsAguarde( { || lFilesTransf := FilesTransf(@aFilesTransf,@aFilesOpen) },"Preparando Arquivos" + "Aguarde..." ) //"Preparando Arquivos. Aguarde..."
		EndIF
		IF !( lFilesTransf )
			Break
		EndIF
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica os CGC das Filiais                                  ³
		//ÀÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( lEmpDif ) .Or. ( lFilDif )
			If ( cCgcDe # cCgcPara )
				lCgcDif := .T.
			ElseIf ( lFilDif .and. ( cCgcDe == cCgcPara ) )
				//"Aten‡„o!"###"Filiais com mesmo CNPJ. A transfˆrencia ser  feita como se os CNPJs fossem diferentes"
				If lAutoma
					ConOut("Atencao" + " " + "Filiais com mesmo CNPJ. A transfˆrencia ser  feita como se os CNPJs fossem diferentes")
				Else
					Aviso(OemToAnsi("Atencao"),OemToAnsi("Filiais com mesmo CNPJ. A transfˆrencia ser  feita como se os CNPJs fossem diferentes"),{"OK"})
				EndIf
				lCgcDif := .T.
			Endif
		Endif
		
		lDelNovo 	:= .F.
		lGravaNovo	:= .F.
		lDelAntigo	:= .F.
		lRegrava	:= .F.
		lMudaSra	:= .F.
		//--mudanca de empresa
		If ( lEmpDif )
			//--CGC DIFERENTE
			If lCgcDif
				lDelNovo 	:= .T.
				lGravaNovo	:= .T.
				lMudaSra	:= .T.
			Else  // CGC IGUAL
				lDelNovo	:= .T.
				lGravaNovo  := .T.
				lDelAntigo	:= .T.
			Endif
			//-- MUDANCA DE FILIAL
		Elseif ( lFilDif )
			//--CGC DIFERENTE
			If ( lCgcDif )
				lDelNovo 	:= .T.
				lGravaNovo	:= .T.
				lMudaSra	:= .T.
			Else             //--CGC IGUAL
				lDelNovo	:= .T.
				lRegrava	:= .T.
			Endif
			//--MUDANCA DE C.CUSTO
		Elseif ( lCcDif )
			lRegrava	:= .T.
			//--MUDANCA DE Departamento
		Elseif ( lDptoDif )
			lRegrava	:= .T.
			//--MUDANCA DE Posto
		ElseIf ( lPostoDif )
			lRegrava	:= .T.
			//--MUDANCA DE ITEM CONTABIL
		ElseIf ( lItemDif )
			lRegrava	:= .T.
			//--MUDANCA DE CLASSE DE VALOR
		ElseIf ( lClvlDif )
			lRegrava	:= .T.
			//--MUDANCA DE MATRICULA
		Elseif ( lMatDif )
			lDelNovo 	:= .T.
			lRegrava	:= .T.
		Endif
		
		cFilMat := cFilDe + cMatDe
		cCcusto := cCcDe
		
		dbSelectArea( "SRA" )
		If !(lLote)
			SRA->( dbSetOrder( 1 ) )
			SRA->( MsSeek( cFilMat , .F. ) )
		Else
			//Observação Importante!!!!
			//Não setar a ordem do SRA pois o arquivo (neste ponto) pode estar filtrado.
			//SRA->(DbSeek(cFilSRA,.F.))
			cSraFilter += Iif( !Empty( cSraFilter ) , " .and. IsMark('RA_OKTRANS','" + cMarkTransf + "')" , "IsMark('RA_OKTRANS','" + cMarkTransf + "')" )
			cSraFilter += " .and. RA_FILIAL == '" + cFilSRA + "'"
			//	CREATE SCOPE aScopeCount FOR &( cSraFilter )
			//	nProcRegua := SRA->( ScopeCount( aScopeCount ) )
			//RstTimeRemaining() //Reinicializa o Contador de Tempos em Proc2BarGauge()
			//BarGauge1Set( nProcRegua )
		EndIf
		
		nSraOrder := SRA->( IndexOrd() )
		While SRA->( !Eof() .and. ( RA_FILIAL == cFilSRA ) )
			
			IF !GetNextRecno( "SRA" , @nSraNextRecno , NIL , nSraOrder )
				Exit
			EndIF
			
			IF ( lLote )
				IF !( SRA ->( &( cSraFilter ) ) )
					IF !( GotoNextRecno( "SRA" , nSraNextRecno , nSraOrder ) )
						Exit
					EndIF
					Loop
				EndIF
				cMatDe 	:= SRA->RA_MAT
				cCcDe  	:= SRA->RA_CC
				cDptoDe	:= SRA->RA_DEPTO
				cMatAte	:= SRA->RA_MAT
				cFilMat	:= cFilDe + cMatDe
				If lItemClVl
					cItemDe  	:= SRA->RA_ITEM
					cClvlDe  	:= SRA->RA_CLVL
				EndIf
				IncPrcG1Time(	AllTrim( SRA->RA_FILIAL + " / " + SRA->RA_MAT + " / " + SRA->RA_NOME )	,;	//01 -> Inicio da Mensagem
				nProcRegua																,;	//02 -> Numero de Registros a Serem Processados
				cTimeIni																,;	//03 -> Tempo Inicial
				.F.																		,;	//04 -> Defina se eh um processo unico ou nao ( DEFAULT .T. )
				-1																		,;	//05 -> Contador de Processos
				1	 																	 ;	//06 -> Percentual para Incremento
				)
				IF !( ConsMat( .F. , lLote , @aLogTransf , .F. ) )
					IF !( GotoNextRecno( "SRA" , nSraNextRecno , nSraOrder ) )
						Exit
					EndIF
					Loop
				EndIF
				
				IF !( Ch_Dat( dDataTra , .F. , lLote , @aLogTransf ) )
					IF !( GotoNextRecno( "SRA" , nSraNextRecno , nSraOrder ) )
						Exit
					EndIF
					Loop
				EndIF
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se no SRC tem verbas rateadas quando a transferencia for de ³
			//³empresa ou de filial.                                                ³
			//³Se existir, verifica se o CC origem existe na empresa/filial destino.³
			//³Se nao existir, nao transfere.                                       ³
			//³Retorna .T. se algo impede a transferencia conforme as condicoes aci ³
			//³ma.             														³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lEmpDif	.or. lFilDif
				lErroRateio := a180VerCC(@aLogTransf)
			EndIf
			
			If lErroRateio
				IF !( lLote )
					Break
				EndIF
				
				IF !( GotoNextRecno( "SRA" , nSraNextRecno , nSraOrder ) )
					Break
				Else
					Loop
				EndIF
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada para desprezar o registro corrente se retono .F. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lGP180VALID //ExistBlock("GP180VALID")
				If !( ExecBlock("GP180VALID",.F.,.F.) )
					IF !( GotoNextRecno( "SRA" , nSraNextRecno , nSraOrder ) )
						Break
					EndIF
					IF !( lLote )
						Break
					EndIF
					Loop
				EndIf
			Endif
			
			Begin Transaction
				
				Begin Sequence
					
					If lTSREP .And. SRA->( FieldPos( "RA_CODUNIC" )) != 0 .And. Empty( SRA->RA_CODUNIC )
						If SRA->( RecLock( "SRA" , .F. ) )
							SRA->RA_CODUNIC := FwCodEmp("SRA") + SRA->( RA_FILIAL + RA_MAT) + dToS( Date() ) + Time()
							SRA->( MsUnLock() )
						EndIf
					EndIf
					
					SQS->(DbSetOrder(1)) 
					RH4->(DbSetOrder(1))
					PA2->(DbSetOrder(6))
					PA2->(DbSeek(xFilial("PA2")+RH3->RH3_CODIGO))
					If SQS->(DbSeek(xFilial("SQS") + PA2->PA2_CDVAGA))
						If RH4->(DbSeek(xFilial("RH4") + SQS->QS_XSOLPTL))
							
							While !RH4->(Eof())
								If Trim(RH4->RH4_CAMPO) == "RBT_DEPTO"
									cDeptoAte	:= Trim(RH4->RH4_VALNOV)
								EndIf
									If Trim(RH4->RH4_CAMPO) == "QS_POSTO"
									cPostoAte	:= Trim(RH4->RH4_VALNOV)
								EndIf
								
								If Trim(RH4->RH4_CAMPO) == "QG_XTURNTB"
									dbSelectArea("SPF")//PONA160.PRW
									SPF->(dbSetOrder(1))
									If SPF->( RecLock( "SPF" , !SPF->(DbSeek(SRA->( RA_FILIAL + RA_MAT)) ) ))
										If !Empty(Trim(RH4->RH4_VALNOV))
											SPF->PF_FILIAL    := SRA->RA_FILIAL
											SPF->PF_MAT       := SRA->RA_MAT
											SPF->PF_DATA      := dDataBase
											// SPF->PF_TURNODE   := SRA->RA_FILIAL
											//SPF->PF_SEQUEDE	  := cTSeqAnt
											// SPF->PF_REGRADE   := cRegrAnt
											SPF->PF_TURNOPA   := Trim(RH4->RH4_VALNOV)
											SPF->PF_SEQUEPA   := "01"
											SPF->PF_REGRAPA   := "01"
											SPF->(MsUnLock())
											
											cTurnoPara	:= Trim(RH4->RH4_VALNOV)
										EndIf
										
									EndIf
								EndIf
								
								RH4->(dbSkip())
							EndDo
						EndIf
					EndIf
					
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava Registro no Arquivo de Transferencia                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lItemClVl
						IF ( ( lFilDif ) .or. ( lEmpDif ) .or. ( lCcDif ) .or. (lItemDif) .or. (lClvlDif) .or. ( lDptoDif ) .or. ( lPostoDif ))
							IF !Grava_SRE(@aLogTransf)
								Break
							EndIF
							/*
							ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							³Monta Array com  os dados para envio de e-mail              ³
							ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
							fMontaMail("019")
						EndIF
					Else
						IF ( ( lFilDif ) .or. ( lEmpDif ) .or. ( lCcDif ) .or. ( lDptoDif ) .or. ( lPostoDif ))
							COBSTRA := "Transferência FAP"
							aFuncTran := {}
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Gera a numeracao sequencial do lote de transferencia                               ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							nNumTRF := Val(DTOS(Date())+SubStr(Time(),1,2)+SubStr(Time(),4,2)+SubStr(Time(),7,2))	// 99:99:99
							SRE->( dbSetOrder( RetOrdem( "SRE" , "RE_TRFUNID" ) ) )
							While SRE->(dbSeek(nNumTRF))
								nNumTRF := Val(DTOS(Date())+SubStr(Time(),1,2)+SubStr(Time(),4,2)+StrZero(Val(SubStr(Time(),7,2))+1,2) )	// AAAAMMDDHHMMSS
							Enddo
							SRE->(dbSetOrder(1)) 
							IF !Grava_SRE(@aLogTransf )
								Break
							EndIF
							/*
							ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							³Monta Array com  os dados para envio de e-mail              ³
							ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
							fMontaMail("019")
						EndIF
						
					EndIf
					//--CHAMADA DA FUNCAO DE TRANSFERENCIA
					IF !( lLote )
						If cOrgCfg == "1" .and. cPostoDe # cPostoAte
							If !Gpea180Trf()
								cCodFunc 	:= ""
								cCodCargo	:= ""
								nSalarioAte := 0
							EndIf
						EndIf
						//MsAguarde( bGpea180Tra , OemToAnsi("Aguarde...") ) //"Aguarde..."
						@15,05 Meter oGauge2 Var nGauge2 Pixel Size 185,20
						//RstTimeRemaining()
						Proc2BarGauge(,,,,,,,.F.)
						Gpea180Tra(aFilesTransf,cFilMat,lDelNovo,lGravaNovo,lDelAntigo,lRegrava)
						//Grava historico de alteracao salarial
						If cOrgCfg == "1" .and. ( ( nSalarioAte > 0 .and. nSalAnt <> nSalarioAte ) .or. ( !Empty(cCodFunc) .and. cCodFunc <> cBkpFunc ) .Or. (!Empty(cCodCargo) .and. cCodCargo <> cBkpCarg))
							fGravaSr3()
						EndIf
					Else
						Gpea180Tra(aFilesTransf,cFilMat,lDelNovo,lGravaNovo,lDelAntigo,lRegrava)//Eval( bGpea180Tra )
					EndIF
					
					/*
					ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³Carregando Dados para relacionamento no RDZ/RD0             ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					IF ( lSraRelation )
						IF EntExisteRel( "SRA" , SRA->( RA_FILIAL + RA_MAT ) , __cSvEmpAnt , SRA->RA_FILIAL , .T. )
							AAdd( aSraUpdRelRd0 , { SRA->( Recno() ) , cMatAte , RD0->( Recno() ) } )
						EndIF
					EndIF
					
					If lTSREP
						
						oObjREP := PTSREPOBJ():New()
						
						// Efetua o envio das informacoes para o TSA sobre o novo registro do SRA
						
						/*/
						ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						³ Executa o WebServices TSA - Pessoa Fisica e Usuario          ³
						ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
						If oObjREP:WSNatural( 1 ) .And. oObjREP:WSUser( 1 )
							
							/*/
							ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							³ Grava as informacoes de controle de log de integracao WebServices TSA ³
							ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
							oObjRep:WSUpdRHExp( "SRA" )
						Endif
						
					Endif
					
					IF ( lMudaSra )
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³  Situacao do Funcionario                                     ³
						//³  Data de Demissao                                            ³
						//³  Situacao para RAIS                                          ³
						//³  Codigo de Transferencia FGTS                                ³
						//|  Numero do Cracha                                            |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lMudaSra := SRA_Anterior( cFilMat , dDataTra , @aLogTransf )  // registro anterior
						
						If lMudaSra
							
							If lTSREP
								// Efetua o envio das informacoes para o TSA sobre o registro antigo do SRA
								
								/*/
								ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								³ Executa o WebServices TSA - Pessoa Fisica e Usuario          ³
								ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
								cChaveSRE := PADR(SRE->RE_FILIALP , TAMSX3("RA_FILIAL")[1]) + SRE->RE_MATP
								aAreaSRA	:= SRA->( GetArea() )
								
								If ( SRA->(DbSeek(cChaveSRE)) .AND. oObjREP:WSNatural( 1 ) .And. oObjREP:WSUser( 1 ) )
									/*/
									ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									³ Grava as informacoes de controle de log de integracao WebServices TSA ³
									ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
									oObjRep:WSUpdRHExp( "SRA" )
								Endif
								RestArea(aAreaSRA)
								
							Endif
						EndIF
					EndIF
					
					If (cOrgCfg == "1") .AND. (cPostoDe != cPostoAte)
						OrgXRescisao(cFilDe, cMatDe, dDataTra)
						OrgXOcupacao(cFilAte, cMatAte, cPostoAte, dDataTra)
					EndIf
					
					//--Ponto de Entrada para Alterar Alguns Campos Apos a transferencia
					//--Variaveis que podem ser Usadas
					//--cEmpAte = Empresa Destino
					//--cFilAte = Filial Destino
					//--cMatAte = Matricula Destino
					//--cCcuAte = C.Custo Destino
					//--lMudaSra = Se havera mudanca no SRA e se ela foi efetivada
					//--Quando transferencia C.Custo/Filial e Empresa com Cgc Diferente fica posicionado no Funcionario
					/*IF ( lGp180TraBlock )
					ExecBlock( "GP180TRA" , .F. , .F. )
					//EndIF*/
					
					If lIntegDef
						FwIntegdef("GPEA180")
					EndIf
					
				End Sequence
				
			End Transaction
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Realiza a gravacao do responsavel no arquivo utilizado  |
			//|pelos modulos do Quality Celerina, caso haja integracao.|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF FindFunction("QT_QUALITY")
				QT_QUALITY(cFilDe,cEmpAnt,cMatDe,cCcDe,cFilAte,cEmpAte,cMatAte,cCcuAte,dDataTra,cDptoDe,cDptoAte)
			Endif
			
			// INTEGRACAO MEDICINA E SEGURANCA DO TRABALHO
			IF FindFunction("MdtTransFicha") .And. (lEmpDif .Or. lFilDif .Or. lMatDif .Or. lCcDif .Or. lDptoDif)
				MdtTransFicha (cEmpAnt, cEmpAte,cFilDe, cFilAte,  cMatDe, cMatAte, cCcDe, cCcuAte, cDptoDe, cDptoAte)
			Endif
			
			// INTEGRACAO MANUTENCAO DE ATIVOS
			IF FindFunction("MNTTRANST1")
				DbSelectArea("ST1")
				ST1->(DbSetOrder(1))
				IF ST1->(DbSeek(cFilDe + cMatDe))
					MNTTRANST1(cEmpAnt, cEmpAte,cFilDe, cFilAte,  cMatDe, cMatAte, cCcDe, cCcuAte)
				EndIF
			EndIF

			//Integração com Gestão de Serviços
			lInteRHAA1	:= IIf(FindFunction("IntegRHAA1"),IntegRHAA1(),.F.)
			If lInteRHAA1
				DbSelectArea("AA1")
				AA1->(DbSetOrder(7))
				If AA1->(DbSeek(cAA1Fil + cMatDe + cFilDe))
					TxTransfAA1(cEmpAnt, cEmpAte,cFilDe, cFilAte,  cMatDe, cMatAte, cCcDe, cCcuAte)
				EndIf
			EndIf

			IF !( lLote )
				Break
			EndIF
			
			IF !( GotoNextRecno( "SRA" , nSraNextRecno , nSraOrder ) )
				Exit
			EndIF
		EndDo
	End Sequence
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Verificando o Relacionamento no RDZ/RD0                     ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IF ( ( nLoops := Len( aSraUpdRelRd0 ) ) > 0 )
		IF ( lLote )
			BarGauge1Set( nLoops )
			BarGauge2Set( nLoops )
		EndIF
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Fecha o SRA para Trabalhar com dois SRA's                   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		SRA->( dbCloseArea() )
		IF ChkFile( "SRA" , NIL , "SRAORIG" )
			SRAORIG->( dbSetOrder( 1 ) )
			nSraOrder := SRAORIG->( IndexOrd() )
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Abre o arquivo da Empresa Destino                           ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			EmpChangeTable( "SRA" , cEmpAte , __cSvEmpAnt , nSraOrder )
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Monta Bloco Para Atualizacao dos Relacionamentos            ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			/*bSraUpdRelRd0 := { || StaticCall(GPEA180,SraUpdRelRd0,;
				nSraOrder ,;
				aSraUpdRelRd0[ nLoop , 1 ],;
				aSraUpdRelRd0[ nLoop , 2 ],;
				aSraUpdRelRd0[ nLoop , 3 ],;
				nLoops;
				);
				}*/
			
			//bSraUpdRelRd0 := { || StaticCall(GPEA180,SraUpdRelRd0, nSraOrder, aSraUpdRelRd0[1,1], aSraUpdRelRd0[1,2], aSraUpdRelRd0[1,3], nLoops)}
			
			bSraUpdRelRd0 := { || SraUpdRelRd0(;
				nSraOrder ,;
				aSraUpdRelRd0[ nLoop , 1 ],;
				aSraUpdRelRd0[ nLoop , 2 ],;
				aSraUpdRelRd0[ nLoop , 3 ],;
				nLoops;
				);
				}
			
			
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Processa para Todos os Funcionarios que possuem Relacionamen³
			³tos														 ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			For nLoop := 1 To nLoops
				IF ( lLote )
					Eval( bSraUpdRelRd0 )
				Else
					MsAguarde( bSraUpdRelRd0 )
				EndIF
			Next nLoop
		EndIF
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Fecha o SRAORIG que sera Reaberto como SRA					 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		IF ( Select( "SRAORIG" ) > 0 )
			SRAORIG->( dbCloseArea() )
		EndIF
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Restaura o arquivo da Empresa Atual                         ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		EmpChangeTable( "SRA" , __cSvEmpAnt , cEmpAte , nSraOrder )
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Restaura o SRA                                              ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		IF ( Select( "SRA" ) == 0 )
			ChkFile( "SRA" )
		Else
			DbSelectArea("SRA")
		EndIF
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Restaura o Filtro de Entrada                                             ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		//executa se nao estiver no processo de aprovacao de uma solicitacao do Portal Protheus
		If !IsInCallStack("TCFA040")
			IF ( lLote )
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Finaliza Filtro da Transfrencia Em Lote                                  ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				EndFilBrw( "SRA" , aNewIndexSRA )
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Restaurando Filtro da Transfrencia Em Lote                               ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				//	SRA->( Eval( bNewFiltroBrw ) )
			Else
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Finaliza Filtro de Entrada                                               ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				EndFilBrw( "SRA" , aIndexSRA )
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Restaurando Filtro de Entrada                                            ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				//	SRA->( Eval( bFiltraBrw ) )
			EndIF
		EndIF
	EndIF
	//--Fecha os arquivos abertos que nao se referem ao Modulo
	nLoops := Len( aFilesOpen )
	For nLoop := 1 To nLoops
		( aFilesOpen[nLoop] )->( dbCloseArea() )
	Next nLoop
	
	//--Fecha os arquivos da empresa Destino
	If ( lEmpDif )
		nLoops := Len(aFilesTransf)
		For nLoop := 1 To nLoops
			fFecEmpresa( aFilesTransf[nLoop,1] )
		Next nLoop
	Endif
	
	IF !Empty( aLogTransf )
		//"Ocorreram Inconsistências durante o Processo de Transferência. Deseja consultar o LOG"
		//Atenção
		IF ( MsgNoYes( OemToAnsi( "" )  , OemToAnsi( "" ) ) )
			//"Log de Ocorrencias"
			bMakeLog := { || fMakeLog( { aLogTransf } ,  { "" } , NIL , .T. , FunName() , NIL , "G" , "L" , NIL , NIL ) }
			MsAguarde( bMakeLog , OemToAnsi( "" ) )
		EndIF
	Else
		If IsInCallStack("TCFA040") //executa se for uma requisicao via Portal Protheus
			oReturn := 0
		EndIf
	EndIF
	
Return( NIL )

Static Function SraUpdRelRd0( nOrderSRA , nSraRecnoDe , cMatDestino , nRd0Recno , nProcRegua )
	
	Local lUndoRelRdz	:= .T.
	
	Local cRd0Codigo
	Local cBkpEmpAnt
	Local cBkpFilAnt
	Local cChaveEntidade
	
	Begin Sequence
		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Se nao Consegui Abir SRA da Empresa Origem, abandona        ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		IF ( Select( "SRAORIG" ) == 0 )
			Break
		EndIF
		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Posiciona no Funcionario Para Efetuar o Relacionamento      ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		SRAORIG->( dbGoto( nSraRecnoDe ) )
		If !(IsBlind())
			IF !( lLote )
				//Incrementa a MsAguarde()
				MsProcTxt( OemToAnsi( "Atualizando Relacionamentos do: " + "SRA" ) ) 			//"Atualizando Relacionamentos do: "
			Else
				//Incrementa a Proc2BarGauge()
				IncPrcG1Time(	SRAORIG->( AllTrim( RA_FILIAL + " / " + RA_MAT + " / " + RA_NOME ) )	,;	//01 -> Inicio da Mensagem
				nProcRegua																,;	//02 -> Numero de Registros a Serem Processados
				cTimeIni																,;	//03 -> Tempo Inicial
				.F.																		,;	//04 -> Defina se eh um processo unico ou nao ( DEFAULT .T. )
				-2																		,;	//05 -> Contador de Processos
				1	 																	 ;	//06 -> Percentual para Incremento
				)
				IncProcG2( OemToAnsi( "Atualizando Relacionamentos do: " + "SRA" ) )	//"Atualizando Relacionamentos do: "
			EndIF
		EndIf
		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Posiciona no Cadastro de Pessoas/Participantes              ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		RD0->( dbGoto( nRd0Recno ) )
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Obtem o Codigo do RD0 para o Funcionario                    ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		cRd0Codigo := RD0->RD0_CODIGO
		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Salva Empresa e Filial                                      ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		cBkpEmpAnt	:= cEmpAnt
		cBkpFilAnt	:= cFilAnt
		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Verifica se ira desfazer o Relacionamento antigo            ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		IF ( lEmpDif )
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Na transferencia de Empresas sempre mantem o  relacionamento³
			³antigo                									 	 ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			lUndoRelRdz := .F.
		ElseIF ( lCcDif )
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Se for Apenas Transferencia de Centro de Custo nao desfaz  o³
			³relacionamento antigo										 ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			IF ( !( lFilDif ) .and. !( lMatDif ) )
				lUndoRelRdz := .F.
			EndIF
		ElseIF ( lDptoDif )
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Se for Apenas Transferencia de Departamento nao desfaz  o   ³
			³relacionamento antigo										 ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			IF ( !( lFilDif ) .and. !( lMatDif ) )
				lUndoRelRdz := .F.
			EndIF
		ElseIf ( lPostoDif )
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Se for Apenas Transferencia de Departamento nao desfaz  o   ³
			³relacionamento antigo										 ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			IF ( !( lFilDif ) .and. !( lMatDif ) )
				lUndoRelRdz := .F.
			EndIF
		EndIF
		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Removendo o Antigo Relacionamento                           ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		IF ( lUndoRelRdz )
			UndoRelRdz( "SRA" , cRd0Codigo , __cSvEmpAnt , cFilDe )
		EndIF
		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Atualiza Empresa e Filial para Pesquisa do Funcionario		 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		cEmpAnt := cEmpAte
		cFilAnt := cFilAte
		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Posiciona no Funcionario                                    ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		cChaveEntidade := ( xFilial( "SRA" , cFilAte ) + cMatDestino )
		IF SRA->( MsSeek( cChaveEntidade , .F. ) )
			
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Restaura Empresa e Filial                                   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			cEmpAnt := cBkpEmpAnt
			cFilAnt := cBkpFilAnt
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Atualiza Cadastro Pessoas x Entidades                       ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			EntUpdateRd0(	cRd0Codigo			,;	//01 -> Codigo da Pessoa
			"SRA"				,;	//02 -> Entidade Relacionada
			cChaveEntidade		,;	//03 -> Chave da Entidade
			nOrderSRA			,;	//04 -> Ordem
			SRA->( Recno() )	,;	//05 -> Recno da Entidade
			cEmpAte				,;	//06 -> Codigo da Empresa
			cFilAte				,;	//07 -> Codigo da Filial
			"1"					,;	//08 -> Conteudo para o RD0_TIPO "1"=Interno;"2"=Externo
			.F.					,;	//09 -> Se Atualiza as Entidades Relacionadas
			NIL					,;	//10 -> Array com as Entidades para o Before Update
			NIL					,;	//11 -> Se Executa algo depois do Update
			aRelation			 ;	//12 -> Array com as Estruturas para o Update
			)
			
		EndIF
		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Restaura Empresa e Filial                                   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		cEmpAnt := cBkpEmpAnt
		cFilAnt := cBkpFilAnt
		
	End Sequence
	
Return( NIL )

Static Function Check_Cgc( aSRA_Aux, aSvSRA_Aux ) 

Local aArea        := GetArea() 
Local aAreaSM0    := SM0->( GetArea() )
Local aCGC_Aux    := {} 
Local cCGCDe       := ""
Local cCGCPara     := ""
Local cNomeDe       := ""
Local cNomePara := ""
Local nPos        := 0 
Local nX           := 0 

For nX:= 1 to Len(aSRA_Aux)
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Obtem o CGC da Empresa de Origem                                   ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If SM0->( dbSeek( __cSvEmpAnt + aSvSRA_Aux[nX,2]  ) ) 
        cCgcDe   := SM0->M0_CGC
        cNomeDe  := SM0->M0_FILIAL 
    Endif 
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Obtem o CGC da Empresa de Destino                                   ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    IF SM0->( dbSeek( aSRA_Aux[nX,1] + aSRA_Aux[nX,2]  ) )
        cCgcPara     := SM0->M0_CGC    
        cNomePara     := SM0->M0_FILIAL 
    EndIF 
    
    If ( nPos:= Ascan(aCGC_Aux,{|x| x[1]+x[3] == (__cSvEmpAnt + aSvSRA_Aux[nX,2] )  + ( aSRA_Aux[nX,1] + aSRA_Aux[nX,2]  )    }   )     ) <= 0 
        aadd(aCGC_aux, {__cSvEmpAnt + aSvSRA_Aux[nX,2], ;    //1- Empresa+Filial De 
                                               cNomeDe , ;  
                                               cCgcDe  , ;
                        aSRA_Aux[nX,1] + aSRA_Aux[nX,2],;    //4- Empresa+Filial De 
                                              cNomePara ,;
                                               cCgcPara  } ) 
    Endif 
    
Next nX 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura os Dados de Entrada                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
( RestArea( aAreaSM0 ) , RestArea( aArea ) )
Return( aCGC_Aux ) 


/*{Protheus.doc} BscFxSal
Pega tabela salarial
@author Henrique Madureira
@since 
@Project MAN0000007423039_EF_003
*/
Static Function BscFxSal(cCodVg, cFilP, cFlSolSqs, cCdSolSqs,cHrMes)

	Local cQuery 	:= ""
	Local cAliRB6	:= "INFRB6"
	Local aAux		:= {}
	
	Default cFlSolSqs 	:= ""
	Default cCdSolSqs 	:= ""
	Default cHrMes		:= 0

	cFilRb6 := U_F0600402( cFilP, "RB6")
	cFilSq3 := U_F0600402( cFilP, "SQ3")
	
	cQuery := "SELECT RB6.RB6_VALOR,RB6.RB6_FAIXA,RB6.RB6_NIVEL FROM " + RetSqlName("RBR") + " RBR "
	cQuery += "INNER JOIN " + RetSqlName("RB6") + " RB6 "
	cQuery += "ON RB6.RB6_FILIAL = '" + cFilRb6 + "' AND "
	cQuery += "RB6.RB6_TABELA     = (SELECT Q3_TABELA FROM " + RetSqlName("SQ3") + " "
	cQuery += "				WHERE  Q3_FILIAL = '" + cFilSq3 + "' AND Q3_CARGO = '" + cCodVg + "' AND D_E_L_E_T_ = ' ') "
	cQuery += "AND RB6.RB6_NIVEL  = (SELECT Q3_TABNIVE FROM " + RetSqlName("SQ3") + " "
	cQuery += "				WHERE  Q3_FILIAL = '" + cFilSq3 + "' AND Q3_CARGO = '" + cCodVg + "' AND D_E_L_E_T_ = ' ') "
	cQuery += "AND RB6.RB6_DTREF = RBR.RBR_DTREF "
	cQuery += "AND RB6.D_E_L_E_T_ = ' '  "
	cQuery += "WHERE RBR.RBR_FILIAL = '" + cFilRb6 + "' "
	cQuery += "AND RBR.RBR_TABELA = (SELECT Q3_TABELA FROM " + RetSqlName("SQ3") + " WHERE  Q3_FILIAL = '" + cFilSq3 + "' AND Q3_CARGO = '" + cCodVg + "' AND D_E_L_E_T_ = ' ') "
	cQuery += "AND RBR.RBR_APLIC = '1' "
	cQuery += "AND RBR.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY RB6.RB6_NIVEL, RB6.RB6_FAIXA "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliRB6)
	
	DbSelectArea(cAliRB6)
	While ! (cAliRB6)->(EOF())
		AADD(aAux, {(cAliRB6)->RB6_NIVEL,(cAliRB6)->RB6_FAIXA,(((cAliRB6)->RB6_VALOR * cHrMes) / 220)})
		(cAliRB6)->(DbSkip())
	End
	(cAliRB6)->(DbCloseArea())

Return aAux

Static Function ConsCc(cFilAte,cCcuAte,cCcDesc)

	Local aArea		:= GetArea()
	Local aTransf	   := {}
	Local cFilAux	   := ""
	Local cEmp_Aux 	:= ""
	Local cFil_aux	:= ""
	Local cDesccc	   := ""
	Local lConsCcOk	:= .T.
	Local lTransfUni := IsInCallStack( "fTransfUnico" )
	Local lMsBlql		:= .F.

	If !lTransfUni
		cEmpAte	:= If( oGetSRA2:LEDITLINE, M->M_EMPRESA, oGetSRA2:aCols[oGetSRA2:nAt, _EMPRES ] )
		cFilAte	:= If( oGetSRA2:LEDITLINE, M->RA_FILIAL, oGetSRA2:aCols[oGetSRA2:nAt, _FILIAL ] )
	Else
		cEmpAte	:= oGetTran:aCols[1,1]
		cFilAte	:= oGetTran:aCols[1,3]
		cEmp_Aux 	:= cEmpAte
		cFil_aux	:= cFilAte
	Endif

	cEmpAnt 	:= cEmpAte
	lEmpDif	:= ( __cSvEmpAnt # cEmpAte )
	cCc 		:= &(ReadVar())

	Begin Sequence
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Centro de Custo nao Pode Estar Vazio                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF !( lConsCcOk := !Empty( cCc ) )
			Help(" ",1,"A180CCNEX") 		//--  Centro de custo não cadastrado.
			Break
		EndIF

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se no arquivo CTT Existe Centro de Custo          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF ( lEmpDif )  .OR. lTransfUni
			IF !( lConsCcOk := fAbrEmpresa( cAliasCc , 1 ) )
				Break
			EndIF
			__cFil := FwxFilial("CTT",cFilAte,FWModeAccess("CTT",1),FWModeAccess("CTT",2),FWModeAccess("CTT",3))
		Else
			dbSelectArea( cAliasCc )
			__cFil := cFilAux := xFilial( cAliasCc , cFilAte )
		EndIF

		If	!(lEmpDif .And. (Len(cFilDe)  <> Len(cFilAte)))
			If !( lConsCcOk := CTB105CC() )
				Break
			EndIf
		Endif

		IF !lEmpDif
			(cAliasCc)->( dbSetOrder(RetOrdem("CTT","CTT_FILIAL+CTT_CUSTO")) )
		EndIf

		CTT->( dbSetOrder(1) )
		IF ( lConsCcOk := ( If(lEmpDif,"GPE","")+cAliasCc )->( dbSeek( RHTamFilial(cFilAte) + cCc , .F. ) ) )
			__cFil := cFilAux := cFilAte
		ElseIf!( lConsCcOk := ( If(lEmpDif,"GPE","")+cAliasCc )->( dbSeek( RHTamFilial(__cFil) + cCc , .F. ) ) )
			Help(" ",1,"A180CCNEX")			//--  Centro de custo não cadastrado.
			Break
		EndIf
		
		lMsBlql		:= ( If(lEmpDif,"GPE","")+cAliasCc )->( FieldPos( "CTT_MSBLQL" ) ) != 0
		If 	lMsBlql .And. ( If(lEmpDif,"GPE","")+cAliasCc )->CTT_MSBLQL == "1"
			Help(" ",1,"REGBLOQ")
			lConsCcOk := .F.
			Break
		EndIF

		cDesccc:= DescCc( cCc , __cFil , NIL , lEmpDif )

		if oGetSRA2:LEDITLINE
			If !lTransfUni
				IF aCols[oGetSRA2:nAt , _CCUSTO]<> cCc
					aCols[oGetSRA2:nAt , _COLBMP] 	:= "BR_AZUL"
				Endif

				aCols[oGetSRA2:nAt , _DCUSTO] :=  cDesccc
				UpdFilResp(oGetSRA2, cFilAte, cCC, oGetSRA2:nAt, _CCUSTO)
				If !IsBlind()
					oGetSRA2:Refresh()
					oGetSRA1:Refresh()
				EndIf
			Else
				oGetTran:aCols[1, 6] :=  cDesccc
				UpdFilResp(oGetTran, cFilAte, "", 0, 0)
				If !IsBlind()
					oGetTran:Refresh()
				EndIf
				cEmpAte 	:= cEmp_Aux
				cFilAte 	:= cFil_Aux
			Endif
		Else
			If !lTransfUni
				IF oGetSRA2:aCols[oGetSRA2:nAt , _CCUSTO]<> cCc
					oGetSRA2:aCols[oGetSRA2:nAt , _COLBMP] 	:= "BR_AZUL"
				Endif

				oGetSRA2:aCols[oGetSRA2:nAt , _DCUSTO] :=  cDesccc
				UpdFilResp(oGetSRA2, cFilAte, cCC, oGetSRA2:nAt, _CCUSTO)
				If !IsBlind()
					oGetSRA2:Refresh()
					oGetSRA1:Refresh()
				EndIf
			Else
				oGetTran:aCols[1, 6] :=  cDesccc
				UpdFilResp(oGetTran, cFilAte, "", 0, 0)
				If !IsBlind()
					oGetTran:Refresh()
				EndIf
				cEmpAte 	:= cEmp_Aux
				cFilAte 	:= cFil_Aux
			Endif
		endIf
		lCcDif := .T.
		SetMemVar("RA_DESCCC",cDesccc)
	End Sequence

	IF ( lEmpDif )
		fFecEmpresa( cAliasCc )
	EndIF

	dbSelectArea( cAliasCc )
	RestArea( aArea )
Return( lConsCcOk )

Static Function fFecEmpresa( cAlias )

IF Select("GPE"+cAlias) > 0
	("GPE"+cAlias)->(dbCloseArea())
EndIF

Return( .T. )

Static Function UpdFilResp(oGet, cFilInf, cConteudo, nPosUpd, nPosDep)

Local nPosFil  := GdFieldPos("RA_FILIAL", aSRAHeader), nPosMat := GdFieldPos("RA_MAT", aSRAHeader)
Local nPosRetT := GdFieldPos("QB_RETTIT", oGet:aHeader), nPosSubT := GdFieldPos("QB_SUBTIT", oGet:aHeader)
Local nPosFilT := GdFieldPos("QB_FILTIT", oGet:aHeader), nPosMatT := GdFieldPos("QB_MATTIT", oGet:aHeader)
Local nPosNom  := GdFieldPos("QB_NOMTIT", oGet:aHeader)
Local aAreaSQB := SQB->(GetArea()), aArea := GetArea()

If nPosFilT > 0
	SQB->(DbSetOrder(1))
	SQB->(DbSeek(xFilial("SQB", cFilInf) + cConteudo))

	oGet:aCols[oGet:nAt, nPosFilT] := SQB->QB_FILTIT
	oGet:aCols[oGet:nAt, nPosMatT] := SQB->QB_MATTIT
	oGet:aCols[oGet:nAt, nPosNom] := ""
	If ! Empty(SQB->(QB_FILTIT + QB_MATTIT))
		oGet:aCols[oGet:nAt, nPosNom] := Posicione('SRA',1, SQB->(QB_FILTIT + QB_MATTIT),'RA_NOME')
	EndIf

	//-- Indica atualização dos campos Retira Titularidade e/ou Atribui Titularidade
	If nPosUpd > 0
		oGet:aCols[nPosUpd][nPosRetT] := oGet:aCols[nPosUpd][nPosSubT] := "2"

		//-- Caso o departamento tenha sido alterado e a filial+matricula for igual ao responsável coloca em branco
		//-- Obrigando ao usuário confirmar a ação
		If 	oGetSRA1:aCols[nPosUpd][nPosDep] <> cConteudo .And.;
			oGetSRA1:aCols[nPosUpd, nPosFilT] + oGetSRA1:aCols[nPosUpd, nPosMatT] ==;
			aSRACols[nPosUpd, nPosFil] + aSRACols[nPosUpd, nPosMat]
			oGet:aCols[nPosUpd][nPosRetT] := oGet:aCols[nPosUpd][nPosSubT] := " "
		EndIf
	EndIf
EndIf

RestArea(aAreaSQB)
RestArea(aArea)

Return 

Static Function ConsDepto(cFilAte,cDptoAte,cDptoDesc)

	Local aArea			:= GetArea()
	Local aTransf		:= {}
	Local cFilAux		:= ""
	Local cEmp_Aux 		:= ""
	Local cFil_aux		:= ""
	Local lConsDeptoOk	:= .T.
	Local lTransfUni	:= IsInCallStack( "fTransfUnico" )
	Local cDescDepto    := ""
	Local cFilDept		:= ""
	Local lMsBlql		:= .F.

	If !lTransfUni
		cEmpAte		:= oGetSRA2:aCols[oGetSRA2:nAt, _EMPRES ]
		cFilAte		:= oGetSRA2:aCols[oGetSRA2:nAt, _FILIAL ]
	Else
		cEmpAte		:= oGetTran:aCols[1,1]
		cFilAte		:= oGetTran:aCols[1,3]
		cEmp_Aux 	:= cEmpAte
		cFil_aux	:= cFilAte
	Endif

	cEmpAnt 	:= cEmpAte
	lEmpDif		:= ( __cSvEmpAnt # cEmpAte )
	cDepto 		:= &(ReadVar())

	Begin Sequence

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Depto nao Pode Estar Vazio                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF cOrgCfg == "1" .And. !( lConsDeptoOk := !Empty( cDepto))
			Help(" ",1,"A180DEPTONEX")       		 							//-- Departamento informado invalido ou nao cadastrado.
			Break
		EndIF

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existo Depto                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cOrgCfg == "1"
			IF ( lEmpDif ) .OR. lTransfUni
				IF !( lConsDeptoOk := fAbrEmpresa("RDK", 1 ) )
					Break
				EndIF
				IF !( lConsDeptoOk := fAbrEmpresa("RD4", 1 ) )
					Break
				EndIF
				__cFil 		:= FwxFilial("RD4",cFilAte,FWModeAccess("RD4",1),FWModeAccess("RD4",2),FWModeAccess("RD4",3))
				cFilDept 	:= FwxFilial("SQB",cFilAte,FWModeAccess("SQB",1),FWModeAccess("SQB",2),FWModeAccess("SQB",3))
			Else
				dbSelectArea( "RD4" )
				__cFil := cFilAux := xFilial( "RD4" , cFilAte )
				cFilDept := fWxFilial("SQB", cFilAte)
			EndIF

			dbSelectArea("RD4")
			RD4->( dbSetOrder(RetOrdem("RD4", "RD4_FILIAL+RD4_EMPIDE+RD4_FILIDE+RD4_CODIDE")) )

			dbSelectArea("RDK")
			RDK->( dbSetOrder(RetOrdem("RDK","RDK_FILIAL+RDK_CODIGO+RDK_HIERAR+RDK_TIPO")) )

			If lConsDeptoOk := RD4->( dbSeek(__cFil + cEmpAte + cFilDept + cDepto) ) 
				lConsDeptoOk := .F.
				While RD4->( !Eof() ) .AND. (RD4->(RD4_FILIAL+RD4_EMPIDE+RD4_FILIDE+RD4_CODIDE) == __cFil + cEmpAte + cFilDept + cDepto)					
					RDK->( dbGoTop() )
					If RDK->( dbSeek(xFilial("RDK") + RD4->RD4_CODIGO + "11") )
						lConsDeptoOk := .T.
						cDescDepto := RD4->RD4_DESC
						Exit
					EndIf

					RD4->( dbSkip() )
				EndDo
			EndIf

			IF cOrgCfg == "1" .And. !( lConsDeptoOk )
				Help(" ",1,"A180DEPTONEX")										//-- Departamento informado invalido ou nao cadastrado.
				Break
			EndIF
			
			lMsBlql		:= RD4->( FieldPos( "RD4_MSBLQL" ) ) != 0
			If lMsBlql .And. RD4->RD4_MSBLQL == "1"
				Help(" ",1,"REGBLOQ")
				lConsDeptoOk	:= .F.
				Break
			EndIf

		Else			
			IF ( lEmpDif ) .OR. lTransfUni
				IF !( lConsDeptoOk := fAbrEmpresa("SQB", 1 ) )
					Break
				EndIF
				__cFil := FwxFilial("SQB",cFilAte,FWModeAccess("SQB",1),FWModeAccess("SQB",2),FWModeAccess("SQB",3))
			Else
				dbSelectArea( "SQB" )
				__cFil := cFilAux := xFilial( "SQB" , cFilAte )
			EndIF

			IF  !( lConsDeptoOk := ( If(lEmpDif,"GPE","")+"SQB" )->( dbSeek( RHTamFilial(__cFil) + cDepto , .F. ) ) )
				Help(" ",1,"A180DEPTONEX")										//-- Departamento informado invalido ou nao cadastrado.
				Break
			EndIF

			lMsBlql	:= (If(lEmpDif,"GPE","")+"SQB" )->( FieldPos( "QB_MSBLQL" ) ) != 0
			If lMsBlql .And. (If(lEmpDif,"GPE","")+"SQB" )->QB_MSBLQL == "1"
				Help(" ",1,"REGBLOQ")
				lConsDeptoOk	:= .F.
				Break
			EndIf
		EndIf

		if oGetSRA2:LEDITLINE

			If !lTransfUni
				aCols[oGetSRA2:nAT , _DDEPT ] :=  If(cOrgCfg == "1", cDescDepto, fDesc("SQB",  cDepto, "QB_DESCRIC"))
				IF aCols[oGetSRA2:nAt , _DEPTO]<> cDepto
					aCols[oGetSRA2:nAt , _COLBMP] 	:= "BR_AZUL"
				Endif
				If !IsBlind()
					oGetSRA2:Refresh()
					oGetSRA1:Refresh()
				EndIf
			Else
				aCols[1, 8 ] := If(cOrgCfg == "1", cDescDepto, fDesc("SQB",  cDepto, "QB_DESCRIC"))
				UpdFilResp(oGetTran, cFilAte, "", 0, 0)
				If !IsBlind()
					oGetTran:Refresh()
				EndIf
				cEmpAte 	:= cEmp_Aux
				cFilAte 	:= cFil_Aux
			Endif
		Else
			If !lTransfUni
				oGetSRA2:aCols[oGetSRA2:nAT , _DDEPT ] :=  If(cOrgCfg == "1", cDescDepto, fDesc("SQB",  cDepto, "QB_DESCRIC"))
				IF oGetSRA2:aCols[oGetSRA2:nAt , _DEPTO]<> cDepto
					oGetSRA2:aCols[oGetSRA2:nAt , _COLBMP] 	:= "BR_AZUL"
				Endif
				If !IsBlind()
					oGetSRA2:Refresh()
					oGetSRA1:Refresh()
				EndIf
			Else
				oGetTran:aCols[1, 8 ] := If(cOrgCfg == "1", cDescDepto, fDesc("SQB",  cDepto, "QB_DESCRIC"))
				UpdFilResp(oGetTran, cFilAte, "", 0, 0)
				If !IsBlind()
					oGetTran:Refresh()
				EndIf
				cEmpAte 	:= cEmp_Aux
				cFilAte 	:= cFil_Aux
			Endif
		endIf

		lDeptoDif := .T.

	End Sequence

	IF ( lEmpDif )
		fFecEmpresa("SQB" )
	EndIF

	dbSelectArea( "SQB" )

	RestArea( aArea )

Return( lConsDeptoOk )

Static Function ConsPosto()
	Local aArea			:= GetArea()
	Local cFilAux		   := ""
	Local cAliasRCL    	:= "RCL"
	Local nPos			:= 0
	Local lConsPostoOk	:= .T.
	Local lOcupalimite	:= .F.
	Local nQtdeOcupante	:= 0 						//-- Qte de ocupantes do posto
	Local cKeySeek
	Local aTransf		:= {}
	Local lTransfUni	:= IsInCallStack( "fTransfUnico" )
	Local nPosEmpGd
	Local nPosFilGd
	Local nPosDepGd
	Local lMsBlql		:= .F.

	Local cQryQ3 		:= ''
	Local cAliasSQ3 	:= "QSQ3"

	If (cOrgCfg # "1")
		Return( lConsPostoOk )
	Endif

	If lTransfUni .And. ValType(oGetTran) == "O"
		nPosEmpGd	:= GdFieldPos("M_EMPRESA", oGetTran:aHeader)
		nPosFilGd	:= GdFieldPos("RA_FILIAL", oGetTran:aHeader)
		nPosDepGd	:= GdFieldPos("RA_DEPTO", oGetTran:aHeader)
		cEmpAte		:= oGetTran:aCols[oGetTran:nAt, nPosEmpGd ]
		cFilAte		:= oGetTran:aCols[oGetTran:nAt, nPosFilGd ]
		cDeptoAte	:= oGetTran:aCols[oGetTran:nAt, nPosDepGd ]
	Else
		cEmpAte		:= oGetSRA2:aCols[oGetSRA2:nAt, _EMPRES ]
		cFilAte		:= oGetSRA2:aCols[oGetSRA2:nAt, _FILIAL ]
		cDeptoAte := oGetSRA2:aCols[oGetSRA2:nAt, _DEPTO]
	EndIf

	cEmpAnt 	:= cEmpAte
	lEmpDif		:= ( __cSvEmpAnt # cEmpAte )
	cPosto 		:= &(ReadVar())
	Begin Sequence

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existo Posto                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF ( lEmpDif )
			IF !( lConsPostoOk := fAbrEmpresa("RCL", 1 ) )
				Break
			EndIF
			cAliasRCL:= "GPERCL"
		Else
			dbSelectArea( "RCL" )
			__cFil := cFilAux := xFilial( "RCL" , cFilAte )
		EndIF

		DbSelectArea(cAliasRCL)

		If Empty(cDeptoAte)
			DbSetOrder(2)
			cKeySeek:= RHTamFilial(__cFil) + cPosto
			cKeySeek2:= RHTamFilial(cFilAte) + cPosto
		Else
			DbSetOrder(1)
			cKeySeek:= RHTamFilial(__cFil) + cDeptoAte + cPosto
			cKeySeek2:= RHTamFilial(cFilAte) + cDeptoAte + cPosto
		EndIf

		IF !( lConsPostoOk := ((( cAliasRCL )->( dbSeek(cKeySeek  , .F. ) ) ) .Or. ( cAliasRCL )->( dbSeek(cKeySeek2  , .F. ) ) ) )
			Help(" ",1,"A180POSTONEX") 										//-- Posto informado invalido ou nao cadatrado.
			Break
		EndIF

		lMsBlql		:= (cAliasRCL)->( FieldPos( "RCL_MSBLQL" ) ) != 0
		If lMsBlql .And. (cAliasRCL)->RCL_MSBLQL == "1"
			Help(" ",1,"REGBLOQ")
			lConsPostoOk := .F.
			Break
		EndIf

		M->RA_DEPTO := ( cAliasRCL )->RCL_DEPTO
		M->RA_POSTO := cPosto

		IF oGetSRA1:aCols[oGetSRA2:nAt, _POSTO]<> cPosto .Or. lEmpDif	

			If  ( cAliasRCL )->RCL_STATUS == "3"  .OR.  (cAliasRCL )->RCL_STATUS ==  "4"
				MsgAlert( OemToAnsi("O Posto esta com  Status 'Congelado' ou 'Cancelado'.") + CRLF + ;		// "O Posto esta com  Status 'Congelado' ou 'Cancelado'."
				  		  OemToAnsi("Consulte o administrador do sistema.") + CRLF , ;		// "Consulte al administrador do sistema."
			  	  		  OemToAnsi("Atencao") ) 				// "Atencao"
	 			lConsPostoOk := .F.
	 			Break
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica qtde de ocupantes no Posto. Nao deve permitir ocupacao³
			//³ultrapassando o limite de ocupantes                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aEval(oGetSRA2:aCols, {|x| nQtdeOcupante+= If( ( cEmpAte +__cFil + cPosto ) ==x[_EMPRES ] + x[_FILIAL] +x[_POSTO] ,1,0) } )

			nQtdeOcupante +=  ( cAliasRCL )->RCL_OPOSTO

			If ( nQtdeOcupante  + 1 ) > ( cAliasRCL )->RCL_NPOSTO
				MsgAlert( OemToAnsi("Excedeu a quantidade maxima de ocupantes permitida para o posto.") + CRLF  + ;			// "Excedeu a quantidade maxima de ocupantes permitida para o posto."
						  OemToAnsi("Consulte o administrador do sistema.") + CRLF+CRLF , ;		// "Consulte al administrador do sistema."
			  			  OemToAnsi("Atencao") ) 						// "Atencao"
				lConsPostoOk := .F.
				Break
			Endif

			cDeptoAte  := ( cAliasRCL )->RCL_DEPTO
			cPostoAte  := ( cAliasRCL )->RCL_POSTO

			cQryQ3 := "SELECT Q3_DESCSUM FROM "
			cQryQ3 +=  RetSqlName("SQ3")
			cQryQ3 += " WHERE (Q3_FILIAL = '" + xFilial("SQ3") + "' OR Q3_FILIAL = '" + FwxFilial("SQ3",cFilAte) + "') AND "
			cQryQ3 += " Q3_CARGO = '" + ( cAliasRCL )->RCL_CARGO + "' AND D_E_L_E_T_ = ' ' "

			cQryQ3 := ChangeQuery(cQryQ3)
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryQ3), cAliasSQ3, .F., .T.)

			If oGetSRA2:LEDITLINE
				aCols[oGetSRA2:nAt , _DEPTO] := cDeptoAte
				aCols[oGetSRA2:nAt , _POSTO] := cPostoAte
				aCols[oGetSRA2:nAt , _DPOSTO] := iif(!(cAliasSQ3)->(EOF()),(cAliasSQ3)->Q3_DESCSUM,'')
			Else
				oGetSRA2:aCols[oGetSRA2:nAt , _DEPTO] := cDeptoAte
				oGetSRA2:aCols[oGetSRA2:nAt , _POSTO] := cPostoAte
				oGetSRA2:aCols[oGetSRA2:nAt , _DPOSTO] := iif(!(cAliasSQ3)->(EOF()),(cAliasSQ3)->Q3_DESCSUM,'')
			EndIf

			(cAliasSQ3)->(dbCloseArea())

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza os campos na Get (como gatilho)           			    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lTransfUni
				if oGetSRA2:LEDITLINE
					aCols[oGetSRA2:nAt , _COLBMP] 	:= "BR_AZUL"
				Else
					oGetSRA2:aCols[oGetSRA2:nAt , _COLBMP] 	:= "BR_AZUL"
				endif
			EndIf
		
			If !IsBlind()
				oGetSRA2:ForceRefresh()
				oGetSRA1:ForceRefresh()
			EndIf
			lPostoDif := .T.
		EndIf
	End Sequence

	IF ( lEmpDif )
		fFecEmpresa("RCL" )
	EndIF

	dbSelectArea( "RCL" )

	RestArea( aArea )
Return lConsPostoOk

Static Function ConsMat( aCols_Aux, nLinAtu, lShowMsg, aLog, lFecEmpresa )

	Local aArea			:= GetArea()
	Local aAreaSRA		:= SRA->( GetArea() )
	Local aPerAtual		:= {}
	Local cName			:= ""
	Local cMsg			:= ""
	Local cMsgFk		:= ""
	Local cAnoMesAb		:= ""
	Local lRet			:= .T.
	Local nPos			:= 0
	Local lTeste		:= .T.
	Local cPic			:= ""
	Local nX            := 0

	DEFAULT lShowMsg	:= .T.
	DEFAULT aLog		:= {}
	DEFAULT lFecEmpresa	:= .T.

	If IsInCallStack("GP180LinOk") .Or. lRobo .Or. !oGetSRA2:lEditLine
		cEmpAte		:= aCols_Aux[nLinAtu, _EMPRES ]
		cFilAte		:= aCols_Aux[nLinAtu, _FILIAL ]
		cCcuAte		:= aCols_Aux[nLinAtu, _CCUSTO ]
		cProces		:= aCols_Aux[nLinAtu, _PROCES ]
		cDeptoAte	:= aCols_Aux[nLinAtu, _DEPTO  ]
		If (cOrgCfg == "1")
			cPostoAte := aCols_Aux[nLinAtu, _POSTO  ]
		Endif
	Else
		cEmpAte		:= M->M_EMPRESA
		cFilAte		:= M->RA_FILIAL
		cCcuAte		:= M->RA_CC
		cProces		:= M->RA_PROCES
		cDeptoAte	:= M->RA_DEPTO
		If (cOrgCfg == "1")
			cPostoAte := M->RA_POSTO
		Endif
	EndIf
	cProcesDe	:= aSvTransfCols[nLinAtu, _PROCES ]
	cCcDe		:= aSvTransfCols[nLinAtu, _CCUSTO ]

	cMatAte := If( IsInCallStack("GP180LinOk") .Or. lRobo, aCols_Aux[nLinAtu, _MATRIC], &(ReadVar()) )

	Begin Sequence

		If  ( cMatAte   <> aSvTransfCols[nLinAtu,_MATRIC]) .AND. ;
			!(cEmpAte   <> aSvTransfCols[nLinAtu,_EMPRES]) .AND. ;
			!(cFilAte   <> aSvTransfCols[nLinAtu,_FILIAL])

			If ( __lFkInUse )
				#IFNDEF STR0074
					#DEFINE STR0074 "Transferencia de matriculas nao e permitida para quem utiliza Integridade Referencial"
				#ENDIF
				If lGestPubl
					cMsgFk := "Relotação de matriculas nao e permitida para quem utiliza Integridade Referencial"										//"Relotação de matriculas nao e permitida para quem utiliza Integridade Referencial"
				Else
					cMsgFk := STR0074										//"Transferencia de matriculas nao e permitida para quem utiliza Integridade Referencial"
				Endif
				Help(" ", 1, OemToAnsi("Atencao"),, OemToAnsi(cMsgFk), 1, 0 )	//"Atencao!"
				lRet := .F.
				Break
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Busca o periodo aberto atual                                 ³
			//³ Comparar data de admissao com periodo aberto, se for difente ³
			//³ nao deixa trocar matricula                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If MesAno(M->RA_ADMISSA) # MesAno(dDataTra)
				If ( lShowMsg )
					Help(" ", 1, OemToAnsi("Atencao"),, OemToAnsi("Transferencia de matriculas so e permitida para funcionarios admitidos dentro do mes de competencia."), 1, 0 )	//"Atencao!"###"Transferencia de matriculas so e permitida para funcionarios admitidos dentro do mes de competencia."
				Else
					aAdd( aLog, __cSvEmpAnt + " " + cFilDe + " " + cMatDe +"-" + aSvTransfCols[nLinAtu,_NOME])
					aAdd( aLog , "Transferencia de matriculas so e permitida para funcionarios admitidos dentro do mes de competencia." )
				EndIf
				lRet := .F.
				Break
			EndIf

			If lFilDif .or. lEmpDif
				If SRG->(dbSeek(M->RA_FILIAL+M->RA_MAT+MesAno(dDataTra)))
					Help(" ", 1, OemToAnsi("Atencao"),, OemToAnsi("Funcionario tem demissao calculada no mes, e por este motivo nao foi transferido."), 1, 0 )//"Funcionario tem demissao calculada no mes, e por este motivo nao foi transferido."
					lRet := .F.
					Break
				EndIF
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se for apenas Transferencia de Centro de Custo nao  precisa³
		//³ validar a Matricula										          ³
		//³ Caso exista Item e Classe, utiliza o mesmo conceito.		    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lItemClVl
			IF ( ( cEmpAte == __cSvEmpAnt ) .and. ( cFilAte == __cSvFilAnt ) .and. (( cCcuAte # cCcDe ) .or.;
			( cProcesDe # cProces ) .or. ( cDeptoAte # cDeptoDe ) .or. ( cItemAte # cItemDe ).or. ( cClvlAte # cClvlDe ) ))
			lRet := .T.
			Break
			Endif
		Else
			IF ( ( cEmpAte == __cSvEmpAnt ) .and. ( cFilAte == __cSvFilAnt ) .and. (( cCcuAte # cCcDe ) .or.;
			( cProcesDe # cProces ) .or. ( cDeptoAte # cDeptoDe ) ))
			lRet := .T.
			Break
			Endif
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se no arquivo SRA Existe a Matricula              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( cEmpAte # __cSvEmpAnt )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se nao Conseguiu Abrir os Arquivos da Empresa Destino      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF !( fAbrEmpresa("SRA",1) )
				lRet := .F.
				Break
			EndIF
				IF ("GPESRA")->( dbSeek( RHTamFilial(__cFil) + cMatAte ) ) //Neste Ponto __cFil jah foi atualizado pela fAbrEmpresa()
					cName   := ("GPESRA")->RA_NOME
					cCPFAte := ("GPESRA")->RA_CIC
			EndIF
		Else
			__cFil := IIF( Empty( xFilial("SRA") ) , xFilial("SRA",SRA->RA_FILIAL), RHTamFilial(cFilAte) )
			IF SRA->( dbSeek( __cFil + cMatAte ) ) //Neste Ponto __cFil terah o conteudo de cFilAte ou Space(02)
				cName   := SRA->RA_NOME
				cCPFAte := SRA->RA_CIC
			EndIF
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Fecha o GPESRA que foi aberto em fAbrEmpresa()             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( cEmpAte # __cSvEmpAnt )
			IF ( lFecEmpresa )
				fFecEmpresa("SRA")
			EndIF
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se Ja Existe a Matricula Informada na Empresa ou Fi³
		//³lial de Destino											             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF !Empty(cName) .AND. (cMatAte <> aSvTransfCols[nLinAtu,_MATRIC])
			cFilMat 	:= RHTamFilial(cFilAte) + cMatAte
			SRA->(dbSeek(cFilMat, .F.))
			cCPFDe  	:= SRA->RA_CIC

			If cCPFDe == cCPFAte .AND. lReutMat
				IF !lRobo .And. !MsgNoYes( OemToAnsi("A matrícula digitada já existe e pertence ao mesmo funcionário." + Chr(013) + "Confirma a Transferencia ?"), OemToAnsi("Transferencia entre Filiais"))
				 	//"A matrícula digitada já existe e pertence ao mesmo funcionário. Confirma a Transferencia ?"###"Transferencia entre Filiais"
					lRet := .F.
					Break
				EndIF
			Else
				cMsg := cMatAte + " <=> " + "Já existe Funcionario com a Matricula Digitada. Informe nova Matricula"	//"Já existe Funcionario com a Matricula Digitada. Informe nova Matricula"
				If ( lShowMsg )
					Help(" ", 1, OemToAnsi("Transferˆncia de Matricula"),, OemToAnsi(cMsg), 1, 0 )//"Transferˆncia de Matricula"
				Else
					aAdd( aLog , cMsg )
				EndIf
				lRet := .F.
				Break
			EndIf
		Else
			If cMatAte <> aSvTransfCols[nLinAtu,_MATRIC]
				For nX := 1 To Len(aCols_Aux)
					If nX == nLinAtu
						Loop
					EndIf

					If cFilAte + cMatAte == aCols_Aux[nX,_FILIAL] + aCols_Aux[nX,_MATRIC]
						lRet := .F.
						cMsg := cMatAte + " <=> " + "Já existe Funcionario com a Matricula Digitada. Informe nova Matricula"	//"Já existe Funcionario com a Matricula Digitada. Informe nova Matricula"

						If ( lShowMsg )
							Help(" ", 1, OemToAnsi("Transferˆncia de Matricula"),, OemToAnsi(cMsg), 1, 0 )	//"Transferˆncia de Matricula"
						Else
							aAdd( aLog , cMsg )
						EndIf
					EndIf
				Next nX
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se nao Tiver informado a Matricula						       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cPic 	:= PesqPict("SRE","RE_MATP")

		If  cPic == "999999"
			If ( Val(cMatAte) <= 0 .or. empty(cMatAte), lTeste := .T., lTeste := .F. )
		Else
			If ( Empty(cMatAte), lTeste := .T., lTeste := .F. )
		EndIf

		If lTeste
			cMsg := cMatAte + " <=> " + "Matricula Invalida"	//"Matricula Invalida"
			IF ( lShowMsg )
				Help(" ", 1, OemToAnsi("Transferˆncia de Matricula"),, OemToAnsi(cMsg), 1, 0 )	//"Transferˆncia de Matricula"
			Else
				aAdd( aLog , cMsg )
			EndIF
			lRet := .F.
			Break
		EndIF

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Neste Caso seta a Diferenca de Matricula				       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lMatDif := ( cMatDe # cMatAte )
		lCpfDif := ( cCPFDe # cCPFAte )

		If lMatDif .And. !lRobo
			oGetSRA21:aCols[oGetSRA2:nat,1] := cMatAte
			If !IsBlind()
				oGetSRA21:Refresh()
			EndIf
		Endif
	End Sequence

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Restaura os Dados de Entrada								          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestArea( aAreaSRA )
	RestArea( aArea )
Return( lRet )

Static Function Gpea180Tra(aFilesTransf,cChave,lDelNovo,lGravaNovo,lDelAntigo,lRegrava,aFileReg)

	Local aAreaSRA	:= SRA->( GetArea() )
	Local nLoop
	Local nLoops

	DEFAULT aFileReg := {}
	// Dados da transferencia de Processo //
	Private aTrfPer
	Private aTrfHeader
	Private aFieldPer					// Campos de periodo da tabela
	GetPerTrf(@aTrfPer, @aTrfHeader) 	// Retorna o array com os periodos selecionados para transferencia de processo

	Private nPosProc   	:= GdFieldPos( "TRF_PROCES"	, aTrfHeader )
	Private nPosTab	   	:= GdFieldPos( "TRF_TABELA"	, aTrfHeader )
	Private nPosPerD   	:= GdFieldPos( "TRF_PERDE"	, aTrfHeader )
	Private nPosNPagoD	:= GdFieldPos( "TRF_NRODE"	, aTrfHeader )
	Private nPosRotD	:= GdFieldPos( "TRF_ROTDE"	, aTrfHeader )
	Private nPosPerP  	:= GdFieldPos( "TRF_PERPARA", aTrfHeader )
	Private nPosNPagoP	:= GdFieldPos( "TRF_NROPARA", aTrfHeader )
	Private nPosDel		:= Len(aTrfHeader)+1

	aFileReg := aClone(aFilesTransf)

	SRA->( dbSetOrder( 1 ) )

	nLoops	:= Len(aFilesTransf)

	If !lRobo
		BarGauge2Set( nLoops )
	Endif

	//Deleta registro destino
	For nLoop := 1 To nLoops

		If !lRobo
			IncProcG2( OemToAnsi( "Preparando Arquivos para a Transferência. " + ": " + aFilesTransf[ nLoop , 1 ] ) ) 	//"Preparando Arquivos para a Transferência. "
		Endif

		IF ( aFilesTransf[nLoop,1] == "SRT" ) 									//Nao Pode Transferir Provisoes
			Loop
		EndIF
    	IF ( aFilesTransf[nLoop,1] == "RFE" ) //Nao Pode Transferir Marcações Originais
	    	Loop
	   EndIF
	   IF ( aFilesTransf[nLoop,1] == "RFB" ) //Nao Pode Transferir Cabeçalho da RFE
		   Loop
	   EndIF

		IF !(;
				( aFilesTransf[nLoop,1] == "SRD" );
				.and.;
				lFilDif;		//Transferencia de Filial
				.and.;
				lCgcDif;		//Diferenca de CGC
				.and.;
				!( lEmpDif );	//Não eh Transferencia de Empresa
			)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ O conteudo do Array aFilesTransf[ nLoop, 6 ] indica se deve ³
			//³ efetuar alteracoes na tabela indica, caso seja .F. nao ira  ³
			//³ alterar nenhum registro da tabela listada					     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF ( ( lDelNovo ) .and. ( aFilesTransf[ nLoop, 6 ] ) )
				//--Deletar Registro se exitir no Destino.
				If !( aFilesTransf[nLoop,1] == "SRA" )
					IF ( aFilesTransf[nLoop,1] == "SR7" )
						fDelNovo("SR3",cFilAte+cMatAte) //Deleta Primeiro os Itens
					EndIF
					If !(aFilesTransf[nLoop,1] == "SRD" .and. lEmpDif .and. !lMatDif) .And. ( !lCpfDif .And. !aFilesTransf[nLoop,1] == "SRD" )
						fDelNovo(aFilesTransf[nLoop,1],cFilAte+cMatAte)
					EndIf
				EndIf
				If ( nLoop == nLoops )
					fDelNovo("SRA",cFilAte+cMatAte)
				EndIf
			EndIf
		EndIf
	Next nLoop

	If !lRobo
		BarGauge2Set( nLoops )
	Endif

	//Inclui novos registros
	For nLoop := 1 To nLoops

		//Verifica se e possivel efetuar a transferencia
		If aFilesTransf[ nLoop, 6 ]

			If !lRobo
				IncProcG2( OemToAnsi( "Transferindo Arquivo: " + aFilesTransf[ nLoop , 1 ] ) ) //"Transferindo Arquivo: "
			Endif

			IF ( aFilesTransf[nLoop,1] == "SRT" ) //Nao Pode Transferir Provisoes
				Loop
			EndIF
			IF ( aFilesTransf[nLoop,1] == "RFE" ) //Nao Pode Transferir Marcações Originais
				Loop
			EndIF
			IF ( aFilesTransf[nLoop,1] == "RFB" ) //Nao Pode Transferir Cabeçalho da RFE
				Loop
			EndIF
			IF ( aFilesTransf[nLoop,1] $ "RHP*RHS" .And. ( lEmpDif .Or. lFilDif ) ) //Nao Pode transferir planos de saude caso haja mudanca de empresa/filial
				Loop
			EndIF

			aFieldPer := aFilesTransf[nLoop,5]		// Campos do periodo para transferencia
			Gpea180Trf(;
							aFilesTransf[nLoop,1]	,;	//1-Alias
							aFilesTransf[nLoop,2]	,;	//2-Se Deleta o Autal
							aFilesTransf[nLoop,3]	,;	//3-Filial
							cChave					   ,;	//4-Chave
							lGravaNovo				   ,;	//5-Se Grava Novo
							lDelAntigo				   ,;	//6-Se Deleta o Antigo
							lRegrava				   ,;	//7-Se Regrava (Caso ja Exista)
			aFilesTransf[nLoop,4]	   ,;	//8-Se Modifica Centro de Custo Igual
			@aFileReg[nLoop];
						)
		EndIf

	Next nLoop

	//Verifica se há inclusão dos campos de turno, regra ou sequência para transferência(s)
	If nPos := AScan( aFields1, { |x| AllTrim( x ) == "RA_TNOTRAB" .OR. AllTrim( x ) == "RA_REGRA" .OR. AllTrim( x ) == "RA_SEQTURN" } ) > 0
		fGravaSpf()
	EndIf

	RestArea( aAreaSRA )
Return 

Static Function Grava_SRE( aLogTransf )

Local cMsgErr
Local lLockSre
Local lTSREP	:= SuperGetMv( "MV_TSREP" , NIL , .F. )
Local lTsaDep	:= If( SQB->(ColumnPos('QB_RHEXP'))>0, SuperGetMv("MV_TSADEP", NIL ,.F. ),.F. )
Local lGrava	:= .T.
Local aTransf	:= {}
Local dDataAnt	:= Ctod("")

Private oObjREP	:= Nil

If cEmpAnt == cEmpAte .And. cFilDe == cFilAte .And.;
	cMatDe == cMatAte .And. cCCDe == cCcuAte .And. cDeptoDe == cDeptoAte .And.;
	cItemAte == cItemDe .And. cClvlAte == cClvlDe .And.;
	cProcesDe == cProces .And. cPostoDe == cPostoAte
	 lGrava:= .F.
Endif

If lGrava
	IF ( lLockSre := RecLock( "SRE" , .T. , .F. ) )
		SRE->RE_EMPD    := cEmpAnt
		SRE->RE_FILIALD := cFilDe
		SRE->RE_MATD    := cMatDe
		SRE->RE_PROCESD := cProcesDe
		SRE->RE_CCD     := cCCDe
		SRE->RE_DEPTOD	:= cDeptoDe
		SRE->RE_POSTOD	:= cPostoDe
		SRE->RE_EMPP    := cEmpAte
		SRE->RE_FILIALP := cFilAte
		SRE->RE_MATP    := cMatAte
		SRE->RE_CCP     := cCcuAte
		SRE->RE_DATA    := dDataTra
		SRE->RE_PROCESP  := cProces
		SRE->RE_DEPTOP	:= cDeptoAte
		SRE->RE_POSTOP	:= cPostoAte
		SRE->RE_CODUNIC	:= SRA->RA_CODUNIC

		//Grava a data de integração com o TAF no campo RE_INTGTAF
		//Caso tenha integrado e exista o campo
		If SRE->(ColumnPos('RE_INTGTAF'))>0 .And. !Empty(dDataTAF)
			SRE->RE_INTGTAF  := dDataTAF
		Endif

		If lItemClvl
			SRE->RE_ITEMD	:= cItemDe
			SRE->RE_ITEMP	:= cItemAte
			SRE->RE_CLVLD	:= cClvlDe
			SRE->RE_CLVLP	:= cClvlAte
		EndIf

			If lTpDesl
				SRE->RE_DESL	:= cCodDesl
			EndIf

		SRE->RE_TRFOBS	:= cObsTra
		SRE->RE_TRFUNID	:= nNumTRF
		SRE->( MsUnlock() )
		aAdd(aFuncTran,{cEmpAnt,cFilDe,cCCDe,cMatDe,cProcesDe,cDeptoDe})

	Else
		cMsgErr := "Nao foi possivel Efetuar a Tranferencia para a Matricula:"	//"Nao foi possivel Efetuar a Tranferencia para a Matricula:"
		aAdd( aLogTransf , cEmpAnt + " " + cFilDe + " " + cMatDe )
		aAdd( aLogTransf , Space(5) + cMsgErr  )
	EndIF
EndIf

If lTSREP
	If cEmpAnt <> cEmpAte .Or. cFilDe <> cFilAte .Or. cMatDe <> cMatAte .Or. cCCDe <> cCcuAte
	    oObjREP := PTSREPOBJ():New()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa o WebServices TSA - Usuario Remover Centro de Custo  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		fTransfAll(@aTransf)
		If Len(aTransf) > 1
			dDataAnt := aTransf[Len(aTransf)-1,7]
    	Endif

		oObjREP:WSUser( 14, If(!Empty(dDataAnt),dDataAnt,NIL) , NIL , cEmpAnt+cFilDe+cMatDe, NIL, cEmpAnt+xFilial("CTT",cFilDe)+cCCDe )
	Endif

	If (cEmpAnt <> cEmpAte .Or. cFilDe <> cFilAte .Or. cMatDe <> cMatAte .Or. cDeptoDe <> cDeptoAte) .AND. lTsaDep

		oObjREP := PTSREPOBJ():New()

		//Executa o WebServices TSA - Usuario Remover Departamento
		oObjREP:WSUser( 15, If(!Empty(dDataAnt),dDataAnt,NIL) , NIL , cEmpAnt+cFilDe+cMatDe, NIL, cEmpAnt+xFilial("CTT",cFilDe)+cCCDe,,,Alltrim(cEmpAnt+xFilial("CTT",cFilDe)+cDeptoAte) )
	Endif

Endif
Return( lLockSre )

Static Function Gpea180Trf(cAlias,lDelAtu,cFil,cChave,lGravaNovo,lDelAntigo,lRegrava,lModCcIgual,aFileReg)

	Local aRecnos		:= {}
	Local aSegmentos	:= {}
	Local aSRC			:= {}
	Local aRGB			:= {}
	Local aStruSRC		:= {}
	Local nRecnos		:= 0
	Local nSvOrder		:= ( cAlias )->( IndexOrd() )
	Local nTamSeq		:= TamSx3( "RC_SEQ" )[1]
	Local nY			:= 0
	Local cCampo 		:= ""
	Local xConteudo		:= ""
	Local cPrefix		:= PrefixoCpo( ( cAlias := Upper( AllTrim( cAlias ) ) ) )
	Local cF			:= PrefixoCpo(Upper(cAlias))+If(cAlias =='RI6',"_FILMAT","_FILIAL")
	Local cC			:= PrefixoCpo(Upper(cAlias))+"_CC"
	Local cM			:= PrefixoCpo(Upper(cAlias))+"_MAT"
	Local cD			:= PrefixoCpo(Upper(cAlias))+"_DEPTO"
	Local cCond			:= &( "{ || " + cAlias + "->" + cF + "+" + cAlias + "->" + cM + " == cChave }" )
	Local cIt			:= ""
	Local cCL			:= ""
	Local cFilAux 		:= cFilAnt
	Local nNext
	Local nRecAtu
	Local nRecAnt		:= 0
	Local nPosPer
	Local nMaxArray		:= 0
	Local nReg			:= 0
	Local nX			:= 0
	Local nPos         	:= 0
	Local nSequencia    := 0
	Local cCpoProc
	Local cCpoPer
	Local cCpoNPago
	Local cCpoRot
	Local cValProc
	Local cValPer
	Local cValNPago
	Local cValRot
	Local cSraMat
	Local lPeriodo
	Local lGrava
	Local lSftSeek		:= .F.
	Local lSRAxSRC		:= .F.
	Local lFechaPls     := .F.
	Local cSeekCmp		:= ""
	Local cBusca       	:= Nil
	Local cPerPon		:= GetMv( "MV_PONMES" , NIL , "" )
	Local cQuery       	:= ""
	Local cAliasSRC    	:= ""
	Local cAliasQry    	:= ""
	Local cArqTemp     	:= ""
	Local cIndTemp     	:= ""
	Local cDataAux 		:= dToS( dDataTra )
	Local dPonIni		:= CtoD('')
	Local aSQBArea		:= ("SQB")->( GetArea() )
	Local cFilialAA1	:= ""
	Local cCodFuncAA1	:= ""
	Local lAtuReg		:= .F.
	Local nPosPd		:= 0
	Local cAliasRGB		:= ""
	Local aStruRGB		:= {}
	Local lCC			:= .F.
	Local lCD			:= .F.
	Local lGP010AGRV	:= ExistBLock('GP010AGRV')
	Local lTemAltera	:= .F.
	Local aBkpSraCols   := {}
	Local aBkpSVSra 	:= {}
	Local aTmp1			:= {}
	Local aTmp2			:= {}
	Local lRespSQB		:= .F.
	Local lRespSQB1		:= .F.
	Local cPer			:= ""
	Local cProc			:= ""

	Private lSraRelRd0	:= .T.
	Private nRd0Recno	:= 0
	Private aStruct     := {}

	If ( cAlias ) $ "REP/TM0/TM5/TMT"
	    cBusca 	:= Upper( cPrefix + "_FILFUN+" + cPrefix + "_MAT"  )
 	    cF		:= PrefixoCpo(Upper(cAlias))+"_FILFUN"
	    cCond	:= &( "{ || " + cAlias + "->" + cF + "+" + cAlias + "->" + cM + " == cChave }" )
	Elseif ( cAlias ) $ "BAU"
		cBusca 	:= Upper( cPrefix + "_FILFUN+" + cPrefix + "_MATFUN"  )
		cM	:= PrefixoCpo(Upper(cAlias))+"_MATFUN"
		cF		:= PrefixoCpo(Upper(cAlias))+"_FILFUN"
		cCond	:= &( "{ || " + cAlias + "->" + cF + "+" + cAlias + "->" + cM + " == cChave }" )
	EndIf

	__cFil 	:= cFil
	cFilAnt := cFilAte
	nOpc	:= xNopc

	If lItemClvl
		cIt	:= PrefixoCpo(Upper(cAlias))+"_ITEM"
		cCl	:= PrefixoCpo(Upper(cAlias))+"_CLVL"
	EndIf

	IF ( ChkFullName( cAlias ) )
		dbSelectArea("SRA")
		Return( NIL )
	EndIF

	//--Verifica se existe os campos Filial e Matricula no arquivo caso contrario nao trasnfere
	dbSelectArea( cAlias )

	lCC	:= Type(cC) # "U"
	lCD	:= Type(cD) # "U"

	If cAlias == 'RI6'
		dbSetOrder(4)
	Else
		dbSetOrder( RetOrdem( cAlias, cBusca ) )
	EndIf
	If (;
			( ( cAlias )->( FieldPos( cF ) ) == 0 );
			.and.;
			( ( cAlias )->( FieldPos( cM ) ) == 0 );
		)
		dbSelectArea("SRA")
		Return( NIL )
	Endif

	//--Verifica se o indice existe, senao cria indice temporario
   If ValType( cBusca ) # "U"
		If !( cBusca $ ( cAlias )->( IndexKey() ) )
			cArqTemp := CriaTrab(NIL,.F.)
			cIndTemp := ( cBusca )
			IndRegua( cAlias, cArqTemp, cIndTemp )
		EndIf
	EndIf

	//--Quando For Transferencia de Filial com CGC Diferente nao Leva SRD.
	If lItemClVl
 	    IF (;
				( cAlias $ "SRD|RIR" );
				.and.;
				(;
				 ( lFilDif .and. lCgcDif .and. !lEmpDif );
				.or.;
				 ( !lFilDif .And. !lCgcDif .And. !lEmpDif .And. (lCcDif .Or. lItemDif .Or. lClvlDif .or. lDeptoDif) );
				);
		    )
	      	  dbSelectArea("SRA")
	        Return( NIL )
	    EndIF
	Else
	    If (;
				( cAlias $ "SRD|RIR" );
				.and.;
				(;
				( lFilDif .and. lCgcDif .and. !lEmpDif );
				.or.;
				( !lFilDif .And. !lCgcDif .And. !lEmpDif .And. lCcDif .and. lDeptoDif);
				);
		    )
		     dbSelectArea("SRA")
		     Return( NIL )
	    EndIF
	EndIf

	If cAlias =="SRC"
	    aGetArea	:= GetArea()
	    nX     	 	:= 0
	    nPos		:= 0
	    nSequencia 	:= 0
	    cQuery	 	:= ""
		cAliasSRC 	:= "QSRC"
		aStruSRC  	:= SRC->( dbStruct() )

	    cQuery := "SELECT RC_FILIAL,RC_MAT, RC_PD, RC_CC,RC_SEMANA, RC_SEQ, R_E_C_N_O_ RECNO "
	    cQuery += "	 FROM " +  RetSqlName("SRC") + " SRC " + CRLF
		cQuery += "	WHERE SRC.RC_FILIAL = '" + Substr(cChave,1,FWGETTAMFILIAL) + "'"  + CRLF
		cQuery += "	  AND SRC.RC_MAT    = '" + Substr(cChave,1+FWGETTAMFILIAL,6) + "'"  + CRLF
		cQuery += "   AND D_E_L_E_T_ = ' ' "
	    cQuery += " ORDER BY " + SqlOrder( SRC->( IndexKey() ) ) + " "	+ CRLF

	    cQuery := ChangeQuery(cQuery)

		//ABRE A EXECUCAO DA QUERY ATRIBUIDA AO SRC
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSRC, .F., .T.)

		For nX := 1 To Len(aStruSRC)
			If ( aStruSRC[nX][2] <> "C" )
				TcSetField(cAliasSRC,aStruSRC[nX][1],aStruSRC[nX][2],aStruSRC[nX][3],aStruSRC[nX][4])
			EndIf
		Next nX

		While (cAliasSrc)->( !EOF() ) .and. ( (cAliasSrc)->RC_FILIAL+(cAliasSrc)->RC_MAT == cChave )
			nPos := Ascan(aSRC,{|x|x[1]+x[2]+x[3]+x[4]+x[5] == RC_FILIAL+RC_MAT+RC_PD+RC_CC+RC_SEMANA})
			IF Empty(nPos)
				Aadd(aSRC,{ RC_FILIAL,RC_MAT,RC_PD,RC_CC,RC_SEMANA,1,{} })
				nPos:= Len(aSRC)
			Else
				//-- Qtde de lancamentos para a mesma chave
				aSRC[nPos,6]++
			Endif
			Aadd(aSRC[nPos,7], { RC_FILIAL,RC_MAT,RC_PD,RC_CC,RC_SEMANA,RC_SEQ, cCcuAte, RECNO })
			(cAliasSrc)->( dbSkip() )
		EndDo

		//-- Gera conteudo do campo RC_SEQ
		fGeraSeq( @aSRC, nTamSeq )

		(cAliasSRC)-> (dbCloseArea())
		RestArea( aGetArea )
	EndIf

	If cAlias =="RGB"
	    aGetArea	:= GetArea()
	    nX     		:= 0
	    nPos		:= 0
	    nSequencia 	:= 0
		cQuery	 	:= ""
		cAliasRGB	:= "QRGB"
		aStruRGB	:= RGB->( dbStruct() )

	    cQuery := "SELECT RGB_FILIAL,RGB_MAT, RGB_PD, RGB_CC,RGB_SEMANA, RGB_SEQ, RGB_PERIOD, R_E_C_N_O_ RECNO "
	    cQuery += "	 FROM " + RetSqlName("RGB") + " RGB " + CRLF
		cQuery += "	WHERE RGB.RGB_FILIAL = '" + Substr(cChave,1,FWGETTAMFILIAL)+ "'"  + CRLF
		cQuery += "	  AND RGB.RGB_MAT    = '" + Substr(cChave,1+FWGETTAMFILIAL,6)+ "'"  + CRLF
	    cQuery += "   AND D_E_L_E_T_ = ' ' "
	    cQuery += " ORDER BY " + SqlOrder( RGB->( IndexKey() ) ) + " "	+ CRLF

	   	cQuery := ChangeQuery(cQuery)

		//ABRE A EXECUCAO DA QUERY ATRIBUIDA AO RGB
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasRGB, .F., .T.)

	   	For nX := 1 To Len(aStruRGB)
			If ( aStruRGB[nX][2] <> "C" )
				TcSetField(cAliasRGB,aStruRGB[nX][1],aStruRGB[nX][2],aStruRGB[nX][3],aStruRGB[nX][4])
			EndIf
		Next nX

		While (cAliasRGB)->( !EOF() ) .and. ( (cAliasRGB)->RGB_FILIAL+(cAliasRGB)->RGB_MAT == cChave )
			nPos := Ascan(aRGB,{|x|x[1]+x[2]+x[3]+x[4]+x[5] == RGB_FILIAL+RGB_MAT+RGB_PD+RGB_CC+RGB_SEMANA})
			IF Empty(nPos)
				Aadd(aRGB,{ RGB_FILIAL,RGB_MAT,RGB_PD,RGB_CC,RGB_SEMANA,1,{} })
				nPos:= Len(aRGB)
			Else
				//-- Qtde de lancamentos para a mesma chave
				aRGB[nPos,6]++
			Endif
			Aadd(aRGB[nPos,7], { RGB_FILIAL,RGB_MAT,RGB_PD,RGB_CC,RGB_SEMANA,RGB_SEQ, cCcuAte, RGB_PERIOD, RECNO })
			(cAliasRGB)->( dbSkip() )
		EndDo

		//-- Gera conteudo do campo RC_SEQ
		fGeraSeq( @aRGB, nTamSeq )

		(cAliasRGB)-> (dbCloseArea())
		RestArea( aGetArea )
	EndIf
	
	aGetArea	:= GetArea()
	
	cQuery		:= ""
	cAliasQry 	:= "Qry" + cAlias
	dbSelectArea(cAlias)
	aStruct := (cAlias)->( dbStruct() )
	
	cQuery := "SELECT "
	For nX := 1 To len(aStruct)
			cQuery += aStruct[ nX , 1 ] + ", "
	Next nX
	
	cQuery += "R_E_C_N_O_ RECNO "
	cQuery += "			FROM " +  RetSqlName(cAlias) + " " + cAlias + " " + CRLF
	cQuery += "			WHERE " + cAlias + "." + cF + " = '" + Substr(cChave,1,FWSizeFilial(__cSvEmpAnt))+ "'"  + CRLF
	cQuery += "			AND	  " + cAlias + "." + cM + " = '" + Substr(cChave,1+FWSizeFilial(__cSvEmpAnt), TamSx3("RA_MAT")[1])+ "'"  + CRLF
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	
	//So deve transferir a SPK do período aberto do ponto
	PerAponta(@dPonIni , Nil , Nil, .F.)
	If cAlias == "SPK"
		If !Empty(dPonIni)
			cQuery += "   AND PK_DATA >= '" + DtoS(dPonIni) + "' "
		Else
			//Se nao existir periodo do ponto aberto, transfere somente os registros com data a partir da data de transferencia
			cQuery += "   AND PK_DATA >= '" + DtoS(dDataTra) + "' "
		EndIf
	EndIf
	
	cQuery += "ORDER BY " + SqlOrder( (cAlias)->( IndexKey() ) ) + " "	+ CRLF
	cQuery := ChangeQuery(cQuery)
	
	//ABRE A EXECUCAO DA QUERY ATRIBUIDA AO SRC
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
	
	For nX := 1 To Len(aStruct)
		If ( aStruct[nX][2] <> "C" )
			TcSetField(cAliasQry,aStruct[nX][1],aStruct[nX][2],aStruct[nX][3],aStruct[nX][4])
		EndIf
	Next nX
	
	lContinua 	:= !( (cAliasQry)->( Bof() ) .And. (cAliasQry)->( Eof() ) )
	cCond		:= &( "{ || " + cAliasQry + "->" + cF + "+" + cAliasQry + "->" + cM + " == cChave }" )
	
Begin Transaction
	
	If lContinua
		
		If cAlias == "SRR" //Guarda o período atual da folha
			cProc 	:= SRA->RA_PROCES
			fGetLastPer( @cPer, , cProc, cRtFol)
			
			dbSelectArea( cAliasQry )
		EndIf
		
		aAdd( aRecnos , RECNO )
		
		While !(cAliasQry)->(Eof())
			lTemAltera := .F.
			
		    //--Gerara novo registro se Alterou Filial Ou Empresa
			If lGravaNovo
				lSRAxSRC:= .F.
			    //-- Verifica se o CC foi trocado para tratar lancamentos do SRC
				If ( "SRC" $ cAlias )
					lSRAxSRC := ( (cAliasQry)->RC_CC # cCcDe )
				ElseIf ( "RGB" $ cAlias )
					lSRAxSRC := ( (cAliasQry)->RGB_CC # cCcDe )
				Endif
				//--FUNCAO PARA GRAVAR REGISTRO PARA NO ARQUIVO DESTINO
				fGravaNovo(cAlias,cAliasQry,lSRAxSRC, If(cAlias == "RGB",aRGB,aSRC), RECNO)
				lTemAltera := .T.
			Endif
			
			//Tratamento para preencher o periodo final do plano de saude nas tabelas RHK, RHL e RHM
			//Porem, nao efetua o fechamento do plano de saude quando somente o CC for diferente
			If ( ( lFilDif ) .OR. ( lEmpDif ) )
				lFechaPls := .T.
			EndIf
			
			If lFechaPls .And. cAlias $ "RHK/RHL/RHM"
				dbSelectArea(cAlias)
				If ( cAlias )->( dbSeek( cChave , .F. ) )
					While ( cAlias )->( &(cAlias+"_FILIAL") + &(cAlias+"_MAT")  ) == cChave
						If ( cAlias )->( RecLock( cAlias , .F. ) )
							lTemAltera := .T.
							( cAlias )->( &(cAlias+"_PERFIM") ) := SubStr( cDataAux, 5, 2 ) + SubStr( cDataAux, 1, 4 )
							( cAlias )->( MsUnlock() )
						EndIf
						( cAlias )->( dbSkip() )
					End While
				EndIf
			 EndIf

			 //-- Se deleta registro do Antigo
			 If(( lDelAntigo ) .Or. (( lDelAtu ).And. (( lEmpDif ) .Or. (( lFilDif ) .And. ( lCgcDif )))))

				//--Deleta registro de Origem quando mudanca de Empresa
				dbSelectArea(cAlias)
				(cAlias)->(dbGoTo((cAliasQry)->RECNO))
				If ( cAlias )->( RecLock( cAlias, .F. ) )
					( cAlias )->( dbDelete() )
					( cAlias )->( MsUnlock() )
				EndIf
			Endif

			//--Nao Alterar Registro Atual Quando Empresa ou Filial
			nNext := Nil
			If lRegrava
				dbSelectArea( cAliasQry )
				lAtuReg := .F.
				nRecAtu := RECNO
				( cAlias )->( dbGoto(nRecAtu)  )

				//Manter o Centro de Custo Original no SRD
					If lCC .and. !( cAlias $ "SRD" )
					Begin Sequence
						If cAlias == "SRC"
							nPos := Ascan(aSRC,{|x|x[8] == ( cAliasQry )->RECNO} )
							If nPos # 0
									nPosPd := Ascan(aSRC,{|x|x[1]+x[2]+x[3]+x[4]+x[6] == cChave + aSrc[nPos,3] + cCcuAte + aSrc[nPos,6]} )
								If nPosPd # 0 .AND. (aSRC[nPosPd,8] <> nRecAtu .AND. !(lModCcIgual .and. ( cAliasQry )->(FieldGet( FieldPos ( cC )) ) # cCcDe ))
									nRecAnt	:= nRecAtu
									nRecAtu := aSRC[nPosPd,8]
									lAtuReg	:= .T.
								EndIf
								( cAlias )->( dbGoto(nRecAtu)  )
								If cAlias == 'SRA'
									PcoDetLan("000086","01","GPEA180")
								Endif
								RecLock(cAlias)

								If  ( cAliasQry )->(FieldGet( FieldPos ( cF ) )) # cFilAte
										lTemAltera := .T.
									FieldPut( FieldPos ( cF ) , cFilAte )
								Endif

								SRC->RC_SEQ := aSRC[nPos,6]
							Else
								If cAlias == 'SRA'
									PcoDetLan("000086","01","GPEA180")
								Endif
								RecLock(cAlias)

								If  ( cAliasQry )->(FieldGet( FieldPos ( cF ) )) # cFilAte
										lTemAltera := .T.
									FieldPut( FieldPos ( cF ) , cFilAte )
								Endif
							EndIf
						ElseIf cAlias == "RGB"
							nPos := Ascan(aRgb,{|x|x[9] == ( cAliasQry )->RECNO})
							If nPos # 0
								nPosPd := Ascan(aRgb,{|x|x[1]+x[2]+x[3]+x[4]+x[6]+x[8] == cChave + aRgb[nPos,3] + cCcuAte + aRgb[nPos,6] + ( cAliasQry )->RGB_PERIOD	} )
								If nPosPd # 0 .AND. (aRgb[nPosPd,9] <> nRecAtu .AND. !(lModCcIgual .and. ( cAliasQry )->(FieldGet( FieldPos ( cC )) ) # cCcDe ))
									nRecAnt	:= nRecAtu
									nRecAtu := aRgb[nPosPd,9]
									lAtuReg	:= .T.
								EndIf
								( cAlias )->( dbGoto(nRecAtu)  )
								If cAlias == 'SRA'
									PcoDetLan("000086","01","GPEA180")
								Endif
								RecLock(cAlias)

								If  ( cAliasQry )->(FieldGet( FieldPos ( cF ) )) # cFilAte
									FieldPut( FieldPos ( cF ) , cFilAte )
										lTemAltera := .T.
								Endif

								RGB->RGB_SEQ := aRgb[nPos,6]
							Else
								If cAlias == 'SRA'
									PcoDetLan("000086","01","GPEA180")
								Endif
								RecLock(cAlias)

								If  ( cAliasQry )->(FieldGet( FieldPos ( cF ) )) # cFilAte
									FieldPut( FieldPos ( cF ) , cFilAte )
										lTemAltera := .T.
								Endif
							EndIf
						Else
							( cAlias )->( dbGoto(nRecAtu)  )

							If cAlias == 'SRA'
								PcoDetLan("000086","01","GPEA180")
							Endif

							RecLock(cAlias)
							If  ( cAliasQry )->(FieldGet( FieldPos ( cF ) )) # cFilAte
								FieldPut( FieldPos ( cF ) , cFilAte )
									lTemAltera := .T.
							Endif

						EndIf

						//So alterar o Centro de Custo do que seja igual ao Centro de Custo
						//do Cadastro de Funcionarios
						If lModCcIgual .and. ( cAliasQry )->(FieldGet( FieldPos ( cC ) )) # cCcDe
							Break
						EndIF
						//Altera os Centros de Custo
						If ( cAliasQry )->(FieldGet( FieldPos ( cC ) )) # cCcuAte
							If cAlias == "SRO"
								If dDataTra <= ( cAliasQry )->RO_DATAATE
									FieldPut( FieldPos ( cC ) , cCcuAte )
										lTemAltera := .T.
								EndIf
							ElseIf cAlias == "SRR"
								If(( cAliasQry )-> RR_PERIODO == cPer)
									FieldPut( FieldPos ( cC ) , cCcuAte )
									lTemAltera := .T.
								Else
									lTemAltera := .F.
								EndIf
							ElseIf cAlias $ "SP8|SPC" .And. !Empty(dPonIni)
								If ( cAliasQry )->&(cPrefix + "_DATA") >= dPonIni
									FieldPut( FieldPos ( cC ), cCcuAte )
									lTemAltera := .T.
								Else
									lTemAltera := .F.
								EndIf
							Else
								FieldPut( FieldPos ( cC ) , cCcuAte )
									lTemAltera := .T.
								If lAtuReg
									If cAlias == "SRC"
										SRC->RC_HORAS += ( cAliasQry )->RC_HORAS
										SRC->RC_VALOR += ( cAliasQry )->RC_VALOR
									ElseIf cAlias == "RGB"
										RGB->RGB_HORAS += ( cAliasQry )->RGB_HORAS
										RGB->RGB_VALOR += ( cAliasQry )->RGB_VALOR
									EndIf
								EndIf
							EndIf
						Endif
						If ( cAliasQry )->(FieldGet( FieldPos ( cD ) )) # cDeptoAte
							FieldPut( FieldPos ( cD ) , cDeptoAte )
								lTemAltera := .T.
						Endif
						If lItemClVl
							If ( cAliasQry )->(FieldGet( FieldPos ( cIt ) )) # cItemAte
								FieldPut( FieldPos ( cIt ) , cItemAte )
									lTemAltera := .T.
							Endif
	   						If ( cAliasQry )->(FieldGet( FieldPos ( cCl ) )) # cClvlAte
								FieldPut( FieldPos ( cCl ) , cClvlAte )
									lTemAltera := .T.
							Endif
						EndIf
					End Sequence
				Else
					( cAlias )->( dbGoto(nRecAtu)  )
					If cAlias == 'SRA'
						PcoDetLan("000086","01","GPEA180")
					Endif
					RecLock(cAlias)

					If  ( cAliasQry )->(FieldGet( FieldPos ( cF ) )) # cFilAte
						FieldPut( FieldPos ( cF ) , cFilAte )
							lTemAltera := .T.
					Endif
				Endif

				//Manter o Departamento Original no SRD
					If lCD .and. !( "SRD" $ cAlias )
					 Begin Sequence
					   //So alterar o Departamento do que seja igual ao Departamento do Cadastro de Funcionarios
					   If lModCcIgual .and. FieldGet( FieldPos ( cD ) ) # cDeptoDe
						    Break
					   EndIf
					   //Altera Departamento
					   If FieldGet( FieldPos ( cD ) ) # cDeptoAte
						 	FieldPut( FieldPos ( cD ) , cDeptoAte )
								lTemAltera := .T.
						Endif
					 End Sequence
			   Endif

				//Alterar o periodo na transferencia de processo e filial
				//Transferencia das tabelas de movimentos abaixo
				If (!Empty(aFieldPer) .and. !( "SRD" $ cAlias ) .and. lProcDif) .Or. ( cAlias == "SRA" )
					 If cAlias == "SRA" .and. ( cPaisLoc $ "MEX*DOM*COS"  )
						  cRotFol := fGetRotOrdinar()

						  cValProc	  := (cAlias)->(RA_PROCES)
					      cValPer 	  := (cAlias)->(RA_PERADM)
						  cValNPago := (cAlias)->(RA_PAGADM)
						  cValPer 	  := "INGRESO"
						  cValNPago := Space( GetSx3Cache( "RCH_NUMPAG" , "X3_TAMANHO" ) )
						  nPosPer := aScan( aTrfPer, { |x| x[nPosTab]+x[nPosProc]+x[nPosPerD]+x[nPosNPagoD]+x[nPosRotD] == cAlias+cValProc+cValPer+cValNPago+cRotFol } )
						  If nPosPer > 0
								cValPer 	:= aTrfPer[nPosPer,nPosPerP]
								cValNPago	:= aTrfPer[nPosPer,nPosNPagoP]
								FieldPut( FieldPos ( "RA_PERADM" ), cValPer )
								FieldPut( FieldPos ( "RA_PAGADM" ), cValNPago )
								lTemAltera := .T.
						  EndIf

						  cValPer   	:= (cAlias)->(RA_PERAUM)
						  cValNPago	:= (cAlias)->(RA_PAGAUM)
						  cValPer 	   := "AUMENTO"
						  cValNPago	:= Space( GetSx3Cache( "RCH_NUMPAG" , "X3_TAMANHO" ) )

						  nPosPer := aScan( aTrfPer, { |x| x[nPosTab]+x[nPosProc]+x[nPosPerD]+x[nPosNPagoD]+x[nPosRotD] == cAlias+cValProc+cValPer+cValNPago+cRotFol } )
						  If nPosPer > 0
								cValPer 	:= aTrfPer[nPosPer,nPosPerP]
								cValNPago	:= aTrfPer[nPosPer,nPosNPagoP]
								FieldPut( FieldPos ( "RA_PERAUM" ), cValPer )
								FieldPut( FieldPos ( "RA_PAGAUM" ), cValNPago )
								lTemAltera := .T.
						  EndIf

						  If cProces <> (cAlias)->(RA_PROCES)
							   FieldPut( FieldPos ( "RA_PROCES" ), cProces )
								lTemAltera := .T.
						  EndIf
					 ElseIf cAlias == "SRA" .And. MV_MODFOL $ "1*2" .and. !cPaisLoc $ "MEX*DOM*COS"
							If cProces <> (cAlias)->(RA_PROCES)
								FieldPut( FieldPos ( "RA_PROCES" ), cProces )
								lTemAltera := .T.
							EndIf
					 EndIf

					 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					 //³Grava campos complementares                                 ³
					 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					 If (cOrgCfg == "1" .Or. lTemCpoCompl ) .and. cAlias == "SRA"
						  nMaxArray	:= Len(aSRAHeader)

						  For nX := 1 To nMaxArray
							   SetMemVar( aSRAHeader[ nX , 02 ] ,aSRACols[ nPosAtu, nX ]  , .T. )
						  Next nX

						  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						  //³Chamada da funcao de gravacao do SRA                        ³
						  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						  aBkpSraCols := aClone(aSRACols)
						  aBkpSVSra := aClone(aSvSraCols)

						  aadd(aTMP1,aSRACols[nPosAtu])
						  aadd(aTMP2,aSvSraCols[nPosAtu])
						  aSRACols := {}
						  aSvSraCols := {}
						  aSRACols := aClone(aTMP1)
						  aSvSraCols := aClone(aTMP2)


						  lGrava :=  Gpea010Put(cAlias , 4 , nRecAtu , 1  , @cSraMat, aSegmentos)

						  aSRACols := aBkpSraCols
						  aSvSraCols := aBkpSVSra

						  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						  //³Ponto de Entrada apos a gravacao dos Registros				   ³
						  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						  If lGrava
								If lGP010AGRV
								    ExecBLock('GP010AGRV',.F.,.F.,{nOpc,lGrava})
							   Endif
						  EndIf
					 Endif

				    If cAlias == 'SRA'
					     PcoDetLan("000086","02","GPEA180")
					     SRA->RA_RHEXP := Space(6)
				    Endif
	          Endif

          		If ( cAliasQry )->(FieldGet( FieldPos ( cM ) )) # cMatAte
				     FieldPut( FieldPos ( cM ) , cMatAte )
						lTemAltera := .T.
			    Endif

				//Alterar o periodo na transferencia de processo e filial
				//Transferencia do funcionario acima ou em GRAVANOVO
				If (!Empty(aFieldPer) .and. !( "SRD" $ cAlias ) .and. lProcDif) .Or. ( cAlias == "SRA" )
				    If cAlias <> "SRA"
					     // Tratamento para a troca de periodos //
					     cCpoProc	:= aFieldPer[1]
						  cCpoPer	:= aFieldPer[2]
						  cCpoNPago	:= aFieldPer[3]
						  cCpoRot	:= aFieldPer[4]

					     lPeriodo := (!Empty( cCpoProc ) .and. !Empty( cCpoPer ) .and. !Empty( cCpoNPago ))
						  If lPeriodo
							 	cValProc	:= ( cAlias )->( &cCpoProc )
								cValPer 	:= ( cAlias )->( &cCpoPer )
								cValNPago	:= ( cAlias )->( &cCpoNPago )
								If !Empty(cCpoRot)
								 	 cValRot	:= ( cAlias )->( &cCpoRot )
									 nPosPer := aScan( aTrfPer, { |x| x[nPosTab]+x[nPosProc]+x[nPosPerD]+x[nPosNPagoD]+x[nPosRotD] == cAlias+cValProc+cValPer+cValNPago+If(Empty(cValRot), Space( GetSx3Cache( "RCH_ROTEIR" , "X3_TAMANHO" ) ), cValRot) }  )
								Else
									 nPosPer := aScan( aTrfPer, { |x| x[nPosTab]+x[nPosProc]+x[nPosPerD]+x[nPosNPagoD] == cAlias+cValProc+cValPer+cValNPago }  )
								EndIf
							   If nPosPer > 0
									  If aTrfPer[nPosPer,nPosDel]
									     ( cAlias )->( dbDelete() )
									  Else
										  FieldPut( FieldPos ( cCpoPer ), aTrfPer[nPosPer,nPosPerP] )
										  FieldPut( FieldPos ( cCpoNPago ), aTrfPer[nPosPer,nPosNPagoP] )
										  FieldPut( FieldPos ( cCpoRot ), aTrfPer[nPosPer,nPosRotD] )
									  	  FieldPut( FieldPos ( cCpoProc ), cProces )
										lTemAltera := .T.
									  EndIf
								Else
									FieldPut( FieldPos ( cCpoProc ), cProces )
									lTemAltera := .T.
								 EndIf
							EndIf
					 EndIf
				EndIf
				( cAlias )->( MsUnlock() )

				If lAtuReg
					( cAlias )->( dbGoto(nRecAnt)  )
					Reclock(cAlias,.F.)
					( cAlias )->( dbDelete() )
					MsUnLock()
						lTemAltera := .T.
				EndIf
	      EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se houve algum tipo de alteracao que envolva os campos do  |
			//| indice, devera procurar pela chave novamente.			   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lEmpDif .and. (lMatDif .or. lFilDif)
				dbSelectArea(cAliasQry)
				nRecnos := 0
				While ( ( ++nRecnos ) <= Len( aRecnos ) )
					If aRecnos[ nRecnos ] == RECNO
    	        		dbSelectArea( cAliasQry )
    	        		( cAliasQry )->( dbSkip() )
    	        		If ( aScan( aRecnos, RECNO ) == 0 )
    	        			aAdd( aRecnos , RECNO )
							Exit
						EndIF
					EndIF
				EndDo
			Else
				dbSelectArea(cAliasQry)
	        	If ( "SRA" $ cAliasQry )
	        		Exit
	        	EndIf
	        	If nNext != NIL
	        		( cAliasQry )->( dbGoto(nNext) )
	        	Else
	        		( cAliasQry )->( dbSkip() )
				EndIf
			EndIf
		Enddo
	EndIf
	(cAliasQry)-> (dbCloseArea())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava os Acumulados                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF cAlias == "SRD"
			aFileReg[7] := .F.
		Else
			aFileReg[7] := lTemAltera
		EndIf
	If ( ( cAlias == "SRD" ) .and. ( lEmpDif ) )
		fGravaSrd( cChave, cAlias )
			aFileReg[7] := .T.
	EndIF

	cFilAnt:= cFilDe
	dbSelectArea("SQB")
	dbSetOrder(4)
	dbSeek(xFilial('SQB') + cCcDe)
	While xFilial('SQB') + cCcDe == SQB->QB_FILIAL + SQB->QB_CC
		If cMatde == SQB->QB_MATRESP  .And. cAlias == "SRA"
			If lRespSQB1 .Or. ( lRespSQB := iif( !lRobo , MsgNoYes( OemToAnsi( "O funcionário é responsavel por um departamento, deseja desassociá-lo?")  , OemToAnsi( "Departamento" ) ) , .T. ) )
			   	If lRespSQB
			   		Reclock("SQB",.F.)
			   		SQB->QB_FILRESP:= ""
			   		SQB->QB_MATRESP:= ""
			   		MsUnlock()
			   	Endif
			EndIf
			lRespSQB1 := .T.
		Endif
		DbSkip()
	EndDo
	cFilAnt:= cFilAte

End Transaction

IF	cAlias == 'RI6'
	( cAlias )->( dbSetOrder(4) )
Else
	( cAlias )->( dbSetOrder ( nSvOrder ) )
Endif
dbSelectArea("SRA")

cFilAnt := cFilAux

//Exclui arquivo de indice temporario se houver
If !Empty( cArqTemp )
	( cAlias )->( dbCloseArea() )
	FErase( cArqTemp + OrdBagExt() )
EndIf

RestArea( aSQBArea )

Return