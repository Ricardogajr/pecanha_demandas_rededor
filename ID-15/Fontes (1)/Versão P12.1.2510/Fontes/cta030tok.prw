#Include "Protheus.ch"


//PE criado para melhoria no chamado RITM0353912
//Lucas Miranda de Aguiar 04/12/2023
User Function CTA030TOK()

	Local aArea := Getarea()
	Local nOpc := PARAMIXB
	Local lRet := .F.
	Local cQuery := ""
	Local cAliasTmp := GetNextAlias()
	Local cMsg := ""


	If nOpc == 4 //Alteração

		If CTT->CTT_BLOQ == "2" .And. M->CTT_BLOQ == "1"

			cQuery += " SELECT 'P11' AS TABELA, P11_FILIAL AS FILIAL, P11_COD AS CODIGO, P11_DESC AS DESCRI FROM  " +RetSqlName("P11")+ " WHERE P11_CCUSTO = '"+CTT->CTT_CUSTO+"' AND P11_MSBLQL = '2' AND D_E_L_E_T_ = ' ' AND ROWNUM < 11"
			cQuery += " UNION ALL"
			cQuery += " SELECT 'NNR' AS TABELA, NNR_FILIAL AS FILIAL, NNR_CODIGO AS CODIGO, NNR_DESCRI AS DESCRI FROM " +RetSqlName("NNR")+" WHERE NNR_XCUSTO = '"+CTT->CTT_CUSTO+"' AND NNR_XBLOQ = 'N' AND D_E_L_E_T_ = ' ' AND ROWNUM < 11"
			cQuery += " ORDER BY TABELA"


			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)

			If !((cAliasTmp)->(Eof()))
				lRet := .T.
			EndIf
			If lRet
				cMsg := "<b><center><h1>Bloqueio não permitido!</h1></center></b>"
				cMsg += "<h3>Não é permitido inativar centro de custo vinculado a local de estoque ou setor.</h3>"
				cMsg += "<h4>O centro de custo está vinculado com os locais/setores abaixo: </h4>"
				While !((cAliasTmp)->(Eof()))
					If (cAliasTmp)->TABELA == "P11"
						cMsg += "SETOR - Filial: "+(caliasTmp)->FILIAL+ " Código: "+(cAliasTmp)->CODIGO+ " Descrição: "+AllTrim((cAliasTmp)->DESCRI) + CRLF
					ElseIf (cAliastmp)->TABELA == "NNR"
						cMsg += "LOCAL - Filial: "+(caliasTmp)->FILIAL+ " Código: "+(cAliasTmp)->CODIGO+ " Descrição: "+AllTrim((cAliasTmp)->DESCRI) + CRLF
					EndIf

					(cAliasTmp)->(DbSkip())
				EndDo
				FWAlertError(cMsg)
			EndIf

			(cAliasTmp)->(DbCloseArea())

			If !lRet
				cQuery := " SELECT 1 FROM "+RETSQLNAME("SRA")+" WHERE D_E_L_E_T_ = ' ' AND RA_SITFOLH <> 'D' AND RA_CC = '"+CTT->CTT_CUSTO+"'"

				DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)

				If !((cAliasTmp)->(Eof()))
					lRet := .T.
				EndIf

				If lRet
					Help(NIL, NIL, "CTA030TOK", NIL, "Não é possível inativar o centro de custo. Existem funcionários ativos vinculados.", 1, 0, NIL, NIL, NIL, NIL, NIL, {""})
				EndIf
				(cAliasTmp)->(DbCloseArea())
			EndIf
		EndIf
	EndIf
	RestArea(aArea)
Return lRet
