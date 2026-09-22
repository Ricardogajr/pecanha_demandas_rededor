#Include "Protheus.ch"

/*/{Protheus.doc} FLUIGP20
Rotina que realiza a busca de mensagens com erro na P20

@project
@type       User Function
@author     Lucas Miranda
@since      27/11/2019
@version    1.0.0
@return     Nil
/*/
User Function FLUIGP20(cEmpCon,cFilCon,cData,cScrNum)

	Local aArea := GetArea()
	Local cQuery  := ""
	Local cAliasQry := ""
	Local cIndkey := ""
	Local lEnviou := .F.
	Local lOk	  := .T.

	Default cEmpCon := "01"
	Default cFilCon := "01010004"
	Default cData   := ""
	Default cScrNum     := ""

	If !(Select("SX2") > 0)
		RpcSetEnv("01", cFilCon)
		If !(Select("SX2") > 0)
			lOk         := .F.
			Conout("Erro na abertura de ambiente em JOB")
		EndIf
	EndIf

	If AllTrim(cData) == ""
		cData := SuperGetMv("MV_DTFLUIG", .F., Date())
	EndIf
	
	cData := DtoS(cData)
	If lOk
		cQuery := " SELECT P20_FILIAL, P20_STATUS, P20_ID, P20_INDKEY "
		cQuery += " FROM " + RetSQLName("P20") + " P20"
		cQuery += " WHERE D_E_L_E_T_ = ' ' "
		cQuery += " AND P20_STATUS = '1' "
		If cScrNum != ""
			cQuery += " AND P20_ROTINA = 'U_FLUIGP20' " 
			cQuery += " AND P20_INDKEY LIKE " + "'%"+cScrNum+"%'"
		Else	
			//cQuery += " AND P20_INDKEY LIKE '%FLUIG%' "
			cQuery += " AND P20_ROTINA = 'U_FLUIGP20' " 
			cQuery += " AND P20_DTHR >= " + "'"+cData+"'"
		EndIf
		
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		MPSysOpenQuery(cQuery, cAliasQry)

		While !((cAliasQry)->(EoF()))

			cIndkey := (cAliasQry)->P20_INDKEY

			lEnviou := U_FLGREPRO(cEmpCon,cFilCon,cIndkey)
			
				P20->(DbSetOrder(2))
				If P20->(DbSeek((cAliasQry)->P20_FILIAL + (cAliasQry)->P20_ID))
					RecLock("P20", .F.)
					P20->P20_STATUS := "2"
					P20->P20_INDKEY := AllTrim((cAliasQry)->P20_INDKEY) + "|Reprocessado" 
					P20->(MsUnlock()) 
				EndIf
				
				PutMv("MV_DTFLUIG",Date())


			(cAliasQry)->(DbSkip())

		End
	EndIf

	RestArea(aArea)
Return