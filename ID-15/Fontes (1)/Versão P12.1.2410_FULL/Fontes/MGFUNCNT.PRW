#Include 'Protheus.ch'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FILEIO.CH'
Static nHdlArq	:= 0
Static lBOracle	:= Trim(TcGetDb()) = 'ORACLE'
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MGVALSM0
validação  de filial
@type function
@author Cris
@since 24/03/2017
@version 1.0
@param cTabAtu, character, (Nome da tabela)
@param cCnt, character, (Conteúdo do campo filial contido no arquivo a ser migrado)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function MGVALSM0(cTabAtu,cCnt)

	Local aArea		:= GetArea()
	Local cFilAux	:= xFilial(cTabAtu)
		
		if Empty(Alltrim(cCnt)) .AND.  !Empty(Alltrim(cFilAux)) 
		
			Return {.F., '008'}//008 - Tabela exclusiva. O arquivo não possui conteúdo.
			
		EndIf
	 	 		
		if !Empty(Alltrim(cCnt)) .AND.  Empty(Alltrim(cFilAux)) 
		
			Return {.F., '007'}//007- Tabela compartilhada. O arquivo possui conteúdo.
			
		EndIf
	
		if len(Alltrim(cCnt)) <>  len(Alltrim(cFilAux)) 
		
			Return {.F., '009'}//009 -  Tamanho do campo filial divergente.
			
		EndIf
		
		if !Empty(Alltrim(cCnt))
		
			dbSelectarea('SM0')
			if !SM0->(dbSeek(cEmpAnt+cCnt))
		
				Return {.F., '001'}// 001 - Filial Inexistente. A filial informada não existe no cadastro de empresa.
			
			EndIf
			
		EndIf
			
	RestArea(aArea)
	
Return {.T.,''} 
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} $ SX3Exist
Verifica os campos descriminados no arquivo e devolve inconsistências conforme parametro nOpc.
@type function
@author Cris
@since 27/03/2017
@version 1.0
@param cTabAtu, character, (nome da tabela)
@param aCpoAtu, array, (Campos do arquivo)
@param nOpc, numeric, (1 - validar somente os campos descritos no arquivo se existem na SX3.
					   2 - Validar somente se os campos da SX3 existem no arquivo.
					   3 - Efetuar as duas validações acima.)
@return ${return}, ${array{Posição 1 - .T. tabela existe no dicionários de dados, .F. não existe;
						   Posição 2 - .T. todos os campos do arquivo existem no dicionário de dados; .F. existem campos que não existem;
						   Posição 3 - Array contendo os campos que não existem no dicionário de dados quando Posição 2 for .F.;
						   Posição 4 - .T. existem campos do dicionário de dados que não existem no arquivo; .F. campos em conformidade;
						   Posição 5 - Array contendo os campos que não existem no arquivo. 
						   Posição 6 - Objeto com a estrutura da Tabela}}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function SX3Exist(cTabAtu,aCpoAtu,nOpc)

	Local aAreaSX3	:= SX3->(GetARea())
//	Local oStrtTab	:=  FWFormStruct(1, cTabAtu)//FWformStruct não retorna alguns tipos de campos
	Local aCpoSX3	:= {}
	Local aCpoArq	:= {}
	Local nCpoArq	:= 0
	Local lNDivArq	:= .T.
	Local lExisTab	:= .T.
	Local lNDivSX3	:= .T.
	
		U_SelSX3(cTabAtu,@aCpoSX3)
	
		SX3->(dbSetOrder(1))
		if SX3->(dbSeek(cTabAtu))			
			
			//Primeiro verifica se todos os campos do arquivo estão no SX3
			if nOpc == 3 .OR. nOpc == 1
			
				For nCpoArq	:= 1 to len(aCpoAtu)
				
				//	if Ascan(oStrtTab:aFields,{|x,y| Alltrim(x[3]) == Alltrim(aCpoAtu[nCpoArq])}) == 0
				if Ascan(aCpoSX3,{|x,y| Alltrim(x[3]) == Alltrim(aCpoAtu[nCpoArq])}) == 0
					
						aAdd(aCpoArq,{aCpoAtu[nCpoArq],nCpoArq})
						lNDivArq	:= .F.
						
					EndIf
					
				Next 

			EndIf
			
			//Verifica se todos os campos no SX3 estão no arquivo
			If  nOpc == 3 .OR. nOpc == 2
						
				//For nCpoArq	:= 1 to len(oStrtTab:aFields)
				For nCpoArq	:= 1 to len(aCpoSX3)
				
					//if Ascan(aCpoAtu,{|x| x == oStrtTab:aFields[nCpoArq][3]}) == 0
					if Ascan(aCpoAtu,{|x| x == aCpoSX3[nCpoArq][3]}) == 0
					
						aAdd(aCpoSX3,aCpoAtu[nCpoArq])
						lNDivSX3	:= .F.
						
					EndIf
					
				Next 
				
			EndIf
					
		Else
			
			//Tabela inexistente
			lExisTab	:= .F.
			
		EndIf
	
	RestArea(aAreaSX3)

Return {lExisTab,lNDivArq,aCpoArq,lNDivSX3,aCpoSX3,Nil}//oStrtTab}
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TrVlDd
Trata e valida de uma forma genérica
@type function
@author Cris
@since 21/03/2017
@version 1.0
@param aConteud, array, (Conteúdo da linha)
@param aCpoAtu, array, (campos no arquivo)
@param aStrucX3, array, (campos do Sx3)
@param aNVlCpo, array, (campos que não devem ser validados)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function TrVlDd(aConteud,aCpoAtu,aStrucX3,aNVlCpo)

	Local iCnt		:= 0
	Local nPosCpo	:= 0
		 
		if len(aConteud[1]) <> len(aCpoAtu)

			aConteud[2]	:= .F. 
			aConteud[3]	:= 'Número de campos diferente do numero de dados.'	//codigo??????
						
		EndIf
		
		if aConteud[2]
					
			//1 o primeiro campo sempre se referirá a filial, a filial pode ser validada pela função MGVALSM0
			For iCnt := 2 to len(aConteud[1])-1
			
				//Retiro as aspas duplas originadas do txt
				aConteud[1][iCnt]	:= StrTran(aConteud[1][iCnt],'"','')
				
				//Os campos que devem ser ignorados devem ser enviados no array aNVlCpo
				if Ascan(aNVlCpo,{ |x| x == aCpoAtu[iCnt]}) == 0
				
					nPosCpo	:= Ascan(aStrucX3,{|x,y| Alltrim(x[3]) == Alltrim(aCpoAtu[iCnt])})
					
					//Carrega o Tipo de cada campo
					cTpCpo	:=	aStrucX3[nPosCpo][4]
				
					//Carrega a informação se é obrigatório ou não do SX3? 29.03.17, por enquanto não é para incluir, obdecer a MIT(alinhado com Roberto)
					//IF aStrucX3[nPosCpo][10]
					if	(cTpCpo <> 'N' .AND. Empty(Alltrim(aConteud[1][iCnt]))) 
		
						//aConteud[2]	:= .F. 
						if Empty(Alltrim(aConteud[3]))
							
							aConteud[3]	:= 'Campo sem preenchimento:'+aCpoAtu[iCnt]	
							
						Else
						
							aConteud[3]	:= aConteud[3]+','+aCpoAtu[iCnt]
							
						EndIf
				
					Elseif  (cTpCpo == 'N' .AND. ((aConteud[1][iCnt]) == '0' .OR. ('-' $ aConteud[1][iCnt]) )) 
					
						//aConteud[2]	:= .F. 
						if Empty(Alltrim(aConteud[3]))
							
							aConteud[3]	:= '|Valor incorreto ('+aCpoAtu[iCnt]+')'+aConteud[1][iCnt]
							
						Else
						
							aConteud[3]	:= aConteud[3]+','+aConteud[1][iCnt]
							
						EndIf
						
					//Caso a estrutura seja criada via aspdu incorretamente garante que o tipo se torne obrigatório
					Elseif Empty(cTpCpo)
					
						aConteud[2]	:= .F. 
						if Empty(Alltrim(aConteud[3]))
							
							aConteud[3]	:= 'Campo incorreto(SX3):'+aCpoAtu[iCnt]	
							
						Else
						
							aConteud[3]	:= aConteud[3]+','+aCpoAtu[iCnt]
							
						EndIf
				
					EndIf
	
					//Valida o formato de Data DD/MM/AAAA				
					if cTpCpo == 'D' .AND. !Empty(Alltrim(aConteud[1][iCnt]))
					
						VlDtAtu(aConteud,aConteud[1][iCnt],aCpoAtu[iCnt],aStrucX3)
										
					EndIf
					
					//Valida o tamanho do conteúdo
					if 	cTpCpo <> 'D' .AND. !Empty(Alltrim(aConteud[1][iCnt]))	
					
						if cTpCpo == 'N'
						
							VlVlAtu(aConteud,aConteud[1][iCnt],aCpoAtu[iCnt],aStrucX3,nPosCpo)
							
						Elseif cTpCpo == 'C'
	
							//Verifica se o campo caracter possui mais informações que seu destino
							if aStrucX3[nPosCpo][5] < len(Alltrim(aConteud[1][iCnt]))
							
								aConteud[2]	:= .F.
								
								if !'Tamanho do campo tipo caracter diferente do destino:' $ aConteud[3]
								
									aConteud[3]	:= aConteud[3]+'|Tamanho do campo do tipo caracter diferente do destino: '+aCpoAtu[iCnt]+':'+aConteud[1][iCnt]
						
								Else
								
									aConteud[3]:= aConteud[3]+','+aConteud[1][iCnt]
								
								EndIf
								
							EndIf
												
						EndIf
						
					EndIf
						
				EndIf 
				
			Next iCnt
	
		EndIf
				
Return
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ImpDd001
Inclui os dados na tabela 
@type function
@author Cris
@since 21/03/2017
@version 1.0
@param cTabAtu, caracter, (Tabela)
@param aCpoAtu, array, (Campos a atualizar)
@param aDdAtu , array, (Conteúdo dos campos a atualizar)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function ImpDd001(cTabAtu,aCpoAtu,aDdAtu)

	Local iCpo		:= 0
	Local aAreaAtu	:= (cTabAtu)->(GetArea())
		
		Begin Transaction
		
			if (cTabAtu)->(Reclock(cTabAtu,.T.))
				
				For iCpo	:= 1 to len(aCpoAtu)
									
					if Valtype(&(cTabAtu+'->'+(aCpoAtu[iCpo]))) == 'D'
					
						&(cTabAtu+'->'+(aCpoAtu[iCpo])) := iif('/'$ aDdAtu[iCpo],Ctod(aDdAtu[iCpo]),Stod(aDdAtu[iCpo]))
					
					Elseif  Valtype(&(cTabAtu+'->'+(aCpoAtu[iCpo]))) == 'N'
					
						&(cTabAtu+'->'+(aCpoAtu[iCpo])) := Val(StrTran(StrTran(aDdAtu[iCpo],'.',''),',','.'))//Val(Transform(aDdAtu[iCpo],GetSx3Cache(aCpoAtu[iCpo],"X3_PICTURE")))
						
					Else
					
						&(cTabAtu+'->'+(aCpoAtu[iCpo])) := aDdAtu[iCpo]
					
					EndIf
				Next iCpo
							
				(cTabAtu)->(MsUnlock())
		
			EndIf
	
		End Transaction
			
		RestArea(aAreaAtu)
					
Return 
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VlDtAtu
Valida a Data
@type function
@author Cris
@since 30/03/2017
@version 1.0
@param aConteud, array, (Descrição do parâmetro)
@param cDadoAtu, character, (Descrição do parâmetro)
@param cCpoArq, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function VlDtAtu(aConteud,cDadoAtu,cCpoArq)

	Local cDiaAt	:= ''
	Local cMesAt	:= ''
	Local cAnoAt	:= ''

		//Valida a primeira barra 
		if Substring(cDadoAtu,3,1) <> '/'
		
			aConteud[2]	:= .F.
			aConteud[3]	:= aConteud[3]	:= aConteud[3]+'|Data inválida '+cCpoArq+':'+cDadoAtu
			
		EndIf
		
		//Valida a segunda barra
		if aConteud[2] .AND. Substring(cDadoAtu,6,1) <> '/'
		
			aConteud[2]	:= .F.
			aConteud[3]	:= aConteud[3]	:= aConteud[3]+'|Data inválida '+cCpoArq+': '+cDadoAtu
			
		EndIf
							
		//Validando dia
		cDiaAt	:= Substring(cDadoAtu,1,2) 
		if aConteud[2] .AND. (len(cDiaAt) > 2 .OR. len(cDiaAt) < 2  .OR. Val(cDiaAt) == 0)
		
			aConteud[2]	:= .F.
			aConteud[3]	:= aConteud[3]	:= aConteud[3]+'|Data inválida '+cCpoArq+': '+cDadoAtu
			
		EndIf
		
		//Validando mês
		cMesAt	:=  Substring(cDadoAtu,4,2) 
		if aConteud[2] .AND. (len(cMesAt) > 2 .OR. len(cMesAt) < 2  .OR. Val(cMesAt) == 0 .OR. Val(cMesAt) > 12)
		
			aConteud[2]	:= .F.
			aConteud[3]	:= aConteud[3]	:= aConteud[3]+'|Data inválida '+cCpoArq+': '+cDadoAtu
			
		EndIf					
						
		//Validando ano
		cAnoAt	:=  Substring(cDadoAtu,7,4) 
		if aConteud[2] .AND. (len(cAnoAt) > 4 .OR. len(cAnoAt) < 4  .OR. Val(cAnoAt) == 0)
		
			aConteud[2]	:= .F.
			aConteud[3]	:= aConteud[3]	:= aConteud[3]+'|Data inválida '+cCpoArq+': '+cDadoAtu
			
		EndIf	

		//Valida se o mês possui o dia corretamente informado
		if aConteud[2] .AND. Month(LastDay(Ctod(cDadoAtu),2)) <> val(cMesAt)
							
			aConteud[2]	:= .F.
			aConteud[3]	:= aConteud[3]	:= aConteud[3]+'|Data inválida '+cCpoArq+': '+cDadoAtu

		EndIf
					
Return 
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VlVlAtu
Valida o valor 
@type function
@author Cris
@since 30/03/2017
@version 1.0
@param aConteud, array, (Descrição do parâmetro)
@param cDadoAtu, character, (Descrição do parâmetro)
@param cCpoArq, character, (Descrição do parâmetro)
@param aStrucX3, array, (Descrição do parâmetro)
@param nPosCpo, numeric, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function VlVlAtu(aConteud,cDadoAtu,cCpoArq,aStrucX3,nPosCpo)
	
	//Verifica tamanho, pois nas documentações obriga o preenchimento com zeros a esquerda para completar
	if aStrucX3[nPosCpo][5] <> len(Alltrim(cDadoAtu))
	
		aConteud[2]	:= .F.
		if !'Tamanho do campo valor diferente do destino' $ aConteud[3]
		
			aConteud[3]:= aConteud[3]+'|Tamanho do campo valor diferente do destino '+cCpoArq+':'+cDadoAtu
	
		Else
		
			aConteud[3]:= aConteud[3]+','+cDadoAtu								
			
		EndIf
		
	EndIf
	
	//Quando existir casas decimais valida se foram informadas corretamente no arquivo
	if aStrucX3[nPosCpo][6] <> 0 .AND. Substring(Alltrim(cDadoAtu),aStrucX3[nPosCpo][5]-aStrucX3[nPosCpo][6]+1,1) <> '.'
	
		aConteud[2]	:= .F.
		if !'As casas decimais não conferem com o destino' $ aConteud[3]
		
			aConteud[3]:= aConteud[3]+'|A quantidade de casas decimais não conferem com o destino '+cCpoArq+':'+cDadoAtu
			
		Else
		
			aConteud[3]:= aConteud[3]+','+cDadoAtu
			
		EndIf
						
	EndIf
	
Return
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SelSX2
Carrega todas as tabelas
@type function
@author Cris
@since 07/04/2017
@version 1.0
@param aTabs, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function SelSX2(aTabs)

Local aAreaSX2	:= SX2->(GetArea())

//Início - Thais Paiva - Compatibilização P27
OpenSxs(,,,,cEmpAnt,"SX2TAB","SX2",,.F.)
//dbSelectArea('SX2') 
//SX2->(dbGotop())
//While !SX2->(Eof())
If Select("SX2TAB") > 0
	While SX2TAB->(!EOF())

		//aAdd(aTabs,SX2->X2_CHAVE+' - '+SX2->X2_NOME+'-'+SX2->X2_ARQUIVO)	
		AAdd(aTabs, SX2TAB->&(X2_CHAVE)+' - '+SX2TAB->&(X2_NOME)+'-'+SX2TAB->&(X2_ARQUIVO))
		//SX2->(dbSkip())
		SX2TAB->(dbSkip())
	
	EndDo
Endif
//Fim - Thais Paiva - Compatibilização P27
RestArea(aAreaSX2)
	
Return 
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} $MGSM0DP1
De Para de Filial
@type function
@author Cris
@since 11/04/2017
@version 1.0
@param cEmpDe, character, (Empresa de Origem)
@param cFilDe, character, (Filial de Origem)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function MGSM0DP1(cEmpDe,cFilDe)
	
		Local aArea			:= GetArea()
		Local aAreaSZX		:= SZX->(GetArea())
		Local cFilPara		:= ''	
		Local cArqImp		:= ''
		Local cEmpFlAx		:= ''	

			//Caso o arquivo possua o codigo da empresa no nome do arquivo e não concatenada com a filial	
			if cEmpDe == 'A'
			
				SplitPath(ZVJ->ZVJ_DIRIMP,,,@cArqImp)
				cEmpDe	:= Substring(cArqImp,5,2)
				cEmpFlAx	:= cEmpDe+cFilDe	
				
			Else
			
				cEmpFlAx	:= Alltrim(cEmpDe)+cFilDe
				
			EndIf
			
			//Caso a funçao seja configurada para um arquivo compartilhado, os parametros virão em branco.
			if !Empty(cEmpFlAx)
			
				dbSelectArea('SZX')
				SZX->(dbSetOrder(1))//SZX_EMPFIL (P10)
				if SZX->(dbSeek(cEmpFlAx))
			
					cFilPara	:= SZX->ZX_FILIALP
					
				EndIf

			EndIF
						
		RestArea(aArea)
		RestArea(aAreaSZX)
		
Return cFilPara
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MGCTTDP1
De Para Centro de Custo
@type function
@author Cris
@since 11/04/2017
@version 1.0
@param cCCAtu, character, (Centro de Custo  "De")
@param cItemVl, character, (Item Contábil  "De")
@param cClasVl, character, (Classe Valor  "De")
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function MGCTTDP1(cCCAtu,cItemVl,cClasVl)
	
		Local aArea			:= GetArea()
		Local aAreaSZY		:= SZY->(GetArea())
		Local cCCPara		:= ''	
		Local cCCAux		:= ''
		
		Default cCCAtu		:= ''
		Default	cItemVl 	:= ''
		Default cClasVl		:= ''
		
			//CC Debito
			//CT2_CCD+CT2_ITEMD+CT2_CLVLDB
			//CC Crédito
			//CT2_CCC+CT2_ITEMC+CT2_CLVLCR	

			if !Empty(cCCAtu)
			
				cCCAux	:= Alltrim(cCCAtu)+Alltrim(cItemVl)+Alltrim(cClasVl)
				M->CT2_ITEMD	:= ''
				M->CT2_CLVLDB	:= ''
				M->CT2_ITEMC	:= ''
				M->CT2_CLVLCR	:= ''
								
				dbSelectArea('SZY')
				SZY->(dbSetOrder(1))//SZY_CCP10 (P10)
				if SZY->(dbSeek(cCCAux))
			
					cCCPara	:= SZY->ZY_CCP12
					
				EndIf
			
			EndIf
			
		RestArea(aArea)
		RestArea(aAreaSZY)
		
Return cCCPara
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SelSX3
Carrega o SX3 da tabela
@type function
@author Cris
@since 13/04/2017
@version 1.0
@param cTabAtu, character, (Descrição do parâmetro)
@param aRetCpos, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function SelSX3(cTabAtu,aRetCpos)
	
Local aAreaSX3	:= SX3->(GetArea())
Local _aCpoX3	:= {} //Thais Paiva - Compatibilização P27

Default cTabAtu 	:= cAlias 
Default aRetCpos	:= {}

//Início - Thais Paiva - Compatibilização P27
//dbSelectArea('SX3')
//SX3->(dbSetOrder(1))
//if SX3->(dbSeek(cTabAtu))
_aCpoX3 := FWSX3Util():GetAllFields( cTabAtu , .T. )
If Len(_aCpoX3) > 0
	//While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == cTabAtu
	For _nx3 := 1 to Len(_aCpoX3)
	
		//aAdd(aRetCpos,{SX3->X3_ARQUIVO,SX3->X3_ORDEM, SX3->X3_CAMPO,SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,SX3->X3_TITULO,;
		//				SX3->X3_VALID, SX3->X3_RELACAO,SX3->X3_CONTEXT, SX3->X3_OBRIGAT})
		aAdd(aRetCpos,{GetSx3Cache(_aCpoX3[_nx3], 'X3_ARQUIVO'),GetSx3Cache(_aCpoX3[_nx3], 'X3_ORDEM'),;
					   GetSx3Cache(_aCpoX3[_nx3], 'X3_CAMPO'),GetSx3Cache(_aCpoX3[_nx3], 'X3_TIPO'),;
					   GetSx3Cache(_aCpoX3[_nx3], 'X3_TAMANHO'),GetSx3Cache(_aCpoX3[_nx3], 'X3_DECIMAL'),;
					   GetSx3Cache(_aCpoX3[_nx3], 'X3_TITULO'),GetSx3Cache(_aCpoX3[_nx3], 'X3_VALID'),;
					   GetSx3Cache(_aCpoX3[_nx3], 'X3_RELACAO'),GetSx3Cache(_aCpoX3[_nx3], 'X3_CONTEXT'),;
					   GetSx3Cache(_aCpoX3[_nx3], 'X3_OBRIGAT')})
	//SX3->(dbSkip())
	Next _nx3
	//EndDo

EndIf
//Fim - Thais Paiva - Compatibilização P27

RestArea(aAreaSX3)

Return 
///---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MGCT1Tr1
Tratamento da conta contábil para não considerar alguns caracteres.
@type function
@author Cris
@since 09/05/2017
@version 1.0
@param cCCntDe, character, (Conteúdo enviado)
@return ${return}, ${return_description}
/*////---------------------------------------------------------------------------------------------------------------------------
User Function MGCT1Tr1(cCntCT1)

	cCntCT1	:= StrTran(StrTran(cCntCT1,'.',''),' ','')

Return cCntCT1
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MGCT1VL1
Valida conta contábil
@type function
@author Cris
@since 13/04/2017
@version 1.0
@param cCCntDe, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function MGCT1VL1(cFilArq,cCCntDe)

		Local aArea			:= GetArea()
		Local aAreaCT1		:= CT1->(GetArea())
		Local lExisCT1		:= .T.

		Default cCCntDe	:= ''
				
			dbSelectArea('CT1')
			CT1->(dbSetOrder(1))
			if !CT1->(dbSeek(cFilArq+cCCntDe))
		
				lExisCT1	:= .F.
				
			EndIf
			
		RestArea(aArea)
		RestArea(aAreaCT1)
		
Return lExisCT1

//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MGCTTVL1
Valida centro de custo
@type function
@author Cris
@since 13/04/2017
@version 1.0
@param cCCntDe, character, (Descrição do parâmetro)
@return ${lógico}, ${.T. centro de custo válido .F. centro de custo não valido}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function MGCTTVL1(cFilArq,cCustoDe)

		Local aArea			:= GetArea()
		Local aAreaCTT		:= CTT->(GetArea())
		Local lExisCTT		:= .T.

		Default cCustoDe	:= ''
				
			dbSelectArea('CT1')
			CTT->(dbSetOrder(1))
			if !CTT->(dbSeek(cFilArq+cCustoDe))
		
				lExisCTT	:= .F.
				
			EndIf
			
		RestArea(aArea)
		RestArea(aAreaCTT)
		
Return lExisCTT
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} fTroca
Substitui o LF de um campo
@type function
@author Edson Cavalcante
@since 13/04/2017
@version 1.0
@param cCpoLmp, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function fTroca(cCpoLmp)
 
Local cChrLF   	:= Chr(10)
Local cChrCR   	:= Chr(13)
Local cBranco	:= " "
Local nI        := 0
Local nPos      := 0

	//cCpoLmp := AllTrim( cCpoLmp )

	For nI := 1 To Len( cCpoLmp )
		
		If ( nPos := At( SubStr( cCpoLmp, nI, 1 ), cChrLF ) ) > 0
			cCpoLmp := SubStr( cCpoLmp, 1, nI - 1 ) + SubStr( cBranco, nPos, 1 ) +  SubStr( cCpoLmp, nI + 1 )
		EndIf
		
		If ( nPos := At( SubStr( cCpoLmp, nI, 1 ), cChrCR ) ) > 0
			cCpoLmp := SubStr( cCpoLmp, 1, nI - 1 ) + SubStr( cBranco, nPos, 1 ) +  SubStr( cCpoLmp, nI + 1 )
		EndIf
		
	Next   
                                                       
Return cCpoLmp
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SelDirGrv
Selecionando diretório
@type function
@author Cris
@since 06/04/2017
@version 1.0
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function SelDirGrv(cDirArq,cNomeArq)

	Local lDirArq  		:= .T.
	Local lNAborta		:= .T.
	Private nLastKey	:= 0
	Default cDirArq		:= ''
		
		if Empty(cDirArq) 
		
			cDirArq := cGetFile("","Diretório para gravação ",1,,.F.,GETF_LOCALHARD+GETF_RETDIRECTORY )
	
		EndIf
		
		If nLastKey == 27
		
			lDirArq	:= .F.
			HELP("HELP",, 'Seleção do diretório',, "Operação abortada pelo usuário!", 1, 0)
			
			Return lDirArq
		Endif
		
		If !ExistDir(cDirArq)
			
			While !ExistDir(cDirArq) .AND. lNAborta
			
				if (lNAborta :=	MsgYesNo('Diretório não existe deseja criá-lo?'))
				
					MakeDir(cDirArq)

				EndIf
			
			EndDo
			
		EndIf   
		
		if (nHdlArq := FCreate(cDirArq+cNomeArq, FC_NORMAL)) < 0
		
			lDirArq	:= .F.
		 	HELP("HELP",, 'Criação do Arquivo',, ("Erro ao criar arquivo: " + Str(Ferror())), 1, 0)
		 	
		EndIf
		
		if FT_FUse(cDirArq+cNomeArq) < 0
		
			lDirArq	:= .F.
		 	HELP("HELP",, 'Criação do Arquivo',, "O arquivo criado não pode ser aberto. Operação Abortada. Verifique suas permissões de acesso.", 1, 0)
		 	
		EndIf   

Return lDirArq
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DescReg
(long_description)
@type function
@author Cris
@since 06/04/2017
@version 1.0
@param cConteudo, character, (Descrição do parâmetro)
@param lFimGrv, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function DescReg(cConteudo,lFimGrv,cNomeArq,lExibMsg)
	
	Local 	nY			:= 0
	Local	nCnt		:= 0
	Default lFimGrv		:= .T.
	Default cNomeArq	:= ''
	Default lExibMsg	:= .T.
	
		FT_FGoTop()    
	
		if !Empty(cConteudo)
		
			FWRITE(nHdlArq, cConteudo+IIF(!lFimGrv,CRLF,CHR(10))  )   

		EndIf
		
		//Quando final de arquivo
		if lFimGrv
		
			FT_FUse()
			
			if FClose(nHdlArq)  
			
				if lExibMsg
			
					Aviso("Geração do Arquivo", 'Termino da montagem do arquivo '+cNomeArq, {'OK'},3)

				EndIf
				
			Else
				
				Aviso("Não Geração do Arquivo",'Ocorreu um erro no fechamento do arquivo ('+Str(FERROR())+'). Informe ao departamento de TI', {'OK'},3)
				
			EndIf
	
		EndIf
	
Return
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TTHORAS
(long_description)
@type function
@author Cris
@since 26/04/2017
@version 1.0
@param _DataIni, ${param_type}, (Descrição do parâmetro)
@param _DataFim, ${param_type}, (Descrição do parâmetro)
@param cHoraIni, character, (Descrição do parâmetro)
@param cHoraFim, character, (Descrição do parâmetro)
@param nTtHrs, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function TTHORAS(_DataIni,_DataFim,cHoraIni,cHoraFim,nTtHrs)

	if Valtype(_DataIni) == 'D'
	
		_DataIni	:= Dtos(_DataIni)		
		
	EndIf
	
	if Valtype(_DataFim) == 'D'
	
		_DataFim	:= Dtos(_DataFim)		
		
	EndIf		
	
	if _DataFim == _DataIni
	
		nTtHrs	:= Subhoras(cHoraFim,cHoraIni)
	
	EndIf
	
	if _DataFim > _DataIni	

		nTtHrs	:= Subhoras('24:00:00',cHoraIni)
		nTtHrs	:= nTtHrs + ((Val(_DataFim)-Val(_DataIni))*24)
		
	EndIf
	
	
Return 
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldCod
Pesquisa se o código existe na tabela enviada como parametro.Tem a mesma finalidade da função EXISTCPO.
@type function
@author Cris
@since 14/06/2017
@version 1.0
@param cTabAtu, character, (Descrição do parâmetro)
@param cConteud, character, (Descrição do parâmetro)
@param nIndice, numérico, (Descrição do parâmetro)
@param cFilAtu, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function VldCod(cTabAtu,cConteud,nIndice,cFilAtu)
	
	Local aAreaAtu	:= GetArea()
	Local aAreaPsq	:= (cTabAtu)->(GetArea())
	Local cFilAux	:= ''
	Local lExisInf	:= .T.
	Default cFilAtu	:= cFilAnt
	Default nIndice	:= 1
	
		cFilAux	:= iif(!Empty(xFilial(cTabAtu)),cFilAtu,xFilial(cTabAtu))
	
		dbSelectArea(cTabAtu)
		(cTabAtu)->(dbSetOrder(nIndice))
		if !(cTabAtu)->(dbSeek(cFilAux+cConteud))
		
			lExisInf	:= .F.

		EndIf
				
	RestArea(aAreaAtu)
	RestArea(aAreaPsq)
	
Return lExisInf
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetCnt
Retorna o conteúdo de um campo a partir da chave de pesquisa, similar a função POSICIONE.
@type function
@author Cris
@since 20/06/2017
@version 1.0
@param cTabAtu, character, (Descrição do parâmetro)
@param nIndice, numérico, (Descrição do parâmetro)
@param cChvPsq, character, (Descrição do parâmetro)
@param cCpoRet, character, (Descrição do parâmetro)
/*///---------------------------------------------------------------------------------------------------------------------------
User Function RetCnt(cTabAtu,nIndice,cChvPsq,cCpoRet)

	Local aAreaAtu	:= (cTabAtu)->(GetArea())
	Local _nCpoRet	
	
		dbSelectArea(cTabAtu)
		(cTabAtu)->(dbSetOrder(nIndice))
		if (cTabAtu)->(dbSeek(Rtrim(cChvPsq))) 
		
			_nCpoRet	:= &(cCpoRet)
			
		EndIf
		
	RestArea(aAreaAtu)	
	
Return _nCpoRet
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ListTab
Consulta se a tabela existe no banco, possibilitando a montagem de diversas consultas posteriores.
@type function
@author Cris
@since 20/04/2017
@version 1.0
@param cTabPesq, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function TabExist(cTabPesq,aRetPesq)

	Local cQryTab		:= ''	
	Local cTabTmp		:= GetNextAlias()
	Default cTabPesq	:= ''
	Default aRetPesq	:= {}
		
		//Caso seja a partir do dicionário de dados
		if lBOracle
		
			cQryTab	:= 	"	SELECT NVL(TABLE_NAME,'') AS TAB "+CRLF
			cQryTab	+=	"	FROM user_tables "+CRLF
			
			if !Empty(cTabPesq) 
			
				if len(cTabPesq) == 3
				
					cQryTab	+=	"	WHERE TABLE_NAME Like '"+cTabPesq+"%' "+CRLF
				
				Else
				
					cQryTab	+=	"	WHERE TABLE_NAME = '"+cTabPesq+"' "+CRLF
	
				EndIf
				
			EndIf
			
		Else
	
			cQryTab	+=	"			SELECT ISNULL(name,'') AS TAB "+CRLF
			cQryTab	+=	"			FROM dbo.SYSOBJECTS  "+CRLF
			cQryTab	+=	"			WHERE XTYPE = 'U' "+CRLF
	
			
			if !Empty(cTabPesq)
			
				if len(cTabPesq) == 3
				
					cQryTab	+=	"			AND name like '%"+cTabPesq+"%' "+CRLF
					
				Else
				
					cQryTab	+=	"			AND name = '"+cTabPesq+"' "+CRLF
	
				EndIf				
				
			EndIf
	
		EndIf

		cQryTab := ChangeQuery(cQryTab)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryTab),cTabTmp,.T.,.T.)
				
		if !(cTabTmp)->(Eof())
			
			if len(cTabPesq) > 3
				
				cTabPesq	:= (cTabTmp)->TAB
				(cTabTmp)->(dbCloseArea())
				Return {cTabPesq}

			Else
				
				While !(cTabTmp)->(Eof())
				
					aAdd(aRetPesq,Alltrim((cTabTmp)->TAB))
					
				(cTabTmp)->(dbSkip())
				
				EndDo
				
				(cTabTmp)->(dbCloseArea())
				Return  aRetPesq	
			EndIf
		
		Else
			(cTabTmp)->(dbCloseArea())
			Return {}
						
		EndIf
	
	(cTabTmp)->(dbCloseArea())
		
Return {}			
