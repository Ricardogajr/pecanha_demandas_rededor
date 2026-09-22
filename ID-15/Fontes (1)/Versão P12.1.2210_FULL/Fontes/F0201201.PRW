#Include 'Protheus.ch'

/*
{Protheus.doc} F0201201() 
Automatização da Emissão das Notas Fiscais
@Author     Mick William da Silva
@Since      25/04/2016
@Version    P12.7
@Project    MAN00000463301_EF_012
@param cStat, characters,1-OK, 2-ERRO 		
@param nRecnoP22, numeric, RECNO da tabela P22
@param cMensagem, characters, Observações
@Return     
*/

User Function F0201201(cStat,nRecnoP22,cMensagem)
	
	Local lLiber	:= .T.
	Local lRet		:= .F.
	Local aItemPv	:= {}
	Local cNota		:= ''
	Local cMsg1		:= ''
	Local cMsg2		:= ''
	Local cMotBlq	:= ''
	Local lDelRet	:= .F.
	Local aSC9Estorn:= {}
	Local lEstornLib:= .T.
	Local cMensEsLib:= ''
	Local aRtEstPV	:= {}
	Local lEstornPV	:= .T.
	Local cMensEsPV := ''
	Local cMensRet	:= ''
	Local cSerie	:= SuperGetMV("FS_SRNFSER") //Pego a série informada no parâmetro.
	Local aArea		:= GetArea()
	Local aAreaSB1	:= SB1->(GetArea())
	Local aAreaSB2	:= SB2->(GetArea())
	Local aAreaSC5	:= SC5->(GetArea())
	Local aAreaSC6	:= SC6->(GetArea())
	Local aAreaSC9	:= SC9->(GetArea())
	Local aAreaSE4	:= SE4->(GetArea())
	Local aAreaSF2	:= SF2->(GetArea())
	Local aAreaSF4	:= SF4->(GetArea())
	Local aListBox	:= {}
	Local cIdInicial:= ''
	Local cIdFinal	:= ''
	Local cURL		:= ''
	Local cIdEnt	:= ''

	

	Default cStat		:=	''
	Default nRecnoP22	:=	0
	Default cMensagem	:=	''
	
	If cStat == '1'
	
		dbSelectArea("SC6")
		SC6->(DBSetOrder(1)) //Filial + Pedido
		SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM))
		
		SC9->( dbSetOrder(1) )
		SE4->( dbSetOrder(1) )
		SB1->( dbSetOrder(1) )
		SB2->( dbSetOrder(1) )
		SF4->( dbSetOrder(1) )
		
		/*========================================================|
		|Liberação de PV.                                         |
		|========================================================*/
		//Analisa Antes os Itens em Relação a TES e a Quantidade Liberada Digitada ou sugerida
		//Alterado Por: Luiz Enrique no QA.	    
		
		
		While SC6->(! Eof() .and. C6_FILIAL + C6_NUM ==xFilial("SC6") + SC5->C5_NUM)			//Percorre o Pedido de Venda	
			
            If 	SC9->( DbSeek(xFilial("SC9") + SC6->(C6_NUM + C6_ITEM)),.T.) .AND. SC9->C9_QTDLIB > 0
				cMsg2 += "Item: " + Alltrim(SC6->C6_ITEM) + " - " + Alltrim(SC6->C6_PRODUTO) + " Com Quantidade Liberada Sugerida/Digitada: " + Alltrim(Str(SC9->C9_QTDLIB)) + CRLF 
				lLiber := .F.
				AAdd(aSC9Estorn,SC9->(RECNO()))				
			Endif		
			SC6->(DbSkip())
		EndDo
        
        If len(aSC9Estorn) > 0
			aRtEstLib := fEstornLib(aSC9Estorn)
			If aRtEstLib[1]  //Se estornou com sucesso o que estava na SC9
				lLiber := .T.  
				cMsg2 := "" //limpa as mensagens dos registros da liberação da SC9.
			EndIF
			
		EndIf
		
		If fChkSC6(ALLTRIM(SC5->C5_NUM))  //Função para verificar se existe item (c6_item) duplicado.
			cMsg2 += "Existe item duplicadado para o pedido! "			
		EndIF		
				
	   	If !Empty(cMsg2)
	   		cMsg1 := 'ERRO|LIBERACAO PEDIDO FRONT: ' + ALLTRIM(SC5->C5_XNUM) + ' / ' + 'PEDIDO PROTHEUS: ' + ALLTRIM(SC5->C5_NUM) + '. OBS: ' + CRLF
	   		If IsInCallStack('U_F0703202')  
				dbSelectArea("P22")	   		
				P22->(DbGoTo(nRecnoP22))
				cMensRet := ""
				If Len(P22->P22_OBSERV+"") < 30000
					cMensRet += P22->P22_OBSERV
				EndIf
				cMensRet += cMsg1 + cMsg2 + CRLF
				Reclock('P22',.F.)
				P22->P22_DTLIB  := DATE()
				P22->P22_HRLIB  := TIME()
				P22->P22_STATLB := '2'
				P22->P22_OBSERV := cMensRet
				P22->P22_STATPV := '2' //ERRO
				P22->(MSUNLOCK())
				cMensRet :=	''
				U_F0703203(SC5->C5_FILIAL, SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_NUM, cMensRet)
				lRet := .F.
				RestArea(aAreaSB1)
				RestArea(aAreaSB2)
				RestArea(aAreaSC5)
				RestArea(aAreaSC6)
				RestArea(aAreaSC9)
				RestArea(aAreaSE4)
				RestArea(aAreaSF2)
				RestArea(aAreaSF4)
				RestArea(aArea)
				Return(lRet)
	   		Else
	   			Aviso(":: Atenção ::",cMsg1 + cMsg2,{"Ok"})
	   		EndIf
	   	Else		
			SC6->(DBSetOrder(1)) //Filial + Pedido
			SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM))				
			While SC6->(! Eof() .and. C6_FILIAL + C6_NUM == xFilial("SC6") + SC5->C5_NUM) .and. lLiber //Percorre o Pedido de Venda
				MaLibDoFat(	SC6->(Recno()),;
							SC6->C6_QTDVEN,;      // --> Quantidade a ser liberada
							.T.,;                 // --> Bloqueio de Credito
							.T.,;                 // --> Bloqueio de Estoque - lBloqueia
							.T.,;                 // --> Avaliacao de Credito
							.F.,;                 // --> Avaliacao de Estoque
							.T.,;                 // --> Permite Liberacao Parcial
							.F.,;                 // --> Tranfere Locais automaticamente
							Nil,;                 // --> Empenhos ( Caso seja informado nao efetua a gravacao apenas avalia )
							Nil,;                 // --> CodBlock a ser avaliado na gravacao do SC9
							NiL,;                 // --> Array (aSaldos) com Empenhos previamente escolhidos (impede selecao dos empenhos pelas rotinas)
							Nil,Nil,Nil,,;
							Nil)
//							SC6->C6_QTDVEN)
							
				SC9->(DbSetOrder(01))
				If !SC9->(DbSeek(xFilial('SC9') + SC6->C6_NUM + SC6->C6_ITEM))
					lLiber := .F.
				EndIf							
				
				AAdd(aSC9Estorn,SC9->(RECNO()))

				// Posiciono nas Tabelas para Faturamento
				//SC9->( DbSeek(xFilial("SC9") + SC6->(C6_NUM + C6_ITEM)),.F.)
				SB1->( DbSeek(xFilial("SB1") + SC6->C6_PRODUTO) )
				SB2->( DbSeek(xFilial("SB2") + SC6->C6_PRODUTO) )
				SF4->( DbSeek(xFilial("SF4") + SC6->C6_TES) )
				
				AAdd(aItemPv,{	SC6->C6_NUM 	,;	//[01]
								SC6->C6_ITEM 	,;	//[02]
								SC6->C6_LOCAL 	,;	//[03]
								SC6->C6_QTDVEN 	,;	//[04]
								SC6->C6_VALOR 	,;	//[05]
								SC6->C6_PRODUTO ,;	//[06]
								.F. 			,;	//[07]
								SC9->(RECNO())	,;	//[08]
								SC5->(RECNO()) 	,;	//[09]
								SC6->(RECNO()) 	,;	//[10]
								SE4->(RECNO())	,;	//[11]
								SB1->(RECNO())	,;	//[12]
								SB2->(RECNO())	,;	//[13]
								SF4->(RECNO())	}) 	//[14]
							
				If !(Empty(SC9->C9_BLEST) .And. Empty(SC9->C9_BLCRED))// .And. Empty(SC9->C9_BLOQUEI))

					lLiber := .F.

					If	SC9->C9_BLEST	==	'02'
						cMotBlq := 'Item: ' + SC6->C6_ITEM + ' - Bloqueio de Estoque' + CRLF
					ElseIf SC9->C9_BLEST	==	'03'
						cMotBlq := 'Item: ' + SC6->C6_ITEM + ' - Bloqueio Manual' + CRLF
					ElseIf SC9->C9_BLEST	==	'10'
						cMotBlq := 'Item: ' + SC6->C6_ITEM + ' - Já Faturado' + CRLF
					EndIf
					
					If SC9->C9_BLEST	<>	'10'
						If	SC9->C9_BLCRED	==	'01'
							cMotBlq := 'Item: ' + SC6->C6_ITEM + ' - Bloqueado p/ crédito' + CRLF
						ElseIf SC9->C9_BLCRED == '02'
							cMotBlq := 'Item: ' + SC6->C6_ITEM + ' - MV_BLQCRED = T' + CRLF
						ElseIf SC9->C9_BLCRED == '04'
							cMotBlq := 'Item: ' + SC6->C6_ITEM + ' - Limite de Crédito Vencido' + CRLF 
						ElseIf SC9->C9_BLCRED == '05'
							cMotBlq := 'Item: ' + SC6->C6_ITEM + ' - Bloqueio Crédito por Estorno' + CRLF 
						ElseIf SC9->C9_BLCRED == '06'
							cMotBlq := 'Item: ' + SC6->C6_ITEM + ' - Bloqueio por risco' + CRLF 
						ElseIf SC9->C9_BLCRED == '09'
							cMotBlq := 'Item: ' + SC6->C6_ITEM + ' - Rejeitado' + CRLF 
						ElseIf SC9->C9_BLCRED == '10'
							cMotBlq := 'Item: ' + SC6->C6_ITEM + ' - Já Faturado' + CRLF
						EndIf
					EndIf				
				
			   		If IsInCallStack('U_F0703202')
						P22->(DbGoTo(nRecnoP22))
						cMensRet := ""
						If Len(P22->P22_OBSERV+"") < 30000
							cMensRet += P22->P22_OBSERV + CRLF
						EndIf
						cMensRet += 'ERRO|PEDIDO FRONT: ' + ALLTRIM(SC5->C5_XNUM) + ' / ' + 'PEDIDO PROTHEUS: ' + ALLTRIM(SC5->C5_NUM) + '. OBS: ' + cMotBlq + CRLF
						Reclock('P22',.F.)
						P22->P22_DTLIB	:=	DATE()
						P22->P22_HRLIB 	:=	TIME()
						P22->P22_STATLB	:=	'2'
						P22->P22_OBSERV	:=	cMensRet
						P22->(MSUNLOCK())
						U_F0703203(SC5->C5_FILIAL, SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_NUM, cMensRet)
			   		Else
			   			Aviso(':: Atenção ::',cMotBlq,{'Ok'})
			   		EndIf
				EndIf
				SC6->(DbSkip())
			EndDo
			
			If !lLiber
				/*========================================================|
				|Estorna liberação do PV.                                 |
				|========================================================*/
				aRtEstLib := fEstornLib(aSC9Estorn)

		   		lEstornLib := aRtEstLib[01]
		   		cMensEsLib := aRtEstLib[02]	
		   		If IsInCallStack('U_F0703202')
					P22->(DbGoTo(nRecnoP22))
					Reclock('P22',.F.)
					If Len(P22->P22_OBSERV+"") > 30000
						P22->P22_OBSERV	:=	cMensEsLib + CRLF
					Else
						P22->P22_OBSERV	:=	P22->P22_OBSERV + cMensEsLib + CRLF
					EndIf
					P22->(MSUNLOCK())
		   		Else
		   			Aviso(':: Atenção ::',cMensEsLib,{'Ok'})
		   		EndIf
		   		
		   		If lEstornLib 
					/*========================================================|
					|Exclui Pedido de Venda.                                  |
					|========================================================*/
					aRtEstPV := fExcPVenda(SC5->C5_FILIAL, SC5->C5_NUM)
	
			   		lEstornPV := aRtEstPV[01]
			   		cMensEsPV := aRtEstPV[02]	
					If !lEstornPV
				   		If IsInCallStack('U_F0703202')
							P22->(DbGoTo(nRecnoP22))
							Reclock('P22',.F.)
							If Len(P22->P22_OBSERV+"") < 30000
								P22->P22_OBSERV	:=	P22->P22_OBSERV + cMensEsPV + CRLF
							Else
								P22->P22_OBSERV	:=	cMensEsPV + CRLF
							EndIf
							P22->P22_STATPV :=	'2'
							P22->(MSUNLOCK())
				   		Else
				   			Aviso(':: Atenção ::',cMensEsPV,{'Ok'})
				   		EndIf
				   	Else
				   		If IsInCallStack('U_F0703202')
							P22->(DbGoTo(nRecnoP22))
							Reclock('P22',.F.)
							If Len(P22->P22_OBSERV+"") < 30000
								P22->P22_OBSERV	:=	P22->P22_OBSERV + cMensEsPV + CRLF
							Else
								P22->P22_OBSERV	:=	cMensEsPV + CRLF
							EndIf
							P22->P22_STATPV :=	'2'
							P22->(MSUNLOCK())
				   		EndIf
			   		EndIf
		   		EndIf		   		
			EndIf
			
			If lLiber
		   		If IsInCallStack('U_F0703202')
					P22->(DbGoTo(nRecnoP22))
					Reclock('P22',.F.)
					P22->P22_DTLIB	:=	DATE()
					P22->P22_HRLIB 	:=	TIME()
					P22->P22_STATLB	:=	'1'
					If Len(P22->P22_OBSERV+"") < 30000
						P22->P22_OBSERV	:=	P22->P22_OBSERV + 'OK|PEDIDO LIBERADO' + CRLF
					Else
						P22->P22_OBSERV	:=	'OK|PEDIDO LIBERADO' + CRLF
					EndIf
					P22->(MSUNLOCK())
				EndIf
			EndIf		   	
	
			/*========================================================|
			|Gera Nota Fiscal de Saída.                               |
			|========================================================*/
			If lLiber 		
				MaLiberOk({SC5->C5_NUM},.F.) //Altero a legenda do Pedido de Vendas			
				// Efetuo o faturamento do Pedido de Vendas
				If !Empty(aItemPv)
					Pergunte("MT461A",.F.)
					cNota := MaPvlNfs(aItemPv,cSerie, .F. , .F. , .T. , .T. , .F. , 0 , 0 , .T. , .F.)				
					// Posiciono no Cabeçalho das Notas Fiscais de Saída
					dbSelectArea("SF2")
					SF2->(DBSetOrder(2)) //F2_FILIAL + F2_CLIENTE + F2_LOJA + F2_DOC + F2_SERIE				
					If SF2->(DbSeek(xFilial("SC5") + SC5->(C5_CLIENTE + C5_LOJACLI + C5_NOTA + C5_SERIE)))
				   		If IsInCallStack('U_F0703202')
							P22->(DbGoTo(nRecnoP22))
							cMensRet := ""
							If Len(P22->P22_OBSERV+"") < 30000
								cMensRet += P22->P22_OBSERV
							EndIf
							cMensRet += 'OK|NOTA FISCAL: ' + SF2->F2_SERIE + ' / ' +  SF2->F2_DOC + ' GERADA COM SUCESSO' + CRLF
							Reclock('P22',.F.)
							P22->P22_NOTA	:= SF2->F2_DOC
							P22->P22_SERIE	:= SF2->F2_SERIE
							P22->P22_DTFAT	:= DATE()
							P22->P22_HRFAT	:= TIME()
							P22->P22_STATFT	:= '1'
							P22->P22_OBSERV	:= cMensRet
							P22->(MSUNLOCK())
						EndIf
					Else
						lLiber := .F.
						cMensRet := ""
						If Len(P22->P22_OBSERV+"") < 30000
							cMensRet +=	P22->P22_OBSERV + CRLF
						EndIf
						cMensRet += 'ERRO|PEDIDO FRONT: ' + ALLTRIM(SC5->C5_XNUM) + ' / ' + 'PEDIDO PROTHEUS: ' + ALLTRIM(SC5->C5_NUM) + '. OBS: NOTA FISCAL NÃO GERADA.' + CRLF
						U_F0703203(SC5->C5_FILIAL, SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_NUM, cMensRet)

						/*========================================================|
						|Estorna liberação do PV.                                 |
						|========================================================*/
						aRtEstLib  := fEstornLib(aSC9Estorn)
				   		lEstornLib := aRtEstLib[01]
				   		cMensEsLib := aRtEstLib[02]	
				   		If IsInCallStack('U_F0703202')
							P22->(DbGoTo(nRecnoP22))
							Reclock('P22',.F.)
							If Len(P22->P22_OBSERV+"") < 30000
								P22->P22_OBSERV	:= P22->P22_OBSERV + cMensEsLib + CRLF
							Else
								P22->P22_OBSERV	:= cMensEsLib + CRLF
							EndIf
							P22->(MSUNLOCK())
				   		Else
				   			Aviso(':: Atenção ::',cMensEsLib,{'Ok'})
				   		EndIf
				   		
				   		If lEstornLib 
							/*========================================================|
							|Exclui Pedido de Venda.                                  |
							|========================================================*/
							aRtEstPV := fExcPVenda(SC5->C5_FILIAL, SC5->C5_NUM)
			
					   		lEstornPV := aRtEstPV[01]
					   		cMensEsPV := aRtEstPV[02]	
							If !lEstornPV
						   		If IsInCallStack('U_F0703202')
									P22->(DbGoTo(nRecnoP22))
									Reclock('P22',.F.)
									IF Len(P22->P22_OBSERV+"") < 30000
										P22->P22_OBSERV	:= P22->P22_OBSERV + cMensEsPV + CRLF
									Else
										P22->P22_OBSERV	:= cMensEsPV + CRLF
									EndIf
									P22->P22_STATPV :=	'2'
									P22->(MSUNLOCK())
						   		Else
						   			Aviso(':: Atenção ::',cMensEsPV,{'Ok'})
						   		EndIf
						   	Else
						   		If IsInCallStack('U_F0703202')
									P22->(DbGoTo(nRecnoP22))
									Reclock('P22',.F.)
									If Len(P22->P22_OBSERV+"") < 30000
										P22->P22_OBSERV	:=	P22->P22_OBSERV + cMensEsPV + CRLF
									Else
										P22->P22_OBSERV	:=	cMensEsPV + CRLF
									EndIf
									P22->P22_STATPV :=	'2'
									P22->(MSUNLOCK())
						   		EndIf
					   		EndIf
				   		EndIf
					EndIf
				EndIf
			Else
				If IsInCallStack('U_F0703202')
					cMensRet := 'ERRO|PEDIDO NÃO LIBERADO'
					U_F0703203(SC5->C5_FILIAL, SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_NUM, cMensRet)
				Else
					Help('',1,'Liberação do Pedido',,cMensRet,1,0)
				EndIf
			EndIf
		EndIf
		
		RestArea(aAreaSB1)
		RestArea(aAreaSB2)
		RestArea(aAreaSC5)
		RestArea(aAreaSC6)
		RestArea(aAreaSC9)
		RestArea(aAreaSE4)
		RestArea(aAreaSF2)
		RestArea(aAreaSF4)
		RestArea(aArea)
	EndIf
Return

/*
{Protheus.doc} fEstornLib()
Estorna liberação de pedido.
@Author     Paulo Krüger
@Since      15/02/2017
@Version    P12.7
@Project    MAN00000463301_EF_012
@Param      aEstorn - Ítens do PV
@Return     
*/
Static Function fEstornLib(aEstorn)

Local nI 		:= 0
Local cMens		:= ''
Local aRet		:= {}
Local lExtorn	:= .T.
Local lRet      := .F.
Local lRetErr   := .F.

For nI := 01 To Len(aEstorn)
	SC9->(DbGoTo(aEstorn[nI]))
	lExtorn := SC9->(A460Estorna())
	If !lExtorn
		cMens += 'ERRO|FILIAL/PEDIDO/ITEM NAO ESTORNADO: ' + SC9->C9_FILIAL + '/' + SC9->C9_PEDIDO + '/' + SC9->C9_ITEM + CRLF
		lRetErr  := .T.
	Else
		cMens += 'OK|FILIAL/PEDIDO/ITEM ESTORNADO: ' + SC9->C9_FILIAL + '/' + SC9->C9_PEDIDO + '/' + SC9->C9_ITEM + CRLF
		lRet  := .T.
	EndIf
Next nI
//Se Houve pelo menos um problema para estornar o SC9 de um item irá sinalizar no log.
AAdd(aRet,IIF(lRetErr,.F.,lRet) )
AAdd(aRet,cMens)

Return aRet

/*
{Protheus.doc} fExcPVenda()
Exclusão do Pedido de Venda.
@Author     Paulo Krüger
@Since      15/02/2017
@Version    P12.7
@Project    MAN00000463301_EF_012
@Param      cFilOri - Filial
			cPedido - Num PV
@Return     
*/
Static Function fExcPVenda(cFilOri, cPedido)

Local nY		:= 0
Local lRet		:= .T.
Local aRet		:= {}
Local aLog		:= {}
Local aCabec	:= {}
Local aLinha	:= {} 
Local aItens	:= {}
Local cRet		:= ''
Private lMsErroAuto := .F.
Private lAutoErrNoFile := .T.

SC5->(DbSetOrder(01))
If SC5->(DbSeek(cFilOri + cPedido))

	AAdd(aCabec,{'C5_FILIAL'	,SC5->C5_FILIAL	 	,Nil})
	AAdd(aCabec,{'C5_NUM' 		,SC5->C5_NUM	 	,Nil})
	AAdd(aCabec,{'C5_TIPO' 		,SC5->C5_TIPO	 	,Nil})
	AAdd(aCabec,{'C5_EMISSAO' 	,SC5->C5_EMISSAO 	,Nil})
	AAdd(aCabec,{'C5_CLIENTE' 	,SC5->C5_CLIENTE 	,Nil})
	AAdd(aCabec,{'C5_LOJACLI' 	,SC5->C5_LOJACLI 	,Nil})
	AAdd(aCabec,{'C5_TIPOCLI' 	,SC5->C5_TIPOCLI 	,Nil})
	AAdd(aCabec,{'C5_CONDPAG' 	,SC5->C5_CONDPAG 	,Nil})
	AAdd(aCabec,{'C5_XNUM'		,SC5->C5_XNUM  	 	,Nil})
	AAdd(aCabec,{'C5_ORIGEM'    ,SC5->C5_ORIGEM	 	,Nil})
            
	dbSelectArea("SC6")
	SC6->(DBSetOrder(1)) //Filial + Pedido
	SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM))
	While !Eof() .And. SC6->C6_NUM == cPedido
		AAdd(aLinha,{'C6_FILIAL'	,SC6->C6_FILIAL		,Nil})
		AAdd(aLinha,{'C6_ITEM'		,SC6->C6_ITEM		,Nil})
		AAdd(aLinha,{'C6_PRODUTO'	,SC6->C6_PRODUTO	,Nil})
		AAdd(aLinha,{'C6_DESCRI'	,SC6->C6_DESCRI		,Nil})
		AAdd(aLinha,{'C6_UM'		,SC6->C6_UM			,Nil})
		AAdd(aLinha,{'C6_QTDVEN'	,SC6->C6_QTDVEN		,Nil})
		AAdd(aLinha,{'C6_PRCVEN'	,SC6->C6_PRCVEN		,Nil})
		AAdd(aLinha,{'C6_VALOR'		,SC6->C6_VALOR		,Nil})
		AAdd(aLinha,{'C6_TES'		,SC6->C6_TES		,Nil})
		AAdd(aLinha,{'C6_LOCAL'		,SC6->C6_LOCAL		,Nil})
		AAdd(aLinha,{'C6_CLI'		,SC6->C6_CLI		,Nil})
		AAdd(aLinha,{'C6_LOJA'		,SC6->C6_LOJA		,Nil})
		AAdd(aLinha,{'C6_QTDLIB'	,SC6->C6_QTDLIB		,Nil})
		AAdd(aLinha,{'C6_PRUNIT'	,SC6->C6_PRUNIT		,Nil})
		AAdd(aLinha,{'C6_CC'    	,SC6->C6_CC    	,Nil})
	
		AAdd(aItens,aLinha)
		DbSkip()
	End	
	MsExecAuto({|x,y,z| MATA410(x,y,z)}, aCabec,aItens,5)
	
	If lMsErroAuto .Or. SC5->(DbSeek(xFilial('SC5') + cPedido))
		lRet := .F.
		cRet := 'ERRO|EXCLUSAO PEDIDO FRONT: ' + ALLTRIM(SC5->C5_XNUM) + ' / ' + 'PEDIDO PROTHEUS: ' + ALLTRIM(SC5->C5_NUM) + '. OBS: ' + CRLF
		aLog := GetAutoGRLog() 
		For nY := 1 To Len(aLog)
			cRet += aLog[nY] + CRLF
		Next nY
	Else
		lRet := .T.
		cRet := 'OK|EXCLUSAO PEDIDO FRONT: ' + ALLTRIM(SC5->C5_XNUM) + ' / ' + 'PEDIDO PROTHEUS: ' + ALLTRIM(SC5->C5_NUM) + '. OBS: ' + CRLF
	EndIf 
EndIf

AAdd(aRet, lRet)
AAdd(aRet, cRet)

Return(aRet)
/*
{Protheus.doc} fChkSC6()
Verifica se o pedido de Venda tem algum item duplicado.
@Author     Marcos Furtado
@Since      13/12/2018
@Version    P12.1.17
@Project    -
@Param      cPedido - Num PV
@Return     
*/
                                                        
Static Function fChkSC6(cPedido)
Local lRet := .F.

	cQuery := " SELECT C6_FILIAL, C6_NUM, C6_ITEM from  " + RetSqlName("SC6") + " SC6 "
	cQuery += " WHERE "
	cQuery += " C6_NUM= '"+cPedido+"' "
	cQuery += " AND C6_FILIAL = '"+xFilial("SC6")+"' "	
	cQuery += " AND SC6.D_E_L_E_T_ = ' ' "                   
	cQuery += " GROUP BY C6_FILIAL, C6_NUM, C6_ITEM HAVING COUNT(*) >  1"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),(cTempAlias:=GetNextAlias()))

	If (cTempAlias) -> (!EOF()) 
		If !Empty((cTempAlias) ->C6_NUM)
			lRet := .T.
		EndIF
	Endif

	(cTempAlias)->(DbCloseArea()) 
                  
Return(lRet)
