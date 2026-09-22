#Include 'Protheus.ch'
#INCLUDE "APWEBSRV.CH"
#INCLUDE 'FWMVCDEF.CH'

#DEFINE PAGE_LENGTH 10
/*
{Protheus.doc} F0200326
WebService de Acompnhamento
@Author     Henrique Toyoda
@Since      07/10/2016
@Version    P12.7
@Project    MAN00000462901_EF_002
*/
User Function F0200326()
Return
//===========================================================================================================
WsStruct acompanha
	WsData codacom As String
	WsData seracom As String
	WsData datacom As String
	WsData staacom As String
	WsData stsbcom As String
	WsData matacom As String
	WsData nomacom As String
	WsData apracom As String
EndWsStruct
//===========================================================================================================
WsStruct _acompanha
	WsData registro As Array Of acompanha
	WSDATA PagesTotal     AS Integer
EndWsStruct

//===========================================================================================================

WSSERVICE W0200302 DESCRIPTION "WebService Server responsavel pelo acompanhamento"

	WSDATA Assunto    AS String
	WSDATA FILIFUN    AS String
	WSDATA Matricu    AS String
	WSDATA lRet       AS Boolean
	WSDATA DtIni      AS String   OPTIONAL
	WSDATA DtFim      AS String   OPTIONAL
	WSDATA Mat        AS String   OPTIONAL
	WSDATA Status     AS String   OPTIONAL
	WSDATA Servico    AS String   OPTIONAL
	//WSDATA Matricu    AS String
	WSDATA FilGes     AS String
	WSDATA Codigo     AS String
	WSDATA PAGE             AS INTEGER
	WSDATA _ACOM      AS _acompanha

	WSMETHOD BuscaMat         DESCRIPTION "Busca matricula"
	WSMETHOD BuscaRH3         DESCRIPTION "Busca RH3"

ENDWSSERVICE

//===========================================================================================================

WSMETHOD BuscaMat WSRECEIVE Matricu,FILIFUN WSSEND lRet WSSERVICE W0200302

	RCX->(DbSetOrder(4))
	If RCX->(DbSeek(xFilial("RCX") + ::FILIFUN  + ::Matricu))
		::lRet := .T.
	Else
		::lRet := .F.
	End

Return .T.

//===========================================================================================================

WSMETHOD BuscaRH3 WSRECEIVE FilGes, Matricu,DtIni, DtFim, Mat,Status, Servico, Codigo, PAGE WSSEND _ACOM WSSERVICE W0200302

	Local cMatFun := "'"
	Local cFilFun := "'"
	Local aAux 	:= {}
	Local aFun    := {}
	Local nX		:= 1
	Local nI      := 1
	Local nPosIni := 1
	Local nCnt    := 0
	Local oSolVg  := Nil
	
	DEFAULT Self:Page   := 1

	aFun := U_F0500198(::FilGes, ::Matricu)

	For nCnt := 1 To Len(aFun)
		If nCnt < Len(aFun)
			cMatFun += aFun[nCnt][4] + "' , '"
			cFilFun += aFun[nCnt][3] + "' , '"
		Else
			cMatFun += aFun[nCnt][4]
			cFilFun += aFun[nCnt][3]
		EndIf
	Next nCnt

	cMatFun += "'"
	cFilFun += "'"

	aAux := RetSolic(cFilFun, cMatFun, ::FilGes, ::Matricu, ::Servico, ::DtIni, ::DtFim, ::Mat, ::Status, ::Codigo )

	If Len(aAux) > 0

		::_ACOM := WSClassNew( "_acompanha" )
		::_ACOM:PagesTotal := Ceiling(Len(aAux) / PAGE_LENGTH)
		::_ACOM:registro := {}
		
		If ::Page > 1
			nPosIni := ((Self:Page-1) * PAGE_LENGTH) + 1
		EndIf

		oSolVg :=  WSClassNew( "acompanha" )
		For nX := nPosIni To Len(aAux)
			oSolVg:codacom := aAux[nX][1]
			oSolVg:seracom := aAux[nX][2]
			oSolVg:datacom := cValToChar(aAux[nX][3])
			oSolVg:staacom := aAux[nX][4]
			oSolVg:matacom := aAux[nX][5]
			oSolVg:nomacom := aAux[nX][6]
			oSolVg:apracom := aAux[nX][7]
			oSolVg:stsbcom := aAux[nX][8]

			AAdd( ::_ACOM:registro, oSolVg )
			oSolVg :=  WSClassNew( "acompanha" )
			
			If len(::_ACOM:registro) >= PAGE_LENGTH
				Exit
			EndIf
		Next
	Else

		::_ACOM := WSClassNew( "_acompanha" )
		::_ACOM:PagesTotal := 1
		::_ACOM:registro := {}
		oSolVg :=  WSClassNew( "acompanha" )
		oSolVg:codacom := ""
		oSolVg:seracom := ""
		oSolVg:datacom := ""
		oSolVg:staacom := ""
		oSolVg:matacom := ""
		oSolVg:nomacom := ""
		oSolVg:apracom := ""
		oSolVg:stsbcom := ""
		AAdd( ::_ACOM:registro, oSolVg )
	EndIf

Return .T.
//===========================================================================================================
/*/{Protheus.doc} RetAprov
Retorna aprovador(es)
@type function
@author henrique.toyada
@since 04/11/2016
@project MAN00000463301_EF_003
@version 1.0
@param cFilSra, filial aprovador
@param cMatriSra, Matricula aprovador
@return aAux, informação do aprovador
/*/
Static Function RetAprov(cFilSol, cCodSol, cNivSol)

	Local cAliPAL := "RETPAL"
	Local cNome   := ""
	Local cQuery  := ""

	cQuery := "SELECT DISTINCT  "
	cQuery += "       SRA.RA_MAT, "
	cQuery += "       SRA.RA_NOME "
	cQuery += "FROM " + RetSqlName("PAL") + " PAL "
	cQuery += "INNER JOIN " + RetSqlName("SRA") + " SRA  "
	cQuery += "ON SRA.RA_MAT = PAL.PAL_MATAPR "
	cQuery += "AND SRA.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE PAL.PAL_NUMSOL = '" + cCodSol + "' "
	cQuery += "  AND PAL.PAL_FILSOL = '" + cFilSol + "' "		
	cQuery += "  AND PAL.PAL_NIVSOL = '" + PADL(cValToChar(cNivSol),2,"0") + " ' "
	cQuery += "  AND PAL.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliPAL)

	DbSelectArea(cAliPAL)
	While ! (cAliPAL)->(EOF())
		If Empty(cNome) 
			cNome  += "" + (cAliPAL)->(RA_NOME) + ""
		Else
			cNome  += "," + (cAliPAL)->(RA_NOME) + ""
		EndIf
		(cAliPAL)->(DbSkip())
	End
	(cAliPAL)->(DbCloseArea())

Return cNome
//===========================================================================================================
/*/{Protheus.doc} RetSolic
Retorna solicitações 
@type function
@author henrique.toyada
@since 04/11/2016
@project MAN00000463301_EF_003
@version 1.0
@param cFilFun, filial pessoa logada
@param cMatFun, Matricula pessoa logada
@param cFilGes, filial aprova
@param cMatricu, matricula aprovador
@param cServico, tipo da solicitação
@param cDtIni, data inicial
@param cDtFim, data final 
@param cMat, matricula pesquisada
@param cStatus, status da solicitação
@return aAux, Solicitações
/*/
Static Function RetSolic(cFilFun, cMatFun, cFilGes, cMatricu, cServico, cDtIni, cDtFim, cMat, cStatus, cCodigo )

	Local cAliasSra  := "RETSRA"
	Local cPosto  := ""
	Local cMatri  := ""
	Local cNome   := ""
	Local cQuery  := ""
	Local cAprov  := ""
	Local aAux    := {}
	Local cStat   := ""

	cQuery := "SELECT	RH3_FILIAL, RH3_CODIGO, RH3_MAT, RH3_DTSOLI, RH3_STATUS, RH3_FILINI, RH3_XPRXNV, "
	cQuery += "		RH3_MATINI, RH3_FILAPR, RH3_MATAPR, RH3_TIPO, RH3_XTPCTM, PAB_SOLDES, SQS.QS_XSTATUS, "
	cQuery += "		RH3.RH3_XFILAP, RH3.RH3_XMATAP, RH3.RH3_XCODAL, RH3.RH3_NVLAPR, RH3.RH3_XLIBPT "
	cQuery += "FROM " + RetSqlName("RH3") + " RH3 "
	cQuery += "RIGHT JOIN " + RetSqlName("PAB") + " PAB     "
	cQuery += "	ON PAB.PAB_FILIAL = '" + XFILIAL("PAB") + "'  "
	cQuery += "	AND PAB.PAB_CODIGO = RH3.RH3_XCODAL  "
	cQuery += "	AND  PAB.D_E_L_E_T_ = ' ' "
	cQuery += "LEFT JOIN " + RetSqlName("SQS") + " SQS "
	cQuery += "   ON SQS.QS_XSOLFIL = RH3.RH3_FILIAL "
	cQuery += "   AND SQS.QS_XSOLPTL = RH3.RH3_CODIGO "
	cQuery += "   AND  SQS.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE RH3.RH3_FILINI = '" + cFilGes + "' AND RH3.RH3_MATINI = '" + cMatricu + "' AND "
	If empty(cServico) .AND. empty(cDtIni) .AND. empty(cDtFim) .AND. empty(cStatus) .AND. empty(cCodigo) .AND. empty(cMat)
		cQuery += " RH3.RH3_XTPCTM != ' ' AND "
		cQuery += " RH3.RH3_TIPO = ' ' AND "
		cQuery += "	(((RH3.RH3_STATUS = '2' OR RH3.RH3_STATUS = '3') AND RH3.RH3_DTSOLI BETWEEN '" + DTOS(YearSub(ddatabase,1)) + "' AND '" + DTOS(ddatabase) + "') OR "
		cQuery += "	(RH3.RH3_STATUS != '2' AND RH3.RH3_STATUS != '3')) AND "
	Else
		If !(empty(cServico)) .AND. cServico != '9'
			cQuery += " RH3.RH3_XTPCTM != ' ' AND RH3.RH3_XTPCTM = '" + cServico + "' AND "
		Else
			cQuery += " RH3.RH3_XTPCTM != ' ' AND "
		EndIf
		cQuery += " RH3.RH3_TIPO = ' ' AND "
		If !(empty(cDtIni)) .AND. !(empty(cDtFim))
			cQuery += "   RH3.RH3_DTSOLI BETWEEN '" + cDtIni + "' AND '" + cDtFim + "' AND "
		EndIf
		If !(empty(cDtIni)) .AND. empty(cDtFim)
			cQuery += "   RH3.RH3_DTSOLI >= '" + cDtIni + "' AND "
		EndIf
		If !(empty(cDtFim)) .AND. empty(cDtIni)
			cQuery += "   RH3.RH3_DTSOLI <= '" + cDtFim + "' AND "
		EndIf
		If !(empty(cMat))
			cQuery += "	RH3.RH3_MAT = '" + cMat + "' AND "
		EndIf
		If !(empty(cStatus)) .AND. cStatus != '9'
			If cStatus == '5'
				cQuery += "	RH3.RH3_STATUS = '4' AND RH3.RH3_XLIBPT = '1' AND "
			Else
				cQuery += "	RH3.RH3_STATUS LIKE '%" + cStatus + "%' AND "
			EndIf
		EndIf
		If !(empty(cCodigo))
			cQuery += "	RH3.RH3_CODIGO = '" + cCodigo + "' AND "
		EndIf
	EndIf
	
	cQuery += "		RH3.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY RH3.RH3_CODIGO "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSra)

	DbSelectArea(cAliasSra)

	While ! (cAliasSra)->(EOF())
		If (cAliasSra)->RH3_STATUS == "3"
			SRA->(DbSetOrder(1))
			SRA->(DbSeek(ALLTRIM(ALLTRIM((cAliasSra)->RH3_XFILAP) + (cAliasSra)->RH3_XMATAP)))
			cAprov := SRA->RA_NOME
		ElseIf (cAliasSra)->RH3_STATUS == "4"
			cAprov := " "
		Else
			cAprov := RetAprov((cAliasSra)->RH3_FILIAL, (cAliasSra)->RH3_CODIGO, (cAliasSra)->RH3_NVLAPR)
		EndIf
		
		If (cAliasSra)->RH3_STATUS == "4" .AND. (cAliasSra)->RH3_XLIBPT == "1"
			cStat := "5"
		Else
			cStat := (cAliasSra)->RH3_STATUS
		EndIf
		
		AADD(aAux, {(cAliasSra)->RH3_CODIGO,;
		(cAliasSra)->PAB_SOLDES,;
		STOD((cAliasSra)->RH3_DTSOLI),;
		cStat,;
		IIF(AllTrim((cAliasSra)->RH3_XTPCTM) $ "004|002|003" , " ", (cAliasSra)->RH3_MAT),;
		IIF(AllTrim((cAliasSra)->RH3_XTPCTM) $ "004|002|003" , " ", POSICIONE("SRA",1,(cAliasSra)->RH3_FILIAL + (cAliasSra)->RH3_MAT,"RA_NOME")),;
		cAprov,;
		U_F0200327((cAliasSra)->QS_XSTATUS) })

		(cAliasSra)->(DbSkip())
	EndDo

	(cAliasSra)->(DbCloseArea())

Return aAux