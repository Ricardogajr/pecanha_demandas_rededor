#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
/*==================================================================================================
Garantia piso Enfermagem  
@author     A.Shibao
@since      17/10/2023
//==================================================================================================*/
User Function DORGPE22()

	Local aArea   := GetArea()
	Local aArSRJ  := SRJ->(GetArea())
	Local nPos    := 0 
	Local cTipSrj := Posicione("SRJ",1,xFilial("SRJ")+SRA->RA_CODFUNC,"RJ_XPISOEN")
	Local cBases  := ''
	Local nPiso   := 0
	Local cxVrb   := ''
	Local nBase   := 0
	Local nx 	  := ''
	Local nsalold := 0	  	
	Private xaTabU111 := {}

	
	fCarrTab( @xaTabU111, "U111", Nil,.t.) 

	If Len(xaTabU111) > 0 .And. !Empty(cTipSrj) .And. (nPos := Ascan(xaTabU111,{|x| x[5] == SRA->RA_SINDICA .And. x[8]==cTipSrj .And.  x[7]==cRot  })) > 0

		lTpCal:= xaTabU111[nPos,6]
		
		If lTpCal == "C"
			
			nPiso := Round(Round((xaTabU111[nPos,9] /220 ) * sra->ra_hrsmes,2) * Iif(cRot== "131",nPercentua,1),2)
			//nPiso := Round((xaTabU111[nPos,9] /220 ) * sra->ra_hrsmes,2) 

			//Proporcionaliza na admissão
			if cRot == "FOL" .And. mesano(sra->ra_admissa) == cperiodo
				nPiso:= ((nPiso/30) * (diastrab + ndiaspg))
			endif

			//Proporcionaliza caso funcionário esteja afastado e não seja afastamento maternidade
			if cRot == "FOL" .And. sra->ra_sitfolh = "A" .And. !(sra->ra_afasfgt $ "Q1*Q2") 
				xdiaafa:= ndiaspg + diastrab
				nPiso:= ((nPiso/30) * xdiaafa)
			endif

			//Proporcionaliza caso funcionário esteja afastado afastamento maternidade
			if cRot == "FOL" .And. sra->ra_sitfolh = "A" .And. (sra->ra_afasfgt $ "Q1*Q2") 
				xdiamat:= fbuscapd('003','H')
				xdiaafa:= xdiamat + diastrab
				nPiso:= ((nPiso/30) * xdiaafa)
			endif

			//Proporcionaliza caso o funcionário tenha retornado de um afastamento superior a 15 dias no período e tenha um afastamento inferior a 15 dias.
			if cRot == "FOL" .And. sra->ra_sitfolh = " " .And. sra->ra_afasfgt <> " "
				xdiaafa:= ndiaspg + diastrab
				nPiso:= ((nPiso/30) * xdiaafa)
			endif
			
			//No caso do funcionário estar de férias 30 dias dentro do mês e não tiver pagamento de salário zero o Piso
			if cRot == "FOL" .And. sra->ra_sitfolh = "F" .and. diastrab = 0 .and. ndiaspg = 0
				nPiso := 0
			endif

			//No cálculo de Férias proporcionaliza o Piso de acordo com os dias pagos de férias
			if cRot == "FER"	
				nPiso := ((nPiso/30)*(m->rh_dferias + m->rh_dabonpe))
			endif 

			//Proporcionaliza Piso no calculo de 13o Salário de acordo com os avos
			if cRot == "131" .or. cRot == "132"
				//npiso := Iif(cRot== "131",((nPiso/12) * (navos * (mv_par02/100))),((nPiso/12) * navos)) 
				nAvos += nAvosMat 
				npiso := ((nPiso/12) * navos)

				if nAvos = 0
					Aeval( aAfast ,{ |X| nAvosAci := If( X[16] == "O1", X[1], 0 ) })
				 	if nAvosAci = 12
						salmes += (fbuscapd('495','V') / npercentua)
					endif
				endif
			endif
		
			//Proporcionaliza Piso no calculo de Rescisão 
			if cRot == "RES"
				xdiaafa:= ndiaspg + diastrab
				nPiso:= ((nPiso/30) * xdiaafa)
			endif
		endif

		//Prorporcionalizar o Piso no caso de cálculo do salário base
		If lTpCal == "B"

			//nPiso := Round(Round((xaTabU111[nPos,9] /220 ) * sra->ra_hrsmes,2) * Iif(cRot== "131",mv_par02/100,1),2)
			nPiso := Round((xaTabU111[nPos,9] /220 ) * sra->ra_hrsmes,2) 

			If cRot == "FER"	
				nPiso := ((nPiso/30)*(m->rh_dferias + m->rh_dabonpe))		
			
			Elseif cRot == "131" .or. cRot == "132"
				//npiso := Iif(cRot== "131",((nPiso/12) * (navos * (mv_par02/100))),((nPiso/12) * navos))
				npiso := Iif(cRot== "131",((nPiso/12) * (navos * nPercentua)),((nPiso/12) * navos))
			Else
				//nPiso := Round(Round((xaTabU111[nPos,9] /220 ) * sra->ra_hrsmes,2) * Iif(cRot== "131",mv_par02/100,1),2)
				xdiaafa:= ndiaspg + diastrab
				nPiso:= ((nPiso/30) * xdiaafa)
			Endif
		Endif

		cxVrb := xaTabU111[nPos,11]
		nperc := xaTabU111[nPos,10] / 100
		lTpCal := ""
		For nx := 1 to len (xaTabU111)
			if  xaTabU111[nx,8] = cTipSrj .And. xaTabU111[nx,7] = cRot .And. xaTabU111[nx,6] == "C" .and. xaTabU111[nx,5] ==SRA->RA_SINDICA 
				cBases += ALLTRIM(xaTabU111[nx,12])
				lTpCal:="C"
			Elseif xaTabU111[nx,8] = cTipSrj .And. xaTabU111[nx,7] = cRot .And. xaTabU111[nx,6] == "B" .and. xaTabU111[nx,5] ==SRA->RA_SINDICA 
				If cRot == "FER"
					cBases := ((SRA->RA_SALARIO/30)*(m->rh_dferias + m->rh_dabonpe))
				elseif cRot == "131" .or. cRot == "132"
					//cBases := Iif(cRot== "131",((SRA->RA_SALARIO/12) * (navos * (mv_par02/100))),((SRA->RA_SALARIO/12) * navos))
					cBases := Iif(cRot== "131",((SRA->RA_SALARIO/12) * (navos * nPercentua)),((SRA->RA_SALARIO/12) * navos))
				else
					cBases := ((SRA->RA_SALARIO/30)*(ndiaspg+diastrab))
				endif
				lTpCal:="B"
			endif
		Next nx
		
		nBase:= Iif(lTpCal =="C",fBuscapd(cBases),cBases)
		
		fdelpd(cxVrb)

		If nBase > 0 
			If nPiso - nBase > 0
				If  ! (( Ascan(aPd,{|X| X[1] == cxVrb .And. X[9] <> "D" .And. X[7] == "I"}) > 0 ) ) 
					nsalold:= salmes
					fGeraVerba( cxVrb,((nPiso - nBase) * nperc),,,,,,,,,.T.)		    
				Endif	
			Endif
		Endif

		// Incorpora valor de Piso na variável NVFERIAS para que seja considerada no cálculo do 1/3 Férias
		If cRot == "FER"
			nVferias += ((nPiso - nBase) * nperc)
		Endif
		
		//Se existir a verba de acidente de trabalho sem incidências, e a verba de adicionais sem incidência estiver com RV_FGTS == "S"
		//Subtrai o valor pago de Piso Enfermagem para ajustar a base de calculo para o FGTS
		If nBase > 0 
			If nPiso - nBase > 0
				If Ascan(aPd,{ |x| x[1] $ aCodfol[1873,1] + "/" + aCodFol[1874,1] + "/" + aCodFol[1875,1] + "/" + aCodFol[1876,1] + "/" + aCodFol[1877,1] .And. X[9] # "D" .And. X[3] == cSemana .And. RetValSRV( x[1], SRA->RA_FILIAL, "RV_FGTS" ) == "S"}) > 0
					salmes := nsalold
					salmes -= ((nPiso - nBase) * nperc)
					saldia := salmes / 30
					salhora:= saldia / sra->ra_hrsdia
				Endif
			Endif
		Endif
	EndIf

	RestArea(aArSRJ)
	RestArea(aArea)

Return()


//Monta Base de calculo valorizada para o Piso Enfermagem Integral
User Function DORGPE23()

	Local aArea   := GetArea()
	Local aArSRJ  := SRJ->(GetArea())
	Local nPos    := 0 
	Local cTipSrj := Posicione("SRJ",1,xFilial("SRJ")+SRA->RA_CODFUNC,"RJ_XPISOEN")
	Local nPiso   := 0
	Local cxVrb   := ''
	Local nBase   := 0
	Private xaTabU111 := {}

	
	fCarrTab( @xaTabU111, "U111", Nil,.t.) 

	If Len(xaTabU111) > 0 .And. !Empty(cTipSrj) .And. (nPos := Ascan(xaTabU111,{|x| x[5] == SRA->RA_SINDICA .And. x[8]==cTipSrj .And.  x[7]==cRot  })) > 0

		nPiso := Round(Round((xaTabU111[nPos,9] /220 ) * sra->ra_hrsmes,2) * Iif(cRot== "131",nPercentua,1),2)
		cxVrb := xaTabU111[nPos,11]		
		nperc := xaTabU111[nPos,10] / 100
		lTpCal:= xaTabU111[nPos,6]	

		if lTpCal = "C"
			nBase := salmes
			If cRot = "FER"
				nBase:= salmes + ninsalub
			elseif cRot = "131"
				nBase:= ((salario + ninsalub) * npercentua)
			Endif

		elseif lTpCal = "B"
			nBase := sra->ra_salario
		ENDIF

		//No caso do funcionario ter periculosidade como a verba é incorpora salario para variáveis de ponto
		//mas não é considerada salario para o cálculo do Piso Enfermagem temos que excluir o valor da base
		If nperic > 0
			nBase := nBase - nperic
		Endif

		If nBase > 0 
			If nPiso - nBase > 0
				IF cRot = "FER"
					nSalM1 += ((nPiso - nBase) * nperc)
				elseif cRot = "RES"
					salario +=((nPiso - nBase) * nperc)
					fGeraVerba( cxVrb,((nPiso - nBase) * nperc),,,,,,,,,.T.)	
				else
					if ! (( Ascan(aPd,{|X| X[1] == cxVrb .And. X[9] <> "D" .And. X[7] == "I"}) > 0 ) ) 
						fGeraVerba( cxVrb,((nPiso - nBase) * nperc),,,,,,,,,.T.)
					Endif			    
				Endif		
			Endif
		Endif
	EndIf

	RestArea(aArSRJ)
	RestArea(aArea)

Return()

//Monta Base de FGTS valorizada nos casos de Afastamento Acidente
User Function DORGPE24()

	Local aArea   := GetArea()
	Local aArSRJ  := SRJ->(GetArea())
	Local nPos    := 0 
	Local cTipSrj := Posicione("SRJ",1,xFilial("SRJ")+SRA->RA_CODFUNC,"RJ_XPISOEN")
	Local nBsFgts := 0
	Local nFgtsol := 0
	Local nPisoat := 0	
	Private xaTabU111 := {}

	fCarrTab( @xaTabU111, "U111", Nil,.t.) 

	If Len(xaTabU111) > 0 .And. !Empty(cTipSrj) .And. (nPos := Ascan(xaTabU111,{|x| x[5] == SRA->RA_SINDICA .And. x[8]==cTipSrj .And.  x[7]==cRot  })) > 0

		If SRA->RA_AFASFGT = 'O1' .And.	!Ascan(aPd,{ |x| x[1] $ aCodfol[1873,1] + "/" + aCodFol[1874,1] + "/" + aCodFol[1875,1] + "/" + aCodFol[1876,1] + "/" + aCodFol[1877,1] .And. X[9] # "D" .And. X[3] == cSemana .And. RetValSRV( x[1], SRA->RA_FILIAL, "RV_FGTS" ) == "S"}) > 0
			//--Verifica Qual Percentual de FGTS deve Aplicar 
			If 	SRA->RA_PERFGTS > 0.00
				nPerFgts := SRA->RA_PERFGTS / 100
			Else
				nPerFgts := If (SRA->RA_TPCONTR$ " *1*3",nFgtsCt1,nFgtsCt2)
			EndIf

			nFgtsol	:= Fbuscapd("A28")
			nPisoat	:= Fbuscapd("493")
			nPison	:= (nPisoat / (diastrab + ndiaspg)) * (ndiasfgts + diastrab)
			nBsFgts	:= ((nFgtsol - nPisoat) + nPison)

			fGeraVerba( aCodfol[17,1],NoRound(nBsFgts),,,,,,,,,.T.)
			fGeraVerba( aCodfol[18,1],NoRound(nBsFgts * nPerFgts),,,,,,,,,.T.)
		
		Endif
	Endif
	RestArea(aArSRJ)
	RestArea(aArea)

Return()		
