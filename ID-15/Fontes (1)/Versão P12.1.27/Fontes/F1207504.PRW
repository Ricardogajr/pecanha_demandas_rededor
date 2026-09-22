#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} F1207504
Rotina chamada a partir dos pontos de entrada MT097GRV e MTALCFIM para gravar o aprovador original.
@author Reinaldo Dias
@since  23/04/2019
@return Nil
@project MAN0000007423048_EF_74
@cliente Rededor
@version P12.1.17
/*/

User Function F1207504(cOpc,aDocto,nOper)
	Local cGlbName   := __cUserID
	Local cDocto     := AvKey(aDocto[1],"CR_NUM")
	Local cTipoDoc	 := aDocto[2]
	Local cAprov	 := If(aDocto[4]==Nil,"",aDocto[4])
	Local cFilSCR    := IIf(cTipoDoc $ 'IC|CT|IR|RV',CnFilCtr(cDocto),xFilial("SCR"))
	Local aRecnoSCR  := {}
	Local oModelCT   := Nil
	Local oModelCN9 := NIL
 	Local oModelCNA := NIL
 	Local oModelCNB := NIL
 	Local oModelCNZ := NIL
	Local lRetorno   := Nil
	Local cAreaSCR   := Nil
	Local nI         
	Local cNivel := ""
	
	//Verificar se o campo específico existe
	IF SCR->(FieldPos('CR_XAPRO')) == 0 
	   Help( , , 'Help', 'F1207504', 'Os campos CR_XAPRO não foi encontrado no banco de dados! Por favor, verificar.', 1, 0 )
	   Return Nil
	Endif 

	If nOper == 1 .And. cOpc = "D"  //Inclusão do Documento - Depois da gravação da SCR e DBM
		
		//Ajusta o aprovador na tabela de Itens de Documentos com Alçada  
		SCR->(DBSetOrder(1)) //CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
		SCR->(MsSeek(cFilSCR+cTipoDoc+cDocto))		    
		While SCR->(!Eof()) .And. SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM == cFilSCR+cTipoDoc+cDocto
			IF !Empty(SCR->CR_XAPRO)
				DBM->(dbSetOrder(1))//DBM_FILIAL+DBM_TIPO+DBM_NUM+DBM_GRUPO+DBM_ITGRP+DBM_USER+DBM_USEROR
				cKeyDBM := SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM+SCR->CR_GRUPO+SCR->CR_ITGRP+SCR->CR_XAPRO
				aRecDBM := {} 
				IF DBM->(dbSeek(cKeyDBM))
					While !DBM->(EOF()) .And. DBM->DBM_FILIAL+DBM->DBM_TIPO+DBM->DBM_NUM+DBM->DBM_GRUPO+DBM->DBM_ITGRP+DBM->DBM_USER == cKeyDBM
						AAdd(aRecDBM,DBM->(Recno()))
						DBM->(dbSkip())
					Enddo
					IF Len(aRecDBM) > 0
						For nI:= 1 To Len(aRecDBM)
							DBM->(DBGoto(aRecDBM[nI]))
							IF !DBM->(EOF())
								RecLock("DBM",.F.)
								DBM->DBM_USER   := SCR->CR_USER 
								DBM->DBM_USAPRO := SCR->CR_APROV
								DBM->DBM_USEROR := SCR->CR_USERORI
								DBM->DBM_USAPOR := SCR->CR_APRORI 
								DBM->(MsUnLock())
							Endif
						Next
					Endif	
				Endif
			Endif
			SCR->(DBSkip())
		Enddo

	ElseIf nOper == 2  //Transferência da Alçada para o Superior
		
		IF cOpc = "A" //Antes da gravação da tabela SCR
			PutGlbValue(cGlbName,SCR->CR_APROV) //O conteúdo da variável cGlbName será utilizada quando a Opc = "D"		
		ElseIF cOpc = "D" //Depois da Gravação do SCR
			cAprovOri := GetGlbValue(cGlbName)
			IF !Empty(cAprovOri)
				Reclock("SCR",.F.)
				SCR->CR_XAPRO := cAprovOri
				SCR->CR_XNOME := UsrFullName(SCR->CR_USER)
				MsUnlock()
				ClearGlbValue(cGlbName)
			Endif
		Endif
		 
	ElseIF nOper == 4 .And. cOpc = "D" //Aprovação do documento depois da gravação da SCR  - Depois da gravação da SCR e DBM.

		cAreaSCR   := SCR->(GetArea())
		SCR->(DBSetOrder(3)) //CR_FILIAL+CR_TIPO+CR_NUM+CR_APROV
		If SCR->(MsSeek(cFilSCR+cTipoDoc+cDocto+cAprov))
			aRecnoSCR := {}
			cGrupo    := SCR->CR_GRUPO
			cItGrp    := SCR->CR_ITGRP		    
			
			//Identifica todas as aprovações que estão amarradas ao aprovador
			While SCR->(!Eof()) .And. SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM+SCR->CR_APROV == cFilSCR+cTipoDoc+cDocto+cAprov
				If cGrupo == SCR->CR_GRUPO .And. SCR->CR_ITGRP == cItGrp
					If SCR->CR_STATUS <> "03" .And. SCR->CR_STATUS <> "04" .And. SCR->CR_STATUS <> "05"
						AAdd(aRecnoSCR,SCR->(Recno())) 
					Endif
				Endif
				SCR->(DBSkip())
			Enddo

			//Finaliza as aprovações dos documentos com o mesmo código do aprovador.
			For nI:= 1 To Len(aRecnoSCR)
				SCR->(DBGoto(aRecnoSCR[nI]))
				IF SCR->(!Eof())
					Do Case
						Case SCR->CR_TIPO == "NF"
							cChave := xFilial("SF1")+Substr(SCR->CR_NUM,1,Len(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
							DBSelectArea("SF1")
							DBSetOrder(1)
							MsSeek(cChave)
						Case SCR->CR_TIPO == "PC" .Or. SCR->CR_TIPO == "AE"
							cChave := xFilial("SC7")+Substr(SCR->CR_NUM,1,len(SC7->C7_NUM))
							DBSelectArea("SC7")
							DBSetOrder(1)
							MsSeek(cChave)
						Case SCR->CR_TIPO == "CP"
							cChave := xFilial("SC3")+Substr(SCR->CR_NUM,1,len(SC3->C3_NUM))
							DBSelectArea("SC3")
							DBSetOrder(1)
							MsSeek(cChave)
						Case SCR->CR_TIPO == "ST"
							cChave := xFilial("NNS")+Substr(SCR->CR_NUM,1,Len(NNS->NNS_COD))
							DBSelectArea("NNS")
							DBSetOrder(1)
							MsSeek(cChave)
						Case SCR->CR_TIPO $ "RV|IR|CT|IC"
							cNumDoc := Substr(SCR->CR_NUM,1,TAMSX3('CN9_NUMERO')[1] + TAMSX3('CN9_REVISA')[1])
							cChave 	:= xFilial("CN9")+cNumDoc
							DBSelectArea("CN9")
							DBSetOrder(1)
							MsSeek(cChave)
						Case SCR->CR_TIPO $ "MD|IM"
							cNumDoc	:= Substr(SCR->CR_NUM,1,TAMSX3('CND_NUMMED')[1])
							cChave := xFilial("CND")+cNumDoc
							DBSelectArea("CND")
							DBSetOrder(4)
							MsSeek(cChave)
						Otherwise
							If !Empty(aMTAlcDoc := MTGetAlcPE(SCR->CR_TIPO))
								DBSelectArea(aMTAlcDoc[2])
								DBSetOrder(aMTAlcDoc[3])
								MsSeek(xFilial(aMTAlcDoc[2])+Substr(SCR->CR_NUM,1,Len(&(aMTAlcDoc[4]))))
							EndIf
					EndCase
					
					oModelCT := FWLoadModel(If(CN9->CN9_ESPCTR == "1","CNTA300","CNTA301"))
					oModelCT:SetOperation(nOper)
					oModelCT:Activate()
					oModelCN9 := oModelCT:GetModel("CN9MASTER")
					oModelCNA := oModelCT:GetModel("CNADETAIL")
					oModelCNB := oModelCT:GetModel("CNBDETAIL")
					oModelCNZ := oModelCT:GetModel("CNZDETAIL")
					A097ProcLib(SCR->(Recno()),2,,,,,dDataBase,oModelCT) //Realiza o processamento da liberação de documentos.						
				Endif
			Next					
			
			SCR->(DBSetOrder(1)) //CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
			
			//Ajusta o status dos documento de 02 para 01.
			SCR->(MsSeek(cFilSCR+cTipoDoc+cDocto))	
			While SCR->(!Eof()) .And. SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM == cFilSCR+cTipoDoc+cDocto
				If cGrupo == SCR->CR_GRUPO .And. SCR->CR_ITGRP == cItGrp
					IF SCR->CR_STATUS == "02"
					   Reclock("SCR",.F.)
					   SCR->CR_STATUS := "01"
					   MsUnlock()
					Endif
				Endif	
				SCR->(DBSkip())
			Enddo
			
			//Ajusta o documento da próxima aprovação para o status 02
			SCR->(MsSeek(cFilSCR+cTipoDoc+cDocto))
			
			cNivel := ""
			
			While SCR->(!Eof()) .And. SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM == cFilSCR+cTipoDoc+cDocto
				If cGrupo == SCR->CR_GRUPO .And. SCR->CR_ITGRP == cItGrp
					IF SCR->CR_STATUS == "01"
						IF cNivel = ""
							cNivel := SCR->CR_NIVEL
						Endif
 	
						IF SCR->CR_NIVEL == cNivel
							Reclock("SCR",.F.)
							SCR->CR_STATUS := "02"
							MsUnlock()
						
						Endif
					Endif
				Endif	
				SCR->(DBSkip())
			Enddo
			
			//Verifica se libera o documento referente aprovação.
			SCR->(DBSetOrder(3)) //CR_FILIAL+CR_TIPO+CR_NUM+CR_APROV 
			lRetorno := .T.
			If SCR->(MsSeek(cFilSCR+cTipoDoc+cDocto))
				While SCR->(!Eof()) .And. SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM == cFilSCR+cTipoDoc+cDocto
					If cGrupo == SCR->CR_GRUPO .And. SCR->CR_ITGRP == cItGrp
						If SCR->CR_STATUS <> "03" .And. SCR->CR_STATUS <> "04" .And. SCR->CR_STATUS <> "05"
							lRetorno := .F.
							Exit
						EndIf
					Endif
					SCR->(dbSkip())
				Enddo
			Endif

		EndIf
		RestArea(cAreaSCR)
	Endif

Return(lRetorno)