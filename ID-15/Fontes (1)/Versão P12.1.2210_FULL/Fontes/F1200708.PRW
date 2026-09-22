#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} F1200708
Prepara Medição.
@author 	Paulo Krüger
@since 		19/08/2017
@version 	P12.7
@Project    MAN0000007423046
@Param		aListMedic, Contratos selecionados
@Return		Nil
/*/
 
User Function F1200708()

Local 	nI			:=	0
Local	nItemMed	:=	0
Local	nPos		:=	0
Local 	cRefer		:=	''
Local	cId			:=	''
Local 	aCabec		:=	{}
Local 	aAllCab		:=	{}
Local	aItGCT		:=	{}
Local	aItsGCT		:=	{}
Local 	nDesFin		:=	0
 
Private nMedicaoFS

If !Empty(aListMedic) 
	ASort(aListMedic,,, { |x, y| x[24] < y[24] })
	cRefer :=	aListMedic[01][24]
	For nI := 01 To Len(aListMedic)
		nMedicaoFS := nI
		nPos := Ascan(aItsGCT,{|x| x[3,2] == aListMedic[nI][09]}) //Verifica duplicidade de produtos em medições/pedidos de compra
		
		nDesFin := RetDesFin(aListMedic[nI][19],aListMedic[nI][01],aListMedic[nI][02], aListMedic[nI][06], aListMedic[01][05],aListMedic[nI][07], aListMedic[nI][09])
		
		If nPos > 0
			nI := nI - 01
			nMedicaoFS := nI
			AAdd(aCabec, {'CND_FILCTR'	, aListMedic[nI][19]	, Nil})
			AAdd(aCabec, {'CND_CONTRA'	, aListMedic[nI][01]	, Nil})
			AAdd(aCabec, {'CND_REVISA'	, aListMedic[nI][02]	, Nil})
			AAdd(aCabec, {'CND_COMPET'	, aListMedic[nI][04]	, Nil})
			AAdd(aCabec, {'CND_NUMERO'	, aListMedic[nI][05]	, Nil})
			AAdd(aCabec, {'CND_FORNEC'	, aListMedic[nI][06]	, Nil})
			AAdd(aCabec, {'CND_LJFORN'	, aListMedic[nI][07]	, Nil})
			AAdd(aCabec, {'CND_FILIAL'	, aListMedic[nI][08]	, Nil})
			AAdd(aCabec, {'CND_PARCEL'	, ''					, Nil})
			AAdd(aCabec, {'CND_NUMMED'	,CriaVar('CND_NUMMED')  , Nil})
			AAdd(aAllCab, aCabec) 
			nItemMed := 0
			aCabec	:= {}
			//cId	:= aListMedic[nI][18] 
			U_F1200709(aAllCab,aItsGCT,aId,aListMedic[nI][01],aListMedic[nI][02],aListMedic[nI][08])
			aAllCab := {}
			aItsGCT := {}
			cRefer	:=	aListMedic[nI + 01][24]
			nPos	:= 0
		Else
			If nI == Len(aListMedic) .and. aListMedic[nI][24] == cRefer 
			
				cFilOld := cFilAnt
				cFilAnt := aListMedic[nI][08]
				
				nItemMed += 01 
				AAdd(aItGCT,{"CNE_FILIAL"	, aListMedic[nI][08]	, Nil})
				AAdd(aItGCT,{"CNE_ITEM"		, StrZero(nItemMed,03)	, Nil})
				AAdd(aItGCT,{"CNE_PRODUT"	, aListMedic[nI][09]	, Nil})
				AAdd(aItGCT,{"CNE_QUANT"	, aListMedic[nI][10]	, Nil})
				AAdd(aItGCT,{"CNE_VLUNIT"	, aListMedic[nI][11]	, Nil})
				AAdd(aItGCT,{"CNE_DTENT"	, dDataBase				, Nil})
				AAdd(aItGCT,{"CNE_CC"		, aListMedic[nI][14]	, Nil})   
				AAdd(aItGCT,{"CNE_CONTA"	, aListMedic[nI][15]	, Nil})
				AAdd(aItGCT,{"CNE_ITEMCT"	, aListMedic[nI][16]	, Nil})
				AAdd(aItGCT,{"CNE_CLVL"		, aListMedic[nI][17]	, Nil})
				AAdd(aItGCT,{"CNE_XDESFI"	, nDesFin				, Nil})
				AAdd(aItGCT,{"CNE_XNUMSC"	, aListMedic[nI][27]	, Nil})
				AAdd(aItGCT,{"CNE_XITSC"	, aListMedic[nI][28]	, Nil})
				AAdd(aItsGCT,aItGCT)
				aItGCT := {}
				AAdd(aId,aListMedic[nI][18])
				AAdd(aCabec, {'CND_FILCTR'	, aListMedic[nI][19]	, Nil})
				AAdd(aCabec, {'CND_CONTRA'	, aListMedic[nI][01]	, Nil})
				AAdd(aCabec, {'CND_REVISA'	, aListMedic[nI][02]	, Nil})
				AAdd(aCabec, {'CND_COMPET'	, aListMedic[nI][04]	, Nil})
				AAdd(aCabec, {'CND_NUMERO'	, aListMedic[nI][05]	, Nil})
				AAdd(aCabec, {'CND_FORNEC'	, aListMedic[nI][06]	, Nil})
				AAdd(aCabec, {'CND_LJFORN'	, aListMedic[nI][07]	, Nil})
				AAdd(aCabec, {'CND_FILIAL'	, aListMedic[nI][08]	, Nil})
				AAdd(aCabec, {'CND_PARCEL'	, ''					, Nil})
				AAdd(aCabec, {'CND_NUMMED'	,CriaVar('CND_NUMMED')  , Nil})
				AAdd(aAllCab, aCabec) 
				nItemMed := 0
				aCabec	 := {}
				
				U_F1200709(aAllCab,aItsGCT,aId,aListMedic[nI][01],aListMedic[nI][02],aListMedic[nI][08])

				aAllCab := {}
				aItsGCT := {}
				cRefer	:=	aListMedic[nI][24]
				
				cFilAnt := cFilOld
				
			ElseIf nI < Len(aListMedic) .and. aListMedic[nI][24] == cRefer 	
				nItemMed += 01 
				AAdd(aItGCT,{"CNE_FILIAL"	, aListMedic[nI][08]	, Nil})
				AAdd(aItGCT,{"CNE_ITEM"		, StrZero(nItemMed,03)	, Nil})
				AAdd(aItGCT,{"CNE_PRODUT"	, aListMedic[nI][09]	, Nil})
				AAdd(aItGCT,{"CNE_QUANT"	, aListMedic[nI][10]	, Nil})
				AAdd(aItGCT,{"CNE_VLUNIT"	, aListMedic[nI][11]	, Nil})
				AAdd(aItGCT,{"CNE_DTENT"	, dDataBase				, Nil})
				AAdd(aItGCT,{"CNE_CC"		, aListMedic[nI][14]	, Nil})   
				AAdd(aItGCT,{"CNE_CONTA"	, aListMedic[nI][15]	, Nil})
				AAdd(aItGCT,{"CNE_ITEMCT"	, aListMedic[nI][16]	, Nil})
				AAdd(aItGCT,{"CNE_CLVL"		, aListMedic[nI][17]	, Nil})
				AAdd(aItGCT,{"CNE_XDESFI"	, nDesFin				, Nil})
				AAdd(aItGCT,{"CNE_XNUMSC"	, aListMedic[nI][27]	, Nil})
				AAdd(aItGCT,{"CNE_XITSC"	, aListMedic[nI][28]	, Nil})
				AAdd(aItsGCT,aItGCT)
				aItGCT := {}
				AAdd(aId,aListMedic[nI][18])

			ElseIf nI <= Len(aListMedic) .and. aListMedic[nI][24] <> cRefer
				nI := nI - 01
				nMedicaoFS := nI
				AAdd(aCabec, {'CND_FILCTR'	, aListMedic[nI][19]	, Nil})
				AAdd(aCabec, {'CND_CONTRA'	, aListMedic[nI][01]	, Nil})
				AAdd(aCabec, {'CND_REVISA'	, aListMedic[nI][02]	, Nil})
				AAdd(aCabec, {'CND_COMPET'	, aListMedic[nI][22]	, Nil})
				AAdd(aCabec, {'CND_NUMERO'	, aListMedic[nI][05]	, Nil})
				AAdd(aCabec, {'CND_FORNEC'	, aListMedic[nI][06]	, Nil})
				AAdd(aCabec, {'CND_LJFORN'	, aListMedic[nI][07]	, Nil})
				AAdd(aCabec, {'CND_FILIAL'	, aListMedic[nI][08]	, Nil})
				AAdd(aCabec, {'CND_PARCEL'	, ''					, Nil})
				AAdd(aCabec, {'CND_NUMMED'	,CriaVar('CND_NUMMED')  , Nil})
				AAdd(aAllCab, aCabec) 
				nItemMed := 0
				aCabec	:= {}
				cId	:= aListMedic[nI][18]

				U_F1200709(aAllCab,aItsGCT,aId,aListMedic[nI][01],aListMedic[nI][02],aListMedic[nI][08])
				aAllCab := {}
				aItsGCT := {}
				cRefer	:=	aListMedic[nI + 01][24]
				
			EndIf
			
		EndIf
	Next nI
EndIf
Return

Static Function RetDesFin(cFilCtr, cNumCtr, cRevCtr, cForne, cNumCNA, cLoja, cProduto)
Local aAreaCNA	:= CNA->(GetArea())
Local aAreaAIB	:= AIB->(GetArea())
Local nRet	:= 0

CNA->(DbSetOrder(1))
AIB->(DbSetOrder(2))

If CNA->(DbSeek(cFilCtr + cNumCtr + cRevCtr + cNumCNA))
	If AIB->(DbSeek(CNA->CNA_FILIAL + CNA->CNA_FORNEC + CNA->CNA_LJFORN + CNA->CNA_XTABPC + cProduto ))
		nRet := AIB->AIB_XDESFI
	EndIf
EndIf

RestArea(aAreaCNA)
RestArea(aAreaAIB)
Return nRet
