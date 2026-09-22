#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSPORTAL01
description: WebServices para consulta da Natureza Descrição portal conecta
@author  Ricardo Junior
@since   29/12/2021
@version 1.0
/*/
//-------------------------------------------------------------------

//User Function FSPORT03()
//Return

WSRESTFUL WSPORT03 DESCRIPTION "Portal Conecta Natureza Consulta descrição" FORMAT "APPLICATION_FORM_URLENCODED"

    WSDATA CNPJ AS String

    WSMETHOD POST DESCRIPTION "POST ConsultarNaturezasDescricao" PATH "/ConsultarNaturezasDescricao"

END WSRESTFUL

WSMETHOD POST WSSERVICE WSPORT03
    Local lRet      := .T.         // Recebe o Retorno
    Local cBody     := ''          // Recebe o conteudo do Rest
    Local cQuery    := ""
    Local cAliasSED := GetNextAlias()
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

    cQuery += " SELECT ED_CODIGO, ED_DESCRIC "
    cQuery += " FROM " + RetSqlName("SED")
    cQuery += " WHERE D_E_L_E_T_ = ' ' "

    DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAliasSED, .T., .T.)

    cXml += '<?xml version="1.0" encoding="utf-8"?>' + CRLF
    cXml += '<ArrayOfNaturezasDescricao xmlns="http://tempuri.org/">' + CRLF

    nCount := 0
    While (cAliasSED)->(!Eof())
        nCount++
        cXml += '<NaturezasDescricao>' + CRLF
        cXml += '<Natureza>'+AllTrim((cAliasSED)->ED_CODIGO)+'</Natureza>' + CRLF
        cXml += '<NaturezaDescricao>'+AllTrim(U_trataEncode((cAliasSED)->ED_DESCRIC))+'</NaturezaDescricao>' + CRLF
        cXml += '</NaturezasDescricao>' + CRLF
        if nCount == 100
            ::SetResponse(cXml)
            cXml := ""
            nCount := 0
        endif
        (cAliasSED)->(DbSkip())
    EndDO
    cXml += '</ArrayOfNaturezasDescricao>' + CRLF

    ::SetResponse(cXml)

Return lRet

