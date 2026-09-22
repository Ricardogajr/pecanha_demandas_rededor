#include "protheus.ch"
#include "fina435.ch"
#include "fileio.ch"
#INCLUDE "TopConn.ch"

/*/{Protheus.doc} XFIN435X
Retorno de comunicação bancária a pagar - via Job. 
Nova Rotina para varrer as pastas definidas na SEE e importar os arquivos independente das filiais configuradas no schedule

@param   cParm01    Código da empresa.
@param   cParm02    Código da filial.

@author  Lucas Miranda / Ramon Teodoro
@since   06/09/2024
/*/
User Function XFIN435X(cParm01, cParm02)

	Local aParam
	Local nCntFor
	Local aTables := {"CT1","CT2","CT3","CT4","CT5","CTF","CTE","SE2","SE5"}
	Local cBco := ""
	Private cCadastro  := "Retorno Bancario Automatico (Pagar)" // "Retorno Bancario Automatico (Pagar)"
	Private aSchnExist  := {}

	Default cParm01 := ''
	Default cParm02 := ''

	If !empty(cParm01) .and. !empty(cParm02)
		aParam := {cParm01, cParm02}
	ElseIf !empty(cParm01) .and. Valtype(cParm01) == "A"
		aParam := {cParm01[2], cParm01[3]}
	Endif

	cBco := cParm01[1]


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
		//RpcSetEnv(aParam[1], aParam[2])
		RpcSetEnv( aParam[1],aParam[2],,,"FIN", "FINA430", aTables, , , , )

		BatchProcess(cCadastro, cCadastro, "FA435JOB", {|| FA435JOB(cBco)}, {|| .F. })

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
Static Function FA435JOB(cBanco)


	Local cQuery  // query de bancos que serao executados automaticamente
	Local cAlias  // alias temporario dos banco que serao executados
	Local cBarra := If(IsSrvUnix(), "/", "\")
	Local nA
	Local aArq     := {}
	Local cArquivo := ""
	Local cDirArq  := ""
	Local cDirBkp  := ""
	Local cFil430  := ""
	Local aFin430 := {}
	Local aLidos  := {}
	Local cBco		:= ""
	Local cAlias2	:= GetNextAlias()

	Private aRecSE5 := {}

	Default cBanco := ""

	SEE->(dbsetorder(1))  // EE_FILIAL, EE_CODIGO, EE_AGENCIA, EE_CONTA, EE_SUBCTA.

	cQuery := " SELECT EE_DIRPAG DIRPAG, EE_BKPPAG BKPPAG FROM " +RetSqlName("SEE")+ " EE "
	cQuery += " WHERE EE_SUBCTA = '002' "
	cQuery += " AND EE_DIRPAG <> ' ' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	If !Empty(cBanco)
		cQuery += " AND EE_CODIGO = '"+cBanco+"' "
	EndIf
	cQuery += " GROUP BY EE_DIRPAG,EE_BKPPAG "

	cAlias := MPSysOpenQuery(cQuery)

	Do While (cAlias)->(!Eof())

		// le os arquivos do diretorio configurado
		cDirArq := Alltrim((cAlias)->DIRPAG)
		cDirBkp := Alltrim((cAlias)->BKPPAG)

		// Verifica se os diretórios estão com a barra no final.
		If right(cDirArq, 1) <> cBarra
			cDirArq += cBarra
		Endif
		If !empty(cDirBkp) .and. right(cDirBkp, 1) <> cBarra
			cDirBkp += cBarra
		Endif

		// Lê os arquivos a serem processados.
		aArq := Directory(cDirArq + "*.RET*")
		If Empty(aArq) .and. AllTrim(cDirArq) == cBarra
			aArq    := Directory("*.RET*")
			cDirArq := ""
		Endif

		For nA := 1 to Len(aArq)

			// Armazena o nome do arquivo nos parâmetros.
			cArquivo := aArq[nA, 1]

			//Pega o CNPJ da filial no arquivo
			cArqTxT := MemoRead( cDirArq + cArquivo )
			cCnPj := SubStr( cArqTxT, 19,14 )
			cBco := SubStr( cArqTxT, 1,3 )


			cFilSEE := fCodFilSm0(cCnPj) // Lucas Miranda de Aguiar
			cFilAnt := cFilSEE

			cQuery := "SELECT R_E_C_N_O_ REGSEE "
			cQuery += "FROM " + RetSqlName("SEE") + " SEE "
			cQuery += "WHERE EE_FILIAL = '" + xFilial("SEE") + "' AND EE_CODIGO = '"+cBco+"' "
			cQuery += "AND EE_RETAUT IN ('2', '3') " // 1.recebimento; 2.pagamento; 3.ambos
			cQuery += "AND (EE_DIRPAG <> ' ' OR EE_DIRPAG <> ' ') " // Somente contas com diretório preenchido.
			cQuery += "AND SEE.D_E_L_E_T_ = ' ' AND SEE.EE_SUBCTA = '002' "
			cQuery += "ORDER BY EE_FILIAL"
			cAlias2 := MPSysOpenQuery(cQuery)

			If (cAlias2)->(EOF())
				Conout("Não foi encontrado o código de banco " +cBco + " na filial " +cFilSEE+ " verifique o cadastro da filial na SEE! Caso a filial seja de outro sistema, ignore esta mensagem, o arquivo não será processado!")
				Loop
			EndIf

			AADD(aFin430,cFilSEE)
			AADD(aFin430,{cDirArq,cArquivo,(cAlias2)->REGSEE,cDirBkp})
			(cAlias2)->(dbCloseArea())
			U_XFIN43XJOB(cEmpAnt,aFin430[1],aFin430)
			aFin430 := {}
		Next nA

		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())
Return


//Função que retorna o código da filial pelo CNPJ.
Static Function fCodFilSm0(cCnPj)

	Local aArea := GetArea()
	Local nX := 1
	Local aInfSM0 := FWLoadSM0()
	Local cReturn := ""

	Default cCnPj := ""

	For nX := 01 To Len(aInfSM0)

		If AllTrim(aInfSM0[nX][18]) == AllTrim(cCnPj)

			cReturn := AllTrim(aInfSM0[nX][2])
			Exit
		EndIf
	Next nX

	RestArea(aArea)
Return cReturn

/*/{Protheus.doc} XFIN435JOB
Função para otimizar a rotina XFIN435X, realizando a baixa por filial via StartJob
Trazida do fonte XFIN435XJOB.PRW para cá.

@param   cParm01    Código da empresa.
@param   cParm02    Código da filial.

@author  Lucas Miranda de Aguiar
@since   03/06/2024
/*/

User Function XFIN43XJOB(cEmp,cFil430,aFina430)

	Local cPerg	:= "AFI430"
	Local nA
	Local aTables := {"CT1","CT2","CT3","CT4","CT5","CTF","CTE","SE2","SE5"}
	Local cDirArq := ""
	Local cArquivo := ""
	Local lnExist := .F.
	Local cDirnExist := ""
	Local cBarra := If(IsSrvUnix(), "/", "\")

	Private aRecSE5 := {}

	Default cFil430 := ""
	Default aFina430 := ""
	Default cEmp := ""

	//RpcSetType(3)
	//RpcSetEnv( cEmp,cFil430,,,"FIN", "U_XF435J", aTables, , , , )

	For nA := 01 To Len(aFina430)

		If nA == 01
			cFilant := aFina430[nA]
			Loop
		EndIf
// Mantém posicionado pois o FINA430 vai utilizar estas informações.
		Pergunte(cPerg, .F., Nil, Nil, Nil, .F.)
		DbSelectArea("SEE")
		SEE->(dbGoto(aFina430[nA][03]))
		cDirArq := aFina430[nA][01]
		cDirBkp := aFina430[nA][04]
		cArquivo := aFina430[nA][02]

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
			aVetPar[3, 2] := cDirArq + cArquivo
			cDirnExist := AllTrim(SEE->EE_INCPAG)
			If !empty(cDirnExist) .and. right(cDirnExist, 1) <> cBarra
				cDirnExist += cBarra
			Endif
			// Executa a consistência antes de executar o recebimento.
			Conout("Executando FINR650 arquivo " + cDirArq + cArquivo + " ")
			FINR650(aVet650)

			// Executa o programa de recebimento.
			Conout("Executando FINA430 arquivo " + cDirArq + cArquivo + " ")
			FINA430(nil, aVetPar)

			// Envia e-mail (FINA205) das mensagens de erro
			Conout("Executando FA205MAIL arquivo " + cDirArq + cArquivo + " ")
			If !Empty(aSchnExist)
				lnExist := .T.
				For nA := 01 To Len(aSchnExist)
					AADD(aMsgSch,aSchnExist[nA])
				Next nA
			EndIf

			FA205MAIL("Retorno Bancario Automatico (Pagar)", cDirArq + cArquivo, aMsgSch) // "Retorno Bancario Automatico (Pagar)"

			If lnExist //Caso algum titulo do arquivo não exista
				If !empty(cDirnExist)
					// Move o arquivo processado para o diretório de backup.
					If fRename(cDirArq + cArquivo, cDirnExist + cArquivo) < 0
						If fRename(cDirArq + cArquivo, cDirBkp + cArquivo) < 0
							ConOut("Não foi possível copiar o arquivo " + cDirArq + cArquivo + " para o diretório " + cDirBkp) // "Não foi possível copiar o arquivo " # " para o diretório "
							ConOut("fRename: " + "Erro " + cValToChar(FError()))  // "Erro "
						Endif
					Endif
				Else
					//Copia para o diretorio original
					If fRename(cDirArq + cArquivo, cDirBkp + cArquivo) < 0
						ConOut("Não foi possível copiar o arquivo " + cDirArq + cArquivo + " para o diretório " + cDirBkp) // "Não foi possível copiar o arquivo " # " para o diretório "
						ConOut("fRename: " + "Erro " + cValToChar(FError()))  // "Erro "
					Endif
				Endif
			Else
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
		EndIf
	Next nA

	Conout("Finalizou arquivo " + cDirArq + cArquivo + " ")
	//RpcClearEnv()
Return
