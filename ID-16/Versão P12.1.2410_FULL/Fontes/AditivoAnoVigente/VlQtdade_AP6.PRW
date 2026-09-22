#INCLUDE "VlQtdade_AP6.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VLQTDADE  ºAutor  ³Willy               º Data ³  07/01/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gatilho Interno para Incrementar o Acols                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TPL CDV - Controle de Despesas de Viagens					  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function VlQtdade()

Local _lVlQtdade 	:= .T.
Local nPosSepP		:= 0
Local nPosSepC		:= 0          
Local ni				:= 0
Local lOk			:= .T.
Local aRefKMI		:= {}
Local cKMI			:= SuperGetMV("MV_KMI",.F.,"")
Local nSepDec		:= 0
Local cFormula		:= "KM__M1"

ChkTemplate("CDV")

nPosSepP := At("/",cKMI)
//Se nao for lancamento avulso, pesquisar campo de km do LHP
If _nStatusP # 2 
	nPosSepC := At("/",LHP->LHP_KMI)
Endif
If nPosSepC == 0 .AND. nPosSepP == 0
	lOK := .F.
Else
	If !Empty(LHP->LHP_KMI) .AND. nPosSepC # 0
		aAdd(aRefKMI,AllTrim(Substr(LHP->LHP_KMI,1,nPosSepC-1)))
		aAdd(aRefKMI,AllTrim(Substr(LHP->LHP_KMI,nPosSepC+1,Len(LHP->LHP_KMI))))
		aAdd(aRefKMI,1)		
	ElseIf !Empty(cKMI) .AND. nPosSepP # 0
		aAdd(aRefKMI,AllTrim(Substr(cKMI,1,nPosSepP - 1)))
		aAdd(aRefKMI,AllTrim(Substr(cKMI,nPosSepP+1,Len(cKMI))))		
		aAdd(aRefKMI,2)
	Else
		lOK := .F.
	Endif
	//Validador do fator de calculo
	If Len(aRefKMI) == 3
		For ni := 1 to Len(aRefKMI[2]) Step 1
			If !Substr(aRefKMI[2],ni,1) $ ",.1234567890"
				lOk := .F.
				Exit
			ElseIf Substr(aRefKMI[2],ni,1) == ","
				nSepDec++
				aRefKMI[2] := Substr(aRefKMI[2],1,ni-1) + "." + Substr(aRefKMI[2],ni+1,Len(aRefKMI[2]))
			ElseIf Substr(aRefKMI[2],ni,1) == "."
				nSepDec++
			Endif
			If nSepDec > 1
				lOk := .F.
				Exit
			Endif			
		Next ni
	Endif
Endif
If !lOK
	Return _lVlQtdade
Endif                
If aRefKMI[3] == 1	//Pela tabela LHP 
	If AllTrim(aCols[n][_nPosCod]) == aRefKMI[1]
		If lCalcKMI 
			aCols[n][_nPosVrt] := M->LHR_QTDADE * Val(aRefKMI[2])
		Else
			If MsgYesNo(STR0001) //"Esta despesa está vinculada ao valor por quilometragem (parâmetro MV_KMI gravado na solicitação), deseja calcular o total por este fator?"
				aCols[n][_nPosVrt] := M->LHR_QTDADE * Val(aRefKMI[2])
				lCalcKMI := .T.
			Endif
		Endif
	EndIf
Else				//Pelo parametro MV_KMI
	If AllTrim(aCols[n][_nPosCod]) == aRefKMI[1]
		If lCalcKMI
			If Empty(AllTrim(aCols[n][_nPosTCal]))
				aCols[n][_nPosTCal] := cFormula
			Endif
		Else
			If Empty(AllTrim(aCols[n][_nPosTCal]))
				If MsgYesNo(STR0002) //"Esta despesa está vinculada ao valor por quilometragem (parâmetro MV_KMI), deseja calcular o total por este fator?"
					aCols[n][_nPosTCal] := cFormula
					lCalcKMI := .T.
				Endif
			Endif
		Endif
		If AllTrim(aCols[n][_nPosTCal]) == cFormula
			aCols[n][_nPosVrt] := M->LHR_QTDADE * Val(aRefKMI[2])
		EndIf
	Endif
EndIf

/*If AllTrim(_cRotPrest) == 'AE_DV005'
	If _lFlagLHQ
		If aCols[n][_nPosCod] == SubStr(Trim(LHP->LHP_KmI),1,6)
			aCols[n][_nPosVrt] := M->LHR_Qtdade * Val(SubStr(Trim(LHP->LHP_KmI),8,10))
		EndIf
	Else
		If aCols[n][_nPosCod] == SubStr(Trim(GetMV('MV_KmI')),1,6)
			aCols[n][_nPosVrt] := M->LHR_Qtdade * Val(SubStr(Trim(GetMV('MV_KmI')),8,10))
		EndIf
	EndIf
ElseIf AllTrim(_cRotPrest) == 'AE_DV007'
	If aCols[n][_nPosTCal] == 'TAXAM2' // Conversao para Dolar
		aCols[n][_nPosTax] := aCols[n][_nPosVrt] / aCols[n][_nPosQtd]
	EndIf
	If aCols[n][_nPosTCal] == 'KM__M1'
		aCols[n][_nPosVrt] := M->LHR_Qtdade * Val(SubStr(Trim(LHP->LHP_KmI),8,10)) 
	EndIf
Else*/

dbSelectArea('LHS')
LHS->(dbSetOrder(1))
If !LHS->(MsSeek(xFilial('LHS') + aCols[n][_nPosCod]))
	MsgInfo(STR0003, STR0004) //"Despesa não Cadastrada !"###"Atenção"
	_lVlValor := .F.
EndIf

/*If AllTrim(_cRotPrest) == 'AE_DV005'
	aCols[n][_nPosVbn] := 0
	aCols[n][_nPosVbs] := aCols[n][_nPosVrt]*/
/*Else
	If LHS->LHS_Tipo == 'N'
		aCols[n][_nPosVbn] := aCols[n][_nPosVrt]
		aCols[n][_nPosVbs] := 0
	Else
		aCols[n][_nPosVbn] := 0
		aCols[n][_nPosVbs] := aCols[n][_nPosVrt]
	EndIf*/ //Referente 82204
//EndIf

If aCols[n][_nPosVrt] > 0
	If 	DTOS(aCols[n][_nPosDat]) != "" .And. ; //Data nao preenchida
			AllTrim(aCols[n][_nPosCod]) != "" .And. ; //Despesa nao preenchida
			aCols[n][_nPosVrt] > 0
			
		U_ValidLim(aCols[n][_nPosDat], aCols[n][_nPosCod], aCols[n][_nPosQtd], aCols[n][_nPosVrt])
	EndIf
EndIf

Return(_lVlQtdade)
