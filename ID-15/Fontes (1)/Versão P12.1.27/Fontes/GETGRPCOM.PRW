#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} GetGrpCom
Programa para Buscar o Grupo de COmpras da Solicitação de Compras.
@type function
@author Ricardo Junior
@since 14/09/2017
@version 1.0
@return NIL
/*/

*-----------------------------------------------*
User Function GetGrpCom(cFil, cItemSc, cNumSc)
*-----------------------------------------------*
	Local aArea 		:= GetArea()
	Local cGrp  		:= ""
	Local cGrupCom		:= ""	
	Local cGrpPadrao 	:= GetMv("MV_PCAPROV")
	
	DbSelectArea("SC1")
	DbSetOrder(01)
	U_WsLogBio("GetGrpCom", 2, "SOLICITACAO " + PadR(cFil, TamSx3("C1_FILIAL")[1]) + PadR(cNumSc, TamSx3("C1_NUM")[1]) + PadR(cItemSc, TamSx3("C1_ITEM")[1]))
	If SC1->(DbSeek(PadR(cFil, TamSx3("C1_FILIAL")[1]) + PadR(cNumSc, TamSx3("C1_NUM")[1]) + PadR(cItemSc, TamSx3("C1_ITEM")[1]))) 
		cComprador := SC1->C1_XCPBIO
		cGrupCom   := SC1->C1_GRUPCOM
		U_WsLogBio("GetGrpCom", 2, "COMPRADOR " + cComprador)
		DbSelectArea("SY1")
		SY1->(DbSetOrder(01))
		If SY1->(DbSeek(PadR(cFil, TamSx3("Y1_FILIAL")[1]) + PadR(cComprador, TamSx3("Y1_USER")[1])))			
			cGrp := SY1->Y1_GRAPROV
			U_WsLogBio("GetGrpCom", 2, "GRUPO DE COMPRAS " + cGrp)
		EndIf						
	Else
		cGrp := cGrpPadrao	
		U_WsLogBio("GetGrpCom", 2, "GRUPO PADRAO ")
	EndIf
	RestArea(aArea)
Return { cGrp, cGrupCom }