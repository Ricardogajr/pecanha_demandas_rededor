#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"

/*
{Protheus.doc} F0100103()
Validação do campo Tabela de preço

@Author			Jose Marcio da Silva Santos
@Since			09/06/2016
@Version		P12.7
@Project    	MAN00000462901_EF_001	
@Return		 	lRet, Retorna True caso o Processo esteja correto, havendo divergências retorna False.
*/

User Function F0100103()
	Local lRet			:= .T.
	Local oModel		:= FWModelActive()
	Local oModelCNA	:= oModel:GetModel("CNADETAIL")
	Local oModelCNB 	:= oModel:GetModel("CNBDETAIL")
	Local oModelCN9	:= oModel:GetModel("CN9MASTER")
	Local cQuery		:= ""
	Local cItem		:= ""
	Local cAlsQry		:= GetNextAlias()
	Local lNoExist	:= .T.
	Local lNoContr	:= .T.
	Local nCount		:= 0
	Local nNewLine	:= 0
	Local nA			:= 0
	
	//-- Verifica se Fornecedor esta preenchido
	If !Empty(oModelCNA:GetValue("CNA_FORNEC")) .And. !Empty(oModelCNA:GetValue("CNA_LJFORN"))
		
		//-- Verifica se tem tabela de preço informada
		If !Empty(oModelCNA:GetValue("CNA_XTABPC"))
			
			//-- Verifica se tabela de preço já esta sendo utilizada por outro contrato
			cQuery := " SELECT CN9.CN9_FILIAL, CN9.CN9_NUMERO, CN9.CN9_DTINIC, CN9.CN9_DTFIM "
			cQuery += " FROM " + RetSqlName("CN9") + " CN9 "
			cQuery += " INNER JOIN " + RetSqlName("CNA") + " CNA ON "
			cQuery += "     CNA.CNA_FILIAL = CN9.CN9_FILIAL "
			cQuery += " AND CNA.D_E_L_E_T_ = '' "
			cQuery += " AND CNA.CNA_CONTRA = CN9.CN9_NUMERO "
			cQuery += " AND CNA.CNA_XTABPC = '" + oModelCNA:GetValue("CNA_XTABPC") + "' "
			cQuery += " AND CNA.CNA_FORNEC = '" + oModelCNA:GetValue("CNA_FORNEC") + "' "
			cQuery += " AND CNA.CNA_LJFORN = '" + oModelCNA:GetValue("CNA_LJFORN") + "' "
			cQuery += " WHERE "
			cQuery += "     CN9.CN9_FILIAL = '" + xFilial("CN9") + "' "
			cQuery += " AND CN9.D_E_L_E_T_ = '' "
			cQuery += " AND CN9.CN9_NUMERO <> '" + oModelCN9:GetValue("CN9_NUMERO") + "' "
			cQuery += " AND CN9.CN9_SITUAC = '05' " //-- 01=Cancelado;02=Elaboracao;03=Emitido;04=Aprovacao;05=Vigente;06=Paralisa.;07=Sol. Finalizacao;08=Finali.;09=Revisao;10=Revisado
			
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAlsQry, .T., .T.)
			
			If (cAlsQry)->(!EOF())
				While (cAlsQry)->(!EOF())
					//-- Verifica Vigencia
					If !Empty((cAlsQry)->CN9_DTFIM)
						If sTod((cAlsQry)->CN9_DTINIC) <= dDataBase .And. sTod((cAlsQry)->CN9_DTFIM) >= dDataBase
							lNoContr := .F.
							Exit
						EndIf
					Else
						lNoContr := .F.
						Exit
					EndIf
					
					(cAlsQry)->(DbSkip())
				EndDo
			EndIf
			(cAlsQry)->(DbCloseArea())
			
			cAlsQry := GetNextAlias()
			
			If lNoContr
			/*
				//-- Busca itens da tabela de preço
				cQuery := " SELECT AIB.AIB_CODFOR, AIB.AIB_LOJFOR, AIB.AIB_CODPRO, AIB.AIB_PRCCOM "
				cQuery += " FROM " + RetSqlName("AIA") + " AIA "
				cQuery += " INNER JOIN " + RetSqlName("AIB") + " AIB ON "
				cQuery += "     AIB.D_E_L_E_T_ = '' "
				cQuery += " AND AIB.AIB_FILIAL = '" + xFilial("AIB") + "' "
				cQuery += " AND AIB.AIB_CODTAB = AIA.AIA_CODTAB "
				cQuery += " AND AIB.AIB_CODFOR = AIA.AIA_CODFOR "
				cQuery += " WHERE "
				cQuery += "     AIA.D_E_L_E_T_ = '' "
				cQuery += " AND AIA.AIA_FILIAL = '" + xFilial("AIA") + "' "
				cQuery += " AND AIA.AIA_CODTAB = '" + oModelCNA:GetValue("CNA_XTABPC") + "' "
				cQuery += " AND AIA.AIA_CODFOR = '" + oModelCNA:GetValue("CNA_FORNEC") + "' "				
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAlsQry, .T., .T.)
				
				If (cAlsQry)->(!EOF())
					While (cAlsQry)->(!EOF())
						lNoExist := .T.
						nCount := 0
						
						If oModelCNB:Length() >= 1
							For nA := 1 To oModelCNB:Length()
								oModelCNB:GoLine(nA)
								
								If !oModelCNB:IsDeleted()
									If !Empty(oModelCNB:GetValue("CNB_PRODUT"))
										nCount++
										If Alltrim(oModelCNB:GetValue("CNB_PRODUT")) == Alltrim((cAlsQry)->AIB_CODPRO)
											lNoExist := .F.
										EndIf
									EndIf
								EndIf
							Next nA
						EndIf
						
						If lNoExist
							If !Empty(oModelCNB:GetValue("CNB_PRODUT"))
								nNewLine := oModelCNB:AddLine()
								oModelCNB:GoLine(nNewLine)
							EndIf
							
							CNTA300BlMd(oModelCNB, .F., .T.)
							
							cItem := Soma1(StrZero(nCount, 3))
							oModelCNB:SetValue("CNB_ITEM", cItem)
							oModelCNB:SetValue("CNB_PRODUT", (cAlsQry)->AIB_CODPRO)
							oModelCNB:SetValue("CNB_QUANT", 1)
							oModelCNB:SetValue("CNB_VLUNIT", (cAlsQry)->AIB_PRCCOM)
							
							CNTA300BlMd(oModelCNB, .F., .F.)
							
						EndIf
						
						(cAlsQry)->(DbSkip())
					EndDo
				EndIf
				(cAlsQry)->(DbCloseArea())
			*/
			Else
				Help('', 1, 'Atenção', ,"Já existe um contrato vigente para o Fornecedor: " + ;
				Alltrim(Posicione("SA2", 1, xFilial("SA2") + oModelCNA:GetValue("CNA_FORNEC") + oModelCNA:GetValue("CNA_LJFORN"), "A2_NOME")) + ;
				", utilizando a Tabela de Preço: " + ;
				Alltrim(oModelCNA:GetValue("CNA_XTABPC")) + " - " + Alltrim(Posicione("AIA", 1, xFilial("AIA") + oModelCNA:GetValue("CNA_FORNEC") + oModelCNA:GetValue("CNA_LJFORN") + oModelCNA:GetValue("CNA_XTABPC"), "AIA_DESCRI")) + "!", 1, 0)
				lRet := lNoContr
			EndIf
		EndIf
	EndIf
	
Return lRet 