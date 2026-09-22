#Include 'Protheus.ch'
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TopConn.ch"
#Include 'FWMVCDef.ch'
#Include 'MATA094.ch'
#Include "GCTXDEF.CH"
#INCLUDE "MATA097.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

STATIC oModelCT := NIL

#DEFINE OP_LIB	"001" // Liberado
#DEFINE OP_EST	"002" // Estornar
#DEFINE OP_SUP	"003" // Superior
#DEFINE OP_TRA	"004" // Transferir Superior
#DEFINE OP_REJ	"005" // Rejeitado
#DEFINE OP_BLQ	"006" // Bloqueio
#DEFINE OP_VIW	"007" // Visualizacao

//-------------------------------------------------------------------
/*/{Protheus.doc} XMATA094()
Aprovação de Documentos em massa - P12 SIMP
@author Lucas Miranda
@since 05/10/2021
@version 1.0
Inicial
@version 2.0
Mudança na forma de busca dos dados selecionados, foi criada uma tabela temporária para guardar os dados
Fazendo com que a busca e exibição da tela fique muito mais rápido.
@return NIL
/*/
//-------------------------------------------------------------------
User Function XMATA094()

	Local aArea := GetArea()
	Private oBrowse     := Nil
	Private lMarcar      := .F.
	Private cFilBkp		:= cFilAnt
	Private aFiltro := {}
	Private lPendSub := .F.
	Private cDocBkp := ""
	Private cDocTipBkp := ""
	Private nOpc	:= 0
	Private cStatsRV := ""
	Private cDocStatus := ""
	Private cDocTipo := ""
	Private cArqT := GetNextAlias()

	DbSelectArea("SAK")
	dbSetOrder(2)
	If !MsSeek(xFilial("SAK")+RetCodUsr())
		Help(" ",1,"A097APROV") //  UsuÃ¡rio nÃ£o esta cadastrado como aprovador. O  acesso  e  a utilizacao desta rotina e destinada apenas aos usuÃ¡rios envolvidos no processo de aprovaÃ§Ã£o de Pedido Compras definido pelos grupos de aprovaÃ§Ã£o.
		dbSelectArea("SCR")
		dbSetOrder(1)
	Else
		If Pergunte("XMTA94",.T.)
			MsgRun("Criando tabela temporária para inserção dos dados...","Processando",{|| fCriaTRB() }) //Cria tabela temporária para inserção dos dados
			MsgRun("Coletando dados das aprovações...","Processando",{|| fGetDados() })//Pega os dados da SCR a partir dos parâmetros passados no Pergunte e Inclui na Tabela temporária
			MsgRun("Criando browse para exibição dos dados...","Processando",{|| fBrowse() })//Cria um Markbrowse para o usuário executar o relatório
			fExclTRB()  //Exclui a tabela temporária após a operação
		EndIf
	EndIf
	RestArea(aArea)

	cFilAnt := cFilBkp
Return


/*/{Protheus.doc} fProcCR
Função responsável por alimentar array com os documentos e realizar as operações
@type function
@author Lucas Miranda de Aguiar
@since 05/10/2021
@version 1.0
@return NIL
/*/ 
User Function fProcCR(nOper)

	Local cMark := oMark:Mark()
	Local nX := 1
	Local aRecno := {}
	Local aRecnoTRB := {}
	Local cInfo := ""
	Local cTitulo := ""
	Local nReg := 0
	Local cCrObs := ""
	Local nCount := 0
	Local nLimite := GetNewPar("MV_XQTDMAS",20)
	Local lOk := .F.
	Local lContinua := .F.
	Local lAprov := .T.
	Local nMulta := 99999999
	Local nJuros := 99999999

	Default nOper := 001


	DbSelectArea("P35")
	DbSetOrder(1)
	DbGoTop()

	While P35->(!EOF())

		If P35->P35_TIPO == "1"
			nMulta := P35->P35_VALMIN
		ElseIf P35->P35_TIPO == "2"
			nJuros := P35->P35_VALMIN
		EndIf
		P35->(DbSkip())
	EndDo

//Posiciona no primeiro registro da tabela temporária.
	DbSelectArea((cArqT))
	(cArqT)->(DbGoTop())

//Adiciona o RECNO da SCR, que está gravado na tabela temporária em um array, mas somente dos documentos que o usuário selecionou para a operação.
	While (cArqT)->(!EoF())
		If (cArqT)->TR_OK == cMark
			nCount++
			AADD(aRecno,(cArqT)->TR_RECNO)
			AADD(aRecnoTRB, (cArqT)->(RECNO()))
		EndIf
		(cArqT)->(DbSkip())
	EndDo

	SetRegua(Len(aRecno))

	If nLimite < nCount
		Alert("Não é possível aprovar mais de " + cValToChar(nLimite)+ " documentos por vez!")
//Realiza as operações nos registros que o usuário marcou.
	Else
		For nX := 1 To Len(aRecno)
			DbSelectArea("SCR")
			DbGoto(aRecno[nX])
			nReg++
			IncRegua()
			lOk := .F.

			If SCR->CR_TIPO == "PC"
				DbSelectArea("SC7")
				DbSetOrder(1)
				If SC7->(DbSeek(SCR->CR_FILIAL+AllTrim(SCR->CR_NUM)))
					If SC7->C7_XSOLPAG == "1"
						If (SC7->C7_XMULTA >= nMulta.Or. SC7->C7_XJURMUL >= nJuros)
							If !(SC7->C7_XMULTA == 0.00 .And. SC7->C7_XJURMUL == 0.00)
								lContinua := U_XAPRVMULJUR()
								If lContinua
									cMsgMulJur := "Esta solicitação de pagamento possui valor de Multa ou Juros lançados. "  + Chr(13) + Chr(10)
									cMsgMulJur += "CODIGO DA FILIAL: " +  cValToChar(SC7->C7_FILIAL) + Chr(13) + Chr(10)
									cMsgMulJur += "NUMERO DA SP: " + cValToChar(SC7->C7_NUM) + Chr(13) + Chr(10)
									cMsgMulJur += "MULTA: R$ " + cValToChar(TRANSFORM(SC7->C7_XMULTA, "@E 99,999,999,999.99")) + Chr(13) + Chr(10)
									cMsgMulJur += "JUROS: R$ " + cValToChar(TRANSFORM(SC7->C7_XJURMUL, "@E 99,999,999,999.99"))  + Chr(13) + Chr(10)
									cMsgMulJur += "Deseja confirmar essa aprovação?"
									//Pergunta se deseja aprovar SP com multa/Juros
									If !MsgYesNo(cMsgMulJur)
										lAprov := .F.
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

			If lAprov

				//Mudo a filial antes da aprovação.
				cFilAnt := SCR->CR_FILIAL

				If nOper == 001
					cCrObs := "Aprovado via rotina de aprovação em massa."
					cInfo := "aprovados"
					cTitulo := "Aprovação de documentos em massa."
					nOpc := 4
					cStatsRV := "10"
					lOk := fProcessa("001",cCrObs)
				ElseIf nOper == 002
					cCrObs := "Bloqueado via rotina de aprovação em massa."
					cInfo := "bloqueados"
					cTitulo := "Bloqueio de documentos em massa."
					nOpc := 6
					lOk := fProcessa("006",cCrObs)
				ElseIf nOper == 003
					cCrObs := "Estornado via rotina de aprovação em massa."
					cInfo := "estornados"
					cTitulo := "Estorno de documentos em massa."
					nOpc := 5
					lOk := fProcessa("002",cCrObs)
				ElseIf nOper == 004
					cCrObs := "Rejeitado via rotina de aprovação em massa."
					cInfo := "rejeitados"
					cTitulo := "Rejeição de documentos em massa."
					nOpc := 7
					cStatsRV := "11"
					lOk := fProcessa("005",cCrObs)
				EndIf
			EndIf

		Next nX

		fNoShow()//Limpa todos os dados da tabela
		fRefresh()//Repopula a tabela com os dados das aprovações ainda com o status que o usuário passou.
		If !Empty(cTitulo)
			MsgInfo("Fim do processamento",cTitulo)
		Else
			MsgInfo("Fim do processamento","Liberação Massiva")
		EndIf
	EndIf
	oBrowse:Refresh()

Return

/*/{Protheus.doc} fProcessa
Função responsável por processar a operação de Liberação/Bloqueio/Rejeição/Estorno
@type function
@author Lucas Miranda de Aguiar
@since 18/04/2021
@version 1.0
@return NIL
/*/ 
Static Function fProcessa(cIdOperac,cObsCr)

	Local aArea         := {}
	Local oModel        := Nil
	Local lRetorno		:= .T.
	Local cUpdate		:= ""
	Local lLiberaRV		:= .F.
	Local oModelCT 		:= NIL
	Local aGrp			:= {}
	Local cGrps			:= ""
	Local nX 			:= 01
	Local lRv			:= .F.
	Local cRvNum		:= ""
	Local lFirstUsr		:= .F.
	Local aArrayCR      := {}
	Private aCamposC7   := {}
	Private aCamposDBL  := {}
	Private cFieldSC7   := ""
	Private lRotMVC 	:= .T.

	Default cIdOperac := ""
	Default cObsCr := ""


	aArea := {GetArea(), SCR->(GetArea())}
	If cIdOperac == "002" //Caso seja estorno chamo a rotina padrão direto.
		If A094VldEst()
			RecLock("SCR",.F.)
			SCR->CR_OBS := cObsCr
			MsUnlock()
		EndIf
	Else//Outras operações eu realizo a operação via MVC

		A094SetOp(cIdOperac)
		//Trecho copiado do padrão para evitar errorlog
		aCamposC7   := MtGetFec("SC7", "C7")
		aCamposDBL  := MtGetFec("DBL", "DBL")

		AEval(aCamposC7, {|campo| cFieldSC7 += "|" + campo})

		oModel := FwLoadModel("MATA094")

		oModel:SetOperation(4)//Operação de UPDATE

		//Tira Possíveis locks de tudo
		XA097Lock(AllTrim(SCR->CR_NUM),AllTrim(SCR->CR_TIPO))

		If oModel:Activate()
			oModel:SetValue("FieldSCR", "CR_OBS", cObsCr)

			If oModel:VldData()
				Begin Transaction
					oModel:CommitData()
					lRetorno := .T.
				End Transaction
			Else
				lRetorno := .F.
			EndIf
		EndIf
		oModel:DeActivate()
	EndIf
	AEval(aArea, {|area| RestArea(area)})


Return lRetorno


//-------------------------------------------------------------------
/*/Function fCriaTRB()
	Criação da tabela temporária para insersão dos dados da aprovação.
	@author Lucas Miranda de Aguiar
	@since 18/04/2021
	@version 1.0
	Inicial
	@return NIL
/*/
//-------------------------------------------------------------------
Static Function fCriaTRB()

	Local aArea := GetArea()
	Local cAlias := "SCR"
	Local aFields := {}
	Local nX := 1
	Local cType := ""
	Local aCampos := {}
	Local oTempTable

	aFields := FWSX3Util():GetAllFields( cAlias , .F. )

	For nX := 01 To Len(aFields)
		cType := FWSX3Util():GetFieldType( aFields[nX] )
		If aFields[nX] == "CR_FILIAL"
			AAdd(aCampos,{aFields[nX],	cType,	8,	0})
			AAdd(aCampos,{"TR_DESCFIL","C",25,0})
			aADD(aFiltro,{"CR_FILIAL","Filial","C",8,0,"@!"})
		ElseIf aFields[nX] == "CR_TIPO"
			AAdd(aCampos,{aFields[nX],	cType,	30,	GetSx3Cache(aFields[nX],"X3_DECIMAL")})
			aADD(aFiltro,{aFields[nX],AllTrim(GetSx3Cache(aFields[nX],"X3_TITULO")),cType,30,GetSx3Cache(aFields[nX],"X3_DECIMAL"),AllTrim(GetSx3Cache(aFields[nX],"X3_PICTURE"))})
		Else
			AAdd(aCampos,{aFields[nX],	cType,	TamSX3(aFields[nX])[1],	GetSx3Cache(aFields[nX],"X3_DECIMAL")})
			aADD(aFiltro,{aFields[nX],AllTrim(GetSx3Cache(aFields[nX],"X3_TITULO")),cType,TamSX3(aFields[nX])[1],GetSx3Cache(aFields[nX],"X3_DECIMAL"),AllTrim(GetSx3Cache(aFields[nX],"X3_PICTURE"))})
		EndIf
	Next nX

//Criar a tabela temporária
	AAdd(aCampos,{"TR_OK"        	,"C",002						,0})
	AAdd(aCampos,{"TR_RECNO"       	,"N",015						,0})
	AADD(aCAmpos,{"TR_NOSHOW"		,"N",001						,0})

	oTempTable := FWTemporaryTable():New( cArqT )
	oTemptable:SetFields( aCampos )
	oTempTable:AddIndex("Filial", {"CR_FILIAL"} )
	oTempTable:AddIndex("Numero", {"CR_NUM"} )
	oTempTable:AddIndex("Tipo", {"CR_TIPO"} )
	oTempTable:AddIndex("04", {"CR_FILIAL", "CR_TIPO", "CR_NUM"} )
	oTempTable:Create()

	RestArea(aArea)
Return



/*/{Protheus.doc} fGetDados
Função responsável por alimentar a tabela temporária com os dados da SCR
@type function
@author Lucas Miranda de Aguiar
@since 18/04/2021
@version 1.0
@return NIL
/*/ 
Static Function fGetDados()

	Local aArea := GetArea()
	Local cAliasTmp := GetNextAlias()
	Local cQuery := ""
	Local aFields := {}
	Local nX := 1
	Local cAlias := "SCR"
	Local cStatusCr := ""
	Local cTipoCr := ""

	cDocStatus := MV_PAR01 //1 - Pendente | 2 - Aprovados | 3 - Todos | 4 - Bloqueado | 5 - Rejeitado
	cDocTipo := MV_PAR02 // 1 - Todos | 2 - Pc/SolPag | 3 - Solicitação de compras | 4 - Contrato | 5 - Revisão


	If !lPendSub
		cDocBkp := cDocStatus
		cDocTipBkp := cDocTipo
	Endif

	cDocStatus := cDocBkp
	cDocTipo := cDocTipBkp

	If cDocStatus == 1
		cStatusCr := "'02'"
	ElseIf cDocStatus == 2
		cStatusCr := "'03','05'"
	ElseIf cDocStatus == 3
		cStatusCr := ""
	ElseIf cDocStatus == 4
		cStatusCr := "'04'"
	ElseIf cDocStatus == 5
		cStatusCr := "'06'"
	EndIf

	If cDocTipo == 1
		cTipoCr := ""
	ElseIf cDocTipo == 2
		cTipoCr := "SV"
	ElseIf cDocTipo == 3
		cTipoCr := "MAT"
	ElseIf cDocTipo == 4
		cTipoCr := "GPE"
	EndIf

	cQuery := fQrySCR(cStatusCr,cTipoCr)


	If Select( cAliasTmp ) > 0
		( cAliasTmp )->( DbCloseArea() )
	EndIf

	TcQuery cQuery Alias ( cAliasTmp ) New
	While !( cAliasTmp )->( Eof() )

		aFields := FWSX3Util():GetAllFields( cAlias , .F. )

		DbSelectArea(cArqT)

		If (cAliasTmp)->CR_TIPO == "PC"
			DbSelectArea("SC7")
			DbSetOrder(1)
			SC7->(DbSeek((cAliasTmp)->CR_FILIAL+AllTrim((cAliasTmp)->CR_NUM)))
			If (SC7->C7_XREPMED == '2' .Or. SC7->C7_XREPMED == '3')
				lOk := .F.
			Else
				lOk := .T.
			EndIf
		else
			lOk := .T.
		EndIf
		If lOk
			Reclock((cArqT),.T.)


			For nX := 01 To Len(aFields)
				If (aFields[nX] == "CR_TIPO" .And. (cAliasTmp)->&(aFields[nX]) == "PC")
					cTip := fGetTipo(cAliasTmp) //"1=Serviço", "2=Materiais(Estocável)", "3=Materiais(Não Estocável)", "4=GPE provisão","5=GPE ajuste"
					If AllTrim(cTip) == "1"
						cTip := "SP - Serviço"
					elseIf AllTrim(cTip) == "2"
						cTip := "SP - Material Estocável"
					ElseIf AllTrim(cTip) == "3"
						cTip := "SP - Material Não Estocável"
					ElseIf AllTrim(cTip) == "4"
						cTip := "SP - GPE Provisão"
					ElseIf AllTrim(cTip) == "5"
						cTip := "SP - GPE Ajuste"
					EndIf
					(cArqT)->&(aFields[nX]) := cTip
				ElseIf aFields[nX] == "CR_FILIAL"
					(cArqT)->&(aFields[nX]) := (cAliasTmp)->&(aFields[nX])
					(cArqT)->TR_DESCFIL := AllTrim(FWFilName(cEmpAnt,(cAliasTmp)->&(aFields[nX])))
				Else
					If FWSX3Util():GetFieldType( aFields[nX] ) == "D"
						(cArqT)->&(aFields[nX]) := StoD((cAliasTmp)->&(aFields[nX]))
					ElseIf FWSX3Util():GetFieldType( aFields[nX] ) == "L"
						If (cAliasTmp)->&(aFields[nX]) == "T"
							(cArqT)->&(aFields[nX]) := .T.
						ElseIf (cAliasTmp)->&(aFields[nX]) == "F"
							(cArqT)->&(aFields[nX]) := .F.
						EndIf
					ElseIf FWSX3Util():GetFieldType( aFields[nX] ) <> "M"
						(cArqT)->&(aFields[nX]) := (cAliasTmp)->&(aFields[nX])
					EndIf
				EndIf

			Next nX
			//Adiciona o RECNO do registro da SCR na tabela temporária para posicionar mais fácil depois.
			(cArqT)->TR_RECNO := (cAliasTmp)->RECNO
			(cArqT)->(MsUnlock())
		EndIf
		( cAliasTmp )->( DbSkip() )
	EndDo
	( cAliasTmp )->( DbCloseArea() )


	RestArea(aArea)

Return


/*/{Protheus.doc} fBrowse
Função responsável por montar a tela com os dados filtrados da SCR
@type function
@author Lucas Miranda de Aguiar
@since 18/04/2021
@version 1.0
@return NIL
/*/ 
Static Function fBrowse()

	Local cPicture := ""
	Local cTitulo := ""
	Local nAlign := 0
	Local nDecimal := 0
	Local cAlias  := "SCR"
	Local cCadastro := "Rotina de liberação de documentos em massa"
	Local bKeyF12    := { || MCFG6Invert(oBrowse:Mark(),lMarcar := !lMarcar ), oBrowse:Refresh(.T.)  }
	Local aSeek := {}
	Local cType := ""
	Local nX

	DbSelectArea((cArqT))
	(cArqT)->(dbGoTop())

	aAdd(aSeek,{"Filial"	,{{"","C",TamSX3("CR_FILIAL")[1]	,0,"Filial"	,"@!"}} } )
	aAdd(aSeek,{"Numero"	,{{"","C",TamSX3("CR_NUM")[1]		,0,"Numero"	,"@!"}} } )
	aAdd(aSeek,{"Tipo"		,{{"","C",TamSX3("CR_TIPO")[1]		,0,"Tipo"	,"@!"}} } )
	aAdd(aSeek,{"Filial+Tipo+Num"	,{{"","C",TamSX3("CR_FILIAL")[1]+TamSX3("CR_TIPO")[1]+TamSX3("CR_NUM")[1]	,0,"Filial+Tipo+Num","@!"}} } )

	oBrowse:= FWMarkBrowse():New()
	oBrowse:SetDescription(cCadastro) //Titulo da Janela
	oBrowse:SetParam(bKeyF12) // Seta tecla F12
	oBrowse:SetMenuDef("PSMATA94")
	oBrowse:SetAlias((cArqT)) //Indica o alias da tabela que será utilizada no Browse
	oBrowse:SetFieldMark("TR_OK") //Indica o campo que deverá ser atualizado com a marca no registro
	oBrowse:oBrowse:SetDBFFilter(.T.)
	oBrowse:oBrowse:SetFieldFilter(aFiltro)
	oBrowse:oBrowse:SetUseFilter(.T.) //Habilita a utilização do filtro no Browse
	oBrowse:oBrowse:SetFixedBrowse(.T.)
	oBrowse:SetWalkThru(.F.) //Habilita a utilização da funcionalidade Walk-Thru no Browse
	oBrowse:SetAmbiente(.T.) //Habilita a utilização da funcionalidade Ambiente no Browse
	oBrowse:SetTemporary() //Indica que o Browse utiliza tabela temporária
	oBrowse:oBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
	oBrowse:oBrowse:SetFilterDefault("TR_NOSHOW != 1") //Indica o filtro padrão do Browse

	//Adicionando legendas no Browse
	oBrowse:AddLegend("CR_STATUS=='01'", "BR_AZUL" , "Bloqueado (aguardando outros níveis)" )
	oBrowse:AddLegend("CR_STATUS=='02'", "DISABLE" , "Aguardando Liberação do usuário"  )
	oBrowse:AddLegend("CR_STATUS=='03'", "ENABLE"  , "Documento Liberado pelo usuário" )
	oBrowse:AddLegend("CR_STATUS=='04'", "BR_PRETO", "Documento Bloqueado pelo usuário" )
	oBrowse:AddLegend("CR_STATUS=='05'", "BR_CINZA", "Documento Liberado por outro usuário" )
	oBrowse:AddLegend("CR_STATUS=='06'", "BR_CANCEL","Documento Rejeitado pelo usuário" )

	aFields := FWSX3Util():GetAllFields( cAlias , .F. )
	For nX := 1 To Len(aFields)
		cPicture := GetSx3Cache( aFields[nX], "X3_PICTURE" )
		cTitulo := GetSx3Cache( aFields[nX], "X3_TITULO" )
		nDecimal :=	GetSx3Cache( aFields[nX], "X3_DECIMAL" )
		cType := FWSX3Util():GetFieldType( aFields[nX] )

		//aAdd(aSeek,{cTitulo	,{aFields[nX],cType,TamSX3(aFields[nX])[1]	,0,cTitulo	,cPicture }} )
		//aAdd(aSeek,{"Filial"	,{{"","C",TamSX3("C1_FILIAL")[1]	,0,"Filial"	,"@!"}} } )

		If aFields[nX] == "CR_FILIAL"
			nAlign := 8
		ElseIf aFields[nX] == "CR_TIPO"
			nAlign := 30
		Else
			nAlign := GetSx3Cache( aFields[nX], "X3_TAMANHO" )
		EndIf
		oBrowse:SetColumns(MCFG006TIT(aFields[nX]     ,cTitulo    			 ,nX,cPicture,1,nAlign,nDecimal))

		If aFields[nX] == "CR_FILIAL"
			nAlign := 25
			oBrowse:SetColumns(MCFG006TIT("TR_DESCFIL"    ,"Nome Filial" ,nX,cPicture,1,nAlign,0))
		EndIf
	Next nX

	oBrowse:bAllMark := { || MCFG6Invert(oBrowse:Mark(),lMarcar := !lMarcar ), oBrowse:Refresh(.T.)  }
	oBrowse:SetCustomMarkRec({ || fValidQtd() })


	//Método de ativação da classe
	oBrowse:Activate()

	oBrowse:oBrowse:Setfocus() //Seta o foco na grade

Return

Static Function fValidQtd()

	Local cAlias := (cArqT)
	Local aArea := (cAlias)->(GetArea())
	Local nLimite := GetNewPar("MV_XQTDMAS",10)
	Local nCount := 1
	Local nRec := (cAlias)->(RECNO())

	If !Empty(AllTrim((cAlias)->TR_OK))
		Reclock((cAlias),.F.)
		(cAlias)->TR_OK := ""
		(cAlias)->(MsUnLock())
	Else
		(cAlias)->(DbGoTop())
		While (!(cAlias)->( Eof() ))
			If !Empty(AllTrim((cAlias)->TR_OK))
				nCount++
			EndIf
			(cAlias)->( dbSkip() )
		EndDo
		If nCount > nLimite
			Alert("Não é possível selecionar mais de " + cValToChar(nLimite) + " registros!")
		Else
			(cAlias)->(DbGoTo(nRec))
			Reclock((cAlias),.F.)
			(cAlias)->TR_OK := oBrowse:Mark()
			(cAlias)->(MsUnLock())
		EndIf
	EndIf
	RestArea(aArea)
Return

/*/{Protheus.doc} MCFG006TIT
Função responsável por criar as colunas do Browse
@type function
@author Lucas Miranda de Aguiar
@since 18/04/2021
@version 1.0
@return NIL
/*/ 
Static Function MCFG006TIT(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
	Local aColumn
	Local bData     := {||}
	Default nAlign     := 1
	Default nSize     := 20
	Default nDecimal:= 0
	Default nArrData:= 0

	If nArrData > 0
		bData := &("{||" + cCampo +"}") //&("{||oBrowse:DataArray[oBrowse:At(),"+STR(nArrData)+"]}")
	EndIf

    /* Array da coluna
    [n][01] Título da coluna
    [n][02] Code-Block de carga dos dados
    [n][03] Tipo de dados
    [n][04] Máscara
    [n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
    [n][06] Tamanho
    [n][07] Decimal
    [n][08] Indica se permite a edição
    [n][09] Code-Block de validação da coluna após a edição
    [n][10] Indica se exibe imagem
    [n][11] Code-Block de execução do duplo clique
    [n][12] Variável a ser utilizada na edição (ReadVar)
    [n][13] Code-Block de execução do clique no header
    [n][14] Indica se a coluna está deletada
    [n][15] Indica se a coluna será exibida nos detalhes do Browse
    [n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
    */
	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}
Return {aColumn}


/*/{Protheus.doc} MCFG6Invert
Função que alimenta o botão F12 no browse
@type function
@author Lucas Miranda de Aguiar
@since 18/04/2021
@version 1.0
@return NIL
/*/ 

//Função para marcar/desmarcar todos os registros do grid
Static Function MCFG6Invert(cMarca,lMarcar)
	Local cAlias := (cArqT)
	Local aArea := (cAlias)->(GetArea())
	Local nLimite := GetNewPar("MV_XQTDMAS",10)
	Local nCount := 0
	Local cMsg := ""

	Default cMarca := oBrowse:Mark()
	Default lMarcar := .T.


	If lMarcar

		dbSelectArea(cAlias)
		(cAlias)->( dbGoTop() )

		While !(cAlias)->( Eof() )
			If !Empty(AllTrim((cAlias)->TR_OK))
				nCount++
			EndIf
			(cAlias)->(DbSkip())
		EndDo

		If nCount >= nLimite
			MsgInfo("O limite de " + cValToChar(nLimite) + " marcações  simultâneas foi atingido, nenhum registro será selecionado.","Liberação Massiva")
			Return .T.
		EndIf

		If nCount >= 1
			cMsg := "Você já selecionou " + cValToChar(nCount) + iif(nCount == 1," registro "," registros ")
			cMsg += " do máximo de " + cValToChar(nLimite) + "."
			If nLimite-nCount > 1
				cMsg += CRLF + " Serão selecionados " + cValtoChar(nLimite-nCount) + " registros faltantes "
			Else
				cMsg += CRLF + " Será selecionado " + cValtoChar(nLimite-nCount) + " registro faltante "
			EndIf
			cMsg += " para completar o máximo de " +cValToChar(nLimite) + " registros permitidos para marcação simultânea."
			nLimite := nLimite-nCount
			MsgInfo(cMsg,"Liberação Massiva")
		EndIf
		nCount := 1
		(cAlias)->(DbGoTop())
		While (!(cAlias)->( Eof() ) .And. nCount <= nLimite)
			If Empty(AllTrim((cAlias)->TR_OK))
				RecLock( (cAlias), .F. )
				(cAlias)->TR_OK := cMarca
				MsUnlock()
				nCount++
			EndIf
			(cAlias)->( dbSkip() )
		EndDo
	Else
		While (!(cAlias)->( Eof() ) .And. nCount <= nLimite)
			RecLock( (cAlias), .F. )
			(cAlias)->TR_OK := '  '
			MsUnlock()
			nCount++
			(cAlias)->( dbSkip() )
		EndDo
	EndIf
	RestArea(aArea)
Return .T.


/*/{Protheus.doc} fExclTRB
Função responsável por excluir a tabela temporária
@type function
@author Lucas Miranda de Aguiar
@since 18/04/2021
@version 1.0
@return 
/*/ 
Static Function fExclTRB()

	(cArqT)->(DbCloseArea())

Return



/*/{Protheus.doc} fQrySCR
Função responsável por fazer a query da SCR 
@type function
@author Lucas Miranda de Aguiar
@since 18/04/2021
@version 1.0
@return caracter
/*/ 
Static Function fQrySCR(cStatusCr,cTipoCR)

	Local aArea := GetArea()
	Local cQry := ""
	Local cQryCr := ""

	Default cStatusCr := ""
	Default cTipoCR := ""
//"1=Serviço", "2=Materiais(Estocável)", "3=Materiais(Não Estocável)", "4=GPE provisão","5=GPE ajuste"
	If cTipoCR == "SV"
		cQryCr := " AND CR_NUM IN (SELECT C7_NUM FROM " + retsqlname("SC7")
		cQryCr += " WHERE D_E_L_E_T_ = ' ' AND C7_XSOLPAG = '1' AND C7_XTPSP = '1')"
	ElseIf cTipoCR == "MAT"
		cQryCr := " AND CR_NUM IN (SELECT C7_NUM FROM " + retsqlname("SC7")
		cQryCr += " WHERE D_E_L_E_T_ = ' ' AND C7_XSOLPAG = '1' AND C7_XTPSP IN ('2','3'))"
	ElseIf cTipoCR == "GPE"
		cQryCr := " AND CR_NUM IN (SELECT C7_NUM FROM " + retsqlname("SC7")
		cQryCr += " WHERE D_E_L_E_T_ = ' ' AND C7_XSOLPAG = '1' AND C7_XTPSP IN ('4','5'))"
	EndIf

	Cqry := " SELECT CR.*, R_E_C_N_O_ AS RECNO FROM " + RETSQLNAME("SCR") + " CR "
	Cqry += " WHERE D_E_L_E_T_ = ' ' "
	If !Empty(cStatusCr)
		Cqry += " AND CR_STATUS IN (" +cStatusCr+")"
	EndIf
	cQry += " AND CR_USER = '"+__CUSERID+"'"
	If !Empty(cTipoCR)
		Cqry += " AND CR_TIPO = 'PC'"
	EndIf
	cQry += cQryCr
	Cqry += " ORDER BY CR_FILIAL,CR_TIPO,CR_NUM"


	RestArea(aArea)
Return cQry

/*/{Protheus.doc} MenuDef
Definição de itens do menu do browse
@type function
@author Lucas Miranda de Aguiar
@since 18/04/2021
@version 1.0
@return 
/*/ 
Static Function MenuDef()

	Local aRotina := {} //Array utilizado para controlar opcao selecionada
	Local aOpcVIs	:= {}
	Local aOpcSup	:= {}
	Local aOpcBco	:= {}

	//ADD OPTION aOpcSup Title "Aprovar pelo superior"	    Action 'U_XAPRVSUP()'													 OPERATION 4 ACCESS 0
	//ADD OPTION aOpcSup Title "Transferir para superior"	    Action 'U_XTRANSSUP()'												     OPERATION 4 ACCESS 0

	ADD OPTION aOpcBco Title "Incluir"	   				    Action 'U_XMT94fbco(3)' 											 OPERATION 2 ACCESS 0
	ADD OPTION aOpcBco Title "Excluir"	    				Action 'U_XMT94fbco(5)' 											 OPERATION 2 ACCESS 0
	ADD OPTION aOpcBco Title "Visualizar"	    			Action 'U_XMT94fbco(1)' 											 OPERATION 2 ACCESS 0
	ADD OPTION aOpcVis Title "Formulário da aprovação"	    Action 'U_XFORMAPRO()' 													 OPERATION 2 ACCESS 0
	ADD OPTION aOpcVis Title "Documento emitido"	        Action 'U_XFDOCEMIT()'											 OPERATION 2 ACCESS 0
	ADD OPTION aOpcVis Title "Saldo para aprovação"		    Action 'u_XfSldApro()'												 OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title "Aprovar"              	    Action 'RptStatus({|| u_fProcCR(001)}, "Aguarde...", "Processando...")' OPERATION 4 ACCESS 0 	//"Aprovar"
	ADD OPTION aRotina Title "Rejeitar"	                    Action 'RptStatus({|| u_fProcCR(004)}, "Aguarde...", "Processando...")'	 OPERATION 4 ACCESS 0  //"Rejeitar"
	ADD OPTION aRotina Title "Visualizar"	                Action  aOpcVis														 OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title "Bloquear"	                    Action 'RptStatus({|| u_fProcCR(002)}, "Aguarde...", "Processando...")'	 OPERATION 4 ACCESS 0 	//"Bloquear"
	ADD OPTION aRotina Title "Estornar"	                    Action 'RptStatus({|| u_fProcCR(003)}, "Aguarde...", "Processando...")'	 OPERATION 5 ACCESS 0 	//"Estornar"
	ADD OPTION aRotina Title "Pendencias de subordinados"   Action 'U_PENDSUB()'												 OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title "Superior"	                    Action  aOpcSup														 OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title "Banco específico		"		Action 	aOpcBco	            										 OPERATION 4 ACCESS 0
Return aRotina


/*/{Protheus.doc} fNoShow
Função responsável por tirar os documentos já lidos da tela após o término das operações
@type function
@author Lucas Miranda de Aguiar
@since 18/04/2021
@version 1.0
@return
/*/ 
Static Function fNoShow()

	Local aArea := GetArea()
	DbSelectArea((cArqT))
	(cArqT)->(DbGoTop())
	While (cArqT)->(!EOF())
		If !Reclock((cArqT),.F.)
			(cArqT)->(MsUnlock())
			Reclock((cArqT),.F.)
			(cArqT)->( DbDelete() )
			(cArqT)->(MsUnlock())
			(cArqT)->(DbSkip())
		Else
			(cArqT)->( DbDelete() )
			(cArqT)->(MsUnlock())
			(cArqT)->(DbSkip())
		EndIf
	EndDo
	RestArea(aArea)
Return

/*/{Protheus.doc} XMT94fbco
Chamada do banco de conhecimento na rotina de aprovação em massa
@type function
@author Lucas Miranda de Aguiar
@since 18/04/2021
@version 1.0
@return 
/*/ 
User Function XMT94fbco(nNum)

	Local aArea := GetArea()

	Default nNum := 1

	cFilAnt := (cArqT)->CR_FILIAL

	DbSelectArea("SCR")
	DbSetOrder(1)
	DbGoto((cArqT)->TR_RECNO)

	If nNum == 1
		u_f0400101(1)
	ElseIf nNum == 3
		u_f0400101(3)
	ElseIf nNum == 5
		u_f0400101(5)
	EndIf
	RestArea(aArea)
Return


User Function XFDOCEMIT()

	Local cRvNum := ""
	Local lFirstUsr := .F.
	Local aGrp := {}
	Local cGrps := ""
	Local nX

	DbSelectArea("SCR")
	DbSetOrder(1)
	DbGoto((cArqT)->TR_RECNO)
	cFilAnt := (cArqT)->CR_FILIAL

	If (SCR->CR_TIPO == "RV" .Or. SCR->CR_TIPO == "CT")
		dbSelectArea("CNN")
		dbSetOrder(1)
		If !DbSeek(xFilial("CNN")+RetCodUsr()+Padr(SCR->CR_NUM,TamSx3("CNN_CONTRA")[1]))
			lFirstUsr := .T.
			cRvNum := SCR->CR_NUM
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega Grupos do usuario                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aGrp := FWSFUsrGrps(RetCodUsr())

			For nX := 01 to Len(aGrp)
				cGrps += "'"+aGrp[nX]+"',"
			Next

			cGrps := SubStr(cGrps,1,Len(cGrps)-1)

			RecLock("CNN",.T.)
			CNN->CNN_FILIAL := xFilial("CNN")
			CNN->CNN_CONTRA := AllTrim(SCR->CR_NUM)
			CNN->CNN_USRCOD := RetCodUsr()
			CNN->CNN_GRPCOD	:= Iif(Len(aGrp) > 0,aGrp[1],"")
			CNN->CNN_TRACOD := "001"
			CNN->(MsUnlock())
		EndIf
	EndIf

	A097Visual(,,2)

	If lFirstUsr
		DbselectArea("CNN")
		DbSetOrder(1)
		If DbSeek(xFilial("CNN")+RetCodUsr()+Padr(cRvNum,TamSx3("CNN_CONTRA")[1]))
			RecLock("CNN",.F.)
			CNN->(DbDelete())
			CNN->(MsUnLock())
		EndIf
	EndIf
Return


/*/{Protheus.doc} XfSldApro
Função para retornar o tipo "SP" caso seja solicitação de pagamento
@type function
@author Lucas Miranda de Aguiar
@since 18/04/2021
@version 1.0
@return 
/*/ 
Static Function fGetTipo( cAliasTmp )

	Local aArea := GetArea()
	Local cAliasC7 := GetNextAlias()
	Local cQuery := ""
	Local cTipo := "PC"

	cQuery := " SELECT C7_NUM,C7_XTPSP FROM "+ RETSQLNAME("SC7")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND C7_NUM = '"+( cAliasTmp )->CR_NUM+"'"
	cQuery += " AND C7_FILIAL = '"+( cAliasTmp )->CR_FILIAL+"'"
	cQuery += " AND C7_XSOLPAG = '1'"

	If Select( cAliasC7 ) > 0
		( cAliasC7 )->( DbCloseArea() )
	EndIf

	TcQuery cQuery Alias ( cAliasC7 ) New
	If !( cAliasC7 )->( Eof() )
		cTipo := ( cAliasC7 )->C7_XTPSP  //1=Serviço;2=Materiais;3=GPE provisao;4=GPE Ajuste
	EndIf

	( cAliasC7 )->( DbCloseArea() )

	RestArea(aArea)
Return cTipo

/*/{Protheus.doc} XfSldApro
Logar na filial e ver o saldo da aprovação
@type function
@author Lucas Miranda de Aguiar
@since 18/04/2021
@version 1.0
@return 
/*/ 
User Function XfSldApro()

	DbSelectArea("SCR")
	DbSetOrder(1)
	DbGoto((cArqT)->TR_RECNO)
	cFilAnt := (cArqT)->CR_FILIAL
	A097Consulta()
Return

/*/{Protheus.doc} XFORMAPRO
Logar na filial e ver o formulário do documento
@type function
@author Lucas Miranda de Aguiar
@since 18/04/2021
@version 1.0
@return 
/*/ 
User Function XFORMAPRO()

	DbSelectArea("SCR")
	DbSetOrder(1)
	DbGoto((cArqT)->TR_RECNO)
	cFilAnt := (cArqT)->CR_FILIAL
	A94Visual()

Return

/*/{Protheus.doc} XAPRVSUP
Logar na filial
@type function
@author Lucas Miranda de Aguiar
@since 18/04/2021
@version 1.0
@return 
/*/ 
User Function XAPRVSUP()

	DbSelectArea("SCR")
	DbSetOrder(1)
	DbGoto((cArqT)->TR_RECNO)
	cFilAnt := (cArqT)->CR_FILIAL
	A94ExSuper()
Return

/*/{Protheus.doc} XTRANSSUP
Logar na filial
@type function
@author Lucas Miranda de Aguiar
@since 18/04/2021
@version 1.0
@return 
/*/ 
User Function XTRANSSUP()
	DbSelectArea("SCR")
	DbSetOrder(1)
	DbGoto((cArqT)->TR_RECNO)
	cFilAnt := (cArqT)->CR_FILIAL
	A94ExTrans()
Return


/*/{Protheus.doc} PENDUSB
Logar na filial
@type function
@author Lucas Miranda de Aguiar
@since 18/04/2021
@version 1.0
@return 
/*/ 

User Function PENDSUB()

	Local aRet := {}

	DbSelectArea("SCR")
	DbSetOrder(1)
	DbGoto((cArqT)->TR_RECNO)
	If Pergunte("XFILPENDSU",.T.)
		cFilAnt := MV_PAR01
		A097Ausente()
		lPendSub := .T.
		fNoShow()//Limpa todos os dados da tabela
		fRefresh()//Repopula a tabela com os dados das aprovações ainda com o status que o usuário passou.
		oBrowse:Refresh()
	EndIf
Return


//--------------------------------------------------------------------
/*/{Protheus.doc} XMT94coLan()
Validacoes de bloqueio orcamentario. - Cópia do padrão para compatibilidade
@version 1.0
@author Lucas Miranda de Aguiar
@return NIL
/*/
//--------------------------------------------------------------------
Static Function XMT94coLan()

	Local aArea    := GetArea()
	Local aAreaSC7 := SC7->(GetArea())
	Local ca094User:= RetCodUsr()
	Local cName    := ""
	Local lA097PCO := ExistBlock("A097PCO")
	Local lLanPCO  := .T.
	Local lRet     := .T.

	If lA097PCO
		cName   := UsrRetName(ca094User)
		lLanPCO := ExecBlock("A097PCO",.F.,.F.,{SC7->C7_NUM,cName,lLanPCO})
	EndIf

	If lLanPCO

		If SCR->CR_TIPO == "PC" .Or. SCR->CR_TIPO == "AE"
			dbSelectArea("SC7")
			DbSetOrder(1)
			DbSeek(xFilial("SC7")+Substr(SCR->CR_NUM,1,len(SC7->C7_NUM)))
		EndIf
		If lRet := PcoVldLan('000055','02','MATA097')
			If SCR->CR_TIPO == "NF"
				dbSelectArea("SF1")
			ElseIf SCR->CR_TIPO == "PC" .Or. SCR->CR_TIPO == "AE" .Or. SCR->CR_TIPO == "IP"
				While lRet .And. !Eof() .And. SC7->C7_FILIAL+Substr(SC7->C7_NUM,1,len(SC7->C7_NUM)) == xFilial("SC7")+Substr(SCR->CR_NUM,1,len(SC7->C7_NUM))
					lRet := PcoVldLan("000055","01","MATA097")
					dbSelectArea("SC7")
					dbSkip()
				EndDo
			ElseIf SCR->CR_TIPO == "CP"
				dbSelectArea("SC3")
			EndIf
		EndIf
		If !lRet
			PcoFreeBlq("000055")
		EndIf

	EndIf

	RestArea(aAreaSC7)
	RestArea(aArea)

Return lRet


/*/{Protheus.doc} Xa097Lock
Função para tirar possíveis locks
@type function
@author Lucas Miranda de Aguiar
@since 18/04/2021
@version 1.0
@return 
/*/ 

Static Function XA097Lock(cNumero,cTipo)

	Local aArea    	:= GetArea()
	Local lRet     	:= .F.
	Local nTamC7Num	:= TamSx3("C7_NUM")[1]
	Local aAreaAgro := "" // Documentos do modulo Agro


	If cTipo == "PC"
		aArea := SC7->(GetArea())
		dbSelectArea("SC7")
		SC7->(dbSetOrder(1))
		If SC7->(MsSeek(xFilial("SC7") + cNumero))
			While SC7->(!Eof()) .And. SC7->C7_FILIAL + Padr(SC7->C7_NUM,nTamC7Num) == xFilial("SC7") + cNumero
				If RecLock("SC7")
					lRet := .T.
					SC7->(MSUNLOCK())
				Else
					SC7->(MSUNLOCK())
				Endif
				SC7->(dbSkip())
			EndDo
		EndIf
	EndIf

	RestArea(aArea)

Return


/*/{Protheus.doc} fRefresh
Função responsável por atualizar a tabela temporária
@type function
@author Lucas Miranda de Aguiar
@since 21/06/2021
@version 1.0
@return NIL
/*/ 
Static Function fRefresh()

	Local aArea := GetArea()
	Local cAliasTmp := GetNextAlias()
	Local cQuery := ""
	Local aFields := {}
	Local nX := 1
	Local cAlias := "SCR"
	Local cStatusCr := ""
	Local cTipoCr := ""


	If cDocStatus == 1
		cStatusCr := "'02'"
	ElseIf cDocStatus == 2
		cStatusCr := "'03','05'"
	ElseIf cDocStatus == 3
		cStatusCr := ""
	ElseIf cDocStatus == 4
		cStatusCr := "'04'"
	ElseIf cDocStatus == 5
		cStatusCr := "'06'"
	EndIf

	If cDocTipo == 1
		cTipoCr := ""
	ElseIf cDocTipo == 2
		cTipoCr := "SV"
	ElseIf cDocTipo == 3
		cTipoCr := "MAT"
	ElseIf cDocTipo == 4
		cTipoCr := "GPE"
	EndIf

	cQuery := fQrySCR(cStatusCr,cTipoCr)


	If Select( cAliasTmp ) > 0
		( cAliasTmp )->( DbCloseArea() )
	EndIf

	TcQuery cQuery Alias ( cAliasTmp ) New
	While !( cAliasTmp )->( Eof() )

		aFields := FWSX3Util():GetAllFields( cAlias , .F. )

		DbSelectArea(cArqT)

		If (cAliasTmp)->CR_TIPO == "PC"
			DbSelectArea("SC7")
			DbSetOrder(1)
			SC7->(DbSeek((cAliasTmp)->CR_FILIAL+AllTrim((cAliasTmp)->CR_NUM)))
			If (SC7->C7_XREPMED == '2' .Or. SC7->C7_XREPMED == '3')
				lOk := .F.
			Else
				lOk := .T.
			EndIf
		else
			lOk := .T.
		EndIf
		Reclock((cArqT),.T.)

		If lOk
			For nX := 01 To Len(aFields)
				If (aFields[nX] == "CR_TIPO" .And. (cAliasTmp)->&(aFields[nX]) == "PC")
					cTip := fGetTipo(cAliasTmp) //"1=Serviço", "2=Materiais(Estocável)", "3=Materiais(Não Estocável)", "4=GPE provisão","5=GPE ajuste"
					If AllTrim(cTip) == "1"
						cTip := "SP - Serviço"
					elseIf AllTrim(cTip) == "2"
						cTip := "SP - Material Estocável"
					ElseIf AllTrim(cTip) == "3"
						cTip := "SP - Material Não Estocável"
					ElseIf AllTrim(cTip) == "4"
						cTip := "SP - GPE Provisão"
					ElseIf AllTrim(cTip) == "5"
						cTip := "SP - GPE Ajuste"
					EndIf
					(cArqT)->&(aFields[nX]) := cTip
				ElseIf aFields[nX] == "CR_FILIAL"
					(cArqT)->&(aFields[nX]) := (cAliasTmp)->&(aFields[nX])
					(cArqT)->TR_DESCFIL := AllTrim(FWFilName(cEmpAnt,(cAliasTmp)->&(aFields[nX])))
				Else
					If FWSX3Util():GetFieldType( aFields[nX] ) == "D"
						(cArqT)->&(aFields[nX]) := StoD((cAliasTmp)->&(aFields[nX]))
					ElseIf FWSX3Util():GetFieldType( aFields[nX] ) == "L"
						If (cAliasTmp)->&(aFields[nX]) == "T"
							(cArqT)->&(aFields[nX]) := .T.
						ElseIf (cAliasTmp)->&(aFields[nX]) == "F"
							(cArqT)->&(aFields[nX]) := .F.
						EndIf
					ElseIf FWSX3Util():GetFieldType( aFields[nX] ) <> "M"
						(cArqT)->&(aFields[nX]) := (cAliasTmp)->&(aFields[nX])
					EndIf
				EndIf

			Next nX
			//Adiciona o RECNO do registro da SCR na tabela temporária para posicionar mais fácil depois.
			(cArqT)->TR_RECNO := (cAliasTmp)->RECNO
			(cArqT)->(MsUnlock())
		EndIf
		( cAliasTmp )->( DbSkip() )
	EndDo
	( cAliasTmp )->( DbCloseArea() )


	RestArea(aArea)

Return
