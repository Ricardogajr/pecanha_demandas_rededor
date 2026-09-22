#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} F0702801
Função para integração de compensação de recebimento antecipado
@type User function
@author anieli.rodrigues
@since 20/03/2017
@version 12.7
@param oComp, object, Dados da compensação a ser realizada
@param nOperac, numérico, operação realizada 3 - Inclusão 5 - Exclusão
@project MAN0000007423041_EF_028
/*/

User Function F0702801(oComp, nOperac)

	Local aLog		:= {}
	Local aEstorn	:= {}
	Local aRecRA	:= {}
	Local aRecSE1	:= {}
	Local bBlock 	:= ErrorBlock({|e|ChkErr(e)})
	Local cChave	:= ""
	Local cFilComp	:= ""
	Local cIndKey	:= ""
	Local cRet		:= "ERRO|"
	Local lContab	:= .F.
	Local lRet		:= .T.
	Local nRecnoRA	:= 0
	Local nRecnoSE1	:= 0	
	Local nRegLog	:= 0
	Local nOrdem	:= 0
	Local nTamCli	:= TamSX3("E1_CLIENTE")[1]
	Local nTamLoja	:= TamSX3("E1_LOJA")[1]
	Local nTamNum	:= TamSX3("E1_NUM")[1]
	Local nTamParc	:= TamSX3("E1_PARCELA")[1]
	Local nTamPref  := TamSX3("E1_PREFIXO")[1] 
	Local nTamTipo	:= TamSX3("E1_TIPO")[1] 
	Local nY		:= 0
	Local cFK5IDBXF := ""

	Private cErrorL			:= ""
	Private cXID			:= U_GetIntegID()
	Private lEstorno        := nOperac == 5
	Private lAutoErrNoFile 	:= .T.
	Private lMsErroAuto 	:= .F.
	Private cXIDBXF

	Begin Sequence 
	
		cFilComp := Alltrim(oComp:cFilReg)

		Begin Transaction 
			nRegLog := U_F07LOG01(cXID,{oComp})
		End Transaction  
	
		If Empty(cFilComp) .Or. !ExistCpo("SM0",cEmpAnt + cFilComp)
			lRet := .F.
			cRet += "PARAMETRO OBRIGATORIO INVALIDO: CFILREG"
		Else 
			cFilAnt := cFilComp
		EndIf

		If lRet .And. nOperac == 3 .And. !Empty(oComp:CDTCOMP) 
			If Empty(cToD(oComp:CDTCOMP))
				lRet := .F.
				cRet += "PARAMETRO INVALIDO: CDTCOMP" 
			Else 
				dDataBase := cToD(oComp:CDTCOMP)
			EndIf
		EndIf

		If lRet .And. nOperac == 3 .And. !Positivo(Val(oComp:cValor)) 
			lRet := .F.
			cRet += "PARAMETRO OBRIGATORIO INVALID: cValor" 
		EndIf
	
		If lRet 
			Pergunte("FIN330",.F.)
			lContab	:= MV_PAR09 == 1
			lComis		:= MV_PAR06 == 1
			
			If nOperac == 3  
				
				SE1->(DbSetOrder(2)) // E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
		
				If !SE1->(DbSeek(xFilial("SE1") + Padr(oComp:cCLI_RA,nTamCli) + Padr(oComp:cLOJARA,nTamLoja) + Padr(oComp:cPREFRA,nTamPref) + Padr(oComp:cNUMRA,nTamNum) + Padr(oComp:cPARCRA,nTamParc) + "RA"))
					cRet += "TITULO RA NAO LOCALIZADO"	
					lRet := .F. 
				EndIf 
				
				If lRet .And. SE1->E1_SALDO <= 0
					cRet += "TITULO RA JA BAIXADO"
					lRet := .F. 
				EndIf 
				
				If lRet
					nRecnoRA := SE1->(Recno())
					
					If !SE1->(DbSeek(xFilial("SE1") + Padr(oComp:cCLIENTE,nTamCli) + Padr(oComp:cLOJA,nTamLoja) + Padr(oComp:cPREFIXO,nTamPref) + Padr(oComp:cNUM,nTamNum) + Padr(oComp:cPARCELA,nTamParc) + Padr(oComp:cTIPO,nTamTipo)))
						cRet += "TITULO PRINCIPAL NAO LOCALIZADO"
						lRet := .F. 
					EndIf 
					
				EndIf 
				
				If lRet 											
					nRecnoSE1 := SE1->(Recno())
					SE1->(dbSetOrder(1)) //E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_FORNECE + E1_LOJA
				
					aRecRA  := {nRecnoRA}
					aRecSE1 := {nRecnoSE1}
					cXIDBXF := oComp:cXIDBXF	
					Begin Transaction 
						lRet := MaIntBxCR(3,aRecSE1,,aRecRA,,{lContab,.F.,.F.,.F.,.F.,lComis},,,,,Val(oComp:cValor))
						
						If !lRet 		
							If lMsErroAuto 
								cRet += "INCONSISTENCIA DE ROTINA AUTOMATICA | " + CRLF
								aLog := GetAutoGRLog()
								For nY := 1 To Len(aLog)
									cRet += aLog[nY] + CRLF
								Next nY
							Else 
								cRet += "COMPENSACAO NAO REALIZADA"
								lRet := .F.
							EndIf 
						Else //
							cRet := "OK|" + cXID + "|" + cXIDBXF
							cIndKey := xFilial("SE5") + "|" + cXID
						EndIf	
					End Transaction 	
				Endif 
			Else 
				SE5->(DBOrderNickName("EF0702801"))
				If Empty(oComp:CIDFK1) .Or. !SE5->(DbSeek(xFilial("SE5") + oComp:CIDFK1))
					lRet := .F. 
					cRet += "CIDFK1 INVALIDO"
				Else 
					cChave := xFilial("SE5") + oComp:CIDFK1
					cIndKey:= xFilial("SE5") + "|" + oComp:CIDFK1
					SE1->(DbSetOrder(1))
					While !SE5->(Eof()) .And. SE5->E5_FILIAL + AllTrim(SE5->E5_XID) == cChave 
						If SE1->(DbSeek(xFilial("SE1") + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO))
							If Alltrim(SE5->E5_TIPO) == "RA"
								nRecnoRA 	:= SE1->(Recno())
								AAdd(aEstorn, {SE5->E5_DOCUMEN})
								nValor		:= SE5->E5_VALOR
							Else
								nRecnoSE1 	:= SE1->(Recno())
								AAdd(aEstorn, {SE5->E5_DOCUMEN})
							EndIf 
							cFK5IDBXF := SE5->E5_IDORIG

							SE5->(DbSkip())
						EndIf
					EndDo
					aRecRA 	:= {nRecnoRA}
					aRecSE1	:= {nRecnoSE1}

					lRet := MaIntBxCR(3,aRecSE1,,aRecRA,,{lContab,.F.,.F.,.F.,.F.,lComis},,aEstorn,,,nValor)

					If !lRet 		
						If lMsErroAuto 
							cRet += "INCONSISTENCIA DE ROTINA AUTOMATICA | " + CRLF
							aLog := GetAutoGRLog()
							For nY := 1 To Len(aLog)
								cRet += aLog[nY] + CRLF
							Next nY
						Else 
							cRet += "ESTORNO DA COMPENSACAO NAO REALIZADO"
							lRet := .F.
						EndIf 
					Else 
						cRet := "OK"
						FK5->(DbSetOrder(1)) //FK5_FILIAL+FK5_IDMOV
						If FK5->(DbSeek(xFilial("FK5")+cFK5IDBXF))
							cRet += "|" + FK5->FK5_XIDBXF
						Endif
					EndIf
				EndIf 
			EndIf 

		EndIf
		
	End Sequence 
	
	ErrorBlock(bBlock)

	If !Empty(cErrorL)
		lRet := .F. 
		cRet += "ERRO DE PROGRAMACAO | " + CRLF + cErrorL
	EndIf 

	SE5->(DBOrderNickName("EF0702801"))
	nOrdem := SE5->(IndexOrd())
	U_F07Log02(nRegLog, cRet, lRet,"SE5",nOrdem,cIndKey)

	dDataBase := Date()

Return cRet

/*/{Protheus.doc} ChkErr
Função para tratamento de erros 
@type function
@author anieli.rodrigues
@since 20/03/2017
@version 12.7
@param oErroArq, object, Dados do erro capturado
@project MAN0000007423041_EF_028
/*/

Static Function ChkErr(oErroArq)

	Local nI:= 0
	
	If oErroArq:GenCode > 0
		cErrorL := '(' + Alltrim(Str(oErroArq:GenCode)) + ') : ' + AllTrim(oErroArq:Description) + CRLF
	EndIf  
	
	nI := 2
	
	While (!Empty(ProcName(ni)))
		cErrorL += Trim(ProcName(ni)) + "(" + Alltrim(Str(ProcLine(ni))) + ") " + CRLF
		ni ++
	End                
	If Intransact()
		cErrorL +="Transacao aberta desarmada"
	 	DisarmTransaction()
	EndIf
	Break
Return
