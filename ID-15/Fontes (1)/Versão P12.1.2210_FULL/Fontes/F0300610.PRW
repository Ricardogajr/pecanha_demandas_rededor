#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#include 'FILEIO.ch'

/*
{Protheus.doc} F0300610()
Exportação de Grupo Familiar
@Author     Rogerio Candisani
@Since      14/10/2016
@Version    P12.7
@Project    MAN00000463701_EF_006
@Return
*/
User Function F0300610()

	Local aArea		:= GetArea()
	Local cPerg		:= "FSW0300610"
	Local aSays		:= {}
	Local aButtons	:= {}
	Local nOpca		:= 0
	Local cCadastro	:= OemToAnsi("Mudança de Plano")

	Pergunte(cPerg,.F.)

	//AAdd(aSays,OemToAnsi("Este programa realiza o processo de geração do Holerite Eletrônico do Banco"))
	AAdd(aSays,OemToAnsi("Este programa realiza o processo de geração do arquivo de exportação"))

	AAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T.)  } } )
	AAdd(aButtons, { 1,.T.,{|o| nOpca := 1,If((MsgYesNo("Confirma a exportação da mudança de plano ?","Atenção")),FechaBatch(),nOpca:=0) }} )
	AAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )

	FormBatch(cCadastro,aSays,aButtons)

	If nOpca == 1
		Processa({|| F03006IMP(),"Gerando Exporta;áo"})
	EndIf

	RestArea(aArea)

Return

/*
{Protheus.doc} F03006IMP()
Exportação de Grupo Familiar
@Author     Rogerio Candisani
@Since      14/10/2016
@Version    P12.7
@Project    MAN00000463701_EF_006
@Return
*/
Static Function F03006IMP()

	Local ctmpTit    := ""
	Local ctmpDep    := ""
	Local cmontaTxt  := ""
	Local cPerg      := "FSW0300610"	// Gp. perguntas especifico
	Local cEstCivi   := ""
	Local cGrauPar   := ""
	Local cDescRcc   := ""
	Local cRACTDEPSA := ""
	Local nPos       := 0
	Local lGerou     := .F.
	Local aLinhas    := {}
	Local cMyPerINI  := ""
	Local cMyPerFIM  := ""

	//exportar os dados do grupo familiar em .CSV
	//criar pergunta F0300604

	/*	Exportação Grupo Familiar:
	MV_PAR01 Filial De		-> Filial De
	MV_PAR02 Filial Até		-> Filial Ate
	MV_PAR03 Matrícula De	-> Periodo Inicial De
	MV_PAR04 Matrícula Até	-> Periodo Inicial Ate
	MV_PAR05 Vigência De	-> Matricula De
	MV_PAR06 Vigência Até	-> Matricula Ate
	MV_PAR07 Tipo de Arquivo (Médico / Odontológico)
	MV_PAR08 Caminho de Gravação
	*/

	Pergunte(cPerg,.F.)

	cMyPerINI := SubStr(MV_PAR03,5,2)+SubStr(MV_PAR03,1,4) 
	cMyPerFIM := SubStr(MV_PAR04,5,2)+SubStr(MV_PAR04,1,4)
	
	//montar query do grupo familiar
	ctmpTit:=GetNextAlias()

	BeginSql Alias ctmpTit
	SELECT 	RA_FILIAL, RA_MAT, RA_NOME, RA_ADMISSA, RA_SEXO, RA_NASC, RA_CIC, RA_ESTCIVI, RA_MAE, RA_PIS, RA_RG,
			RA_RGORG, RA_DTRGEXP, RA_CC, RA_CARGO, RA_LOGRDSC, RA_ENDEREC, RA_LOGRNUM, RA_COMPLEM, RA_BAIRRO,
			RA_MUNICIP, RA_ESTADO, RA_CEP, RHK_PERINI, RA_BCDEPSA, RA_CTDEPSA, RHK_PLANO, RA_CODFUNC, RA_LOGRTP
	FROM %table:SRA% SRA
	Inner join %table:RHK% RHK ON
			RHK.RHK_MAT = SRA.RA_MAT AND
			RHK.%NotDel%
	WHERE SRA.RA_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
			AND SRA.RA_MAT BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
			AND RHK.RHK_PERINI BETWEEN %Exp:cMyPerINI% AND %Exp:cMyPerFIM%
			AND RHK.RHK_TPFORN = %Exp:MV_PAR07%
			AND RHK.RHK_XSTAT = "3"
			AND SRA.%NotDel%
	ORDER BY %Order:SRA%
	EndSql

	cMontaTxt:= ""
	// Cabeçalho
	cMontaTxt += "Tipo de alteracao;"            // 1  - Plano ou Cargo / Deve ser gerado duas linhas para cada colaborador informado, uma para o Plano e outra para o Cargo.
	cMontaTxt += "Nº da apólice/contrato;"       // 2  - Em branco
	cMontaTxt += "Nº Sub;"                       // 3  - Em branco
	cMontaTxt += "Operadora;"                    // 4  - Em branco
	cMontaTxt += "Inicio de Vigëncia;"           // 5  - RHK_PERINI e RHL_PERINI / A vigência será o registro seguinte aquele que serviu de base para os filtros
	cMontaTxt += "Matricula;"                    // 6  - RA_MAT
	cMontaTxt += "Certificado;"                  // 7  - Em branco
	cMontaTxt += "Nova Matricula;"               // 8  - RA_MAT
	cMontaTxt += "Novo Nº Centro de Custo;"      // 9  - RA_CC
	cMontaTxt += "Novo Nome Centro de Custo;"    // 10 - RA_CC / Buscar a descrição do CCusto
	cMontaTxt += "Novo Plano;"                   // 11 - RHK_PLANO / Trazer descrição da RCC – S008 (ou equivalente, conforme cadastro)
	cMontaTxt += "Nome Titular;"                 // 12 - RA_NOME
	cMontaTxt += "Nome correto Titular;"         // 13 - Em branco
	cMontaTxt += "Data de Nascimento;"           // 14 - Em branco
	cMontaTxt += "Data de Nascimento (Correta);" // 15 - RA_NASC
	cMontaTxt += "Estado civil;"                 // 16 - RA_ESTCIVI / Buscar descrição da SX5 – 33
	cMontaTxt += "CPF (Cadastrado);"             // 17 - Em branco
	cMontaTxt += "CPF (Correto);"                // 18 - RA_CIC
	cMontaTxt += "Nome correto da mãe;"          // 19 - RA_MAE
	cMontaTxt += "Tipo de logradouro;"           // 20 - RA_LOGRTP
	cMontaTxt += "Nome do logradouro;"           // 21 - RA_LOGRDSC
	cMontaTxt += "Número;"                       // 22 - RA_LOGRNUM
	cMontaTxt += "Complemento;"                  // 23 - RA_COMPLEM
	cMontaTxt += "Bairro;"                       // 24 - RA_BAIRRO
	cMontaTxt += "Cidade;"                       // 25 - RA_MUNICIP
	cMontaTxt += "Estado;"                       // 26 - RA_ESTADO
	cMontaTxt += "CEP;"                          // 27 - RA_CEP
	cMontaTxt += "Banco;"                        // 28 - RA_BCDEPSA / Cuidar para pegar as três primeiras posições
	cMontaTxt += "Agência;"                      // 29 - RA_BCDEPSA / Cuidar para pegar as posições a partir da 4ª.posição
	cMontaTxt += "Digito da Agencia;"            // 30 - Em branco
	cMontaTxt += "Conta corrente;"               // 31 - RA_CTDEPSA / Sem a última posição
	cMontaTxt += "Digito da conta corrente;"     // 32 - RA_CTDEPSA / Somente a última posição
	cMontaTxt += "Lote ou chamado;"              // 33 - Em branco
	cMontaTxt += "Documento;"                    // 34 - Em branco
	cMontaTxt += "Sequência;"                    // 35 - Em branco
	cMontaTxt += "Setor;"                        // 36 - Em branco
	cMontaTxt += "Lotação;"                      // 37 - Em branco
	cMontaTxt += "Local;"                        // 38 - Em branco
	cMontaTxt += "Unidade de atendimento;"       //-39 - Em branco
	cMontaTxt += "Unidade de negociação;"        //-40 - Em branco
	cMontaTxt += CHR(13) + CHR(10)

	AAdd(aLinhas, cMontaTxt)

	DbSelectArea(ctmpTit)
	ProcRegua((ctmpTit)->(LASTREC()))
	(ctmpTit)->(DbGoTop())

	While ! (ctmpTit)->(EOF())
		lGerou := .T.
		IncProc((ctmpTit)->RA_NOME)
		//monta o txt do titular
		cMontaTxt := ""
		If MV_PAR07 == 1
			nPos := fPosTab("S008", (ctmpTit)->RHK_PLANO, "=", 4)
			If nPos > 0
				cDescRcc := fTabela( "S008",nPos,5)
			ELSE
				cDescRcc := ""
			EndIf
		Else
			nPos := fPosTab("S013", (ctmpTit)->RHK_PLANO, "=", 4)
			If nPos > 0
				cDescRcc := fTabela( "S013",nPos,5)
			ELSE
				cDescRcc := ""
			EndIf		
		EndIf
		cMontaTxt += "PLANO;"                               // 1
		cMontaTxt += ";"                                                                       // 2
		cMontaTxt += ";"                                                                       // 3
		cMontaTxt += ";"                                                                       // 4
		cMontaTxt += "01/"+Substr((ctmpTit)->RHK_PERINI,1,2) + "/" + Substr((ctmpTit)->RHK_PERINI,3,4) + ";"                                               // 5
		cMontaTxt += (ctmpTit)->RA_MAT + ";"                                                   // 6 Matricula
		cMontaTxt +=";"                                                                        // 7
		cMontaTxt += (ctmpTit)->RA_MAT + ";"                                                   // 8
		cMontaTxt += (ctmpTit)->RA_CC  + ";"                                                   // 9
		cMontaTxt += Posicione("CTT",1,xFilial("CTT") + (ctmpTit)->RA_CC,"CTT_DESC01") + ";"   // 10
		If MV_PAR07 == 1
			nPos := fPosTab("S008", (ctmpTit)->RHK_PLANO, "=", 4)
			If nPos > 0
				cDescRcc := fTabela( "S008",nPos,5)
			ELSE
				cDescRcc := ""
			EndIf
		Else
			nPos := fPosTab("S013", (ctmpTit)->RHK_PLANO, "=", 4)
			If nPos > 0
				cDescRcc := fTabela( "S013",nPos,5)
			ELSE
				cDescRcc := ""
			EndIf		
		EndIf
		cMontaTxt += (ctmpTit)->RHK_PLANO + "/" + cDescRcc + ";"                               // 11
		cMontaTxt += (ctmpTit)->RA_NOME + ";"                                                  // 12
		cMontaTxt += ";"                                                                       // 13
		cMontaTxt += ";"                                                                       // 14
		cMontaTxt += (ctmpTit)->RA_NASC + ";"                                                  // 15
		Do Case
			Case (ctmpTit)->RA_ESTCIVI == "C"
			cEstCivi:= "Casado(a)"
			Case (ctmpTit)->RA_ESTCIVI == "D"
			cEstCivi:= "Divorciado(a)"
			Case (ctmpTit)->RA_ESTCIVI == "M"
			cEstCivi:= "União Estável"
			Case (ctmpTit)->RA_ESTCIVI == "Q"
			cEstCivi:= "Desquitado(a)"
			Case (ctmpTit)->RA_ESTCIVI == "S"
			cEstCivi:= "Solteiro(a)"
			Case (ctmpTit)->RA_ESTCIVI == "V"
			cEstCivi:= "Viúvo(a)"
		EndCase
		cMontaTxt += cEstCivi  + ";"                                                           // 16
		cMontaTxt += ";"                                                                       // 17
		cMontaTxt += (ctmpTit)->RA_CIC + ";"                                                   // 18
		cMontaTxt += (ctmpTit)->RA_MAE + ";"                                                   // 19
		cMontaTxt += (ctmpTit)->RA_LOGRTP  + ";"                                               // 20
		cMontaTxt += (ctmpTit)->RA_LOGRDSC + ";"                                               // 21
		cMontaTxt += (ctmpTit)->RA_LOGRNUM + ";"                                               // 22
		cMontaTxt += (ctmpTit)->RA_COMPLEM + ";"                                               // 23
		cMontaTxt += (ctmpTit)->RA_BAIRRO  + ";"                                               // 24
		cMontaTxt += (ctmpTit)->RA_MUNICIP + ";"                                               // 25
		cMontaTxt += (ctmpTit)->RA_ESTADO  + ";"                                               // 26
		cMontaTxt += (ctmpTit)->RA_CEP     + ";"                                               // 27
		cMontaTxt += Subs((ctmpTit)->RA_BCDEPSA,1,3) + ";"                                     // 28
		cMontaTxt += Subs((ctmpTit)->RA_BCDEPSA,4,5) + ";"                                     // 29
		cMontaTxt += ";"                                                                       // 30
		cRACTDEPSA := Alltrim((ctmpTit)->RA_CTDEPSA)
		cMontaTxt += Subs(cRACTDEPSA,1,LEN(cRACTDEPSA)-1) + ";"                                // 31
		cMontaTxt += Right(ALLTRIM(cRACTDEPSA), 1 ) + ";"                                      // 32
		cMontaTxt += ";"                                                                       // 33
		cMontaTxt += ";"                                                                       // 34
		cMontaTxt += ";"                                                                       // 35
		cMontaTxt += ";"                                                                       // 36
		cMontaTxt += ";"                                                                       // 37
		cMontaTxt += ";"                                                                       // 38
		cMontaTxt += ";"                                                                       // 39
		cMontaTxt += ";"                                                                       // 40
		cMontaTxt += CHR(13) + CHR(10)
		AAdd(aLinhas, cMontaTxt)
		(ctmpTit)->(dBSkip())
	Enddo

	(ctmpTit)->(DbGoTop())

	While ! (ctmpTit)->(EOF())
		lGerou := .T.
		IncProc((ctmpTit)->RA_NOME)
		//monta o txt do titular
		cMontaTxt := ""
		cMontaTxt += "CARGO;"                               // 1
		cMontaTxt += ";"                                                                       // 2
		cMontaTxt += ";"                                                                       // 3
		cMontaTxt += ";"                                                                       // 4
		cMontaTxt += "01/"+Substr((ctmpTit)->RHK_PERINI ,1,2) + "/" + Substr((ctmpTit)->RHK_PERINI ,3,4)+ ";"                                               // 5
		cMontaTxt += (ctmpTit)->RA_MAT + ";"                                                   // 6 Matricula
		cMontaTxt +=";"                                                                        // 7
		cMontaTxt += (ctmpTit)->RA_MAT + ";"                                                   // 8
		cMontaTxt += (ctmpTit)->RA_CC  + ";"                                                   // 9
		cMontaTxt += Posicione("CTT",1,xFilial("CTT") + (ctmpTit)->RA_CC,"CTT_DESC01") + ";"   // 10
		nPos := fPosTab("S008", (ctmpTit)->RHK_PLANO, "=", 4)
		If MV_PAR07 == 1
			nPos := fPosTab("S008", (ctmpTit)->RHK_PLANO, "=", 4)
			If nPos > 0
				cDescRcc := fTabela( "S008",nPos,5)
			ELSE
				cDescRcc := ""
			EndIf
		Else
			nPos := fPosTab("S013", (ctmpTit)->RHK_PLANO, "=", 4)
			If nPos > 0
				cDescRcc := fTabela( "S013",nPos,5)
			ELSE
				cDescRcc := ""
			EndIf		
		EndIf
		cMontaTxt += (ctmpTit)->RHK_PLANO + "/" + cDescRcc + ";"                               // 11
		cMontaTxt += (ctmpTit)->RA_NOME + ";"                                                  // 12
		cMontaTxt += ";"                                                                       // 13
		cMontaTxt += ";"                                                                       // 14
		cMontaTxt += (ctmpTit)->RA_NASC + ";"                                                  // 15
		Do Case
			Case (ctmpTit)->RA_ESTCIVI == "C"
			cEstCivi:= "Casado(a)"
			Case (ctmpTit)->RA_ESTCIVI == "D"
			cEstCivi:= "Divorciado(a)"
			Case (ctmpTit)->RA_ESTCIVI == "M"
			cEstCivi:= "União Estável"
			Case (ctmpTit)->RA_ESTCIVI == "Q"
			cEstCivi:= "Desquitado(a)"
			Case (ctmpTit)->RA_ESTCIVI == "S"
			cEstCivi:= "Solteiro(a)"
			Case (ctmpTit)->RA_ESTCIVI == "V"
			cEstCivi:= "Viúvo(a)"
		EndCase
		cMontaTxt += cEstCivi  + ";"                                                           // 16
		cMontaTxt += ";"                                                                       // 17
		cMontaTxt += (ctmpTit)->RA_CIC + ";"                                                   // 18
		cMontaTxt += (ctmpTit)->RA_MAE + ";"                                                   // 19
		cMontaTxt += (ctmpTit)->RA_LOGRTP  + ";"                                               // 20
		cMontaTxt += (ctmpTit)->RA_LOGRDSC + ";"                                               // 21
		cMontaTxt += (ctmpTit)->RA_LOGRNUM + ";"                                               // 22
		cMontaTxt += (ctmpTit)->RA_COMPLEM + ";"                                               // 23
		cMontaTxt += (ctmpTit)->RA_BAIRRO  + ";"                                               // 24
		cMontaTxt += (ctmpTit)->RA_MUNICIP + ";"                                               // 25
		cMontaTxt += (ctmpTit)->RA_ESTADO  + ";"                                               // 26
		cMontaTxt += (ctmpTit)->RA_CEP     + ";"                                               // 27
		cMontaTxt += Subs((ctmpTit)->RA_BCDEPSA,1,3) + ";"                                     // 28
		cMontaTxt += Subs((ctmpTit)->RA_BCDEPSA,4,5) + ";"                                     // 29
		cMontaTxt += ";"                                                                       // 30
		cRACTDEPSA := Alltrim((ctmpTit)->RA_CTDEPSA)
		cMontaTxt += Subs(cRACTDEPSA,1,LEN(cRACTDEPSA)-1) + ";"                                // 31
		cMontaTxt += Right(ALLTRIM(cRACTDEPSA), 1 ) + ";"                                      // 32
		cMontaTxt += ";"                                                                       // 33
		cMontaTxt += ";"                                                                       // 34
		cMontaTxt += ";"                                                                       // 35
		cMontaTxt += ";"                                                                       // 36
		cMontaTxt += ";"                                                                       // 37
		cMontaTxt += ";"                                                                       // 38
		cMontaTxt += ";"                                                                       // 39
		cMontaTxt += ";"                                                                       // 40
		cMontaTxt += CHR(13) + CHR(10)
		AAdd(aLinhas, cMontaTxt)
		(ctmpTit)->(dBSkip())
	Enddo


	//fechar arquivos temporarios
	(ctmpTit)->(DbCloseArea())

	//gerar o arquivo
	If lgerou
		criaCSV(aLinhas)
	Else
		MsgAlert("Não existem dados a serem gerados, verifique os parametros utilizados")
	Endif

	aLinhas := ASize(aLinhas, 0)
	aLinhas := Nil
Return 

/*
{Protheus.doc} criaCSV()
Exportando dados para planilha
@Author     Rogerio Candisani
@Since      14/10/2016
@Version    P12.7
@Project    MAN00000463701_EF_006
@Param      aLinhas, array, array contendo as linhas de impressão
@Return
*/
Static Function criaCSV(aLinhas)
	Local lRet  := .T.
	Local nRec  := 0
	Local nX

	// Nome do arquivo criado, o nome é composto por umam descrição
	//a data e a hora da criação, para que não existam nomes iguais
	cNomeArq := alltrim(MV_PAR08) + ".csv"

	If FILE(cNomeArq)
		If (MsgYesNo(OemToAnsi("Arquivo já existe substituir ?"),OemToAnsi("Atencao")))
			lRet:= .T.
			FERASE(cNomeArq)
			nHandle := FCREATE(cNomeArq)
		Else
			lRet:= .F.
			nHandle := FOPEN(cNomeArq)
		Endif
	Else
		// criar arquivo texto vazio a partir do root path no servidor
		nHandle := FCREATE(cNomeArq)
	EndIf

	If lRet
		nRec := FT_FLastRec()
		FSEEK(nHandle, nRec)

		For nX:= 1 to Len(aLinhas)
			FWrite(nHandle,aLinhas[nX])
		Next

		// encerra gravação no arquivo
		FClose(nHandle)
		MsgAlert("Arquivo salvo em : " + cNomeArq)
		//FOPEN(cNomeArq, FO_READWRITE)
	EndIf
Return
