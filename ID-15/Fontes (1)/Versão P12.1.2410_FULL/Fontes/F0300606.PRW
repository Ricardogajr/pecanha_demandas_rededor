#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"
#include 'FILEIO.ch'

/*
{Protheus.doc} F0300606()
Exportação de Transferencia de Colaborador
@Author     Rogerio Candisani
@Since      31/10/2016
@Version    P12.7
@Project    MAN00000463701_EF_006
@Return
*/
User Function F0300606()
	
	Local aArea		:= GetArea()
	Local cPerg		:= "FSW0300606"
	Local aSays		:= {}
	Local aButtons	:= {}
	Local nOpca		:= 0
	Local cCadastro	:= OemToAnsi("Exportação de Exclusão de Transferencia de Colaborador")

	Pergunte(cPerg,.F.)
			
	//AAdd(aSays,OemToAnsi("Este programa realiza o processo de geração do Holerite Eletrônico do Banco"))
	AAdd(aSays,OemToAnsi("Este programa realiza o processo de geração do arquivo de exportação"))
	
	AAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T.)  } } )
	AAdd(aButtons, { 1,.T.,{|o| nOpca := 1,If((MsgYesNo("Confirma a Exportação de Transferencia de Colaborador ?","Atenção")),FechaBatch(),nOpca:=0) }} )
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

	Local ctmpTrf
	Local ctmpDep
	Local cmontaTxt:= ""
	Local cPerg:= "FSW0300606"	// Gp. perguntas especifico
	Local Lgerou:= .F.
	Local aLinhas := {}
	
	//exportar os dados de exclusão do colaborador
	//criar pergunta F0300606
	
	/*	Exportação de Transferencia de Colaborador
	MV_PAR01 Filial De                                -> Filial De
	MV_PAR02 Filial Até                               -> Filial Ate
	MV_PAR03 Transferencia De                         -> Transferencia De
	MV_PAR04 Transferencia Até                        -> Transferencia Ate
	MV_PAR05 Tipo de Arquivo (Médico / Odontológico)  -> Matricula De
	MV_PAR06 Caminho de Gravação                      -> Matricula Ate
	MV_PAR07 XXX                                      -> Tipo de Arquivo (Médico / Odontológico)
	MV_PAR08 XXX                                      -> Caminho de Gravação
	*/
	
	// Verificar na tabela SRE, somente para os casos onde a filial destino seja diferente da origem. NÃO SE APLICA A TRANSFERENCIAS INTERNAS 
	// (CENTRO DE CUSTO, DEPARTAMENTO, ETC);
	//	Verificar na tabela RHK se o colaborador transferido possui um plano ativo;
	//	Será incluído no arquivo somente se satisfeita as condições acima.
	// Deverá gerar todas as colunas, ainda que algumas sem conteúdo.
	
	// Colunas 1, 2, 6 e 14 - Informar somente a coluna, o dado será vazio;
	//	As Colunas que foram indicadas para serem geradas “em branco” terão dados informados manualmente pela equipe de benefícios;
	//	A Coluna 10 deverá ser preenchida com a data da transferência;
	//	Os tamanhos das colunas são livres, e deverão ser separados por “; ”.
	
	Pergunte(cPerg,.F.)
	
	//PRESERVAR CNPJ DE TODAS AS FILIAIS DO SIGAMAT
	Private aCnpjFil := {}
	DbSelectArea("SM0")
	dbGoTop()
	While !Eof()
		AAdd(aCnpjFil, { FWGETCODFILIAL, SM0->M0_CGC,  SM0->M0_CODMUN})
		SM0->(dbSkip())
	EndDo
	
	CtmpTrf:=GetNextAlias()
	BeginSql Alias CtmpTrf
		SELECT RE_CCD, RE_DATA, RE_FILIAL, RE_FILIALD, RE_MATD, RE_FILIALP, RE_MATP, RE_CCP, RA_NOME, RA_CIC, RA_CARGO
		FROM %table:SRE% SRE
		Inner join %table:RHK% RHK ON
				RHK.RHK_MAT = SRE.RE_MATD AND
				RHK.RHK_TPFORN = %Exp:AllTrim(Str(MV_PAR07))% AND
				RHK.%NotDel%
		Inner join %table:RHL% RHL ON
				RHL.RHL_MAT = SRE.RE_MATD AND
				RHL.RHL_TPFORN = %Exp:AllTrim(Str(MV_PAR07))% AND
				RHL.%NotDel%
		INNER JOIN %table:SRA% SRA
		ON SRA.RA_MAT = SRE.RE_MATD AND
				SRA.%NotDel%
		WHERE 	SRE.RE_FILIALD BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
				AND SRE.RE_DATA BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
				AND SRE.RE_MATD BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
				AND SRE.RE_FILIALD <> SRE.RE_FILIALP
				AND SRE.%NotDel%
		GROUP BY RE_EMPD,RE_FILIALD,RE_MATD,RE_DATA, RE_CCD, RE_DATA, RE_FILIAL, RE_FILIALD, RE_MATD, RE_FILIALP, RE_MATP, RE_CCP, RA_NOME, RA_CIC, RA_CARGO  
		ORDER BY %Order:SRE%
	EndSql
	
	DbSelectArea(CtmpTrf)
	(CtmpTrf)->(DbGoTop())
	//Cabeçalho
	cMontaTxt += "Operadora;"                    // 01
	cMontaTxt += "Nº da apólice/contrato;"       // 02
	cMontaTxt += "Empresa/Sub Atual;"            // 03
	cMontaTxt += "Nome Titular;"                 // 04
	cMontaTxt += "Matrícula atual;"              // 05
	cMontaTxt += "Certificado;"                  // 06
	cMontaTxt += "CPF;"                          // 07
	cMontaTxt += "Nova Empresa/Sub;"             // 08
	cMontaTxt += "Nova Matricula;"               // 09
	cMontaTxt += "Inicio de Vigência;"           // 10
	cMontaTxt += "Nº Novo Centro de Custo;"      // 11
	cMontaTxt += "Nome do Novo Centro de Custo;" // 12
	cMontaTxt += "Novo Cargo;"                   // 13
	cMontaTxt += "Novo Plano;"                   // 14
	cMontaTxt += "Lote ou Chamado;"              //-15
	cMontaTxt += "Documento;"                    //-16
	cMontaTxt += "Sequencia;"                    //-17
	cMontaTxt += "Setor;"                        //-18
	cMontaTxt += "Lotaçao;"                      //-19
	cMontaTxt += "Local;"                        //-20
	cMontaTxt += "Unidade de Atendimento;"       //-21
	cMontaTxt += "Unidade de Negociaçao;"        //-22
	cMontaTxt += CHR(13) + CHR(10)
	
	AAdd(aLinhas,cMontaTxt)
	
	While ! (CtmpTrf)->(EOF())
		//mpos:=AScan(aCnpjFil[1],Substr((CtmpTrf)->RE_FILIALD,1,len((CtmpTrf)->RE_FILIAL)))
		mpos := AScan(aCnpjFil,{|X| AllTrim(X[01]) == AllTrim((CtmpTrf)->RE_FILIALD)})
		If mpos > 0
			cCNPJde:= AcNPJfIL[MPOS,2]
			//mpos:=AScan(aCnpjFil[1],Substr((CtmpTrf)->RE_FILIALD,1,len((CtmpTrf)->RE_FILIAL)))
			mpos := AScan(aCnpjFil,{|X| AllTrim(X[01]) == AllTrim((CtmpTrf)->RE_FILIALP)})
			
			If 	mpos > 0
				lGerou:=.T.
				
				cCNPJpara:= AcNPJfIL[MPOS,2]
				//monta o txt do titular
				cMontaTxt := ""
				cMontaTxt += ";"                                                                      // 1 - branco
				cMontaTxt += ";"                                                                      // 2 - branco
				cMontaTxt += cCNPJde + ";"                                                            // 3 - cnpj da filial origem
				cMontaTxt += (CtmpTrf)->RA_NOME + ";"                                                 // 4 - nome do titular
				cMontaTxt += (CtmpTrf)->RE_MATD + ";"                                                 // 5 - matricula
				cMontaTxt += ";"                                                                      // 6 - branco
				cMontaTxt += (CtmpTrf)->RA_CIC + ";"                                                  // 7 - CPF do titular
				cMontaTxt += cCNPJpara + ";"                                                          // 8 - cnpj da filial destino
				cMontaTxt += (CtmpTrf)->RE_MATP + ";"                                                 // 9 - nova matricula
				cMontaTxt += subst((ctmpTrf)->RE_DATA,7,2) + "/" + subst((ctmpTrf)->RE_DATA,5,2) + "/" + subst((ctmpTrf)->RE_DATA,1,4) + ";" // 10 - data de inicio do beneficio DDMMAAAA
				cMontaTxt += (CtmpTrf)->RE_CCP +  ";"                                                 // 11 - centro de custo
				cMontaTxt += Posicione("CTT",1,xFilial("CTT") + (CtmpTrf)->RE_CCP,"CTT_DESC01") + ";" // 12 - nome do centro de custo
				cMontaTxt += FDESC('SRJ',(CtmpTrf)->RA_CARGO,'RJ_DESC',TamSX3('RJ_DESC'),SRA->RA_FILIAL)+ ";"                                                // 13 - novo cargo
				cMontaTxt += ";"                                                                      // 14 - branco
				cMontaTxt += ";"                                                                      //-15-Lote ou Chamado
				cMontaTxt += ";"                                                                      //-16-Documento
				cMontaTxt += ";"                                                                      //-17-Sequencia
				cMontaTxt += ";"                                                                      //-18-Setor
				cMontaTxt += ";"                                                                      //-19-Lotaçao
				cMontaTxt += ";"                                                                      //-20-Local
				cMontaTxt += ";"                                                                      //-21-Unidade de Atendimento
				cMontaTxt += ";"                                                                      //-22-Unidade de Negociaçao 
				cMontaTxt += CHR(13) + CHR(10)
				AAdd(aLinhas,cMontaTxt)
			EndIf
		EndIf
		(CtmpTrf)->(dBSkip())
	Enddo
	
	//fechar arquivos temporarios
	(CtmpTrf)->(DbCloseArea())
	
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
