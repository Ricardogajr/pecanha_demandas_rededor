#INCLUDE "totvs.ch"

/*/{Protheus.doc} TempoServ
Roteiro de Cálculo - "Calcular Trienio personalizado - exclusivo para o Hospital SANTACRUZ"
@author luciano.camargo
@since 07/04/2021
@history 27/05/2021, Luciano.Camargo TOTVS, ajustes conforme solicitação.
@version 1.0
@obs A rotina pega o valores de duas verbas existentes (anuenio & trienio) já calculadas e gera um nova verba (tempo serviço)
@type function
/*/
User Function TempoServ()

	Local cCodSind  as char         // Codigo do Sindicato
	Local cCatFunc  as char         // Categoria Funcional
	Local cAdtPose  as char         // Adicional por tempo de serviço
	Local cCodTSD    as char         // Codigo da verba de tempo de serviço
	Local cCodTSO    as char         // Codigo da verba de tempo de serviço
	Local cEmpTS    as char 		// Empresa da verba de tempo de serviço
	Local nValTS    as numeric      // Valor do Tempo de Serviço
	Local nValTMP   as numeric      // Valor temporario da verba
	Local nIdx      as numeric
	Local cParam    as char			// Variavel temporaria de parametros
	Local aValTS    as array		// Array com os codigos das verbas de origem
	Local aArea 	:= GetArea()
	Local cPDTmp    as char

	Default cRoteiro := "FOL"

	cRot := IIF( Empty(cRot), GETROTEXEC(), cRot )
	nValTS := 0
	nValTMP := 0

	// Executa somente para a Filial SANTACRUZ
	cEmpTS  := SuperGetMV("RD_EPTS",.F.,"01F70001") // Codigo da Empresa Tempo de Serviço

	If SRA->RA_FILIAL <> cEmpTS
		RestArea(aArea) ; Return()
	EndIf

	// Recupera dados do funcionário
	cCodSind  := SRA->RA_SINDICA
	cCatFunc  := SRA->RA_CATFUNC // categoria M - Mensalista
	cAdtPose  := SRA->RA_ADTPOSE // $ T/A

	// Verificar o sindicato do funcionario
	If !(cCodSind $ '84/85') // Fazer somente para: SINDESC- SIND DOS EMPREGADOS SAUDE CTBA e SINDIFAR - SIND FARMACEUTICOS EST PARANA
		RestArea(aArea) ; Return()
	EndIf

	// Verificar categoria
	If !(cCatFunc $ 'M') // Mensalista
		RestArea(aArea) ; Return()
	EndIf

	// Verificar Adicional por tempo de serviço
	If At('T',cAdtPose)=0 .AND. At('A',cAdtPose)=0 .AND. At('B',cAdtPose)=0 // Trienio, Bienio e Anuenio
		RestArea(aArea) ; Return()
	EndIf

	// 6 roteiros
	// Ferias, 2 abono, 1 13, 2 13, folha/rescisao
	//Alert( cRot )
	cParam := "RD_TSD"+cRot
	cCodTSD := SuperGetMV(cParam,.F.,"999") // Codigo da Verba de destino Tempo de Serviço

	//Alert( cCodTSD )

	// Validar se a verba TS esta criada
	If Empty( PosSrv(cCodTSD,SRA->RA_FILIAL,"RV_COD") )
		Alert("Verba DESTINO ("+cCodTSD+") Tempo de Serviço não localizada") ; RestArea(aArea) ; Return()
	EndIf

	// Achar as verbas antigas, somar os valores
	cParam := "RD_TSO"+cRot
	cCodTSO := SuperGetMV(cParam,.F.,"338;325") // Codigo das Verbas de origem Tempo de Serviço
	//Alert( cCodTSO)

	aValTS := Separa( cCodTSO, ";" )
	For nIdx := 1 to Len(aValTS)
		cPDTmp := AllTrim(aValTS[nIdx])
		If !Empty(cPDTmp)
			If Empty( PosSrv(cPDTmp,SRA->RA_FILIAL,"RV_COD") )
				Alert("Verba ORIGEM ("+aValTS[nIdx]+") Tempo de Serviço não localizada") ; RestArea(aArea) ; Return()
			EndIf

			nValTMP := fBuscaPd(cPDTmp,"V")  // Anuenio, Trienio, Etc
			//Alert( nValTMP )
			nValTS += nValTMP
		Endif
	Next nIdx
	//Alert( nValTS )

	Conout("Roteiro TempoServ ("+cCodTSD+"): Memoria calculo - RA_MAT "+SRA->RA_MAT)

	If nValTS > 0

//		Conout("Valor Verba TempoServ ("+cCodTSD+"): "+cValToChar(nValTS)+" ( anuenio = "+cValTochar(nVal338)+" + trienio = "+cValToChar(nVal325)+" )")
		// Remover valores das verbas originais
		For nIdx := 1 to Len(aValTS)
			cPDTmp := AllTrim(aValTS[nIdx])
			//Alert(cPDTmp)
			fDelPd(cPDTmp)
		Next

		// Criar nova verba
		If !Empty(cCodTSD )
			//fGeraVerba(cCodTSD,nValTS,30,,SRA->RA_CC,"V","I",0,,dDtPago,.T.)
			fGeraVerba(cCodTSD,nValTS,30,,SRA->RA_CC,"V","I",0,,,.T.)
		EndIf 
	Endif

	RestArea(aArea)

Return
