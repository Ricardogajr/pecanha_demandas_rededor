/*/{Protheus.doc} F1400101
Função chamada do Ponto de entrada ChkFile para gravação de Log.
@author Carlos Alberto Gomes Junior
@since 05/12/2017
/*/
User Function F1400101()

	Local cAlias    := PARAMIXB[2]
	Local cCampo    := If(Left(cAlias,1) == 'S', Right(cAlias,2) + '_FILIAL', cAlias + '_FILIAL')
	Local cAliasLog := "CT1,SA2,SAH,SB1,SBM,SED,P13,P14,P15,P16,P17,P24,P25,SA1,CVD,CVE,CVF,FIL,SE4,P32,SBZ,SF4,CTT,CTS,CTD,SEJ,SEB,LHT,SNG,CCQ"

	If (cAlias $ cAliasLog)
		If cAlias == 'SM2'
			FldSettrigger(M0_MOEDA1,8192 + 16384 + 32768,{|X,Y| U_F1400102(x,y)})
		Else
			&('FldSettrigger('+cCampo+',8192 + 16384 + 32768,{|X,Y| U_F1400102(x,y)})')
		EndIf
	EndIf

Return

/*/{Protheus.doc} F1400102
Função de gravação dos campos de log.
@author Carlos Alberto Gomes Junior
@since 05/12/2017
/*/
User Function F1400102(cCampo,nModo)

	Local nCodInsert := 8192
	Local nCodDelete := 32768
	Local cOperacao  := Iif( nModo == nCodDelete, '5', Iif( nModo == nCodInsert, '3', '4'))
	Local cDtTime    := DToS(Date())+Space(1)+Time()

	cAlias := Alias()

	RecLock(cAlias,.F.)

	Do Case

	Case cAlias == "SA1"
		If cOperacao == "3"
			SA1->A1_XUSRIN := cDtTime
		EndIf
		SA1->A1_XUSRAL := cDtTime
	Case cAlias == "SB1"
		If cOperacao == "3"
			SB1->B1_XUSRIN := cDtTime
		EndIf
		SB1->B1_XUSRAL := cDtTime
	Case cAlias == "SAH"
		If cOperacao == "3"
			SAH->AH_XUSRIN := cDtTime
		EndIf
		SAH->AH_XUSRAL := cDtTime
	Case cAlias == "SA2"
		If cOperacao == "3"
			SA2->A2_XUSRIN := cDtTime
		EndIf
		SA2->A2_XUSRAL := cDtTime
	Case cAlias == "SBM"
		If cOperacao == "3"
			SBM->BM_XUSRIN := cDtTime
		EndIf
		SBM->BM_XUSRAL := cDtTime
	Case cAlias == "SED"
		If cOperacao == "3"
			SED->ED_XUSRIN := cDtTime
		EndIf
		SED->ED_XUSRAL := cDtTime
	Case cAlias == "CT1"
		If cOperacao == "3"
			CT1->CT1_XUSRIN := cDtTime
		EndIf
		CT1->CT1_XUSRAL := cDtTime
	Case cAlias == "P13"
		If cOperacao == "3"
			P13->P13_XUSRIN := cDtTime
		EndIf
		P13->P13_XUSRAL := cDtTime
	Case cAlias == "P14"
		If cOperacao == "3"
			P14->P14_XUSRIN := cDtTime
		EndIf
		P14->P14_XUSRAL := cDtTime
	Case cAlias == "P15"
		If cOperacao == "3"
			P15->P15_XUSRIN := cDtTime
		EndIf
		P15->P15_XUSRAL := cDtTime
	Case cAlias == "P16"
		If cOperacao == "3"
			P16->P16_XUSRIN := cDtTime
		EndIf
		P16->P16_XUSRAL := cDtTime
	Case cAlias == "P17"
		If cOperacao == "3"
			P17->P17_XUSRIN := cDtTime
		EndIf
		P17->P17_XUSRAL := cDtTime
	Case cAlias == "P24"
		If cOperacao == "3"
			P24->P24_XUSRIN := cDtTime
		EndIf
		P24->P24_XUSRAL := cDtTime
	Case cAlias == "P25"
		If cOperacao == "3"
			P25->P25_XUSRIN := cDtTime
		EndIf
		P25->P25_XUSRAL := cDtTime
	Case cAlias == "CVD"
		if cOperacao == "3"
			CVD->CVD_XUSRIN := cDtTime
		endif
		CVD_XUSRAL  := cDtTime
	Case cAlias == "CVE"
		if cOperacao == "3"
			CVE->CVE_XUSRIN := cDtTime
		endif
		CVE->CVE_XUSRAL := cDtTime
	Case cAlias == "CVF"
		if cOperacao == "3"
			CVF->CVF_XUSRIN := cDtTime
		endif
		CVF->CVF_XUSRAL := cDtTime
	Case cAlias == "FIL"
		if cOperacao == "3"
			FIL->FIL_XUSRIN := cDtTime
		endif
		FIL->FIL_XUSRAL := cDtTime
	Case cAlias == "SE4"
		if cOperacao == "3"
			SE4->E4_XUSRIN := cDtTime
		endif
		SE4->E4_XUSRAL := cDtTime
	Case cAlias == "P32"
		if cOperacao == "3"
			P32->P32_XUSRIN := cDtTime
		endif
		P32->P32_XUSRAL := cDtTime
	Case cAlias == "SBZ"
		if cOperacao == "3"
			SBZ->BZ_XUSRIN := cDtTime
		endif
		SBZ->BZ_XUSRAL := cDtTime
	Case cAlias == "SF4"
		if cOperacao == "3"
			SF4->F4_XUSRIN := cDtTime
		endif
		SF4->F4_XUSRAL := cDtTime
	Case cAlias == "CCQ"
		if cOperacao == "3"
			CCQ->CCQ_XUSRIN := cDtTime
		endif
		CCQ->CCQ_XUSRAL := cDtTime
	Case cAlias == "SNG"
		if cOperacao == "3"
			SNG->NG_XUSRIN := cDtTime
		endif
		SNG->NG_XUSRAL := cDtTime
	Case cAlias == "LHT"
		if cOperacao == "3"
			LHT->LHT_XUSRIN := cDtTime
		endif
		LHT->LHT_XUSRAL := cDtTime
	Case cAlias == "SEB"
		if cOperacao == "3"
			SEB->EB_XUSRIN := cDtTime
		endif
		SEB->EB_XUSRAL := cDtTime
	Case cAlias == "SEJ"
		if cOperacao == "3"
			SEJ->EJ_XUSRIN := cDtTime
		endif
		SEJ->EJ_XUSRAL := cDtTime
	Case cAlias == "CTD"
		if cOperacao == "3"
			CTD->CTD_XUSRIN := cDtTime
		endif
		CTD->CTD_XUSRAL := cDtTime
	Case cAlias == "CTS"
		if cOperacao == "3"
			CTS->CTS_XUSRIN := cDtTime
		endif
		CTS->CTS_XUSRAL := cDtTime
	Case cAlias == "CTT"
		if cOperacao == "3"
			CTT->CTT_XUSRIN := cDtTime
		endif
		CTT->CTT_XUSRAL := cDtTime
	EndCase

	MsUnLock()

Return
