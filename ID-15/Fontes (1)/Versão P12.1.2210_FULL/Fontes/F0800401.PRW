#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

/*
{Protheus.doc} F0800401()
Cadastro do Controle de Alçada
@Author     Bruno de Oliveira
@Since      07/03/2017
@Version    P12.1.07
@Project    MAN0000007423042_EF_004
*/
User Function F0800401()
	
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("PAB")
	oMBrowse:SetDescription("Cadastro de Alçadas")
	oMBrowse:SetCacheView( .F. )
	oMBrowse:DisableReport()
	oMBrowse:DisableDetails()
	oMBrowse:Activate()
	
Return

/*
{Protheus.doc} MenuDef()
Menu do controle de Alçada
@Author     Bruno de Oliveira
@Since      07/03/2017
@Version    P12.1.07
@Project    MAN0000007423042_EF_004
*/
Static Function MenuDef()
	
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE "Visualizar"    ACTION "VIEWDEF.F0800401" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"       ACTION "VIEWDEF.F0800401" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"	     ACTION "VIEWDEF.F0800401" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"	     ACTION "VIEWDEF.F0800401" OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Copiar Alçada" ACTION "VIEWDEF.F0800401" OPERATION 9 ACCESS 0
	ADD OPTION aRotina TITLE "Automatico"    ACTION "U_F0800404()"     OPERATION 4 ACCESS 0
	
Return aRotina

/*
{Protheus.doc} ModelDef()
Modelo de dados do cadastro de alçada
@Author     Bruno de Oliveira
@Since      07/03/2017
@Version    P12.1.07
@Project    MAN0000007423042_EF_004
@Return		oModel, Modelo de dados
*/
Static Function ModelDef()
	
	Local oModel
	Local oStrPAB := FwFormStruct(1,"PAB")
	Local oStrPAC := FWFormStruct(1,"PAC")
	Local bPosMd  := {|| FsVldMdl()}
	
	aAux := FwStruTrigger ( 'PAB_TPSOLI', 'PAB_SOLDES', 'Posicione("PA7",1,xFilial("PA7") + M->PAB_TPSOLI,"PA7_DESCR")' , .F. )
	oStrPAB:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])
	
	aAux := FwStruTrigger ( 'PAB_TPSOLI', 'PAB_GRPSOL', '' , .F. )
	oStrPAB:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])
	
	aAux := FwStruTrigger ( 'PAB_TPSOLI', 'PAB_GRPDES', '' , .F. )
	oStrPAB:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])
	
	aAux := FwStruTrigger ( 'PAB_GRPSOL', 'PAB_GRPDES', 'Posicione("PA7",1,xFilial("PA7") + M->PAB_TPSOLI + M->PAB_GRPSOL,"PA7_DESSUB")' , .F. )
	oStrPAB:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])
	
	aAux := FwStruTrigger ( 'PAB_VISAO', 'PAB_DESVIS', 'Posicione("RDK",1,xFilial("RDK") + M->PAB_VISAO,"RDK_DESC")' , .F. )
	oStrPAB:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])
	
	aAux := FwStruTrigger ( 'PAC_CODPOS', 'PAC_DESPOS', 'Posicione("PAD",1,xFilial("PAD") + M->PAC_CODPOS,"PAD_DESCRI")' , .F. )
	oStrPAC:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])
	
	aAux := FwStruTrigger ( 'PAC_TIPAPR', 'PAC_NUMNIV', '' , .F. )
	oStrPAC:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])
	
	aAux := FwStruTrigger ( 'PAC_TIPAPR', 'PAC_CODPOS', '' , .F. )
	oStrPAC:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])
	
	aAux := FwStruTrigger ( 'PAC_TIPAPR', 'PAC_DESPOS', '' , .F. )
	oStrPAC:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])

	aAux := FwStruTrigger ( 'PAC_CODLG', 'PAC_DESLG', 'Posicione("PAI",1,xFilial("PAI") + FwFldGet("PAC_CODLG"),"PAI_DESCR")' , .F. )
	oStrPAC:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])
	
	oModel := MPFormModel():New("M08004",  /*bPreMd*/ , bPosMd , /*bCommitMd*/, /*bCancel*/ )
	oModel:SetDescription("Cadastro de Alçada")
	
	oStrPAB:SetProperty('PAB_TPSOLI',MODEL_FIELD_VALID, {|| FsVldCdAl("PAB_TPSOLI") })
	oStrPAB:SetProperty('PAB_GRPSOL',MODEL_FIELD_VALID, {|| FsVldCdAl("PAB_GRPSOL")})
	oStrPAB:SetProperty('PAB_VISAO',MODEL_FIELD_VALID, {|| FsVldCdAl("PAB_VISAO")})
	oStrPAC:SetProperty('PAC_CODPOS',MODEL_FIELD_VALID, {|| FsVldCdAl("PAC_CODPOS")})
	oStrPAC:SetProperty('PAC_CODLG',MODEL_FIELD_VALID, {|| FsVldCdAl("PAC_CODLG")})
		
	oStrPAB:SetProperty('PAB_TPSOLI' , MODEL_FIELD_WHEN, {|oModel| oModel:GetOperation() == MODEL_OPERATION_INSERT })
	oStrPAB:SetProperty('PAB_GRPSOL' , MODEL_FIELD_WHEN, {|oModel| oModel:GetOperation() == MODEL_OPERATION_INSERT .AND. !Empty(M->PAB_TPSOLI) })
	
	oStrPAB:SetProperty('PAB_VISAO'  , MODEL_FIELD_WHEN, {|| FsVldPrMdl() })
	oStrPAB:SetProperty('PAB_NIVMIN' , MODEL_FIELD_WHEN, {|| FsVldPrMdl() })
	oStrPAB:SetProperty('PAB_TPSOL'  , MODEL_FIELD_WHEN, {|| FsVldPrMdl() })
	oStrPAB:SetProperty('PAB_LIMNIV' , MODEL_FIELD_WHEN, {|| FsVldPrMdl() })
	oStrPAB:SetProperty('PAB_APRMAX' , MODEL_FIELD_WHEN, {|| FsVldPrMdl() })
	oStrPAB:SetProperty('PAB_NECAPV' , MODEL_FIELD_WHEN, {|| FsVldPrMdl() })
	
	oStrPAC:SetProperty('PAC_NUMNIV' , MODEL_FIELD_WHEN, {|| oModel:GetModel("PACDETAIL"):GetValue("PAC_TIPAPR") == "1" })
	oStrPAC:SetProperty('PAC_CODPOS' , MODEL_FIELD_WHEN, {|| oModel:GetModel("PACDETAIL"):GetValue("PAC_TIPAPR") == "2"  })
	
	oStrPAC:SetProperty('PAC_VINCL' , MODEL_FIELD_WHEN, {|| oModel:GetModel("PACDETAIL"):GetValue("PAC_TIPAPR") == "2"  })
	oStrPAC:SetProperty('PAC_CODLG' , MODEL_FIELD_WHEN, {|| oModel:GetModel("PACDETAIL"):GetValue("PAC_TIPAPR") == "2"  })
	oStrPAC:SetProperty('PAC_CODLG' , MODEL_FIELD_WHEN, {|| oModel:GetModel("PACDETAIL"):GetValue("PAC_VINCL") == "1"   })
	
	oModel:AddFields("PABMASTER", /*cOwner*/, oStrPAB)
	
	oModel:AddGrid("PACDETAIL","PABMASTER",oStrPAC, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	
	oModel:SetPrimaryKey({"PAB_CODIGO"})
	
	oModel:GetModel("PACDETAIL"):SetUniqueLine({"PAC_NIVEL"})
	
	oModel:SetRelation("PACDETAIL",{{"PAC_FILIAL","xFilial('PAC')"},{"PAC_CODALC", "PAB_CODIGO"}})
	
	oModel:SetDescription("Cadastro Alçada")
	
Return oModel

/*
{Protheus.doc} ViewDef()
Interface do cadastro de alçada
@Author     Bruno de Oliveira
@Since      07/03/2017
@Version    P12.1.07
@Project    MAN0000007423042_EF_004
@Param		oView, interface
*/
Static Function ViewDef()
	
	Local oModel := FWLoadModel("F0800401")
	Local oStrPAB := FWFormStruct(2,"PAB")
	Local oStrPAC := FWFormStruct(2,"PAC")
	Local oView	:= FWFormView():New()
	
	oStrPAC:RemoveField("PAC_CODALC")
	
	oView:SetModel(oModel)
	oView:AddField("VIEW_PAB", oStrPAB, 'PABMASTER')
	
	oView:AddGrid("VIEW_PAC", oStrPAC,"PACDETAIL")
	oView:AddIncrementField( 'VIEW_PAC', 'PAC_NIVEL' )
	oView:CreateHorizontalBox("TOP", 50)
	oView:CreateHorizontalBox("BOTTOM", 50)
	
	oView:SetOwnerView("VIEW_PAB", "TOP")
	oView:SetOwnerView("VIEW_PAC", "BOTTOM")
	
Return oView

/*
{Protheus.doc} F0800402()
Consulta Especifica dos tipos de solicitação
@Author     Bruno de Oliveira
@Since      08/03/2017
@Version    P12.1.07
@Project    MAN0000007423042_EF_004
@Param		
*/
User Function F0800402()
	
	Local aArea 	:= GetArea()
	Local oMdl  	:= FwModelActivate()
	Local oMdlPAB 
	Local aTpSolic 	:= {}
	Local lRet 		:= .F. 
	Local oDlg

	              
	Local oList := Nil
	Static aRet 		:= {}	
	
	If oMdl <> NIL
		oMdlPAB := oMdl:GetModel("PABMASTER")
	EndIF
	DbSelectArea("PA7")
	PA7->(DbGotop())
	While PA7->(!EOF())
		
		nPos := AScan(aTpSolic,{|x| x[1] == PA7->PA7_CODIGO})
		If nPos == 0
			AAdd(aTpSolic,{PA7->PA7_CODIGO,PA7->PA7_DESCR})
		EndIf
		
		PA7->(DbSkip())
	End
	
	If Len(aTpSolic) > 0
	
		Define MsDialog oDlg Title "Tipos de Solicitação" From 0,0 To 260, 435 Of oMainWnd Pixel
		
		@ 5,5 LISTBOX oList VAR lVar Fields HEADER "Tipo", "Descrição" SIZE 200,100 OF oDlg PIXEL
		
		oList:SetArray( aTpSolic )
		oList:bLine := {|| { aTpSolic[oList:nAt,1], aTpSolic[oList:nAt,2]} }
		oList:bLDblClick := {|| {oDlg:End(), aRet := {oList:aArray[oList:nAt,1]}}}
		
		DEFINE SBUTTON FROM 112,005 TYPE 1 ACTION (oDlg:End(), aRet := {oList:aArray[oList:nAt,1]}) ENABLE OF oDlg
		DEFINE SBUTTON FROM 112,040 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
		
		Activate MSDialog oDlg Centered
	
	Else
	
		MsgAlert("Não existem registros na tabela de tipos de solicitação")
	
	EndIf
	
	//If Len(aRet) > 0
	If Len(aRet) > 0 .AND. INCLUI //Thais Paiva - 14047271
		lRet := .T.                
		IF oMdl <> NIL
			oMdlPAB:SetValue("PAB_TPSOLI", aRet[1] )
		EndIF
		aTpSolic := {}
	EndIf                            
    
	DbSelectArea("PA7")
	PA7->(DbGotop())    
	DbSetOrder(1)
	DbSeek(xFilial("PA7")+AllTrim(aRet[1]))  
		
	RestArea(aArea)
	
Return lRet

/*
{Protheus.doc} FsVldCdAl()
Validações de campos do Cadastro de Alçada
@Author     Bruno de Oliveira
@Since      08/03/2017
@Version    P12.1.07
@Project    MAN0000007423042_EF_004
@Param		lRet, permite ou não continuar
*/
Static Function FsVldCdAl(cCampo)
	
	Local aArea    := GetArea()
	Local oModel   := FwModelActive()
	Local oMdlPAB  := oModel:GetModel("PABMASTER")
	Local oMdlPAC  := oModel:GetModel("PACDETAIL")
	Local cTpSolic := oMdlPAB:GetValue("PAB_TPSOLI")
	Local cSubGrp  := oMdlPAB:GetValue("PAB_GRPSOL")
	Local cVisao   := oMdlPAB:GetValue("PAB_VISAO")
	Local cDtAlca  := dtos(oMdlPAB:GetValue("PAB_DTVLD"))
	Local cCodAprv := oMdlPAC:GetValue("PAC_CODPOS")
	Local cCodList := oMdlPAC:GetValue("PAC_CODLG")
	Local lRet     := .T.
	
	If cCampo == "PAB_TPSOLI"
		
		DbSelectArea("PA7")
		PA7->(DbSetOrder(1))
		If !PA7->(DbSeek(xFilial("PA7") + cTpSolic))
			Help("",1, "FsVldTpSl",, "Não existe este tipo de solicitação!" , 1, 0)
			lRet := .F.
		EndIf
	
	ElseIf cCampo == "PAC_CODLG"
		
		PAI->(DbSetOrder(1))
		If !PAI->(DbSeek(xFilial("PAI") + cCodList))
			lRet := .F.
		EndIf
		
	ElseIf cCampo == "PAB_GRPSOL"
		
		DbSelectArea("PA7")
		PA7->(DbSetOrder(1))
		If !PA7->(DbSeek(xFilial("PA7") + cTpSolic + cSubGrp))
			Help("",1, "FsVldTpSl",, "Não existe subgrupo para este tipo de solicitação!" , 1, 0)
			lRet := .F.
		EndIf
		
		If lRet
			DbSelectArea("PAB")
			PAB->(DbSetOrder(3))
			If PAB->(DbSeek(xFilial("PAB") + cTpSolic + cSubGrp + cDtAlca))
				Help("",1, "FsVldTpSl",, "Já existe um cadastro de alçada para esse tipo de solicitação, subgrupo e validade!" , 1, 0)
				lRet := .F.
			EndIf
		EndIf
		
		/*If lRet .And. cTpSolic == "005" .And. cSubGrp == "005" //Desligamento sem justa causa
			MsgAlert("Caso o usuário desligado tenha cargo superior ou igual a gerente, ou mais " + ;
				"de 10 anos de empresa, o fluxo de alçada será modificado, seguindo o " + ;
				"fluxo de alçada do subgrupo 098 e 099, respectivamente. O código " + ;
				"desses subgrupos estão contidos no código fonte, logo, não deverão ser alterados.","Atenção")
		EndIf*/
		
	ElseIf cCampo == "PAB_VISAO"
		
		DbSelectArea("RDK")
		RDK->(DbSetOrder(1))
		If !RDK->(DbSeek(xFilial("RDK") + cVisao))
			Help("",1, "FsVldTpSl",,"Não existe este código de visão!" , 1, 0)
			lRet := .F.
		EndIf
		
	ElseIf cCampo == "PAC_CODPOS"
		
		DbSelectArea("PA9")
		PA9->(DbSetOrder(1))
		If !PA9->(DbSeek(xFilial("PA9") + cCodAprv))
			Help("",1, "FsVldTpSl",,"Não existe este código de posto-filial de aprovação!" , 1, 0)
			lRet := .F.
		EndIf
		
	EndIf
	
	RestArea(aArea)
	
Return lRet

Static Function FsVldPrMdl()

	Local oMdl    := FwModelActivate()
	Local oMdlPAB := oMdl:GetModel("PABMASTER")
	Local oMdlPAC := oMdl:GetModel("PACDETAIL")
	Local cCodAlc := oMdlPAB:GetValue("PAB_CODIGO")
	Local cOper   := oMdl:GetOperation()
	Local cAlias1 := GetNextAlias()
	Local cRH3	  := "%" + RetFullName("RH3",cEmpAnt) + "%"
	Local lRet    := .T.
	
	If cOper == MODEL_OPERATION_UPDATE
		
		BeginSql alias cAlias1
			
			SELECT RH3.RH3_FILIAL, RH3.RH3_CODIGO
			FROM %Exp:cRH3% RH3
			WHERE RH3.RH3_XCODAL = %exp:cCodAlc%  AND
			RH3.RH3_STATUS IN ('1','4')  AND
			RH3.%notDel%
			
		EndSql
		
		If (cAlias1)->(!EOF())
			oMdlPAC:SetNoInsertLine( .T. )
			oMdlPAC:SetNoUpdateLine( .T. )
			oMdlPAC:SetNoDeleteLine( .T. )
			lRet := .F.		
		EndIf
		
		(cAlias1)->(DbCloseArea())
		
	EndIf
	
Return lRet

Static Function FsVldMdl()

	Local oMdl    := FwModelActivate()
	Local oMdlPAB := oMdl:GetModel("PABMASTER")
	Local oMdlPAC := oMdl:GetModel("PACDETAIL")
	Local cCodAlc := oMdlPAB:GetValue("PAB_CODIGO")
	Local cOper   := oMdl:GetOperation()
	Local cAlias1 := GetNextAlias()
	Local cRH3	  := "%" + RetFullName("RH3",cEmpAnt) + "%"
	Local lRet    := .T.
	Local nLoop	:= 0
	Local nLinha	:= 0
	
	If cOper == MODEL_OPERATION_DELETE
		
		BeginSql alias cAlias1
			
			SELECT RH3.RH3_FILIAL, RH3.RH3_CODIGO
			FROM %Exp:cRH3% RH3
			WHERE RH3.RH3_XCODAL = %exp:cCodAlc%  AND
			RH3.RH3_STATUS IN ('1','4')  AND
			RH3.%notDel%
			
		EndSql
		
		If (cAlias1)->(!EOF())
			Help("",1, "FsVldMdl",, "Não é permitido excluir, existem solicitações do portal utilizando esse cadastro!" , 1, 0)
			lRet := .F.
		EndIf
		
		(cAlias1)->(DbCloseArea())
		
	EndIf
	
	If lRet 
		If cOper == MODEL_OPERATION_INSERT
			nLinha := 1
			For nLoop := 1 To oMdlPAC:Length()
				oMdlPAC:GoLine(nLoop)
				If !oMdlPAC:IsDeleted()
					oMdlPAC:SetValue("PAC_NIVEL", StrZero(nLinha,2))
					nLinha ++
				EndIf
			Next
		EndIf
	EndIf
Return lRet

/*
{Protheus.doc} F0800404()
Cadastro do Controle de Alçada
@Author     Bruno de Oliveira
@Since      07/03/2017
@Version    P12.1.07
@Project    MAN0000007423042_EF_004
*/
User Function F0800404()

	Local cCodMov := ""
	Local cDesMov := ""
	Local aAreas     := {PA7->(GetArea()),RCC->(GetArea()),GetArea()}
	
	DbSelectArea("PA7")
	
	DbSelectArea("RCC")
	RCC->(DbSetOrder(1))
	If RCC->(DbSeek(xFilial("RCC") + "U006")) //Desligamento
		While RCC->(!EOF()) .AND. RCC->(RCC_FILIAL + RCC_CODIGO) == xFilial("RCC") + "U006"
			cCodMov := SubStr(RCC->RCC_CONTEU,1,3)
			cDesMov := SubStr(RCC->RCC_CONTEU,4)
			PA7->(DbSetOrder(1))
			If !PA7->(DbSeek(xFilial("PA7") + "005" + cCodMov))
				RecLock("PA7",.T.)
				PA7->PA7_FILIAL := xFilial("PA7")
				PA7->PA7_CODIGO := "005"
				PA7->PA7_DESCR  := "DESLIGAMENTO"
				PA7->PA7_CODSUB := cCodMov
				PA7->PA7_DESSUB := cDesMov
				PA7->(MsUnLock())
			Else
				If !(UPPER(Alltrim(PA7->PA7_DESSUB)) == UPPER(Alltrim(cDesMov)))
					RecLock("PA7",.F.)
					PA7->PA7_DESSUB := cDesMov
					PA7->(MsUnLock())
					
					DbSelectArea("PAB")
					PAB->(DbSetOrder(2))
					If PAB->(DbSeek(xFilial("PAB") + "005" + cCodMov))
						RecLock("PAB",.F.)
						PAB->PAB_GRPDES := cDesMov
						PAB->(MsUnLock())
					EndIf 					
				EndIf
			EndIf
			RCC->(DbSkip())
		End
	EndIf
	
	RCC->(DbSetOrder(1))
	If RCC->(DbSeek(xFilial("RCC") + "U010")) //Movimento de Pessoal
		While RCC->(!EOF()) .AND. RCC->(RCC_FILIAL + RCC_CODIGO) == xFilial("RCC") + "U010"
			cCodMov := SubStr(RCC->RCC_CONTEU,1,3)
			cDesMov := SubStr(RCC->RCC_CONTEU,4)
			PA7->(DbSetOrder(1))
			If !PA7->(DbSeek(xFilial("PA7") + "006" + cCodMov))
				RecLock("PA7",.T.)
				PA7->PA7_FILIAL := xFilial("PA7")
				PA7->PA7_CODIGO := "006"
				PA7->PA7_DESCR  := "MVT.DE PESSOAL"
				PA7->PA7_CODSUB := cCodMov
				PA7->PA7_DESSUB := cDesMov
				PA7->(MsUnLock())
			Else
				If !(UPPER(Alltrim(PA7->PA7_DESSUB)) == UPPER(Alltrim(cDesMov)))
					RecLock("PA7",.F.)
					PA7->PA7_DESSUB := cDesMov
					PA7->(MsUnLock())
					
					DbSelectArea("PAB")
					PAB->(DbSetOrder(2))
					If PAB->(DbSeek(xFilial("PAB") + "006" + cCodMov))
						RecLock("PAB",.F.)
						PAB->PAB_GRPDES := cDesMov
						PAB->(MsUnLock())
					EndIf			
				EndIf
			EndIf
			RCC->(DbSkip())
		End
	EndIf
	
	MsgAlert("Fim do Processamento!")
	
	AEval(aAreas, {|x| RestArea(x)} )
	
Return