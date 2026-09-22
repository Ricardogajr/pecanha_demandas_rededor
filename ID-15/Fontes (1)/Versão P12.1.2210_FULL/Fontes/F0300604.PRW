#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#include 'FILEIO.ch'

/*
{Protheus.doc} F0300604()
Exportação de Grupo Familiar
@Author     Rogerio Candisani
@Since      14/10/2016
@Version    P12.7
@Project    MAN00000463701_EF_006
@Return
*/
/*
Alterado em: 02/09/24
Por: Mauricio Siqueira
Solicitação: RITM0459451
Motivo: Trocar o campo RA_NOME por RA_NOMECMP
*/
User Function F0300604()
	
	Local aArea		:= GetArea()
	Local cPerg		:= "FSW0300604"
	Local aSays		:= {}
	Local aButtons	:= {}
	Local nOpca		:= 0
	Local cCadastro	:= OemToAnsi("Exportação de Grupo Familiar")

	Pergunte(cPerg,.F.)
			
	//AAdd(aSays,OemToAnsi("Este programa realiza o processo de geração do Holerite Eletrônico do Banco"))
	AAdd(aSays,OemToAnsi("Este programa realiza o processo de geração do arquivo de exportação"))
	
	AAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T.)  } } )
	AAdd(aButtons, { 1,.T.,{|o| nOpca := 1,If((MsgYesNo("Confirma a exportação do grupo familiar ?","Atenção")),FechaBatch(),nOpca:=0) }} )
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
	Local cPerg      := "FSW0300604"	// Gp. perguntas especifico
	Local cEstCivi   := ""
	Local cGrauPar   := ""
	Local cDescRcc   := ""
	Local cRACTDEPSA := ""
	Local nPos       := 0
	Local lGerou     := .F.
	Local aLinhas    := {}
	Local cMyPerINI  := ""
	Local cMyPerFIM  := ""
	Local nQtd
	//exportar os dados do grupo familiar em .CSV
	//criar pergunta F0300604
	
	/*	Exportação Grupo Familiar:
	MV_PAR01 Filial De		-> Filial De
	MV_PAR02 Filial Até		-> Filial Ate
	MV_PAR03 Matrícula De	-> Periodo Inicial De
	MV_PAR04 Matrícula Até	-> Periodo Inicial Ate
	MV_PAR05 Admissão De	-> Admissao De
	MV_PAR06 Admissão ate	-> Admissao Ate
	MV_PAR07 Vigência De	-> Matricula De
	MV_PAR08 Vigência Até	-> Matricula Ate
	MV_PAR09 Tipo de Arquivo (Médico / Odontológico)
	MV_PAR10 Caminho de Gravação
	*/
	
	//	As Colunas 1, 2, 3, 4, 7, 15 e 32 - Informar somente a coluna, o dado será vazio;
	//	A Coluna 5 deverá ser verificado no parâmetro de geração, informando o conteúdo 5 para Plano de Saúde ou 6 para Plano Odontológico;
	// A Coluna 14 – Quando for informações do Titular, informar fixo "Titular", quando for dependente, buscar a informação no campo RB_GRAUPAR;
	// As Colunas que foram indicadas para serem geradas “em branco” terão dados informados manualmente pela equipe de benefícios;
	// Os tamanhos das colunas são livres, e deverão ser separados por ";"
	
	Pergunte(cPerg,.F.)
	
	cMyPerINI := SubStr(MV_PAR03,5,2)+SubStr(MV_PAR03,1,4) 
	cMyPerFIM := SubStr(MV_PAR04,5,2)+SubStr(MV_PAR04,1,4)
	
	//montar query do grupo familiar
	ctmpTit:=GetNextAlias()
	// ticket n° 3834093 - 415966 - Paulo Dias - ajuste query para campo CNS
	BeginSql Alias ctmpTit
		SELECT RA_FILIAL, RA_MAT, RA_NOMECMP, RA_ADMISSA, RA_SEXO, RA_NASC, RA_CIC, RA_ESTCIVI, RA_MAE, RA_PIS, RA_RG,
				RA_RGORG, RA_DTRGEXP, RA_CC, RA_CARGO, RA_LOGRDSC, RA_ENDEREC, RA_LOGRNUM, RA_COMPLEM, RA_BAIRRO,
				RA_MUNICIP, RA_ESTADO, RA_CEP, RA_XCNS, RHK_PERINI, RA_BCDEPSA, RA_CTDEPSA, RHK_PLANO, RA_CODFUNC, RA_LOGRTP
		FROM %table:SRA% SRA
		Inner join %table:RHK% RHK ON
				RHK.RHK_MAT = SRA.RA_MAT AND
				RHK.RHK_XSTAT = "1" AND
				RHK.%NotDel%
		WHERE SRA.RA_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
				AND SRA.RA_MAT BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
				AND SRA.RA_ADMISSA BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
				AND RHK.RHK_PERINI BETWEEN %Exp:cMyPerINI% AND %Exp:cMyPerFIM%
				AND RHK.RHK_TPFORN = %Exp:MV_PAR09%
				AND SRA.%NotDel%
		ORDER BY %Order:SRA%
	EndSql
	
	cMontaTxt:= ""
	// Cabeçalho
	cMontaTxt += "Operadora;"                // 1
	cMontaTxt += "Nº da apólice/contrato;"   // 2
	cMontaTxt += "Nº Sub;"                   // 3
	cMontaTxt += "Inicio de Vigência;"       // 4
	cMontaTxt += "Codigo/Nome plano;"        // 5 Codigo nome plano
	cMontaTxt += "Matricula;"                // 6 Matricula
	cMontaTxt += "Código Dependente;"        // 7
	cMontaTxt += "Data de admissão;"         // 8 Data admissão ,Informar a data DD/MM/AAAA
	cMontaTxt += "Nome Segurado;"            // 9 Nome do segurado
	cMontaTxt += "Sexo;"                     // 10 Sexo , Masculino ou Feminino
	cMontaTxt += "Data de Nascimento;"       // 11 Data nascimento , Informar a data DD/MM/AAAA
	cMontaTxt += "N. CPF;"                   // 12 N. CPF , Informar o CPF beneficiario, se menos de 18 anos CPF nao deve ser preenchido
	cMontaTxt += "Estado civil;"             // 13  Estado civil , Casado(a),Solteiro(a), União Estável, Separado(a),Viúvo(a),Divorciado(a)
	cMontaTxt += "Grau de parentesco;"       // 14 Grau de parentesco ,Quando for informações do Titular, informar fixo "Titular"
	cMontaTxt += "Data do Casamento;"        // 15
	cMontaTxt += "Nome da Mãe;"              // 16 Nome da mãe , informação nome da mãe completo
	cMontaTxt += "PIS;"                      // 17 PIS , preencher somente para o titular
	cMontaTxt += "RG;"                       // 18 RG , se tiver informação preencher
	cMontaTxt += "Orgão emissor;"            // 19 Orgão emissor , se tiver informação preencher
	cMontaTxt += "Data de expedição;"        // 20 Data de expedição, se tiver informação preencher
	cMontaTxt += "Centro de custo;"          // 21 Centro de custo, se tiver informação preencher
	cMontaTxt += "Nome C. de custo;"         // 22 Nome C. de custo , se tiver informação preencher
	cMontaTxt += "Cargo;"                    // 23 Cargo , se tiver informação preencher
	cMontaTxt += "Tipo de logradouro;"       // 24 Tipo de logradouro , Rua, Avenida
	cMontaTxt += "Nome do logradouro;"       // 25 Nome do logradouro
	cMontaTxt += "Numero;"                   // 26 Numero ,numero
	cMontaTxt += "Compl. Numero;"            // 27 Compl. Numero
	cMontaTxt += "Bairro;"                   // 28 Bairro
	cMontaTxt += "Cidade;"                   // 29 Cidade
	cMontaTxt += "Estado;"                   // 30 Estado
	cMontaTxt += "CEP;"                      // 31 CEP
	cMontaTxt += "Cartão Nacional de Saúde;" // 32 CNS
	cMontaTxt += "Banco;"                    // 33 Banco ,informar o banco para reembolso
	cMontaTxt += "Agencia;"                  // 34 Agencia , informar a agencia para reembolso
	cMontaTxt += "Dig. Agencia;"             // 35 Dig. Agencia , informar a digito da agencia para reembolso
	cMontaTxt += "Conta corrente;"           // 36 Conta corrente  , informar a conta corrente
	cMontaTxt += "Digito da Conta corrente;" // 37 Digito Conta corrente
	cMontaTxt += "Numero de Nascido Vivo;"   // 38
	cMontaTxt += "Lote ou Chamado;"          //-39-Em branco
	cMontaTxt += "Documento;"                //-40-Em branco
	cMontaTxt += "Sequencia;"                //-41-Em branco
	cMontaTxt += "Setor;"                    //-42-Em branco
	cMontaTxt += "Lotacao;"                  //-43-Em branco
	cMontaTxt += "Local;"                    //-44-Em branco
	cMontaTxt += "Unidade de Atendimento;"   //-45-Em branco
	cMontaTxt += "Unidade de Negociacao;"    //-46-Em branco
	cMontaTxt += CHR(13) + CHR(10)
	
	AAdd(aLinhas, cMontaTxt)
	
	DbSelectArea(ctmpTit)
	ProcRegua((ctmpTit)->(LASTREC()))
	(ctmpTit)->(DbGoTop())
	
	While ! (ctmpTit)->(EOF())
		lGerou := .T.
		IncProc((ctmpTit)->RA_NOMECMP)
		//monta o txt do titular
		cMontaTxt := ""
		cMontaTxt += ";"                                       // 1
		cMontaTxt += ";"                                       // 2
		cMontaTxt += ";"                                       // 3
		cMontaTxt += "01/"+Substr((ctmpTit)->RHK_PERINI,1,2) + "/" + Substr((ctmpTit)->RHK_PERINI,3,4) + ";"               // 4
		If MV_PAR09 == 1
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
		cMontaTxt += (ctmpTit)->RHK_PLANO + "/" + cDescRcc + ";"// 5 Codigo nome plano
		cMontaTxt += (ctmpTit)->RA_MAT + ";"                    // 6 Matricula
		cMontaTxt += "00;"                                      // 7
		cMontaTxt += subst((ctmpTit)->RA_ADMISSA,7,2) + "/" + subst((ctmpTit)->RA_ADMISSA,5,2) + "/" + subst((ctmpTit)->RA_ADMISSA,1,4) + ";" // 8 Data admissão ,Informar a data DD/MM/AAAA
		cMontaTxt += (ctmpTit)->RA_NOMECMP + ";"                   //9 Nome do segurado
		cMontaTxt += IIF((ctmpTit)->RA_SEXO == "M","Masculino","Feminino") + ";" // 10 Sexo , Masculino ou Feminino
		cMontaTxt += subst((ctmpTit)->RA_NASC,7,2) + "/" + subst((ctmpTit)->RA_NASC,5,2) + "/" + subst((ctmpTit)->RA_NASC,1,4) + ";" // 11 Data nascimento , Informar a data DD/MM/AAAA
		cMontaTxt += (ctmpTit)->RA_CIC  + ";"                   // 12 N. CPF , Informar o CPF beneficiario, se menos de 18 anos CPF nao deve ser preenchido
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
		cMontaTxt += cEstCivi  + ";"                            // 13  Estado civil , Casado(a),Solteiro(a), União Estável, Separado(a),Viúvo(a),Divorciado(a)
		cMontaTxt += "Titular" + ";"                            // 14 Grau de parentesco ,Quando for informações do Titular, informar fixo "Titular"
		cMontaTxt += ";"                                        // 15
		cMontaTxt += (ctmpTit)->RA_MAE   + ";"                  // 16 Nome da mãe , informação nome da mãe completo
		cMontaTxt += (ctmpTit)->RA_PIS   + ";"                  // 17 PIS , preencher somente para o titular
		cMontaTxt += (ctmpTit)->RA_RG    + ";"                  // 18 RG , se tiver informação preencher
		cMontaTxt += (ctmpTit)->RA_RGORG + ";"                  // 19 Orgão emissor , se tiver informação preencher
		cMontaTxt += subst((ctmpTit)->RA_DTRGEXP,7,2) + "/" + subst((ctmpTit)->RA_DTRGEXP,5,2) + "/" + subst((ctmpTit)->RA_DTRGEXP,1,4) + ";" // 20 Data de expedição, se tiver informação preencher
		cMontaTxt += (ctmpTit)->RA_CC + ";"                                                              // 21 Centro de custo, se tiver informação preencher
		cMontaTxt += Posicione("CTT",1,xFilial("CTT") + (ctmpTit)->RA_CC,"CTT_DESC01") + ";"             // 22 Nome C. de custo , se tiver informação preencher
		cMontaTxt += FDESC('SRJ',(ctmpTit)->RA_CODFUNC,'RJ_DESC',TamSX3('RJ_DESC'),SRA->RA_FILIAL) + ";" // 23 Cargo , se tiver informação preencher
		cMontaTxt += fDescRCC("S054", (ctmpTit)->RA_LOGRTP, 1, 4, 5, 20) + ";"                           // 24 Tipo de logradouro , Rua, Avenida
		cMontaTxt += (ctmpTit)->RA_LOGRDSC + ";"                // 25 Nome do logradouro
		cMontaTxt += (ctmpTit)->RA_LOGRNUM + ";"                // 26 Numero ,numero
		cMontaTxt += (ctmpTit)->RA_COMPLEM + ";"                // 27 Compl. Numero
		cMontaTxt += (ctmpTit)->RA_BAIRRO  + ";"                // 28 Bairro
		cMontaTxt += (ctmpTit)->RA_MUNICIP + ";"                // 29 Cidade
		cMontaTxt += (ctmpTit)->RA_ESTADO  + ";"                // 30 Estado
		cMontaTxt += (ctmpTit)->RA_CEP     + ";"                // 31 CEP
		nQtd      := Len((ctmpTit)->RA_XCNS) // ticket n° 3834093 - 415966 - Paulo Dias - inserção registro CNS 
		cMontaTxt += SUbStr((ctmpTit)->RA_XCNS, 1,nQtd - 5) + " " + SUbStr((ctmpTit)->RA_XCNS, nQtd - 4,4) + " " + SUbStr((ctmpTit)->RA_XCNS, nQtd, 1) + ";"  // 32 CNS // ticket n° 3834093 - 415966 - Paulo Dias - inserção registro CNS 
		cMontaTxt += Subs((ctmpTit)->RA_BCDEPSA,1,3) + ";"      // 33 Banco ,informar o banco para reembolso
		cMontaTxt += Subs((ctmpTit)->RA_BCDEPSA,4,5) + ";"      // 34 Agencia , informar a agencia para reembolso
		cMontaTxt += ";"                                        // 35 Dig. Agencia , informar a digito da agencia para reembolso
		cRACTDEPSA := Alltrim((ctmpTit)->RA_CTDEPSA)
		cMontaTxt += Subs(cRACTDEPSA,1,LEN(cRACTDEPSA)-1) + ";" // 36 Conta corrente  , informar a conta corrente
		cMontaTxt += Right(ALLTRIM(cRACTDEPSA), 1 ) + ";"       // 37 Digito Conta corrente
		cMontaTxt += ";"                                        // 38 Numero de Nascido Vivo
		cMontaTxt += ";"                                        // 39-Lote ou Chamado
		cMontaTxt += ";"                                        // 40-Documento
		cMontaTxt += ";"                                        // 41-Sequencia
		cMontaTxt += ";"                                        // 42-Setor
		cMontaTxt += ";"                                        // 43-Lotaçao
		cMontaTxt += ";"                                        // 44-Local
		cMontaTxt += ";"                                        // 45-Unidade de Atendimento
		cMontaTxt += ";"                                        // 46-Unidade de Negociaçao
		cMontaTxt += CHR(13) + CHR(10)
		AAdd(aLinhas, cMontaTxt)
		(ctmpTit)->(dBSkip())
	Enddo
	
	//gera dados dos dependentes de cada titular com plano ativo
	DbSelectArea(ctmpTit)
	(ctmpTit)->(DbGoTop())
	While !(ctmpTit)->(EOF())
		//montar query do dependente
		ctmpDep:=GetNextAlias()
		// ticket n° 3834093 - 415966 - Paulo Dias - ajuste query para campo CNS
		BeginSql Alias ctmpDep
			SELECT RB_MAT,RB_NOME,RB_SEXO,RB_DTNASC,RB_GRAUPAR,RB_CIC,
					RB_MAE,RB_XCNS,RHL_PERINI,RHL_CODIGO,RHL_PLANO
			FROM %table:SRB% SRB
			Inner join %table:RHL% RHL ON
					RHL.RHL_FILIAL = SRB.RB_FILIAL AND
					RHL.RHL_MAT = SRB.RB_MAT AND
					RHL.RHL_CODIGO = SRB.RB_COD AND
					RHL.RHL_XSTAT = "1" AND
					RHL.%NotDel%
			WHERE SRB.RB_FILIAL = %Exp:(ctmpTit)->RA_FILIAL%
					AND SRB.RB_MAT = %Exp:(ctmpTit)->RA_MAT%
					AND RHL.RHL_PERINI BETWEEN %Exp:cMyPerINI% AND %Exp:cMyPerFIM%
					AND RHL.RHL_TPFORN = %Exp:MV_PAR09% 
					AND SRB.%NotDel%
			ORDER BY %Order:SRB%
		EndSql
		
		DbSelectArea(ctmpDep)
		(ctmpDep)->(DbGoTop())
		While !(ctmpDep)->(EOF())
			//monta o txt dos dependentes
			IncProc((ctmpTit)->RA_NOMECMP)
			cMontaTxt := ""
			cMontaTxt += ";"                                                                                                                      // 1
			cMontaTxt += ";"                                                                                                                      // 2
			cMontaTxt += ";"                                                                                                                      // 3
			cMontaTxt += "01/"+Substr((ctmpDep)->RHL_PERINI,1,2) + "/" + Substr((ctmpDep)->RHL_PERINI,3,4)+ ";"                                                                                              // 4
			If MV_PAR09 == 1
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
			cMontaTxt += (ctmpDep)->RHL_PLANO + "/" + cDescRcc + ";"                                                                              // 5 Codigo nome plano
			cMontaTxt += (ctmpDep)->RB_MAT + ";"                                                                                                  // 6 Matricula
			cMontaTxt += (ctmpDep)->RHL_CODIGO + ";"                                                                                              // 7
			cMontaTxt += subst((ctmpTit)->RA_ADMISSA,7,2) + "/" + subst((ctmpTit)->RA_ADMISSA,5,2) + "/" + subst((ctmpTit)->RA_ADMISSA,1,4) + ";" // 8 Data admissão , so para titular
			cMontaTxt += (ctmpDep)->RB_NOME + ";"                                                                                                 // 9 Nome do segurado
			cMontaTxt += IIF((ctmpDep)->RB_SEXO == "M","Masculino","Feminino") + ";"                                                              // 10 Sexo , Masculino ou Feminino
			cMontaTxt += subst((ctmpDep)->RB_DTNASC,7,2) + "/" + subst((ctmpDep)->RB_DTNASC,5,2) + "/" + subst((ctmpDep)->RB_DTNASC,1,4) + ";"    // 11 Data nascimento , Informar a data DD/MM/AAAA
			cMontaTxt += (ctmpDep)->RB_CIC + ";"                                                                                                  // 12 N. CPF , Informar o CPF beneficiario, se menos de 18 anos CPF nao deve ser preenchido
			cMontaTxt +=  ";"                                                                                                                     // 13  Estado civil , Casado(a),Solteiro(a), União Estável, Separado(a),Viúvo(a),Divorciado(a)
			Do Case
			Case (ctmpDep)->RB_GRAUPAR == "C"
				cGrauPar:= "Cônjuge/Companheiro"
			Case (ctmpDep)->RB_GRAUPAR == "F"
				cGrauPar:= "Filho(a)"
			Case (ctmpDep)->RB_GRAUPAR == "E"
				cGrauPar:= "Enteado(a)"
			Case (ctmpDep)->RB_GRAUPAR == "P"
				cGrauPar:= "Pai/Mâe"
			Case (ctmpDep)->RB_GRAUPAR == "O"
				cGrauPar:= "Agregado/Outros"
			EndCase
			cMontaTxt += cGrauPar + ";"                               // 14 Grau de parentesco ,Quando for informações do Titular, informar fixo "Titular"
			cMontaTxt += ";"                                          // 15
			cMontaTxt += (ctmpDep)->RB_MAE + ";"                      // 16 Nome da mãe , informação nome da mãe completo
			cMontaTxt += ";"                                          // 17 PIS , preencher somente para o titular
			cMontaTxt += ";"                                          // 18 RG , se tiver informação preencher
			cMontaTxt += ";"                                          // 19 Orgão emissor , se tiver informação preencher
			cMontaTxt += ";"                                          // 20 Data de expedição, se tiver informação preencher
			cMontaTxt += (ctmpTit)->RA_CC + ";"                       // 21 Centro de custo, se tiver informação preencher
			cMontaTxt += Posicione("CTT",1,xFilial("CTT") + (ctmpTit)->RA_CC,"CTT_DESC01") + ";" // 22 Nome C. de custo , se tiver informação preencher
			cMontaTxt += ";"                                          // 23 Cargo , se tiver informação preencher
			cMontaTxt += fDescRCC("S054", (ctmpTit)->RA_LOGRTP, 1, 4, 5, 20) + ";" // 24 Tipo de logradouro , Rua, Avenida
			cMontaTxt += (ctmpTit)->RA_LOGRDSC + ";"                  // 25 Nome do logradouro
			cMontaTxt += (ctmpTit)->RA_LOGRNUM + ";"                  // 26 Numero ,numero
			cMontaTxt += (ctmpTit)->RA_COMPLEM + ";"                  // 27 Compl. Numero
			cMontaTxt += (ctmpTit)->RA_BAIRRO  + ";"                  // 28 Bairro
			cMontaTxt += (ctmpTit)->RA_MUNICIP + ";"                  // 29 Cidade
			cMontaTxt += (ctmpTit)->RA_ESTADO  + ";"                  // 30 Estado
			cMontaTxt += (ctmpTit)->RA_CEP     + ";"                  // 31 CEP
			nQtd      := Len((ctmpDep)->RB_XCNS) // ticket n° 3834093 - 415966 - Paulo Dias - inserção registro CNS 
			cMontaTxt += SUbStr((ctmpDep)->RB_XCNS, 1,nQtd - 5) + " " + SUbStr((ctmpDep)->RB_XCNS, nQtd - 4,4) + " " + SUbStr((ctmpDep)->RB_XCNS, nQtd, 1) + ";"        // 32 CNS // ticket n° 3834093 - 415966 - Paulo Dias - inserção registro CNS                                        
			cMontaTxt += Subs((ctmpTit)->RA_BCDEPSA,1,3) + ";"        // 33 Banco ,informar o banco para reembolso
			cMontaTxt += Subs((ctmpTit)->RA_BCDEPSA,4,5) + ";"        // 34 Agencia , informar a agencia para reembolso
			cMontaTxt += ";"                                          // 35 Dig. Agencia , informar a digito da agencia para reembolso
			cRACTDEPSA := Alltrim((ctmpTit)->RA_CTDEPSA)
			cMontaTxt += SUBSTR(cRACTDEPSA,1,LEN(cRACTDEPSA)-1) + ";" // 36 Conta corrente  , informar a conta corrente
			cMontaTxt += Right( cRACTDEPSA, 1 ) + ";"                 // 37 Digito Conta corrente
			cMontaTxt += ";"                                          // 38 Numero de Nascido Vivo
			cMontaTxt += ";"                                          // 39-Lote ou Chamado
			cMontaTxt += ";"                                          // 40-Documento
			cMontaTxt += ";"                                          // 41-Sequencia
			cMontaTxt += ";"                                          // 42-Setor
			cMontaTxt += ";"                                          // 43-Lotaçao
			cMontaTxt += ";"                                          // 44-Local
			cMontaTxt += ";"                                          // 45-Unidade de Atendimento
			cMontaTxt += ";"                                          // 46-Unidade de Negociaçao
			cMontaTxt += CHR(13) + CHR(10)
			AAdd(aLinhas, cMontaTxt)
			(ctmpDep)->(DbSkip())
		Enddo
		(ctmpDep)->(DbCloseArea())
		//DbSelectArea(ctmpTit)
		(ctmpTit)->(DbSkip())
	Enddo
	
	//gera dados dos dependentes de cada titular com plano ativo
	DbSelectArea(ctmpTit)
	(ctmpTit)->(DbGoTop())
	While !(ctmpTit)->(EOF())
		//montar query do dependente
		ctmpDep:=GetNextAlias()
		// ticket n° 3834093 - 415966 - Paulo Dias - ajuste query para campo CNS
		BeginSql Alias ctmpDep
			SELECT RHM_MAT,RHM_NOME,RHM_DTNASC,RHM_CPF,RHM_PERINI,RHM_CODIGO,RHM_PLANO, RHM_XCNS
			FROM %table:RHM% RHM
			WHERE	RHM.RHM_FILIAL = %Exp:(ctmpTit)->RA_FILIAL% AND
					RHM.RHM_MAT = %Exp:(ctmpTit)->RA_MAT% AND
					RHM.RHM_PERINI BETWEEN %Exp:cMyPerINI% AND %Exp:cMyPerFIM%
					AND RHM.RHM_TPFORN = %Exp:MV_PAR09% 
					AND RHM.RHM_XSTAT = "1" AND RHM.%NotDel%
		EndSql
		
		DbSelectArea(ctmpDep)
		(ctmpDep)->(DbGoTop())
		While !(ctmpDep)->(EOF())
			//monta o txt dos dependentes
			IncProc((ctmpTit)->RA_NOMECMP)
			cMontaTxt := ""
			cMontaTxt += ";"                                                                                                                      // 1
			cMontaTxt += ";"                                                                                                                      // 2
			cMontaTxt += ";"                                                                                                                      // 3
			cMontaTxt += (ctmpDep)->RHM_PERINI + ";"                                                                                              // 4
			nPos := fPosTab("S008", (ctmpDep)->RHM_PLANO, "=", 4)                                                                                 
			If nPos > 0                                                                                                                           
				cDescRcc := fTabela( "S008",nPos,5)                                                                                               
			ELSE                                                                                                                                  
				cDescRcc := ""                                                                                                                    
			EndIf                                                                                                                                 
			cMontaTxt += (ctmpDep)->RHM_PLANO + "/" + cDescRcc + ";"                                                                              // 5 Codigo nome plano
			cMontaTxt += (ctmpDep)->RHM_MAT + ";"                                                                                                  // 6 Matricula
			cMontaTxt += (ctmpDep)->RHM_CODIGO + ";"                                                                                              // 7
			cMontaTxt += subst((ctmpTit)->RA_ADMISSA,7,2) + "/" + subst((ctmpTit)->RA_ADMISSA,5,2) + "/" + subst((ctmpTit)->RA_ADMISSA,1,4) + ";" // 8 Data admissão , so para titular
			cMontaTxt += (ctmpDep)->RHM_NOME + ";"                                                                                                 // 9 Nome do segurado
			cMontaTxt += ";"                                                                                                                      // 10 Sexo , Masculino ou Feminino
			cMontaTxt += subst((ctmpDep)->RHM_DTNASC,7,2) + "/" + subst((ctmpDep)->RHM_DTNASC,5,2) + "/" + subst((ctmpDep)->RHM_DTNASC,1,4) + ";"    // 11 Data nascimento , Informar a data DD/MM/AAAA
			cMontaTxt += (ctmpDep)->RHM_CPF + ";"                                                                                                  // 12 N. CPF , Informar o CPF beneficiario, se menos de 18 anos CPF nao deve ser preenchido
			cMontaTxt +=  ";"                                                                                                                     // 13  Estado civil , Casado(a),Solteiro(a), União Estável, Separado(a),Viúvo(a),Divorciado(a)
			cGrauPar:= "Agregado/Outros"
			cMontaTxt += cGrauPar + ";"                               // 14 Grau de parentesco ,Quando for informações do Titular, informar fixo "Titular"
			cMontaTxt += ";"                                          // 15
			cMontaTxt += ";"                      // 16 Nome da mãe , informação nome da mãe completo
			cMontaTxt += ";"                                          // 17 PIS , preencher somente para o titular
			cMontaTxt += ";"                                          // 18 RG , se tiver informação preencher
			cMontaTxt += ";"                                          // 19 Orgão emissor , se tiver informação preencher
			cMontaTxt += ";"                                          // 20 Data de expedição, se tiver informação preencher
			cMontaTxt += (ctmpTit)->RA_CC + ";"                       // 21 Centro de custo, se tiver informação preencher
			cMontaTxt += Posicione("CTT",1,xFilial("CTT") + (ctmpTit)->RA_CC,"CTT_DESC01") + ";" // 22 Nome C. de custo , se tiver informação preencher
			cMontaTxt += ";"                                          // 23 Cargo , se tiver informação preencher
			cMontaTxt += fDescRCC("S054", (ctmpTit)->RA_LOGRTP, 1, 4, 5, 20) + ";" // 24 Tipo de logradouro , Rua, Avenida
			cMontaTxt += (ctmpTit)->RA_LOGRDSC + ";"                  // 25 Nome do logradouro
			cMontaTxt += (ctmpTit)->RA_LOGRNUM + ";"                  // 26 Numero ,numero
			cMontaTxt += (ctmpTit)->RA_COMPLEM + ";"                  // 27 Compl. Numero
			cMontaTxt += (ctmpTit)->RA_BAIRRO  + ";"                  // 28 Bairro
			cMontaTxt += (ctmpTit)->RA_MUNICIP + ";"                  // 29 Cidade
			cMontaTxt += (ctmpTit)->RA_ESTADO  + ";"                  // 30 Estado
			cMontaTxt += (ctmpTit)->RA_CEP     + ";"                  // 31 CEP
			nQtd      := Len((ctmpDep)->RHM_XCNS) // ticket n° 3834093 - 415966 - Paulo Dias - inserção registro CNS 
			cMontaTxt += SUbStr((ctmpDep)->RHM_XCNS, 1,nQtd - 5) + " " + SUbStr((ctmpDep)->RHM_XCNS, nQtd - 4,4) + " " + SUbStr((ctmpDep)->RHM_XCNS, nQtd, 1) + ";"        // 32 CNS // ticket n° 3834093 - 415966 - Paulo Dias - inserção registro CNS 
			cMontaTxt += Subs((ctmpTit)->RA_BCDEPSA,1,3) + ";"        // 33 Banco ,informar o banco para reembolso
			cMontaTxt += Subs((ctmpTit)->RA_BCDEPSA,4,5) + ";"        // 34 Agencia , informar a agencia para reembolso
			cMontaTxt += ";"                                          // 35 Dig. Agencia , informar a digito da agencia para reembolso
			cRACTDEPSA := Alltrim((ctmpTit)->RA_CTDEPSA)
			cMontaTxt += SUBSTR(cRACTDEPSA,1,LEN(cRACTDEPSA)-1) + ";" // 36 Conta corrente  , informar a conta corrente
			cMontaTxt += Right( cRACTDEPSA, 1 ) + ";"                 // 37 Digito Conta corrente
			cMontaTxt += ";"                                          // 38 Numero de Nascido Vivo
			cMontaTxt += ";"                                          // 39-Lote ou Chamado
			cMontaTxt += ";"                                          // 40-Documento
			cMontaTxt += ";"                                          // 41-Sequencia
			cMontaTxt += ";"                                          // 42-Setor
			cMontaTxt += ";"                                          // 43-Lotaçao
			cMontaTxt += ";"                                          // 44-Local
			cMontaTxt += ";"                                          // 45-Unidade de Atendimento
			cMontaTxt += ";"                                          // 46-Unidade de Negociaçao
			cMontaTxt += CHR(13) + CHR(10)
			AAdd(aLinhas, cMontaTxt)
			(ctmpDep)->(DbSkip())
		Enddo
		(ctmpDep)->(DbCloseArea())
		//DbSelectArea(ctmpTit)
		(ctmpTit)->(DbSkip())
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
	cNomeArq := alltrim(MV_PAR10) + ".csv"
	
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
