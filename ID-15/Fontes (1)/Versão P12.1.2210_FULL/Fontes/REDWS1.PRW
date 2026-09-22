#include "APWEBSRV.CH"
#include "PROTHEUS.CH"
#include "TBICONN.CH"
#include "TBICODE.CH"
#include "TOPCONN.CH"
#include "rwmake.ch"

/*/{Protheus.doc} REDWS1

Descrição: WebService para integração com o Bionexo - (PEDIDO DE COMPRAS/CONTRATOS)

@author Ricardo junior
@since 25/05/17
@version 1.1		
/*/

WsStruct STRBASE

	WsData Parametros	As String OPTIONAL
	WsData Login		As String OPTIONAL
	WsData Password		As String OPTIONAL
	WsData Filial		As String OPTIONAL
	WsData XIdProc 		As String OPTIONAL
	WsData A2CGC		As String OPTIONAL
	WsData C7NUM 		As String OPTIONAL
	WsData Operacao		As String OPTIONAL
	WsData Cancelamento As String OPTIONAL

EndWsStruct

WsStruct STRWDG

	WsData C7FILIAL 	As String OPTIONAL
	WsData C7NUMSC 		As String OPTIONAL
	WsData C7ITEM 		As String OPTIONAL
	WsData C7PRODUTO 	As String OPTIONAL
	WsData C7PRECO		As Float  OPTIONAL
	WsData C7QTSEGUM	As Float  OPTIONAL
	WsData C7OBS 		As String OPTIONAL
	WsData C7CONDPAG 	As String OPTIONAL
	WsData C7XIDBIO 	As String OPTIONAL
	WsData C7XITBIO 	As String OPTIONAL
	WsData C7DATPRF 	As String OPTIONAL
	WsData A2CGC		As String OPTIONAL

EndWsStruct

WsStruct STRWBS

	//WsData C7FILIAL 	As String
	WsData STATUS 		As String
	WsData A2CGC 		As String
	WsData C7ITEM 		As String
	WsData C7PRODUTO 	As String
	WsData C7QTSEGUM	As Float
	WsData C7OBS 		As String
	WsData C7XIDBIO 	As String
	WsData C7XITBIO 	As String
	WsData C7XNUMEXT	As String
	WsData XIDPROC 		As String


EndWsStruct

WsStruct STRWFG

	WsData	C8FILIAL 	As String OPTIONAL
	WsData  A2CGC		As String OPTIONAL
	WsData	C8ITEMSC	As String OPTIONAL
	WsData	C8PRODUTO 	As String OPTIONAL
	WsData  C8PRAZO     As Float  OPTIONAL
	WsData	C8QTSEGUM 	As Float  OPTIONAL
	WsData	C8OBS 		As String OPTIONAL
	WsData	C8CONDPAG 	As String OPTIONAL
	WsData  C8XCTBIO    As String OPTIONAL
	WsData	C8NUMSC 	As String OPTIONAL
	WsData	C8XIDBIO 	As String OPTIONAL
	WsData	C8PRECO 	As Float  OPTIONAL
	WsData  TIPO		As String OPTIONAL


EndWsStruct

WsStruct STRWASE//ESTRUTURA DO ENVIO DAS SOLICITAÇÕES DE COMPRAS

	WsData C1FILIAL 	As String
	WsData C1NUM 		As String
	WsData C1ITEM 		As String
	WsData C1PRODUTO 	As String
	WsData C1QTSEGUM 	As String
	WsData C1OBS 		As String
	WsData C1XTPSC 		As String
	WsData C1MOEDA 		As String
	WsData XCONDPAG		As String
	WsData XDTCOTA		As String
	WsData XHRCOTA		As String
	WsData C1XIDBIO 	As String OPTIONAL
	WsData TITPDC 		As String OPTIONAL

EndWsStruct

WsStruct ASTRWASE
	WsData lSolic As Array of STRWASE
EndWsStruct

WsStruct ASTRWBS
	WsData aConf As Array of STRWBS
EndWsStruct

WsStruct STRWASERET //ESTRUTURA RETORNO DA SOLICITAÇÃO DE COMPRAS

	WsData XIDPROC	    As String OPTIONAL
	WsData STATUS  	    As String OPTIONAL
	WsData MSGRET		As String OPTIONAL

EndWsStruct


WsStruct STRWBSRET//ESTRUTURA RETORNO DA CONFIRMAÇÃO DO PEDIDO DE COMPRAS

	WsData XIDPROC	    As String OPTIONAL
	WsData STATUS	    As String OPTIONAL
	WsData MSGRET		As String OPTIONAL

EndWsStruct

WsStruct STRWAURET

	WsData XIDPROC	    As String OPTIONAL
	WsData STATUS	    As String OPTIONAL
	WsData MSGRET		As String OPTIONAL

EndWsStruct

WsStruct STRWDGENV

	WsData XIDPROC	    As String OPTIONAL
	WsData STATUS	    As String OPTIONAL
	WsData MSGRET		As String OPTIONAL

EndWsStruct

WsStruct LWDGENV
	WsData listaWDG 	As Array of STRWDG OPTIONAL
EndWsSTruct

WsStruct STRWDGRET

	WsData XIDPROC	    As String OPTIONAL
	WsData STATUS	    As String OPTIONAL
	WsData MSGRET		As String OPTIONAL

EndWsStruct


WsStruct STRWFGENV

	WsData XIDPROC	    As String OPTIONAL
	WsData STATUS	    As String OPTIONAL
	WsData MSGRET		As String OPTIONAL

EndWsStruct

WsStruct LWFGENV
	WsData LISTAWFG 	As Array of STRWFG OPTIONAL
EndWsStruct

WsStruct STRWFGRET

	WsData XIDPROC	    As String OPTIONAL
	WsData STATUS	    As String OPTIONAL
	WsData MSGRET		As String OPTIONAL

EndWsStruct


WsService REDWS1 DESCRIPTION "WebService para integração com o Bionexo - SOLICITAÇÃO DE COMPRAS/PEDIDO DE COMPRAS/CONTRATOS"

	WsData WsRet 		As String
	WsData WSBase     	As STRBASE
	WsData WsSolic 		As ASTRWASE
	WsData WsConf 		As ASTRWBS
	WsData WsWaseEnv    As STRWASERET
	WsData WsWBSEnv    	As STRWBSRET
	WsData WsWaseRet    As STRWASERET
	WsData WsWBSRet    	As STRWBSRET
	WsData WsWauEnv    	As STRWAURET
	WsData WsWauRet		As STRWAURET

	WsData WsWfgEnv		As STRWFGENV
	WsData WsContrato	As LWFGENV OPTIONAL

	WsData WsWfgRet		As STRWFGRET

	WsData WsWdgEnv		As STRWDGENV
	WsData WsPedido		As LWDGENV OPTIONAL

	WsData WsWdgRet		As STRWDGRET

	WsMethod WDG	 DESCRIPTION "WebService para recuperar dados do Carrinho (recuperar o carrinho de compras)"
	WsMethod WDGRET	 DESCRIPTION "WebService para recuperar dados do Carrinho (recuperar o carrinho de compras) - RETORNO"

	WsMethod WFG  	 DESCRIPTION "WebService para recuperar dados do Contrato (recupera contrato gerado na Bionexo)"
	WsMethod WFGRET	 DESCRIPTION "WebService para recuperar dados do Carrinho (recuperar o carrinho de compras) - RETORNO"

	WsMethod WASE 	 DESCRIPTION "WebService para gerar solicitação (cria pedido de cotação Individual em estado de espera)"
	WsMethod WAU	 DESCRIPTION "WebService para alterar dados da solicitação (utilizado para alterar/cancelar pedido de cotação jã publicado, vigente ou confirmado)."
	WsMethod WASERET DESCRIPTION "WebService para atualizar a solicitação de compras com o id Bionexo."
	WsMethod WAURET	 DESCRIPTION "WebService para receber as solicitaçãoes que foram desvinculadas no Bionexo."
	WsMethod WBS	 DESCRIPTION "WebService para enviar a confirmação do pedido de compras protheus e do front para a Bionexo."
	WsMethod WBSRET	 DESCRIPTION "WebService retornar status da confirmação do pedido do BIONEXO."

EndWsService

WsMethod WDG WsReceive WSBase WsSend WsRet WsService REDWS1

	Local nX := 00

	For nX := 01 To 2
		aAdd(::WsPedido, WsClassNew("STRWDG") )
		aTail(::WsPedido):FILIAL 	:= "01"
		aTail(::WsPedido):PRODUTO 	:= StrZero(nX,6)
		aTail(::WsPedido):SEGUM		:= "CX"
		aTail(::WsPedido):DESCRI 	:= "TESTE " + StrZero(nX, 5)
		aTail(::WsPedido):QTSEGUM 	:= Randomize(0,100)
		aTail(::WsPedido):PRECO 	:= Randomize(0,2000)
		aTail(::WsPedido):OBS		:= ""
		aTail(::WsPedido):CGC 		:= "16.501.354/0001-50"
		aTail(::WsPedido):CONDPAG 	:= "001"
		aTail(::WsPedido):NUMSC 	:= StrZero(Randomize(0,10), 6)
		aTail(::WsPedido):ITEMSC	:= StrZero(nX, 4)
		aTail(::WsPedido):XIDBIO 	:= "999999"
		aTail(::WsPedido):XITBIO 	:= "99999999"

		aTail(::WsPedido):GERACTR 	:= "1"
	Next nX

Return .T.

WsMethod WFG WsReceive WSBase WsSend WsRet WsService REDWS1


	aAdd(::WsContrato, WsClassNew("STRWFG") )

	aTail(::WsContrato):C8FILIAL 	:= "01"
	aTail(::WsContrato):C8ITEM	 	:= "0001"
	aTail(::WsContrato):C8PRODUTO 	:= "00000001"
	aTail(::WsContrato):C8SEGUM		:= "UN"
	aTail(::WsContrato):C8DESCRI 	:= "TESTE ORDENAÃ‡ÃƒO"
	aTail(::WsContrato):C8QTSEGUM  	:= 10
	aTail(::WsContrato):C8OBS		:= "OBS"
	aTail(::WsContrato):A2CGC	  	:= "11122233344455"
	//aTail(::WsContrato):C8FORNECE  	:= "000010"
	//aTail(::WsContrato):C8LOJA 	 	:= "01"
	aTail(::WsContrato):A2CGC 	 	:= ""
	aTail(::WsContrato):C8CONDPAG  	:= "AVT"
	aTail(::WsContrato):C8NUMSC 	:= "000002"
	aTail(::WsContrato):C8XIDBIO 	:= "50600"
	aTail(::WsContrato):C8PRECO 	:= 120.00
	aTail(::WsContrato):C8TPDOC 	:= "2"

	aAdd(::WsContrato, WsClassNew("STRWFG") )
	aTail(::WsContrato):C8FILIAL 	:= "01"
	aTail(::WsContrato):C8ITEM	 	:= "0002"
	aTail(::WsContrato):C8PRODUTO 	:= "00000002"
	aTail(::WsContrato):C8SEGUM		:= "UN"
	aTail(::WsContrato):C8DESCRI 	:= "TESTE ORDENAção"
	aTail(::WsContrato):C8QTSEGUM  	:= 55
	aTail(::WsContrato):C8OBS		:= "OBS"
	aTail(::WsContrato):A2CGC	  	:= "11122233344455"
	//aTail(::WsContrato):C8FORNECE  	:= "000010"
	//aTail(::WsContrato):C8LOJA 	 	:= "01"
	aTail(::WsContrato):A2CGC 	 	:= ""
	aTail(::WsContrato):C8CONDPAG  	:= "AVT"
	aTail(::WsContrato):C8NUMSC 	:= "000002"
	aTail(::WsContrato):C8XIDBIO 	:= "50600"
	aTail(::WsContrato):C8PRECO 	:= 100.00
	aTail(::WsContrato):C8TPDOC 	:= "2"

	aAdd(::WsContrato, WsClassNew("STRWFG") )
	aTail(::WsContrato):C8FILIAL 	:= "01"
	aTail(::WsContrato):C8ITEM	 	:= "0003"
	aTail(::WsContrato):C8PRODUTO 	:= "00000003"
	aTail(::WsContrato):C8SEGUM		:= "UN"
	aTail(::WsContrato):C8DESCRI 	:= "TESTE ORDENAção"
	aTail(::WsContrato):C8QTSEGUM  	:= 10
	aTail(::WsContrato):C8OBS		:= "OBS"
	aTail(::WsContrato):A2CGC	  	:= "11122233344455"
	//aTail(::WsContrato):C8FORNECE  	:= "000010"
	//aTail(::WsContrato):C8LOJA 	 	:= "01"
	aTail(::WsContrato):A2CGC 	 	:= ""
	aTail(::WsContrato):C8CONDPAG  	:= "AVT"
	aTail(::WsContrato):C8NUMSC 	:= "000002"
	aTail(::WsContrato):C8XIDBIO 	:= "50600"
	aTail(::WsContrato):C8PRECO 	:= 120.00
	aTail(::WsContrato):C8TPDOC 	:= "2"
Return .T.

WsMethod WASE WsReceive WSBase, WsSolic WsSend WsRet WsService REDWS1
	::WsRet := "ERRO"
Return(.T.)

WsMethod WAU WsReceive WSBase, WsSolic WsSend  WsRet WsService REDWS1
	::WsRet := "1"
Return(.T.)

WsMethod WASERET WsReceive WsWaseEnv WsSend WsWaseRet WsService REDWS1
	Local nRecno	 	:= 0
	Local nX 			:= 0
	Local aRet 		:= {}
	Local cStatus 	:= "1"
	Local cObs 		:= "Ok"
	Local _cZError	:= ""
	Local cQuery  	:= ""
	Private cAliasSC1 	:= GetNextAlias()//"TMPSC1"

	Conout("VALTYPE: " + ValType(::WsWaseEnv:MSGRET))
	If ValType(::WsWaseEnv:MSGRET) == "C"

		nRecno := U_F07Log01(::WsWaseEnv:XIDPROC,"U_REDA002")

		cQuery := "  SELECT " + CRLF
		cQuery += " 	C1_XIDPROC, " + CRLF
		cQuery += " 	R_E_C_N_O_ REC" + CRLF
		cQuery += " 	FROM "+ RetSqlName("SC1") +" SC1 " 	+ CRLF
		cQuery += " 	WHERE SC1.D_E_L_E_T_ = ' ' "		+ CRLF
		cQuery += " 	AND SC1.C1_XIDPROC = '" + ::WsWaseEnv:XIDPROC + "'" 	+ CRLF

		If Select(cAliasSC1) > 0
			(cAliasSC1)->(DbCloseArea())
		EndIf

		DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasSC1, .F., .T.)

		aRet := StrTokArr(::WsWaseEnv:MSGRET, ";")
		DbSelectArea("SC1")
		If aRet[1] == "1"
			If !(cAliasSC1)->(Eof())
				While !(cAliasSC1)->(Eof())
					SC1->(DbGoTo((cAliasSC1)->REC))
					SC1->(RecLock("SC1", .F.))
					SC1->C1_XIDBIO 	:= aRet[4]
					SC1->C1_XENVBIO := "2" //1=Aguardando Integr. Bionexo, 2=Integrado Bionexo, 3=Aguardando Desvinculo Bionexo, 4=Erro de Integração Bionexo
					SC1->(MsUnLock())
					(cAliasSC1)->(DbSkip())
				EndDo
			Else
				cStatus 	:= "2" //1=Aguardando Integr. Bionexo, 2=Integrado Bionexo, 3=Aguardando Desvinculo Bionexo, 4=Erro de Integração Bionexo
				cObs		:= "Erro: Solicitação de Compras não encontrada - NOVO!"
				_cZError	:= "IDPROC: " + ::WsWaseEnv:XIDPROC + " não foi encontrado!"+ CRLF
				U_WsLogBio("WASERET", 1, _cZError)
			EndIf
		ElseIf aRet[1] == "-1"
			_cZError	:= aRet[4]
			U_WsLogBio("WASERET", 1, _cZError)
		ElseIf aRet[1] == "0"
			_cZError 	:= "Não foi realizado alteração na Bionexo."
			U_WsLogBio("WASERET", 1, _cZError)
		EndIf
	Else
		cStatus := "2"
		cObs	:= "VALOR DO MSGRET É DIFERENTE DE CARACTER"
	EndIf

	::WsWaseRet:XIDPROC 	:= WsWaseEnv:XIDPROC
	::WsWaseRet:STATUS 		:= cStatus
	::WsWaseRet:MSGRET		:= cObs

	If nRecno > 0
		(cAliasSC1)->(DbGoTop())
		SC1->(DbGoTo((cAliasSC1)->REC))
		U_F07Log02(nRecno,::WsWaseRet:MSGRET,Iif(cStatus == "1",.T., .F.), "SC1", 1, SC1->C1_FILIAL + "|" + SC1->C1_NUM)
	Endif
Return .T.

WsMethod WAURET WsReceive WsWauEnv WsSend WsWauRet WsService REDWS1

	Local nRecno := 0
	Local nX := 0
	Local cObs := "OK"
	Local cStatus := "1"
	Local cMsgError	:= ""

	// Mensagem de Erro Padrão Mapeada
	cMsgError := AllTrim( SuperGetMV("MV_XMSGERRO", .F., "A requisição não encontra-se mais em espera", ) )

	Conout("VALTYPE: " + ValType(::WsWauEnv:MSGRET))
	If ValType(::WsWauEnv:MSGRET) == "C"

		nRecno := U_F07Log01(::WsWauEnv:XIDPROC,"U_REDA004")

		aRet := StrTokArr(::WsWauEnv:MSGRET, ";")
		DbSelectArea("SC1")
		If DBOrderNickname("IDPROC")
			If DbSeek(::WsWauEnv:XIDPROC)
				nRecSC1 := SC1->(Recno())
				U_WsLogBio("WAURET", 1, "Encontrou o XIDPROC")
				If Empty(SC1->C1_XIDBIO) .And. Empty(SC1->C1_XENVBIO)
					cStatus := "2"
					cObs 	:= "XIDPROC: " + ::WsWauEnv:XIDPROC + " não pode ser desvinculado."
					U_WsLogBio("WAURET", 1, cObs)
				Else
					If aRet[1] == "1"
						cIdProc := AllTrim(::WsWauEnv:XIDPROC)
						While !SC1->(Eof()) .And. cIdProc == AllTrim(SC1->C1_XIDPROC)
							U_WsLogBio("WAURET", 1, "ATUALIZANDO SC " + SC1->C1_NUM)
							RecLock("SC1", .F.)
							SC1->C1_XIDBIO 	:= ""
							SC1->C1_XENVBIO := ""
							SC1->(MsUnLock())
							SC1->(DbSkip())
						EndDo
					ElseIf aRet[1] == "-1"
						cObs := "Ok"//aRet[4]
						cStatus := "1"
						// 02/10/2017
						// Compara se a Mensagem Padrão é igual a Retornada
						If ( Upper( cMsgError ) == Upper( cObs ) )
							cIdProc := AllTrim(::WsWauEnv:XIDPROC)
							While !SC1->(Eof()) .And. cIdProc == AllTrim(SC1->C1_XIDPROC)
								U_WsLogBio("WAURET", 1, "ATUALIZOU OS CAMPOS XCANWAU e XENVBIO DA SOLICITACAO" + SC1->C1_FILIAL + SC1->C1_NUM + SC1->C1_ITEM)
								RecLock("SC1", .F.)
								SC1->C1_XCANWAU := "S"
								SC1->C1_XENVBIO := "2"
								SC1->(MsUnLock())
								SC1->(DbSkip())
							EndDo
						EndIf
					ElseIf aRet[1] == "0"
						cObs := "Não foi realizada a alteração na Bionexo"
					EndIf
					U_WsLogBio("WAURET", 1, "RETORNO: " + aRet[1] + " - " + cObs)
				EndIf
			Else
				cObs := "XIDPROC: " + ::WsWauEnv:XIDPROC + " não foi encontrado."
				cStatus := "2"
				U_WsLogBio("WAURET", 1, cObs)
			EndIf
		Else
			cStatus := "2"
			cObs	:= "Erro: Não foi encontrado o indice IDPROC no protheus."
			U_WsLogBio("WAURET", 1, cObs)
		EndIf
	EndIf

	::WsWauRet:XIDPROC 		:= ::WsWauEnv:XIDPROC
	::WsWauRet:MSGRET		:= cObs
	::WsWauRet:STATUS 		:= cStatus

	If nRecno > 0
		SC1->(DbGoTo(nRecSC1))
		U_F07Log02(nRecno,::WsWauRet:MSGRET, Iif (cStatus == "1",.T., .F.), "SC1", 1, SC1->C1_FILIAL + "|" + SC1->C1_NUM)
	Endif
Return( .T. )

WsMethod WBS WsReceive WSBase WsSend WsConf WsService REDWS1

	Local cQuery 	:= ""
	Local cAliasSC7 := GetNextAlias()
	Local aZRecNo	:= {}
	Local oWsStrWbs	:= Nil
	Local cIdProc	:= ""

	cQuery := " SELECT C7_NUM, C7_XFLGWBS, C7_XQTENV, SC7.* FROM ( "
	cQuery += " SELECT SC7.*  FROM " + RetSqlName("SC7") + " SC7 " + CRLF
	cQuery += " WHERE D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " AND C7_XNUM != ' ' " + CRLF
	cQuery += " AND C7_FILIAL = '"+::WSBase:Filial+"' " + CRLF
	If !Empty(::WSBase:C7NUM)
		cQuery += " AND C7_NUM = '"+::WSBase:C7NUM+"' " + CRLF
	Else
		cQuery += " AND C7_XFLGWBS <> 'I' " + CRLF
	EndIf
	cQuery += " AND C7_XIDBIO != ' ' " + CRLF
	cQuery += " AND C7_XIDART != ' ' " + CRLF
	cQuery += " AND C7_XQTENV < 100"
	cQuery += " AND TO_DATE(C7_EMISSAO, 'YYYY/MM/DD') >= SYSDATE - INTERVAL '30' DAY "

	cQuery += " UNION ALL " + CRLF

	cQuery += " SELECT C7.*  FROM " + RetSqlName("SC7") + " C7 " + CRLF
	cQuery += " WHERE C7.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " AND C7.C7_XNUM = ' ' " + CRLF
	cQuery += " AND C7.C7_FILIAL = '"+::WSBase:Filial+"' " + CRLF
	If !Empty(::WSBase:C7NUM)
		cQuery += " AND C7.C7_NUM = '"+::WSBase:C7NUM+"' " + CRLF
	Else
		cQuery += " AND C7.C7_XFLGWBS <> 'I' " + CRLF
	EndIf
	cQuery += " AND C7.C7_XIDBIO != ' ' " + CRLF
	cQuery += " AND C7.C7_XIDART != ' ' " + CRLF
	cQuery += " AND C7.C7_CONAPRO = 'L' "
	cQuery += " AND C7.C7_XQTENV < 100"
	cquery += " AND C7.C7_PRODUTO = (SELECT P17_COD FROM " + RetSqlName("P17") + " P17 WHERE P17.D_E_L_E_T_ = ' ' AND P17.P17_FTRATA = C7.C7_FILIAL AND P17.P17_COD = C7.C7_PRODUTO AND P17.P17_ESTOQ = 'N') "
	cQuery += " AND TO_DATE(C7.C7_EMISSAO, 'YYYY/MM/DD') >= SYSDATE - INTERVAL '30' DAY "
	cQuery += "  ) SC7 ORDER BY SC7.C7_FILIAL, SC7.C7_XIDBIO, SC7.C7_NUM "

	If Select(cALiasSC7) > 0
		(cALiasSC7)->(DbCloseArea())
	EndIf

	Conout("Antes de rodar a Query " + Time())
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC7,.T.,.T.)
	Conout("Depois de rodar a Query " + Time())
	DbSelectArea("SC7")
	SC7->(DbSetOrder(01))
	::WsConf := WSClassNew("ASTRWBS")
	::WsConf:aConf := {}

	If (cALiasSC7)->(Eof())
		Conout("Query retornou vazio, resposta vazia padrão para o barramento " + Time())
		oWsStrWbs := WSClassNew("STRWBS")
		oWsStrWbs:STATUS		:= "0"
		oWsStrWbs:C7ITEM		:= ""
		oWsStrWbs:C7QTSEGUM		:= 0
		oWsStrWbs:C7PRODUTO		:= ""
		oWsStrWbs:C7XIDBIO		:= ""
		oWsStrWbs:C7XITBIO		:= ""
		oWsStrWbs:C7XNUMEXT 	:= ""
		oWsStrWbs:C7OBS 		:= ""
		oWsStrWbs:XIDPROC 		:= ""
		oWsStrWbs:A2CGC 		:= ""
		aAdd(::WsConf:aConf, oWsStrWbs)
		oWsStrWbs := WSClassNew("STRWBS")
		Conout("Fim Query retornou vazio, resposta vazia padrão para o barramento " + Time())
		Return .T.
	EndIf

	While !(cALiasSC7)->(Eof())
		Conout("Envio pedido " + (cALiasSC7)->C7_NUM + " " + Time())
		cFil    := (cALiasSC7)->C7_FILIAL
		cXIDBIO    := (cALiasSC7)->C7_XIDBIO
		cNum    := (cALiasSC7)->C7_NUM
		cItem   := (cALiasSC7)->C7_ITEM
		cNumExt := (cALiasSC7)->C7_XNUM
		cIdProc := AllTrim(FWUUIDV4())
		While !(cALiasSC7)->(Eof()) .And. cFil == (cALiasSC7)->C7_FILIAL .And. cXIDBIO  == (cALiasSC7)->C7_XIDBIO .And. cNum  == (cALiasSC7)->C7_NUM
			Conout("Inicio envio item " + (cALiasSC7)->C7_ITEM + " " + Time())
			Conout("Inicio função FConvUmBio " + Time())
			aConv := U_FConvUmBio((cALiasSC7)->C7_PRODUTO, (cALiasSC7)->C7_QUANT, 00, "B")
			Conout("Fim função FConvUmBio " + Time())
			oWsStrWbs := WSClassNew("STRWBS")
			oWsStrWbs:STATUS		:= "1"
			oWsStrWbs:A2CGC := Posicione("SA2",01,xFilial("SA2")+(cALiasSC7)->C7_FORNECE+(cALiasSC7)->C7_LOJA, "A2_CGC")
			oWsStrWbs:C7ITEM		:= (cALiasSC7)->C7_ITEM
			oWsStrWbs:C7QTSEGUM	:= aConv[01]
			oWsStrWbs:C7PRODUTO	:= (cALiasSC7)->C7_PRODUTO
			oWsStrWbs:C7XIDBIO	:= (cALiasSC7)->C7_XIDBIO
			oWsStrWbs:C7XITBIO	:= (cALiasSC7)->C7_XIDART
			oWsStrWbs:C7XNUMEXT 	:= Iif(Empty((cALiasSC7)->C7_XNUM),"PEDERP",(cALiasSC7)->C7_XNUM)
			oWsStrWbs:C7OBS 		:= (cALiasSC7)->C7_NUM + " | " + EncodeUTF8(_noTags((cALiasSC7)->C7_OBS))
			oWsStrWbs:XIDPROC 	:= 	cIdProc


			aAdd(aZRecNo, (cALiasSC7)->R_E_C_N_O_)
			aAdd(::WsConf:aConf, oWsStrWbs)
			Conout("Inicio classe STRWBS " + Time())
			oWsStrWbs := WSClassNew("STRWBS")
			Conout("Fim classe STRWBS " + Time())
			Conout("Fim Inicio envio item " + (cALiasSC7)->C7_ITEM + " " + Time())
			(cALiasSC7)->(DbSkip())
			Conout("Fim Envio pedido " +(cALiasSC7)->C7_NUM + " " + Time())
		EndDo
		Conout("Inicio do For para atualizar os campos da SC7 dos pedidos enviados " + Time())
		For nX := 01 To Len(aZRecNo)
			SC7->(DbGoTo(aZRecNo[nX]))
			Conout("Reclock pedido recno " + cValToChar(aZRecNo[nX]) + " " + Time())
			RecLock("SC7", .F.)
			SC7->C7_XFLGWBS := "S"
			SC7->C7_XIDPROC := cIdProc
			SC7->C7_XQTENV := SC7->C7_XQTENV + 1
			SC7->(MsUnlock())
			Conout("Fim Reclock pedido recno " + cValToChar(aZRecNo[nX]) + " " + Time())
		Next nX
		Conout("Fim do For para atualizar os campos da SC7 dos pedidos enviados " + Time())
		Exit
	EndDo


	(cALiasSC7)->(DbCloseArea())
Return .T.

WsMethod WBSRET WsReceive WsWBSEnv WsSend WsWBSRet WsService REDWS1

	Local nRecno := 0
	Local nX	:= 00
	Local cObs 	:= "OK"
	Local cStatus := "1"

	Conout("VALTYPE: " + ValType(::WsWBSEnv:MSGRET))
	If ValType(::WsWBSEnv:MSGRET) == "C"
		//nRecno := U_F07Log01(::WsWBSEnv:XIDPROC,"U_REDSCH3")
		Conout("ENTROU NO IF")
		aRet := StrTokArr(::WsWBSEnv:MSGRET, ";")
		DbSelectArea("SC7")
		If DBOrderNickname("IDPROC")
			Conout("ENTROU NO IDPROC")
			If DbSeek(::WsWBSEnv:XIDPROC)
				Conout("ENTROU NO DBSEEK DO XIDPROC")
				If aRet[1] == "1"
					Conout("RETORNO 1")
					cIdProc := AllTrim(::WsWBSEnv:XIDPROC)
					While !SC7->(Eof()) .And. cIdProc == AllTrim(SC7->C7_XIDPROC)
						RecLock("SC7", .F.)
						SC7->C7_XFLGWBS := "I"
						SC7->C7_DATPRF := dDataBase + (SC7->C7_DATPRF - SC7->C7_EMISSAO)
						SC7->(MsUnlock())
						SC7->(DbSkip())
					EndDo
				ElseIf aRet[1] == "-1"
					Conout("RETORNO -1")
					cError := aRet[4]
					cObs 	:= cError
					cStatus := "2"
					U_WsLogBio("WBSRET", 1, cError)
				ElseIf aRet[1] == "0"
					Conout("RETORNO 0")
					cObs 	:= "RETORNO: 0"
					cStatus := "2"
					U_WsLogBio("WBSRET", 1, cObs)
				EndIf
			EndIf
		Else
			cStatus := "2"
			cObs	:= "Erro: Não foi encontrado o indice IDPROC no protheus."
			U_WsLogBio("WBSRET", 1, cObs)
		EndIf
	EndIf

	::WsWBSRet:XIDPROC 		:= WsWBSEnv:XIDPROC
	::WsWBSRet:MSGRET		:= cObs
	::WsWBSRet:STATUS 		:= cStatus

	/*/If nRecno > 0
	U_F07Log02(nRecno,::WsWBSRet:MSGRET, Iif (cStatus == "1",.T., .F.), "SC7", 1, SC7->C7_FILIAL + "|" + SC7->C7_NUM)
	Endif/*/	
Return( .T. )

WsMethod WDGRET WsReceive WsWDGEnv, WsPedido WsSend WsWDGRet WsService REDWS1

	Local nRecno	:= 0
	Local nX 		:= 0
	Local aRet 		:= {}
	Local aRetAux	:= {}
	Local cStatus 	:= "1"
	Local cObs 		:= "Ok"
	Local aPedidos  := {}

	U_WsLogBio("WDGRET", 1, "INICIALIZANDO O WDGRET")
	If ValType(::WSWDGENV:MSGRET) == "C"
		cIdProc := AllTrim(FWUUIDV4())
		nRecno := U_F07Log01(cIdProc,"U_REDSCH1")
		aRet := StrTokArr(::WsWDGEnv:MSGRET, ";")
		If aRet[1] == "1"
			For nX := 01 To Len(::WsPedido:LISTAWDG)
				aAdd(aPedidos,{ {"cCGC", 		::WsPedido:LISTAWDG[nX]:A2CGC},;
					{"cCONDPAG", 	::WsPedido:LISTAWDG[nX]:C7CONDPAG},;//{"cCONDPAG", 	aXml[3][nX]:_C7CONDPAG:TEXT},;
					{"cFilAtu", 	::WsPedido:LISTAWDG[nX]:C7FILIAL},;
					{"cITEMSC", 	::WsPedido:LISTAWDG[nX]:C7ITEM },;
					{"cNUMSC", 		::WsPedido:LISTAWDG[nX]:C7NUMSC},;
					{"cOBS", 		::WsPedido:LISTAWDG[nX]:C7OBS},;
					{"nPRECO", 		::WsPedido:LISTAWDG[nX]:C7PRECO},;
					{"cPRODUTO", 	::WsPedido:LISTAWDG[nX]:C7PRODUTO},;
					{"nQTSEGUM", 	::WsPedido:LISTAWDG[nX]:C7QTSEGUM},;
					{"cXIDBIO", 	::WsPedido:LISTAWDG[nX]:C7XIDBIO},;
					{"cDATPRF", 	::WsPedido:LISTAWDG[nX]:C7DATPRF},;
					{"cXITBIO", 	::WsPedido:LISTAWDG[nX]:C7XITBIO}})
			Next nX
			aRetAux := U_REDSCH1(aPedidos)
			If aRetAux[1] == "2"
				cStatus := aRetAux[1]
				cObs	:= aRetAux[2]
				U_WsLogBio("REDWS1 - WDGRET", 1, aRetAux[2])
			EndIf
		ElseIf aRet[1] == "-1"
			cObs := aRet[4]
			cStatus := "2"
			U_WsLogBio("REDWS1 - WDGRET", 1, cObs)
		EndIf
	Else
		cObs := "MSGRET NAO ENCONTRADO NA ESTRUTURA"
		cStatus := "2"
		U_WsLogBio("REDWS1 - WDGRET", 1, cObs)
	EndIf

	::WsWDGRet:XIDPROC 	:= ::WSWDGENV:XIDPROC
	::WsWDGRet:STATUS 	:= cStatus
	::WsWDGRet:MSGRET	:= cObs

	If nRecno > 0
		U_F07Log02(nRecno,::WsWDGRet:MSGRET, Iif(cStatus == "1",.T.,.F.), "SC7", 1, aPedidos[1][3][2] + "|" + aPedidos[1][10][2])
	Endif
Return .T.

WsMethod WFGRET WsReceive WsWFGEnv, WsContrato WsSend WsWFGRet WsService REDWS1

	Local cFilAtu	:= NIL
	Local nRecno	:= 0
	Local nX 		:= 0
	Local aRet 		:= {}
	Local aRetAux	:= {}
	Local cStatus 	:= "1"
	Local cObs 		:= "Ok"
	Local aCotacao  := {}

	U_WsLogBio("WFGRET", 1, "INICIALIZANDO O WFGRET")

	If ValType(::WsWFGEnv:MSGRET) == "C"

		nRecno := U_F07Log01(::WsWFGEnv:XIDPROC,"U_REDSCH2")
		U_WsLogBio("WFGRET", 1, "ENTROU NO IF DO MSGRET")
		aRet := StrTokArr(::WsWFGEnv:MSGRET, ";")
		If aRet[1] == "1"
			U_WsLogBio("WFGRET", 1, "RETORNOU 1")
			For nX := 01 To Len(::WsContrato:LISTAWFG)
				aAdd( aCotacao,{{"cCGC", 		::WsContrato:LISTAWFG[nX]:A2CGC },;
					{"cCONDPAG", 	::WsContrato:LISTAWFG[nX]:C8CONDPAG },;
					{"cFilAtu", 	::WsContrato:LISTAWFG[nX]:C8FILIAL },;
					{"cITEMSC", 	::WsContrato:LISTAWFG[nX]:C8ITEMSC },;
					{"cNUMSC", 		::WsContrato:LISTAWFG[nX]:C8NUMSC },;
					{"cOBS", 		::WsContrato:LISTAWFG[nX]:C8OBS },;
					{"nPRECO", 		::WsContrato:LISTAWFG[nX]:C8PRECO },;
					{"cPRODUTO", 	::WsContrato:LISTAWFG[nX]:C8PRODUTO },;
					{"nQTSEGUM", 	::WsContrato:LISTAWFG[nX]:C8QTSEGUM },;
					{"nPrazo", 		::WsContrato:LISTAWFG[nX]:C8PRAZO },;
					{"cXIDBIO", 	::WsContrato:LISTAWFG[nX]:C8XIDBIO },;
					{"cXCTBIO", 	::WsContrato:LISTAWFG[nX]:C8XCTBIO}})

				//{"cStatus", 	::WsContrato:LISTAWFG[nX]:STATUS },;
					//{"cTipo", 		::WsContrato:LISTAWFG[nX]:TIPO },;
					//{"cXCTBIO", 	::WsContrato:LISTAWFG[nX]:C8XCTBIO },;
				Next nX
			aRetAux := U_REDSCH2(aCotacao)
			If aRetAux[1] == "2"
				cStatus := aRetAux[1]
				cObs	:= aRetAux[2]
			Else
				U_WsLogBio("REDWS1 - WFGRET", 1, "SUCESSO")
			EndIf
		ElseIf aRet[1] == "-1"
			cObs 	:= aRet[4]
			cStatus := "2"
			U_WsLogBio("REDWS1 - WFGRET", 1, "ERRO BIONEXO ->" + cObs)
		EndIf
	Else
		cObs := "MSGRET NAO ENCONTRADO NA ESTRUTURA"
		cStatus := "2"
		U_WsLogBio("REDWS1 - WFGRET", 1, cObs)
	EndIf

	::WsWFGRet:XIDPROC 	:= ::WsWFGEnv:XIDPROC
	::WsWFGRet:STATUS 	:= cStatus
	::WsWFGRet:MSGRET	:= cObs

	If nRecno > 0
		U_F07Log02(nRecno,::WsWFGRet:MSGRET, Iif (cStatus == "1",.T., .F.), "SC8", 1, aCotacao[1][3][2] + "|" + aCotacao[1][11][2])
	Endif

	//U_WsLogBio("WFGRET", 1, "XIDPROC: " + ::WsWFGRet:XIDPROC + " - STATUS: " + ::WsWFGRet:STATUS + " - MSGRET: " + ::WsWFGRet:MSGRET  )
Return .T.
