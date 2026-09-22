#include "protheus.ch"
#include "fileio.ch"
#INCLUDE "TopConn.ch"

/*/{Protheus.doc} F430BXA
Validações da baixa do título e conciliação automática via schedule

@author  Ramon Teodoro / Lucas Aguiar
@Projeto Schedule de Retorno de pagamento + Conciliação automática de títulos processados via schedule
@since   24/06/2021
/*/
User Function F430BXA()

	Local aArea := GetArea()
	Local cQuery := ""
	Local cAliasTmp := GetNextAlias()
	Local _lSchdl  := IsInCallStack("U_XFINA435")
	Local cUsrAlt  := UsrFullName(__cuserid)
	Local lRet := .T. //Thais Paiva - 13275758

	lRet := U__RetStatic()

	//If IsInCallStack("U_XFINA435")
	If _lSchdl
		If (SE2->E2_SALDO == 0 .And. SE2->E2_BAIXA == dBaixa)

			If (SE2->(E2_MULTA+E2_JUROS+E2_ACRESC+E2_DESCONT+E2_DECRESC)) == 0 
				cQuery := " SELECT R_E_C_N_O_ AS RECNO FROM  " + RetSqlName("SE5")
				cQuery += " WHERE D_E_L_E_T_ = ' ' "
				cQuery += " AND E5_FILIAL||E5_PREFIXO||E5_NUMERO||E5_PARCELA||E5_TIPO||E5_CLIFOR||E5_LOJA = '"
				cQuery += xFilial("SE5")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA) + "'"
				//cQuery += " AND E5_DTCANBX = ' '"
				cQuery += " AND E5_SITUACA <> 'C'"
				cQuery += " AND E5_TIPODOC NOT IN ('ES','E2','EC','TE','VA')"
				cQuery += " ORDER BY R_E_C_N_O_ DESC "
			Else
				cQuery := " SELECT R_E_C_N_O_ AS RECNO FROM  " + RetSqlName("SE5")
				cQuery += " WHERE D_E_L_E_T_ = ' ' "
				cQuery += " AND E5_FILIAL||E5_PREFIXO||E5_NUMERO||E5_PARCELA||E5_TIPO||E5_CLIFOR||E5_LOJA = '"
				cQuery += xFilial("SE5")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA) + "'"
				//cQuery += " AND E5_DTCANBX = ' '"
				cQuery += " AND E5_SITUACA <> 'C'"
				cQuery += " AND E5_TIPODOC NOT IN ('ES','E2','EC','TE','VA')"
				cQuery += " AND (E5_VLJUROS <> 0 OR E5_VLMULTA <> 0 OR E5_VLDESCO <> 0) ORDER BY R_E_C_N_O_ DESC"
			EndIf

			If Select( cAliasTmp ) > 0
				( cAliasTmp )->( DbCloseArea() )
			EndIf

			TcQuery cQuery Alias ( cAliasTmp ) New

			If ( cAliasTmp )->(!EOF())
				U_F2000310({{( cAliasTmp )->RECNO,.T.,NIL,NIL}})
			EndIf
			( cAliasTmp )->( DbCloseArea() )
		Elseif Empty(SE2->E2_BAIXA) .And. !Empty(SE2->E2_NUM)
			Aadd(aMsgSch, "O título número: " + SE2->E2_NUM + " com ID CNAB número: " + AllTrim(cnumtit) + " não foi baixado na filial " + AllTrim(FWFilialName()))
			lRet := .F. //Thais Paiva - 13275758
		EndIf
	EndIf
	RestArea(aArea)
	
	If !_lSchdl
		If FunName() == 'FINA430'
			If Empty(SE5->E5_XLOGMOV)
				RecLock("SE5", .F. )
				SE5->E5_XLOGMOV  := cUsrAlt
				SE5->E5_XHORMOV  := TIME() 
				SE5->E5_XDATMOV  := DATE() 

				MsUnlock()
			EndIf 
		EndIf
	Endif   
	
	//Início Thais Paiva - 13275758
	If lRet
		U_FSPE0012()
	EndIf
	//Fim Thais Paiva - 13275758

Return

