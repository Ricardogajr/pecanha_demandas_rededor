#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "rwmake.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "Tbiconn.CH"
#Include "TOTVS.ch"
/*/{Protheus.doc} F1200701
	
	Seleção de itens de solicitação de compra para medição automatizada.
	
	@type Function User
	@Author     Paulo Krüger
	@Since      15/08/2017
	@Version    P12.7
	@Param		lExibeTela ,logical, Se .T., exibe markbrowsers e telas de processamento 
	@Param		lVerUsrLog ,logical,  Verifica grupo de compras do usuário logado 
	@Param		lVerCtr    ,logical,  Verifica contratos 
	@Param		mv_par01   ,character,  Filial de
	@Param		mv_par02   ,character,  Filial ate
	@Param		mv_par03   ,character,  Solicitacao de Compra de
	@Param		mv_par04   ,character,  Solicitacao de Compra ate
	@Param		mv_par05   ,Date,  Data de Emissao de
	@Param		mv_par06   ,Date,  Data de Emissao ate
	@Param		mv_par07   ,character,  Produto de
	@Param		mv_par08   ,character,  Produto ate
	@Obs    MAN0000007423046
/*/
User Function F1200701(lExibeTela, lVerUsrLog, lVerCtr, mv_par01, mv_par02, mv_par03, mv_par04, mv_par05, mv_par06, mv_par07, mv_par08)

	Local aCtr         := {}
	Local aFieFilter   := {}
	Local aSeek        := {}
	Local aStru        := {}
	Local cAlias01     := ''
	Local cFilOri      := ''
	Local cGrpComLog   := ''
	Local cTpSemAprv   := ''
	Local cTpSemMed    := '' 
	Local cUserLog     := ''
	Local nCont        := 0
	Local nContGrp     := 0
	Local nX           := 0
	Local cDias        := GetNewPar("FS_F12701D","60")
	Private aAgrup     := {}
	Private aColumns   := {}
	Private aId        := {}
	Private aListMedic := {}
	Private aProdSel   := {}
	Private aRotina    := {}
	Private aSelContr  := {}
	Private cArqTrab   := GetNextAlias()
	Private oDlgMark
	Private oMrkBrowse
	Default lExibeTela := .T.
	Default lVerUsrLog := .T.

	cFilOri		:= xFilial('SC1')
	cUserLog	:= RetCodUsr()
	cTpSemMed	:= U_F1200702(GetMV('FS_XTPSCME'))	//Tipos que NÃO serao considerados pela rotina de Medicao Automatizada
	cTpSemAprv	:= U_F1200702(GetMV('FS_XTPSCCA'))	//Tipos de solicitacoes de compras que NÃO terao aprovacao de Alcadas

	If	lVerUsrLog //Quando chamado por medição manual ou medição automatizada, verifica grupo de compras do usuário.
		cAlias01 := GetNextAlias()
		BeginSql Alias cAlias01
			SELECT	SAJ.AJ_GRCOM GRCOM
			FROM	%Table:SAJ% SAJ
			WHERE  SAJ.%notDel%
					AND SAJ.AJ_FILIAL	= %Exp:cFilOri%
					AND SAJ.AJ_USER		= %Exp:cUserLog%
		EndSql

		While !(cAlias01)->(Eof())
			nContGrp	+= 01
			cGrpComLog	:= "'"
			(cAlias01)->(dbSkip())
		EndDo

		(cAlias01)->(DbGoTop())

		While !(cAlias01)->(Eof())
			nCont += 01
			cGrpComLog += (cAlias01)->GRCOM
			If nCont < nContGrp
				cGrpComLog += "','"
			ElseIf nCont == nContGrp
				cGrpComLog += "'"
			EndIf
			(cAlias01)->(DbSkip())
		EndDo
		(cAlias01)->(DbCloseArea())
		nCont	:=	0
		nContGrp:=	0
	EndIf

	oTempTable := FWTemporaryTable():New( cArqTrab )

	If lExibeTela
		cQuery := "SELECT ' ' TMP_OK, " + CRLF
		cQuery += "SC1.R_E_C_N_O_ RECNO, " + CRLF
	Else
		cQuery := "SELECT SC1.R_E_C_N_O_ RECNO, " + CRLF
	Endif
	cQuery += "SC1.C1_USER, " + CRLF
	cQuery += "SC1.C1_FILIAL, " + CRLF
	cQuery += "SC1.C1_NUM, " + CRLF
	cQuery += "SC1.C1_ITEM, " + CRLF
	cQuery += "SC1.C1_PRODUTO, " + CRLF
	cQuery += "SC1.C1_DESCRI, " + CRLF
	cQuery += "SC1.C1_QUANT, " + CRLF
	cQuery += "SC1.C1_XTOTAL, " + CRLF
	cQuery += "SC1.C1_TOTAL, " + CRLF
	cQuery += "SC1.C1_LOCAL, " + CRLF
	cQuery += "SC1.C1_EMISSAO, " + CRLF
	cQuery += "SC1.C1_FORNECE, " + CRLF
	cQuery += "SC1.C1_LOJA, " + CRLF
	cQuery += "SC1.C1_GRUPCOM, " + CRLF
	cQuery += "SC1.C1_OBS, " + CRLF
	cQuery += "SC1.C1_VUNIT, " + CRLF
	cQuery += "SC1.C1_CC, " + CRLF
	cQuery += "SC1.C1_XTPSC, " + CRLF
	cQuery += "SC1.C1_FLAGGCT, " + CRLF
	cQuery += "SC1.C1_CONTA, " + CRLF
	cQuery += "SC1.C1_ITEMCTA, " + CRLF
	cQuery += "SC1.C1_CLVL, " + CRLF
	cQuery += "SC1.C1_XCODSET, " + CRLF
	cQuery += "SC1.C1_XINFPAC, " + CRLF
	cQuery += "SC1.C1_XMOTIVO, " + CRLF
	cQuery += "SC1.C1_XNUMMED, " + CRLF
	cQuery += "SC1.C1_DATPRF, " + CRLF
	cQuery += "SAJ.AJ_FILIAL" + CRLF
	cQuery += "FROM " + RETSQLNAME('SC1') + " SC1 LEFT JOIN " + RETSQLNAME('SAJ') + " SAJ ON " + CRLF
	cQuery += "SAJ.AJ_FILIAL = SC1.C1_FILIAL " + CRLF
	cQuery += "AND SAJ.AJ_GRCOM = SC1.C1_GRUPCOM " + CRLF
	If IsInCallStack('U_F1200601') //Quando vier de medição manual
		cQuery += "AND SAJ.AJ_USER = '" + cUserLog + "' " + CRLF
	Else
		cQuery += "AND SAJ.AJ_USER = SC1.C1_USER " + CRLF
	EndIf
	cQuery += "AND SAJ.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE SC1.C1_QUJE = 0 " + CRLF
	cQuery += "AND SC1.C1_RESIDUO <> 'S'" + CRLF
	cQuery += "AND SC1.C1_COTACAO =  '" + Space(TAMSX3("C1_COTACAO")[1]) + "' " + CRLF
	cQuery += "AND (SC1.C1_APROV = ' ' OR  SC1.C1_APROV = 'L')  " + CRLF
	cQuery += "AND SC1.D_E_L_E_T_= ' ' " + CRLF
	cQuery += "AND SC1.C1_FLAGGCT <> '1' " + CRLF
	cQuery += "AND SC1.C1_XENVBIO = ' ' " + CRLF


	If lVerUsrLog
		If !Empty(cGrpComLog)
			cQuery += "AND (SC1.C1_GRUPCOM = '' OR " + CRLF
			cQuery += "SC1.C1_GRUPCOM IN (" + cGrpComLog + ") OR " + CRLF
			cQuery += "SAJ.AJ_GRCOM IS NOT NULL) " + CRLF
		Else
			cQuery += "AND (SC1.C1_GRUPCOM = '' OR " + CRLF
			cQuery += "SAJ.AJ_GRCOM IS NOT NULL)               " + CRLF
		EndIf
	EndIf

	If !Empty(cTpSemMed)
		cQuery += "AND SC1.C1_XTPSC NOT IN (" + cTpSemMed + ") " + CRLF
	EndIf

	If ISINCALLSTACK('U_F1200600') //Quando vier de medição schedule, incrementa filtros
		cQuery += "AND SC1.C1_FILIAL = '" + mv_par01 + "' " + CRLF
		//Performance de rotina para pegar SCS de até 2 meses schedule - Lucas Miranda 16/09/2024
		cQuery += " AND TO_DATE(C1_EMISSAO, 'YYYYMMDD') BETWEEN TRUNC(SYSDATE) - "+cDias+ " AND TRUNC(SYSDATE) "
	EndIf

	If ISINCALLSTACK('U_F1200601') //Quando vier de medição manual, incrementa filtros
		cQuery += "AND SC1.C1_FILIAL >= '" + mv_par01       + "' AND SC1.C1_FILIAL <= '" + mv_par02       + "' " + CRLF
		cQuery += "AND SC1.C1_NUM >= '" + mv_par03       + "' AND SC1.C1_NUM <= '" + mv_par04       + "' " + CRLF
		cQuery += "AND SC1.C1_EMISSAO >= '" + DTOS(mv_par05) + "' AND SC1.C1_EMISSAO <= '" + DTOS(mv_par06) + "' " + CRLF
		cQuery += "AND SC1.C1_PRODUTO >= '" + mv_par07       + "' AND SC1.C1_PRODUTO <= '" + mv_par08       + "' " + CRLF
		cQuery += "AND SC1.C1_XENVBIO = ' ' " + CRLF
	EndIf

	//cQuery += " AND SC1.C1_FILIAL = '01310011' AND SC1.C1_NUM = '002338' "


	cQuery += "ORDER BY "  + SqlOrder(SC1->(IndexKey()))

	cChave		:= SC1->(IndexKey())

	If lExibeTela
		AAdd(aStru, {"TMP_OK", 'C', 1 , 0 })
	EndIf

	AAdd(aStru, {"RECNO" , 'N', 10, 0 })
	AAdd(aStru, {"C1_USER",'C',6,0})
	AAdd(aStru, {"C1_FILIAL",'C',8,0})
	AAdd(aStru, {"C1_NUM",'C',6,0})
	AAdd(aStru, {"C1_ITEM",'C',4,0})
	AAdd(aStru, {"C1_PRODUTO",'C',15,0})
	AAdd(aStru, {"C1_DESCRI",'C',70,0})
	AAdd(aStru, {"C1_QUANT",'N',18,4})
	AAdd(aStru, {"C1_XTOTAL",'N', 14,2})
	AAdd(aStru, {"C1_TOTAL",'N',14,2})
	AAdd(aStru, {"C1_LOCAL",'C',6,0})
	AAdd(aStru, {"C1_EMISSAO",'D',8,0})
	AAdd(aStru, {"C1_DATPRF",'D',8,0})
	AAdd(aStru, {"C1_FORNECE",'C',6,0})
	AAdd(aStru, {"C1_LOJA",'C',2,0})
	AAdd(aStru, {"C1_GRUPCOM",'C',6,0})
	AAdd(aStru, {"C1_OBS",'C',80,0})
	AAdd(aStru, {"C1_VUNIT",'N',18,7})
	AAdd(aStru, {"C1_CC",'C',11,0})
	AAdd(aStru, {"C1_XTPSC",'C',2,0})
	AAdd(aStru, {"C1_FLAGGCT",'C',1,0})
	AAdd(aStru, {"C1_CONTA",'C',20,0})
	AAdd(aStru, {"C1_ITEMCTA",'C',11,0})
	AAdd(aStru, {"C1_CLVL",'C',11,0})
	AAdd(aStru, {"C1_XCODSET",'C',6,0})
	AAdd(aStru, {"C1_XINFPAC",'C',254,0})
	AAdd(aStru, {"C1_XMOTIVO",'C',2,0})
	AAdd(aStru, {"C1_XNUMMED",'C',6,0})
	AAdd(aStru, {"AJ_FILIAL",'C',8,0})


	oTemptable:SetFields( aStru )
	oTempTable:AddIndex("indice1", {"C1_FILIAL"} )
	oTempTable:AddIndex("indice2", {"C1_NUM"} )
	oTempTable:AddIndex("indice3", {"C1_ITEM"} )
	oTempTable:AddIndex("indice4", {"C1_PRODUTO"} )


	Aadd(aFieFilter,{"C1_FILIAL"	, "Filial"  , "C", 08, 0,"@!"})
	Aadd(aFieFilter,{"C1_NUM"		, "Pedido"	, "C", 06, 0,"@!"})
	Aadd(aFieFilter,{"C1_ITEM"		, "Item"	, "C", 04, 0,"@!"})
	Aadd(aFieFilter,{"C1_PRODUTO"	, "Produto" , "C", 15, 0,"@!"})


	If lExibeTela //A função IndRegua cria um índice temporário para o alias especificado, podendo ou não ter um filtro
		oTempTable:Create()
		(cArqTrab)->(DbSetOrder(0))
		//Processa({||SqlToTrb(cQuery, aStru, cArqTrab)})
		Processa({||xSqlToTrb(cQuery, aStru, cArqTrab,lExibeTela)})//Criada nova função para inserir dados na tabela temporária, melhora consideravel na performance - Lucas Miranda de Aguiar 17/09/2024
	Else
		oTempTable:Create()
		//SqlToTrb(cQuery, aStru, cArqTrab)
		xSqlToTrb(cQuery, aStru, cArqTrab,lExibeTela)//Criada nova função para inserir dados na tabela temporária, melhora consideravel na performance - Lucas Miranda de Aguiar 17/09/2024
	EndIf

	If lExibeTela
		For nX := 1 To Len(aStru)
			If	aStru[nX][1] $ "C1_FILIAL|C1_NUM|C1_ITEM|C1_PRODUTO|C1_DESCRI|C1_QUANT|C1_VUNIT|C1_XTOTAL|C1_LOCAL|C1_EMISSAO|C1_DATPRF|C1_CC|C1_XTPSC|C1_FLAGGCT|C1_GRUPCOM|C1_OBS|R_E_C_N_O_|"
				AAdd(	aColumns, FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData( &("{||" + aStru[nX][1] + "}") )
				aColumns[Len(aColumns)]:SetTitle(RetTitle(aStru[nX][1]))
				aColumns[Len(aColumns)]:SetSize(aStru[nX][3])
				aColumns[Len(aColumns)]:SetDecimal(aStru[nX][4])
				aColumns[Len(aColumns)]:SetPicture(PesqPict("SC1", aStru[nX][1]))

				If aStru[nX,1] == "C1_FILIAL"
					AAdd(	aColumns, FWBrwColumn():New())
					aColumns[Len(aColumns)]:SetData( {|| RetNomeFil() } )
					aColumns[Len(aColumns)]:SetTitle('Descrição filial')
					aColumns[Len(aColumns)]:SetSize(41)
					aColumns[Len(aColumns)]:SetDecimal(0)
					aColumns[Len(aColumns)]:SetPicture("@!")
				EndIf

			EndIf

		Next

		(cArqTrab)->(DbGoTop())
		If !(cArqTrab)->(Eof())
			If lVerCtr
				While !(cArqTrab)->(Eof())
					aCtr := U_F1200101((cArqTrab)->C1_FILIAL, (cArqTrab)->C1_PRODUTO, '', .F.)
					If Len(aCtr) != 1
						(cArqTrab)->(Rlock())
						(cArqTrab)->(DbDelete())
						aCtr := {}
					EndIf
					(cArqTrab)->(DbSkip())
				EndDo
			EndIf

			DEFINE MSDIALOG oDlgMark TITLE 'Medições de contratos' FROM 000, 000  TO 800, 1000 COLORS 0, 16777215 PIXEL Style DS_MODALFRAME

			aAdd(aSeek,{"Filial"	,{{"","C",TamSX3("C1_FILIAL")[1]	,0,"Filial"	,"@!"}} } )
			aAdd(aSeek,{"Numero"	,{{"","C",TamSX3("C1_NUM")[1]		,0,"Numero"	,"@!"}} } )
			aAdd(aSeek,{"Item"		,{{"","C",TamSX3("C1_ITEM")[1]		,0,"Item"	,"@!"}} } )
			aAdd(aSeek,{"Produto"	,{{"","C",TamSX3("C1_PRODUTO")[1]	,0,"Produto","@!"}} } )

			oMrkBrowse:= FWMBrowse():New()
			oMrkBrowse:SetAlias(cArqTrab)
			oMrkBrowse:SetMenuDef("F1200701")
			//Comentando trecho abaixo para performance da rotina Lucas Miranda de Aguiar 16/09/2024
			//oMrkBrowse:SetFilterDefault("(cArqTrab)->C1_FLAGGCT <> '1' .and. !(cArqTrab)->(Deleted())")

			oMrkBrowse:SetDBFFilter(.T.)
			oMrkBrowse:SetUseFilter(.T.) //Habilita a utilização do filtro no Browse
			oMrkBrowse:SetFixedBrowse(.T.)
			oMrkBrowse:SetWalkThru(.F.) //Habilita a utilização da funcionalidade Walk-Thru no Browse
			oMrkBrowse:SetAmbiente(.T.) //Habilita a utilização da funcionalidade Ambiente no Browse
			oMrkBrowse:SetTemporary() //Indica que o Browse utiliza tabela temporária
			oMrkBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse

			oColumn := oMrkBrowse:AddMarkColumns({||If(!Empty((cArqTrab)->TMP_OK)/*Função de Marca/desmaca*/,'LBOK','LBNO')},{|oMrkBrowse| Marca() })

			oMrkBrowse:SetFieldFilter(aFieFilter)

			If ISINCALLSTACK('U_F1200601')
				oMrkBrowse:SetDescription('Medicao Automatica')
			Else
				oMrkBrowse:SetDescription('Medicao Automatizada')
			EndIf

			oMrkBrowse:SetColumns(aColumns)
			oMrkBrowse:Activate()

			If Type("oDlgMark") != "U"
				oDlgMark:lMaximized := .T.
				ACTIVATE MSDIALOG oDlgMark
			EndIf


		EndIf

	Else
		//Job e schedule
		U_F1200703(cArqTrab)
	EndIf

	If !Empty(cArqTrab)
		dbSelectArea(cArqTrab)
		dbCloseArea()
		Ferase(cArqTrab + GetDBExtension())
		Ferase(cArqTrab + OrdBagExt())
		cArqTrab := ''
		dbSelectArea('SC1')
		SC1->(DbSetOrder(1))
	EndIf

	If Type("oDlgMark") != "U"
		oTempTable:Delete()
	EndIf

Return NIL
/*/{Protheus.doc} RetNomeFil
	
	Retorno o nome da filial
	
	@author  Alex Sandro Valario
	@type Function Static
	@since   15/08/2017
	@Obs   MAN0000007423046_EF_003

/*/
Static Function RetNomeFil()
	Local cNomeFil := 'Não Encontrado'
	Local aArea    := SM0->(fwgetArea('SM0'))
	Local nRecno   := SM0->(Recno())
	Local cFilSC1  := (Alias())->C1_FILIAL

	SM0->(DbSetOrder(1))
	If SM0->(DbSeek(cEmpAnt + cFilSC1))
		cNomeFil := SM0->M0_FILIAL
	EndIf
	SM0->(fwrestarea(aArea))
	SM0->(DbGoto(nRecno))

Return cNomeFil
/*/{Protheus.doc} MenuDEF
	Menu do Browse de Medição Automatizada
	@type Function Static
	@author 	Paulo Krüger
	@since 		08/09/2017
	@version 	P12.7
	@Obs   MAN00000462901_EF_001
	@Return 	Array, Retorna a Rotina a ser inclusa no Menu.
/*/
Static Function MenuDef()
	Local aRotina := {}


	aadd(aRotina,{"Processar","Processa( {|| U_PrcManu() }, 'Aguarde...', 'Verificando contratos...',.F.)",0,2})


//	ADD OPTION aRotina TITLE 'Processar' 	ACTION 'U_PrcManu()' OPERATION 2 ACCESS 0 // ticket n° 7182557 - 415966 - Paulo Dias - Função de bloqueio quando Schedule estiver ativo

Return aRotina
/*/{Protheus.doc} Marca

	Marca se registro já está sendo utilizado por outra rotina e não pode ser selecionado

	@type  Function Static
	@version 12.1.27
	@author  Cleiton Genuino da Silva
	@since   25/07/2023
/*/
Static Function Marca()
	If Empty((cArqTrab)->TMP_OK)
		If IsInUse()
			MsgAlert("Este registro já está sendo utilizado por outra rotina e não pode ser selecionado.")
		Else
			RecLock((cArqTrab),.F.)
			(cArqTrab)->TMP_OK := "S"
			(cArqTrab)->(MsUnlock())

			ShiftSC1((cArqTrab)->RECNO)
		EndIf
	Else
		RecLock((cArqTrab),.F.)
		(cArqTrab)->TMP_OK := " "
		(cArqTrab)->(MsUnlock())

		ShiftSC1((cArqTrab)->RECNO)
	EndIf
Return
/*/{Protheus.doc} PrcManu

	Checa se esta em uso pelo job ou por outra rotina

	@type  Function User
	@version 12.1.27
	@author  Cleiton Genuino da Silva
	@since   25/07/2023
/*/
Static Function IsInUse()
	Local lRet  := .F.       as logical
	Local aArea := fwGetArea() as array

	If !empty((cArqTrab)->C1_XNUMMED) .and. ((cArqTrab)->C1_XNUMMED == "XXXXXX" .or. (cArqTrab)->C1_XNUMMED == "ZZZZZZ")
		If SC1->(DbSeek((cArqTrab)->C1_FILIAL + (cArqTrab)->C1_NUM +  (cArqTrab)->C1_ITEM  ))
			lRet := U_ScUnlock()
		EndIf
	EndIf

	fwrestarea(aArea)

Return lRet
/*/{Protheus.doc} ShiftSC1

	 Função , Alterna o conteudo do campo TMP_OK ao clicar no browse na tela e altera a SC1 nos campos
	 	C1_XNUMMED : número da medição do pedido
		C1_XUSR    : usuário que iniciou a medição

	@type  Function Static
	@version 12.1.27 Versão.20230604
	@author  Cleiton Genuino da Silva
	@since   04/06/2023 at 00:09
	@param nRecSC1,	numeric		, Recno da tabela SC1 para marcar o registro
	@obs Projeto: Incluido nome e grupo do usuário na medição
/*/
Static Function ShiftSC1(nRecSC1)
	default nRecSC1 := 0

	If nRecSC1 > 0
		SC1->( DbGoTo( nRecSC1 ) )
		If SC1->(!Eof()) .And. SC1->( RecNo() ) == nRecSC1
			If RecLock("SC1",.F.)
				If empty(SC1->C1_XNUMMED) //Se está vazio, marca
					SC1->C1_XNUMMED := "XXXXXX"
					SC1->C1_XUSR    := RetCodUsr()
				ElseIf SC1->C1_XNUMMED == "XXXXXX"
					SC1->C1_XNUMMED := ''
					SC1->C1_XUSR    := ''
				Else
					RecLock((cArqTrab),.F.)
					(cArqTrab)->TMP_OK := " "
					(cArqTrab)->(MsUnlock())
					MsgStop("SCHEDULE em execução, tente mais tarde!")
				Endif
				SC1->(MsUnlock())
			Endif
		EndIf
	EndIf
Return
/*/{Protheus.doc} PrcManu

	 Função de bloqueio quando Schedule estiver ativo

	@type  Function User
	@version 12.1.27
	@author  Cleiton Genuino da Silva
	@since   25/07/2023
/*/
User Function PrcManu()

	If !LockByName('F1200600_' + cFilAnt + __cUserID,.F.,.F. )//Alteração no Lockbyname para não travar toda a filial quando um usuário estiver realizando o processo - Lucas Miranda de Aguiar 16/09/2024
		MsgStop("LockByName!! SCHEDULE em execução, tente mais tarde!","Medição Automática")
	ElseIf  (SC1->C1_XNUMMED != "XXXXXX" .AND. !EMPTY(SC1->C1_XNUMMED))
		MsgStop("SCHEDULE em execução, registro em processamento. Tente mais tarde!","Medição Automática")
	Else
		U_F1200703(cArqTrab)
	EndIf

Return

/*/
	Função criada para substituir a SqlToTrb, que é muito lenta.
	Lucas Miranda de Aguiar 17/09/2024

	Teste no ambiente BSO com SqlToTrb -> 2h para carregar a tela.
	Teste no ambiente BSO com xSqlToTrb -> 1,30 min para carregar a tela.
/*/
Static Function xSqlToTrb(cQuery, aStru, cArqTrab,lExibeTela)

	Local cQry := ""
	Local nX := 0
	Local cAlias2 := GetNextAlias()
	Local cCampos := ""

	Default cQuery := ""
	Default aStru := {}
	Default cArqTrab := ""
	Default lExibeTela := .F.

	//DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAlias2, .T., .T.)
	cAlias2 := MPSysOpenQuery(ChangeQuery(cQuery))
	(cAlias2)->(DbGoTop())

	While (cAlias2)->(!EOF())

		SC1->(DbGoto((cAlias2)->RECNO))
		If SC1->C1_QUJE == 0

			Reclock((cArqTrab),.T.)
			For nX := 01 To Len(aStru)
				If aStru[nX][02] == "D"
					(cArqTrab)->&(aStru[nX][01]) := sTOD((cAlias2)->&(aStru[nX][01]))
				Else
					(cArqTrab)->&(aStru[nX][01]) := (cAlias2)->&(aStru[nX][01])
				EndIf
			Next nX
			(cArqTrab)->(MsUnlock())
		EndIf
		(cAlias2)->(DbSkip())
	EndDo
	(cAlias2)->(DbCloseArea())

/*/	For nX := 01 To Len(aStru)

	If nX == 01
		cCampos += aStru[nX][01]
	Else
		cCampos += ","+aStru[nX][01]
	EndIf
Next nX

cQry += "INSERT INTO "+cArqTrab+" ("+cCampos+") "
cQry += "(SELECT * FROM ("+cQuery+"))"

if TCSqlExec(cQry) < 0
	If lExibeTela
		Alert("Erro: " + TCSqlError())
	Else
		ConOut("Erro:", TCSqlError())
	EndIf
EndIf
/*/

Return
