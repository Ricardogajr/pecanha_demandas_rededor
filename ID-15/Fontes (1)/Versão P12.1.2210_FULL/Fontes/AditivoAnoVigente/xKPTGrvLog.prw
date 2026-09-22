#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDef.ch"

/*/{Protheus.doc} xKPTGrvLog
Faz a gravação das integrações com a Onergy 
@type function
@author Joalisson Laurentino
@since 12/06/2021
/*/

User Function xKPTGrvLog(lActiveLog,cFilOri,cId,cRotina,cIDOnergy,cOrigem,cDestino,cRequest,cResponse,cStatus,dDtProc,cHrProc,cCallBack)
	Local lRet		  := .F. 
	Local lExist	  := .F. 

	Default cStatus	  := "1"
	Default cId		  := ""
	Default cFilOri	  := ""
	Default cOrigem	  := ""
	Default cDestino  := ""
	Default cRotina	  := ""
	Default cIDOnergy := ""
	Default cRequest  := ""
	Default cResponse := ""
	Default dDtProc	  := CToD("")
	Default cHrProc	  := ""
	Default cCallBack := ""
	
	lExist := SeekZKT(cFilOri,cId,cIDOnergy,cRotina,cCallBack)

	If !lExist
		RecLock('ZKT',.T.)
			ZKT->ZKT_FILORI := cFilOri
			ZKT->ZKT_ID     := cId
			ZKT->ZKT_ROTINA := cRotina
			ZKT->ZKT_ONERGY := cIDOnergy
			ZKT->ZKT_ORIGEM := cOrigem
			ZKT->ZKT_DESTIN := cDestino
			ZKT->ZKT_JSON   := cRequest
			ZKT->ZKT_RETURN := cResponse
			ZKT->ZKT_DTIMP  := dDatabase
			ZKT->ZKT_HRIMP  := Substr(Time(),1,5)
			ZKT->ZKT_DTPROC := dDtProc
			ZKT->ZKT_HRPROC := cHrProc
			ZKT->ZKT_STATUS := cStatus
			//nRecnoZKT		:= ZKT->(Recno())
		ZKT->(MsUnlock())
	EndIf
	
Return(lRet)

Static Function SeekZKT(cFilOri,cId,cIDOnergy,cRotina,cCallBack)
	Local cAliasQry	:= ""
	Local cQuery 	:= ""
	Local lRet 		:= .F.

	Default cRotina	  := ""

	cQuery := " SELECT COUNT(*) OVER (PARTITION BY ' ') TOTREG,R_E_C_N_O_ RECNO, ZKT_STATUS"
	cQuery += " FROM " + RetSQLName("ZKT") + " ZKT "
	cQuery += " WHERE D_E_L_E_T_ = ''"
	cQuery += " AND ZKT_FILORI 	= '"+ cFilOri +"'"
	cQuery += " AND ZKT_ID	 	= '"+ cId +"'"
	cQuery += " AND ZKT_ONERGY	= '"+ cIDOnergy +"'"
	cQuery += " AND ZKT_STATUS	IN ('1','2')"

	cAliasQry := MPSysOpenQuery(ChangeQuery(cQuery))
	
	If (cAliasQry)->TOTREG > 0 .AND. !Empty(cCallBack)
		lRet := .T.

		If (cAliasQry)->ZKT_STATUS = '2'
			oData := JsonObject():New()
			oData["tenantId"] := cFilOri
			oData["id"]		  := cId
			oData["rotina"]	  := cRotina
			oData["msg"]	  := "DUPLICADO! Este ID Onergy já foi importado e finalizado com sucesso!"
			cPostParams := EncodeUTF8(oData:ToJson())
			
			U_xKPTFWRest("POST",cCallBack/*cUrl*/,/*cSetPath*/,cPostParams,/*aHeader*/,.T./*lCallBack*/,cIDOnergy)
		EndIf
	EndIf 
	(cAliasQry)->(DBCloseArea())

Return( lRet )
