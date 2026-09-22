#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"

/*/{Protheus.doc} F0500309
(long_description)
@type    function
@author  henrique.toyada
@since   31/10/2016
@version 1.0
@return  cHtml, Retorno pagina para ser acessada
@project MAN00000463301_EF_003
/*/
User Function F0500309()
	
	Local cHtml    := ""
	
	Local nReg     := 0
	Local oOrg
	
	Private cMsg
	Private cObsApr := 'S'
	Private oParam
	Private oLista
	Private oLista2
	Private oSol
	Private cInclus := "S"
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	HttpCTType("text/html; charset=ISO-8859-1")
	
	cCodigo := HttpGet->cCodigo
	cTipo   := HttpGet->cTipo
	cOperac := HttpGet->cStatus
	cVisao  := HttpGet->cVisao
	cMatric := HttpSession->RHMat
	nOperac := HttpGet->cStatus
	cCodMat := HttpGet->cCodMat
	cFilRh3 := HttpGet->cFilRh3
	cFilials  := HttpGet->cFilRh3
	cFilis  := HttpGet->cFilRh3
	cFilFun := HttpGet->cFilRh3
	cFililS := HttpGet->cFilRh3
	cDesc   := HttpGet->cDesc
	
	oInf   := WSW0500307():new()
	WsChgURL(@oInf,"W0500307.APW")
	If oInf:ChkRh3(cCodigo)
		lRet := oInf:lCHKRH3RESULT
	EndIf
	
	IF oInf:BscDados(cFilRh3, cCodigo)
		cFilSoli:= oInf:oWSBSCDADOSRESULT:cFilSoli
		cDescFil:= oInf:oWSBSCDADOSRESULT:cDescFil
		cFilIniS:= oInf:oWSBSCDADOSRESULT:cFilIniS
		cDescFlS:= oInf:oWSBSCDADOSRESULT:cDescFlS
		cMatrFlS:= oInf:oWSBSCDADOSRESULT:cMatrFlS
		cNomeFlS:= oInf:oWSBSCDADOSRESULT:cNomeFlS
		cDescCar:= oInf:oWSBSCDADOSRESULT:cDescCar
		cDescCtt:= oInf:oWSBSCDADOSRESULT:cDescCtt
		cFilSltd:= oInf:oWSBSCDADOSRESULT:cFilSltd
		cDecSltd:= oInf:oWSBSCDADOSRESULT:cDecSltd
		cMatSltd:= oInf:oWSBSCDADOSRESULT:cMatSltd
		cNomSltd:= oInf:oWSBSCDADOSRESULT:cNomSltd
		cCARSLTD:= oInf:oWSBSCDADOSRESULT:cCARSLTD
	EndIf
	
	Do Case
	Case cTipo = '001'
		cStatus   := "1"
		lBtAprova := .F.
		lRet := .T.
		cMATRI    := cCodMat
		cSolic    := cCodigo
		oParam := WSW0200301():new()
		WsChgURL(@oParam,"W0200301.APW")
		
		If oInf:BuscaTrm(cCodigo,cFilRh3)
			CCalend  := oInf:oWSBUSCATRMRESULT:CCalend
			CCurso   := oInf:oWSBUSCATRMRESULT:CCurso
			cNOME    := oInf:oWSBUSCATRMRESULT:CNome
			cObserva := oInf:oWSBUSCATRMRESULT:CObs
		EndIf
		
		If oParam:InfTrm(CCalend,CCurso,cFilRh3)
			cCalendario 	:=  oParam:oWSInfTrmRESULT:cCalendario
			cCurso 		:=  oParam:oWSInfTrmRESULT:cCurso
			cHorario 		:=  oParam:oWSInfTrmRESULT:cHorario
			cInicio 		:=  oParam:oWSInfTrmRESULT:cInicio
			cTermino 		:=  oParam:oWSInfTrmRESULT:cTermino
			cTreinamento 	:=  oParam:oWSInfTrmRESULT:cTreinamento
			cVagas 		:=  oParam:oWSInfTrmRESULT:cVagas
			cTurma 		:=  oParam:oWSInfTrmRESULT:cTurma
		EndIf
		
		oParam := WSW0500307():new()
		WsChgURL(@oParam,"W0500307.APW")
		
		If oParam:BuscObser(cFilRh3, cCodigo)
			oLista2 :=  oParam:oWSBuscObserRESULT
		EndIf
		
		cHtml := ExecInPage("F0200309")//Treinamento/Evento
		
	Case cTipo = '002'
		
		fGetInfRotina("U_F0100301.APW") //Verificar
		GetMat()							//Pega a Matricula e a filial do participante logado
		
		cCodSol := cCodigo
		cMatric := HttpSession->RHMat
		cVisPad := HttpSession->aInfRotina:cVisao
		nOperac := '9'
		cTVaga  := ""
		cLugar  := "1"
	    
		oSol := WSW0500308():New()
		WsChgURL(@oSol,"W0500308.APW")
		
		oSol:BscSolVags(cCodSol,cMatric,cVisPad,cFililS)
		If oSol:oWSBscSolVagsRESULT:cRet == ".T."
			cFVaga   := oSol:oWSBscSolVagsRESULT:cFilVag
			cTVaga   := "Contratação"
			cCdDept  := oSol:oWSBscSolVagsRESULT:cDepto
			cDscDpt  := oSol:oWSBscSolVagsRESULT:cDescDpt
			cCdPost  := oSol:oWSBscSolVagsRESULT:cPosto
			cFPost   := oSol:oWSBscSolVagsRESULT:cFlPost
			cCdCC    := oSol:oWSBscSolVagsRESULT:cCodCC
			cDESCRCC := oSol:oWSBscSolVagsRESULT:cDescCc
			cCdFun   := oSol:oWSBscSolVagsRESULT:cFuncao
			CDESCRFC := oSol:oWSBscSolVagsRESULT:cDescFu
			cNSolic  := oSol:oWSBscSolVagsRESULT:cNomeSol
			cPrzVg   := oSol:oWSBscSolVagsRESULT:cPrazo
			cDtAbt   := oSol:oWSBscSolVagsRESULT:cDtAbt
			cDtFch   := oSol:oWSBscSolVagsRESULT:cDtFch
			cCustV   := oSol:oWSBscSolVagsRESULT:cCustVg
			cPrSel   := oSol:oWSBscSolVagsRESULT:cProcS
			cTpVg    := IIF(AllTrim(oSol:oWSBscSolVagsRESULT:cTpVaga) == "1","Int./Ext.",IIF(AllTrim(oSol:oWSBscSolVagsRESULT:cTpVaga) == "2","Interna","Externa"))
			cJornTb  := oSol:oWSBscSolVagsRESULT:cHorMes
			cObservacao   := ALLTRIM(oSol:oWSBscSolVagsRESULT:cXObs)
			cDscDetal   := ALLTRIM(oSol:oWSBscSolVagsRESULT:cObserDet)	
			cCODCARGO  := oSol:oWSBscSolVagsRESULT:cCODCARGO
			cDESCRCARGO  := oSol:oWSBscSolVagsRESULT:cDESCRCARGO
			cTurno   := oSol:oWSBscSolVagsRESULT:cTurnoTab
			cDescTrn :=	oSol:oWSBscSolVagsRESULT:cDscTurno
			cCatFun  := oSol:oWSBscSolVagsRESULT:cCatFun
			cDscCatF := oSol:oWSBscSolVagsRESULT:cDscCateg
			cTpCont  := IIF(AllTrim(oSol:oWSBscSolVagsRESULT:cTpContr) == "1","Indeterminado","Determinado")
			cHrsSem  := oSol:oWSBscSolVagsRESULT:cHorSem
			cSalHrs  := oSol:oWSBscSolVagsRESULT:cSalHora
			cDFPost  := oSol:oWSBscSolVagsRESULT:cDscFilPt
			
			If oSol:InfFxSl(cCODCARGO,cFPost)
				oInf :=  oSol:oWSInfFxSlRESULT
			EndIf
			
			If oSol:PegMnem(.T.)
				nVal := VAL(oSol:cPEGMNEMRESULT)
			EndIf 		
			
		EndIf
		
		oParam := WSW0500307():new()
		WsChgURL(@oParam,"W0500307.APW")
		
		If oParam:BuscObser(cFilRh3, cCodigo)
			oLista2 :=  oParam:oWSBuscObserRESULT
		EndIf
		
		cHtml := ExecInPage("F0100310") //Vaga
	Case cTipo = '003'
		
		fGetInfRotina("U_F0100312.APW") //Verificar
		GetMat()							//Pega a Matricula e a filial do participante logado
		//Ajustando solicitação
		cCodSol := cCodigo
		cMatric := HttpSession->RHMat
		cVisPad := HttpSession->aInfRotina:cVisao
		nOperac := "9"
		cLugar  := "1"
	    //cFililS := httpget->cFilil
		oSol := WSW0500308():New()
		WsChgURL(@oSol,"W0500308.APW")
	
		If oSol:BscSolQdro(cCodSol,cMatric,cVisPad,cFililS)
			cFilQd := oSol:oWSBscSolQdroRESULT:cFilQdr
			cCDept := oSol:oWSBscSolQdroRESULT:cCdDept
			cDDept := oSol:oWSBscSolQdroRESULT:cDsDept
			cCFunc := oSol:oWSBscSolQdroRESULT:cCdFunc
			cDFunc := oSol:oWSBscSolQdroRESULT:cDsFunc
			cCCarg := oSol:oWSBscSolQdroRESULT:cCdCarg
			cDCarg := oSol:oWSBscSolQdroRESULT:cDsCarg
			cCCtt  := oSol:oWSBscSolQdroRESULT:cCdCCtt
			cDCtt  := oSol:oWSBscSolQdroRESULT:cDscCtt
			cSalar := oSol:oWSBscSolQdroRESULT:cSalari
			cTpCnt := oSol:oWSBscSolQdroRESULT:cTpCont
			cQntQd := oSol:oWSBscSolQdroRESULT:cQntQdr
			cTpPst := oSol:oWSBscSolQdroRESULT:cTpPost
			cObs   := oSol:oWSBscSolQdroRESULT:cObserv
			cCdPst := oSol:oWSBscSolQdroRESULT:cCodPst
			cOrgSl := oSol:oWSBscSolQdroRESULT:cOrigSl
			AlPstRpr  := oSol:oWSBscSolQdroRESULT:cAlPstRpr  
			AlDsDpRpr := oSol:oWSBscSolQdroRESULT:cAlDsDpRpr 
			AlDpRpr   := oSol:oWSBscSolQdroRESULT:cAlDpRpr   
			AlDscRpr  := oSol:oWSBscSolQdroRESULT:cAlDscRpr  
			AlFlRpr   := oSol:oWSBscSolQdroRESULT:cAlFlRpr   
			AlFlSl    := oSol:oWSBscSolQdroRESULT:cAlFlSl    
			AlDscSl   := oSol:oWSBscSolQdroRESULT:cAlDscSl   
			AlDptSl   := oSol:oWSBscSolQdroRESULT:cAlDptSl   
			AlDscDptSl:= oSol:oWSBscSolQdroRESULT:cAlDscDptSl
		EndIf
		
		oParam := WSW0500307():new()
		WsChgURL(@oParam,"W0500307.APW")
		
		If oParam:BuscObser(cFilRh3, cCodigo)
			oLista2 :=  oParam:oWSBuscObserRESULT
		EndIf
		
		cCARSLTD := ""		
		
		cHtml := ExecInPage("F0100321")//Aumento de quadro/Orçamento
		
	Case cTipo = '004'
		lRet := .T.
		oParam := WSW0500307():new()
		WsChgURL(@oParam,"W0500307.APW")
		If oParam:FunRh3(cCodigo,cFilRh3)
			cNomeFun := oParam:oWSFUNRH3RESULT:cNOMMAFUN
			cMatFun  := oParam:oWSFUNRH3RESULT:cCODMAFUN
			cFilFunc := IIF(!Empty(cMatFun),cFilRh3,"")
		EndIf
		
		If oParam:ValSesmt(cFilRh3, cCodigo)
			lSesmt := oParam:lVALSESMTRESULT
		EndIf
		
		If oParam:InfRh4F(cCodigo,cFilRh3)
			oLista :=  oParam:oWSINFRH4FRESULT
			cFili        := ALLTRIM(oLista:cPA5FILIAL  )
			cCodVg       := ALLTRIM(oLista:cPA5CDVAGA  )
			cNomVg       := ALLTRIM(oLista:CTMPNMVAGA  )
			cValVg       := ALLTRIM(oLista:cPA5VLVAGA  )
			cSalFe       := ALLTRIM(oLista:cPA5SLFECH  )
			cCodCand     := ALLTRIM(oLista:cPA5CDCAND  )
			cNomCand     := ALLTRIM(oLista:cPA5NMCAND  )
			cCpf         := ALLTRIM(oLista:cPA5CPFCAN  )
			cDtApro      := ALLTRIM(oLista:cPA5DTAPRV  )
			cLogTor      := ALLTRIM(oLista:cPA5LOGTOR  )
			cNomTor      := ALLTRIM(oLista:CTMPNOMTOR  )
			cTMPNMVAGA   := ALLTRIM(oLista:cTMPNMVAGA  )
			cTMPNOMTOR   := ALLTRIM(oLista:cTMPNOMTOR  )
			cPA2FILCAN   := ALLTRIM(oLista:cPA2FILCAN  )
			cPA2STSVAG   := ALLTRIM(oLista:cPA2STSVAG  )
			cPA2DESFIL   := ALLTRIM(oLista:cPA2DESFIL  )
			cPA2CARGO    := ALLTRIM(oLista:cPA2CARGO   )
			cPA2DESCAR   := ALLTRIM(oLista:cPA2DESCAR  )
			cPA2TURNO    := ALLTRIM(oLista:cPA2TURNO   )
			cPA2DESCTU   := ALLTRIM(oLista:cPA2DESCTU  )
			cPA2DEPART   := ALLTRIM(oLista:cPA2DEPART  )
			cPA2DESDEP   := ALLTRIM(oLista:cPA2DESDEP  )
			cPA2CC       := ALLTRIM(oLista:cPA2CC      )
			cPA2DESCC    := ALLTRIM(oLista:cPA2DESCC   )
			cPA2HRMES    := ALLTRIM(oLista:cPA2HRMES   )
			cPA2SALHR    := ALLTRIM(oLista:cPA2SALHR   )
			cPA2DTADMI   := ALLTRIM(oLista:cPA2DTADMI  )
			cTMPFILVAGA  := ALLTRIM(oLista:cTMPFILVAGA )
			cTMPDESCVG   := ALLTRIM(oLista:cTMPDESCVG  )
			cTMPTIPOFAP  := ALLTRIM(oLista:cTMPTIPOFAP )
			cTMPCARGOVG  := ALLTRIM(oLista:cTMPCARGOVG )
			cTMPDSCCGVG  := ALLTRIM(oLista:cTMPDSCCGVG )
			cTMPCCVAGA   := ALLTRIM(oLista:cTMPCCVAGA  )
			cTMPDSCVAGA  := ALLTRIM(oLista:cTMPDSCVAGA )
			cTMPDPTVAGA  := ALLTRIM(oLista:cTMPDPTVAGA )
			cTMPDSCDVAGA := ALLTRIM(oLista:cTMPDSCDVAGA)
			cTMPMATCOLA  := ALLTRIM(oLista:cTMPMATCOLA )
			cTMPNOMECOLA := ALLTRIM(oLista:cTMPNOMECOLA)
			cTMPSALARIO  := ALLTRIM(oLista:cTMPSALARIO )
		EndIf
		
		cMatSltd:= cTMPMATCOLA
		cNomSltd:= cNomCand
		cCARSLTD:= cPA2DESCAR
		
		cFilSltd:= cPA2FILCAN
		cDecSltd:= CPA2DESFIL
		
		If oParam:BuscObser(cFilRh3, cCodigo)
			oLista2 :=  oParam:oWSBuscObserRESULT
		EndIf
		cHtml := ExecInPage("F0500309")//FAP
		
	Case cTipo = '005'
		lRet := .T.
		oParam := WSW0500307():new()
		WsChgURL(@oParam,"W0500307.APW")
		If oParam:FunRh3(cCodigo,cFilRh3)
			cNomeFun := oParam:oWSFUNRH3RESULT:cNOMMAFUN
			cMatFun  := oParam:oWSFUNRH3RESULT:cCODMAFUN
			cFilFunc := IIF(!Empty(cMatFun),cFilRh3,"")
		EndIf
		If oParam:InfRh4D(cCodigo,cFilRh3)
			oLista :=  oParam:oWSINFRH4DRESULT
			cFili    := ALLTRIM(oLista:CP10FILIAL)
			cCodMat  := ALLTRIM(oLista:CP10MATRIC)
			cNomMat  := ALLTRIM(oLista:CTMPMATRIC)
			cDtSoli  := STOD(ALLTRIM(oLista:CP10DTSOLI))
			cCodRes  := ALLTRIM(oLista:CP10CODRES)
			cDesRes  := ALLTRIM(oLista:CTMPDESRES)
			cMotivo  := ALLTRIM(oLista:CP10MOTIVO)
			cDtDesl  := STOD(ALLTRIM(oLista:CP10DTDEMI))
			cNvlUsu  := ALLTRIM(oLista:CNVUSUARIO)
			cSubGrp  := ALLTRIM(oLista:CSUBGRPALC)
		EndIf
		
		If oParam:BuscObser(cFilRh3, cCodigo)
			oLista2 :=  oParam:oWSBuscObserRESULT
		EndIf
		
		cHtml := ExecInPage("F0500310")//DESLIGAMENTO
		
	Case cTipo = '006'
		lRet := .T.
		oParam := WSW0500307():new()
		WsChgURL(@oParam,"W0500307.APW")
		If oParam:FunRh3(cCodigo,cFilRh3)
			cNomeFun := oParam:oWSFUNRH3RESULT:cNOMMAFUN
			cMatFun  := oParam:oWSFUNRH3RESULT:cCODMAFUN
			cFilFunc := IIF(!Empty(cMatFun),cFilRh3,"")
		EndIf
		If oParam:ValSesmt(cFilRh3, cCodigo)
			lSesmt := oParam:lVALSESMTRESULT
		EndIf
		If oParam:InfRh4C(cCodigo,cFilRh3)
			oLista :=  oParam:oWSINFRH4CRESULT
			cTMPFUNCAO := ALLTRIM(oLista:cTMPFUNCAO) //Codigo da Função Atual
			cTMPD_FUNC := ALLTRIM(oLista:cTMPD_FUNC) //Nome da Função Atual
			cTMPSALATU := ALLTRIM(oLista:cTMPSALATU) //Salário Atual
			cTMPTABELA := ALLTRIM(oLista:cTMPTABELA) //Códio da Tabela Atual
			cTMPNIVELT := ALLTRIM(oLista:cTMPNIVELT) //Nivel da Tabela Atual
			cTMPFAIXAT := ALLTRIM(oLista:cTMPFAIXAT) //Faixa Atual
			cRASALARIO := ALLTRIM(oLista:cRASALARIO) //Salário Proposto
			cRATIPOALT := ALLTRIM(oLista:cRATIPOALT) //Motivo da Alteração Salarial
			cTMPD_MOT  := ALLTRIM(oLista:cTMPD_MOT)  //Descrição do  Motivo
			cTMPVLSALA := ALLTRIM(oLista:cTMPVLSALA) //Valor do aumento proposto
			cTMPPERCSA := ALLTRIM(oLista:cTMPPERCSA) //Percentual do Aumento Proposto
			cRACODFUNC := ALLTRIM(oLista:cRACODFUNC) //Codigo da Função Proposta
			cTMPD_F_PP := ALLTRIM(oLista:cTMPD_F_PP) //Nome da Função Proposta
			cTMPH_M_AT := ALLTRIM(oLista:cTMPH_M_AT) //Horas Mês Atual
			cTMPH_S_AT := ALLTRIM(oLista:cTMPH_S_AT) //Horas Semana Atual
			cTMPH_D_AT := ALLTRIM(oLista:cTMPH_D_AT) //Horas Dia Atual
			cRAHRSMES  := ALLTRIM(oLista:cRAHRSMES)  //Horas Mês Proposto
			cRAHRSEMAN := ALLTRIM(oLista:cRAHRSEMAN) //Horas Semana Proposto
			cRAHRSDIA  := ALLTRIM(oLista:cRAHRSDIA)  //Horas Dia Proposto
			cTMPTURNAT := ALLTRIM(oLista:cTMPTURNAT) //Turno de Trabalho Atual
			cTMPD_TURN := ALLTRIM(oLista:cTMPD_TURN) //Nome do Turno Atual
			cTMPS_TURN := ALLTRIM(oLista:cTMPS_TURN) //Seq.Ini.Turno Atual
			cTMPREGRA  := ALLTRIM(oLista:cTMPREGRA)  //Regra Atual
			cRATNOTRAB := ALLTRIM(oLista:cRATNOTRAB) //Turno de trabalho Proposto
			cTMPDESCTU := ALLTRIM(oLista:cTMPDESCTU) //Nome do Turno Proposto
			cRASEQTURN := ALLTRIM(oLista:cRASEQTURN) //Seq.Ini. Turno Proposto
			cRAREGRA   := ALLTRIM(oLista:cRAREGRA)   //Regra Proposta
			cTMPFILIAL := ALLTRIM(oLista:cTMPFILIAL) //Filial Atual
			cTMPD_FILI := ALLTRIM(oLista:cTMPD_FILI) //Nome da Filial Atual
			cTMPCCATU  := ALLTRIM(oLista:cTMPCCATU)  //Centro de Custo Atual
			cTMPD_CCAT := ALLTRIM(oLista:cTMPD_CCAT) //Descrição do Centro de Custo Atual
			cTMPDEPTOA := ALLTRIM(oLista:cTMPDEPTOA) //Departamento Atual
			cTMPD_DEPT := ALLTRIM(oLista:cTMPD_DEPT) //Nome do Departamento Atual
			cRAFILIAL  := ALLTRIM(oLista:cRAFILIAL)  //Filial/Empresa proposta
			cTMPN_F_D  := ALLTRIM(oLista:cTMPN_F_D)  //Nome da Filial/Empresa proposta
			cRACC      := ALLTRIM(oLista:cRACC)      //Centro de Custo proposto
			cTMPD_CC_D := ALLTRIM(oLista:cTMPD_CC_D) //Descrição do Centro de Custo Proposto
			cRADEPTO   := ALLTRIM(oLista:cRADEPTO)   //Departamento Proposto
			cTMPD_DEPD := ALLTRIM(oLista:cTMPD_DEPD) //Nome do Departamento Proposto
			cRAPROCES  := ALLTRIM(oLista:cRAPROCES)  //Nome do Departamento Proposto
			cTMPPROCES := ALLTRIM(oLista:cTMPPROCES) //Processo Atual
			cTMPTIPO   := ALLTRIM(oLista:cTMPTIPO)   //Processo Proposto
			cTMPPOSTO  := ALLTRIM(oLista:cTMPPOSTO)   //Posto Atual
			cRAPOSTO   := ALLTRIM(oLista:cRAPOSTO)   //Posto Proposto
			cTMPCLVL   := ALLTRIM(oLista:cTMPCLVL)   //Classe Valor Atual
			cRACLVL    := ALLTRIM(oLista:cRACLVL)  	 //Classe Valor Proposto
			cTMPITEM   := ALLTRIM(oLista:cTMPITEM)   //Item Contabil Atual
			cRAITEM    := ALLTRIM(oLista:cRAITEM)    //Item Contábil Proposto
			cTMPOBSINC := ALLTRIM(oLista:cTMPOBSINC)    //Observação feita na inclusão
			cTMPMETIRO := ALLTRIM(oLista:cTMPMETIRO)    //Observação feita na inclusão
			If AllTrim(cTMPMETIRO) == '1' .Or. AllTrim(cTMPMETIRO) == 'Sim'
				cTMPMETIRO := "Sim"
			Else
				cTMPMETIRO := "Não"
			EndIf
		EndIf
		If oParam:BuscObser(cFilRh3, cCodigo)
			oLista2 :=  oParam:oWSBuscObserRESULT
		EndIf
		cHtml := ExecInPage("F0500311")//CARGOS E SALARIOS
		
	Case cTipo = '007'
		//Ajustando solicitação
		oParam    := WSW0200301():new()
		WsChgURL(@oParam,"W0200301.APW")
		cSolic    := cCodigo
		cMat      := cMatric
		lBtAprova := .F.
		lRet := .T.

		fGetInfRotina("U_F0200301.APW")
		GetMat()								//Pega a Matricula e a filial do participante logado
	
		oOrg := WSORGSTRUCTURE():New()
		WsChgURL(@oOrg,"ORGSTRUCTURE.APW",,,HttpGet->EmployeeEmp)
		
		If Empty(HttpGet->EmployeeFilial) .And. Empty(HttpGet->Registration)
			oOrg:cParticipantID 	    := HttpSession->cParticipantID
		
			If ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat)
				oOrg:cRegistration	 := HttpSession->RHMat
			EndIf
		Else
			oOrg:cEmployeeFil  	    := HttpGet->EmployeeFilial
			oOrg:cRegistration 	    := HttpGet->Registration
		EndIf
	
		oOrg:cKeyVision   :=  Alltrim(HttpGet->cKeyVision)
	
		oOrg:cVision      := HttpSession->aInfRotina:cVisao
		oOrg:cFilterValue := HttpGet->FilterValue
		oOrg:cFilterField := HttpGet->FilterField
		oOrg:cRequestType := ""
	
		IF oOrg:GetStructure()
			HttpSession->aStructure  := aClone(oOrg:oWSGetStructureResult:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE)
			nPageTotal 		       := oOrg:oWSGetStructureResult:nPagesTotal
		Else
			HttpSession->aStructure := {}
			nPageTotal 		      := 1
		EndIf
	
		If oParam:RetInvFu(cCodMat,CFILIALS)
			cMatricu1  := oParam:oWSRetInvFuRESULT:cMatricula
			cNome1     := oParam:oWSRetInvFuRESULT:cNome
			cAdmissao1 := oParam:oWSRetInvFuRESULT:cAdmissao
			cDepartam1 := oParam:oWSRetInvFuRESULT:cDepartame
			cSituacao1 := ""
			cCenCusto1 := oParam:oWSRetInvFuRESULT:cCenCusto
			cCargo1    := oParam:oWSRetInvFuRESULT:cCargo
			cFilial1   := CFILIALS
			cNmCarg1   := oParam:oWSRetInvFuRESULT:cNMCARGO
			cNmCeCu1   := oParam:oWSRetInvFuRESULT:cNMCENTRO
			cNmDepa1   := oParam:oWSRetInvFuRESULT:cNMDEPART
			Superior1  := cMat
		Else
			cMatricu1  := ''
			cNome1     := ''
			cAdmissao1 := ''
			cDepartam1 := ''
			cSituacao1 := ''
			cCenCusto1 := ''
			cCargo1    := ''
			cFilial1   := ''
			cNmCarg1   := ''
			cNmCeCu1   := ''
			cNmDepa1   := ''
			Superior1  := ''
		EndIf
		If oInf:InfRh4I(cSolic,cFilRh3)
			cCod  := oInf:cINFRH4IRESULT
		EndIf
		
		If oParam:InfPa3(cCod," ")
			ccurseName         := oParam:oWSINFPA3RESULT:ccurseName
			cinstituteName     := oParam:oWSINFPA3RESULT:cinstituteName
			ccontact           := oParam:oWSINFPA3RESULT:ccontact
			cphone             := oParam:oWSINFPA3RESULT:cphone
			cramal             := oParam:oWSINFPA3RESULT:cramal
			cstartDate         := oParam:oWSINFPA3RESULT:cstartDate
			cendDate           := oParam:oWSINFPA3RESULT:cendDate
			cmonthlyPayment    := oParam:oWSINFPA3RESULT:cmonthlyPayment
			cinstallmentAmount := oParam:oWSINFPA3RESULT:cinstallmentAmount
			cbenefconcedido    := oParam:oWSINFPA3RESULT:cbenefconcedido
			cvltotcurso        := oParam:oWSINFPA3RESULT:cvltotcurso
			cvlinvesanovig     := oParam:oWSINFPA3RESULT:cvlinvesanovig
			cduracao           := oParam:oWSINFPA3RESULT:cduracao
			cTipo              := oParam:oWSINFPA3RESULT:cTipo
			cObservacao        := oParam:oWSINFPA3RESULT:cobservation
		EndIf
		
		oParam := WSW0500307():new()
		WsChgURL(@oParam,"W0500307.APW")
		
		If oParam:BuscObser(cFilRh3, cCodigo)
			oLista2 :=  oParam:oWSBuscObserRESULT
		EndIf
		
		cHtml := ExecInPage("F0200304")//Incentivo academico
	Case cTipo = '008'
		lRet := .T.
		
		HttpGet->nOperacao := '3'
		nIndice := 1
		HttpGet->nIndice := '1'
		HttpGet->nIndiceSolic := '1'
		GetMat()
		oInfLog    := WSW0200301():new()
		WsChgURL(@oInfLog,"W0200301.APW")
		
		If oInfLog:RetInvFu(cCodMat,CFILIALS)
			cMatricu1  := oInfLog:oWSRetInvFuRESULT:cMatricula
			cNome1     := oInfLog:oWSRetInvFuRESULT:cNome
			cAdmissao1 := oInfLog:oWSRetInvFuRESULT:cAdmissao
			cDepartam1 := oInfLog:oWSRetInvFuRESULT:cDepartame
			cCenCusto1 := oInfLog:oWSRetInvFuRESULT:cCenCusto
			cCargo1    := oInfLog:oWSRetInvFuRESULT:cCargo
			cNmCeCu1   := oInfLog:oWSRetInvFuRESULT:cNMCENTRO
			cNmCarg1   := oInfLog:oWSRetInvFuRESULT:cNMCARGO
			cNmDepa1   := oInfLog:oWSRetInvFuRESULT:cNMDEPART
			cNomeFil1	:= oInfLog:oWSRetInvFuRESULT:cNomeFil			
		EndIf
		
		oParam := WSW0500307():new()
		WsChgURL(@oParam,"W0500307.APW")
		
		If oParam:InfRh4Fe(cCodigo,cFilRh3)
			oLista :=  oParam:oWSINFRH4FERESULT
			cFili                       := ALLTRIM(oLista:CR8FILIAL)
			cCodVg                      := ALLTRIM(oLista:CR8MAT)
			cNomVg                      := ALLTRIM(oLista:CTMPNOME)
			cInitialDate                := ALLTRIM(oLista:CR8DATAINI)
			cFinalDate                  := ALLTRIM(oLista:CR8DATAFIM)
			cDays                       := ALLTRIM(oLista:CR8DURACAO)
			cPecuniaryAllowance         := ALLTRIM(oLista:CTMPABONO)
			cThirteenthSalary1stInstall := ALLTRIM(oLista:CTMP1P13SL)
			cObservacao                 := oLista:CObs 
		Else
			cFili                       := ''
			cCodVg                      := ''
			cNomVg                      := ''
			cInitialDate                := ''
			cFinalDate                  := ''
			cDays                       := ''
			cPecuniaryAllowance         := ''
			cThirteenthSalary1stInstall := ''
			cObservacao                 := ''
		EndIf
		
		//Busca ferias programadas do funcionario
		oWSFerProg := WsRHVACATION():New()
		WsChgURL(@oWSFerProg, "RHVACATION.apw" ,,,GetEmpFun())
	
		HTTPGet->nDiasAbo	:= 0
		HTTPGet->nDiasProg	:= 0
		
		//Busca Dados montagem da solicitacao
		oObj := WSRHVacation():New()
		WsChgURL(@oObj,"RHVACATION.APW",,,GetEmpFun())
		
		oFerObj := WSW0801101():new()
		WsChgURL(@oFerObj, "W0801101.APW")
		
		oFerObj:cEmployeeFil  := CFILIALS
		oFerObj:cRegistration := cCodMat
		If (nIndice > 0)
			oFerObj:cEmployeeFil	 := oObj:cEmployeeFil
			oFerObj:cRegistration := oObj:cRegistration
			If oWSFerProg:GetVacProgEffect()
				aFerProg 			:= oWSFerProg:oWSGETVACPROGEFFECTRESULT:oWSListOfVacProgEffect:oWSDataVacProgEffect
				HTTPGet->aFerProg 	:= oWSFerProg:oWSGETVACPROGEFFECTRESULT:oWSListOfVacProgEffect:oWSDataVacProgEffect
	
				For nReg := 1 to Len(aFerProg)
					HTTPGet->nDiasAbo  +=	aFerProg[nReg]:nAllowDays
					HTTPGet->nDiasProg +=	aFerProg[nReg]:nVacationDays
				Next nReg
			EndIf
		EndIf
		
		HttpGet->aPeriodos := {}
		
		If oFerObj:GetPeriodAbert()
			If EMPTY(oFerObj:oWSGetPeriodAbertResult:oWSListOfPeriod:oWSPerdVacationProg) .OR. Len(oFerObj:oWSGetPeriodAbertResult:oWSListOfPeriod:oWSPerdVacationProg) < 2
				HttpGet->aPeriodos := oFerObj:oWSGetPeriodAbertResult:oWSListOfPeriod:oWSPerdVacationProg
			Else
				HttpGet->aPeriodos := aSize( oFerObj:oWSGetPeriodAbertResult:oWSListOfPeriod:oWSPerdVacationProg, 2 )
			EndIf
		Else
			HttpGet->aPeriodos := {}
		EndIf
		If oObj:GetTypeCalcDay()
			HttpSession->cTipoCalcDia := oObj:cGetTypeCalcDayResult
		EndIf
		
		oParam := WSW0500307():new()
		WsChgURL(@oParam,"W0500307.APW")
		
		If oParam:BuscObser(cFilRh3, cCodigo)
			oLista2 :=  oParam:oWSBuscObserRESULT
		EndIf
	
		HttpCTType("text/html; charset=ISO-8859-1")
		cHtml := ExecInPage( "F0801104" )
	EndCase
	
	WEB EXTENDED END
	
Return cHtml
