#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH"
#include 'FILEIO.ch'

/*
{Protheus.doc} F0300603()
Exportação de Dependentes
@Author     Rogerio Candisani
@Since      18/10/2016
@Version    P12.7
@Project    MAN00000463701_EF_006
@Return
*/
User Function F0300603()
	
	Local aArea		:= GetArea()
	Local cPerg		:= "FSW0300603"
	Local aSays		:= {}
	Local aButtons	:= {}
	Local nOpca		:= 0
	Local cCadastro	:= OemToAnsi("Exportação de Dependente")

	Pergunte(cPerg,.F.)
			
	//AAdd(aSays,OemToAnsi("Este programa realiza o processo de geração do Holerite Eletrônico do Banco"))
	AAdd(aSays,OemToAnsi("Este programa realiza o processo de geração do arquivo de exportação"))
	
	AAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T.)  } } )
	AAdd(aButtons, { 1,.T.,{|o| nOpca := 1,If((MsgYesNo("Confirma a exportação do dependente ?","Atenção")),FechaBatch(),nOpca:=0) }} )
	AAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )
		
	FormBatch(cCadastro,aSays,aButtons)

	If nOpca == 1
		Processa({|| F03006IMP(),"Gerando Exportação"})
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
	Local cctmpDep :=""
	Local cmontaTxt:= ""
	Local cPerg:= "FSW0300603"	// Gp. perguntas especifico
	Local cGrauPar:=""
	Local lGerou := .f.
	Local aLinhas:= {}
	Local cMyPerINI  := ""
	Local cMyPerFIM  := ""
	
	//exportar os dados do dependenter em .CSV
	//criar pergunta F0300603
	
	/*	Exportação Dependente:
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
	
	//Observações para exportações dos Dependentes:
	//1)	As Colunas 1, 2, 3, 5, 6 e 15 - Informar somente a coluna, o dado será vazio;
	//2)	A Coluna 14 – Informar o grau de parentesco de acordo com o conteúdo do campo RB_GRAUPAR;
	//3)	As Colunas que foram indicadas para serem geradas “em branco” terão dados informados manualmente pela equipe de benefícios;
	//4)	Os tamanhos das colunas são livres, e deverão ser separados por “; ”.
	
	Pergunte(cPerg,.F.)
	
	cMyPerINI := SubStr(MV_PAR03,5,2)+SubStr(MV_PAR03,1,4) 
	cMyPerFIM := SubStr(MV_PAR04,5,2)+SubStr(MV_PAR04,1,4)
	
	//Cabeçalho
	cMontaTxt += "Operadora;"                      // 1 - brancos
	cMontaTxt += "Nº da apólice/contrato;"         // 2 - brancos
	cMontaTxt += "Nº Sub;"                         // 3 - brancos
	cMontaTxt += "Matrícula;"                      // 4
	cMontaTxt += "Certificado;"                    // 5 - brancos
	cMontaTxt += "Código Dependente;"              // 6 - brancos
	cMontaTxt += "Nome do Titular;"                // 7 nome do titular
	cMontaTxt += "CPF do Titular;"                 // 8 N. CPF , Informar o CPF beneficiario, se menos de 18 anos CPF nao deve ser preenchido
	cMontaTxt += "Nome Dependente;"                // 9 Nome do segurado
	cMontaTxt += "CPF do Dependente;"              // 10 N. CPF , Informar o CPF beneficiario, se menos de 18 anos CPF nao deve ser preenchido
	cMontaTxt += "Data nascimento;"                // 11 Data nascimento , Informar a data DD/MM/AAAA
	cMontaTxt += "Sexo;"                           // 12 Sexo , Masculino ou Feminino
	cMontaTxt += "estado civil;"                   // 13 estado civil
	cMontaTxt += "Grau de parentesco;"             // 14 Grau de parentesco ,Quando for informações do Titular, informar fixo "Titular"
	cMontaTxt += "data de casamento;"              // 15 data de casamento
	cMontaTxt += "Inicio de Vigência;"             // 16 data de inclusao no plano
	cMontaTxt += "Nome da Mãe do dependente;"      // 17 Nome da mãe , informação nome da mãe completo
	cMontaTxt += "Número de nascido vivo;"         // 18 numero de nascido vivo, opcional
	cMontaTxt += "Cartão nacional de saúde (CNS);" // 19 numero de CNS, opcional
	cMontaTxt += "Lote ou Chamado;"                // 20-Em branco
	cMontaTxt += "Documento;"                      // 21-Em branco
	cMontaTxt += "Sequencia;"                      // 22-Em branco
	cMontaTxt += "Setor;"                          // 23-Em branco
	cMontaTxt += "Lotaçao;"                        // 24-Em branco
	cMontaTxt += "Local;"                          // 25-Em branco
	cMontaTxt += CHR(13) + CHR(10)
	AAdd(aLinhas,cMontaTxt)
	
	//montar query do dependente
	ctmpDep:=GetNextAlias()
	
	BeginSql Alias ctmpDep
		SELECT RB_FILIAL, RB_MAT, RB_NOME, RB_SEXO, RB_DTNASC, RB_GRAUPAR, RB_CIC,
				RB_MAE, RHL_PERINI, RHL_CODIGO
		FROM %table:SRB% SRB
		Inner join %table:SRA% SRA ON
				SRA.RA_FILIAL = SRB.RB_FILIAL AND
				SRA.RA_MAT = SRB.RB_MAT AND
				SRA.%NotDel%
		Inner join %table:RHL% RHL ON
				RHL.RHL_FILIAL = SRB.RB_FILIAL AND
				RHL.RHL_MAT = SRB.RB_MAT AND
				RHL.RHL_CODIGO = SRB.RB_COD AND
				RHL.RHL_XSTAT = "6" AND
				RHL.%NotDel%
		WHERE SRB.RB_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
				AND SRB.RB_MAT BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
				AND SRA.RA_ADMISSA BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
				AND RHL.RHL_PERINI BETWEEN %Exp:cMyPerINI% AND %Exp:cMyPerFIM%
				AND RHL.RHL_TPFORN = %Exp:MV_PAR09% 
				AND SRB.%NotDel%
		ORDER BY %Order:SRB%
	EndSql
	
	DbSelectArea(ctmpDep)
	ProcRegua((ctmpDep)->(LASTREC()))
	(ctmpDep)->(DbGoTop())
	//cMontaTxt := ""
	While !(ctmpDep)->(EOF())
		
		lgerou := .T.
		IncProc((ctmpDep)->RB_NOME)
		//monta o txt dos dependentes]
		//ajustar o montaTxt
		//colunas 4, 7,8,9,10,11,12,13,14,16,17,18,19
		cMontaTxt := ""
		cMontaTxt += ";"                          // 1 - brancos
		cMontaTxt += ";"                          // 2 - brancos
		cMontaTxt += ";"                          // 3 - brancos
		cMontaTxt += (ctmpDep)->RB_MAT + ";"      // 4
		cMontaTxt += ";"                          // 5 - brancos
		cMontaTxt += (ctmpDep)->RHL_CODIGO + ";"  // 6 - brancos
		cMontaTxt += Posicione("SRA",1,(ctmpDep)->RB_FILIAL + (ctmpDep)->RB_MAT,"RA_NOME") + ";" // 7 nome do titular
		cMontaTxt += SRA->RA_CIC + ";"            // 8 N. CPF , Informar o CPF beneficiario, se menos de 18 anos CPF nao deve ser preenchido
		cMontaTxt += (ctmpDep)->RB_NOME + ";"     // 9 Nome do segurado
		cMontaTxt += (ctmpDep)->RB_CIC + ";"      // 10 N. CPF , Informar o CPF beneficiario, se menos de 18 anos CPF nao deve ser preenchido
		cMontaTxt += subst((ctmpDep)->RB_DTNASC,7,2) + "/" + subst((ctmpDep)->RB_DTNASC,5,2) + "/" + subst((ctmpDep)->RB_DTNASC,1,4) + ";" // 11 Data nascimento , Informar a data DD/MM/AAAA
		cMontaTxt += IIF((ctmpDep)->RB_SEXO == "M","Masculino","Feminino") + ";" // 12 Sexo , Masculino ou Feminino
		cMontaTxt += ";"                          // 13 estado civil
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
		cMontaTxt += cGrauPar + ";"               // 14 Grau de parentesco ,Quando for informações do Titular, informar fixo "Titular"
		cMontaTxt += ";"                          // 15 data de casamento
		cMontaTxt += "01/"+Substr((ctmpDep)->RHL_PERINI,1,2) + "/" + Substr((ctmpDep)->RHL_PERINI,3,4)  + ";" // 16 data de inclusao no plano
		cMontaTxt += (ctmpDep)->RB_MAE + ";"      // 17 Nome da mãe , informação nome da mãe completo
		cMontaTxt += ";"                          // 18 numero de nascido vivo, opcional
		cMontaTxt += ";"                          // 19 numero de CNS, opcional
		cMontaTxt += ";"                          // 20-Lote ou Chamado
		cMontaTxt += ";"                          // 21-Documento
		cMontaTxt += ";"                          // 22-Sequencia
		cMontaTxt += ";"                          // 23-Setor
		cMontaTxt += ";"                          // 24-Lotaçao
		cMontaTxt += ";"                          // 25-Local
		cMontaTxt += CHR(13) + CHR(10)
		AAdd(aLinhas,cMontaTxt)
		(ctmpDep)->(DbSkip())
	Enddo
	(ctmpDep)->(DbCloseArea())
	ctmpDep:=GetNextAlias()
	
	BeginSql Alias ctmpDep
		SELECT RHM_MAT,RHM_NOME,RHM_DTNASC,RHM_CPF,RHM_PERINI,RHM_CODIGO,RHM_PLANO, RA_NOME, RA_CIC
		FROM %table:RHM% RHM
		Inner join %table:SRA% SRA ON
				SRA.RA_FILIAL = RHM.RHM_FILIAL AND
				SRA.RA_MAT = RHM.RHM_MAT AND
				SRA.RA_ADMISSA BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06% AND
				SRA.%NotDel%
		WHERE	RHM.RHM_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% AND
				RHM.RHM_MAT BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08% AND
				RHM.RHM_PERINI BETWEEN %Exp:cMyPerINI% AND %Exp:cMyPerFIM% AND
				RHM.RHM_TPFORN = %Exp:MV_PAR09% AND 
				RHM.RHM_XSTAT = "2" AND
				RHM.%NotDel%
	EndSql
	
	DbSelectArea(ctmpDep)
	ProcRegua((ctmpDep)->(LASTREC()))
	(ctmpDep)->(DbGoTop())
	//cMontaTxt := ""
	While !(ctmpDep)->(EOF())
		
		lgerou := .T.
		IncProc((ctmpDep)->RA_NOME)
		//monta o txt dos dependentes]
		//ajustar o montaTxt
		//colunas 4, 7,8,9,10,11,12,13,14,16,17,18,19
		cMontaTxt := ""
		cMontaTxt += ";"                          // 1 - brancos
		cMontaTxt += ";"                          // 2 - brancos
		cMontaTxt += ";"                          // 3 - brancos
		cMontaTxt += (ctmpDep)->RHM_MAT + ";"      // 4
		cMontaTxt += ";"                          // 5 - brancos
		cMontaTxt += (ctmpDep)->RHM_CODIGO + ";"  // 6 - brancos
		cMontaTxt += (ctmpDep)->RA_NOME + ";" // 7 nome do titular
		cMontaTxt += (ctmpDep)->RA_CIC + ";"            // 8 N. CPF , Informar o CPF beneficiario, se menos de 18 anos CPF nao deve ser preenchido
		cMontaTxt += (ctmpDep)->RHM_NOME + ";"     // 9 Nome do segurado
		cMontaTxt += (ctmpDep)->RHM_CPF + ";"      // 10 N. CPF , Informar o CPF beneficiario, se menos de 18 anos CPF nao deve ser preenchido
		cMontaTxt += subst((ctmpDep)->RHM_DTNASC,7,2) + "/" + subst((ctmpDep)->RHM_DTNASC,5,2) + "/" + subst((ctmpDep)->RHM_DTNASC,1,4) + ";" // 11 Data nascimento , Informar a data DD/MM/AAAA
		cMontaTxt += ";" // 12 Sexo , Masculino ou Feminino
		cMontaTxt += ";"                          // 13 estado civil
		cGrauPar:= "Agregado/Outros"
		cMontaTxt += cGrauPar + ";"               // 14 Grau de parentesco ,Quando for informações do Titular, informar fixo "Titular"
		cMontaTxt += ";"                          // 15 data de casamento
		cMontaTxt += "01/"+Substr((ctmpDep)->RHm_PERINI,1,2) + "/" + Substr((ctmpDep)->RHm_PERINI,3,4)  + ";" // 16 data de inclusao no plano
		cMontaTxt += ";"      // 17 Nome da mãe , informação nome da mãe completo
		cMontaTxt += ";"                          // 18 numero de nascido vivo, opcional
		cMontaTxt += ";"                          // 19 numero de CNS, opcional
		cMontaTxt += ";"                          // 20-Lote ou Chamado
		cMontaTxt += ";"                          // 21-Documento
		cMontaTxt += ";"                          // 22-Sequencia
		cMontaTxt += ";"                          // 23-Setor
		cMontaTxt += ";"                          // 24-Lotaçao
		cMontaTxt += ";"                          // 25-Local
		cMontaTxt += CHR(13) + CHR(10)
		AAdd(aLinhas,cMontaTxt)
		(ctmpDep)->(DbSkip())
	Enddo
	(ctmpDep)->(DbCloseArea())
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
	Local nX    := 0
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
