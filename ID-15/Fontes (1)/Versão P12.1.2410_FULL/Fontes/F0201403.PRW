#Include 'Protheus.ch'

/*
{Protheus.doc} F0201403()
Rotina para montar estrutura para gravação na PA0
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_014
*/
User Function F0201403()
	
	Local cPerg		:= "FSWSELARQ"
	PergArq()
	If Pergunte(cPerg, .T.)
		InfArq(MV_PAR01)
	EndIf
Return
/*
{Protheus.doc} InfArq()
Rotina para montar estrutura para gravação na PA0
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_014
@Param      cArq, Recebe o caminho do arquivo
*/
Static Function InfArq(cArq)
	Local aArray 		:= {}
	Local aAux			:= {}
	Local aTam			:= {11,60,45,8}
	Local nHandle 		:= 0
	Local nCnt			:= 0
	Local cLine 		:= ""
	Local lRet
	Local cNome

	PswOrder(1)
	PswSeek( __CUSERID, .T. )
	cNome := PSWRET()[1][4]
	
	
	If ! File(cArq)
		Help( ,, 'HELP',, "Arquivo não encontrado", 1, 0)
	Else
		nHandle := FT_FUse(cArq)
		if nHandle = -1
			Return
		endif
		
		FT_FGoTop()
		
		While !FT_FEOF()
			
			cLine  := FT_FReadLn()
			aArray := {}
			AAdd(aArray,SubStr( cLine, 1	, aTam[1] 	) )
			AAdd(aArray,SubStr( cLine, aTam[1] + 1	, aTam[2] 	) )
			AAdd(aArray,cNome)
			AAdd(aArray,DTOS(date()))
			AAdd(aAux,aArray)
			FT_FSKIP()
			
		End
		
		FT_FUSE()
		
		If Len(aAux) != 0
			Processa({|| GrvPa0(aAux)},"Aguarde...")
		Else
			Help( ,, 'HELP',, "Não foi criado novo registro", 1, 0)
		EndIf
	EndIf
Return
/*
{Protheus.doc} GrvPa0()
Rotina para montar estrutura para gravação na PA0
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_014
@Param      cArq, Recebe o caminho do arquivo
*/
Static Function GrvPa0(aAux)
	
	Local aArea     := GetArea()
	Local aAreaPA0  := PA0->(GetArea())
	Local nCnt      := 1
	Local cCpf      := ""
	Local cQuery    := ""
	Local cMsg      := ""
	local lRet
	
	cQuery := "DELETE " + RetSqlName("PA0") + ""
	TcSqlExec(cQuery)
	
	DbSelectArea("PA0")
	PA0->(DbSetOrder(1))
	ProcRegua(len(aAux))
	FOR nCnt := 1 TO Len(aAux)
		IncProc()
		If ! PA0->(DbSeek(xFilial("PA0") + aAux[nCnt][1]))
			cCpf := STRZERO(VAL(aAux[nCnt][1]),11,0)
			
			RECLOCK("PA0", .T.)
			PA0_FILIAL  := xFilial("PA0")
			PA0_XCPF    := cCpf           // CPF
			PA0_XNOME   := aAux[nCnt][2]  // Nome completo
			PA0_XRES    := aAux[nCnt][3]  // Nome do responsavel
			PA0_XDTI    := StoD(aAux[nCnt][4])// Data de inclusão
			PA0->(MsUnlock())
			GrvAlt(cCpf, DATE())
		EndIf
	NEXT nCnt
	
	If !(Empty(cMsg))
		Help( ,, 'HELP',, cMsg, 1, 0)
	EndIf
	
	RestArea(aAreaPA0)
	RestArea(aArea)
	
Return

/*
{Protheus.doc} PergArq()
Monta pergunta
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_014
@Return	 cDir, retorna o diretorio informado
*/
Static Function PergArq()
	Local cDir      := ""
	///Local cPerg     := "FSWSELARQ"
	Local cStringP  := ""
	Local aHelpPor  := {}
	
	AAdd( aHelpPor, "Selecione a pasta e o nome do arquivo a importar o cadastro de contra indicados." )
	cStringP := "Nome do arquivo a importar"
	
	cDir := MV_PAR01
	
Return cDir


//------------------------------------------------------------------------------------------------------------
/*
{Protheus.doc} GrvAlt()
Grava a alteração na tabela de log
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_014
@Param		 cCpf
@Param		 cData
*/
Static Function GrvAlt(cCpf, cData)
	Local aArea     := GetArea()
	Local aAreaPA1  := PA1->(GetArea())
	
	DbSelectArea("PA1")
	
	If !(EMPTY(cCpf))
		//Salvando o log
		RecLock("PA1", .T.)
		PA1_XCPF   := cCpf                    // CPF do contra indicado
		PA1_XDAT   := cData                   // data de alteração
		PA1_XUSUA  := UsrRetName(RetCodUsr()) // nome de quem alterou
		PA1_XTIPO  := "4"                     // Importado
		PA1->(MsUnlock())
	EndIf
	
	RestArea(aAreaPA1)
	RestArea(aArea)
Return
