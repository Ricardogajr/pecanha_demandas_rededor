#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
Static lPreeRB6	:= .F.
Static aTabAtu  := {}
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} M0500401
(Ponto de Entrada MVC do modelo MS050401)
@type function
@author Cris
@since 28/10/2016
@version P12.1.7
@Project MAN0000007423039_EF_004
@return ${return}, ${não há}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function M0500401()
	
	Local aParam    := PARAMIXB
	Local xRet      := .T.
	Local oObj      := aParam[1]
	Local cIdPonto  := aParam[2]
	Local cTabSal	:= ''
	Local nLinAtu	:= 1
	Local cNumRH3	:= ''
	Local nCrgHrPp	:= 0
	Local nCrgHrAt	:= 0
	Local nSalPnal	:= 0
//?	Local nPerTol	:= 1
	Local nPropSal	:= 0
	Local nFaixa	:= 1
	Local nFxTabAt	:= 0
	Local nX        := 0
	
	//Sinalizado que a cada nova ativação da tabela uma nova consulta deverá ser efetuada na tabela Salarial
	if cIdPonto == "MODELVLDACTIVE"
		
		lPreeRB6	:= .F.
		
	EndIf
	
	//Simulo uma alteração no model principal para que seja permitido a gravação dos dados necessários
	If cIdPonto == 'MODELPOS'
		
		oObj:GetModel("F0500401"):SetValue("RH3_MAT","")
		
	EndIf
	
	//Verifico se realmente o colaborador deseja abortar a operação
	if cIdPonto == 'MODELCANCEL'
		
		//If ( xRet := ApMsgYesNo( 'Deseja Realmente Sair ?' ) )
		
		Help( ,, 'Help',"CANCELAMENTO DA SOLICITAÇÂO", 'Solicitação abortada pelo colaborador.', 1, 0 )
		
		While .T.
			cNumRH3 := GetSX8Num("RH3","RH3_CODIGO")
			DbSelectArea("RH3")
			RH3->( DbSetOrder(1) )
			If RH3->(DbSeek(xFilial("RH3") + cNumRH3 ))
				ConfirmSX8()
				Conout("[RH3] - Realocando contador -> " + cNumRH3)
				Loop
			EndIf
			Exit
		EndDo
		
		ConfirmSX8()
		
		//Requisito N005 -  Indicadores: -057-Logou se na tela - somente no cancelamento esta sendo gravado
		U_F0500201(xFilial('RH3'),cNumRH3,'057')
		
		//EndIf
		MtBCMod(oObj,{"SALDETAIL"},{||.T.})
		
	EndIf
	
	//Carrego a Tabela Salarial de acordo com a informada no cadastro de funcionário
	If cIdPonto ==  'MODELPRE'
		
		if !lPreeRB6
			
			lPreeRB6	:=  .T.
			
			oObj:GetModel("F0500401"):SetValue("RH3_MAT",SRA->RA_MAT)
			
			cTabSal	 := GetNextAlias()
			
			SelTabSl(@cTabSal)
			
			If !(cTabSal)->(Eof())
				
				While !(cTabSal)->(Eof())

					AAdd(aTabAtu,{(cTabSal)->RB6_NIVEL,(cTabSal)->RB6_FAIXA,(cTabSal)->RB6_VALOR})

					(cTabSal)->(dbSkip())
					
					nLinAtu	:= nLinAtu + 1
					
				Enddo
				
				If SRA->RA_HRSMES == 220
					
					For nX := 1 To Len(aTabAtu)
						
						If nX > 1
							oObj:GetModel("RB6DETAIL"):AddLine()
						EndIf
						
						oObj:GetModel("RB6DETAIL"):SetValue("NIVELATU",aTabAtu[nX][1])
						oObj:GetModel("RB6DETAIL"):SetValue("FAIXAATU",aTabAtu[nX][2])
						oObj:GetModel("RB6DETAIL"):SetValue("VALORATU",aTabAtu[nX][3])
						
					Next nX
					
				Else
					
					nCrgHrPp	:=  SRA->RA_HRSMES
					nCrgHrAt	:=  220
					
					//Somente se a carga horária foi alterada e for diferente da Carga horaria padrão 220
					if nCrgHrPp <> 0 .AND. nCrgHrPp <> nCrgHrAt .AND. nCrgHrPp < 220
						//Caso tenha sido informado uma  carga horária diferente da atual, efetua a proporcionalidade
						
						nFxTabAt := Len(aTabAtu) //Carrego a quantidade de faixas existente
						
						if nFxTabAt > 0 .AND. aTabAtu[1][3] <> 0
							
							//Busco o percentual de tolerância
							aAreaRCA := RCA->(GetArea())
							/*??
							dbSelectArea("RCA")
							RCA->(dbSetOrder(1))
							If RCA->(DbSeek(FwxFilial("RCA") + "M_PERCTOL"))	//??
								nPerTol	:= Val(RCA->RCA_CONTEU)
							EndIf
							??*/
							//Monto a tabela temporária de acordo com o numero de faixas existentes na tabela atual associada ao funcionário
							While nFaixa < nFxTabAt + 1
								
								nSalPnal	:= Round((aTabAtu[nFaixa][3]*nCrgHrPp)/nCrgHrAt,2)
								
								If nFaixa > 1
									oObj:GetModel("RB6DETAIL"):AddLine()
								EndIf
								
								oObj:GetModel("RB6DETAIL"):GoLine(nFaixa)
								
								
								oObj:GetModel("RB6DETAIL"):SetValue("NIVELATU",aTabAtu[nFaixa][1])
								oObj:GetModel("RB6DETAIL"):SetValue("FAIXAATU",aTabAtu[nFaixa][2])
								//?oObj:GetModel("RB6DETAIL"):SetValue("VALORATU",Round(nSalPnal + ((nSalPnal*nPerTol)/100),2))
								oObj:GetModel("RB6DETAIL"):SetValue("VALORATU",nSalPnal)
								
								nFaixa	:=  nFaixa  + 1
								
							EndDo
							
							//Posiciono na primeira linha para garantir uma exibição correta
							oObj:GetModel("RB6DETAIL"):GoLine(1)
							
							RestArea(aAreaRCA)
							
						EndIf
						
					EndIf
					
				EndIf
				
			EndIf
			
			(cTabSal)->(dbCloseArea())
			aTabAtu  := {}
			//MtBCMod(oObj,{"RB6DETAIL"},{||.F.})
			
		EndIf
		
	EndIf
	
Return xRet
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SelTabSl
(long_description)
@type function
@author Cris
@since 28/10/2016
@version 1.0
@param cTabSal, character, (Descrição do parâmetro)
@version P12.1.7
@Project MAN0000007423039_EF_004
@return ${return}, ${não há}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function SelTabSl(cTabSal)
	
	Local cQryRB6		:= ""
	
	cQryRB6	:= " SELECT RB6_FILIAL, RB6_TABELA, RB6_DESCTA, RB6_TIPOVL, RB6_NIVEL, RB6_FAIXA,RB6_VALOR, RB6_PTOMIN, RB6_PTOMAX,  " + CRLF
	cQryRB6	+= " RB6_DTREF, RB6_COEFIC,RB6_REGIAO, RB6_ATUAL  " + CRLF
	cQryRB6	+= " FROM " + RetSqlName("RB6") + " (NOLOCK) RB6" + CRLF
	cQryRB6	+= " INNER JOIN " + RetSqlName("RBR") + "  RBR" + CRLF
	cQryRB6	+= " ON RBR_FILIAL = RB6_FILIAL" + CRLF
	cQryRB6	+= " AND RBR_TABELA = RB6_TABELA" + CRLF
	cQryRB6	+= " AND RBR_APLIC = '1'" + CRLF
	cQryRB6	+= " AND RBR_DTREF = RB6_DTREF" + CRLF
	cQryRB6	+= " AND RBR.D_E_L_E_T_ = ' '" + CRLF
	cQryRB6	+= " WHERE RB6_FILIAL = '" + xFilial("RB6") + "'  " + CRLF
	cQryRB6	+= " AND RB6_TABELA = '" + SRA->RA_TABELA + "'  " + CRLF
	cQryRB6 	+= " AND RB6_NIVEL = '" + SRA->RA_TABNIVE + "'" + CRLF
	cQryRB6	+= " AND RB6.D_E_L_E_T_ = ' '" + CRLF
	
	cQryRB6 := ChangeQuery(cQryRB6)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRB6),cTabSal,.T.,.T.)
	
Return
