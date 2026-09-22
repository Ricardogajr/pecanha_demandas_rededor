#include "protheus.CH"
#include "TOTVS.CH"       
#INCLUDE 'FWMVCDEF.CH'

/*{Protheus.doc} F0702402
A rotina de manutenção de campos exclusivos por filial estará 
disponível em “Outras Ações” na rotina de Cadastro de Produto 
@author Alex Sandro
@since 08/02/2017
@type
@project MAN0000007423041_EF_024
*/
User Function F0702402()          

	Local aGroups := UsrRetGrp(RetCodUsr())
	Local lBlqPer := .F.
	Local cBloqPer := SuperGetMv( "FS_BLOQPER" , .F. , "" )
	Local nLoop := 0

   AAdd( aRotina, { 'Tratamento por Filiais - Visualizar'	, 'VIEWDEF.F0702402', 0, 1 } )  
   AAdd( aRotina, { 'Tratamento por Filiais - Alterar   '	, 'VIEWDEF.F0702402', 0, 4 } )

    FOR nLoop := 1 TO LEN(aGroups)
    	IF aGroups[nLoop] $ cBloqPer
    		lBlqPer := .T.
    	EndIf
    Next

   IF FindFunction('U_F1207401') .AND. lBlqPer 
   AAdd( aRotina, { 'Bloq/Desbloq. Permanente Produto   '	, 'U_F1207401()', 0, 4 } )
   Endif
 
Return

/*{Protheus.doc} ModelDef
@author Alex Sandro
@since 08/02/2017
@project MAN0000007423041_EF_024
*/
Static Function ModelDef()
	Local oModel 		:= Nil
	Local oStPai 		:= FWFormStruct(1, 'SB1')
	Local oStFilho 		:= FWFormStruct(1, 'P17')
	Local aP17Rel		:= {}
    //Local bCommit       := {|| .T.}
    Local nCampo        := 0
    Local nQtdCampo     := 0
    Local aGatP30P31    := {}

//  Local   oNo       := LoadBitmap( GetResources(), "LBNO" )
//  Local   oOk       := LoadBitmap( GetResources(), "LBOK" )

    //Local aIndP17 := oStFilho:GetIndex()

    oModel := MPFormModel():New('M0702402',, {|oModel| IsValidModel(oModel)},)
	oModel:AddFields('SB1MASTER', , oStPai)

    oStFilho:AddField( ;
        AllTrim('') , ;                 // [01] C Titulo do campo
    AllTrim('Vermelho=Matriz, Verde=Filial') , ;               // [02] C ToolTip do campo
    'P17_LEGEND' , ;                // [03] C identificador (ID) do Field
    'C' , ;                         // [04] C Tipo do campo
    50 , ;                          // [05] N Tamanho do campo
    0 , ;                           // [06] N Decimal do campo
    NIL , ;                         // [07] B Code-block de validação do campo
    NIL , ;                         // [08] B Code-block de validação When do campo
    NIL , ;                         // [09] A Lista de valores permitido do campo
    NIL , ;                          // [10] L Indica se o campo tem preenchimento obrigatório
    { || IIf( BuscaP30( P17->P17_FTRATA )='1'  , "BR_VERDE" , IF(BuscaP30( P17->P17_FTRATA )='2', "BR_VERMELHO", "BR_BRANCO" )) } , ;           // [11] B Code-block de inicializacao do campo
    NIL , ;                         // [12] L Indica se trata de um campo chave
    NIL , ;                         // [13] L Indica se o campo pode receber valor em uma operação de update.
    .T. )                           // [14] L Indica se o campo é virtual


    oStFilho:AddField( AllTrim('Código Matriz') , ; // [01] C Titulo do campo
    AllTrim('') , ;                                 // [02] C ToolTip do campo
    'P30_COD' , ;                                   // [03] C identificador (ID) do Field
    'C' , ;                                         // [04] C Tipo do campo
    10 , ;                                          // [05] N Tamanho do campo
    0 , ;                                           // [06] N Decimal do campo
    NIL , ;                                         // [07] B Code-block de validação do campo
    NIL , ;                                         // [08] B Code-block de validação When do campo
    NIL , ;                                         // [09] A Lista de valores permitido do campo
    NIL , ;                                         // [10] L Indica se o campo tem preenchimento obrigatório
    {||INIP3031(P17->P17_FTRATA)} , ;               // [11] B Code-block de inicializacao do campo
    .T. , ;                                         // [12] L Indica se trata de um campo chave
    NIL , ;                                         // [13] L Indica se o campo pode receber valor em uma operação de update.
    .T. )                                           // [14] L Indica se o campo é virtual

    aCampoP17   := RetCampos("P17")
    nQtdCampo   := Len(aCampoP17)

    For nCampo := 1 To nQtdCampo
        aGatP30P31 := Array(0)
        aGatP30P31 := FwStruTrigger(aCampoP17[nCampo], aCampoP17[nCampo], "U_F1206403('" + aCampoP17[nCampo] + "')", .F., "P17",,,)
        oStFilho:AddTrigger(aGatP30P31[1], aGatP30P31[2], aGatP30P31[3], aGatP30P31[4])
        aGatP30P31 := Nil
    Next nCampo

    oModel:AddGrid('P17DETAIL','SB1MASTER', oStFilho,, /*{|oModel| ReplicaMat(oModel)}bLinePost*/,, /*bPosVal*/)
	
	AAdd(aP17Rel, {'P17_COD', 'B1_COD'}) 
	
	oModel:SetRelation('P17DETAIL', aP17Rel, P17->(IndexKey(1)))
	oModel:GetModel('P17DETAIL'):SetUniqueLine({"P17_FILIAL","P17_COD", "P17_FTRATA"})

	oModel:SetDescription("Produto")
	oModel:GetModel('SB1MASTER'):SetDescription('Modelo Produto')
    oModel:GetModel('SB1MASTER'):SetOnlyView()
	oModel:GetModel('P17DETAIL'):SetDescription('Modelo Tratamento por Filiais')

	oStFilho:SetProperty( 'P17_FILIAL'	, MODEL_FIELD_WHEN, {||IIF(FwFldGet('B1_MSBLQL')='1',.F.,IIF(FwFldGet('P17_ESTOQ')='S',.F.,.T.))})
	oStFilho:SetProperty( 'P17_FTRATA'	, MODEL_FIELD_WHEN, {||IIF(FwFldGet('B1_MSBLQL')='1',.F.,IIF(FwFldGet('P17_ESTOQ')='S',.F.,.T.))})
//	oStFilho:SetProperty( 'P17_FATUR'	, MODEL_FIELD_WHEN, {||IIF(FwFldGet('B1_MSBLQL')='1',.F.,IIF(FwFldGet('P17_ESTOQ')='S',.F.,.T.))})	
//	oStFilho:SetProperty( 'P17_FATUR'	, MODEL_FIELD_WHEN, {||IIF(FwFldGet('B1_MSBLQL')='1',.F.,IIF(FwFldGet('P17_ESTOQ')='S',.F., U_F1206501(FwFldGet('P17_FTRATA')))})	// paulo

//  oStFilho:SetProperty( 'P17_ESTOQ' , MODEL_FIELD_WHEN, {|| IIf(FwFldGet('B1_MSBLQL')='1',.F.,.T.)})
    oStFilho:SetProperty( 'P17_ESTOQ'   , MODEL_FIELD_WHEN, {|| U_F1206402("P17_ESTOQ")}) 
//    oStFilho:SetProperty( 'P17_ESTOQ'   , MODEL_FIELD_WHEN, {|| U_F1206402("P17_ESTOQ") .AND. IIf(FwFldGet('B1_MSBLQL')='1',.F.,IIF(FwFldGet('P17_ESTOQ')='S',.F., U_F1206501(FwFldGet('P17_FTRATA'),FwFldGet('B1_COD'))))})

//  oStFilho:SetProperty( 'P17_BLOQ'	, MODEL_FIELD_WHEN, {|| U_F1206501(FwFldGet('P17_FTRATA'),FwFldGet('B1_COD'),'A')}) // ticket n° 10710218 -- gravação na SBZ quando desbloq da P17
    oStFilho:SetProperty( 'P17_BLOQ'	, MODEL_FIELD_WHEN, {|| U_F1206402("P17_BLOQ") .AND. IIF(FwFldGet('B1_MSBLQL')='1',.F.,IIF(FwFldGet('P17_ESTOQ')='S',.F., U_F1206501(FwFldGet('P17_FTRATA'),FwFldGet('B1_COD'))))})
    
//  oStFilho:SetProperty( 'P17_ATUAL'	, MODEL_FIELD_WHEN, {|| U_F1206402("P17_ESTOQ") .AND. IIF(FwFldGet('B1_MSBLQL')='1',.F.,IIF(FwFldGet('P17_ESTOQ')='S',.F.,.T.))})
//  oStFilho:SetProperty( 'P17_ATUAL'   , MODEL_FIELD_WHEN, {|| IIF(FwFldGet('P17_ESTOQ')='S', U_F1206402("P17_ATUAL"),IIf(FwFldGet('B1_MSBLQL')='1',.F.,.T.))})
    oStFilho:SetProperty( 'P17_ATUAL'   , MODEL_FIELD_WHEN, {|| U_F1206402("P17_ATUAL")})

//  oStFilho:SetProperty( 'P17_UM1'      , MODEL_FIELD_WHEN, {|| IIf(FwFldGet('B1_MSBLQL')='1',.F.,.T.) .And. U_F1206402("P17_UM1")})
//  oStFilho:SetProperty( 'P17_UM1'     , MODEL_FIELD_WHEN, {|| U_F1206402("P17_UM1") .AND. IIf(FwFldGet('B1_MSBLQL')='1',.F.,IIF(FwFldGet('P17_ESTOQ')='S',.F., U_F1206501(FwFldGet('P17_FTRATA'),FwFldGet('B1_COD'))))})
//  oStFilho:SetProperty( 'P17_UM1'     , MODEL_FIELD_WHEN, {|| IIF(FwFldGet('P17_ESTOQ')='S', U_F1206402("P17_UM1"),IIf(FwFldGet('B1_MSBLQL')='1',.F.,.T.))})
    oStFilho:SetProperty( 'P17_UM1'   , MODEL_FIELD_WHEN, {|| U_F1206402("P17_UM1")})

//  oStFilho:SetProperty( 'P17_CONV1'   , MODEL_FIELD_WHEN, {|| IIf(FwFldGet('B1_MSBLQL')='1',.F.,.T.) .And. U_F1206402("P17_CONV1")})
//  oStFilho:SetProperty( 'P17_CONV1'   , MODEL_FIELD_WHEN, {|| U_F1206402("P17_CONV1") .AND. IIf(FwFldGet('B1_MSBLQL')='1',.F.,IIF(FwFldGet('P17_ESTOQ')='S',.F., U_F1206501(FwFldGet('P17_FTRATA'),FwFldGet('B1_COD'))))})
//  oStFilho:SetProperty( 'P17_CONV1'   , MODEL_FIELD_WHEN, {|| IIF(FwFldGet('P17_ESTOQ')='S', U_F1206402("P17_CONV1"),IIf(FwFldGet('B1_MSBLQL')='1',.F.,.T.))})
    oStFilho:SetProperty( 'P17_CONV1'   , MODEL_FIELD_WHEN, {|| U_F1206402("P17_CONV1")})

//  oStFilho:SetProperty( 'P17_TPC1'    , MODEL_FIELD_WHEN, {|| IIf(FwFldGet('B1_MSBLQL')='1',.F.,.T.) .And. U_F1206402("P17_TPC1")})
//  oStFilho:SetProperty( 'P17_TPC1'    , MODEL_FIELD_WHEN, {|| U_F1206402("P17_TPC1") .AND. IIf(FwFldGet('B1_MSBLQL')='1',.F.,IIF(FwFldGet('P17_ESTOQ')='S',.F., U_F1206501(FwFldGet('P17_FTRATA'),FwFldGet('B1_COD'))))})
//  oStFilho:SetProperty( 'P17_TPC1'    , MODEL_FIELD_WHEN, {|| IIF(FwFldGet('P17_ESTOQ')='S', U_F1206402("P17_TPC1"),IIf(FwFldGet('B1_MSBLQL')='1',.F.,.T.))})
    oStFilho:SetProperty( 'P17_TPC1'   , MODEL_FIELD_WHEN, {|| U_F1206402("P17_TPC1")})

//  oStFilho:SetProperty( 'P17_UM2'     , MODEL_FIELD_WHEN, {|| IIf(FwFldGet('B1_MSBLQL')='1',.F.,.T.) .And. U_F1206402("P17_UM2")})
//  oStFilho:SetProperty( 'P17_UM2'     , MODEL_FIELD_WHEN, {|| U_F1206402("P17_UM2") .AND. IIf(FwFldGet('B1_MSBLQL')='1',.F.,IIF(FwFldGet('P17_ESTOQ')='S',.F., U_F1206501(FwFldGet('P17_FTRATA'),FwFldGet('B1_COD'))))})
//  oStFilho:SetProperty( 'P17_UM2'     , MODEL_FIELD_WHEN, {|| IIF(FwFldGet('P17_ESTOQ')='S', U_F1206402("P17_UM2"),IIf(FwFldGet('B1_MSBLQL')='1',.F.,.T.))})
    oStFilho:SetProperty( 'P17_UM2'   , MODEL_FIELD_WHEN, {|| U_F1206402("P17_UM2")})

//  oStFilho:SetProperty( 'P17_CONV2'   , MODEL_FIELD_WHEN, {|| IIf(FwFldGet('B1_MSBLQL')='1',.F.,.T.) .And. U_F1206402("P17_CONV2")})
//  oStFilho:SetProperty( 'P17_CONV2'   , MODEL_FIELD_WHEN, {|| U_F1206402("P17_CONV2") .AND. IIf(FwFldGet('B1_MSBLQL')='1',.F.,IIF(FwFldGet('P17_ESTOQ')='S',.F., U_F1206501(FwFldGet('P17_FTRATA'),FwFldGet('B1_COD'))))})
//  oStFilho:SetProperty( 'P17_CONV2'   , MODEL_FIELD_WHEN, {|| IIF(FwFldGet('P17_ESTOQ')='S', U_F1206402("P17_CONV2"),IIf(FwFldGet('B1_MSBLQL')='1',.F.,.T.))})
    oStFilho:SetProperty( 'P17_CONV2'   , MODEL_FIELD_WHEN, {|| U_F1206402("P17_CONV2")})
    
//  oStFilho:SetProperty( 'P17_TPC2'    , MODEL_FIELD_WHEN, {|| IIf(FwFldGet('B1_MSBLQL')='1',.F.,.T.) .And. U_F1206402("P17_TPC2")})
//  oStFilho:SetProperty( 'P17_TPC2'    , MODEL_FIELD_WHEN, {|| U_F1206402("P17_TPC2") .AND. IIf(FwFldGet('B1_MSBLQL')='1',.F.,IIF(FwFldGet('P17_ESTOQ')='S',.F., U_F1206501(FwFldGet('P17_FTRATA'),FwFldGet('B1_COD'))))})
//  oStFilho:SetProperty( 'P17_TPC2'    , MODEL_FIELD_WHEN, {|| IIF(FwFldGet('P17_ESTOQ')='S', U_F1206402("P17_TPC2"),IIf(FwFldGet('B1_MSBLQL')='1',.F.,.T.))})
    oStFilho:SetProperty( 'P17_TPC2'   , MODEL_FIELD_WHEN, {|| U_F1206402("P17_TPC2")})

//  oStFilho:SetProperty( 'P17_UM3'     , MODEL_FIELD_WHEN, {|| IIf(FwFldGet('B1_MSBLQL')='1',.F.,.T.) .And. U_F1206402("P17_UM3")})
//  oStFilho:SetProperty( 'P17_UM3'     , MODEL_FIELD_WHEN, {|| U_F1206402("P17_UM3") .AND. IIf(FwFldGet('B1_MSBLQL')='1',.F.,IIF(FwFldGet('P17_ESTOQ')='S',.F., U_F1206501(FwFldGet('P17_FTRATA'),FwFldGet('B1_COD'))))})
//  oStFilho:SetProperty( 'P17_UM3'     , MODEL_FIELD_WHEN, {|| IIF(FwFldGet('P17_ESTOQ')='S', U_F1206402("P17_UM3"),IIf(FwFldGet('B1_MSBLQL')='1',.F.,.T.))})
    oStFilho:SetProperty( 'P17_UM3'   , MODEL_FIELD_WHEN, {|| U_F1206402("P17_UM3")})

//  oStFilho:SetProperty( 'P17_CONSUM'  , MODEL_FIELD_WHEN, {|| IIf(FwFldGet('B1_MSBLQL')='1',.F.,.T.) .And. U_F1206402("P17_CONSUM")})
//  oStFilho:SetProperty( 'P17_CONSUM'  , MODEL_FIELD_WHEN, {|| U_F1206402("P17_CONSUM") .AND. IIf(FwFldGet('B1_MSBLQL')='1',.F.,IIF(FwFldGet('P17_ESTOQ')='S',.F., U_F1206501(FwFldGet('P17_FTRATA'),FwFldGet('B1_COD'))))})
//  oStFilho:SetProperty( 'P17_CONSUM'  , MODEL_FIELD_WHEN, {|| IIF(FwFldGet('P17_ESTOQ')='S', U_F1206402("P17_CONSUM"),IIf(FwFldGet('B1_MSBLQL')='1',.F.,.T.))})
    oStFilho:SetProperty( 'P17_CONSUM'   , MODEL_FIELD_WHEN, {|| U_F1206402("P17_CONSUM")})

//  oStFilho:SetProperty( 'P17_COMP'    , MODEL_FIELD_WHEN, {|| IIf(FwFldGet('B1_MSBLQL')='1',.F.,.T.) .And. U_F1206402("P17_COMP")})
//  oStFilho:SetProperty( 'P17_COMP'    , MODEL_FIELD_WHEN, {|| U_F1206402("P17_COMP") .AND. IIf(FwFldGet('B1_MSBLQL')='1',.F.,IIF(FwFldGet('P17_ESTOQ')='S',.F., U_F1206501(FwFldGet('P17_FTRATA'),FwFldGet('B1_COD'))))})
//  oStFilho:SetProperty( 'P17_COMP'    , MODEL_FIELD_WHEN, {|| IIF(FwFldGet('P17_ESTOQ')='S', U_F1206402("P17_COMP"),IIf(FwFldGet('B1_MSBLQL')='1',.F.,.T.))})
    oStFilho:SetProperty( 'P17_COMP'   , MODEL_FIELD_WHEN, {|| U_F1206402("P17_COMP")})

//  oStFilho:SetProperty( 'P17_P12FRO'  , MODEL_FIELD_WHEN, {|| IIf(FwFldGet('B1_MSBLQL')='1',.F.,.T.) .And. U_F1206402("P17_P12FRO")})
//  oStFilho:SetProperty( 'P17_P12FRO'  , MODEL_FIELD_WHEN, {|| U_F1206402("P17_P12FRO") .AND. IIf(FwFldGet('B1_MSBLQL')='1',.F.,IIF(FwFldGet('P17_ESTOQ')='S',.F., U_F1206501(FwFldGet('P17_FTRATA'),FwFldGet('B1_COD'))))})
//  oStFilho:SetProperty( 'P17_P12FRO'    , MODEL_FIELD_WHEN, {|| IIF(FwFldGet('P17_ESTOQ')='S', U_F1206402("P17_P12FRO"),IIf(FwFldGet('B1_MSBLQL')='1',.F.,.T.))})
    oStFilho:SetProperty( 'P17_P12FRO'   , MODEL_FIELD_WHEN, {|| U_F1206402("P17_P12FRO")})

//  oStFilho:SetProperty( 'P17_FROP12'  , MODEL_FIELD_WHEN, {|| IIf(FwFldGet('B1_MSBLQL')='1',.F.,.T.) .And. U_F1206402("P17_FROP12")})
//  oStFilho:SetProperty( 'P17_FROP12'  , MODEL_FIELD_WHEN, {|| U_F1206402("P17_FROP12") .AND. IIf(FwFldGet('B1_MSBLQL')='1',.F.,IIF(FwFldGet('P17_ESTOQ')='S',.F., U_F1206501(FwFldGet('P17_FTRATA'),FwFldGet('B1_COD'))))})
//  oStFilho:SetProperty( 'P17_FROP12'    , MODEL_FIELD_WHEN, {|| IIF(FwFldGet('P17_ESTOQ')='S', U_F1206402("P17_FROP12"),IIf(FwFldGet('B1_MSBLQL')='1',.F.,.T.))})
    oStFilho:SetProperty( 'P17_FROP12'   , MODEL_FIELD_WHEN, {|| U_F1206402("P17_FROP12")})

//  oStFilho:SetProperty( 'P17_FATUR'   , MODEL_FIELD_WHEN, {|| U_F1206402("P17_FATUR")}) 
//  oStFilho:SetProperty( 'P17_FATUR'   , MODEL_FIELD_WHEN, {|| U_F1206402("P17_FATUR") .AND. IIf(FwFldGet('B1_MSBLQL')='1',.F.,IIF(FwFldGet('P17_ESTOQ')='S',.F., U_F1206501(FwFldGet('P17_FTRATA'),FwFldGet('B1_COD'))))})
//  oStFilho:SetProperty( 'P17_FATUR'    , MODEL_FIELD_WHEN, {|| IIF(FwFldGet('P17_ESTOQ')='S', U_F1206402("P17_FATUR"),IIf(FwFldGet('B1_MSBLQL')='1',.F.,.T.))})
    oStFilho:SetProperty( 'P17_FATUR'   , MODEL_FIELD_WHEN, {|| U_F1206402("P17_FATUR")})
    oStFilho:SetProperty( 'P17_XBRASC'  , MODEL_FIELD_WHEN, {|| U_F1206402("P17_XBRASC")})
	oStFilho:SetProperty( 'P17_XSIMPC'  , MODEL_FIELD_WHEN, {|| U_F1206402("P17_XSIMPC")})


//Validação de Campo segundo P17 arvore
    //oStFilho:SetProperty( 'P17_ESTOQ' , MODEL_FIELD_VALID, {|| VldAltCmpo('P17_ESTOQ')})
/* ticket n° 11485301
    oStFilho:SetProperty( 'P17_BLOQ'    , MODEL_FIELD_VALID, {|| VldAltCmpo('P17_BLOQ')})
    oStFilho:SetProperty( 'P17_ATUAL'   , MODEL_FIELD_VALID, {|| VldAltCmpo('P17_ATUAL')})
    oStFilho:SetProperty( 'P17_UM1'     , MODEL_FIELD_VALID, {|| VldAltCmpo('P17_UM1')})
    oStFilho:SetProperty( 'P17_CONV1'   , MODEL_FIELD_VALID, {|| VldAltCmpo('P17_CONV1')})
    oStFilho:SetProperty( 'P17_TPC1'    , MODEL_FIELD_VALID, {|| VldAltCmpo('P17_TPC1')})
    oStFilho:SetProperty( 'P17_UM2'     , MODEL_FIELD_VALID, {|| VldAltCmpo('P17_UM2')})
    oStFilho:SetProperty( 'P17_CONV2'   , MODEL_FIELD_VALID, {|| VldAltCmpo('P17_CONV2')})
    oStFilho:SetProperty( 'P17_TPC2'    , MODEL_FIELD_VALID, {|| VldAltCmpo('P17_TPC2')})
    oStFilho:SetProperty( 'P17_UM3'     , MODEL_FIELD_VALID, {|| VldAltCmpo('P17_UM3')})
    oStFilho:SetProperty( 'P17_CONSUM'  , MODEL_FIELD_VALID, {|| VldAltCmpo('P17_CONSUM')})
    oStFilho:SetProperty( 'P17_COMP'    , MODEL_FIELD_VALID, {|| VldAltCmpo('P17_COMP')})
    oStFilho:SetProperty( 'P17_P12FRO'  , MODEL_FIELD_VALID, {|| VldAltCmpo('P17_P12FRO')})
    oStFilho:SetProperty( 'P17_FROP12'  , MODEL_FIELD_VALID, {|| VldAltCmpo('P17_FROP12')})
    oStFilho:SetProperty( 'P17_FATUR'   , MODEL_FIELD_VALID, {|| VldAltCmpo('P17_FATUR')})
*/
	oModel:GetModel('P17DETAIL'):SetNoInsertLine (.T.)
	oModel:GetModel('P17DETAIL'):SetNoDeleteLine (.T.)
    
Return oModel

/*{Protheus.doc} ViewDef
@author Alex Sandro
@since 08/02/2017
@project MAN0000007423041_EF_024
*/
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel		:= FWLoadModel('F0702402')
	Local oStPai		:= FWFormStruct(2, 'SB1', { |x| ALLTRIM(x) $ 'B1_COD, B1_DESC,B1_LOCPAD,B1_XBLOQ,B1_XFATURA,B1_UM,B1_CONV,B1_TIPCONV,B1_SEGUM,B1_XCONV2,B1_XTCONV2,B1_XTERUM,,B1_XESTOQ,B1_XCONSUM,B1_XCOMP,B1_XP12FRO,B1_XFROP12' })
	Local oStFilho		:= FWFormStruct(2, 'P17')
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_SB1',oStPai,'SB1MASTER')

    //  oView:SetViewProperty("oStFilho", "GRIDDOUBLECLICK", {{|oFormulario,cFieldName,nLineGrid,nLineModel| Iif(Alltrim(cFieldName) == "P17_LEGEND",TT002(),)}})

    oStFilho:AddField( ;                    // Ord. Tipo Desc.
    'P17_LEGEND'                    , ;     // [01]  C   Nome do Campo
    "00"                            , ;     // [02]  C   Ordem
    AllTrim( ''    )                , ;     // [03]  C   Titulo do campo
    AllTrim( '' )                   , ;     // [04]  C   Descricao do campo
    { 'Legenda' }                   , ;     // [05]  A   Array com Help
    'C'                             , ;     // [06]  C   Tipo do campo
    '@BMP'                          , ;     // [07]  C   Picture
    NIL                             , ;     // [08]  B   Bloco de Picture Var
    ''                              , ;     // [09]  C   Consulta F3
    .F.                             , ;     // [10]  L   Indica se o campo é alteravel
    NIL                             , ;     // [11]  C   Pasta do campo
    NIL                             , ;     // [12]  C   Agrupamento do campo
    NIL                             , ;     // [13]  A   Lista de valores permitido do campo (Combo)
    NIL                             , ;     // [14]  N   Tamanho maximo da maior opção do combo
    NIL                             , ;     // [15]  C   Inicializador de Browse
    .T.                             , ;     // [16]  L   Indica se o campo é virtual
    NIL                             , ;     // [17]  C   Picture Variavel
    Nil                             )       // [18]  L   Indica pulo de linha após o campo

    oStFilho:AddField( ;                    // Ord. Tipo Desc.
    'P30_COD'                       , ;     // [01]  C   Nome do Campo
    "25"                            , ;     // [02]  C   Ordem
    AllTrim( 'COD.P30'    )         , ;     // [03]  C   Titulo do campo
    AllTrim( '' )                   , ;     // [04]  C   Descricao do campo
    { 'CODIGO P30' }                , ;     // [05]  A   Array com Help
    'C'                             , ;     // [06]  C   Tipo do campo
    '@!'                            , ;     // [07]  C   Picture
    NIL                             , ;     // [08]  B   Bloco de Picture Var
    ''                              , ;     // [09]  C   Consulta F3
    .F.                             , ;     // [10]  L   Indica se o campo é alteravel
    NIL                             , ;     // [11]  C   Pasta do campo
    NIL                             , ;     // [12]  C   Agrupamento do campo
    NIL                             , ;     // [13]  A   Lista de valores permitido do campo (Combo)
    NIL                             , ;     // [14]  N   Tamanho maximo da maior opção do combo
    NIL                             , ;     // [15]  C   Inicializador de Browse
    .T.                             , ;     // [16]  L   Indica se o campo é virtual
    NIL                             , ;     // [17]  C   Picture Variavel
    Nil                             )       // [18]  L   Indica pulo de linha após o campo

    // MMT
    //oModel:GetModel('P17DETAIL'):RemoveField( 'P17_COD' )
    oStFilho:RemoveField('P17_COD')

	oView:AddGrid('VIEW_P17',oStFilho,'P17DETAIL')
	oView:CreateHorizontalBox('CABEC',30)
	oView:CreateHorizontalBox('GRID',70)
	oView:SetOwnerView('VIEW_SB1', 'CABEC')
	oView:SetOwnerView('VIEW_P17', 'GRID')
	oView:EnableTitleView('VIEW_SB1', 'Produto')
	oView:EnableTitleView('VIEW_P17', 'Tratamento por Filiais')
	oView:AddUserButton( 'Teste Conversão', 'Teste Conversão', { || U_F0702403() } )

    oView:SetViewProperty("VIEW_P17", "GRIDDOUBLECLICK", {{|oFormulario, cFieldName, nLineGrid, nLineModel| IIf(AllTrim(cFieldName) == "P17_LEGEND", Legenda(), .T.)}})

    // Criar um "box" horizontal para receber algum elemento da view
/*
    oView:CreateHorizontalBox( 'PAI', 2)
    oView:SetOwnerView('VIEW_P17','PAI')
    oView:EnableTitleView('VIEW_P17' , 'Descricao' )
    oView:SetViewProperty('VIEW_P17' , 'SETCOLUMNSEPARATOR', {3})

        //Criando grupos
    oStFilho:AddGroup( 'Matriz', 'Descrição'        , '', 1 )
    oStFilho:SetProperty( 'P30_COD' , MVC_VIEW_GROUP_NUMBER, 'Matriz' )
*/
    oView:SetAfterViewActivate({|| U_F0702406(oView)})

Return oView

/*/{Protheus.doc} RetCampos
Retorna os campos da estrutura conforme prefixo do alias informado.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@param      cPrefixo, character, prefixo da tabela
@return     aCampos, array contendo os campos retornados
/*/
Static Function RetCampos(cPrefixo)

    Local aCampos       := {}
    Local aP17Struct    := {}

    Local cCampos       := ""

    Local nCampoP17     := 0
    Local nQtdCmpP17    := 0

    cCampos     := "P17_FILIAL|P17_COD|P17_FTRATA|P17_NFILIA|P17_FILNOM|P17_XUSRIN|P17_XUSRAL|P17_XMIGLT|"

    aP17Struct := P17->(DbStruct())

    nQtdCmpP17 := Len(aP17Struct)
			
    For nCampoP17 := 1 To nQtdCmpP17
        If !(aP17Struct[nCampoP17][1] $ cCampos) .And. (cPrefixo)->(FieldPos(MudaPrefix(cPrefixo, aP17Struct[nCampoP17][1]))) > 0
            AAdd(aCampos, MudaPrefix(cPrefixo, aP17Struct[nCampoP17][1]))
		EndIf
    Next nCampoP17

Return aCampos

/*/{Protheus.doc} F1206402
Valida alteração do campo e filial de tratamento. Esta rotina está adaptada para ser executada em outras rotinas
ou validações da campos.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@param      cFilTrata, character, filial de tratamento
@param      cCampoP17, character, campo alterado
@return     lOk, se permite ou não alteração
/*/
User Function F1206402(cCampoP17, cFilTrata, lWebserv)

    Local aArea := {}

    Local lOk   := .T.

    Default cCampoP17   := ""
    Default cFilTrata   := ""
    Default lWebserv    := .F.

    aArea := {GetArea(), P30->(GetArea()), P31->(GetArea())}

    If Empty(cFilTrata)
        cFilTrata := FwFldGet("P17_FTRATA")
    EndIf

    P30->(DbSetOrder(2))
    P31->(DbSetOrder(2))

    //Caso seja matriz não é necessário validar o campo alterado
    If !(P30->(DbSeek(FwXFilial("P30") + cFilTrata)))
        //Caso não encontre a filial vinculada a uma matriz gera um erro
        If P31->(DbSeek(FwXFilial("P31") + cFilTrata))
            If &("P31->" + MudaPrefix("P31", cCampoP17)) == "2"
                lOk := .F.
                If !lWebserv
                    Help("", 1, "HELP", "Filial", "Não é permitido alterar o campo " + AllTrim(cCampoP17) + " diretamente nesta filial de tratamento.",;
                        1, 0,,,,,, {""})
                EndIf
            Else
                lOk := .T.
            EndIf
        EndIf
    Else
        lOk := .T.
    EndIf

    AEval(aArea, {|area| RestArea(area)})

Return lOk

/*/{Protheus.doc} F1206403
Função "gatilho" para replicar os dados da matriz em outras filiais.

@project
@type       Static Function
@author     Rafael Riego
@since      06/05/2018
@param      cMatriz, character, Matriz alterada que replicará os dados
@param      cProduto, character, Produto que alterado
@return     Nil
/*/
User Function F1206403(cCampo)

    Local aArea         := {}
    Local aCamposP31    := {}
    Local aSaveLines    := {}

    Local cMatriz       := ""

    Local nCampo        := 0
    Local nQtdCampos    := 0

    Local oModel        := Nil
    Local oModelP17     := Nil
    Local oView         := Nil

    Local xValor        := 0
    Local nLine         := 0

    aCamposP31 := RetCampos("P31")
    nQtdCampos := Len(aCamposP31)

    Default cCampo      := ReadVar()

    aArea := {GetArea(), P30->(GetArea()), P31->(GetArea()), P17->(GetArea())}

    oModel      := FwModelActive()
    oModelP17   := oModel:GetModel("P17DETAIL")

    oView       := FwViewActive()

    cMatriz     := oModelP17:GetValue("P17_FTRATA")
    cProduto    := oModelP17:GetValue("P17_COD")

    P30->(DbSetOrder(2))
    P31->(DbSetOrder(1))
    P17->(DbSetOrder(1))

    xValor  := oModelP17:GetValue(cCampo)
    nLine   := oModelP17:GetLine()

    If AllTrim(MudaPrefix("P31", cCampo)) <> "P31_CODFIL"
        If P17->(DbSeek(FwXFilial("P17") + cProduto + cMatriz))
            If P30->(DbSeek(FwXFilial("P30") + cMatriz)) .And. P30->P30_REPLIC == "1"
                aSaveLines  := FwSaveRows()
                If P31->(DbSeek (FwXFilial("P31") + P30->P30_COD))
                    While P31->(!(EoF())) .And. P31->P31_FILIAL == FwXFilial("P30") .And. P31->P31_COD == P30->P30_COD
                        If oModelP17:SeekLine({{"P17_FTRATA", P31->P31_CODFIL}})
                            If &("P31->" + MudaPrefix("P31", cCampo)) == "2"
                                oModelP17:LoadValue(cCampo, xValor)
                            EndIf
                        EndIf
                        P31->(DbSkip())
                    End
                    FwRestRows(aSaveLines)
                    oModelP17:GoLine(nLine)
	If oView != Nil
                        oView:Refresh("VIEW_P17")
                    EndIf
                EndIf
            EndIf
        EndIf
	EndIf

    AEval(aArea, {|area| RestArea(area)})

Return xValor

Static Function VldAltCmpo(cCmpP17)

    Local cFilLin   := ""

	Local lRet := .T.
	Local oMdl := FwModelActive()
	Local oMdlP17 := oMdl:GetModel("P17DETAIL")
	
    oMdlP17:GoLine(oMdlP17:GetLine())
	cFilLin := oMdl:GetValue("P17DETAIL","P17_FTRATA")
	
    If !(Empty(cFilLin))
        lRet := U_F1206402(cCmpP17, cFilLin)
	EndIf	

Return lRet 

Static Function MudaPrefix(cPrefixo, cCampo)

    cCampo := cPrefixo + SubStr(cCampo, 4)

Return cCampo

Static Function BuscaP30(cFilP17)

    Local aArea     := {}

    Local cMatriz   := .F.

    aArea := {GetArea(), P30->(GetArea()), P31->(GetArea())}

    P30->(DbSetOrder(2))
    P31->(DbSetOrder(2))
    If P30->(DbSeek(FwXFilial("P30") + cFilP17))
        cMatriz := "1"
    ElseIf P31->(DbSeek(FwXFilial("P31") + cFilP17))
        cMatriz := "2"
    Else
        cMatriz := "3"
    EndIf

    AEval(aArea, {|area| RestArea(area)})

Return cMatriz
	
Static Function IniP3031(cFilP17)
	
    Local aArea     := {}
			
    Local cMatriz   := ""

    P30->(DbSetOrder(2))
    P31->(DbSetOrder(2))
    If P30->(DbSeek(FwXFilial("P30") + cFilP17))
        cMatriz := P30->P30_COD + "P30"
    ElseIf P31->(DbSeek(xFilial("P31") + cFilP17))
        cMatriz := P31->P31_COD + "P31"
    Else
        cMatriz := "999999" + "999"
    EndIf

    AEval(aArea, {|area| RestArea(area)})

Return cMatriz

Static Function Legenda()

    // Cria a legenda que identifica a estrutura
    oLegend := FwLegend():New()

    // Adiciona descrição para cada legenda
    oLegend:Add( { || }, 'BR_VERDE'    , 'Matriz' )
    oLegend:Add( { || }, 'BR_VERMELHO' , 'Filial' )
    oLegend:Add( { || }, 'BR_BRANCO'   , 'Sem Amarração' )

    // Ativa a Legenda
    oLegend:Activate()

    // Exibe a Tela de Legendas
    oLegend:View()
                
Return .T.

/*/{Protheus.doc} F0702406
Ordena grid da View.

@project
@type       User Function
@author     Rafael Riego
@since      15/05/2019
@param      oView, object, objeto da view
@return     Nil
/*/
User Function F0702406(oView)

    Local aSaveRows := {}

    Local nLinha        := 0
    Local nMenor        := 0
    Local nModelLen     := 0
    Local nProxLinha    := 0

    Local oModel    := Nil
    Local oModelP17 := Nil

    oModel := FwModelActivate()

    If oModel != Nil .And. oView != Nil
        aSaveRows := FwSaveRows()

        oModelP17 := oModel:GetModel("P17DETAIL")

        //ordenação
        nModelLen   := oModelP17:Length()
        nLinha      := 0

        For nLinha := 1 To nModelLen - 1
            nMenor      := nLinha

            For nProxLinha := nLinha + 1 To nModelLen
                If oModelP17:GetValue("P30_COD", nProxLinha) < oModelP17:GetValue("P30_COD", nMenor)
                    nMenor := nProxLinha
        Endif
            Next nProxLinha

            oView:LineShift("P17DETAIL", nLinha, nMenor)
	
        Next nLinha

        FwRestRows(aSaveRows)
        oView:Refresh("VIEW_P17")
        oModelP17:GoLine(1)
    EndIf

Return Nil


Static Function IsValidModel(oModel)

	Local nOperation	:= oModel:GetOperation()
	Local oModelB1      := oModel:GetModel('SB1MASTER')
	Local oModelP17     := oModel:GetModel('P17DETAIL')
	Local lRet          := .T.

	If !Empty(oModelB1:GetValue("B1_XSIMPRO"))
		If oModelP17:Getvalue("P17_XSIMPC") == 0
            lRet := .F.
			Help(" ", 1, "Problema", , "O campo Conv Simpro deve ser preenchido quando o código Simpro é informado.", 1, 0, , , , , , {"Informe o valor de conversão no campo Conv Simpro"})
		EndIf
	ElseIf !Empty(oModelB1:GetValue("B1_XBRASIN"))
		If oModelP17:GetValue("P17_XBRASC") == 0
            lRet := .F.
			Help(" ", 1, "Problema", , "O campo Conv Brasind deve ser preenchido quando o código Brasindice é informado.", 1, 0, , , , , , {"Informe o valor de conversão no campo Conv Brasind"})
		EndIf
	EndIf

Return lRet
