#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

/*
{Protheus.doc} F1301110()
Historico das Substituições
@Author     Bruno de Oliveira
@Since      22/11/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_011
*/
User Function F1301110()

	Local aRotina := MenuDef()
	
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("PAK")
	oMBrowse:SetDescription("Histórico da Operação do Substituto")
	oMBrowse:SetMenuDef("F1301110")
	oMBrowse:SetCacheView( .F. )
	oMBrowse:Activate()

Return

/*
{Protheus.doc} MenuDef()
Menu do Historico
@Author     Bruno de Oliveira
@Since      22/11/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_011
*/
Static Function MenuDef()
	
	Local aRotina := {}
	
	aAdd( aRotina, { 'Consultar'    , 'VIEWDEF.F1301110'                , 0, 2, 0, NIL } )
	
Return aRotina

/*
{Protheus.doc} ModelDef()
Modelo de dados do histórico de substituição
@Author     Bruno de Oliveira
@Since      22/11/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_011
@Return		oModel, Modelo de dados
*/
Static Function ModelDef()
	
	Local oModel
	Local oStrPAK := FwFormStruct(1, "PAK")	
	
	oModel := MPFormModel():New("MD131110", /*bPreMd*/ , /*bPosMd*/ , /*bCommitMd*/, /*bCancel*/ )
	
	oModel:SetDescription("Historico de Substituição")
	
	oModel:AddFields("PAKMASTER", /*cOwner*/, oStrPAK)
	
	oModel:SetPrimaryKey({"PAK_FILIAL","PAK_CODSOL","PAK_FILSUB","PAK_MATSUB"})
	
Return oModel

/*
{Protheus.doc} ViewDef()
Interface do histórico de substituição
@Author     Bruno de Oliveira
@Since      22/11/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_011
@Param		oView, interface
*/
Static Function ViewDef()
	
	Local oModel := FWLoadModel('F1301110')
	Local oStrPAK := FWFormStruct(2, "PAK")
	Local oView	:= FWFormView():New()
	
	oView:SetModel(oModel)
	oView:AddField("VIEW_PAK", oStrPAK, 'PAKMASTER')
	
	oView:CreateHorizontalBox("TOP", 100)
	
	oView:SetOwnerView("VIEW_PAK", "TOP")
	
Return oView

/*
{Protheus.doc} F1301111()
Gravação do Histórico
@Author     Bruno de Oliveira
@Since      22/11/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_011
@Param		cFilSol, Filial da solicitação
@Param		cCodSol, Código da solicitação
@Param		cOper, operação realizada
*/
User Function F1301111(cFilSol,cCodSol,cOper)

	Local aArea := RH3->(GetArea())
	
	DbSelectArea("RH3")
	DbSetOrder(1)
	If RH3->(DbSeek(cFilSol+cCodSol))
		
		aRet := FsRetPost(RH3->RH3_FILAPR,RH3->RH3_MATAPR)
	
		RecLock("PAK",.T.)
		PAK->PAK_FILPOS := aRet[1]
		PAK->PAK_CODPOS := aRet[2]
		PAK->PAK_FILSUB := RH3->RH3_FILAPR
		PAK->PAK_MATSUB := RH3->RH3_MATAPR
		PAK->PAK_NOMSUB := Posicione("SRA",1,RH3->RH3_FILAPR+RH3->RH3_MATAPR,"RA_NOME")
		PAK->PAK_FILSOL := RH3->RH3_FILIAL
		PAK->PAK_CODSOL := RH3->RH3_CODIGO
		PAK->PAK_TPSOL  := RH3->RH3_XTPCTM
		PAK->PAK_TPSOLN := Posicione("PA7",1,xFilial("PA7")+RH3->RH3_XTPCTM,"PA7_DESCR")
		PAK->PAK_DTOPER := dDatabase
		PAK->PAK_HROPER := SubStr(Time(),1,5)
		PAK->PAK_FILSBD := RH3->RH3_XFILSU
		PAK->PAK_MATSBD := RH3->RH3_XMATSU
		PAK->PAK_NOMSBD := Posicione("SRA",1,RH3->RH3_XFILSU+RH3->RH3_XMATSU,"RA_NOME")
		PAK->PAK_OPERAC := IIF(ValType(cOper) == "N", cValToChar(cOper), cOper)
		PAK->(MsUnLock())
	EndIf
	
	RestArea(aArea)

Return

/*
{Protheus.doc} FsRetPost()
Retorno do posto do substituto
@Author     Bruno de Oliveira
@Since      22/11/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_011
@Param		cFilApr, Filial do substituto
@Param		cMatApr, Matricula do substituto
*/
Static Function FsRetPost(cFilApr,cMatApr)

	Local cQuery := ""
	Local cAlias1 := GetNextAlias()
	Local cFilPost := ""
	Local cCodPost := ""
	
	cQuery += "SELECT RCX_FILIAL, RCX_POSTO "
	cQuery += "FROM " + RetSqlName("RCX") + " "
	cQuery += "WHERE "
	cQuery += "RCX_FILFUN = '" + cFilApr + "' AND "
	cQuery += "RCX_MATFUN = '" + cMatApr + "' AND "
	cQuery += "RCX_SUBST = '2' AND D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAlias1)
				
	If (cAlias1)->(!EOF())
		cFilPost := (cAlias1)->RCX_FILIAL
		cCodPost := (cAlias1)->RCX_POSTO
	EndIf

Return {cFilPost,cCodPost}
