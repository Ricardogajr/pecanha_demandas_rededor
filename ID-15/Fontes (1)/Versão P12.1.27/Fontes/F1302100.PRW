#include 'protheus.ch'
#include "APWEBSRV.CH"

#DEFINE PAGE_LENGTH 10

User Function F1302000()
Return

WSSTRUCT allfil
	WSDATA FILIAIS   AS String
	WSDATA DESCRICAO AS String
ENDWSSTRUCT

WSSTRUCT _allfil
	WSDATA ListOfallfil   AS Array Of allfil
	WSDATA PagesTotal     AS Integer
ENDWSSTRUCT

WSSTRUCT alldepart
	WSDATA Department			As String  				//Departamento do Funcionario
	WSDATA DescrDepartment  	AS String  		//Departamento
ENDWSSTRUCT

WSSTRUCT _alldepart
	WSDATA ListOfalldepart   AS Array Of alldepart
	WSDATA PagesTotal     AS Integer
ENDWSSTRUCT

WSSTRUCT allpostos
	WSDATA PostFilial       As String
	WSDATA Posto			As String 	   				//Posto
	WSDATA DescrTipo		AS String					//Descricao do Tipo
	WSDATA Qtd				AS Integer 			 		//quantidade
	WSDATA Ocupado			AS Integer 			 		//Qtd ocupada
	WSDATA DescrFuncao		AS String 			 		//Descricao da funcao
	WSDATA DescrCargo		AS String 			 		//Descricao do Cargo
	WSDATA Responsavel      AS String OPTIONAL	     	//Responsá¶¥l pelo Posto
ENDWSSTRUCT

WSSTRUCT _allpostos
	WSDATA ListOfAllPostos		AS Array Of allpostos 		OPTIONAL
	WSDATA PagesTotal			AS Integer 					OPTIONAL
ENDWSSTRUCT

WsStruct CntrCusto
	WsData CodCC  As String
	WsData DescC  As String
EndWsStruct

WSSTRUCT allfuncao
	WSDATA Codigo    AS String
	WSDATA Descricao AS String
ENDWSSTRUCT

WSSTRUCT _allfuncao
	WSDATA ListOfallfuncao  AS Array Of allfuncao
	WSDATA PagesTotal       AS Integer
ENDWSSTRUCT

WsService W1302100 Description "WebService Server de montagem de grid"
	
	WSDATA _ListOfallfil    AS _allfil
	WSDATA _ListOfalldepart AS _alldepart
	WSDATA _ListOfallpostos AS _allpostos		//Postos
	WSDATA _CntrCusto       AS CntrCusto
	WSDATA _ListOfallfuncao AS _allfuncao
	WSDATA RET              AS BOOLEAN
	WSDATA PAGE             AS INTEGER
	WSDATA Filtro           AS String
	WSDATA Campo            AS String
	WSDATA cFilP            AS String
	WSDATA cDepto           AS String
	WSDATA FilPosto         AS String
	WSDATA CodPosto         AS String
	
	WSDATA ParticipantID AS String
	WSDATA Vision        AS String
	WSDATA ControlPost   AS String
	WSDATA FilPotVis     AS String
	WSDATA FilRepor      AS String
	WSDATA Ocupados		 AS String
	WSDATA CompanyID     AS String optional
	WSDATA DepartmentID  AS String optional
	WSDATA PostID        AS String optional
	//WSDATA Page          AS Integer optional
	WSDATA FilterField   AS String optional
	WSDATA FilterValue   AS String optional
	WSDATA RequestType   AS String optional
	WSDATA EmployeeFil   AS String optional
	WSDATA Registration  AS String optional
	WSDATA PostoVis      AS String optional
	WSDATA nTotal        AS INTEGER
	WSMETHOD RetFiliais       DESCRIPTION "Metodo que retorna as filiais"
	WSMETHOD RetDepartamentos DESCRIPTION "Metodo que retorna os departamentos"
	WSMETHOD RetPostos        DESCRIPTION "Metodo que retorna os postos"
	WSMETHOD AllCntrCusto     DESCRIPTION ""
	WSMETHOD AllBuscDepto     DESCRIPTION ""
	WSMETHOD RETFUNCRG        DESCRIPTION "Retorna as funções"
	
EndWsService

WsMethod RetFiliais WsReceive Filtro, Campo, PAGE WsSend _ListOfallfil WsService W1302100
	Local aAux      := {}
	Local aFilial   := {}
	Local nCnt      := 1
	Local nPosIni   := 1
	Local lLoop     := .F.
	Local oSolicita
	Local cFilName := "" // Ticket #9406673 04/08/2020 - Eduardo Williams - Performance da rotina. Trocada função FwFilialName pela Classe FWSM0Util
	
	DEFAULT Self:Page   := 1
	DEFAULT Self:Filtro := 1
	DEFAULT Self:Campo  := 1
	
	aFilial := FWAllFilial(,,,.F.)
	If Len(aFilial) > 0
		
		For nCnt := 1 to LEN(aFilial)
			//Filial 1
			//Descrição 2
			cFilName := FWSM0Util():GetSM0Data( , aFilial[nCnt], { "M0_FILIAL" } )[1,2] // Ticket #9406673 04/08/2020 - Eduardo Williams - Performance da rotina. Trocada função FwFilialName pela Classe FWSM0Util
			If !(EMPTY(::Filtro)) .AND. !(EMPTY(::Campo))
				If ::Campo == "2"
					If ALLTRIM(UPPER(::Filtro)) $ cFilName //UPPER(FWFILIALNAME(,aFilial[nCnt])) // Ticket #9406673 04/08/2020 - Eduardo Williams - Performance da rotina. Trocada função FwFilialName pela Classe FWSM0Util
						lLoop := .F.
					Else
						lLoop := .T.
					EndIf
				Else
					If ALLTRIM(UPPER(::Filtro)) == aFilial[nCnt]
						lLoop := .F.
					Else
						lLoop := .T.
					EndIf
				EndIf
			EndIf
			If !lLoop
				//AADD(aAux,{aFilial[nCnt],FWFilialName(,aFilial[nCnt])})
				AADD(aAux,{aFilial[nCnt], cFilName}) // Ticket #9406673 04/08/2020 - Eduardo Williams - Performance da rotina. Trocada função FwFilialName pela Classe FWSM0Util
			EndIf
		Next nCnt
		If Len(aAux) > 0
			::_ListOfallfil := WSClassNew( "_allfil" )
			::_ListOfallfil:PagesTotal       := Ceiling(Len(aAux) / PAGE_LENGTH)
			::_ListOfallfil:ListOfallfil := {}
			
			If ::Page > 1
				nPosIni := ((Self:Page-1) * PAGE_LENGTH) + 1
			EndIf
			
			oSolicita :=  WSClassNew( "allfil" )
			For nCnt := nPosIni To Len(aAux)
				oSolicita:FILIAIS   := aAux[nCnt][1]
				oSolicita:DESCRICAO := aAux[nCnt][2]
				AAdd( ::_ListOfallfil:ListOfallfil, oSolicita )
				oSolicita :=  WSClassNew( "allfil" )
				
				If len(::_ListOfallfil:ListOfallfil) >= PAGE_LENGTH
					Exit
				EndIf
			Next
		Else
			::_ListOfallfil := WSClassNew( "_allfil" )
			::_ListOfallfil:PagesTotal := 1
			::_ListOfallfil:ListOfallfil := {}
			oSolicita :=  WSClassNew( "allfil" )
			oSolicita:FILIAIS   := ""
			oSolicita:DESCRICAO := ""
			AAdd( ::_ListOfallfil:ListOfallfil, oSolicita )
		EndIf
	Else
		::_ListOfallfil := WSClassNew( "_allfil" )
		::_ListOfallfil:PagesTotal := 1
		::_ListOfallfil:ListOfallfil := {}
		oSolicita :=  WSClassNew( "allfil" )
		oSolicita:FILIAIS   := ""
		oSolicita:DESCRICAO := ""
		AAdd( ::_ListOfallfil:ListOfallfil, oSolicita )
	EndIf
Return .T.

WsMethod RetDepartamentos WsReceive FilRepor, Filtro, Campo, Ocupados, PAGE WsSend _ListOfalldepart WsService W1302100
	
	Local cRet    := ""
	Local cQuery  := ""
	Local cAlias1 := "TMPSQB"
	
	Local aDepts  := {}
	Local nPosIni := 1
	Local nX      := 0

	cQuery := "SELECT SQB.QB_DEPTO, SQB.QB_DESCRIC "
	cQuery += "FROM	" + RetSqlName("SQB") + " SQB "
	If Ocupados == "S"
		cQuery += "INNER JOIN "+RetSqlName("RCL")+" RCL "
		cQuery += "ON RCL.RCL_FILIAL = SQB.QB_FILIAL AND  RCL.RCL_DEPTO = SQB.QB_DEPTO "
	EndIf
	cQuery += "WHERE SQB.QB_FILIAL = '" + ::FilRepor + "' AND SQB.D_E_L_E_T_ = ' ' "
	If !(EMPTY(::Filtro)) .AND. !(EMPTY(::Campo))
		If ::Campo == "QB_DEPTO"
			cQuery += "AND SQB." + ::Campo + " = '" + ::Filtro + "' "
		ElseIf ::Campo == "QB_DESCRIC"
			cQuery += "AND SQB." + ::Campo + " LIKE '%" + ::Filtro + "%' "
		EndIf
	EndIf
	
	cQuery += " Group By SQB.QB_DEPTO, SQB.QB_DESCRIC"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1)

	While !(cAlias1)->(EOF())
		aAdd(aDepts,{(cAlias1)->QB_DEPTO,(cAlias1)->QB_DESCRIC})
		(cAlias1)->(DbSkip())
	End
	
	If Len(aDepts) > 0
		::_ListOfalldepart := WSClassNew( "_alldepart" )
		::_ListOfalldepart:PagesTotal       := Ceiling(Len(aDepts) / PAGE_LENGTH)
		::_ListOfalldepart:ListOfalldepart := {}
		
		If ::Page > 1
			nPosIni := ((Self:Page-1) * PAGE_LENGTH) + 1
		EndIf
		
		oSolicita :=  WSClassNew( "alldepart" )
		For nX := nPosIni To Len(aDepts)		
			oSolicita:Department   := aDepts[nX][1]
			oSolicita:DescrDepartment := aDepts[nX][2]		
			AAdd( ::_ListOfalldepart:ListOfalldepart, oSolicita )
			oSolicita :=  WSClassNew( "alldepart" )
			
			If len(::_ListOfalldepart:ListOfalldepart) >= PAGE_LENGTH
				Exit
			EndIf			
		Next nX
	Else
		::_ListOfalldepart := WSClassNew( "_alldepart" )
		::_ListOfalldepart:PagesTotal := 1
		::_ListOfalldepart:ListOfalldepart := {}
		oSolicita :=  WSClassNew( "alldepart" )
		oSolicita:Department   := ""
		oSolicita:DescrDepartment := ""
		AAdd( ::_ListOfalldepart:ListOfalldepart, oSolicita )
	EndIf

	(cAlias1)->(DbCloseArea())
	
Return .T.

WsMethod RetPostos WsReceive EmployeeFil,DepartmentID, Page, FilterField, FilterValue WsSend _ListOfallpostos WsService W1302100
	
	Local cAuxAlias := "QRCL"
	Local aSx3Box   := RetSx3Box( Posicione("SX3", 2, "RCL_TPOSTO", "X3CBox()" ),,, 1 )
	Local cQuery    := ""	
	Local aPostDp   := {}
	Local nPosIni   := 1
	Local nX        := 0
   		
	DEFAULT Self:Page         := 1
	DEFAULT Self:DepartmentID := ""
	DEFAULT Self:FilterField  := ""
	DEFAULT Self:FilterValue  := ""
	DEFAULT Self:RequestType  := ""
	DEFAULT Self:EmployeeFil  := ""
		
	cQuery := "SELECT RCL.* "
	cQuery += "FROM " + RetSqlName("RCL") + " RCL "
	cQuery += "WHERE RCL.D_E_L_E_T_ = ' ' "
	cQuery += "AND RCL.RCL_STATUS IN('1','2') "
	cQuery += "AND RCL.RCL_FILIAL = '" + ::EmployeeFil + "' "
	cQuery += "AND RCL.RCL_DEPTO = '" + ::DepartmentID + "' "
	If !(EMPTY(::FilterField)) .AND. !(EMPTY(::FilterValue))
		cQuery += "AND RCL." + ::FilterField + " = '" + ::FilterValue + "' "
	EndIf
	cQuery += "ORDER BY RCL.RCL_FILIAL,RCL.RCL_POSTO "
		
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAuxAlias)
	
	While !(cAuxAlias)->(EOF())
		aAdd(aPostDp,{(cAuxAlias)->RCL_POSTO,;
			 Alltrim(aSx3Box[Ascan( aSx3Box, { |aBox| aBox[2] = (cAuxAlias)->RCL_TPOSTO  } )][3]),;
			(cAuxAlias)->RCL_NPOSTO,;
			(cAuxAlias)->RCL_OPOSTO,;
		     Alltrim(Posicione("SRJ",1,xFilial("SRJ",(cAuxAlias)->RCL_FILIAL)+(cAuxAlias)->RCL_FUNCAO,"RJ_DESC")),;
		     Alltrim(Posicione("SQ3",1,xFilial("SQ3",(cAuxAlias)->RCL_FILIAL)+(cAuxAlias)->RCL_CARGO,"Q3_DESCSUM")),;
		     RespPosto((cAuxAlias)->RCL_FILIAL,(cAuxAlias)->RCL_POSTO),;
		     (cAuxAlias)->RCL_FILIAL})
	(cAuxAlias)->(DbSkip())
	End
	
	If Len(aPostDp) > 0
		::_ListOfallpostos := WSClassNew( "_allpostos" )
		::_ListOfallpostos:PagesTotal       := Ceiling(Len(aPostDp) / PAGE_LENGTH)
		::_ListOfallpostos:ListOfallpostos := {}
		
		If ::Page > 1
			nPosIni := ((Self:Page-1) * PAGE_LENGTH) + 1
		EndIf
		
		oSolicita :=  WSClassNew( "allpostos" )
		For nX := nPosIni To Len(aPostDp)
			oSolicita:PostFilial  := aPostDp[nX][8]	
			oSolicita:Posto       := aPostDp[nX][1]
			oSolicita:DescrTipo   := aPostDp[nX][2]
			oSolicita:Qtd         := aPostDp[nX][3]
			oSolicita:Ocupado     := aPostDp[nX][4]
			oSolicita:DescrFuncao := aPostDp[nX][5]
			oSolicita:DescrCargo  := aPostDp[nX][6]
			oSolicita:Responsavel := aPostDp[nX][7]
			AAdd( ::_ListOfallpostos:ListOfallpostos, oSolicita )
			oSolicita :=  WSClassNew( "allpostos" )
			
			If len(::_ListOfallpostos:ListOfallpostos) >= PAGE_LENGTH
				Exit
			EndIf			
		Next nX
	Else
		::_ListOfallpostos := WSClassNew( "_allpostos" )
		::_ListOfallpostos:PagesTotal := 1
		::_ListOfallpostos:ListOfallpostos := {}
		oSolicita :=  WSClassNew( "allpostos" )
		oSolicita:PostFilial  := ""
		oSolicita:Posto       := ""
		oSolicita:DescrTipo   := ""
		oSolicita:Qtd         := ""
		oSolicita:Ocupado     := ""
		oSolicita:DescrFuncao := ""
		oSolicita:DescrCargo  := ""
		oSolicita:Responsavel := ""
		AAdd( ::_ListOfallpostos:ListOfallpostos, oSolicita )
	EndIf

	(cAuxAlias)->(DbCloseArea())
	
Return .T.

Static Function RespPosto(cFilPos, cCodPos)
	Local aAux		:= {}
	Local aAreaRD4	:= RD4->(GetArea())
	Local aAreaSRA	:= SRA->(GetArea())
	Local aAreaRCX	:= RCX->(GetArea())
	Local cAlias1	:= GetNextAlias()
	Local cCodResp	:= ""
	Local cCodRD4	:= ""
	Local cFilResp	:= ""
	Local cItemRD4		:= ""
	Local cQuery 	:= ""
	Local cRet		:= "Vazio"
	
	RD4->(DbSetOrder(6))
	
	If RD4->(DbSeek(xFilial("RD4")+ cEmpAnt + cFilPos + cCodPos))
		cCodRD4	 := RD4->RD4_CODIGO
		cItemRD4 := RD4->RD4_TREE

		RD4->(DbSetOrder(1))
		If RD4->(DbSeek(xFilial("RD4")+ cCodRD4 + cItemRD4))
			cFilResp	:= RD4->RD4_FILIDE
			cCodResp	:= RD4->RD4_CODIDE

			If RCX->(DbSeek(cFilResp + cCodResp))
				cRet := ""
				While RCX->(RCX_FILIAL + RCX_POSTO) == (cFilResp + cCodResp)
					If !Empty(cRet)
						cRet += ", "
					EndIf
					If SRA->(DbSeek(RCX->(RCX_FILFUN + RCX_MATFUN)))
						cRet += SRA->RA_NOME
					EndIf
					RCX->(DbSkip())
				EndDo
			EndIf
		EndIf
	EndIf
	
	RestArea(aAreaRD4)
	RestArea(aAreaSRA)
	RestArea(aAreaRCX)

Return cRet


WsMethod AllCntrCusto WsReceive cFilP,cDepto WsSend _CntrCusto WsService W1302100

	Local cQuery 	:= ''
	Local cAlias1	:= GetNextAlias()
	//Alterar para pegar o centro de custo do departamento
	cQuery := "SELECT DISTINCT CTT_CUSTO, CTT_DESC01 FROM " + RetSqlName("CTT") + "  CTT "
	cQuery += "RIGHT JOIN " + RetSqlName("SQB") + " SQB "
	cQuery += "ON QB_FILIAL = '" + cFilP + "' "
	cQuery += "AND QB_DEPTO = '" + cDepto + "' "
	cQuery += "AND SQB.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE CTT_CUSTO = QB_CC "
	cQuery += "AND CTT.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1)
	
	If !(cAlias1)->(EOF())
		::_CntrCusto:CodCC   := (cAlias1)->(CTT_CUSTO)
		::_CntrCusto:DescC   := (cAlias1)->(CTT_DESC01)
	Else
		::_CntrCusto:CodCC   := ""
		::_CntrCusto:DescC   := ""
	EndIf
	(cAlias1)->(DbCloseArea())
	
Return .T.

WsMethod AllBuscDepto WsReceive cDepto, FilPosto, CodPosto WsSend nTotal WsService W1302100

	::nTotal := U_F0500314(::cDepto, ::FilPosto, ::CodPosto)

Return .T.

WsMethod RETFUNCRG WsReceive Filtro, Campo, PAGE WsSend _ListOfallfuncao WsService W1302100

	Local cRet    := ""
	Local cQuery  := ""
	Local cAlias1 := "TMPSRJ"
	
	Local aFuncao := {}
	Local nPosIni := 1
	Local nX      := 0

	cQuery := "SELECT SRJ.RJ_FUNCAO, SRJ.RJ_DESC "
	cQuery += "FROM	" + RetSqlName("SRJ") + " SRJ "
	cQuery += "WHERE SRJ.D_E_L_E_T_ = ' ' "
	cQuery += "AND SRJ.RJ_MSBLQL = '2'" // ticket n° 3025970 - 14/06/2018 - Paulo Dias - nova atribuição na condicional. Não levar funções bloqueadas ao portal.
	
	If !(EMPTY(::Filtro)) .AND. !(EMPTY(::Campo))
		If ::Campo == "RJ_FUNCAO"
			cQuery += "AND SRJ.RJ_FUNCAO = '" + ::Filtro + "' "
		ElseIf ::Campo == "RJ_DESC"
			cQuery += "AND SRJ.RJ_DESC LIKE UPPER('%" + ::Filtro + "%') "
		EndIf
	EndIf
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1)

	While !(cAlias1)->(EOF())
		aAdd(aFuncao,{(cAlias1)->RJ_FUNCAO,(cAlias1)->RJ_DESC})
	(cAlias1)->(DbSkip())
	End

	If Len(aFuncao) > 0
		::_ListOfallfuncao := WSClassNew( "_allfuncao" )
		::_ListOfallfuncao:PagesTotal       := Ceiling(Len(aFuncao) / PAGE_LENGTH)
		::_ListOfallfuncao:ListOfallfuncao := {}
		
		If ::Page > 1
			nPosIni := ((Self:Page-1) * PAGE_LENGTH) + 1
		EndIf
		
		oSolicita :=  WSClassNew( "allfuncao" )
		For nX := nPosIni to Len(aFuncao)
			oSolicita:Codigo    := aFuncao[nX][1]
			oSolicita:Descricao := aFuncao[nX][2]		
			AAdd( ::_ListOfallfuncao:ListOfallfuncao, oSolicita )
			oSolicita :=  WSClassNew( "allfuncao" )
			
			If len(::_ListOfallfuncao:ListOfallfuncao) >= PAGE_LENGTH
				Exit
			EndIf			
		Next
	Else
		::_ListOfallfuncao := WSClassNew( "_allfuncao" )
		::_ListOfallfuncao:PagesTotal := 1
		::_ListOfallfuncao:ListOfallfuncao := {}
		oSolicita :=  WSClassNew( "allfuncao" )
		oSolicita:Codigo    := ""
		oSolicita:Descricao := ""
		AAdd( ::_ListOfallfuncao:ListOfallfuncao, oSolicita )
	EndIf

	(cAlias1)->(DbCloseArea())

Return .T.
