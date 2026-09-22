#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F0800202
Tela de Histórico do Arquivo de Log

@type function
@author		Ademar Fernandes
@since		02/03/2017
@version	1.0
@version	P12.1.7
@Project	MAN0000007423042_EF_002
@return 	lRet => Indica se a gravação foi realizada com sucesso
/*/
//---------------------------------------------------------------------------------------------------------------------------

User Function F0800202()
	
	Local oBrowse
	Local cFiltro  := ""
	
	cFiltro := "Empty(PAA_CODIGO)"
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("PAA")
	oBrowse:SetDescription('Histórico de Log das Solicitações')
	oBrowse:Activate()

Return NIL


Static Function MenuDef()
	Local aMyRotina := {}
	
	ADD OPTION aMyRotina Title 'Consultar' 	Action 'VIEWDEF.F0800202' OPERATION 2 ACCESS 0
//?	ADD OPTION aMyRotina Title 'Popular' 	Action 'U_TSTLOG' OPERATION 2 ACCESS 0
	
Return aMyRotina


Static Function ModelDef()
	Local oStruMod 	:= FWFormStruct(1,'PAA')
	Local oModel	:= MPFormModel():New('ModPAA') //Model com 7 caracteres

	oModel:AddFields('MASTER',, oStruMod)
	oModel:SetPrimaryKey({})
	oModel:SetDescription('Histórico de Log das Solicitações')
	oModel:GetModel('MASTER'):SetDescription('Histórico de Log das Solicitações')
	oModel:SetVldActivate( { |oModel| ValidMod(oModel) } )
	
Return oModel


Static Function ViewDef()
	Local oModel 	:= FWLoadModel('F0800202')
	Local oStruView := FWFormStruct(2,'PAA')
	Local oView		:= FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField('VIEW_MASTER', oStruView, 'MASTER')
	oView:CreateHorizontalBox('SUPERIOR', 100 )
	oView:SetOwnerView('VIEW_MASTER', 'SUPERIOR')
	oView:EnableControlBar(.T.)
Return oView


Static Function ValidMod()	
	Local lRet 	:= .F.
	Local aArea	:= GetArea()
	
	dbSelectArea('PAA')
	dbGoTop()
	If !EOF()
		lRet 	:= .T.
	Else
		Help("",1, "Help", "Sem registro na PAA", "Não há dados para ser exibido." , 3, 0)	
	EndIf
	RestArea(aArea)	
Return lRet 

//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TSTLOG
Testa log

@type function
@author		Ademar Fernandes
@since		02/03/2017
@version	1.0
@version	P12.1.7
@Project	MAN0000007423042_EF_002
/*/
//---------------------------------------------------------------------------------------------------------------------------

User Function TSTLOG()
	//-F0800201(cTpOper,cNumSol,cCodAlc,cFilSol,cMatSol,cFilApr,cMatApr,cObsLog)
	If !U_F0800201("1","00001","000001","01","114603","01","114603","Campo de observação: solicitação de Aumento de Quadro")
		MsgAlert("Tipo de Operação 1 deu erro!",FunDesc())
	EndIf
	If !U_F0800201("2","00002","000001","01","114603","01","114603","Campo de observação: solicitação de Formulário de Aprovação Profissional (FAP)")
		MsgAlert("Tipo de Operação 2 deu erro!",FunDesc())
	EndIf
	If !U_F0800201("3","00003","000001","01","114603","01","114603","Campo de observação: solicitação de Desligamento")
		MsgAlert("Tipo de Operação 3 deu erro!",FunDesc())
	EndIf
	If !U_F0800201("4","00004","000001","01","114603","01","114603","Campo de observação: solicitação de Movimentação de Pessoal")
		MsgAlert("Tipo de Operação 4 deu erro!",FunDesc())
	EndIf
	
	MsgAlert("Teste finalizado (Y)!",FunDesc())
Return Nil
