#include "Protheus.ch"
#iNCLUDE "FWMVCDEF.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FINA050.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MSINTNFS()
Gera LOG personalizado na integra��o de Notas Fiscais
@author Lucas Miranda de Aguiar
@since 23/11/2023
@version 1.0
Inicial
@return NIL
/*/
//-------------------------------------------------------------------

/*/
nOperac 1 - Devolu��o comum
nOperac 2 - Cancelamento devolu��o comum
nOperac 3 - Inclus�o NF
nOperac 4 - Devolu��o m�s fechado
nOperac 5 - Dele��o NF
nOperac 6 - Cancelamento devolu��o m�s fechado

/*/

User Function MSINTNFS(cOper,aXml,nRec,aInfo,nOperac)

	Local aArea := GetArea()
	Local cFilInt := ""
	Local cNumNf  := ""
	Local cSerNf  := ""
	Local cFornNF := ""
	Local cLojFrn := ""
	Local cIProc  := ""
	Local cJson   := ""
	Local cTipo   := ""
	Local cParc   := ""


	Default cOper := "A"
	Default aXml := {}
	Default nRec := 0
	Default aInfo := {}
	Default nOperac := 0

	//Inclus�o NF
	If cOper == "I" .And. nOperac == 3

		cFilInt := aXml[1]:CFILREG
		cNumNf  := STRZERO(val(aXml[1]:CDOC),9)
		cSerNf  := aXml[1]:cSerie + Space(TamSX3("E2_PREFIXO")[1] - Len(aXml[1]:cSerie))
		cFornNF := aXml[1]:CFORNECE
		cLojFrn := aXml[1]:CLOJA
		cTipo   := aXml[1]:cTipo
		cParc   := aXml[3][1]:cParcela + Space(TamSX3("E2_PARCELA")[1] - Len(aXml[3][1]:cParcela))
		cIProc  := Dtos(date()) + " " + Time()
		cJson   := FwJsonSerialize(aXml)

		DbSelectArea("P50")
		Reclock("P50",.T.)
		P50->P50_FILIAL := cFilInt
		P50->P50_NUMNF  := cNumNF
		P50->P50_SERIE  := cSerNf
		P50->P50_FORNEC := cFornNF
		P50->P50_LOJA   := cLojFrn
		P50->P50_IPROC  := cIproc
		P50->P50_JSON   := cJson
		P50->P50_PARCEL := cParc
		P50->P50_TIPO   := cTipo
		P50->P50_OPER   := fGetOper(cFilInt+cSerNf+cNumNf+cParc+cTipo+cFornNf+cLojFrn)
		P50->(MsUnLock())

		nRec := P50->(RECNO())

		//Dele��o NF
	ElseIf cOper == "I" .And. nOperac == 5

		cFilInt := aXml[1]:CFILREG
		cNumNf  := aXml[1]:CDOC
		cSerNf  := aXml[1]:CSERIE
		cFornNF := aXml[1]:CFORNECE
		cLojFrn := aXml[1]:CLOJA
		cIProc  := Dtos(date()) + " " + Time()
		cJson   := FwJsonSerialize(aXml)

		DbSelectArea("P50")
		Reclock("P50",.T.)
		P50->P50_FILIAL := cFilInt
		P50->P50_NUMNF  := cNumNF
		P50->P50_SERIE  := cSerNf
		P50->P50_FORNEC := cFornNF
		P50->P50_LOJA   := cLojFrn
		P50->P50_IPROC  := cIproc
		P50->P50_JSON   := cJson
		P50->P50_OPER   := "Dele��o"
		P50->(MsUnLock())

		nRec := P50->(RECNO())

		//Devolu��o Comum
	ElseIf cOper == "I" .And. nOperac == 1

		cFilInt := aXml[1]:CFILREG
		cNumNf  := aXml[1]:CDOC
		cSerNf  := aXml[1]:CSERIE
		cFornNF := aXml[1]:CFORNECE
		cLojFrn := aXml[1]:CLOJA
		cIProc  := Dtos(date()) + " " + Time()
		cJson   := FwJsonSerialize(aXml)

		DbSelectArea("P50")
		Reclock("P50",.T.)
		P50->P50_FILIAL := cFilInt
		P50->P50_NUMNF  := cNumNF
		P50->P50_SERIE  := cSerNf
		P50->P50_FORNEC := cFornNF
		P50->P50_LOJA   := cLojFrn
		P50->P50_IPROC  := cIproc
		P50->P50_JSON   := cJson
		P50->P50_OPER   := "Devolu��o Comum"
		P50->(MsUnLock())

		nRec := P50->(RECNO())

		//Cancelamento devlu��o comum
	ElseIf cOper == "I" .And. nOperac == 2

		cFilInt := aXml[1]:CFILREG
		cNumNf  := aXml[1]:CDOC
		cSerNf  := aXml[1]:CSERIE
		cFornNF := aXml[1]:CFORNECE
		cLojFrn := aXml[1]:CLOJA
		cIProc  := Dtos(date()) + " " + Time()
		cJson   := FwJsonSerialize(aXml)

		DbSelectArea("P50")
		Reclock("P50",.T.)
		P50->P50_FILIAL := cFilInt
		P50->P50_NUMNF  := cNumNF
		P50->P50_SERIE  := cSerNf
		P50->P50_FORNEC := cFornNF
		P50->P50_LOJA   := cLojFrn
		P50->P50_IPROC  := cIproc
		P50->P50_JSON   := cJson
		P50->P50_OPER   := "Cancelamento da devolu��o comum"
		P50->(MsUnLock())

		nRec := P50->(RECNO())

		//Devolu��o M�s fechado
	ElseIf cOper == "I" .And. nOperac == 4

		cFilInt := aXml[1]:CFILIALDOC
		cNumNf  := aXml[1]:CDOC
		cSerNf  := aXml[1]:CSERIE
		cFornNF := aXml[1]:CFORNECEDOR
		cLojFrn := aXml[1]:CLOJA
		cIProc  := Dtos(date()) + " " + Time()
		cJson   := FwJsonSerialize(aXml)

		DbSelectArea("P50")
		Reclock("P50",.T.)
		P50->P50_FILIAL := cFilInt
		P50->P50_NUMNF  := cNumNF
		P50->P50_SERIE  := cSerNf
		P50->P50_FORNEC := cFornNF
		P50->P50_LOJA   := cLojFrn
		P50->P50_IPROC  := cIproc
		P50->P50_JSON   := cJson
		P50->P50_OPER   := "Devolu��o de m�s fechado"
		P50->(MsUnLock())

		nRec := P50->(RECNO())

		//Cancelamento devolu��o de m�s fechado
	ElseIf cOper == "I" .And. nOperac == 6

		cFilInt := aXml[1]:CFILIALDOC
		cNumNf  := aXml[1]:CDOC
		cSerNf  := aXml[1]:CSERIE
		cFornNF := aXml[1]:CFORNECEDOR
		cLojFrn := aXml[1]:CLOJA
		cIProc  := Dtos(date()) + " " + Time()
		cJson   := FwJsonSerialize(aXml)

		DbSelectArea("P50")
		Reclock("P50",.T.)
		P50->P50_FILIAL := cFilInt
		P50->P50_NUMNF  := cNumNF
		P50->P50_SERIE  := cSerNf
		P50->P50_FORNEC := cFornNF
		P50->P50_LOJA   := cLojFrn
		P50->P50_IPROC  := cIproc
		P50->P50_JSON   := cJson
		P50->P50_OPER   := "Cancelamento da devolu��o de m�s fechado"
		P50->(MsUnLock())

		nRec := P50->(RECNO())

	ElseIf cOper == "A"
		DbSelectArea("P50")
		P50->(DbGoTo(nRec))

		Reclock("P50",.F.)

		P50->P50_FPROC := Dtos(date()) + " " + Time()
		P50->P50_STATUS := Iif(aInfo[2] == 1,"Ok","Erro")
		P50->P50_RET := aInfo[1]
		P50->P50_TEMPO := ElapTime( Right(AllTrim(P50->P50_IPROC),8), Right(AllTrim(P50->P50_FPROC),8))

		P50->(MsUnLock())
	EndIf

	RestArea(aArea)
	Return nRec

	//-------------------------------------------------------------------
	/*/{Protheus.doc} FCADP50()
	Tela de visualiza��o do LOG P50
	@author Lucas Miranda de Aguiar
	@since 23/11/2023
	@version 1.0
	Inicial
	@return NIL
	/*/
//-------------------------------------------------------------------
User Function FCADP50()

	Local oBrowse := FWmBrowse():New()

	Private cNomeLog  := "Log de integra��es NF"

	oBrowse:AddLegend("P50_STATUS=='Ok   '", "ENABLE" , "Integrado com sucesso!" )
	oBrowse:AddLegend("P50_STATUS=='Erro '", "DISABLE" , "Erro na integra��o!"  )
	oBrowse:AddLegend("P50_STATUS=='     '", "BR_AZUL"  , "Integra��o em andamento!" )

	oBrowse:SetAlias("P50")
	oBrowse:SetMenuDef("MSINTNFS")
	oBrowse:SetDescription("Log de integra��es de NFS")
	oBrowse:Activate()

	Return NIL

	//-------------------------------------------------------------------
	/*/{Protheus.doc} MenuDef()
	Constru��o do menu na rotina FCADP50
	@author Lucas Miranda de Aguiar
	@since 23/11/2023
	@version 1.0
	Inicial
	@return NIL
	/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	Local aFuncoes := {}
	Local aRels := {}
	Local aEscolha := {}

//	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.MSINTNFS" OPERATION 2  ACCESS 0 // Visualizar
//	ADD OPTION aRotina TITLE "Fun��es/Relat�rios" ACTION aEscolha OPERATION 4  ACCESS 0 // Visualizar
//	ADD OPTION aEscolha TITLE "Fun��es" ACTION aFuncoes OPERATION 4  ACCESS 0 // Visualizar
//	ADD OPTION aEscolha TITLE "Relat�rios" ACTION aRels OPERATION 4  ACCESS 0 // Visualizar
//	//Fun��es
//	ADD OPTION aFuncoes TITLE "Tempo m�dio de integra��o" ACTION 'Processa({||U_MSINTNFA()}, "Log de integra��es - NF")' OPERATION 4  ACCESS 0 // Visualizar
//	ADD OPTION aFuncoes TITLE "Status NF P12" ACTION 'Processa({||U_MSINTNFB()}, "Log de integra��es - NF")' OPERATION 4  ACCESS 0 // Visualizar
//	ADD OPTION aFuncoes TITLE "Visualizar documento emitido - Nota" ACTION 'Processa({||U_MSINTNFC()}, "Log de integra��es - NF")' OPERATION 4  ACCESS 0 // Visualizar
//	ADD OPTION aFuncoes TITLE "Visualizar documento emitido - T�tulo" ACTION 'Processa({||U_MSINTNFD()}, "Log de integra��es - NF")' OPERATION 4  ACCESS 0 // Visualizar
//
//
//
//
//	//Relat�rios
//	ADD OPTION aRels TITLE "Relat�rio de integra��es - Resumido"    ACTION 'Processa({||U_MSINTNFE()}, "Log de integra��es - NF")' OPERATION 4  ACCESS 0 // Visualizar
//	ADD OPTION aRels TITLE "Relat�rio de duplicidade na integra��o" ACTION 'Processa({||U_MSINTNFG()}, "Log de integra��es - NF")' OPERATION 4  ACCESS 0 // Visualizar
//	ADD OPTION aRels TITLE "Relat�rio do quantitativo de ingra��es por per�odo" ACTION 	'Processa({|| U_MSINTNFH()}, "Log de integra��es - NF")' OPERATION 4  ACCESS 0 // Visualizar
//


	aAdd(aRotina,{"Visualizar", "VIEWDEF.MSINTNFS"   ,0,2}) 
	aAdd(aRotina,{"Fun��es/Relat�rios", aEscolha  , 0 , 4}) 
	aAdd(aRotina,{"Fun��es", aFuncoes  , 0 , 4}) 
	aAdd(aRotina,{"Relat�rios", aRels  , 0 , 4}) 
	
	
	
	aAdd(aRotina,{"Tempo m�dio de integra��o",'Processa({||U_MSINTNFA()}, "Log de integra��es - NF")'  ,0,4}) 
	aAdd(aRotina,{"Status NF P12", 'Processa({||U_MSINTNFB()}, "Log de integra��es - NF")'  , 0 , 4}) 
	aAdd(aRotina,{"Visualizar documento emitido - Nota", 'Processa({||U_MSINTNFC()}, "Log de integra��es - NF")'  , 0 , 4}) 
	aAdd(aRotina,{"Visualizar documento emitido - T�tulo", 'Processa({||U_MSINTNFD()}, "Log de integra��es - NF")'  , 0 , 4}) 




	aAdd(aRotina,{"Relat�rio de integra��es - Resumido", 'Processa({||U_MSINTNFE()}, "Log de integra��es - NF")'  ,0,4}) 
	aAdd(aRotina,{"Relat�rio de duplicidade na integra��o",'Processa({||U_MSINTNFG()}, "Log de integra��es - NF")'  , 0 , 4}) 
	aAdd(aRotina,{"Relat�rio do quantitativo de ingra��es por per�odo", 'Processa({|| U_MSINTNFH()}, "Log de integra��es - NF")'   , 0 , 4}) 







	Return aRotina

	//-------------------------------------------------------------------
	/*/{Protheus.doc} ModelDef()
	Constru��o do modelo na rotina de LOG P50
	@author Lucas Miranda de Aguiar
	@since 23/11/2023
	@version 1.0
	Inicial
	@return NIL
	/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStru := FwFormStruct(1, "P50")


	oModel := MPFormModel():New('MXCADP50',,,)
	oModel:AddFields('P50MASTER', , oStru, , , )
	oModel:SetDescription('Log de integra��es de NFS')
	oModel:GetModel('P50MASTER'):SetDescription('Log de integra��es de NFS')
	oModel:GetModel("P50MASTER"):SetPrimaryKey({"P50_FILIAL", "P50_NUMNF", "P50_SERIE","P50_FORNEC","P50_LOJA"})

	Return oModel

	//-------------------------------------------------------------------
	/*/{Protheus.doc} ModelDef()
	Constru��o da view na rotina de LOG P50
	@author Lucas Miranda de Aguiar
	@since 23/11/2023
	@version 1.0
	Inicial
	@return NIL
	/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   	:= FWLoadModel('MSINTNFS')
	Local oStru 	:= FwFormStruct(2, "P50")
	Local oView		:= Nil

	oView := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField('VIEW_P50', oStru, 'P50MASTER')
	oView:CreateHorizontalBox('TELA' , 100)
	oView:SetOwnerView('VIEW_P50', 'TELA')

	Return oView


	//-------------------------------------------------------------------
	/*/{Protheus.doc} MSINTNFB()
	Rotina para verificar situa��o do t�tulo no P12
	@author Lucas Miranda de Aguiar
	@since 23/11/2023
	@version 1.0
	Inicial
	@return NIL
	/*/
//-------------------------------------------------------------------
User Function MSINTNFB()

	Local aArea := GetArea()
	Local cRet := ""
	DbSelectArea("SE2")
	SE2->(DbSetOrder(1))

	If SE2->(DbSeek(P50->(P50_FILIAL+P50_SERIE+P50_NUMNF+P50_PARCEL+P50_TIPO+P50_FORNEC+P50_LOJA)))

		IF !Empty(SE2->E2_BAIXA)
			cRet := "Titulo Baixado."
		ElseIf !Empty(SE2->E2_NUMBOR)
			cRet := "Titulo em border�."
		Else
			cRet := "Titulo em aberto."
		EndIf
	Else
		cRet := "Titulo exclu�do."
	EndIf

	FWAlertInfo(cRet,cNomeLog)
	RestArea(aArea)
	Return


	//-------------------------------------------------------------------
	/*/{Protheus.doc} fGetOper()
	Rotina para verificar se o t�tulo � inclus�o ou opera��o na hora de gravar no LOG
	@author Lucas Miranda de Aguiar
	@since 23/11/2023
	@version 1.0
	Inicial
	@return NIL
	/*/
//-------------------------------------------------------------------
Static Function fGetOper(cChave)

	Local aArea := GetArea()
	Local cRet := ""

	DbSelectArea("SE2")
	SE2->(DbSetOrder(1))

	If SE2->(DbSeek(cChave))
		cRet := "Altera��o"
	Else
		cRet := "Inclus�o"
	EndIf

	RestArea(aArea)
	Return cRet


	//-------------------------------------------------------------------
	/*/{Protheus.doc} MSINTNFA()
	Rotina do menu para verificar o tempo de integra��o em um determinado range de data.
	@author Lucas Miranda de Aguiar
	@since 23/11/2023
	@version 1.0
	Inicial
	@return NIL
	/*/
//-------------------------------------------------------------------
User Function MSINTNFA()


	Local cQry := ""
	Local cAliasT := GetNextAlias()
	Local cTempo := ""
	Local aPergs   := {}
	Local dDataDe  := Date()
	Local cData   := ""




	aAdd(aPergs, {1, "Data",  dDataDe,  "", ".T.", "", ".T.", 80,  .F.})


	If ParamBox(aPergs, "Informe a data desejada")

		If Empty(MV_PAR01)
			Return
		EndIf
		dDataDe := MV_PAR01
		cData := DtoS(dDataDe)
		cQry += " SELECT AVG(TO_NUMBER(SUBSTR(P50_TEMPO, 1, 2))*3600 + TO_NUMBER(SUBSTR(P50_TEMPO, 4, 2))*60 + TO_NUMBER(SUBSTR(P50_TEMPO, 7, 2))) AS T, COUNT(*) AS TOTAL FROM "
		cQry += RETSQLNAME("P50")
		cQry += " WHERE D_E_L_E_T_ = ' ' "
		cQry += " AND P50_IPROC >= '"+cData+ " 00:00:00' "
		cQry += " AND P50_FPROC <= '"+cData+ " 23:59:59' "
		cQry += " AND P50_TEMPO <> ' ' "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasT,.T.,.T.)

		If !(cAliasT)->(EOF())
			cTempo := "O tempo m�dio de integra��o � de " +cVALTOCHAR(ROUND((cALIAST)->T,2)) + " segundos. " + CRLF
			ctempo += "Para " + cValToChar((cAliasT)->TOTAL) + " nota(s) integrada(s)."
			FWAlertInfo(cTempo,cNomeLog)
		Else
			FWAlertInfo("Ainda n�o existem documentos integrados na data selecionada.",cNomeLog)
		EndIf
	EndIf
	Return


	//-------------------------------------------------------------------
	/*/{Protheus.doc} MSINTNFC()
	Rotina do menu para exibir o documento selecionado na tela, como se estivesse visualizando no documento de entrada.
	@author Lucas Miranda de Aguiar
	@since 23/11/2023
	@version 1.0
	Inicial
	@return NIL
	/*/
//-------------------------------------------------------------------
User Function MSINTNFC()

	Private aRotina := {}

	DbSelectArea("SF1")
	SF1->(DbSetOrder(1))

	If SF1->(DBSEEK(P50->(P50_FILIAL+P50_NUMNF+P50_SERIE+P50_FORNEC+P50_LOJA)))
		aAdd(aRotina,{OemToAnsi("Pesquisar"), "AxPesqui"   , 0 , 1, 0, .F.}) 		//"Pesquisar"
		aAdd(aRotina,{OemToAnsi("Visualizar"), "A103NFiscal", 0 , 2, 0, nil}) 		//"Visualizar"
		aAdd(aRotina,{OemToAnsi("Incluir"), "A103NFiscal", 0 , 3, 0, nil}) 		//"Incluir"
		aAdd(aRotina,{OemToAnsi("Classificar"), "A103NFiscal", 0 , 4, 0, nil}) 		//"Classificar"
		aAdd(aRotina,{OemToAnsi("Excluir"), "A103NFiscal", 3 , 5, 0, nil})		//"Excluir"






		A103NFiscal("SF1",SF1->(RecNo()),2)
	else
		FWAlertInfo("A nota n�o est� cadastrada no sistema.",cNomeLog)
	EndIf
	Return


	//-------------------------------------------------------------------
	/*/{Protheus.doc} MSINTNFD()
	Rotina do menu para exibir o documento selecionado na tela, como se estivesse visualizando no contas a pagar.
	@author Lucas Miranda de Aguiar
	@since 23/11/2023
	@version 1.0
	Inicial
	@return NIL
	/*/
//-------------------------------------------------------------------
User Function MSINTNFD()

	Local cAlias := "SE2"

	DbSelectArea("SE2")
	SE2->(DbSetOrder(1))

	If SE2->(DbSeek(P50->(P50_FILIAL+P50_SERIE+P50_NUMNF+P50_PARCEL+P50_TIPO+P50_FORNEC+P50_LOJA)))
		xFa050Vis( cAlias, SE2->(RECNO()),2)
	else
		FWAlertInfo("A nota n�o est� cadastrada no sistema.",cNomeLog)
	EndIf
	Return




	Static Function xFa050Vis( cAlias As Character, nReg As Numeric, nOpc As Numeric,aRotAuto As Array, nOpcion As Numeric, nOpcAuto As Numeric, bExecuta As Block, aDadosBco As Array, lExibeLanc As Logical,;
	lOnline As Logical, aDadosCTB As Array, aTitPrv As Array, lMsBlQl As Logical, lPaMovBco As Logical, aVAAutP As Array, cUUIDBS As Character )

	Local aBut050  As Array
	LOCAL nOpcA    As Numeric
	Local lF050VIS As Logical

	PRIVATE aRatAFR		As Array
	Private aSE2FI2		As Array
	Private aCposAlter  As Array
	PRIVATE bPMSDlgFI	As Block
	PRIVATE _Opc 		As Numeric

	PRIVATE cCadastro 	:= STR0007 // "Contas a Pagar"
	PRIVATE cBancoAdt	:= CriaVar("A6_COD")
	PRIVATE cAgenciaAdt	:= CriaVar("A6_AGENCIA")
	PRIVATE cNumCon	 	:= CriaVar("A6_NUMCON")
	PRIVATE nMoedAdt	:= CriaVar("A6_MOEDA")
	PRIVATE cChequeAdt	:= CriaVar("EF_NUM")
	PRIVATE cHistor		:= CriaVar("EF_HIST")
	PRIVATE cBenef		:= CriaVar("EF_BENEF")
	PRIVATE lAltera		:= .F.
	PRIVATE nMoeda 		:= Int(Val(GetMv("MV_MCUSTO")))
	If Type("lWserver") == "U"
		PRIVATE cMarca 		:= GetMark( )
	EndIf
	PRIVATE aTELA[0][0]
	PRIVATE aGETS[0]
	PRIVATE cPictHist   := ""
	PRIVATE lVerifyBlq  := .F.
	PRIVATE cLote       := ""
	PRIVATE nQtdTot     := 0		//Utilizado no Rateio Externo do SIGACTB.
	PRIVATE aItensCTB   := Iif(aDadosCTB <> Nil, aDadosCTB, {})
	PRIVATE aItnTitPrv  := Iif(aTitPrv   <> Nil, aTitPrv  , {})
	PRIVATE cItnUuidBs  := Iif(cPaisLoc = "RUS" .AND. CUUIDBS <> Nil, cUUIDBS, "") //cItnUuidBs - UUID Bank statment insinde FINA050
	PRIVATE __LLOCBRA   := .T.
	DEFAULT aDadosBco   := {}
	DEFAULT lMsBlQl     := .T.
	DEFAULT lPaMovBco	:= .T.
	DEFAULT cUUIDBS	    := ""

	Default __lIntPFS  := SuperGetMv("MV_JURXFIN",.T.,.F.) //Integra��o do Financeiro com o Juridico(Habilitado = .T.)
	Default __lTemMR   := (FindFunction("FTemMotor") .and. FTemMotor())

	nOpcA    := 0
	aBut050  := {}
	lF050VIS := Existblock("F050VIS")

	aRatAFR		:= {}
	bPMSDlgFI	:= {||PmsDlgFI(2,M->E2_PREFIXO,M->E2_NUM,M->E2_PARCELA,M->E2_TIPO,M->E2_FORNECE,M->E2_LOJA)}
	_Opc 		:= nOpc
	aSE2FI2		:=	{} // Utilizada para gravacao das justificativas
	aCposAlter  :=  {}

	dbSelectArea("SA2")
	dbSeek(cFilial+SE2->E2_FORNECE+SE2->E2_LOJA)

	//Botoes adicionais na EnchoiceBar
	aBut050 := fa050BAR('SE2->E2_PROJPMS == "1"')

	///Projeto
	//inclusao do botao Posicao
	AADD(aBut050, {"HISTORIC", {|| Fc050Con() }, STR0204}) //"Posicao"

	//inclusao do botao Rastreamento
	AADD(aBut050, {"HISTORIC", {|| Fin250Pag(2) }, STR0205}) //"Rastreamento"

	If __lIntPFS .And. FindFunction("JURA246") .And. !(SE2->E2_TIPO $ MVTAXA+"|"+MVINSS+"|"+MVISS+"|"+MVTXA+"|SES|INA|IRF|PIS|COF|CSL")
		Aadd(aBut050,{"", {|| JURA246(1) }, "Detalhe / Desdobramentos"}) //"Detalhe / Desdobramentos" (M�dulo SIGAPFS)
	EndIF

	//Motor de reten��es
	If __lTemMR
		AADD(aBut050, {"HISTORIC", {|| FINCRET('SE2') }, "Consulta de Reten��es"}) //'Consulta de Reten��es'
	EndIF

	// integra��o com o PMS
	If IntePMS() .And. SE2->E2_PROJPMS == "1"
		SetKey(VK_F10, {|| Eval(bPMSDlgFI)})
	EndIf
	dbSelectArea(cAlias)
	//RegToMemory("SE2",.T.,,.F.,FunName())
	nOpca := AxVisual(cAlias,nReg,nOpc,,4,SA2->A2_NOME,"FA050MCPOS",aBut050)
	If lF050VIS		// ponto na saida da visualizacao
		Execblock("F050VIS",.f.,.f.)
	Endif

	If IntePMS() .And. SE2->E2_PROJPMS == "1"
		SetKey(VK_F10, Nil)
	EndIf
	If __lLocBRA
		F986LimpaVar() //Limpa as variaveis estaticas - Complemento de Titulo
	EndIf

	Return


	//-------------------------------------------------------------------
	/*/{Protheus.doc} MSINTNFE()
	Rotina do menu para exibir o relat�rio de integra��es resumido
	@author Lucas Miranda de Aguiar
	@since 23/11/2023
	@version 1.0
	Inicial
	@return NIL
	/*/
//-------------------------------------------------------------------
User Function MSINTNFE()

	Local aArea        := GetArea()
	Local oFWMsExcel
	Local oExcel
	Local cArquivo    := GetTempPath()+'RELNF'+DTOS(DATE())+'.xml'
	Local cQry := ""
	Local cAliasRel := GetNextAlias()
	Local aPergs   := {}
	Local dDataDe  := Date()
	Local dDataAt  := Date()
	Local cFilRelI    := Space(08)
	Local cNfRelI     := Space(09)
	Local cSerieRelI  := Space(03)
	Local cFornRelI := Space(06)
	Local cLojaRelI   := Space(02)
	Local cFilRelF    := Space(08)
	Local cNfRelF     := Space(09)
	Local cSerieRelF  := Space(03)
	Local cFornRelF := Space(06)
	Local cLojaRelF   := Space(02)
	Local cDataI      := ""
	Local cDataF      := ""


	aAdd(aPergs, {1, "Data De",  dDataDe,  "", ".T.", "", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Data At�", dDataAt,  "", ".T.", "", ".T.", 80,  .F.})

	aAdd(aPergs, {1, "Filial De",  cFilRelI,  "", ".T.", "SM0", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Filial At�", cFilRelF,  "", ".T.", "SM0", ".T.", 80,  .F.})

	aAdd(aPergs, {1, "Num Nf De",     cNfRelI, "", ".T.", "",    ".T.", 80, .F.})
	aAdd(aPergs, {1, "Num Nf At�",     cNfRelF, "", ".T.", "",    ".T.", 80, .F.})

	aAdd(aPergs, {1, "Da S�rie",     cSerieRelI, "", ".T.", "",    ".T.", 80, .F.})
	aAdd(aPergs, {1, "At� a S�rie",     cSerieRelF, "", ".T.", "",    ".T.", 80, .F.})

	aAdd(aPergs, {1, "Do Fornecedor",     cFornRelI, "", ".T.", "",    ".T.", 80, .F.})
	aAdd(aPergs, {1, "At� o Fornecedor",     cFornRelF, "", ".T.", "",    ".T.", 80, .F.})

	aAdd(aPergs, {1, "Da Loja",     cLojaRelI, "", ".T.", "",    ".T.", 80, .F.})
	aAdd(aPergs, {1, "At� a Loja",     cLojaRelF, "", ".T.", "",    ".T.", 80, .F.})

	If ParamBox(aPergs, "Informe os par�metros")

		If (Empty(MV_PAR01) .Or. Empty(MV_PAR02))
			FwAlertError("Os par�metros de data s�o obrigat�rios!!",cNomeLog)
			Return
		EndIf

		cFilRelI    := MV_PAR03
		cNfRelI     := MV_PAR05
		cSerieRelI  := MV_PAR07
		cFornRelI := MV_PAR09
		cLojaRelI   := MV_PAR11 
		cFilRelF    := MV_PAR04
		cNfRelF     := MV_PAR06
		cSerieRelF  := MV_PAR08
		cFornRelF := MV_PAR10
		cLojaRelF   := MV_PAR12
		cDataI      := DtoS(MV_PAR01)
		cDataF      := DtoS(MV_PAR02)


		cQry += " WITH Recentes AS ( "
		cQry += " SELECT "
		cQry += " P50_FILIAL, "
		cQry += " P50_NUMNF, "
		cQry += " P50_SERIE, "
		cQry += " P50_FORNEC, "
		cQry += " P50_LOJA, "
		cQry += " MAX(R_E_C_N_O_) AS Max_RECNO "
		cQry += " FROM "
		cQry += RetSqlName("P50")
		cQry += " WHERE
		cQry += " D_E_L_E_T_ = ' ' AND P50_FPROC BETWEEN '"+cDataI+ " 00:00:00' AND '"+cDataF+" 23:59:59'
		cQry += " GROUP BY "
		cQry += " P50_FILIAL, "
		cQry += " P50_NUMNF, "
		cQry += " P50_SERIE, "
		cQry += " P50_FORNEC, "
		cQry += " P50_LOJA) "

		cQry += " SELECT P.P50_FILIAL, P.P50_NUMNF, P.P50_SERIE, P.P50_FORNEC, P.P50_LOJA, COUNT(*) AS TOTAL, "
		cQry += " MAX(P.P50_OPER) KEEP (DENSE_RANK LAST ORDER BY P.R_E_C_N_O_) AS RECENTE, "
		cQry += " MAX(P.P50_FPROC) KEEP (DENSE_RANK LAST ORDER BY P.R_E_C_N_O_) AS DATAF, "
		cQry += " MAX(P.P50_STATUS) KEEP (DENSE_RANK LAST ORDER BY P.R_E_C_N_O_) AS STATUS FROM "
		cQry += RetSqlName("P50") + " P "
		cQry += " JOIN Recentes R ON P.P50_FILIAL = R.P50_FILIAL "
		cQry += " AND P.P50_NUMNF = R.P50_NUMNF "
		cQry += " AND P.P50_SERIE = R.P50_SERIE "
		cQry += " AND P.P50_FORNEC = R.P50_FORNEC "
		cQry += " AND P.P50_LOJA = R.P50_LOJA "
		cQry += " WHERE P.D_E_L_E_T_ = ' ' AND P.P50_FPROC BETWEEN '"+cDataI+ " 00:00:00' AND '"+cDataF+" 23:59:59'"

		cQry += " AND P.P50_FILIAL BETWEEN '"+cFilRelI+"' AND '"+cFilRelF+"'"
		cQry += " AND P.P50_NUMNF  BETWEEN '"+cNfRelI+"' AND '"+cNfRelF+"'"
		cQry += " AND P.P50_SERIE  BETWEEN '"+cSerieRelI+"' AND '"+cSerieRelF+"'"
		cQry += " AND P.P50_FORNEC BETWEEN '"+cFornRelI+"' AND '"+cFornRelF+"'"
		cQry += " AND P.P50_LOJA   BETWEEN '"+cLojaRelI+"' AND '"+cLojaRelF+"'"
		cQry += " GROUP BY P.P50_FILIAL, P.P50_NUMNF, P.P50_SERIE, P.P50_FORNEC, P.P50_LOJA "



		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasRel,.T.,.T.)

		If !(cAliasRel)->(EOF())
			//Criando o objeto que ir� gerar o conte�do do Excel
			oFWMsExcel := FWMSExcel():New()



			oFWMsExcel:AddworkSheet("Relat�rio de NFS resumido")
			//Criando a Tabela
			oFWMsExcel:AddTable("Relat�rio de NFS resumido","Notas Fiscais")
			oFWMsExcel:AddColumn("Relat�rio de NFS resumido","Notas Fiscais","Filial",1)
			oFWMsExcel:AddColumn("Relat�rio de NFS resumido","Notas Fiscais","N�mero da NF",1)
			oFWMsExcel:AddColumn("Relat�rio de NFS resumido","Notas Fiscais","S�rie da NF",1)
			oFWMsExcel:AddColumn("Relat�rio de NFS resumido","Notas Fiscais","Fornecedor",1)
			oFWMsExcel:AddColumn("Relat�rio de NFS resumido","Notas Fiscais","Loja",1)
			oFWMsExcel:AddColumn("Relat�rio de NFS resumido","Notas Fiscais","Quantidade de integra��es",1)
			oFWMsExcel:AddColumn("Relat�rio de NFS resumido","Notas Fiscais","Ultima opera��o",1)
			oFWMsExcel:AddColumn("Relat�rio de NFS resumido","Notas Fiscais","Data da �ltima opera��o",1)
			oFWMsExcel:AddColumn("Relat�rio de NFS resumido","Notas Fiscais","Status da �ltima opera��o",1)
			//Criando as Linhas... Enquanto n�o for fim da query
			(cAliasRel)->(DbGoTop())
			While !((cAliasRel)->(EoF()))
				oFWMsExcel:AddRow("Relat�rio de NFS resumido","Notas Fiscais",{;
				(cAliasRel)->P50_FILIAL,;
				(cAliasRel)->P50_NUMNF,;
				(cAliasRel)->P50_SERIE,;
				(cAliasRel)->P50_FORNEC,;
				(cAliasRel)->P50_LOJA,;
				(cAliasRel)->TOTAL,;
				(cAliasRel)->RECENTE,;
				(cAliasRel)->DATAF,;
				(cAliasRel)->STATUS;
				})

				//Pulando Registro
				(cAliasRel)->(DbSkip())
			EndDo

			//Ativando o arquivo e gerando o xml
			oFWMsExcel:Activate()
			oFWMsExcel:GetXMLFile(cArquivo)

			//Abrindo o excel e abrindo o arquivo xml
			// oExcel := MsExcel():New()             //Abre uma nova conex�o com Excel
			// oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
			// oExcel:SetVisible(.T.)                 //Visualiza a planilha
			// oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas
			ShellExecute("open",cArquivo,"","",1)	
		Else
			FWAlertInfo("Ainda n�o existem documentos integrados na data selecionada.",cNomeLog)
		EndIf

	EndIf
	RestArea(aArea)
	Return



	//-------------------------------------------------------------------
	/*/{Protheus.doc} MSINTNFG()
	Rotina do menu para exibir o relat�rio de notas integradas com duplicidade.
	@author Lucas Miranda de Aguiar
	@since 23/11/2023
	@version 1.0
	Inicial
	@return NIL
	/*/
//-------------------------------------------------------------------
User Function MSINTNFG()

	Local aArea        := GetArea()
	Local oFWMsExcel
	Local oExcel
	Local cArquivo    := GetTempPath()+'RELDUPNF'+DTOS(DATE())+'.xml'
	Local cQry := ""
	Local cAliasRel := GetNextAlias()
	Local aPergs   := {}
	Local dDataDe  := Date()
	Local dDataAt  := Date()
	Local cDataI      := ""
	Local cDataF      := ""
	Local nX 		  := 0
	Local cChave 	  := ""
	Local cParte 	  := ""


	aAdd(aPergs, {1, "Data De",  dDataDe,  "", ".T.", "", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Data At�", dDataAt,  "", ".T.", "", ".T.", 80,  .F.})

	If ParamBox(aPergs, "Informe os par�metros")

		If (Empty(MV_PAR01) .Or. Empty(MV_PAR02))
			FWAlertError("Os par�metros de data s�o obrigat�rios!!",cNomeLog)
			Return
		EndIf

		cDataI      := DtoS(MV_PAR01)
		cDataF      := DtoS(MV_PAR02)


		cQry += " SELECT P50_FILIAL, P50_NUMNF, P50_SERIE, P50_FORNEC, P50_LOJA, COUNT(*) AS QTD_ENVIOS "
		cQry += " ,PARTE1, PARTE2, PARTE3, PARTE4,PARTE5,PARTE6,PARTE7,PARTE8,PARTE9,PARTE10,PARTE11,PARTE12 "
		cQry += " FROM "
		cQry += " (SELECT P50_FILIAL, P50_NUMNF, P50_SERIE, P50_FORNEC, P50_LOJA,P50_OPER, "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 1, 1000) AS VARCHAR2(1000))  AS parte1, "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 1001, 1000) AS VARCHAR2(1000)) AS parte2, "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 2001, 1000) AS VARCHAR2(1000)) AS parte3, "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 3001, 1000) AS VARCHAR2(1000)) parte4, "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 4001, 1000) AS VARCHAR2(1000)) parte5, "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 5001, 1000) AS VARCHAR2(1000)) parte6, "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 6001, 1000) AS VARCHAR2(1000)) parte7, "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 7001, 1000) AS VARCHAR2(1000)) parte8,  "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 8001, 1000) AS VARCHAR2(1000)) parte9 , "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 9001, 1000) AS VARCHAR2(1000)) parte10  , "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 10001, 1000) AS VARCHAR2(1000)) parte11  , "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 11001, 1000) AS VARCHAR2(1000)) parte12,  "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 12001, 1000) AS VARCHAR2(1000)) parte13  , "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 13001, 1000) AS VARCHAR2(1000)) parte14  , "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 14001, 1000) AS VARCHAR2(1000)) parte15  , "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 15001, 1000) AS VARCHAR2(1000)) parte16  , "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 16001, 1000) AS VARCHAR2(1000)) parte17  , "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 17001, 1000) AS VARCHAR2(1000)) parte18  , "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 18001, 1000) AS VARCHAR2(1000)) parte19  , "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 19001, 1000) AS VARCHAR2(1000)) parte20  , "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 20001, 1000) AS VARCHAR2(1000)) parte21  , "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 21001, 1000) AS VARCHAR2(1000)) parte22  , "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 22001, 1000) AS VARCHAR2(1000)) parte23  , "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 23001, 1000) AS VARCHAR2(1000)) parte24  , "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 24001, 1000) AS VARCHAR2(1000)) parte25  , "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 25001, 1000) AS VARCHAR2(1000)) parte26  , "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 26001, 1000) AS VARCHAR2(1000)) parte27  , "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 27001, 1000) AS VARCHAR2(1000)) parte28  , "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 28001, 1000) AS VARCHAR2(1000)) parte29  , "
		cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 29001, 1000) AS VARCHAR2(1000)) parte30   "
		cQry += " FROM " + RetSqlName("P50") + " P50 "
		cQry += " WHERE P50.D_E_L_E_T_ = ' ' "
		cQry += " AND P50.P50_STATUS = 'Ok' "
		cQry += " AND P50.P50_IPROC >= '" +cDataI+ " 00:00:00' AND P50.P50_IPROC <= '"+cDataF+" 23:59:59')"
		cQry += " HAVING COUNT(*) > 1 "
		cQry += " GROUP BY P50_FILIAL, P50_NUMNF, P50_SERIE, P50_FORNEC, P50_LOJA, PARTE1, PARTE2, PARTE3, PARTE4,PARTE5,PARTE6,PARTE7,PARTE8,PARTE9,PARTE10,PARTE11,PARTE12,PARTE13,PARTE14,PARTE15,PARTE16,PARTE17,PARTE18,PARTE19,PARTE20,PARTE21,PARTE22,PARTE23,PARTE24,PARTE25,PARTE26,PARTE27,PARTE28,PARTE29,PARTE30"
		cQry += " ORDER BY P50_FILIAL, P50_NUMNF, P50_SERIE, P50_FORNEC, P50_LOJA "



		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasRel,.T.,.T.)

		If !(cAliasRel)->(EOF())
			//Criando o objeto que ir� gerar o conte�do do Excel
			oFWMsExcel := FWMSExcel():New()



			oFWMsExcel:AddworkSheet("Relat�rio de NFS resumido")
			//Criando a Tabela
			oFWMsExcel:AddTable("Relat�rio de NFS resumido","Notas Fiscais")
			oFWMsExcel:AddColumn("Relat�rio de NFS resumido","Notas Fiscais","Filial",1)
			oFWMsExcel:AddColumn("Relat�rio de NFS resumido","Notas Fiscais","N�mero da NF",1)
			oFWMsExcel:AddColumn("Relat�rio de NFS resumido","Notas Fiscais","S�rie da NF",1)
			oFWMsExcel:AddColumn("Relat�rio de NFS resumido","Notas Fiscais","Fornecedor",1)
			oFWMsExcel:AddColumn("Relat�rio de NFS resumido","Notas Fiscais","Loja",1)
			oFWMsExcel:AddColumn("Relat�rio de NFS resumido","Notas Fiscais","Quantidade de envios",1)
			oFWMsExcel:AddColumn("Relat�rio de NFS resumido","Notas Fiscais","Informa��o sobre envios",1)
			oFWMsExcel:AddColumn("Relat�rio de NFS resumido","Notas Fiscais","Json",1)
			//Criando as Linhas... Enquanto n�o for fim da query
			(cAliasRel)->(DbGoTop())
			While !((cAliasRel)->(EoF()))

				For nX := 1 To 12
					cParte := "PARTE"+cValToChar(nX)
					cChave := cChave + cParte
				Next nX

				cChave := (cAliasRel)->(PARTE1+PARTE2+PARTE3+PARTE4+PARTE5+PARTE6+PARTE7+PARTE8+PARTE9+PARTE10+PARTE11+PARTE12)
				oFWMsExcel:AddRow("Relat�rio de NFS resumido","Notas Fiscais",{;
				(cAliasRel)->P50_FILIAL,;
				(cAliasRel)->P50_NUMNF,;
				(cAliasRel)->P50_SERIE,;
				(cAliasRel)->P50_FORNEC,;
				(cAliasRel)->P50_LOJA,;
				(cAliasRel)->QTD_ENVIOS,;
				fInfoEnvs(cChave,cDataI,cDataF,(cAliasRel)->(P50_FILIAL),(cAliasRel)->(P50_NUMNF),(cAliasRel)->(P50_SERIE),(cAliasRel)->(P50_FORNEC),(cAliasRel)->(P50_LOJA)),;
				cChave;
				})

				//Pulando Registro
				(cAliasRel)->(DbSkip())
			EndDo

			//Ativando o arquivo e gerando o xml
			oFWMsExcel:Activate()
			oFWMsExcel:GetXMLFile(cArquivo)

			//Abrindo o excel e abrindo o arquivo xml
			// oExcel := MsExcel():New()             //Abre uma nova conex�o com Excel
			// oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
			// oExcel:SetVisible(.T.)                 //Visualiza a planilha
			// oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas
			ShellExecute("open",cArquivo,"","",1)	

		Else
			FWAlertInfo("N�o existem integra��es com duplicidade no per�odo selecionado.",cNomeLog)
		EndIf

	EndIf
	RestArea(aArea)
	Return

	//-------------------------------------------------------------------
	/*/{Protheus.doc} fInfoEnvs()
	Rotina do menu para exibir o relat�rio de notas integradas com duplicidade.
	@author Lucas Miranda de Aguiar
	@since 23/11/2023
	@version 1.0
	Inicial
	@return NIL
	/*/
//-------------------------------------------------------------------
Static Function fInfoEnvs(cChave,cDataI,cDataF,cFil,cNf,cSerie,cFornec,cLoja)


	Local cQry := ""
	Local cTabTemp := GetNextAlias()
	Local cRet := ""

	Default cChave := ""
	Default cDataI := ""
	Default cDataF := ""



	cQry += " SELECT  "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 1, 1000) AS VARCHAR2(1000))  AS parte1, "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 1001, 1000) AS VARCHAR2(1000)) AS parte2, "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 2001, 1000) AS VARCHAR2(1000)) AS parte3, "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 3001, 1000) AS VARCHAR2(1000)) parte4, "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 4001, 1000) AS VARCHAR2(1000)) parte5, "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 5001, 1000) AS VARCHAR2(1000)) parte6, "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 6001, 1000) AS VARCHAR2(1000)) parte7, "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 7001, 1000) AS VARCHAR2(1000)) parte8,  "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 8001, 1000) AS VARCHAR2(1000)) parte9 , "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 9001, 1000) AS VARCHAR2(1000)) parte10  , "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 10001, 1000) AS VARCHAR2(1000)) parte11  , "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 11001, 1000) AS VARCHAR2(1000)) parte12,  "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 12001, 1000) AS VARCHAR2(1000)) parte13  , "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 13001, 1000) AS VARCHAR2(1000)) parte14  , "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 14001, 1000) AS VARCHAR2(1000)) parte15  , "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 15001, 1000) AS VARCHAR2(1000)) parte16  , "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 16001, 1000) AS VARCHAR2(1000)) parte17  , "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 17001, 1000) AS VARCHAR2(1000)) parte18  , "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 18001, 1000) AS VARCHAR2(1000)) parte19  , "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 19001, 1000) AS VARCHAR2(1000)) parte20  , "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 20001, 1000) AS VARCHAR2(1000)) parte21  , "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 21001, 1000) AS VARCHAR2(1000)) parte22  , "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 22001, 1000) AS VARCHAR2(1000)) parte23  , "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 23001, 1000) AS VARCHAR2(1000)) parte24  , "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 24001, 1000) AS VARCHAR2(1000)) parte25  , "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 25001, 1000) AS VARCHAR2(1000)) parte26  , "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 26001, 1000) AS VARCHAR2(1000)) parte27  , "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 27001, 1000) AS VARCHAR2(1000)) parte28  , "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 28001, 1000) AS VARCHAR2(1000)) parte29  , "
	cQry += " CAST(SUBSTR(BLOB2CHAR(P50_JSON), 29001, 1000) AS VARCHAR2(1000)) parte30,   "
	cQry += "  ROW_NUMBER() OVER (ORDER BY P50.P50_IPROC) AS LINHA, R_E_C_N_O_ AS RECNO, P50.* FROM "+RetSqlName("P50")+ " P50 " + CRLF
	cQry += " WHERE P50.D_E_L_E_T_ = ' ' " + CRLF
	cQry += " AND P50.P50_STATUS = 'Ok' " + CRLF
	cQry += " AND P50.P50_IPROC >= '" +cDataI+ " 00:00:00' AND P50.P50_IPROC <= '"+cDataF+" 23:59:59'" + CRLF
	cQry += " AND P50.P50_FILIAL = '" +cFil+ " '"
	cQry += " AND P50.P50_NUMNF = '" +cNF+ " '"
	cQry += " AND P50.P50_SERIE = '" +cSerie+ " '"
	cQry += " AND P50.P50_FORNEC = '" +cFornec+ " '"
	cQry += " AND P50.P50_LOJA = '" +cLoja+ " '"
	cQry += " ORDER BY P50_IPROC "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cTabTemp,.T.,.T.)

	While !((cTabTemp)->(EoF()))

		If AllTrim((cTabTemp)->(PARTE1+PARTE2+PARTE3+PARTE4+PARTE5+PARTE6+PARTE7+PARTE8+PARTE9+PARTE10+PARTE11+PARTE12+PARTE13+PARTE14+PARTE15+PARTE16+PARTE17+PARTE18+PARTE19+PARTE20+PARTE21+PARTE22+PARTE23+PARTE24+PARTE25+PARTE26+PARTE27+PARTE28+PARTE29+PARTE30)) == Alltrim(cChave)
			cRet += cValToChar((cTabTemp)->LINHA) + "� envio - Data/Hora: "+(cTabTemp)->P50_IPROC+ " - Tempo de integra��o: "+(cTabTemp)->P50_TEMPO+ " Opera��o: "+(cTabTemp)->P50_OPER+ " RECNO na tabela de LOG: "+ cValToChar((cTabTemp)->RECNO) + " |"
		EndIf
		(cTabTemp)->(DbSkip())
	EndDo


	Return cRet



	//-------------------------------------------------------------------
	/*/{Protheus.doc} MSINTNFH()
	Rotina do menu para exibir o relat�rio com o quantitativo de integra��es no per�odo selecionado.
	@author Lucas Miranda de Aguiar
	@since 23/11/2023
	@version 1.0
	Inicial
	@return NIL
	/*/
//-------------------------------------------------------------------
User Function MSINTNFH()

	Local aArea        := GetArea()
	Local oFWMsExcel
	Local oExcel
	Local cArquivo    := GetTempPath()+'RELQTINT'+DTOS(DATE())+'.xml'
	Local cQry := ""
	Local cAliasRel := GetNextAlias()
	Local aPergs   := {}
	Local dDataDe  := Date()
	Local dDataAt  := Date()
	Local cDataI      := ""
	Local cDataF      := ""
	Local lFLine      := .T.


	aAdd(aPergs, {1, "Data De",  dDataDe,  "", ".T.", "", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Data At�", dDataAt,  "", ".T.", "", ".T.", 80,  .F.})

	If ParamBox(aPergs, "Informe os par�metros")

		If (Empty(MV_PAR01) .Or. Empty(MV_PAR02))
			FwAlertError("Os par�metros de data s�o obrigat�rios!!",cNomeLog)
			Return
		EndIf

		cDataI      := DtoS(MV_PAR01)
		cDataF      := DtoS(MV_PAR02)


		cQry += " SELECT F1_FILIAL, COUNT(1) AS TOTAL_FILIAL, SUM(COUNT(1)) OVER () AS TOTAL_MES FROM "
		cQry += RetSqlName("SF1")
		cQry += " WHERE F1_DTDIGIT >= '"
		cQry += cDataI
		cQry += "' AND F1_DTDIGIT <= '"
		cQry += cDataF
		cQry += "' AND D_E_L_E_T_ = ' ' AND F1_XID <> ' ' "
		cQry += " GROUP BY F1_FILIAL "


		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasRel,.T.,.T.)

		If !(cAliasRel)->(EOF())
			//Criando o objeto que ir� gerar o conte�do do Excel
			oFWMsExcel := FWMSExcel():New()



			oFWMsExcel:AddworkSheet("Quantidade de NFS integradas por per�odo")
			//Criando a Tabela
			oFWMsExcel:AddTable("Quantidade de NFS integradas por per�odo","Notas Fiscais")
			oFWMsExcel:AddColumn("Quantidade de NFS integradas por per�odo","Notas Fiscais","Filial",1)
			oFWMsExcel:AddColumn("Quantidade de NFS integradas por per�odo","Notas Fiscais","Total da filial",1)
			oFWMsExcel:AddColumn("Quantidade de NFS integradas por per�odo","Notas Fiscais","Soma total do per�odo",1)

			//Criando as Linhas... Enquanto n�o for fim da query
			(cAliasRel)->(DbGoTop())
			While !((cAliasRel)->(EoF()))

				If lFLine
					oFWMsExcel:AddRow("Quantidade de NFS integradas por per�odo","Notas Fiscais",{;
					(cAliasRel)->F1_FILIAL,;
					(cAliasRel)->TOTAL_FILIAL,;
					(cAliasRel)->TOTAL_MES;
					})
					lFline := .F.
				Else
					oFWMsExcel:AddRow("Quantidade de NFS integradas por per�odo","Notas Fiscais",{;
					(cAliasRel)->F1_FILIAL,;
					(cAliasRel)->TOTAL_FILIAL,;
					' ';
					})
				EndIf
				//Pulando Registro
				(cAliasRel)->(DbSkip())
			EndDo

			//Ativando o arquivo e gerando o xml
			oFWMsExcel:Activate()
			oFWMsExcel:GetXMLFile(cArquivo)

			//Abrindo o excel e abrindo o arquivo xml
			// oExcel := MsExcel():New()             //Abre uma nova conex�o com Excel
			// oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
			// oExcel:SetVisible(.T.)                 //Visualiza a planilha
			// oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas
			ShellExecute("open",cArquivo,"","",1)	

		Else
			FWAlertInfo("N�o existem integra��es no per�odo selecionado.",cNomeLog)
		EndIf

	EndIf
	RestArea(aArea)
Return
