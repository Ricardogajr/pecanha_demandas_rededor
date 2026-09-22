#INCLUDE "PROTHEUS.CH"
#INCLUDE "SPEDNFE.CH"
#INCLUDE "APWIZARD.CH"

/*/{Protheus.doc} RDSPEDSINC
Job de Sincronização de NFE na Sefaz

@author  Lucas Miranda de Aguiar
@since   23/07/2021
/*/
User Function RDSPEDSINC(cParm01, cParm02)

	Local aParam
	Local nCntFor
	Private cCadastro  := "Sincronização de NFE - Monitor de Notas Fiscais"

	Default cParm01 := ''
	Default cParm02 := ''

	If !empty(cParm01) .and. !empty(cParm02)
		aParam := {cParm01, cParm02}
	ElseIf !empty(cParm01) .and. Valtype(cParm01) == "A"
		aParam := {cParm01[1], cParm01[2]}
	Endif

	ConOut("*** INÝCIO - " + Dtoc(Date()) + " " + Time() + " - " + cCadastro)

	if Valtype(aParam) <> "A"
		ConOut("*** - " + "Processo pode ser executado apenas via Schedule") // "Processo pode ser executado apenas via Schedule"
	Else
		// Executa apenas se for chamado pelo Schedule.
		// As variáveis abaixo são úteis para debug da rotina via execução normal.
		Private lExecJob := .T.
		Private aMsgSch  := {}
		Private aFA205R  := {}

		RpcSetEnv(aParam[1], aParam[2])
		BatchProcess(cCadastro, cCadastro, "SPEDSNCJOB", {|| SPEDSNCJOB()}, {|| .F. })

		RpcClearEnv()
	Endif

	ConOut("*** FIM - " + Dtoc(Date()) + " " + Time() + " - " + cCadastro)

Return


/*/{Protheus.doc} SPEDSNCJOB
Job de Sincronização de NFE na Sefaz

@author  Lucas Miranda de Aguiar
@since   23/07/2021
/*/
Static Function SPEDSNCJOB()

	Local oTButton2
	Local oTButton1
	Local oDlg
	Local oSay
	Local oCheck
//Local oCheck1
	local cfonte := IIf (FunName()$ "SPEDMANIFE","SPEDMANIFE","")

	Local lCheck	:= .T.
	Local lCheck1	:= .T.

	Local lContinua := .F.

	local cMsg := ""

	If xReadyTss()
		xSincDados(lCheck,lCheck1)
		U_xAtStNf()
	Else
		Conout("Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!")//"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
	EndIf

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} U_xReadyTss()
Verifica se a conexao com o TSS pode ser estabelecida

@author Lucas Aguiar
@since 10/06/2021
@version 1.00
/*/
//-----------------------------------------------------------------------    
Static Function xReadyTss(cURL,nTipo,lHelp)

Return (CTIsReady(cURL,nTipo,lHelp,.F.))


Static Function xSincDados(lProcAll,lRefazSinc)

	Local aChave	:= {}
	Local aDocs		:= {}
	Local aProc		:= {}

	Local cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local cIdEnt	:= RetIdEnti(.F.)
	Local cChave	:= ""
	Local cCancNSU	:= ""
	Local cAlert	:= ""
	Local cSitConf	:= ""
	Local cCodEvento	:= ""
	Local cAmbiente	:= ""
	Local lContinua	:= .T.

	Local lOk		:= .F.
	Local lDestcnpj	:= .T.
	local lSinc     := .F.

	Local nX		:= 0
	Local nZ		:= 0

	Private oWs		:= Nil
	Private oInfdoc	:= Nil

	Default lProcAll := .F.
	Default lRefazSinc	:= .F.

	If xReadyTss()
		oWs :=WSMANIFESTACAODESTINATARIO():New()
		oWs:cUserToken   := "TOTVS"
		oWs:cIDENT	     := cIdEnt
		oWs:cINDNFE		 := "0"
		oWs:cINDEMI      := "0"
		oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"

		cAmbiente		 := xgetAmbMde()

	/* ********************************************************************************************************************** */
		// Retirado a opção de refazer a sincronizaçaõ de todos os documentos, devido o cliente estar sempre flegando esta opção
		// assim dando a impressão que o TSS não está sincronizando as notas.
	/* ********************************************************************************************************************** */
		// Refaz a sincronização de todos os documentos disponiveis na SEFAZ
		//If lRefazSinc
		//	oWs:cUltNSU	:= "0"
		//	oWs:CONFIGURARPARAMETROS()
		//Endif

		//Tratamento para solicitar a sincronização enaquanto o IDCONT não retornar zero.

		While lContinua

			lOk		:= .F.
			aChave	:= {}
			aProc	:= {}

			If oWs:SINCRONIZARDOCUMENTOS()
				If Type ("oWs:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO") <> "U"
					If Type("oWs:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO")=="A"
						aDocs := oWs:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO
					Else
						aDocs := {oWs:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO}
					EndIf

					For nX := 1 To Len(aDocs)
						lDestcnpj:=.T.
						oInfdoc := aDocs[nx]
						If Type("oInfdoc:CCHAVE") <> "U" .and. Type("oInfdoc:CSITCONF") <> "U"
							cSitConf  := oInfdoc:CSITCONF
							cChave    := oInfdoc:CCHAVE
							cCancNSU  := oInfdoc:CCANCNSU
							If Type("oInfdoc:CCODEVENTO") <> "U"
								cCodEvento:= oInfdoc:CCODEVENTO
							Else
								CodEvento:= ""
							EndIf
							If Type("oInfdoc:cDESTCNPJ") <> "U" .AND. !empty(oInfdoc:cDESTCNPJ)
								If SM0->M0_CGC <> oInfdoc:cDESTCNPJ
									lDestcnpj:= .F.
								EndIf
							EndIf

							// Caso o doc sincronizado tenha TPEVENTO não deve ir pra tabela C00
							If !cCodEvento $ "411500|411501|411502|411503" .and. lDestcnpj
								if xSincAtuDados(cChave,cSitConf,cCancNSU)
									aadd(aChave, cChave)
									lOk  := .T.
									lSinc:= .T.
								endif
							EndIf
						EndIf
					Next

					If lOk
						For nZ := 1 To Len( aChave )

							AADD( aProc, aChave[nZ] )

							If Len( aProc ) >= 30
								xMonitoraManif(aProc,cAmbiente,cIdEnt,cUrl)
								aProc := {}
							Endif

						Next
						If Len( aProc ) > 0
							xMonitoraManif(aProc,cAmbiente,cIdEnt,cUrl)
						Endif
					EndIf

					If Type("oWs:OWSSINCRONIZARDOCUMENTOSRESULT:CINDCONT") <> "U"

						If oWs:OWSSINCRONIZARDOCUMENTOSRESULT:CINDCONT == "0"
							lContinua := .F.
						endif
					else
						lContinua := .F.
					endif

					If Empty(aDocs) .And. !lContinua .And. !lOk
						If lSinc
							cAlert:= "Todos os documentos disponíveis até o momento foram sincronizados."
						Else
							cAlert:= STR0437 //"Não há documentos para serem sincronizados"
						EndIF
					EndIF
					Sleep(2000)
				EndIf
			Else
				lContinua := .F.
				Conout(GetWscError())
			EndIf
		EndDo
	EndIf

	oWs := Nil
	oInfdoc := Nil
	aDocs := Nil
	DelClassIntf()

Return


Static Function xgetAmbMde()

	local cAmbiente := ""
	local cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
	local oWs
	Local lUsaColab := .F.

	if !lUsacolab .and. xReadyTss()
		oWs :=WSMANIFESTACAODESTINATARIO():New()
		oWs:cUserToken   := "TOTVS"
		oWs:cIDENT	     := retIdEnti(.F.)
		oWs:cAMBIENTE	 := ""
		oWs:cVERSAO      := ""
		oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"
		oWs:CONFIGURARPARAMETROS()
		cAmbiente		 := oWs:OWSCONFIGURARPARAMETROSRESULT:CAMBIENTE

		freeObj(oWs)
		oWs := nil

	endif

return cAmbiente


Static Function xSincAtuDados(cChave,cSitConf,cCancNSU)

	Local dData		:= CtoD("  /  /    ")
	Local lOk			:= .F.

	C00->(DbsetOrder(1))
	If !C00->( DbSeek( xFilial("C00") + cChave) )
		RecLock("C00",.T.)
		C00->C00_FILIAL     := xFilial("C00")
		C00->C00_STATUS     := cSitConf
		C00->C00_CHVNFE		:= cChave
		dData := CtoD("01/"+Substr(cChave,5,2)+"/"+Substr(cChave,3,2))
		C00->C00_ANONFE		:= Strzero(Year(dData),4)
		C00->C00_MESNFE		:= Strzero(Month(dData),2)
		C00->C00_SERNFE		:= Substr(cChave,23,3)
		C00->C00_NUMNFE		:= Substr(cChave,26,9)
		C00->C00_CODEVE		:= Iif(cSitConf $ '0',"1","3")
		If !Empty(cCancNSU)
			C00->C00_SITDOC := "3" //nota cancelada
		Else
			C00->C00_SITDOC := "1" //nota autorizada
		EndIf
		lOk := .T.
		MsUnLock()
		If ExistBlock("MANIGRV")
			ExecBlock("MANIGRV",.F.,.F.,{Substr(cChave,23,3),Substr(cChave,26,9),cChave,cSitConf})
		EndIf
	Else
		If !Empty(cCancNSU)
			RecLock("C00",.F.)
			C00->C00_SITDOC := "3"
			MsUnLock()
		EndIf
	EndIf

return (lOk)


Static Function xMonitoraManif(aChave,cAmbiente,cIdEnt,cUrl,lJob,cOpcUpd)

	Local cChave		:= ""
	Local cCNPJEmit	:= ""
	Local cIeEmit		:= ""
	Local cNomeEmit	:= ""
	Local cSitConf	:= ""
	Local cSituacao	:= ""
	Local cDesResp	:= ""
	Local cDesCod		:= ""

	Local dDtEmi		:= CTOD("  /  /  ")
	Local dDtRec		:= CTOD("  /  /  ")

	Local nValDoc		:= 0
	Local nZ := 0
	Local nY := 0

	Local aMonDoc	:={}

	Default cOpcUpd :=""

	Private oWS		:= Nil

	Default lJob	:= .F.

	if xReadyTss()
		oWs :=WSMANIFESTACAODESTINATARIO():New()
		oWs:cUserToken   := "TOTVS"
		oWs:cIDENT	     := cIdEnt
		oWs:cAMBIENTE	 := cAmbiente
		oWs:OWSMONDADOS:OWSDOCUMENTOS  := MANIFESTACAODESTINATARIO_ARRAYOFMONDOCUMENTO():New()
		For nY := 1 to Len(aChave)
			aadd(oWs:OWSMONDADOS:OWSDOCUMENTOS:OWSMONDOCUMENTO,MANIFESTACAODESTINATARIO_MONDOCUMENTO():New())
			oWs:OWSMONDADOS:OWSDOCUMENTOS:OWSMONDOCUMENTO[nY]:CCHAVE := aChave[nY]
		Next
		oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"

		If oWs:MONITORARDOCUMENTOS()
			If Type ("oWs:OWSMONITORARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSMONDOCUMENTORET") <> "U"
				If Type ("oWs:OWSMONITORARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSMONDOCUMENTORET") == "A"
					aMonDoc := oWs:OWSMONITORARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSMONDOCUMENTORET
				Else
					aMonDoc := {oWs:OWSMONITORARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSMONDOCUMENTORET}
				EndIf
			EndIF
			For nZ :=1 to Len(aMonDoc)
				If Type(aMonDoc[nZ]:CCHAVE) <> "U"
					cChave := aMonDoc[nZ]:CCHAVE

					cCNPJEmit	:= Iif(!Empty(Alltrim(aMonDoc[nZ]:CEMITENTECNPJ)),Alltrim(aMonDoc[nZ]:CEMITENTECNPJ),Alltrim(aMonDoc[nZ]:CEMITENTECPF))
					cIeEmit	:= AllTrim(aMonDoc[nZ]:CEMITENTEIE)
					cNomeEmit	:= Alltrim(aMonDoc[nZ]:CEMITENTENOME)
					cSitConf	:= aMonDoc[nZ]:CSITUACAOCONFIRMACAO
					cSituacao	:= aMonDoc[nZ]:CSITUACAO
					cDesResp	:= Alltrim(aMonDoc[nZ]:CRESPOSTADESCRICAO)
					cDesCod	:= aMonDoc[nZ]:CRESPOSTASTATUS

					dDtEmi		:= StoD(StrTran(aMonDoc[nZ]:CDATAEMISSAO,"-",""))
					dDtRec		:= StoD(StrTran(aMonDoc[nZ]:CDATAAUTORIZACAO,"-",""))

					nValDoc		:= aMonDoc[nZ]:NVALORTOTAL


					xMonAtuDados(cChave,cCNPJEmit,cIeEmit,cNomeEmit,cSitConf,cSituacao,cDesResp,cDesCod,dDtEmi,dDtRec,nValDoc,cOpcUpd)

				EndIf
			Next
		Else
			//Conout("SPED " + IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		EndIf
	Else
		Conout("Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!") //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
	EndIf

	oWs := Nil
	DelClassIntf()

Return


Static Function xMonAtuDados(cChave,cCNPJEmit,cIeEmit,cNomeEmit,cSitConf,cSituacao,cDesResp,cDesCod,dDtEmi,dDtRec,nValDoc,cOpcUpd)

	C00->(DbsetOrder(1))
	If C00->(DbSeek( xFilial("C00") + cChave))
		RecLock("C00",.F.)
		C00->C00_CNPJEM		:= Alltrim(cCNPJEmit)
		C00->C00_IEEMIT		:= AllTrim(cIeEmit)
		C00->C00_NOEMIT		:= Alltrim(cNomeEmit)
		// Caso tenha retornado cSitConf = 0 (Sem Manifestação do Destinatário), devido ao sincronismo ter sido em momentos diferentes, ou seja, no sincronismo não continha nenhuma manifestação,
		// porém após poderá ter sido realizado alguma manifestação (como no TSS gravado Sem Manifestação do Destinatário), e retornado rejeição cOpcUpd = 4 assim como o registro C00_STATUS está com status 1 ou 4 ( confirmação ou ciencia )
		// manter o mesmo status para que seja possível realizar a exportação do XML, caso tenha sido uma rejeição diferente de duplicidade, a SEFAZ não irá retorna o XML.
		// DSERTSS1-16588
		C00->C00_STATUS		:= if(alltrim(cSitConf) == "0" .and. alltrim(cOpcUpd) == '4' .and. C00->C00_STATUS $ "1|4" , C00->C00_STATUS, cSitConf)
		C00->C00_SITDOC		:= cSituacao
		C00->C00_DESRES		:= Alltrim(cDesResp)
		C00->C00_CODRET		:= cDesCod
		C00->C00_DTEMI  	:= dDtEmi
		C00->C00_DTREC		:= dDtRec
		C00->C00_VLDOC		:= nValDoc
		C00->C00_CODEVE		:= Iif(alltrim(cOpcUpd) $ '4','4',Iif(alltrim(C00->C00_STATUS) $ '0',"1","3"))
		C00->(MsUnLock())
	EndIf

return nil


Static Function xAtStNf()

	Local aArea := GetArea()
	Local cCodForn := ""
	Local cLojaForn := ""
	Local cFilNf := ""
	Local cNumNf := ""
	Local cSerieNf := ""
	Local lContinua := .T.

	dbSelectArea("C00")
	DbSetOrder(1)
	dbGotop()

	While C00->(!EOF())

		If C00->C00_FILIAL == xFilial("C00")
			dbSelectArea("SA2")
			DbSetOrder(3)

			cFilNf   := C00->C00_FILIAL
			cNumNf	 := C00->C00_NUMNFE
			cSerieNf := C00->C00_SERNFE

			If SA2->(DbSeek(xFilial("SA2")+C00->C00_CNPJEM))
				cCodForn := SA2->A2_COD
				cLojaForn := SA2->A2_LOJA
			EndIf

			dbSelectArea("SE2")
			DbSetOrder(6)

			//Enquanto existir zeros a esquerda
			While lContinua
				If cSerieNf == "000"
					lContinua := .F.
					cSerieNf := PadR("0",TamSX3("E2_PREFIXO")[1])
				EndIf
				//Se a priemira posição for diferente de 0 ou não existir mais texto de retorno, encerra o laço
				If SubStr(cSerieNf, 1, 1) <> "0" .Or. Len(cSerieNf) ==0
					lContinua := .f.
				EndIf
				//Se for continuar o processo, pega da próxima posição até o fim
				If lContinua
					cSerieNf := Substr(cSerieNf, 2, Len(cSerieNf))
				EndIf
			EndDo

			If SE2->(DbSeek(cFilNf+cCodForn+cLojaForn+PadR(cSerieNf,TamSX3("E2_PREFIXO")[1])+cNumNf))//E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM
				If !Empty(SE2->E2_BAIXA)
					If C00->C00_STATUS <> "8"
						RecLock("C00",.F.)
						C00->C00_STATUS := "8"
						C00->(MsUnlock())
					EndIf
				ElseIf !Empty(SE2->E2_NUMBOR)
					If C00->C00_STATUS <> "7"
						RecLock("C00",.F.)
						C00->C00_STATUS := "7"
						C00->(MsUnlock())
					EndIf
				Else
					If C00->C00_STATUS <> "6"
						RecLock("C00",.F.)
						C00->C00_STATUS := "6"
						C00->(MsUnlock())
					EndIf
				EndIf
			Else
				If C00->C00_STATUS <> "9"
					RecLock("C00",.F.)
					C00->C00_STATUS := "9"
					C00->(MsUnlock())
				EndIf
			EndIf
		EndIf
		C00->(DbSkip())
	EndDo

	RestArea(aArea)
Return
