#INCLUDE "totvs.ch"

/*/{Protheus.doc} LimCopart
Roteiro de Cálculo - Calcular Limite de Coparticipação - exclusivo para o Hospital Aliança e Café Navarre
@author luciano.camargo
@since 15/07/2021
@history 18/08/2021, Luciano.Camargo TOTVS, Ajuste para utilizar fBuscaPd() - Rotina deixou de ser roteiro PLA e virou FOL
@version 1.0
@type function
@obs lMsgInfo como .T. exibira o fluxo e os conteudos das variaveis a pedido dos analistas de negocio para testes
/*/
User Function LimCopart(lMsgInfo)

	Local cCdVerbDest  as char         // Codigo da verba (Limite de Coparticipação)
	Local cEmpCop   as char 		// Empresas da verba (Limite de Coparticipação)
	Local nValCop   as numeric      // Valor do Limite de Coparticipação
	Local aFaixa    as array		// Array com as faixas de dedução
	Local aArea 	:= GetArea()

	cRot := IIF( Empty(cRot), GETROTEXEC(), cRot )
	nValCop := 0
	aFaixa  := {}

	// Verificar existencia da tabela e vinculo ao hospital em processamento. Padrão: Hospital Aliança e Café Navarre
	cEmpCop  := AllTrim(SRA->RA_FILIAL)
	DbSelectArea("RCC")
	If RCC->(!DbSeek(xFilial("RCC")+"U050"+cEmpCop))
		RestArea(aArea) ; Return()
	Endif

	// Obter Dados da RCC
	While !RCC->(Eof()) .and. RCC_CODIGO == 'U050' .and. RCC_FIL == cEmpCop

		If lmsgInfo
			Msginfo("passou empresa")
		Endif

		// Verificar validade da tabela
		if Left(DtoS(dDatabase),6) >= Substr( RCC->RCC_CONTEU, 1,6 ) .and. Left(DtoS(dDatabase),6) <= Substr( RCC->RCC_CONTEU, 7,6 )

			If lmsgInfo
				Msginfo("passou validade")
			Endif

			// Verificar roteiro - Padrão PLA
			If cRot == Substr( RCC->RCC_CONTEU, 133,3 )

				If lmsgInfo
					Msginfo("passou roteiro")
				Endif

				// Verificar Existencia da Verba
				cCdVerbDest  := Substr( RCC->RCC_CONTEU, 136,3 )
				//cCdVerbOrig  := Substr( RCC->RCC_CONTEU, 139,3 )
				If !Empty( PosSrv(cCdVerbDest,SRA->RA_FILIAL,"RV_COD") )

					If lmsgInfo
						Msginfo("passou verba destino")
					Endif
					aFaixa := {}
					// Obter faixas de valores
					AADD( aFaixa, {Val(Substr( RCC->RCC_CONTEU, 013,12 )), Val(Substr( RCC->RCC_CONTEU, 025,12 ))})
					AADD( aFaixa, {Val(Substr( RCC->RCC_CONTEU, 037,12 )), Val(Substr( RCC->RCC_CONTEU, 049,12 ))})
					AADD( aFaixa, {Val(Substr( RCC->RCC_CONTEU, 061,12 )), Val(Substr( RCC->RCC_CONTEU, 073,12 ))})
					AADD( aFaixa, {Val(Substr( RCC->RCC_CONTEU, 085,12 )), Val(Substr( RCC->RCC_CONTEU, 097,12 ))})
					AADD( aFaixa, {Val(Substr( RCC->RCC_CONTEU, 109,12 )), Val(Substr( RCC->RCC_CONTEU, 121,12 ))})

					Calcula( aFaixa, cCdVerbDest, lmsgInfo )

				Endif

			EndIf

		EndIf

		RCC->(DbSkip())

	Enddo
	RestArea(aArea)

Return

Static Function Calcula( aFaixa, cCdVerbDest, lMsgInfo  )

	Local nIdx 		as numeric
	Local nValCop   as numeric      // Valor da coparticipação
	Local nDias		as numeric   	// Quantidade de dias correspondente ao valor calculado
	Local aArea     := GetArea()

	// Obter o valor cobrado da coparticipação
	nValCop := 0
	nSalFxValIni := 0
	nDias := 0
/*	cComppg := ""
	If FunName() $ "GPEM016/GPEM020"
		cComppg :=  MV_PAR03
	Endif
*/
	cTmpMatr 	:= SRA->RA_MAT
	cTmpFilial  := SRA->RA_FILIAL
	//RHR ou RHO
/*
	dBSelectArea("RHO")
	RHO->(dbSetOrder(2)) // FILIAL + MAT + COMPPG
	Msginfo("procurando RHO")
	If RHO->(DbSeek(cTmpFilial+cTmpMatr+cComppg))
		Msginfo("achou RHO")
		While RHO->(!Eof()) .and. RHO->RHO_COMPPG = cComppg .and. RHO->RHO_MAT = cTmpMatr .and. RHO->RHO_FILIAL = cTmpFilial
			Msginfo(RHO_PD)
			If AllTrim(RHO->RHO_PD) = AllTrim(cCdVerbOrig)
				nValCop := RHO->RHO_VLRFUN
			Endif
			RHO->(DbSkip())
		Enddo
	Endif
*/
// Houve mudança na importação do arquivo e agora o valor já está em verba

	nValCop := fBuscaPd(cCdVerbDest,"V")  // Obter Valor
	If nValCop < 0 // Atenção: Quando a verba é de desconto o valor retorna negativo
		nValCop := nValCop*-1
	Endif

	// Validar valor pago x valores das faixas conforme salario
	If nValCop != 0

		If lmsgInfo
			Msginfo("achou valor copart "+cvaltochar(nValCop))
		Endif
		For nIdx := 1 to Len(aFaixa)

			//TODO se ja estiver num valor correto, apenas salvar na nova verba destino

			If (SRA->RA_SALARIO >= nSalFxValIni) .AND. (SRA->RA_SALARIO <= aFaixa[nIdx,1])  ;
					.AND. ( nValCop > aFaixa[nIdx,2])

				If lmsgInfo
					Msginfo("entrou faixa "+cvaltochar(aFaixa[nIdx,1]))
				Endif
				// Sobrepor o valor

// Comentado em 18/08/2021 Quando o valor passou a ser gravado em Verba
/*				dBSelectArea("RHO")
				RHO->(dbSetOrder(2)) // FILIAL + MAT + COMPPG
				Msginfo("procurando RHO")
				If RHO->(DbSeek(cTmpFilial+cTmpMatr+cComppg))
					Msginfo("achou RHO")
					While RHO->(!Eof()) .and. RHO_COMPPG = cComppg .and. RHO_MAT = cTmpMatr .and. RHO_FILIAL = cTmpFilial
						Msginfo(RHO_PD)
						If AllTrim(RHO_PD) = AllTrim(cCdVerbOrig)
							RecLock("RHO",.F.)
							Msginfo("alterou RHO")
							RHO_PD := cCdVerbDest
							RHO_VLRFUN := aFaixa[nIdx,2]
							RHO->(MsUnlock())
						Endif
						RHO->(DbSkip())
					Enddo
				Endif

				dBSelectArea("RHR")
				RHR->(dbSetOrder(1)) // FILIAL + MAT + COMPPG
				msginfo("procurando RHR")
				If RHR->(DbSeek(cTmpFilial+cTmpMatr+cComppg))
					msginfo("achou RHR")
					While RHR->(!Eof()) .and. RHR_COMPPG = cComppg .and. RHR_MAT = cTmpMatr .and. RHR_FILIAL = cTmpFilial
						If RHR_PD = cCdVerbOrig
							msginfo("Alterou RHR")
							RecLock("RHR",.F.)
							RHR_PD := cCdVerbDest
							RHR_VLRFUN := aFaixa[nIdx,2]
							RHR->(MsUnlock())
						Endif
						RHR->(DbSkip())
					Enddo
				Endif
*/
				fDelPd(cCdVerbDest)
				fGeraVerba(cCdVerbDest,aFaixa[nIdx,2],nDias,,SRA->RA_CC,"V","I",0,,dDataBase,.T.)

				exit
			Endif
			nSalFxValIni := aFaixa[nIdx,1]
		Next nIdx
	Endif

	RestArea( aArea )

Return(.T.)
