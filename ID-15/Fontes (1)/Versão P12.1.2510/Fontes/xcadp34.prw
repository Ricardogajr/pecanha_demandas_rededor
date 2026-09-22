 /*/{Protheus.doc} XCADP34
@Description - Função de cadastro dos tipos de requisição na tabela P34
@type  Function
@author Lucas Miranda
@since 07/07/2021
@version 1.0
/*/
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

User Function XCADP34()

	Local oBrowse := FWmBrowse():New()

	oBrowse:SetAlias("P34")
	oBrowse:SetMenuDef("XCADP34")
	oBrowse:SetDescription("Amarração Multa/Juros")
	oBrowse:Activate()

Return NIL

Static Function MenuDef()

Return FWMVCMenu("XCADP34")


Static Function ModelDef()

	Local oStru := FwFormStruct(1, "P34")

	oStru:RemoveField('P34_FILIAL')

	oModel := MPFormModel():New('MXCADP34',,,)
	oModel:AddFields('P34MASTER', , oStru, , , )
	oModel:SetDescription('Amarração Multa/Juros')
	oModel:GetModel('P34MASTER'):SetDescription('Amarração Multa/Juros')
	oModel:GetModel("P34MASTER"):SetPrimaryKey({"P34_FILIAL", "P34_TIPO", "P34_PRODUT"})

Return oModel


Static Function ViewDef()

	Local oModel   	:= FWLoadModel('XCADP34')
	Local oStru 	:= FwFormStruct(2, "P34")
	Local oView		:= Nil

	oView := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField('VIEW_P34', oStru, 'P34MASTER')
	oView:CreateHorizontalBox('TELA' , 100)
	oView:SetOwnerView('VIEW_P34', 'TELA')

Return oView

/*/Static Function SaveModel(oModel)

	Local aAreas := {P34->(GetArea()), GetArea()}
	Local lRet   := .T.
	Local cSpace := Space(Len(P34->P34_PRODUT))

	DbSelectArea("P34")
	DbSetOrder(3)

	If P34->(DbSeek(xFilial("P34")+M->P34_TIPO+M->P34_PRODUT))
		Alert("O Tipo de Requisição X Produto já está cadastrado!")
		lRet := .F.
		AEval(aAreas, {|aArea| RestArea(aArea)})
		Return lRet
	EndIf

	If P34->(DbSeek(xFilial("P34")+M->P34_TIPO+cSpace))
		Alert("O Tipo de Requisição já está cadastrada!")
		lRet := .F.
		AEval(aAreas, {|aArea| RestArea(aArea)})
		Return lRet
	EndIf

	If lRet
		P34->(Reclock("P34",.T.))
			P34->P34_FILIAL := xFilial("P34")
			P34->P34_PRODUT := M->P34_PRODUT
			P34->P34_TIPO 	:= M->P34_TIPO
			P34->P34_DESCTP	:= M->P34_DESCTP
			P34->P34_DESCPR := M->P34_DESCPR
			P34->P34_MULTA  := M->P34_MULTA
			P34->P34_JUROS	:= M->P34_JUROS
		P34->(MsUnlock())
	EndIf

	AEval(aAreas, {|aArea| RestArea(aArea)})
Return lRet
/*/

User Function xFDescTp()


	Local aArea := GetArea()

	DbSelectArea("P02")
	DbSeek(xFilial('P02') + M->P34_TIPO)

	RestArea(aArea)

Return AllTrim(P02->P02_DESC)

User Function xfDescProd()


	Local aArea := GetArea()

	DbSelectArea("SB1")
	DbSeek(xFilial('SB1') + M->P34_PRODUT)

	RestArea(aArea)

Return AllTrim(SB1->B1_DESC)

