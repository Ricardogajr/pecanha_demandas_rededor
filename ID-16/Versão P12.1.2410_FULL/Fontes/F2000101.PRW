#Include 'TOTVS.ch'
#Include 'FWMVCDEF.ch'

/*/{Protheus.doc} User Function F2000101
    Browse PX0
    @type  Function
    @author Gianluca Moreira
    @since 17/05/2021
    /*/
User Function F2000101(cFiltro, oOwner)
	Local oBrowse
	Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual

    //Integração não habilitada neste grupo
    If !lGrpHblt
		Help(,, "F2000130",, 'A integração do XRT não está habilitada nesta empresa.', 1, 0,;
		,,,,, {'Verifique se os campos do processo estão criados e habilite através da rotina F2000130'})
        Return
    EndIf

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('PX0')
	oBrowse:SetDescription('Integração Contas a Pagar - XRT')
    oBrowse:AddLegend('PX0->PX0_STTIT == "1"', 'ORANGE',        'Temp. -1', "1")
    oBrowse:AddLegend('PX0->PX0_STTIT == "2"', 'BR_VIOLETA',    'Temp. +1', "1")
	oBrowse:AddLegend('PX0->PX0_STTIT == "3"', 'BR_AZUL_CLARO', 'Temp. +2', "1")
    oBrowse:AddLegend('PX0->PX0_STXRT $ "1 "', 'YELLOW', 'Pendente Int.', "2")
    oBrowse:AddLegend('PX0->PX0_STXRT == "2"', 'GREEN',  'Int. com sucesso', "2")
    oBrowse:AddLegend('PX0->PX0_STXRT == "3"', 'RED',    'Falha de comunicação', "2")
    oBrowse:AddLegend('PX0->PX0_STXRT == "4"', 'CANCEL', 'Falha de dados', "2")
    oBrowse:AddLegend('PX0->PX0_STXRT == "5"', 'BLUE',   'Enviado ao barramento', "2")

	If cFiltro != NIL
		oBrowse:SetFilterDefault ( cFiltro )
	EndIf
    oBrowse:DisableDetails()
	oBrowse:SetMenuDef('F2000101')

	If oOwner != Nil
		oBrowse:Activate(oOwner)
	Else
	oBrowse:Activate()
	EndIf

Return NIL

Static Function MenuDef()
	Local aRot := {}

	/*ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.F2000101' OPERATION 2 ACCESS 0
	ADD OPTION aRot TITLE 'Log Integração' ACTION 'U_F2000107()' OPERATION 2 ACCESS 0
	ADD OPTION aRot TITLE 'Reenviar' ACTION 'U_F200010A()' OPERATION 2 ACCESS 0*/
	aAdd(aRot, {"Visualizar", 		"VIEWDEF.F2000101", 0, 2})
	aAdd(aRot, {"Log Integração", 	"U_F2000107()", 	0, 2})
	aAdd(aRot, {"Reenviar", 		"U_F200010A()", 	0, 2})

Return aRot

Static Function ModelDef()
	Local oStruPX0 := FWFormStruct(1,"PX0", /*bAvalCampo*/,/*lViewUsado*/ )
	local oModel   := MPFormModel():New('MF2000101',,,, /*bCancel*/ )	
	oModel:AddFields('PX0MASTER', /*cOwner*/, oStruPX0, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetPrimaryKey( {"FwXFilial('PX0')","PX0_CHVXRT"} )
Return oModel

Static Function ViewDef()
	Local oModel := FWLoadModel( 'F2000101' )
	Local oStruPX0 := FWFormStruct( 2, 'PX0' )
	Local oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "VIEW_PX0", oStruPX0, 'PX0MASTER')
	oView:CreateHorizontalBox( "TELA" , 100 )
	oView:SetOwnerView( "VIEW_PX0","TELA" )

Return oView

/*/{Protheus.doc} User Function F2000107
	Chama o log de integração (P20)
	@type  Function
	@author Gianluca Moreira
	@since 24/05/2021
	/*/
User Function F2000107()
	Local cFiltro := ''
	Local cFilP20 := ''
	Local cTit    := ''
	Local cChave  := ''

	//cChave := SubStr("PX0|03|"+PX0->PX0_FILIAL+PX0->PX0_CHVXRT+Space(Len(P20->P20_INDKEY)), 1, Len(P20->P20_INDKEY))
	cChave  := SubStr(PX0->PX0_IDP20, FWSizeFilial()+1)
	cFilP20 := Left(PX0->PX0_IDP20, FWSizeFilial())
	cChave  := AvKey(cChave, 'P20_ID')

	cTit    := 'Log Integração Títulos a Pagar - XRT'
	cFiltro := "@"
	cFiltro += " P20_FILIAL = '"+cFilP20+"' AND "
	cFiltro += " P20_ID = '"+cChave+"' AND "
	cFiltro += "D_E_L_E_T_ = ' '"
	U_F2000105(cTit, cFiltro, "P20")
Return 

/*/{Protheus.doc} User Function F200010A
	Reenvia o título posicionado, caso não tenha retornado do XRT
	@type  Function
	@author Gianluca Moreira
	@since 16/07/2021
	/*/
User Function F200010A()
	Local cMsg := ''
/*
	If PX0->PX0_STXRT != '5'
		cMsg := 'O título já foi integrado ao XRT ou está na fila de espera. '
		cMsg += 'Caso precise corrigir alguma informação, estorne a movimentação e altere o título.'
		MsgStop(cMsg, 'Reenvio')
		Return
	EndIf*/

	cMsg := 'Deseja reenviar o título posicionado?'
	If MsgYesNo(cMsg, 'Reenvio')
		If RecLock('PX0', .F.)
			PX0->PX0_STXRT := '1' //Pendente
			PX0->(MsUnlock())
		EndIf
	EndIf
Return
