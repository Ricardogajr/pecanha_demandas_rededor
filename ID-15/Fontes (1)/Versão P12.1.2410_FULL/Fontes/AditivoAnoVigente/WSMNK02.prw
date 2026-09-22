// #########################################################################################
// Projeto: Monkey
// Modulo : Integração API
// Fonte  : WSMNK02
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 13/09/20 | Rafael Yera Barchi| Rotina para enviar os títulos
// ---------+-------------------+-----------------------------------------------------------

#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#Include "Totvs.ch"
#INCLUDE 	"PARMTYPE.CH"

#DEFINE 	cFunction		"WSMNK02"
#DEFINE 	cPerg			PadR(cFunction, 10)
#DEFINE 	cTitleRot	 	"Payables"
#DEFINE 	cEOL			Chr(13) + Chr(10)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} WSMNK02
//Rotina para obter enviar os títulos
@author Rafael Yera Barchi
@since 13/09/2020
@version 1.00
@type function

/*/
//------------------------------------------------------------------------------------------
User Function WSMNK02()

	//--< Variáveis >-----------------------------------------------------------------------
	Local	lSchedule	:= .F.
	Local	cObs		:= ""
	Local	oProcess	:= Nil

    Private cLogDir		:= SuperGetMV("MK_LOGDIR", , "\log\")
    Private cLogArq		:= cFunction


	//--< Procedimentos >-------------------------------------------------------------------
	ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | " + cFunction + ": " + cTitleRot + " ------> Início... "))

	lSchedule 	:= FWGetRunSchedule()

//	ValidPerg()
    
    If !lSchedule
		cObs := "Essa rotina tem a finalidade de enviar os títulos para a Monkey. "
		oProcess := TNewProcess():New(cFunction, cTitleRot, {|oSelf, lSchedule| MNK02Pr2(oSelf, lSchedule)}, cObs, cPerg)
		Aviso(cTitleRot, "Fim do processamento! ", {"OK"})
	Else
		MNK02Pro(Nil, lSchedule)
	EndIf

	ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | " + cFunction + ": " + cTitleRot + " ------> Fim! "))

	If ValType(oProcess) == "O"
		FreeObj(oProcess)
	EndIf

Return Nil



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MNK02Pro
Rotina auxiliar de processamento

@author    Rafael Yera Barchi
@version   1.xx
@since     13/09/2020
/*/
//------------------------------------------------------------------------------------------
Static Function MNK02Pro(oSelf, lSchedule)

	//--< Variáveis >-----------------------------------------------------------------------
	Local 	nCont       := 0
	Local 	nRegua		:= 0
    Local   nPos        := 0
    Local   nTimeOut    := 120
    Local   cSQL        := ""
    Local   cRetPost    := ""
    Local   cURL_MNK    := ""
    Local   cHeaderGet  := ""
    Local   cPostParms  := ""
    Local   cToken      := ""
    Local   cInvNum     := ""
    Local   cProgram    := "Program: UNIPAR"
    Local   cContent    := "Content-Type: application/json"
    Local   aHeadStr    := {}
    Local   aAuth       := {}
    Local	cAliasTRB	:= GetNextAlias()
    Local   cBanco      := SuperGetMV("MK_BANCO", , "MNK")

	Default lSchedule	:= .F.


	//--< Procedimentos >-------------------------------------------------------------------
	If !lSchedule
		oSelf:SaveLog(" * * * Início do Processamento * * * ")
		oSelf:SaveLog("Executando para filial: " + cFilAnt)
	EndIf

    // Query para selecao de registros
    cSQL := MNK02Qry()

    //	cSQL := ChangeQuery(cSQL)
    If Select(cAliasTRB) > 0
        (cAliasTRB)->(DBCloseArea())
    EndIf
    DBUseArea(.T., "TOPCONN", TCGenQry( , , cSQL), (cAliasTRB), .F., .T.)

    Count To nRegua

    If !lSchedule
        oSelf:SetRegua1(nRegua)
    EndIf

    (cAliasTRB)->(DBSelectArea(cAliasTRB))
    (cAliasTRB)->(DBGoTop())
    While !(cAliasTRB)->(EOF())

        //URL da API
        cURL_MNK := "https://hmg-zuul.monkeyecx.com/v1/sponsors/"
        cURL_MNK += CValToChar((cAliasTRB)->A2_XIDMNK)
        cURL_MNK += "/payables"

        cInvNum     := (cAliasTRB)->E2_NUM + "-" + (cAliasTRB)->E2_PREFIXO + " (" + (cAliasTRB)->E2_FILIAL + "/" + (cAliasTRB)->E2_PARCELA + "/" + (cAliasTRB)->E2_TIPO + "/" + (cAliasTRB)->E2_FORNECE + "/" + (cAliasTRB)->E2_LOJA + ")"

        // Retorna total de parcelas
        nParcs := U_ADRetParc((cAliasTRB)->E2_FILIAL, (cAliasTRB)->E2_PREFIXO, (cAliasTRB)->E2_NUM, (cAliasTRB)->E2_FORNECE, (cAliasTRB)->E2_LOJA)

        cPostParms := '{' + cEOL
        cPostParms += '"items": [ ' + cEOL
        cPostParms += '{' + cEOL
        cPostParms += '"externalId": "' + AllTrim((cAliasTRB)->E2_FILIAL + (cAliasTRB)->E2_PREFIXO + (cAliasTRB)->E2_NUM + (cAliasTRB)->E2_PARCELA) + '", ' + cEOL
        cPostParms += '"installment": ' + AllTrim((cAliasTRB)->E2_PARCELA) + ', ' + cEOL
        cPostParms += '"invoiceDate": "' + SubStr((cAliasTRB)->E2_EMISSAO, 1, 4) + '-' + SubStr((cAliasTRB)->E2_EMISSAO, 5, 2) + '-' + SubStr((cAliasTRB)->E2_EMISSAO, 7, 2) + 'T00:00:00", ' + cEOL
        cPostParms += '"invoiceKey": "' + AllTrim((cAliasTRB)->E2_FILIAL + (cAliasTRB)->E2_PREFIXO + (cAliasTRB)->E2_NUM + (cAliasTRB)->E2_PARCELA) + '", ' + cEOL
        cPostParms += '"invoiceNumber": "' + cInvNum + '", ' + cEOL
        cPostParms += '"paymentDate": "' + SubStr((cAliasTRB)->E2_VENCTO, 1, 4) + '-' + SubStr((cAliasTRB)->E2_VENCTO, 5, 2) + '-' + SubStr((cAliasTRB)->E2_VENCTO, 7, 2) + 'T00:00:00", ' + cEOL
        cPostParms += '"paymentValue": ' + CValToChar((cAliasTRB)->E2_SALDO) + ', ' + cEOL
        cPostParms += '"realPaymentDate": "' + SubStr((cAliasTRB)->E2_VENCREA, 1, 4) + '-' + SubStr((cAliasTRB)->E2_VENCREA, 5, 2) + '-' + SubStr((cAliasTRB)->E2_VENCREA, 7, 2) + 'T00:00:00", ' + cEOL
        cPostParms += '"supplierGovernmentId": "' + (cAliasTRB)->A2_CGC + '", ' + cEOL
        cPostParms += '"supplierName": "' + AllTrim((cAliasTRB)->A2_NOME) + '", ' + cEOL
        cPostParms += '"totalInstallment": ' + CValToChar(nParcs) + ' ' + cEOL
        cPostParms += '}' + cEOL
        cPostParms += ']' + cEOL
        cPostParms += '}' + cEOL

        aHeadStr    := {}
        aAuth       := U_MNKAUTH()
        nPos        := AScan(aAuth, {|x| AllTrim(x[1]) == "access_token"})
        cToken      := "Authorization: Bearer " + aAuth[nPos,2]
        
        //Header do POST
        AAdd(aHeadStr, cToken)
        AAdd(aHeadStr, cProgram)
        AAdd(aHeadStr, cContent)        

        MemoWrite(cLogDir + cLogArq + ".json", cURL_MNK + cEOL + cPostParms)

        //Efetua o POST na API
        cRetPost := HTTPPost(cURL_MNK, /*cGetParms*/, cPostParms, nTimeOut, aHeadStr, @cHeaderGet)

        If "200 OK" $ cHeaderGet .Or. "HTTP/1.1 200" $ cHeaderGet .Or. "201 OK" $ cHeaderGet .Or. "HTTP/1.1 201" $ cHeaderGet
            SE2->(DBSelectArea("SE2"))
            SE2->(DBGoTo((cAliasTRB)->SE2RECNO))
            RecLock("SE2", .F.)
                SE2->E2_PORTADO := cBanco
            SE2->(MSUnLock())
        Else
            ConOut("Erro: " + cHeaderGet)
            MsgAlert("Erro na integração com a API Monkey! ")
        EndIf

        (cAliasTRB)->(DBSkip())

    EndDo

	If !lSchedule
		oSelf:SaveLog("Total de Registros Atualizados: " + CValToChar(nCont))
		oSelf:SaveLog(" * * * Fim do Processamento * * * ")
	EndIf

Return



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MNK02Qry
//Query de seleção de registros
@author Rafael Yera Barchi
@since 13/09/2020
@version 1.00

@type function
/*/
//------------------------------------------------------------------------------------------
Static Function MNK02Qry()

    Local 	cSQL 		:= ""


    cSQL := "          SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, A2_NOME, A2_CGC,E2_NATUREZ, E2_EMISSAO, E2_VENCTO, E2_VENCREA, E2_VALOR, E2_SALDO, E2_PORTADO, SE2.R_E_C_N_O_ SE2RECNO," + cEOL
    cSQL += "          E2_XMNK,ED_XMNK,A2_XMNK,E2_NATUREZ"
    cSQL += "            FROM " + RetSQLName("SE2") + " SE2 "
    If "MSSQL" $ Upper(AllTrim(TCGetDB()))
        cSQL += " (NOLOCK) " + cEOL
    Else
        cSQL += cEOL
    EndIf
    
    cSQL += "      INNER JOIN " + RetSQLName("SA2") + " SA2 "
    If "MSSQL" $ Upper(AllTrim(TCGetDB()))
        cSQL += " (NOLOCK) " + cEOL
    Else
        cSQL += cEOL
    EndIf
    cSQL += "              ON A2_FILIAL = '" + FWxFilial("SA2") + "' " + cEOL
    cSQL += "             AND A2_COD = E2_FORNECE " + cEOL
    cSQL += "             AND A2_LOJA = E2_LOJA " + cEOL
    cSQL += "             AND SA2.D_E_L_E_T_ = ' ' " + cEOL
    
    cSQL += "      INNER JOIN " + RetSQLName("SED") + " SED "
    If "MSSQL" $ Upper(AllTrim(TCGetDB()))
        cSQL += " (NOLOCK) " + cEOL
    Else
        cSQL += cEOL
    EndIf
    cSQL += "              ON ED_FILIAL = '" + FWxFilial("SED") + "' " + cEOL
	cSQL += "             AND ED_CODIGO = E2_NATUREZ " + cEOL
    cSQL += "             AND SED.D_E_L_E_T_ = ' '  " + cEOL

    cSQL += "           WHERE E2_FILIAL = '" + FWxFilial("SE2") + "' " + cEOL
    cSQL += "             AND E2_EMISSAO BETWEEN '" + DToS(MV_PAR01) + "' AND '" + DToS(MV_PAR02) + "' " + cEOL
    cSQL += "             AND E2_VENCREA BETWEEN '" + DToS(MV_PAR03) + "' AND '" + DToS(MV_PAR04) + "' " + cEOL
    cSQL += "             AND E2_PORTADO = '" + Space(TamSX3("E2_PORTADO")[1]) + "' " + cEOL
    //cSQL += "             AND A2_XIDMNK <> 0 " + cEOL
    cSQL += "             AND SE2.D_E_L_E_T_ = ' ' " + cEOL

    MemoWrite(cLogDir + cLogArq + ".sql", cSQL)

Return cSQL



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidPerg
//Rotina para criação de perguntas.
@author Rafael Yera Barchi
@since 13/09/2020
@version 1.00

@type function
/*/
//------------------------------------------------------------------------------------------
//Static Function ValidPerg()
//
//	//--< Variáveis >-----------------------------------------------------------------------
//	Local aAreaX1 := GetArea()
//
//
//	//--< Procedimentos >-------------------------------------------------------------------
//	U_PutSx1AD(cPerg, "01", "Da emissao?"       , "", "", "mv_ch1"	, "D", TamSX3("E2_EMISSAO")[1]	, TamSX3("E2_EMISSAO")[2]	, 1, "G", "", 		, "", "", "MV_PAR01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {"Informe a data de emissao inicial para pesquisa. "}		, {}, {})
//	U_PutSx1AD(cPerg, "02", "Até a emissao?"    , "", "", "mv_ch2"	, "D", TamSX3("E2_EMISSAO")[1]	, TamSX3("E2_EMISSAO")[2]	, 1, "G", "", 		, "", "", "MV_PAR02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {"Informe a data de emissao final para pesquisa. "}	    , {}, {})
//	U_PutSx1AD(cPerg, "03", "Dp vencimento?"    , "", "", "mv_ch3"	, "D", TamSX3("E2_VENCREA")[1]	, TamSX3("E2_VENCREA")[2]	, 1, "G", "", 		, "", "", "MV_PAR03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {"Informe a data de vencimento inicial para pesquisa. "}		, {}, {})
//	U_PutSx1AD(cPerg, "04", "Até o vencimento?" , "", "", "mv_ch4"	, "D", TamSX3("E2_VENCREA")[1]	, TamSX3("E2_VENCREA")[2]	, 1, "G", "", 		, "", "", "MV_PAR04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {"Informe a data de vencimento final para pesquisa. "}	    , {}, {})
//
//	RestArea(aAreaX1)
//
//Return



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
//Função para utilização no Schedule
@author Rafael Yera Barchi
@since 13/09/2020
@version 1.00
@type function
/*/
//------------------------------------------------------------------------------------------
Static Function SchedDef()

	Local _aPar 	:= {}	//array de retorno


	_aPar := { 	"P"		,;	//Tipo R para relatorio P para processo
				cPerg   ,;	//Nome do grupo de perguntas (SX1)
				Nil		,;	//cAlias (para Relatorio)
				Nil		,;	//aArray (para Relatorio)
				Nil		}	//Titulo (para Relatorio)
	
Return _aPar



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MNK02Dmy
//Dummy Function - Apenas para não apresentar warning na compilação
@author Rafael Yera Barchi
@since 13/09/2020
@version 1.00
@param Nil
@return Nil
@type function
/*/
//------------------------------------------------------------------------------------------
User Function MNK02Dmy()
	
	
	If .F.
		SchedDef()
	EndIf
	
Return
//--< fim de arquivo >----------------------------------------------------------------------



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MNK02Pro
Rotina auxiliar de processamento

@author    Rafael Yera Barchi
@version   1.xx
@since     13/09/2020
/*/
//------------------------------------------------------------------------------------------
Static Function MNK02Pr2(oSelf, lSchedule)

	//--< Variáveis >-----------------------------------------------------------------------
	Local 	nCont       := 0
	Local 	nRegua		:= 0
//  Local   nPos        := 0
//  Local   nTimeOut    := 120
    Local   cSQL        := ""
//  Local   cRetPost    := ""
//  Local   cURL_MNK    := ""
//  Local   cHeaderGet  := ""
//  Local   cPostParms  := ""
//  Local   cToken      := ""
    Local   cInvNum     := ""
//  Local   cProgram    := "Program: UNIPAR"
//  Local   cContent    := "Content-Type: application/json"
//  Local   aHeadStr    := {}
//  Local   aAuth       := {}
    Local	cAliasTRB	:= GetNextAlias()
    Local   cBanco      := SuperGetMV("MK_BANCO", , "MNK")
    Local   cMK_URL	    := alltrim(SuperGetMV("MK_URLTIT"	, , "https://sap-proxy.monkeyecx.com/service/SponsorsPayables_v2.wsdl"))
    Local   cUsuario      := alltrim(SuperGetMV("MK_USERCON"	, , "sapproxy.monkeyecx@gmail.com")) 
    Local   cSenhaUsr     := alltrim(SuperGetMV("MK_PASSCON"	, , "Sapproxy2020!123"))  
	Local   cAuthBasic    := Alltrim(Encode64(cUsuario + ":" + cSenhaUsr))
    Local   cTPTITMNK     := SuperGetMV("MK_TPTITMK")
    
    Local cTokenMK    := ""
	
    Default lSchedule	:= .F.

    If U_MNKAUT2(@cTokenMK)
        //--< Procedimentos >-------------------------------------------------------------------
        If !lSchedule
            oSelf:SaveLog(" * * * Início do Processamento * * * ")
            oSelf:SaveLog("Executando para filial: " + cFilAnt)
        EndIf
        // Query para selecao de registros
        cSQL := MNK02Qry()

        //	cSQL := ChangeQuery(cSQL)
        If Select(cAliasTRB) > 0
            (cAliasTRB)->(DBCloseArea())
        EndIf
        DBUseArea(.T., "TOPCONN", TCGenQry( , , cSQL), (cAliasTRB), .F., .T.)

        Count To nRegua

        If !lSchedule
            oSelf:SetRegua1(nRegua)
        EndIf

        (cAliasTRB)->(DBSelectArea(cAliasTRB))
        (cAliasTRB)->(DBGoTop())

        While !(cAliasTRB)->(EOF())
            IF ((cAliasTRB)->E2_TIPO $ cTPTITMNK) .OR. (cAliasTRB)->E2_XMNK == "S" .OR. (cAliasTRB)->A2_XMNK == "S" .OR. (cAliasTRB)->ED_XMNK == "S"
                
                cInvNum     := (cAliasTRB)->E2_NUM + "-" + (cAliasTRB)->E2_PREFIXO + " (" + (cAliasTRB)->E2_FILIAL + "/" + (cAliasTRB)->E2_PARCELA + "/" + (cAliasTRB)->E2_TIPO + "/" + (cAliasTRB)->E2_FORNECE + "/" + (cAliasTRB)->E2_LOJA + ")"
                
                // Retorna total de parcelas
                nParcs := U_ADRetParc((cAliasTRB)->E2_FILIAL, (cAliasTRB)->E2_PREFIXO, (cAliasTRB)->E2_NUM, (cAliasTRB)->E2_FORNECE, (cAliasTRB)->E2_LOJA)

                oWsdl := TWsdlManager():New()
                oWsdl:lSSLInsecure := .T. //Desabilita o Uso de Segurança no WS
                xRet := oWsdl:ParseURL(cMK_URL)
                if xRet == .F.
                    conout("Erro ParseURL: " + oWsdl:cError)
                    Return
                endif

                xRet := oWsdl:ListOperations()
                If Len( xRet ) == 0
                    conout( "Erro: " + oWsdl:cError )
                EndIf

                // Define a operação
                xRet := oWsdl:SetOperation("Create")
                if xRet == .F.
                    conout( "Erro: " + oWsdl:cError )
                    Return
                endif

                lRet := oWsdl:AddHttpHeader( "Authorization" , "Basic "+cAuthBasic)
                if xRet == .F.
                    conout( "Erro: " + oWsdl:cError )
                    Return
                endif
            
                cMsg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'+ CRLF
                cMsg += 'xmlns:v1="http://monkey.com.br/ecx/plugin/authentication/v1"'+ CRLF
                cMsg += 'xmlns:v2="http://monkey.com.br/ecx/plugin/sponsors/payables/v2">'+ CRLF
                cMsg += '<soapenv:Header>'+ CRLF
                cMsg += '<v1:AuthenticationHeaderRequest>'+ CRLF
                cMsg += '<v1:program>UNIPAR</v1:program>'+ CRLF
                cMsg += '<v1:companyGovernmentId>61460325000141</v1:companyGovernmentId>'+ CRLF
                cMsg += '<v1:accessToken>'+alltrim(cTokenMK)+'</v1:accessToken>'+ CRLF
                cMsg += '</v1:AuthenticationHeaderRequest>'+ CRLF
                cMsg += '</soapenv:Header>'+ CRLF

                cMsg += '<soapenv:Body>'+ CRLF
                cMsg += '    <v2:CreateRequest>'+ CRLF
                cMsg += '        <v2:items>'+ CRLF
                cMsg += '            <v2:item>'+ CRLF
                cMsg += '            <v2:externalId>' + AllTrim((cAliasTRB)->E2_FILIAL + (cAliasTRB)->E2_PREFIXO + (cAliasTRB)->E2_NUM + (cAliasTRB)->E2_PARCELA) + '</v2:externalId>'+ CRLF
                cMsg += '            <v2:electronicInvoiceKey/>'+ CRLF
                cMsg += '            <v2:installment>' + AllTrim((cAliasTRB)->E2_PARCELA) + '</v2:installment>'+ CRLF
                cMsg += '            <v2:invoiceDate>' + SubStr((cAliasTRB)->E2_EMISSAO, 1, 4) + '-' + SubStr((cAliasTRB)->E2_EMISSAO, 5, 2) + '-' + SubStr((cAliasTRB)->E2_EMISSAO, 7, 2) + '</v2:invoiceDate>'+ CRLF
                cMsg += '            <v2:invoiceNumber>' + cInvNum + '</v2:invoiceNumber>'+ CRLF
                cMsg += '            <v2:paymentDate>' + SubStr((cAliasTRB)->E2_VENCTO, 1, 4) + '-' + SubStr((cAliasTRB)->E2_VENCTO, 5, 2) + '-' + SubStr((cAliasTRB)->E2_VENCTO, 7, 2) + ' </v2:paymentDate>'+ CRLF
                cMsg += '            <v2:paymentValue>' + CValToChar((cAliasTRB)->E2_SALDO) + '</v2:paymentValue>'+ CRLF
                cMsg += '            <v2:realPaymentDate>' + SubStr((cAliasTRB)->E2_VENCREA, 1, 4) + '-' + SubStr((cAliasTRB)->E2_VENCREA, 5, 2) + '-' + SubStr((cAliasTRB)->E2_VENCREA, 7, 2) + '</v2:realPaymentDate>'+ CRLF
                cMsg += '            <v2:supplierGovernmentId>' + (cAliasTRB)->A2_CGC + '</v2:supplierGovernmentId>'+ CRLF
                cMsg += '            <v2:supplierName>' + AllTrim((cAliasTRB)->A2_NOME) + '</v2:supplierName>'+ CRLF
                cMsg += '            <v2:totalInstallment>' + CValToChar(nParcs) + '</v2:totalInstallment>'+ CRLF
                cMsg += '            </v2:item>'+ CRLF
                cMsg += '        </v2:items>'+ CRLF
                cMsg += '    </v2:CreateRequest>'+ CRLF
                cMsg += '</soapenv:Body>'+ CRLF

                cMsg += '</soapenv:Envelope>'+ CRLF

                lRet := oWsdl:SendSoapMsg(cMsg)
                If !lRet
                    ConOut("[WSMNK03] - Erro SendSoapMsg: " + oWsdl:cError)
                    ConOut("[WSMNK03] - Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode)
                    lRet := .F.
                Else
                    cMsgRet := oWsdl:GetSoapResponse()
                    SE2->(DBSelectArea("SE2"))
                    SE2->(DBGoTo((cAliasTRB)->SE2RECNO))
                    RecLock("SE2", .F.)
                    SE2->E2_PORTADO := cBanco
                    SE2->(MSUnLock())
                    conout( cMsgRet )
                EndIf
            ENDIF
            (cAliasTRB)->(DBSkip())

        EndDo

        If !lSchedule
            oSelf:SaveLog("Total de Registros Atualizados: " + CValToChar(nCont))
            oSelf:SaveLog(" * * * Fim do Processamento * * * ")
        EndIf
    Else
    conout( "Erro: Nao conseguiu gerar o Token" )
	EndIf
	

Return
