#Include 'Totvs.ch'

/*/{Protheus.doc} F2000105
Apresenta a tela de visualização do log (P20) baseado na chave da própria tabela
@author Gianluca Moreira
@since 18/05/2021
@version 1.0
@return Nil, Nil
@type function
/*/
User Function F2000105(cTitulo, cFiltro, cTabLog)
	Local aWindSize := FwGetDialogSize(oMainWnd)
	Local aDialog   := {0 ,  0, 75,  100} 
	Local oDialog

	aDialog := Ajusta(aWindSize, aDialog)
	oDialog :=  TDialog():New(aDialog[1], aDialog[2], aDialog[3], aDialog[4], cTitulo,,,,,,,,,.T.)
	U_F2000106(cFiltro, oDialog, cTabLog)
	oDialog:Activate(,,,.T.)
	FreeObj(aDialog)
	FreeObj(oDialog)
Return

/*/{Protheus.doc} F2000106
Monitor Integração Log de Entrada
@author Alex Sandro 
@since 27/12/2016
@param cFiltro, caracter, filtro de browse
@param oOwner, object, objeto container do browse
@Project MAN0000007423041_EF_000 - Log de Entrada

/*/
User Function F2000106(cFiltro, oOwner, cTabLog)
	Local oBrowse := FWFormBrowse():New()
	Local aAreaSX3 := SX3->(GetArea())
	Local aSX3    := FWSX3Util():GetAllFields( cTabLog , .F. )
	Local aHeader := {}
	Local nI      := 0
	Local nLastIndex := 0

	Default oOwner := oMainWnd

	SX3->(DbSetOrder(2)) //X3_CAMPO
	For nI := 1 to Len(aSX3)
		If !SX3->(DbSeek(aSX3[nI]))
			Loop
		EndIf
		If GetSx3Cache( aSX3[nI] ,"X3_BROWSE") == 'N' .Or. Empty(GetSx3Cache( aSX3[nI] ,"X3_BROWSE"))
			Loop
		EndIf
		AAdd(aHeader, FwBrwColumn():New())
		nLastIndex := Len(aHeader)

		aHeader[nLastIndex]:SetTitle(FWX3Titulo(aSX3[nI]))
		aHeader[nLastIndex]:SetData(&('{|| '+cTabLog+'->'+aSX3[nI]+'}'))
		aHeader[nLastIndex]:SetType(TamSX3(aSX3[nI])[3])
		aHeader[nLastIndex]:SetSize(TamSX3(aSX3[nI])[1])
		aHeader[nLastIndex]:SetDecimal(TamSX3(aSX3[nI])[2])
		aHeader[nLastIndex]:SetPicture(PesqPict(cTabLog, aSX3[nI])) 
	Next nI
	SX3->(RestArea(aAreaSX3))

	oBrowse:SetDataTable()
	oBrowse:SetAlias(cTabLog)
    If cTabLog == 'P19'
        oBrowse:SetDescription('Monitor Integração Log de Entrada')
        oBrowse:AddLegend( "P19_STATUS == '1'", "YELLOW", "Criado"  )
        oBrowse:AddLegend( "P19_STATUS == '2'", "GREEN",  "Sucessso"  )
        oBrowse:AddLegend( "P19_STATUS == '3'", "RED",    "Falha"  )
        oBrowse:AddButton('Visualizar', 'VIEWDEF.F0700002', , 2)
    ElseIf cTabLog == 'P20'
        oBrowse:SetDescription('Monitor Integração Log de Saída')
        oBrowse:AddLegend( "P20_STATUS == '1'", "RED",   "Falha"  )
        oBrowse:AddLegend( "P20_STATUS == '2'", "GREEN", "Sucessso"  )
        oBrowse:AddButton('Visualizar', 'VIEWDEF.F0700003', , 2)
    EndIf
	oBrowse:SetInsert(.F.)
	
	//oBrowse:SetMenuDef("F0700002")
	oBrowse:SetColumns(aHeader)

	If cFiltro != NIL
		oBrowse:SetFilterDefault ( cFiltro )
	EndIf
	If oOwner != Nil
		oBrowse:Activate(oOwner)
	Else
		oBrowse:Activate()
	EndIf

	FreeObj(aAreaSX3)
	FreeObj(aSX3)
Return

/*/{Protheus.doc} Ajusta
Converte os tamanhos passados em % para pixel, para desenhar as telas
@author Gianluca Moreira
@since 24/06/2019
@version 1.0
@return aAjustado, Array com as coordenadas convertidas de % para pixel
@param aWind, array, Array com as dimensões da janela
@param aItem, array, Array a ser ajustado
@type function
/*/
Static Function Ajusta(aWind, aItem)
	Local aAjustado := {0, 0, 0, 0}
	Local nLarg     := aWind[4]-aWind[2]
	Local nAlt      := aWind[3]-aWind[1]

	aAjustado[1] := int(aItem[1]*nAlt/100)
	aAjustado[2] := int(aItem[2]*nLarg/100)
	aAjustado[3] := int(aItem[3]*nAlt/100)
	aAjustado[4] := int(aItem[4]*nLarg/100)
Return aClone(aAjustado)
