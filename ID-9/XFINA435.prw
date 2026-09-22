#include "protheus.ch"
#include "fina435.ch"
#include "fileio.ch"
#INCLUDE "TopConn.ch"

/*/{Protheus.doc} FINA435
Retorno de comunicação bancária a pagar - via Job.

@param   cParm01    Código da empresa.
@param   cParm02    Código da filial.

@author  Aldo Barbosa dos Santos
@since   31/05/2011
/*/
User Function XFINA435(cParm01, cParm02)

	Local aParam
	Local nCntFor	
	Private cCadastro   := "Retorno Bancario Automatico (Pagar)" // "Retorno Bancario Automatico (Pagar)"
	Private aLogs 		:= {}
	Private cError 		:= ""

	Default cParm01 := ''
	Default cParm02 := ''

	If !empty(cParm01) .and. !empty(cParm02)
		aParam := {cParm01, cParm02}
	ElseIf !empty(cParm01) .and. Valtype(cParm01) == "A"
		aParam := {cParm01[1], cParm01[2]}
	Endif

	ConOut("*** INÍCIO - " + Dtoc(Date()) + " " + Time() + " - " + cCadastro)
	aAdd(aLogs, {"*** INÍCIO - " + Dtoc(Date()) + " " + Time() + " - " + cCadastro, ProcLine(0)})
	if Valtype(aParam) <> "A"
		ConOut("*** - " + "Processo pode ser executado apenas via Schedule") // "Processo pode ser executado apenas via Schedule"
	Else
		// Executa apenas se for chamado pelo Schedule.
		// As variáveis abaixo são úteis para debug da rotina via execução normal.
		Private lExecJob := .T.
		Private aMsgSch  := {}
		Private aFA205R  := {}

		// Manter posicionado pois o FINA200 vai utilizar estas informações.
		aAdd(aLogs, {"Antes do RPCSETENV [" + aParam[1] + aParam[2] + "]", ProcLine(0)})
		RpcSetEnv(aParam[1], aParam[2])
		lAtivaLog := SuperGetMv("MV_XLF435",,.T.)
		aAdd(aLogs, {"DEPOIS do RPCSETENV [" + cEmpAnt + cFilAnt + "]", ProcLine(0)})
		
		BatchProcess(cCadastro, cCadastro, "FA435JOB", {|| FA435JOB()}, {|| .F. })

		// Se o parâmetro não está definido, envia as mensagens para o console.
		If empty(GetMv("MV_RETMAIL",, "")) .and. Len(aMsgSch) > 0
			For nCntFor := 1 to Len(aMsgSch)
				ConOut(aMsgSch[nCntFor])
			Next
		Endif

		ConOut("*** FIM - " + Dtoc(Date()) + " " + Time() + " - " + cCadastro)
		aAdd(aLogs, {"*** FIM - " + Dtoc(Date()) + " " + Time() + " - " + cCadastro, ProcLine(0)})
		
		if lAtivaLog
			U_uLOGF435(aLogs,,cError)
		endif

		RpcClearEnv()
	Endif

Return

/*/{Protheus.doc} FA435JOB
Retorno de comunicação bancária a pagar - via Job.

@author  Aldo Barbosa dos Santos
@since   31/05/2011
/*/
Static Function FA435JOB()

	Local bError := ErrorBlock({|e| cError := e:ERRORSTACK })//ErrorBlock({|e| U_uLOGF435(,,e:Description) })
	Local cPerg	:= "AFI430"
	Local aVetPar // vetor das perguntas
	Local cQuery  // query de bancos que serao executados automaticamente
	Local cAlias  // alias temporario dos banco que serao executados
	Local cBarra := If(IsSrvUnix(), "/", "\")
	Local nA

	Local aArq
	Local cArquivo
	Local cDirArq
	Local cDirBkp

	Local lOk := .T.

	Private aRecSE5 := {}

	SEE->(dbsetorder(1))  // EE_FILIAL, EE_CODIGO, EE_AGENCIA, EE_CONTA, EE_SUBCTA.

// Lê as perguntas do FINA430 que serão modificadas de acordo com os novos campos da tabela de bancos.
// Pergunte(cPergunta,lAsk,cTitle,lOnlyView,oDlg,lUseProf,aPerg,lBreakLine,lHasHelp)
	Pergunte(cPerg, .F., Nil, Nil, Nil, .F.)

// Seleciona todas as contas que estão programadas para recebimento automático.
	cQuery := "SELECT R_E_C_N_O_ REGSEE "
	cQuery += "FROM " + RetSqlName("SEE") + " SEE "
	cQuery += "WHERE EE_FILIAL = '" + xFilial("SEE") + "' "
	cQuery += " AND EE_SUBCTA = '002' "
	cQuery += "AND EE_RETAUT IN ('2', '3') " // 1.recebimento; 2.pagamento; 3.ambos
	cQuery += "AND (EE_DIRPAG <> ' ' OR EE_DIRPAG <> '') " // Somente contas com diretório preenchido.
	cQuery += "AND SEE.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY EE_DIRREC"
	cAlias := MPSysOpenQuery(cQuery)

	aAdd(aLogs, {cQuery, ProcLine(0)})

	aAdd(aLogs, {"Inicio do While", ProcLine(0)})
	Do While (cAlias)->(!Eof())
		// Mantém posicionado pois o FINA430 vai utilizar estas informações.
		SEE->(dbGoto((cAlias)->REGSEE))

		aAdd(aLogs, {"Executando Loop da query na SEE.", ProcLine(0)})
		//aAdd(aLogs, {"Registro -> " + cValToChar((cAlias)->REGSEE), ProcLine(0)})
		
		// Verifica se todos os parâmetros necessários foram preechindos e grava no log.
		If !FA205ERRO()

			// Perguntas do FINA430
			// MV_PAR01: Mostra Lanc. Contab  ? Sim Nao
			// MV_PAR02: Aglutina Lanc. Contab? Sim Nao
			// MV_PAR03: Arquivo de Entrada   ?
			// MV_PAR04: Arquivo de Config    ?
			// MV_PAR05: Banco                ?
			// MV_PAR06: Agencia              ?
			// MV_PAR07: Conta                ?
			// MV_PAR08: SubConta             ?
			// MV_PAR09: Contabiliza          ?
			// MV_PAR10: Padrao Cnab          ? Modelo1 Modelo 2
			// MV_PAR11: Processa filiais     ? Modelo1 Modelo 2
			cDirInc := Alltrim(SEE->EE_INCPAG)
			// Atualiza o pergunte do FINA200 de acordo com a tabela de bancos
			aVetPar := {{'mv_par01', 2					},; // 01	Mostra Lanc Contab ?
			{'mv_par02', Val(SEE->EE_AGLCTB)},; // 02	Aglut Lancamentos ?
			{'mv_par03', SEE->EE_CFGREC		},; // 03	Arquivo de Entrada ?
			{'mv_par04', SEE->EE_CFGPAG		},; // 04	Arquivo de Config ?
			{'mv_par05', SEE->EE_CODIGO		},; // 05	Codigo do Banco ?
			{'mv_par06', SEE->EE_AGENCIA	},; // 06	Codigo da Agencia ?
			{'mv_par07', SEE->EE_CONTA		},; // 07	Codigo da Conta ?
			{'mv_par08', SEE->EE_SUBCTA		},; // 08	Codigo da Sub-Conta ?
			{'mv_par09', 2					},; // 09	Contabiliza On Line ?
			{'mv_par10', Val(SEE->EE_CNABPG)},; // 10	Configuracao CNAB ?
			{'mv_par11', Val(SEE->EE_PROCFL)},; // 11	Processa Filial?
			{'mv_par12', 2					}}  // 12	Considera Multiplas naturezas ?

			//aAdd(aLogs, {"aVetPar -> " + FWArrayToStr(aVetPar), ProcLine(0)})

			// le os arquivos do diretorio configurado
			cDirArq := Alltrim(SEE->EE_DIRPAG)
			cDirBkp := Alltrim(SEE->EE_BKPPAG)

			//aAdd(aLogs, {"cDirArq -> " + cDirArq, ProcLine(0)})
			//aAdd(aLogs, {"cDirBkp -> " + cDirBkp, ProcLine(0)})

			// Verifica se os diretórios estão com a barra no final.
			If right(cDirArq, 1) <> cBarra
				cDirArq += cBarra
			Endif
			If !empty(cDirBkp) .and. right(cDirBkp, 1) <> cBarra
				cDirBkp += cBarra
			Endif

			// Lê os arquivos a serem processados.
			aArq := Directory(cDirArq + "*." + AllTrim(SEE->EE_EXTEN) + "*")

			//aAdd(aLogs, {"aArq -> " + FWArrayToStr(aArq), ProcLine(0)})

			If Empty(aArq) .and. AllTrim(cDirArq) == cBarra
				aArq    := Directory("*." + AllTrim(SEE->EE_EXTEN) + "*")
				cDirArq := ""
				aAdd(aLogs, {"entrou no if Empty(aArq) .and. AllTrim(cDirArq) == cBarra", ProcLine(0)})
			Endif

			For nA := 1 to Len(aArq)

				//aAdd(aLogs, {"For nA aArq -> " + cValToChar(nA), ProcLine(0)})
				// Armazena o nome do arquivo nos parâmetros.
				cArquivo := aArq[nA, 1]
				aVetPar[3, 2] := cDirArq + cArquivo
				//aAdd(aLogs, {"aVetPar[3, 2] -> " + aVetPar[3, 2], ProcLine(0)})
				//Pega o CNPJ da filial no arquivo
				cArqTxT := MemoRead( cDirArq + cArquivo )
				cCnPj := SubStr( cArqTxT, 19,14 )
				//aAdd(aLogs, {"cCnPj -> " + cCnPj, ProcLine(0)})

				cFilSEE := fCodFilSm0(cCnPj) // Lucas Miranda de Aguiar
				//aAdd(aLogs, {"cFilSEE -> " + cFilSEE, ProcLine(0)})

				If cFilSee <> xFilial("SEE")
					lOk := .F.
				Else
					lOk := .T.
				EndIf

				If lOk //Só vai executar a FINA 430 para os arquivos que forem da filial logada no momento
					// Atualiza o pergunte do FINR650.
					aAdd(aLogs, {"Achou a filial e o arquivo!", ProcLine(0)})
					aAdd(aLogs, {"cCnPj -> " + cCnPj + "cFilSEE -> " + cFilSEE, ProcLine(0)})

					aVet650 := {{'mv_par01', cDirArq + cArquivo},;	// 01 Arquivo de Entrada ?
					{'mv_par02', SEE->EE_CFGPAG},;		// 02 Arquivo de Config ?
					{'mv_par03', SEE->EE_CODIGO},;		// 03 Codigo do Banco ?
					{'mv_par04', SEE->EE_AGENCIA},;		// 04 Codigo da Agencia ?
					{'mv_par05', SEE->EE_CONTA},;		// 05 Codigo da Conta ?
					{'mv_par06', SEE->EE_SUBCTA},;		// 06 Codigo da SubConta ?
					{'mv_par07', 2},;					// 07 Carteira ?  1=Receber;2=Pagar
					{'mv_par08', Val(SEE->EE_CNABPG)}}	// 08 Configuracao CNAB ?

					aAdd(aLogs, {"aVet650 -> " + FWArrayToStr(aVet650), ProcLine(0)})
					// Controle de mensagens de erro.
					aMsgSch := {}

					// Controle de titulos baixados utilizado no fina430
					aFA205R := {}

					// Executa a consistência antes de executar o recebimento.
					//aAdd(aLogs, {"Antes do FINR650", ProcLine(0)})
					//FINR650(aVet650)
					//aAdd(aLogs, {"Depois do FINR650", ProcLine(0)})

					// Executa o programa de recebimento.
					aAdd(aLogs, {"Antes do FINA430", ProcLine(0)})
					FINA430(nil, aVetPar)
					aAdd(aLogs, {"Depois do FINA430", ProcLine(0)})
					aAdd(aLogs, {"aMsgSch - >" + FWArrayToStr(aMsgSch), ProcLine(0)})

					// Verifica se o título foi baixado
					//fVldBaixa(cArqTxT)

					// Envia e-mail (FINA205) das mensagens de erro
					//aAdd(aLogs, {"Antes do FA205MAIL", ProcLine(0)})
					//FA205MAIL("Retorno Bancario Automatico (Pagar)", cDirArq + cArquivo, aMsgSch) // "Retorno Bancario Automatico (Pagar)"
					//aAdd(aLogs, {"Depois do FA205MAIL", ProcLine(0)})

					If Len(aMsgSch) == 0
						If !empty(cDirBkp)
							// Move o arquivo processado para o diretório de backup.
							If fRename(cDirArq + cArquivo, cDirBkp + cArquivo) < 0
								ConOut("Não foi possível copiar o arquivo " + cDirArq + cArquivo + " para o diretório " + cDirBkp) // "Não foi possível copiar o arquivo " # " para o diretório "
								ConOut("fRename: " + "Erro " + cValToChar(FError()))  // "Erro "
								aAdd(aLogs, {"Não foi possível copiar o arquivo " + cDirArq + cArquivo + " para o diretório " + cDirBkp, ProcLine(0)})
								aAdd(aLogs, {"fRename: " + "Erro " + cValToChar(FError()), ProcLine(0)})
							else
								aAdd(aLogs, {"Arquivo copiado para pasta " + cDirBkp + cArquivo, ProcLine(0)})
							Endif
						Else
							// Exclui o arquivo processado.
							If fErase(cDirArq + cArquivo) < 0
								ConOut("Não foi possível excluir o arquivo " + cDirArq + cArquivo) // "Não foi possível excluir o arquivo "
								ConOut("fErase: " + "Erro " + cValToChar(FError()))  // "Erro "
								aAdd(aLogs, {"Não foi possível excluir o arquivo " + cDirArq + cArquivo, ProcLine(0)})
								aAdd(aLogs, {"fRename: " + "Erro " + cValToChar(FError()), ProcLine(0)})
							else
								aAdd(aLogs, {"Arquivo excluido da pasta " + cDirArq + cArquivo, ProcLine(0)})
							Endif
						Endif
					Else
						cPathArq := cDirArq + cArquivo
						cPathInc := cDirInc + cArquivo
						if Empty(cDirInc)
							ConOut("O diretório de incidentes está vazio. Alltrim(SEE->EE_INCPAG)") // "Não foi possível copiar o arquivo " # " para o diretório "
							aAdd(aLogs, {"O diretório de incidentes está vazio. Alltrim(SEE->EE_INCPAG)", ProcLine(0)})
						else
							_CopyFile(cPathArq, cPathInc) //copia o arquivo para o diretorio de Inconsistencia.
							if !File(cPathInc)//Verifica a existencia do arquivo
								ConOut("Não foi possível copiar o arquivo " + cPathArq + " para o diretório " + cDirInc) // "Não foi possível copiar o arquivo " # " para o diretório "
								aAdd(aLogs, {"Não foi possível copiar o arquivo " + cPathArq + " para o diretório " + cDirInc, ProcLine(0)})
							Else
								aAdd(aLogs, {"Copiou o arquivo para pasta de inconsistências! " + cPathInc, ProcLine(0)})
								FErase(cPathArq)
								aAdd(aLogs, {"Apagou o arquivo: " + cPathArq, ProcLine(0)})
							EndIf
						endif
					EndIf
				Endif
			Next nA
			//aAdd(aLogs, {"Fim do For -> Next nA", ProcLine(0)})
		Endif
		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())
	aAdd(aLogs, {"Fim While", ProcLine(0)})

	ErrorBlock(bError)
Return


//Função que retorna o código da filial pelo CNPJ.
Static Function fCodFilSm0(cCnPj)

	Local aArea := GetArea()
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local cReturn := ""


	cQuery += " SELECT M0_CODFIL FROM SYS_COMPANY WHERE M0_CGC = '"+AllTrim(cCnPj)+"' AND D_E_L_E_T_ = ' '"

	cAlias := MPSysOpenQuery(cQuery)

	If (cAlias)->(!Eof())
		cReturn := AllTrim((cAlias)->M0_CODFIL)
	EndIf

	(cAlias)->(DbCloseArea())
	RestArea(aArea)
Return cReturn

/*/{Protheus.doc} GravaLog
Grava log em outro local deifindo pelo usuario.
@type function
@version P12  
@author Ricardo Junior.
@since 2/24/2026
@param aDados, array, mensagens de log
@return variant, nulo
/*/
Static Function GravaLog(aDados, cFilSEE)
	Local cArquivo := GetSrvProfString("RootPath", "") + "\log_schedule\"+ cFilSEE + "\" + DToS(Date()) + ".log"
	Local nHandle  := 0
	Local cConteudo := ""
	Local nI

	// Junta tudo em uma string só
	For nI := 1 To Len(aDados)
		cConteudo += aDados[nI] + CRLF
	Next nI

	nHandle := FOpen(cArquivo, FO_READWRITE)

	If nHandle == -1
		nHandle := FCreate(cArquivo, FC_NORMAL)
	Else
		FSeek(nHandle, 0, FS_END)
	EndIf

	If nHandle != -1
		FWrite(nHandle, cConteudo, Len(cConteudo))
		FClose(nHandle)
	else
		conout("ERRO ao tentar criar arquivo de log: "+ cArquivo)
	EndIf

Return
