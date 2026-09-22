#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*
{Protheus.doc} F0201104()
Tela MVC de cadastro dos subgrupos de produtos.
@Author     Robson William
@Since      02/05/2017
@Version    P12.7
@Project    MAN000000463301_AID_011_02
@Menu		Compras\Atualizacoes\Cadastros\[RDSL]-Amarração Tipo X Grupo X SubGrupo
*/

User Function F0201104()
	
	Local aArea   := GetArea()
	Local oBrowse
	
	Private cTitulo := "Amarração Tipo x Grupo x SubGrupo"
	Private __nVez  := 0

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SBM")
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetMenuDef("F0201104")
	oBrowse:Activate()
	
	RestArea(aArea)
Return Nil

Static Function MenuDef()
	
	Local aRot := {}
	
//	ADD OPTION aRot TITLE 'Visualizar'      ACTION 'VIEWDEF.F0201104'  OPERATION MODEL_OPERATION_VIEW ACCESS 0 //OPERATION 1
//	ADD OPTION aRot TITLE 'Inclui Tipo'     ACTION 'VIEWDEF.MATA035'   OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION X
//	ADD OPTION aRot TITLE 'Amarração'       ACTION 'VIEWDEF.F0201104'  OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
//	
//	
	
	Aadd(aRot , {"Visualizar"    , 'VIEWDEF.F0201104'        , 0, 1})
	Aadd(aRot , {"Inclui Tipo"    ,'VIEWDEF.MATA035'     , 0, 6})
	Aadd(aRot , {"Amarração"    ,'VIEWDEF.F0201104'         , 0, 4})
	
	

Return aRot

Static Function ModelDef()
	
	Local oModel      := Nil
	Local oStPai      := FWFormStruct(1, 'SBM')
	Local oStFilho    := FWFormStruct(1, 'P24', { |x| ALLTRIM(x) $ 'P24_FILIAL,P24_GRUPO,P24_DESGRU' } )
	Local oStNeto     := FWFormStruct(1, 'P25', { |x| ALLTRIM(x) $ 'P25_FILIAL,P25_SUBGRP,P25_DESCSU' } )
	Local aP24Rel     := {}
	Local aP25Rel     := {}
	Local bLine24Post := {|oGridModel, nLine, cAction| fLinePostGrid(oGridModel, nLine, cAction, "P24")}
	Local bLine25Post := {|oGridModel, nLine, cAction| fLinePostGrid(oGridModel, nLine, cAction, "P25")}
	Local bLine24Pre  := {|oGridModel, nLine, cAction| fLinePreGrid(oGridModel, nLine, cAction, "P24")}
	Local bLine25Pre  := {|oGridModel, nLine, cAction| fLinePreGrid(oGridModel, nLine, cAction, "P25")}

	oModel := MPFormModel():New('M0201104')
	oModel:AddFields('SBMMASTER',/*cOwner*/,oStPai)
	oModel:AddGrid('P24DETAIL','SBMMASTER',oStFilho,/*bLinePre*/bLine24Pre, /*bLinePost*/bLine24Post,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/, /*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
	oModel:AddGrid('P25DETAIL','P24DETAIL',oStNeto,/*bLinePre*/bLine25Pre, /*bLinePost*/bLine25Post,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/, /*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
	
	//Fazendo o relacionamento entre o Pai e Filho
	aAdd(aP24Rel, {'P24_FILIAL','BM_FILIAL'} )
	aAdd(aP24Rel, {'P24_TIPO' ,'BM_GRUPO'})
	
	//Fazendo o relacionamento entre o Filho e Neto
	aAdd(aP25Rel, {'P25_FILIAL','BM_FILIAL'} )
	aAdd(aP25Rel, {'P25_TIPO' ,'BM_GRUPO'} ) 
	aAdd(aP25Rel, {'P25_GRUPO' ,'P24_GRUPO'} ) 
	
	oModel:SetRelation('P24DETAIL', aP24Rel, P24->(IndexKey(1))) //IndexKey -> quero a ordenaééo e depois filtrado
	oModel:GetModel('P24DETAIL'):SetUniqueLine({"P24_FILIAL","P24_GRUPO"})	//não repetir informaéées ou combinaéées {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:SetPrimaryKey({})
	
	oModel:SetRelation('P25DETAIL', aP25Rel, P25->(IndexKey(1))) //IndexKey -> quero a ordenaééo e depois filtrado
	oModel:GetModel('P25DETAIL'):SetUniqueLine({"P25_FILIAL","P25_SUBGRP"})	//não repetir informaéées ou combinaéées {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:SetPrimaryKey({})
	
	oModel:SetDescription("Amarração Tipo x Grupo x SubGrupo")
    oModel:GetModel('SBMMASTER'):SetOnlyView()
	oModel:GetModel('SBMMASTER'):SetDescription('Tipo')
	oModel:GetModel('P24DETAIL'):SetDescription('Grupo')
	oModel:GetModel('P25DETAIL'):SetDescription('SubGrupo')
	oModel:GetModel('P25DETAIL'):SetOptional(.T.)
	oModel:GetModel('P24DETAIL'):SetOptional(.T.)

Return oModel

Static Function ViewDef()
	
	Local oView		:= Nil
	Local oModel	:= FWLoadModel('F0201104')
	Local oStPai	:= FWFormStruct(2, 'SBM')
	Local oStFilho	:= FWFormStruct(2, 'P24', { |x| ALLTRIM(x) $ 'P24_FILIAL,P24_GRUPO,P24_DESGRU' } )
	Local oStNeto	:= FWFormStruct(2, 'P25', { |x| ALLTRIM(x) $ 'P25_FILIAL,P25_SUBGRP,P25_DESCSU' } )

	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:AddField('VIEW_SBM',oStPai,'SBMMASTER')
	oView:AddGrid('VIEW_SP24',oStFilho,'P24DETAIL')
	oView:AddGrid('VIEW_SP25',oStNeto,'P25DETAIL')
	
	oView:CreateHorizontalBox('CABEC',33)
	oView:CreateHorizontalBox('GRID',33)
	oView:CreateHorizontalBox('GRID2',33)
	
	oView:SetOwnerView('VIEW_SBM','CABEC')
	oView:SetOwnerView('VIEW_SP24','GRID')
	oView:SetOwnerView('VIEW_SP25','GRID2')
	
	oView:EnableTitleView('VIEW_SBM','Tipo')
	oView:EnableTitleView('VIEW_SP24','Grupo')
	oView:EnableTitleView('VIEW_SP25','SubGrupo')

Return oView

Static Function fLinePreGrid(oGridModel, nLine, cAction, cAlias)
	
	Local cConteudo	  := oGridModel:GetValueByPos(2, nLine)
	Local lRetorno    := .T.
	Local nI          := 0
	Local nTamGrid	  := oGridModel:GetQTDLine()

	Default cAlias    := "P24"

		If cAlias == "P24"
		 	If GrupoUsado(cConteudo)
				Alert("Este Grupo já foi associado a um produto e não pode ser alterado")
				//Help(,,'F02011042 - Grupo Inválido',,'Este Grupo já foi associado a um produto e não pode ser alterado.',1,0) 
				lRetorno := .F.
			EndIf
		ElseIf SubGrupoUsado(cConteudo)
			Alert("Este SubGrupo já foi associado a um produto e não pode ser alterado")
			//Help(,,'F02011043 - SubGrupo Inválido',,'Este SubGrupo já foi associado a um produto e não pode ser alterado.',1,0) 
			lRetorno := .F.
		EndIf

Return lRetorno

Static Function fLinePostGrid(oGridModel, nLine, cAction, cAlias)
	
	Local cConteudo	  := oGridModel:GetValueByPos(2, nLine)
	Local lRetorno    := .T.
	Local nI          := 0
	Local nTamGrid	  := oGridModel:GetQTDLine()

	Default cAlias    := "P24"

	If oGridModel:IsUpdated(nLine)
		For nI:=1 to nTamGrid
			If oGridModel:GetValueByPos(2, nI) == cConteudo .and. nI <> nLine
				Help(,,'F02011041 - Linha Duplicada',,'Este valor já foi informado. Informe um outro valor',1,0) 
				lRetorno := .F.
				Exit
			EndIf
		Next

		If lRetorno
			If cAlias == "P24"
				If ( ExisteGrupo(oGridModel,cConteudo) )
					Help(,,'F02011042 - Grupo Inválido',,'Este Grupo ('+cConteudo+') já foi associado a outro Tipo. Favor informar outro Grupo.',1,0) 
					lRetorno := .F.
				EndIf
			ElseIf ExisteSubGrupo(oGridModel, cConteudo) 
				Help(,,'F02011043 - SubGrupo Inválido',,'Este SubGrupo ('+cConteudo+')já foi associado a outro Grupo. Favor informar outro SubGrupo.',1,0) 
				lRetorno := .F.
			EndIf
		EndIf
	Else
		If Empty(cConteudo)
			RollBackSxe() //Vou assumir que o inicializador padrao esta configurado
		EndIf
	EndIf
	If lRetorno
		cConteudo := Alltrim(oGridModel:GetValueByPos(3, nLine))
		If Len(cConteudo) < 2
			Help(,,'F02011044 - Grupo sem Descrição.', , 'Campo Descrição do Grupo não está preenchido.', 1, 0, , , , , , {"Preencha o campo Descrição do Grupo."}) 
			lRetorno := .F.				
		EndIf

		//Forca a verificacao do NETO pois o usuario pode não preencher
		oModelSubGrupo := oGridModel:GetModel('M0201104')
		cConteudo := Alltrim(oModelSubGrupo:GetModel('P25DETAIL'):GetValueByPos(3, 1))
		If Len(cConteudo) < 2
			Help(,,'F02011044 - Subgrupo sem Descrição.', , 'Campo Descrição do Subgrupo não está preenchido.', 1, 0, , , , , , {"Preencha o campo Descrição do Subgrupo."}) 
			lRetorno := .F.				
		EndIf

	EndIf

Return lRetorno

Static Function ExisteGrupo(oGridModel,cGrupo)
	
	Local aP25Area   := P25->(GetArea())
	Local lRetorno   := .F.
 	
	P03->(DbSetOrder(1)) //P03_FILIAL+P03_GRUPO

	If P03->(DbSeek(XFilial("P03")+cGrupo))
		P25->(DbSetOrder(1)) //P25_FILIAL+P25_GRUPO+P25_SUBGRP
		If P25->(DbSeek(XFilial("P25")+cGrupo)) .And. P25->P25_TIPO <> SBM->BM_GRUPO
			lRetorno := .T.
		EndIf	
	EndIf

	RestArea(aP25Area)
Return lRetorno

Static Function ExisteSubGrupo(oGridModel, cSubGrupo)

	Local lRetorno    := .F.
	Local aP25Area    := P25->(GetArea())
	Local oModelGrupo := oGridModel:GetModel('M0201104')
	Local nLinhaP24   := oModelGrupo:GetModel('P24DETAIL'):GetLine()
	Local cGrupo      := oModelGrupo:GetModel('P24DETAIL'):GetValueByPos(2, nLinhaP24)

	P04->(DbSetOrder(1)) //P04_FILIAL+P04_SUBGRP
	If P04->(DbSeek(XFilial("P04") + cSubGrupo))
		P25->(DbSetOrder(2)) //P25_FILIAL+P25_SUBGRP+P25_GRUPO
		If P25->(DbSeek(XFilial("P25") + cSubGrupo)) .And. P25->P25_GRUPO <> cGrupo
			lRetorno := .T.
		EndIf	
	EndIf

   
	RestArea(aP25Area)

Return lRetorno

/*/{Protheus.doc} GrupoUsado(cCodigo)
	Verifica se o grupo que está sendo alterado ou deletado, está em uso no Cadastro de Produtos
	@type  Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@retorno: légico - Indica se o Grupo está em uso no SB1 (Cadastro de Produtos)
	/*/
Static Function GrupoUsado(cCodigo)
	Local lRetorno := .F.
	Local cAlias01 := GetNextAlias()
				
	BeginSql Alias cAlias01
	
		%noparser%
		SELECT SB1.B1_COD FROM %table:SB1% SB1
		WHERE SB1.B1_FILIAL = %Exp:XFilial("SB1")%
		AND SB1.B1_XGRPPRO = %Exp:cCodigo%
		AND SB1.%NotDel%
	
	EndSql
	
	If (cAlias01)->(!Eof())
		lRetorno := .T.
	EndIf
	
	(cAlias01)->(DbCloseArea())

Return lRetorno

/*/{Protheus.doc} GrupoUsado(cCodigo)
	Verifica se o grupo que está sendo alterado ou deletado, está em uso no Cadastro de Produtos
	@type  Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@retorno: légico - Indica se o Grupo está em uso no SB1 (Cadastro de Produtos)
	/*/
Static Function SubGrupoUsado(cCodigo)
	Local lRetorno := .F.
	Local cAlias01 := GetNextAlias()
				
	BeginSql Alias cAlias01
	
		SELECT SB1.B1_COD FROM %table:SB1% SB1
		WHERE SB1.B1_FILIAL = %Exp:XFilial("SB1")%
		AND SB1.B1_XSUBGRP = %Exp:cCodigo%
		AND SB1.%NotDel%
	
	EndSql
	
	If (cAlias01)->(!Eof())
		lRetorno := .T.
	EndIf
	
	(cAlias01)->(DbCloseArea())

Return lRetorno


/*
{Protheus.doc} M0201104()
Ponto de Entrada MVC
@Author     Robson William
@Since      29/06/2017
@Version    P12.7
@Project    MAN000000463301_AID_011_02
*/
User Function M0201104()

	Local xRetorno   := .T.
	Local oObj       := ParamIxb[1]
	Local cIdPonto   := ParamIxb[2]
	Local cIdModel   := ParamIxb[3]
	Local cRetorno   := ""
	Local cCodigo    := ""
	Local cDescricao := ""
	Local oModelSubGrupo := oObj:GetModel('M0201104')
	Local oModelGrupo    := oObj:GetModel('M0201104')

	If cIdPonto == 'FORMLINEPOS'
	
		cCodigo    := oObj:GetValueByPos(2, PARAMIXB[4])
		cDescricao := oObj:GetValueByPos(3, PARAMIXB[4])

		If oObj:IsDeleted()
			If "P24" $ cIdModel
				P03->(DbSetOrder(1)) //P03_FILIAL+P03_GRUPO
				If PA3->(DbSeek(XFilial("PA3")+cCodigo))
					If !U_F0700007("F0201102", "FORMP03", {{"P03_GRUPO", cCodigo}, {"P03_DESC", cDescricao}}, 5, @cRetorno)
						Help(,,'F02011047 - Erro na Exclusão do cadastro de Grupos',,cRetorno,1,0)
						xRetorno := .F.
					EndIf
				EndIf
			ElseIf  "P25" $ cIdModel
				P04->(DbSetOrder(1)) //P04_FILIAL+P04_SUBGRP
				If PA4->(DbSeek(XFilial("PA4")+cCodigo))
					If !U_F0700007("F0201103", "FORMP04", {{"P04_SUBGRP", cCodigo}, {"P04_DESC", cDescricao}}, 5, @cRetorno)
						Help(,,'F02011048 - Erro na Exclusão do cadastro de Grupos',,cRetorno,1,0)
						xRetorno := .F.
					EndIf
				EndIf
			EndIf
		Else
			If "P24" $ cIdModel
				P03->(DbSetOrder(1)) //P03_FILIAL+P03_GRUPO
				If !P03->(DbSeek(XFilial("P03")+cCodigo))
					If !U_F0700007("F0201102", "FORMP03", {{"P03_GRUPO", cCodigo}, {"P03_DESC", cDescricao}}, 3, @cRetorno)
						Help(,,'F02011047 - Erro na gravação do cadastro de Grupos',,cRetorno,1,0)
						xRetorno := .F.
					EndIf
				EndIf
			ElseIf  "P25" $ cIdModel
				P04->(DbSetOrder(1)) //P04_FILIAL+P04_SUBGRP
				If !P04->(DbSeek(XFilial("P04")+cCodigo))
					If !U_F0700007("F0201103", "FORMP04", {{"P04_SUBGRP", cCodigo}, {"P04_DESC", cDescricao}}, 3, @cRetorno)
						Help(,,'F02011048 - Erro na gravação do cadastro de Grupos',,cRetorno,1,0)
						xRetorno := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	ElseIf cIdPonto == 'FORMPOS'
	    //oModelSubGrupo := oGridModel:GetModel('M0201104')
//		cConteudo := Alltrim(oModelSubGrupo:GetModel('P25DETAIL'):GetValueByPos(3, 1))
	    
//		cCodigo    := oObj:GetValueByPos(2, PARAMIXB[4])
//		cDescricao := oObj:GetValueByPos(3, PARAMIXB[4])

		If cIdModel $ "P24DETAIL|P25DETAIL" .And. oObj:IsDeleted()
			If "P24" $ cIdModel
				oModelGrupo    := oObj:GetModel('M0201104')

				cCodigo    := Alltrim(oModelGrupo:GetModel('P24DETAIL'):GetValueByPos(2, 1))
				cDescricao := Alltrim(oModelGrupo:GetModel('P24DETAIL'):GetValueByPos(3, 1))
              

			
				P03->(DbSetOrder(1)) //P03_FILIAL+P03_GRUPO
				If P03->(DbSeek(XFilial("P03")+cCodigo))
					If !U_F0700007("F0201102", "FORMP03", {{"P03_GRUPO", cCodigo}, {"P03_DESC", cDescricao}}, 5, @cRetorno)
						Help(,,'F02011047 - Erro na Exclusão do cadastro de Grupos',,cRetorno,1,0)
						xRetorno := .F.
					EndIf
				EndIf
			ElseIf  "P25" $ cIdModel
				oModelSubGrupo := oObj:GetModel('M0201104')			
				cCodigo    := Alltrim(oModelSubGrupo:GetModel('P25DETAIL'):GetValueByPos(2, 1))
				cDescricao := Alltrim(oModelSubGrupo:GetModel('P25DETAIL'):GetValueByPos(3, 1))
			
				P04->(DbSetOrder(1)) //P04_FILIAL+P04_SUBGRP
				If P04->(DbSeek(XFilial("P04")+cCodigo))
					If !U_F0700007("F0201103", "FORMP04", {{"P04_SUBGRP", cCodigo}, {"P04_DESC", cDescricao}}, 5, @cRetorno)
						Help(,,'F02011048 - Erro na Exclusão do cadastro de Grupos',,cRetorno,1,0)
						xRetorno := .F.
					EndIf
				EndIf
			EndIf
		EndIf		
	ElseIf cIdPonto == "FORMPRE"
		cCodigo    := oObj:GetValueByPos(2, PARAMIXB[4])
		cDescricao := oObj:GetValueByPos(3, PARAMIXB[4])

		If ValType(ParamIxb[5]) == "U"
			Return xRetorno
		Else
			If ParamIxb[5] $ "DELETE"
				If "P24" $ cIdModel
					If GrupoUsado(cCodigo)
						Help(,,"F02011045 - Exclusão não permitida",,"não é possível excluir este grupo pois o mesmo está em uso.",1,0)
						xRetorno := .F.
					Else
						oModelSubGrupo := oObj:GetModel('M0201104')
						oModelSubGrupo:GetModel('P25DETAIL'):DeleteLine()
					EndIf
				ElseIf "P25" $ cIdModel .And. SubGrupoUsado(cCodigo)
					Help(,,"F02011046 - Exclusão não permitida",,"não é possível excluir este subgrupo pois o mesmo está em uso.",1,0)
					xRetorno := .F.
				EndIf
			ElseIf ParamIxb[5] $ "UNDELETE"
				If "P24" $ cIdModel
					oModelSubGrupo := oObj:GetModel('M0201104')
					oModelSubGrupo:GetModel('P25DETAIL'):UndeleteLine()
				EndIf
			ElseIf ParamIxb[5] $ "UPDATE"
				If "P24" $ cIdModel .And. ExisteGrupo(oObj, cCodigo) //GrupoUsado(cCodigo)
					Help(,,"F02011045 - Alteraééo não permitida",,"não é possível alterar para este grupo pois o mesmo está já está associado é outro tipo.",1,0)
					xRetorno := .F.
				ElseIf "P25" $ cIdModel .And. ExisteSubGrupo(oObj, cCodigo)
					Help(,,"F02011046 - Alteraééo não permitida",,"não é possível alterar para este subgrupo pois o mesmo já está associado é outro grupo.",1,0)
					xRetorno := .F.
				EndIf								
			EndIf
		EndIf
	EndIf

Return xRetorno

