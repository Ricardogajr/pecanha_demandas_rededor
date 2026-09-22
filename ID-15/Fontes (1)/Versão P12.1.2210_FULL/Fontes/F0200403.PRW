#Include 'Protheus.ch'
/*{Protheus.doc} F0200403
Valida a(s) filial(is) informadas no pergunte
@type User function
@author Cristiane Thomaz Polli
@since 07/07/2016
@version P12.1.7
@Project MAN00000463301_EF_004
@return ${lValFil}, ${.T. o contéudo informado é válido .F. não é válido.}
*/
User Function F0200403()

	Local	lValFil		:= .T.
	Local	aArea		:= GetArea()
	Local	aAreaSM0	:= SM0->(GetArea())
	Local	nSM0Fil		:= 0
	Local 	cSM0Inf		:= Alltrim(MV_PAR01)
	Local 	nTamCont	:= Len(Alltrim(cSM0Inf))
	Local 	aRetfil 	:= FwEmpLoad(.T.)	
	Local 	aFilAtu		:= StrTokArr(cSM0Inf,";")
	Local 	nPosFil		:= 0
	Local   nPosAux		:= 0
	
	If !Empty(cSM0Inf)
			
		//verifica se o último caracter é ponto e vírgula.
		If Substring(Alltrim(cSM0Inf),nTamCont,1) <> ';' 
				
			Aviso('Obrigatório Separador (;)','Informe o ponto  e virgula (;) após cada código. Obrigatório!',{'OK'})
			lValFil		:= .F.
								
		EndIf
		
		//Válida informações digitadas		
		For nSM0Fil := 1 to len(aFilAtu)
	
			//Verifica se existe
			If AScan(aRetFil,{|x,y| Alltrim(x[3]) == aFilAtu[nSM0Fil]}) == 0
	
				Aviso('Inválida Filial','A Filial ' + aFilAtu[nSM0Fil] + ' não existe ou colaborador não tem acesso. Informe uma filial válida!',{'OK'})
				lValFil		:= .F.	
			
			EndIf
			
			nPosFil	:= 	nSM0Fil + 1
			//Verifica se a informação no  filtro não esta duplicado
			If lValFil	.AND. nPosFil <= len(aFilAtu) .AND. (nPosAux	:= AScan(aFilAtu,{|x| Alltrim(x) == aFilAtu[nSM0Fil]},nPosFil)) > 0
				
				Aviso('Duplicidade','A filial ' + aFilAtu[nSM0Fil] + ' foi informada novamente na posição ' + StrZero(nPosAux,3) + '. Não duplique o filtro!',{'OK'})
				lValFil		:= .F.	
							
			EndIf
					
		Next nSM0Fil
	
	Else
		
		Aviso('Obrigatório Preenchimento','Informe pelo menos uma filial. Campo  obrigatório!',{'OK'})
		lValFil	:= .F.
			
	EndIf

	RestArea(aArea)
	RestArea(aAreaSM0)
	
Return lValFil