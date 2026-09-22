#INCLUDE 'PROTHEUS.CH'
#Include "TOTVS.ch" 
/*/{Protheus.doc} F1200703

	Rotina para Seleção de Itens de Solicitações de Compras.
	
	@type Function User
	@author 	Paulo Krüger
	@since 		17/08/2017
	@version 	P12.7
	@Param		cAliasTMP, character,Alias temporario.
	@Obs	MAN0000007423046
/*/
User Function F1200703(cAliasTMP)
	Local aArea         := fwGetArea()                       as array
	Local aAreaSC1		:= fwGetArea()				 		 as Array
	Local aProds        := {}                                as array
	Local aRet          := {}                                as array
	Local cCodUser      := ''                                as character
	Local cFiltro       := ''                                as character
	Local cMtvNProc     := ""                                as character
	Local cNamUser      := ''                                as character
	Local cTpDtPrograda := SuperGetMv("MV_XDTPLAM", .F., "") as character // Tipos de Solicitação de Compras que mantem a data da SC
	Local lContinue     := .T.                               as logical
	Local lExibeTela    := .T.                               as logical
	Local lItMarka      := .F.                               as logical
	Local lMedic        := .F.                               as logical
	Local lMedPar       := .T.                               as logical
	Local nCt           := 0                                 as numeric
	Local nX            := 0                                 as numeric
	Local oMark         := GetMarkBrow()                     as object

	//Quando chamado de Medição manual ou Job não exibe tela
	If ISINCALLSTACK('U_F1200600')// .OR. ISINCALLSTACK('U_F1200601')
		lExibeTela := .F.
	EndIf		

	If lExibeTela
		//Verifica se existem ítens marcados
		(cAliasTMP)->(dbGoTop())
		While(cAliasTMP)->(!Eof()) .and. !lItMarka
			If !Empty((cAliasTMP)->TMP_OK)
				lItMarka := .T.
			EndIf
			(cAliasTMP)->(DbSkip())
		EndDo	
		If !lItMarka
			FWAlertWarning('Não há ítens selecionados.',  'Seleção incorreta de ítens.' ) 
			Return
		EndIf
		//Ajusta critério de filtro
		cFiltro	:= '!Empty((cAliasTMP)->TMP_OK)'
	Else
		//Ajusta critério de filtro
		cFiltro	:= '.T.'
	EndIf
	
	(cAliasTMP)->(dbGoTop())
	While (cAliasTMP)->(!Eof())
	
		If &cFiltro
			
				aAreaSC1 := SC1->(fwGetArea())
				DbSelectArea("SC1")
				SC1->(DbSetOrder(1))
			
				If SC1->(DbSeek((cAliasTMP)->(C1_FILIAL) + (cAliasTMP)->(C1_NUM) + (cAliasTMP)->(C1_ITEM)))
				If lExibeTela
					//Verifica no processamento se campo esta sendo processado por outra rotina	ou job (atraves do semaforo)
					//If Empty(SC1->C1_XNUMMED) .or. ((cAliasTMP)->TMP_OK == "S" .and. SC1->C1_XNUMMED == "XXXXXX") Thais Paiva - 09/12/2020
					If Empty(Alltrim(SC1->C1_XNUMMED)) .or. ((cAliasTMP)->TMP_OK == "S" .and. Alltrim(SC1->C1_XNUMMED) == "XXXXXX")
						If !LockByName('F1200701_' + (cAliasTMP)->(C1_FILIAL) + (cAliasTMP)->(C1_NUM) + (cAliasTMP)->(C1_ITEM) ,.F.,.F. )
							cMtvNProc += "O Registro ("+ (cAliasTMP)->(C1_FILIAL) + " - " + (cAliasTMP)->(C1_NUM) + " - " + (cAliasTMP)->(C1_ITEM) +") não será processado pois já esta sendo utilizado" + CRLF
							lContinue := .F.
						Else
							lContinue := .T.
						Endif
					Else
						cMtvNProc += "O Registro ("+ (cAliasTMP)->(C1_FILIAL) + " - " + (cAliasTMP)->(C1_NUM) + " - " + (cAliasTMP)->(C1_ITEM) +") já foi processado" + CRLF
						lContinue := .F.
					EndIf
				Else
					//Se for schedule, verifica o conteudo do campo SC1->C1_XNUMMED.
					//Se estiver preenchido com ZZZZZZ, significa que é de JOB mas que houve algum erro no processamento.
					//Limpa para processar novamente
					//Se houver outro valor, não processa
					//If !Empty(SC1->C1_XNUMMED) .and. SC1->C1_XNUMMED != "ZZZZZZ" Thais Paiva - 09/12/2020
					If !Empty(Alltrim(SC1->C1_XNUMMED)) .and. Alltrim(SC1->C1_XNUMMED) != "ZZZZZZ"
						lContinue := .F.
					Else
						SC1->(RecLock("SC1",.F.))
							SC1->C1_XNUMMED := "ZZZZZZ" //Grava que esta sendo processado pelo job
							SC1->C1_XUSR    := RetCodUr()
						SC1->(MsUnlock())
						
						lContinue := .T.
					EndIf
				EndIf
			EndIf

			If lContinue
				cCodUser	:= (cAliasTMP)->(C1_USER)		//Retorna o Codigo do Usuario
				cNamUser	:= Alltrim(UsrRetName( cCodUser ))	//Retorna o nome do usuario
				
				IF Alltrim((cAliasTMP)->(C1_XTPSC)) $ cTpDtPrograda
					cDatPrf  := (cAliasTMP)->(C1_FILIAL) + (cAliasTMP)->(C1_PRODUTO) + (cAliasTMP)->(C1_LOCAL) + DTOS((cAliasTMP)->C1_DATPRF) + (cAliasTMP)->(C1_CC)  
				Else
					cDatPrf  := (cAliasTMP)->(C1_FILIAL) + (cAliasTMP)->(C1_PRODUTO) + (cAliasTMP)->(C1_LOCAL) + (cAliasTMP)->(C1_CC)  
				EndIf
			
				aAdd(aProdSel,{	(cAliasTMP)->(RECNO)		,	;	//[01] Registro da SC 
								(cAliasTMP)->(C1_FILIAL)	,	;	//[02] Filial da SC 
								(cAliasTMP)->(C1_NUM)		,	;	//[03] Numero da SC 
								(cAliasTMP)->(C1_ITEM)		,	;	//[04] Item da SC 
								(cAliasTMP)->(C1_PRODUTO)	,	;	//[05] Produto 
								(cAliasTMP)->(C1_DESCRI)	,	;	//[06] Descricao produto 
								(cAliasTMP)->(C1_QUANT)		,	;	//[07] Quantidade 
								(cAliasTMP)->(C1_XTOTAL)	,	;	//[08] Preço total
								(cAliasTMP)->(C1_TOTAL)		,	;	//[09] Valor total 
								(cAliasTMP)->(C1_LOCAL)		,	;	//[10] Local de estoque 
								(cAliasTMP)->(C1_EMISSAO)	,	;	//[11] Emissao 
								(cAliasTMP)->(C1_FORNECE)	,	;	//[12] Fornecedor 
								(cAliasTMP)->(C1_LOJA)		,	;	//[13] Loja do fornecedor 
								(cAliasTMP)->(C1_GRUPCOM)	,	;	//[14] Grupo de compras 
								(cAliasTMP)->(C1_OBS)		,	;	//[15] Observações 
								(cAliasTMP)->(C1_VUNIT)		,	;	//[16] Valor unitario
								(cAliasTMP)->(C1_CC)		,	;	//[17] Centro de custo 
								(cAliasTMP)->(C1_XTPSC)		,	;	//[18] Tipo de solicitacao 
								(cAliasTMP)->(C1_FLAGGCT)	,	;	//[19] Flag da solicitacao 
								(cAliasTMP)->(C1_CONTA)		,	;	//[20] Conta contabil 
								(cAliasTMP)->(C1_ITEMCTA)	,	;	//[21] Item contabil 
								(cAliasTMP)->(C1_CLVL)		,	;	//[22] Classe de valor
								0							,	;	//[23] Quantidade aglutinada
								0							,	;	//[24] Valor aglutinado
								''							,	;	//[25] ID de integração
								''							,	;	//[26] Flag GCT
								''							,	;	//[27] Status da medição
								''							,	;	//[28] Observacoes da medição
								''							,	;	//[29] Numero da medição
								''							,	;	//[30] Item da medição
								''							,	;	//[31] Origem da medição
								''							,	;	//[32] Data da medição
								''							,	;	//[33] Hora da medição
								''							,	;	//[34] Filial do contrato
								''							,	;	//[35] Numero do contrato
								''							,	;	//[36] Revisao do contrato
								''							,	;	//[37] Data inicial do contrato
								''							,	;	//[38] Data final do contrato 
								''							,	;	//[39] Vigencia do contrato
								''							,	;	//[40] Num do PC 
								''							,	;	//[41] Item do PC
								cCodUser					,	;	//[42] Código do usuário
								(cAliasTMP)->(C1_XCODSET)	,	;	//[43] Setor
								(cAliasTMP)->(C1_XMOTIVO)	,	;	//[44] Motivo
								 cDatPrf,;//[45] Filial + Produto + Local + Centro de Custo + Previsão Entrega
								(cAliasTMP)->(C1_XINFPAC),;//[46]  Estava em uso
								(cAliasTMP)->C1_DATPRF})//[47] Previsão de Entrega - DATAPSOLIC
			EndIf
							  
		EndIf
		(cAliasTMP)->(DbSkip())
	EndDo
	
	//Agrupa Ítens
	U_F1200704()
		
	//Seleciona Contratos
	U_F1200705()
		
	//Exibe mensagem de processamento
	If ISINCALLSTACK('U_F1200601') //Quando medição manual
		lExibeTela := .T.
	EndIf

	//Prepara Medições
	If lExibeTela
		Processa( {|| U_F1200708() }, 'Aguarde...', 'Processando medições...',.F.)
	Else
		U_F1200708()
	EndIf
	
	If lExibeTela .AND. LEN(aProdSel) > 0
		U_F1200711()
	EndIf
	
	//Grava log de processamento
	U_F1200714()

	If Empty(cMtvNProc)
		If lExibeTela
			FWAlertSuccess('Medição automatizada', 'Concluída com sucesso')
		Else
			FwLogMsg("INFO",,"F1200703","","","01","[F1200703][SUCCESS] Medicao automatizada concluida com sucesso [" +  AllTrim( cEmpAnt ) + "] da Filial [" + AllTrim( cFilAnt ) + "]",0,0,{})
		Endif
	Else
		If lExibeTela
			FWAlertError("Medição automatizada",cMtvNProc)
		Else
			FwLogMsg("ERROR",,"F1200703","","","01","[F1200703][ERROR] Medicao automatizada concluida com ERROR [" +  AllTrim( cEmpAnt ) + "] da Filial [" + AllTrim( cFilAnt ) + cMtvNProc + "]",0,0,{})
		Endif
	Endif
	
	For nX := 1 to Len(aProdSel)
		UnLockByName('F1200701_' + aProdSel[nX][2] + aProdSel[nX][3] + aProdSel[nX][4] ,.F.,.F. )	
	Next nX
	
	//Limpa campo de medição caso não tenha sido atualizado
	ClrNumMed()
	
	ASIZE(aProdSel  , 0)
	ASIZE(aAgrup    , 0)
	ASIZE(aSelContr , 0)
	ASIZE(aListMedic, 0)

	fwrestarea(aAreaSC1)
	fwrestarea(aArea)
	
Return

Static Function RetCodUr()
return RetCodUsr()
/*/{Protheus.doc} ClrNumMed

	 Limpa o numero de medição, caso tenha ocorrido erro

	@type  Function Static
	@version 12.1.27
	@author  Cleiton Genuino da Silva
	@since   25/07/2023
/*/
Static Function ClrNumMed()
	Local aAreaSC1 := SC1->(fwGetArea())
	Local nI := 1
	
	//Percorre o array de solicitações selecionadas para medição, verifica se está com ZZZZZZ, se sim, altera para vazio para processar novamente
	SC1->(DbSetOrder(1))
	
	for nI := 1 to len(aProdSel)
		if aProdSel[nI][01] > 0
			SC1->(DbGoTo(aProdSel[nI][01]))
	
			if !empty(alltrim(SC1->C1_XNUMMED)) .and. SC1->C1_XNUMMED == "ZZZZZZ"
				SC1->(Reclock("SC1",.F.))
					SC1->C1_XNUMMED := ""
				SC1->(MsUnlock())
			endif
		endif
	next nI
	
	fwrestarea	(aAreaSC1)
Return
