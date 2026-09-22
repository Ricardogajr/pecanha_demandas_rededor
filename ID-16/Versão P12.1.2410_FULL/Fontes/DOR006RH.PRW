#INCLUDE "PROTHEUS.CH"              
#INCLUDE "TBICODE.CH"                 
#INCLUDE "TBICONN.CH"               
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH"                    
#INCLUDE "AP5MAIL.CH"  
#INCLUDE "XMLXFUN.CH"
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROJETO CONECTA REDE D´OR    |  MODULO | SIGAGPE                            |//
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | DOR006RH | AUTOR | Edsonho ®                | DATA | 11/06/2017 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | Função: Envio de email informativo ao Superior do Colaborador   |//
//|                     Participação de Vagas Internas                          |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
User Function DOR006RH(cFilSolic,cCodSolic)

	Local cTituloXML  := ""
	Local nSMTPPort 	:= GetMV("MV_GCPPORT",, 25)	// PORTA SMTP
	Local nSMTPTime:= 200
	Local cCorpoXML   := ""
	Public nRecEmail  := 0
	Public cTmp_Desc  := ""
	Public cTmp_Filial:= ""
	Public cTmp_Dscfil:= ""
	Public cCrLf      := Chr(13)+Chr(10)
	//---------------------------------------------------------------------------------------------------------------------------------------------------------------
	Private _cServer   := SUPERGETMV("MV_RELSERV") // 10.250.0.224:587          ==> Configuracao do SMTP do E-Mail
	Private _cConta    := SUPERGETMV("MV_RELACNT") // protheus12@rededor.com.br ==> Conta de e-mail
	Private _cPass     := SUPERGETMV("MV_RELPSW")  // Ropi%45H@                 ==> Senha do e-Mail
	Private _cRemet    := SUPERGETMV("MV_RELACNT") // protheus12@rededor.com.br ==> Conta de e-mail
	Private _cDestino  := ""
	Private _cSubject  := "Inscrição de Colaborador em vaga interna: "
	Private lConexao   := .F.
	Private cAnexo     := ""
	Private lEnvio     := .F.
	Private cBcc       := ""
	//---------------------------------------------------------------------------------------------------------------------------------------------------------------

	DOR006RH1(cFilSolic,cCodSolic)

	If nRecEmail > 0

		cTituloXML:= "Rede D'Or | Inscrição em Vaga Interna"

		DbSelectArea("TMPEMAIL")
		TMPEMAIL->(DbGoTop())

		DOR006RH2(TMPEMAIL->RH3_FILINI,TMPEMAIL->RH3_CODIGO)

		DbSelectArea("TMPEMAIL")
		While TMPEMAIL->(!Eof())

			cCorpoXML := ''
			cCorpoXML += '<table width="80%" align="center">'
			cCorpoXML += '	<tr><td align="center" colspan=2><font size=2><b>Matrícula: '+Alltrim(TMPEMAIL->RA_MAT)+'</b></a></font></td></tr>'
			cCorpoXML += '	<tr><td align="center" colspan=2><font size=2><b>Colaborador: '+Alltrim(TMPEMAIL->RA_NOME)+'</b></a></font></td></tr>'
			cCorpoXML += '	<tr><td align="center" colspan=2><font size=2><b>Cargo da Vaga: '+Alltrim(cTmp_Desc)+'</b></a></font></td></tr>'
			cCorpoXML += '	<tr><td align="center" colspan=2><font size=2><b>Filial da Vaga: '+Alltrim(cTmp_Filial)+" - "+Alltrim(cTmp_Dscfil)+'</b></a></font></td></tr>'
			cCorpoXML += '	<tr><td align="center" colspan=2><font size=2>Seu colaborador se inscreveu em uma vaga interna na Rede D’Or</a></font></td></tr>'
			cCorpoXML += '	<tr><td align="center" colspan=2><font size=2>Data da inscrição: '+Dtoc(dDatabase)+' às '+Time()+'</a></font></td></tr>'
			cCorpoXML += '</table>'

			cCorpoXML := DOR006RH3(cTituloXML,cCorpoXML,"CENTER")

			_cDestino := Alltrim(TMPEMAIL->XRA_EMAIL)

			
				//         Connect Smtp SERVER _cServer ACCOUNT _cConta PASSWORD _cPass RESULT lConexao
				//         lConexao := MailAuth(_cConta,_cPass)
				oServer := tMailManager():New()


				nErr := oServer:init("",_cServer, _cConta,_cPass,,nSMTPPort)
				If nErr <> 0	
					alert("Falha ao conectar:" + oServer:getErrorString(nErr)) // Falha ao conectar: 	

				Endif


				If oServer:SetSMTPTimeout(nSMTPTime) != 0
					alert("Falha ao definir timeout") // Falha ao definir timeout

				EndIf


				nErr := oServer:smtpConnect()
				If nErr <> 0	
					alert("Falha ao conectar:" + oServer:getErrorString(nErr)) // Falha ao conectar:		
					oServer:SMTPDisconnect()

				EndIf

				nErr := oServer:smtpAuth(_cConta,_cPass)
				If nErr <> 0		
					alert("Falha ao autenticar: " + oServer:getErrorString(nErr)) // Falha ao autenticar: 
					oServer:SMTPDisconnect() 
				EndIf




			

			//			Send Mail From _cConta TO _cDestino BCC cBcc SUBJECT _cSubject+Alltrim(TMPEMAIL->RA_NOME) BODY cCorpoXML FORMAT TEXT ATTACHMENT cAnexo RESULT lConexao
			//
			//			If !lConexao
			//				Get Mail Error cErrMail
			//				Conout("Erro no Envio " + cErrMail )
			//			EndIf                    
			// Cria uma nova mensagem (TMailMessage)
			oMessage := tMailMessage():new()
			oMessage:clear()        


			// Dados da mensagem		
			oMessage:cFrom		:= _cConta
			oMessage:cTo     	:=  _cDestino
			oMessage:cBcc    	:=  cBcc
			oMessage:cSubject	:= _cSubject+Alltrim(TMPEMAIL->RA_NOME)
			oMessage:cBody   	:= cCorpoXML
			oMessage:AttachFile(cAnexo)


			nErr := oMessage:send(oServer)
			If nErr <> 0		
				alert("Falha ao Enviar MSg: " + oServer:getErrorString(nErr)) // Falha ao autenticar: 
				oServer:SMTPDisconnect() 
			EndIf

			// Desconecta do Servidor
			oServer:smtpDisconnect() 

			DbSelectArea("TMPEMAIL")
			TMPEMAIL->(DbSkip())

		EndDo

	
endif


	If Select("TMPEMAIL") > 0
		DbSelectArea("TMPEMAIL")
		("TMPEMAIL")->(DbCloseArea())  
	Endif

Return
//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Converte o Texto Padrao para Email em HTML                                  |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function DOR006RH3(cTituloCNV,cCorpoXML,cPosicaoXML)

	Local cIniFile  := GetAdv97()
	Local cServer   := GetPvProfString("TopConnect","Server","ERROR",cInIfile )
	Local cTopServer:= GetSrvProfString("TopServer",cServer)
	Local cConType  := Upper(GetPvProfString("TopConnect","Contype","TCPIP",cInIfile ))
	Local cAmbiente := GetEnvServer()
	Local cCorXML   := "#003162"
	Local cCorpoCNV := ""

	If cPosicaoXML == Nil
		cPosicaoXML := "CENTER"
	Endif

	cCorpoCNV	:= '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'
	cCorpoCNV	+= '<HTML>'
	cCorpoCNV	+= '<HEAD>'
	cCorpoCNV	+= '<TITLE>Totvs - WorkFlow</TITLE>'
	cCorpoCNV	+= '<META NAME="GENERATOR" CONTENT="MAXs HTML Beauty++ ME">'
	cCorpoCNV	+= '</HEAD>'
	cCorpoCNV	+= '<BODY>'
	cCorpoCNV	+= '<TABLE WIDTH="100%" BGCOLOR="'+cCorXML+'">'
	cCorpoCNV	+= '<TR>'
	cCorpoCNV	+= '	<TD COLSPAN=2><CENTER><FONT FACE="Verdana" SIZE="+2" COLOR="#FFFFFF">'+cTituloCNV+'</FONT></CENTER></TD>'
	cCorpoCNV	+= '</TR>'

	cCorpoCNV	+= '<TR>'
	cCorpoCNV	+= '	<TD COLSPAN=2>'
	cCorpoCNV	+= '		<TABLE WIDTH="100%" BGCOLOR="#FFFFFF">'
	cCorpoCNV	+= '		<TR><TD>&nbsp;</TD></TR>'
	cCorpoCNV	+= '		<TR>'
	cCorpoCNV	+= '			<TD ALIGN=CENTER>'
	cCorpoCNV	+= '				<FONT FACE="Verdana" SIZE="-1" COLOR="#000000">'
	cCorpoCNV	+= '					<p align='+cPosicaoXML+'>'
	cCorpoCNV	+= '						'+cCorpoXML+''
	cCorpoCNV	+= '					</p>'
	cCorpoCNV	+= '				</FONT>'
	cCorpoCNV	+= '			</TD>'
	cCorpoCNV	+= '		</TR>'
	cCorpoCNV	+= '		<TR>'
	cCorpoCNV	+= '			<TD><CENTER>&nbsp;</CENTER></TD>'
	cCorpoCNV	+= '		</TR>'
	cCorpoCNV	+= '		</TABLE>'
	cCorpoCNV	+= '	</TD>'

	cCorpoCNV	+= '</TR>'
	cCorpoCNV	+= '<TR>'
	cCorpoCNV	+= '	<TD COLSPAN=2><CENTER>'
	cCorpoCNV	+= '		<FONT FACE="Verdana" SIZE="2" COLOR="#FF0000">'
	cCorpoCNV	+= '		<p><b>Atenção</b>'
	cCorpoCNV	+= '		</FONT>'
	cCorpoCNV	+= '		<FONT FACE="Verdana" SIZE="1" COLOR="#FFFFC1">'
	cCorpoCNV	+= '		<br>Este e-mail é gerado automaticamente pelo Protheus, favor não responder.'
	cCorpoCNV	+= '		</FONT></CENTER></TD>'
	cCorpoCNV	+= '</TR>'

	cCorpoCNV	+= '</TABLE>'
	cCorpoCNV	+= '</BODY>'
	cCorpoCNV	+= '</HTML>'

Return(cCorpoCNV)
//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Gera Query do email do Superior Imdiato                                     |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function DOR006RH1(cFilSolic,cCodSolic)

	Local cQuery := _cQuery := ""
	Local nRecVagas:= 0

	nRecEmail := 0

	cQuery += "Select Distinct"+cCrLf
	cQuery += " SRA.RA_FILIAL,"+cCrLf
	cQuery += " SRA.RA_MAT,"+cCrLf
	cQuery += " SRA.RA_NOME,"+cCrLf
	cQuery += " SRA.RA_POSTO,"+cCrLf
	cQuery += " RH3.RH3_MATINI,"+cCrLf
	cQuery += " RH3.RH3_VISAO,"+cCrLf
	cQuery += " RH3.RH3_ORIGEM,"+cCrLf
	cQuery += " RH3.RH3_FILINI,"+cCrLf 
	cQuery += " RH3.RH3_CODIGO,"+cCrLf 
	cQuery += " RH3.RH3_TIPO,"+cCrLf
	cQuery += " RD4.RD4_ITEM,"+cCrLf
	cQuery += " RD4.RD4_CODIDE,"+cCrLf
	cQuery += " RD4.RD4_DESC,"+cCrLf
	cQuery += " RD4.RD4_TREE,"+cCrLf
	cQuery += " XD4.RD4_FILIDE As XD4_FILDE,"+cCrLf
	cQuery += " XD4.RD4_CODIDE As XD4_CODIDE,"+cCrLf
	cQuery += " XD4.RD4_DESC As XD4_DESC,"+cCrLf
	cQuery += " RCX.RCX_FILFUN,"+cCrLf
	cQuery += " RCX.RCX_MATFUN,"+cCrLf
	cQuery += " XRA.RA_NOME As XRA_NOME,"+cCrLf
	cQuery += " XRA.RA_EMAIL As XRA_EMAIL "+cCrLf
	cQuery += "From "+RetSqlName("SRA")+" SRA "+cCrLf
	cQuery += "Inner Join "+RetSqlName("RD4")+" RD4 On "+cCrLf
	cQuery += " RD4.RD4_FILIDE = SRA.RA_FILIAL And "+cCrLf 
	cQuery += " RD4.RD4_CODIDE = SRA.RA_POSTO And "+cCrLf
	cQuery += " RD4.D_E_L_E_T_ = ' '  "+cCrLf
	cQuery += "Inner Join "+RetSqlName("RH3")+" RH3 On "+cCrLf
	cQuery += " RH3.RH3_FILIAL = RD4.RD4_FILIDE And "+cCrLf
	cQuery += " RH3.RH3_MATINI = SRA.RA_MAT And "+cCrLf
	cQuery += " RH3.RH3_VISAO  = RD4.RD4_CODIGO And "+cCrLf
	cQuery += " RH3.D_E_L_E_T_ = ' '  "+cCrLf
	cQuery += "Inner Join "+RetSqlName("RD4")+" XD4 On "+cCrLf
	cQuery += " RD4.RD4_FILIDE = XD4.RD4_FILIDE And "+cCrLf 
	cQuery += " RD4.RD4_TREE   = XD4.RD4_ITEM And "+cCrLf
	cQuery += " RD4.RD4_CODIGO = XD4.RD4_CODIGO And "+cCrLf
	cQuery += " XD4.D_E_L_E_T_ = ' '  "+cCrLf
	cQuery += "Inner Join "+RetSqlName("RCX")+" RCX On "+cCrLf
	cQuery += " XD4.RD4_FILIDE = RCX.RCX_FILIAL And "+cCrLf 
	cQuery += " XD4.RD4_CODIDE = RCX.RCX_POSTO And "+cCrLf
	cQuery += " RCX.D_E_L_E_T_ = ' '  "+cCrLf
	cQuery += "Inner Join "+RetSqlName("SRA")+" XRA On "+cCrLf
	cQuery += " RCX.RCX_FILFUN = XRA.RA_FILIAL And "+cCrLf
	cQuery += " RCX.RCX_MATFUN = XRA.RA_MAT And "+cCrLf
	cQuery += " XRA.RA_SITFOLH <> 'D' And "+cCrLf
	cQuery += " XRA.RA_EMAIL <> '' And "+cCrLf
	cQuery += " XRA.D_E_L_E_T_ = ' '  "+cCrLf
	cQuery += "Where SRA.D_E_L_E_T_ = ' '  And SRA.RA_SITFOLH <> 'D' And "+cCrLf 
	cQuery += " SRA.RA_FILIAL = '"+cFilSolic+"' And "+cCrLf 
	cQuery += " SRA.RA_MAT    = '"+cCodSolic+"' "+cCrLf 
	cQuery += "Order By SRA.RA_FILIAL,SRA.RA_MAT,RCX.RCX_FILFUN,RCX.RCX_MATFUN"

	//MemoWrite("C:\TOTVS_Projects\Projetos\PROTHEUS_RedeDOR\RedeDOR\Query\TMPEMAIL.SQL",cQuery)

	_cQuery := ChangeQuery(cQuery)

	If Select("TMPEMAIL") > 0
		DbSelectArea("TMPEMAIL")
		("TMPEMAIL")->(DbCloseArea())  
	Endif

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery),"TMPEMAIL", .F., .T.)

	DbSelectArea("TMPEMAIL")
	TMPEMAIL->(DbGoTop())
	Count To nRecEmail

Return
//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Gera Query da Vaga do Candidato                                             |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function DOR006RH2(cFilVaga,cCodVaga)

	Local cQuery  := _cQuery := ""
	Local nRecVaga:= 0

	aVagas := {}

	cQuery += "Select Distinct"+cCrLf
	cQuery += " RH3.RH3_FILIAL,"+cCrLf
	cQuery += " RH3.RH3_FILINI,"+cCrLf
	cQuery += " RH3.RH3_MAT,"+cCrLf
	cQuery += " RH3.RH3_MATINI,"+cCrLf
	cQuery += " RH3.RH3_CODIGO As CODVAGA,"+cCrLf
	cQuery += " RH3.RH3_VISAO,"+cCrLf
	cQuery += " RH3.RH3_ORIGEM,"+cCrLf
	cQuery += " RH3.RH3_TIPO,"+cCrLf
	cQuery += " RH3.RH3_DTSOLI,"+cCrLf
	cQuery += " RH3.RH3_XVAGA,"+cCrLf
	cQuery += " RH4.RH4_ITEM,"+cCrLf
	cQuery += " RH4.RH4_CAMPO,"+cCrLf
	cQuery += " RH4.RH4_VALNOV "+cCrLf
	cQuery += "From "+RetSqlName("RH3")+" RH3 "+cCrLf
	cQuery += "Inner Join "+RetSqlName("RH4")+" RH4 On "+cCrLf
	cQuery += " RH4.RH4_FILIAL = RH3.RH3_FILINI And "+cCrLf 
	cQuery += " RH4.RH4_CODIGO = RH3.RH3_CODIGO And "+cCrLf
	cQuery += " RH4.D_E_L_E_T_ = ' '  "+cCrLf
	cQuery += "Where RH3.D_E_L_E_T_ = ' '  And RH3.RH3_TIPO = '9' And "+cCrLf
	cQuery += " RH3.RH3_FILINI = '"+cFilVaga+"' And "+cCrLf 
	cQuery += " RH3.RH3_CODIGO = '"+cCodVaga+"' "+cCrLf 
	cQuery += "Order By RH3.RH3_FILINI,RH3.RH3_MATINI,RH3.RH3_CODIGO,RH4.RH4_ITEM"

	//MemoWrite("C:\TOTVS_Projects\Projetos\PROTHEUS_RedeDOR\RedeDOR\Query\TMPVAGA.SQL",cQuery)

	_cQuery := ChangeQuery(cQuery)

	If Select("TMPVAGA") > 0
		DbSelectArea("TMPVAGA")
		("TMPVAGA")->(DbCloseArea())  
	Endif

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery),"TMPVAGA", .F., .T.)

	DbSelectArea("TMPVAGA")
	TMPVAGA->(DbGoTop())
	Count To nRecVaga

	If nRecVaga > 0

		DbSelectArea("TMPVAGA")
		TMPVAGA->(DbGoTop())

		While TMPVAGA->(!Eof())
			If TMPVAGA->RH4_CAMPO == "TMP_DESC  "
				cTmp_Desc := TMPVAGA->RH4_VALNOV
			Else
				If TMPVAGA->RH4_CAMPO == "TMP_FILIAL"
					cTmp_Filial := TMPVAGA->RH4_VALNOV
				Else
					If TMPVAGA->RH4_CAMPO == "TMP_DSCFIL"
						cTmp_Dscfil := TMPVAGA->RH4_VALNOV
					EndIf
				EndIf
			EndIf
			DbSelectArea("TMPVAGA")
			TMPVAGA->(DbSkip())
		EndDo
	EndIf

	If Select("TMPVAGA") > 0
		DbSelectArea("TMPVAGA")
		("TMPVAGA")->(DbCloseArea())  
	Endif


Return
