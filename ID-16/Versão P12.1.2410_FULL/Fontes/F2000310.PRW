#include 'TOTVS.ch'

/*/{Protheus.doc} User Function F2000310
	Realiza a conciliação bancária de registros
	aRecSE5 - Array com dados dos registros a serem conciliados
	aRecSE5[x] - array com dados de um registro
	aRecSE5[x][1] - numérico - Recno da SE5
	aRecSE5[x][2] - lógico - .T. Concilia .F. Desfaz conciliação
	aRecSE5[x][3] - lógico - Informar em branco. A função retornará se conciliou ou não
	aRecSE5[x][4] - caracter - Informar em branco. A função retornará mensagem de falha caso não concilie
	@type  Function
	@author Gianluca Moreira
	@since 28/04/2021
	@version version
	@param aRecSE5, array, Contém os dados dos registros a serem conciliados
	/*/
User Function F2000310(aRecSE5)
	Local cFilBkp    := cFilAnt
	Local nTamFil    := TamSX3("E5_FILIAL")[1]
	Local nTamKey    := TamSX3("E5_PREFIXO")[1]+TamSX3("E5_NUMERO")[1]+TamSX3("E5_PARCELA")[1] + 1
	Local nTamTipo   := TamSX3("E5_TIPO")[1]
	Local lSharSE53	 := FWModeAccess("SE5",3) == "C"
	Local cReconAnt	 := ""
	Local cIdProc    := ''
	Local lAtuSaldo  := .F.
	Local lDTDispFK  := FK1->(FieldPos("FK1_DTDISP")) > 0 .And. FK2->(FieldPos("FK2_DTDISP")) > 0 
	Local oMovFilho  := Nil
	Local cKeyCheque := ""  
	Local lF380AlDt  := ExistBlock("F380AlDt")

	Local nI        := 0
	Local dDtDisp   := CTOD('')

	Private aRotina		:= {}
	Private cBco380		:= CriaVar("E5_BANCO")
	Private cAge380		:= CriaVar("E5_AGENCIA")
	Private cCta380		:= CriaVar("E5_CONTA")
	Private dIniDt380	:= dDataBase
	Private dFimDt380	:= dDataBase
	Private nQtdTitP	:= 0
	Private nQtdTitR	:= 0
	Private nValRec		:= 0
	Private nValPag		:= 0
	Private nBalOn380	:= 0
	Private nSldFinOn	:= 0
	Private cCadastro	:= "Reconciliação Bancária"
	Private cFil380		:= ""	// Variavel destinada a complementação do filtro atrves de ponto de entrada		

	//Para evitar error.log quando executa a rotina customizada via schedule 
	//Lucas Aguiar - 14/05/2021
	If !(IsInCallStack("U_XFINA435") .Or. IsInCallStack("U_XFIN435X")) 
		aRotina := {}// MenuDef()
	EndIf	
	//Fim
	
	dbSelectArea("FK1")
	dbSelectArea("FK2")
	dbSelectArea("FK5")
	dbSelectArea("FKA")
	dbSelectArea("SE5")

	SM0->(dbSetOrder(1))
	FK1->(dbSetOrder(1))
	FK2->(dbSetOrder(1))
	FK5->(dbSetOrder(1))
	
	Begin Transaction
		For nI := 1 To Len(aRecSE5)
			SE5->(dbGoTo(aRecSE5[nI, 1]))

			dDtDisp := SE5->E5_DTDISPO
			If dDtDisp > dFimDt380
				dFimDt380 := dDtDisp
			EndIf
			If dDtDisp < dIniDt380
				dIniDt380 := dDtDisp
			EndIf
			cBco380	:= SE5->E5_BANCO
			cAge380	:= SE5->E5_AGENCIA
			cCta380	:= SE5->E5_CONTA

			If !VldConc(aRecSE5[nI])
				Loop
			EndIf
			
			//Caso a filial nÃ£o seja totalmente compartilhada ajusto cFilAnt
			If lSharSE53
				//Se filial de origem preenchida
				If !Empty(SE5->E5_FILORIG)
					cFilAnt := SE5->E5_FILORIG
				Else
					//Se filial de origem vazia (inconsistÃªncia de base)
					SM0->(MsSeek(cEmpAnt+Alltrim(xFilial("SE5",SE5->E5_FILIAL))))
					cFilAnt := SM0->M0_CODFIL
				Endif
			Else // Se a Filial Ã© totalmente exclusiva, deve usar o _FILIAL
				cFilAnt := SE5->E5_FILIAL				
			Endif

			//Verifico se nao estava reconciliado anteriormente
			If cPaisLoc $ "ARG|DOM|EQU"
				SEF->(DbSetOrder(6))                
				IF SEF->( DbSeek( xFilial("SEF")+SE5->E5_RECPAG;
				+If(SE5->E5_RECPAG=="R",(SE5->(E5_BCOCHQ+E5_AGECHQ+E5_CTACHQ+SUBSTR(E5_NUMERO,1,TAMSX3("EF_NUM")[1]))),;
				(SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA+SUBSTR(IIf(cPaisLoc == "ARG",E5_NUMERO,E5_NUMCHEQ),1,TAMSX3("EF_NUM")[1]))));
				+SE5->E5_PREFIXO ))
					RecLock("SEF")                                            
					SEF->EF_RECONC := IIf(aRecSE5[nI, 2],"x"," ")
					SEF->(MSUnlock())
				Endif
			Endif
			
			cReconAnt := SE5->E5_RECONC
			
			//Obtem o IDPROC
			cIdProc := FINProcFKs(SE5->E5_IDORIG, SE5->E5_TABORI)
			FKA->(dbSetOrder(2))
			FKA->(dbseek(SE5->E5_FILIAL+cIdProc))
			
			While FKA->(!EOF()) .AND. FKA->FKA_IDPROC == cIdProc
				If FKA->FKA_TABORI == "FK5"
					If FK5->(dbseek(FKA->FKA_FILIAL+FKA->FKA_IDORIG)) 
						If FK5->FK5_TPDOC == SE5->E5_TIPODOC
							Reclock("FK5", .F.)
							If aRecSE5[nI, 2]
								FK5->FK5_DTCONC :=  dDataBase
							Else
								FK5->FK5_DTCONC :=  CTOD("") 
							Endif
								
							If FK5->FK5_DTDISP # dDtDisp
								dOldDispo := SE5->E5_DTDISPO
								lAtuSaldo := .T.
								FK5->FK5_DTDISP :=  dDtDisp
							Endif
							FK5->(MsUnlock())	
						Endif						
					EndIf
				ElseIf lDTDispFK .And. FKA->FKA_TABORI == "FK1"
					If FK1->(dbseek(FKA->FKA_FILIAL+FKA->FKA_IDORIG))
						If FK1->FK1_TPDOC == SE5->E5_TIPODOC
							Reclock("FK1", .F.)
							If FK1->FK1_DTDISP # dDtDisp
								FK1->FK1_DTDISP :=  dDtDisp
							Endif
							FK1->(MsUnlock())	
						Endif
					EndIf
				ElseIf lDTDispFK .And. FKA->FKA_TABORI == "FK2"
					If FK2->(dbseek(FKA->FKA_FILIAL+FKA->FKA_IDORIG))
						If FK2->FK2_TPDOC == SE5->E5_TIPODOC
							Reclock("FK2", .F.)
							If FK2->FK2_DTDISP # dDtDisp
								FK2->FK2_DTDISP :=  dDtDisp
							Endif
							FK2->(MsUnlock())
						EndIf
					EndIf
				Endif
				FKA->(dbskip())
			Enddo
			
			If !AllTrim(SE5->E5_TIPODOC) $ "DB|ES"
				AltDtFilho(dDtDisp, @oMovFilho)
			EndIf
			
			Reclock("SE5", .F.)
			SE5->E5_RECONC := IIf(aRecSE5[nI, 2],"x"," ")
			If SE5->E5_DTDISPO <> dDtDisp
				SE5->E5_DTDISPO := dDtDisp
			EndIf
			SE5->(MsUnlock())				
		
			//Acerto E5_DTDISPO dos titulos baixados com cheque para melhor apresentacao no
			//relatorio de fluxo de caixa realizado
			If lAtuSaldo .AND. !EMPTY(SE5->E5_NUMCHEQ)
				dbSelectArea("SE5")							
				SE5->(dbSetOrder(11))
				
				If SE5->(MsSeek(xFilial("SE5")+SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ)))
					cKeyCheque := SE5->(E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ)
					
					While SE5->(!Eof()) .and. cKeyCheque == SE5->(E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ)
						If lF380AlDt	
							If !(lAltDt := ExecBlock("F380AlDt",.F.,.F.))
								SE5->(DbSkip())
								Loop
							EndIf
						EndIf
						
						If (SE5->(Recno()) == aRecSE5[nI, 1] .Or. lF380AlDt) .And. FK5->(dbseek(xFilial("SE5")+SE5->E5_IDORIG))
							Reclock("FK5", .F.)
							FK5->FK5_DTDISP :=  dDtDisp
							FK5->(MsUnlock())
						EndIf
						
						SE5->(dbSkip())
					Enddo
				Endif
				
				SE5->(dbGoTo( aRecSE5[nI, 1] ))
			Endif
			
			/*
			If lF380Grv
				ExecBlock("F380GRV",.F.,.F.)
			EndIf	*/

			//Verifico atualizacao do saldo conciliado
			DO CASE
				CASE Empty(cReconAnt) .and. !Empty(SE5->E5_RECONC)
					nReconc := 1 	//Se foi reconciliado agora 			
				CASE !Empty(cReconAnt) .and. Empty(SE5->E5_RECONC)
					nReconc := 2 	//Se foi desconciliado agora
				CASE !Empty(cReconAnt) .and. !Empty(SE5->E5_RECONC)
					nReconc := 3	//Nao foi alterada a situacao anterior, mas ja estava conciliado
				CASE Empty(cReconAnt) .and. Empty(SE5->E5_RECONC)		
					nReconc := 3	//Nao foi alterada a situacao anterior, mas nao estava conciliado
			END CASE				

			If lAtuSaldo  // atualiza saldo bancario se alterou o E5_DTDISPO
				lAtuSaldo  := .F.				
				lAtSalRec1 := (nReconc == 2 .or. nReconc == 3) .And. !Empty(SE5->E5_RECONC) //Atualiza saldo conciliado na data antiga				
				lAtSalRec2 := nReconc != 4 .And. !Empty(SE5->E5_RECONC) //Atualiza saldo conciliado na data nova
				
				If SE5->E5_RECPAG == "P"
					AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,dOldDispo,SE5->E5_VALOR,"+",lAtSalRec1)
					AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DTDISPO,SE5->E5_VALOR,"-",lAtSalRec2)
				Else
					AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,dOldDispo,SE5->E5_VALOR,"-",lAtSalRec1)
					AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DTDISPO,SE5->E5_VALOR,"+",lAtSalRec2)
				Endif
			ElseIf (nReconc == 1 .Or. nReconc == 2)	//1 => Atualiza saldo conciliado, 2 => Saldo desconciliado
				cSinal  := Iif(nReconc == 2, Iif(SE5->E5_RECPAG == "P", "+", "-"), Iif(SE5->E5_RECPAG == "P", "-", "+"))
				nValTit := SE5->E5_VALOR
				
				If Alltrim(SE5->E5_TIPODOC) $ "TR;BD"
					aAreaSE5 := SE5->(GetArea())
					SE5->(dbsetorder(2))
					
					If SE5->(dbseek(SE5->E5_FILIAL+"I2"+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+DTOS(SE5->E5_DATA)+ SE5->E5_CLIFOR+SE5->E5_LOJA+SE5->E5_SEQ))
						nValTit += SE5->E5_VALOR 
					EndIf
					
					RestArea(aAreaSE5)					
				EndIf
				
				AtuSalBco(SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_DTDISPO, nValTit, cSinal, .T., .F.)
			Endif

			If aRecSE5[nI][2]
				If Empty(SE5->E5_XLOGMOV)
					RecLock("SE5", .F. )
					SE5->E5_XLOGMOV  := "RPC"
					SE5->E5_XHORMOV  := TIME() 
					SE5->E5_XDATMOV  := DATE() 

					SE5->E5_XLOGALT  := "RPC"
					SE5->E5_XHORALT  := TIME() 
            		SE5->E5_XDATALT  := DATE()

					MsUnlock()
				EndIf 
			EndIf 
		Next nI
	End Transaction
	cFilAnt := cFilBkp

	If oMovFilho != Nil
		oMovFilho:Destroy()
		oMovFilho := Nil
	EndIf
Return

/*/{Protheus.doc} VldConc
	Valida se o registro pode ser conciliado, conforme regras da
	Fa380ChecF padrão
	@type  Static Function
	@author Gianluca Moreira
	@since 28/04/2021
	/*/
Static Function VldConc(aRecSE5)
	Local lRet := .T.

	If SE5->(Deleted())
		lRet := .F.
		aRecSE5[3] := lRet
		aRecSE5[4] := 'Registro Excluído'
		Return lRet
	EndIf

	If !(SE5->E5_TIPODOC $ 'JR;VA;TL;DC;D2;MT;M2;CM;C2;CP;BA;V2;J2') .And. SE5->E5_SITUACA != 'C';
	.And. !(SE5->E5_TIPODOC = 'PA' .And. SE5->E5_ORIGEM = 'FINA090' .And. !Empty(SE5->E5_NUMCHEQ))
		lRet := .T.
		aRecSE5[3] := lRet
	Else
		lRet := .F.
		aRecSE5[3] := lRet
		aRecSE5[4] := 'Dados inválidos: E5_TIPODOC '+SE5->E5_TIPODOC+CRLF
		aRecSE5[4] += 'E5_SITUACA '+SE5->E5_SITUACA+CRLF
		aRecSE5[4] += 'E5_ORIGEM '+SE5->E5_ORIGEM+CRLF
		aRecSE5[4] += 'E5_NUMCHEQ '+SE5->E5_NUMCHEQ
	EndIf

//Fim
/*
	cQuery += "WHERE E5_FILIAL " + GetRngFil( aFiliais, "SE5", .T.,) + " AND "
cQuery += "E5_BANCO = '" + cBco380 + "' AND "
cQuery += "E5_AGENCIA = '" + cAge380 + "' AND "
cQuery += "E5_CONTA = '" + cCta380 + "' AND "
cQuery += "E5_DTDISPO <= '" + DTOS(dFimDt380) + "' AND "
cQuery += "E5_DTDISPO >= '" + DTOS(dIniDt380) + "' AND "	          
cQuery += " E5_TIPODOC NOT IN ('JR','VA','TL','DC','D2','MT','M2','CM','C2','CP','BA','V2','J2') AND E5_SITUACA <> 'C' "
cQuery += " AND (NOT (E5_TIPODOC = 'PA ' AND E5_ORIGEM = 'FINA090' AND E5_NUMCHEQ <> ' ')) "

IF mv_par01==2
	cQuery += "AND E5_RECONC = ' ' "
Elseif mv_par01==3
	cQuery += "AND E5_RECONC <> ' ' "
EndIf

If !Empty(cFil380)
	cQuery += "AND " + cFil380
Endif

cQuery += " AND D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY E5_FILIAL,E5_DTDISPO,E5_BANCO,E5_AGENCIA,E5_CONTA,E5_NUMCHEQ"*/
Return lRet

/*/{Protheus.doc} User Function TSTFIN
	(long_description)
	@type  Function
	@author user
	@since 28/04/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
User Function TSTFIN()
	Local aRecSE5 := {{26, MsgYesNo('Concilia?'), Nil, Nil}}

	U_F2000310(aRecSE5)
Return
//---------------------------------------------------------------------------
/*/{Protheus.doc} AltDtFilho
Atualiza a data E5_DTDISPO dos títulos filhos do principal

@Param dDataConc	data de conciliação ajustada

@author Daniel Mendes
@since 06/08/2015
@version 12
/*/
//---------------------------------------------------------------------------
Static Function AltDtFilho(dDataConc, oMovFilho)
	Local cChaveSE5 := ""
	Local cFilSE5   := ""
	Local aTipos    := { "VL","CM","CX","DC","MT","JR","V2","C2","D2","M2","J2","BA","TL","LJ","RA" }
	Local aArea     := {}
	Local aAreaSE5  := {}
	Local cLote		:= ""
	Local cRecPag	:= ""
	Local cQry      := ""
	Local cTblTmp   := ""
	
	aArea     := GetArea()
	aAreaSE5  := SE5->(GetArea())
	cFilSE5   := SE5->E5_FILIAL
	cLote	  := SE5->E5_LOTE
	cRecpag	  := SE5->E5_RECPAG
	
	If SE5->E5_TIPODOC != "CH"		
		If !Empty(SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO))
			If oMovFilho == Nil
				cQry := "SELECT R_E_C_N_O_ FROM " + RetSqlName("SE5") + " "
				cQry += "WHERE E5_FILIAL = ? AND E5_TIPODOC IN (?) AND E5_PREFIXO = ? AND E5_NUMERO = ? "
				cQry += "AND E5_PARCELA = ? AND E5_TIPO = ? AND E5_DATA = ? AND E5_CLIFOR = ? 
				cQry += "AND E5_LOJA = ? AND E5_SEQ = ? AND E5_SITUACA <> 'C' AND D_E_L_E_T_ = ' ' "
				cQry := ChangeQuery(cQry)
				oMovFilho := FwPreparedStatement():New(cQry)			
			EndIf
			
			oMovFilho:SetString(1,  SE5->E5_FILIAL)
			oMovFilho:SetIn(2,      aTipos)
			oMovFilho:SetString(3,  SE5->E5_PREFIXO)
			oMovFilho:SetString(4,  SE5->E5_NUMERO)
			oMovFilho:SetString(5,  SE5->E5_PARCELA)
			oMovFilho:SetString(6,  SE5->E5_TIPO)
			oMovFilho:SetString(7,  DtoS(SE5->(E5_DATA)))
			oMovFilho:SetString(8,  SE5->E5_CLIFOR)
			oMovFilho:SetString(9,  SE5->E5_LOJA)
			oMovFilho:SetString(10, SE5->E5_SEQ)
			
			cQry := oMovFilho:GetFixQuery()
			cTblTmp := MpSysOpenQuery(cQry)
			
			While (cTblTmp)->(!Eof()) .And. (cTblTmp)->R_E_C_N_O_ > 0
				SE5->(DbGoto((cTblTmp)->R_E_C_N_O_))
				
				If SE5->E5_DTDISPO == dDataConc
					(cTblTmp)->(DbSkip())
					Loop
				EndIf
				
				RecLock("SE5")
				SE5->E5_DTDISPO := dDataConc
				SE5->(MsUnLock())
				(cTblTmp)->(DbSkip())

			EndDo		
			
			(cTblTmp)->(DbCloseArea()) 

		ElseIf !Empty(cLote)
			SE5->(dbSetOrder(5))//E5_FILIAL+E5_LOTE+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)                                                                                         
			
			If SE5->(MsSeek(cFilSE5+cLote))
				While SE5->(!Eof()) .And. SE5->E5_LOTE == cLote
					If (SE5->E5_DTDISPO < dIniDt380) .Or. (SE5->E5_DTDISPO > dFimDt380) .Or. (SE5->E5_RECPAG <> cRecPag)
						SE5->(dbSkip())
						Loop
					EndIf
					
					If (SE5->E5_BANCO <> cBco380) .Or. (SE5->E5_AGENCIA <> cAge380) .Or. (SE5->E5_CONTA <> cCta380)
						SE5->(dbSkip())
						Loop
					EndIf
					
					RecLock("SE5")
					SE5->E5_DTDISPO := dDataConc
					SE5->(MsUnLock())
					SE5->(dbSkip())
				EndDo
			EndIf
		EndIf
	ElseIf !Empty(SE5->E5_NUMCHEQ) .Or. !Empty(cLote)
		If !Empty(SE5->E5_NUMCHEQ)
			cChaveSE5 := cFilSE5+SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ)+DtoS(SE5->E5_DATA)
			SE5->(dbSetOrder(11)) 
			SE5->(dbSeek(cChaveSE5))		
			
			While SE5->(!Eof()) .And. SE5->(E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ)+DtoS(SE5->E5_DATA) == cChaveSE5
				If (!SE5->E5_TIPODOC $ "VL/CM/CX/DC/MT/JR/V2/C2/D2/M2/J2/BA/TL/LJ/RA") .Or. (SE5->E5_DTDISPO == dDataConc)
					SE5->(dbSkip())
					Loop	
				EndIf
				
				RecLock("SE5")
				SE5->E5_DTDISPO := dDataConc
				SE5->(MsUnLock())
				SE5->(dbSkip())
			Enddo			
		Else
			SE5->(dbSetOrder(5))//E5_FILIAL+E5_LOTE+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)                                                                                         
			
			If SE5->(MsSeek(cFilSE5+cLote))
				While SE5->(!Eof()) .And. SE5->E5_LOTE == cLote				
					If (SE5->E5_DTDISPO == dDataConc) .Or. (SE5->E5_DTDISPO < dIniDt380) .Or. (SE5->E5_DTDISPO > dFimDt380)
						SE5->(dbSkip())
						Loop
					EndIf
					
					RecLock("SE5")
					SE5->E5_DTDISPO := dDataConc
					SE5->( MsUnLock() )
					SE5->(dbSkip())
				EndDo
			EndIf		
		EndIf		
	EndIf
	
	RestArea(aAreaSE5)
	RestArea(aArea)
	FwFreeArray(aAreaSE5)
	FwFreeArray(aArea)
Return Nil
