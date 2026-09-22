#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"

Static cAliasPA5
Static cAliasRH3

/*/{Protheus.doc} F0500202
Função que exibe o Browse com os registros da Solicitação de Vagas
@author Fernando Carvalho
@since 07/11/2016
@version 12.7
@project MAN0000007423039_EF_002
/*/

User Function F0500202()
	Local oBrowse
	Local cFiltro  := ""
	Local aRetFil	:= aClone(RetFil())
	Local cSta1      := "Aguardando aprovação"
	Local cSta2      := "Aprovado"
	Local cSta3      := "Reprovado"
	Local cSta4      := "Aguardando efetivação do RH"
	
	cAliasPA5			:= GetNextAlias()
	cFiltro := "Empty(RH3_TIPO)"
	If !Empty(aRetFil[2])
		cFiltro += aRetFil[2]
	EndIf
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("RH3")
	oBrowse:SetFilterDefault(cFiltro)
	oBrowse:SetOnlyFields({'RH3_XDTAPV'})
	oBrowse:SetDescription('Monitor das Solicitações')

	ADD COLUMN oColumn DATA {|| RH3_FILIAL }  TITLE 'Filial' SIZE TamSX3('RH3_FILIAL')[1]  OF oBrowse
	ADD COLUMN oColumn DATA {|| RH3_CODIGO }  TITLE 'Código' SIZE TamSX3('RH3_CODIGO')[1]  OF oBrowse
	ADD COLUMN oColumn DATA {|| POSICIONE("PA7",1,XFILIAL("PA7")+RH3_XTPCTM,"PA7_DESCR") }  TITLE 'Descrição'	    SIZE 30  OF oBrowse
	ADD COLUMN oColumn DATA {|| IIF(RH3_STATUS=="1",cSta1,IIF(RH3_STATUS=="2",cSta2,IIF(RH3_STATUS=="3",cSta3,cSta4))) }  TITLE 'Status' SIZE 30  OF oBrowse
	ADD COLUMN oColumn DATA {|| RH3_DTSOLI }  TITLE 'Data Solic' SIZE TamSX3('RH3_DTSOLI')[1]  OF oBrowse				
	ADD COLUMN oColumn DATA {|| RH3_XDTAPV }  TITLE 'Data Aprov' SIZE TamSX3('RH3_XDTAPV')[1]  OF oBrowse

	oBrowse:SetCacheView( .F. )
	If aRetFil[1]
		oBrowse:Activate()
	Else
		oBrowse:Destroy()
	EndIf
	
Return NIL

/*/-------------------------------------------------------------------
{Protheus.doc} MenuDef()
Criação do Menu de monitor das solicitações
@Author     Fernando Carvalho
@Since      07/11/2016
@Version    P12.1.07
@Project    MAN0000007423039_EF_002
@Return		aRotina, opção de menu
*/
Static Function MenuDef()
	
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE 'Visualizar' 		ACTION 'VIEWDEF.F0500202' 	OPERATION 2  ACCESS 0
	ADD OPTION aRotina Title "Cancelar Solicitação"   Action 'U_F0500225' 		OPERATION 6 ACCESS 0	
		
Return aRotina

/*/{Protheus.doc} ModelDef
Menu da rotina de Solicitações de Vagas
@author Fernando Carvalho
@since 11/11/2016
@version 12.7
@return oModel - Objeto do modelo do MVC
@project MAN0000007423039_EF_002
/*/
Static Function ModelDef()
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStrField	:= FieldModelo()
	Local oStruPA5 	:= GridModelo()
	Local oModel
		
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('F050203', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields("FIELD", /*cOwner*/, oStrField, /*bPreVld*/, /*bPosVld*/,{|oModel|CargaField(oModel)}/*bLoad*/)

	oModel:AddGrid('GRID','FIELD',oStruPA5, , , , ,{|oModel|CargaGrid(oModel)})
	oModel:GetModel('FIELD'):SetPrimaryKey({})
	oModel:GetModel( 'GRID' ):SetNoInsertLine()
	oModel:SetDescription("Mudança de Status de Indicadores")
	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'FIELD' ):SetDescription( 'Consulta de Indicadores' )
	
	oModel:SetPrimaryKey({'PA5_FILIAL+PA5_XNRSOL+PA5_XDATA'})
	oModel:SetVldActivate( { |oModel| ValidMod(oModel) } )
	

Return oModel

/*/{Protheus.doc} FieldModelo
Retorna a estrutura da Field da Tela para o Modelo
@author Fernando Carvalho
@since 11/11/2016
@version 12.7
@project MAN0000007423039_EF_002
/*/
Static Function FieldModelo()

	Local oStructModelField	:= FWformModelStruct():New()
	
	oStructModelField:AddTable('PA5',,"Consulta de Indicadores")
	
	oStructModelField:AddField("Filial Solic"   ,"Filial Solic" ,'PA5_FILIAL' ,'C',TamSx3("PA5_FILIAL")[1],	0, 	{|| .T.},	{|| .F.},	NIL,	.F.,NIL,	NIL,	NIL,.T.)
	oStructModelField:AddField("Descrição"      ,"Descricao"    ,'DESCRICAO'  ,'C',20                     ,	0, 	{|| .T.},	{|| .F.},	NIL,	.F.,{||FWFilialName(,((cAliasPA5)->PA5_FILIAL),1)},	NIL,	.T.,.T.)
	oStructModelField:AddField("Num Solic"      ,"Num Solic"    ,'PA5_XNRSOL' ,'C',TamSx3("PA5_XNRSOL")[1],	0, 	{|| .T.}, 	{|| .F.},	NIL,	.F.,NIL,	NIL,	NIL,.T.)	
	oStructModelField:AddField("Desc Solic"     ,"Desc Solic"   ,'PA5_XDESOL' ,'C',TamSx3("PA5_XDESOL")[1],	0,	{|| .T.},	{|| .F.},	NIL,	.F.,NIL,	NIL,	NIL,.T.)		 		
	oStructModelField:AddField("Função"         ,"Função"       ,'PA5_FUNCAO' ,'C',TamSx3("PA5_FUNCAO")[1],	0, 	{|| .T.},	{|| .F.},	NIL,	.F.,NIL,	NIL,	NIL,.T.)
	oStructModelField:AddField("Matr. Solici"   ,"Matr. Solici" ,'PA5_XMAT'	  ,'C',TamSx3("PA5_XMAT")[1]  ,	0, 	{|| .T.},	{|| .F.},	NIL,	.F.,NIL,	NIL,	NIL,.T.)
	oStructModelField:AddField("Nome Solicit"   ,"Nome Solicit" ,'PA5_XNOME'  ,'C',TamSx3("PA5_XNOME")[1] ,	0, 	{|| .T.},	{|| .F.},	NIL,	.F.,NIL,	NIL,	NIL,.T.)
	oStructModelField:AddField("Departamento"   ,"Departamento" ,'PA5_XSETOR' ,'C',TamSx3("PA5_XSETOR")[1],	0, 	{|| .T.},	{|| .F.},	NIL,	.F.,NIL,	NIL,	NIL,.T.)
	oStructModelField:AddField("Cargo"          ,"Cargo"        ,'PA5_XCARGO' ,'C',TamSx3("PA5_XCARGO")[1],	0, 	{|| .T.},	{|| .F.},	NIL,	.F.,NIL,	NIL,	NIL,.T.)
	oStructModelField:AddField("Centro Custo"   ,"Centro Custo" ,'PA5_XCC'    ,'C',TamSx3("PA5_XCC")[1]   ,	0, 	{|| .T.},	{|| .F.},	NIL,	.F.,NIL,	NIL,	NIL,.T.)
	
Return oStructModelField

/*/{Protheus.doc} GridModelo
Retorna a estrutura da Grid da Tela para o MOdelo
@author Fernando Carvalho
@since 11/11/2016
@version 12.7
@project MAN0000007423039_EF_002
/*/
Static Function GridModelo()

	Local oStructModelGrid	:= FWformModelStruct():New()

	oStructModelGrid:AddTable('PA5',,"Consulta de Indicadores")
		 	
	oStructModelGrid:AddField("Matr. Aprovado"	,"Matr. Aprovado"		,'PA5_XMATAP'	,'C',TamSx3("PA5_XMATAP")[1]	,	0, 	{|| .T.},	{|| .F.},	NIL,	.F.,NIL,	NIL,	NIL,.T.)
	oStructModelGrid:AddField("Nome Aprovador"	,"Nome Aprovador"		,'PA5_XAPROV'	,'C',TamSx3("PA5_XAPROV")[1]	,	0, 	{|| .T.},	{|| .F.},	NIL,	.F.,NIL,	NIL,	NIL,.T.)
	oStructModelGrid:AddField("Departamento"		,"Departamento"		,'PA5_XSEAPV'	,'C',TamSx3("PA5_XSEAPV")[1]	,	0, 	{|| .T.},	{|| .F.},	NIL,	.F.,NIL,	NIL,	NIL,.T.)
	oStructModelGrid:AddField("Filial Aprovador"	,"Filial Aprovador"	,'PA5_XUNAPR'	,'C',TamSx3("PA5_XUNAPR")[1]	,	0, 	{|| .T.},	{|| .F.},	NIL,	.F.,NIL,	NIL,	NIL,.T.)
	oStructModelGrid:AddField("Cargo Aprovador"	,"Cargo Aprovador"	,'PA5_XCARAP'	,'C',TamSx3("PA5_XCARAP")[1]	,	0, 	{|| .T.},	{|| .F.},	NIL,	.F.,NIL,	NIL,	NIL,.T.)
	oStructModelGrid:AddField("Cod. Evento"		,"Cod. Evento"		,'PA5_XCODEV'	,'C',TamSx3("PA5_XCODEV")[1]	,	0, 	{|| .T.},	{|| .F.},	NIL,	.F.,NIL,	NIL,	NIL,.T.)
	oStructModelGrid:AddField("Des. Evento"		,"Des. Evento"		,'PA5_XDESEV'	,'C',TamSx3("PA5_XDESEV")[1]	,	0, 	{|| .T.},	{|| .F.},	NIL,	.F.,NIL,	NIL,	NIL,.T.)
	oStructModelGrid:AddField("Status"				,"Status"				,'PA5_XSTAT'	,'C',TamSx3("PA5_XSTAT")[1]		,	0, 	{|| .T.},	{|| .F.},	NIL,	.F.,NIL,	NIL,	NIL,.T.)
	oStructModelGrid:AddField("Valor Solicitado"	,"Valor Solicitado"	,'PA5_XEMPEN'	,'N',TamSx3("PA5_XEMPEN")[1]	,	2, 	{|| .T.},	{|| .F.},	NIL,	.F.,NIL,	NIL,	NIL,.T.)
	oStructModelGrid:AddField("Data"				,"Data"				,'PA5_XDATA'	,'D',TamSx3("PA5_XDATA")[1]		,	0, 	{|| .T.},	{|| .F.},	NIL,	.F.,NIL,	NIL,	NIL,.T.)
	oStructModelGrid:AddField("Hora"				,"Hora"				,'PA5_XHORA'	,'C',TamSx3("PA5_XHORA")[1]		,	0, 	{|| .T.},	{|| .F.},	NIL,	.F.,NIL,	NIL,	NIL,.T.)	

Return oStructModelGrid

/*/{Protheus.doc} ViewDef
Retorna a View da rotina
@author Fernando Carvalho
@since 11/11/2016
@version 12.7
@project MAN0000007423039_EF_002
/*/
Static Function ViewDef()
	
	Local oModel   			
	Local oView 	:= FWFormView():New()	
	Local oStruCab	:= FieldView()
	Local oStrGrid	:= GridView()
	
	oModel   	:= FWLoadModel( 'F0500202' )
	
	oView:AddUserButton("Informações da Solicitação", "", {|oModel| FsVisualSol(oModel) })
	
	If RH3->RH3_XTPCTM == "002" //Vaga
		oView:AddUserButton("Visualizar Solicitação FAP", "", {|oModel| FsVisualFAP(oModel) })
	ElseIf RH3->RH3_XTPCTM == "004" //FAP
		oView:AddUserButton("Visualizar Solicitação Vaga", "", {|oModel| FsVisualVga(oModel) })
	EndIf
	
	oView:SetModel( oModel )
		
	oView:AddField("TELA", oStruCab,'FIELD') 
	oView:AddGrid("ITEM", oStrGrid,'GRID')
	
	oView:CreateHorizontalBox("BOXTELA", 40)
	oView:CreateHorizontalBox("BOXPA5"	, 60)
	
	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView("TELA","BOXTELA")
	oView:SetOwnerView("ITEM","BOXPA5")
		
	
	//oView:EnableTitleView( "ITEM", "Consulta de Indicadores" )
	
	oView:EnableControlBar( .F. )
	//oView:setUseCursor(.F.)
	//oView:SetCloseOnOk({||.T.})
	oView:SetViewCanActivate({|oView| .t. })
	
Return oView


/*/{Protheus.doc} FieldView
Retorna a estrutura da Field da Tela para a View
@author Fernando Carvalho
@since 11/11/2016
@version 12.7
@project MAN0000007423039_EF_002
/*/
Static Function FieldView()

	Local oStructViewField	:= FWformViewStruct():New()
	
	oStructViewField:AddField( 'PA5_FILIAL'	,'001','Filial Solic' ,'Filial Solic'  ,NIL,'GET',	'@!',	NIL,	'',	.T.,NIL, NIL,	NIL,0,'',.T.)
	oStructViewField:AddField( 'DESCRICAO'	,'002','Descricao'    ,'Descricao'     ,NIL,'GET',	'@!',	NIL,	'',	.T.,NIL, NIL,	NIL,0,'',.T.)
	oStructViewField:AddField( 'PA5_XNRSOL'	,'003','Num Solic'    ,'Num Solic'     ,NIL,'GET',	'@!',	NIL,	'',	.T.,NIL, NIL,	NIL,0,'',.T.)
	oStructViewField:AddField( 'PA5_XDESOL'	,'004','Desc Solic'   ,'Desc Solic'    ,NIL,'GET',	'@!',	NIL,	'',	.T.,NIL, NIL,	NIL,0,'',.T.)
	oStructViewField:AddField( 'PA5_FUNCAO'	,'005','Função'       ,'Função'        ,NIL,'GET',	'@!',	NIL,	'',	.T.,NIL, NIL,	NIL,0,'',.T.)
	oStructViewField:AddField( 'PA5_XMAT'	,'006','Matr. Solici' ,'Matr. Solici'  ,NIL,'GET',	'@!',	NIL,	'',	.T.,NIL, NIL,	NIL,0,'',.T.)
	oStructViewField:AddField( 'PA5_XNOME'	,'007','Nome Solicit' ,'Nome Solicit'  ,NIL,'GET',	'@!',	NIL,	'',	.T.,NIL, NIL,	NIL,0,'',.T.)	
	oStructViewField:AddField( 'PA5_XSETOR'	,'008','Departamento' ,'Departamento'  ,NIL,'GET',	'@!',	NIL,	'',	.T.,NIL, NIL,	NIL,0,'',.T.)
	oStructViewField:AddField( 'PA5_XCARGO'	,'009','Cargo'        ,'Cargo'         ,NIL,'GET',	'@!',	NIL,	'',	.T.,NIL, NIL,	NIL,0,'',.T.)
	oStructViewField:AddField( 'PA5_XCC'	,'010','Centro Custo' ,'Centro Custo'  ,NIL,'GET',	'@!',	NIL,	'',	.T.,NIL, NIL,	NIL,0,'',.T.)
	
Return oStructViewField

/*/{Protheus.doc} GridView
Retorna a estrutura da Grid da Tela para a View
@author Fernando Carvalho
@since 11/11/2016
@version 12.7
@project MAN0000007423039_EF_002
/*/
Static Function GridView()
	
	Local oStructViewGrid	:= FWformViewStruct():New()
	Local cP					:= '@E 99,999,999.99'	
	//Descrição da Solicitação
	oStructViewGrid:AddField('PA5_XSTAT' ,'001','Status'				,'Status'				,NIL,'GET','@!',NIL,'',	.T.,NIL,NIL,NIL,0,	'',	.T.)
	oStructViewGrid:AddField('PA5_XMATAP','002','Matr. Aprovado'	,'Matr. Aprovado'		,NIL,'GET','@!',NIL,'',	.T.,NIL,NIL,NIL,0,	'',	.T.)
	oStructViewGrid:AddField('PA5_XAPROV','003','Nome Aprovador'	,'Nome Aprovador'		,NIL,'GET','@!',NIL,'',	.T.,NIL,NIL,NIL,0,	'',	.T.)
	oStructViewGrid:AddField('PA5_XSEAPV','004','Departamento'		,'Departamento'		,NIL,'GET','@!',NIL,'',	.T.,NIL,NIL,NIL,0,	'',	.T.)
	oStructViewGrid:AddField('PA5_XUNAPR','005','Filial Aprovador'	,'Filial Aprovador'	,NIL,'GET','@!',NIL,'',	.T.,NIL,NIL,NIL,0,	'',	.T.)
	oStructViewGrid:AddField('PA5_XCARAP','006','Cargo Aprovador'	,'Cargo Aprovador'	,NIL,'GET','@!',NIL,'',	.T.,NIL,NIL,NIL,0,	'',	.T.)
	oStructViewGrid:AddField('PA5_XCODEV','007','Cod. Evento'		,'Cod. Evento'		,NIL,'GET','@!',NIL,'',	.T.,NIL,NIL,NIL,0	,	'',.T.)
	oStructViewGrid:AddField('PA5_XDESEV','008','Des. Evento'		,'Des. Evento'		,NIL,'GET','@!',NIL,'',	.T.,NIL,NIL,NIL,0,	'',.T.)	
	oStructViewGrid:AddField('PA5_XEMPEN','009','Valor Solicitado'	,'Valor Solicitado'	,NIL,'GET', cP ,NIL,'',	.T.,NIL,NIL,NIL,0,	'',	.T.)
	oStructViewGrid:AddField('PA5_XDATA' ,'010','Data'				,'Data'				,NIL,'GET','@D',NIL,'',	.T.,NIL,NIL,NIL,0,	'',	.T.)
	oStructViewGrid:AddField('PA5_XHORA' ,'011','Hora'				,'Hora'				,NIL,'GET','@!',NIL,'',	.T.,NIL,NIL,NIL,0,	'',	.T.)
		
Return oStructViewGrid	

/*/{Protheus.doc} ExecQuery
Cria e abre o Alias Temporario para que seja utilizado nos blocos de Load da View e do Model
@author Fernando Carvalho
@since 11/11/2016
@version 12.7
@project MAN0000007423039_EF_002
/*/
Static Function ExecQuery()
	
	Local cQuery		:= ""
	
	cQuery += " SELECT 				"	+ CRLF
	cQuery += " PA5.R_E_C_N_O_ RECNO"	+ CRLF
	cQuery += " ,PA5.PA5_XNRSOL "	+ CRLF
	cQuery += " ,PA5.PA5_XDESOL "	+ CRLF
	cQuery += " ,PA5.PA5_FILIAL"	+ CRLF
	cQuery += " ,PA5.PA5_XCODEV"	+ CRLF
	cQuery += " ,PA5.PA5_XDESEV"	+ CRLF
	cQuery += " ,PA5.PA5_FUNCAO"	+ CRLF
	cQuery += " ,PA5.PA5_XMAT	"	+ CRLF
	cQuery += " ,PA5.PA5_XNOME	"	+ CRLF
	cQuery += " ,PA5.PA5_XSETOR	"	+ CRLF
	cQuery += " ,PA5.PA5_XCARGO	"	+ CRLF
	cQuery += " ,PA5.PA5_XMATAP	"	+ CRLF
	cQuery += " ,PA5.PA5_XAPROV	"	+ CRLF
	cQuery += " ,PA5.PA5_XSEAPV	"	+ CRLF
	cQuery += " ,PA5.PA5_XUNAPR	"	+ CRLF
	cQuery += " ,PA5.PA5_XCARAP	"	+ CRLF
	cQuery += " ,PA5.PA5_XCC	"		+ CRLF
	cQuery += " ,PA5.PA5_XCONTA	"	+ CRLF
	cQuery += " ,PA5.PA5_XSTAT	"	+ CRLF
	cQuery += " ,PA5.PA5_XEMPEN"	+ CRLF
	cQuery += " ,PA5.PA5_XDATA	"	+ CRLF
	cQuery += " ,PA5.PA5_XHORA	"	+ CRLF

	cQuery += " FROM "+RetSqlName("PA5")+" PA5"	+ CRLF
	cQuery += " INNER JOIN "+RetSqlName("RH3")+" RH3"	+ CRLF
	cQuery += " ON RH3.RH3_CODIGO = PA5.PA5_XNRSOL"	+ CRLF
	cQuery += " AND RH3.RH3_FILIAL = PA5.PA5_FILIAL"	+ CRLF
	cQuery += " AND RH3.D_E_L_E_T_ = ' ' "	+ CRLF
	cQuery += " WHERE"	+ CRLF
	cQuery += " PA5.PA5_FILIAL = '"+xFilial("PA5")+"'"	+ CRLF
	cQuery += " AND PA5.PA5_XNRSOL	= '"+RH3->RH3_CODIGO+"'"	+ CRLF
	cQuery += " AND PA5.D_E_L_E_T_ = ' '"+ CRLF
	 
	If Select(cAliasPA5)<>0
		dbSelectArea(cAliasPA5)
		dbCloseArea()
	EndIf 
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasPA5,.T.,.T.)
	
Return 

/*/{Protheus.doc} CargaField
Carrega e retorna os dados da Field
@author Fernando Carvalho
@since 11/11/2016
@version 12.7
@project MAN0000007423039_EF_002
/*/
Static Function CargaField(oModel)

	Local aResult		:= {}
	ExecQuery()//Abre o arquivo temporário
	dbSelectArea(cAliasPA5)
	(cAliasPA5)->(dbGoTop())
	
	aAdd(aResult,{})
	aadd(aResult,1)
	
	If (cAliasPA5)->(! EOF())		
		aResult[1] := {(cAliasPA5)->(PA5_FILIAL),"",(cAliasPA5)->(PA5_XNRSOL)	,(cAliasPA5)->(PA5_XDESOL)	;
						,(cAliasPA5)->(PA5_FUNCAO),(cAliasPA5)->(PA5_XMAT)  	,(cAliasPA5)->(PA5_XNOME)	;
						,(cAliasPA5)->(PA5_XSETOR),(cAliasPA5)->(PA5_XCARGO)	,(cAliasPA5)->(PA5_XCC) 	}
	Else
		aResult[1] := { "","","","","","","","","","","" }	 
	EndIf
		
Return aResult

/*/{Protheus.doc} CargaGrid
Carrega e retorna os dados do Modelo
@author Fernando Carvalho
@since 11/11/2016
@version 12.7
@project MAN0000007423039_EF_002
/*/
Static Function CargaGrid(oModel)

	Local aResult		:= {}
	Local nLoop		:= 0
	
	dbSelectArea(cAliasPA5)
	(cAliasPA5)->(dbGoTop())	
	aResult := FwLoadByAlias(oModel,cAliasPA5)	
	For nLoop := 1 To Len(aResult)
		aResult[nLoop,2,10] := StoD(aResult[nLoop,2,10])
	Next	
	
Return aResult

//-----------------------------	|
//Função para encerrar a Grid	|
//-----------------------------	|
Static Function Sair()	
	Local oView := FwViewActive()				
	(cAliasPA5)->(dbCloseArea())	      
	oView:ButtonCancelAction()	//Necessário para encerrar a View 	
Return

/*/{Protheus.doc} Monitoramento
Função chamada no MenuDef
@author Fernando Carvalho
@since 14/12/2016
@version 12.7
@project MAN0000007423039_EF_002
/*/
Static Function ValidMod()	
	Local lRet 	:= .F.
	ExecQuery()//Abre o arquivo temporário
	dbSelectArea(cAliasPA5)
	(cAliasPA5)->(dbGoTop())
	
	If (cAliasPA5)->(! EOF())
		lRet 	:= .T.
	Else
		//Alert("Não há indicadores para ser exibido.")
		Help("",1, "Help", "Sem registro na PA5", "Não há indicadores para ser exibido." , 3, 0)	
	EndIf	
Return lRet 

/*
{Protheus.doc} F0500225()
Validação para cancelamento da solicitação
@Author     Bruno de Oliveira
@Since      15/12/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_025
*/
User Function F0500225()

	Local aUser := {}
	Local cNivel := "00"
	Local cFilSol := RH3->RH3_FILIAL
	Local cCodSol := RH3->RH3_CODIGO
	Local cStatus := RH3->RH3_STATUS
	Local cSolict := RH3->RH3_XTPCTM
	
	cMatFun := Posicione("RH3",1,cFilSol+cCodSol,"RH3_MAT")

	DbSelectArea("PAB")
	PAB->(DbSetOrder(1))
	If PAB->(DbSeek(xFilial("PAB")+RH3->RH3_XCODAL))
		cSubGrp := PAB->PAB_GRPSOL
	EndIf
	
	aUser	:= U_GetInfMat()
	
	If !Empty(aUser[1]) .AND. !Empty(aUser[2])

		SRA->(DbSetOrder(1))
		If SRA->(DbSeek(aUser[1]+aUser[2]))
			SRJ->(DbSetOrder(1))
			If SRJ->(DbSeek(xFilial("SRJ")+SRA->RA_CODFUNC))
				cNivel := SRJ->RJ_XGEREN
			EndIf
		EndIf

		If cNivel == "01" //RH
			If cSolict == "005" //Desligamento
				If cSubGrp == "001" .OR. cSubGrp == "002" .OR. cSubGrp == "003" .OR. cStatus != "1"
					MsgAlert("Usuário não tem permissão para cancelar a solicitação")
				Else
					cCodP10 := Posicione("P10",2,cFilSol+cMatFun,"P10_COD")
					U_CanclSlc(cFilSol,cCodSol,cCodP10,aUser[1],aUser[2],cSolict)
				EndIf
			Else
				If cStatus == "1" .OR. cStatus == "4"
					If cSolict == "004" //FAP
						cCodPrt := cFilSol+cCodSol
					ElseIf cSolict == "006" //Movimentação Pessoal
						cCodPrt := cFilSol+cMatFun
					Else
						cCodPrt := ""
					EndIf					
					U_CanclSlc(cFilSol,cCodSol,cCodPrt,aUser[1],aUser[2],cSolict)
				Else
					MsgAlert("Usuário não tem permissão para cancelar a solicitação")	
				EndIf
			EndIf
		Else
			MsgAlert("Usuário não tem permissão para cancelar a solicitação")
		EndIf

	EndIf

Return

/*
{Protheus.doc} FsVisualSol()
Visualizar informações da Solicitação
@Author     Bruno de Oliveira
@Since      18/12/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_023
*/
Static Function FsVisualSol(oModel)

	Local aAreaRH3 := RH3->(GetArea())
	Local cFilSol  := oModel:GetModel("FIELD"):GetValue("PA5_FILIAL")
	Local cCodSol  := oModel:GetModel("FIELD"):GetValue("PA5_XNRSOL")
	
	RH3->(DbSetOrder(1))
	If RH3->(DbSeek(cFilSol+cCodSol))
		FWExecView('', 'F0100323', 1, , { || .T. })
	EndIf

	RestArea(aAreaRH3)

Return

/*
{Protheus.doc} FsVisualFAP()
Visualizar a solicitação de FAP vinculada
@Author     Bruno de Oliveira
@Since      18/12/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_023
*/
Static Function FsVisualFAP(oModel)

	Local aAreaRH3 := RH3->(GetArea())
	Local cFilSol  := oModel:GetModel("FIELD"):GetValue("PA5_FILIAL")
	Local cCodSol  := oModel:GetModel("FIELD"):GetValue("PA5_XNRSOL")
	Local cAlias1  := GetNextAlias()
	Local cAlias2  := GetNextAlias()
	Local cQuery   := ""
	Local cQuery2  := ""
	Local cFlVaga  := ""
	Local cCdVaga  := ""	
	
	cQuery += "SELECT QS_FILIAL, QS_VAGA "
	cQuery += "FROM " + RetSqlName("SQS") + " "
	cQuery += "WHERE QS_XSOLFIL = '" + cFilSol + "' "
	cQuery += "AND QS_XSOLPTL =  '" + cCodSol + "' "
	cQuery += "AND D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1,.T.,.T.)
	
	If !(cAlias1)->(EOF())
		cFlVaga := (cAlias1)->QS_FILIAL
		cCdVaga := (cAlias1)->QS_VAGA
	EndIf
	
	If !Empty(cFlVaga) .AND. !Empty(cCdVaga)
	
		cQuery2 += "SELECT PA2_FILSOL, PA2_SOL "
		cQuery2 += "FROM " + RetSqlName("PA2") + " "
		cQuery2 += "WHERE PA2_FILVG = '" + cFlVaga + "' "
		cQuery2 += "AND PA2_CDVAGA = '" + cCdVaga + "' "
		cQuery2 += "AND PA2_SIT IN ('AP','AG','CL','RI') "
		cQuery2 += "AND D_E_L_E_T_ = ' ' "
		
		cQuery2 := ChangeQuery(cQuery2)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),cAlias2,.T.,.T.)
		
		If !(cAlias2)->(EOF())
			RH3->(DbSetOrder(1))
			If RH3->(DbSeek((cAlias2)->(PA2_FILSOL)+(cAlias2)->(PA2_SOL)))
				FWExecView('', 'F0100323', 4, , { || .T. })
				lRet := .T.
			Else
				lRet := .F.
			EndIf
		Else
			lRet := .F.
		EndIf
	
		If !lRet
			MsgAlert("Não existe nennhuma FAP vinculada a solicitação.")
		EndIf
	
	Else
		MsgAlert("Vaga não existe para esta solicitação")
	EndIf
	
	RestArea(aAreaRH3)

Return

/*
{Protheus.doc} FsVisualVga()
Visualizar a solicitação de vaga vinculada
@Author     Bruno de Oliveira
@Since      18/12/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_023
*/
Static Function FsVisualVga(oModel)

	Local aAreaRH3 := RH3->(GetArea())
	Local cFilSol  := oModel:GetModel("FIELD"):GetValue("PA5_FILIAL")
	Local cCodSol  := oModel:GetModel("FIELD"):GetValue("PA5_XNRSOL")
	Local cVaga    := ""
	Local cFlSolVg := ""
	Local cCdSolVg := ""
	
	PA2->(DbSetOrder(6))
	If PA2->(DbSeek(cFilSol+cCodSol))
		
		SQS->(DbSetOrder(1))
		If SQS->(DbSeek(PA2->PA2_FILVG+PA2->PA2_CDVAGA))
			cFlSolVg := SQS->QS_XSOLFIL
			cCdSolVg := SQS->QS_XSOLPTL
		EndIf
		
	EndIf
	
	If !Empty(cFlSolVg) .AND. !Empty(cCdSolVg)
		RH3->(DbSetOrder(1))
		If RH3->(DbSeek(cFlSolVg+cCdSolVg))
			FWExecView('', 'F0100323', 1, , { || .T. })
		EndIf
	EndIf
	
	RestArea(aAreaRH3)
	
Return

/*
{Protheus.doc} CrButton()
Criação dos botões
@Author     Bruno de Oliveira
@Since      21/12/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_023
*/
Static Function CrButton( oBrowse , aRotina )

	Local cTitle := ""
	Local cRot   := ""
	Local nOpc   := 0
	Local nX     := 0
	
	For nX := 1 To Len( aRotina )
		cTitle	:= aRotina[nX][1]
		cRot	:= aRotina[nX][2]
		nOcp	:= aRotina[nX][4]
		oBrowse:AddButton( cTitle, cRot ,, nOcp ) //"Confirmar"
	Next nX

Return

/*
{Protheus.doc} RetFil()
Retorna as solicitações
@Author     Bruno de Oliveira
@Since      21/12/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_023
*/
Static Function RetFil

	Local cAlias1   := GetNextAlias()
	Local cQueryChv := ""
	Local cQuery    := ""
	Local aUser     := {}
	Local lRh       := .F.
	Local aRet		:= {.F.,""}
	
	aUser	:= U_GetInfMat()
	
	If !Empty(aUser[1]) .AND. !Empty(aUser[2])

		SRA->(DbSetOrder(1))
		If SRA->(DbSeek(aUser[1]+aUser[2]))
			SRJ->(DbSetOrder(1))
			If SRJ->(DbSeek(xFilial("SRJ")+SRA->RA_CODFUNC))
				If SRJ->RJ_XGEREN == "01" //RH
					lRh := .T.
					aRet[1] := .T.
				EndIf
			EndIf
			
			If !lRh
				cQueryChv := "SELECT RD4_CHAVE "
				cQueryChv += "FROM " + RetSqlName("RCX") + " RCX "
				cQueryChv += "INNER JOIN " + RetSqlName("RD4") + " RD4 ON(RD4.RD4_FILIDE = RCX.RCX_FILIAL AND "
				cQueryChv += "RD4.RD4_CODIDE = RCX.RCX_POSTO AND RD4.D_E_L_E_T_ = ' ') "
				cQueryChv += "WHERE RCX.RCX_FILFUN = '" + aUser[1]  + "' AND "
				cQueryChv += "RCX.RCX_MATFUN = '" + aUser[2] + "' AND "
				cQueryChv += "RCX.RCX_POSTO = '" + SRA->RA_POSTO + "' AND "
				cQueryChv += "RCX.D_E_L_E_T_ = ' '"
				
				cQueryChv := ChangeQuery(cQueryChv)
				DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryChv),cAlias1,.T.,.T.)
				
				If !(cAlias1)->(EOF())
					cChave := (cAlias1)->RD4_CHAVE
				
					(cAlias1)->(DbCloseArea())
				
					aRet[1] := .T.
					aRet[2] := " .AND. '"+AllTrim(cChave)+"' $  AllTrim(RH3_XCHAVE) "
					
				// 416094 - Rogerio Carvalho - 23/07/2018 - DOR04520620 - AMS Rio
				// mensagem para informar que não existem Solicitações e impedir que surja erro de smartclient
				// Erro percebido durantes testes para integração de alteração cadastral/contratual
				Else
				   alert("Não foram encontradas [SOLICITAÇÕES] para este funcionário!")
				   (cAlias1)->(DbCloseArea())
				EndIf
				// Fim 416094 - Rogerio Carvalho - 23/07/2018 - DOR04520620 - AMS Rio
			EndIf
			
		EndIf
					
	EndIf	

Return aRet