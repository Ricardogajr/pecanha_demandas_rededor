// #########################################################################################
// Projeto: Monkey
// Modulo : SIGAFIN
// Fonte  : payables
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 30/04/21 | Rafael Yera Barchi| Consulta títulos previamente processados
// ---------+-------------------+-----------------------------------------------------------

#INCLUDE    "TOTVS.CH"
#INCLUDE    "RESTFUL.CH"

#DEFINE 	cEOL			Chr(13) + Chr(10)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} payables
Consulta títulos previamente processados

@author    Rafael Yera Barchi
@version   1.xx
@since     30/04/2021
/*/
//------------------------------------------------------------------------------------------
WSRESTFUL payables DESCRIPTION "ATOS DATA payables - Consulta de Títulos por Lote"

	WSDATA      cRequestId	AS STRING
    WSDATA 		cResponse   AS STRING

	WSMETHOD GET cRequestId	;
    DESCRIPTION "Consulta informações dos títulos por lote de processamento" ;
    WSSYNTAX "/payables/{cRequestId}" ;
    PATH "/payables/{cRequestId}"

END WSRESTFUL



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} payables
payables - Método GET

@author    Rafael Yera Barchi
@version   1.xx
@since     30/04/2021

Exemplo de Requisição: 
//--- Início
null
//--- Fim

/*/
//------------------------------------------------------------------------------------------
WSMETHOD GET cRequestId PATHPARAM cRequestId WSSERVICE payables

	Local 	lReturn     := .T.
    Local 	lCheckAuth  := SuperGetMV("MK_CHKAUTH", , .F.)
	Local   nCont       := 0
    Local 	nRegua		:= 0
    Local 	nValor		:= 0
//  Local   nTamFil     := 0
    Local   aTabEmp     := {}
    Local   cSQL        := ""
    Local	cAliasTRB	:= ""
    Local   cMNKLote    := ""
	Local	cMessage 	:= ""
	Local 	cResponse 	:= ""
    Local 	cItems 	    := ""
    Local 	cStatus	    := ""
//  Local   cLayout     := ""
//  Local   cFilMatriz  := ""
    Local   cCNPJMatriz := ""
    Local   cInvNum     := ""
    Local   cAction     := ""
    Local   cHasMore    := "false"
    Local   nParc       := ""
    Local   nParcs      := 0
	Local 	nHTTPCode 	:= 400
    Local   nLimTit     := SuperGetMV("MK_LIMTIT", , 50)
    Local   dVctIni     := dDataBase + SuperGetMV("MK_VENCINI", , 0)
    Local cMKINTMNK:= SuperGetMV("MK_INTMNK", , .F.)
    Local cMV_VLRETIR:= GetMV("MV_VLRETIR")
    Local cMV_VLRETIN:= GetMV("MV_VLRETIN")
    Local cMV_VRETISS:= GetMV("MV_VRETISS")
	Local cMV_VRETPIS:= GetMV("MV_VRETPIS")
	Local cMV_VRETCOF:= GetMV("MV_VRETCOF")
	Local cMV_VRETCSL:= GetMV("MV_VRETCSL")
	
    Private cLogDir		:= SuperGetMV("MK_LOGDIR", , "\log\")
	Private cLogArq		:= "payables"


    ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | payables Início"))
    FWLogMsg("INFO", , "MONKEY", "payables", "001", "001", "Início do Processo", 0, 0, {})
    
    ::SetContentType("application/JSON;charset=UTF-8")
    
    cMNKLote := ::cRequestId

    ZM1->(DBSelectArea("ZM1"))
    ZM1->(DBSetOrder(1))
    If ZM1->(DBSeek(FWxFilial("ZM1") + PadR(cMNKLote, TamSX3("ZM1_COD")[1])))
        If ZM1->ZM1_STATUS == "2"
            cStatus := "true"
        Else
            cStatus := "false"
        EndIf
    Else
		lReturn		:= .F.
		nHTTPCode 	:= 500
		cMessage 	:= "Lote não encontrado"
    EndIf

    If lReturn
        
        If lCheckAuth
            cUser := U_MNKRetUsr(::GetHeader("Authorization"))
        Else
            ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | payables Executando sem autenticação"))
            FWLogMsg("WARN", , "MONKEY", "payables", "002", "400", "Início do Processo", 0, 0, {})
        EndIf

        If lCheckAuth .And. Empty(cUser)

            lReturn		:= .F.
            nHTTPCode 	:= 401
            cMessage 	:= "Usuário não autenticado"

        Else

            cResponse := '{ ' + cEOL
            cResponse += '"requestId": "' + cMNKLote + '", ' + cEOL
            cResponse += '"requestCompleted": ' + cStatus + ', ' + cEOL
            
            If cStatus == "true"
                
                cResponse += '"pageSize": 1, ' + cEOL
                cResponse += '"hasMoreItems": #####, ' + cEOL   // Gravo ##### para poder depois substituir no StrTran indicando se tem ou não mais títulos
                cResponse += '"items": [' + cEOL

                SM0->(DBSelectArea("SM0"))
                SM0->(DBGoTop())
                While !SM0->(EOF())
                    
                    If AScan(aTabEmp, RetSQLName("SE2")) == 0
                        
                        AAdd(aTabEmp, RetSQLName("SE2"))
                        
                        cEmpAnt := SM0->M0_CODIGO
                        cFilAnt := SM0->M0_CODFIL

                        lIntMnk := cMKINTMNK
                        
                        If lIntMnk

                            ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | payables - Executando para a Empresa: " + cEmpAnt + " / Filial: " + cFilAnt))
                            
                            /*
                            ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | payables Query de Atualização - Início"))
                            // Update para atualizar o lote dos títulos vencidos
                            cSQL := MNKXUpd(cMNKLote)

                            If (nQryRet := TCSQLExec(cSQL)) < 0
                                ConOut("Erro na atualização de títulos vencidos! ")
                                FWLogMsg("ERROR", , "MONKEY", "payables", "021", "600", "Erro na atualização de títulos vencidos", 0, 0, {})
                            Else
                                TCRefresh("SE2")
                            EndIf
                            ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | payables Query de Atualização - Fim"))
                            */
                            
                            ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | payables Query de Seleção - Início"))
                            
                            // Query para selecao de registros
                            cSQL := MNKXQry(cMNKLote)

                            cAliasTRB := GetNextAlias()
                            If Select(cAliasTRB) > 0
                                (cAliasTRB)->(DBCloseArea())
                            EndIf
                            DBUseArea(.T., "TOPCONN", TCGenQry( , , cSQL), (cAliasTRB), .F., .T.)

                            ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | payables Query de Seleção - Fim"))

                            If "MSSQL" $ Upper(AllTrim(TCGetDB()))
                                Count To nRegua
                            Else
                                (cAliasTRB)->(DBSelectArea(cAliasTRB))
                                (cAliasTRB)->(DBGoTop())
                                nRegua := (cAliasTRB)->ROW_COUNT
                            EndIf

                            ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | payables Query: " + CValToChar(nRegua)))

                            (cAliasTRB)->(DBSelectArea(cAliasTRB))
                            (cAliasTRB)->(DBGoTop())
                            While !(cAliasTRB)->(EOF())

                                nCont++
                                If nCont > nLimTit
                                    cHasMore := "true"
                                    ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | payables Finalizando devido ao limite de títulos (Limite: " + CValToChar(nLimTit)))
                                    Exit
                                EndIf

                                ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | payables Registro: " + CValToChar(nCont) + "/" + CValToChar(nRegua)))
                                
                                ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | payables ADConvParc - Início"))
                                nParc   := U_ADConvParc(AllTrim((cAliasTRB)->E2_PARCELA), 2)
                                ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | payables ADConvParc - Fim"))

                                // Ricardo solicitou para enviar o mesmo conteúdo em Parcela e Total de Parcelas
                                // O Total de Parcelas é apenas informativo e não tem implicação no portal
                                /*
                                ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | payables ADRetParc - Início"))
                                nParcs  := U_ADRetParc((cAliasTRB)->E2_FILIAL, (cAliasTRB)->E2_PREFIXO, (cAliasTRB)->E2_NUM, (cAliasTRB)->E2_FORNECE, (cAliasTRB)->E2_LOJA)
                                ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | payables ADRetParc - Fim"))
                                */
                                If nParc == 0
                                    nParc := 1
                                EndIf
                                nParcs := nParc

                                If !Empty(cItems)
                                    cItems += ', ' + cEOL
                                Else
                                    cItems += cEOL
                                EndIf
                                

                                // Rafael Yera Barchi
                                // Desabilitamos e estamos enviando o CNPJ da Filial mesmo
                                /*

                                // Tratativa para enviar o CNPJ da Matriz - Início
                                aAreaSM0    := SM0->(GetArea())

                                ConOut("Grupo de Empresas Atual: " + SM0->M0_CODIGO)
                                ConOut("Filial Atual: " + SM0->M0_CODFIL)
                                ConOut("CNPJ Atual: " + SM0->M0_CGC)
                                
                                cLayout     := FWSM0Layout()
                                ConOut("Layout: " + cLayout)
                                cLayout     := AllTrim(Replace(cLayout, "F", ""))
                                
                                nTamFil     := FWSizeFilial() - Len(cLayout)
                                ConOut("Tamanho Filial: " + CValToChar(nTamFil))
                                
                                cFilMatriz  := (cAliasTRB)->E2_FILIAL   //FWCodFil()
                                cFilMatriz  := Left(cFilMatriz, Len(cLayout)) + StrZero(1, nTamFil)
                                ConOut("Matriz: " + cFilMatriz)

                                cCNPJMatriz := AllTrim(AllTrim(FWArrFilAtu(FWCodEmp(), cFilMatriz)[18]))
                                ConOut("CNPJ Matriz: " + cCNPJMatriz)
                                
                                RestArea(aAreaSM0)
                                // Tratativa para enviar o CNPJ da Matriz - Fim

                                */

                                ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | payables FWArrFilAtu - Início"))
                                cCNPJMatriz := AllTrim(FWArrFilAtu(FWCodEmp(), (cAliasTRB)->E2_FILIAL)[18])
                                ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | payables FWArrFilAtu - Fim"))

                                cInvNum     := (cAliasTRB)->E2_NUM + "-" + (cAliasTRB)->E2_PREFIXO + " (" + (cAliasTRB)->E2_FILIAL + "/" + (cAliasTRB)->E2_PARCELA + "/" + (cAliasTRB)->E2_TIPO + "/" + (cAliasTRB)->E2_FORNECE + "/" + (cAliasTRB)->E2_LOJA + ")"
                                
                                // Rafael Yera Barchi - 12/05/2022
                                // Solicitação de Mudança - 031_Solicitac?a?o de Mudanc?a_Multa_Juros_Desconto_v1 (24/02/2022)
                                //nValor := (cAliasTRB)->E2_SALDO + (cAliasTRB)->E2_SDACRES - (cAliasTRB)->E2_SDDECRE
                                nValor  := (cAliasTRB)->E2_SALDO + (cAliasTRB)->E2_SDACRES - (cAliasTRB)->E2_SDDECRE + (cAliasTRB)->E2_MULTA + (cAliasTRB)->E2_JUROS - (cAliasTRB)->E2_DESCONT

                                If Empty((cAliasTRB)->E2_PARCIR) .And. (cAliasTRB)->E2_IRRF >= cMV_VLRETIR
                                    nValor := nValor - (cAliasTRB)->E2_IRRF
                                EndIf

                                If Empty((cAliasTRB)->E2_PARCINS) .And. (cAliasTRB)->E2_INSS >= cMV_VLRETIN
                                    nValor := nValor - (cAliasTRB)->E2_INSS
                                EndIf

                                If Empty((cAliasTRB)->E2_PARCISS) .And. (cAliasTRB)->E2_ISS >= cMV_VRETISS
                                    nValor := nValor - (cAliasTRB)->E2_ISS
                                EndIf

                                If Empty((cAliasTRB)->E2_PARCPIS) .And. (cAliasTRB)->E2_PIS >= cMV_VRETPIS
                                    nValor := nValor - (cAliasTRB)->E2_PIS
                                EndIf

                                If Empty((cAliasTRB)->E2_PARCCOF) .And. (cAliasTRB)->E2_COFINS >= cMV_VRETCOF
                                    nValor := nValor - (cAliasTRB)->E2_COFINS
                                EndIf

                                If Empty((cAliasTRB)->E2_PARCSLL) .And. (cAliasTRB)->E2_CSLL >= cMV_VRETCSL
                                    nValor := nValor - (cAliasTRB)->E2_CSLL
                                EndIf

                                If SToD((cAliasTRB)->E2_VENCREA) < dVctIni .Or. (cAliasTRB)->E2_XMNKSTA == "4"
                                    cAction := '"remove"'
                                Else
                                    cAction := '"create"'
                                EndIf
                                
                                cItems += ' { ' + cEOL
                                cItems += ' "companyGovernmentId": "' + cCNPJMatriz + '", ' + cEOL
                                // cItems += ' "externalId": "' + (cAliasTRB)->E2_FILIAL + (cAliasTRB)->E2_PREFIXO + (cAliasTRB)->E2_NUM + (cAliasTRB)->E2_PARCELA + (cAliasTRB)->E2_TIPO + '", ' + cEOL
                                cItems += ' "externalId": "' + cEmpAnt + (cAliasTRB)->E2_FILIAL + CValToChar((cAliasTRB)->SE2RECNO) + '", ' + cEOL
                                cItems += ' "installment": ' + CValToChar(nParc) + ', ' + cEOL
                                cItems += ' "invoiceDate": "' + SubStr((cAliasTRB)->E2_EMISSAO, 1, 4) + '-' + SubStr((cAliasTRB)->E2_EMISSAO, 5, 2) + '-' + SubStr((cAliasTRB)->E2_EMISSAO, 7, 2) + 'T00:00:00", ' + cEOL
                                cItems += ' "electronicInvoiceKey": "", ' + cEOL
                                cItems += ' "invoiceNumber": "' + cInvNum + '", ' + cEOL
                                cItems += ' "paymentDate": "' + SubStr((cAliasTRB)->E2_VENCTO, 1, 4) + '-' + SubStr((cAliasTRB)->E2_VENCTO, 5, 2) + '-' + SubStr((cAliasTRB)->E2_VENCTO, 7, 2) + 'T00:00:00", ' + cEOL
                                cItems += ' "paymentValue": ' + CValToChar(nValor) + ', ' + cEOL
                                cItems += ' "realPaymentDate": "' + SubStr((cAliasTRB)->E2_VENCREA, 1, 4) + '-' + SubStr((cAliasTRB)->E2_VENCREA, 5, 2) + '-' + SubStr((cAliasTRB)->E2_VENCREA, 7, 2) + 'T00:00:00", ' + cEOL
                                cItems += ' "supplierGovernmentId": "' + (cAliasTRB)->A2_CGC + '", ' + cEOL
                                cItems += ' "supplierName": "' + AllTrim((cAliasTRB)->A2_NOME) + '", ' + cEOL
                                cItems += ' "totalInstallment": ' + CValToChar(nParcs) + ', ' + cEOL
                                cItems += ' "action": ' + cAction + cEOL
                                cItems += ' }'

                                ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | payables - Concluiu para a Empresa: " + cEmpAnt + " / Filial: " + cFilAnt))

                                (cAliasTRB)->(DBSkip())

                            EndDo

                            If Select(cAliasTRB) > 0
                                (cAliasTRB)->(DBCloseArea())
                            EndIf

                        EndIf

                    EndIf

                    SM0->(DBSkip())

                EndDo

                cResponse += cItems + cEOL + '] ' + cEOL

            Else

                cResponse += '"pageSize": 0, ' + cEOL
                cResponse += '"hasMoreItems": #####, ' + cEOL   // Gravo ##### para poder depois substituir no StrTran indicando se tem ou não mais títulos
                cResponse += '"items": []' + cEOL

            EndIf

            cResponse += '} '

        EndIf

        // Corrigo o hasMoreItems para paginação na API
        cResponse := StrTran(cResponse, "#####", cHasMore)

    EndIf

    cResponse := EncodeUTF8(cResponse)

	ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | payables Message: " + cMessage))
    ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | payables Response: " + cResponse))

	If !lReturn
		SetRestFault(nHTTPCode, EncodeUTF8(cMessage))
		::SetResponse(cResponse)
	Else
		::SetResponse(cResponse)
	EndIf

	MemoWrite(cLogDir + cLogArq + "_response.json", cResponse)

    ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | payables Fim"))
    FWLogMsg("INFO", , "MONKEY", "payables", "999", "999", "Fim do Processo", 0, 0, {})

Return lReturn



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MNKXUpd
//Query de seleção de registros
@author Rafael Yera Barchi
@since 30/04/2021
@version 1.00

@type function
/*/
//------------------------------------------------------------------------------------------
/*
Static Function MNKXUpd(cMNKLote)

    Local 	cSQL 		:= ""
    Local   dVctIni     := dDataBase + SuperGetMV("MK_VENCINI", , 0)

        
    cSQL := " UPDATE " + RetSQLName("SE2") + cEOL
    cSQL += "    SET E2_XMNKLOT = '" + cMNKLote + "', E2_XMNKSTA = '4' " + cEOL
    cSQL += "  WHERE E2_XMNKLOT <> '" + Space(TamSX3("E2_XMNKLOT")[1]) + "' " + cEOL
    cSQL += "    AND E2_VENCREA < '" + DToS(dVctIni) + "' " + cEOL
    cSQL += "    AND D_E_L_E_T_ = ' ' " + cEOL

    MemoWrite(cLogDir + cLogArq + "_upd.sql", cSQL)

Return cSQL
*/



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MNKXQry
//Query de seleção de registros
@author Rafael Yera Barchi
@since 30/04/2021
@version 1.00

@type function
/*/
//------------------------------------------------------------------------------------------
Static Function MNKXQry(cMNKLote)

    Local 	cSQL 		:= ""


    If "MSSQL" $ Upper(AllTrim(TCGetDB()))
        
        cSQL := "          SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, A2_NOME, A2_CGC, E2_NATUREZ, E2_EMISSAO, E2_VENCTO, E2_VENCREA, E2_VALOR, E2_SALDO, E2_MULTA, E2_JUROS, E2_DESCONT, E2_PORTADO, E2_SDACRES, E2_SDDECRE, E2_PARCIR, E2_BASEIRF, E2_IRRF, E2_PARCINS, E2_BASEINS, E2_INSS, E2_PARCISS, E2_BASEISS, E2_ISS, E2_PARCPIS, E2_BASEPIS, E2_PIS, E2_PARCCOF, E2_BASECOF, E2_COFINS, E2_PARCSLL, E2_BASECSL, E2_CSLL, E2_XMNKSTA, SE2.R_E_C_N_O_ SE2RECNO " + cEOL
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

    //  cSQL += "           WHERE E2_FILIAL = '" + FWxFilial("SE2") + "' " + cEOL
        cSQL += "           WHERE E2_FILIAL >= '" + Space(TamSX3("E2_FILIAL")[1]) + "' " + cEOL
        cSQL += "             AND E2_XMNKLOT = '" + cMNKLote + "' " + cEOL
    //  cSQL += "             AND E2_NUMBOR = '" + Space(TamSX3("E2_NUMBOR")[1]) + "' " + cEOL
    //  cSQL += "             AND E2_XMNKSTA = '" + Space(TamSX3("E2_XMNKSTA")[1]) + "' " + cEOL
        cSQL += "             AND E2_XMNKSTA IN ('0', '4') " + cEOL
        cSQL += "             AND SE2.D_E_L_E_T_ = ' ' " + cEOL
        cSQL += "        ORDER BY SE2.R_E_C_N_O_ " + cEOL

    Else

        cSQL := "          SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, A2_NOME, A2_CGC, E2_NATUREZ, E2_EMISSAO, E2_VENCTO, E2_VENCREA, E2_VALOR, E2_SALDO, E2_MULTA, E2_JUROS, E2_DESCONT, E2_PORTADO, E2_SDACRES, E2_SDDECRE, E2_PARCIR, E2_BASEIRF, E2_IRRF, E2_PARCINS, E2_BASEINS, E2_INSS, E2_PARCISS, E2_BASEISS, E2_ISS, E2_PARCPIS, E2_BASEPIS, E2_PIS, E2_PARCCOF, E2_BASECOF, E2_COFINS, E2_PARCSLL, E2_BASECSL, E2_CSLL, E2_XMNKSTA, SE2.R_E_C_N_O_ SE2RECNO, COUNT(*) OVER (PARTITION BY 1) ROW_COUNT " + cEOL
        cSQL += "            FROM " + RetSQLName("SE2") + " SE2, " + RetSQLName("SA2") + " SA2 " + cEOL
        cSQL += "           WHERE SA2.A2_FILIAL = '" + FWxFilial("SA2") + "' " + cEOL
        cSQL += "             AND SA2.A2_COD = SE2.E2_FORNECE " + cEOL
        cSQL += "             AND SA2.A2_LOJA = SE2.E2_LOJA " + cEOL
        cSQL += "             AND SA2.D_E_L_E_T_ = ' ' " + cEOL
        cSQL += "             AND SE2.R_E_C_N_O_ IN (SELECT /*+ INDEX(SE2010 SE2010N) */ R_E_C_N_O_ " + cEOL
        cSQL += "                                      FROM SE2010 " + cEOL
        cSQL += "                                     WHERE D_E_L_E_T_ = ' ' " + cEOL 
        cSQL += "                                       AND E2_VENCREA >= TO_CHAR(SYSDATE,'YYYYMMDD') " + cEOL
        cSQL += "                                       AND E2_XMNKLOT = '" + cMNKLote + "' " + cEOL
//      cSQL += "                                       AND E2_NUMBOR = '" + Space(TamSX3("E2_NUMBOR")[1]) + "' " + cEOL
        cSQL += "                                       AND E2_XMNKSTA IN ('0', '4') ) " + cEOL

    EndIf

    MemoWrite(cLogDir + cLogArq + "_qry.sql", cSQL)

Return cSQL
//--< fim de arquivo >----------------------------------------------------------------------
