#Include 'Protheus.ch'
#INCLUDE "totvs.ch"

/*/{Protheus.doc} F0703308  
Função responsável pelo cancelamento de da devolução de Nota Fiscal de Saída e Pedido de Venda 
@type function
@author Rafael Falco
@since 14/05/2018
@version 12.7
@param oCabec, object, Dados do cabeçalho da nota fiscal
@param oCorpo, object, Dados do item da nota fiscal
@param nOperac, numérico, Operação utilizada sendo 3 para inclusão e 5 para exclusão
@param nTpMetd, numérico, 1=DevolverDocEntrada, 2=CancelarDocDevolucao
@project MAN0000007423041_EF_036
@return cRET
/*/ 

User Function F0703308(oCabec, nOperac, nTpMetd)

	Local aCabec	:= {}
	Local aConv     := {}
	Local aExcNF	:= {}
	Local aExcTit	:= {}
	Local aImp		:= {}
	Local aItens	:= {}
	Local aLinha	:= {}
	Local aLog 		:= {}
	Local aTitulo 	:= {}
	Local bBlock 	:= ErrorBlock({|e|ChkErr(e)})
	Local cFilDoc 	:= ""
	Local cRet 		:= "ERRO|"
	Local cXID		:= U_GetIntegID()
	Local cXIDOld	:= ""
	Local lRet 		:= .T.
	Local nTamDoc	:= TamSX3("F2_DOC")[1]
	Local nTamCli	:= TamSX3("F2_CLIENTE")[1]
	Local nTamLoja 	:= TamSX3("F2_LOJA")[1]
	Local nTamSer  	:= TamSX3("F2_SERIE")[1]
	Local nX       	:= 0
	Local nY		:= 0
	Local nZ 		:= 0
	Local nRegLog	:= 0
	Local cIndKey  	:= ''
	Local nTamTgDv  := TamSX3("F2_XDEVFRO")[1]
	Local cQuery    := ""
	Local cAlias1   := GetNextAlias()

	Private cErrorL			:= ""
	Private lAutoErrNoFile 	:= .T.
	Private lMsErroAuto 		:= .F.
	Private CUSERNAME 		:= "INTNFD"
	Private aRegSD2	:= {} 
	Private aRegSE1	:= {}
	Private aRegSE2	:= {}

	cFilDoc := Alltrim(oCabec:cFilReg) 
	Begin Transaction
    	nRegLog := U_F07LOG01(cXID,{oCabec,,nOperac})
	End Transaction

	If Empty(cFilDoc) .Or. !ExistCpo("SM0",cEmpAnt + cFilDoc)
		lRet := .F.
		cRet += "PARAMETRO OBRIGATORIO INVALIDO: CFILREG" + CRLF
	Else 
		cFilAnt := cFilDoc
	EndIf
	
	If nTpMetd == 1
		If lRet .And. Empty(oCabec:cDoc)
			lRet := .F.
			cRet += "PARAMETRO OBRIGATORIO INVALIDO: CDOC" + CRLF
		EndIf
	Else
		If lRet .And. Empty(oCabec:cTagDev)
			lRet := .F.
			cRet += "PARAMETRO OBRIGATORIO INVALIDO: cTAGDEV" + CRLF
		EndIf	
	EndIf
	
	If nTpMetd == 1
		If lRet .And. Empty(oCabec:cSerie)
			lRet := .F.
			cRet += "PARAMETRO OBRIGATORIO INVALIDO: CSERIE" + CRLF
		EndIf
	EndIf 
	
	If lRet .And. Empty(oCabec:cFornece)
		lRet := .F.
		cRet += "PARAMETRO OBRIGATORIO INVALIDO: CFORNECE" + CRLF
	EndIf  
	
	If lRet .And. Empty(oCabec:cLoja)
		lRet := .F.
		cRet += "PARAMETRO OBRIGATORIO INVALIDO: CLOJA" + CRLF
	EndIf  
	
	If nOperac == 3 .And. !Empty(oCabec:cDtDigit) 
		If Empty(cToD(oCabec:cDtDigit))
			lRet := .F. 
			cRet += "PARAMETRO OBRIGATORIO INVALIDO: CDTDIGIT" + CRLF 
		Else 
			dDataBase := cToD(oCabec:cDtDigit)
		EndIf
	EndIf
	
	//chamar função aqui
	If nTpMetd == 2 .AND. lRet
		cQuery := "SELECT SF2.F2_FILIAL, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA "										
		cQuery += " FROM " + RetSqlName( "SF2" ) + " SF2 " 							
		cQuery += " WHERE SF2.D_E_L_E_T_ = ' ' "									
		cQuery += " AND SF2.F2_FILIAL  = '" + xFilial( "SF2" )          + "'"	
		cQuery += " AND SF2.F2_XDEVFRO = '" + AllTrim( oCabec:cTagDev ) + "'"
		cQuery += " AND SF2.F2_CLIENTE = '" + AllTrim( oCabec:cFornece ) + "'"
		cQuery += " AND SF2.F2_LOJA = '" + AllTrim( oCabec:cLoja ) + "'"	

		cQuery := ChangeQuery( cQuery )
		DbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAlias1, .T., .T. )
		
		If (cAlias1)->(!EOF())
			oCabec:cDoc   := (cAlias1)->F2_DOC
			oCabec:cSerie := (cAlias1)->F2_SERIE
		EndIf	 
	EndIf
	
	cIndKey := xFilial("SF2") + '|' + Padr(oCabec:cDoc,nTamDoc) + '|' + Padr(oCabec:cSerie,nTamSer) + '|' + Padr(oCabec:cFornece,nTamCli) + '|' + Padr(oCabec:cLoja,nTamLoja)

	//// CASO AS VALIDAÇÕES DOS CAMPOS OBRIGATÓRIO ESTEJA OK SEGUE NA EXCLUSÃO DA NOTA FISCAL
	If lRet 
		
		//// LOCALIZANDO A NOTA FISCAL DE SAIDA A SER EXCLUÍDA
		SF2->( DbSetOrder(1) )
		If( SF2->( DbSeek( xFilial("SF2") + Padr(oCabec:cDoc,nTamDoc) + Padr(oCabec:cSerie,nTamSer) + Padr(oCabec:cFornece,nTamCli) + Padr(oCabec:cLoja,nTamLoja) ) ) )
			If !Empty(SF2->F2_XDEVFRO)
				Begin Transaction
					ConOut("Inicio: "+Time())
					SD2->( DbSetOrder(3) )
					If( SD2->( DbSeek( xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA ) ) )
					
						cNumPed := SD2->D2_PEDIDO
						cFilOri := SD2->D2_FILIAL
	
						If MaCanDelF2("SF2", SF2->(RECNO()), @aRegSD2, @aRegSE1, @aRegSE2)
							CONOUT("VALIDA EXCLUSÃO DA NOTA - MaCanDelF2 OK")
							/*'--------------------------------------------------------------------------'*
							*'Rotina responsável pela exclusão da nota após estar tudo ok pela validação'*
							*'--------------------------------------------------------------------------'*/
							lMsErroAuto := .F. //A rotina MaCanDelF2 está sem erro, mas está mudando o conteúdo da variável para .T. e com isso gera erro na rotina a seguir
							SF2->(MaDelNFS(aRegSD2, aREgSE1, aRegSE2,.F.,.F.,.T.,.T.))  //mata521
						Else
							cRet := 'ERRO|EXCLUSAO DO TÍTULO. Função padrão MaCanDelF2."
							aLog := GetAutoGRLog() 
							For nY := 1 To Len(aLog)
								cRet += aLog[nY] + CRLF
							Next nY
							lMsErroAuto := .T.
							DisarmTransaction()
							Break						
						EndIf					
		
						If( SF2->( DbSeek( xFilial("SF2") + Padr(oCabec:cDoc,nTamDoc) + Padr(oCabec:cSerie,nTamSer) + Padr(oCabec:cFornece,nTamCli) + Padr(oCabec:cLoja,nTamLoja) ) ) )
							cRet := 'ERRO|EXCLUSAO DO TÍTULO. Função padrão MaDelNFS."
							aLog := GetAutoGRLog() 
							For nY := 1 To Len(aLog)
								cRet += aLog[nY] + CRLF
							Next nY
							lMsErroAuto := .T.
							DisarmTransaction()
							Break											
						EndIf
						
						If( !lMsErroAuto )
							aCabec := {}
							aItens := {}
							ConOut("Exclusão da Nota Fiscal feita com sucesso! [SF2/SD2] " + oCabec:cDoc)
		
							SC5->(DbSetOrder(01)) //FILIAL + PEDIDO
							If( SC5->( DbSeek( cFilOri + cNumPed ) ) )
								aAdd(aCabec,{'C5_NUM' 		,SC5->C5_NUM	 	,Nil})
								aAdd(aCabec,{'C5_TIPO' 		,SC5->C5_TIPO	 	,Nil})
								aAdd(aCabec,{'C5_CLIENTE' 	,SC5->C5_CLIENTE 	,Nil})
								aAdd(aCabec,{'C5_LOJACLI' 	,SC5->C5_LOJACLI 	,Nil})
								aAdd(aCabec,{'C5_CONDPAG' 	,SC5->C5_CONDPAG 	,Nil})
								
								SC6->(DBSetOrder(1)) //FILIAL + PEDIDO
								If( SC6->( DbSeek( xFilial( "SC6" ) + SC5->C5_NUM ) ) )		
									aAdd(aLinha,{'C6_ITEM'		,SC6->C6_ITEM		,Nil})
									aAdd(aLinha,{'C6_PRODUTO'	,SC6->C6_PRODUTO	,Nil})
									aAdd(aLinha,{'C6_QTDVEN'	,SC6->C6_QTDVEN		,Nil})
									aAdd(aLinha,{'C6_PRCVEN'	,SC6->C6_PRCVEN		,Nil})
									aAdd(aLinha,{'C6_PRUNIT'	,SC6->C6_PRUNIT		,Nil})
									aAdd(aLinha,{'C6_VALOR'		,SC6->C6_VALOR		,Nil})
									aAdd(aLinha,{'C6_TES'		,SC6->C6_TES		,Nil})
									aAdd( aItens, aLinha )
							
									MsExecAuto( { |x,y,z| MATA410(x,y,z) }, aCabec, aItens, 4 )
									
									If lMsErroAuto
										lRet := .F.
										cRet := 'ERRO|EXCLUSAO PEDIDO FRONT: ' + ALLTRIM(SC5->C5_XNUM) + ' / ' + 'PEDIDO PROTHEUS: ' + ALLTRIM(SC5->C5_NUM) + '. OBS: ' + CRLF
										aLog := GetAutoGRLog() 
										For nY := 1 To Len(aLog)
											cRet += aLog[nY] + CRLF
										Next nY
										DisarmTransaction()
										Break
									Else
										lRet := .T.
										cRet := 'OK|EXCLUSAO PEDIDO FRONT: ' + ALLTRIM(SC5->C5_XNUM) + ' / ' + 'PEDIDO PROTHEUS: ' + ALLTRIM(SC5->C5_NUM) + '. OBS: ' + CRLF
									EndIf 
								Else
									cRet := 'ERRO|EXCLUSAO PEDIDO FRONT: ' + ALLTRIM(SC5->C5_XNUM) + ' / ' + 'PEDIDO PROTHEUS: ' + ALLTRIM(SC5->C5_NUM) + '. OBS: ' + CRLF
									cRet += 'Itens do pedido não foram localizados.' + CRLF
									DisarmTransaction()
									Break
								EndIf	
							EndIf
						Else
							ConOut("Erro| Exclusão não foi bem sucedida! " + oCabec:cDoc )
							lRet	:= .F.
							DisarmTransaction()
							Break
						EndIf
						ConOut("Fim  : "+Time())
						ConOut(Repl("-",80))
					Else
						ConOut("Erro| Itens não foram localizados (SD2)! " + oCabec:cDoc )
						DisarmTransaction()
						Break
					EndIf
				End Transaction 
			Else
				cRet += " Nota não originada pela integração (Campo F2_XDEVFRO em branco)! " + CRLF
				lRet := .F.			
			EndIf
		Else
			cRet += " Cabeçalho não foi localizado (SF2)! " + CRLF
			lRet := .F.
		EndIf
		
		ErrorBlock(bBlock)
		
		If lMsErroAuto .And. lRet
			cRet += "INCONSISTENCIA DE ROTINA AUTOMATICA | " + CRLF
			aLog := GetAutoGRLog()
			For nY := 1 To Len(aLog)
				cRet += aLog[nY] + CRLF
			Next nY
		EndIf 	
			
		If !Empty(cErrorL)
			lRet := .F. 
			cRet += "ERRO DE PROGRAMACAO | " + CRLF + cErrorL
		EndIf 
		
		If !lMsErroAuto .And. lRet 
			cRet := "OK" 
			U_F07LOG02(nRegLog,cRet,.T.,"SF2",1,cIndKey)
		Else
			U_F07LOG02(nRegLog,cRet,.F.,"SF2",1,cIndKey) // Entrou aqui 258
		EndIf 
	EndIf
	
	dDataBase := Date()

Return cRet 

/*/{Protheus.doc} ChkErr
Função para tratamento de erros 
@type function
@author anieli.rodrigues
@since 03/02/2017
@version 12.7
@param oErroArq, object, Dados do erro capturado
@project MAN0000007423041_EF_033
/*/

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

