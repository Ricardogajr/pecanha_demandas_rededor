#Include 'Protheus.ch'
/*
{Protheus.doc} F0200302()
Função de criação de corpo de e-mail
@Author     Henrique Madureira
@Since      30/06/2016
@Version    P12.7
@Project    MAN00000463301_EF_003
@param nSolicit, numeric, descricao
@param cMatricu, characters, descricao
@param cNome, characters, descricao
@param cTreina, characters, descricao
@param cCurso, characters, descricao
@param cTurma, characters, descricao
@param cFilApr, characters, descricao
@Return
*/
User Function F0200302(nSolicit,cMatricu,cNome, cTreina, cCurso, cTurma, cFilApr)
	
	Local oWs
	Local cEmail 	:= ''
	Local aAux 	:= {}
	
	Default nSolicit := 0
	Default cMatricu := ''
	Default cNome    := ''
	Default cTreina  := ''
	Default cCurso   := ''
	Default cTurma   := ''
	
	If FWIsInCallStack("U_F0200303")
		aAux := U_F0200305(cFilApr,cMatricu, cTreina, cCurso, cTurma)
		If ValType(aAux) != 'U'
			If EMPTY(cNome)
				cNome  	:= ALLTRIM(aAux[1])
			EndIf
			cEmail 	:= aAux[2]
			cTreina 	:= ALLTRIM(aAux[3])
		EndIf
	Else
		oWs := WSW0200301():new()
		WsChgURL(@oWs,"W0200301.APW")
		If oWs:CRIAENTRE(cFilApr,cMatricu, cTreina, cCurso, cTurma)
			cEmail     := oWs:oWSCRIAENTRERESULT:cEMAIL
			cTreina    := ALLTRIM(oWs:oWSCRIAENTRERESULT:cTreina)
			If EMPTY(cNome)
				cNome	    := ALLTRIM(oWs:oWSCRIAENTRERESULT:cNome)
			EndIf
		EndIf
	EndIf
	If cEmail != ''
		
		DO CASE
		CASE nSolicit == 1
			SendSoct(cTreina, ALLTRIM(cNome), cEmail)
		CASE nSolicit == 2
			RetrSoct(cTreina, ALLTRIM(cNome), cEmail)
		CASE nSolicit == 3
			RetrNeg(cTreina, ALLTRIM(cNome), cEmail)
		CASE nSolicit == 4
			SendInce(ALLTRIM(cNome), cEmail)
		CASE nSolicit == 5
			InceApr( ALLTRIM(cNome), cEmail)
		CASE nSolicit == 6
			InceRpr(ALLTRIM(cNome), cEmail)
		OTHERWISE
			conout("Operação invalida")
		ENDCASE
	EndIf
	
Return nil

//=========================================================================================================================================
/*
{Protheus.doc} SendSoct()

@Author     Henrique Madureira
@Since      30/06/2016
@Version    P12.7
@Project    MAN00000463301_EF_003
@Param		 cTreina
@param		 cNome
@param		 cEmail
@Return
*/
Static Function SendSoct(cTreina, cNome, cEmail)
	
	Local cBody 		:= ""
	Local cAssunto 	:= ""
	Local oWs
	
	cAssunto 	:= "Solicitação de Aprovação para Treinamento"
	
	cBody := '<html><body><pre>' + CRLF
	cBody += '<b>Prezado,</b>' + CRLF
	cBody += "Segue solicitação de aprovação para treinamento '" + cTreina + "'"
	cBody += " para o colaborador '" + cNome + "'."
	cBody += "Favor efetuar a aprovação ou reprovação no Portal de RH."
	cBody += '</pre></body></html>'
	
	// Envia o e-mail
	SendEm(cAssunto,cBody,cEmail)
	
Return

//=========================================================================================================================================
/*
{Protheus.doc} RetrSoct()

@Author     Henrique Madureira
@Since      30/06/2016
@Version    P12.7
@Project    MAN00000463301_EF_003
@Param		 cTreina
@param		 cNome
@param		 cEmail
@Return
*/
Static Function RetrSoct(cTreina, cNome, cEmail)
	
	Local cBody 		:= ""
	Local cAssunto 	:= ""
	
	cAssunto 	:= "Retorno Solicitação de Aprovação para Treinamento"
	
	cBody := '<html><body><pre>' + CRLF
	cBody += '<b>Prezado,</b>' + CRLF
	cBody += "O treinamento '" + cTreina + "' "
	cBody += "solicitado para o colaborador '" + cNome + "' foi aprovado. "
	cBody += "Para maiores informações, procure o RH da sua Unidade"
	cBody += '</pre></body></html>'
	// Envia o e-mail
	SendEm(cAssunto,cBody,cEmail)
	
Return

//=========================================================================================================================================
/*
{Protheus.doc} RetrNeg()

@Author     Henrique Madureira
@Since      30/06/2016
@Version    P12.7
@Project    MAN00000463301_EF_003
@Param		 cTreina
@param		 cNome
@param		 cEmail
@Return
*/
Static Function RetrNeg(cTreina, cNome,cEmail)
	
	Local cBody 		:= ""
	Local cAssunto 	:= ""
	
	cAssunto 	:= "Retorno Solicitação 'Reprovada'"
	
	cBody := '<html><body><pre>' + CRLF
	cBody += '<b>Prezado,</b>' + CRLF
	cBody += "O treinamento '" + cTreina + "' "
	cBody += "solicitado para o colaborador '" + cNome + "' foi reprovado. "
	cBody += "Para maiores informações, procure o RH da sua Unidade"
	cBody += '</pre></body></html>'
	// Envia o e-mail
	SendEm(cAssunto,cBody,cEmail)
	
Return

//=========================================================================================================================================
/*
{Protheus.doc} SendInce()

@Author     Henrique Madureira
@Since      30/06/2016
@Version    P12.7
@Project    MAN00000463301_EF_003
@param		 cNome
@param		 cEmail
@Return
*/
Static Function SendInce(cNome,cEmail)
	
	Local cBody 		:= ""
	Local cAssunto 	:= ""
	
	cAssunto 	:= "Solicitação Incentivo à Educação"
	
	cBody := '<html><body><pre>' + CRLF
	cBody += '<b>Prezado,</b>' + CRLF
	cBody += "Segue solicitação de aprovação para Incentivo à "
	cBody += "Educação para o colaborador '" + cNome + "'."
	cBody += "Favor efetuar a aprovação ou reprovação no Portal de RH."
	cBody += '</pre></body></html>'
	
	// Envia o e-mail
	SendEm(cAssunto,cBody,cEmail)
	
	
Return

//=========================================================================================================================================
/*
{Protheus.doc} InceApr()

@Author     Henrique Madureira
@Since      30/06/2016
@Version    P12.7
@Project    MAN00000463301_EF_003
@param		 cNome
@param		 cEmail
@Return
*/
Static Function InceApr( cNome,cEmail)
	
	Local cBody 		:= ""
	Local cAssunto 	:= ""
	
	cAssunto 	:= "Incentivo à Educação 'Aprovado'"
	
	cBody := '<html><body><pre>' + CRLF
	cBody += '<b>Prezado,</b>' + CRLF
	cBody += "A Solicitação de Incentivo à Educação "
	cBody += "solicitado para o colaborador '" + cNome + "' foi aprovado. "
	cBody += "Para maiores informações, procure o RH da sua Unidade"
	cBody += '</pre></body></html>'
	
	// Envia o e-mail
	SendEm(cAssunto,cBody,cEmail)
	
Return

//=========================================================================================================================================
/*
{Protheus.doc} InceRpr()

@Author     Henrique Madureira
@Since      30/06/2016
@Version    P12.7
@Project    MAN00000463301_EF_003
@param		 cNome
@param		 cEmail
@Return
*/
Static Function InceRpr(cNome,cEmail)
	
	Local cBody 		:= ""
	Local cAssunto 	:= ""
	
	cAssunto 	:= "Incentivo à Educação 'Reprovado'"
	
	cBody := '<html><body><pre>' + CRLF
	cBody += '<b>Prezado,</b>' + CRLF
	cBody += "Prezado gestor, a Solicitação de Incentivo à Educação "
	cBody += "solicitado para o colaborador '" + cNome + "' foi reprovado. "
	cBody += "Para maiores informações, procure o RH da sua Unidade"
	cBody += '</pre></body></html>'
	// Envia o e-mail
	SendEm(cAssunto,cBody,cEmail)
	
Return

//=========================================================================================================================================
/*
{Protheus.doc} SendEm()

@Author     Henrique Madureira
@Since      30/06/2016
@Version    P12.7
@Project    MAN00000463301_EF_003
@Param		 cAssunto
@param		 cBody
@param		 cEmail
@Return
*/
Static Function SendEm(cAssunto,cBody,cEmail)
	
	Local oWs
	
	If FWIsInCallStack("U_F0200303")
		U_F0200304(cAssunto, cBody, cEmail)
	Else
		// Envia o e-mail
		oWs := WSW0200301():new()
		WsChgURL(@oWs,"W0200301.apw")
		oWs:PARAMENTRE(cAssunto,cBody,cEmail)
	EndIf
	
Return
