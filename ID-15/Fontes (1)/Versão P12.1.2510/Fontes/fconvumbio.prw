#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} FConvUmBio
Rotina de Conversão da Unidade de medida conforme a tabela P29.
@type function
@author Ricardo Junior
@since 20/01/2018
@version 1.0
@return Nil
/*/
//B=BIonexo e P=Protheus
*--------------------------------------------------------*
User Function FConvUmBio(cProd, nQtdCons, nPreco, cTipo)
*--------------------------------------------------------*	
	Local aArea := GetArea()
	Local aConv:= {00, 00}//Quant, Preco
	
	Default nPreco := 00
	
	DbSelectArea("P29")
	P29->(DbSetOrder(01))
	If DBSeek(xFilial("P29")+PadR(cProd, TamSx3("P29_COD")[01]))
		aConv := fConv(nQtdCons, nPreco, cTipo)		 					
	Else 	
		aConv := { nQtdCons, nPreco }
	EndIf	
	
	RestArea(aArea)
return aConv
*---------------------------------------------*
Static Function fConv(nQuant, nPreco, cTipo)
*---------------------------------------------*
	aAux := { 00, 00}
	If cTipo == "B"
		aAux[01] := Iif(AllTrim(P29->P29_P12BIO) == "M", nQuant * P29->P29_CONV, nQuant / P29->P29_CONV)
		aAux[02] := Iif(AllTrim(P29->P29_P12BIO) == "M", nPreco / P29->P29_CONV, nPreco * P29->P29_CONV) 			
	Else
		aAux[01] := Iif(AllTrim(P29->P29_BIOP12) == "M", nQuant * P29->P29_CONV, nQuant / P29->P29_CONV)
		aAux[02] := Iif(AllTrim(P29->P29_BIOP12) == "M", nPreco / P29->P29_CONV, nPreco * P29->P29_CONV)
	EndIf
	
Return aAux	