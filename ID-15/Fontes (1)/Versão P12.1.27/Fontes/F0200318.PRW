#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"
/*
{Protheus.doc} F0200318()
Insere incentivo academico
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_003
@Return	 cHtml
*/
User Function F0200318()
	
	Local cHtml   := ""
	Local oParam  := Nil
	Local oOrg    := Nil
	Local oSolic  := Nil
	
	cMsg := "Inconsistencia encontrada no cadastro da pessoa logada ou na amarração da visão."
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	fGetInfRotina("U_F0200301.APW") //Verificar
	GetMat()							//Pega a Matricula e a filial do participante logado
	
	oOrg := WSORGSTRUCTURE():New()
	WsChgURL(@oOrg,"ORGSTRUCTURE.APW")
	
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
		
		cFilSolic  := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cEmployeeFilial
		cMatSolic  := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
			
		cMat := HTTPSession->RHMat
		cNome := HttpPost->cNome
			
		cDtInicio := substr(HttpPost->cDtInicio,7,4) + substr(HttpPost->cDtInicio,4,2) + substr(HttpPost->cDtInicio,0,2)
		cDtFim := substr(HttpPost->cDtFim,7,4) + substr(HttpPost->cDtFim,4,2) + substr(HttpPost->cDtFim,0,2)
		
		oParam := Nil
		oParam := WSW0200301():new()
		WsChgURL(@oParam,"W0200301.APW")
		
		If !(EMPTY(cDtFim)) .AND. (STOD(cDtFim) - STOD(cDtInicio)) < 0
			cMsg := "Cadastro não Efetuado! A data Final é menor que a data inicial!"
		Else
			
			If oParam:InserePa3(cNome,HttpPost->cLogin,HttpPost->cDepartamento1,HttpPost->cCenCusto1,;
						        HttpPost->cSupFil,HttpPost->cCargo1,HttpPost->cPhone,HttpPost->cRamal,HttpPost->cContact,;
						        HttpPost->cBenefitCode,HttpPost->cInstituteName,HttpPost->cCurseName,;
						        HttpPost->cDtInicio,HttpPost->cDtFim,HttpPost->cDuracao,HttpPost->cMonthlyPayment,;
						        HttpPost->cVlinvesanovig,HttpPost->cVltotcurso,HttpPost->cBenefconcedido,;
						        HttpPost->txtobs,"3",cFilSolic,cMatSolic,HttpPost->cFilFun)
					
				If oParam:OWSINSEREPA3RESULT:llRetorn
					cMsg := "Cadastro Efetuado com Sucesso!"
				Else
					cMsg := oParam:OWSINSEREPA3RESULT:cMsgAvso
				EndIf
			Else
				cMsg := "Erro no cadastro! Verifique os dados informados!"
			EndIf

		EndIf

	EndIf
	cHtml := ExecInPage("F0200301")
	WEB EXTENDED END
	
Return cHtml
