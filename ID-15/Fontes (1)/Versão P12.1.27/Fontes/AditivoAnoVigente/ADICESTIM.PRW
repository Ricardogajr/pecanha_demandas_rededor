#INCLUDE "totvs.ch"

/*/{Protheus.doc} AdicEstim
Roteiro de Cálculo - Adicional de Estimulo - exclusivo para o Hospital São Carlos
@author luciano.camargo
@since 069/09/2021
@version 1.0
@obs <empresa>;<inicio>;<fim>;<roteiro>;<verba>;<% por curso>;<max cursos>;<funcao>
@type function
@see PE_GP010AGRV / PE_GP180TRA / GRATITULA / ADIC1ESTIM / FUNXCUR / GPE10MENU
@obs lMsgInfo como .T. exibira o fluxo e os conteudos das variaveis a pedido dos analistas de negocio para testes
/*/
User Function AdicEstim(lMsgInfo)

	Local cCodVerb  	as char         // Codigo da verba (Adicional de Estimulo)
	Local cEmpRCB   	as char 		// Empresas da verba (Adicional de Estimulo)
	Local lCodFunc  	as logical 		// Código da Função
	Local cTmpTab  		as char			// Codigo da tabela RCC
	Local cTpCurso		as char 		// Tipo Curso (tabela SX5 = ZB)
	Local cTpValor		as char 		// Tipo Valor (Salario Base ou Piso)
	Local aArea 		:= GetArea()

	Default lMsgInfo := .F.

	cTmpTab := "U057"
	cRot := IIF( Empty(cRot), GETROTEXEC(), cRot )

	// Verificar existencia da tabela e vinculo ao hospital em processamento. Padrão: Hospital Aliança e Café Navarre
	cEmpRCB  := AllTrim(SRA->RA_FILIAL)
	DbSelectArea("RCC")
	RCC->(DbSetOrder(1))
	If RCC->(!DbSeek(xFilial("RCC")+cTmpTab+cEmpRCB))
		RestArea(aArea) ; Return()
	Endif

	// Obter Dados da RCC
	While !RCC->(Eof()) .and. RCC_CODIGO == cTmpTab .and. RCC_FIL == cEmpRCB

		//MsgInfo( AllTrim(RCC->RCC_CONTEU))

		if lMsgInfo
			MsgInfo(ProcName()+" passou empresa")
		Endif

		// Verificar validade da tabela
		if Left(DtoS(dDatabase),6) >= Substr( RCC->RCC_CONTEU, 1,6 ) .and. Left(DtoS(dDatabase),6)  <= Substr( RCC->RCC_CONTEU, 7,6 )

			if lMsgInfo
				MsgInfo(ProcName()+" passou validade")
			Endif

			// Verificar roteiro
			If cRot $ AllTrim(Substr( RCC->RCC_CONTEU, 13,24 )) // FOL, RES, FER, 131, 132
				If lMsgInfo
					MsgInfo(ProcName()+" passou roteiro")
				Endif

				// Verificar existencia da Verba e obter o percentual de aplicacao
				cCodVerb := Substr( RCC->RCC_CONTEU, 37,3 )
				If !Empty( PosSrv(cCodVerb,SRA->RA_FILIAL,"RV_COD") )

					If lMsgInfo
						MsgInfo(ProcName()+" passou verba "+cCodVerb)
					Endif

					// Validar dados do colaborador
					lCodFunc := ( AllTrim(SRA->RA_CODFUNC) $ AllTrim(Substr( RCC->RCC_CONTEU, 47,45 )) )   // Codigo da Função

					If ( lCodFunc )

						If lMsgInfo
							MsgInfo(ProcName()+" Passou Função")
						Endif

						// Obter o percentual
						nPerc := Val(Substr( RCC->RCC_CONTEU, 40,6 ))

						// Obter limite de cursos
						nLimite := Val(Substr( RCC->RCC_CONTEU, 46,1 ))

						// Tipo curso
						cTpCurso := Substr( RCC->RCC_CONTEU, 137,1 )

						// Obter quantidade de cursos
						nCursos := RetCursos( SRA->RA_MAT, cTpCurso, lMsgInfo )

						// Usa piso ou salario base
						cTpValor := Substr( RCC->RCC_CONTEU, 138,1 )

						// Valor do Piso
						nVlPiso := Val(Substr( RCC->RCC_CONTEU, 139,12 ))

						// Efetuar Calculo
						Calcula( cCodVerb, nPerc, nCursos, nLimite, cTpValor, nVlPiso, cRot, lMsgInfo  )

					Endif

				Endif

			Endif

		EndIf

		RCC->(DbSkip())

	Enddo
	RestArea(aArea)

Return

/*/{Protin
	@author user
	@since 09/09/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
static Function Calcula( cCodVerb, nPerc, nCursos, nLimite, cTpValor, nVlPiso, cRot, lMsgInfo )

	Local nValVerb  as numeric      // Valor do Adicional de Estimulo
	Local nVal      as numeric		// Valor original para ser usado no calculo
	Local nDiasProp as numeric 		//Quantidade de dias correspondente ao valor calculado
	Local nFer		as numeric
	Local nFerSub	as numeric
	Local nPecu		as numeric
	Local nPecuSub	as numeric
	Local nVlVb131	as numeric

	Local nValMes	as numeric
	Local nVlRes    as numeric
	Local nFerInd	as numeric
	Local nFerProp	as numeric
	Local n13Res	as numeric

	nVal 	:= IIF( cTpValor=="1", SRA->RA_SALARIO, nVlPiso ) // Obter Valor base
	nDiasProp := 30
	nVlVb131 := 0

	nValMes := 0
	nVlRes	:= 0
	nFerInd := 0
	nFerProp:= 0
	n13Res	:= 0

	nCursos := IIF( nCursos > nLimite, nLimite, nCursos )    // Limite
	nPerc	:= (nPerc * nCursos) 							 // Calcular o percentual

	If cRot = "RES" // Quando rescisão calcular propos

		nDiasProp := fBuscaPd(Substr( RCC->RCC_CONTEU, 151,3 ),"H")  	// Obter verba Saldo Salario = 319
		// Bloco retorna valor de mes
		nValMes := ( nVal / 12 )
		nFerInd  := (nValMes * Int(fBuscaPd(Substr( RCC->RCC_CONTEU, 172,3 ),"H"))) // Obter verba ferias indenizada = 199
		nFerProp := (nValMes * Int(fBuscaPd(Substr( RCC->RCC_CONTEU, 175,3 ),"H"))) // Obter verba ferias proporcional = 201
		n13Res   := (nValMes * Int(fBuscaPd(Substr( RCC->RCC_CONTEU, 178,3 ),"H"))) // Obter verba pagto 13o na rescisão = 014

		nFerInd := ( nFerInd * (nPerc/100) )
		nFerProp := ( nFerProp * (nPerc/100) )
		n13Res := ( n13Res * (nPerc/100) )

	ElseIf cRot = "FOL" // Folha

		nDiasProp := fBuscaPd(Substr( RCC->RCC_CONTEU, 166,3 ),"H")  	// Obter verba Saldo Salario = 001

	ElseIf cRot = "FER" 	// Ferias 20 dias + Abono 10 considerar como proporcional total

		nFer    := fBuscaPd(Substr( RCC->RCC_CONTEU, 154,3 ),"H")  	// Obter verba ferias = 195
		nFerSub := fBuscaPd(Substr( RCC->RCC_CONTEU, 157,3 ),"H")  	// Obter verba ferias mes seguinte = 200
		nPecu   := fBuscaPd(Substr( RCC->RCC_CONTEU, 160,3 ),"H")  	// Obter verba abono pecuniario = 016
		nPecuSub:= fBuscaPd(Substr( RCC->RCC_CONTEU, 163,3 ),"H") 	// Obter verba abono pecuniaria mes seguinte = 015

		nDiasProp := ( nFer + nFerSub + nPecu + nPecuSub )

		If ( fBuscaPd(Substr( RCC->RCC_CONTEU, 169,3 ),"V") != 0 )	// Obter valor verba 131 = 004
			nVlVb131 := ( nVal * (nPerc/100) )
		Endif

	Endif

	nValVerb := ( ((nVal/30)*nDiasProp) * (nPerc/100) ) + nVlVb131 + ( nFerInd + nFerProp + n13Res )

	If lMsgInfo
		MsgInfo(ProcName()+" Valor Base = "+cValToChar(nval)+chr(10)+chr(13)+;
			"nVlVb131 = "+cValToChar(nVlVb131)+Chr(10)+chr(13)+;
			"DiasProp = "+cValToChar(nDiasProp)+Chr(10)+chr(13)+;
			"FerInd/FerProp/13Prop = "+cValToChar(( nFerInd + nFerProp + n13Res ))+Chr(10)+chr(13)+;
			"nPerc = "+cValToChar(nPerc)+Chr(10)+chr(13)+;
			"Valor = "+cValToChar(nValVerb))
	Endif

	//TODO Heitor retornar se nVlVb131 entra na mesma verba ou gerar nova

	If nValVerb > 0
		fGeraVerba(cCodVerb,nValVerb,nDiasProp,,SRA->RA_CC,"V","I",0,,dDataBase,.T.)
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
Static Function RetCursos(cMatr, cTpCurso, lMsgInfo)

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
