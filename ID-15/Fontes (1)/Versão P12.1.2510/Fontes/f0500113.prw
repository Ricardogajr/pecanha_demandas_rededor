#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"

/*/{Protheus.doc} ${function_method_class_name}
Consulta padrão customizada para apresentar as matrículas subordinadas ao usuário logado.
@author Nairan Alves Silva
@since 10/07/2017
@version 1.0
@return lRet - Confirmação da consulta
/*/
User Function F0500113()

	Local lRet		:= .F.
	Local cAliasSRA := GetNextAlias()
	Local oModAtu	:= FWModelActive()
	Local cBkpFil	:= cEmpAnt + cFilAnt
	Local cMat		:= ""
	Local cRetorno	:= ""
	Local aBrowse 	:= {}
	Local oLayer 	:= FWLayer():new()
	Local aIndex    := {}
 	Local aSeek     := {}

	AAdd(aSeek, {"Matrícula", {{"", "C", TamSX3("RA_MAT")[1] , 0, "Matrícula", , }}, 1, .T.}) 
   	AAdd(aSeek, {"Nome"     , {{"", "C", TamSX3("RA_NOME")[1], 0, "Nome"     , , }}, 2, .T.})

	AAdd(aIndex, "RA_MAT" )
   	AAdd(aIndex, "RA_NOME")
	
	oBrowse 	:= FWFormBrowse():New()
	
	cQuery 	:= RetFunc()

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
		  
		TButton():New( 010, 002, "OK"			, oPanel2,{|| lRet := .T.,cMat := (oBrowse:Alias())->RA_MAT,oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
		TButton():New( 010, 052, "Visualizar" 	, oPanel2,{|| VisualSRA(oBrowse) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	  	TButton():New( 010, 102, "Cancelar"   	, oPanel2,{|| lRet := .F.,oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	  		
		oBrowse:SetOwner(oPanel1)
		oBrowse:SetDescription("Consulta Padrão") 
		oBrowse:SetDataQuery(.T.)
		oBrowse:SetAlias(cAliasSra)
		oBrowse:SetQueryIndex(aIndex)
		oBrowse:SetQuery( cQuery ) 
    	oBrowse:SetSeek(,aSeek)		
 		oBrowse:SetUseFilter( .F. )
	//	oBrowse:SetDataArray()
		//oBrowse:DisableFilter()
		oBrowse:DisableDetails()
		oBrowse:DisableConfig() 

		ADD COLUMN oColumn DATA {|| RA_MAT}     TITLE 'Matricula' 	    SIZE TamSX3('RA_MAT')[1]  OF oBrowse
		ADD COLUMN oColumn DATA {|| RA_NOME}    TITLE 'Nome   ' 	    SIZE TamSX3('RA_NOME')[1]  OF oBrowse
		
		oBrowse:Activate()
        
	ACTIVATE MSDIALOG oDLG  CENTER
	
	If lRet
		If !Empty(cMat)
			SRA->(DbSeek(xFilial("SRA")+cMat))
		EndIf
	EndIf

Return lRet	

Static Function GetColuna(cTitulo,xArrData,cPicture,nAlign,nSize,cBrowse,cTipo,nDecimal)

	Local aColumn	:= {}
	Local bData := {||}
	
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

		
Static Function VisualSRA(oBrowse)
	Local cMat 		:= (oBrowse:Alias())->RA_MAT
	Private cCadastro	:= "SRA"		
	SRA->(DbSeek(xFilial("SRA") + cMat))
	AxVisual("SRA",SRA->(Recno()),2)
Return 

//retorno do codigo
User Function F0500114()	
Return (SRA->RA_MAT)

Static Function RetFunc() 

	Local aAux      := {}
	Local aChave    := {}
	Local cConc		:= " || "
	Local cQuery    := ""
	Local cMy1Alias := "INFTRB"
	Local nCnt      := 0
	
	aAux := U_GetInfMat(.F.)

	cQuery := "SELECT RD4_CHAVE "
	cQuery += "FROM " + RetSqlName("RCX") + " RCX "
	cQuery += "INNER JOIN " + RetSqlName("RD4") + " RD4 "
	cQuery += "ON RD4.D_E_L_E_T_ = ' ' "
	cQuery += "AND RD4_FILIDE = RCX_FILIAL AND RD4_CODIDE = RCX_POSTO "
	cQuery += "INNER JOIN " + RetSqlName("RDK") + " RDK "
	cQuery += " ON ( RDK.RDK_FILIAL = RD4.RD4_FILIAL AND RDK.RDK_CODIGO = RD4.RD4_CODIGO "
	cQuery += "AND RDK.D_E_L_E_T_ = ' ' ) "
	cQuery += "WHERE RCX.D_E_L_E_T_ = ' ' "
	cQuery += "AND RCX_FILFUN = '" + aAux[1] + "' "
	cQuery += "AND RCX_MATFUN = '" + aAux[2] + "' "
	cQuery += "AND RDK_PADRAO = '1' "
	cQuery += "AND RDK_STATUS = '1' "
	cQuery += "ORDER BY RCX_FILIAL,RCX_FILFUN,RCX_MATFUN,RCX_POSTO "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGenQry( ,,cQuery ), cMy1Alias, .F., .T. )
	
	While (cMy1Alias)->(!Eof())
		AADD(aChave, (cMy1Alias)->RD4_CHAVE)
		(cMy1Alias)->(DbSkip())
	EndDo
	(cMy1Alias)->(DbCloseArea())
	
	cQuery := "SELECT DISTINCT RA_MAT    ,RA_NOME  "
	cQuery += "FROM " + RetSqlName("RD4") + " RD4 "
	cQuery += "INNER JOIN " + RetSqlName("RDK") + " RDK "
	cQuery += " ON ( RDK.RDK_FILIAL = RD4.RD4_FILIAL AND RDK.RDK_CODIGO = RD4.RD4_CODIGO "
	cQuery += "AND RDK.D_E_L_E_T_ = ' ' ) "	
	cQuery += "INNER JOIN " + RetSqlName("RCX") + " RCX "
	cQuery += "  ON RCX.D_E_L_E_T_ = ' ' "
	cQuery += "  AND RCX_FILIAL = RD4_FILIDE "
	cQuery += "  AND RCX_POSTO = RD4_CODIDE "
	cQuery += "INNER JOIN " + RetSqlName("SRA") + " SRA "
	cQuery += "  ON SRA.D_E_L_E_T_ = ' ' "
	cQuery += "  AND SRA.RA_MAT = RCX.RCX_MATFUN "
	cQuery += "  AND SRA.RA_FILIAL = RCX.RCX_FILFUN "
	cQuery += "WHERE RD4.D_E_L_E_T_ = ' ' "
	cQuery += "AND RD4_CODIGO IN (SELECT RD4_CODIGO "
	cQuery += "FROM " + RetSqlName("RCX") + " RCX "
	cQuery += "INNER JOIN " + RetSqlName("RD4") + " RD4 "
	cQuery += "  ON RD4.D_E_L_E_T_ = ' ' "
	cQuery += "  AND RD4_FILIDE = RCX_FILIAL "
	cQuery += "  AND RD4_CODIDE = RCX_POSTO "
	cQuery += "WHERE RCX.D_E_L_E_T_ = ' ' "
	cQuery += "AND RDK_PADRAO = '1' "
	cQuery += "AND RDK_STATUS = '1' "	
	cQuery += "AND RA_FILIAL = '" + xFilial("SRA") + "' "	
	cQuery += "AND RCX_FILFUN = '" + aAux[1] + "' "
	cQuery += "AND RCX_MATFUN = '" + aAux[2] + "') "
	If Len(aChave) > 1 
		cQuery += " AND ("
		For nCnt := 2 To Len(aChave)
			cQuery += "( RD4_CHAVE LIKE LTRIM(RTRIM( "
			cQuery += " '"+ aChave[nCnt] + "' "
			cQuery += ")) " + cConc + " '%' )"
			If nCnt < Len(aChave)
				cQuery += " OR "
			EndIf
		Next
		cQuery += ") "

	ElseIf Len(aChave) > 0 
		cQuery += " AND ("
		For nCnt := 1 To Len(aChave)
			cQuery += "( RD4_CHAVE LIKE LTRIM(RTRIM( "
			cQuery += " '"+ aChave[nCnt] + "' "
			cQuery += ")) " + cConc + " '%' )"
			If nCnt < Len(aChave)
				cQuery += " OR "
			EndIf
		Next
		cQuery += ") "
		cQuery += " AND RCX_MATFUN <> '"+aAux[2]+"' "	
	EndIf
	
	cQuery += "ORDER BY RA_MAT "
	
Return cQuery