#INCLUDE "TOTVS.CH"

//Layout aDados 
#Define EF_FILIAL   	1		//Filial
#Define EF_MATRIC   	2		//Matricula
#Define EF_DTDEMI   	3		//Dt Demissao
#Define EF_MOTIVO   	4		//Motivo
#Define EF_OPERACAO	5		//Operacao
#Define EF_ID			6		//ID
#Define EF_STATUS   	7		//Status
#Define EF_OBSERVA  	8		//Observa


//-----------------------------------------------------------------------
/*/{Protheus.doc} F0600603
Funcao para consumir WS ApData
 
@author Eduardo Fernandes 
@since  19/12/2016
@param	aDados, array, conjunto dos dados
@return Nil  

@project MAN0000007423040_EF_006
@cliente Rededor
@version P12.1.7
             
/*/
//-----------------------------------------------------------------------
User Function F0600603(aParam)
	Local nX		  := 0
	Local aFiles	  := {'RH3', 'RH4', 'P10'}
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
	If !LockByName("F0600603_" + cFilIni ,.F.,.F. )
		Conout('F0600603 - Já existe um Job com mesmo nome em execução!')
	Else
		ConOut("**************************************************************************")
		ConOut("* F0600603: Integração Cadastro de Rescisao x WS ApData	 				 *")
		ConOut("* Início: " + Dtos(dDtIni) + " - " + cHora + "                   		 	 *")
		ConOut("* Montagem do ambiente na empresa " + cEmpIni + " - " + cFilIni + " 		 *")
		Conout("* F0600603 - Inicio Thread: '" + cValToChar(ThreadID()) 					   )
		ConOut("**************************************************************************")	  	  
	  		
		If Select("SX2") == 0 
			If !RpcSetEnv( cEmpIni, cFilIni,,,,, aFiles )
				Conout('F0600603 - Nao foi possivel inicializar o ambiente')
				UnLockByName("F0600603_" + cFilIni,.F.,.F. )
				Return .F.
			Endif
			lMontaAmb := .T.
		Endif
				
		FWMonitorMsg("F0600603: Integração WS ApData x Rescisao - Filial: " + cFilAnt)														
											
		// Conexao com base Externa
		cMsgError := ""
		If !U_F06001C1(@cMsgError)
			Conout(cMsgError)
			UnLockByName("F0600603_" + cFilIni,.F.,.F. )			
			Return .F.
		EndIf
																					
		//Montando estrutura da tabela
		AAdd(aTblStru, {"EF06006_ID"			,	"VARCHAR",	032})
		AAdd(aTblStru, {"EF06006_FILIAL"		,	"VARCHAR",	008})
		AAdd(aTblStru, {"EF06006_MATRICULA"	,	"VARCHAR",	006})
		AAdd(aTblStru, {"EF06006_DTATEND"		,	"VARCHAR",	008})
		AAdd(aTblStru, {"EF06006_MOTIVO"		,	"VARCHAR",	006})
		AAdd(aTblStru, {"EF06006_DTTRANSAC"	,	"VARCHAR",	008})
		AAdd(aTblStru, {"EF06006_HRTRANSAC"	,	"VARCHAR",	008})
		AAdd(aTblStru, {"EF06006_OPERACAO"		,	"VARCHAR",	006})
		AAdd(aTblStru, {"EF06006_STATUS"		,	"VARCHAR",	001})
		AAdd(aTblStru, {"EF06006_DTPROCESS"	,	"VARCHAR",	008})
		AAdd(aTblStru, {"EF06006_HRPROCESS"	,	"VARCHAR",	008})
		AAdd(aTblStru, {"EF06006_OBSERVA"		,	"VARCHAR",	700})		
				
		cMsgError := ""
		If !U_F06001C3("EF06006", aTblStru, @cMsgError)				
			Conout("Erro na criação da Tabela Interface - EF06006")
		Else
			
			//função para analise dados
			LoadTRB(@aDados, cFilIni)
		
			If Len(aDados) == 0
				Conout("Não existem registros para serem processados na tabela - EF06006")
			Else
				//------------------------------------------
				// Consome WS CLient do ApData				//
				//------------------------------------------
				WsApData(@aDados)				
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
		
		Conout('F0600603 - Final Thread: ' + cValToChar(ThreadID()) )
		UnLockByName("F0600603_" + cFilIni,.F.,.F. )			 				
	EndIf

Return NIL

//--------------------------------------------------------------------------
/*{Protheus.doc} LoadTRB
Seleciona os registros da tabela de Interface

@author     Eduardo Fernandes
@since      19/12/2016

@Param		 aDados, array, conjunto dos dados
@return     NIL
@version    P12.1.7
@project    MAN0000007423040_EF_006
*/
//--------------------------------------------------------------------------
Static Function LoadTRB(aDados, cFilIni)
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
cCommand :=  " UPDATE " + cOwner + "EF06006 SET EF06006_STATUS = '2' WHERE EF06006_STATUS = '1' AND EF06006_FILIAL = '"+cFilIni+"' " "
//cCommand +=  " COMMIT "
If !U_F06001C5(cCommand, @cMsgError)
 	Conout(cMsgError)
	Return		
Endif		 

//------------------------------------------
// Consulta Registros A PROCESSAR 			//
//------------------------------------------
cQuery := " SELECT EF06006_FILIAL, EF06006_MATRICULA, EF06006_DTATEND DTATEND, EF06006_MOTIVO, EF06006_OPERACAO, EF06006_ID, EF06006_DTTRANSAC, EF06006_HRTRANSAC  "
cQuery += " FROM EF06006 " 
cQuery += " WHERE EF06006_STATUS = '2' "
cQuery += " AND EF06006_FILIAL = '"+cFilIni+"' "
cQuery += " ORDER BY EF06006_FILIAL, EF06006_DTTRANSAC, EF06006_HRTRANSAC "

If U_F06001C6(cQuery, cNewAlias, @cMsgError)
	If Select(cNewAlias) > 0
		//Carrega vetor com os registros selecionados
		(cNewAlias)->(dbEval({|| AAdd(aDados,{EF06006_FILIAL, EF06006_MATRICULA, DTATEND, EF06006_MOTIVO,; 
												   EF06006_OPERACAO, EF06006_ID, "3", "" })},, {|| !EOF()}))

		//Fecha a area
		(cNewAlias)->(dbCloseArea())
	Endif	
Endif	

Return Nil	
	
//-----------------------------------------------------------------------
/*/{Protheus.doc} WsApData
Funcao para consumir WS ApData
 
@author Eduardo Fernandes 
@since  20/12/2016
@return Nil  

@project MAN0000007423040_EF_006
@cliente Rededor
@version P12.1.7
             
/*/
//-----------------------------------------------------------------------
Static Function WsApData(aDados)
	Local nX, nY		:= 0
	Local aArquivo	:= {}
	Local aMethod		:= {}
	Local cFileWsdl	:= ""
	Local cMetodo		:= ""
	
	Local cRet  		:= ""
	Local cMsg			:= ""
	Local cURL			:= GetMV("FS_URLAPDT",,"http://10.25.136.22:7800/conectador/InformarRescisaoProtheus12SA?WSDL")
													  
	Local cWSDL		:= "\wsdl\informarrescisaosn.wsdl"
	Local lRet			:= .T.
		
	Local oWSDL		:= Nil
	Local oXML			:= Nil
	Local cChave		:= ""
	Local cChaveApData := ""
	Local nLoop		:= ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento para ambiente Linux ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If IsSrvUnix() .And. GetRemoteType() == 1
		cWSDL := StrTran(cWSDL,"\","/")
	Endif	
	
	oWSDL	:= TWSDLManager():New()
	oXML 	:= TXMLManager():New()
	//oWSDL:SetProxy( "10.171.0.62" , 8080 ) //Configura Proxy
		
	//If !oWsdl:ParseFile( cWSDL )
	
	oWsdl:bNoCheckPeerCert := .T.
	If !oWSDL:ParseURL(cURL)	
		cMsg := "[" + FwTimeStamp(2) + "] - Arquivo WSDL informado invalido"
		cMsg += CRLF + oWsdl:cError
		lRet := .F.		
	EndIf
	
	If lRet			
		aMethod := oWSDL:ListOperations() 
		
		Conout("[" + FwTimeStamp(2) + "] - InformarRescisaoSN: procurando método!")
		If AScan(aMethod, {|x| x[1] $ "Incluir/Excluir"}) == 0
			cMsg := "[" + FwTimeStamp(2) + "] - Incluir/Excluir: Métodos não encontrado!"			
			Conout(cMsg)
			lRet := .F.
		EndIf
	EndIf
		
	If lRet
		For nX:=1 to Len(aDados)
			lRet := .T.
			cChaveApData := ""

			If nX > 1
				FreeObj(oWSDL)
				FreeObj(oXML)
				oWSDL	:= TWSDLManager():New()
				oXML 	:= TXMLManager():New()
				If !oWSDL:ParseURL(cURL)	
					cMsg := "[" + FwTimeStamp(2) + "] - Arquivo WSDL informado invalido"
					cMsg += CRLF + oWsdl:cError
					lRet := .F.		
				EndIf
				
				If lRet			
					aMethod := oWSDL:ListOperations() 
					Conout("[" + FwTimeStamp(2) + "] - InformarRescisaoSN: procurando método!")
					If AScan(aMethod, {|x| x[1] $ "Incluir/Excluir"}) == 0
						cMsg := "[" + FwTimeStamp(2) + "] - Incluir/Excluir: Métodos não encontrado!"			
						Conout(cMsg)
						lRet := .F.
					EndIf
				EndIf
				
				If !lRet
					Exit
				Endif
			Endif
			Conout("[" + FwTimeStamp(2) + "] - InformarRescisaoSN: definindo método a ser executado!")
		
			//Selecionando Metodo
			cMetodo := IIF(aDados[nX,05] == "UPSERT", "Incluir", "Excluir")
			If !oWSDL:SetOperation(cMetodo)
				cMsg := "[" + FwTimeStamp(2) + "] - " + cMetodo + ": Não foi possível estabelecer a chamada do método!"
				Conout(cMsg)
				lRet := .F.
				aDados[nX][EF_OBSERVA]	:= cMsg
				aDados[nX][EF_STATUS]		:= "4"
				UpdInter(aDados[nX])
				Loop
			EndIf
			//Set dos parametros
			oWSDL:SetValue(0, aDados[nX, EF_MATRIC])	//Matricula
			oWSDL:SetValue(1, aDados[nX, EF_FILIAL])	//Filial
			oWSDL:SetValue(2, aDados[nX, EF_DTDEMI])	//Dt. Desligamento

			If cMetodo == "Incluir"			
				oWSDL:SetValue(3, StrZero( Val(aDados[nX, EF_MOTIVO]), 2))	//Motivo
			Else
				cChaveApData	:= Posicione("SRA", 1, aDados[nX, EF_FILIAL] + aDados[nX, EF_MATRIC], "RA_XIDAPDT")			
				oWSDL:SetValue(3, cChaveApData)	//chave Apdata				
			EndIf	
					
			cMsg := oWSDL:GetSoapMsg()
			
			cMsg := TrataXML(cMetodo,cMsg)//padroniza o XML esperado pela IBM
			
			If !oWSDL:SendSoapMsg(cMsg)
				cMsg := "[" + FwTimeStamp(2) + "] - " + cMetodo + ": erro ao enviar requisição ao servidor!" + chr(13) + chr(10)
				cMsg += oWSDL:GetSoapResponse()
				Conout(cMsg)
				aDados[nX][EF_OBSERVA]	:= cMsg
				aDados[nX][EF_STATUS]		:= "4"
				UpdInter(aDados[nX])
				lRet := .F.
				Loop				
			EndIf
	
			If lRet
				//Retorno WS
				cRet := oWSDL:GetSoapResponse()
		
				If !oXML:Parse(cRet) .AND. !(Empty(oXml:Error()))					
					cMsg := "[" + FwTimeStamp(2) + "] - " + cMetodo + ": Erro ao tentar parsear XML! " + cRet  
					Conout(cMsg)
					aDados[nX][EF_OBSERVA]	:= cMsg
					aDados[nX][EF_STATUS]		:= "4"
					UpdInter(aDados[nX])
					lRet := .F.
					Loop					
				EndIf
			EndIf
	
			If lRet				
				If !("<Status>true</Status>" $ cRet)
					cMsg := "[" + FwTimeStamp(2) + "] - " + cMetodo + ": Estrutura de XML não reconhecida! " + cRet
					Conout(cMsg)
					aDados[nX][EF_OBSERVA]	:= cMsg
					aDados[nX][EF_STATUS]		:= "4"
					UpdInter(aDados[nX])
					lRet := .F.
					Loop					
				EndIf
								
				If lRet
					If cMetodo == "Incluir"	
						cChave := SubStr(cRet,At("<ChaveGerada>",cRet)+Len("<ChaveGerada>"),10)
						For nLoop := 1 To Len(cChave)		    						
							If SubStr(cChave,nLoop,1) $ "0123456789"      
								cChaveApData += SubStr(cChave,nLoop,1)
							EndIf				
						Next 
						
						dbSelectArea("SRA")
						SRA->(dbSetOrder(1))
						SRA->(dbSeek(aDados[nX,EF_FILIAL]+aDados[nX,EF_MATRIC]))
						If SRA->(FieldPos("RA_XIDAPDT")) > 0
							RecLock("SRA",.F.)
								SRA->RA_XIDAPDT := cChaveApData
							SRA->(msUnLock())
						EndIf	
					EndIf
				EndIf	
				If lRet	
					aDados[nX][EF_OBSERVA]	:= "Sucesso. Chave ApData = " + cChaveApData + " "
					UpdInter(aDados[nX])
				Endif					
			EndIf						
		Next nX
	Endif		

	//Retorno
	FreeObj(oWSDL)
	FreeObj(oXML)

Return lRet
				
//--------------------------------------------------------------------------
/*{Protheus.doc} UpdInter
Atualiza STATUS final da tabela INTERFACE 

@author     Eduardo Fernandes
@since      20/12/2016

@Param		 aDados, ARRAY
@return     lRet, BOOLEAN
@version    P12.1.7
@project    MAN0000007423040_EF_004
*/
//--------------------------------------------------------------------------
Static Function UpdInter(aLinha)
Local lRet 	  := .T.
Local cCommand  := ""
Local cMsgError := ""
Local cOwner	  := GetMV('FS_OWNER',,'')

//------------------------------------------
// Atualiza STATUS da tabela INTERFACE    //
//------------------------------------------
cCommand :=  " UPDATE " + cOwner + "EF06006 SET EF06006_STATUS = '" + aLinha[EF_STATUS] + "', "
If !Empty(aLinha[EF_OBSERVA])
	cCommand +=  " EF06006_OBSERVA = '" + SubStr(aLinha[EF_OBSERVA],1,700) + "', "
Endif	

cCommand +=  " EF06006_DTPROCESS = '" + DtoS(dDatabase) + "', "
cCommand +=  " EF06006_HRPROCESS = '" + Time() + "' "
cCommand +=  " WHERE EF06006_ID = '" + AllTrim(aLinha[EF_ID]) + "' " 
cCommand +=  " AND EF06006_STATUS = '2' "

If !U_F06001C5(cCommand, @cMsgError)
 	Conout(cMsgError)
 	lRet := .F.
Endif		
	
Return lRet

Static Function TrataXML(cMetodo,cMsg)
	Local cMens1	:= "ns1:IncluirRequest xmlns:ns1"
	Local cMens2	:= "/ns1:IncluirRequest"
	Local cMens3	:= "ns1:ExcluirRequest xmlns:ns1"
	Local cMens4	:= "/ns1:ExcluirRequest"
	
	If cMetodo == "Incluir"
		cMsg := Stuff(cMsg, At("IncluirRequest xmlns", cMsg),Len("IncluirRequest xmlns"),cMens1)
		cMsg := Stuff(cMsg, At("/IncluirRequest", cMsg),Len("/IncluirRequest"),cMens2)
	Elseif  cMetodo == "Excluir"
		cMsg := Stuff(cMsg, At("ExcluirRequest xmlns", cMsg),Len("ExcluirRequest xmlns"),cMens3)
		cMsg := Stuff(cMsg, At("/ExcluirRequest", cMsg),Len("/ExcluirRequest"),cMens4)
	EndIf 
Return cMsg


//--------------------------------------------------------------------------
/*{Protheus.doc} TsJ00606
Testa JOB iniciando pelo TDS
@author     Eduardo Fernandes
@since      20/12/2016
@return     NIL
@version    P12.1.7
@project    MAN0000007423040_EF_006
*/
//--------------------------------------------------------------------------
User Function TsJ00606()
	Local aVet := {{'01','01010002'}}
	U_F0600603(aVet)
Return
