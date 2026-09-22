#INCLUDE "totvs.ch"

/*/{Protheus.doc} GratTitula
Roteiro de Cálculo - Gratificação de Titulação - exclusivo para o Hospital São Carlos
@author luciano.camargo
@since 29/06/2021
@history 30/06/2021, Luciano.Camargo TOTVS, ajustes conforme solicitação.
@version 1.0
@obs <empresa>;<sindicato>;<funcao>;<grau>;<cargahoraria>;<verba>;<percentual>;<data corte>
@type function
@obs lMsgInfo como .T. exibira o fluxo e os conteudos das variaveis a pedido dos analistas de negocio para testes
@see PE_GP010AGRV / PE_GP180TRA / ADICESTIM / ADIC1ESTIM / FUNXCUR / GPE10MENU
/*/
User Function GratTitula(lmsgInfo)

	Local cCodVerb  	as char         // Codigo da verba (Gratificação Assiduidade)
	Local cEmpRCB   	as char 		// Empresas da verba (Gratificação Assiduidade)
	Local cSindics  	as char         // Códigos dos sindicatos
	Local lCodFunc  	as logical 		// Código da Função
	Local lTpCurso  	as logical		// Grau de Instrução
	Local lHrSeman  	as logical		// Carga Horaria Semanal
	Local cTmpTab  		as char
	Local nVlPiso		as numeric		// Valor do Piso por Função
	Local cTpValor		as char 
	Local aArea 		:= GetArea()

	Default lmsgInfo := .F.

	cTmpTab := "U056"
	cRot := IIF( Empty(cRot), GETROTEXEC(), cRot )

	// Verificar existencia da tabela e vinculo ao hospital em processamento. Padrão: Hospital Aliança e Café Navarre
	cEmpRCB  := AllTrim(SRA->RA_FILIAL)
	DbSelectArea("RCC")
	If RCC->(!DbSeek(xFilial("RCC")+cTmpTab+cEmpRCB)) // "04F60001;04F60002"
		RestArea(aArea) ; Return()
	Endif

	// Obter Dados da RCC
	While !RCC->(Eof()) .and. RCC_CODIGO == cTmpTab .and. RCC_FIL == cEmpRCB

		if lmsgInfo
			MsgInfo(ProcName()+" passou empresa")
		Endif

		// Verificar validade da tabela
		if Left(DtoS(dDatabase),6) >= Substr( RCC->RCC_CONTEU, 1,6 ) .and. Left(DtoS(dDatabase),6)  <= Substr( RCC->RCC_CONTEU, 7,6 )

			if lmsgInfo
				MsgInfo(ProcName()+" passou validade")
			Endif

			// Verificar roteiro
			If cRot $ AllTrim(Substr( RCC->RCC_CONTEU, 13,24 )) // FOL, RES, FER, 131, 132
				If lmsgInfo
					MsgInfo(ProcName()+" passou roteiro")
				Endif

				// Verificar existencia da Verba e obter o percentual de aplicacao
				cCodVerb  := Substr( RCC->RCC_CONTEU, 137,3 ) // 
				If !Empty( PosSrv(cCodVerb,SRA->RA_FILIAL,"RV_COD") )

					If lmsgInfo
						MsgInfo(ProcName()+" passou verba")
					Endif

					// Validar dados do funcionario
					cSindics  := AllTrim(Substr( RCC->RCC_CONTEU, 37,45 ))
					If 	( SRA->RA_SINDICA $ cSindics )

						If lmsgInfo
							MsgInfo(ProcName()+" Passou sindicato")
						Endif

						// Obter o percentual
						nPerc := Val(Substr( RCC->RCC_CONTEU, 134,3 ))

						// Validar dados do colaborador
						lCodFunc  := ( AllTrim(SRA->RA_CODFUNC) $ AllTrim(Substr( RCC->RCC_CONTEU, 82,45 )) )   // Codigo da Função

						lTpCurso  := ( RetCurso( SRA->RA_MAT, AllTrim(Substr( RCC->RCC_CONTEU,126,2 )), lMsgInfo) >= 1  )	// Tipo de Curso

						lHrSeman  := ( Val(Substr( RCC->RCC_CONTEU, 128,6 )) = SRA->RA_HRSEMANA )				// Carga Horaria Semanal

						If ( lCodFunc )

							If lmsgInfo
								MsgInfo(ProcName()+" Passou Função")
							Endif

							If ( lTpCurso )

								If lmsgInfo
									MsgInfo(ProcName()+" Passou Grau")
								Endif

								If ( lHrSeman )

									If lmsgInfo
										MsgInfo(ProcName()+" Passou Carga Horaria")
									Endif

									// Usa piso ou salario base
									cTpValor := Substr( RCC->RCC_CONTEU, 140,1 )

									// Efetuar Calculo
									nVlPiso  := ( Val(Substr( RCC->RCC_CONTEU, 141,12 )) )	
		
									Calcula( cCodVerb, nPerc, nVlPiso, cRot, cTpValor, lmsgInfo  )

								Endif

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


Static Function Calcula( cCodVerb, nPerc, nVlPiso, cRot, cTpValor, lmsgInfo )

	Local nValVerb  as numeric      // Valor do Adicional de Jornada e Gratificação por Função
	Local nVal      as numeric		// Valor original para ser usado no calculo
	Local nDiasProp as numeric 		//Quantidade de dias correspondente ao valor calculado
	Local nFer		as numeric
	Local nFerSub	as numeric
	Local nPecu		as numeric
	Local nPecuSub	as numeric
	Local nVlVb131	as numeric
	Local nVlVbAtual as numeric

	Local nValMes	as numeric
	Local nVlRes    as numeric
	Local nFerInd	as numeric
	Local nFerProp	as numeric
	Local n13Res	as numeric

	//nVal := IIF( SRA->RA_SALARIO <= nVlPiso, SRA->RA_SALARIO, nVlPiso )   // Obter Valor do salario base
	nVal := IIF( cTpValor=="1", SRA->RA_SALARIO, nVlPiso ) // Obter Valor base

	nDiasProp := 30
	nVlVb131 := 0

	nValMes := 0
	nVlRes	:= 0
	nFerInd := 0
	nFerProp:= 0
	n13Res	:= 0
	nVlVbAtual := 0

	If cRot = "RES" // Quando rescisão calcular propos

		nDiasProp := fBuscaPd(Substr( RCC->RCC_CONTEU, 153,3 ),"H") // Obter verba Saldo Salario = 319

		// Bloco retorna valor de mes
		nValMes := ( nVal / 12 )
		nFerInd  := (nValMes * Int(fBuscaPd(Substr( RCC->RCC_CONTEU, 174,3 ),"H"))) // Obter verba ferias indenizada = 199
		nFerProp := (nValMes * Int(fBuscaPd(Substr( RCC->RCC_CONTEU, 177,3 ),"H"))) // Obter verba ferias proporcional = 201
		n13Res   := (nValMes * Int(fBuscaPd(Substr( RCC->RCC_CONTEU, 180,3 ),"H"))) // Obter verba pagto 13o na rescisão = 014

		nFerInd := ( nFerInd * (nPerc/100) )
		nFerProp := ( nFerProp * (nPerc/100) )
		n13Res := ( n13Res * (nPerc/100) )

	ElseIf cRot = "FOL" // Folha

		nDiasProp := fBuscaPd(Substr( RCC->RCC_CONTEU, 168,3 ),"H")  	// Obter verba Saldo Salario = 001

	ElseIf cRot = "FER" 	// Ferias 20 dias + Abono 10 considerar como proporcional total

		nFer    := fBuscaPd(Substr( RCC->RCC_CONTEU, 156,3 ),"H")  	// Obter verba ferias = 195
		nFerSub := fBuscaPd(Substr( RCC->RCC_CONTEU, 159,3 ),"H")  	// Obter verba ferias mes seguinte = 200
		nPecu   := fBuscaPd(Substr( RCC->RCC_CONTEU, 162,3 ),"H")  	// Obter verba abono pecuniario = 016
		nPecuSub:= fBuscaPd(Substr( RCC->RCC_CONTEU, 165,3 ),"H") 	// Obter verba abono pecuniaria mes seguinte = 015

		nDiasProp := ( nFer + nFerSub + nPecu + nPecuSub )

		If ( fBuscaPd(Substr( RCC->RCC_CONTEU, 171,3 ),"V") != 0 )	// Obter valor verba 131 = 004
			nVlVb131 := ( nVal * (nPerc/100) )
		Endif

	Endif

	nValVerb := ( ((nVal/30)*nDiasProp) * (nPerc/100) ) + nVlVb131 + ( nFerInd + nFerProp + n13Res )

	If nValVerb != 0
		nVlVbAtual := fBuscaPd(cCodVerb,"V",,,"FOL")
		If lmsgInfo
			MsgInfo(ProcName()+	"nVlVb131 = "+cValToChar(nVlVb131)+Chr(10)+chr(13)+;
				"FerInd/FerProp/13Prop = "+cValToChar(( nFerInd + nFerProp + n13Res ))+Chr(10)+chr(13)+;
				"DiasProp = "+cValToChar(nDiasProp)+Chr(10)+chr(13)+;
				"Val.Atual = "+cValToChar(nVlVbAtual)+Chr(10)+chr(13)+;
				"Val.Verba = "+cValToChar(nValVerb))
		Endif

		If nValVerb > nVlVbAtual
			If nVlVbAtual != 0
				fDelPd(cCodVerb)
			Endif
			fGeraVerba(cCodVerb,nValVerb,nPerc,,SRA->RA_CC,"V","I",0,,dDataBase,.T.)
		Endif
	Endif

Return(.T.)

/*/{Protheus.doc} RetCursos
	(long_description)
	@type  Function
	@author user
	@since 09/09/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/

Static Function RetCurso(cMatr, cTpCurso, lMsgInfo)

	Local aArea := GetArea()
	Local nQtdCurso as numeric

	nQtdCurso := 0

	DbSelectArea("ZZD")
	ZZD->(DbSetOrder(1))
	if ZZD->( DbSeek(xFilial("ZZD")+cMatr))
		While ZZD->(!Eof()) .AND. ZZD->ZZD_MAT == cMatr
			If ZZD->ZZD_TPCUR = cTpCurso .and. ZZD->ZZD_ATIVO = '1'
				++nQtdCurso
			Endif
			ZZD->(DbSkip())
		Enddo
	endif
	RestArea(aArea)

Return( nQtdCurso )
