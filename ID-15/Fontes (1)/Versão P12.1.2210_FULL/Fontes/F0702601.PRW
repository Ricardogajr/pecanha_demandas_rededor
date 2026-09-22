#include "totvs.ch"

/*/{Protheus.doc} F0702601
Função responsável pelas integrações de pedidos de compras externos
@type User function
@author anieli.rodrigues
@since 20/01/2017
@param oCabec, object, Dados do cabeçalho da nota fiscal
@param oCorpo, object, Dados do item da nota fiscal
@param nOperac, numérico, Operação utilizada sendo 3 para inclusão e 5 para exclusão
@project MAN0000007423041_EF_026
@return cRET 
/*/

User Function F0702601(oCabec, oCorpo, nOperac)
	Local aCabec 	:= {}
	Local aConv		:= {}
	Local aItens 	:= {}
	Local aLinha	:= {}
	Local aLog 		:= {}
	Local bBlock
	Local cNum 		:= ""
	Local cRet 		:= "OK"
	Local cXID    	:= U_GetIntegID()
	Local cXNum		:= ""
	Local lRet 		:= .T.
	Local nItem 	:= 0
	Local nTamProd	:= TamSX3("C7_PRODUTO")[1]
	Local nTipo 	:= ""
	Local nOpc 		:= nOperac
	Local nX 		:= 0
	Local nY		:= 0
	Local nZ		:= 0
	Local cCodCpr	:= ''
	Local cIdUsr	:= ''
	Local cTipOrig  := "2"
	Local cFilNota	:= ""
	Local aDelPed   := {}
	Local lFree 	:= .T.
	Local nTent 	:= 0
	Local cChvPed   := ""
	Local nH		:= 0

	Local _aItPed   := {}
	Local _lNotExc  := .F.
	Local nSC7      := 0
	Local nXML      := 0
	Local _aItens   := {}
	Local aSC7      := {}
	Local aRt 		:= {}
	Local cUpd		:= ""
	Local lParcAtend := .F.
	Local aItemRS  := {}

	Private cErrorL			:= ""
	Private lAutoErrNoFile 	:= .T.
	Private lMsErroAuto 	:= .F.

	Private nIntValDes      := 0
	Private dDtValExec      := CToD("  /  /    ")

	cChvPed := AllTrim(oCabec:cXNum)+oCabec:cFilReg
	lFree := MayIUseCode(cChvPed)

	If !lFree
		nTent := 0
		While !(lFree := MayIUseCode(cChvPed))
			Sleep(2000)
			If ++nTent > 50
				cRet := " Controle de semáforo - Já existe uma integração desse pedido/filial em andamento."
				lRet := .F.
				Break
			Endif
		Enddo
		If lFree
			Sleep(2000)
		Endif
	Endif

	bBlock 	:= ErrorBlock({|e| ChkErr(e)})

	Begin Sequence

		Begin Transaction
			nRegLog := U_F07LOG01(cXID, {oCabec, oCorpo})
		End Transaction

		cRet := RetCabErr(oCabec, nOperac)

		If !Empty(cRet)
			lRet := .F.
			Break
		Else
			cFilAnt := oCabec:cFilReg
		EndIf

//		Begin Transaction
//    		nRegLog := U_F07LOG01(cXID, {oCabec, oCorpo})
//		End Transaction

		/*============================================================================|
		|Atribuição de usuário a partir do comprador informado no parâmetro FS_CPRINTE|
		|============================================================================*/
		cCodCpr := SuperGetMv("FS_CPRINTE",,"")
		If Empty(cCodCpr)
			cRet := "Parametro FS_CPRINTE não informado para a Filial " + cFilAnt + "!"
			lRet := .F.
			Break
		EndIf
		
		cIdUsr    := Posicione("SY1", 1, xFilial("SY1") + cCodCpr, "Y1_USER")
		cUserName := UsrRetName(cIdUsr)
		__CUSERID := cIdUsr

		If nOperac == 3
			nTipo := Val(oCabec:cTipo)
			cXNum := AllTrim(oCabec:cXNum)
			cNum  := oCabec:cNum

			SC7->(DBOrderNickName("EF0702601"))
			If SC7->(MsSeek(xFilial("SC7") + cXNum))
				If AllTrim(SC7->C7_XNUM) == cXNum
				nOpc := 3
				cNum := SC7->C7_NUM
				/*/Begin Transaction
				aDelPed := fDelPed(cXNum,5)//Correção chamado DOR010752583
					If !aDelPed[1]
					cRet := "ERRO NA EXCLUSÃO DE PEDIDO EXTERNO - " + aDelPed[2]
					lRet := .F.
					DisarmTransaction()
					Break
					EndIf
				End Transaction/*/
				EndIf
			EndIf

			//Início - Thais Paiva - 13243662
			While SC7->(!EOF()) .AND. ALLTRIM(SC7->C7_FILIAL) == ALLTRIM(xFilial("SC7")) .AND. ALLTRIM(SC7->C7_NUM) == ALLTRIM(cNum)
				aAdd(_aItPed,{SC7->C7_ITEM,SC7->C7_PRODUTO,SC7->C7_QUANT,SC7->C7_PRECO,SC7->(RECNO())})
				AAdd(aSC7,SC7->C7_ITEM)

				If SC7->C7_QUJE > 0
					lParcAtend := .T.
				EndIf

				SC7->(DbSkip())
			EndDo

			If Empty(cNum)
				cNum := GetNumSC7()
			EndIf

			If "|E" $ Upper(AllTrim(oCabec:cXFRONT))
				cTipOrig := "3"
			EndIf

			AAdd(aCabec, {"C7_NUM"    , cNum                            } )
			AAdd(aCabec, {"C7_FORNECE", oCabec:cFORNECE                 } )
			AAdd(aCabec, {"C7_LOJA"   , oCabec:cLOJA                    } )
			AAdd(aCabec, {"C7_COND"   , oCabec:cCOND                    } )
			AAdd(aCabec, {"C7_FILENT" , cFilAnt                         } )
			AAdd(aCabec, {"C7_COMPRA" , cCodCpr                         } )
			AAdd(aCabec, {"C7_CONTATO", oCabec:NomeContatoFornecedor    } )
			AAdd(aCabec, {"C7_EMISSAO", CToD(oCabec:DataEmissao)        } )
			AAdd(aCabec, {"C7_TPFRETE", oCabec:TipoFreteUtilizado       } )
			AAdd(aCabec, {"C7_FRETE" , Val(oCabec:ValorFrete)           } )
			AAdd(aCabec, {"C7_XFRONT" , Upper(AllTrim(oCabec:cXFRONT)) } )
			aAdd(aCabec, {"C7_USER"   ,	cIdUsr})

          dDtValExec := CToD(oCabec:DataEmissao)

			//variável utiilzada em PE da RDSL - deve existir.
			nIntValDes := Val(oCabec:cDESCFIN)

			U_F07PADR(aCabec)

			SC7->(DbSetOrder(1))

				If lParcAtend
					For nX := 1 To Len(oCorpo)
						If oCorpo[nX]:cResiduo == "S"
							AADD(aItemRS, AllTrim(oCorpo[nX]:cProduto ))
						EndIf
					Next nX
					If !Empty(aItemRS)
						SC7->(DBOrderNickName("EF0702601"))
						If SC7->(MsSeek(xFilial("SC7") + cXNum))
							While SC7->(!EOF()) .AND. ALLTRIM(SC7->C7_FILIAL) == ALLTRIM(xFilial("SC7")) .AND. ALLTRIM(SC7->C7_NUM) == ALLTRIM(cNum)
    						If aScan(aItemRS, {|x| AllTrim(Upper(x)) == AllTrim(SC7->C7_PRODUTO)})  > 0
								Reclock("SC7",.F.)
								SC7->C7_RESIDUO := "S"
								SC7->C7_ENCER := "E"
								SC7->(MsUnlock())
    						EndIf
							SC7->(DbSkip())
							EndDo
						EndIf
					Return "OK|ELIMINAÇÃO DE RESÍDUO PEDIDO " + cNum
					EndIf
				EndIf
			For nX := 1 To Len(oCorpo)

				aConv := U_F07024X(Padr(oCorpo[nX]:cProduto, nTamProd), xFilial("SC7"), Val(oCorpo[nX]:cQUANT), 2, 2, oCorpo[nX]:cUM)

				cRet := RetItemErr(oCorpo[nX], aConv[3])

				If !Empty(cRet)
					lRet := .F.
					Exit
				EndIf

				aLinha := {}

				If nOpc == 4 .and. SC7->(MsSeek(xFilial("SC7") + cNum + oCorpo[nX]:cITEM))
					AAdd(aLinha, {"C7_REC_WT", SC7->(RECNO()) , Nil}) //1
				Else
					AAdd(aLinha, {"C7_REC_WT", 0 , Nil}) //1
				EndIf
				
				IF nOpc == 4 .AND. SC7->(MsSeek(xFilial("SC7") + cNum + Strzero(Val(oCorpo[nX]:cITEM), 4))) .AND. SC7->C7_RESIDUO = "S" 	   .AND. oCorpo[nX]:cResiduo = "S"
					SC7->(Reclock("SC7",.F.))
						SC7->C7_RESIDUO := ""
					MsUnLock()
				Endif
				
				AAdd(aLinha, {"C7_ITEM"   , Strzero(Val(oCorpo[nX]:cITEM), 4)                                 , Nil}) //2
				AAdd(aLinha, {"C7_PRODUTO", oCorpo[nX]:cProduto                                               , Nil}) //3
				AAdd(aLinha, {"C7_QUANT"  , aConv[1]                                                          , Nil}) //4
				AAdd(aLinha, {"C7_PRECO"  , Val(oCorpo[nX]:cTOTAL)/aConv[1]                                   , Nil}) //5
				AAdd(aLinha, {"C7_TOTAL"  , Val(oCorpo[nX]:cTOTAL)                                            , Nil}) //6
				AAdd(aLinha, {"C7_TES"    , Posicione("SBZ", 1, xFilial("SBZ") + oCorpo[nX]:cProduto, "BZ_TE"), Nil}) //7
				AAdd(aLinha, {"C7_XORIG"  , cTipOrig                                                          , Nil}) //8
				AAdd(aLinha, {"C7_XNUM"   , oCabec:cXNUM                                                      , Nil}) //9
				AAdd(aLinha, {"C7_RESIDUO", oCorpo[nX]:cResiduo                                               , Nil}) //10
				AAdd(aLinha, {"C7_UM"     , aConv[2]                                                          , Nil}) //11
				AAdd(aLinha, {"C7_NUMSC"  , oCorpo[nX]:cNumSC                                                 , Nil}) //12
				AAdd(aLinha, {"C7_ITEMSC" , oCorpo[nX]:cITEMSC                                                , Nil}) //13
				AAdd(aLinha, {"C7_LOCAL"  , oCorpo[nX]:cLocal                                                 , Nil}) //14
				AAdd(aLinha, {"C7_OBS"    , oCorpo[nX]:cObs                                                   , Nil}) //15
				
				If !Empty(oCorpo[nX]:cXCODSET)
					AAdd(aLinha, {"C7_XCODSET", oCorpo[nX]:cXCODSET                                           , Nil})
				EndIf

				If !Empty(oCorpo[nX]:cCC)
					AAdd(aLinha, {"C7_CC"     , oCorpo[nX]:cCC                                                , Nil})
				EndIf
				
				AAdd(aLinha, {"C7_VLDESC" , Val(oCorpo[nX]:cVLDESC)                                           , Nil})
				AAdd(aLinha, {"C7_XINFPAC", oCorpo[nX]:cINFPAC                                                , Nil})
                AAdd(aLinha, {"C7_XDESFIN", Val(oCabec:cDESCFIN)                                         , Nil})
				 
				If !Empty(oCorpo[nX]:cNumSC) .And. !Empty(oCorpo[nX]:cITEMSC)
					AAdd(aLinha, {"C7_QTDSOL" , aConv[1]                                                          , Nil})
				EndIf
				
				If !Empty(CToD(oCorpo[nX]:cDATPRF))
					AAdd(aLinha, {"C7_DATPRF" , CToD(oCorpo[nX]:cDATPRF)                                          , Nil})
				EndIf
				If !Empty(oCorpo[nX]:cXDOCFAB)
				AAdd(aLinha, {"C7_XCODFAB", oCorpo[nX]:cXDOCFAB													  , Nil})
				EndIf
				AAdd(aLinha, {"C7_XID"    , cXID                                                              , Nil})
				AADD(aLinha, {"C7_XFRONT" , Upper(AllTrim(oCabec:cXFRONT)),Nil } )
				U_F07PADR(aLinha)

				AAdd(aItens, aLinha) 
			Next nX

			//Inicio Paulo  
			// CHAMAR EXECAUTO PARA INCLUSÃO DO PEDIDO OU ITEM (ALTERAÇÃO)
			If lRet
			Begin Transaction
			SC7->(DBOrderNickName("EF0702601"))
			If SC7->(MsSeek(xFilial("SC7") + cXNum))
				If AllTrim(SC7->C7_XNUM) == cXNum
					nOpc := 3
					cNum := SC7->C7_NUM
					aDelPed := fDelPed(cXNum,5)//Correção chamado DOR010752583
					If !aDelPed[1]
						cRet := "ERRO NA EXCLUSÃO DE PEDIDO EXTERNO - " + aDelPed[2]
						lRet := .F.
						DisarmTransaction()
						Break
						Return cRet
					EndIf
				EndIf
			EndIf
				MSExecAuto({|v, x, y, z| MATA120(v, x, y, z)}, nTipo, aCabec, aItens, nOpc)
				If lMsErroAuto
					cRet := "ERRO|EXECUCAO DA ROTINA AUTOMATICA" + CRLF
					aLog := GetAutoGRLog()
					For nY := 1 To Len(aLog)
						cRet += aLog[nY] + CRLF
					Next nY
					DisarmTransaction()
				ElseIf nOperac == 3
					cRet += "OK|" + cNum

					If nOpc == 4
						cUpd := "UPDATE " + RetSqlName("SC7") + " SET C7_FORNECE = '"+oCabec:cFORNECE+"', C7_COND = '"+oCabec:cCOND+"', C7_EMISSAO = '"+DTOS(CToD(oCabec:DataEmissao))+"', C7_TPFRETE = '"
						cUpd += oCabec:TipoFreteUtilizado+"', C7_FRETE = "+oCabec:ValorFrete+" WHERE D_E_L_E_T_ = ' ' AND C7_FILIAL = '"+oCabec:cFilReg+"' AND C7_XNUM = '"+oCabec:cXNUM+"'"

						TcSqlExec(cUpd)
					EndIf
				
				//Inicio -> William Souza - Totvs Partners / ID:1504 / 22/01/19
				//excluir o pedido de compra (C7_ENCER = 'E') quando o C7_RESIDUO = 'S'
					IF nOpc == 4 .or. nOpc == 3
						SC7->(DbSetOrder(1))
						nZ := 0
						For nZ := 1 To Len (aItens)

							if 	len(aItens[nZ]) >= 10 .and. ;
								aItens[nZ][10][2] == "S" .and. ;
								SC7->(MsSeek(xFilial("SC7") + cNum + Strzero(Val(aItens[nZ][2][2]), 4)))

								SC7->(Reclock("SC7",.F.))
									SC7->C7_ENCER := "E"
								SC7->(MsUnLock())
								EndIf
							
						Next
					EndIf
				ElseIf nOperac == 5
					cRet += "OK|"
					
				EndIf
			End Transaction

						SC7->(DbSetOrder(1))
						For nH := 01 to Len(oCorpo)

						cUpd := "UPDATE " + RetSqlName("SC7") + " SET C7_XINFPAC = '"+SubStr(AllTrim(oCorpo[nH]:cINFPAC),1,254)+"' "
						cUpd += "WHERE D_E_L_E_T_ = ' ' AND C7_FILIAL = '"+oCabec:cFilReg+"' AND C7_XNUM = '"+oCabec:cXNUM+"' AND C7_ITEM = '"+AllTrim(Strzero(val(oCorpo[nH]:cITEM), 4))+"'"

						TcSqlExec(cUpd)
							/*/SC7->(DbSeek(xFilial("SC7") + cNum + AllTrim(Strzero(val(oCorpo[nH]:cITEM), 4))))
							SC7->(Reclock("SC7",.F.))
								SC7->C7_XINFPAC :=  
							SC7->(MsUnLock())/*/
						Next nH
	
			EndIf
			
			If nOpc == 4 // Exclusão do item

				//DbSetOrder(1)
				If SC7->(MsSeek(xFilial("SC7") + cNum))
					For nSC7 := 1 To Len(aSC7)
						For nXML := 1 To Len(aItens)
							If  aItens[nXML][2][2] == aSC7[nSC7]
								_lNotExc := .T.
								Exit
							Else
								If nXML == Len(aItens)
									_lNotExc := .F.
								EndIf
							EndIf
							
							If !_lNotExc
									aLinha := {}

									AAdd(aLinha, {"C7_REC_WT" , _aItPed[nSC7][5]   , Nil})
									AAdd(aLinha, {"C7_ITEM"   , _aItPed[nSC7][1]   , Nil})
									AAdd(aLinha, {"C7_PRODUTO", _aItPed[nSC7][2]   , Nil})
									AAdd(aLinha, {"AUTDELETA" , "S"                , Nil})

									U_F07PADR(aLinha)

									AAdd(_aItens, aLinha)
									
									_lNotExc := .T.
							EndIf
						Next
					Next
				Endif
			EndIf
		// Fim Paulo 	
		Else
			nOpc := nOperac
			cXNum := oCabec:cXNum

            SC7->(DBOrderNickName("EF0702601"))
			If SC7->(MsSeek(xFilial("SC7") + cXNum))
				cNum  := SC7->C7_NUM
				nTipo := SC7->C7_TIPO
				dDtValExec := SC7->C7_EMISSAO
				AAdd(aCabec, {"C7_NUM", cNum})

				While !SC7->(Eof()) .And. SC7->C7_FILIAL == xFilial("SC7") .And. SC7->C7_NUM == cNum
					aLinha := {}

					AAdd(aLinha, {"C7_REC_WT" , SC7->(RECNO())   , Nil})
					AAdd(aLinha, {"C7_ITEM"   , SC7->(C7_ITEM)   , Nil})
					AAdd(aLinha, {"C7_PRODUTO", SC7->(C7_PRODUTO), Nil})

					U_F07PADR(aLinha)

					AAdd(_aItens, aLinha)
					SC7->(DbSkip())
				EndDo
			EndIf
		EndIf

		If lRet .And. nOperac <> 3
			MSExecAuto({|v, x, y, z| MATA120(v, x, y, z)}, nTipo, aCabec, _aItens, nOpc)
			If lMsErroAuto
				cRet := ""
				cRet += "ERRO|EXECUCAO DA ROTINA AUTOMATICA" + CRLF
				aLog := GetAutoGRLog()
				For nY := 1 To Len(aLog)
					cRet += aLog[nY] + CRLF
				Next nY
			ElseIf nOperac == 3
				If cRet == ""
					cRet += "OK|" + cNum
				EndIf
				//Inicio -> William Souza - Totvs Partners / ID:1504 / 22/01/19
				//excluir o pedido de compra (C7_ENCER = 'E') quando o C7_RESIDUO = 'S'
				IF nOpc == 4 .or. nOpc == 3
 					SC7->(DbSetOrder(1))
					nZ := 0
					For nZ := 1 To Len (aItens)

						if 	len(aItens[nZ]) >= 10 .and. ;
							aItens[nZ][10][2] == "S" .and. ;
							SC7->(MsSeek(xFilial("SC7") + cNum + Strzero(Val(aItens[nZ][2][2]), 4)))

							SC7->(Reclock("SC7",.F.))
						 		SC7->C7_ENCER := "E"
							SC7->(MsUnLock())
							EndIf
					Next
				EndIf
				//fim
			ElseIf nOperac == 5
				If cRet == ""
					cRet += "OK|PEDIDO EXCLUIDO COM SUCESSO!" 
				EndIf
			EndIf
		EndIf

	End Sequence

	ErrorBlock(bBlock)

	lSucesso := lRet .and. !lMsErroAuto

	If !Empty(cErrorL)
		cRet += "ERRO DE PROGRAMACAO | " + CRLF + cErrorL
		lSucesso := .F.
	EndIf

	U_F07LOG02(nRegLog, cRet, lSucesso, "SC7", 1, xfilial("SC7") + "|" + cNum)

Return cRet

Static Function RetCabErr(oCabec, nOperac)
	Local aAreas       := {GetArea(), SC7->(GetArea())}
	Local cNumExterno  := ""
	
	If !u_F07ChkFil(oCabec:cFilReg)
		Return "ERRO|PARAMETRO OBRIGATORIO INVALIDO: CFILREG"
	EndIf

	If Empty(oCabec:cXNum)
		Return "ERRO|PARAMETRO OBRIGATORIO NAO INFORMADO: CXNUM"
	EndIf

	If nOperac == 3 .And. Empty(oCabec:cTipo)
		Return "ERRO|PARAMETRO OBRIGATORIO NAO INFORMADO: CTIPO"
	EndIf

	If nOperac == 5
        cNumExterno := AllTrim(oCabec:cXNum)
	    SC7->(DbOrderNickName("EF0702601"))
		If ! SC7->(MsSeek(xFilial("SC7") + cNumExterno))
            AEval( aAreas, {|aArea| RestArea(aArea)})
		    Return "ERRO|PEDIDO EXTERNO [" + xFilial("SC7") + "/" + cNumExterno + "] NAO LOCALIZADO!"
		EndIf
	EndIf
	AEval( aAreas, {|aArea| RestArea(aArea)})
Return ""


Static Function RetItemErr(oItem, cConvErr)

	If !Empty(cConvErr)
		Return "ERRO|" + cConvErr
	EndIf

	If Empty(oItem:cITEM)
		Return "ERRO|PARAMETRO OBRIGATORIO NAO INFORMADO: CITEM"
	EndIf

	If !Empty(oItem:cDATPRF) .And. Empty(CToD(oItem:cDATPRF))
		Return "ERRO|PARAMETRO INVALIDO: CDATPRF"
	EndIf

Return ""


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

	If oErroArq:GenCode > 0
		cErrorL := "(" + Alltrim(Str(oErroArq:GenCode)) + ") : " + AllTrim(oErroArq:Description) + CRLF
	EndIf

	cErroL += GetEStack()

	If Intransact()
		cErrorL +="Transacao aberta desarmada"
		DisarmTransaction()
	EndIf
	Break
Return

Static Function GetEStack() as character
	Local cStack := ""
	Local nI     := 2

	While (!Empty(ProcName(ni)))
		cStack += Trim(ProcName(ni)) + "(" + Alltrim(Str(ProcLine(ni))) + ") " + CRLF
		ni ++
	End
Return cStack


/*/{Protheus.doc} fDelPed
Função para deletar o pedido caso já exista no sistema.
@type function
@author Lucas Aguiar
@since 28/03/2022
@version 1
Chamado DOR010752583
Função criada porque a integração de pedidos não chega com os itens em ordem, por este motivo, é necessário deletar o pedido e incluir novamente.
/*/
Static Function fDelPed(cXNum,nOperac)

	Local aArea := GetArea()
	Local aAreaC7 := SC7->(GetArea())
	Local aRet := {}
	Local cNum := ""
	Local cTipo := ""
	Local dDtValExec := ""
	Local aCabec := {}
	Local aLinha := {}
	Local _aItens := {}

	Default cXNum := ""
	Default nOperac := 0

	SC7->(DBOrderNickName("EF0702601"))
	If SC7->(MsSeek(xFilial("SC7") + cXNum))
		cNum  := SC7->C7_NUM
		nTipo := SC7->C7_TIPO
		dDtValExec := SC7->C7_EMISSAO
		AAdd(aCabec, {"C7_NUM", cNum})

		While !SC7->(Eof()) .And. SC7->C7_FILIAL == xFilial("SC7") .And. SC7->C7_NUM == cNum
			aLinha := {}

			AAdd(aLinha, {"C7_REC_WT" , SC7->(RECNO())   , Nil})
			AAdd(aLinha, {"C7_ITEM"   , SC7->(C7_ITEM)   , Nil})
			AAdd(aLinha, {"C7_PRODUTO", SC7->(C7_PRODUTO), Nil})

			U_F07PADR(aLinha)

			AAdd(_aItens, aLinha)
			SC7->(DbSkip())
		EndDo
	EndIf

	MSExecAuto({|v, x, y, z| MATA120(v, x, y, z)}, nTipo, aCabec, _aItens, nOperac)
	If lMsErroAuto

		cRet := ""
		cRet += "ERRO|EXECUCAO DA ROTINA AUTOMATICA" + CRLF
		aLog := GetAutoGRLog()
		For nY := 1 To Len(aLog)
			cRet += aLog[nY] + CRLF
		Next nY
		AADD(aRet,.F.)
		AADD(aRet,cRet)
	Else
		AADD(aRet,.T.)
		AADD(aRet,"Sucesso")
	EndIf

	RestArea(aAreaC7)
	RestArea(aArea)

Return aRet
