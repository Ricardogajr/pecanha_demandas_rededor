#Include "TOTVS.CH"

/*/{Protheus.doc} F0703401
Client resposta ao IIB (Chave de NF de Saida)
@author Paulo Krüger
@since  09/03/2017
@param	cFilOri		- Filial
@param	cCodCli		- Código do Cliente
@param	cLojCli		- Loja do Cliente
@param	cEmissao	- Data de Emissão da Nota
@param	cEspecie	- Espécie da Nota
@param	cSerie		- Série da Nota
@param	cNFiscal	- Número da Nota Fiscal
@param	cChvSEFAZ	- Chave de autorização da SEFAZ/Prefeitura
@param	cStatus		- Status da Nota: E= Enviada, C= Cancelada
@param	nRecnoP22	- Num do registro da tabela de controle P22
@param	cSTATRS		- Status do retorno da SEFAZ/Prefeitura
@param	lCancela	- Identifica cancelamento da Nota Fiscal
@param	cNumPed		- Numero do Pedido de Venda
@param	cOcorr		- Descritivo da ocorrência
@return Nil
@project MAN0000007423041_EF_034
@cliente Rededor
@version P12.1.7
/*/
User Function F0703401(	cRecnoP22, cSTATRS  , cNumPed  , cOcorr  , cFilOri , cXTipo ,;
                        cStatus  , cNFiscal , cSerie   , cCodCli , cLojCli,;
						cCancela,  cEmissao , cEspecie , cTotal   , cISS    , cPIS   ,;
						cCofins ,  cCSLL    , cIRRF    , cValFat  ,cMsgNota , cChvSEFAZ,;
						cNunPedFro, cCodVerNF)
	Local cChave    := ""
	Local cInput  	:= ""
	Local cMetodo	:= ""
	Local cMsg		:= ""
	Local cCancVal  := ""
	Local cChave    := ""
	Local cRetorno  := ""
	Local cURL		:= SuperGetMV("FS_URLRTSF", , "http://spon010108386:8088/mockManterDocumentoSaidaProtheusSASOAP?WSDL")
	Local lCancela 	:= cCancela == "T"
	Local nRecnoP22 := Val(cRecnoP22)
	Local oWSDL		:= Nil
	Local aFunPar   := {}
	Local nPar      := 0

	DEFAULT cFilOri    := ""
	DEFAULT cXTipo     := ""
	DEFAULT cStatus    := "E"
	DEFAULT cNFiscal   := ""
	DEFAULT cSerie     := ""
	DEFAULT cCodCli    := ""
	DEFAULT cLojCli    := ""
	DEFAULT cCancela   := ""
	DEFAULT cEmissao   := ""
	DEFAULT cEspecie   := ""
	DEFAULT cTotal     := "0"
	DEFAULT cISS       := "0"
	DEFAULT cPIS       := "0"
	DEFAULT cCofins    := "0"
	DEFAULT cCSLL      := "0"
	DEFAULT cIRRF      := "0"
	DEFAULT cValFat    := "0"
	DEFAULT cMsgNota   := ""
	DEFAULT cChvSEFAZ  := ""
	DEFAULT cNunPedFro := ""
	DEFAULT cCodVerNF  := ""

	aFunPar := {	cRecnoP22, cSTATRS   , cNumPed   , cOcorr   , cFilOri  , cXTipo  ,;
					cStatus   , cNFiscal  , cSerie   , cCodCli  , cLojCli  ,;
					cCancela ,  cEmissao , cEspecie  , cTotal   , cISS     , cPIS     ,;
					cCofins  ,  cCSLL    , cIRRF     , cValFat  , cMsgNota , cChvSEFAZ,;
					cNunPedFro, cCodVerNF }
	
	cInput := "U_F0703401("

	For nPar := 1 to Len(aFunPar) - 1
		 cInput +=  aFunPar[nPar] + ","
	Next
	
	cInput += aFunPar[nPar] + ")"

	oWSDL	:= TWSDLManager():New()

	cRetorno := "1" // ERRO

	Begin Sequence
		If !oWSDL:ParseURL(cURL)
			cMsg := "Arquivo WSDL informado invalido" + CRLF + oWsdl:cError
			LogTimedMsg(cMsg)
			cSTATRS := "2"
			Break
		EndIf

		LogTimedMsg("Procurando método RetornarStatus.")
		cMetodo := "RetornarStatus"
		If !oWSDL:SetOperation(cMetodo)
			cMsg := cMetodo + ": Não foi possível estabelecer a chamada do método!"
			LogTimedMsg(cMsg)
			cSTATRS := "2"
			Break
		EndIf
			
		If lCancela
			cCancVal := StrZero(Day(dDataBase),2) + "/" + StrZero(Month(dDataBase),2) + "/" + StrZero(Year(dDataBase),4)
		EndIf		

		aValues := {;
						{"Empresa"   , "Codigo"             , cFilOri  },;
						{"Pedido"    , "Tipo"               , cXTipo   },;
						{"NotaFiscal", "StatusRetorno"      , cStatus  },;
						{"NotaFiscal", "Numero"             , cNFiscal },;
						{"NotaFiscal", "Serie"              , cSerie   },;
						{"NotaFiscal", "CodigoCliente"      , cCodCli  },;
						{"NotaFiscal", "LojaCliente"        , cLojCli  },;
						{"NotaFiscal", Iif(lCancela,"DataCancelamento","naoenviar"), cCancVal },;
						{"NotaFiscal", "DataEmissao"        , cEmissao },;
						{"NotaFiscal", "EspecieDocumento"   , cEspecie },;
						{"NotaFiscal", "ValorTotal"         , cTotal   },;
						{"NotaFiscal", "ValorISS"           , cISS     },;
						{"NotaFiscal", "ValorPIS"           , cPIS     },;
						{"NotaFiscal", "ValorCofins"        , cCofins  },;
						{"NotaFiscal", "ValorCSLL"          , cCSLL    },;
						{"NotaFiscal", "ValorIRRF"          , cIRRF    },;
						{"NotaFiscal", "ValorFatura"        , cValFat  },;
						{"NotaFiscal", "ChaveSEFAZ"         , cChvSEFAZ},;
						{"NotaFiscal", "MensagemNotaFiscal" , cMsgNota },;
						{"NotaFiscal", "NumeroPedidoFront"  , cNunPedFro },;
						{"NotaFiscal", "CodigoVerificacaoNF", cCodVerNF };
					}

		oWSDL:lUseNSPrefix := .T.

		cMsg := SetWSValues(oWSDL, aValues)

		If !Empty(cMsg)
			Break
		EndIf
		
		cMsg := oWSDL:GetSoapMsg()

		If !oWSDL:SendSoapMsg(cMsg)
			cMsg := cMetodo + ": erro ao enviar requisição ao servidor!"
			LogTimedMsg(cMsg)
			cSTATRS := "2"
			Break
		EndIf

		cRetorno := "2" //OK
	End Sequence

	GravaP22(nRecnoP22, cSTATRS, cOcorr)

	cChave := xFilial("SF2") + "|" + cNFiscal + "|" + cSerie + "|" + cCodCli + "|" + cLojCli
	U_F07Log03("U_F0703401", cInput, cMsg, cRetorno, "SF2", 1, cChave)

	FreeObj(oWSDL)
Return

Static Function LogTimedMsg(cMsg)
	ConOut("[" + FwTimeStamp(2) + "] - F0703401 - " + OEMToANSI(cMsg))
Return

Static Function SetWsValues(oWSDL, aValues)
	Local aSimples := {}
	Local bBusca   := {||}
	Local cRet     := ""
	Local nValue   := 0
	Local nSimple  := 0

	aSimples := oWsdl:SimpleInput()

	For nValue := 1 to Len(aValues)
		bBusca  := {|aSimple| (aSimple[2] == aValues[nValue][2]) .and. (aValues[nValue][1] $ aSimple[5]) }
		If (nSimple := AScan( aSimples, bBusca )) == 0
			Loop
		Endif

		If Empty(aValues[nValue][3])
			If !oWsdl:SetValue( aSimples[nSimple][1], EncodeUTF8(" ")  )
				cRet := oWsdl:cCurrentOperation + ": erro ao interpretar estrutura complexa: <" + aValues[nValue][2] + "> [" + EncodeUTF8(aValues[nValue][3]) + "] = " + oWSDL:cError
				LogTimedMsg(cRet)
				Exit
			Endif
		Else
			If !oWsdl:SetValue( aSimples[nSimple][1], EncodeUTF8(aValues[nValue][3])  )
				cRet := oWsdl:cCurrentOperation + ": erro ao interpretar estrutura complexa: <" + aValues[nValue][2] + "> [" + EncodeUTF8(aValues[nValue][3]) + "] = " + oWSDL:cError
				LogTimedMsg(cRet)
				Exit
			Endif
		EndIf
	Next
Return cRet

Static Function GravaP22(nRecnoP22, cStatRS, cObserv)
	If nRecnoP22 > 0
		P22->(DbGoTo(nRecnoP22))
		Reclock("P22", .F.)
		P22->P22_DTRTSF	:= DATE()
		P22->P22_HRRTSF := TIME()
		P22->P22_STATRS	:= cSTATRS
		If Len(P22->P22_OBSERV+"") > 30000
			P22->P22_OBSERV	:= cObserv + CRLF
		Else
			P22->P22_OBSERV	:= P22->P22_OBSERV + CRLF + cObserv + CRLF
		EndIf
		P22->(MsUnLock())
	EndIf
Return
