#Include 'Protheus.ch'
#INCLUDE "APWEBSRV.CH"
#INCLUDE 'FWMVCDEF.CH'

/*
{Protheus.doc} F0300405()
Webservice responsavel pelo portal e comunicação com protheus
@Author    Henrique Madureira
@Since
@Version   P12.7
@Project   MAN00000463701_EF_004
@Param
@Return
*/

User Function F0300405()
	
Return
//=====================================================================================================
WSSTRUCT InfFuncio
	WSDATA Matricula		As String
	WSDATA Nome			As String
	WSDATA Admissao		As String
	WSDATA Departamento	As String
	WSDATA Situacao		As String
	WSDATA CenCusto		As String
	WSDATA Cargo			As String
	WSDATA FilialFun		As String
	WSDATA CodParti      AS String
	WSDATA Tem           AS String
ENDWSSTRUCT

WSSTRUCT _InfSra
	WSDATA Registro		As ARRAY OF InfFuncio
ENDWSSTRUCT
//=====================================================================================================
WSSTRUCT Acao
	WSDATA RDWITEM   AS String
	WSDATA RDWDESCIT AS String
	WSDATA RDWCODOBJ AS String
ENDWSSTRUCT

WSSTRUCT _Acao
	WSDATA InfRdw    As ARRAY OF Acao
ENDWSSTRUCT
//=====================================================================================================
WSSTRUCT Peri
	WSDATA RDUCODIGO  AS String
	WSDATA RDUDESC    AS String
	WSDATA RDUDATINI  AS String
	WSDATA RDUDATFIM  AS String
ENDWSSTRUCT

WSSTRUCT _Period
	WSDATA InfRdu    As ARRAY OF Peri
ENDWSSTRUCT
//=====================================================================================================
WSSTRUCT TreeSup
	WSDATA RANOME			AS String
	WSDATA RAEMAIL		As String
	WSDATA RD4TREE       AS String
	WSDATA SRADEPTO      AS String
	WSDATA QBMATRESP     AS String
ENDWSSTRUCT

WSSTRUCT _TreeSup
	WSDATA Registro		As ARRAY OF TreeSup
ENDWSSTRUCT
//=====================================================================================================
WSSERVICE W0300401 DESCRIPTION "WebService Server responsavel pelo plano de desenvolvimento em equipe"
	
	WSDATA _AcaoInf       AS _Acao
	WSDATA _PerInf        AS _Period
	WSDATA _InfFun        AS InfFuncio
	WSDATA Matricu        AS String
	WSDATA Matr           AS String
	WSDATA Depart         AS String
	WSDATA _Subord        AS _InfSra
	WSDATA _Superi        AS _TreeSup
	WSDATA Check          AS String
	WSDATA DtInicio       AS String
	WSDATA DtFim          AS String
	WSDATA ItemAd         AS String
	WSDATA Periodo        AS String
	WSDATA ItemObj        AS String
	WSDATA FilResp        AS String
	WSDATA Mat            AS String
	WSDATA lRet           AS Boolean
	WSDATA RAMatric       AS String
	WSDATA Matricula      AS String
	
	WSMETHOD LogFunc   DESCRIPTION "Metodo que busca informações do usuario logado"
	WSMETHOD InfFunc   DESCRIPTION "Metodo que busca os funcionários que tem PDI"
	WSMETHOD RetAcao   DESCRIPTION "Metodo que Busca os Itens"
	WSMETHOD GravAcao  DESCRIPTION "Metodo que Grava as informações no PDI do participante"
	WSMETHOD InfCalen  DESCRIPTION "Metodo que busca informações dos calendários"
	WSMETHOD VisSuper  DESCRIPTION "Visão dos superiores"
	
ENDWSSERVICE
//=====================================================================================================
// Metodo que busca os funcionários que tem PDI
WSMETHOD LogFunc WSRECEIVE Matricu WSSEND _InfFun WSSERVICE W0300401
	Local aAux := {}
	aAux := RetSra(::Matricu)
	If !(EMPTY(aAux))
		::_InfFun:Matricula      := aAux[1]
		::_InfFun:Nome           := aAux[2]
		::_InfFun:Admissao       := aAux[3]
		::_InfFun:Departamento   := aAux[4]
		::_InfFun:Situacao       := aAux[5]
		::_InfFun:CenCusto       := aAux[6]
		::_InfFun:Cargo          := aAux[7]
		::_InfFun:FilialFun      := aAux[8]
	EndIf
Return .T.
//=====================================================================================================
Static Function RetSra(cMatricu)
	
	Local cQuery    := ''
	Local cAliasSra := 'RETSRA'
	Local aAux      := {}
	
	cQuery := "SELECT	SRA.RA_MAT, SRA.RA_NOME, SRA.RA_ADMISSA, SRA.RA_DEPTO, SRA.RA_DEMISSA, SRA.RA_CC,"
	cQuery += " SRA.RA_CARGO, SRA.RA_FILIAL, SRA.RA_SITFOLH "
	cQuery += "FROM	" + RetSqlName("SRA") + " SRA "
	cQuery += "WHERE	SRA.RA_MAT = '" + cMatricu + "' AND SRA.RA_DEMISSA = ' '"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSra)
	
	DbSelectArea(cAliasSra)
	
	Do Case
	Case EMPTY(ALLTRIM((cAliasSra)->RA_SITFOLH))
		cSituac := "Situação Normal"
	Case ALLTRIM((cAliasSra)->RA_SITFOLH) == "A"
		cSituac := "Afastado Temp."
	Case ALLTRIM((cAliasSra)->RA_SITFOLH) == "D"
		cSituac := "Demitido"
	Case ALLTRIM((cAliasSra)->RA_SITFOLH) == "F"
		cSituac := "Férias"
	Case ALLTRIM((cAliasSra)->RA_SITFOLH) == "T"
		cSituac := "Trasferido"
	EndCase
	
	While ! (cAliasSra)->(EOF())
		AAdd(aAux, (cAliasSra)->RA_MAT   	)
		AAdd(aAux, (cAliasSra)->RA_NOME    )
		AAdd(aAux, (cAliasSra)->RA_ADMISSA )
		AAdd(aAux, (cAliasSra)->RA_DEPTO 	)
		AAdd(aAux, cSituac  )
		AAdd(aAux, (cAliasSra)->RA_CC 		)
		AAdd(aAux, (cAliasSra)->RA_CARGO 	)
		AAdd(aAux, (cAliasSra)->RA_FILIAL 	)
		(cAliasSra)->(DbSkip())
	End
	(cAliasSra)->(DbCloseArea())
	
Return aAux
//=====================================================================================================
// Metodo que busca os periodos
WSMETHOD InfCalen WSRECEIVE NULLPARAM WSSEND _PerInf WSSERVICE W0300401
	Local aAux := {}
	Local nCnt	:= 1
	Local oSolicita
	
	aAux := InfRdu()
	
	If Len(aAux) > 0
		::_PerInf := WSClassNew( "_Period" )
		
		::_PerInf:InfRdu := {}
		oSolicita :=  WSClassNew( "Peri" )
		For nCnt := 1 To Len(aAux)
			oSolicita:RDUCODIGO   := aAux[nCnt][1]
			oSolicita:RDUDESC     := aAux[nCnt][2]
			oSolicita:RDUDATINI   := aAux[nCnt][3]
			oSolicita:RDUDATFIM   := aAux[nCnt][4]
			AAdd( ::_PerInf:InfRdu, oSolicita )
			oSolicita :=  WSClassNew( "Peri" )
		Next
	EndIf
	
Return .T.
//=====================================================================================================
Static Function InfRdu()
	
	Local cQuery    := ''
	Local cAliasRDU := 'RETRDU'
	Local aAux      := {}
	
	cQuery := "SELECT	RDU_CODIGO, RDU_DESC, RDU_DATINI, RDU_DATFIM "
	cQuery += "FROM   " + RetSqlName("RDU") + " "
	cQuery += "WHERE  D_E_L_E_T_ = ' ' "
	cQuery += "		AND RDU_TIPO = '2' "
	cQuery += "		AND RDU_DATFIM >= " + DTOS(DATE()) + " "
	cQuery += "		ORDER BY RDU_CODIGO"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRDU)
	
	DbSelectArea(cAliasRDU)
	While ! (cAliasRDU)->(EOF())
		AAdd(aAux, {(cAliasRDU)->RDU_CODIGO,;
			(cAliasRDU)->RDU_DESC,;
			(cAliasRDU)->RDU_DATINI,;
			(cAliasRDU)->RDU_DATFIM  } )
		(cAliasRDU)->(DbSkip())
	End
	(cAliasRDU)->(DbCloseArea())
	
Return aAux
//=====================================================================================================

// Metodo que busca os funcionários que tem PDI
WSMETHOD InfFunc WSRECEIVE Matr, Depart WSSEND _Subord WSSERVICE W0300401
	Local aAux := {}
	Local nCnt := 1
	Local oSolicita
	
	aAux := SubSra(::Matr, ::Depart)
	
	If Len(aAux) > 0
		::_Subord := WSClassNew( "_InfSra" )
		
		::_Subord:Registro := {}
		oSolicita :=  WSClassNew( "InfFuncio" )
		For nCnt := 1 To Len(aAux)
			oSolicita:Matricula 		:= aAux[nCnt][1]
			oSolicita:Nome 			:= aAux[nCnt][2]
			oSolicita:Admissao 		:= aAux[nCnt][3]
			oSolicita:Departamento	:= aAux[nCnt][4]
			oSolicita:Situacao		:= aAux[nCnt][5]
			oSolicita:CenCusto		:= aAux[nCnt][6]
			oSolicita:Cargo			:= aAux[nCnt][7]
			oSolicita:FilialFun		:= aAux[nCnt][8]
			oSolicita:CodParti		:= aAux[nCnt][9]
			oSolicita:Tem		       := aAux[nCnt][10]
			AAdd( ::_Subord:Registro, oSolicita )
			oSolicita :=  WSClassNew( "InfFuncio" )
		Next
	EndIf
	
Return .T.
//=====================================================================================================
Static Function SubSra(cMatric, cDepart)
	
	Local cQuery    := ''
	Local cAliasRD4 := 'RETRD4'
	Local cAliasSRA := 'RETSRA'
	Local cAliasAi8 := 'RETAI8'
	Local cTem      := "N"
	Local nCnt      := 1
	Local aAux      := {}
	Local aAux2     := {}
	Local aTem      := {}
	
	cQuery := "SELECT	AI8_VISAPV "
	cQuery += "FROM	" + RetSqlName("AI8") + " AI8 "
	cQuery += "WHERE	AI8_WEBSRV = 'W0300401' AND AI8_ROTINA = 'U_F0300401.APW'"
	cQuery += " AND D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAi8)
	
	DbSelectArea(cAliasAi8)
	//Pega a visão cadastrada
	cVisao := (cAliasAi8)->AI8_VISAPV
	
	(cAliasAi8)->(DbCloseArea())
		
	cQuery := "SELECT	RD4.RD4_CODIDE, RD4.RD4_TREE, SQB.QB_MATRESP "
	cQuery += "FROM	" + RetSqlName("RD4") + " RD4 "
	cQuery += "		RIGHT JOIN " + RetSqlName("SQB") + " SQB "
	cQuery += "		ON SQB.QB_DEPTO = RD4.RD4_CODIDE "
	cQuery += "WHERE	RD4.D_E_L_E_T_ = ' '"
	cQuery += "		AND RD4.RD4_TREE = ( SELECT RD4.RD4_TREE "
	cQuery += "					  FROM " + RetSqlName("RD4") + " RD4"
	cQuery += "					  WHERE RD4.RD4_CODIDE = ("
	cQuery += "													SELECT QB_DEPTO FROM " + RetSqlName("SQB") + " "
	cQuery += "													WHERE QB_MATRESP = '" + cMatric + "') "
	cQuery += "					  AND RD4.RD4_CODIGO = '" + cVisao + "'  AND RD4.D_E_L_E_T_ = ' ' "
	cQuery += "				    ) "
	cQuery += "		OR RD4.RD4_TREE = ( SELECT RD4.RD4_TREE "
	cQuery += "					  FROM " + RetSqlName("RD4") + " RD4 "
	cQuery += "					  WHERE RD4.RD4_CODIDE = ("
	cQuery += "													SELECT QB_DEPTO FROM " + RetSqlName("SQB") + " "
	cQuery += "													WHERE QB_MATRESP = '" + cMatric + "') "
	cQuery += "					  AND RD4.RD4_CODIGO = '" + cVisao + "'  AND RD4.D_E_L_E_T_ = ' ' "
	cQuery += "				    ) + 1 "
	cQuery += " 		AND RD4.RD4_CODIGO = '" + cVisao + "'"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRD4)
	
	DbSelectArea(cAliasRD4)
	While ! (cAliasRD4)->(EOF())
		AAdd(aAux2, {(cAliasRD4)->RD4_CODIDE, (cAliasRD4)->QB_MATRESP, (cAliasRD4)->RD4_TREE} )
		(cAliasRD4)->(DbSkip())
	End
	(cAliasRD4)->(DbCloseArea())
	If Len(aAux2) > 0
		
		// Funcionarios da visão com e sem PDI
		cQuery := "SELECT DISTINCT SRA.RA_MAT, SRA.RA_NOME, SRA.RA_ADMISSA,"
		cQuery += "                SRA.RA_DEPTO, SRA.RA_DEMISSA,SRA.RA_CC,"
		cQuery += "                SRA.RA_CARGO, SRA.RA_FILIAL, SRA.RA_SITFOLH, RD0.RD0_CODIGO  "
		cQuery += "FROM   " + RetSqlName("SRA") + " SRA, "
		cQuery += "INNER JOIN " + RetSqlName("RD0") + " RD0 "
		cQuery += "ON SRA.RA_CIC = RD0.RD0_CIC "
		For nCnt := 1 To LEN(aAux2)
			If  aAux2[nCnt][2] == cMatric
				cTree := aAux2[nCnt][3]
				cQuery += "WHERE 	SRA.RA_DEPTO = '" + aAux2[nCnt][1] + "' "
				cQuery += "		AND SRA.RA_DEPTO != ' ' "
				cQuery += "		AND SRA.RA_DEMISSA = ' ' "
			EndIf
		Next
		cQuery += " AND SRA.RA_MAT <> '" + cMatric + "' "
		For nCnt := 1 To LEN(aAux2)
			If aAux2[nCnt][2] != cMatric .AND. aAux2[nCnt][3] != cTree
				cQuery += "OR SRA.RA_MAT = '" + aAux2[nCnt][2] + "' "
			EndIf
		Next
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRA)
		
		DbSelectArea(cAliasSRA)
		
		For nCnt := 1 To Len(aAux2)
			(cAliasSRA)->(DbGoTop())
			While ! (cAliasSRA)->(EOF())
				nPoDSup := AScan( aAux2[nCnt], (cAliasSRA)->RA_MAT )
				If nPoDSup != 0
					If AScan( aTem, (cAliasSRA)->RA_MAT ) == 0
						AAdd(aTem,(cAliasSRA)->RA_MAT)
					EndIf
				EndIf
				(cAliasSRA)->(DbSkip())
			End
		Next
		(cAliasSRA)->(DbGoTop())
		
		While ! (cAliasSRA)->(EOF())
			Do Case
			Case EMPTY(ALLTRIM((cAliasSra)->RA_SITFOLH))
				cSituac := "Situação Normal"
			Case ALLTRIM((cAliasSra)->RA_SITFOLH) == "A"
				cSituac := "Afastado Temp."
			Case ALLTRIM((cAliasSra)->RA_SITFOLH) == "D"
				cSituac := "Demitido"
			Case ALLTRIM((cAliasSra)->RA_SITFOLH) == "F"
				cSituac := "Férias"
			Case ALLTRIM((cAliasSra)->RA_SITFOLH) == "T"
				cSituac := "Trasferido"
			EndCase
			AAdd(aAux, {	(cAliasSRA)->RA_MAT ,;
				(cAliasSRA)->RA_NOME,;
				(cAliasSRA)->RA_ADMISSA,;
				(cAliasSRA)->RA_DEPTO,;
				cSituac,;
				(cAliasSRA)->RA_CC,;
				(cAliasSRA)->RA_CARGO,;
				(cAliasSRA)->RA_FILIAL,;
				(cAliasSRA)->RD0_CODIGO,;
				IIF(AScan( aTem, (cAliasSRA)->RA_MAT ) == 0,"N","S");
				}  	)
			(cAliasSRA)->(DbSkip())
		End
		(cAliasSRA)->(DbCloseArea())
	EndIf
Return aAux
//=====================================================================================================
// Metodo que Busca os Itens
WSMETHOD RetAcao WSRECEIVE NULLPARAM WSSEND _AcaoInf WSSERVICE W0300401
	Local aAux := {}
	Local nCnt	:= 1
	Local oSolicita
	
	aAux := RETRDW()
	
	If Len(aAux) > 0
		::_AcaoInf := WSClassNew( "_Acao" )
		
		::_AcaoInf:InfRdw := {}
		oSolicita :=  WSClassNew( "Acao" )
		For nCnt := 1 To Len(aAux)
			oSolicita:RDWCODOBJ   := aAux[nCnt][1]
			oSolicita:RDWITEM     := aAux[nCnt][2]
			oSolicita:RDWDESCIT   := aAux[nCnt][3]
			AAdd( ::_AcaoInf:InfRdw, oSolicita )
			oSolicita :=  WSClassNew( "Acao" )
		Next
	EndIf
	
Return .T.
//=====================================================================================================
Static Function RETRDW()
	
	Local cQuery 		:= ''
	Local cAliasRdw	:= 'RETRDW'
	Local aAux			:= {}
	
	// Henrique continue essa logica ruim
	cQuery := "SELECT	RDW_CODOBJ, RDW_ITEM, RDW_DESCIT "
	cQuery += "FROM	" + RetSqlName("RDW") + " RDW, " + RetSqlName("RDI") + " RDI "
	cQuery += "WHERE	RDW.D_E_L_E_T_ = ' ' "
	cQuery += "		AND RDW.RDW_CODOBJ = RDI.RDI_CODIGO "
	cQuery += "		AND RDI.RDI_TIPO = '1' "
	cQuery += "		ORDER BY RDW_CODOBJ"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRdw)
	
	DbSelectArea(cAliasRdw)
	While ! (cAliasRdw)->(EOF())
		AAdd(aAux, {(cAliasRdw)->RDW_CODOBJ,(cAliasRdw)->RDW_ITEM, (cAliasRdw)->RDW_DESCIT })
		(cAliasRdw)->(DbSkip())
	End
	(cAliasRdw)->(DbCloseArea())
	
Return aAux
//=====================================================================================================
// Metodo que Grava as informações no PDI do participante
WSMETHOD GravAcao WSRECEIVE FilResp, Mat, Check, DtInicio, DtFim, ItemAd, ItemObj, Periodo WSSEND lRet WSSERVICE W0300401
	
	::lRet := GrvItemAc(::FilResp, ::Mat, ::Check, ::DtInicio, ::DtFim, ::ItemAd, ::ItemObj, ::Periodo)
	
Return .T.
//=====================================================================================================
Static Function GrvItemAc(cFilSup,cMat, cCheck, cDtInicio, cDtFim, cItemAd, cItemObj, cPeriodo)
	Local aAux      := {}
	Local aAreas    := {RDJ->(GetArea()),RDV->(GetArea()),GetArea()}
	Local lRet      := .F.
	Local cQuery    := ''
	Local cAliasRdi := 'RETRDI'
	Local cAliasRd0 := 'RETRD0'
	
	cFilSup := U_F0600402( cFilSup, "RD0")
	
	cMat := POSICIONE("RD0",1,cFilSup + cMat, "RD0_CODIGO")
	
	cQuery := "SELECT	RDI_ESCREL, RDI_ESCATG, RDI_ESCCON "
	cQuery += "FROM	" + RetSqlName("RDI") + " "
	cQuery += "WHERE	D_E_L_E_T_ = ' ' AND RDI_CODIGO = '" + cItemObj + "' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRdi)
	cPeriodo := SUBSTR(cPeriodo,0,6)
	RDV->(DbSetOrder(1))
	If !(RDV->(DbSeek(xFILIAL("RDV") + ALLTRIM(cCheck + cItemObj + cMat + cPeriodo))))
		RecLock("RDV", .T.)
		RDV->RDV_FILIAL := xFILIAL("RDV")
		RDV->RDV_CODPAR := cCheck
		RDV->RDV_CODOBJ := cItemObj
		RDV->RDV_CODPER := cPeriodo
		RDV->RDV_CODDOR := cMat
		RDV->RDV_STATUS := '1'
		RDV->RDV_CODPAP := ''
		RDV->RDV_VERATU := 0
		RDV->(MsUnlock())
	EndIf
	
	RDJ->(DbSetOrder(2))
	DbSelectArea(cAliasRdi)
	If !(RDJ->(DbSeek(xFILIAL("RDJ") + cItemObj + cCheck + cPeriodo + '0001' + '01' + DtoS(dDataBase))))
		RecLock("RDJ", .T.)
		RDJ->RDJ_CODPAR := cCheck
		RDJ->RDJ_CODOBJ := cItemObj
		RDJ->RDJ_PERIOD := cPeriodo
		RDJ->RDJ_CODDOR := cMat
		RDJ->RDJ_ITOBJ  := cItemAd
		RDJ->RDJ_ITEM   := '0001'
		RDJ->RDJ_SEQITM := '01'
		RDJ->RDJ_STATUS := '1'
		RDJ->RDJ_DATITM := dDataBase
		RDJ->RDJ_DTINI  := StoD(cDtInicio)
		RDJ->RDJ_DTFIM  := StoD(cDtFim)
		RDJ->RDJ_ESCREA := (cAliasRdi)->RDI_ESCREL
		RDJ->RDJ_ESCATG := (cAliasRdi)->RDI_ESCATG
		RDJ->RDJ_ESCCON := (cAliasRdi)->RDI_ESCCON
		RDJ->(MsUnlock())
		lRet := .T.
	EndIf
	(cAliasRdi)->(DbCloseArea())
	
	
	AEval(aAreas, {|x| RestArea(x)} )
	
Return lRet
//=====================================================================================================
// Pega as informações de quem está logado
WSMETHOD VisSuper WSRECEIVE RAMatric, Matricula WSSEND _Superi WSSERVICE W0300401
	Local aAux := {}
	Local nCnt	:= 1
	Local oSolicita
	
	aAux := RetRd4(::RAMatric, ::Matricula)
	
	If Len(aAux) > 0
		::_Superi := WSClassNew( "_TreeSup" )
		
		::_Superi:Registro := {}
		oSolicita :=  WSClassNew( "TreeSup" )
		For nCnt := 1 To Len(aAux)
			oSolicita:RANOME 		:= aAux[nCnt][1]
			oSolicita:RAEMAIL 	:= aAux[nCnt][2]
			oSolicita:RD4TREE    := aAux[nCnt][3]
			oSolicita:SRADEPTO   := aAux[nCnt][5]
			oSolicita:QBMATRESP  := aAux[nCnt][4]
			AAdd( ::_Superi:Registro, oSolicita )
			oSolicita :=  WSClassNew( "TreeSup" )
		Next
	EndIf
	
Return .T.
//=====================================================================================================
/*
{Protheus.doc} RetRd4()
Retorna dados do aprovador
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_003
@Param      cDepart, departamento
@Param      cMatri, matricula
@Param      cTipo, tipo de solicitação
@Return     aAux
*/
Static Function RetRd4(cMatric,cMatri)
	
	Local cQuery     := ''
	Local cAliasRd4  := 'RETRD4'
	Local cAliAi8    := 'RETAI8'
	Local cAliasTRE  := 'RETTRE'
	Local cAlTRE     := 'RETTRELOG'
	Local nCnt       := 1
	Local aAux       := {}
	
	cQuery := "SELECT	AI8_VISAPV "
	cQuery += "FROM	" + RetSqlName("AI8") + " AI8 "
	cQuery += "WHERE	AI8_WEBSRV = 'W0300401' AND AI8_ROTINA = 'U_F0300401.APW'"
	cQuery += " AND D_E_L_E_T_ = ' '
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAi8)
	
	DbSelectArea(cAliAi8)
	//Pega a visão cadastrada
	cVisao := (cAliAi8)->AI8_VISAPV
	(cAliAi8)->(DbCloseArea())
	
	cQuery := "SELECT RD4.RD4_TREE "
	cQuery += "FROM 	" + RetSqlName("RD4") + " RD4 "
	cQuery += "WHERE 	RD4.RD4_CODIDE = (SELECT QB_DEPTO FROM " + RetSqlName("SQB") + " "
	cQuery += "							WHERE QB_MATRESP = '" + cMatri + "') "
	cQuery += "		AND RD4.RD4_CODIGO = '" + cVisao + "' "
	cQuery += "		AND RD4.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlTRE)
	
	DbSelectArea(cAlTRE)
	//Pega a posição na tree da visão
	cTreeLog := (cAlTRE)->RD4_TREE
	//cTree := (cAliasTRE)->RD4_TREE
	
	(cAlTRE)->(DbCloseArea())
	
	
	cQuery := "SELECT RD4.RD4_TREE "
	cQuery += "FROM 	" + RetSqlName("RD4") + " RD4 "
	cQuery += "WHERE 	RD4.RD4_CODIDE = (SELECT QB_DEPTO FROM " + RetSqlName("SQB") + " "
	cQuery += "							WHERE QB_MATRESP = '" + cMatric + "') "
	cQuery += "		AND RD4.RD4_CODIGO = '" + cVisao + "' "
	cQuery += "		AND RD4.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTRE)
	
	DbSelectArea(cAliasTRE)
	//Pega a posição na tree da visão
	cTree := (cAliasTRE)->RD4_TREE
	
	(cAliasTRE)->(DbCloseArea())
	
	cQuery := "SELECT	RD4.RD4_CODIDE, RD4.RD4_TREE,SQB.QB_MATRESP, SRA.RA_NOME, SRA.RA_EMAIL, SRA.RA_DEPTO "
	cQuery += "FROM	" + RetSqlName("RD4") + " RD4, " + RetSqlName("SQB") + " SQB, " + RetSqlName("SRA") + " SRA "
	cQuery += "WHERE	RD4.D_E_L_E_T_ = ' ' "
	cQuery += "		AND SQB.QB_DEPTO = RD4.RD4_CODIDE "
	cQuery += "		AND SQB.QB_MATRESP = SRA.RA_MAT "
	cQuery += "		AND RD4.RD4_TREE >= ( SELECT RD4.RD4_TREE "
	cQuery += "					  FROM " + RetSqlName("RD4") + " RD4 "
	cQuery += "					  WHERE RD4.RD4_CODIDE = (	SELECT QB_DEPTO"
	cQuery += "												 	FROM " + RetSqlName("SQB") + " "
	cQuery += "													WHERE QB_MATRESP = '" + cMatri + "') "
	cQuery += "					  AND RD4.RD4_CODIGO = '" + cVisao + "'
	cQuery += "					  AND RD4.D_E_L_E_T_ = ' ' "
	cQuery += "				    )	"
	cQuery += " 		AND RD4.RD4_CODIGO = '" + cVisao + "'"
	cQuery += "Order by RD4.RD4_TREE "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRd4)
	
	DbSelectArea(cAliasRd4)
	While ! (cAliasRd4)->(EOF())
		If VAL((cAliasRd4)->RD4_TREE) <= VAL(cTree)
			AAdd(aAux, {(cAliasRd4)->RA_NOME,;
				ALLTRIM((cAliasRd4)->RA_EMAIL),;
				(cAliasRd4)->RD4_TREE,;
				(cAliasRd4)->QB_MATRESP,;
				(cAliasRd4)->RA_DEPTO  })
		EndIf
		(cAliasRd4)->(DbSkip())
	End
	(cAliasRd4)->(DbCloseArea())
	
Return aAux
