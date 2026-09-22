#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} F0700701
Manutenï¿½ï¿½o do Fabricante 
@author Fernando Carvalho
@since 20/01/2017
@Project MAN0000007423041_EF_007
/*/
User Function F0700701()
	
	Local oBrowse := FWMBrowse():New()
	
	oBrowse:SetAlias('P13')
	oBrowse:SetDescription('Cadastro Fabricante')
	oBrowse:SetMenuDef('F0700701')
	oBrowse:Activate()

Return

Static Function MenuDef()
	
	Local aRotina := {}
	
	ADD OPTION aRotina Title 'Visualizar' 	Action 'VIEWDEF.F0700701' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Incluir' 		Action 'VIEWDEF.F0700701' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Alterar' 		Action 'VIEWDEF.F0700701' OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Excluir' 		Action 'VIEWDEF.F0700701' OPERATION 5 ACCESS 0

	

Return aRotina

Static Function ModelDef()
	
	Local oStruMod 	:= FWFormStruct(1,'P13')
	Local oModel	:= MPFormModel():New('M0700701',{ |oModel| F0700701A( oModel ) },{|oModel|PosVal(oModel)}) //Model com 7 caracteres

	oModel:AddFields('MASTER',, oStruMod)
	oModel:SetPrimaryKey({})
	oModel:SetDescription('Cadastro Fabricante')
	oModel:GetModel('MASTER'):SetDescription('Cadastro Fabricante')

Return oModel

Static Function ViewDef()

	Local oModel 	:= FWLoadModel('F0700701')
	Local oStruView := FWFormStruct(2,'P13')
	Local oView		:= FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField('VIEW_MASTER', oStruView, 'MASTER')
	oView:CreateHorizontalBox('SUPERIOR', 100 )
	oView:SetOwnerView('VIEW_MASTER', 'SUPERIOR')

Return oView

Static Function PosVal(oModel)

	Local lRet 		:= .T.
	Local oMod		:= oModel:GetModel('MASTER')
	Local aArea		:= GetArea()
	Local cAliasSB1 := GetNextAlias()
	Local cQuery	:= ""
	
	If oModel:GetOperation() == 5
		cQuery += " SELECT 				"	+ CRLF
		cQuery	+= " B1_COD, B1_DESC"	+ CRLF
		cQuery += " FROM " + RetSqlName("SB1") + " SB1"	+ CRLF
		cQuery += " WHERE"	+ CRLF
		cQuery += " B1_FILIAL ='" + xFILIAL("SB1") + "'"	+ CRLF
		cQuery += " AND B1_XCODFAB ='" + oMod:GetValue("P13_COD") + "'"	+ CRLF
		cQuery += " AND D_E_L_E_T_ =''"
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB1,.T.,.T.)
		
		If (cAliasSB1)->(! EOF())	
			Help("",1, "NÃO PERMITIDO!", "NÃO PERMITIDO" ,;
					"O Código do fabricante está sendo utilizado no Produto:" + CHR(13) + CHR(10) + ;
					"Código:   " + (cAliasSB1)->(B1_COD) + CHR(13) + CHR(10) + ;
					"Descrição:" + (cAliasSB1)->(B1_DESC) , 3, 0)
			
			lRet := .F.
		EndIf
	EndIf		

	RestArea(aArea)

Return lRet




/*/{Protheus.doc} F0700701A
Atualizaï¿½ï¿½o dos campos de integraï¿½ï¿½o Onergy
@author 	Jean.Silvano
@since 		02/10/2024
@Project	MAN00000462901_EF_004
/*/
Static Function F0700701A(oModel)
	Local _aArea := GetArea()
	Local _lRet := .T.
	Local oHeadModel := oModel:GetModel( 'MASTER' )
    Local IS_INSERT   := oModel:GetOperation() == MODEL_OPERATION_INSERT
    Local IS_UPDATE   := oModel:GetOperation() == MODEL_OPERATION_UPDATE

	if IS_INSERT .OR. IS_UPDATE
		oHeadModel:SetValue("P13_ZONERG", .T. )
		oHeadModel:SetValue("P13_ZINTOG", "1" )
	Endif

	RestArea(_aArea)

Return(_lRet)
