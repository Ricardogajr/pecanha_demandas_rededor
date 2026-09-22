#INCLUDE "totvs.ch"

/*/{Protheus.doc} RDSLVB
Roteiro de Cálculo - Calcular Adicional de Jornada e Gratificação por Função - exclusivo para o Hospital Santa Cruz
@author luciano.camargo
@since 21/07/2021
@version 1.0
@type function
@history 30/07/2021, Luciano.Camargo TOTVS, Ajustes para configurar na RCC uma verba origem para calculo da verba destino
/*/
User Function RDSLVB(cRCB_Tab)

	Local cCodVerb  as char         // Codigo da verba (Adicional de Jornada e Gratificação por Função)
	Local cEmpRCB   as char 		// Empresas da verba (Adicional de Jornada e Gratificação por Função)
	Local nCargaHr  as numeric		// Carga Horaria
	Local cSindics  as char         // Códigos dos sindicatos
	Local cCargo    as char			// Cargo
	Local cCateg    as char			// Categoria funcional
	Local aArea 	:= GetArea()

	// U052 - Adicional de Jornada
	// U053 - Gratificação por Função

	Default cRCB_Tab := "U052"

	cRot := IIF( Empty(cRot), GETROTEXEC(), cRot )

	// Verificar existencia da tabela e vinculo ao hospital em processamento. Padrão: Hospital Santa Cruz
	cEmpRCB  := AllTrim(SRA->RA_FILIAL)
	DbSelectArea("RCC")
	If RCC->(!DbSeek(xFilial("RCC")+cRCB_Tab+cEmpRCB))
		RestArea(aArea) ; Return()
	Endif

	// Obter Dados da RCC
	While !RCC->(Eof()) .and. RCC_CODIGO == cRCB_Tab .and. RCC_FIL == cEmpRCB

//alert("passou empresa")
		// Verificar validade da tabela
		if Left(DtoS(dDatabase),6) >= Substr( RCC->RCC_CONTEU, 1,6 ) .and. Left(DtoS(dDatabase),6)  <= Substr( RCC->RCC_CONTEU, 7,6 )

//alert("passou validade")
			// Verificar roteiro
			If cRot == Substr( RCC->RCC_CONTEU, 13,3 )

//alert("passou roteiro")
				// Verificar existencia da Verba
				cCodVerb  := Substr( RCC->RCC_CONTEU, 16,3 )

				// Obter a verba origem/base para proporcional de dias/valor
				cCodBaseVerba  := Substr( RCC->RCC_CONTEU, 122,3 )

				If !Empty( PosSrv(cCodVerb,SRA->RA_FILIAL,"RV_COD") ) .and. !Empty(cCodBaseVerba)

					// Obter a carga horaria
					nCargaHr  := Val(Substr( RCC->RCC_CONTEU, 19,6 ))

					// Obter os codigos dos sindicatos
					cSindics  := Substr( RCC->RCC_CONTEU, 25,45 )

					// Obter a categoria funcional
					cCateg := Substr( RCC->RCC_CONTEU, 76,1 )

					// Obter os cargos / Funções
					cCargo := Substr( RCC->RCC_CONTEU, 77,45 )

					// Validar dados (carga horaria, categoria e sindicato) x funcionario
					If ( cCateg = SRA->RA_CATFUNC ) .AND. ( SRA->RA_CODFUNC $ cCargo ) .AND. ;
							( nCargaHr = SRA->RA_HRSEMAN ) .AND. ( SRA->RA_SINDICA $ cSindics )

//alert("passou cat / func / hor e sindicato")
						// Obter o percentual de aplicação
						nPerc  := Val(Substr( RCC->RCC_CONTEU, 70,6 ))

						Calcula( cCodVerb, nPerc, cRot, cCodBaseVerba )

					Endif
				Endif

			EndIf

		EndIf

		RCC->(DbSkip())

	Enddo
	RestArea(aArea)

Return

Static Function Calcula( cCodVerb, nPerc, cRot, cCodBaseVerba )

	Local nValVerb  as numeric      // Valor do Adicional de Jornada e Gratificação por Função
	Local nVal      as numeric		// Valor original para ser usado no calculo
	Local nDias		as numeric   	// Quantidade de dias correspondente ao valor calculado

	nVal := fBuscaPd(cCodBaseVerba,"V")  // Obter Valor
	nDias:= fBuscaPd(cCodBaseVerba,"H")  // Obter Dias
	nValVerb := ( nVal * (nPerc/100) )

//alert(nval)
//alert(ndias)
//alert(nValVerb)

	If nValVerb > 0

		fGeraVerba(cCodVerb,nValVerb,nDias,,SRA->RA_CC,"V","I",0,,dDataBase,.T.)

	Endif

Return(.T.)
