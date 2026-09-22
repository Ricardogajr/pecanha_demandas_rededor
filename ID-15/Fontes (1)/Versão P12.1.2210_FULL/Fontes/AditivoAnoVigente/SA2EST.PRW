#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FILEIO.CH'

static cAliCod
static cAliEst

/*/{Protheus.doc} SA2EST
//TODO Descrição auto-gerada.
@author Paulo D
@since 08/04/2021
@project DOR08203457
@type function
/*/
User Function SA2EST()
	Local aArea      := GetArea()
	Local lRet       := .F.
	Local oTela      := FWLayer():new()
	Local aBrowse    := {}
	Local aFieFilter := {}
	Local aStru      := {}
	Local aCampos    := {}
	Local aColumns   := {}
	Local nFor       := 0
	Local cPerg      := ""
	Local cAliCC2    := GetNextAlias()


	cQuery := "SELECT DISTINCT CC2.CC2_EST,CC2.CC2_XCODES"
	cQuery += "FROM "+RetSQLName("CC2") + " CC2 "
	cQuery += "WHERE CC2.D_E_L_E_T_ = ' ' "
		
	cQuery := ChangeQuery(cQuery)
	
	DEFINE MSDIALOG oDlg FROM 0,0 TO 500,800 TITLE OemToAnsi("Consulta Padrão") PIXEL OF oMainWnd
	oTela:init(oDlg,.F., .T.)
	
	oTela:addLine('Sup',80,.F.)
	oTela:addLine('Inf',90,.F.)
	oTela:addCollumn('Col',100,.F.,'Sup')
	oTela:addCollumn('Col',100,.F.,'Inf')
	
	oTela:addWindow('Col','Browse' ,''	,100,.T.,.F.,{|| /*"Clique janela 01!"*/ },'Sup',{|| /*"Janela 01 recebeu foco!"*/ })
	oTela:addWindow('Col','Button' ,''	,100,.T.,.T.,{|| /*"Clique janela 02!"*/ },'Inf',{|| /*"Janela 02 recebeu foco!"*/ })
	
	oPanel1 := oTela:GetWinPanel('Col','Browse','Sup')
	oPanel1:FreeChildren()

	oPanel2 := oTela:GetWinPanel('Col','Button','Inf')
	oPanel2:FreeChildren()

	aAdd(aCampos, {"CC2_EST",     "Estado",          "C", 02, 0, "@!"})
	aAdd(aCampos, {"CC2_XCODES", "Código do Estado", "C", 02, 0, "@!"})
	
	For nFor := 1 To Len(aCampos)
		AAdd( aColumns, FWBrwColumn():New() )
		
		aColumns[Len(aColumns)]:SetData( &("{||" + aCampos[nFor][1] + "}") )
		aColumns[Len(aColumns)]:SetTitle( aCampos[nFor][2] )
		aColumns[Len(aColumns)]:SetType( aCampos[nFor][3] )
		aColumns[Len(aColumns)]:SetSize( aCampos[nFor][4] )
		aColumns[Len(aColumns)]:SetDecimal( aCampos[nFor][5] )
		aColumns[Len(aColumns)]:SetPicture( aCampos[nFor][6] )
	Next nFor
	
	oBrowse := FWBrowse():New()

	oBrowse:SetDataQuery(.T.)
	oBrowse:SetQuery(cQuery)
	oBrowse:SetAlias(cAliCC2)
	oBrowse:SetOwner(oPanel1)
	oBrowse:SetDescription("Consulta Padrão")
	oBrowse:SetColumns( aClone(aColumns) )

	Aadd(aFieFilter,{'CC2_EST',    'Estado',           "C", 02, 0,""})
	Aadd(aFieFilter,{'CC2_XCODES', 'Código do Estado', "C", 02, 0,""})
			
	oBrowse:setFieldFilter(aFieFilter)
	
	oBrowse:SetUseFilter() 
	oBrowse:SetLocate() 
	oBrowse:SetSeek() 
	
	oBrowse:Activate()
	
	// Botões
	TButton():New( 010, 002, "OK"			, oPanel2,{|| OK(), lRet := .T.,oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 010, 102, "Cancelar"   	, oPanel2,{|| lRet := .F.,oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
        
	ACTIVATE MSDIALOG oDLG  CENTER

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} OK
Executa quandro clicado no ok da consulta
@author Paulo D
@since 08/04/2021
@project DOR08203457
@type function
/*/
Static Function OK()
	Local cAliCC2 := Alias()
	cAliEst	:= (cAliCC2)->CC2_EST
	cAliCod := (cAliCC2)->CC2_XCODES
Return

/*
@author Paulo D
@since 08/04/2021
@project DOR08203457
@type function
/*/
User Function SA2IBG1()
Return(cAliEst)

/*
@author Paulo D
@since 08/04/2021
@project DOR08203457
@type function
/*/
User Function SA2IBG2()
Return(cAliCod)
