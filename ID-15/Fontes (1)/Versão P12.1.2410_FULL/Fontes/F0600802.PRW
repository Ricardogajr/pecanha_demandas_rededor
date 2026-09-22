#INCLUDE 'TOTVS.CH'
#INCLUDE 'APWEBSRV.CH'

//-----------------------------------------------------------------------
/*/{Protheus.doc} F0600802
Funcao utilizada no metodo LoadRGB do WS Rescisao_ApDat
 
@author Eduardo Fernandes 
@since  08/11/2016
@param cFilXml, characters, descricao
@param cMatric, characters, descricao
@param cCodVer, characters, descricao
@param cRefVer, characters, descricao
@param cQtdVer, characters, descricao
@param cValVer, characters, descricao
@param cAnoMesRef, characters, descricao
@param cDatTran, characters, descricao
@param cHorTran, characters, descricao
@param cOperac, characters, descricao
@param cRet, characters, descricao
@return lRet, BOOLEAN  

@project MAN0000007423040_EF_008
@cliente Rededor
@version P12.1.7
             
/*/
User Function F0600802(cFilXml, cMatric, cCodVer, cRefVer, cQtdVer, cValVer, cAnoMesRef, cDatTran, cHorTran, cOperac, cRet)
Local nI 			:= 0
Local lRet 		:= .T.
Local lMonta  	:= .F.
Local aFiles		:= {'SRA', 'RGB', 'SRV', 'CTT'}
Local aValues		:= {}
Local aTblStru	:= {}
Local cMsgError 	:= ""
Local cFilJob 	:= IIF(!Empty(cFilXml), cFilXml, "01010002")
Local cEF06ID     := " "  // 416094 - Rogerio Carvalho - 22/05/2018 - DOR04906980
							 // substituicao da funcao FWUUIDV4 por uma funcao de usuario central que gere as chaves 
							 // para integracao na PA6

If Select("SX2") > 0 .And. (cFilJob <> cFilAnt)
	RpcClearEnv() //Desconecta ambiente 
Endif

If Select("SX2") == 0
	//Conecta no ambiente (depende do PrepareIn do config do WS) 
	If !RpcSetEnv( "01", cFilJob,,,,, aFiles )
		Conout('F0600802 - Filial: ' + cFilJob + ' informada invalida, nao foi possivel conectar no ambiente')		
		cRet := cMsgError
		Return .T.
	Endif			
Endif	
	
Conout(" F0100802 - Inicio Thread: '" + cValToChar(ThreadID()))
FWMonitorMsg("F0600401: Integração Cadastro de Controle de Ponto - Filial: " + cFilAnt)														
cRet := "OK"
											
// Conexao com base Externa
cMsgError := ""

If !U_F06001C1(@cMsgError)
	Conout(cMsgError)
	cRet := cMsgError	  
	Return .T.
EndIf
																					
If lRet
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
		Conout(cMsgError)
		cRet := cMsgError		
	Else
		//Carrega Dados do WS no aValues 	
		cEF06ID:=u_ams00003()
							
		AAdd(aValues, "")
		AAdd(aValues, cFilAnt)
		AAdd(aValues, cMatric)
		AAdd(aValues, cCodVer)
		AAdd(aValues, cRefVer)
		AAdd(aValues, cQtdVer)
		AAdd(aValues, cValVer)
		AAdd(aValues, cAnoMesRef)
		AAdd(aValues, DtoS(dDatabase))
		AAdd(aValues, Time())
		AAdd(aValues, cOperac)
		AAdd(aValues, "1")
		AAdd(aValues, "")
		AAdd(aValues, "")
		AAdd(aValues, "")
		AAdd(aValues, cEF06ID)   // 416094 - Rogerio Carvalho - 22/05/2018 - DOR04906980
							 		// substituicao da funcao FWUUIDV4 por uma funcao de usuario central que gere as chaves 
							       // para integracao na PA6
				
		//Inseri registros
		If !U_F06001C4("EF06008", aTblStru, aValues, @cMsgError)
			Conout("Erro no Insert - EF06008 - " + cMsgError)
			cRet := cMsgError
		Else
			//Chama funcao para incluir tabela RGB
			StartJob("U_F0600803",GetEnvServer(),.F.,{"01",cFilAnt})				
		Endif												
	Endif
	
	//------------------------------------------
	// Fecha Conexao com o Banco de Integracao //
	//------------------------------------------
	cMsgError := ""
	U_F06001C2(@cMsgError)
	
Endif			

Conout('F0600802 - Final Thread: ' + cValToChar(ThreadID()) )

Return .T.