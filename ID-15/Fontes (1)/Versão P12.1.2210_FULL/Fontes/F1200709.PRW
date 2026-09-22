#INCLUDE 'PROTHEUS.CH'
#INCLUDE  'TOPCONN.CH'
#Include "TOTVS.ch" //Thais Paiva - 09/12/2020
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GCTXDEF.CH"
#INCLUDE "CNTA121.CH"
#INCLUDE "CNTA120.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "ApWizard.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GCTXDEF.CH"
#DEFINE STR0187 "Não há competências a serem listadas. O parâmetro MV_CNFCOMP está ativo, porém não há parcela com saldo para esse mês."
#DEFINE STR0188 "Troque a data do sistema para poder medir competências futuras ou desative o parâmetro MV_CNFCOMP."
#DEFINE STR0166 "Valida se o contrato esta em vigencia"
/*/{Protheus.doc} F1200709
Processa medições.
@author 	Paulo Krüger
@since 		17/08/2017
@version 	P12.7
@Project    MAN0000007423046
@Return		lRet
/*/

User Function F1200709(aAllCab,aItsGCT,aId,cContrat,cRevisa, cNewfil )

	Local cFuncao	:=	''
	Local aRet		:=	{}
	Local aErro		:=	{}
	Local cFlagGCT	:=	''
	Local cNumMed	:=	''
	Local cOriMed	:=	''
	Local dDataMed	:=	CTOD('  /  /  ')
	Local cHoramed	:=	''
	Local cPedCom	:=	''
	Local cStatMed	:=	''
	Local cObs 		:=	''
	Local nPosObs	:=	0
	Local cRecnSC7	:=  0
	Local cFilOld 	:= ""
	Local lGCTOk	:= .T.
	Local oModel    := Nil
	Local cCodCTR   := "CNTA121EXEMP002"
	Local aMsgDeErro:= {}
	Local lRet      := .F.
// --------------------------------------------------------
// [ Chamado 7023201 - inicio - 1/3 ]
// --------------------------------------------------------
	local lAltCN9   := .F.
	local nRecCN9   := 0
	local cQry      := ''
	Local nX := 01
	Local oModelEncer := NIL
// --------------------------------------------------------
// [ Chamado 7023201 - fim    - 1/3 ]
// --------------------------------------------------------

	Default cContrat:=	''
	Default cRevisa	:=	''

	Private lMsHelpAuto := .T.
	Private lMsErroAuto := .F.
	Private aCNE := aClone(AITSGCT)

	If ISINCALLSTACK('U_F1200600')
		cOrigMed := 'S'
	Else
		cOrigMed := 'M'
	EndIf

	CN9->(DbSetOrder(01))
	If CN9->(DbSeek(aAllCab[01][01][02] + aAllCab[01][02][02]))

		cFilOld := cFilAnt
		cFilAnt := cNewfil

		Begin Transaction
			CND->(DbSetOrder(04))
			If	CND->(DbSeek(cNewfil + aAllCab[01][10][02]) )
				aAllCab[01][10][02] := GetSxENum('CND','CND_NUMMED')
				ConfirmSX8()
			EndIf

// --------------------------------------------------------
//      [ Chamado 7023201 - inicio - 2/3 ]
// --------------------------------------------------------
// -----[ Verificação padrão, replicada aqui  ]-------
// -----[ com a filial correta,               ]-------
//------[ pois a customização altera a filial ]-------
// ---------------------------------------------------
// -----[ Verifica revisão atual do contrato  ]-------
// -----[ se a situação é revisão '09'        ]-------
// ---------------------------------------------------
			CN9->( dbsetorder( 1 )) // CN9_FILIAL + CN9_NUMERO          + CN9_REVISA
			CN9->( dbseek(    aAllCab[01][01][02] + aAllCab[01][02][02] + 'ZZZ' , .T. ))
			CN9->( dbskip( -1 ))
			if ( CN9->CN9_FILIAL == aAllCab[01][01][02] .AND. ; // filial do contrato
				CN9->CN9_NUMERO == aAllCab[01][02][02] .AND. ; // numero do contrato
				CN9->CN9_SITUAC == '09'                      )
				Help( ' ' , 1 , 'CNTA120_02' ) // 'Apenas contratos em vigência podem ser medidos'
				lGCTOk   := .F.                // Erro na medicao
				cFlagGCT := '3'
				disarmtransaction()
				break
			endif
// -----[ contorna a validação padrão, ]--------------
// -----[ feita na filial errada       ]--------------
			CN9->( dbsetorder( 1 )) // CN9_FILIAL + CN9_NUMERO          + CN9_REVISA
			CN9->( dbseek(       xFilial( 'CN9' ) + aAllCab[01][02][02] + 'ZZZ' , .T. ))
			CN9->( dbskip( -1 ))
			if CN9->CN9_SITUAC == '09'
				reclock( 'CN9' , .T. )
				CN9->CN9_FILIAL := xfilial( 'CN9' )
				CN9->CN9_NUMERO := aAllCab[01][02][02]
				CN9->CN9_REVISA := 'ZZY'
				CN9->CN9_SITUAC := 'XX'
				nRecCN9         := CN9->( recno() )
				lAltCN9         := .T.
				msunlock()
			endif
// --------------------------------------------------------
//      [ Chamado 7023201 - fim    - 2/3 ]
// --------------------------------------------------------

			DbSelectArea('CN1')

			//Executa Medições
			CN9->(DbSetOrder(1))

			If CN9->(DbSeek(aallcab[1][AScan(aallcab[1], {|X| AllTrim(x[1]) == "CND_FILCTR"})][2] + aallcab[1][AScan(aallcab[1], {|X| AllTrim(x[1]) == "CND_CONTRA"})][2]))//Posicionar na CN9 para realizar a inclusão
				oModel := FWLoadModel("CNTA121")

				oModel:SetOperation(MODEL_OPERATION_INSERT)
				If(oModel:CanActivate())
					oModel:Activate()
					oModel:SetValue("CNDMASTER","CND_CONTRA"    ,CN9->CN9_NUMERO)
					XCN120VlCo(1,NIL,NIL)

					oModel:SetValue("CNDMASTER","CND_RCCOMP"    ,"1")//Selecionar competência

					oModel:SetValue("CNDMASTER","CND_FILCTR",aallcab[1][AScan(aallcab[1], {|X| AllTrim(x[1]) == "CND_FILCTR"})][2])
					//oModel:SetValue("CNDMASTER","CND_CONTRA",aallcab[1][AScan(aallcab[1], {|X| AllTrim(x[1]) == "CND_CONTRA"})][2])
					oModel:SetValue("CNDMASTER","CND_REVISA",aallcab[1][AScan(aallcab[1], {|X| AllTrim(x[1]) == "CND_REVISA"})][2])
					oModel:SetValue("CNDMASTER","CND_COMPET",aallcab[1][AScan(aallcab[1], {|X| AllTrim(x[1]) == "CND_COMPET"})][2])
					oModel:SetValue("CNDMASTER","CND_FORNEC",aallcab[1][AScan(aallcab[1], {|X| AllTrim(x[1]) == "CND_FORNEC"})][2])
					oModel:SetValue("CNDMASTER","CND_LJFORN",aallcab[1][AScan(aallcab[1], {|X| AllTrim(x[1]) == "CND_LJFORN"})][2])
					oModel:SetValue("CNDMASTER","CND_FILIAL",aallcab[1][AScan(aallcab[1], {|X| AllTrim(x[1]) == "CND_FILIAL"})][2])
					oModel:SetValue("CNDMASTER","CND_PARCEL",aallcab[1][AScan(aallcab[1], {|X| AllTrim(x[1]) == "CND_PARCEL"})][2])
					//oModel:SetValue("CNDMASTER","CND_RCCOMP"    ,"1")//Selecionar competência


					//oModel:SetValue("CXNDETAIL","CXN_CHECK" , .T.)//Marcar a planilha(nesse caso apenas uma)
					//oModel:GetModel('CNEDETAIL'):LoadValue('CNE_ITEM', PadL("1", CNE->(Len(CNE_ITEM)), "0"))//Adiciona um item a planilha

					For nX := 1 To oModel:GetModel("CXNDETAIL"):Length() //Marca todas as planilhas
						oModel:GetModel("CXNDETAIL"):GoLine(nX)
						oModel:LoadValue("CXNDETAIL","CXN_CHECK" , .T.)
						oModel:LoadValue("CXNDETAIL","CXN_ZERO","0")
						oModel:LoadValue("CXNDETAIL","CXN_VLSALD",99999999999)
						oModel:LoadValue("CXNDETAIL", "CXN_NUMPLA","000001")
						//oModel:SetValue("CXNDETAIL","CXN_CHECK" , .T.)
						//oModel:SetValue("CXNDETAIL","CXN_NUMPLA" , PadL(cValToChar(nX), CNE->(Len(CNX->CXN_NUMPLA)), "0"))
						//oModel:SetValue("CXNDETAIL","CXN_NUMPLA" , PadL(cValToChar(nX), CNE->(Len(CXN_NUMPLA)), "0"))
						//oModel:SetValue("CXNDETAIL","CXN_CONTRA" , CN9->CN9_NUMERO)
					/*/If nX <> oModel:GetModel("CXNDETAIL"):Length()
						oModel:GetModel("CXNDETAIL"):AddLine()
					EndIf/*/

					Next nX

					For nX := 01 To Len(aITSGCT)
						oModel:GetModel('CNEDETAIL'):LoadValue('CNE_ITEM', PadL(cValToChar(nX), CNE->(Len(CNE_ITEM)), "0"))
						//oModel:SetValue( 'CNEDETAIL' , 'CNE_ITEM' , PadL(cValToChar(nX), CNE->(Len(CNE_ITEM)), "0"))
						oModel:SetValue( 'CNEDETAIL' , 'CNE_PRODUT' , AITSGCT[nX][AScan(aITSGCT[1], {|X| AllTrim(x[1]) == "CNE_PRODUT"})][2])
						//oModel:SetValue( 'CNEDETAIL' , 'CNE_PRODSV' , AITSGCT[nX][AScan(aITSGCT[1], {|X| AllTrim(x[1]) == "CNE_PRODUT"})][2])
						oModel:SetValue( 'CNEDETAIL' , 'CNE_SDAMED' , AITSGCT[nX][AScan(aITSGCT[1], {|X| AllTrim(x[1]) == "CNE_QUANT"})][2])
						oModel:SetValue( 'CNEDETAIL' , 'CNE_VLUNIT' , AITSGCT[nX][AScan(aITSGCT[1], {|X| AllTrim(x[1]) == "CNE_VLUNIT"})][2] )
						oModel:SetValue( 'CNEDETAIL' , 'CNE_VLTOT' 	, AITSGCT[nX][AScan(aITSGCT[1], {|X| AllTrim(x[1]) == "CNE_VLUNIT"})][2] * AITSGCT[nX][AScan(aITSGCT[1], {|X| AllTrim(x[1]) == "CNE_QUANT"})][2] )
						oModel:SetValue( 'CNEDETAIL' , 'CNE_QUANT' 	, AITSGCT[nX][AScan(aITSGCT[1], {|X| AllTrim(x[1]) == "CNE_QUANT"})][2])
						oModel:SetValue( 'CNEDETAIL' , 'CNE_CC' 	, AITSGCT[nX][AScan(aITSGCT[1], {|X| AllTrim(x[1]) == "CNE_CC"})][2])
						oModel:SetValue( 'CNEDETAIL' , 'CNE_CONTA' 	, AITSGCT[nX][AScan(aITSGCT[1], {|X| AllTrim(x[1]) == "CNE_CONTA"})][2])
						oModel:SetValue( 'CNEDETAIL' , 'CNE_XDESFI' , AITSGCT[nX][AScan(aITSGCT[1], {|X| AllTrim(x[1]) == "CNE_XDESFI"})][2])
						oModel:SetValue( 'CNEDETAIL' , 'CNE_XNUMSC' , AITSGCT[nX][AScan(aITSGCT[1], {|X| AllTrim(x[1]) == "CNE_XNUMSC"})][2])
						oModel:SetValue( 'CNEDETAIL' , 'CNE_XITSC' 	, AITSGCT[nX][AScan(aITSGCT[1], {|X| AllTrim(x[1]) == "CNE_XITSC"})][2])
						//oModel:SetValue( 'CNEDETAIL' , 'CNE_TE'  , '   ')
						If nX <> Len(aITSGCT)
							oModel:GetModel("CNEDETAIL"):AddLine()
						EndIf
					Next nX

					If (oModel:VldData()) /*Valida o modelo como um todo*/
						oModel:CommitData()
					EndIf
				EndIf

				If(oModel:HasErrorMessage())
					aMsgDeErro := oModel:GetErrorMessage()
					cFlagGCT	:=	'3'
					lGCTOk := .F. //Erro na medicao
					cObs 	:= aMsgDeErro[6]
					If !IsBlind()
						Alert(aMsgDeErro[6])
					EndIf
					DisarmTransaction()
					Break
				Else
					cNumMed := CND->CND_NUMMED
					oModel:DeActivate()
					lRet := CN121Encerr(.T.) //Realiza o encerramento da medição
				EndIf
			EndIf

			If lRet
				cFlagGCT	:=	'1'
				cNummed		:=	CND->CND_NUMMED
				cOriMed		:=	If(IsInCallStack('U_F1200600'),'S','M') // Schedule ou Manual
				dDataMed	:=	dDataBase
				cHoramed	:=	Time()
				cPedCom		:=	SC7->C7_NUM
			Else
				oModelEncer := FwModelActive()
				If oModelEncer:GetErrorMessage()[5] == "CNNOTRANS "
					cObs := "Usuário não possui permissões no contrato, verifique a tabela CNN!"
				Else
					cObs := oModelEncer:GetErrorMessage()[5] + " " + oModelEncer:GetErrorMessage()[6]
				EndIf
			EndIf
			If Empty(aErro)
				cStatMed := 'Utilizado pelo GCT'
				//Atualiza o Campo C7_XDESFIN na inclusão do pedido vindo de medição
				U_F1600701(CNE->CNE_FILIAL, SC7->C7_NUM)
			Else
				cStatMed := 'Medição não Realizada'
			EndIf

// --------------------------------------------------------
//      [ Chamado 7023201 - início - 3/3 ]
// --------------------------------------------------------
// -----[ Desfaz o contorno da validação padrão ]-----
			if ( lAltCN9 .AND. ;
					nRecCN9 <> 0  )
				CN9->( dbgoto( nRecCN9 ))
				reclock( 'CN9' , .F. )
				CN9->( dbdelete() )
				msunlock()
// ------------------------------------
				cQry := "DELETE " + retsqlname( 'CN9' )
				cQry += "WHERE D_E_L_E_T_ = '*' "
				cQry += "AND CN9_FILIAL = '" + xfilial( 'CN9' )    + "' "
				cQry += "AND CN9_NUMERO = '" + aAllCab[01][02][02] + "' "
				cQry += "AND CN9_REVISA = 'ZZY' "
				cQry += "AND CN9_SITUAC = 'XX'  "
				tcsqlexec( cQry )
// ------------------------------------
			endif
// --------------------------------------------------------
//      [ Chamado 7023201 - fim    - 3/3 ]
// --------------------------------------------------------

		End Transaction

		cFilAnt := cFilOld

		if lGCTOk //Se processou medicao no GCT corretamente
			If cFlagGCT == '1'
				cRecnSC7 := SC7->(Recno())
			EndIf

			//Atualiza informações nas Solicitações de Compras
			U_F1200710(	aId				,	;
				cObs			,	;
				cFlagGCT		,	;
				cStatMed		,	;
				cNummed			,	;
				cOriMed			,	;
				dDataMed		,	;
				cHoramed		,	;
				cContrat		,	;
				cRevisa			,	;
				cPedCom)

			//Processa todo o PE do final da SC7
			//U_GCTINTEGR(3, SC7->C7_NUM, 1, SC7->(Recno())) Thais Paiva - 10355882
			U_GCTINTEGR(3, cPedCom, 1, SC7->(Recno()))

			If cFlagGCT == '1'

				Reclock("CND",.F.)
				CND->CND_FORNEC := CNA->CNA_FORNEC
				CND->CND_LJFORN := CNA->CNA_LJFORN
				CND->CND_REVGER := CND->CND_REVISA
				CND->CND_PEDIDO := cPedCom
				CND->CND_NUMERO := '000001'
				CND->CND_MOEDA := 1
				CND->CND_VLCONT := CN9->CN9_VLATU
				CND->(MsUnlock())

				DbSelectArea("CN9")
				CN9->(DbSetOrder(1))
				CN9->(DbSeek(aAllcab[1][AScan(aallcab[1], {|x| AllTrim(x[1]) == "CND_FILCTR"})][2]+aAllcab[1][AScan(aallcab[1], {|x| AllTrim(x[1]) == "CND_CONTRA"})][2]+aAllcab[1][AScan(aallcab[1], {|x| AllTrim(x[1]) == "CND_REVISA"})][2]))
				//Envia email com o Pedido de Compra gerado

				SC7->(DbGoto(cRecnSC7))
				U_F1200501(cRecnSC7)
			EndIf
		EndIf

	EndIf

Return(.T.)


Static Function XCN120VlCo(nTipo,lExcede,cFilCTR)
	Local cCompetbck  := ""
	Local cQuery      := ""
	Local cCompExce   := ""
	Local aArea		  := GetArea()
	Local aAreaCNA	  := CNA->(GetArea())
	Local aCompets    := {}
	Local aCompExce   := {}
	Local lMVC		  := .F.
	Local lRecorre 	  := .F.
	Local lRet        := .T.
	Local lCN120DTCON := .T.
	Local lIsGs		  := (IsInCallStack("TECA930") .Or. IsInCallStack("ApurJobAux")) .Or. IsInCallStack('TECA934') .OR. ( FindFunction("TEC930Test") .AND. TEC930Test() )
	Local lCn120ctaut := ExistBlock("CN120CTAUT")
	Local lVldVige    := ValidVigen()
	Local lMVCNFCOMP  := SuperGetMv("MV_CNFCOMP",.F.,.F.) //Filtra competencias a exibir de acordo com a database
	Local lPims		  := .F.
	Local oModel	  := Nil
	Local oModelCND	  := Nil

	Private cCompt := ""

	DEFAULT nTipo	:= 1
	DEFAULT lExcede	:= Iif( ExistFunc('IsExced') , IsExced() , IsInCallStack("CN121ExceC") )
	DEFAULT cFilCTR := Iif(!Empty(CN9->CN9_FILCTR),CN9->CN9_FILCTR,cFilAnt)

	If Type("cContra") == "U"
		cContra := ""
	EndIf

	If Type("cCompet") == "U"
		cCompet := ""
	EndIf
	If Type('lAuto') == 'U'
		PRIVATE lAuto := (FwIsInCallStack('MsExecAuto') .Or. FwIsInCallStack('CN260Exc') .Or. FwIsInCallStack("IncEnc121"))
	EndIf

	If Type('lBack') == 'L' .And. lBack == .T.
		Return .T.
	EndIf

	If !lAuto .Or. lIsGs
		If (!IsInCallStack('CNTA120') .And. ValType(FWModelActive()) <> "U") .Or. lIsGs
			oModel := FWModelActive()
			lMVC	:= oModel:GetId() == "CNTA121" .And. oModel:IsActive()

			If lMVC
				oModelCND	:= oModel:GetModel("CNDMASTER")
				cContra 	:= oModelCND:GetValue("CND_CONTRA")
				If CN9->(AllTrim(cContra) != AllTrim(CN9_NUMERO))
					cFilCTR := cFilAnt
				EndIf
			EndIf
		EndIf

		CN9->(dbSetOrder(1))
		CN9->(dbSeek(xFilial("CN9",cFilCTR)+cContra))

	/*/If !IsBlind() .And. !(CNTVldCTR(cContra,@cFilCtr) .And. CN240VldUsr(cContra,DEF_TRAINC,.T.,,cFilCTR))
		Return .F.
	EndIf/*/

		If ( lRet := CN9->(dbSeek(xFilial("CN9",cFilCTR)+cContra)) )
			CN9->(DbSetOrder(7)) // CN9_FILIAL + CN9_NUMERO + CN9_SITUAC
			If CN9->(DbSeek(xFilial("CN9",cFilCtr) + cContra + DEF_SVIGE))//-- busca revisão vigente
				If !Empty(CN9->CN9_REVATU)
					lRet := .F.
					Help("",1,"CNTA120_REV","","CNTA120_REV:"+STR0166,1,0) //- Valida se o contrato esta em vigencia
				Else
					cRevisa := CN9->CN9_REVISA
					If lMvc
						oModelCND:LoadValue("CND_REVISA",cRevisa)
						oModelCND:LoadValue("CND_FILCTR",CN9->CN9_FILCTR)
						Cn121Carga(cContra,cRevisa)
					EndIf
				EndIf
			Else
				lRet := .F.
				Help( " ", 1, "CNTA120_02" ) //"Apenas contratos em vigência podem ser medidos"
			Endif

			If lVldVige .and. (CN9->CN9_DTINIC > dDataBase .Or. CN9->CN9_DTFIM < dDataBase)
				lRet := .F.
				Help( " ", 1, "CNTA120_07" ) //Contrato fora do periodo de vigencia
			EndIf
			CN9->(dbSetOrder(1))
		EndIf

		//Bloqueia o registro do contrato na tabela CN9
		If lRet
			lRet := SoftLock('CN9',.F.)
			If lRet
				CN9->(msUnlock())
			EndIf
		EndIf

		If lRet
			If lPims .And. !IsInCallStack("CN121V2000")
				Help( " ", 1, "CN121PIMS" )//"O contrato possui integração com o PIMS e, por isso, não pode ter a medição inclusa manualmente."
				lRet := .F.
			EndIf

			If AllTrim(CN9->CN9_NUMERO) <> AllTrim(cContra)
				Help(" ",1,STR0114,, CN9->CN9_NUMERO + STR0156 + CHR(13) + STR0157 + cContra ,1,1)
				lRet := .F.
			Endif

			//- Verifica Medicao eventual
			dbSelectArea("CN1")
			CN1->(dbSetOrder(1))

			If (lRet := CN1->(dbSeek(xFilial("CN1",cFilCTR)+CN9->CN9_TPCTO)))
				If nTipo == 2 .And. CN1->CN1_ESPCTR == "2"
					Help(" ",1,STR0114,, OemToAnsi(STR0054) ,1,1)
					lRet := .F.
				EndIf

				If lRet .And. lExcede .And. CN1->CN1_ESPCTR == "1"
					Help(" ",1,STR0114,, STR0090 ,1,1)
					lRet := .F.
				EndIf
			else
				Help(" ",1,"REGNOIS")
			EndIf
		EndIf

		If lRet
			If !lExcede
				cPlan := ""

				If !lMVC
					dbSelectArea("TRBCNA")
					If RecCount() > 0
						Zap //³Limpa arquivo temporario
						oBrowse:Refresh()
					Endif
				EndIf

				aCompets := CtrCompets()//Obtem competencias

				//Se for pra mostrar só a competência do mês vigente e não houver nenhuma parcela com saldo nesse período, exibe alerta ao usuário
				If lMVCNFCOMP .And. Len( aCompets ) == 0
					Help( ,, "CN120NOCOMP",, STR0187, 1, 0,,,,,, {STR0188} ) //"Não há competências a serem listadas. O parâmetro MV_CNFCOMP está ativo, porém não há parcela com saldo para esse mês." ## "Troque a data do sistema para poder medir competências futuras ou desative o parâmetro MV_CNFCOMP."
					lRet := .F.
				EndIf

				//Ordena por data
				If !lMVC
					oCbx:aItems := aCompets
					If lCn120ctaut .and. cCompet<>Space(TamSX3("CNF_COMPET")[1])
						cCompetbck := cCompet
						cCompet := cCompetbck
						oCbx:nAT := aScan(oCbx:aItems,cCompet)
						oCbx:Refresh()
					EndIf
				ElseIf(lRet)
					If( Len(aCompets) > 0 )
						//CN121Cbox(aCompets,,cFilCTR)
					Else
						oModel:SetErrorMessage( "CNDMASTER", "CND_RCCOMP", "CN120NOCOMP", "", "", STR0070, STR0030)
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf

		If lRet
			If lExcede .And. !lRecorre
				cEspCtr := '2'
				cCompExce := Substr(DToS(CN9->CN9_DTINIC),1,6)

				cQuery := "SELECT DISTINCT(CNF.CNF_COMPET) AS CNF_COMPET FROM " +RetSQLName("CNF") +" CNF WHERE "
				cQuery += "CNF.D_E_L_E_T_ <> '*' AND CNF.CNF_FILIAL = '" +xFilial("CNF",cFilCTR) +"' AND "
				cQuery += "CNF.CNF_CONTRA = '" +cContra +"' AND CNF.CNF_REVISA = '" +cRevisa +"' "
				cQuery += "UNION "
				cQuery += "SELECT DISTINCT(CND.CND_COMPET) FROM " +RetSQLName("CND") +" CND WHERE CND.D_E_L_E_T_ <> '*' AND "
				cQuery += "CND.CND_FILCTR = '" + xFilial("CNF",cFilCTR) +"' AND "
				cQuery += "CND.CND_CONTRA = '" +cContra +"' AND "
				cQuery += "CND.CND_REVISA = '" +cRevisa +"' AND CND.CND_COMPET NOT IN ("
				cQuery += "SELECT DISTINCT(CNFTMP.CNF_COMPET) FROM " +RetSQLName("CNF") +" CNFTMP WHERE CNFTMP.D_E_L_E_T_ <> '*' AND "
				cQuery += "CNFTMP.CNF_FILIAL = '" +xFilial("CNF",cFilCTR) +"' AND CNFTMP.CNF_CONTRA = '" +cContra +"' AND "
				cQuery += "CNFTMP.CNF_REVISA = '" +cRevisa +"'"
				cQuery += ")"

				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQuery ),"QRYTRB",.F.,.T.)

				QRYTRB->(dbEval({|| aAdd(aCompets, Substr(QRYTRB->CNF_COMPET,4,4) + Substr(QRYTRB->CNF_COMPET,1,2))}))
				QRYTRB->(dbCloseArea())

				//-- Monta competencias nao previstas no cronograma.
				While cCompExce <= Substr(DToS(CN9->CN9_DTFIM),1,6)
					If aScan(aCompets, {|x| x == cCompExce}) == 0
						aAdd(aCompExce,Substr(cCompExce,5,2) +"/" +Substr(cCompExce,1,4))
					EndIf

					//-- Incrementa cCompExce
					If Substr(cCompExce,5,2) == '12'
						cCompExce := StrZero(Val(Substr(cCompExce,1,4)) + 1,4) + "01"
					Else
						cCompExce := Substr(cCompExce,1,4) + StrZero(Val(Substr(cCompExce,5,2)) + 1,2)
					EndIf
				EndDo

				If !Empty(aCompExce)
					If !lMVC
						oCbx:aItems := aClone(aCompExce)
						cCompet := oCbx:aItems[1]
					Else
						CN121Cbox(aCompExce,,cFilCTR)
					EndIf
				Else
					Aviso(STR0114,STR0115,{STR0155}) //-- Não há competências não previstas para este contrato.
					lRet := .F.
				EndIf
			EndIf
		EndIf

		If lRet .And. !lMVC
			CN120Compet(lExcede,cFilCTR)
		EndIf

	ElseIf IsInCallStack('IncEnc121')
		oModel  	:= FWModelActive()
		oModelCND	:= oModel:GetModel("CNDMASTER")
		cContra 	:= oModelCND:GetValue("CND_CONTRA")

		If (lRet := (CNTVldCTR(cContra,cFilCTR) .And. CN240VldUsr(cContra,DEF_TRAINC,.T.,,cFilCTR)))
			CN9->(DbSetOrder(7)) // CN9_FILIAL + CN9_NUMERO + CN9_SITUAC

			If CN9->(DbSeek(xFilial("CN9") + cContra + DEF_SVIGE))
				cRevisa := CN9->CN9_REVISA
				oModelCND:LoadValue("CND_REVISA",cRevisa)
				Cn121Carga(cContra,cRevisa)
			Else
				lRet := .F.
			Endif

			If lRet
				cCompet := A260GComp()
				aAdd(aCompets,cCompet)
				CN121Cbox(aCompets,,cFilCTR)
			Endif
		EndIf

	Else
		lRet := .T.
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa ponto de entrada após validação  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("CN120DTCON")
		lCN120DTCON:= ExecBlock("CN120DTCON",.F.,.F.,{lRet})
		If ValType(lCN120DTCON) == "L"
			lRet := lCN120DTCON
		EndIf
	EndIf

	RestArea(aArea)
	RestArea(aAreaCNA)

Return lRet


Static Function ValidVigen()
	Local lResult := SuperGetMV("MV_CNFVIGE", .F., "N") == "N"//S=permite incluir fora da vigência,N=não permite.
Return lResult


