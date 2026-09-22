#Include 'TOTVS.CH'
/*{Protheus.doc} F0200402
Valida setor(es) informados no parametros
@type User function
@author Cristiane Thomaz Polli
@since 07/07/2016
@version P12.1.7
@Project MAN00000463301_EF_004
@return ${lValSet}, ${.T. o contéudo informado é válido .F. não é válido.}
*/
User Function F0200402()
	Local _aFilSel := StrTokArr(MV_PAR01,";") //Thais Paiva - 17830513
	Local	lValSet		:= .T.
	Local	aAreaAtu	:= GetArea()
	Local	aAreaNNR	:= NNR->(GetArea())
	Local	nSetor		:= 0
	Local	nTamCpo		:= TamSX3('NNR_CODIGO')[1]
	Local 	cSetor		:= Alltrim(MV_PAR02)
	//Local 	nTamCont	:= Len(cSetor) Thais Paiva - 17830513
	Local 	aSetAtu		:= StrTokArr(cSetor,";")
	Local 	nPosSet		:= 0
	Local   nPosAux		:= 0
	Local _nFil := 0 //Thais Paiva - 17830513
	Local lValFil := .F.
	//Valida 
	If !Empty(cSetor) 
	
	//verifica se o último caracter é ponto e vírgula.
		If Substring(Alltrim(cSetor),len(cSetor),1) <> ';' 
				
			Aviso('Obrigatório Separador (;)','Informe o ponto  e virgula (;) após cada código. Obrigatório!',{'OK'})
			lValSet		:= .F.
								
		EndIf
		
		//Varre o range para certificar-se que todos os valores existem na tabela referida  (NNR)	
		For nSetor := 1 to Len(aSetAtu)
			
			If nTamCpo < len(aSetAtu[nSetor])
			
					Aviso('Não válido tamanho','O código informe ' + aSetAtu[nSetor] + ' ultrapassa o tamanho do campo Setor. Não é Válido!',{'OK'})
					lValSet		:= .F.
				
			Else
			
				dbSelectArea('NNR')
				
				NNR->(dbSetOrder(1))
				lValFil := .F.
				For _nFil := 1 to Len(_aFilSel) //Início Thais Paiva - 17830513
					If !Empty(Alltrim(_aFilSel[_nFil]))
						if !NNR->(DbSeek(_aFilSel[_nFil] + Padr(aSetAtu[nSetor],nTamCpo,' '))) .AND. !lValFil
							//Aviso('Inválido Setor','O Setor ' + Padr(aSetAtu[nSetor],nTamCpo,' ') + ' não existe. Informe um setor válido!',{'OK'})
							lValFil := .F. //lValSet		:= .F.
						Elseif NNR->(FieldPos("NNR_MSBLQL")) > 0 .And. NNR->NNR_MSBLQL == '1'
							Aviso('Não permitido Setor','O Setor ' + Padr(aSetAtu[nSetor],nTamCpo,' ') + ' esta bloqueado. Informe um setor ativo!',{'OK'})
							lValSet		:= .F.
						Else
							lValFil := .T.
						EndIf
						If lValFil .And. lValSet
							Exit
						EndIf
					Endif
				Next //Fim Thais Paiva - 17830513
				
				If !lValFil .AND. lValSet
					Aviso('Inválido Setor','O Setor ' + Padr(aSetAtu[nSetor],nTamCpo,' ') + ' não existe. Informe um setor válido!',{'OK'})
					lValSet := .F.
				EndIf
				nPosSet	:= 	nSetor + 1
				//Verifica se a informação já foi digitada no parametro
				If lValSet	.AND. nPosSet <= len(aSetAtu) .AND. (nPosAux	:= AScan(aSetAtu,{|x| Alltrim(x) == aSetAtu[nSetor]},nPosSet)) > 0
					
					Aviso('Duplicidade','O Setor ' + aSetAtu[nSetor] + ' foi informada novamente na posição ' + StrZero(nPosAux,3) + '. Não duplique o filtro!',{'OK'})
					lValSet		:= .F.	
								
				EndIf
			
			EndIf
					
		Next nSetor	
		
	Else
	
		Aviso('Obrigatório Preenchimento','Informe pelo menos um setor. Campo  obrigatório!',{'OK'})
		lValSet	:= .F.
		
	EndIf

	RestArea(aAreaAtu)
	RestArea(aAreaNNR)
	
Return lValSet
