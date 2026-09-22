#Include 'Protheus.ch'
#Include 'FwMVCDef.ch'
/*/{Protheus.doc} P52SELCC
Atualiza filiais no centro de custo
@type function
@version P122410 
@author ricar
@since 1/8/2026
@return variant, Nulo
/*/
User Function P52SELCC()
	Local aArea         := GetArea()
	Local aColumns      := {}
	Private oTempTable    := Nil
	Private cMarca      := GetMark()
	Private cTempTable  := ""
	Private oMarkBrowse := Nil
	Private aRotina     := MenuDef()

	cTempTable := fBuildTmp(@oTempTable)
	aColumns := fBuildColumns()

	aSize := MsAdvSize(.F.)
	oMoreDlg := MsDialog():New(aSize[7], aSize[2], aSize[6], aSize[5], 'Seleção Centro de custo x Filial', , , , , CLR_BLACK, CLR_WHITE, , , .T., , , , .T.) // "Sales Invoices"

	oMarkBrowse := FWMarkBrowse():New()
	oMarkBrowse:SetMenuDef("")
	oMarkBrowse:SetDescription('Seleção Filiais x Centro de custo' + " - "+ AllTrim(CTT->CTT_CUSTO) + " | " + AllTrim(CTT->CTT_DESC01) )
	oMarkBrowse:SetOwner(oMoreDlg)

	oMarkBrowse:SetAlias(cTempTable)
	oMarkBrowse:SetColumns(aColumns)
	oMarkBrowse:SetFieldMark("OK")
	
	cCampoAux := "P52_FILCC"
	aSeek := {}
    aAdd(aSeek,{GetSX3Cache(cCampoAux, "X3_TITULO"), {{"", GetSX3Cache(cCampoAux, "X3_TIPO"), GetSX3Cache(cCampoAux, "X3_TAMANHO"), GetSX3Cache(cCampoAux, "X3_DECIMAL"), AllTrim(GetSX3Cache(cCampoAux, "X3_TITULO")), AllTrim(GetSX3Cache(cCampoAux, "X3_PICTURE"))}} } )
       
	oMarkBrowse:oBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
	oMarkBrowse:SetMark(cMarca, cTempTable, "OK")
	oMarkBrowse:SetCustomMarkRec({|| P52MkB(oMarkBrowse) })
	oMarkBrowse:SetTemporary(.T.)	
	//oMarkBrowse:SetFixedBrowse(.T.)
	
	DbSelectArea(cTempTable)
	(cTempTable)->( DbSetOrder(1) )
	(cTempTable)->( DbGoTop() )

	OpenSm0(cEmpAnt)
	SM0->(DbGoTop())
	//cMarca    := oMarkBrowse:Mark()
	While SM0->(!Eof())
		If( RecLock(cTempTable, .T.) )
			(cTempTable)->OK        := IIF(!Empty(Posicione("P52",1,xFilial("P52")+Padr(SM0->M0_CODFIL, FwTamSx3("P52_FILCC")[1])+PadR(CTT->CTT_CUSTO,FwTamSx3("P52_CC")[1]), "P52_FILCC")), cMarca, Space(2))
			(cTempTable)->FILIAL    := AllTrim(SM0->M0_CODFIL)
			(cTempTable)->NOME      := AllTrim(SM0->M0_FILIAL)
			(cTempTable)->(MsUnLock())
		EndIf
		SM0->(DbSkip())
	EndDo	
	
	(cTempTable)->(DbGoTop())
	oMarkBrowse:Refresh(.T.)
	oMarkBrowse:Activate()
	oMoreDlg:Activate(, , , .T., {|| .T.}, , {|| .F.})
	
	oTempTable:Delete()
	oMarkBrowse:DeActivate()
	FreeObj(oTempTable)
	FreeObj(oMarkBrowse)
	RestArea( aArea )
Return

/*
    Descrição: Constrói tabela temporária.
    Data     : 26/05/2020
    Param    : Object, Endereço do content da temporária
    Return   : Character, nome da tabela criada.    
*/
Static Function fBuildTmp(oTempTable)

	Local cAliasTemp := GetNextAlias()
	Local aFields    := {}

	//Monta estrutura de campos da temporária
	aAdd(aFields, { "OK"       , "C", 2, 0 })
	aAdd(aFields, { "FILIAL"   , GetSx3Cache("P52_FILCC","X3_TIPO"), GetSx3Cache("P52_FILCC","X3_TAMANHO"), GetSx3Cache("P52_FILCC","X3_DECIMAL") })
	aAdd(aFields, { "NOME"     , GetSx3Cache("P52_NOMFIL","X3_TIPO"), GetSx3Cache("P52_NOMFIL","X3_TAMANHO"), GetSx3Cache("P52_NOMFIL","X3_DECIMAL")  })

	oTempTable:= FWTemporaryTable():New(cAliasTemp)
	oTemptable:SetFields( aFields )
	oTempTable:AddIndex("01", {"FILIAL"} )
	oTempTable:Create()

Return oTempTable:GetAlias()

/*
    Descrição: Constrói estrutura das colunas que serão apresentadas na tela.
    Data     : 26/05/2020
    Return   : Nil        
*/
Static Function fBuildColumns()

	Local nX       := 0
	Local aColumns := {}
	Local aStruct  := {}

	AAdd(aStruct, { "OK"           , "C", 2 , 0})
	aAdd(aStruct, { "FILIAL"      , GetSx3Cache("M0_CODFIL","X3_TIPO"), GetSx3Cache("M0_CODFIL","X3_TAMANHO"), GetSx3Cache("M0_CODFIL","X3_DECIMAL") })
	aAdd(aStruct, { "NOME"  , GetSx3Cache("M0_FILIAL","X3_TIPO"), GetSx3Cache("M0_FILIAL","X3_TAMANHO"), GetSx3Cache("M0_FILIAL","X3_DECIMAL")  })

	For nX := 2 To Len(aStruct)
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nX][1]+"}") )
		aColumns[Len(aColumns)]:SetTitle(aStruct[nX][1])
		aColumns[Len(aColumns)]:SetSize(aStruct[nX][3])
		aColumns[Len(aColumns)]:SetDecimal(aStruct[nX][4])
	Next nX
Return aColumns

/*/{Protheus.doc} MenuDef
Menu da rotina
@type function
@version P122410 
@author ricar
@since 1/8/2026
@return variant, aRotina
/*/
Static Function MenuDef()
	Local aRotina := {}

	//Criação das opções
	
	
	Aadd(aRotina , {"Salvar"    ,'u_xP52SLCC'       , 0, 2})
	Aadd(aRotina , {"Fechar"    , 'CloseBrowse()'       , 0, 2})

	
	
	
Return aRotina

/*/{Protheus.doc} xP52SLCC
Rotina responsável por criar os itens na P52
@type function
@version P122410 
@author ricar
@since 1/8/2026
@return variant, nulo
/*/
User Function xP52SLCC()
	Local aArea     := FWGetArea()
	Local nAtual    := 0
	Local cDtTime    := DToS(Date())+Space(1)+Time()	
	
	//Define o tamanho da régua
	DbSelectArea(cTempTable)
	(cTempTable)->(DbGoTop())
	cCusto := CTT->CTT_CUSTO

	DbSelectArea("P52")
	P52->(DbSetOrder(03))			
	if P52->(DbSeek(FwxFilial("P52") + cCusto))										
		While P52->P52_CC == cCusto			
			RecLock("P52", .F.)
				P52->(DbDelete())
			P52->(MsUnLock())
			P52->(DbSkip())
		EndDo
	endif

	While !(cTempTable)->(EoF())
		lOpc := .T.
		nAtual++
		//Caso esteja marcado
		If oMarkBrowse:IsMark()
			DbSelectArea("P52")
			P52->(DbSetOrder(02))			
			if !P52->(DbSeek(FwxFilial("P52") + cCusto + (cTempTable)->FILIAL))										
				Reclock("P52", lOpc)
				P52->P52_CC := cCusto
				P52->P52_FILCC := (cTempTable)->FILIAL
				P52->P52_NOMFIL := FWFilName(cEmpAnt,(cTempTable)->FILIAL)
				P52->P52_XUSRIN := cDtTime
				P52->P52_XUSRAL := cDtTime
				P52->P52_XUSR := UsrRetName(getCodUsr())
				P52->P52_ATIVO := "1"
				P52->(MsUnlock())
			endif			
		else
			DbSelectArea("P52")
			P52->(DbSetOrder(01))
			if P52->(DbSeek(FwxFilial("P52") + (cTempTable)->FILIAL + CTT->CTT_CUSTO))
				RecLock("P52",.F.)
				P52->(DbDelete())
				P52->(MsUnlock())
			endif
		EndIf

		(cTempTable)->(DbSkip())
	EndDo

	//Mostra a mensagem de término e caso queria fechar a dialog, basta usar o método End()
	FWAlertInfo('Rotina finalizada', 'Atenção')
	(cTempTable)->(DbGoTop())
	
	CloseBrowse()
	FWRestArea(aArea)
Return

Static function getCodUsr()
return RetCodUsr()
//-------------------------------------------------------------------
/*/{Protheus.doc} function Rh3MkB
description SetCustomMarkRec
@author  Gisele Nuncherino
@since   25/03/2020
/*/
//-------------------------------------------------------------------
Static Function P52MkB(oMark)
	If ( !oMark:IsMark() )
		RecLock(oMark:Alias(),.F.)
		(oMark:Alias())->OK  := cMarca
		(oMark:Alias())->(MsUnLock())

	Else
		RecLock(oMark:Alias(),.F.)
		(oMark:Alias())->OK  := ""
		(oMark:Alias())->(MsUnLock())
	EndIf
Return( .T. )
