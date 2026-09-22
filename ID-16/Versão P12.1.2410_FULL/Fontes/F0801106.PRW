#Include 'Protheus.ch'
#INCLUDE "APWEBSRV.CH"
#INCLUDE 'FWMVCDEF.CH'

/*
{Protheus.doc} F0801106()

@Author     Henrique Madureira
@Since	     27/03/2017
@Version    P12.7
@Project    MAN0000007423042_EF_011
@Return	 cHtml
*/
User Function F0801106()

Return

WSSTRUCT RetFerias
	WSDATA COD				AS String
	WSDATA Matricula		As String
	WSDATA Nome			As String
	WSDATA Status			As String
	WSDATA FilialS       AS String
ENDWSSTRUCT

WSSTRUCT _RetFerias
	WSDATA Registro    As ARRAY OF RetFerias
ENDWSSTRUCT
//===========================================================================================================
WSSTRUCT _RetSlFer
	WsData FlAprov As String
	WsData CdAprov As String
	WsData lRetorn As Boolean
	WsData MsgAvso As String
	WsData CodSol  As String
ENDWSSTRUCT

WSSTRUCT VacatProg
	WSDATA ListOfPeriod 		As Array of PerdVacationProg OPTIONAL //Lista dos periodos
ENDWSSTRUCT

WSSTRUCT PerdVacationProg
	WSDATA EmployeeFilial	As String	 				//Filial do funcionario
	WSDATA Registration		As String	        		//Codigo da matricula
	WSDATA InitialDate 		As String	   				//Data de Inicio do Periodo
	WSDATA FinalDate 			As String	      			//Data de Termino do Periodo
	WSDATA Days 				As Integer OPTIONAL 		//Dias de Direito
	WSDATA ProportionalDays 	As Float   OPTIONAL 		//Dias Proporcionais
	WSDATA ResidualDays     	As Float   OPTIONAL 		//Dias Remanescentes
	WSDATA ScheduleDays     	As Float   OPTIONAL 		//Dias Programados
	WSDATA IdCode           	As String  OPTIONAL 		//Codigo ID da verba
	WSDATA IDBase           	As String  OPTIONAL 		//Codigo da verba
ENDWSSTRUCT


//===========================================================================================================
WSSERVICE W0801101 DESCRIPTION "WebService Server responsavel por férias"

	WSDATA Matricula      AS String
	WSDATA FilAprIn       AS String
	WSDATA RetSolFer      AS _RetFerias
	WSDATA aRetSol        As _RetSlFer
	WSDATA Matri          AS String
	WSDATA NomeSol        AS String
	WSDATA DtIni          AS String
	WSDATA DtFim          AS String
	WSDATA Duracao        AS String
	WSDATA Abono          AS String
	WSDATA P13SL          AS String
	WSDATA FilSoliciIn    AS String
	WSDATA MatSoliciIn    AS String
	//WSDATA FilAprIn       AS String
	WSDATA MatAprIn       AS String
	WSDATA FilFun         AS String
	WSDATA _Ret           AS Boolean
	WSDATA LimDias		 AS String
	WSDATA EmployeeFil    AS String
	WSDATA Registration   AS String
	WSDATA oBS            AS String
	WSDATA TypeOfProg     AS String OPTIONAL

	WSDATA DtVacationProg  	As VacatProg

	WSMETHOD BuscaFerias         DESCRIPTION "Retorna solicitações de férias"
	WSMETHOD InsereSoli          DESCRIPTION "Insere solicitações de férias"
	WSMETHOD VldFerias			 DESCRIPTION "Valida inclusão de férias - 75 dias"
	WSMETHOD GetPeriodAbert      DESCRIPTION "Pega os peridos abertos"
	WSMETHOD TemSoliAbert        DESCRIPTION "Pega solicitações que estejam abertas"
ENDWSSERVICE
//===========================================================================================================
// Metodo que envia o email
WSMETHOD BuscaFerias WSRECEIVE Matricula WSSEND RetSolFer WSSERVICE W0801101

	Local aAux := {}
	Local nCnt	:= 1
	Local oSolicita

	aAux := RetRh3(::Matricula)

	If Len(aAux) > 0
		::RetSolFer := WSClassNew( "_RetFerias" )

		::RetSolFer:Registro := {}
		oSolicita :=  WSClassNew( "RetFerias" )
		For nCnt := 1 To Len(aAux)
			oSolicita:COD := aAux[nCnt][1]
			oSolicita:Matricula := aAux[nCnt][2]
			oSolicita:Nome := aAux[nCnt][3]
			If aAux[nCnt][6] == "1" //Cancelado sim
				oSolicita:Status := "5"
			Else
				oSolicita:Status := aAux[nCnt][4]
			EndIf
			oSolicita:FilialS := aAux[nCnt][5]
			AAdd( ::RetSolFer:Registro, oSolicita )
			oSolicita :=  WSClassNew( "RetFerias" )
		Next
	Else
		::RetSolFer := WSClassNew( "_RetFerias" )

		::RetSolFer:Registro := {}
		oSolicita :=  WSClassNew( "RetFerias" )
		oSolicita:COD 		:= ""
		oSolicita:Matricula 	:= ""
		oSolicita:Nome 		:= ""
		oSolicita:Status 		:= ""
		oSolicita:FilialS		:= ""
		AAdd( ::RetSolFer:Registro, oSolicita )
	EndIf

Return .T.

Static Function RetRh3(cMatriIni)
	Local cQuery     := ''
	Local cAliasRh3  := 'RETPA3'
	Local cAliasrH4  := 'RETRH4'
	Local cCodPa3    := ''
	Local cFilPa3    := ''
	Local nCnt       := 1
	Local aAux       := {}

	cQuery := "SELECT	RH3_CODIGO, RH3_MAT, RH3_DTSOLI , RH3_XTPCTM, RH3_STATUS, RH3_MATINI, "
	cQuery += "SRA.RA_NOME, RH3_VISAO, RH3_FILIAL, RH3.RH3_XCANCL "
	cQuery += "FROM	" + RetSqlName("RH3") + " RH3 "
	cQuery += "INNER JOIN " + RetSqlName("SRA") + " SRA "
	cQuery += "ON SRA.RA_MAT = RH3.RH3_MAT "
	cQuery += "AND SRA.RA_FILIAL = RH3.RH3_FILIAL "
	cQuery += "	AND SRA.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE	RH3_MATINI = '" + cMatriIni + "' "
	cQuery += "		AND RH3_TIPO = ' ' "
	cQuery += "		AND RH3_XTPCTM = '008' "
	cQuery += "		AND RH3.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY RH3_CODIGO"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAliasRh3)

	DbSelectArea(cAliasRh3)
	While ! (cAliasRh3)->(EOF())

		AADD(aAux, {(cAliasRh3)->RH3_CODIGO, ;
			(cAliasRh3)->RH3_MAT, ;
			(cAliasRh3)->RA_NOME, ;
			(cAliasRh3)->RH3_STATUS, ;
			(cAliasRh3)->RH3_FILIAL, ;
			(cAliasRh3)->RH3_XCANCL})
		(cAliasRh3)->(DbSkip())
	End
	(cAliasRh3)->(DbCloseArea())

Return aAux

//===========================================================================================================
// Metodo que valida a data de inclusão de férias
//===========================================================================================================
WSMETHOD VldFerias WSRECEIVE Matricula,FilSoliciIn,DtIni,LimDias WSSEND _Ret WSSERVICE W0801101

	Local aTmp	:= {}
	Local cSeekSRF 	:= FilSoliciIn + Matricula + fGetCodFol("0072")
	Local nTot		:= 0
	Local dDataFin

	dbSelectArea("SRF")
	SRF->(dbSetOrder(2))

	If SRF->(dbSeek(cSeekSRF))
		While SRF->(!Eof() .And. SRF->(RF_FILIAL + RF_MAT + RF_PD) == cSeekSRF ) .And. nTot < 2
			If Empty(SRF->RF_STATUS) .Or. SRF->RF_STATUS == "1"
				dDataFin := If(Empty(SRF->RF_DATAFIM),fCalcFimAq(SRF->RF_DATABAS),SRF->RF_DATAFIM)
				nTot++
			Endif
			SRF->(DbSkip())
		EndDo

		If nTot == 2
			If STOD(DtIni) >= DaySub(dDataFin,Val(LimDias))
				::_Ret := .F.
			Else
				::_Ret := .T.
			EndIf
		Else
			::_Ret := .T.
		Endif
	EndIf

Return ::_Ret

//===========================================================================================================
// Metodo que envia o email
WSMETHOD InsereSoli WSRECEIVE Matri, NomeSol, DtIni, DtFim, Duracao, Abono, P13SL, FilSoliciIn, MatSoliciIn,  FilFun, Obs   WSSEND aRetSol WSSERVICE W0801101

	Local aResult := {}
	Local 	aRegs :={	{"R8_FILIAL", ::FilFun  }, ;
		{"R8_MAT",    ::Matri   }, ;
		{"TMP_NOME",   ::NomeSol }, ;
		{"R8_DATAINI", ::DtIni}, ;
		{"R8_DATAFIM",  ::DtFim}, ;
		{"R8_DURACAO",  ::Duracao}, ;
		{"TMP_ABONO",   ::Abono }, ;
		{"TMP_1P13SL",    ::P13SL  },;
		{"TMP_OBS",    ::Obs  }}
	BEGIN TRANSACTION
		aResult := GrvSolici(aRegs, ::Matri, ::FilSoliciIn, ::MatSoliciIn,  ::FilFun )

		If aResult[1][1]
			::aRetSol:FlAprov := aResult[1][2]
			::aRetSol:CdAprov := aResult[1][3]
			::aRetSol:lRetorn := aResult[1][1]
			::aRetSol:MsgAvso := aResult[1][4]
			::aRetSol:CodSol := aResult[1][5]
		Else
			::aRetSol:FlAprov := ""
			::aRetSol:CdAprov := ""
			::aRetSol:lRetorn := .F.
			::aRetSol:MsgAvso := aResult[1][4]
			::aRetSol:CodSol := aResult[1][5]			
		EndIf

	END TRANSACTION
Return .T.
//===========================================================================================================

Static Function GrvSolici(aRegs, cMatricula, cFilSolici, cMatSolici, cFilFun)

	Local nReturnCode := 0
	Local nCount      := 0
	Local nItem       := 0
	Local cAliasAi8   := "INFAI8"
	Local cVisao      := ""
	Local aRet        := {}
	Local lRet        := .F.
	Local aAreas      := {RA2->(GetArea()), RH4->(GetArea()), RH3->(GetArea()), GetArea()}
	Local cObs        := ""
	Local cXStatus    := ""
	Local cNotif      := ""
	Local aAllSup     := {}
	Local nLoop       := 0
	Local cQueryChv   := ""
	Local cAlias1     := GetNextAlias()
	Local cVisPAB     := ""
	Local cChave      := ""
	Local cFilPost    := ""
    Local cCodPost    := ""
	
	cRh3Cod  := U_F1302201({cFilFun,"",""}, .T.)
	//Busca o superior
	If (cFilSolici+cMatSolici) == (cFilFun+cMatricula)
		aRetSup := U_F0800501("1", ,, "008", "001", cFilSolici, cMatSolici, cFilFun, cMatricula)
	Else
		aRetSup := U_F0800501("1", ,, "008", "002", cFilSolici, cMatSolici, cFilFun, cMatricula)	
	EndIf
	
	If aRetSup[1][1] //Se Encontrou o Aprovador

		cNotif  := Posicione("PAC",1,xFilial("PAC")+aRetSup[1][6]+aRetSup[1][4],"PAC_APRNOT")
		cVisPAB := Posicione("PAB",1,xFilial("PAB")+aRetSup[1][6],"PAB_VISAO")
		
		cQueryChv := "SELECT RD4_CHAVE, RD4_FILIDE, RD4_CODIDE "
		cQueryChv += "FROM " + RetSqlName("RCX") + " RCX "
		cQueryChv += "INNER JOIN " + RetSqlName("RD4") + " RD4 ON(RD4.RD4_FILIDE = RCX.RCX_FILIAL AND "
		cQueryChv += "RD4.RD4_CODIDE = RCX.RCX_POSTO AND RD4.D_E_L_E_T_ = ' ') "
		cQueryChv += "WHERE RCX.RCX_FILFUN = '" + cFilSolici  + "' AND "
		cQueryChv += "RCX.RCX_MATFUN = '" + cMatSolici + "' AND "
		cQueryChv += "RD4.RD4_CODIGO = '" + cVisPAB + "' AND "
		cQueryChv += "RCX.D_E_L_E_T_ = ' '"
		
		cQueryChv := ChangeQuery(cQueryChv)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryChv),cAlias1,.T.,.T.)
		
		If !(cAlias1)->(EOF())
			cChave := (cAlias1)->RD4_CHAVE
			cFilPost := (cAlias1)->RD4_FILIDE
		    cCodPost := (cAlias1)->RD4_CODIDE
		EndIf
		
		If (aRetSup[1][5] == "FM" .And. cNotif == "2") .Or. (aRetSup[1][5] == "FM" .And. ("aprova direto" $ aRetSup[1][8] .OR. "Terminou a estrutura da visão!" $ aRetSup[1][8] )) 
			cXStatus := "4"
		Else
			cXStatus := "1"
		EndIf
		RH3->(DbSetOrder(1))
		If ! RH3->(DbSeek(cFilFun + cRh3Cod))
			Reclock("RH3", .T.)
			RH3->RH3_FILIAL := cFilFun
			RH3->RH3_CODIGO := cRh3Cod
			RH3->RH3_MAT    := cMatricula
			RH3->RH3_ORIGEM := "PORTAL"
			RH3->RH3_STATUS := cXStatus
			RH3->RH3_DTSOLI := DATE()
			RH3->RH3_FILINI := cFilSolici
			RH3->RH3_MATINI := cMatSolici
			RH3->RH3_FILAPR := aRetSup[1][2]
			RH3->RH3_MATAPR := aRetSup[1][3]
			RH3->RH3_NVLAPR := Val(aRetSup[1][4])
			RH3->RH3_KEYINI := "002"
			RH3->RH3_EMP    := "01"
			RH3->RH3_EMPINI := "01"
			RH3->RH3_EMPAPR := "01"
			RH3->RH3_XTPCTM := "008"
			RH3->RH3_XCODAL := aRetSup[1][6]
			RH3->RH3_XPRXNV := aRetSup[1][5]
			RH3->RH3_XFILAP := cFilSolici
			RH3->RH3_XMATAP := cMatSolici
			RH3->RH3_VISAO	:= cVisPAB
			If !Empty(aRetSup[1][9]) .AND. !Empty(aRetSup[1][10])
				RH3->RH3_XSUBST := "S"
				RH3->RH3_XFILSU := aRetSup[1][9]
				RH3->RH3_XMATSU := aRetSup[1][10]
			EndIf
			RH3->RH3_XCHAVE := cChave
			RH3->RH3_XFILPO := cFilPost
			RH3->RH3_XCODPO := cCodPost
			RH3->(MsUnlock())
			
			U_F0801201(RH3->RH3_FILAPR, RH3->RH3_MATAPR, RH3->RH3_FILIAL, RH3->RH3_CODIGO, RH3->RH3_NVLAPR, RH3->RH3_XCODAL)
			
			If LEN(GETFUNCARRAY('U_F0500201')) > 0
				//U_F0500201(cFilSolici,cRh3Cod,"001")
				U_F0500201(cFilFun,cRh3Cod,"001")
			EndIf
			
			If cXStatus == "4"
				//U_F0500201(cFilSolici,cRh3Cod,"005")
				U_F0500201(cFilFun,cRh3Cod,"005")
			Else
				//U_F0500201(cFilSolici,cRh3Cod,"002")
				U_F0500201(cFilFun,cRh3Cod,"002")
			EndIf
			SRA->(DbSetOrder(1))
			SRA->(DbSeek(aRetSup[1][2] + aRetSup[1][3]))
			cSubGrp := POSICIONE("PAB",1, XFILIAL("PAB") + RH3->RH3_XCODAL, "PAB_GRPSOL")
			U_F0800901("1",SRA->RA_EMAIL,cFilFun,cRh3Cod,SRA->RA_NOME,"008",cSubGrp,aRetSup[1][4],aRegs[9, 2])
			
		EndIf

		RH4->(DbSetOrder(1))
		If ! RH4->(DbSeek(xFilial("RH4") + cRh3Cod))
			For nCount:= 1 To Len(aRegs)
				If !Empty(aRegs[nCount, 2])
					Reclock("RH4", .T.)
					RH4->RH4_FILIAL	:= cFilFun
					RH4->RH4_CODIGO	:= cRh3Cod
					RH4->RH4_ITEM	:= ++nItem
					RH4->RH4_CAMPO	:= aRegs[nCount, 1]
					If aRegs[nCount, 1] != "TMP_OBS"
						RH4->RH4_XOBS  	:= ""
						RH4->RH4_VALNOV	:= aRegs[nCount, 2]
					Else
						RH4->RH4_VALNOV	:= ""
						RH4->RH4_XOBS  	:= aRegs[nCount, 2]
						cObs			:= aRegs[nCount, 2]
					EndIf
					RH4->(MsUnlock())
				EndIf
			Next
		EndIf

		If (__lSX8)
			ConfirmSx8()
			lRet := .T.
		EndIf

		AAdd(aRet, {lRet, aRetSup[1][2], aRetSup[1][3], "",cRh3Cod})
		cEmail := AllTrim(Posicione("SRA", 1, aRetSup[1][2] + aRetSup[1][3], "RA_EMAIL"))
		
		aAllSup := fAllBuscSuper(aRetSup[1][2],aRetSup[1][3])
		
		
		For nLoop := 1 To Len(aAllSup) 
			U_F0800901("3", aAllSup[nLoop][3],RH3->RH3_FILIAL,cRh3Cod,POSICIONE("SRA",1,RH3->RH3_FILINI + RH3->RH3_MATINI,"RA_NOME" ),'008','001',Strzero(RH3->RH3_NVLAPR,TAMSX3("RH3_XPRXNV")[1]),cObs)
		Next
		

	Else
		AAdd(aRet, {lRet, "", "", aRetSup[1][8],""})
	EndIf

	AEval(aAreas, {|x| RestArea(x)} )

Return aRet

Static Function SendVencMail(cFilFun, cMatFun, cFilApr, cMatApr)

	Local aArea        := GetArea()
	Local aAreaSRA     := SRA->(GetArea())
	Local cAssunto     := "Férias Vencidas"
	Local cEmailFunc   := ""
	Local cEmailApro   := ""
	Local cBody        := ""
	Local cMatApr      := ""

	cEmailApro := AllTrim(Posicione("SRA", 1, cFilApr + cMatApr, "RA_EMAIL"))
	cEmailFunc := AllTrim(Posicione("SRA", 1, cFilFun + cMatFun, "RA_EMAIL"))

	cBody := '<html><body><pre>' + CRLF
	cBody += '<b>Prezado, </b>' + CRLF
	cBody += "Verificamos que não houve o agendamento das férias do (a)" +  SRA->( RA_MAT + " - " + RA_NOME) + "." + CRLF
	cBody += "Como está vencendo o segundo período aquisitivo e para que não haja o pagamento em dobro conforme artigo 137 da CLT, as mesmas devem ser sugeridas e aprovadas conforme os prazos legais." + CRLF
	cBody += '</pre></body></html>'

	U_F0200304(cAssunto, cBody, cEmailApro + ";" + cEmailFunc )

	RestArea(aAreaSRA)
	RestArea(aArea)
Return


WSMETHOD GetPeriodAbert WSRECEIVE  EmployeeFil, Registration, TypeOfProg WSSEND DtVacationProg WSSERVICE W0801101
	Local lRet      := .T.
	Local lOK       := .F.
	Local cFilFun   := ::EmployeeFil
	Local cMatFun   := ::Registration
	Local nPer 		:= 0
	Local nPer	    := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O parametro MV_GSPUBL = "2" identifica que eh GSP-Caixa.                    ³
	//³Se existir o parametro MV_VDFLOGO, eh porque eh GSP-MP (novo modelo de GSP).³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cFerOrd   := ""
	Local cFerComp	:= ""
	Local cGSP      := SuperGetMv("MV_GSPUBL",,"1")
	If cGSP == "2" .And. GetMv("MV_VDFLOGO",,"0") <> "0"
		cGSP := "3"
	EndIf

	Private aGetPerFerias := {}
	Private aPerFerias    := {}

	DEFAULT ::TypeOfProg  := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Buscando RECNO                                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cFerAlias := "QSRA"
	BeginSql alias cFerAlias
		SELECT SRA.R_E_C_N_O_
		FROM %table:SRA% SRA
		WHERE SRA.RA_FILIAL  = %exp:cFilFun% AND
		SRA.RA_MAT	 = %exp:cMatFun% AND
		SRA.%notDel%
	EndSql
	cRecNo := (cFerAlias)->R_E_C_N_O_
	(cFerAlias)->( DbCloseArea() )

	//Ponteirando registro SRA
	dbSelectArea("SRA")
	dbSetOrder(1)
	SRA->(dbseek(cFilFun+cMatFun))

	// Variaveis criadas no GPEM030 antes da chamada ao m030fer
	Private aGets 			:= {}
	Private c__Roteiro 	    := "FER"
	Private lItemClVl   	:= SuperGetMv( "MV_ITMCLVL", .F., "2" ) == "1"
	Private nDFalt			:= 0

	If cGSP == "2" .or. cGSP == "3"
		Private P_FERPAC  := "S"

		If cGSP == "3"//GSP-MP
			Do Case
			Case ::TypeOfProg == 1 //Saldo de dias
				aPerVerbas   := {}
			Case ::TypeOfProg == 2 //Licenca Premio
				aPerVerbas   := {fGetCodFol("1332")}
			Case ::TypeOfProg == 3 //Ferias
				cFerOrd       := fGetCodFol("0072") //(Ferias ordinarias servidor e membro)
				cFerComp      := fGetCodFol("1335") //(Ferias compensatorias membro)
				aPerVerbas    := {cFerOrd, cFerComp}
			EndCase
		EndIf
	EndIf

	If CarPerFer(cFilFun, cMatFun, @aPerFerias)
		Self:DtVacationProg:ListOfPeriod := {}
		For nPer := 1 to Len(aPerFerias)

			lOK := .F.
			If cGSP == "3"
				//GSP-MP
				If ::TypeOfProg == 1
					//avalia Saldo de dias de folga
					If aPerFerias[nPer][3] > 0 .or. aPerFerias[nPer][36] > 0
						lOK := .T.
					EndIf
				Else
					//avalia ferias e licenca premio
					If aPerFerias[nPer][3] > 0
						lOK := .T.
					Else
						If aPerFerias[nPer][36] > 0
							//Nos casos onde não existe dias vencidos(DFERVAT), os dias de direito serão utilizados.
							//Isso acontece quando o periodo aquisito não esta completo.
							aPerFerias[nPer][3] := aPerFerias[nPer][36]
							lOK := .T.
						EndIf
					EndIf
				EndIf
			Else
				//Padrao
				If aPerFerias[nPer][3] > 0 .OR. aPerFerias[nPer][4] > 0
					lOK := .T.
				EndIf
				//Funcionário acabou de ser contratado e ainda não tem Dias de ferias vencidas ou a vencer mas já tem o período aquisitivo
				If Len(aPerFerias) == 1
					If !Empty(aPerFerias[nPer][1]) .OR. !Empty(aPerFerias[nPer][2])
						lOK := .T.
					EndIf
				EndIf
			EndIf

			If lOK
				If cGSP == "3" //GSP-MP
					If ::TypeOfProg == 1 //avalia Saldo de dias de folga
						If aPerFerias[nPer][36] == 0 .or. alltrim(aPerFerias[nPer][35]) <> ''
							loop
						EndIf
					Else
						//lançamento sem código de verba para avaliação de ferias
						If alltrim(aPerFerias[nPer][34]) == ''
							loop
						EndIf
					EndIf
				EndIf

				//nPer2++
				aadd(::DtVacationProg:ListOfPeriod,WsClassNew('PeriodVacationProg'))
				::DtVacationProg:ListOfPeriod[nPer]:EmployeeFilial	:= cFilFun
				::DtVacationProg:ListOfPeriod[nPer]:Registration	:= cMatFun
				::DtVacationProg:ListOfPeriod[nPer]:InitialDate     := DtoC(aPerFerias[nPer][1])
				::DtVacationProg:ListOfPeriod[nPer]:FinalDate       := DtoC(aPerFerias[nPer][2])

				If cGSP == "3" //GSP-MP
					If ::TypeOfProg == 1 .or. ::TypeOfProg == 2 //avalia (1-Saldo de dias de folga) (2-Licenca Premio)
						::DtVacationProg:ListOfPeriod[nPer]:Days           := Max(aPerFerias[nPer][36], 0)
					Else
						::DtVacationProg:ListOfPeriod[nPer]:Days           := Max(aPerFerias[nPer][3], 0)
					Endif
					::DtVacationProg:ListOfPeriod[nPer]:ProportionalDays   := Max(aPerFerias[nPer][4], 0)
					::DtVacationProg:ListOfPeriod[nPer]:ResidualDays       := Max(aPerFerias[nPer][32], 0)
					::DtVacationProg:ListOfPeriod[nPer]:ScheduleDays       := Max(aPerFerias[nPer][33], 0)
				Else
					nDFalt := aPerFerias[nPer][15]
					TabFaltas(@nDFalt)
					nDFalt := nDFalt + aPerFerias[nPer][14]
					::DtVacationProg:ListOfPeriod[nPer]:Days               := Max(aPerFerias[nPer][3] - nDFalt, 0)
					::DtVacationProg:ListOfPeriod[nPer]:ProportionalDays   := Max(aPerFerias[nPer][4] - nDFalt, 0)
					::DtVacationProg:ListOfPeriod[nPer]:ResidualDays       := 0
					::DtVacationProg:ListOfPeriod[nPer]:ScheduleDays       := 0
				EndIf

				If cGSP == "3" //GSP-MP
					::DtVacationProg:ListOfPeriod[nPer]:IdBase              := alltrim(aPerFerias[nPer][34])
					If alltrim(aPerFerias[nPer][34]) == cFerOrd
						::DtVacationProg:ListOfPeriod[nPer]:IdCode          := "0072"
					ElseIf alltrim(aPerFerias[nPer][34]) == cFerComp
						::DtVacationProg:ListOfPeriod[nPer]:IdCode          := "1335"
					Else
						::DtVacationProg:ListOfPeriod[nPer]:IdCode          := ""
					EndIf
				Else
					::DtVacationProg:ListOfPeriod[nPer]:IdCode              := ""
					::DtVacationProg:ListOfPeriod[nPer]:IdBase              := ""
				EndIf
			EndIf
		Next nPer
	EndIf

Return(lRet)

Static Function CarPerFer(cFilFer, cMatFer, aPerFerias)
	Local lRetorno := .F.
	Local aTmp	:= {}
	aPerFerias	:= {}
	cSeekSRF 	:= cFilFer + cMatFer + fGetCodFol("0072")

	dbSelectArea("SRF")
	SRF->(dbSetOrder(2))
	If SRF->(dbSeek(cSeekSRF))
		While SRF->(!Eof() .And. SRF->(RF_FILIAL + RF_MAT + RF_PD) == cSeekSRF )
			If Empty(SRF->RF_STATUS) .Or. SRF->RF_STATUS == "1"
				aAdd(aTmp,{	SRF->RF_DATABAS	,;										  		 			// 01 - Inicio Database de Ferias
								Iif(Empty(SRF->RF_DATAFIM),fCalcFimAq(SRF->RF_DATABAS),SRF->RF_DATAFIM),;  	// 02 - Final Database de Ferias
								SRF->RF_DFERVAT	,;															// 03 - Dias de ferias vencidas
								SRF->RF_DFERAAT	,;															// 04 - Dias de ferias a vencer
								0.00			,;																// 05 - Dias totais de afastamento por periodo
								SRF->RF_OBSERVA	,;															// 06 - Descricao do tipo de afastamento do periodo
								CtoD("")		,;																// 07 - Data de original de termino do p.aquisitivo quando houver prorrogacao do mesmo RWX
								Iif(Empty(SRF->RF_STATUS),"1",SRF->RF_STATUS),;							// 08 - Status do periodo de ferias:  1-Ativo (Vencidos/A vencer)/2-Prescrito (Perdido)/3-Pago
								CtoD("")		,;																// 09 - Data de Inicio do Proximo periodo caso seja um periodo perdido.
								0				,;																// 10 - Quantidade dias de deducao para o direito apurado no periodo
								SRF->RF_DVENPEN ,;     														// 11 - Dias Vencidos Pendentes
								SRF->RF_IVENPEN ,;     														// 12 - Data Inicia Vencido Pendente
								SRF->RF_FVENPEN ,;															// 13 - Data Inicia Vencido Pendente
								SRF->RF_DFERANT ,;     														// 14 - Dias de Ferias Antecipadas
								SRF->RF_DFALVAT ,;     														// 15 - Dias de Faltas Vencidas
								SRF->RF_DFALAAT ,; 				    										// 16 - Dias de Faltas a Vencer
								Iif(cPaisLoc$"VEN|EQU",SRF->RF_DBONVAT,NIL),;				 				// 17 - Dias de bono vencido
								Iif(cPaisLoc$"VEN|EQU",SRF->RF_DBONAAT,NIL),; 								// 18 - Dias de bono a Vencer
								0				,;																// 19 - Total de dias de ferias
								0				,;																// 20 - Total de dias de bonificacao
								0				,;																// 21 - Dias de Faltas vencidas bonificacao
								0				,;																// 22 - Dias de ¦Faltas a Vencer bonificacao
								0				,;																// 23 - Dias de ausencia convertidos em ferias
								0				,;      														// 24 - Total de Dias de Ferias do Periodo
								SRF->RF_DIASANT ,;					      									// 25 - Dias Gozados Vencidos
								SRF->RF_DIASANT	,;	    													// 26 - Dias Gozados a Vencer
								0               ,;      														// 27 - Dias Subsid. Vencidos
								0               ,;   														// 28 - Dias Subsid. a Vencer
								0				,; 																// 29 - Dias de Pagto. Minimo na Adm/Dem (cpo. RF_PAGOFER desabilitado 08/2012)
								SRF->( RECNO() ),;															// 30 - Recno do aquivo
								Iif(Type("SRF->RF_FERPAGA")<>"U",  SRF->RF_FERPAGA, 0) ,;					// 31 - Dias pagos em R$ na folha
								SRF->RF_DATAATU	;
					})
				If SRF->RF_DATAINI >= dDataBase
					dDtIniProg := SRF->RF_DATAINI
					nDiasProg  := SRF->RF_DFEPRO1
				ElseIf SRF->RF_DATINI2 >= dDataBase
					dDtIniProg := SRF->RF_DATINI2
					nDiasProg  := SRF->RF_DFEPRO2
				ElseIf SRF->RF_DATINI3 >= dDataBase
					dDtIniProg := SRF->RF_DATINI3
					nDiasProg  := SRF->RF_DFEPRO3
				EndIf
			Endif
			SRF->(DbSkip())
		EndDo
	EndIf

	If Len(aTmp) > 0
		lRetorno := .T.
		aPerFerias := aclone(atmp)
	EndIf

Return(lRetorno)

WSMETHOD TemSoliAbert WSRECEIVE FilFun, Matricula WSSEND _Ret WSSERVICE W0801101
	Local cQuery     := ''
	Local cAliasRh3  := 'RETPA3'

	cQuery := "SELECT	RH3_CODIGO "
	cQuery += "FROM	" + RetSqlName("RH3") + " RH3 "
	cQuery += "WHERE RH3_FILIAL = '" + ::FilFun + "' "
	cQuery += "      AND RH3_MAT = '" + ::Matricula + "' "
	cQuery += "      AND RH3_TIPO = ' ' "
	cQuery += "      AND RH3_XTPCTM = '008' "
	cQuery += "      AND RH3_STATUS IN('1','4') "
	cQuery += "      AND RH3.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY RH3_CODIGO"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRh3)

	DbSelectArea(cAliasRh3)
	If ! (cAliasRh3)->(EOF())
		::_Ret := .T.
	Else
		::_Ret := .F.
	EndIf
	(cAliasRh3)->(DbCloseArea())
Return .T.

/*/{Protheus.doc} fAllBuscSuper
função que busca todos os  
@author Fernando Carvalho
@since 22/05/2017
@version undefined
@param cFilApr, characters, descricao
@param cMatApr, characters, descricao
@type function
/*/
Static Function fAllBuscSuper(cFilApr,cMatApr)
	Local aSuperior		:= {}
	Local cQuery 		:= ""
	Local aArea 		:= GetArea()
	Local cPosto 		:= Posicione("SRA", 1, cFilApr + cMatApr,"RA_POSTO")
	Local lAdd			:= .F.
	Local cSub			:= ""
	Local cSupAlias    	:= "QSUP"
	
	BeginSql alias cSupAlias
		SELECT 
			SRA.RA_MAT, SRA.RA_FILIAL, SRA.RA_EMAIL, RCX.RCX_SUBST, RCX.RCX_DTFIM
		FROM %table:SRA% SRA
		INNER JOIN %table:RCX% RCX	
		ON RCX.RCX_FILIAL = SRA.RA_FILIAL AND
			RCX.RCX_MATFUN = SRA.RA_MAT AND
			RCX.%notDel%
		WHERE 
			SRA.RA_FILIAL =  %exp:cFilApr%
			AND SRA.RA_POSTO = %exp:cPosto%
			AND SRA.%notDel%
	EndSql
	
	
	While (cSupAlias)->(!Eof())
		lAdd := .T.
				
		If (cSupAlias)->RCX_SUBST == '1' .AND. ! Empty((cSupAlias)->RCX_DTFIM)
			IF (dDataBase > (cSupAlias)->RCX_DTFIM)
				lAdd := .F.
			EndIf	
		EndIf

		iF lAdd
			aAdd( aSuperior, { (cSupAlias)->RA_FILIAL,(cSupAlias)->RA_MAT, (cSupAlias)->RA_EMAIL })
		EndIf	
		(cSupAlias)->(dbSkip())		
	EndDo

	(cSupAlias)->( dbCloseArea() )
	
	RestArea(aArea)
Return aSuperior
