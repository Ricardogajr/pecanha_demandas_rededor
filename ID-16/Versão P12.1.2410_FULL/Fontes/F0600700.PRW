#include "protheus.ch"
#include "TOPCONN.CH"

/////////////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------------+//
//| PROJETO CONECTA REDE DOR    |  MODULO | SIGAMDT                                   |//
//+-----------------------------------------------------------------------------------+//
//| PROGRAMA  | F0600700 | AUTOR | Paulo Dias               | DATA | 07/06/2019       |//
//+-----------------------------------------------------------------------------------+//
//| DESCRICAO  | Função: Job integração Transferência - gravação PA6 e Update na  SRE |//
//+-----------------------------------------------------------------------------------+//
/////////////////////////////////////////////////////////////////////////////////////////


User Function F0600700(aParam)
Local aArea         := GetArea()
Local lRet			:= .T.
Local cOper			:= "UPSERT"
Local cQuery        := "   "
Local cPA6IDa       := " "
Local cPA6IDb       := " "
Local cQryUPDa   	:= " "
Local cQryUPDb   	:= " "
Local dDtInt        := DATE()
Local cEmpIni   := IIF(ValType(aParam) == "A", aParam[1], cEmpAnt)
Local cFilIni   := IIF(ValType(aParam) == "A", aParam[2], cFilAnt)

If !LockByName("F0600700_" + cEmpIni, .F. ,.F.)
		Conout("F0600700 - Ja existe um Job com mesmo nome em execucao!")
Else
	//If !RpcSetEnv( cEmpIni, cFilIni,,,"FAT",, /*aFiles*/ ) ticket n° 9303216
	//	Conout("F0600700 - Nao foi possivel inicializar o ambiente.") ticket n° 9303216	
	//Else ticket n° 9303216
	
	// início ticket n° 9948084
	If !RpcSetEnv(cEmpIni,cFilIni,,,"FAT",,)
		Conout("Integra Transferências (INC) - Inicialização de Ambiente Não Realizada")
		restarea(aArea)
		Return
	Endif
	// Fim

		cQuery  := "SELECT RE_FILIALD,RE_FILIALP,RE_MATD,RE_MATP,RE_CCD,RE_CCP,RE_DEPTOD,RE_DEPTOP,RE_PROCESD,RE_PROCESP,RE_XDTPA6,RE_XIDINC,SRE.R_E_C_N_O_ "
		cQuery  += "FROM "+ RetSqlName("SRE") + " SRE " 
		cQuery  += "WHERE SRE.D_E_L_E_T_ = ' ' "
		cQuery  += "AND RE_XDTPA6 = ' ' " 
		cQuery  += "AND RE_XIDINC = '                                    ' "  
		cQuery  += "ORDER BY SRE.R_E_C_N_O_  "
		
		If Select("TSRE") > 0
			TSRE->(DbCloseArea())
		EndIf
		
		TCQUERY cQuery NEW ALIAS "TSRE"
		
		TSRE->( dbGoTop() )
		
		While TSRE->(!Eof())

			If  TSRE->RE_CCD <> TSRE->RE_CCP

				cPA6IDa :=  U_F0600901("F0600301",; // cFunc 
							TSRE->(R_E_C_N_O_),; // nRecno 
							"SRE",; // cAliasTrb 
							TSRE->RE_FILIALD + TSRE->RE_MATD,; // cChave 
							"",; // cObs
							CTOD(""),; // Data de envio
							cOper,; // Operacao
							TSRE->RE_FILIALD)
				
				If EMPTY(TSRE->RE_XDTPA6) .AND. EMPTY(TSRE->RE_XIDINC)
					dbSelectArea("SRE")
					dbSetOrder(1)
					dbGoTo(TSRE->(R_E_C_N_O_))
				
					RecLock("SRE",.F.)
						SRE->RE_XDTPA6 := DATE()
						SRE->RE_XIDINC := cPA6IDa
					SRE->(MsUnlock())
				Else
					lRet := .F.
				EndIf
				/*
				cQryUPDa := "UPDATE "+ RetSqlName("SRE") + " SRE "   
				cQryUPDa += "SET RE_XIDINC = '" + cPA6IDa + "'  "
				//cQryUPDa += "RE_XDTPA6 = '" +DTOS(dDtInt) + "'   "
				cQryUPDa += "WHERE D_E_L_E_T_= ' ' "
				cQryUPDa += "AND RE_XIDINC = '                                    ' "	
				cQryUPDa +=	"AND RE_XDTPA6 = ' ' "	
				cQryUPDa += "AND RE_FILIALD = '"+ TSRE->RE_FILIALD + "' "
				cQryUPDa += "AND RE_FILIALP = '"+ TSRE->RE_FILIALP + "' "
				cQryUPDa += "AND RE_MATD = '"+ TSRE->RE_MATD + "' "
				cQryUPDa += "AND RE_MATP = '"+ TSRE->RE_MATP + "' 

				nExecSql := TCSQLEXEC(cQryUPDa) 

					If nExecSql > 0
						If !lIntRot
								Conout ( "TRANSFERÊNCIAS - Erro na atualização de integração da tabela SRE." )
						Endif
					Endif
				
				cQryUPDa := " "
				*/


			EndIf
		
			If  TSRE->RE_FILIALD <> TSRE->RE_FILIALP .OR.;
				TSRE->RE_DEPTOD <> TSRE->RE_DEPTOP .OR.; 
				TSRE->RE_PROCESD <> TSRE->RE_PROCESP

				cPA6IDb :=  U_F0600901("F0600701",; // cFunc 
							TSRE->(R_E_C_N_O_),; // nRecno 
							"SRE",; // cAliasTrb 
							TSRE->RE_FILIALD + TSRE->RE_MATD,; // cChave 
							"",; // cObs
							CTOD(""),; // Data de envio
							cOper,; // Operacao
							TSRE->RE_FILIALD) 
					
					If EMPTY(TSRE->RE_XDTPA6) .AND. EMPTY(TSRE->RE_XIDINC) 
						dbSelectArea("SRE")
						dbSetOrder(1)
						dbGoTo(TSRE->(R_E_C_N_O_))
					
						RecLock("SRE",.F.)
							SRE->RE_XDTPA6 := DATE()
							SRE->RE_XIDINC := cPA6IDb
						SRE->(MsUnlock())
					Else
						lRet := .F.
					EndIf
				
				/*
				cQryUPDb := "UPDATE "+ RetSqlName("SRE") + " SRE "  
				cQryUPDb += " SET RE_XIDINC = '" + cPA6IDb + "'  "
				//cQryUPDb += "RE_XDTPA6 = '" +DTOS(dDtInt) + "'   "
				cQryUPDb += "WHERE D_E_L_E_T_= ' ' "
				cQryUPDb += "AND RE_XDTPA6 =  ' ' "
				cQryUPDb += "AND RE_XIDINC = '                                    ' "	
				cQryUPDb += "AND RE_FILIALD = '"+ TSRE->RE_FILIALD + "' "
				cQryUPDb += "AND RE_FILIALP = '"+ TSRE->RE_FILIALP + "' "
				cQryUPDb += "AND RE_MATD = '"+ TSRE->RE_MATD + "' "
				cQryUPDb += "AND RE_MATP = '"+ TSRE->RE_MATP + "' "

				nExecSql := TCSQLEXEC(cQryUPDb) 

					If nExecSql > 0
						If !lIntRot
								Conout ( "TRANSFERÊNCIAS - Erro na atualização de integração da tabela SRE." )
						Endif
					Endif
				
				cQryUPDb := " "
				*/

			EndIf
		
		TSRE->(dbskip())

		Enddo

		TSRE->(DbCloseArea())
		
		Restarea(aArea)

		//RpcClearEnv() // Desconecta ambiente. ticket n° 9303216

	//EndIf ticket n° 9303216
	
	Conout("F0600700 - Final Thread: " + cValToChar(ThreadID()))
		
	UnLockByName("F0600700_" + cEmpIni, .F., .F.)

EndIf

Return lRet 