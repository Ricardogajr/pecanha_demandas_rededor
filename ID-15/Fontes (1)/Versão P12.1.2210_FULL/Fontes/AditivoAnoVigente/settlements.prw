// #########################################################################################
// Projeto: Monkey
// Modulo : SIGAFIN
// Fonte  : settlements
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 17/05/21 | Rafael Yera Barchi| Confirma títulos em negociação no Portal Monkey
// ---------+-------------------+-----------------------------------------------------------

#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} settlements
Confirma títulos em negociação no Portal Monkey

@author    Rafael Yera Barchi
@version   1.xx
@since     17/05/2021
/*/
//------------------------------------------------------------------------------------------
WSRESTFUL settlements DESCRIPTION "ATOS DATA settlements - Confirmação de Títulos"

	WSDATA 		cResponse   AS STRING

	WSMETHOD 	POST 		DESCRIPTION "Confirma a seleção do título para negociação" WSSYNTAX "/settlements"

END WSRESTFUL



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} settlements
settlements - Método POST

@author    Rafael Yera Barchi
@version   1.xx
@since     17/05/2021

Exemplo de Requisição: 
//--- Início
Endpoint: http://18.228.227.63:8189/atosdata/settlements
Body: 
{
 "items": [
   {
       "externalId" : "01AUT00000053201",
       "successFlag" : "Y",
       "errorMessage" : null
   },
   {
       "externalId" : "01AUT00000054501",
       "successFlag" : "Y",
       "errorMessage" : null
   },
   {
       "externalId" : "01AUT00000054801",
       "successFlag" : "N",
       "errorMessage" : "O valor deve ser maior que R$5,01"
   }
 ]
}
//--- Fim

/*/
//------------------------------------------------------------------------------------------
WSMETHOD POST WSSERVICE settlements

	Local 	lReturn     := .T.
    Local 	lCheckAuth  := SuperGetMV("MK_CHKAUTH", , .F.)
	Local   oObjJSON    := Nil
	Local 	cBody	    := ""
	Local	cMessage 	:= ""
	Local 	cResponse 	:= ""
	Local 	nHTTPCode 	:= 400
	Local   nI          := 0
    Local   nRegSE2     := 0
    Local   cNumBor     := ""
    Local   l240Versao	:= SEA->(FieldPos("EA_VERSAO")) > 0
    Local   nTamEmp     := Len(SM0->M0_CODIGO)
    Local   nTamFil     := Len(FWxFilial("SE2"))
    Local   cBanco      := PadR(SuperGetMV("MK_BANCO"    , , ""), TamSX3("A6_COD")[1])
    Local   cAgencia    := PadR(SuperGetMV("MK_AGENCIA"  , , ""), TamSX3("A6_AGENCIA")[1])
    Local   cConta      := PadR(SuperGetMV("MK_CONTA"    , , ""), TamSX3("A6_NUMCON")[1])
    Local   cModPgto    := SuperGetMV("MK_MODPAG"   , , "98")
    Local   cTipPgto    := SuperGetMV("MK_TIPPAG"   , , "98")
	Local   cLogDir		:= SuperGetMV("MK_LOGDIR"   , , "\log\")
	Local   cLogArq		:= "settlements"


	ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | settlements Início"))
    FWLogMsg("INFO", , "MONKEY", "settlements", "001", "001", "Início do Processo", 0, 0, {})
    
    ::SetContentType("application/JSON;charset=UTF-8")

    If lCheckAuth
        cUser := U_MNKRetUsr(::GetHeader("Authorization"))
    Else
        ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | settlements Executando sem autenticação"))
        FWLogMsg("WARN", , "MONKEY", "settlements", "002", "400", "Início do Processo", 0, 0, {})
    EndIf

    If lCheckAuth .And. Empty(cUser)

		lReturn		:= .F.
		nHTTPCode 	:= 401
		cMessage 	:= "Usuário não autenticado"

	Else

		cBody := DecodeUTF8(AllTrim(::GetContent()))
		MemoWrite(cLogDir + cLogArq + "_request.json", cBody)

		If FWJSONDeserialize(cBody, @oObjJSON)

            ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | settlements FWJSONDeserialize"))
			
            lReturn		:= .T.

            // Verifica numero do ultimo Bordero Gerado
            DBSelectArea("SX6")
            cNumBor := GetMV("MV_NUMBORP")
            cNumBor := Soma1(cNumBor)
            SE2->(DBSelectArea("SE2"))
            While !MayIUseCode("E2_NUMBOR" + FWFilial("SX6") + cNumBor)     //verifica se esta na memoria, sendo usado
                cNumBor := Soma1(cNumBor)							    // busca o proximo numero disponivel
            EndDo

            // Grava o numero do bordero atualizado
            If GetMV("MV_NUMBORP") < cNumBor
                PutMV("MV_NUMBORP", cNumBor)
            EndIf

            ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | settlements Bordero: " + cNumBor))
            
            For nI := 1 To Len(oObjJSON:ITEMS)

                ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | settlements Registro: " + CValToChar(nI) + "/" + CValToChar(Len(oObjJSON:ITEMS))))
                ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | settlements externalId: " + oObjJSON:ITEMS[nI]:externalId))

                cEmpAnt     := SubStr(oObjJSON:ITEMS[nI]:externalId, 1, nTamEmp)
                cFilAnt     := SubStr(oObjJSON:ITEMS[nI]:externalId, nTamEmp + 1, nTamFil)
                nRegSE2     := Val(SubStr(oObjJSON:ITEMS[nI]:externalId, nTamEmp + nTamFil + 1, Len(AllTrim(oObjJSON:ITEMS[nI]:externalId)) - (nTamEmp + nTamFil)))

				SE2->(DBSelectArea("SE2"))
                // Mudamos o seek para usar o Recno
                /*
				SE2->(DBSetOrder(1))
				If SE2->(DBSeek(oObjJSON:ITEMS[nI]:externalId))
                */
                    SE2->(DBGoTo(nRegSE2))
					If oObjJSON:ITEMS[nI]:successFlag == "Y"

                        If SE2->E2_XMNKSTA == "0" // Inclusão confirmada
                            
                            SA2->(DBSelectArea("SE2"))
                            SA2->(DBSetOrder(1))
                            SA2->(DBSeek(FWxFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA))
                            
                            SEA->(DBSelectArea("SEA"))
                            SEA->(DBSetOrder(1))
                            If !SEA->(DBSeek(FWxFilial("SEA") + cNumBor + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA))
                                
                                ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | settlements Gravacao SEA"))
                                RecLock("SEA", .T.)
                                    SEA->EA_FILIAL  := FWxFilial("SEA")
                                    SEA->EA_PORTADO := cBanco
                                    SEA->EA_AGEDEP  := cAgencia
                                    SEA->EA_NUMCON  := cConta
                                    SEA->EA_NUMBOR  := cNumBor
                                    SEA->EA_DATABOR := dDataBase
                                    SEA->EA_PREFIXO := SE2->E2_PREFIXO
                                    SEA->EA_NUM     := SE2->E2_NUM
                                    SEA->EA_PARCELA := SE2->E2_PARCELA
                                    SEA->EA_TIPO    := SE2->E2_TIPO
                                    SEA->EA_FORNECE := SE2->E2_FORNECE
                                    SEA->EA_LOJA	:= SE2->E2_LOJA
                                    SEA->EA_CART    := "P"
                                    SEA->EA_MODELO  := cModPgto
                                    SEA->EA_TIPOPAG := cTipPgto
                                    SEA->EA_FILORIG := SE2->E2_FILORIG
                                    SEA->EA_ORIGEM  := PadR("FINA240", TamSX3("EA_ORIGEM")[1])
                                    If l240Versao
                                        SEA->EA_VERSAO  := "0001"
                                    EndIf
                                SEA->(MSUnLock())

                                ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | settlements Gravacao SE2"))
                                RecLock("SE2", .F.)
                                    If SE2->(FieldPos("E2_XPORTAD")) > 0
                                        SE2->E2_XPORTAD := SE2->E2_PORTADO
                                    EndIf
                                    SE2->E2_PORTADO := cBanco
                                    SE2->E2_NUMBOR  := cNumBor
                                    SE2->E2_DTBORDE := dDataBase
                                    SE2->E2_XMNKSTA := "1"
                                    If SA2->(FieldPos("A2_XRISSAC")) > 0 .And. SE2->(FieldPos("E2_XRISCOS"))
                                        SE2->E2_XRISCOS := SA2->A2_XRISSAC
                                    EndIf
                                SE2->(MSUnLock())

                                lReturn		:= .T.
                                nHTTPCode 	:= 201
                                cMessage 	:= "Título confirmado com sucesso"

                            EndIf

                        ElseIf SE2->E2_XMNKSTA == "4" // Exclusão confirmada

                            ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | settlements Gravacao SE2"))
                            RecLock("SE2", .F.)
                                SE2->E2_XMNKOBS := "Lote " + SE2->E2_XMNKLOT + " - " + Left(oObjJSON:ITEMS[nI]:errorMessage, TamSX3("E2_XMNKOBS")[1])
                                SE2->E2_XMNKSTA := "5"  // Excluído
                                SE2->E2_XMNKLOT := Space(TamSX3("E2_XMNKLOT")[1])
                            SE2->(MSUnLock())

                            lReturn		:= .T.
                            nHTTPCode 	:= 201
                            cMessage 	:= "Título excluído com sucesso"

                        Else

                            lReturn		:= .F.
                            nHTTPCode 	:= 425
                            cMessage 	:= "O status do título não permite confirmações (Status: " + SE2->E2_XMNKSTA + ")"

                        EndIf

					Else
						
                        If oObjJSON:ITEMS[nI]:errorMessage <> Nil
							
                            RecLock("SE2", .F.)
							    SE2->E2_XMNKOBS := "Lote " + SE2->E2_XMNKLOT + " - " + Left(oObjJSON:ITEMS[nI]:errorMessage, TamSX3("E2_XMNKOBS")[1])
                                SE2->E2_XMNKSTA := "3"  // Rejeitado
                                SE2->E2_XMNKLOT := Space(TamSX3("E2_XMNKLOT")[1])
							SE2->(MSUnLock())
                            
                            lReturn		:= .T.
                            nHTTPCode 	:= 201
                            cMessage 	:= "Erro registrado no log do título"

						Else

                            lReturn		:= .F.
                            nHTTPCode 	:= 500
                            cMessage 	:= "Não foi informada mensagem de erro do Portal Monkey"

                        EndIf

					EndIf
//				EndIf   // Mudamos o seek para usar o Recno
			Next nI

            cResponse := '{ '
            cResponse += '"settlements": ' + CValToChar(Len(oObjJSON:ITEMS))
            cResponse += '} '

		Else
			lReturn		:= .F.
			nHTTPCode 	:= 500
			cMessage 	:= "Erro na função FWJSONDeserialize"
            FWLogMsg("ERROR", , "MONKEY", "settlements", "012", "500", "Erro na função FWJSONDeserialize", 0, 0, {})
		EndIf

	EndIf

	ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | settlements: " + cMessage))

	If !lReturn
		SetRestFault(nHTTPCode, EncodeUTF8(cMessage))
		::SetResponse(cResponse)
	Else
		::SetResponse(cResponse)
	EndIf

	MemoWrite(cLogDir + cLogArq + "_response.json", cResponse)

    ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | settlements Fim"))
    FWLogMsg("INFO", , "MONKEY", "settlements", "999", "999", "Fim do Processo", 0, 0, {})

Return lReturn
//--< fim de arquivo >----------------------------------------------------------------------
