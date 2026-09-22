#INCLUDE "totvs.ch"

/*/{Protheus.doc} GRATASSID
Roteiro de Cálculo - Calcular Gratificação Assiduidade - exclusivo para o Hospital Aliança e Café Navarre
@author luciano.camargo
@since 15/07/2021
@version 1.0
@type function
@history 29/07/2021, Luciano.Camargo TOTVS, adaptação do código para uso da RCB/RCC
@obs lMsgInfo como .T. exibira o fluxo e os conteudos das variaveis a pedido dos analistas de negocio para testes
/*/
User Function GRATASSID(lmsgInfo)

	Local cCodVerb  	:= ""       // Codigo da verba (Gratificação Assiduidade)
	Local cEmpRCB   	:= ""   	// Empresas da verba (Gratificação Assiduidade)
	Local cDtAdmissa  	:= ""  		// Data admissão
	Local cSindics  	:= ""       // Códigos dos sindicatos
	Local nLimFaltas 	:= ""		// Limite de Faltas
	Local cTmpTab   	:= ""
	Local lTransf		:= .F.
	Local cTmpMatr	 	:= "" 		// Matricula
	Local cFilSRA       := "" 

	Local cAliasQry := GetNextAlias()
	Local aArea := GetArea()

	Default lmsgInfo := .F.

	cTmpTab := "U051"
	cRot := IIF( Empty(cRot), GETROTEXEC(), cRot )

	// Verificar existencia da tabela e vinculo ao hospital em processamento. Padrão: Hospital Aliança e Café Navarre
	cEmpRCB  := cFilAnt //AllTrim(SRA->RA_FILIAL) 
	DbSetOrder(1) 
	DbSelectArea("RCC")
	If RCC->(!DbSeek(xFilial("RCC")+cTmpTab+cEmpRCB)) 
		RestArea(aArea) ; Return()
	Endif

	// Obter Dados da RCC
	While !RCC->(Eof()) .and. RCC_CODIGO == cTmpTab //.and. RCC_FIL == cEmpRCB 
		// Verificar validade da tabela
		if Left(DtoS(dDatabase),6) >= Substr( RCC->RCC_CONTEU, 1,6 ) .and. Left(DtoS(dDatabase),6)  <= Substr( RCC->RCC_CONTEU, 7,6 )
			// Verificar roteiro
			If cRot == Substr( RCC->RCC_CONTEU, 13,3 ) // FER
				// Verificar existencia da Verba e obter o percentual de aplicacao
				cCodVerb  := Substr( RCC->RCC_CONTEU, 16,3 )
				nPerc := PosSrv(cCodVerb,SRA->RA_FILIAL,"RV_PERC")
				If !Empty( nPerc )
					// Obter a data de admissão até - 20181231
					cDtAdmissa  := Substr( RCC->RCC_CONTEU, 19,8 )

					// Obter os codigos dos sindicatos
					/* 
					68	SINDISAUDE BA
					70	SEEB - SIND DOS ENFERMEIROS ESTADO BA
					72	SINDIFITO - SINDICATO FISIOTERAPEUTA BA
					73	SINDIMAGEM - SIND DOS TEC E AUX RADIO BA
					75	SINDIPSI - SIND DOS PSIOCOLOGOS ESTADO BA
					76	SINDINUTRI - SIND DOS NUTRICIONISTA BA
					77	SASB - SIND DOS ASSISTENTES SOCIAIS BA
					*/
					cSindics  := Substr( RCC->RCC_CONTEU, 27,45 )

					// Obter o Limite de Faltas - 6
					nLimFaltas := Val(Substr( RCC->RCC_CONTEU, 72,3 ))

					// Validar dados (admissao e sindicato) x funcionario
					If 	( DtoS(SRA->RA_ADMISSA) <= cDtAdmissa ) .AND. ( SRA->RA_SINDICA $ cSindics )
						// Obter Faltas e proporcional de dias de férias
						nFaltas := RetFaltas( nLimFaltas, lmsgInfo )

						// Validar Faltas
						If ( nFaltas <= nLimFaltas )

							cFilSRA  := SRA->RA_FILIAL 
							cTmpMatr := SRA->RA_MAT
							cFilRCC  := RCC->RCC_FIL 
							// VERIFICO SE A FILIAL DO CÁLCULO É A MESMA DO PRÊMIO
							If cEmpRCB == cFilRCC
								// VERIFICO CASOS DE PAGAMENTO DE PRÊMIO PARA AS EXCEÇÕES - TRANSFERÊNCIAS
								BeginSql Alias cAliasQry
									SELECT COUNT(*) AS TOTAL FROM %table:SRE% SRE
									WHERE SRE.RE_FILIALP = %exp:cFilRCC% // VERIFICO SE A FILIAL DE DESTINO CONTÉM NA U051
									AND SRE.RE_MATD = %exp:cTmpMatr%    
									AND SRE.%notdel% 
								EndSql
								If (cAliasQry)->TOTAL >= 1 .And. SRA->RA_XASSID == 'S' 
									Calcula( cCodVerb, nPerc, nFaltas, nLimFaltas, lmsgInfo  )
									Return
								else
									// VERIFICO SE A FILIAL DE ORIGEM ESTÁ HABILITADA A RECEBER O PRÊMIO 
									If cFilSRA == cFilRCC .And. SRA->RA_XASSID == " "
										Calcula( cCodVerb, nPerc, nFaltas, nLimFaltas, lmsgInfo  )
										Return
									EndIf 
								Endif
								(cAliasQry)->(DbCloseArea())
							Endif
							
						Endif

					Endif

				Endif

			EndIf

		EndIf

		RCC->(DbSkip())

	Enddo
	RestArea(aArea)

Return

Static Function Calcula( cCodVerb, nPerc, nFaltas, nLimFaltas, lmsgInfo )

	Local nValGA	as numeric 	// Valor da Gratificação
	Local nFer		as numeric
	Local nFerSub	as numeric
	Local nPecu		as numeric
	Local nPecuSub	as numeric

	nValGA := 0

	// Ferias Picadas (Calcular Proporcional)
	// Ferias 20 dias + Abono 10 considerar como proporcional total
	nFer    := fBuscaPd(Substr( RCC->RCC_CONTEU, 75,3 ),"H")  	// Obter verba ferias = 195
	nFerSub := fBuscaPd(Substr( RCC->RCC_CONTEU, 78,3 ),"H")  	// Obter verba ferias mes seguinte = 200
	nPecu   := fBuscaPd(Substr( RCC->RCC_CONTEU, 81,3 ),"H")  	// Obter verba abono pecuniario = 016
	nPecuSub:= fBuscaPd(Substr( RCC->RCC_CONTEU, 84,3 ),"H") 	// Obter verba abono pecuniaria mes seguinte = 015

	nDiasProp := ( nFer + nFerSub + nPecu + nPecuSub )
	If lmsgInfo
		msgInfo(Substr( RCC->RCC_CONTEU, 75,3 )+' = '+cValtoChar(nFer) +chr(10)+chr(13)+;
			Substr( RCC->RCC_CONTEU, 78,3 )+" = "+cValToChar(nFerSub)+chr(10)+chr(13)+;
			Substr( RCC->RCC_CONTEU, 81,3 )+" = "+cValToChar(nPecu)+chr(10)+chr(13)+;
			Substr( RCC->RCC_CONTEU, 84,3 )+" = "+cValToChar(nPecuSub)+chr(10)+chr(13)+;
			'nDiasProp = '+cvaltochar(nDiasProp))
	Endif

	If nDiasProp > 30
		nDiasProp := 30
	Endif

	Conout("GratAssid() - Verba: "+cCodVerb+" Memoria calculo - RA_MAT "+SRA->RA_MAT)
	nValGA := ( ((SRA->RA_SALARIO/30)*nDiasProp) * (nPerc/100) )
	If lmsgInfo
		msgInfo("Valor Gratif. = "+cValToChar(nValGA) )
	Endif

	If nValGA > 0
		// Criar nova verba
		fGeraVerba(cCodVerb,nValGA,nDiasProp,,SRA->RA_CC,"V","I",0,,dDataBase,.T.)
	Endif

Return(.T.)


Static Function RetFaltas( nLimFaltas, lmsgInfo )

	Local nFaltas 	 as numeric // Dias de Faltas
	Local cTmpMatr	 as char 	// Matricula
	Local cTmpFilial as char
	Local cDatIni    as char
	Local cDatFim    as Char

	Local aArea     := GetArea()
	Local cAliasQry := GetNextAlias()

	nFaltas		:= 0
	cTmpMatr 	:= SRA->RA_MAT
	cTmpFilial  := SRA->RA_FILIAL

	BeginSql Alias cAliasQry

			SELECT RF_DATABAS, RF_DATAFIM, (RF_DFALVAT+RF_DFALAAT) AS TOTALFALTAS FROM %table:SRF% SRF
			WHERE SRF.RF_FILIAL = %exp:cTmpFilial% AND SRF.RF_MAT = %exp:cTmpMatr%
			AND SRF.RF_STATUS ='1'
			AND SRF.%notdel% 
			ORDER BY SRF.RF_DATABAS

	EndSql

	If !(cAliasQry)->(Eof())

		// Pegar periodo aquisitivo na SRF

		cDatIni 	:= (cAliasQry)->RF_DATABAS
		cDatFim 	:= (cAliasQry)->RF_DATAFIM
		nFaltas 	:= (cAliasQry)->TOTALFALTAS

		If lmsgInfo
			msgInfo("Periodo = "+cDatIni + " " + cDatFim)
			msgInfo("Faltas = "+cValToChar(nFaltas) )
		Endif

		/*
		RF_DATABAS - inicio período aquisitivo
		RF_DATAFIM - fim do período aquisitivo
		RF_STATUS = 1 - ativo

		somar
		RF_DFALVAT - Faltas vencidas
		RF_DFALAAT - Faltas proporcionais 
		*/

		If lmsgInfo
			msgInfo("RH_MAT "+M->RH_MAT)
		Endif

		If nFaltas <= nLimFaltas // Buscar os afastamentos apenas se o limite de faltas não foi ultrapassado

			(cAliasQry)->( DbCloseArea() )

			BeginSql Alias cAliasQry

			SELECT SUM( SR8.R8_DURACAO ) DIAS
			FROM %table:SR8% SR8
			WHERE SR8.R8_FILIAL = %exp:cTmpFilial% AND 
				SR8.R8_MAT = %exp:cTmpMatr%  AND 
				SR8.R8_DATAINI >= %exp:cDatIni%  AND 
				SR8.R8_DATAFIM <= %exp:cDatFim%  AND
				SR8.R8_TIPOAFA <> '001' AND 
				SR8.%notdel% 

			EndSql

			nFaltas += (cAliasQry)->DIAS
			If lmsgInfo
				msgInfo("Faltas + Afast.: "+cValToChar(nFaltas) )
			Endif

		Endif

	Endif

	(cAliasQry)->( DbCloseArea() )

	RestArea( aArea )

Return( nFaltas )
