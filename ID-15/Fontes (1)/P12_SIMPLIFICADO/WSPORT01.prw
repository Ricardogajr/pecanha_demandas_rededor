#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSPORTAL01
description: WebServices para consulta de fornecedor CNPJ portal conecta
@author  Ricardo Junior
@since   29/12/2021
@version 1.0
/*/
//-------------------------------------------------------------------

User Function FSPORT01()
Return

    WSRESTFUL WSPORT01 DESCRIPTION "Portal Conecta Fornecedor Consulta CNPJ" FORMAT "APPLICATION_FORM_URLENCODED"

        WSDATA CNPJ AS String

        WSMETHOD POST DESCRIPTION "POST ListarFornecedorCNPJ" PATH "/ListarFornecedorCNPJ"

    END WSRESTFUL

WSMETHOD POST WSSERVICE WSPORT01
    Local lRet      := .T.         // Recebe o Retorno
    Local cBody     := ''          // Recebe o conteudo do Rest
    Local cQuery    := ""
    Local cCnPj     := ""
    Local cAliasSA2 := GetNextAlias()
    Local cXml := ""

    cBody := ::GetContent()
    ::SetContentType("text/xml")
    aCnpj := StrTokArr(cBody, "=")

    cQuery += " SELECT A2_NOME, A2_EST, A2_CGC, A2_COD, A2_BANCO, A2_AGENCIA, A2_DVAGE, A2_NUMCON, A2_DVCTA "
    cQuery += " FROM " + RetSqlName("SA2")
    cQuery += " WHERE D_E_L_E_T_ = ' '"
    //cQuery += " AND A2_MSBLQL in ('2', ' ') "

    if Len(aCnpj) > 1
        cCnpJ := aCnpj[2]
    endif
    if !Empty(cCnPj)
        cQuery += " AND A2_CGC = '" + PadR(cCNPJ, TamSx3("A2_CGC")[01]) +"' "
    endif

    DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAliasSA2, .T., .T.)

    cXml += '<?xml version="1.0" encoding="utf-8"?>' + CRLF
    cXml += '<ArrayOfFornecedor xmlns="http://tempuri.org/">' + CRLF

    nCount := 0
    While (cAliasSA2)->(!Eof())
        nCount++
        cXml += '<Fornecedor>' + CRLF
        cXml += '<NAME>'+AllTrim(U_trataEncode((cAliasSA2)->A2_NOME))+'</NAME>' + CRLF
        cXml += '<STATE>'+AllTrim((cAliasSA2)->A2_EST)+'</STATE>' + CRLF
        cXml += '<FEDERALID>'+AllTrim((cAliasSA2)->A2_CGC)+'</FEDERALID>' + CRLF
        cXml += '<SUPPLIERCODE>'+AllTrim((cAliasSA2)->A2_COD)+'</SUPPLIERCODE>' + CRLF
        cXml += '<BANCO>'+AllTrim((cAliasSA2)->A2_BANCO)+'</BANCO>' + CRLF
        cXml += '<AGENCIA>'+AllTrim(AllTrim((cAliasSA2)->A2_AGENCIA) + ' '  +  AllTrim((cAliasSA2)->A2_DVAGE))+'</AGENCIA>' + CRLF
        cXml += '<CONTA>'+AllTrim(AllTrim((cAliasSA2)->A2_NUMCON) + ' '     +  AllTrim((cAliasSA2)->A2_DVCTA))+'</CONTA>' + CRLF
        cXml += '</Fornecedor>  ' + CRLF
        if nCount == 100
            ::SetResponse(cXml)
            cXml := ""
            nCount := 0
        endif
        (cAliasSA2)->(DbSkip())
    EndDO
    cXml += '</ArrayOfFornecedor>' + CRLF

    ::SetResponse(cXml)
    
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} trataEncode
description: Rotina para tratar campo texto.
@author  Ricardo Junior
@since   29/12/2021
@version 1.0
/*/
//-------------------------------------------------------------------

User Function trataEncode(cValor)
    
    Local aTratar   := {}
    Local nX        := 00
    Default cValor := ""

    aAdd(aTratar, {"&", " "})
    aAdd(aTratar, {"", " "})
    aAdd(aTratar, {"°", " "})

    For nX := 01 To Len(aTratar)
        cValor := Replace(cValor, aTratar[nX][1], aTratar[nX][2])
    Next nX

    cValor := EncodeUTF8(FWNoAccent(cValor))

Return cValor
