#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

/*
{Protheus.doc} F0200303()
Solicitação de Incentivo Acadêmico
@Author     Henrique Madureira
@Since      25/04/2016
@Version    P12.1.07
@Project    MAN00000463301_EF_003
@Menu		SIGATRM - Treinamento
@Param
@Return
*/
User Function F0200303()
	
	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('PA3')
	oBrowse:SetDescription('Solicitação de Incentivo Academico')
	oBrowse:AddLegend( "PA3_XSTATU == '1'", "GREEN", "Aprovado"  )
	oBrowse:AddLegend( "PA3_XSTATU == '2'", "RED", "Reprovado"  )
	oBrowse:AddLegend( "PA3_XSTATU == '3'", "YELLOW", "Aguardando Aprovação"  )
	oBrowse:Activate()
	
Return

/*
{Protheus.doc} MenuDef()
Criação do Menu de Incentivo Acadêmico
@Author     Henrique Madureira
@Since      25/04/2016
@Version    P12.1.07
@Project    MAN00000463301_EF_003
@Param
@Return		aRotina, Opção de Menu
*/
Static Function MenuDef()
	
	Local aRotina := {}
	
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
	AAdd(aRotina,{"&Incluir"	, "VIEWDEF.F0200303"    , 0, 3 } )
	AAdd(aRotina,{"&Visualizar"	, "VIEWDEF.F0200303"    , 0, 2 } )

	// ADD OPTION aRotina TITLE '&Incluir'    ACTION 'VIEWDEF.F0200303' OPERATION 3 ACCESS 0
	// ADD OPTION aRotina TITLE '&Visualizar' ACTION 'VIEWDEF.F0200303' OPERATION 2 ACCESS 0

Return aRotina

/*
{Protheus.doc} ModelDef()
Modelo de Dados do Incentivo Acadêmico
@Author     Henrique Madureira
@Since      25/04/2016
@Version    P12.1.07
@Project    MAN00000463301_EF_003
@Param
@Return		oModel, Modelo de Dados
*/
Static Function ModelDef()
	
	Local oStruPA3 := FWFormStruct( 1, 'PA3', /*bAvalCampo*/,.F. )
	Local oModel
	
	oStruPA3:SetProperty("PA3_XTERMI",MODEL_FIELD_VALID,{|oModel| FsVldDtFim(oModel)})
	oStruPA3:SetProperty("PA3_XSOLIC",MODEL_FIELD_INIT,{|oModel| FsBscSolic(oModel,"PA3_XSOLIC")})
	oStruPA3:SetProperty("PA3_RSPAPR",MODEL_FIELD_INIT,{|oModel| FsBscSolic(oModel,"PA3_RSPAPR")})
	oStruPA3:SetProperty("PA3_XNMSOL",MODEL_FIELD_INIT,{|oModel| FsBscSolic(oModel,"PA3_XNMSOL")})
	
	oModel := MPFormModel():New('F02003', , {|oModel|GrvSoliIn(oModel)}, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields( 'PA3MASTER', /*cOwner*/, oStruPA3, , /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetDescription( 'Solicitação de Incentivo Academico' )
	oModel:SetPrimaryKey({""})
	oModel:GetModel( 'PA3MASTER' ):SetDescription( 'Incentivo Academico' )
	
	oModel:SetVldActivate( { |oModel| FsVldAct( oModel ) } )
	
Return oModel

/*
{Protheus.doc} ViewDef()
Interface do Incentivo Acadêmico
@Author     Henrique Madureira
@Since      25/04/2016
@Version    P12.1.07
@Project    MAN00000463301_EF_003
@Param
@Return		oView, interface
*/
Static Function ViewDef()
	
	Local oModel   := FWLoadModel( 'F0200303' )
	Local oStruPA3 := FWFormStruct( 2, 'PA3' )
	Local oView
	
	oStruPA3:RemoveField("PA3_RSPAPR")
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_PA3', oStruPA3, 'PA3MASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_PA3', 'TELA' )
	
Return oView

/*
{Protheus.doc} ValStatu()
Validação do Status do Incentivo Acadêmico
@Author     Henrique Madureira
@Since      25/04/2016
@Version    P12.1.07
@Project    MAN00000463301_EF_003
@Param		oModel, objeto, modelo de dados
@Return		lRet, permite alteração do campo ou não
*/
Static Function ValStatu(oModel)
	
	Local oModel1     := oModel:GetModel()
	Local nOperation  := oModel:GetOperation()
	Local cStatus     := oModel1:GetValue( 'PA3MASTER', "PA3_XSTATU" )
	Local oStruPA3    := FWFormStruct( 1, 'PA3', /*bAvalCampo*/,.F. )
	Local lRet        := .T.
	
	If nOperation == MODEL_OPERATION_UPDATE .AND. cStatus == "1"
		oStruPA3:SetProperty( '*' , MODEL_FIELD_WHEN,'INCLUI')
		Help( ,, 'HELP',, "Não é possível alteração, pois a solicitação já foi aprovada!", 1, 0)
		lRet := .F.
	EndIf
	
	If nOperation == MODEL_OPERATION_UPDATE .AND. cStatus == "2"
		oStruPA3:SetProperty( '*' , MODEL_FIELD_WHEN,'INCLUI')
		Help( ,, 'HELP',, "Não é possível alteração, pois a solicitação já foi reprovada!", 1, 0)
		lRet := .F.
	EndIf
	
Return lRet

/*
{Protheus.doc} FsVldDtFim()
Validação da data final do curso
@Author     Bruno de Oliveira
@Since      11/08/2016
@Version    P12.1.07
@Project    MAN00000463301_EF_003
@Param		oModel, objeto, modelo de dados
@Return		lRet, permite informar data válida ou não
*/
Static Function FsVldDtFim(oModel)
	
	Local aArea  := GetArea()
	Local dDtIni := oModel:GetValue("PA3_XINICI")
	Local dDtFim := oModel:GetValue("PA3_XTERMI")
	Local lRet   := .F.

	If !Empty(dDtIni)
		If DTOS(dDtFim) >= DTOS(dDtIni) .And. DTOS(dDtFim) >= DTOS(dDatabase)
			lRet := .T.
		EndIf
	Else
		Help(,,'FsVldDtFim',,"Necessário informar a data de inicio do curso primeiro",1,0)
		lRet := .F.
	EndIf

	RestArea(aArea)
	
Return lRet

/*
{Protheus.doc} FsBscSolic()
Busca solicitantes e responsaveis pela aprovação
@Author     Bruno de Oliveira
@Since      11/08/2016
@Version    P12.1.07
@Project    MAN00000463301_EF_003
@Param		oModel, objeto, modelo de dados
@Return		cRet, retorna o conteudo do campo
*/
Static Function FsBscSolic(oModel,cCampo)
	
	Local nOper  := oModel:GetOperation()
	Local cSolic := ""
	Local cRet   := ""
	
	If nOper == MODEL_OPERATION_INSERT
		
		PswOrder(2)
		If PswSeek(CUSERNAME)
			If cCampo == "PA3_XSOLIC"
				cRet := SubStr(PswRet()[1][22],11)
			ElseIf cCampo == "PA3_RSPAPR"
				cRet := SubStr(PswRet()[1][22],11)
			EndIf
		EndIf
		
	EndIf
	
	If cCampo == "PA3_XNMSOL"
		cSolic := oModel:GetValue("PA3_XSOLIC")
		cRet   := Posicione("SRA",1,xFilial("SRA") + cSolic,"RA_NOME")
	EndIf
	
Return cRet

/*
{Protheus.doc} FsVldAct()
Validação antes de abrir a tela de incetivo acadêmico
@Author     Bruno de Oliveira
@Since      12/08/2016
@Version    P12.1.07
@Project    MAN00000463301_EF_003
@Param		oModel, objeto, modelo de dados
@Return		lRet, permite ativação da tela ou não.
*/
Static Function FsVldAct(oModel)
	
	Local aArea    := GetArea()
	Local cOper    := oModel:GetOperation()
	Local cSolic   := PA3->PA3_XSOLIC
	Local cResp    := PA3->PA3_RSPAPR
	Local cStatus  := PA3->PA3_XSTATU
	Local lRet     := .T.
	
	If cOper == MODEL_OPERATION_UPDATE
		If cSolic <> cResp
			Help(,,'FsVldAct',,"Alteração não permitida! Processo de solicitação está em andamento.",1,0)
			lRet := .F.
		EndIf
	EndIf
	
	If cOper == MODEL_OPERATION_UPDATE .AND. cStatus == "1"
		Help( ,, 'HELP',, "Não é possível alteração, pois a solicitação já foi aprovada!", 1, 0)
		lRet := .F.
	EndIf
	
	If cOper == MODEL_OPERATION_UPDATE .AND. cStatus == "2"
		Help( ,, 'HELP',, "Não é possível alteração, pois a solicitação já foi reprovada!", 1, 0)
		lRet := .F.
	EndIf
	
	RestArea(aArea)
	
Return lRet

Static Function GrvSoliIn(oModel)
	
	Local aAreas  := {RH4->(GetArea()),RH3->(GetArea()),GetArea()}
	Local oMdlPA3 := oModel:GetModel("PA3MASTER")
	Local cFilMat := oMdlPa3:GetValue("PAB_FILIAL")
	Local cMatric := oMdlPA3:GetValue("PAB_XMATRI")
	Local nCount  := 0
	Local nItem   := 0
	Local lRet    := .F.
	Local aRetSup := {}
	Local cNotif  := ""
	
	PswOrder(1)
	If (PswSeek(__cUserId,.T.))
		aDdSolic := PswRet()
		
		///cMatSoli  := Substring(aDdSolic[1][22],len(cEmpAnt) + len(cFilAnt) + 1,12)
		cMatSoli := SubString(aDdSolic[1][22], (Len(aDdSolic[1,22])-6) + 1 , 12)
		cFilSoli  := Substring(aDdSolic[1][22],len(cEmpAnt) + 1,len(cFilAnt))
		
		If Empty(cFilSoli) .AND. Empty(cMatSoli)
			Help( ,, 'HELP',, 'Erro no Vínculo entre o Solicitante e o cadastro de Funcionários.', 1, 0)
			lRet := .F.
		Else
			lRet := .T.
			aRetSup := U_F0800501("1",,,"007","001",cFilSoli,cMatSoli,cFilMat,cMatric) //Busca aprovador			
		EndIf

	EndIf
	
	If lRet 
		If aRetSup[1][1]
		
			cNotif := Posicione("PAC",1,xFilial("PAC") + aRetSup[1][6] + aRetSup[1][4],"PAC_APRNOT")
			
			If (aRetSup[1][5] == "FM" .And. cNotif == "2") .Or. (aRetSup[1][5] == "FM" .And. ("aprova direto" $ aRetSup[1][8] .OR. "Terminou a estrutura da visão!" $ aRetSup[1][8] )) 
				cXStatus := "4"
			Else
				cXStatus := "1"
			EndIf
			
			cFilApr := aRetSup[1][2]
			cMatApr := aRetSup[1][3]
			cNvlApr := aRetSup[1][4]
			cCodAlc := aRetSup[1][6]
			cPrxNvl := aRetSup[1][5]
			
			aRegs := {;
				{"PA3_FILIAL",M->PA3_FILIAL},;
				{"PA3_XCOD  ",M->PA3_XCOD  },;
				{"PA3_XMATRI",M->PA3_XMATRI},;
				{"PA3_XSETOR",M->PA3_XSETOR},;
				{"PA3_XCENTR",M->PA3_XCENTR},;
				{"PA3_XUNIDA",M->PA3_XUNIDA},;
				{"PA3_XCARGO",M->PA3_XCARGO},;
				{"PA3_XEMAIL",M->PA3_XEMAIL},;
				{"PA3_XTELEF",M->PA3_XTELEF},;
				{"PA3_XRAMAL",M->PA3_XRAMAL},;
				{"PA3_XTIPO ",M->PA3_XTIPO },;
				{"PA3_XINSTI",M->PA3_XINSTI},;
				{"PA3_XCURS ",M->PA3_XCURS },;
				{"PA3_XINICI",DTOS(M->PA3_XINICI)},;
				{"PA3_XTERMI",DTOS(M->PA3_XTERMI)},;
				{"PA3_XDURAC",CVALTOCHAR(M->PA3_XDURAC)},;
				{"PA3_XMENSL",CVALTOCHAR(M->PA3_XMENSL)},;
				{"PA3_XVLTAL",CVALTOCHAR(M->PA3_XVLTAL)},;
				{"PA3_XVLTCU",CVALTOCHAR(M->PA3_XVLTCU)},;
				{"PA3_XPCBEN",CVALTOCHAR(M->PA3_XPCBEN)},;
				{"PA3_XSOLIC",M->PA3_XSOLIC},;
				{"PA3_RSPAPR",aRetSup[1][2]},;
				{"PA3_XOBSER",M->PA3_XOBSER},;
				{"PA3_XSTATU",M->PA3_XSTATU};
				}
				
			cRH4Fil := U_F1302201({M->PA3_FILIAL,"",""}, .T.)

			RH3->(DbSetOrder(1))
			If ! RH3->(DbSeek(xFilial("RH3") + cRH4Fil))
				Reclock("RH3", .T.)
				RH3->RH3_FILIAL  := FWxFilial("RH3")
				RH3->RH3_CODIGO  := cRH4Fil
				RH3->RH3_MAT     := M->PA3_XMATRI
				RH3->RH3_TIPO    := " "
				RH3->RH3_ORIGEM  := "PORTAL"
				RH3->RH3_STATUS  := cXStatus
				RH3->RH3_DTSOLI  := DATE()
				RH3->RH3_NVLINI  := 0
				RH3->RH3_FILINI  := cFilSoli
				RH3->RH3_MATINI  := cMatSoli
				RH3->RH3_FILAPR  := cFilApr
				RH3->RH3_MATAPR  := cMatApr
				RH3->RH3_NVLAPR  := VAL(cNvlApr)
				RH3->RH3_KEYINI  := "002"
				RH3->RH3_FLUIG   := 0
				RH3->RH3_EMP     := "01"
				RH3->RH3_EMPINI  := "01"
				RH3->RH3_EMPAPR  := "01"
				RH3->RH3_XTPCTM  := "007"
				RH3->RH3_XCODAL  := cCodAlc			
				RH3->RH3_XPRXNV  := cPrxNvl
				RH3->(MsUnlock())
				
				U_F0801201(RH3->RH3_FILAPR, RH3->RH3_MATAPR, RH3->RH3_FILIAL, RH3->RH3_CODIGO, RH3->RH3_NVLAPR, RH3->RH3_XCODAL)
				
				If LEN(GETFUNCARRAY('U_F0500201')) > 0
					U_F0500201(cFilSoli,cRH4Fil,"001")
				EndIf
			EndIf
				
			RH4->(DbSetOrder(1))
			If ! RH4->(DbSeek(xFilial("RH4") + cRH4Fil))
				For nCount:= 1 To Len(aRegs)
					Reclock("RH4", .T.)
					RH4->RH4_FILIAL	:= FWxFilial("RH4")
					RH4->RH4_CODIGO	:= cRH4Fil
					RH4->RH4_ITEM	:=++ nItem
					RH4->RH4_CAMPO	:= aRegs[nCount, 1]
					RH4->RH4_VALNOV	:= IIF(EMPTY(aRegs[nCount, 2]),'',aRegs[nCount, 2])
					RH4->RH4_XOBS  	:= ""
					RH4->(MsUnlock())
				Next
			EndIf
			If (__lSX8)
				ConfirmSx8()
				lRet := .T.
			EndIf
			cNome := POSICIONE("SRA",1,cFilSoli + cMatSoli,"RA_NOME")
			U_F0200302(4,cMatApr,cNome,'','','',cFilApr)
		Else
			MsgAlert(aRetSup[1][8])
		EndIf		
	EndIf
	AEval(aAreas, {|x| RestArea(x)} )
	
Return lRet
