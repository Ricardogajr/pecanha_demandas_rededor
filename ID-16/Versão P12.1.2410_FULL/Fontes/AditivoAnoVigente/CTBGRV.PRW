#Include "Protheus.ch"
#Include "Tbiconn.ch"
#INCLUDE "TopConn.ch"
#Include "Totvs.ch"


/*{Protheus.doc} CTBGRV
Ponto de entrada para mudar o campo de chave unica da CT2 nas devoluções de mês fechado.

@author Lucas Miranda de Aguiar
@since  26/01/2022
@param aParm
@version P12.1.7
@return Nil  
*/

User Function CTBGRV()

	Local aArea := GetArea()
	Local aAreaCT2 := CT2->(GetArea())
	Local cQuery := ""
	Local cAliasCT2 := GetNextAlias()
	Local cMaxSeq := ""

	If IsIncallStack("U_F1303701")

		CT2->CT2_SEQIDX := "000000"

		cQuery := " SELECT MAX(CT2_SEQIDX) AS MAXIMO FROM " +RETSQLNAME("CT2") + " CT2 WHERE "
		cQuery += " D_E_L_E_T_ = ' ' AND CT2_FILIAL = '"+CT2->CT2_FILIAL+"'"

		If Select( cAliasCT2 ) > 0
			( cAliasCT2 )->( DbCloseArea() )
		EndIf

		TcQuery cQuery Alias ( cAliasCT2 ) New

		If !( cAliasCT2 )->( Eof() )
			cMaxSeq := (cAliasCT2)->MAXIMO
		EndIf

		If Empty(AllTrim(cMaxSeq))
			cMaxSeq := "00001"
		Else
			cMaxSeq := Soma1(cMaxSeq)
		EndIf

		CT2->CT2_SEQIDX := cMaxSeq

		( cAliasCT2 )->( DbCloseArea() )
	EndIf

    If IsIncallStack("U_F2000401") // Melhoria para incluir o código do XRT nos lançamentos bancários também.
		If Empty(CT2->CT2_XCDXRT) 
			CT2->CT2_XCDXRT := AllTrim(SE5->E5_XCODXRT)
		EndIf 
			CT2->CT2_XPCXRT := SE5->E5_XPCXRT
    EndIf

	RestArea(aArea)
	RestArea(aAreaCT2)
Return
