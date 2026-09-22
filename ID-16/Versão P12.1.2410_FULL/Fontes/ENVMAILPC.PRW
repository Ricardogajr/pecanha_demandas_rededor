#include 'protheus.ch'
#include "Ap5Mail.ch"
#include "rwmake.ch"
/*/{Protheus.doc} ENVMAILPC
//TODO Função responsável por enviar o email com os pedidos pendentes de SP.
@author Ricardo Junior
@since 17/07/2019
@version 1.0
@return Nil
@type function
/*/

User Function ENVMAILPC(cFil, cNum)
    Local lRet         := .T.
    Local cError       := ""
    Local _cQuery      := ""
    Local cAlias       := GetNextAlias()
    // Obtém configurações do servidor SMTP
    Local cSMTPServer  := GetMV("MV_RELSERV",, "")
    Local cSMTPUser    := GetMV("MV_RELACNT",, "")
    Local cSMTPPass    := GetMV("MV_RELPSW",, "")
    Local cMailFrom    := GetMV("MV_RELACNT",, "")
    Local lUseAuth     := GetMV("MV_RELAUTH",, .T.)
    Local nPort        := GetMV("MV_GCPPORT",, 25)
    Local cSubject     := SuperGetMv("MV_XSUBJPC",, "TITULO DO E-MAIL")
    Local cVarMV_XHMLMAI:= SuperGetMv("MV_XHMLMAI",, "ricardogajr@gmail.com")
    Local cAmbiente    := GetEnvServer()
	Local oMail		   := TMailManager():New()
	Local cFilBkp 		:= ""
	Local cUserApr 		:= ""
	Local cFilApr  		:= ""

    Private _lEnviado  := .F.
    Private cHtml      := ""
    
    Default cFil := ""
    Default cNum := ""

    // Verifica se o parâmetro está habilitado para executar
    If !SuperGetMv("MV_XMAILPC",, .T.)
        Return
    EndIf
    


    // Verifica configurações obrigatórias
    If Empty(cSMTPServer) .OR. Empty(cMailFrom)
        cError := "Erro na configuração: "
        If Empty(cSMTPServer)
            cError += "Servidor SMTP não configurado (MV_RELSERV)" + CRLF
        EndIf
        If Empty(cMailFrom)
            cError += "Conta de envio não configurada (MV_RELACNT)" + CRLF
        EndIf
        If lUseAuth .AND. (Empty(cSMTPUser) .OR. Empty(cSMTPPass))
            cError += "Autenticação requer usuário/senha (MV_RELACNT/MV_RELPSW)" + CRLF
        EndIf
        
        Alert(cError)
        Return .F.
    EndIf

    // Monta query SQL
    _cQuery := " SELECT CR_FILIAL AS FILIAL," + CRLF 
    _cQuery += " TRIM(CR_NUM) AS SOL_PAG,   " + CRLF
    _cQuery += " C7.C7_XTIPO AS TIPO_REQ, C7.C7_FORNECE AS FORNECE, A2_NOME AS NOME_FORNECE," + CRLF
    _cQuery += " CR_APROV AS COD_APROV, AK_NOME AS APROV, CR_USER AS USUARIO_APROV, C7_CC AS CENTRO_CUSTO," + CRLF
    _cQuery += " CTT_DESC01 AS DESC_CENTRO_CUSTO, CR_TOTAL AS TOTAL, C7_PRODUTO AS PRODUTO, C7_EMISSAO AS EMISSAO," + CRLF
    _cQuery += " MIN(CR_NIVEL) AS NIVEL, C7_XDTVEN AS DATA_VENCIMENTO, CR_STATUS, CR_GRUPO, CR_DATALIB,  CR_USERLIB," + CRLF
    _cQuery += " CR_LIBAPRO " + CRLF
    _cQuery += " FROM "+RetSqlName("SCR")+" CR " + CRLF
    _cQuery += " INNER JOIN "+RetSqlName("SAK")+" AK " + CRLF
    _cQuery += "  ON AK_FILIAL = CR_FILIAL " + CRLF
    _cQuery += "  AND AK_COD = CR_APROV " + CRLF
    _cQuery += "  AND CR_USER = AK_USER " + CRLF
    _cQuery += " INNER JOIN "+RetSqlName("SC7")+" C7 " + CRLF
    _cQuery += "  ON C7_FILIAL = CR_FILIAL " + CRLF
    _cQuery += "  AND C7_NUM = CR_NUM " + CRLF
    _cQuery += "  AND C7_CONAPRO = 'B' " + CRLF
    _cQuery += "  AND C7_XSOLPAG = '1' " + CRLF
    _cQuery += "  AND C7_QUJE < C7_QUANT " + CRLF
    _cQuery += " INNER JOIN "+RetSqlName("SA2")+" A2 " + CRLF
    _cQuery += "  ON A2_FILIAL = '        ' " + CRLF
    _cQuery += "  AND A2_COD = C7.C7_FORNECE " + CRLF
    _cQuery += "  AND A2_LOJA = C7_LOJA " + CRLF
    _cQuery += " INNER JOIN "+RetSqlName("CTT")+" CTT " + CRLF
    _cQuery += "  ON CTT_FILIAL = '        ' " + CRLF
    _cQuery += "  AND CTT_CUSTO = C7_CC " + CRLF
    _cQuery += " WHERE CR.D_E_L_E_T_ = ' ' " + CRLF
    _cQuery += " AND AK.D_E_L_E_T_ = ' ' " + CRLF
    _cQuery += " AND C7.D_E_L_E_T_ = ' ' " + CRLF
    _cQuery += " AND CTT.D_E_L_E_T_ = ' ' " + CRLF
    _cQuery += " AND A2.D_E_L_E_T_ = ' ' " + CRLF
    _cQuery += " AND CR_FILIAL = '"+cFil+"' " + CRLF
    _cQuery += " AND CR_TIPO = 'PC' " + CRLF
    
    If Empty(cNum)
        _cQuery += " AND C7_XDTVEN <= '"+DToS((dDataBase+SuperGetMv("MV_XDTAPPC",,15)))+"' " + CRLF
        _cQuery += " AND CR_STATUS IN ('02') " + CRLF
    Else
        _cQuery += " AND CR_NUM = '"+cNum+"' " + CRLF
    EndIf
    
    _cQuery += " GROUP BY CR_FILIAL, TRIM(CR_NUM), C7.C7_XTIPO, C7.C7_FORNECE, A2_NOME, CR_APROV, AK_NOME, CR_USER, C7_CC, " + CRLF
    _cQuery += " CTT_DESC01, CR_TOTAL, C7_PRODUTO, C7_EMISSAO, C7_XDTVEN, CR_STATUS, CR_GRUPO, CR_DATALIB, CR_USERLIB, CR_LIBAPRO " + CRLF
    _cQuery += " ORDER BY 1, 8, 2, 15" + CRLF
    
    // Executa a query
    DbUseArea(.F., "TOPCONN", TcGenQry(,, _cQuery), cAlias, .f., .f.)
    
    If Select(cAlias) <= 0
        Return .F.
    EndIf
    
    // Inicializa objeto de e-mail
    oMail := TMailManager():New()
    oMail:Init("", cSMTPServer, cSMTPUser, cSMTPPass, 0, nPort)
    oMail:SetSmtpTimeOut(30) // 30 segundos de timeout
    
    // Processa os registros
    cFilBkp := cFilAnt
    While !(cAlias)->(Eof())
        cUserApr := (cAlias)->USUARIO_APROV
        cFilApr  := (cAlias)->FILIAL
        cFilAnt := cFilApr
        
        // Monta cabeçalho HTML
        CabecHtml()
        
        // Processa todos os registros para o mesmo usuário/filial
        While !(cAlias)->(Eof()) .And. cFilApr == (cAlias)->FILIAL .And. cUserApr == (cAlias)->USUARIO_APROV
            MontaHtml({(cAlias)->FILIAL,; 
                      FWFilialName(),; 
                      (cAlias)->SOL_PAG,; 
                      (cAlias)->FORNECE,; 
                      (cAlias)->NOME_FORNECE,;
                      (cAlias)->APROV,;
                      DTOC(STOD((cAlias)->DATA_VENCIMENTO)),;
                      TRANSFORM((cAlias)->TOTAL, "@E 999,999,999,999.99"),;
                      AllTrim((cAlias)->CENTRO_CUSTO),;
                      (cAlias)->DESC_CENTRO_CUSTO,;
                      UsrRetMail((cAlias)->USUARIO_APROV)})
            (cAlias)->(DbSkip())
        EndDo
        
        cFilAnt := cFilBkp
        RodapeHtml()
        
        // Define destinatário
        If At("H", cAmbiente) == 1 // Ambiente de homologação
            cEmailUsr := cVarMV_XHMLMAI
        Else
            cEmailUsr := UsrRetMail(cUserApr)
        EndIf
        
        // Conecta e envia e-mail
        nErro := oMail:SmtpConnect()
        If nErro != 0
            cError := oMail:GetErrorString(nErro)
            Alert("Erro ao conectar ao servidor SMTP: " + cError)
            lRet := .F.
        Else
            // Autenticação se necessário
            If lUseAuth
                nErro := oMail:SmtpAuth(cSMTPUser, cSMTPPass)
                If nErro != 0
                    cError := oMail:GetErrorString(nErro)
                    Alert("Erro na autenticação SMTP: " + cError)
                    lRet := .F.
                EndIf
            EndIf
            
            If lRet
                // Prepara e envia a mensagem
                oMessage := TMailMessage():New()
                oMessage:Clear()
                oMessage:cFrom    := cMailFrom
                oMessage:cTo      := cEmailUsr
                oMessage:cSubject := cSubject + " - " + cAmbiente
                oMessage:cBody    := cHtml
                
                nErro := oMessage:Send(oMail)
                If nErro != 0
                    cError := oMail:GetErrorString(nErro)
                    Alert("Erro ao enviar e-mail: " + cError)
                    lRet := .F.
                Else
                    _lEnviado := .T.
                EndIf
            EndIf
            
            // Desconecta do servidor
            oMail:SMTPDisconnect()
        EndIf
        
        cHtml := ""
    EndDo
    
    // Fecha a área de trabalho
    (cAlias)->(DbCloseArea())
    
Return lRet

// User Function ENVMAILPC(cFil, cNum) 
// 	Local lAutentica    := GetMV("MV_RELAUTH") 
// 	Local _cQuery 		:= ""
// 	Local cAlias 		:= GetNextAlias() 
// 	Local aAux			:= {}
// 	Private cError		:= ""
// 	Private _lEnviado   := .F.
// 	Private cHtml		:= ""
// 	Private lResult       := .F.                    // Resultado da tentativa de comunicacao com servidor de E-Mail
	
// 	Default cFil := ""
// 	Default cNum := ""

// 	If !SuperGetMv("MV_XMAILPC",,.T.)//Verifica se o parametro esta habilitado para executar.
// 		Return
// 	EndIf
	
// 	_cQuery := " SELECT CR_FILIAL AS FILIAL," + CRLF 
//     _cQuery += " TRIM(CR_NUM) AS SOL_PAG,   " + CRLF
// 	_cQuery += " C7.C7_XTIPO AS TIPO_REQ, C7.C7_FORNECE AS FORNECE, A2_NOME AS NOME_FORNECE," + CRLF
// 	_cQuery += " CR_APROV AS COD_APROV, AK_NOME AS APROV, CR_USER AS USUARIO_APROV, C7_CC AS CENTRO_CUSTO," + CRLF
// 	_cQuery += " CTT_DESC01 AS DESC_CENTRO_CUSTO, CR_TOTAL AS TOTAL, C7_PRODUTO AS PRODUTO, C7_EMISSAO AS EMISSAO," + CRLF
// 	_cQuery += " MIN(CR_NIVEL) AS NIVEL, C7_XDTVEN AS DATA_VENCIMENTO, CR_STATUS, CR_GRUPO, CR_DATALIB,  CR_USERLIB," + CRLF
// 	_cQuery += " CR_LIBAPRO                                                                                                             " + CRLF
// 	_cQuery += " FROM "+RetSqlName("SCR")+" CR                                                                                          " + CRLF
// 	_cQuery += " INNER JOIN "+RetSqlName("SAK")+" AK                                                                                    " + CRLF
// 	_cQuery += " 	ON AK_FILIAL = CR_FILIAL                                                                                            " + CRLF
// 	_cQuery += " 	AND AK_COD = CR_APROV                                                                                               " + CRLF
// 	_cQuery += " 	AND CR_USER = AK_USER                                                                                               " + CRLF
// 	_cQuery += " INNER JOIN "+RetSqlName("SC7")+" C7                                                                                    " + CRLF
// 	_cQuery += " 	ON C7_FILIAL = CR_FILIAL                                                                                            " + CRLF
// 	_cQuery += " 	AND C7_NUM = CR_NUM                                                                                                 " + CRLF
// 	_cQuery += " 	AND C7_CONAPRO = 'B'                                                                                                " + CRLF
// 	_cQuery += " 	AND C7_XSOLPAG = '1'                                                                                                " + CRLF
// 	_cQuery += " 	AND C7_QUJE < C7_QUANT                                                                                              " + CRLF
// 	_cQuery += " INNER JOIN "+RetSqlName("SA2")+" A2                                                                                    " + CRLF
// 	_cQuery += " 	ON A2_FILIAL = '        '                                                                                           " + CRLF
// 	_cQuery += " 	AND A2_COD = C7.C7_FORNECE	                                                                                        " + CRLF
// 	_cQuery += " 	AND A2_LOJA = C7_LOJA                                                                                               " + CRLF
// 	_cQuery += " INNER JOIN "+RetSqlName("CTT")+" CTT                                                                                   " + CRLF
// 	_cQuery += " 	ON CTT_FILIAL = '        '                                                                                          " + CRLF
// 	_cQuery += " 	AND CTT_CUSTO = C7_CC                                                                                               " + CRLF
// 	_cQuery += "     WHERE CR.D_E_L_E_T_ = ' '                                                                                          " + CRLF
// 	_cQuery += "     AND AK.D_E_L_E_T_ = ' '                                                                                            " + CRLF
// 	_cQuery += "     AND C7.D_E_L_E_T_ = ' '                                                                                            " + CRLF
// 	_cQuery += "     AND CTT.D_E_L_E_T_ = ' '                                                                                           " + CRLF
// 	_cQuery += "     AND A2.D_E_L_E_T_ = ' '                                                                                            " + CRLF
// 	_cQuery += "     AND CR_FILIAL = '"+cFil+"'                                                                                         " + CRLF
// 	_cQuery += "     AND CR_TIPO = 'PC'																									" + CRLF
// 	If Empty(cNum)    																								
// 		_cQuery += "     AND C7_XDTVEN <= '"+DToS((dDataBase+SuperGetMv("MV_XDTAPPC",,15)))+"'                                          " + CRLF//Parametro data da aprovação da PC.
// 		_cQuery += "     AND CR_STATUS IN ('02')                                                                                        " + CRLF
// 	Else
// 		_cQuery += "     AND CR_NUM = '"+cNum+"'												                                        " + CRLF
// 	EndIf
// 	_cQuery += "     GROUP BY CR_FILIAL, TRIM(CR_NUM), C7.C7_XTIPO, C7.C7_FORNECE, A2_NOME, CR_APROV, AK_NOME, CR_USER, C7_CC,          " + CRLF
// 	_cQuery += "     CTT_DESC01, CR_TOTAL, C7_PRODUTO, C7_EMISSAO, C7_XDTVEN, CR_STATUS, CR_GRUPO, CR_DATALIB, CR_USERLIB, CR_LIBAPRO   " + CRLF
// 	_cQuery += "     ORDER BY 1, 8, 2, 15" + CRLF		
	
// 	DbUseArea(.F., "TOPCONN", TcGenQry(,, _cQuery), cAlias, .f., .f.) 
	
// 	If Select(cAlias) <= 0
// 		Return
// 	EndIf
// 	cFilBkp := cFilAnt
// 	While !(cAlias)->(Eof())
// 		cUserApr := (cAlias)->USUARIO_APROV
// 		cFilApr  := (cAlias)->FILIAL
// 		cFilAnt := cFilApr
// 		CabecHtml()
// 		While !(cAlias)->(Eof()) .And. cFilApr  == (cAlias)->FILIAL .And. cUserApr == (cAlias)->USUARIO_APROV
// 				MontaHtml({(cAlias)->FILIAL,; 
// 							FWFilialName(),; 
// 							(cAlias)->SOL_PAG,; 
// 							(cAlias)->FORNECE,; 
// 							(cAlias)->NOME_FORNECE,;
// 							(cAlias)->APROV,;
// 							DTOC(STOD((cAlias)->DATA_VENCIMENTO)),;
// 							TRANSFORM((cAlias)->TOTAL, "@E 999,999,999,999.99"),;
// 							AllTrim((cAlias)->CENTRO_CUSTO),;
// 							(cAlias)->DESC_CENTRO_CUSTO,;
// 							UsrRetMail((cAlias)->USUARIO_APROV)})		
// 	    (cAlias)->(DbSkip())
// 	    EndDo
// 	    cFilAnt := cFilBkp
// 	    RodapeHtml()
// 		CONNECT SMTP SERVER  GetMV("MV_RELSERV") ACCOUNT GetMV("MV_RELACNT") PASSWORD GetMV("MV_RELPSW") RESULT lResult 
// 		If lAutentica     
// 			lRet := MailAuth(GetMV("MV_RELACNT"),GetMV("MV_RELPSW")) 
// 		Else
// 			lRet := .T.
// 		Endif     
// 		If lResult .And. lRet
// 			cAmbiente := GetEnvServer()
// 			If At("H", cAmbiente) == 1//Verifica se é um ambiente de homologação
// 				cEmailUsr := SuperGetMv("MV_XHMLMAI",,"ricardogajr@gmail.com")
// 			Else
// 				cEmailUsr := UsrRetMail(cUserApr)
// 			EndIf
// 			SEND MAIL FROM GetMV("MV_RELACNT") TO cEmailUsr SUBJECT SuperGetMv("MV_XSUBJPC",,"TITULO DO E-MAIL") + " - " + cAmbiente BODY cHtml FORMAT TEXT RESULT _lEnviado 
// 			If !_lEnviado
// 	       		If isBlind()
// 		           GET MAIL ERROR cError
// 		           Help(" ",1,"ATENCAO",,cError+ " " + cEmailTo,4,5)     //STR0006
// 		        EndIf
// 		    Endif
// 	       DISCONNECT SMTP SERVER
// 	    Else
// 	   		If isBlind()
// 	   			GET MAIL ERROR cError
// 	   			Help(" ",1,"Atencao",,cError,4,5)
// 	   		EndIf
// 	   EndIf 
// 	   cHtml := ""         
// 	EndDo
// Return

Static Function CabecHtml()
	cHtml += ' <!DOCTYPE html>'
	cHtml += ' <html>'
	cHtml += ' <body>'
	cHtml += ' <p>' + SuperGetMv("MV_XBODYPC",,"MENSAGEM DO CORPO DO E-MAIL") + '</p>'  
	cHtml += ' <table style="border-collapse: collapse;">'
	cHtml += '  <tr>'
	cHtml += '      <td style="border: 1px solid black">Filial</td>'
	cHtml += '      <td style="border: 1px solid black">Descr. Filial</td>'
	cHtml += '      <td style="border: 1px solid black">Solicitação Pagamento</td>'
	cHtml += '      <td style="border: 1px solid black">Fornecedor</td>'
	cHtml += '      <td style="border: 1px solid black">Nome do fornecedor</td>'
	cHtml += '      <td style="border: 1px solid black">Nome do Aprovador</td>'
	cHtml += '      <td style="border: 1px solid black">Data de vencimento</td>'
	cHtml += '      <td style="border: 1px solid black">Valor do documento</td>'
	cHtml += '      <td style="border: 1px solid black">Centro de Custo</td>'
	cHtml += '      <td style="border: 1px solid black">Desc. Centro de Custo</td>'
	cHtml += '  </tr>'
Return

Static Function MontaHtml(aAux)
	
	cHtml += '  <tr>'
	cHtml += '     <td style="border: 1px solid black">'+aAux[01]+'</td>'
	cHtml += '     <td style="border: 1px solid black">'+AllTrim(aAux[02])+'</td>'
	cHtml += '     <td style="border: 1px solid black">'+AllTrim(aAux[03])+'</td>'
	cHtml += '     <td style="border: 1px solid black">'+AllTrim(aAux[04])+'</td>'
	cHtml += '     <td style="border: 1px solid black">'+AllTrim(aAux[05])+'</td>'
	cHtml += '     <td style="border: 1px solid black">'+AllTrim(aAux[06])+'</td>'
	cHtml += '     <td style="border: 1px solid black">'+aAux[07]+'</td>'
	cHtml += '     <td style="border: 1px solid black">'+aAux[08]+'</td>'
	cHtml += '     <td style="border: 1px solid black">'+AllTrim(aAux[09])+'</td>'
	cHtml += '     <td style="border: 1px solid black">'+AllTrim(aAux[10])+'</td>'
	cHtml += '  </tr>'
	
Return

Static Function RodapeHtml()
	cHtml += '  </body>'
	cHtml += ' </table>'
	cHtml += ' </body>'
	cHtml += ' </html>'
Return
