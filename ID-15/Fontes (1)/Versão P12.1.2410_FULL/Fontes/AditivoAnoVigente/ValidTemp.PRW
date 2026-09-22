#INCLUDE "ValidTemp.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidDesp ºAutor  ³Itamar 			 º Data ³  11/07/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se a despesa possui limite ou nao					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CDV - Controle de Despesas de Viagens						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ValidDesp()
Local lRet:=.F.	

If M->LHS_TEMLIM == "1"
	lRet := .T.
Else
	M->LHS_LIMITE := 0	
	lRet := .F.
EndIf

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidLim  ºAutor  ³Itamar 			 º Data ³  12/07/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida limites de despesas no apontamento das mesmas 		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CDV - Controle de Despesas de Viagens						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ValidLim(_dData, _cDespesa, _nQtde, nVlrTotal)
Local _aAcols := {}, _VerColab := {}, _aDesp := {}, _nCont := 0, _nValores := 0

//Montando _aAcols -> Essa matriz vai possuir os dados atualizados, mesmo se for a linha em alteracao no momento
For _nCont = 1 To Len(aCols)
	If ! aCols[_nCont][_nUsado+1]
		If EhInter
			If _nCont == n	.And. Type("M->LHR_MOEDA") == "N"
				_nMoeda := M->LHR_MOEDA
			Else
				_nMoeda := aCols[_nCont][_nPosMoe]
			EndIf
		Else
			_nMoeda := 1
		EndIf
	
		If _nCont == n
			AADD(_aAcols, {_dData, _cDespesa, _nQtde, nVlrTotal, _nMoeda, aCols[_nCont][_nPosVbn], aCols[_nCont][_nPosVbs]})
		Else		
			AADD(_aAcols, {	aCols[_nCont][_nPosDat],;
							aCols[_nCont][_nPosCod],;
							aCols[_nCont][_nPosQtd],;
							aCols[_nCont][_nPosVrt],;
							_nMoeda,;
							aCols[_nCont][_nPosVbn],;
							aCols[_nCont][_nPosVbs]	}	)
		EndIf
	EndIf
Next 

//Verificar Valor da Diaria e se o colaborador possui limites para apontamento das despesas
_VerColab := U_VerColab() //Retonar a Diaria e se Possui Limites
// _VerColab[1] --> Valor Diaria Nacional
// _VerColab[2] --> Valor Diaria Internacional
// _VerColab[3] --> Se o colaborador segue o limite ou nao (0 = Nao segue limite | 1 = Segue Limite)

If _VerColab[3] == 0
	U_TodosReem(@_aAcols) //Todos reembolsaveis
	U_AtualizaAcols(_aAcols)
	U_Calcula()
	oGet:Refresh()
	Return
EndIf

//Agrupar Despesas pela Data e moeda para rodar _aAcols e validar limites e retornar os limites das despesas
U_GrupoLimites(_aAcols, @_aDesp, _VerColab[1], _VerColab[2])

//Validar Limite da Despesa do Dia
For _nCont = 1 To Len(_aAcols)
	_nValores := U_RetSaldoDes(_aAcols, _nCont, @_aDesp)
	_aAcols[_nCont][7] := _nValores[1] //Reembolsavel
	_aAcols[_nCont][6] := _nValores[2] //Nao Reembolsavel
Next

U_AtualizaAcols(_aAcols) //Atualiza aCols com o o valor de _aAcols
U_Calcula()
oGet:Refresh()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DelItem   ºAutor  ³Itamar 			 º Data ³  12/07/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta item e calcula valores						 		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CDV - Controle de Despesas de Viagens						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DelItem()

aCols[n][_nUsado+1] := Iif(aCols[n][_nUsado+1] = .T., .F., .T.) //Passa como deletado direto
oGet:Refresh() 
U_Calcula()

Return .T.


// Habilita / Desabilita o campo TOTAL na Acols
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DigTotal  ºAutor  ³Itamar 			 º Data ³  12/07/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta item e calcula valores						 		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CDV - Controle de Despesas de Viagens						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DigTotal()

Local lHabilita := .T.

If aCols != Nil
	If aCols[n][_nPosTCal] == "KM__M1"
		lHabilita := .F.
	EndIf
EndIf

Return lHabilita      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VlMoeda   ºAutor  ³Itamar 			 º Data ³  03/10/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida valores apos troca da moeda quando viagem internac.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CDV - Controle de Despesas de Viagens						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/     

User Function VlMoeda()
Local lRet := .T.

If M->LHR_MOEDA == 1 .Or. M->LHR_MOEDA == 2
	If !EhInter .And. M->LHR_MOEDA == 2
		MsgInfo(STR0001) //"Para viagens nacionais a moeda sempre deve ser 1!"
		lRet := .F.
	Else
		If 	DTOS(aCols[n][_nPosDat]) != "" .And. ; //Data nao preenchida
			AllTrim(aCols[n][_nPosCod]) != "" .And. ; //Despesa nao preenchida
			aCols[n][_nPosQtd] != 0 .And. ;
			aCols[n][_nPosVrt] > 0
	
			U_ValidLim(aCols[n][_nPosDat], aCols[n][_nPosCod], aCols[n][_nPosQtd], aCols[n][_nPosVrt])
		EndIf
	EndIf
Else
	MsgInfo(STR0002) //"O campo Moeda deve ser preenchido com o valor '1' para despesas Nacionais ou '2' para despesas Internacionais."
	lRet := .F.
EndIf
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VerColab  ºAutor  ³Itamar 			 º Data ³  04/10/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica Limite de diaria e se o colaborador segue esse lim.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CDV - Controle de Despesas de Viagens						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/     

User Function VerColab()
Local _aArea:=GetArea(), _nDriaNac := 0, _nDriaInt := 0

DbSelectArea("LHT")
DbSetOrder(1)
If DbSeek(xFilial() + _cFunc)
	If LHT->LHT_LIMDES == "2" 	// O colaborador nao possui limites para apontamento das despesas
		Return {0, 0, 0} 		// O primeiro 0 (zero) eh o valor do limite em Reais e o segundo em Dolar.
								// O terceiro indica se o colaborador possui e respeita o limite. 
								// Quando retornar 0 eh pq o colaborador nao respeita o limite.
	EndIf

	DbSelectArea('LHP')
	DbSetOrder(1)
	If (DbSeek(xFilial() + LHQ->LHQ_CODIGO))
		_nDriaInt := LHP->LHP_DIAINT
		If (_dVooC - _dVooS) > 0
			_nDriaNac := Val(LHP->LHP_RDia)
		Else
			_nDriaNac := Val(LHP->LHP_UmDia)
		EndIf
	Else
		_nDriaNac := 0
		_nDriaInt := 0
	EndIf
		
	If _nDriaNac == 0 .Or. 	_nDriaInt == 0
		DbSelectArea("LJL")
		DbSetOrder(1)
		If LJL->(DbSeek(xFilial("LJL") + LHT->LHT_CARGO))
			_nDriaInt := LJL->LJL_VLINT
			If (_dVooC - _dVooS) > 0
				_nDriaNac := LJL->LJL_VLCPER
			Else
				_nDriaNac := LJL->LJL_VLSPER
			EndIf
		EndIf
	EndIf
Else
	MsgInfo(STR0003) //"Colaborador viajante não encontrado. Por favor, preencha o campo Colaborador."
	Return .T.
EndIf

RestArea(_aArea)

Return {_nDriaNac, _nDriaInt, 1} //O 1 indica que o colaborador deve seguir o valor limite de uso da despesa.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TodosReem ºAutor  ³Itamar 			 º Data ³  04/10/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza todos os valores para Reembolsaveis				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CDV - Controle de Despesas de Viagens						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/     
User Function TodosReem(_aAcols)
Local _nCont := 0

For _nCont = 1 To Len(_aAcols)
	LHS->(DbSetOrder(1))
	If LHS->(DbSeek(xFilial("LHS")+_aAcols[_nCont][2]))
		If LHS->LHS_TIPO $ "E"
			If _aAcols[_nCont][5] <> 1 //Moeda
				_aAcols[_nCont][6] := IIf(_aAcols[_nCont][4] > _nAdtUS,_nAdtUS,_aAcols[_nCont][4]) //Nao reembolsavel
				_aAcols[_nCont][7] := IIf(_aAcols[_nCont][4] > _nAdtUS,_aAcols[_nCont][4] - _nAdtUS,0)		
			Else
				_aAcols[_nCont][6] := IIf(_aAcols[_nCont][4] > _nAdiant,_nAdiant,_aAcols[_nCont][4]) //Nao reembolsavel
				_aAcols[_nCont][7] := IIf(_aAcols[_nCont][4] > _nAdiant,_aAcols[_nCont][4] - _nAdiant,0)				
			EndIf
		Else
			_aAcols[_nCont][6] := 0 //Nao reembolsavel
			_aAcols[_nCont][7] := _aAcols[_nCont][4]
		EndIf                                        
	Else
		_aAcols[_nCont][6] := 0 //Nao reembolsavel
		_aAcols[_nCont][7] := _aAcols[_nCont][4]	
	EndIf
Next

Return
      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AtualizaAcolsºAutor  ³Itamar 		     º Data ³  05/10/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza todos os valores da Acols segundo regras de permis.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CDV - Controle de Despesas de Viagens						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/     
User Function AtualizaAcols(_aAcols)
Local _nCont := 0

For _nCont = 1 To Len(_aAcols)
	aCols[_nCont][_nPosDat] := _aAcols[_nCont][1]
	aCols[_nCont][_nPosCod] := _aAcols[_nCont][2]
	aCols[_nCont][_nPosQtd] := _aAcols[_nCont][3]
	aCols[_nCont][_nPosVrt] := _aAcols[_nCont][4]
	aCols[_nCont][_nPosMoe] := _aAcols[_nCont][5]
	aCols[_nCont][_nPosVbn] := _aAcols[_nCont][6]
	aCols[_nCont][_nPosVbs] := _aAcols[_nCont][7]
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GrupoLimites ºAutor  ³Itamar 		     º Data ³  05/10/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza todos os valores de limites e retorna aDesp 		  º±±
±±º			 ³agrupado por data, Despesa e Moeda                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CDV - Controle de Despesas de Viagens						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/     
User Function GrupoLimites(_aAcols, _aDesp, _nDiaNac, _nDiaInt)
//_aAcols + _aDesp Vazia + Limite por Dia (Valor usado no calculo do adiantamento, conforme cargo do viajante - Nac. e Int.)
Local _aDespLim := {}, _nLimDia := 0, _nCont := 0

For _nCont = 1 To Len(_aAcols)
	If Ascan(_aDesp, {|x| DTOC(x[1]) + x[2] + Str(x[3]) = DTOC(_aAcols[_nCont][1]) + _aAcols[_nCont][2] + Str(_aAcols[_nCont][5])}) == 0
		//Limite da Despesa
		_aDespLim := U_LimDesp(_aAcols[_nCont][2])
			AADD(_aDesp,	{	_aAcols[_nCont][1],; 	//Data
							_aAcols[_nCont][2],; 	//Cod Despesa
							_aAcols[_nCont][5],; 	//Moeda
							_aDespLim[1],;			//Despesa possui Limite?
							_aDespLim[2],;			//Valor Limite da Despesa - Nacional
							_aDespLim[3],;			//Valor Limite da Despesa - Internacional
							_nDiaNac,;				//Limite por Dia - Viagens Nacionais
							_nDiaInt,;         		//Limite por Dia - Viagens Internacionais
							_aDespLim[4]} )			//Despesa segue limite diario?
	EndIf
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LimDesp      ºAutor  ³Itamar 		     º Data ³  05/10/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna os valores dos limites da despesa informada		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CDV - Controle de Despesas de Viagens						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/     
User Function LimDesp(_cCodDesp)
Local _aArea := GetArea(), _nLimNac := 0, _nLimInt := 0, _lLimite := .F., _lLimDia := .F.

DbSelectArea("LHS")
DbSetOrder(1)
If LHS->(DbSeek(xFilial() + _cCodDesp))
	If LHS->LHS_TEMLIM == "1" //Verifica se a despesa utilizada possui limite ($) de uso - "1" = Possui limite
		_lLimite := .T.
		_nLimNac := LHS->LHS_LIMITE
		_nLimInt := LHS->LHS_LIMINT
	EndIf
		If LHS->LHS_LIMDIA == "1" //Verifica se a Despesa respeita limite diario
		_lLimDia := .T.
	Else
		_lLimDia := .F.
	EndIf
EndIf
RestArea(_aArea)

Return {_lLimite, _nLimNac, _nLimInt, _lLimDia}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetSaldoDes  ºAutor  ³Itamar 		     º Data ³  05/10/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna os valores reemb. e nao reemb. da despesa em questaoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CDV - Controle de Despesas de Viagens						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/     
User Function RetSaldoDes(_aAcols, _nCont, _aDesp)
Local _nLimDesNac := 0, _nLimDesInt := 0, _nSdoDNac := 0, _nSdoDInt := 0, _nValor :=0, _nPosicao := 0, _nMoeda := 0
Local _NReemb := 0, _Reemb := 0, _nSaldo := 0

_nPosicao := Ascan(_aDesp, {|x| DTOC(x[1]) + x[2] + Str(x[3]) = DTOC(_aAcols[_nCont][1]) + _aAcols[_nCont][2] + Str(_aAcols[_nCont][5])})
_nValor	  := _aAcols[_nCont][4] //Valor da diaria Nacional
_nSdoDNac := _aDesp[_nPosicao][7] //Valor da diaria Nacional
_nSdoDInt := _aDesp[_nPosicao][8] //Valor da diaria Internacional
_nMoeda   := _aDesp[_nPosicao][3] //Moeda

If _aDesp[_nPosicao][4]
	_nLimDesNac := _aDesp[_nPosicao][5] //Valor do limite da despesa Nacional
	_nLimDesInt := _aDesp[_nPosicao][6] //Valor do limite da despesa Internacional
EndIf
	
If _nMoeda == 1
	_nDiaria := _nSdoDNac
	_nLimite := _nLimDesNac
Else
	_nDiaria := _nSdoDInt
	_nLimite := _nLimDesInt
EndIf
	
//Verifica o limite da Diaria
_nSaldo := _nValor - _nDiaria
If _nSaldo >= 0
	_Reemb	:= _nDiaria
	_NReemb := _nSaldo
Else
	_Reemb	:= _nValor
	_NReemb := 0
EndIf
	
//Verifica o limite da despesa
If _aDesp[_nPosicao][4]
	If _Reemb > _nLimite
		_Reemb := _nLimite
	EndIf
		
	If _nValor > _nLimite
		If _nDiaria >= _nLimite
			_NReemb := _nValor - _nLimite
		Else
			_NReemb := _nValor - _nDiaria
		EndIf
	EndIf
		
	//Calculo do Saldo quando a despesa possui limite
	If _nDiaria > _nLimite
		_nSaldo := _nLimite - _nValor
	Else
		_nSaldo := _nDiaria - _nValor
	EndIf
Else
	//Calculo do Saldo quando a despesa nao possui limite
	_nSaldo := _nDiaria - _nValor
EndIf
	
If _nSaldo < 0
	_nSaldo := 0
EndIf 
	
//Calculo do Reemb quando a despesa NAO segue o limite 
If ! _aDesp[_nPosicao][9] //Segue limite diario?
	If _nLimite > _nDiaria 
	If _nLimite < _nValor
			_Reemb := _nLimite
		Else
			_Reemb := _nValor
		EndIf
	EndIf

	//Calculo do NAO Reemb quando a despesa NAO segue o limite 
	If _nValor > _nLimite
		_NReemb := _nValor - _nLimite
	Else
		_NReemb := 0
	EndIf
		
	//Se a Despesa nao segue limite diario e nao possui limite
	If ! _aDesp[_nPosicao][4]
		_Reemb := _nValor
		_NReemb := 0
	EndIf
		
	_nSdoDia := _nDiaria
	_nSdoDes := _nLimite - _Reemb
Else
	_nSdoDia := _nSaldo
	_nSdoDes := _nSaldo
EndIf
	
If _nMoeda == 1
	_aDesp[_nPosicao][5] := _nSdoDes //Saldo da despesa Nacional
	_aDesp[_nPosicao][7] := _nSdoDia //Saldo da diaria Nacional
Else
	_aDesp[_nPosicao][6] := _nSdoDes //Saldo da despesa Internacional
	_aDesp[_nPosicao][8] := _nSdoDia //Saldo da diaria Internacional
EndIf
	
Return {_Reemb, _NReemb}
