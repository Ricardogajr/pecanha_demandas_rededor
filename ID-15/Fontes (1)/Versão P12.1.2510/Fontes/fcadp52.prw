#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Variáveis Estáticas
Static cTitulo := "Cadastro de Amarração Centro de custo x Filial"

/*/{Protheus.doc} zMVCMd3
Rotina responsável pelo cadastro de centro de custo x filial
@type function
@version P122410 
@author Ricardo Junior
@since 12/23/2025
@return variant, nulo
/*/ 
User Function FCADP52()
	Local aArea   := GetArea()
	Local oBrowse

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("CTT")
	oBrowse:SetDescription(cTitulo)
	oBrowse:DisableDetails()
	
	oBrowse:SetFilterDefault("CTT->CTT_BLOQ = '2'")
	oBrowse:Activate()

	RestArea(aArea)
Return Nil
/*/{Protheus.doc} MenuDef
MenuDef
@type function
@version P122410  
@author Ricardo Junior
@since 12/23/2025
@return variant, aRot
/*/
Static Function MenuDef()
	Local aRot := {}


	
	Aadd(aRot , {"Manutenção"    ,'U_XCADP52(4)'       , 0, 6})
	Aadd(aRot , {"Selecione"    , 'U_P52SELCC()'       , 0, 6})
	Aadd(aRot , {"Carga"    , 'U_FCARP52()'        , 0, 6})
	Aadd(aRot , {"Excluir"    , 'U_XCADP52(5)'        , 0, 6})
	
	
	
	
	

Return aRot

/*/{Protheus.doc} ModelDef
ModelDef
@type function
@version P122410  
@author Ricardo Junior
@since 12/23/2025
@return variant, oModel
/*/
Static Function ModelDef()
	Local oModel         := Nil
	Local oStPai       := FWFormStruct(1, 'P52', {|x| AllTrim(x)   + "|" $  "P52_FILIAL|P52_CC|P52_DESCC|"  })
	Local oStFilho     := FWFormStruct(1, 'P52', {|x| !AllTrim(x)  + "|" $  ""  })

	oModel := MpFormModel():New("MFCAD52", /*{|oModel| IsOpenModel(oModel)}*/ , /*{|oModel| /*IsValidModel(oModel)}*/, {|oModel| SaveModel(oModel)}, /*{|oModel| CancelModel(oModel)}*/)

	aP52FilNm := FwStruTrigger("P52_FILCC", "P52_NOMFIL", "FWFilName(cEmpAnt,M->P52_FILCC)", .F., "SM0",,,)
	oStFilho:AddTrigger(aP52FilNm[1], aP52FilNm[2], aP52FilNm[3], aP52FilNm[4])

	aP52Gree := FwStruTrigger("P52_FILCC", "P52_FILGRE", 'iif(ExistcPo("P53", FwFldGet("P52_FILCC")),"1","2")', .F., "SM0",,,)
	oStFilho:AddTrigger(aP52Gree[1], aP52Gree[2], aP52Gree[3], aP52Gree[4])

	bLinePost := {|oModel| PosVldLine(oModel)}
	//bLinePre  := {|oModel| PreVldLine(oModel)}
	oModel:AddFields('P52MASTER',/*cOwner*/,oStPai)
	oModel:AddGrid('P52DETAIL','P52MASTER',oStFilho, /*bLinePre*/, /*bLinePost*/,,bLinePost,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence

	oModel:SetRelation('P52DETAIL', {{'P52_FILIAL','xFilial("P52")'},{'P52_CC', 'P52_CC'}} , P52->(IndexKey(3))) //IndexKey -> quero a ordenação e depois filtrado
	oModel:SetPrimaryKey({'xFilial("P52")','P52_CC','P52_FILCC'})
	oModel:GetModel('P52DETAIL'):SetUniqueLine({'P52_FILCC'})    //Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}

	//Setando as descrições
	oModel:SetDescription("Amarração Centro de Custo x Filial")
	oModel:GetModel('P52MASTER'):SetDescription('Centro de Custo')
	oModel:GetModel('P52DETAIL'):SetDescription('Filiais')

Return oModel

/*/{Protheus.doc} ViewDef
ViewDef
@type function
@version P122410 
@author Ricardo Junior
@since 12/23/2025
@return variant, oView
/*/ 
Static Function ViewDef()
	Local oView        := Nil
	Local oModel        := FWLoadModel('FCADP52')
	Local oStPai       := FWFormStruct(2, 'P52', {|x| AllTrim(x)  + "|"  $ "P52_CC|P52_DESCC|"  })
	Local oStFilho     := FWFormStruct(2, 'P52', {|x| !AllTrim(x)  + "|"  $ "P52_CC|P52_DESCC|"  })

	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField('VIEW_P52',oStPai,'P52MASTER')
	oView:AddGrid('VIEW_P52G',oStFilho,'P52DETAIL')

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',20)
	oView:CreateHorizontalBox('GRID',80)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_P52','CABEC')
	oView:SetOwnerView('VIEW_P52G','GRID')

	//Habilitando título
	oView:EnableTitleView('VIEW_P52','Centro de custo')
	oView:EnableTitleView('VIEW_P52G','Filiais')
Return oView

/*/{Protheus.doc} PosVldLine
Valida Linha
@type function
@version P122410 
@author Ricardo Junior
@since 1/5/2026
@param oModel, object, Modelo
@return variant, True or False
/*/
static function PosVldLine(oModel)
	Local lOk := .T.
	Local cDtTime    := DToS(Date())+Space(1)+Time()
	Local nX := 0

	For nX := 01 To oModel:Length()
		oModel:GoLine(nX)

		if Empty(FWFLDGet("P52_XUSRIN"))
			FwFldPut("P52_XUSRIN", cDtTime)
		endif

		if oModel:IsUpdated() .Or. oModel:IsInserted()
			FwFldPut("P52_XUSRAL", cDtTime)
			FwFldPut("P52_XUSR", UsrRetName(getCodUsr()))
		endif

		if !FWFilExist(cEmpAnt, FwFldGet("P52_FILCC"))
			FWAlertHelp("Atenção", "Filial "+FwFldGet("P52_FILCC")+" não existe!")
			lOk := .F.
		endif
	Next nX
return lOk

Static function getCodUsr()
return RetCodUsr()

/*/{Protheus.doc} SaveModel
Salva modelo
@type function
@version P122410 
@author Ricardo Junior
@since 1/5/2026
@param oModel, object, model
@return variant, true or false
/*/
static function SaveModel(oModel)
	Local lOk := .T.	
	FwFormCommit(oModel, , {|oModel,cID,cAlias| .T.})
return lOk

/*/{Protheus.doc} XCADP52
Posiciona registro e executa view
@type function
@version P122410 
@author Ricardo Junior
@since 1/5/2026
@return variant, executa viewer
/*/
User function XCADP52(nOper)

	DbSelectArea("P52")
	P52->(DbSetOrder(3))
	if !DbSeek(xFilial("P52")+CTT->CTT_CUSTO)
		Reclock("P52",.T.)
		P52->P52_CC := CTT->CTT_CUSTO
		P52->P52_ATIVO := "1"
		P52->(MsUnlock())
	endif
	
Return FWExecView( iif(nOper==4,"Inclusão","Exclusão") + " da amarração Centro de custo x Filial", "VIEWDEF.FCADP52", nOper)
