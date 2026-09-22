#Include 'Protheus.ch'
#INCLUDE "TopConn.ch"
/*
{Protheus.doc} F0400710()
Cadastro de Portador Automático
@Author     Ramon Teodoro
@Since      06/02/2019       
@Return     
*/

User Function TEWBTYC2()

	local lRet := .T.
	Private aRotina   := {}
	Private cAlias 	  := "PZE"
	Private lGravou   := .F.
	PRIVATE cCadastro := "Portador Automático"
	Private lErro := .F.
	Private _aColsPZE := {}
	Private _aHeadPZE := {}

	DbSelectArea("PZE")
	PZE->(DbSetOrder(1))

	AADD(aRotina,{"Pesquisar",	"AxPesqui" ,0,1})
	AADD(aRotina,{"Visualizar", "U_FilBco" ,0,2})
	AADD(aRotina,{"Cadastro", 	"U_FilBco" ,0,3})
	//AADD(aRotina,{"Alterar", 	"U_FilBco" ,0,4})
	AADD(aRotina,{"Excluir", 	"U_FilBco" ,0,5})

	mBrowse( 6, 1,22,75,"PZE")

Return lRet

/*
{Protheus.doc} FilBco()
Opções de inclusão, alteração, exclusão e visualização do cadastro de portador automático 
@Author     Ramon Teodoro
@Since      06/02/2019       
@Param	     cAlias,
@param      nReg, 
@param      nOpcx	 
@Return     lRet
*/

User Function FilBco(cAlias,nReg, nOpcx)

	Local cFieldOk	    := "AllwaysTrue()"
	Local nUsado, nX 	:= 0
	Local aAltEnchoice	:= {}
	Local aObjects   	:= {}
	Local aSizeAut		:= MsAdvSize(.T.)
	Local lRetMod3		:= .F.
	Local aHeader   	:= {}
	Local aCols     	:= {}
	Local oFilBco
	Local oDescri
	Local cFilBco      := xFilial("PZE")
	Local cDescri	   := FwFilialName()
	Local nOpcA        := 1
	Local lRet         := .T.
	Local _aCmpPZE	:= {} //Thais Paiva - Compatibilização P27

	Private nOpc 		:= nOpcx
	Private nOpcF		:= IIf(nOpcx == 3 .Or. nOpcx == 4,GD_INSERT+GD_UPDATE+GD_DELETE,2)
	Private aAlt 		:= {}
	Private oDlgPri

	If lGravou
		lGravou := .F.
		Return
	EndIf

	If lErro
		fRemonta(cAlias,nReg, nOpcx)
		Return
	EndIf

	If nOpcx == 3 .Or. nOpcx == 4
		nOpcE := 3
	Else
		nOpcE := 2
	EndIf

	DbSelectArea("PZE")
	PZE->(DbSetOrder(1))

	RegToMemory("PZE",(nOpcx==3))
	RegToMemory("PZE",(nOpcx==4))

	nUsado := 0
//Início - Thais Paiva - Compatibilização P27
//DbSelectArea("SX3")
//SX3->(dbSetOrder(1))
//SX3->(dbSeek("PZE"))
	_aCmpPZE := FWSX3Util():GetAllFields( "PZE" , .T. )
//While SX3->(!Eof()) .And. (SX3->X3_ARQUIVO == "PZE")
	For _nZe := 1 to Len(_aCmpPZE)

		//If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
		//If X3USO(GetSx3Cache(_aCmpPZE[_nZe], 'X3_CAMPO')) .And. cNivel >= GetSx3Cache(_aCmpPZE[_nZe], 'X3_NIVEL')
		If cNivel >= GetSx3Cache(_aCmpPZE[_nZe], 'X3_NIVEL')
			//If !(SX3->X3_CAMPO $ "PZE_FILIAL|PZE_DESCRI")
			If !(_aCmpPZE[_nZe] $ "PZE_FILIAL|PZE_DESCRI")
				nUsado++
				//aAdd(aHeader, {ALLTRIM(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE,	SX3->X3_TAMANHO, SX3->X3_DECIMAL,"ALLWAYSTRUE()", SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})
				aAdd(aHeader, {ALLTRIM(GetSx3Cache(_aCmpPZE[_nZe], 'X3_TITULO')), GetSx3Cache(_aCmpPZE[_nZe], 'X3_CAMPO'), ;
					GetSx3Cache(_aCmpPZE[_nZe], 'X3_PICTURE'), GetSx3Cache(_aCmpPZE[_nZe], 'X3_TAMANHO'), ;
					GetSx3Cache(_aCmpPZE[_nZe], 'X3_DECIMAL'),"ALLWAYSTRUE()", GetSx3Cache(_aCmpPZE[_nZe], 'X3_USADO'), ;
					GetSx3Cache(_aCmpPZE[_nZe], 'X3_TIPO'), GetSx3Cache(_aCmpPZE[_nZe], 'X3_F3'), ;
					GetSx3Cache(_aCmpPZE[_nZe], 'X3_CONTEXT')})
				//aAdd(aAltEnchoice,SX3->X3_CAMPO)
				aAdd(aAltEnchoice,GetSx3Cache(_aCmpPZE[_nZe], 'X3_CAMPO'))
			EndIf
		EndIf

		//SX3->(dbSkip())

//End
	Next _nZe

	If nOpcx == 2
		aAltEnchoice := {}
	EndIf

	aCols := {}

	DbSelectArea("PZE")
	PZE->(DbSetOrder(2))
	PZE->(DbGoTop())

	If PZE->(dbSeek(xFilial("PZE")))

		While !PZE->(EoF()) .And. PZE->PZE_FILIAL == xFilial("PZE") // .And. PZE->PZE_BANCO == M->PZE_BANCO

			aAdd(aCols,Array(nUsado+1))
			For nX := 1 To nUsado
				aCols[Len(aCols),nX] := FieldGet(FieldPos(aHeader[nX,2]))
			Next

			aCols[Len(aCols),nUsado+1] := .F.

			aAdd(aAlt, Recno())

			DbSelectArea("PZE")
			PZE->(DbSkip())

			If Len(aCols) == 0
				aCols := {Array(nUsado+1)}
				aCols[1,nUsado+1] := .F.

				For nX := 1 To nUsado
					aCols[1,nX] := CriaVar(aHeader[nX,2])
				Next
			EndIf

		End

	Else

		M->PZE_FILIAL := xFilial("PZE")

		aCols := {Array(nUsado+1)}
		aCols[1,nUsado+1] := .F.

		For nX := 1 to nUsado
			If  "PZE_ITEM" $ aHeader[nX,2]
				aCols[1,nX] := "1"
			Else
				aCols[1,nX] := CriaVar(aHeader[nX,2])
			EndIf
		Next

	EndIf

	DbSelectArea("PZE")
	PZE->(DbSetOrder(2))

	aObjects := {}
	AAdd( aObjects, { 315,  30, .T., .T. } )
	AAdd( aObjects, { 100,  70, .T., .T. } )

	aInfo 	:= { aSizeAut[ 1 ], aSizeAut[ 2 ],aSizeAut[ 3 ] ,aSizeAut[ 4 ], 3, 3 }
	aPosObj 	:= MsObjSize( aInfo, aObjects )

	aPosEnchoice 		:= aClone(aPosObj[1])
	aPosEnchoice[4] 	:= NoRound(aPosEnchoice[4]*1)

	DEFINE MSDIALOG oDlgPri TITLE OemToAnsi("Filial x Banco") FROM 0,0 TO 420, 870 OF oMainWnd PIXEL

	@ 36,010 SAY "Filial:"                SIZE 050,07  OF oDlgPri PIXEL
	@ 35,032 MSGET oFilBco  VAR cFilBco   SIZE 030,04  OF oDlgPri PIXEL HASBUTTON When .F.

	@ 36,080 SAY "Descrição:"             SIZE 050,07  OF oDlgPri PIXEL
	@ 35,110 MSGET oDescri  VAR cDescri   SIZE 120,04  OF oDlgPri PIXEL HASBUTTON When .F.

	oGet := MsNewGetDados():New(50,0,200,437;
		,nOpcF,,, "++PZE_ITEM",aAltEnchoice,0,999,cFieldOk,,,oDlgPri,aHeader,aCols )

	ACTIVATE MSDIALOG oDlgPri ON INIT EnchoiceBar(oDlgPri,{|| nOpca := 1, oDlgPri:End()},{|| nOpca := 2, oDlgPri:End()}) CENTERED


	If nOpca == 1
		U_GrvPZE()
	EndIf

Return

/*
{Protheus.doc} OPCPZE()
Direcionamento das opções
@Author     Ramon Teodoro
@Since      06/02/2019     
@Param	     lRetMod3
@Return     lRet
*/

User Function OPCPZE(lRetMod3)

	If lRetMod3
		If nOpc == 3 .OR. nOpc == 4
			U_GrvPZE()
		ElseIf nOpc == 5
			U_GrvPZE()
		EndIf
	EndIf
	oDlgPri:End()

Return

/*
{Protheus.doc} F0400712()
Gravação de dados na tabela PZE
@Author     Ramon Teodoro
@Since      06/02/2019       
@Return     lRet
*/
User Function GrvPZE()

	Local lRet     := .T.
	Local nI       := 0
	Local nX       := 0
	Local aColsPZE := aClone(oGet:aCols) // aClone(oGet:oBrowse:OMOTHER:ACOLS)
	Local aHeadPZE := aClone(oGet:aHeader) //aClone(oGet:oBrowse:OMOTHER:AHEADER)
	Local nPosBco  := Ascan(aHeadPZE,{|x|Alltrim(x[2])=="PZE_BANCO"})
	Local nPosAge  := Ascan(aHeadPZE,{|x|Alltrim(x[2])=="PZE_AGEN"})
	Local nPosCnt  := Ascan(aHeadPZE,{|x|Alltrim(x[2])=="PZE_CONTA"})
	Local nPosPta := Ascan(aHeadPZE,{|x|Alltrim(x[2])=="PZE_PORAUT"})
	Local nContPA  := 0
	Local lFind := .T.

	ProcRegua(Len(aColsPZE) + FCount())

	DbSelectArea("PZE")
	DbSetOrder(1)

	lFind := U_FindFormPG()

	If !lFind
		_aColsPZE := aClone(aColsPZE)
		_aHeadPZE := aClone(aHeadPZE)
		lErro := .T.
		Return .T.
	EndIf

	lGravou := .T.

	If nOpc <> 5

		For nX := 1 to Len(aColsPZE)

			If aColsPZE[nX][nPosPta] == "S"
				nContPA += 1
			EndIf

			If aColsPZE[nX][Len(aColsPZE[nX])]
				If PZE->(DbSeek(xFilial("PZE")+aColsPZE[nX][nPosBco]+aColsPZE[nX][nPosAge]+aColsPZE[nX][nPosCnt]))
					RecLock( "PZE", .F. )
					PZE->(DbDelete())
					PZE->(MsUnlock())
				EndIf
			Else
				If PZE->(DbSeek(xFilial("PZE")+aColsPZE[nX][nPosBco]+aColsPZE[nX][nPosAge]+aColsPZE[nX][nPosCnt]))
					RecLock( "PZE", .F. )
				Else
					RecLock( "PZE", .T. )
					PZE->PZE_FILIAL	:= xFilial("PZE")
					PZE->PZE_DESCRI	:= FwFilialName()
				EndIf

				For nI := 1 To Len( aHeadPZE )
					If  !( AllTrim( aHeadPZE[nI,2] ) $ "PZE_FILIAL|PZE_DESCRI" )
						PZE->(FieldPut(FieldPos(aHeadPZE[nI,2]),aColsPZE[nX,nI]))
					EndIf
				Next nI

			EndIf

			PZE->(MSUnlock())

		Next nX

	Else

		If PZE->(DbSeek(xFilial("PZE")))
			While !Eof() .And. PZE->PZE_FILIAL == xFilial("PZE")
				RecLock("PZE",.F.)
				PZE->(DbDelete())
				PZE->(MsUnLock())
				PZE->(DbSkip())
			End
		EndIf

	EndIf

	If nContPA == 0
		MsgAlert("Nenhum banco foi definido como portador automático para esta filial!", "Atenção")
	EndIf


Return .T.

/*
{Protheus.doc} VldGrPZE()
Validação para que não sejam cadastrados mais de um portador automático
@Author     Ramon Teodoro
@Since      06/02/2019       
@Return     lRet
*/
User Function VldGrPZE()

	Local lRet    := .T.
	Local nG      := 0
	Local nCont   := 0
	Local aColsPZE := aClone(oGet:aCols)
	Local aHeadPZE := aClone(oGet:aHeader)
	Local cFilial  := ""
	Local nPosPta := Ascan(aHeadPZE,{|x|Alltrim(x[2])=="PZE_PORAUT"})
	Local nPosFpg := Ascan(aHeadPZE,{|x|Alltrim(x[2])=="PZE_FORMPG"})

	If M->PZE_PORAUT == "S"

		For nG := 1 to Len(aColsPZE)
			If aColsPZE[nG][nPosPta] == "S"
				nCont += 1
			EndIf
		Next nG

		If nCont > 0
			MsgAlert("Apenas um banco pode ser considerado como portador automático.")
			lRet := .F.
		EndIf
	EndIf

Return lRet



/*
{Protheus.doc} U_PortAuto()

Traz o portador definido para a filial corrente. Usado no inicializador padrão dos campos E2_PORTADO, E2_XAGEPOR, 
E2_XDVAPOR, E2_XCONPOR, E2_XDVCPOR
@Author     Ramon Teodoro
@Since      06/02/2019       
@Return     lRet
*/

User Function PortAuto(cCampo)

	Local cRet  := ""
	Local aArea := GetArea()

	DbSelectArea("PZE")
	PZE->(DbSetOrder(1))
	PZE->(DbGoTop())

	If PZE->(DbSeek(xFilial("SE2")))

		While !PZE->(Eof()) .And. xFilial("SE2") == PZE->PZE_FILIAL

			If PZE->PZE_PORAUT == "S"

				If Alltrim(cCampo) == "E2_PORTADO"
					cRet := PZE->PZE_BANCO
				ElseIf Alltrim(cCampo) == "E2_XAGEPOR"
					cRet := PZE->PZE_AGEN
				ElseIf Alltrim(cCampo) == "E2_XDVAPOR"
					cRet := PZE->PZE_DVAGEN
				ElseIf Alltrim(cCampo) == "E2_XCONPOR"
					cRet := PZE->PZE_CONTA
				ElseIf Alltrim(cCampo) == "E2_XDVCPOR"
					cRet := PZE->PZE_DVCONT
				EndIf

			EndIf

			PZE->(DbSkip())

		End

	EndIf

	RestArea(aArea)
Return cRet


User Function XPZECONSUL()


	Local MvPar := ""
	Local MvParDef:=""
	Local cTitulo := "Formas de Pagamento"
	Local lTipoRet := .T.
	Local l1Elem := .F.
	Local cTabela := "58"
	Local lOk := .T.
	Local lFindPg := .T.
	Local cRet := ""
	Private aCat:={}


	IF lTipoRet
		MvPar:=&(Alltrim(ReadVar()))    // Carrega Nome da Variavel do Get em Questao
		mvRet:=Alltrim(ReadVar())        // Iguala Nome da Variavel ao Nome variavel de Retorno
	EndIF

	dbSelectArea("SX5")

	If dbSeek(xFilial("SX5")+cTabela)
		CursorWait()
		aCat := {}
		While SX5->(!Eof()) .AND. SX5->X5_FILIAL == XFilial("SX5") .AND. SX5->X5_Tabela == cTabela
			Aadd(aCat,Left(SX5->X5_Chave,2) + " - " + Alltrim(X5Descri()))
			MvParDef+=Left(SX5->X5_Chave,2)
			dbSkip()
		Enddo
		CursorArrow()
	Else
		Help('',1,'FMULTIOP',,'As opções não foram inseridas!',1,0)
	Endif

	IF lTipoRet
		IF f_Opcoes(@MvPar,cTitulo,aCat,MvParDef,12,49,l1Elem,2,100,,,,,,.T.)  // Chama funcao f_Opcoes (padrão Protheus)
			&MvRet := mvpar                                         // Devolve Resultado
		EndIF
	EndIF

	/*/lFindPg := U_FindFormPG(MvPar)
	If !lFindPg
		lOk := .F.
		&MvRet := ""
	Else/*/
		If ValType(MvPar) == "C"
			MvPar := StrTokArr(AllTrim(MvPar),"|")
		EndIf
		For nX := 01 to Len(mvpar)
			If nX == 01
				cRet := +mvpar[nX]
			Else
				cRet := cRet + "|" +mvpar[nX]
			EndIf
		Next nX
		&MvRet := cRet
//	EndIf

		dbSelectArea(cAlias) // Retorna Alias
		Return .T.


User Function FindFormPG(mvpar)

	Local aArea := GetArea()
	Local nX := 01
	Local nG := 01
	Local nY := 01
	Local nZ := 01
	Local cFormsPg := ""
	Local lRet := .T.
	Local cFil := ""
	Local nCount := 0
	Local aColsPZE := aClone(oGet:aCols)
	Local aHeadPZE := aClone(oGet:aHeader)
	Local cFilial  := ""
	Local aAclPos := {}
	Local nCountF1 := 0
	Local nCountF2 := 0
	Local lPzeConsul := .F.
	Local nPosFpg := Ascan(aHeadPZE,{|x|Alltrim(x[2])=="PZE_FORMPG"})

	Default mvpar := {}
	Default nRec := 0

	For nG := 1 To Len(aColsPZE)
		If 	("30" $ aColsPZE[nG][nPosFpg] .Or. "31" $ aColsPZE[nG][nPosFpg])
			nCountF1++
		EndIf

		If ("01" $ aColsPZE[nG][nPosFpg] .Or. "41" $ aColsPZE[nG][nPosFpg])
			nCountF2++
		EndIf
	Next nG

	If nCountF1 > 1
		MsgAlert("As formas de pagamento 30 e 31 não podem ser cadastradas em bancos diferentes.")
		lRet := .F.
		Return lRet
	ElseIf nCountF2 > 1
		MsgAlert("As formas de pagamento 01 e 41 não podem ser cadastradas em bancos diferentes.")
		lRet := .F.
		Return lRet
	EndIf


	For nG := 1 to Len(aColsPZE)
		aAclPos := StrTokArr(aColsPZE[nG][nPosFpg],"|")
		If !lRet
			Exit
		EndIf
		For nZ := 1 To Len(aAclPos)
			nCount := 0
			If !lRet
				Exit
			EndIf
			For nY := 1 To Len(aColsPZE)
				If AllTrim(aAclPos[nZ]) $ AllTrim(aColsPZE[nY][nPosFpg])
					nCount++
				EndIf
				If nCount > 1
					MsgAlert("Não é permitido cadastrar tipos de pagamentos iguais para bancos diferentes na mesma filial.")
					lRet := .F.
					Exit
				EndIf
			Next nY
		Next nZ
	Next nG

	RestArea(aArea)
Return lRet

User Function xGtFormPg()

	Local aArea := GetArea()
	Local cRet := ""
	Local cFormPg := ""
	Local cQuery := ""
	Local cAliasTmp := GetNextAlias()

	If Isincallstack("GPEM670")
		If __RETGP670 == "1"//Variavel pública dentro do PE GP670ARR para validar se não retorna o portador
			Return "   "
		EndIF
	EndIf

	cFormPg := M->E2_FORMPAG

	cQuery := " SELECT * FROM " + RetSqlName("PZE")
	cQuery += " WHERE D_E_l_E_T_ = ' ' "
	cQuery += " AND PZE_FILIAL = '"+xFilial("SE2")+"'"
	If !Empty(cFormPg) .And. !IsInCallStack("T_AE_DV003")
		cQuery += " AND PZE_FORMPG LIKE '%"+cFormPg+"%'"
	Else
		cQuery += " AND PZE_PORAUT = 'S'"
	EndIf

	If Select( cAliasTmp ) > 0
		( cAliasTmp )->( DbCloseArea() )
	EndIf

	TcQuery cQuery Alias ( cAliasTmp ) New

	If !( cAliasTmp )->( Eof() )
		cRet := ( cAliasTmp )->PZE_BANCO
		M->E2_XAGEPOR := ( cAliasTmp )->PZE_AGEN
		M->E2_XDVAPOR := ( cAliasTmp )->PZE_DVAGEN
		M->E2_XCONPOR := ( cAliasTmp )->PZE_CONTA
		M->E2_XDVCPOR := ( cAliasTmp )->PZE_DVCONT
	EndIf

	( cAliasTmp )->( DbCloseArea() )

	If (ProcName(1) == "RUNTRIGGER")
		If (!Empty(M->E2_CODBAR) .And. ProcName(2) == "U_TEWBTYA1")
			If Empty(cRet)
				cRet := M->E2_PORTADO
			EndIf
			If cRet == SubStr(M->E2_CODBAR, 1, 3)
				M->E2_FORMPAG := "30"
			Else
				M->E2_FORMPAG := "31"
			EndIf
		EndIf
	EndIf


	If Empty(cRet)
		cRet := M->E2_PORTADO
	EndIf

	RestArea(aArea)
Return cRet



Static Function fRemonta(cAlias,nReg, nOpcx)

	Local aArea := GetArea()
	Local nI       := 0
	Local nX       := 0
	Local cFieldOk	    := "AllwaysTrue()"
	Local nUsado, nX 	:= 0
	Local aAltEnchoice	:= {}
	Local aObjects   	:= {}
	Local aSizeAut		:= MsAdvSize(.T.)
	Local lRetMod3		:= .F.
	Local aHeader   	:= {}
	Local aCols     	:= {}
	Local oFilBco
	Local oDescri
	Local cFilBco      := xFilial("PZE")
	Local cDescri	   := FwFilialName()
	Local nOpcA        := 1
	Local lRet         := .T.
	Local nAcols := 0

	lErro := .F.
	If nOpcx == 3 .Or. nOpcx == 4
		nOpcE := 3
	Else
		nOpcE := 2
	EndIf

	DbSelectArea("PZE")
	PZE->(DbSetOrder(1))

	RegToMemory("PZE",(nOpcx==3))
	RegToMemory("PZE",(nOpcx==4))

	nUsado := 0
//Início - Thais Paiva - Compatibilização P27
//DbSelectArea("SX3")
//SX3->(dbSetOrder(1))
//SX3->(dbSeek("PZE"))
	_aCmpPZE := FWSX3Util():GetAllFields( "PZE" , .T. )
//While SX3->(!Eof()) .And. (SX3->X3_ARQUIVO == "PZE")
	For _nZe := 1 to Len(_aCmpPZE)

		//If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
		//If X3USO(GetSx3Cache(_aCmpPZE[_nZe], 'X3_CAMPO')) .And. cNivel >= GetSx3Cache(_aCmpPZE[_nZe], 'X3_NIVEL')
		If cNivel >= GetSx3Cache(_aCmpPZE[_nZe], 'X3_NIVEL')
			//If !(SX3->X3_CAMPO $ "PZE_FILIAL|PZE_DESCRI")
			If !(_aCmpPZE[_nZe] $ "PZE_FILIAL|PZE_DESCRI")
				nUsado++
				//aAdd(aHeader, {ALLTRIM(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE,	SX3->X3_TAMANHO, SX3->X3_DECIMAL,"ALLWAYSTRUE()", SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})
				aAdd(aHeader, {ALLTRIM(GetSx3Cache(_aCmpPZE[_nZe], 'X3_TITULO')), GetSx3Cache(_aCmpPZE[_nZe], 'X3_CAMPO'), ;
					GetSx3Cache(_aCmpPZE[_nZe], 'X3_PICTURE'), GetSx3Cache(_aCmpPZE[_nZe], 'X3_TAMANHO'), ;
					GetSx3Cache(_aCmpPZE[_nZe], 'X3_DECIMAL'),"ALLWAYSTRUE()", GetSx3Cache(_aCmpPZE[_nZe], 'X3_USADO'), ;
					GetSx3Cache(_aCmpPZE[_nZe], 'X3_TIPO'), GetSx3Cache(_aCmpPZE[_nZe], 'X3_F3'), ;
					GetSx3Cache(_aCmpPZE[_nZe], 'X3_CONTEXT')})
				//aAdd(aAltEnchoice,SX3->X3_CAMPO)
				aAdd(aAltEnchoice,GetSx3Cache(_aCmpPZE[_nZe], 'X3_CAMPO'))
			EndIf
		EndIf

		//SX3->(dbSkip())

//End
	Next _nZe

	If nOpcx == 2
		aAltEnchoice := {}
	EndIf

	aCols := {}

	DbSelectArea("PZE")
	PZE->(DbSetOrder(2))
	PZE->(DbGoTop())

	If PZE->(dbSeek(xFilial("PZE")))

		While !PZE->(EoF()) .And. PZE->PZE_FILIAL == xFilial("PZE") // .And. PZE->PZE_BANCO == M->PZE_BANCO
			nAcols++
			aAdd(aCols,Array(nUsado+1))
			For nX := 1 To nUsado
				aCols[Len(aCols),nX] := _aColsPZE[nAcols][nX] //FieldGet(FieldPos(aHeader[nX,2])) //Ascan(_aHeadPZE,{|x|Alltrim(x[2])=="PZE_CONTA"})//
			Next

			aCols[Len(aCols),nUsado+1] := .F.

			aAdd(aAlt, Recno())

			DbSelectArea("PZE")
			PZE->(DbSkip())

			If Len(aCols) == 0
				aCols := {Array(nUsado+1)}
				aCols[1,nUsado+1] := .F.

				For nX := 1 To nUsado
					aCols[1,nX] := CriaVar(aHeader[nX,2])
				Next
			EndIf

		End

	Else

		M->PZE_FILIAL := xFilial("PZE")

		aCols := {Array(nUsado+1)}
		aCols[1,nUsado+1] := .F.

		For nX := 1 to nUsado
			If  "PZE_ITEM" $ aHeader[nX,2]
				aCols[1,nX] := "1"
			Else
				aCols[1,nX] := CriaVar(aHeader[nX,2])
			EndIf
		Next

	EndIf

	DbSelectArea("PZE")
	PZE->(DbSetOrder(2))

	aObjects := {}
	AAdd( aObjects, { 315,  30, .T., .T. } )
	AAdd( aObjects, { 100,  70, .T., .T. } )

	aInfo 	:= { aSizeAut[ 1 ], aSizeAut[ 2 ],aSizeAut[ 3 ] ,aSizeAut[ 4 ], 3, 3 }
	aPosObj 	:= MsObjSize( aInfo, aObjects )

	aPosEnchoice 		:= aClone(aPosObj[1])
	aPosEnchoice[4] 	:= NoRound(aPosEnchoice[4]*1)

	DEFINE MSDIALOG oDlgPri TITLE OemToAnsi("Filial x Banco") FROM 0,0 TO 420, 870 OF oMainWnd PIXEL

	@ 36,010 SAY "Filial:"                SIZE 050,07  OF oDlgPri PIXEL
	@ 35,032 MSGET oFilBco  VAR cFilBco   SIZE 030,04  OF oDlgPri PIXEL HASBUTTON When .F.

	@ 36,080 SAY "Descrição:"             SIZE 050,07  OF oDlgPri PIXEL
	@ 35,110 MSGET oDescri  VAR cDescri   SIZE 120,04  OF oDlgPri PIXEL HASBUTTON When .F.

	oGet := MsNewGetDados():New(50,0,200,437;
		,nOpcF,,, "++PZE_ITEM",aAltEnchoice,0,999,cFieldOk,,,oDlgPri,aHeader,aCols )

	ACTIVATE MSDIALOG oDlgPri ON INIT EnchoiceBar(oDlgPri,{|| nOpca := 1, oDlgPri:End()},{|| nOpca := 2, oDlgPri:End()}) CENTERED

	If nOpca == 1
		U_GrvPZE()
	EndIf

	RestArea(aArea)

Return
