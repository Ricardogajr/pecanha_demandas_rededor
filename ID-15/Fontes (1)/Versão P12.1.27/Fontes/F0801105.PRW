#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"

/*
{Protheus.doc} F0801105()

@Author     Henrique Madureira
@Since	     27/03/2017
@Version    P12.7
@Project    MAN0000007423042_EF_011
@Return	 cHtml
*/
User Function F0801105()

	Local cHtml   := ""
	Local oParam  := Nil
	Local oOrg    := Nil
	Local oSolic  := Nil
	
	cMsg := "Inconsistencia encontrada no cadastro da pessoa logada ou na amarração da visão."
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	fGetInfRotina("U_F0801101.APW") //Verificar
	GetMat()							//Pega a Matricula e a filial do participante logado
	
	oOrg := WSORGSTRUCTURE():New()
	WsChgURL(@oOrg, "ORGSTRUCTURE.APW")
	
	oOrg:cParticipantID   := ""
	oOrg:cVision          := HttpSession->aInfRotina:cVisao
	oOrg:cEmployeeFil     := HttpSession->aUser[2]
	oOrg:cRegistration    := HttpSession->RhMat
	oOrg:cEmployeeSolFil  := HttpSession->aUser[2]
	oOrg:cRegistSolic     := HttpSession->RhMat
	
	If Type("HttpSession->RHMat") != "U" .And. !Empty(HttpSession->RHMat)
		oOrg:cRegistration := HttpSession->RHMat
	EndIf
	
	If oOrg:GetStructure()
		
		oSolic := WSW0500308():New()
		WsChgURL(@oSolic, "W0500308.apw")
		
		cFilSol   := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cEmployeeFilial
		cMatSol   := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
		cVOrg     := HttpSession->aInfRotina:cVisao
		cEmpFunc  := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cEmployeeEmp
		cDepto    := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cDepartment
		cFilSolic := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cEmployeeFilial
		cMatSolic := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
		
		oInfPar	:= WSCFGDICTIONARY():NEW()
		WsChgURL(@oInfPar, "CFGDICTIONARY.APW")

		If oInfPar:GETPARAM( "MSALPHA", "FS_DINIFER" )
				// Verifica se existe o parametro
			If oInfPar:cGETPARAMRESULT <> ".F."
				nDiIni := Val(oInfPar:cGETPARAMRESULT)
			Else
				nDiIni := 45
			EndIf
		EndIf
	
		If oInfPar:GETPARAM( "MSALPHA", "FS_DTER2PE" )
				// Verifica se existe o parametro
			If oInfPar:cGETPARAMRESULT <> ".F."
				cDiPer := oInfPar:cGETPARAMRESULT
			Else
				cDiPer := "75"
			EndIf
		EndIf
			
		oParam := Nil
		oParam := WSW0801101():new()
		WsChgURL(@oParam, "W0801101.APW")
		
		cDtInicio := (SubStr(HttpPost->txtdtInicial, 7, 4) + SubStr(HttpPost->txtdtInicial, 4, 2) + SubStr(HttpPost->txtdtInicial, 0, 2))
		dDate     := DaySum( Date() , nDiIni )
		If oParam:VldFerias(HttpGet->Matri,HttpGet->cFilFun,cDtInicio,cDiPer)
			If !(Empty(cDtInicio)) .AND. ((STOD(cDtInicio)) > dDate )
				If oParam:InsereSoli( HttpGet->Matri, HttpGet->NomeSol, HttpPost->txtdtInicial, HttpPost->txtdtFinal, HttpPost->txtdias, ;
						HttpGet->cAbono, HttpGet->cParc13, cFilSolic, cMatSolic, HttpGet->cFilFun, HttpPost->txtobs)
						
					If oParam:OWSInsereSoliRESULT:lLRETORN
						cMsg := "Cadastro Efetuado com Sucesso! Código da Solicitação gerada: "+oParam:OWSInsereSoliRESULT:cCodSol+"."
					Else
						cMsg := oParam:OWSInsereSoliRESULT:cMsgAvso
					EndIf
				Else
					cMsg := "Erro no cadastro! Verifique os dados informados!"
				EndIf
			Else
				cMsg := "Data de inicio fora do prazo mínimo possível (" + cValToChar(nDiIni) + " dias), funcionário deve procurar o RH ou informar uma nova data.!"
			EndIf
		Else
			cMsg := "Data superior à " + AllTrim(cValToChar(cDiPer)) + " dias do segundo perídio, funcionário deve procurar o RH ou informar uma nova data.!"
		EndIf			
	EndIf
	
	cHtml := ExecInPage("F0801101")
	
	WEB EXTENDED END
	
Return cHtml
		
