#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#Include "TOTVS.ch" //Thais Paiva - 09/12/2020
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GCTXDEF.CH"
#INCLUDE "CNTA121.CH"
//#INCLUDE "CNTA120.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "ApWizard.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GCTXDEF.CH"
#DEFINE STR0187 "Não há competências a serem listadas. O parâmetro MV_CNFCOMP está ativo, porém não há parcela com saldo para esse mês."
#DEFINE STR0188 "Troque a data do sistema para poder medir competências futuras ou desative o parâmetro MV_CNFCOMP."
#DEFINE STR0166 "Valida se o contrato esta em vigencia"
#DEFINE STR0030 "Não existem competência disponível para o contrato, verifique o saldo"
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
	Local cCdPgn9   := ""
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

		cCdPgn9 := CN9->CN9_CONDPG
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
					//oModel:SetValue("CNDMASTER","CND_CONDPG",cCdPgn9)
					//oModel:SetValue("CNDMASTER","CND_CONTRA",CN9->CN9_NUMERO)
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
						//oModel:SetValue("CNDMASTER","CND_CONDPG","")
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
					//lRet := xCN121MedEnc(CND->(RECNO()))
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
				cQuery += "CNF.D_E_L_E_T_ = '' AND CNF.CNF_FILIAL = '" +xFilial("CNF",cFilCTR) +"' AND " //Thiago Marques - 23781643 - 12/06/2025 - Alterado de <> para = na verificação dos registros deletador
				cQuery += "CNF.CNF_CONTRA = '" +cContra +"' AND CNF.CNF_REVISA = '" +cRevisa +"' "
				cQuery += "UNION "
				cQuery += "SELECT DISTINCT(CND.CND_COMPET) FROM " +RetSQLName("CND") +" CND WHERE CND.D_E_L_E_T_ = '' AND "
				cQuery += "CND.CND_FILCTR = '" + xFilial("CNF",cFilCTR) +"' AND "
				cQuery += "CND.CND_CONTRA = '" +cContra +"' AND "
				cQuery += "CND.CND_REVISA = '" +cRevisa +"' AND CND.CND_COMPET NOT IN ("
				cQuery += "SELECT DISTINCT(CNFTMP.CNF_COMPET) FROM " +RetSQLName("CNF") +" CNFTMP WHERE CNFTMP.D_E_L_E_T_ = '' AND "
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





Static Function xCN121MedEnc(nReg,lAviso,lAutoFor,lMedServ)

Local oModel		:= Nil

Local aAreaSX3		:= ""
Local aLPGCT		:= {{"697",VerPadrao("697")},; //LP Gestão de Contratos - Encerramento da Medição
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

Local cFilCtr  		:= cFilAnt
Local cCronog		:= ""
Local cParcel		:= ""
Local cNumTit  		:= ""
Local cAlias   		:= ""
Local cEspCtr  		:= ""
Local cAliasCNE		:= ""
Local cChave   		:= ""
Local cParcela 		:= "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0"
Local cChave1  		:= ""
Local cChave2  		:= ""
Local cArqGCT		:= ""                   //Arquivo contabilizacao
Local cLancCont		:= ""						// Numero da LP
Local cBusca		:= ""
Local cSeqPCOLan	:= "" 	 	//Sequencia de Lancamento do PCO - 000355t
Local cLoteGCT 		:= LoteCont("COM")  	//Numero do Lote
Local cFilCND  		:= xFilial("CND")
Local cFilCXN		:= xFilial("CXN")
Local cFilCNE		:= xFilial("CNE")
Local cFilCN9  		:= xFilial("CN9",cFilCTR)
Local cFilCNA  		:= xFilial("CNA",cFilCTR)
Local cFilCNB  		:= xFilial("CNB",cFilCTR)
Local cFilCNF		:= xFilial("CNF",cFilCTR)
Local cFilCNS		:= xFilial("CNS",cFilCTR)
Local cFilCNZ  		:= xFilial("CNE")
Local cFilCNV		:= xFilial("CNV",cFilCTR)
Local cFilSED		:= xFilial("SED")
Local cFilSE4  		:= xFilial("SE4")
Local cNatureza		:= SuperGetMv("MV_CNNATMD",.F.,"") //Informa natureza financeira usada pelos títulos gerados pela medição de itens faturados através de título.
Local cChaveCXN		:= ""
Local cProxParce	:= ""
Local cOrigem		:= FUNNAME()

Local nMedLmt   	:= 0 //Limite de medicao do contrato
Local nTipo     	:= 1 //1 - Medicao;2 - Autorizacao de Fornecimento
Local nAcao     	:= 1 //1 - Encerra;2 - Gera Pedido;3 - Somente Encerra
Local nServico  	:= 1 //1 - Medicao;2 - Medicao de Servico;
Local nHead	  		:= 0 		//Retorno da funcao HeadProva
Local nDet  		:= 0     	//Retorno da funcao DetProva
Local nTaxa			:= 0
Local nI			:= 0
Local nParcelas 	:= SuperGetMv("MV_NUMPARC")
Local nTpDoc		:= CN120VerDoc(CND->CND_NUMMED) //Verifica quais documentos foram gerados Pedidos/Titulos
Local nTamContra	:= TamSx3("CNZ_CONTRA")[1]
Local nTamRevisa	:= TamSx3("CNZ_REVISA")[1]
Local nTamNummed	:= TamSX3("CNZ_NUMMED")[1]
Local nTamItem  	:= TamSx3("CNZ_ITCONT")[1]
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
Local lSldFlex		:= .T. // PE CN121VDS
Local lDigita 		:= .F.    	 				//Mostra lancamento?
Local lAglutina		:= .F.    	 				//Aglutina
Local lMedComPlan	:= .F.
Local lRetVlPar		:= .T.
Local lCN121VMP		:= .T.
Local lCNPROVI 		:= GetNewPar( "MV_CNPROVI" ,  "S" ) == "S"
Local lCriaProv		:= AllTrim(SuperGetMV("MV_CNTPPP" ,.F.,"0")) $ "0/1"  // define quando os contratos recorrentes serão provisionados
Local lPeSld   		:= ExistBlock("CN121ESD")
Local lPeVdSld 		:= ExistBlock("CN121VDS")
Local lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Local lCtbCNE		:= .F.
Local aFlagCTB 		:= {}

DEFAULT lAviso   	:= .T.
DEFAULT lAutoFor 	:= CND->CND_AUTFRN == '2'
DEFAULT lMedServ 	:= .F.

//Estabelece passos
ProcRegua(5)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para indicar se atualiza ou nao  ³
//³saldo da medicao                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CN121ATS")
	lAtuSld := ExecBlock("CN121ATS",.F.,.F.)
	If ValType(lAtuSld) <> "L"
		lAtuSld := .T.
	EndIf
EndIf

dbSelectArea("CND")
CND->(MsGoTo(nReg)) //-- Posiciona na medicao

If ( !lAutoFor .Or. !lMedServ ) .And. (!FWIsInCallStack('MATA094') .Or. !GetNewPar("MV_CNMDEAT",.F.) )
	lRet := CN240VldUsr(CND->CND_CONTRA,DEF_TRAENC_MED,.T.,,cFilCtr)
EndIf

cChave := CND->(CND_CONTRA+CND_REVISA+CND_NUMMED)

If LockByName("CN121"+cFilCND+cChave,.T.,!Empty(cFilCND),.T.)
	Pergunte("CNT120",.F.)	//carrega as variaveis

	If ValType("cOrigem") == "C"
		cLancCont:= IiF(ALLTRIM(cOrigem) == "CNTA121",cLancCont:= "697",cLancCont:= "698")
		If cOrigem == "CNTA260" .and. GetRemoteType() != -1 //.And. lShow
	   		Pergunte("CNT120",.T.)
	   	ElseIf cOrigem == "CNTA260" .and. GetRemoteType() == -1
	   		MV_PAR01 := 1
	   		MV_PAR02 := 2
	   		MV_PAR03 := 2
		EndIf
	Else
		cLancCont:= "697"
	EndIf

	If (lCtbOnLine := IIf(ValType(MV_PAR01)=="N",MV_PAR01 == 1,.F.)) //SE CONTABILIZA, atraves da escolha do usuario
		//Percorre os lancamentos contabeis do GCT, se algum deles existir, a contabilizacao podera ter continuidade
		For nI := 1 to len(aLPGCT)
			If aLPGCT[nI,2]
				lCtbOnline := .t.
				Exit
			Else
				lCtbOnline := .f.
			Endif
		Next nI

		If lCtbOnLine
			lDigita	:= IIF(VAlTYPE(MV_PAR02)=="N",MV_PAR02 == 1,.F.)
			lAglutina	:= IIF(VAlTYPE(MV_PAR03)=="N",MV_PAR03 == 1,.F.)

			nHead	:= HeadProva(cLoteGCT,cOrigem,Subs(cUsuario,7,6),@cArqGCT)
			If nHead <= 0
				If GetRemoteType() != -1
					HELP(" ",1,"SEM_LANC") //"SEM_LANC"
				EndIf
				lCtbOnLine := .F.
			EndIf
		EndIf
	Endif

	If lRet
		If !Empty(CND->CND_DTFIM) //-- Verifica se a medicao ja se encontra encerrada
			lRet := .F.
			Help( " ", 1, "CNTA120_03" )//"Medição já encerrada"
		ElseIf (GetNewPar("MV_CNMDALC","N") == "S" ) .AND. CND->CND_ALCAPR == "B"
			lRet := .F.
			Help( " ", 1, "CNTA120_09" )//"Medição bloqueada por alçada"
		ElseIf nTpDoc # 1 .And. (Empty(cNatureza) .Or. !SED->(MsSeek(cFilSED+cNatureza)))
		 	Help( " ", 1, "NOCNNATMD" )//"A natureza informada no parâmetro MV_CNNATMD não está cadastrada.
		 	lRet := .F.
		EndIf

		dbSelectArea("CN9")
		CN9->(dbSetOrder(1))
		If lRet .And. CN9->(MsSeek(cFilCN9+CND->(CND_CONTRA+CND_REVISA))) .And. (CN9->CN9_SITUAC==DEF_SFINA .OR. CN9->CN9_SITUAC==DEF_SCANC) //Contrato finalizado ou cancelado
				lRet := .F.
				Help( " ", 1, "CNTA120_02" )//"Apenas contratos em vigência podem ser medidos"
			EndIf

		//-- Verifica se os campos CND_DATA e CND_PARC estão criados conforme parametro MV_NUMPARC
		dbSelectArea("SE4")
		SE4->(dbSetOrder(1))
		If lRet .And. SE4->(MsSeek(cFilSE4+CND->CND_CONDPG)) .And. SE4->E4_TIPO=='9' .And. nParcelas > 4
				cChave1  := "CND_DATA"+Subs(cParcela,nParcelas,1)
				cChave2  := "CND_PARC"+Subs(cParcela,nParcelas,1)
				aAreaSX3 := SX3->(GetArea())

			dbSelectArea("SX3")
			SX3->(dbSetOrder(2))
			If lRet .And. (!SX3->(MsSeek(cChave1)) .OR. !SX3->(MsSeek(cChave2)))
						Help(" ",1,"TMKTIP905") //"A quantidade de parcelas nao esta compativel. Verificar junto ao administrador do sistema relacao entre parametro MV_NUMPARC e dicionario de dados"
						lRet:= .F.
					EndIf
				Restarea(aAreaSX3)
			EndIf

		If lRet .And. nAcao != 3
			dbSelectArea("CN9")
			CN9->(dbSetOrder(1))
			CN9->(MsSeek(cFilCN9+CND->(CND_CONTRA+CND_REVISA)))

			cChaveCXN := cFilCXN+CND->(CND_CONTRA+CND_REVISA+CND_NUMMED)
			DbSelectArea("CXN")
			CXN->(DbSetOrder(1))
			CXN->(MsSeek(cFilCXN+CND->(CND_CONTRA+CND_REVISA+CND_NUMMED)))

			Begin Transaction

			While !CXN->(EOF()) .And. cChaveCXN == CXN->(CXN_FILIAL+CXN_CONTRA+CXN_REVISA+CXN_NUMMED)
				If !CXN->CXN_CHECK
					CXN->(DbSkip())
					Loop
				EndIf

				lFixo	:= Cn300RetSt("FIXO"		,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA)
				lValor	:= Cn300RetSt("PREVFINANC"	,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA)

				//Valor total dos itens excedentes da planilha
				nValExced := CN120VlExc(CND->CND_CONTRA,CND->CND_REVISA,CND->CND_NUMMED,CXN->CXN_NUMPLA)

				cCronog := Posicione("CNA",1,cFilCNA+CND->(CND_CONTRA+CND_REVISA)+CXN->CXN_NUMPLA,"CNA_CRONOG")

				//- Ponto de entrada permite ou não validar o saldo do contrato do tipo flexível com o valor da medição a ser encerrada
				If lPeVdSld
					lSldFlex := ExecBlock("CN121VDS",.F.,.F.)
				EndIf

		   		If !lFixo .And. lSldFlex
					If lValor .And. CNA->CNA_SALDO < xMoeda(CXN->CXN_VLLIQD - nValExced ,CND->CND_MOEDA,CN9->CN9_MOEDA,dDataBase,nTamVlTot)
						If nTipo==1 .And. nServico ==1
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

			IncProc(STR0098)//"Atualizando Medicao e Itens"
			PcoIniLan("000355")

			If lRet 

				oModel := FwLoadModel('CNTA121')
				oModel:SetOperation(MODEL_OPERATION_UPDATE)
				oModel:Activate()

				If !lAutoFor
					oModel:LoadValue("CNDMASTER","CND_SITUAC","E")
					oModel:LoadValue("CNDMASTER","CND_DTFIM",dDataBase)
				EndIf

				If (lRet := oModel:VldData())
					lRet := oModel:CommitData()
				EndIf
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
					
					//-- Encerramento de planilhas zeradas
					If CXN->(Columnpos('CXN_ZERO')) > 0
						If CXN->CXN_ZERO == '1'
							CN121ZERO( CXN->CXN_CONTRA , CXN->CXN_REVISA , CXN->CXN_NUMMED , CXN->CXN_NUMPLA , cFilCtr , '1')
							CXN->(DbSkip())
							Loop
						EndIf
					EndIf
					
					cEspCtr	:= Cn300RetSt("ESPECIE"		,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA)
					lMedEve	:= Cn300RetSt("MEDEVE"		,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA)
					lContab	:= Cn300RetSt("CONTABIL"	,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA)
					lFixo	:= Cn300RetSt("FIXO"		,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA)
					lSemiFix:= Cn300RetSt("SEMIFIXO"	,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA)
					lValor	:= Cn300RetSt("PREVFINANC"	,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA)
					lFisico	:= Cn300RetSt("FISICO"		,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA)
					nMedLmt	:= Cn300RetSt("LMTMED"		,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA)
					lFscLmt	:= Cn300RetSt("LMTFISICO"	,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA)
					lRecorre:= Cn300RetSt("RECORRENTE"	,0,CXN->CXN_NUMPLA,CXN->CXN_CONTRA)
					
					cParcel := CXN->CXN_PARCEL 
					
					//Valor total dos itens excedentes da planilha
					nValExced := CN120VlExc(CND->CND_CONTRA,CND->CND_REVISA,CND->CND_NUMMED,CXN->CXN_NUMPLA)

					PcoDetLan("000355","03","CNTA120") //-- Ponto lancamento contabil e orcamentario para encerramento da medicao
					If lCtbOnLine
				    	nDet += DetProva(nHead,cLancCont,cOrigem,cLoteGCT,,,,,,,,,{"CND",CND->(RECNO())})
					EndIf

					DbSelectArea("CNE")
					CNE->(dbSetOrder(1))
					CNE->(MsSeek(cFilCNE+CND->(CND_CONTRA+CND_REVISA)+CXN->CXN_NUMPLA+CND->CND_NUMMED))
					cCronog := Posicione("CNA",1,cFilCNA+CND->(CND_CONTRA+CND_REVISA)+CXN->CXN_NUMPLA,"CNA_CRONOG")

					If lAtuSld .And. !lPeSld//-- Atualiza itens da planilha
						While CNE->(CNE_FILIAL+CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_NUMMED) == cFilCNE+CND->(CND_CONTRA+CND_REVISA)+CXN->CXN_NUMPLA+CND->CND_NUMMED
							lMedComPlan := .F.
							//-- Itens excedentes nao atualizam saldos
							If CNE->CNE_EXCEDE == '2'
								dbSelectArea("CNB")
								CNB->(dbSetOrder(1))
								If CNB->(MsSeek(cFilCNB+CNE->(CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_ITEM)))
									If !lRecorre	//-- se não recorrente
										RecLock("CNB",.F.)
											If nServico == 1
												CNB->CNB_QTDMED += CNE->CNE_QUANT
											CNB->CNB_SLDMED -= Iif(lSemiFix,0,CNE->CNE_QUANT) //- Somente atualiza se não semifixo
											Else
												CNB->CNB_QTDMED += CNE->CNE_QTDORI
											CNB->CNB_SLDMED -= Iif(lSemiFix,0,CNE->CNE_QTDORI)//- Somente atualiza se não semifixo
											EndIf
										MsUnlock()
									Else //-- Se for recorrente
										//- Tratamento das planilhas de contratos recorrentes
										If CNE->CNE_QUANT > 0
											// verifica se é pro-rata
											If CNB->CNB_PARPRO > 0 .And. Empty(CNB->CNB_PRIMED)
												RecLock("CNB",.F.)
												CNB->CNB_PRIMED := CND->CND_DTINIC
												MsUnlock()
											Endif
										Endif
									Endif
									lMedComPlan := .T. //--  CAPTURO A VARIAVEL FLAG DE ITENS COM PLANILHA
								EndIf
								If lFisico
									dbSelectArea("CNS")
									CNS->(dbSetOrder(1))
									If CNS->(dbSeek(cFilCNS+CND->(CND_CONTRA+CND_REVISA)+cCronog+cParcel+CNB->CNB_ITEM))
										RecLock("CNS",.F.)
											CNS->CNS_RLZQTD += CNE->CNE_QUANT
											CNS->CNS_SLDQTD -= CNE->CNE_QUANT
										MsUnlock()
									EndIf
								EndIf
							EndIf

							PcoDetLan("000355","04","CNTA120")
							If lCtbOnLine //-- CONTABILIZA ENCERRAMENTO DA MEDICAO - ITENS DO CONTRATO

								nLp69A	:= aScan(aLPGCT,{|x| x[1]=="69A"})
								nLp69H := aScan(aLPGCT,{|x| x[1]=="69H"})

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
									If CNE->(Columnpos('CNE_DTLANC')) > 0
										dbSelectArea("CNE")
										RecLock("CNE",.F.)
										CNE->CNE_DTLANC := dDataBase
										MsUnlock()
									EndIf
								EndIf

							EndIf

							If lMedComPlan
								cLancCont 	:= "69E"
								cSeqPCOLanc	:= "06"
							Else
								cLancCont := "69C"
								cSeqPCOLanc	:= "05"
							Endif

	                	  	cBusca :=	cFilCNZ +;
							Padr(CNE->CNE_CONTRA	,nTamContra )+;
							Padr(CNE->CNE_REVISA	,nTamRevisa )+;
							Padr(CNE->CNE_NUMMED	,nTamNummed )+;
							Padr(CNE->CNE_ITEM	,nTamItem )

	                   	CNZ->(dbSetOrder(2)) //CNZ_FILIAL+CNZ_CONTRA+CNZ_REVISA+CNZ_NUMMED+CNZ_ITCONT+CNZ_ITEM

	                   	If CNZ->(MsSeek( cBusca ))
	                    		While CNZ->(!Eof()) .and. cBusca == CNZ->CNZ_FILIAL +;
												Padr(CNZ->CNZ_CONTRA	,nTamContra) +;
												Padr(CNZ->CNZ_REVISA	,nTamRevisa) +;
												Padr(CNZ->CNZ_NUMMED	,nTamNummed) +;
												Padr(CNZ->CNZ_ITCONT	,nTamItem)

					  		     	If !Empty(CNZ->CNZ_CC)
								  		 PcoDetLan("000355",cSeqPCOLan,"CNTA120")
										 //-- Contabiliza os rateios do item do contrato com planilha.
										 //-- Se ha planilha, entao nao podera contabilizar o rateio sem planilha, abaixo (controlar com variavel flag)
										 //-- efetua a contabilizacao dos rateios do item do contrato sem planilha,
										 If lCtbOnLine
											  nDet += DetProva(nHead,cLancCont,"CNTA120",cLoteGCT,,,,,,,,,{"CNZ",CNZ->(Recno())})
										 EndIf
									EndIf
									CNZ->(DbSkip())
	                          EndDo
							EndIf
							dbSelectArea("CNE")
							CNE->(dbSkip())
						EndDo
					EndIf
					IncProc( "Atualizando Saldos" )//"Atualizando Saldos"
					dbSelectArea("CNA")
					CNA->(dbSetOrder(1))
					If CNA->(MsSeek(xFilial("CNA",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA+CXN->CXN_NUMPLA))
						If lAtuSld .And. !lPeSld .And. !lRecorre //-- Atualiza saldo da planilha se nao recorrente
							RecLock("CNA",.F.)
								If lFixo .Or. lSemiFix .Or. lValor
									CNA->CNA_SALDO -= xMoeda(CXN->CXN_VLLIQD - nValExced,CND->CND_MOEDA,CN9->CN9_MOEDA,dDataBase,nTamVlTot,,nTaxa)
								EndIf
							MsUnlock()
						EndIf
						If lRecorre
							//-- atualiza campos de controle dos contratos recorrentes no encerramento
							If CNA->CNA_MEDEFE > 0
								RecLock("CND",.F.)
								CND->CND_RECMED := CNA->CNA_RECMED
								CND->CND_ULTMED := CNA->CNA_ULTMED
								MsUnlock()
							Endif

							RecLock("CNA",.F.)
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
							MsUnlock()
						Endif

					EndIf
					DbSelectArea("CN9")
					CN9->(dbSetorder(1))
					If CN9->(MsSeek(cFilCN9+CND->CND_CONTRA+CND->CND_REVISA))
						If lAtuSld .And. !lPeSld .And. !lRecorre //-- Atualiza saldo do contrato se nao recorrente
							RecLock("CN9",.F.)
							If lFixo .Or. lSemiFix .Or. lValor
								CN9->CN9_SALDO -= xMoeda(CXN->CXN_VLLIQD - nValExced,CND->CND_MOEDA,CN9->CN9_MOEDA,dDataBase,nTamVlTot,,nTaxa)
							Else
								CN9->CN9_VLATU += xMoeda(CXN->CXN_VLLIQD - nValExced,CND->CND_MOEDA,CN9->CN9_MOEDA,dDataBase,nTamVlTot,,nTaxa)//Atualiza valor do contrato
								If Empty(CN9->CN9_REVISA)//Se contrato original atualiza valor inicial
									CN9->CN9_VLINI += xMoeda(CXN->CXN_VLLIQD - nValExced,CND->CND_MOEDA,CN9->CN9_MOEDA,dDataBase,nTamVlTot,,nTaxa)
								EndIf
							EndIf
							MsUnlock()
						EndIf
					EndIf

					If !lMedEve .And. !lRecorre //-- Atualiza saldo do cronograma quando nao houver medicao eventual e nem recorrente
						dbSelectArea("CNF")
						If !Empty(CXN->CXN_PARCEL)
							dbSetorder(3)
							MsSeek(cFilCNF+CND->CND_CONTRA+CND->CND_REVISA+cCronog+CXN->CXN_PARCEL)
						Else
							dbSetorder(2)
							MsSeek(cFilCNF+CND->CND_CONTRA+CND->CND_REVISA+cCronog+CND->CND_COMPET)
						EndIf

						If Found()
							If lAtuSld .And. !lPeSld
								RecLock("CNF")
									CNF->CNF_VLREAL += xMoeda(CXN->CXN_VLLIQD - nValExced,CND->CND_MOEDA,CN9->CN9_MOEDA,dDataBase,nTamVlTot,,nTaxa)
									CNF->CNF_SALDO  -= xMoeda(CXN->CXN_VLLIQD - nValExced,CND->CND_MOEDA,CN9->CN9_MOEDA,dDataBase,nTamVlTot,,nTaxa)
									CNF->CNF_DTREAL := dDataBase
								MsUnlock()

								If lCNPROVI
									IncProc( STR0099 )//"Processando títulos provisórios"
									CN100ETit(CND->CND_CONTRA,CND->CND_REVISA,cCronog,CNF->CNF_PARCEL,cFilCtr)
									If CNF->CNF_SALDO > 0
										CN100CTit(CND->CND_CONTRA,CND->CND_REVISA,cCronog,CNF->CNF_PARCEL,CNF->CNF_SALDO)
									EndIf
								EndIf
							EndIf
						EndIf

						If lContab
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

					ElseIf lRecorre
						//-- Exclui titulo provisorio da parcela atual
						CN100ETit(CND->CND_CONTRA,CND->CND_REVISA,"RECORRENTE",CXN->CXN_PARCEL,cFilCtr,CXN->CXN_NUMPLA)

						// cria titulo provisorio da parcela recorrente se o parâmetro MV_GCTTPPP é 0 ou 1
						If lCriaProv
							CN100RecTi(CND->CND_CONTRA,CND->CND_REVISA,CXN->CXN_PARCEL,CXN->CXN_NUMPLA)
						Endif
					EndIf
					CXN->(DbSkip())
				EndDo

			EndIf

			If lPeSld//Chama ponto de entrada para atualizacao do saldo
				ExecBlock("CN121ESD",.F.,.F.,{lMedEve,lFisico,cCronog,lFixo,lValor})
			EndIf

			If !lRet
				DisarmTransaction()
			EndIf

			End Transaction

			PcoFinLan("000355")

		EndIf
	EndIf
Else
	// Nao permite processamento concorrente
	Aviso(STR0159,OemtoAnsi(STR0100),{STR0156},2) // ##"Concorrência"##"Esta Medição está em uso por outra estação."
EndIf

If lCtbOnLine
	RodaProva(nHead,nDet)
	If nDet > 0
		cA100Incl(cArqGCT,nHead,1,cLoteGCT,lDigita,lAglutina,,,,@aFlagCTB)
		aFlagCTB := {}
	Endif
EndIf

UnLockByName("CN121"+cFilCND+cChave,.T.,!Empty(cFilCND),.T.)

Return lRet
