#Include 'Protheus.ch'
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F0500411
Utilizado para filtrar consultas padroes
@type function
@author Ademar Fernandes
@since 26/01/2017
@version 1.0
@version P12.1.7
@Project MAN0000007423039_EF_004
@param nMyOpc, numerico, 1 - Filtro do Depto.(SQB)| 2 - Filtro do C.Custo (CTT)| 3 - Filtro do Posto (RCL)
@return ${return}, ${não há}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function F0500411(nMyOpc)

	Local oModAtu	:= FWModelActive()
	Local cBkpFil	:= cEmpAnt + cFilAnt
	Local cFilProp	:= oModAtu:GetModel("TRFDETAIL"):GEtValue("FILIPROP")
	Local cCustoProp:= oModAtu:GetModel("TRFDETAIL"):GEtValue("CCUSTOPROP")
	Local cDepProp	:= oModAtu:GetModel("TRFDETAIL"):GEtValue("DEPTOPROP")
	Local cRetorno	:= ""

	Default nMyOpc := 0

	If Empty(cFilProp)
		cFilProp := oModAtu:GetModel("TRFDETAIL"):GEtValue("TMP_FILIAL")
	EndIf

	If nMyOpc = 0	//-Busca a "Filial Para"
		dbSelectArea("SM0")
		SM0->(dbSetOrder(1))
		if SM0->(DbSeek(cEmpAnt + cFilProp))
			//cRetorno := SM0->(Alltrim(M0_NOME) + " - " + Alltrim(M0_FILIAL)) Thais Paiva - 13163986
			cRetorno := SUBSTR(SM0->(Alltrim(M0_NOME) + " - " + Alltrim(M0_FILIAL)),1,50)
		EndIf
		SM0->(DbSeek(cEmpAnt + cBkpFil))

	ElseIf nMyOpc = 2	//-Filtro do C.Custo (CTT) para usar no SXB
		cRetorno += "CTT->CTT_FILIAL == '" + cFilProp + "' .OR. Empty(CTT->CTT_FILIAL) "

	ElseIf nMyOpc = 1	//-Filtro do Depto.(SQB) para usar no SXB
		cRetorno += "(SQB->QB_FILIAL == '" + cFilProp + "' .OR. Empty(SQB->QB_FILIAL)) "
		cRetorno += ".AND. (SQB->QB_CC == '" + cCustoProp + "' .OR. Empty(SQB->QB_CC)) "

	ElseIf nMyOpc = 3	//-Filtro do Posto (RCL) para usar no SXB
		If Empty(cDepProp)
			cDepProp := oModAtu:GetModel("TRFDETAIL"):GEtValue("TMP_DEPTOA")
		EndIf
		cRetorno += "(RCL->RCL_FILIAL == '" + cFilProp + "' .OR. Empty(RCL->RCL_FILIAL)) "
		cRetorno += ".AND. (RCL->RCL_CC == '" + cCustoProp + "' .OR. Empty(RCL->RCL_CC)) "
		cRetorno += ".AND. (RCL->RCL_DEPTO == '" + cDepProp + "' .OR. Empty(RCL->RCL_DEPTO)) "

	EndIf

	If nMyOpc <> 0
		cRetorno := "@#" + cRetorno + "@#"
	EndIf

Return(cRetorno)


/*/{Protheus.doc} ${function_method_class_name}
consulta padrão customizada para retorna os status dos postos genericos como "ocupado parcial"
@author Fernando Carvalho
@since 21/04/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function FSRCL2()
	Local lRet			:= .F.
	Local cAliasRCL	:= GetNextAlias()
	Local oModAtu		:= FWModelActive()
	Local cBkpFil		:= cEmpAnt + cFilAnt
	Local cFilProp	:= oModAtu:GetModel("TRFDETAIL"):GEtValue("FILIPROP")
	Local cCustoProp	:= oModAtu:GetModel("TRFDETAIL"):GEtValue("CCUSTOPROP")
	Local cDepProp	:= oModAtu:GetModel("TRFDETAIL"):GEtValue("DEPTOPROP")
	Local cRetorno	:= ""
	Local aBrowse 	:= {}
	Local oLayer 		:= FWLayer():new()



	cQuery 	:= " SELECT RCL_POSTO, RCL_STATUS, RCL_NPOSTO, RCL_OPOSTO, RCL_CARGO"
	cQuery 	+= " FROM " + RetSqlName("RCL")
	cQuery 	+= " WHERE (RCL_FILIAL 	= '" + cFilProp + "' 		OR RCL_FILIAL	='')"
	cQuery 	+= " AND (RCL_CC 			= '" + cCustoProp + "' 	OR RCL_CC 		='')"
	cQuery 	+= " AND (RCL_DEPTO 		= '" + cDepProp + "' 		OR RCL_DEPTO 	='')"
	cQuery  += " AND RCL_STATUS <> '4'" // ticket 3142417 [AMS] - Paulo Dias - 28/06/2018
	cQuery 	+= " AND D_E_L_E_T_ 		= ''"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRCL,.T.,.T.)

	If !(cAliasRCL)->(EOF())

		oBrowse 	:= FWBrowse():New()

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

		oBrowse:SetOwner(oPanel1)
		oBrowse:SetDescription("Consulta Padrão")
		oBrowse:SetDataArray()
		oBrowse:DisableFilter()
		oBrowse:DisableConfig()
		oBrowse:SetArray(aBrowse)
	   	oBrowse:SetColumns(GetColuna('Código Posto',1,,1,20,"oBrowse"))
	   	oBrowse:SetColumns(GetColuna('Situação'	 ,2,,1,20,"oBrowse"))
	   	oBrowse:SetColumns(GetColuna('Cargo'   	 ,3,,1,20,"oBrowse"))
	   	oBrowse:SetColumns(GetColuna('Desc. Cargo' ,4,,1,20,"oBrowse"))


		While !(cAliasRCL)->(EOF())
			AAdd(aBrowse,{(cAliasRCL)->(RCL_POSTO),; //Cod. Posto
							IIF((cAliasRCL)->(RCL_STATUS)  = '2',IIF((cAliasRCL)->(RCL_NPOSTO) <> (cAliasRCL)->(RCL_OPOSTO),"Parcial","Ocupado"),"Livre"),;//Status
							(cAliasRCL)->(RCL_CARGO),;  //Cod. Cargo
							FDesc("SQ3", (cAliasRCL)->(RCL_CARGO), "Q3_DESCSUM")})  //Cargo

			(cAliasRCL)->(DbSkip())
		EndDo

		oBrowse:Activate()
		//If valtype(oBrowse:oData) <> 'U' .And. Len(oBrowse:oData:aArray) > 0

			TButton():New( 010, 002, "OK"			, oPanel2,{|| OKRCL(oBrowse,cFilProp,cDepProp),lRet := .T.,oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
			TButton():New( 010, 052, "Visualizar" 	, oPanel2,{|| VisualRCL(oBrowse,cFilProp,cDepProp) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
		  	TButton():New( 010, 102, "Cancelar"   	, oPanel2,{|| lRet := .F.,oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )

			ACTIVATE MSDIALOG oDLG  CENTER
			If valtype(oBrowse:oData) <> 'U' .And. Len(oBrowse:oData:aArray) > 0
				If lRet
					IF !(Empty(oBrowse:oData:aArray[oBrowse:nat,1]))
						oModAtu:GetModel("TRFDETAIL"):SetValue("POSTOPROP",oBrowse:oData:aArray[oBrowse:nat,1])

					Else
						lRet := .F.
					EndIf
				EndIf
			EndIf
	Else
		MSGINFO("Não existem postos para a Filial+Departamento+CC informados","Atenção")
		lRet := .F.
	EndIf
Return lRet

Static Function GetColuna(cTitulo,xArrData,cPicture,nAlign,nSize,cBrowse,cTipo,nDecimal)
	Local aColumn
	Local bData := {||}
	Default nAlign := 1
	Default nSize := 20

	If !Empty(xArrData)
		If ValType(xArrData) == "B"
			bData := xArrData
		ElseIf ValType(xArrData) == "N" .AND. xArrData > 0 .AND. !Empty(cBrowse)
			bData := &("{||" + cBrowse + ":oData:aArray[" + cBrowse + ":At()," + STR(xArrData) + "]}")
		EndIf
	EndIf

	/* Array da coluna
	[n][01] Título da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] Máscara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Indica se permite a edição
	[n][09] Code-Block de validação da coluna após a edição
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execução do duplo clique
	[n][12] Variável a ser utilizada na edição (ReadVar)
	[n][13] Code-Block de execução do clique no header
	[n][14] Indica se a coluna está deletada
	[n][15] Indica se a coluna será exibida nos detalhes do Browse
	[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não) */

	aColumn := {cTitulo,bData,cTipo,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}
Return {aColumn}

Static Function VisualRCL(oBrowse,cFilProp,cDepProp)
	Local cPosto 		:= IIf(valtype(oBrowse:oData) <> 'U' .And. Len(oBrowse:oData:aArray) > 0,oBrowse:oData:aArray[oBrowse:nat,1],"")

	Private cCadastro	:= "RCL"
	dbSelectArea("RCL")
	dbSetOrder(1)

	If DbSeek(cFilProp + cDepProp + cPosto)
		AxVisual("RCL",RCL->(Recno()),2)
	Else
		MSGINFO("Não existem postos para a Filial+Departamento+CC informados","Atenção")
	EndIF
Return
//retorno do codigo
Static Function OKRCL(oBrowse,cFilProp,cDepProp)
	Local cPosto 		:= IIf(valtype(oBrowse:oData) <> 'U' .And. Len(oBrowse:oData:aArray) > 0,oBrowse:oData:aArray[oBrowse:nat,1],"")

	Private cCadastro	:= "RCL"
	dbSelectArea("RCL")
	dbSetOrder(1)

	If !DbSeek(cFilProp + cDepProp + cPosto)
		MSGINFO("Não existem postos para a Filial+Departamento+CC informados","Atenção")
	EndIF
Return
//retorno do codigo

User Function FSRCL2R1()

Return (RCL->RCL_POSTO)
//retorno da descrição
User Function FSRCL2R2()
Local oModAtu := FWModelActive()
Local cFilProp := oModAtu:GetModel("TRFDETAIL"):GEtValue("FILIPROP")

Local cCargo		:= POSICIONE("RCL",2,cFilProp + RCL->RCL_POSTO,"RCL_CARGO")
Return(POSICIONE("SQ3",1,xFilial("SQ3") + cCargo,"Q3_DESCSUM"))
