#Include 'Protheus.ch'
Static _cRetSel	
/*{Protheus.doc} F0200404
Consulta especifica (SXB) 
@type User function
@author Cristiane Thomaz Polli
@since 08/07/2016
@version P12.1.7
@Project MAN00000463301_EF_004
@param nOpcF3, numérico, (1=F3 da Filial, 2=F3 do Setor;3 ou 4 retorna o(s)
 valor(es) selecionados)
@return ${.T. para seleção ou _cRetSel }, ${Retorno do F3}
*/
User Function F0200404(nOpcF3)

	Local aDados 	:=  Array(0)
	Local aRetSel 	:= {}
	Local nI 		:= 1
	Local cRetAux	:= ''
	Local cRetAtu	:= ''
	Local cCntAtu	:= ''
	
	If nOpcF3 == 1
	
		_cRetSel	:= ''
		aDados		:= DvRelFil()

		f_Opcoes(@cRetAtu,'Filiais',aDados,@cRetAtu,,,.F.,0,len(aDados))
		
		aRetSel := StrTokArr(cRetAtu,"*")
		
		While nI <= Len(aRetSel)		

			if !(Alltrim(subStr(aRetSel[nI],01,TamSX3('C1_FILIAL')[1])) $ cRetAux + cCntAtu) //!subStr(aRetSel[nI],01,08) $ cRetAux + cCntAtu Thais Paiva - 17830513
	
				cRetAux += subStr(aRetSel[nI],01,TamSX3('C1_FILIAL')[1]) //subStr(aRetSel[nI],01,08) Thais Paiva - 17830513
			
				if nI < Len(aRetSel)
				
					cRetAux += ';'
				
				EndIf
			
			EndIf
				
			nI++
		
		EndDo
				
	Elseif nOpcF3 == 3

		_cRetSel	:= ''
		aDados 		:= DvRelSet(aDados)
				
		f_Opcoes(@cRetAtu,'Setor',aDados,@cRetAtu,,,.F.,0,len(aDados))
		
		aRetSel := StrTokArr(cRetAtu,"*")
		
		While nI <= Len(aRetSel)

			if !(Alltrim(subStr(aRetSel[nI],01,TamSX3('C1_LOCAL')[1])) $ cRetAux + cCntAtu) //!subStr(aRetSel[nI],01,02) $ cRetAux + cCntAtu Thais Paiva - 17830513
				
				cRetAux +=  subStr(aRetSel[nI],01,TamSX3('C1_LOCAL')[1]) //subStr(aRetSel[nI],01,02) Thais Paiva - 17830513
				
				if nI < Len(aRetSel)
				
					cRetAux += ';'
				
				EndIf
				
			EndIf
			
			nI++
		
		EndDo

	EndIf
		
	if !Empty(cRetAux)
	
		_cRetSel	:= cRetAux
	
	EndIf

	if nOpcF3 == 2 .OR. nOpcF3 == 4
	
		Return _cRetSel
		
	EndIf
	
Return .T.  

/*{Protheus.doc} DvRelFil
Carrega as filiais no array para exibição
@type User function
@author Cristiane Thomaz Polli
@since 08/07/2016
@version P12.1.7
@Project MAN00000463301_EF_004
@return ${aDdFil}, ${array com as filiais da empresa que esta sendo utilizada}
*/
Static Function DvRelFil()

	Local aAreaSM0	:= SM0->(GetArea())
	Local aDdFil	:= {}
	
	dbSelectArea("SM0")
	SM0->(dbSetOrder(1))
	SM0->(DbSeek(cEmpAnt))
	
	While !SM0->(Eof()) .AND. cEmpAnt == SM0->M0_CODIGO
		AAdd(aDdFil, AllTrim(SM0->M0_CODFIL) + ' - ' + AllTrim(SM0->M0_FILIAL) + '*')
		SM0->(dbSkip())
	End
		
	RestArea(aAreaSM0)
	
Return aDdFil

/*{Protheus.doc} DvRelSet
Carrega todos os locais no array  para exibição.
@type User function
@author Cristiane Thomaz Polli
@since 08/07/2016
@version P12.1.7
@Project MAN00000463301_EF_004
@return ${aDdSet}, ${array com os setores ativos}
*/
Static Function DvRelSet(aDdSet)
	Local _aFilSel := StrTokArr(MV_PAR01,";") //Thais Paiva - 17830513
	Local aAreaNNR	:= NNR->(GetArea())
	
		dbSelectArea('NNR')
		
		While  !NNR->(Eof()) 
	
			If NNR->(FieldPos("NNR_MSBLQL")) > 0 .And. NNR->NNR_MSBLQL <>  '1' .AND. ; 
				(AScan(_aFilSel,{|x| Alltrim(x) == Alltrim(NNR->NNR_FILIAL)})) > 0 //Thais Paiva - 17830513
			
				AAdd(aDdSet,NNR->NNR_CODIGO + ' - ' + Alltrim(NNR->NNR_DESCRI) + '*')
			
			EndIf
			
			NNR->(dbSkip())
			
		EndDo
		
	RestArea(aAreaNNR)
	
Return aDdSet
