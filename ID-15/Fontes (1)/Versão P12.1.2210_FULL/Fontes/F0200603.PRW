#Include 'Protheus.ch'
Static _cRetSel
//-----------------------------------------------------------------------------
/*/{Protheus.doc} F0200603
Consulta especifica (SXB)
@type User function
@author Cristiane Thomaz Polli
@since 08/07/2016
@version P12.1.7 @Project MAN00000463301_EF_006
@param nOpcF3, numérico, (1=F3 da Filial, 2=F3 do Setor;3 ou 4 retorna o(s) valor(es) selecionados)
@return ${.T. para seleção ou _cRetSel }, ${Retorno do F3}
/*/
//-----------------------------------------------------------------------------
User Function F0200603(nOpcF3)
	
	Local aDados 	:=  Array(0)
	Local aRetSel 	:= {}
	Local nI 		:= 1
	Local cRetAux	:= ''
	Local cRetAtu	:= ''
	Local cCntAtu	:= ''
	
	cCntAtu	:= GetMemVar(ReadVar())
	
	If nOpcF3 == 1
		
		_cRetSel	:= ''
		aDados		:= DvRelPro()
		
		f_Opcoes(@cRetAtu,'Produtos',aDados,@cRetAtu,,,.F.,0,len(aDados))
		
		aRetSel := StrTokArr(cRetAtu,"*")
		
		While nI <= Len(aRetSel)
			
			if !subStr(aRetSel[nI],01,15) $ cRetAux + cCntAtu
				
				cRetAux += subStr(aRetSel[nI],01,15)
				
				if nI < Len(aRetSel)
					
					cRetAux += ';'
					
				EndIf
				
			EndIf
			
			nI++
			
		EndDo
		
	Elseif nOpcF3 == 3
		_cRetSel	:= ''
		aDados 		:= DvRelGrp(aDados)
		f_Opcoes(@cRetAtu,'Setor',aDados,,,,.F.,0,len(aDados))
		aRetSel := StrTokArr(cRetAtu,"*")
		While nI <= Len(aRetSel)
			if !subStr(aRetSel[nI],01,02) $ cRetAux + cCntAtu
				cRetAux +=  subStr(aRetSel[nI],01,06)
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
//-----------------------------------------------------------------------------
/*/{Protheus.doc} DvRelPro
Carrega as filiais no array para exibição
@type User function
@author Cristiane Thomaz Polli
@since 08/07/2016
@version P12.1.7 @Project MAN00000463301_EF_006
@return ${aDdFil}, ${array com as filiais da empresa que esta sendo utilizada}
/*/
//-----------------------------------------------------------------------------
Static Function DvRelPro()
	
	Local aAreaSB1	:= SB1->(GetArea())
	Local aDdPro	:= {}
	
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	dbGotop()
	While !SB1->(Eof())
		If SB1->(FieldPos("B1_MSBLQL")) > 0 .And. SB1->B1_MSBLQL <>  '1'
			AAdd(aDdPro, AllTrim(SB1->B1_COD) + ' - ' + AllTrim(SB1->B1_DESC) + '*')
			SB1->(dbSkip())
		EndIf
	EndDo
	
	RestArea(aAreaSB1)
	
Return aDdPro
//-----------------------------------------------------------------------------
/*/{Protheus.doc} DvRelGrp
Carrega todos os locais no array  para exibição.
@type User function
@author Cristiane Thomaz Polli
@since 08/07/2016
@version P12.1.7 @Project MAN00000463301_EF_006
@return ${aDdSet}, ${array com os setores ativos}
/*/
//-----------------------------------------------------------------------------
Static Function DvRelGrp(aDdGrp)
	Local aAreaSBM	:= SBM->(GetArea())
	dbSelectArea('SBM')
	dbGotop()
	While !SBM->(Eof())
		If SBM->(FieldPos("BM_MSBLQL")) > 0 .And. SBM->BM_MSBLQL <>  '1'
			AAdd(aDdSet,SBM->BM_GRUPO + ' - ' + Alltrim(SBM->BM_DESC) + '*')
		EndIf
		SBM->(dbSkip())
	EndDo
	RestArea(aAreaSBM)
Return aDdSet
