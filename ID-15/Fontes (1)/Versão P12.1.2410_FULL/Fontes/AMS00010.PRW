#Include 'Protheus.ch'
#include "rwmake.ch"
#include "topconn.ch"

/*
{Protheus.doc} AMS00010()
Fonte para readequar os substitutos para titulares, quando houver aumento de quadro,
transferências e desligamentos em postos.
DOR05218784 - AMS
@Author     416094 - Rogerio Carvalho
@Since      17/10/2018
@Version    P12.1.07
@Project
*/

//************************************************************************************
// Aumento de Quadro
// Função para ajustar , na RCL, quantidade de titulares e substitutos. Baseado na RCX.
User Function AmsAjQuad(cRclFil,cRclPost,nRclAq)

	Local aAreaAnt := getarea()
	Local nRcxSub  := 0
	Local nRcxTit  := 0
	Local nCntSub  := 0
	Local aRcxTS   := {}

	// Verifica se a quantidade , passada por parametro, do aumento de quadro é maior que zero
	If nRclAq <= 0
		restarea(aAreaAnt)
		Return
	Endif

	// Seleciona os participantes do posto
	cQueryRCX := " SELECT * "
	cQueryRCX += " FROM " + RetSqlName("RCX") + " "
	cQueryRCX += " WHERE D_E_L_E_T_=' ' "
	cQueryRCX += " AND RCX_POSTO= '"+cRclPost+"' "
	cQueryRCX += " AND RCX_FILIAL= '"+cRclFil+"' "
	cQueryRCX += " ORDER BY RCX_FILIAL, RCX_POSTO, RCX_DTINI, RCX_MATFUN "

	If Select("ALRERCX") > 0
		ALRERCX->(DbCloseArea())
	EndIf

	cQueryRCX := ChangeQuery(cQueryRCX)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryRCX),"ALRERCX")

	nRcxSub := 0
	nRcxTit := 0
	nCntSub := 1

	// conta os participantes do posto
	DbSelectArea("ALRERCX")
	While !ALRERCX->(EOF())

		If ALRERCX->RCX_SUBST == "1" // se participante é subtituto
			nRcxSub +=1

			If nCntSub <= nRclAq

				DbSelectArea("RCX")
				RCX->(DbSetOrder(2))
				RCX->(dbGoTop())

				If dbseek(ALRERCX->RCX_FILIAL+ALRERCX->RCX_POSTO+ALRERCX->RCX_FILFUN+ALRERCX->RCX_MATFUN)
					RecLock('RCX',.F.)

					RCX->RCX_SUBST  := "2"
					nRcxTit += 1
					nRcxSub -=1
					nCntSub += 1

					MsUnLock()
				Endif

			Endif

		Else // se não, participante é titular
			nRcxTit +=1
		Endif

		ALRERCX->(dbskip())

	Enddo

	AADD(aRcxTS,nRcxTit+nRcxSub)
	AADD(aRcxTS,nRcxSub )

	//nRcxTit := nRcxTit+nRcxSub

	ALRERCX->(DbCloseArea())
	//restarea(aAreaAnt)

Return aRcxTS

//************************************************************************************
// Transferencia entre postos
// Função para ajustar , na RCL, quantidade de titulares e substitutos. Baseado na RCX.
User Function AmsTrfPost(cSraMatF,cSRAFILORI,cSRAPOSORI,cREFILDES,cREPOSDES)

	Local cQueryT   := ""
	Local cQueryS   := ""
	Local nQtdTit   := 0
	Local nQtdSub   := 0
	Local aAreaAnt  := getarea()
	Local aAreaAnt2 := getarea()
	Local lVagaTit  := .f.
	Local aRclTS    := {}
	Local cStVag    := ""

	// verifica se matricula foi informada, para ajustar, tanto o posto origem quanto destino
	If empty(alltrim(cSraMatF))
		restarea(aAreaAnt)
		Return
	Endif

	DbSelectArea("RCL")
	RCL->(DbSetOrder(2))
	RCL->(dbGoTop())

	// Posto de Origem , na Tranferência de Posto
	// Ajusta tabela RCL, se necessário, nos campos RCL_OPOSTO e RCL_XSPOST
	If dbseek(cSRAFILORI+cSRAPOSORI)

		nRclNpst := RCL->RCL_NPOSTO

		// Seleciona os funcionários  titulares e substitutos no posto destino
		cQueryT := " SELECT * "
		cQueryT += " FROM " + RetSqlName("RCX") + " "
		cQueryT += " WHERE D_E_L_E_T_=' ' "
		cQueryT += " AND RCX_POSTO= '"+cSRAPOSORI+"' "
		cQueryT += " AND RCX_FILIAL= '"+cSRAFILORI+"' "
		cQueryT += " AND RCX_SUBST IN ('1','2') "

		If Select("ALIRCXTO") > 0
			ALIRCXTO->(DbCloseArea())
		EndIf

		cQueryT := ChangeQuery(cQueryT)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryT),"ALIRCXTO")

		nRcxTit := 0
		nRcxSub := 0
		DbSelectArea("ALIRCXTO")
		While !ALIRCXTO->(EOF())

			If ALIRCXTO->RCX_SUBST == "1"  // se é substituto
				nRcxSub += 1
			ElseIf ALIRCXTO->RCX_SUBST == "2"  // se é titular
				nRcxTit += 1
			Endif

			ALIRCXTO->(dbskip())

		Enddo

		// se quantidade definida do posto é igual a quantidade de titulares
		// porque foi retirado substituto
		If nRclNpst == nRcxTit

			DbSelectArea("RCL")
			RCL->(DbSetOrder(2))
			RCL->(dbGoTop())

			If dbseek(cSRAFILORI+cSRAPOSORI)
				RecLock('RCL',.F.)
				RCL->RCL_OPOSTO := nRcxTit+nRcxSub
				RCL->RCL_XSPOST	:= nRcxSub
				MsUnLock()
			Endif

		// se quantidade definida do posto é maior que a quantidade de titulares 
		// e o numero de substituos é igual a zero
		// porque foi demitido titular e nao ha substitutos
		ElseIf (nRclNpst > nRcxTit) .and. (nRcxSub == 0)

			DbSelectArea("RCL")
			RCL->(DbSetOrder(2))
			RCL->(dbGoTop())

			If dbseek(cSRAFILORI+cSRAPOSORI)
				RecLock('RCL',.F.)
				RCL->RCL_OPOSTO := nRcxTit+nRcxSub
				RCL->RCL_XSPOST	:= nRcxSub
				MsUnLock()
			Endif

			// se quantidade definida do posto é maior que a quantidade de titulares
			// e o numero de substitutos é maior que zero, entao foi demitido titular
			// nesse caso o status do primeiro substituto deve ser atualizado para titular
			// e deve ser recontado os titulares e substitutos e atualizado a tabela RCL
		ElseIf (nRclNpst > nRcxTit) .and. (nRcxSub > 0)
			nSomaTit:=0
			DbSelectArea("RCX")
			RCX->(DbSetOrder(6))
			RCX->(dbGoTop())

			If RCX->(dbseek(cSRAFILORI+cSRAPOSORI))

				While RCX->RCX_FILIAL == cSRAFILORI .and. RCX->RCX_POSTO == cSRAPOSORI
					If RCX->RCX_SUBST=="1"
						RecLock('RCX',.F.)
							RCX->RCX_SUBST := "2"
						MsUnLock()
						nSomaTit += 1
						exit
					Endif
					RCX->(dbskip())
				Enddo
				
				DbSelectArea("RCL")
				RCL->(DbSetOrder(2))
				RCL->(dbGoTop())

				If RCL->(dbseek(cSRAFILORI+cSRAPOSORI))
					RecLock('RCL',.F.)
						RCL->RCL_OPOSTO := nQtdTit+nSomaTit
					 // RCL->RCL_XSPOST	:= nQtdSub-nSomaTit 
						// Ticket No. 4494084 - 418497 - Don Junior - ajuste para não gerar quantidade negativa
						RCL->RCL_XSPOST	:= (RCL->RCL_OPOSTO - nSomaTit)
					MsUnLock()
				Endif

			Endif

		Endif

		Endif

	// Posto de Destino , na Tranferência de Posto
	DbSelectArea("RCL")
	RCL->(DbSetOrder(2))
	RCL->(dbGoTop())

	// Ajusta tabela RCL, se necessário, nos campos RCL_OPOSTO e RCL_XSPOST
	If RCL->(dbseek(cREFILDES+cREPOSDES))
		//If (RCL->RCL_NPOSTO ==  RCL->RCL_OPOSTO) .or. (RCL->RCL_NPOSTO >  RCL->RCL_OPOSTO)
		If (RCL->RCL_NPOSTO >  RCL->RCL_OPOSTO)
			// variavel para sinalizar a troca , se necessário , do status do funcionário transferido
			// de titular para substituto
			lVagaTit := .t.
		Endif
	Endif

	// Seleciona os funcionários  titulares e substitutos no posto destino
	cQueryT := " SELECT * "
	cQueryT += " FROM " + RetSqlName("RCX") + " "
	cQueryT += " WHERE D_E_L_E_T_=' ' "
	cQueryT += " AND RCX_POSTO= '"+cREPOSDES+"' "
	cQueryT += " AND RCX_FILIAL= '"+cREFILDES+"' "
	cQueryT += " AND RCX_SUBST IN ('1','2') "

	If Select("ALIRCXTD") > 0
		ALIRCXTD->(DbCloseArea())
	EndIf

	cQueryT := ChangeQuery(cQueryT)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryT),"ALIRCXTD")

	DbSelectArea("ALIRCXTD")
	While !ALIRCXTD->(EOF())

		If  ALIRCXTD->RCX_MATFUN == cSraMatF

			If ALIRCXTD->RCX_SUBST == "1" .AND. lVagaTit // se é substituto e tem vaga pra titular
				cStVag := "2"
			ElseIf ALIRCXTD->RCX_SUBST == "1" .AND. !lVagaTit // se é substituto e não tem vaga pra titular
				cStVag := "1"
			ElseIf ALIRCXTD->RCX_SUBST == "2" .AND. lVagaTit // se é titular e tem vaga pra titular
				cStVag := "2"
			ElseIf ALIRCXTD->RCX_SUBST == "2" .AND. !lVagaTit // se é titular e não tem vaga pra titular
				cStVag := "1"
			Endif

			aAreaAnt2:= getarea()

			DbSelectArea("RCX")
			RCX->(DbSetOrder(2))
			RCX->(dbGoTop())

			If dbseek(ALIRCXTD->RCX_FILIAL+ALIRCXTD->RCX_POSTO+ALIRCXTD->RCX_FILFUN+ALIRCXTD->RCX_MATFUN)

				RecLock('RCX',.F.)
				RCX->RCX_SUBST  := cSTVag
				MsUnLock()

				// atualiza no cadastro do funcionário a informação do posto destino
				DbSelectArea("SRA")
				SRA->(DbSetOrder(13))
				SRA->(dbGoTop())

				If SRA->(dbseek(cSraMatF))
					// atualiza posto do funcionário , no cadastro
					RecLock('SRA',.F.)
					SRA->RA_POSTO  := cREPOSDES //ALIRCXTD->RCX_POSTO
					MsUnLock()
				Endif

				restarea(aAreaAnt2)

				If cStVag == "2"
					nQtdTit += 1 // acumula o total de titulares
				Elseif cStVag == "1"
					nQtdSub += 1 // acumula o total de substitutos
				Endif

			Endif
		Else
		    If ALIRCXTD->RCX_SUBST == '2'
			nQtdTit += 1 // acumula o total de titulares
			Elseif ALIRCXTD->RCX_SUBST == '1'
			nQtdSub += 1 // acumula o total de substitutos
		    Endif
        Endif
		ALIRCXTD->(dbskip())

	Enddo

	//Ajusta tabela RCL para Posto Destino
	DbSelectArea("RCL")
	RCL->(DbSetOrder(2))
	RCL->(dbGoTop())

	If RCL->(dbseek(cREFILDES+cREPOSDES))

		//If	RCL->RCL_NPOSTO < RCL->RCL_OPOSTO

		//nAjPst:= RCL->RCL_OPOSTO < RCL->RCL_NPOSTO
		RecLock('RCL',.F.)
		RCL->RCL_OPOSTO := nQtdTit+nQtdSub
		RCL->RCL_XSPOST	:= nQtdSub
		MsUnLock()
		//Endif
	Endif

	ALIRCXTD->(DbCloseArea())

	restarea(aAreaAnt)

Return

//************************************************************************************
// Desligamento do Funcionário - Ajusta posto
// Função para ajustar , na RCL, quantidade de titulares e substitutos. Baseado na RCX.
User Function AmsDesPost(cSRAFILDES,cSRAPOSDES)

	Local aAreaAnt	:= getarea()
	Local lVagaTit	:= .f.
	Local cSTVag	:= ""
	Local cQueryT 	:= ""
	Local aRclTS	:= {}
	Local nSomaTit  := 0
	Local nRclNpst  := 0
	Local nRcxTit   := 0
	Local nRcxSub   := 0

	If empty(alltrim(cSRAFILDES)) .or. empty(alltrim(cSRAPOSDES))
		restarea(aAreaAnt)
		Return
	Endif

	DbSelectArea("RCL")
	RCL->(DbSetOrder(2))
	RCL->(dbGoTop())

	// Ajusta tabela RCL, se necessário, nos campos RCL_OPOSTO e RCL_XSPOST
	If RCL->(dbseek(cSRAFILDES+cSRAPOSDES))


		nRclNpst := RCL->RCL_NPOSTO

		// Seleciona os funcionários  titulares e substitutos no posto destino
		cQueryT := " SELECT * "
		cQueryT += " FROM " + RetSqlName("RCX") + " "
		cQueryT += " WHERE D_E_L_E_T_=' ' "
		cQueryT += " AND RCX_POSTO= '"+cSRAPOSDES+"' "
		cQueryT += " AND RCX_FILIAL= '"+cSRAFILDES+"' "
		cQueryT += " AND RCX_SUBST IN ('1','2') "

		If Select("ALIRCXTZ") > 0
			ALIRCXTZ->(DbCloseArea())
		EndIf

		cQueryT := ChangeQuery(cQueryT)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryT),"ALIRCXTZ")

		nRcxTit := 0
		nRcxSub := 0
		DbSelectArea("ALIRCXTZ")
		While !ALIRCXTZ->(EOF())

			If ALIRCXTZ->RCX_SUBST == "1"  // se é substituto
				nRcxSub += 1
			ElseIf ALIRCXTZ->RCX_SUBST == "2"  // se é titular
				nRcxTit += 1
			Endif

			ALIRCXTZ->(dbskip())

		Enddo

		// se quantidade definida do posto é igual a quantidade de titulares
		// porque foi demitido substituto
		// nesse caso somente atualizar a tabela RCL
		If nRclNpst == nRcxTit

			DbSelectArea("RCL")
			RCL->(DbSetOrder(2))
			RCL->(dbGoTop())

			If RCL->(dbseek(cSRAFILDES+cSRAPOSDES))
				RecLock('RCL',.F.)
				RCL->RCL_OPOSTO := nRcxTit+nRcxSub
				RCL->RCL_XSPOST	:= nRcxSub
				MsUnLock()
			Endif

		// se quantidade definida do posto é maior que a quantidade de titulares
		// e substitutos é igual a zero, porque foi demitido titular
		// nesse caso somente atualizar a tabela RCL
		ElseIf (nRclNpst > nRcxTit) .and. (nRcxSub == 0)

			DbSelectArea("RCL")
			RCL->(DbSetOrder(2))
			RCL->(dbGoTop())

			If dbseek(cSRAFILDES+cSRAPOSDES)
				RecLock('RCL',.F.)
				RCL->RCL_OPOSTO := nRcxTit+nRcxSub
				RCL->RCL_XSPOST	:= nRcxSub
				MsUnLock()
			Endif

			// se quantidade definida do posto é maior que a quantidade de titulares
			// e o numero de substitutos é maior que zero, entao foi demitido titular
			// nesse caso o status do primeiro substituto deve ser atualizado para titular
			// e deve ser recontado os titulares e substitutos e atualizado a tabela RCL
		ElseIf (nRclNpst > nRcxTit) .and. (nRcxSub > 0)
			nSomaTit:=0
			DbSelectArea("RCX")
			RCX->(DbSetOrder(6))
			RCX->(dbGoTop())

			If RCX->(dbseek(cSRAFILDES+cSRAPOSDES))

				While RCX->RCX_FILIAL == cSRAFILDES .and. RCX->RCX_POSTO == cSRAPOSDES
					If RCX->RCX_SUBST=="1"
						RecLock('RCX',.F.)
						RCX->RCX_SUBST := "2"
						MsUnLock()
						nSomaTit += 1
						exit
					Endif
					RCX->(dbskip())
				Enddo
				
				DbSelectArea("RCL")
				RCL->(DbSetOrder(2))
				RCL->(dbGoTop())

				If RCL->(dbseek(cSRAFILDES+cSRAPOSDES))
					RecLock('RCL',.F.)
					RCL->RCL_OPOSTO := nRcxTit+nSomaTit
					RCL->RCL_XSPOST	:= nRcxSub-nSomaTit
					MsUnLock()
				Endif

			Endif

		Endif
		
		ALIRCXTZ->(DbCloseArea()) //Thais Paiva - 7049358

	Endif

	//ALIRCXTZ->(DbCloseArea()) Thais Paiva - 7049358

	restarea(aAreaAnt)

Return

//************************************************************************************
// Conta Status dos Funcionários no Posto: titulares e subsitutos
// e atualiza os campos na tabela RCL : RCL_OPOSTO e RCL_XSPOST
User Function AmsCntSt(cRclFil,cRclPost)

	Local aAreaAnt := getarea()
	Local nRcxSub  := 0
	Local nRcxTit  := 0
	Local nCntSub  := 0

	// Verifica se a quantidade , passada por parametro, do aumento de quadro é maior que zero
	If empty(alltrim(cRclFil)) .or. empty(alltrim(cRclPost))
		restarea(aAreaAnt)
		Return
	Endif

	// Seleciona os participantes do posto
	cQueryRCX := " SELECT * "
	cQueryRCX += " FROM " + RetSqlName("RCX") + " "
	cQueryRCX += " WHERE D_E_L_E_T_=' ' "
	cQueryRCX += " AND RCX_POSTO= '"+cRclPost+"' "
	cQueryRCX += " AND RCX_FILIAL= '"+cRclFil+"' "
	cQueryRCX += " ORDER BY RCX_FILIAL, RCX_POSTO, RCX_DTINI, RCX_MATFUN "

	If Select("CNTRCX") > 0
		CNTRCX->(DbCloseArea())
	EndIf

	cQueryRCX := ChangeQuery(cQueryRCX)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryRCX),"CNTRCX")

	nRcxSub := 0
	nRcxTit := 0
	nCntSub := 1

	// conta os participantes do posto
	DbSelectArea("CNTRCX")
	While !CNTRCX->(EOF())

		If CNTRCX->RCX_SUBST == "1" // se participante é subtituto
			nRcxSub +=1
		Elseif CNTRCX->RCX_SUBST == "2" // se não, participante é titular
			nRcxTit +=1
		Endif

		CNTRCX->(dbskip())

	Enddo

	DbSelectArea("RCL")
	RCL->(DbSetOrder(2))
	RCL->(dbGoTop())

	If RCL->(dbseek(cRclFil+cRclPost))

		RecLock('RCL',.F.)
		RCL->RCL_OPOSTO := nRcxTit+nRcxSub
		RCL->RCL_XSPOST	:= nRcxSub
		MsUnLock()

	Endif

	CNTRCX->(DbCloseArea())

	restarea(aAreaAnt)

Return

