#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"
/*
{Protheus.doc} F0200312()
Insere a solicitação
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_003
@Return	 cHtml
*/
User Function F0200312()
	
	Local cHtml      := ""
	Local cMatAprov  := ""
	Local aAux       := {}
	Local oParam     := Nil
	Local oOrg       := Nil
	Local oSolic     := Nil
	
	cMsg := "Inconsistencia encontrada no cadastro da pessoa logada ou na amarração da visão."
	
	Private cNomePa5 := ""
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	fGetInfRotina("U_F0200306.APW") //Verificar
	GetMat()							//Pega a Matricula e a filial do participante logado
	
	cMat     := HTTPSession->RHMat
	
	oOrg := WSORGSTRUCTURE():New()
	WsChgURL(@oOrg,"ORGSTRUCTURE.APW")
	
	cNomePa5 := HTTPSession->USR_INFO[1]:cusername
	
	oOrg:cParticipantID   := ""
	oOrg:cVision          := HttpSession->aInfRotina:cVisao
	oOrg:cEmployeeFil     := HttpSession->aUser[2]
	oOrg:cRegistration    := HttpSession->RhMat
	oOrg:cEmployeeSolFil  := HttpSession->aUser[2]
	oOrg:cRegistSolic     := HttpSession->RhMat
	If ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat)
		oOrg:cRegistration := HttpSession->RHMat
	EndIf
	If oOrg:GetStructure()
		oSolic := WSW0500308():New()
		WsChgURL(@oSolic,"W0500308.apw")
		
		cFilSol  := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cEmployeeFilial
		cMatSol  := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
		cVOrg    := HttpSession->aInfRotina:cVisao
		cEmpFunc := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cEmployeeEmp
		cDepto   := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cDepartment
		
		cFilSolic := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cEmployeeFilial
		cMatSolic := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
			
		oParam := Nil
		oParam := WSW0200301():new()
		WsChgURL(@oParam,"W0200301.APW")
			
		If oParam:InsereSoli(HttpGet->cMat, HttpGet->cNome, HttpPost->txtCalendario, HttpPost->txtCurso,HttpPost->txtTurma,dtos(Date()),;
				             HttpPost->txtObservacao, cFilSolic,cMatSolic, HttpGet->cFilFun)
			If oParam:OWSInsereSoliRESULT:llRetorn
				cMsg := "Cadastro Efetuado com Sucesso!"
			Else
				cMsg := oParam:OWSInsereSoliRESULT:cMsgAvso
			EndIf
		Else
			cMsg := "Erro no cadastro! Verifique os dados informados!"
		EndIf
		
	EndIf
	
	cHtml := ExecInPage("F0200305")
	WEB EXTENDED END
	
Return cHtml
