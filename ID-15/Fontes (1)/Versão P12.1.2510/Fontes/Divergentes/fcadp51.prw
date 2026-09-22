#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#include "Protheus.ch"
#iNCLUDE "FWMVCDEF.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"


User Function FCADP51()

	Local oBrowse := FWmBrowse():New()

	Private cNomeLog  := "Log de integrações Plannexo"

	oBrowse:AddLegend("P51_STATUS=='2'", "ENABLE" , "Integrado com sucesso!" )
	oBrowse:AddLegend("P51_STATUS=='3'", "DISABLE" , "Erro na integração!"  )
	oBrowse:AddLegend("P51_STATUS=='1'", "BR_AZUL"  , "Integração em andamento!" )

	oBrowse:SetAlias("P51")
	oBrowse:SetMenuDef("FCADP51")
	oBrowse:SetDescription("Log de integrações Plannexo")
	oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Construção do menu na rotina FCADP51
@author Lucas Miranda de Aguiar
@since 07/05/2025
@version 1.0
Inicial
@return NIL
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	Local aFuncoes := {}
	Local aRels := {}
	Local aEscolha := {}

	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.FCADP51" OPERATION 2  ACCESS 0 // Visualizar
	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Construção do modelo na rotina de LOG P51
@author Lucas Miranda de Aguiar
@since 07/05/2025
@version 1.0
Inicial
@return NIL
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStru := FwFormStruct(1, "P51")


	oModel := MPFormModel():New('MXCADP51',,,)
	oModel:AddFields('P51MASTER', , oStru, , , )
	oModel:SetDescription('Monitor Plannexo')
	oModel:GetModel('P51MASTER'):SetDescription('Monitor Plannexo')
	oModel:GetModel("P51MASTER"):SetPrimaryKey({"P51_FILIAL", "P51_IDPLAN"})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Construção da view na rotina de LOG P51
@author Lucas Miranda de Aguiar
@since 07/05/2025
@version 1.0
Inicial
@return NIL
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   	:= FWLoadModel('FCADP51')
	Local oStru 	:= FwFormStruct(2, "P51")
	Local oView		:= Nil

	oView := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField('VIEW_P51', oStru, 'P51MASTER')
	oView:CreateHorizontalBox('TELA' , 100)
	oView:SetOwnerView('VIEW_P51', 'TELA')

Return oView
