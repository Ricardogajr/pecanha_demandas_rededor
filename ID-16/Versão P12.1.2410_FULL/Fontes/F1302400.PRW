#Include 'Protheus.ch'
#INCLUDE "APWEBSRV.CH"
#INCLUDE 'FWMVCDEF.CH'

/*
{Protheus.doc} F1302400
WebService de Estrutura organizacional portal
@Author     Henrique Toyoda
@Since      29/12/2017
@Version    P12.7
@Project    MAN0000007423048_EF_024
*/
User Function F1302400()
Return
//===========================================================================================================
WsStruct ESTRUTURA
	WsData FilialEs     AS STRING
	WsData Descricao    AS STRING
	WsData posto        AS STRING
	WsData Tipo         AS STRING
	WsData Quantidade   AS Integer
	WsData Ocupado      AS Integer
	WsData Reservado    AS Integer
	WsData Handover     AS STRING
	WsData departamento AS STRING
	WsData Funcao       AS STRING
	WsData Responsavel  AS STRING
	WsData Equipe       AS Boolean
	WsData Coddepart    AS STRING
	WsData CodFuncao    AS STRING
EndWsStruct
//===========================================================================================================
WsStruct _ESTRUTURA
	WsData registro As Array Of ESTRUTURA
EndWsStruct

//===========================================================================================================
WsStruct ESTRUTURA_FUNC
	WsData FilialMat       AS STRING
	WsData DescricaoFil    AS STRING
	WsData MatriculaFun    AS STRING
	WsData NomeFun         AS STRING
	WsData DepartamentoFun AS STRING
	WsData DescricaoFun    AS STRING
	WsData StatusFun       AS STRING
	WsData SalarioFun      AS STRING
	WsData SituacaoFun     AS STRING
	WsData AdmissaoFun     AS STRING
EndWsStruct
//===========================================================================================================
WsStruct _ESTRUTURA_FUNC
	WsData registro_FUNC As Array Of ESTRUTURA_FUNC
EndWsStruct

//===========================================================================================================
WSSERVICE W1302400 DESCRIPTION "WebService Server responsavel pelo ESTRUTURAmento"

	WSDATA Assunto    AS String
	WSDATA FILIFUN    AS String
	WSDATA Matricu    AS String
	WSDATA lRet       AS Boolean
	WSDATA DtIni      AS String
	WSDATA DtFim      AS String
	WSDATA Mat        AS String
	WSDATA Status     AS String
	WSDATA Servico    AS String
	//WSDATA Matricu    AS String
	WSDATA FilGes     AS String
	WSDATA Codigo     AS String
	WSDATA Visao      AS String
	WSDATA FilPosto   AS String
	WSDATA CodPosto   AS String
	WSDATA FILTRO     AS String
	WSDATA CAMPO      AS String
	WSDATA Lista      AS String

	WSDATA _ACOM      AS _ESTRUTURA
	WSDATA _FUNPOS    AS _ESTRUTURA_FUNC

	WSMETHOD BuscaRCL  DESCRIPTION "Busca RCL"
	WSMETHOD BuscaRCX  DESCRIPTION "Busca RCX"

ENDWSSERVICE

//===========================================================================================================

WSMETHOD BuscaRCL WSRECEIVE FilGes, Matricu, Visao, FilPosto, CodPosto, FILTRO, CAMPO, Lista WSSEND _ACOM WSSERVICE W1302400

	Local cMatFun := "'"
	Local cFilFun := "'"
	Local aAux 	:= {}
	Local aFun    := {}
	Local nX		:= 1
	Local nI      := 1
	Local nPosIni := 1
	Local nCnt    := 0
	Local oSolVg  := Nil

	aAux := RetAprov(::FilGes, ::Matricu, ::Visao, ::FilPosto, ::CodPosto, ::FILTRO, ::CAMPO, ::Lista)

	If Len(aAux) > 0

		::_ACOM := WSClassNew( "_ESTRUTURA" )
		::_ACOM:registro := {}

		oSolVg :=  WSClassNew( "ESTRUTURA" )
		For nX := 1 To Len(aAux)
			oSolVg:FilialEs     := aAux[nX][1]
			oSolVg:Descricao    := aAux[nX][2]
			oSolVg:posto        := aAux[nX][3]
			oSolVg:Tipo         := aAux[nX][4]
			oSolVg:Quantidade   := aAux[nX][5]
			oSolVg:Ocupado      := aAux[nX][6]
			oSolVg:Reservado    := U_F0500314(aAux[nX][7],aAux[nX][1],aAux[nX][3])
			oSolVg:Handover     := ""
			oSolVg:Coddepart    := aAux[nX][7]
			oSolVg:departamento := aAux[nX][8]
			oSolVg:CodFuncao    := aAux[nX][9]
			oSolVg:Funcao       := aAux[nX][10]
			oSolVg:Responsavel  := aAux[nX][11]
			oSolVg:Equipe       := ValEstru(::Visao,aAux[nX][12])
			AAdd( ::_ACOM:registro, oSolVg )
			oSolVg :=  WSClassNew( "ESTRUTURA" )
		Next
	Else
		::_ACOM := WSClassNew( "_ESTRUTURA" )
		::_ACOM:registro := {}
		oSolVg :=  WSClassNew( "ESTRUTURA" )
		oSolVg:FilialEs     := ""
		oSolVg:Descricao    := ""
		oSolVg:posto        := ""
		oSolVg:Tipo         := ""
		oSolVg:Quantidade   := 0
		oSolVg:Ocupado      := 0
		oSolVg:Reservado    := 0
		oSolVg:Handover     := ""
		oSolVg:Coddepart    := ""
		oSolVg:departamento := ""
		oSolVg:CodFuncao    := ""
		oSolVg:Funcao       := ""
		oSolVg:Responsavel  := ""
		oSolVg:Equipe       := .f.
		AAdd( ::_ACOM:registro, oSolVg )
	EndIf

Return .T.

Static Function ValEstru(cCodRD4, cItemRD4)
	
	Local aArea := GetArea()
	Local aAreaRd4 := RD4->(GetArea())
	Local lRet  := .F.
	
	RD4->(DbSetOrder(2))
	If RD4->(DbSeek(xFilial("RD4")+ cCodRD4 + cItemRD4))
		lRet := .T.
	EndIf
	
	RestArea(aAreaRd4)
	RestArea(aArea)
	
Return lRet

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
Static Function RetAprov(cFilSra,cMatriSra, cVisao, cFilPosto, cCodPosto, cFILTRO, cCAMPO, cLista)

	Local cAliRh4 := "RETRH4"
	Local cPosto  := ""
	Local cMatri  := ""
	Local cNome   := ""
	Local cQuery  := ""
	Local cGeren  := ""
	Local cFdescDep := ""
	Local cFdescFun := ""
	Local lLoop   := .F.
	Local aAux    := {}

	Default cFilSra   := ""
	Default cMatriSra := ""
	Default cFilPosto := ""
	Default cCodPosto := ""
	Default cVisao    := ""
	Default cFILTRO   := ""
	Default cCAMPO    := ""
	
	If !Empty(cFILTRO)
		cFILTRO := FwNoAccent(cFILTRO)
	EndIf
	
	cQuery := "SELECT RCL.RCL_FILIAL,RCL.RCL_POSTO, "
	cQuery += "       RCL.RCL_DEPTO, RCL.RCL_CARGO, RCL.RCL_FUNCAO, RCL.RCL_CC,   "
	cQuery += "       RD4.RD4_CODIGO, RCL.RCL_NPOSTO , RCL.RCL_TPOSTO, "
	cQuery += "       RCL.RCL_NPOSTO, RCL.RCL_OPOSTO, RCL.RCL_DEPTO, RCL.RCL_FUNCAO, RD4.RD4_ITEM  "
	cQuery += "FROM " + RetSqlName("RD4") + " RD4  "
	cQuery += "INNER JOIN " + RetSqlName("RCL") + " RCL   "
	cQuery += "ON RCL.D_E_L_E_T_ = ' '   "
	
	If cCAMPO == "RCL_FILIAL"
		cQuery += "AND RCL.RCL_FILIAL LIKE '%" + cFILTRO + "%' "
	EndIf
	If cCAMPO == "RCL_DEPTO"
		cQuery += "AND RCL.RCL_DEPTO LIKE '%" + cFILTRO + "%' "
	EndIf
	If cCAMPO == "RCL_POSTO"
		cQuery += "AND RCL.RCL_POSTO LIKE '%" + cFILTRO + "%' "
	EndIf
	If cCAMPO == "RCL_FUNCAO"
		cQuery += "AND RCL.RCL_FUNCAO LIKE '%" + cFILTRO + "%' "
	EndIf
	
	cQuery += "AND RCL.RCL_POSTO =  RD4.RD4_CODIDE   "
	cQuery += "AND RCL.RCL_FILIAL = RD4.RD4_FILIDE   "
	
	If EMPTY(cLista)
		cQuery += "INNER JOIN " + RetSqlName("RCX") + " RCX   "
		cQuery += "ON RCX.D_E_L_E_T_ = ' '   "
		cQuery += "AND RCX.RCX_POSTO =  RCL.RCL_POSTO  "
		cQuery += "AND RCX.RCX_FILIAL = RCL.RCL_FILIAL  "	
		cQuery += "AND RCX.RCX_FILFUN = '" + cFilSra + "' "
		cQuery += "AND RCX.RCX_MATFUN = '" + cMatriSra + "' "
	EndIf

	cQuery += "WHERE RD4.D_E_L_E_T_ = ' '   "
	cQuery += "AND RD4.RD4_CODIGO = '" + cVisao + "'  "

	If !(EMPTY(cLista))
		cQuery += "AND    RD4.RD4_TREE IN( "
		cQuery += "SELECT RD4.RD4_ITEM  "
		cQuery += "FROM " + RetSqlName("RD4") + " RD4  "
		If !(EMPTY(cFilSra)) .AND. !(EMPTY(cMatriSra))
			cQuery += "INNER JOIN " + RetSqlName("RCX") + " RCX "
			cQuery += "ON RCX.D_E_L_E_T_ = ' '  "
			cQuery += "AND RCX.RCX_FILFUN = '" + cFilSra + "' "
			cQuery += "AND RCX.RCX_MATFUN = '" + cMatriSra + "' "
		EndIf
		cQuery += "WHERE RD4.D_E_L_E_T_ = ' ' "
		cQuery += "AND RD4.RD4_CODIGO = '" + cVisao + "'  "
		If !(EMPTY(cFilSra)) .AND. !(EMPTY(cMatriSra))
			cQuery += "AND RD4.RD4_FILIDE = RCX.RCX_FILIAL "
			cQuery += "AND RD4.RD4_CODIDE = RCX.RCX_POSTO	 "
		Else
			cQuery += "AND RD4.RD4_FILIDE = '" + cFilPosto + "' "
			cQuery += "AND RD4.RD4_CODIDE = '" + cCodPosto + "' "
		EndIf
		cQuery += ")  "
	EndIf
	cQuery += "AND RCL.RCL_STATUS <> '4' "
	cQuery += "ORDER BY  RD4.RD4_CHAVE  "
		
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliRh4)

	DbSelectArea(cAliRh4)
	While ! (cAliRh4)->(EOF())
		cGeren := U_F1300202((cAliRh4)->RCL_FILIAL, (cAliRh4)->RCL_POSTO, cVisao)
		cFdescDep := FDESC("SQB",(cAliRh4)->RCL_DEPTO,"QB_DESCRIC")
		cFdescFun := FDESC("SRJ",(cAliRh4)->RCL_FUNCAO,"RJ_DESC")
					
		If !(EMPTY(cFiltro)) .AND. !(EMPTY(cCampo))
			If cCampo == "TMP_FILIAL"
				If !(ALLTRIM(UPPER(cFiltro)) $ UPPER(FWFILIALNAME(,(cAliRh4)->RCL_FILIAL)))
					lLoop := .T.
				EndIf
			ElseIf cCampo == "TMP_DEPTO"
				If !(ALLTRIM(UPPER(cFiltro)) $ cFdescDep)
					lLoop := .T.
				EndIf
			ElseIf cCampo == "TMP_FUNCAO"
				If !(ALLTRIM(UPPER(cFiltro)) $ cFdescFun)
					lLoop := .T.
				EndIf
			ElseIf cCampo == ""
				If !(ALLTRIM(UPPER(cFiltro)) $ cGeren)
					lLoop := .T.
				EndIf
			EndIf
		EndIf
		If !lLoop
			AADD(aAux,{(cAliRh4)->RCL_FILIAL,;
				FWFILIALNAME(,(cAliRh4)->RCL_FILIAL),;
				(cAliRh4)->RCL_POSTO,;
				IIF((cAliRh4)->RCL_TPOSTO == "2","Generico","Individual"),;
				(cAliRh4)->RCL_NPOSTO,;
				(cAliRh4)->RCL_OPOSTO,;
				(cAliRh4)->RCL_DEPTO,;
				cFdescDep,;
				(cAliRh4)->RCL_FUNCAO,;
				cFdescFun,;
				cGeren,;
				(cAliRh4)->RD4_ITEM;
				})
		EndIf
		lLoop   := .F.
		(cAliRh4)->(DbSkip())
	End
	(cAliRh4)->(DbCloseArea())

Return aAux

//===========================================================================================================

WSMETHOD BuscaRCX WSRECEIVE FilPosto, CodPosto, CAMPO, FILTRO WSSEND _FUNPOS WSSERVICE W1302400

	Local cMatFun := "'"
	Local cFilFun := "'"
	Local aAux 	:= {}
	Local aFun    := {}
	Local nX		:= 1
	Local nI      := 1
	Local nPosIni := 1
	Local nCnt    := 0
	Local oSolVg  := Nil

	aAux := RetMatr(::FilPosto,::CodPosto,::CAMPO, ::FILTRO)

	If Len(aAux) > 0

		::_FUNPOS := WSClassNew( "_ESTRUTURA_FUNC" )
		::_FUNPOS:registro_FUNC := {}

		oSolVg :=  WSClassNew( "ESTRUTURA_FUNC" )
		For nX := 1 To Len(aAux)
			oSolVg:FilialMat       := aAux[nX][1]
			oSolVg:DescricaoFil    := aAux[nX][2]
			oSolVg:MatriculaFun    := aAux[nX][3]
			oSolVg:NomeFun         := aAux[nX][4]
			oSolVg:DepartamentoFun := aAux[nX][5]
			oSolVg:DescricaoFun    := aAux[nX][6]
			oSolVg:StatusFun       := aAux[nX][7]
			oSolVg:SalarioFun      := aAux[nX][8]
			oSolVg:SituacaoFun     := aAux[nX][9]
			oSolVg:AdmissaoFun     := aAux[nX][10]
			AAdd( ::_FUNPOS:registro_FUNC, oSolVg )
			oSolVg :=  WSClassNew( "ESTRUTURA_FUNC" )
		Next
	Else
		::_FUNPOS := WSClassNew( "_ESTRUTURA_FUNC" )
		::_FUNPOS:registro_FUNC := {}
		oSolVg :=  WSClassNew( "ESTRUTURA_FUNC" )
		oSolVg:FilialMat       := ""
		oSolVg:DescricaoFil    := ""
		oSolVg:MatriculaFun    := ""
		oSolVg:NomeFun         := ""
		oSolVg:DepartamentoFun := ""
		oSolVg:DescricaoFun    := ""
		oSolVg:StatusFun       := ""
		oSolVg:SalarioFun      := ""
		oSolVg:SituacaoFun     := ""
		oSolVg:AdmissaoFun     := ""
		AAdd( ::_FUNPOS:registro_FUNC, oSolVg )
	EndIf

Return .T.

Static Function RetMatr(cFlPosto,cCdPosto,cCampo,cDado)

	Local cAliRh4 := "RETRH4"
	Local cPosto  := ""
	Local cMatri  := ""
	Local cNome   := ""
	Local cSituac := ""
	Local cQuery  := ""
	Local aAux    := {}

	cQuery := "SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_DEPTO, RA_SALARIO, "
	cQuery += " RA_SITFOLH, RCX_SUBST, RA_ADMISSA "
	cQuery += "FROM " + RetSqlName("SRA") + " SRA "
	cQuery += "INNER JOIN " + RetSqlName("RCX") + " RCX   "
	cQuery += "ON RCX.D_E_L_E_T_ = ' '   "
	cQuery += "AND RCX.RCX_FILFUN =  SRA.RA_FILIAL "
	cQuery += "AND RCX.RCX_MATFUN = SRA.RA_MAT  "
	cQuery += "AND RCX.RCX_FILIAL = '" + cFlPosto + "' "
	cQuery += "AND RCX.RCX_POSTO = '" + cCdPosto + "'   "
	cQuery += "WHERE SRA.D_E_L_E_T_ = ' ' "
	
	If !Empty(cCampo) .AND. !Empty(cDado)
		If cCampo == "RCX_FILFUN"
			cQuery += "AND RCX_FILFUN = '" + cDado + "' "
		ElseIf cCampo == "RCX_MATFUN"
			cQuery += "AND RCX_MATFUN = '" + cDado + "' "
		ElseIf cCampo == "RA_NOME"
			cQuery += "AND RA_NOME LIKE UPPER('%" + cDado + "%') "
		EndIf
	EndIf
		
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliRh4)

	DbSelectArea(cAliRh4)
	While ! (cAliRh4)->(EOF())
		Do Case
		Case EMPTY(ALLTRIM((cAliRh4)->RA_SITFOLH))
			cSituac := "Situação Normal"
		Case ALLTRIM((cAliRh4)->RA_SITFOLH) == "A"
			cSituac := "Afastado Temp."
		Case ALLTRIM((cAliRh4)->RA_SITFOLH) == "D"
			cSituac := "Demitido"
		Case ALLTRIM((cAliRh4)->RA_SITFOLH) == "F"
			cSituac := "Férias"
		Case ALLTRIM((cAliRh4)->RA_SITFOLH) == "T"
			cSituac := "Trasferido"
		EndCase
		AADD(aAux,{(cAliRh4)->RA_FILIAL,;
			FWFILIALNAME(,(cAliRh4)->RA_FILIAL),;
			(cAliRh4)->RA_MAT,;
			(cAliRh4)->RA_NOME,;
			(cAliRh4)->RA_DEPTO,;
			FDESC("SQB",(cAliRh4)->RA_DEPTO,"QB_DESCRIC"),;
			IIF((cAliRh4)->RCX_SUBST != "2","Substituto", "Não substituto"),;
			cValToChar((cAliRh4)->RA_SALARIO),;
			cSituac,;
			SUBSTR((cAliRh4)->RA_ADMISSA,7,2) + "/" + SUBSTR((cAliRh4)->RA_ADMISSA,5,2) + "/" + SUBSTR((cAliRh4)->RA_ADMISSA,1,4);
			})
		(cAliRh4)->(DbSkip())
	End
	(cAliRh4)->(DbCloseArea())

Return aAux