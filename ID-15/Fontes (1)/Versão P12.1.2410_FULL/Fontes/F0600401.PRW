#INCLUDE "TOTVS.CH"

//Layout aDados
#Define EF_FILIAL   1		//Filial
#Define EF_MATRIC   2		//Matricula
#Define EF_VERBA    3		//Verba
#Define EF_DTREFER  4		//Dt. Referencia
#Define EF_REF      5		//Referencia
#Define EF_QTDA     6		//Qtd Horas
#Define EF_VALOR    7		//Valor
#Define EF_OPERACAO 8		//Operacao
#Define EF_STATUS   9		//Status
#Define EF_OBSERVA  10		//Observa
#Define EF_IDAPDATA 11		//IDAPDATA

//-----------------------------------------------------------------------
/*/{Protheus.doc} F0600401
JOB de Integração Cadastro de Controle de Ponto

@author Eduardo Fernandes
@since  01/11/2016
@param aParam, ARRAY
@return Nil

@project MAN0000007423040_EF_004
@cliente Rededor
@version P12.1.7

/*/
//-----------------------------------------------------------------------
User Function F0600401(aParam)
	Local nX		  := 0
	Local aFiles	  := {'SRA', 'RGB', 'SRV', 'CTT'}
	Local dDtIni    := Date()
	Local cHora     := Time()
	Local cEmpIni   := IIF(ValType(aParam) == "A", aParam[1], cEmpAnt)
	Local cFilIni   := IIF(ValType(aParam) == "A", aParam[2], cFilAnt)
	Local aDados    := {}
	Local aValues   := {}
	Local aTblStru  := {}
	Local cNewAlias := ""
	Local cMsgError := ""
	Local lMontaAmb := .F.
	
	//Verifica se já existe um Job em execução com o mesmo nome.
	If !LockByName("F0600401_" + cEmpIni ,.F.,.F. )
		Conout('F0600401 - Já existe um Job com mesmo nome em execução!')
	Else
		ConOut("**************************************************************************")
		ConOut("* F0600401: Integração Cadastro de Controle de Ponto		 				 *")
		ConOut("* Início: " + Dtos(dDtIni) + " - " + cHora + "                   		 	 *")
		ConOut("* Montagem do ambiente na empresa " + cEmpIni + " - " + cFilIni + " 		 *")
		Conout("* F0600401 - Inicio Thread: '" + cValToChar(ThreadID()) 					   )
		ConOut("**************************************************************************")
		
		If Select("SX2") == 0
			If !RpcSetEnv( cEmpIni, cFilIni,,,,, aFiles )
				Conout('F0600401 - Nao foi possivel inicializar o ambiente')
			Endif
			lMontaAmb := .T.
		Endif
		
		FWMonitorMsg("F0600401: Integração Cadastro de Controle de Ponto - Filial: " + cFilAnt)
		
		// Conexao com base Externa
		cMsgError := ""
		If !U_F06001C1(@cMsgError)
			Conout(cMsgError)
			UnLockByName("F0600401_" + cEmpIni,.F.,.F. )
			Return .F.
		EndIf
		
		//Montando estrutura da tabela
		AAdd(aTblStru, {"EF06004_ID"			,	"VARCHAR",	032})
		AAdd(aTblStru, {"EF06004_FILIAL"		,	"VARCHAR",	008})
		AAdd(aTblStru, {"EF06004_MATRIC"		,	"VARCHAR",	006})
		AAdd(aTblStru, {"EF06004_VERBA"			,	"VARCHAR",	003})
		AAdd(aTblStru, {"EF06004_REFERENCIA"	,	"VARCHAR",	001})
		AAdd(aTblStru, {"EF06004_QTDA"			,	"VARCHAR",	009})
		AAdd(aTblStru, {"EF06004_VALOR"			,	"VARCHAR",	015})
		AAdd(aTblStru, {"EF06004_DTREFER"		,	"VARCHAR",	008})
		AAdd(aTblStru, {"EF06004_DTTRANSAC"	,	"VARCHAR",	008})
		AAdd(aTblStru, {"EF06004_HRTRANSAC"	,	"VARCHAR",	008})
		AAdd(aTblStru, {"EF06004_OPERACAO"		,	"VARCHAR",	006})
		AAdd(aTblStru, {"EF06004_STATUS"		,	"VARCHAR",	001})
		AAdd(aTblStru, {"EF06004_DTPROCESS"	,	"VARCHAR",	008})
		AAdd(aTblStru, {"EF06004_HRPROCESS"	,	"VARCHAR",	008})
		AAdd(aTblStru, {"EF06004_OBSERVA"		,	"VARCHAR",	700})
		AAdd(aTblStru, {"EF06004_IDAPDATA"		,	"VARCHAR",	036})
		
		cMsgError := ""
		If !U_F06001C3("EF06004", aTblStru, @cMsgError)
			Conout("Erro na criação da Tabela Interface - EF06004")
		Else
			
			//função para analise dados
			LoadTRB(@aDados)
			
			If Len(aDados) == 0
				Conout("Não existem registros para serem processados na tabela - EF06004")
			Else
				//------------------------------------------
				// Faz a Gravacao da tabela RGB 			//
				//------------------------------------------
				GravaRGB(@aDados)
			Endif
		Endif
		
		//------------------------------------------
		// Fecha Conexao com o Banco de Integracao //
		//------------------------------------------
		cMsgError := ""
		U_F06001C2(@cMsgError)
		
		If lMontaAmb
			RpcClearEnv() //Desconecta ambiente
		Endif
		
		Conout('F0600401 - Final Thread: ' + cValToChar(ThreadID()) )
		UnLockByName("F0600401_" + cEmpIni,.F.,.F. )
	EndIf
	
Return NIL

//--------------------------------------------------------------------------
/*{Protheus.doc} LoadTRB
Seleciona os registros da tabela de Interface

@author     Eduardo Fernandes
@since      01/11/2016

@Param		 aDados, ARRAY
@return     NIL
@version    P12.1.7
@project    MAN0000007423040_EF_004
*/
//--------------------------------------------------------------------------
Static Function LoadTRB(aDados)
	Local nError	  := 0
	Local cError	  := ""
	Local cQuery    := ""
	Local cCommand  := ""
	Local cNewAlias := GetNextAlias()
	Local cMsgError := ""
	Local cOwner	:= GetMV('FS_OWNER',,'')
	
	//------------------------------------------
	// Atualiza STATUS da tabela INTERFACE    //
	//------------------------------------------
	cCommand :=  " UPDATE " + cOwner + "EF06004 SET EF06004_STATUS = '2' WHERE EF06004_STATUS = '1' "
	//cCommand +=  " COMMIT "
	If !U_F06001C5(cCommand, @cMsgError)
		Conout(cMsgError)
		Return
	Endif
	
	//------------------------------------------
	// Consulta Registros A PROCESSAR 			//
	//------------------------------------------
	cQuery := " SELECT EF06004_FILIAL, EF06004_MATRIC, EF06004_VERBA, EF06004_DTREFER, EF06004_STATUS, "
	cQuery += "   EF06004_REFERENCIA, EF06004_QTDA, EF06004_VALOR, EF06004_OPERACAO, EF06004_IDAPDATA "
	cQuery += " FROM EF06004 "
	cQuery += " WHERE EF06004_STATUS = '2' "
	cQuery += " ORDER BY 1,2,3,4 "
	
	If U_F06001C6(cQuery, cNewAlias, @cMsgError)
		If Select(cNewAlias) > 0
			//Carrega vetor com os registros selecionados
			(cNewAlias)->(dbEval({|| AAdd(aDados,{EF06004_FILIAL, EF06004_MATRIC, EF06004_VERBA, EF06004_DTREFER, EF06004_REFERENCIA,;
				AllTrim(EF06004_QTDA), AllTrim(EF06004_VALOR), EF06004_OPERACAO, '2','', EF06004_IDAPDATA})},, {|| !EOF()}))
			
			//Fecha a area
			(cNewAlias)->(dbCloseArea())
		Endif
	Endif
	
Return Nil

//--------------------------------------------------------------------------
/*{Protheus.doc} GravaRGB
Faz a gravação da tabela RGB quando, validando todos os campos CHAVES

@author     Eduardo Fernandes
@since      03/11/2016

@Param		 aDados, ARRAY
@return     NIL
@version    P12.1.7
@project    MAN0000007423040_EF_004
*/
//--------------------------------------------------------------------------
Static Function GravaRGB(aDados)
	Local aPerAtual := {}
	Local cFilDtRef	:= ""
	Local cFilRCH	:= ""
	Local cFilTRB   := ""
	Local cMatric   := ""
	Local cMsgError := ""
	Local cPD		:= ""
	Local cPeriod   := ""
	Local dDtRef	:= CTOD("  /  /  ")
	Local lGrava	:= .T.
	Local lITMCLVL  := AllTrim(GetMV("MV_ITMCLVL",,"2")) == "1"

	Local nX		:= 0
	
	SRA->(dbSetOrder(1))
	SRV->(dbSetOrder(1))
	RGB->(dbSetOrder(1)) // RGB_FILIAL + RGB_MAT + RGB_PD + RGB_PERIOD + RGB_SEMANA + RGB_SEQ
	
	For nX:=1 to Len(aDados)
		cFilTRB := aDados[nX,EF_FILIAL]
		cMatric := aDados[nX,EF_MATRIC]
		cPD		 := aDados[nX,EF_VERBA]
		aDados[nX, EF_STATUS] := "4" //PROCESSADO ERRO
		cPeriod := ""
		lGrava	 := .T.
		
		//Valida Filial
		If !FWFilExist(cEmpAnt,cFilTRB) .Or. Empty(cFilTRB)
			aDados[nX, EF_OBSERVA]:= "Filial informada nao existe no Protheus"
			lGrava	 := .F.
		Endif
		
		//Valida Matricula
		If lGrava .And. SRA->(!DbSeek(cFilTRB + cMatric))
			aDados[nX, EF_OBSERVA]:= "Matricula informada nao existe no Protheus"
			lGrava	 := .F.
		Endif
		
		//Valida verba
		If lGrava .And. SRV->(!DbSeek(FWxFilial("SRV") + cPD))
			aDados[nX, EF_OBSERVA]:= "Verba informada nao existe no Protheus"
			lGrava	 := .F.
		Endif
		
		//Busca periodo em aberto
		aPerAtual := {}
		If lGrava
			cFilRCH := U_F0600402(cFilTRB,"RCH")
			If fGetPerAtual( @aPerAtual, cFilRCH, SRA->RA_PROCES, "FOL" )
				cPeriod  := IIF(Len(aPerAtual) > 0, aPerAtual[1,1] , "")
			Else
				aDados[nX, EF_OBSERVA]:= "Periodo em aberto nao encontrato para o roteiro FOL no Protheus"
				lGrava	 := .F.
			Endif
		Endif
		
		// Nairan (21/11/17) - Validação não mais necessária após a EF MAN0000007423048_EF_017
		// Nairan (22/12/17) - Função retornada/alterada por solicitação do Borelli devido aos últimos erros na integração de ponto
		//Valida se CHAVE ja existe na RGB
		If lGrava .And. RGB->(DbSeek(cFilTRB + cMatric + cPD + cPeriod))
			aDados[nX, EF_OBSERVA]:= "Registro ja existente na tabela RGB"
			aDados[nX, EF_STATUS]	:= "3"
			lGrava	 := .F.
		Endif
				
		
		If lGrava
			If cFilDtRef != cFilTRB
				dDtRef	:= VerDtRef(cFilTRB, cPeriod)
				cFilDtRef := cFilTRB
			EndIf
			
			If Empty(dDtRef)
				aDados[nX, EF_STATUS]	:= "4"
				aDados[nX, EF_OBSERVA]	:= "Já foi realizado o número máximo de integrações para o mês atual"			
				lGrava	:= .F.
			EndIf
		EndIf
		//------------------------------------------
		// Grava tabela RGB 							//
		//------------------------------------------
		Begin Transaction
			If lGrava
				aDados[nX, EF_STATUS] := "3" //PROCESSADO OK
				
				RecLock("RGB", .T.)
				RGB->RGB_FILIAL := cFilTRB
				RGB->RGB_PROCES := SRA->RA_PROCES
				RGB->RGB_MAT    := cMatric
				RGB->RGB_PD		:= cPD
				RGB->RGB_ROTEIR := "FOL"
				RGB->RGB_CC		:= SRA->RA_CC
				RGB->RGB_PERIOD := cPeriod
				RGB->RGB_SEMANA := "01"
				RGB->RGB_TIPO2	:= "I"
				//Se utiliza ITEM/CLASSE na Folha
				If lITMCLVL
					RGB->RGB_ITEM := SRA->RA_ITEM
					RGB->RGB_CLVL := SRA->RA_CLVL
				Endif
				
				RGB->RGB_TIPO1  := aDados[nX,EF_REF]

				If RGB->RGB_TIPO1 $ "HD"
					RGB->RGB_HORAS := Val(AllTrim(aDados[nX,EF_QTDA]))
				Else
					RGB->RGB_VALOR := Val(AllTrim(aDados[nX,EF_QTDA]))
				Endif
				
				RGB->RGB_XIMPAP	:= "I"
				RGB->RGB_DTREF	:= dDtRef
				RGB->(MsUnlock())
			Endif
			
			//------------------------------------------
			// Atualiza STATUS da tabela INTERFACE    //
			//------------------------------------------
			If !UpdInter(aDados[nX], IIF(lGrava, RGB->(Recno()),0), cFilTRB + cMatric + cPD + cPeriod )
				DisarmTran()
			Endif
		End Transaction
		
	Next nX
	
Return Nil

//--------------------------------------------------------------------------
/*{Protheus.doc} UpdInter
Atualiza STATUS final da tabela INTERFACE

@author     Eduardo Fernandes
@since      03/11/2016

@Param		 aDados, ARRAY
@Param		 nRecRGB, NUMERIC
@Param		 cChavRGB, STRING
@return     lRet, BOOLEAN
@version    P12.1.7
@project    MAN0000007423040_EF_004
*/
//--------------------------------------------------------------------------
Static Function UpdInter(aDados,nRecRGB,cChavRGB)
	Local lRet 	  := .T.
	Local cCommand  := ""
	Local cMsgError := ""
	
	Local cIDPA6 := U_F0600901("F0600401",nRecRGB,"RGB",cChavRGB,aDados[EF_OBSERVA],dDatabase,"UPSERT")
	Local cOwner	:= GetMV('FS_OWNER',,'')
	
	//------------------------------------------
	// Atualiza STATUS da tabela INTERFACE    //
	//------------------------------------------
	cCommand :=  " UPDATE " + cOwner + "EF06004 SET EF06004_STATUS = '" + aDados[EF_STATUS] + "', "
	If !Empty(aDados[EF_OBSERVA])
		cCommand +=  " EF06004_OBSERVA = '" + aDados[EF_OBSERVA] + "', "
	Endif
	cCommand +=  " EF06004_ID = '" + cIDPA6 + "',"
	cCommand +=  " EF06004_DTPROCESS = '" + DtoS(dDatabase) + "', "
	cCommand +=  " EF06004_HRPROCESS = '" + Time() + "' "
	cCommand +=  " WHERE EF06004_IDAPDATA = '" + AllTrim(aDados[EF_IDAPDATA]) + "' "
	cCommand +=  "   AND EF06004_STATUS = '2' "
	//cCommand +=  " COMMIT "
	
	If !U_F06001C5(cCommand, @cMsgError)
		Conout(cMsgError)
		lRet := .F.
	Endif
	
Return lRet



//--------------------------------------------------------------------------
/*{Protheus.doc} TsJ00401
Testa JOB iniciando pelo TDS
@author     Eduardo Fernandes
@since      03/11/2016
@return     NIL
@version    P12.1.7
@project    MAN0000007423040_EF_004
*/
//--------------------------------------------------------------------------
User Function TsJ00401()
	Local aVet := {{'01','01010002'}}
	U_F0600401(aVet)
Return

//--------------------------------------------------------------------------
/*{Protheus.doc} VerDtRef
Verifica a Data de Referencia a ser utilizada na importação
@author     Nairan Alves Silva
@since      21/11/2016
@return     NIL
@version    P12.1.7
@project    MAN0000007423040_EF_017
*/
//--------------------------------------------------------------------------
Static Function VerDtRef(cFilTRB, cPeriod)

	Local cAlias1	:= GetNextAlias()
	Local cQuery 	:= ''
	Local xDataRef	:= dDataBase
	
	cQuery := " SELECT RGB_DTREF "
	cQuery += " FROM	" + RetSqlName("RGB") + " "
	cQuery += " WHERE RGB_FILIAL = '" + cFilTRB + "' "
	cQuery += " AND RGB_PERIOD = '" + cPeriod + "' "
	cQuery += " AND RGB_ROTEIR = 'FOL' "
	cQuery += " AND D_E_L_E_T_ = ' '  "
	cQuery += " AND RGB_DTREF <> ' ' "
	cQuery += " AND RGB_XIMPAP = 'I' "
	cQuery += " ORDER BY R_E_C_N_O_ DESC "	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1)
	
	If (cAlias1)->(!EOF())
		xDataRef := STOD((cAlias1)->RGB_DTREF) + 1
		If DateDiffMonth(xDataRef,STOD((cAlias1)->RGB_DTREF)) > 0
			xDataRef := ""
		EndIf
	Else
		xDataRef := LastDay(xDataRef, 1)
	EndIf
	
	(cAlias1)->(DbCloseArea())
	
Return xDataRef