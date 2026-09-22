#Include 'Protheus.ch'
Static lTransf	:= .F.
Static lOutros	:= .F.
Static lTurno 	:= .F.
Static aTpsSol	:= {Nil,Nil,Nil,Nil,Nil}
Static cFilNova	:= cFilAnt

/*{Protheus.doc} F0500402
Efetua a atualização quando solicitação aprovada
@type User Function
@author Cris
@since 04/11/2016
@version P12.1.7
@Project MAN0000007423039_EF_004
@return ${lVlDt}, ${.T. efetivado com sucesso  .F. não efetivado}
@param oModel, objeto, Modelo de Dados
*/
User Function F0500402(oModel)

	Local cFilSol	:= oModel:GetModel("RH3MASTER"):GetValue("RH3_FILIAL")
	Local cNumSol	:= oModel:GetModel("RH3MASTER"):GetValue("RH3_CODIGO")
	Local dDtaSol	:= oModel:GetModel("RH3MASTER"):GetValue("RH3_DTSOLI")
	Local cMatFun	:= oModel:GetModel("RH3MASTER"):GetValue("RH3_MAT")
	Local cVisaoA	:= oModel:GetModel("RH3MASTER"):GetValue("RH3_VISAO")
	Local aCpos		:= {}
	Local cTipoAtu	:= ''
	Local lVlDt		:= .T.
	Local cBlqSlTF	:= ''
	Local lExeTrans := .F. 
	Private dM1Dt
	Private lIntTAF	:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 )
	Private lTpDesl	:= lIntTAF .And. X3USADO('RE_DESL')	
	
	Private oGauge2
	Private cConDept	:= .F.
	Private cConProc	:= .F.
	Private cConPosto	:= .F.
	Private lGpea180Flt := .F.					//Verifica se havera filtro de Browse para o GPEA180

	
	// ticket n° 10997420 - Evita o desponteiro vindo da primeira efetivação sem sair do browse
	If cFilNova <> cFilAnt 
		cFilNova := cFilAnt  
	EndIf
	
	// ticket 3138519 [AMS] - Paulo Dias - 29/06/2018
	dM1Dt := PegaM1Dt(cFilSol,cNumSol)
	dbSelectArea("RH4")
	RH4->(dbSetORder(1))
	If RH4->(DbSeek(cFilSol + cNumSol))
		
		While cFilSol + cNumSol == RH4->(RH4_FILIAL + RH4_CODIGO)
			
			If 'TMP_TIPO' $ RH4->RH4_CAMPO .AND. cTipoAtu <> RH4->RH4_VALNOV
				
				If !Empty(cTipoAtu)
					AcuSoli(Alltrim(cTipoAtu),@aCpos)
				EndIf
				
				cTipoAtu	:= RH4->RH4_VALNOV
				
			EndIf
			
			If 'RA_' $ RH4->RH4_CAMPO				
				AAdd(aCpos,{RH4->RH4_CAMPO, RH4->RH4_VALNOV})
			EndIf
			
			RH4->(dbSkip())
		EndDo
		
		AcuSoli(Alltrim(cTipoAtu),@aCpos) //Acumula os tipos de solicitações nas posições dentro do array(aTpsSol) limitado	
		
		//Validar data da aprovação
		//If  lVlDt	:= (VlDtAprov(lVlDt,dDtaSol) .AND. VldTransf( aTpsSol[1] ) .AND. Valposto(cFilSol,cNumSol))
		If  lVlDt	:= (VldTransf( aTpsSol[1] ) .AND. Valposto(cFilSol,cNumSol))
				
			lExeTrans := lTransf .AND. (lVlDt	:= MsgNoYes( "Confirma a Transferência?" + CRLF + CRLF + "ATENÇÃO: Após a confirmação NÃO SERÁ POSSÍVEL DESFAZER ESSA OPERAÇÃO!" ))
			
			Begin Transaction
			
				If lExeTrans
					FWMsgRun(,{|| lVlDt	:= AtTransf(oModel,aTpsSol[1],cFilSol,cMatFun,dDtaSol) },"Processando...","Atualizando para a transferência. Aguarde!" )
				EndIf
					
			 	If lVlDt .AND. lOutros
						
					If aTpsSol[2] <> Nil .AND. len(aTpsSol[2]) > 0							
						// ticket 3138519 [AMS] - Paulo Dias - 29/06/2018
						lSoTur := VerSoTur(cFilSol,cNumSol) // verificar se solicitaçao eh somente alteracao de turno
						FWMsgRun(,{|| lVlDt	:= ATTurHor(aTpsSol[2],cFilSol,cMatFun,dDtaSol,aTpsSol[5],dM1Dt,lSoTur,lExeTrans) },"Processando...","Atualizando Carga Horária/Turno de trabalho. Aguarde!" )
					EndIf
						
					If lVlDt .AND. aTpsSol[3] <> Nil .AND. len(aTpsSol[3]) > 0							
						FWMsgRun(,{|| lVlDt	:= AtCargo(aTpsSol[3],cFilSol,cMatFun,dDtaSol,dM1Dt) },"Processando...","Atualizando Cargo. Aguarde!" )
					EndIf
						
					If lVlDt .AND. aTpsSol[4] <> Nil .AND. len(aTpsSol[4]) > 0 .AND. lTransf .AND. Alltrim(GetMV('FS_BLQSLTF')) == 'S'							
							lVlDt	:= .F.
					EndIf
						
					If lVlDt .AND. aTpsSol[4] <> Nil .AND. len(aTpsSol[4]) > 0							
						FWMsgRun(,{|| lVlDt	:= AtSalari(aTpsSol[4],cFilSol,cMatFun,dDtaSol,dM1Dt,cTipoAtu) },"Processando...","Atualizando Salário. Aguarde!" )
					EndIf
					// ticket 3138519 [AMS] - Paulo Dias - 29/06/2018
					If lExeTrans // verifica se houve trasnferencia e altera a data seguindo as regras do M+1
						//DbSelectArea("SRE")
						//SRE->(DbSetOrder(1))
						//If SRE->(dBseek("01"+ALLTRIM(padr(cFilSol,12))+cMatFun+dtos(dDatabase)))
						Reclock("SRE",.F.)
						Replace RE_DATA with dM1Dt
						MsUnlock()
						//Endif
					Endif
					// Fim ticket 3138519 [AMS] - Paulo Dias - 29/06/2018
				EndIf
				/* ticket n° 7065967 - 415966 - Paulo Dias 
				====== Garanto que a atualização de status e data de atendimento sejam gravados na RH3
			    ====== em alinhamento com a rotina de movimentação evitando dados divergentes entre as tabelas respectivas
		        ====== e a RH3 caso o processo seja abortado por algum motivo 
				*/
				If lVlDt 
					DbSelectArea("RH3")
					RH3->(DbSetOrder(1))
					If RH3->(DbSeek(cFilSol+cNumSol))
						RecLock("RH3",.F.)
						RH3->RH3_STATUS := "2"
						RH3->RH3_DTATEN := dDataBase 
						RH3->RH3_XDTAPV := DATE()
							
						RH3->(MsUnLock())
					EndIf
				EndIf
				// Fim ticket n° 7065967
			End Transaction
						
		EndIf
		
	EndIf
	
	If lVlDt
		
		//Libera cadastro de funcionário para nova inclusão de solicitação
		U_F0500407(cFilSol,cMatFun,cNumSol,cVisaoA)
		
		//Monta e-mail para chamar rotina de envio e-mail para todos
		//U_F0500409(cFilSol,cMatFun,cNumSol,cVisaoA,'1')
		
		Aviso('SUCESSO - EFETIVAÇÃO',"A solicitação foi efetuada com sucesso. ",{'OK'},1)
		
	Else
		
		Aviso('NÃO EFETIVADA - EFETIVAÇÃO',"A solicitação não foi efetuada. ",{'OK'},1)
		//Monta e-mail para chamar rotina de envio e-mail para todos
	EndIf
	
	lTransf		:= .F.
	lOutros		:= .F.
	aTpsSol		:= {Nil,Nil,Nil,Nil,Nil}
	cFilNova	:= cFilAnt

Return lVlDt

/*{Protheus.doc} AcuSoli
(long_description)
@author Cris
@since 09/11/2016
@param cTipoAtu, character, Tipo de atualização 1-Aumento,2-Cargo,3-Carga Horaria,4-Turno,5-Transferencia
@param aCpos, array, (Descrição do parâmetro)
@version P12.1.7
@Project MAN0000007423039_EF_004
*/
Static Function AcuSoli(cTipoAtu,aCpos)
	
	//Se for transferencia, chama rotina de transferência
	if cTipoAtu == '5'
		
		aTpsSol[1] := aCpos
		aCpos	:= {}
		lTransf	:= .T.
		
	Elseif cTipoAtu $ '4' //Os dados da troca de turno(4) e da carga horária(3) serão atualizados em conjunto **Verificar
		
		aTpsSol[2] := aCpos
		aCpos	:= {}
		lOutros	:= .T.
		lTurno	:= .T.
		
	Elseif cTipoAtu $ '3' //Os dados da troca de turno(4) e da carga horária(3) serão atualizados em conjunto **Verificar
		
		aTpsSol[5] := aCpos
		aCpos	:= {}
		lOutros	:= .T.
		lTurno	:= .T.	
		
	Elseif cTipoAtu == '2'
		
		aTpsSol[3] := aCpos
		aCpos	:= {}
		lOutros	:= .T.
		
	Elseif cTipoAtu == '1'
		
		aTpsSol[4] := aCpos
		aCpos	:= {}
		lOutros	:= .T.
	EndIf
	
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
	Local dDtTur	:= Ctod('16/' + Strzero(Month(dDataBase),2) + "/" + Str(Year(dDataBase)))
	Local dDataAtu	:= MSDATE()
	Local dMesBase
	 
	/*
	REGRA:
	Solicitações abertas até dia 20 do mês corrente, tem como base o mês corrente + 1 e caso seja posterior será o mês + 2
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
	/*	
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
			Help("",1, "Help", "Validação de Data de Aprovação(F0500402_04)", "Mês base menor que mês da data da solicitação. Efetivação não será realizada!" , 3, 0)
			lVlDt	:= .F.
		EndIf
		
	ElseIf ( MesAno(dDataAtu) >= dMesBase )
		lContin	:= .T.
	Else
		Help("",1, "Help", "Validação de Data de Aprovação(F0500402_05)", "Dia/Mês não permitido para efetivação para este tipo de solicitação aprovada!" , 3, 0)
		lVlDt	:= .F.
	EndIf
	
	If lContin		
		//Caso exista Troca de Turno
		If lTurno .AND. !lOutros .AND. ( MesAno(dDataAtu) < dMesBase )	//?cDiaAtu <> Day(dDtTur)
			
			Help("",1, "Help", "Validação de Data de Aprovação(F0500402_03)", "A efetivação para a Troca de Turno somente poderá ocorrer dia 16 ou o 1 dia mês posterior a data da solicitação!" , 3, 0)
			lVlDt	:= .F.
			
		Elseif !lTurno .AND. lOutros .AND. ( MesAno(dDataAtu) < dMesBase )	//?cDiaAtu <> Day(dDtTur)
			
			Help("",1, "Help", "Validação de Data de Aprovação(F0500402_02)", "As efetivações para este tipo de solicitação devem ser executadas a partir do dia 01 do mês posterior a data da solicitação!" , 3, 0)
			lVlDt	:= .F.
		EndIf
	EndIf
	
Return lVlDt
*/
/*{Protheus.doc} AtSalari
Realiza a atualização salarial
@type function
@author Cris
@since 04/11/2016
@version P12.1.7
@Project MAN0000007423039_EF_004
@return lAtuSal, Se efetuou a atualização salarial
*/
Static Function AtSalari(aCpos,cFilFun,cMatFun,dDtaSol,dM1Sal,cTipoAtu)
	
	Local aAreaSRA	:= SRA->(GetArea())
	Local nSalAnt	:= 0
	Local lAtuSal	:= .T. 
	Local nPerTol	:= 0	
	Local cTabNov	:= ""
	Local cTabNiv	:= ""
	Local cTabFxa	:= ""
	Local aFaixa	:= {}
	Local nX		:= 0
	Local nSalTran	:= 0 
	
	//Caso tenha ocorrido transferência
		If cFilNova <> cFilAnt	
			cFilFun	:= cFilNova
		EndIf
	
	//nSalAnt	:= SRA->RA_SALARIO Thais Paiva - 10037508
		
	SRA->(dbSetOrder(1))
	If SRA->(DbSeek(cFilFun + cMatFun))
		
		nSalAnt	:= SRA->RA_SALARIO //Thais Paiva - 10037508

		RCA->(dbSetOrder(1))
		If RCA->(dbSeek(FwxFilial("RCA")+"M_PERCTOL"))
			nPerTol	:= Val(RCA->RCA_CONTEU)
		EndIf
		
		nSalTran	:= Val(StrTran(StrTran(Alltrim(aCpos[1][2]),".",""),",","."))
		
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
		SRA->RA_SALARIO	:=  Val(StrTran(StrTran(Alltrim(aCpos[1][2]),".",""),",","."))
		SRA->RA_ANTEAUM	:=  Val(StrTran(StrTran(Alltrim(aCpos[1][2]),".",""),",","."))//Conforme EF mantendo os dois iguais, para manter a integridade do calculo de Dissidio Retroativo.
		SRA->RA_TABELA 	:= cTabNov
		SRA->RA_TABNIVE := cTabNiv 
		SRA->RA_TABFAIX := cTabFxa
		
		SRA->(MsUnlock())
		
		If SRA->RA_SALARIO == nSalAnt
			Help("",1, "Help", "Atualização Salarial(AtSalari_01)", "Não foi possível efetuar a atualização salarial. Efetue manualmente!" , 3, 0)
			//lAtuSal	:= .F. // ticket n° 7958390 -- salário atual igual ao proposto, o processo continua mas não grava na SR3 e SR7
		Else
			GrvSR3R7(aCpos,cFilFun,cMatFun,dDtaSol,dM1Sal)
			//lAtuSal	:= .T. // ticket n° 7958390 -- o processo continua normalmente
		EndIf
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
Static Function AtCargo(aCpos,cFilFun,cMatFun,dDtaSol,dM1Car)
	
	Local aAreaSRA	:= SRA->(GetArea())
	Local aAreaTN0	:= TN0->(GetArea())
	Local lAltCarg	:= .F.
	Local dDtAtu	:= Iif(dDtaSol <> NIL, dDtaSol, MsDate())	//?MsDate()
	Local cAnoMes1	:= ""                
	Local cCodFunc	:= Alltrim(aCpos[1][2])
	Local nPerTol	:= 0	
	Local cTabNov	:= ""
	Local cTabNiv	:= ""
	Local cTabFxa	:= ""
	Local aFaixa	:= {}
	Local nX		:= 0
	Local nSalTran	:= 0 
	
	If DAY(dDtAtu) <= 20
		cAnoMes1 := SomaMesAno( dDtAtu )
	Else
		cAnoMes1 := SomaMesAno( dDtAtu )
		cAnoMes1 := SomaMesAno( cAnoMes1 )
	EndIf
	
	dDtAtu := STOD( Alltrim(cAnoMes1) + "01" )
	
	//Caso tenha ocorrido transferência
	If cFilNova <> cFilAnt	
		cFilFun	:= cFilNova
	EndIf
	
	dbSelectArea("SRA")
	SRA->(dbSetOrder(1))
	If SRA->(DbSeek(cFilFun + cMatFun))

		RCA->(dbSetOrder(1))
		If RCA->(dbSeek(FwxFilial("RCA")+"M_PERCTOL"))
			nPerTol	:= Val(RCA->RCA_CONTEU)
		EndIf
		
		nSalTran	:= SRA->RA_SALARIO
		
		SQ3->(DbSetOrder(1))
		If SQ3->(DbSeek(FwxFilial("SQ3")+cCodFunc))
			aFaixa := BscFxSal(cCodFunc, cFilFun, ,,SRA->RA_HRSMES)	
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
		dDtOper := date() // 10/07/2018 : 416094 - Rogerio Carvalho AMS-Rio / DOR04520620  
	    cHrOper := time() // 10/07/2018 : 416094 - Rogerio Carvalho AMS-Rio / DOR04520620		
		SRA->(RecLock("SRA",.F.))
		SRA->RA_CARGO	:= Alltrim(aCpos[1][2])
		SRA->RA_CODFUNC	:= Alltrim(aCpos[1][2])
		SRA->RA_TABELA 	:= cTabNov
		SRA->RA_TABNIVE := cTabNiv 
		SRA->RA_TABFAIX := cTabFxa
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
		
		//Certifico que atualizou o cargo
		If (lAltCarg := (Alltrim(aCpos[1][2]) == SRA->RA_CARGO .AND. Alltrim(aCpos[1][2]) == SRA->RA_CODFUNC ))
			//Quando existir em única solicitação a alteração de Cargo com Salário,único log nas tabelas SR3 e SR7 deverá ser gerado,
			//portanto grava-se o cargo e  depois o salário.
			If aTpsSol[4] == Nil
				
				//Tabelas de históricos de alteração salarial e cargo
				GrvSR3R7(aCpos,cFilFun,cMatFun,dDtaSol,dM1Car)
				
				//tabelas de histórico de alteração de campo
				// 10/07/2018 : 416094 - Rogerio Carvalho AMS-Rio / DOR04520620
				GrvSR9b(cFilFun,cMatFun,dDtAtu/*Msdate()*/,'RA_CARGO',Alltrim(aCpos[1][2]),dDtOper,cHrOper,dM1Car)
				// FIM 10/07/2018 : 416094 - Rogerio Carvalho AMS-Rio / DOR04520620
			EndIf
			
			lAltCarg	:= .T.
		EndIf
	Else
		Help("",1, "Help", "INSUCESSO - Cargo(AtCargo_01)", "Não foi localizado o funcionário " + cMatFun + " na filial de destino " + cFilFun + ". Os campos cargo/função não foram atualizados!" , 3, 0)
		lAltCarg	:= .F.
	EndIf
	
	RestArea(aAreaSRA)
	RestArea(aAreaTN0)
Return lAltCarg

/*{Protheus.doc} GrvSR3R7
Gravação dos Historicos de Valores e Alterações Salariais
@author Cris
@since 09/11/2016
@version P12.1.7
@Project MAN0000007423039_EF_004
*/
Static Function GrvSR3R7(aCpos,cFilFun,cMatFun,dDtaSol,dGrR3R7)
	
	Local cSeq	:= ''
	Local dDtAtu	:= Iif(dDtaSol <> NIL, dDtaSol, MsDate())	//?MsDate()
	Local cAnoMes1	:= ""
	Local dDtOper   
	Local cHrOper	
		
	/*
	REGRA:
	Solicitações abertas até dia 20 do mês corrente, tem como base o mês corrente + 1 e caso seja posterior será o mês + 2
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
	
	dDtAtu := STOD( Alltrim(cAnoMes1) + "01" )
	
	dbSelectArea("SR3")
	SR3->(dbSetOrder(1))
	If SR3->(DbSeek(cFilFun + cMatFun + Dtos(dDtAtu) + Alltrim(aCpos[2][2])))
		
		While cFilFun + cMatFun + Dtos(dDtAtu) + Alltrim(aCpos[2][2]) == SR3->(R3_FILIAL + R3_MAT + Dtos(R3_DATA) + R3_TIPO)
			
			cSeq	:= SR3->R3_SEQ
			
			SR3->(dbSkip())
		EndDo
		
	EndIf
	
	dDtOper := date()
	cHrOper := time()
		
	SR3->(RecLock("SR3",.T.))
	SR3->R3_FILIAL  := cFilFun
	SR3->R3_MAT     := cMatFun
	SR3->R3_DATA    := dGrR3R7 //dDtAtu
	SR3->R3_SEQ		:= StrZero(Val(cSeq) + 1,1)
	SR3->R3_PD      := "000"
	SR3->R3_DESCPD  := "SALARIO BASE"
	SR3->R3_VALOR   := SRA->RA_SALARIO
	SR3->R3_TIPO    := Alltrim(aCpos[2][2])
	SR3->R3_ANTEAUM	:= SRA->RA_SALARIO

	SR3->R3_TABELA	:= SRA->RA_TABELA
	SR3->R3_TABFAIX	:= SRA->RA_TABFAIX
	SR3->R3_TABNIVE	:= SRA->RA_TABNIVE	
	SR3->R3_XDTOPER	:= dDtOper
	SR3->R3_XHROPER	:= cHrOper
	SR3->R3_XINTINC := " "
	SR3->R3_XIDINC  := "                                "	
			
	SR3->(MsUnLock())

	If IsInCallStack("AtSalari")		
		//Chama rotina de integração quando alteração salarial
	// 10/07/2018 : 416094 - Rogerio Carvalho - AMS Rio - DOR04520620
		//U_F0600901("F0600301",; // cFunc
		//SR3->(RECNO()),; // nRecno
		//"SR3",; // cAliasTrb
		//SR3->R3_FILIAL + SR3->R3_MAT + DTOS(SR3->R3_DATA) + SR3->R3_TIPO,; // cChave
		//"",; // cObs
		//CTOD(""),; // Data de envio
		//"UPSERT") // Operacao
	// FIM 10/07/2018 : 416094 - Rogerio Carvalho - AMS Rio - DOR04520620
	EndIf
	
	dbSelectArea("SR7")
	SR7->(dbSetOrder(1))
	If SR7->(DbSeek(cFilFun + cMatFun + Dtos(dDtAtu) + Alltrim(aCpos[2][2])))
		
		While cFilFun + cMatFun + Dtos(dDtAtu) + Alltrim(aCpos[2][2]) ==  SR7->(R7_FILIAL + R7_MAT + Dtos(R7_DATA) + R7_TIPO)
			
			cSeq	:= SR7->R7_SEQ
			
			SR7->(dbSkip())
		EndDo
		
	EndIf
	
	dbSelectArea("SR7")
	If SR7->(RecLock("SR7",.T.))
		SR7->R7_FILIAL   := cFilFun
		SR7->R7_MAT      := cMatFun
		SR7->R7_DATA     := dGrR3R7 //dDtAtu	//?MsDate()
		SR7->R7_TIPO     := Alltrim(aCpos[2][2])
		SR7->R7_FUNCAO   := SRA->RA_CODFUNC
		SR7->R7_DESCFUN  := POSICIONE("SRJ",1,xFilial("SRJ") + SRA->RA_CODFUNC,"RJ_DESC")
		SR7->R7_TIPOPGT  := SRA->RA_TIPOPGT
		SR7->R7_CATFUNC  := SRA->RA_CATFUNC
		SR7->R7_USUARIO  := Alltrim(cUsername) + '|' + Alltrim(LogUserName())
		If SR7->( Type("R7_CARGO") ) # "U"
			SR7->R7_CARGO   := SRA->RA_CARGO
		EndIf
		If SR7->( Type("R7_DESCCAR") ) # "U"
			SR7->R7_DESCCAR	:= POSICIONE("SQ3",1,xFilial("SQ3") + SRA->RA_CARGO,"Q3_DESCSUM")
		EndIf
		SR7->R7_SEQ		:= StrZero(Val(cSeq) + 1,1)

		SR7->R7_XDTOPER	:= dDtOper  // 416094 - Rogerio Carvalho - AMS Rio - 01/07/2018 - DOR04520620
		SR7->R7_XHROPER	:= cHrOper  // 416094 - Rogerio Carvalho - AMS Rio - 01/07/2018 - DOR04520620
		SR7->R7_XINTINC := " "      // 416094 - Rogerio Carvalho - AMS Rio - 01/07/2018 - DOR04520620
		SR7->R7_XIDINC  := "                                " // 416094 - Rogerio Carvalho - AMS Rio - 01/07/2018 - DOR04520620		
				
		SR7->( MsUnLock() )
	EndIf

        // 416094 - Rogerio Carvalho - AMS Rio - 01/07/2018 - DOR04520620
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
Static Function ATTurHor(aCpos,cFilFun,cMatFun,dDtaSol,aCpCarg,dM1TH,lTurOK,lOnTrf)
	
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
	Local dDtOper   
	Local cHrOper
	Local dDtTur 
	//Chamado 10182469
	Local lIncluiSPF := .F.	
	
	Default aCpos	:= {}
	Default cFilFun := ""
	Default cMatFun := ""
	Default dDtaSol := CTOD("//")
	Default aCpCarg := {}
	
	/*
	REGRA:
	Solicitações abertas até dia 20 do mês corrente, tem como base o mês corrente + 1 e caso seja posterior será o mês + 2
	Exemplo: 
	Data Solicitação 20/03/2017 -> Alteração salarial com início em 01/04/2017
	Data Solicitação 21/03/2017 -> Alteração salarial com início em 01/05/2017
	*/
	// ticket n° 8135802 - 415966 - Validação considerando virada de ano
	If Year(dDtAtu) < Year(dDataBase)
		If Month(dDtAtu) < Month(dDataBase) + 12 
			dDtTur := DaySum(FirstDate(dDataBase),15)
		ElseIf Month(dDtAtu) == Month(dDataBase)
			If Day(dDtAtu) <= 15
				dDtTur := DaySum(FirstDate(dDataBase),15)
			Else	
				dDtTur := DaySum(FirstDate(MonthSum(dDataBase,1)),15)
			EndIf
		EndIf
	else
	//  Paulo - 19/12/2018
		If Month(dDtAtu) < Month(dDataBase) 
			dDtTur := DaySum(FirstDate(dDataBase),15)
		ElseIf Month(dDtAtu) == Month(dDataBase)
			If Day(dDtAtu) <= 15
				dDtTur := DaySum(FirstDate(dDataBase),15)
			Else	
				dDtTur := DaySum(FirstDate(MonthSum(dDataBase,1)),15)
			EndIf
		EndIf
	EndIf
	/*
	If month(dDtAtu) < month(dDatabase) 
			dDtTur := DaySum(FirstDate(MonthSum(dDtAtu,1)),15)
	Elseif month(dDtAtu) == month(dDatabase)
		If Day(dDtAtu) <= 20
		   dDtTur := DaySum(FirstDate(MonthSum(dDtAtu,1)),15)
	    Elseif Day(dDtAtu) > 20
		   dDtTur := DaySum(FirstDate(MonthSum(dDtAtu,2)),15)
	    Endif
	Endif
	*/
		//If DAY(dDtAtu) <= 20
			//cAnoMes1 := SomaMesAno( dDtAtu )
			//dDtTur := STOD( Alltrim(cAnoMes1) + "16" )
		//Else
			//cAnoMes1 := SomaMesAno( dDtAtu )
			//dDtTur := STOD( Alltrim(cAnoMes1) + "16" )
			//cAnoMes1 := SomaMesAno( cAnoMes1 )
		//Endif
	
	//dDtAtu := STOD( Alltrim(cAnoMes1) + "01" )
		If lOnTrf //ticket n° 7086894 - 415966 - Paulo Dias - validação se houve a transferência através do parâmetro lExeTrans
			//Caso tenha ocorrido transferência
			if cFilNova <> cFilAnt	
				cFilFun	:= cFilNova
			EndIf
		EndIf
	
	//Garanto que realmente esta posicionado no funcionario relacionado a solicitação
	dbSelectArea("SRA")
	SRA->(dbSetOrder(1))
	If SRA->(DbSeek(cFilFun + cMatFun))
		
		cTurnAnt := SRA->RA_TNOTRAB
		cTSeqAnt := SRA->RA_SEQTURN
		cRegrAnt := SRA->RA_REGRA
		
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
				//Início - Ticket 9368427 - 22/07/2020 - Lucas Aguiar/Thais Paiva 
				If Alltrim(SRA->RA_ADCPERI) == '2' 
					SRA->RA_PERICUL := Val(AllTrim(aCpCarg[1][2])) 
				ElseIf Alltrim(SRA->RA_ADCPERI) == '1' 
					SRA->RA_PERICUL := 0.00
				EndIf 
				//Fim - Ticket 9368427 - 22/07/2020 - Lucas Aguiar/Thais Paiva
			Else
				&(aCpCarg[iCpoCg][1])	:= aCpCarg[iCpoCg][2]
				//Início - Ticket 9368427 - 22/07/2020 - Lucas Aguiar/Thais Paiva
				If Alltrim(SRA->RA_ADCPERI) == '2' 
					SRA->RA_PERICUL := AllTrim(aCpCarg[1][2]) 
				ElseIf Alltrim(SRA->RA_ADCPERI) == '1' 
					SRA->RA_PERICUL := 0.00
				EndIf 
				//Fim - Ticket 9368427 - 22/07/2020 - Lucas Aguiar/Thais Paiva
			EndIf
		Next		
		
		SRA->(MsUnlock())

		// ticket 3138519 [AMS] - Paulo Dias - 29/06/2018
		If lTurOK
			dTurCh := dDtTur
		Else 
			dTurCh := dM1TH
		Endif
		// Fim  ticket 3138519 [AMS] - Paulo Dias - 29/06/2018
		
		aAreaSPF	:= SPF->(GetArea())
		
		dbSelectArea("SPF")//PONA160.PRW
		SPF->(dbSetOrder(1))
		//chamado 10182469 (dbseek sem data posicionava em registro errado)
		lIncluiSPF := !SPF->(DbSeek(cFilFun + cMatFun + DtoS(dTurCh)) )
		// If SPF->( RecLock( "SPF" , !SPF->(DbSeek(cFilFun + cMatFun) ) ))
		If SPF->( RecLock( "SPF" , lIncluiSPF ))
			dDtOper         := date()
			cHrOper         := time()			
			SPF->PF_FILIAL	:= cFilFun
			SPF->PF_MAT		:= cMatFun
			SPF->PF_DATA	:= dTurCh //dDtTur ticket 3138519 [AMS] - Paulo Dias - 29/06/2018
			SPF->PF_TURNODE	:= cTurnAnt
			SPF->PF_SEQUEDE := cTSeqAnt
			SPF->PF_REGRADE := cRegrAnt
			SPF->PF_TURNOPA	:= iif((nPosCpo := AScan(aCpos,{|x,y| Alltrim(x[1]) == "RA_TNOTRAB"})) > 0, Alltrim(aCpos[nPosCpo][2]),cTurnAnt)
			SPF->PF_SEQUEPA := iif((nPosCpo := AScan(aCpos,{|x,y| Alltrim(x[1]) == "RA_SEQTURN"})) > 0, Alltrim(aCpos[nPosCpo][2]),cTSeqAnt)
			SPF->PF_REGRAPA := iif((nPosCpo := AScan(aCpos,{|x,y| Alltrim(x[1]) == "RA_REGRA"})) > 0, Alltrim(aCpos[nPosCpo][2]),cRegrAnt)
			SPF->PF_XDTOPER := dDtOper
			SPF->PF_XHROPER := cHrOper
			SPF->PF_XINTINC := " "
			SPF->PF_XIDINC  := "                                "
			
			SPF->(MsUnLock())

		EndIf
	// 10/07/2018 : 416094 - Rogerio Carvalho - AMS Rio - DOR04520620
		//U_F0600901("F0600301",; // cFunc 
		//			SPF->(RECNO()),; // nRecno 
		//			"SPF",; // cAliasTrb 
		//			SPF->PF_FILIAL + SPF->PF_MAT + DTOS(SPF->PF_DATA),; // cChave 
		//			"",; // cObs
		//			CTOD(""),; // Data de envio
		//			"UPSERT") // Operacao
	// FIM 10/07/2018 : 416094 - Rogerio Carvalho - AMS Rio - DOR04520620	
		RestArea(aAreaSPF)
		
		nPosTrn := AScan(aCpos,{|x,y| Alltrim(x[1]) == 'RA_TNOTRAB'})
		If nPosTrn > 0
			cDescTur := Posicione("SR6",1,xFilial("SR6") + Alltrim(aCpos[nPosTrn][2]),"R6_DESC")
			GrvSR9b(cFilFun,cMatFun,dDtTur,'RA_TNOTRAB',cDescTur,dDtOper,cHrOper,dTurCh)
		EndIf
		
		nPosHr := AScan(aCpCarg,{|x,y| Alltrim(x[1]) == 'RA_HRSMES'})
		If nPosHr > 0 
			GrvSR9b(cFilFun,cMatFun,dDtAtu,'RA_HRSMES',Alltrim(aCpCarg[nPosHr][2]),dDtOper,cHrOper,dTurCh)
		EndIf

	EndIf
	
	RestArea(aAreaSRA)
	
Return lAtuTurn

/*{Protheus.doc} GrvSR9b
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

// 10/07/2018 : 416094 - Rogerio Carvalho - AMS Rio - DOR04520620 - dDtOpSR9,cHrOpSR9
Static Function GrvSR9b(cFilFun,cMatFun,dDtReal,cCpoAlt,cCntAlt,dDtOpSR9,cHrOper,dM1SR9)
	
	Local aAreaAtu	:= SR9->(GetArea())
	Default dDtOpSR9 := ctod("  /  /    ") // ticket 3138519 [AMS] - Paulo Dias - 29/06/2018
	Default cHrOper	 := " "
	

	dbSelectArea("SR9")
	If SR9->(Reclock('SR9',.T.))
		SR9->R9_FILIAL	:= cFilFun
		SR9->R9_MAT		:= cMatFun
		SR9->R9_DATA	:= dM1SR9 //dDtReal ticket 3138519 [AMS] - Paulo Dias - 29/06/2018
		SR9->R9_CAMPO 	:= cCpoAlt
		SR9->R9_DESC	:= cCntAlt
		SR9->R9_XDTOPER := dDtOpSR9 // 10/07/2018 : 416094 - Rogerio Carvalho - AMS Rio - DOR04520620
		SR9->R9_XHROPER := cHrOper  // 10/07/2018 : 416094 - Rogerio Carvalho - AMS Rio - DOR04520620
		SR9->R9_XINTINC := " "      // 10/07/2018 : 416094 - Rogerio Carvalho - AMS Rio - DOR04520620
		SR9->R9_XIDINC  := "                                " // 10/07/2018 : 416094 - Rogerio Carvalho - AMS Rio - DOR04520620
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
 // FIM 10/07/2018 : 416094 - Rogerio Carvalho - AMS Rio - DOR04520620	
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
	
		nScan := AScan( aCpos, {|x|, Alltrim(x[01]) == "RA_FILIAL" })
		If nScan > 0
	
			cFilP := Padr(aCpos[nScan][02],nTamFil)
			cFilNova	:= cFilP
	
			// Verifica se mudou Depto - SQB
			If !Empty(AllTrim(xFilial("SQB")))
				nScan := AScan( aCpos, {|x|, Alltrim(x[01]) == "RA_DEPTO" })
				If nScan > 0
					cDeptoP := Alltrim(aCpos[nScan][02])
					
					aAreaAtu	:= SQB->(GetArea())
					
					//Verifica se o depto existe na filial destino
					DbSelectArea("SQB")
					SQB->(DbSetOrder(1))
					If !SQB->(DbSeek(cFilP + cDeptoP))
						cMsgErro +="Depto: " + AllTrim(cDeptoP) + " nâo existe na filial de destino: " + cFilP	+ "." + CRLF
					EndIf
					
					RestArea(aAreaAtu)
				EndIf
			EndIf
			
			// Verifica se mudou CC - CTT
			If !Empty(AllTrim(xFilial("CTT")))
				nScan := AScan( aCpos, {|x|, Alltrim(x[01]) == "RA_CC" })
				If nScan > 0
					cCCP := aCpos[nScan][02]
					//Verifica se o CC existe na filial destino
					
					aAreaAtu	:= CTT->(GetArea())
					
					DbSelectArea("CTT")
					CTT->(DbSetOrder(1))
					If !CTT->(DbSeek(cFilP + cCCP))
						cMsgErro +="C. Custo: " + AllTrim(cCCP) + " nâo existe na filial de destino: " + cFilP	+ "." + CRLF
					EndIf
					
					RestArea(aAreaAtu)
				EndIf
			EndIf
			
			// Verifica se mudou Processo - RCJ
			If !Empty(AllTrim(xFilial("RCJ")))
				nScan := AScan( aCpos, {|x|, Alltrim(x[01]) == "RA_PROCES" })
				If nScan > 0
					cProcP := aCpos[nScan][02]
					//Verifica se o Processo existe na filial destino
					
					aAreaAtu	:= RCJ->(GetArea())
					
					DbSelectArea("RCJ")
					RCJ->(DbSetOrder(1))
					If !RCJ->(DbSeek(cFilP + cProcP))
						cMsgErro +="Processo: " + AllTrim(cProcP) + " nâo existe na filial de destino: " + cFilP	+ "." + CRLF
					EndIf
					
					RestArea(aAreaAtu)
				EndIf
			EndIf
			
			
			// Verifica se mudou Função - SRJ
			If !Empty(AllTrim(xFilial("SRJ")))
				nScan := AScan( aCpos, {|x|, Alltrim(x[01]) == "RA_CODFUNC" })
				If nScan > 0
					cFuncP := aCpos[nScan][02]
					//Verifica se a função existe na filial destino
					aAreaAtu	:= SRJ->(GetArea())
					
					DbSelectArea("SRJ")
					SRJ->(DbSetOrder(1))
					If !SRJ->(DbSeek(cFilP + cFuncP))
						cMsgErro +="Função: " + AllTrim(cFuncP) + " nâo existe na filial de destino: " + cFilP	+ "." + CRLF
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
Static Function AtTransf( oModel, aCpos, cFilFun, cMatFun, dDtaSol )
	
	Local lRet     := .F.
	Local dDtAtu   := MsDate()
	Local dDtaRef  
	Private lLote  := .F.
		
	/*
	REGRA:
	Solicitações abertas até dia 20 do mês corrente, tem como base o mês corrente + 1 e caso seja posterior será o mês + 2
	Exemplo: 
	Data Solicitação 20/03/2017 -> Alteração salarial com início em 01/04/2017
	Data Solicitação 21/03/2017 -> Alteração salarial com início em 01/05/2017
	*/

	//If DAY(dDtAtu) <= 20
	//	cAnoMes1 := dDtAtu 
	//Else
		//cAnoMes1 := SomaMesAno( dDtAtu )
		//cAnoMes1 := SomaMesAno( cAnoMes1 )
	//EndIf
	
	dDtaRef := FirstDate(dDtAtu)
		
	DbSelectArea("SRA")
	SRA->(DbSetOrder(1))
	If SRA->(DbSeek(cFilFun + cMatFun))
		lRet := TCFA040Atende(oModel,"2",dM1Dt)
	Else
		lRet := .F.
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
Static Function TCFA040Atende( oModel, cStatus, dDtAtu )
	
	Local oModRH3   			:= oModel:GetModel("RH3MASTER") //oModel:GetModel("TCFA040_RH3")
	Local lRet				  	:= .F.
	Local nI 		 			:= 0
	Local dM1Trf
	Local cSRAFILORI			:= "" // DOR05218784 - 18/10/2018 - 416094 - Rogerio Carvalho
	Local cSRAPOSORI 			:= "" // DOR05218784 - 18/10/2018 - 416094 - Rogerio Carvalho
	Local cREFILDES				:= "" // DOR05218784 - 18/10/2018 - 416094 - Rogerio Carvalho
	Local cREPOSDES				:= "" // DOR05218784 - 18/10/2018 - 416094 - Rogerio Carvalho
	Local cSraMatF				:= "" // DOR05218784 - 18/10/2018 - 416094 - Rogerio Carvalho
	Private cCadastro 			:= ""
	Private cTipSolicPortal		:= ""
	Private cFilFun    			:= ""
	Private cMatFun   			:= ""
	Private dFerDtIni		   	:= CToD("")
	Private dFerDtFim		   	:= CToD("")
	Private nFerDuracao			:= 0
	Private cCodSolic  			:= oModRH3:GetValue("RH3_CODIGO") // RH3->RH3_CODIGO
	Private aCPosPortal			:= {}
	Private bParamPortal		:= {|| .T.}
	Private lUseSPJ            	:= If(cPaisLoc == "BRA",.T., SuperGetMv("MV_USESPJ",NIL,"0")  == "1" )
	Private cRH3Cod				:= ''
	
	//variaveis usadas (RH3_TIPO = '2') na alteraÃ§Ã£o cadastral eSocial.
	Private aCpoSRA := {}
	Private lMsErroAuto    		:= .F.
	Private lMsHelpAuto    		:= .T.
	Private lAutoErrNoFile 		:= .T.
	
	//variaveis usadas no GPEA050
	Private lIncSRA				:= .T.
	Private lInitDesc
	Private lHabAba 			:= .F.				//Variavel para habilitar a aba de ProgramaÃ§Ã£o de fÃ©rias
	Private cOrgCfg				:= SuperGetMv("MV_ORGCFG", NIL, "0" )	//-- Controlde de Postos : 0-nÃ£o usa Sigaorg;1-Tem controle de postos; 2- nÃ£o tem  controle de postos
	Private cGsPubl 			:= SuperGetMv("MV_GSPUBL",,"1")
	Private cContrMat			:= SuperGetMv( "MV_MATRICU", NIL, "0")
	Private lCtrAutoMat			:= .F.					//Checa se o controle Automatico de Matricula esta ativado e se havera transferencia de matricula
	
	If cGsPubl == "2" .And. GetMv("MV_VDFLOGO",,"0") <> "0"
		cGsPubl := "3"
	EndIf
	
	// **************************** Transferencia
	Private cCodTrasfPortal 	:=  oModRH3:GetValue("RH3_CODIGO") // RH3->RH3_CODIGO
	
	//-- Variaveis utilizadas pelo GPEA180
	Private cItemClVl       	:= SuperGetMv( "MV_ITMCLVL", .F., "2" )
	Private lItemClVl       	:= SuperGetMv( "MV_ITMCLVL", .F., "2" ) $ "13"
	Private aLogTransf			:= {}
	Private aTransfCols 		:= {}
	Private aTransf1Cols    	:= {}
	
	Private aNewIndexSRA  		:= {}
	Private bNewFiltroBrw 		:= {|| NIL }
	Private cMarkTransf			:= GetMark()
	Private cRaOkTransSpc		:= Space( TamSx3( "RA_OKTRANS" )[1] )
	Private lAbortPrint			:= .F.
	
	Private LGERADEM            := .T.
	Private dDataTra            := dDtAtu
	Private lRobo    := .F. // ticket n° 9303216
	Private dDataTAF := dDtAtu // ticket n° 9303216
	
	cCadastro               	:= OemToAnsi( "TransferË†ncias" )  //"TransferË†ncias"
	cTipSolicPortal         	:= "4"
	
	DbSelectArea( "SRA" )
	SRA->(DbSetOrder( RetOrder( "SRA", "RA_FILIAL + RA_MAT") ))
	
	If SRA->(DbSeek(RH3->RH3_FILIAL + RH3->RH3_MAT))
		// DOR05218784 - 18/10/2018 - 416094 - Rogerio Carvalho
		cSRAFILORI := SRA->RA_FILIAL	// DOR05218784 - Pega Filial Origem da Transferencia de Posto
		cSRAPOSORI := SRA->RA_POSTO		// DOR05218784 - Pega Posto Origem da Transferencia de Posto
		cSraMatF   := SRA->RA_MAT
		
		BEGIN TRANSACTION
			
			RecLock("SRA",.F.)
			SRA->RA_OKTRANS := cMarkTransf
			SRA->(MsUnlock())
			
		END TRANSACTION
		
		RH4->(DbSeek(RH3->(RH3_FILIAL + RH3_CODIGO)))
		
		// Inicializa as variaveis com o destino do funcionÃ¡rio
		M->RE_EMPP 		:= cEmpAnt
		M->RE_FILIALP 	:= ""
		M->RE_MATP 		:= ""
		M->RE_DEPTOP 	:= ""
		M->RE_PROCESP 	:= ""
		M->RE_CCP       := ""
		M->RA_DESCCC	:= ""
		M->RE_POSTOP	:= ""
		M->RE_DATA      := dDtAtu
		
		While !RH4->(Eof()) .AND. RH4->(RH4_FILIAL + RH4_CODIGO) == RH3->(RH3_FILIAL + RH3_CODIGO)
			If AllTrim(RH4->RH4_CAMPO) == "RE_EMPP"
				M->RE_EMPP := Left(RH4->RH4_VALNOV, Len(SRE->RE_EMPP))
			ElseIf AllTrim(RH4->RH4_CAMPO) == "RE_FILIALP" .Or. AllTrim(RH4->RH4_CAMPO) == "RA_FILIAL"
				M->RE_FILIALP := Left(RH4->RH4_VALNOV, Len(SRA->RA_FILIAL))
			ElseIf AllTrim(RH4->RH4_CAMPO) == "RE_MATP" .Or. AllTrim(RH4->RH4_CAMPO) == "RA_MAT"
				M->RE_MATP := Left(RH4->RH4_VALNOV, Len(SRE->RE_MATP))
			ElseIf AllTrim(RH4->RH4_CAMPO) == "RE_DEPTOP" .Or. AllTrim(RH4->RH4_CAMPO) == "RA_DEPTO"
				M->RE_DEPTOP := Left(RH4->RH4_VALNOV, Len(SRE->RE_DEPTOP))
			ElseIf AllTrim(RH4->RH4_CAMPO) == "RE_CCP" .Or. AllTrim(RH4->RH4_CAMPO) == "RA_CC"
				M->RE_CCP    := Left(RH4->RH4_VALNOV, Len(SRE->RE_CCP))
				M->RA_DESCCC := fDesc("CTT",Left(RH4->RH4_VALNOV, Len(SRA->RA_CC)),"CTT_DESC01",,)//SRA->RA_FILIAL))
			ElseIf AllTrim(RH4->RH4_CAMPO) == "RE_PROCESP" .Or. AllTrim(RH4->RH4_CAMPO) == "RA_PROCES"
				M->RE_PROCESP := Left(RH4->RH4_VALNOV, Len(SRE->RE_PROCESP))
			ElseIf AllTrim(RH4->RH4_CAMPO) == "RE_POSTOP" .Or. AllTrim(RH4->RH4_CAMPO) == "RA_POSTO"
				M->RE_POSTOP := Left(RH4->RH4_VALNOV, Len(SRE->RE_POSTOP))
			ElseIf AllTrim(RH4->RH4_CAMPO) == "RE_ITEMP" .Or. AllTrim(RH4->RH4_CAMPO) == "RA_ITEM"
				M->RE_ITEMP := Left(RH4->RH4_VALNOV, Len(SRE->RE_ITEMP))
			ElseIf AllTrim(RH4->RH4_CAMPO) == "RE_CLVLP" .Or. AllTrim(RH4->RH4_CAMPO) == "RA_CLVL"
				M->RE_CLVLP := Left(RH4->RH4_VALNOV, Len(SRE->RE_CLVLP))
			EndIf
			RH4->(DbSkip())
		EndDo
		
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
		

	EndIf
	// DOR05218784 - 18/10/2018 - 416094 - Rogerio Carvalho
	cREFILDES := M->RE_FILIALP // DOR05218784 - Pega Filial Destino para Transferencia de Posto
	cREPOSDES := M->RE_POSTOP  // DOR05218784 - Pega Posto Destino para Transferencia de Posto
	
	// DOR05218784 - Trata RCL para Transferencia de Posto
	// Chama função para ajustar os postos , em relação a qtd de titulares e substitutos
    //	alert("Matricula : "+cSraMatF+" --- Ajustando Postos - Filial/Posto (Origem) : "+ cSRAFILORI+"/"+cSRAPOSORI+" --- Filial/Posto (Destino) : "+ cREFILDES+"/"+cREPOSDES)
    	u_AmsTrfPost(cSraMatF,cSRAFILORI,cSRAPOSORI,cREFILDES,cREPOSDES) 
	//  DOR05218784 - 18/10/2018 - 416094 - Rogerio Carvalho
	
Return( lRet )

/*{Protheus.doc} ValPosto
Valida se existe disponibilidade no posto de destino
@author Cris
@since 23/11/2016
@version P12.1.7
@Project MAN0000007423039_EF_004
@return lValPosto, ${.T. válido  .F. não valido}
*/
Static Function ValPosto(cFilSol,cCodSol)
	
	Local cDepto	:= ''
	Local cFilAt	:= ''
	Local cCCAt		:= ''
	Local cCodCarg	:= ''
	Local cQry		:= ''
	Local nQtdePost	:= 0
	Local nPosCpo	:= 0
	Local cTabAtu	:= ''
	Local lValPosto	:= .T.
	Local aAreaSRA	:= SRA->(GetArea())
	Local lLibPst   := SuperGetMv("FS_BLQSOL",,.F.)
	
	//Dados da Transferência
	//Lembrar que na transferência posso mudar filial, departamento,  centro de custo e/ou processo
	//Para o posto
	if aTpsSol[1] <> Nil
		
		//Busca a informação da filial de Destino
		if (nPosCpo := AScan(aTpsSol[1],{|x| Alltrim(x[1]) == 'RA_FILIAL'})) > 0			
			cFilAt	:= Alltrim(aTpsSol[1][1][nPosCpo + 1])
		EndIf
		
		//Busca a informação do Centro de Custo de Destino
		if (nPosCpo := AScan(aTpsSol[1],{|x| Alltrim(x[1]) == 'RA_CC'})) > 0			
			cCCAt	:= Alltrim(aTpsSol[1][nPosCpo][2])
		EndIf
		
		//Busca a informação do deparrtamento de Destino
		if (nPosCpo := AScan(aTpsSol[1],{|x| Alltrim(x[1]) == 'RA_DEPTO'})) > 0			
			cDepto	:= Alltrim(aTpsSol[1][nPosCpo][2])
		EndIf
		
	EndIf
	
	//Dados do cargo
	if aTpsSol[3] <> Nil
		
		if (nPosCpo := AScan(aTpsSol[3],{|x| Alltrim(x[1]) == 'RA_CODFUNC'})) > 0			
			cCodCarg	:= Alltrim(aTpsSol[3][nPosCpo][2])
		EndIf
		
	EndIf
	
	/*
	if aTpsSol[1] <> Nil .OR. aTpsSol[3] <> Nil
		
		if Empty(cCodCarg) .OR. Empty(cFilAt) .OR. Empty(cDepto) .OR. Empty(cCCAt)
			
			dbSelectArea("SRA")
			SRA->(dbSetORder(1))
			if SRA->(DbSeek(RH3->RH3_FILIAL + RH3->RH3_MAT))
				
				cFilAt	:= iif(Empty(cFilAt),SRA->RA_FILIAL, cFilAt)
				cDepto	:= iif(Empty(cDepto),SRA->RA_DEPTO, cDepto)
				cCCAt	:= iif(Empty(cCCAt),SRA->RA_CC, cCCAt)
				cCodCarg:= iif(Empty(cCodCarg),SRA->RA_CARGO,cCodCarg)
			EndIf
			
		EndIf
		
		cTabAtu	:= GetNextAlias()
		
		cQry	:=  "	SELECT (RCL_NPOSTO-RCL_OPOSTO) AS QTDEDISPONIVEL ,RCL_POSTO ,RCL_FILIAL " + CRLF
		cQry	+=  "		FROM " + RetSqlName("RCL") + " " + CRLF
		cQry	+=  "		WHERE RCL_FILIAL = '" + iif(!Empty(xFilial("RCL")),cFilAt,xFilial("RCL")) + "' " + CRLF
		cQry	+=  "		  AND RCL_DEPTO = '" + cDepto + "' " + CRLF
		cQry	+=  "		  AND RCL_CARGO IN ('','" + cCodCarg + "')" + CRLF
		cQry	+=  "		  AND D_E_L_E_T_ = ''" + CRLF
		cQry	+=  "		  AND RCL_DTINI <= '" + Dtos(dDataBase) + "' " + CRLF
		cQry	+=  "		  AND (" + CRLF
		cQry	+=  "		  		RCL_DTFIM >= '" + Dtos(dDataBase) + "' OR " + CRLF
		cQry	+=  "		  		RCL_DTFIM = ' '" + CRLF
		cQry	+=  "		   )"
		
		cQry := ChangeQuery(cQry)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cTabAtu,.T.,.T.)
		
		if !(cTabAtu)->(Eof())
			
			if (cTabAtu)->QTDEDISPONIVEL == 0
				If !lLibPst
					lValPosto	:= .F.
					Help("",1, "Help", "Validação da Posto(ValPosto_01)", "Para o cargo " + cCodCarg + ", departamento " + cDepto + " e filial " + cFilAt + " não existe posto disponível!" , 3, 0)
				Else
					MsgAlert("O posto "+ (cTabAtu)->RCL_POSTO +" da filial "+ (cTabAtu)->RCL_FILIAL +" está totalmente ocupado. O Status da solicitação será alterado para 'Aguardando Liberação do Posto'")
					DbSelectArea("RH3")
					RH3->(DbSetOrder(1))
					If RH3->(DbSeek(cFilSol+cCodSol))
						If RH3->RH3_XLIBPT != "1"
							RecLock("RH3",.F.)
							RH3->RH3_XLIBPT := "1" //Posto não livre
							RH3->(MsUnLock())
							MsgAlert("Clique no Confirmar para atualizar o status")				
							U_F0500201(cFilSol, cCodSol, "025")//Aguardando liberação
						EndIf
					EndIf
					lValPosto	:= .F.
				EndIf
			Else				
				nQtdePost	:= (cTabAtu)->QTDEDISPONIVEL
				lValPosto	:= .T.
				DbSelectArea("RH3")
				RH3->(DbSetOrder(1))
				If RH3->(DbSeek(cFilSol+cCodSol))
					If RH3->RH3_XLIBPT == "1"
						RecLock("RH3",.F.)
						RH3->RH3_XLIBPT := "" //Posto não livre
						RH3->(MsUnLock())
						U_F0500201(cFilSol, cCodSol, "026")//Liberação do Posto	
					EndIf
				EndIf
			EndIf
			
		Else			
			lValPosto	:= .F.
			Help("",1, "Help", "Validação da Posto(ValPosto_01)", "Para o cargo " + cCodCarg + ", departamento " + cDepto + " e filial " + cFilAt + " não existe posto disponível!" , 3, 0)
		EndIf
		
		(cTabAtu)->(dbCloseArea())
	EndIf*/
	RestArea(aAreaSRA)

Return lValPosto


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
	
	// 07/02/2018 / 416094 : Rogerio Carvalho / chamado DOR04490913
	// ajuste da query abaixo nas linhas
	// antes do (SELECT Q3_TABELA FROM... e (SELECT Q3_TABNIVE FROM...
	// colocar IN no lugar do sinal igual ( = )
	cQuery := "SELECT RB6.RB6_VALOR,RB6.RB6_FAIXA,RB6.RB6_NIVEL FROM " + RetSqlName("RBR") + " RBR "
	cQuery += "INNER JOIN " + RetSqlName("RB6") + " RB6 "
	cQuery += "ON RB6.RB6_FILIAL = '" + cFilRb6 + "' AND "
	cQuery += "RB6.RB6_TABELA     IN (SELECT Q3_TABELA FROM " + RetSqlName("SQ3") + " "
	cQuery += "				WHERE  Q3_FILIAL = '" + cFilSq3 + "' AND Q3_CARGO = '" + cCodVg + "' AND D_E_L_E_T_ = ' ') "
	cQuery += "AND RB6.RB6_NIVEL  IN (SELECT Q3_TABNIVE FROM " + RetSqlName("SQ3") + " "
	cQuery += "				WHERE  Q3_FILIAL = '" + cFilSq3 + "' AND Q3_CARGO = '" + cCodVg + "' AND D_E_L_E_T_ = ' ') "
	cQuery += "AND RB6.RB6_DTREF = RBR.RBR_DTREF "
	cQuery += "AND RB6.D_E_L_E_T_ = ' '  "
	cQuery += "WHERE RBR.RBR_FILIAL = '" + cFilRb6 + "' "
	cQuery += "AND RBR.RBR_TABELA IN (SELECT Q3_TABELA FROM " + RetSqlName("SQ3") + " WHERE  Q3_FILIAL = '" + cFilSq3 + "' AND Q3_CARGO = '" + cCodVg + "' AND D_E_L_E_T_ = ' ') "
	cQuery += "AND RBR.RBR_APLIC = '1' "
	cQuery += "AND RBR.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY RB6.RB6_NIVEL, RB6.RB6_FAIXA "

	// 07/02/2018 - Fim Rogerio Carvalho
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliRB6)
	
	DbSelectArea(cAliRB6)
	While ! (cAliRB6)->(EOF())
		AADD(aAux, {(cAliRB6)->RB6_NIVEL,(cAliRB6)->RB6_FAIXA,(((cAliRB6)->RB6_VALOR * cHrMes) / 220)})
		(cAliRB6)->(DbSkip())
	End
	(cAliRB6)->(DbCloseArea())

Return aAux
/*{Protheus.doc} PegaM1Dt
ticket 3138519 [AMS] - Paulo Dias - 29/06/2018
Monta Data (M+1) : Soma 1 mes na data da ultima aprovacao e coloca a data do dia para o dia 01
@author  Paulo Cezar
@since
@Project MAN0000007423039_EF_003
*/
Static Function PegaM1Dt(cFilM1,cSolM1)

	Local dDtAprov  // ticket 2655967 [AMS] - Paulo Dias - 04/05/2018
	Local cAli      := ""
	//Local cAliPA5   := GetNextAlias()
	Local dDtaTra



	cAli := " SELECT MAX(PA5_XDATA) AS PA5_XDATA "
	cAli += " FROM " + RetSqlName("PA5") + " PA5 "
	cAli += " WHERE PA5.D_E_L_E_T_ = ' ' "
	//cAli += "AND RH3.D_E_L_E_T_ = ' ' "
	cAli += " AND UPPER(TRIM(PA5.PA5_XSTAT)) = 'APROVADO SOLICITAÇÃO' "
	cAli += " AND PA5_XNRSOL = '" + cSolM1 + "' "
	cAli += " AND PA5_FILIAL = '" + cFilM1 + "' "
	//cAli += "AND PA5_XDESEV != 'Troca de Turno' "

	If Select("PA5DT") > 0
		PA5DT->(DbCloseArea())
	EndIf

	cAli := ChangeQuery(cAli)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cAli),"PA5DT")

	//dtApPA5 := POSICIONE("PA5",1,xFilial("PA5")+cAliPA5->PA5_XNRSOL+DTOS((cAliPA5)->PA5_XDATA),"PA5_XDATA")

	nTemXdt:=0
	WHILE PA5DT->(!EOF())
		nTemXdt += 1
		dM1Pa5Dt := PA5DT->PA5_XDATA
		PA5DT->(dbskip())
	End do

	//If nTemXdt==0 Thais Paiva - 10037508
	If nTemXdt==0 .OR. Empty(dM1Pa5Dt)
		dDtAprov := dDatabase
	Else
		dDtAprov := STOD(dM1Pa5Dt)
	EndIf

	dDtaTra:= FirstDate(MonthSum(dDtAprov,1))

Return dDtaTra 

/*{Protheus.doc} VerSoTur
ticket 3138519 [AMS] - Paulo Dias - 29/06/2018
Verifica se solicitação eh somente alteracao de turno 
@author  Paulo Cezar
@since
@Project MAN0000007423039_EF_003
*/
Static Function VerSoTur(cFilTur,cSolTur)

	// ticket 2655967 [AMS] - Paulo Dias - 04/05/2018
	Local cAliTur      := ""
	Local lSoTur       := .f.

	cAliTur := " SELECT * "
	cAliTur += " FROM " + RetSqlName("RH4") + " RH4 "
	cAliTur += " WHERE RH4.D_E_L_E_T_ = ' ' "
	cAliTur += " AND RH4_CODIGO = '" + cSolTur + "' "
	cAliTur += " AND RH4_FILIAL = '" + cFilTur + "' "

	If Select("RH4TUR") > 0
		RH4TUR->(DbCloseArea())
	EndIf

	cAliTur := ChangeQuery(cAliTur)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cAliTur),"RH4TUR")

	//dtApPA5 := POSICIONE("PA5",1,xFilial("PA5")+cAliPA5->PA5_XNRSOL+DTOS((cAliPA5)->PA5_XDATA),"PA5_XDATA")

	nTemTur:=0
	nTemOut:=0
	WHILE RH4TUR->(!EOF())
		If ALLTRIM(RH4TUR->RH4_CAMPO) == 'TMP_TIPO' .AND. ALLTRIM(RH4TUR->RH4_VALNOV) == '4'  
			nTemTur += 1
		Elseif ALLTRIM(RH4TUR->RH4_CAMPO) == 'TMP_TIPO' .AND. ALLTRIM(RH4TUR->RH4_VALNOV) <> '4'
		    nTemOut += 1
		Endif
		RH4TUR->(dbskip())
	End do

	If nTemTur == 1 .and. nTemOut == 0
		lSoTur := .T.
	Elseif nTemTur == 1 .and. nTemOut > 0
		lSoTur := .F.
	Endif
Return lSoTur 
