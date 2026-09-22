#Include 'Protheus.ch' 
#INCLUDE 'FWMVCDEF.CH'

Static lBtApRp := .T.  

/*
{Protheus.doc} F0100323()
Atendimento das solicitações customizadas
@Author     Bruno de Oliveira
@Since      25/10/2016
@param cTipo, characters, descricao
@Version    P12.1.07
@Project    MAN00000462901_EF_003
*/
User Function F0100323(cTipo,xxx)
	Local cFiltro	:= ""
	Local aRotina	:= MenuDef()
	Default cTipo	:= ""
	Default	xxx 	:= ""
// ------------------------------------
    public lGp050Auto := .T.
// ------------------------------------
	
	If cTipo == "006" .And. !Empty(xxx)
		cFiltro := "RH3_XTPCTM == '" + cTipo + "' .AND. RH3_XXXX == '"+xxx+"' "
	Else
		cFiltro := "RH3_XTPCTM == '" + cTipo + "' "	
	EndIf
	
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("RH3")
	oMBrowse:SetDescription("Solicitações ao RH")
	If cTipo == "002" .OR. EMPTY(cTipo)
		oMBrowse:SetOnlyFields({'RH3_FILIAL', 'RH3_CODIGO', 'RH3_NOME', 'RH3_XDSCTM', 'RH3_DTSOLI', 'RH3_DTATEN', 'RH3_XDCARG'} )
	Else
		oMBrowse:SetOnlyFields({'RH3_FILIAL', 'RH3_CODIGO', 'RH3_NOME', 'RH3_XDSCTM', 'RH3_DTSOLI', 'RH3_DTATEN'} )
	EndIf
	oMBrowse:AddLegend('RH3->RH3_STATUS=="1"', "YELLOW", "Solicitado")
	oMBrowse:AddLegend('RH3->RH3_STATUS=="2"', "GREEN", "Aprovado")
	oMBrowse:AddLegend('RH3->RH3_STATUS=="4" .AND. RH3->RH3_XLIBPT=="1"', "WHITE", "Aguardando liberação do posto")
	oMBrowse:AddLegend('RH3->RH3_STATUS=="4"', "BLUE", "Aguardando Efetivacao RH")
	oMBrowse:AddLegend('RH3->RH3_STATUS=="3" .AND. RH3->RH3_XCANCL=="1"',  "PINK",	"Cancelado")
	oMBrowse:AddLegend('RH3->RH3_STATUS=="3"', "RED", "Rejeitado")
	oMBrowse:SetMenuDef("F0100323")
	If !Empty(cTipo)
		If cTipo == "002"
			cFiltro += ".AND. RH3_XFLPTV == '" + cFilAnt + "' "
		EndIf
		oMBrowse:SetFilterDefault(cFiltro)
	Else
		oMBrowse:SetFilterDefault('!EMPTY(RH3_XTPCTM)')
	EndIf
	oMBrowse:SetCacheView( .F. )
	oMBrowse:Activate()
	
Return

/*
{Protheus.doc} MenuDef()
Criaï¿½ï¿½o do Menu de atendimento de solicitações
@Author     Bruno de Oliveira
@Since      26/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Return		aRotina, opï¿½ï¿½o de menu
*/
Static Function MenuDef()
	
	Local aRotina := {}
	
	// ADD OPTION aRotina TITLE "Atender" ACTION "VIEWDEF.F0100323" OPERATION 4 ACCESS 0
	// ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.F0100323" OPERATION 1 ACCESS 0	
	// ADD OPTION aRotina Title 'Banco Específico - Visualizar' Action 'U_F0400101(1)'    	OPERATION 0 ACCESS 0
	// ADD OPTION aRotina Title 'Banco Específico - Incluir'    Action 'U_F0400101(3)'    	OPERATION 0 ACCESS 0
	// ADD OPTION aRotina Title 'Banco Específico - Excluir'    Action 'U_F0400101(5)'    	OPERATION 0 ACCESS 0
	// ADD OPTION aRotina Title 'Gerar Ficha Médica'			 Action 'U_DORFIMED'    	OPERATION 0 ACCESS 0
	
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Array contendo as Rotinas a executar do programa      ³
	³ ----------- Elementos contidos por dimensao ------------     ³
	³ 1. Nome a aparecer no cabecalho                              ³
	³ 2. Nome da Rotina associada                                  ³
	³ 3. Usado pela rotina                                         ³
	³ 4. Tipo de Transa‡„o a ser efetuada                          ³
	³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
	³    2 - Simplesmente Mostra os Campos                         ³
	³    3 - Inclui registros no Bancos de Dados                   ³
	³    4 - Altera o registro corrente                            ³
	³    5 - Remove o registro corrente do Banco de Dados          ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	AAdd(aRotina,{"Atender" 						, "VIEWDEF.F0100323"    , 0, 4 } )
	AAdd(aRotina,{"Visualizar" 						, "VIEWDEF.F0100323"    , 0, 2 } )
	AAdd(aRotina,{"Banco Específico - Visualizar" 	, "U_F0400101(1)"    	, 0, 4 } )
	AAdd(aRotina,{"Banco Específico - Incluir" 		, "U_F0400101(3)"    	, 0, 4 } )
	AAdd(aRotina,{"Banco Específico - Excluir" 		, "U_F0400101(5)"    	, 0, 4 } )
	AAdd(aRotina,{"Gerar Ficha Médica" 				, "U_DORFIMED()"    	, 0, 4 } )



Return aRotina

/*
{Protheus.doc} ModelDef()
Modelo de dados do atendimento de solicitações
@Author     Bruno de Oliveira
@Since      26/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Return		oModel, Modelo de dados
*/
Static Function ModelDef()
	
	Local oModel
	Local oStrRH3 := FwFormStruct(1, "RH3")
	Local oStrRH4 := FWFormStruct(1, "RH4")
	Local oStrPAE := FWFormStruct(1, "PAE")
	Local bCancel := {|oModel| FCancAtend(oModel) }
	Local bPreMd  := {|oModel| AjustVal(oModel, RH3->RH3_FILIAL), lBtApRp := .T.  }
	Local bCmtAlt := {|oModel| VldCommit(oModel)}
	//Local bPosOk  := {|oModel| IIF(RH3->RH3_XTPCTM == '006', .T., .F.)}
	
	If (FunName() $ "U_F0500401|U_F0500202") //Caso venha da consulta de movimentação o sistema nao grava alteracoes
		oModel := MPFormModel():New("M01003",  bPreMd , /*bPosMd*/ , bCmtAlt , bCancel ) 
	Elseif RH3->RH3_XTPCTM == '006'
		oModel := MPFormModel():New("M01003",  bPreMd , /*bPosOk*/ , bCmtAlt , bCancel ) 
	Else 
		oModel := MPFormModel():New("M01003",  bPreMd , /*bPosMd*/ , /*bCommit*/ , bCancel )
	EndIf
	oModel:SetDescription("Atendimento das solicitações")
	
	oStrRH3:SetProperty( "RH3_MAT", MODEL_FIELD_OBRIGAT, .F. )
	oStrRH3:SetProperty( "RH3_TIPO", MODEL_FIELD_OBRIGAT, .F. )
	
	oStrRH4:SetProperty( "RH4_VALANT", MODEL_FIELD_OBRIGAT, .F. )
	oStrRH4:SetProperty( "RH4_VALNOV", MODEL_FIELD_OBRIGAT, .F. )
	
	oStrRH4:AddField(	"Descrição"		, ;	// 	[01]  C   Titulo do campo
	"Descrição"		, ;	// 	[02]  C   ToolTip do campo
	"DESCRICAO"		, ;	// 	[03]  C   Id do Field
	"C"				, ;	// 	[04]  C   Tipo do campo
	200				, ;	// 	[05]  N   Tamanho do campo
	0				, ;	// 	[06]  N   Decimal do campo
	NIL				, ;	// 	[07]  B   Code-block de validação do campo
	{|| .T.}		, ;	// 	[08]  B   Code-block de validação When do campo
	NIL				, ;	//	[09]  A   Lista de valores permitido do campo
	.F.				, ;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
	, ;	//	[11]  B   Code-block de inicializacao do campo
	NIL				, ;	//	[12]  L   Indica se trata-se de um campo chave
	.T.				, ;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.				)	// 	[14]  L   Indica se o campo ï¿½ virtual
	
	oModel:AddFields("RH3MASTER", /*cOwner*/, oStrRH3)
	
	oModel:AddGrid(	"RH4DETAIL", "RH3MASTER", oStrRH4)
	
	oModel:SetPrimaryKey({"RH3_CODIGO"})
	
	If RH3->RH3_XTPCTM == "002"
		oModel:GetModel('RH4DETAIL'):SetLoadFilter( { { 'RH4_ITEM', "{'1', '2', '4', '5', '6', '7', '8', '9', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '24', '25', '26', '27', '28', '29'}", 9 } } )	//-MVC_LOADFILTER_IS_CONTAINED
	EndIf
	
	oModel:GetModel("RH4DETAIL"):SetUniqueLine({"RH4_ITEM"}) //Diz ao model que o campo deve ser validado quanto a repeticao
	oModel:GetModel("RH4DETAIL"):SetNoInsertLine()//Não permite incluir linhas
	
	oModel:SetRelation("RH4DETAIL", {{"RH4_FILIAL", "xFilial('RH4')"}, {"RH4_CODIGO", "RH3_CODIGO"}}, "RH4_FILIAL + RH4_CODIGO + STR(RH4_ITEM, 3)")
	
	oModel:AddGrid(	"PAEDETAIL", "RH4DETAIL", oStrPAE)

	oModel:GetModel("PAEDETAIL"):SetUniqueLine({"PAE_NUMSOL"}) //Diz ao model que o campo deve ser validado quanto a repeticao
	oModel:GetModel("PAEDETAIL"):SetNoInsertLine()//Não permite incluir linhas
	oModel:GetModel("PAEDETAIL"):SetOptional( .T. )
	oModel:SetRelation("PAEDETAIL", {{"PAE_FILIAL", "xFilial('PAE')"}, {"PAE_NUMSOL", "RH3_CODIGO"}}, "PAE_FILIAL + PAE_NUMSOL")
	
Return oModel

/*
{Protheus.doc} ViewDef()
Interface do atendimento de solicitações
@Author     Bruno de Oliveira
@Since      26/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Param		oView, interface
*/
Static Function ViewDef()
	
	Local oModel := FWLoadModel('F0100323')
	Local oStrRH3 := FWFormStruct(2, "RH3")
	Local oStrRH4 := FWFormStruct(2, "RH4")
	Local oStrPAE := FWFormStruct(2, "PAE")
	Local oView	:= FWFormView():New()
	
	If RH3->RH3_STATUS == '4' .And. ! (FunName() $ "U_F0500401") .And. ALTERA
		oView:AddUserButton("Aprovar", "", {|oModel| If(FsVldStat(), FsAprovSol(oModel), .F.) })
		oView:AddUserButton("Reprovar", "", {|oModel| If(FsVldStat(), FsReproSol(oModel), .F.) })
	EndIf
	
	oStrRH3:RemoveField("RH3_FILIAL")
	oStrRH3:RemoveField("RH3_ORIGEM")
	oStrRh3:RemoveField("RH3_TIPO")
	oStrRH3:RemoveField("RH3_TPDESC")
	oStrRH3:RemoveField("RH3_VISAO")
	oStrRH3:RemoveField("RH3_NVLINI")
	oStrRH3:RemoveField("RH3_FILINI")
	oStrRH3:RemoveField("RH3_MATINI")
	oStrRH3:RemoveField("RH3_NVLAPR")
	oStrRH3:RemoveField("RH3_FILAPR")
	oStrRH3:RemoveField("RH3_MATAPR")
	oStrRh3:RemoveField("RH3_FLUIG")
	oStrRH3:RemoveField("RH3_WFID")
	oStrRH3:RemoveField("RH3_IDENT")
	oStrRH3:RemoveField("RH3_KEYINI")
	oStrRH3:RemoveField("RH3_EMP")
	oStrRH3:RemoveField("RH3_EMPINI")
	oStrRH3:RemoveField("RH3_EMPAPR")
	oStrRH3:RemoveField("RH3_XSUSPE")
	
	oStrRH3:RemoveField("RH3_XVAGA")
	
	If RH3->RH3_XTPCTM != '002'
		oStrRH3:RemoveField("RH3_XDCARG")
	EndIf
	
	oStrRH4:RemoveField("RH4_FILIAL")
	oStrRH4:RemoveField("RH4_CAMPO")
	oStrRH4:RemoveField("RH4_CODIGO")
	oStrRH4:RemoveField("RH4_VALANT")
	
	If RH3->RH3_XTPCTM != '005' .AND. RH3->RH3_XTPCTM != '003' .AND. RH3->RH3_XTPCTM != '008' .AND. RH3->RH3_XTPCTM != '002' .And. RH3->RH3_XTPCTM != '006'
		oStrRH4:RemoveField("RH4_XOBS")
	EndIf
	
	oView:SetModel(oModel)
	oView:AddField("VIEW_RH3", oStrRH3, 'RH3MASTER')
	
	oStrRH4:AddField(	"DESCRICAO"	, ;	// [01]  C   Nome do Campo
	"3"			, ;	// [02]  C   Ordem
	'Descrição'	, ;	// [03]  C   Titulo do campo
	'Descrição'	, ;	// [04]  C   Descricao do campo
	NIL			, ;	// [05]  A   Array com Help
	"C"			, ;	// [06]  C   Tipo do campo
	""			, ;	// [07]  C   Picture
	NIL			, ;	// [08]  B   Bloco de Picture Var
	NIL			, ;	// [09]  C   Consulta F3
	.F.			, ;	// [10]  L   Indica se o campo ï¿½ alteravel
	NIL			, ;	// [11]  C   Pasta do campo
	NIL			, ;	// [12]  C   Agrupamento do campo
	NIL			, ;	// [13]  A   Lista de valores permitido do campo (Combo)
	NIL			, ;	// [14]  N   Tamanho maximo da maior opï¿½ï¿½o do combo
	NIL			, ;	// [15]  C   Inicializador de Browse
	.T.			, ;	// [16]  L   Indica se o campo ï¿½ virtual
	NIL			, ;	// [17]  C   Picture Variavel
	NIL			)	// [18]  L   Indica pulo de linha apï¿½s o campo

	oView:AddGrid("VIEW_RH4", oStrRH4, "RH4DETAIL")
	
	oView:AddGrid("VIEW_PAE", oStrPAE, "PAEDETAIL")
	
	oView:CreateHorizontalBox("TOP", 20)
	oView:CreateHorizontalBox("HALF", 60)
	oView:CreateHorizontalBox("BOTTOM", 20)
	
	oView:SetOwnerView("VIEW_RH3", "TOP")
	oView:SetOwnerView("VIEW_RH4", "HALF")
	oView:SetOwnerView("VIEW_PAE", "BOTTOM")
	
Return oView

/*
{Protheus.doc} FsVldStat()
Validaï¿½ï¿½o do campo Status
@Author     Bruno de Oliveira
@Since      26/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Return		lRet, .T. Permite continuar e .F. não permite
*/
Static Function FsVldStat
	
	Local lRet := .T.
	
	If (RH3->RH3_STATUS == "2" .OR. RH3->RH3_STATUS == "3") .OR. (M->RH3_STATUS == "2" .OR. M->RH3_STATUS == "3") // ticket n° #6327195 - 415966 - Paulo Dias - ajuste para que não seja possivel aprovar ou reprovar mais de uma vez
		MsgAlert("A solicitação ja foi atendida!", "Atenção!")
		lRet := .F.
	EndIf
	
	If RH3->RH3_STATUS == "1" .OR. M->RH3_STATUS == "1" // ticket n° #6327195 - 415966 - Paulo Dias - ajuste para que não seja possivel aprovar ou reprovar mais de uma vez
		MsgAlert("A solicitação ainda esta em processo de aprovação!", "Atenção!")
		lRet := .F.
	EndIf
	
Return lRet

/*
{Protheus.doc} FsAprovSol()
Aprovaï¿½ï¿½o da solicitação
@Author     Bruno de Oliveira
@Since      26/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Param		oModel, objeto, Modelo de dados da solicitação
*/
Static Function FsAprovSol(oModel)
	
	Local oModel     := FWModelActive()
	Local cTipo      := oModel:GetModel("RH3MASTER"):GetValue("RH3_XTPCTM")
	Local cFilSolic  := oModel:GetModel("RH3MASTER"):GetValue("RH3_FILIAL")
	Local cCodSolic  := oModel:GetModel("RH3MASTER"):GetValue("RH3_CODIGO")
	Local cFilMatri  := oModel:GetModel("RH3MASTER"):GetValue("RH3_FILINI")
	Local cCodMatri  := oModel:GetModel("RH3MASTER"):GetValue("RH3_MATINI")
	Local cCodAlc    := oModel:GetModel("RH3MASTER"):GetValue("RH3_XCODAL")
	Local lPosto     := .T.
	Local lCanPosto := .F. //Thais Paiva - 9582494
	Local cDescVg    := ""
	Local aPerFerias := {}
	Local nDiasAb    := 0
	Local nPosto     := 0
	Local nTotPos    := 0
	Local lInclui    := .T.
	Local lFatInt	 := .F.
	Local nGetSX8Len
	Local cCodPos    := ""
	Local cFieldName
	Local nField
	Local nCount
	Local lRetFAP    := .T.
	Local cValVaga   := ""
	Local cEmail     := ""
	Local lLibPst    := SuperGetMv("FS_BLQSOL",,.F.)
	local aRclTS 	 := {} // DOR05218784 - 416094 - Rogerio Carvalho - 17/10/2018  
	Local cMatDesl   := oModel:GetModel("RH3MASTER"):GetValue("RH3_MAT") // DOR05218784 - 416094 - Rogerio Carvalho - 17/10/2018
	//Local cFilDesl   := Posicione("SRA",13,cMatDesl,"RA_FILIAL") // DOR05218784 - 416094 - Rogerio Carvalho - 17/10/2018
	//Local cPostDesl  := Posicione("SRA",13,cMatDesl,"RA_POSTO")  // DOR05218784 - 416094 - Rogerio Carvalho - 17/10/2018
	Local cFilDesl   := Posicione("SRA",1,cFilMatri+cMatDesl,"RA_FILIAL") // Thais Paiva - 9625964
	Local cPostDesl  := Posicione("SRA",1,cFilMatri+cMatDesl,"RA_POSTO")  // Thais Paiva - 9625964
	Local cTpVaga    := ""
	
	Local lRet       := .T.
	Local cFilPa2
	Local nSolici
	Local cFlSolSqs
	Local cCdSolSqs
	Local cHrMes
	Local cVlMes
	Local nValVg
	Local nSlMesFun
	Local nHrMesFun
	Local nValFun   := 0
	
	
	// Don Junior 20/03/2019 - validação salï¿½rio/hora com base no F0500300.prw
	cFilPa2 := Alltrim(GetRh4Val("PA2_FILIAL"))
	
	PA2->(DbSetOrder(7))
	If PA2->(DbSeek(cFilPa2 + cFilSolic + cCodSolic))
		
		SQG->(DbSetOrder(1))
		If SQG->(DbSeek(XFilial("SQG")+PA2->PA2_CDCAND))
			
			SQS->(DbSetOrder(1))
			If SQS->(DbSeek(PA2->PA2_FILVG+PA2->PA2_CDVAGA))
				
				// Chamado No.5140150 - 418497 - Don Junior - Alteração campo QS_VCUSTO para salario fechamento (PA2_SLFECH)
				nSolici   := PA2->PA2_SLFECH // SQS->QS_VCUSTO
				cFlSolSqs := SQS->QS_XSOLFIL
				cCdSolSqs := SQS->QS_XSOLPTL
			
				RH4->(DbSetOrder(1))
	
				If RH4->(DbSeek(cFlSolSqs + cCdSolSqs + "19"))
					cHrMes := ALLTRIM(RH4->RH4_VALNOV)
				EndIf
			
				If RH4->(DbSeek(cFlSolSqs + cCdSolSqs + "14"))
					cVlMes := ALLTRIM(RH4->RH4_VALNOV)
				EndIf
				
				If !(EMPTY(cHrMes))
					nValVg := nSolici / VAL(cHrMes)
				Else
					nValVg := nSolici / 220
				EndIf
				
				SRA->(DbSetOrder(1))
				If SRA->(DbSeek(SQG->QG_FILMAT + SQG->QG_MAT))
					If SRA->RA_SITFOLH <> 'D' // ticket n° 10110526 -- evitar de ponteirar em reg anterior para recolocação
						nSlMesFun := SRA->RA_SALARIO
						nHrMesFun := SRA->RA_HRSMES
						nValFun   := nSlMesFun/ nHrMesFun
					EndIf 
				EndIf
				
				If nValFun != 0 .AND. nValVg != 0
					If nValFun <= nValVg
						lRet := .T.
					Else
						lRet := .F.
					EndIf
				EndIf
			EndIF
		EndIF
	
		If !lRet
			MsgAlert("FAP não será aprovada!" + CRLF + "Valor do salário hora atual maior que o da vaga!")
			Return .F.
		EndIf
	EndIf
	
	If MsgYesNo("Confirma a aprovacao da solicitacao?", "Atenção")
		
		If cTipo == "001" //Solicitação de Treinamento/Evento
			
			cTFilial := Alltrim(GetRh4Val("RA3_FILIAL")) //RA3_FILIAL
			cTMat    := Alltrim(GetRh4Val("RA3_MAT"   )) //RA3_MAT
			cTCalend := Alltrim(GetRh4Val("RA3_CALEND")) //RA3_CALEND
			cTCurso  := Alltrim(GetRh4Val("RA3_CURSO" )) //RA3_CURSO
			cTTurma  := Alltrim(GetRh4Val("RA3_TURMA" )) //RA3_TURMA
			cTData   := CTOD(   GetRh4Val("RA3_DATA"  )) //RA3_DATA
			
			//Verifica disponibilidade de vagas
			cAliasQry := "F0200306"
			BeginSql alias cAliasQry
				SELECT RA2_VAGAS, RA2_RESERV
				FROM %table:RA2% RA2
				WHERE RA2.RA2_CALEND = %exp:cTCalend% AND
				RA2.RA2_CURSO  = %exp:cTCurso%  AND
				RA2.RA2_TURMA  = %exp:cTTurma%  AND
				RA2.%notDel%
			EndSql
			
			If !(cAliasQry)->(EOF())
				If !((cAliasQry)->RA2_VAGAS > (cAliasQry)->RA2_RESERV)
					(cAliasQry)->( DbCloseArea() )
					
					MsgAlert("Nao existem mais vagas disponiveis para esse treinamento!", "Atenção!")
					Return .F.
				EndIf
			Else
				(cAliasQry)->( DbCloseArea() )
				
				MsgAlert("Treinamento da solicitacao nao localizado!" , "Atenção!")
				Return .F.
			EndIf
			(cAliasQry)->( DbCloseArea() )
			
			//Atualiza treinamento RA3
			DbSelectArea("RA3")
			RecLock("RA3", .T.)
			RA3->RA3_FILIAL := xFilial("RA3", cTFilial)
			RA3->RA3_MAT    := cTMat
			RA3->RA3_CALEND := cTCalend
			RA3->RA3_CURSO  := cTCurso
			RA3->RA3_TURMA  := cTTurma
			RA3->RA3_DATA   := cTData
			RA3->RA3_RESERV := "S"
			RA3->(MsUnlock())
			
			// Atualiza reservas calendario RA2
			dbSelectArea("RA2")
			RA2->(DbSetOrder(1))
			IF RA2->(DbSeek((xFilial("RA2", cTFilial) + RTRIM(cTCalend) + RTRIM(cTCurso) + RTRIM(cTTurma))))
				RecLock("RA2", .F.)
				RA2->RA2_RESERV := (RA2->RA2_RESERV + 1)
				RA2->(MsUnlock())
			EndIf
			
			//Atualiza status solicitacao
			oModel:GetModel("RH3MASTER"):SetValue("RH3_STATUS", "2")
			oModel:GetModel("RH3MASTER"):SetValue("RH3_DTATEN", dDataBase)
			
			//Alterado 24/01/2017
			U_F0500201(cFilSolic, cCodSolic, "006")//Atendido Treinamento Externo
			
		ElseIf cTipo == "002" //Solicitação de Vagas
			
			cDepto   := Alltrim(GetRh4Val("RBT_DEPTO"))
			cPosto   := Alltrim(GetRh4Val("QS_POSTO"))
			cFilPost := Alltrim(GetRh4Val("QS_FILPOST"))

			// Chamado 4330913 - 418497 - Don Junior - Validaï¿½ï¿½o para não gerar vaga duplicada
			DbSelectArea("SQS")
			SQS->(DbSetOrder(5))
			If SQS->(DbSeek(Alltrim(GetRh4Val("QS_XSOLPTL"))))
				MsgAlert("Esta vaga já foi aprovada!", "Atenção!")
				Return .F.
			EndIf
			
			DbSelectArea("RCL")
			RCL->(DbSetOrder(1)) //RCL_FILIAL + RCL_DEPTO + RCL_POSTO
			If RCL->(DbSeek(cFilPost + cDepto + cPosto))
				If (RCL->RCL_NPOSTO - RCL->RCL_OPOSTO) <= 0 .OR. (RCL->RCL_NPOSTO - RCL->RCL_OPOSTO) == 0
					lPosto := .F.
				EndIf
			EndIf
			
			If !lPosto
				If !lLibPst
					MsgAlert("Nao existe mais posto disponivel para essa vaga!", "Atenção!")
					Return .F.
				Else
					// Customizaï¿½ï¿½o feita pela fï¿½brica-SP 23/08/2018. Merge feito por Rogerio Carvalho (416094) - AMS-RJ
					//MsgAlert("O posto " + cPosto + " da filial "+ cFilPost + " estï¿½ ocupado. A vaga serï¿½ gerada, A solicitação serï¿½ processada, mas o candidato serï¿½ admitido somente apï¿½s a desocupaï¿½ï¿½o do posto. .", "Atenção!")
					MsgAlert("O posto " + cPosto + " da filial "+ cFilPost + " está ocupado. Caso não realize a adequação, a quantidade de colaboradores existentes será maior que a quantidade prevista.", "Atenção!")
				EndIf	
			EndIf
				
			SQS->(DbSetOrder(1))
			cVgDisp := GetSX8Num("SQS", "QS_VAGA")
				
			While SQS->(DbSeek(cFilPost+cVgDisp))
				ConfirmSX8()
				cVgDisp := GetSX8Num("SQS", "QS_VAGA")
			EndDo
			
			cValSal := Alltrim(GetRh4Val("QS_VCUSTO"))//ALLtrim(POSICIONE("RH4", 1, cFilSolic + cCodSolic + "14", "RH4_VALNOV"))
			
			cValSal := StrTran( cValSal, ".", "" )
			cValSal := StrTran( cValSal, ",", "." )
			
			cDescVg := POSICIONE("SRJ", 1, xFilial("SRJ") + ALLtrim(GetRh4Val("QS_FUNCAO")), "RJ_DESC")
			cObsRh4	:= GetObsRh4(RH3->RH3_FILIAL , RH3->RH3_CODIGO)
			DbSelectArea("SQS")
			RecLock("SQS", .T.)
			SQS->QS_FILIAL  := cFilPost
			SQS->QS_VAGA    := cVgDisp
			SQS->QS_DESCRIC := cDescVg
			SQS->QS_POSTO   := cPosto
			SQS->QS_FILPOST := cFilPost
			SQS->QS_CC      := Alltrim(GetRh4Val("QS_CC"))
			SQS->QS_FUNCAO  := Alltrim(GetRh4Val("QS_FUNCAO"))
			SQS->QS_SOLICIT := POSICIONE("SRA",1,RH3->(RH3_FILINI+RH3_MATINI),"RA_NOME")//Alltrim(GetRh4Val("QS_SOLICIT"))
			SQS->QS_VCUSTO  := VAL(cValSal)
			SQS->QS_TIPO    := Alltrim(GetRh4Val("QS_TIPO"))
			SQS->QS_NRVAGA  := 1
			SQS->QS_DTABERT := DATE()
			SQS->QS_FILRESP := cFilMatri
			SQS->QS_MATRESP := cCodMatri
			SQS->QS_XSTATUS := "2"
			SQS->QS_XJORN   := VAL(Alltrim(GetRh4Val("QG_XHRMES")))
			SQS->QS_XSOLFIL := Alltrim(GetRh4Val("QS_FILIAL"))
			SQS->QS_XSOLPTL := Alltrim(GetRh4Val("QS_XSOLPTL"))
			SQS->QS_XOBSERV := cObsRh4//Alltrim(oModel:GetModel("RH4DETAIL"):GetValue("RH4_XOBS", 25))
			SQS->QS_XPUBLIC := "2"
			SQS->QS_XTURNO := Alltrim(GetRh4Val("QG_XTURNTB")) //Ajustado conforme update U01003
			SQS->QS_XDESTUR := POSICIONE("SR6",1,xFilial("SR6")+ Alltrim(GetRh4Val("QG_XTURNTB")),"R6_DESC")

			SQS->QS_XJUSTVA := Alltrim(GetRh4Val("QS_XJUSTVA"))
			SQS->QS_XREQSOL := Alltrim(GetRh4Val("QS_XREQSOL"))
			SQS->QS_XLOCALI := Alltrim(GetRh4Val("QS_XLOCALI"))

			SQS->QS_XOUTROS := AllTrim(GetOutRh4(RH3->RH3_FILIAL , RH3->RH3_CODIGO))//Alltrim(GetRh4Val("QS_XOUTROS"))

			MSMM(, ,, Alltrim(cObsRh4), 1, ,, "SQS", "QS_CODPERF")
			SQS->(MsUnLock())
			
			//Atualiza status solicitacao
			oModel:GetModel("RH3MASTER"):SetValue("RH3_STATUS", "2")
			oModel:GetModel("RH3MASTER"):SetValue("RH3_DTATEN", dDataBase)

			// ticket n° 6486292 - 415966 - Paulo Dias 
			DbSelectArea("RH3")
			RH3->(DbSetOrder(1))
			If RH3->(DbSeek(cFilSolic+cCodSolic))
				RecLock("RH3",.F.)
				RH3->RH3_STATUS := "2"
				RH3->RH3_DTATEN := dDataBase 
				RH3->RH3_XDTAPV := DATE()
							
				RH3->(MsUnLock())
			EndIf
			// Fim ticket n° 6486292
			
			//Alterado 24/01/2017
			U_F0500201(cFilSolic, cCodSolic, "006")
			U_F0500201(cFilSolic, cCodSolic, "011")//EM RECRUTAMENTO
					
		ElseIf cTipo == "003" //Solicitação de Aumento de Quadro\Orï¿½amento
			
			// Atualiza RBT - // Busca RH4
			
			cPCC     := GetRh4Val("RCL_CC")
			cPDepto  := GetRh4Val("RCL_DEPTO")
			cPFunc   := GetRh4Val("RCL_FUNCAO")
			cPCarg   := GetRh4Val("RCL_CARGO")
			nPSalar  := Val(GetRh4Val("RCL_SALAR"))
			cPTpost  := GetRh4Val("RCL_TPOSTO")
			cPTcont  := GetRh4Val("RCL_TPCONT")
			cPQtdM   := GetRh4Val("RCL_NPOSTO")
			cCodPost := GetRh4Val("RCL_POSTO")
			cFilPost := GetRh4Val("RCL_FILIAL")
			
			If "Novo"  $ GetRh4Val("RBT_TIPOR") .AND. Empty(Alltrim(cCodPost)) //Thais Paiva - 18799380
				cCodPost := GetNPosto(ALLTRIM(cFilPost)) //RCLPostoInit() Thais Paiva - 18799380
			EndIf

			//Valida tipo de posto se a solicitacao for de atualizacao de posto que ja existe
			If !Empty(Alltrim(cCodPost)) .And. !("Novo"  $ GetRh4Val("RBT_TIPOR"))
				If !( FsVldTPos( ALLTRIM(cFilPost), cCodPost ) )
					Return .F.
				Else
					cPTpost := '2'
				EndIf
			EndIf
			
			Begin Transaction
				
				DbSelectArea("RBT")
				RecLock("RBT", .T.)
				RBT->RBT_FILIAL := ALLTRIM(cFilPost)
				RBT->RBT_CODMOV	:= GetSx8Num("RBT", "RBT_CODMOV")
				RBT->RBT_DTAMOV := dDataBase
				RBT->RBT_CC     := cPCC
				RBT->RBT_DEPTO  := cPDepto
				RBT->RBT_FUNCAO := cPFunc
				RBT->RBT_CARGO  := cPCarg
				RBT->RBT_REMUNE := nPSalar
				RBT->RBT_TPOSTO := cPTpost
				RBT->RBT_TPCONT := cPTcont
				RBT->RBT_QTDMOV := VAL(cPQtdM)
				RBT->RBT_CODPOS := cCodPost
				RBT->RBT_JUSTIF := "02"
				RBT->RBT_TIPOR  := "2"
				RBT->RBT_STATUS := "1"
				RBT->(MsUnLock())
				
			End Transaction
			
			// Atualizando RBX - Registro de movimentacao do departamento
			DbSelectArea("RBX")
			RecLock("RBX", .T.)
			RBX->RBX_FILIAL := ALLTRIM(cFilPost)
			RBX->RBX_DEPTO 	:=	cPDepto
			RBX->RBX_CODMOV :=	RBT->RBT_CODMOV
			RBX->RBX_DTAMOV :=	RBT->RBT_DTAMOV
			RBX->RBX_CODOPE :=	"1"
			RBX->RBX_TPOSTO :=	cPTpost
			RBX->RBX_QTDOPE	:=	VAL(cPQtdM)
			RBX->RBX_RESOPE	:=	cUsername
			RBX->RBX_JUSTIF :=  "01"
			RBX->(MsUnLock())
						
			// Atualiza Status da Solicitacao
			oModel:GetModel("RH3MASTER"):SetValue("RH3_STATUS", "2")
			oModel:GetModel("RH3MASTER"):SetValue("RH3_DTATEN", dDataBase)

			DbSelectArea("RH3")
			RH3->(DbSetOrder(1))
			If RH3->(DbSeek(cFilSolic+cCodSolic))
				RecLock("RH3",.F.)
				RH3->RH3_STATUS := "2"
				RH3->RH3_DTATEN := dDataBase 
				RH3->RH3_XDTAPV := DATE()
							
				RH3->(MsUnLock())
			EndIf
			
			nQtDig := RBX->RBX_QTDOPE
			
			//Efetua gravacao de postos/historico
			If ( !Empty(RBX->RBX_CODMOV) )
				
				Begin Transaction
					
					nGetSX8Len:= GetSX8Len()
					
					dbSelectArea("RCL")
					RCL->(dbSetOrder( RetOrder("RCL", "RCL_FILIAL + RCL_POSTO") ))
					dbSelectArea("RBT")
					RBT->(dbSetOrder(RetOrder("RBT", "RBT_FILIAL + RBT_CODMOV")))
					RBT->(DbSeek(RBT->RBT_FILIAL + RBX->RBX_CODMOV))
					
					RecLock("RBT", .F.)
					//cCodPos	:= RBT->RBT_CODPOS
					// comentario rogerio lInclui:= !(RCL->(DbSeek(RBT->RBT_FILIAL + RBT->RBT_CODPOS)))
					lInclui := !(RCL->(DbSeek(RBT->RBT_FILIAL + cCodPost)))
					If !lInclui
						RBT->RBT_TPOSTO := "2"
					EndIf
					
					RBT->(MsUnlock())
					
					If RBX->RBX_CODOPE == "1"  //  Caso for Aprovado
						
						//Registro de criacao/alteracao do posto
						dbSelectArea("RCL")
						If ( !lInclui )
							RCL->(dbSetOrder( RetOrder("RCL", "RCL_FILIAL + RCL_POSTO") ))
							RCL->(DbSeek(xFilial("RCL", RBT->RBT_FILIAL) + cCodPost))
						EndIf
						
						For nPosto:= 1 to nQtDig
							//cPTpost := IIF(cPTpost == "1" .AND. !lInclui,"2","1")    
							If "Novo"  $ GetRh4Val("RBT_TIPOR") .and. Empty(Alltrim(cCodPost))
								cCodPost := GetNPosto(ALLTRIM(cFilPost)) //RCLPostoInit() Thais Paiva 18799380
							EndIf					 
							If !(RCL->(DbSeek(RBT->RBT_FILIAL + cCodPost)))	// ticket n° 11067430			
								RecLock("RCL",lInclui)
								If lInclui
									RCL->RCL_FILIAL 	:=	RBT->RBT_FILIAL
									RCL->RCL_POSTO 		:=	cCodPost
									RCL->RCL_PROCES 	:=	RBT->RBT_PROCES
									RCL->RCL_DEPTO 		:= 	cPDepto
									RCL->RCL_CARGO 		:=	cPCarg
									RCL->RCL_FUNCAO 	:=	cPFunc
									RCL->RCL_CC			:=	cPCC
									RCL->RCL_SALAR   	:=	RBT->RBT_REMUNE
									RCL->RCL_ENCARG  	:= 	RBT->RBT_ENCARG
									RCL->RCL_BENEF   	:= 	RBT->RBT_BENEF
									RCL->RCL_TPCONT   :=	RBT->RBT_TPCONT
									RCL->RCL_STATUS   := "1"	   				//Posto Vago para ocupacao
									RCL->RCL_DTATU    :=	dDataBase
									RCL->RCL_FGTS     := RBT->RBT_FGTS
								EndIf
							Else
								RecLock("RCL",.F.)
							EndIf //Thais Paiva - 13137521
							//Se o posto for generico cria um unico registro de posto com a quantidade aprovada.
							// comentario rogerio carvalho 18/12/2017  
							// RCL->RCL_NPOSTO     	:= IIf(cPTpost=="2", RCL->RCL_NPOSTO + nQtDig, 1)	//1=Individual;2=Generico
							// Fim Comentario 

							nNPOSTO     	:= IIf(cPTpost=="2", RCL->RCL_NPOSTO + nQtDig, 1)	//1=Individual;2=Generico

							RCL->RCL_NPOSTO     	:= nNPOSTO
							
							If lInclui //Thais Paiva - 13137521
								RCL->RCL_TPOSTO 		:= cPTpost		//1=Individual;2=Generico
							EndIf //Thais Paiva - 13137521

							// comentario rogerio carvalho 18/12/2017 
							//nTotPos					:= RCL->RCL_NPOSTO
							// Fim Comentario

							nTotPos	:= nNPOSTO
							
							// DOR05218784 - 416094 - Rogerio Carvalho - 17/10/2018
							// apï¿½s o aumento de quadro, chama função para readequar se necessï¿½rio, 
							// os substitutos para titulares e totalizar novamente
							// a quantidade de titulares e substitutos nos campos da RCL
							If (cPTpost =="2") .and. ( nQtDig > 0) .and. (RCL->RCL_XSPOST > 0)
								aRclTS := u_AmsAjQuad(RCL->RCL_FILIAL,RCL->RCL_POSTO,nQtDig)
								RCL->RCL_OPOSTO := aRclTS[1]
								RCL->RCL_XSPOST := aRclTS[2]
							Endif
							// FIM - DOR05218784
							
							RCL->(MsUnLock())
							//EndIf Thais Paiva - 13137521
							
							//Registro de movimentacao do posto
							RecLock("RBU", .T.)
							RBU->RBU_FILIAL 	:=	xFilial("RBU", RCL->RCL_FILIAL)
							RBU->RBU_POSTO 		:=	RCL->RCL_POSTO
							RBU->RBU_CODMOV		:=	CriaVar("RBU_CODMOV")
							RBU->RBU_DTAMOV  	:=	RCL->RCL_DTATU
							RBU->RBU_OPERAC 	:=  If( lInclui, "1", "2" )					//1=Criaï¿½ï¿½o;2=Atualização;3=Ocupaï¿½ï¿½o;4=Congelamento;5=Cancelamento
							RBU->RBU_RESPON		:=	cUserName
							RBU->RBU_ORIGEM		:=	RBT->RBT_CODMOV 		//Relacionar com o movimentacao do Departamento RBT
							RBU->RBU_NPOSTO		:=	nTotPos
							RBU->RBU_DEPTO      :=  cPDepto
							RBU->RBU_CARGO      :=  cPCarg
							
							For nCount:= 1 To RCL->(FCount())
								cFieldName:= RCL->(FieldName(nCount))
								
								If cFieldName $ "RCL_FILIAL/RCL_POSTO/RCL_TPOSTO/RCL_NPOSTO/RCL_OPOSTO/RCL_STATUS/RCL_DTINI/RCL_DTFIM/RCL_DTATU"
									Loop
								EndIF
								
								nField:= RBU->(FieldPos(StrTran(cFieldName, "RCL", "RBU")))
								
								If nField == 0
									Loop
								EndIF
								
								RBU->(FieldPut(nField, RCL->( FieldGet(nCount) ) ) )
							
								If cPTpost == '2'
									Exit
								EndIf
							Next
							
							RBU->(MsUnLock())
							
							//ï¿½ Se o posto for generico cria um unico registro de posto com a quantidade aprovada.										   ï¿½
							If cPTpost == "2"	//1=Individual;2=Generico
								Exit
							EndIf
							
						Next nPosto
						
					EndIf
					
					While ( GetSX8Len() > nGetSX8Len )
						ConfirmSX8()
					End While
					
				End Transaction
				
			EndIf
			
			U_F0500201(cFilSolic, cCodSolic, "006")//Atendido
			
			
		ElseIf cTipo == "004" //Solicitação da FAP
		
			//Início - Thais Paiva - 9582494
			cDepto   := Alltrim(GetRh4Val("TMP_DPTVAG"))
			cPosto   := Alltrim(GetRh4Val("TMP_POSTO"))
			cFilPost := Alltrim(GetRh4Val("TMP_FPOSTO"))
			
			If CancPosto(1,cFilPost,cDepto,cPosto,"","")
				MsgAlert("Posto cancelado!", "Atenção!")
				Return .F.
			EndIf
			//Fim - Thais Paiva - 9582494
			
			//Valida se a Vaga tem valor compativel com o candidado interno
			dbSelectArea("SQG")
			SQG->(DbSetOrder(1))
			SQG->(DbSeek(XFilial("SQG")+GetRh4Val("PA2_CDCAND")))
			
			If SitCand(SQG->QG_CIC)
				If Val(GetRh4Val("PA2_SLFECH")) > 0
					cValVaga := GetRh4Val("PA2_SLFECH")
				Else
					cValVaga := GetRh4Val("PA2_VLVAGA")
				EndIf
				
				//-Posiciona as tabelas necessï¿½rias
				dbSelectArea("SRA")
				SRA->(DbSetOrder(1))
				SRA->(DbSeek(GetRh4Val("PA2_FILCAN")+SQG->QG_MAT,.F.))
				dbSelectArea("SQS")
				SQS->(DbSetOrder(1))
				SQS->(DbSeek(GetRh4Val("TMP_FILVAG")+GetRh4Val("PA2_CDVAGA"),.F.))
				dbSelectArea("SQG")
				//(Valor da FAP/Carga horï¿½ria da vaga) < Valor hora da SRA.
				IF Round((Val(cValVaga) / SQS->QS_XJORN),2) < IIF(SRA->RA_CATFUNC $ "G*H", SRA->RA_SALARIO, Round(SRA->(RA_SALARIO / RA_HRSMES),2))
				//?If Val(cValVaga) < SQG->QG_ULTSAL
					MsgAlert("O Candidato tem um salário maior que o proposto pela Vaga.")
					lRetFAP := .F.
				EndIf
				lFatInt := .T.
				// Customizaï¿½ï¿½o feita pela fï¿½brica-SP 16/08/2018. Merge feito por Rogerio Carvalho (416094) - AMS-RJ
				//If !lLibPst 16/08/2018
					If lRetFAP  .And. !U_F050030S(oModel)
						lRetFAP := .F.
					EndIf
				// Customizaï¿½ï¿½o feita pela fï¿½brica-SP 16/08/2018. Merge feito por Rogerio Carvalho (416094) - AMS-RJ
				/*Else
					If lRetFAP
					
						cAlias1 := GetNextAlias()
					
						cQuery := "SELECT SQS.QS_FILPOST, SQS.QS_POSTO, RCL.RCL_NPOSTO, RCL.RCL_OPOSTO "
						cQuery += "FROM " + RetSqlName("SQS") + " SQS "
						cQuery += "INNER JOIN " + RetSqlName("RCL") + " RCL "
						cQuery += "ON ( RCL.RCL_FILIAL = SQS.QS_FILPOST AND RCL.RCL_POSTO = SQS.QS_POSTO "
						cQuery += "AND RCL.D_E_L_E_T_ = ' ') "
						cQuery += "WHERE SQS.QS_FILIAL = '" + GetRh4Val("TMP_FILVAG") + "' "
						cQuery += "AND SQS.QS_VAGA = '" + GetRh4Val("PA2_CDVAGA") + "' "
						cQuery += "AND SQS.D_E_L_E_T_ = ' ' "
						
						cQuery := ChangeQuery(cQuery)
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1)
						
						If (cAlias1)->(!EOF())
							If ((cAlias1)->RCL_NPOSTO - (cAlias1)->RCL_OPOSTO) == 0 
								MsgAlert("O posto "+ (cAlias1)->QS_POSTO +" da filial "+ (cAlias1)->QS_FILPOST +" estï¿½ totalmente ocupado. O Status da solicitação serï¿½ alterado para 'Aguardando Liberaï¿½ï¿½o do Posto'")
								If RH3->(DbSeek(cFilSolic+cCodSolic))
									If RH3->RH3_XLIBPT != "1"
										RecLock("RH3",.F.)
										RH3->RH3_XLIBPT := "1" //Posto não livre
										RH3->(MsUnLock())
										MsgAlert("Clique no Confirmar para atualizar o status")	
										U_F0500201(cFilSolic, cCodSolic, "025")//Aguardando liberaï¿½ï¿½o
									EndIf
									lRetFAP := .F.
								EndIf	
								DbSelectArea("SQS")
								SQS->(DbSetOrder(1))
								If SQS->(DbSeek(GetRh4Val("TMP_FILVAG")+GetRh4Val("PA2_CDVAGA")))
									If SQS->QS_XSTATUS != "A"
										RecLock("SQS",.F.)
										SQS->QS_XSTATUS := "A" //Posto não livre
										SQS->(MsUnLock())
										U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "025")//Aguardando liberaï¿½ï¿½o
									EndIf
								EndIf												
							Else
								If !U_F050030S(oModel)
									lRetFAP := .F.
								Else
									If RH3->(DbSeek(cFilSolic+cCodSolic))
										If RH3->RH3_XLIBPT == "1"
											RecLock("RH3",.F.)
											RH3->RH3_XLIBPT := "" //Posto livre
											RH3->(MsUnLock())
											U_F0500201(cFilSolic, cCodSolic, "026")//Liberaï¿½ï¿½o do Posto	
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
						
						(cAlias1)->(DbCloseArea())
						
					EndIf					
				EndIf*/
				// FIM - Customizaï¿½ï¿½o feita pela fï¿½brica-SP 16/08/2018. Merge feito por Rogerio Carvalho (416094) - AMS-RJ
			EndIf
			
			If Empty(Alltrim(cFilPa2)) //Thais Paiva - 25597797
				cFilPa2 := Alltrim(GetRh4Val("PA2_FILIAL", oModel)) //Alltrim(GetRh4Val("PA2_FILIAL")) Thais Paiva - 18799380
			EndIf //Thais Paiva - 25597797
			
			If Empty(Alltrim(cFilPa2)) //Início Thais Paiva - 25597797
				cFilPa2 := Alltrim(oModel:GetModel("RH3MASTER"):GetValue("RH3_FILIAL")) 
			EndIf //Fim Thais Paiva - 25597797
			
			If lRetFAP  
				If U_F0500302(cFilPa2, cFilSolic, cCodSolic, "AP")// .AND. U_F9999999(SQS->QS_FILIAL,SQS->QS_VAGA)
					//Atualiza status solicitacao
					oModel:GetModel("RH3MASTER"):SetValue("RH3_STATUS", "2")
					oModel:GetModel("RH3MASTER"):SetValue("RH3_DTATEN", dDataBase)

					/* ticket n° 7106096 - 415966 - Paulo Dias 
					==---------------------------------------------------------------------------------------------------------==
					|| Garanto que a atualização de status e data de atendimento sejam gravados na RH3                         ||
			    	|| em alinhamento com a rotina de movimentação evitando dados divergentes entre as tabelas respectivas     ||
					|| e a RH3 caso o processo seja abortado por algum motivo                                                  ||
					==---------------------------------------------------------------------------------------------------------||
					*/
					DbSelectArea("RH3")
					RH3->(DbSetOrder(1))
					If RH3->(DbSeek(cFilSolic+cCodSolic))
						RecLock("RH3",.F.)
						RH3->RH3_STATUS := "2"
						RH3->RH3_DTATEN := dDataBase 
						RH3->RH3_XDTAPV := DATE()
							
						RH3->(MsUnLock())
					EndIf
					// Fim ticket n° 7106096
				Else
					Return .F.
				EndIf
			Else
				
				Return .F.
				
			EndIf

			If !lFatInt
				U_F0500201(cFilSolic, cCodSolic, "006")//Atendido
				U_F0500201(cFilSolic, cCodSolic, "019")			
			EndIf
		ElseIf cTipo == "005" //Solicitação de Desligamento
			
			If U_F0500104(oModel)
				
				//Atualiza status solicitacao
				oModel:GetModel("RH3MASTER"):SetValue("RH3_STATUS", "2")
				oModel:GetModel("RH3MASTER"):SetValue("RH3_DTATEN", dDataBase)
			Else
				
				Return .F.
				
			EndIf
			U_F0500201(cFilSolic, cCodSolic, "006")//Atendido			
			
			// DOR05218784 - Trata RCL para ajuste de Posto , qundo funcionario ï¿½ desligado
			// Chama função para ajustar os postos , em relaï¿½ï¿½o a qtd de titulares e substitutos
			u_AmsDesPost(cFilDesl,cPostDesl) 
			//  DOR05218784 - 18/10/2018 - 416094 - Rogerio Carvalho
			
		ElseIf cTipo == "006" //Solicitação Cargos e Salarios
			
			//Início - Thais Paiva - 9582494
			If CancPosto(2,"","","",cFilSolic,cCodSolic)
				MsgAlert("Posto cancelado!", "Atenção!")
				Return .F.
			EndIf
			//Fim - Thais Paiva - 9582494
			
			if U_F0500402(oModel)
				
				//Atualiza status solicitacao
				oModel:GetModel("RH3MASTER"):SetValue("RH3_STATUS", "2")
				oModel:GetModel("RH3MASTER"):SetValue("RH3_DTATEN", dDataBase)
			Else
				
				Return .F.
				
			EndIf
			
			U_F0500201(cFilSolic, cCodSolic, "006")//Atendido
		ElseIf cTipo == "007" //Incentivo Academico
			
			//Atualiza status solicitacao
			oModel:GetModel("RH3MASTER"):SetValue("RH3_STATUS", "2")
			oModel:GetModel("RH3MASTER"):SetValue("RH3_DTATEN", dDataBase)
			
			U_F0500201(cFilSolic, cCodSolic, "006")//Atendido
			
		ElseIf cTipo == "008"
			// **************************** Ferias
			
			//Busca Dados da solicitacao de ferias
			cAliasQry := "SolFer"
			BeginSql alias cAliasQry
				SELECT RH4_CODIGO, RH4_CAMPO, RH4_VALNOV
				FROM %table:RH4% RH4
				WHERE 	RH4.RH4_CODIGO = %exp:cCodSolic% AND
				RH4.%notDel%
			EndSql
			
			nTamFilial := TAMSX3("R8_FILIAL")[1]
			
			Dbselectarea(cAliasQry)
			While !(cAliasQry)->(eof())
				
				Do Case
				Case alltrim((cAliasQry)->RH4_CAMPO) == "R8_FILIAL"
					cFerFilial				    := SubStr( (cAliasQry)->RH4_VALNOV, 1, nTamFilial)
				Case alltrim((cAliasQry)->RH4_CAMPO) == "R8_MAT"
					cFerMat					    := (cAliasQry)->RH4_VALNOV
				Case alltrim((cAliasQry)->RH4_CAMPO) == "R8_DATAINI"
					dFerDtIni				      := CtoD((cAliasQry)->RH4_VALNOV)
				Case alltrim((cAliasQry)->RH4_CAMPO) == "R8_DATAFIM"
					dFerDtFim			  		  := CtoD((cAliasQry)->RH4_VALNOV)
				Case alltrim((cAliasQry)->RH4_CAMPO) == "R8_DURACAO"
					nFerDuracao		    	  := val((cAliasQry)->RH4_VALNOV)
				Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_ABONO"
					lFerAbono			    	  := If (alltrim((cAliasQry)->RH4_VALNOV) == ".T.", .T., .F.)
				Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_1P13SL"
					lFer13Sal			    	  := If (alltrim((cAliasQry)->RH4_VALNOV) == ".T.", .T., .F.)
				EndCase
				cDatabas := ""
				
				
				(cAliasQry)->(dbskip())
			Enddo
			(cAliasQry)->( DbCloseArea() )
			
			If (cPaisLoc $ "BRA|CHI|PAR|URU")
				dbSelectArea("SRA")
				SRA->(DbSetOrder(1)) // ticket n° 6191921 - 415966 - Paulo Dias - Ponteirando registro
				If !SRA->( MsSeek( cFerFilial + alltrim(cFerMat) ) )
					MsgAlert("Cadastro do funcionario da solicitacao nao localizado!" , 'Atenção') //
					oReturn := Nil
					Return .F.
				EndIf
				
				dbSelectArea("SRF")
				SRF->(DbSetOrder(1))
				If !SRF->( MsSeek( cFerFilial + alltrim(cFerMat) + cDatabas ) )
					MsgAlert("Nao existe periodo de ferias no cadastro de Programacao de Ferias!" , 'Atenção') //
					oReturn := Nil
					Return .F.
				Else
					fCarPerFer(cFerFilial, alltrim(cFerMat), @aPerFerias)
					If len(aPerFerias) > 0
						SRF->(dbGoto(aPerFerias[1][30]))
					Else
						MsgAlert("Nao existe periodo de ferias no cadastro de Programacao de Ferias!" , 'Atenção') //
						oReturn := Nil
						Return .F.
					EndIf
				EndIf
				
				nIdade := Int((dDataBase - SRA->RA_NASC) / 365)
				
				If ( lFerAbono .or. lFer13Sal .Or. ( nFerDuracao < 30 .AND. (nIdade < 18 .Or. nIdade > 50) ) )
					cMensagem := OemToAnsi("Funcionário : ") + CRLF	//"Funcionário : " + CRLF
					If nIdade < 18 .AND. nFerDuracao < 30
						cMensagem += OemToAnsi("- Menor de 18 anos e deve tirar férias em período único.") + CRLF //"- ?menor de 18 anos e deve tirar fias em perdo ico." + CRLF
					ElseIf nIdade > 50 .AND. nFerDuracao < 30
						cMensagem += OemToAnsi("- Maior de 50 anos e deve tirar férias em período único.") + CRLF //"- ?maior de 50 anos e deve tirar fias em perdo ico." + CRLF
					EndIf
					If lFerAbono
						cMensagem += OemToAnsi("- Solicitou abono de fias.") + CRLF //"- Solicitou abono de fias." + CRLF
					EndIf
					If lFer13Sal
						cMensagem += OemToAnsi("- Solicitou adiantamento de 13o salio.") + CRLF //"- Solicitou adiantamento de 13o salio." + CRLF
					EndIf
					cMensagem += CRLF + OemToAnsi("A tela Controle de Dias de Direito sera aberta para realizar o complemento dos dados!")	//"A tela Controle de Dias de Direito sera aberta para realizar o complemento dos dados!
					If !MsgYesNo(cMensagem, "Deseja continuar?") //cMensagem ### "Deseja continuar?"
						oReturn := Nil
						Return .F.
					EndIf
					
					//Atualiza solicitacao para o Brasil pelo GPEA050
					IF 	(!Empty(SRF->RF_DATAINI) .and. !Empty(SRF->RF_DATINI2) .and. !Empty(SRF->RF_DATINI3))
						MsgAlert("Todas as programacoes disponiveis ja estao ocupadas, verifique!", 'Atenção') //
						oReturn := Nil
						Return .F.
					EndIf
					
					oModGPE	:= FWLOADMODEL('GPEA050')
					oModSRF	:= oModGPE:GetModel("GPEA050_SRF")
					oModGPE:SetOperation( 4 )
					oModGPE:Activate()
					oModSRF:SeekLine({{"RF_STATUS", "1"} })
					TCF040Prep(dFerDtIni, nFerDuracao, oModSRF)
					oReturn := FWExecView('', 'GPEA050', 4, , { || .T. }, ,, ,, ,, oModGPE)
					If (oReturn == 0)
					// ticket n° 8104950 - 415966 
						DbSelectArea("RH3")
						RH3->(DbSetOrder(1))
						If RH3->(DbSeek(cFilSolic+cCodSolic))
							RecLock("RH3",.F.)
							RH3->RH3_STATUS := "2"
							RH3->RH3_DTATEN := dDataBase 
							RH3->RH3_XDTAPV := DATE()
								
							RH3->(MsUnLock())
						EndIf
					/*
						oModel:GetModel("RH3MASTER"):SetValue("RH3_STATUS", "2")
						oModel:GetModel("RH3MASTER"):SetValue("RH3_DTATEN", dDataBase)
					*/
					Else
						oReturn := Nil
					EndIf
				Else
					//Atualiza direto SRF(Programacao de ferias)
					IF Empty(SRF->RF_DATAINI)
						RecLock("SRF", .F.)
						SRF->RF_DATAINI	:= dFerDtIni
						SRF->RF_DFEPRO1	:= nFerDuracao
						SRF->RF_DABPRO1	:= nDiasAb
						SRF->(MsUnlock())
					ElseIf Empty(SRF->RF_DATINI2)
						RecLock("SRF", .F.)
						SRF->RF_DATINI2	:= dFerDtIni
						SRF->RF_DFEPRO2	:= nFerDuracao
						SRF->RF_DABPRO2	:= nDiasAb
						SRF->(MsUnlock())
					ElseIf Empty(SRF->RF_DATINI3)
						RecLock("SRF", .F.)
						SRF->RF_DATINI3	:= dFerDtIni
						SRF->RF_DFEPRO3	:= nFerDuracao
						SRF->RF_DABPRO3	:= nDiasAb
						SRF->(MsUnlock())
					Else
						MsgAlert("Todas as programacoes disponiveis ja estao ocupadas, verifique!" , 'Atenção') //
						oReturn := Nil
						Return .F.
					EndIf
					//  ticket n° 8104950 - 415966 
						DbSelectArea("RH3")
						RH3->(DbSetOrder(1))
						If RH3->(DbSeek(cFilSolic+cCodSolic))
							RecLock("RH3",.F.)
							RH3->RH3_STATUS := "2"
							RH3->RH3_DTATEN := dDataBase 
							RH3->RH3_XDTAPV := DATE()
								
							RH3->(MsUnLock())
						EndIf
					/*
					oModel:GetModel("RH3MASTER"):SetValue("RH3_STATUS", "2")
					oModel:GetModel("RH3MASTER"):SetValue("RH3_DTATEN", dDataBase)
					*/
					//Alterado 24/01/2017
				EndIf

			EndIF
			U_F0500201(cFilSolic, cCodSolic, "006")//Atendido
		EndIf
				
		If oModel:VldData()
		
			oModel:GetModel("RH3MASTER"):SetValue("RH3_XDTAPV", Date())
			
			oModel:CommitData()
			
			PAB->(DbSetOrder(1))
			PAB->(DbSeek(xFilial("PAB") + cCodAlc))
	
			SRA->(DbSetOrder(1))
			SRA->(DbSeek(cFilSolic + cCodSolic))
			
			cEmail := ";" + GetEmail(cFilSolic, cCodSolic, cFilMatri, cCodMatri,.F.)
			U_F0800901("5", cEmail, cFilSolic, cCodSolic, SRA->RA_NOME, cTipo, PAB->PAB_GRPSOL,"","Aprovado na Efetivação")
			
			MsgInfo("Solicitacao aprovada", "Atenção")
			lBtApRp := .F.
		Else
			MsgAlert(oModel:GetErrorMessage()[6], "Atencao!")
		EndIf

		// Ticket No. 4494084 - 418497 - Don Junior - Atualização quantidade posto
		If cTipo <> "008" //Thais Paiva - 14304811
			cTpVaga := Alltrim(GetRh4Val("TMP_TIPOFA"))
		EndIf //Thais Paiva - 14304811
		AtlzRCL(cFilSolic,cCodSolic,cTpVaga) // Atualização RCL com dados da RCX
		
		 // Atualização desligamento
		 If cTipo == "005"
			AtlzDesl(cFilSolic,cPostDesl)
		EndIf
	EndIf
	
Return

/*
{Protheus.doc} FsReproSol()
Reprovação da solicitação
@Author     Bruno de Oliveira
@Since      26/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Param		oModel, objeto, Modelo de dados da solicitação
*/
Static Function FsReproSol(oModel)
	
	Local oModel     := FWModelActive()
	Local cTipo      := oModel:GetModel("RH3MASTER"):GetValue("RH3_XTPCTM")
	Local cFilSolic  := oModel:GetModel("RH3MASTER"):GetValue("RH3_FILIAL")
	Local cCodSolic  := oModel:GetModel("RH3MASTER"):GetValue("RH3_CODIGO")
	Local cVisSolic  := oModel:GetModel("RH3MASTER"):GetValue("RH3_VISAO")
	Local cMatSolic  := oModel:GetModel("RH3MASTER"):GetValue("RH3_MAT")
	Local cNomeFun   := POSICIONE("SRA", 1, cFilSolic + cMatSolic, "RA_NOME")
	Local cCodAlc	 := oModel:GetModel("RH3MASTER"):GetValue("RH3_XCODAL")
	Local cFilMatri:= oModel:GetModel("RH3MASTER"):GetValue("RH3_FILINI")
	Local cCodMatri:= oModel:GetModel("RH3MASTER"):GetValue("RH3_MATINI")
	Local cCALEN     := ""
	Local cCURSO     := ""
	Local cTURMA     := ""
	Local cTreina    := ""
	Local lMotivo		:= .F.
	Local aMotivo		:= {.T.,""}
	Local cMotivo		:= ""
	Local lRep       := .F. // ticket n° 9220575 
	If cTipo == "001"
		cCALEN     := Alltrim(GetRh4Val("RA3_CALEND"))
		cCURSO     := Alltrim(GetRh4Val("RA3_CURSO"))
		cTURMA     := Alltrim(GetRh4Val("RA3_TURMA"))
		cTreina    := POSICIONE("RA2", 1, cFilSolic + cCALEN + cCURSO + cTURMA, "RA2_DESC")
	EndIf
	
	If MsgNoYes("Confirma a Reprovação da solicitação?", "Atenção")
		
		While aMotivo[1] .And. Empty(aMotivo[2])  
			aMotivo := U_Motivo()
			If aMotivo[1] .And. Empty(aMotivo[2])
				Alert("É obrigatório o preenchimento de uma justificativa para Reprovação!")
			EndIf
		EndDo
		
		If !aMotivo[1]
			Return
		EndIf
		
		If cTipo == "001" //Treinamento/Evento
			U_F0500201(cFilSolic, cCodSolic, "007")//Reprovado Posto
			
			/*
			If EnvRepro(cVisSolic, cFilSolic, cCodSolic, cTipo, cTreina, cNomeFun)
				MSGALERT("Email enviado")
			Else
				MSGALERT("Email não enviado")
			EndIf
			*/
			
			cAssunto 	:= "Solicitação de Treinamento"
			cDesSol 	:= "Treinamento"
			cEmail 	:= POSICIONE("SRA", 1, cFilSolic + cMatSolic , "RA_EMAIL")
			EnvMail(cAssunto, cDesSol, cEmail, cFilSolic, cCodSolic, cTipo, cCodAlc, cMatSolic, cFilMatri, cCodMatri, aMotivo[2])
			
			oModel:GetModel("RH3MASTER"):SetValue("RH3_STATUS", "3")
			oModel:GetModel("RH3MASTER"):SetValue("RH3_DTATEN", dDataBase)
			
		ElseIf cTipo == "002" //Solicitação de Vagas
			
			//U_F0500201(cFilSolic, cCodSolic, "007")//Reprovado Vaga // ticket n° 9220575 -- linha comentada
			
			// ticket n° 9220575 - gravação da RH3, após gravação da PA5
			lRep := U_F0500201(cFilSolic, cCodSolic, "007")

			If lRep
				DbSelectArea("RH3")
				RH3->(DbSetOrder(1))
				If RH3->(DbSeek(cFilSolic+cCodSolic))
					RecLock("RH3",.F.)
					RH3->RH3_STATUS := "3"
					RH3->RH3_DTATEN := dDataBase 
					RH3->(MsUnLock())
				EndIf
			EndIf

			cAssunto 	:= "Solicitação de Vagas"
			cDesSol 	:= "vaga"
			cEmail 	:= POSICIONE("SRA", 1, cFilSolic + cMatSolic , "RA_EMAIL")
			EnvMail(cAssunto, cDesSol, cEmail, cFilSolic, cCodSolic, cTipo, cCodAlc, cMatSolic, cFilMatri, cCodMatri, aMotivo[2])
			
			//oModel:GetModel("RH3MASTER"):SetValue("RH3_STATUS", "3")
			//oModel:GetModel("RH3MASTER"):SetValue("RH3_DTATEN", dDataBase)
			
		ElseIf cTipo == "003" //Solicitação de Aumento de Quadro
			
			U_F0500201(cFilSolic, cCodSolic, "007")
			cAssunto 	:= "Solicitação de Aumento de Quadro"
			cDesSol 	:= "Aumento de Quadro"
			cEmail 	:= POSICIONE("SRA", 1, cFilSolic + cMatSolic , "RA_EMAIL")
			EnvMail(cAssunto, cDesSol, cEmail, cFilSolic, cCodSolic, cTipo, cCodAlc, cMatSolic, cFilMatri, cCodMatri, aMotivo[2])
			
			oModel:GetModel("RH3MASTER"):SetValue("RH3_STATUS", "3")
			oModel:GetModel("RH3MASTER"):SetValue("RH3_DTATEN", dDataBase)
			
		ElseIf cTipo == "004" //Solicitação da FAP
			
			cFilPa2 := Alltrim(GetRh4Val("PA2_FILIAL"))
			
			If U_F0500302(cFilPa2, cFilSolic, cCodSolic, "RE")
				
				//Atualiza status solicitacao
				oModel:GetModel("RH3MASTER"):SetValue("RH3_STATUS", "3")
				oModel:GetModel("RH3MASTER"):SetValue("RH3_XLIBPT", "" )
				oModel:GetModel("RH3MASTER"):SetValue("RH3_DTATEN", dDataBase)

				cAssunto 	:= "Solicitação de FAP"
				cDesSol 	:= "FAP"
				cEmail 	:= POSICIONE("SRA", 1, cFilSolic + cMatSolic , "RA_EMAIL")
				EnvMail(cAssunto, cDesSol, cEmail, cFilSolic, cCodSolic, cTipo, cCodAlc, cMatSolic, cFilMatri, cCodMatri, aMotivo[2])
				U_F0500201(cFilSolic, cCodSolic, "007")
			Else
				
				Return .F.
				
			EndIf
			
		ElseIf cTipo == "005" //Solicitação de Desligamento
			
			If U_F0500110(cCodSolic, "3", cFilSolic)
				
				oModel:GetModel("RH3MASTER"):SetValue("RH3_STATUS", "3")
				oModel:GetModel("RH3MASTER"):SetValue("RH3_DTATEN", dDataBase)
				//Alterado 26/01/2017
				U_F0500201(cFilSolic, cCodSolic, "007")//Reprovado solicitação de desligamento

				cAssunto 	:= "Solicitação de Desligamento"
				cDesSol 	:= "Desligamento"
				cEmail 	:= POSICIONE("SRA", 1, cFilSolic + cMatSolic , "RA_EMAIL")
				EnvMail(cAssunto, cDesSol, cEmail, cFilSolic, cCodSolic, cTipo, cCodAlc, cMatSolic, cFilMatri, cCodMatri, aMotivo[2])
			Else
				
				Return .F.
				
			EndIf
			
		ElseIf cTipo == "006" //Solicitação de Cargos e Salarios
			
			If U_F0500407(cFilSolic, cMatSolic, cCodSolic, cVisSolic)
				
				DbSelectArea("RH3")
				RH3->(DbSetOrder(1))
				If RH3->(DbSeek(cFilSolic+cCodSolic))
					RecLock("RH3",.F.)
					RH3->RH3_STATUS := "3"
					RH3->RH3_DTATEN := dDataBase 
					RH3->RH3_XLIBPT := ""
						
					RH3->(MsUnLock())
				EndIf
				
				oModel:GetModel("RH3MASTER"):SetValue("RH3_STATUS", "3")
				oModel:GetModel("RH3MASTER"):SetValue("RH3_XLIBPT", "" )
				oModel:GetModel("RH3MASTER"):SetValue("RH3_DTATEN", dDataBase)
				
				cAssunto 	:= "Solicitação de Cargos e Salários"
				cDesSol 	:= "Cargos e Salários"
				cEmail 	:= POSICIONE("SRA", 1, cFilSolic + cMatSolic , "RA_EMAIL")
				EnvMail(cAssunto, cDesSol, cEmail, cFilSolic, cCodSolic, cTipo, cCodAlc, cMatSolic, cFilMatri, cCodMatri, aMotivo[2])
				U_F0500201(cFilSolic, cCodSolic, "007")
			Else
				
				Return .F.
				
			EndIf
			
		ElseIf cTipo == "007" //Incentivo Academico
			U_F0500201(cFilSolic, cCodSolic, "007")//Reprovado Incentivo Academico
			
			/*
			If EnvRepro(cVisSolic, cFilSolic, cCodSolic, cTipo, "", cNomeFun)
				MSGALERT("Email enviado")
			Else
				MSGALERT("Email não enviado")
			EndIf
			*/
			cAssunto 	:= "Incentivo Academico"
			cDesSol 	:= "Incentivo"
			cEmail 	:= POSICIONE("SRA", 1, cFilSolic + cMatSolic , "RA_EMAIL")
			EnvMail(cAssunto, cDesSol, cEmail, cFilSolic, cCodSolic, cTipo, cCodAlc, cMatSolic, cFilMatri, cCodMatri, aMotivo[2])
			
			oModel:GetModel("RH3MASTER"):SetValue("RH3_STATUS", "3")
			oModel:GetModel("RH3MASTER"):SetValue("RH3_DTATEN", dDataBase)
		ElseIf cTipo == "008"
			
			U_F0500201(cFilSolic, cCodSolic, "007")//Reprovado
			/*
			If EnvRepro(cVisSolic, cFilSolic, cCodSolic, cTipo, "", cNomeFun)
				MSGALERT("Email enviado")
			Else
				MSGALERT("Email não enviado")
			EndIf
			*/
			cAssunto 	:= "Solicitação de Férias"
			cDesSol 	:= "Férias"
			cEmail 	:= POSICIONE("SRA", 1, cFilSolic + cMatSolic , "RA_EMAIL")
			EnvMail(cAssunto, cDesSol, cEmail, cFilSolic, cCodSolic, cTipo, cCodAlc, cMatSolic, cFilMatri, cCodMatri, aMotivo[2])
			
			// ticket n° 8104950 - 415966 
			DbSelectArea("RH3")
			RH3->(DbSetOrder(1))
			If RH3->(DbSeek(cFilSolic+cCodSolic))
				RecLock("RH3",.F.)
				RH3->RH3_STATUS := "3"
				RH3->RH3_DTATEN := dDataBase 					
				RH3->(MsUnLock())
			EndIf
			/*
			oModel:GetModel("RH3MASTER"):SetValue("RH3_STATUS", "3")
			oModel:GetModel("RH3MASTER"):SetValue("RH3_DTATEN", dDataBase)
			*/
		Else
			
			oModel:GetModel("RH3MASTER"):SetValue("RH3_STATUS", "3")
			oModel:GetModel("RH3MASTER"):SetValue("RH3_DTATEN", dDataBase)
			
		EndIf
		
		
		If oModel:VldData()
		
			oModel:GetModel("RH3MASTER"):SetValue("RH3_XDTAPV", Date())
		
			oModel:CommitData()
			//--------------------------------------------
			// Gravar PA6 da Reprovacao do Desligamento //
			//--------------------------------------------
			If cTipo == "005" //Solicitação de Desligamento
				U_F0600601(RH3->RH3_FILIAL, "RH3", RH3->RH3_CODIGO, RH3->(Recno()), "DELETE")
			Endif
			MsgInfo("Solicitação reprovada", "Atenção")
			lBtApRp := .F.
		Else
			MsgAlert(oModel:GetErrorMessage()[6], "Atencao!")
		EndIf
		
	EndIf
	
Return

/*
{Protheus.doc} FCancAtend()
Validaï¿½ï¿½o do cancelamento do modelo
@Author     Bruno de Oliveira
@Since      26/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Param		oModel, objeto, Modelo de dados da solicitação
*/
Static Function FCancAtend(oModel)
	
	If !lBtApRp
		MsgAlert("Foi realizado operação de aprovação ou reprovação da solicitação, não é permitido cancelar", "Atenção!")
	EndIf
	
Return lBtApRp

/*
{Protheus.doc} FsVldTPos()
Validaï¿½ï¿½o do tipo de posto
@Author     Bruno de Oliveira
@Since      26/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Param		cFilRCL, caracter, Filial do posto
@Param		cCodPos, caracter, Código do posto
@Return		lRet
*/
Static Function FsVldTPos(cFilRCL, cCodPos)
	
	Local aArea := FwGetArea()
	Local lRet  := .T.
	
	DbSelectArea("RCL")
//	RCL->(DbSetOrder(RetOrder("RCL", "RCL_FILIAL + RCL_POSTO")))
	RCL->(DbSetOrder(1))
	RCL->(DbSeek(cFilRCL + cCodPos))
	
	If RCL->RCL_TPOSTO == "1"
		If !MsgYesNo( "O Posto Origem é Individual, após a aprovação ele se tornará Genérico!" + CRLF + "Deseja continuar?" , "Atenção" )
			lRet := .F.
		EndIf
	EndIf
	
	FwRestArea(aArea)
	
Return lRet

/*
{Protheus.doc} EnvRepro()

@Author     FSW
@Since      26/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Param		
@Return		
*/
Static Function EnvRepro(cVisao, cFIRH3H4, cCodSolt, cTipo, cTreina, cNomeFun)
	Local cBody     := ""
	Local cAssunto  := ""
	Local cQuery    := ""
	Local cTipVis   := ""
	Local cFilSol   := ""
	Local cConc     := " + "
	Local lNOracle  := TCGetDB() != 'ORACLE'
	Local cAliasSUP := 'RETSUP'
	Local lRet      := .F.
	
	TipoOrg(@cTipVis, cVisao)
	
	cMatFezSol	:= POSICIONE("RH3", 1, cFIRH3H4 + cCodSolt, "RH3_MATINI")
	cFilSol	:= POSICIONE("RH3", 1, cFIRH3H4 + cCodSolt, "RH3_FILINI")
	
	If !lNOracle
		cConc := "||"
	EndIf
	
	//Por posto
	if cTipVis == '1'
		
		cQuery := "	SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_EMAIL " + CRLF
		cQuery += "	FROM " + RetSqlName("SRA") + " (NOLOCK) " + CRLF
		cQuery += "	WHERE D_E_L_E_T_ = '' " + CRLF
		cQuery += "	  AND RA_SITFOLH    <> 'D'  " + CRLF
		cQuery += "	  AND RA_FILIAL" + cConc + "RA_MAT IN ( SELECT RCX_FILFUN" + cConc + "RCX_MATFUN " + CRLF
		cQuery += "	  			FROM " + RetSqlName("RCX") + " (NOLOCK) " + CRLF
		cQuery += "	  			INNER JOIN " + RetSqlName("RDZ") + " (NOLOCK) " + CRLF
		cQuery += "	  					ON RDZ_CODENT = RCX_FILFUN" + cConc + "RCX_MATFUN " + CRLF
		cQuery += "	  							AND " + RetSqlName("RDZ") + ".D_E_L_E_T_ = '' " + CRLF
		cQuery += "	  			INNER JOIN " + RetSqlName("RD0") + "  (NOLOCK) " + CRLF
		cQuery += "	  							ON RD0_FILIAL  = '' " + CRLF
		cQuery += "	  							AND RD0_CODIGO = RDZ_CODRD0 " + CRLF
		cQuery += "	  							AND " + RetSqlName("RD0") + ".D_E_L_E_T_ = '' " + CRLF
		cQuery += "	  			WHERE RCX_FILIAL = '" + cFilSol + "' " + CRLF
		cQuery += "	  					AND " + RetSqlName("RCX") + ".D_E_L_E_T_ = '' " + CRLF
		cQuery += "	  					AND RCX_SUBST = '2' " + CRLF
		cQuery += "	  					AND RCX_TIPOCU = '1' " + CRLF
		cQuery += "	  					AND RCX_DTFIM = '' " + CRLF
		cQuery += "	  					AND RCX_FILFUN" + cConc + "RCX_POSTO IN ( 	SELECT RD4_FILIDE" + cConc + "RD4_CODIDE " + CRLF
		cQuery += "	  												FROM " + RetSqlName("RD4") + " (NOLOCK) " + CRLF
		cQuery += "	  												WHERE " + RetSqlName("RD4") + ".D_E_L_E_T_ = '' " + CRLF
		cQuery += "	  												  AND RD4_FILIAL = '" + cFilSol + "' " + CRLF
		cQuery += "	  												  AND RD4_CODIGO = '" + cVisao + "' " + CRLF
		cQuery += "	  												  AND RD4_TREE >= ( SELECT RD4_TREE " + CRLF
		cQuery += "	  																	FROM  " + RetSqlName("RD4") + " (NOLOCK) " + CRLF
		cQuery += "	  																	WHERE RD4_FILIAL = '" + cFilSol + "' " + CRLF
		cQuery += "	  																	 AND RD4_CODIGO = '" + cVisao + "' " + CRLF
		cQuery += "	  																	 AND D_E_L_E_T_ ='' " + CRLF
		cQuery += "	  																	 AND RD4_CODIDE = (SELECT RCX_POSTO " + CRLF
		cQuery += "	  																						FROM " + RetSqlName("RCX") + " (NOLOCK) " + CRLF
		cQuery += "	  																						WHERE RCX_FILIAL = '" + cFilSol + "'" + CRLF
		cQuery += "	  																						  AND D_E_L_E_T_ = '' " + CRLF
		cQuery += "	  																						  AND RCX_SUBST = '2'  " + CRLF
		cQuery += "	  																						  AND RCX_TIPOCU = '1' " + CRLF
		cQuery += "	  																						  AND RCX_DTFIM = '' " + CRLF
		cQuery += "	  																						  AND RCX_POSTO" + cConc + "RCX_FILFUN" + cConc + "RCX_MATFUN = (	SELECT RA_POSTO" + cConc + "RA_FILIAL" + cConc + "RA_MAT " + CRLF
		cQuery += "	  																																	FROM " + RetSqlName("SRA") + " (NOLOCK) " + CRLF
		cQuery += "	  																																	WHERE RA_FILIAL = '" + cFilSol + "' " + CRLF
		cQuery += "	  																																	AND RA_MAT = '" + cMatFezSol + "' " + CRLF
		cQuery += "	  																																	AND RA_SITFOLH    <> 'D'  " + CRLF
		cQuery += "	  																																	AND D_E_L_E_T_ = '') " + CRLF
		cQuery += "	  																						) " + CRLF
		cQuery += "	  																		) " + CRLF
		cQuery += "	  													) " + CRLF
		cQuery += "	  										) " + CRLF
		
	Else
		
		cQuery := "	SELECT RA_MAT, RA_NOME, RA_EMAIL " + CRLF
		cQuery += "	FROM " + RetSqlName("SQB") + " (NOLOCK) " + CRLF
		cQuery += "	INNER JOIN " + RetSqlName("RD4") + " (NOLOCK) " + CRLF
		cQuery += "			ON RD4_FILIAL = '" + cFilSol + "' " + CRLF
		cQuery += "			AND RD4_CODIGO = '" + cVisao + "' " + CRLF
		cQuery += "			AND " + RetSqlName("RD4") + ".D_E_L_E_T_ = '' " + CRLF
		cQuery += "			AND RD4_TREE >= ( " + CRLF
		cQuery += "								SELECT RD4_TREE " + CRLF
		cQuery += "								FROM " + RetSqlName("RD4") + " (NOLOCK) " + CRLF
		cQuery += "								WHERE RD4_FILIAL = '" + cFilSol + "' " + CRLF
		cQuery += "						  		  AND RD4_CODIGO = '" + cVisao + "' " + CRLF
		cQuery += "						 		  AND " + RetSqlName("RD4") + ".D_E_L_E_T_ = '' " + CRLF
		cQuery += "						  		 AND RD4_CODIDE = (	SELECT RA_DEPTO	 " + CRLF
		cQuery += "													FROM " + RetSqlName("SRA") + " (NOLOCK) " + CRLF
		cQuery += "													WHERE RA_FILIAL = '" + cFilSol + "' " + CRLF
		cQuery += "											  		  AND RA_MAT = '" + cMatFezSol + "' " + CRLF
		cQuery += "											          AND " + RetSqlName("SRA") + ".D_E_L_E_T_ = '' " + CRLF
		cQuery += "											 		  AND RA_SITFOLH    <> 'D'  " + CRLF
		cQuery += "											  	   )" + CRLF
		cQuery += "							) " + CRLF
		cQuery += "			AND RD4_FILIDE = QB_FILIAL " + CRLF
		cQuery += "			AND RD4_CODIDE = QB_DEPTO " + CRLF
		cQuery += "			AND " + RetSqlName("SQB") + ".D_E_L_E_T_ = '' " + CRLF
		cQuery += "	INNER JOIN " + RetSqlName("SRA") + " (NOLOCK)  " + CRLF
		cQuery += "	        ON RA_FILIAL = QB_FILRESP " + CRLF
		cQuery += "			AND RA_MAT = QB_MATRESP " + CRLF
		cQuery += "			AND RA_SITFOLH  <> 'D'  " + CRLF
		cQuery += "			AND " + RetSqlName("SRA") + ".D_E_L_E_T_ = '' " + CRLF
		
	EndIf
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAliasSUP)
	
	While !(cAliasSUP)->(EOF())
		If cTipo == "007"
			cAssunto 	:= "Incentivo à Educação 'Reprovado'"
			
			cBody := '<html><body><pre>' + CRLF
			cBody += '<b>Prezado, </b>' + CRLF
			cBody += "Prezado gestor, a Solicitação de Incentivo à Educação "
			cBody += "solicitado para o colaborador '" + cNomeFun + "' foi reprovado. "
			cBody += "Para maiores informações, procure o RH da sua Unidade"
			cBody += '</pre></body></html>'
		ElseIf cTipo == "001"
			cAssunto 	:= "Retorno Solicitação 'Reprovada'"
			
			cBody := '<html><body><pre>' + CRLF
			cBody += '<b>Prezado, </b>' + CRLF
			cBody += "O treinamento '" + cTreina + "' "
			cBody += "solicitado para o colaborador '" + cNomeFun + "' foi reprovado. "
			cBody += "Para maiores informações, procure o RH da sua Unidade"
			cBody += '</pre></body></html>'
			
		EndIf
		
		If U_F0200304(cAssunto, cBody, (cAliasSUP)->(RA_EMAIL))
			lRet := .T.
		Else
			lRet := .F.
		EndIf
		(cAliasSUP)->(DbSkip())
	EndDo
	
	(cAliasSUP)->(DbCloseArea())
	
Return lRet

/*
{Protheus.doc} AjustVal()

@Author     FSW
@Since      26/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Param		
@Return		
*/
Static Function AjustVal(oModel, cFilSol)
	
	Local nX		  := 1
	Local nLine     := 1
	Local cValue    := ""
	Local cOldVal   := ""
	Local cDescDpt  := ""
	Local oModelRH4 := oModel:GetModel("RH4DETAIL")
	Local aDesc     := {;
		{"TMP_VAGA"  , "Tipo da Vaga"                 },;
		{"TMP_DSCDPT", "Descrição Departamento"       },;
		{"TMP_TABSAL", "Tabela Salarial"              },;
		{"TMP_FUNCAO", "Código da função atual"       },;
		{"TMP_D_FUNC", "Descrição da função"          },;
		{"TMP_SALATU", "Salario Atual"                },;
		{"TMP_TABELA", "Tabela Salarial"              },;
		{"TMP_NIVELT", "Nivel"                        },;
		{"TMP_FAIXAT", "Faixa"                        },;
		{"TMP_D_MOT" , "Descrição do motivo"          },;
		{"TMP_VLSALA", "Valor do reajuste proposto"   },;
		{"TMP_PERCSA", "Percentual reajuste proposto" },;
		{"TMP_D_F_PP", "Nome da Função Proposta"      },;
		{"TMP_H_M_AT", "Hora mês Atual"               },;
		{"TMP_H_S_AT", "Hora"                         },;
		{"TMP_H_D_AT", "Horas Dia Atual"              },;
		{"TMP_TURNAT", "Turno de Trabalho Atual"      },;
		{"TMP_D_TURN", "Nome do Turno Atual"          },;
		{"TMP_S_TURN", "Seq.Ini.Turno Atual"          },;
		{"TMP_REGRA" , "Regra Atual"                  },;
		{"TMP_DESCTU", "Nome do Turno Proposto"       },;
		{"TMP_FILIAL", "Filial Atual"                 },;
		{"TMP_D_FILI", "Nome da Filial Atual"         },;
		{"TMP_CCATU" , "Centro de Custo Atual"        },;
		{"TMP_D_CCAT", "Descrição Centro Custo Atual" },;
		{"TMP_DEPTOA", "Departamento Atual"           },;
		{"TMP_D_DEPT", "Nome do Departamento Atual"   },;
		{"TMP_N_F_D" , "Nome Filial/Empresa proposta" },;
		{"TMP_D_CC_D", "Desc. Centro Custo Proposto"  },;
		{"TMP_D_DEPD", "Nome do Departamento Proposto"},;
		{"TMP_PROCES", "Processo Proposto"            },;
		{"TMP_CLVL"  , "Classe de Valor"              },;
		{"TMP_ITEM"  , "Item"                         },;
		{"TMP_TIPO"  , "Tipo de Solicitação"          },;
		{"TMP_DESRES", "Descrição da Rescisão"        },;
		{"TMP_NOME"  , "Nome"                         },;
		{"TMP_ABONO" , "Abono"                        },;
		{"RA_SALARIO", "Salario Proposto"             },;
		{"TMP_FILVAG", "Filial da vaga"               },;
		{"TMP_DESCVG", "Descrição da filial"          },;
		{"TMP_TIPOFA", "Tipo da FAP"                  },;
		{"TMP_CARGOV", "Cargo vaga"                   },;
		{"TMP_DSCCGV", "Descrição cargo vaga"         },;
		{"TMP_CCVAGA", "Centro de Custo vaga"         },;
		{"TMP_DSCVAG", "Descrição cc vaga"            },;
		{"TMP_DPTVAG", "Departamento"                 },;
		{"TMP_DSCDVA", "Descrição do departamento"    },;
		{"TMP_MATCOL", "Matricula colaborador"        },;
		{"TMP_NOMECO", "Nome colaborador"             },;
		{"TMP_FPOSTO", "Filail Posto vaga"            },;
		{"TMP_FILPOS", "Filail Posto Candidato"       },;
		{"TMP_CODPOS", "Posto do Candidato"           },;
		{"TMP_TURVAG", "Turno da Vaga"                },;
		{"TMP-Desc.P", "Descrição Posto"              },;
		{"TMP-Desc.C", "Descrição Contrato"           },;		
		{"TMP_JUSTIF", "Justificativa"                },;
		{"TMPP-D-MOT", "Motivo"                 	  },;
		{"TMP_JORNVG", "Jornada da Vaga"              },;
		{"TMP_OBS"   , "Observação"            		  },;
		{"TMP_DFUNCA", "Função"      	       		  },;
		{"TMP_SALFUN", "Salário"                      },;
		{"TMP_1P13SL", "13 Salário"            	      },;
		{"AlPostRepo", "Posto Reporte"                },;
		{"AlDesDpRep", "Descrição Dep Reporte"        },;
		{"AlDepRepor", "Departamento Reporte"         },;
		{"AlDescRepo", "Descrição Filial Reporte"     },;
		{"AlFilRepor", "Filial Reporte"               },;
		{"AlFilSol  ", "Filial Selecionada"           },;
		{"AlDescSol ", "Descrição Filial Selecionada" },;
		{"AlDeptSol ", "Departamento Selecionado"     },;
		{"AlDescDept", "Descrição Dep Selecionado"    },;
		{"TMP_ESCL", "Mérito" 	   	        	      },;
		{"TMP_OBSINC", "Observação"            	      };
		}
	
	For nLine:= 1 to Len(aDesc)
		If oModelRH4:SeekLine({{"RH4_CAMPO", aDesc[nLine][1]}})
			oModelRH4:LoadValue("RH4_DESCAM", aDesc[nLine][2])
		EndIf
	Next

	If oModelRH4:SeekLine({{"RH4_CAMPO", "TMP_ESCL"}})
		IF  "1" $ FwFldGet("RH4_VALNOV")
			cValue  := "Sim"
		Else	
			cValue  := "Não"
		EndIf	
		oModelRH4:LoadValue("RH4_VALNOV", cValue)	
	EndIf
		
	If oModelRH4:SeekLine({{"RH4_CAMPO", "TMP_POSTO"}})
		If oModel:GetModel("RH3MASTER"):GetValue("RH3_XTPCTM") == "004" //FAP
			cValue  := "Posto da Vaga"
		ElseIf oModel:GetModel("RH3MASTER"):GetValue("RH3_XTPCTM") == "006" //Mov.Pessoal	
			cValue  := "Posto Atual"		
		EndIf
		oModelRH4:LoadValue("RH4_DESCAM", cValue)
	EndIf

	If oModelRH4:SeekLine({{"RH4_CAMPO", "TMP_XOBS"}})
		If oModel:GetModel("RH3MASTER"):GetValue("RH3_XTPCTM") == "002" //FAP
			cValue  := "Descrição da Vaga"
		Else
			cValue  := "Observação"		
		EndIf
		oModelRH4:LoadValue("RH4_DESCAM", cValue)
	EndIf

	
	If oModelRH4:SeekLine({{"RH4_CAMPO", "RCL_FILIAL"}})
		cValue  := FWFilialName(,AllTrim(FwFldGet("RH4_VALNOV")),1)
		oModelRH4:LoadValue("DESCRICAO", cValue)
	EndIf
	
	If oModelRH4:SeekLine({{"RH4_CAMPO", "QS_FILIAL"}})
		cValue  := FWFilialName(,AllTrim(FwFldGet("RH4_VALNOV")),1)
		oModelRH4:LoadValue("DESCRICAO", cValue)
	EndIf
	
	If oModelRH4:SeekLine({{"RH4_CAMPO", "P10_FILIAL"}})
		cValue  := FWFilialName(,AllTrim(FwFldGet("RH4_VALNOV")),1)
		oModelRH4:LoadValue("DESCRICAO", cValue)
	EndIf
	
	If oModelRH4:SeekLine({{"RH4_CAMPO", "PA2_FILIAL"}})
		cValue  := FWFilialName(,AllTrim(FwFldGet("RH4_VALNOV")),1)
		oModelRH4:LoadValue("DESCRICAO", cValue)
	EndIf
	
	If oModelRH4:SeekLine({{"RH4_CAMPO", "R8_FILIAL"}})
		cValue  := FWFilialName(,AllTrim(FwFldGet("RH4_VALNOV")),1)
		oModelRH4:LoadValue("DESCRICAO", cValue)
	EndIf
	
	If oModelRH4:SeekLine({{"RH4_CAMPO", "P10_MATRIC"}})
		cValue  := POSICIONE("SRA", 1, cFilSol + AllTrim(FwFldGet("RH4_VALNOV")) , "RA_NOME")
		oModelRH4:LoadValue("DESCRICAO", cValue)
	EndIf
	
	If oModelRH4:SeekLine({{"RH4_CAMPO", "P10_DTSOLI"}})
		IF  "/" $ FwFldGet("RH4_VALNOV")
			cValue  := AllTrim(FwFldGet("RH4_VALNOV"))
		Else
			cValue  := SubStr(AllTrim(FwFldGet("RH4_VALNOV")), 7, 2) + "/" + SubStr(AllTrim(FwFldGet("RH4_VALNOV")), 5, 2) + "/" + SubStr(AllTrim(FwFldGet("RH4_VALNOV")), 1, 4)
		EndIf
		oModelRH4:LoadValue("RH4_VALNOV", cValue)
	EndIf
	
	If oModelRH4:SeekLine({{"RH4_CAMPO", "P10_DTDEMI"}})
		IF  "/" $ FwFldGet("RH4_VALNOV")
			cValue  := AllTrim(FwFldGet("RH4_VALNOV"))
		Else
			cValue  := SubStr(AllTrim(FwFldGet("RH4_VALNOV")), 7, 2) + "/" + SubStr(AllTrim(FwFldGet("RH4_VALNOV")), 5, 2) + "/" + SubStr(AllTrim(FwFldGet("RH4_VALNOV")), 1, 4)
		EndIf
		oModelRH4:LoadValue("RH4_VALNOV", cValue)
	EndIf
	/*
	If oModelRH4:SeekLine({{"RH4_CAMPO", "TMP_ABONO"}})
		IF  "T" $ FwFldGet("RH4_VALNOV")
			cValue  := "Sim"
		Else	
			cValue  := "Não"
		EndIf	
		oModelRH4:LoadValue("RH4_VALNOV", cValue)	
	EndIf
	
	If oModelRH4:SeekLine({{"RH4_CAMPO", "TMP_1P13SL"}})
		IF  "T" $ FwFldGet("RH4_VALNOV")
			cValue  := "Sim"
		Else	
			cValue  := "Não"
		EndIf	
		oModelRH4:LoadValue("RH4_VALNOV", cValue)	
	EndIf	
	*/
	If oModelRH4:SeekLine({{"RH4_CAMPO", "TMP_VAGA"}})
		oModelRH4:LoadValue("DESCRICAO", "Contratação")
	EndIf
	
	If oModelRH4:SeekLine({{"RH4_CAMPO", "QS_POSTO"}})
		oModelRH4:LoadValue("DESCRICAO", GetRH4Val("TMP_DSCDPT"))
	EndIf
	
	If oModelRH4:SeekLine({{"RH4_CAMPO", "QS_FILPOST"}}) //"QS_FILIAL"
		cValue  := FWFilialName(,AllTrim(FwFldGet("RH4_VALNOV")),1)
		oModelRH4:LoadValue("DESCRICAO", cValue)
	EndIf
	
	If oModelRH4:SeekLine({{"RH4_CAMPO", "QS_CC"}})
		aArea   := CTT->(FwGetArea())
		cValue  := POSICIONE("CTT", 1, XFILIAL("CTT") + AllTrim(FwFldGet("RH4_VALNOV")), "CTT_DESC01")
		oModelRH4:LoadValue("DESCRICAO", cValue)
		CTT->(FwRestArea(aArea))
	EndIf
	
	If oModelRH4:SeekLine({{"RH4_CAMPO", "RBT_DEPTO"}})
		cDescDpt := GetRh4Val("TMP_DSCDPT")
		oModelRH4:LoadValue("DESCRICAO", cDescDpt )
	EndIf
	
	If oModelRH4:SeekLine({{"RH4_CAMPO", "QS_FUNCAO"}})
		aArea   := SRJ->(FwGetArea())
		cValue  := POSICIONE("SRJ", 1, XFILIAL("SRJ") + AllTrim(FwFldGet("RH4_VALNOV")), "RJ_DESC")
		oModelRH4:LoadValue("DESCRICAO", cValue)
		SRJ->(FwRestArea(aArea))
	EndIf
	
	If oModelRH4:SeekLine({{"RH4_CAMPO", "QG_XCATFUN"}})
		aArea   := SX5->(FwGetArea())
		cValue  := POSICIONE("SX5", 1, xFilial("SX5") + "28" + AllTrim(FwFldGet("RH4_VALNOV")) , "X5_DESCRI")
		oModelRH4:LoadValue("DESCRICAO", cValue)
		SX5->(FwRestArea(aArea))
	EndIf
	
	If oModelRH4:SeekLine({{"RH4_CAMPO", "QG_XTURNTB"}})
		aArea   := SR6->(FwGetArea())
		cValue  := POSICIONE("SR6", 1, xFilial("SR6") + AllTrim(FwFldGet("RH4_VALNOV")) , "R6_DESC")
		oModelRH4:LoadValue("DESCRICAO", cValue)
		SR6->(FwRestArea(aArea))
	EndIf
	
	If oModelRH4:SeekLine({{"RH4_CAMPO", "QG_XTPCONT"}})
		cValue  := If(AllTrim(FwFldGet("RH4_VALNOV")) == "1", "Indeterminado", "Determinado")
		oModelRH4:LoadValue("DESCRICAO", cValue)
	EndIf
	
	If oModelRH4:SeekLine({{"RH4_CAMPO", "TMP_ABONO"}})
		cValue  := If(AllTrim(FwFldGet("RH4_VALNOV")) == ".T.", "Solicitado", "Não Solicitado")
		oModelRH4:LoadValue("DESCRICAO", cValue)
	EndIf
	
	If oModelRH4:SeekLine({{"RH4_CAMPO", "TMP_1P13SL"}})
		cValue  := If(AllTrim(FwFldGet("RH4_VALNOV")) == ".T.", "Solicitado", "Não Solicitado")
		oModelRH4:LoadValue("DESCRICAO", cValue)
	EndIf
	
	If oModelRH4:SeekLine({{"RH4_CAMPO", "QS_XJUSTVA"}})
		cValue  := iif(!Empty(AllTrim(FwFldGet("RH4_VALNOV"))),X3CboxToArray("QS_XJUSTVA")[1][Val(AllTrim(FwFldGet("RH4_VALNOV")))],"")
		oModelRH4:LoadValue("DESCRICAO", cValue)
	EndIf

	If oModelRH4:SeekLine({{"RH4_CAMPO", "QS_XREQSOL"}})
		cValue  := iif(!Empty(AllTrim(FwFldGet("RH4_VALNOV"))),X3CboxToArray("QS_XREQSOL")[1][Val(AllTrim(FwFldGet("RH4_VALNOV")))],"")
		oModelRH4:LoadValue("DESCRICAO", cValue)
	EndIf

	If oModelRH4:SeekLine({{"RH4_CAMPO", "QS_XLOCALI"}})
		cValue  := iif(!Empty(AllTrim(FwFldGet("RH4_VALNOV"))),X3CboxToArray("QS_XLOCALI")[1][Val(AllTrim(FwFldGet("RH4_VALNOV")))],"")
		oModelRH4:LoadValue("DESCRICAO", cValue)
	EndIf
	
	
	If oModelRH4:SeekLine({{"RH4_CAMPO", "TMP_TABSAL"}})
		cFilPost := GetRh4Val("QS_FILPOST")
		cCodVg   := GetRh4Val("QS_FUNCAO")
		
		cFilRb6 := U_F0600402( cFilPost, "RB6")
		cFilSq3 := U_F0600402( cFilPost, "SQ3")
		cFilRbR := U_F0600402( cFilPost, "RBR")
		
		cQuery := "SELECT DISTINCT RB6.RB6_TABELA, RB6.RB6_DESCTA FROM " + RetSqlName("RBR") + " RBR "
		cQuery += "INNER JOIN " + RetSqlName("SQ3") + " SQ3 "
		cQuery += "ON SQ3.Q3_FILIAL = '" + cFilSq3 + "' "
		cQuery += "AND SQ3.Q3_CARGO  = '" + cCodVg + "' "
		cQuery += "AND SQ3.Q3_TABELA = RBR.RBR_TABELA "
		cQuery += "AND SQ3.D_E_L_E_T_ = ' '  "
		cQuery += "INNER JOIN " + RetSqlName("RB6") + " RB6 "
		cQuery += "ON RB6.RB6_FILIAL = '" + cFilRb6 + "' "
		cQuery += "AND RB6.RB6_TABELA     = SQ3.Q3_TABELA "
		cQuery += "AND RB6.RB6_NIVEL  = SQ3.Q3_TABNIVE "
		cQuery += "AND RB6.RB6_DTREF = RBR.RBR_DTREF   "
		cQuery += "AND RB6.D_E_L_E_T_ = ' '  "
		cQuery += "WHERE RBR.RBR_FILIAL = '" + cFilRbr + "' "
		cQuery += "AND RBR.RBR_APLIC = '1' "
		cQuery += "AND RBR.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAliasQry)
		cCod  := ""
		cDesc := ""
		If !(cAliasQry)->(EOF())
			cDesc  := (cAliasQry)->(RB6_DESCTA)
			cCod   := (cAliasQry)->(RB6_TABELA)
		EndIf
		
		(cAliasQry)->( DbCloseArea() )
		oModelRH4:LoadValue("RH4_VALNOV", cCod)
		oModelRH4:LoadValue("DESCRICAO" , cDesc)
	EndIf
	
	For nX := 1 To oModelRH4:Length()
		oModelRH4:GoLine(nX)

		If AllTrim(FwFldGet("RH4_CAMPO")) == "TMP_FUNCAO"
			oModelRH4:LoadValue("RH4_DESCAM", 'Código da função atual')
		EndIf

		If AllTrim(FwFldGet("RH4_CAMPO")) == "TMP_D_FUNC"
			oModelRH4:LoadValue("RH4_DESCAM", 'Descrição da função')
		EndIf
		
		If AllTrim(FwFldGet("RH4_CAMPO")) == "TMP_D_MOT"
			oModelRH4:LoadValue("RH4_DESCAM", 'Descrição do motivo')
		EndIf				
		
		If AllTrim(FwFldGet("RH4_CAMPO")) == "TMP_TIPO"
			If AllTrim(FwFldGet("RH4_VALNOV")) == '1'
				oModelRH4:LoadValue("DESCRICAO", 'Aumento Salarial')
			EndIf
			If AllTrim(FwFldGet("RH4_VALNOV")) == '2'
				oModelRH4:LoadValue("DESCRICAO", 'Alteração de Cargo')
			EndIf
			If AllTrim(FwFldGet("RH4_VALNOV")) == '3'
				oModelRH4:LoadValue("DESCRICAO", 'Alteração de Carga Horaria')
			EndIf
			If AllTrim(FwFldGet("RH4_VALNOV")) == '4'
				oModelRH4:LoadValue("DESCRICAO", 'Troca de Turno')
			EndIf
			If AllTrim(FwFldGet("RH4_VALNOV")) == '5'
				oModelRH4:LoadValue("DESCRICAO", 'Transferência')
			EndIf
			oModelRH4:LoadValue("RH4_DESCAM", 'Tipo de Solicitação')
		EndIf
	Next

	If oModelRH4:SeekLine({{"RH4_CAMPO", "QS_TIPO"}})
		Do Case
		CASE AllTrim(FwFldGet("RH4_VALNOV")) == '1'
			cValue := 'Int/Ext'
		CASE AllTrim(FwFldGet("RH4_VALNOV")) == '2'
			cValue := 'Interno'
		CASE AllTrim(FwFldGet("RH4_VALNOV")) == '3'
			cValue := 'Externo'
		OTHERWISE
			cValue := ''
		EndCase
		oModelRH4:LoadValue("DESCRICAO", cValue)
	EndIf
	
	If oModelRH4:SeekLine({{"RH4_CAMPO", "TMP_FILVAG"}})
		cValue  := AllTrim(FwFldGet("RH4_VALNOV"))
		If oModelRH4:SeekLine({{"RH4_CAMPO", "PA2_CDVAGA"}})
			cValue  := POSICIONE("SQS",1,cValue + AllTrim(FwFldGet("RH4_VALNOV")), "QS_DESCRIC")
			oModelRH4:LoadValue("DESCRICAO", cValue)
		EndIf
	EndIf
	
	If oModelRH4:SeekLine({{"RH4_CAMPO", "TMP_TURVAG"}})
		cValue  := Posicione("SR6", 1, XFilial("SR6") + AllTrim(FwFldGet("RH4_VALNOV")), "R6_DESC")
		oModelRH4:LoadValue("DESCRICAO", cValue)
	EndIf
Return

/*
{Protheus.doc} GetRh4Val()

@Author     FSW
@Since      26/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Param		
@Return		
*/
Static Function GetRh4Val(cField,oModel,lSegVz) //GetRh4Val(cField,oMdlAtv) //Static Function GetRh4Val(cField) Thais Paiva - 18799380
	Local _aAreaRh4 := FwGetArea() //Thais Paiva - 25597797
	Local cVal      := ""
	Local oMdlPad   := (oModel := IIF(!lSegVz,FWModelActive(),oModel))
	Local oModelRH4 := oMdlPad:GetModel("RH4DETAIL")
	Local aSaveLines:= FWSaveRows()
/*
	If oModel != Nil .or. oModel:IsActive() //Início Thais Paiva - 18799380
		oModelRH4 := oModel:GetModel("RH4DETAIL")
	Else
		oModel := oMdlAtv
		oModelRH4 := oModel:GetModel("RH4DETAIL")
	EndIf //Fim Thais Paiva - 18799380
*/	If oModelRH4 != Nil
		If oModelRH4:SeekLine({{"RH4_CAMPO", cField}})
			cVal := Alltrim(oModelRH4:GetValue("RH4_VALNOV"))
		EndIf
	EndIf 
	
	FWRestRows(aSaveLines)
	
	FwRestArea(_aAreaRh4) //Thais Paiva - 25597797
	
Return cVal

/*
{Protheus.doc} EnvMail()

@Author     FSW
@Since      26/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Param		
@Return		
*/
Static Function EnvMail(cAssunto, cDesSol, cMail, cFilSolic, cCodSolic, cTipo, cCodAlc, cMatSolic, cFilMatri, cCodMatri, cMotivo)
	Local aAreaPAB		:= PAB->(FwGetArea())
	Local aAreaSRA		:= SRA->(FwGetArea())
	PAB->(DbSetOrder(1))
	PAB->(DbSeek(xFilial("PAB") + cCodAlc))
	
	Default cMotivo := ""	
	
	SRA->(DbSetOrder(1))
	SRA->(DbSeek(cFilSolic + cMatSolic))
			
	cEmail := ";" + GetEmail(cFilSolic, cCodSolic, cFilMatri, cCodMatri,.T.)
	U_F0800901("4", cEmail, cFilSolic, cCodSolic, SRA->RA_NOME, cTipo, PAB->PAB_GRPSOL, "Efetivação", cMotivo)
	
	FwRestArea(aAreaPAB)
	FwRestArea(aAreaSRA)
Return

/*
{Protheus.doc} GetObsRh4()

@Author     FSW
@Since      26/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Param		
@Return		
*/
Static Function GetObsRh4(cFilRH3, cCodRH3)
	Local cRet 	:= ""
	Local aArea 	:= FwGetArea()
	
	DbSelectArea("RH4")
	RH4->(DbSetOrder(1))
	RH4->(DbSeek(cFilRH3 + cCodRH3 + "25"))
	cRet	:= AllTrim(RH4->RH4_XOBS)
	
	FwRestArea(aArea)
	
Return cRet


/*
{Protheus.doc} GetOutRh4()

@Author     FSW
@Since      26/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Param		
@Return		
*/
Static Function GetOutRh4(cFilRH3, cCodRH3)
	Local cRet 	:= ""
	Local aArea 	:= FwGetArea()
	
	DbSelectArea("RH4")
	RH4->(DbSetOrder(1))
	RH4->(DbSeek(cFilRH3 + cCodRH3 + "29"))
	cRet	:= AllTrim(RH4->RH4_XOBS)
	
	FwRestArea(aArea)
	
Return cRet

///////////////////////////////////////////
//Retorna o e-mail dos usuários da Alçada//
///////////////////////////////////////////
/*
{Protheus.doc} GetEmail()

@Author     FSW
@Since      26/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Param		
@Return		
*/
Static Function GetEmail(cFilSolic, cCodSolic, cFilMatri, cCodMatri, lReprov)
	Local cRet := ""
	Local aAreaPAA := PAA->(FwGetArea())
	Local aAreaPAC := PAC->(FwGetArea())
	Local aAreaSRA := SRA->(FwGetArea())

	Default cFilMatri := ""
	Default cCodMatri := ""

	If !Empty(cFilMatri)
		If SRA->(DbSeek(cFilMatri+cCodMatri))
			cRet	:= AllTrim(SRA->RA_EMAIL) + ";"
		EndIf
	EndIf
	PAA->(DbSetOrder(3))
	PAA->(DbSeek(xFilial("PAA") + cFilSolic + cCodSolic))
				
	While (PAA->(!EOF()) .AND. (PAA->(PAA_FILSOL + PAA_NUMSOL) ==  cFilSolic + cCodSolic))
		DbSelectArea("PAC")
		PAC->(DbSetOrder(1))
		If PAC->(DbSeek(xFilial("PAC") + PAA->(PAA_CODALC + PAA_NIVAPR))) .Or. (PAC->(DbSeek(xFilial("PAC") + PAA->(PAA_CODALC))) .AND. AllTrim(PAA->PAA_NIVAPR) == "FM")//Alteração do Nairan. ISso acontece qdo a solicitação só possui notificador na PAA
			If lReprov
				If PAC->PAC_NOTREJ == "1"
					DbSelectArea("SRA")
					SRA->(DbSetOrder(1))
					SRA->(DbSeek(PAA->(PAA_FILDOR + PAA_CODDOR)))
					cRet += AllTrim(SRA->RA_EMAIL) + ";"
				EndIf
			Else
				If PAC->PAC_NOTEFE == "1"
					DbSelectArea("SRA")
					SRA->(DbSetOrder(1))
					SRA->(DbSeek(PAA->(PAA_FILDOR + PAA_CODDOR)))
					cRet += AllTrim(SRA->RA_EMAIL) + ";"
				EndIf
			EndIf	
		EndIf
		PAA->(DbSkip())
	EndDo

	FwRestArea(aAreaPAA)
	FwRestArea(aAreaPAC)
	FwRestArea(aAreaSRA)
Return cRet

/*
{Protheus.doc} VldAnexo()

@Author     FSW
@Since      26/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Param		
@Return		
*/
Static Function VldAnexo()
	Local lRet := .T.
	Local cQuery	:= ""
	Local cMyAlias	:= GetNextAlias()
	Local aAreaRH4	:= RH4->(FwGetArea())
	Local aAreaRH3	:= RH3->(FwGetArea())

	If AllTrim(RH3->RH3_XTPCTM) == "005"
		If RH4->(DbSeek(RH3->(RH3_FILIAL + RH3_CODIGO) + '4'))
			
			If FDESCRCC("U005", RH4->RH4_VALNOV, 0, 2, 36, 1) = "S"		// Óbito, Pedido de Demissão, Abandono de Emprego
			
				cQuery := "SELECT P09_CODDOC "
				cQuery += "FROM " + RetSqlName("P09") + " "
				cQuery += "WHERE P09_CODORI LIKE '%" + RH3->RH3_CODIGO + "%' "
				cQuery += "AND P09_FILIAL = '" + xFilial("P09") + "' "
				cQuery += "AND P09_ROTINA LIKE '%F0500101%' "
				cQuery += "AND D_E_L_E_T_ = ' '"
			
				cQuery := ChangeQuery(cQuery)
			
				dbUseArea( .T., "TOPCONN", TCGenQry( , ,cQuery ), cMyAlias, .F., .T. )
			
				If (cMyAlias)->(Eof())
					MsgAlert("Favor inserir o anexo para prosseguir o processo de aprovação.", "Atenção")
					lRet := .F.
				EndIf
			
				(cMyAlias)->(dbCloseArea())
			
			Endif
		EndIf
	EndIf
	
	FwRestArea(aAreaRH4)
	FwRestArea(aAreaRH3)
Return lRet

/*{Protheus.doc} Motivo
(Sem descricao)
@author  Fernando Carvalho 
@since 14/11/2016
@version 12.7
@project 2015GGS0758_MAN00000060101_EF_001
*/
Static Function Motivo()
	Local oDlg
	Local lOk		
	Local cTexto1 := ""	
	
 	DEFINE DIALOG oDlg TITLE "Motivo da Alteração" FROM 180, 180 TO 420, 700 PIXEL
 		TMultiGet():new( 01, 01, {| u | if( pCount() > 0, cTexto1 := u, cTexto1 ) },oDlg, 260, 92, , , , , , .T. )
  		TButton():New( 100, 080, "OK"		,oDlg,{||oDlg:End(),lOk := .T.}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
  		//TButton():New( 100, 130, "Cancel"	,oDlg,{||oDlg:End(),lOk := .F.}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )   
  	ACTIVATE DIALOG oDlg CENTERED
return {lOk,cTexto1}

//////////////////////////////////////////////////
// Verifica se o Candidato é interno ou externo //
//////////////////////////////////////////////////
Static Function SitCand(cCic)
	Local cTempAlias	:= GetNextAlias()
	Local lRet 	:= .F.
	
	cQuery := " SELECT SRA.R_E_C_N_O_ NumRec FROM " + RetSqlName("SRA") + " SRA "
	cQuery += " WHERE "
	cQuery += " SRA.RA_CIC = '"+cCIC+"' "
	cQuery += " AND SRA.RA_SITFOLH <> 'D' "
	cQuery += " AND SRA.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTempAlias)
	
	If (cTempAlias) -> (!EOF())
		SRA->(DbGoTo((cTempAlias) -> NumRec))
		lRet := .T.
	Endif

	(cTempAlias)->(DbCloseArea())
Return lRet

Static Function VldCommit()
	
Return .T.



//----------------------------------------------------------
// Atualização quantidade do posto conforme RCX
//----------------------------------------------------------
Static Function AtlzRCL(cFilRH4,cCodRH4,cTpVaga)

	Local nQtdTotOld      := 0
	Local nQtdTotNew      := 0
	Local nQtdSubOld      := 0
	Local nQtdSubNew      := 0
	Local nNewQtdPostoOld := 0
	Local nNewQtdPostoNew := 0
	Local nNewQtdSubstOld := 0
	Local nNewQtdSubstNew := 0
	Local cQueryRH4       := ""
	Local cQueryRCL       := ""
	Local cQueryRCX       := ""
	Local cFilialOld      := ""
	Local cFilialNew      := ""
	Local cPostoOld       := ""
	Local cPostoNew       := ""
	Local lPostoOld       := .F.
	Local lSubstOld       := .F.
	Local lPostoNew       := .F.
	Local lSubstNew       := .F.
	Local cAliaRH4        := GetNextAlias()
	Local cAliaRCL        := GetNextAlias()
	Local cAliaRCX        := GetNextAlias()

	// buscando o cï¿½digo do posto (antigo e novo)
	cQueryRH4 += "SELECT RH4_CAMPO, RH4_VALNOV "
	cQueryRH4 += "  FROM " + RetSqlName("RH4") + " RH4 "
	cQueryRH4 += " WHERE RH4.D_E_L_E_T_ = ' ' "
	cQueryRH4 += "   AND RH4.RH4_FILIAL = '" + cFilRH4 + "' "
	cQueryRH4 += "   AND RH4.RH4_CODIGO = '" + cCodRH4 + "' "
	
	If AllTrim(cTpVaga) == "INTERNO" 
		cQueryRH4 += " AND RH4.RH4_CAMPO IN ('PA2_FILCAN','TMP_CODPOS','TMP_FPOSTO','TMP_POSTO')"
	Else // Outras solicitações
		cQueryRH4 += " AND RH4.RH4_CAMPO IN ('TMP_FILIAL','TMP_POSTO','RA_FILIAL','RA_POSTO')"
	Endif
	
	cQueryRH4 := ChangeQuery(cQueryRH4)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryRH4),cAliaRH4)
	
	DbSelectArea(cAliaRH4)
	While !(cAliaRH4)->(EOF())
	
		// guardando filial e cï¿½digo do posto
		If AllTrim(cTpVaga) == "INTERNO" // Tratamento para FAP interna
			If AllTrim((cAliaRH4)->RH4_CAMPO) == "PA2_FILCAN" //TMP_FILPOS alterado pois alguns registros estï¿½o em branco 
				cFilialOld := AllTrim((cAliaRH4)->RH4_VALNOV)
			ElseIf AllTrim((cAliaRH4)->RH4_CAMPO) == "TMP_CODPOS" 
				cPostoOld := AllTrim((cAliaRH4)->RH4_VALNOV)
			ElseIf AllTrim((cAliaRH4)->RH4_CAMPO) == "TMP_FPOSTO" 
				cFilialNew := AllTrim((cAliaRH4)->RH4_VALNOV)
			ElseIf AllTrim((cAliaRH4)->RH4_CAMPO) == "TMP_POSTO" 
				cPostoNew := AllTrim((cAliaRH4)->RH4_VALNOV)
			EndIf
		Else // Outras solicitações
			If AllTrim((cAliaRH4)->RH4_CAMPO) == "TMP_FILIAL" 
				cFilialOld := AllTrim((cAliaRH4)->RH4_VALNOV)
			ElseIf AllTrim((cAliaRH4)->RH4_CAMPO) == "TMP_POSTO" 
				cPostoOld := AllTrim((cAliaRH4)->RH4_VALNOV)
			ElseIf AllTrim((cAliaRH4)->RH4_CAMPO) == "RA_FILIAL" 
				cFilialNew := AllTrim((cAliaRH4)->RH4_VALNOV)
			ElseIf AllTrim((cAliaRH4)->RH4_CAMPO) == "RA_POSTO" 
				cPostoNew := AllTrim((cAliaRH4)->RH4_VALNOV)
			EndIf
		EndIf
		(cAliaRH4)->(DbSkip())
	EndDo
	(cAliaRH4)->(DbCloseArea())

	// quantidade por posto/tipo ocupante (1=substituto|2=Titular) na RCX
	cQueryRCX += "SELECT RCX.RCX_FILIAL, RCX.RCX_POSTO, COUNT(RCX.RCX_POSTO) AS QTD_POSTO, RCX.RCX_SUBST "
	cQueryRCX += "  FROM " + RetSqlName("RCX") + " RCX "
	cQueryRCX += " WHERE RCX.D_E_L_E_T_   = ' ' "
	cQueryRCX += "   AND ((RCX.RCX_FILIAL = '" + cFilialOld + "'  AND "
	cQueryRCX += "         RCX.RCX_POSTO  = '" + cPostoOld  + "') OR "  
	cQueryRCX += "        (RCX.RCX_FILIAL = '" + cFilialNew + "'  AND " 
	cQueryRCX += "         RCX.RCX_POSTO  = '" + cPostoNew  + "')) "
	cQueryRCX += " GROUP BY RCX.RCX_FILIAL, RCX.RCX_POSTO, RCX.RCX_SUBST "

	cQueryRCX := ChangeQuery(cQueryRCX)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryRCX),cAliaRCX)
	
	DbSelectArea(cAliaRCX)
	While !(cAliaRCX)->(EOF())

		// guardando quantidade total de substituto do posto
		If (cAliaRCX)->RCX_FILIAL == cFilialOld .And. (cAliaRCX)->RCX_POSTO == cPostoOld 
			nQtdTotOld += (cAliaRCX)->QTD_POSTO
			If (cAliaRCX)->RCX_SUBST == '1'
				nQtdSubOld += (cAliaRCX)->QTD_POSTO
			EndIf
		ElseIf (cAliaRCX)->RCX_FILIAL == cFilialNew .And. (cAliaRCX)->RCX_POSTO == cPostoNew 
			nQtdTotNew += (cAliaRCX)->QTD_POSTO
			If (cAliaRCX)->RCX_SUBST == '1'
				nQtdSubNew += (cAliaRCX)->QTD_POSTO
			EndIf
		EndIf
		(cAliaRCX)->(DbSkip())
	EndDo
	(cAliaRCX)->(DbCloseArea())
	
	// quantidade por posto/tipo ocupante (1=substituto|2=Titular) na RCL
	cQueryRCL += "SELECT RCL.RCL_FILIAL, RCL.RCL_POSTO, RCL_NPOSTO, RCL.RCL_OPOSTO, RCL.RCL_XSPOST, RCL.R_E_C_N_O_ AS RECNO "
	cQueryRCL += "  FROM RCL010 RCL "
	cQueryRCL += " WHERE D_E_L_E_T_       = ' ' "
	cQueryRCL += "   AND ((RCL.RCL_FILIAL = '" + cFilialOld + "'  AND "
	cQueryRCL += "         RCL.RCL_POSTO  = '" + cPostoOld  + "') OR "  
	cQueryRCL += "        (RCL.RCL_FILIAL = '" + cFilialNew + "'  AND " 
	cQueryRCL += "         RCL.RCL_POSTO  = '" + cPostoNew  + "')) "

	cQueryRCL := ChangeQuery(cQueryRCL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryRCL),cAliaRCL)
	
	DbSelectArea(cAliaRCL)
	While !(cAliaRCL)->(EOF())

		// validando totais entre RCL e RCX do posto antigo
		If (cAliaRCL)->RCL_FILIAL == cFilialOld .And. (cAliaRCL)->RCL_POSTO == cPostoOld
			If (cAliaRCL)->RCL_OPOSTO != nQtdTotOld
				lPostoOld := .T.
				nNewQtdPostoOld := nQtdTotOld
			Else
				nNewQtdPostoOld := (cAliaRCL)->RCL_OPOSTO
			EndIf
			
			// Tratamento para ajustar a quantidade de sustituto em relaï¿½ï¿½o a qtd. mï¿½xima do posto 
			If (cAliaRCL)->RCL_NPOSTO >= nNewQtdPostoOld 
				lSubstOld := .T.
				nNewQtdSubstOld := 0
				AtlzRCX(cFilialOld,cPostoOld) // Atualizando status de substituto na RCX
			Else
				If (cAliaRCL)->RCL_XSPOST != nQtdSubOld
					lSubstOld := .T.
					nNewQtdSubstOld := nQtdSubOld
				Else 
					nNewQtdSubstOld := (cAliaRCL)->RCL_XSPOST
				EndIf
			EndIf
			
			// Atualizando posto antigo na RCL
			If lPostoOld .Or. lSubstOld
				DbSelectArea("RCL")
				RCL->(DbGoTo((cAliaRCL)->RECNO))
				RecLock("RCL",.F.)
					RCL->RCL_OPOSTO := nNewQtdPostoOld
					RCL->RCL_XSPOST := nNewQtdSubstOld
				RCL->(MsUnLock())
				RCL->(DbCloseArea())
			EndIf
		EndIf

		// validando totais entre RCL e RCX do posto novo
		If (cAliaRCL)->RCL_FILIAL == cFilialNew .And. (cAliaRCL)->RCL_POSTO == cPostoNew
			If (cAliaRCL)->RCL_OPOSTO != nQtdTotNew
				lPostoNew := .T.
				nNewQtdPostoNew := nQtdTotNew
			Else
				nNewQtdPostoNew := (cAliaRCL)->RCL_OPOSTO
			EndIf
			
			// Tratamento para ajustar a quantidade de sustituto em relaï¿½ï¿½o a qtd. mï¿½xima do posto 
			If (cAliaRCL)->RCL_NPOSTO >= nNewQtdPostoNew 
				lSubstNew := .T.
				nNewQtdSubstNew := 0
				AtlzRCX(cFilialNew,cPostoNew) // Atualizando status de substituto na RCX
			Else
				If (cAliaRCL)->RCL_XSPOST != nQtdSubNew
					lSubstNew := .T.
					nNewQtdSubstNew := nQtdSubNew
				Else
					nNewQtdSubstNew := (cAliaRCL)->RCL_XSPOST
				EndIf
			EndIf
			
			// Atualizando posto novo na RCL
			If lPostoNew .Or. lSubstNew
				DbSelectArea("RCL")
				RCL->(DbGoTo((cAliaRCL)->RECNO))
				RecLock("RCL",.F.)
					RCL->RCL_OPOSTO := nNewQtdPostoNew
					RCL->RCL_XSPOST := nNewQtdSubstNew
				RCL->(MsUnLock())
				RCL->(DbCloseArea())
			EndIf
			
		EndIf
		(cAliaRCL)->(DbSkip())
	EndDo
	(cAliaRCL)->(DbCloseArea())

	   
    // Limpando variáveis
	nQtdTotOld      := 0
	nQtdTotNew      := 0
	nQtdSubOld      := 0
	nQtdSubNew      := 0
	nNewQtdPostoOld := 0
	nNewQtdPostoNew := 0
	nNewQtdSubstOld := 0
	nNewQtdSubstNew := 0
	cQueryRH4       := ""
	cQueryRCL       := ""
	cQueryRCX       := ""
	cFilialOld      := ""
	cFilialNew      := ""
	cPostoOld       := ""
	cPostoNew       := ""
	lPostoOld       := .F.
	lSubstOld       := .F.
	lPostoNew       := .F.
	lSubstNew       := .F.

Return


//----------------------------------------------------------
// Limpa os substitutos quando qtd máx na RCL não é atingida
//----------------------------------------------------------
Static Function AtlzRCX(cFilialRCX,cPostoRCX)

	Local cRcxQry   := ""
	Local cRcxAlias := GetNextAlias()

	cRcxQry += "SELECT RCX.R_E_C_N_O_ AS RECNO "
	cRcxQry += "  FROM " + RetSqlName("RCX") + " RCX "
	cRcxQry += " WHERE RCX.D_E_L_E_T_ = ' ' "
	cRcxQry += "   AND RCX.RCX_FILIAL = '" + cFilialRCX + "' "
	cRcxQry += "   AND RCX.RCX_POSTO  = '" + cPostoRCX  + "' "
	cRcxQry += "   AND RCX.RCX_SUBST  = '1' "   

	cRcxQry := ChangeQuery(cRcxQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cRcxQry),cRcxAlias)
	
	DbSelectArea(cRcxAlias)
	While !(cRcxAlias)->(EOF())
	
		DbSelectArea("RCX")
		RCX->(DbGoTo((cRcxAlias)->RECNO))
		RecLock("RCX",.F.)
			RCX->RCX_SUBST := '2'
		RCX->(MsUnLock())
		RCX->(DbCloseArea())

		(cRcxAlias)->(DbSkip())
	EndDo
	(cRcxAlias)->(DbCloseArea())
Return


//----------------------------------------------------------
// Atualiza qtd total/substituto depois do desligamento
//----------------------------------------------------------
Static Function AtlzDesl(cFilialDes,cPostDes)

	Local cDesQry    := ""
	Local nQtdSubDes := 0
	Local nQtdTotDes := 0
	Local cDesAlias  := GetNextAlias()

	cDesQry += "SELECT RCX.RCX_POSTO, COUNT(RCX.RCX_POSTO) AS QTD_POSTO, RCX.RCX_SUBST "
	cDesQry += "  FROM RCX010 RCX "
	cDesQry += " WHERE D_E_L_E_T_ = ' ' "
	cDesQry += "   AND RCX.RCX_FILIAL = '" + cFilialDes + "' " 
	cDesQry += "   AND RCX.RCX_POSTO  = '" + cPostDes + "' "
	cDesQry += " GROUP BY RCX.RCX_POSTO, RCX.RCX_SUBST "

	cDesQry := ChangeQuery(cDesQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cDesQry),cDesAlias)
	
	DbSelectArea(cDesAlias)
	While !(cDesAlias)->(EOF())
		
		// guardando quantidade total do posto
		nQtdTotDes += (cDesAlias)->QTD_POSTO
		
		If (cDesAlias)->RCX_SUBST == '1'
			nQtdSubDes += (cDesAlias)->QTD_POSTO
		EndIf

		(cDesAlias)->(DbSkip())
	EndDo
	(cDesAlias)->(DbCloseArea())

	DbSelectArea("RCL")
	RCL->(DbSetOrder(RetOrder("RCL", "RCL_FILIAL + RCL_POSTO")))
	If RCL->(DbSeek(cFilialDes + cPostDes))
		RecLock("RCL",.F.)
			RCL->RCL_OPOSTO := nQtdTotDes
			RCL->RCL_XSPOST := nQtdSubDes 
		RCL->(MsUnLock())
		RCL->(DbCloseArea())
	EndIf
	RCL->(DbCloseArea())

Return

//Início - Thais Paiva - 9582494
//----------------------------------------------------------
// Verifica se o Posto está cancelado
//----------------------------------------------------------
Static Function CancPosto(nTipo,cFilPost,cDepto,cPosto,cFilSolic,cCodSolic)
Local _aAreaCL := FwGetArea()
Local lCancel := .F.
Local lContinua := .F.

If nTipo == 2
	
	dbSelectArea("RH4")
	RH4->(dbSetORder(1))
	If RH4->(DbSeek(cFilSolic + cCodSolic))
		While cFilSolic == RH4->RH4_FILIAL .AND. cCodSolic == RH4->RH4_CODIGO
			
			If ALLTRIM(RH4->RH4_CAMPO) == 'TMP_TIPO' .AND. Alltrim(RH4->RH4_VALNOV) == '5'
				lContinua := .T.
			EndIf
			
			If ALLTRIM(RH4->RH4_CAMPO) == 'RA_FILIAL'
				cFilPost := Alltrim(RH4->RH4_VALNOV)
			EndIf
			
			If ALLTRIM(RH4->RH4_CAMPO) == 'RA_DEPTO'
				cDepto := Alltrim(RH4->RH4_VALNOV)
			EndIf
			
			If ALLTRIM(RH4->RH4_CAMPO) == 'RA_POSTO'
				cPosto := Alltrim(RH4->RH4_VALNOV)
			EndIf
			
			RH4->(dbSkip())
		EndDo
	EndIf

Else

	lContinua := .T.
	
EndIf

If lContinua
	DbSelectArea("RCL")
	RCL->(DbSetOrder(1)) //RCL_FILIAL + RCL_DEPTO + RCL_POSTO
	If RCL->(DbSeek(cFilPost + cDepto + cPosto))
		If RCL->RCL_STATUS == "4"
			lCancel := .T.
		EndIf
	EndIf
EndIf

FwRestArea(_aAreaCL)

Return lCancel
//Fim - Thais Paiva - 9582494

//Início - Thais Paiva - 18799380
//----------------------------------------------------------
// Busca código do posto
//----------------------------------------------------------
Static Function GetNPosto(cFilPost)
Local cFilBkp := cFilAnt
Local cNumPost := ""
Local _aAreaCL := FwGetArea()

If Alltrim(cFilAnt) <> Alltrim(cFilPost)
	cFilAnt := cFilPost
Endif
cNumPost := GetSXENum('RCL','RCL_POSTO')

RCL->(DbSetOrder(2)) //RCL_FILIAL+RCL_POSTO
While RCL->(DbSeek(FWXFilial('RCL')+cNumPost))
	ConfirmSX8()
	cNumPost := GetSXENum('RCL','RCL_POSTO')
EndDo

ConfirmSX8()

If Alltrim(cFilAnt) <> Alltrim(cFilBkp)
	cFilAnt := cFilBkp
Endif

FwRestArea(_aAreaCL)

Return cNumPost
//Fim - Thais Paiva - 18799380
