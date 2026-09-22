#INCLUDE "PROTHEUS.CH"
//==========================================================================================
/*/
/  Funcao para gerar uma base do salario familia p/ cada dependente 
@author     A.Shibao
@since      4/09/16
@param		
@version    P12
@return      
@project 
@client    RedeDor 
@          Utilizada tb a funcao DorPensSF  
/*/
//==========================================================================================  
User Function DorSFPens() 

Local 	aArea		:= GetArea()
Local   aSRBArea	:= SRB->(GetArea())

Local   nSalAux 	:= Salario 
Local   nSalMulV	:= 0
Local	nProfTar	:= 0.00
Local	cCodProp	:= ""
Local	llDepSf		:= Iif(SRA->(FieldPos("RA_DEPSF"))>0,.T.,.F.)    
Local	nQtdeDepSF	:= 0  
Local 	nIdade   	:= 0                       
Local 	dDaCalc		:= dDataAte //Atualizacao da Variavel ddacalc para não utilizar o DDATABASE
Local   aShPensao   := {}
Local   nSalShFam   := 0    
Local   lGetOut     := .F.

dDatadem := If(dDatadem = Nil,SRA->RA_DEMISSA,dDatadem)

If llDepSf	
	If Val(SRA->RA_DEPSF) > 0 .And. fBuscaPD(aCodfol[34,1]) > 0
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Controla idade dos dependentes Salario Familia            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea( "SRB" )                     

			If ! dbSeek(SRA->RA_FILIAL + SRA->RA_MAT)
				lGetOut := .T.
			Endif
			
			//Verificar se existem dependentes   
			While SRB->(!Eof() .And. SRB->RB_FILIAL + SRB->RB_MAT == SRA->RA_FILIAL + SRA->RA_MAT )
		
					//-- Somente se o dependente for filho/Outros e tenha pensionista 
					If (Upper(SRB->RB_GRAUPAR) <>"C") .And. !Empty(SRB->RB_XPENSAO) .And. !Empty(SRB->RB_XVERBAP)
					
					    //-- *** Somente se não houver limite de idade  ou
						If (SRB->RB_TIPSF == "1") 
							nQtdeDepSF += 1
							//armazendo o registro
							aadd(aShPensao,{SRB->RB_FILIAL,SRB->RB_MAT,SRB->RB_XPENSAO,SRB->RB_XVERBAP}) 
						//-- *** Dependente ate 14 anos 
						//-- ****** Nascidos ate a data de calculo
						ElseIF (SRB->RB_TIPSF == "2") .and. ;
						 	   ( AnoMes(ddacalc)>= AnoMes(SRB->RB_DTNASC) ) 
		 					    //-- Menor de 14 anos ou igual a 14 mas, nesse ultimo caso, completa anos
		 					    //-- ate o mes de referencia inclusive
		 					    //-- Exemplo: Nascto: 01/10/11 ou 31/10/11 e calculo referente a 'Outubro', 
		 					    //-- o dependente devera ser considerado.
		 					    //-- No entanto, na folha referente a 'Novembro', o dependente nao devera ser 
		 					    //-- considerado no SF pois ja se trata do mes seguinte ao do aniversario de 
		 					    //-- 14 anos.
	 							nIdade   	:= CALC_IDADE(ddacalc,SRB->RB_DTNASC) 
		 						If ( nIdade < 14 )  .or. ;
		 						   ( 	( nIdade = 14 ) .and. ;
		 						   		( MesAno(ddacalc) <= MesAno(YearSum( SRB->RB_DTNASC , 14 ) ) );
		 						   	)
									nQtdeDepSF += 1 
									//armazendo o registro
									aadd(aShPensao,{SRB->RB_FILIAL,SRB->RB_MAT,SRB->RB_XPENSAO,SRB->RB_XVERBAP}) 									
								EndIf	
		 					
			 			EndIf	
		
					EndIf
					SRB->(dbSkip())
				EndDo 
			
			RestArea(aSRBArea)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Para semanalistas, deve calcular somente na ultima semana ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( SRA->RA_TIPOPGT = "S" .And. ! lUltSemana ) .And. If( SRA->RA_CATFUNC = "S", cTipoRot <> "4", .T. )
			Return
		EndIf
		
		nSalfami_b := 0.00
		
		If Ascan(aPd, { |X| X[1] = aCodfol[34,1] .And. X[9] # "D" }) > 0  .And. !(lGetOut)
		
			// As verbas de DSR horista e Hrs. Atividade devem ser buscadas diretamente do aPd,
			// pois nao devem possuir incidencia para salario familia.
			// SOMA INCIDENCIA PARA SALARIO FAMILIA
			Aeval( aPd ,{ |X| SomaInc(X,21,@nSalfami_B, , , , , , ,aCodFol) })
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Proporcionaliza salario conforme as hrs efetivamente      ³
			//³ trabalhadas no mes                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cTipoRot=="4" .and. SRA->RA_CATFUNC $ "H*T*G"
				nSalAux	:= Round( ( Salario /SRA->RA_HRSMES * (NORMAL + DESCANSO )  ), MsDecimais(1))
			EndIf
	
			// SOMA O SALARIO BASE AUTOMATICAMENTE NA BASE SAL.FAMILIA		
			nSalFami_b += If(nDiasMat > 0 .And. PosSrv(aCodFol[040,1],SRA->RA_FILIAL,"RV_SALFAMI") == "S", nSalAux / nDiasC * DiasTrab, nSalAux )
		
			// SOMA O VALOR DA MEDIA DE COMISSAO CALCULADA PARA AFASTAMENTO POR AUXILIO MATERNIDADE
			If aCodFol[238,1] # Space(3) .And. PosSrv(aCodFol[238,1],SRA->RA_FILIAL,"RV_SALFAMI") == "S"
				nSalFami_b += fVarRot("nMedComiss")
			EndIf
	
			// SOMA O VALOR DA BASE DE INSS DE OUTRAS EMPRESAS NA BASE DE CALCULO DO SALARIO FAMILIA
			// SOMENTE DEVERA CONFIGURAR A VERBA 288 COM "SIM" SE A EMPRESA NAO UTILIZAR MULTIPLOS VINCULOS
			If aCodFol[288,1] # Space(3) .And. PosSrv(aCodFol[288,1],SRA->RA_FILIAL,"RV_SALFAMI") == "S"
				Aeval( aPd ,{|X| nSalFami_b += If(X[1] == aCodFol[288,1] .And. X[9] <> "D",X[5],0) })
			EndIf                                                                                       
	
			// CALCULO DO SALARIO FAMILIA PROPORCIONAL
			DiasFamil :=  If(SuperGetmv("MV_SALFD")= "S",nDiasC,P_QTDIAMES)
			DiasBase  :=  If(SuperGetmv("MV_SALFD")= "S",nDiasC,P_QTDIAMES)
			If SuperGetmv("MV_SALFP") = "S"
				If YEAR(SRA->RA_ADMISSAO)=YEAR(dDataAte).AND.MONTH(SRA->RA_ADMISSAO)=MONTH(dDataAte).AND.DAY(SRA->RA_ADMISSAO) # 1
					Diasfamil := DiasFamil - Day(SRA->RA_ADMISSAO) + 1
					If !Empty(dDatadem)
						Diasfamil := (Day(dDatadem) - Day(SRA->RA_ADMISSAO)+1)
					EndIf
				Elseif  ! Empty(dDataDem)
					DiasFamil := Day(dDataDem)
				EndIf
			EndIf
	
			For nShConta :=1 to len (aShPensao)
				
				If nSalfami_b <= nLIMSF1
					nSalShFam := 1 * nVAL_SF1 / DiasBase * DiasFamil
					nSalShFam := Min( (1 * nVAL_SF1), nSalShFam)		// Ajuste p/nao extrapolar o limite do beneficio
				Elseif nSalfami_b <= nLIMSF2
					nSalShFam := 1 * nVAL_SF2 / DiasBase * DiasFamil
					nSalShFam := Min( (1 * nVAL_SF2), nSalShFam)		// Ajuste p/nao extrapolar o limite do beneficio
				EndIf
				If (SRA->RA_TIPOPGT = "S") .And. (SRA->RA_CATFUNC $ "S*T") .And. ! lUltSemana .And. If( SRA->RA_CATFUNC = "S", cTipoRot <> "4", .T. )
					nSalShFam := 0
				EndIf
		
				If nSalShFam > 0
					FMatriz(aShPensao[nShConta,4],nSalShFam,,,,,,,,,.T.) 					
				EndIf 
			Next
				
		EndIf
	EndIf
EndIf

RestArea(aArea)	

Return