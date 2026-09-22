#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#include 'FILEIO.ch'

/*
{Protheus.doc} F0300605()
Exportação de Exclusão de Colaborador
@Author     Rogerio Candisani
@Since      31/10/2016
@Version    P12.7
@Project    MAN00000463701_EF_006
@Return
*/
User Function F0300605()
	
	Local aArea		:= GetArea()
	Local cPerg		:= "FSW0300605"
	Local aSays		:= {}
	Local aButtons	:= {}
	Local nOpca		:= 0
	Local cCadastro	:= OemToAnsi("Exportação de Exclusão de Colaborador")

	Pergunte(cPerg,.F.)
			
	//AAdd(aSays,OemToAnsi("Este programa realiza o processo de geração do Holerite Eletrônico do Banco"))
	AAdd(aSays,OemToAnsi("Este programa realiza o processo de geração do arquivo de exportação"))
	
	AAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T.)  } } )
	AAdd(aButtons, { 1,.T.,{|o| nOpca := 1,If((MsgYesNo("Confirma Exportação de Exclusão de Colaborador ?","Atenção")),FechaBatch(),nOpca:=0) }} )
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

	Local ctmpExc
	Local ctmpDep
	Local cmontaTxt:= ""
	Local cPerg:= "FSW0300605"	// Gp. perguntas especifico
	Local lgerou:=.f.
	Local aLinhas := {}
	Local cPERINI := ""
	Local cMyPerINI  := ""
	Local cMyPerFIM  := ""
	
	//exportar os dados de exclusão do colaborador
	//criar pergunta F0300605
	
	/*	Exportação de Exclusão de Colaborador
	MV_PAR01 Filial De			-> Filial De
	MV_PAR02 Filial Até			-> Filial Ate
	MV_PAR03 Demissao De        -> Periodo Final De
	MV_PAR04 Demissao Até		-> Periodo Final Ate
	MV_PAR05 Tipo de Arquivo (Médico / Odontológico)	-> Demissao De
	MV_PAR06 Caminho de Gravação -> Demissao Ate
	MV_PAR07 XXX                 -> Tipo de Arquivo (Médico / Odontológico)
	MV_PAR08 XXX                 -> Caminho de Gravação
	*/
	
	//	Verificar se o campo RG_DATADEM possui conteúdo
	//	Verificar na tabela RHK se o colaborador demitido possui um plano ativo.
	//	Será incluído no arquivo somente se satisfeita as condições acima.
	//	Deverá gerar todas as colunas, ainda que algumas sem conteúdo.
	
	// As Colunas 2, 3, 4, 6 e 13 - Informar somente a coluna, o dado será vazio;
	// As Colunas que foram indicadas para serem geradas “em branco” terão dados informados manualmente pela equipe de benefícios;
	// A Coluna 10 deverá ser preenchida com a data da demissão;
	// Os tamanhos das colunas são livres, e deverão ser separados por “; ”.
	
	Pergunte(cPerg,.F.)
	
	cMyPerINI := SubStr(MV_PAR03,5,2)+SubStr(MV_PAR03,1,4) 
	cMyPerFIM := SubStr(MV_PAR04,5,2)+SubStr(MV_PAR04,1,4)
	
	//montar query de exclusão do colaborador
	ctmpExc:=GetNextAlias()
	
	BeginSql Alias ctmpExc
		SELECT RHK_FILIAL,RHK_MAT,		RG_DATADEM,RHK_PERINI,RHK_PERFIM,RHK_XSTAT, RHK_NCARVD 
		FROM %table:RHK% RHK 
		LEFT JOIN %table:SRG% SRG ON SRG.RG_FILIAL = RHK.RHK_FILIAL AND SRG.RG_MAT = RHK.RHK_MAT  AND SRG.D_E_L_E_T_= ' '  
		WHERE  
		RHK.RHK_TPFORN = %Exp:MV_PAR07% 
		AND RHK.RHK_PERFIM >= %Exp:cMyPerINI%  
		AND (RHK.RHK_PERFIM <= %Exp:cMyPerFIM% OR RHK.RHK_PERFIM > ' ' ) 
		AND RHK.D_E_L_E_T_= ' ' 
		AND RHK.RHK_XSTAT IN ('2','4','5')
		AND RHK.RHK_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
		ORDER BY  RHK.RHK_FILIAL,RHK.RHK_MAT	
	EndSql
	

	
	
	//Cabeçalho
	cMontaTxt += "Tipo de Exclusão;"       // 01
	cMontaTxt += "Nº da apólice/contrato;" // 02
	cMontaTxt += "Nº Sub;"                 // 03
	cMontaTxt += "Operadora;"              // 04
	cMontaTxt += "Matrícula;"              // 05
	cMontaTxt += "Certificado;"            // 06
	cMontaTxt += "Código Dependente;"      // 07
	cMontaTxt += "Nome do Titular;"        // 08
	cMontaTxt += "CPF Titular;"            // 09
	cMontaTxt += "Data de Demissão;"       // 10
	cMontaTxt += "Nome Dependente;"        // 11
	cMontaTxt += "Data de Cancelamento;"   // 12
	cMontaTxt += "Motivo;"                 // 13
	cMontaTxt += "Lote ou Chamado;"        //-14
	cMontaTxt += "Documento;"              //-15
	cMontaTxt += "Sequencia;"              //-16
	cMontaTxt += "Setor;"                  //-17
	cMontaTxt += "Lotaçao;"                //-18
	cMontaTxt += "Local;"                  //-19
	cMontaTxt += CHR(13) + CHR(10)
	AAdd(aLinhas,cMontaTxt)
	
	DbSelectArea(ctmpExc)
	ProcRegua((ctmpExc)->(LASTREC()))
	(ctmpExc)->(DbGoTop())
	//cMontaTxt:= ""
	While ! (ctmpExc)->(EOF())
		lgerou:=.t.
		//monta o txt do titular
		cMontaTxt := ""
		cMontaTxt += "Titular" + ";"                                                                                                              // 1 verificar RHK_PERFIM ou RHL_PERFIM
		cMontaTxt += ";"                                                                                                                          // 2 - branco
		cMontaTxt += ";"                                                                                                                          // 3 - branco
		cMontaTxt += ";"                                                                                                                          // 4 - branco
		cMontaTxt += (ctmpExc)->RHK_MAT + ";"                                                                                                      // 5 - matricula do titular
		cMontaTxt += ";"                                                                                                                          // 6 - branco
		cMontaTxt += (ctmpExc)->RHK_NCARVD+";"                                                                                                                        // 7
		cMontaTxt += Posicione("SRA",1,(ctmpExc)->RHK_FILIAL + (ctmpExc)->RHK_MAT,"RA_NOME") + ";"                                                  // 8 - nome do titular
		cMontaTxt += SRA->RA_CIC + ";"                                                                                                            // 9 - CPF do titular
		cMontaTxt += subst((ctmpExc)->RG_DATADEM,7,2) + "/" + subst((ctmpExc)->RG_DATADEM,5,2) + "/" + subst((ctmpExc)->RG_DATADEM,1,4) + ";"     // 10 Data demissao , Informar a data DD/MM/AAAA
		cMontaTxt += ";"                                                                                                                          // 11 - nome do dependente ?
		If !Empty((ctmpExc)->RG_DATADEM)                                                                                                          // 12 - data de cancelamento ?
			cMontaTxt += subst((ctmpExc)->RG_DATADEM,7,2) + "/" + subst((ctmpExc)->RG_DATADEM,5,2) + "/" + subst((ctmpExc)->RG_DATADEM,1,4) + ";" 
		Else
			cPERINI := "01" + "/" + subst((ctmpExc)->RHK_PERFIM,1,2) + "/" + subst((ctmpExc)->RHK_PERFIM,3,4)
			cPERINI := StrZero(F_ULTDIA(CTOD(cPERINI)),2)
			cMontaTxt += cPERINI + "/" + subst((ctmpExc)->RHK_PERFIM,1,2) + "/" + subst((ctmpExc)->RHK_PERFIM,3,4) + ";"                      
		EndIf
		cMontaTxt += ";"                                                                                                                          // 13
		cMontaTxt += ";"                                                                                                                          //-14-Lote ou Chamado
		cMontaTxt += ";"                                                                                                                          //-15-Documento
		cMontaTxt += ";"                                                                                                                          //-16-Sequencia
		cMontaTxt += ";"                                                                                                                          //-17-Setor
		cMontaTxt += ";"                                                                                                                          //-18-Lotaçao
		cMontaTxt += ";"                                                                                                                          //-19-Local
		cMontaTxt += CHR(13) + CHR(10)
		AAdd(aLinhas,cMontaTxt)
		(ctmpExc)->(dBSkip())
	Enddo
	
	//gera dados dos dependentes de cada titular excluido
	DbSelectArea(ctmpExc)
		//montar query do dependente
		ctmpDep:=GetNextAlias()
		
		BeginSql Alias ctmpDep
			SELECT RHL_FILIAL,RHL_MAT,RHL_CODIGO,RHL_PERINI,RHL_PERFIM,RHL_XSTAT, RHL_NCARVD, RG_DATADEM
			FROM %table:RHL% RHL
			LEFT JOIN %table:SRG% SRG ON SRG.RG_FILIAL = RHL.RHL_FILIAL AND SRG.RG_MAT = RHL.RHL_MAT  AND SRG.D_E_L_E_T_= ' '  			
			WHERE  
			RHL.RHL_TPFORN = %Exp:MV_PAR07% 
			AND RHL.RHL_PERFIM >= %Exp:cMyPerINI%  
			AND (RHL.RHL_PERFIM <= %Exp:cMyPerFIM% OR RHL.RHL_PERFIM > ' ' ) 
			AND RHL.%NotDel%
			AND RHL.RHL_XSTAT IN ('2','4','5')
			AND RHL.RHL_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
			ORDER BY  RHL.RHL_FILIAL,RHL.RHL_MAT				
			
		EndSql
		
		DbSelectArea(ctmpDep)
		(ctmpDep)->(DbGoTop())
		While !(ctmpDep)->(EOF())
			lgerou:=.t.
			//monta o txt dos dependentes a serem excluidos
			cMontaTxt := ""
			cMontaTxt += "Dependente" + ";"                                                                                                           // 1 verificar RHL_PERFIM
			cMontaTxt += ";"                                                                                                                          // 2 - branco
			cMontaTxt += ";"                                                                                                                          // 3 - branco
			cMontaTxt += ";"                                                                                                                          // 4 - branco
			cMontaTxt += (ctmpDep)->RHL_MAT + ";"                                                                                                     // 5 - matricula do titular
			cMontaTxt += ";"                                                                                                                          // 6 - branco
			cMontaTxt += (ctmpDep)->RHL_NCARVD+ ";"                                                                                                  // 7 campo RHL_XCARTE ?
			cMontaTxt += Posicione("SRA",1,(ctmpDep)->RHL_FILIAL + (ctmpDep)->RHL_MAT,"RA_NOME") + ";"                                                // 8 - nome do titular
			cMontaTxt += SRA->RA_CIC + ";"                                                                                                            // 9 - CPF do titular
			cMontaTxt += subst((ctmpDep)->RG_DATADEM,7,2) + "/" + subst((ctmpDep)->RG_DATADEM,5,2) + "/" + subst((ctmpDep)->RG_DATADEM,1,4) + ";"     // 10 Data demissao , Informar a data DD/MM/AAAA - 20170313
			cMontaTxt += Posicione("SRB",1,(ctmpDep)->RHL_FILIAL + (ctmpDep)->RHL_MAT + (ctmpDep)->RHL_CODIGO,"RB_NOME") + ";"                                                // 11 - nome do dependente
			If !Empty((ctmpDep)->RG_DATADEM)                                                                                                          // 12 - data de cancelamento MM/AAAA -032017
				cMontaTxt += subst((ctmpDep)->RG_DATADEM,7,2) + "/" + subst((ctmpDep)->RG_DATADEM,5,2) + "/" + subst((ctmpDep)->RG_DATADEM,1,4) + ";" 
			Else
				cPERINI := "01" + "/" + subst((ctmpDep)->RHL_PERFIM,1,2) + "/" + subst((ctmpDep)->RHL_PERFIM,3,4)
				cPERINI := StrZero(F_ULTDIA(CTOD(cPERINI)),2)
				cMontaTxt += cPERINI + "/" + subst((ctmpDep)->RHL_PERFIM,1,2) + "/" + subst((ctmpDep)->RHL_PERFIM,3,4) + ";"                          
			EndIf
			cMontaTxt += ";"                                                                                                                          // 13
			cMontaTxt += ";"                                                                                                                          //-14-Lote ou Chamado
			cMontaTxt += ";"                                                                                                                          //-15-Documento
			cMontaTxt += ";"                                                                                                                          //-16-Sequencia
			cMontaTxt += ";"                                                                                                                          //-17-Setor
			cMontaTxt += ";"                                                                                                                          //-18-Lotaçao
			cMontaTxt += ";"                                                                                                                          //-19-Local
			cMontaTxt += CHR(13) + CHR(10)
			AAdd(aLinhas,cMontaTxt)
			(ctmpDep)->(dBSkip())
		Enddo
		(ctmpDep)->(DbCloseArea())
		//DbSelectArea(ctmpExc)
		(ctmpExc)->(DbSkip())
	
	//gera dados dos agregados de cada titular excluido
	DbSelectArea(ctmpExc)
	(ctmpExc)->(DbGoTop())
	While !(ctmpExc)->(EOF())
		//montar query do agregados
		ctmpDep:=GetNextAlias()
		
		BeginSql Alias ctmpDep
			SELECT RHM_FILIAL,RHM_MAT,RHM_CODIGO,RHM_PERINI,RHM_PERFIM,RHM_XSTAT
			FROM %table:RHM% RHM
			WHERE RHM.RHM_FILIAL = %Exp:(ctmpExc)->RHK_FILIAL%
					AND RHM.RHM_MAT = %Exp:(ctmpExc)->RHK_MAT%
					AND RHM.RHM_PERFIM >= %Exp:cMyPerINI%
					AND ( RHM.RHM_PERFIM <= %Exp:cMyPerFIM% OR RHM.RHM_PERFIM > '' )
					AND RHM.RHM_TPFORN = %Exp:MV_PAR07%
					AND RHM.%NotDel%
		EndSql
		
		DbSelectArea(ctmpDep)
		(ctmpDep)->(DbGoTop())
		While !(ctmpDep)->(EOF())
			//monta o txt dos agregados a serem excluidos
			cMontaTxt := ""
			cMontaTxt += "Agregado" + ";"                                                                                                             // 1 verificar RHM_PERFIM
			cMontaTxt += ";"                                                                                                                          // 2 - branco
			cMontaTxt += ";"                                                                                                                          // 3 - branco
			cMontaTxt += ";"                                                                                                                          // 4 - branco
			cMontaTxt += (ctmpDep)->RHM_MAT + ";"                                                                                                     // 5 - matricula do titular
			cMontaTxt += ";"                                                                                                                          // 6 - branco
			cMontaTxt += (ctmpDep)->RHM_CODIGO + ";"                                                                                                  // 7 campo RHM_XCARTE ?
			cMontaTxt += Posicione("SRA",1,(ctmpDep)->RHM_FILIAL + (ctmpDep)->RHM_MAT,"RA_NOME") + ";"                                                // 8 - nome do titular
			cMontaTxt += SRA->RA_CIC + ";"                                                                                                            // 9 - CPF do titular
			cMontaTxt += subst((ctmpExc)->RG_DATADEM,7,2) + "/" + subst((ctmpExc)->RG_DATADEM,5,2) + "/" + subst((ctmpExc)->RG_DATADEM,1,4) + ";"     // 10 Data demissao , Informar a data DD/MM/AAAA - 20170313
			cMontaTxt += Posicione("SRB",1,(ctmpDep)->RHM_FILIAL + (ctmpDep)->RHM_MAT,"RB_NOME") + ";"                                                // 11 - nome do dependente
			If !Empty((ctmpExc)->RG_DATADEM)                                                                                                          // 12 - data de cancelamento MM/AAAA -032017
				cMontaTxt += subst((ctmpExc)->RG_DATADEM,7,2) + "/" + subst((ctmpExc)->RG_DATADEM,5,2) + "/" + subst((ctmpExc)->RG_DATADEM,1,4) + ";" 
			Else
				cPERINI := "01" + "/" + subst((ctmpExc)->RHM_PERFIM,1,2) + "/" + subst((ctmpExc)->RHM_PERFIM,3,4)
				cPERINI := StrZero(F_ULTDIA(CTOD(cPERINI)),2)
				cMontaTxt += cPERINI + "/" + subst((ctmpExc)->RHM_PERFIM,1,2) + "/" + subst((ctmpExc)->RHM_PERFIM,3,4) + ";"                          
			EndIf
			cMontaTxt += ";"                                                                                                                          // 13
			cMontaTxt += ";"                                                                                                                          //-14-Lote ou Chamado
			cMontaTxt += ";"                                                                                                                          //-15-Documento
			cMontaTxt += ";"                                                                                                                          //-16-Sequencia
			cMontaTxt += ";"                                                                                                                          //-17-Setor
			cMontaTxt += ";"                                                                                                                          //-18-Lotaçao
			cMontaTxt += ";"                                                                                                                          //-19-Local
			cMontaTxt += CHR(13) + CHR(10)
			AAdd(aLinhas,cMontaTxt)
			(ctmpDep)->(dBSkip())
		Enddo
		(ctmpDep)->(DbCloseArea())
		//DbSelectArea(ctmpExc)
		(ctmpExc)->(DbSkip())
	Enddo
	
	//fechar arquivos temporarios
	(ctmpExc)->(DbCloseArea())
	//(tmpDep)->(DbCloseArea())
	
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
