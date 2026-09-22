#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSPORTAL01
description: WebServices para consulta de fornecedor NOME portal conecta
@author  Ricardo Junior
@since   29/12/2021
@version 1.0
/*/
//-------------------------------------------------------------------

User Function FSPORT02()
Return

    WSRESTFUL WSPORT02 DESCRIPTION "Portal Conecta Fornecedor Consulta Nome" FORMAT "APPLICATION_FORM_URLENCODED"

        WSDATA CNPJ AS String

        WSMETHOD POST DESCRIPTION "POST ListarFornecedorNOME" PATH "/ListarFornecedorNOME"

    END WSRESTFUL

WSMETHOD POST WSSERVICE WSPORT02
    Local lRet      := .T.         // Recebe o Retorno
    Local cBody     := ''          // Recebe o conteudo do Rest
    Local cQuery    := ""
    Local cNome     := ""
    Local cAliasSA2 := GetNextAlias()
    Local cXml := ""

    cBody := ::GetContent()
    ::SetContentType("text/xml")
    aNome := StrTokArr(cBody, "=")

    cQuery += " SELECT A2_NOME, A2_EST, A2_CGC, A2_COD, A2_BANCO, A2_AGENCIA, A2_DVAGE, A2_NUMCON, A2_DVCTA "
    cQuery += " FROM " + RetSqlName("SA2")
    cQuery += " WHERE D_E_L_E_T_ = ' '"

    if Len(aNome) > 1
        cNome := aNome[2]
    endif
    if !Empty(cNome)
        cQuery += " AND A2_NOME LIKE '%" + AllTrim(cNome) +"%' "
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

