#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

/*
{Protheus.doc} F0201401()
Monta a tela dos contra indicados
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_014
@Return
*/
User Function F0201401()
	
	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('PA0')
	oBrowse:SetDescription('Arquivo de Contraind�cados')
	oBrowse:Activate()
	
Return

//============================================================================================

Static Function MenuDef()
	Local aRotina := {}

	Aadd(aRot , {"&Visualizar"    , "VIEWDEF.F0201401"        , 0, 2})
	Aadd(aRot , {"&Incluir"    , "VIEWDEF.F0201401"        , 0, 3})
	Aadd(aRot , {"&Alterar"    , "VIEWDEF.F0201401"        , 0, 4})
	Aadd(aRot , {"&Excluir"    , "VIEWDEF.F0201401"        , 0, 5})
	Aadd(aRot , {"Impor&tar"    , "U_F0201403()"        , 0, 3})
	
Return aRotina

//============================================================================================

Static Function ModelDef()
	
	Local oStruPA0 := FWFormStruct( 1, 'PA0', /*bAvalCampo*/,.F. )
	Local oModel
	
	oModel := MPFormModel():New('F02014', ,{|oModel| MontAlt(oModel) } ,  , /*bCancel*/ )
	oModel:AddFields( 'PA0MASTER', /*cOwner*/, oStruPA0, , /*{|| MontAlt(oModel) }*/, /*bCarga*/ )
	oModel:SetDescription( 'Arquivo de Contraind�cados' )
	oModel:SetPrimaryKey({"PA0_XCPF"})
	oModel:GetModel( 'PA0MASTER' ):SetDescription( 'Contraind�cados' )
	
Return oModel

//============================================================================================

Static Function ViewDef()
	
	Local oModel   := FWLoadModel( 'F0201401' )
	Local oStruPA0 := FWFormStruct( 2, 'PA0' )
	Local oView
	Local cCampos := {}
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_PA0', oStruPA0, 'PA0MASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_PA0', 'TELA' )
	
Return oView

//============================================================================================
/*
{Protheus.doc} MontAlt()
Quando altera��o monta o array para inclus�o na tabela de log
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_014
@Param		 oModel
@Return	 .T.
*/
Static Function MontAlt(oModel)
	
	Local oModel1  	:= oModel:GetModel()
	Local nOperation	:= oModel:GetOperation()
	
	DO CASE
		CASE nOperation == MODEL_OPERATION_INSERT
			GrvAlt(oModel1:GetValue( 'PA0MASTER', "PA0_XCPF" ), Date(), "1")
		CASE nOperation == MODEL_OPERATION_UPDATE
			GrvAlt(oModel1:GetValue( 'PA0MASTER', "PA0_XCPF" ), Date(), "2")
		CASE nOperation == MODEL_OPERATION_DELETE
			GrvAlt(oModel1:GetValue( 'PA0MASTER', "PA0_XCPF" ), Date(), "3")
	ENDCASE
	
Return .T.


//============================================================================================
/*
{Protheus.doc} GrvAlt()
Grava a altera��o na tabela de log
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_014
@Param		 cCpf
@Param		 cData
@Param		 cCampo
@Param		 cHist
@Param		 cObs
@Return	 lRet
*/
Static Function GrvAlt(cCpf, cData, cOp)
	Local aArea     := GetArea()
	Local aAreaPA1  := PA1->(GetArea())
	
	DbSelectArea("PA1")
	
	If !(EMPTY(cCpf))
		//Salvando o log
		RecLock("PA1", .T.)
		PA1_XCPF   := cCpf                    // CPF do contra indicado
		PA1_XDAT   := cData                   // data de altera��o
		PA1_XUSUA  := UsrRetName(RetCodUsr()) // nome de quem alterou
		PA1_XTIPO  := cOp         // Incluido
		PA1->(MsUnlock())
	EndIf
	
	RestArea(aAreaPA1)
	RestArea(aArea)
Return
