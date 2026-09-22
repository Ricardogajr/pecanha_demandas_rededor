#Include "TOTVS.CH"
#Include "AP5MAIL.CH"
#include "TBICONN.CH"

Static aOrigXPR := {}

/*/{Protheus.doc} F2000530

Se lancamento originado no XRT, envia e-mail de notificacao de alteracao ou exclusao

Executado pelos PEs (depois da operacao):
- DPCTB103GR (CTBA103)
- DPCTB102GR (CTBA102)
- CTBLANC (CTBA101)

@type function
@version  
@author fabio.cazarini
@since 25/06/2021
@param nOpc, numeric, 4=Alteracao ou 5=exclusao
@param dData, date, data do lancamento contabil
@param cLote, character, lote
@param cSubLote, character, sublote
@param cDoc, character, documento
/*/
User Function F2000530(nOpc, dDatalanc, cLote, cSubLote, cDoc)
	Local cParCtb 		:= ""
	Local cPara 		:= ""
	Local cAssunto 		:= ""
	Local cCorpo1		:= ""
	Local aTable		:= {}
	Local cCorpo2		:= "* E-mail enviado automaticamente"
	Local cMensagem		:= ""
	Local lGrpHblt      := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual

    //Integração não habilitada neste grupo
    If !lGrpHblt
        Return
    EndIf

    If Len(aOrigXPR) > 0
		cPara := Alltrim(SuperGetMV("FS_C200051", .T. , ""))
		If !Empty(cPara)
			cParCtb := aOrigXPR[1][1][1] // array static criada antes da operacao, com dados do lancamento contabil original

			cAssunto 	:= "[TOTVS] Notificação de " + iif(nOpc==5,"exclusão ","alteração ") + "de lançamento contábil XRT"
			cCorpo1		:= "Dados do lançamento:"

			aAdd( aTable, { "Data do lançamento:"	, dToC(dDatalanc) 	})
			aAdd( aTable, { "Lote:"					, cLote 			})
			aAdd( aTable, { "Sublote:"				, cSubLote 			})
			aAdd( aTable, { "Documento:"			, cDoc 				})
			aAdd( aTable, { "Par contábil:"			, cParCtb 			})
			aAdd( aTable, { "Usuário:"				, UsrFullName()		})

			cMensagem	:= FormHTML(cAssunto, cCorpo1, aTable, cCorpo2)

			// Envia e-mail de notificacao em thread separada para não precisar aguardar
			StartJob("U_F20005JB", GetEnvServer(), .F., cEmpAnt, cFilAnt, cPara, cAssunto, cMensagem)
		Endif
    Endif

Return NIL


/*/{Protheus.doc} F2000532

Envia e-mail de notificacao em thread separada para não precisar aguardar

@type function
@version  
@author fabio.cazarini
@since 25/06/2021
@return variant, return_description
/*/
User Function F20005JB(cCodEmp, cCodFil, cPara, cAssunto, cMensagem)
	Local lExibeHelp := .F.

	RpcSetType ( 3 )
	PREPARE ENVIRONMENT EMPRESA cCodEmp FILIAL cCodFil MODULO "CTB"                                 

	// Envia e-mail de notificacao
	U_F20005EM(cPara, , , cAssunto, cMensagem, lExibeHelp) 

	RESET ENVIRONMENT	

Return NIL


/*/{Protheus.doc} F2000531

Armazena dados na array static aOrigXPR com o lancamento contabil, quando originado pelo XRT

Executado pelos PEs (antes da operacao):
- ANCTB103GR (CTBA103)
- ANCTB102GR (CTBA102)
- VDCTB101GR (CTBA101)

@type function
@version  
@author fabio.cazarini
@since 25/06/2021
@param nOpc, numeric, 4=Alteracao ou 5=exclusao
@param dData, date, data do lancamento contabil
@param cLote, character, lote
@param cSubLote, character, sublote
@param cDoc, character, documento
/*/
User Function F2000531(nOpc, dDatalanc, cLote, cSubLote, cDoc)
	Local aItemCT2	:= {}
	Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual

    //Integração não habilitada neste grupo
    If !lGrpHblt
        Return
    EndIf

	aOrigXPR := {} // limpa a variavel static

	If !Empty(CT2->CT2_XPCXRT) 								// se o lancamento foi originado pelo XRT (somente avalia a linha posicionada na CT2)
		aAdd(aItemCT2, {CT2->CT2_XPCXRT, CT2->CT2_XCDXRT}) 	// armazena o par contabil e a chave XRT (da linha posicionada na CT2)
		aAdd(aOrigXPR, aItemCT2)
	Endif

Return NIL


/*/{Protheus.doc} F20005EM

Função genérica de envio de e-mail simples
Exemplo: U_F20005EM(cPara, , , cAssunto, cCorpo)

@author Gianluca Moreira
@since 06/09/2019
@version 1.0
@return lRet, Enviou e-mail com sucesso
@param aPara, array, destinatários
@param aCopia, array, Copias
@param aCopiaOc, array, Copias ocultas
@param cAssunto, characters, Assunto do e-mail
@param cCorpo, characters, corpo do email
@param lExibeHelp, logical, Indica se exibe os helps - Adicionado para evitar erros quando vier de ExecAuto antigas
@type function
/*/
User Function F20005EM(aPara, aCopia, aCopiaOc, cAssunto, cCorpo, lExibeHelp)
	Local cSMTPServer := GetMv("MV_RELSERV",,'')
	Local cSMTPUser	  := GetMv("MV_RELACNT",,'')
	Local cSMTPPass	  := GetMv("MV_RELPSW",,'')
	Local cMailFrom	  := GetMv("MV_RELFROM",,'')
	Local cUserAcnt   := GetMv('MV_RELAUSR',,'')
	Local cUserPass   := GetMv('MV_RELAPSW',,'')
	Local lUseAuth	  := GetMv("MV_RELAUTH") 
	Local lUseTLSMail := GetMv('MV_RELTLS')
	Local lUseSSLMail := GetMv('MV_RELSSL')
	Local nTimeOut    := IIf(Empty(GetMv("MV_RELTIME",,120)), 120, GetMv("MV_RELTIME",,120)) 

	Local lRet        := .T.
	Local cMsgPro     := ''
	Local cMsgSol     := ''
	Local cErro       := ''

	Local nI          := 0
	Local nTries      := 0
	Local nX		  := 0

	Default aCopia := {}
	Default aCopiaOc := {}
	Default lExibeHelp := .T.

	If Empty(cSMTPServer)
		lRet := .F.
		If lExibeHelp
			cMsgPro := 'Servidor SMTP não encontrado'
			cMsgSol := 'Preencha o parâmetro MV_RELSERV com o servidor SMTP que será utilizado para envio dos e-mails.'
			Help( Nil, Nil, 'E-MAIL', Nil, cMsgPro, 1, 0, Nil, Nil, Nil, Nil, Nil, {cMsgSol})
		EndIf
		Return lRet
	EndIf
	If Empty(cSMTPUser)
		lRet := .F.
		If lExibeHelp
			cMsgPro := 'Conta do Servidor SMTP de e-mail não encontrado'
			cMsgSol := 'Preencha o parâmetro MV_RELACNT com a conta de usuário que será utilizado para envio dos e-mails.'
			Help( Nil, Nil, 'E-MAIL', Nil, cMsgPro, 1, 0, Nil, Nil, Nil, Nil, Nil, {cMsgSol})
		EndIf
		Return lRet
	EndIf
	If Empty(cSMTPPass)
		lRet := .F.
		If lExibeHelp
			cMsgPro := 'Senha do Servidor SMTP de e-mail não encontrada'
			cMsgSol := 'Preencha o parâmetro MV_RELPSW com senha da conta de usuário '+cSMTPUser+' que será utilizado para envio dos e-mails.'
			Help( Nil, Nil, 'E-MAIL', Nil, cMsgPro, 1, 0, Nil, Nil, Nil, Nil, Nil, {cMsgSol})
		EndIf
		Return lRet
	EndIf
	If Empty(cMailFrom)
		lRet := .F.
		If lExibeHelp
			cMsgPro := 'Remetente não encontrado'
			cMsgSol := 'Preencha o parâmetro MV_RELFROM com o e-mail de rementente que será utilizado para envio dos e-mails.'
			Help( Nil, Nil, 'E-MAIL', Nil, cMsgPro, 1, 0, Nil, Nil, Nil, Nil, Nil, {cMsgSol})
		EndIf
		Return lRet
	EndIf
	If lUseAuth
		If Empty(cUserAcnt)
			lRet := .F.
			If lExibeHelp
				cMsgPro := 'O Servidor de E-mail utilizado exige autenticação, mas a conta de autenticação não foi preenchida.'
				cMsgSol := 'Caso o servidor não exija autenticação, desative o parâmetro MV_RELAUTH. Caso ele exija, preencha '
				cMsgSol += 'o parâmetro MV_RELAUSR com a conta de autenticação.'
				Help( Nil, Nil, 'E-MAIL', Nil, cMsgPro, 1, 0, Nil, Nil, Nil, Nil, Nil, {cMsgSol})
			EndIf
			Return lRet
		EndIf
		If Empty(cUserPass)
			lRet := .F.
			If lExibeHelp
				cMsgPro := 'O Servidor de E-mail utilizado exige autenticação, mas a senha de autenticação não foi preenchida.'
				cMsgSol := 'Caso o servidor não exija autenticação, desative o parâmetro MV_RELAUTH. Caso ele exija, preencha '
				cMsgSol += 'o parâmetro MV_RELAPSW com a senha de autenticação.'
				Help( Nil, Nil, 'E-MAIL', Nil, cMsgPro, 1, 0, Nil, Nil, Nil, Nil, Nil, {cMsgSol})
			EndIf
			Return lRet
		EndIf
	EndIf
	If Empty(aPara)
		lRet := .F.
		If lExibeHelp
			cMsgPro := 'Destinatário não encontrado. CallStack:'
			For nI := 1 To 10
				cMsgPro += CRLF+ProcName(nI)+' - Linha: ('+cValToChar(ProcLine(nI))+')'
			Next nI
			cMsgSol := 'Verifique se existe parâmetro que preenche o destinatário da mensagem, de acordo com a rotina que está executando.'
			Help( Nil, Nil, 'E-MAIL', Nil, cMsgPro, 1, 0)
		EndIf
		Return lRet
	EndIf

	//Trata C->A
	If ValType(aPara) == 'C'
		aPara := StrTokArr(aPara, ';')
	EndIf
	If ValType(aCopia) == 'C'
		aCopia := StrTokArr(aCopia, ';')
	EndIf
	If ValType(aCopiaOc) == 'C'
		aCopiaOc := StrTokArr(aCopiaOc, ';')
	EndIf

	For nX := 1 To Len(aPara)
		lRet := IsEmail(aPara[nX]) //Verifica se os e-mails são Válidos
		If !lRet
			Exit
		Endif
	Next nX
	If !lRet
		Return lRet
	EndIf

	For nX := 1 To Len(aCopia)
		lRet := IsEmail(aCopia[nX]) //Verifica se os e-mails são Válidos
		If !lRet
			Exit
		Endif
	Next nX
	If !lRet
		aCopia := {}
	EndIf

	For nX := 1 To Len(aCopiaOc)
		lRet := IsEmail(aCopiaOc[nX]) //Verifica se os e-mails são Válidos
		If !lRet
			Exit
		Endif
	Next nX
	If !lRet
		aCopiaOc := {}
	EndIf

	//Conecta
	For nTries := 0 To 5
		If lRet := MailSmtpOn( cSMTPServer, cSMTPUser, cSMTPPass, nTimeOut, lUseTLSMail, lUseSSLMail )
			Exit
		EndIf
	Next nTries

	//Sleep(500)
	If !lRet
		cErro := cValToChar(MailGetNumErr())+' - '+MailGetErr()
		cMsgPro := 'Erro ao Conectar ao Servidor SMTP: '+CRLF+cErro+'.'
	EndIf

	//Autentica
	If lRet
		If lUseAuth
			For nTries := 0 To 5
				If lRet := MailAuth(cUserAcnt, cUserPass)
					Exit
				EndIf
			Next nTries
			If !lRet
				cErro := cValToChar(MailGetNumErr())+' - '+MailGetErr()
				cMsgPro := 'Erro na autenticação do usuário de envio de e-mail.'+CRLF+cErro+'.'
				cMsgSol := 'Verifique os parâmetros MV_RELACNT, MV_RELPSW e MV_RELAUTH.'
			EndIf
		EndIf
	EndIf

	//Envia
	If lRet
		For nTries := 0 To 5
			If lRet := MailSend(cMailFrom, aPara, aCopia, aCopiaOc, cAssunto, cCorpo, {}, .F., lUseTLSMail, lUseSSLMail )
				Exit
			EndIf
		Next nTries
		If !lRet
			cErro := cValToChar(MailGetNumErr())+' - '+MailGetErr()
			cMsgPro := 'Erro ao enviar E-Mail: '+CRLF+cErro+'.'
		EndIf
	EndIf

	//Desconecta
	If lRet
		lRet := MailSmtpOff()
		If !lRet
			cErro := cValToChar(MailGetNumErr())+' - '+MailGetErr()
			cMsgPro := 'Erro ao desconectar do servidor de E-Mail: '+CRLF+cErro+'.'
		EndIf
	EndIf

	If !lRet .And. lExibeHelp
		Help( Nil, Nil, 'E-MAIL', Nil, cMsgPro, 1, 0, Nil, Nil, Nil, Nil, Nil, {cMsgSol})
	EndIf

Return lRet


/*/{Protheus.doc} FormHTML

Formata HTML

@type function
@version  
@author fabio.cazarini
@since 25/06/2021
@param cTitulo, character, título 
@param cCorpo1, character, corpo antes tabela
@param aTable, array, tabela
@param cCorpo2, character, corpo pos tabela
@return character, HTML formatado
/*/
Static Function FormHTML(cTitulo, cCorpo1, aTable, cCorpo2)
    Local cHTML     := ""
    Local nTable    := 1

    Default cTitulo := ""
    Default cCorpo1 := ""
    Default aTable  := {}
    Default cCorpo2 := ""

	cHTML := "<html>"
	cHTML += "<head>"
    If !Empty(cTitulo)
	    cHTML += "<title>" + cTitulo + "</title>"
    Endif
	cHTML += "</head>"
	cHTML += "<body>" 
	cHTML += "<article>"
    If !Empty(cCorpo1)
    	cHTML += "<br><p style='font-size: 20px'>" + cCorpo1 + "</p>"	
    Endif
    If Len(aTable) > 0
        cHTML += "<br><table border='0'>"
        For nTable := 1 To Len(aTable)
            cHTML += "<tr>"
            cHTML += "<td>" + aTable[nTable, 1] + "</td>"
            cHTML += "<td>" + aTable[nTable, 2] + "</td>"
            cHTML += "</tr>"
        Next nTable
        cHTML += "</table>"
    Endif
    If !Empty(cCorpo2)
    	cHTML += "<br><p style='font-size: 10px'>" + cCorpo2 + "</p>"	
    Endif
	cHTML += "</body>"
	cHTML += "</html>"

Return cHTML
