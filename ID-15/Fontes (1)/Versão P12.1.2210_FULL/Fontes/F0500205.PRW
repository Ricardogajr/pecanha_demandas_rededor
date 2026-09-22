#Include 'Protheus.ch'

/*/{Protheus.doc} F0500205
Chamada no ponto de entrada RSP100ME, que tem como objetivo permitir a inclusï¿½o de novos botï¿½es (rotinas) no menu do browse do Cadastro de Vagas.
@author Fernando
@since 14/12/2016
@version 1.0
@project MAN0000007423039_EF_002
/*/

User Function F0500205()

	aAdd( aRotina, {'Cancelar Vaga' , 'U_VagaCanc()', 0, 4} )
	aAdd( aRotina, {'Suspender Vaga', 'U_VagaSusp()', 0, 4} )
	aAdd( aRotina, {'Reabre a Vaga'	, 'U_VagaReab()', 0, 4} )
	aAdd( aRotina, {'Historico'		, 'U_HistMotiv()', 0, 4} )

Return

/*/{Protheus.doc} VagaReab
Vaga Reaberta
@author  Fernando Carvalho 
@since 14/11/2016
@version 12.7
@project MAN0000007423039_EF_002
/*/
User Function VagaReab()

	Local lMotivo := .F.
	Local cMotivo := ""
	Local cEmail  := Posicione("SRA",1,SQS->(QS_FILRESP+QS_MATRESP),"RA_EMAIL")
	Local lRet    := .F.
	Local cBody   := "A vaga "+ SQS->QS_VAGA +" foi reaberta " + CRLF
	
	//If SQS->QS_XSTATUS != '5' .AND.  SQS->QS_XSTATUS != '7' //ticket n° 6424694 - 415966 - Paulo Dias - validação para não permitir a reabertura da vaga
	If !(SQS->QS_XSTATUS $ "5/7") 
		RecLock("SQS",.F.)
		SQS->QS_XMOTIVO := cMotivo
		SQS->QS_XSTATUS := SQS->QS_XSUSPEN
		SQS->QS_XSUSPEN := ''
		SQS->(MsUnLock())
		
		U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,SQS->QS_XSUSPEN)	//Status da Vaga na FAP
		U_F0500201(SQS->QS_XSOLFIL,SQS->QS_XSOLPTL,"010")
		
		If !Empty(cMotivo)
			cBody += +CRLF +CRLF +"Motivo da Alteração: " + cMotivo
		EndIf
			
		lRet := U_F0200304("Vaga Reaberta", cBody, cEmail) //Rotina de Envio de E-mail
		
		If !lRet
			Aviso("INSUCESSO - Email","E-mail não enviado. Comunique aos envolvidos!" ,{'OK'},1)
		EndIf
		
		MsgAlert("Vaga Reaberta!")
		
	Else
		//Alert("A vaga não foi 'Suspensa' para que seja 'Reaberta'!")
		//MsgAlert("A vaga já se encontra concluída!")
		If SQS->QS_XSTATUS == '5'  //ticket n° 6424694 - 415966 - Paulo Dias - validação para não permitir nova suspensão da vaga
	
			MsgAlert("Vaga já se encontra cancelada!")
	
		elseif SQS->QS_XSTATUS == '7'
		
			MsgAlert("Vaga já se encontra Concluída!")
			
		endif
	EndIf
Return
	
/*/{Protheus.doc} HistMotiv
Historico
@author Fernando
@since 14/12/2016
@version 1.0
@project MAN0000007423039_EF_002
/*/
User Function HistMotiv()
	Local oDlg
	Local cTexto1 := SQS->QS_XMOTIVO
	
	If !Empty(cTexto1)
		DEFINE DIALOG oDlg TITLE "Motivo da Alteração" FROM 180, 180 TO 420, 700 PIXEL
		TMultiGet():new( 01, 01, {| u | if( pCount() > 0, cTexto1 := u, cTexto1 ) },oDlg, 260, 92, , , , , , .T. )
		TButton():New( 100, 100, "OK",oDlg,{||oDlg:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		ACTIVATE DIALOG oDlg CENTERED
	Else
		Alert("Não existe histórico de alterações!")
	EndIf
Return

/*/{Protheus.doc} VagaSusp
Vaga Suspensa
@author		Fernando Carvalho 
@CoAuthor	Ademar Fernandes 
@since		14/11/2016
@version	12.7
@project	2015GGS0758_MAN00000060101_EF_001
/*/
/*
Quando o botao Suspender Vaga estava na rotina da FAP (F0500206), a partir da PA2, buscava a SQS e atualizava os 2 arquivos
*/
User Function VagaSusp()

	Local aArea   := GetArea()
	Local lMotivo := .F.
	Local aMotivo := ""
	Local lRet    := .F.
	Local cCodVag := ""
	
	If SQS->QS_XSTATUS == '5'  //ticket n° 6424694 - 415966 - Paulo Dias - validação para não permitir nova suspensão da vaga
	
		MsgAlert("Vaga já se encontra cancelada!")
	
	elseif SQS->QS_XSTATUS == '7'
		
		MsgAlert("Vaga já se encontra Concluída!")
	
	Else
	
		If MsgNoYes("Deseja realmente continuar com o processo de suspender a vaga?")
				
			aMotivo := U_Motivo()
				
			lMotivo := aMotivo[1]
			cMotivo := aMotivo[2]
				
			If lMotivo
				If !Empty(cMotivo)

					DbSelectArea("SQS")
					SQS->(DbSetOrder(1))
					RecLock("SQS",.F.)
					SQS->QS_XMOTIVO := cMotivo
					SQS->QS_XSUSPEN := SQS->QS_XSTATUS
					SQS->QS_XSTATUS := '6'
					SQS->(MsUnLock())

					U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"6")	//Status da Vaga na FAP						
					U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "011") //Em Recrutamento
					DbSelectArea("PA2")
					PA2->(DbSetOrder(8))	//-PA2_FILVG+PA2_CDVAGA
					If PA2->(dbSeek(SQS->(QS_FILIAL + QS_VAGA),.F.))
					cCodVag := SQS->(QS_FILIAL+QS_VAGA)
						While !(PA2->(EOF())) .AND. PA2->(PA2_FILVG+PA2_CDVAGA) == cCodVag
							U_F0500201(PA2->PA2_FILIAL,PA2->PA2_SOL,"009")
							U_ReprovaPA2()
							PA2->(DbSkip())
						EndDo
					EndIf
				
					U_F0500201(SQS->QS_XSOLFIL,SQS->QS_XSOLPTL,"009")

					EnvEmail("Vaga Suspensa",cMotivo)
					MsgAlert("Vaga Suspensa!")
				Else
					MsgAlert("É obrigatório o preenchimento de uma justificativa para alteração do Status!")
				EndIf
			Else
			
				MsgAlert("A vaga não foi suspensa!")
			
			EndIf
		EndIf
	EndIf
	
	RestArea(aArea)
	
Return

/*/{Protheus.doc} VagaCanc
Vaga Cancelada
@author		Fernando Carvalho 
@CoAuthor	Ademar Fernandes 
@since		14/11/2016
@version	12.7
@project	2015GGS0758_MAN00000060101_EF_001
/*/
/*
Quando o botao Cancelar Vaga estava na rotina da FAP (F0500206), a partir da PA2, buscava a SQS e atualizava os 2 arquivos
*/
User Function VagaCanc()

	Local aArea   := GetArea()
	Local lMotivo := .F.
	Local cMotivo := ""
	Local cCodVag := ""
	
	If MsgNoYes("Deseja realmente continuar com o processo de cancelamento da vaga? Caso exista FAP aprovada e/ou em andamento vinculada à vaga, será cancelada.")
					
		aMotivo := U_Motivo()
		
		lMotivo := aMotivo[1]
		cMotivo := aMotivo[2]
		
		If lMotivo
			If !Empty(cMotivo)
							
				RecLock("SQS",.F.)
				SQS->QS_XMOTIVO := cMotivo
				SQS->QS_XSTATUS := '5'
				SQS->(MsUnLock())
			
				U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"5")	//Status da Vaga na FAP
				// Chamado No.5501860 - 418497 - Don Junior - Ajuste para realizar o cancelamento da FAP na RH3 corretamente.
				// FsRepSol(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL)

				DbSelectArea("PA2")
				PA2->(DbSetOrder(8))	//-PA2_FILVG+PA2_CDVAGA
				If PA2->(dbSeek(SQS->(QS_FILIAL + QS_VAGA),.F.))
				cCodVag := SQS->(QS_FILIAL+QS_VAGA)
				
					While !(PA2->(EOF())) .AND. PA2->(PA2_FILVG + PA2_CDVAGA) == cCodVag

						// Chamado No.5501860 - 418497 - Don Junior - Ajuste para realizar o cancelamento da FAP na RH3 corretamente.
						FsRepSol(PA2->PA2_FILIAL, PA2->PA2_SOL) // Cancelamento da FAP na RH3
						FsRepSol(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL) // Cancelamento da Vaga na RH3 - Thais Paiva - 10437076

						U_F0500201(PA2->PA2_FILIAL,PA2->PA2_SOL,"008")
						U_ReprovaPA2()
						PA2->(DbSkip())
					EndDo
				Else //Ini­cio - Thais Paiva - 10437076
					FsRepSol(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL) // Cancelamento da Vaga na RH3
				//Fim - Thais Paiva - 10437076	
				EndIf
			
				U_F0500201(SQS->QS_XSOLFIL,SQS->QS_XSOLPTL,"008")
				EnvEmail("Vaga Cancelada",cMotivo)
				MsgAlert("Vaga Cancelada!")
			Else
				MsgAlert("É obrigatório o preenchimento de uma justificativa para alteração do Status!")
			EndIf
		Else
		
			//MsgAlert("A vaga foi cancelada!") Thais Paiva - 10437076
			MsgAlert("A não vaga foi cancelada!")
		
		EndIf
	EndIf
	
	RestArea(aArea)
Return

Static Function FsRepSol(cFilRh3, cCodRh3)

	Local aAreas := { RH3->(GetArea()), GetArea() }

	RH3->(DbSetOrder(1))
	If RH3->(DbSeek(cFilRh3+cCodRh3))
		Reclock("RH3", .F.)
		RH3->RH3_STATUS := '3'
		RH3->RH3_XCANCL := "1" //Cancelado Sim
		RH3->RH3_DTATEN := ddatabase //Thais Paiva - 10437076
		RH3->(MsUnlock())
	EndIf

	AEval(aAreas,{|x| RestArea(x) })

Return

/*/{Protheus.doc} EnvEmail
(Sem descricao)
@author  Fernando Carvalho 
@since 14/11/2016
@param cStatus, caracter,
@param cMotivo, caracter,
@version 12.7
@project 2015GGS0758_MAN00000060101_EF_001
/*/
Static Function EnvEmail(cStatus,cMotivo)
	
	Local cAssunto := cStatus
	Local cBody    := "A vaga referente ao código da solicitação "+ SQS->QS_XSOLPTL +" teve mudança de Status."+ CRLF+;
		"Novo Status: " + cStatus
	Local cEmail   := Posicione("SRA",1,SQS->(QS_FILRESP+QS_MATRESP),"RA_EMAIL")
	Local lRet     := .F.

	If !Empty(cMotivo)
		cBody += +CRLF +CRLF +"Motivo da Alteração: " +cMotivo
	EndIf
		
	lRet := U_F0200304(cAssunto, cBody, cEmail) //Rotina de Envio de E-mail
	
	If !lRet
		Aviso("INSUCESSO - Email","E-mail NÃO enviado. Comunique aos envolvidos!" ,{'OK'},1)
	EndIf

Return
