#Include 'Protheus.ch'
 
/*
{Protheus.doc} F0800501()
Busca do superior
@Author     Bruno de Oliveira
@Since      10/03/2017
@Version    P12.1.07
@Project    MAN0000007423042_EF_005
@Param		cNovSol, caracter, 1=Nova solicitação;2=Aprovação
@Param		cCodAlc, caracter, Código da alçada
@Param		cNvAprv, caracter, Nível do próximo aprovador
@Param		cTpSol,  caracter, tipo de solicitação
@Param		cSubGrp, caracter, subgrupo do tipo de solicitação
@Param		cFilResp,caracter, filial do solicitante
@Param		cMatResp,caracter, matricula do solicitante
@Param		cFSold,  caracter, Filial do solicitado  
@Param		cMSold,  caracter, matricula do solicitado
@Param		cFilRH3,  caracter, Filial da solicitação
@Param		cNumRH3,  caracter, Numero da solicitação
@Param		aEmail, email dos usuários
@Param		lPortal, indica se a solicitação foi realizada via portal ou não
@Return     aRet, parametros referente ao aprovador
*/
User Function F0800501(cNovSol,cCodAlc,cNvAprv,cTpSol,cSubGrp,cFilResp,cMatResp,cFSold,cMSold,cFilRH3,cNumRH3,aEmail,lPortal,cFilPost,cCodPost)
	
	Local aArea := GetArea()
	Local lRet  := .T.
	Local aRetPerm := {}
	Local aRet	:= {}
	Local nPos  := 0
	Local cObsLog := ''
	Local aDdSolic	:= {}
	Local cFilVga 	:= ""
	Local cMatVga	:= ""
	
	Default lPortal	:= .T.
	
	If cNovSol == "1" //Nova Solicitação
		
		If !lPortal
			If cTpSol == "004"
				cFilVga := cFilResp
				cMatVga := cMatResp
			EndIf
			
			If Empty(cMatResp) .Or. Empty(cFilResp)
				aDdSolic	:= PswRet()
				///cMatResp 	:= Substring(aDdSolic[1][22],len(cEmpAnt) + len(cFilAnt) + 1,12)
				cMatResp 	:= SubString(aDdSolic[1][22], (Len(aDdSolic[1,22])-6) + 1 , 12)
				cFilResp	:= Substring(aDdSolic[1][22],len(cEmpAnt) + 1,len(cFilAnt))
			EndIf
		EndIf
		
		FWMsgRun(,{|| aRetPerm := FsIncSolic(.F.,cTpSol,cSubGrp,cFilResp,cMatResp,cFSold,cMSold,cFilRH3,cNumRH3,@aEmail,lPortal, cFilVga, cMatVga, cNovSol) },"Aguarde!","Validando o Cadastro de Alçadas..." )
		
		nPos := AScan(aRetPerm,{|x| x[1] == .F. })
		If nPos > 0 //existir todos os aprovadores3
			If Empty(aRetPerm[nPos][8])
				cMsg := "Não é permitido incluir a solicitação, devido não existir alocação em alguns itens da Alçada"
				AAdd(aRet,{.F.,"","","","","","",cMsg})
			Else
				AAdd(aRet, aClone(aRetPerm[nPos]))
			EndIf
		Else
			aRet := FsIncSolic(.T.,cTpSol,cSubGrp,cFilResp,cMatResp,cFSold,cMSold,cFilRH3,cNumRH3,@aEmail,lPortal, cFilVga, cMatVga, cNovSol)
		EndIf
		
	ElseIf cNovSol == "2" //Aprovação
		
		DbSelectArea("PAB")
		PAB->(DbSetOrder(1))
		If PAB->(DbSeek(xFilial("PAB") + cCodAlc))
			nNvMin   := VAL(PAB->PAB_NIVMIN)
			cVisao   := PAB->PAB_VISAO
			nNvMax   := VAL(PAB->PAB_APRMAX)
			cCodAlc  := PAB->PAB_CODIGO
			nLimit   := PAB->PAB_LIMNIV
			nTotLim  := PAB->PAB_LIMNIV
			cTpSol   := PAB->PAB_TPSOLI
			cSubGrp  := PAB->PAB_GRPSOL
		Else
			lRet := .F.
			cMsg := "não foi encontrada nenhuma alçada cadastrada para esse Tipo e subgrupo de solicitação"
			AAdd(aRet,{.F.,"","","","","","",cMsg})
		EndIf
		
		DbSelectArea("PAC")
		PAC->(DbSetOrder(1))
		If PAC->(DbSeek(xFilial("PAC") + cCodAlc + cNvAprv))
			
			While PAC->(!EOF()) .AND. PAC->(PAC_FILIAL + PAC_CODALC)== xFilial("PAC") + cCodAlc
				
				aRet := {}
				
				If PAC->PAC_TIPAPR == "1" //Tipo de aprovação por nível
					
					If PAC->PAC_NUMNIV > 0
						aResult := FsTpNivel(cVisao,cFilResp,cMatResp,PAC->PAC_NUMNIV,nNvMax,nLimit,.T.,cFSold,cMSold,cCodAlc,PAC->PAC_NIVEL,cTpSol,cSubGrp,cFilRH3,cNumRH3,cNovSol,cFilPost,cCodPost)
						
						AAdd(aRet,{aResult[1][1],;			//Encontrou o aprovador?
						aResult[1][2],;			//Filial Aprovador
						aResult[1][3],; 		//Código Aprovador
						PAC->PAC_NIVEL,;		//Nível do Aprovador
						"",;					//Próximo Nível
						cCodAlc,;				//Código da Alçada
						aResult[1][4],; 		//E-mail do aprovador
						aResult[1][5],;			//Mensagem de retorno
						aResult[1][6],;			//Filial do Substituido
						aResult[1][7]})			//Matricula do Substituido
						
					Else
						AAdd(aRet,{.F.,"","","","","","","Nível cadastrado na alçada precisa ser maior que zero"})
					EndIf
					
					
				ElseIf PAC->PAC_TIPAPR == "2" .AND. PAC->PAC_VINCL != "1" //Tipo de aprovação por Posto Fixo sem vinculo
					
					aResult := FsTpPosto(PAC->PAC_CODPOS,cFilResp,nNvMax,.T.,cFSold,cMSold,PAC->PAC_NIVEL,cTpSol,cSubGrp,cFilRH3, cNumRH3)
					
					AAdd(aRet,{aResult[1][1],;			//Encontrou o aprovador?
					aResult[1][2],;			//Filial Aprovador
					aResult[1][3],;			//Código Aprovador
					PAC->PAC_NIVEL,;		//Nível do Aprovador
					"",; 				//Próximo Nível
					cCodAlc,;				//Código da Alçada
					aResult[1][4],;			//E-mail do aprovador
					aResult[1][5],;			//Mensagem de retorno
					aResult[1][6],;			//Filial do Substituido
					aResult[1][7]})			//Matricula do Substituido
					
				ElseIf PAC->PAC_TIPAPR == "2" .AND. PAC->PAC_VINCL == "1" //Tipo de aprovação por Posto Fixo com vinculo
					If cTpSol <> "002" .AND. cTpSol <> "003" .AND. cTpSol <> "004"
						aResult := FsTpPosto(PAC->PAC_CODPOS,cFSold,nNvMax,.T.,cFSold,cMSold,PAC->PAC_NIVEL,cTpSol,cSubGrp,cFilRH3, cNumRH3)
					Else
						aResult := FsTpPosto(PAC->PAC_CODPOS,cFilResp,nNvMax,.T.,cFSold,cMSold,PAC->PAC_NIVEL,cTpSol,cSubGrp,cFilRH3, cNumRH3)
					EndIf

					AAdd(aRet,{aResult[1][1],; //Encontrou o aprovador?
					aResult[1][2],;			//Filial Aprovador
					aResult[1][3],;			//Código Aprovador
					PAC->PAC_NIVEL,;		//Nível do Aprovador
					"",;                    //Próximo Nível
					cCodAlc,;				//Código da Alçada
					aResult[1][4],;			//E-mail do aprovador
					aResult[1][5],;			//Mensagem de retorno
					aResult[1][6],;			//Filial do Substituido
					aResult[1][7]})			//Matricula do Substituido
				EndIf
				
				If aResult[1][1] //Encontrou aprovador
					
					If PAC->PAC_APRNOT == "2" //Notificado
						DbSelectArea("SRA")
						SRA->(DbSetOrder(1))
						SRA->(DbSeek(aResult[1][2] + aResult[1][3]))
						DbSelectArea("PAB")
						PAB->(DbSetOrder(1))
						PAB->(DbSeek(xFilial("PAB") + cCodAlc))
						cObsLog := "Aprovador Notificado."
						U_F0800201("3",cFilRH3,cNumRH3,cCodAlc,cFilResp,cMatResp,aResult[1][2],aResult[1][3],cObsLog,SRA->RA_EMAIL,PAC->PAC_NIVEL)
						U_F0800901("3",SRA->RA_EMAIL,cFilRH3,cNumRH3,SRA->RA_NOME,PAB->PAB_TPSOLI,PAB->PAB_GRPSOL,PAC->PAC_NIVEL,cObsLog)

					Else
						//Se aprovar direto devido aprovador ter um nivel maior
						If aResult[1][5] != "Aprovador aprova direto!"
							If !Empty(aResult[1][2]) .AND. !Empty(aResult[1][3])
								If !((aResult[1][2] == cFilResp) .AND. (aResult[1][3] == cMatResp )) //solicitante não é o aprovador
									Exit
								Endif
							EndIf
						EndIf
					EndIf
					
				Else
					Exit
				EndIf

				PAC->(DbSkip())
			End
		Else
			AAdd(aRet,{.F.,"","","","","","","Não existe nível de número " + cNvAprv + " para o cadastrado de alçada " + cCodAlc + "."})
		EndIf
		
	EndIf
	IF ! (Empty(aRet))
		If aRet[1][1]
			If !(aRet[1][4] == "FM")
				cProxNvl := StrZero( (Val(aRet[1][4]) + 1), 2 )
				PAC->(DbSetOrder(1))
				If PAC->(DbSeek(xFilial("PAC") + aRet[1][6] + cProxNvl))
					aRet[1][5] := cProxNvl
				Else
					aRet[1][5] := "FM"
				EndIf
			EndIf
		Else
			aRet[1][5] := "CL"
		EndIf
	Else
		nQtd := Len(aRetPerm)
		If aRetPerm[nQtd][8] == "Aprovador aprova direto!"
			aAdd(aRet,{.T.,;		//Encontrou o aprovador?
					   "",;		//Filial Aprovador
					   "",; 		//Código Aprovador
					   "",;		//Nível do Aprovador
					   "FM",;		//Próximo Nível
					   "",;		//Código da Alçada
					   "",; 		//E-mail do aprovador
			            "aprova direto!",;  //Mensagem de retorno
			            "",;				//Filial do Substituido
			            ""})				//Matricula do Substituido	
		Else
			aRet := aRetPerm
		EndIf
	Endif
	
	RestArea(aArea)
	
Return aRet

/*
{Protheus.doc} FsTpNivel()
Busca do Aprovador por Nível
@Author     Bruno de Oliveira
@Since      14/03/2017
@Version    P12.1.07
@Project    MAN0000007423042_EF_005
@Param		cVisao, caracter, código da visão
@Param		cFilResp, caracter, filial do solicitante
@Param		cMatResp, caracter, matricula do solicitante
@Param		nNivel, numerico, quantidade da busca
@Param		nNvMax, nível máximo do aprovador
@Return		aRet, informações do aprovador
*/
Static Function FsTpNivel(cVisao,cFilResp,cMatResp,nNivel,nNvMax,nLimit,lSegVz,cFSold,cMSold,cCodAlc,cNvAprv,cTpSol,cSubGrp,cFilRH3,cNumRH3,cNovSol,cFilPost,cCodPost)
	
	Local aArea   := GetArea()
	Local aRet    := {}
	Local aAprov  := {}
	Local cEmpIde := cEmpAnt
	Local cAlias2 := GetNextAlias()
	Local cAlias3 := GetNextAlias()
	Local cAlias4 := GetNextAlias()
	Local cRCX    := "%" + RetFullName("RCX",cEmpAnt) + "%"
	Local cRD4    := "%" + RetFullName("RD4",cEmpAnt) + "%"
	Local cSRA    := "%" + RetFullName("SRA",cEmpAnt) + "%"
	Local cRDZ	  := "%" + RetFullName("RDZ",cEmpAnt) + "%"
	Local cRD0	  := "%" + RetFullName("RD0",cEmpAnt) + "%"
	Local lRet	  := .F.
	Local lSubst  := .T.
	Local cFlSubd := ""
	Local cMtSubd := ""
	
	Default cFilRH3	:= ""
	Default cNumRH3	:= ""

	//Posiciona no solicitante
	cAlias2 := GetNextAlias()
	If cNovSol == "1" //Nova Solicitação
		BeginSql alias cAlias2
			
			SELECT RD4.RD4_TREE, RD4.RD4_ITEM
			FROM %EXP:cRCX% RCX
			INNER JOIN %table:RD4% RD4 ON RD4.RD4_CODIDE = RCX.RCX_POSTO AND RCX.RCX_FILIAL = RD4.RD4_FILIDE
			WHERE
			RD4.RD4_FILIAL = %xfilial:RD4%  AND
			RD4.RD4_CODIGO = %exp:cVisao%   AND
			RCX.RCX_MATFUN = %exp:cMatResp% AND
			RCX.RCX_FILFUN = %exp:cFilResp% AND
			RCX.RCX_SUBST  = '2'            AND
			RCX.RCX_TIPOCU = '1'            AND
			RD4.%notDel%                    AND
			RCX.%notDel%
			
		EndSql
	Else
		BeginSql alias cAlias2
			
			SELECT RD4.RD4_TREE, RD4.RD4_ITEM
			FROM %EXP:cRD4% RD4
			WHERE
			RD4.RD4_FILIAL = %xfilial:RD4%  AND
			RD4.RD4_CODIGO = %exp:cVisao%   AND
			RD4.RD4_FILIDE = %exp:cFilPost% AND //Filial do Posto
			RD4.RD4_CODIDE = %exp:cCodPost% AND //Codigo do Posto
			RD4.%notDel%                    
			
		EndSql	
	EndIf	
	
	If !(cAlias2)->(EOF())
		
		cTree := (cAlias2)->RD4_TREE
		cItem := (cAlias2)->RD4_ITEM
		nX := 1
		
		If !Empty(cTree) .And. AllTrim(cTree) != "000000"
			//Busca o superior a partir dos níveis definidos
			While nX <= nNivel
				
				If nX > 1
					cAlias3 := GetNextAlias()
					BeginSql alias cAlias3
						
						SELECT RD4.RD4_CHAVE, RD4.RD4_EMPIDE, RD4.RD4_TREE, RD4.RD4_CODIDE
						FROM %Exp:cRD4% RD4
						WHERE RD4.RD4_FILIAL = %xfilial:RD4% AND
						RD4.RD4_CODIGO = %exp:cVisao%  AND
						RD4.RD4_ITEM   = %exp:cTree%   AND
						RD4.%notDel%
						
					EndSql
			
					If (cAlias3)->( !Eof() )
						cTree := (cAlias3)->RD4_TREE
						If cTree == "000000"
							(cAlias3)->(DbCloseArea())
							Exit
						EndIf
					Else
						cItem := cTree
						cTree := ""
						(cAlias3)->(DbCloseArea())
						Exit
					EndIf
	
				EndIf
				
				nX := nX + 1
			End
		Endif
		//Verifica se tem superior alocado no posto
		If !Empty(cTree)
			If cTree != "000000"
				//Posiciona
				cAlias4 := GetNextAlias()
				BeginSql alias cAlias4
					
					SELECT RCX.RCX_FILFUN, RCX.RCX_MATFUN, SRA.RA_EMAIL, SRA.RA_CODFUNC, SRA.RA_SITFOLH
					FROM %Exp:cRCX% RCX
					INNER JOIN %table:RD4% RD4 ON RD4.RD4_CODIDE = RCX.RCX_POSTO AND RCX.RCX_FILIAL = RD4.RD4_FILIDE
					INNER JOIN %Exp:cSRA% SRA ON SRA.RA_FILIAL = RCX.RCX_FILFUN AND	SRA.RA_MAT = RCX.RCX_MATFUN
					INNER JOIN %Exp:cRDZ% RDZ ON RDZ.RDZ_CODENT = SRA.RA_FILIAL || SRA.RA_MAT
					INNER JOIN %Exp:cRD0% RD0 ON RD0.RD0_CODIGO = RDZ.RDZ_CODRD0
					WHERE RD0.RD0_FILIAL = %xfilial:RD0% AND
					RDZ.RDZ_EMPENT = %exp:cEmpIde% AND
					RDZ.RDZ_FILIAL = %xfilial:RDZ% AND
					SRA.RA_SITFOLH NOT IN ('D') AND //Melhoria Temporaria ID 945 retirada do ",'F'"
					RD4.RD4_FILIAL = %xfilial:RD4% AND
					RD4.RD4_CODIGO = %exp:cVisao% AND
					RD4.RD4_ITEM   = %exp:cTree% AND
					RCX.RCX_SUBST  = '2' AND
					RCX.RCX_TIPOCU = '1' AND
					RD0.%notdel%		 AND
					RDZ.%notdel%		 AND
					SRA.%notdel%		 AND
					RD4.%notDel%         AND
					RCX.%notDel%
					
				EndSql
				
				If (cAlias4)->( !Eof() )
					AAdd(aAprov,{(cAlias4)->RCX_FILFUN,; //Filial do Funcionário
								 (cAlias4)->RCX_MATFUN,; //Matricula do Funcionário
								 (cAlias4)->RA_CODFUNC,; //Código da Função
								 (cAlias4)->RA_SITFOLH,; //Situação da Folha
								 (cAlias4)->RA_EMAIL})   //Email do Funcionário
					lSubst := VrfCadSub(@aAprov,@cFlSubd,@cMtSubd)
					If !lSubst .AND. aAprov[1][4] $ ('AF')
						lRet := VldAusen(aAprov[1][1], aAprov[1][2])
					Else
						lRet := .T.
					EndIf
				EndIf
			
				If lRet
					If (aAprov[1][1] == cFSold .AND. aAprov[1][2] == cMSold)// .OR. ValSolPG(cAlias4,cFSold,cMSold) //Aprovador = Solicitado
						aRet := FsBscLimit(nLimit,cVisao,cTree,"","","N",cNvAprv,cTpSol,cSubGrp,cFilRH3,cNumRH3)
					Else
						DbSelectArea("SRJ")
						SRJ->(DbSetOrder(1))
						If SRJ->(DbSeek(xFilial("SRJ") + aAprov[1][3]))
							If !Empty(SRJ->RJ_XGEREN)
								If Val(SRJ->RJ_XGEREN) >= nNvMax
									If ValidPAE(cFilRH3,cNumRH3, aAprov[1][1] , aAprov[1][2])
										AAdd(aRet, { .T., aAprov[1][1] , aAprov[1][2], "", "Aprovador aprova direto!","","" }) //Aprovar direto
									Else
										AAdd(aRet, { .T., aAprov[1][1] , aAprov[1][2], aAprov[1][5], "", cFlSubd, cMtSubd })
									EndIf
								Else
									If cTpSol == "005" .And. cSubGrp $ "001|002|003"
										AAdd(aRet, { .T., aAprov[1][1] , aAprov[1][2], "", "Aprovador aprova direto!","","" }) //Aprovar direto
										U_F0800201("3",,,cCodAlc,cFilResp,cMatResp,aAprov[1][1],aAprov[1][2],"Aprovação automatica",aAprov[1][5],cNvAprv)
									Else
										If SRJ->RJ_XGEREN == "01" .OR. SRJ->RJ_XGEREN == "02" //RH ou PA
											If ValidPAE(cFilRH3,cNumRH3, aAprov[1][1] , aAprov[1][2])
												AAdd(aRet, { .T., aAprov[1][1] , aAprov[1][2], "", "Aprovador aprova direto!","","" }) //Aprovar direto
											Else
												AAdd(aRet, { .T., aAprov[1][1] , aAprov[1][2], aAprov[1][5], "", cFlSubd, cMtSubd })
											EndIf											
										Else
											AAdd(aRet, { .T., aAprov[1][1] , aAprov[1][2], "", "Aprovador aprova direto!","","" }) //Aprovar direto
											U_F0800201("3",,,cCodAlc,cFilResp,cMatResp,aAprov[1][1],aAprov[1][2],"Aprovação automatica",aAprov[1][5],cNvAprv)
										EndIf
									EndIf
								EndIf
							Else
								AAdd(aRet, { .F., "", "", "", "Não foi definido nível para função " + aAprov[1][3] + "!","","" })
							EndIf
						Else
							AAdd(aRet, { .F., "", "", "", "Não existe o código da função do aprovador " + aAprov[1][1] + " - " + aAprov[1][2] + "!","","" })
						EndIf
					EndIf
				Else
					If lSegVz
						If nLimit > 0
							aRet := FsBscLimit(nLimit,cVisao,cTree,"","","N",cNvAprv,cTpSol,cSubGrp, cFilRH3,cNumRH3)
						Else
							AAdd(aRet, { .F., "", "", "", "Não existe funcionário alocado no item " + cNvAprv + " da alçada e não foi definido limite de nível para continuar!","","" })
						EndIf
					Else
						AAdd(aRet, { .F., "", "", "", "Não existe funcionário alocado no item " + cNvAprv + " da alçada ","","" })
					EndIf
				EndIf
				
				(cAlias4)->(DbCloseArea())
				
			Else
				//Mandar para o RH
				AAdd(aRet, { .T., "", "", "", "Terminou a estrutura da visão!","","" })
			EndIf
		Else
			//Não foi encontrado
			AAdd(aRet, { .F., "", "", "", "No nivel " + cNvAprv + " da alçada, não foi encontrado o superior do item " + cItem + " da visão","","" })
		EndIf
		
	EndIf
	
	If Len(aRet) == 0
		AAdd(aRet, { .F., "", "", "", "Não foi encontrado aprovador para a solicitação - Aprovação por Nível!","","" })
	EndIf
	
	(cAlias2)->(DbCloseArea())
	RestArea(aArea)
	
Return aRet

/*
{Protheus.doc} FsTpPosto()
Busca do aprovador por posto fixo
@Author     Bruno de Oliveira
@Since      13/03/2017
@Version    P12.1.07
@Project    MAN0000007423042_EF_005
@Param		cCodPost, caracter, código do cadastro de filial\posto de aprovação
@Param		cFilSol,  caracter, filial da solicitante
@Param		nNvMac,   numerico, novel máximo do aprovador
@Return		aRet, informações do aprovador
*/
Static Function FsTpPosto(cCodPost,cFilSol,nNvMax,lSegVz,cFSold,cMSold,cNvAprv,cTpSol,cSubGrp,cFilRH3, cNumRH3)
	
	Local aArea := GetArea()
	Local cFilPosto := ""
	Local cCodPosto := ""
	Local cXAlias1 := GetNextAlias()
	Local cEmpIde := cEmpAnt
	Local aRet := {}
	Local nNivel := 0
	Local cRCX := "%" + RetFullName("RCX",cEmpAnt) + "%"
	Local cSRA    := "%" + RetFullName("SRA",cEmpAnt) + "%"
	Local cRDZ	  := "%" + RetFullName("RDZ",cEmpAnt) + "%"
	Local cRD0	  := "%" + RetFullName("RD0",cEmpAnt) + "%"
	Local lRet	  := .F.
	Local cFlSubd := ""
	Local cMtSubd := ""
	Local aAprov  := {}
	Local _aPstFil:= {} //Thais Paiva - DOR05216398 - 3621714
	Local _cQryPF := "" //Thais Paiva - DOR05216398 - 3621714 

	Default cMSold	:= ""
	Default cNvAprv := ""
	Default cFSold	:= ""
	
	Default cFilRH3	:= ""
	Default cNumRH3	:= ""

	If !Empty(cFSold) .AND. !Empty(cMSold)
		cFlSobe := cFSold
	ElseIf !Empty(cFilRH3)
		cFlSobe := cFilRH3	
	Else
		cFlSobe := cFilSol
	EndIf
	
	DbSelectArea("PA9")
	PA9->(DbSetOrder(2)) //PA9_FILIAL + PA9_CODIGO + PA9_FILSOL
	If PA9->(DbSeek(xFilial("PA9") + cCodPost + cFlSobe))
		While PA9->(PA9_FILIAL + PA9_CODIGO + PA9_FILSOL) == xFilial("PA9") + cCodPost + cFlSobe
			/*Início - Thais Paiva - DOR05216398 - 3621714
			If !(EMPTY(cFilPosto))
				cFilPosto += ", '" + ALLTRIM(PA9->PA9_FILAPR) + "'"
			Else
				cFilPosto += "" + ALLTRIM(PA9->PA9_FILAPR) + "'"
			EndIf
			If !(EMPTY(cCodPosto))
				cCodPosto += ", '" + ALLTRIM(PA9->PA9_POSAPR) + "'"
			Else
				cCodPosto += "" + ALLTRIM(PA9->PA9_POSAPR) + "'"
			EndIf*/
			AAdd(_aPstFil,{ALLTRIM(PA9->PA9_FILAPR),; //Filial Aprovador
						   ALLTRIM(PA9->PA9_POSAPR) }) //Posto Aprovador 
			//Fim - Thais Paiva - DOR05216398 - 3621714
			PA9->(DbSkip())
		EndDo
	EndIf
	
	/*Início - Thais Paiva - DOR05216398 - 3621714
	cFilPosto := SubStr(cFilPosto,1,Len(cFilPosto)-1)
	cCodPosto := SubStr(cCodPosto,1,Len(cCodPosto)-1)

	If !Empty(cFilPosto) .And. !Empty(cCodPosto)
		cAlias1 := GetNextAlias()
		BeginSql alias cXAlias1
			
			SELECT RCX.RCX_FILFUN, RCX.RCX_MATFUN, SRA.RA_EMAIL, SRA.RA_CODFUNC, RA_SITFOLH
			FROM %Exp:cRCX% RCX
			INNER JOIN %Exp:cSRA% SRA ON SRA.RA_FILIAL = RCX.RCX_FILFUN AND	SRA.RA_MAT = RCX.RCX_MATFUN
			INNER JOIN %Exp:cRDZ% RDZ ON RDZ.RDZ_CODENT = SRA.RA_FILIAL || SRA.RA_MAT
			INNER JOIN %Exp:cRD0% RD0 ON RD0.RD0_CODIGO = RDZ.RDZ_CODRD0
			WHERE RD0.RD0_FILIAL = %xfilial:RD0% AND
			RDZ.RDZ_EMPENT = %exp:cEmpIde% AND
			RDZ.RDZ_FILIAL = %xfilial:RDZ% AND
			SRA.RA_SITFOLH NOT IN ('D') AND //Melhoria Temporaria ID 945 retirada do ",'F'"
			RCX.RCX_FILIAL  IN (%exp:cFilPosto%) AND
			RCX.RCX_POSTO   IN (%exp:cCodPosto%) AND
			RCX.RCX_SUBST  = '2' AND
			RCX.RCX_TIPOCU = '1' AND
			RD0.%notdel% AND
			RDZ.%notdel% AND
			SRA.%notdel% AND
			RCX.%notDel%
			
		EndSql
		*/
	
	If Len(_aPstFil) > 0 
		
		cXAlias1 := GetNextAlias()
		
		_cQryPF := " SELECT RCX.RCX_FILFUN, RCX.RCX_MATFUN, SRA.RA_EMAIL, SRA.RA_CODFUNC, RA_SITFOLH "
		_cQryPF += " FROM  "+ RetSqlName("RCX") +"  RCX"
		_cQryPF += " INNER JOIN "+ RetSqlName("SRA") +"  SRA ON SRA.RA_FILIAL = RCX.RCX_FILFUN AND	SRA.RA_MAT = RCX.RCX_MATFUN "
		_cQryPF += " INNER JOIN "+ RetSqlName("RDZ") +" RDZ ON RDZ.RDZ_CODENT = SRA.RA_FILIAL || SRA.RA_MAT "
		_cQryPF += " INNER JOIN "+ RetSqlName("RD0") +" RD0 ON RD0.RD0_CODIGO = RDZ.RDZ_CODRD0 "
		_cQryPF += " WHERE RD0.RD0_FILIAL = '"+xFilial("RD0")+"' AND "
		_cQryPF += " RDZ.RDZ_EMPENT = '"+cEmpIde+"' AND "
		_cQryPF += " RDZ.RDZ_EMPENT = '"+cEmpIde+"' AND "
		_cQryPF += " RDZ.RDZ_FILIAL = '"+xFilial("RDZ")+"' AND "
		_cQryPF += " SRA.RA_SITFOLH NOT IN ('D') AND ( " 
		For _nP := 1 To Len(_aPstFil)
			
			If _nP == 1
				_cQryPF += " (RCX.RCX_FILIAL = '" +_aPstFil[_nP][1] + "' AND "
				_cQryPF += "  RCX.RCX_POSTO = '" +_aPstFil[_nP][2] + "' ) "
			Else
				_cQryPF += " OR (RCX.RCX_FILIAL = '" + _aPstFil[_nP][1] + "' AND "
				_cQryPF += " RCX.RCX_POSTO = '" +_aPstFil[_nP][2] + "' ) "
			EndIf
				
		Next _nP
		_cQryPF += " ) AND "
		_cQryPF += " RCX.RCX_SUBST  = '2' AND "
		_cQryPF += " RCX.RCX_TIPOCU = '1' AND "
		_cQryPF += " RD0.D_E_L_E_T_ = ' ' AND "
		_cQryPF += " RDZ.D_E_L_E_T_ = ' ' AND "
		_cQryPF += " SRA.D_E_L_E_T_ = ' ' AND "
		_cQryPF += " RCX.D_E_L_E_T_ = ' ' "
		 
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQryPF),cXAlias1)
		
		//Fim - Thais Paiva - DOR05216398 -  - 3621714
		
		If (cXAlias1)->(!EOF())
			While (cXAlias1)->(!EOF()) .And. !lRet
				aAprov := aClone({})
				AAdd(aAprov,{(cXAlias1)->RCX_FILFUN,; //Filial do Funcionário
							 (cXAlias1)->RCX_MATFUN,; //Matricula do Funcionário
							 "",; 					  //Código da Função
							 (cXAlias1)->RA_SITFOLH,; //Situação da Folha
							 (cXAlias1)->RA_EMAIL})   //Email do Funcionário
				lSubst := VrfCadSub(@aAprov,@cFlSubd,@cMtSubd)
				If !lSubst .AND. aAprov[1][4] $ ('AF')
					lRet := VldAusen(aAprov[1][1], aAprov[1][2])
				Else
					lRet := .T.
				EndIf
				
				(cXAlias1)->(DbSkip())
			EndDo
		EndIf
		
		If lRet
			If (aAprov[1][1] == cFSold .AND. aAprov[1][2] == cMSold) //.Or. ValSolPG(cXAlias1,cFSold,cMSold)//Se for a matricula igual ao solicitado ele busca o superior dele isso se for desligamento
				aRet := FsBscLimit(nLimit,cVisao,"",cFilPosto,cCodPosto,"P",cNvAprv,cTpSol,cSubGrp, cFilRH3,cNumRH3)
			Else
				If ValidPAE(cFilRH3,cNumRH3, aAprov[1][1] , aAprov[1][2])
					AAdd(aRet, { .T., aAprov[1][1] , aAprov[1][2], "", "Aprovador aprova direto!","","" }) //Aprovar direto
				Else
					AAdd(aRet, { .T., aAprov[1][1] , aAprov[1][2], aAprov[1][5], "", cFlSubd,cMtSubd })
				EndIf			
			EndIf
		Else
			If lSegVz
				If nLimit > 0
//					aRet := FsBscLimit(nLimit,cVisao,"",cFilPosto,cCodPosto,"P",cNvAprv,cTpSol,cSubGrp, cFilRH3,cNumRH3)
				
					For _nP := 1 To Len(_aPstFil)
						aRet := FsBscLimit(nLimit,cVisao,"",_aPstFil[_nP][1],_aPstFil[_nP][2],"P",cNvAprv,cTpSol,cSubGrp, cFilRH3,cNumRH3)
					Next _nP
					
				Else
					AAdd(aRet, { .F., "", "", "", "Não existe funcionário alocado no item " + cNvAprv + " e não foi definido limite de nível para continuar!","","" })
				EndIf
			Else
				AAdd(aRet, { .F., "", "", "", "Não existe funcionário alocado no item " + cNvAprv + " da alçada!","","" })
			EndIf
		EndIf
		
		(cXAlias1)->(DbCloseArea())
	Else
		AAdd(aRet, { .F., "", "", "", "Não existe posto fixo de aprovação para a filial do solicitante!","","" })
	EndIf
	
	If Len(aRet) == 0
		AAdd(aRet, { .F., "", "", "", "Não encontrado Filial e Posto de aprovação!","","" })
	EndIf
	
	RestArea(aArea)
	
Return aRet

/*
{Protheus.doc} FsIncSolic()
Verifica se todos os itens da alçada tem aprovador no momento da inclusão da solicitação
@Author     Bruno de Oliveira
@Since      13/03/2017
@Version    P12.1.07
@Project    MAN0000007423042_EF_005
@Param		lSegVz,  logico, se está passando pela segunda vez .T. = sim ou .F. = não
@Param		cTpSol,  caracter, tipo de solicitação
@Param		cSubGrp, caracter, subgrupo do tipo de solicitação
@Param		cFilResp,caracter, filial do solicitante
@Param		cMatResp,caracter, matricula do solicitante
@Param		cFSold,  caracter, filial do solicitado
@Param		cMSold,  caracter, matricula do solicitado
@Return		aRet, informações do aprovador
*/
Static Function FsIncSolic(lSegVz,cTpSol,cSubGrp,cFilResp,cMatResp,cFSold,cMSold,cFilRH3,cNumRH3,aEmail,lPortal, cFilVga, cMatVga,cNovSol)
					
	Local aRet := {}
	Local lRet := .T.
	Local aDdSolic	:= {}
	Local cCodAlc	:= ""
	Local cDataAl	:= ""
	Local cObsLog := ""
	Local cSolicit:= ""
	Local cAlias1 := "BscInf"
	Local lSoNotif	:= .T.
	Local cMatUsrLog:= cMatResp
	Local cFilUsrLog:= cFilResp
	Local nNivel	:= 0
	Local nNvMin	:= 0
	If !lPortal
		aDdSolic	:= PswRet()
		///cMatUsrLog 	:= Substring(aDdSolic[1][22],len(cEmpAnt) + len(cFilAnt) + 1,12)
		cMatUsrLog 	:= Substring(aDdSolic[1][22], (Len(aDdSolic[1,22])-6) + 1,12)
		cFilUsrLog	:= Substring(aDdSolic[1][22], len(cEmpAnt) + 1,len(cFilAnt))
	EndIf
	
	Default aEmail	:= {}
	
	DbSelectArea("SRA")
	SRA->(DbSetOrder(1))
	If SRA->(DbSeek(cFilUsrLog + cMatUsrLog))
		cFuncao := SRA->RA_CODFUNC
		DbSelectArea("SRJ")
		SRJ->(DbSetOrder(1))
		If SRJ->(DbSeek(xFilial("SRJ") + cFuncao))
			nNivel := Val(SRJ->RJ_XGEREN)
		EndIf
	EndIf
	
	cQuery := "SELECT PAB_CODIGO, PAB_DTVLD "
	cQuery += "FROM	" + RetSqlName("PAB") + " "
	cQuery += "WHERE PAB_TPSOLI = '" + cTpSol + "' AND PAB_GRPSOL = '" + cSubGrp + "' AND PAB_DTVLD >= '" + dtos(date()) + "' AND "
	cQuery += "D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY PAB_DTVLD"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1)
	If (cAlias1)->(!EOF())
		cCodAlc := (cAlias1)->(PAB_CODIGO)
	EndIf
	(cAlias1)->(DbCloseArea())
	
	DbSelectArea("PAB")
	PAB->(DbSetOrder(1))
	If !Empty(cCodAlc) .And. PAB->(DbSeek(xFilial("PAB") + cCodAlc))
		nNvMin := VAL(PAB->PAB_NIVMIN)
		cVisao := PAB->PAB_VISAO
		nNvMax := VAL(PAB->PAB_APRMAX)
		cCodAlc := PAB->PAB_CODIGO
		nLimit := PAB->PAB_LIMNIV
		nTotLim := PAB->PAB_LIMNIV
		cSolicit := PAB->PAB_TPSOL
	Else
		lRet := .F.
		cMsg := "não foi encontrada nenhuma alçada cadastrada para esse Tipo e subgrupo de solicitação"
		AAdd(aRet,{.F.,"","","","","","",cMsg})
	EndIf
	
	If lRet .And. PAB->PAB_NECAPV == '2'
		aAdd(aRet,{ .T.,;				//Encontrou o aprovador?
		            "",; 				//Filial Aprovador
		            "",;				//Código Aprovador
		            "FM",;				//Nível do Aprovador
		            "FM",; 				//Próximo Nível
		            cCodAlc,;			//Código da Alçada
		            "",;				//E-mail do aprovador
		            "aprova direto!",;  //Mensagem de retorno
		            "",;				//Filial do Substituido
		            ""})				//Matricula do Substituido	
		Return aRet
	EndIf
	
	If lRet
		If nNivel <= nNvMin
			
			If lSegVz
				If cTpSol <> "002" .AND. cTpSol <> "003" .AND. cTpSol <> "004" .And. !VerUsPA(cFilUsrLog, cMatUsrLog, cTpSol, cSubGrp)
					lRet := U_F0800801(cFilResp,cMatResp,cFSold,cMSold,cSolicit,cVisao)
					If !lRet
						cMsg := "O usuário solicitado não está na hierarquia do solicitante ou não é o inferior imediato"
						AAdd(aRet,{.F.,"","","","","","",cMsg})
					EndIf
				EndIf
			EndIf
			
			If lRet
				//Em caso de FAP, usar os dados da Vaga.
				If cTpSol == "004"
					cFilResp	:=	cFilVga
					cMatResp	:=	cMatVga
				EndIf
				
				DbSelectArea("PAC")
				PAC->(DbSetOrder(1))
				If PAC->(DbSeek(xFilial("PAC") + cCodAlc))
					
					While PAC->(!EOF()) .AND. PAC->(PAC_FILIAL + PAC_CODALC)== xFilial("PAC") + cCodAlc
						If PAC->PAC_APRNOT == "1"
							lSoNotif := .F.
						EndIf
							
						If PAC->PAC_TIPAPR == "1" //Tipo de aprovação por nível
							
							If PAC->PAC_NUMNIV > 0
								//FAP será pelo responsável da vaga
								aResult := FsTpNivel(cVisao,cFilResp,cMatResp,PAC->PAC_NUMNIV,nNvMax,nLimit,.T.,cFSold,cMSold,cCodAlc,PAC->PAC_NIVEL,cTpSol,cSubGrp,cFilRH3,cNumRH3,cNovSol)
								
								AAdd(aRet,{aResult[1][1],;			//Encontrou o aprovador?
								aResult[1][2],; 		//Filial Aprovador
								aResult[1][3],;			//Código Aprovador
								PAC->PAC_NIVEL,;		//Nível do Aprovador
								"",; 				//Próximo Nível
								cCodAlc,;				//Código da Alçada
								aResult[1][4],;			//E-mail do aprovador
								aResult[1][5],;			//Mensagem de retorno
								aResult[1][6],;			//Filial do Substituido
								aResult[1][7]})			//Matricula do Substituido
								
							Else
								AAdd(aRet,{.F.,"","","","","","","Nível cadastrado na alçada precisa ser maior que zero"})
							EndIf
							
							
						ElseIf PAC->PAC_TIPAPR == "2" .AND. PAC->PAC_VINCL != "1" //Tipo de aprovação por Posto Fixo sem vinculo
							
							aResult := FsTpPosto(PAC->PAC_CODPOS,cFilResp,nNvMax,.T.,cFSold,cMSold,PAC->PAC_NIVEL,cTpSol,cSubGrp,cFilRH3, cNumRH3)
							
							AAdd(aRet,{aResult[1][1],; 		//Encontrou o aprovador?
							aResult[1][2],; 		//Filial Aprovador
							aResult[1][3],; 		//Código Aprovador
							PAC->PAC_NIVEL,; 	//Nível do Aprovador
							"",; 				//Próximo Nível
							cCodAlc,; 			//Código da Alçada
							aResult[1][4],; 		//E-mail do aprovador
							aResult[1][5],;			//Mensagem de retorno
							aResult[1][6],;			//Filial do Substituido
							aResult[1][7]})			//Matricula do Substituido
							
						ElseIf PAC->PAC_TIPAPR == "2" .AND. PAC->PAC_VINCL == "1" //Tipo de aprovação por Posto Fixo com vinculo
							If cTpSol <> "002" .AND. cTpSol <> "003" .AND. cTpSol <> "004"
								aResult := FsTpPosto(PAC->PAC_CODPOS,cFSold,nNvMax,.T.,,,,cTpSol,cSubGrp,cFilRH3, cNumRH3)
							Else
								aResult := FsTpPosto(PAC->PAC_CODPOS,cFilResp,nNvMax,.T.,,,,cTpSol,cSubGrp,cFilRH3, cNumRH3)
							EndIf

							AAdd(aRet,{aResult[1][1],; 		//Encontrou o aprovador?
							aResult[1][2],; 		//Filial Aprovador
							aResult[1][3],; 		//Código Aprovador
							PAC->PAC_NIVEL,; 	//Nível do Aprovador
							"",; 				//Próximo Nível
							cCodAlc,; 			//Código da Alçada
							aResult[1][4],; 		//E-mail do aprovador
							aResult[1][5],; 		//Mensagem de retorno
							aResult[1][6],;			//Filial do Substituido
							aResult[1][7]})			//Matricula do Substituido
						EndIf
						
						If lSegVz
							If aResult[1][1] //Encontrou aprovador
								If PAC->PAC_APRNOT == "2" //Notificador
									DbSelectArea("SRA")
									SRA->(DbSetOrder(1))
									SRA->(DbSeek(aResult[1][2] + aResult[1][3]))
									DbSelectArea("PAB")
									PAB->(DbSetOrder(1))
									PAB->(DbSeek(xFilial("PAB") + cCodAlc))
									cObsLog := "Aprovador Notificado."
									//U_F0800901("3",SRA->RA_EMAIL,cFilRH3,cNumRH3,SRA->RA_NOME,PAB->PAB_TPSOLI,PAB->PAB_GRPSOL,aResult[1][4],cObsLog)
									AAdd(aEmail,SRA->RA_EMAIL)
								Else
									//Se aprovar direto devido aprovador ter um nivel maior
									If aResult[1][5] != "Aprovador aprova direto!"
										If !Empty(aResult[1][2]) .AND. !Empty(aResult[1][3])
											If !((aResult[1][2] == cFilResp) .AND. (aResult[1][3] == cMatResp )) //solicitante não é o aprovador
												Exit
											Endif
										EndIf
									EndIf
								EndIf
							Else
								Exit
							EndIf
						EndIf
						
						PAC->(DbSkip())
						If lSegVz
							aRet := {}
						EndIf
					End
					
				EndIf
				
			EndIf
		Else
			lRet := .F.
			cMsg := "Solicitante não tem permissão para incluir essa solicitação, pois não tem cargo mínimo exigido"
			AAdd(aRet,{.F.,"","","","","","",cMsg})
		EndIf
	EndIf
	
	If lRet
		If lSoNotif .And. Len(aRet) > 0
			aRet[1][5] := "FM"
		EndIf
	EndIf
	
Return aRet

/*
{Protheus.doc} FsBscLimit()
Busca do Limite de Nível
@Author     Bruno de Oliveira
@Since      13/03/2017
@Version    P12.1.07
@Project    MAN0000007423042_EF_005
@Param		nLimit, numerico, Limite de dias
@Param		cVisao, caracter, código da visão
@Param		cTree,  caracter, item do posto do aprovador
@Param		cFlPost,caracter, filial do posto
@Param		cCdPost,caracter, código do posto
@Param		cTpAprv,caracter, tipo de aprovador
@Return		aRet, informações do aprovador
*/
Static Function FsBscLimit(nLimit,cVisao,cTree,cFlPost,cCdPost,cTpAprv,cNvAprv,cTpSol,cSubGrp, cFilRH3,cNumRH3)
	
	Local nI      := 1
	Local aRet    := {}
	Local cEmpIde := cEmpAnt
	Local cAlias1 := GetNextAlias()
	Local cAlias2 := GetNextAlias()
	Local cAlias3 := GetNextAlias()
	Local cRD4    := "%" + RetFullName("RD4",cEmpAnt) + "%"
	Local cRCX    := "%" + RetFullName("RCX",cEmpAnt) + "%"
	Local cSRA    := "%" + RetFullName("SRA",cEmpAnt) + "%"
	Local cRDZ	  := "%" + RetFullName("RDZ",cEmpAnt) + "%"
	Local cRD0	  := "%" + RetFullName("RD0",cEmpAnt) + "%"
	Local lRet	  := .F.
	Local aAprov  := {}
	Local cFlSubd := ""
	Local cMtSubd := ""
		
	If cTpAprv == "N"
		cAlias1 := GetNextAlias()
		BeginSql alias cAlias1
			
			SELECT RD4.RD4_CHAVE, RD4.RD4_EMPIDE, RD4.RD4_TREE, RD4.RD4_CODIDE, RD4.RD4_ITEM
			FROM %Exp:cRD4% RD4
			WHERE RD4.RD4_FILIAL = %xfilial:RD4% AND
			RD4.RD4_CODIGO = %exp:cVisao%  AND
			RD4.RD4_ITEM   = %exp:cTree%   AND
			RD4.%notDel%
			
		EndSql
		
	ElseIf cTpAprv == "P"
		cAlias1 := GetNextAlias()
		BeginSql alias cAlias1
			
			SELECT RD4.RD4_CHAVE, RD4.RD4_EMPIDE, RD4.RD4_TREE, RD4.RD4_CODIDE, RD4.RD4_ITEM
			FROM %Exp:cRD4% RD4
			WHERE RD4.RD4_FILIAL = %xfilial:RD4% AND
			RD4.RD4_FILIDE IN (%exp:cFlPost%)  AND
			RD4.RD4_CODIGO = %exp:cVisao%  AND
			RD4.RD4_CODIDE IN (%exp:cCdPost%)   AND
			RD4.%notDel%
			
		EndSql
		
	EndIf
	
	If (cAlias1)->(!EOF())
		
		If cTpAprv == "N"
			cTree := (cAlias1)->(RD4_ITEM)
		ElseIf cTpAprv == "P"
			cTree := (cAlias1)->(RD4_TREE)
		EndIf
		
		While nI <= nLimit
			aAprov  := {}
			cFlSubd := ""
			cMtSubd := ""
			cAlias2 := GetNextAlias()
			BeginSql alias cAlias2
				
				SELECT RCX.RCX_FILFUN, RCX.RCX_MATFUN, SRA.RA_EMAIL, SRA.RA_CODFUNC, SRA.RA_EMAIL, SRA.RA_SITFOLH
				FROM %Exp:cRCX% RCX
				INNER JOIN %table:RD4% RD4 ON RD4.RD4_CODIDE = RCX.RCX_POSTO AND RCX.RCX_FILIAL = RD4.RD4_FILIDE
				INNER JOIN %Exp:cSRA% SRA ON SRA.RA_FILIAL = RCX.RCX_FILFUN AND	SRA.RA_MAT = RCX.RCX_MATFUN
				INNER JOIN %Exp:cRDZ% RDZ ON RDZ.RDZ_CODENT = SRA.RA_FILIAL || SRA.RA_MAT
				INNER JOIN %Exp:cRD0% RD0 ON RD0.RD0_CODIGO = RDZ.RDZ_CODRD0
				WHERE RD0.RD0_FILIAL = %xfilial:RD0% AND
				RDZ.RDZ_EMPENT = %exp:cEmpIde% AND
				RDZ.RDZ_FILIAL = %xfilial:RDZ% AND
				SRA.RA_SITFOLH NOT IN ('D') AND
				RD4.RD4_FILIAL = %xfilial:RD4% AND
				RD4.RD4_CODIGO = %exp:cVisao% AND
				RD4.RD4_ITEM   = %exp:cTree% AND
				RCX.RCX_SUBST  = '2' AND
				RCX.RCX_TIPOCU = '1' AND
				RD0.%notdel%		 AND
				RDZ.%notdel%		 AND
				SRA.%notdel%		 AND
				RD4.%notDel%         AND
				RCX.%notDel%
				
			EndSql

			If (cAlias2)->(!EOF())
				AAdd(aAprov,{(cAlias2)->RCX_FILFUN,; //Filial do Funcionário
						 	 (cAlias2)->RCX_MATFUN,; //Matricula do Funcionário
						     (cAlias2)->RA_CODFUNC,; //Código da Função
						     (cAlias2)->RA_SITFOLH,; //Situação da Folha
						     (cAlias2)->RA_EMAIL})   //Email do Funcionário
				lSubst := VrfCadSub(@aAprov,@cFlSubd,@cMtSubd)
				If !lSubst .AND. aAprov[1][4] $ ('AF')
					lRet := VldAusen(aAprov[1][1], aAprov[1][2])
				Else
					lRet := .T.
				EndIf
			EndIf
			
			If lRet
				If ValidPAE(cFilRH3,cNumRH3, aAprov[1][1] , aAprov[1][2])
					AAdd(aRet, { .T., aAprov[1][1] , aAprov[1][2], "", "Aprovador aprova direto!","","" }) //Aprovar direto
				Else
					DbSelectArea("SRJ")
					SRJ->(DbSetOrder(1))
					If SRJ->(DbSeek(xFilial("SRJ") + aAprov[1][3]))
						If VAL(SRJ->RJ_XGEREN) >= nNvMax
							AAdd(aRet, { .T., aAprov[1][1] , aAprov[1][2], aAprov[1][5], "", cFlSubd, cMtSubd })
						Else
							If cTpSol == "005" .And. cSubGrp $ "001|002|003"
								AAdd(aRet,{ .F., "", "", "", "No item " + cNvAprv + " da alçada não foi encontrado funcionario alocado! Ao buscar no limite de nível o aprovador encontrado ("+(cAlias2)->RCX_FILFUN+"-"+(cAlias2)->RCX_MATFUN+") tem nível maior que o nível máximo da alçada, será cancelado solicitação!","","" })
							Else
								If SRJ->RJ_XGEREN == "01" .OR. SRJ->RJ_XGEREN == "02" //RH ou PA
									AAdd(aRet,{ .T., aAprov[1][1] , aAprov[1][2], aAprov[1][5], "", cFlSubd, cMtSubd })
								Else
									AAdd(aRet,{ .F., "", "", "", "No item " + cNvAprv + " da alçada não foi encontrado funcionario alocado! Ao buscar no limite de nível o aprovador encontrado ("+(cAlias2)->RCX_FILFUN+"-"+(cAlias2)->RCX_MATFUN+") tem nível maior que o nível máximo da alçada, será cancelado solicitação!","","" })
								EndIf
							EndIf
						EndIf
					EndIf
					
					(cAlias2)->(DbCloseArea())
					Exit
				EndIf
			Else
				If nLimit > 1
					
					BeginSql alias cAlias3
			
						SELECT RD4.RD4_CHAVE, RD4.RD4_EMPIDE, RD4.RD4_TREE, RD4.RD4_CODIDE, RD4.RD4_ITEM
						FROM %Exp:cRD4% RD4
						WHERE RD4.RD4_FILIAL = %xfilial:RD4% AND
						RD4.RD4_CODIGO = %exp:cVisao%  AND
						RD4.RD4_ITEM   = %exp:cTree%   AND
						RD4.%notDel%
						
					EndSql
					
					If (cAlias3)->(!EOF())
						cTree := (cAlias3)->(RD4_TREE)
					EndIf
					
					(cAlias3)->(DbCloseArea())
					cAlias3 := GetNextAlias()
				EndIf
			EndIf
			
			(cAlias2)->(DbCloseArea())
			cAlias2 := GetNextAlias()
			
			nI := nI + 1
		End
		
	EndIf
	
	If Len(aRet) == 0
		AAdd(aRet,{ .F., "", "", "", "Não existe(m) funcionário(s) alocado(s) na busco dos limites de níveis da alçada!","","" })
	EndIf
	
	(cAlias1)->(DbCloseArea())
Return aRet

////////////////////////////////////////
// Valida Aprovador Posto Genérico /////
////////////////////////////////////////

Static Function ValSolPG(cAliasExp,cFSold,cMSold)
	Local lRet := .F.
	(cAliasExp)->(DbGoTop())
	While (cAliasExp)->(!EOF())
		If ((cAliasExp)->RCX_FILFUN == cFSold .AND. (cAliasExp)->RCX_MATFUN == cMSold)
			lRet := .T.
			Exit
		Endif
		(cAliasExp)->(DbSkip())
	EndDo
	(cAliasExp)->(DbGoTop())
Return lRet


////////////////////////////////////////
// Valida Se o usuário é um PA     /////
////////////////////////////////////////
Static Function VerUsPA(cFilMat, cMat, cTpSol, cSubGrp)
	Local aAreaSRA	:= SRA->(GetArea())
	Local aAreaSRJ	:= SRJ->(GetArea())
	Local lRet		:= .F.
	
	If cTpSol == "005" .And. cSubGrp $ "001|002|003"
		If SRA->(DbSeek(cFilMat + cMat))
			If  SRJ->(DbSeek(xFilial("SRJ")+SRA->RA_CODFUNC))
				If AllTrim(SRJ->RJ_XGEREN) == "02"
					lRet := .T.
				EndIf
			EndIf
		EndIf
	EndIf
	
	RestArea(aAreaSRA)
	RestArea(aAreaSRJ)

Return lRet


/*{Protheus.doc} FsLsPosto
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 24/10/2017
@version 6
@param cCodPost, characters, descricao
@param cFilSol, characters, descricao
@param nNvMax, numeric, descricao
@param lSegVz, logical, descricao
@param cFSold, characters, descricao
@param cMSold, characters, descricao
@param cNvAprv, characters, descricao
@type function
*/
Static Function FsLsPosto(cCodList,cCodPost,cFilSol,nNvMax,lSegVz,cFSold,cMSold,cNvAprv,cTpSol,cSubGrp)

	Local aArea     := GetArea()
	Local cFilPosto := ""
	Local cCodPosto := ""
	Local cQuery    := ""
	Local cAliasTmp := "AliasTmp"
	Local cAliasAux := GetNextAlias()
	Local cEmpIde   := cEmpAnt
	Local aRet      := {}
	Local nNivel    := 0
	Local lRet	  := .F.

	Default cMSold	:= ""
	Default cNvAprv := ""
	Default cFSold	:= ""

	//Fazer query para trazer todos os postos da listagem

	cQuery := "SELECT PAH.PAH_FILPOS, PAH.PAH_POSTO "
	cQuery += "FROM " + RETSQLNAME('PAH') + " PAH "
	cQuery += "WHERE PAH.D_E_L_E_T_ = ' ' "
	cQuery += "AND PAH.PAH_FILIAL = '" + XFILIAL("PAH") +"' "
	cQuery += "AND PAH.PAH_CODIGO = '" + cCodList + "' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp)

	While (cAliasTmp)->(!(EOF()))
		If !(EMPTY(cFilPosto))
			cFilPosto += ", '" + ALLTRIM((cAliasTmp)->PAH_FILPOS) + "'"
		Else
			cFilPosto += "'" + ALLTRIM((cAliasTmp)->PAH_FILPOS) + "'"
		EndIf
		If !(EMPTY(cCodPosto))
			cCodPosto += ", '" + ALLTRIM((cAliasTmp)->PAH_POSTO) + "'"
		Else
			cCodPosto += "'" + ALLTRIM((cAliasTmp)->PAH_POSTO) + "'"
		EndIf

		(cAliasTmp)->(dbSkip())
	End
	(cAliasTmp)->(DbCloseArea())


	If !Empty(cFilPosto) .And. !Empty(cCodPosto)
		cAliasAux := GetNextAlias()

		cQuery := " SELECT RCX.RCX_FILFUN, RCX.RCX_MATFUN, SRA.RA_EMAIL, SRA.RA_CODFUNC, RA_SITFOLH "
		cQuery += " FROM " + RETSQLNAME('RCX') + " RCX "
		cQuery += " INNER JOIN " + RETSQLNAME('SRA') + " SRA ON SRA.RA_FILIAL = RCX.RCX_FILFUN AND	SRA.RA_MAT = RCX.RCX_MATFUN "
		cQuery += " INNER JOIN " + RETSQLNAME('RDZ') + " RDZ ON RDZ.RDZ_CODENT = SRA.RA_FILIAL || SRA.RA_MAT "
		cQuery += " INNER JOIN " + RETSQLNAME('RD0') + " RD0 ON RD0.RD0_CODIGO = RDZ.RDZ_CODRD0 "
		cQuery += " WHERE RD0.RD0_FILIAL = '" + xfilial("RD0") + "' AND "
		cQuery += " RDZ.RDZ_EMPENT = '" + cEmpIde + "' AND "
		cQuery += " RDZ.RDZ_FILIAL = '" + xfilial("RDZ") + "' AND "
		cQuery += " SRA.RA_SITFOLH NOT IN ('D') AND " 
		cQuery += " RCX.RCX_FILIAL IN ( " + cFilPosto + " ) AND "
		cQuery += " RCX.RCX_POSTO  IN ( " + cCodPosto + " ) AND "
		cQuery += " RCX.RCX_SUBST  = '2' AND "
		cQuery += " RCX.RCX_TIPOCU = '1' AND "
		cQuery += " RD0.D_E_L_E_T_ = ' ' AND "
		cQuery += " RDZ.D_E_L_E_T_ = ' ' AND "
		cQuery += " SRA.D_E_L_E_T_ = ' ' AND "
		cQuery += " RCX.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAux)
			
		If (cAliasAux)->(!EOF())
			If (cAliasAux)->RA_SITFOLH $ ('AF')
				lRet := VldAusen((cAliasAux)->RCX_FILFUN, (cAliasAux)->RCX_MATFUN)
			Else
				lRet := .T.
			EndIf
		EndIf
		
		If lRet
			If ((cAliasAux)->RCX_FILFUN == cFSold .AND. (cAliasAux)->RCX_MATFUN == cMSold) //.Or. ValSolPG(cXAlias1,cFSold,cMSold)//Se for a matricula igual ao solicitado ele busca o superior dele isso se for desligamento
				aRet := FsBscLimit(nLimit,cVisao,"",cFilPosto,cCodPosto,"P",cNvAprv)
			Else
				AAdd(aRet, { .T., (cAliasAux)->RCX_FILFUN , (cAliasAux)->RCX_MATFUN, (cAliasAux)->RA_EMAIL, "", "", "" })
			EndIf
		Else
			If lSegVz
				If nLimit > 0
					aRet := FsBscLimit(nLimit,cVisao,"",cFilPosto,cCodPosto,"P",cNvAprv)
				Else
					AAdd(aRet, { .F., "", "", "", "Não existe funcionário alocado dentro da listagem de postos no item da alçada " + cNvAprv + " e não foi definido limite de nível para continuar!", "", "" })
				EndIf
			Else
				AAdd(aRet, { .F., "", "", "", "Não existe funcionário alocado dentro da listagem de postos no item da alçada " + cNvAprv + " !", "", "" })
			EndIf
		EndIf

		(cAliasAux)->(DbCloseArea())
	Else
		AAdd(aRet, { .F., "", "", "", "Não existe posto de aprovação!", "", "" })
	EndIf

	If Len(aRet) == 0
		AAdd(aRet, { .F., "", "", "", "Não encontrado Filial e Posto de aprovação!", "", "" })
	EndIf

	RestArea(aArea)

Return aRet

////////////////////////////////////
// Valida ausencia do funcionário //
////////////////////////////////////
Static Function VldAusen(cFilUsr, cMatUsr)
	Local aArea	    := GetArea()
	Local cAliasSR8	:= GetNextAlias()
	Local cCodPA5   := ""
	Local cFilPA5	:= ""
	Local cQuery	:= ""
	Local lRet		:= .T.
	
	cQuery	+= " SELECT R8_DATAFIM"
	cQuery	+= " FROM "+ RetSqlName("SR8") + " SR8 " //tickket n° 9173385 - Ajuste query para aprovador substitut
	cQuery	+= " WHERE "
	cQuery	+= " R8_FILIAL	= '"+ cFilUsr +"'"
	cQuery	+= " AND R8_MAT = '"+ cMatUsr +"'"
	cQuery  += " AND D_E_L_E_T_ = ' ' "
	cQuery	+= " ORDER BY R_E_C_N_O_ DESC"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSR8,.T.,.T.)
	
	If (cAliasSR8)->(!EOF())
		If (Empty((cAliasSR8)->R8_DATAFIM)) .Or. ((!Empty((cAliasSR8)->R8_DATAFIM) .And. STOD((cAliasSR8)->R8_DATAFIM) >= Date()))
			lRet := .F.
		EndIf
	EndIf
	
	RestArea(aArea)
	(cAliasSR8)->(DbCloseArea())
Return lRet

//////////////////////////////////////////
// Valida se funcionário tem substituto //
//////////////////////////////////////////
Static Function VrfCadSub(aAprov,cFlSubd,cMtSubd)

	Local lRet := .T.
	Local cQuery := ""
	Local dDtHj := dDatabase
	Local cAlias1 := GetNextAlias()
	
	cFlSubd := aAprov[1][1]
	cMtSubd := aAprov[1][2]
	
	cQuery 	+= " SELECT PAJ.PAJ_CODIGO, PAJ.PAJ_FILFUN, PAJ.PAJ_MATFUN, SRA.RA_CODFUNC, SRA.RA_SITFOLH, SRA.RA_EMAIL "
	cQuery 	+= " FROM " + RetSqlName("PAJ") + " PAJ "
	cQuery  += " INNER JOIN " + RetSqlName("SRA") + " SRA "
	cQuery  += " ON (SRA.RA_FILIAL = PAJ.PAJ_FILFUN AND SRA.RA_MAT = PAJ.PAJ_MATFUN AND"
	cQuery  += " SRA.D_E_L_E_T_ = ' ' )"
	cQuery 	+= " WHERE "
	cQuery 	+= " PAJ.PAJ_FILSUB = '" + aAprov[1][1] + "' AND"
	cQuery  += " PAJ.PAJ_MATSUB = '" + aAprov[1][2] + "' AND"
	cQuery  += " PAJ.PAJ_DTINI <= '" + DTOS(dDtHj) + "' AND"
	cQuery  += " (PAJ.PAJ_DTFIM >= '" + DTOS(dDtHj) + "' OR PAJ.PAJ_DTFIM = '        ') AND" 
	cQuery  += " PAJ.PAJ_STATUS = '2' "
	cQuery 	+= " AND PAJ.D_E_L_E_T_	= ' '"
			
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1,.T.,.T.)

	If (cAlias1)->(!EOF())
	
		aAprov[1][1] := (cAlias1)->PAJ_FILFUN
		aAprov[1][2] := (cAlias1)->PAJ_MATFUN
		aAprov[1][3] := (cAlias1)->RA_CODFUNC
		aAprov[1][4] := (cAlias1)->RA_SITFOLH
		aAprov[1][5] := (cAlias1)->RA_EMAIL
	
		If (cAlias1)->RA_SITFOLH $ ('AF')
			lRet := .F.
		Else
			lRet := .T.
		EndIf
		
	Else
		cFlSubd := ""
		cMtSubd := ""
		lRet := .F.
	EndIf

Return lRet

////////////////////////////////////////////////////
//Valida se o usuário pertence a um posto que já  //
//aprovou a solicitação                           //
////////////////////////////////////////////////////

Static Function ValidPAE(cFilSol, cCodSol, cFilApr, cMatApr)
	Local lRet := .F.
	Local aAreaPAL	:=	PAE->(GetArea())
	Local cQuery	:= ""
	Local cAliasPAL := GetNextAlias()
	Local aAprov	:= {}
	Local cFilPUsr	:= ""
	Local cPostUsr	:= ""
	Local cFilPAux	:= ""
	Local cPostAux	:= ""		
	
	If !Empty(cFilSol) .And. !Empty(cCodSol)

		cQuery 	:= " SELECT PAL_FILIAL "
		cQuery 	+= " FROM " + RetSqlName("PAL") + " PAL "
		cQuery 	+= " WHERE "
		cQuery  += " PAL_FILSOL = '" + cFilSol + "' AND"
		cQuery  += " PAL_NUMSOL = '" + cCodSol + "' AND"
		cQuery  += " PAL_MATAPR = '" + cMatApr + "' AND"		
		cQuery 	+= " PAL.D_E_L_E_T_	= ' '"
				
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasPAL,.T.,.T.)

		If !(cAliasPAL) ->(EOF())
			lRet := .T.	
		EndIf

		(cAliasPAL) -> (DbCloseArea())
	
	EndIf
	
	RestArea(aAreaPAL)
Return lRet
