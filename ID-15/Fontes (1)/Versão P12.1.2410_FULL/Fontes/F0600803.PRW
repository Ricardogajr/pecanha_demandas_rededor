#INCLUDE 'TOTVS.CH'

//Layout aDados 
#Define EF_FILIAL   1		//Filial
#Define EF_MATRIC   2		//Matricula
#Define EF_CODVER   3		//Verba
#Define EF_DTREFER  4		//Dt. Referencia
#Define EF_REF      5		//Referencia
#Define EF_QTDVER   6		//Qtd Horas
#Define EF_VALVER   7		//Valor
#Define EF_OPERACAO 8		//Operacao
#Define EF_STATUS   9		//Status
#Define EF_OBSERVA  10		//Observa
#Define EF_IDAPDATA 11		//IDAPDATA

//-----------------------------------------------------------------------
/*/{Protheus.doc} F0600803
JOB de Integracao Calculo de Rescisao
 
@author 	Eduardo Fernandes 
@since  	09/11/2016
@return  	Nil  

@param 		aParam, ARRAY 
@project 	MAN0000007423040_EF_008
@cliente 	Rededor
@version 	P12.1.7
             
/*/
//-----------------------------------------------------------------------
User Function F0600803(aParam)
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
		
	//Verifica se já existe um Job em execução com o mesmo nome.
	If !LockByName("F0600803_" + cEmpIni ,.F.,.F. )
		Conout('F0600803 - Já existe um Job com mesmo nome em execução!')
	Else
		ConOut("**************************************************************************")
		ConOut("* F0600803: Integração Calculo de Rescisao					 				 *")
		ConOut("* Início: " + Dtos(dDtIni) + " - " + cHora + "                   		 	 *")
		ConOut("* Montagem do ambiente na empresa " + cEmpIni + " - " + cFilIni + " 		 *")
		Conout("* F0600803 - Inicio Thread: '" + cValToChar(ThreadID()) 					   )
		ConOut("**************************************************************************")	  	  
	  
		If !RpcSetEnv( cEmpIni, cFilIni,,,,, aFiles )
			Conout('F0600803 - Nao foi possivel inicializar o ambiente')
		Else	
			FWMonitorMsg("F0600803: Integração Calculo de Rescisao - Filial: " + cFilAnt)														
											
			// Conexao com base Externa
			cMsgError := ""
			If !U_F06001C1(@cMsgError)
				Conout(cMsgError)		
				UnLockByName("F0600803_" + cEmpIni,.F.,.F. )	
				Return .F.
			EndIf
																					
			//Montando estrutura da tabela
			AAdd(aTblStru, {"EF06008_ID"			,	"VARCHAR",	032})
			AAdd(aTblStru, {"EF06008_FILIAL"		,	"VARCHAR",	008})
			AAdd(aTblStru, {"EF06008_MATRIC"		,	"VARCHAR",	006})
			AAdd(aTblStru, {"EF06008_CODVER"		,	"VARCHAR",	003})
			AAdd(aTblStru, {"EF06008_REFVER"		,	"VARCHAR",	001})
			AAdd(aTblStru, {"EF06008_QTDVER"		,	"VARCHAR",	009})
			AAdd(aTblStru, {"EF06008_VALVER"		,	"VARCHAR",	015})
			AAdd(aTblStru, {"EF06008_ANOMESREF"	,	"VARCHAR",	008})
			AAdd(aTblStru, {"EF06008_DTTRANSAC"	,	"VARCHAR",	008})
			AAdd(aTblStru, {"EF06008_HRTRANSAC"	,	"VARCHAR",	008})
			AAdd(aTblStru, {"EF06008_OPERACAO"		,	"VARCHAR",	006})
			AAdd(aTblStru, {"EF06008_STATUS"		,	"VARCHAR",	001})
			AAdd(aTblStru, {"EF06008_DTPROCESS"	,	"VARCHAR",	008})
			AAdd(aTblStru, {"EF06008_HRPROCESS"	,	"VARCHAR",	008})
			AAdd(aTblStru, {"EF06008_OBSERVA"		,	"VARCHAR",	700})
			AAdd(aTblStru, {"EF06008_IDAPDATA"		,	"VARCHAR",	036})
			
			cMsgError := ""
			If !U_F06001C3("EF06008", aTblStru, @cMsgError)				
				Conout("Erro na criação da Tabela Interface - EF06008")
			Else								
				//função para analise dados
				LoadTRB(@aDados)
			
				If Len(aDados) == 0
					Conout("Não existem registros para serem processados na tabela - EF06008")
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
			
			RpcClearEnv() //Desconecta ambiente 						
		Endif
		
		Conout('F0600803 - Final Thread: ' + cValToChar(ThreadID()) )
		UnLockByName("F0600803_" + cEmpIni,.F.,.F. )			 				
	EndIf

Return NIL

//--------------------------------------------------------------------------
/*{Protheus.doc} LoadTRB
Seleciona os registros da tabela de Interface

@author     Eduardo Fernandes
@since      09/11/2016

@Param		 aDados, ARRAY
@return     NIL
@version    P12.1.7
@project    MAN0000007423040_EF_008
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
cCommand :=  " UPDATE " + cOwner + "EF06008 SET EF06008_STATUS = '2' WHERE EF06008_STATUS = '1' "
//cCommand +=  " COMMIT "
If !U_F06001C5(cCommand, @cMsgError)
 	Conout(cMsgError)
	Return		
Endif		 

//------------------------------------------
// Consulta Registros A PROCESSAR 			//
//------------------------------------------
cQuery := " SELECT EF06008_FILIAL, EF06008_MATRIC, EF06008_CODVER, EF06008_ANOMESREF, EF06008_STATUS, "
cQuery += "        EF06008_REFVER, EF06008_QTDVER, EF06008_VALVER, EF06008_OPERACAO, EF06008_IDAPDATA "
cQuery += " FROM EF06008 " 
cQuery += " WHERE EF06008_STATUS = '2' "
cQuery += " ORDER BY 1,2,3,4 "

If U_F06001C6(cQuery, cNewAlias, @cMsgError)
	If Select(cNewAlias) > 0
		//Carrega vetor com os registros selecionados
		(cNewAlias)->(dbEval({|| AAdd(aDados,{EF06008_FILIAL, EF06008_MATRIC, EF06008_CODVER, EF06008_ANOMESREF, EF06008_REFVER,;
												 AllTrim(EF06008_QTDVER), AllTrim(EF06008_VALVER), EF06008_OPERACAO, '2','',;
												 EF06008_IDAPDATA})},, {|| !EOF()}))

		//Fecha a area
		(cNewAlias)->(dbCloseArea())
	Endif	
Endif	

Return Nil

//--------------------------------------------------------------------------
/*{Protheus.doc} GravaRGB
Faz a gravação da tabela RGB quando, validando todos os campos CHAVES

@author     Eduardo Fernandes
@since      10/11/2016

@Param		 aDados, ARRAY
@return     NIL
@version    P12.1.7
@project    MAN0000007423040_EF_008
*/
//--------------------------------------------------------------------------
Static Function GravaRGB(aDados)
Local nX 		  	:= 0
Local cFilTRB   	:= ""
Local cMatric   	:= ""
Local cPD		 	:= ""
Local cPeriod   	:= ""
Local aPerAtual 	:= {}
Local lGrava	 	:= .T.
Local lSeek	  		:= .F.
Local lEfetiva		:= .F.
Local lITMCLVL  	:= AllTrim(GetMV("MV_ITMCLVL",,"2")) == "1"
Local cMsgError 	:= ""
Local cFilRCH	  	:= ""
Local aAreaSRC		:= SRC->(GetArea())
Local cMatDel		:= ""
Local cFilDel		:= ""

SRA->(dbSetOrder(1))
SRV->(dbSetOrder(1))
RGB->(dbSetOrder(1)) // RGB_FILIAL + RGB_MAT + RGB_PD + RGB_PERIOD + RGB_SEMANA + RGB_SEQ  


For nX:=1 to Len(aDados)
	cFilTRB := aDados[nX,EF_FILIAL]
	cMatric := aDados[nX,EF_MATRIC]
	cPD		 := aDados[nX,EF_CODVER]
	
	aDados[nX, EF_STATUS] := "4" //PROCESSADO ERRO
	cPeriod := ""
	lGrava	 := .T.
	
	//Valida Filial
	If !FWFilExist(cEmpAnt,cFilTRB) 		
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
	ElseIf lGrava .And. SRV->(RV_COD + RV_TIPO) <> aDados[nX, EF_CODVER] + aDados[nX, EF_REF]
		aDados[nX, EF_OBSERVA]:= "Referencia de Verba inexistente no sistema Protheus"
		lGrava	 := .F.
	ElseIf lGrava .And. (aDados[nX, EF_REF] $ "HDV" .And. Val(aDados[nX, EF_QTDVER]) == 0)
		aDados[nX, EF_OBSERVA]:= "Quantidade invalida"
		lGrava	 := .F.
	Endif

	//Busca periodo em aberto
	aPerAtual := {}
	If lGrava
		cFilRCH := U_F0600402( cFilTRB, "RCH")

		If Empty(StoD(aDados[nX,EF_DTREFER]))
			aDados[nX, EF_OBSERVA]:= "Periodo não informado"
			lGrava	 := .F.				
		Else
			cPeriod := MesAno(StoD(aDados[nX,EF_DTREFER]))		
		EndIf
				
		lSeek := RGB->(DbSeek(cFilTRB + cMatric + cPD + cPeriod + "011"))
		If lGrava .And. !lSeek .And. aDados[nX, EF_OPERACAO] == "DELETE"
			aDados[nX, EF_OBSERVA]:= "Registro nao encontrado no Protheus para DELETE"
			lGrava	 := .F.
		ElseIf lGrava .And. lSeek .And. aDados[nX, EF_OPERACAO] == "DELETE"
			DbSelectArea( "RCH")
    		RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL + RCH_PROCES + RCH_PER + RCH_NUMPAG + RCH_ROTEIR" )))
    		If RCH->(DbSeek(cFilRCH + SRA->RA_PROCES + cPeriod + "01" + "RES")) 
    			If !Empty(RCH->RCH_DTINTE)  
					aDados[nX, EF_OBSERVA]:= "Perido informado nao pode ser excluido porque esta integrado no Protheus"
					lGrava	 := .F.
				ElseIf !Empty(RCH->RCH_DTFECH )   	
					aDados[nX, EF_OBSERVA]:= "Perido informado nao pode ser excluido porque esta fechado no Protheus"
					lGrava	 := .F.
				Endif
			Endif		
		Endif		
	Endif					
	
	//------------------------------------------
	// Grava tabela RGB 							//
	//------------------------------------------
	Begin Transaction 
		If lGrava
			If cMatDel != cMatric .Or. cFilDel != cFilTRB
				DeletRegs(cFilTRB, cMatric, cPeriod)
				cMatDel := cMatric
				cFilDel := cFilTRB
			EndIf
		
			If lSeek
				While RGB->(RGB_FILIAL + RGB_MAT + RGB_PD + RGB_PERIOD + RGB_SEMANA + RGB_SEQ) == (cFilTRB + cMatric + cPD + cPeriod + "011")
					If AllTrim(RGB->RGB_XIMPAP) == "I" .And. AllTrim(RGB->RGB_ROTEIR) == "RES"
						If SRC->(DbSeek(RGB->(RGB_FILIAL + RGB_MAT + RGB_PD + RGB_CC + RGB_SEMANA + RGB_SEQ)))
							aDados[nX, EF_OBSERVA]:= "O registro informado já foi processado e não pode ser alterado. "
							aDados[nX,EF_STATUS] := "4"			
							lGrava := .F.
							Exit
						EndIf	
					EndIf
					RGB->(DbSkip())
				EndDo
				lSeek := RGB->(DbSeek(cFilTRB + cMatric + cPD + cPeriod + "011"))
			EndIf
		EndIf
				
		If lGrava
		
			aDados[nX, EF_STATUS] := "3" //PROCESSADO OK
			
			RecLock("RGB", !lSeek)
			If aDados[nX, EF_OPERACAO] == "DELETE"
				//------------------------------------------
				// Exclusao RGB	 							//
				//------------------------------------------
				RGB->(dbDelete())
			Else	
				//------------------------------------------
				// Inclusao/Alteracao RGB					//
				// Campos Chaves nao Altera					//
				//------------------------------------------				
				If !lSeek
					RGB->RGB_FILIAL := cFilTRB		
					RGB->RGB_MAT    := cMatric
					RGB->RGB_PD	  := cPD
					RGB->RGB_PERIOD := cPeriod
					RGB->RGB_SEMANA := "01"
					RGB->RGB_SEQ    := "1"
				Endif	
			
				RGB->RGB_PROCES := SRA->RA_PROCES
				RGB->RGB_ROTEIR := "RES"
				//RGB->RGB_ROTORI := "RES" 
				RGB->RGB_CC 	  := SRA->RA_CC
	
				//Se utiliza ITEM/CLASSE na Folha
				If lITMCLVL 
					RGB->RGB_ITEM := SRA->RA_ITEM
					RGB->RGB_CLVL := SRA->RA_CLVL
				Endif
	
				RGB->RGB_TIPO1  := aDados[nX,EF_REF] 
				RGB->RGB_DTREF  := StoD(aDados[nX,EF_DTREFER])	
				RGB->RGB_TIPO2	:= "I"
				If RGB->RGB_TIPO1 $ "HD"
					RGB->RGB_HORAS := Val(AllTrim(aDados[nX,EF_QTDVER]))
				Else
					RGB->RGB_VALOR := Val(AllTrim(aDados[nX,EF_QTDVER]))
				Endif
				RGB->RGB_XIMPAP := "I"
			Endif		 	
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
RestArea(aAreaSRC)
Return Nil

//--------------------------------------------------------------------------
/*{Protheus.doc} UpdInter
Atualiza STATUS final da tabela INTERFACE 

@author     Eduardo Fernandes
@since      09/11/2016

@Param		 aDados, ARRAY
@Param		 nRecRGB, NUMERIC
@Param		 cChavRGB, STRING
@return     lRet, BOOLEAN
@version    P12.1.7
@project    MAN0000007423040_EF_008
*/
//--------------------------------------------------------------------------
Static Function UpdInter(aDados,nRecRGB,cChavRGB)
Local lRet 	  := .T.
Local cCommand  := ""
Local cMsgError := ""

Local cIDPA6 := U_F0600901("F0600803",nRecRGB,"RGB",cChavRGB,aDados[EF_OBSERVA],dDatabase,aDados[EF_OPERACAO])
Local cOwner	:= GetMV('FS_OWNER',,'')

//------------------------------------------
// Atualiza STATUS da tabela INTERFACE    //
//------------------------------------------
cCommand :=  " UPDATE " + cOwner + "EF06008 SET EF06008_STATUS = '" + aDados[EF_STATUS] + "', "
If !Empty(aDados[EF_OBSERVA])
	cCommand +=  " EF06008_OBSERVA = '" + aDados[EF_OBSERVA] + "', "
Endif	
cCommand +=  " EF06008_ID = '" + cIDPA6 + "',"
cCommand +=  " EF06008_DTPROCESS = '" + DtoS(dDatabase) + "', "
cCommand +=  " EF06008_HRPROCESS = '" + Time() + "' "
cCommand +=  " WHERE EF06008_IDAPDATA = '" + AllTrim(aDados[EF_IDAPDATA]) + "' " 
cCommand +=  "   AND EF06008_STATUS = '2' "
//cCommand +=  " COMMIT "

If !U_F06001C5(cCommand, @cMsgError)
 	Conout(cMsgError)
 	lRet := .F.
Endif		
	
Return lRet

//--------------------------------------------------------------------------
/*{Protheus.doc} TsJ00801
Testa JOB iniciando pelo TDS
@author     Eduardo Fernandes
@since      09/11/2016
@return     NIL
@version    P12.1.7
@project    MAN0000007423040_EF_008
*/
//--------------------------------------------------------------------------
User Function TsJ00801()
	Local aVet := {{'01','01010002'}}
	U_F0600803(aVet)
Return

//--------------------------------------------------------------------------
/*{Protheus.doc} UpdInter
Deleta os registros já integrados na tabela RGB

@author     Nairan Alves Silva
@since      04/12/2017

@Param		 cFilTRB, Código da Filial RGB
@Param		 cMatUser, Matrícula do Usuário
@Param		 cPeriod, Período
@return     Nil
@version    P12.1.7
@project    MAN0000007423048_EF_019
*/
//--------------------------------------------------------------------------

Static Function DeletRegs(cFilTRB,cMatUser,cPeriod)

	Local cAlias1	:= GetNextAlias()
	Local aAreaRGB	:= RGB->(GetArea())
	Local aAreaSRC	:= SRC->(GetArea())
	Local cQuery 	:= ''
	Local lEfetiva	:= .F.
	
	cQuery := " SELECT RGB_FILIAL, RGB_MAT, RGB_PD, RGB_CC, RGB_SEMANA, RGB_SEQ, R_E_C_N_O_ NumRec "
	cQuery += " FROM	" + RetSqlName("RGB") + " "
	cQuery += " WHERE RGB_FILIAL = '" + cFilTRB + "' "
	cQuery += " AND RGB_PERIOD = '" + cPeriod + "' "
	cQuery += " AND RGB_MAT = '" + cMatUser + "' "
	cQuery += " AND RGB_ROTEIR = 'RES' "
	cQuery += " AND RGB_XIMPAP = 'I' "	
	cQuery += " AND D_E_L_E_T_ = ' '  "
	cQuery += " ORDER BY R_E_C_N_O_ DESC "	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1)
	
	While (cAlias1)->(!EOF())
		If !(SRC->(DbSeek((cAlias1)->(RGB_FILIAL + RGB_MAT + RGB_PD + RGB_CC + RGB_SEMANA + RGB_SEQ))))
			RGB->(DbGoTo((cAlias1)->NumRec))
			RecLock("RGB",.F.)
			RGB->( dbDelete() )
			RGB->(MsUnLock())
		EndIf
		(cAlias1)->(DbSkip())
	EndDo
	
	(cAlias1)->(DbCloseArea())
	RestArea(aAreaRGB)
	RestArea(aAreaSRC)
Return