#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} F1300102
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 02/10/2017
@version 6
@project MAN0000007423048_EF_001
@type function
/*/
user function F1300102()
	
return

/*/{Protheus.doc} FSRCL3
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 02/10/2017
@version 6
@project MAN0000007423048_EF_001
@type function
/*/
User Function FSRCL3()
	Local lRet       := .F.
	Local oLayer     := FWLayer():new()
	Local aBrowse    := {}
	Local aFieFilter := {}
	Local aStru      := {}
	Local aCampos    := {}
	Local aColumns   := {}
	Local nFor       := 0
	Local cPerg      := ""
	
	If FWIsInCallStack("U_F1300101")
		cPerg      := Padr("FSW1300101",10)
	ElseIf FWIsInCallStack("U_F1300201")
		cPerg      := Padr("FSW1300201",10)
	ElseIf FWIsInCallStack("U_F1300301")
		cPerg      := Padr("FSW1300301",10)
	EndIf
	
	MakeSqlExpr( cPerg )
	
	cAliasF3	:= GetNextAlias()
	
	cQuery := " SELECT RCL.RCL_FILIAL,RCL.RCL_POSTO,RCL.RCL_DEPTO,RCL.RCL_CARGO, RCL.R_E_C_N_O_ RECNO  "
	cQuery += " FROM "+RetSQLName("RCL") + " RCL"
	cQuery += " WHERE RCL.D_E_L_E_T_ = ' ' "
	If !(EMPTY(MV_PAR02))
		cFilRcl := MV_PAR02
		If "RA_FILIAL" $ cFilRcl
			cFilRcl := STRTRAN(cFilRcl, "RA_FILIAL", "RCL_FILIAL")
		EndIf
		cQuery += " AND " + cFilRcl + ""
			
	EndIf
	cQuery += " ORDER BY RCL.RCL_FILIAL,RCL.RCL_POSTO "
	
	cQuery := ChangeQuery(cQuery)
	
	DEFINE MSDIALOG oDlg FROM 0,0 TO 500,800 TITLE OemToAnsi("Consulta Padrão") PIXEL OF oMainWnd
	oLayer:init(oDlg,.F., .T.)
	
	oLayer:addLine('Sup',80,.F.)
	oLayer:addLine('Inf',90,.F.)
	oLayer:addCollumn('Col',100,.F.,'Sup')
	oLayer:addCollumn('Col',100,.F.,'Inf')
	
	oLayer:addWindow('Col','Browse' ,''	,100,.T.,.F.,{|| /*"Clique janela 01!"*/ },'Sup',{|| /*"Janela 01 recebeu foco!"*/ })
	oLayer:addWindow('Col','Button' ,''	,100,.T.,.T.,{|| /*"Clique janela 02!"*/ },'Inf',{|| /*"Janela 02 recebeu foco!"*/ })
	
	oPanel1 	:= oLayer:GetWinPanel('Col','Browse','Sup')
	oPanel1:FreeChildren()
	oPanel2 	:= oLayer:GetWinPanel('Col','Button','Inf')
	oPanel2:FreeChildren()
	//Browse
	//
	//Monta colunas
	aAdd(aCampos, {"RCL_FILIAL"	,"Filial"		, "C"	, 08  , 	0 ,	"@!" })
	aAdd(aCampos, {"RCL_POSTO"  ,"Posto"		, "C"	, 08  , 	0 ,	"@!" })
	aAdd(aCampos, {"RCL_DEPTO"	,"Departamento"	, "C"	, 08  , 	0 ,	"@!" })
	
	For nFor := 1 To Len(aCampos)
		AAdd( aColumns, FWBrwColumn():New() )
		
		aColumns[Len(aColumns)]:SetData( &("{||" + aCampos[nFor][1] + "}") )
		aColumns[Len(aColumns)]:SetTitle( aCampos[nFor][2] )
		aColumns[Len(aColumns)]:SetType( aCampos[nFor][3] )
		aColumns[Len(aColumns)]:SetSize( aCampos[nFor][4] )
		aColumns[Len(aColumns)]:SetDecimal( aCampos[nFor][5] )
		aColumns[Len(aColumns)]:SetPicture( aCampos[nFor][6] )
	Next nFor
	
	oBrowse 	:= FWBrowse():New()
	//oBrowse:SetDataTable()
	oBrowse:SetDataQuery(.T.)
	oBrowse:SetQuery(cQuery)
	oBrowse:SetAlias(cAliasF3)
	oBrowse:SetOwner(oPanel1)
	oBrowse:SetDescription("Consulta Padrão")
	oBrowse:SetColumns( aClone(aColumns) )
	Aadd(aFieFilter,{'RCL_FILIAL', "Filial"		,'C', 08, 0,""})
	Aadd(aFieFilter,{'RCL_POSTO', "Posto"		,'C', 06, 0,""})
	Aadd(aFieFilter,{'RCL_DEPTO', "Descrição"	,'C', 30, 0,""})
			
	oBrowse:setFieldFilter(aFieFilter)
	
	// Habilita/Desabilita opções de Salvar, Imprimir, etc.
	oBrowse:SetUseFilter() // Habilita a utilização do Filtro de registros
	oBrowse:SetLocate() // Habilita a Localização de registros
	oBrowse:SetSeek() // Habilita a Pesquisa de registros
	
	oBrowse:Activate()
	
	TButton():New( 010, 002, "OK"			, oPanel2,{||OK(), lRet := .T.,oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 010, 052, "Visualizar" 	, oPanel2,{|| VisualF3(oBrowse) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 010, 102, "Cancelar"   	, oPanel2,{|| lRet := .F.,oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
        
	ACTIVATE MSDIALOG oDLG  CENTER
	
Return lRet


/*/{Protheus.doc} OK
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 02/10/2017
@version 6
@project MAN0000007423048_EF_001
@type function
/*/
Static Function OK()
	Local cAliasF3 := Alias()
	Private cFilRcl 		:= (cAliasF3)->RCL_FILIAL
	Private cPostoRcl		:= (cAliasF3)->RCL_POSTO
Return


/*/{Protheus.doc} VisualF3
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 02/10/2017
@version 6
@project MAN0000007423048_EF_001
@param oBrowse, object, descricao
@type function
/*/
Static Function VisualF3(oBrowse)
	Local cAliasF3		:= Alias()
	Local cFilRcl 		:= (cAliasF3)->RCL_FILIAL
	Local cPosRcl		:= (cAliasF3)->RCL_POSTO
	Private cCadastro	:= "RCL"
	
	DbSelectArea("RCL")
	RCL->(DbSetOrder(1))
	RCL->(DbSeek(cFilRcl + cPosRcl))
	AxVisual("RCL",RCL->(Recno()),2)
Return
 
 
/*/{Protheus.doc} FSRCL3R1
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 02/10/2017
@version 6
@project MAN0000007423048_EF_001
@type function
/*/
User Function FSRCL3R1()
Local cAliasF3 := Alias()
cPostoRcl := (cAliasF3)->RCL_POSTO
Return(cPostoRcl)


/*/{Protheus.doc} FSRCL3R2
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 02/10/2017
@version 6
@project MAN0000007423048_EF_001
@type function
/*/
User Function FSRCL3R2()
Return(cCodF3)