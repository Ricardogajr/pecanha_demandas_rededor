#INCLUDE "RWMAKE.CH"
#INCLUDE "Protheus.CH"
#include "fwmvcdef.ch"

#define cNomeArq "PSDTFIXSP"
#define MVC_ALIAS "TMPDTFIX"

/*/{Protheus.doc} fTelaExcSp
Função responsável por apresentar a tela para o usuário editar as datas da parcela, exceção data fixa.
@type function
@author Ricardo Junior  
@since 14/10/2021
@version 1.0
@return aReturn - Retorna um array
/*/ 

User Function PSDTFIXSP(cCondicao, nValor, nOpc)
	Local aArea := GetArea()

	Private cCond := cCondicao
	Private nVal := nValor
	Private oModel as object
	Private __oTmpDTFIX as object
	Private lVis		:= MODEL_OPERATION_VIEW
	Private _nOpcao as numeric
	Private oModelSC7   := NIL
	Private oModelCabec := NIL
	Private oModelItem  := NIL

	Public __ADTVENCTO := {}

	Default nOpc := 3

	_nOpcao := nOpc

	oModelSC7 := FwModelActive()
	oModelCabec := oModelSC7:GetModel("MODEL_SC7p")
	oModelItem  := oModelSC7:GetModel("MODEL_SC7")

	lExceDtFix := AllTrim(oModelCabec:GetValue("C7_XDTEXCE")) == "1" .And. AllTrim(oModelCabec:GetValue("C7_XTPSP")) $ "2|3"

	if !lExceDtFix
		Return .T.
	else
		__ADTVENCTO := {}
	endif

	cCond 	:= oModelCabec:GetValue("C7_COND")
	nVal 	:= oModelItem:GetValue("C7_TOTAL")

	if nVal == 0
		Aviso("Atenção", "Por favor, para que seja preenchida a tela de exceção é necessário o preenchimento do valor", {"voltar"})
		Return .T.
	endif

	FWExecView( "Alteração da data de vencimento - Exceção data Fixa", "VIEWDEF."+cNomeArq,4,, { || .T. }, , 50,,{|| .F. })

	RestArea(aArea)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

@return oView - Objeto da view, interface
@author 
@since 10/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
static function viewDef()
	local oView as object
	local oModel as object
	local oStrGrid as object

	oStrCabec := FWFormViewStruct():New()
	oStrCabec:addField("XXNUM", 		"01" , "Número", 		"Número",, 			"C", "@!", ,      , .F., "01", , , , , .F., , ,  )
	oStrGrid := FWFormViewStruct():New()
	oStrGrid:addField("XXPREFIXO", 	"01" , "Prefixo", 		"Prefixo",, 		"C", "@!", ,      , .F., "01", , , , , .F., , ,  )
	oStrGrid:addField("XXNUM", 		"02" , "Número", 		"Número",, 			"C", "@!", ,      , .F., "01", , , , , .F., , ,  )
	oStrGrid:addField("XXTIPO", 		"03" , "Tipo", 			"Tipo",, 			"C", "@!", ,      , .F., "01", , , , , .F., , ,  )
	oStrGrid:addField("XXPARCELA", 	"04" , "Ord", 			"Ord",, 			"C", "@!", ,      , .F., "01", , , , , .F., , ,  )
	oStrGrid:addField("XXVENCREA", 	"05" , "Vencimento",	"Vencimento",, 		"D", "@!", ,      , .T., "01", , , , , .F., , ,  )
	oStrGrid:addField("XXVALOR",		"06" , "Vlr Duplicata",	"Vlr Duplicata",, 	"N", "@E 99,999,999,999.99", ,      , .F., "01", , , , , .F., , ,  )

	oModel 	:= FwLoadModel("PSDTFIXSP")

	oView 	:= FwFormView():New()

	oView:SetModel(oModel)

	// Estrutura visual dos campos
	oView:AddField('CABEC', oStrCabec, "CABEC1")

	// Estrutura visual das grids
	oView:AddGrid('GRID', oStrGrid, "GRID")

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox( 'BOX_SUPERIOR', 0 )
	oView:CreateHorizontalBox( 'BOX_INFERIOR', 100 )

	oView:SetOwnerView('CABEC' , 'BOX_SUPERIOR' )
	oView:SetOwnerView('GRID', 'BOX_INFERIOR')

	oView:EnableTitleView("CABEC", "Dados Brutos do Produto")
	oView:EnableTitleView("GRID", "Dados Científicos do Produto")

	//oView:SetProgressBar(.T.)
	oView:SetCloseOnOk({||.T.})


return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Montagem do modelo dados para MVC
@return oModel - Objeto do modelo de dados
@author
@since 10/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static function ModelDef()

	local oStrGrid as object
	Local bLoad := {|oGridModel, lCopy| GridLoad(oGridModel, lCopy)}

	oStrGrid := FWFormModelStruct():New()
	//oStrGrid:AddTable(__oTmpDTFIX:oStruct:GetAlias(), {} , "DTFIX")
	oStrGrid:AddTable("   ",{" "}," ")

	oStrGrid:AddIndex(1,'1','XXNUM','XXNUM','','',.T.)
	oStrGrid:addField("Prefixo",	  "Prefixo", 		"XXPREFIXO",FwTamSx3("E2_PREFIXO")[3], FwTamSx3("E2_PREFIXO")[1], FwTamSx3("E2_PREFIXO")[2], Nil,Nil,{},.T.,,.F.,.F.,.F.)
	oStrGrid:addField("Número", 	  "Número", 		"XXNUM", 	 FwTamSx3("E2_NUM")[3], FwTamSx3("E2_NUM")[1], FwTamSx3("E2_NUM")[2], Nil,Nil,{},.T.,,.F.,.F.,.F.)
	oStrGrid:addField("Tipo", 		  "Tipo", 			"XXTIPO", 	 FwTamSx3("E2_TIPO")[3], FwTamSx3("E2_TIPO")[1], FwTamSx3("E2_TIPO")[2], Nil,Nil,{},.T.,,.F.,.F.,.F.)
	oStrGrid:addField("Ord", 		  "Ord", 			"XXPARCELA",FwTamSx3("E2_PARCELA")[3], FwTamSx3("E2_PARCELA")[1], FwTamSx3("E2_PARCELA")[2], Nil,Nil,{},.T.,,.F.,.F.,.F.)
	oStrGrid:addField("Vencimento",   "Vencimento",   	"XXVENCREA",FwTamSx3("E2_VENCREA")[3], FwTamSx3("E2_VENCREA")[1], FwTamSx3("E2_VENCREA")[2], Nil,Nil,{},.T.,,.F.,.F.,.F.)
	oStrGrid:addField("Vlr Duplicata","Vlr Duplicata",	"XXVALOR",  FwTamSx3("E2_VALOR")[3], FwTamSx3("E2_VALOR")[1], FwTamSx3("E2_VALOR")[2], Nil,Nil,{},.T.,,.F.,.F.,.F.)

	oStrCampo := FWFormModelStruct():New()
	oStrCampo:AddTable("   ",{" "}," ")
	oStrCampo:addField("Número", "Número",	"XXNUM", 	 'C', FwTamSx3("E2_NUM")[1])

	oModel   := MpFormModel():New("MPSDTFIXSP",,, {|oModel| SaveModel(oModel)})

	oModel:addFields("CABEC1",, oStrCampo , , ,{||CabecLoad()})
	oModel:addGrid("GRID", "CABEC1", oStrGrid,,,,,bLoad)
	oModel:SetPrimaryKey({"XXPREFIXO", "XXNUM"})

	//oModel:SetRelation('GRID', { { 'XXNUM', 'XXNUM' } })

	oModel:setDescription("Exceção Data Fixa SP")
	oModel:GetModel("CABEC1"):SetDescription("Formulário do Cadastro ")
	oModel:GetModel("GRID"):SetDescription("Formulário do Cadastro 2")

	oModel:GetModel( 'GRID' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'GRID' ):SetNoDeleteLine( .T. )

	//(__oTmpDTFIX:oStruct:GetAlias())->(DbGoTop())
	//Ao ativar o modelo, irá alterar o campo do cabeçalho mandando o conteúdo FAKE pois é necessário alteração no cabeçalho
	//oModel:SetActivate({ | oModel | ActiveModel(oModel) })

return oModel

Static FUNCTION CabecLoad()
	LOCAL aLoad := {}
	Local oModelSP := FwModelActive()
	Local oModelCabec := oModelSP:GetModel("MODEL_SC7p")

	aAdd(aLoad, {oModelCabec:getValue("C7_XDOC")}) //dados
	aAdd(aLoad, 1) //recno

RETURN aLoad

Static Function GridLoad(oModel)
	Local nI 		:= 0
	Local aRet := {}
	Local oModelSP := FwModelActive()
	Local oModelCabec := oModelSP:GetModel("MODEL_SC7p")

	if _nOpcao == MODEL_OPERATION_INSERT		
		aVenc := Condicao(nVal, cCond,,oModelCabec:GetValue("C7_EMISSAO"))
		For nI := 01 To Len(aVenc)
			aAdd(aRet, {nI, { oModelCabec:GetValue("C7_XSERIE"), oModelCabec:GetValue("C7_XDOC"), Soma1(cValToChar(nI-1),1),"NFE", U_DTFORNFIX(aVenc[nI][1],cCond), aVenc[nI][2]}})
		Next nI
	else
		aAreaAnt := GetArea()
		DbSelectArea("SE2")
		SE2->(DbSetOrder(6))
		cChavE2 := XFilial("SE2") + SC7->(C7_FORNECE + C7_LOJA + C7_XSERIE + C7_XDOC)
		SE2->(DbSeek(cChavE2))
		While SE2->(!Eof()) .And. SE2->E2_FILIAL + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM == cChavE2
			aAdd(aRet, {nI, { SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA,SE2->E2_TIPO, SE2->E2_VENCTO, SE2->E2_VALOR}})
			SE2->(DbSkip())
		End
		RestArea(aAreaAnt)
	endif
Return aRet


/*/{Protheus.doc} SaveModel
Gravação do modelo de dados.
@author 	alexandre.arume
@since 		24/08/2016
@version 	1.0
@param 		oModel, Modelo de dados.
@Project	MAN00000462901_EF_004
@return ${lRet}, Status da operação.
/*/
Static Function SaveModel(oModel)

	Local lRet 	 		:= .T.
	Local oMdlDetail 	:= oModel:GetModel("GRID")
	Local nI 			:= 0
	Private aValores 	:= {}

	if _nOpcao == MODEL_OPERATION_INSERT
		If oModel:VldData()
			For nI := 1 To oMdlDetail:Length()
				oMdlDetail:GoLine(nI)
				aAdd( __ADTVENCTO, {oMdlDetail:GetValue("XXVENCREA"), oMdlDetail:GetValue("XXVALOR")})
			Next nI
		EndIf
		//oModel:DeActivate()
	endif
Return lRet
