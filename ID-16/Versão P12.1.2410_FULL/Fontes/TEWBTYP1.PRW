#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "PARMTYPE.CH"
#INCLUDE "TOTVS.CH"
#Include 'TopConn.Ch'

/*
{Protheus.doc} RDFINSCH 
Geração de borderô automático por banco e forma de pagamento, via schedule. 
@Author     Thiago Goes do Nascimento
@Since      26/10/2020     
@Version    P12.1.27
@Parametros MV_XFILBOR, parametro criado para executar por filial, para executar para todas, excluir o conteudo do parametro.
@Return
*/

User Function TEWBTYP1(aDadosEmp)

	DEFAULT cEmp := "01"
	DEFAULT cFil := "01010004"
	DEFAULT cModulo := "FIN"
	DEFAULT aDadosEmp := {"01","01010004"}

	If !IsBlind()
		U_TEWBT12(.F.)
	Else
		U_RDFINSCH(aDadosEmp)
	EndIf

Return

User Function RDFINSCH(aDadosEmp)

	Local nCFil := 0 //Thais Paiva - 13341866
	Local nDataBord   := 0
	Local nX 		  := 0
	Local nY          := 0
	Local nDMesAtu    := 0
	Private nQtMeses    := 0
	Private lSchedule := .T.
	Private aRecnoSM0 := {}
	Private _aFilias  := {}
	Private cFilSched := " "
	Private cFIlIni  := ""
	Private cFilFim  := ""
	Private cDataExe := " "
	Private cDataAtu := " "
//Private nCFil    := " " Thais Paiva - 13341866
	Private aSM0     := {}
	Private cDiaI	 := ""
	Private cQryDias := ""
	Private cQryMes  := ""
	Private nCountMes := 0
	Private dbkpdt  := NIL

	DEFAULT cEmp := "01"
	DEFAULT cFil := "01010004"
	DEFAULT cModulo := "FIN"
	DEFAULT aDadosEmp := {"01","01010004"}

	//RPCSetType(3)

	#IFDEF TOP
		SetTopType("A")
	#ENDIF

	//RpcSetType( 3 )
	//PREPARE ENVIRONMENT EMPRESA ( cEmp ) FILIAL ( cFil ) MODULO cModulo TABLES "SX2", "SX5"
	//RpcSetEnv(cEmp, cFil )
	//RpcSetEnv(aDadosEmp[01], aDadosEmp[02])

	dbkpdt := DatE()
	aArea0 := GetArea()

	cDataAtu  := DTOS(DatE())
	cFilSched := Alltrim(SUPERGETMV("MV_XFILBOR",.F., " "))
	nDataBord := GetNewPar("FS_XDSCHBO",2) + 1
	cDiaI       := DtoS(DataValida(DatE(),.T.))

	For nX := 01 to nDataBord
		If nX == 01
			cDataExe    := DtoS(DataValida(DatE(),.T.))
		Else
			cDataExe    := DtoS(DataValida(Stod(cDataExe),.T.))
		EndIf
	Next nX

	If Month(StoD(cDataExe)) <> Month(StoD(cDiaI))
		nQtMeses := 2

		/*/For nY := 01 To nDataBord
		If Month(StoD(cDiaI)) == //Month(DataValida(DaySum(ddatabase, nY),.T.))
			nDMesAtu++
		EndIf
		Next nY/*/
		nDMesAtu := DateWorkDay( DatE(), LastDay(DatE(),2) , .F. , .F. ,.F. )

		For nX := 01 To nQtMeses
			If nX == 01
				For nY := 1 To nDMesAtu
					If nY == 1
						cQryDias := "("
						cDataExe := DtoS(DataValida(DatE(),.T.))
						cQryDias += "'"+cDataExe+"',"
					EndIf
					If nY > 1 .And. nY < nDMesAtu
						cDataExe := DtoS(DataValida(DaySum(sTod(cDataExe), 1),.T.))
						cQryDias += "'"+cDataExe+"',"
					EndIf
					If nY == nDMesAtu
						If Month(StoD(cDataExe)) <> Month(DataValida(DaySum(sTod(cDataExe), 1),.T.))
							cQryDias += "'"+cDataExe+"')"
						Else
							cDataExe := DtoS(DataValida(DaySum(sTod(cDataExe), 1),.T.))
							cQryDias += "'"+cDataExe+"')"
						EndIf
					EndIf
				Next nY
			Else
				For nY := 1 To nDataBord-nDMesAtu
					If nY == 1
						cQryMes := "("
						cDataExe := DtoS(DataValida(FirstDate(MonthSum(STOD(cDataExe),1),.T.)))
						cQryMes += "'"+cDataExe+"',"
					EndIf
					If nY > 1 .And. nY < nDataBord-nDMesAtu
						cDataExe := DtoS(DataValida(DaySum(sTod(cDataExe), 1),.T.))
						cQryMes += "'"+cDataExe+"',"
					EndIf
					If nY == nDataBord-nDMesAtu
						cDataExe := DtoS(DataValida(DaySum(sTod(cDataExe), 1),.T.))
						cQryMes += "'"+cDataExe+"')"
					EndIf
				Next nY
			EndIf
		Next nX
	Else
		For nY := 1 To nDataBord
			If nY == 1
				cQryDias := "("
				cDataExe := DtoS(DataValida(DatE(),.T.))
				cQryDias += "'"+cDataExe+"',"
			EndIf
			If nY > 1 .And. nY < nDataBord
				cDataExe := DtoS(DataValida(DaySum(sToD(cDataExe), 1),.T.))
				cQryDias += "'"+cDataExe+"',"
			EndIf
			If nY == nDataBord
				cDataExe := DtoS(DataValida(DaySum(sTod(cDataExe), 1),.T.))
				cQryDias += "'"+cDataExe+"')"
			EndIf

		Next nY
	EndIf


	If !Empty(cFilSched)
		aSM0   := separa(cFilSched,";")
	Else
		//aSM0   := FWLoadSM0()
		aSM0 := fGetFil()
	EndIf

	//RpcClearEnv()

	For nCFil := 1 to Len(aSM0)
		conout( "JOBBORAUT: Processando filial:" + cEmp+ "|" + aSM0[nCFil] )
		//RpcSetType(3)
		cFilAnt := aSM0[nCFil]
		/*/If nQtMeses > 1
		For nX := 1 To nQtMeses
			nCountMes := nX
			If nCountMes > 1
				dDataBase := Lastday(MonthSum(dbkpdt,nCountMes-1),  1)
			EndIf
			If IsBlind()
				BatchProcess("TEWBTYP1", "TEWBTYP1", "TEWBTYP1JOB", {|| U_TEWBT12(lSchedule)}, {|| .F. })
			Else
				U_TEWBT12(lSchedule)
			EndIf
			dDataBase := dbkpdt
		Next nX
		Else/*/
		If IsBlind()
			BatchProcess("TEWBTYP1", "TEWBTYP1", "TEWBTYP1", {|| U_TEWBT12(lSchedule)}, {|| .F. })
		Else
			U_TEWBT12(lSchedule)
		EndIf
		//EndIf
//	startjob("U_TEWBTYP1",getenvserver(),.F., lSchedule,aSM0[nCFil][1],aSM0[nCFil][2] )
		// Fina435( {aSM0[nCFil][SM0_GRPEMP], aSM0[nCFil][SM0_CODFIL]})
		//RpcClearEnv()
		conout( "JOBBORAUT: Processamento da filial:" + cEmp + "|" + aSM0[nCFil] + " Concluido!")
	Next nCFil

/*
 dbSelectArea("SM0")
 SM0->(dbGoTop())

	While !SM0->( EOF() )
	// SÃ³ adiciona no aRecnoSM0 se a empresa for diferente 
	aAdd( aRecnoSM0, { SM0->M0_CODFIL } )

	cEmpAtu := Alltrim(SM0->M0_CODIGO)	
	cFilAtu := Alltrim(SM0->M0_CODFIL)
	
	AADD( _aFilias, {cEmp,cFil} ) 

	SM0->( dbSkip() )

	EndDo
 
	For nX:=1 to Len(_aFilias)
    cEmp := _aFilias[nX,1]
	cFil := _aFilias[nX,2]
     
    RpcSetType( 3 )
    PREPARE ENVIRONMENT EMPRESA ( cEmp ) FILIAL ( cFil ) MODULO cModulo

 //   StartJob("U_TEWBTYP1",GetEnvServer(),.T.,[lSchedule]) 
	U_TEWBTYP1(lSchedule)

	RESET ENVIRONMENT   
	Next nX
 */
// U_TEWBTYP1(lSchedule)

	If lSchedule
		//	RpcClearEnv()
	EndIf


	RestArea(aArea0)
Return


/*
{Protheus.doc} TEWBTYP1
Geração de borderô automático por banco e forma de pagamento. 
@Author     Ramon Teodoro e Silva
@Since      11/11/2016     
@Version    P12.7
@Return
*/

User Function TEWBT12(lSchedule)

	Local lRet := .T.
	Local oProcess	:= Nil
	Local oSelf
	Default lSchedule := .F.

	If !lSchedule
		oProcess := tNewProcess():New( "TEWBTYP1", "Boderôs Automáticos",{|oSelf| U_AutoProc(oSelf,lSchedule)}, "Este programa tem como objetivo gerar borderôs automaticamente para pagamento a fornecedores via transferência bancária.", "TEWBTYP1",,.F.,,"",.F.,.T.) //"Borderôs automáticos"###"Este programa tem como objetivo gerar borderôs automaticamente para pagamento a fornecedores via transferência bancária."
		FreeObj(oProcess)
		DelClassIntf()
	Else
//	RpcSetType(3)
//	RpcSetEnv(cEmp, cFil)
		//U_TEWBTYP1(lSchedule)][SM0_GRPEMP], aSM0[nCFil][SM0_CODFIL]})
		Pergunte("TEWBTYP1",.F.)
		U_AutoProc(oSelf,lSchedule)
		//RpcClearEnv()
	EndIf

Return lRet

/*
{Protheus.doc} AutoProc
Gera automaticamente os borderôs de pagamento.
A geração é através do FINA241 (borderô com impostos)
@Author     Ramon Teodoro e Silva
@Since      11/11/2016     
@Version    P12.7
@Return
*/

User Function AutoProc(oSelf,lSchedule)
	Local nBco			:= 0
	Local cQuery		:= ""
	Local cAliasTmp		:= ""
	Local c245ArqTit	:= ""
	Local cAliasSE2		:= ""
	Local dDtBor		:= Ctod("//")
	Local aArea			:= {}
	Local aBcos			:= {}
	Local aSelFil	    := {}
	Private aEstr := {}

	If !lSchedule
		If mv_par01 == 1
			aSelFil := AdmGetFil() //AdmGetFil(.T.,.T.,"SE2")
			If Len( aSelFil ) <= 0
				Return
			EndIf
		Else
			aSelFil := {}
		EndIf

		aArea := GetArea()
		MsgRun("Verificando o cadastro de bancos","",{|| CursorWait(),U_BASelBco(@aBcos, aSelFil,lSchedule),"Geração automática de borderôs",CursorArrow()})
		If Empty(aBcos)
			MsgAlert("Não há bancos configurados para geração automática de borderôs")
		Else
			MsgRun("Verificando os títulos a pagar.","",{|| CursorWait(),U_BASelTit(@aBcos,@c245ArqTit,@cAliasSE2,aSelFil,oSelf,lSchedule),"Geração automática de borderôs",CursorArrow()})
			If Empty(cAliasSE2)
				MsgAlert("Não foram encontrados títulos para geração dos borderôs.")
			EndIf
		Endif
	Else
		aArea := GetArea()
		U_BASelBco(@aBcos, aSelFil,lSchedule)
		If !Empty(aBcos)
			U_BASelTit(@aBcos,@c245ArqTit,@cAliasSE2,aSelFil,oSelf,lSchedule)
		Endif
	EndIf

	RestArea(aArea)
	aSize(aArea,0)
	aArea := Nil
Return()


//-----------------------------------------------------------------------------------------------------
/*/
/*/
//-----------------------------------------------------------------------------------------------------
User Function BASelBco(aBcos, aSelFil, lSchedule)
	Local nBco		:= 0
	Local nLen		:= 0
	Local cQuery	:= ""
	Local cAliasTmp	:= ""
	Local cChvBco	:= ""
	Local aArea		:= {}
	Local aBcosTmp	:= {}
	Local cFilFwSA6 := xFilial("SA6")
	Local cFilFwSEE := xFilial("SEE")

	Default lSchedule := .F.

	Default aBcos	:= {}

	cQuery := "SELECT DISTINCT A6_COD,A6_AGENCIA,A6_NUMCON,A6_MOEDA,A6_NOME,EE_PERMPG,EE_DTVALID FROM " + RetSQLName("SA6") + " SA6, " + RetSQLName("SEE") + " SEE "

	If !lSchedule .And. !Empty(aSelFil)
		If Empty( cFilFwSA6 )
			cQuery += " WHERE A6_FILORIG " + GetRngFil( aSelFil, "SA6", .T., "")
		Else
			cQuery += " WHERE A6_FILIAL " + GetRngFil( aSelFil, "SA6", .T., "" )
		EndIf
	Else
//	If Empty(cFilIni) 
//		cQuery += " WHERE A6_FILIAL BETWEEN '"+cFilIni+"' AND '"+cFilFim+"'" 
		cQuery += " WHERE A6_FILIAL = '"+cFilAnt+"'"
//	Else 
//		cQuery += " WHERE A6_FILIAL IN "+FormatIN(Alltrim(cFilIni),";")
//	EndIf
	EndIf


	cQuery += " AND SA6.D_E_L_E_T_= ' '"

	If !lSchedule .And. !Empty(aSelFil)
		If Empty( cFilFwSEE )
			cQuery += " AND EE_FILIAL " + GetRngFil( aSelFil, "SEE", .T., "")
		Else
			cQuery += " AND EE_FILIAL " + GetRngFil( aSelFil, "SEE", .T., "" )
		EndIf
	Else
		//cQuery += " AND EE_FILIAL BETWEEN ' ' AND 'ZZZZZZZZZZZ' "
		cQuery += " AND EE_FILIAL = '"+cFilAnt+"'"
	Endif

	cQuery += " AND EE_CODIGO = A6_COD"
	cQuery += " AND EE_AGENCIA = A6_AGENCIA"
	cQuery += " AND EE_CONTA = A6_NUMCON"
	cQuery += " AND EE_PERMPG = '1'"
	cQuery += " AND "
	cQuery += " ("
	cQuery += "EE_DTVALID = '" + Space(8) + "'"
	cQuery += " OR "
	If lSchedule
		cQuery += "EE_DTVALID >= '" + 	cDataAtu + "'"
	Else
		cQuery += "EE_DTVALID >= '" + Dtos(DatE()) + "'"
	EndIf
	cQuery += ")"
	cQuery += " AND SEE.D_E_L_E_T_= ' '"

	cQuery += " ORDER BY A6_COD,A6_AGENCIA,A6_NUMCON"
	cQuery := ChangeQuery( cQuery )
	cAliasTmp := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)
	While !((cAliasTmp)->(Eof()))
		cChvBco := (cAliasTmp)->A6_COD
		Aadd(aBcosTmp,{})
		nLen := Len(aBcosTmp)
		While !((cAliasTmp)->(Eof())) .And. (cAliasTmp)->A6_COD == cChvBco
			Aadd(aBcosTmp[nLen],{(cAliasTmp)->A6_COD,(cAliasTmp)->A6_AGENCIA,(cAliasTmp)->A6_NUMCON,(cAliasTmp)->A6_MOEDA,(cAliasTmp)->A6_NOME})
			(cAliasTmp)->(DbSkip())
		Enddo
	Enddo
	DbSelectArea(cAliasTmp)
	DbCloseArea()
/*
Verificando se ha mais de uma conta em um mesmo banco. Se afirmativo, pede ao usuario
para definir qual sera utilizada. */
nBco := 0
nLen := Len(aBcosTmp)
cChvBco := ""
aBcos := {}

	For nBco := 1 To Len(aBcosTmp)
	nLen := Len(aBcosTmp[nBco])
		If nLen > 1
		Aadd(aBcos,aBcosTmp[nBco,nLen,1]/*,aBcosTmp[nBco,nLen,2],aBcosTmp[nBco,nLen,3],aBcosTmp[nBco,nLen,4],aBcosTmp[nBco,nLen,5],0*/)
		Else
		Aadd(aBcos,aBcosTmp[nBco,1,1] /*,aBcosTmp[nBco,1,2],aBcosTmp[nBco,1,3],aBcosTmp[nBco,1,4],aBcosTmp[nBco,1,5],0*/)
		Endif
	Next

Asize(aBcosTmp,0)
Return()

//-----------------------------------------------------------------------------------------------------
/*/
/*/
//-----------------------------------------------------------------------------------------------------
User Function BASelTit(aBcos,c245ArqTit,cAliasSE2,aSelFil,oSelf,lSchedule)
Local _aAreaTit := GetArea() //Thais Paiva - 13341866
Local cQuery	 := ""
Local cAliasTmp	 := ""
Local cFiltro	 := ""
Local nBco		 := 0
Local cFilFwSE2  := xFilial("SE2")
Local cFilFwSA6  := xFilial("SA6")
Local nSaldo     := 0
Local nLimite    := MV_PAR04
Local dDtBor     := MV_PAR05	
Local lMostraLan := .F.
Local lMostraLog := (MV_PAR06 == 1)
Local aBorderos	 := {}
Local aRetBor    := {}
Local cBkpFil    := cFilAnt
Local nH := 01
Local aDts := {}
Local dDt := StoD("")
Local cPortados := ""
Local cChave  := ""
Local aResumo := {}


Private aListCNAB := {}
//Local cVenctoSch := Dtos(dDataBase+1)									   
Default lSchedule := .F.

cAliasSE2 := ""
c245ArqTit := ""

	For nBco := 1 To Len(aBcos)
		If nBco > 1
		cPortados += ","
		Endif
	cPortados += "'" + aBcos[nBco] + "'"
	Next

//cQuery := "SELECT E2_FILIAL, E2_MOEDA, E2_PORTADO, E2_XAGEPOR, E2_XCONPOR, E2_SALDO, E2_FORMPAG, E2_XMIGLT, SE2.R_E_C_N_O_, A6_NOME FROM " + RetSQLName("SE2") + " SE2, " + RetSQLName("SA6") + " SA6 "

If !lSchedule
	While dDt < MV_PAR03 

	If MV_PAR02 == MV_PAR03
		If Empty(aDts)
		AADD(aDts,DtoS(MV_PAR02))
		dDt := MV_PAR02
		EndIf
		dDt := DaySum(dDt,1)
	Else
		If Empty(dDt)
			AADD(aDts,DtoS(MV_PAR02))
			dDt := MV_PAR02
		Else
			AADD(aDts,DtoS(DaySum(dDt,1)))
			dDt := DaySum(dDt,1)
		EndIf
	EndIf
	EndDo
Else
	aDts := StrToKarr(Replace(Replace(Replace(cQryDias+cQryMes,")",""),"(",","),"'"),",")
EndIf

For nH := 01 To Len(aDts)
If lSchedule
	If Month(sToD(aDts[nH])) > Month(DatE())
		ddatabase := Lastday(MonthSum(dbkpdt,1),  1)
		dDtBor     := Lastday(MonthSum(dbkpdt,1),  1)
	Else
		dDtBor := DatE()
	EndIf
EndIf
cQuery := "SELECT  E2_FILIAL,E2_MOEDA,E2_PORTADO,E2_XAGEPOR,E2_XCONPOR,E2_SALDO,E2_FORMPAG,E2_XMIGLT,SE2.R_E_C_N_O_,A6_NOME,  CASE WHEN (SE2.E2_XMIGLT <> ' ') THEN '1' ELSE ' ' END XMIGLT FROM SE2010 SE2 , SA6010 SA6 " 

	If !lSchedule .And. !Empty(aSelFil)
		If Empty( cFilFwSE2 )
			cQuery += " WHERE E2_FILORIG " + GetRngFil( aSelFil, "SE2", .T., "")  	
		Else
			cQuery += " WHERE E2_FILIAL " + GetRngFil( aSelFil, "SE2", .T., "" )  
		EndIf
		cQuery += " AND E2_VENCREA = '"+aDts[nH]+"' "
	Else
		cQuery += " WHERE E2_FILIAL = '"+cFilAnt+"'" 
		cQuery += " AND E2_VENCREA = '"+aDts[nH]+"' "
	Endif

cQuery += " AND E2_PORTADO IN (" + cPortados + ")"
cQuery += " AND SE2.D_E_L_E_T_= ' '"


cQuery += " AND A6_FILIAL = E2_FILIAL"

cQuery += " AND A6_COD = E2_PORTADO"
cQuery += " AND A6_AGENCIA = E2_XAGEPOR"

cQuery += " AND A6_NUMCON = E2_XCONPOR"

cQuery += " AND SA6.D_E_L_E_T_ = ' '"

/*
Condicoes executada pela fina241 e fina240 para completar a selecao dos titulos: verifica o tipo do titulo,
saldo, se ja pertence a um bordero etc. */
cFiltro := U_BAChec2()
cQuery += " AND " + cFiltro
cQuery += " AND NOT E2_ORIGEM = 'SIGAEFF'"
/*-*/
cQuery += " ORDER BY E2_FILIAL, E2_PORTADO, E2_FORMPAG, XMIGLT "
cQuery := ChangeQuery(cQuery)  
cAliasTmp := GetNextAlias() 			
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)
If !((cAliasTmp)->(Eof()))

	Aadd(aEstr,{"NUM_REG","N",10,0})
	Aadd(aEstr,{"E2_FORBCO" ,"C",TamSX3("E2_FORBCO")[1],0})
	Aadd(aEstr,{"E2_PORTADO","C",TamSX3("E2_PORTADO")[1],0})
	Aadd(aEstr,{"E2_XAGEPOR","C",TamSX3("E2_XAGEPOR")[1],0})
	Aadd(aEstr,{"E2_XCONPOR","C",TamSX3("E2_XCONPOR")[1],0})
	Aadd(aEstr,{"E2_FORMPAG","C",TamSX3("E2_FORMPAG")[1],0})
	Aadd(aEstr,{"E2_XMIGLT","C",TamSX3("E2_XMIGLT")[1],0})
	c245ArqTit := CriaTrab(,.F.) 
	DbCreate(c245ArqTit,aEstr,"TOPCONN")
	cAliasSE2 := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",c245ArqTit,cAliasSE2,.F.,.F.)
	Asize(aEstr,0)
	aEstr := {}
	/*-*/
	(cAliasTmp)->(DbGoTop())
	
	cChave := (cAliasTmp)->(E2_FILIAL+E2_PORTADO+E2_FORMPAG+XMIGLT)
	
	If !lSchedule
	//	oSelf:SaveLog("Início do processo")
	//	oSelf:SetRegua1(Len(aBcos))
	EndIf
	
	While !((cAliasTmp)->(Eof()))
					
		nSaldo   += (cAliasTmp)->E2_SALDO
		cModPag  := (cAliasTmp)->E2_FORMPAG
		cNomeBco := (cAliasTmp)->A6_NOME

		Begin Transaction
						
			If nLimite <= 0 .Or. nSaldo <= nLimite
			cFilAnt := (cAliasTmp)->E2_FILIAL
			RecLock(cAliasSE2,.T.)
		//Início Thais Paiva - 13341866
			/*Replace (cAliasSE2)->NUM_REG	With (cAliasTmp)->R_E_C_N_O_
			Replace (cAliasSE2)->E2_FORBCO	With (cAliasTmp)->E2_PORTADO
			Replace (cAliasSE2)->E2_PORTADO	With (cAliasTmp)->E2_PORTADO
			Replace (cAliasSE2)->E2_XAGEPOR	With (cAliasTmp)->E2_XAGEPOR
			Replace (cAliasSE2)->E2_XCONPOR	With (cAliasTmp)->E2_XCONPOR
			Replace (cAliasSE2)->E2_FORMPAG With (cAliasTmp)->E2_FORMPAG
			Replace (cAliasSE2)->E2_XMIGLT  With (cAliasTmp)->XMIGLT*/
			(cAliasSE2)->NUM_REG 	:= (cAliasTmp)->R_E_C_N_O_
			(cAliasSE2)->E2_FORBCO	:= (cAliasTmp)->E2_PORTADO
			(cAliasSE2)->E2_PORTADO	:= (cAliasTmp)->E2_PORTADO
			(cAliasSE2)->E2_XAGEPOR	:= (cAliasTmp)->E2_XAGEPOR
			(cAliasSE2)->E2_XCONPOR	:= (cAliasTmp)->E2_XCONPOR
			(cAliasSE2)->E2_FORMPAG := (cAliasTmp)->E2_FORMPAG
			(cAliasSE2)->E2_XMIGLT  := (cAliasTmp)->XMIGLT
			(cAliasSE2)->(MsUnLock()) 
			Endif
		End Transaction
		//Fim Thais Paiva - 13341866
		(cAliasTmp)->(DbSkip())
		
		If cChave <> (cAliasTmp)->(E2_FILIAL+E2_PORTADO+E2_FORMPAG+XMIGLT)
			cChave  := (cAliasTmp)->(E2_FILIAL+E2_PORTADO+E2_FORMPAG+XMIGLT)
			(cAliasSE2)->(DbGoTop())
			//If Alltrim((cAliasSE2)->E2_PORTADO) == "104" 
			//	aRetBor := {cAliasSE2,(cAliasSE2)->E2_PORTADO, (cAliasSE2)->E2_XAGEPOR, (cAliasSE2)->E2_XCONPOR, cModPag, "20",dDtBor,lMostraLan}
			//ElseIf Alltrim((cAliasSE2)->E2_PORTADO) == "001" 
			//	aRetBor := {cAliasSE2,(cAliasSE2)->E2_PORTADO, (cAliasSE2)->E2_XAGEPOR, (cAliasSE2)->E2_XCONPOR, cModPag, IIF( cModPag $ "01|03|41|30|31", "20", "98"),dDtBor,lMostraLan}
			//Else
			//	aRetBor := {cAliasSE2,(cAliasSE2)->E2_PORTADO, (cAliasSE2)->E2_XAGEPOR, (cAliasSE2)->E2_XCONPOR, cModPag, IIF( cModPag $ "11|16|17|18|19|21|22|25|27|35|91", "22", "20"),dDtBor,lMostraLan}
			//EndIf

			aRetBor := {cAliasSE2,(cAliasSE2)->E2_PORTADO, (cAliasSE2)->E2_XAGEPOR, (cAliasSE2)->E2_XCONPOR, cModPag, IIF( cModPag $ "11|16|17|18|19|21|22|23|24|25|26|27|35|91", "22", "20"),dDtBor,lMostraLan}

			
			If Len(aRetBor) > 0
				//If !Empty((cAliasSE2)->E2_XMIGLT) Thais Paiva - 9602422
				If !Empty(Alltrim((cAliasSE2)->E2_XMIGLT))
					U_GBordMig(aRetBor, lSchedule)
				Else
					FINA241(0,aRetBor)
				EndIf
			EndIf
			
			If Len(aRetBor) < 10
				Loop
			EndIf
			If !lSchedule
				oSelf:SaveLog("Borderô: " + Alltrim(aRetBor[9]) + " Banco: " + AllTrim(aRetBor[2]) + "-" + AllTrim(aRetBor[3]) + "-" + AllTrim(aRetBor[4]) + " Modelo: " + Alltrim(aRetBor[5]))  
			EndIf
			Aadd(aBorderos,{aRetBor[2],aRetBor[3],aRetBor[4],cNomeBco,aRetBor[9],aRetBor[10],cModPag,Alltrim(cFilAnt+ "-" + FwFilName(cEmpAnt,cFilAnt)), nSaldo})
			Aadd(aResumo,{aRetBor[2],aRetBor[3],aRetBor[4],cNomeBco,aRetBor[9],aRetBor[10],cModPag,Alltrim(cFilAnt+ "-" + FwFilName(cEmpAnt,cFilAnt)), nSaldo})
			nSaldo  := 0
			U_DelTrab(cAliasSE2)		
		EndIf
		
	//End Transaction Thais Paiva - 13341866
	EndDo
	
	
	cFilAnt := cBkpFil
	
	If !lSchedule
		oSelf:SaveLog("Fim do processo")
	EndIf
	DbSelectArea(cAliasSE2)
	(cAliasSE2)->(DbCloseArea())
	TcDelFile(c245ArqTit)
	/*/
	If !Empty(aBorderos) .And. lMostraLog .And. !lSchedule
		U_ResumeBA(@aBorderos)
	Endif/*/

	If GetNewPar("FS_XGERCNB",1) == 1
		If (!Empty(aBorderos) .And. lSchedule)
		aListCNAB := aclone(aBorderos)
		fCriaCNAB(aListCNAB)
		EndIf
	Else
		Conout("TEWBTYP1 - Schedule de Borderô - Não será criado o arquivo de CNAB porque o parâmero FS_XGERCNB está com o conteúdo diferente de 1")
	EndIf
	
	aSize(aBcos,0)
	aBcos := {}
	aSize(aRetBor,0)
	aRetBor := {}
	aSize(aBorderos,0)
	aBorderos := {}
	
Endif
DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbCloseArea())
If lSchedule
ddatabase := dbkpdt
EndIf
Next nH
If !Empty(aResumo) .And. lMostraLog .And. !lSchedule
		U_ResumeBA(@aResumo)
	Endif
RestArea(_aAreaTit) //Thais Paiva - 13341866
Return()


//-----------------------------------------------------------------------------------------------------
/*/
/*/
//-----------------------------------------------------------------------------------------------------
User Function ResumeBA(aBorderos)
Local oSize1	:= Nil
Local oSize		:= Nil
Local oDlg		:= Nil
Local oBrwBor	:= Nil

Default aBorderos	:= {}
Default lSchedule := .F.

	If !Empty(aBorderos)
	oSize1 := FWDefSize():New(.T.)
	oSize1:lLateral := .F.
	oSize1:lProp	:= .T. 
	oSize1:Process()
		
	DEFINE MSDIALOG oDlg TITLE "Relação de borderôs gerados"  From oSize1:aWindSize[1],oSize1:aWindSize[2] to oSize1:aWindSize[3]/2,oSize1:aWindSize[4]/2 OF oMainWnd PIXEL		//"Relação de borderôs gerados" 
		oSize := FwDefSize():New(.T.,,,oDlg)
		oSize:AddObject("PNLCEN",100,100,.T.,.T.)
		oSize:lProp	:= .T.             
		oSize:aMargins := {3,3,3,3}  
		oSize:Process()	
	
		oBrwBor := TCBrowse():New(oSize:GetDimension("PNLCEN","LININI"),oSize:GetDimension("PNLCEN","COLINI"),oSize:GetDimension("PNLCEN","XSIZE")-6,oSize:GetDimension("PNLCEN","YSIZE"),,,,oDlg,,,,,,,,,,,,.T.,"",.T.,{|| .T.},,,,)
		oBrwBor:AddColumn(TCColumn():New("Filial" ,{|| aBorderos[oBrwBor:nAt,8]},,,,"LEFT",60,.F.,.F.,,,,,))		//"Filial"
		oBrwBor:AddColumn(TCColumn():New("Borderô",{|| aBorderos[oBrwBor:nAt,5]},,,,"LEFT",40,.F.,.F.,,,,,))		//"Borderô"
		oBrwBor:AddColumn(TCColumn():New("Títulos",{|| aBorderos[oBrwBor:nAt,6]},,,,"LEFT",40,.F.,.F.,,,,,))		//"Títulos"
		oBrwBor:AddColumn(TCColumn():New("Valor"  ,{|| aBorderos[oBrwBor:nAt,9]},"@E 99,999,999.99",,,"LEFT",40,.F.,.F.,,,,,))		//"Valor"
		oBrwBor:AddColumn(TCColumn():New(SA6->(RetTitle("A6_COD")),{|| aBorderos[oBrwBor:nAt,1]},,,,"LEFT",20,.F.,.F.,,,,,))
		oBrwBor:AddColumn(TCColumn():New(SA6->(RetTitle("A6_AGENCIA")),{|| aBorderos[oBrwBor:nAt,2]},,,,"LEFT",40,.F.,.F.,,,,,))
		oBrwBor:AddColumn(TCColumn():New(SA6->(RetTitle("A6_NUMCON")),{|| aBorderos[oBrwBor:nAt,3]},,,,"LEFT",40,.F.,.F.,,,,,))
		oBrwBor:AddColumn(TCColumn():New(SA6->(RetTitle("A6_NOME")),{|| aBorderos[oBrwBor:nAt,4]},,,,"LEFT",30,.F.,.F.,,,,,))
		oBrwBor:AddColumn(TCColumn():New(SE2->(RetTitle("E2_FORMPAG")),{|| aBorderos[oBrwBor:nAt,7]},,,,"LEFT",20,.F.,.F.,,,,,))
		oBrwBor:SetArray(aBorderos)
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{|| oDlg:End()},,,,,,,.F.,.F.)
	
	oBrwBor := Nil
	oDlg := Nil 
	FreeObj(oSize1)
	oSize1 := Nil 
	FreeObj(oSize)
	oSize := Nil
	Endif
Return()

/*
{Protheus.doc} BAChec2
Retorna filtro para query de seleção de títulos 
@Author     Ramon Teodoro e Silva
@Since      11/11/2016     
@Version    P12.7
@Return
*/

User Function BAChec2()
	Local _aAreaCh := GetArea() //Thais Paiva - 13341866
	Local cFiltro := " "
	Local lPrjCni := ValidaCNI()
	Default lSchedule := .F.

	cFiltro += "E2_TIPO NOT IN "+FormatIn(MVPROVIS+"|"+MV_CPNEG+"|PRE"+MVABATIM,"|") +" AND "
	cFiltro += "(E2_TIPO <> '"+MVPAGANT+"' OR E2_NUMBCO ='"+ space(TAMSX3("E2_NUMBCO")[1]) + "') AND "
//Ignora os títulos que possuem cheques emitidos.
	cFiltro += " E2_IMPCHEQ <> 'S' AND "
	if lPrjCni
		cFiltro += "  E2_NUMSOL= ' '   AND  "
	EndIf
	cFIltro += "(E2_SALDO>0 AND E2_NUMBOR = '" + space(TAMSX3("E2_NUMBOR")[1]) + "')"

//³ Verifica se pode baixar sem aprova‡Æo                               ³

	If GetMv("MV_CTLIPAG")
		cFiltro += " AND (E2_DATALIB <> ' '"
		cFiltro += " OR (E2_SALDO+E2_SDACRES-E2_SDDECRE<="+ALLTRIM(STR(GetMv('MV_VLMINPG'),17,2))+"))"
	Endif

//cFiltro := '(' +cFiltro+ ') AND (' +c240FilBT+')'

Return cFiltro


/*
{Protheus.doc} DelTrab
Limpa o arquivo de trabalho para os próximos borderôs
@Author     Ramon Teodoro e Silva
@Since      11/11/2016     
@Version    P12.7
@Return
*/
User Function DelTrab(cAliasSE2)

	Local lRet  := .t.
	Local aArea := GetArea()
	Default lSchedule := .F.

	DbSelectArea(cAliasSE2)
	(cAliasSE2)->(DbGoTop())

	While (cAliasSE2)->(!Eof())
		Begin Transaction //Thais Paiva - 13341866
			RecLock(cAliasSE2,.F.,.T.)
			(cAliasSE2)->(DbDelete())
			(cAliasSE2)->(MsUnLock()) //Thais Paiva - 13341866
			(cAliasSE2)->(DbSkip())
		End Transaction //Thais Paiva - 13341866
	EndDo

	RestArea(aArea)

Return lRet

/*
{Protheus.doc} GBordMig
Limpa o arquivo de trabalho para os próximos borderôs
@Author     Ramon Teodoro e Silva
@Since      11/11/2016     
@Version    P12.7
@Return
*/
User Function GBordMig(aRetBor,lSchedule)

	Local lRet      := .t.
	Local aArea     := GetArea()
	Local cNumBor   := ""
	Local cAliasBM	:= aRetBor[1]
	Local cPortBM	:= aRetBor[2]
	Local cAgenBM	:= aRetBor[3]
	Local cContaBM	:= aRetBor[4]
	Local cModPgBM	:= aRetBor[5]
	Local cTipoPgBM	:= aRetBor[6]
	Local dDataBase	:= aRetBor[7]
	Local nQtdTit   := 0
	Local _cMVNumBor := "" //Thais Paiva - Compatibilização P27
	Default lSchedule := .F.


/*DbSelectArea("SX3")
DbSetOrder(2)
DbSeek("E2_NUM")
cUso := SX3->X3_USADO

DbSelectArea("SX3")
DbSeek("E2_SALDO")
cUsoAnt := X3_USADO
Reclock("SX3")
Replace SX3->X3_USADO With cUso
MsUnlock()

SX3->(dbSetOrder(1))*/

//DbSelectArea("SX6") Thais Paiva - Compatibilização P27
cNumBor := Soma1(Pad(GetMV("MV_NUMBORP"),Len(SE2->E2_NUMBOR)),Len(SE2->E2_NUMBOR))
//While !MayIUseCode( "E2_NUMBOR"+SX6->X6_FIL+cNumBor)  //verifica se esta na memoria, sendo usado Thais Paiva - Compatibilização P27
	While !MayIUseCode( "E2_NUMBOR"+FWFilial("SX6")+cNumBor)
	cNumBor := Soma1(cNumBor)	
	FreeUsedCode(.T.) 									// busca o proximo numero disponivel 
	End

DbSelectArea(cAliasBM)

	While !(cAliasBM)->(Eof()) .And. (cAliasBM)->E2_FORBCO == cPortBM

	SE2->(MSGOTO((cAliasBM)->NUM_REG))

	//cOldPort240 := SE2->E2_PORTADO	 
		If lSchedule
		dDataGrv := STOD(cDataAtu)
		Else
		dDataGrv := dDataBase 
		EndIf
	
		Begin Transaction //Início Thais Paiva - 13341866
	DbSelectArea("SEA")
	RecLock("SEA",.T. )
	/*Replace	EA_FILIAL	With xFilial("SEA"),;
				EA_PORTADO	With cPortBM,;
				EA_AGEDEP	With cAgenBM,;
				EA_NUMCON	With cContaBM,;
				EA_NUMBOR	With cNumBor,;
				EA_DATABOR	With dDataGrv,;
				EA_PREFIXO	With SE2->E2_PREFIXO,;
				EA_NUM		With SE2->E2_NUM,;
				EA_PARCELA	With SE2->E2_PARCELA,;
				EA_TIPO	    With SE2->E2_TIPO,;
				EA_FORNECE	With SE2->E2_FORNECE,;
				EA_LOJA	    With SE2->E2_LOJA,;
				EA_CART	    With "P",;
				EA_MODELO	With cModPgBM,;
				EA_TIPOPAG	With cTipoPgBM,;
				EA_FILORIG	With SE2->E2_FILORIG,;
				EA_ORIGEM   With "FINA241"*/
	SEA->EA_FILIAL	:= xFilial("SEA")
	SEA->EA_PORTADO := cPortBM
	SEA->EA_AGEDEP	:=  cAgenBM
	SEA->EA_NUMCON	:=  cContaBM
	SEA->EA_NUMBOR	:=  cNumBor
	SEA->EA_DATABOR := dDataGrv
	SEA->EA_PREFIXO := SE2->E2_PREFIXO
	SEA->EA_NUM		:=  SE2->E2_NUM
	SEA->EA_PARCELA := SE2->E2_PARCELA
	SEA->EA_TIPO	:= SE2->E2_TIPO
	SEA->EA_FORNECE := SE2->E2_FORNECE
	SEA->EA_LOJA	:= SE2->E2_LOJA
	SEA->EA_CART	:= "P"
	SEA->EA_MODELO	:= cModPgBM
	SEA->EA_TIPOPAG	:= cTipoPgBM
	SEA->EA_FILORIG	:= SE2->E2_FILORIG
	SEA->EA_ORIGEM  := "FINA241"
	SEA->(MsUnlock()) 
	//FKCOMMIT()
	
	RecLock("SE2")
	SE2->E2_NUMBOR  := cNumBor
	SE2->E2_PORTADO := cPortBM
	SE2->E2_DTBORDE := dDataBase
	SE2->(MsUnlock())
		END Transaction
	//Fim Thais Paiva - 13341866
	(cAliasBM)->(DbSkip())
	nQtdTit++
				
	End

Aadd(aRetBor,cNumBor)
Aadd(aRetBor,nQtdTit)

//Início - Thais Paiva - Compatibilização P27
//DbSelectArea("SX6")
_cMVNumBor := GetMv("MV_NUMBORP")
// Garante que o numero do bordero seja sempre superior ao numero anterior
//If SX6->X6_CONTEUD < cNumbor
	If _cMVNumBor < cNumbor
	//RecLock("SX6",.F.)
	//SX6->X6_CONTEUD := cNumbor
	//msUnlock()
	PutMv("MV_NUMBORP",cNumbor)
//Fim - Thais Paiva - Compatibilização P27
	Endif

RestArea(aArea)	
Return lRet	


/*

/*
{Protheus.doc} DiaUtil

A função irá considerar as datas encontradas na tabela 63 do SX5 (Tabela de Feriados), 
os sábados (caso o parâmetro MV_SABFERI seja igual a "S") e os domingos como sendo feriados, 
retornando assim a próxima data válida.

@Author     Thiago Goes do Nascimento
@Since      10/11/2020   
@Version    P12.1.27
@Return dNewData
*/

Static Function DiaUtil

	Local dDataHj := ddatabase+1
	Local lNext	:= .T.
	Local dNewData := DataValida(dDataHj, lNext)

//ApMsgAlert("Proxima data válida será: "+ Dtoc(dNewData)+ ' - ' +DiaExtenso(dNewData))

Return dNewData

/*
SELECT 
CASE WHEN DIA IN (
    SELECT 
case
      when (length(trim(SUBSTR(X5_DESCRI,1,8))))<=5 then  trim(SUBSTR(X5_DESCRI,1,5))||'/'||to_char(sysdate, 'YY')
else
        trim(SUBSTR(X5_DESCRI,1,8))
End feriado
        from SX5010 X5
        WHERE X5_TABELA = '63' 
        and SUBSTR(X5_DESCRI,1,1) not like '*'
        ) THEN 'F'||(TO_NUMBER(TO_CHAR(sysdate, 'D')))
ELSE 'T'||(TO_NUMBER(TO_CHAR(sysdate, 'D')))
END EXECUTA,
     A.*
   FROM(
select
  TO_CHAR(sysdate, 'DD/MM/YY') HOJE,
CASE
      when (TO_NUMBER(TO_CHAR(sysdate, 'D'))) < 5 then  TO_CHAR(sysdate+1,'DD/MM/YY')
      
      when (TO_NUMBER(TO_CHAR(sysdate, 'D'))) = 5 then  TO_CHAR(sysdate+3,'DD/MM/YY')
      when (TO_NUMBER(TO_CHAR(sysdate, 'D'))) = 6 then  TO_CHAR(sysdate+2,'DD/MM/YY')
      when (TO_NUMBER(TO_CHAR(sysdate, 'D'))) = 7 then  TO_CHAR(sysdate+1,'DD/MM/YY')
END dia
    FROM DUAL
 ) A  
  GROUP BY A.HOJE,A.DIA
*/
//return Thais Paiva  - 13341866

/* pegar filiais da tabela*/
static Function fGetFil
	Local _aAreaFil := GetArea() //Thais Paiva - 13341866
	Local aRetFil    := {}
	Local cQry       := " "
	Local cAlias := " "

	cQry := "SELECT  E2_FILIAL FROM "+RetSqlName("SE2")+" SE2"
	//cQry += " WHERE E2_VENCREA BETWEEN '" + cDiaI + "' AND '" + cDataExe + "' AND SE2.D_E_L_E_T_= ' '  "
	If nQtMeses > 1
		cQry += " WHERE (E2_VENCREA IN "+cQryDias+" OR E2_VENCREA IN "+cQryMes+") "
	Else
		cQry += " WHERE E2_VENCREA IN "+cQryDias+" "
	EndIf

	cQry += " AND SE2.D_E_L_E_T_ = ' '"
	cQry += " AND NOT E2_ORIGEM = 'SIGAEFF'"
	cQry += " AND E2_TIPO NOT IN "+FormatIn(MVPROVIS+"|"+MV_CPNEG+"|PRE"+MVABATIM,"|") "
	cQry += " AND (E2_TIPO <> '"+MVPAGANT+"' OR E2_NUMBCO ='"+ space(TAMSX3("E2_NUMBCO")[1]) + "') "
	cQry += " AND E2_IMPCHEQ <> 'S' "
	cQry += " AND  E2_NUMSOL= ' '  "
	cQry += " AND (E2_SALDO>0 AND E2_NUMBOR = ' ')"
	cQry += "GROUP BY E2_FILIAL "


	cQry 		:= ChangeQuery(cQry)
	cAlias  := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAlias,.F.,.T.)


	While !((cAlias)->(Eof()))
		aaDD(aRetFil, (cAlias)->E2_FILIAL)
		(cAlias)->(DbSkip())
	End
	RestArea(_aAreaFil) //Thais Paiva - 13341866
Return aRetFil

Static Function fCriaCNAB(aListCNAB)

	Local aArea := GetArea()
	Local cQuery := ""
	Local cAliasBcos := ""
	Local cAliasTmp := ""
	Local aSBcos := {}
	Local cBorDe  := ""
	Local cBorAte := ""
	Local cCodBco := ""
	Local cArqCfg := ""
	Local cDirArq := ""
	Local nModelo := 0
	Local nSelFil := 0
	Local nH := 0
	Local nT := 0
	Local nX := 0
	Local cMinBor := ""
	Local cMaxBor := ""
	Local cAliasBords := GetNextAlias()
	Local cAliasEE  := GetNextAlias()
	Local aCodBc  := {}

	Private mv_par01
	Private mv_par02
	Private mv_par03
	Private mv_par04
	Private mv_par05
	Private mv_par06
	Private mv_par07
	Private mv_par08
	Private mv_par09
	Private mv_par10
	Private mv_par11
	Private mv_par12
	Private mv_par13
	Private mv_par14

	Private nHdlBco :=0,nHdlSaida:=0,nSeq:=0,cBanco,cAgencia,nSomaValor := 0
	Private nSomaCGC:=0,nSomaData:=0
	Private xConteudo
	Private nTotCnab2  := 0 // Contador de Lay-out nao deletar
	Private nLinha     := 0 // Contador de LINHAS, nao deletar
	Private nSomaVlLote:= 0
	Private nQtdTotTit := 0
	Private nQtdTitLote:= 0
	Private nQtdLinLote:= 0
	Private nTotLinArq := 0
	Private nLotCnab2  := 1		//Contador de lotes do CNAB2

	cQuery := "SELECT MIN(codigo) AS primeiro_codigo, MAX(codigo) AS ultimo_codigo"
	cQuery += " FROM ("

	For nX := 1 To Len(aListCNAB)

		If nX == 1
			cQuery += " SELECT '"+aListCNAB[nx][5]+ "' AS codigo FROM dual "
		Else
			cQuery += " UNION ALL SELECT '"+aListCNAB[nx][5]+ "' AS codigo FROM dual "
		EndIf
	Next nX

	cQuery += ")"

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasBords,.F.,.T.)

	If !(cAliasBords)->(Eof())
		cMinBor := (cAliasBords)->primeiro_codigo
		cMaxBor := (cAliasBords)->ultimo_codigo
	EndIf

	(cAliasBords)->(DbCloseArea())


	cQuery := "SELECT DISTINCT(EE_CODIGO) AS CODIGO FROM " + RetSqlName("SEE") + " WHERE EE_FILIAL = '"+cFilAnt+"' AND D_E_L_E_T_ = ' '"

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasEE,.F.,.T.)

	While !(cAliasEE)->(EOF())
		AADD(aCodBc,(cAliasEE)->CODIGO)

		(cAliasEE)->(DbSkip())
	EndDo

	(cAliasEE)->(DbCloseArea())

	For nH := 1 To Len(aCodBc)

		cBorDe  := cMinBor
		cBorAte := cMaxBor
		cCodBco := aCodBc[nH]
		cArqCfg := AllTrim(GetAdvFVal("SX5","X5_DESCRI",XFILIAL("SX5")+"ZF"+aCodBc[nH],1))
		cDirArq := ""
		nModelo := 2
		nSelFil := 2

//Seleção das filiais e bancos a serem considerados, dentro do intervalo de borderôs
		cQuery := "SELECT DISTINCT SEA.EA_FILIAL, SEA.EA_PORTADO, SEA.EA_AGEDEP, SEA.EA_NUMCON, SEE.EE_SUBCTA FROM " + RetSqlName("SEA") + " SEA"
		cQuery += " INNER JOIN " + RetSqlName("SEE") + " SEE ON"
		cQuery += " SEA.EA_PORTADO = SEE.EE_CODIGO AND "
		cQuery += " SEA.EA_AGEDEP = SEE.EE_AGENCIA AND "
		cQuery += " SEA.EA_NUMCON = SEE.EE_CONTA AND "
		cQuery += " SEE.D_E_L_E_T_ = ''"
		cQuery += " WHERE "
		cQuery += " SEA.EA_PORTADO = '" + cCodBco + "' AND"
		cQuery += " SEA.EA_NUMBOR >= '" + cBorDe + "' AND SEA.EA_NUMBOR <= '" + cBorAte + "' AND "
		cQuery += " SEE.EE_PERMPG ='1' AND SEA.D_E_L_E_T_ = ''"
		cQuery += " ORDER BY SEA.EA_FILIAL , SEA.EA_PORTADO"
		cQuery := ChangeQuery(cQuery)
		cAliasBcos := GetNextAlias()
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasBcos,.F.,.T.)

		aSBcos := {}
		While !(cAliasBcos)->(Eof())
			Aadd(aSBcos, { (cAliasBcos)->EA_FILIAL, (cAliasBcos)->EA_PORTADO, (cAliasBcos)->EA_AGEDEP, (cAliasBcos)->EA_NUMCON, (cAliasBcos)->EE_SUBCTA })
			(cAliasBcos)->(DbSkip())
		End
		(cAliasBcos)->(DbCloseArea())


		For nT := 1 to Len(aSBcos)

			//Intervalo de borderôs por filial e banco+agencia+conta
			cQuery := "SELECT  MIN(EA_NUMBOR) AS BORMIN, MAX(EA_NUMBOR) AS BORMAX FROM " + RetSqlName("SEA")
			cQuery += " WHERE "
			cQuery += " EA_NUMBOR >= '" + cBorDe + "' AND EA_NUMBOR <= '" + cBorAte + "' AND "
			cQuery += " EA_PORTADO = '" + aSBcos[nT][2] + "' AND "
			cQuery += " EA_AGEDEP = '" + aSBcos[nT][3] + "' AND "
			cQuery += " EA_NUMCON = '" + aSBcos[nT][4] + "' AND D_E_L_E_T_ = ' '
			cQuery := ChangeQuery(cQuery)
			cAliasTmp := GetNextAlias()
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)

			If (cAliasTmp)->(Eof())
				(cAliasTmp)->(DbCloseArea())
				Return
			EndIf

			cFilAnt := aSBcos[nT][1]

			cArqName := Soma1(Pad(GetMV("FS_XNUMARQ"),6),6)

			While !MayIUseCode( "PZC_ARQUIV"+FwFilial("SX6")+cArqName)  //verifica se esta na memoria, sendo usado
				cArqName := Soma1(cArqName)										// busca o proximo numero disponivel
			End

			cDirArq := Alltrim(SuperGetMV( "FS_XDIRARQ" , .F. , .F.,cFilant))

			mv_par01 := (cAliasTmp)->BORMIN
			mv_par02 := (cAliasTmp)->BORMAX
			mv_par03 := cArqCfg
			If At("\", cDirArq) > 0
				mv_par04 := IIf( SubStr(cDirArq, Len(cDirArq), 1) == "\", cDirArq, cDirArq+"\") + cArqName
			ElseIf At("/", cDirArq) > 0
				mv_par04 := IIf( SubStr(cDirArq, Len(cDirArq), 1) == "/", cDirArq, cDirArq+"/") + cArqName
			EndIf
			mv_par05 := aSBcos[nT][2]
			mv_par06 := aSBcos[nT][3]
			mv_par07 := aSBcos[nT][4]
			mv_par08 := aSBcos[nT][5]
			mv_par09 := nModelo
			mv_par10 := 2
			mv_par11 := ''
			mv_par12 := ''
			mv_par13 := 0
			mv_par14 := 2

			Fa420Ger("SE2")

			_cMvNumArq := GetMv("FS_XNUMARQ")
			If _cMvNumArq < cArqName
				PutMv("FS_XNUMARQ",cArqName)
			EndIf

			(cAliasTmp)->(DbCloseArea())

		Next nT

	Next nH
	RestArea(aArea)
Return


Static Function Scheddef()
	Local aParam as array
	Local aOrd as array

	aParam := {}


	Aadd(aParam, "P"            ) // 01 - Tipo R para relatorio P para processo
	Aadd(aParam, ""       ) // 02 - Pergunte do relatorio, caso nao use passar ParamDef
	Aadd(aParam, ""          ) // 03 - Alias
	Aadd(aParam, aOrd           ) // 04 - Array de ordens
	Aadd(aParam, "" ) // 05 - Titulo

Return aParam
