#include "totvs.ch"

Static aPedido := {}
Static cPedido := ""

/*{Protheus.doc} F0702203
Função responsável por acionar a integração do Pedido de Compras ERP
@owner robson.william
@author Alex Sandro
@since 02/03/2017
@version 12.7
@param cPedComp, caracter, descricao
@param nOper, numerico, descricao
@param nOpca, numerico, descricao
@return lRet
@project	MAN0000007423041_EF_022
*/
User Function F0702203( cPedComp, nOper, nOpca, nRecSC7)
	Local aSC7Area   := SC7->(FWGetArea())
	Local cItPdCom   := ""
	Local cResTotPar := ""

	Default nOpca  := 1
	Default nRecSC7 := 0

	SC7->(DbSetOrder(1))
	If !SC7->(MsSeek(xFilial("SC7") + AllTrim(cPedComp)))
		Return
	EndIf

	//If nOpca != 1
	// Return
	//EndIf

	If IsInCallStack("U_F0702601") .Or. U_VALSIMP(xFilial("SC7"))//Filial Simplificada.
		Return
	EndIf

	If nRecSC7 <> 0
		SC7->(DbGoTo(nRecSC7))
		cPedComp := SC7->C7_NUM
		cItPdCom := SC7->C7_ITEM
	EndIf

	// ID 1214. Incluido para desconsiderar pedidos mão encontrados na base
	If EMPTY(cPedComp)
		Return
	Endif

	If !VldProEstocavel(cPedComp)
		Return
	Endif

	IF SC7->C7_XSOLPAG = "1"
		Return
	EndIf

	// Inclusão de pedido ou copia
	//SE OPERAÇÃO FOR INCLUSÃO E O PONTO DE ENTRADA FOR MT120FIM E NAO VIER DA ALTERAÇÃO DE FORNECEDOR E NÃO TENHA A ROTINA DE DEVOLUÇÃO DE NOTA FISCAL DE ENTRADA
	If (nOper == 3 .And. (IsInCallStack('U_GCTINTEGR') .Or. IsInCallStack('U_MT120FIM') .Or. IsInCallStack("A120Copia") .Or. FwIsInCallStack("U_F1303701"))) .And.;
			!(FwIsInCallStack("U_F1304901")) .And. IIf(FwIsInCallStack("U_F1303701"), FwIsInCallStack("U_F1303708"), .T.)

		If IsPCLib(AllTrim(cPedComp))                                                   // Se bloqueado, envia bloqueio.
			ManterPedidoERP(AllTrim(cPedComp), "I")
		EndIf

		//SE FOR ALTERAÇÃO OU VIER DA ALTERAÇÃO DE FORNECEDOR E O PONTO DE ENTRADA FOR MT120FIM
	ElseIf (nOper == 4 .Or. FwIsInCallStack("U_F1304901")) .And. IsInCallStack('U_MT120FIM') // Alteração de pedido de compra, sempre com status de bloqueado

		If IsPCLib(AllTrim(cPedComp))                                                           // Se bloqueado, envia bloqueio.
			ManterPedidoERP(AllTrim(cPedComp), "A")
		Else
			If ! Empty(SC7->C7_XDTINT)
				ManterPedidoERP(AllTrim(cPedComp), "B")
			EndIf
		EndIf

		//SE OPERAÇÃO FOR EXCLUSÃO E NAO VIER DA ALTERAÇÃO DE FORNECEDOR E
	ElseIf (nOper == 5 .And. !(FwIsInCallStack("U_F1304901")) .And. IIf(FwIsInCallStack("U_F1303702"), FwIsInCallStack("U_F1303708"), FwIsInCallStack('U_MTA120E')))

		ManterPedidoERP(AllTrim(cPedComp), "E")
		INCLUI := .F.
		ALTERA := .F.

	ElseIf nOper == 8 .and. (IsInCallStack('U_REDA003') .OR.  ( IsInCallStack('U_MT235AIR') .and. IsLastItem(AllTrim(cPedComp), cItPdCom)))    // Elimina Residuo
		ManterPedidoERP(AllTrim(cPedComp), "R")
	ElseIf nOper == 9 .and. IsInCallStack('U_MT094END') .and. IsPCLib(AllTrim(cPedComp))                // Desbloqueio
		If Empty(SC7->C7_XDTINT)
			ManterPedidoERP(AllTrim(cPedComp), "I")
		Else
			ManterPedidoERP(AllTrim(cPedComp), "D")
		EndIf
	EndIf
	FWRestArea(aSC7Area)
Return

Static Function IsPCLib(cPedComp)
	Local lRet := .T.
	Local aSC7Area := SC7->(FWGetArea())

	SC7->(DbSetOrder(1))
	SC7->(MsSeek(xFilial("SC7") + AllTrim(cPedComp)))
	While SC7->(!Eof() .and. C7_FILIAL + C7_NUM== xFilial("SC7") + AllTrim(cPedComp))
		If SC7->C7_CONAPRO <> 'L'
			lRet := .F.
			Exit
		Endif
		SC7->(DbSkip())
	End
	FWRestArea(aSC7Area)

Return lRet

Static Function IsLastItem(cPedComp, cItPdCom)
	Local lRet := .F.
	Local aSC7Area
	Local nPos
	Local nX

	If AllTrim(cPedido) <> AllTrim(cPedComp)
		aPedido := {}
		cPedido := AllTrim(cPedComp)
		aSC7Area := SC7->(FWGetArea())
		SC7->(DbSetOrder(1))
		SC7->(MsSeek(xFilial("SC7") + AllTrim(cPedComp)))
		While SC7->(!Eof() .and. C7_FILIAL + C7_NUM == xFilial("SC7") + AllTrim(cPedComp))
			If SC7->C7_ITEM >= MV_PAR14 .And. SC7->C7_ITEM <= MV_PAR15 .And. SC7->C7_PRODUTO >= MV_PAR06 .And. SC7->C7_PRODUTO <= MV_PAR07
				AAdd(aPedido, {SC7->C7_ITEM, SC7->C7_RESIDUO == "S"})
			EndIf
			SC7->(DbSkip())
		End
		FWRestArea(aSC7Area)
	EndIf

	nPos := Ascan(aPedido,{|x| x[1] == cItPdCom})
	If Empty(nPos)
		Return .f.
	EndIf
	aPedido[nPos,2] := .T.

	For nX := 1 to len(aPedido)
		If ! aPedido[nX,2]
			Return .F.
		EndIf
	Next

	aPedido := ""
	aPedido := {}

Return .T.

Static Function ManterPedidoERP(cPedComp, cTipoOper)

	Local cInput      := 'U_F07022RE(' + cPedComp + ',' + cTipoOper + ')'
	Local cRet        := ""
	Local cStatus     := ""  //"1-ERRO,2-OK
	Local oWSDL       := Nil
	Local nPos        := 0
	Local nI, nJ      := 0
	Local aSC7Area    := SC7->(FWGetArea("SC7"))
	Local aItensPC    := {}
	Local aComplex    := {}
	Local aSimple     := {}
	Local aNodeCampo  := {}
	Local cInfoPac    := ""
	Local nValorBruto := 0
	Local cMetodo     := "ManterPedidoERP"
	Local cURL        := GetMV("FS_WSPCERP",,"http://localhost:8088/mockManterPedidoProtheusSASOAP?WSDL")
	Local cNodeIt	  := "ManterPedidoERPRequest#1.ItensPedido#1.ItemPedido#" //Necessario incluir o indice do array dos itens
	Local nTotVlBrut  := 0
	Local nTotVlDesp  := 0
	Local nTotVlFret  := 0
	Local nTotVlSegu  := 0
	Local cEnvelope   := ""
	Local cEndEntreg  := ""
	Local aAreaSM0    := {}
	Local cUpd := ""
	Local cFilEnt     := ""
	Local cStPedRes   := Iif(cTipoOper == "R","|T","")
	Local lContinua   := .F.
	Local cQuery      := ""
	Local cAlias1     := "SC7"
	Local cFilPc 	  := ""
	Local cNumPc	  := ""
	Local cErrPc      := ""

	aNodeCampo := { "ItemPedidoCompra"  , ;
		"ValorISS"			, ;
		"AliquotaISS"		, ;
		"AliquotaIPI"		, ;
		"CodigoProduto"     , ;
		"PrecoUnitarioItem" , ;
		"QuantidadePedida"  , ;
		"UnidadeMedida"     , ;
		"ValorDescontoItem" , ;
		"ValorICMSItem"     , ;
		"ValorIPIItem"      , ;
		"ValorTotalItem"    , ;
		"Armazem"           , ;
		"InformacaoPaciente", ;
		"SetorHospitalar"   , ;
		"Observacoes"       , ;
		"PCResiduoEliminado", ;
		"FatordeCompras"    , ;
		"FatordeConversao"  , ;
		"CentrodeCusto"     , ;
		"DatadeEntrega"     , ;
		"CodigoFabricante"     }

	Begin Sequence

		SC7->(DbSetOrder(1)) //C7_FILIAL + C7_NUM + C7_ITEM + C7_SEQUEN
		If SC7->(MsSeek(xFilial("SC7") + ALLTRIM(cPedComp)))
			aArea := SC7->(FWGetArea())
			If cTipoOper == "R"
				While !SC7->(Eof()) .And. SC7->C7_NUM == ALLTRIM(cPedComp)
					if SC7->C7_QUANT <> SC7->C7_QUJE //Quantidade do item diferente da quantidade entregue quando for eliminacao de residuos
						lContinua := .T.
						cAlias1 := "SC7"
						dDtEm  := SC7->C7_EMISSAO
						dDtPrf := SC7->C7_DATPRF
						Exit
					endif

					SC7->(DbSkip())
				EndDo

				FWRestArea(aArea)
			Else
				If SC7->C7_QUANT <> SC7->C7_QUJE
					lContinua := .T.
					cAlias1 := "SC7"
					dDtEm  := SC7->C7_EMISSAO
					dDtPrf := SC7->C7_DATPRF
				Else
					lContinua := .F.
					cRet := "Pedido de Compra encerrado"
					Break
				EndIf
			endif
		Else

			If cTipoOper == "E"  //Exclusão

				cAlias1 := GetNextAlias()

				cQuery := "SELECT C7_FILIAL, C7_NUM, C7_XNUM, C7_XDESFIN, C7_COND, C7_FORNECE, "
				cQuery += "C7_CONTATO, C7_EMISSAO, C7_LOJA, C7_TPFRETE, C7_FILENT, C7_ITEM, "
				cQuery += "C7_VALISS, C7_ALIQISS, C7_IPI, C7_PRODUTO, C7_XPRECO, C7_XQTDPC, "
				cQuery += "C7_XUMCONV, C7_VLDESC, C7_VALICM, C7_VALIPI, C7_TOTAL, C7_LOCAL, "
				cQuery += "C7_XINFPAC, C7_XCODSET, C7_OBS, C7_RESIDUO, C7_QUANT, C7_QUJE, "
				cQuery += "C7_XTPFATO, C7_XFATOR, C7_CC, C7_DATPRF, C7_DESPESA, C7_VALFRE, C7_SEGURO, C7_XCODFAB, C7_XERRPC "
				cQuery += "FROM " + RetSqlName("SC7") + " "
				cQuery += "WHERE C7_FILIAL = '" + xFilial("SC7") + "' AND "
				cQuery += "C7_NUM = '" + ALLTRIM(cPedComp) + "' AND "
				cQuery += "D_E_L_E_T_ = '*' "
				If FwIsInCallStack("U_F1303708")
					cQuery += "ORDER BY R_E_C_N_O_ DESC"
				EndIf

				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAlias1, .T., .T.)

				If !(cAlias1)->(EOF())
					lContinua := .T.
					dDtEm  := STOD((cAlias1)->C7_EMISSAO)
					dDtPrf := STOD((cAlias1)->C7_DATPRF)
					cFilPc := (cAlias1)->C7_FILIAL
					cNumPc := (cAlias1)->C7_NUM
					cErrPc := (cAlias1)->C7_XERRPC
				Else
					lContinua := .F.
					(cAlias1)->(DbCloseArea())
					Break
				EndIf

			Else
				lContinua := .F.
				cRet := "Não encontrado Pedido de Compra"
				Break
			EndIf

		EndIf

		If lContinua
			oWSDL	:= TWSDLManager():New()
			
			oWSDL:bNoCheckPeerCert := .T.
			If !oWSDL:ParseURL(cURL)
				cRet := "[" + FwTimeStamp(2) + "] - Arquivo WSDL informado invalido"
				cRet += CRLF + oWsdl:cError
				Break
			EndIf

			//Selecionando Metodo
			If !oWSDL:SetOperation(cMetodo)
				cRet := "[" + FwTimeStamp(2) + "] - " + cMetodo + ": Não foi possível estabelecer a chamada do método!"
				Break
			EndIf

			oWSDL:lUseNSPrefix := .T.

			If !(cAlias1)->(oWSDL:SetValue(00, EncodeUTF8(C7_FILIAL))) //Filial
				cRet := "[" + FwTimeStamp(2) + "] - Nao foi possível passar a TAG [00]" + oWSDL:cError
				Break
			EndIf
			If !(cAlias1)->(oWSDL:SetValue(01, EncodeUTF8(C7_NUM))) //NumeroPedidoCompra
				cRet := "[" + FwTimeStamp(2) + "] - Nao foi possível passar a TAG [01]" + oWSDL:cError
				Break
			EndIf
			If !(cAlias1)->(oWSDL:SetValue(03, EncodeUTF8(C7_XNUM))) //NumeroPedidoExterno
				cRet := "[" + FwTimeStamp(2) + "] - Nao foi possível passar a TAG [03]" + oWSDL:cError
				Break
			EndIf
			If !(cAlias1)->(oWSDL:SetValue(04, EncodeUTF8(Alltrim(Str(C7_XDESFIN))))) //Desconto financeiro
				cRet := "[" + FwTimeStamp(2) + "] - Nao foi possível passar a TAG [04]" + oWSDL:cError
				Break
			EndIf
			If !(cAlias1)->(oWSDL:SetValue(06, EncodeUTF8(C7_COND))) //CodigoCondicaoPagamento
				cRet := "[" + FwTimeStamp(2) + "] - Nao foi possível passar a TAG [06]" + oWSDL:cError
				Break
			EndIf
			If !(cAlias1)->(oWSDL:SetValue(07, EncodeUTF8(C7_FORNECE))) //CodigoFornecedor
				cRet := "[" + FwTimeStamp(2) + "] - Nao foi possível passar a TAG [07]" + oWSDL:cError
				Break
			EndIf

//            If !(cAlias1)->(oWSDL:SetValue(08, EncodeUTF8(C7_CONTATO))) //NomeContatoFornecedor
			If !(cAlias1)->(oWSDL:SetValue(08, EncodeUTF8(_NoTags(C7_CONTATO)))) //NomeContatoFornecedor

				cRet := "[" + FwTimeStamp(2) + "] - Nao foi possível passar a TAG [08]" + oWSDL:cError
				Break
			EndIf

			If !(cAlias1)->(oWSDL:SetValue(09, EncodeUTF8(StrZero(Day(dDtEm),2) + "/" + StrZero(Month(dDtEm),2) + "/" + StrZero(Year(dDtEm),4)))) //DataEmissao
				cRet := "[" + FwTimeStamp(2) + "] - Nao foi possível passar a TAG [09]" + oWSDL:cError
				Break
			EndIf
			If !(cAlias1)->(oWSDL:SetValue(10, EncodeUTF8(C7_LOJA))) //LojaFornecedor
				cRet := "[" + FwTimeStamp(2) + "] - Nao foi possível passar a TAG [10]" + oWSDL:cError
				Break
			EndIf
			If !(cAlias1)->(oWSDL:SetValue(11, EncodeUTF8(C7_TPFRETE))) //TipoFreteUtilizado
				cRet := "[" + FwTimeStamp(2) + "] - Nao foi possível passar a TAG [11]" + oWSDL:cError
				Break
			EndIf

			aAreaSM0 := SM0->(FWGetArea())
			cFilEnt  := Iif(Empty((cAlias1)->C7_FILENT),(cAlias1)->C7_FILIAL,(cAlias1)->C7_FILENT)

			cEndEntreg := Alltrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilEnt,{"M0_ENDCOB"})[1][2]) //AllTrim(Posicione('SM0',01,cEmpAnt + cFilEnt,'M0_ENDCOB')) + ' - '
			cEndEntreg += AllTrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilEnt,{"M0_COMPCOB"})[1][2]) + ' - '
			cEndEntreg += AllTrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilEnt,{"M0_BAIRCOB"})[1][2]) + ' - '
			cEndEntreg += AllTrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilEnt,{"M0_CIDCOB"})[1][2]) + ' - '
			cEndEntreg += AllTrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilEnt,{"M0_ESTCOB"})[1][2]) + ' - '
			cEndEntreg += AllTrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilEnt,{"M0_CEPCOB"})[1][2])

			cEndEntreg := EncodeUTF8(_NoTags(cEndEntreg))

			SM0->(FWRestArea(aAreaSM0))

			If !oWSDL:SetValue(15, EncodeUTF8(cEndEntreg)) //Endereço de Entrega
				cRet := "["+FwTimeStamp(2)+"] - Não foi possível passar a TAG [15]" + oWSDL:cError
				Break
			Endif

			While (cAlias1)->(!Eof() .and. (cAlias1)->C7_FILIAL + (cAlias1)->C7_NUM == xFilial("SC7") + ALLTRIM(cPedComp))

				P17->(MsSeek(XFilial("P17")+(cAlias1)->C7_PRODUTO+(cAlias1)->C7_FILIAL)) //P17_FILIAL+P17_COD+P17_FTRATA

				AAdd( aItensPC, {	(cAlias1)->C7_ITEM               		, ;
					Alltrim(Str((cAlias1)->C7_VALISS))		, ;
					Alltrim(Str((cAlias1)->C7_ALIQISS))	 	, ;
					Alltrim(Str((cAlias1)->C7_IPI))		  	, ;
					(cAlias1)->C7_PRODUTO             		, ;
					Alltrim(Str((cAlias1)->C7_XPRECO))   	, ;
					Alltrim(Str((cAlias1)->C7_XQTDPC))     	, ;
					(cAlias1)->C7_XUMCONV                 	, ;
					Alltrim(Str((cAlias1)->C7_VLDESC))		, ;
					Alltrim(Str((cAlias1)->C7_VALICM))  	, ;
					Alltrim(Str((cAlias1)->C7_VALIPI))  	, ;
					Alltrim(Str((cAlias1)->C7_TOTAL))    	, ;
					(cAlias1)->C7_LOCAL                   	, ;
					(cAlias1)->C7_XINFPAC                	, ;
					(cAlias1)->C7_XCODSET                	, ;
					(cAlias1)->C7_OBS   , ; // EncodeUTF8(_NoTags(C7_OBS))   , ;
					(cAlias1)->C7_RESIDUO+"|"+IIf((cAlias1)->C7_QUANT == (cAlias1)->C7_QUJE, "A","P") , ;
					(cAlias1)->C7_XTPFATO                  	, ;
					AllTrim(Str(P17->P17_CONV1))  , ;
					(cAlias1)->C7_CC                     	, ;
					StrZero(Day(dDtPrf),2) + "/" + StrZero(Month(dDtPrf),2) + "/" + StrZero(Year(dDtPrf),4),;
					(cAlias1)->C7_XCODFAB })

				nTotVlBrut += (cAlias1)->C7_TOTAL
				nTotVlDesp += (cAlias1)->C7_DESPESA
				nTotVlFret += (cAlias1)->C7_VALFRE
				nTotVlSegu += (cAlias1)->C7_SEGURO

				If cTipoOper == "R" .And. ((cAlias1)->C7_QUANT != (cAlias1)->C7_QUJE) .And. (cAlias1)->C7_RESIDUO != "S"
					cStPedRes := "|P"
				EndIf

				(cAlias1)->(DbSkip())
			EndDo

			If !oWSDL:SetValue(02, EncodeUTF8(cTipoOper + cStPedRes )) //Tipo de operadao: I=Inclusão; A=Alteração; E=Exclusão; R=Elimina residuo (|P parcial |T total); B=Bloqueio; D=Desbloqueio
				cRet := "[" + FwTimeStamp(2) + "] - Nao foi possível passar a TAG [02]" + oWSDL:cError
				Break
			EndIf
			If !oWSDL:SetValue(05, EncodeUTF8(AllTrim(Str(nTotVlBrut)))) //ValorBruto
				cRet := "["+FwTimeStamp(2)+"] - Não foi possível passar a TAG [05]" + oWSDL:cError
				Break
			Endif
			If !oWSDL:SetValue(12, EncodeUTF8(AllTrim(Str(nTotVlDesp)))) //ValorDespesas
				cRet := "["+FwTimeStamp(2)+"] - Não foi possível passar a TAG [12]" + oWSDL:cError
				Break
			Endif
			If !oWSDL:SetValue(13, EncodeUTF8(AllTrim(Str(nTotVlFret)))) //ValorFrete
				cRet := "["+FwTimeStamp(2)+"] - Não foi possível passar a TAG [13]" + oWSDL:cError
				Break
			Endif
			If !oWSDL:SetValue(14, EncodeUTF8(AllTrim(Str(nTotVlSegu)))) //ValorSeguro
				cRet := "["+FwTimeStamp(2)+"] - Não foi possível passar a TAG [14]" + oWSDL:cError
				Break
			Endif

			aComplex := oWsdl:NextComplex()

			While ValType( aComplex ) == "A"
				If !oWsdl:SetComplexOccurs( aComplex[1], len(aItensPC) )
					cRet := "[" + FwTimeStamp(2) + "] - " + cMetodo + ": erro ao interpretar estrutura complexa: " + oWSDL:cError
					Break
				Endif
				aComplex := oWsdl:NextComplex()
			End

			aSimple := oWsdl:SimpleInput()

			For nI:=1 to len(aItensPC)
				For nJ:=1 to len(aNodeCampo)
					If (nPos := AScan( aSimple, {|aVet| aVet[2] == aNodeCampo[nJ] .AND. aVet[5] == cNodeIt + Alltrim(Str(nI)) } )) > 0
						If Empty(aSimple[nPos][3]) .and. Empty(aItensPC[nI,nJ])
							Loop
						EndIf
//                      If !oWsdl:SetValue( aSimple[nPos][1], EncodeUTF8(aItensPC[nI,nJ]) )
//                      ID 1280
//                      Implementado tratamento _NoTags

						If !oWsdl:SetValue( aSimple[nPos][1], EncodeUTF8(_NoTags(FwCutOff(OEMToAnsi( aItensPc[nI,nJ]),.T.))) )
							cRet := "[" + FwTimeStamp(2) + "] - " + cMetodo + ": erro ao interpretar estrutura complexa: " + oWSDL:cError
							Break
						Endif

					Else
						Exit
					Endif
				Next
			Next

			cEnvelope := oWSDL:GetSoapMsg()

			If !oWSDL:SendSoapMsg()
				cRet := "[" + FwTimeStamp(2) + "] - " + cMetodo + ": erro ao enviar requisição ao servidor: " + oWSDL:cError
				cRet +=  CRLF + "Envelope:" + CRLF + cEnvelope
				Break
			EndIf

			cRet := oWSDL:GetSoapResponse()
			FreeObj(oWSDL)

		EndIf
		cStatus := "2" //OK
		AtuDtTrans(cPedComp)
		Recover
		cStatus := "1" // ERRO
	End Sequence
	U_F07Log03('U_F0702203',cInput,cRet,cStatus,"SC7",1,xFilial("SC7") + '|' + AllTrim(cPedComp))
	SC7->(MsSeek(xFilial("SC7") + ALLTRIM(cPedComp)))
	If (cStatus == "1" .And. AllTrim(cRet) <> "Pedido de Compra encerrado")
		//If cTipoOper == "E"
			cUpd := "UPDATE " + RETSQLNAME("SC7") + " SET C7_XERRPC = '"+cPedComp+ cTipoOper+"'"
			cUpd += " WHERE C7_FILIAL = '"+XFILIAL("SC7")+"'"
			cUpd += " AND C7_NUM = '"+cPedComp+"'"
			TcSqlExec(cUpd)
		/*/Else
			While !SC7->(EOF()) .And. SC7->C7_NUM == cPedComp
				RecLock("SC7",.F.)
				SC7->C7_XERRPC := SC7->C7_NUM + cTipoOper
				SC7->(MsUnlock())
				SC7->(DBSKIP())
			ENDDO
		EndIf/*/
	Else
		//If cTipoOper == "E"
			cUpd := "UPDATE " + RETSQLNAME("SC7") + " SET C7_XERRPC = ' '"
			cUpd += " WHERE C7_FILIAL = '"+XFILIAL("SC7")+"'"
			cUpd += " AND C7_NUM = '"+cPedComp+"'"
			TcSqlExec(cUpd)
		/*/Else
			If AllTrim(SC7->C7_XERRPC) <> ""
				While !SC7->(EOF()) .And. SC7->C7_NUM == cPedComp
					RecLock("SC7",.F.)
					SC7->C7_XERRPC := " "
					SC7->(MsUnlock())
					SC7->(DBSKIP())
				ENDDO
			EndIf
		EndIf/*/
	EndIf

	FWRestArea(aSC7Area)

Return cRet

/*{Protheus.doc} F0702203
Função responsável pelo reprocessamento da integração do Pedido de Compras ERP
@owner		Carlos Gomes
@since		09/08/2017
@param		cPedComp, Numero do Pedido de Compras
@param		cTipoOper, Operação a ser executada
@project	MAN0000007423041_EF_022
*/
User Function F07022RE(cPedComp, cTipoOper)
	ManterPedidoERP(cPedComp, cTipoOper)
Return

Static Function AtuDtTrans(cPedComp)
	Local aSC7Area    := SC7->(FWGetArea("SC7"))

	SC7->(DbSetOrder(1))
	SC7->(MsSeek(xFilial("SC7") + ALLTRIM(cPedComp)))
	While SC7->(!Eof() .and. C7_FILIAL + C7_NUM == xFilial("SC7") + ALLTRIM(cPedComp))
		SC7->(RecLock("SC7",.F.))
		SC7->C7_XDTINT := dDataBase
		SC7->(MsUnlock())
		SC7->(DbSkip())
	EndDo

	FWRestArea(aSC7Area)
Return

/*{Protheus.doc} VldProEstocavel
Valida se o primeiro produto do pedido é estocável ou não.
*/
Static Function VldProEstocavel(cPedComp)

	Local lEstocavel := .F.
	Local aAreas     := { SC7->(FWGetArea()), P17->(FWGetArea()), FWGetArea() }

	SC7->(DbSetOrder(1))
	If SC7->(MsSeek(xFilial("SC7") + ALLTRIM(cPedComp)))
		P17->(DbSetOrder(1))
		If P17->(MsSeek(XFilial("P17")+SC7->C7_PRODUTO+cFilAnt))
			lEstocavel := ( P17->P17_ESTOQ == "S" )
		EndIf
	EndIf

	AEval(aAreas,{|aArea| FWRestArea(aArea) })

Return lEstocavel
