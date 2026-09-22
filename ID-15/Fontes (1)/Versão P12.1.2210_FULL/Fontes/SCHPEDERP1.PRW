#Include "Protheus.ch"
#Include "Tbiconn.ch"
#INCLUDE "TopConn.ch"
#Include "Totvs.ch"

/*{Protheus.doc} SCHEDPEDERP1
JOB de reenvio de pedidos ERP com erro de conexão com o barramento.

@author Lucas Miranda de Aguiar
@since  17/01/2022
@param aParm
@version P12.1.7
@return Nil  
*/
User Function SCHEDPEDERP1(aParam)

	Local aArea := GetArea()
	Local cEmpIni := aParam[1]
	Local cFilIni := aParam[2]
	Local cQuery := ""
	Local cAliasC7 := GetNextAlias()
	Local cGetPed := ""
	Local cGetOper := ""
	Local cFilBkp := ""
	Local nCountPed := 1
	Local nTempoI := Time()
	Local cTotPed := ""

	If !RpcSetEnv(cEmpIni,cFilIni,,,"COM",,{"SC7"})
		Conout("Rotina SCHEDPEDERP1 - Não foi possível realizar o login na filial")
		Return
	EndIf

	Conout("Inicio da schedule de reenvio de pedidos ERP " + Time())
	cFilBkp := cFilAnt
	cQuery := " SELECT C7_FILIAL, C7_XERRPC, COUNT(*) OVER() AS TOTAL_LINHAS FROM " +RETSQLNAME("SC7") + " C7 WHERE "
	cQuery += " C7_XERRPC <>  ' '  GROUP BY C7.C7_FILIAL,C7.C7_XERRPC"

	If Select( cAliasC7 ) > 0
		( cAliasC7 )->( DbCloseArea() )
	EndIf

	TcQuery cQuery Alias ( cAliasC7 ) New
	If !( cAliasC7 )->( Eof() )
	Conout(cValToChar((cAliasC7)->TOTAL_LINHAS) + " pedidos ser�o reprocessados.")
	cTotPed := cValToChar((cAliasC7)->TOTAL_LINHAS)
		While !( cAliasC7 )->( Eof() )
		Conout("Enviando pedido " + cValToChar(nCountPed) + " de " + cValToChar((cAliasC7)->TOTAL_LINHAS) + ". " + Time())
		nCountPed++
			cFilAnt  := ( cAliasC7 )->C7_FILIAL
			cGetPed  := SubStr( ( cAliasC7 )->C7_XERRPC, 1,6    )
			cGetOper := SubStr( ( cAliasC7 )->C7_XERRPC, 7,1    )
			DbSelectArea("SC7")
			DbSetOrder(1)
			U_F07022RE(cGetPed, cGetOper)
			( cAliasC7 )->( DbSkip() )
		EndDo
	Else
		Conout("Rotina SCHEDPEDERP1 - Não há pedidos para reenvio.")
	EndIf

	Conout("Tempo total para o reenvio de "+cTotPed+" pedidos: " + ElapTime(nTempoI,Time()))
	( cAliasC7 )->( DbCloseArea() )
	cFilAnt := cFilBkp
	Conout("Fim do processamento do schedule." + Time())
	RpcClearEnv()
	RestArea(aArea)
Retur
