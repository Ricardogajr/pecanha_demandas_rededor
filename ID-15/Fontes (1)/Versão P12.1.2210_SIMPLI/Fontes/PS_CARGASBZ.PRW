#INCLUDE "Protheus.ch"
/*
{Protheus.doc} CargaSBZ()
Inclui registros na SBZ caso não exista.
@Author     Ricardo Junior
@Since      14/06/2021
*/
User function CargaSBZ(aEmpFil) 
	Local cQuery := ""
	Local cAlias1 := GetNextAlias()
	Local aAreaAtu := GetArea()

	RpcSetType(3)
	RpcSetEnv(aEmpFil[1],aEmpFil[2])

	cQuery += " SELECT * FROM "+ RetSqlName("SB1") +" SB1 " + CRLF
	cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " AND B1_COD NOT IN (SELECT BZ_COD FROM "+ RetSqlName("SBZ") +" SBZ WHERE SBZ.D_E_L_E_T_ = ' ' AND SBZ.BZ_FILIAL = '"+cFilAnt+"')"+ CRLF

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAlias1, .T., .T.)

	While !(cAlias1)->(EOF())
		RecLock("SBZ",.T.)
		SBZ->BZ_FILIAL  := cFilAnt
		SBZ->BZ_COD     := (cAlias1)->B1_COD
		SBZ->BZ_LOCPAD  := (cAlias1)->B1_LOCPAD
		SBZ->BZ_QE      := 0
		SBZ->(MsUnLock())
		(cAlias1)->(DbSkip())
	EndDo
	(cAlias1)->(DbCloseArea())

	RpcClearEnv()
	RestArea(aAreaAtu)
Return
