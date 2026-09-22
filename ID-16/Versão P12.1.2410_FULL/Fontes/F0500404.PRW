#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F0500404
(Movimentaçoes de Pessoas - centralizador de solicitações)
@type function
@author Cris
@since 20/10/2016
@version P12.1.7
@Project MAN0000007423039_EF_004
@return ${return}, ${não há}
/*/
//---------------------------------------------------------------------------------------------------------------------------
User Function F0500404()
	
Return


//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} $ ModelDef
(Movimentaçoes de Pessoas - centralizador de solicitações)
@type function
@author Cris
@since 20/10/2016
@version P12.1.7
@Project MAN0000007423039_EF_004
@return ${return}, ${não há}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function ModelDef()
	
	Local oModel
	Local oStrRH3 := FwFormStruct(1, "RH3")
	Local oStrRH4 := FWFormStruct(1, "RH4")
	
	oModel := MPFormModel():New("M0500404",,{|oModel| PrepNot(oModel)}, NIL)
	oModel:SetDescription("Cancelamento da Solicitação")
	
	oStrRH3:AddField(Alltrim(GetSx3Cache("RA_NOME","X3_TITULO")),;	// 	[01]  C   Titulo do campo
	Alltrim(GetSx3Cache("RA_NOME","X3_DESCRIC"))		,;	// 	[02]  C   ToolTip do campo
	"NOMESOL"											,;	// 	[03]  C   Id do Field
	GetSx3Cache("RA_NOME","X3_TIPO"	)				,;	// 	[04]  C   Tipo do campo
	TamSX3("RA_NOME")[1]								,;	// 	[05]  N   Tamanho do campo
	0													,;	// 	[06]  N   Decimal do campo
	NIL												,;	// 	[07]  B   Code-block de validação do campo
	{|| .T.}											,;	// 	[08]  B   Code-block de validação When do campo
	NIL												,;	//	[09]  A   Lista de valores permitido do campo
	.T.												,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
	{|| POSICIONE('SRA',1,RH3->RH3_FILINI + RH3->RH3_MATINI,'RA_NOME')}	,;//	[11]  B   Code-block de inicializacao do campo
	NIL												,;	//	[12]  L   Indica se trata-se de um campo chave
	.T.												,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.												)	// 	[14]  L   Indica se o campo é virtual
	
	oStrRH3:AddField(Alltrim(GetSx3Cache("RA_NOME","X3_TITULO")),;	// 	[01]  C   Titulo do campo
	Alltrim(GetSx3Cache("RA_NOME","X3_DESCRIC"))		,;	// 	[02]  C   ToolTip do campo
	"NOMAPROV"											,;	// 	[03]  C   Id do Field
	GetSx3Cache("RA_NOME","X3_TIPO"	)				,;	// 	[04]  C   Tipo do campo
	TamSX3("RA_NOME")[1]								,;	// 	[05]  N   Tamanho do campo
	0													,;	// 	[06]  N   Decimal do campo
	NIL												,;	// 	[07]  B   Code-block de validação do campo
	{|| .T.}											,;	// 	[08]  B   Code-block de validação When do campo
	NIL												,;	//	[09]  A   Lista de valores permitido do campo
	.T.												,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
	{|| POSICIONE('SRA',1,RH3->RH3_FILAPR + RH3->RH3_MATAPR,'RA_NOME')}	,;//	[11]  B   Code-block de inicializacao do campo
	NIL												,;	//	[12]  L   Indica se trata-se de um campo chave
	.T.												,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.												)	// 	[14]  L   Indica se o campo é virtual
	
	/*	if FindFunction("U_F0500201")
	
	oStrRH3:AddField("Hora"										,;	// 	[01]  C   Titulo do campo
	"Hora"												,;	// 	[02]  C   ToolTip do campo
	"HORAULT"											,;	// 	[03]  C   Id do Field
	"C"												,;	// 	[04]  C   Tipo do campo
	TamSX3("PA5_XHORA")[1]								,;	// 	[05]  N   Tamanho do campo
	0													,;	// 	[06]  N   Decimal do campo
	NIL												,;	// 	[07]  B   Code-block de validação do campo
	{|| .T.}											,;	// 	[08]  B   Code-block de validação When do campo
	NIL												,;	//	[09]  A   Lista de valores permitido do campo
	.T.												,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
	{|| UltHora()}										,;//	[11]  B   Code-block de inicializacao do campo
	NIL												,;	//	[12]  L   Indica se trata-se de um campo chave
	.T.												,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.												)	// 	[14]  L   Indica se o campo é virtual
	
EndIf
*/
oStrRH3:SetProperty( "*", MODEL_FIELD_OBRIGAT, .F. )
oStrRH3:SetProperty( "RH3_STATUS", MODEL_FIELD_WHEN, {|| .T.})

oModel:AddFields("RH3MASTER", /*cOwner*/, oStrRH3)
oModel:AddGrid(	"RH4DETAIL","RH3MASTER",oStrRH4)

oModel:SetPrimaryKey({"RH3_CODIGO"})

oModel:GetModel("RH4DETAIL"):SetUniqueLine({"RH4_ITEM"})

oModel:SetRelation("RH4DETAIL",{{"RH4_FILIAL","xFilial('RH4')"},{"RH4_CODIGO", "RH3_CODIGO"}}, "RH4_FILIAL + RH4_CODIGO + STR(RH4_ITEM,3)")

Return oModel

//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} UltHora
Retorna a ultima hora da ultima manipulação da solicitação
@type function
@author Cris
@since 12/12/2016
@version 12
@return ${caracter}, ${Retorna a ultima hora da ultima manipulação}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function UltHora()
	
	Local cQryPA5	:= ''
	Local cHoraUlt	:= ''
	Local cTabPA5	:= ''
	
	cTabPA5	:= GetNextAlias()
	
	cQryPA5	:= " SELECT MAX(R_E_C_N_O_), PA5_XHORA " + CRLF
	cQryPA5	+= " FROM " + RetSqlName("PA5") + " (NOLOCK) " + CRLF
	cQryPA5	+= " WHERE PA5_FILIAL = '" + RH3->RH3_FILIAL + "' " + CRLF
	cQryPA5	+= "   AND D_E_L_E_T_ = '' " + CRLF
	cQryPA5	+= "   AND PA5_XNRSOL = '" + RH3->RH3_CODIGO + "'" + CRLF
	cQryPA5	+= "   GROUP BY PA5_XHORA " + CRLF
	
	cQryPA5 := ChangeQuery(cQryPA5)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryPA5),cTabPA5,.T.,.T.)
	
	if !(cTabPA5)->(Eof())
		
		cHoraUlt	:= (cTabPA5)->PA5_XHORA
	EndIf
	
	(cTabPA5)->(dbCloseArea())
	
Return cHoraUlt


//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} $ ViewDef
(Movimentaçoes de Pessoas - centralizador de solicitações)
@type function
@author Cris
@since 20/10/2016
@version P12.1.7
@Project MAN0000007423039_EF_004
@return ${return}, ${não há}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function ViewDef()
	
	Local oModel := FWLoadModel('F0500404')
	Local oStrRH3 := FWFormStruct(2, "RH3")
	Local oStrRH4 := FWFormStruct(2, "RH4")
	Local oView
	
	oStrRH3:SetProperty( "RH3_STATUS", MVC_VIEW_CANCHANGE, .T.)
	
	oStrRH3:RemoveField("RH3_FILIAL")
	oStrRh3:RemoveField("RH3_TIPO")
	oStrRH3:RemoveField("RH3_VISAO")
	oStrRH3:RemoveField("RH3_NVLINI")
	oStrRH3:RemoveField("RH3_FILINI")
	oStrRH3:RemoveField("RH3_NVLAPR")
	oStrRH3:RemoveField("RH3_FILAPR")
	oStrRh3:RemoveField("RH3_FLUIG")
	oStrRH3:RemoveField("RH3_WFID")
	oStrRH3:RemoveField("RH3_IDENT")
	oStrRH3:RemoveField("RH3_KEYINI")
	oStrRH3:RemoveField("RH3_EMP")
	oStrRH3:RemoveField("RH3_EMPINI")
	oStrRH3:RemoveField("RH3_EMPAPR")
	oStrRH3:RemoveField("RH3_XTPCTM")
	oStrRH3:RemoveField("RH3_ORIGEM")
	oStrRH3:RemoveField("RH3_TPDESC")
	oStrRH3:RemoveField("RH3_DTATEN")
	oStrRH3:RemoveField("RH3_XSUSPE")
	
	oStrRH4:RemoveField("RH4_FILIAL")
	oStrRH4:RemoveField("RH4_CAMPO")
	oStrRH4:RemoveField("RH4_CODIGO")
	oStrRH4:RemoveField("RH4_VALANT")
	oStrRH4:RemoveField("RH4_XOBS")
	
	oStrRH3:AddField("NOMESOL"								,;	// [01]  C   Nome do Campo
	"15"										,;	// [02]  C   Ordem
	'Nome do Solicitante'						,;	// [03]  C   Titulo do campo
	'Nome do Solicitante'						,;	// [04]  C   Descricao do campo
	NIL											,;	// [05]  A   Array com Help
	"C"											,;	// [06]  C   Tipo do campo
	GetSx3Cache("RA_NOME","X3_PICTURE")			,;	// [07]  C   Picture
	NIL											,;	// [08]  B   Bloco de Picture Var
	NIL											,;	// [09]  C   Consulta F3
	.F.											,;	// [10]  L   Indica se o campo é alteravel
	NIL											,;	// [11]  C   Pasta do campo
	NIL											,;	// [12]  C   Agrupamento do campo
	NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
	NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
	NIL											,;	// [15]  C   Inicializador de Browse
	.T.											,;	// [16]  L   Indica se o campo é virtual
	NIL											,;	// [17]  C   Picture Variavel
	NIL											)	// [18]  L   Indica pulo de linha após o campo
	
	oStrRH3:AddField("NOMAPROV"								,;	// [01]  C   Nome do Campo
	"20"										,;	// [02]  C   Ordem
	'Nome do Aprovador'							,;	// [03]  C   Titulo do campo
	'Nome do Aprovador'							,;	// [04]  C   Descricao do campo
	NIL											,;	// [05]  A   Array com Help
	"C"											,;	// [06]  C   Tipo do campo
	GetSx3Cache("RA_NOME","X3_PICTURE")			,;	// [07]  C   Picture
	NIL											,;	// [08]  B   Bloco de Picture Var
	NIL											,;	// [09]  C   Consulta F3
	.F.											,;	// [10]  L   Indica se o campo é alteravel
	NIL											,;	// [11]  C   Pasta do campo
	NIL											,;	// [12]  C   Agrupamento do campo
	NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
	NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
	NIL											,;	// [15]  C   Inicializador de Browse
	.T.											,;	// [16]  L   Indica se o campo é virtual
	NIL											,;	// [17]  C   Picture Variavel
	NIL											)	// [18]  L   Indica pulo de linha após o campo
	
	/*
	if FindFunction("U_F0500201")
		
		oStrRH3:AddField("HORAULT"								,;	// [01]  C   Nome do Campo
		"21"										,;	// [02]  C   Ordem
		'Hora'										,;	// [03]  C   Titulo do campo
		'Hora'										,;	// [04]  C   Descricao do campo
		NIL											,;	// [05]  A   Array com Help
		"C"											,;	// [06]  C   Tipo do campo
		"@R 99:99"									,;	// [07]  C   Picture
		NIL											,;	// [08]  B   Bloco de Picture Var
		NIL											,;	// [09]  C   Consulta F3
		.F.											,;	// [10]  L   Indica se o campo é alteravel
		NIL											,;	// [11]  C   Pasta do campo
		NIL											,;	// [12]  C   Agrupamento do campo
		NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
		NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
		NIL											,;	// [15]  C   Inicializador de Browse
		.T.											,;	// [16]  L   Indica se o campo é virtual
		NIL											,;	// [17]  C   Picture Variavel
		NIL											)	// [18]  L   Indica pulo de linha após o campo
		
	EndIf
	*/
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:AddField("VIEW_RH3", oStrRH3, 'RH3MASTER')
	
	oView:AddGrid("VIEW_RH4", oStrRH4,"RH4DETAIL")
	oView:CreateHorizontalBox("TOP", 40)
	oView:CreateHorizontalBox("BOTTOM", 60)
	
	oView:SetOwnerView("VIEW_RH3", "TOP")
	oView:SetOwnerView("VIEW_RH4", "BOTTOM")
	
Return oView


//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} $ PrepNot
Envia email aos aprovadores relacionados
@type function
@author Cris
@since 11/11/2016
@version P12.1.7
@Project MAN0000007423039_EF_004
@return ${return}, ${não há}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function PrepNot(oModel)
	
	Local cVisaoAtu	:= oModel:GetModel("RH3MASTER"):GetValue("RH3_VISAO")
	Local cCodAtu	:= oModel:GetModel("RH3MASTER"):GetValue("RH3_CODIGO")
	Local aResp		:= {}
	Local iResp		:= 0
	Local cEmails	:= ''
	Local cBody		:= ''
	Local lEnvEmail	:= .T.
	
	//Retorna todos os emails de todos os aprovadores responsáveis
	U_F0500405(cVisaoAtu,,,,.T.,@aResp)
	
	For iResp := 1 to len(aResp)
		
		if !Empty(cEmails)
			
			if !Alltrim(aResp[iResp][3]) $ cEmails
				
				cEmails	:= cEmails + ';'
			EndIf
		Else
			
			cEmails	:= Alltrim(aResp[iResp][3])
		EndIf
	Next iResp
	
	cBody := '<html><body><pre>' + CRLF
	cBody += '<b>Prezado,</b>' + CRLF
	cBody += "A solicitação abaixo foi <b>CANCELADA</b> pelo departamento RH, portanto não será efetivada." + CRLF
	cBody += "Número da Solicitação:" + cCodAtu + CRLF
	cBody += '</pre></body></html>'
	
	FWMsgRun(,{|| lEnvEmail:= U_F0200304("Cancelamento de Solicitação de Movimentações de Pessoal", cBody, cEmails)},"Aguarde...","Estabelecendo conexão com o serviço de e-mail." )
	//FWMsgRun(,{|| lEnvEmail:= EnvEmail("","Cancelamento de Solicitação de Movimentações de Pessoal",cBody,cEmails,'')},"Aguarde...","Estabelecendo conexão com o serviço de e-mail." )
	
	if lEnvEmail
		
		Aviso("SUCESSO - Email","E-mail enviado com sucesso!" ,{'OK'},1)
	Else
		
		Aviso("INSUCESSO - Email","E-mail NÃO enviado. Comunique aos envolvidos!" ,{'OK'},1)
	EndIf
	
	//Atualiza o campo de status na tabela SRA liberando o funcionário para ter uma nova solicitação
	if !U_F0500407(oModel:GetModel("RH3MASTER"):GetValue("RH3_FILIAL"),oModel:GetModel("RH3MASTER"):GetValue("RH3_MAT"),cCodAtu,cVisaoAtu)
		
		Aviso("NÃO ATUALIZADO","O cadastro do funcionário não foi desbloqueado para novas solicitações!" ,{'OK'},1)
	EndIf
	
Return .T.


//--------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ${EnvEmail}
(Envia e-mail)
@type function
@author Cris
@since 09/11/2016
@version 1.0
@param cArquivo, character, (nome do arquivo a ser anexado)
@param cSubject, character, (Titulo do e-mail)
@param cBody, character, (Corpo do e-mail)
@param cTo, character, (endereço de Destino do e-mail)
@param cCC, character, (endereço copia de destino)
@version P12.1.7
@Project MAN0000007423039_EF_004
@return ${return}, ${não há}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function EnvEmail(cArquivo,cSubject,cBody,cTo,cCC)
	
	Local cServer	:= AllTrim(GetMv("MV_RELSERV"))
	Local cFrom		:= AllTrim(GetMv("MV_RELACNT"))
	Local lAutentica:= GetMv("MV_RELAUTH")
	Local cUserAut	:= Alltrim(GetMv("MV_RELAUSR"))
	Local cPassAut	:= Alltrim(GetMv("MV_RELAPSW"))
	
	Default cArquivo := ""
	Default cSubject := ""
	Default cBody    := ""
	Default cTo      := ""
	Default cCC      := ""
	
	If Empty(cServer)
		conout("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
		Return .F.
	EndIF
	
	IF Empty(cFrom)
		conout("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
		Return .F.
	EndIf
	
	cTo := AvLeGrupoEMail(cTo)
	cCC := AvLeGrupoEMail(cCC)
	
	lOK	:= MailSmtpOn( cServer, cFrom, cPassAut, 60 )
	
	If !lOK
		
		conout("Falha na Conexão com Servidor de E-Mail")
		Aviso('Email não enviado',"Falha na Conexão com Servidor de E-Mail. ",{'OK'},3)
	Else
		
		If lAutentica
			If !MailAuth(cUserAut,cPassAut)
				Aviso('Email não enviado',"Falha na Autenticação do Usuário. ",{'OK'},3)
				conout("Falha na Autenticacao do Usuario")
				lOk	:=	MailSmtpOff()
			EndIf
		EndIf
		
		If !Empty(cCC)
			lOK:=MailSend( cFrom, { cTo }, { cCC }, { }, cSubject, cBody, { cArquivo },.F. )
		Else
			lOK:=MailSend( cFrom, { cTo }, { }, { }, cSubject, cBody, { cArquivo },.F. )
		EndIF
		
		If !lOK
			if !IsBlind()
				///Aviso('Email não enviado',"Falha no Envio do E-Mail: " + ALLTRIM(cTo),{'OK'},3)
			Else
				conout("Falha no Envio do E-Mail: " + ALLTRIM(cTo))
			EndIF
		Else
			if  !IsBlind()
				//Aviso("Envio de Email",'E-mail enviado com sucesso.', {'OK'},3)
			EndIf
		EndIF
	ENDIF
	
	MailSmtpOff()
	
RETURN lOK
