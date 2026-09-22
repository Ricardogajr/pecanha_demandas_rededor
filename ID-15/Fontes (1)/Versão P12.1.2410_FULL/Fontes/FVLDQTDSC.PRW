#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} fVldQtdSC
Validação para que nao deixe o usuário aumentar a quantidade do item do pedido que veio de uma solicitação de compras.
@type function
@author Ricardo Junior	
@since 07/02/2018
@version 1.0
@return lRet .T. valido, .F. não valido.
/*/
*----------------------------*
User Function fVldQtdSC()
*----------------------------*
	Local aArea := GetArea()
	Local lRet  := .T.
	Local cNum  := M->C7_NUMSC
	
	nPosSC 	:= aScan(aHeader, {|x| AllTrim(x[2]) == "C7_NUMSC"})	
	nPosIt 	:= aScan(aHeader, {|x| AllTrim(x[2]) == "C7_ITEMSC"})
	nPosQ1 	:= aScan(aHeader, {|x| AllTrim(x[2]) == "C7_QUANT"})
	nPosQ2 	:= aScan(aHeader, {|x| AllTrim(x[2]) == "C7_QTSEGUM"})
	nPosPrc	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRECO"})
	
	DbSelectArea("SC1")
	DbSetOrder(01)
	If DbSeek(xFilial("SC1")+ aCols[n][nPosSC]+aCols[n][nPosIt])
		If SC1->C1_QUANT < aCols[n][nPosQ1] .Or. SC1->C1_QTSEGUM < aCols[n][nPosQ2]
			aCols[n][nPosQ1] := SC1->C1_QUANT
			aCols[n][nPosQ2] := SC1->C1_QTSEGUM
			M->C7_QTSEGUM := SC1->C1_QTSEGUM
			A100SegUm()
			MaFisAlt("IT_QUANT",SC1->C1_QUANT,n)
			MaFisAlt("IT_VALMERC",NoRound(aCols[n][nPosPrc]*aCols[n][nPosQ1],TamSx3("C7_TOTAL")[2]),n)
			GetdRefresh()
		  	Alert("Quantidade do pedido não pode ser maior que da solicitação de compras")
			lRet := .F.			
		EndIf									
	EndIf
	
	RestArea(aArea)
Return lRet 