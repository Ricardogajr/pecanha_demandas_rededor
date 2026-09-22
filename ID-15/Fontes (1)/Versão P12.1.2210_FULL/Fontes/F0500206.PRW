#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} F0500206
Função génerica para execução das funções dos processos
@author  Fernando Carvalho 
@since 11/11/2016
@version 12.7
@param cProcesso, character, (Processo executado)
@param oMdGrid, objeto, (Grid da rotina	 MVC)
@param oView, objeto, (View da rotina MVC)
@project 2015GGS0758_MAN00000060101_EF_001
/*/

//User Function F0500206( cProcesso , oMdGrid , oView        ) // gus
  User Function F0500206( cProcesso , oMdGrid , oView , nRec ) // gus
  
    default nRec := 0                       // gus
//  alert( 'nRec -> ' + str(nRec) + ' <-' ) // gus
    if nRec <> 0                            // gus
        ( 'PA2' )->( dbgoto( nRec ))        // gus
    endif                                   // gus

	If (cProcesso == "Encaminhamento")
		If !MsgYesNo("Deseja Realmente Confirmar 'Encaminhamento Célula de Cadastro'?")
			return
		EndIf			
		CelCad(oMdGrid)
		
	ElseIf (cProcesso == "DesDocsExame")
		If !MsgYesNo("Deseja Realmente Confirmar 'Candidato Desistente Docs. / Exame'?")
			return
		EndIf
		DesisDocEx(oMdGrid)
		
	ElseIf (cProcesso == "DocsInconsist")
		If !MsgYesNo("Deseja Realmente Confirmar 'Candidato Doc. Inconsistente'?")
			return
		EndIf		
		DocIncon()
	
	ElseIf (cProcesso == "Inapto")
		If !MsgYesNo("Deseja Realmente Confirmar 'Candidato Inapto Exame'?")
			return
		EndIf		
		Inapto()
			
	ElseIf (cProcesso == "AssinaturaContra")
		If !MsgYesNo("Deseja Realmente Confirmar 'Assinatura de Contrato'?")
			return
		EndIf		
		AssContra()
			
	ElseIf (cProcesso == "DesistContrato")
		If !MsgYesNo("Deseja Realmente Confirmar 'Candidato Desistente Contrato'?")
			return
		EndIf
		DesisContra()
		
	ElseIf (cProcesso == "VagaSuspensa")
		If !MsgYesNo("Deseja Realmente Confirmar 'Vaga Suspensa'?")
			return
		EndIf
		VagaSus()
		
	ElseIf (cProcesso == "VagaCancelada")
		If !MsgYesNo("Deseja Realmente Confirmar 'Vaga Cancelada'?")
			return
		EndIf
		VagaCan()
		
	ElseIf (cProcesso == "VagaReaberta")
		If !MsgYesNo("Deseja Realmente Confirmar 'Vaga Reaberta'?")
			return
		EndIf
		VagaReab()
		
	Endif
Return .T.

/*/{Protheus.doc} F0500206
Enc. Célula de Cadastro
@author  queizy.nascimento 
@since 17/11/2016
@version 12.7
@project 2015GGS0758_MAN00000060101_EF_001
/*/
Static Function CelCad()
	Local aArea	:= GetArea()
	Local lRet		:= .F. 
	
	cFILsQG := U_F0600402( PA2->PA2_FILIAL, "SQS")
	DbSelectArea("SQS")
	SQS->(DbSetOrder(1))
	If SQS->(DbSeek(cFILsQG + PA2->PA2_CDVAGA))
		RecLock("SQS",.F.)
		SQS->QS_XMOTIVO := "Em cadastro"	
		SQS->QS_XSTATUS := '4' // Em Cadastro		'		
		SQS->(MsUnLock())
		
		U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"4")	//Status da Vaga na FAP
		
		U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "022")
		U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "013")
		
		U_F0500201(PA2->PA2_FILSOL, PA2->PA2_SOL, "022")
		U_F0500201(PA2->PA2_FILSOL, PA2->PA2_SOL, "013") 
	EndIf

	RestArea(aArea)
	Sair()
Return


/*/{Protheus.doc} F0500206
Candidato Desistente Docs./Exame
@author  queizy.nascimento 
@since 17/11/2016
@version 12.7
@project 2015GGS0758_MAN00000060101_EF_001
/*/
Static Function DesisDocEx()
	Local lRet 	:= .F.
	cFILsQG := U_F0600402( PA2->PA2_FILIAL, "SQS")
	DbSelectArea("SQS")
	SQS->(DbSetOrder(1))
	If SQS->(DbSeek(cFILsQG + PA2->PA2_CDVAGA))
		RecLock("SQS",.F.)
		SQS->QS_XMOTIVO := "Desistente Docs./Exame"	
		SQS->QS_XSTATUS := '2' // Em Recrutamento		'		
		SQS->(MsUnLock())

		U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"2")	//Status da Vaga na FAP
		
		U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "015")
		U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "011")
		U_F0802001(cFILsQG,PA2->PA2_CDVAGA) // ticket n° 5892521 - 415966 - Paulo Dias - Chamada função para decremento na contagem da vaga
	EndIf
	
	U_ReprovaPA2("015")
	Sair()
Return


/*/{Protheus.doc} F0500206
Candidato Doc. Inconsistente'
@author  queizy.nascimento 
@since 17/11/2016
@version 12.7
@project 2015GGS0758_MAN00000060101_EF_001
/*/
Static Function DocIncon()
	Local lRet		:= .F.
	Local cFILsQG 	:= ""
	cFILsQG := U_F0600402( PA2->PA2_FILIAL, "SQS")
	DbSelectArea("SQS")
	SQS->(DbSetOrder(1))
	If SQS->(DbSeek(cFILsQG + PA2->PA2_CDVAGA))
		RecLock("SQS",.F.)
		SQS->QS_XMOTIVO := "Documento Suspenso"	
		SQS->QS_XSTATUS := '8' 	
		SQS->(MsUnLock())
		
		U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"8")	//Status da Vaga na FAP
		
		U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "016")
		U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "019")

		U_F0500201(PA2->PA2_FILSOL, PA2->PA2_SOL, "016")
		U_F0500201(PA2->PA2_FILSOL, PA2->PA2_SOL, "019") 
		U_F0802001(cFILsQG,PA2->PA2_CDVAGA) // ticket n° 5892521 - 415966 - Paulo Dias - Chamada função para decremento na contagem da vaga
	EndIf
//	U_ReprovaPA2()
	Sair()
Return

/*/{Protheus.doc} F0500206
Candidato Inapto Exame
@author  queizy.nascimento 
@since 17/11/2016
@version 12.7
@project 2015GGS0758_MAN00000060101_EF_001
/*/
Static Function Inapto()
	Local lRet		:= .F.
	Local cFILsQG 	:= ""

	cFILsQG := U_F0600402( PA2->PA2_FILIAL, "SQS")
	DbSelectArea("SQS")
	SQS->(DbSetOrder(1))
	If SQS->(DbSeek(cFILsQG + PA2->PA2_CDVAGA))
		RecLock("SQS",.F.)
		SQS->QS_XMOTIVO := "Inapto Exame"	
		SQS->QS_XSTATUS := '2' // Em Recrutamento		'		
		SQS->(MsUnLock())
		
		U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"2")	//Status da Vaga na FAP
		
		U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "017")
		U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "011")
		U_F0802001(cFILsQG,PA2->PA2_CDVAGA) // ticket n° 5892521 - 415966 - Paulo Dias - Chamada função para decremento na contagem da vaga
	EndIf	
	U_ReprovaPA2("017")
	Sair()
	
Return


/*/{Protheus.doc} F0500206
Assinatura de Contrato
@author  queizy.nascimento 
@since 17/11/2016
@version 12.7
@project 2015GGS0758_MAN00000060101_EF_001
/*/
Static Function AssContra()
	Local lRet 	:= .F. 
	Local aAreaSRA	:= SRA->(GetArea())
	Local aAreaRH3	:= RH3->(GetArea())
	Local aAreaSQG	:= SQG->(GetArea())	

	RH3->(dbSetOrder(1))
	RH3->(DbSeek(PA2->PA2_FILIAL + PA2->PA2_SOL))	

	SQG->(DbSetOrder(1))
	SQG->(DbSeek(xFilial("SQG")+PA2->PA2_CDCAND))
	
	SRA->(dbSetOrder(5))
	SRA->(DbSeek(PA2->PA2_FILIAL + SQG->QG_CIC))	
	
	// Jamer Nuns Pedroso - 20/05/2017
	cFILsQG := U_F0600402( PA2->PA2_FILIAL, "SQS")
	DbSelectArea("SQS")
	SQS->(DbSetOrder(1))
	If SQS->(DbSeek(cFILsQG + PA2->PA2_CDVAGA))
		RecLock("SQS",.F.)
		SQS->QS_XMOTIVO := "Assinatura de contrato"	
		SQS->QS_XSTATUS := '7' // Assinatura de contrato'		
		SQS->(MsUnLock())
		
		U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"7")	//Status da Vaga na FAP
		U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "014")
		U_F0500201(PA2->PA2_FILSOL, PA2->PA2_SOL, "014")
		
	EndIf
	Reclock("PA2",.F.)
		PA2->PA2_SIT := "CL"
	PA2->(MsUnLock())	
	RestArea(aAreaSRA)
	RestArea(aAreaRH3)
	RestArea(aAreaSQG)
	Sair()
Return


/*/{Protheus.doc} F0500206
Candidato Desistente Contrato
@author  queizy.nascimento 
@since 17/11/2016
@version 12.7
@project 2015GGS0758_MAN00000060101_EF_001
/*/
Static Function DesisContra()
	Local lRet		:= .F.
	cFILsQG := U_F0600402( PA2->PA2_FILIAL, "SQS")
	DbSelectArea("SQS")
	SQS->(DbSetOrder(1))
	If SQS->(DbSeek(cFILsQG + PA2->PA2_CDVAGA))
		RecLock("SQS",.F.)
		SQS->QS_XMOTIVO := "Desistente Contrato"	
		SQS->QS_XSTATUS := '2' // Em Recrutamento		'		
		SQS->(MsUnLock())
		
		U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"2")	//Status da Vaga na FAP
	
		U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "018")
		U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "011")
	EndIf	
	RepRh3(PA2->PA2_FILSOL, PA2->PA2_SOL)
	
	If !U_F0802001(cFILsQG,PA2->PA2_CDVAGA)
		Aviso("Erro","Não foi possível atualizar a vaga. Comunique aos envolvidos!" ,{'OK'},1)
	//Else
	//	U_F0802001(cFILsQG,PA2->PA2_CDVAGA) // ticket n° 5892521 - 415966 - Paulo Dias - Linha comentada -- função para decremento na contagem da vaga	
	EndIf
	
	If !U_F0802002(PA2->PA2_FILIAL, PA2->PA2_CDCAND)
		Aviso("Erro","Não foi possível desocupar o participante do posto. Comunique aos envolvidos!" ,{'OK'},1)		
	Endif
	U_ReprovaPA2("018")
	Sair()
Return


/*/{Protheus.doc} F0500206
Vaga Suspensa
@author  Fernando Carvalho 
@since 14/11/2016
@version 12.7
@project 2015GGS0758_MAN00000060101_EF_001
/*/
Static Function VagaSus()	//-Descontinuada em 17/03/2017 pois funcao mudou pro Pto.Entrada RSP100ME()
	Local lMotivo		:= .F.
	Local aMotivo		:= ""
	Local cStatus		:= "Vaga Suspensa"
	Local aArea		:= GetArea()
	Local lRet			:= .F.
	cFILsQG := U_F0600402( PA2->PA2_FILIAL, "SQS")
	DbSelectArea("SQS")
	SQS->(DbSetOrder(1))
	If SQS->(DbSeek(cFILsQG + PA2->PA2_CDVAGA))
		If Empty(SQS->QS_XSUSPEN)
			While !lMotivo
				aMotivo := U_Motivo()
				lMotivo := aMotivo[1]
				cMotivo := aMotivo[2]
				If !lMotivo .and. !Empty(aMotivo[2])
					lMotivo := .T.
				Elseif !lMotivo .and. Empty(aMotivo[2])
					Alert("É obrigatório o preenchimento de uma justificativa para alteração do Status!")	
				EndIf	
			EndDo
			If lMotivo .AND. !Empty(aMotivo[2]) .AND. !aMotivo[1] 
				RecLock("SQS",.F.)
					SQS->QS_XMOTIVO := cMotivo	
					SQS->QS_XSUSPEN := SQS->QS_XSTATUS		
					SQS->QS_XSTATUS := '6'		
				SQS->(MsUnLock())
				U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"6")	//Status da Vaga na FAP
				U_F0500201(SQS->QS_XSOLFIL,SQS->QS_XSOLPTL,"009")	
				U_EnviaEmail(cStatus)
			EndIf	
		Else
			Alert("Vaga já se encontra 'Suspensa'!")
		EndIf
	Else	
		Alert("Vaga não encontra!")
	EndIf	

	U_ReprovaPA2("009")
	RestArea(aArea)
	Sair()
Return	


/*/{Protheus.doc} F0500206
Vaga Cancelada
@author  Fernando Carvalho 
@since 14/11/2016
@version 12.7
@project 2015GGS0758_MAN00000060101_EF_001
/*/
Static Function VagaCan() //-Descontinuada em 17/03/2017 pois funcao mudou pro Pto.Entrada RSP100ME()
	Local lMotivo		:= .F.
	Local cMotivo		:= ""
	Local cStatus		:= "Vaga Cancelada"
	Local aArea		:= GetArea()
	cFILsQG := U_F0600402( PA2->PA2_FILIAL, "SQS")
	DbSelectArea("SQS")
	SQS->(DbSetOrder(1))
	If SQS->(DbSeek(cFILsQG + PA2->PA2_CDVAGA))
		While !lMotivo
			aMotivo := U_Motivo()
			lMotivo := aMotivo[1]
			cMotivo := aMotivo[2]
			If !lMotivo .and. !Empty(aMotivo[2])
				lMotivo := .T.
			Elseif !lMotivo .and. Empty(aMotivo[2])
				Alert("É obrigatório o preenchimento de uma justificativa para alteração do Status!")	
			EndIf	
		EndDo
		If lMotivo .AND. !Empty(aMotivo[2]).AND. !aMotivo[1]
			RecLock("SQS",.F.)
				SQS->QS_XMOTIVO := cMotivo	
				SQS->QS_XSTATUS := '5'
			SQS->(MsUnLock())
			U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"5")	//Status da Vaga na FAP
			U_F0500201(PA2->PA2_FILIAL,SQS->QS_XSOLPTL,"008")
			
			U_F0500201(PA2->PA2_FILIAL,PA2->PA2_SOL,"008")	
			U_EnviaEmail(cStatus)
			RepRh3(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL)
		EndIf	
	Else
		Alert("Vaga não encontrada!")
	EndIf

	U_ReprovaPA2("008")
	RestArea(aArea)	
	Sair()	
Return

/*/{Protheus.doc} Motivo
(Sem descricao)
@author  Fernando Carvalho 
@since 14/11/2016
@version 12.7
@project 2015GGS0758_MAN00000060101_EF_001
/*/
User Function Motivo()
	Local oDlg
	Local lOk		
	Local cTexto1 := ""	
	
 	DEFINE DIALOG oDlg TITLE "Motivo da Alteração" FROM 180, 180 TO 420, 700 PIXEL
 		TMultiGet():new( 01, 01, {| u | if( pCount() > 0, cTexto1 := u, cTexto1 ) },oDlg, 260, 92, , , , , , .T. )
  		TButton():New( 100, 080, "OK"		,oDlg,{||oDlg:End(),lOk := .T.}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
  		TButton():New( 100, 130, "Cancel"	,oDlg,{||oDlg:End(),lOk := .F.}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )   
  	ACTIVATE DIALOG oDlg CENTERED
return {lOk,cTexto1}

/*/{Protheus.doc} EnviaEmail
(Sem descricao)
@author  Fernando Carvalho 
@since 14/11/2016
@param cStatus, caracter,
@param cMotivo, caracter,
@version 12.7
@project 2015GGS0758_MAN00000060101_EF_001
/*/
User Function EnviaEmail(cStatus, cMotivo)	
	Local lTrue    := .T.
	Local cAssunto := cStatus
	Local cBody    := "A vaga referente ao número " + PA2->PA2_SOL + " teve mudança de Status." + CRLF + ;
					  "Novo Status: " + cStatus
	Local cEmail   := ""							
	Local lRet     := .F.
	Local cTypeOrg := ""

	Default cMovito := ""
	If !Empty(cMotivo)
		cBody += + CRLF + CRLF + "Motivo da Alteração: " + cMotivo
	EndIf
		
	dbSelectArea("RH3")
	RH3->(dbSetOrder(1))
	RH3->(DbSeek(PA2->PA2_FILIAL + PA2->PA2_SOL))	
	
	dbSelectArea("SRA")
	SRA->(dbSetOrder(1))
	SRA->(DbSeek(RH3->RH3_FILINI + RH3->RH3_MATINI))	
	
	cEmail 	:= SRA->RA_EMAIL		
	lRet	:= u_F0200304(cAssunto, cBody, cEmail) //Rotina de Envio de E-mail	
	
	While lTrue
	
		TipoOrg(@cTypeOrg, RH3->RH3_VISAO)
		aRet	:= fBuscaSuperior(SRA->RA_FILIAL,SRA->RA_MAT,SRA->RA_DEPTO,{},cTypeOrg,RH3->RH3_VISAO)
		If Len(aRet) > 0
			
			If !Empty(aRet[1,1]) .AND. !Empty(aRet[1,2])
				dbSelectArea("SRA")
				SRA->(dbSetOrder(1))			
				If SRA->(DbSeek(aRet[1,1] + aRet[1,2]))		
					cEmail 	:= SRA->RA_EMAIL		
					lRet	:= U_F0200304(cAssunto, cBody, cEmail) //Rotina de Envio de E-mail
				EndIf
			Else
				lTrue 	:= .F.
			EndIf
			
		Else
			lTrue 	:= .F.
		EndIf	
	EndDo
	
	If !lRet
		Aviso("INSUCESSO - Email","E-mail NÃO enviado. Comunique aos envolvidos!" ,{'OK'},1)
	Endif

Return 

/*/{Protheus.doc} ReprovaPA2
(Sem descricao)
@author  Fernando Carvalho 
@since 14/11/2016
@version 12.7
@project 2015GGS0758_MAN00000060101_EF_001
/*/
User Function ReprovaPA2(cCodInd)
	Local lRet	:= .T.
	Local aArea	:= GetArea()
	
	Default cCodInd	:= "004"
	Reclock("PA2",.f.)
		PA2->PA2_SIT := "RE"
	PA2->(MsUnLock())
	
	DbSelectARea("SQG")
	SQG->(dbSetOrder(1))
	If SQG->(DbSeek(PA2->PA2_FILCAN + PA2->PA2_CDCAND))
		Reclock("SQG",.f.)
		SQG->QG_XFILFAP := ""
		SQG->QG_XCODFAP := ""		
		SQG->(MsUnLock())
	EndIf		
	U_F0500201(PA2->PA2_FILIAL, PA2->PA2_SOL, cCodInd)
	RestArea(aArea)
Return lRet

Static Function RepRh3(cFilRh3, cCodRh3)

	Local lRet    := .T.
	Local cQuery  := ""

	RH3->(DbSetOrder(1))
	If RH3->(DbSeek(cFilRh3 + cCodRh3))
		Reclock("RH3", .F.)
		RH3->RH3_STATUS := '3'
		RH3->(MsUnlock())
	EndIf

Return

Static Function Sair()
	Local oView := FwViewActive()
	Aviso('SUCESSO',"Processo efetuado com sucesso. ",{'OK'},1)
	oView:ButtonCancelAction()	//Necessário para encerrar a View
Return
