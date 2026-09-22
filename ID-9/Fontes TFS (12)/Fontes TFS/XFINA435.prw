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
	Private cCadastro  := "Retorno Bancario Automatico (Pagar)" // "Retorno Bancario Automatico (Pagar)"

	Default cParm01 := ''
	Default cParm02 := ''

	If !empty(cParm01) .and. !empty(cParm02)
		aParam := {cParm01, cParm02}
	ElseIf !empty(cParm01) .and. Valtype(cParm01) == "A"
		aParam := {cParm01[1], cParm01[2]}
	Endif

	ConOut("*** INÍCIO - " + Dtoc(Date()) + " " + Time() + " - " + cCadastro)

	if Valtype(aParam) <> "A"
		ConOut("*** - " + "Processo pode ser executado apenas via Schedule") // "Processo pode ser executado apenas via Schedule"
	Else
		// Executa apenas se for chamado pelo Schedule.
		// As variáveis abaixo são úteis para debug da rotina via execução normal.
		Private lExecJob := .T.
		Private aMsgSch  := {}
		Private aFA205R  := {}

		// Manter posicionado pois o FINA200 vai utilizar estas informações.
		RpcSetEnv(aParam[1], aParam[2])

		BatchProcess(cCadastro, cCadastro, "FA435JOB", {|| FA435JOB()}, {|| .F. })

		// Se o parâmetro não está definido, envia as mensagens para o console.
		If empty(GetMv("MV_RETMAIL",, "")) .and. Len(aMsgSch) > 0
			For nCntFor := 1 to Len(aMsgSch)
				ConOut(aMsgSch[nCntFor])
			Next
		Endif

		RpcClearEnv()
	Endif

	ConOut("*** FIM - " + Dtoc(Date()) + " " + Time() + " - " + cCadastro)

Return

/*/{Protheus.doc} FA435JOB
Retorno de comunicação bancária a pagar - via Job.

@author  Aldo Barbosa dos Santos
@since   31/05/2011
/*/
Static Function FA435JOB()

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
	cQuery += "AND EE_DIRPAG <> ' ' OR EE_DIRPAG <> '' " // Somente contas com diretório preenchido.
	cQuery += "AND SEE.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY EE_DIRREC"
	cAlias := MPSysOpenQuery(cQuery)

	Do While (cAlias)->(!Eof())
		// Mantém posicionado pois o FINA430 vai utilizar estas informações.
		SEE->(dbGoto((cAlias)->REGSEE))

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

			// le os arquivos do diretorio configurado
			cDirArq := Alltrim(SEE->EE_DIRPAG)
			cDirBkp := Alltrim(SEE->EE_BKPPAG)

			// Verifica se os diretórios estão com a barra no final.
			If right(cDirArq, 1) <> cBarra
				cDirArq += cBarra
			Endif
			If !empty(cDirBkp) .and. right(cDirBkp, 1) <> cBarra
				cDirBkp += cBarra
			Endif

			// Lê os arquivos a serem processados.
			aArq := Directory(cDirArq + "*." + AllTrim(SEE->EE_EXTEN) + "*")
			If Empty(aArq) .and. AllTrim(cDirArq) == cBarra
				aArq    := Directory("*." + AllTrim(SEE->EE_EXTEN) + "*")
				cDirArq := ""
			Endif

			For nA := 1 to Len(aArq)
				// Armazena o nome do arquivo nos parâmetros.
				cArquivo := aArq[nA, 1]
				aVetPar[3, 2] := cDirArq + cArquivo
				//Pega o CNPJ da filial no arquivo
				cArqTxT := MemoRead( cDirArq + cArquivo )
				cCnPj := SubStr( cArqTxT, 19,14 )

				cFilSEE := fCodFilSm0(cCnPj) // Lucas Miranda de Aguiar
				If cFilSee <> xFilial("SEE")
					lOk := .F.
				Else
					lOk := .T.
				EndIf

				If lOk //Só vai executar a FINA 430 para os arquivos que forem da filial logada no momento
					// Atualiza o pergunte do FINR650.
					aVet650 := {{'mv_par01', cDirArq + cArquivo},;	// 01 Arquivo de Entrada ?
					{'mv_par02', SEE->EE_CFGPAG},;		// 02 Arquivo de Config ?
					{'mv_par03', SEE->EE_CODIGO},;		// 03 Codigo do Banco ?
					{'mv_par04', SEE->EE_AGENCIA},;		// 04 Codigo da Agencia ?
					{'mv_par05', SEE->EE_CONTA},;		// 05 Codigo da Conta ?
					{'mv_par06', SEE->EE_SUBCTA},;		// 06 Codigo da SubConta ?
					{'mv_par07', 2},;					// 07 Carteira ?  1=Receber;2=Pagar
					{'mv_par08', Val(SEE->EE_CNABPG)}}	// 08 Configuracao CNAB ?

					// Controle de mensagens de erro.
					aMsgSch := {}

					// Controle de titulos baixados utilizado no fina430
					aFA205R := {}

					// Executa a consistência antes de executar o recebimento.
					FINR650(aVet650)

					// Executa o programa de recebimento.
					FINA430(nil, aVetPar)

					// Verifica se o título foi baixado
					//fVldBaixa(cArqTxT)

					// Envia e-mail (FINA205) das mensagens de erro
					FA205MAIL("Retorno Bancario Automatico (Pagar)", cDirArq + cArquivo, aMsgSch) // "Retorno Bancario Automatico (Pagar)"

					If Len(aMsgSch) == 0
						If !empty(cDirBkp)
							// Move o arquivo processado para o diretório de backup.
							If fRename(cDirArq + cArquivo, cDirBkp + cArquivo) < 0
								ConOut("Não foi possível copiar o arquivo " + cDirArq + cArquivo + " para o diretório " + cDirBkp) // "Não foi possível copiar o arquivo " # " para o diretório "
								ConOut("fRename: " + "Erro " + cValToChar(FError()))  // "Erro "
							Endif
						Else
							// Exclui o arquivo processado.
							If fErase(cDirArq + cArquivo) < 0
								ConOut("Não foi possível excluir o arquivo " + cDirArq + cArquivo) // "Não foi possível excluir o arquivo "
								ConOut("fErase: " + "Erro " + cValToChar(FError()))  // "Erro "
							Endif
						Endif
					Endif
				EndIf
			Next nA
		Endif

		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea()) 
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
		cReturn := (cAlias)->M0_CODFIL
	EndIf

	(cAlias)->(DbCloseArea())
	RestArea(aArea)
Return cReturn

