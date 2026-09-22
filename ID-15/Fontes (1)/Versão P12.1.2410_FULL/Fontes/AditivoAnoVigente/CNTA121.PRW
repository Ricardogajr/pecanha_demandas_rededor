#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GCTXDEF.CH"
#INCLUDE "CNTA121.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE 'FWLIBVERSION.CH'

PUBLISH MODEL REST NAME CNTA121 SOURCE CNTA121


// -- Declaração de Variáveis Estáticas
Static oCbx		  := Nil
Static aComp 	  := {}
Static lSugVal 	  := SuperGetMV("MV_CNSUGME",.F.,"1") == "1" //Sugere Valores para Medição
Static lExced 	  := SuperGetMV("MV_CNBTEXC",.F.,"N") == "S" 	//Mostra Excedente
Static _lVlCptCXN := SuperGetMV("MV_CNPLCPT",.F.,.T.)	//Valida competência da planilha
Static lInclui	  := .F.
Static lAltera	  := .F.
Static lEncerra	  := .F.
Static cEncMsg	  := ""
Static lExcedMEnc := .F.
Static lExcedNPrv := .F.
Static lAutForn	  := .F.
Static _lCXNParc  := Nil
Static _lCN121VRE := ExistBlock("CN121VRE")
Static _aIdMdlDoc := ResetIdDoc(.T.)
Static _oQtdBlqIt := Nil
Static _oCtrProps := Nil
Static _lTec930Tst:= Nil
Static _MedServ120:= .F.
Static _aObrgMdls := Nil
Static _lGsMedZer := Nil
Static _oPosCpos  := Nil//Armazena a posição dos campos mais consultados
Static _lVldFrete := Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CNTA121()
Manutenção das Medições
@author José Eulálio
@since 22/07/2015
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function CNTA121()
Local oBrowse
Private aRotina		:= Menudef()
Private lFixo		:= .F.
Private lMedEve		:= .F.
Private lServico	:= .F.
Private cFilCtr 	:= cFilAnt
Private cCadastro	:= STR0001//"Medições de Contrato" -- Variável criada exclusivamente por conta do MsDocument

oBrowse := BrowseDef()
oBrowse:Activate()

FWSetShowKeys(.T.)
SetKey( VK_F12 , Nil )

CN121Limpa()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef()
Browse Definition
@author Flavio Lopes Rasta
@since 05/06/2018
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

Static Function BrowseDef()
	Local oBrowse
	Local aLegenda	:= {}
	Local aCNT121LG	:= {}
	Local nX		:= 0

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("CND")
	oBrowse:SetDescription(STR0001)  //"Medições de Contrato"

	//- Definição de Legendas
	aAdd(aLegenda,{"Alltrim(CND_SITUAC) == 'A'" ,"BR_VERMELHO"	 	,STR0002})// "Medição em Aberto"
	aAdd(aLegenda,{"Alltrim(CND_SITUAC) == 'B'" ,"BR_PRETO"		 	,STR0003})// "Medição Bloqueada"
	aAdd(aLegenda,{"Alltrim(CND_SITUAC) == 'R'" ,"BR_CANCEL"		,STR0072})// "Medição Rejeitada"
	aAdd(aLegenda,{"Alltrim(CND_SITUAC) == 'E'" ,"BR_VERDE"		 	,STR0004})// "Medição Encerrada"
	aAdd(aLegenda,{"Alltrim(CND_SITUAC) == 'FA'","BR_AZUL"		 	,STR0006})// "Aut. Fornec. em Aberto"
	aAdd(aLegenda,{"Alltrim(CND_SITUAC) == 'FE'","BR_CINZA"		 	,STR0007})// "Aut. Fornec Encerrada"
	aAdd(aLegenda,{"Alltrim(CND_SITUAC) == 'DT'","BR_VIOLETA"	 	,STR0122})// "Medição Totalmente Devolvida"
	aAdd(aLegenda,{"Alltrim(CND_SITUAC) == 'DP'","BR_VERDE_ESCURO"	,STR0123})// "Medição Parcialmente Devolvida"
	aAdd(aLegenda,{"Empty(CND_SITUAC)"          ,"BR_AZUL_CLARO"	,STR0212})// "Medição oriunda do CNTA120"
	aAdd(aLegenda,{"Alltrim(CND_SITUAC) == 'SA'","BR_AMARELO"		,STR0008})// "Medição de Serviço em Aberto"

	// Ponto de Entrada para customização da legenda
	IF ExistBlock("CNT121LG")
		aCNT121LG := ExecBlock("CNT121LG",.F.,.F.,{aLegenda})
		If ValType(aCNT121LG) == "A"
			aLegenda := aCNT121LG
		EndIf
	Endif

	For nX := 1 to len(aLegenda)
		oBrowse:AddLegend(aLegenda[nX][1], aLegenda[nX][2], aLegenda[nX][3])
	Next nX

	//-- Filtra Browse
	If ExistBlock("CN121FIL")
		cCn121Fil := ExecBlock("CN121FIL",.F.,.F.)

		If ValType(cCn121Fil) == "C" .And. !Empty(cCn121Fil)
			oBrowse:SetFilterDefault(cCn121Fil)
		EndIf
	EndIf

	// -- mv_par01 - Mostra Lancamentos   S/N
	// -- mv_par02 - Aglut Lancamentos    S/N
	SetKey(VK_F12,{|| Pergunte("CNT120",.T.)})

	oBrowse:SetCacheView(.F.)
	oBrowse:SetMainProc('CNTA121')

	FwFreeArray(aLegenda)
Return oBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
@author José Eulálio
@since 22/07/2015
@version 1.0
@return aRotina
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aExcede 	:= {}
Private aRotina := {} //Array utilizado para controlar opcao selecionada

ADD OPTION aExcede TITLE STR0120 ACTION "CN121Menu(10)" OPERATION MODEL_OPERATION_UPDATE ACCESS 13 //Excedentes - Medições encerradas
ADD OPTION aExcede TITLE STR0121 ACTION "CN121Menu(11)" OPERATION MODEL_OPERATION_INSERT ACCESS 14 //Excedentes - Competências não previstas

ADD OPTION aRotina TITLE STR0053 ACTION "CN121Menu(1)"	OPERATION MODEL_OPERATION_INSERT ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0076 ACTION "CN121Menu(2)"	OPERATION MODEL_OPERATION_INSERT ACCESS 0 //"Aut. Fornecimento"
ADD OPTION aRotina TITLE STR0054 ACTION "CN121Menu(3)"	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0055 ACTION "CN121Menu(4)"	OPERATION MODEL_OPERATION_VIEW	 ACCESS 0//"Visualizar"
ADD OPTION aRotina TITLE STR0056 ACTION "CN121Menu(5)"	OPERATION MODEL_OPERATION_DELETE ACCESS 3 //"Excluir"
ADD OPTION aRotina TITLE STR0057 ACTION "CN121Menu(6)"	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //"Estornar"
ADD OPTION aRotina TITLE STR0058 ACTION "CN121Menu(7)"	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //"Encerrar"
ADD OPTION aRotina TITLE STR0059 ACTION "CN121Menu(8)"	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //"Conhecimento"
ADD OPTION aRotina TITLE STR0060 ACTION "CN121Menu(9)"	OPERATION 8 ACCESS 0//'Imprimir'
ADD OPTION aRotina TITLE STR0077 ACTION "CN121Menu(12)"	OPERATION MODEL_OPERATION_INSERT ACCESS 0 //Medição de Serviço

If lExced
	aAdd(aRotina,{ STR0050, aExcede	, 0, 13, 0, nil}) //Excedente
EndIf

If ExistBlock("CNT121BT")
	ExecBlock("CNT121BT",.F.,.F.)
EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author José Eulálio
@since 22/07/2015
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel   		:= Nil
	//- Estruturas de Medição
	Local oStruCND 		:= Nil
	Local oStruCXN		:= Nil
	Local oStruCNE		:= Nil

	//- Estruturas de Consulta Contrato
	Local oStruCNU		:= FWFormStruct(1,'CNU')

	//- Estruturas de Multas e Bonificações
	Local oStruCNR1		:= FWFormStruct(1,'CNR')
	Local oStruCNR2		:= FWFormStruct(1,'CNR')
	Local oStruCNK		:= FWFormStruct(1,'CNK')
	Local oStruCNQ		:= FWFormStruct(1,'CNQ')
	Local oStruCNZ		:= FWFormStruct(1,'CNZ')
	Local oStruCXI		:= FWFormStruct(1,'CXI')
	Local oStruCXJ		:= FWFormStruct(1,'CXJ')
	Local oStruCXM		:= FWFormStruct(1,'CXM')
	Local oStruCXO		:= FWFormStruct(1,'CXO') 
	Local oStruCXP		:= FWFormStruct(1,'CXP')

	Local bVldCalc		:= {|oFldModel| Cn121VldCalc(oFldModel)}
	Local bPosCND		:= {|oFieldModel| CN121CNDPos(oFieldModel:GetModel())}
	Local bLinPreCNZ 	:= { |oModelGrid,  nLine,cAction,  cField, xValue, xOldValue| Cn121CNZPV(oModelGrid, nLine, cAction, cField, xValue, xOldValue) }
	Local bLinPosCNZ 	:= {|x| CNZPosVld(x)}
	Local bLinPosCNE	:= {|x| CNEPosVld(x)}

	Local bPreVlCXO		:= {|oModelGrid,nLine,cAction,cField,xValue,xOldValue| MNatPreCXO("CNTA121",oModelGrid,nLine,cAction,cField,xValue,xOldValue)}
	Local bPreVlCXP		:= {|oModelGrid,nLine,cAction,cField,xValue,xOldValue| MNatPreCXP("CNTA121",oModelGrid,nLine,cAction,cField,xValue,xOldValue)}

	Local aCamposCXP	:= {"CXP_CC","CXP_CONTA","CXP_ITEMCT","CXP_CLVL"}
	Local aCTBEnt		:= CTBEntArr()
	Local nX			:= 0
	Local aRelatCNU		:= {}
	
	Local bFalseWhen	:= FwBuildFeature( STRUCT_FEATURE_WHEN	, ".F.")
	Local bModoTrigg	:= {|| IIF(FwIsInCallStack('CN121CNRIt'), '1', '2') }

	oStruCND := CNDStruct()//Obtem Struct da CND(Cabeçalho da Medição)
	oStruCXN := CXNStruct()//Obtem struct da CXN(Planilhas da Medição)
	oStruCNE := CNEStruct()//Obtem Struct da CNE(Itens da Medição)

	If cPaisloc == "RUS" 
		oStruCNE:AddTrigger('CNE_OPER'	 /*cIdField*/, 'CNE_TES'	/*cTargetIdField*/, {||.T.} /*bPre*/,{||RUSmtTio(Iif(CN300RetSt("COMPRA",0,oModel:GetModel('CXNDETAIL'):GetValue('CXN_NUMPLA'),oModel:GetModel("CNDMASTER"):GetValue("CND_CONTRA")),1,2),FwFldGet('CNE_OPER'))}/*bSetValue*/ )
		oStruCNE:AddTrigger('CNE_OPER'	 /*cIdField*/, 'CNE_CF'	/*cTargetIdField*/, {||.T.} /*bPre*/,{||RUSmtCd(Iif(CN300RetSt("COMPRA",0,oModel:GetModel('CXNDETAIL'):GetValue('CXN_NUMPLA'),oModel:GetModel("CNDMASTER"):GetValue("CND_CONTRA")),1,2),FwFldGet('CNE_OPER'))}/*bSetValue*/ )
		oStruCNE:AddTrigger('CNE_PRODUT'	 /*cIdField*/, 'CNE_OPER'	/*cTargetIdField*/, {||.T.} /*bPre*/,{||RU09XTIOTrigger()}/*bSetValue*/ ) 
	EndIf

	/*---------Alteracoes na estrutura da CNZ---------*/
	oStruCNZ:AddTrigger('CNZ_PERC', 'CNZ_VALOR1', /*bPre*/,{|a,b,c|Cn121AtuRat(Nil, c,.T.)}	/*bSetValue*/ )
	aEval({'CNZ_VALOR1', 'CNZ_VALOR2', 'CNZ_VALOR3', 'CNZ_VALOR4', 'CNZ_VALOR5' }, {|x| oStruCNZ:SetProperty( x , MODEL_FIELD_WHEN, bFalseWhen ) })
	oStruCNZ:SetProperty("CNZ_PERC"  ,MODEL_FIELD_VALID,MTBlcVld("CNZ","CNZ_PERC"	,"A121VldPerc(a,c,0,d)",.F.,.F., .T.) )

	CfgFldsParc(IIF(CXNParcTp9(), oStruCXN, oStruCND))/*Configura no struct os campos parcelas do tipo 9*/

	oStruCNR1:AddTrigger("CNR_VALOR", "CNR_MODO", {||.T.}, bModoTrigg)
	oStruCNR2:AddTrigger("CNR_VALOR", "CNR_MODO", {||.T.}, bModoTrigg)

	//-- Cria a estrutura basica
	oModel:= MPFormModel():New("CNTA121", /*Pre-Validacao*/,{|oModel|Cn121TudOK(oModel)}/*Pos-Validacao*/,{|| CN121GRV(oModel)}/*Commit*/,/*Cancel*/)

	//--	Adiciona o componente de formulario no model
	oModel:AddFields("CNDMASTER",/*cOwner*/,oStruCND,/*bPreCND*/,bPosCND)

	//-- Adiciona Grids e outros Fields Filhos
	oModel:AddGrid('CXNDETAIL','CNDMASTER',oStruCXN, { |oModelGrid,  nLine,cAction,  cField, xValue, xOldValue| Cn121CXNPV(oModelGrid, nLine, cAction, cField, xValue, xOldValue) }/*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)
	oModel:AddGrid('CNEDETAIL','CXNDETAIL',oStruCNE, { |oModelGrid,  nLine,cAction,  cField, xValue, xOldValue| Cn121CNEPV(oModelGrid, nLine, cAction, cField, xValue, xOldValue) }/*bPreValidacao*/, bLinPosCNE ,/*bCarga*/)
	oModel:AddGrid('CXMDETAIL','CXNDETAIL',oStruCXM)
	oModel:AddGrid('CNUDETAIL','CNDMASTER',oStruCNU)

	//- Estrutura das multas, adiantamentos, bonificações e descontos.
	oModel:AddGrid('CNRDETAIL1','CXNDETAIL',oStruCNR1,{ |oModelGrid,  nLine,cAction,  cField, xValue, xOldValue| Cn121CNR1(oModelGrid, nLine, cAction, cField, xValue, xOldValue) }/*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)
	oModel:AddGrid('CNQDETAIL' ,'CXNDETAIL',oStruCNQ, { |oModelGrid,  nLine,cAction,  cField, xValue, xOldValue| Cn121CNQPV(oModelGrid, nLine, cAction, cField, xValue, xOldValue) }/*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)
	oModel:AddGrid('CNRDETAIL2','CNEDETAIL',oStruCNR2,{ |oModelGrid,  nLine,cAction,  cField, xValue, xOldValue| Cn121CNR2(oModelGrid, nLine, cAction, cField, xValue, xOldValue) }/*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)

	oModel:AddGrid('CNKDETAIL' ,'CNDMASTER',oStruCNK)

	oModel:AddGrid('CXIDETAIL' ,'CXNDETAIL',oStruCXI,{ |oModelGrid,  nLine,cAction,  cField, xValue, xOldValue| Cn121CXIPV(oModelGrid, nLine, cAction, cField, xValue, xOldValue) }/*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)
	oModel:AddGrid('CXJDETAIL' ,'CXNDETAIL',oStruCXJ)

	//- Estrutura de Rateio
	oModel:AddGrid('CNZDETAIL'	,'CNEDETAIL',oStruCNZ, bLinPreCNZ/*bLinePre*/, bLinPosCNZ/*bLinePost*/, /*bPre*/, /*bPost*/,/*bLoad*/)

	//- Estrutura Multiplas Naturezas
	oModel:AddGrid('CXODETAIL','CXNDETAIL',oStruCXO,bPreVlCXO,{|oModelGrid| MNatPosCXO(.T.,oModelGrid)})
	oModel:AddGrid('CXPDETAIL','CXODETAIL',oStruCXP,bPreVlCXP,{|oModelGrid| MNatPosCXP(.T.,oModelGrid)})

	//- Adiciona valor maximo de linhas da grid	
	aEval({'CNEDETAIL','CXJDETAIL'},{|cId| oModel:GetModel(cId):SetMaxLine( SuperGetMV("MV_COMLMAX",.F.,99999) ) })

	//-Adiciona Totalizadores ao modelo
	oModel:AddCalc('TOTMED','CNDMASTER','CXNDETAIL','CXN_VLPREV','CND_VLPREV','FORMULA'	,bVldCalc,,NomeSX3('CND_VLPREV'),{|oModel,nVlrAtu,xValor,lSoma| Cn121VlrTt(oModel,nVlrAtu,xValor,lSoma,'CND_VLPREV')})
	oModel:AddCalc('TOTMED','CNDMASTER','CXNDETAIL','CXN_VLLIQD','CND_VLLIQD','FORMULA'	,bVldCalc,,NomeSX3('CND_VLLIQD'),{|oModel,nVlrAtu,xValor,lSoma| Cn121VlrTt(oModel,nVlrAtu,xValor,lSoma,'CND_VLLIQD')})
	oModel:AddCalc('TOTMED','CNDMASTER','CXNDETAIL','CXN_VLMULT','CND_VLMULT','FORMULA'	,bVldCalc,,NomeSX3('CND_VLMULT'),{|oModel,nVlrAtu,xValor,lSoma| Cn121VlrTt(oModel,nVlrAtu,xValor,lSoma,'CND_VLMULT')})
	oModel:AddCalc('TOTMED','CNDMASTER','CXNDETAIL','CXN_VLBONI','CND_VLBONI','FORMULA'	,bVldCalc,,NomeSX3('CND_VLBONI'),{|oModel,nVlrAtu,xValor,lSoma| Cn121VlrTt(oModel,nVlrAtu,xValor,lSoma,'CND_VLBONI')})

	If CND->(FieldPos("CND_VLMPED")) > 0 .And. CND->(FieldPos("CND_VLBPED")) > 0 .And. CXN->(FieldPos("CXN_VLMPED")) > 0 .And. CXN->(FieldPos("CXN_VLBPED")) > 0
		oModel:AddCalc('TOTMED','CNDMASTER','CXNDETAIL','CXN_VLMPED','CND_VLMPED','FORMULA'	,bVldCalc,,NomeSX3('CND_VLMPED'),{|oModel,nVlrAtu,xValor,lSoma| Cn121VlrTt(oModel,nVlrAtu,xValor,lSoma,'CND_VLMPED')})
		oModel:AddCalc('TOTMED','CNDMASTER','CXNDETAIL','CXN_VLBPED','CND_VLBPED','FORMULA'	,bVldCalc,,NomeSX3('CND_VLBPED'),{|oModel,nVlrAtu,xValor,lSoma| Cn121VlrTt(oModel,nVlrAtu,xValor,lSoma,'CND_VLBPED')})
	EndIf

	oModel:AddCalc('TOTMED','CNDMASTER','CXNDETAIL','CXN_VLDESC','CND_DESCME','FORMULA'	,bVldCalc,,NomeSX3('CND_DESCME'),{|oModel,nVlrAtu,xValor,lSoma| Cn121VlrTt(oModel,nVlrAtu,xValor,lSoma,'CND_DESCME')})
	oModel:AddCalc('TOTMED','CNDMASTER','CXNDETAIL','CXN_VLRADI','CND_TOTADT','FORMULA'	,bVldCalc,,NomeSX3('CND_TOTADT'),{|oModel,nVlrAtu,xValor,lSoma| Cn121VlrTt(oModel,nVlrAtu,xValor,lSoma,'CND_TOTADT')})
	oModel:AddCalc('TOTMED','CNDMASTER','CXNDETAIL','CXN_VLTOT' ,'CND_RETCAC','FORMULA'	,bVldCalc,,NomeSX3('CND_RETCAC'),{|oModel,nVlrAtu,xValor,lSoma| Cn121VlrMd(oModel,nVlrAtu,xValor,lSoma,'CND_RETCAC')})
	oModel:AddCalc('TOTMED','CNDMASTER','CXNDETAIL','CXN_VLTOT' ,'CND_VLTOT' ,'FORMULA'	,bVldCalc,,NomeSX3('CND_VLTOT' ),{|oModel,nVlrAtu,xValor,lSoma| Cn121VlrMd(oModel,nVlrAtu,xValor,lSoma,'CND_VLTOT' )})

	oModel:AddCalc('CALC_CNZ','CNEDETAIL','CNZDETAIL','CNZ_PERC','CNZ_TOTRAT','SUM',,, RetTitle("CNZ_PERC"))

	//-- Seta relacao entre os grids
	oModel:SetRelation('CXNDETAIL', {{'CXN_FILIAL','xFilial("CXN")'},{'CXN_CONTRA','CND_CONTRA'},{'CXN_REVISA','CND_REVISA'},{'CXN_NUMMED','CND_NUMMED'}},CXN->(IndexKey(1)))
	oModel:SetRelation('CNEDETAIL', {{'CNE_FILIAL','xFilial("CNE")'},{'CNE_CONTRA','CND_CONTRA'},{'CNE_REVISA','CND_REVISA'},{'CNE_NUMERO','CXN_NUMPLA'},{'CNE_NUMMED','CND_NUMMED'}},CNE->(IndexKey(1)))
	oModel:SetRelation('CNQDETAIL', {{'CNQ_FILIAL','xFilial("CNQ")'},{'CNQ_CONTRA','CND_CONTRA'},{'CNQ_NUMMED','CND_NUMMED'},{'CNQ_NUMPLA','CXN_NUMPLA'}},CNQ->(IndexKey(3)))

	aRelatCNU := {{'CNU_FILIAL','xFilial("CNU", CND_FILCTR)'},{'CNU_CONTRA','CND_CONTRA'}}

	If CNURevisa()
		aAdd(aRelatCNU,{'CNU_REVISA', 'CND_REVISA'})
	EndIf

	oModel:SetRelation('CNUDETAIL', aRelatCNU,CNU->(IndexKey(1)))
	oModel:SetRelation('CXMDETAIL', {{'CXM_FILIAL','xFilial("CXM")'},{'CXM_CONTRA','CND_CONTRA'},{'CXM_REVISA','CND_REVISA'},{'CXM_NUMERO','CXN_NUMPLA'}},CXM->(IndexKey(1)))
	oModel:SetRelation('CNKDETAIL', {{'CNK_FILIAL','xFilial("CNK")'},{'CNK_CONTRA','CND_CONTRA'}},CNK->(IndexKey(3)))
	oModel:SetRelation('CNRDETAIL1',{{'CNR_FILIAL','xFilial("CNR")'},{'CNR_CONTRA','CXN_CONTRA'},{'CNR_NUMMED','CND_NUMMED'},{'CNR_CODPLA','CXN_NUMPLA'},{'CNR_ITEM','Space(TamSX3("CNE_ITEM")[1])'}},CNR->(IndexKey(3))) //CNR_FILIAL+CNR_CONTRA+CNR_NUMMED+CNR_CODPLA+CNR_ITEM
	oModel:SetRelation('CNRDETAIL2',{{'CNR_FILIAL','xFilial("CNR")'},{'CNR_CONTRA','CXN_CONTRA'},{'CNR_NUMMED','CND_NUMMED'},{'CNR_CODPLA','CXN_NUMPLA'},{'CNR_ITEM','CNE_ITEM'}},CNR->(IndexKey(3)))
	oModel:SetRelation('CNZDETAIL', {{'CNZ_FILIAL','xFilial("CNE")'},{'CNZ_CONTRA','CND_CONTRA'},{'CNZ_REVISA','CND_REVISA'},{'CNZ_NUMMED','CND_NUMMED'},{'CNZ_CODPLA','CXN_NUMPLA'},{'CNZ_FORNEC','CXN_FORNEC'},{'CNZ_LJFORN','CXN_LJFORN'},{'CNZ_CLIENT','CXN_CLIENT'},{'CNZ_LOJACL','CXN_LJCLI'},{'CNZ_ITCONT','CNE_ITEM'}},CNZ->(IndexKey(5)))
	oModel:SetRelation('CXIDETAIL', {{'CXI_FILIAL','xFilial("CXI")'},{'CXI_CONTRA','CND_CONTRA'},{'CXI_REVISA','CND_REVISA'},{"CXI_NUMPLA","CXN_NUMPLA"}},CXI->(IndexKey(1)))
	oModel:SetRelation('CXJDETAIL', {{'CXJ_FILIAL','xFilial("CXJ")'},{'CXJ_CONTRA','CND_CONTRA'}/*,{'CXJ_REVISA','CND_REVISA'}*/,{"CXJ_NUMPLA","CXN_NUMPLA"},{"CXJ_NUMMED","CND_NUMMED"}},CXJ->(IndexKey(1)))

	For nX := 1 To Len(aCTBEnt)
		If CXP->(FieldPos("CXP_EC" +aCTBEnt[nX] +"CR")) > 0
			aAdd(aCamposCXP,"CXP_EC" +aCTBEnt[nX] +"CR")
			aAdd(aCamposCXP,"CXP_EC" +aCTBEnt[nX] +"DB")
		EndIf

	Next nX

	oModel:SetRelation('CXODETAIL', {{'CXO_FILIAL','xFilial("CXO")'},{'CXO_CONTRA','CND_CONTRA'},{'CXO_REVISA','CND_REVISA'},{'CXO_NUMMED','CND_NUMMED'},{'CXO_NUMPLA','CXN_NUMPLA'}},CXO->(IndexKey(1)))
	oModel:SetRelation('CXPDETAIL', {{'CXP_FILIAL','xFilial("CXP")'},{'CXP_CONTRA','CND_CONTRA'},{'CXP_REVISA','CND_REVISA'},{'CXP_NUMMED','CND_NUMMED'},{'CXP_NUMPLA','CXN_NUMPLA'},{'CXP_ITMNAT','CXO_ITEM'}},CXP->(IndexKey(1)))

	oModel:GetModel('CXODETAIL'):SetUniqueLine({"CXO_NATURE"})
	oModel:GetModel('CXPDETAIL'):SetUniqueLine(aCamposCXP)

	ConfMdlDoc(oModel) /*Configura em <oModel> os submodelos dos documentos(Títulos/Pedidos:SE1,SE2,SC5 e SC7)*/
	ConfMldCZY(oModel) /*Configura em <oModel> o submodelo dos Adiantamentos(CZY)*/

	//-- Configura o model
	oModel:SetPrimaryKey( {} ) //Obrigatorio setar a chave primaria (mesmo que vazia)

	//-- Ativa Modelo somente para visualização
	oModel:GetModel('CXMDETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('CNKDETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('CXIDETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('CNUDETAIL'):SetOnlyQuery(.T.)

	//Modelos de Preenchimento Não Obrigatorio
	oModel:GetModel('CXMDETAIL'):SetOptional(.T.)
	oModel:GetModel('CNEDETAIL'):SetOptional(.T.)
	oModel:GetModel('CNKDETAIL'):SetOptional(.T.)
	oModel:GetModel('CNQDETAIL'):SetOptional(.T.)
	oModel:GetModel('CNRDETAIL1'):SetOptional(.T.)
	oModel:GetModel('CNRDETAIL2'):SetOptional(.T.)
	oModel:GetModel('CNZDETAIL'):SetOptional(.T.)
	oModel:GetModel('CXIDETAIL'):SetOptional(.T.)
	oModel:GetModel('CXJDETAIL'):SetOptional(.T.)
	oModel:GetModel('CNUDETAIL'):SetOptional(.T.)
	oModel:GetModel('CXODETAIL'):SetOptional(.T.)
	oModel:GetModel('CXPDETAIL'):SetOptional(.T.)

	//-- Desabilita alteracoes nas grids que são somente leitura
	CNTA300BlMd(oModel:GetModel('CNKDETAIL'),.T.)
	CNTA300BlMd(oModel:GetModel('CXIDETAIL'),.T.)
	CNTA300BlMd(oModel:GetModel('CXNDETAIL'),.T., .T.)//Libera apenas atualização

	If lExced .And. lExcedMEnc
		CNTA300BlMd(oModel:GetModel("CXNDETAIL"),.T.)
		CNTA300BlMd(oModel:GetModel("CNEDETAIL"),.T.)
		CNTA300BlMd(oModel:GetModel("CNRDETAIL1"),.T.)
		CNTA300BlMd(oModel:GetModel("CNQDETAIL"),.T.)
		CNTA300BlMd(oModel:GetModel("CNRDETAIL2"),.T.)
	EndIf

	//-- Define as chaves unicas.
	oModel:GetModel('CNQDETAIL'):SetUniqueLine({"CNQ_TPDESC"})	
	

	oModel:SetVldActivate({|oModel| CN121VlAct(oModel)})
	oModel:SetActivate({|oModel| CN121Act(oModel)})
	oModel:SetDeActivate({|oModel| CN121DeAct(oModel)})

	oModel:SetOnDemand(.T.)

	If ExistBlock("C121MCPO")
		ExecBlock("C121MCPO",.F.,.F.,{oModel})//PE C121MCPO para manipular a estrutura do Model
	EndIf
Return oModel

//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Jose Eulalio
@since 27/07/2015
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   	:= FWLoadModel( "CNTA121" )	 //Carrega model definido
	//- Listagem de campos para cada modelo (Finalizar string com '|')
	Local cCampoCND := CNDViewCpo()
	Local cCampoCNE := "CNE_FILIAL|CNE_CONTRA|CNE_REVISA|CNE_NUMMED|CNE_NUMERO|CNE_TIPO|CNE_DTANIV|CNE_ITSOMA|CNE_QTRETI|CNE_PEDIDO|CNE_TS|CNE_TE|CNE_FLGCMS|CNE_QTDORI|CNE_VUNORI|CNE_CRONOG|CNE_QTAMED|CNE_15ANOS|CNE_20ANOS|CNE_25ANOS|CNE_TPSERV|CNE_VLMPED|CNE_VLBPED|"
	Local cCampoCNR := "CNR_NUMMED|CNR_CONTRA|CNR_CODIGO|CNR_CODPLA|CNR_ITEM|"
	Local cCampoCNQ := "CNQ_FILIAL|CNQ_CONTRA|CNQ_NUMMED|CNQ_NUMPLA|"
	Local cCampoCNZ := "CNZ_CONTRA|CNZ_REVISA|CNZ_ITCONT|CNZ_CODPLA|CNZ_NUMMED|CNZ_FORNEC|CNZ_LJFORN|CNZ_CLIENT|CNZ_LOJACL|"
	Local cCampoCXN := "CXN_CONTRA|CXN_REVISA|CXN_NUMMED|CXN_CRONCT|CXN_DTMXMD|CXN_VLCOMS|CXN_VLMPED|CXN_VLBPED|"
	Local cCampoCXO := "CXO_CONTRA|CXO_NUMMED|CXO_REVISA|CXO_NUMPLA|"
	Local cCampoCXP := "CXP_CONTRA|CXP_NUMMED|CXP_REVISA|CXP_NUMPLA|CXP_ITMNAT|"
	Local cCampoCZY := "CZY_FILIAL|CZY_CONTRA|CZY_NUMMED|CZY_NUMPLA|CZY_REVISA|"
	//- Preparação de estruturas da View
	Local oStruCND	:= FWFormStruct(2,'CND', {|cCampo|  AllTrim(cCampo)+'|' $ cCampoCND})
	Local oStruCND2 := FWCalcStruct(oModel:GetModel('TOTMED'))
	Local oStruCNE	:= FWFormStruct(2,'CNE', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCNE})
	Local oStruCNK	:= FWFormStruct(2,'CNK')
	Local oStruCNR1	:= FWFormStruct(2,'CNR', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCNR})
	Local oStruCNR2	:= FWFormStruct(2,'CNR', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCNR})
	Local oStruCNQ	:= FWFormStruct(2,'CNQ', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCNQ})
	Local oStruCNZ	:= FWFormStruct(2,'CNZ', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCNZ})
	Local oStruCXN	:= FWFormStruct(2,'CXN', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCXN})
	Local oStruCZY	:= FWFormStruct(2,'CZY', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCZY})

	Local oStruCXO	:= FWFormStruct(2,'CXO', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCXO})
	Local oStruCXP	:= FWFormStruct(2,'CXP', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCXP})
	Local oCalcCNZ 	:= FWCalcStruct(oModel:GetModel('CALC_CNZ'))

	Local oView		:= FWFormView():New()
	Local lCompra	:= CN121RetSt( "COMPRA", 0,, CND->CND_CONTRA, .F. )
	Local lMultNat	:= SuperGetMv('MV_MULNATP',.F.,.F.) .Or. SuperGetMv('MV_MULNATR',.F.,.F.)
	Local aCpsNoAlt	:= {}

	oStruCND:AddField("CND_RCCOMP"	,;	// [01]  C   Nome do Campo
					"06"			,;	// [02]  C   Ordem
					STR0061 		,;	// [03]  C   Titulo do campo
					STR0061			,;	// [04]  C   Descricao do campo
					oStruCND:GetProperty("CND_COMPET", MVC_VIEW_HELP)			,;	// [05]  A   Array com Help
					"C"				,;	// [06]  C   Tipo do campo
					"@!"			,;	// [07]  C   Picture
					NIL				,;	// [08]  B   Bloco de Picture Var
					NIL				,;	// [09]  C   Consulta F3
					.T.				,;	// [10]  L   Indica se o campo é alteravel
					oStruCND:GetProperty("CND_COMPET", MVC_VIEW_FOLDER_NUMBER)	,;	// [11]  C   Pasta do campo
					oStruCND:GetProperty("CND_COMPET", MVC_VIEW_GROUP_NUMBER)	,;	// [12]  C   Agrupamento do campo
					{Space(10)}		,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL				,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL				,;	// [15]  C   Inicializador de Browse
					.T.				,;	// [16]  L   Indica se o campo é virtual
					NIL				,;	// [17]  C   Picture Variavel
					NIL				)	// [18]  L   Indica pulo de linha após o campo

	oStruCXN:AddField("CXN_FORCLI"	,;	// [01]  C   Nome do Campo
					"14"			,;	// [02]  C   Ordem
					STR0062			,;	// [03]  C   Titulo do campo
					STR0063			,;	// [04]  C   Descricao do campo
					NIL				,;	// [05]  A   Array com Help
					"C"				,;	// [06]  C   Tipo do campo
					"@!"			,;	// [07]  C   Picture
					NIL				,;	// [08]  B   Bloco de Picture Var
					"CNC001"		,;	// [09]  C   Consulta F3
					.T.				,;	// [10]  L   Indica se o campo é alteravel
					NIL				,;	// [11]  C   Pasta do campo
					NIL				,;	// [12]  C   Agrupamento do campo
					NIL				,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL				,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL				,;	// [15]  C   Inicializador de Browse
					.T.				,;	// [16]  L   Indica se o campo é virtual
					NIL				,;	// [17]  C   Picture Variavel
					NIL				)	// [18]  L   Indica pulo de linha após o campo

	oStruCXN:AddField("CXN_LOJA"	,;	// [01]  C   Nome do Campo
					"15"			,;	// [02]  C   Ordem
					STR0064 		,;	// [03]  C   Titulo do campo
					STR0065			,;	// [04]  C   Descricao do campo
					NIL				,;	// [05]  A   Array com Help
					"C"				,;	// [06]  C   Tipo do campo
					"@!"			,;	// [07]  C   Picture
					NIL				,;	// [08]  B   Bloco de Picture Var
					NIL				,;	// [09]  C   Consulta F3
					.T.				,;	// [10]  L   Indica se o campo é alteravel
					NIL				,;	// [11]  C   Pasta do campo
					NIL				,;	// [12]  C   Agrupamento do campo
					NIL				,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL				,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL				,;	// [15]  C   Inicializador de Browse
					.T.				,;	// [16]  L   Indica se o campo é virtual
					NIL				,;	// [17]  C   Picture Variavel
					NIL				)	// [18]  L   Indica pulo de linha após o campo

	oStruCXN:AddField("CXN_IGITEM"	,;	// [01]  C   Nome do Campo
					"16"			,;	// [02]  C   Ordem
					STR0192			,;	// [03]  C   Titulo do campo - Ignora Item Bloq.
					STR0193			,;	// [04]  C   Descricao do campo - Ignora itens inconsistentes da planilha.
					NIL				,;	// [05]  A   Array com Help
					"L"				,;	// [06]  C   Tipo do campo
					"@!"			,;	// [07]  C   Picture
					NIL				,;	// [08]  B   Bloco de Picture Var
					NIL				,;	// [09]  C   Consulta F3
					.T.				,;	// [10]  L   Indica se o campo é alteravel
					NIL				,;	// [11]  C   Pasta do campo
					NIL				,;	// [12]  C   Agrupamento do campo
					NIL				,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL				,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL				,;	// [15]  C   Inicializador de Browse
					.T.				,;	// [16]  L   Indica se o campo é virtual
					NIL				,;	// [17]  C   Picture Variavel
					NIL				)	// [18]  L   Indica pulo de linha após o campo					)
					
	oStruCNE:AddField('CNE_TES'	,;	// [01]  C   Nome do Campo
					'15'		,;	// [02]  C   Ordem
					STR0066		,;	// [03]  C   Titulo do campo
					STR0067		,;	// [04]  C   Descricao do campo
					NIL			,;	// [05]  A   Array com Help
					'C'			,;	// [06]  C   Tipo do campo
					'@!'		,;	// [07]  C   Picture
					NIL			,;	// [08]  B   Bloco de Picture Var
					'SF4'		,;	// [09]  C   Consulta F3
					.T.			,;	// [10]  L   Indica se o campo é alteravel
					NIL			,;	// [11]  C   Pasta do campo
					NIL			,;	// [12]  C   Agrupamento do campo
					NIL			,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL			,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL			,;	// [15]  C   Inicializador de Browse
					.T.			,;	// [16]  L   Indica se o campo é virtual
					NIL			,;	// [17]  C   Picture Variavel
					NIL			)	// [18]  L   Indica pulo de linha após o campo

	oStruCNE:AddField("CNE_SDAMED"			,;	// [01]  C   Nome do Campo
					"07"					,;	// [02]  C   Ordem
					STR0068 				,;	// [03]  C   Titulo do campo
					STR0069					,;	// [04]  C   Descricao do campo
					NIL						,;	// [05]  A   Array com Help
					'N'						,;	// [06]  C   Tipo do campo
					X3Picture("CNE_QTAMED")	,;	// [07]  C   Picture
					NIL						,;	// [08]  B   Bloco de Picture Var
					NIL						,;	// [09]  C   Consulta F3
					.F.						,;	// [10]  L   Indica se o campo é alteravel
					NIL						,;	// [11]  C   Pasta do campo
					NIL						,;	// [12]  C   Agrupamento do campo
					NIL						,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL						,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL						,;	// [15]  C   Inicializador de Browse
					.T.						,;	// [16]  L   Indica se o campo é virtual
					NIL						,;	// [17]  C   Picture Variavel
					NIL						)	// [18]  L   Indica pulo de linha após o campo

	oStruCZY:AddField("CZY_DTADT"			,;	// [01]  C   Nome do Campo
					"08"					,;	// [02]  C   Ordem
					STR0220 				,;	// [03]  C   Titulo do campo
					STR0221					,;	// [04]  C   Descricao do campo
					NIL						,;	// [05]  A   Array com Help
					'D'						,;	// [06]  D   Tipo do campo
					""	                    ,;	// [07]  C   Picture
					NIL						,;	// [08]  B   Bloco de Picture Var
					NIL						,;	// [09]  C   Consulta F3
					.F.						,;	// [10]  L   Indica se o campo é alteravel
					NIL						,;	// [11]  C   Pasta do campo
					NIL						,;	// [12]  C   Agrupamento do campo
					NIL						,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL						,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL						,;	// [15]  C   Inicializador de Browse
					.T.						,;	// [16]  L   Indica se o campo é virtual
					NIL						,;	// [17]  C   Picture Variavel
					NIL						)	// [18]  L   Indica pulo de linha após o campo

	oStruCZY:AddField("CZY_VLADT"			,;	// [01]  C   Nome do Campo
					"08"					,;	// [02]  C   Ordem
					STR0222 	            ,;	// [03]  C   Titulo do campo
					STR0223	                ,;	// [04]  C   Descricao do campo
					NIL						,;	// [05]  A   Array com Help
					'N'						,;	// [06]  D   Tipo do campo
					PesqPict("CNX","CNX_VLADT")		                 ,;	// [07]  C   Picture
					NIL						,;	// [08]  B   Bloco de Picture Var
					NIL						,;	// [09]  C   Consulta F3
					.F.						,;	// [10]  L   Indica se o campo é alteravel
					NIL						,;	// [11]  C   Pasta do campo
					NIL						,;	// [12]  C   Agrupamento do campo
					NIL						,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL						,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL						,;	// [15]  C   Inicializador de Browse
					.T.						,;	// [16]  L   Indica se o campo é virtual
					NIL						,;	// [17]  C   Picture Variavel
					NIL						)	// [18]  L   Indica pulo de linha após o campo

	oStruCZY:AddField("CZY_SALDO"			,;	// [01]  C   Nome do Campo
					"08"					,;	// [02]  C   Ordem
					STR0224 	            ,;	// [03]  C   Titulo do campo
					STR0225                 ,;	// [04]  C   Descricao do campo
					NIL						,;	// [05]  A   Array com Help
					'N'						,;	// [06]  D   Tipo do campo
					PesqPict("CNX", "CNX_SALDO")	                    ,;	// [07]  C   Picture
					NIL						,;	// [08]  B   Bloco de Picture Var
					NIL						,;	// [09]  C   Consulta F3
					.F.						,;	// [10]  L   Indica se o campo é alteravel
					NIL						,;	// [11]  C   Pasta do campo
					NIL						,;	// [12]  C   Agrupamento do campo
					NIL						,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL						,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL						,;	// [15]  C   Inicializador de Browse
					.T.						,;	// [16]  L   Indica se o campo é virtual
					NIL						,;	// [17]  C   Picture Variavel
					NIL						)	// [18]  L   Indica pulo de linha após o campo



	oStruCXN:SetProperty( "CXN_DTINI", MVC_VIEW_ORDEM, "12" )
	oStruCXN:SetProperty( "CXN_DTFIM", MVC_VIEW_ORDEM, "13" )

	//-- Associa o View ao Model
	oView:SetModel(oModel)  //-- Define qual o modelo de dados será utilizado

	//-- Insere os componentes na View
	oView:AddField('VIEW_CND'	,oStruCND	,'CNDMASTER')   //Cabecalho
	oView:AddField('VIEW_CND2'	,oStruCND2	,'TOTMED')
	oView:AddGrid('VIEW_CXN'	,oStruCXN	,'CXNDETAIL')
	oView:AddGrid('VIEW_CNE'	,oStruCNE	,'CNEDETAIL')

	oView:AddGrid('VIEW_CNK'	,oStruCNK	,'CNKDETAIL')
	oView:AddGrid('VIEW_CNR1'	,oStruCNR1	,'CNRDETAIL1')
	oView:AddGrid('VIEW_CNQ'	,oStruCNQ	,'CNQDETAIL')
	oView:AddGrid('VIEW_CNR2'	,oStruCNR2	,'CNRDETAIL2')
	oView:AddGrid('VIEW_CNZ'	,oStruCNZ	,'CNZDETAIL')
	oView:AddGrid('VIEW_CZY'    ,oStruCZY   ,'CZYDETAIL')

	//-- Cria os Box's
	oView:CreateHorizontalBox("CABEC",30) //Cabeçalho
	oView:CreateHorizontalBox("PLANI",70) //Planilhas

	//-- Cria a pasta e planilhas da Manutencao de Contratos
	oView:CreateFolder('FLDCND','CABEC')
	oView:CreateFolder('FLDCXN','PLANI')

	oView:AddSheet('FLDCND','GRDCABEC',STR0129) //- Medições
	oView:CreateHorizontalBox('MEDICAO' ,100,/*owner*/,/*lUsePixel*/,'FLDCND','GRDCABEC')

	oView:AddSheet('FLDCND','GRDTOTMD',STR0130) //- Totais
	oView:CreateHorizontalBox('TOTMD' ,100,/*owner*/,/*lUsePixel*/,'FLDCND','GRDTOTMD')

	oView:AddSheet('FLDCXN','GRDPLAN',STR0131) //- Planilhas
	oView:CreateHorizontalBox('PLANILHA' ,40,/*owner*/,/*lUsePixel*/,'FLDCXN','GRDPLAN')
	oView:CreateHorizontalBox('ITENS' ,60,/*owner*/,/*lUsePixel*/,'FLDCXN','GRDPLAN')
	oView:CreateFolder('FLDCNE','ITENS')

	oView:AddSheet('FLDCXN','GRDMULT1',STR0132) //- Multas/Bonif. da Planilha
	oView:CreateHorizontalBox('MULTAS1' ,100,/*owner*/,/*lUsePixel*/,'FLDCXN','GRDMULT1')

	oView:AddSheet('FLDCXN','GRDDESC',STR0133) //- Descontos
	oView:CreateHorizontalBox('DESCONTOS',100,/*owner*/,/*lUsePixel*/,'FLDCXN','GRDDESC')

	If !lInclui
		CfgViewDoc(oView, lCompra, 'FLDCXN')/*Configura a view dos documentos(pedidos ou títulos)*/
	EndIf

	oView:AddSheet('FLDCXN','GRDDOCS',STR0136) //- Documentos
	oView:CreateHorizontalBox('DOCS' ,100,/*owner*/,/*lUsePixel*/,'FLDCXN','GRDDOCS')

	oView:AddSheet('FLDCXN','GRDADIA',STR0116) //- Adiantamentos
	oView:CreateHorizontalBox('ADIANTAMENTOS',100,/*owner*/,/*lUsePixel*/,'FLDCXN','GRDADIA')
	oView:AddSheet('FLDCNE','GRDITENS',STR0137) //- Itens
	oView:CreateHorizontalBox('GITENS' ,100,/*owner*/,/*lUsePixel*/,'FLDCNE','GRDITENS')

	oView:AddSheet('FLDCNE','GRDRATEIO',STR0138) //- Rateio Contabil
	oView:CreateHorizontalBox('RATEIO' ,75,/*owner*/,/*lUsePixel*/,'FLDCNE','GRDRATEIO')

	oView:AddField('VCNZTOT', oCalcCNZ, 'CALC_CNZ')
	oView:SetViewProperty( "VCNZTOT", "SETLAYOUT", {FF_LAYOUT_HORZ_DESCR_LEFT, 1} )
	oView:CreateHorizontalBox('TOTRAT' ,25, /**/,/*lUsePixel*/,'FLDCNE','GRDRATEIO')
	oView:SetOwnerView("VCNZTOT", "TOTRAT")

	oView:AddSheet('FLDCNE','GRDMULT2',STR0139) //- Multas/Bonif. do Item
	oView:CreateHorizontalBox('MULTAS2' ,100,/*owner*/,/*lUsePixel*/,'FLDCNE','GRDMULT2')

	If lMultNat
		oView:AddGrid('VIEW_CXO',oStruCXO,'CXODETAIL')
		oView:AddGrid('VIEW_CXP',oStruCXP,'CXPDETAIL')
		
		oView:AddSheet('FLDCXN','ABANTM',STR0165) 		//"Naturezas Multiplas"
		oView:CreateHorizontalBox('GRDNTM',40,/*owner*/,/*lUsePixel*/,'FLDCXN','ABANTM')
		oView:CreateHorizontalBox('GRDCCM',60,/*owner*/,/*lUsePixel*/,'FLDCXN','ABANTM')
		oView:SetOwnerView('VIEW_CXO','GRDNTM')
		oView:SetOwnerView('VIEW_CXP','GRDCCM')
		
		oView:AddIncrementField('VIEW_CXO','CXO_ITEM')
		oView:AddIncrementField('VIEW_CXP','CXP_ITEM')
	EndIf

	//-- Associa os componentes as pastas
	oView:SetOwnerView("VIEW_CND"	,"MEDICAO")
	oView:SetOwnerView("VIEW_CND2"	,"TOTMD")
	oView:SetOwnerView("VIEW_CXN"	,"PLANILHA")
	oView:SetOwnerView("VIEW_CNK"	, "DOCS")
	oView:SetOwnerView("VIEW_CNR1"	,"MULTAS1")
	oView:SetOwnerView("VIEW_CNQ" 	,"DESCONTOS")
	oView:SetOwnerView("VIEW_CZY"	, "ADIANTAMENTOS")
	oView:SetOwnerView("VIEW_CNE"	,"GITENS")
	oView:SetOwnerView("VIEW_CNR2"	,"MULTAS2")
	oView:SetOwnerView("VIEW_CNZ"	, "RATEIO")
	
	oStruCND:RemoveField(IIF(lInclui .Or. lExcedNPrv, "CND_COMPET", "CND_RCCOMP"))//Durante a inclusão exibe campo virtual CND_RCCOMP, posteriormente exibe CND_COMPET 	

	//Remove campos Fornec/Cliente e exibe apenas o virtual CXN_FORCLI
	oStruCXN:RemoveField("CXN_FORNEC")
	oStruCXN:RemoveField("CXN_LJFORN")
	oStruCXN:RemoveField("CXN_CLIENT")
	oStruCXN:RemoveField("CXN_LJCLI")

	If (Iif(Type("lServico")=='L',lServico,.F.))
		oStruCNE:RemoveField("CNE_QTDORI")
		oStruCNE:RemoveField("CNE_VUNORI")
	EndIf

	If CND->(FieldPos("CND_VLMPED")) > 0 .And. CND->(FieldPos("CND_VLBPED")) > 0 //-- Remove totalizadores de multa e bonificação considerados no pedido
		oStruCND2:RemoveField("CND_VLMPED")
		oStruCND2:RemoveField("CND_VLBPED")
	EndIf
	
	oStruCNE:SetProperty('CNE_ITEMGR'	, MVC_VIEW_CANCHANGE, .F.)
	oStruCND:SetProperty('CND_CONTRA'	, MVC_VIEW_CANCHANGE, .T.)

	aCpsNoAlt := {	'CXN_VLTOT'	,;
					'CXN_VLLIQD',;
					'CXN_VLMULT',;
					'CXN_VLBONI'}
	aEval(aCpsNoAlt,{|x| oStruCXN:SetProperty(x, MVC_VIEW_CANCHANGE, .F.) })//Não permite a edição pelo usuário, apenas pela função <CnCXNTotVl>
	FwFreeArray(aCpsNoAlt)	

	oStruCNR1:SetProperty("CNR_MODO", MVC_VIEW_CANCHANGE, .F.)
	oStruCNR2:SetProperty("CNR_MODO", MVC_VIEW_CANCHANGE, .F.)

	If !(INCLUI .Or. ALTERA)
		oView:AddUserButton(STR0073,'BUDGET', {|| a120Posic("CND",CND->(Recno()),2,"IM",.F.)}) //"Log de Aprovação"
		oView:AddUserButton('Tracker','BUDGET', {|| Cn121Track(oModel)}) //"Tracker"
	EndIf

	If !(INCLUI)
		oView:AddUserButton(STR0074,'BUDGET', {|| CN121VFoCl(lCompra,oModel:GetValue('CXNDETAIL','CXN_FORCLI'),oModel:GetValue('CXNDETAIL','CXN_LOJA'))})	//- "Visualizar Forn./Cliente"
	EndIf

	oView:AddUserButton(STR0163,'BUDGET', {|x| CN121RatP(oModel,x) })	//- "Rateio Pré-Configurado"

	If CNE->(Columnpos('CNE_15ANOS'))
		oView:AddUserButton(STR0166,'BUDGET', {|| CNReinf(oModel) })
	EndIf

	oView:SetViewProperty( 'CXNDETAIL' , "CHANGELINE", {{ |oView, cViewID| Cn121ChgPl(,oView:getModel() ) }} )

	//- Adiciona campos Incrementais.
	oView:AddIncrementField('VIEW_CNE','CNE_ITEM')
	oView:AddIncrementField('VIEW_CNZ','CNZ_ITEM')

	If ExistBlock("C121VCPO")
		ExecBlock("C121VCPO",.F.,.F.,{oStruCND, oStruCXN, oStruCNE, oView})//PE C121VCPO para manipular campos na View
	EndIf
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121MedSer()
Função para identificação de Medições de Serviços.
@author israel.escorizza
@since 11/08/2015
@version 1.0
@Return FwExecView
/*/
//-------------------------------------------------------------------
Function CN121MedSer()
	lServico := .T.
	CfgIdMldDoc(MODEL_OPERATION_INSERT)
Return FWExecView(STR0077,"CNTA121",MODEL_OPERATION_INSERT,,{|| .T.})//""Medição de Serviços""

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121MedSer()
Função para identificação de Autorização de Fornecimento.
@author israel.escorizza
@since 11/08/2015
@version 1.0
@Return FwExecView
/*/
//-------------------------------------------------------------------
Function CN121AutFor()
	Cn121GAutF(.T., .T.)//Seta variável estática de Autorização de Fornecimento
	lInclui  := .T.
	aComp	 := {}

	CfgIdMldDoc(MODEL_OPERATION_INSERT)
	FWExecView(STR0076,"CNTA121",MODEL_OPERATION_INSERT,,{|| .T.})//"Aut. Fornecimento"

	Cn121GAutF(.F., .T.)//Seta variável estática de Autorização de Fornecimento
	lInclui  := .F.
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121Cbox()
Rotina para "transformar" o objeto Competências em ComboBox e
Carregar as Competências das Planilhas dos Contratos
@author miguel.santos
@since 23/07/2015
@version P12.1.7
/*/
//-------------------------------------------------------------------
Function CN121Cbox(aCompets,aCompSemN,cFilCTR)
Local oModel		:= FWModelActive()
Local oView			:= FWViewActive()
Local oModelStruct	:= NIL
Local lExistObj		:= .F.
Local lAuto			:= IsBlind()
Local lView			:= ValType(oView) == "O"
Local nX			:= 0
Default aCompSemN	:= {}

If !lAuto .And. lView
	lExistObj := oView:IsActive() .And. oView:GetModel():GetId() $ "CNTA121" 
Else
	lExistObj := .T.
EndIf

If lExistObj
	oModelStruct := oModel:GetModel('CNDMASTER'):GetStruct()

	If Empty(aCompSemN)
		aCompSemN := aClone(aCompets)
		For nX := 1 to Len(aCompets)
			aCompets[nX] := CVALTOCHAR(nX)+'='+aCompets[nX]
			aCompSemN[nX] := CVALTOCHAR(nX)
		Next nX
	EndIf
	aComp := aClone(aCompets)//<aComp> precisa ser atualizado antes da atualização de CND_RCCOMP

	//-- correção para permitir chamada da CNTA121 pela rotina automática CNTA260
	oModelStruct:SetProperty("CND_RCCOMP", MODEL_FIELD_VALUES,aCompSemN)

	//Tratativa para quando executar via robô, selecionar a primeira competência disponivel
	If lAuto .Or. !lView
		oModel:GetModel("CNDMASTER"):SetValue("CND_RCCOMP", Substr(aCompets[1], 1, 1))
	Else
		oView:SetFieldProperty("CNDMASTER","CND_RCCOMP","COMBOVALUES",{aCompets}) 
	EndIf
Else
	aComp := aClone(aCompets)
Endif

CN121SetCp(oModel:GetModel('CNDMASTER'),,,,cFilCTR,!lExistObj)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121Carga()
Carrega formulário da CND com valores do contrato da CN9
@author israel.escorizza
@since 11/08/2015
@version P12
/*/
//--------------------------------------------------------------------
Function Cn121Carga(cContra,cRev,lAuto)
Local aSaveLines	:= FwSaveRows()
Local aArea			:= GetArea()
Local oModel 	:= FWModelActive()
Local oModelCND	:= NIL
Local cFilCTR   := ""
Local cFilCN9	:= ""

Default cContra := ""
Default cRev	:= ""
Default lAuto	:= .F.

If ValType(oModel) == "O"
	oModelCND	:= oModel:GetModel("CNDMASTER")
	IIf (Empty(cContra), cContra := oModelCND:GetValue("CND_CONTRA"),)
	IIf (Empty(cRev), 	cRev 	 := oModelCND:GetValue("CND_REVISA"),)
	cFilCTR := oModelCND:GetValue("CND_FILCTR")
EndIf

If Empty(cFilCTR)
	cFilCTR := cFilAnt
EndIf

cFilCN9	:= xFilial( "CN9", cFilCTR )
CN9->(dbSetOrder(1)) //- CN9_FILIAL+CN9_NUMERO+CN9_REVISA
If CN9->(MsSeek(cFilCN9+cContra+cRev))
	
	oModelCND:LoadValue("CND_CONDPG",CN9->CN9_CONDPG)
	oModelCND:SetValue("CND_FILCTR",CN9->CN9_FILCTR)	
	oModelCND:SetValue("CND_SERVIC",IIf(A121Servico(1),'2','1'))

	If cPaisLoc == 'RUS'
		oModelCND:SetValue("CND_CONUNI" ,CN9->CN9_CONUNI )
	EndIf

EndIf

RestArea(aArea)
FWRestRows( aSaveLines )
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CnCNDTotVl()
Função para calculo do Total da planilha

@author israel.escorizza
@since 26/08/2015
@version P12
@return .T.
/*/
//--------------------------------------------------------------------
Function CnCNDTotVl()
Local lRet		:= .T.
Local lCposMBPed:= CND->(FieldPos("CND_VLMPED")) > 0 .And. CND->(FieldPos("CND_VLBPED")) > 0
Local oModel	:= FwModelActive()
Local oModelCND	:= oModel:GetModel('CNDMASTER')
Local nMod		:= IIf(Cn121RetSt('COMPRA',0,,oModelCND:GetValue('CND_CONTRA')),1,-1)
Local nVlPrev	:= oModelCND:GetValue('CND_VLLIQD')
Local nVlDesc	:= oModelCND:GetValue('CND_DESCME')
Local nVlMult	:= oModelCND:GetValue('CND_VLMULT')
Local nVlBoni	:= oModelCND:GetValue('CND_VLBONI')
Local nVlAdit	:= oModelCND:GetValue('CND_TOTADT')
Local nTotal	:= nVlPrev - nVlDesc - nVlAdit + (nMod * (nVlBoni  - nVlMult))
Local nRetCac	:= 0
Local nVlMPed	:= 0
Local nVlBPed	:= 0
Local nTotCauc	:= 0

If lCposMBPed //-- Calcula caução apenas com as multas/bonificações consideradas no pedido
    nVlMPed  := oModelCND:GetValue('CND_VLMPED')
    nVlBPed  := oModelCND:GetValue('CND_VLBPED')
    nTotCauc := nVlPrev - nVlDesc - nVlAdit + (nMod * (nVlBPed  - nVlMPed))
Else
    nTotCauc := nTotal
EndIf

nRetCac	:= CN121RetCa(nTotCauc, oModel)

oModelCND:SetValue('CND_VLTOT',Max(nTotal-nRetCac,0))

If (oModelCND:GetValue("CND_RETCAC") != nRetCac)
	oModelCND:SetValue("CND_RETCAC",nRetCac)	
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} CnCXNTotVl()
Função para calculo do Total da planilha

@author israel.escorizza
@since 26/08/2015
@version P12
@return .T.
/*/
//--------------------------------------------------------------------
Function CnCXNTotVl()
	Local lRet		:= .T.
	Local oModel 	:= FwModelActive()
	Local oModelCXN	:= oModel:GetModel('CXNDETAIL')
	Local nMod		:= Iif(Cn121RetSt('COMPRA',0,oModelCXN:GetValue('CXN_NUMPLA')),1,-1)
	Local nVlLiqd	:= oModelCXN:GetValueByPos(GetPosCpo(oModel,'CXN_VLLIQD'))
	Local nVlDesc	:= oModelCXN:GetValueByPos(GetPosCpo(oModel,'CXN_VLDESC'))
	Local nVlMult	:= oModelCXN:GetValueByPos(GetPosCpo(oModel,'CXN_VLMULT'))
	Local nVlBoni	:= oModelCXN:GetValueByPos(GetPosCpo(oModel,'CXN_VLBONI'))
	Local nTotal 	:= nVlLiqd + (nMod * (nVlBoni - nVlMult)) - nVlDesc
	Local cAtuFld	:= 'CXN_VLTOT'

	oModelCXN:SetValue(cAtuFld,Max(nTotal,0))
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121CXNPV()
Pré-valid da CXN (Planilha da Medição)

@author israel.escorizza
@since 26/08/2015
@version P12
@return .T.
/*/
//--------------------------------------------------------------------
Function Cn121CXNPV(oModelCXN, nLine, cAction, cField, xValue, xOldValue)
Local lRet		:= .T.
Local lChk		:= .F.
Local lValidCmp := _lVlCptCXN
Local nX		:= 0
Local nTotal	:= 0
Local cAtuFld 	:= ""
Local cVlrFld	:= ""
Local cDataIni	:= ""
Local cDataCpt	:= ""
Local aCampos	:= {}
Local cChave	:= ""
Local oModel	:= NIL
Local oModelCND := NIL
Local oModelCXO	:= NIL
Local oModelCXP	:= NIL

DO CASE
	CASE cAction == 'CANSETVALUE'
		oModel		:= oModelCXN:GetModel()
		oModelCND	:= oModel:GetModel('CNDMASTER')

		If cField == 'CXN_CHECK'
			If Empty(oModelCND:GetValue('CND_CONTRA')) .Or. (Empty(oModelCND:GetValue('CND_RCCOMP')) .And. Empty(oModelCND:GetValue('CND_COMPET')))
				lRet	:= .F.			
			ElseIf lValidCmp
				cDataIni	:= SubStr(DtoC(oModelCXN:GetValue('CXN_DTINI')),7)+SubStr(DtoC(oModelCXN:GetValue('CXN_DTINI')),4,2)
				cDataCpt	:= SubStr(oModelCND:GetValue('CND_COMPET'),4)+SubStr(oModelCND:GetValue('CND_COMPET'),1,2)

				//- Valida data de inicio da planilha maior do que competência.
				If  cDataIni > cDataCpt
					Help(" ",1,"CN121CMPPL") //- "Não é possivel selecionar esta planilha pois sua data inicial posterior a competência selecionada."
					If !IsBlind()
						MsgAlert(STR0078)//"Não é possivel selecionar esta planilha pois sua data inicial é posterior a competência selecionada."
					EndIf
					lRet := .F.
				EndIf
			EndIf
		ElseIf(cField == 'CXN_PARCEL')
			lRet := (!(oModelCXN:GetValue("CXN_CHECK")) .And. oModelCXN:GetOperation() == MODEL_OPERATION_INSERT  .And. (!Empty(oModelCXN:GetValue("CXN_PARCEL")  ) ) )			
			If lRet
				cChave := xFilial("CNF") + oModelCXN:GetValue("CXN_CRONOG")
				cChave += oModelCXN:GetValue("CXN_CONTRA") + oModelCXN:GetValue("CXN_REVISA")			
				CNF->(DbSetOrder(1)) //CNF_FILIAL+CNF_NUMERO+CNF_CONTRA+CNF_REVISA			
				//CXN_PARCEL eh editavel apenas quando tiver cronograma, for uma inclusao e nao estiver marcado(check)
				lRet := lRet .And. CNF->(DbSeek(cChave))				
			EndIf
		ElseIf (cField == 'CXN_IGITEM')
			lRet := (!oModelCXN:GetValue("CXN_CHECK") .And. oModelCXN:GetOperation() == MODEL_OPERATION_INSERT )
		Else
			lRet := oModelCXN:GetValue("CXN_CHECK")
		EndIf

	CASE cAction == 'SETVALUE'
		DO CASE			
			CASE cField == 'CXN_CHECK'
				If lRet := Cn121VldChk(oModelCXN,cField,xValue,nLine,xOldValue)
					lChk := .T.
					aCampos := {{'CXN_VLPREV','CND_VLPREV'},{'CXN_VLLIQD','CND_VLLIQD'},{'CXN_VLMULT','CND_VLMULT'},{'CXN_VLBONI','CND_VLBONI'},;
								{'CXN_VLDESC','CND_DESCME'},{'CXN_VLRADI','CND_TOTADT'}}
					
					If CND->(FieldPos("CND_VLMPED")) > 0 .And. CND->(FieldPos("CND_VLBPED")) > 0 .And. CXN->(FieldPos("CXN_VLMPED")) > 0 .And. CXN->(FieldPos("CXN_VLBPED")) > 0
						aAdd(aCampos, {'CXN_VLMPED','CND_VLMPED'})
						aAdd(aCampos, {'CXN_VLBPED','CND_VLBPED'})
					EndIf
					
					oModelCXO := oModelCXN:GetModel():GetModel('CXODETAIL')
					oModelCXP := oModelCXN:GetModel():GetModel('CXPDETAIL')
					If xValue .And. CnGatMNat()
						CNTA300BlMd(oModelCXO,.F.)
						CNTA300BlMd(oModelCXP,.F.)
					Else
						CNTA300BlMd(oModelCXO,.T.)
						CNTA300BlMd(oModelCXP,.T.)
					EndIf				
				EndIf			
		ENDCASE		

		If lChk //- Delete ou Undelete
			oModel		:= oModelCXN:GetModel()
			oModelCND	:= oModel:GetModel('CNDMASTER')

			nMod := Iif(xValue,1,-1) //- Caso Ativado soma no total, caso desativado, subtrai

			For nX := 1 To Len(aCampos)
				cVlrFld := aCampos[nX][1]
				cAtuFld := aCampos[nX][2]

				nTotal := oModelCND:GetValue(cAtuFld)
				nTotal += (oModelCXN:GetValue(cVlrFld) * nMod)
				CNNoWhenSet(oModelCND, cAtuFld, nTotal)				
			Next nX
		EndIf		
ENDCASE

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121CNEPV()
Pré-valid da CNE (Itens da Planilha da Medição)

@author israel.escorizza
@since 26/08/2015
@version P12
@return .T.
/*/
//--------------------------------------------------------------------
Function Cn121CNEPV(oModelCNE, nLine, cAction, cField, xValue, xOldValue)
Local oModel 		:= Nil
Local oModelCND     := Nil
Local oModelCXN 	:= Nil
Local aCampos		:= {}
Local cAtuFld 		:= ""
Local cContra		:= ""
Local cNumPla 	    := ""
Local lRet			:= .T.
Local lSemiFixo     := .F.
Local nTotal 		:= 0
Local nX			:= 0
Local nMod			:= 1
Local aBlkCpo		:= {}
Local aProp			:= {}
Local nTamDec		:= 0
Local lCn121Item	:= .F.
Local nDecVlDesc	:= 0
Local nQAtu			:= 0
Local nQAnt			:= 0
Local lDelete		:= .F.
Local cCampo		:= ""
DO CASE
	CASE cAction == 'CANSETVALUE'
		oModel := oModelCNE:GetModel()
		oModelCXN := oModel:GetModel("CXNDETAIL")
		
		If !oModelCXN:GetValue("CXN_CHECK") .And. !IsInCallStack('Cn121Item')
			lRet:= .F.
		ElseIf IsExced()
			If !oModelCNE:IsInserted() .And. !lExcedNPrv
				MtBCMod(oModel,{'CNEDETAIL'},{||.F.},'1') //- Bloqueia todos os campos
			Else
				aAdd(aBlkCpo,'CNE_PRODUT')
				aAdd(aBlkCpo,'CNE_DESCRI')
				aAdd(aBlkCpo,'CNE_QUANT')
				aAdd(aBlkCpo,'CNE_VLUNIT')
				aAdd(aBlkCpo,'CNE_TES')
				aAdd(aBlkCpo,'CNE_TS')
				If cPaisLoc == "RUS"
					aAdd(aBlkCpo,'CNE_CF') 
				EndIf
				aAdd(aBlkCpo,'CNE_PERC')
				aAdd(aBlkCpo,'CNE_VLTOT')
				aAdd(aBlkCpo,'CNE_TABPRC')
				MtBCMod(oModel,{{'CNEDETAIL',aBlkCpo}},{||.T.},'2')
			EndIf
		ElseIf CN121MdServ() .And. cField $ 'CNE_QUANT|CNE_PERC|'
			lRet:= .F.
		ElseIf (cField == 'CNE_QUANT')
        	cContra := oModel:GetValue("CNDMASTER", "CND_CONTRA")
        	cNumPla := oModelCXN:GetValue("CXN_NUMPLA")
        	lRet    := !(CN121RetSt("SERVIÇO", 0, cNumPla, cContra))
		EndIf
		
		FwFreeArray(aBlkCpo)

	CASE cAction == 'SETVALUE'
		
		DO CASE
			CASE cField == 'CNE_VLTOT'
				cAtuFld := 'CXN_VLLIQD'
			CASE cField == "CNE_PDESC" .Or. cField == "CNE_VLDESC"
				cAtuFld := 'CXN_VLLIQD'
				nMod    := -1
				If cField == "CNE_PDESC"
					nDecVlDesc	:= GetSx3Cache("CNE_VLDESC", "X3_DECIMAL")
					xValue	  	:= NoRound(oModelCNE:GetValue("CNE_VLTOT")*xValue/100,nDecVlDesc)
					xOldValue 	:= NoRound(oModelCNE:GetValue("CNE_VLTOT")*xOldValue/100,nDecVlDesc)
				EndIf
				If !Positivo(xValue)
					lRet:= .F.
					Help("",1,'Cn121VLDVl',,STR0236,1,0,,,,,,{STR0237})
				EndIf
			CASE cField == 'CNE_MULTA'
				cAtuFld := 'CXN_VLMULT'
			CASE cField == 'CNE_VLMPED'
				cAtuFld := 'CXN_VLMPED'
			CASE cField == 'CNE_BONIF'
				cAtuFld := 'CXN_VLBONI'
			CASE cField == 'CNE_VLBPED'
				cAtuFld := 'CXN_VLBPED'
			CASE cField == 'CNE_VLUNIT'
				if CN121RetSt( "SERVIÇO", 0, , , .T.,oModelCNE:GetModel()) //Se for serviço, trata o valor unitário igual ao valor total
					cAtuFld := 'CXN_VLLIQD'
				endif
		ENDCASE

		If lRet .And. !Empty(cAtuFld)
			lCn121Item := FwIsInCallStack('Cn121Item')
			oModel := oModelCNE:GetModel()
			oModelCND := oModel:GetModel("CNDMASTER")
			oModelCXN := oModel:GetModel("CXNDETAIL")

			nTamDec := GetSx3Cache( cField, "X3_DECIMAL" )
			nTotal := oModelCXN:GetValue(cAtuFld)
			If (nMod < 1)
				nTotal += ( NoRound(xValue,nTamDec) - NoRound(xOldValue,nTamDec) ) * nMod
			Else
				nTotal += ( Round(xValue,nTamDec) - Round(xOldValue,nTamDec) ) * nMod
			EndIf
		
			If !lCn121Item
				aProp 	:= Array(2)
				aProp[1]:= GetPropMdl(oModelCXN)
				aProp[2]:= GCTGetWhen(oModelCXN)				
				CNTA300BlMd(oModelCXN,,.T.)//Libera p/ atualizacao				
			EndIf

            cContra := oModelCND:GetValue("CND_CONTRA")
			cNumPla := oModelCXN:GetValue("CXN_NUMPLA")
            lSemiFixo := CN121RetSt("SEMIFIXO", 0, cNumPla, cContra, .T., oModel )					

            If cField == 'CNE_VLTOT' //Quando semi-fixo valida se o valor total do item ultrapassa o saldo da planilha
                lRet := CN121VlTot(Iif(lSemiFixo, nTotal, xValue))
				AtuSldFrt(oModel,nLine,cAction,xValue, xOldValue,cField)
            EndIf

			If lRet .And. CN121MdServ()
				oModel := oModelCNE:GetModel()
				lRet := !(oModel:HasErrorMessage())
			EndIf

            If (lRet .Or. cField != 'CNE_VLTOT')
				If (oModelCXN:GetValue(cAtuFld) != nTotal)
                	oModelCXN:SetValue(cAtuFld,nTotal)					
				EndIf
            EndIf

			If !lCn121Item
				RstPropMdl(oModelCXN, aProp[1])
				GCTRstWhen(oModelCXN, aProp[2])
				FwFreeArray(aProp)
			EndIf
			
		EndIf

		If cField $ "CNE_FRETE|CNE_DESPES|CNE_SEGURO" .And. !lCn121Item
			AtuSldFrt(oModelCNE:GetModel(),nLine,cAction,xValue, xOldValue,cField)				
		Endif
		If cField = 'CNE_VLUNIT' .And. !lCn121Item .And. lRet
			Cn121AtuRat( xValue * oModelCNE:GetValue("CNE_QUANT") )
		Endif

	CASE cAction == 'DELETE' .OR. cAction == 'UNDELETE'
		lDelete		:= cAction == 'DELETE'
		oModel		:= oModelCNE:GetModel()
		oModelCXN	:= oModel:GetModel("CXNDETAIL")
		
		aCampos 	:={{'CNE_VLTOT','CXN_VLLIQD'},{'CNE_MULTA','CXN_VLMULT'},{'CNE_BONIF','CXN_VLBONI'},{'CNE_VLDESC','CXN_VLLIQD'}}
				
		If 	CNE->(FieldPos("CNE_VLMPED") > 0 .And. FieldPos("CNE_VLBPED") > 0) .And.;
			CXN->(FieldPos("CXN_VLMPED") > 0 .And. FieldPos("CXN_VLBPED") > 0)

			aAdd(aCampos, {'CNE_VLMPED','CXN_VLMPED'})
			aAdd(aCampos, {'CNE_VLBPED','CXN_VLBPED'})
		EndIf

		If oModelCNE:GetValue("CNE_VLTOT") > 0 .And. !IsExced()

			aProp:= GCTGetWhen(oModelCXN)				
			oModelCXN:GetStruct():SetProperty("*",MODEL_FIELD_WHEN,{||.T.})
			For nX := 1 To Len(aCampos)
				cAtuFld := aCampos[nX][2]
				cCampo	:= aCampos[nX][1]
						
				nTotal 	:= oModelCXN:GetValue(cAtuFld)

				If  lDelete 
					If cCampo == "CNE_VLDESC" .Or. cCampo == "CNE_VLTOT"
						nTotal += oModelCNE:GetValue("CNE_VLDESC")
						nTotal -= oModelCNE:GetValue(cCampo)
					EndIf
				Else
					nMod	:= IIF(cCampo == "CNE_VLDESC",-1,1)
					nTotal	+= (oModelCNE:GetValue(cCampo) * nMod)
				EndIf

				

				nTotal	:= Max(0, nTotal)
				oModelCXN:SetValue(cAtuFld,nTotal)
			Next nX
			GCTRstWhen(oModelCXN,aProp )
			FwFreeArray(aProp)

			If !Empty(oModelCNE:GetValue("CNE_ITEMGR"))
				If lDelete
					nQAtu := 0
					nQAnt := oModelCNE:GetValue("CNE_QUANT")
				Else
					nQAtu := oModelCNE:GetValue("CNE_QUANT")
					nQAnt := 0
				EndIf
				lRet := CN121VlAgr(oModelCNE:GetValue("CNE_PRODUT"),nQAtu,nQAnt)

				If lRet .And. !lDelete
					lRet := C121CNEAgr(oModel,,,,.T.)
				EndIf
			EndIf
		
		ElseIf IsExced() .And. !lDelete
			CN121ChgPl() //Habilita edição de campos
		EndIf
		FwFreeArray(aCampos)

		AtuSldFrt(oModel,nLine,cAction,xValue, xOldValue,cField)

ENDCASE

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121CNQPV()
Pré-valid da CNQ (Descontos da Planilha da Medição)

@author israel.escorizza
@since 09/09/2015
@version P12
@return .T.
/*/
//--------------------------------------------------------------------
Function Cn121CNQPV(oModelCNQ, nLine, cAction, cField, xValue, xOldValue)
Local lRet		:= .T.
Local oModel	:= Nil
Local oModelCNE	:= Nil
Local oModelCXN	:= Nil

DO CASE
	CASE cAction == 'CANSETVALUE'
		oModel := oModelCNQ:GetModel()
		oModelCNE := oModel:GetModel("CNEDETAIL")
		oModelCXN := oModel:GetModel("CXNDETAIL")
		
		If !oModelCXN:GetValue("CXN_CHECK") .OR. Empty(oModelCNE:GetValue("CNE_ITEM"))
			lRet:= .F.
		EndIf

	CASE cAction == 'SETVALUE'
		DO CASE
			CASE cField == 'CNQ_VALOR'
				oModel := oModelCNQ:GetModel()
				oModelCXN := oModel:GetModel("CXNDETAIL")
				
				cAtuFld := 'CXN_VLDESC'

				nTotal := oModelCXN:GetValue(cAtuFld)
				nTotal += (xValue - xOldValue)				
				CNNoWhenSet(oModelCXN, cAtuFld, nTotal)
		ENDCASE

	CASE cAction == 'DELETE'
		oModel := oModelCNQ:GetModel()
		oModelCXN := oModel:GetModel("CXNDETAIL")
		
		cAtuFld := 'CXN_VLDESC'

		nTotal := oModelCXN:GetValue(cAtuFld)
		nTotal -= oModelCNQ:GetValue('CNQ_VALOR')
		CNNoWhenSet(oModelCXN, cAtuFld, nTotal)		

	CASE cAction == 'UNDELETE'
		oModel := oModelCNQ:GetModel()
		oModelCXN := oModel:GetModel("CXNDETAIL")
		
		cAtuFld := 'CXN_VLDESC'

		nTotal := oModelCXN:GetValue(cAtuFld)
		nTotal += oModelCNQ:GetValue('CNQ_VALOR')
		CNNoWhenSet(oModelCXN, cAtuFld, nTotal)
ENDCASE

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121CNZPV()
Pré-valid da CNZ (Rateio dos Itens da Planilha da Medição)

@author israel.escorizza
@since 02/09/2015
@version P12
@return .T.
/*/
//--------------------------------------------------------------------
Function Cn121CNZPV(oModelCNZ, nLine, cAction, cField, xValue, xOldValue)
	Local lRet		:= .T.
	Local nX 		:= 0
	Local oModel	:= NIL
	Local oModelCNE	:= NIL
	Local oModelCXN	:= NIL
	Local cTemp		:= ""
	Local aArea		:= {}
	Local aParCps	:= {{'CNE_CC'		,'CNB_CC'},;
						{'CNE_CONTA'	,'CNB_CONTA'},;
						{'CNE_ITEMCT'	,'CNB_ITEMCT'},;
						{'CNE_CLVL'		,'CNB_CLVL'}}
	
	DO CASE
		CASE cAction == 'CANSETVALUE'
			oModel		:= oModelCNZ:GetModel()
			oModelCXN	:= oModel:GetModel("CXNDETAIL")
			oModelCNE	:= oModel:GetModel("CNEDETAIL")
	
			If !oModelCXN:GetValue("CXN_CHECK") .OR. Empty(oModelCNE:GetValue("CNE_ITEM"))
				lRet:= .F.			
			EndIf
		CASE cAction == "UNDELETE" .Or. (cAction == 'SETVALUE' .And. cField == "CNZ_CC")
			AddEntCtb(aParCps)//Carrega entidades contab. adicionais
			oModel := oModelCNZ:GetModel()
			For nX:= 1 to Len(aParCps)				
				If(!Empty(oModel:GetValue("CNEDETAIL", aParCps[nX,1])))			
					oModel:SetValue("CNEDETAIL", aParCps[nX,1], "")
				EndIf
			Next nX
	
		CASE cAction == 'DELETE' .And. (oModelCNZ:Length() - 1) == 0
			oModel := oModelCNZ:GetModel()
			oModelCNE	:= oModel:GetModel("CNEDETAIL")
			If(Empty(oModelCNE:GetValue("CNE_CC")))			
				aArea := CNB->(GetArea())
				
				CNB->(DbSetOrder(1))//CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM
				cTemp := xFilial("CNB", oModel:GetValue("CNDMASTER","CND_FILCTR"))		
				cTemp += oModelCNE:GetValue("CNE_CONTRA") + oModelCNE:GetValue("CNE_REVISA") 
				cTemp += oModelCNE:GetValue("CNE_NUMERO") + oModelCNE:GetValue("CNE_ITEM")
				If(CNB->( DbSeek(cTemp) ))
					AddEntCtb(aParCps)//Carrega entidades contab. adicionais
					For nX:= 1 to Len(aParCps)	
						cTemp := CNB->( &(aParCps[nX,2]) )
						If(!Empty(cTemp))						
							oModel:SetValue("CNEDETAIL", aParCps[nX,1], cTemp)
						EndIf
					Next nX				
				EndIf
							
				RestArea(aArea)
			EndIf			
	ENDCASE

	FwFreeArray(aParCps)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121CXIPV()
Pré-valid da CXI (Partes envolvidas)

@author israel.escorizza
@since 02/09/2015
@version P12
@return .T.
/*/
//--------------------------------------------------------------------
Function Cn121CXIPV(oModelCXI, nLine, cAction, cField, xValue, xOldValue)
Local lRet		:= .T.
Local oModel	:= NIL
Local oModelCXN	:= NIL

DO 	CASE
	CASE cAction == 'CANSETVALUE'
		oModel := oModelCXI:GetModel()
		oModelCXN := oModel:GetModel("CXNDETAIL")

		If !oModelCXN:GetValue("CXN_CHECK")
			lRet:= .F.
		EndIf
ENDCASE

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121CNR1()
Pré-valid da CNR1 (Multas e Bonificações da planilha)
@author
@since
@version P12
@return .T.
/*/
//--------------------------------------------------------------------
Function Cn121CNR1(oModelCNR1, nLine, cAction, cField, xValue, xOldValue)
Local lRet		:= .T.
Local lAuto     := IsBlind()
Local lBonif	:= .F.
Local lCompra   := .F.
Local lCN121Auto:= IsInCallStack("CN121Auto")
Local nTotal	:= 0
Local nTotal2   := 0
Local cAtuFld1	:= ""
Local cAtuFld2  := ""
Local cRmvFld1	:= ""
Local cRmvFld2	:= ""
Local cAddFld1	:= ""
Local cAddFld2	:= ""
Local oModel	:= NIL
Local oModelCXN := NIL

DO CASE
	CASE cAction == 'CANSETVALUE'
		oModel	   := oModelCNR1:GetModel()
		oModelCXN  := oModel:GetModel('CXNDETAIL')

		If (!oModelCXN:GetValue('CXN_CHECK') .Or. oModelCXN:IsDeleted()) //-- Não permite alterar multa/bonificação
			lRet := .F.
		EndIf

        lRet := lRet .And. C121CNRVld(oModel, cAction, cField, .T.) //-- Realiza outras validações
	CASE cAction == 'SETVALUE'
		DO CASE
			CASE cField == 'CNR_VALOR'
				oModel    := oModelCNR1:GetModel()
				oModelCXN := oModel:GetModel('CXNDETAIL')
				lRet      := C121CNRVld(oModel, cAction, cField, .T.)
                lCompra   := CN121RetSt("COMPRA", 0, oModel:GetValue("CXNDETAIL","CXN_NUMPLA"))

				If lRet
					If oModelCNR1:GetValue('CNR_TIPO') == '1' //- Verifica se é multa ou bonificação 1- Multa/2- Bonif.
						cAtuFld1 := 'CXN_VLMULT'
						cAtuFld2 := 'CXN_VLMPED'
						lBonif   := .F.
					Else
						cAtuFld1 := 'CXN_VLBONI'
						cAtuFld2 := 'CXN_VLBPED'
						lBonif   := .T.
					EndIf

                    nTotal := oModelCXN:GetValue(cAtuFld1)
                    nTotal += (xValue - xOldValue)

					If ((lCompra .And. !lBonif) .Or. (!lCompra .And. lBonif)) .And. nTotal >= oModelCXN:GetValue("CXN_VLTOT")
                        If !lCN121Auto .And. !lAuto .And. !MsgYesNo(STR0140+STR0141) //- A bonificação é igual ao total da planilha.|| Esta planilha será desconsiderada na geração do documento, deseja continuar?
                            Help(" ",1,"CN121MULT")
                            lRet := .F.
                        Endif
					EndIf
					
					CNNoWhenSet(oModelCXN, cAtuFld1, nTotal)
                    If lRet .And. oModelCNR1:GetValue('CNR_FLGPED') == '1' //-- Atualiza CXN_VLMPED/CXN_VLBPED apenas quando a multa/bonficação seja considerada no pedido.
                        nTotal := oModelCXN:GetValue(cAtuFld2)
                        nTotal += (xValue - xOldValue)
						
						CNNoWhenSet(oModelCXN, cAtuFld2, nTotal)
                    EndIf
				EndIf
			CASE cField == 'CNR_TIPO'
				oModel		:= oModelCNR1:GetModel()
				oModelCXN 	:= oModel:GetModel('CXNDETAIL')
				lRet		:= C121CNRVld(oModel, cAction, cField, .T.)
				
				If lRet
					If xValue == '2' .AND. (xOldValue == '1' .Or. Empty(xOldValue))
						cRmvFld1 := 'CXN_VLMULT'
						cRmvFld2 := 'CXN_VLMPED'
						cAddFld1 := 'CXN_VLBONI'
						cAddFld2 := 'CXN_VLBPED'
					ElseIf xValue == '1' .AND. (xOldValue == '2' .Or. Empty(xOldValue))
						cRmvFld1 := 'CXN_VLBONI'
						cRmvFld2 := 'CXN_VLBPED'
						cAddFld1 := 'CXN_VLMULT'
						cAddFld2 := 'CXN_VLMPED'
					Else
						lRet := .F.
					EndIf
    
                    If lRet
                        nTotal := oModelCXN:GetValue(cRmvFld1)
                        nTotal -= oModelCNR1:GetValue('CNR_VALOR')						
						CNNoWhenSet(oModelCXN, cRmvFld1, nTotal)
                        
						nTotal := oModelCXN:GetValue(cAddFld1)
                        nTotal += oModelCNR1:GetValue('CNR_VALOR')						
						CNNoWhenSet(oModelCXN, cAddFld1, nTotal)

						If oModelCNR1:GetValue('CNR_FLGPED') == '1' //-- Atualiza CXN_VLMPED/CXN_VLBPED apenas quando a multa/bonficação seja considerada no pedido.
							nTotal := oModelCXN:GetValue(cRmvFld2)
							nTotal -= oModelCNR1:GetValue('CNR_VALOR')							
							CNNoWhenSet(oModelCXN, cRmvFld2, nTotal)

							nTotal := oModelCXN:GetValue(cAddFld2)
							nTotal += oModelCNR1:GetValue('CNR_VALOR')
							CNNoWhenSet(oModelCXN, cAddFld2, nTotal)
						EndIf
                    EndIf
				EndIf

            CASE cField == 'CNR_FLGPED'
                oModel		:= oModelCNR1:GetModel()
				oModelCXN 	:= oModel:GetModel('CXNDETAIL')
                lRet        := C121CNRVld(oModel, cAction, cField, .T.)
                cAtuFld1    := IIF(oModelCNR1:GetValue('CNR_TIPO') == '1', 'CXN_VLMPED', 'CXN_VLBPED') //- Verifica se é multa ou bonificação 1- Multa/2- Bonif.

                If lRet
                    If xValue == '1' .And. xOldValue == '2'
                        nTotal := oModelCXN:GetValue(cAtuFld1)
                        nTotal += oModelCNR1:GetValue('CNR_VALOR')
                    ElseIf xValue == '2' .And. xOldValue == '1'
                        nTotal := oModelCXN:GetValue(cAtuFld1)
                        nTotal -= oModelCNR1:GetValue('CNR_VALOR')
                    Else
                        lRet := .F.
                    EndIf

                    If lRet                        
						CNNoWhenSet(oModelCXN, cAtuFld1, nTotal)
                    EndIF
                EndIf
            OTHERWISE
                oModel := oModelCNR1:GetModel()
				lRet := C121CNRVld(oModel, cAction, cField, .T.)
		ENDCASE

	CASE cAction == 'DELETE' .Or. cAction == 'UNDELETE'
		oModel	  := oModelCNR1:GetModel()
		oModelCXN := oModel:GetModel('CXNDETAIL')
        
		If oModelCNR1:GetValue('CNR_MODO') == '1' .And. !FwIsInCallStack('CNTA300DlMd') //-- Não permite deletar a linha
			Help(" ",1,"CN121CNRDEL",,STR0199,1,4) //-- Esta multa/bonificação não pode ser alterada ou excluída porque o valor do campo Modo (CNR_TIPO) é Automático.
			lRet := .F.
		Else
			If oModelCNR1:GetValue('CNR_TIPO') == '1' //- Verifica se é multa ou bonificação 1- Multa/2- Bonif.
				cAtuFld1 := 'CXN_VLMULT'
				cAtuFld2 := 'CXN_VLMPED'
			Else
				cAtuFld1 := 'CXN_VLBONI'
				cAtuFld2 := 'CXN_VLBPED'
			EndIf

			nTotal := oModelCXN:GetValue(cAtuFld1)
			nTotal2 := oModelCXN:GetValue(cAtuFld2)

            If cAction == 'DELETE'
			    nTotal -= oModelCNR1:GetValue('CNR_VALOR')  
                nTotal2 -= oModelCNR1:GetValue('CNR_VALOR')
            Else
                nTotal += oModelCNR1:GetValue('CNR_VALOR')
                nTotal2 += oModelCNR1:GetValue('CNR_VALOR')
            EndIf
			
			CNNoWhenSet(oModelCXN, cAtuFld1, nTotal)

			If oModelCNR1:GetValue('CNR_FLGPED') == '1' //-- Atualiza CXN_VLMPED/CXN_VLBPED apenas quando a multa/bonficação seja considerada no pedido.
				CNNoWhenSet(oModelCXN, cAtuFld2, nTotal2)
			EndIf
		EndIf
ENDCASE

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121CNR2()
Pré-valid da CNR2 (Multas e Bonificações dos itens)
@author
@since
@version P12
@return .T.
/*/
//--------------------------------------------------------------------
Function Cn121CNR2(oModelCNR2, nLine, cAction, cField, xValue, xOldValue)
Local lRet		:= .T.
Local lMulta	:= .F.
Local lAuto     := IsBlind()
Local lCompra   := .F.
Local nTotal	:= 0
Local nTotal2   := 0
Local cAtuFld1	:= ""
Local cRmvFld1	:= ""
Local cAddFld1	:= ""
Local cAtuFld2	:= ""
Local cRmvFld2	:= ""
Local cAddFld2	:= ""
Local oModel	:= NIL
Local oModelCNE := NIL
Local oModelCXN := NIL

DO CASE
	CASE cAction == 'CANSETVALUE'
		oModel := oModelCNR2:GetModel()
		oModelCXN := oModel:GetModel("CXNDETAIL")
		oModelCNE := oModel:GetModel("CNEDETAIL")

		If (!oModelCXN:GetValue('CXN_CHECK') .Or. oModelCXN:IsDeleted()) .Or. ; //-- Não permite alterar multa/bonificação
		   (Empty(oModelCNE:GetValue("CNE_ITEM")) .Or. oModelCNE:IsDeleted())
			lRet := .F.
		EndIf

		lRet := lRet .And. C121CNRVld(oModel, cAction, cField, .F.) //-- Realiza outras validações

	CASE cAction == 'SETVALUE'
        DO CASE
            CASE cField == 'CNR_VALOR'
                oModel    := oModelCNR2:GetModel()
                oModelCNE := oModel:GetModel('CNEDETAIL')
				lRet      := C121CNRVld(oModel, cAction, cField, .F.)
                lCompra   := CN121RetSt("COMPRA", 0, oModel:GetValue("CXNDETAIL","CXN_NUMPLA"))

				If lRet
					If oModelCNR2:GetValue('CNR_TIPO') == '1' //- Verifica se é multa ou bonificação 1- Multa/2- Bonif.
						cAtuFld1 := 'CNE_MULTA'
                        cAtuFld2 := 'CNE_VLMPED'
						lMulta := .T.
					Else
						cAtuFld1 := 'CNE_BONIF'
                        cAtuFld2 := 'CNE_VLBPED'
						lMulta := .F.
					EndIf

					nTotal := oModelCNE:GetValue(cAtuFld1)
					nTotal += (xValue - xOldValue)

					If ((lCompra .And. lMulta) .Or. (!lCompra .And. !lMulta)) .And. nTotal >= oModelCNE:GetValue("CNE_VLTOT")
                        If !lAuto .And. !MsgYesNo(STR0142+STR0143) //- A multa é igual ao total do item. || Este item será desconsiderado na geração do documento, deseja continuar?
                            Help(" ",1,"CN121MULT")
                            lRet := .F.
                        EndIf
                    EndIf

                    If lRet
						CNNoWhenSet(oModelCNE, cAtuFld1, nTotal)

						If oModelCNR2:GetValue('CNR_FLGPED') == '1' //-- Atualiza CNE_VLMPED/CNE_VLBPED apenas quando a multa/bonficação seja considerada no pedido.
							nTotal := oModelCNE:GetValue(cAtuFld2)
							nTotal += (xValue - xOldValue)
							CNNoWhenSet(oModelCNE, cAtuFld2, nTotal)
						EndIf
                    EndIf
				EndIf
            CASE lRet .And. cField == 'CNR_TIPO'
                oModel    := oModelCNR2:GetModel()
                oModelCNE := oModel:GetModel('CNEDETAIL')
				lRet      := C121CNRVld(oModel, cAction, cField, .F.)

				If lRet
					If xValue == '2' .AND. (xOldValue == '1' .Or. Empty(xOldValue))
						cRmvFld1 := 'CNE_MULTA'
						cRmvFld2 := 'CNE_VLMPED'
						cAddFld1 := 'CNE_BONIF'
						cAddFld2 := 'CNE_VLBPED'
					ElseIf xValue == '1' .AND. (xOldValue == '2' .Or. Empty(xOldValue))
						cRmvFld1 := 'CNE_BONIF'
						cRmvFld2 := 'CNE_VLBPED'
						cAddFld1 := 'CNE_MULTA'
						cAddFld2 := 'CNE_VLMPED'
					Else
						lRet := .F.
					EndIf

					If lRet
 						nTotal := oModelCNE:GetValue(cRmvFld1)
						nTotal -= oModelCNR2:GetValue('CNR_VALOR')
						CNNoWhenSet(oModelCNE, cRmvFld1, nTotal)

						nTotal := oModelCNE:GetValue(cAddFld1)
						nTotal += oModelCNR2:GetValue('CNR_VALOR')
						CNNoWhenSet(oModelCNE, cAddFld1, nTotal)

						If oModelCNR2:GetValue('CNR_FLGPED') == '1' //-- Atualiza CNE_VLMPED/CNE_VLBPED apenas quando a multa/bonficação seja considerada no pedido.
							nTotal := oModelCNE:GetValue(cRmvFld2)
							nTotal -= oModelCNR2:GetValue('CNR_VALOR')
							CNNoWhenSet(oModelCNE, cRmvFld2, nTotal)							

							nTotal := oModelCNE:GetValue(cAddFld2)
							nTotal += oModelCNR2:GetValue('CNR_VALOR')
							CNNoWhenSet(oModelCNE, cAddFld2, nTotal)
						EndIf
					EndIf
				EndIf

            CASE cField == 'CNR_FLGPED' .And. (xValue != xOldValue)
                oModel		:= oModelCNR2:GetModel()
                oModelCNE 	:= oModel:GetModel('CNEDETAIL')
                lRet        := C121CNRVld(oModel, cAction, cField, .T.)
                cAtuFld1    := IIF(oModelCNR2:GetValue('CNR_TIPO') == '1', 'CNE_VLMPED', 'CNE_VLBPED') //- Verifica se é multa ou bonificação 1- Multa/2- Bonif.

                If lRet
                    If xValue == '1' .And. (xOldValue == '2' .Or. Empty(xOldValue))
                        nTotal := oModelCNE:GetValue(cAtuFld1)
                        nTotal += oModelCNR2:GetValue('CNR_VALOR')
                    ElseIf xValue == '2' .And. (xOldValue == '1' .Or. Empty(xOldValue))
                        nTotal := oModelCNE:GetValue(cAtuFld1)
                        nTotal -= oModelCNR2:GetValue('CNR_VALOR')
                    Else
                        lRet := .F.
                    EndIf

                    If lRet
						CNNoWhenSet(oModelCNE, cAtuFld1, nTotal)
                    EndIF
                EndIf
            OTHERWISE
				oModel := oModelCNR2:GetModel()
				lRet := C121CNRVld(oModel, cAction, cField, .F.)
        ENDCASE

    CASE cAction == 'DELETE' .Or. cAction == 'UNDELETE'
        oModel    := oModelCNR2:GetModel()
        oModelCXN := oModel:GetModel('CXNDETAIL')
        oModelCNE := oModel:GetModel('CNEDETAIL')

        If oModelCNR2:GetValue('CNR_MODO') == '1' .And. !FwIsInCallStack('CNTA300DlMd') //-- Não permite deletar a linha
            Help(" ",1,"CN121CNRDEL",,STR0199,1,4) //-- "Esta multa/bonificação não pode ser alterada ou excluída porque o valor do campo Modo (CNR_TIPO) é Automático."
            lRet := .F.
        Else
            If oModelCNR2:GetValue('CNR_TIPO') == '1' //- Verifica se é multa ou bonificação 1- Multa/2- Bonif.
                cAtuFld1 := 'CNE_MULTA'
                cAtuFld2 := 'CNE_VLMPED'
            Else
                cAtuFld1 := 'CNE_BONIF'
                cAtuFld2 := 'CNE_VLBPED'
            EndIf

            nTotal := oModelCNE:GetValue(cAtuFld1)
            nTotal2 := oModelCNE:GetValue(cAtuFld2)

            If cAction == 'DELETE'
                nTotal -= oModelCNR2:GetValue('CNR_VALOR')
                nTotal2 -= oModelCNR2:GetValue('CNR_VALOR')
            Else
                nTotal += oModelCNR2:GetValue('CNR_VALOR')
                nTotal2 += oModelCNR2:GetValue('CNR_VALOR')
            EndIf			

           	CNNoWhenSet(oModelCNE, cAtuFld1, nTotal)

			If oModelCNR2:GetValue('CNR_FLGPED') == '1' //-- Atualiza CNE_VLMPED/CNE_VLBPED apenas quando a multa/bonficação seja considerada no pedido.				
				CNNoWhenSet(oModelCNE, cAtuFld2, nTotal2)
			EndIf
        EndIf

ENDCASE

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121SetCp()
Função para "converter" os Valores de CND_RCCOMP e setar em
CND_COMPET

@author miguel.santos
@since 27/07/2015

@version P12.1.7
/*/
//-------------------------------------------------------------------
Function CN121SetCp(oModel,cField,cValue,cOldValue,cFilCTR,lAuto)
Local 	nIndex	:= 0
DEFAULT cFilCTR	:= Iif(!Empty(CN9->CN9_FILCTR),CN9->CN9_FILCTR,cFilAnt)
DEFAULT lAuto	:= IsInCallStack('CN260EXC')

If !Empty(aComp) .And. !FwIsInCallStack("CHANGECOMBOVALUES")
	lExced	:= lExcedNPrv
	If !Empty(cOldValue) .And. ((cField == "CND_RCCOMP") .And. cValue != cOldValue)
		Cn121ClrTt()
	EndIf

	If !lAuto
		nIndex := Val(oModel:GetValue("CND_RCCOMP"))
		cValue := aComp[IIf(nIndex == 0,1,nIndex)]
	Else
		cValue := aComp[1]
	Endif

	cValue := SubStr(cValue ,At("=",cValue)+1,Len(cValue))
	oModel:SetValue("CND_COMPET", cValue)
	CN120Compet(lExced,cFilCTR)
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121Item
Função para carregas os itens vinculados na Planilha.
@author Israel.Escorizza
@since 31/08/2015
@version P12.1.7
@return lRet, Logico: Retorna .F. caso exista produtos inconsistentes ou não existir itens válidos para medição. 
/*/
//-------------------------------------------------------------------
Function CN121Item( lCheck, cItemCNB, oModel, cPlan, cContra )
Local aSaveLines	:= FwSaveRows()
Local aArea			:= GetArea()
Local aAreaCNA		:= {}
Local aAreaCNB		:= {}
Local aAreaGS		:= {}
Local oModelCND		:= Nil
Local oModelCNE		:= Nil
Local oModelCXN		:= Nil
Local oModelCXI		:= Nil
Local oModelCNZ		:= Nil
Local cRevisa		:= ""
Local cCompet		:= ""
Local nVlPrev		:= 0
Local cCronog		:= ""
Local cParcel		:= ""
Local cItem			:= ""
Local cSeek			:= ""
Local cFilCtr		:= ""
Local cFilCtrAux	:= ""
Local cFilCNB 		:= ""
Local cFilCNF       := ""
Local cFilCNS       := ""
Local cFilTFJ       := ""
Local cGCTxGS		:= "0" //0 = Não verificado; 1=Contrato integrado com GS; 2=Sem Integração
Local cCodTFJ		:= ""
Local lFisico		:= .F.
Local lFixo			:= .F.
Local lMedEve		:= .F.
Local lRecorre		:= .F.
Local lCompra		:= .F.
Local lServico		:= .F.
Local lRet 			:= .T.
Local lArrendCpo	:= .F.
Local lGSLE			:= SuperGetMV("MV_GSLE",,.F.) .AND. SuperGetMv("MV_GSDSGCN",,"1") == '2'
Local aECAdic		:= {}
Local aItemErro		:= Array(2, "")
Local nX			:= 0
Local nY			:= 0
Local nQtdeItens	:= 0
Local nQtdItErro    := 0
Local nValUnit 		:= 0
Local nPDesc		:= 0
Local lTECItGSEn 	:= (ExistFunc("TECItGSEn") .And. ExistFunc("TecGsMdZer") .And. ExistFunc('TecGsVerDt'))
Local lTecBLoadMd 	:= ExistFunc("TecBLoadMd")
Local oView			as Object
Local oViewCNE		as Object
Local lContinua		:= .T.
Local lAddItem      := .F.
Local cChaveCNS		:= ""
Local lMulta		:= .F.
Local lPrevFin		:= .F.
Local nVlQuant		:= 0
Local cCodTES		:= ""
Local nMoedaCtr		:= 1
Local nMoedaMed		:= 1
Local dDataInic		:= dDatabase
Local nDecVlTot		:= GetSx3Cache("CNE_VLTOT"	,"X3_DECIMAL")
Local nDecPerc		:= GetSx3Cache("CNE_PERC","X3_DECIMAL")
Local nProdGsZero	:= 0
Local dEntrega		:= dDatabase
Default oModel		:= FwModelActive()
Default lCheck		:= oModel:GetModel('CXNDETAIL'):GetValue("CXN_CHECK")
Default cItemCNB	:= ""
Default cPlan 		:= ""
Default cContra		:= ""

lFisico		:= CN121RetSt( 'FISICO'		, 0, cPlan, cContra, .T. )
lFixo		:= CN121RetSt( 'FIXO'		, 0, cPlan, cContra, .T. )
lMedEve		:= CN121RetSt( 'MEDEVE'		, 0, cPlan, cContra, .T. )
lRecorre	:= CN121RetSt( 'RECORRENTE'	, 0, cPlan, cContra, .T. )
lCompra		:= CN121RetSt( "COMPRA"		, 0, cPlan, cContra, .T. )
lServico	:= CN121RetSt( "SERVIÇO"	, 0, cPlan, cContra, .T. )
lPrevFin	:= CN121RetSt( "PREVFINANC" , 0, cPlan, cContra, .T. )
nMoedaCtr	:= CN121RetSt( "MOEDACTR"	, 0,	  , cContra, .T. )

oModelCND := oModel:GetModel('CNDMASTER')
oModelCNE := oModel:GetModel('CNEDETAIL')
oModelCXN := oModel:GetModel('CXNDETAIL')
oModelCXI := oModel:GetModel('CXIDETAIL')
oModelCNZ := oModel:GetModel('CNZDETAIL')

cRevisa := oModelCND:GetValue('CND_REVISA')
cCompet := oModelCND:GetValue('CND_COMPET')
nVlPrev := oModelCND:GetValue('CND_VLLIQD')
cCronog := oModelCXN:GetValue('CXN_CRONOG')
cParcel := oModelCXN:GetValue('CXN_PARCEL')
nMoedaMed := oModelCND:GetValue('CND_MOEDA')
dDataInic := oModelCND:GetValue('CND_DTINIC')


If !Empty(cItemCNB)
	oModelCNE:GoLine(oModelCNE:Length())
Else
	oModelCNE:GoLine(1)
EndIf

//- Verifica se já existe informação antes de iniciar a carga
If Empty(oModelCNE:GetValue("CNE_PRODUT"))
	//- Inicio da carga		
	lArrendCpo  := CNE->( ColumnPos( "CNE_ARREND" ) ) > 0 .And. CNB->( ColumnPos( "CNB_ARREND" ) ) > 0
    cFilTFJ     := FWxFilial("TFJ")
	cFilCtr     := oModelCND:GetValue("CND_FILCTR")
	cFilCtrAux  := FWxFilial("CN9", cFilCtr)
	cFilCNB     := FWxFilial("CNB", cFilCtr) 
    cFilCNF     := FWxFilial("CNF", cFilCtr)
    cFilCNS     := FWxFilial("CNS", cFilCtr)
	
	cSeek := cFilCNB + cContra + cRevisa + cPlan
	CNA->(dbSetOrder(1))
	CNA->(MsSeek(cSeek)) //Posiciona CNA

	lMulta := (CN121RetSt('TPMULT') == "2")//Se multa na Medicao(CNL_TPMULT/CN1_TPMULT : 2=Medição)
	
	If oModelCNE:GetLine() == 1
		InitCposMd(oModelCNE) //Caso possua inicializador padrão, atualiza os campos com seus respectivos valores na primeira linha dos itens da medição.
	EndIf

	CNB->(dbSetOrder(1)) //CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM
	If CNB->(MsSeek(cSeek))		

		AddEntCtb(aECAdic)//Carrega entidades contab. adicionais
			
		nQtdeItens := PegaQtdCNB( cFilCNB, cContra, cRevisa, cPlan )
				
		If !lMedEve .And. !lRecorre //Posiciona CNF e CNS
			If !Empty(cParcel)
				CNF->(dbSetOrder(3))
				CNF->(MsSeek(cFilCNF+cContra+cRevisa+cCronog+cParcel))
			Else
				CNF->(dbSetOrder(2))
				CNF->(MsSeek(cFilCNF+cContra+cRevisa+cCronog+cCompet))
			EndIf

			If lFisico
				CNS->(dbSetOrder(1)) //CNS_FILIAL+CNS_CONTRA+CNS_REVISA+CNS_CRONOG+CNS_PARCEL+CNS_ITEM
				cChaveCNS := xFilial("CNS",cFilCTR)+cContra+cRevisa+CNF->CNF_NUMERO+CNF->CNF_PARCEL //Chave parcial da CNS				
			EndIf
		EndIf
		
		If lGSLE .AND. FindFunction("TecBCtrLE")
			lGSLE := TecBCtrLE(CNB->CNB_FILIAL,CNB->CNB_CONTRA,CNB->CNB_REVISA)
		EndIf

		While CNB->( !EOF() .And. (CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO == cSeek) )
			nValUnit:= 0
			nPDesc 	:= 0
			cItem 	:= CNB->CNB_ITEM
			dEntrega:= Max(dDatabase, CNB->CNB_DTPREV)

			lContinua := (!lFixo .Or. (lFixo .And. Round(CNB->(CNB_SLDMED*CNB_VLUNIT),nDecVlTot) > 0))

			If( lContinua .And. lFixo .And. lFisico)
				If (lContinua := CNS->(MsSeek(cChaveCNS + cItem)))
					lContinua := (CNS->CNS_SLDQTD > 0)//Em planilhas fisicas, só deve trazer item com saldo na CNS
				EndIf				
			EndIf
			
			If lContinua .AND. lGSLE
				lContinua := lContinua .AND. Empty(CNB->CNB_ITMDST)
			EndIf

            If (lContinua)
				If nY <> 0 .And. lAddItem .And. !Empty(oModelCNE:GetValue("CNE_PRODUT"))
					aAreaCNB := CNB->(GetArea())
					
					If ( (oModelCNE:Length(.T.)+1) <= oModelCNE:GetMaxLines() )
						oModelCNE:AddLine()
					else
						oModel:SetErrorMessage("",,"CNEDETAIL","","CN121MAXCOL",STR0240,STR0241)//Verifique o valor informado no parâmetro MV_COMLMAX
					EndIf
					RestArea(aAreaCNB)
				EndIf
				nY++
				If (nY == oModelCNE:GetLine() .Or. !Empty(cItemCNB)) .And. !(oModel:HasErrorMessage())
					
					//Popula Modelo de Itens
					oModelCNE:LoadValue('CNE_CONTRA',CNB->CNB_CONTRA)
					oModelCNE:LoadValue('CNE_REVISA',CNB->CNB_REVISA)
					oModelCNE:LoadValue('CNE_NUMERO',CNB->CNB_NUMERO)
					oModelCNE:LoadValue('CNE_ITEM'	,CNB->CNB_ITEM)					

					If IsExced()
						oModelCNE:SetValue('CNE_PRODUT',"")
					Else
						oModelCNE:SetValue('CNE_PRODUT',CNB->CNB_PRODUT)
						oModelCNE:LoadValue('CNE_DESCRI',CNB->CNB_DESCRI)
					EndIf
					oModelCNE:LoadValue('CNE_TABPRC',CNB->CNB_TABPRC)
					oModelCNE:LoadValue('CNE_FLGCMS',CNB->CNB_FLGCMS)
					
					//Carrega as informações contábeis do item do contrato somente se a medição estiver na mesma filial do contrato ou se as tabelas tiverem comparilhamentos compatíveis
					If !Empty(CNB->CNB_CC)
						oModelCNE:SetValue( 'CNE_CC', CNB->CNB_CC )
					EndIf
					If !Empty(CNB->CNB_CONTA) 
						oModelCNE:SetValue( 'CNE_CONTA', CNB->CNB_CONTA )
						If cPaisLoc == "RUS" .And. nY != oModelCNE:GetLine()
							oModelCNE:GoLine(nY) // CNE_CONTA has function CTB105CTA in validation. This function refreshing oView, after that Spreadsheets grid loses his line.
						EndIf
					EndIf
					If !Empty(CNB->CNB_ITEMCT)
						oModelCNE:SetValue( 'CNE_ITEMCT', CNB->CNB_ITEMCT )
					EndIf
					If !Empty(CNB->CNB_CLVL)
						oModelCNE:SetValue( 'CNE_CLVL', CNB->CNB_CLVL )
					EndIF
					
					oModelCNE:LoadValue('CNE_CODNE'	,CNB->CNB_CODNE)
					oModelCNE:LoadValue('CNE_ITEMNE',CNB->CNB_ITEMNE)

					If (lTecBLoadMd .OR. lTECItGSEn) .AND. cGCTxGS == "0"
						aAreaGS := GetArea()
						
						TFJ->(DbSetOrder(5)) //TFJ_FILIAL+TFJ_CONTRT+TFJ_CONREV
						If TFJ->(MsSeek(cFilTFJ+CNB->CNB_CONTRA+CNB->CNB_REVISA))
							cGCTxGS := "1"
							cCodTFJ := TFJ->TFJ_CODIGO
						Else
							cGCTxGS := "2"
						EndIf
						
						RestArea(aAreaGS)
						FwFreeArray(aAreaGS)
					EndIf
					
					If IsExced()//Excedente por Competência não prevista
						nValUnit := 0
						nPDesc := 0
						oModelCNE:LoadValue('CNE_EXCEDE','1')
					Else
						nValUnit:= xMoeda(CNB->CNB_VLUNIT, nMoedaCtr, nMoedaMed, dDataInic)
						nPDesc	:= CNB->CNB_DESC
						oModelCNE:LoadValue('CNE_EXCEDE','2')
					EndIf

					If !(CN121MdServ())
						oModelCNE:LoadValue('CNE_VLUNIT',nValUnit)
					EndIf
					oModelCNE:LoadValue('CNE_PDESC' ,nPDesc)
					oModelCNE:LoadValue('CNE_PRODSV',CNB->CNB_PRODSV)
					oModelCNE:LoadValue('CNE_DTENT'	,dEntrega)
					oModelCNE:LoadValue('CNE_IDPED'	,CNB->CNB_IDPED)

					If lTecBLoadMd .AND. cGCTxGS == '1' //Apenas contratos integrados com o Prestadores de Serviços
						TecBLoadMd(CNB->CNB_CONTRA,CNB->CNB_REVISA,CNB->CNB_NUMERO,CNB->CNB_ITEM, oModel, cCodTFJ, cFilCNB)
					EndIf					

					If !Empty(CNB->CNB_PEDTIT)
						oModelCNE:LoadValue('CNE_PEDTIT',CNB->CNB_PEDTIT)
					EndIf

					If lCompra						
						cCodTES := oModelCNE:GetValue('CNE_TE')//Caso o usuário informe algum valor no inicializar padrão, não sobrescreve
						cCodTES := IIF(Empty(cCodTES), CNB->CNB_TE, cCodTES)
						oModelCNE:SetValue('CNE_TE'		,cCodTES)
						oModelCNE:LoadValue("CNE_TES"	,cCodTES)
						If cPaisLoc == "RUS"
							oModelCNE:SetValue('CNE_CF'		,CNB->CNB_CF)
						EndIf
					Else
						cCodTES := oModelCNE:GetValue('CNE_TS')//Caso o usuário informe algum valor no inicializar padrão, não sobrescreve
						cCodTES := IIF(Empty(cCodTES), CNB->CNB_TS, cCodTES)
						oModelCNE:SetValue('CNE_TS'		,cCodTES)
						oModelCNE:LoadValue("CNE_TES"	,cCodTES)
						If cPaisLoc == "RUS"
							oModelCNE:SetValue('CNE_CF'		,CNB->CNB_CF)
						EndIf
					EndIf

					If lRecorre // Verifica contrato recorrente
						If CNB->CNB_ATIVO == "1" // verifica item ativo
							oModelCNE:LoadValue('CNE_QTAMED',CNB->CNB_SLDMED - Cn121QtdBlq(CNB->CNB_CONTRA,CNB->CNB_REVISA,CNB->CNB_NUMERO,CNB->CNB_ITEM, cFilCtr) )
							oModelCNE:LoadValue('CNE_SDAMED',oModelCNE:GetValue('CNE_QTAMED') )
							oModelCNE:LoadValue('CNE_QTDSOL',CNB->CNB_QUANT)

							If CNB->CNB_PARPRO > 0 .And. Empty(CNB->CNB_PRIMED) // verifica se é primeira medição e se é proproporcional
								oModelCNE:SetValue('CNE_QUANT',CNB->CNB_QUANT * CNB->CNB_PARPRO /100 )
								oModelCNE:SetValue('CNE_PERC',CNB->CNB_PARPRO)
							Else
								oModelCNE:SetValue('CNE_QUANT',CNB->CNB_QUANT)
							EndIf
						Else
							oModelCNE:SetValue('CNE_QUANT',0)
						Endif
					Else
						If lFixo
							//Excedente por Competência não prevista
							If IsExced()
								oModelCNE:LoadValue('CNE_QTAMED',0)
								oModelCNE:LoadValue('CNE_SDAMED',0)
								oModelCNE:LoadValue('CNE_QTDSOL',0)							
							Else
								oModelCNE:LoadValue('CNE_QTAMED',CNB->CNB_SLDMED)
								oModelCNE:LoadValue('CNE_SDAMED',Iif(oModelCNE:GetValue('CNE_QTAMED') < 0, 0, oModelCNE:GetValue('CNE_QTAMED')))
								oModelCNE:LoadValue('CNE_QTDSOL',CNB->CNB_QUANT)
							EndIf
						Else
							oModelCNE:SetValue('CNE_PERC',0)
						EndIf

						If !lMedEve
							If !lFisico
								If IsExced()
									oModelCNE:SetValue('CNE_QUANT',0)
								Else
									aAreaCNA := CNA->(GetArea())

									nVlQuant := Cn121QtdIt(CNB->CNB_SLDMED,CNA->CNA_SALDO,CNF->CNF_SALDO,lFisico,lFixo)
									If CN121MdServ()
										nVlQuant := A410Arred( nVlQuant , "CNE_QUANT" )
										oModelCNE:LoadValue('CNE_QTDORI', nVlQuant)
										oModelCNE:LoadValue('CNE_VUNORI', CNB->CNB_VLUNIT)
										oModelCNE:LoadValue('CNE_VLUNIT', CNB->CNB_VLUNIT * nVlQuant)
										oModelCNE:LoadValue('CNE_PERC'	, (nVlQuant * 100) / CNB->CNB_QUANT)										
										oModelCNE:SetValue('CNE_QUANT'	, 1)
									ElseIf Round(CNB->CNB_VLUNIT * nVlQuant, nDecVlTot) > 0
										oModelCNE:SetValue('CNE_QUANT', nVlQuant)
									EndIf
									RestArea(aAreaCNA)
								EndIf
							Else
								If IsExced()
									oModelCNE:SetValue('CNE_QUANT',0)
								Else
									oModelCNE:SetValue('CNE_QUANT',Min(CNS->CNS_SLDQTD,oModelCNE:GetValue('CNE_SDAMED')))// Saldo na CNS
								EndIf
							EndIf
						ElseIf CN121MdServ() .And. !(oModel:HasErrorMessage())
							oModelCNE:LoadValue('CNE_QTDORI', 0)
							oModelCNE:LoadValue('CNE_VUNORI', CNB->CNB_VLUNIT)
							oModelCNE:LoadValue('CNE_VLUNIT', CNB->CNB_VLUNIT)
							oModelCNE:LoadValue('CNE_PERC'  , Round((1 / CNB->CNB_QUANT * 100), nDecPerc))										
							oModelCNE:SetValue('CNE_QUANT'	, 1)							
						Else
							oModelCNE:SetValue('CNE_QUANT',0)
						EndIf
					EndIf

					If lServico
						If oModelCNE:GetValue('CNE_QUANT') == 0							
							nValUnit := 0
						Else
							oModelCNE:SetValue('CNE_VLUNIT',nValUnit)
						Endif	
					EndIf					
					
					For nX := 1 To Len(aECAdic)//Campos de entidades adicionais
						cCpoCNB := CNB->(FieldGet( aECAdic[nX,3] ))
						If!Empty(cCpoCNB)
							oModelCNE:SetValue(aECAdic[nX,1], cCpoCNB )
						EndIf
					Next nX

					If lArrendCpo
						oModelCNE:LoadValue( "CNE_ARREND", CNB->CNB_ARREND )
					EndIf

					//Carrega Agregados dos itens
					CN121CNZIt(oModel, oModelCNZ)
					If lMulta						
						CN121CNRIt(oModel, .T., "2")
					EndIf
					
					If (lTECItGSEn .AND. cGCTxGS == '1')//Apenas contratos integrados com o Prestadores de Serviços
						//Verifica se o item do contrato é do GS e está  configurado para apurar zerado o item encerrado
						If (TECItGSEn(CNB->CNB_CONTRA, CNB->CNB_REVISA, CNB->CNB_NUMERO, CNB->CNB_ITEM,,CNB->CNB_PRODUT, oModelCNE) .Or.;
							(GCTGsMvZer() .And. TecGsMdZer(CNB->CNB_CONTRA, CNB->CNB_REVISA, CNB->CNB_NUMERO, CNB->CNB_ITEM, FwIsInCallStack("CN260Exc"), cCompet)) .Or.;
							!(TecGsVerDt(CNB->CNB_CONTRA,CNB->CNB_REVISA,cCompet,CNB->CNB_ITEM )) )

							oModelCNE:SetValue('CNE_QUANT', 0) 
							nProdGsZero++
						EndIf
					EndIf
				EndIf

				If oModel:HasErrorMessage() .Or. !oModelCNE:VldLineData() //Não inclui linha com erro
					nQtdItErro ++ //-- Soma quantidade de itens com erro
					
					aItemErro[1] := CNB->CNB_ITEM
					aItemErro[2] := oModel:GetErrorMessage()					

					If !oModelCXN:GetValue('CXN_IGITEM') //Sai do loop caso exista algum item com erro
						Exit
					EndIf

					oModel:GetErrorMessage(.T.) //Limpa erro do modelo
                    lAddItem := .F.
					nY--
                Else
                    lAddItem := .T.
				EndIf
		    EndIf
	      	CNB->(dbSkip())
		EndDo

		If !Empty(aItemErro[1])
			If !oModelCXN:GetValue('CXN_IGITEM')
                oModel:SetErrorMessage(,,,, aItemErro[2][5] + " ", STR0194 + aItemErro[1] + CRLF + CRLF + RTrim(aItemErro[2][6]), RTrim(aItemErro[2][7])) //Existe inconsistência no item: XXXX
				lRet := .F.
			Else
				If 	Empty(oModelCNE:GetValue('CNE_PRODUT')) .Or. (CN121MdServ() .And. oModelCNE:GetValue('CNE_QUANT') == 0)//Deleta linha em branco					
					oModelCNE:DeleteLine(.T.,.T.)
				EndIf				

				If oModelCNE:Length(.T.) == 0 .Or. nQtdeItens == nQtdItErro //-- Retorna erro caso não exista nenhuma linha no modelo ou a quantidade de itens seja igual a quantidade de itens com erro
					oModel:SetErrorMessage(,,,, aItemErro[2][5] + " ", STR0195 + aItemErro[1] + CRLF + CRLF + RTrim(aItemErro[2][6]), RTrim(aItemErro[2][7])) //Não há itens válidos para medição. Verifique o item
					lRet:= .F.
				EndIf
			EndIf
		EndIf
		
		If lRet .And. (lTECItGSEn .And. oModelCNE:Length() == nProdGsZero) 
			oModelCXN:LoadValue("CXN_ZERO" , "1" )
		EndIf
	EndIf
EndIf


If cPaisLoc == "RUS"
	oView := FWViewActive()
	If ValType(oView) == "O" .And. oView:IsActive()
		oViewCNE := oView:GetViewObj("VIEW_CNE")[3]
    	oViewCNE:Refresh(/* lEvalChanges */, .T. /* lGoTop */)
	EndIf
EndIf

RestArea(aArea)
FWRestRows( aSaveLines )

FWFreeArray( aArea )
FWFreeArray( aSaveLines )
FWFreeArray( aItemErro )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121MultT()
Efetua a Validacao dos campos digitados quanto a quantidade,preco,
desconto e quantidade liberada.

@author filipe.gonçalves
@since 28/07/2015

@version P12.1.7
/*/
//-------------------------------------------------------------------
Function CN121MultT(oModelGrid,cField,cValue,cOldValue,lCheck120)
Local aArea     := GetArea()
Local oModel	:= Nil
Local oModelCNE := Nil
Local cContra	:= Nil
Local cPlan		:= Nil
Local lFixo		:= Nil
Local lServico	:= Nil
Local cEspecie  := ""
Local lIsCnta120 := .F.
Default cField	:= ""
Default lCheck120 := .T.

If lCheck120
	lIsCnta120 := (FwIsInCallStack('CNTA120') .Or. FwIsInCallStack('CN121OldMd')) .And. IsNotTEC930()
EndIf

If lIsCnta120
	CN130MultT()
ElseIf(!FwIsInCallStack("Cn260Exc"))
	oModel		:= IIF(oModelGrid == Nil, FwModelActive(), oModelGrid:GetModel())
	cContra		:= oModel:GetValue("CNDMASTER","CND_CONTRA")
	cPlan		:= oModel:GetValue("CXNDETAIL","CXN_NUMPLA")
	cEspecie	:= CN121RetSt("ESPECIE",0,cPlan,cContra)

	If (cEspecie=="2")	
		oModelCNE	:= oModel:GetModel("CNEDETAIL")
		
		If (lFixo := CN121RetSt("FIXO"	,0,cPlan,cContra))

			If cField $ 'CNE_VLUNIT|CNE_VLTOT|CNE_PERC|'
				lServico:= CN121RetSt("SERVICO"	,0,cPlan,cContra)				
			EndIf

			Do Case
				Case cField == "CNE_VLUNIT"
					If (!lServico )
						FtDescItem(0,@cValue,oModelCNE:GetValue('CNE_QUANT'),oModelCNE:GetValue('CNE_VLTOT'),oModelCNE:GetValue('CNE_PDESC'),oModelCNE:GetValue('CNE_VLDESC'),0,1,,)
					Else
						FtDescItem(0,oModelCNE:GetValue('CNE_VUNORI'),@cValue/oModelCNE:GetValue('CNE_VUNORI'),oModelCNE:GetValue('CNE_VLTOT'),oModelCNE:GetValue('CNE_PDESC'),oModelCNE:GetValue('CNE_VLDESC'),0,1,,)
					EndIf

				Case cField == "CNE_QUANT"
					FtDescItem(0,oModelCNE:GetValue('CNE_VLUNIT'),@cValue,oModelCNE:GetValue('CNE_VLTOT'),oModelCNE:GetValue('CNE_PDESC'),oModelCNE:GetValue('CNE_VLDESC'),0,1,,)

				Case cField == "CNE_PDESC"
					FtDescItem(0,oModelCNE:GetValue('CNE_VLUNIT'),oModelCNE:GetValue('CNE_QUANT'),oModelCNE:GetValue('CNE_VLTOT'),@cValue,oModelCNE:GetValue('CNE_VLDESC'),0,1,,)

				Case cField == "CNE_VLTOT"					
					If (!lServico )
						FtDescItem(0,oModelCNE:GetValue('CNE_VLUNIT'),(@cValue/oModelCNE:GetValue('CNE_VLUNIT')) ,@cValue,oModelCNE:GetValue('CNE_PDESC'),oModelCNE:GetValue('CNE_VLDESC'),0,1,,)
					Else
						FtDescItem(0,oModelCNE:GetValue('CNE_VUNORI'),(@cValue/oModelCNE:GetValue('CNE_VUNORI')),@cValue,oModelCNE:GetValue('CNE_PDESC'),oModelCNE:GetValue('CNE_VLDESC'),0,1,,)
					EndIf

				Case cField == "CNE_PERC"					
					If (!lServico )
						FtDescItem(0,oModelCNE:GetValue('CNE_VLUNIT'),(oModelCNE:GetValue('CNE_QTDSOL')*@cValue)/100,oModelCNE:GetValue('CNE_VLTOT'),oModelCNE:GetValue('CNE_PDESC'),oModelCNE:GetValue('CNE_VLDESC'),0,1,,)
					Else
						FtDescItem(0,oModelCNE:GetValue('CNE_VUNORI'),(oModelCNE:GetValue('CNE_QTDSOL')*@cValue)/100,oModelCNE:GetValue('CNE_VLTOT'),oModelCNE:GetValue('CNE_PDESC'),oModelCNE:GetValue('CNE_VLDESC'),0,1,,)
					EndIf
			EndCase		
		Else
			Do Case
				Case cField == "CNE_VLUNIT"
					oModelCNE:SetValue('CNE_VLDESC'	,0)
					oModelCNE:SetValue('CNE_PDESC'	,0)
				Case cField == "CNE_PDESC"
					FtDescItem(0,oModelCNE:GetValue('CNE_VLUNIT'),oModelCNE:GetValue('CNE_QUANT'),oModelCNE:GetValue('CNE_VLTOT'),@xConteudo,oModelCNE:GetValue('CNE_VLDESC'),0,1,,)
			EndCase
		EndIf		
	EndIf
EndIf

RestArea(aArea)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121Mult()
Validação do campo código da multa/bonificação

@author jose.eulalio
@since 28/07/2015
@version P12
@return .T.
/*/
//--------------------------------------------------------------------
Function Cn121Mult()
Local aArea		:= GetArea()
Local lRet		:= .T.
Local lFormula	:= .F.
Local oModel	:= FwModelActive()
Local oModCNR1	:= oModel:GetModel("CNRDETAIL1")
Local cCod		:= oModCNR1:GetValue("CNR_CODIGO")
Local nValor	:= 0

DbSelectArea("CN4")
CN4->(DbSetOrder(1))

If CN4->(MsSeek(FwXFilial('CN4')+cCod))
	lFormula := IIf( Empty( CN4->CN4_VLDALT ), Formula( CN4->CN4_VALID ), CNTA130Form( CN4->CN4_VLDALT ) )
	lFormula := IIf( ValType( lFormula ) == 'L', lFormula , .F. )

	If lFormula
		nValor := IIf( Empty( CN4->CN4_VLRALT ), Formula( CN4->CN4_FORMUL ), CNTA130Form( CN4->CN4_VLRALT ) )
        nValor := IIf( ValType( nValor ) == 'N', nValor, 0 )
	EndIf

	oModCNR1:LoadValue("CNR_MODO","2")
	oModCNR1:SetValue("CNR_FLGPED",CN4->CN4_FLGPED)
	oModCNR1:SetValue("CNR_TIPO",CN4->CN4_TIPO)
	oModCNR1:SetValue("CNR_VALOR",nValor)
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121VldDtEnt()
Valida data de entrada informada nas medicoes

@author filipe.gonçalves
@since 29/07/2015

@version P12.1.7
/*/
//-------------------------------------------------------------------
Function CN121VldDtEnt()
Local oModel	:= Nil
Local oModelCNE	:= Nil
Local lRet 		:= .T.

If (IsInCallStack('CNTA120') .Or. FwIsInCallStack('CN121OldMd')) .And. IsNotTEC930()
	CN130VldDtEnt()
Else
	oModel	:= FWModelActive()
	oModelCNE	:= oModel:GetModel('CNEDETAIL')
	lRet := (FwFldGet('CNE_DTENT') >= dDataBase)
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121VlTot()
Valida valor total informado na medicao

@author filipe.gonçalves
@since 29/07/2015

@version P12.1.7
/*/
//-------------------------------------------------------------------
Function CN121VlTot( nValue )
Local aArea		:= GetArea()
Local aSaveLines:= FWSaveRows()
Local oModel	:= Nil
Local oModelCND	:= Nil
Local oModelCXN	:= Nil
Local oModelCNE	:= Nil
Local nVlDesc	:= 0
Local nSaldoIt	:= 0
Local nQtdePend := 0
Local nValorUn  := 0
Local lRet      := .T.
Local lSemiFixo	:= .F.
Local lSemiAgr	:= .F.
Local lEventual := .F.
Local lFixo 	:= .F.
Local lPrevFin 	:= .F.
Local lServico	:= .F.
local lFlexPrev  := .F.
local lFlexSPrev := .F.
Local lCNEPreVld := FwIsInCallStack("Cn121CNEPV")
Local cContra	 := ""
Local cPlan		 := ""
Local nLimite	 := 0

If !lCNEPreVld .And. (FwIsInCallStack('CNTA120') .Or. FwIsInCallStack('CN121OldMd')) .And. IsNotTEC930()
	lRet := CN130VlTot()
Else
	oModel		:= FWModelActive()
	oModelCND	:= oModel:GetModel('CNDMASTER')
	oModelCXN	:= oModel:GetModel('CXNDETAIL')
	oModelCNE	:= oModel:GetModel('CNEDETAIL')			

	If nValue == Nil
		nValue := oModelCNE:GetValue('CNE_VLTOT')
	EndIf

	If !IsExced()
		
		If oModelCND:GetValue('CND_ZERO') == "1" //Verifica se o total e igual a zero quando a medicao for zerada
			lRet := ( nValue == 0 )
		ElseIf !(CN121MdServ())			
			cContra		:= oModelCXN:GetValue("CXN_CONTRA")
			cPlan		:= oModelCXN:GetValue("CXN_NUMPLA")
			lFixo 		:= CN121RetSt('FIXO')
			lPrevFin 	:= CN121RetSt("PREVFINANC")
			lEventual 	:= CN121RetSt("EVENTUAL")
			lFlexPrev 	:= lEventual .And. !lFixo .And. lPrevFin //Flexível com previsão financeira
			lFlexSPrev 	:= lEventual .And. !lFixo .And. !lPrevFin //Flexível sem previsão financeira
			
			If !lFlexSPrev

				lSemiFixo 	:= CN121RetSt( "SEMIFIXO", 0, cPlan, cContra, .T., oModel )
				lServico 	:= CN121RetSt( "SERVIÇO", 0, cPlan, cContra, .F. )

				If !lFlexPrev .And. !lSemiFixo .And. IsNotTEC930()
					nQtdePend := oModelCNE:GetValue('CNE_SDAMED')
					nValorUn := oModelCNE:GetValue('CNE_VLUNIT')
					nLimite	 := CN121RetSt("LMTMED",0, cPlan, cContra, .F.,,oModelCND:GetValue("CND_FILCTR"))
					nSaldoIt := IIF(nLimite > 0,Cn121LtMed(oModelCXN),(nQtdePend * nValorUn))
											
					If nValue > nSaldoIt //Valida se o valor informado ultrapassa o saldo do item
						lRet := .F.
						FwClearHLP() // Caso algum help tenha sido exibido anteriormente na tela antes de validar o total, limpa o help anterior para não exibir erroneamente um help indevido
						oModel:SetErrorMessage( "CNEDETAIL", "CNE_VLTOT", "CNEDETAIL", "CNE_VLTOT", "CNEVLTOT1", STR0187 + " (" + cValToChar(nSaldoIt) + ")" ) //"O valor Total informado é maior do que o saldo do item"
					EndIf
				EndIf

				If lRet .And. lSemiFixo
					If oModelCXN:GetValue("CXN_VLSALD") < nValue
						lRet := .F.
                        oModel:SetErrorMessage( "CNEDETAIL", "CNE_VLTOT", "CNEDETAIL", "CNE_VLTOT", "CXNSLDMED2", STR0215 + " (" + cValToChar(oModelCXN:GetValue("CXN_VLSALD")) + ")" ) //"O Valor Total informado é maior que o saldo da planilha"
					EndIf
					
					lSemiAgr := CN121RetSt("SEMIAGRUP", 0, oModelCXN:GetValue("CXN_NUMPLA"), oModelCXN:GetValue("CXN_CONTRA") )
					If lSemiAgr
						lRet := CN121VlAgr(oModelCNE:GetValue("CNE_PRODUT"),oModelCNE:GetValue("CNE_QUANT"),0)
					EndIf
				EndIf				
		
				If lRet .And. !lCNEPreVld //Regra para calcular valor do desconto.		

					If Cn121RetSt('COMPRA')
						nVlDesc := CNEVLDesc(nValue, oModelCNE:GetValue('CNE_PDESC'))					
					Else
						nVlDesc := CtrValDesc("2",;
										nValue	 ,;
										oModelCNE:GetValue('CNE_PDESC'),;
										oModelCNE:GetValue('CNE_VLUNIT'),;
										oModelCNE:GetValue('CNE_QUANT') )
					EndIf

					CNNoWhenSet(oModelCNE, 'CNE_VLDESC', nVlDesc)
				EndIf
			EndIf
		EndIf

		If lRet .And. !lCNEPreVld //Validação para preenchimento dos campos de Valor do rateio quando alterado CNE_VLTOT
			Cn121AtuRat(nValue)
		EndIf
	EndIf
EndIf

RestArea( aArea )
FwFreeArray(aArea)
FWRestRows( aSaveLines )
FwFreeArray(aSaveLines)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121VldPerc()
Valida percentual informado nas medicoes

@author filipe.gonçalves
@since 28/07/2015

@version P12.1.7
/*/
//-------------------------------------------------------------------
Function CN121VldPerc()
Local lRet     	:= .T.
Local aArea		:= GetArea()
Local aSaveLines:= FWSaveRows()
Local oModel	:= Nil
Local oModelCND	:= Nil
Local oModelCNE	:= Nil
Local lArrefat 	:= .F.
Local nTotal   	:= 0
Local nQtdSol	:= 0
Local nQtdMed	:= 0
Local cExeced	:= 0
Local nPerc		:= 0
Local nPercMed 	:= 0

If (IsInCallStack('CNTA120') .Or. FwIsInCallStack('CN121OldMd')) .And. IsNotTEC930()
	lRet := CN130VldPerc()
Else
	oModel		:= FWModelActive()
	oModelCND	:= oModel:GetModel('CNDMASTER')
	oModelCNE	:= oModel:GetModel('CNEDETAIL')
	lArrefat 	:= (SuperGetMv("MV_ARREFAT",.F.,"S")== "S")
	nTotal   	:= 0
	nQtdSol		:= oModelCNE:GetValue('CNE_QTDSOL')
	nQtdMed		:= oModelCNE:GetValue('CNE_SDAMED')
	cExeced		:= oModelCNE:GetValue('CNE_EXCEDE')
	nPerc		:= oModelCNE:GetValue('CNE_PERC')
	nPercMed 	:= (nQtdSol-nQtdMed)*100/nQtdSol //- Calculo do Percentual disponivel

	//-- Se excedente não permite digitar percentual
	If !Empty(cExeced) .And. cExeced == '1'
		Aviso(STR0079,STR0080,{STR0156}) //"Este campo não deve ser utilizado para itens classificados como excedente."
		lRet := .F.
	ElseIf oModelCND:GetValue('CND_ZERO') == "1" //-- Medição zerada possui percentual 0
		lRet := nPerc == 0
	Else
		lRet := nPerc <= (100-nPercMed)
		If !lRet
			nTotal := nPerc -(100-nPercMed)
			If nTotal<=0.001 .And. !lArrefat
			   lRet := .T.
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aArea)
FWRestRows( aSaveLines )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121VlUnt()
Valida valor unitario informado na medicao

@author filipe.gonçalves
@since 29/07/2015

@version P12.1.7
/*/
//-------------------------------------------------------------------
Function CN121VlUnt(oModelGrid,cField,xValue,nLine,lDesconto)
Local aArea		:= GetArea()
Local aSaveLines:= FWSaveRows()
Local oModel	:= Nil
Local oModelCND := Nil
Local oModelCXN	:= Nil
Local oModelCNE	:= Nil
Local cProdut	:= ""
Local cContra	:= ""
Local cRevisa	:= ""
Local cNumPla	:= ""
Local lRet 		:= .T.
Local lArrefat 	:= .F.
Local lSemiAgr	:= .F.
Local lEventual	:= .F.
Local lFixo 	:= .F.
Local lPrevFin 	:= .F.
Local lServico	:= .F.
Local nQuant  	:= 0
Local nTotal 	:= 0
Local nTotCNE	:= 0
Local nX		:= 0
Local nLimite	:= 0
Default lDesconto:= .F.

If (IsInCallStack('CNTA120') .Or. FwIsInCallStack('CN121OldMd')) .And. IsNotTEC930()
	CN130VlUnt()
Else
	oModel		:= FWModelActive()
	oModelCND 	:= oModel:GetModel('CNDMASTER')
	oModelCXN	:= oModel:GetModel('CXNDETAIL')
	oModelCNE	:= oModel:GetModel('CNEDETAIL')
	cProdut		:= oModel:GetValue("CNEDETAIL","CNE_PRODUT")
	cContra		:= oModelCND:GetValue("CND_CONTRA")
	cRevisa		:= oModelCND:GetValue("CND_REVISA")
	cNumPla		:= oModelCXN:GetValue("CXN_NUMPLA")
	lArrefat 	:= (SuperGetMv("MV_ARREFAT",.F.,"S")== "S")
	lSemiAgr	:= CN121RetSt("SEMIAGRUP",0,cNumPla,cContra)
	lEventual	:= CN121RetSt("EVENTUAL", 0,cNumPla,cContra)
	lFixo		:= CN121RetSt("FIXO",0,cNumPla,cContra)
	lPrevFin	:= CN121RetSt("PREVFINANC",0,cNumPla,cContra)
	lServico	:= CN121RetSt("SERVIÇO",0,cNumPla,cContra)

	If !IsExced()
		//Verifica se a quantidade e menor que o saldo disponivel
		If oModelCNE:GetValue('CNE_SDAMED')  > 0
			If oModelCND:GetValue('CND_SERVIC') == '2'
				nQuant := oModelCNE:GetValue('CNE_VLUNIT') / oModelCNE:GetValue('CNE_VUNORI')
				lRet   := (nQuant <= oModelCNE:GetValue('CNE_SDAMED'))
			EndIf
		EndIf

		If !lRet
			nTotal := nQuant - oModelCNE:GetValue('CNE_SDAMED')
			If nTotal <= 0.001 .And. !lArrefat
			   lRet := .T.
			EndIf
		EndIf

		If lRet
			For nX := 1 to oModelCNE:Length()
				oModelCNE:GoLine(nX)
				If !oModelCNE:IsDeleted()
					If oModelCNE:GetLine() == nLine
						nTotCNE += oModelCNE:GetValue("CNE_QUANT") * xValue
					Else
						nTotCNE += oModelCNE:GetValue("CNE_VLTOT")
					EndIf

					If lDesconto
						nTotCNE-=oModelCNE:GetValue("CNE_VLDESC")						
					EndIf
					
				EndIf
			Next nX
			
			lVldEvent := lEventual .And. !lFixo .And. !lPrevFin
			
			If oModelCXN:GetValue("CXN_VLSALD") < nTotCNE .And. !lVldEvent
				lRet := .F.
				Help(" ",1,"CN121VLCNE")
			EndIf
		EndIf

		//Validação do Agrupador com relação ao valor maximo da CXM
		If lRet .And. lSemiAgr
			lRet := C121CNEAgr(oModel,cField,xValue,nLine)
		EndIf
	EndIf

 	//Valida se o valor unitário informado ultrapassa o valor previsto do cronograma financeiro quando a planilha é de serviço
	If lRet .And. lServico
		nLimite	 := Cn121LtMed(oModelCXN)
		If xValue > nLimite
			lRet := .F.
			oModel:SetErrorMessage( "CNEDETAIL", "CNE_VLUNIT", "CNEDETAIL", "CNEVLUNIT", "CNEVLUNIT", STR0243 ) //"O valor unitário informado é maior do que o valor previsto"
		EndIf
	EndIf

EndIf

RestArea(aArea)
FWRestRows( aSaveLines )

FwFreeArray(aArea)
FwFreeArray(aSaveLines)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121RetCa
Função para pegar o valor da caucao de retencao
@author filipe.gonçalves
@since 29/07/2015
@version P12.1.7
/*/
//-------------------------------------------------------------------
Function CN121RetCa( nTotMed, oModel )
	Local aAreas		:= {CN9->(GetArea()), CND->(GetArea()), GetArea()}
	Local oModelCND		:= Nil
	Local oModelCXN		:= Nil
	Local cFilCtr		:= ""
	Local cContra		:= ""
	Local cRevisa		:= ""
	Local cPlan			:= ""
	Local lCaucRet		:= .F.
	Local nCaucRet  	:= 0
	Local nCaucVlr  	:= 0
	Local nCn121VRet	:= 0
	Default nTotMed		:= 0
	Default oModel	    := FWModelActive()

	oModelCND := oModel:GetModel('CNDMASTER')
	cFilCtr := oModelCND:GetValue("CND_FILCTR")
	cContra := oModelCND:GetValue("CND_CONTRA")

	If (oModel:GetOperation() == MODEL_OPERATION_VIEW)
		cRevisa := oModelCND:GetValue("CND_REVGER") //Há cenários que o percentual de retenção foi alterado de uma revisão p/ outra
	Else
		cRevisa := oModelCND:GetValue("CND_REVISA")	
	EndIf

	CN9->( dbSetOrder( 1 ) ) //CN9_FILIAL+CN9_NUMERO+CN9_REVISA
	If CN9->( msSeek( FWxFilial("CN9",cFilCtr) + cContra + cRevisa ) )
		
		lCaucRet := CN9->(CN9_FLGCAU == "1" .And. CN9_TPCAUC == "2" )
		If lCaucRet //Verifica se a caução de retenção está disponível para o contrato
			nCaucRet := CN9->CN9_MINCAU
			
			If _lCN121VRE //Ponto de Entrada para permitir alteracao no percentual de retencao
				oModelCXN := oModel:GetModel('CXNDETAIL')
				cPlan := oModelCXN:GetValue('CXN_NUMPLA')
				nCn121VRet := ExecBlock( "CN121VRE", .F., .F., {cContra,cRevisa,cPlan} )
				nCaucRet := Iif( Valtype(nCn121VRet) == "N", nCn121VRet, nCaucRet )
			EndIf
		
			//Calcula valor da retencao
			nCaucVlr := ( ( nTotMed * nCaucRet ) / 100 )		
		ElseIf(nTotMed > 0 .And. oModel:GetOperation() == MODEL_OPERATION_VIEW )
			CND->(DbGoTo(oModelCND:GetDataID()))//Garante o posicionamento na CND correta		
			nCaucVlr := CND->CND_RETCAC
		EndIf
	EndIf

	nCaucVlr := Max(nCaucVlr, 0)
	If nCaucVlr > 0
		nCaucVlr := Round(nCaucVlr, GetSx3Cache("CND_RETCAC", "X3_DECIMAL") )
	EndIf

	aEval(aAreas,{|x|RestArea(x)})
	FwFreeArray(aAreas)
Return nCaucVlr

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121CNRPl()
Carrega pasta de multas/bonificações

@author jose.eulalio
@since 29/07/2015
@version P12
@return .T.
/*/
//--------------------------------------------------------------------
Function CN121CNRPl(oModel,oModelCXN)
Local aSaveLines:= {}
Local lRet		:= .T.
Local oModCNR1	:= Nil
Local nX		:= 0

If (CN121RetSt('TPMULT') == "2")//Se multa na Medicao(CNL_TPMULT/CN1_TPMULT : 2=Medição)	
	oModCNR1 := oModel:GetModel("CNRDETAIL1")	

	aSaveLines:= FWSaveRows()
	For nX := 1 To oModCNR1:Length() //-- Verifica se já existe multa/bonificação automática
		oModCNR1:GoLine(nX)
		If oModCNR1:GetValue("CNR_MODO") == "1"
			lRet := .F.
			Exit
		EndIf
	Next nX
	FWRestRows(aSaveLines)
	FwFreeArray(aSaveLines)

	If lRet
		CN121CNRIt(oModel, .F.)		
	EndIf	
EndIf
Return lRet

/*/{Protheus.doc} Cn121CNRIt()
Carrega pasta de multas/bonificações
@author jose.eulalio
@since 29/07/2015
@version P12
@return .T.
/*/
Function CN121CNRIt(oModel, lItem, cTpMult)
	Local aAreas		:= {}
	Local aSaveLines	:= {}
	Local aProp			:= {}
	Local oSubModel		:= Nil
	Local cContrato		:= ""
	Local cRevisao		:= ""
	Local cFilCtr		:= ""
	Local nMult			:= 0
	Local nVlMult		:= 0
	Local nVlBonif		:= 0
	Local lRet			:= .T.
	Local cChave		:= ""
	Local cFilCN4		:= ""
	Local cTipo			:= ""
	Default oModel		:= FwModelActive()
	Default lItem		:= .T.
	Default cTpMult		:= CN121RetSt('TPMULT')

	If (cTpMult == "2")//Se multa na Medicao(CNL_TPMULT/CN1_TPMULT : 2=Medição)
		aAreas		:= {CNH->(GetArea()), CN4->(GetArea()), GetArea()}
		aSaveLines	:= FWSaveRows()
		cContrato	:= oModel:GetValue('CNDMASTER', 'CND_CONTRA')
		cRevisao	:= oModel:GetValue('CNDMASTER', 'CND_REVISA')
		cFilCtr		:= oModel:GetValue('CNDMASTER', 'CND_FILCTR')		
		cTipo		:= IIF(lItem, "2", "1")//1=Medição;2=Item
		
		CNH->(DbSetOrder(1))//CNH_FILIAL+CNH_NUMERO+CNH_CODIGO
		cChave := xFilial("CNH", cFilCtr) + cContrato
		If CNH->(DbSeek(cChave))
			oSubModel	:= oModel:GetModel( IIF(lItem, "CNRDETAIL2", "CNRDETAIL1") )
			aProp 		:= GetPropMdl(oSubModel)
			CNTA300BlMd(oSubModel,.F.)

			CN4->(DbSetOrder(1))//CN4_FILIAL+CN4_CODIGO
			cFilCN4	:= xFilial("CN4", cFilCtr)

			While CNH->(!Eof() .And. CNH_FILIAL+CNH_NUMERO == cChave)
				If (CNH->CNH_REVISA == cRevisao)					
					
					If CN4->(DbSeek(cFilCN4+CNH->CNH_CODIGO))

						While CN4->(!Eof() .And. CN4_FILIAL+CN4_CODIGO == cFilCN4+CNH->CNH_CODIGO )
							If (CN4->CN4_AVALIA == cTipo)
								nMult := Cn121vlMul() //Processa a fórmula da multa, retornando o valor

								If !Empty(nMult) //-- Não inclui multa zerada
									If CN4->CN4_TIPO == '1'
										nVlMult += nMult
									Else
										nVlBonif += nMult
									EndIf

									If oSubModel:IsDeleted() .Or. !Empty(oSubModel:GetValue("CNR_VALOR"))
										oSubModel:AddLine()
									EndIf
									oSubModel:LoadValue("CNR_TIPO"	, CN4->CN4_TIPO)
									oSubModel:LoadValue("CNR_DESCRI", CN4->CN4_DESCRI)
									oSubModel:LoadValue("CNR_FLGPED", CN4->CN4_FLGPED)
									oSubModel:SetValue("CNR_VALOR"	, nMult)
									oSubModel:LoadValue("CNR_MODO"	, "1") //-- Deve ser o ultimo campo a ser preenchido
								EndIf
							EndIf
							CN4->(DbSkip())
						EndDo
					EndIf
				EndIf
				CNH->(DbSkip())
			EndDo
	
			RstPropMdl(oSubModel, aProp)
			FwFreeArray(aProp)
		EndIf

		FWRestRows(aSaveLines)
		FwFreeArray(aSaveLines)

		aEval(aAreas, {|x|RestArea(x)})
		FwFreeArray(aAreas)
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121CXIIt()
Carrega pasta de Partes Envolvidas

@author Paulo V Beraldo
@since 20/08/2015
@version P12
@return .T.
/*/
//--------------------------------------------------------------------
Function CN121CXIIt(oModel)
Local oModelCXI	:= oModel:GetModel("CXIDETAIL")
Local aArea		:= GetArea()
Local aCXIArea	:= CXI->( GetArea() )
Local aSaveLines:= FWSaveRows()
Local cContrat	:= oModel:GetModel( 'CXNDETAIL' ):GetValue( 'CXN_CONTRA' )
Local cRevisa	:= oModel:GetModel( 'CXNDETAIL' ):GetValue( 'CXN_REVISA' )
Local cNumero	:= oModel:GetModel( 'CXNDETAIL' ):GetValue( 'CXN_NUMPLA' )
Local cLogError	:= ""
Local nCount	:= 0
Local nIncLine	:= 0
Local nInd		:= 0
Local lRet		:= .T.
Local lCanUpdCXI:= !(oModelCXI:CanUpdateLine())

dbSelectArea( 'CXI' )
CXI->( dbSetOrder( 1 ) ) //CXI_FILIAL+CXI_CONTRA+CXI_REVISA+CXI_NUMPLA+CXI_ITEM

If !CXI->( dbSeek( FwXFilial( 'CXI' ) + cContrat + cRevisa + cNumero ) )
	lRet := .F.
Else
	//Libera o Modelo para alteração
	oModelCXI:SetNoUpdateLine(.F.)
	CNTA300BlMd(oModelCXI,.F.) 		//- Libera o modelo
  	While CXI->( !Eof() ) .And. CXI->CXI_FILIAL == FwXFilial( 'CXI' ) .And. CXI->CXI_CONTRA == cContrat .And. CXI->CXI_REVISA == cRevisa .And. CXI->CXI_NUMPLA == cNumero
    	nCount ++
    	Do Case
    		Case ( nCount == 1 ) .And. ( nCount == oModelCXI:nLine )
      			nIncLine := nCount
    		Case ( nCount > 1 )
      			nIncLine := oModelCXI:AddLine()
      			If nCount # nIncLine
                    AEval( oModel:GetErrorMessage(), { | x |  cLogError += cValToChar( x ) + CRLF   } )
                    Help(" ",1,"CXILOAD-1",, STR0081 + CRLF + cLogError ,1,0)//"Nao Foi Possivel Criar uma Nova Linha nas Partes Envolvidas da Planilha Financeira"
        			lRet := .F.
        			Exit
      			EndIf
    	EndCase

    	If lRet
      		oModelCXI:GoLine( nIncLine )

      		For nInd := 1 To CXI->( FCount() )
      			//Proteção para o campo não usado
      			If FieldName( nInd ) <> "CXI_QUANT"
        			oModelCXI:LoadValue( CXI->( FieldName( nInd ) ), CXI->( FieldGet( nInd ) )  )
        		EndIf
      		Next nInd
      	EndIf
		CXI->( dbSkip() )
	EndDo
  	//Devolve para a posição original
	oModelCXI:SetNoUpdateLine(lCanUpdCXI)
EndIf

FwRestRows( aSaveLines )
RestArea( aCXIArea )
RestArea( aArea )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121CNKIt()
Carrega pasta de Documentos do Contrato

@author Paulo V Beraldo
@since 20/08/2015
@version P12
@return .T.
/*/
//--------------------------------------------------------------------
Function Cn121CNKIt( oModel, oModelCNK )
Local lRet       := .T.
Local nCount     := 0
Local nLinAtu    := 0
Local nIncLine   := 0
Local nInd       := 0
Local aArea      := GetArea()
Local aCNKArea   := CNK->( GetArea() )
Local cLogError  := ""
Local aSaveLines := FWSaveRows()
Local cContrat   := oModel:GetModel( 'CXNDETAIL' ):GetValue( 'CXN_CONTRA' )

dbSelectArea( 'CNK' )
CNK->( dbSetOrder( 3 ) ) //CNK_FILIAL, CNK_CONTRA, CNK_TPDOC

CNTA300BlMd( oModelCNK ,.F.)
MtBCMod( oModel,{ 'CNKDETAIL' },{||.F.},'1' )

If !CNK->( dbSeek( FwXFilial( 'CNK' ) + cContrat  ) )
  lRet := .F.
Else
  While CNK->( !Eof() ) .And. CNK->CNK_FILIAL == FwXFilial( 'CNK' ) .And. CNK->CNK_CONTRA == cContrat
    nCount ++
    nLinAtu := MtFindMvc( oModelCNK,{ { 'CNK_CONTRA', CNK->CNK_CONTRA }, { 'CNK_CODIGO', CNK->CNK_CODIGO } } )

    If nLinAtu > 0
      nIncLine := nLinAtu
    Else
      Do Case
      Case ( nCount == 1 ) .And. ( nCount == oModelCNK:nLine )
        nIncLine := nCount
      Case ( nCount > 1 )
        nIncLine := oModelCNK:AddLine()
        If nCount # nIncLine
          AEval( oModel:GetErrorMessage(), { | x |  cLogError += cValToChar( x ) + CRLF   } )
          Help(" ",1,"CNKLOAD",, STR0082 + CRLF + cLogError ,1,0)//"Nao Foi Possivel Criar uma Nova Linha para a Inclusao dos Documentos"
          lRet := .F.
          Exit
        EndIf
      EndCase
    EndIf

    If lRet
      oModelCNK:GoLine( nIncLine )
      For nInd := 1 To CNK->( FCount() )
        oModelCNK:LoadValue( CNK->( FieldName( nInd ) ), CNK->( FieldGet( nInd ) )  )
      Next nInd
    EndIf

    CNK->( dbSkip() )
  EndDo
EndIf

CNTA300BlMd( oModelCNK ,.T.)
FwRestRows( aSaveLines )
RestArea( aCNKArea )
RestArea( aArea )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121CNZIt()
Carrega Pasta do Rateio de Itens do Contrato

@author Paulo V Beraldo
@since 21/08/2015
@version P12
@return .T.
/*/
//--------------------------------------------------------------------
Function CN121CNZIt( oModel, oModelCNZ  )
Local aAreas      := {CNZ->(GetArea()), GetArea()}
Local lRet       := .T.
Local nCount     := 0
Local nIncLine   := 0
Local nInd       := 0
Local nYnd       := 0
Local nCpoVal    := 0
Local nPosCpo    := 0
Local cLogError  := ""
Local aCpoValor  := {'CNZ_VALOR1', 'CNZ_VALOR2', 'CNZ_VALOR3', 'CNZ_VALOR4', 'CNZ_VALOR5' }
Local aSaveLines := FWSaveRows()
Local oModelCNE  := oModel:GetModel( 'CNEDETAIL' )
Local cContrat   := oModelCNE:GetValue( 'CNE_CONTRA' )
Local cFilCtr	 := oModel:GetValue('CNDMASTER', 'CND_FILCTR')
Local cRevisa    := oModelCNE:GetValue( 'CNE_REVISA' )
Local cNumero    := oModelCNE:GetValue( 'CNE_NUMERO' )
Local cItemCt    := oModelCNE:GetValue( 'CNE_ITEM' )
Local cNumMed    := Space(Len(CNZ->CNZ_NUMMED))//Deve buscar os rateios do contrato(cujo campo CNZ_NUMMED estará em branco).
Local cChave	 := ""
Local cCampo	 := ""
Local cCNZFil	 := xFilial("CNZ")

CNZ->( dbSetOrder( 5 ) ) //CNZ_FILIAL+CNZ_CONTRA+CNZ_REVISA+CNZ_NUMMED+CNZ_CODPLA+CNZ_ITCONT+CNZ_ITEM
cChave := FwXFilial( 'CNZ', cFilCtr ) + cContrat + cRevisa + cNumMed + cNumero + cItemCt

If !CNZ->( dbSeek( cChave ) )
  lRet := .F.
Else
  While CNZ->( !Eof() .And. (CNZ_FILIAL + CNZ_CONTRA + CNZ_REVISA + CNZ_NUMMED + CNZ_CODPLA + CNZ_ITCONT) == cChave) 
    nCount ++
    Do Case
    Case ( nCount == 1 ) .And. ( nCount == oModelCNZ:nLine )
      nIncLine := nCount
    Case ( nCount > 1 )
      nIncLine := oModelCNZ:AddLine()
      If nCount # nIncLine
        AEval( oModel:GetErrorMessage(), { | x | cLogError += cValToChar( x ) + CRLF } )
        Help(" ",1,"CNZLOAD",, STR0083 + CRLF + cLogError ,1,0)//"Nao Foi Possivel Criar uma Nova Linha para Incluir os Itens do Rateio "
        lRet := .F.
        Exit
      EndIf
    EndCase

    If lRet
      oModelCNZ:GoLine( nIncLine )
      For nInd := 1 To CNZ->( FCount() )
		cCampo	:= CNZ->( FieldName( nInd ) )

        If (nPosCpo := Ascan( aCpoValor, cCampo )) > 0
          For nYnd := 1 To oModelCNE:Length()
            oModelCNE:GoLine( nYnd )
            If !( oModelCNE:GetValue( 'CNE_NUMERO' ) == CNZ->CNZ_CODPLA .And. oModelCNE:GetValue( 'CNE_ITEM' ) == CNZ->CNZ_ITCONT )
              Loop
            Else
              If CNZ->( FieldGet( nInd ) ) > 0
                nCpoVal := Round( ( oModelCNE:GetValue( 'CNE_VLTOT' ) * CNZ->CNZ_PERC ) / 100, TamSx3( aCpoValor[ nPosCpo ] )[ 2 ] )
                oModelCNZ:LoadValue( cCampo, xMoeda(nCpoVal,1,nPosCpo,dDatabase)  )
              EndIf
            EndIf
          Next nYnd
        ElseIf(cCampo == "CNZ_FILIAL")
			oModelCNZ:LoadValue( cCampo, cCNZFil )
        ElseIf(cCampo == "CNZ_PERC")
			oModelCNZ:SetValue( cCampo, CNZ->CNZ_PERC  ) //Necessario p/ ativar gatilho do CNZ_PERC
        ElseIf(cCampo == "CNZ_NUMMED")
	        oModelCNZ:SetValue( cCampo, oModel:GetModel( 'CNDMASTER' ):GetValue( 'CND_NUMMED' ) )
		Else
          oModelCNZ:LoadValue( cCampo, CNZ->( FieldGet( nInd ) )  )
        EndIf

      Next nInd
    EndIf

    CNZ->( dbSkip() )
  EndDo
EndIf

FwRestRows(aSaveLines)
FwFreeArray(aSaveLines)
aEval(aAreas, {|x| RestArea(x) })
FwFreeArray(aAreas)
Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121vlMul()
Processa a fórmula da multa, retornando o valor

@author jose.eulalio
@since 29/07/2015
@version P12
@return .T.
/*/
//--------------------------------------------------------------------
Function Cn121vlMul()
Local nValor	  := 0
Local lFormula := .F.

If Empty( CN4->CN4_VLDALT )
	lFormula := Formula( CN4->CN4_VALID )
Else
	lFormula := CNTA130Form( CN4->CN4_VLDALT )
	lFormula := IIf( !( ValType( lFormula ) == 'L' ) , .F. ,lFormula )
EndIf

If lFormula
	//Obtem o valor da multa
	If Empty( CN4->CN4_VLRALT )
		nValor := Formula( CN4->CN4_FORMUL )
	Else
		nValor := CNTA130Form( CN4->CN4_VLRALT)
		nValor := IIf( !( ValType( nValor ) == 'N' ), 0, nValor )
	EndIf
EndIf

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121Act()
Pós-Ativação do modelo

@author jose.eulalio
@since 04/08/2015
@version P12
@return lRet
/*/
//--------------------------------------------------------------------
Function CN121Act(oModel)
	Local oModelCND	:= oModel:GetModel("CNDMASTER")
	Local oModelCNE	:= oModel:GetModel("CNEDETAIL")
	Local oModelCXN	:= oModel:GetModel("CXNDETAIL")	
	Local lAltera	:= oModel:GetOperation() == MODEL_OPERATION_UPDATE
	Local lRet 		:= .T.
	Local nX		:= 0
	Local cIdPD		:= ""

	aComp 	:= {}//Limpar variavel estatica <aComp> na ativacao.

	If IsExced()
		CfgCNEExced(oModelCNE)//Configura modelo da CNE p/ medicoes excedentes		
	EndIf

	SetObgFlds(oModel, .F.)//Desativa a obrigatoriedade de preencher os campos marcados como "obrigatório" no dicionário
	SetWhenOri(oModel, .T.)//Faz o cache de WHEN original	

	If lAltera

		If (CND->(AllTrim(CND_SERVIC) == "2"))
			CN121MdServ(.T., .T.)
		EndIf

		If !lExcedMEnc		
			CN121ChgPl()//- Bloqueia modelo de Itens pelo tipo da planilha
		Else
			//Libera modelo
			oModelCNE:SetNoDeleteLine(.T.)
			oModelCNE:SetNoUpdateLine(.T.)
			oModelCNE:SetNoInsertLine(.F.)			

			For nX := 1 To oModelCXN:Length()
				oModelCXN:Goline(nX)

				If oModelCXN:GetValue("CXN_CHECK")					
					oModelCNE:Goline(oModelCNE:Length()) //Ultima linha
					cIdPD := oModelCNE:GetValue("CNE_IDPED")
					cIdPD := SOMA1(cIdPD)					
					
					//Adiciona uma nova linha
					oModelCNE:AddLine()
					oModelCNE:SetNoDeleteLine(.T.)
					oModelCNE:SetNoUpdateLine(.F.)

					If oModelCNE:IsInserted()
						oModelCNE:LoadValue("CNE_IDPED", cIdPD)
						CN121ChgPl()//Habilita edição de campos
						Exit
					EndIf
				Endif
			Next nX
			oModelCNE:GoLine(1)
		EndIf
	Else
		CNTA300BlMd( oModel:GetModel('CXODETAIL') , .T. )
		CNTA300BlMd( oModel:GetModel('CXPDETAIL') , .T. )
	EndIf

	If Empty(oModelCND:GetValue("CND_FILCTR"))
		cFilCTR := cFilAnt
	Else
		cFilCTR := oModelCND:GetValue("CND_FILCTR")
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121VldChk()
Valid do Check box da CXN // CNA
@author jose.eulalio
@since 04/08/2015
@version P12
@return lRet
/*/
//--------------------------------------------------------------------
Function Cn121VldChk(oModelCXN,cField,xValue,nLine,xOldValue)
Local lRet		:= .T.
Local aAreas    := {CND->( GetArea() ), CXN->( GetArea() ), CNA->( GetArea() ), GetArea()}
Local aError    := {}
Local oModel	:= oModelCXN:GetModel()
Local oModelCNE	:= oModel:GetModel('CNEDETAIL')
Local oModelCND	:= oModel:GetModel('CNDMASTER')
Local oModelCNR1:= oModel:GetModel('CNRDETAIL1')
Local oModelCNR2:= oModel:GetModel('CNRDETAIL2')
Local oModelCXO := oModel:GetModel('CXODETAIL')
Local oModelCNZ	:= oModel:GetModel('CNZDETAIL')
Local cFilCtr	:= oModelCND:GetValue("CND_FILCTR")
Local cFilCXN	:= xFilial("CXN")
Local cFilCND	:= xFilial("CND")
Local cFilCNA	:= xFilial("CNA", cFilCtr)
Local cCompet	:= ''
Local cNumPla 	:= oModelCXN:GetValue("CXN_NUMPLA")
Local cRevisa   := oModelCND:GetValue("CND_REVISA")
Local cContra   := oModelCND:GetValue("CND_CONTRA")
Local cChave	:= cFilCXN + cContra + cRevisa + cNumPla
Local cCNDCompe := ""
Local cNumMed   := ""
Local lServico	:= .F.
Local lRecorre	:= .F.
Local lEventual	:= .F.
Local lSemifixo	:= .F.
Local lSemiProd	:= .F.
Local lFixo		:= .F.
Local lCancelChk:= .F.
Local lHasError := .F.
Local aProp		:= {}
Local bTrueWhen	:= Nil

dbSelectArea( 'CND' )
CND->( dbSetOrder( 4 ) ) //CND_FILIAL+CND_NUMMED

dbSelectArea( 'CXN' )
CXN->( dbSetOrder( 2 ) ) //CXN_FILIAL+CXN_CONTRA+CXN_REVISA+CXN_NUMPLA

CursorWait()
//-----------------------------------------------
// Verifica se a planilha esta sendo utilizada em outra medição
// Contratos Recorrentes e Eventuais permitem ter mais de uma medição na mesma competência
//------------------------------------------------
If xValue
	CNTA300BlMd(oModel:GetModel("CZYDETAIL"),, .T.)
	If CN121MdServ()
		If (Empty(oModelCXN:GetValue("CXN_CRONOG")))
			lRet := (CnTpProd("CNTA121", cNumPla, cContra, cRevisa,/*nLinha*/, cFilCtr) == 2)
			If !lRet
				Help(" ",1,"CXNTPPRODSRV",,STR0219,1,0)//É necessário que todos os produtos sejam do tipo Serviço. Verifique os produtos da planilha.
			EndIf
		Else
			lRet := !(CN121RetSt("FISICO"	, 0, cNumPla, cContra ))
			If !lRet
				Help(" ",1,"CXNCHECKSRV",,STR0218,1,0)//"Somente é possível incluir Medições de Serviços para contratos do Tipo Fixo e Cronograma Financeiro"
			EndIf
		EndIf
	EndIf

	If lRet		
		If lAltera .And. (oModelCNE:IsModified() .Or. oModelCNR1:IsModified()) //-- Realiza undelete da CNE, CNR1 e CNR2
			If oModelCNE:IsModified()
				CNTA300BlMd(oModelCNE,.F.,.F.)
				CNTA300DlMd(oModelCNE,"CNE_NUMERO",.F.)
				CNTA300BlMd(oModelCNE,.T.,.T.)

				CNTA300BlMd(oModelCNR2,.F.,.F.) //-- Libera o modelo da CNR2
				CNTA300DlMd(oModelCNR2,"CNR_TIPO",.F.)
			EndIf

			If oModelCNR1:IsModified()
				CNTA300BlMd(oModelCNR1,.F.,.F.) //-- Libera o modelo da CNR1
				CNTA300DlMd(oModelCNR1,"CNR_TIPO",.F.)
			EndIf
			LoadAdiants(oModel) // Ao selecionar novamente o check box, retorna os valores do adiantamento.
			CNTA300BlMd(oModelCXO,.F.,.F.)
			CNTA300DlMd(oModelCXO,"CXO_ITEM",.F.)
			CNTA300BlMd(oModelCXO,.T.,.T.)
		Else

			cCNDCompe := AllTrim( oModelCND:GetValue("CND_COMPET") )

			lServico	:= CN121RetSt("SERVIÇO"		, 0, cNumPla, cContra )
			lRecorre	:= CN121RetSt("RECORRENTE"	, 0, cNumPla, cContra )
			lEventual	:= CN121RetSt("MEDEVE"		, 0, cNumPla, cContra )
			lSemifixo	:= CN121RetSt("SEMIFIXO"	, 0, cNumPla, cContra )
			lSemiProd	:= Cn121RetSt("SEMIPROD"	, 0, cNumPla, cContra )
			lFixo		:= Cn121RetSt("FIXO"	    , 0, cNumPla, cContra )
			
			If !lRecorre .And. !lEventual //Medicoes eventuais permitir na mesma competencia.
				cNumMed := oModelCND:GetValue("CND_NUMMED")
				
				CXN->( MsSeek( cChave ) )
				While cChave == cFilCXN + CXN->(CXN_CONTRA + CXN_REVISA + CXN_NUMPLA) .And. !(CXN->(Eof())) .And. lRet
					If cNumMed # CXN->CXN_NUMMED
						If CND->( MsSeek( cFilCND + CXN->CXN_NUMMED ) )
							If cCNDCompe == AllTrim( CND->CND_COMPET ) .And. oModelCXN:GetValue("CXN_PARCEL") == CXN->CXN_PARCEL .And. CXN->CXN_CHECK
								If lServico
									Help(" ",1,"CXNCHECKMED",,STR0154,1,0)//- "Não é possível realizar medições complementares em parcelas já realizadas para planilha de serviços."
									lRet := .F.
									Exit
								ElseIf !Alltrim(CND->CND_SITUAC) $ "E|FE" .And. (CXN->CXN_VLPREV - CXN->CXN_VLLIQD <= 0)
									Help(" ",1,"CXNCHECKMED",,STR0084,1,0)//"A planilha selecionada se encontra em uso por outra medição na mesma competencia."
									lRet := .F.
									Exit
								EndIf
							EndIf
						EndIf
					EndIf
					CXN->(DbSkip())
				EndDo
			
			ElseIf lRecorre
				
				cChave := cFilCNA + cContra + cRevisa + cNumPla
				dProMed := Posicione("CNA",1,cChave,"CNA_PROMED")
				cProMed := StrZero( Month( dProMed ), 2 ) + "/" + CValToChar( Year( dProMed ) )
				
				cCompet := cCNDCompe
						
				If AllTrim( cProMed ) <> cCompet
					Help("CXNPROMED",1,"CXNPROMED",, STR0085 + cProMed,1,1)//"Para marcar a planilha recorrente é necessário mudar a competência para "
					lRet := .F.
				Endif
				
			ElseIf lSemifixo
			
				If oModelCXN:GetValue("CXN_VLSALD") == 0
					Help(" ",1,"CXNSLDMED")
					lRet := .F.
				EndIf
				
			EndIf
			
			// Efetua Carga e Atualiza totalizadores
			If lRet
				aProp 	:= GetPropMdl(oModelCXN)								
				CNTA300BlMd(oModelCXN,,.T.)//Libera p/ atualizacao
				CNTA300BlMd(oModelCNE,.F.)//Libera p/ preenchimento dos dados na carga
				bTrueWhen := FwBuildFeature( STRUCT_FEATURE_WHEN, ".T.")
				oModelCXN:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,bTrueWhen)
				oModelCNE:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,bTrueWhen)
				oModelCNZ:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,bTrueWhen)
				SetObgFlds(oModel, .F.)

				oModelCNE:GoLine(1)
				If Empty(oModelCNE:GetValue("CNE_NUMERO"))
					If CN121Item( xValue,, oModel, cNumPla, cContra ) //Caso o usuário cancelar a operação ou não exista itens válidos a planilha é desmarcada
						CN121Agrup(oModel)
						CN121CXIIt(oModel)
						LoadAdiants(oModel) // Efetua a carga do adiantamento
						If CnGatMNat()
							CnCrgMNat(oModel)
						EndIf

						CN121ChgPl(.T.,oModel)
		
					Else
						lCancelChk := .T.
						lRet := .F.
					EndIf
				EndIf
				CN121CNRPl(oModel,oModelCXN)

				RstPropMdl(oModelCXN, aProp)
				FwFreeArray(aProp)

				SetWhenOri(oModel)//Restaura WHEN original
			EndIf
		EndIf
	EndIf
EndIf

If !xValue .And. xOldValue .Or. lCancelChk //--Caso a planilha seja desmarcada devo limpar os itens
    
    If lHasError := oModel:HasErrorMessage() //-- Faz backup da mensagem de erro
        aError := oModel:GetErrorMessage()
    EndIf

	CNTA300BlMd(oModelCNE,.F.,.F.)
    
	
	CNTA300BlMd(oModel:GetModel("CZYDETAIL"),.F.)
	CNTA300BlMd(oModel:GetModel("CXODETAIL"),.F.)
	
	CNTA300DlMd(oModelCNR1					,"CNR_TIPO"		,lCancelChk)
	CNTA300DlMd(oModelCNR2					,"CNR_TIPO"		,lCancelChk)
	CNTA300DlMd(oModelCNE					,"CNE_NUMERO"	,lCancelChk)
	CNTA300DlMd(oModel:GetModel("CZYDETAIL"),"CZY_VALOR"	,lCancelChk)
	CNTA300DlMd(oModel:GetModel("CXODETAIL"),"CXO_ITEM"     ,lCancelChk)
	CNTA300BlMd(oModelCNE,.T.,.T.)    
	CNTA300BlMd(oModel:GetModel("CZYDETAIL"),.T.)
	CNTA300BlMd(oModel:GetModel("CXODETAIL"),.T.)

    If lHasError //-- Restaura mensagem de erro
        oModel:SetErrorMessage(,,,,aError[5],aError[6],aError[7])
    EndIf
EndIf

CursorArrow()

aEval(aAreas, {|x| RestArea(x) })
FwFreeArray(aAreas)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121Limpa()
Limpa variaveis estáticas antes do final da função.
@author israel.escorizza
@since 11/08/2015
@version P12
@return .T.
/*/
//--------------------------------------------------------------------
Function CN121Limpa(lFreeModel)
	Local oModel := FwModelActive()
	Default lFreeModel:= .T.
	
	lServico := .F.
	Cn121GAutF(.F., .T.)
	cEncMsg := "" //Limpa mensagem
	
	If lFreeModel
		IIf( ValType( oModel ) == 'O' .And. oModel:IsActive() .And. oModel:GetId() == "CNTA121", oModel:Deactivate(), Nil )
	EndIf

	If (ValType(_oPosCpos) == 'J')
		FreeObj(_oPosCpos)
	EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121Compet
Funcao que carrega grid das planilhas após selecionar competência
@author Rogerio Melonio
@since 11/08/2015
/*/
//-------------------------------------------------------------------
Function CN121Compet()
Local oModel	:= FWModelActive()
Local cCompet	:= oModel:GetValue("CNDMASTER","CND_RCCOMP")

If( Type("nTipo")=="N", Nil, nTipo := 1)
If( Type("lExced")=="L", Nil, lExced := lExcedNPrv)
If( Type("cValue")=="C", Nil, cValue := "")

If(Type("cFilCTR") != "C")	
	If(Empty(oModel:GetValue("CNDMASTER","CND_FILCTR")))		
		cFilCTR := cFilAnt
	Else
		cFilCTR := oModel:GetValue("CNDMASTER","CND_FILCTR")
	EndIf
EndIf

If !IsInCallStack("CN121CBOX")
	CN120Compet(lExced,cFilCTR)
Endif
Return cCompet

//------------------------------------------------------------------
/*/{Protheus.doc} CN121TudOk()
Tudo Ok do Modelo
@author jose.eulalio
@since 14/08/2015
@version P12
@return .T.
/*/
//--------------------------------------------------------------------
Function Cn121TudOk(oModel)
Local aAreas	 := {CN9->(GetArea()), GetArea()}
Local cChave	 := ""
Local lRet       := .T.
Local oModelCND  := oModel:GetModel("CNDMASTER")
Local oModelCXN  := oModel:GetModel("CXNDETAIL")
Local oModelCNE  := oModel:GetModel("CNEDETAIL")
Local oModelCNQ  := oModel:GetModel("CNQDETAIL")
Local oModelCZY  := oModel:GetModel("CZYDETAIL")
Local oModelTOT  := oModel:GetModel('TOTMED')
Local oModelCXO  := Nil
Local oModelCXP  := Nil
Local lVenda     := CN121RetSt("VENDA",,,oModelCXN:GetValue("CXN_CONTRA"),.T.,oModel)
Local lInclui    := oModel:GetOperation() == MODEL_OPERATION_INSERT
Local lAltera    := oModel:GetOperation() == MODEL_OPERATION_UPDATE
Local lExclui    := oModel:GetOperation() == MODEL_OPERATION_DELETE
Local lNotaEmp   := SuperGetMV("MV_NOTAEMP",.F.,.F.)
Local lCNEIsVld  := .T.
Local lNoTes     := .T.
Local lNoDtEnt	 := .F.
Local nI         := 0
Local nX         := 0
Local nY         := 0
Local nTotPla    := 0
Local nTotOri	 := 0
Local nTotDesc	 := 0
Local lMark      := .F.
Local aSaveLines := FWSaveRows()
Local lSemiFix   := Cn121RetSt( "SEMIFIXO",,,, .T., oModel )
Local cContra	 := oModelCXN:GetValue("CXN_CONTRA")
Local cPlan		 := ""
Local cFilCtr	 := oModelCND:GetValue("CND_FILCTR")
Local nMoedaCtr	 := CN121RetSt("MOEDACTR",0,, cContra,.F.,Nil, cFilCtr)
Local lServico	 := .F.
Local lMedZerada := (CXN->( Columnpos('CXN_ZERO') ) > 0 .And. SuperGetMV("MV_CNNOPED",.F.,.T.))
Local lVldEvent	:= .F.
Local lFixo 	:= .F.
Local lPrevFin 	:= .F.
Local lFlexPrev := .F.
Local lVldTP9   := .F.
Local nVlLimit	:= 0
Local nTotItem  := 0
Local nPDesc    := 0
Local lMultiMed := CN121RetSt("MULTIMED",0,, cContra,.F.,Nil, cFilCtr)
Local lCondTp9	:= .F.
Local nTamDesc	:= GetSx3Cache("CNE_VLDESC"	,"X3_DECIMAL")
Local nDecVlTot	:= GetSx3Cache("CNE_VLTOT"	,"X3_DECIMAL")
Local nDecSldCXN:= GetSx3Cache("CXN_VLSALD"	,"X3_DECIMAL")
Local aVldAdiant:= {}
Local lSemProdut:= .F.
Local nDifTotLim:= 0
Local nDif		:= 0
Local nVlUnit	:= 0
Local lLimitPlan:= .F.
Local lTotValido:= .T.
Local nDecPerc	:= GetSx3Cache("CNE_PERC","X3_DECIMAL")
Local nPercent	:= 0
Local nQuantCNE := 0
Local nCalcPerc := 0
Local aPropCNE	:= {}

If !lExclui
	//-Carrega os Totalizadores no modelo da CND	
	oModelCND:LoadValue('CND_VLPREV',oModelTOT:GetValue('CND_VLPREV'))
	oModelCND:LoadValue('CND_VLLIQD',oModelTOT:GetValue('CND_VLLIQD'))
	oModelCND:LoadValue('CND_VLMULT',oModelTOT:GetValue('CND_VLMULT'))
	oModelCND:LoadValue('CND_VLBONI',oModelTOT:GetValue('CND_VLBONI'))
    
    If CND->(FieldPos("CND_VLMPED")) > 0 .And. CND->(FieldPos("CND_VLBPED")) > 0
        oModelCND:LoadValue('CND_VLMPED', oModelTOT:GetValue('CND_VLMPED'))
        oModelCND:LoadValue('CND_VLBPED', oModelTOT:GetValue('CND_VLBPED'))
    EndIf
	
    oModelCND:LoadValue('CND_DESCME',oModelTOT:GetValue('CND_DESCME'))
	oModelCND:LoadValue('CND_TOTADT',oModelTOT:GetValue('CND_TOTADT'))
	oModelCND:LoadValue('CND_RETCAC',oModelTOT:GetValue('CND_RETCAC'))
	oModelCND:LoadValue('CND_VLTOT',oModelTOT:GetValue('CND_VLTOT'))

	//-- Preenche valor liquido dos itens
	If oModelCNE:HasField('CNE_VLLIQD') .And. (lInclui .Or. lAltera) .And. !lEncerra
		Cn121Liq(oModel)
	EndIf

	lCondTp9 := (Posicione('SE4',1,xFilial('SE4')+ oModelCND:GetValue("CND_CONDPG"), 'E4_TIPO') == '9')

	SetObgFlds(oModel, .T.)//Ativa a obrigatoriedade de preencher os campos marcados como "obrigatório" no dicionário
EndIf

If Cn121GAutF() .And. ((lExclui .Or. lAltera) .And. !lEncerra)
	lRet := VlExcPCAut(oModel)//Valida exclusão do PC da Autorização de Fornecimento
EndIf

//-- Validacao de pontos de bloqueio do SIGAPCO
If lRet
	lRet := CN121PCOBQ( oModel )
EndIf

If lRet .And. !lExclui
	oModelCXO	:= oModel:GetModel("CXODETAIL")
	oModelCXP	:= oModel:GetModel("CXPDETAIL")
	lRet := CnMNPosMd(oModelCXN,oModelCXO,oModelCXP)
EndIf

 If (lRet .And. !lExclui .And. lVenda .And. lCondTp9 .And. !lEncerra) .And. !CXNParcTp9()
 	lRet := cn130VldCnd9(oModel)
 EndIf

If FwIsInCallStack('CN121Encerr')
	SetExcedNP(GCTExcedNP(CND->CND_NUMMED))
EndIf

If !IsExced()
	If lRet .And. !lExclui
		For nX := 1 To oModelCXN:Length()
			nTotPla := 0
			nTotDesc:= 0
			oModelCXN:GoLine(nX)
			If oModelCXN:GetValue("CXN_CHECK") .AND. !oModelCXN:IsDeleted()
				cPlan 		:= oModelCXN:GetValue("CXN_NUMPLA")
				lServico 	:= CN121RetSt("SERVIÇO"		,0,	cPlan, cContra)			
				lEventual	:= CN121RetSt("EVENTUAL"	,0,	cPlan, cContra)
				lFixo		:= CN121RetSt("FIXO"		,0,	cPlan, cContra)
				lPrevFin	:= CN121RetSt("PREVFINANC"	,0,	cPlan, cContra)
				lLimitPlan 	:= CN121RetSt("LMTMED"		,0, cPlan, cContra) > 0 // Verifica se a planilha possui Limite medição
				lFlexPrev 	:= lEventual .And. !lFixo .And. lPrevFin //Flexível com previsão financeira

				GetAdtPlan(oModelCZY, @aVldAdiant) /*Atualiza a variável de adiantamentos por planilha*/
				For nY := 1 To oModelCNE:Length()
					oModelCNE:GoLine(nY)
					If  !oModelCNE:IsDeleted() .And. oModelCNE:GetValue("CNE_VLTOT") > 0
						If Empty(oModelCNE:GetValue("CNE_PRODUT")) .And. oModelCNE:GetValue("CNE_PEDTIT") == '1'
							lRet		:= .F.
							lSemProdut	:= .T.
							Exit
						EndIf

						nTotPla += Round(oModelCNE:GetValue("CNE_VLTOT"),nDecVlTot)
						
						If ( lVenda .And. oModelCNE:GetValue("CNE_PEDTIT") == '1' .And. Empty(oModelCNE:GetValue("CNE_TES")) .And. oModelCNE:GetValue("CNE_VLTOT") > 0)
							lRet := .F.
							lNoTes := .F.							
							Exit
						EndIf

						If !lVenda .And. Empty(oModelCNE:GetValue("CNE_DTENT"))
							lRet := .F.
							lNoDtEnt := .T.
							Exit
						EndIf

						If !oModelCNE:VldLineData()
							lRet := .F.
							lCNEIsVld := .F.
							Exit
						EndIf
						
						nTotItem	:= oModelCNE:GetValue("CNE_VLTOT")
						
						If lVenda
							nPDesc 	:= CtrValDesc("2",;
												nTotPla,;
												oModelCNE:GetValue("CNE_PDESC"),;
												oModelCNE:GetValue("CNE_VLUNIT"),;
												oModelCNE:GetValue("CNE_QUANT") )
						Else
							nPDesc := CNEVLDesc(nTotPla, oModelCNE:GetValue("CNE_PDESC") )
						Endif

						If (Round(nPDesc, nTamDesc) >= nTotItem)
							nPDesc := NoRound(nPDesc, nTamDesc)
						Else
							nPDesc := Round(nPDesc, nTamDesc)
						EndIf

						nTotPla 	-= nPDesc

						nPercent	:= oModelCNE:GetValue("CNE_PERC")
						nQuantCNE	:= oModelCNE:GetValue("CNE_QUANT")
						nCalcPerc	:= NoRound(nQuantCNE / oModelCNE:GetValue("CNE_QTDSOL") * 100, nDecPerc )

						If nPercent > 100 // Caso valor percentual esteja preenchido de maneira errada, atualiza o mesmo
							oModelCNE:LoadValue("CNE_PERC",nCalcPerc)
						EndIf
					Endif
				Next nY
				
				nTotPla := Round(nTotPla, nDecSldCXN)
				lVldEvent := lEventual .And. !lFixo .And. !lPrevFin						
				If  lRet .And. !lVldEvent .And. !lServico .And. lNoTes 
					//Valida se o total informado nos itens ultrapassa o valor previsto para a medição, considerando o percentual de limite para medição, definido no tipo de contrato/planilha 								
					If !lFlexPrev	
						nVlLimit := Min(Cn121LtMed( oModelCXN ),oModelCXN:GetValue("CXN_VLSALD"))
					Else
						nVlLimit := oModelCXN:GetValue("CXN_VLSALD")
					EndIf
					nVlLimit := xMoeda(nVlLimit, nMoedaCtr, oModelCND:GetValue("CND_MOEDA"), oModelCND:GetValue("CND_DTINIC"), nDecSldCXN)
					
					If !lLimitPlan // Se não tiver limite
						nDifTotLim := Round(nTotPla-nVlLimit,nDecVlTot)
						If lTotValido := nDifTotLim == 0.01

							oModelCNE:GoLine(oModelCNE:Length())

							nDif := nDifTotLim
							nDif /= NoRound(oModelCNE:GetValue("CNE_QUANT"),nDecVlTot)
							nVlUnit := oModelCNE:GetValue("CNE_VLUNIT") -nDif
							
							aPropCNE := GetPropMdl(oModelCNE)
							CNTA300BlMd(oModelCNE,,.T.)							
							
							CNNoWhenSet(oModelCNE, "CNE_VLUNIT", nVlUnit)
							
							RstPropMdl(oModelCNE, aPropCNE)
							FwFreeArray(aPropCNE)
						Else
							lTotValido := !(nDifTotLim > 0.01)
						EndIf
					Else
						lTotValido:= !nTotPla > nVlLimit	
					EndIf

					If !(lRet := lTotValido)
						oModel:SetErrorMessage( "CNEDETAIL", "CNE_VLTOT", "CNEDETAIL", "CNE_VLTOT", "CNEVLTOT3", STR0186 + cValToChar(nTotPla) + STR0188 + cValToChar(nVlLimit) + "."  ) //"A soma dos valores informados para os itens ultrapassa o limite previsto para essa medição. Total informado: " ## ". Limite da medição: "
					EndIf
				EndIf

				If  (lVenda .And. lCondTp9 .And. !lEncerra) .And. CXNParcTp9()
					lRet := cn130VldCnd9(oModel,"CXN")
					If !lRet
						lVldTP9:= .T.
					EndIf
				EndIf

                If !lRet
                    Exit
                EndIf

				For nY := 1 To oModelCNQ:Length()
					oModelCNQ:GoLine(nY)
					If (!oModelCNQ:IsDeleted())
						nTotDesc += oModelCNQ:GetValue('CNQ_VALOR')
					EndIf
				Next nY
				nTotOri := nTotPla //Guarda valor original
				nTotPla -= nTotDesc//Subtrai o valor dos descontos
					
				If lMedZerada //- Valida inclusão de medição para valores zerados com campo CXN_ZERO (Med. Zerada)
					
					If(oModelCXN:GetValue("CXN_ZERO") != "1")
						lRet := (nTotPla > 0)
					EndIf
					
					If(!lRet)
						Exit
					EndIf
				ElseIf nTotPla <= 0					
					lRet := .F.					
					Exit					
				EndIf
			EndIf
		Next nX

		If !lRet
            If (!lCNEIsVld .Or. !lTotValido)
                Help(" ",1,AllTrim(oModel:GetErrorMessage()[MODEL_MSGERR_ID]),,oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE]+CRLF,1,1)// Mensagem de erro gerada pela validação da CNE 
			ElseIf lVenda .And. !lNoTes
				Help("",1,'SEMTESITEM',,STR0189,1,1)//"O código do TES não foi informado. Informar o Tipo de Saída no item."
			ElseIf lSemiFix
				Help("",1,'SEMIFQTD',,STR0087,1,1) 	//- "Preencha a quantidade para a planilha Semi-fixa para poder realizar a gravação!"
			ElseIf !lVenda .And. lNoDtEnt
				Help(" ",1,"CN121NODTENT",,STR0207, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0208}) //Existe item da(s) planilha(s) selecionada(s) sem a data de entrega informada.
			ElseIf(!Empty(nTotDesc) .And. nTotDesc >= nTotOri)
				Help("",1,"CN121VLZERO",,STR0197,1 , 0, NIL, NIL, NIL, NIL, NIL, {STR0198})	// Não é permitido a inclusão de medição com valor zerado. Verifique os valores informados na aba descontos.
			ElseIf lSemProdut
				Help(" ",1,"CN121NOPRODUT",,STR0233, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0234}) // Erro na medição. Medições programadas para gerar pedido/nota devem obrigatoriamente ter um produto informado. 
			ElseIf !lVldTP9
				Help("",1,'CN121VLMED')	//- "Existem planilhas com quantidades invalidas. | Verifique a quantidade dos itens das planilhas selecionadas. Para planilhas de medição zerada, a quantidade dos itens deve ser obrigatoriamente 0 (zero)."
			EndIf
		ElseIf(Len(aVldAdiant) > 0)
			lRet := VldAdtPlan(aVldAdiant) /*Realiza a validação dos adiantamentos p/ planilha*/
			If lRet .And. (oModelTOT:GetValue("CND_TOTADT") > oModelTOT:GetValue("CND_VLLIQD"))
				Help("",1,"CN121TOTADT",,STR0226,1 , 0, NIL, NIL, NIL, NIL, NIL, {STR0227})//Valor dos adiantamentos superior ao total da medição
				lRet := .F.
			EndIf
		EndIf
		nI := 1	
		While lRet .And. nI <= oModelCXN:Length()
			oModelCXN:GoLine(nI)
			lMark := lMark .Or. oModelCXN:GetValue('CXN_CHECK')							
			lRet := CN121LimPla(oModel) .And. CN121VldRt(oModelCNE)
			cPlan := oModelCXN:GetValue("CXN_NUMPLA")
			lServico := CN121RetSt( "SERVIÇO", 0, cPlan, cContra, .F. )
			If lRet .And. lServico
				lRet := CN121VlUnt(,,,,.T.)
			EndIf
			nI++
		EndDo
		If lRet .And. !lMark
			lRet := .F.
			Help("",1,"CN121NOPL") //- "Não foram selecionadas planilhas para realizar a medição.|Selecione uma planilha"
		EndIf
	ElseIf(lRet .And. lExclui .And. lMultiMed)		
		CNA->(DbSetOrder(1))//CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO
		cChave := xFilial("CNA", oModelCND:GetValue("CND_FILCTR")) + oModelCND:GetValue("CND_CONTRA") + oModelCND:GetValue("CND_REVISA")		
		
		For nX := 1 To oModelCXN:Length()
			oModelCXN:GoLine(nX)
			If oModelCXN:GetValue("CXN_CHECK") .AND. !oModelCXN:IsDeleted()					
				If 	Cn121RetSt( 'RECORRENTE', 0, oModelCXN:GetValue("CXN_NUMPLA"), cContra, .T., oModel ) .And.;
					CNA->(MsSeek( cChave + oModelCXN:GetValue("CXN_NUMPLA") ))			
					
					If !Empty(CNA->CNA_PERIOD) .And. !Empty(CNA->CNA_RECMED) .And. ( CNA->CNA_RECMED <> CND->CND_NUMMED  )//- Se a medição a ser excluída não é a última, não permite exclusão
						Help(" ",1,"CN121BLQREC") // "Exclusões de medições de contratos recorrentes serão permitidas na ordem inversa da que foram incluídas, a partir da última medição.")
						lRet := .F.                        
						Exit
					EndIf
				EndIf
			EndIf
		Next nX
	EndIf	

	If lRet .And. lNotaEmp
		CN9->(dbSetOrder(1)) //-- CN9_FILIAL+CN9_NUMERO+CN9_REVISA
		cChave := xFilial("CN9", oModelCND:GetValue("CND_FILCTR")) + oModelCND:GetValue("CND_CONTRA")
		If(CN9->(dbSeek(cChave) .And. !Empty(CN9_CODED) .And. GCPSCED(CN9_CODED, CN9_NUMPR)))
			For nI := 1 To oModelCNE:Length()
				oModelCNE:GoLine(nI)
				If Empty(oModelCNE:GetValue("CNE_CODNE")) .Or. Empty(oModelCNE:GetValue("CNE_ITEMNE"))
					lRet := .F.
					Help("",1,'SEMNOTEMP ',,STR0086,1,1)//"A medição não pode ser gravada, digite o codigo ou o item da nota de empenho"
				EndIf
			Next
		EndIf
	EndIf
ElseIf (lInclui .Or. lAltera)

	For nX := 1 To oModelCXN:Length()
		oModelCXN:GoLine(nX)
		If oModelCXN:GetValue("CXN_CHECK") .AND. !oModelCXN:IsDeleted()
			For nI := oModelCNE:Length() To 1 STEP - 1
				oModelCNE:GoLine(nI)

				If (!oModelCNE:IsDeleted() .And. oModelCNE:IsInserted())					
					If Empty(oModelCNE:GetValue("CNE_TES"))
						lRet := .F.
						Help("",1,'SEMTESITEM',,STR0067,1,1)//"O código do TES não foi informado. Informar o Tipo de Saída no item"
						Exit						
					EndIf
				EndIf
			Next nI			
		EndIf
	Next nX

EndIf

FWRestRows(aSaveLines)
FwFreeArray(aSaveLines)
aEval(aAreas, {|x| RestArea(x), FwFreeArray(x)})
Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN121GRV()
Função de gravação da medição
@author alexandre.gimenez
@since 20/08/2015
/*/
//-------------------------------------------------------------------
Function CN121GRV(oModel)
Local oModelCND := oModel:GetModel('CNDMASTER')
Local oModelCXN	:= oModel:GetModel('CXNDETAIL')
Local oModelCNE	:= oModel:GetModel('CNEDETAIL')

Local cOpc		:= oModel:GetOperation()
Local nStack 	:= 0
Local nX		:= 0

Local lCompra	:= CN121RetSt("COMPRA",/**/,/**/,oModelCXN:GetValue("CXN_CONTRA"),.T.,oModel)
Local lInclui	:= cOpc == MODEL_OPERATION_INSERT
Local lAltera	:= cOpc == MODEL_OPERATION_UPDATE
Local lExclui	:= cOpc == MODEL_OPERATION_DELETE
Local lRet	 	:= .T.
Local lPeGrP	:= ExistBlock("CN121GPD")
Local lGrPed	:= .T.
Local aOkDocs	:= {}
Local cTexto	:= ""
Local lMultiMed	:= CN121RetSt("MULTIMED",0,,oModelCND:GetValue("CND_CONTRA"),.F.,Nil, oModelCND:GetValue("CND_FILCTR"))
Local nAvgMetr	:= 0 //Armazena a quantidade de itens da medição
Local oStructCXN:= Nil

cEncMsg := "" //Limpa variavel estatica

Begin Transaction

	If lMultiMed .And. !lEncerra .And. (lExclui .Or. lAltera) .And. !IsExced()
		/*Numa alteracao, o saldo consumido inicialmente será estornado, posteriormente será consumido o saldo novamente com o valor atualizado.*/
		UpdSaldos(oModelCND:GetDataID(), .T.)//Retorna saldos na exclusao.[Precisa ser chamado antes do fim da transação]		
	EndIf

	If lEncerra .Or. lExcedMEnc
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Chama ponto de entrada para verificar se gera pedido. ³
		//³Podera ser utilizado para aglutinar varias medicoes e |
		//³somente apos realizar a geracao do pedido.            |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lEncerra .And. lPeGrP
			lGrPed := ExecBlock("CN121GPD",.f.,.f.)
		EndIf
		
		If lGrPed 
			lRet := CN121GerDoc(oModel, aOkDocs)			
		EndIf
		
		If(lRet .And. !lMultiMed)
			AtuSldCXM(oModelCNE)//Atualiza o saldo de agrupadores(CXM)[Verificar de futuramente mover essa logica para CN121MedEnc]
		EndIf
	ElseIf !lExclui 
		//- Define Variaveis de Med. Serviço e Aut. Fornecimento		
		oModelCND:SetValue("CND_SERVIC"	, IIF(CN121MdServ(), '2','1'))
		oModelCND:SetValue("CND_AUTFRN"	, Iif(lAutForn,'2','1'))
		oModelCND:LoadValue("CND_FILMED", cFilAnt)//Grava a filial da medicao

		oModelCNE:SetNoInsertLine( .F. )
		oModelCNE:SetNoDeleteLine( .F. )
			
		oStructCXN := oModelCXN:GetStruct()
		aEval({"CXN_FORNEC","CXN_LJFORN","CXN_CLIENT","CXN_LJCLI"}, {|x| oStructCXN:SetProperty(x,MODEL_FIELD_WHEN,{||.T.}) })
		
		For nX := 1 to oModelCXN:Length()//- Percorre CXN relizando ações complementares antes da gravação.
			oModelCXN:GoLine(nX)
			//Grava campo fornecedor/cliente conforme tipo do contrato(grava mesmo se a planilha não estiver selecionada, pois pode sofrer alteração futura)
			oModelCXN:LoadValue(IIF(lCompra, "CXN_FORNEC", "CXN_CLIENT"),	oModelCXN:GetValue("CXN_FORCLI"))
			oModelCXN:LoadValue(IIF(lCompra, "CXN_LJFORN", "CXN_LJCLI")	,	oModelCXN:GetValue("CXN_LOJA"))				
			
			If !oModelCXN:GetValue("CXN_CHECK") //- Remove Planilha sem Marcação
				CN121Grids( oModel , .F. )
			Else
				If lInclui				
					nAvgMetr += oModelCNE:Length(.T.)//Adiciona a quantidade de itens da planilha
				EndIf
				Cn121GrvAd()// 1x por Planilha
			EndIf
		Next Nx		

		//- Define situação da Medição.
		If lRet 
			lRet:= CN121Situa(oModel)
		EndIf
	ElseIf lExclui

		//-- Exclui a amarração com os conhecimentos
		MsDocument("CND", CND->(Recno()), 2,, 3)
		
		For nX := 1 to oModelCXN:Length()
			oModelCXN:GoLine(nX)
			If oModelCXN:GetValue("CXN_CHECK")
				Cn121GrvAd()//Atualiza os adiantamentos 1x por planilha
			EndIf
		Next nX
		
		If oModelCND:GetValue('CND_AUTFRN') == '2'			
			lRet := CN121MedEst(CND->(Recno()), !IsBlind(), .T.)
		EndIf
		
		//-- Estorno dos lancamentos do PCO
		CN121PCOLN( oModel , lExclui )
		
	EndIf

	//- Controle de Alçadas
	If lRet .And. !FwIsInCallStack('Cn121MedEnc') .And. !oModelCND:GetValue('CND_AUTFRN') == '2'
		CN121AlcMd(oModel)
	EndIf

	If lRet .And. (lRet := FwFormCommit(oModel))
		If lInclui
			nStack := GetSX8Len()
			While ( GetSX8Len() > nStack )
				ConfirmSX8()
			EndDo

			If oModelCND:GetValue('CND_AUTFRN') == '2'
				lRet := CN121Encerr(.T.)//- Autorização de fornecimento necessita do modelo gravado para poder gerar pedido.
			EndIf

			If (nAvgMetr > 0)
				MedMetric(nAvgMetr)//Telemetria(Média de itens por medição)
			EndIf
		EndIf
	EndIf

	If !lRet
	
		DisarmTransaction()
	
	ElseIf !lExclui .And. !lEncerra
		
		//-- Inclusao dos lancamentos do PCO
		CN121PCOLN( oModel , lExclui )
		
	EndIf
	
End Transaction

If lRet .And. lExcedMEnc
	CN121MedEnc(CND->(RECNO()), /*lAviso*/, /*lAutoFor*/, /*lMedServ*/, .T.)//Chama as integrações de PCO/Contabil para os itens excedentes
EndIf

If lRet .And. lMultiMed .And. ((lInclui .Or. lAltera) .And. !lEncerra) .And. !IsExced()
	UpdSaldos(oModelCND:GetDataID(), .F.)//Atualiza saldos na inclusao.[Precisa ser chamado após o fim da transação]
EndIf

If(!IsBlind() .And. ( lRet .And. Len(aOkDocs) > 0 ))	
	cTexto := STR0191 + CRLF //Foram gerados os documentos abaixo:
	
	aEval(aOkDocs,{|x| cTexto += IIF(x[1] $ '1|2', STR0070, STR0135) + ": " + x[2] + CRLF })
	
	cEncMsg := cTexto
EndIf

If IsInCallStack("At930Commit") //Apuração GS
	If FindFunction("At930GrCnt")
		At930GrCnt(aOkDocs, oModel)
	EndIf
EndIf

Return lRet
//------------------------------------------------------------------
/*/{Protheus.doc} Cn121AlcMd
Função de controle de Alçadas
@author israel.escorizza
@since 02/09/2015
/*/
//-------------------------------------------------------------------
Function Cn121AlcMd(oModel)
Local oModelCND	:= Nil
Local lInclui	:= .F.
Local lAltera	:= .F.
Local lExclui	:= .F.
Local lAlcada	:= Iif(SuperGetMv("MV_CNMDALC",.F.,"N")=="S",.T.,.F.)
Local cNumMed	:= ""
Local aCampos	:={}
Default oModel	:= FwModelActive()

If (oModel:IsActive() .And. oModel:GetId() == "CNTA121")
	oModelCND:= oModel:GetModel('CNDMASTER')
	lInclui	:= oModel:GetOperation() == MODEL_OPERATION_INSERT
	lAltera := oModel:GetOperation() == MODEL_OPERATION_UPDATE
	lExclui := oModel:GetOperation() == MODEL_OPERATION_DELETE
	cNumMed	:= oModelCND:GetValue("CND_NUMMED")

	If lAlcada
		DO CASE
			CASE lInclui .OR. lAltera
					aAdd(aCampos,{	oModelCND:GetValue("CND_NUMMED"),;
										"MD",;
										oModelCND:GetValue("CND_VLTOT"),;
										"",;
										"",;
										oModelCND:GetValue("CND_APROV"),;
										"",;
										oModelCND:GetValue("CND_MOEDA"),;
										0,;
										oModelCND:GetValue("CND_DTINIC");
									})

					//- Na alteração deleta documentos de alçada e gera novos.
					If lAltera
						GCTAlcEnt(oModel,oModel:GetOperation(),3,"MD",cNumMed,oModelCND:GetValue("CND_REVISA"),aCampos,.T.)
					EndIf

					GCTAlcEnt(oModel,oModel:GetOperation(),1,"MD",cNumMed,oModelCND:GetValue("CND_REVISA"),aCampos,.T.)

			CASE lExclui
				aAdd(aCampos,{	cNumMed,;
									"MD",;
									oModelCND:GetValue("CND_VLTOT"),;
									"",;
									"",;
									oModelCND:GetValue("CND_APROV"),;
									"",;
									oModelCND:GetValue("CND_MOEDA"),;
									0,;
									oModelCND:GetValue("CND_DTINIC");
					})

					GCTAlcEnt(oModel,oModel:GetOperation(),3,"MD",cNumMed,oModelCND:GetValue("CND_REVISA"),aCampos,.T.)
			ENDCASE
	EndIf
EndIf

Return

//------------------------------------------------------------------
/*/{Protheus.doc} CN121Inc()
Função de Inclusão
@author alexandre.gimenez
@since 21/08/2015
/*/
//-------------------------------------------------------------------
Function CN121Inc()
Local cModel:= 'CNTA121'

lInclui := .T.
aComp	:= {}
CfgIdMldDoc(MODEL_OPERATION_INSERT)
FWExecView(STR0088,cModel,MODEL_OPERATION_INSERT,,{|| .T.})//"Inclusão de Medição"
lInclui := .F.
Return

//------------------------------------------------------------------
/*/{Protheus.doc} CN121Alt()
Função de alteração
@author Israel.Escorizza
@since 29/06/2017
/*/
//-------------------------------------------------------------------
Function CN121Alt()
Local cModel:= 'CNTA121'
lAltera	:= .T.
Cn121GAutF((CND->CND_AUTFRN == '2'), .T.)
aComp	:= {}

//Verifica se a medição é excedente para competência não prevista
If GCTExcedNP(CND->CND_NUMMED)
	SetExcedNP(.T.)
EndIf

If Cn121OriMd('CNTA120')
 	CN121OldMd(4)
Else
	CfgIdMldDoc(MODEL_OPERATION_UPDATE)
	FWExecView(STR0054,cModel,MODEL_OPERATION_UPDATE,,{|| .T.})//"Alteração de Medição"
EndIf
lAltera := .F.
Cn121GAutF(.F., .T.)
Return

//------------------------------------------------------------------
/*/{Protheus.doc} CN121Vis()
Função de visualização
@author Israel.Escorizza
@since 29/06/2017
/*/
//-------------------------------------------------------------------
Function CN121Vis()
	Local cModel:= 'CNTA121'

	aComp	:= {}
	If Cn121OriMd('CNTA120')		
		CN121OldMd(2)
	Else
		CfgIdMldDoc(MODEL_OPERATION_VIEW)
		FWExecView(STR0055,cModel,MODEL_OPERATION_VIEW,,{|| .T.})//"Visualização de Medição"
	EndIf
Return

//------------------------------------------------------------------
/*/{Protheus.doc} CN121Exc()
Função de exclusão
@author Israel.Escorizza
@since 29/06/2017
/*/
//-------------------------------------------------------------------
Function CN121Excl()
	Local cModel:= 'CNTA121'
	lAutForn 	:= CND->CND_AUTFRN == '2'
	aComp	:= {}

	If Cn121OriMd('CNTA120')
		CN121OldMd(5)
	Else
		CfgIdMldDoc(MODEL_OPERATION_DELETE)
		FWExecView(STR0056,cModel,MODEL_OPERATION_DELETE,,{|| .T.})//"Exclusão de Medição"
	EndIf

	lAutForn := .F.
Return

//------------------------------------------------------------------
/*/{Protheus.doc} CN121Prt()
Função de visualização
@author Israel.Escorizza
@since 29/06/2017
/*/
//-------------------------------------------------------------------
Function CN121Prt()
aComp	:= {}
If Cn121OriMd('CNTA120')
	CN121OldMd(-3)//Chama impressão CNTA120	
Else
	CNTR031(CND->CND_NUMMED)
EndIf
Return

//------------------------------------------------------------------
/*/{Protheus.doc} CN121TES()
Função que atualiza tes
@author alexandre.gimenez
@since 21/08/2015
/*/
//-------------------------------------------------------------------
Static Function CN121TES()
Local oModel 	:= FwModelActive()
Local cContra	:= oModel:GetValue('CNDMASTER','CND_CONTRA')
Local cRet 		:= ""

If CN121RetSt("COMPRA",/**/,/**/,cContra)
	oModel:SetValue('CNEDETAIL',"CNE_TE",oModel:GetValue('CNEDETAIL',"CNE_TES"))
Else
	oModel:SetValue('CNEDETAIL',"CNE_TS",oModel:GetValue('CNEDETAIL',"CNE_TES"))
EndIf

Return cRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN121VldTES()
Função que Valida tes
@author alexandre.gimenez
@since 21/08/2015
/*/
//-------------------------------------------------------------------
Function CN121VldTES()
	Local oModel 	:= FwModelActive()
	Local cContra	:= oModel:GetValue('CNDMASTER','CND_CONTRA')
	Local lRet		:= .T.

	If ('CNE_TS' $ AllTrim(ReadVar())) .Or. ('CNE_TE' $ AllTrim(ReadVar()))
	If CN121RetSt("COMPRA",/**/,/**/,cContra)
		lRet := cn130VldTE(oModel:GetValue("CNEDETAIL","CNE_TES"))
	Else
		lRet := cn130VldTS(oModel:GetValue("CNEDETAIL","CNE_TES"))
	EndIf
	EndIf

Return lRet


//------------------------------------------------------------------
/*/{Protheus.doc} CN121IniTES()
Função inicializador padrao de  tes
@author alexandre.gimenez
@since 21/08/2015
/*/
//-------------------------------------------------------------------
Function CN121IniTES()
	Local cRet := ""
	Local oModel	:= FwModelActive()
	Local lInclui	:= .T.

	if ValType(oModel) == "O"
		lInclui	:= oModel:GetOperation() == MODEL_OPERATION_INSERT
	endif

	If !lInclui
		If CN121RetSt("COMPRA",/**/,/**/,CND->CND_CONTRA)
			cRet := CNE->CNE_TE
		Else
			cRet := CNE->CNE_TS
		EndIf
	EndIf

Return cRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN121ChgPl()
Change Line de Planilha. Libera e Bloqueia Modelo conforme tipo de planilha.
Refaz Totalizadores
@author alexandre.gimenez
@since 23/08/2015
/*/
//-------------------------------------------------------------------
Static Function CN121ChgPl(lCheck, oModel )	
	Local oModelCNE	:= Nil
	Local lInclui	:= .F.
	Local lAltera	:= .F.
	Local cContra	:= ""
	Local cPlan		:= ""
	Local lFixo		:= .F.
	Local lSemiProd	:= .F.
	Local lServico	:= .F.
	Local aBlkCpo	:= {}
	Local lRet 		:= .T.
	Local aBloqModel:= {}
	
	Default oModel := FwModelActive()
	Default lCheck := oModel:GetValue("CXNDETAIL","CXN_CHECK")	

	If !IsExced()
		oModelCNE := oModel:GetModel("CNEDETAIL")
		lInclui	:= oModel:GetOperation() == MODEL_OPERATION_INSERT
		lAltera	:= oModel:GetOperation() == MODEL_OPERATION_UPDATE
		cContra	:= oModel:GetValue("CXNDETAIL", "CXN_CONTRA")
		cPlan 	:= oModel:GetValue("CXNDETAIL", "CXN_NUMPLA")

		If !lCheck
			CNTA300BlMd(oModelCNE, .T.)
			
			aBloqModel := {'CZYDETAIL', 'CNRDETAIL1', 'CNRDETAIL2'}
			aEval(aBloqModel, {|x| CNTA300BlMd(oModel:GetModel(x),.T.) })//- Bloqueia modelos ao desmarcar planilha
			
			SetObgFlds(oModel, .F.)//Desativa a obrigatoriedade de preencher os campos marcados como "obrigatório" no dicionário
		Else
			lSemiProd	:= Cn121RetSt( 'SEMIPROD'	, 0, cPlan, cContra, .T., oModel )
			lServico 	:= Cn121RetSt( 'SERVIÇO'	, 0, cPlan, cContra, .T., oModel )
			lFixo 		:= Cn121RetSt( 'FIXO'		, 0, cPlan, cContra, .T., oModel )

			CNTA300BlMd(oModel:GetModel('CZYDETAIL'),,.T.) //Libera apenas o update
			
			CNTA300BlMd(oModel:GetModel('CNRDETAIL1'),.F.) //Libera modelo Multas da Planilha
			CNTA300BlMd(oModel:GetModel('CNRDETAIL2'),.F.) //Libera modelo Multas dos Itens
			
			oModelCNE:SetNoDeleteLine(.F.)
			oModelCNE:SetNoInsertLine((lFixo .And. !lServico .Or. lSemiProd))
			oModelCNE:SetNoUpdateLine(.F.)

			SetObgFlds(oModel, .T.)//Ativa a obrigatoriedade de preencher os campos marcados como "obrigatório" no dicionário			
			SetWhenOri(oModel,,{'CNEDETAIL'})//Restaura WHEN original dos campos da CNE			
		EndIf
	Else
		LibCpoExcd(oModel)//Configura campos p/ excedente
	EndIf

	FwFreeArray(aBlkCpo)
Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN121Encerr()
Rotina de encerramento de medição
@author alexandre.gimenez
@since 23/08/2015
/*/
//-------------------------------------------------------------------
Function CN121Encerr(lAuto,lAprRev)
Local lRet 		:= .F.
Local lContinua	:= .T.
Local lAutFor	:= (CND->CND_AUTFRN == '2' .And. !FwIsInCallStack("CN121GRV"))
Local dDataBloq	:= GetNewPar("MV_ATFBLQM",CTOD("")) //Data de Bloqueio da Movimentação - MV_ATFBLQM
Local lReinf	:= CNE->( Columnpos('CNE_15ANOS') ) > 0 
Local bEncerra	:= {||}
Local cChaveCN9	:= ""
Local lMultiMed := CN121RetSt("MULTIMED",0,, CND->CND_CONTRA,.F.,Nil, CND->CND_FILCTR)
Local oView		:= Nil
Local lFreeModel:= .F.
Local lIntegGRR	:= 	(FindFunction( "GRRIsActive" ) .And. GRRIsActive()) .And. FindFunction('GRRSndE1MD')

DEFAULT lAuto 	:= FwIsInCallStack("IncEnc121")
DEFAULT lAprRev := .F.
DEFAULT lAprRev := .F.

If Cn121OriMd('CNTA120')
 	CN120Ence('CND',CND->(Recno()))
ElseIf !(AllTrim(CND->CND_SITUAC) $ "A|FA|SA")
	If !lAuto
		Help(" ",1,"CN121JaEnc",,STR0089,1,0) //"Operação não permitida. Somente é possível encerrar Medições em Aberto."
	Endif
Else
	lEncerra := .T.
    If !lAuto
	    lContinua := (Aviso("CNTA121",OemtoAnsi(STR0090),{STR0157,STR0158}) == 1)//"Confirma encerramento da medição/Aut. Fornecimento?"
    Endif

	//Verifica se existe bloqueio contábil
	If lContinua .And. (lContinua := CtbValiDt(Nil, dDataBase,/*.T.*/ ,Nil ,Nil ,{"GCT001"}/*,"Data de apuração bloqueada pelo calendário contábil."*/) )
		If!Empty(dDataBloq) .AND. ( dDataBase <= dDataBloq)
			If !lAuto
				Help(" ",1,"ATFCTBBLQ") //P: Processo bloqueado pelo Calendário Contábil ou parâmetro de bloqueio nesta data ou período. S: Caso possível altere a data de referência do processo, verifique o parâmetro ou contate o responsável pelo Módulo Contábil.)
			Endif
			lContinua := .F.
		End
	EndIf

	If lContinua .And. lReinf .And. !CNRNFVldP( CND->CND_FILIAL , CND->CND_CONTRA , CND->CND_NUMMED )
		Help( " " , 1 , "CNREINF" )
		lContinua := .F.
	EndIf

	If lContinua .And. !Empty(CND->CND_DTFIM) //-- Verifica se a medicao ja se encontra encerrada
		Help( " ", 1, "CNTA120_03" )//"Medição já encerrada"
		lContinua := .F.
	EndIf
	
	If lContinua .And. (GetNewPar("MV_CNMDALC","N") == "S"  .AND. CND->CND_ALCAPR == "B")
		Help( " ", 1, "CNTA120_09" )//"Medição bloqueada por alçada"
		lContinua := .F.
	EndIf

	If lContinua		
		CN9->(dbSetOrder(1))
		cChaveCN9 := CND->(xFilial("CN9", CND_FILCTR) + CND_CONTRA+CND_REVISA)		
		If CN9->(MsSeek(cChaveCN9)) .And. (CN9->CN9_SITUAC $ DEF_SSPAR + "|" + DEF_SFINA + "|" + DEF_SCANC) ////Contrato em Sol. Finalização, Finalizado ou Cancelado
			Help( " ", 1, "CNTA120_02" )//"Apenas contratos em vigência podem ser medidos"
			lContinua := .F.
		EndIf		
	EndIf

	If lContinua
		lContinua := CN121DtEnt() //Varrer todos os itens da medição e verificar se existe item com CNE_DTENT vazio e caso existir não prosseguir com o processamento
	EndIf	

	If lContinua .And. !lMultiMed
		lContinua := VldCXNEnc()/*Valida o saldo da CNA com sabe na CXN*/
	EndIf
	
	If lContinua
		//Chama rotina de encerramento por meio de processo
		If  lAutFor .And. !lInclui .And. !lAltera
			bEncerra := {||lRet := Cn121AutEnc(CND->(RECNO()))}			
		Else
			bEncerra := {||lRet := CN121MedEnc(CND->(RECNO()))}			
		EndIf
		
		If(lAuto)
			Eval(bEncerra)
		Else
			Processa(bEncerra)
		EndIf

		If(lRet)			
			EnvSldMail()//Avalia o limite percentual do tipo da planilha e avisa sobre seu saldo
			If lIntegGRR
				GRRSndE1MD()
			EndIf
			
			If(!Empty(cEncMsg))
				If !lAuto
					MsgInfo(cEncMsg, STR0134 + "/" + STR0135)
				ElseIf !IsBlind() .And. (FwIsInCallStack("A094Commit") .Or.; //Aprovação de Documentos via MATA094
										(FwIsInCallStack("CN121GRV") .And. Cn121GAutF()))//Inclusão da autorização de fornecimento(encerra na inclusão)
					oView := FWViewActive()
					If ValType(oView) == "O"
						oView:showUpdateMsg(.T.)
						oView:setUpdateMessage(STR0134 + "/" + STR0135,cEncMsg)
						oView:showInsertMsg(.T.)
						oView:setInsertMessage(STR0134 + "/" + STR0135,cEncMsg)						
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	lEncerra := .F.
EndIf

lFreeModel := !lAuto .Or.; //Encerramento via tela, limpa o modelo
			  (lAuto .And. (FwIsInCallStack("CN260Exc") .Or. FwIsInCallStack("GCTPVGrvMD")) ) // caso seja rotina automática, porém via CNTA260 ou MATA410, também limpa			  

CN121Limpa(lFreeModel)//Realiza a limpeza de variáveis estáticas

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN121PreDoc()
Funcao para Preparar pedidos e titulos de uma medicao
@author alexandre.gimenez
@since 26/08/2015
/*/
//-------------------------------------------------------------------
Function CN121PreDoc()
Local lRet 		:= .T.
Local oModel 	:= FwLoadModel("CNTA121")

oModel:SetOperation(MODEL_OPERATION_UPDATE)
If lRet := oModel:Active()
	If lRet := oModel:VldData()
			lRet := oModel:CommitData()
	EndIf
EndIf

Return lRet


//------------------------------------------------------------------
/*/{Protheus.doc} CN121GerDoc()
Funcao para gerar pedidos e titulos de uma medicao
@author alexandre.gimenez
@since 26/08/2015
/*/
//-------------------------------------------------------------------
Function CN121GerDoc(oModel, aOkDocs)
Local oModelCND		:= oModel:GetModel("CNDMASTER")
Local oModelCXN		:= oModel:GetModel("CXNDETAIL")
Local oModelCNE		:= oModel:GetModel("CNEDETAIL")
Local oModelCXI		:= oModel:GetModel("CXIDETAIL")
Local oModelCXJ		:= oModel:GetModel("CXJDETAIL")
Local oModelCNQ		:= oModel:GetModel("CNQDETAIL")
Local oModelCNU		:= oModel:GetModel("CNUDETAIL")
Local oModelCNZ		:= oModel:GetModel("CNZDETAIL")
Local oModelCNR1	:= oModel:GetModel("CNRDETAIL1")
Local oModelCNR2	:= oModel:GetModel("CNRDETAIL2")
Local oModelCZY		:= oModel:GetModel('CZYDETAIL')

Local aCond			:= {}
Local aDocs			:= {}
Local aCab			:= {}
Local aItem			:= {}
Local aRateio		:= {}
Local aRatServ		:= {}
Local aQuebraIt		:= {}
Local aQuebraEnv	:= {}
Local aCTBEnt		:= CTBEntArr()
Local aCamposCNZ	:= oModelCNZ:GetStruct():GetFields()
Local aLocAtend		:= {}
Local aCabUser      := {}
Local aAreaCN9		:= CN9->(GetArea())

Local cAlc			:= "N"
Local cRetPrf		:= ""
Local cTpTit		:= ""
Local cRetNat		:= ""
Local cParcela		:= "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0"
Local cChaveRat		:=	""
Local cNumCab		:= ""
Local cItemDetail	:= ""
Local cVend			:= ""
Local cCampoECCNZ	:= ""
Local cCampoECCNE	:= ""
Local cGrpAprov		:= oModelCND:GetValue("CND_APROV")
Local cContra		:= oModelCND:GetValue("CND_CONTRA")
Local cRevisa		:= oModelCND:GetValue("CND_REVISA")
Local cNumMed		:= oModelCND:GetValue("CND_NUMMED")
Local cMoeda		:= oModelCND:GetValue("CND_MOEDA")
Local cCondPgto		:= oModelCND:GetValue("CND_CONDPG")
Local cFilCtr		:= oModelCND:GetValue("CND_FILCTR")
Local cUserGi		:= ""
Local cUserCod		:= ""
Local dDtVencPl		:= ""
Local cNumPlan		:= ""
Local cIdPedido		:= ""
Local cPedTit		:= ""
Local cProdSv		:= ""
Local cFilRes		:= ""
Local cFilContr		:= oModelCND:GetValue("CND_FILCTR")
Local cFilSC        := ""
Local cFilScCTR		:= xFilial("SC1", cFilContr)
Local cTipoFrete	:= ""
Local cTpRat		:= GetNewPar("MV_CNRATE", "1")
Local cCNPREMD 		:= SuperGetMV("MV_CNPREMD",.F.,"MED")
Local cCNTPTMD 		:= SuperGetMV("MV_CNTPTMD",.F.,"BOL")
Local cFilSA2       := xFilial("SA2",cFilCtr)
Local cFilCN9       := xFilial("CN9",cFilCtr)
Local nQuantCNE		:= 0
Local nCXN			:= 0
Local nCNQ			:= 0
Local nCZY			:= 0
Local nCNE			:= 0
Local nCXI			:= 0
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 0
Local nA			:= 0
Local nB			:= 0
Local nCount		:= 0
Local nCauc			:= 0
Local nAdia			:= 0
Local nParte		:= 0
Local nVlrDescPl	:= 0
Local nTitVlr		:= 0
Local nVlrDescIt    := 0
Local nDescMedPl    := 0
Local nMultMedPl	:= 0
Local nBoniMedPl	:= 0
Local nTotDecres	:= 0
Local nTotAcres		:= 0
Local nTitBoni		:= 0
Local nTitMult		:= 0
Local nPosId		:= 0
Local nPosServ		:= 0
Local nPosItem		:= 0
Local nPosEnv		:= 0
Local nPosDoc		:= 0
Local nPosRat		:= 0
Local nGCTDPcAl		:= GetNewPar("MV_CNDPCAL",2)
Local nQuantArred	:= 0
Local nPrecoArred	:= 0
Local nValorArred	:= 0
Local nQuantOri		:= 0
Local nPrecoOri		:= 0
Local nValorOri		:= 0
Local nDifValor		:= 0
Local nVlItDesc		:= 0
Local nDescPropIt	:= 0
Local nDescPropPl	:= 0
Local nAcumulado	:= 0
Local nValor		:= 0
Local nMultBonIt	:= 0
Local nMultBonPla	:= 0
Local nVlItMulBon	:= 0
Local nVlPlMulBon	:= 0
Local nCNR1			:= 0
Local nCNR2			:= 0
Local nMod			:= Iif(Cn121RetSt('COMPRA',0,oModelCXN:GetValue('CXN_NUMPLA'),oModelCXN:GetValue("CXN_CONTRA")),1,-1)
Local nItemAglut    := 0
Local nNumPla       := 0
Local nNumInd       := 0

Local lCNT121PC 	:= ExistBlock("CNT121PC")
Local lCN121PED 	:= ExistBlock("CN121PED")
Local lCN121AFN	    := ExistBlock("CN121AFN")

Local lGCTRet		:= GetNewPar("MV_CNRETNF"	,"N") == "S"
Local lGCTAdia		:= GetNewPar("MV_CNADIA"	,"N") == "S"
Local lGCTMdAlc		:= GetNewPar("MV_CNMDALC"	,"N") == "S"
Local lGeraCP		:= SuperGetMV("MV_CNPROCP"	,.F.,"N") == "S"
Local lNMedTit		:= SuperGetMV("MV_NMEDTIT",.F., '1') == '2'
Local lCompra		:= CN121RetSt( "COMPRA", 0,, CND->CND_CONTRA )
Local lRet			:= .T.
Local lEnvFinan		:= .F.
Local lEnvCons		:= .F.
Local lMod			:= .F.
Local lSkipEnv		:= .F.
Local lProdServ		:= .F.
Local lEC05			:= .F.
Local lEC06			:= .F.
Local lEC07			:= .F.
Local lEC08			:= .F.
Local lEC09			:= .F.
Local lTemPedido	:= .F.
Local lCalcIR       := .F.
Local lHasFrete		:= HasCpoFrete()
Local lFilSC		:= CNB->(FieldPos("CNB_FILSC")) > 0 .And. FWModeAccess("SC1",1)+FWModeAccess("SC1",2)+FWModeAccess("SC1",3) != "CCC"
Local cMdcron  		:= ""
Local cMdparce 		:= ""
Local cParCXN		:= ""
Local cCRONOG		:= ""
Local cCodEdt       := ""
Local cFilEdt       := ""
Local cNumPro       := ""
Local lAposEsp		:= CNE->(Columnpos('CNE_15ANOS')) > 0 .OR. CNE->(Columnpos('CNE_20ANOS')) > 0  .OR. CNE->(Columnpos('CNE_25ANOS')) > 0  
Local aItemApo		:= {}
Local aLinhApo		:= {}
Local aAposEsp		:= {}
Local nAp			:= 1
Local aSeFKF		:= {}
Local aSeFKG		:= {}
Local aItemFKG		:= {}
Local nItemFKG		:= 0
Local nSoma15a		:= 0
Local nSoma20a		:= 0
Local nSoma25a		:= 0
Local cMDAP15		:= SuperGetMv("MV_MDAP15",,"")	//Codigo do complemento de imposto de aposentadoria para faixa de 15 anos
Local cMDAP20		:= SuperGetMv("MV_MDAP20",,"")	//Codigo do complemento de imposto de aposentadoria para faixa de 20 anos
Local cMDAP25		:= SuperGetMv("MV_MDAP25",,"")	//Codigo do complemento de imposto de aposentadoria para faixa de 25 anos 
Local lTxMoeda  	:= CND->( ColumnPos( "CND_TXMOED" ) ) > 0
Local cNatPV		:= ""
Local cLocPad		:= ""
Local nVlrBsIr      := 0
Local nVlrAdiant	:= 0
Local lEmDespesa	:= SuperGetMV("MV_MULTMED",.F.,"2") == "2" //1=Valor Unitario, 2=Despesa
Local aMultBoni		:= {0, 0}
Local lPcFilEnt  	:= .F.
Local aAdtPC		:= {}
Local lCondPgAdt	:= IIF(	SE4->(ColumnPos('E4_CTRADT')) > 0,;//Em algumas localizações o campo E4_CTRADT não existe
							(Posicione("SE4", 1, xFilial("SE4",cFilCtr) + PadR(cCondPgto, TamSX3("E4_CODIGO")[1]), "E4_CTRADT") == "1"),;
							.F.)
Local cFormPagA2	:= ""
Local nPlanDocs		:= 0
Local lDocGen		:= .F.
Local nTotDocs		:= 0
Local nTamUser 		:= GetSX3Cache('C7_USER','X3_TAMANHO')

Default aOkDocs		:= {}

If Type("lMsErroAuto") != 'L'
	Private lMsErroAuto := .F.
EndIf

//-Inclusão de proteção para entidades contábeis na geração de pedido.
If FindFunction("CTB105MVC")
	CTB105MVC(.T.)
EndIf 

If lCompra	
	If (cFilCtr != cFilAnt)
		lPcFilEnt := SuperGetMv("MV_PCFILEN") //Informa se as solicitacoes devem ser da mesma filial logada	 		
	EndIf
EndIf

/* Estrutura de Arrays
aDocs
	cTipo(1-PedidoCompra,2-PedidoVenda,3-TituloPagar,4-TituloReceber)
	aCab
	aItem
	aRateio

aQuebraIt
	cChave
	cIdPed
	cTipo
	aServ
		cProdSv
		aItem
			cItem
			nQuant
			nValor

aQuebraEnv
	cTipo
	cCliente
	cLoja
	cFilial
	nPercent
	aQuebraIt
	cItem

aRatServ
	cChave
	cValor
	CC
	CONTA
	ITEMCT
	CLVL
	05CR
	05DB
	06CR
	06DB
	07CR
	07DB
	08CR
	08DB
	09CR
	09DB
*/

//Identifica o uso de controle de alçada no PC
If nGCTDPcAl == 1
	cAlc := "N" //Ativa o uso do controle de alçada.
ElseIf	nGCTDPcAl == 2
	cAlc :=  "S" //Desativa o uso do controle de alçada.
ElseIf nGCTDPcAl == 3
	cAlc := IIf( lGCTMdAlc .And. !Empty(cGrpAprov),"S","N") //Se medição possuir alçada, desativa.
EndIf

CN9->(dbSetOrder(1))

If CN9->(MsSeek(cFilCN9+CND->CND_CONTRA+CND->CND_REVISA))
	cCodEdt := CN9->CN9_CODED
	cNumPro := CN9->CN9_NUMPR
	cFilEdt := CN9->CN9_FILEDT
EndIf

//Obtem o valor de retencao de caucao
nCauc := If(!lGCTRet,oModel:GetValue("CNDMASTER","CND_RETCAC"),0)
//Obtem o valor dos adiantamentos
nAdia := If(lGCTAdia,oModel:GetValue("CNDMASTER","CND_TOTADT"),0)

For nCXN := 1 to oModelCXN:Length()
	oModelCXN:GoLine(nCXN)
	cNumPlan	:= oModelCXN:GetValue("CXN_NUMPLA")
	cParCXN		:= oModelCXN:GetValue("CXN_PARCEL")			
	
	nDescMedPl := 0
	nMultMedPl := 0
	nBoniMedPl := 0
	aMultBoni  := {0, 0} //Limpa por planilha
	
	If oModelCXN:GetValue("CXN_CHECK")
		
		nDescMedPl := oModelCXN:GetValue( "CXN_VLDESC" )
		nMultMedPl := oModelCXN:GetValue( "CXN_VLMULT" ) 
		nBoniMedPl := oModelCXN:GetValue( "CXN_VLBONI" )
		
		//-- Se planilha for zerada, não gera documentos
		If oModelCXN:GetValue('CXN_ZERO') == '1'
			Loop
		Else
			nPlanDocs++
		EndIf
			
		dDtVencPl  := oModelCXN:GetValue('CXN_DTVENC')
		nVlrDescPl := 0

		lTemPedido	:= CN121TPed( oModelCNE )

		For nCNQ := 1 to oModelCNQ:Length()
			oModelCNQ:GoLine(nCNQ)
			//Contabiliza desconto apenas se o tipo do desconto estiver configurado para interferir no pedido
			//ou se a planilha gerar apenas títulos
			If CN121DcItf( oModelCNQ ) .And. lTemPedido
				nVlrDescPl += oModelCNQ:GetValue('CNQ_VALOR')
			EndIf
		Next nCNQ

		If lGCTAdia
			nVlrAdiant := 0
			For nCZY := 1 to oModelCZY:Length()
				oModelCZY:GoLine(nCZY)
				nVlrAdiant += oModelCZY:GetValue('CZY_VALOR')
			Next nCZY

			If !(lCondPgAdt .And. lCompra)			
				nVlrDescPl += nVlrAdiant				
			EndIf
		EndIf

		If !lGCTRet
			nVlrDescPl += oModelCND:GetValue('CND_RETCAC') * (oModelCXN:GetValue('CXN_VLLIQD') / oModelCND:GetValue('CND_VLLIQD'))
		EndIf

		aSize(aQuebraIt,0)
		aSize(aQuebraEnv,0)
		aQuebraIt := {}
		aQuebraEnv := {}

		lEnvFinan	:= !Empty(oModelCXI:GetValue("CXI_CODCLI")) .And. oModelCXI:GetValue("CXI_TIPO") == "2" //Existem Finaciadores
		lEnvCons	:= !Empty(oModelCXI:GetValue("CXI_FILRES")) .And. oModelCXI:GetValue("CXI_TIPO") == "1"// Consorcio, Verificar linha

		For nCNE := 1 to oModelCNE:Length()
			oModelCNE:GoLine(nCNE)
			cIdPedido	:= oModelCNE:GetValue("CNE_IDPED")
			cPedTit 	:= oModelCNE:GetValue("CNE_PEDTIT")
			cProdSv		:= oModelCNE:GetValue("CNE_PRODSV")
			nQuantCNE 	:= oModelCNE:GetValue("CNE_QUANT")			
			
			//Inclui somente itens com quantidade maior que zero
			lDocGen	:= IsDocGen(oModelCXJ, oModelCNE:GetValue("CNE_ITEM"))
			nTotDocs+= IIF(lDocGen,1,0)
			If nQuantCNE > 0 .And. !lDocGen
				If !lExcedMEnc
					//Busca Id de Pedido no array
					If ( nPosId := aScan(aQuebraIt,{|x| x[1] == cIdPedido+cPedTit } ) ) == 0
						aAdd(aQuebraIt,{cIdPedido+cPedTit,cIdPedido,cPedTit,{}})
						nPosId:= Len(aQuebraIt)
						aAdd(aQuebraIt[nPosId][4],{cProdSv,{}})
						nPosServ := 1
					Else //Busca se ja existe o servico no Id
						If ( nPosServ := aScan(aQuebraIt[nPosId][4],{|x| x[1] == cProdSv } ) ) == 0
							aAdd(aQuebraIt[nPosId][4],{cProdSv,{}})
							nPosServ := Len(aQuebraIt[nPosId][4])
						EndIf
					EndIf

					//Cria um novo Item
					aAdd(aQuebraIt[nPosId][4][nPosServ][2],{})
					nPosItem := Len(aQuebraIt[nPosId][4][nPosServ][2])
					//Adiciona Itens ao Id e Servico Relacionado
					aAdd(aQuebraIt[nPosId][4][nPosServ][2][nPosItem],oModelCNE:GetValue("CNE_ITEM") )
					aAdd(aQuebraIt[nPosId][4][nPosServ][2][nPosItem],nQuantCNE )
					aAdd(aQuebraIt[nPosId][4][nPosServ][2][nPosItem],oModelCNE:GetValue("CNE_VLUNIT") - oModelCNE:GetValue("CNE_VLDESC") )
				Else
					If oModelCNE:GetValue("CNE_EXCEDE") == "1" .And. oModelCNE:IsInserted()
						//Busca Id de Pedido no array
						If ( nPosId := aScan(aQuebraIt,{|x| x[1] == cIdPedido+cPedTit } ) ) == 0
							aAdd(aQuebraIt,{cIdPedido+cPedTit,cIdPedido,cPedTit,{}})
							nPosId:= Len(aQuebraIt)
							aAdd(aQuebraIt[nPosId][4],{cProdSv,{}})
							nPosServ := 1
						Else //Busca se ja existe o servico no Id
							If ( nPosServ := aScan(aQuebraIt[nPosId][4],{|x| x[1] == cProdSv } ) ) == 0
								aAdd(aQuebraIt[nPosId][4],{cProdSv,{}})
								nPosServ := Len(aQuebraIt[nPosId][4])
							EndIf
						EndIf

						//Cria um novo Item
						aAdd(aQuebraIt[nPosId][4][nPosServ][2],{})
						nPosItem := Len(aQuebraIt[nPosId][4][nPosServ][2])
						//Adiciona Itens ao Id e Servico Relacionado
						aAdd(aQuebraIt[nPosId][4][nPosServ][2][nPosItem],oModelCNE:GetValue("CNE_ITEM") )
						aAdd(aQuebraIt[nPosId][4][nPosServ][2][nPosItem],nQuantCNE )
						aAdd(aQuebraIt[nPosId][4][nPosServ][2][nPosItem],oModelCNE:GetValue("CNE_VLUNIT") - oModelCNE:GetValue("CNE_VLDESC") )
					EndIf
				EndIf
			EndIf
		Next nCNE


		//-- Monta pedidos por Envolvidos
		If lEnvFinan .Or. lEnvCons
			For nCXI := 1 To oModelCXI:Length()
				oModelCXI:GoLine(nCXI)
				cFilRes	:= oModelCXI:GetValue("CXI_FILRES")

				lSkipEnv := .F.
				//-- Para consorcio, so gera quando for uma filial
				If lEnvCons .And. Empty(cFilRes)
					lSkipEnv := .T.
				EndIf

				If !lSkipEnv
					aAdd(aQuebraEnv,{})
					nPosEnv := Len(aQuebraEnv)

					If lEnvFinan
						aAdd(aQuebraEnv[nPosEnv],"F")
						aAdd(aQuebraEnv[nPosEnv],oModelCXI:GetValue("CXI_CODCLI"))
						aAdd(aQuebraEnv[nPosEnv],oModelCXI:GetValue("CXI_LOJACL"))
					Else
						aAdd(aQuebraEnv[nPosEnv],"C")
						aAdd(aQuebraEnv[nPosEnv],oModelCXN:GetValue("CXN_FORCLI"))
						aAdd(aQuebraEnv[nPosEnv],oModelCXN:GetValue("CXN_LOJA"))
					EndIf

					aAdd(aQuebraEnv[nPosEnv],IIF(Empty(cFilRes),cFilAnt,cFilRes))
					aAdd(aQuebraEnv[nPosEnv],oModelCXI:GetValue("CXI_PERRAT"))
					aAdd(aQuebraEnv[nPosEnv],aClone(aQuebraIt))
					aAdd(aQuebraEnv[nPosEnv],oModelCXI:GetValue("CXI_ITEM"))
				EndIf
			Next nCXI
		Else //Caso Não exista envolvidos Monta array com Cliente/ Fornecedor da planilha
			aAdd(aQuebraEnv,{})
			nPosEnv := Len(aQuebraEnv)
			aAdd(aQuebraEnv[nPosEnv],"X")

			If lCompra
				aAdd(aQuebraEnv[nPosEnv],oModelCXN:GetValue("CXN_FORNEC"))
				aAdd(aQuebraEnv[nPosEnv],oModelCXN:GetValue("CXN_LJFORN"))
			Else
				aAdd(aQuebraEnv[nPosEnv],oModelCXN:GetValue("CXN_CLIENT"))
				aAdd(aQuebraEnv[nPosEnv],oModelCXN:GetValue("CXN_LJCLI"))
			EndIf

			aAdd(aQuebraEnv[nPosEnv],cFilAnt)
			aAdd(aQuebraEnv[nPosEnv],100)
			aAdd(aQuebraEnv[nPosEnv],aClone(aQuebraIt))
			aAdd(aQuebraEnv[nPosEnv],StrZero(nPosEnv,TamSX3("CXI_ITEM")[1] ) )//-- Não tem parte envolvida
		EndIf

		If !Empty(aQuebraEnv)
			For nA := 1 To Len(aQuebraEnv)//-- Roda Clientes/Fornecedores da Planilha
				nParte := aQuebraEnv[nA][5]/100
				For nX := 1 To Len(aQuebraEnv[nA][6])//Roda os Ids
					//-- Zera Totalizadores de titulo por ID
					nTitVlr 	:= 0
					nVlrDescIt  := 0
					nTitBoni	:= 0
					nTitMult	:= 0
					nSoma15a	:= 0
					nSoma20a	:= 0 
					nSoma25a	:= 0
					nItemFKG	:= 0
					aSeFKF		:= {}
					aSeFKG		:= {}
					aItemFKG	:= {}
					aItemApo 	:= {}
					aLinhApo 	:= {}
					aAposEsp 	:= {}
					aAdtPC		:= {}
					
					aAdd(aDocs, {/*Tipo*/,{/*aCab*/},{/*aItem*/},{/*aRateio*/},{/*aSeFKF*/},{/*aSeFKG*/},{/*aAposEsp*/}, {/*aAdtPC*/}})
					//-- Criar documento e iniciar
					aSize(aCab,0)
					aSize(aItem,0)
					aSize(aRateio,0)
					aCab 	:= {}
					aItem 	:= {}
					aRateio	:= {}
					cItemDetail:= IIF(lCompra,StrZero(0,TamSX3("C7_ITEM")[1]),StrZero(0,TamSX3("C6_ITEM")[1]))
					nPosDoc 	:= Len(aDocs)

					//Identifica documento a ser gerado
					If lCompra
						If aQuebraEnv[nA][6][nX][3] == '2'
							aDocs[nPosDoc][1]:= '3' // Titulo a Pagar
						Else
							aDocs[nPosDoc][1]:= '1'  // Pedido de Compra
						EndIf
					Else
						If aQuebraEnv[nA][6][nX][3] == '2'
							aDocs[nPosDoc][1]:= '4' // Titulo a receber
						Else
							aDocs[nPosDoc][1]:= '2'  // Pedido de Venda
						EndIf
					EndIf
					
					cMdcron  := ""
					cMdparce := ""
					cCRONOG	 := ""
						
					cCRONOG := oModelCXN:GetValue('CXN_CRONOG')
					
					CNF->( dbSetorder( 3 ) ) //CNF_FILIAL+CNF_CONTRA+CNF_REVISA+CNF_NUMERO+CNF_PARCEL
					If CNF->( msSeek( FWxFilial("CNF") + oModelCND:GetValue('CND_CONTRA') + oModelCND:GetValue('CND_REVISA') + cCRONOG + cParCXN ) )
						cMdcron := CNF->CNF_NUMERO
						cMdparce := CNF->CNF_PARCEL
					EndIf

					//- Montagem dos aCabs conforme Documento
					Do Case
						Case aDocs[nPosDoc][1] == '1'  // Pedido de Compra
							If lCNT121PC
								ExecBlock("CNT121PC",.F.,.F.)
							EndIf

							//- Monta a Cab
							aCab:=	{{"C7_EMISSAO"	,dDataBase						,NIL},; // Data de Emissao
									{"C7_FORNECE"	,aQuebraEnv[nA][2]				,NIL},; // Fornecedor
									{"C7_LOJA"		,aQuebraEnv[nA][3]				,NIL},; // Loja do Fornecedor
									{"C7_COND"		,cCondPgto						,NIL},; // Condicao de Pagamento
									{"ALCADA"		,cAlc							,NIL},; // Alcada
									{"MED_GCT"		,"GCT"							,NIL},; // Originador
									{"C7_MOEDA"		,cMoeda							,NIL},; // Moeda
									{"C7_CONTATO"	,CriaVar("C7_CONTATO"	,.F.)	,NIL},; // Contato
									{"C7_FILENT"	,CriaVar("C7_FILENT",.F.)		,NIL},; // Filial de Entrega
									{"C7_FRETE"		,IIF(lHasFrete,oModelCXN:GetValue("CXN_FRETE" ),CriaVar("C7_FRETE"  ,.F. ) ),NIL},; // Frete
									{"C7_DESPESA"	,IIF(lHasFrete,oModelCXN:GetValue("CXN_DESPES"),CriaVar("C7_DESPESA",.F. ) ) ,NIL},; // Despesa
									{"C7_SEGURO"	,IIF(lHasFrete,oModelCXN:GetValue("CXN_SEGURO"),CriaVar("C7_SEGURO" ,.F. ) ) ,NIL},; // Seguro
									{"C7_MSG"		,CriaVar("C7_MSG",.F.)			,NIL},; // Mensagem
									{"C7_REAJUST"	,CriaVar("C7_REAJUST",.F.)		,NIL}} // Reajuste
							
							If cMoeda != 1
								If lTxMoeda .And. CND->CND_TXMOED > 0
									aAdd( aCab, { "C7_TXMOEDA", CND->CND_TXMOED, NIL } )
								Else
									aAdd( aCab, { "C7_TXMOEDA", xMoeda(1,cMoeda,1,dDataBase,TamSx3("C7_TXMOEDA")[2],,), NIL } ) //Taxa de Conversao
								EndIF
							EndIf

							If cPaisLoc == 'RUS'
				   				aAdd(aCab,{"C7_CONUNI",CND->CND_CONUNI,NIL}) // Conventional unit
				   				If !EMPTY(AllTrim(oModelCXN:GetValue('CXN_CONTRA')))
									aAdd(aCab,{"C7_F5QUID",Posicione("CNA",1,XFILIAL("CNA")+oModelCXN:GetValue('CXN_CONTRA')+oModelCXN:GetValue('CXN_REVISA')+oModelCXN:GetValue('CXN_NUMPLA'),"CNA_F5QUID"),NIL}) // Legal Contracts UID
									aAdd(aCab,{"C7_F5QCODE",Posicione("F5Q",1,XFILIAL("F5Q")+aCab[Ascan(aCab,{|x| x[1] == "C7_F5QUID" })][2],"F5Q_CODE"),NIL}) // Legal Contracts Code
								EndIf
							EndIf

							If CND->(FieldPos('CND_USERGI')) > 0
								cUserGi := FWLeUserlg("CND_USERGI")
								PswOrder(2)
								If PswSeek(cUserGi,.T.)
									cUserCod	:= PswRet()[1][1]
									aAdd(aCab,{"C7_USER",cUserCod,NIL})
								EndIf
							Else
								aAdd(aCab,{"C7_USER",PadR(__cUserId,nTamUser),NIL})
							EndIf

						Case aDocs[nPosDoc][1] == '3' // Titulo a Pagar
							
							//- Monta a Cab
							
							cNumCab := CriaVar('E2_NUM',.T.)
							
							If Empty(cNumCab)
								cNumCab := A121SeqTit("SE2","E2_NUM",,cCNPREMD, oModel)
							EndIf
							
							
							aCab:={ {"E2_FORNECE"	,aQuebraEnv[nA][2]					,NIL},; //[1] Fornecedor
									{"E2_LOJA"		,aQuebraEnv[nA][3]					,NIL},; //[2] Loja do Fornecedor
									{"E2_ORIGEM"	,"CNTA121"							,NIL},; //[3] Origem
									{"E2_EMISSAO"	,dDataBase							,NIL},; //[4] Emissão
									{"E2_VENCTO" 	,IIf(dDtVencPl > dDataBase, dDtVencPl , dDataBase) ,NIL},; //[5] Vencimento
									{"E2_VENCREA"	,IIf(dDtVencPl > dDataBase, dDtVencPl , dDataBase) ,NIL},; //[6] Vencimento Real
									{"E2_VENCORI"	,IIf(dDtVencPl > dDataBase, dDtVencPl , dDataBase) ,NIL},; //[7] Vencimento Origem	
									{"E2_MOEDA"  	,cMoeda								,NIL},; //[8] Moeda
									{"E2_MDCONTR"	,cContra							,NIL},; //[9] Numero do Contrato
									{"E2_MDREVIS"	,cRevisa							,NIL},; //[10]Revisão do Contrato
									{"E2_MEDNUME"	,cNumMed							,NIL},; //[11]Numero da Medição
									{"E2_MDPLANI"	,cNumPlan							,NIL},; //[12]Numero da planilha
									{"E2_VALOR"		,0									,NIL},; //[13]Acrescimos do Titulo
									{"E2_ACRESC"	,0									,NIL},; //[14]Acrescimos do Titulo
									{"E2_DECRESC"	,0                              	,NIL},; //[15]Decrescimos do Titulo
									{"E2_NUM"		,cNumCab							,NIL},; //[16]Numero do Titulo
									{"E2_MDCRON"	,cMdcron							,NIL},;	//[17]Numero do Cronograma
									{"E2_MDPARCE"	,cMdparce							,NIL},;	//[18] Numero da Parcela
									{"E2_MDDESC"	,0									,NIL},;	//[19] Desconto da medição
									{"E2_MDMULT"	,0									,NIL},;	//[20] Multa da medição
									{"E2_MDBONI"	,0									,NIL},;	//[21] Bonificação da medição							
									{"E2_BASEIRF"	,0									,NIL}}  //[22] Base para calculo IRRF

							cFormPagA2 := GetFormPag(aQuebraEnv[nA,2], aQuebraEnv[nA,3], cFilCtr)
							If !Empty(cFormPagA2)
								aAdd(aCab, {"E2_FORMPAG", cFormPagA2, NIL})
							EndIf

							CnGetMNat( oModel , @aCab , 'E2' ) 

						Case aDocs[nPosDoc][1] == '2'  // Pedido de Venda
							//- Monta a Cab
							cTipoFrete := Posicione("TFJ",5,xFilial("TFJ")+cContra+cRevisa,"TFJ_TPFRET")
							If !Empty(cTipoFrete)
								cTipoFrete := Iif(TFJ->TFJ_TPFRET=="1","C","F")
							Else
								cTipoFrete := Posicione("SA1",1, xFilial("SA1")+oModelCXN:GetValue("CXN_CLIENT")+oModelCXN:GetValue("CXN_LJCLI"),"A1_TPFRET")
							Endif

							If cPaisLoc == "BRA"
								aLocAtend := Cn121GetLoc(oModelCXN:GetValue("CXN_CONTRA"),oModelCXN:GetValue("CXN_NUMPLA"))
							EndIf
							
							aCab:={	{"C5_TIPO"   	,	"N"									,Nil},; 	// Tipo de pedido
									{"C5_CLIENTE"	,	aQuebraEnv[nA][2]					,Nil},; 	// Codigo do cliente
									{"C5_LOJAENT"	,	aQuebraEnv[nA][3]					,Nil},; 	// Loja para entrada
									{"C5_LOJACLI"	,	aQuebraEnv[nA][3]					,Nil},; 	// Loja do cliente
									{"C5_EMISSAO"	,	dDatabase							,Nil},; 	// Data de emissao
									{"C5_CONDPAG"	,	cCondPgto							,Nil},; 	// Codigo da condicao de pagamanto*
									{"C5_MOEDA"  	,	cMoeda								,Nil},; 	// Moeda
									{"C5_TPFRETE"  	,	cTipoFrete							,Nil},; 	// Tipo de Frete
									{"C5_MDCONTR"	,	cContra								,Nil},;		// Cod. do Contrato
									{"C5_MDNUMED"	,	cNumMed								,Nil},;		// Codigo da Medicao
									{"C5_MDPLANI"	,	cNumPlan							,Nil}}		// Numero da Planilha	

							If !Empty (cCodEdt) .And. !Empty(cNumPro)
								aAdd(aCab	,{"C5_CODED"	,cCodEdt						,NIL}) // Código do Edital
								aAdd(aCab	,{"C5_NUMPR"	,cNumPro						,NIL}) // Número do Processo
							EndIf								
							cNatPV := GetNatPV(oModel, aQuebraEnv[nA,2], aQuebraEnv[nA,3], cNumPlan)//Obtem natureza para geracao do pedido de venda.
							
							If(!Empty(cNatPV))								
								aAdd(aCab,{"C5_NATUREZ", cNatPV, Nil})							
							EndIf
							
							If (cPaisLoc == "MEX" .And. FindFunction('LoCnta120'))
								aCab := LoCnta120("Grv120", aCab)//LoCnta120 localizada en LOCXMEX.PRW
							EndIf

							If cPaisLoc == "BRA"
								If !Empty(aLocAtend[1])
									aAdd(aCab,{"C5_MUNPRES",aLocAtend[1],NIL}) // Municipio de Prestacao
								EndIf

								If !Empty(aLocAtend[2])
									aAdd(aCab,{"C5_RECISS",aLocAtend[2],NIL}) // Recolhe ISS?
								EndIf

								If !Empty(aLocAtend[3])
									aAdd(aCab,{"C5_ESTPRES",aLocAtend[3],NIL}) // Estado de Prestacao
								EndIf

								If cMoeda != 1
									If lTxMoeda .And. CND->CND_TXMOED > 0
										aAdd( aCab, { "C5_TXMOEDA", CND->CND_TXMOED, NIL } )
									Else
										aAdd( aCab, { "C5_TXMOEDA", xMoeda(1,cMoeda,1,dDataBase,TamSx3("C5_TXMOEDA")[2],,), NIL } ) //Taxa de Conversao
									EndIf
								EndIf
							EndIf

							If cPaisLoc == 'RUS'
				   				aAdd(aCab,{"C5_CONUNI",CND->CND_CONUNI,NIL}) // Conventional unit
				   				If !EMPTY(AllTrim(oModelCXN:GetValue('CXN_CONTRA')))
				   					aAdd(aCab,{"C5_F5QUID",Posicione("CNA",1,XFILIAL("CNA")+oModelCXN:GetValue('CXN_CONTRA')+oModelCXN:GetValue('CXN_REVISA')+oModelCXN:GetValue('CXN_NUMPLA'),"CNA_F5QUID"),NIL}) // Legal Contracts
									aAdd(aCab,{"C5_F5QCODE",Posicione("F5Q",1,XFILIAL("F5Q")+aCab[Ascan(aCab,{|x| x[1] == "C5_F5QUID" })][2],"F5Q_CODE"),NIL}) // Legal Contracts Code
								EndIf
							EndIf
							
							LoadVendrs(oModelCNU, @aCab, 'C5_VEND' , 'C5_COMIS')//Carrega Vendedores

							If Posicione('SE4',1,xFilial('SE4')+cCondPgto,'E4_TIPO') == '9' //Preenche as Parcelas e Vencimentos  se condição de pagamento for do tipo 9								
								If !CXNParcTp9()
									GetParcPV("CND", @aCab)
								Else
									nNumInd:= aScan(aCab, {|x| AllTrim(x[1]) == "C5_MDPLANI"})
									cNumPla:= aCab[nNumInd][2]
									nNumPla:= MTFindMVC(oModel:GetModel("CXNDETAIL"),{{"CXN_NUMPLA",cNumPla}})
									oModel:GetModel("CXNDETAIL"):GoLine(nNumPla)
									CXN->(DBGoto(oModel:GetModel("CXNDETAIL"):GetDataID()))
									GetParcPV("CXN", @aCab)
								EndIf
							EndIf
							
						Case aDocs[nPosDoc][1] == '4' // Titulo a receber
							
							//- Monta a Cab
							
							cNumCab := CriaVar('E1_NUM',.T.)
							
							If Empty(cNumCab)								
								cNumCab := A121SeqTit("SE1","E1_NUM",,cCNPREMD, oModel)
							EndIf

							aCab:={{"E1_CLIENTE"	,aQuebraEnv[nA][2]					,NIL},; // [1] Cliente
									{"E1_LOJA"		,aQuebraEnv[nA][3]					,NIL},; // [2] Loja do Cliente
									{"E1_ORIGEM"	,"CNTA121"							,NIL},; // [3] Origem
									{"E1_EMISSAO"	,dDataBase							,NIL},; // [4] Emissão
									{"E1_VENCTO" 	,IIf(dDtVencPl > dDataBase, dDtVencPl , dDataBase) ,NIL},; // [5] Vencimento
									{"E1_VENCREA"	,IIf(dDtVencPl > dDataBase, dDtVencPl , dDataBase) ,NIL},; // [6] Vencimento Real
									{"E1_VENCORI"	,IIf(dDtVencPl > dDataBase, dDtVencPl , dDataBase) ,NIL},; // [7] Vencimento Origem
									{"E1_MOEDA"  	,cMoeda								,NIL},; // [8] Moeda
									{"E1_MDCONTR"	,cContra							,NIL},; // [9] Numero do Contrato
									{"E1_MDREVIS"	,cRevisa							,NIL},; // [10]Revisão do Contrato
									{"E1_MEDNUME"	,cNumMed							,NIL},; // [11]Numero da Medição
									{"E1_MDPLANI"	,cNumPlan 							,NIL},; // [12]Numero da planilha
									{"E1_VALOR"		,0									,NIL},; // [13]Valor do Titulo
									{"E1_ACRESC"	,0									,NIL},; // [14]Acrescimos do Titulo
									{"E1_DECRESC"	,0                              	,NIL},; // [15]Decrescimos do Titulo
									{"E1_NUM"		,cNumCab							,NIL},; // [16]Numero do Titulo
									{"E1_MDCRON"	,cMdcron							,NIL},;	// [17]Numero do Cronograma
									{"E1_MDPARCE"	,cMdparce							,NIL},;	// [18] Numero da Parcela
									{"E1_MDDESC"	,0									,NIL},;	// [19] Desconto da medição
									{"E1_MDMULT"	,0									,NIL},;	// [20] Multa da medição
									{"E1_MDBONI"	,0									,NIL},;	// [21] Bonificação da medição
									{"E1_BASEIRF"	,0									,NIL}}  //[22] Base para calculo IRRF
						
							
							//Carrega Vendedores
							LoadVendrs(oModelCNU, @aCab, 'E1_VEND', 'E1_COMIS')
							
							CnGetMNat( oModel , @aCab , 'E1' )
														
					EndCase

					//Multa e Bonificação da Planilha a ser considerada zera o valor da multa para recalcular o próximo item
					nMultBonPla	:= 0
					nMultBonIt	:= 0
					nVlItMulBon	:= 0
					nVlPlMulBon	:= 0

					For nCNR1 := 1 To oModelCNR1:Length()
						oModelCNR1:GoLine(nCNR1)
						If oModelCNR1:GetValue("CNR_FLGPED") == "1"
							If oModelCNR1:GetValue("CNR_TIPO") == "1"//1=Multa;2=Bonificaçao
								nMultBonPla	-= oModelCNR1:GetValue("CNR_VALOR")
								aMultBoni[1]+= oModelCNR1:GetValue("CNR_VALOR")
							Else
								nMultBonPla	+= oModelCNR1:GetValue("CNR_VALOR")
								aMultBoni[2]+= oModelCNR1:GetValue("CNR_VALOR")
							EndIf
						EndIf
					Next nCNR1

					//Modifica Acréscimo ou decréscimo do valor de acordo com o contrato de compra ou venda
					nMultBonPla := nMod * nMultBonPla
					nDifValor 	:= 0
					
					For nY := 1 To Len(aQuebraEnv[nA][6][nX][4]) // Roda por Produto de servico
						lProdServ := !(Empty(aQuebraEnv[nA][6][nX][4][nY][1])) // Quando preenchido tem que aglutinar
						If lProdServ
							aAdd(aItem,{})
							aSize(aRatServ,0)
							aRatServ := {}
							nPosItem := Len(aItem)
							cItemDetail := Soma1(cItemDetail)
							
							SB1->(DBSetOrder(1))
							SB1->(DbSeek(xFilial("SB1")+aQuebraEnv[nA][6][nX][4][nY][1]))

							nQuantArred := aQuebraEnv[nA][6][nX][4][nY][2][1][2] //Produto de servico deve pegar a quantidade existente no array
							
							CNB->(DbSetOrder(1))//CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM
							CNB->(DbSeek(xFilial("CNB", cFilCtr)+oModelCND:GetValue("CND_CONTRA")+oModelCND:GetValue("CND_REVISA")+oModelCXN:GetValue("CXN_NUMPLA")+oModelCNE:GetValue("CNE_ITEM") ))

							If aDocs[nPosDoc][1] == '1' // pedido de Compra

								cLocPad := RetFldProd(SB1->B1_COD,"B1_LOCPAD")								

								aAdd(aItem[nPosItem]	,{"C7_ITEM"		,cItemDetail						,NIL})	//Item
								aAdd(aItem[nPosItem]	,{"C7_PRODUTO"	,aQuebraEnv[nA][6][nX][4][nY][1]	,NIL}) //Produto
								aAdd(aItem[nPosItem]	,{"C7_DESCRI"	,SB1->B1_DESC						,NIL}) //Descricao
								aAdd(aItem[nPosItem]	,{"C7_QUANT"	,1									,NIL}) //Quantidade
								aAdd(aItem[nPosItem]	,{"C7_QTDSOL"	,1									,NIL})	//Quantidade solicitada
								aAdd(aItem[nPosItem]	,{"C7_UM"		,SB1->B1_UM							,NIL}) //Unidade de Medida
								aAdd(aItem[nPosItem]	,{"C7_QTSEGUM"	,ConvUm(SB1->B1_COD,nQuantArred,0,2),NIL})	//Segunda unidade de medida
								aAdd(aItem[nPosItem]	,{"C7_PRECO"	,0									,NIL}) //Preco unitario
								aAdd(aItem[nPosItem]	,{"C7_IPI"		,SB1->B1_IPI						,NIL}) //IPI
								aAdd(aItem[nPosItem]	,{"C7_DATPRF"	,dDataBase							,NIL}) //Data de entrega
								aAdd(aItem[nPosItem]	,{"C7_LOCAL"	,cLocPad							,NIL}) //Local de Estoque
								aAdd(aItem[nPosItem]	,{"C7_TES"		,""									,Nil}) // TES
								aAdd(aItem[nPosItem]	,{"C7_ITEMED"	,""									,Nil}) //Item da Medicao
								aAdd(aItem[nPosItem]	,{"C7_VLDESC"	,0									,NIL}) //Desconto Item
								aAdd(aItem[nPosItem]	,{"C7_CC"		,""									,NIL}) //Centro de custo
								aAdd(aItem[nPosItem]	,{"C7_CONTA"	,""									,NIL}) //Conta
								aAdd(aItem[nPosItem]	,{"C7_ITEMCTA"	,""									,NIL}) //Item de conta
								aAdd(aItem[nPosItem]	,{"C7_CLVL"		,""									,NIL})	//Classe de valor
								aAdd(aItem[nPosItem]	,{"C7_CONTRA"	,cContra							,NIL})	//
								aAdd(aItem[nPosItem]	,{"C7_CONTREV"	,cRevisa							,NIL})	//
								aAdd(aItem[nPosItem]	,{"C7_PLANILH"	,cNumPlan							,NIL})	//
								aAdd(aItem[nPosItem]	,{"C7_MEDICAO"	,cNumMed							,NIL})	//
								aAdd(aItem[nPosItem] 	,{"C7_OBS"		,oModelCND:GetValue("CND_OBS")		,Nil})	//Observação

								If !Empty (cCodEdt) .And. !Empty(cNumPro)
									aAdd(aItem[nPosItem]	,{"C7_CODED"	,cCodEdt						,NIL}) // Código do Edital
									aAdd(aItem[nPosItem]	,{"C7_NUMPR"	,cNumPro						,NIL}) // Número do Processo
									aAdd(aItem[nPosItem]	,{"C7_FILEDT"	,cFilEdt						,NIL}) // Filial do Edital
								EndIf

								//Não permitir Nota de empenho e solicitações de compra para produto de servico
								aAdd(aItem[nPosItem]	,{"C7_CODNE"	,""									,NIL}) //Código da nota de empenho
								aAdd(aItem[nPosItem]	,{"C7_ITEMNE" 	,""									,NIL}) //Item da Nota de empenho
								aAdd(aItem[nPosItem]	,{"C7_FISCORI"	,""									,NIL}) //Filial de origem da SC

								For nB := 1 To Len(aCTBEnt) //Entidades Contabeis
									If SC7->(FieldPos("C7_EC"+aCTBEnt[nB]+"CR")) > 0 .And. CNE->(FieldPos("CNE_EC"+aCTBEnt[nB]+"CR")) > 0
											aAdd(aItem[nPosItem]	,{"C7_EC"+aCTBEnt[nB]+"CR"	,oModelCNE:GetValue("CNE_EC"+aCTBEnt[nB]+"CR")	,NIL}) //Entidades Contabeis Credito
											aAdd(aItem[nPosItem]	,{"C7_EC"+aCTBEnt[nB]+"DB"	,oModelCNE:GetValue("CNE_EC"+aCTBEnt[nB]+"DB")	,NIL}) //Entidades Contabeis Debito
									EndIf
								Next nB							
								
							ElseIf aDocs[nPosDoc][1] == '2' // pedido de venda

								cLocPad := RetFldProd(SB1->B1_COD,"B1_LOCPAD")
					
								aAdd(aItem[nPosItem]	,{"C6_NUM"		,cNumCab							,Nil}) // Numero do Pedido
								aAdd(aItem[nPosItem]	,{"C6_ITEM"		,cItemDetail						,Nil}) // Numero do Item no Pedido
								aAdd(aItem[nPosItem]	,{"C6_PRODUTO"	,aQuebraEnv[nA][6][nX][4][nY][1]	,Nil}) // Codigo do Produto
								aAdd(aItem[nPosItem]	,{"C6_DESCRI"	,SB1->B1_DESC						,Nil}) // Descricao
								aAdd(aItem[nPosItem]	,{"C6_QTDVEN"	,1									,Nil}) // Quantidade Vendida
								aAdd(aItem[nPosItem]	,{"C6_PRUNIT"	,0									,Nil}) // PRECO DE LISTA
								aAdd(aItem[nPosItem]	,{"C6_PRCVEN"	,0									,Nil}) // Preco Unitario Liquido
								aAdd(aItem[nPosItem]	,{"C6_ENTREG"	,dDataBase							,Nil}) // Data da Entrega
								aAdd(aItem[nPosItem]	,{"C6_UM"		,SB1->B1_UM							,Nil}) // Unidade de Medida Primar.
								aAdd(aItem[nPosItem]	,{"C6_CLI"		,aQuebraEnv[nA][2]					,Nil}) // Cliente
								aAdd(aItem[nPosItem]	,{"C6_LOJA"		,aQuebraEnv[nA][3]					,Nil}) // Loja do Cliente
								aAdd(aItem[nPosItem]	,{"C6_TES"		,''									,Nil}) // TES
								aAdd(aItem[nPosItem]	,{"C6_LOCAL"	,cLocPad							,Nil}) // Local de Estoque
								aAdd(aItem[nPosItem]	,{"C6_ITEMED"	,''									,Nil}) // Item da Medicao
								aAdd(aItem[nPosItem]	,{"C6_VALDESC"	,nVlItDesc							,Nil}) // Desconto Item ZERADO PRODUTO DE SERVIÇO
								aAdd(aItem[nPosItem]	,{"ITENS_AGLUT"	,{ }						        ,Nil}) // Itens Aglutinados na Medição

								If lProdServ
									aAdd(aItem[nPosItem]	,{"C6_CC"		,""									,NIL}) //Centro de custo
									aAdd(aItem[nPosItem]	,{"C6_CONTA"	,""									,NIL}) //Conta Contábil
									aAdd(aItem[nPosItem]	,{"C6_ITEMCTA"	,""									,NIL}) //Item de conta
									aAdd(aItem[nPosItem]	,{"C6_CLVL"		,""									,NIL}) //Classe de valor
								EndIf
								
								For nB := 1 To Len(aCTBEnt) //Entidades Contabeis
									If SC6->(FieldPos("C6_EC"+aCTBEnt[nB]+"CR")) > 0 .And. CNE->(FieldPos("CNE_EC"+aCTBEnt[nB]+"CR")) > 0
										aAdd(aItem[nPosItem]	,{"C6_EC"+aCTBEnt[nB]+"CR"	,oModelCNE:GetValue("CNE_EC"+aCTBEnt[nB]+"CR")	,NIL}) //Entidades Contabeis Credito
										aAdd(aItem[nPosItem]	,{"C6_EC"+aCTBEnt[nB]+"DB"	,oModelCNE:GetValue("CNE_EC"+aCTBEnt[nB]+"DB")	,NIL}) //Entidades Contabeis Debito
									EndIf
								Next nB

								//Preenche ARRAYS com dados sobre aposentadoria especial REINF
								If	lAposEsp			
									aAdd(aItemApo , { cItemDetail ,oModelCNE:GetValue("CNE_15ANOS") , oModelCNE:GetValue("CNE_20ANOS") , oModelCNE:GetValue("CNE_25ANOS") })
								Endif 								
								
								If oModelCNE:GetValue("CNE_FLGCMS") == "1" //Verifica se o item e comissionado
									cVend:="1"
									For nB:=1 to oModelCNU:Length()
										oModelCNU:GoLine(nB)
										If	!(Empty(oModelCNU:GetValue("CNU_CODVD"))) //Complementa as comissoes de acordo com os contratos
											aAdd(aItem[nPosItem]	,{"C6_COMIS"+cVend,oModelCNU:GetValue("CNU_PERCCM"),NIL})
											cVend:=Soma1(cVend)
										EndIf
									Next nB
								EndIf
							EndIf
						EndIf												
						
						For nZ := 1 To Len(aQuebraEnv[nA][6][nX][4][nY][2])
							//Posiciona CNE
							oModelCNE:GoLine(MtFindMVC(oModelCNE,{{"CNE_ITEM",aQuebraEnv[nA][6][nX][4][nY][2][nZ][1]}}))
							
							If lProdServ .And. aDocs[nPosDoc][1] == '2'
								nItemAglut := aScan(aItem[nPosItem],{|x| x[1] == "ITENS_AGLUT"} )
								If nItemAglut > 0
									aAdd(aItem[nPosItem][nItemAglut][2], oModelCNE:GetValue("CNE_ITEM"))
								EndIf
							EndIf
							
							If oModelCNE:GetValue('CNE_VLUNIT') > 0
								//Posiciona SB1
								DbSelectArea("SB1")
								SB1->(DBSetOrder(1))
								SB1->(DbSeek(xFilial("SB1")+oModelCNE:GetValue("CNE_PRODUT")))
	
								//Atualiza Valores
								nQuantOri	:= oModelCNE:GetValue("CNE_QUANT")  * nParte
								nPrecoOri	:= oModelCNE:GetValue("CNE_VLUNIT")
								nValorOri	:= oModelCNE:GetValue("CNE_VLTOT") * nParte
	
								//Multa e Bonificação do Item a ser considerado
								nMultBonIt := 0
								For nCNR2 := 1 To oModelCNR2:Length()
									oModelCNR2:GoLine(nCNR2)
									If oModelCNR2:GetValue("CNR_FLGPED") == "1"
										If oModelCNR2:GetValue("CNR_TIPO") == "1" //1=Multa;2=Bonificaçao
											nMultBonIt	-= oModelCNR2:GetValue("CNR_VALOR")
											aMultBoni[1]+= oModelCNR2:GetValue("CNR_VALOR")
										Else
											nMultBonIt	+= oModelCNR2:GetValue("CNR_VALOR")
											aMultBoni[2]+= oModelCNR2:GetValue("CNR_VALOR")
										EndIf
									EndIf
								Next nCNR2
								//Modifica Acréscimo ou decréscimo do valor de acordo com o contrato de compra ou venda
								nMultBonIt := nMod * nMultBonIt
	
								//-Desconto proporcional ao item aplicado ao item
								nDescPropIt	:= A410Arred( oModelCNE:GetValue("CNE_VLDESC") )
	
								//-Desconto proporcional ao item aplicado a planilha
								nDescPropPl	:= A410Arred( ((oModelCNE:GetValue("CNE_VLTOT") - nDescPropIt) / oModelCXN:GetValue("CXN_VLLIQD")) * nVlrDescPl)
								//-Multa / Bonificação proporcional ao item
								nVlPlMulBon	:= A410Arred( (oModelCNE:GetValue("CNE_VLTOT") / oModelCXN:GetValue("CXN_VLLIQD")) * nMultBonPla )
	
								If cTpRat == '1'
									nVlItDesc		:= nDescPropIt									
									nPrecoOri	-= nDescPropPl / oModelCNE:GetValue("CNE_QUANT")
									nValorOri	-= nDescPropPl
								Else
									nVlItDesc 	:= nDescPropIt + nDescPropPl
								EndIf	
	
								If !lEmDespesa								
									nVlItMulBon	:= nMultBonIt  + nVlPlMulBon
		
									//Proporcionaliza pela qtde de itens
									nVlItMulBon := nVlItMulBon * nParte
									nVlItUnMuB := nVlItMulBon / oModelCNE:GetValue("CNE_QUANT")

									//Atualiza preço com Multas e Bonificações									
									nPrecoOri += nVlItUnMuB
									nValorOri += nVlItMulBon
								EndIf
								
								//-- Arredondamento de acordo com as casas decimais do pedido
								nQuantArred	:= A410Arred( nQuantOri , ( IIF( lCompra , "C7_QUANT" , "C6_QTDVEN") ) )
								nPrecoArred	:= A410Arred( nPrecoOri , ( IIF( lCompra , "C7_PRECO" , "C6_PRUNIT") ) )
								nValorArred	:= A410Arred( nQuantArred * nPrecoArred , ( IIF( lCompra , "C7_TOTAL" , "C6_VALOR") ) )
								
								nDifValor   += nValorArred - nValorOri 
								
								 If ABS(nDifValor) >= 0.01	//--Ajusta o valor total e valor unitario do item
	
								 	nValorArred := A410Arred( nValorArred - nDifValor 		, IIF( lCompra , "C7_TOTAL" , "C6_VALOR" 	) )		//-- Ajusta valor total considerando a diferença de arredondamentos
								 	nPrecoArred	:= A410Arred( nValorArred / nQuantArred 	, IIF( lCompra , "C7_PRECO" , "C6_PRUNIT" 	) )		//-- Ajusta o valor unitario para que multiplicado pela quantidade chegue o mais próximo possível do valo total
								 	nValorarred := A410Arred( nQuantArred * nPrecoArred 	, IIF( lCompra , "C7_TOTAL" , "C6_VALOR"	) ) 	//-- Ajusta o valor 
									
								 	nDifValor   := nValorArred - nValorOri	//-- Recalcula sobra para que seja contabilizada no próximo item 
									
								 	If ABS(nDifValor) >= 0.01 .And. nZ == Len(aQuebraEnv[nA][6][nX][4][nY][2]) //-Quando for o último item e ainda possuir saldo, deve abater a diferença.
								 		nPrecoArred := nValorOri / nQuantOri
								 		nValorArred := A410Arred( nQuantArred * nPrecoArred , ( IIF( lCompra , "C7_TOTAL" , "C6_VALOR") ) ) 
								 	EndIf
	
								 EndIf

								If aDocs[nPosDoc][1] $ '34' //- (3- Titulo a pagar | 4- Titulo a receber)
									//- Totalizador de Titulos
									nTitVlr	+= oModelCNE:GetValue("CNE_VLTOT") * nParte
									nVlrDescIt += oModelCNE:GetValue("CNE_VLDESC") * nParte
									nVlrDescIt += A410Arred((oModelCNE:GetValue("CNE_VLTOT") * nParte)/oModelCXN:GetValue("CXN_VLLIQD") * nVlrAdiant)
																		
									If	lAposEsp	
									
										If	oModelCNE:GetValue("CNE_15ANOS") > 0
											nSoma15a += oModelCNE:GetValue("CNE_15ANOS")
										Endif
								
										If	oModelCNE:GetValue("CNE_20ANOS") > 0
											nSoma20a += oModelCNE:GetValue("CNE_20ANOS")
										Endif
								
										If	oModelCNE:GetValue("CNE_25ANOS") > 0
											nSoma25a += oModelCNE:GetValue("CNE_25ANOS")
										Endif
										
									Endif 								 
									
								ElseIf !lProdServ

									If nPrecoArred > 0 //Quando o preço for zero não adiciona itens
	
										cItemDetail	:= Soma1(cItemDetail) //Adiciona um novo aItem e alimenta
										aAdd(aItem,{}) //Gera item do pedido
										nPosItem 		:= Len(aItem)
	
										If aDocs[nPosDoc][1] == '1' // pedido de Compra

											
											cLocPad := RetFldProd(SB1->B1_COD,"B1_LOCPAD")
	
											DbSelectArea("CNB")
											CNB->(DbSetOrder(1))//CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM
											CNB->(DbSeek(xFilial("CNB", cFilCtr)+oModelCND:GetValue("CND_CONTRA")+oModelCND:GetValue("CND_REVISA")+oModelCXN:GetValue("CXN_NUMPLA")+oModelCNE:GetValue("CNE_ITEM") ))
		
											aAdd(aItem[nPosItem],{"C7_ITEM"		,cItemDetail						,NIL}) //Item
											aAdd(aItem[nPosItem],{"C7_PRODUTO"	,oModelCNE:GetValue("CNE_PRODUT")	,NIL}) //Produto
											aAdd(aItem[nPosItem],{"C7_DESCRI"	,oModelCNE:GetValue("CNE_DESCRI")	,NIL}) //Descricao
											aAdd(aItem[nPosItem],{"C7_QUANT"	,nQuantArred						,NIL}) //Quantidade
											aAdd(aItem[nPosItem],{"C7_QTDSOL"	,nQuantArred						,NIL}) //Quantidade solicitada
											aAdd(aItem[nPosItem],{"C7_UM"		,SB1->B1_UM							,NIL}) //Unidade de Medida
											aAdd(aItem[nPosItem],{"C7_QTSEGUM"	,ConvUm(SB1->B1_COD,nQuantArred,0,2),NIL}) //Segunda unidade de medida
											aAdd(aItem[nPosItem],{"C7_PRECO"	,nPrecoArred						,NIL}) //Preco unitario
											aAdd(aItem[nPosItem],{"C7_IPI"		,SB1->B1_IPI						,NIL}) //IPI
											aAdd(aItem[nPosItem],{"C7_DATPRF"	,oModelCNE:GetValue("CNE_DTENT")	,NIL}) //Data de entrega
											aAdd(aItem[nPosItem],{"C7_LOCAL"	,cLocPad							,NIL}) //Local de estoque 
											aAdd(aItem[nPosItem],{"C7_TES"		,oModelCNE:GetValue("CNE_TE")		,Nil}) // TES
											If cPaisLoc == "RUS"
												aAdd(aItem[nPosItem],{"C7_CF"	,oModelCNE:GetValue("CNE_CF")	 	,Nil}) // Fiscal COde
											EndIf
											aAdd(aItem[nPosItem],{"C7_OBSM"		,oModelCND:GetValue("CND_OBS")		,Nil}) //Observação
											aAdd(aItem[nPosItem],{"C7_ITEMED"	,oModelCNE:GetValue("CNE_ITEM")		,Nil}) //Item da Medicao
											If nVlItDesc > 0
												aAdd(aItem[nPosItem],{"C7_VLDESC"	,nVlItDesc						,NIL}) //Desconto Item
											Endif	
											aAdd(aItem[nPosItem],{"C7_CC"		,oModelCNE:GetValue("CNE_CC")		,NIL}) //Centro de custo 
											aAdd(aItem[nPosItem],{"C7_CONTA"	,oModelCNE:GetValue("CNE_CONTA")	,NIL}) //Conta
											aAdd(aItem[nPosItem],{"C7_ITEMCTA"	,oModelCNE:GetValue("CNE_ITEMCT")	,NIL}) //Item de conta
											aAdd(aItem[nPosItem],{"C7_CLVL"		,oModelCNE:GetValue("CNE_CLVL")		,NIL}) //Classe de valor
											aAdd(aItem[nPosItem],{"C7_CONTRA"	,cContra							,NIL}) //
											aAdd(aItem[nPosItem],{"C7_CONTREV"	,cRevisa							,NIL}) //
											aAdd(aItem[nPosItem],{"C7_PLANILH"	,cNumPlan							,NIL}) //
											aAdd(aItem[nPosItem],{"C7_MEDICAO"	,cNumMed							,NIL}) //
											aAdd(aItem[nPosItem],{"C7_CODNE"	,oModelCNE:GetValue("CNE_CODNE")	,NIL}) //Código da nota de empenho
											aAdd(aItem[nPosItem],{"C7_ITEMNE" 	,oModelCNE:GetValue("CNE_ITEMNE")	,NIL}) //Item da Nota de empenho

											If !Empty (cCodEdt) .And. !Empty(cNumPro)
												aAdd(aItem[nPosItem]	,{"C7_CODED"	,cCodEdt					,NIL}) // Código do Edital
												aAdd(aItem[nPosItem]	,{"C7_NUMPR"	,cNumPro					,NIL}) // Número do Processo
												aAdd(aItem[nPosItem]	,{"C7_FILEDT"	,cFilEdt					,NIL}) // Filial do Edital
											EndIf

											If lFilSC .And. !Empty(CNB->CNB_FILSC) .And. !Empty(CNB->CNB_NUMSC)
												cFilSC := CNB->CNB_FILSC //Filial de origem da SC
                                            Else
                                                cFilSC := cFilScCTR //Filial da SC baseada na Filial do Contrato
											EndIf

											aAdd(aItem[nPosItem],{"C7_FISCORI"	    ,cFilSC	        		    	,NIL}) //Filial de origem da SC

											If !Empty(CNB->CNB_NUMSC) .And. !lPcFilEnt
												aAdd(aItem[nPosItem],{"C7_NUMSC"	,CNB->CNB_NUMSC					,NIL}) //Solicitacao
												aAdd(aItem[nPosItem],{"C7_ITEMSC"	,CNB->CNB_ITEMSC				,NIL}) //Item solicitacao
											EndIf
		
											For nB := 1 To Len(aCTBEnt) //Entidades Contabeis
												If SC7->(FieldPos("C7_EC"+aCTBEnt[nB]+"CR")) > 0 .And. CNE->(FieldPos("CNE_EC"+aCTBEnt[nB]+"CR")) > 0
													aAdd(aItem[nPosItem],{"C7_EC"+aCTBEnt[nB]+"CR"	,oModelCNE:GetValue("CNE_EC"+aCTBEnt[nB]+"CR")	,NIL}) //Entidades Contabeis Credito
													aAdd(aItem[nPosItem],{"C7_EC"+aCTBEnt[nB]+"DB"	,oModelCNE:GetValue("CNE_EC"+aCTBEnt[nB]+"DB")	,NIL}) //Entidades Contabeis Debito
												EndIf
											Next nB
	
										ElseIf aDocs[nPosDoc][1] == '2'// pedido de venda

											cLocPad := RetFldProd(SB1->B1_COD,"B1_LOCPAD")
										
											aAdd(aItem[nPosItem],{"C6_NUM"		,cNumCab							,Nil}) // Numero do Pedido
											aAdd(aItem[nPosItem],{"C6_ITEM"		,cItemDetail						,Nil}) // Numero do Item no Pedido
											aAdd(aItem[nPosItem],{"C6_PRODUTO"	,oModelCNE:GetValue("CNE_PRODUT")	,Nil}) // Codigo do Produto
											aAdd(aItem[nPosItem],{"C6_DESCRI"	,oModelCNE:GetValue("CNE_DESCRI")	,Nil}) // Descricao
											aAdd(aItem[nPosItem],{"C6_QTDVEN"	,nQuantArred						,Nil}) // Quantidade Vendida
											aAdd(aItem[nPosItem],{"C6_PRUNIT"	,nPrecoArred						,Nil}) // PRECO DE LISTA
											aAdd(aItem[nPosItem],{"C6_PRCVEN"	,nPrecoArred						,Nil}) // Preco Unitario Liquido
											aAdd(aItem[nPosItem],{"C6_ENTREG"	,oModelCNE:GetValue("CNE_DTENT")	,Nil}) // Data da Entrega
											aAdd(aItem[nPosItem],{"C6_UM"		,SB1->B1_UM							,Nil}) // Unidade de Medida Primar.
											aAdd(aItem[nPosItem],{"C6_CLI"		,aQuebraEnv[nA][2]					,Nil}) // Cliente
											aAdd(aItem[nPosItem],{"C6_LOJA"		,aQuebraEnv[nA][3]					,Nil}) // Loja do Cliente
										 	aAdd(aItem[nPosItem],{"C6_TES"		,oModelCNE:GetValue("CNE_TS")		,Nil}) // TES
											If cPaisLoc == "RUS"
												aAdd(aItem[nPosItem],{"C6_CF"	,oModelCNE:GetValue("CNE_CF")		,Nil}) // Fiscal Code
											EndIf
											aAdd(aItem[nPosItem],{"C6_LOCAL"	,cLocPad							,Nil}) // Local Estoque
											aAdd(aItem[nPosItem],{"C6_ITEMED"	,oModelCNE:GetValue("CNE_ITEM")		,Nil}) // Item da Medicao
											aAdd(aItem[nPosItem],{"C6_VALDESC"	,nVlItDesc							,Nil}) // Desconto Item
											aAdd(aItem[nPosItem],{"C6_CC"		,oModelCNE:GetValue("CNE_CC")		,Nil}) // Centro de Custo
											aAdd(aItem[nPosItem],{"C6_CONTA"	,oModelCNE:GetValue("CNE_CONTA")	,Nil}) // Conta Contábil
											aAdd(aItem[nPosItem],{"C6_ITEMCTA"	,oModelCNE:GetValue("CNE_ITEMCT")	,Nil}) // Item da Conta Contábil
											aAdd(aItem[nPosItem],{"C6_CLVL"		,oModelCNE:GetValue("CNE_CLVL")		,Nil}) // Classe valor COntabil
											
											For nB := 1 To Len(aCTBEnt) //Entidades Contabeis
												If SC6->(FieldPos("C6_EC"+aCTBEnt[nB]+"CR")) > 0 .And. CNE->(FieldPos("CNE_EC"+aCTBEnt[nB]+"CR")) > 0
													aAdd(aItem[nPosItem]	,{"C6_EC"+aCTBEnt[nB]+"CR"	,oModelCNE:GetValue("CNE_EC"+aCTBEnt[nB]+"CR")	,NIL}) //Entidades Contabeis Credito
													aAdd(aItem[nPosItem]	,{"C6_EC"+aCTBEnt[nB]+"DB"	,oModelCNE:GetValue("CNE_EC"+aCTBEnt[nB]+"DB")	,NIL}) //Entidades Contabeis Debito
												EndIf
											Next nB
											
											//Preenche ARRAYS com dados sobre aposentadoria especial REINF
											If	lAposEsp	
												aAdd(aItemApo , { cItemDetail ,oModelCNE:GetValue("CNE_15ANOS") , oModelCNE:GetValue("CNE_20ANOS") , oModelCNE:GetValue("CNE_25ANOS") })
											Endif 										
											
											If oModelCNE:GetValue("CNE_FLGCMS") == "1" //Verifica se o item e comissionado
												cVend:="1"
												For nB:=1 to oModelCNU:Length()
													oModelCNU:GoLine(nB)
													If	!(Empty(oModelCNU:GetValue("CNU_CODVD"))) //Complementa as comissoes de acordo com os contratos
														aAdd(aItem[nPosItem]	,{"C6_COMIS"+cVend,oModelCNU:GetValue("CNU_PERCCM"),NIL})
														cVend:=Soma1(cVend)
													EndIf
												Next nB
											EndIf
										EndIf

										For nB := 1 to oModelCNZ:Length()
											oModelCNZ:GoLine(nB)
											If !Empty(oModelCNZ:GetValue("CNZ_PERC"))
												If nB == 1
													aAdd(aRateio,Array(2))
													aRateio[len(aRateio)][1] := cItemDetail
													aRateio[len(aRateio)][2] := {}
												EndIf
												nPosRat := len(aRateio)
												aAdd(aRateio[nPosRat][2],{})
		
												If aDocs[nPosDoc][1] == '1' // pedido de Compra
													aAdd(aRateio[nPosRat][2][nB],{"CH_ITEMPD"	,cItemDetail					 ,NIL})
													aAdd(aRateio[nPosRat][2][nB],{"CH_ITEM"		,oModelCNZ:GetValue("CNZ_ITEM")	 ,NIL})
													aAdd(aRateio[nPosRat][2][nB],{"CH_PERC"		,oModelCNZ:GetValue("CNZ_PERC")	 ,NIL})
													aAdd(aRateio[nPosRat][2][nB],{"CH_CC"		,oModelCNZ:GetValue("CNZ_CC")	 ,NIL})
													aAdd(aRateio[nPosRat][2][nB],{"CH_CONTA"	,oModelCNZ:GetValue("CNZ_CONTA") ,NIL})
													aAdd(aRateio[nPosRat][2][nB],{"CH_ITEMCTA"	,oModelCNZ:GetValue("CNZ_ITEMCT"),NIL})
													aAdd(aRateio[nPosRat][2][nB],{"CH_CLVL"		,oModelCNZ:GetValue("CNZ_CLVL")	 ,NIL})
		
													For nCount := 1 To Len(aCTBEnt)
														If SCH->(FieldPos("CH_EC" +aCTBEnt[nCount] +"CR")) > 0 .And. CNZ->(FieldPos("CNZ_EC" +aCTBEnt[nCount] +"CR")) > 0
															aAdd(aRateio[nPosRat][2][nB],{"CH_EC"+aCTBEnt[nCount] +"CR"	, oModelCNZ:GetValue("CNZ_EC"+aCTBEnt[nCount] +"CR")	, NIL})
															aAdd(aRateio[nPosRat][2][nB],{"CH_EC"+aCTBEnt[nCount] +"DB"	, oModelCNZ:GetValue("CNZ_EC"+aCTBEnt[nCount] +"DB")	, NIL})
														EndIf
													Next nCount
		
												ElseIf aDocs[nPosDoc][1] == '2' // pedido de venda
													aAdd(aRateio[nPosRat][2][nB],{"AGG_ITEMPD"	,cItemDetail					 ,NIL})
													aAdd(aRateio[nPosRat][2][nB],{"AGG_ITEM"	,oModelCNZ:GetValue("CNZ_ITEM")	 ,NIL})
													aAdd(aRateio[nPosRat][2][nB],{"AGG_PERC"	,oModelCNZ:GetValue("CNZ_PERC")	 ,NIL})
													aAdd(aRateio[nPosRat][2][nB],{"AGG_CC"		,oModelCNZ:GetValue("CNZ_CC")	 ,NIL})
													aAdd(aRateio[nPosRat][2][nB],{"AGG_CONTA"	,oModelCNZ:GetValue("CNZ_CONTA") ,NIL})
													aAdd(aRateio[nPosRat][2][nB],{"AGG_ITEMCT"	,oModelCNZ:GetValue("CNZ_ITEMCT"),NIL})
													aAdd(aRateio[nPosRat][2][nB],{"AGG_CLVL"	,oModelCNZ:GetValue("CNZ_CLVL")	 ,NIL})
		
													For nCount := 1 To Len(aCTBEnt)
														If AGG->(FieldPos("AGG_EC" +aCTBEnt[nCount] +"CR")) > 0 .And. CNZ->(FieldPos("CNZ_EC" +aCTBEnt[nCount] +"CR")) > 0
															aAdd(aRateio[nPosRat][2][nB],{"AGG_EC"+aCTBEnt[nCount] +"CR"	, oModelCNZ:GetValue("CNZ_EC"+aCTBEnt[nCount] +"CR")	, NIL})
															aAdd(aRateio[nPosRat][2][nB],{"AGG_EC"+aCTBEnt[nCount] +"DB"	, oModelCNZ:GetValue("CNZ_EC"+aCTBEnt[nCount] +"DB")	, NIL})
														EndIf
													Next nCount
												EndIf
											EndIf
										Next nB
									EndIf
								Else
									If aDocs[nPosDoc][1] == '1' // pedido de compra
										aItem[nPosItem][8][2]	+= nValorArred  //-- Preco unitario
										aItem[nPosItem][12][2] 	:= oModelCNE:GetValue("CNE_TE") //-- TES
										aItem[nPosItem][13][2] 	:= oModelCNE:GetValue("CNE_ITEM") //-- Item da Medicao
										aItem[nPosItem][14][2] 	+= nVlItDesc //-- Desconto Item
										aItem[nPosItem][15][2] 	:= oModelCNE:GetValue("CNE_CC") //-- Centro de custo
										aItem[nPosItem][16][2] 	:= oModelCNE:GetValue("CNE_CONTA") //-- Conta
										aItem[nPosItem][17][2] 	:= oModelCNE:GetValue("CNE_ITEMCT") //-- Item de conta
										aItem[nPosItem][18][2] 	:= oModelCNE:GetValue("CNE_CLVL") //-- Classe de valor
									ElseIf aDocs[nPosDoc][1] == '2' // pedido de venda
										//-- Atualiza valores para produto de servico
										aItem[nPosItem][6][2] 	+= nValorArred //-- PRECO DE LISTA
										aItem[nPosItem][7][2] 	+= nValorArred //-- Preco Unitario Liquido
										aItem[nPosItem][12][2] 	:= oModelCNE:GetValue("CNE_TS") //-- TES
										aItem[nPosItem][14][2] 	:= oModelCNE:GetValue("CNE_ITEM") //-- Item da Medicao
										aItem[nPosItem][15][2] 	+= nVlItDesc //-- Desconto Item
										aItem[nPosItem][17][2] 	:= oModelCNE:GetValue("CNE_CC")       //-- Centro de custo
										aItem[nPosItem][18][2] 	:= oModelCNE:GetValue("CNE_CONTA")   //-- Conta Contábil
										aItem[nPosItem][19][2] 	:= oModelCNE:GetValue("CNE_ITEMCT") //-- Item de conta
										aItem[nPosItem][20][2] 	:= oModelCNE:GetValue("CNE_CLVL")  //-- Classe de valor
									EndIf

									//-- //Rateio de Serviço
									If Empty(cCampoECCNZ)//-- Campos de entidades adicionais CNZ
										For nB := 1 To Len(aCTBEnt)
											If CNZ->(FieldPos("CNZ_EC"+aCTBEnt[nB]+"CR")) > 0 .And. CNZ->(FieldPos("CNZ_EC"+aCTBEnt[nB]+"DB")) > 0
												cCampoECCNZ += "CNZ_EC"+aCTBEnt[nB]+"CR|CNZ_EC"+aCTBEnt[nB]+"DB|"
												&(("lEC"+aCTBEnt[nB]) + " := .T.")
											EndIf
										Next nB
									EndIf
									If Empty(cCampoECCNE)//-- Campos de entidades adicionais CNE
										For nB := 1 To Len(aCTBEnt)
											If CNE->(FieldPos("CNE_EC"+aCTBEnt[nB]+"CR")) > 0 .And. CNZ->(FieldPos("CNE_EC"+aCTBEnt[nB]+"DB")) > 0
												cCampoECCNZ += "CNE_EC"+aCTBEnt[nB]+"CR|CNE_EC"+aCTBEnt[nB]+"DB|"
												&(("lEC"+aCTBEnt[nB]) + " := .T.")
											EndIf
										Next nB
									EndIf
									cChaveRat:= "" //-- Limpa a chave antes de comecar
									oModelCNZ:GoLine(1)

									If !Empty(oModelCNZ:GetValue("CNZ_PERC"))// verifica rateio na CNZ, caso nao exista ver CNE
										For nB := 1 to oModelCNZ:Length() // Roda tabela de rateio
											oModelCNZ:GoLine(nB)
											cChaveRat := ""
											For nCount := 1 To Len(aCamposCNZ)// Monta Chave de Busca
												If (aCamposCNZ[nCount][3] $ "CNZ_CC|CNZ_CONTA|CNZ_CLVL")  .Or. (aCamposCNZ[nCount][3] $ cCampoECCNZ) .Or. aCamposCNZ[nCount][3] == "CNZ_ITEMCT"
													cChaveRat +=  oModelCNZ:GetValue(aCamposCNZ[nCount][3])
												EndIf
											Next nCount
		
											If ( nPosRat := aScan(aRatServ,{|x| x[1] == cChaveRat} ) ) == 0 // Procura chave Igual
												// Adiciona uma nova chave.
											 	aAdd(aRatServ,Array(16))//{/*cChave*/,/*cValor1*/,/*CC*/,/*CONTA*/,/*ITEMCT*/,/*CLVL*/,/*05CR*/,/*05DB*/,/*06CR*/,/*06DB*/,/*07CR*/,/*	07DB*/,/*08CR*/,/*08DB*/,/*09CR*/,/*09DB*/})
											 	nPosRat := Len(aRatServ)
											 	aRatServ[nPosRat][1]:= cChaveRat
											 	aRatServ[nPosRat][2]:= 0 //Valor
											 	aRatServ[nPosRat][3]:= oModelCNZ:GetValue("CNZ_CC")
											 	aRatServ[nPosRat][4]:= oModelCNZ:GetValue("CNZ_CONTA")
											 	aRatServ[nPosRat][5]:= oModelCNZ:GetValue("CNZ_ITEMCT")
											 	aRatServ[nPosRat][6]:= oModelCNZ:GetValue("CNZ_CLVL")
											 	aRatServ[nPosRat][7]:= IIF(lEC05,oModelCNZ:GetValue("CNZ_EC05CR"),"")
											 	aRatServ[nPosRat][8]:= IIF(lEC05,oModelCNZ:GetValue("CNZ_EC05DB"),"")
												aRatServ[nPosRat][9]:= IIF(lEC06,oModelCNZ:GetValue("CNZ_EC06CR"),"")
												aRatServ[nPosRat][10]:= IIF(lEC06,oModelCNZ:GetValue("CNZ_EC06DB"),"")
												aRatServ[nPosRat][11]:= IIF(lEC07,oModelCNZ:GetValue("CNZ_EC07CR"),"")
												aRatServ[nPosRat][12]:= IIF(lEC07,oModelCNZ:GetValue("CNZ_EC07DB"),"")
												aRatServ[nPosRat][13]:= IIF(lEC08,oModelCNZ:GetValue("CNZ_EC08CR"),"")
												aRatServ[nPosRat][14]:= IIF(lEC08,oModelCNZ:GetValue("CNZ_EC08DB"),"")
												aRatServ[nPosRat][15]:= IIF(lEC09,oModelCNZ:GetValue("CNZ_EC09CR"),"")
												aRatServ[nPosRat][16]:= IIF(lEC09,oModelCNZ:GetValue("CNZ_EC09DB"),"")
											EndIf
											aRatServ[nPosRat][2] += (nValorArred * oModelCNZ:GetValue("CNZ_PERC") / 100) //Valor
										Next nB
									EndIf
								EndIf
								If nPrecoArred > 0
									//-- Atualiza CXJ
									If IsInCallStack("CN300RevPd")
										oModelCXJ:SeekLine({{"CXJ_NUMPLA",oModelCXN:GetValue("CXN_NUMPLA")},{"CXJ_ITEMPL",oModelCNE:GetValue("CNE_ITEM")}})
									ElseIf !Empty(oModelCXJ:GetValue("CXJ_NUMPLA"))
										oModelCXJ:AddLine()
									EndIf
		
									If aDocs[nPosDoc][1]  $ '34'
										oModelCXJ:SetValue("CXJ_NUMTIT",cNumCab)
									Else
										oModelCXJ:SetValue("CXJ_ITEMPE",cItemDetail)
									EndIf
									oModelCXJ:SetValue("CXJ_NUMPLA",oModelCXN:GetValue("CXN_NUMPLA"))
									oModelCXJ:SetValue("CXJ_ITEMPL",oModelCNE:GetValue("CNE_ITEM"))
									oModelCXJ:SetValue("CXJ_ID",aQuebraEnv[nA][6][nX][2])
									oModelCXJ:SetValue("CXJ_PRTENV",aQuebraEnv[nA][7])
								EndIf
							EndIf
						Next nZ

						//-- Atualiza cabeçalho do Titulo com valores de Acrescimo ou Decrescimo.
						If aDocs[nPosDoc][1]  $ '34' //(3 = Titulo a pagar | 4 = Titulo a receber)
							aCab[13][2]	:= nTitVlr
							aCab[19][2]	:= nVlrDescIt + nDescMedPl //Desconto da medição
							aCab[20][2]	:= nMultMedPl //Multa da medição
							aCab[21][2]	:= nBoniMedPl //Bonificação da medição
							
							nTotDecres := nVlrDescIt + nDescMedPl 
							
							If aDocs[nPosDoc][1] == "3" //Se for título a pagar, gera multa como decréscimo e bonificação como acréscimo
								nTotAcres := nBoniMedPl
								nTotDecres += nMultMedPl																
							Else //Se for título a receber, gera multa como acréscimo e bonificação como decréscimo
								nTotAcres := nMultMedPl
								nTotDecres += nBoniMedPl						
							Endif

							If lCompra //Verifica o campo A2_CALCIRF da SA2 somente se o contrato for do tipo Compra
								lCalcIR := GetAdvFVal("SA2", "A2_CALCIRF", cFilSA2 + aQuebraEnv[nY][2] + aQuebraEnv[nY][3], 1, " ", .T.) <> "2" //Quando o campo A2_CALCIRF = 2 esta como calculo na baixa, o acréscimo e o descréscimo são feitos no financeiro
							Else
								lCalcIR := .T.
							EndIf
							
							//Tratamento de compensação de valores para informar os campos de decréscimo ou acréscimo do título, pois não pode ter valor nesses dois campos ao mesmo tempo
							If nTotAcres > nTotDecres
								aCab[14][2]	:= nTotAcres - nTotDecres //Acréscimo
								nVlrBsIr := nTotAcres - nTotDecres
								If lCalcIR
									aCab[22][2] := nTitVlr + nVlrBsIr //Calculo para o valor Base de IRRF
								EndIf
							ElseIf nTotAcres < nTotDecres
								aCab[15][2]	:= nTotDecres - nTotAcres //Descréscimo
								nVlrBsIr := nTotDecres - nTotAcres
								If lCalcIR
									aCab[22][2] := nTitVlr - nVlrBsIr //Calculo para o valor Base de IRRF
								EndIf
							Else
								aCab[22][2] := nTitVlr
							Endif
						
						EndIf

						//-- Recria Array de Rateio de Servico
						If lProdServ
							nAcumulado := 0
							If Len(aRatServ) > 0
								aAdd(aRateio,Array(2))
								nPosRat := len(aRateio)
								aRateio[nPosRat][1] := cItemDetail
								aRateio[nPosRat][2] := {}
							EndIf
							For nB := 1 to Len(aRatServ)
								aAdd(aRateio[nPosRat][2],{})
								If nB <> Len(aRatServ)
									If lCompra
										nValor := Round(aRatServ[nB][2] / aItem[nPosItem][8][2] * 100 , TamSx3("CH_PERC")[2])
									Else
										nValor := Round(aRatServ[nB][2] / aItem[nPosItem][6][2] * 100 , TamSx3("AGG_PERC")[2] )
									Endif
									nAcumulado += nValor
								Else
									If lCompra
										nValor := Round(100 - nAcumulado , TamSx3("CH_PERC")[2])
									Else
										nValor := Round(100 - nAcumulado , TamSx3("AGG_PERC")[2])
									EndIf
								EndIf
		
								If aDocs[nPosDoc][1] == '1' // pedido de Compra
									aAdd(aRateio[nPosRat][2][nB],{"CH_ITEMPD"		, cItemDetail	, nil})
									aAdd(aRateio[nPosRat][2][nB],{"CH_ITEM"		, StrZero(nB,TamSX3("CNZ_ITEM")[1],0)				, nil})
									aAdd(aRateio[nPosRat][2][nB],{"CH_PERC"		, nValor	, nil})
									aAdd(aRateio[nPosRat][2][nB],{"CH_CC"			, aRatServ[nB][3]	, nil})
									aAdd(aRateio[nPosRat][2][nB],{"CH_CONTA"		, aRatServ[nB][4]	, nil})
									aAdd(aRateio[nPosRat][2][nB],{"CH_ITEMCTA"	, aRatServ[nB][5]	, nil})
									aAdd(aRateio[nPosRat][2][nB],{"CH_CLVL"		, aRatServ[nB][6]	, nil})
									If lEC05
										aAdd(aRateio[nPosRat][2][nB],{"CH_EC05CR"	, aRatServ[nB][7]	, nil})
										aAdd(aRateio[nPosRat][2][nB],{"CH_EC05DB"	, aRatServ[nB][8]	, nil})
									EndIf
									If lEC06
										aAdd(aRateio[nPosRat][2][nB],{"CH_EC06CR"	, aRatServ[nB][9]	, nil})
										aAdd(aRateio[nPosRat][2][nB],{"CH_EC06DB"	, aRatServ[nB][10], nil})
									EndIf
									If lEC07
										aAdd(aRateio[nPosRat][2][nB],{"CH_EC07CR"	, aRatServ[nB][11], nil})
										aAdd(aRateio[nPosRat][2][nB],{"CH_EC07DB"	, aRatServ[nB][12], nil})
									EndIf
									If lEC08
										aAdd(aRateio[nPosRat][2][nB],{"CH_EC08CR"	, aRatServ[nB][13], nil})
										aAdd(aRateio[nPosRat][2][nB],{"CH_EC08DB"	, aRatServ[nB][14], nil})
									EndIf
									If lEC09
										aAdd(aRateio[nPosRat][2][nB],{"CH_EC09CR"	, aRatServ[nB][15], nil})
										aAdd(aRateio[nPosRat][2][nB],{"CH_EC09DB"	, aRatServ[nB][16], nil})
									EndIf
								ElseIf aDocs[nPosDoc][1] == '2' // pedido de venda
									aAdd(aRateio[nPosRat][2][nB],{"AGG_ITEMPD"	, cItemDetail	, nil})
									aAdd(aRateio[nPosRat][2][nB],{"AGG_ITEM"	, StrZero(nB,TamSX3("CNZ_ITEM")[1],0)				, nil})
									aAdd(aRateio[nPosRat][2][nB],{"AGG_PERC"		, nValor 	, nil})
									aAdd(aRateio[nPosRat][2][nB],{"AGG_CC"		, aRatServ[nB][3]	, nil})
									aAdd(aRateio[nPosRat][2][nB],{"AGG_CONTA"		, aRatServ[nB][4]	, nil})
									aAdd(aRateio[nPosRat][2][nB],{"AGG_ITEMCT"	, aRatServ[nB][5]	, nil})
									aAdd(aRateio[nPosRat][2][nB],{"AGG_CLVL"		, aRatServ[nB][6]	, nil})
									If lEC05
										aAdd(aRateio[nPosRat][2][nB],{"AGG_EC05CR"	, aRatServ[nB][7]	, nil})
										aAdd(aRateio[nPosRat][2][nB],{"AGG_EC05DB"	, aRatServ[nB][8]	, nil})
									EndIf
									If lEC06
										aAdd(aRateio[nPosRat][2][nB],{"AGG_EC06CR"	, aRatServ[nB][9]	, nil})
										aAdd(aRateio[nPosRat][2][nB],{"AGG_EC06DB"	, aRatServ[nB][10], nil})
									EndIf
									If lEC07
										aAdd(aRateio[nPosRat][2][nB],{"AGG_EC07CR"	, aRatServ[nB][11], nil})
										aAdd(aRateio[nPosRat][2][nB],{"AGG_EC07DB"	, aRatServ[nB][12], nil})
									EndIf
									If lEC08
										aAdd(aRateio[nPosRat][2][nB],{"AGG_EC08CR"	, aRatServ[nB][13], nil})
										aAdd(aRateio[nPosRat][2][nB],{"AGG_EC08DB"	, aRatServ[nB][14], nil})
									EndIf
									If lEC09
										aAdd(aRateio[nPosRat][2][nB],{"AGG_EC09CR"	, aRatServ[nB][15], nil})
										aAdd(aRateio[nPosRat][2][nB],{"AGG_EC09DB"	, aRatServ[nB][16], nil})
									EndIf
								EndIf
							Next nB
						EndIf
					Next nY

					//-- Chama ponto de entrada para tratamento de campos especificos na geracao do pedido de compra / venda
					If lCN121PED
						aRet := ExecBlock("CN121PED",.f.,.f.,{aCab,aItem})
						If Valtype(aRet) == "A"
							aCab := aRet[1]
							aItem := aRet[2]
						EndIf
					EndIf
			
					//Prepara ARRAY aAposEsp (Aposentadoria Especial REINF)unificando dados do aItemApo	
				    For nAp:= 1 to Len(aItemApo)
				     
				        aLinhApo := {}
				     	 
				     	aAdd(aLinhApo , { aItemApo[nAp,1] , aItemApo[nAp,2], aItemApo[nAp,3], aItemApo[nAp,4] } ) 
				     	aAdd(aAposEsp , { aItemApo[nAp,1], aLinhApo } )
				     
				    Next nAp
			

					If	( nSoma15a + nSoma20a + nSoma25a ) > 0   
						
						//Prepara ARRAY para complemento de titulo (FKF)							
						aSeFKF := { { "FKF_TPSERV", oModelCNE:GetValue("CNE_TPSERV") , NIL }} 
							
						//Prepara ARRAY para complemento de impostos x titulos (FKG)
						If	nSoma15a > 0 	
											
							nItemFKG ++
								
							aItemFKG := {{ "FKG_ITEM"  , StrZero(nItemFKG,6) 	, NIL },;
				 						 { "FKG_IDFKE" , cMDAP15			 	, NIL },; 
										 { "FKG_DESCR" , STR0167				, NIL },; 
										 { "FKG_BASECA", nSoma15a				, NIL }}
					 										 
							aAdd(aSeFKG,aItemFKG)			 										 
								
						Endif
										
						If	nSoma20a > 0 	
										
							nItemFKG ++
			
							aItemFKG := {{ "FKG_ITEM"  , StrZero(nItemFKG,6)		, NIL },;
										 { "FKG_IDFKE" , cMDAP20				 	, NIL },; 
										 { "FKG_DESCR" , STR0168					, NIL },;
										 { "FKG_BASECA", nSoma20a  					, NIL }}  
					 										 
							aAdd(aSeFKG,aItemFKG)			 										 
								
						Endif
										
						If	nSoma25a > 0 	
											
							nItemFKG ++
			
							aItemFKG := {{ "FKG_ITEM"  , StrZero(nItemFKG,6) 		, NIL },;
										 { "FKG_IDFKE" , cMDAP25				 	, NIL },; 
										 { "FKG_DESCR" , STR0169			 		, NIL },;
										 { "FKG_BASECA", nSoma25a					, NIL }}  
					 										 
							aAdd(aSeFKG,aItemFKG)			 										 
								
						Endif	
										
					Endif 				

					If 	(lEmDespesa .And.;
						(aDocs[nPosDoc][1] == '1' .Or. aDocs[nPosDoc][1] == '2'))//Pedido : 1=Compras, 2=Venda
					
						PutDespesa(aCab, aDocs[nPosDoc][1], aMultBoni)//Preenche os campos de despesa e desconto no cabeçalho do pedido
					EndIf

					If lCondPgAdt .And. (aDocs[nPosDoc][1] == '1')
						aAdtPC := GetAdtPC(oModelCZY, aQuebraEnv[nA][2], aQuebraEnv[nA][3], aItem) //Adiciona os adiantamentos do pedido de compra(tabela FIE)
					EndIf

					//-- Atualiza aDocs
					aDocs[nPosDoc][2] := aClone(aCab)
					aDocs[nPosDoc][3] := aClone(aItem)
					aDocs[nPosDoc][4] := aClone(aRateio)
					aDocs[nPosDoc][5] := aClone(aSeFKF)
					aDocs[nPosDoc][6] := aClone(aSeFKG)
					aDocs[nPosDoc][7] := aClone(aAposEsp)
					aDocs[nPosDoc][8] := aClone(aAdtPC) //Adiantamentos PC
			
				Next nX
			Next nA
		EndIf
	EndIf
Next nCXN

For nA := 1 To Len(aDocs)//- Chama as rotinas automaticas dos documentos
		
	Do Case
		Case aDocs[nA][1] == '1'  // Pedido de Compra
			//-- Mata120
			If Len(aDocs[nA][3]) > 0					
				MSExecAuto({|v,x,y,z,w,a,p| MATA120(v,x,y,z,w,a,p)},1,aDocs[nA][2],aDocs[nA][3],3,.F.,aDocs[nA][4],aDocs[nA][8])

			EndIf
		Case aDocs[nA][1] == '2'  // Pedido de Venda
			If Len(aDocs[nA][3]) > 0
				//-- Mata410
				MSExecAuto({|x,y,z,w,a| Mata410(x,y,z,,,,,w,,,,,,,a)},aDocs[nA][2],aDocs[nA][3],3,aDocs[nA][4],aDocs[nA][7])										
			EndIf

		Case aDocs[nA][1] $ '34' // Titulos 3- Pagar [E2], 4- Receber [E1]
			//- Popula variaveis para gerar titulo
			lMod 	:= Iif (aDocs[nA][1] == '3',.T.,.F.)

			cRetPrf := PadR(cCNPREMD	,Iif(lMod	,Len(SE2->E2_PREFIXO)	,Len(SE1->E1_PREFIXO)))
			cTpTit 	:= PadR(cCNTPTMD	,Iif(lMod	,Len(SE2->E2_TIPO)		,Len(SE1->E1_TIPO)))
			cRetNat := Cn121NatTt(lMod,aDocs,cFilContr,nA)
			
			If lRet := !Empty(cRetNat)
				If !lNMedTit .Or. nA == 1 //Reinicia a variável apenas se a numeração for sequencial.
					cParcela := StrZero(1,Iif(lMod,Len(SE2->E2_PARCELA),Len(SE1->E1_PARCELA)))
				EndIf
				
				aCond 	:= {{aDocs[nA][2][5][2], aDocs[nA][2][13][2]}}

				If Posicione('SE4', 1, xFilial('SE4') + cCondPgto, 'E4_TIPO') == '9'
					If CXNParcTp9() 
						nNumInd:= aScan(aDocs[nA][2], {|x| AllTrim(x[1]) == Iif(lMod,"E2_MDPLANI","E1_MDPLANI")})
						cNumPla:= aDocs[nA][2][nNumInd][2]
						nNumPla:= MTFindMVC(oModel:GetModel("CXNDETAIL"),{{"CXN_NUMPLA",cNumPla}})
						oModel:GetModel("CXNDETAIL"):GoLine(nNumPla)
						aCond := MedCondTp9(aCond[1,2], aCond[1,1], oModel,"CXN")
					Else
						aCond := MedCondTp9(aCond[1,2], aCond[1,1], oModel)
					EndIf
				ElseIf lGeraCP
					aCond := Condicao(aCond[1,2],cCondPgto,,aCond[1,1])	
				EndIf

				For nB := 1 to Len(aCond)
					aDocs[nA][2][5][2] 	:= aCond[nB,1]
					aDocs[nA][2][6][2]  := DataValida(aCond[nB,1],.T.)
					aDocs[nA][2][7][2]  := DataValida(aCond[nB,1],.T.)
					aDocs[nA][2][13][2] := aCond[nB,2]
							
					If lMod
						if nB == 1
							aAdd( aDocs[nA][2],{"E2_PREFIXO"	,cRetPrf	,NIL})
							aAdd( aDocs[nA][2],{"E2_NATUREZ"	,cRetNat	,NIL})
							aAdd( aDocs[nA][2],{"E2_PARCELA"	,cParcela	,NIL})
							aAdd( aDocs[nA][2],{"E2_TIPO"		,cTpTit		,NIL})
						Else
							aDocs[nA][2] [ascan(aDocs[na][2],{|x| Trim(x[1]) == "E2_PARCELA" })][2] := cParcela
						EndIF
						If	Len(aDocs[nA][5]) > 0 .AND. Len(aDocs[nA][6]) > 0 
							aAdd(aDocs[nA][2],{"AUTCMTIT",aDocs[nA][5],Nil})
							aAdd(aDocs[nA][2],{"AUTCMIMP",aDocs[nA][6],Nil})
						Endif 							
							
						If lTxMoeda .And. CND->CND_TXMOED > 0
							aAdd( aDocs[nA][2], { "E2_TXMOEDA", CND->CND_TXMOED, NIL } )
						EndIf
							
						If lCN121AFN //PE que permite alterar o Array do titulo financeiro ao encerrar a medição.
							aCabUser := ExecBlock("CN121AFN",.F.,.F.,{aDocs[nA][2],"1"})
							If ( ValType(aCabUser) == "A" )
								aDocs[nA][2] := aCabUser
							EndIf
						EndIf
						
						MSExecAuto({|a,b,c| FINA050(a,b,c)} ,aDocs[nA][2],,3)
							
					Else

						If nB == 1
							aAdd( aDocs[nA][2],{"E1_PREFIXO"	,cRetPrf	,NIL})
							aAdd( aDocs[nA][2],{"E1_NATUREZ"	,cRetNat	,NIL})
							aAdd( aDocs[nA][2],{"E1_PARCELA"	,cParcela	,NIL})
							aAdd( aDocs[nA][2],{"E1_TIPO"		,cTpTit		,NIL})
						Else
							aDocs[nA][2] [ascan(aDocs[na][2],{|x| Trim(x[1]) == "E1_PARCELA" })][2] := cParcela
						Endif	
						
						If lTxMoeda .And. CND->CND_TXMOED > 0
							aAdd( aDocs[nA][2], { "E1_TXMOEDA", CND->CND_TXMOED, NIL } )
						EndIf
						
						If lCN121AFN //PE que permite alterar o Array do titulo financeiro ao encerrar a medição.
							aCabUser := ExecBlock("CN121AFN",.F.,.F.,{aDocs[nA][2],"2"})
							If ( ValType(aCabUser) == "A" )
								aDocs[nA][2] := aCabUser
							EndIf
						EndIf

						ProcTitSE1(aDocs[nA,2], aDocs[nA,5], aDocs[nA,6]) //Processa contas à receber(SE1)						
					EndIf

					cParcela := Soma1(cParcela)
					If lMsErroAuto
						Exit
					Else
						C121AtDocs(oModel, aDocs, aOkDocs, nA) //Atualiza aOkDocs.
					EndIf
				Next nB
			EndIf
	EndCase

	If lMsErroAuto
		If !IsBlind() .Or. (FindFunction("At930IsBld") .And. At930IsBld()) 
			MostraErro()
		EndIf
		lRet := .F.
		If (InTransact())
			DisarmTransaction()
		EndIf
		Exit
	ElseIf aDocs[nA][1] $ '1|2'
		C121AtDocs(oModel, aDocs, aOkDocs, nA)	//Atualiza aOkDocs, CNE e CXJ. 
	Endif
Next nA

nTotDocs+= Len(aDocs)
If lRet .And. nTotDocs == 0 .And. nPlanDocs > 0
	lRet:= .F.
	oModel:SetErrorMessage("",,"CXNDETAIL","","CN121GerDoc",STR0231,STR0232) 
EndIf

//Grava retencao da caucao
If lRet .And. !lMsErroAuto .And. !IsExced() .And. !Empty(oModelCND:GetValue('CND_RETCAC'))
	CN121InCau( oModel )
EndIf

FWModelActive(oModel)
RestArea(aAreaCN9)
FwFreeArray(aAreaCN9)

Return lRet
//------------------------------------------------------------------
/*/{Protheus.doc} CN121VlCmp()
Valid do campo competencia
@author alexandre.gimenez
@since 26/08/2015
/*/
//-------------------------------------------------------------------
Function CN121VlCmp()
Local lRet := .T.
Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN121Grids
Limpeza dos grids se usuário muda o contrato
@author rogerio.melonio
@since 24/08/2015
/*/
//-------------------------------------------------------------------
Function CN121Grids( oModel , lDelCXN )
Local aSaveLines:= FWSaveRows()
Local oModelCXN	:= NIL
Local oModelCNE	:= NIL
Local oModelCNR1:= NIL
Local oModelCNR2:= NIL
Local oModelCNK	:= NIL
Local oModelCNZ	:= NIL
Local oModelCXI	:= NIL
Local oModelCXO	:= NIL
Local oModelCXP	:= NIl
Local oModelCNQ	:= NIL
Local oModelCZY	:= NIL

Default oModel := FwModelActive()
Default lDelCXN	:= .T.

oModelCXN	:= oModel:GetModel("CXNDETAIL")
oModelCNE	:= oModel:GetModel("CNEDETAIL")
oModelCNR1	:= oModel:GetModel("CNRDETAIL1")
oModelCNR2	:= oModel:GetModel("CNRDETAIL2")
oModelCNK	:= oModel:GetModel("CNKDETAIL")
oModelCNZ	:= oModel:GetModel("CNZDETAIL")
oModelCXI	:= oModel:GetModel("CXIDETAIL")
oModelCNQ	:= oModel:GetModel("CNQDETAIL")
oModelCZY	:= oModel:GetModel("CZYDETAIL")
oModelCXO	:= oModel:GetModel("CXODETAIL")
oModelCXP	:= oModel:GetModel("CXPDETAIL")

oModelCXN:SetNoDeleteLine(.F.)
oModelCNE:SetNoDeleteLine(.F.)
oModelCNR1:SetNoDeleteLine(.F.)
oModelCNR2:SetNoDeleteLine(.F.)
oModelCNK:SetNoDeleteLine(.F.)
oModelCNZ:SetNoDeleteLine(.F.)
oModelCXI:SetNoDeleteLine(.F.)
oModelCNQ:SetNoDeleteLine(.F.)
oModelCZY:SetNoDeleteLine(.F.)
oModelCXO:SetNoDeleteLine(.F.)
oModelCXP:SetNoDeleteLine(.F.)

If lDelCXN
	CNTA300DlMd(oModelCXN,'CXN_NUMPLA')
EndIf

CNTA300DlMd(oModelCNE,'CNE_PRODUT')
CNTA300DlMd(oModelCNR1,'CNR_VALOR')
CNTA300DlMd(oModelCNR2,'CNR_VALOR')
CNTA300DlMd(oModelCNK,'CNK_CONTRA')
CNTA300DlMd(oModelCNZ,'CNZ_PERC')
CNTA300DlMd(oModelCXI,'CXI_CONTRA')
CNTA300DlMd(oModelCNQ,'CNQ_TPDESC')
CNTA300DlMd(oModelCZY,'CZY_VALOR')
CNTA300DlMd(oModelCXO,'CXO_NATURE')
CNTA300DlMd(oModelCXP,'CXP_PERC')

FWRestRows( aSaveLines )

Return Nil

//------------------------------------------------------------------
/*/{Protheus.doc} CN121PrcMd
Retorna a parcela de uma competência de contrato recorrente
Já está posicionado no CNA da planilha que se quer retornar a parcela.
@author rogerio.melonio
@since 26/08/2015
/*/
//-------------------------------------------------------------------
Function CN121PrcMd(cCompet)
Local cParcela		:= CNA->CNA_PROPAR
Local cCpoParcela	:= ""
Local aParcelas		:= {}
Local nParc			:= 0

cCpoParcela := IIf( Empty(CNA->CNA_FORNEC),"E1_PARCELA","E2_PARCELA" )
aParcelas := CN100ParRc(CNA->CNA_PERIOD,CNA->CNA_QTDREC,CNA->CNA_DIASEM,CNA->CNA_DIAMES,CNA->CNA_PROMED,CNA->CNA_DTINI,CNA->CNA_DTFIM,cCpoParcela,CNA->CNA_PERREC)

For nParc := 1 To Len(aParcelas)
	If Substr(Dtoc(aParcelas[nParc][2]),4) <> cCompet
		Loop
	Endif
	If CNA->CNA_MEDEFE = 0
		cParcela	:= aParcelas[nParc][1]
		Exit
	ElseIf nParc > CNA->CNA_MEDEFE
		cParcela	:= aParcelas[nParc][1]
		Exit
	Endif
Next nParc

Return cParcela

//------------------------------------------------------------------
/*/{Protheus.doc} CN121ClrTt
Limpa os totalizadores do cabeçalho.
@author israel.escorizza
@since 28/08/2015
/*/
//-------------------------------------------------------------------
Function CN121ClrTt()
Local oModel 	:= FwModelActive()
Local oModelCXN	:= oModel:GetModel('CXNDETAIL')
Local nX		:= 0

For nX := 1 to oModelCXN:Length()
	oModelCXN:GoLine(nX)
	If oModelCXN:GetValue('CXN_CHECK') .And. !(oModelCXN:IsDeleted())
		oModelCXN:SetValue('CXN_CHECK',.F.)
	EndIf
Next nX
Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} CN121DfLeg
Define o valor da Legenda.
@author israel.escorizza
@since 28/08/2015
/*/
//-------------------------------------------------------------------
Function CN121Situa(oModel)
	Local lRet 		:= .T.
	Local oModelCND	:= Nil
	Default oModel  := FwModelActive()

	oModelCND := oModel:GetModel("CNDMASTER")

	DO CASE
		CASE	Empty(oModelCND:GetValue("CND_DTFIM"));
				.AND. oModelCND:GetValue("CND_ALCAPR") == 'L';
				.AND. oModelCND:GetValue("CND_SERVIC") == '1';
			 	.AND. oModelCND:GetValue("CND_AUTFRN") == '1'
			oModelCND:SetValue("CND_SITUAC","A") //- Medição em Aberto

		CASE 	Empty(oModelCND:GetValue("CND_DTFIM"));
				.AND. oModelCND:GetValue("CND_ALCAPR") == 'L';
				.AND. oModelCND:GetValue("CND_SERVIC") == '2';
				.AND. oModelCND:GetValue("CND_AUTFRN") == '1'
			oModelCND:SetValue("CND_SITUAC","SA") //- Med. Servic. Aberta

		CASE 	Empty(oModelCND:GetValue("CND_DTFIM"));
				.AND. oModelCND:GetValue("CND_ALCAPR") == 'L';
				.AND. oModelCND:GetValue("CND_SERVIC") == '1';
				.AND. oModelCND:GetValue("CND_AUTFRN") == '2'
			oModelCND:SetValue("CND_SITUAC","FA") //- Aut. Fornec. Aberta

		CASE 	Empty(oModelCND:GetValue("CND_DTFIM"));
				.AND. oModelCND:GetValue("CND_ALCAPR") == 'B'
			oModelCND:SetValue("CND_SITUAC","B") //- Medição Bloqueada

		CASE 	Empty(oModelCND:GetValue("CND_DTFIM"));
				.AND. oModelCND:GetValue("CND_ALCAPR") == 'B';
				.AND. !Empty(oModelCND:GetValue("CND_APROV"))
			oModelCND:SetValue("CND_SITUAC","BA") //- Medição Bloqueada por Alçada

		CASE 	!Empty(oModelCND:GetValue("CND_DTFIM"));
				.AND. oModelCND:GetValue("CND_AUTFRN") == '1';
				.AND. oModelCND:GetValue("CND_SERVIC") == '1'
			oModelCND:SetValue("CND_SITUAC","E") //- Medição Encerrada

		CASE 	!Empty(oModelCND:GetValue("CND_DTFIM"));
				.AND. oModelCND:GetValue("CND_SERVIC") == '2';
				.AND. oModelCND:GetValue("CND_AUTFRN") == '1'
			oModelCND:GetValue("CND_SITUAC","SE") //- Med. Servic. Encerrada

		CASE 	!Empty(oModelCND:GetValue("CND_DTFIM"));
				.AND. oModelCND:GetValue("CND_SERVIC") == '1';
				.AND. oModelCND:GetValue("CND_AUTFRN") == '2'
			oModelCND:SetValue("CND_SITUAC","FE") //- Aut. Fornec. Encerrada
	ENDCASE

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN121MedEnc()
Rotina de processamento do encerramento de medição
@author alexandre.gimenez
@since 01/09/2015
/*/
//-------------------------------------------------------------------
Function CN121MedEnc(nReg,lAviso,lAutoFor,lMedServ, lOnlyExced)
Local oModel		:= Nil
Local aLPGCT		:= {}
Local aErro			:= {}
Local cFilCtr  		:= ""
Local cCronog		:= ""
Local cParcel		:= ""
Local cEspCtr  		:= ""
Local cChave   		:= ""
Local cArqGCT		:= ""   //Arquivo contabilizacao
Local cLancCont		:= ""	// Numero da LP
Local cLPMedEnc		:= ""	// LP de Encerramento da medição(697 ou 698)
Local cBusca		:= ""
Local cSeqPCOLan	:= "" 	 //Sequencia de Lancamento do PCO - 000355t
Local cLoteGCT 		:= LoteCont("COM")  	//Numero do Lote
Local cFilCND  		:= xFilial("CND")
Local cFilCXN		:= xFilial("CXN")
Local cFilCNE		:= xFilial("CNE")
Local cFilCN9  		:= ""
Local cFilCNA  		:= ""
Local cFilCNB  		:= ""
Local cFilCNF		:= ""
Local cFilCNS		:= ""
Local cFilCNZ  		:= xFilial("CNE")
Local cFilCNV		:= ""
Local cChaveCXN		:= ""
Local cOrigem		:= "CNTA121"
Local cGCTxGS		:= '0' //0 = Não verificado; 1=Contrato integrado com GS; 2=Sem Integração
Local cCodTFJ		:= ""
Local nMedLmt   	:= 0 //Limite de medicao do contrato
Local nHead	  		:= 0 		//Retorno da funcao HeadProva
Local nDet  		:= 0     	//Retorno da funcao DetProva
Local nTaxa			:= 0
Local nTamVrCamb	:= TamSX3("CNV_VRCAMB")[2]
Local nTamVlTot		:= TamSX3("CND_VLTOT")[2]
Local nValExced		:= 0
Local nLp69A		:= 0
Local nLp69H		:= 0
Local lRet			:= .T.
Local lMedEve   	:= .F.
Local lFscLmt   	:= .F.
Local lContab   	:= .F.
Local lFixo     	:= .T.
Local lSemiFix		:= .T.
Local lValor    	:= .T.
Local lFisico   	:= .F.
Local lRecorre 		:= .F.
Local lAtuSld  		:= .T. // PE CN121ATS
Local lDigita 		:= .F.    	 				//Mostra lancamento?
Local lAglutina		:= .F.    	 				//Aglutina
Local lPlanComItem	:= .F.
Local lCriaProv		:= AllTrim(SuperGetMV("MV_CNTPPP" ,.F.,"0")) $ "0/1"  // define quando os contratos recorrentes serão provisionados
Local lPeSld   		:= ExistBlock("CN121ESD")
Local lCN121ENC		:= ExistBlock("CN121ENC")//P.E apos o encerramento da medicao

Local lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Local lCtbCNE		:= .F.
Local lTecBAtVlp	:= FindFunction("TecBAtVlpr")
Local aFlagCTB 		:= {}
Local aAreaGS		:= {}
Local lCXNZero 		:= CXN->(ColumnPos('CXN_ZERO')) > 0
Local lCNEDtLanc	:= CNE->(ColumnPos('CNE_DTLANC')) > 0
Local lMultiMed		:= .F.
Local lServico		:= .F.
Local lCNZInd6		:= FWSIXUtil():ExistIndex("CNZ", "6")//Remover esse tratamento quando releases inferiores à 12.1.33 forem descontinuados em definitivo
Local cExpChvCNZ	:= IIF(lCNZInd6, 'CNZ_FILIAL+CNZ_CONTRA+CNZ_REVISA+CNZ_CODPLA+CNZ_ITCONT+CNZ_NUMMED', 'CNZ_FILIAL+CNZ_CONTRA+CNZ_REVISA+CNZ_NUMMED+CNZ_ITCONT')
DEFAULT lAviso   	:= .T.
DEFAULT lAutoFor 	:= CND->CND_AUTFRN == '2'
DEFAULT lMedServ 	:= .F.
Default lOnlyExced	:= .F.

//Estabelece passos
ProcRegua(5)
dbSelectArea("CND")
CND->(MsGoTo(nReg)) //-- Posiciona na medicao

cFilCtr := CND->CND_FILCTR
cFilCN9 := FWxFilial( "CN9", cFilCTR )
cFilCNA := FWxFilial( "CNA", cFilCTR )
cFilCNB := FWxFilial( "CNB", cFilCTR )
cFilCNF := FWxFilial( "CNF", cFilCTR )
cFilCNS := FWxFilial( "CNS", cFilCTR )
cFilCNV := FWxFilial( "CNV", cFilCTR )
cChave := CND->(CND_CONTRA+CND_REVISA+CND_NUMMED)
lMultiMed	:= CN121RetSt("MULTIMED",0,, CND->CND_CONTRA,.F.,Nil, CND->CND_FILCTR)

If !lOnlyExced
	If ExistBlock("CN121ATS")/*Ponto de entrada para indicar se atualiza ou nao saldo da medicao*/
		lAtuSld := ExecBlock("CN121ATS",.F.,.F.)
		If ValType(lAtuSld) <> "L"
			lAtuSld := .T.
		EndIf
	EndIf
EndIf

If LockByName("CN121"+cFilCND+cChave,.T.,!Empty(cFilCND),.T.)
	CN9->(dbSetOrder(1))	

	If (lRet := CN9->(MsSeek(cFilCN9+CND->(CND_CONTRA+CND_REVISA))))

		If !lOnlyExced
			CfgIdMldDoc(MODEL_OPERATION_UPDATE)

			oModel := FwLoadModel('CNTA121')
			oModel:SetOperation(MODEL_OPERATION_UPDATE)

			If (lRet := oModel:Activate())
				If !lAutoFor
					oModel:LoadValue("CNDMASTER","CND_SITUAC","E")
					oModel:LoadValue("CNDMASTER","CND_DTFIM",dDataBase)
				EndIf

				oModel:LoadValue("CNDMASTER","CND_FILMED", cFilAnt)//Grava a filial de encerramento da medicao
				lRet := oModel:VldData() //Deve estar fora da transação p/ que a chamada as funções PcoVldLan não sejam desfeitas
			EndIf
			
		Else
			oModel := FwModelActive()
		Endif
	Else
		Help(" ",1,"REGNOIS")
	EndIf

	If lRet
		cEspCtr := CN9->CN9_ESPCTR
		nTaxa	:= RecMoeda(CND->CND_DTINIC,CN9->CN9_MOEDA)

		Begin Transaction


		IncProc(STR0098)//"Atualizando Medicao e Itens"

		If (lCtbOnLine := IsCtbOnline(@aLPGCT, @cLPMedEnc, @lDigita, @lAglutina))
			nHead	:= HeadProva(cLoteGCT,cOrigem,Subs(cUsuario,7,6),@cArqGCT)
			If nHead <= 0
				If GetRemoteType() != -1
					HELP(" ",1,"SEM_LANC") //"SEM_LANC"
					lRet := .F.
				EndIf
				lCtbOnLine := .F.
			EndIf
		EndIf

		PcoIniLan("000355" , .F.)

		If lRet .And. !lOnlyExced
			lRet := oModel:CommitData() //Apenas o CommitData deve estar dentro da transação
		EndIf

		If lRet
			cChaveCXN := cFilCXN+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMMED
			DbSelectArea("CXN")
			CXN->(DbSetOrder(1))
			CXN->(MsSeek(cFilCXN+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMMED))
			While cChaveCXN == CXN->(CXN_FILIAL+CXN_CONTRA+CXN_REVISA+CXN_NUMMED) .And. !(CXN->(Eof())) .And. lRet
				If !(CXN->CXN_CHECK)
					CXN->(DbSkip())
					Loop
				EndIf			
				
				If lCXNZero //-- Encerramento de planilhas zeradas
					If CXN->CXN_ZERO == '1'
						CN121ZERO( CXN->CXN_CONTRA , CXN->CXN_REVISA , CXN->CXN_NUMMED , CXN->CXN_NUMPLA , cFilCtr , '1')
						CXN->(DbSkip())
						Loop
					EndIf
				EndIf				
				
				lMedEve	:= CN121RetSt("MEDEVE"		,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.T.,oModel)
				lContab	:= CN121RetSt("CONTABIL"	,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.T.,oModel)
				lFixo	:= CN121RetSt("FIXO"		,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.T.,oModel)
				lSemiFix:= CN121RetSt("SEMIFIXO"	,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.T.,oModel)
				lValor	:= CN121RetSt("PREVFINANC"	,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.T.,oModel)
				lFisico	:= CN121RetSt("FISICO"		,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.T.,oModel)
				nMedLmt	:= CN121RetSt("LMTMED"		,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.T.,oModel)
				lFscLmt	:= CN121RetSt("LMTFISICO"	,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.T.,oModel)
				lRecorre:= CN121RetSt("RECORRENTE"	,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.T.,oModel)
				lServico:= CN121RetSt('SERVIÇO'		,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.T.,oModel)
				
				cParcel := CXN->CXN_PARCEL				

				If !lOnlyExced //Não executa quando for processar apenas excedentes...					
					PcoDetLan("000355","03","CNTA120") //-- Ponto lancamento contabil e orcamentario para encerramento da medicao
					If lCtbOnLine
						nDet += DetProva(nHead, cLPMedEnc,cOrigem,cLoteGCT,,,,,,,,,{"CND",CND->(RECNO())})						
					EndIf
				EndIf

				DbSelectArea("CNE")
				CNE->(dbSetOrder(1))
				CNE->(MsSeek(cFilCNE+CND->(CND_CONTRA+CND_REVISA)+CXN->CXN_NUMPLA+CND->CND_NUMMED))
				cCronog := Posicione("CNA",1,cFilCNA+CND->(CND_CONTRA+CND_REVISA)+CXN->CXN_NUMPLA,"CNA_CRONOG")

				If lAtuSld .And. !lPeSld//-- Atualiza itens da planilha
					While CNE->(CNE_FILIAL+CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_NUMMED) == cFilCNE+CND->(CND_CONTRA+CND_REVISA)+CXN->CXN_NUMPLA+CND->CND_NUMMED
						CNB->(dbSetOrder(1))
						lPlanComItem := CNB->(MsSeek(cFilCNB+CNE->(CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_ITEM)))//CAPTURO A VARIAVEL FLAG DE ITENS COM PLANILHA
						If CNE->CNE_EXCEDE == '2'//-- Itens excedentes nao atualizam saldos
							If lOnlyExced //Nesse caso processa apenas os excedentes
								CNE->(dbSkip())
								Loop
							ElseIf(!lMultiMed)								
								If (lPlanComItem)
									UpdSldCNB(lRecorre, lServico, lSemiFix)/*Atualiza o item da planilha(CNB) do contrato*/
								EndIf
								If lFisico
									UpdSldCNS(cFilCNS, cCronog, cParcel)/*Atualiza saldo do cronograma fisico(CNS)*/
								EndIf
							EndIf
						EndIf

						PcoDetLan("000355","04","CNTA120")
						
						If 	lCtbOnLine .And. ;//-- CONTABILIZA ENCERRAMENTO DA MEDICAO - ITENS DO CONTRATO
							(!lOnlyExced .Or.;// Caso nao sejam apenas excedentes OU
							(lOnlyExced .And. lCNEDtLanc .And. Empty(CNE->CNE_DTLANC)))//Sejam apenas excedentes, campo CNE_DTLANC exista e não esteja preenchido
							
							nLp69A	:= aScan(aLPGCT,{|x| x[1]=="69A"})
							nLp69H	:= aScan(aLPGCT,{|x| x[1]=="69H"})

							If lUsaFlag
								aAdd( aFlagCTB, {"CNE_DTLANC", dDataBase, "CNE", CNE->( Recno() ), 0, 0, 0} )
							EndIf

							If aLPGCT[nLp69H,2] .And. cEspCtr == '2' .And. CN9->CN9_DTINIC >= CTOD("01/01/2018") // - Ponto de lançamento padrão IFRS15
								nDet += DetProva(nHead,'69H',cOrigem,cLoteGCT,,,,,,,,@aFlagCTB,{"CNE",CNE->(Recno())})
								lCtbCNE	:= .T.
							ElseIf aLPGCT[nLp69A,2]
								nDet += DetProva(nHead,"69A",cOrigem,cLoteGCT,,,,,,,,@aFlagCTB,{"CNE",CNE->(Recno())})
								lCtbCNE	:= .T.
							EndIf

							If !lUsaFlag .And. lCtbCNE
								If lCNEDtLanc
									dbSelectArea("CNE")
									RecLock("CNE",.F.)
									CNE->CNE_DTLANC := dDataBase
									MsUnlock()
								EndIf
							EndIf
						EndIf
						
						If lPlanComItem
							cLancCont 	:= "69E"
							cSeqPCOLanc	:= "06"
						Else
							cLancCont 	:= "69C"
							cSeqPCOLanc	:= "05"
						Endif						

						//2=CNZ_FILIAL+CNZ_CONTRA+CNZ_REVISA+CNZ_NUMMED+CNZ_ITCONT+CNZ_ITEM
						//6=CNZ_FILIAL+CNZ_CONTRA+CNZ_REVISA+CNZ_CODPLA+CNZ_ITCONT+CNZ_NUMMED
						CNZ->(dbSetOrder(IIF(lCNZInd6,6,2)))
						cBusca := cFilCNZ + IIF(lCNZInd6, CNE->(CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_ITEM+CNE_NUMMED), CNE->(CNE_CONTRA+CNE_REVISA+CNE_NUMMED+CNE_ITEM))						
						If CNZ->(MsSeek( cBusca ))
							While CNZ->( !Eof() .And. &(cExpChvCNZ) == cBusca )
								If !Empty(CNZ->CNZ_CC) .And. (lCNZInd6 .Or. (!lCNZInd6 .And. CNZ->CNZ_CODPLA == CNE->CNE_NUMERO))
									PcoDetLan("000355",cSeqPCOLan,"CNTA120")
									//-- Contabiliza os rateios do item do contrato com planilha.
									//-- Se ha planilha, entao nao podera contabilizar o rateio sem planilha, abaixo (controlar com variavel flag)
									//-- efetua a contabilizacao dos rateios do item do contrato sem planilha,
									If lCtbOnLine
										nDet += DetProva(nHead,cLancCont,"CNTA121",cLoteGCT,,,,,,,,,{"CNZ",CNZ->(Recno())})
									EndIf
								EndIf
								CNZ->(DbSkip())
							EndDo
						EndIf						
						
						CNE->(dbSkip())
					EndDo
				EndIf

				If !lOnlyExced //Se nao for apenas excedentes...					
					IncProc( "Atualizando Saldos" )//"Atualizando Saldos"					
					nValExced := CN120VlExc(CND->CND_CONTRA,CND->CND_REVISA,CND->CND_NUMMED,CXN->CXN_NUMPLA)//Valor total dos itens excedentes da planilha

					CNA->(dbSetOrder(1))
					If CNA->(MsSeek(xFilial("CNA",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA+CXN->CXN_NUMPLA))

						If (lRecorre .And. CNA->CNA_MEDEFE > 0) //-- atualiza campos de controle dos contratos recorrentes no encerramento
							RecLock("CND",.F.)
							CND->CND_RECMED := CNA->CNA_RECMED
							CND->CND_ULTMED := CNA->CNA_ULTMED
							MsUnlock()
						EndIf						

						If lAtuSld .And. !lPeSld .And. !lMultiMed
							UpdSldCNA(lRecorre, lFixo, lSemiFix, lValor, nValExced, nTamVlTot, nTaxa)							
						EndIf						

						If cGCTxGS == "0" .AND. lTecBAtVlp
							aAreaGS := GetArea()							
							TFJ->(DbSetOrder(5)) //TFJ_FILIAL+TFJ_CONTRT+TFJ_CONREV
							If TFJ->(MsSeek(xFilial("TFJ",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA))
								cGCTxGS := "1"
								cCodTFJ := TFJ->TFJ_CODIGO
							Else
								cGCTxGS := "2"
							EndIf
							RestArea(aAreaGS)
							FwFreeArray(aAreaGS)
						ElseIf(cGCTxGS != "1")
							cGCTxGS := "2"
						EndIf
						If lTecBAtVlp .AND. cGCTxGS == "1"
							TecBAtVlpr(cFilCTR, cCodTFJ, CND->CND_CONTRA, CND->CND_REVISA, CNA->(Recno()))
						EndIf

					EndIf					

					If lAtuSld .And. !lPeSld .And. !lRecorre .And. !lMultiMed
						DbSelectArea("CN9")
						CN9->(dbSetorder(1))
						If CN9->(MsSeek(cFilCN9+CND->CND_CONTRA+CND->CND_REVISA))
							UpdSldCN9(lFixo, lSemiFix, lValor, nValExced, nTamVlTot, nTaxa, lRecorre)//-- Atualiza saldo do contrato se nao recorrente
						EndIf

						If !lMedEve							
							UpdSldCNF(cCronog, nValExced, nTamVlTot, .F., /*lTitProv*/, lServico)							
						EndIf
					EndIf

					If lRecorre
						If !lMultiMed
							TitProvRec(lCriaProv)//-- Exclui titulo provisorio da parcela atual							
						EndIf
					ElseIf(!lMedEve .And. lContab)//-- Atualiza saldo do cronograma contabil quando nao houver medicao eventual e nao seja recorrente
						dbSelectArea("CNV")
						dbSetOrder(2)

						If MsSeek(cFilCNV+CND->CND_CONTRA+CND->CND_REVISA+CXN->CXN_NUMMED)
							nVlOr := xMoeda(CXN->CXN_VLLIQD - nValExced,CN9->CN9_MOEDA,1,dDataBase,nTamVrCamb,CNV->CNV_TXMOED)
							nVlAtu:= xMoeda(CXN->CXN_VLLIQD - nValExced,CN9->CN9_MOEDA,1,dDataBase,nTamVrCamb)
							RecLock("CNV",.F.)
								CNV->CNV_VRCAMB += nVlAtu-nVlOr
							MsUnlock()
						EndIf
					EndIf					
				EndIf
				CXN->(DbSkip())
			EndDo

		EndIf

		If !lOnlyExced
			If lPeSld
				ExecBlock("CN121ESD",.F.,.F.,{lMedEve,lFisico,cCronog,lFixo,lValor})//Chama ponto de entrada para atualizacao do saldo
			EndIf

			If lCN121ENC
				ExecBlock("CN121ENC",.F.,.F.,{.T., lRet})//chamada dentro da transação do P.E
			EndIf
		EndIf

		If !lRet
			DisarmTransaction()
		Else
			If lCtbOnLine
				RodaProva(nHead,nDet)				
			EndIf
			PcoFinLan("000355",/*lForceVis*/, /*lProc*/, .F.)
		EndIf

		End Transaction
		
		If (lRet .And. lCtbOnLine .And. nDet > 0)
			cA100Incl(cArqGCT,nHead,1,cLoteGCT,lDigita,lAglutina,,,,@aFlagCTB)//Deve ser chamada fora da transação necessariamente.
			aFlagCTB := {}
		EndIf

		If !lOnlyExced .And. lCN121ENC
			ExecBlock("CN121ENC",.F.,.F.,{.F., lRet})//chamada FORA da transação do P.E
		EndIf
	EndIf

	If(!lRet .And. oModel:HasErrorMessage())
		aErro := oModel:GetErrorMessage()			
		Help(NIL, NIL, AllTrim(aErro[MODEL_MSGERR_ID]), NIL, aErro[MODEL_MSGERR_MESSAGE], 1, 0, NIL, NIL, NIL, NIL, NIL, {aErro[MODEL_MSGERR_SOLUCTION]})
	EndIf
	ResetIdDoc()//Restaura submodelos dos documentos
Else
	// Nao permite processamento concorrente
	Aviso(STR0159,OemtoAnsi(STR0100),{STR0156},2) // ##"Concorrência"##"Esta Medição está em uso por outra estação."
EndIf

UnLockByName("CN121"+cFilCND+cChave,.T.,!Empty(cFilCND),.T.)

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} Cn121RetSt
Retorna a propriedade do contrato chamado pelo gatilho dos campos da tabela CNE
quando chamada pela CNTA260
@author rogerio.melonio
@since 02/09/2015
/*/
//-------------------------------------------------------------------
Function Cn121RetSt( cProp, nModo, cPlan, cContra, lModel, oModel, cFilCtr )
	Local xRet 			:= .F.
	Local oModelCND 	:= Nil
	Local oModelCXN 	:= Nil
	Local cFindId		:= ""
	Default cContra := ""
	Default cPlan 	:= ""
	Default nModo 	:= 0
	Default lModel 	:= .T.
	Default oModel 	:= Nil
	Default cFilCtr := ""

	If FwIsInCallStack("CNTA120") .And. IsNotTEC930()
		xRet := CN300RetSt(cProp,nModo)
	Else
		If lModel
			If oModel == Nil
				oModel := FwModelActive()
			EndIf		
			
			oModelCND := oModel:GetModel("CNDMASTER")

			If Empty(cFilCtr)
				cFilCtr := oModelCND:GetValueByPos(GetPosCpo(oModel, "CND_FILCTR"))
				cFilCtr := IIF(Empty(cFilCtr),cFilAnt,cFilCtr)
			EndIf
			
			If Empty(cContra)
				cContra := oModelCND:GetValueByPos(GetPosCpo(oModel, "CND_CONTRA"))
			EndIF
			
			If Empty(cPlan)
				oModelCXN := oModel:GetModel("CXNDETAIL")
				cPlan := oModelCXN:GetValueByPos(GetPosCpo(oModel, "CXN_NUMPLA"))
			EndIf
					
		Else		
			If Empty(cContra)
				cContra := CND->CND_CONTRA
			EndIf
			
			If Empty(cFilCtr)
				cFilCtr := CND->CND_FILCTR				
			EndIf
		EndIf
		
		cFindId := cProp+cValToChar(nModo)+cPlan+cContra+cFilCtr
		If (_oCtrProps == Nil)
			_oCtrProps := THashMap():New()
		ElseIf _oCtrProps:Get(cFindId, @xRet)
			Return xRet		
		EndIf

		If (cProp == "MOEDACTR")
			xRet := Posicione("CN9",1, xFilial('CN9',cFilCtr) + cContra + CnGetRevAt(cContra,cFilCtr), "CN9_MOEDA")
		Else
			xRet := CN300RetSt( cProp, nModo, cPlan, cContra, cFilCtr )
		EndIf
		_oCtrProps:Set(cFindId, xRet)
	EndIf
Return xRet

//------------------------------------------------------------------
/*/{Protheus.doc} A121Servico
Retorna flag indicando se o contrato é de serviço
@author rogerio.melonio
@since 02/09/2015
/*/
//-------------------------------------------------------------------
Function A121Servico(nModo,cPlan,cContra)
	Local oModel := Nil
	Local lModel := .F.
	Default nModo 	:= 0
	Default cPlan 	:= ""
	Default cContra := ""

	oModel := FwModelActive()
	lModel := ( ValType(oModel) == "O" .And. oModel:IsActive() .And. oModel:GetId() == 'CNTA121' )
Return CN121RetSt('SERVIÇO', nModo, cPlan, cContra, lModel, oModel)

//------------------------------------------------------------------
/*/{Protheus.doc} CN121Agrup
Carregamento de agrupadores por planilha

@author guilherme.pimentel
@since 02/09/2015
/*/
//-------------------------------------------------------------------
Function CN121Agrup(oModel,oModelCXM)
Local nCount	:= 0
Local nIncLine	:= 0
Local nInd		:= 0
Local aSaveLines:= FWSaveRows()
Local cContrat	:= oModel:GetModel( 'CXNDETAIL' ):GetValue( 'CXN_CONTRA' )
Local cRevisa	:= oModel:GetModel( 'CXNDETAIL' ):GetValue( 'CXN_REVISA' )
Local cNumero	:= oModel:GetModel( 'CXNDETAIL' ):GetValue( 'CXN_NUMPLA' )
Local lRet		:= .T.

Default oModelCXM := oModel:GetModel('CXMDETAIL')

If CN121RetSt('SEMIAGRUP',0,cNumero,cContrat)
	dbSelectArea('CXM')
	CXM->(dbSetOrder(1)) //CXM_FILIAL+CXM_CONTRA+CXM_REVISA+CXM_NUMERO+CXM_ITEMID

	CNTA300DlMd(oModelCXM,'CXM_ITEMID')

	If !CXM->(dbSeek(xFilial('CXM')+cContrat+cRevisa+cNumero ) )
		lRet := .F.
	Else
		While CXM->(!Eof()) .And. CXM->CXM_FILIAL == xFilial('CXM') .And. CXM->CXM_CONTRA == cContrat .And. CXM->CXM_REVISA == cRevisa .And. CXM->CXM_NUMERO == cNumero
			nCount ++
			Do Case
				Case ( nCount == 1 ) .And. ( nCount == oModelCXM:nLine )
					nIncLine := nCount
				Case ( nCount > 1 )
					nIncLine := oModelCXM:AddLine()
					If nCount # nIncLine
						//Help de Erro na Criacao da Linha
						lRet := .F.
						Exit
					EndIf
			EndCase

			If lRet
				oModelCXM:GoLine( nIncLine )
				For nInd := 1 To CXM->( FCount() )
					oModelCXM:LoadValue( CXM->( FieldName( nInd ) ), CXM->( FieldGet( nInd ) )  )
				Next nInd
			EndIf
			CXM->( dbSkip() )
	 	EndDo
	EndIf
EndIf

FwRestRows( aSaveLines )
Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN121VlAgr
Validação do tipo do agrupador

@author guilherme.pimentel
@since 02/09/2015
/*/
//-------------------------------------------------------------------
Function CN121VlAgr(cProd,nQAtu,nQAnt)
	Local aArea		:= GetArea()
	Local lEncontrou:= .F.
	Local cTipo		:= ''
	Local cGrupo	:= ''
	Local oModel	:= FWModelActive()
	Local oModelCXN	:= oModel:GetModel('CXNDETAIL')
	Local oModelCNE := oModel:GetModel('CNEDETAIL')
	Local cContra	:= oModelCXN:GetValue("CXN_CONTRA")
	Local cRevisa	:= oModelCXN:GetValue("CXN_REVISA")
	Local cNumPla	:= oModelCXN:GetValue("CXN_NUMPLA")
	Local cItem		:= oModelCNE:GetValue("CNE_ITEMGR")
	
	Default cProd := ''
	Default nQAtu := 0
	Default nQAnt := 0
	
	If SB1->(DbSeek(xFilial("SB1")+cProd))
		cTipo	:= SB1->B1_TIPO
		cGrupo	:= SB1->B1_GRUPO
		
		//Se for chamado pela quantidade ou o item estiver preenchido posiciona
		If !IsInCallStack("CN120VldProd") .Or. !Empty(oModelCNE:GetValue('CNE_ITEMGR'))
			//Posiciona na CXM correspondente caso haja
			If !Empty(oModelCNE:GetValue('CNE_ITEMGR'))				
				CXM->(dbSetOrder(1))
				lEncontrou := CXM->(MsSeek(xFilial("CXM")+cContra+cRevisa+cNumPla+cItem))
			EndIf
		EndIf
		
		//Verifica se é alteração de produto ou se o saldo não é suficiente e se encaixa em outra categoria
		If IsInCallStack("CN120VldProd") .Or. IsInCallStack('CN121VlTot')
			cItem := CN121ItId(oModel , .F.)//Busca na CXM o valor de CXM_ITEMID que deve ser carregado em CNE_ITEMGR		
			lEncontrou := !Empty(cItem)
			If(lEncontrou)
				oModelCNE:LoadValue('CNE_ITEMGR', cItem)
			Else
				lEncontrou := CN300getACV(cProd,nQAtu)
				//Se não encontrar ninguem compativel exibe mensagem
				If !lEncontrou
					Help(" ",1,"CN121VlAgr",,STR0101,1,0)//"Não foram encontrados agrupadores de estoque nas mesmas caracteristicas ou saldo do produto selecionado."					
				EndIf		
			EndIf
		EndIf		
	EndIf
	
	RestArea(aArea)
Return (lEncontrou)

//------------------------------------------------------------------
/*/{Protheus.doc} CN300getACV
Carrega todos os níveis da tabela ACV

@author guilherme.pimentel
@since 02/09/2015
/*/
//-------------------------------------------------------------------
Function CN300getACV(cProd,nQAtu)
Local aCateg	:= {}
Local aCatCXM	:= {}
Local aRet		:= {}
Local nX		:= 0
Local nY		:= 0
Local nPos		:= 0
Local cCategoria:= ''
Local oModel	:= FWModelActive()
Local oModelCXM := oModel:GetModel('CXMDETAIL')
Local oModelCNE := oModel:GetModel('CNEDETAIL')
Local lSaldo	:= .F.
Local cChave	:= ""

DbSelectArea("ACV")
DbSetOrder(6)//ACV_FILIAL+ACV_SEQPRD

ACV->(DbGoBottom())
While !ACV->(Bof())
	If ACV->ACV_CODPRO == cProd
		cCategoria := ACV->ACV_CATEGO
		Exit
	Else
		ACV->(DbSkip(-1))
	EndIf
End

DbSelectArea("ACV")
DbSetOrder(1)//ACV_FILIAL+ACV_CATEGO+ACV_GRUPO+ACV_CODPRO

//Verifica a arvore de categorias e ordena pela mais recomendada
If ACV->(DbSeek(xFilial("ACV")+cCategoria))
	aAdd(aCateg,cCategoria)

	dbSelectArea("ACU")
	dbSetorder(1)
	If ACU->(DbSeek(xFilial("ACU")+cCategoria))
		cCategoria := ACU->ACU_CODPAI
		aAdd(aCateg,cCategoria)
		While !EOF()
			ACU->(DbSeek(xFilial("ACU")+ACU->ACU_CODPAI))
			If Empty(ACU->ACU_CODPAI)
				cCategoria := ACU->ACU_COD
				aAdd(aCateg,cCategoria)
				Exit
			Endif
		Enddo
	Endif
EndIf

cChave := xFilial('CXM', oModel:GetValue("CNDMASTER", "CND_FILCTR"))
cChave += oModel:GetValue("CXNDETAIL", "CXN_CONTRA") 
cChave += oModel:GetValue("CXNDETAIL", "CXN_REVISA")
cChave += oModel:GetValue("CXNDETAIL", "CXN_NUMPLA")
CXM->(DbSetOrder(1))//CXM_FILIAL+CXM_CONTRA+CXM_REVISA+CXM_NUMERO+CXM_ITEMID
If CXM->(dbSeek(cChave))	
	While (CXM->(!Eof() .And. CXM_FILIAL+CXM_CONTRA+CXM_REVISA+CXM_NUMERO == cChave))
		If !Empty(CXM->CXM_AGRCAT)
			aAdd(aCatCXM, CXM->CXM_AGRCAT)
		EndIf
		CXM->(DbSkip())
	EndDo
EndIf

//Adiciona em um array final todas as categorias que tme no original e suas posições
For nX := 1 to len(aCatCXM)
	If (nPos := AScan(aCateg,aCatCXM[nX])) > 0
		aAdd(aRet,{nPos,aCatCXM[nX]})
	EndIf
Next nX

aSort(aRet, , ,{|x,y|x[1] < y[1]})

//Verificação de saldo
//Posiciona no no CMX de acordo com o array
For nY := 1 to Len(aRet)
	If lSaldo
		Exit
	EndIf
	For nX := 1 To oModelCXM:Length()
		oModelCXM:GoLine(nX)
		// Verifica se encontra
		If oModelCXM:GetValue('CXM_AGRCAT') == aRet[nY,2]
			//Valida o Saldo
			If oModelCXM:GetValue('CXM_VLMAX') > 0
				If (nQAtu + oModelCXM:GetValue('CXM_VLMED')) <= oModelCXM:GetValue('CXM_VLMAX')
					lSaldo := .T.
					oModelCXM:LoadValue('CXM_VLMED',oModelCXM:GetValue('CXM_VLMED')+nQAtu)
					oModelCNE:LoadValue('CNE_ITEMGR',oModelCXM:GetValue('CXM_ITEMID'))
					Exit
				EndIf
			Else
				//Por total
				lSaldo := .T.
				oModelCXM:LoadValue('CXM_VLMED',oModelCXM:GetValue('CXM_VLMED')+nQAtu)
				oModelCNE:LoadValue('CNE_ITEMGR',oModelCXM:GetValue('CXM_ITEMID'))
				Exit
			EndIf
		EndIf
	Next nX
Next nY

Return lSaldo

//------------------------------------------------------------------
/*/{Protheus.doc} CN121Estorn
Estorna Medição
@author Leonardo Quintania
@since 03/09/2015
/*/
//-------------------------------------------------------------------
Function CN121Estorn(lAuto,lAprRev,cMedErro)
Local aArea     := GetArea()
Local aAreaCND  := CND->(GetArea())
Local lAutForn	:= CND->CND_AUTFRN == "2"
Local lContinua	:= .T.
Local cChave	:= ""
Local cFilCNA	:= xFilial("CNA")
Local cFilCXN	:= xFilial("CXN")
Local nReg		:= CND->(Recno())
Local bBloco	:= Nil
Local oModel    := Nil
Default lAuto	:= .F.
Default lAprRev := .F.
Default cMedErro:= ""

If Cn121OriMd('CNTA120')
	If lAuto
		cMedErro := "CN121MEDPAD: " + STR0127+CRLF+STR0128+CRLF+CRLF+STR0125+CRLF+STR0126
		lContinua := .F.
	Else		
		Return CN121OldMd(-1)//Chama o estorno do CNTA120
	EndIf    
ElseIf !(Alltrim(CND->CND_SITUAC) $ "E|FE|SE")
	Help(" ",1,"CN121NoEnc",,STR0102,1,0) //"Operação não permitida. Somente é possível estornar Medições que estejam encerradas"
    cMedErro := "CN121NoEnc: " + STR0102
    lContinua := .F.
ElseIf ( FindFunction("A300IsGTP") .And. A300IsGTP(.T.) .And. !(FunName() $ "GTPA903") )
	Help( ,, "CNTA121GTP",, STR0216, 1, 0,,,,,, {STR0217} )//Ação indisponivel para medições integradas ao Gestão de Trasporte de Passageiros.
	cMedErro  := "CNTA121GTP: " + STR0216
	lContinua := .F.
Else
	oModel := FwLoadModel('CNTA121')
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	lContinua := oModel:Activate()

	If lContinua

		lContinua := VldEstorMd(lAprRev, @cMedErro, lAuto)

		//- Verifica se é contrato recorrente e se é a última medição efetuada
		CXN->(dbSetOrder(1))
		CNA->(dbSetOrder(1))
		CXN->(dbSeek(cFilCXN+CND->(CND_CONTRA+CND_REVISA+CND_NUMMED)))
		While !CXN->(Eof()) .And. CXN->(CXN_FILIAL+CXN_CONTRA+CXN_REVISA+CXN_NUMMED) == cFilCXN+CND->(CND_CONTRA+CND_REVISA+CND_NUMMED)
			If CXN->CXN_CHECK
				If CNA->(MsSeek(cFilCNA+CND->(CND_CONTRA+CND_REVISA)+CXN->CXN_NUMPLA))
					//- Se a medição a ser excluída não é a última, não permite exclusão
					If !Empty(CNA->CNA_PERIOD) .And. !Empty(CNA->CNA_RECMED) .And. ( CNA->CNA_RECMED <> CND->CND_NUMMED  )
						lContinua := .F.
						Help(" ",1,"CN121BLQREC") // "Exclusões de medições de contratos recorrentes serão permitidas na ordem inversa da que foram incluídas, a partir da última medição.")
                        cMsgErro := "CN121BLQREC: " + STR0209
						Exit
					Endif
				Endif
			Endif
			CXN->(dbSkip())
		EndDo

		cChave := CND->(CND_CONTRA+CND_REVISA+CND_NUMMED)
		If LockByName("CN120"+xFilial("CND")+cChave,.T.,!Empty(xFilial("CND")),.T.)
			If lContinua			
				//Chama rotina de estorno por meio de processo
				If lAutForn
					bBloco := {|| lContinua := Cn121AutEst(nReg,!lAuto) }
				Else				
					bBloco	:= IIF(lAuto, {|| lContinua := CN121MedEst(nReg,!lAuto,,,lAprRev,@cMedErro) }, {|| lContinua := CN121MedEst(nReg,!lAuto) })
				EndIf

				If lAuto
					Eval(bBloco)
				Else
					Processa(bBloco)
				Endif
			EndIf
		Else
			// Nao permite processamento concorrente
			lContinua := .F.
            If !lAuto
			    Aviso(STR0159,OemtoAnsi(STR0100),{STR0156},2) // ##"Concorrência"##"Esta Medição está em uso por outra estação."
            Else
                cMedErro := "CN121CONMED: " + STR0100
            EndIf
		EndIf
    EndIf 
    UnLockByName("CN120"+xFilial("CND")+cChave,.T.,!Empty(xFilial("CND")),.T.)
EndIf

CN121Limpa() //--Desativa o model do CNTA121 apó finalização do processo.

RestArea(aAreaCND)
RestArea(aArea)

Return lContinua

//------------------------------------------------------------------
/*/{Protheus.doc} CN121MedEst
Estorna medicao, valida pedido de compra, medicoes zeradas
e saldo do contrato, planilhas e cronogramas
@author Leonardo Quintania
@since 03/09/2015
/*/
//-------------------------------------------------------------------
Static Function CN121MedEst(nReg,lAviso,lAutoFor,lMedServ,lAprRev,cMedErro)
Local cFilCtr		:= CND->CND_FILCTR
Local cFilCNS 		:= xFilial("CNS",cFilCTR)
Local cRetPrf		:= PadR(SuperGetMV("MV_CNPREMD",.F.,"MED"),TAMSX3("E2_PREFIXO")[1])
Local cTpTit		:= PadR(SuperGetMV("MV_CNTPTMD",.F.,"BOL"),TAMSX3("E2_TIPO")[1])
Local cLoteGCT  	:= LoteCont("COM")  //-- Numero do Lote
Local cQuery   		:= ""
Local cCronog  		:= ""
Local cEspCtr  		:= ""
Local cParcel		:= ""
Local cAliasCNT		:= ""
Local cNumTit		:= ""
Local cArqGCT 		:= ""
Local cLancCont		:= ""
Local cBusca		:= ""
Local cChaveCXN		:= ""
Local cChaveCNE		:= ""
Local cChaveCNZ		:= ""
Local cChaveCXJ		:= ""
Local cOrigem		:= FunName()
Local cFilBkp		:= "" 
Local nTamVlTot		:= TamSX3("CND_VLTOT")[2]
Local nTipo    		:= 1 	//-- 1 - Medicao;2 - Autorizacao de Fornecimento
Local nServico 		:= 1 	//-- 1 - Medicao;2 - Medicao de Servico
Local nDet 			:= 0    //-- Retorno da funcao DetProva
Local nTaxa			:= 0
Local nHead			:= 0
Local nX			:= 0
Local nValExced		:= 0
Local nLp69B		:= 0
Local nLp69I		:= 0
Local lCriaProv		:= AllTrim(SuperGetMV("MV_CNTPPP" ,.F.,"0")) $ "0/1"  // define quando os contratos recorrentes serão provisionados
Local lTitProv		:= GetNewPar("MV_CNPROVI","S") == "S"
Local lPeSld   		:= ExistBlock("CN121ELD")
Local lCN121EPM 	:= ExistBlock("CN121EPM")
Local lRecorre		:= .F.
Local lMedEve  		:= .F.
Local lFisico  		:= .F.
Local lSemiFix		:= .F.
Local lValor   		:= .T.
Local lFixo    		:= .T.
Local lRet     		:= .T.
Local lEstSld		:= .T.
Local lDigita 		:= .F.    	//-- Mostra lancamento?
Local lAglutina		:= .F.    	//-- Aglutina
Local lMedComPlan 	:= .F.
Local lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Local lCtbCNE		:= .F.
Local lCtbOnLine	:= .F.
Local lPrevFin		:= .F.
Local lCN121EST 	:= ExistBlock("CN121EST")//P.E apos o estorno da medicao
Local aFlagCTB 		:= {}
Local aCTBFile		:= {}
Local aDocuments	:= {}
Local aLPGCT		:= {}
Local dDtFim		:= dDataBase
Private lAutoErrNoFile := !lAviso
Private lMsHelpAuto    := !lAviso

DEFAULT lAviso 		:= .T.
DEFAULT lAutoFor	:= CND->CND_AUTFRN=="2"
DEFAULT lMedServ	:= CND->CND_SERVIC=="2"
DEFAULT lAprRev		:= .F.

lMsErroAuto := Iif(Type("lMsErroAuto")=='L',lMsErroAuto,.F.)

//-- Ponto de entrada para indicar se atualiza ou nao saldo da medicao no estorno
If ExistBlock("CN121ASD")
	lEstSld := ExecBlock("CN121ASD",.F.,.F.)
	If ValType(lEstSld) <> "L"
		lEstSld := .T.
	EndIf
EndIf

//-- Estabelece passos
ProcRegua(6)

If lRet .And. (lCtbOnLine := IsCtbOnline(@aLPGCT, "", @lDigita, @lAglutina))	
	nHead := HeadProva(cLoteGCT,"CNTA121",Subs(cUsuario,7,6),@cArqGCT)
	If nHead <= 0
		Help(" ",1,"SEM_LANC")
		cMedErro := "SEM_LANC: " + STR0210
		lCtbOnLine := .F.
	EndIf
EndIf

If lRet
	If !Empty(CND->CND_DTFIM) .Or. lAutoFor
		nTipo 	:= Iif(lAutoFor,2,1)
		nServico:= Iif(lMedServ,2,1)

		CN9->(dbSetOrder(1)) //-- CN9_FILIAL+CN9_NUMERO+CN9_REVISA
		lRet := CN9->(MsSeek(xFilial("CN9",cFilCTR)+CND->(CND_CONTRA+CND_REVISA)))//-- Posiciona na revisao atual do contrato		

		lMultiMed	:= CN121RetSt("MULTIMED",0,, CND->CND_CONTRA,.F.,Nil, CND->CND_FILCTR)
		If lRet .And. !Empty(CND->CND_RETCAC)
			//-- Verifica se existe retencao para a medicao e se
			//-- a mesma se encontra baixada
			cQuery := " SELECT COUNT(*) AS RETQTD "
			cQuery += " FROM "+RetSQLName("CNT")+" CNT"
			cQuery += " WHERE CNT.CNT_FILIAL = '"+xFilial("CNT",cFilCTR)+"'"
			cQuery += " AND CNT.CNT_CONTRA = '"+CND->CND_CONTRA+"'"
			cQuery += " AND CNT.CNT_NUMMED = '"+CND->CND_NUMMED+"'"
			cQuery += " AND CNT.CNT_VLBX   > 0"
			cQuery += " AND D_E_L_E_T_ = ' '"

			cAliasCNT := GetNextAlias()
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCNT,.F.,.T.)
			lRet := ((cAliasCNT)->RETQTD == 0)
			(cAliasCNT)->(dbCloseArea())
			
			If !lRet
				Help( " ", 1, "CNTA120_05")//-- A medição não pode ser estornada, pois o valor de retenção da caução já foi baixado"
				cMedErro := "CNTA120_05: " + STR0211
			EndIf
		EndIf

		Begin Transaction

		If lRet
			//Valida se a medição é de excedente para competência não prevista
			If GCTExcedNP(CND->CND_NUMMED)
				SetExcedNP(.T.)
			EndIf

			nTaxa := RecMoeda(CND->CND_DTINIC,CN9->CN9_MOEDA)

			cChaveCXN := xFilial("CXN")+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMMED
			CXN->(DbSetOrder(1)) //-- CXN_FILIAL+CXN_CONTRA+CXN_REVISA+CXN_NUMMED+CXN_NUMPLA
			CXN->(DbSeek(xFilial("CXN")+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMMED))
			While CXN->(!EOF()) .And. cChaveCXN == CXN->(CXN_FILIAL+CXN_CONTRA+CXN_REVISA+CXN_NUMMED)
				//- Aqui processa cada registro da CXN
				If !(CXN->CXN_CHECK)
					CXN->(DbSkip())
					Loop
				EndIf
				
				//-- Encerramento de planilhas zeradas
				If CXN->(Columnpos('CXN_ZERO')) > 0
					If CXN->CXN_ZERO == '1'
						CN121ZERO( CXN->CXN_CONTRA , CXN->CXN_REVISA , CXN->CXN_NUMMED , CXN->CXN_NUMPLA , cFilCtr , '2')
						CXN->(DbSkip())
						Loop
					EndIf
				EndIf

				//- Caracteristicas do contrato pelo tipo de planilha
				cEspCtr := CN121RetSt("ESPECIE",	0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.F.)
				lMedEve := CN121RetSt("MEDEVE",		0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.F.)
				lContab := CN121RetSt("CONTABIL",	0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.F.)
				lFixo	:= CN121RetSt("FIXO",		0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.F.)
				lValor	:= CN121RetSt("PREVFINANC",	0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.F.)
				lFisico := CN121RetSt("FISICO",		0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.F.)
				lRecorre:= CN121RetSt("RECORRENTE",	0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.F.)
				lSemiFix:= CN121RetSt("SEMIFIXO",	0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.F.)
				lServico:= CN121RetSt('SERVIÇO',	0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.F.)
				lPrevFin:= CN121RetSt("PREVFINANC",	0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.F.)

				//Valor total dos itens excedentes da planilha
				nValExced := CN120VlExc(CND->CND_CONTRA,CND->CND_REVISA,CND->CND_NUMMED,CXN->CXN_NUMPLA)

				//- Busca parcela do cronograma
				If lRet .And. !Empty(CXN->CXN_CRONOG)
					cCronog := CXN->CXN_CRONOG
					cParcel := CXN->CXN_PARCEL					
				EndIf

				PcoIniLan("000355")

				//- Busca documentos da medição
				cChaveCXJ := xFilial("CXJ")+CND->(CND_CONTRA+CND_NUMMED)+CXN->CXN_NUMPLA
				CXJ->(DbSetOrder(1)) //-- CXJ_FILIAL+CXJ_CONTRA+CXJ_NUMMED+CXJ_NUMPLA+CXJ_ITEMPL+CXJ_PRTENV+CXJ_ID
				CXJ->(MsSeek(cChaveCXJ))

				IncProc(STR0155)//-- Verificando documentos da medição
				While CXJ->(!EOF()) .And. cChaveCXJ == CXJ->(CXJ_FILIAL+CXJ_CONTRA+CXJ_NUMMED+CXJ_NUMPLA)
					lFind:=  aScan(aDocuments,{|x| x[2] == CXJ->CXJ_NUMPED }) > 0  .Or.  aScan(aDocuments,{|x| x[2] == CXJ->CXJ_NUMTIT }) > 0
					If !lFind
						If cEspCtr == '1'
							If Empty(CXJ->CXJ_NUMTIT)
								aAdd(aDocuments,{"1",CXJ->CXJ_NUMPED, CND->CND_FILMED}) //-- Pedido de Compra
							Else
								aAdd(aDocuments,{"3",CXJ->CXJ_NUMTIT, CND->(RecNo())}) //-- Titulo a Pagar - SE2
							EndIf
						Else
							If Empty(CXJ->CXJ_NUMTIT)
								aAdd(aDocuments,{"2",CXJ->CXJ_NUMPED, CND->CND_FILMED}) //-- Pedido de Venda
							Else
								aAdd(aDocuments,{"4",CXJ->CXJ_NUMTIT, CND->(RecNo()) }) //-- Titulo a Receber - SE1
							EndIf
						EndIf
					EndIf

					CXJ->(dbSkip())
				EndDo

				If lRet
					dDtFim := CND->CND_DTFIM

					PcoDetLan("000355","03","CNTA120",.T.)	//-- Ponto de lancamento contabil e orcamentario para estorno da medicao

					If lRet .And. lCtbOnLine
						nDet += DetProva(nHead,"699","CNTA121",cLoteGCT,,,,,,,,,{"CND",CND->(RECNO())})
					EndIf

					IncProc( STR0098 )//-- Atualizando Medição e Itens
					
					If (lFixo .Or. lSemiFix .Or. lValor)//- Atualiza saldo da planilha se tipo de contato/planilha é fixa
						CNA->(dbSetOrder(1))
						If CNA->(dbSeek(xFilial("CNA",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA+CXN->CXN_NUMPLA))
							If lEstSld .And. !lPeSld .And. !lMultiMed						
								UpdSldCNA(lRecorre, lFixo, lSemiFix, lPrevFin, nValExced, nTamVlTot, nTaxa, .T.)//-- Atualiza saldo da planilha								
							EndIf
						EndIf
					EndIf

					//- Atualiza saldo do contrato se tipo de contrato/planilha é fixo
					CN9->(dbSetorder(1))
					If CN9->(dbSeek(xFilial("CN9",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA))
						If lEstSld .And. !lPeSld .And. !lMultiMed
							UpdSldCN9(lFixo, lSemiFix, lValor, nValExced, nTamVlTot, nTaxa, lRecorre)
						EndIf
					EndIf
					
					If !lMedeve .And. !lRecorre //-- Atualiza saldo do cronograma quando nao houver  medicao eventual
						If (lEstSld .And. !lPeSld .And. !lMultiMed)
							UpdSldCNF(cCronog, nValExced, nTamVlTot, .T., /*lTitProv*/, lServico)//- localiza e atualiza valores da parcela do cronograma se não é eventual
						EndIf
					EndIf

					//- atualiza saldos de cronogramas fisico/financeiro
					cChaveCNE := xFilial("CNE")+CND->(CND_CONTRA+CND_REVISA)+CXN->CXN_NUMPLA+CND->CND_NUMMED
					CNE->(dbSetOrder(1))
					CNE->(MsSeek(cChaveCNE))							
					CXM->(DbSetOrder(1))//CXM_FILIAL+CXM_CONTRA+CXM_REVISA+CXM_NUMERO+CXM_ITEMID
												
					While !CNE->(Eof()) .And. cChaveCNE == CNE->(CNE_FILIAL+CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_NUMMED)
						lMedComPlan := .F.

						If CNE->CNE_EXCEDE == '2' //-- Atualiza saldo dos itens da planilha, itens excedentes nao atualizam saldos
							If(!Empty(CNE->CNE_ITEMGR) .And. !lMultiMed	)//Se tiver agrupador, estornar o saldo.									
								UpdVlMdCXM(CNE->CNE_VLLIQD, xFilial("CXM") + CNE->(CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_ITEMGR), .T.)
							EndIf

							If !lRecorre								
								CNB->(dbSetOrder(1)) //-- CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM
								If CNB->(dbSeek(xFilial("CNB",cFilCTR)+CNE->CNE_CONTRA+CNE->CNE_REVISA+CNE->CNE_NUMERO+CNE->CNE_ITEM))
									If lEstSld .And. !lPeSld .And. !lMultiMed
										UpdSldCNB(lRecorre, lServico, lSemiFix, .T.)										
									EndIf
									lMedComPlan := .T. //-- CAPTURO A VARIAVEL FLAG DE ITENS COM PLANILHA
								EndIf

								If lFisico .And. lEstSld .And. !lPeSld .And. !lMultiMed									
									UpdSldCNS(cFilCNS, cCronog, cParcel, .T.)//- atualiza saldo do cronograma físico									
								EndIf
							EndIf
						EndIf

						PcoDetLan("000355","04","CNTA120",.T.)

						If lRet .And. lCtbOnLine //CONTABILIZA ESTORNO DA MEDICAO - ITENS DO CONTRATO

							nLp69B := aScan(aLPGCT,{|x| x[1]=="69B"})
							nLp69I := aScan(aLPGCT,{|x| x[1]=="69I"})

							If lUsaFlag
								aAdd( aFlagCTB, {"CNE_DTLANC", dDataBase, "CNE", CNE->( Recno() ), 0, 0, 0} )
							EndIf

							If aLPGCT[nLp69I,2]  .And. cEspCtr == '2' .And. CN9->CN9_DTINIC >= CTOD("01/01/2018") // - Ponto de lançamento padrão IFRS15
								nDet += DetProva(nHead,'69I',cOrigem,cLoteGCT,,,,,,,,@aFlagCTB,{"CNE",CNE->(Recno())})
								lCtbCNE := .T.
							ElseIf aLPGCT[nLp69B,2]
								nDet += DetProva(nHead,"69B","CNTA121",cLoteGCT,,,,,,,,,{"CNE",CNE->(Recno())})
								lCtbCNE := .T.
							EndIf

							If !lUsaFlag .And. lCtbCNE
								If CNE->(Columnpos('CNE_DTLANC')) > 0
									dbSelectArea("CNE")
									RecLock("CNE",.F.)
									CNE->CNE_DTLANC := dDataBase
									MsUnlock()
								EndIf
							EndIf

						EndIf

						If lMedComPlan
							cLancCont := "69F"
							cSeqPCOLan:= "06"
						Else
							cLancCont := "69D"
							cSeqPCOLan:= "05"
						Endif

						cBusca := xFilial("CNZ",cFilCTR)+ CNE->(CNE_CONTRA+CNE_REVISA+CNE_NUMMED+CNE_ITEM)
						CNZ->(dbSetOrder(2)) //CNZ_FILIAL+CNZ_CONTRA+CNZ_REVISA+CNZ_NUMMED+CNZ_ITCONT+CNZ_ITEM
						If CNZ->(dbSeek( cBusca ))
							While CNZ->(!Eof()) .and. cBusca == xFilial("CNZ",cFilCTR)+CNZ->(CNZ_CONTRA+CNZ_REVISA+CNZ_NUMMED+CNZ_ITCONT)
								PcoDetLan("000355",cSeqPCOLan,"CNTA120",.T.)
								If lRet .And. lCtbOnLine
									//CONTABILIZA OS RATEIOS DO ITEM DO CONTRATO COM PLANILHA.
									//SE HA PLANILHA, ENTAO NAO PODERA CONTABILIZAR O RATEIO SEM PLANILHA, ABAIXO (CONTROLAR COM VARIAVEL FLAG)
									//EFETUA A CONTABILIZACAO DOS RATEIOS DO ITEM DO CONTRATO SEM PLANILHA,
									nDet	+= DetProva(nHead,cLancCont,"CNTA121",cLoteGCT,,,,,,,,,{"CNZ",CNZ->(RECNO())})
								Endif
								CNZ->(DbSkip())
							EndDo
						Endif

						If CNE->CNE_EXCEDE == '1' .And. !lExcedNPrv	//Exclui excedentes no estorno
							RecLock('CXN',.F.) //- Atualiza Totais da CXN
							CXN->CXN_VLLIQD -= CNE->CNE_VLTOT
							CXN->CXN_VLTOT  -= (CNE->CNE_VLTOT + CNE->CNE_MULTA - CNE->CNE_BONIF)
							CXN->(MsUnlock())

							RecLock('CND',.F.) //- Atualiza Totais da CND
							CND->CND_VLLIQD -= CNE->CNE_VLTOT
							CND->CND_VLTOT 	-= (CNE->CNE_VLTOT + CNE->CNE_MULTA - CNE->CNE_BONIF)
							CND->(MsUnlock())

							dbSelectArea('CNZ')
							cChaveCNZ := CNE->(CNE_FILIAL+CNE_CONTRA+CNE_REVISA+CNE_NUMMED+CNE_NUMERO+CNE_ITEM)
							CNZ->(dbSetOrder(5)) //CNZ_FILIAL+CNZ_CONTRA+CNZ_REVISA+CNZ_NUMMED+CNZ_CODPLA+CNZ_ITCONT+CNZ_ITEM
							CNZ->(MsSeek(cChaveCNZ))
							While CNZ->(!EOF()) .And. CNZ->(CNZ_FILIAL+CNZ_CONTRA+CNZ_REVISA+CNZ_NUMMED+CNZ_CODPLA+CNZ_ITCONT) == cChaveCNZ
								RecLock('CNZ',.F.)
								CNZ->(dbDelete())
								CNZ->(MsUnlock())
								CNZ->(dbSkip())
							End

							RecLock('CNE',.F.)
							CNE->(dbDelete())
							CNE->(MsUnlock())
						EndIf


						CNE->(dbSkip())
					EndDo

					IncProc( STR0106 )//-- Atualizando Saldos

					If lPeSld//Chama ponto de entrada para atualizacao do saldo
						ExecBlock("CN121ELD",.f.,.f.,{lMedEve,lFisico,cCronog,lFixo,lValor})
					EndIf

					CN120HistMul( 2, NIL, CND->CND_CONTRA, CND->CND_NUMMED )//-- Estorna o historico de multas / bonificacoes do contrato
					If !Empty(CND->CND_RETCAC) //-- Estorna o valor retido da caucao
						CND->(CN120CaucRet(CND_CONTRA, CND_NUMMED, 2, CND_RETCAC, CND_FILCTR))
					EndIf

				EndIf

				PcoFinLan("000355")

				If lRet .And. lRecorre .And. !lMultiMed			
					If lTitProv 
						IncProc(STR0099) //-- Processando títulos provisórios
						TitProvRec(lCriaProv, .T.)//- Atualiza títulos provisórios de contratos recorrentes							
					EndIf
				EndIf

				CXN->(dbSkip())
			EndDo
				
			// atualiza campos de controle dos contratos recorrentes na medição
			If lRet
				RecLock("CND",.F.)
				CND->CND_RECMED := Space(TamSx3("CND_RECMED")[1])
				CND->CND_ULTMED := Ctod("")
				If !lAutForn
					CND->CND_DTFIM := CTOD("")					
					CND->CND_SITUAC:= IIF(CND->(AllTrim(CND_SERVIC) == "2"), "SA", "A")
				EndIf
				CND->(MsUnlock())
			EndIf
				
			If lRet				
				If lCtbOnLine
					aCTBFile := {GetHFile(), GetHProva()}
				EndIf

				For nX := 1 To Len(aDocuments) //-- Documentos encontrados para serem estornados
					If cEspCtr == "1"
						//-- Verifica se o documento é Pedido de Compra
						If aDocuments[nX,1] == "1"
							// PE para tratamento específico do usuário antes da exclusão do Pedido de compras
							If lCN121EPM
								ExecBlock("CN121EPM",.F.,.F.)
							EndIf
							IncProc( STR0107 )//-- Verificando pedido de compras
							
							cFilBkp := cFilAnt																		
							If(!Empty(aDocuments[nX,3]))
								cFilAnt := aDocuments[nX,3]//Muda a cFilAnt p/ permitir estornar um pedido gerado em filial diferente da corrente. 
							EndIf
																
							MSExecAuto({|v,x,y,z,w| MATA120(v,x,y,z,w)},1,{{"C7_NUM",aDocuments[nX,2],NIL}},{},5,.F.) //Exclui pedido de compras
							If lMsErroAuto
								If !IsBlind()
									MostraErro()
								Else
									cMedErro := PegaMsErro()
								EndIf
								lRet:= .F.
								Exit
							Else
								LimpCNEPed(aDocuments[nX,2])
							EndIf
							cFilAnt := cFilBkp
						EndIf
						//-- Verifica se o documento é Titulo a Pagar - SE2
						If lRet .And. aDocuments[nX,1] == "3"
							IncProc(STR0108)//-- Verificando título a pagar
							aTitulo := {}
							cNumTit	:= aDocuments[nX,2]
																
							lRet := CNEstTitMd(cRetPrf, cNumTit, cTpTit, .F., aDocuments[nX,3])
						EndIf
					Else
						//-- Verifica se o documento é Pedido de Venda
						If aDocuments[nX,1] == "2"
							IncProc( STR0109 )//-- Verificando pedido de venda
							
							cFilBkp := cFilAnt																		
							If(!Empty(aDocuments[nX,3]))
								cFilAnt := aDocuments[nX,3]//Muda a cFilAnt p/ permitir estornar um pedido gerado em filial diferente da corrente. 
							EndIf
							
							MSExecAuto({|x,y,z| Mata410(x,y,z)},{{"C5_NUM",aDocuments[nX,2],NIL}},{},5) //-- Exclui pedido de venda
							If lMsErroAuto
								If !IsBlind()
									MostraErro()
								Else
									cMedErro := PegaMsErro()
								EndIf
								lRet:= .F.
								Exit
							Else
								LimpCNEPed(aDocuments[nX,2])
							Endif
							cFilAnt := cFilBkp
						EndIf
						//-- Verifica se o documento é Titulo a Receber - SE1
						If lRet .And. aDocuments[nX,1] == "4"
							IncProc(STR0110)//-- Verificando título a receber
							
							cNumTit	:= aDocuments[nX,2]
							lRet := CNEstTitMd(cRetPrf, cNumTit, cTpTit, .T.,aDocuments[nX,3])										
						EndIf
					EndIf
				Next nX

				If lRet
					aAreaCND  := CND->(GetArea()) 					//Guarda a posição atual da CND
					CND->(MsGoTo(nReg)) 							//Posiciona na linha selecionada
					
					If lCN121EST
						ExecBlock("CN121EST",.F.,.F.,{aDocuments, .T.})//chamada dentro da transação
					EndIf

					CN121DelCXJ(CND->CND_CONTRA,CND->CND_NUMMED) 	//Deleta registros de documentos
					RestArea(aAreaCND) 								//Devolve a posição da CND
				EndIf
			EndIf
	
			If !lRet
				If lAviso
					Aviso("CNTA121",STR0111,{STR0156})				//"O documento não pode ser estornado"
				EndIf
				DisarmTransaction()
			Else
				If lCtbOnLine					
					PutHFile(aCTBFile[1],aCTBFile[2]) //Restaura arquivo de contabilização
					RodaProva(nHead,nDet)							
				EndIf
				If nTipo == 1  .And. nServico == 1 .And. lAviso
					Aviso("CNTA121",OemToAnsi(STR0112),{STR0156})	//"Medição/entrega estornada com sucesso"
				EndIf
			EndIf
		EndIf
		
		End Transaction
			
	EndIf

	//Restaura valor default da variável static lExcedNPrv
	SetExcedNP(.F.)
EndIf

If lRet
	If (lCtbOnLine .And. nDet > 0)		
		cA100Incl(cArqGCT,nHead,1,cLoteGCT,lDigita,lAglutina,,,,@aFlagCTB)
		aFlagCTB := {}
	EndIf

	If lCN121EST
		ExecBlock("CN121EST",.F.,.F.,{aDocuments, .F.})//chamada fora da transação
	EndIf
EndIf

FwFreeArray(aDocuments)
FwFreeArray(aCTBFile)
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} CN121DelCXJ
Exclui tabela CXJ
@author leonardo.quintania
@since 22/11/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN121DelCXJ(cContra,cMedicao)
	Local aArea		:= GetArea()
	Local oQuery as Object
	Local cAliasTmp := "" as Char
	Local cQuery := "" as Char

	cQuery := "SELECT CXJ.R_E_C_N_O_ AS RECNOCXJ"
	cQuery += " FROM "+ RetSqlName("CXJ") +" CXJ"
	cQuery += " WHERE CXJ.CXJ_FILIAL= ?"
	cQuery += "	AND CXJ.CXJ_CONTRA = ?"
	cQuery += "	AND CXJ.CXJ_NUMMED = ?"
	cQuery += "	AND CXJ.D_E_L_E_T_ = ?"

	oQuery := FWExecStatement():New(cQuery)
	oQuery:SetString(1, xFilial("CXJ") )
	oQuery:SetString(2, cContra)
	oQuery:SetString(3, cMedicao)
	oQuery:SetString(4, Space(1))

	cAliasTmp := oQuery:OpenAlias()

	While !(cAliasTmp)->(EOF())
		CXJ->(dbGoTo( (cAliasTmp)->RECNOCXJ) )
		
		RecLock("CXJ",.F.)
		CXJ->(dbDelete())
		CXJ->(MsUnlock())
		
		(cAliasTmp)->(dbSkip())
	EndDo
	(cAliasTmp)->(dbCloseArea())

	RestArea(aArea)
	FwFreeArray(aArea)

	FreeObj(oQuery)
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121IFC
Retorna Cliente/Fornecedor e Loja da Planilha CXN
@author rogerio.melonio
@since 04/09/15
/*/
//-------------------------------------------------------------------
Function CN121IFC(cCampo)
	Local cRet := ""
	Local oModel := FwModelActive()
	Local cCompra := ""
	Local cVenda := ""

	If (ValType(oModel) == "O" .And. oModel:GetOperation() != MODEL_OPERATION_INSERT )
		cCompra := IIF(cCampo == "CLIFOR", CXN->CXN_FORNEC, CXN->CXN_LJFORN)
		cVenda	:= IIF(cCampo == "CLIFOR", CXN->CXN_CLIENT, CXN->CXN_LJCLI)
		cRet	:= IIF(Empty(cCompra), cVenda, cCompra)
	EndIf
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121VlAct()
Pré-Ativação do modelo

@author jose.eulalio
@since 07/09/2015
@version P12
@return lRet
/*/
//--------------------------------------------------------------------
Function CN121VlAct(oModel)
Local lRet 		:= .T.
Local lAltera	:= oModel:GetOperation() == MODEL_OPERATION_UPDATE
Local lExclui	:= oModel:GetOperation() == MODEL_OPERATION_DELETE
Local lAuto		:= IsBlind()
Local cTpCtr    := ""
Local lIntegra	:= .F.
Local lIsEncerr	:= (lEncerra .Or. FWIsInCallStack('CN121Encerr'))
Local cTransCod	:= ""
Local lIsMATA094:= (FWIsInCallStack('MATA094') .Or. FWIsInCallStack('A094Commit'))
Local lValida	:= !IsInCallStack('CN300RevPd') .And. !IsInCallStack('CN121Estorn') .And. !lIsMATA094 .And. !IsInCallStack("GCTEstApr")

If (lAltera .Or. lExclui) .And. !lExcedMEnc

	cTpCtr	:= Posicione("CN9",1,xFilial("CN9",CND->CND_FILCTR)+CND->CND_CONTRA+CND->CND_REVISA ,"CN9_TPCTO")
	lIntegra:= Iif(CN1->(Columnpos('CN1_INTEGR')) > 0 ,Posicione("CN1",1,xFilial("CN1")+cTpCtr,"CN1_INTEGR"),.F.)

	If lValida .And. !(	Alltrim(CND->CND_SITUAC) == 'A' .Or. ;	// "Medição em Aberto"
											Alltrim(CND->CND_SITUAC) == 'FA'.Or. ;	// "Aut. Fornec. em Aberto"
											AllTrim(CND->CND_SITUAC) == 'B' .Or. ;	// "Bloqueio por Alçada"
											AllTrim(CND->CND_SITUAC) == 'R' .Or. ;	// "Rejeitado"
											Alltrim(CND->CND_SITUAC) == 'SA')		// "Medição de Serviço em Aberto"

		Help(" ",1,"CN121NoDel",,STR0114,1,0) //-- "Operação apenas permitida para Medições ou Aut. Fornec. em Aberto"
		lRet := .F.
	
	ElseIf lIntegra .And. !lAuto .And.	!lIsEncerr
		Help("",1,"CN121Pims",,STR0182,1,0) //-- "Não e permitido excluir ou alterar medições de contratos integrados de forma manual."
		lRet := .F.
	EndIf
	
	If !lValida .And. lIsEncerr
		lValida := !SuperGetMV("MV_CNMDEAT",.F.,.F.)
	EndIf

	If (lRet .And. lValida)
		If lExclui
			cTransCod := DEF_TRAEXC_MED
		ElseIF lIsEncerr
			cTransCod := DEF_TRAENC_MED
		Else
			cTransCod := DEF_TRAEDT_MED
		EndIf

		lRet := CN240VldUsr(CND->CND_CONTRA, cTransCod,.T.,, CND->CND_FILCTR)
	EndIf
ElseIf(lValida .And. oModel:GetOperation() == MODEL_OPERATION_VIEW)
	lRet := CN240VldUsr(CND->CND_CONTRA, DEF_TRAVIS_MED,.T.,, CND->CND_FILCTR)
EndIf

If (lRet .And. (lAltera .Or. oModel:GetOperation() == MODEL_OPERATION_INSERT))
	If !CXNParcTp9()
		If !(lRet:= VldParcTP9("CND"))
			Help(" ",1,"TMKTIP905") //"A quantidade de parcelas nao esta compativel. Verificar junto ao administrador do sistema relacao entre parametro MV_NUMPARC e dicionario de dados"
		EndIf
	EndIf
EndIf

If lRet .And. !lIsEncerr .And. (lAltera .And. Cn121GAutF())
	Help(" ",1,"C121AUTALT",,STR0229, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0230})//Não permite alteração de autorização de fornecimento
	lRet := .F.
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121GatFC())
Gatilho para loja do fornecedor ou cliente
@author Israel.Escorizza
@since 23/09/2015
/*/
//-------------------------------------------------------------------
Function Cn121GatFC(oModelCXN,cCampo,cCodigo)
Local oModel 	:= oModelCXN:GetModel()
Local cContra	:= oModel:GetValue("CNDMASTER","CND_CONTRA")
Local cRevisa	:= oModel:GetValue("CNDMASTER","CND_REVISA")
Local cRet		:= ""

If CN121RetSt('COMPRA',0,,cContra, .T., oModel)
	cRet := Posicione("CNC",1,xFilial("CNC")+cContra+cRevisa+cCodigo,"CNC_LOJA")
Else
	cRet := Posicione("CNC",3,xFilial("CNC")+cContra+cRevisa+cCodigo,"CNC_LOJACL")
EndIf

Return cRet
//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121VldFC())
Função de Validação de Fornecedor ou Cliente para rotina de medição
@author Israel.Escorizza
@since 22/09/2015
/*/
//-------------------------------------------------------------------
Function Cn121VldFC(oModelCXN,cCampo,xValue)
Local lRet 		:= .T.
Local oModel 	:= oModelCXN:GetModel()
Local cFilCtr := oModel:GetValue("CNDMASTER","CND_FILCTR")
Local cFil		:= FWxFilial("CNC", cFilCtr)
Local cContra	:= oModel:GetValue("CNDMASTER","CND_CONTRA")
Local cRevisa	:= oModel:GetValue("CNDMASTER","CND_REVISA")
Local cCodigo	:= ""
Local cLoja		:= ""
Local cSeek		:= ""
Local nOrder	:= 0

nOrder := Iif(Cn121RetSt( "COMPRA",0,,, .T., oModel ),1,3)

Do Case
	//- Para os campos variaveis, é executado o order 1 e 3
	Case cCampo == "CXN_FORCLI"
		cCodigo := xValue
	Case cCampo == "CXN_LOJA"
		cCodigo := oModelCXN:GetValue("CXN_FORCLI")
		cLoja	 := xValue
	Case cCampo == "CXN_FORNEC"
		cCodigo := xValue
	Case cCampo == "CXN_LJFORN"
		cCodigo := oModelCXN:GetValue("CXN_FORNEC")
		cLoja	 := xValue
	Case cCampo == "CXN_CLIENT"
		cCodigo := xValue
	Case cCampo == "CXN_LJCLI"
		cCodigo := oModelCXN:GetValue("CXN_CLIENT")
		cLoja	 := xValue
EndCase

cSeek := cFil+cContra+cRevisa+cCodigo+cLoja
CNC->(dbSetOrder(nOrder))
lRet := IIf (CNC->(MsSeek(cSeek)),.T.,.F.)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A121GComp()
Função para recuperar a variavel estatica aComp
@author rogerio.melonio
@since 15/09/2015
/*/
//-------------------------------------------------------------------
Function A121GComp()
Return aComp

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121QtdIt())
Função que retorna a quantidade que deve ser utilizada no preenchimento da
medição que contenha cronograma financeiro.

@author Israel.Escorizza
@since 30/09/2015
@return nRet
/*/
//-------------------------------------------------------------------
Function Cn121QtdIt(nSldMed,nCnaSaldo,nCnfSaldo,lFisico,lFixo)
Local aArea		:= GetArea()
Local nRet		:= 0
Local cContra	:= CNB->CNB_CONTRA
Local cRevisa	:= CNB->CNB_REVISA
Local cNumPla	:= CNB->CNB_NUMERO
Local cItem		:= CNB->CNB_ITEM

Default nSldMed		:= 0
Default nCnaSaldo	:= 0
Default nCnfSaldo	:= 1

If nSldMed > 0
	//- Verificar se é serviço, se sim, verificar itens já medidos. Se item já medido, retornar 0.
	If A121Servico() .Or. !lFisico .And. !lFixo .And. CnTpProd("CNTA121", cNumPla, cContra, cRevisa) == 2
		nRet := A121QtdSrv(cContra,cRevisa,cNumPla,cItem)
	Else
		If lSugVal
			nRet := (nSldMed/nCnaSaldo)*nCnfSaldo
			nRet := Min(nSldMed, nRet) // A quantidade não pode superar o saldo
			nRet := Round(nRet, TamSX3("CNE_QUANT")[2])
		EndIf
	EndIf
Else
	nRet := 0
EndIf

RestArea(aArea)
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121QtdBlq(cContra,cRevisa,cNumPla,cItem)
Função que verifica a quantidade de itens utilizado em medições
em aberto para composição do saldo fisico atual valido.

É necessário informar o contrato, revisão e numero da planilha.
- O não preenchimento do Item retorna o saldo bloqueado da planilha.
- O preenchimento do Item, retorna o saldo bloqueado daquele item na planilha.

@author Israel.Escorizza
@since 30/09/2015
@return nRet
/*/
//-------------------------------------------------------------------
Function Cn121QtdBlq(cContra,cRevisa,cNumPla,cItem, cFilCtr)
	Local nRet		:= 0
	Local cQuery 	:= ""
	Local aArea		:= GetArea()
	Local cAliasTmp	:= ""

	Default cContra	:= ""
	Default cRevisa	:= ""
	Default cNumPla	:= ""
	Default cItem	:= ""
	Default cFilCtr	:= cFilAnt

	If !(CN121RetSt("MULTIMED" ,0,cNumPla,cContra,.F., Nil))
		if _oQtdBlqIt == Nil
			
			cQuery += "SELECT SUM (CNE_QUANT) AS QTBLOQ FROM "+RetSQLName("CNE")+" CNE"
			cQuery += " INNER JOIN "+RetSQLName("CND")+" CND ON"
			cQuery += " (CND_FILIAL = CNE_FILIAL AND CND_CONTRA = CNE_CONTRA AND CND_REVISA = CNE_REVISA AND CND_NUMMED = CNE_NUMMED)"		
			cQuery += " WHERE"
			cQuery += " CNE_CONTRA = ?"
			cQuery += " AND CNE_REVISA = ?"
			cQuery += " AND CNE_NUMERO = ?"
			cQuery += " AND CNE_ITEM   = ?"
			cQuery += " AND CND_FILCTR = ?"//Filtra pela filial do contrato pra englobar qlq medição em qlq filial
			cQuery += " AND CND_SITUAC IN (?)"		
			cQuery += " AND CND.D_E_L_E_T_ = ?"
			cQuery += " AND CNE.D_E_L_E_T_ = ?"
			cQuery := ChangeQuery(cQuery)

			_oQtdBlqIt := FWExecStatement():New(cQuery)
		endif

		_oQtdBlqIt:SetString(1, cContra)
		_oQtdBlqIt:SetString(2, cRevisa)
		_oQtdBlqIt:SetString(3, cNumPla)
		_oQtdBlqIt:SetString(4, cItem)
		_oQtdBlqIt:SetString(5, cFilCtr)
		_oQtdBlqIt:SetIn(6, { 'A','B','SA' })		
		_oQtdBlqIt:SetString(7, Space(1))
		_oQtdBlqIt:SetString(8, Space(1))

		cAliasTmp := _oQtdBlqIt:OpenAlias()		

		nRet := (cAliasTmp)->QTBLOQ
		(cAliasTmp)->(dbCloseArea())
		
	EndIf
	
	RestArea(aArea)
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121VldQtd(oModelGrid,cField,xValue,nLine)
Função que valida a quantidade informada na medição.

@author Israel.Escorizza
@since 30/09/2015
@return nRet
/*/
//-------------------------------------------------------------------
Function Cn121VldQtd(oModelGrid,cField,xValue,nLine)
Local lRet		:= .T.
Local aArea		:= GetArea()
Local aSaveLines:= FWSaveRows()
Local oModel	:= Nil
Local oModelCXN	:= Nil
Local oModelCNE	:= Nil
Local cContra	:= ""
Local cRevisa	:= ""
Local cNumPla	:= ""
Local cItem		:= ""
Local cProdut	:= ""
Local nQuant	:= 0
Local nQtaMed	:= 0
Local nLimMed	:= 0
Local lRecorre	:= .F.
Local lFixo		:= .F.
Local lSemiFix	:= .F.
Local lSemiAgr	:= .F.
Local lLimFis	:= .F.
Local lPrevFin	:= .F.
Local lEventual	:= .F.
Local lFlex		:= .F.
Local lArrefat 	:= .F.
Local lFlexPrev := .F.
Local nDecVlTot	:= GetSx3Cache("CNE_VLTOT","X3_DECIMAL")
Local cFilCtr	:= cFilAnt

If (IsInCallStack('CNTA120') .Or. FwIsInCallStack('CN121OldMd')) .And. IsNotTEC930()
	lRet := CN130VldQtd()
ElseIf(!IsExced() .And. !CN121MdServ())
	oModel		:= FwModelActive()
	oModelCXN	:= oModel:GetModel("CXNDETAIL")
	oModelCNE	:= oModel:GetModel("CNEDETAIL")
	cContra		:= oModel:GetValue("CNDMASTER","CND_CONTRA")
	cRevisa		:= oModel:GetValue("CNDMASTER","CND_REVISA")
	cFilCtr		:= oModel:GetValue("CNDMASTER","CND_FILCTR")
	cNumPla		:= oModelCXN:GetValue("CXN_NUMPLA")
	cItem		:= oModelCNE:GetValue("CNE_ITEM")
	cProdut		:= oModelCNE:GetValue("CNE_PRODUT")
	nQuant		:= oModelCNE:GetValue("CNE_QUANT")
	nQtaMed		:= oModelCNE:GetValue("CNE_SDAMED")

	lRecorre	:= CN121RetSt("RECORRENTE" 	,0,cNumPla,cContra, .F.,/*oModel*/, cFilCtr)
	lFixo		:= CN121RetSt("FIXO"	   	,0,cNumPla,cContra, .F.,/*oModel*/, cFilCtr)
	lSemiFix	:= CN121RetSt("SEMIFIXO"	,0,cNumPla,cContra, .F.,/*oModel*/, cFilCtr)
	lSemiAgr	:= Cn121RetSt("SEMIAGRUP"	,0,cNumPla,cContra, .F.,/*oModel*/, cFilCtr)
	lLimFis		:= Cn121RetSt("LMTFISICO"	,0,cNumPla,cContra, .F.,/*oModel*/, cFilCtr)
	lPrevFin	:= CN121RetSt("PREVFINANC"	,0,cNumPla,cContra, .F.,/*oModel*/, cFilCtr)
	lEventual	:= CN121RetSt("EVENTUAL"	,0,cNumPla,cContra, .F.,/*oModel*/, cFilCtr)
	lServico	:= CN121RetSt("SERVIÇO"		,0,cNumPla,cContra, .F.,/*oModel*/, cFilCtr)
	lFlex		:= !lFixo .And. lPrevFin
	lArrefat 	:= SuperGetMv("MV_ARREFAT",.F.,"S")== "S"
	lFlexPrev 	:= lEventual .And. !lFixo .And. lPrevFin //Flexível com previsão financeira
	If lLimFis
		nLimMed	:= Cn121RetSt("LMTMED"	   	,0,cNumPla,cContra)
		nQtaMed *= 1+(nLimMed/100)
	EndIf

	If nQuant > 0 .AND. !lRecorre .AND. !lSemiFix .AND. !lFlex .And. !lEventual
		lRet := (nQuant <= nQtaMed)
		If !lRet 
			If ( ( nQuant - nQtaMed ) <= 0.001 ) .AND. !lArrefat
				lRet := .T.
			Else
				Help( ,, "CN121QTDE",, STR0183 + AllTrim(cItem) + " (" + cValToChar(nQuant) + ") " + STR0184 + " (" + cValToChar(nQtaMed) + ").", 1, 0,,,,,, {STR0185} ) //"A quantidade informada para o item " ## "é maior do que a quantidade disponível" ## "Informe uma quantidade válida para o item." 
			EndIF
		ElseIf !(lRet:=(Round(oModelCNE:GetValue("CNE_QUANT")*oModelCNE:GetValue("CNE_VLUNIT"),nDecVlTot)>0))
			cMsg := I18N(STR0238,{AllTrim(cItem)})
		 	oModel:SetErrorMessage("",,"CNEDETAIL","","CN121QTDEMIN",cMsg)
		EndIf
	EndIf

	If lRet .And. lSemiAgr
		lRet := C121CNEAgr(oModel,cField,xValue,nLine)
	EndIf
	
	If lRet .And. (CNE->(ColumnPos('CNE_15ANOS')) > 0 .And. CNE->(ColumnPos('CNE_20ANOS')) > 0 .And. CNE->(ColumnPos('CNE_25ANOS')) > 0)
		lRet := CnrTotItem(oModelCNE:GetValue("CNE_QUANT")*oModelCNE:GetValue("CNE_VLUNIT"))
	EndIf
EndIf

FWRestRows( aSaveLines )
FwFreeArray(aSaveLines)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121SldDis()
Função de inicializador padrão do saldo disponivel para medição.

@author Israel.Escorizza
@since 30/09/2015
@return nRet
/*/
//-------------------------------------------------------------------
Function CN121SldDis()
	Local oModel	:= FwModelActive()
	Local oModelCND	:= Nil
	Local oModelCXN	:= Nil
	Local cContra	:= ""
	Local cRevisa	:= ""
	Local cFilCtr	:= ""
	Local cNumPla	:= ""
	Local cItem		:= CNE->CNE_ITEM
	Local lInclui	:= oModel:GetOperation() == MODEL_OPERATION_INSERT
	Local lRecorre	:= .F.
	Local nQtdMed	:= 0
	Local nQtdBlq 	:= 0
	Local nRet		:= 0
	Local aAreaCNB	:= {}

	If !lInclui .And. CNE->CNE_EXCEDE <> "1"
		oModelCND	:= oModel:GetModel("CNDMASTER")
		oModelCXN	:= oModel:GetModel("CXNDETAIL")
		cContra		:= oModelCND:GetValue("CND_CONTRA")
		cRevisa		:= oModelCND:GetValue("CND_REVISA")
		cFilCtr		:= oModelCND:GetValue("CND_FILCTR")
		cNumPla		:= oModelCXN:GetValue("CXN_NUMPLA")
		If !CN121RetSt('SEMIFIXO',0,cNumpla,cContra)
			aAreaCNB := CNB->(GetArea())
			CNB->(dbSetOrder(1))
			If CNB->(MsSeek(xFilial('CNB', cFilCtr)+cContra+cRevisa+cNumPla+cItem))
				lRecorre:= CN121RetSt('RECORRENTE',0,cNumPla,cContra)
				nQtdMed := CNE->CNE_QUANT
				nQtdBlq := Cn121QtdBlq(cContra,cRevisa,cNumPla,cItem, cFilCtr)
				nRet 	:= CNB->CNB_SLDMED - nQtdBlq + nQtdMed

				If lRecorre
					If nQtdBlq > 0
						nRet := CNB->CNB_SLDMED
					Else
						nRet := 0
					EndIf
				EndIf
			EndIf
			RestArea(aAreaCNB)
			FwFreeArray(aAreaCNB)
		EndIf	
	EndIf
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121VlTab()
Função de gatilho do valor do produto baseado na tabela de preço.

@author Flavio Lopes Rasta
@since 07/12/2015
@return nRet
/*/
//-------------------------------------------------------------------
Function CN121VlTab()
Local oModel 	:= Nil
Local oModelCND := Nil
Local oModelCNE := Nil
Local oModelCXN := Nil

Local lFixo		:= .F.
Local lCompra	:= .F.
Local lAgrup 	:= .F.
Local lModel	:= .F.

Local dDataInic	:= sToD("")

Local cContra 	:= ""
Local cRevisa 	:= ""
Local cPlan		:= ""
Local cClieForn	:= ""
Local cLoja		:= ""
Local cProduto	:= ""
Local cCodTab	:= ""

Local nRet 		:= 0
Local nQtd		:= 0
Local nMoeda	:= 0

If IsInCallStack('CNTA121') .And. !FwIsInCallStack('CN121OldMd')
	lModel		:= .T.
	oModel 		:= FwModelActive()
	oModelCND 	:= oModel:GetModel('CNDMASTER')
	oModelCNE 	:= oModel:GetModel('CNEDETAIL')
	oModelCXN 	:= oModel:GetModel('CXNDETAIL')

	dDataInic	:= oModelCND:GetValue('CND_DTINIC')
	cContra 	:= oModelCND:GetValue('CND_CONTRA')
	cRevisa 	:= oModelCND:GetValue('CND_REVISA')
	nMoeda		:= oModelCND:GetValue('CND_MOEDA')

	cPlan		:= oModelCXN:GetValue('CXN_NUMPLA')
	cClieForn	:= oModelCXN:GetValue('CXN_FORCLI')
	cLoja		:= oModelCXN:GetValue('CXN_LOJA')

	cProduto	:= oModelCNE:GetValue('CNE_PRODUT')
	cCodTab		:= oModelCNE:GetValue('CNE_TABPRC')
	nQtd		:= oModelCNE:GetValue('CNE_QUANT')

ElseIf (IsInCallStack('CNTA120') .Or. FwIsInCallStack('CN121OldMd'))
	dDataInic	:= CND->CND_DTINIC
	cContra 	:= CND->CND_CONTRA
	cRevisa 	:= CND->CND_REVISA
	cPlan		:= CND->CND_NUMERO
	cClieForn	:= Iif(!Empty(CND->CND_FORNEC),CND->CND_FORNEC,CND->CND_CLIENT)
	cLoja		:= Iif(!Empty(CND->CND_LJFORN),CND->CND_LJFORN,CND->CND_LOJACL)
	nMoeda		:= CND->CND_MOEDA

	cProduto	:= aCols[IIf(lAuto,n,oGetDados:nAt),aScan(aHeader,{|x| x[2] == "CNE_PRODUT"})]
	cCodTab		:= aCols[IIf(lAuto,n,oGetDados:nAt),aScan(aHeader,{|x| x[2] == "CNE_TABPRC"})]
	nQtd		:= If( M->CNE_QUANT == NIL , CNE->CNE_QUANT , M->CNE_QUANT ) 

EndIf

lFixo	:= Cn300RetSt('FIXO'		,0,cPlan,cContra,,lModel)
lCompra	:= Cn300RetSt('COMPRA'		,0,cPlan,cContra,,lModel)
lAgrup 	:= Cn300RetSt('SEMIAGRUP'	,0,cPlan,cContra,,lModel)

nQtd := Iif(nQtd == 0,1,nQtd)

If Empty(cCodTab)
	If Empty(cCodTab := Cn121SkTbP(oModelCNE))
		cCodTab	:= Posicione("SA1",1,xFilial("SA1")+cClieForn+cLoja,"A1_TABELA")
	EndIf
	oModelCNE:LoadValue('CNE_TABPRC',cCodTab)
EndIf
nRet := MaTabPrVen(cCodTab,cProduto,nQtd,cClieForn,cLoja,nMoeda,dDataInic)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121SkTbP
Função para buscar a tabela de preço para itens de medições excedentes

@author Israel.escorizza
@since 14/09/2017
@return cCodTbPr
/*/
//-------------------------------------------------------------------
Function Cn121SkTbP(oModelCNE)
Local cCodTbPr 	:= ""
Local cCodProd	:= oModelCNE:GetValue('CNE_PRODUT')
Local nLine	  	:= oModelCNE:GetLine()
Local nX		:= 1

While Empty(cCodTbPr) .And. nX <= oModelCNE:Length()
	oModelCNE:GoLine(nX)
	If AllTrim(oModelCNE:GetValue('CNE_PRODUT')) == AllTrim(cCodProd)
		cCodTbPr := oModelCNE:GetValue('CNE_TABPRC')
	EndIf
	nX++
End

oModelCNE:GoLine(nLine)
Return cCodTbPr

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121CondG()
Função para tratar condição de execução do gatilho do valor do
produto baseado na tabela de preço.

@author Flavio Lopes Rasta
@since 07/12/2015
@return nRet
/*/
//-------------------------------------------------------------------
Function CN121CondG()
Local oModel 	:= Nil

Local lRet 		:= .F.
Local lFixo		:= .F.
Local lSemiPro	:= .F.
Local lAgrup 	:= .F.
Local lExced	:= .F.
Local lModel	:= .F.

Local cContra 	:= ""
Local cPlan		:= ""
Local cTabPrc	:= ""
Local lTECA930	:= FindFunction("TEC930autG") .AND. TEC930autG()

If (IsInCallStack('CNTA121') .And. !FwIsInCallStack('CN121OldMd')) .OR. lTECA930
	lModel		:= .T.
	oModel		:= FwModelActive()
	cContra 	:= oModel:GetValue('CNDMASTER','CND_CONTRA')
	cPlan		:= oModel:GetValue('CXNDETAIL','CXN_NUMPLA')
	cTabPrc		:= oModel:GetValue('CNEDETAIL','CNE_TABPRC')
	lExced		:= (lExcedMEnc .Or. lExcedNPrv)
ElseIf (IsInCallStack('CNTA120') .Or. FwIsInCallStack('CN121OldMd'))
	cContra 	:= CND->CND_CONTRA
	cPlan		:= CND->CND_NUMERO
	cTabPrc		:= aCols[If(lAuto,n,oGetDados:nAt),aScan(aHeader,{|x| x[2] == "CNE_TABPRC"})]			//CNE->CNE_TABPRC
	lExced		:= aCols[If(lAuto,n,oGetDados:nAt),aScan(aHeader,{|x| x[2] == "CNE_EXCEDE"})] == '1'  	//CNE->CNE_EXCEDE == '1'
EndIF

If !Empty(cTabPrc)
	lFixo		:= Cn300RetSt('FIXO'	 ,0,cPlan,cContra,,lModel)
	lSemiPro	:= Cn300RetSt('SEMIPROD' ,0,cPlan,cContra,,lModel)
	lAgrup 		:= Cn300RetSt('SEMIAGRUP',0,cPlan,cContra,,lModel)

	If (!lFixo .And. !lSemiPro) .Or. lAgrup .Or. lExced
		lRet := .T.
	Endif
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121LimPla()
Função que verifica o percentual limite da planilha, retornando:
.T. para limite dentro do percentual ou
.F. para limite fora do percentual.

@author Israel Escorizza
@since 05/01/2016
@return lRet
/*/
//-------------------------------------------------------------------
Function CN121LimPla(oModel)
Local aAreas	:= {CNA->(GetArea()), CNF->(GetArea()), CNS->(GetArea()), GetArea()}
Local aSaveLines:= FWSaveRows()
Local oModelCND := Nil
Local oModelCXN	:= Nil
Local oModelCNE	:= Nil
Local cFilCTR 	:= ""
Local cMedCpt	:= ""
Local cCtrNum	:= ""
Local cCtrRev	:= ""
Local cPlaNum	:= ""
Local cParcel	:= ""
Local cCronog	:= ""
Local nVlExec	:= 0
Local nTamVlTot	:= TamSX3("CND_VLTOT")[2]
Local nMedLmt 	:= 0
Local nX	    := 0
Local nMoedaCtr := 1
Local nMoedaMed := 1
Local lUpdFrn	:= .F.
Local lMedEve 	:= .F.
Local lRecorre	:= .F.
Local lSemiAgr	:= .F.
Local lEventua	:= .F.
Local lLmtFis 	:= .F.
Local lLmtFin	:= .F.
Local lRet 		:= .T.
Local lMultiMed	:= .F.
Local dDataInic := CToD("//")
Local nLimite   := 0.01
Local nSaldoPlan := 0
Local nRealizado := 0
Default oModel  := FWModelActive()

oModelCND := oModel:GetModel('CNDMASTER')
oModelCXN := oModel:GetModel('CXNDETAIL')
oModelCNE := oModel:GetModel('CNEDETAIL')

cMedCpt		:= oModelCND:GetValue("CND_COMPET")
cCtrNum		:= oModelCND:GetValue("CND_CONTRA")
cFilCTR		:= oModelCND:GetValue("CND_FILCTR")
cCtrRev		:= oModelCND:GetValue("CND_REVISA")
nMoedaMed	:= oModelCND:GetValue("CND_MOEDA")
dDataInic	:= oModelCND:GetValue('CND_DTINIC')

cPlaNum	:= oModelCXN:GetValue("CXN_NUMPLA")
cParcel := oModelCXN:GetValue("CXN_PARCEL")

cCronog	:= Posicione("CNA",1,xFilial("CNA",cFilCTR)+cCtrNum+cCtrRev+cPlaNum,"CNA_CRONOG")
lUpdFrn	:= oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. oModelCND:GetValue("CND_AUTFRN") == "2"

nMedLmt		:= CN121RetSt("LMTMED"			,0,cPlaNum,cCtrNum,.T.,oModel)
lMedEve 	:= CN121RetSt("MEDEVE"			,0,cPlaNum,cCtrNum,.T.,oModel)
lRecorre 	:= CN121RetSt("RECORRENTE"		,0,cPlaNum,cCtrNum,.T.,oModel)
lSemiAgr 	:= CN121RetSt("SEMIAGRUP"		,0,cPlaNum,cCtrNum,.T.,oModel)
lEventua 	:= CN121RetSt("EVENTUAL"		,0,cPlaNum,cCtrNum,.T.,oModel)
lLmtFis 	:= CN121RetSt("LMTFISICO"		,0,cPlaNum,cCtrNum,.T.,oModel)
lLmtFin		:= CN121RetSt("LMTFINANCEIRO"	,0,cPlaNum,cCtrNum,.T.,oModel)
lMultiMed	:= CN121RetSt("MULTIMED"		,0,cPlaNum,cCtrNum,.F.,nil, cFilCTR)
nMoedaCtr	:= CN121RetSt("MOEDACTR"		,0,cPlaNum,cCtrNum,.F.,nil, cFilCTR)

//-- Ponto de entrada para informar se deve ou não validar limites da planilha
If Existblock("CN121VPA") .And. !ExecBlock("CN121VPA",.F.,.F.)
	Return .T.
EndIf

If oModelCXN:GetValue("CXN_CHECK") .And. (lLmtFis .Or. lLmtFin) .And. ((lMultiMed .And. !lEncerra .And. oModelCXN:IsUpdated()) .Or. (lEncerra .And. !lMultiMed))
	
	If !lMedEve .AND. !lRecorre .AND. !lSemiAgr .And. !lEventua		
		dbSelectArea("CNF")

		If !Empty(oModelCXN:GetValue("CXN_PARCEL"))
			CNF->(dbSetOrder(3))
			CNF->(MsSeek(xFilial("CNF",cFilCTR)+cCtrNum+cCtrRev+cCronog+cParcel))
		Else
			CNF->(dbSetOrder(2))
			CNF->(MsSeek(xFilial("CNF",cFilCTR)+cCtrNum+cCtrRev+cCronog+cMedCpt))
		EndIf

		If CNF->(Found())
			
			cParcel := CNF->CNF_PARCEL
			
			If !lLmtFis .And. !lMultiMed
				
				//-- Soma o limite de medicao ao saldo da parcela 
				nVlExec := oModelCXN:GetValue("CXN_VLLIQD") - CN120VlExc()
				nVlExec := Round( nVlExec, nTamVlTot )
				nVlExec := xMoeda(nVlExec, nMoedaMed, nMoedaCtr, dDataInic, nTamVlTot)

				If lRet .And. ( nVlExec > Round((CNF->CNF_VLPREV * (1+(nMedLmt/100))) - Iif(lUpdFrn,0,CNF->CNF_VLREAL), nTamVlTot))
					Help("",1,STR0079,,STR0146+cPlaNum+STR0147+CRLF+STR0148,1,1) //- Valor total da planilha | #NUMERO# | não previsto no cronograma. | O mesmo deve ser reestruturado.
					lRet := .F.
				EndIf
			Else				
				CNS->( dbSetOrder(1) )
				
				//-- Valida a quantidade medida contra a quantidade prevista no cronograma
				For nX := 1 To oModelCNE:Length()					
					oModelCNE:GoLine( nX )
					
					If CNS->( dbSeek( xFilial( 'CNS' , cFilCTR ) + cCtrNum + cCtrRev + cCronog + cParcel + oModelCNE:GetValue( 'CNE_ITEM' ) ) )
						
						nLmtQtd	:= CNS->CNS_PRVQTD * ( 1 + ( nMedLmt / 100 ) )
						
						If oModelCNE:GetValue( 'CNE_QUANT' ) > nLmtQtd
							Help( "" , 1 , STR0079 , , STR0149 + oModelCNE:GetValue('CNE_ITEM') + STR0150 , 1 , 1 ) //Item #ITEM# ultrapassou o limite de medição do cronograma físico"
							lRet := .F.
							Exit
						EndIf
					
					EndIf
				
				Next nX

			EndIf
			
		EndIf
		
		
	
	ElseIf lLmtFin .And. !lEventua .And. !lRecorre 		//- Se Limite Financeiro.!lMedEve .AND. !lRecorre .AND. !lSemiAgr .And. !lEventua
		
		CNA->(dbSetOrder(1))		
		If (lRet := CNA->(MsSeek(xFilial("CNA",cFilCTR)+cCtrNum+cCtrRev+cPlaNum)))			
			nSaldoPlan := CNA->CNA_SALDO*(1+(nMedLmt/100))
			nSaldoPlan := NoRound(nSaldoPlan, GetSX3Cache("CNA_SALDO","X3_DECIMAL")) + nLimite

			nRealizado := (oModelCXN:GetValue("CXN_VLLIQD") - CN120VlExc())
			nRealizado := NoRound(nRealizado, GetSX3Cache("CXN_VLLIQD","X3_DECIMAL"))

			lRet :=  (nSaldoPlan >= nRealizado)
		EndIf

		If !lRet
			Help("",1,STR0079,,STR0146+cPlaNum+STR0151+CRLF+STR0148,1,1) //- Valor total da planilha | #NUMERO# | ultrapassa o saldo disponivel. | O mesmo deve ser reestruturado.			
		EndIf
		
	EndIf

EndIf

FWRestRows(aSaveLines)
FwFreeArray(aSaveLines)
aEval(aAreas,{|x| RestArea(x) })
FwFreeArray(aAreas)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121AtuRat(nValor)
Função para preenchimento e atualização dos valores em diferentes moedas
na aba de rateio da medição

@author israel.escorizza
@since 26/02/2016
@return
/*/
//-------------------------------------------------------------------
Function Cn121AtuRat(nValor, nPerc, lTrigger as Logical)
	Local aArea		:= GetArea()
	Local aRows		:= FWSaveRows()
	Local oModel 	:= FwModelActive()
	Local oView     := FWViewActive()
	Local lCNTA121  := oModel:GetId() == 'CNTA121'
	Local oModItem	:= oModel:GetModel(IIF(lCNTA121,'CNEDETAIL','CNBDETAIL'))
	Local oModelCNZ := oModel:GetModel('CNZDETAIL')
	Local nX		:= 0
	Local nVlrRat	:= 0
	Local nVlrPer	:= 0
	Local aCampos	:=	{{'CNZDETAIL',{'CNZ_VALOR1','CNZ_VALOR2','CNZ_VALOR3','CNZ_VALOR4','CNZ_VALOR5'}}}
	Local lDelLn	:= .F.
	Local xRet		:= Nil
	Local lRefresh	:= .F.
	Default nValor	:= oModItem:GetValue(IIF(lCNTA121,'CNE_VLTOT','CNB_VLTOT'))
	Default lTrigger:= .F.

	MtBCMod(oModel,aCampos,{||.T.},'2')
	If nPerc == Nil
		For nX := 1 To oModelCNZ:Length()
			oModelCNZ:GoLine(nX)

			If (lDelLn := oModelCNZ:IsDeleted())
				oModelCNZ:UnDeleteLine()
			EndIf

			nVlrPer := oModelCNZ:GetValue('CNZ_PERC')
			If !Empty(nVlrPer)
				nVlrRat := nValor * (nVlrPer / 100)
				oModelCNZ:SetValue("CNZ_VALOR1",nVlrRat)
				oModelCNZ:SetValue("CNZ_VALOR2",xMoeda(nVlrRat,1,2,dDatabase))
				oModelCNZ:SetValue("CNZ_VALOR3",xMoeda(nVlrRat,1,3,dDatabase))
				oModelCNZ:SetValue("CNZ_VALOR4",xMoeda(nVlrRat,1,4,dDatabase))
				oModelCNZ:SetValue("CNZ_VALOR5",xMoeda(nVlrRat,1,5,dDatabase))
				If (!lRefresh)
					lRefresh := .T.
				EndIf
			EndIf

			If lDelLn
				oModelCNZ:DeleteLine()
				oModelCNZ:GoLine(nX)
			EndIf

		Next nX
	Else
		nVlrRat := nValor * (nPerc / 100)
		If lTrigger
			xRet := nVlrRat
		Else
			oModelCNZ:SetValue("CNZ_VALOR1",nVlrRat)
		EndIf
		oModelCNZ:SetValue("CNZ_VALOR2",xMoeda(nVlrRat,1,2,dDatabase))
		oModelCNZ:SetValue("CNZ_VALOR3",xMoeda(nVlrRat,1,3,dDatabase))
		oModelCNZ:SetValue("CNZ_VALOR4",xMoeda(nVlrRat,1,4,dDatabase))
		oModelCNZ:SetValue("CNZ_VALOR5",xMoeda(nVlrRat,1,5,dDatabase))
		lRefresh := .T.
	EndIf
	MtBCMod(oModel,aCampos,{||.F.},'2')

	FWRestRows(aRows)
	FwFreeArray(aRows)
	RestArea(aArea)

	If lRefresh
		lRefresh := !FwIsInCallStack("CN121CNZIt") .And.;	//Nao dá refresh na carga dos itens da medição
					!FwIsInCallStack("CN300AddPrd") .And.;	//Não dá refresh na carga dos itens da SC no contrato
					!FwIsInCallStack("CN300AddPC")			//Não dá refresh na carga dos itens do PC no contrato
	EndIf

	If lRefresh
		If (ValType(oView) == "O" .And. oView:IsActive() .And. oView:oModel:GetId() $ 'CNTA121|CNTA300|CNTA301')
			oView:Refresh("VIEW_CNZ")
		EndIf
	EndIf

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121AtuTes()
Função para preenchimento do campo virtual CNE_TES de acordo com produto
informado.

@author israel.escorizza
@since 26/02/2016
@return
/*/
//-------------------------------------------------------------------
Function CN121AtuTes()
Local aArea		:= GetArea()
Local aSaveLines:= FwSaveRows()
Local oModel 	:= FwModelActive()
Local oModelCNE := oModel:GetModel('CNEDETAIL')
Local cContra	:= oModel:GetValue('CNDMASTER','CND_CONTRA')
Local cPlan		:= oModel:GetValue('CXNDETAIL','CXN_NUMPLA')
Local cProd		:= oModelCNE:GetValue('CNE_PRODUT')
Local cValor	:= ""

If !CN121RetSt('FIXO',,cPlan,cContra)
	If CN121RetSt('COMPRA',,,cContra)
		cValor := 	GctGatTes(cProd,.T.)
	Else
		cValor := 	GctGatTes(cProd,.F.)
	EndIf
EndIf

FWRestRows(aSaveLines)
RestArea(aArea)

Return AllTrim(cValor)

//-------------------------------------------------------------------
/*/{Protheus.doc} A121VldGat(cDomin,cCDomin,cSeq)
Função para validação de gatilho para impedir loops
@author israel.escorizza
@since 25/04/2016
@return
/*/
//-------------------------------------------------------------------
Function A121VldGat(cDomin,cCDomin,cSeq)
Local lRet 		:= .F.
Local lFixo 	:= .F.
Local lCompra 	:= .F.
Local lCnta120	:= (FwIsInCallStack('CNTA120') .Or. FwIsInCallStack('CN121OldMd'))

Local oModel	:= Nil
Local oModelCNE	:= Nil
Local cProdut	:= ""
Local nQtdOri	:= 0
Local nQtdSol	:= 0
Local nQuant	:= 0
Local nPerc		:= 0
Local nVUnOri	:= 0
Local nVlUnit	:= 0
Local nVlTot	:= 0
Local nPDesc	:= 0
Local nValDescnt:= 0
Local nDecPdesc	:= 0
Default cDomin	:= ""
Default cCDomin	:= ""
Default cSeq 	:= ""

If lCnta120 .And. IsNotTEC930()
	If INCLUI
		lFixo 	:= Cn300RetSt('FIXO',	0,cPlan,cContra,cFilCtr,.F.)
		lCompra := Cn300RetSt('COMPRA',	0,cPlan,cContra,cFilCtr,.F.)
	Else
		lFixo 	:= Cn300RetSt('FIXO',	0,CND->CND_NUMERO,CND->CND_CONTRA,CND->CND_FILCTR,.F.)
		lCompra := Cn300RetSt('COMPRA',	0,CND->CND_NUMERO,CND->CND_CONTRA,CND->CND_FILCTR,.F.)
	EndIf

	DO CASE
		CASE cDomin == "CNE_PRODUT" .And. cCDomin == "CNTA120" .And. !lFixo
			lRet := .T.

		CASE cDomin == "CNE_QUANT"
			If cCDomin == "CNE_PERC" .And. lFixo .And. !Empty(ACOLS[N, ASCAN(AHEADER,{|X| X[2] == "CNE_QTDSOL"})])	//-SEQ001
				lRet := .T.
			EndIf

			If cCDomin == "CNE_VLTOT"								//-SEQ002
				lRet := .T.
			EndIf

			If cCDomin == "CNE_VLDESC" .And. lCompra	//-SEQ003
				lRet := .T.
			EndIf

		CASE cDomin == "CNE_PERC"
			If cCDomin == "CNE_QUANT" .And. !A121Servico() //-SEQ001
				lRet := .T.
			EndIf

			If cCDomin == "CNE_VLTOT"  .And. !A121Servico() .And. cSeq == "2" 			 					//-SEQ002
				lRet := .T.
			EndIf

			If cCDomin == "CNE_VLDESC" .And. CN121RetSt("COMPRA")	//-SEQ003
				lRet := .T.
			EndIf

			If 	lFixo .And. A121Servico()
				If cCDomin == "CNE_QTDORI"								//-SEQ004
					lRet := .T.
				EndIf

				If cCDomin == "CNE_VLTOT" .And. cSeq == "5" 												//-SEQ005
					lRet := .T.
				EndIf

				If cCDomin == "CNE_VLUNIT"								//-SEQ006
					lRet := .T.
				EndIf
			EndIf

		CASE cDomin == "CNE_VLTOT"
			If cCDomin == "CNE_QUANT" .And. !A121Servico()			//-SEQ001
				lRet := .T.
			EndIf

			If cCDomin == "CNE_VLDESC" .And. CN121RetSt("COMPRA")   //-SEQ002
				lRet := .T.
			EndIf

			If cCDomin == "CNE_PERC" .And. lFixo .And. !A121Servico()	//-SEQ003
				nPerc := aScan(aHeader,{|x| AllTrim(x[2])=="CNE_PERC"})
				nQtd := aScan(aHeader,{|x| AllTrim(x[2])=="CNE_QUANT"})
				nQtdSol := aScan(aHeader,{|x| AllTrim(x[2])=="CNE_QTDSOL"})

				aCols[n,nPerc] := (aCols[n,nQtd]/aCols[n,nQtdSol]) * 100
				lRet := .F.
			EndIf

			If lFixo .And. A121Servico()
				If cCDomin == "CNE_QTDORI"								//-SEQ004
					lRet := .T.
				EndIf

				If cCDomin == "CNE_VLUNIT"								//-SEQ006
					lRet := .T.
				EndIf
			EndIf

		CASE cDomin == "CNE_VLUNIT"
			If cCDomin	== "CNE_VLTOT"
				If cSeq == "1"
					If !A121Servico()	//- SEQ001
						lRet := .T.
					EndIf
				ElseIf cSeq == "2"
					If lFixo .And. A121Servico()	//- SEQ002
						lRet := .T.
					EndIf
				EndIf
			EndIf

			If cCDomin == "CNE_QTDORI" .And. lFixo .And. A121Servico() .And. CN130GATCNE(3)//- SEQ003
				lRet := .T.
			EndIf

			If cCDomin == "CNE_PERC" .And. lFixo .And. A121Servico() .And. CN130GATCNE(4) 	 //- SEQ004
				lRet := .T.
			EndIf

		CASE cDomin == "CNE_PDESC"
			lRet := .T.

		ENDCASE
Else
	oModel		:= FWModelActive()
	oModelCNE	:= oModel:GetModel("CNEDETAIL")
	cProdut		:= oModelCNE:GetValueByPos(GetPosCpo(oModel,"CNE_PRODUT"))
	nQtdOri		:= oModelCNE:GetValueByPos(GetPosCpo(oModel,"CNE_QTDORI"))
	nQtdSol		:= oModelCNE:GetValueByPos(GetPosCpo(oModel,"CNE_QTDSOL"))
	nQuant		:= oModelCNE:GetValueByPos(GetPosCpo(oModel,"CNE_QUANT"))
	nPerc		:= oModelCNE:GetValueByPos(GetPosCpo(oModel,"CNE_PERC"))
	nVUnOri		:= oModelCNE:GetValueByPos(GetPosCpo(oModel,"CNE_VUNORI"))
	nVlUnit		:= oModelCNE:GetValueByPos(GetPosCpo(oModel,"CNE_VLUNIT"))
	nVlTot		:= oModelCNE:GetValueByPos(GetPosCpo(oModel,"CNE_VLTOT"))
	nPDesc		:= oModelCNE:GetValueByPos(GetPosCpo(oModel,"CNE_PDESC"))
	
	cContra		:= oModel:GetValue('CNDMASTER','CND_CONTRA')
	cNumPla		:= oModel:GetValue('CXNDETAIL','CXN_NUMPLA')
	cFilCtr		:= oModel:GetValue('CNDMASTER','CND_FILCTR')

	lFixo 	:= Cn121RetSt('FIXO'  ,0,cNumPla,cContra,.T.,oModel,cFilCtr)
	lCompra	:= Cn121RetSt('COMPRA',0,cNumPla,cContra,.T.,oModel,cFilCtr)

	If(cCDomin == "CNE_VLDESC")
		If nPDesc > 0
			If lCompra
				nValDescnt := CNEVLDesc(nVlTot, nPDesc)
			Else
				nValDescnt := CtrValDesc("2",;
										nVlTot,;
										nPDesc,;
										nVlUnit,;
										nQuant )
			EndIf
		Else
			nValDescnt := 0
		EndIf		
		oModelCNE:LdValueByPos(GetPosCpo(oModel, cCDomin), nValDescnt)
	EndIf

	DO CASE
		CASE cDomin == "CNE_PRODUT" 
			If(cCDomin == "CNTA121")
				lRet := (!lFixo)				
				If(Empty(oModelCNE:GetValue("CNE_ITEMGR")) .And. Cn121RetSt("SEMIAGRUP",0,oModel:GetValue('CXNDETAIL','CXN_NUMPLA')))
					oModelCNE:LoadValue("CNE_ITEMGR", CN121ItId(oModel))//A partir do release 12.1.27, remover esse trecho, sera preenchido por gatilho
				EndIf				
			ElseIf(cCDomin == "CNE_ITEMGR" .And. Cn121RetSt("SEMIAGRUP",0,oModel:GetValue('CXNDETAIL','CXN_NUMPLA')))
				lRet := .T.
			EndIf		
		CASE cDomin == "CNE_QUANT"
			If cCDomin == "CNE_PERC" .And. lFixo .And. !CN121MdServ()		//-SEQ001				
				oModelCNE:LdValueByPos(GetPosCpo(oModel, cCDomin),NoRound(nQuant / nQtdSol * 100,GetSx3Cache("CNE_PERC","X3_DECIMAL")))
			EndIf

			If cCDomin == "CNE_VLTOT"								//-SEQ002				
				lRet := !CNNoWhenSet(oModelCNE, cCDomin, (nVlUnit * nQuant))				
			EndIf
		CASE cDomin == "CNE_PERC"
			If cCDomin == "CNE_QUANT" .And. !A121Servico() .And. nQtdSol > 0//-SEQ001				
				oModelCNE:SetValue(cCDomin,NoRound((nQtdSol * nPerc)/100,GetSx3Cache("CNE_QUANT","X3_DECIMAL")))
			EndIf

			If cCDomin == "CNE_VLTOT"  .And. !A121Servico() .And. oModelCNE:GetValue('CNE_VLTOT') != (nVlUnit * nQuant)	//-SEQ002
				oModelCNE:SetValue(cCDomin,nVlUnit * nQuant)
			EndIf

			If 	lFixo .And. A121Servico()
				If cCDomin == "CNE_QTDORI"								//-SEQ004
					oModelCNE:LoadValue(cCDomin,nQtdSol * nPerc / 100)
				EndIf

				If cCDomin == "CNE_VLTOT"								//-SEQ005
					oModelCNE:LoadValue(cCDomin,nVUnOri * nQtdOri)
				EndIf

				If cCDomin == "CNE_VLUNIT"								//-SEQ006
					oModelCNE:LoadValue(cCDomin,nVlTot)
				EndIf
			EndIf

		CASE cDomin == "CNE_VLTOT"
			If CN121MdServ()				
				oModelCNE:LoadValue("CNE_VLUNIT", nVlTot)
				oModelCNE:LoadValue('CNE_PERC'	, ( nVlTot / (nVUnOri * nQtdSol) ) * 100)
				Return .F.
			EndIf
			If cCDomin == "CNE_QUANT" .And. !A121Servico()			//-SEQ001							
				oModelCNE:LdValueByPos(GetPosCpo(oModel, cCDomin)	, Round( nVlTot / nVlUnit, GetSx3Cache("CNE_QUANT","X3_DECIMAL")))
				oModelCNE:LdValueByPos(GetPosCpo(oModel, 'CNE_PERC'), NoRound(oModelCNE:GetValue('CNE_QUANT') / nQtdSol * 100,GetSx3Cache("CNE_PERC","X3_DECIMAL")))
			EndIf					

			If lFixo			
				If A121Servico()
					If cCDomin == "CNE_QTDORI"								//-SEQ004
						oModelCNE:LoadValue(cCDomin,nVlTot / nVUnOri)
					EndIf

					If cCDomin == "CNE_PERC"									//-SEQ005
						oModelCNE:LoadValue(cCDomin,nQtdOri * 100)
					EndIf
					
				ElseIf (cCDomin == "CNE_PERC")//-SEQ003								
					oModelCNE:LdValueByPos(GetPosCpo(oModel, cCDomin),NoRound(nQuant/nQtdSol * 100,GetSx3Cache("CNE_PERC","X3_DECIMAL")))
				EndIf
			EndIf

		CASE cDomin == "CNE_VLUNIT"			

			If cCDomin == "CNE_QTDORI" .And. lFixo .And. !A121Servico() //- SEQ003
				oModelCNE:LoadValue(cCDomin,FwFldGet('CNE_VLTOT')/FwFldGet('CNE_VUNORI'))
			EndIf

			If cCDomin == "CNE_PERC" .And. lFixo .And. !A121Servico()	 //- SEQ004
				oModelCNE:LdValueByPos(GetPosCpo(oModel, cCDomin),NoRound(nQuant / nQtdSol * 100,GetSx3Cache("CNE_PERC","X3_DECIMAL")))
			EndIf	
		CASE cDomin == "CNE_VLDESC"
			IF cCDomin == "CNE_PDESC"
				nDecPDesc	:= GetSx3Cache("CNE_PDESC","X3_DECIMAL")
				nPDesc		:= NoRound(oModelCNE:GetValue("CNE_VLDESC") / oModelCNE:GetValue("CNE_VLTOT") * 100,nDecPDesc)
				oModelCNE:LoadValue("CNE_PDESC",nPDesc)
				lRet:= .F.
			EndIf
	ENDCASE
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A121QtdSrv(cContra,cRevisa,cNumPla,cItem)
Função que retorna a quantidade de itens de serviço a ser medido de acordo com a
competencia da medição em comparação com medições já realizadas anteriormente.
@author israel.escorizza
@since 25/04/2016
@return
/*/
//-------------------------------------------------------------------
Function A121QtdSrv(cContra,cRevisa,cNumPla,cItem,cCompet)
Local aArea		:= GetArea()
Local aSaveLines:= FwSaveRows()
Local oModel	:= FwModelActive()
Local cAliasCNE	:= GetNextAlias()
Local cQuery	:= ""
Local nRet		:= 0
Local cNumpar	:= ""
Local cFilCtr	:= ""

Default cContra	:= ""
Default cRevisa	:= ""
Default cCompet	:= ""
Default cNumPla	:= ""
Default cItem	:= ""

If oModel:IsActive() .And. oModel:GetId() == "CNTA121"

	cContra 	:= Iif(Empty(cContra),	oModel:GetValue('CNDMASTER','CND_CONTRA'),cContra)
	cRevisa 	:= Iif(Empty(cRevisa),	oModel:GetValue('CNDMASTER','CND_REVISA'),cRevisa)
	cCompet 	:= Iif(Empty(cCompet),	oModel:GetValue('CNDMASTER','CND_COMPET'),cCompet)
	cNumPla 	:= Iif(Empty(cNumPla),	oModel:GetValue('CXNDETAIL','CXN_NUMPLA'),cNumPla)
	cNumpar		:= oModel:GetValue('CXNDETAIL','CXN_PARCEL')
	cItem 		:= Iif(Empty(cItem),		oModel:GetValue('CNEDETAIL','CNE_ITEM'),	cItem	)	
	cFilCtr		:= oModel:GetValue('CNDMASTER','CND_FILCTR')

	cQuery	+= 	" SELECT COUNT(*) AS CNE_QTDREG "
	cQuery	+= 	" FROM "
	cQuery += 	RetSQLName("CNE") + " CNE "

	cQuery	+= 	" INNER JOIN "
	cQuery += 	RetSQLName("CND") + " CND "
	cQuery	+=	" ON "
	cQuery	+=	" CNE.CNE_FILIAL = CND.CND_FILIAL AND "
	cQuery	+=	" CNE.CNE_CONTRA = CND.CND_CONTRA AND "
	cQuery	+=	" CNE.CNE_REVISA = CND.CND_REVISA AND "
	cQuery	+=	" CNE.CNE_NUMMED = CND.CND_NUMMED "
	
	cQuery	+= 	" INNER JOIN "
	cQuery += 	RetSQLName("CXN") + " CXN "
	cQuery	+=	" ON "	
	cQuery	+=	" CXN.CXN_FILIAL = CND.CND_FILIAL AND "
	cQuery	+=	" CXN.CXN_CONTRA = CND.CND_CONTRA AND "
	cQuery	+=	" CXN.CXN_REVISA = CND.CND_REVISA AND "  
	cQuery	+=	" CXN.CXN_NUMMED = CND.CND_NUMMED AND "
	cQuery	+=	" CXN.CXN_PARCEL = '"+cNumpar+"' "	
	
	cQuery	+= 	" WHERE "
	cQuery += 	" CND.CND_FILIAL = '" + xFilial("CND", cFilCtr) + "' AND "
	cQuery += 	" CND.CND_CONTRA = '" + cContra + "' AND "
	cQuery += 	" CND.CND_REVISA = '" + cRevisa + "' AND "
	cQuery += 	" CND.CND_COMPET = '" + cCompet + "' AND "
	cQuery += 	" CNE.CNE_NUMERO = '" + cNumPla + "' AND "
	cQuery += 	" CNE.CNE_ITEM   = '" + cItem   + "' AND "
	cQuery +=	" CND.D_E_L_E_T_ = ' ' AND "
	cQuery +=	" CNE.D_E_L_E_T_ = ' ' "

	cQuery  := ChangeQuery( cQuery )
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), cAliasCNE,.T.,.T.)

	If (cAliasCNE)->CNE_QTDREG == 0
		nRet := 1
	EndIf

	(cAliasCNE)->(dbCloseArea())
EndIf

FWRestRows(aSaveLines)
RestArea(aArea)
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121VldRt(oModelCNE)
Função que valida rateio dos itens da planilha posicionada.
@author israel.escorizza
@since 23/05/2016
@return lRet
/*/
//-------------------------------------------------------------------
Function CN121VldRt(oModelCNE)
Local aArea		:= GetArea()
Local aSaveLines:= FwSaveRows()
Local oModel	:= Nil
Local lRet 		:= .T.
Local nX		:= 1

Default oModelCNE := Nil

If oModelCNE == Nil
	oModel := FwModelActive()
	If oModel:IsActive() .And. oModel:GetId() == 'CNTA121'
		oModelCNE	:= oModel:GetModel('CNEDETAIL')
	EndIf
EndIf

While lRet .And. nX <= oModelCNE:Length()
	oModelCNE:GoLine(nX)
	If !oModelCNE:IsDeleted()
		lRet := CN300VldRat(.F.)
	EndIf
	nX++
EndDo

FWRestRows(aSaveLines)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} C121AtuCXJ
Função que atualiza numero do pedido/titulo na CXJ após inclusão em casos que a
numeração solicitada não tenha sido valida.

@author israel.escorizza
@since 08/11/2016
@return Nil
/*/
//-------------------------------------------------------------------
Function C121AtuCXJ(oModel,cAtuCpo,cNumDoc,aDocs,cChavC7)
Local aSaveLines:= FwSaveRows()
Local oModelCXN	:= Nil
Local oModelCXJ	:= Nil
Local cPlan		:= ""
Local nLinCXJ	:= 0
Local nItemAglut:= 0
Local nX		:= 0
Local nI    	:= 0
Local aAreas 	:= {SC7->(GetArea()), GetArea()}
Local aSeek		:= {}
Local cPedVazio := Space(TamSx3("CXJ_NUMPED")[1])
Default oModel	:= FwModelActive()
Default cAtuCpo := ""
Default cNumDoc	:= ""
Default cChavC7 := ""
Default	aDocs	:= {}

If Len(aDocs) > 0

	oModelCXN	:=	oModel:GetModel('CXNDETAIL')
	oModelCXJ	:= 	oModel:GetModel('CXJDETAIL')

	Do Case

		Case aDocs[1] == '1' .And. !Empty(cChavC7)//- Tratativas para pedido de compra (SC7)			
			SC7->(DbSetOrder(1))
			SC7->(DbSeek(cChavC7))
			
			oModelCXN:GoLine(MtFindMVC(oModelCXN,{{'CXN_NUMPLA', SC7->C7_PLANILH}}))
			While SC7->(!EOF() .And. C7_FILIAL + C7_NUM == cChavC7)
				If (nLinCXJ := MtFindMVC(oModelCXJ,{{'CXJ_ITEMPL', SC7->C7_ITEMED}}) )
					oModelCXJ:GoLine(nLinCXJ)
					oModelCXJ:LoadValue("CXJ_NUMPED", SC7->C7_NUM)

					aAdd(aSeek,{'CXJ_ITEMPE', SC7->C7_ITEM}) 
					aAdd(aSeek,{'CXJ_NUMPED', cPedVazio})
							
					While (nLinCXJ := MtFindMVC(oModelCXJ,aSeek)) > 0
						oModelCXJ:GoLine(nLinCXJ)
						oModelCXJ:LoadValue("CXJ_NUMPED", SC7->C7_NUM)
					EndDo
				EndIf
				SC7->(DbSkip())
			EndDo
			FwFreeArray(aSeek)
				
		Case aDocs[1] == '2'	//- Tratativas para pedido de venda (SC5)
			
			For nX := 1 To Len( aDocs[3] )
				nItemAglut := aScan(aDocs[3][nX],{|x| x[1] == "ITENS_AGLUT"} )
				If nItemAglut > 0
					For nI := 1 To Len(aDocs[3][nX][nItemAglut][2])
						cPlan := aDocs[ 2 , aScan( aDocs[2], {|x| x[1] = 'C5_MDPLANI'} ) , 2 ]
						cItem := aDocs[ 3 , nX , nItemAglut , 2, nI ]
						
						oModelCXN:GoLine( MtFindMVC( oModelCXN , { { 'CXN_NUMPLA' , cPlan } } ) )
						oModelCXJ:SeekLine( { { "CXJ_NUMPLA" , cPlan } , { "CXJ_ITEMPL" , cItem } } )
						oModelCXJ:LoadValue( cAtuCpo , cNumDoc )
					Next nI
				Else
					cPlan := aDocs[ 2 , aScan( aDocs[2], {|x| x[1] = 'C5_MDPLANI'} ) , 2 ]
					cItem := aDocs[ 3 , nX , aScan( aDocs[3,1] , {|x| x[1] = 'C6_ITEMED'} ) , 2 ]
					
					oModelCXN:GoLine( MtFindMVC( oModelCXN , { { 'CXN_NUMPLA' , cPlan } } ) )
					oModelCXJ:SeekLine( { { "CXJ_NUMPLA" , cPlan } , { "CXJ_ITEMPL" , cItem } } )
					oModelCXJ:LoadValue( cAtuCpo , cNumDoc )
				EndIf
			Next nX
			
	EndCase
	
EndIf

FWRestRows(aSaveLines)
FwFreeArray(aSaveLines)
aEval(aAreas, {|x|RestArea(x)})

Return .T.

/*/{Protheus.doc} AtuCNEPed
	Atualiza todos os registros do submodelo da CNE com o numero do pedido
	em <cNumPed>
@author PHILIPE.POMPEU
@since 29/01/2019
@param oModelCNE, object FWFormGrid, submodelo da tabela CNE
@param aDocumento, array, Lista de itens do Pedido
@param cNumPed, characters, Numero do Pedido
/*/
Static Function AtuCNEPed(oModel,aPedido, lVenda)
	Local cChaveMdl		:= ""
	Local cChaveArr		:= ""	
	Local nK	:= 0
	Local nI	:= 0	
	Local aItemPed := {}
	Local oModelCXN:= Nil
	Local oModelCNE:= Nil
	Local lCanUpdCNE:= .F.
	Local nPosCtr	:= 0
	Local nPosRev	:= 0
	Local nPosPlan	:= 0
	Local nPosMed	:= 0
	Local nPosItMed	:= 0
	Local cNumPed	:= ""
	Local cFilCNE	:= xFilial("CNE")
	Default lVenda	:= .F.
		
	cNumPed := IIF(lVenda, SC5->C5_NUM, SC7->C7_NUM)

	oModelCXN := oModel:GetModel('CXNDETAIL')
	oModelCNE := oModel:GetModel('CNEDETAIL')	
	
	lCanUpdCNE := oModelCNE:CanUpdateLine()//Verifica se a linha de CNE pode ser alterada	
	If !lCanUpdCNE //Se não puder alterar a CNE, então libera a grid para alteração
		CNTA300BlMd(oModel:GetModel('CNEDETAIL'),.T.,.T.)
	EndIF

	For nK := 1 To Len(aPedido)
		aItemPed := aPedido[nK]
		
		If nK == 1
			If lVenda
				nPosItMed	:= aScan(aItemPed, {|x| AllTrim(x[1]) == "C6_ITEMED"})
			Else
				nPosCtr		:= aScan(aItemPed, {|x| AllTrim(x[1]) ==  "C7_CONTRA"})
				nPosRev		:= aScan(aItemPed, {|x| AllTrim(x[1]) ==  "C7_CONTREV"})
				nPosPlan	:= aScan(aItemPed, {|x| AllTrim(x[1]) ==  "C7_PLANILH"})
				nPosMed		:= aScan(aItemPed, {|x| AllTrim(x[1]) ==  "C7_MEDICAO"})
				nPosItMed	:= aScan(aItemPed, {|x| AllTrim(x[1]) ==  "C7_ITEMED"})
			EndIf
		EndIf		
				
		For nI:= 1 To oModelCXN:Length()
			oModelCXN:GoLine(nI)
			cChaveMdl	:= oModelCXN:GetValue("CXN_FILIAL") + oModelCXN:GetValue("CXN_CONTRA") 
			cChaveMdl	+= oModelCXN:GetValue("CXN_REVISA") + oModelCXN:GetValue("CXN_NUMPLA")
			
			cChaveArr	:= xFilial("CNE")
			If lVenda
				cChaveArr += SC5->C5_MDCONTR + oModelCXN:GetValue("CXN_REVISA") + SC5->C5_MDPLANI
			Else
				cChaveArr += aItemPed[nPosCtr,2] + aItemPed[nPosRev,2] + aItemPed[nPosPlan,2] //Pega do item se for compras	
			EndIf		
			
			If cChaveMdl == cChaveArr
				Exit
			EndIf
		Next nI
	
		For nI := 1 To oModelCNE:Length()
			oModelCNE:GoLine(nI)
			cChaveMdl := oModelCNE:GetValue("CNE_FILIAL") + oModelCNE:GetValue("CNE_CONTRA")
			cChaveMdl += oModelCNE:GetValue("CNE_REVISA") + oModelCNE:GetValue("CNE_NUMERO")
			cChaveMdl += oModelCNE:GetValue("CNE_NUMMED") + oModelCNE:GetValue("CNE_ITEM")
						
			cChaveArr := cFilCNE
			If lVenda
				cChaveArr += SC5->C5_MDCONTR + oModelCNE:GetValue("CNE_REVISA") + SC5->(C5_MDPLANI + C5_MDNUMED)
			Else				
				cChaveArr += aItemPed[nPosCtr,2] + aItemPed[nPosRev,2] + aItemPed[nPosPlan,2] + aItemPed[nPosMed,2]
			EndIf
			cChaveArr += aItemPed[nPosItMed,2]

			If cChaveMdl == cChaveArr
				oModelCNE:LoadValue("CNE_PEDIDO", cNumPed)				
				Exit
			EndIf
		Next nI
	Next nK

	//Se não podia alterar, então volta os bloqueios que haviam na grid
	If !lCanUpdCNE
		CNTA300BlMd(oModel:GetModel('CNEDETAIL'),.T.)
	EndIF
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121VFoCl(lCompra,cForCli,cCodLoj)
Posiciona no cadastro do cliente/fornecedor e abre o cadastro para visualização

@since 22/11/2016
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function CN121VFoCl(lCompra,cForCli,cCodLoja,cFilCtr)
Local aArea			:= 	GetArea()
Local aSaveLines	:= 	FwSaveRows()

//- Variaveis para compatibilização com chamadas de funções MATA020 e MATA030
Private lPyme		:= .F.
Private lTMSOPdg	:= .F.
Private cCadastro	:= ""

Default lCompra 	:= 	CN121RetSt("COMPRA",,,CND->CND_CONTRA,.F.)
Default cForCli		:= 	""
Default cCodLoja	:= 	""
Default cFilCtr		:=	CND->CND_FILCTR

If lCompra
	//Mata020 - Cadastro de Fornecedores (A2_COD + A2_LOJA)
	dbSelectArea('SA2')
	If SA2->(MsSeek(xFilial('SA2',cFilCtr)+cForCli+cCodLoja))
		cCadastro := STR0152 //- Fornecedor
		A020Visual('SA2',SA2->(Recno()),3)
	EndIf
Else
	//Mata030 - Cadastro de Clientes (A1_COD + A1_LOJA)
	dbSelectArea('SA1')
	If SA1->(MsSeek(xFilial('SA1',cFilCtr)+cForCli+cCodLoja))
		cCadastro := STR0153 //- Cliente
		A030Visual('SA1',SA1->(Recno()),3)
	EndIf
EndIf

FWRestRows(aSaveLines)
RestArea(aArea)
Return

/*/{Protheus.doc} CN121CNDPos
Função de pós-validação dos campos da CND
@author juan.felipe
@since 03/07/2020
@param oModel, object, Modelo de dados ativo.
@return lRet, logical, Retorna .F. caso os campos estejam inválidos.
/*/
Static Function CN121CNDPos(oModel)
    Local oModelCND As Object
    Local lExclui As Logical
    Local lRet As Logical 
    Default oModel := FwModelActive()

    oModelCND := oModel:GetModel('CNDMASTER')
    lExclui := oModel:GetOperation() == MODEL_OPERATION_DELETE
    lRet := .T.

    If !lExclui //Valida condição de pagamento
        lRet := ExistCpo('SE4', oModelCND:GetValue('CND_CONDPG'))
    EndIf
Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN121Exced()
Inclui excedente na medicao encerrada


@author Filipe Gonçalves Rodrigues
@since 19/12/2014
@version P12
/*/
//-------------------------------------------------------------------
Function CN121Exced(lAuto, aExcds, bSave, cMsgErro)
Local lSeekCN9	:= .F.
Local cTitulo 	:= STR0088 + " " + STR0050 + " " + STR0120
Local cChave 	:= CND->(CND_CONTRA+CND_REVISA+CND_NUMERO+CND_NUMMED)
Local cModel	:= "CNTA121"
Local lRet 			:= .T.
Local oCNDMaster	:= Nil
Local oCXNDetail	:= Nil
Local oCNEDetail	:= Nil
Local oStruct		:= Nil
Local nY			:= 0
Local nX			:= 0
Local nI			:= 0
Local nPos			:= 0
Local aAux			:= {}
Local aSaveLines	:= {}
lOCAL cCodProd		:= ""
Local lHasSave		:= .F.
Local aRegistro		:= {}
Local nLinha		:= 0
Default lAuto		:= .F.
Default aExcds		:= {}
Default bSave		:= Nil
Default cMsgErro	:= ""

CN9->(dbSetOrder(1))
lSeekCN9 := CN9->(dbSeek(xFilial("CN9",CND->CND_FILCTR)+CND->CND_CONTRA+CND->CND_REVISA))

If Cn121RetSt('MEDEVE',1,,,.F.)	
	Help("",1,"CNEXCEVEN",,STR0162,4,1) //Funcionalidade indisponível para planilhas com medição eventual!
	cMsgErro := "CNEXCEVEN"
	lRet := .F.
ElseIf Cn121OriMd('CNTA120')
	If !lAuto
		CN121OldMd(-2)
	EndIf
	lRet := .F.
ElseIf(AllTrim(CND->CND_SITUAC) <> "E")
	Help(" ",1,"C121ExdEnc") //- Funcionalidade indisponível para medições de venda não encerradas.	
	cMsgErro := "C121ExdEnc"
	lRet := .F.
ElseIf(!lSeekCN9 .Or. (lSeekCN9 .And. CN9->CN9_ESPCTR != "2"))
	Help(" ",1,IIF(lSeekCN9, "CN121Exced", "REGNOIS")) //- "Funcionalidade indisponível para contratos de compra."
	lRet := .F.
	cMsgErro := IIF(lSeekCN9, "CN121Exced", "REGNOIS")
ElseIf(CN240VldUsr(CND->CND_CONTRA,DEF_TRAEDT_MED,.T.,, CND->CND_FILCTR))//Verifica permissões do usuário
	SetExcedME(.T.)	

	If LockByName("CN121"+xFilial("CND")+cChave,.T.,!Empty(xFilial("CND")),.T.)
		If !lAuto
			CfgIdMldDoc(MODEL_OPERATION_UPDATE)
			FWExecView(cTitulo ,cModel,MODEL_OPERATION_UPDATE,,{|| .T.})
		Else
			oModel := FwModelActive()

			If ValType(oModel) == "O"
				If oModel:GetId() == "CNTA121" .And. oModel:IsActive()
					oModel:DeActivate()							
				EndIf
			Endif

			oModel := FwLoadModel("CNTA121")
			oCNDMaster	:= oModel:GetModel("CNDMASTER")
			oCXNDetail	:= oModel:GetModel("CXNDETAIL")
			oCNEDetail	:= oModel:GetModel("CNEDETAIL")

			oModel:SetOperation(MODEL_OPERATION_UPDATE)

			If lRet := oModel:Activate()
				aSaveLines	:=	FwSaveRows()
				oStruct 	:= oCNEDetail:GetStruct()
				aAux 		:= oStruct:GetFields()

				For nY := 1 To oCXNDetail:Length()
					oCXNDetail:GoLine(nY)
					If oCXNDetail:GetValue("CXN_CHECK")
						For nI := oCNEDetail:Length() To 1 STEP - 1
							oCNEDetail:Goline(nI)
							If !Empty(oCNEDetail:GetValue("CNE_PRODUT"))
								cCodProd := oCNEDetail:GetValue("CNE_PRODUT")
								Exit
							ElseIf (oCNEDetail:IsInserted() .And. oCNEDetail:GetValue("CNE_EXCEDE") == "1")
								nLinha := nI
							EndIf
						Next nI

						If nLinha > 0
							oCNEDetail:GoLine(nLinha)
						EndIf
						
						oCNEDetail:SetNoUpdateLine(.F.)//Libera o Update								
						CN121ChgPl()//Habilita edição de campos
						
						For nI := 1 To Len(aExcds)
							If (nI > 1 .Or.  (nI == 1 .And. nLinha == 0))
								oCNEDetail:AddLine()
								oCNEDetail:LoadValue("CNE_EXCEDE", "1")
							EndIf

							If oCNEDetail:IsInserted() .And. Empty(oCNEDetail:GetValue("CNE_ITEM"))
								oCNEDetail:LoadValue("CNE_ITEM", StrZero(oCNEDetail:Length(), Len(CNE->CNE_ITEM)))										
							EndIf

							aRegistro := aExcds[nI]

							For nX := 1 To Len(aRegistro)

								If (nPos := aScan(aAux,{ |x| AllTrim(x[3]) == AllTrim(aRegistro[nX][1])})) > 0
									
									If !(lRet := oCNEDetail:SetValue(	aRegistro[nX,1],;
																		aRegistro[nX,2]))
										Exit
									Endif
								Endif

							Next nX

							If Empty(oCNEDetail:GetValue("CNE_PRODUT"))
								lRet := oCNEDetail:LoadValue("CNE_PRODUT",cCodProd)
							EndIf

							If !lRet
								Exit
							EndIf
						Next nI
					Endif
				Next nY
				FWRestRows( aSaveLines )
				FwFreeArray( aSaveLines)
			Endif

			If lRet
				lHasSave := (bSave != Nil)
				
				if !lHasSave					
					bSave := {|oUmModel| oUmModel:VldData() .And. oUmModel:CommitData() }
				EndIf
				
				lRet :=  Eval(bSave, oModel)						
				If !lRet
					cMsgErro := AllTrim(oModel:GetErrorMessage()[MODEL_MSGERR_ID])
					AtErroMvc(oModel)
					If !IsBlind()
						MostraErro()
					EndIf
				Endif

				If !lHasSave .And. oModel:IsActive()
					oModel:DeActivate()
				EndIf
			Endif

		Endif
	Else
		Help(" ",1,"A121CONC")		
		cMsgErro:= "A121CONC"
		lRet 	:= .F.
	EndIf

	UnLockByName("CN121"+xFilial("CND")+cChave,.T.,!Empty(xFilial("CND")),.T.)

	SetExcedME(.F.)
EndIf
Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN121ExceC()
Inclui excedente na medicao para competência inexistente


@author Filipe Gonçalves Rodrigues
@since 19/12/2014
@version P12
/*/
//-------------------------------------------------------------------
Function CN121ExceC()
Local cTitulo 	:= STR0088 + " " + STR0050 + " " + STR0121
Local cModel	:= "CNTA121"

SetExcedNP(.T.)

lInclui := .T.
aComp	:= {}
CfgIdMldDoc(MODEL_OPERATION_INSERT)
FWExecView(cTitulo,cModel,MODEL_OPERATION_INSERT,,{|| .T.})//"Inclusão de Medição"
lInclui := .F.

SetExcedNP(.F.)

Return

/*/{Protheus.doc} CN121VLDSF()
	Retorna o saldo já consumido de planilhas semi-fixas por medições em aberto
@author Filipe Gonçalves Rodrigues
@since 19/12/2014
@param cContra, caractere, número do contrato
@param cRevisa, caractere, revisão do contrato
@param cNumPla, caractere, número da planilha
@param cFilCtr, caractere, filial do contrato
@return nSldConsum, numérico, saldo já consumido
/*/
Function CN121VLDSF(cContra, cRevisa, cNumPla, cFilCtr)
	Local aArea		:= GetArea()
	Local nSldConsum:= 0
	Local cAliasTmp	:= GetNextAlias()

	Default cContra	:= ""
	Default cRevisa	:= ""
	Default cNumPla	:= ""
	Default cFilCtr	:= cFilAnt

	BeginSQL Alias cAliasTmp

		SELECT SUM(CXN_VLTOT) AS TOTAL
		FROM %Table:CXN% CXN
		INNER JOIN %Table:CND% CND ON(
			CND_FILIAL = CXN_FILIAL 
			AND CND_CONTRA = CXN_CONTRA 
			AND CND_REVISA = CXN_REVISA 
			AND CND_NUMMED = CXN_NUMMED 
			AND CND.%NotDel%)
		WHERE
		CXN_CONTRA = %Exp:cContra%
		AND CXN_REVISA = %Exp:cRevisa%
		AND CXN_NUMPLA = %Exp:cNumPla%
		AND CND.CND_FILCTR = %Exp:cFilCtr%
		AND CND_SITUAC IN ('A','B','SA','FA')
		AND CXN.%NotDel%
	EndSQL

	nSldConsum := (cAliasTmp)->TOTAL
	(cAliasTmp)->(dbCloseArea())
	
	RestArea(aArea)
	FwFreeArray(aArea)
Return nSldConsum

//------------------------------------------------------------------
/*/{Protheus.doc} C121CNEAgr()
Validação do agrupador referente ao valor máximo da CXM


@author Filipe Gonçalves Rodrigues
@since 16/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function C121CNEAgr(oModel,cField,xValue,nLine, lUndelete)
Local aArea		:= GetArea()
Local aSaveLines:= FWSaveRows()
Local oModelCNE	:= oModel:GetModel('CNEDETAIL')
Local oModelCXM := oModel:GetModel("CXMDETAIL")
Local aAgrvld	:= {}
Local nX		:= 0
Local nPos		:= 0
Local nValor	:= 0
Local lRet		:= .T.
Local cTipo		:= ""
Local cGrupo 	:= ""
Local nTotalMed	:= 0
Default oModel		:= FwModelActive()
Default cField		:= ""
Default xValue		:= 0
Default nLine		:= 0
Default lUndelete	:= .F.

For nX := 1 To oModelCNE:Length()
	oModelCNE:GoLine(nX)
	If (!oModelCNE:IsDeleted() .Or. lUndelete) .And. !Empty(oModelCNE:GetValue("CNE_ITEMGR"))
		SB1->(DbSeek(xFilial("SB1")+oModelCNE:GetValue("CNE_PRODUT")))
		cTipo := SB1->B1_TIPO
		cGrupo := SB1->B1_GRUPO

		If !(nPos := aScan(aAgrvld,{|x| x[1] == oModelCNE:GetValue("CNE_ITEMGR")})) > 0									
			aAdd(aAgrvld,{oModelCNE:GetValue("CNE_ITEMGR"), 0})
			nPos := Len(aAgrvld)
		EndIf
		If(nX == nLine .And. cField $ 'CNE_VLUNIT|CNE_QUANT')
			If cField == "CNE_VLUNIT"
				nValor := oModelCNE:GetValue("CNE_QUANT") * xValue
			ElseIf cField == "CNE_QUANT"
				nValor := xValue * oModelCNE:GetValue("CNE_VLUNIT")
			EndIf
		Else
			nValor := oModelCNE:GetValue("CNE_QUANT") * oModelCNE:GetValue("CNE_VLUNIT")		
		EndIf
		aAgrvld[nPos][2] += nValor
	EndIf
Next Nx

nLine := oModelCXM:GetLine() //Guarda a linha original
//Percorre o array para posicionar na CXM e verificar se o total do agrupador é maior que o total dos itens
For nX := 1 to Len(aAgrvld)
	If(aAgrvld[nX,2] > 0 .And. (nPos := MtFindMVC(oModelCXM,{{"CXM_ITEMID",aAgrvld[nX][1]}})) > 0 )
		oModelCXM:GoLine(nPos)//Posiciona na linha correta
		nTotalMed := aAgrvld[nX,2] + oModelCXM:GetValue("CXM_VLMED")
		If oModelCXM:GetValue("CXM_VLMAX") <> 0 .And. nTotalMed > oModelCXM:GetValue("CXM_VLMAX")
			lRet := .F.
			Help(" ",1,"CN121UNIGRP")
			Exit
		EndIf		
	EndIf	
Next nX
oModelCXM:GoLine(nLine)

RestArea(aArea)
FWRestRows( aSaveLines )
Return lRet
//------------------------------------------------------------------
/*/{Protheus.doc} CN121Auto()

@author Kaique Schiller Olivero
@since 20/03/2017
@version P12.1.14
/*/
//-------------------------------------------------------------------
Function CN121Auto(aCposCab,aCposItem,nOpcAut,aExceds,aMultas,aDescts,aPlan,lAgrup,cErroMed)
Local aArea			:= GetArea()
Local oModel 		:= Nil
Local oCNDMaster	:= Nil
Local oCXNDetail	:= Nil
Local oCNEDetail	:= Nil
Local oCNRDetail	:= Nil
Local oCNQDetail	:= Nil
Local oStruct		:= Nil
Local bValid		:= Nil
Local nX			:= 0
Local nI			:= 0
Local nY			:= 0
Local nZ
Local nPos			:= 0
Local nPosPlan		:= 0
Local cNumPla		:= ""
Local lRet	 		:= .T.
Local cContra		:= ""
Local cRevisa		:= ""
Local cNumMed		:= ""
Local lSeleComp	:= .F.
Default aCposCab	:= {}
Default aCposItem	:= {}
Default nOpcAut		:= 0
Default aExceds		:= {}
Default aMultas		:= {}
Default aDescts		:= {}
Default aPlan		:= {}
Default lAgrup		:= .F.
Default cErroMed	:= ""

If !Empty(aCposCab) .And. !Empty(aCposItem)
	For nX := 1 To Len(aCposCab)
		If aCposCab[nX][1] == "CND_CONTRA"
			cContra := aCposCab[nX][2]
		Elseif aCposCab[nX][1] == "CND_REVISA"
			cRevisa := aCposCab[nX][2]
		Elseif aCposCab[nX][1] == "CND_NUMMED"
			cNumMed := aCposCab[nX][2]
		Endif
	Next nX

	If nOpcAut == 3 .Or. nOpcAut == 5
		oModel 		:= FwLoadModel("CNTA121")
		oCNDMaster	:= oModel:GetModel("CNDMASTER")
		oCXNDetail	:= oModel:GetModel("CXNDETAIL")
		oCNEDetail	:= oModel:GetModel("CNEDETAIL")
		oCNRDetail 	:= oModel:GetModel("CNRDETAIL1")
		oCNQDetail 	:= oModel:GetModel("CNQDETAIL")

		If nOpcAut == 3
			oModel:SetOperation(MODEL_OPERATION_INSERT)
		Elseif nOpcAut == 5
			DbSelectArea("CND")
			CND->(DbSetOrder(7)) //CND_FILIAL+CND_CONTRA+CND_REVISA+CND_NUMMED
			If CND->(DbSeek(xFilial("CND")+cContra+cRevisa+cNumMed))
				oModel:SetOperation(MODEL_OPERATION_DELETE)
			Else
				//Não foi possível encontrar a CND
				lRet := .F.
			Endif
		Endif

		If lRet
			lRet := oModel:Activate()
		Endif

		If lRet .And. nOpcAut == 3
			oStruct 	:= oCNDMaster:GetStruct()
			aAux 		:= oStruct:GetFields()

			For nI := 1 To Len(aCposCab) //Preenche o cabeçalho CND
				// Verifica se os campos passados existem na estrutura do cabeçalho
				If !lSeleComp .AND. VALTYPE(A121GComp()) == "A" .AND. !EMPTY(A121GComp()) .AND. isInCallStack("At930Grv")
					lSeleComp := .T.
					If !( lRet := lRet .AND. At930SelCp(A121GComp(),oCNDMaster,lAgrup,aPlan) )
						Exit
					EndIf
				EndIf
				
				If lRet
					If aCposCab[nI][1] == "CND_NUMERO"
						cNumPla := aCposCab[nI][2]
					ElseIf !(aCposCab[nI][1] $ "CND_VLTOT|CND_DESCME") .And. (nPos := aScan(aAux,{ |x| AllTrim(x[3]) == AllTrim(aCposCab[nI][1])})) > 0
						If !EMPTY(aCposCab[nI][2])
							If !(lRet := oCNDMaster:SetValue(aCposCab[nI][1],aCposCab[nI][2]))
								Exit
							Endif
						EndIF
					EndIf
				Else
					Exit
				EndIf
			
			Next nI

			If lRet
				If lAgrup
					For nZ := 1 To Len(aPlan)
						If aPlan[nZ][3] .AND. aPlan[nZ][4] > 0
							If lRet := oCXNDetail:SeekLine({{'CXN_NUMPLA',aPlan[nZ][2]}})
								lRet := oCXNDetail:SetValue("CXN_CHECK",.T.)
								lRet := lRet .AND. oCXNDetail:SetValue("CXN_FORCLI",aPlan[nZ][5])
								lRet := lRet .AND. oCXNDetail:SetValue("CXN_LOJA",aPlan[nZ][6])
							Else
								//"A competencia selecionada não existe nesta planilha. "
								Help("",1," CN121Auto",,STR0190 + " (" + aPlan[nZ][2] + ")",4,1)
							Endif

							If lRet
								For nI := 1 To Len(aCposItem)
									nPosPlan := aScan( aCposItem[nI], {|x| x[1] == "PLAN" } )
									If nPosPlan > 0 .AND. aCposItem[nI,nPosPlan,2] <> aPlan[nZ][2]
										Loop
									EndIf
									If lRet
										oStruct 	:= oCNEDetail:GetStruct()
										aAux 		:= oStruct:GetFields()

										If oCNEDetail:SeekLine({{'CNE_ITEM',aCposItem[nI,1,2]}})
											For nX := 1 To Len(aCposItem[nI]) //Inclui os itens da Apuração/Medição
												If (nPos := aScan(aAux,{ |x| AllTrim(x[3]) == AllTrim(aCposItem[nI][nX][1])})) > 0
													If !(lRet := oCNEDetail:SetValue(aCposItem[nI][nX][1],aCposItem[nI][nX][2]))
														Exit
													Endif
												Endif
											Next nX
										EndIf	 
									Endif
								Next nI

								If lRet .And. !Empty(aMultas)
									For nY := 1 To Len(aMultas) //Inclui as Multas/Bonificação

										lRet := lRet .And. Iif(oCNRDetail:GetValue("CNR_TIPO") <> aMultas[nY][1],oCNRDetail:SetValue("CNR_TIPO",aMultas[nY][1]),.T.)
										lRet := lRet .And. oCNRDetail:SetValue("CNR_DESCRI"	,aMultas[nY][2])
										lRet := lRet .And. oCNRDetail:SetValue("CNR_VALOR"	,aMultas[nY][3])
										lRet := lRet .And. oCNRDetail:SetValue("CNR_FLGPED"	,aMultas[nY][5])
										lRet := lRet .And. oCNRDetail:LoadValue("CNR_MODO"	,aMultas[nY][4])

										If !lRet
											Exit
										Else
											If nY < Len(aMultas)
												oCNRDetail:AddLine()
											Endif
										Endif
									Next nY
								Endif

								If lRet .And. !Empty(aDescts)
									For nY := 1 To Len(aDescts) //Inclui os descontos

										lRet := lRet .And. oCNQDetail:SetValue("CNQ_CONTRA"	,cContra)

										bValid := oCNQDetail:GetStruct():GetProperty('CNQ_NUMMED',MODEL_FIELD_VALID)
										oCNQDetail:GetStruct():SetProperty('CNQ_NUMMED',MODEL_FIELD_VALID,{||.T.})
										lRet := lRet .And. oCNQDetail:SetValue("CNQ_NUMMED" ,cNumMed)
										oCNQDetail:GetStruct():SetProperty('CNQ_NUMMED',MODEL_FIELD_VALID,bValid)
										lRet := lRet .And. oCNQDetail:SetValue("CNQ_NUMPLA"	,cNumPla)
										lRet := lRet .And. oCNQDetail:SetValue("CNQ_TPDESC"	,aDescts[nY][4])
										lRet := lRet .And. oCNQDetail:SetValue("CNQ_DESCRI"	,aDescts[nY][5])
										lRet := lRet .And. oCNQDetail:SetValue("CNQ_VALOR"	,aDescts[nY][6])

										If !lRet
											Exit
										Else
											If nY < Len(aDescts)
												oCNQDetail:AddLine()
											Endif
										Endif
									Next nY
								Endif

							Endif
						EndIf
					Next nZ
				Else
					If lRet := oCXNDetail:SeekLine({{'CXN_NUMPLA',cNumPla}})
						lRet := oCXNDetail:SetValue("CXN_CHECK",.T.)
						nPosPlan := ASCAN( aPlan, { |x| x[2] == cNumPla })
						If nPosPlan > 0
							lRet := lRet .AND. oCXNDetail:SetValue("CXN_FORCLI",aPlan[nPosPlan][5])
							lRet := lRet .AND. oCXNDetail:SetValue("CXN_LOJA",aPlan[nPosPlan][6])
						EndIf
					Else
						//"A competencia selecionada não existe nesta planilha. "
						Help("",1," CN121Auto",,STR0190 + " (" + cNumPla + ")",4,1)
					Endif

					If lRet
						For nI := 1 To Len(aCposItem)
							nPosPlan := aScan( aCposItem[nI], {|x| x[1] == "PLAN" } )
							If nPosPlan > 0 .AND. aCposItem[nI,nPosPlan,2] <> cNumPla
								Loop
							EndIf
							If lRet
								oStruct 	:= oCNEDetail:GetStruct()
								aAux 		:= oStruct:GetFields()

								If oCNEDetail:SeekLine({{'CNE_ITEM',aCposItem[nI,1,2]}})
									For nX := 1 To Len(aCposItem[nI]) //Inclui os itens da Apuração/Medição
										If (nPos := aScan(aAux,{ |x| AllTrim(x[3]) == AllTrim(aCposItem[nI][nX][1])})) > 0
											If !(lRet := oCNEDetail:SetValue(aCposItem[nI][nX][1],aCposItem[nI][nX][2]))
												Exit
											Endif
										Endif
									Next nX
								EndIf	 
							Endif
						Next nI

						If lRet .And. !Empty(aMultas)
							For nY := 1 To Len(aMultas) //Inclui as Multas/Bonificação

								lRet := lRet .And. Iif(oCNRDetail:GetValue("CNR_TIPO") <> aMultas[nY][1],oCNRDetail:SetValue("CNR_TIPO",aMultas[nY][1]),.T.)
								lRet := lRet .And. oCNRDetail:SetValue("CNR_DESCRI"	,aMultas[nY][2])
								lRet := lRet .And. oCNRDetail:SetValue("CNR_VALOR"	,aMultas[nY][3])								
								If oCNRDetail:GetValue("CNR_FLGPED") <> aMultas[nY][5]
									lRet := lRet .And. oCNRDetail:SetValue("CNR_FLGPED"	,aMultas[nY][5])
								EndIf
								lRet := lRet .And. oCNRDetail:LoadValue("CNR_MODO"	,aMultas[nY][4])

								If !lRet
									Exit
								Else
									If nY < Len(aMultas)
										oCNRDetail:AddLine()
									Endif
								Endif
							Next nY
						Endif

						If lRet .And. !Empty(aDescts)
							For nY := 1 To Len(aDescts) //Inclui os descontos

								lRet := lRet .And. oCNQDetail:SetValue("CNQ_CONTRA"	,cContra)

								bValid := oCNQDetail:GetStruct():GetProperty('CNQ_NUMMED',MODEL_FIELD_VALID)
								oCNQDetail:GetStruct():SetProperty('CNQ_NUMMED',MODEL_FIELD_VALID,{||.T.})
								lRet := lRet .And. oCNQDetail:SetValue("CNQ_NUMMED" ,cNumMed)
								oCNQDetail:GetStruct():SetProperty('CNQ_NUMMED',MODEL_FIELD_VALID,bValid)
								lRet := lRet .And. oCNQDetail:SetValue("CNQ_NUMPLA"	,cNumPla)
								lRet := lRet .And. oCNQDetail:SetValue("CNQ_TPDESC"	,aDescts[nY][4])
								lRet := lRet .And. oCNQDetail:SetValue("CNQ_DESCRI"	,aDescts[nY][5])
								lRet := lRet .And. oCNQDetail:SetValue("CNQ_VALOR"	,aDescts[nY][6])

								If !lRet
									Exit
								Else
									If nY < Len(aDescts)
										oCNQDetail:AddLine()
									Endif
								Endif
							Next nY
						Endif

					Endif
				EndIf
			Endif
		EndIf

		If lRet
			lRet := oModel:VldData() .And. oModel:CommitData()
		Endif

		If !lRet
			AtErroMvc(oModel)
		Endif

		//Veriica se esta ativo e desativa o Modelo
		If oModel:IsActive()
			oModel:DeActivate()
		Endif

	ElseIf nOpcAut == 6
		DbSelectArea("CND")
		CND->(DbSetOrder(7)) //CND_FILIAL+CND_CONTRA+CND_REVISA+CND_NUMMED
		If CND->(DbSeek(xFilial("CND")+cContra+cRevisa+cNumMed))
			lRet := CN121Encerr(.T.)
		Endif
	Elseif nOpcAut == 7
		DbSelectArea("CND")
		CND->(DbSetOrder(7))
		If CND->(DbSeek(xFilial("CND")+cContra+cRevisa+cNumMed))
			lRet := CN121Estorn(.T.,,@cErroMed)
		Endif
	Elseif nOpcAut == 8
		DbSelectArea("CND")
		CND->(DbSetOrder(7))
		If CND->(DbSeek(xFilial("CND")+cContra+cRevisa+cNumMed))
			lRet := CN121Exced(.T.,aExceds)
		Endif
	Endif
Endif

RestArea(aArea)

Return lRet


//------------------------------------------------------------------
/*/{Protheus.doc} CN121VlSt()
	Verifica se é uma planilha fixa de serviço
@author Kaique Schiller Olivero
@since 20/03/2017
@return lRet, logical, se a planilha posicionada é fixa e de serviço
/*/
//-------------------------------------------------------------------
Function CN121VlSt(lTrigger as logical)
	Local lRet 		:= .F.
	Local oModel	:= Nil	
	Local lModel := .T.
	Default lTrigger := .F.
	
	oModel := FwModelActive()
	lRet := Cn121RetSt('FIXO'	, 0,/*cPlan*/,/*cContra*/, lModel, oModel) .And.;
			Cn121RetSt('SERVIÇO', 0,/*cPlan*/,/*cContra*/, lModel, oModel)

	If lTrigger .And. lRet
		//se for uma planilha fixa de serviço(nesse cenário o valor unitário é sempre igual ao total), porém é preenchido via loadValue na condição do gatilho(que sempre retorna falso)
		oModel:LoadValue("CNEDETAIL", "CNE_VLTOT", FwFldGet("CNE_VLUNIT") )
		lRet := .F.
	EndIf
Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} Cn121GetLoc(cCodCtr, cNumPla)
	Pega informações do local de atendimento baseado na Planilla Med. de contratos
@author Kaique Schiller Olivero
@since 08/05/2017
@version P12.1.14
/*/
//-------------------------------------------------------------------
Function Cn121GetLoc(cCodCtr, cNumPla)
Local cAliasTemp	:= GetNextAlias()
Local aInfLoc 		:= {"","",""}

If !Empty(cCodCtr) .And. !Empty(cNumPla)
	BeginSQL Alias cAliasTemp
		SELECT ABS_RECISS,ABS_CODMUN,ABS_ESTADO
			FROM %Table:TFL% TFL
		INNER JOIN %Table:ABS% ABS ON
			ABS.ABS_FILIAL = %xFilial:ABS% AND
			ABS.ABS_LOCAL  = TFL.TFL_LOCAL
		WHERE
			TFL.TFL_FILIAL 	= %xFilial:TFL% AND
			TFL.TFL_CONTRT	= %Exp:cCodCtr%	AND
			TFL.TFL_PLAN	= %Exp:cNumPla%	AND
			TFL.%NotDel% AND ABS.%NotDel%
	EndSQL

	If (cAliasTemp)->(!Eof())
		aInfLoc[1] := (cAliasTemp)->ABS_CODMUN
		aInfLoc[2] := (cAliasTemp)->ABS_RECISS
		aInfLoc[3] := (cAliasTemp)->ABS_ESTADO
	EndIf

	(cAliasTemp)->(dbClosearea())

Endif

Return aInfLoc

//------------------------------------------------------------------------------
/*/{Protheus.doc}  Cn121LtMed()
	Retorna o limite da medição respeitando o nivel de planilha e de tipo de contrato.

@param oModelCXN, object, Modelo de dados da CXN.

@Return nVlrRet, numerico, retorna o valor limite da medição
Autor: Kaique Schiller Olivero
/*/
//------------------------------------------------------------------------------//
Function Cn121LtMed( oModelCXN )
	Local aAreas 	 := {CNF->(GetArea()), GetArea() }
	Local nLmtMed	 := 0
	Local nVlrRet	 := 0
	Local lMultiMed  := 0
	Local cFilCNF	 := ""
	Local nRealizado := 0
	Local nValorReal := 0
	Local nSaldo 	 := 0
	Local cNumCtr  	 := ""
	Local cRevCtr	 := ""
	Local cNumPla	 := ""
	Local nValPrev 	 := nSaldo
	Local cFilCtr  	 := cFilAnt
	Local cCronog  	 := ""
	Local cParcel  	 := ""
	Local nTotMdAnt	 := 0
	Local lAltera    := oModelCXN:GetOperation() == MODEL_OPERATION_UPDATE
	Local cChaveCXN  := ""

	cFilCtr := oModelCXN:GetModel():GetValue("CNDMASTER", "CND_FILCTR")
	nSaldo 	:=  oModelCXN:GetValue("CXN_VLSALD")
	cNumCtr := oModelCXN:GetValue('CXN_CONTRA')
	cRevCtr := oModelCXN:GetValue("CXN_REVISA")
	cNumPla	:= oModelCXN:GetValue("CXN_NUMPLA")	
	cCronog := oModelCXN:GetValue("CXN_CRONOG")
	cParcel := oModelCXN:GetValue("CXN_PARCEL")

	If !Empty(cCronog)
		cFilCNF		:= xFilial("CNF", cFilCtr)
		cChaveCNF := cFilCNF + cNumCtr + cRevCtr + cCronog + cParcel
		CNF->(DbSetOrder(3))
		If CNF->(DbSeek(cChaveCNF))// Verifica se o registro possui parcela do cronograma medida
			nSldParc := CNF->CNF_VLPREV
			nValPrev:= nSldParc
			nValorReal := CNF->CNF_VLREAL
		EndIf		
	Else
		nValPrev := oModelCXN:GetValue("CXN_VLPREV")
	EndIf	

	If nValPrev == 0
		nValPrev := nSaldo
	EndIf

	If nSaldo <> 0 .And. !Empty(cNumCtr)
		nLmtMed		:= CN121RetSt("LMTMED",0, cNumPla, cNumCtr, .F.,,cFilCtr)
		lMultiMed	:= CN121RetSt("MULTIMED",0,cNumPla, cNumCtr,.F.,,cFilCtr)	
	Endif

	If nLmtMed > 0	

		If lMultiMed .And. lAltera// Caso consuma o saldo na inclusão, pega o valor caso o mesmo já tenha sido consumido parcialmente
			cChaveCXN := xFilial("CXN") + cNumCtr + cRevCtr + oModelCXN:GetValue("CXN_NUMMED") + oModelCXN:GetValue("CXN_NUMPLA")

			nTotMdAnt := GetAdvFVal("CXN", "CXN_VLTOT"	,;//Total da medição já incluida que esta sendo alterada
									cChaveCXN			,;//Busca a CXN com os valores gravados, não os valores em memória(que foram atualizados)
									 1					,;//CXN_FILIAL+CXN_CONTRA+CXN_REVISA+CXN_NUMMED+CXN_NUMPLA+CXN_PARCEL
									 0, .T.)
		EndIf
		
		nVlrRet := nValPrev + ( ( nValPrev * nLmtMed ) / 100 )
			
		If (nValorReal > 0)// Verifica se o registro possui parcela do cronograma medida
			If !lMultiMed .Or. !lEncerra .And. !lAltera
				nVlrRet-= nValorReal
			ElseIf lAltera// Caso seja alteração de um registro que já teve saldo consumido parcialmente na inclusão
				nRealizado := nValorReal
				nRealizado -=  nTotMdAnt
				nVlrRet    -= nRealizado
			EndIf			
		endif
	Else
		nVlrRet := nValPrev
	Endif

	aEval(aAreas, {|x| RestArea(x) })
	FwFreeArray(aAreas)

Return nVlrRet

/*/{Protheus.doc} Cn121GrvAd()
	Função responsável pela inclusão/atualização da CZY(Medição x Adiantamentos)
e pela atualização do saldo da CNX(Adiantamentos do Contrato)
@author israel.escorizza
@since 11/08/2015
@version 1.0
@Return Nil
/*/
Function Cn121GrvAd()
	Local aAreas 	:= {CNX->(GetArea()), CZY->(GetArea()), GetArea()}
	Local oModel	:= Nil
	Local cFilMed	:= ""
	Local cFilCtr 	:= ""
	Local cContra	:= ""
	Local cRevisa	:= ""
	Local cNumMed	:= ""
	Local oModelCZY	:= NIL
	Local oModelCXN := NIL
	Local nValor	:= 0
	Local nOpc		:= 0
	Local nCZY      := 0

	oModel	:= FwModelActive()
	oModelCZY := oModel:GetModel('CZYDETAIL')
	oModelCXN := oModel:GetModel("CXNDETAIL")
	cContra	:= oModel:GetValue("CNDMASTER", "CND_CONTRA")
	cRevisa	:= oModel:GetValue("CNDMASTER", "CND_REVISA")
	cNumMed	:= oModel:GetValue("CNDMASTER", "CND_NUMMED")
	cFilCtr := oModel:GetValue("CNDMASTER", "CND_FILCTR")
	cFilMed := cFilAnt
	nOpc 	:= oModel:GetOperation()
	If nOpc <> MODEL_OPERATION_DELETE
		CZY->(DbsetOrder(2))
		CNX->(DbsetOrder(1))

		If !oModelCZY:CanDeleteLine()
			oModelCZY:SetNoDeleteLine(.F.)//É necessário liberar a exclusão p/ quando existir itens zerados
		EndIf
		
		For nCZY := 1 to oModelCZY:Length()
			oModelCZY:GoLine(nCZY)
			cNumero:= oModelCZY:GetValue("CZY_NUMERO")
			If CNX->(MsSeek(xFilial("CNX",cFilCtr)+cContra+cNumero))
				nValor:= oModelCZY:GetValue("CZY_VALOR")
				Reclock("CNX",.F.)
				If(oModelCZY:GetDataId() > 0)
					CZY->(DbGoTo(oModelCZY:GetDataId()))
					CNX->CNX_SALDO += CZY->CZY_VALOR //Sempre devolve ao saldo o valor original
				EndIf
				If !(oModelCZY:IsDeleted())				
					If nValor > 0
						CNX->CNX_SALDO -= nValor
					Else
						oModelCZY:DeleteLine() //Deleta a linha caso seja zerado
					EndIf
				EndIf
				CNX->(MsUnlock())				
			EndIf					
		Next nCZY
	Else
		For nCZY:= 1 to oModelCZY:Length()
			oModelCZY:GoLine(nCZY)
			cNumero:= oModelCZY:GetValue("CZY_NUMERO")
			nValor:= oModelCZY:GetValue("CZY_VALOR")
			If CNX->(MsSeek(xFilial("CNX",cFilCtr)+cContra+cNumero))
				RecLock("CNX", .F.)
				CNX->CNX_SALDO += oModelCZY:GetValue("CZY_VALOR")
				CNX->(MsUnlock())
			EndIf
		Next	
	EndIf

	aEval(aAreas, {|x|RestArea(x)})
	FwFreeArray(aAreas)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121OriMd()
Função para identificar se medição veio do CNTA120 ou CNTA121
@author israel.escorizza/Alessandro Honda
@since 29/06/2017
@version 1.0
@Return lRet
/*/
//-------------------------------------------------------------------
Function Cn121OriMd(cOrigem)
Local lRet	:= .F.
Local aArea	:= GetArea()
Local aAreaCXN	:= {}

Default cOrigem := ""

dbSelectArea('CXN')

aAreaCXN := CXN->(GetArea())

CXN->(dbSetOrder(1))	//- CXN_FILIAL+CXN_CONTRA+CXN_REVISA+CXN_NUMMED+CXN_NUMPLA
If cOrigem == 'CNTA120' .And. !(CXN->(dbSeek(xFilial('CXN')+CND->(CND_CONTRA+CND_REVISA+CND_NUMMED))))
 	lRet := .T.
Else
	lRet := .F.
EndIf

RestArea(aAreaCXN)
RestArea(aArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} CN121TPed()
Função para verificar se ao menos um item da planilha esta configurado
para gerar pedido.

@author jose.delmondes
@since 07/08/2017
@version 1.0
@Return Logico: True -> Sera gerado ao menos um pedido para a planilha.
				  False -> Nao sera gerado pedido para a planilha.
/*/
//---------------------------------------------------------------------
Static Function CN121TPed( oModel )
Local lRet := .F.
Local nX	:= 0
Local aSaveLines	:= FwSaveRows()

For nX := 1 To oModel:Length()
	If oModel:GetValue('CNE_PEDTIT') == '1'
		lRet := .T.
		Exit
	EndIf
Next nX

FWRestRows(aSaveLines)

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} CN121DcItf()
Função para verificar se o desconto será aplicado no pedido ou no título
gerado pela NF.

@author jose.delmondes
@since 07/08/2017
@version 1.0
@Return Logico: True -> Deconto deve ser aplicado no pedido
				  False -> Desconto sera aplicado no título gerado pela NF
/*/
//-----------------------------------------------------------------------
Static Function CN121DcItf( oModel )
Local lRet := .F.
Local aArea := GetArea()
Local aAreaCNP := {}

dbSelectArea('CNP')

aAreaCNP := CNP->(GetArea())

dbSetorder(1)

If dbSeek( xFilial('CNP') + oModel:GetValue('CNQ_TPDESC') )
	lRet := CNP->CNP_FLGPED == '1'
Endif

RestArea( aAreaCNP )
RestArea( aArea )

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} CN121InCau()
Grava Caução Retida

@author jose.delmondes
@since 11/08/2017
@version 1.0
@Return
/*/
//-----------------------------------------------------------------------
Static Function CN121InCau(oModel)

Local oModelCND		:= oModel:GetModel("CNDMASTER")
Local oModelCXN		:= oModel:GetModel("CXNDETAIL")

Local lCn120IncCa 	:= ExistBlock("CN120INCCA")
Local lGrvCau     	:= .T.

Local nX			:= 0

//Ponto de entrada para indicar se grava ou não a retencao de caucao
If ExistBlock("CN120GRVCA")
	lGrvCau := ExecBlock("CN120GRVCA",.F.,.F.)
	If ValType(lGrvCau) <> "L"
		lGrvCau := .T.
	EndIf
EndIf

If lGrvCau

	dbSelectArea("CNT")

	For nX := 1 To oModelCXN:Length()

		oModelCXN:GoLine(nX)

		if !(oModelCXN:IsDeleted()) .And. oModelCXN:GetValue("CXN_CHECK")
			
			RecLock("CNT",.T.)

			CNT->CNT_FILIAL := xFilial("CNT", oModelCND:GetValue('CND_FILCTR'))
			CNT->CNT_CONTRA := oModelCND:GetValue('CND_CONTRA')
			CNT->CNT_NUMMED := oModelCND:GetValue('CND_NUMMED')
			CNT->CNT_NUMPLA := oModelCXN:GetValue('CXN_NUMPLA')
			CNT->CNT_VLRET  := oModelCND:GetValue('CND_RETCAC') * (oModelCXN:GetValue('CXN_VLLIQD') / oModelCND:GetValue('CND_VLLIQD'))
			CNT->CNT_DTMED  := dDataBase
			CNT->CNT_FORNEC := oModelCXN:GetValue('CXN_FORNEC')
			CNT->CNT_LJFORN := oModelCXN:GetValue('CXN_LJFORN')
			CNT->CNT_CLIENT := oModelCXN:GetValue('CXN_CLIENT')
			CNT->CNT_LOJACL := oModelCXN:GetValue('CXN_LJCLI')

			If lCn120IncCa
				ExecBlock("CN120INCCA",.F.,.F.)
			Endif

			//Executa contabilizacao da retencao do contrato
			CN120Contab( '695' )

			CNT->(MsUnlock())
		endif


	Next nX

EndIf

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} SetExcedP()
Inicializa variavel lExcedPrv (Excedente para competencia prevista)

@author jose.delmondes
@since 15/08/2017
@version 1.0
@Return Nao possui
/*/
//-----------------------------------------------------------------------
Function SetExcedME(lConteudo)
lExcedMEnc	:= lConteudo
Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} SetExcedP()
Inicializa variavel lExcedNPrv (Excedente para competencia não prevista)

@author jose.delmondes
@since 15/08/2017
@version 1.0
@Return Nao possui
/*/
//-----------------------------------------------------------------------
Function SetExcedNP(lConteudo)
lExcedNPrv := lConteudo
Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} IsExced()
Verifica se a medição é Excedente

@author jose.delmondes
@since 15/08/2017
@version 1.0
@Return Logico:   True: eh excedente
                  False: Nao eh excedente
/*/
//-----------------------------------------------------------------------
Function IsExced()

lRet := lExcedMEnc .Or. lExcedNPrv
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121VldCalc
Função para validação do calculo dos campos totalizadores
@author israel.escorizza
@since 17/08/2017
@version V12.1.17
@return lRet
/*/
//--------------------------------------------------------------------
Function Cn121VldCalc(FModel)
	Local lRet := FModel:GetValue('CXNDETAIL','CXN_CHECK')
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121VlrTt
Função para calculo do totalizador com atualização do valor total
@author israel.escorizza
@since 17/08/2017
@version V12.1.17
@return lRet
/*/
//--------------------------------------------------------------------
Function Cn121VlrTt(oModel,nVlrAtu,xValor,lSoma,cIdField)
If xValor > 0
	nVlrAtu += xValor * Iif(lSoma,1,-1)
	Cn121VlrMd(oModel,nVlrAtu,xValor,lSoma,cIdField)
EndIf
Return nVlrAtu

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121VlrMd
Função para calculo do totalizador valor total e Retenção da caução
@author israel.escorizza
@since 17/08/2017
@version V12.1.17
@return lRet
/*/
//--------------------------------------------------------------------
Function Cn121VlrMd(oModel,nVlrAtu,xValor,lSoma,cIdField)
Local oModelCND := oModel:GetModel('CNDMASTER')
Local oModelTOT := oModel:GetModel('TOTMED')
Local lCposMBPed:= CND->(FieldPos("CND_VLMPED")) > 0 .And. CND->(FieldPos("CND_VLBPED")) > 0
Local nModCt	:= IIf(Cn121RetSt('COMPRA',0,, oModelCND:GetValue('CND_CONTRA')),1,-1)
Local nVlLiqd	:= oModelTOT:GetValue('CND_VLLIQD')
Local nTotMul	:= oModelTOT:GetValue('CND_VLMULT')
Local nTotBon	:= oModelTOT:GetValue('CND_VLBONI')
Local nTotDes	:= oModelTOT:GetValue('CND_DESCME')
Local nTotAdt	:= oModelTOT:GetValue('CND_TOTADT')
Local nVlrTot	:= 0
Local nRetCau	:= 0
Local nTotMPed  := 0
Local nTotBPed  := 0
Local nTotCauc  := 0

If lCposMBPed
    nTotMPed := oModelTOT:GetValue('CND_VLMPED')
    nTotBPed := oModelTOT:GetValue('CND_VLBPED')
EndIf

DO 	CASE
	CASE cIdField == 'CND_VLLIQD'
		nVlLiqd := nVlrAtu
	CASE cIdField == 'CND_VLMULT'
		nTotMul := nVlrAtu
	CASE cIdField == 'CND_VLBONI'
		nTotBon := nVlrAtu
	CASE cIdField == 'CND_VLMPED'
		nTotMPed := nVlrAtu
	CASE cIdField == 'CND_VLBPED'
		nTotBPed := nVlrAtu
	CASE cIdField == 'CND_DESCME'
		nTotDes := nVlrAtu
	CASE cIdField == 'CND_TOTADT'
		nTotAdt := nVlrAtu
ENDCASE

//Regras de aplicação de multa, desconto e bonificação
//Contratos de Compra:	Multas(-)|Bonificação(+)|Desconto(-)|Adiantamento(-)|Retenção(-)
//Contratos de Venda :  Multas(+)|Bonificação(-)|Desconto(-)|Adiantamento(-)|Retenção(-)
nVlrTot	:= nVlLiqd + ((nTotBon - nTotMul) * nModCt) - nTotDes - nTotAdt

If lCposMBPed //-- Calcula caução apenas com as multas/bonificações consideradas no pedido
    nTotCauc := nVlLiqd + ((nTotBPed - nTotMPed) * nModCt) - nTotDes - nTotAdt
EndIf

nRetCau	:= CN121RetCa( nTotCauc, oModel )

If cIdField != 'CND_RETCAC' .And. oModel:GetOperation() != MODEL_OPERATION_DELETE
	If nRetCau > 0
		oModelCND:LoadValue('CND_RETCAC',nRetCau)
		nVlrTot -= nRetCau
	Else
		oModelCND:LoadValue('CND_RETCAC',0)
	EndIf

	If cIdField != 'CND_VLTOT'
		oModelTOT:LoadValue('CND_VLTOT',nVlrTot)
	EndIf
Else
	nVlrTot := nRetCau
EndIf

Return nVlrTot

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121AutEnc
Função para desbloquear movimentações financeiras encerrada Aut. Fornecimento.
@author israel.escorizza
@since 22/08/2017
@version V12.1.17
@return lRet
/*/
//--------------------------------------------------------------------
Function Cn121AutEnc(nReg,lAviso)
Local cQuery 	:= ""
Local cPedidos 	:= ""
local cAliasQry := ""
Local cAliasSD1	:= ""
Local cAliasSE2	:= ""
Local cFilCND	:= xFilial("CND")

Local lGCTBloq 	:= SE2->(FieldPos("E2_MSBLQL")) > 0 //- Valida bloqueio de movimentação financeira pelo GCT
Local lBloqSE2  := .F.
Local oQuery as Object

Default lAviso 	:= .T.

Begin Transaction
	dbSelectArea("CND")
	CND->(MsGoTo(nReg)) //-- Posiciona na medicao

	RecLock('CND')
	CND->CND_SITUAC := 'FE'
	CND->CND_DTFIM 	:= dDataBase
	CND->(MsUnlock())

	cQuery := " SELECT DISTINCT "
	cQuery += " CXJ_NUMPED "
	cQuery += " FROM "
	cQuery += RetSQLName("CXJ") + " CXJ "
	cQuery += " WHERE CXJ.CXJ_FILIAL = ? AND CXJ.CXJ_NUMMED = ? AND CXJ.D_E_L_E_T_ = ? "

	cQuery    := ChangeQuery( cQuery )

	oQuery := FWExecStatement():New(cQuery)
	oQuery:SetString(1, CND->CND_FILIAL)
	oQuery:SetString(2, CND->CND_NUMMED)	
	oQuery:SetString(3, Space(1))

	cAliasQry := oQuery:OpenAlias()	

	While !(cAliasQry)->(Eof())
		If !Empty(cPedidos)
			cPedidos += ", "
		EndIf
		cPedidos += "'"+(cAliasQry)->CXJ_NUMPED+"'""
		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

	//- Seleciona a nota
	cQuery := " SELECT DISTINCT "
	cQuery += " SF1.F1_DOC, 	"
	cQuery += " SF1.F1_SERIE, 	"
	cQuery += " SF1.F1_TIPO,	"
	cQuery += " SF1.F1_DUPL,	"
	cQuery += " SF1.F1_PREFIXO,	"
	cQuery += " F1_FORNECE, 	"
	cQuery += " F1_LOJA 		"

	cQuery += " FROM "
	cQuery += RetSQLName("SF1") + " SF1, "
	cQuery += RetSQLName("SD1") + " SD1 "

	cQuery += " WHERE
	cQuery += " SF1.F1_FILIAL  = '"+xFilial("SF1")+"' 	AND "
	cQuery += " SD1.D1_FILIAL  = '"+xFilial("SD1")+"' 	AND "
	cQuery += " SF1.F1_DOC     = SD1.D1_DOC     		AND "
	cQuery += " SF1.F1_SERIE   = SD1.D1_SERIE   		AND "
	cQuery += " SF1.F1_TIPO    = SD1.D1_TIPO    		AND "
	cQuery += " SF1.F1_FORNECE = SD1.D1_FORNECE 		AND "
	cQuery += " SF1.F1_LOJA    = SD1.D1_LOJA    		AND "
	cQuery += " SD1.D1_PEDIDO  IN ("+cPedidos+") 		AND "
	cQuery += " SF1.D_E_L_E_T_ = ' ' 					AND "
	cQuery += " SD1.D_E_L_E_T_ = ' '"

	cQuery    := ChangeQuery( cQuery )
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasQry, .F., .T. )

	If !(cAliasQry)->(Eof())
		//³ Seleciona os pedidos relacionados na mesma nota   ³
		cQuery := " SELECT DISTINCT SD1.D1_PEDIDO "
		cQuery += " FROM " + RetSQLName("SD1") + " SD1 "
		cQuery += " WHERE "
		cQuery += " SD1.D1_FILIAL 	= 	'" + xFilial("SD1") + "' 		AND "
		cQuery += " SD1.D1_DOC		= 	'" + (cAliasQry)->F1_DOC + "' 	AND "
		cQuery += " SD1.D1_SERIE  	= 	'" + (cAliasQry)->F1_SERIE + "' AND "
		cQuery += " SD1.D1_TIPO   	= 	'" + (cAliasQry)->F1_TIPO + "' 	AND "
		cQuery += " SD1.D1_PEDIDO 	NOT IN 	("+cPedidos+") 	AND "
		cQuery += " SD1.D_E_L_E_T_ 	= 	' '"

		cQuery    := ChangeQuery( cQuery )
		cAliasSD1 := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasSD1, .F., .T. )

		While !(cAliasSD1)->(Eof())
			dbSelectArea("SC7")
			SC7->(dbSetOrder(1))
			If SC7->(MsSeek(xFilial("SC7")+(cAliasSD1)->D1_PEDIDO))
				//³ Verifica se o pedido foi originado por uma medicao³
				If !Empty(SC7->C7_CONTRA)
					dbSelectArea("CND")
					CND->(dbSetOrder(1))

					//³ Posiciona na Medicao ³
					If CND->(MsSeek(cFilCND+SC7->(C7_CONTRA+C7_CONTREV+C7_PLANILH+C7_MEDICAO)))
						//³ Quando houver alguma medicao NAO encerrada impede o desbloqueio dos titulos ³
						If Empty(CND->CND_DTFIM)
							lBloqSE2 := .T.
							Exit
						EndIf
					EndIf
				EndIf
			EndIf
			(cAliasSD1)->(dbSkip())
		EndDo
		(cAliasSD1)->(dbCloseArea())

		//³ Desbloqueia os titulos ³
		If !lBloqSE2 .And. lGCTBloq
			//³ Seleciona os titulos ³
			cQuery := "	SELECT SE2.R_E_C_N_O_ AS RECNO "
			cQuery += " FROM " + RetSQLName("SE2") + " SE2 "
			cQuery += " WHERE "
			cQuery += " SE2.E2_FILIAL  		= '" + xFilial("SE2") + "'"
			cQuery += " AND SE2.E2_NUM     	= '" + (cAliasQry)->F1_DUPL + "'"
			cQuery += " AND SE2.E2_PREFIXO 	= '" + IIf(Empty((cAliasQry)->F1_PREFIXO),&(SuperGetMV("MV_2DUPREF")),(cAliasQry)->F1_PREFIXO) + "'"
			cQuery += " AND SE2.E2_FORNECE 	= '" + (cAliasQry)->F1_FORNECE + "'"
			cQuery += " AND SE2.E2_LOJA    	= '" + (cAliasQry)->F1_LOJA + "'"
			cQuery += " AND SE2.E2_TIPO    	= 'NF '"
			cQuery += " AND SE2.D_E_L_E_T_ 	= ' ' "

			cQuery    := ChangeQuery( cQuery )
			cAliasSE2 := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasSE2, .F., .T. )

			//³ Desbloqueia os titulos ³
			While !(cAliasSE2)->(Eof())
				SE2->( MsGoTo( (cAliasSE2)->RECNO ) )
				RecLock("SE2",.F.)
				SE2->E2_MSBLQL := "2"
				MsUnlock()
				(cAliasSE2)->(dbSkip())
			EndDo
			(cAliasSE2)->(dbCloseArea())
		EndIf
	EndIf
	(cAliasQry)->(dbCloseArea())

End Transaction

FreeObj(oQuery)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121AutEst
Função para estornar Aut. Fornecimento.
@author israel.escorizza
@since 22/08/2017
@version V12.1.17
@return lRet
/*/
//--------------------------------------------------------------------
Function Cn121AutEst(nReg, lAviso)
Local cQuery 	:= ""
Local cPedidos 	:= ""
local cAliasQry := ""
Local cAliasSE2	:= ""

Local lGCTBloq 	:= SE2->(FieldPos("E2_MSBLQL")) > 0 //- Valida bloqueio de movimentação financeira pelo GCT
Local lBloqSE2  := .F.
Local lRet 		:= .T.

Default lAviso	:= .T.

Begin Transaction
	dbSelectArea("CND")
	CND->(MsGoTo(nReg)) //-- Posiciona na medicao

	cQuery := " SELECT DISTINCT "
	cQuery += " CXJ_NUMPED "
	cQuery += " FROM "
	cQuery += RetSQLName("CXJ") + " CXJ "
	cQuery += " WHERE CXJ.CXJ_NUMMED = '"+CND->CND_NUMMED+"' AND CXJ.D_E_L_E_T_ = '' "

	cQuery    := ChangeQuery( cQuery )
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasQry, .F., .T. )

	While !(cAliasQry)->(Eof())
		If !Empty(cPedidos)
			cPedidos += ", "
		EndIf
		cPedidos += "'"+(cAliasQry)->CXJ_NUMPED+"'""
		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

	//- Seleciona a nota
	cQuery := " SELECT DISTINCT "
	cQuery += " SF1.F1_DOC, 	"
	cQuery += " SF1.F1_SERIE, 	"
	cQuery += " SF1.F1_TIPO,	"
	cQuery += " SF1.F1_DUPL,	"
	cQuery += " SF1.F1_PREFIXO,	"
	cQuery += " F1_FORNECE, 	"
	cQuery += " F1_LOJA 		"

	cQuery += " FROM "
	cQuery += RetSQLName("SF1") + " SF1, "
	cQuery += RetSQLName("SD1") + " SD1 "

	cQuery += " WHERE
	cQuery += " SF1.F1_FILIAL  = '"+xFilial("SF1")+"' 	AND "
	cQuery += " SD1.D1_FILIAL  = '"+xFilial("SD1")+"' 	AND "
	cQuery += " SF1.F1_DOC     = SD1.D1_DOC     		AND "
	cQuery += " SF1.F1_SERIE   = SD1.D1_SERIE   		AND "
	cQuery += " SF1.F1_TIPO    = SD1.D1_TIPO    		AND "
	cQuery += " SF1.F1_FORNECE = SD1.D1_FORNECE 		AND "
	cQuery += " SF1.F1_LOJA    = SD1.D1_LOJA    		AND "
	cQuery += " SD1.D1_PEDIDO  IN ("+cPedidos+") 		AND "
	cQuery += " SF1.D_E_L_E_T_ = ' ' 					AND "
	cQuery += " SD1.D_E_L_E_T_ = ' '"

	cQuery    := ChangeQuery( cQuery )
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasQry, .F., .T. )

	If !(cAliasQry)->(Eof())
		//- Verifica os valores dos titulos
		cQuery := " SELECT SUM(E2_VALOR) AS E2_VALOR,SUM(E2_SALDO) AS E2_SALDO "
		cQuery += " FROM " + RetSQLName("SE2") + " SE2 "
		cQuery += " WHERE SE2.E2_FILIAL  = '" + xFilial("SE2") + "'"
		cQuery += " AND SE2.E2_NUM     = '" + (cAliasQry)->F1_DUPL + "'"
		cQuery += " AND SE2.E2_PREFIXO = '" + IIf(Empty((cAliasQry)->F1_PREFIXO),&(SuperGetMV("MV_2DUPREF")),(cAliasQry)->F1_PREFIXO) + "'"
		cQuery += " AND SE2.E2_FORNECE = '" + (cAliasQry)->F1_FORNECE + "'"
		cQuery += " AND SE2.E2_LOJA    = '" + (cAliasQry)->F1_LOJA + "'"
		cQuery += " AND SE2.E2_TIPO    = 'NF '"
		cQuery += " AND SE2.D_E_L_E_T_ = ' '"

		cQuery    := ChangeQuery( cQuery )
		cAliasSE2 := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasSE2, .F., .T. )

		TCSetField( cAliasSE2, "E2_VALOR", "N", TamSX3("E2_VALOR")[1], TamSX3("E2_VALOR")[2] )
		TCSetField( cAliasSE2, "E2_SALDO", "N", TamSX3("E2_SALDO")[1], TamSX3("E2_SALDO")[2] )

		//- Verifica se houve movimentacoes nos titulos
		If (cAliasSE2)->E2_VALOR > (cAliasSE2)->E2_SALDO
			If lAviso
				Aviso("CNTA121",OemToAnsi(STR0160)+(cAliasQry)->F1_DOC+"/"+ SerieNfID("SF1", 2, "F1_SERIE") +OemToAnsi(STR0161),{STR0156})//STR0160"Não foi possível estornar a autorização de fornecimento, pois a NFE: "##" possui movimentações financeiras."
				lRet := .F.
			EndIf
			lBloqSE2 := .T.
		EndIf
		(cAliasSE2)->(dbCloseArea())

		If !lBloqSE2 .And. lGCTBloq
			//- Seleciona os titulos
			cQuery := " SELECT SE2.R_E_C_N_O_ AS RECNO "
			cQuery += " FROM " + RetSQLName("SE2") + " SE2 "
			cQuery += " WHERE SE2.E2_FILIAL  = '" + xFilial("SE2") + "'"
			cQuery += " AND SE2.E2_NUM     = '" + (cAliasQry)->F1_DUPL + "'"
			cQuery += " AND SE2.E2_PREFIXO = '" + IIf(Empty((cAliasQry)->F1_PREFIXO),&(SuperGetMV("MV_2DUPREF")),(cAliasQry)->F1_PREFIXO) + "'"
			cQuery += " AND SE2.E2_FORNECE = '" + (cAliasQry)->F1_FORNECE + "'"
			cQuery += " AND SE2.E2_LOJA    = '" + (cAliasQry)->F1_LOJA + "'"
			cQuery += " AND SE2.E2_TIPO    = 'NF '"
			cQuery += " AND SE2.D_E_L_E_T_ = ' '"

			cQuery    := ChangeQuery( cQuery )
			cAliasSE2 := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasSE2, .F., .T. )

			//- Bloqueia os titulos
			While !(cAliasSE2)->(Eof())
				SE2->(MsGoTo((cAliasSE2)->RECNO))
				RecLock("SE2",.F.)
					SE2->E2_MSBLQL := "1"
				MsUnlock()
				(cAliasSE2)->(dbSkip())
			EndDo
			(cAliasSE2)->(dbCloseArea())
		EndIf

	EndIf
	(cAliasQry)->(dbCloseArea())

	If !lBloqSE2
		RecLock("CND",.F.)
		CND->CND_DTFIM 	:= CTOD("")
		CND->CND_SITUAC := "FA"
		MsUnlock()
	EndIf
End Transaction

If lRet .And. lAviso
	Aviso("CNTA121",OemToAnsi(STR0113),{STR0156})	//"Autorização de fornecimento estornada com sucesso"
EndIf

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} GCTExcedNP(cNumMed)
Verifica se todos os itens da medição são excedentes
(Excedente para competencia não prevista)

@author jose.delmondes
@since 23/08/2017
@version 1.0
@Return Logico:   True: Eh uma medição de excedente para competência não prevista
                  False: Nao eh uma medição de excedente para competência não prevista
/*/
//-----------------------------------------------------------------------
Function GCTExcedNP(cNumMed)
Local lRet	:= .F.
Local cAliasCNE	:= GetNextAlias()

//Conta a quantidade de itens não excedentes da medição
BeginSQL alias cAliasCNE

SELECT	COUNT(*) AS QTD
FROM 	%table:CNE% CNE
WHERE	CNE_FILIAL= %xFilial:CNE% AND
		CNE.CNE_NUMMED = %Exp:cNumMed% AND
		CNE.CNE_EXCEDE <> '1' AND
		CNE.%NotDel%

EndSQL

//Se não houver nenhum item que não seja excedente, a medição é considerada como excedente para competencia não prevista
IF (cAliasCNE)->QTD == 0
	lRet := .T.
EndIf

(cAliasCNE)->(dbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn121GAutF()
Função para retornar o valor da variavel estatica lAutForn
@author israel.escorizza
@since 24/08/2017
@version V12.1.17
@return lAutForn
/*/
//--------------------------------------------------------------------
Function Cn121GAutF(lValor, lSet)
	Default lValor	:= .T.
	Default lSet	:= .F.

	lAutForn := IIF(lSet, lValor, lAutForn)
Return lAutForn

/*/{Protheus.doc} VlExcPCAut()
	Função para validar exclusão do pedido de compra da autorização de fornecimento
@author israel.escorizza
@since 24/08/2017
@version V12.1.17
@return lRet
/*/
Static Function VlExcPCAut(oModel)
	Local aAreas 	:= {SC7->(GetArea()), GetArea()}
	Local cAliasTemp:= GetNextAlias()
	Local cFilMed	:= ""
	Local cNumMed	:= ""
	Local cContra	:= ""
	Local cRevisa	:= ""
	Local lRet		:= .T.
	Local cChave	:= ""
	Local cMedVazia	:= Space(GetSx3Cache('C7_MEDICAO'	,'X3_TAMANHO'))
	Local cCtrVazio	:= Space(GetSx3Cache('C7_CONTRA'	,'X3_TAMANHO'))
	Local cRevVazia	:= Space(GetSx3Cache('C7_CONTREV'	,'X3_TAMANHO'))
	Default oModel	:= FwModelActive()

	cFilMed	:= xFilial("SC7", oModel:GetValue('CNDMASTER','CND_FILMED'))
	cNumMed	:= oModel:GetValue('CNDMASTER','CND_NUMMED')
	cContra	:= oModel:GetValue('CNDMASTER','CND_CONTRA')
	cRevisa	:= oModel:GetValue('CNDMASTER','CND_REVISA')

	BeginSQL Alias cAliasTemp
	SELECT DISTINCT C7_NUM
	FROM %Table:SC7%
		WHERE 
			C7_FILIAL  	= %Exp:cFilMed%
		AND C7_CONTRA 	= %Exp:cContra%
		AND C7_CONTREV 	= %Exp:cRevisa%
		AND C7_MEDICAO 	= %Exp:cNumMed%
		AND %NotDel%
	EndSQL

	SC7->(dbSetOrder(1))
	While lRet .And. (cAliasTemp)->(!Eof())
		cChave := cFilMed + (cAliasTemp)->C7_NUM
		If SC7->(MsSeek(cChave))
			If (lRet := MaCanDelPC("SC7"))
				While SC7->(C7_FILIAL+C7_NUM == cChave .And. !Eof())
					RecLock("SC7", .F.)
					/*Necessário limpar esses campos pra permitir exclusão do registro, caso contrário a validação de integridade não permite.
					Mesmo sem esses campos o sistema consegue posteriormente excluir o pedido através da CXJ*/
					SC7->C7_CONTRA	:= cCtrVazio
					SC7->C7_CONTREV	:= cRevVazia
					SC7->C7_MEDICAO	:= cMedVazia
					SC7->(MsUnlock())
					SC7->(DbSkip())	
				EndDo
			EndIf
		EndIf
		(cAliasTemp)->(dbSkip())
	EndDo
	(cAliasTemp)->(dbClosearea())

	aEval(aAreas, {|x|RestArea(x)})
	FwFreeArray(aAreas)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121CondC()
Função para tratar condição de execução do gatilho das entidades contábeis
para medições que permitam informar o produto.

@author Israel Escorizza
@since 31/10/2017
@return lRet
/*/
//-------------------------------------------------------------------
Function CN121CondC()
Local lRet 		:= .F.
Local lModel	:= .F.
Local cFilCtr	:= ""
Local cContra 	:= ""
Local cPlan		:= ""

Local oModel 	:= Nil

If FwIsInCallStack("CN121Item")//Nessa situação os campos das entidades serão carregados à partir da CNB
	lRet := .F.
Else
	DO 	CASE
		CASE IsInCallStack('CNTA121') .And. !FwIsInCallStack('CN121OldMd')
			oModel		:= FwModelActive()
			cFilCtr	:= oModel:GetValue('CNDMASTER','CND_FILCTR')
			cContra 	:= oModel:GetValue('CNDMASTER','CND_CONTRA')
			cPlan		:= oModel:GetValue('CXNDETAIL','CXN_NUMPLA')
			lModel		:= .T.

		CASE (IsInCallStack('CNTA120') .Or. FwIsInCallStack('CN121OldMd'))
			cFilCtr		:= M->CND_FILCTR
			cContra		:= M->CND_CONTRA
			cPlan		:= M->CND_NUMERO
	ENDCASE

	If !(lRet := Cn121RetSt('EVENTUAL',0,cPlan,cContra,lModel,,cFilCtr))
		lRet  := Cn121RetSt('SEMIAGRUP',0,cPlan,cContra,lModel,,cFilCtr)
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121Liq()
Atualiza o valor líquido dos itens (CNE_VLLIQD)

@author jose.delmondes
@since 21/11/2017
/*/
//-------------------------------------------------------------------
Function Cn121Liq(oModel)

Local oModelCND	:= oModel:GetModel('CNDMASTER')
Local oModelCXN	:= oModel:GetModel('CXNDETAIL')
Local oModelCNE	:= oModel:GetModel('CNEDETAIL')

Local cEspCtr		:= Cn121RetSt('ESPECIE', , , oModelCND:GetValue('CND_CONTRA') , .F. , ,oModelCND:GetValue('CND_FILCTR'))

Local nX	:= 0
Local nY 	:= 0
Local nCaucPla	:= 0
Local nPercCauc	:= 0

Local lExced	:= IsExced()
Local lCanCNE   := oModelCNE:CanUpdateLine()

If !lCanCNE //-- Caso estiver bloqueado libera CNE
    CNTA300BlMd(oModel:GetModel('CNEDETAIL'),,.T.)
EndIf

For nX := 1 To oModelCXN:Length()

	oModelCXN:GoLine(nX)

	If oModelCXN:GetValue('CXN_CHECK')

		//-- Calcula o percentual de caucao para a planilha
		nPercCauc	:= oModelCXN:GetValue('CXN_VLLIQD') / oModelCND:GetValue('CND_VLLIQD')
		nCaucPla	:= nPercCauc * oModelCND:GetValue('CND_RETCAC')

		For nY := 1 To oModelCNE:Length()

			oModelCNE:GoLine(nY)

			//-- Calculo do valor liquido do item
			If !lExced 
				nValLiq := CN130Liq( cEspCtr , oModelCNE:GetValue('CNE_VLTOT') , oModelCNE:GetValue('CNE_VLDESC') , oModelCXN:GetValue('CXN_VLLIQD') , oModelCXN:GetValue('CXN_VLMULT') , oModelCXN:GetValue('CXN_VLBONI') , oModelCXN:GetValue('CXN_VLDESC') , nCaucPla ,oModelCXN:GetValue('CXN_VLRADI'))
				oModelCNE:LoadValue( 'CNE_VLLIQD' , nValLiq )
			ElseIf oModelCNE:GetValue('CNE_EXCEDE') == '1'
				oModelCNE:LoadValue( 'CNE_VLLIQD' , oModelCNE:GetValue('CNE_VLTOT')  )
			EndIf

		Next nY

	EndIf

Next nX

If !lCanCNE //-- Restaura bloqueio da CNE
    CNTA300BlMd(oModel:GetModel('CNEDETAIL'),.T.)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121RatP(oModel)
Função de importação de Rateio Pré-Configurado

@author israel.escorizza
@since 06/12/2017
/*/
//-------------------------------------------------------------------
Function CN121RatP(oModel, oView, aAuto)
Local aSaveLines:= FWSaveRows()
Local oModelCNE	:= oModel:GetModel('CNEDETAIL')
Local oModelCNZ	:= oModel:GetModel('CNZDETAIL')
Local nPos		:= 0
Local cChave	:= ""
Local bRateio	:= { |x,y,z| GCTRatMVC(x,@y,z) }
Local cItem		:= ''
Default aAuto	:= {}

If oModelCNE:IsDeleted() .Or. Empty(oModelCNE:GetValue('CNE_PRODUT'))
	Help("",1,"CN121RATP",,STR0164,4,1)
ElseIf(ValType(oView) == "O")
	AdmRatExt( , , bRateio, oModelCNZ )
	If(oView:HasError())
		oView:ShowLastError()
	EndIf
ElseIf(Len(aAuto) > 0)
	If((nPos := aScan(aAuto, {|x| x[1] == "CTJ_FILIAL"})) > 0)
		cChave := aAuto[nPos, 2]
		If((nPos := aScan(aAuto, {|x| x[1] == "CTJ_RATEIO"})) > 0)
			cChave += aAuto[nPos, 2]						
			CTJ->(dbSetOrder(1))//CTJ_FILIAL+CTJ_RATEIO
			If(CTJ->(DbSeek(cChave)))
				oModelCNZ:GoLine(1)
				oModelCNZ:LoadValue("CNZ_ITEM", StrZero(1, Len(CNZ->CNZ_ITEM)))
				Eval(bRateio, oModelCNZ, @cItem, .T.)
				While ( CTJ->(!Eof() .And. CTJ_FILIAL+CTJ_RATEIO == cChave) )
					Eval(bRateio, oModelCNZ, @cItem, .F.)
					CTJ->(dbSkip())
				EndDo
			EndIf			
		EndIf
	EndIf	
EndIf

FWRestRows(aSaveLines)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121ClrAc()
Apaga o conteúdo da static aComp.
Função utilizada quando há execução em lote.
@author mateus.boiani
@since 21/12/2017
/*/
//-------------------------------------------------------------------
Function CN121ClrAc()
aComp := {}
Return
//==============================================================================================================================
/*/{Protheus.doc} Cn121Track() - Tracker da nova medição
@Param	
@author Israel.Escorizza 
@since 	23/03/2018 
@return Nil
/*/
//==============================================================================================================================
Function Cn121Track(oModel)
Local aArea		:= GetArea() 
Local aSaveLine	:= FWSaveRows()
Local aEnt		:= {}

Local oModelCND	:= Nil
Local cSeekKey 	:= ""

Default oModel := FwModelActive()

If oModel:GetId() == 'CNTA121'
	oModelCND:= oModel:GetModel('CNDMASTER')
	cSeekKey := xFilial("CND") + oModelCND:GetValue('CND_CONTRA') + oModelCND:GetValue('CND_REVISA') + oModelCND:GetValue('CND_NUMMED')

	AAdd( aEnt, { "CND21", cSeekKey} )
	MaTrkShow( aEnt )
Else
	Help(" ",1, 'Help','CN121TRK01',,4,0) 	//- "Modelo ativo invalido"
EndIf


FWRestRows( aSaveLine )     
RestArea(aArea)
Return 
//--------------------------------------------------------------------
/*/{Protheus.doc} VldPedTit()
Valid do campo CNE_PEDTIT

@author jose.delmondes
@since 20/04/2018
@version 1.0
@return Logico			
/*/
//-------------------------------------------------------------------
Function VldPedTit()
	Local lRet		:= .T.
	Local oModel	:= Nil
	Local oModelCNE	:= Nil
	Local oModelCNZ := Nil
	Local lCompra	:= .F.
	Local lPedido   := .F. 
	Local lReinf	:= CNE->( Columnpos('CNE_15ANOS') ) > 0 
	Local lAuto		:= .F.
	Local lMVC		:= .F.
	Local cContra	:= ""
	Local cFilCtr	:= ""
	Local cPedTit	:= ""
	Local cItemRat  := ""
	Local aCposReinf:= {'CNE_15ANOS', 'CNE_20ANOS', 'CNE_25ANOS'}
	Local nTotal	:= 0
	Local nIndItem  := 0
	Local nX		:= 0
	Local nRat      := 0
	Local aRateios  := {}
	Local aHeadCNZ	:= {}

	If lReinf
		lAuto	:= IsBlind()
		lMVC 	:= !(FwIsInCallStack('CNTA120') .Or. FwIsInCallStack('CN121OldMd'))
		
		If lMVC
			oModel := FwModelactive()
			oModelCNE := oModel:GetModel('CNEDETAIL')
			oModelCNZ := oModel:GetModel('CNZDETAIL')
			cContra	:= oModel:GetValue( 'CNDMASTER' , 'CND_CONTRA' )
			cFilCtr	:= oModel:GetValue( 'CNDMASTER' , 'CND_FILCTR' )
			cPedTit	:= oModelCNE:GetValue('CNE_PEDTIT')
			aEval(aCposReinf, {|x| nTotal += oModelCNE:GetValue(x)})
		Else
			cContra	:= M->CND_CONTRA
			cFilCtr	:= M->CND_FILCTR
			nX := aScan(aHeader, {|x| AllTrim(x[2]) == 'CNE_PEDTIT' })
			If (nX  > 0)
				cPedTit	:= 	aCols[n, nX]
			EndIf

			for nX := 1 to Len(aCposReinf)
				aCposReinf[nX] := aScan(aHeader, {|x| AllTrim(x[2]) == aCposReinf[nX] })
			next nX

			aEval(aCposReinf, {|x| nTotal += IIF(x > 0, aCols[n, x ], 0) })
		EndIf
		
		lCompra:= Cn121RetSt("COMPRA", , , cContra , .F. , ,cFilCtr)
		
		If ( lCompra .And. cPedTit == '1' .And.  nTotal > 0 )
			
			If lAuto .Or. ( !lAuto .And. MsgYesNo( STR0213 +CRLF+CRLF+ STR0214 ) )//Os valores de aposentadoria especial serão zerados. Deseja prosseguir com a alteração?
				
				If lMvc
					aEval(aCposReinf, {|x| oModelCNE:LoadValue(x, 0)}) //Zera os valores
				Else
					aEval(aCposReinf, {|x| IIF(x > 0, aCols[n, x] := 0, 0) })//Zera valores					
				EndIf
				
			Else
				lRet := .F.
			EndIf
		EndIf
		If lRet
			If lMVC
				lPedido := cPedtit == "1"
				lRet:= GCTDuplRat(oModelCNZ,,lCompra,lPedido,.F.)
			ElseIf Type("aAuxRat") == "A" .And. Len(aAuxRat) > 0
				nIndItem:= aScan(aHeader, {|x| AllTrim(x[2]) == 'CNE_ITEM' })
				cItemRat:= AllTrim(aCols[n][nIndItem])
				nRat	:= aScan(aAuxRat,{|x| AllTrim(x[4]) == cItemRat })
				If nRat > 0
					aRateios:= aAuxRat[nRat][5]
					If Len(aRateios) > 1
						aHeadCNZ	:= GCTHeadCNZ()
						lPedido		:= M->CNE_PEDTIT == "1"
						lRet		:= MedDuplRat(aHeadCNZ,aRateios,n,.F.,lPedido)
						FwFreeArray(aHeadCNZ)
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet

//==============================================================================================================================
/*/{Protheus.doc} CxnZeroWhe() - Função When do campo CXN_ZERO
@Param	
@author Israel.Escorizza 
@since 	02/05/2018 
@return lRet
/*/
//==============================================================================================================================
Function CxnZeroWhe()
Local  lRet := ( ( !Empty(FwFldGet('CXN_CRONOG')) .Or. !Empty(FwFldGet('CXN_PARCEL')) ) .And. SuperGetMV("MV_CNNOPED",.F.,.T.) )  .Or. GCTGsMvZer() 
Return lRet

//==============================================================================================================================
/*/{Protheus.doc} CN121SLDZR(oModel)
Funcao para processamento da medicao zerada
@author jose.delmondes
@since 16/04/2018
@version 1.0
@return 
/*/
//==============================================================================================================================
Function CN121ZERO( cContra , cRevisa , cMed , cPlan , cFilCtr , nOpc )
	Local aAreas	:= {CXN->(Getarea()), CNF->(GetArea()), CNA->(GetArea()), GetArea()}
	Local lCNPROVI	:= GetNewPar( "MV_CNPROVI" ,  "S" ) == "S"
	Local lRecorre	:= .F.

	dbSelectArea('CXN')
	CXN->( dbSetOrder(1) )

	If CXN->( dbSeek( xFilial('CXN') + cContra + cRevisa + cMed + cPlan ) )
		
		dbSelectArea('CNF')
		CNF->( dbSetOrder(3) )
		
		If CNF->(dbSeek( xFilial('CNF', cFilCtr) + cContra + cRevisa + CXN->CXN_CRONOG + CXN->CXN_PARCEL ))
			
			Do Case				
				Case nOpc == '1' 	//-- Encerramento da medicao
					
					//-- Exclui titulo provisorio, referente a parcela do cronograma financeiro
					If lCNPROVI
						CN100ETit( cContra , cRevisa , CNF->CNF_NUMERO , CNF->CNF_PARCEL , cFilCtr )
					EndIf
					
					//-- Preenche data de realizacao da parcela
					RecLock("CNF")
						CNF->CNF_DTREAL := dDataBase
					MsUnlock()
					
				Case nOpc == '2'	//-- Estorno da medicao
					
					//-- Gera titulo provisorio
					If lCNPROVI
						CN100CTit( cContra , cRevisa , CNF->CNF_NUMERO , CNF->CNF_PARCEL , CNF->CNF_SALDO , cFilCtr )
					EndIf
					
					//-- Limpa data de realizacao da parcela
					RecLock("CNF")
						CNF->CNF_DTREAL := CTOD("")
					MsUnlock()
			
			EndCase
			
		EndIf
		
		lRecorre := CN121RetSt("RECORRENTE", 0, CXN->CXN_NUMPLA, CXN->CXN_CONTRA, .F., Nil, cFilCtr)
		If lRecorre .And. CxnZeroWhe() 
			CNA->(dbSetOrder(1))				
			If CNA->(DbSeek(xFilial("CNA",cFilCTR)+CXN->(CXN_CONTRA+CXN_REVISA+CXN_NUMPLA)))
				UpdSldCNA(lRecorre, .F.	, .F., .F., 0, 0, 0, (nOpc == '2'))					
			EndIf
		EndIf		
	EndIf

	aEval(aAreas,{|x|RestArea(x)})
	FwFreeArray(aAreas)
Return

//==============================================================================================================================
/*/{Protheus.doc} Cn121NatTt() - Função responsável por definir a natureza que será encaminhada para o titulo.
@Param	
@author Israel.Escorizza 
@since 	16/05/2018 
@return cRetNat	- Natureza a ser utilizada.
/*/
//==============================================================================================================================
Function Cn121NatTt(lTitPag,aDocs,cFilContr,nPosic)
Local aArea		:= GetArea() 
Local aSaveLine	:= FWSaveRows()

Local lCN121NAT := ExistBlock("CN121NAT")
Local cRetNat	:= ""

//- Variaveis posicionamento no array
Local nNumMed	:= IIf(lTitPag,aScan(aDocs[nPosic,2],{|x|x[1] == 'E2_MEDNUME'}),aScan(aDocs[nPosic,2],{|x|x[1] == 'E1_MEDNUME'}))
Local nContra	:= IIf(lTitPag,aScan(aDocs[nPosic,2],{|x|x[1] == 'E2_MDCONTR'}),aScan(aDocs[nPosic,2],{|x|x[1] == 'E1_MDCONTR'}))
Local nRevisa	:= IIf(lTitPag,aScan(aDocs[nPosic,2],{|x|x[1] == 'E2_MDREVIS'}),aScan(aDocs[nPosic,2],{|x|x[1] == 'E1_MDREVIS'}))
Local nPlan		:= IIf(lTitPag,aScan(aDocs[nPosic,2],{|x|x[1] == 'E2_MDPLANI'}),aScan(aDocs[nPosic,2],{|x|x[1] == 'E1_MDPLANI'}))
Local nForCli	:= IIf(lTitPag,aScan(aDocs[nPosic,2],{|x|x[1] == 'E2_FORNECE'}),aScan(aDocs[nPosic,2],{|x|x[1] == 'E1_CLIENTE'}))
Local nLoja		:= IIf(lTitPag,aScan(aDocs[nPosic,2],{|x|x[1] == 'E2_LOJA'})   ,aScan(aDocs[nPosic,2],{|x|x[1] == 'E1_LOJA'}))

//- Atribuição de variaveis para utilização
Local cNumMed	:= IIf(nNumMed > 0, aDocs[nPosic,2,nNumMed,2], '')
Local cContra	:= IIf(nContra > 0, aDocs[nPosic,2,nContra,2], '')
Local cRevisa	:= IIf(nRevisa > 0, aDocs[nPosic,2,nRevisa,2], '')
Local cForCli	:= IIf(nForCli > 0, aDocs[nPosic,2,nForCli,2], '')
Local cLoja		:= IIf(nLoja > 0  , aDocs[nPosic,2,nLoja,2]  , '')
Local cNumPlan	:= IIf(nPlan > 0  , aDocs[nPosic,2,nPlan,2]  , '')

Default cFilContr := cFilCtr

If lCN121NAT //- Executa ponto de entrada para definição de natureza.
	cRetNat := ExecBlock("CN121NAT",.F.,.F.,{xFilial("CND", cFilContr), cNumMed})
Else

	cRetNat := GetNatCtr(cFilContr, cContra, cRevisa, cNumPlan)//Verifica natureza do contrato
	
	If Empty(cRetNat)
	
		//- Verifica natureza do Cliente/Fornecedor
		If lTitPag
			cRetNat := POSICIONE('SA2',1,xFilial('SA2',cFilContr)+cForCli+cLoja,'A2_NATUREZ') //- FORNECEDOR: A2_FILIAL+A2_COD+A2_LOJA
		Else
			cRetNat := POSICIONE('SA1',1,xFilial('SA1',cFilContr)+cForCli+cLoja,'A1_NATUREZ') //- CLIENTE: A1_FILIAL+A1_COD+A1_LOJA
		EndIf
		
		If Empty(cRetNat)			
			//- Utiliza a natureza do parametro.
			cRetNat := SuperGetMv("MV_CNNATMD",.F.,"")
			If Empty(cRetNat)
				Help( " ", 1, "NOCNNATMD" )//"A natureza informada no parâmetro MV_CNNATMD não está cadastrada.
			Endif
		EndIf
	EndIf
	
	//- Garante que o retorno será do tamanho correto do campo.
	cRetNat := PadR(cRetNat, Iif(lTitPag, TAMSX3('E2_NATUREZ')[1], TAMSX3('E1_NATUREZ')[1]))
EndIf

FWRestRows( aSaveLine )     
RestArea(aArea)
Return cRetNat

//-----------------------------------------------------------------------
/*/{Protheus.doc} CN121VParc()
Valida existência de parcela no cronograma financeiro

@author jose.delmondes
@since 22/05/2018
@version 1.0
@Return Logico: 	True -> parcela existe
				  	False -> parcela nao existe
/*/
//-----------------------------------------------------------------------
Function CN121VParc()
Local aArea	:= GetArea()
Local cAliasCNF	:= GetNextAlias()
Local oModel	:= FWModelActive()
Local oModelCXN	:= oModel:GetModel('CXNDETAIL')
Local oModelCND	:= oModel:GetModel('CNDMASTER')
Local lRet	:= .T.

BeginSQL Alias cAliasCNF
	
	SELECT	CNF_NUMERO, CNF_DTVENC, CNF_VLPREV
	
	FROM 	%Table:CNF% CNF
	
	WHERE	CNF.CNF_FILIAL = %xFilial:CNF%	AND
			CNF.CNF_CONTRA = %Exp:oModelCND:GetValue('CND_CONTRA')% AND
			CNF.CNF_REVISA = %Exp:oModelCND:GetValue('CND_REVISA')% AND
			CNF.CNF_NUMERO = %Exp:oModelCXN:GetValue('CXN_CRONOG')% AND
			CNF.CNF_PARCEL = %Exp:oModelCXN:GetValue('CXN_PARCEL')% AND
			CNF.CNF_COMPET = %Exp:oModelCND:GetValue('CND_COMPET')% AND
			CNF.%NotDel%
EndSQL


If (cAliasCNF)->(EOF())
	lRet := .F.
Else
	TCSetField(cAliasCNF,"CNF_DTVENC","D")
	oModelCXN:LoadValue('CXN_DTVENC',(cAliasCNF)->(CNF_DTVENC))
	oModelCXN:LoadValue('CXN_VLPREV',(cAliasCNF)->(CNF_VLPREV))
EndIf

(cAliasCNF)->(dbCloseArea())

RestArea(aArea)

Return lRet				 

//-------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Rotina para integração EAI

@author janaina.jesus
@since 14/05/2018
/*/
//-------------------------------------------------------------------
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage, cVersion)
Local  aRet	:= 	CNTI121( cXML, nTypeTrans, cTypeMessage, cVersion)
Return aRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} A121SeqTit()
Obtém o próximo número sequencial para inclusão de títulos.

@author janaina.jesus
@since 12/07/2018
@version 1.0
@Return caracter: próximo número disponível.
/*/
//-----------------------------------------------------------------------
Function A121SeqTit(cAlias, cCampo, nQualIndex, cPrefixo, oModel)
Local aArea		:= GetArea()//Guarda area atual
Local cProxNum					//Proximo numero do SX8
Local lNMedTit	:= SuperGetMV("MV_NMEDTIT",.F., '1') == '2'

Default nQualIndex	:= 1
Default oModel		:= FWModelActive()

If(lNMedTit .And. (ValType(oModel) == "O" .And. oModel:GetId() == 'CNTA121') )
	cProxNum := oModel:GetValue("CNDMASTER", "CND_NUMMED")
Else
	cProxNum := GetSx8Num(cAlias, cCampo,, nQualIndex)
		
	dbSelectArea(cAlias)
	dbSetOrder(nQualIndex)
				
	While dbSeek( xFilial( cAlias ) + cPrefixo + cProxNum )
		ConfirmSX8()
		cProxNum := GetSx8Num(cAlias, cCampo,, nQualIndex)
	End
EndIf

RestArea(aArea)
Return(cProxNum)

/*/{Protheus.doc} PegaQtdCNB
Função para pegar a quantidade de itens em uma planilha de serviços, para realizar o cálculo
de valor unitário de cada serviço que será medido ( valor total previsto / quantidade de itens )

@param cFilCNB, Filial dos itens do contrato, com base na filial do contrato 
@param cContra, Número do contrato
@param cRevisa, Número da revisão do contrato
@param cPlan, Número da planilha do contrato
@Return nRet, Indica a quantidade de registros encontrados na CNB, conforme parâmetros de busca

@author pedro.alencar
@since 05/02/2019
/*/
Static Function PegaQtdCNB( cFilCNB As Char, cContra As Char, cRevisa As Char, cPlan As Char ) As Numeric
	Local nRet As Numeric
	Local cQuery As Char
	Local cAliasCNB As Char
	Local oQuery as Object
	Default cFilCNB := ""
	Default cContra := ""
	Default cRevisa := ""
	Default cPlan := ""
		
	nRet := 0	
	
	cQuery := "SELECT COUNT(CNB.R_E_C_N_O_) AS QTDE" + CRLF
	cQuery += " FROM " + RetSqlName("CNB") + " CNB "
	cQuery += " WHERE " + CRLF 
	cQuery += " CNB_FILIAL = ? AND " + CRLF
	cQuery += " CNB_CONTRA = ? AND " + CRLF
	cQuery += " CNB_REVISA = ? AND " + CRLF
	cQuery += " CNB_NUMERO = ? AND " + CRLF
	cQuery += " CNB.D_E_L_E_T_ = ? "
	
	cQuery := ChangeQuery( cQuery )

	oQuery := FWExecStatement():New(cQuery)
	oQuery:SetString(1, cFilCNB)
	oQuery:SetString(2, cContra)	
	oQuery:SetString(3, cRevisa)
	oQuery:SetString(4, cPlan)
	oQuery:SetString(5, Space(1))
	
	cAliasCNB := oQuery:OpenAlias()	
	
	If ( cAliasCNB )->( ! EOF() )
		nRet := ( cAliasCNB )->( QTDE )
	Endif
	
	If Select(cAliasCNB) > 0
		( cAliasCNB )->( dbCloseArea() )
		FErase( ( cAliasCNB ) + GetDBExtension() )
	EndIf

	FreeObj(oQuery)		
Return nRet

/*/{Protheus.doc} CNDViewCpo
	Retorna os campos da tabela CND que devem ser exibidos na view
@author philipe.pompeu
@since 13/02/2019
@return cCampos, lista de campos da CND que devem ficar visiveis na View
/*/
Static Function CNDViewCpo()
	Local aArea		 := GetArea()
	Local cCampos	 := ""
    Local cNoUsrCpos := ""
	Local nParcelas	 := SuperGetMv("MV_NUMPARC")
	Local cSeq		 := "1"
	Local nX		 := 0
	Local aTabCpos	 := {}
	
	cCampos := "CND_NUMMED|CND_CONTRA|CND_REVISA|CND_DTFIM|CND_OBS|CND_DESCCP|CND_APROV|CND_MOEDA|CND_COMPET|CND_TXMOED|CND_CONDPG"
    cNoUsrCpos := "CND_VLMPED|CND_VLBPED" //-- Campos de usuário que não devem ser exibidos - Tratamento para releases inferiores ao 12.1.31
	
	If(cPaisLoc == "RUS")
		cCampos += "|CND_MOEDES|CND_CONUNI"
	EndIf
	If !CXNParcTp9()
		for nX := 1 to nParcelas //Adiciona campos pra condicao de pagamento tipo 9
			cCampos += "|CND_PARC"+ cSeq +"|CND_DATA" + cSeq
			cSeq := Soma1(cSeq,1)
		next nX
	EndIf
	
	aTabCpos := FWSX3Util():GetAllFields("CND")
	for nX := 1 to Len(aTabCpos)
		If  FWSX3Util():GetOwner(aTabCpos[nX]) == "U" 	.And.;
			!AllTrim(aTabCpos[nX]) $ cNoUsrCpos 		.And.;
			X3USO(GetSx3Cache(aTabCpos[nX],"X3_USADO")) .And.;
			cNivel >= GetSx3Cache(aTabCpos[nX],"X3_NIVEL")

			cCampos += "|" + AllTrim(aTabCpos[nX])
		EndIf		
	next nX
	FwFreeArray(aTabCpos)
		
	cCampos += "|"//Finalizar string com '|'
	
	RestArea(aArea)
Return cCampos

/*/{Protheus.doc} CN121Parc
	Consulta especifica que permite a selecao da 
	parcela de uma competencia.
@author philipe.pompeu
@since 25/02/2019
@return lResult, se a consulta foi confirmada
/*/
Function CN121Parc()
	Local aArea	:= GetArea()
	Local lResult	:= .F.
	Local cMyAlias:= GetNextAlias()
	Local aAdvSize:= {}
	Local aInfoAdvSize:= {}
	Local aObjCoords	:= {}
	Local aObjSize	:= {}
	LOcal oFont		:= Nil
	Local oDlg			:= NIL
	Local oListResp	:= NIL
	Local aHead		:= {}
	Local nPosLinha	:= 0.00
	Local aOpcoes 	:= {}
	Local bOk		:= { ||lResult := .T., nPosLinha:=oListResp:nAt,oDlg:End()}   
	Local bCancel	:= { ||lResult := .F., oDlg:End() }
	Local oModel	:= FWModelActive()
	Local cContra	:= ""
	Local cRevisa	:= ""
	Local cCompet	:= ""
	Local cCronog	:= ""
	Local cTitulo	:= ""
	Local cPicVal	:= GetSx3Cache("CNF_VLPREV","X3_PICTURE")

	If(ValType(oModel) == 'O' .And. oModel:IsActive() .And. oModel:GetId() == "CNTA121")
		cContra := oModel:GetValue('CXNDETAIL', 'CXN_CONTRA')
		cRevisa := oModel:GetValue('CNDMASTER', 'CND_REVISA')
		cCompet := oModel:GetValue('CNDMASTER', 'CND_COMPET')
		cCronog := oModel:GetValue('CXNDETAIL', 'CXN_CRONOG')
		
		cTitulo := cContra + " | " + cCompet
		
		BeginSql alias cMyAlias
			COLUMN CNF_DTVENC As Date
			SELECT CNF_PARCEL,CNF_VLPREV, CNF_DTVENC, R_E_C_N_O_ as RECNUM
			FROM %table:CNF% CNF		
			WHERE
			CNF.%notDel% AND CNF_FILIAL = %xFilial:CNF%
			AND (CNF_SALDO > 0)					
			AND (CNF_CONTRA =  %Exp:cContra% AND CNF_REVISA =  %Exp:cRevisa%)
			AND (CNF_COMPET =  %Exp:cCompet% AND CNF_NUMERO =  %Exp:cCronog%)
			ORDER BY CNF_PARCEL
		EndSql
			
		while ( (cMyAlias)->(!Eof()) )		
			aAdd(aOpcoes,{ (cMyAlias)->CNF_PARCEL, Transform((cMyAlias)->CNF_VLPREV, cPicVal), DtoC((cMyAlias)->CNF_DTVENC), (cMyAlias)->RECNUM })
			(cMyAlias)->(dbSkip())
		End
		(cMyAlias)->(dbCloseArea())
		
		if !(Len(aOpcoes) > 0)
			aOpcoes := {{'','','',''}}
		endIf
		
		aAdd(aHead,GetSx3Cache("CNF_PARCEL"	, "X3_TITULO"))
		aAdd(aHead,GetSx3Cache("CNF_VLPREV"	, "X3_TITULO"))
		aAdd(aHead,GetSx3Cache("CNF_DTVENC"	, "X3_TITULO"))
		aAdd(aHead,"RecNo")
		
		aAdvSize := MsAdvSize( , .T., 390)
		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 15 , 5 }
		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
		aObjSize := MsObjSize( aInfoAdvSize , aObjCoords )
	
		DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD 
		DEFINE MSDIALOG oDlg FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cTitulo PIXEL
				
		@ aObjSize[1,1], aObjSize[1,2] LISTBOX oListResp FIELDS HEADER aHead[1],aHead[2],aHead[3]  SIZE 290,130 OF oDlg PIXEL;
		ON DBLCLICK ( lResult := .T., nPosLinha:=oListResp:nAt,oDlg:End() )
			
		oListResp:SetArray(aOpcoes)	
		oListResp:bLine := { || {aOpcoes[oListResp:nAt,1],aOpcoes[oListResp:nAt,2],aOpcoes[oListResp:nAt,3]}}
		
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg, bOk, bCancel))
		
		If(lResult) .And. !Empty(aOpcoes[nPosLinha,4])
			VAR_IXB := aOpcoes[nPosLinha,1]
			
			CNF->(DbGoTo(aOpcoes[nPosLinha,4]))
		Else
			VAR_IXB := ''
		EndIf
	EndIf	
	RestArea(aArea)
Return lResult

/*/{Protheus.doc} CNEstTitMd
	Rotina estorna titulo de uma medicao
Os filtros MDCONTR e FILORIG p/ considerando ambientes com tabelas do GCT compartilhadas.
@author PHILIPE.POMPEU
@since 08/03/2019
@return lResult, se o titulo foi estornado corretamente
/*/
Function CNEstTitMd(cRetPrf As Character, cNumTit As Character, cTpTit As Character, lVenda as Logical, nCndRecno As Numeric, cOrigem as Character)
	Local aAreas  := {CND->(GetArea()), GetArea()} 
	Local lResult := .T.
	Local cUmAlias	:= GetNextAlias()
	Local aTitulo 	:= {}
	Local bExecAut	:= Nil
	Local cFilBkp 	:= cFilAnt
	Local cWhere  	:= ""
	Local cTitVazio	:= ""
	Local cQuery := "" as Char
	Local oQuery as Object
	Default lVenda 	:= .T.
	Default nCndRecno	:= CND->(RecNo())	
	Default cOrigem 	:= "CNTA121"	
	
	CND->(DbGoTo(nCndRecno))	
	If(!Empty(CND->CND_FILMED))		
		cFilAnt := CND->CND_FILMED
	EndIf
	
	If(lVenda)		
		cTitVazio:= Space(TamSx3("E1_TITPAI")[1])
		bExecAut := {|x,y| FINA040(x,y)}
		
		cQuery := " SELECT E1_PREFIXO AS PREFIXO, E1_NUM AS NUMTIT, E1_TIPO AS TIPO,E1_PARCELA AS PARCELA,"
		cQuery += " E1_CLIENTE AS CLIFORN, E1_LOJA AS LOJA"
		cQuery += " FROM "+ RetSqlName("SE1") +" SE1"
		cQuery += " WHERE "
		cQuery += " SE1.E1_FILORIG = ? "
		cQuery += " AND SE1.E1_MDCONTR = ?"
		cQuery += " AND SE1.E1_MEDNUME = ?"
		cQuery += " AND SE1.E1_TITPAI = ?"
		cQuery += " AND SE1.D_E_L_E_T_ = ?"		
	Else
		cTitVazio	:= Space(TamSx3("E2_TITPAI")[1])
		bExecAut := {|x,y,z| FINA050(x,y,z)}

		cQuery := "SELECT E2_PREFIXO AS PREFIXO, E2_NUM AS NUMTIT, E2_TIPO AS TIPO, E2_PARCELA AS PARCELA,"
		cQuery += " E2_FORNECE AS CLIFORN, E2_LOJA AS LOJA"
		cQuery += " FROM "+ RetSqlName("SE2") +" SE2"
		cQuery += " WHERE SE2.E2_FILORIG = ?"
		cQuery += " AND SE2.E2_MDCONTR = ?"
		cQuery += " AND SE2.E2_MEDNUME= ?"
		cQuery += " AND SE2.E2_TITPAI = ?"
		cQuery += " AND SE2.D_E_L_E_T_ = ?"
	EndIf

	cQuery := ChangeQuery(cQuery)
	oQuery := FWExecStatement():New(cQuery)
	oQuery:SetString(1, cFilAnt)
	oQuery:SetString(2, CND->CND_CONTRA)	
	oQuery:SetString(3, CND->CND_NUMMED)
	oQuery:SetString(4, cTitVazio)
	oQuery:SetString(5, Space(1))

	cUmAlias := oQuery:OpenAlias()	
	
	While !(cUmAlias)->(EOF())
		aTitulo := {}
		
		If(lVenda)
			aAdd(aTitulo,{"E1_PREFIXO"	, (cUmAlias)->PREFIXO	, NIL})
			aAdd(aTitulo,{"E1_NUM"		, (cUmAlias)->NUMTIT	, NIL})
			aAdd(aTitulo,{"E1_TIPO"		, (cUmAlias)->TIPO		, NIL})
			aAdd(aTitulo,{"E1_ORIGEM"	, cOrigem				, NIL})
			aAdd(aTitulo,{"E1_PARCELA"	, (cUmAlias)->PARCELA	, NIL})
			aAdd(aTitulo,{"E1_FILORIG"	, cFilAnt				, NIL})
			aAdd(aTitulo,{"E1_CLIENTE"	, (cUmAlias)->CLIFORN	, NIL})
			aAdd(aTitulo,{"E1_LOJA"		, (cUmAlias)->LOJA		, NIL})		
		Else
			aAdd(aTitulo,{"E2_PREFIXO"	, (cUmAlias)->PREFIXO	, NIL})
			aAdd(aTitulo,{"E2_NUM"		, (cUmAlias)->NUMTIT	, NIL})
			aAdd(aTitulo,{"E2_TIPO"		, (cUmAlias)->TIPO		, NIL})
			aAdd(aTitulo,{"E2_ORIGEM"	, cOrigem				, NIL})
			aAdd(aTitulo,{"E2_PARCELA"	, (cUmAlias)->PARCELA	, NIL})		
			aAdd(aTitulo,{"E2_FILORIG"	, cFilAnt				, NIL})
			aAdd(aTitulo,{"E2_FORNECE"	, (cUmAlias)->CLIFORN	, NIL})
			aAdd(aTitulo,{"E2_LOJA"		, (cUmAlias)->LOJA		, NIL})
		EndIf
		
		If(lVenda)			
			MSExecAuto(bExecAut,aTitulo,5)
		Else
			MSExecAuto(bExecAut,aTitulo,,5)//Exclui títulos à pagar
		EndIf
		
		If lMsErroAuto
			If !IsBlind()
				MostraErro()
			EndIf
			lResult := .F.
			Exit
		Else
			CN120EstSld(CND->CND_NUMMED)
		Endif
		
		(cUmAlias)->(DbSkip())
	EndDo	
	(cUmAlias)->(dbCloseArea())
	cFilAnt := cFilBkp //Restaura filial
	aEval(aAreas,{|x| RestArea(x)})
	FreeObj(oQuery)
Return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121PCOLN( oModel , lDelete )
Realiza integracao com o modulo SIGAPCO.

@param	oModel			, objeto	, modelo da rotina CNTA121
		lDelete			, booleano	, informa se o lancamento deve ser estornado

@return não possui

@author		jose.delmondes
@since		02/07/2019
@version	12.1.25
/*/
//-------------------------------------------------------------------
Function CN121PCOLN( oModel , lDelete )

Local aSaveLines	:= FwSaveRows( )
Local aArea		:= GetArea( ) 
Local aAreaCND 	:= CND->( GetArea( ) )
Local aAreaCNE	:= CNE->( GetArea( ) )

Local cFilCNE	:= xFilial( 'CNE' )
Local cContrato := ''
Local cRevisao	:= ''
Local cMedicao	:= ''
Local cPlanilha	:= ''

Local nX := 0

Local oModelCND := oModel:GetModel( 'CNDMASTER' )
Local oModelCXN	:= oModel:GetModel( 'CXNDETAIL' )

cContrato	:= oModelCND:GetValue( 'CND_CONTRA' )
cRevisao	:= oModelCND:GetValue( 'CND_REVISA' )
cMedicao	:= oModelCND:GetValue( 'CND_NUMMED' )

//-- Inicia a integracao com o PCO
PcoIniLan( '000355' )

CND->( dbGoTo( oModelCND:GetDataId( ) ) ) //-- Posiociona na medicao pelo recno
PcoDetLan( '000355' , '01' , 'CNTA120' , lDelete )	//-- Lancamento: Total da medicao - inclusao

CNE->( dbSetOrder( 1 ) ) //-- CNE_FILIAL + CNE_CONTRA + CNE_REVISA + CNE_NUMERO + CNE_NUMMED + CNE_ITEM

For nX := 1 To oModelCXN:Length( )
	
	oModelCXN:GoLine( nX )
	
	If oModelCXN:GetValue( 'CXN_CHECK' ) .And. !oModelCXN:IsDeleted( )
		
		cPlanilha	:= oModelCXN:GetValue( 'CXN_NUMPLA' )
		
		If CNE->( dbSeek( cFilCNE + cContrato + cRevisao + cPlanilha + cMedicao ) )
		
			While !CNE->(EOF()) .And. cFilCNE + cContrato + cRevisao + cPlanilha + cMedicao == CNE->( CNE_FILIAL + CNE_CONTRA + CNE_REVISA + CNE_NUMERO + CNE_NUMMED )
				
				PcoDetLan( '000355' , '02' , 'CNTA120' , lDelete )	//-- Lancamento: Itens da medicao - inclusao
				CNE->( dbSkip( ) )
				
			End
		
		EndIf
	
	EndIf

Next nX

//-- Finaliza a integracao com o PCO
PcoFinLan( '000355' )

RestArea( aAreaCND )
RestArea( aAreaCNE )
RestArea( aArea )

FwRestRows( aSaveLines )

FwFreeArray( aAreaCND )
FwFreeArray( aAreaCNE )
FwFreeArray( aArea )
FwFreeArray( aSaveLines )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121PCOBQ( oModel )
Validacao de pontos de bloqueio na integracao com o modulo SIGAPCO.

@param	oModel			, objeto	, modelo da rotina CNTA121
		lDelete			, booleano	, informa se o lancamento deve ser estornado

@return lRet			, booleano	, indica se a inclusão da medicao foi bloqueada pelo PCO

@author		jose.delmondes
@since		02/07/2019
@version	12.1.25
/*/
//-------------------------------------------------------------------
Function CN121PCOBQ( oModel )
Local aAreas		:= {CND->(GetArea()), CNE->(GetArea()), CNZ->(GetArea()), GetArea()}
Local aSaveLines	:= FwSaveRows( )

Local lRet		:= .T.
Local lExclui	:= oModel:GetOperation( ) == MODEL_OPERATION_DELETE

Local nX	:= 0
Local nY	:= 0
Local nZ	:= 0
Local cSeqPcoCNZ:= "05"
Local lFixo 	:= .F.
Local lPrevFin	:= .F.
Local lEventual := .F.
Local oModelCXN	:= oModel:GetModel( 'CXNDETAIL' )
Local oModelCNE	:= oModel:GetModel( 'CNEDETAIL' )
Local oModelCNZ	:= oModel:GetModel( 'CNZDETAIL' )
Local oModelCND	:= oModel:GetModel( 'CNDMASTER' )

If !lExclui

	PcoIniLan( '000355' )

	If lEncerra
		CND->(DbGoTo(oModelCND:GetDataID()))//Garante o posicionamento na CND correta
		lRet := PcoVldLan( '000355', '03' , 'CNTA120' )	
	Else 	
		lRet := PcoVldLan( '000355', '01' , 'CNTA120' )	
	EndIf
	
	If lRet
		
		For nX := 1 To oModelCXN:Length()
			
			oModelCXN:GoLine(nX)
			
			If oModelCXN:GetValue( 'CXN_CHECK' ) .And. !oModelCXN:IsDeleted( )
				
				For nY := 1 To oModelCNE:Length()				
					oModelCNE:GoLine(nY)
					
					If !oModelCNE:IsDeleted()
						If lEncerra
							CNE->(DbGoTo(oModelCNE:GetDataID()))//Posiciona na CNE corrente p/ utilizacao no lancamento
							lRet := PcoVldLan( '000355' , "04" , 'CNTA120' )
							If lRet	
								lFixo		:= CN121RetSt('FIXO'		,,,, .T., oModel)
								lPrevFin	:= CN121RetSt("PREVFINANC"	,,,, .T., oModel)
								lEventual	:= CN121RetSt("EVENTUAL"	,,,, .T., oModel)

								If (lEventual .And. !lFixo .And. !lPrevFin)
									cSeqPcoCNZ := "05" //Encer. Medição: Rateio Itens Contrato s/ Planilha	
								Else
									cSeqPcoCNZ := "06" //Encer. Medição: Rateio Itens Contrato c/ Planilha
								EndIf

								For nZ := 1 to oModelCNZ:Length()
									oModelCNZ:GoLine(nZ)
									If !oModelCNZ:IsDeleted()
										CNZ->(DbGoTo(oModelCNZ:GetDataID()))//Posiciona na CNZ corrente.

										lRet := PcoVldLan( '000355' , cSeqPcoCNZ , 'CNTA120' )	
									EndIf

									If !lRet
										oModel:SetErrorMessage("",,"CNZDETAIL","","CN121CNZPCO",STR0196)
										Exit
									EndIf
								Next nZ
							Else
								oModel:SetErrorMessage("",,"CNEDETAIL","","CN121CNEPCO",STR0196)
							EndIf							
						Else
							lRet := PcoVldLan( '000355' , '02' , 'CNTA120' )
						EndIf
					EndIf
					
					If !lRet
						Exit
					EndIf				
				Next nY
			
			EndIf
			
			If !lRet
				Exit
			EndIf		
		Next nX
		
	ElseIf(lEncerra)
		oModel:SetErrorMessage("",,"CNDMASTER","","CN121CNDPCO",STR0196)
	EndIf
	
	PcoFinLan( '000355' , /*lForceVis*/, /*lProc*/, !lRet)
EndIf

FwRestRows( aSaveLines )
FwFreeArray( aSaveLines )

aEval(aAreas,{|x|RestArea(x)})
FwFreeArray(aAreas)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121Chave( cCodLan, cItem )
Retorna a chave que deve ser utilizada no lançamento do PCO

@param	cCodLan			, caracter	, codigo do lancamento
		cItem			, caracter	, item do lancamento

@return cChave			, caracter	, chave utilizada no lancamento

@author		jose.delmondes
@since		02/07/2019
@version	12.1.25
/*/
//-------------------------------------------------------------------
Function CN121Chave( cCodLan, cItem )
	Local cChave	:= ''

	If (cCodLan == '000355')	
		Do Case
			Case (cItem == '01')
				
				cChave := xFilial('CND') + M->CND_CONTRA + M->CND_REVISA + M->CND_NUMERO + M->CND_NUMMED

			Case (cItem == '02')
				
				If IsInCallStack('CN121PCOBQ')
					cChave := xFilial('CNE') + M->CND_CONTRA + M->CND_REVISA + FwFldGet('CXN_NUMPLA') + M->CND_NUMMED + FwFldGet('CNE_ITEM')
				Else
					cChave := xFilial('CNE') + M->CND_CONTRA + M->CND_REVISA + M->CND_NUMERO + M->CND_NUMMED + GDFieldGet('CNE_ITEM')
				EndIf
			Case (cItem == '03')//Encerramento da medição|Cabecalho CND
				
				cChave := CND->( &(IndexKey(1)) )//CND_FILIAL+CND_CONTRA+CND_REVISA+CND_NUMERO+CND_NUMMED

			Case (cItem == '04')//Encerramento da medicão|Itens CNE
				
				cChave := CNE->( &(IndexKey(1)) )//CNE_FILIAL+CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_NUMMED+CNE_ITEM

			Case (cItem == '05' .Or. cItem == '06')//Encer. Medição: Rateio Itens Contrato com ou sem planilha
				
				cChave := CNZ->( &(IndexKey(2)) ) //CNZ_FILIAL+CNZ_CONTRA+CNZ_REVISA+CNZ_NUMMED+CNZ_ITCONT+CNZ_ITEM
				
		End Case
	EndIf

Return cChave

//-------------------------------------------------------------------
/*/{Protheus.doc} CN121DtEnt
Função que valida se existe item da planilha (CNE) sem data de 
entrega informada (CNE_DTENT)
@author leonardo.magalhaes
@since 06/08/2019
/*/
//-------------------------------------------------------------------
Static Function CN121DtEnt()

	Local lRet 		:= .T.
	Local lCheck 	:= .T.
	Local lCompra   := CN121RetSt("COMPRA",,,CND->CND_CONTRA,.F.)
	
	Local cContra   := CND->CND_CONTRA
	Local cRevisa   := CND->CND_REVISA
	Local cNumMed   := CND->CND_NUMMED
	Local cAliasTmp := ""

	If lCompra

		cAliasTmp := GetNextAlias()

		BeginSQL Alias cAliasTmp 
			SELECT	1
			FROM 	%Table:CNE% CNE
			JOIN	%Table:CXN% CXN
			ON		CXN.CXN_FILIAL 		= CNE.CNE_FILIAL
					AND CXN.CXN_CONTRA 	= CNE.CNE_CONTRA
					AND CXN.CXN_REVISA 	= CNE.CNE_REVISA
					AND CXN.CXN_NUMMED 	= CNE.CNE_NUMMED
					AND CXN.CXN_NUMPLA	= CNE.CNE_NUMERO
					AND CXN.CXN_CHECK 	= %Exp:lCheck%
					AND CXN.%Notdel%
			WHERE	CNE.CNE_FILIAL		= %xFilial:CNE%
					AND CNE.CNE_CONTRA 	= %Exp:cContra%
					AND CNE.CNE_REVISA 	= %Exp:cRevisa%
					AND CNE.CNE_NUMMED 	= %Exp:cNumMed%
					AND CNE.CNE_DTENT	= '        '
					AND CNE.%NotDel%
		EndSQL

		If !(cAliasTmp)->(Eof())
			Help(" ",1,"CN121NODTENT",,STR0207, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0208}) //Existe item da(s) planilha(s) selecionada(s) sem a data de entrega informada.
			lRet := .F.
		EndIf

		(cAliasTmp)->(DbCloseArea())

	EndIf

Return lRet

/*/{Protheus.doc} CN121ItId
	Busca na CXM(agrupadores do contrato) o item referente ao produto da linha da CNE atual.
@author philipe.pompeu
@since 11/09/2019
@return cResult, caractere, valor de CXM_ITEMID
@param oModel, object, instancia de MPFormModel
@param lPosiciona, logical, se deve se posicionar na SB1 ou nao
/*/
Function CN121ItId(oModel, lPosiciona)
	Local aAreas	:= {ACV->(GetArea()), GetArea()} 
	Local cResult	:= ""
	Local cChave	:= ""
	Local cTipo		:= ""
	Local cGrupo	:= ""
	Local cCategoria:= ""
	Default oModel	:= FWModelActive()
	Default lPosiciona := .T.
	
	If(lPosiciona)
		SB1->(DbSeek(xFilial("SB1") + oModel:GetValue("CNEDETAIL", "CNE_PRODUT")))		
	EndIf
	
	ACV->(DbSetOrder(5))//ACV_FILIAL+ACV_CODPRO+ACV_CATEGO
	If(ACV->(DbSeek( xFilial("ACV") +  SB1->B1_COD )))
		cCategoria := ACV->ACV_CATEGO
	EndIf
	
	cTipo	:= SB1->B1_TIPO
	cGrupo	:= SB1->B1_GRUPO
	
	cChave := xFilial("CXM", oModel:GetValue("CNDMASTER", "CND_FILCTR"))
	cChave += oModel:GetValue("CXNDETAIL", "CXN_CONTRA")
	cChave += oModel:GetValue("CXNDETAIL", "CXN_REVISA")
	cChave += oModel:GetValue("CXNDETAIL", "CXN_NUMPLA")
	
	CXM->(dbSetOrder(1))
	If CXM->(MsSeek(cChave))	
		While CXM->(!Eof() .And. CXM_FILIAL+CXM_CONTRA+CXM_REVISA+CXM_NUMERO == cChave)			
			If CXM->( ( !Empty(CXM_AGRTIP) .And. CXM_AGRTIP == cTipo) .OR.;
			 			(!Empty(CXM_AGRGRP) .And. CXM_AGRGRP == cGrupo) .OR.;
			 			(!Empty(CXM_AGRCAT) .And. CXM_AGRCAT == cCategoria) )
				cResult := CXM->CXM_ITEMID
				Exit				
			EndIf
			CXM->(dbSkip())
		EndDo
	EndIf
	
	aEval(aAreas,{|x|RestArea(x), aSize(x,0)})
Return cResult

/*/{Protheus.doc} AtuSldCXM
	Chama a funcao UpdVlMdCXM para todos os registros da CNE carregados no
<oModelCNE>, atualizando o saldo de todos os itens.
@author philipe.pompeu
@since 11/09/2019
@return Nil, valor nulo
@param oModelCNE, object, instancia de FwFormModelGrid da tabela CNE
/*/
Function AtuSldCXM(oModelCNE)
	Local nX := 0
	Local cChaveParc := ""
	
	CXM->(DbSetOrder(1))//CXM_FILIAL+CXM_CONTRA+CXM_REVISA+CXM_NUMERO+CXM_ITEMID
	cChaveParc := xFilial("CXM")
	cChaveParc += oModelCNE:GetValue("CNE_CONTRA")
	cChaveParc += oModelCNE:GetValue("CNE_REVISA")
	cChaveParc += oModelCNE:GetValue("CNE_NUMERO")
	
	For nX := 1 to oModelCNE:Length()
		oModelCNE:GoLine(nX)		
		If (!oModelCNE:IsDeleted() .And. !Empty(oModelCNE:GetValue("CNE_ITEMGR")) .And. oModelCNE:GetValue("CNE_EXCEDE") == '2')
			UpdVlMdCXM(oModelCNE:GetValue("CNE_VLLIQD"), cChaveParc + oModelCNE:GetValue("CNE_ITEMGR"))
		EndIf
	Next nX	
Return Nil

/*/{Protheus.doc} UpdVlMdCXM
	Se encontrado o registro na CXM correspondente a <cChave>,
atualiza(subtrai ou soma, de acordo com <lEstorna>) o saldo do agrupador(CXM_VLMED)
@author philipe.pompeu
@since 11/09/2019
@return Nil, valor nulo
@param nLiquido, numerico, sera subtraido/somado ao saldo do agrupador
@param cChave, caracteres, chave a ser buscada na CXM
@param lEstorna, boleano, se deve subtrair(estornar) ou somar
/*/
Static Function UpdVlMdCXM(nLiquido, cChave, lEstorna)
	Default lEstorna := .F.
		
	If(CXM->(MsSeek(cChave)))
		RecLock("CXM" , .F.)
		If(lEstorna)
			CXM->CXM_VLMED -= nLiquido 
		Else
			CXM->CXM_VLMED += nLiquido
		EndIf
		CXM->(MsUnlock())
	EndIf		
Return Nil

/*/{Protheus.doc} EnvSldMail
	Confere se deve enviar um e-mail de aviso de acordo com o percentual consumido do saldo da planilha.
@author philipe.pompeu
@since 24/09/2019
@return Nil, Valor Nulo
/*/
Static Function EnvSldMail()
	Local cChavCXN:= ""
	Local cChavTmp:= ""
	Local cFilCTR := CND->CND_FILCTR	
	CNL->(dbSetOrder(1))//CNL_FILIAL+CNL_CODIGO
	CNA->(dbSetOrder(1))//CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO
	CXN->(DbSetOrder(1))//CXN_FILIAL+CXN_CONTRA+CXN_REVISA+CXN_NUMMED+CXN_NUMPLA+CXN_PARCEL	
	cChavCXN := xFilial("CXN", cFilCTR) + CND->(CND_CONTRA + CND_REVISA + CND_NUMMED)		
	If(CXN->(DbSeek(cChavCXN)))
		While ( CXN->(!Eof() .And.  CXN_FILIAL+CXN_CONTRA+CXN_REVISA+CXN_NUMMED == cChavCXN))//Percorre planilhas da medicao
			If(CXN->CXN_CHECK)
				If CNL->( MsSeek(xFilial("CNL",cFilCTR)+CXN->CXN_TIPPLA) .And. CNL_LMTAVS > 0 )
					cChavTmp := xFilial("CNA",cFilCTR) + CXN->(CXN_CONTRA + CXN_REVISA + CXN_NUMPLA)
					If(CNA->(MsSeek(cChavTmp)))
						cPrcSld := (CNA->CNA_SALDO*100)/CNA->CNA_VLTOT //Calcula percentual do saldo da planilha						
						If(cPrcSld <= CNL->CNL_LMTAVS)//Verifica se a planilha alcancou o limite percentual
							GCTSendMsg("040", "", STR0242, CND->({CND_NUMERO,CND_CONTRA,CND_REVISA,CNA->CNA_VLTOT,CNA->CNA_SALDO,CND_FILIAL})) //"Limite de saldo das planilhas de contrato - (SIGAGCT)"
						EndIf						
					EndIf
				EndIf		
			EndIf
			CXN->(dbSkip())
		EndDo
	EndIf
Return Nil

/*/{Protheus.doc} GetNatPV
	Obtem a natureza a ser utilizada no pedido de venda.
@author philipe.pompeu
@since 16/10/2019
@return cNat, natureza a ser utilizada no PV
@param oModel, objeto, instancia de MPFormModel
@param cCliente, caractere, codigo do cliente
@param cLoja, caractere, loja do cliente
/*/
Static Function GetNatPV(oModel, cCliente, cLoja, cNumPlan)
	Local aAreas	:= {SA1->(GetArea()), GetArea()}
	Local cNat 		:= ""
	Local cValParam := ""
	Local cChave	:= ""
	Local oModelCND := oModel:GetModel("CNDMASTER")

	cNat := GetNatCtr(oModelCND:GetValue("CND_FILCTR"), oModelCND:GetValue("CND_CONTRA"), oModelCND:GetValue("CND_REVISA"), cNumPlan)	
	
	If(Empty(cNat))		
		cChave := xFilial("SA1") + cCliente + cLoja
		SA1->(DbSetOrder(1))		
		If SA1->(DbSeek(cChave))		
			cValParam := Upper(AllTrim(SuperGetMv("MV_1DUPNAT",.F.,"")))			
			If((!Empty(cValParam) .And. "A1_NATUREZ" $ cValParam))
				cNat := SA1->( &(cValParam) ) //Macroexecuta a expressao do parametro
				If(Empty(cNat) .And. !Empty(SA1->A1_NATUREZ))
					cNat := SA1->A1_NATUREZ //Caso a expressao nao tenha retornado algo valido, obtem do cliente.
				EndIf
			EndIf			
		EndIf
	EndIf
		
	cNat := PadR(cNat, Len(SC5->C5_NATUREZ))
	
	aEval(aAreas, {|x| RestArea(x), aSize(x,0)})
Return cNat

/*/{Protheus.doc} AddEntCtb
	Dado <aParCps>, adiciona as entidades contabeis ao vetor
caso existam.
@author philipe.pompeu
@since 09/01/2020
@return Nil, nulo
@param aParCps, vetor
/*/
Static Function AddEntCtb(aParCps)
	Local nX := 0
	Local aCTBEnt := CTBEntArr()
	Local cCampoCNE := ""
	Local cCampoCNB := ""
	Local nPosCpoCNB:= 0
	
	for nX:= 1 to Len(aCTBEnt)
		cCampoCNE := "CNE_EC"+aCTBEnt[nX]
		cCampoCNB := "CNB_EC"+aCTBEnt[nX]
		nPosCpoCNB:= CNB->(FieldPos(cCampoCNB+"CR"))
		If (nPosCpoCNB > 0 .And. CNE->(FieldPos(cCampoCNE+"CR")))
			aAdd(aParCps,{cCampoCNE+"CR" ,cCampoCNB+"CR", nPosCpoCNB})			
			aAdd(aParCps,{cCampoCNE+"DB" ,cCampoCNB+"DB", CNB->(FieldPos(cCampoCNB+"DB"))})
		EndIf
	next nX
Return Nil

/*/{Protheus.doc} GetNatCtr
	Tenta obter a natureza da planilha do contrato(CNA), caso contrario
pega da natureza do contrato(CN9)
@author philipe.pompeu
@since 17/02/2020
@param cFilCtr, caractere, filial do contrato
@param cCtr, caractere, contrato
@param cRev, caractere, revisao
@param cNumPlan, caractere, planilha
@return cNat, caractere, codigo da natureza
/*/
Static Function GetNatCtr(cFilCtr, cCtr, cRev, cNumPlan)
	Local aAreas:= {CN9->(GetArea()), CNA->(GetArea())}
	Local cNat	:= ""
	Local cChave:= ""
	
	If(CNA->( ColumnPos( "CNA_NATURE" ) ) > 0)
		CNA->(DbSetOrder(1))//CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO
		cChave := xFilial("CNA", cFilCtr) + cCtr + cRev + cNumPlan		
		If(CNA->(DbSeek(cChave) .And. !Empty(CNA_NATURE)))
			cNat := CNA->CNA_NATURE //Primeira tenta obter da planilha
		EndIf
	EndIf

	If(Empty(cNat))
		CN9->(DbSetOrder(1))
		cChave := xFilial("CN9", cFilCtr) + cCtr + cRev		
		If(CN9->(DbSeek(cChave) .And. !Empty(CN9_NATURE)))
			cNat := CN9->CN9_NATURE //Depois tenta obter do contrato
		EndIf
	EndIf

	aEval(aAreas, {|x| RestArea(x), aSize(x,0)})
Return cNat

/*/{Protheus.doc} MedCondTp9
	Função retorna as parcelas a serem geradas quando a condicao de pagamento é do tipo 9.
Leva em consideração os dados da CND corrente, ou se posiciona na CND ou na CXN caso <oModel> seja informado.
@author philipe.pompeu
@since 03/03/2020
@param nTotal, numerico, total do titulo a ser gerado
@param dPadrao, data, data padrao para os titulos
@param oModel, objeto, instancia de MPFormModel
@param cTable, caracter, tabela que será utilizada
@return aResult, vetor, parcelas a serem geradas
/*/
Function MedCondTp9(nTotal as numeric, dPadrao as date, oModel as object, cTable as character) as array
	Local aArea		:= CND->(GetArea())
	Local aResult	:= {}
	Local nTotTit	:= 0
	Local nParcelas	:= SuperGetMv("MV_NUMPARC")
	Local cSeq	    := "1"
	Local nX	    := 0
	Local nValor    := 0
	Local dVenc	    := Date()
	Local cChave    := ""
	Local cPrefCpo  := ""
	Local cCpoValor := ""
	Local cCpoData  := ""
	Local nFieldPos	:= 0
	Local oModelCXN := Nil
	Default cTable  := "CND"
	Default dPadrao := Date()

	If ValType(oModel) == "O" .And. oModel:IsActive()
		If cTable == "CND"
			CND->(DbSetOrder(7))//CND_FILIAL+CND_CONTRA+CND_REVISA+CND_NUMMED		
			aEval(StrTokArr(CND->(IndexKey(IndexOrd())), "+"), {|x| cChave +=  oModel:GetValue("CNDMASTER", x)})
			CND->(DbSeek(cChave))
		Else
			oModelCXN:=oModel:GetModel("CXNDETAIL")
			If (oModelCXN:GetDataId() > 0)
				CXN->(DbGoTo(oModelCXN:GetDataId()))
			EndIf	
		EndIf	
	EndIf


	cPrefCpo  := PrefixoCpo(cTable)

	cCpoValor := cPrefCpo + "_PARC"

	cCpoData  := cPrefCpo + "_DATA"
	
	If nParcelas > 1
		nTotTit := nTotal
		For nX := 1 to nParcelas
			nFieldPos := (cTable)->( FieldPos(cCpoValor+cSeq) )			
			nValor := (cTable)->( FieldGet( nFieldPos ) )
			If nValor > 0
				If (  (nTotTit - nValor) < 0 )
					nValor := nTotTit //Nao permite gerar parcelas com valor superior ao total
				EndIf

				nFieldPos := (cTable)->( FieldPos(cCpoData+cSeq) )
				dVenc := (cTable)->( FieldGet( nFieldPos ) )
				If Empty(dVenc)
					dVenc := dPadrao
				EndIf

				aAdd(aResult,{ dVenc, nValor })
				nTotTit -= nValor //Subtrai do total
			EndIf			
			cSeq := Soma1(cSeq,1)

			If nTotTit == 0 //Caso o saldo acabe antes do total de parcelas, sai do loop.
				Exit
			EndIf
		Next nX

		If nTotTit > 0 .And. !Empty(aResult)//Verifica se sobrou algum valor
			aTail(aResult)[2] += nTotTit //Se sobrou, joga a "sobra" na parcela final
		EndIf
	EndIf

	If Empty(aResult)
		aAdd(aResult,{ dPadrao, nTotal }) //Retorna apenas um titulo com o total
	EndIf
	
	RestArea( aArea )
Return aResult

/*/{Protheus.doc} LimpCNEPed
	Limpa o campo CNE_PEDIDO dos itens da planilha 
@author philipe.pompeu
@since 23/03/2020
@param cPedido, caractere, numero do pedido a ser limpo
@return Nil, valor nulo
/*/
Static FUnction LimpCNEPed(cPedido)
	Local aAreas	:= {CXN->(GetArea()), CNE->(GetArea()), GetArea()}
	Local cKeyTmp	:= ""
	Local cKeyCNE	:= ""
	Local cLimpo	:= Space(TamSx3("CNE_PEDIDO")[1])
											
	cKeyTmp := xFilial("CXN") + CND->CND_CONTRA + CND->CND_REVISA + CND->CND_NUMMED
	CXN->(DbSetOrder(1)) //-- CXN_FILIAL+CXN_CONTRA+CXN_REVISA+CXN_NUMMED+CXN_NUMPLA
	If CXN->(DbSeek(xFilial("CXN")+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMMED))
		CNE->(DbSetOrder(1)) // CNE_FILIAL, CNE_CONTRA, CNE_REVISA, CNE_NUMERO, CNE_NUMMED, CNE_ITEM
		While CXN->(!EOF()) .And. (cKeyTmp == CXN->CXN_FILIAL+ CXN->CXN_CONTRA + CXN->CXN_REVISA + CXN->CXN_NUMMED)
			If CXN->CXN_CHECK
				cKeyCNE := xFilial("CNE") + CXN->CXN_CONTRA + CXN->CXN_REVISA + CXN->CXN_NUMPLA + CXN->CXN_NUMMED
				If CNE->( DbSeek(cKeyCNE))
					While !CNE->(Eof()) .And. cKeyCNE == (CNE->CNE_FILIAL + CNE->CNE_CONTRA + CNE->CNE_REVISA + CNE->CNE_NUMERO + CNE->CNE_NUMMED)
						If CNE->CNE_PEDIDO == cPedido
							RecLock("CNE",.F.)
							CNE->CNE_PEDIDO := cLimpo
							CNE->(MsUnlock())
						EndIf
						CNE->(DbSkip())
					EndDo
				EndIf
			EndIf
			CXN->(DbSkip())
		EndDo
	EndIf
	
	aEval(aAreas, {|x| RestArea(x), FwFreeArray(x)})
Return Nil

/*/{Protheus.doc} C121AtDocs
Função para atualizar o array aOkDocs com os títulos/pedidos gerados.
Em Pedidos de Compra/Venda também atualiza a CNE e CXJ.
@author juan.felipe
@since 09/06/2020
@param oModel, object, Modelo de dados.
@param aDocs, array, Documentos.
@param aOkDocs, array, Títulos, Documentos gerados.
@param nIndex, numeric, Índice para o documento no aDocs.
@return Nil, valor nulo.
/*/
Static Function C121AtDocs(oModel, aDocs, aOkDocs, nIndex)
	Local cDoc		:= ""
	Local cChavC7 	:= ""
	Default oModel 	:= FwModelActive()
	Default aDocs 	:= {}
	Default aOkDocs := {}
	Default nIndex 	:= 1

	If oModel <> Nil .And. oModel:GetId() == "CNTA121" .And. Len(aDocs) > 0
		If(aDocs[nIndex, 1] $ '1|2' .And. Len(aDocs[nIndex,3]) > 0) //Pedido de Compra/Venda
			cDoc 	:= Iif(aDocs[nIndex,1] == '1', SC7->C7_NUM, SC5->C5_NUM)
			cChavC7 := SC7->(C7_FILIAL + C7_NUM)

			AtuCNEPed(oModel, aDocs[nIndex,3], (aDocs[nIndex,1] == '2')) //Atualiza CNE
			C121AtuCXJ( oModel, 'CXJ_NUMPED', cDoc, aDocs[nIndex],cChavC7 ) //Atualiza CXJ

		ElseIf(aDocs[nIndex, 1] $ '3|4') //Título a Pagar/Receber
			cDoc := Iif(aDocs[nIndex,1] == '3', SE2->(E2_PREFIXO + "/" + E2_NUM + "/" + E2_PARCELA), SE1->(E1_PREFIXO + "/" + E1_NUM + "/" + E1_PARCELA))
		EndIf

		If(!Empty(cDoc))
			aAdd(aOkDocs, {aDocs[nIndex,1], cDoc})
		EndIf
	EndIf
Return Nil

/*/{Protheus.doc} C121CNxLOk
Função de pós-validação da linha do grid da CNZ ou CNE (LinhaOk)
@author leonardo.magalhaes
@since 26/06/2020
@param oModel, object, Modelo de dados.
@param aEntAd, array, Entidades contábeis adicionais.
@return lRet, logical, Linha válida (.T.) ou inválida (.F.).
/*/
Function C121CNxLOk(oModel, aEntAd, cAliasVld)
	Local lRet 	     := .T.
    Local lItemZero  := .F.
	Local oModelGrid := Nil

	Default oModel    := FwModelActive()
	Default aEntAd 	  := CTBEntArr()
	Default cAliasVld := ""

    If !FwIsInCallStack('Cn121CXNPV') .And. !FwIsInCallStack('CN121Item') //-- Não valida amarração contábil na seleção da planilha e carga dos itens
        If oModel <> Nil .And. oModel:GetId() == "CNTA121" .And. !Empty(cAliasVld)

            oModelGrid := oModel:GetModel(cAliasVld + "DETAIL")

            If cAliasVld == 'CNE' //-- Não valida amarração quando o valor total do item for zerado
                lItemZero := oModelGrid:GetValue("CNE_VLTOT") == 0
            EndIf

            If !lItemZero
                lRet := GctAmarra(	oModelGrid:GetValue(cAliasVld + "_CONTA") ,;
								 	oModelGrid:GetValue(cAliasVld + "_CC")    ,;
									oModelGrid:GetValue(cAliasVld + "_ITEMCT"),;
									oModelGrid:GetValue(cAliasVld + "_CLVL")  ,;
									cAliasVld, oModelGrid)
            EndIf
	    EndIf
    EndIf
Return lRet

/*/{Protheus.doc} LoadVendrs
	Carrega os vendedores de <oModelCNU> em <aCab> de acordo com os prefixos de <cCpoVend> e <cCpoComis>
@author philipe.pompeu
@since 14/07/2020
@param oModelCNU, FwFormModelGrid, modelo da CNU
@param aCab, array, vetor que sera enviado para o MsExecAuto
@param cCpoVend, caractere, prefixo campo vendedor
@param cCpoComis, caractere, prefixo campo comissao
@return Nil, valor nulo
/*/
Static Function LoadVendrs(oModelCNU, aCab, cCpoVend , cCpoComis)
	Local cVend	:= "1"
	Local nB	:= 0
	Local cTable:= ""
	Local aVend := {}
	Local aTemp	:= {}
	Local lItem	:= (CNU->(ColumnPos('CNU_ITEM') > 0))
	Default aCab		:= {}
	Default cCpoVend	:= ""
	Default cCpoComis	:= ""

	For nB := 1 To oModelCNU:Length()
		oModelCNU:GoLine(nB)		
		If !Empty(oModelCNU:GetValue("CNU_CODVD"))
			aTemp := {oModelCNU:GetValue("CNU_CODVD"), oModelCNU:GetValue("CNU_PERCCM")}			
			aAdd(aTemp, IIF(lItem, oModelCNU:GetValue("CNU_ITEM"), Space(1)))
			aAdd(aVend, aTemp)
		EndIf
	Next nB

	If (!Empty(aVend))
		If lItem
			aSort(aVend,,,{|x,y| aTail(x) < aTail(y) }) //Ordena pelo campo CNU_ITEM
		EndIf

		for nB := 1 to Len(aVend)
			If Empty(cTable)
				cTable := FWTabPref(cCpoVend + cVend)
			EndIf

			If (cTable)->(ColumnPos(cCpoVend + cVend) > 0 .And. ColumnPos(cCpoComis+ cVend) > 0)				
				aAdd(aCab,{cCpoVend	+ cVend, aVend[nB, 1]	,NIL})
				aAdd(aCab,{cCpoComis+ cVend, aVend[nB, 2]	,NIL})
			EndIf

			cVend := Soma1(cVend)
		Next nB

		FwFreeArray(aVend)
	EndIf
Return

/*/{Protheus.doc} C121CNRVld
	Realiza validações em comum entre as ações de CANSETVALUE e SETVALUE nos grids da CNR.
@author juan.felipe
@since 03/09/2020
@param oModel, FwFormModel, modelo ativo
@param cAction, character, ação executada CANSETVALUE ou SETVALUE
@param cField, character, campo em que se está inserindo informação
@param lPlan, logical, .T. para Planilha (CNRDETAIL1), .F. para Item (CNRDETAIL2)
@return lRet, logical, retorna .T. para prosseguir com a ação
/*/
Static Function C121CNRVld(oModel, cAction, cField, lPlan)
    Local lRet As Logical
    Local lHelp As Logical
    Local oModelCNR As Object
    Local cModelCNR As Character
    Local cMulMan As Character
    Local cTipo As Character

    Default oModel := FwModelActive()
    Default cAction := ''
    Default cField := ''
    Default lPlan := .T.

    lRet := .T.
    lHelp := cAction == 'SETVALUE' //-- Executa Helps apenas na ação SETVALUE
    cMulMan	:= Cn121RetSt('MULMAN')
    cModelCNR := IIF(lPlan, 'CNRDETAIL1', 'CNRDETAIL2')
    oModelCNR := oModel:GetModel(cModelCNR)

    If oModelCNR:GetValue('CNR_MODO') == '1' //-- Não permite alterar multa/bonificação Automática.
        If lHelp
            Help(" ",1,"CN121CNRALT",,STR0199,1,4) //-- Esta multa/bonificação não pode ser alterada pois o valor do campo Modo (CNR_TIPO) é Automático.
        EndIf
        lRet := .F.
	ElseIf cMulMan == '1' //-- Não permite multa manual
        If lHelp
            Help(" ",1,'CN121CNRMULT',,STR0201,1,4) //-- O contrato ou planilha não permite multa/bonificação.
        EndIf
        lRet := .F.
	ElseIf cField != 'CNR_TIPO'
		If 	(oModelCNR:GetValue('CNR_TIPO') == '1' .AND. !cMulMan $ '2|4') .OR. (oModelCNR:GetValue('CNR_TIPO') == '2' .AND. !cMulMan $ '3|4')
            cTipo := IIF(cMulMan == '2', STR0203, STR0204) //-- bonificação | multa
            If lHelp
                Help(" ",1,'CN121CNRMULT',,STR0202 + cTipo,1,4) //-- O contrato ou planilha não permite 
            EndIf
            lRet := .F.
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} PegaMsErro
Pega mensagem de erro gerada pelo MSExecAuto e converte para string.
Antes de chamar essa função utilizar as variáveis privadas lAutoErrNoFile e lMsHelpAuto como .T. (apenas em execuções automáticas).
@author juan.felipe
@since 02/10/2020
@return cMsgErro, character, mensagem de erro.
/*/
Static Function PegaMsErro()
    Local aErroAuto As Array
    Local cMsgErro As Character
	Local nX As Numeric

	aErroAuto := GetAutoGRLog()
    cMsgErro := ""
    
    For nX := 1 To Len(aErroAuto)
        cMsgErro += aErroAuto[nX] + CRLF  
    Next nX

    FwFreeArray(aErroAuto)
Return cMsgErro

/*/{Protheus.doc} CNMsExErro
	Possibilita a chamada da função PegaMsErro por outros fontes, como por exemplo, o CNTA260
@author philipe.pompeu
@since 15/08/2023
@return cMsgErro, character, mensagem de erro.
/*/
Function CNMsExErro()
Return PegaMsErro()

/*/{Protheus.doc} IsCtbOnline
	Verifica o pergunte <CNT120> p/ saber se deve ou não contabilizar.
@author philipe.pompeu
@since 03/12/2020
@param aLPGCT	, vetor		, será preenchido com os Lp's do GCT
@param cLancCont, caractere	, será preenchido com o código do lançamento
@param lDigita	, lógico	, será preenchido com a informação se deve ou não permitir digitação
@param lAglutina, lógico	, informará se é executada a aglutinação
@return lCtbOnLine, logico, se deve ou não contabilizar
/*/
Static Function IsCtbOnline(aLPGCT, cLancCont, lDigita, lAglutina) as Logical
	Local lCtbOnLine := .F.
	Local nI := 0
	Default aLPGCT 		:= {}
	Default cLancCont 	:= ""

	aLPGCT	:= {{"697",VerPadrao("697")},; //LP Gestão de Contratos - Encerramento da Medição
				{"698",VerPadrao("698")},; //LP Gestão de Contratos - Encerramento da Medição/Automatico
				{"699",VerPadrao("699")},; //LP Gestão de Contratos - Encer. Medicao: Itens do Contrato
				{"69A",VerPadrao("69A")},; //LP Gestão de Contratos - Est. Medicao: Itens do Contrato
				{"69B",VerPadrao("69B")},; //LP Gestão de Contratos - Incl. Rateio Itens Contrato s/ Planilha
				{"69C",VerPadrao("69C")},; //LP Gestão de Contratos - Excl. Rateio Itens Contrato s/ Planilha
				{"69D",VerPadrao("69D")},; //LP Gestão de Contratos - Incl. Rateio Itens Contrato c/ Planilha
				{"69E",VerPadrao("69E")},;
				{"69F",VerPadrao("69F")},; //LP Gestão de Contratos - Excl. Rateio Itens Contrato c/ Planilha
				{"69H",VerPadrao("69H")},; //LP Gestão de Contratos - Encerramento da medição por item norma IFRS 15 (bens e serviços)
				{"69I",VerPadrao("69I")}; //LP Gestão de Contratos - Estorno da medição por item norma IFRS 15 (bens e serviços)
				}

	Pergunte("CNT120",.F.)	//carrega as variaveis
	If Type("cOrigem") == "C"
		cLancCont:= IIF(ALLTRIM(cOrigem) == "CNTA121",cLancCont:= "697",cLancCont:= "698")
		If cOrigem == "CNTA260"
			If ((MV_PAR01 == 1 .And. MV_PAR02 == 1) .And. GetRemoteType() != -1 )
	   			Pergunte("CNT120",.T.)
			Else
				MV_PAR01 := 1
				MV_PAR02 := 2
				MV_PAR03 := 2
			EndIf	   	
		EndIf
	Else
		cLancCont:= "697"
	EndIf

	If (lCtbOnLine := IIf(ValType(MV_PAR01)=="N",MV_PAR01 == 1,.F.)) //SE CONTABILIZA, atraves da escolha do usuario
		//Percorre os lancamentos contabeis do GCT, se algum deles existir, a contabilizacao podera ter continuidade
		For nI := 1 to len(aLPGCT)
			If aLPGCT[nI,2]
				lCtbOnline := .T.
				Exit
			Else
				lCtbOnline := .F.
			Endif
		Next nI

		If lCtbOnLine
			lDigita		:= IIF(VAlTYPE(MV_PAR02)=="N",MV_PAR02 == 1,.F.)
			lAglutina	:= IIF(VAlTYPE(MV_PAR03)=="N",MV_PAR03 == 1,.F.)		
		EndIf
	Endif

Return lCtbOnLine

/*/{Protheus.doc} VldCXNEnc
	Confere se existe saldo disponivel nas planilhas do contratos(CNA) vinculadas as planilhas da medição(CXN)
@author philipe.pompeu
@since 03/12/2020
@return lRet, logico, verdadeiro caso exista saldo
/*/
Static Function VldCXNEnc() as Logical
	Local aAreas	:= {CXN->(GetArea()), CNA->(GetArea()), GetArea()}
	Local cChaveCXN :=  ""
	Local lRet := .T.
	Local cFilCXN		:= xFilial("CXN")
	Local cFilCNA		:= xFilial("CNA", CND->CND_FILCTR)
	Local lCN121VMP := .F.
	Local lFixo 
	Local lValor
	Local lPeVdSld 		:= ExistBlock("CN121VDS")
	Local nValExced := 0
	Local cCronog := ""
	Local lSldFlex := .T.
	Local nTamVlTot	:= TamSX3("CND_VLTOT")[2]

	cChaveCXN := cFilCXN+CND->(CND_CONTRA+CND_REVISA+CND_NUMMED)
	DbSelectArea("CXN")
	CXN->(DbSetOrder(1))
	CXN->(MsSeek(cChaveCXN))

	While !CXN->(EOF()) .And. cChaveCXN == CXN->(CXN_FILIAL+CXN_CONTRA+CXN_REVISA+CXN_NUMMED)
		If !CXN->CXN_CHECK
			CXN->(DbSkip())
			Loop
		EndIf

		lFixo	:= CN121RetSt( "FIXO"	   , 0, CXN->CXN_NUMPLA, CXN->CXN_CONTRA, .F. )

		//- Ponto de entrada permite ou não validar o saldo do contrato do tipo flexível com o valor da medição a ser encerrada
		If lPeVdSld
			lSldFlex := ExecBlock("CN121VDS",.F.,.F.)
		EndIf

		If !lFixo .And. lSldFlex
			lValor	:= CN121RetSt( "PREVFINANC", 0, CXN->CXN_NUMPLA, CXN->CXN_CONTRA, .F. )

			//Valor total dos itens excedentes da planilha
			nValExced := CN120VlExc(CND->CND_CONTRA,CND->CND_REVISA,CND->CND_NUMMED,CXN->CXN_NUMPLA)

			cCronog := Posicione("CNA",1,cFilCNA+CND->(CND_CONTRA+CND_REVISA)+CXN->CXN_NUMPLA,"CNA_CRONOG")

			If lValor .And. CNA->CNA_SALDO < xMoeda(CXN->CXN_VLLIQD - nValExced ,CND->CND_MOEDA,CN9->CN9_MOEDA,dDataBase,nTamVlTot)
				If (CND->CND_SERVIC=="2")
					Aviso("CNTA121",STR0096,{STR0156})//"Não foi possível encerrar a medição. O saldo do contrato nao equivale ao valor da medicao."
				Else
					Aviso("CNTA121",STR0097,{STR0156})//"Não foi possível gerar o pedido. O saldo do contrato nao equivale ao valor da medicao."
				EndIf
				lRet := .F.
			EndIf
		EndIf
		CXN->(DbSkip())
	EndDo
	//- Executa ponto de entrada após validação do valor previsto com realizado
	If ExistBlock("CN121VMP")
		lCN121VMP := ExecBlock("CN121VMP",.F.,.F.,{lRet})
		If ValType(lCN121VMP) == "L"
			lRet := lCN121VMP
		EndIf
	EndIf

 aEval(aAreas, {|x| RestArea(x) })
 FwFreeArray(aAreas)
Return lRet

/*/{Protheus.doc} UpdSldCNB
	Atualiza o saldo do registro corrente da CNB(item da planilha do contrato) com base no
registro corrente da CNE(item da planilha da medição).
@author philipe.pompeu
@since 03/12/2020
@param lRecorre, logico, se é uma planilha recorrente
@param lServico, logico, se é uma planilha de servico
@param lSemiFix, logico, se é uma planilha semi-fixa
/*/
Static Function UpdSldCNB(lRecorre, lServico, lSemiFix, lEstorno)
	Local cChavCNA	:= ""
	Local aArea		:= {}
	Local nVlQtdMed := 0
	Local nVlSldMed := 0
	Local lHasFrete := HasCpoFrete()
	Default lEstorno:= .F.

	RecLock("CNB",.F.)

	If lRecorre //-- Se for recorrente
		If (CNB->CNB_PARPRO > 0)//é pro-rata			
			If lEstorno
				If !Empty(CNB->CNB_PRIMED)
					aArea := CNA->(GetArea())
					CNA->(dbSetOrder(1))//CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO
					cChavCNA := xFilial("CNA", CND->CND_FILCTR) + CNE->(CNE_CONTRA+CNE_REVISA+CNE_NUMERO)
					If CNA->( MsSeek(cChavCNA) )					
						If 	(CNA->CNA_MEDEFE == 0 .And. CNA->CNA_PROPAR	== CXN->CXN_PARCEL) .Or.;//CNA ja tenha sido atualizada via <UpdSldCNA>
							(CNA->CNA_MEDEFE == 1 .And. CNA->CNA_PROPAR	!= CXN->CXN_PARCEL)//CNA ainda nao foi atualizada...						
							CNB->CNB_PRIMED := Ctod("")
						EndIf					
					EndIf

					RestArea(aArea)
					FwFreeArray(aArea)
				EndIf
			ElseIf(Empty(CNB->CNB_PRIMED))
				CNB->CNB_PRIMED := CND->CND_DTINIC			
			EndIf
		Endif
	Else//Nao recorrente
		If CND->(AllTrim(CND_SERVIC) == "1")
			nVlQtdMed := CNE->CNE_QUANT
			nVlSldMed := CNE->CNE_QUANT
		Else
			nVlQtdMed := ( ( CNE->CNE_VLTOT / CNB->CNB_VLTOT ) * CNB->CNB_QUANT )
			nVlSldMed := nVlQtdMed
		EndIf

		If lSemiFix
			nVlSldMed := 0 //- Somente atualiza se não semifixo	
		EndIf

		If lEstorno
			CNB->CNB_QTDMED -= nVlQtdMed
			CNB->CNB_SLDMED += nVlSldMed
			If lHasFrete
				CNB->CNB_SLDFRT += CNE->CNE_FRETE
				CNB->CNB_SLDDSP += CNE->CNE_DESPES
				CNB->CNB_SLDSEG += CNE->CNE_SEGURO
			Endif	
		Else
			CNB->CNB_QTDMED += nVlQtdMed
			CNB->CNB_SLDMED -= nVlSldMed
			If lHasFrete
				CNB->CNB_SLDFRT -= CNE->CNE_FRETE
				CNB->CNB_SLDDSP -= CNE->CNE_DESPES
				CNB->CNB_SLDSEG -= CNE->CNE_SEGURO
			Endif	
		EndIf
	EndIf

	MsUnlock()		
Return

/*/{Protheus.doc} UpdSldCNS
	Atualiza o saldo do cronograma fisico(CNS) com base na medição posicionada(CND e CNE).
@author philipe.pompeu
@since 03/12/2020
@param cFilCNS, caractere, xFilial da CNS
@param cCronog, caractere, cronograma da planilha corrente
@param cParcel, caractere, parcela da planilha corrente
/*/
Static Function UpdSldCNS(cFilCNS, cCronog, cParcel, lEstorno)
	Default lEstorno := .F.
	dbSelectArea("CNS")
	CNS->(dbSetOrder(1))
	If CNS->(dbSeek(cFilCNS+CND->(CND_CONTRA+CND_REVISA)+cCronog+cParcel+CNE->CNE_ITEM))
		RecLock("CNS",.F.)
		If lEstorno			
			CNS->CNS_RLZQTD -= CNE->CNE_QUANT
			CNS->CNS_SLDQTD += CNE->CNE_QUANT
		Else
			CNS->CNS_RLZQTD += CNE->CNE_QUANT
			CNS->CNS_SLDQTD -= CNE->CNE_QUANT
		EndIf
		MsUnlock()
	EndIf
Return

/*/{Protheus.doc} UpdSldCNA
	Atualiza o saldo da planilha do contrato(CNA) posicionada com base nos valores da medição(CND) corrente
@author philipe.pompeu
@since 03/12/2020
@param lRecorre	, lógico	, se a planilha é recorrente
@param lFixo	, lógico	, se a planilha é fixa
@param lSemiFix	, lógico	, se a planilha é semifixa
@param lPrevFin	, lógico	, se a planilha tem previsao financeira
@param nValExced, numérico	, valor total dos itens excedentes da planilha
@param nTamVlTot, numérico	, casas decimais do campo CND_VLTOT
@param nTxDestino	, numérico	, taxa da moeda destino(do contrato)
/*/
Static Function UpdSldCNA(lRecorre, lFixo, lSemiFix, lPrevFin, nValExced, nTamVlTot, nTxDestino, lEstorno)
	Local cProxParce	:= ""
	Local dDataProMed as Date
	Local lUpdSaldo	as Logical
	Default lEstorno:= FwIsInCallStack('CN121MedEst')

	lUpdSaldo := !lRecorre .And. (lFixo .Or. lSemiFix .Or. lPrevFin)

	RecLock("CNA",.F.)

	If lUpdSaldo //Atualiza saldo da planilha se nao recorrente	e for fixo/semifixo ou tiver previsao financeira
		If lEstorno//Devolve saldo(estorno)
			CNA->CNA_SALDO += xMoeda(CXN->CXN_VLLIQD - nValExced , CND->CND_MOEDA,CN9->CN9_MOEDA, CND->CND_DTINIC,nTamVlTot,,nTxDestino)
		Else//Consome saldo(Encerramento)
			CNA->CNA_SALDO -= xMoeda(CXN->CXN_VLLIQD - nValExced , CND->CND_MOEDA,CN9->CN9_MOEDA, CND->CND_DTINIC,nTamVlTot,,nTxDestino)
		EndIf
	EndIf

	If lRecorre
		If lEstorno
			CNA->CNA_MEDEFE := CNA->CNA_MEDEFE - 1
			CNA->CNA_PROMED := CNA->CNA_ULTMED
			CNA->CNA_ULTMED := CND->CND_ULTMED
			CNA->CNA_RECMED := CND->CND_RECMED
			CNA->CNA_PROPAR	:= CXN->CXN_PARCEL
		Else
			CNA->CNA_MEDEFE := CNA->CNA_MEDEFE + 1
			cProxParce	:= CNA->CNA_PROPAR

			If TamSx3("CNA_PROPAR")[1] = 1 .And. cProxParce == "Z"
				cProxParce := "a"
			Else
				cProxParce 	:= Soma1(cProxParce)
			Endif
			CNA->CNA_PROPAR := cProxParce
			CNA->CNA_ULTMED := CNA->CNA_PROMED
			CNA->CNA_RECMED := CND->CND_NUMMED
			dDataProMed 	:= CN300RetMed(CNA->CNA_PERIOD,CNA->CNA_PROMED,CNA->CNA_DIAMES,CNA->CNA_DIASEM,CNA->CNA_PERREC)
			CNA->CNA_PROMED := dDataProMed
		EndIf	
	EndIf

	MsUnlock()
Return

/*/{Protheus.doc} UpdSldCN9
	Atualiza o saldo do contrato(CN9) posicionado com base nos valores da medição(CND) corrente
@author philipe.pompeu
@since 03/12/2020
@param lFixo	, lógico	, se a planilha é fixa
@param lSemiFix	, lógico	, se a planilha é semifixa
@param lValor	, lógico	, se a planilha tem previsao financeira
@param nValExced, numérico	, valor total dos itens excedentes da planilha
@param nTamVlTot, numérico	, casas decimais do campo CND_VLTOT
@param nTxDestino	, numérico	, taxa da moeda de destino(moeda do contrato)
@param lRecorre	, lógico	, se a planilha é recorrente
@param lEstorno	, lógico	, se é um estorno
/*/
Static Function UpdSldCN9(lFixo, lSemiFix, lValor, nValExced, nTamVlTot, nTxDestino, lRecorre, lEstorno)
	Local nRealizado := 0
	Default lEstorno:= FwIsInCallStack('CN121MedEst')

	nRealizado := xMoeda(CXN->CXN_VLLIQD - nValExced,CND->CND_MOEDA,CN9->CN9_MOEDA,CND->CND_DTINIC,nTamVlTot,,nTxDestino)
	RecLock("CN9",.F.)
	if (!lEstorno)//Consome saldo(encerramento)
		If lFixo .Or. lSemiFix .Or. lValor
			CN9->CN9_SALDO -= nRealizado
		Else
			CN9->CN9_VLATU += nRealizado//Atualiza valor do contrato
			If Empty(CN9->CN9_REVISA)//Se contrato original atualiza valor inicial
				CN9->CN9_VLINI += nRealizado
			EndIf
		EndIf
	Else//Devolve saldo(estorno)
		If ( (lFixo .Or. lSemiFix) .And. !lRecorre) .Or. (lValor .And. !lRecorre)
			CN9->CN9_SALDO += nRealizado
		ElseIf !lRecorre
			CN9->CN9_VLATU -= nRealizado//Atualiza valor do contrato
			If Empty(CN9->CN9_REVISA)//Se contrato original atualiza valor inicial
				CN9->CN9_VLINI -= nRealizado
			EndIf
		EndIf
	EndIf
	MsUnlock()
Return

/*/{Protheus.doc} PutDespesa
	Preenche os campos de despesa e desconto no cabeçalho do pedido
@author philipe.pompeu
@since 04/01/2021
@param aCab, array, cabeçalho do pedido
@param cTipo, caractere, tipo(1=compras, 2=vendas)
@param aMultBoni, array, valores de multas e bonificações
/*/
Static Function PutDespesa(aCab as array, cTipo as character, aMultBoni as array)
	Local lCompras	:= (cTipo == '1') //1=Compras, 2=Venda
	Local nDespesa	:= 0
	Local nDescont	:= 0
	Local nPos		:= 0
	Local cDesconto	:= ""
	Local cDespesa	:= ""
	Default aMultBoni := {0, 0} //1=Multa;2=Bonificaçao
	
	If !(Empty(aMultBoni[1]) .And. Empty(aMultBoni[2]))

		If lCompras
			nDespesa := aMultBoni[2]
			nDescont := aMultBoni[1]
			cDespesa := "C7_DESPESA"
			cDesconto:= "C7_VLDESC"
		Else
			nDespesa := aMultBoni[1]
			nDescont := aMultBoni[2]
			cDespesa := "C5_DESPESA"
			cDesconto:= "C5_DESCONT"
		EndIf

		If nDescont > 0			
			nPos := aScan(aCab, {|x|x[1] == cDesconto})
			If nPos == 0
				aAdd( aCab , { cDesconto , 0, NIL } )
				nPos := Len(aCab)
			EndIf
			aCab[nPos, 2] := A410Arred(nDescont, cDesconto)
		EndIf
		
		If nDespesa > 0			
			nPos := aScan(aCab, {|x|x[1] == cDespesa})
			If nPos == 0
				aAdd( aCab , { cDespesa , 0, NIL } )
				nPos := Len(aCab)
			EndIf
			aCab[nPos, 2] := A410Arred(nDespesa, cDespesa)
		EndIf
		
	EndIf
Return

/*/{Protheus.doc} CN121OldMd
	Chama as funcoes de exibicao/alteracao, estorno e impressao para medicoes feitas pelo CNTA120(legado)
@author philipe.pompeu
@since 08/01/2021
@param nOpc, numerico, numero da opcao a ser executada
/*/
Function CN121OldMd(nOpc)	
	Default nOpc := 2
Return CNTA120(nOpc)

/*/{Protheus.doc} CNTA120
	Função estática nomeada <CNTA120> p/ que o sistema entenda que a chamada ocorre através da rotina legada.
Dessa forma, todos os trechos que verificam a pilha de chamada, vão entender que se trata de uma chamada do CNTA120.
@author philipe.pompeu
@since 22/03/2022
@param nOpc, numerico, numero da opcao a ser executada
/*/
Static Function CNTA120(nOpc)
	Local xResult := nil	
	Private cCadastro 	:= STR0001 //Medição
	Private aRotina 	:= CNT120Menu()

	If(nOpc == 2)
		xResult := CND->( CN130Manut(Alias(), RecNo(), nOpc,Nil, CND_CONTRA, CND_REVISA,, CND_NUMERO) )
	ElseIf(nOpc > 0)
		xResult := CND->( CN120Manut(Alias(), RecNo(), nOpc) )		
	ElseIf (nOpc == -1)
		xResult := CND->( CN120Estor(Alias(), RecNo(), 2) )//Estorno
	ElseIf (nOpc == -2)
		xResult := CND->( CN120ExceM(Alias(), RecNo(), 2) )//Excedente p/ medicao encerrada
	ElseIf (nOpc == -3)
		CND->( CN120Impr(Alias(), RecNo()) )//Chama impressão CNTA120
	EndIf	

	FwFreeArray(aRotina)
Return xResult

/*/{Protheus.doc} UpdSaldos
	Chama as funcoes de exibicao/alteracao, estorno e impressao para medicoes feitas pelo CNTA120(legado)
@author philipe.pompeu
@since 03/02/2021
@param nReg, numerico, numero da opcao a ser executada
@param lEstorno, logico, se é uma estorno
/*/
Static Function UpdSaldos(nReg, lEstorno)
	Local aAreas      	:= {CN9->(GetArea()), CNA->(GetArea()), CNB->(GetArea()), CXN->(GetArea()), CNF->(GetArea()), CNS->(GetArea()), CXM->(GetArea()), GetArea()}
	Local oBkpModel		:= FwModelActive()
	Local cFilCtr  		:= ""
	Local cCronog		:= ""
	Local cParcel		:= ""
	Local cEspCtr  		:= ""
	Local cChave   		:= ""
	Local cFilCXN		:= xFilial("CXN")
	Local cFilCNE		:= xFilial("CNE")
	Local cFilCN9  		:= ""
	Local cFilCNA  		:= ""
	Local cFilCNB  		:= ""
	Local cFilCNF		:= ""
	Local cFilCNS		:= ""
	Local cFilCNV		:= ""
	Local cChaveCXN		:= ""
	Local nMedLmt   	:= 0 //Limite de medicao do contrato	
	Local nTaxa			:= 0
	Local nTamVlTot		:= TamSX3("CND_VLTOT")[2]
	Local nValExced		:= 0
	Local lRet			:= .T.
	Local lMedEve   	:= .F.
	Local lFscLmt   	:= .F.
	Local lContab   	:= .F.
	Local lFixo     	:= .T.
	Local lSemiFix		:= .T.
	Local lValor    	:= .T.
	Local lFisico   	:= .F.
	Local lRecorre 		:= .F.
	Local lPlanComItem	:= .F.
	Local lCXNZero 		:= CXN->(ColumnPos('CXN_ZERO')) > 0
	Local lServico 		:= .F.	
	Local lTitProv		:= GetNewPar("MV_CNPROVI","S") == "S"

	dbSelectArea("CND")
	CND->(MsGoTo(nReg)) //-- Posiciona na medicao

	cFilCtr := CND->CND_FILCTR
	cFilCN9 := FWxFilial( "CN9", cFilCTR )
	cFilCNA := FWxFilial( "CNA", cFilCTR )
	cFilCNB := FWxFilial( "CNB", cFilCTR )
	cFilCNF := FWxFilial( "CNF", cFilCTR )
	cFilCNS := FWxFilial( "CNS", cFilCTR )
	cFilCNV := FWxFilial( "CNV", cFilCTR )
	cFilCXM	:= FWxFilial( "CXM", cFilCTR)
	CXM->(DbSetOrder(1))//CXM_FILIAL+CXM_CONTRA+CXM_REVISA+CXM_NUMERO+CXM_ITEMID

	cChave := CND->(CND_CONTRA+CND_REVISA+CND_NUMMED)

	dbSelectArea("CN9")
	CN9->(dbSetOrder(1))
	CN9->(MsSeek(cFilCN9+CND->(CND_CONTRA+CND_REVISA)))

	cEspCtr := CN9->CN9_ESPCTR
	If (cEspCtr == '2' .And. lExced .And. lEstorno)
		If OnlyExced()
			Return
		EndIf
	EndIf

	Begin Transaction

		cChaveCXN := cFilCXN+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMMED
		DbSelectArea("CXN")
		CXN->(DbSetOrder(1))
		CXN->(MsSeek(cFilCXN+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMMED))
		While cChaveCXN == CXN->(CXN_FILIAL+CXN_CONTRA+CXN_REVISA+CXN_NUMMED) .And. !(CXN->(Eof())) .And. lRet
			If !(CXN->CXN_CHECK) .Or. (lCXNZero .And. CXN->CXN_ZERO == '1')
				CXN->(DbSkip())
				Loop
			EndIf
			
			lMedEve	:= CN121RetSt("MEDEVE"		,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.F.,,CND->CND_FILCTR)
			lContab	:= CN121RetSt("CONTABIL"	,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.F.,,CND->CND_FILCTR)
			lFixo	:= CN121RetSt("FIXO"		,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.F.,,CND->CND_FILCTR)
			lSemiFix:= CN121RetSt("SEMIFIXO"	,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.F.,,CND->CND_FILCTR)
			lValor	:= CN121RetSt("PREVFINANC"	,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.F.,,CND->CND_FILCTR)
			lFisico	:= CN121RetSt("FISICO"		,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.F.,,CND->CND_FILCTR)
			nMedLmt	:= CN121RetSt("LMTMED"		,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.F.,,CND->CND_FILCTR)
			lFscLmt	:= CN121RetSt("LMTFISICO"	,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.F.,,CND->CND_FILCTR)
			lRecorre:= CN121RetSt("RECORRENTE"	,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.F.,,CND->CND_FILCTR)			
			lServico:= CN121RetSt('SERVIÇO'		,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA,.F.,,CND->CND_FILCTR)
			cParcel := CXN->CXN_PARCEL			

			If !lRecorre
				DbSelectArea("CN9")
				CN9->(dbSetorder(1))
				If CN9->(MsSeek(cFilCN9+CND->CND_CONTRA+CND->CND_REVISA))
					UpdSldCN9(lFixo, lSemiFix, lValor, nValExced, nTamVlTot, nTaxa, lRecorre, lEstorno)//-- Atualiza saldo do contrato se nao recorrente
				EndIf				
			EndIf		

			CNA->(dbSetOrder(1))
			If CNA->(MsSeek(xFilial("CNA",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA+CXN->CXN_NUMPLA))
				cCronog := CNA->CNA_CRONOG
				
				DbSelectArea("CNE")
				CNE->(dbSetOrder(1))
				CNE->(MsSeek(cFilCNE+CND->(CND_CONTRA+CND_REVISA)+CXN->CXN_NUMPLA+CND->CND_NUMMED))
				While CNE->(CNE_FILIAL+CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_NUMMED) == cFilCNE+CND->(CND_CONTRA+CND_REVISA)+CXN->CXN_NUMPLA+CND->CND_NUMMED					
					If (CNE->CNE_EXCEDE <> '1')
						CNB->(dbSetOrder(1))
						lPlanComItem := CNB->(MsSeek(cFilCNB+CNE->(CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_ITEM)))//CAPTURO A VARIAVEL FLAG DE ITENS COM PLANILHA
						If (lPlanComItem)
							UpdSldCNB(lRecorre, lServico, lSemiFix, lEstorno)/*Atualiza o item da planilha(CNB) do contrato*/
						EndIf
						If lFisico
							UpdSldCNS(cFilCNS, cCronog, cParcel, lEstorno)/*Atualiza saldo do cronograma fisico(CNS)*/
						EndIf
						
						If(!Empty(CNE->CNE_ITEMGR))//Se tiver agrupador, atualiza seu saldo.									
							UpdVlMdCXM(CNE->CNE_VLLIQD, cFilCXM + CNE->(CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_ITEMGR), lEstorno)
						EndIf
					EndIf
					CNE->(dbSkip())
				EndDo

				If !lEstorno .And. (lRecorre .And. CNA->CNA_MEDEFE > 0) //-- atualiza campos de controle dos contratos recorrentes no encerramento
					RecLock("CND",.F.)
					CND->CND_RECMED := CNA->CNA_RECMED
					CND->CND_ULTMED := CNA->CNA_ULTMED
					MsUnlock()
				EndIf
				
				UpdSldCNA(lRecorre, lFixo, lSemiFix, lValor, nValExced, nTamVlTot, nTaxa, lEstorno)
				If !lMedeve .And. !lRecorre
					UpdSldCNF(cCronog, nValExced, nTamVlTot, lEstorno, lTitProv, lServico)					
				EndIf

				If lRecorre .And. lTitProv
					TitProvRec(, lEstorno)//-- Exclui titulo provisorio da parcela atual
				EndIf
			EndIf

			CXN->(DbSkip())
		EndDo

		If !lRet
			DisarmTransaction()
		EndIf	
	End Transaction

	FwModelActive(oBkpModel)//Restaura modelo ativo no inicio do processamento...
	aEval(aAreas, {|x| RestArea(x) })
	FwFreeArray(aAreas)
Return

/*/{Protheus.doc} UpdSldCNF
	Atualiza o saldo do da parcela(CNF) do cronograma financeiro
@author philipe.pompeu
@since 03/02/2021
@param cCronog	, caractere	, cronograma da planilha
@param lValor	, lógico	, se a planilha tem previsao financeira
@param nValExced, numérico	, valor total dos itens excedentes da planilha
@param nTamVlTot, numérico	, casas decimais do campo CND_VLTOT
@param lEstorno	, lógico	, se é um estorno
@param lServico	, lógico	, se é uma planilha de serviço
/*/
Static Function UpdSldCNF(cCronog, nValExced, nTamVlTot, lEstorno, lTitProv, lServico)
	Local cParcel 	:= ""	
	Local nSaldo  	:= 0
	Local nRealizado:= 0
	Local cFilCtr 	:= CND->CND_FILCTR
	Local dDtReal	:= CtoD("//")
	Default nValExced	:= 0
	Default nTamVlTot	:= GetSx3Cache('CND_VLTOT','X3_TAMANHO')	
	Default lTitProv	:= GetNewPar("MV_CNPROVI","S") == "S"
	Default lServico	:= .F.

	If !Empty(CXN->CXN_PARCEL)
        CNF->(dbSetorder(3)) //-- CNF_FILIAL+CNF_CONTRA+CNF_REVISA+CNF_NUMERO+CNF_PARCEL
        CNF->(dbSeek(xFilial("CNF",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA+cCronog+CXN->CXN_PARCEL))
    Else
        CNF->(dbSetorder(2)) //-- CNF_FILIAL+CNF_CONTRA+CNF_REVISA+CNF_NUMERO+CNF_COMPET
        CNF->(dbSeek(xFilial("CNF",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA+cCronog+CND->CND_COMPET))
    EndIf

	If CNF->(Found())
		nRealizado := xMoeda(CXN->CXN_VLLIQD - nValExced ,CND->CND_MOEDA,CN9->CN9_MOEDA,CND->CND_DTINIC,nTamVlTot)			
		RecLock("CNF")
		If lEstorno			
			CNF->CNF_VLREAL -= nRealizado
			CNF->CNF_SALDO  += nRealizado
			
			If (CNF->CNF_VLREAL > 0)
				dDtReal := UltMedCNF()//Obtem a data de encerramento da última medição a ter consumido o saldo da parcela(cnf) atual				
			EndIf

			CNF->CNF_DTREAL := dDtReal			
		Else
			CNF->CNF_VLREAL += nRealizado
			CNF->CNF_SALDO  -= nRealizado
			CNF->CNF_DTREAL := dDataBase
		EndIf
		MsUnlock()

		If lTitProv//- ajusta os títulos provisórios
			If !(FwIsInCallStack('UpdSaldos'))
				IncProc( STR0099 )//"Processando títulos provisórios"				
			EndIf

			If lEstorno
				cParcel := CNF->CNF_PARCEL
				
				CN100ETit(CND->CND_CONTRA,CND->CND_REVISA,cCronog,CNF->CNF_PARCEL,cFilCtr)//- Exclui título provisório gerado no encerramento da medição				
				
				If CNF->CNF_SALDO > 0
					CN100CTit(CND->CND_CONTRA,CND->CND_REVISA,cCronog,CNF->CNF_PARCEL,CNF->CNF_SALDO,cFilCtr)//- Inclui título provisório do saldo atualizado da parcela
				EndIf
			Else

				CN100ETit(CND->CND_CONTRA,CND->CND_REVISA,cCronog,CNF->CNF_PARCEL,cFilCtr)
				
				If(FwIsInCallStack("CN300REVPD"))
					nSaldo := CNF->CNF_VLPREV - CND->CND_VLTOT
				Else
					nSaldo := CNF->CNF_SALDO
				EndIf

				If (nSaldo  > 0 .And. !lServico)
					CN100CTit(CND->CND_CONTRA,CND->CND_REVISA,cCronog,CNF->CNF_PARCEL,CNF->CNF_SALDO,cFilCtr)
				EndIf
			Endif
		EndIf
	EndIf
Return

/*/{Protheus.doc} TitProvRec
	Deleta/Inclui os provisorios de contratos Recorrentes
@author philipe.pompeu
@since 09/02/2021
@param lCriaProv, lógico, deve ou nao provisionar contratos recorrentes
@param lEstorno, lógico, se é um estorno de medição ou não
/*/
Static Function TitProvRec(lCriaProv, lEstorno)
	Default lCriaProv 	:= AllTrim(SuperGetMV("MV_CNTPPP" ,.F.,"0")) $ "0/1"  // define quando os contratos recorrentes serão provisionados
	Default lEstorno	:= .F.

	If lEstorno		
		If lCriaProv// exclui a última parcela provisória se o parâmetro MV_CNTPPP é 0 ou 1
			CN100ETit(CND->CND_CONTRA,CND->CND_REVISA,"RECORRENTE",CXN->CXN_PARCEL, CND->CND_FILCTR, CXN->CXN_NUMPLA,.T.)
		Endif
		
		CN100RecTi(CND->CND_CONTRA,CND->CND_REVISA,CXN->CXN_PARCEL,CXN->CXN_NUMPLA,.T.,CND->CND_FILCTR)// inclui titulo provisório da parcela atual
	Else
		CN100ETit(CND->CND_CONTRA,CND->CND_REVISA,"RECORRENTE",CXN->CXN_PARCEL, CND->CND_FILCTR, CXN->CXN_NUMPLA)//-- Exclui titulo provisorio da parcela atual
		
		If lCriaProv// cria titulo provisorio da parcela recorrente se o parâmetro MV_GCTTPPP é 0 ou 1
			CN100RecTi(CND->CND_CONTRA,CND->CND_REVISA,CXN->CXN_PARCEL,CXN->CXN_NUMPLA,.F.,CND->CND_FILCTR)
		Endif
	EndIf
Return

/*/{Protheus.doc} OnlyExced
	Se existem apenas itens excedentes na medicao corrente
@author philipe.pompeu
@since 10/02/2021
@return lResult, logico, se a medicao é exclusivamente excedente
/*/
Static Function OnlyExced() as Logical
	Local lResult := .F.
	Local cMyAlias:= "" as Char
	Local oQuery as Object
	Local cQuery := "" as Char

	cQuery := " SELECT  COUNT(CNE_ITEM) AS TOTAL"
	cQuery += " FROM "+ RetSqlName("CNE") +" CNE"
	cQuery += " WHERE "
	cQuery += " 	CNE_FILIAL = ?"
	cQuery += " AND CNE_NUMMED = ?"
	cQuery += " AND CNE_EXCEDE <> ?"	
	cQuery += " AND CNE.D_E_L_E_T_ = ?"

	cQuery := ChangeQuery( cQuery )

	oQuery := FWExecStatement():New(cQuery)
	oQuery:SetString(1, CND->CND_FILIAL)
	oQuery:SetString(2, CND->CND_NUMMED)	
	oQuery:SetString(3, '1')
	oQuery:SetString(4, Space(1))

	cMyAlias := oQuery:OpenAlias()
	If (cMyAlias)->(!Eof())			
		lResult := ((cMyAlias)->TOTAL == 0)
	EndIf
	(cMyAlias)->(dbCloseArea())

	FreeObj(oQuery)
Return lResult

/*/{Protheus.doc} A121VldPerc
	Valida o valor do campo CNZ_PERC
@author philipe.pompeu
@since 05/05/2021
@return lResult, logico, se o valor informado em CNZ_PERC é válido
/*/
Function A121VldPerc(oModelCNZ, nNewValue, nOldValue, nLinha)
	Local lResult	:= .T.
	Local nTemp		:= 0	
	Local aSaveLines:= {}
	Local nCount	:= 0
	
	If( nNewValue > 100)
		Help(" ",1,"CN300ERAT")
		lResult := .F.
	Else
		aSaveLines := FWSaveRows()
		
		nTemp := nNewValue

		For nCount := 1 to oModelCNZ:Length()
			oModelCNZ:GoLine(nCount)			
			If (nCount != nLinha) .And. !oModelCNZ:IsDeleted()
				nTemp += oModelCNZ:GetValue("CNZ_PERC")				
			EndIf
		Next nCount

		lResult := (nTemp <= 100)		

		FWRestRows(aSaveLines)
		FwFreeArray(aSaveLines)
	EndIf
Return lResult

/*/{Protheus.doc} MedMetric
	Atualiza métrica <cIdMetric> via <FWCustomMetrics>
@author philipe.pompeu
@since 28/05/2021
@return Nil, indefinido
/*/
Static Function MedMetric(nValue, cIdMetric, cSubRoutine)
	Local lContinua		:= (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')
	Local cRotina		:= "CNTA121"
	Default nValue		:= 1
	Default cIdMetric	:= "gestao-de-contratos-protheus_media-itens-medicao-contratos_total"
	Default cSubRoutine	:= ""
	
	If (lContinua)
		Do Case
			Case (cIdMetric == "gestao-de-contratos-protheus_media-itens-medicao-contratos_total")
				cSubRoutine	:= "cnta121-inclusao-medicao"
				FWCustomMetrics():setAverageMetric(cSubRoutine, cIdMetric, nValue, /*dDateSend*/, /*nLapTime*/, cRotina)
			Case (cIdMetric == "gestão-de-contratos-protheus_tempo-medio-da-medicao_seconds")
				FWCustomMetrics():setAverageMetric(cSubRoutine, cIdMetric, nValue, /*dDateSend*/, /*nLapTime*/, cRotina)
			Case (cIdMetric == "gestão-de-contratos-protheus_total-de-operacoes-_total")
				FWCustomMetrics():setSumMetric(cSubRoutine, cIdMetric, nValue, /*dDateSend*/, /*nLapTime*/, cRotina)
		End Case
	EndIf
Return

/*/{Protheus.doc} CN121DeAct
	Limpa variáveis estáticas ao desativar o modelo de dados
@author philipe.pompeu
@since 29/06/2021
@param oModel, objeto, instância de MPFormModel
@return Nil, indefinido
/*/
Static Function CN121DeAct(oModel as Object)
	ResetIdDoc()/*Reinicia a variável estática <_aIdMdlDoc> */

	CNXStClean()//Limpa variaveis estáticas do CNTXFUN

	If (_oQtdBlqIt != Nil)
		_oQtdBlqIt:Destroy()
		_oQtdBlqIt := Nil
	EndIf

	If (ValType(_oCtrProps) == 'O')
		_oCtrProps:Clean()		
	EndIf	

	If CN121MdServ()
		CN121MdServ(.T., .F.)
	EndIf

	If (ValType(_aObrgMdls) == 'J')
		FreeObj(_aObrgMdls)
	EndIf
Return Nil

/*/{Protheus.doc} ResetIdDoc
	Limpa a variável estática <_aIdMdlDoc> ou retorna seu valor inicial
@author philipe.pompeu
@since 29/06/2021
@param lReturn, lógico, deve retornar ou reiniciar variável
@return aResult, vetor, valor inicial p/ <_aIdMdlDoc>
/*/
Static Function ResetIdDoc(lReturn as Logical)
	Local aResult	:= Nil
	Default lReturn := .F.

	If lReturn
		aResult := {'SC7DETAIL',;
					'SE2DETAIL',;
					'SC5DETAIL',;
					'SE1DETAIL' }
	Else
		_aIdMdlDoc:= {	'SC7DETAIL',;
						'SE2DETAIL',;
						'SC5DETAIL',;
						'SE1DETAIL' }		 
	EndIf	
Return aResult

/*/{Protheus.doc} HasMdlId
	Verifica a existência de <cModelId> no vetor <_aIdMdlDoc>
@author philipe.pompeu
@since 29/06/2021
@param cModelId, caractere, identificador do submodelo
@return lResult, lógico, se <cModelId> está presente na variável estática <_aIdMdlDoc>
/*/
Static Function HasMdlId(cModelId as Char) as Logical
	Local lResult	:= .F.
	lResult := (aScan(_aIdMdlDoc, cModelId) > 0)
Return lResult

/*/{Protheus.doc} ConfMdlDoc
	Configura em <oModel> os submodelos dos documentos(Títulos/Pedidos:SE1,SE2,SC5 e SC7)
@author philipe.pompeu
@since 29/06/2021
@param oModel, objeto, instância de MPFormModel
@return Nil, Indefinido
/*/
Static Function ConfMdlDoc(oModel as Object)
	Local oStruSC7		:= Nil
	Local oStruSC5		:= Nil
	Local oStruSE1		:= Nil
	Local oStruSE2		:= Nil
	
	If HasMdlId('SC7DETAIL')
		oStruSC7 := FWFormStruct(1,'SC7')
		oModel:AddGrid('SC7DETAIL' ,'CNDMASTER',oStruSC7)
		oModel:SetRelation('SC7DETAIL',{{'C7_FILIAL','xFilial("SC7",CND->(IIF(Empty(CND_FILMED), cFilAnt, CND_FILMED)))'},{'C7_CONTRA' ,'CND_CONTRA'},{"C7_MEDICAO","CND_NUMMED"}},SC7->(IndexKey(1)))

		oModel:GetModel('SC7DETAIL'):SetOptional(.T.)
		oModel:GetModel('SC7DETAIL'):SetOnlyQuery(.T.)
		CNTA300BlMd(oModel:GetModel('SC7DETAIL'),.T.)
	EndIf

	If HasMdlId('SC5DETAIL')
		oStruSC5 := FWFormStruct(1,'SC5')		
		oModel:AddGrid('SC5DETAIL' ,'CNDMASTER',oStruSC5)
		oModel:SetRelation('SC5DETAIL',{{'C5_FILIAL','xFilial("SC5",CND->(IIF(Empty(CND_FILMED), cFilAnt, CND_FILMED)))'},{'C5_MDCONTR','CND_CONTRA'},{"C5_MDNUMED","CND_NUMMED"}},SC5->(IndexKey(1)))
		oModel:GetModel('SC5DETAIL'):SetOptional(.T.)
		oModel:GetModel('SC5DETAIL'):SetOnlyQuery(.T.)
		CNTA300BlMd(oModel:GetModel('SC5DETAIL'),.T.)
	EndIf

	If HasMdlId('SE1DETAIL')
		oStruSE1 := FWFormStruct(1,'SE1')
		oModel:AddGrid('SE1DETAIL' ,'CNDMASTER',oStruSE1)
		oModel:SetRelation('SE1DETAIL',{{'E1_FILORIG','CND->(IIF(Empty(CND_FILMED), cFilAnt, CND_FILMED))'},{'E1_MDCONTR','CND_CONTRA'},{'E1_MEDNUME','CND_NUMMED'}},SE1->(IndexKey(1)))
		oModel:GetModel('SE1DETAIL'):SetOptional(.T.)
		oModel:GetModel('SE1DETAIL'):SetOnlyQuery(.T.)
		CNTA300BlMd(oModel:GetModel('SE1DETAIL'),.T.)
	EndIf

	If HasMdlId('SE2DETAIL')
		oStruSE2 := FWFormStruct(1,'SE2')
		
		oModel:AddGrid('SE2DETAIL' ,'CNDMASTER',oStruSE2)		
		oModel:SetRelation('SE2DETAIL',{{'E2_FILORIG','CND->(IIF(Empty(CND_FILMED), cFilAnt, CND_FILMED))'},{'E2_MDCONTR','CND_CONTRA'},{'E2_MEDNUME','CND_NUMMED'}},SE2->(IndexKey(1)))
		
		oModel:GetModel('SE2DETAIL'):SetOptional(.T.)	
		oModel:GetModel('SE2DETAIL'):SetOnlyQuery(.T.)	
		CNTA300BlMd(oModel:GetModel('SE2DETAIL'),.T.)
	EndIf

Return Nil

/*/{Protheus.doc} CfgIdMldDoc
	Atualiza a variável estática <_aIdMdlDoc> com base na operação informada em <nOperation>.
O propósito dessa função é carregar apenas os submodelos estritamente necessários para otimizar
o tempo de abertura das telas, pois tratam-se no geral de tabelas grandes(SC5, SC7, SE1 e SE2).
@author philipe.pompeu
@since 29/06/2021
@param nOperation, numérico, operação utilizada
@return Nil, Indefinido
/*/
Static Function CfgIdMldDoc(nOperation)	
	Local lCompra := .F.
	Local lPedido := .F.
	Local lTitulo := .F.
	Local cMyAlias:= ""

	If (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_DELETE)
		_aIdMdlDoc := {} //Na inclusão/deleção não há submodelos dos documentos
	ElseIf(nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_VIEW)
		If !(AllTrim(CND->CND_SITUAC) $ "E|FE" .Or. !Empty(CND->CND_DTFIM))
			_aIdMdlDoc := {} //Nenhum submodelo de documentos deve ser exibido antes do encerramento...
		Else
			lCompra	:= CN121RetSt( "COMPRA", 0,, CND->CND_CONTRA, .F.,, CND->CND_FILCTR)			

			cMyAlias:= GetNextAlias()

			BeginSql alias cMyAlias
				SELECT  DISTINCT CNE_PEDTIT
				FROM %table:CNE% CNE		
				WHERE 
				CNE.%notDel%
				AND CNE_FILIAL = %Exp:CND->CND_FILIAL%
				AND CNE_CONTRA = %Exp:CND->CND_CONTRA%
				AND CNE_REVISA = %Exp:CND->CND_REVISA%
				AND CNE_NUMMED = %Exp:CND->CND_NUMMED%				
			EndSql			
				
			While (cMyAlias)->(!Eof())

				If AllTrim((cMyAlias)->CNE_PEDTIT) == '1' .And. !lPedido
					lPedido := .T.
				EndIf
				
				If AllTrim((cMyAlias)->CNE_PEDTIT) == '2' .And. !lTitulo
					lTitulo := .T.
				EndIf
				
				(cMyAlias)->(DbSkip())
			EndDo
			(cMyAlias)->(dbCloseArea())

			_aIdMdlDoc := {}
			If lPedido				
				aAdd(_aIdMdlDoc, IIF(lCompra, 'SC7DETAIL', 'SC5DETAIL'))
			EndIf
			If lTitulo				
				aAdd(_aIdMdlDoc, IIF(lCompra, 'SE2DETAIL', 'SE1DETAIL'))
			EndIf	
		EndIf
	EndIf
Return Nil

/*/{Protheus.doc} CfgViewDoc
	Configura em <oView> os grids p/ exibição dos documentos da medição(SC7, SC5, SE1 e SE2)
@author philipe.pompeu
@since 20/07/2021
@param oView	, objeto, instância de FWFormView
@param lCompra	, lógico, se é um contrato de compra
@param cFolderId, caractere, identificador da aba que os documentos devem ser exibidos
@return Nil, Indefinido
/*/
Static Function CfgViewDoc(oView as Object, lCompra as Logical, cFolderId as character)
	Local lPedido 	:= .F.
	Local lTitulo 	:= .F.
	Local cCampoSC7	:= "C7_FILIAL|C7_CONTRA|C7_CONTREV|C7_MEDICAO|"
	Local cCampoSC5 := "C5_FILIAL|C5_MDCONTR|C5_MDNUMED|"
	Local cCampoSE1 := "E1_FILIAL|E1_MDCONTR|E1_MDREVIS|E1_MEDNUME|"
	Local cCampoSE2 := "E2_FILIAL|E2_MDCONTR|E1_MDREVIS|E2_MEDNUME|"
	Local oStruSC7	:= Nil
	Local oStruSC5	:= Nil
	Local oStruSE1	:= Nil
	Local oStruSE2	:= Nil

	If lCompra
		If (lPedido := HasMdlId('SC7DETAIL'))
			oStruSC7 := FWFormStruct(2,'SC7', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoSC7})
			oView:AddGrid('VIEW_SC7',oStruSC7,'SC7DETAIL')
		EndIf

		If (lTitulo := HasMdlId('SE2DETAIL'))
			oStruSE2 := FWFormStruct(2,'SE2', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoSE2})
			oView:AddGrid('VIEW_SE2',oStruSE2,'SE2DETAIL')
		EndIf
	Else
		If (lPedido := HasMdlId('SC5DETAIL'))
			oStruSC5 := FWFormStruct(2,'SC5', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoSC5})
			oView:AddGrid('VIEW_SC5',oStruSC5,'SC5DETAIL')
		EndIf

		If (lTitulo := HasMdlId('SE1DETAIL'))
			oStruSE1 := FWFormStruct(2,'SE1', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoSE1})
			oView:AddGrid('VIEW_SE1',oStruSE1,'SE1DETAIL')
		EndIf
	EndIf

	If (lPedido)
		oView:AddSheet(cFolderId,'GRDPEDS',STR0134) //- Pedidos
		oView:CreateHorizontalBox('PTPED' ,100,/*owner*/,/*lUsePixel*/,cFolderId,'GRDPEDS')
		oView:SetOwnerView(IIF(lCompra, "VIEW_SC7", "VIEW_SC5")	,"PTPED")		
	EndIf

	If (lTitulo)
		oView:AddSheet(cFolderId,'GRDTITS',STR0135) //- Titulos
		oView:CreateHorizontalBox('TITS' ,100,/*owner*/,/*lUsePixel*/,cFolderId,'GRDTITS')
		oView:SetOwnerView(IIF(lCompra, "VIEW_SE2", "VIEW_SE1")	,"TITS")		
	EndIf
Return

/*/{Protheus.doc} IsNotTEC930
	Informa se a chamada não está ocorrendo do TEC930
@author philipe.pompeu
@since 26/07/2021
@return lResult, lógico, verdadeiro caso não tenha o TEC930 na pilha
/*/
Static Function IsNotTEC930()
	Local lResult := .F.

	If _lTec930Tst == Nil
		_lTec930Tst := FindFunction("TEC930Test")
	EndIf	
	lResult := IIF( (( _lTec930Tst .AND. TEC930Test()) .Or. FwIsInCallStack("ApurJobAux") ) , .F. , !FwIsInCallStack("TECA930") )

Return lResult

/*/{Protheus.doc} CN121Docum
	Validação das permissões do usuário antes da chamada ao MsDocument
@author philipe.pompeu
@since 06/08/2021
@return Nil, nulo
/*/
Function CN121Docum()
	Local aArea		:= GetArea()
	
	If CN240VldUsr(CND->CND_CONTRA, "047",.T.,, CND->CND_FILCTR)//047 == Contratos - Banco de Conhec.
		MsDocument('CND', CND->(Recno()), 2)
	EndIf

	RestArea(aArea)
Return Nil

/*/{Protheus.doc} CN121Menu
	Centraliza as chamadas realizadas na definição do menu para contabilizar métricas de usabilidade
@author philipe.pompeu
@since 24/09/2021
@param nOperacao, numerico, operacao a ser executada
@return Nil	, indefinido
/*/
Function CN121Menu(nOperacao)
	Local xResult 		:= Nil
	Local cSubRotina	:= ""
	Local cIdTotal		:= "gestão-de-contratos-protheus_total-de-operacoes-_total"
	Local cIdTempo		:= "gestão-de-contratos-protheus_tempo-medio-da-medicao_seconds"
	Local nInicio		:= Seconds()
	Local nSegsTot		:= 0
	Default nOperacao	:= 1

	Do Case
		Case (nOperacao == 1)//Incluir
			cSubRotina := "CN121Inc"
			xResult := CN121Inc()
		Case (nOperacao == 2)//Aut. Fornecimento
			cSubRotina := "CN121AutFor"
			xResult := CN121AutFor()
		Case (nOperacao == 3)//Alterar
			cSubRotina := "CN121Alt"
			xResult := CN121Alt()
		Case (nOperacao == 4)//Visualizar
			cSubRotina := "CN121Vis"
			xResult := CN121Vis()
		Case (nOperacao == 5)//Excluir
			cSubRotina := "CN121Excl"
			xResult := CN121Excl()
		Case (nOperacao == 6)//Estornar
			cSubRotina := "CN121Estorn"
			xResult := CN121Estorn(.F.)
		Case (nOperacao == 7)//Encerrar
			cSubRotina := "CN121Encerr"
			xResult := CN121Encerr(.F.)
		Case (nOperacao == 8)//Conhecimento
			cSubRotina := "CN121Docum"
			xResult := CN121Docum()
		Case (nOperacao == 9)//Imprimir
			cSubRotina := "CN121Prt"
			xResult := CN121Prt()
		Case (nOperacao == 10)//Excedentes - Medições encerradas
			cSubRotina := "CN121Exced"
			xResult := CN121Exced(.F.)
		Case (nOperacao == 11)
			cSubRotina := "CN121ExceC"
			xResult := CN121ExceC()//Excedentes - Competências não previstas
		Case (nOperacao == 12)//Medicao de Serviço(Legada do CNTA120)
			cSubRotina := "CN121Serv"

			CN121MdServ(.T., .T.)

			xResult := CN121Inc()

			CN121MdServ(.T., .F.)
	End Case

	nSegsTot := Round((Seconds() - nInicio), 0)
	MedMetric(nSegsTot	, cIdTempo, cSubRotina) /*Metrica de tempo média de chamadas a cada subrotina*/
	MedMetric(1			, cIdTotal, cSubRotina) /*Metrica de total de chamadas a cada subrotina*/
Return xResult

/*/{Protheus.doc} CN121MdServ
	Função responsável pelo gerenciamento da variável estática _MedServ120
@author philipe.pompeu
@since 29/09/2021
@param lSet		, lógico, se deve atualizar o valor da variável estática
@param lValue	, lógico, novo valor para variável estática
@return _MedServ120, lógico, valor atual da variável estática
/*/
Function CN121MdServ(lSet as Logical, lValue as Logical)
	Default lSet	:= .F.
	Default lValue	:= .F.

	if lSet
		_MedServ120 := lValue
	endif
Return _MedServ120

/*/{Protheus.doc} SetObgFlds
	Gerencia a variável estática <_aObrgMdls>, controlando ativação/desativação da obrigatoriedade do preenchimento dos campos
@author philipe.pompeu
@since 01/10/2021
@param oModel	, objeto, instância de MPFormModel
@param lObrigt	, lógico, ativa/desativa a obrigatoriedade do preenchimento dos campos
@return Nil, valor nulo
/*/
Static Function SetObgFlds(oModel as Object, lObrigt as Logical)
	Local aMldIdObrg:= {}
	Local aSavedIds	:= {}
	Local nX := 0
	Default oModel := FwModelActive()
	Default lObrigt:= .T.

	If (_aObrgMdls == Nil)		
		_aObrgMdls := JsonObject():New()		
		aSavedIds := {"CNEDETAIL"} //Caso seja necessário liberar outros submodelos, adicionar nesse array		
		aEval(aSavedIds,{|x| _aObrgMdls[x] := GCTGetObrg(oModel:GetModel(x))})//Guarda os campos obrigatórios
	EndIf

	aMldIdObrg := _aObrgMdls:GetNames()
	for nX := 1 to Len(aMldIdObrg)
		If lObrigt
			GCTRstObrg(oModel:GetModel(aMldIdObrg[nX]), _aObrgMdls[aMldIdObrg[nX]]) //Restaura a obrigatoriedade dos campos(inclusive customizados)
		Else
			oModel:GetModel(aMldIdObrg[nX]):GetStruct():SetProperty('*',MODEL_FIELD_OBRIGAT, .F.) //Libera todos os campos
		EndIf
	next nX
Return Nil

/*/{Protheus.doc} GetAdtPC
	Obtem os adiantamentos para o pedido de compra
@author philipe.pompeu
@since 21/10/2021
@param oModelCZY, objeto, instância de FwFormGridModel
@param cFornec	, caractere, código do fornecedor
@param cLoja	, caractere, loja do fornecedor
@param aItensPC	, caractere, itens do pedido de compra
@return aResult, vetor, contêm os registros a serem inseridos na tabela FIE(Adiantamentos x Pedidos)
/*/
Static Function GetAdtPC(oModelCZY as Object, cFornec as Character, cLoja as Character, aItensPC as array) as array
	Local aAreas	:= {CNX->(GetArea()), GetArea()}
	Local aSaveLines:= FwSaveRows()
	Local aResult 	:= {}
	Local nCZY		:= 0
	Local aLinha	:= {}
	Local oModel 	:= oModelCZY:GetModel()
	Local cFilCtr	:= oModel:GetValue("CNDMASTER" ,"CND_FILCTR")
	Local cContra	:= oModel:GetValue("CNDMASTER" ,"CND_CONTRA")
	Local nTotPlan	:= oModel:GetValue("CXNDETAIL" ,"CXN_VLLIQD")
	Local cFilCNX	:= xFilial("CNX", cFilCtr)
	Local cChave 	:= cFilCNX + cContra
	Local cTipoAdt	:= PadR( GetNewPar("MV_CNADITC","PA"), Len(SE2->E2_TIPO) )
	Local nNumTam	:= TamSX3("E2_NUM")[1]
	Local nNumPrefix:= TamSX3("E2_PREFIXO")[1]
	Local cParcela	:= PadR(CriaVar("E2_PARCELA") ,TamSX3("E2_PARCELA")[1])
	Local nTotalPC	:= 0
	Local nX 		:= 0
	Local nIndex	:= 0
	Local nQuant	:= 0
	Local nVlUnit	:= 0
	Local nPercent	:= 0
	
	for nX := 1 to Len(aItensPC) /*Obtem o valor total do pedido gerado*/
		nIndex := aScan(aItensPC[nX], {|x| x[1] == "C7_QUANT"})
		If nIndex > 0
			nQuant := aItensPC[nX,nIndex,2]
			If (nIndex := aScan(aItensPC[nX], {|x| x[1] == "C7_PRECO"})) > 0
				nVlUnit := aItensPC[nX,nIndex,2]
				nTotalPC += (nVlUnit * nQuant)
			EndIf
		EndIf
	next nX
	nPercent := (nTotalPC / nTotPlan) //Proporção do pedido em comparação ao total da planilha

	CNX->(DBSetOrder(1))//CNX_FILIAL+CNX_CONTRA+CNX_NUMERO

	For nCZY := 1 to oModelCZY:Length()
		oModelCZY:GoLine(nCZY)
				
		If !(oModelCZY:IsDeleted()) .And. oModelCZY:GetValue('CZY_VALOR') > 0
			If CNX->(DbSeek(cChave + oModelCZY:GetValue('CZY_NUMERO')))
				aLinha := {}
				/*Nao mudar a ordem dos campos, pois a função FPedAdtGrv espera as posicoes fixas*/
				aAdd(aLinha, {"FIE_FILIAL"	, xFilial("SE2",cFilCtr)			,Nil})
				aAdd(aLinha, {"FIE_CART"	, "P"								,Nil}) // Carteira pagar
				aAdd(aLinha, {"FIE_PEDIDO"	, ""								,Nil}) // Não precisa, pois quem trata é a a120adiantamento()				
				aAdd(aLinha, {"FIE_PREFIX"	, PadR(CNX->CNX_PREFIX, nNumPrefix)	,Nil})				
				aAdd(aLinha, {"FIE_NUM"		, PadR(CNX->CNX_NUMTIT, nNumTam)	,Nil})
				aAdd(aLinha, {"FIE_PARCEL"	, cParcela							,Nil})
				aAdd(aLinha, {"FIE_TIPO"	, cTipoAdt							,Nil})				
				aAdd(aLinha, {"FIE_FORNEC"	, cFornec							,Nil})
				aAdd(aLinha, {"FIE_LOJA"	, cLoja								,Nil})
				aAdd(aLinha, {"FIE_VALOR"	, A410Arred( oModelCZY:GetValue('CZY_VALOR')*nPercent , "FIE_VALOR" ),Nil}) // Valor do pa que está vinculado ao pedido

				aAdd(aResult, aClone(aLinha))
			EndIf
		EndIf
	Next nCZY
	
	aEval(aAreas, {|x|RestArea(x)})
	FwFreeArray(aAreas)
	FWRestRows(aSaveLines)
	FwFreeArray(aSaveLines)
Return aResult


/*/{Protheus.doc} CZYTrigSld()
	Gatilho responsável por atualizar o campo CNX_SALDO ao informar um valor no campo CZY_VALOR
@author jose.souza2
@since 23/11/2021
@version P12
/*/
Function CZYTrigSld(nValor, oModelCZY)
	Local nNovoSaldo:= LoadCZYCpo("CNX_SALDO", .T.)

	UpdVlrAdi(oModelCZY) /*Atualiza o totalizador CXN_VLRADI*/
	If (oModelCZY:GetDataId() > 0)
		CZY->(DbGoTo(oModelCZY:GetDataId()))
		nNovoSaldo += CZY->CZY_VALOR
	EndIf
	nNovoSaldo -= nValor
Return nNovoSaldo

/*/{Protheus.doc} LoadAdiants()
Função que retorna os valores da tabela CNX para os adiantamentos no cabeçalho da medição ao realizar o check na medição
@author jose.souza2
@since 23/11/2021
@version P12
/*/
Static Function LoadAdiants(oModel)
	Local aAreas	:= {CNX->(GetArea()),GetArea()}	
	Local oModelCZY	:= Nil
	Local cContra	:= oModel:GetValue("CNDMASTER", "CND_CONTRA")
	Local cFilCTR	:= oModel:GetValue("CNDMASTER", "CND_FILCTR")
	Local cChave   	:= xFilial("CNX",cFilCTR)+cContra
	Local nLinAtu 	:= 0
	Local aPropCZY	:= {}
	Local nCZY		:= 0
	
	CNX->(DbsetOrder(1))
	If CNX->(DbSeek(cChave))
		oModelCZY:= oModel:GetModel('CZYDETAIL')
		aPropCZY := GetPropMdl(oModelCZY)
		CNTA300BlMd(oModelCZY, .F.)

		For nCZY := 1 to oModelCZY:Length()
			oModelCZY:GoLine(nCZY)
			If oModelCZY:IsDeleted()
				oModelCZY:UnDeleteLine()				
			EndIf
		Next nCZY
		oModelCZY:GoLine(1)

		While CNX->(CNX_FILIAL+CNX_CONTRA == cChave .And. !EOF() )
			nLinAtu := MtFindMvc( oModelCZY,{ { 'CZY_NUMERO', CNX->CNX_NUMERO }  } )
			If CNX->CNX_SALDO > 0 .And. nLinAtu == 0
				If !Empty(oModelCZY:GetValue("CZY_NUMERO"))
					oModelCZY:AddLine()
				Else
					oModelCZY:LoadValue("CZY_REVISA", oModel:GetValue("CNDMASTER", "CND_REVISA"))
				EndIf
				oModelCZY:LoadValue("CZY_NUMERO", CNX->CNX_NUMERO)
				oModelCZY:LoadValue("CZY_DTADT"	, CNX->CNX_DTADT)
				oModelCZY:LoadValue("CZY_VLADT"	, CNX->CNX_VLADT)
				oModelCZY:LoadValue("CZY_SALDO"	, CNX->CNX_SALDO)
			EndIf
			CNX->(dbSkip())
		EndDo
		
		RstPropMdl(oModelCZY, aPropCZY)
		FwFreeArray(aPropCZY)
	EndIf

	aEval(aAreas,{|x|RestArea(x)})
	FwFreeArray(aAreas)
Return Nil

/*/{Protheus.doc} LoadCZYCpo()
Função que retorna o valor total do adiantamento na pasta adiantamentos
@author jose.souza2
@since 24/11/2021
@version P12
/*/
Static Function LoadCZYCpo(cCampo, lTrigger)
	Local aAreas	:= {CNX->(GetArea()),GetArea()}
	Local oModelCND	:= Nil
	Local oModelCZY := Nil
	Local cChave    := ""
	Local xRet		:= Nil
	Local nPosCpo	:= 0
	Local oModel	:= FwModelActive()
	Default cCampo	:= "CNX_VLADT"
	Default lTrigger:= .F.
	
	nPosCpo := CNX->(FieldPos(cCampo))
	xRet 	:= IIF(nPosCpo > 0, CriaVar(cCampo, .F.), Nil)

	If (oModel:GetOperation() != MODEL_OPERATION_INSERT .Or. lTrigger)
		oModelCND := oModel:GetModel("CNDMASTER")
		oModelCZY := oModel:GetModel("CZYDETAIL")
		cChave := xFilial("CNX",  oModelCND:GetValue("CND_FILCTR"))+oModelCND:GetValue("CND_CONTRA")

		If lTrigger
			cChave += oModelCZY:GetValue("CZY_NUMERO")
		Else			
			cChave += CZY->CZY_NUMERO
		EndIf
		
		CNX->(DbsetOrder(1))
		If CNX->(DbSeek(cChave))
			If nPosCpo > 0
				xRet:= CNX->(FieldGet(nPosCpo))				
			EndIf			
		EndIf
	EndIf

	aEval(aAreas,{|x|RestArea(x)})
	FwFreeArray(aAreas)
Return xRet

/*/{Protheus.doc} CZYVldVlr()
	Função responsável pelo valid do campo CZY_VALOR
@author jose.souza2
@since 24/11/2021
@version P12
/*/
Function CZYVldVlr(oModelCZY, nNovoValor)
	Local lResult  := .T.
	Local nValorAnt:= 0

	If (oModelCZY:GetDataId() >0)
		CZY->(DbGoTo(oModelCZY:GetDataId()))
		nValorAnt:= CZY->CZY_VALOR
	EndIf

	lResult:= !((nNovoValor) > (LoadCZYCpo("CNX_SALDO",.T.) + nValorAnt))

	If !lResult
		Help(" ",1,"CN130NVLCOMP")
	EndIf
Return lResult

/*/{Protheus.doc} ConfMldCZY
	Configura em <oModel> o submodelo dos Adiantamentos(CZYDETAIL)
@author philipe.pompeu
@since 30/11/2021
@return oModel, objeto, instância de MPFormModel
/*/
Static Function ConfMldCZY(oModel)
	Local oStruCZY	:= FWFormStruct(1,'CZY')
	Local aTamCpo	:= {}
	Local aRelatCZY	:= {}
	Local bTrigSld	:= {|a,b,c|CZYTrigSld(c,a)}
	Local bVldValor := FwBuildFeature( STRUCT_FEATURE_VALID	,"CZYVldVlr(a,c)")
	Local bWhenCpos	:= FwBuildFeature( STRUCT_FEATURE_WHEN	,".F.")
	Local bRevIniPad:= FwBuildFeature( STRUCT_FEATURE_INIPAD, "FwFldGet('CND_REVISA')")
		
	oStruCZY:AddField(STR0220					,;	// 	[01]  C   Titulo do campo
				STR0221						,;	// 	[02]  C   ToolTip do campo
				 "CZY_DTADT"				,;	// 	[03]  C   Id do Field
				 "D"						,;	// 	[04]  D   Tipo do campo
				 8	                        ,;	// 	[05]  N   Tamanho do campo
				 0							,;	// 	[06]  N   Decimal do campo
				 {|| .T. }					,;	// 	[07]  B   Code-block de validação do campo
				 bWhenCpos					,;	// 	[08]  B   Code-block de validação When do campo
				 NIL						,;	//	[09]  A   Lista de valores permitido do campo
				 .F.						,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				{|| LoadCZYCpo("CNX_DTADT") }			    ,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL						,;	//	[12]  L   Indica se trata-se de um campo chave
				 .T.						,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .T.						)	// 	[14]  L   Indica se o campo é virtual
	aTamCpo := TAMSX3("CNX_VLADT")
	oStruCZY:AddField(STR0222				,;	// 	[01]  C   Titulo do campo
					STR0223					,;	// 	[02]  C   ToolTip do campo
					"CZY_VLADT"				,;	// 	[03]  C   Id do Field
					"N"						,;	// 	[04]  N   Tipo do campo
					aTamCpo[1]	    		,;	// 	[05]  N   Tamanho do campo
					aTamCpo[2]				,;	// 	[06]  N   Decimal do campo
					{|| .T. }				,;	// 	[07]  B   Code-block de validação do campo
					bWhenCpos				,;	// 	[08]  B   Code-block de validação When do campo
					NIL						,;	//	[09]  A   Lista de valores permitido do campo
					.F.						,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					{|| LoadCZYCpo("CNX_VLADT")},;	//	[11]  B   Code-block de inicializacao do campo
					NIL						,;	//	[12]  L   Indica se trata-se de um campo chave
					.F.						,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.						)	// 	[14]  L   Indica se o campo é virtual

	aTamCpo := TAMSX3("CNX_SALDO")
	oStruCZY:AddField(	STR0224					,;	// 	[01]  C   Titulo do campo
						STR0225					,;	// 	[02]  C   ToolTip do campo
						"CZY_SALDO"				,;	// 	[03]  C   Id do Field
						"N"						,;	// 	[04]  N   Tipo do campo
						aTamCpo[1]	    		,;	// 	[05]  N   Tamanho do campo
						aTamCpo[2]	    		,;	// 	[06]  N   Decimal do campo
						{|| .T. }				,;	// 	[07]  B   Code-block de validação do campo
						bWhenCpos				,;	// 	[08]  B   Code-block de validação When do campo
						NIL						,;	//	[09]  A   Lista de valores permitido do campo
						.F.						,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
						{|| LoadCZYCpo("CNX_SALDO") },;	//	[11]  B   Code-block de inicializacao do campo
						NIL						,;	//	[12]  L   Indica se trata-se de um campo chave
						.T.						,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.						)	// 	[14]  L   Indica se o campo é virtual

	oStruCZY:SetProperty('CZY_SALDO'	, MODEL_FIELD_NOUPD	,.F.)
	oStruCZY:SetProperty('CZY_VALOR'	, MODEL_FIELD_VALID	,bVldValor)
	oStruCZY:SetProperty('CZY_NUMERO'	, MODEL_FIELD_WHEN	,bWhenCpos)
	oStruCZY:SetProperty("CZY_REVISA"	, MODEL_FIELD_INIT	,bRevIniPad)

	oStruCZY:AddTrigger('CZY_VALOR', 'CZY_SALDO', {||.T.}, bTrigSld )
	oModel:AddGrid('CZYDETAIL','CXNDETAIL',oStruCZY	, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/,/*bLoad*/)

	oModel:AddCalc('CALC_CZY','CXNDETAIL','CZYDETAIL','CZY_VALOR','CXN_VLRADI','SUM',,, RetTitle("CXN_VLRADI"))

	aRelatCZY := {{'CZY_CONTRA','CND_CONTRA'},{'CZY_NUMMED','CND_NUMMED'},{"CZY_NUMPLA","CXN_NUMPLA"}}
	If CZY->(FieldPos("CZY_FILCTR")> 0 .And. FieldPos("CZY_FILMED") > 0)
		aAdd(aRelatCZY, {'CZY_FILCTR','CND_FILCTR'})
		aAdd(aRelatCZY, {'CZY_FILMED','CND_FILMED'})
	EndIf
	oModel:SetRelation('CZYDETAIL', aRelatCZY,CZY->(IndexKey(2)))
	
	oModel:GetModel('CZYDETAIL'):SetOptional(.T.)
	CNTA300BlMd(oModel:GetModel('CZYDETAIL'),,.T.)//Libera apenas o update
Return Nil

/*/{Protheus.doc} UpdVlrAdi
	Carrega o valor dos adiantamentos para o campo CXN_VLRADI
@author philipe.pompeu
@since 30/11/2021
@param oModelCZY, objeto, instância de FwFormGrid do submodelo CZYDETAIL
*/
Function UpdVlrAdi(oModelCZY)
	Local oModel 	:= Nil
	Local oModelCXN := Nil
	Local aProp 	:= {}

	oModel 	  := oModelCZY:GetModel()
	oModelCXN := oModel:GetModel("CXNDETAIL")

	aProp:= GetPropMdl(oModelCXN)

	CNTA300BlMd(oModelCXN,,.T.)//Libera p/ atualizacao	

	CNNoWhenSet(oModelCXN, "CXN_VLRADI", oModel:GetValue("CALC_CZY", "CXN_VLRADI"))//Via SetValue p/ atualizar o totalizador da CND

	RstPropMdl(oModelCXN, aProp)	
	FwFreeArray(aProp)
Return Nil

/*/{Protheus.doc} GetAdtPlan
	Constrói uma lista de adiantamentos para possibilitar sua posterior validação.
@author philipe.pompeu
@since 07/12/2021
@param oModelCZY, objeto, instância de FwFormGrid do submodelo CZYDETAIL
@param aVldAdiant, vetor, lista que deve receber os adiantamentos
@return Nil, valor nulo
*/
Static Function GetAdtPlan(oModelCZY as Object, aVldAdiant as array)
	Local aArea	 := CNX->(GetArea())
	Local nIndex := 0
	Local nX	 := 0
	Local cNumAdt:= ""
	Local oAdt := Nil
	Local oModelCND := oModelCZY:GetModel():GetModel("CNDMASTER")
	Local cFilCNX := xFilial("CNX", oModelCND:GetValue("CND_FILCTR"))

	CNX->(DbsetOrder(1))
	For nX := 1 to oModelCZY:Length()
		oModelCZY:GoLine(nX)
		If !oModelCZY:IsDeleted()
			
			cNumAdt:= oModelCZY:GetValue("CZY_NUMERO")
			nIndex := aScan(aVldAdiant, {|x| x['NUMADT'] == cNumAdt })
			if nIndex == 0
				oAdt := JsonObject():New()
				oAdt["NUMADT"]	:= cNumAdt
				oAdt["VALOR"]	:= 0
				oAdt["SALDO"]	:= 0

				cChave := cFilCNX + oModelCND:GetValue("CND_CONTRA") + cNumAdt
				If CNX->(DbSeek(cChave))
					oAdt["SALDO"]:= CNX->CNX_SALDO
				EndIf

				aAdd(aVldAdiant, oAdt)
				nIndex := Len(aVldAdiant)
			endif
			aVldAdiant[nIndex]["VALOR"] += oModelCZY:GetValue("CZY_VALOR")

			If (oModelCZY:GetDataId() > 0)
				CZY->(DbGoTo(oModelCZY:GetDataId()))
				aVldAdiant[nIndex]["SALDO"] += CZY->CZY_VALOR
			EndIf
		EndIf
	Next nX
	RestArea(aArea)
	FwFreeArray(aArea)
Return Nil

/*/{Protheus.doc} VldAdtPlan
	Valida o total dos adiantamentos por planilha.
Essa função trabalha em conjunto com a função <GetAdtPlan>
@author philipe.pompeu
@since 07/12/2021
@param aVldAdiant, vetor, lista de adiantamentos construída pela função <GetAdtPlan>
@return lResult, lógico, se a validação foi efetuada com sucesso
*/
Static Function VldAdtPlan(aVldAdiant as array) as Logical
	Local lResult := .T.
	Local nX := 0
	Local oAdiant	:= Nil

	for nX := 1 to Len(aVldAdiant)
		oAdiant := aVldAdiant[nX]
		If oAdiant["VALOR"] > oAdiant["SALDO"]
			lResult := .F.
			Help(" ",1,"CN130NVLCOMP")
			Exit
		EndIf
	next nX

	aEval(aVldAdiant, {|x| FreeObj(x)})
	FwFreeArray(aVldAdiant)
Return lResult

/*/{Protheus.doc} ProcTitSE1
	Processa a inclusão do contas à receber via FINA040
@author philipe.pompeu
@since 15/12/2021
@param aCab, vetor, contêm os campos do título
@param aFKF, vetor, contêm os complemento do título
@param aFKG, vetor, contêm o complemento imposto x titulos
@return Nil, valor nulo
*/
Static Function ProcTitSE1(aCab as array, aFKF as array, aFKG as array)
	Local aRotAuto	:= FWVetByDic(aCab, "SE1")//Ordena o cabeçalho com base no dicionário
	Local nPosRatEv := 0
	Local aRatSevSez:= {}
	Local lRetJob	:= .T.
	Default aFKF	:= {}
	Default aFKG	:= {}

	nPosRatEv	:= aScan(aCab, { |x| x[1] == 'AUTRATEEV' } )
	If (nPosRatEv > 0)
		aRatSevSez := aClone(aCab[nPosRatEv, 2])
	EndIf

	If (FwIsInCallStack("CNTA260JOB")) /*Nesse cenário deve executar a inclusão do título numa thread separada p/ evitar deadlock(RECLOCKED)*/		
		lRetJob := StartJob( "GCTINCTIT" , GetEnvServer() , .T. , {cEmpAnt, cFilAnt}, aRotAuto, aRatSevSez, aFKF, aFKG)
		If !lRetJob
			lMsErroAuto := .T.
		EndIf
	Else
		CNMedTitE1(aRotAuto, aRatSevSez, aFKF, aFKG)
	EndIf
Return Nil

/*/{Protheus.doc} CNMedTitE1
	Chama o execAuto do FINA040 p/ inclusao de um título a receber
@author philipe.pompeu
@since 15/12/2021
@param aCab, vetor, contêm os campos do título
@param aFKF, vetor, contêm os complemento do título
@param aFKG, vetor, contêm o complemento imposto x titulos
@return lResult, lógico, se o processamento ocorreu com sucesso.
*/
Function CNMedTitE1(aRotAuto as array, aRatSevSez as array, aFKF as array, aFKG as array) as Logical
	Local nOpcAuto	:= 3
	Local bExec		:= {|a, b, c, d, e, f, g| FINA040(a,b,c,d,e,f,g)}
	Local lResult	:= .T.
	
	If (FwIsInCallStack("GCTIncTit"))
		Private lMsErroAuto := .F.		
	EndIf

	MSExecAuto(bExec,;
		aRotAuto	,;
		nOpcAuto	,;
		/*aTitPrv*/	,;
		aRatSevSez	,;
		/*aParam*/	,;
		aFKF		,;
		aFKG )

	lResult := !lMsErroAuto
Return lResult

/*/{Protheus.doc} CXNParcTp9
	Retorna na função se os campos referentes a data e parcelamento da condição de pagamento tipo 9 existem na CXN
@author jose.souza2
@since 14/12/2021
@return lResult, lógico, se existe os campos referentes a data e ao parcelamento na CXN
/*/

Static Function CXNParcTp9() as Logical
	Local lResult   := .F.

	If (_lCXNParc == Nil)
		_lCXNParc := VldParcTP9("CXN",1)

	EndIf

	lResult := _lCXNParc
Return lResult

/*/{Protheus.doc} VldParcTP9
	Retorna na função se a quantidade de parcelas 
	informadas no parâmetro MV_NUMPARC esta compátivel com os campos criados na base de dados 
@author jose.souza2
@since 14/12/2021
@return lResult, lógico, se existe os campos referentes a data e ao parcelamento na CXN
/*/

Static Function VldParcTP9(cTable,nStart)
	Local lRet 		:= .T.
	Local nParcelas	:= 0
	Local nX		:= 0
	Local cSeq		:= ""
	Local cParcPln  := ""
	Local cDataParc := ""
	Local cPrefCpo  := ""

	Default cTable  := "CND"
	Default nStart  := 5


	cPrefCpo := PrefixoCpo(cTable)

	cParcPln   := cPrefCpo + "_PARC"

	cDataParc  := cPrefCpo + "_DATA"


	nParcelas := SuperGetMv("MV_NUMPARC")
	cSeq := CValToChar(nStart)
	
	for nX := nStart to nParcelas
		lRet := (cTable)->(ColumnPos(cParcPln + cSeq) > 0 .And. ColumnPos(cDataParc + cSeq) > 0)
		
		If !lRet
			Exit
		EndIf
		cSeq := Soma1(cSeq,1)
	next nX

Return lRet

/*/{Protheus.doc} GetParcPV
	Obtêm as parcelas de <cTable> e joga no vetor <aResult> p/ geração do pedido de venda
@author philipe.pompeu
@since 21/12/2021
@param cTable, caractere, tabela de onde obter as parcelas
@param aResult, vetor, onde adicionar as parcelas
@return Nil, Nulo
*/
Static Function GetParcPV(cTable as Character, aResult as array)	
	Local nParcelas	:= SuperGetMv("MV_NUMPARC")
	Local cPrefCpo	:= PrefixoCpo(cTable)
	Local cValorCpo	:= cPrefCpo + "_PARC"
	Local cDataCpo	:= cPrefCpo + "_DATA"
	Local cSeq		:= "1"
	Local nX		:= 0
	Local nValor	:= 0
	Local dDtVenc	:= Date()	

	for nX := 1 to nParcelas
		nValor := (cTable)->(&(cValorCpo+cSeq))
		dDtVenc:= (cTable)->(&(cDataCpo+cSeq))

		If !Empty(nValor) .And. !Empty(dDtVenc)
			aAdd(aResult, {"C5_PARC"+cSeq, nValor, NIL})
			aAdd(aResult, {"C5_DATA"+cSeq, dDtVenc,NIL})
		EndIf
		cSeq := Soma1(cSeq,1)
	next nX

Return Nil

/*/{Protheus.doc} CfgFldsParc
	Configura os campos de parcelas de condição do tipo 9 em <oStruct>
@author philipe.pompeu
@since 21/12/2021
@param oStruct, objeto, instância da classe FWFormModelStruct
@return Nil, Nulo
*/
Static Function CfgFldsParc(oStruct as Object)
	Local nParcelas	:= SuperGetMv("MV_NUMPARC")
	Local cSeq		:= "1"
	Local cTable 	:= ""
	Local cPrefCpo	:= ""
	Local cValorCpo	:= ""
	Local cDataCpo	:= ""
	Local bParcTp9	:= {|| !Empty(FWFldGet("CND_CONDPG")) .And. Posicione('SE4',1,xFilial('SE4') + FWFldGet("CND_CONDPG"), 'E4_TIPO') == '9' }
	Local lVldPos	:= .T.
	Local nX		:= 0
	
	cTable 		:= oStruct:GetTable()[1]
	cPrefCpo	:= PrefixoCpo(cTable)
	cValorCpo	:= cPrefCpo + "_PARC"
	cDataCpo	:= cPrefCpo + "_DATA"

	for nX := 1 to nParcelas //Adiciona campos pra condicao de pagamento tipo 9	
		lVldPos := (nX <= 4)
		If (!lVldPos)		
			lVldPos := (cTable)->( ColumnPos(cValorCpo + cSeq) > 0 .And. ColumnPos(cDataCpo + cSeq) > 0)
		EndIf

		If lVldPos
			oStruct:SetProperty( cValorCpo 	+ cSeq, MODEL_FIELD_WHEN, bParcTp9)
			oStruct:SetProperty( cDataCpo 	+ cSeq, MODEL_FIELD_WHEN, bParcTp9)
		EndIf
		cSeq := Soma1(cSeq,1)
	next nX
Return Nil

/*/{Protheus.doc} GetFormPag
	Obtem <A2_FORMPAG> com base na chave composta por <cFornece> e <cLoja>
@author philipe.pompeu
@since 28/03/2022
@param cFornece, caractere, codigo do fornecedor
@param cLoja, caractere, loja do fornecedor
@param cFilCtr, caractere, filial do contrato
@return cResult, caractere, forma de pagamento
*/
Static Function GetFormPag(cFornece, cLoja, cFilCtr)
	Local aArea		:= SA2->(GetArea())
	Local cResult	:= ""
	Local cChave	:= ""

	cChave	:= xFilial('SA2',cFilCtr) + cFornece + cLoja
	cResult := POSICIONE('SA2', 1, cChave, 'A2_FORMPAG')

	RestArea(aArea)
	FwFreeArray(aArea)
Return cResult

/*/{Protheus.doc} IsDocGen
	Verifica se já foi gerado documento para <cItemPlan>
@author philipe.pompeu
@since 07/04/2022
@param oModelCXJ, objeto, instância de FWFormGrid do submodelo CXJDETAIL
@param cItemPlan, caractere, item a ser buscado
@return lGerado, lógico, se foi gerado algum documento p/ o item
*/
Static Function IsDocGen(oModelCXJ as Object, cItemPlan as Character) as Logical
	Local nLinha	:= oModelCXJ:GetLine()
	Local lGerado	:= .F.

	If oModelCXJ:SeekLine({{"CXJ_ITEMPL",  cItemPlan}})
		lGerado := !Empty(oModelCXJ:GetValue("CXJ_NUMPED")) .Or. !Empty(oModelCXJ:GetValue("CXJ_NUMTIT"))
	EndIf

	oModelCXJ:GoLine(nLinha)
Return lGerado

/*/{Protheus.doc} GCTGsMvZer
	Encapsula a chamada à função <TecGsMvZer> do SIGATEC: confere parâmetro MV_GSMDZER
@author philipe.pompeu
@since 09/05/2022
@return _lGsMedZer, lógico, resultado da chamada a função <TecGsMvZer>
/*/
Function GCTGsMvZer()
	If _lGsMedZer == Nil
		_lGsMedZer := FindFunction("TecGsMvZer") .And. TecGsMvZer()
	EndIf
Return _lGsMedZer

/*/{Protheus.doc} SetWhenOri
	Gerencia o controle do X3_WHEN originais dos campos dos modelos. 
Utilizado p/ restaurar o when dos modelos ao estado configurado na função ModelDef(when do dicionário OU setado via SetProperty)
@author philipe.pompeu
@since 15/06/2022
@param oModel,objeto, instância de MPFormModel
@param lOnlyCache,lógica, se deve apenas armazenar o When no Cache sem realizar operação nenhuma
@param aIdRestore,vetor, id dos submodelos à serem armazenados
/*/
Static Function SetWhenOri(oModel, lOnlyCache, aIdRestore)
	Default lOnlyCache := .F.
	Default aIdRestore := {'CXNDETAIL','CNEDETAIL','CNZDETAIL'}

	If lOnlyCache
		aEval(aIdRestore,{|x| FwFreeArray(GCTGetWhen(oModel:GetModel(x), .F., Nil, .T.))})
	Else		
		aEval(aIdRestore,{|x| GCTRstWhen( oModel:GetModel(x) , Nil, Nil, .T. ) })		
	EndIf
Return

/*/{Protheus.doc} CfgCNEExced
	Configura o struct dos itens da medição(CNE) para funcionamento dos itens que sejam excedentes
@author philipe.pompeu
@since 18/07/2022
@param oModel, objeto, instância de FwFormGridModel do submodelo CNEDETAIL
@return Nil
/*/
Static Function CfgCNEExced(oModelCNE)
	Local oStruCNE	:= Nil
	Local bInitExced:= Nil
	Local bCondTrig := {|| FwFldGet('CNE_EXCEDE') == '1' }
	Local bTrigProdt:= Nil
	Local aCposTrig := CposExced()
	Local nX 		:= 0
	Local bTrueWhen := FwBuildFeature( STRUCT_FEATURE_WHEN, ".T.")

	/*Alteracoes na estrutura devem ser realizadas antes da chamada as funcoes SetObgFlds e SetWhenOri*/
	oStruCNE:= oModelCNE:GetStruct()		
	If lExcedMEnc //Excedente p/ medicao encerrada precisa preencher os campos chave p/ geração dos documentos
		oStruCNE:SetProperty("CNE_CONTRA" 	,MODEL_FIELD_INIT	,FwBuildFeature(STRUCT_FEATURE_INIPAD, "FwFldGet('CND_CONTRA')") )
		oStruCNE:SetProperty("CNE_REVISA" 	,MODEL_FIELD_INIT	,FwBuildFeature(STRUCT_FEATURE_INIPAD, "FwFldGet('CND_REVISA')") )
		oStruCNE:SetProperty("CNE_NUMMED" 	,MODEL_FIELD_INIT	,FwBuildFeature(STRUCT_FEATURE_INIPAD, "FwFldGet('CND_NUMMED')") )
		oStruCNE:SetProperty("CNE_NUMERO" 	,MODEL_FIELD_INIT	,FwBuildFeature(STRUCT_FEATURE_INIPAD, "FwFldGet('CXN_NUMPLA')") )			
	EndIf
	oStruCNE:SetProperty("CNE_DTENT" 	,MODEL_FIELD_INIT	,FwBuildFeature(STRUCT_FEATURE_INIPAD, "dDataBase"))		
	IIF(oStruCNE:HasField('CNE_CF'), oStruCNE:SetProperty("CNE_CF" ,MODEL_FIELD_OBRIGAT,(cPaisLoc == "RUS")),)
	
	bInitExced := FwBuildFeature( STRUCT_FEATURE_INIPAD, "'1'")
	oStruCNE:SetProperty("CNE_EXCEDE" 	,MODEL_FIELD_INIT, bInitExced)
	oStruCNE:SetProperty('CNE_PRODUT'   ,MODEL_FIELD_WHEN,bTrueWhen)
	oStruCNE:SetProperty('CNE_VLUNIT'   ,MODEL_FIELD_WHEN,bTrueWhen)

	for nX := 1 to Len(aCposTrig)
		bTrigProdt:= &('{|a,b,c,d| CNEPrdExcd(a,b,c,d,"'+ aCposTrig[nX] +'") }')		
		oStruCNE:AddTrigger('CNE_PRODUT', aCposTrig[nX], bCondTrig, bTrigProdt )
	next nX

	FwFreeArray(aCposTrig)
Return

/*/{Protheus.doc} CNEPrdExcd
	Gatilha o preenchimento de <cCDomin> com base na CNB p/ itens excedentes
@author philipe.pompeu
@since 18/07/2022
@param oModel	, objeto, instância de FwFormGridModel do submodelo CNEDETAIL
@param cCampo	, caractere, campo sendo informado(nesse cenário sempre CNE_PRODUT)
@param cProduto	, caractere, produto informado
@param nLinha	, numerico, linha da CNE
@param cCDomin	, caractere, campo à ser preenchido
@return cResult, caractere, novo valor para <cCDomin>
/*/
Function CNEPrdExcd(oModelCNE, cCampo, cProduto, nLinha, cCDomin)
	Local aAreaCNB 	:= CNB->(GetArea())
	Local cResult	:= ""
	Local oModel	:= oModelCNE:GetModel()
	Local cFilCtr	:= oModel:GetValue('CNDMASTER', 'CND_FILCTR')
	Local cContra	:= oModel:GetValue('CNDMASTER', 'CND_CONTRA')
	Local cNumPla	:= oModel:GetValue('CXNDETAIL', 'CXN_NUMPLA')
	Local cChave 	:= ""
	Local cCpoCNB	:= ""
	Local nCpoCNB	:= 0

	CNB->(dbSetOrder(4))//CNB_FILIAL+CNB_CONTRA+CNB_NUMERO+CNB_PRODUT
	cChave := xFilial("CNB", cFilCtr) + cContra + cNumPla + cProduto
	If CNB->(MsSeek(cChave))
		cCpoCNB := PrefixoCpo("CNB") + SubStr(cCDomin, At("_", cCDomin))
		Do Case
			Case (cCDomin == "CNE_TES")
				cResult := CNB->CNB_TS
			Case ((nCpoCNB := CNB->(FieldPos(cCpoCNB))) > 0)				
				cResult := CNB->(FieldGet(nCpoCNB))
		End Case		
	EndIf

	RestArea(aAreaCNB)
	FwFreeArray(aAreaCNB)
Return cResult

/*/{Protheus.doc} CposExced
	Retorna os campos da CNE que devem ser liberados p/ alteração e gatilhados com base na CNB
@author philipe.pompeu
@since 18/07/2022
@return aCampos, vetor, lista de campos
/*/
Static Function CposExced()
	Local aCampos := {}
	Local aParCps := {}

	aAdd(aCampos,'CNE_CC')
	aAdd(aCampos,'CNE_CONTA')
	aAdd(aCampos,'CNE_CLVL')
	aAdd(aCampos,'CNE_ITEMCT')

	AddEntCtb(aParCps)//Carrega entidades contab. adicionais
	aEval(aParCps, {|x| aAdd(aCampos,x[1])})
	FwFreeArray(aParCps)

	aAdd(aCampos,'CNE_TES')
	aAdd(aCampos,'CNE_TABPRC')
Return aCampos

/*/{Protheus.doc} LibCpoExcd
	Libera os campos da CNE para itens excedentes
@author philipe.pompeu
@since 18/07/2022
@param oModel, objeto, instância de MPFormModel
@return Nil
/*/
Static Function LibCpoExcd(oModel)
	Local aBlkCpo := {}

	MtBCMod(oModel,{'CNEDETAIL'},{||.F.},'1') //- Bloqueia todos os campos
	aAdd(aBlkCpo,'CNE_PRODUT')
	aAdd(aBlkCpo,'CNE_DESCRI')
	aAdd(aBlkCpo,'CNE_QUANT')
	aAdd(aBlkCpo,'CNE_VLUNIT')		
	aAdd(aBlkCpo,'CNE_TS')
	IIF((cPaisLoc == "RUS"), aAdd(aBlkCpo,'CNE_CF'),)
	aAdd(aBlkCpo,'CNE_VLTOT')
	aAdd(aBlkCpo,'CNE_PEDTIT')
	aAdd(aBlkCpo,'CNE_IDPED')		

	aEval(CposExced(),{|x| aAdd(aBlkCpo,x) })		

	MtBCMod(oModel,{{'CNEDETAIL',aBlkCpo}},{||.T.},'2')

	FwFreeArray(aBlkCpo)
Return

/*/{Protheus.doc} CNDStruct
	Retorna uma instância de FwFormStruct da tabela CND com as modificações necessárias
@author philipe.pompeu
@since 30/09/2022
@return oStruCND, objeto, instância de FwFormStruct da tabela CND
/*/
Static Function CNDStruct()
	Local oStruCND 	:= FWFormStruct(1,'CND') //Estrutura Cabecalho
	Local aCposTrig := {"CND_REVISA","CND_APROV", "CND_MOEDA", "CND_REVGER","CND_VLCONT","CND_VLADIT","CND_VLREAJ"}
	Local nX		:= 0
	Local bSetValue	:= Nil
	Local bVldMoeda := MTBlcVld('CND','CND_MOEDA',"CNVlTxMoed(FwFldGet('CND_MOEDA'), FwFldGet('CND_DTINIC'))", .T.,, .T.)

	/*---------Alteracoes na estrutura da CND---------*/
	oStruCND:AddField(STR0061/*Competência*/		,;	// 	[01]  C   Titulo do campo
					STR0061						,;	// 	[02]  C   ToolTip do campo
					"CND_RCCOMP"					,;	// 	[03]  C   Id do Field
					"C"							,;	// 	[04]  C   Tipo do campo
					3								,;	// 	[05]  N   Tamanho do campo
					0								,;	// 	[06]  N   Decimal do campo
					{|a,b,c,d|CN121SetCp(a,b,c,d)}	,;	// 	[07]  B   Code-block de validação do campo
					NIL							,;	// 	[08]  B   Code-block de validação When do campo
					{"",""}						,;	//	[09]  A   Lista de valores permitido do campo
					.F.							,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					NIL							,;	//	[11]  B   Code-block de inicializacao do campo
					NIL							,;	//	[12]  L   Indica se trata-se de um campo chave
					.T.							,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.							)	// 	[14]  L   Indica se o campo é virtual

	oStruCND:SetProperty('CND_CONTRA'	,MODEL_FIELD_NOUPD, .T.)
	oStruCND:SetProperty('CND_REVISA'	,MODEL_FIELD_NOUPD, .T.)
	oStruCND:SetProperty('CND_MOEDA'	,MODEL_FIELD_NOUPD, .T.)
	
	oStruCND:SetProperty('CND_MOEDA'	,MODEL_FIELD_VALID, bVldMoeda)

	oStruCND:AddTrigger('CND_RCCOMP' /*cIdField*/, 'CND_RCCOMP'	/*cTargetIdField*/, {||.T.} /*bPre*/,{||CN121Compet()}/*bSetValue*/ )	

	for nX := 1 to Len(aCposTrig)//Todos os campos que devem ser preenchidos com valores da CN9 ao alterar CND_CONTRA
		bSetValue := &("{|x| C121TrgCN9(x,'"+ aCposTrig[nX] +"')}")
		oStruCND:AddTrigger('CND_CONTRA', aCposTrig[nX],  /*bPre*/, bSetValue)
	next nX
	FwFreeArray(aCposTrig)

	If CND->( ColumnPos( "CND_TXMOED" ) ) > 0
		oStruCND:AddTrigger('CND_CONTRA', "CND_TXMOED", /*bPre*/, {|| 0 })
	EndIf
Return oStruCND

/*/{Protheus.doc} C121TrgCN9
	Função chamada ao preencher CND_CONTRA(trigger), obtêm os campos da CN9 correspondentes ao da CND
@author philipe.pompeu
@since 30/09/2022
@param oModelCND, objeto, instância de FwFormGrid CNDMASTER
@param cCpoDest, caractere, campo destino na CND
@return xValor, indefinido, valor da CN9
/*/
Function C121TrgCN9(oModelCND, cCpoDest )
	Local aArea	:= CN9->(GetArea())
	Local xValor := ""
	Local cFilCtr := oModelCND:GetValue("CND_FILCTR")
	Local cContra := oModelCND:GetValue("CND_CONTRA")
	Local cChave := xFilial("CN9",cFilCtr) + cContra + DEF_SVIGE

	CN9->(DbSetOrder(7))
	If CN9->(CN9_FILIAL+CN9_NUMERO+CN9_SITUAC == cChave .Or. DbSeek(cChave))
		DO CASE
			CASE (cCpoDest == "CND_APROV")
				xValor := CN9->CN9_GRPAPR
			CASE (cCpoDest == "CND_MOEDA")
				xValor := CN9->CN9_MOEDA
			CASE (cCpoDest == "CND_REVGER")
				xValor := CN9->CN9_REVISA
			CASE (cCpoDest == "CND_VLCONT")
				xValor := CN9->CN9_VLATU
			CASE (cCpoDest == "CND_VLADIT")
				xValor := CN9->CN9_VLADIT
			CASE (cCpoDest == "CND_VLREAJ")
				xValor := CN9->CN9_VLREAJ
			CASE (cCpoDest == "CND_REVISA")
				xValor := CN9->CN9_REVISA				
		ENDCASE
	EndIf	
	RestArea(aArea)
	FwFreeArray(aArea)
Return xValor

/*/{Protheus.doc} InitCposMd
	Função responsável por preencher o inicializador padrão dos campos da grid após alterar
	a competência da medição
@author jose.souza2
@since 04/11/2022
@param oGrid, objeto, instância de FwFormGrid do modelo desejado
@return 
/*/
Static Function InitCposMd(oGrid)
	Local aCamposGrid	:= oGrid:GetStruct():GetFields()
	Local aArea			:= GetArea()
	Local nI			:= 0
	Local xInitValue	:= ""

	For nI:= 1 to Len(aCamposGrid)
		If aCamposGrid[nI][MODEL_FIELD_INIT] <> NIL
			xInitValue := oGrid:InitValue(aCamposGrid[nI][MODEL_FIELD_IDFIELD])
			If !Empty(xInitValue)
				oGrid:LoadValue(aCamposGrid[nI][MODEL_FIELD_IDFIELD], xInitValue )
			EndIf
		EndIf
	Next	
	RestArea(aArea)
	FwFreeArray(aArea)
Return

/*/{Protheus.doc} CNEStruct
	Retorna uma instância de FwFormStruct da tabela CNE com as modificações necessárias
@author jose.souza2
@since 18/01/2023
@return oStruCNE, objeto, instância de FwFormStruct da tabela CNe
/*/
Static Function CNEStruct()
	Local oStruCNE		:= FWFormStruct(1,'CNE')
	Local bBuildQtd		:= Nil
	Local bVldCNECpos	:= FwBuildFeature( STRUCT_FEATURE_WHEN, "!(CN121RetSt('FIXO') .Or. CN121RetSt('SEMIPROD'))")
	Local bWhenVlUn		:= FwBuildFeature( STRUCT_FEATURE_WHEN, "CNVlUnWhen()")
	Local bWhenPerc 	:= FwBuildFeature( STRUCT_FEATURE_WHEN, "!(CN121RetSt('SERVIÇO') .Or. CN121RetSt('SEMIPROD'))")
	Local bWhenQtd		:= FwBuildFeature( STRUCT_FEATURE_WHEN, "!CN121RetSt('SERVIÇO')")
	Local bInitTES		:= FwBuildFeature( STRUCT_FEATURE_INIPAD, "CN121IniTES()")
	Local bVldTES 		:= FwBuildFeature( STRUCT_FEATURE_VALID	, "CN121VldTES()")
	Local nX := 0
	Local aTriggers := {}
	Local cDomin 	:= ""
	Local cCDomin 	:= ""
	Local cCondic 	:= ""
	Local aTrigCNE 	:= {}

	/*---------Alteracoes na estrutura da CNE---------*/
	oStruCNE:AddField(STR0066															,;	// 	[01]  C   Titulo do campo
					STR0067																,;	// 	[02]  C   ToolTip do campo
					"CNE_TES"															,;	// 	[03]  C   Id do Field
					"C"																	,;	// 	[04]  C   Tipo do campo
					Max(TamSX3("CNE_TE")[1],TamSX3("CNE_TS")[1])						,;	// 	[05]  N   Tamanho do campo
					0																	,;	// 	[06]  N   Decimal do campo
					bVldTES																,;	// 	[07]  B   Code-block de validação do campo
					NIL																	,;	// 	[08]  B   Code-block de validação When do campo
					NIL																	,;	//	[09]  A   Lista de valores permitido do campo
					.F.																	,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					bInitTES															,;	//	[11]  B   Code-block de inicializacao do campo
					NIL																	,;	//	[12]  L   Indica se trata-se de um campo chave
					.F.																	,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.																	 )	// 	[14]  L   Indica se o campo é virtual

	oStruCNE:AddField(STR0068															,;	// 	[01]  C   Titulo do campo
					STR0069																,;	// 	[02]  C   ToolTip do campo
					"CNE_SDAMED"														,;	// 	[03]  C   Id do Field
					"N"																	,;	// 	[04]  C   Tipo do campo
					TamSX3("CNE_QTAMED")[1]												,;	// 	[05]  N   Tamanho do campo
					0																	,;	// 	[06]  N   Decimal do campo
					{|| .T. }															,;	// 	[07]  B   Code-block de validação do campo
					NIL																	,;	// 	[08]  B   Code-block de validação When do campo
					NIL																	,;	//	[09]  A   Lista de valores permitido do campo
					.F.																	,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					FwBuildFeature( STRUCT_FEATURE_INIPAD,  "CN121SldDis()")			,;	//	[11]  B   Code-block de inicializacao do campo
					NIL																	,;	//	[12]  L   Indica se trata-se de um campo chave
					.T.																	,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.																	 )	// 	[14]  L   Indica se o campo é virtual

	//-- Receber o valor antigo no valid
	bBuildQtd := MTBlcVld("CNE","CNE_QUANT"	,"Positivo() .And. CN121VldQtd(a,b,c,d) .And. Cn121MultT(a,b,c,,.F.)",.F.,.F., .T.)
	oStruCNE:SetProperty("CNE_QUANT" 	,MODEL_FIELD_VALID	,bBuildQtd)
	oStruCNE:SetProperty('CNE_PDESC'    ,MODEL_FIELD_WHEN,bVldCNECpos)
	oStruCNE:SetProperty('CNE_VLDESC'   ,MODEL_FIELD_WHEN,bVldCNECpos)
	oStruCNE:SetProperty('CNE_PRODUT'   ,MODEL_FIELD_WHEN,bVldCNECpos)
	oStruCNE:SetProperty('CNE_PRODSV'   ,MODEL_FIELD_WHEN,bVldCNECpos)
	oStruCNE:SetProperty('CNE_QUANT'   	,MODEL_FIELD_WHEN,bWhenQtd)
	oStruCNE:SetProperty('CNE_VLUNIT'   ,MODEL_FIELD_WHEN,bWhenVlUn)
	oStruCNE:SetProperty('CNE_PERC'   	,MODEL_FIELD_WHEN,bWhenPerc)
	oStruCNE:SetProperty('CNE_ARREND'   ,MODEL_FIELD_WHEN,bVldCNECpos)

	//-- Gatilho Para Preencher a CNE	
	oStruCNE:AddTrigger('CNE_PRODUT' /*cIdField*/, 'CNE_TES'	/*cTargetIdField*/, {||.T.} /*bPre*/,{||CN121AtuTes()}/*bSetValue*/ )
	oStruCNE:AddTrigger('CNE_TES'	 /*cIdField*/, 'CNE_TES'	/*cTargetIdField*/, {||.T.} /*bPre*/,{||CN121TES()}/*bSetValue*/ )
	oStruCNE:AddTrigger('CNE_VLDESC', 'CNE_PDESC', {||!FwIsInCallStack('CN121VlTot') .And. A121VldGat('CNE_VLDESC','CNE_PDESC')}, {||0})

	If !(GetRPORelease() > "12.1.2410")
		aTriggers := oStruCNE:aTriggers
		for nX := 1 to Len(aTriggers)
			cDomin := AllTrim(aTriggers[nX,1])
			cCDomin:= AllTrim(aTriggers[nX,2])
			cCondic:= GetCbSource(aTriggers[nX,3])
			if ((cDomin == 'CNE_VLTOT' .And. cCDomin == 'CNE_VLUNIT' .And. ('CN121VlSt'  $ cCondic ) ) .Or. ;
				(cDomin == 'CNE_VLUNIT' .And. cCDomin == 'CNE_VLTOT' .And. ('A121VldGat' $ cCondic ) ))
				
				aTriggers[nX,3] := {|| .F. } //Desabilita trigger inválida
			endif
		next	
		aTrigCNE := FwStruTrigger(	'CNE_VLTOT'	,;
									'CNE_VLUNIT',;
									'FwFldGet("CNE_VLTOT")',,,,,;
									'CN121VlSt()') //Só executa se for uma planilha fixa de serviço(nesse cenário o valor unitário é sempre igual ao total)
		oStruCNE:AddTrigger(aTrigCNE[1]	, aTrigCNE[2]	, aTrigCNE[3], aTrigCNE[4]  )
	
		aTrigCNE := FwStruTrigger(	'CNE_VLUNIT',;
									'CNE_VLTOT'	,;
									'FwFldGet("CNE_VLUNIT") * FwFldGet("CNE_QUANT")',,,,,;
									'!(CN121VlSt())') //Só executa se NÃO for uma planilha fixa de serviço
		oStruCNE:AddTrigger(aTrigCNE[1]	, aTrigCNE[2]	, aTrigCNE[3], aTrigCNE[4]  )
	EndIf

	aTrigCNE := FwStruTrigger(	'CNE_VLUNIT',;
								'CNE_VLUNIT',;
								'FwFldGet("CNE_VLUNIT")',,,,,;
								'CN121VlSt(.T.)') //Só executa se for uma planilha fixa de serviço(nesse cenário o valor unitário é sempre igual ao total), porém é preenchido via loadValue na condição do gatilho(que sempre retorna falso)
	oStruCNE:AddTrigger(aTrigCNE[1]	, aTrigCNE[2]	, aTrigCNE[3], aTrigCNE[4]  )
	
	FwFreeArray(aTrigCNE)     
Return oStruCNE

/*/{Protheus.doc} GetPosCpo
	Retorna a posição do campo na estrutura, que fica armazenada na variável estática _oPosCpos
_oPosCpos não contêm todos os campos, apenas os mais utilizados
@author philipe.pompeu
@since 23/03/2023
@param oModel, objecto, instância de MPFormModel
@param cCampo, caractere, campo que se deseja saber a posição
@return nResult, numerico, posição do campo
/*/
Static Function GetPosCpo(oModel as Object, cCampo as Character) as Numeric
	Local cSubMdlId := ""
	Local aCampos := {}
	Local nX := 0
	Local nY := 0
	Local aModelxCpo := {}
	Local oStruct := Nil
	Local aPosCpos := {}
	Local nResult := 0

	If _oPosCpos == Nil
		_oPosCpos := JsonObject():New()
		aAdd(aModelxCpo,{"CNDMASTER", { 'CND_FILCTR'	,'CND_CONTRA'} })
		aAdd(aModelxCpo,{"CXNDETAIL", { 'CXN_CHECK'		,;
										'CXN_VLLIQD'	,;
										'CXN_VLDESC'	,;
										'CXN_VLMULT'	,;
										'CXN_VLBONI'	,;
										'CXN_NUMPLA'	}})
		aAdd(aModelxCpo,{"CNEDETAIL", {	"CNE_PRODUT"	,;
										"CNE_QTDORI"	,;
										"CNE_QTDSOL"	,;
										"CNE_QUANT"		,;
										"CNE_PERC"		,;
										"CNE_VUNORI"	,;
										"CNE_VLUNIT"	,;
										"CNE_VLTOT"		,;
										"CNE_VLDESC"	,;
										"CNE_PDESC"}})
		for nX := 1 to Len(aModelxCpo)		
			cSubMdlId	:= aModelxCpo[nX,1]
			aCampos		:= aModelxCpo[nX,2]

			oStruct := oModel:GetModel(cSubMdlId):GetStruct()

			aPosCpos := oStruct:GetArrayPos(aCampos)

			for nY := 1 to Len(aPosCpos)
				_oPosCpos[aCampos[nY]] := aPosCpos[nY]
			next nY
		next

		FwFreeArray(aModelxCpo)
	EndIf
	nResult := _oPosCpos[cCampo]
Return nResult

/*/{Protheus.doc} CXNStruct
	Retorna uma instância de FwFormStruct da tabela CXN com as modificações necessárias
@author philipe.pompeu
@since 23/03/2023
@return oStruCXN, objeto, instância de FwFormStruct da tabela CXN
/*/
Static Function CXNStruct()
	Local oStruCXN 		:= FWFormStruct(1,'CXN')
	Local bVldCXNCpos	:= FwBuildFeature( STRUCT_FEATURE_WHEN, "!Empty(FwFldGet('CXN_TIPPLA'))")
	Local bTrueWhen		:= FwBuildFeature( STRUCT_FEATURE_WHEN, ".T.")
	Local bFalseWhen	:= FwBuildFeature( STRUCT_FEATURE_WHEN, ".F.")
	Local bZeroWhen		:= FwBuildFeature( STRUCT_FEATURE_WHEN, "CxnZeroWhe()")	
	Local bVldForCli	:= FwBuildFeature( STRUCT_FEATURE_VALID	,"Cn121VldFC(a,b,c)")	
	Local aUserFldCXN	:= {}
	Local aTotCpos := {	'CXN_VLTOT'	,;//Campos totalizadores
						'CXN_VLLIQD',;
						'CXN_VLMULT',;
						'CXN_VLMPED',;
						'CXN_VLBONI',;
						'CXN_VLBPED'}				

	/*---------Alteracoes na estrutura da CXN---------*/
	oStruCXN:AddField(STR0062															,;	// 	[01]  C   Titulo do campo
					STR0063																,;	// 	[02]  C   ToolTip do campo
					"CXN_FORCLI"														,;	// 	[03]  C   Id do Field
					"C"																	,;	// 	[04]  C   Tipo do campo
					Max(TamSX3("CNA_FORNEC")[1],TamSX3("CNA_CLIENT")[1])				,;	// 	[05]  N   Tamanho do campo
					0																	,;	// 	[06]  N   Decimal do campo
					bVldForCli															,;	// 	[07]  B   Code-block de validação do campo
					NIL																	,;	// 	[08]  B   Code-block de validação When do campo
					NIL																	,;	//	[09]  A   Lista de valores permitido do campo
					.F.																	,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					FwBuildFeature( STRUCT_FEATURE_INIPAD	,"CN121IFC('CLIFOR')")		,;	//	[11]  B   Code-block de inicializacao do campo
					NIL																	,;	//	[12]  L   Indica se trata-se de um campo chave
					.F.																	,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.																 	 )	// 	[14]  L   Indica se o campo é virtual
					
	oStruCXN:AddField(STR0192															,;	//  [01]  C   Titulo do campo - Ignora Item Bloq.
					STR0193																,;	// 	[02]  C   ToolTip do campo - Ignora itens inconsistentes da planilha.
					"CXN_IGITEM"														,;	// 	[03]  C   Id do Field
					"L"																	,;	// 	[04]  C   Tipo do campo
					1																	,;	// 	[05]  N   Tamanho do campo
					0																	,;	// 	[06]  N   Decimal do campo
					NIL																	,;	// 	[07]  B   Code-block de validação do campo
					NIL																	,;	// 	[08]  B   Code-block de validação When do campo
					NIL																	,;	//	[09]  A   Lista de valores permitido do campo
					.F.																	,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					{|| .F. }															,;	//	[11]  B   Code-block de inicializacao do campo
					NIL																	,;	//	[12]  L   Indica se trata-se de um campo chave
					.F.																	,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.						 											 )	// 	[14]  L   Indica se o campo é virtual
					
	oStruCXN:AddField(STR0064														,;	// 	[01]  C   Titulo do campo
				STR0065																,;	// 	[02]  C   ToolTip do campo
				"CXN_LOJA"															,;	// 	[03]  C   Id do Field
				"C"																	,;	// 	[04]  C   Tipo do campo
				Max(TamSX3("CNA_LJFORN")[1],TamSX3("CNA_LOJACL")[1])				,;	// 	[05]  N   Tamanho do campo
				0																	,;	// 	[06]  N   Decimal do campo
				{|a,b,c|Cn121VldFC(a,b,c)}											,;	// 	[07]  B   Code-block de validação do campo
				NIL																	,;	// 	[08]  B   Code-block de validação When do campo
				NIL																	,;	//	[09]  A   Lista de valores permitido do campo
				.F.																	,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				FwBuildFeature( STRUCT_FEATURE_INIPAD	,"CN121IFC('LJFORN')")		,;	//	[11]  B   Code-block de inicializacao do campo
				NIL																	,;	//	[12]  L   Indica se trata-se de um campo chave
				.F.																	,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				.T.																	 )	// 	[14]  L   Indica se o campo é virtual

	
	oStruCXN:AddTrigger('CXN_FORCLI' /*cIdField*/, 'CXN_LOJA'	/*cTargetIdField*/, {||.T.} /*bPre*/,{|a,b,c|CN121GatFC(a,b,c)}	/*bSetValue*/ )
	
	aUserFldCXN := GCTGetWhen( , .T.,  oStruCXN) /*Guarda o WHEN dos campos de usuario*/
	oStruCXN:SetProperty('*'			, MODEL_FIELD_WHEN,bFalseWhen)	
	oStruCXN:SetProperty('CXN_CHECK'	, MODEL_FIELD_WHEN,bVldCXNCpos)
	oStruCXN:SetProperty('CXN_DTVENC'	, MODEL_FIELD_WHEN,bVldCXNCpos)
	oStruCXN:SetProperty('CXN_FORCLI'	, MODEL_FIELD_WHEN,bVldCXNCpos)
	oStruCXN:SetProperty('CXN_LOJA'		, MODEL_FIELD_WHEN,bVldCXNCpos)
	oStruCXN:SetProperty('CXN_PARCEL'	, MODEL_FIELD_WHEN,bVldCXNCpos)
	oStruCXN:SetProperty('CXN_IGITEM'	, MODEL_FIELD_WHEN,bVldCXNCpos)
	oStruCXN:SetProperty('CXN_ZERO'		, MODEL_FIELD_WHEN,bZeroWhen)

	aEval(aTotCpos,{|x| oStruCXN:SetProperty(x, MODEL_FIELD_WHEN,bTrueWhen)})//Liberado p/ o totalizador
					
	GCTRstWhen( , aUserFldCXN, oStruCXN)
	FwFreeArray(aUserFldCXN)
	FwFreeArray(aTotCpos)
Return oStruCXN

/*/{Protheus.doc} CNVlUnWhen
	When do campo CNE_VLUNIT
@author philipe.pompeu
@since 04/09/2023
@return lAltera, lógico, se permite alteração
/*/
Function CNVlUnWhen()
	Local lFixo 	:= CN121RetSt('FIXO')
	Local lAltera 	:= !((lFixo .And. !CN121RetSt('SERVIÇO')) .Or. CN121RetSt('SEMIPROD'))	

	If !lAltera .And. lFixo
		lAltera := CN121RetSt("LMTMED") > 0
	EndIf
Return lAltera

/*/{Protheus.doc} CNEVLDesc
	Realiza o calculo do valor do desconto do item da medição(CNE_VLDESC)
@author philipe.pompeu
@since 19/09/2023
@param nVlTot, numerico, valor total do item
@param nPDesc, numerico, percentual do desconto
@return nValDescnt, numerico, valor do desconto
/*/
Function CNEVLDesc(nVlTot, nPDesc)
	Local nValDescnt:= 0
	Local nDecimal 	:= GetSX3Cache("CNE_VLDESC","X3_DECIMAL")
	Local nValorBase:= 0

	nValorBase := nVlTot * ( nPDesc / 100 )
	nValDescnt := Round(nValorBase, nDecimal)

	If (nValDescnt >= nVlTot)
		nValDescnt := NoRound(nValorBase, nDecimal)
	EndIf	

Return nValDescnt

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} UltMedCNF
	Retorna a última data de encerramento da medição de determinada parcela
@author philipe.pompeu
@since 01/11/2023
@return dDtFim, data, data de encerramento da medição mais recente
-------------------------------------------------------------------------------------/*/
Static Function UltMedCNF()
	Local aAreas := {CND->(GetArea()),CNF->(GetArea()), GetArea()}
	Local dDtFim := CtoD("//")
	Local cQuery := ""
	Local cTmpAlias  := ""	
	Local oUltMedQry := Nil

	cQuery := "SELECT MAX(CND_DTFIM) CND_DTFIM FROM "+  RetSqlName("CXN") +" CXN"
	cQuery += " INNER JOIN "+RetSqlName("CND")+" CND ON("
	cQuery += " 	CND.CND_FILIAL = CXN.CXN_FILIAL"
	cQuery += " AND CND.CND_CONTRA = CXN.CXN_CONTRA"
	cQuery += " AND CND.CND_REVISA = CXN.CXN_REVISA"
	cQuery += " AND CND.CND_NUMMED = CXN.CXN_NUMMED"
	cQuery += " AND CND.D_E_L_E_T_ = CXN.D_E_L_E_T_)"		
	cQuery += " WHERE"
	cQuery += " 	CND.CND_FILCTR = ? "	//Pode existir medição em qualquer filial
	cQuery += " AND CND.CND_NUMMED < ? "	//Exclui a medição sendo estornada
	cQuery += " AND CXN.CXN_CONTRA = ? "
	cQuery += " AND CXN.CXN_REVISA = ? "
	cQuery += " AND	CXN.CXN_NUMPLA = ? "
	cQuery += " AND	CXN.CXN_PARCEL = ? "
	cQuery += " AND CXN.D_E_L_E_T_ = ? "
	cQuery += " GROUP BY CND_FILCTR,CXN_CONTRA,CXN_REVISA,CXN_NUMPLA,CXN_PARCEL"
	cQuery := ChangeQuery(cQuery)

	oUltMedQry := FwExecStatement():New(cQuery)
	
	oUltMedQry:SetString(1, CND->CND_FILCTR)
	oUltMedQry:SetString(2, CND->CND_NUMMED)
	oUltMedQry:SetString(3, CNF->CNF_CONTRA)
	oUltMedQry:SetString(4, CNF->CNF_REVISA)
	oUltMedQry:SetString(5, CNF->CNF_NUMPLA)
	oUltMedQry:SetString(6, CNF->CNF_PARCEL)
	oUltMedQry:SetString(7, Space(1)) //Campo D_E_L_E_T_

	cTmpAlias := oUltMedQry:OpenAlias()
	
	TCSetField(cTmpAlias,"CND_DTFIM","D",08,0)
	If ( (cTmpAlias)->(!Eof()) )
		dDtFim := (cTmpAlias)->CND_DTFIM
	EndIf
	(cTmpAlias)->(dbCloseArea())

	aEval(aAreas,{|x|RestArea(x)})
	FwFreeArray(aAreas)	

	FreeObj(oUltMedQry)
Return dDtFim

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} AtUltLinRat
Atualiza o valor a ser preenchido na última linha do rateio contábil quando
o valor total do rateio for diferente do valor total do item.

@param oModelCNZ, objeto, instância de FwFormGrid CNZDETAIL

@return lRet, lógico, caso tenha atualizado o valor total ou se não foi necessário efetuar a validação
@author jose.souza2
@since 16/05/2024
/*/
//-------------------------------------------------------------------------------------
Static Function AtUltLinRat(oModelCNE)
	Local nTamVlr		:= GetSX3Cache('CNZ_VALOR1','X3_DECIMAL')
	Local nX			:= 0
	Local nVlrItem		:= 0
	Local nTotal		:= 0
	Local nTotItem		:= 0
	Local nVlRat		:= 0
	Local aRowsCNZ		:= FWSaveRows()
	Local aWhenCNZ		:= {}
	Local aCampos		:=	{{'CNZDETAIL',{'CNZ_VALOR1','CNZ_VALOR2','CNZ_VALOR3','CNZ_VALOR4','CNZ_VALOR5'}}}
	Local oModel  		:= oModelCNE:GetModel()
	Local oModelCNZ		:= oModel:GetModel("CNZDETAIL")
	Local lRet			:= .T.

	nTotItem:= oModelCNE:GetValue("CNE_VLTOT")

	If nTotItem > 0

		For nX := 1 to oModelCNZ:Length()
			oModelCNZ:GoLine(nX)
			If !oModelCNZ:IsDeleted() .And. !Empty(oModelCNZ:GetValue("CNZ_PERC"))
				nTotal	+= Round(oModelCNZ:GetValue("CNZ_VALOR1"),nTamVlr)
			EndIf
		Next nX

		If nTotal > 0 .And. nTotal != nTotItem
			//Pega When do modelo da CNZ para restaurar posteriormente
			aWhenCNZ:= GCTGetWhen(oModelCNZ)
			//Libera edição dos campos da CNZ
			MtBCMod(oModel,aCampos,{||.T.},'2')	

			nVlrItem	:= Round(oModelCNZ:GetValue("CNZ_VALOR1"),nTamVlr)
			nVlRat		:= nVlrItem+(nTotItem-nTotal)
		
			lRet:= oModelCNZ:SetValue("CNZ_VALOR1",nVlRat)
			//Seta valor nos campos CNZ_VALOR2 até CNZ_VALOR5
			For nX := 2 to 5
				lRet:= oModelCNZ:SetValue("CNZ_VALOR"+ cValToChar(nX) ,xMoeda(nVlRat,1,nX,dDatabase))
			Next nX

			lRet:= oModelCNZ:VldData()

			//Restaura o when do modelo
			GCTRstWhen(oModelCNZ, aWhenCNZ)
		EndIf
	EndIf

	FWRestRows(aRowsCNZ)
	FwFreeArray(aRowsCNZ)
	FwFreeArray(aWhenCNZ)
	FwFreeArray(aCampos)

Return lRet


/*/{Protheus.doc} AtuSldFrt
	Ao marca o Check da Planilha atualiza o valor dos campos de frete,seguro e despesa da CXN

	@param oModel   ,objeto  , instância o modelo de dados
	@param nLine    ,numerico, informa a linha posicionada da CNE
	@param cAction  ,caracter, ação realização no momento
	@param xValue   ,numerico, valor inserido
	@param xOldValue,numerico, valor do campo
	@param cCampo   ,caracter, campo que foi acionado

@return Nil
@author ivan.magno
@since 11/10/2024
/*/
Static Function AtuSldFrt( oModel, nLine, cAction, xValue, xOldValue, cCampo )
	Local aArea      := { CNB->(GetArea()),GetArea() }
	Local oMdlCNE	 := Nil
	Local oMdlCXN	 := Nil
	Local nVlFrete	 := 0
	Local nVlSeguro  := 0
	Local nVlDespes	 := 0
	Local nProporcao := 0
	Local cNumContr	 := ""
	Local cRevisa	 := ""
	Local cPlanilha	 := ""
	Local cChave	 := ""
	
	oMdlCNE := oModel:GetModel( "CNEDETAIL" )
	oMdlCXN	:= oModel:GetModel( "CXNDETAIL" )	

	If HasCpoFrete() .And. Cn121RetSt( "COMPRA",,,, .T., oModel )
		If cAction $ "DELETE|UNDELETE"
			If !oMdlCXN:IsDeleted()
				nTotFrete  := oMdlCXN:GetValue('CXN_FRETE' )
				nTotDespes := oMdlCXN:GetValue('CXN_DESPES')
				nTotSeguro := oMdlCXN:GetValue('CXN_SEGURO')

				If cAction == "DELETE"
					nTotFrete  -= oMdlCNE:GetValue('CNE_FRETE' )
					nTotDespes -= oMdlCNE:GetValue('CNE_DESPES')
					nTotSeguro -= oMdlCNE:GetValue('CNE_SEGURO')
				Else					
					nTotFrete  += oMdlCNE:GetValue('CNE_FRETE' )
					nTotDespes += oMdlCNE:GetValue('CNE_DESPES')
					nTotSeguro += oMdlCNE:GetValue('CNE_SEGURO')

				Endif
				oMdlCXN:LoadValue('CXN_FRETE' , nTotFrete  )
				oMdlCXN:LoadValue('CXN_DESPES', nTotDespes )
				oMdlCXN:LoadValue('CXN_SEGURO', nTotSeguro )
			Endif

		Elseif cAction == 'SETVALUE'
			If cCampo == "CNE_VLTOT"				
				cNumContr := oMdlCNE:GetValue( "CNE_CONTRA" )
				cRevisa   := oMdlCNE:GetValue( "CNE_REVISA" )
				cPlanilha := oMdlCNE:GetValue( "CNE_NUMERO" )
				cChave	  := xFilial( "CNB", oModel:GetValue("CNDMASTER", "CND_FILCTR") ) + cNumContr + cRevisa + cPlanilha

				CNB->(DbSetOrder(1) )
				If CNB->(MsSeek( cChave + oMdlCNE:GetValue('CNE_ITEM') ) )
					nCNBFrete  := CNB->CNB_FRETE
					nCNBSegur  := CNB->CNB_SEGURO
					nCNBDespes := CNB->CNB_DESPES						
				
					If CN121RetSt('SEMIPROD')		
						nProporcao := ( ( ( oMdlCNE:GetValue('CNE_QUANT') *  oMdlCNE:GetValue('CNE_VLUNIT') ) / oMdlCXN:GetValue('CXN_VLSALD') ) )
					Else
						nProporcao := ( oMdlCNE:GetValue('CNE_QUANT') / (oMdlCNE:GetValue('CNE_QTDSOL') ) )
					Endif
					nVlFrete  := ( nCNBFrete ) * ( nProporcao )
					nVlSeguro := ( nCNBSegur ) * ( nProporcao )
					nVlDespes := ( nCNBDespes) * ( nProporcao )

					If nVlDespes <= nCNBDespes  .And. nVlFrete <= nCNBFrete  .And. nVlSeguro <= nCNBSegur
						nVlFrete  := Min(( nVlFrete  ), CNB->CNB_SLDFRT)
						nVlSeguro := Min(( nVlSeguro ), CNB->CNB_SLDSEG)
						nVlDespes := Min(( nVlDespes ), CNB->CNB_SLDDSP)

						oMdlCNE:SetValue('CNE_FRETE' , nVlFrete  )
						oMdlCNE:SetValue('CNE_DESPES', nVlDespes )
						oMdlCNE:SetValue('CNE_SEGURO', nVlSeguro )
					Endif

				Endif

			Else		
				cCpoCNA := StrTran(cCampo,"CNE","CXN",1,2)			
				oMdlCXN:LoadValue( cCpoCNA, oMdlCXN:GetValue( cCpoCNA ) + ( xValue - xOldValue ) )
			Endif			
			
		Endif
		
	Endif
	
	aEval(aArea, {|x| RestArea(x) })
	FwFreeArray( aArea )
Return

/*/{Protheus.doc} VldSldFre
	Valida os saldos de frete,despesa e seguro

@param oModel, objeto, instância o modelo de dados

@return lRet, logico, Retonar .T. se os saldos de frete,despesa e seguro estão corretos
@author ivan.magno
@since 17/10/2024
/*/
Static Function VldSldFre( oModelCNE )
	Local aArea      := { GetArea() }
	Local aValida	 := {}
	Local oModel  	 := oModelCNE:GetModel()
	Local nY		 := 0
	Local nSldDespes := 0
	Local nSldFrete	 := 0
	Local nSldSegur  := 0	
	Local cValor	 := ""
	Local cNumContr	 := ""
	Local cRevisa	 := ""
	Local cPlanilha	 := ""
	Local cChave	 := ""
	Local cCpo		 := ""
	Local lRet 		 := .T.		
	
	If HasCpoFrete() .And. !lEncerra .And.  Cn121RetSt( "COMPRA",,,, .T., oModel )

		cNumContr 	:= oModel:GetValue('CNDMASTER','CND_CONTRA')
		cRevisa   	:= oModel:GetValue('CNDMASTER','CND_REVISA')
		cPlanilha	:= oModel:GetValue('CXNDETAIL','CXN_NUMPLA') 
		cItem 		:= oModelCNE:GetValue('CNE_ITEM')
		cChave		:=  xFilial( "CNB", oModel:GetValue("CNDMASTER", "CND_FILCTR") ) + cNumContr + cRevisa + cPlanilha

		CNB->(DbSetOrder(1) )
		If CNB->(MsSeek( cChave + oModelCNE:GetValue('CNE_ITEM') ) )
			nSldFrete  := CNB->CNB_SLDFRT
			nSldSegur  := CNB->CNB_SLDSEG
			nSldDespes := CNB->CNB_SLDDSP		

			aValida := {{'CNE_FRETE',  nSldFrete},;
						{'CNE_DESPES', nSldDespes},;
						{'CNE_SEGURO', nSldSegur}}												
			
			For nY := 1 to Len(aValida)
				cCpo := aValida[nY,1]
				cValor := cValToChar( aValida[nY,2] )
				If oModelCNE:GetValue(cCpo) > aValida[nY,2]
					lRet := .F.
					Exit
				Endif
			Next			
		Endif

		If !lRet
			Help( ,,'CN121FRETE',,I18N(STR0247,{cCpo, cPlanilha, cItem, cValor}), 1, 0) //Verifique o campo #1 que está com o saldo insuficiente na planilha #2 no item #3. O saldo restante do item é: #4
		Endif
	
	Endif

	aEval(aArea, {|x| RestArea(x) })
	FwFreeArray( aArea )
	FwFreeArray( aValida )

Return lRet

/*/{Protheus.doc} HasCpoFrete
	Preenche a variavel Static _lVldFrete

@return _lVldFrete, logico, Retonar .T. caso encontre o função CtrCpoFret e os campos relacionados ao frete
@author ivan.magno
@since 26/12/2024
/*/
Static Function HasCpoFrete()

	If _lVldFrete == Nil
		_lVldFrete := FindFunction("CtrCpoFret") .And. CtrCpoFret()
	Endif

Return _lVldFrete

//----------------------------------------------------------------------------------
/*/{Protheus.doc} CNEPosVld
	Função de pós-validação da CNE
@param oModelCNE, object, Modelo de CNEDETAIL

@return lResult, lógico, retorna .T. se as validações não falharem
@author ivan.magno
@since 27/12/2024
/*/
//----------------------------------------------------------------------------------
Function CNEPosVld(oModelCNE)
	Local oModel 	:= oModelCNE:GetModel()
	Local oModelCNZ := oModel:GetModel("CNZDETAIL")
	Local lResult	:= .F.
	Local aCTBEnt 	:= CTBEntArr()

	lResult := C121CNxLOk(oModel, aCTBEnt, "CNE")  .And. VldSldFre(oModelCNE)

	If lResult .And. !FwIsInCallStack("Cn121VldChk")
		lResult := CN300VldCC(oModelCNE, oModelCNZ)
	Endif

	If lResult
		lResult := AtUltLinRat(oModelCNE)
	Endif

	FwFreeArray( aCTBEnt )

Return lResult

