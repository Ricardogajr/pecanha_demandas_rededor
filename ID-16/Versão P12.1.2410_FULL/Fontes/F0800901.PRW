#Include 'Protheus.ch'

#DEFINE  ENTER Chr(13)+Chr(10)

/*{Protheus.doc} F0800901
Função de envio de e-mail
@author   Fernando Carvalho
@since    20/03/2017
@param    cTpOper, characters, descricao
@param    cEmail, characters, descricao
@param    cFilSol, characters, descricao
@param    cNumSol, characters, descricao
@param    cNomeSol, characters, descricao
@param    cTpSol, characters, descricao
@param    cSubGrupo, characters, descricao
@param    cNvAprv, characters, descricao
@param    cObsLog, characters, descricao
@version  P12.1.7
@project  MAN0000007423042_EF_009
*/
User Function F0800901(cTpOper,cEmail,cFilSol,cNumSol,cNomeSol,cTpSol,cSubGrupo,cNvAprv,cObsLog)
	
	Local aAreaPAC  := PAC->(GetArea())
	Local lRet      := .T.	
	Local cAssunto  := ""	
	Local cMsg      := ""
	Local aAux      := {}	
	Local aAreaSRA  := SRA->(GetArea())
	
	Private cBody   := ""
	
	Default cFilSol := ""
	Default cNumSol := ""
	
	cBody := '<html><body><pre>' + ENTER
	
	If cTpOper == "1" .OR. cTpOper == "3" //Inclusão ou Aprovação
		cCodPab := POSICIONE("PAB",2,XFILIAL("PAB") + cTpSol + cSubGrupo,"PAB_CODIGO")
		cAprNot := POSICIONE("PAC",1,XFILIAL("PAC") + cCodPab + cNvAprv ,"PAC_APRNOT") //1=Aprovador;2=Notificado
	
		aAux := RetApr(cAprNot, cTpSol, cSubGrupo)
	EndIf
	
	If cTpOper $ "2"//Cancelamento
		aAux := RetCnc(cTpSol, cSubGrupo)
	EndIf
	
	If cTpOper $ "4"//Rejeição
		aAux := RetRpr(cTpSol, cSubGrupo)
	EndIf
	
	If cTpOper $ "5"//Efetivação
		aAux := RetEfe(cTpSol, cSubGrupo)
	EndIf
	
	If Len(aAux) > 0
		cAssunto := aAux[1]
	EndIf
	
	RetEmail(cTpSol,cSubGrupo,cFilSol,cNumSol,cNomeSol,cObsLog)
	
	lRet := U_F0200304(cAssunto, cBody, cEmail) //Rotina de Envio de E-mail
	
	If !lRet
		Aviso("INSUCESSO - Email","E-mail NÃO enviado. Comunique aos envolvidos!" ,,1,,,,,3000,)
	//	Aviso("INSUCESSO - Email","E-mail NÃO enviado. Comunique aos envolvidos!" ,{'OK'},1)
	Endif
	
	RestArea(aAreaSRA)
	RestArea(aAreaPAC)
Return lRet

/*{Protheus.doc} RetEmail

@author    Henrique Madureira
@since     31/05/2017
@param     cBody, characters, descricao
@param     cTpSol, characters, descricao
@param     cSubGrupo, characters, descricao
@param     cFilSol, characters, descricao
@param     cNumSol, characters, descricao
@param     cNomeSol, characters, descricao
@param     cObsLog, characters, descricao
@version   P12.1.7
@project   MAN0000007423042_EF_009
*/
Static Function RetEmail(cTpSol,cSubGrupo,cFilSol,cNumSol,cNomeSol,cObsLog)
	
	Local cDecTpSol := ""
	Local cDsSubGrp := ""
	Local cFilIni   := ""
	Local cCodSol   := ""
	Local cFilSltd  := ""
	Local cCodSltd  := ""
	Local cNomeSltd := ""
	Local cTpFap    := ""
	Local lVal      := .F.
	Local aAreas    := {SRA->(GetArea()),RH3->(GetArea()),PA7->(GetArea()),GetArea()}
	
	PA7->(DbSetOrder(1))
	PA7->(DbSeek(XFILIAL("PA7") + cTpSol + cSubGrupo))
	
	cDecTpSol := PA7->PA7_DESCR
	cDsSubGrp := PA7->PA7_DESSUB
	
	RH3->(DbSetOrder(1))
	RH3->(DbSeek(cFilSol + cNumSol))
	
	cFilIni   := RH3->RH3_FILINI
	cCodSol   := RH3->RH3_MATINI
	cFilSltd  := RH3->RH3_FILIAL
	cCodSltd  := RH3->RH3_MAT
	
	cNomeSltd := POSICIONE("SRA",1,cFilSltd + cCodSltd,"RA_NOME" )
	
	If cTpSol $ "004" 
		cTpFap := POSICIONE("RH4", 1, cFilSol + cNumSol + '  6', "RH4_VALNOV")
		If ALLTRIM(cTpFap) $ "EXTERNO"
			cNomeSltd := POSICIONE("RH4", 1, cFilSol + cNumSol + ' 19', "RH4_VALNOV")
		Else
			cFilSltd  := ALLTRIM(POSICIONE("RH4", 1, cFilSol + cNumSol + ' 22', "RH4_VALNOV"))
			cCodSltd  := ALLTRIM(POSICIONE("RH4", 1, cFilSol + cNumSol + ' 24', "RH4_VALNOV"))
			cNomeSltd := ALLTRIM(POSICIONE("RH4", 1, cFilSol + cNumSol + ' 25', "RH4_VALNOV"))
		EndIf
	EndIf
	
	If cTpSol $ "002/003" 
		lVal := .T.
	EndIf
	
	cBody	+= ENTER
	cBody	+= "<hr>"
	cBody	+= ENTER
	cBody	+= "Segue dados da solicitação:" + ENTER
	cBody	+= "Solicitação:               " + cFilSol   + " - " + cNumSol   + ENTER
	cBody	+= "Filial:                    " + cFilIni   + "/" + FWFilialName(,cFilIni,2)  + ENTER
	cBody	+= "Solicitante:               " + cCodSol   + "/" + cNomeSol  + ENTER
	If !lVal .AND. EMPTY(cTpFap)
		cBody	+= "Filial:                    " + cFilSltd  + "/" + FWFilialName(,cFilSltd,2)    + ENTER
		cBody	+= "Solicitado:                " + cCodSltd  + "/" + cNomeSltd + ENTER
	EndIf
	If !(EMPTY(cTpFap))
		If cTpFap $ "INTERNO"
			cBody	+= "Filial:                    " + cFilSltd  + "/" + FWFilialName(,cFilSltd,2)    + ENTER
		EndIf
		cBody	+= "Solicitado:                " + cCodSltd  + "/" + cNomeSltd + ENTER
	EndIf
	cBody	+= "Tipo Solicitação:          " + cTpSol    + "/" + cDecTpSol + ENTER
	cBody	+= "SubGrupo:                  " + cSubGrupo + "/" + cDsSubGrp + ENTER
	cBody	+= "Observação:                " + cObsLog   + ENTER
	
	cBody += '</pre></body></html>'
	
	AEval(aAreas, {|x| RestArea(x)} )
	
Return cBody

/*{Protheus.doc} RetCnc
Monta cabeçalho do e-mail
@author    Henrique Madureira
@since     31/05/2017
@param     cAprNot, characters, descricao
@param     cTpOper, characters, descricao
@param     cSubGrupo, characters, descricao
@version   P12.1.7
@project   MAN0000007423042_EF_009
*/
Static Function RetCnc(cTpSol, cSubGrupo)
	
	Local cAssunto := ""
	
	If cTpSol == "001"		//TREINAMENTO/EVENTO
		cAssunto := "Cancelamento treinamento/evento"
	Elseif cTpSol == "002"	//VAGA
		cAssunto := "Cancelamento da Vaga"
	Elseif cTpSol == "003"	//Aumento de quadro/Orçamento
		cAssunto := "Cancelamento do Aumento de Quadro"
	Elseif cTpSol == "004" 	//FAP	
		cAssunto := "Cancelamento da FAP"
	Elseif cTpSol == "005" 	//DESLIGAMENTO
		cAssunto := "Cancelamento do Desligamento"
	Elseif cTpSol == "006" 		//CARGOS E SALARIOS
		cAssunto := "Cancelamento de Movimentação de Pessoal"	
	Elseif cTpSol == "007" //INCENTIVO ACADEMICO
		cAssunto := "Cancelamento de Incentivo Acadêmico"	
	Else
		cAssunto := "Cancelamento de Férias"
	EndIf	
	
	cBody += "Solicitação cancelada devido inconsistencia na alçada"
	
Return {cAssunto, cBody}

/*{Protheus.doc} RetApr
Monta cabeçalho do e-mail
@author    Henrique Madureira
@since     31/05/2017
@param     cAprNot, characters, descricao
@param     cTpOper, characters, descricao
@param     cSubGrupo, characters, descricao
@version   P12.1.7
@project   MAN0000007423042_EF_009
*/
Static Function RetApr(cAprNot, cTpSol, cSubGrupo)
	
	Local cAssunto := ""
	
	If cTpSol == "001"		//TREINAMENTO/EVENTO
		cAssunto := "Aprovação treinamento/evento"
	Elseif cTpSol == "002"	//VAGA
		cAssunto := "Aprovação da Vaga"
	Elseif cTpSol == "003"	//Aumento de quadro/Orçamento
		cAssunto := "Aprovação do Aumento de Quadro"
	Elseif cTpSol == "004" 	//FAP	
		cAssunto := "Aprovação da FAP"
	Elseif cTpSol == "005" 	//DESLIGAMENTO
		cAssunto := "Aprovação do Desligamento"
	Elseif cTpSol == "006" 		//CARGOS E SALARIOS
		cAssunto := "Aprovação de Movimentação de Pessoal"	
	Elseif cTpSol == "007" //INCENTIVO ACADEMICO
		cAssunto := "Aprovação de Incentivo Acadêmico"	
	Else
		cAssunto := "Aprovação de Férias"
	EndIf	
		
	If cAprNot == "1"
		cBody += POSICIONE("PAF",4, XFILIAL("PAF") + cTpSol + cSubGrupo, "PAF_TXTAPR") + ENTER
	Else
		cBody += POSICIONE("PAF",4, XFILIAL("PAF") + cTpSol + cSubGrupo, "PAF_TXTNAP") + ENTER
	EndIf
	
Return {cAssunto, cBody}

/*{Protheus.doc} RetEfe
Monta cabeçalho do e-mail
@author    Henrique Madureira
@since     31/05/2017
@param     cAprNot, characters, descricao
@param     cTpOper, characters, descricao
@param     cSubGrupo, characters, descricao
@version   P12.1.7
@project   MAN0000007423042_EF_009
*/
Static Function RetEfe(cTpSol, cSubGrupo)
	
	Local cAssunto := ""
	
	If cTpSol == "001"		//TREINAMENTO/EVENTO
		cAssunto := "Efetivação treinamento/evento"
	Elseif cTpSol == "002"	//VAGA
		cAssunto := "Efetivação da Vaga"
	Elseif cTpSol == "003"	//Aumento de quadro/Orçamento
		cAssunto := "Efetivação do Aumento de Quadro"
	Elseif cTpSol == "004" 	//FAP	
		cAssunto := "Efetivação da FAP"
	Elseif cTpSol == "005" 	//DESLIGAMENTO
		cAssunto := "Efetivação do Desligamento"
	Elseif cTpSol == "006" 		//CARGOS E SALARIOS
		cAssunto := "Efetivação de Movimentação de Pessoal"	
	Elseif cTpSol == "007" //INCENTIVO ACADEMICO
		cAssunto := "Efetivação de Incentivo Acadêmico"	
	ElseIf cTpSol == "008"
		cAssunto := "Efetivação de Férias"
	EndIf	
		
	cBody += POSICIONE("PAF",4, XFILIAL("PAF") + cTpSol + cSubGrupo, "PAF_TXTEFE") + ENTER
	
Return {cAssunto, cBody}

/*{Protheus.doc} RetRpr
Monta cabeçalho do e-mail
@author    Henrique Madureira
@since     31/05/2017
@param     cAprNot, characters, descricao
@param     cTpOper, characters, descricao
@param     cSubGrupo, characters, descricao
@version   P12.1.7
@project   MAN0000007423042_EF_009
*/
Static Function RetRpr(cTpSol, cSubGrupo)
	
	Local cAssunto := ""
	
	If cTpSol == "001"		//TREINAMENTO/EVENTO
		cAssunto := "Rejeição treinamento/evento"
	Elseif cTpSol == "002"	//VAGA
		cAssunto := "Rejeição da Vaga"
	Elseif cTpSol == "003"	//Aumento de quadro/Orçamento
		cAssunto := "Rejeição do Aumento de Quadro"
	Elseif cTpSol == "004" 	//FAP	
		cAssunto := "Rejeição da FAP"
	Elseif cTpSol == "005" 	//DESLIGAMENTO
		cAssunto := "Rejeição do Desligamento"
	Elseif cTpSol == "006" 		//CARGOS E SALARIOS
		cAssunto := "Rejeição de Movimentação de Pessoal"	
	Elseif cTpSol == "007" //INCENTIVO ACADEMICO
		cAssunto := "Rejeição de Incentivo Acadêmico"
	Else
		cAssunto := "Rejeição de Férias"
	EndIf	

	cBody += POSICIONE("PAF",4, XFILIAL("PAF") + cTpSol + cSubGrupo, "PAF_TXTREP") + ENTER

Return {cAssunto, cBody}