#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} F0800301
Cadastro de Filal/Postos de Aprovação.

@author		Nairan Alves Silva
@since		23/02/2017
@version	12
/*/
//------------------------------------------------------------------------------
User Function F0800301()

Local aArea		:= GetArea()
Local oBrowse	:= Nil

PAD->( DbSetOrder(1) )

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("PAD")
oBrowse:SetDescription("Filial e Posto de Aprovação") 
oBrowse:DisableReport()
oBrowse:DisableDetails()
oBrowse:Activate()

RestArea( aArea )

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Monta estrutura de funções do Browse

@return	aRotina, array, Array de Rotinas

@author		Nairan Alves Silva
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.F0800301" OPERATION 2 ACCESS 0 
ADD OPTION aRotina TITLE "Incluir"		ACTION "VIEWDEF.F0800301" OPERATION 3 ACCESS 0  
ADD OPTION aRotina TITLE "Alterar"		ACTION "VIEWDEF.F0800301" OPERATION 4 ACCESS 0 
ADD OPTION aRotina TITLE "Excluir"		ACTION "VIEWDEF.F0800301" OPERATION 5 ACCESS 0

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Monta modelo de dados modelo 2

@return		oModel, objeto, Modelo de Dados

@author		Nairan Alves Silva
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local cCabFields	:= "PA9_FILIAL|PA9_CODIGO|PA9_DESCRI|"
Local bAvalCampo	:= {|cField| AllTrim(cField) + "|" $ cCabFields }
Local oStructPAD	:= FWFormStruct(1,"PAD",/*bAvalCampo*/,/*lViewUsado*/)
Local oStructPA9	:= FWFormStruct(1,"PA9",/*bAvalCampo*/,/*lViewUsado*/)
Local oModel		:= Nil

oModel := MPFormModel():New("F08003M",/*PreValid*/,{|oModel|PosVal(oModel)}/*bPosValidacao*/,/*bCommitMdl*/,/*bCancel*/)

oModel:AddFields("CABMASTER",/*cOwner*/,oStructPAD,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel:AddGrid("PA9DETAIL","CABMASTER",oStructPA9,/*bLinPre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVldGrid*/,/*bLoad*/)

oModel:SetRelation("PA9DETAIL",{{"PA9_FILIAL","PAD_FILIAL"},{"PA9_CODIGO","PAD_CODIGO"}},PA9->(IndexKey(1)))

oModel:SetDescription("Filial - Posto de Aprovação")

oModel:SetPrimaryKey({"PAD_CODIGO"}) 
Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Monta interface modelo 2

@return	oView, objeto, Interface do Agrupador de Registros

@author		Nairan Alves Silva
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

//Local cCabFields	:= "PA9_FILIAL|PA9_CODIGO|PA9_DESCRI|"
//Local bAvalCampo	:= {|cField| AllTrim(cField) + "|" $ cCabFields }
Local oStructPAD	:= FWFormStruct(2,"PAD",/*bAvalCampo*/,/*lViewUsado*/)
Local oStructPA9	:= FWFormStruct(2,"PA9",/*bAvalCampo*/,/*lViewUsado*/)
Local oModel   		:= FWLoadModel("F0800301")
Local oView	 		:= Nil
Local aAreaSX3		:= SX3->(GetArea())

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_CAB",oStructPAD,"CABMASTER")
oView:AddGrid("VIEW_PA9",oStructPA9,"PA9DETAIL")

oStructPA9:RemoveField("PA9_CODIGO")

SX3->(DbSetOrder(2))
If SX3->(DbSeek("PA9_DESCRI"))
	oStructPA9:RemoveField("PA9_DESCRI")
EndIf
//Painel Superior 
oView:CreateHorizontalBox("SUPERIOR",30)

//Painel Inferior
oView:CreateHorizontalBox("INFERIOR",70)

oView:EnableTitleView("VIEW_CAB","Filial e Posto")
oView:EnableTitleView("VIEW_PA9","Detalhes")

oView:SetOwnerView("VIEW_CAB","SUPERIOR") 
oView:SetOwnerView("VIEW_PA9","INFERIOR") 

RestArea(aAreaSX3)
Return oView


//------------------------------------------------------------------------------
/*/{Protheus.doc} F0800302
Valida filial de aprovação

@author		Nairan Alves Silva
@since		23/02/2017
@version	12
/*/
//------------------------------------------------------------------------------
User Function F0800302()
Local oModel	:= FWModelActive()
Local oModelPA9	:= oModel:GetModel("PA9DETAIL")
Local nLin		:= oModelPA9:Getline()
Local cFilAprv	:= oModelPA9:GetValue("PA9_FILAPR", nLin )
Local lRet		:= .T.
Local cNomeFil	:= ""
Local aAreaSM0	:= SM0->(GetArea())

cNomeFil := POSICIONE("SM0",1,cEmpAnt + AllTrim(cFilAprv),"M0_NOME")

If Empty(cNomeFil) .Or. Len(AllTrim(cFilAprv)) != Len(xFilial("PA9"))
	Help('',1,'Atenção',,"Filial Não Encontrada.",1,0,,,,,,{"Informe uma filial válida."})	
	lRet := .F.
EndIf

RestArea(aAreaSM0)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} F0800303
Valida filial de Solicitação

@author		Nairan Alves Silva
@since		23/02/2017
@version	12
/*/
//------------------------------------------------------------------------------
User Function F0800303()
Local oModel	:= FWModelActive()
Local oModelPA9	:= oModel:GetModel("PA9DETAIL")
Local nQtdLin	:= oModelPA9:GetQTDLine()
Local nLin		:= oModelPA9:Getline()
Local cFilSol	:= oModelPA9:GetValue("PA9_FILSOL", nLin )
Local cRet		:= ""
Local nX		:= 0
Local lRet		:= .T.
Local cNomeFil	:= ""
Local aAreaSM0	:= SM0->(GetArea())

cNomeFil := POSICIONE("SM0",1,cEmpAnt + AllTrim(cFilSol),"M0_FILIAL")

If Empty(cNomeFil) .Or. Len(AllTrim(cFilSol)) != Len(xFilial("PA9"))
	Help('',1,'Atenção',,"Filial Não Encontrada.",1,0,,,,,,{"Informe uma filial válida."})	
	lRet := .F.
EndIf

If lRet
	oModelPA9:SetLine(nLin)
	oModelPA9:SetValue("PA9_FSODES",cNomeFil)
EndIf

RestArea(aAreaSM0)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} F0800304
Gatilho descrição do posto de aprovação

@author		Nairan Alves Silva
@since		23/02/2017
@version	12
/*/
//------------------------------------------------------------------------------
User Function F0800304()
Local oModel	:= FWModelActive()
Local oModelPA9	:= oModel:GetModel("PA9DETAIL")
Local nLin		:= oModelPA9:Getline()
Local cPosto	:= oModelPA9:GetValue("PA9_POSAPR", nLin )
Local cFilApr	:= LEFT(oModelPA9:GetValue("PA9_FILAPR", nLin ),TAMSX3("RCL_FILIAL")[1],9)
Local cRet		:= ""
Local lRet		:= .T.
Local aAreaSQB	:= SQB->(GetArea())
Local aAreaRCL	:= RCL->(GetArea())

RCL->(DbSetOrder(2))
If !RCL->(DbSeek(IIF(Empty(xFilial("RCL")),xFilial("RCL"),cFilApr) + cPosto))
	Help('',1,'Atenção',,"O posto não encontrado.",1,0,,,,,,{"Informe um posto válido."})	
	lRet := .F.
ELSE
	cRet := POSICIONE("SQ3",1,xFilial("SQ3") + RCL->RCL_CARGO,"Q3_DESCSUM")
EndIf                                       

If lRet
	If RCL->RCL_STATUS $ "1|3|4" .And. lRet
		Help('',1,'Atenção',,"O posto selecionado está livre, congelado ou cancelado.",1,0,,,,,,{"Informe um posto ocupado."})	
		lRet := .F.
	Else
		oModelPA9:SetValue("PA9_PAPDES",cRet)
	Endif
EndIf
//1=Livre;2=Ocupado;3=Congelado;4=Cancelado

RestArea(aAreaSQB)
RestArea(aAreaRCL)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} F0800305
Retorna a Filial de Aprovação

@author		Nairan Alves Silva
@since		23/02/2017
@version	12
/*/
//------------------------------------------------------------------------------
User Function F0800305()
Local oModel	:= FWModelActive()
Local oModelPA9	:= oModel:GetModel("PA9DETAIL")
Local nLin		:= oModelPA9:Getline()
Local cFilApv	:= oModelPA9:GetValue("PA9_FILAPR", nLin )

Return cFilApv


/////////////////////////////////
// Tudo Ok Confirmação da tela //
/////////////////////////////////
Static Function PosVal()
Local lRet 		:= .T.
Local oModel		:= FWModelActive()
Local oModelPAD		:= oModel:GetModel("CABMASTER")
Local cDescri		:= oModelPAD:GetValue("PAD_DESCRI")
Local lRet			:= .T.
Local nOper		:= oModel:GetOperation()

If Empty(cDescri)
	Help('',1,'Atenção',,"Descrição do grupo não informado.",1,0,,,,,,{"Informe uma descrição para o cadastro."})	
	lRet := .F.
Endif

If nOper == 5	
	lRet := MsgNoYes('Deseja realmente excluir todos os itens de "Cadastro de Filal/Postos de Aprovação"?')
	If !lRet
		Help('',1,'Atenção',,"Foi Cancelado a excluísão do(s) item(ns) do Cadastro de Filial/Posto de Aprovação.",1,0,,,,,,{"Exclusão Cancelada."})	
	EndIf	
Endif

If nOper == 3
	lAlt := .F.
	c1Cod := oModelPAD:GetValue("PAD_CODIGO")
	While .T.	
		If PAD->(dbSeek(xFilial("PAD")+c1Cod))
			c1Cod := Soma1(c1Cod)
			lAlt := .T.
		Else
			If lAlt
				oModelPAD:SetValue("PAD_CODIGO", c1Cod)
				Help('',1,'Atenção',,"O Código inicial já existe!",1,0,,,,,,{"Ele foi alterado para o próximo livre: "+Alltrim(c1Cod) })
			EndIf
			Exit
		EndIf
	EndDo
EndIf
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} FSORG2


@author		Nairan Alves Silva
@since		23/02/2017
@version	12
/*/
//------------------------------------------------------------------------------
User Function FSORG2()
	Local lRet			:= .F.
	Local cAliasRCL	:= GetNextAlias()
	Local oModel		:= FWModelActive()
	Local oModelPA9	:= oModel:GetModel("PA9DETAIL")
	Local nLin			:= oModelPA9:Getline()
	Local cFilApv		:= oModelPA9:GetValue("PA9_FILAPR", nLin )
	Local aBrowse 	:= {}
	Local oLayer 		:= FWLayer():new()
	
	oBrowse 	:= FWBrowse():New()
	
	
	
	cQuery 	:= " SELECT RCL_POSTO, RCL_DEPTO, RCL_CARGO, RCL_FUNCAO"
	cQuery 	+= " FROM " + RetSqlName("RCL")
	cQuery 	+= " WHERE RCL_FILIAL = '" + cFilApv + "'
	cQuery 	+= " AND D_E_L_E_T_ = ''" 
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRCL,.T.,.T.)
	
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
   	oBrowse:SetColumns(GetColuna('Código Posto'	,1,,1,20,"oBrowse"))
   	oBrowse:SetColumns(GetColuna('Código Depto'	,2,,1,20,"oBrowse"))
   	oBrowse:SetColumns(GetColuna('Departamento'	,3,,1,20,"oBrowse"))
   	oBrowse:SetColumns(GetColuna('Código Cargo'	,4,,1,20,"oBrowse"))
   	oBrowse:SetColumns(GetColuna('Cargo'			,5,,1,20,"oBrowse"))
   	oBrowse:SetColumns(GetColuna('Código Função'	,6,,1,20,"oBrowse"))
   	oBrowse:SetColumns(GetColuna('Função'			,7,,1,20,"oBrowse"))	

	
	While !(cAliasRCL)->(EOF())
		AAdd(aBrowse,{(cAliasRCL)->(RCL_POSTO),; //Cod. Posto
						(cAliasRCL)->(RCL_DEPTO),;  //Cod. Depto
						FDesc("SQB", (cAliasRCL)->(RCL_DEPTO), "QB_DESCRIC"),;  //Departamento
						(cAliasRCL)->(RCL_CARGO),;  //Cod. Cargo
						FDesc("SQ3", (cAliasRCL)->(RCL_CARGO), "Q3_DESCSUM"),;  //Cargo
						(cAliasRCL)->(RCL_FUNCAO),;  //Cod. Funcao
						FDesc("SRJ", (cAliasRCL)->(RCL_FUNCAO), "RJ_DESC")})  //Funcao
		
		(cAliasRCL)->(DbSkip())							     						     
	EndDo 
		
	oBrowse:Activate()
	TButton():New( 010, 002, "OK"			, oPanel2,{|| lRet := .T.,oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 010, 052, "Visualizar" 	, oPanel2,{|| VisualRCL(oBrowse,cFilApv) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
  	TButton():New( 010, 102, "Cancelar"   	, oPanel2,{|| lRet := .F.,oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
        
	ACTIVATE MSDIALOG oDLG  CENTER
	If lRet
		oModelPA9:SetLine(nLin)
		oModelPA9:SetValue("PA9_POSAPR",oBrowse:oData:aArray[oBrowse:nat,1])		
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
	
Static Function VisualRCL(oBrowse,cFilApv)
	Local cPosto 		:= oBrowse:oData:aArray[oBrowse:nat,1]
	Local cDetpo		:= oBrowse:oData:aArray[oBrowse:nat,2] 
	Private cCadastro	:= "RCL"
	dbSelectArea("RCL")
	dbSetOrder(1)
	DbSeek(cFilApv + cDetpo + cPosto)
	AxVisual("RCL",RCL->(Recno()),2)
Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} FSORG2R1


@author		Nairan Alves Silva
@since		23/02/2017
@version	12
/*/
//------------------------------------------------------------------------------
User Function FSORG2R1()	
Return(M->PA9_POSAPR)

//------------------------------------------------------------------------------
/*/{Protheus.doc} FSORG2R2


@author		Nairan Alves Silva
@since		23/02/2017
@version	12
/*/
//------------------------------------------------------------------------------
User Function FSORG2R2()	
	Local oModel		:= FWModelActive()
	Local oModelPA9	:= oModel:GetModel("PA9DETAIL")
	Local nLin			:= oModelPA9:Getline()
	Local cFilApv		:= oModelPA9:GetValue("PA9_FILAPR", nLin )
	Local cDepto		:= POSICIONE("RCL",2,xFilial("RCL") + M->PA9_POSAPR,"RCL_DEPTO")
Return(POSICIONE("SQB",1,xFilial("SQB") + cDepto,"QB_DESCRIC"))
