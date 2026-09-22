#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"

/*
{Protheus.doc} F0101004()
Envia email de  notificação da recusa ao responsável.
@Author     Paulo Krüger
@Since      18/01/2017
@Version    P12.7
@param cFilOri, characters, descricao
@param cNumTit, characters, descricao
@param cTipo, characters, descricao
@param cParcela, characters, descricao
@param cPrefixo, characters, descricao
@param nValor, numeric, descricao
@param dVencrea, date, descricao
@param cFornece, characters, descricao
@param cNomFor, characters, descricao
@param cCodEmit, characters, descricao
@param cNomEmit, characters, descricao
@param cCodRecu, characters, descricao
@param cNomRecu, characters, descricao
@param cMotivo, characters, descricao
@param dData, date, descricao
@param cOrigem, characters, descricao
@param cEmailEmit, characters, descricao
@Project    MAN00000462901_EF_010
*/
// ticket n° 8096124 - passagem parâmetro filial
User Function F0101004(cGet00,cNumTit,cTipo,cParcela,cPrefixo,nValor,dVencrea,cFornece,cNomFor,cCodEmit,cNomEmit,cCodRecu,cNomRecu,cMotivo,dData,cOrigem,cEmailEmit,lRecAuto)

	Local cHtml		:= ''
	Local cAlert	:= ''
	Local cError	:= ''
	Local cServer := Trim(GetMV("MV_RELSERV")) // smtp.ig.com.br ou 200.181.100.51
	Local cEmail  := Trim(GetMV("MV_RELACNT")) // fulano@ig.com.br
	Local cPass   := Trim(GetMV("MV_RELPSW"))  // 123abc
	Local lResulConn := .F.
	Local lResulSend := .F.
	Local cTituloEmail := "Recusa de Título"
	Local cNomFil  := RetField('SM0',1,cEmpAnt+cGet00,'M0_FILIAL') // ticket n° 8096124
//Default cEmailEmit := Trim(GetMv("FS_MAILREC"))
	local cEmailPar := SUPERGETMV("FS_MAILREC",.T., "ramon.silva@totvspartners.com.br")

	Default lRecAuto  := .F.

	If IsInCallStack("U_F010101PCANCELARECUSA") .Or. IsInCallStack("U_F010101P")
		cTituloEmail := "Cancelamento de Recusa de Documento"
	ElseIf IsInCallStack("MATA103") .Or. IsInCallStack("U_F0100401")
		cTituloEmail := "Recusa de Documento"
	Endif

	cHtml := '<html>'
	cHtml += '<head>'
	cHtml += '<title>Notifica&ccedil;&atilde;o de ' +Alltrim(cTituloEmail)+ '</title>'
	cHtml += '</head>'
	cHtml += '<body>'
	cHtml += '<div>'
	cHtml += '<table align="left" border="0" cellpadding="1" cellspacing="1" style="width: 800px">'
	cHtml += '<tbody>'
	cHtml += '<tr>'
	cHtml += '<td>'
	cHtml += '<p>'
	cHtml += '<strong><span style="font-family:arial,helvetica,sans-serif;">Recusa de T&iacute;tulo a Pagar</span></strong></p>'
	cHtml += '</td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td>'
	cHtml += '<table border="0" cellpadding="1" cellspacing="1" style="width: 799px">'
	cHtml += '<tbody>'
	cHtml += '<tr>'
	cHtml += '<td>'
	cHtml += '<strong><span style="font-size:12px;"><span style="font-family:arial,helvetica,sans-serif;">T&iacute;tulo</span></span></strong></td>'
	cHtml += '<td>'
	cHtml += '<span style="font-size:12px;"><span style="font-family:arial,helvetica,sans-serif;"> ' + cNumTit + '</span></span></td>'
	cHtml += '<td>'
	cHtml += '<strong><span style="font-size:12px;"><span style="font-family:arial,helvetica,sans-serif;">Filial</span></span></strong></td>' //paulo
	cHtml += '<td>'
	cHtml += '<span style="font-size:12px;"><span style="font-family:arial,helvetica,sans-serif;"> ' + cGet00 + '</span></span></td>' //paulo
	cHtml += '<td>'
	cHtml += '<strong><span style="font-size:12px;"><span style="font-family:arial,helvetica,sans-serif;">Nome da filial</span></span></strong></td>' //paulo
	cHtml += '<td>'
	cHtml += '<span style="font-size:12px;"><span style="font-family:arial,helvetica,sans-serif;"> ' + cNomFil + '</span></span></td>' //paulo
	cHtml += '<td>'
	cHtml += '<strong><span style="font-size:12px;"><span style="font-family:arial,helvetica,sans-serif;">Tipo</span></span></strong></td>'
	cHtml += '<td>'
	cHtml += '<span style="font-size:12px;"><span style="font-family:arial,helvetica,sans-serif;"> ' + cTipo + '</span></span></td>'
	cHtml += '<td>'
	cHtml += '<strong><span style="font-size:12px;"><span style="font-family:arial,helvetica,sans-serif;">Parcela</span></span></strong></td>'
	cHtml += '<td>'
	cHtml += '<span style="font-size:12px;"><span style="font-family:arial,helvetica,sans-serif;">' + cParcela + '</span></span></td>'
	cHtml += '<td>'
	cHtml += '<strong><span style="font-size:12px;"><span style="font-family:arial,helvetica,sans-serif;">Valor</span></span></strong></td>'
	cHtml += '<td>'
	cHtml += '<span style="font-size:12px;"><span style="font-family:arial,helvetica,sans-serif;">' + LTrim(Transform(nValor,"@E 999,999,999.99")) + '</span></span></td>'
	cHtml += '<td>'
	cHtml += '<strong><span style="font-size:12px;"><span style="font-family:arial,helvetica,sans-serif;">Vencimento</span></span></strong></td>'
	cHtml += '<td>'
	cHtml += '<span style="font-size:12px;"><span style="font-family:arial,helvetica,sans-serif;">' + DTOC(dVencrea) + '</span></span></td>'
	cHtml += '</tr>'
	cHtml += '</tbody>'
	cHtml += '</table>'
	cHtml += '<table border="0" cellpadding="1" cellspacing="1" style="width: 799px">'
	cHtml += '<tbody>'
	cHtml += '<tr>'
	cHtml += '<td>'
	cHtml += '<strong><span style="font-family:arial,helvetica,sans-serif;"><span style="font-size:12px;">Fornecedor</span></span></strong></td>'
	cHtml += '<td>'
	cHtml += '<span style="font-family:arial,helvetica,sans-serif;"><span style="font-size:12px;">' + cFornece + '</span></span></td>'
	cHtml += '<td>'
	cHtml += '<span style="font-family:arial,helvetica,sans-serif;"><span style="font-size:12px;">' + cNomFor  + '</span></span></td>'
	cHtml += '</tr>'
	cHtml += '</tbody>'
	cHtml += '</table>'
	cHtml += '<p>'
	cHtml += '&nbsp;</p>'
	cHtml += '</td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td>'
	cHtml += '<table border="0" cellpadding="1" cellspacing="1" style="width: 799px">'
	cHtml += '<tbody>'
	cHtml += '<tr>'
	cHtml += '<td>'
	cHtml += '<strong><span style="font-family:arial,helvetica,sans-serif;"><span style="font-size:12px;">Emitente</span></span></strong></td>'
	cHtml += '<td>'
	cHtml += '<span style="font-family:arial,helvetica,sans-serif;"><span style="font-size:12px;">' + cCodEmit + '</span></span></td>'
	cHtml += '<td>'
	cHtml += '<span style="font-family:arial,helvetica,sans-serif;"><span style="font-size:12px;">' + cNomEmit + '</span></span></td>'
	cHtml += '</tr>'
	cHtml += '</tbody>'
	cHtml += '</table>'
	cHtml += '<p>'
	cHtml += '&nbsp;</p>'
	cHtml += '</td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td>'
	cHtml += '<table border="0" cellpadding="1" cellspacing="1" style="width: 799px">'
	cHtml += '<tbody>'
	cHtml += '<tr>'
	cHtml += '<td>'
	cHtml += '<strong><span style="font-family:arial,helvetica,sans-serif;"><span style="font-size:12px;">Recusante</span></span></strong></td>'
	cHtml += '<td>'
	If AllTrim(GetNewPar("FS_CONTREC","")) == ""
		cHtml += '<span style="font-family:arial,helvetica,sans-serif;"><span style="font-size:12px;">' + cCodRecu + '</span></span></td>'
		cHtml += '<td>'
		cHtml += '<span style="font-family:arial,helvetica,sans-serif;"><span style="font-size:12px;">' + cNomRecu + '</span></span></td>'
	Else
		cHtml += '<span style="font-family:arial,helvetica,sans-serif;"><span style="font-size:12px;">' + AllTrim(GetNewPar("FS_CONTREC"))  + '</span></span></td>'
	EndIf
	cHtml += '</tr>'
	cHtml += '</tbody>'
	cHtml += '</table>'
	cHtml += '<p>'
	cHtml += '&nbsp;</p>'
	cHtml += '</td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td>'
	cHtml += '<table align="left" border="0" cellpadding="1" cellspacing="1" style="width: 799px">'
	cHtml += '<tbody>'
	cHtml += '<tr>'
	cHtml += '<td>'
	cHtml += '<strong><span style="font-family:arial,helvetica,sans-serif;"><span style="font-size:12px;">Motivo</span></span></strong></td>'
	cHtml += '<td>'
	cHtml += '<span style="font-family:arial,helvetica,sans-serif;"><textarea style="margin: 0px; width: 785px; height: 89px;">' + cMotivo + '</textarea></span></td>'
	cHtml += '</tr>'
	cHtml += '</tbody>'
	cHtml += '</table>'
	cHtml += '<p>'
	cHtml += '&nbsp;</p>'
	cHtml += '</td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td>'
	cHtml += '&nbsp;</td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td>'
	cHtml += '&nbsp;</td>'
	cHtml += '</tr>'
	cHtml += '</tbody>'
	cHtml += '</table>'
	cHtml += '<p>'
	cHtml += '&nbsp;</p>'
	cHtml += '</div>'
	cHtml += '<div style="text-align: center;">'
	cHtml += '<p>'
	cHtml += '&nbsp;</p>'
	cHtml += '</div>'
	cHtml += '<p>'
	cHtml += '&nbsp;</p>'
	cHtml += '</body>'
	cHtml += '</html>'

	CONNECT SMTP SERVER cServer ACCOUNT cEmail PASSWORD cPass RESULT lResulConn
	if lResulConn
		SEND MAIL FROM cEmail TO iIf(alltrim(cEmailEmit)="",cEmailPar,cEmailEmit) SUBJECT cTituloEmail BODY cHtml RESULT lResulSend

		If lResulSend
			cAlert:= "Email enviado"
		Else
			GET MAIL ERROR cError
			cAlert:= 'Falha no Envio do e-mail.' + cError
		Endif
		if !lRecAuto
			MsgAlert(cAlert)
		endif
	else
		MsgAlert("Erro na conexão SMTP. Recusa não será gravada. Favor, entrar em contato com suporte.")
	endif

Return lResulSend
