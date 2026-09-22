#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"

/*
{Protheus.doc} F0201106()
Consulta padrão Tipo/Grupo/Subgrupo.
@Author     Nairan
@Since      12/07/2017
@Version    P12.7
@Project    MAN000000463301_AID_011_02
*/

User Function F0201106()
	Local aBrowse 	:= {}
	Local cMat		:= ""
	Local cRetorno	:= ""	
	Local lRet		:= .F.
	Local oLayer 	:= FWLayer():new()

	Private aRotina := MenuDef() 
		
	oBrowse 	:= FWMBrowse():New()
	
	DEFINE MSDIALOG oDlg FROM 0,0 TO 500,800 TITLE OemToAnsi('Consulta Tipo/Grupo/Subgrupo.') PIXEL OF oMainWnd
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

	oBrowse:SetOwner(oPanel1)
	oBrowse:SetDescription("Consulta de SubGrupo")	
	oBrowse:SetAlias("P25")
	oBrowse:SetMenuDef("F0201106")
	oBrowse:SetOnlyFields({''})
	oBrowse:SetUseFilter( .T. )
	oBrowse:DisableReport() 
	oBrowse:DisableDetails()
	oBrowse:DisableConfig()

    oColumn := FWBrwColumn():New(); If( ValType() == "N" ); oColumn:SetAlign(); EndIf; If( ValType() == "N" ); oColumn:SetBackColor(); EndIf; If( ValType() == "C" ); oColumn:SetComment(); EndIf; If( ValType({||P25_SUBGRP}) == "B" ); oColumn:SetData({||P25_SUBGRP}); EndIf; If( ValType() == "N" ); oColumn:SetDecimal(); EndIf; If.F.; oColumn:SetDelete(.F.); EndIf; If.F.; oColumn:SetDetails(.F.); EndIf; If( ValType() == "B" ); oColumn:SetDoubleClick(); EndIf; If.F.; oColumn:SetEdit(.F.); EndIf; If( ValType() == "N" ); oColumn:SetForeColor(); EndIf; If( ValType() == "B" ); oColumn:SetHeaderClick(); EndIf; oColumn:SetOptions(); If( ValType() == "N" ); oColumn:SetOrder(); EndIf; If( ValType() == "C"); oColumn:SetPicture(); ElseIf( ValType() == "B"); oColumn:SetPicture(); EndIf; If( ValType() == "C" ); oColumn:SetReadVar(); EndIf; If( ValType(TamSX3("P25_SUBGRP")[1]) == "N" ); oColumn:SetSize(TamSX3("P25_SUBGRP")[1]); EndIf; If.F.; oColumn:SetImage(.F.); EndIf; If( ValType("Subgrupo") == "C" ); oColumn:SetTitle("Subgrupo"); Else; oColumn:SetTitle(" "); EndIf; If( ValType() == "C" ); oColumn:SetType(); EndIf; If( ValType() == "B" ); oColumn:SetValid(); EndIf; If( ValType(oBrowse) == "O" ); If ( oBrowse:ClassName() $ "FWBROWSE|FWFORMBROWSE|FWMBROWSE|FWMARKBROWSE" ); oBrowse:SetColumns({oColumn}); EndIf; EndIf
	oColumn := FWBrwColumn():New(); If( ValType() == "N" ); oColumn:SetAlign(); EndIf; If( ValType() == "N" ); oColumn:SetBackColor(); EndIf; If( ValType() == "C" ); oColumn:SetComment(); EndIf; If( ValType({||P25_DESCSU}) == "B" ); oColumn:SetData({||P25_DESCSU}); EndIf; If( ValType() == "N" ); oColumn:SetDecimal(); EndIf; If.F.; oColumn:SetDelete(.F.); EndIf; If.F.; oColumn:SetDetails(.F.); EndIf; If( ValType() == "B" ); oColumn:SetDoubleClick(); EndIf; If.F.; oColumn:SetEdit(.F.); EndIf; If( ValType() == "N" ); oColumn:SetForeColor(); EndIf; If( ValType() == "B" ); oColumn:SetHeaderClick(); EndIf; oColumn:SetOptions(); If( ValType() == "N" ); oColumn:SetOrder(); EndIf; If( ValType() == "C"); oColumn:SetPicture(); ElseIf( ValType() == "B"); oColumn:SetPicture(); EndIf; If( ValType() == "C" ); oColumn:SetReadVar(); EndIf; If( ValType(TamSX3("P25_DESCSU")[1]) == "N" ); oColumn:SetSize(TamSX3("P25_DESCSU")[1]); EndIf; If.F.; oColumn:SetImage(.F.); EndIf; If( ValType("Descrição") == "C" ); oColumn:SetTitle("Descrição"); Else; oColumn:SetTitle(" "); EndIf; If( ValType() == "C" ); oColumn:SetType(); EndIf; If( ValType() == "B" ); oColumn:SetValid(); EndIf; If( ValType(oBrowse) == "O" ); If ( oBrowse:ClassName() $ "FWBROWSE|FWFORMBROWSE|FWMBROWSE|FWMARKBROWSE" ); oBrowse:SetColumns({oColumn}); EndIf; EndIf
	oColumn := FWBrwColumn():New(); If( ValType() == "N" ); oColumn:SetAlign(); EndIf; If( ValType() == "N" ); oColumn:SetBackColor(); EndIf; If( ValType() == "C" ); oColumn:SetComment(); EndIf; If( ValType({||P25_GRUPO}) == "B" ); oColumn:SetData({||P25_GRUPO}); EndIf; If( ValType() == "N" ); oColumn:SetDecimal(); EndIf; If.F.; oColumn:SetDelete(.F.); EndIf; If.F.; oColumn:SetDetails(.F.); EndIf; If( ValType() == "B" ); oColumn:SetDoubleClick(); EndIf; If.F.; oColumn:SetEdit(.F.); EndIf; If( ValType() == "N" ); oColumn:SetForeColor(); EndIf; If( ValType() == "B" ); oColumn:SetHeaderClick(); EndIf; oColumn:SetOptions(); If( ValType() == "N" ); oColumn:SetOrder(); EndIf; If( ValType() == "C"); oColumn:SetPicture(); ElseIf( ValType() == "B"); oColumn:SetPicture(); EndIf; If( ValType() == "C" ); oColumn:SetReadVar(); EndIf; If( ValType(TamSX3("P25_GRUPO")[1]) == "N" ); oColumn:SetSize(TamSX3("P25_GRUPO")[1]); EndIf; If.F.; oColumn:SetImage(.F.); EndIf; If( ValType("Grupo") == "C" ); oColumn:SetTitle("Grupo"); Else; oColumn:SetTitle(" "); EndIf; If( ValType() == "C" ); oColumn:SetType(); EndIf; If( ValType() == "B" ); oColumn:SetValid(); EndIf; If( ValType(oBrowse) == "O" ); If ( oBrowse:ClassName() $ "FWBROWSE|FWFORMBROWSE|FWMBROWSE|FWMARKBROWSE" ); oBrowse:SetColumns({oColumn}); EndIf; EndIf
	oColumn := FWBrwColumn():New(); If( ValType() == "N" ); oColumn:SetAlign(); EndIf; If( ValType() == "N" ); oColumn:SetBackColor(); EndIf; If( ValType() == "C" ); oColumn:SetComment(); EndIf; If( ValType({||POSICIONE("P24",1,xFilial("P24")+P25->(P25_TIPO+P25_GRUPO),"P24_DESGRU")}) == "B" ); oColumn:SetData({||POSICIONE("P24",1,xFilial("P24")+P25->(P25_TIPO+P25_GRUPO),"P24_DESGRU")}); EndIf; If( ValType() == "N" ); oColumn:SetDecimal(); EndIf; If.F.; oColumn:SetDelete(.F.); EndIf; If.F.; oColumn:SetDetails(.F.); EndIf; If( ValType() == "B" ); oColumn:SetDoubleClick(); EndIf; If.F.; oColumn:SetEdit(.F.); EndIf; If( ValType() == "N" ); oColumn:SetForeColor(); EndIf; If( ValType() == "B" ); oColumn:SetHeaderClick(); EndIf; oColumn:SetOptions(); If( ValType() == "N" ); oColumn:SetOrder(); EndIf; If( ValType() == "C"); oColumn:SetPicture(); ElseIf( ValType() == "B"); oColumn:SetPicture(); EndIf; If( ValType() == "C" ); oColumn:SetReadVar(); EndIf; If( ValType(TamSX3("P24_DESGRU")[1]) == "N" ); oColumn:SetSize(TamSX3("P24_DESGRU")[1]); EndIf; If.F.; oColumn:SetImage(.F.); EndIf; If( ValType("Descrição") == "C" ); oColumn:SetTitle("Descrição"); Else; oColumn:SetTitle(" "); EndIf; If( ValType() == "C" ); oColumn:SetType(); EndIf; If( ValType() == "B" ); oColumn:SetValid(); EndIf; If( ValType(oBrowse) == "O" ); If ( oBrowse:ClassName() $ "FWBROWSE|FWFORMBROWSE|FWMBROWSE|FWMARKBROWSE" ); oBrowse:SetColumns({oColumn}); EndIf; EndIf
	oColumn := FWBrwColumn():New(); If( ValType() == "N" ); oColumn:SetAlign(); EndIf; If( ValType() == "N" ); oColumn:SetBackColor(); EndIf; If( ValType() == "C" ); oColumn:SetComment(); EndIf; If( ValType({||P25_TIPO}) == "B" ); oColumn:SetData({||P25_TIPO}); EndIf; If( ValType() == "N" ); oColumn:SetDecimal(); EndIf; If.F.; oColumn:SetDelete(.F.); EndIf; If.F.; oColumn:SetDetails(.F.); EndIf; If( ValType() == "B" ); oColumn:SetDoubleClick(); EndIf; If.F.; oColumn:SetEdit(.F.); EndIf; If( ValType() == "N" ); oColumn:SetForeColor(); EndIf; If( ValType() == "B" ); oColumn:SetHeaderClick(); EndIf; oColumn:SetOptions(); If( ValType() == "N" ); oColumn:SetOrder(); EndIf; If( ValType() == "C"); oColumn:SetPicture(); ElseIf( ValType() == "B"); oColumn:SetPicture(); EndIf; If( ValType() == "C" ); oColumn:SetReadVar(); EndIf; If( ValType(TamSX3("P25_TIPO")[1]) == "N" ); oColumn:SetSize(TamSX3("P25_TIPO")[1]); EndIf; If.F.; oColumn:SetImage(.F.); EndIf; If( ValType("Tipo") == "C" ); oColumn:SetTitle("Tipo"); Else; oColumn:SetTitle(" "); EndIf; If( ValType() == "C" ); oColumn:SetType(); EndIf; If( ValType() == "B" ); oColumn:SetValid(); EndIf; If( ValType(oBrowse) == "O" ); If ( oBrowse:ClassName() $ "FWBROWSE|FWFORMBROWSE|FWMBROWSE|FWMARKBROWSE" ); oBrowse:SetColumns({oColumn}); EndIf; EndIf
	oColumn := FWBrwColumn():New(); If( ValType() == "N" ); oColumn:SetAlign(); EndIf; If( ValType() == "N" ); oColumn:SetBackColor(); EndIf; If( ValType() == "C" ); oColumn:SetComment(); EndIf; If( ValType({||POSICIONE("SBM",1,xFilial("SBM")+P25->P25_TIPO,"BM_DESC")}) == "B" ); oColumn:SetData({||POSICIONE("SBM",1,xFilial("SBM")+P25->P25_TIPO,"BM_DESC")}); EndIf; If( ValType() == "N" ); oColumn:SetDecimal(); EndIf; If.F.; oColumn:SetDelete(.F.); EndIf; If.F.; oColumn:SetDetails(.F.); EndIf; If( ValType() == "B" ); oColumn:SetDoubleClick(); EndIf; If.F.; oColumn:SetEdit(.F.); EndIf; If( ValType() == "N" ); oColumn:SetForeColor(); EndIf; If( ValType() == "B" ); oColumn:SetHeaderClick(); EndIf; oColumn:SetOptions(); If( ValType() == "N" ); oColumn:SetOrder(); EndIf; If( ValType() == "C"); oColumn:SetPicture(); ElseIf( ValType() == "B"); oColumn:SetPicture(); EndIf; If( ValType() == "C" ); oColumn:SetReadVar(); EndIf; If( ValType(TamSX3("BM_DESC")[1]) == "N" ); oColumn:SetSize(TamSX3("BM_DESC")[1]); EndIf; If.F.; oColumn:SetImage(.F.); EndIf; If( ValType("Descrição") == "C" ); oColumn:SetTitle("Descrição"); Else; oColumn:SetTitle(" "); EndIf; If( ValType() == "C" ); oColumn:SetType(); EndIf; If( ValType() == "B" ); oColumn:SetValid(); EndIf; If( ValType(oBrowse) == "O" ); If ( oBrowse:ClassName() $ "FWBROWSE|FWFORMBROWSE|FWMBROWSE|FWMARKBROWSE" ); oBrowse:SetColumns({oColumn}); EndIf; EndIf
		
	oBrowse:Activate()
	TButton():New( 010, 002, "OK"			, oPanel2,{|| lRet := .T.,oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
 	TButton():New( 010, 052, "Cancelar"   	, oPanel2,{|| lRet := .F.,oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
        
	ACTIVATE MSDIALOG oDLG  CENTER
	
Return lRet	


Static Function MenuDef()
	
	Local _aRotina := {}
	
	Aadd( _aRotina, { "Pesquisar", 'PesqBrw', 0, 1, 0}) 

Return _aRotina

