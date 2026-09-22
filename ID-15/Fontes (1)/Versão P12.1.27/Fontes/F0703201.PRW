#include "totvs.ch"

/*/{Protheus.doc} F0703201
Função responsável pelas integrações de pedidos de vendas
@type User function
@author Paulo Krüger
@since 20/01/2017
@version 12.7
@param oCabec, object, descricao
@param oCorpo, object, descricao
@param oParcelas, object, descricao
@param nOpcao, numeric, descricao
@project MAN0000007423041_EF_032
@return cRET
/*/
User Function F0703201(oCabec,oCorpo,oParcelas,nOpcao)

	Local aCabec 	:= {}
	Local aItens 	:= {}
	Local aLinha	:= {}
	Local aLog 		:= {}
	Local cFilPed 	:= ''
	Local cNumPv 	:= ''
	Local cRet 		:= ''
	Local lRet 		:= .T.
	Local cTipo 	:= 'N'
	Local nX 		:= 0
	Local nY		:= 0
	Local cCond		:= GETMV('FS_CONDFAT')
	Local nOperac	:= nOpcao
	Local nContParc	:= 0
	Local cTES		:= ''
	Local nCount	:= 0
	Local nRegLog	:= 0
	Local cAlias01	:= ''
	Local cXID		:= U_GetIntegID()
	Local nTamC6Desc:= TamSX3('C6_DESCRI')[01]
	Local cNum		:= ''
	Local cFilPVDest:= ''
	Local cCliPVDest:= ''
	Local cLojPVDest:= ''
	Local cXIDPVDest:= ''
	Local cTipoCli	:= ''
	Local lSucesso  := .F.
	Local cCodPro   := ""
	Local nTamProd  := TamSX3("B1_COD")[1]
	Local cNNRLocal := ""
	Local nTamLocal := TamSX3("B2_LOCAL")[1]
	Local cCodCli   := ""
	Local cLojCli   := ""
	Local nPerDes   := 0
	Local nValDes   := 0   
	Local _nQtdItem := 0

	Local bBlock
	
	Local _aCmpX3	:= {} //Thais Paiva - Compatibilização P27

	Private cErrorL			:= ""
	Private lAutoErrNoFile 	:= .T.
	Private lMsErroAuto 	:= .F.

	bBlock 	:= ErrorBlock({|e|ChkErr(e)})

	/*==============================================================|
	|Validações de Cabeçalho.                                       |
	|==============================================================*/
	If Len(oCabec:cFILREG) < FWSizeFilial()
		cFilPed := oCabec:cFILREG + SPACE(FWSizeFilial() - Len(oCabec:cFILREG))
	ElseIf 	Len(oCabec:cFILREG) > FWSizeFilial()
		lRet := .F.
		cRet := 'ERRO|PARAMETRO OBRIGATORIO INVALIDO: CFILREG (Filial) ' + oCabec:cFILREG + ' - NUM PED FRONT: ' + oCabec:cNum + CRLF
	ElseIf Len(oCabec:cFILREG) == FWSizeFilial()
		cFilPed := oCabec:cFILREG
	EndIf

	If lRet
		If !ExistCpo('SM0',cEmpAnt + cFilPed)
			lRet := .F.
			cRet := 'ERRO|PARAMETRO OBRIGATORIO INVALIDO: CFILREG (Filial) - NUM PED FRONT: ' + oCabec:cNum + CRLF
		Else
			cFilAnt := cFilPed
		EndIf
	EndIf

	If lRet .And. Empty(oCabec:cNum)
		lRet := .F.
		cRet := 'ERRO|PARAMETRO OBRIGATORIO NAO INFORMADO: CNUM (Numero do Pedido no Front) - NUM PED FRONT: ' + oCabec:cNum + CRLF
	EndIf

	If lRet .And. Empty(oCabec:cEMISSAO)
		lRet := .F.
		cRet := 'ERRO|PARAMETRO OBRIGATORIO NAO INFORMADO: CEMISSAO (Data de Emissao) - NUM PED FRONT: ' + oCabec:cNum + CRLF
	EndIf

	If lRet .And. Empty(oCabec:cIDCLIEN)
		lRet := .F.
		cRet := 'ERRO|PARAMETRO OBRIGATORIO NAO INFORMADO: cIDCLIEN (CNPJ/CPF do Cliente) - NUM PED FRONT: ' + oCabec:cNum + CRLF
	EndIf

	If lRet
		SA1->(DbSetOrder(03))
		If SA1->(DbSeek(xFilial('SA1') + oCabec:cIDCLIEN))
			cCodCli  := SA1->A1_COD
			cLojCli  := SA1->A1_LOJA
			cTipoCli := SA1->A1_TIPO
			nPerDes  := SA1->A1_DESC
		Else
			SA1->(DbOrderNickName("EF0703201"))
			If SA1->(DbSeek(xFilial('SA1') + oCabec:cIDCLIEN))
				cCodCli  := SA1->A1_COD
				cLojCli  := SA1->A1_LOJA
				cTipoCli := SA1->A1_TIPO
				nPerDes  := SA1->A1_DESC
			EndIf
		EndIf
		If Empty(cTipoCli)
			lRet := .F.
			cRet := 'ERRO|CLIENTE NAO CADASTRADO - NUM PED FRONT: ' + oCabec:cNum + CRLF
		EndIf
	EndIf

	If lRet
		cAlias01 := GetNextAlias()
		BeginSql Alias cAlias01
		%noparser%
		SELECT	SC5.C5_FILIAL	AS	FILIAL	,
		SC5.C5_NUM		AS	NUMPED	,
		SC5.C5_XNUM		AS	NUMFRT
		FROM 	%Table:SC5% SC5
		WHERE 		SC5.%notDel%
		AND	SC5.C5_FILIAL	= %exp:cFilPed%
		AND SC5.C5_XNUM		= %exp:oCabec:cNum%
		EndSql
		(cAlias01)->(DbGoTop())

		If (cAlias01)->(!Eof())
			lRet := .F.
			cRet := 'ERRO|PED FRONT: ' + oCabec:cNum + ' JA CONSTA NO SISTEMA PROTHEUS' + CRLF
		EndIf

		If Select(cAlias01) > 0
			(cAlias01)->(DbCloseArea())
		EndIf
	EndIf

	/*==============================================================|
	|Validações de Parcelas.                                        |
	|==============================================================*/
	If lRet
		//Início - Thais Paiva - Compatibilização P27
		//SX3->(dBSetOrder(02))
		//SX3->(DbSeek('C5_PARC',.T.))
		//While SX3->(!Eof()) .and. SUBSTR(SX3->X3_CAMPO,01,07) == 'C5_PARC'
		_aCmpX3 := FWSX3Util():GetAllFields( "SC5" , .T. )
		For _nC5 := 1 To Len(_aCmpX3)
			If SUBSTR(_aCmpX3[_nC5],01,07) == "C5_PARC"
			//If X3USO(SX3->X3_USADO)
				If X3USO(GetSx3Cache(_aCmpX3[_nC5], 'X3_USADO'))
					nContParc += 01
				EndIf
			//SX3->(dBSkip())
			EndIf
		//EndDo
		Next _nC5
		//Fim - Thais Paiva - Compatibilização P27

		If Len(oParcelas) > nContParc .or. nContParc == 0
			lRet := .F.
			cRet := 'ERRO|QUANTIDADE DE PARCELAS INVÁLIDAS - NUM PED FRONT: ' + oCabec:cNum + CRLF
		EndIf
	EndIf

	If lRet

		AAdd(aCabec,{'C5_FILIAL'	,cFilPed			  , Nil})
		AAdd(aCabec,{'C5_TIPO' 		,cTipo				  , Nil})
		AAdd(aCabec,{'C5_EMISSAO' 	,CTOD(oCabec:cEMISSAO), Nil})
		AAdd(aCabec,{'C5_CLIENTE' 	,cCodCli              , Nil})
		AAdd(aCabec,{'C5_LOJACLI' 	,cLojCli              , Nil})
		AAdd(aCabec,{'C5_TIPOCLI' 	,cTipoCli			  , Nil})
		AAdd(aCabec,{'C5_CONDPAG' 	,cCOND				  , Nil})
		AAdd(aCabec,{'C5_XNUM'		,oCabec:cNum		  , Nil})
		AAdd(aCabec,{'C5_XID'		,cXID				  , Nil})
		AAdd(aCabec,{'C5_ORIGEM'    ,'F0703201'           , Nil})
		AAdd(aCabec,{'C5_XNOMEPA'   ,oCabec:cNOMEP    	  , Nil})
		AAdd(aCabec,{'C5_XDATANA'   ,CTOD(oCabec:cDATANAS), Nil})
		AAdd(aCabec,{'C5_XCPFPAC'   ,oCabec:cCPFNAS       , Nil})
		AAdd(aCabec,{'C5_XNUMATE'   ,oCabec:cNUMATE       , Nil})
		AAdd(aCabec,{'C5_XTIPO'     ,oCabec:cXTIPO        , Nil})

		For nX := 01 To Len(oParcelas)
			cNomParc	:= 'C5_PARC' + ALLTRIM(STR(nX))
			cNomVenc	:= 'C5_DATA' + ALLTRIM(STR(nX))
			AAdd(aCabec,{cNomParc	,VAL(oParcelas[nX]:cValor)	,Nil})
			AAdd(aCabec,{cNomVenc	,CTOD(oParcelas[nX]:cVencto),Nil})
		Next nX

		SB1->(DbSetOrder(1))
		SBZ->(dBSetOrder(1))
		NNR->(DbSetOrder(1))

		For nX := 1 To Len(oCorpo)

			cCodPro   := ""
			cNNRLocal := ""
			cTES      := ""

			If Empty(oCorpo[nX]:cITEM)
				lRet := .F.
				cRet += 'ERRO|PARAMETRO OBRIGATORIO NAO INFORMADO: CITEM (Item do PV) - NUM PED FRONT: ' + oCabec:cNum + CRLF
				Exit
			EndIf

			If Empty(oCorpo[nX]:cProduto)
				lRet := .F.
				cRet += 'ERRO|PARAMETRO OBRIGATORIO NAO INFORMADO: CPRODUTO - NUM PED FRONT: ' + oCabec:cNum + ' ITEM: ' + oCorpo[nX]:cITEM + CRLF
			Else
				cCodPro := PadR(oCorpo[nX]:cProduto,nTamProd)
				If !SB1->(DbSeek(XFilial("SB1")+cCodPro))
					lRet := .F.
					cRet += 'ERRO|PRODUTO NAO CADASTRADO - NUM PED FRONT: ' + oCabec:cNum + ' ITEM: ' + oCorpo[nX]:cITEM  + ' PRODUTO: ' + cCodPro + CRLF
				EndIf
			EndIf
/*
			If Empty(oCorpo[nX]:cLocal)
				lRet := .F.
				cRet += 'ERRO|PARAMETRO OBRIGATORIO NAO INFORMADO: CLOCAL (Local) - NUM PED FRONT: ' + oCabec:cNum + ' ITEM: ' + oCorpo[nX]:cITEM + CRLF
			Else
				cNNRLocal := PadR(oCorpo[nX]:cLocal,nTamLocal)
				If !NNR->(DbSeek(XFilial("NNR")+cNNRLocal))
					lRet := .F.
					cRet += 'ERRO|LOCAL DE ESTOQUE NAO CADASTRADO - NUM PED FRONT: ' + oCabec:cNum + ' ITEM: ' + oCorpo[nX]:cITEM  + ' LOCAL: ' + cNNRLocal + CRLF
				ElseIf lRet
					CriaSB2(cCodPro, cNNRLocal)
				EndIf
			EndIf
*/
			If SBZ->(DbSeek(cFilPed + cCodPro))
				cTES := SBZ->BZ_TS
				If Empty(cTES)
					lRet := .F.
					cRet += 'ERRO|O TES ESTA EM BRANCO NA TABELA SBZ (Indicadores de Produtos) - NUM PED FRONT: ' + oCabec:cNum + ' ITEM: ' + oCorpo[nX]:cITEM + ' PRODUTO: ' + cCodPro + CRLF
				EndIF					 
			Else
				lRet := .F.
				cRet += 'ERRO|PRODUTO NAO ENCONTRADO NA TABELA SBZ (Indicadores de Produtos) - NUM PED FRONT: ' + oCabec:cNum + ' ITEM: ' + oCorpo[nX]:cITEM + ' PRODUTO: ' + cCodPro + CRLF
			EndIf

			// ID 1285
			// Alterado validação de local padrao para SBZ. 	
			If Empty(SBZ->BZ_LOCPAD)
				lRet := .F.
				cRet += 'ERRO|LOCAL PADRAO NAO INFORMADO NA SBZ: - NUM PED FRONT: ' + oCabec:cNum + ' ITEM: ' + oCorpo[nX]:cITEM + CRLF
			Else
				cNNRLocal := PadR(SBZ->BZ_LOCPAD,nTamLocal)
				If !NNR->(DbSeek(XFilial("NNR")+cNNRLocal))
					lRet := .F.
					cRet += 'ERRO|LOCAL DE ESTOQUE DA SBZ NAO CADASTRADO - NUM PED FRONT: ' + oCabec:cNum + ' ITEM: ' + oCorpo[nX]:cITEM  + ' LOCAL: ' + cNNRLocal + CRLF
				ElseIf lRet
					CriaSB2(cCodPro, cNNRLocal)
				EndIf
			EndIf

			If Empty(oCorpo[nX]:cQTDVEN)
				lRet := .F.
				cRet += 'ERRO|PARAMETRO OBRIGATORIO NAO INFORMADO: CQTDVEN (Quantidade) - NUM PED FRONT: ' + oCabec:cNum + ' ITEM: ' + oCorpo[nX]:cITEM + CRLF
			EndIf

			If Empty(oCorpo[nX]:cPRCVEN)
				lRet := .F.
				cRet += 'ERRO|PARAMETRO OBRIGATORIO NAO INFORMADO: CPRCVEN (Preço) - NUM PED FRONT: ' + oCabec:cNum + ' ITEM: ' + oCorpo[nX]:cITEM + CRLF
			EndIf

			If Empty(oCorpo[nX]:cValor)
				lRet := .F.
				cRet += 'ERRO|PARAMETRO OBRIGATORIO NAO INFORMADO: CVALOR (Valor) - NUM PED FRONT: ' + oCabec:cNum + ' ITEM: ' + oCorpo[nX]:cITEM + CRLF
			EndIf

			If !lRet
				Exit
			EndIf

			aLinha := {}
			AAdd(aLinha,{'C6_FILIAL'	,cFilPed					 	 , Nil})
			AAdd(aLinha,{'C6_ITEM'		,StrZero(Val(oCorpo[nX]:cITEM),2), Nil})
			AAdd(aLinha,{'C6_PRODUTO'	,cCodPro                         , Nil})
			AAdd(aLinha,{'C6_DESCRI'	,PadR(GetAdvFVal('SB1','B1_DESC',xFilial('SB1') + cCodPro,1,''),nTamC6Desc), NIL})
			AAdd(aLinha,{'C6_QTDVEN'	,Val(oCorpo[nX]:cQTDVEN)		 , Nil})
			AAdd(aLinha,{'C6_PRCVEN'	,Val(oCorpo[nX]:cPRCVEN)		 , Nil})
			AAdd(aLinha,{'C6_VALOR'		,Val(oCorpo[nX]:cValor)			 , Nil})
			AAdd(aLinha,{'C6_TES'		,cTES							 , Nil})
			AAdd(aLinha,{'C6_LOCAL'		,cNNRLocal                       , Nil})
			AAdd(aLinha,{'C6_CLI'		,cCodCli                         , Nil})
			AAdd(aLinha,{'C6_LOJA'		,cLojCli                         , Nil})
			AAdd(aLinha,{'C6_QTDLIB'	,0								 , Nil})
			AAdd(aLinha,{'C6_PRUNIT'	,Val(oCorpo[nX]:cPRCVEN)		 , Nil})
			AAdd(aLinha,{'C6_XFATREM'	,oCorpo[nX]:cXFATREM             , Nil})

			If !Empty(oCorpo[nX]:cCC)
				AAdd(aLinha,{'C6_CC', oCorpo[nX]:cCC, Nil})
			ElseIf !Empty(oCorpo[nX]:cXSETOR)
				AAdd(aLinha,{'C6_CC', Posicione("P11",1,XFilial("P11")+oCorpo[nX]:cXSETOR,"P11_CCUSTO"), Nil})
			EndIf
			
			AAdd(aItens,aLinha)

			nValDes += Val(oCorpo[nX]:cValor) * (nPerDes / 100)

		Next nX

		AAdd(aCabec,{'C5_DESCONT', Val(oCabec:cDESCONT) + nValDes, Nil})

	EndIf

	If lRet
		Begin Transaction
			nRegLog := U_F07LOG01(cXID,{oCabec,oCorpo})
		End Transaction

		Pergunte('MTA410',.F.)

		mv_par01 := 2

		MsExecAuto({|x,y,z| MATA410(x,y,z)}, aCabec,aItens,nOperac)
		If lMsErroAuto
			cRet := 'ERRO|EXECUCAO DA ROTINA AUTOMATICA NUM PED FRONT: ' + oCabec:cNum + CRLF
			aLog := GetAutoGRLog()
			For nY := 1 To Len(aLog)
				cRet += aLog[nY] + CRLF
			Next nY
			cRet += '|NUM PED FRONT: ' + oCabec:cNum
			Reclock('P22',.T.)
			P22->P22_FILIAL	:=	xFilial('P22')
			P22->P22_EMPPV	:=	cEmpAnt
			P22->P22_FILPV	:=	cFilPed
			P22->P22_NUMPV	:=	cNumPv
			P22->P22_DTPV	:=	DATE()
			P22->P22_HRPV	:=	TIME()
			P22->P22_STATPV	:=	'2'
			P22->P22_ID		:=	cXID
			P22->P22_OBSERV	:=	cRet + CRLF
			P22->(MSUNLOCK())
		Else
			cAlias01 := GetNextAlias()
			BeginSql Alias cAlias01
			%noparser%
			SELECT	SC5.C5_FILIAL	AS	FILIAL	,
			SC5.C5_NUM		AS	NUMPED	,
			SC5.C5_CLIENTE	AS	CODCLI	,
			SC5.C5_LOJACLI	AS	LOJCLI	,
			SC5.C5_XID		AS	IDINTG
			FROM 	%Table:SC5% SC5
			WHERE 	SC5.%notDel%
			AND	SC5.C5_XID	= %exp:cXID%
			EndSql

			(cAlias01)->(DbGoTop())

			If (cAlias01)->(!Eof())
				cNumPv		:= (cAlias01)->NUMPED
				cFilPVDest	:= (cAlias01)->FILIAL
				cCliPVDest	:= (cAlias01)->CODCLI
				cLojPVDest	:= (cAlias01)->LOJCLI
				cXIDPVDest	:= (cAlias01)->IDINTG
			EndIf

			If Select(cAlias01) > 0
				(cAlias01)->(dbCloseArea())
			EndIf
				
			If !Empty(cNumPv) 
				cRet += 'OK|NUM PED FRONT: ' + oCabec:cNum + ' NUM PED PROTHEUS: ' + cNumPv + CRLF
				lSucesso := .T.
				Reclock('P22',.T.)
				P22->P22_FILIAL	:=	xFilial('P22')
				P22->P22_EMPPV	:=	cEmpAnt
				P22->P22_FILPV	:=	cFilPed
				P22->P22_NUMPV	:=	cNumPv
				P22->P22_DTPV	:=	DATE()
				P22->P22_HRPV	:=	TIME()
				P22->P22_STATPV	:=	'1'
				P22->P22_ID		:=	cXID
				P22->P22_OBSERV	:=	cRet + CRLF
				P22->(MSUNLOCK())
			Else
				cRet += 'ERRO|FALHA NA INTEGRAÇÃO DO PEDIDO. NUM PED FRONT: ' + oCabec:cNum  + CRLF
				Reclock('P22',.T.)
				P22->P22_FILIAL	:=	xFilial('P22')
				P22->P22_EMPPV	:=	cEmpAnt
				P22->P22_FILPV	:=	cFilPed
				P22->P22_NUMPV	:=	cNumPv
				P22->P22_DTPV	:=	DATE()
				P22->P22_HRPV	:=	TIME()
				P22->P22_STATPV	:=	'2'
				P22->P22_ID		:=	cXID
				P22->P22_OBSERV	:=	cRet + CRLF
				P22->(MSUNLOCK())
			EndIf
		EndIf

		//Grava Log de Execução do WS de Inclusão do Pedido de Venda
		U_F07Log02(nRegLog, cRet, lSucesso, "SC5", 1, XFilial("SC5")+cNumPv)

	EndIf

	If !Empty(cRet)
		U_F0703203(cFilPVDest, cCliPVDest, cLojPVDest, cNumPv, cRet)
	EndIf

	ErrorBlock(bBlock)
	If !Empty(cErrorL)
		cRet := "ERRO DE PROGRAMACAO | " + CRLF + cErrorL
	EndIf

Return cRet

Static Function ChkErr(oErroArq)

	Local nI:= 0

	If oErroArq:GenCode > 0
		cErrorL := '(' + Alltrim(Str(oErroArq:GenCode)) + ') : ' + AllTrim(oErroArq:Description) + CRLF
	EndIf

	nI := 2

	While (!Empty(ProcName(ni)))
		cErrorL += Trim(ProcName(ni)) + "(" + Alltrim(Str(ProcLine(ni))) + ") " + CRLF
		ni ++
	End
	If Intransact()
		cErrorL +="Transacao aberta desarmada"
		DisarmTransaction()
	EndIf
	Break
Return
 
Static Function fExcPVenda(aCabec, aItens, cRet, cNumPv)

Local nY		:= 0
Local lRet		:= .T.
Local aRet		:= {}
Local aLog		:= {}
DEFAULT aCabec	:= {}
DEFAULT aItens	:= {} 
Private lMsErroAuto := .F.
Private lAutoErrNoFile := .T.
                              
	DbSelectArea("SC5") 
	DbSetOrder(1)
	DbSeek(xFilial('SC5') + cNumPv)
	AAdd(aCabec,{'C5_NUM' 		,cNumPv	 	,Nil})
	
	MsExecAuto({|x,y,z| MATA410(x,y,z)}, aCabec,aItens,5)
	
    //Foi colocado o seek após a exclusao porque o execauto estava apresentando problemas e nao estava trazendo a variavel lMsErroAuto como .T.              
	DbSelectArea("SC5") 
	DbSetOrder(1)
	If lMsErroAuto .Or. SC5->(DbSeek(xFilial('SC5') + cNumPv))
		lRet := .F.
		cRet += 'ERRO|EXCLUSAO PEDIDO FRONT: ' + ALLTRIM(SC5->C5_XNUM) + ' / ' + 'PEDIDO PROTHEUS: ' + ALLTRIM(SC5->C5_NUM) + '. OBS: ' + CRLF
		aLog := GetAutoGRLog() 
		For nY := 1 To Len(aLog)
			cRet += aLog[nY] + CRLF
		Next nY
	Else
		lRet := .T.
		cRet += 'OK|EXCLUSAO PEDIDO FRONT: ' + ALLTRIM(SC5->C5_XNUM) + ' / ' + 'PEDIDO PROTHEUS: ' + ALLTRIM(SC5->C5_NUM) + ' QUANTIDADE DIVERGENTE DO XML. OBS: ' + CRLF
	EndIf 


Return(lRet)
