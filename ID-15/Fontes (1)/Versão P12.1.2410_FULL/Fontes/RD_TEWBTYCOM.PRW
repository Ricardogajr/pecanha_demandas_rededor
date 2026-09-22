#Include 'Protheus.ch'
#Include 'TopConn.Ch'
#Include 'Totvs.Ch'
#include "RWMAKE.CH"
/*
+---------------------------------------------------------------------------------------------------------+
| Neste programa estão todas as User Functions que são chamadas em pontos de entrada do módulo de Compras |
| Função     Ponto de Entrada                                                                             |   
| FSPE0003   M110STTS                                                                                     |
| FSPE0004   MT094END - Descontinuado                                                                                    |  
| FSPE0005   MT121BRW - Descontinuado                                                                                    |    
| FSPE0008   MT235G2                                                                                      | 
| FSPE0009   A010TOK                                                                                      | 
| FSPE0019   MT100TOK     																				  |	
|                                                                                  |  
+---------------------------------------------------------------------------------------------------------+*/


/*
{Protheus.doc}  FSPE0003()
Função chamada pelo ponto de entrada M110STTS para refazer alçada de aprovação
@Author  Ramon Teodoro e Silva	
@Since   23/02/2017       
@Version P12.7
*/
User Function FSPE0003()

	Local aArea      := GetArea()
	Local cFilSC 	 := Space(TamSx3("C1_FILIAL")[1])
	Local cNumSc 	 := Space(TamSx3("C1_NUM")[1])
	Local lMVXAPROSC := GetMv("MV_XAPROSC") //Parametro que indica se a empresa utiliza APROVAÇÃO DE SC
	Local cMVXTPSCAP := ALLTRIM(GetMv("MV_XTPSCAP")) //Parametro que indica se O TIPO exige aprovação de SC
	Local nVlrEsti	 := 0
	Local cTipoSc	 := SC1->C1_XTPSC //SC1->C1_XMOTIVO
	Local c_GrApro   := ""
	Local aItens	 := {}
	Local aDocument		:= {}
	Local nRec		 := 0
	Local lAprova 	:= .T.

	cFilSC  := xFilial("SC1")
	cNumSC  := CA110NUM

	DbSelectArea("SC1")
	DbSetOrder(1)
//DbSeek(SC1->C1_FILIAL+SC1->C1_NUM)
	DbSeek(cFilSC+cNumSC)
//nRec    := SC1->(Recno())
	cCCusto := ""

	While !SC1->(Eof()) .and. cFilSC + cNumSC = SC1->C1_FILIAL+SC1->C1_NUM
		nVlrEsti += SC1->C1_XTOTAL
		aAdd(aItens,{SC1->C1_ITEM," ",SC1->C1_XTOTAL})
		If !Empty(cCCusto)
			cCCusto += ","
		EndIf
		cCCusto += "'" + Alltrim(SC1->C1_CC) + "'"
		SC1->(DbSkip())
	Enddo

	SC1->(DbGoTo(nRec))

//Exclui alçada para refazer
	DbSelectArea("PZY")
	DbSetOrder(1)
	If (DbSeek(xFilial("PZY") + cTipoSc ))
		c_GrApro := PZY->PZY_GRAPRO
	EndIf

	DbSelectArea("SAL")
	DbSetOrder(1)

//Se tiver alçada exclui de qq forma para refazer caso tenha necessidade.
	DbSelectArea("SCR")
	DbSetOrder(1)
	If DbSeek(xFilial("SCR")+"SC"+cNumSC)
		//MaAlcDoc({cNumSC, "SC", nVlrEsti,,, c_GrApro,,,,," "},dDataBase,3,,,"01",aItens)
		MaAlcDoc({cNumSC, "SC", nVlrEsti,,, c_GrApro,,,,dDataBase},,3)
	Endif
	//ADICIONADO O PARAMIXB PQ O LCOPIA FICA COMO .T. DEPOIS QUE COPIA E EXCLUI  - 30/06/2020
	If (Altera .OR. Inclui .Or. (lCopia .And. PARAMIXB[2] == 1)) //cria a alçada se for inclusão ou alteração
		//If  lMVXAPROSC .and. !(SC1->C1_XTPSC $ cMVXTPSCAP) //Caso tenha aprovação de SC e o tipo exige aprovacao//se for alteração refaz o processo de alçada
		If  lMVXAPROSC .and. !(SC1->C1_XTPSC $ cMVXTPSCAP) .AND. !ISINCALLSTACK("U_REDA003") //Thais Paiva - 9474856
			//Inclui alçada
			//MaAlcDoc({cNumSC, "SC", nVlrEsti,,, c_GrApro,,,,, " "}, dDataBase,1,,,"01",aItens)
			//MaAlcDoc({cA110Num,"SC",n110TotLib,,,cGrpAprov,,,,dA110Data},,1)
			MaAlcDoc({cNumSC, "SC", nVlrEsti,,, c_GrApro,,,,dDataBase},,1)
			U_RddSetxApr(cNumSC,cCCusto)
		EndIf
	EndIf
/*
_cTmp   := ""
_cTmp   := GetNextAlias()

//Analista: Jonatha bumblebee
//
cQuery := "SELECT CR.R_E_C_N_O_  REC FROM "+RetSqlName("SAK")+" AK " + CRLF 
cQuery += " INNER JOIN "+RetSqlName("SCR")+" CR " + CRLF
cQuery += "  ON CR_FILIAL = '" +cFilSC+ "'" + CRLF
cQuery += "  AND CR_APROV = AK_COD " + CRLF
cQuery += "  AND CR_USER = AK_USER " + CRLF
cQuery += "  AND CR.D_E_L_E_T_ = ' ' " + CRLF
cQuery += " INNER JOIN "+RetSqlName("SC1")+" C1 " + CRLF
cQuery += " ON C1_FILIAL = CR_FILIAL " + CRLF
cQuery += " AND C1_NUM = CR_NUM " + CRLF
cQuery += " AND C1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += " WHERE AK.D_E_L_E_T_ = ' ' " + CRLF
//cQuery += " AND AK_FILIAL = '"+xFilial("SCR")+"' " + CRLF
cQuery += " AND CR_TIPO = 'SC' " + CRLF
cQuery += " AND CR_NUM = '"+cNumSc+"' " + CRLF
cQuery += " AND CR_USERORI = ' ' " + CRLF
cQuery += " AND CR_TOTAL < AK_LIMMIN " + CRLF

DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , _cTmp, .F., .T. )

	While !(_cTmp)->(EOF())
		SCR->(DbGoTo((_cTmp)->REC))
		RecLock("SCR",.F.)
		SCR->(DbDelete())
		SCR->(MsUnlock())
	(_cTmp)->(DbSkip())
	EndDo

(_cTmp)->(DbCloseArea())
*/
	lAprova := VeriApro(cNumSc,cFilSC,"SC")
//Função de envio para o FLUIG foi transferida do fonte PE_MTALCDOC para este por questão de compatibilidade com o padrão.
//Envio somente de Solicitação de Compras (NOVAS)
	If !lAprova
		SCR->(DbGoTop())
		SCR->(DbSetOrder(1))
		If SCR->(DbSeek(cFilSC + "SC" + cNumSc))
			AAdd(aDocument, SCR->CR_NUM)            // DEF_DOCUMENTO  01 - [01] Número do Documento
			AAdd(aDocument, SCR->CR_TIPO)           // DEF_TIPO_DOC   02 - [02] Tipo de Documento
			AAdd(aDocument, SCR->CR_TOTAL)          // DEF_VALOR_DOC  03 - [03] Valor do Documento
			AAdd(aDocument, NIL)          // DEF_APROVADOR  04 - [04] Código do Aprovador
			AAdd(aDocument, NIL)           // DEF_USUARIO    05 - [05] Código do Usuário
			AAdd(aDocument, SCR->CR_GRUPO)          // DEF_GRP_APROV  06 - [06] Grupo do Aprovador
			AAdd(aDocument, NIL) //não será necessário       // DEF_APROV_SUP  07 - [07] Aprovador Superior
			AAdd(aDocument, NIL)          // DEF_MOEDA_DOC  08 - [08] Moeda do Documento
			AAdd(aDocument, NIL)        // DEF_TX_MOEDA   09 - [09] Taxa da Moeda
			AAdd(aDocument, SCR->CR_EMISSAO)  		// DEF_DT_EMISSAO 10 - [10] Data de Emissão do Documento

			If FindFunction("U_F1701101")
				//StartJob("U_F1701101", GetEnvServer(), .F., aDocument, dDataRef, nOperation, FwCodEmp(), FwCodFil())
				U_F1701101(aDocument, SCR->CR_EMISSAO, 1)
			EndIf
		EndIf
	EndIf
	RestArea(aArea)
Return

Static Function VeriApro(cNum,cFil,cTipo)

	Local aArea  := GetArea()
	Local lAprov := .F.

	Default cNum  := ""
	Default cFil  := ""
	Default cTipo  := ""

	SCR->(DbSetOrder(1))
	If SCR->(DbSeek(cFil + cTipo + cNum))
		While SCR->(!(EoF())) .And. SCR->CR_FILIAL == cFil .And. SCR->CR_TIPO == cTipo .And. SCR->CR_NUM == cNum
			If SCR->CR_STATUS $ "03|04|05|06"
				lAprov := .T.
			EndIf
			SCR->(DbSkip())
		End
	EndIf
	RestArea(aArea)
Return lAprov
/*
{Protheus.doc}  FSPE0004()
Função chamada pelo ponto de entrada MT094END na liberação manual de documentos. 
@Author  Ramon Teodoro e Silva	
@Since   23/02/2017       
@Version P12.7

User Function FSPE0004()

Local __cNumPed := Alltrim(PARAMIXB[1])
Local cTipoDoc 	:= PARAMIXB[2]
Local nOpcA 	:= PARAMIXB[3]
Local cFildoc	:= PARAMIXB[4]
Local aRet      := {}

If cTipoDoc = "PC" //só valida se for pedido de compras
	cQuery := " SELECT count(CR_NUM) QTAPROV FROM "+RetFullName("SCR")+" "+CRLF
	cQuery += " WHERE D_E_L_E_T_='' AND CR_FILIAL='"+cFildoc+"' AND CR_TIPO='PC' "+CRLF
	cQuery += " AND CR_NUM='"+__cNumPed+"' AND CR_STATUS in ('01','02','04') "

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), ("TMPSCR"), .F., .T.)

	//Se a query retornar maior que 0, significa que ainda tem aprovação pendente ou algum aprovador bloqueou, 
	//portanto o PC não está liberado
	If TMPSCR->QTAPROV = 0

		DbSelectArea("SC7")
		DbSetOrder(1)
		DbSeek(cFildoc+__cNumPed)

		U_RDDR001("SC7",SC7->(Recno()),2)

	Endif
Endif

Return aRet
*/

/*
{Protheus.doc}  FSPE0005()
Função chamada pelo ponto de entrada MT121BRW  
@Author  Ramon Teodoro e Silva	
@Since   23/02/2017       
@Version P12.7

User Function FSPE0005() 

Local lRet := .t.

aAdd(aRotina,{"Enviar p/ Fornec","U_RDDR001", 0, 2, 0, .F. }) 

Return lRet

*/

//--------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------

/*
{Protheus.doc}  FSPE0008()
Função chamada pelo ponto de entrada MT235G2 - Validação durante o processo de eliminação de resíduo para que apenas seja considerado o pedido ou solicitação 
do usuário que está executando a rotina  
@Author  Ramon Teodoro e Silva	
@Since   23/02/2017       
@Version P12.7
*/
User Function FSPE0008()

	Local lRet     := .T.
	Local aArea    := GetArea()
	Local lComp    := .F.
	Local lSolic   := .F.
	Local cUserAtu := RetCodUsr()
	Local cAliasT  := Paramixb[1]
	Local cUserPS  := ""
	Local aGrupos  := {}
//Local cUsrResid := SuperGetMv("MV_XELIREU",,"000001") Thais Paiva - 7755927
//Local cGrpResid := SuperGetMv("MV_XELIREG",,"000001") Thais Paiva - 7755927
	Local cUsrResid := Supergetmv( 'MV_XELIREU' , , '000000' , cFilant ) //Thais Paiva - 7755927
	Local cGrpResid := Supergetmv( 'MV_XELIREG' , , '000000' , cFilant ) //Thais Paiva - 7755927
	Local _cGrpcom	:= "" //Thais Paiva - 7755927
	Local _cTpSol	:= "" //Thais Paiva - 7755927
	Local _cNumCt	:= "" //Thais Paiva - 7755927
	Local _cAprov	:= "" //Thais Paiva - 7755927
	Local lGrpCom	:= .F. //Thais Paiva - 7755927
	Local lGrpAprov	:= .F. //Thais Paiva - 7755927
	Local _cNumBio	:= "" //Thais Paiva 7755927
	Local _cLocal   := ""
	Local lRetGrp	:= .F.
	Local aGrpResid := {}
	Local nX := 0
	Local nY := 0
	Local _cQryAI	:= "" //Thais Paiva 7755927
	Local _cAliasAI	//Thais Paiva 7755927
	Local _aGrpUsu	:= ""
	Local _cGrpSol	:= ""
	Local nRecBkp := 0
	Local lGo := .T.
	Local cQry := ""
	Local cDoc := ""
	Local cFilDoc := ""
	Local cAliasCR := GetNextAlias()

	If ParamIxb[2] == 1//Pedido
		cDoc := AllTrim((cAliasT)->C7_NUM)
		cFilDoc := AllTrim((cAliasT)->C7_FILIAL)
		cQry += " SELECT CR_STATUS FROM "+RETSQLNAME("SCR")
		cQry += " WHERE D_E_L_E_T_ = ' ' "
		cQry += " AND CR_FILIAL = '"+cFilDoc+"' "
		cQry += " AND CR_TIPO = 'PC' "
		cQry += " AND CR_NUM = '"+cDoc+"' "
		cQry += " AND CR_STATUS IN ('02','01') "

		DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ) , cAliasCR, .F., .T. )

		If (cAliasCr)->(!EOF())
			MsgAlert("O documento " + cDoc + " está em processo de aprovação, a eliminação não é permitida. Use a rotina de exclusão","Atenção")
			lRet := .F.
			(cAliasCr)->(DbCloseArea())
			Return lRet
		EndIf

		If !Empty(Posicione( "SC7",1,cFilDoc+cDoc,"C7_XIDEXNF"))
			Aviso("Atenção", "O documento " + cDoc + " é proveniente de devolução do mês fechado. Não será possivel eliminar residuos por esta rotina.", {"Ok"})
			lRet := .F.
			(cAliasCr)->(DbCloseArea())
			Return lRet
		EndIf
	ElseIf ParamIxb[2] == 3//SC
		cDoc := AllTrim((cAliasT)->C1_NUM)
		cFilDoc := AllTrim((cAliasT)->C1_FILIAL)
		cQry += " SELECT CR_STATUS FROM "+RETSQLNAME("SCR")
		cQry += " WHERE D_E_L_E_T_ = ' ' "
		cQry += " AND CR_FILIAL = '"+cFilDoc+"' "
		cQry += " AND CR_TIPO = 'SC' "
		cQry += " AND CR_NUM = '"+cDoc+"' "
		cQry += " AND CR_STATUS IN ('02','01') "

		DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ) , cAliasCR, .F., .T. )

		If (cAliasCr)->(!EOF())
			MsgAlert("O documento " + cDoc + " está em processo de aprovação, a eliminação não é permitida. Use a rotina de exclusão","Atenção")
			lRet := .F.
			(cAliasCr)->(DbCloseArea())
			Return lRet
		EndIf
	EndIf

	(cAliasCr)->(DbCloseArea())

	If Paramixb[2] == 1

		cUserPS := Posicione("SC7", 1, xFilial("SC7")+(cAliasT)->C7_NUM,"C7_USER")
		//Início - Thais Paiva - 7755927
		//_cGrpcom	:= Alltrim(Posicione("SC7", 1, xFilial("SC7")+(cAliasT)->C7_NUM,"C7_GRUPCOM"))
		//_cNumCt		:= Alltrim(Posicione("SC7", 1, xFilial("SC7")+(cAliasT)->C7_NUM,"C7_CONTRA"))
		//_cAprov		:= Alltrim(Posicione("SC7", 1, xFilial("SC7")+(cAliasT)->C7_NUM,"C7_APROV"))
		//_cNumBio	:= Alltrim(Posicione("SC7", 1, xFilial("SC7")+(cAliasT)->C7_NUM,"C7_XIDBIO"))

		// Início - Eduardo Williams - 9474856 - 10/08/2020
		_cGrpcom	:= Alltrim(Posicione("SC7", 4, xFilial("SC7")+(cAliasT)->C7_PRODUTO+(cAliasT)->C7_NUM,"C7_GRUPCOM"))
		_cNumCt		:= Alltrim(Posicione("SC7", 4, xFilial("SC7")+(cAliasT)->C7_PRODUTO+(cAliasT)->C7_NUM,"C7_CONTRA"))
		_cAprov		:= Alltrim(Posicione("SC7", 4, xFilial("SC7")+(cAliasT)->C7_PRODUTO+(cAliasT)->C7_NUM,"C7_APROV"))
		_cNumBio	:= Alltrim(Posicione("SC7", 4, xFilial("SC7")+(cAliasT)->C7_PRODUTO+(cAliasT)->C7_NUM,"C7_XIDBIO"))
		_cLocal		:= Alltrim(Posicione("SC7", 4, xFilial("SC7")+(cAliasT)->C7_PRODUTO+(cAliasT)->C7_NUM,"C7_LOCAL"))
		// Fim - Eduardo Williams - 9474856 - 10/08/2020
		If !(Alltrim(cUserPS) == Alltrim(cUserAtu)) //Thais Paiva - 9474856
			If Empty(_cNumCt) .AND. Empty(_cNumBio)

				If Empty(_cAprov)
					MsgAlert("O pedido " + Alltrim((cAliasT)->C7_NUM)+ " não possui Grupo de Aprovação e não poderá ser processado","Atenção")
					lRet := .F.
				Else
					DbSelectArea("SY1")
					SY1->(DbSetOrder(3))
					If SY1->(DbSeek(xFilial("SY1")+cUserAtu))
						While SY1->(!Eof()) .AND. Alltrim(SY1->Y1_USER) == cUserAtu
							If Alltrim(SY1->Y1_GRAPROV) == _cAprov
								lGrpAprov := .T.
								Exit
							Endif
							SY1->(DbSkip())
						Enddo
					Else
						MsgAlert("O usuário não está associado ao Grupo de Aprovação do pedido " + Alltrim((cAliasT)->C7_NUM)+ ". O Pedido não poderá ser processado","Atenção")
						lRet := .F.
					EndIf
				Endif

				If !lGrpAprov
					MsgAlert("O usuário não está associado ao Grupo de Aprovação do pedido " + Alltrim((cAliasT)->C7_NUM)+ ". O Pedido não poderá ser processado","Atenção")
					lRet := .F.
				Endif
			Else
				If Empty(_cGrpcom)
					DbSelectArea("SBZ")
					SBZ->(DbSetOrder(1))
					If SBZ->(DbSeek(xFilial("SC7")+(cAliasT)->C7_PRODUTO))
						If Empty(SBZ->BZ_XGRPCOM)
							lGo := fTelaBZ("A",SBZ->(Recno()),_cLocal,(cAliasT)->C7_PRODUTO,cDoc,cFilDoc)
							If lGo
								nRecBkp := SC7->(RECNO())
								DbSelectArea("SC7")
								SC7->(DbSetOrder(4))
								If SC7->(DbSeek(xFilial("SC7")+(cAliasT)->C7_PRODUTO+(cAliasT)->C7_NUM))
									Reclock("SC7",.F.)
									SC7->C7_GRUPCOM := SBZ->BZ_XGRPCOM
									SC7->(MsUnLock())
								EndIf
								SC7->(DbGoto(nRecBkp))
							EndIf
						Else
							nRecBkp := SC7->(RECNO())
							DbSelectArea("SC7")
							SC7->(DbSetOrder(4))
							If SC7->(DbSeek(xFilial("SC7")+(cAliasT)->C7_PRODUTO+(cAliasT)->C7_NUM))
								Reclock("SC7",.F.)
								SC7->C7_GRUPCOM := SBZ->BZ_XGRPCOM
								SC7->(MsUnLock())
							EndIf
							SC7->(DbGoto(nRecBkp))
						EndIf
					Else
						lGo := fTelaBZ("I",0,_cLocal,(cAliasT)->C7_PRODUTO,cDoc,cFilDoc)
						If lGo
							nRecBkp := SC7->(RECNO())
							DbSelectArea("SC7")
							SC7->(DbSetOrder(4))
							If SC7->(DbSeek(xFilial("SC7")+(cAliasT)->C7_PRODUTO+(cAliasT)->C7_NUM))
								Reclock("SC7",.F.)
								SC7->C7_GRUPCOM := SBZ->BZ_XGRPCOM
								SC7->(MsUnLock())
							EndIf
							SC7->(DbGoto(nRecBkp))
						EndIf
					EndIf
					If !lGo
						MsgAlert("O pedido " + Alltrim((cAliasT)->C7_NUM)+ " não possui Grupo de Compras e não poderá ser processado","Atenção")
						lRet := .F.
					Else
						lGrpCom := .T.
					EndIf
				Else
					DbSelectArea("SAJ")
					SAJ->(DbSetOrder(1))
					If SAJ->(DbSeek(xFilial("SAJ")+_cGrpcom))
						While SAJ->(!Eof()) .AND. Alltrim(SAJ->AJ_GRCOM) == _cGrpcom

							If Alltrim(SAJ->AJ_USER) == cUserAtu
								lGrpCom := .T.
								Exit
							Endif

							SAJ->(DbSkip())
						Enddo
					Endif
				EndIf

				If !lGrpCom
					MsgAlert("O pedido " + Alltrim((cAliasT)->C7_NUM)+ " não pertence ao Grupo de Compras do usuário e não poderá ser processado.","Atenção")
					lRet := .F.
				Endif
			EndIf

			If lRet
				//Fim - Thais Paiva - 7755927

				//Verifica se o usuario amarrado no parametro
				If cUserAtu $ cUsrResid
					lRetGrp := .T.
				EndIf

				//Verifica se o grupo amarrado no parametro
				If !lRetGrp

					PswOrder(1)
					If (  PswSeek(cUserAtu, .T.) )
						aGrupos := Pswret(1)
					EndIf
					aGrpResid := StrTokArr(cGrpResid, "|")
					For nX := 01 To Len(aGrupos)
						For nY := 01 To Len(aGrpResid)
							If aScan(aGrupos[1][10],aGrpResid[nY]) <> 0
								lRetGrp := .T.
								Exit
							EndIf
						Next nY
						If lRetGrp
							Exit
						EndIf
					Next nX
				EndIf

				If !lRetGrp
					If !(cUserPS == cUserAtu) .Or. Empty(cUserPS)
						MsgAlert("O pedido " + Alltrim((cAliasT)->C7_NUM)+ " foi lançado por outro usuário e não poderá ser processado","Atenção")
						lRet := .F.
					EndIf
				EndIf

			EndIf
		Endif //Thais Paiva - 9474856

	ElseIf Paramixb[2] == 3

/*	cUserPS := Posicione("SC1", 1, xFilial("SC1")+(cAliasT)->C1_NUM,"C1_USER")
	
	DbSelectArea("SAI")
	SAI->(DbSetOrder(2))
	
	If SAI->(DbSeek(xFilial("SAI")+cUserAtu)) 
		
		If !(cUserPS == cUserAtu) .Or. Empty(cUserPS)
			MsgAlert("A solicitação " + Alltrim((cAliasT)->C1_NUM)+ " foi lançada por outro usuário e não poderá ser processada","Atenção")
			lRet := .F.
		EndIf
		
	EndIf*/
	
	cUserPS := Posicione("SC1", 1, xFilial("SC1")+(cAliasT)->C1_NUM,"C1_USER")
	_cTpSol := Alltrim(Posicione("SC1", 1, xFilial("SC1")+(cAliasT)->C1_NUM,"C1_XTPSC")) //Thais Paiva - 7755927
	_aGrpUsu := UsrRetGrp(cUserAtu)	//Thais Paiva - 7755927
	
	
	//DbSelectArea("SY1") Thais Paiva - 7755927
	//SY1->(DbSetOrder(3)) Thais Paiva - 7755927
	
	//Início - Thais Paiva - 7755927

	If !(Alltrim(cUserPS) == Alltrim(cUserAtu)) //Thais Paiva - 9474856
		For _nG := 1 to Len(_aGrpUsu)
		
			If _nG = Len(_aGrpUsu)
				_cGrpSol += "'" + _aGrpUsu[_nG] + "'"
			Else
				_cGrpSol += "'" + _aGrpUsu[_nG] + "',"
			EndIf
		
		Next _nG
		
		_cAliasAI := GetNextAlias()
		
		_cQryAI := "SELECT AI_USER FROM "+RetSqlName("SAI")
		_cQryAI += " WHERE D_E_L_E_T_ = ' '"
		_cQryAI += " AND AI_FILIAL = '"+xFilial("SAI")+"' "
		_cQryAI += " AND AI_XTPSC LIKE '%"+_cTpSol+"%'"
		_cQryAI += " AND AI_GRUSER IN (" + _cGrpSol + ") "
		
		If Select(_cAliasAI) > 0
			dbSelectArea(_cAliasAI)
			(_cAliasAI)->(dbCloseArea())
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQryAI),_cAliasAI,.T.,.T.)
		
		If (_cAliasAI)->(!Eof())
			While (_cAliasAI)->(!Eof())
						
				If Alltrim((_cAliasAI)->AI_USER) == cUserAtu .OR. Alltrim((_cAliasAI)->AI_USER) == "******"
					lGrpCom := .T.
					Exit
				Endif
				
				(_cAliasAI)->(DbSkip())
			Enddo
		Endif
		
		//If !lGrpCom
		//	MsgAlert("O usuário não tem acesso de solicitante ao  Tipo de Solicitação. A Solicitação: " + Alltrim((cAliasT)->C1_NUM)+" não poderá ser processada","Atenção")
		//	lRet := .F.
		//EndIf
		
		If lRet
		//Fim - Thais Paiva - 7755927
		
			//Verifica se o usuario amarrado no parametro		
			If cUserAtu $ cUsrResid
				lRetGrp  := .T.
			EndIf	
			
			//Verifica se o grupo amarrado no parametro	
			If !lRetGrp
				
				PswOrder(1)      
				If (  PswSeek(cUserAtu, .T.) )            
					aGrupos := Pswret(1)
				EndIf
				aGrpResid := StrTokArr(cGrpResid, "|")	
				For nX := 01 To Len(aGrupos)				
					For nY := 01 To Len(aGrpResid)
						If aScan(aGrupos[1][10],aGrpResid[nY]) <> 0					
							lRetGrp := .T.
							Exit				
						EndIf					
					Next nY
					If lRetGrp
						Exit
					EndIf	
				Next nX
			EndIf
				
			If !lRetGrp
				If !(cUserPS == cUserAtu) .Or. Empty(cUserPS)
					MsgAlert("A solicitação " + Alltrim((cAliasT)->C1_NUM)+ " foi lançada por outro usuário e não poderá ser processada","Atenção")
					lRet := .F.
				EndIf
			EndIf	
			
			If lRetGrp .AND. !lGrpCom
				MsgAlert("O usuário não tem acesso de solicitante ao  Tipo de Solicitação. A Solicitação: " + Alltrim((cAliasT)->C1_NUM)+" não poderá ser processada","Atenção")
				lRet := .F.
			EndIf 
		
		Endif //Thais Paiva - 7755927
	EndIf //Thais Paiva - 9474856
		
EndIf
	
RestArea(aArea)
Return lRet


/*
{Protheus.doc}  FSPE0009()
Função chamada pelo ponto de entrada A010TOK - Verificação de informações iguais na inclusão/alteração do produto 
@Author  Ramon Teodoro e Silva	
@Since   23/02/2017       
@Version P12.7
*/
User Function FSPE0009()
	Local lRet    := .T.
	Local aArea   := GetArea()
	Local nRec    := SB1->(Recno())
	Local aColsB1 := {}
	Local aHeadB1 := {}
	Local nCount  := 0
	Local oCount
	Local nUsado  := 0
	Local cQuery  := ""
	Local aBotoes := {}
	Local nOpc    := 0
	Local cArqQry := "TRBSB1"

	Private oDlSB1
	Private oDlg
	Private nPosOk  := 0

	If !IsInCallStack("U_F0702501")

		Aadd(aHeadB1,{ "Identificador", "B1_IDENTF", "@!", 55, 0 ,""  ,"", "C",  ,"R","",""   ,.f. })
		Aadd(aHeadB1,{ "Código"      , "B1_COD", PesqPict("SB1","B1_COD",,), TamSX3("B1_COD")[1], TamSX3("B1_COD")[2] ,""  ,"", TamSX3("B1_COD")[3],  ,,"","" ,.f. })
		Aadd(aHeadB1,{ "Descrição"   , "B1_DESC", PesqPict("SB1","B1_DESC",,), TamSX3("B1_DESC")[1], TamSX3("B1_DESC")[2] ,""  ,"", TamSX3("B1_DESC")[3],  ,,"","" ,.f. })
		If M->B1_XMEDICA == "S"
			Aadd(aHeadB1,{ "BRASINDICE"  , "B1_XBRASIN", PesqPict("SB1","B1_XBRASIN",,), TamSX3("B1_XBRASIN")[1], TamSX3("B1_XBRASIN")[2] ,""  ,"", TamSX3("B1_XBRASIN")[3],  ,,"","" ,.f. })
			Aadd(aHeadB1,{ "TUSS"        , "B1_XTUSS", PesqPict("SB1","B1_XTUSS",,), TamSX3("B1_XTUSS")[1], TamSX3("B1_XTUSS")[2] ,""  ,"", TamSX3("B1_XTUSS")[3],  ,,"","" ,.f. })
		Else
			//	Aadd(aHeadB1,{ "Pos.IPI/NCM" , "B1_POSIPI", PesqPict("SB1","B1_POSIPI",,), TamSX3("B1_POSIPI")[1], TamSX3("B1_POSIPI")[2] ,""  ,"", TamSX3("B1_POSIPI")[3],  ,,"","" ,.f. })
			Aadd(aHeadB1,{ "Anvisa"      , "B1_XANVISA", PesqPict("SB1","B1_XANVISA",,), TamSX3("B1_XANVISA")[1], TamSX3("B1_XANVISA")[2] ,""  ,"", TamSX3("B1_XANVISA")[3],  ,,"","" ,.f. })
			Aadd(aHeadB1,{ "BRASINDICE"  , "B1_XBRASIN", PesqPict("SB1","B1_XBRASIN",,), TamSX3("B1_XBRASIN")[1], TamSX3("B1_XBRASIN")[2] ,""  ,"", TamSX3("B1_XBRASIN")[3],  ,,"","" ,.f. })
			Aadd(aHeadB1,{ "Referencia"  , "B1_XREFER", PesqPict("SB1","B1_XREFER",,), TamSX3("B1_XREFER")[1], TamSX3("B1_XREFER")[2] ,""  ,"", TamSX3("B1_XREFER")[3],  ,,"","" ,.f. })
			Aadd(aHeadB1,{ "SIMPRO"      , "B1_XSIMPRO", PesqPict("SB1","B1_XSIMPRO",,), TamSX3("B1_XSIMPRO")[1], TamSX3("B1_XSIMPRO")[2] ,""  ,"", TamSX3("B1_XSIMPRO")[3],  ,,"","" ,.f. })
			Aadd(aHeadB1,{ "TUSS"        , "B1_XTUSS", PesqPict("SB1","B1_XTUSS",,), TamSX3("B1_XTUSS")[1], TamSX3("B1_XTUSS")[2] ,""  ,"", TamSX3("B1_XTUSS")[3],  ,,"","" ,.f. })
		EndIf
		Aadd(aHeadB1,{ "Recno", "B1_RECNO", "@E 9999999999", 10, 0 ,""  ,"", "N",  ,"V","",""   ,.f. })

		If M->B1_XMEDICA == "S"

			cIdtf := ""

			If M->B1_COD <> SB1->B1_COD

				cQuery := " SELECT B1_COD, B1_DESC, B1_XBRASIN, B1_XTUSS, R_E_C_N_O_ FROM " + RetSqlName("SB1")
				cQuery += " WHERE ( LTRIM(RTRIM(B1_DESC)) = '" + Alltrim(M->B1_DESC) + "'"

				If Alltrim(M->B1_XBRASIN) <> ""
					cQuery += " OR B1_XBRASIN = '" + M->B1_XBRASIN + "' "
				EndIf

				If Alltrim(M->B1_XTUSS) <> ""
					cQuery += + " OR B1_XTUSS = '" + M->B1_XTUSS + "' "
				EndIf

				cQuery += " ) AND D_E_L_E_T_ = ''"

				If Select(cArqQry) > 0
					DbSelectArea(cArqQry)
					(cArqQry)->(DbCloseArea())
				EndIf

				cQuery := ChangeQuery(cQuery)

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqQry,.T.,.T.)

				While !(cArqQry)->(Eof())

					//If U_RetDesc(M->B1_DESC) == U_RetDesc((cArqQry)->B1_DESC)
					If M->B1_DESC == (cArqQry)->B1_DESC
						cIdtf += "DESC /"
					EndIf

					If !Empty(Alltrim(M->B1_XBRASIN)) .And. Alltrim(M->B1_XBRASIN) == Alltrim((cArqQry)->B1_XBRASIN)
						cIdtf += "BRASIN /"
					EndIf

					If !Empty(Alltrim(M->B1_XTUSS)).And. Alltrim(M->B1_XTUSS) == Alltrim((cArqQry)->B1_XTUSS)
						cIdtf += "TUSS /"
					EndIf

					If cIdtf <> ""
						nCount += 1
						cIdtf := SubStr(cIdtf, 1, Len(cIdtf)-1)
						Aadd( aColsB1, { cIdtf, (cArqQry)->B1_COD, (cArqQry)->B1_DESC, (cArqQry)->B1_XBRASIN, (cArqQry)->B1_XTUSS, (cArqQry)->R_E_C_N_O_, .f.})
						cIdtf := ""
					EndIf

					(cArqQry)->(DbSkip())

				End

			EndIf

		Else

			cQuery := " SELECT B1_COD, B1_DESC, B1_POSIPI, B1_XANVISA, B1_XBRASIN, B1_XREFER, B1_XSIMPRO, B1_XTUSS, R_E_C_N_O_ FROM " + RetSqlName("SB1")
			cQuery += " WHERE ( LTRIM(RTRIM(B1_DESC)) = '" + Alltrim(M->B1_DESC) + "' "

		/*If Alltrim(M->B1_POSIPI) <> "" 
			cQuery += " OR B1_POSIPI = '" + M->B1_POSIPI + "' "
		EndIf*/
		
		If Alltrim(M->B1_XANVISA) <> "" 
			cQuery += " OR B1_XANVISA = '" + M->B1_XANVISA + "' "
		EndIf
		
		If Alltrim(M->B1_XBRASIN) <> "" 
			cQuery += " OR B1_XBRASIN = '" + M->B1_XBRASIN + "' "
		EndIf
		
		If Alltrim(M->B1_XREFER) <> "" 
			cQuery += " OR B1_XREFER = '" + M->B1_XREFER + "' "
		EndIf
		
		If Alltrim(M->B1_XSIMPRO) <> "" 
			cQuery += " OR B1_XSIMPRO = '" + M->B1_XSIMPRO + "' "
		EndIf
		
		If Alltrim(M->B1_XTUSS) <> ""
			cQuery += " OR B1_XTUSS = '" + M->B1_XTUSS + "' "
		EndIf
		
		cQuery += " ) AND D_E_L_E_T_ = ''"
	
		If Select(cArqQry) > 0
			DbSelectArea(cArqQry)
			(cArqQry)->(DbCloseArea())
		EndIf
		
		cQuery := ChangeQuery(cQuery)
	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqQry,.T.,.T.)
		
		While !(cArqQry)->(Eof())
		
			cIdtf := ""
			
			If M->B1_COD <> SB1->B1_COD
			
				//If U_RetDesc(M->B1_DESC) == U_RetDesc(SB1->B1_DESC)
				If M->B1_DESC == (cArqQry)->B1_DESC
					cIdtf += "DESC /"
				EndIf
				
				/*If !Empty(Alltrim(M->B1_POSIPI)) .And. Alltrim(M->B1_POSIPI) == Alltrim((cArqQry)->B1_POSIPI)
					cIdtf += "POSIPI /"
				EndIf*/
				
				If !Empty(Alltrim(M->B1_XANVISA)) .And. Alltrim(M->B1_XANVISA) == Alltrim((cArqQry)->B1_XANVISA)
					cIdtf += "ANVISA /"
				EndIf
				
				If !Empty(Alltrim(M->B1_XBRASIN)) .And. Alltrim(M->B1_XBRASIN) == Alltrim((cArqQry)->B1_XBRASIN)
					cIdtf += "BRASIN /"
				EndIf
				
				If !Empty(Alltrim(M->B1_XREFER)) .And. Alltrim(M->B1_XREFER) == Alltrim((cArqQry)->B1_XREFER)
					cIdtf += "REFERE /"
				EndIf 
				
				If !Empty(Alltrim(M->B1_XSIMPRO)) .And. Alltrim(M->B1_XSIMPRO) == Alltrim((cArqQry)->B1_XSIMPRO)
					cIdtf += "SIMPRO /"
				EndIf
					
				If !Empty(Alltrim(M->B1_XTUSS)) .And. Alltrim(M->B1_XTUSS) == Alltrim((cArqQry)->B1_XTUSS)
					cIdtf += "TUSS /"
				EndIf
					
				If cIdtf <> ""
					nCount += 1
					cIdtf := SubStr(cIdtf, 1, Len(cIdtf)-1)
					Aadd( aColsB1, { cIdtf, (cArqQry)->B1_COD, (cArqQry)->B1_DESC, (cArqQry)->B1_POSIPI, (cArqQry)->B1_XANVISA, (cArqQry)->B1_XBRASIN,;
											(cArqQry)->B1_XREFER, (cArqQry)->B1_XSIMPRO, (cArqQry)->B1_XTUSS, (cArqQry)->R_E_C_N_O_, .f.})
					cIdtf := ""
				EndIf
			
			EndIf
			
			(cArqQry)->(DbSkip())
		
		End
	
	EndIf
	
	If !Empty(aColsB1) 
		
		If M->B1_XMEDICA == "S"	
			MsgAlert("Já existem produtos cadastrados com as mesmas informações (Descrição, TUSS, BRASINDICE).", "Alerta para verificação das informações")
		Else
			MsgAlert("Já existem produtos cadastrados com as mesmas informações (Referência, TUSS, Descrição, ANVISA, BRASINDICE, SIMPRO).", "Alerta para verificação das informações")
		EndIf
	
		DEFINE MSDIALOG oDlg TITLE "Analise dos Produtos"  FROM 0,0 TO 380, 820 OF oMainWnd PIXEL
			
		@ 160,048 SAY "Total Encontrado"           SIZE 050,07  OF oDlg PIXEL	 
		@ 169,048 MSGET oCount  VAR nCount         SIZE 035,09  OF oDlg PIXEL HASBUTTON When .F. Picture "@E 999"
		
		oDlSB1 := MsNewGetDados():New(30,0,155,412,  ,,,,,,9999,,,,oDlg,aHeadB1,aColsB1) 
		
		oDlSB1:oBrowse:blDblClick:={|| U_VisualPr()}
		
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpc:=1,oDlg:End()}, {|| nOpc:=0,oDlg:End() },,aBotoes)
			
		If nOpc == 1
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	EndIf

EndIf

SB1->(DbGoTo(nRec))
RestArea(aArea)

Return lRet


/*
{Protheus.doc}  FSPE0019()
Função chamada pelo ponto de entrada MT100TOK - Validação na nota de entrada, após a confirmação 
@Author  Ramon Teodoro e Silva	
@Since   08/08/2017       
@Version P12.7
*/

User Function FSPE0019

	Local lRet    := .T.
	Local aArea   := GetArea()
	Local nValIr  := MaFisRet( , "NF_VALIRR")
	Local cNaturz := MaFisRet( , "NF_NATUREZA")
	Local nValIns := MaFisRet( , "NF_VALINS")
	Local nPosCon := Ascan(aHeader,{|x|Alltrim(x[2])=="D1_XCODCON"})
	Local cFilF1 := SF1->F1_FILIAL
	Local nPosCRe := Ascan(aHeader,{|x|Alltrim(x[2])=="D1_XRETINS"})
	Local cFornec := SA2->A2_COD

	Local cQuery  := ""
	Local cArqSE2 := "TRBSE2"
	Local aHeadE2 := {}
	Local aColsE2 := {}
	Local nCont   := 0
	Local oCont
	Local nOpc    := 0

	Private oDlSE2
	Private oDlg

	If FwIsInCallStack("fExecClass")
		cFilF1 := SCR->CR_FILIAL
	EndIf

	If nValIr > 0 .And. cDirf == "2"
		MsgStop("Documento com Valor de IRRF, é necessário preencher o campo 'Gera Dirf'", "Dirf")
		lRet := .F.
	EndIf

	If nValIr > 0 .And. Empty(cCodRet) .And. lRet
		MsgStop("Documento com Valor de IRRF, é necessário preencher campo 'Cd. Retenção'", "Cod. de Retenção")
		lRet := .F.
	EndIf

	If Empty(cNaturz)
		MsgStop("Favor preencher o campo 'Natureza' na aba de Duplicatas.", "Natureza não preenchida")
		lRet := .F.
	EndIf

	If nValIns > 0 .And. Empty(aCols[1][nPosCRe]) .And. lRet
		MsgStop("Documento com valor de INSS, é necessário preencher o Código de Retenção de INSS", "Cod. Ret. INSS não preenchido")
		lRet := .F.
	EndIf

	If IsInCallStack("U_F1000301") .And. lRet

		If Empty(aCols[1][nPosCon])
			MsgStop("É obrigatório que o campo 'Cod.Controle' esteja preenchido.", "Código de Controle")
			lRet := .F.
		Else

			Aadd(aHeadE2,{ "FILIAL", "E2_FILIAL", PesqPict("SE2","E2_FILIAL",,), TamSX3("E2_FILIAL")[1], TamSX3("E2_FILIAL")[2] ,""  ,"", TamSX3("E2_FILIAL")[3],  ,,"","" ,.f. })
			Aadd(aHeadE2,{ "NOME", "E2_NOMEFIL", "@!", 40, 0 ,""  ,"", "C",  ,,"","" ,.f. })
			Aadd(aHeadE2,{ "PREFIXO", "E2_PREFIXO", PesqPict("SE2","E2_PREFIXO",,), TamSX3("E2_PREFIXO")[1], TamSX3("E2_PREFIXO")[2] ,""  ,"", TamSX3("E2_PREFIXO")[3],  ,,"","" ,.f. })
			Aadd(aHeadE2,{ "NUMERO", "E2_NUM", PesqPict("SE2","E2_NUM",,), TamSX3("E2_NUM")[1], TamSX3("E2_NUM")[2] ,""  ,"", TamSX3("E2_NUM")[3],  ,,"","" ,.f. })
			Aadd(aHeadE2,{ "CONTROLE", "E2_XCODCON", PesqPict("SE2","E2_XCODCON",,), TamSX3("E2_XCODCON")[1], TamSX3("E2_XCODCON")[2] ,""  ,"", TamSX3("E2_XCODCON")[3],  ,,"","" ,.f. })
			Aadd(aHeadE2,{ "PARCELA", "E2_PARCELA", PesqPict("SE2","E2_PARCELA",,), TamSX3("E2_PARCELA")[1], TamSX3("E2_PARCELA")[2] ,""  ,"", TamSX3("E2_PARCELA")[3],  ,,"","" ,.f. })
			Aadd(aHeadE2,{ "TIPO", "E2_TIPO", PesqPict("SE2","E2_TIPO",,), TamSX3("E2_TIPO")[1], TamSX3("E2_TIPO")[2] ,""  ,"", TamSX3("E2_TIPO")[3],  ,,"","" ,.f. })
			Aadd(aHeadE2,{ "FORNECEDOR", "E2_FORNECE", PesqPict("SE2","E2_FORNECE",,), TamSX3("E2_FORNECE")[1], TamSX3("E2_FORNECE")[2] ,""  ,"", TamSX3("E2_FORNECE")[3],  ,,"","" ,.f. })
			Aadd(aHeadE2,{ "NOME", "E2_NOMFOR", PesqPict("SE2","E2_NOMFOR",,), TamSX3("E2_NOMFOR")[1], TamSX3("E2_NOMFOR")[2] ,""  ,"", TamSX3("E2_NOMFOR")[3],  ,,"","" ,.f. })
			Aadd(aHeadE2,{ "EMISSÃO", "E2_EMISSAO", PesqPict("SE2","E2_EMISSAO",,), TamSX3("E2_EMISSAO")[1], TamSX3("E2_EMISSAO")[2] ,""  ,"", TamSX3("E2_EMISSAO")[3],  ,,"","" ,.f. })
			Aadd(aHeadE2,{ "VENCIMENTO", "E2_VENCTO", PesqPict("SE2","E2_VENCTO",,), TamSX3("E2_VENCTO")[1], TamSX3("E2_VENCTO")[2] ,""  ,"", TamSX3("E2_VENCTO")[3],  ,,"","" ,.f. })
			Aadd(aHeadE2,{ "VALOR", "E2_PARCELA", PesqPict("SE2","E2_VALOR",,), TamSX3("E2_VALOR")[1], TamSX3("E2_VALOR")[2] ,""  ,"", TamSX3("E2_VALOR")[3],  ,,"","" ,.f. })
			Aadd(aHeadE2,{ "Recno", "E2_RECNO", "@E 9999999999", 10, 0 ,""  ,"", "N",  ,"V","",""   ,.f. })

			cQuery := " SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_NOMFOR, E2_EMISSAO, E2_VENCTO, E2_VALOR, E2_XCODCON, R_E_C_N_O_ FROM " + RetSqlName("SE2")
			cQuery += " WHERE (E2_NUM = '" + aCols[1][nPosCon] + "' OR E2_XCODCON = '" + aCols[1][nPosCon] + "') AND "
			cQuery += " E2_FORNECE = '" + cFornec + "' AND "
			cQuery += " E2_FILIAL = '" + cFilF1 + "' AND"
			cQuery += " D_E_L_E_T_ = ' '"
 
			If Select(cArqSE2) > 0
				DbSelectArea(cArqSE2)
				(cArqSE2)->(DbCloseArea())
			EndIf

			cQuery := ChangeQuery(cQuery)

			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqSE2,.T.,.T.)

			While !(cArqSE2)->(Eof())

				Aadd( aColsE2, { (cArqSE2)->E2_FILIAL, FWFilialName(SubStr((cArqSE2)->E2_FILIAL, 1, 2), (cArqSE2)->E2_FILIAL, 2 ), (cArqSE2)->E2_PREFIXO, (cArqSE2)->E2_NUM, (cArqSE2)->E2_XCODCON, (cArqSE2)->E2_PARCELA, (cArqSE2)->E2_TIPO,;
					(cArqSE2)->E2_FORNECE, (cArqSE2)->E2_NOMFOR, StoD((cArqSE2)->E2_EMISSAO), StoD((cArqSE2)->E2_VENCTO), (cArqSE2)->E2_VALOR, (cArqSE2)->R_E_C_N_O_, .f.})

				nCont += 1
				(cArqSE2)->(DbSkip())

			End

			If !Empty(aColsE2)

				DEFINE MSDIALOG oDlg TITLE "Títulos Encontrados"  FROM 0,0 TO 380, 820 OF oMainWnd PIXEL

				@ 160,048 SAY "Total Encontrado"           SIZE 050,07  OF oDlg PIXEL
				@ 169,048 MSGET oCout  VAR nCont           SIZE 035,09  OF oDlg PIXEL HASBUTTON When .F. Picture "@E 999"

				oDlSE2 := MsNewGetDados():New(30,0,155,412,  ,,,,,,9999,,,,oDlg,aHeadE2,aColsE2)

				oDlSE2:oBrowse:blDblClick:={|| U_VisualE2()}

				ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpc:=1,oDlg:End()}, {|| nOpc:=0,oDlg:End() },,)

				If nOpc == 1
					lRet := .T.
				Else
					lRet := .F.
				EndIf

			EndIf

		EndIf

	EndIf

	RestArea(aArea)
Return lRet







/*---------------------------------------------------------------------------------------*/
/*Funções do ponto de entrada M110STTS --------------------------------------------------*/
/*---------------------------------------------------------------------------------------*/

/*
|----------------------------------------------------------------------------|
|Programa  |RddSetxApr  |Autor  |TECNOSUM            | Data |  16/06/2016    |
|----------------------------------------------------------------------------|
|Descrição |Checa se os usuários na alçada podem participar de aprovação da  |
|          |sc de acordo com o setor.                                        |			  
|----------------------------------------------------------------------------|
|Uso       |REDEDOR                                                          |						  
|----------------------------------------------------------------------------|
*/
User Function RddSetxApr(cSol,cCCusto)
	Local aAprCCust := {}
	Local nApr		:= 0
	Local cUpd		:= ""
/*
BeginSql alias "PZXTMP"

%noparser%
SELECT PZX_FILIAL,	PZX_CODAPR,	PZX_CCUSTO
FROM %table:PZX% PZX
WHERE PZX_FILIAL =  %XFilial:PZX% AND PZX_CCUSTO IN ( %exp:cCCusto% ) AND PZX.%notDel%

EndSql 
DbSelectArea("PZXTMP")*/

cQuery := " SELECT PZX_FILIAL,	PZX_CODAPR,	PZX_CCUSTO "
cQuery += " FROM " + RetSqlName("PZX") 
cQuery += " WHERE PZX_FILIAL = '" + xFilial("PZX") + "' AND PZX_CCUSTO IN ( " + cCCusto + " ) AND D_E_L_E_T_ = ''"
cQuery := ChangeQuery(cQuery)	
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"PZXTMP",.F.,.T.)

PZXTMP->(Dbeval({||aAdd(aAprCCust,PZXTMP->PZX_CODAPR)}))

PZXTMP->(DbCloseArea())

DbSelectArea("SCR")
DbSetOrder(1)
If DbSeek(xFilial("SCR")+"SC"+cSol)

	While !SCR->(Eof()) .and. SCR->CR_FILIAL+SCR->CR_TIPO+AllTRIM(SCR->CR_NUM) == xFilial("SCR")+"SC"+AllTrim(cSol) 

		nApr := aScan(aAprCCust,{|x| AllTrim(x)==SCR->CR_APROV})
		
		If nApr =  0 // Se não achar, significa que o aprovador não pode aprovar esse setor
		
			//Apagar os itens referente ao aprovador
			BeginSql alias "DBMTMP"

			%noparser%
			SELECT R_E_C_N_O_ RECDBM
			FROM %table:DBM% DBM
			WHERE DBM_FILIAL =  %XFilial:DBM% AND DBM_TIPO = 'SC' AND DBM_NUM = %exp:cSol% AND 
			DBM_USAPRO = %exp:SCR->CR_APROV% AND DBM.%notdel%

			EndSql

			While !DBMTMP->(Eof()) 
				
				DbSelectArea("DBM")
				DbSetOrder(1)
				DBM->(Dbgoto(DBMTMP->RECDBM))

				RecLock("DBM",.f.)
				DBM->(DbDelete())
				MsUnlock()

				DBMTMP->(DbSkip())
			Enddo
			DbSelectarea("DBMTMP")
			DbcloseArea()
			//Deletou o DBM Agora vai deletar a SCR
			DbSelectARea("SCR")
			RecLock("SCR",.f.)
			SCR->(DbDelete())
			MsUnlock()


		Endif
		SCR->(DBSKIP())

	Enddo	


	//AJUSTA O STATUS DO MENOR NIVEL, CASO TENHA EXCLUIDO TODOS OS APROVADORES DO 1º NIVEL
	cUpd := "UPDATE " + RetSqlName("SCR") + " SET CR_STATUS = '02' " + CHR(13) + CHR(10)
	cUpd += "WHERE 	CR_FILIAL = '" +xFilial("SCR") + "' AND " + CHR(13) + CHR(10)
	cUpd += "		CR_NUM = '"+cSol+"' AND  " + CHR(13) + CHR(10)
	cUpd += "		CR_TIPO= 'SC' AND  " + CHR(13) + CHR(10)
	cUpd += "		CR_NIVEL =(select MIN(CR_NIVEL) NIVEL FROM " + RetSqlName("SCR") + " A " + CHR(13) + CHR(10)
	cUpd += "					WHERE 	A.CR_FILIAL = '" +xFilial("SCR") + "' AND " + CHR(13) + CHR(10)
	cUpd += "							A.CR_NUM = '"+cSol+"' AND CR_TIPO= 'SC' AND A.D_E_L_E_T_ = ' ') " + CHR(13) + CHR(10)
	cUpd += "		AND D_E_L_E_T_ = ' ' " + CHR(13) + CHR(10)
	If TcSqlExec(cUpd) < 0
		Alert(TcSqlError())	

	Endif

Endif

Return



/*---------------------------------------------------------------------------------------*/
/*Funções do ponto de entrada A010TOK ---------------------------------------------------*/
/*---------------------------------------------------------------------------------------*/


/*
{Protheus.doc} RetDesc()
Retorna Descrição sem caracteres especiais e sem espaços 
@Author     Ramon Teodoro
@Since      09/06/2016       
@Version    P12.7
@Return     lRet
*/

User Function RetDesc(cTexto)

	Local nI     := 0
	Local aCarac := {}

	Aadd(aCarac,{"Á","A"})
	Aadd(aCarac,{"À","A"})
	Aadd(aCarac,{"Â","A"})
	Aadd(aCarac,{"Ã","A"})
	Aadd(aCarac,{"á","a"})
	Aadd(aCarac,{"à","a"})
	Aadd(aCarac,{"â","a"})
	Aadd(aCarac,{"ã","a"})
	Aadd(aCarac,{"É","E"})
	Aadd(aCarac,{"Ê","E"})
	Aadd(aCarac,{"é","e"})
	Aadd(aCarac,{"ê","e"})
	Aadd(aCarac,{"Í","I"})
	Aadd(aCarac,{"í","i"})
	Aadd(aCarac,{"Ó","O"})
	Aadd(aCarac,{"Ô","O"})
	Aadd(aCarac,{"Õ","O"})
	Aadd(aCarac,{"ó","o"})
	Aadd(aCarac,{"ô","o"})
	Aadd(aCarac,{"õ","o"})
	Aadd(aCarac,{"Ú","U"})
	Aadd(aCarac,{"ú","u"})
	Aadd(aCarac,{"Ç","C"})
	Aadd(aCarac,{"ç","c"})
	Aadd(aCarac,{"!"," "})
	Aadd(aCarac,{"@"," "})
	Aadd(aCarac,{"#"," "})
	Aadd(aCarac,{"$"," "})
	Aadd(aCarac,{"%"," "})
	Aadd(aCarac,{"&"," "})
	Aadd(aCarac,{"*"," "})
	Aadd(aCarac,{"("," "})
	Aadd(aCarac,{")"," "})
	Aadd(aCarac,{"-"," "})
	Aadd(aCarac,{"_"," "})
	Aadd(aCarac,{"+"," "})
	Aadd(aCarac,{"="," "})
	Aadd(aCarac,{"\"," "})
	Aadd(aCarac,{"/"," "})
	Aadd(aCarac,{"?"," "})
	Aadd(aCarac,{"["," "})
	Aadd(aCarac,{"]"," "})
	Aadd(aCarac,{"'"," "})
	Aadd(aCarac,{'"'," "})
	Aadd(aCarac,{":"," "})
	Aadd(aCarac,{";"," "})

	For nI := 128 To 255
		Aadd(aCarac,{Chr(nI)," "})
	Next nI

	For nI := 1 To Len(aCarac)
		If aCarac[nI, 1] $ cTexto
			cTexto := StrTran(cTexto, aCarac[nI,1], aCarac[nI,2])
		EndIf
	Next nI

	cTexto := StrTran(cTexto, " ", "")

Return cTexto


/*
{Protheus.doc} VisualPr()
Visualização do produto posicionado 
@Author     Ramon Teodoro
@Since      09/06/2016       
@Version    P12.7
@Return     lRet
*/

User Function VisualPr

	Local lRet    := .t.
	Local n       := oDlSB1:NAT
	Local aArea   := GetArea()
	Local nRec    := Recno()
	Local nPosRec := GDFieldPos("B1_RECNO",oDlSB1:aHeader)
	Local nRecB1  := oDlSB1:aCols[n][nPosRec]

	SB1->(DbGoTo(nRecB1))

	If IsInCallStack("a010copia")
		AxVisual("SB1",nRecB1,1)
	Else
		AxVisual("SB1",nRecB1,2)
	EndIf

	DbGoTo(nRec)
	RestArea(aArea)
Return lRet



/*
{Protheus.doc} VisualE2()
Visualização do produto posicionado 
@Author     Ramon Teodoro
@Since      11/08/2017       
@Version    P12.7
@Return     lRet
*/

User Function VisualE2

	Local lRet    := .t.
	Local n       := oDlSE2:NAT
	Local aArea   := GetArea()
	Local nRec    := Recno()
	Local nPosRec := GDFieldPos("E2_RECNO",oDlSE2:aHeader)
	Local nPosFil := GDFieldPos("E2_FILIAL",oDlSE2:aHeader)
	Local nRecE2  := oDlSE2:aCols[n][nPosRec]
	Local cFilSE2 := oDlSE2:aCols[n][nPosFil]
	Local cArmFil := cFilAnt

	cFilAnt := cFilSE2

	SE2->(DbGoTo(nRecE2))

	AxVisual("SE2",nRecE2,2)

	cFilAnt := cArmFil
	DbGoTo(nRec)
	RestArea(aArea)
Return lRet
/*
{Protheus.doc} VldAltP17()
Validação para alguns campos da tabela P17  - Esta função está sendo usada no X3_WHEN dos campos: P17_COMP, P17_CONSUM, P17_P12FRO e P17_FROP12 
@Author     Ramon Teodoro
@Since      13/12/2017       
@Version    P12.7
@Return     lRet
*/

User Function VldAltP17(cCampo)

	Local lRet := .T.

	If Alltrim(cCampo) == "P17_COMP"

		If FwFldGet("P17_UM2") <> SB1->B1_SEGUM
			lRet := .T.
		Else
			lRet := .F.
		EndIf

	ElseIf Alltrim(cCampo) == "P17_CONSUM"

		If FwFldGet("P17_UM1") <> SB1->B1_UM
			lRet := .T.
		Else
			lRet := .F.
		EndIf

	ElseIf Alltrim(cCampo) == "P17_P12FRO"

		If FwFldGet("P17_UM2") <> SB1->B1_SEGUM .Or. FwFldGet("P17_UM1") <> SB1->B1_UM
			lRet := .T.
		Else
			lRet := .F.
		EndIf

	ElseIf Alltrim(cCampo) == "P17_FROP12"

		If FwFldGet("P17_UM2") <> SB1->B1_SEGUM .Or. FwFldGet("P17_UM1") <> SB1->B1_UM
			lRet := .T.
		Else
			lRet := .F.
		EndIf

	EndIf

Return lRet


Static Function fTelaBZ(cOper,nRecBz,cLocal,cProd,cDoc,cItem,cFilDoc)

	Local lRet := .T.
	Local aParamBox := {}
	Local aRetBox   := ""
	Local lValidou := .F.

	Default cOper := ""
	Default nRecBz := 0
	Default cLocal := ""
	Default cProd := ""
	Default cDoc  := ""
	Default cItem := ""
	Default cFilDoc := ""


	aAdd(aParamBox,{9,"O produto " +AllTrim(cProd)+ " do pedido " +cDoc+ " na filial " +cFilDoc+ " não possui grupo de compras.",150,7,.T.})
	aAdd(aParamBox,{9,"Insira o grupo de compras do item antes de eliminar resíduo.",150,7,.T.})
	aAdd(aParamBox,{1,"Grupo de compras",Space(15),"","","CPGRCO","",0,.F.})

	While !lValidou
		If ParamBox(aParamBox,"",@aRetBox)
			DbSelectArea("SAJ")
			SAJ->(DbSetOrder(2))
			SAJ->(DbSeek(xFilial("SAJ")+__cUserId))

			While SAJ->(!EOF()) .And. SAJ->AJ_FILIAL == xFilial("SAJ") .And. SAJ->AJ_USER == __cUserId
				If SAJ->AJ_GRCOM == AllTrim(aRetBox[3])
					lValidou := .T.
				EndIf
				SAJ->(DbSkip())
			EndDo

			If lValidou
				If cOper == "I"
					RecLock("SBZ",.T.)
					SBZ->BZ_FILIAL  := xFilial("SBZ")
					SBZ->BZ_COD     := cProd
					SBZ->BZ_LOCPAD  := cLocal
					SBZ->BZ_QE      := 0
					SBZ->BZ_XGRPCOM := AllTrim(aRetBox[3])
					SBZ->(MsUnLock())

				ElseIf cOper == "A"
					SBZ->(DbGoto(nRecBz))
					Reclock("SBZ",.F.)
					SBZ->BZ_XGRPCOM := AllTrim(aRetBox[3])
					SBZ->(MsUnLock())
				EndIf
			Else
				MsgAlert("O grupo de compras informado não está vinculado ao usuário!")
			EndIf
		Else
			lRet := .F.
			lValidou := .T.
		EndIf
	EndDo

Return lRet
