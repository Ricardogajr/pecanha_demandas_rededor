#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDef.ch"
#INCLUDE "FWEditPanel.ch"

#DEFINE ALIAS_ZKT     "ZKT"
#DEFINE ROTINA_FILE	  "xKPTMntLog.prw"
#DEFINE VERSAO 		  " | v" + Trim(AllToChar(GetAPOInfo(ROTINA_FILE)[04])) + " - " + Trim(AllToChar(GetAPOInfo(ROTINA_FILE)[05])) + "[" + Trim(AllToChar(GetAPOInfo(ROTINA_FILE)[03])) + "]"
#DEFINE TITULO_MODEL  "Onergy Integration Cockpit - KTGroup"//+SubStr(VERSAO,1,25)
#DEFINE MODEL_MASTER  "ZKTMASTER"

/*/{Protheus.doc} xKPTMntLog
Monta Browse com as opções - CRUD MVC da tabela de Log de Monitoramenteo (Onergy)
@type function
@author Joalisson Laurentino | Kepptrue | 1198975-3610 | Skype: jslaurentino
@since 12/06/2021
/*/
User Function xKPTMntLog()
	Local cTitulo   := TITULO_MODEL
	Local cSetAlias := ALIAS_ZKT
	Local oBrowse   := Nil
	Local nOrdem	:= 4

	Private nTime   := SuperGetMV('KT_MNTREFS',.F.,5) // Tempo em Segundos para Refresh da tela de Execucao de Servicos (Default = 10 segundos)
	Private nAtuTela:= SuperGetMV('KT_ATUTELA',.F.,1) //Atualiza Autom. Tela ? 1-Refresh 1o Reg 2-Refresh Ult.Reg 3-Refresh Mesmo R 4-Sem Refresh    
	Private aRotina := FwLoadMenuDef("xKPTMntLog")

	If (FwAliasInDic(cSetAlias))
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias(cSetAlias)  
		oBrowse:AddLegend("ZKT_STATUS == '1'","ORANGE","Aguardando Execução") 			//Aguardando execução - A mensagem está na fila do JOB e ainda não começou a execução (o seu envio ou o seu processamento)
		oBrowse:AddLegend("ZKT_STATUS == '2'","GREEN" ,"Finalizado com Sucesso")		//Finalizada - A mensagem foi processada sem erros ou foi enviada sem erros;
		oBrowse:AddLegend("ZKT_STATUS == '3'","RED"   ,"Erro de Execução") 				//Falhou - Houve um erro no envio da mensagem ou no seu recebimento;
		oBrowse:AddLegend("ZKT_STATUS == '4'","BLUE"  ,"Documento já Classificado") 	//Registro já Classificado - Documento já processado e classificado.
		oBrowse:SetDescription(cTitulo)
		oBrowse:DisableDetails()
		oBrowse:SetAmbiente(.F.)
		oBrowse:SetWalkThru(.F.)
		oBrowse:SetFixedBrowse(.T.)
		oBrowse:SetTimer({|| RefreshBrw(oBrowse) }, Iif(nTime<=0, 3600, nTime) * 9000)
		oBrowse:SetIniWindow({||oBrowse:oTimer:lActive := (nAtuTela < 4)})

		// Ordenando a tabela temporária de forma decrescente
		ZKT->(DbSetOrder(nOrdem))
		ZKT->(OrdDescend(nOrdem,cValToChar(nOrdem),.T.))
		ZKT->(DbGoTop())

		oBrowse:Activate()
		oBrowse:Destroy()
	Else
		FWAlertHelp("Alias da Tabela [ "+cSetAlias+" ] não foi criado nesse grupo de empresa.","Entre em contato com o suporte para criar a tabela [ "+cSetAlias+" ] no ambiente.")
	Endif
Return()

/*/{Protheus.doc} ModelDef
Define o modelo de dados MVC da tabela de Log de Monitoramento (Onergy)
@type function
@author Joalisson Laurentino | Kepptrue | 1198975-3610 | Skype: jslaurentino
@since 05/06/2021
/*/
Static Function ModelDef()
    Local oModel	:= Nil
    Local oStruZKT	:= FwFormStruct(1,ALIAS_ZKT)

    oModel := MPFormModel():New('MxKPTMntLog',/*bMPre*/,/*bMPost*/,/*bMCommit*/,/*bMCancel*/)
    oModel:AddFields(MODEL_MASTER,/*cOwner*/,oStruZKT,/*bPreVld*/,/*bPostVld*/,/*bLoad*/)
    oModel:SetDescription('Onergy Cockpit')
    oModel:SetPrimaryKey({'ZKT_FILIAL','ZKT_ID','ZKT_ONERGY'})
Return(oModel)

/*/{Protheus.doc} ViewDef
Define o modelo de visualização MVC da tabela de Log de Monitoramento (Onergy)
@type function
@author Joalisson Laurentino | Kepptrue | 1198975-3610 | Skype: jslaurentino
@since 12/06/2021
/*/
Static Function ViewDef()
	Local oView	   := FwFormView():New()
	Local oModel   := FWLoadModel('xKPTMntLog')
	Local oStruZKT := FwFormStruct(2,ALIAS_ZKT) 

	oStruZKT:AddGroup('GRP_01','Chave do Log'              ,'',2)
    oStruZKT:AddGroup('GRP_02','Dados da Requisição - Json','',2)

    oStruZKT:SetProperty("ZKT_FILORI",MVC_VIEW_GROUP_NUMBER,"GRP_01")
    oStruZKT:SetProperty("ZKT_ID"    ,MVC_VIEW_GROUP_NUMBER,"GRP_01")
    oStruZKT:SetProperty("ZKT_ROTINA",MVC_VIEW_GROUP_NUMBER,"GRP_01")
    oStruZKT:SetProperty("ZKT_ONERGY",MVC_VIEW_GROUP_NUMBER,"GRP_01")
    oStruZKT:SetProperty("ZKT_ORIGEM",MVC_VIEW_GROUP_NUMBER,"GRP_01")
    oStruZKT:SetProperty("ZKT_DESTIN",MVC_VIEW_GROUP_NUMBER,"GRP_01")
    oStruZKT:SetProperty("ZKT_STATUS",MVC_VIEW_GROUP_NUMBER,"GRP_01")
	oStruZKT:SetProperty("*"         ,MVC_VIEW_GROUP_NUMBER,"GRP_01")
	oStruZKT:SetProperty("ZKT_JSON"  ,MVC_VIEW_GROUP_NUMBER,"GRP_02")
	oStruZKT:SetProperty("ZKT_RETURN",MVC_VIEW_GROUP_NUMBER,"GRP_02")

	oView:SetModel(oModel)
	oView:AddField(MODEL_MASTER,oStruZKT,MODEL_MASTER)

	oView:SetViewProperty(MODEL_MASTER,"SETLAYOUT",{FF_LAYOUT_VERT_DESCR_TOP,-1 })
	oView:CreateHorizontalBox('SUPERIOR',100)
	oView:SetOwnerView(MODEL_MASTER,'SUPERIOR')
Return(oView)

/*/{Protheus.doc} MenuDef
Define o menu de operacoes do CRUD MVC
@type function
@author Joalisson Laurentino | Kepptrue | 1198975-3610 | Skype: jslaurentino
@since 
/*/
Static Function MenuDef()  
	Local aRotina := {}
	Local aRotCad := {} 
	Local aRotImp := {}
	Local aRotExe := {}
	
	//INBOUND
    Private cPreNota := "SF101"  // MATA140	| GERA PRÉ NOTA
	Private cDocEnt  := "SF102"  // MATA103	| DOCUMENTO DE ENTRADA
	Private cSolPag  := "SC704"  // MATA120/F0100401 | SOLICITACAO DE PAGAMENTOS

	ADD OPTION aRotina TITLE "+ Detalhes" 						 	ACTION "VIEWDEF.xKPTMntLog"																					OPERATION MODEL_OPERATION_VIEW   ACCESS 1 
	ADD OPTION aRotina TITLE "Alterar" 	 	  					 	ACTION "VIEWDEF.xKPTMntLog" 																				OPERATION MODEL_OPERATION_UPDATE ACCESS 1 
	ADD OPTION aRotina TITLE "Excluir" 	  						 	ACTION "VIEWDEF.xKPTMntLog" 																				OPERATION MODEL_OPERATION_DELETE ACCESS 1 

	ADD OPTION aRotCad 	TITLE "00 | Enviar Todos IDs Pendentes"	 	ACTION "U_xKPTOutExc()" 																					OPERATION MODEL_OPERATION_INSERT ACCESS 2
	ADD OPTION aRotCad 	TITLE "01 | SM0 - Empresas/Filiais"			ACTION "FWMsgRun(,{|oSay| U_xKPTOSM0(,,,oSay) },'ID: SM001','Enviando Empresas e Filiais...')" 	 			OPERATION MODEL_OPERATION_INSERT	ACCESS 2
	ADD OPTION aRotCad 	TITLE "02 | SF4 - Tipos de Entrada e Saída"	ACTION "FWMsgRun(,{|oSay| U_xKPTOSF4(,,,oSay) },'ID: SF401','Enviando Cadastro de TES/Tipos de Entrada e Saída...')" 	 			OPERATION MODEL_OPERATION_INSERT	ACCESS 2
	ADD OPTION aRotCad 	TITLE "03 | SC7 - Pedidos de Compras"		ACTION "FWMsgRun(,{|oSay| U_xKPTOSC7(,,,,,oSay) },'ID: SC701','Enviando Pedidos de Compras...')" 	 			OPERATION MODEL_OPERATION_INSERT	ACCESS 2
	ADD OPTION aRotCad 	TITLE "04 | SB1 - Produtos"					ACTION "FWMsgRun(,{|oSay| U_xKPTOSB1(,,,oSay) },'ID: SB101','Enviando Produtos...')" 	 					OPERATION MODEL_OPERATION_INSERT	ACCESS 2
	ADD OPTION aRotCad 	TITLE "05 | SED - Natureza"					ACTION "FWMsgRun(,{|oSay| U_xKPTOSED(,,,oSay) },'ID: SED01','Enviando Naturezas...')" 	 					OPERATION MODEL_OPERATION_INSERT	ACCESS 2
	//ADD OPTION aRotCad 	TITLE "06 | SA5 - Produtos x Fornecedores"	ACTION "FWMsgRun(,{|oSay| U_xKPTOSA5(,,,oSay) },'ID: SA501','Enviando Produtos x Fornecedores...')" 	 			OPERATION MODEL_OPERATION_INSERT	ACCESS 2
	ADD OPTION aRotCad 	TITLE "06 | SE4 - Condição de Pagamentos"	ACTION "FWMsgRun(,{|oSay| U_xKPTOSE4(,,,oSay) },'ID: SE401','Enviando Condição de Pagamentos...')" 	 			OPERATION MODEL_OPERATION_INSERT	ACCESS 2
	ADD OPTION aRotCad 	TITLE "07 | CTT - Centro de Custo"			ACTION "FWMsgRun(,{|oSay| U_xKPTOCTT(,,,oSay) },'ID: CTT01','Enviando Centro de Custo...')" 	 			OPERATION MODEL_OPERATION_INSERT	ACCESS 2
	ADD OPTION aRotCad 	TITLE "08 | SD1 - Historico TES"			ACTION "FWMsgRun(,{|oSay| U_xKPTOSD1(,,,oSay) },'ID: SD101','Enviando Historico de TES...')" 	 			OPERATION MODEL_OPERATION_INSERT	ACCESS 2
	ADD OPTION aRotCad 	TITLE "09 | P02 - Tipo de Requisição"	    ACTION "FWMsgRun(,{|oSay| U_xKPTOP02(,,,oSay) },'ID: P0201','Enviando Cadastro de Tipo de Requisição...')" 	 			OPERATION MODEL_OPERATION_INSERT	ACCESS 2
	ADD OPTION aRotCad 	TITLE "10 | P11 - Setores"	    			ACTION "FWMsgRun(,{|oSay| U_xKPTOP11(,,,oSay) },'ID: P1101','Enviando Cadastro de Setores...')" 	 			OPERATION MODEL_OPERATION_INSERT	ACCESS 2
	ADD OPTION aRotCad 	TITLE "11 | P13 - Fabricantes"	    		ACTION "FWMsgRun(,{|oSay| U_xKPTOP13(,,,oSay) },'ID: P1301','Enviando Cadastro de Fabricantes...')" 	 			OPERATION MODEL_OPERATION_INSERT	ACCESS 2
	ADD OPTION aRotCad 	TITLE "12 | KT0 - Perfil de Acesso"    		ACTION "FWMsgRun(,{|oSay| U_xKPTOKT0(,,,oSay) },'ID: KT001','Enviando Perfil de Acesso...')" 	 			OPERATION MODEL_OPERATION_INSERT	ACCESS 2
	ADD OPTION aRotCad 	TITLE "13 | SC7 - Pedidos de Compras Manual"ACTION "FWMsgRun(,{|oSay| U_xKPTOSC7(,,,,oSay,,.T.) },'ID: SC701','Enviando Pedido de Compras...')" 	 			OPERATION MODEL_OPERATION_INSERT	ACCESS 2


	ADD OPTION aRotina 	TITLE "01 | Outbound"	 			 		ACTION aRotCad 																								OPERATION MODEL_OPERATION_UPDATE ACCESS 2
	
	ADD OPTION aRotImp TITLE "00 | Importar IDs Pendentes"		    ACTION "U_xKPTInbound()" 																					OPERATION MODEL_OPERATION_INSERT ACCESS 2	
	ADD OPTION aRotina TITLE "02 | Inbound"				 		    ACTION aRotImp 																								OPERATION MODEL_OPERATION_UPDATE ACCESS 2

	ADD OPTION aRotExe TITLE "00 | Todos IDs Pendentes"			    ACTION "U_xKPTInbExc()" 																					OPERATION MODEL_OPERATION_INSERT ACCESS 2
	ADD OPTION aRotExe TITLE "01 | Processar Posicionado"		    ACTION "U_xKPTInbExc(,.T.)" 																				OPERATION MODEL_OPERATION_INSERT ACCESS 2	
	ADD OPTION aRotExe TITLE "02 | SF101 - Pré Nota"				ACTION "U_xKPTInbExc(,.F.,'"+cPreNota+"')"																	OPERATION MODEL_OPERATION_INSERT ACCESS 2
	ADD OPTION aRotExe TITLE "03 | SF102 - Doc. Entrada"			ACTION "U_xKPTInbExc(,.F.,'"+cDocEnt+"')"																	OPERATION MODEL_OPERATION_INSERT ACCESS 2
	ADD OPTION aRotExe TITLE "04 | SC704 - Solicitação de Pagamentos"ACTION "U_xKPTInbExc(,.F.,'"+cSolPag+"')"																	OPERATION MODEL_OPERATION_UPDATE ACCESS 2
	ADD OPTION aRotina TITLE "03 | Executar IDs Protheus"	        ACTION aRotExe 																								OPERATION MODEL_OPERATION_INSERT ACCESS 2
	ADD OPTION aRotina TITLE "04 | Perfil de Acesso Portal"			ACTION "U_xKPTPerfil()" 	 																				OPERATION MODEL_OPERATION_INSERT ACCESS 2
Return aRotina

//-------------------------------------------------------------------//
//------------Refresh do Browse para Recarregar a Tela---------------//
//-------------------------------------------------------------------//
Static Function RefreshBrw(oBrowse)
	Local nPos := oBrowse:At()

	//oBrowse:SetFilterDefault("@"+Filtro())
	If nAtuTela == 1
		oBrowse:Refresh(.T.)
	ElseIf nAtuTela == 2
		oBrowse:Refresh(.F.)
		oBrowse:GoBottom()
	Else
		oBrowse:Refresh(.F.)
		oBrowse:GoTo(nPos)
	EndIf

Return .T.
