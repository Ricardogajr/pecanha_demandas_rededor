// #########################################################################################
// Projeto: Monkey
// Modulo : SIGAFIN
// Fonte  : operations
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 17/05/21 | Rafael Yera Barchi| Liquida títulos negociados no Portal Monkey
// ---------+-------------------+-----------------------------------------------------------

#INCLUDE    "TOTVS.CH"
#INCLUDE    "RESTFUL.CH"

#DEFINE     cEOL            Chr(13) + Chr(10)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} operations 
Liquida títulos negociados no Portal Monkey

@author    Rafael Yera Barchi
@version   1.xx
@since     17/05/2021
/*/
//------------------------------------------------------------------------------------------
WSRESTFUL operations DESCRIPTION "ATOS DATA operations - Operações dos Títulos"

WSDATA 		cResponse   AS STRING

WSMETHOD 	POST 		DESCRIPTION "Operações realizadas nos títulos confirmados" WSSYNTAX "/operations"

END WSRESTFUL



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} operations
operations - Método POST

@author    Rafael Yera Barchi
@version   1.xx
@since     17/05/2021

Exemplo de Requisição: 
//--- Início
Endpoint: http://18.228.227.63:8189/atosdata/operations
Body: 

//--- Fim

/*/
//------------------------------------------------------------------------------------------
WSMETHOD POST WSSERVICE operations

	Local 	lReturn     := .T.
	Local 	lCheckAuth  := SuperGetMV("MK_CHKAUTH", , .F.)
	Local   oObjJSON    := Nil
	Local   cPrefixo    := SuperGetMV("MK_PREFIXO", , "NEG")
	Local   cTipoFat    := SuperGetMV("MK_TIPOFAT", , "FT ")
	Local   cCondPag    := SuperGetMV("MK_CONDPAG", , "001")
	Local   dVencOri    := CToD("")
	Local   cHistOri    := ""
	Local   cPortOri    := ""
	Local   cBcoOri     := ""
	Local   cAgeOri     := ""
	Local   cDVAgOri    := ""
	Local   cCtaOri     := ""
	Local   cDVCtOri    := ""
	Local   cAgePag     := ""
	Local   cDVAgPag    := ""
	Local   cCtaPag     := ""
	Local   cDVCtPag    := ""
	Local   cFormOri    := ""
	Local   cFormPg     := ""
	Local   cFatura     := ""
	Local 	cBody	    := ""
	Local   cErro       := ""
	Local	cMessage 	:= ""
	Local 	cResponse 	:= ""
	//  Local 	cLogFile 	:= ""
	//  Local   aLog        := {}
	Local   aTitulos    := {}
	Local   aFatura     := {}
	Local 	nHTTPCode 	:= 400
	//  Local   nHandle     := 0
	Local   nRegSE2     := 0
	Local   nI          := 0
	//  Local   nY          := 0
	Local   nTam        := 0
	Local   nTaxa       := 0
	Local   nAcresc     := 0
	Local   nDecresc    := 0
	Local   nAcrOri     := 0
	Local   nDecrOri    := 0
	Local   nVlJurOri   := 0
	Local   nVlMulOri   := 0
	Local   nVlDesOri   := 0
	Local   nBsIRFOri   := 0
	Local   nBsINSOri   := 0
	Local   nBsISSOri   := 0
	Local   nBsPISOri   := 0
	Local   nBsCOFOri   := 0
	Local   nBsCSLOri   := 0
	Local   nVlIRFOri   := 0
	Local   nVlINSOri   := 0
	Local   nVlISSOri   := 0
	Local   nVlPISOri   := 0
	Local   nVlCOFOri   := 0
	Local   nVlCSLOri   := 0
	Local   nValBru     := 0
	Local   nValLiq     := 0
	Local   nRecnoSA2   := 0
	Local   nTamEmp     := Len(SM0->M0_CODIGO)
	Local   nTamFil     := Len(FWxFilial("SE2"))
	Local   cCNPJ       := SuperGetMV("MK_CNPJ", , "")
	Local   lFatCustom  := SuperGetMV("MK_FATCUST", , .F.)
	Local   lLibPag     := SuperGetMV("MV_CTLIPAG", , .F.)
	Local   cLogDir		:= SuperGetMV("MK_LOGDIR", , "\log\")
	Local cVarMvMRETISS:= GetMV('MV_MRETISS')
	Loca cVarMVNUMFATP:= GetMV("MV_NUMFATP")
	Local   cLogArq		:= "operations"

	Private lMSErroAuto := .F.
	Private lMSHelpAuto := .T.

	Private lCxProp     := .F.


	ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Início"))
	FWLogMsg("INFO", , "MONKEY", "operations", "001", "001", "Início do Processo", 0, 0, {})

	::SetContentType("application/JSON;charset=UTF-8")

	If lCheckAuth
		cUser := U_MNKRetUsr(::GetHeader("Authorization"))
	Else
		ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Executando sem autenticação"))
		FWLogMsg("WARN", , "MONKEY", "operations", "002", "400", "Início do Processo", 0, 0, {})
	EndIf

	// Verifica a condição de pagamento
	SE4->(DBSelectArea("SE4"))
	SE4->(DBSetOrder(1))
	If !SE4->(DBSeek(FWxFilial("SE4") + cCondPag))
		lReturn		:= .F.
		nHTTPCode 	:= 412
		cMessage 	:= "Condição de pagamento não cadastrada"
	EndIf

	If lReturn 

		If lCheckAuth .And. Empty(cUser)

			lReturn		:= .F.
			nHTTPCode 	:= 401
			cMessage 	:= "Usuário não autenticado"

		Else

			cBody := DecodeUTF8(AllTrim(::GetContent()))
			MemoWrite(cLogDir + cLogArq + "_request.json", cBody)

			If FWJSONDeserialize(cBody, @oObjJSON)

				ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations FWJSONDeserialize"))

				lReturn		:= .T.

				For nI := 1 To Len(oObjJSON:OPERATIONS)

					ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Registro: " + CValToChar(nI) + "/" + CValToChar(Len(oObjJSON:OPERATIONS))))
					ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations externalId: " + oObjJSON:OPERATIONS[nI]:externalId))

					nAcresc     := 0
					nAcrOri     := 0
					nDecresc    := 0
					nDecrOri    := 0

					cEmpAnt     := SubStr(oObjJSON:OPERATIONS[nI]:externalId, 1, nTamEmp)
					cFilAnt     := SubStr(oObjJSON:OPERATIONS[nI]:externalId, nTamEmp + 1, nTamFil)
					nRegSE2     := Val(SubStr(oObjJSON:OPERATIONS[nI]:externalId, nTamEmp + nTamFil + 1, Len(AllTrim(oObjJSON:OPERATIONS[nI]:externalId)) - (nTamEmp + nTamFil)))

					If Empty(cCNPJ)
						cCNPJ := SM0->M0_CGC
					EndIf

					SE2->(DBSelectArea("SE2"))
					// Mudamos o seek para usar o Recno
					/*
					SE2->(DBSetOrder(1))
					If SE2->(DBSeek(oObjJSON:OPERATIONS[nI]:externalId))
					*/
					SE2->(DBGoTo(nRegSE2))

					ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Chave: " + SE2->E2_FILIAL + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA))

					// Verifica operação
					Do Case

						Case AllTrim(Upper(oObjJSON:OPERATIONS[nI]:eventType)) == "SOLD"

						ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations SOLD "))

						If SE2->(FieldPos("E2_XAGEPOR")) > 0
							cAgePag     := SE2->E2_XAGEPOR
						EndIf
						If SE2->(FieldPos("E2_XDVAPOR")) > 0
							cDVAgPag    := SE2->E2_XDVAPOR
						EndIf
						If SE2->(FieldPos("E2_XCONPOR")) > 0
							cCtaPag     := SE2->E2_XCONPOR
						EndIf
						If SE2->(FieldPos("E2_XDVCPOR")) > 0
							cDVCtPag    := SE2->E2_XDVCPOR
						EndIf

						nBsIRFOri   := SE2->E2_BASEIRF
						nBsINSOri   := SE2->E2_BASEINS
						nBsISSOri   := SE2->E2_BASEISS
						nBsPISOri   := SE2->E2_BASEPIS
						nBsCOFOri   := SE2->E2_BASECOF
						nBsCSLOri   := SE2->E2_BASECSL
						nVlIRFOri   := SE2->E2_IRRF
						nVlINSOri   := SE2->E2_INSS
						nVlISSOri   := SE2->E2_ISS
						nVlPISOri   := SE2->E2_PIS
						nVlCOFOri   := SE2->E2_COFINS
						nVlCSLOri   := SE2->E2_CSLL
						nAcrOri     := SE2->E2_SDACRES
						nDecrOri    := SE2->E2_SDDECRE
						nVlJurOri   := SE2->E2_JUROS
						nVlMulOri   := SE2->E2_MULTA
						nVlDesOri   := SE2->E2_DESCONT

						nValBru     := SE2->E2_VALOR

						If !Empty(SE2->E2_PARCIR)
							nValBru := nValBru + SE2->E2_IRRF
						EndIf

						If !Empty(SE2->E2_PARCINS)
							nValBru := nValBru + SE2->E2_INSS
						EndIf

						If !Empty(SE2->E2_PARCISS)
							nValBru := nValBru + SE2->E2_ISS
						EndIf

						If !Empty(SE2->E2_PARCPIS)
							nValBru := nValBru + SE2->E2_PIS
						EndIf

						If !Empty(SE2->E2_PARCCOF)
							nValBru := nValBru + SE2->E2_COFINS
						EndIf

						If !Empty(SE2->E2_PARCSLL)
							nValBru := nValBru + SE2->E2_CSLL
						EndIf

						/*
						nValLiq     := SE2->E2_VALOR + SE2->E2_ACRESC - SE2->E2_DECRESC

						If Empty(SE2->E2_PARCIR)
						nValLiq := nValLiq - SE2->E2_IRRF
						EndIf

						If Empty(SE2->E2_PARCINS)
						nValLiq := nValLiq - SE2->E2_INSS
						EndIf

						If Empty(SE2->E2_PARCISS)
						nValLiq := nValLiq - SE2->E2_ISS
						EndIf

						If Empty(SE2->E2_PARCPIS)
						nValLiq := nValLiq - SE2->E2_PIS
						EndIf

						If Empty(SE2->E2_PARCCOF)
						nValLiq := nValLiq - SE2->E2_COFINS
						EndIf

						If Empty(SE2->E2_PARCSLL)
						nValLiq := nValLiq - SE2->E2_CSLL
						EndIf
						*/

						// Regra informada pelo Sr. Ramon Silva em e-mail do dia 12/11/2021: 
						nValLiq := ((SE2->E2_VALOR + SE2->E2_ACRESC + SE2->E2_MULTA + SE2->E2_JUROS) - (IIf(AllTrim(cVarMvMRETISS) == '1', (SE2->E2_COFINS + SE2->E2_PIS + SE2->E2_CSLL + SE2->E2_DESCONT + SE2->E2_DECRESC), (SE2->E2_ISS + SE2->E2_COFINS + SE2->E2_PIS + SE2->E2_CSLL + SE2->E2_DESCONT + SE2->E2_DECRESC))))
						ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Valor Líquido: " + CValToChar(nValLiq)))

						// Verifica se é caixa próprio
						If oObjJSON:OPERATIONS[nI]:buyerGovernmentId $ cCNPJ
							// Se for caixa próprio, utiliza o mesmo fornecedor do título original
							ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Caixa Próprio "))
							lCxProp     := .T.
							nTaxa       := oObjJSON:OPERATIONS[nI]:paymentValue - oObjJSON:OPERATIONS[nI]:sellerReceivementValue
							ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Taxa: " + CValToChar(nTaxa)))
							cHistOri    := SE2->E2_HIST
							cBcoOri     := SE2->E2_FORBCO
							cAgeOri     := SE2->E2_FORAGE
							cDVAgOri    := SE2->E2_FAGEDV
							cCtaOri     := SE2->E2_FORCTA
							cDVCtOri    := SE2->E2_FCTADV
							cFormOri    := SE2->E2_FORMPAG
							// Rafael Yera Barchi - 09/09/2022
							// Nos testes na Rede D'Or isso estava duplicando o decréscimo
							nDecrOri    := 0    //SE2->E2_DECRESC
							nDecresc    := nDecrOri + nTaxa
							nValLiq     := nValLiq - nTaxa
							ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Valor Líquido - Taxa: " + CValToChar(nValLiq)))
							If SE2->(FieldPos("E2_XPORTAD")) > 0 .And. !Empty(SE2->E2_XPORTAD)
								cPortOri := SE2->E2_XPORTAD
								// Rafael Yera Barchi - 17/09/2021
								// Não deve gravar o Banco Monkey
								/*
								Else
								cPortOri := SE2->E2_PORTADO
								*/
							EndIf
							SA2->(DBSelectArea("SA2"))
							SA2->(DBSetOrder(1))
							If SA2->(DBSeek(FWxFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA))
								lReturn     := .T.
								cMessage 	:= "Fornecedor localizado -> Código: " + SA2->A2_COD + " - Loja: " + SA2->A2_LOJA
								ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Fornecedor localizado -> Código: " + SA2->A2_COD + " - Loja: " + SA2->A2_LOJA))
							Else
								lReturn     := .F.
								nHTTPCode 	:= 500
								cMessage 	:= "Fornecedor não localizado -> CNPJ: " + AllTrim(oObjJSON:OPERATIONS[nI]:buyerGovernmentId)
								ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Fornecedor não localizado -> (SE2: Código: " + SE2->E2_FORNECE + " - Loja: " + SE2->E2_LOJA + ") CNPJ: " + AllTrim(oObjJSON:OPERATIONS[nI]:buyerGovernmentId)))
							EndIf
						Else
							// Se não for caixa próprio, localiza o fornecedor da instituição financeira que comprou o título (buyer)
							ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Caixa Terceiro Buyer "))
							lCxProp     := .F.
							cHistOri    := SE2->E2_HIST
							dVencOri    := SE2->E2_VENCTO
							nDecrOri    := 0
							nDecresc    := 0
							If SE2->(FieldPos("E2_XPORTAD")) > 0 .And. !Empty(SE2->E2_XPORTAD)
								cPortOri := SE2->E2_XPORTAD
								// Rafael Yera Barchi - 17/09/2021
								// Não deve gravar o Banco Monkey
								/*
								Else
								cPortOri := SE2->E2_PORTADO
								*/
							EndIf
							SA2->(DBSelectArea("SA2"))
							SA2->(DBSetOrder(3))
							If SA2->(DBSeek(FWxFilial("SA2") + AllTrim(oObjJSON:OPERATIONS[nI]:buyerGovernmentId)))
								lReturn     := .T.
								cMessage 	:= "Fornecedor localizado -> Código: " + SA2->A2_COD + " - Loja: " + SA2->A2_LOJA
								ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Fornecedor localizado -> Código: " + SA2->A2_COD + " - Loja: " + SA2->A2_LOJA))
							Else
								lReturn     := .F.
								nHTTPCode 	:= 500
								cMessage 	:= "Fornecedor não localizado -> CNPJ: " + AllTrim(oObjJSON:OPERATIONS[nI]:buyerGovernmentId)
								ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Fornecedor não localizado -> CNPJ: " + AllTrim(oObjJSON:OPERATIONS[nI]:buyerGovernmentId)))
							EndIf

							// Movi todo este trecho a seguir para o novo título gerado pela fatura, pois deve verificar a forma de pagamento pelo novo título
							/*
							E-mail do Sr. Ramon Silva - 19/08/2021
							Banco do Fornecedor igual ao Portador: Gatilha forma de pagamento “01 – Crédito em conta corrente”
							Banco do Fornecedor diferente do Portador: Gatilha forma de pagamento “41 – TED Outro Titular”
							Portador igual aos 3 primeiros dígitos do código de barras: Gatilha forma de pagamento “30 – Boleto mesmo banco”
							Portador diferente dos 3 primeiros dígitos do código de barras: Gatilha forma de pagamento “31 – Boleto outros bancos”
							*/
							/*
							If !Empty(SE2->E2_FORBCO)
							If (SE2->E2_XPORTAD == SE2->E2_FORBCO .Or. SE2->E2_PORTADO == SE2->E2_FORBCO)
							cFormPg := "01"
							Else
							cFormPg := "41"
							EndIf
							EndIf
							If !Empty(SE2->E2_CODBAR)
							If (SE2->E2_XPORTAD == Left(SE2->E2_CODBAR, 3) .Or. SE2->E2_PORTADO == Left(SE2->E2_CODBAR, 3))
							cFormPg := "30"
							Else
							cFormPg := "31"
							EndIf
							EndIf
							*/
							// SA2->(DBSetOrder(1))
						EndIf

						If lReturn

							If SE2->E2_SALDO == 0

								lReturn		:= .T.
								nHTTPCode 	:= 201
								cMessage 	:= "Título já baixado anteriormente"
								ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Título já baixado anteriormente"))
								FWLogMsg("INFO", , "MONKEY", "operations", "003", "101", "Título já baixado anteriormente", 0, 0, {})

							Else

								// Limpa dados do borderô
								ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Gravacao SEA"))
								SEA->(DBSelectArea("SEA"))
								SEA->(DBSetOrder(1))
								If SEA->(DBSeek(FWxFilial("SEA") + SE2->E2_NUMBOR + "P" + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA))
									If RecLock("SEA", .F.)
										SEA->(DBDelete())
										SE2->(MSUnLock())
									Else
										ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Não foi possível reservar registro - SEA"))
										FWLogMsg("ERROR", , "MONKEY", "operations", "004", "501", "Não foi possível reservar registro - SEA", 0, 0, {})
									EndIf
								EndIf

								ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Gravacao SE2"))
								If RecLock("SE2", .F.)
									SE2->E2_PORTADO := Space(TamSX3("E2_PORTADO")[1])
									SE2->E2_NUMBOR  := Space(TamSX3("E2_NUMBOR")[1])
									SE2->E2_DTBORDE := CToD("")
									SE2->E2_XMNKSTA := "2"
									SE2->(MSUnLock())
								Else
									ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Não foi possível reservar registro - SE2"))
									FWLogMsg("ERROR", , "MONKEY", "operations", "005", "501", "Não foi possível reservar registro - SE2", 0, 0, {})
								EndIf

								// Salvo Recno do fornecedor localizado
								nRecnoSA2 := SA2->(Recno())

								//[01] - Prefixo
								//[02] - Tipo
								//[03] - Numero da Fatura (se o numero estiver em branco obtem pelo FINA290)
								//[04] - Natureza
								//[05] - Data de
								//[06] - Data Ate
								//[07] - Fornecedor
								//[08] - Loja
								//[09] - Fornecedor para geracao
								//[10] - Loja do fornecedor para geracao
								//[11] - Condicao de pagto
								//[12] - Moeda
								//[13] - ARRAY com os titulos da fatura
								//[13,1] Prefixo
								//[13,2] Numero
								//[13,3] Parcela
								//[13,4] Tipo
								//[13,5] Titulo localizado na geracao de fatura (logico). Iniciar com falso.
								//[14] - Valor de decrescimo
								//[15] - Valor de acrescimo

								AAdd(aTitulos, {SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, .F.})

								nTam 	:= TamSX3("E2_NUM")[1]
								cFatura	:= Soma1(cVarMVNUMFATP)
								cFatura	:= PadR(cFatura, nTam)

								// Rafael Yera Barchi - 16/12/2021
								// Ajuste por conta de problemas quando o serviço parava com o processo em andamento
								// Grava no SX6 o numero da ultima fatura gerada
								//                                        GetMV("MV_NUMFATP")
								//                                        RecLock("SX6", .F.)
								//                                            SX6->X6_CONTEUD := cFatura
								//                                        SX6->(MSUnLock())
								putmv("MV_NUMFATP",cFatura)

								ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Numero da Fatura: " + cFatura))

								aFatura := {    cPrefixo,           ;//1
								cTipoFat,           ;//2
								cFatura,            ;//3
								SE2->E2_NATUREZ,    ;//4
								SE2->E2_EMISSAO,    ;//5
								SE2->E2_EMISSAO,    ;//6
								SE2->E2_FORNECE,    ;//7
								SE2->E2_LOJA,       ;//8
								SA2->A2_COD,        ;//9
								SA2->A2_LOJA,       ;//10
								cCondPag,           ;//11
								SE2->E2_MOEDA,      ;//12
								aTitulos,           ;//13
								nDecresc,           ;//14
								nAcresc             }//15 

								lMSErroAuto := .F.

								SA2->(DBSetOrder(1))
								SE2->(DBSetOrder(1))
								SEA->(DBSetOrder(1))

								// Backup das perguntas da rotina
								Pergunte("AFI290",.F.)
								__BKMV01 := MV_PAR01
								__BKMV02 := MV_PAR02

								// Altero o conteúdo das perguntas
								MV_PAR01 := 2   // Considera lojas = Não (Quando está sim, não é possível gerar para outro fornecedor)
								MV_PAR02 := 2   // Mostra lançamentos contábeis = Não

								If lFatCustom
									ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations (U) FINA290 Início"))
									MSExecAuto({|x,y| U_MY290FI(x,y)}, 3, aFatura, .T.)
									ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations (U) FINA290 Fim"))
								Else
									ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations FINA290 Início"))
									MSExecAuto({|x,y| FINA290(x,y)}, 3, aFatura, )
									ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations FINA290 Fim"))
								EndIf

								If lMSErroAuto

									/*
									ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Erro FINA290"))

									cLogFile := cLogDir + cLogArq + "_erro.log"
									aLog := GetAutoGRLog()
									If !File(cLogFile)			
									If (nHandle := MSFCreate(cLogFile, 0)) <> -1				
									lRet := .T.	
									EndIf
									Else			
									If (nHandle := FOpen(cLogFile, 2)) <> -1				
									FSeek(nHandle, 0, 2)				
									lRet := .T.			
									EndIf		
									EndIf		

									If lRet
									For nY := 1 To Len(aLog)				
									FWrite(nHandle, aLog[nY] + cEOL)
									If !Empty(cErro)
									cErro += cEOL
									EndIf
									cErro += aLog[nY]
									Next nY
									FClose(nHandle)		
									EndIf
									*/
									cErro	:= ArrayToStr(GetAutoGrLog())

									ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Erro FINA290 " + cErro))
									FWLogMsg("ERROR", , "MONKEY", "operations", "006", "502", "Erro na rotina de geração de fatura", 0, 0, {})

									lReturn     := .F.
									nHTTPCode 	:= 500
									cMessage 	:= "Erro na geração da fatura: " + cErro
									MemoWrite(cLogDir + cLogArq + "_erro.txt", cErro)

								Else

									ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations FINA290 OK"))
									lReturn := .T.

									ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Fornecedor: " + SE2->E2_FORBCO))

									// Reposiciono o forncedor do título original (na rotina de fatura, o fornecedor é desposicionado)
									SA2->(DBSelectArea("SA2"))
									SA2->(DBSetOrder(1))
									SA2->(DBGoTo(nRecnoSA2))

									SE2->(DBSelectArea("SE2"))
									SE2->(DBSetOrder(1))
									SE2->(DBSeek(FWxFilial("SE2") + cPrefixo + cFatura))
									While !SE2->(EOF()) .And. SE2->E2_FILIAL == FWxFilial("SE2") .And. SE2->E2_PREFIXO == cPrefixo .And. SE2->E2_NUM == cFatura

										If RecLock("SE2", .F.)
											ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Gravação de campos específicos - SE2"))
											If lLibPag
												SE2->E2_DATALIB  := dDataBase
											EndIf
											If lCxProp
												ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Caixa Próprio"))
												SE2->E2_FORBCO  := cBcoOri
												SE2->E2_FORAGE  := cAgeOri
												SE2->E2_FAGEDV  := cDVAgOri
												SE2->E2_FORCTA  := cCtaOri
												SE2->E2_FCTADV  := cDVCtOri
											Else
												ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Caixa Terceiro"))
												SE2->E2_VENCTO  := dVencOri
												SE2->E2_VENCREA := DataValida(dVencOri, .T.)
												SE2->E2_FORBCO  := SA2->A2_BANCO
												SE2->E2_FORAGE  := SA2->A2_AGENCIA
												SE2->E2_FAGEDV  := SA2->A2_DVAGE
												SE2->E2_FORCTA  := SA2->A2_NUMCON
												SE2->E2_FCTADV  := SA2->A2_DVCTA
											EndIf
											If SE2->(FieldPos("E2_XRISCOS")) > 0
												SE2->E2_XRISCOS  := "S"
											EndIf
											If SE2->(FieldPos("E2_XANALIS")) > 0
												SE2->E2_XANALIS  := "S"
											EndIf
											If SE2->(FieldPos("E2_XAGEPOR")) > 0
												SE2->E2_XAGEPOR := cAgePag
											EndIf
											If SE2->(FieldPos("E2_XDVAPOR")) > 0
												SE2->E2_XDVAPOR := cDVAgPag
											EndIf
											If SE2->(FieldPos("E2_XCONPOR")) > 0
												SE2->E2_XCONPOR := cCtaPag
											EndIf
											If SE2->(FieldPos("E2_XDVCPOR")) > 0
												SE2->E2_XDVCPOR := cDVCtPag
											EndIf
											If SE2->(FieldPos("E2_XVLBRUT")) > 0
												SE2->E2_XVLBRUT  := nValBru
											EndIf
											If SE2->(FieldPos("E2_XVLLIQ")) > 0
												SE2->E2_XVLLIQ  := nValLiq
											EndIf
											// Removido nos testes realizados em 13/08/2021
											/*
											If SE2->(FieldPos("E2_XLIBERA")) > 0
											SE2->E2_XLIBERA := "L"
											EndIf
											*/
											SE2->E2_BASEIRF := nBsIRFOri
											SE2->E2_BASEINS := nBsINSOri
											SE2->E2_BASEISS := nBsISSOri
											SE2->E2_BASEPIS := nBsPISOri
											SE2->E2_BASECOF := nBsCOFOri
											SE2->E2_BASECSL := nBsCSLOri
											SE2->E2_IRRF    := nVlIRFOri
											SE2->E2_INSS    := nVlINSOri
											SE2->E2_ISS     := nVlISSOri
											SE2->E2_PIS     := nVlPISOri
											SE2->E2_COFINS  := nVlCOFOri
											SE2->E2_CSLL    := nVlCSLOri
											// SE2->E2_SDACRES := nAcrOri
											// SE2->E2_SDDECRE := nDecrOri
											SE2->E2_JUROS   := nVlJurOri
											SE2->E2_MULTA   := nVlMulOri
											SE2->E2_DESCONT := nVlDesOri
											SE2->E2_HIST    := cHistOri
											SE2->E2_PORTADO := cPortOri
											SE2->(MSUnLock())

										Else

											ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Não foi possível reservar registro - SE2 (1)"))
											FWLogMsg("ERROR", , "MONKEY", "operations", "007", "501", "Não foi possível reservar registro - SE2 (1)", 0, 0, {})

										EndIf

										/*
										E-mail do Sr. Ramon Silva - 19/08/2021
										Banco do Fornecedor igual ao Portador: Gatilha forma de pagamento “01 – Crédito em conta corrente”
										Banco do Fornecedor diferente do Portador: Gatilha forma de pagamento “41 – TED Outro Titular”
										Portador igual aos 3 primeiros dígitos do código de barras: Gatilha forma de pagamento “30 – Boleto mesmo banco”
										Portador diferente dos 3 primeiros dígitos do código de barras: Gatilha forma de pagamento “31 – Boleto outros bancos”
										*/
										ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Banco Fornecedor: " + SE2->E2_FORBCO))
										// Comentado em 01/09/2022 a pedido do Sr. Ricardo Almeida após reunião com usuários da Rede D'Or
										//If !Empty(SE2->E2_FORBCO)
										If (SE2->E2_XPORTAD == SE2->E2_FORBCO .Or. SE2->E2_PORTADO == SE2->E2_FORBCO)
											cFormPg := "01"
										Else
											cFormPg := "41"
										EndIf
										//EndIf

										// Comentado em 01/09/2022 a pedido do Sr. Ricardo Almeida após reunião com usuários da Rede D'Or
										/*
										ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Código de Barras: " + SE2->E2_CODBAR))
										If !Empty(SE2->E2_CODBAR)
										If (SE2->E2_XPORTAD == Left(SE2->E2_CODBAR, 3) .Or. SE2->E2_PORTADO == Left(SE2->E2_CODBAR, 3))
										cFormPg := "30"
										Else
										cFormPg := "31"
										EndIf
										EndIf
										*/

										If RecLock("SE2", .F.)
											ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Gravação da forma de pagamento - SE2"))
											SE2->E2_FORMPAG := cFormPg
											/*
											If lCxProp
											ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Caixa Próprio"))
											SE2->E2_FORMPAG := cFormOri
											ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Forma Pagamento (Título Original): " + cFormOri))
											Else
											ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Caixa Terceiro"))
											SE2->E2_FORMPAG := cFormPg
											ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Forma Pagamento: " + cFormPg))
											EndIf
											*/
											SE2->(MSUnLock())

										Else

											ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Não foi possível reservar registro - SE2 (2)"))
											FWLogMsg("ERROR", , "MONKEY", "operations", "007", "501", "Não foi possível reservar registro - SE2 (2)", 0, 0, {})

										EndIf

										SE2->(DBSkip())

									EndDo

									lReturn		:= .T.
									nHTTPCode 	:= 201
									cMessage 	:= "Operações realizadas com sucesso"

								EndIf

								// Restauro backup das perguntas da rotina
								MV_PAR01 := __BKMV01
								MV_PAR02 := __BKMV02

							EndIf

						EndIf


						Case AllTrim(Upper(oObjJSON:OPERATIONS[nI]:eventType)) == "DELETED"

						ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations DELETED "))

						If SE2->E2_XMNKSTA $ "1|5"  // Título já confirmado no settlement

							// Limpa dados do borderô
							SEA->(DBSelectArea("SEA"))
							SEA->(DBSetOrder(1))
							If SEA->(DBSeek(FWxFilial("SEA") + SE2->E2_NUMBOR + "P" + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA))
								If RecLock("SEA", .F.)
									SEA->(DBDelete())
									SEA->(MSUnLock())
								Else
									lReturn		:= .F.
									nHTTPCode 	:= 423
									cMessage 	:= "DELETED - Não foi possível reservar registro - SEA"
									ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations DELETED - Não foi possível reservar registro - SEA"))
									FWLogMsg("ERROR", , "MONKEY", "operations", "008", "501", "DELETED - Não foi possível reservar registro - SEA", 0, 0, {})
								EndIf
							EndIf

							If RecLock("SE2", .F.)
								If SE2->(FieldPos("E2_XPORTAD")) > 0
									SE2->E2_PORTADO := SE2->E2_XPORTAD
								Else
									SE2->E2_PORTADO := Space(TamSX3("E2_PORTADO")[1])
								EndIf
								SE2->E2_NUMBOR  := Space(TamSX3("E2_NUMBOR")[1])
								SE2->E2_DTBORDE := CToD("")
								// Em 02/08/2022 - Ricardo solicitou para limpar estes campos apenas se o título foi excluído manualmente no Portal (Status = 1)
								If SE2->E2_XMNKSTA == "1"
									SE2->E2_XMNKSTA := Space(TamSX3("E2_XMNKSTA")[1])
									SE2->E2_XMNKLOT := Space(TamSX3("E2_XMNKLOT")[1])
								EndIf
								SE2->(MSUnLock())
							Else
								lReturn		:= .F.
								nHTTPCode 	:= 423
								cMessage 	:= "DELETED - Não foi possível reservar registro - SE2"
								ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations DELETED - Não foi possível reservar registro - SE2"))
								FWLogMsg("ERROR", , "MONKEY", "operations", "009", "501", "DELETED - Não foi possível reservar registro - SE2", 0, 0, {})
							EndIf

						Else

							lReturn		:= .F.
							nHTTPCode 	:= 425
							cMessage 	:= "DELETED - Não foi recebida a confirmação deste registro"
							ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations DELETED - Não foi recebida a confirmação deste registro"))
							FWLogMsg("ERROR", , "MONKEY", "operations", "011", "502", "DELETED - Não foi recebida a confirmação deste registro", 0, 0, {})

						EndIf

						Case AllTrim(Upper(oObjJSON:OPERATIONS[nI]:eventType)) == "DUPLICATED"

						ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations DUPLICATED "))


						Case AllTrim(Upper(oObjJSON:OPERATIONS[nI]:eventType)) == "REFUSED"

						ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations REFUSED "))

						// Rafael Yera Barchi - 14/09/2022
						// A operação REFUSED estava igual a operação DELETED
						// Ricardo solicitou mudar para devolver 200 e não fazer nada no ERP
						/*
						If SE2->E2_XMNKSTA $ "1|5"  // Título já confirmado no settlement

						// Limpa dados do borderô
						SEA->(DBSelectArea("SEA"))
						SEA->(DBSetOrder(1))
						If SEA->(DBSeek(FWxFilial("SEA") + SE2->E2_NUMBOR + "P" + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA))
						If RecLock("SEA", .F.)
						SEA->(DBDelete())
						SEA->(MSUnLock())
						Else
						lReturn		:= .F.
						nHTTPCode 	:= 423
						cMessage 	:= "REFUSED - Não foi possível reservar registro - SEA"
						ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations REFUSED - Não foi possível reservar registro - SEA"))
						FWLogMsg("ERROR", , "MONKEY", "operations", "008", "501", "REFUSED - Não foi possível reservar registro - SEA", 0, 0, {})
						EndIf
						EndIf

						If RecLock("SE2", .F.)
						If SE2->(FieldPos("E2_XPORTAD")) > 0
						SE2->E2_PORTADO := SE2->E2_XPORTAD
						Else
						SE2->E2_PORTADO := Space(TamSX3("E2_PORTADO")[1])
						EndIf
						SE2->E2_NUMBOR  := Space(TamSX3("E2_NUMBOR")[1])
						SE2->E2_DTBORDE := CToD("")
						// Em 02/08/2022 - Ricardo solicitou para limpar estes campos apenas se o título foi excluído manualmente no Portal (Status = 1)
						If SE2->E2_XMNKSTA == "1"
						SE2->E2_XMNKSTA := Space(TamSX3("E2_XMNKSTA")[1])
						SE2->E2_XMNKLOT := Space(TamSX3("E2_XMNKLOT")[1])
						EndIf
						SE2->(MSUnLock())
						Else
						lReturn		:= .F.
						nHTTPCode 	:= 423
						cMessage 	:= "REFUSED - Não foi possível reservar registro - SE2"
						ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations REFUSED - Não foi possível reservar registro - SE2"))
						FWLogMsg("ERROR", , "MONKEY", "operations", "009", "501", "REFUSED - Não foi possível reservar registro - SE2", 0, 0, {})
						EndIf

						Else

						lReturn		:= .F.
						nHTTPCode 	:= 425
						cMessage 	:= "REFUSED - Não foi recebida a confirmação deste registro"
						ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations REFUSED - Não foi recebida a confirmação deste registro"))
						FWLogMsg("ERROR", , "MONKEY", "operations", "011", "502", "REFUSED - Não foi recebida a confirmação deste registro", 0, 0, {})

						EndIf
						*/

						OtherWise

						lReturn		:= .F.
						nHTTPCode 	:= 500
						cMessage 	:= "Operação inválida: " + AllTrim(Upper(oObjJSON:OPERATIONS[nI]:eventType))
						FWLogMsg("ERROR", , "MONKEY", "operations", "011", "502", "Operação inválida", 0, 0, {})

					EndCase

					/*
					// Mudamos o seek para usar o Recno                
					Else

					lReturn		:= .F.
					nHTTPCode 	:= 500
					cMessage 	:= "Título não localizado: " + AllTrim(oObjJSON:OPERATIONS[nI]:externalId)

					EndIf
					*/

				Next nI

				cResponse := '{ '
				cResponse += '"operations": ' + CValToChar(Len(oObjJSON:OPERATIONS))
				cResponse += '} '

			Else

				lReturn		:= .F.
				nHTTPCode 	:= 500
				cMessage 	:= "Erro na função FWJSONDeserialize"
				FWLogMsg("ERROR", , "MONKEY", "operations", "012", "500", "Erro na função FWJSONDeserialize", 0, 0, {})

			EndIf

		EndIf

		ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations: " + cMessage))

	EndIf

	If !lReturn
		SetRestFault(nHTTPCode, EncodeUTF8(cMessage))
		::SetResponse(cResponse)
	Else
		::SetResponse(cResponse)
	EndIf

	MemoWrite(cLogDir + cLogArq + "_response.json", cResponse)

	ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | operations Fim"))
	FWLogMsg("INFO", , "MONKEY", "operations", "999", "999", "Fim do Processo", 0, 0, {})

Return lReturn
//--< fim de arquivo >----------------------------------------------------------------------
