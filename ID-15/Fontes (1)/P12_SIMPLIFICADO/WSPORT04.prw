#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSPORTAL01
description: WebServices para consulta de Centro de Custo descrição portal conecta
@author  Ricardo Junior
@since   29/12/2021
@version 1.0
/*/
//-------------------------------------------------------------------

User Function FSPORT04()
Return

    WSRESTFUL WSPORT04 DESCRIPTION "Portal Conecta Centro de Custo Descrição" FORMAT "APPLICATION_FORM_URLENCODED"

        WSDATA CNPJ AS String

        WSMETHOD POST DESCRIPTION "POST ConsultarCentroCustoDescricao" PATH "/ConsultarCentroCustoDescricao"

    END WSRESTFUL

WSMETHOD POST WSSERVICE WSPORT04
    Local lRet      := .T.         // Recebe o Retorno
    Local cBody     := ''          // Recebe o conteudo do Rest
    Local cQuery    := ""
    Local cAliasCTT := GetNextAlias()
    Local aValores := {}
    Local nX        := 01
    Local cXml      := ""

    cBody := ::GetContent()
    ::SetContentType("text/xml")
    aDados := StrTokArr(cBody, "&")

    for nX := 01 To Len(aDados)
        aResult :=  StrTokArr(aDados[nX], "=")
        aAdd(aValores, iif(Len(aResult) > 1, aResult[2], ""))
    next nX

    if Len(aValores) > 1
        cEmpAnt := aValores[1]
        cFilAnt := aValores[2]
    endif

    cQuery += " SELECT CTT_CUSTO, CTT_DESC01, CTT_RES "
    cQuery += " FROM " + RetSqlName("CTT")
    cQuery += " WHERE D_E_L_E_T_ = ' '"

    DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAliasCTT, .T., .T.)

    cXml += '<?xml version="1.0" encoding="utf-8"?>' + CRLF
    cXml += '<ArrayOfCentroCustoDescricao xmlns="http://tempuri.org/">' + CRLF

    nCount := 0
    While (cAliasCTT)->(!Eof())
        nCount++
        cXml += '<CentroCustoDescricao>' + CRLF
        cXml += '<CentroCusto>'+AllTrim((cAliasCTT)->CTT_CUSTO)+'</CentroCusto>' + CRLF
        cXml += '<DescricaoCentroCusto>'+AllTrim(U_trataEncode((cAliasCTT)->CTT_DESC01))+'</DescricaoCentroCusto>' + CRLF
        cXml += '<Responsavel>'+AllTrim((cAliasCTT)->CTT_RES)+'</Responsavel>' + CRLF
        cXml += '</CentroCustoDescricao>' + CRLF
        if nCount == 100
            ::SetResponse(cXml)
            cXml := ""
            nCount := 0
        endif
        (cAliasCTT)->(DbSkip())
    EndDo
    cXml += '</ArrayOfCentroCustoDescricao>' + CRLF
    ::SetResponse(cXml)

Return lRet

