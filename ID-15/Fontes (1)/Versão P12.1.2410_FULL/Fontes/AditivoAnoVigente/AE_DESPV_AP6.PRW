#include "protheus.ch"
#INCLUDE "AE_Despv_Ap6.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AE_DESPV  ºAutor  ³Armando / Willy     º Data ³  09/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ MBrowse das Despesas com Viagem.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AE_DespV()

	Local aOpcAdc	:= {}
	Local cFilMbrPE := ""
	Local cFiltro   := ""

	Private aCores		:= {}
	Private cCadastro	:= ""
	Private aRotina 	:= MenuDef()

	//ChkUser("CDV")

	cCadastro  := STR0001 //"Prestação de Contas"

	// V - Verde     -> Colaborador Viajando
	// D - Amarela   -> Iniciado Processo de Acerto
	// L - Laranja   -> Encaminhado e Aguardando Confirmacao
	// C - Vermelho  -> Autorizado e Liberado
	// Z - Cinza     -> Fechamento da Viagem
	// M - Marrom    -> Iniciado a Prestação de Contas sem Solicitação
	// B - Branco    -> Prestação de Contas sem Solicitação
	// P - Preto     -> Processo de acerto em atraso
	// K - Pink		 -> Solicitacoes canceladas

	aCores := {	{ 'LHQ_Flag = "V" ', 'BR_VERDE'    	},;
	{ 'LHQ_Flag = "D" ', 'BR_AMARELO'  	},;
	{ 'LHQ_Flag = "L" ', 'BR_LARANJA'  	},;
	{ 'LHQ_Flag = "C" ', 'BR_VERMELHO' 	},;
	{ 'LHQ_Flag = "Z" ', 'BR_CINZA'    	},;
	{ 'LHQ_Flag = "M" ', 'BR_MARROM'   	},;
	{ 'LHQ_Flag = "B" ', 'BR_BRANCO'   	},; 
	{ 'LHQ_Flag = "K" ', 'BR_PINK'   	},;
	{ 'LHQ_Flag = "P" ', 'BR_PRETO'    	},;
	{ 'LHQ_Flag = "E" ', 'BR_AZUL'    	}}

	If ExistBlock("AE_DVMENU")
		aOpcAdc := ExecBlock("AE_DVMENU",.F.,.F.)
		If ValType(aOpcAdc) == "A"
			If !Empty(aOpcAdc) .AND. Len(aOpcAdc) >= 4
				aAdd(aRotina, aOpcAdc)
			Endif
		Endif
	Endif

	If ExistBlock("AE_DVFILT") //-- PE - Permite ao usuario filtrar a mbrowse
		cFilMbrPE := ExecBlock("AE_DVFILT",.F.,.F.)
		If ValType(cFilMbrPE) == "C" .And. !Empty(cFilMbrPE)
			cFiltro += cFilMbrPE
		EndIf
	EndIf

	dbSelectArea('LHQ')   
	mBrowse(6, 1, 22, 75,"LHQ",,,,,, aCores,,,,,,,,cFiltro) ////mBrowse(6, 1, 22, 75,"LHQ",,,,,, aCores)
	LHQ->(dbClearFilter())

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³08/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
	Local aRotina := {}   

	aAdd(aRotina, {STR0002	,'AxPesqui'		,0	,1}) //"Pesquisa"
	aAdd(aRotina, {STR0003	,'U_AE_SV001(0)',0	,2}) //"Visualiza"
	aAdd(aRotina, {STR0004	,'U_AE_DV001(1)',0	,3}) //"Despesas"
	aAdd(aRotina, {STR0005	,'U_AE_DV001(2)',0	,3}) //"Avulso"
	aAdd(aRotina, {STR0006	,'U_AE_DV003'	,0	,4}) //"Liberar"
	aAdd(aRotina, {STR0007	,'U_AE_DV006'	,0	,4}) //"Fechamento"
	aAdd(aRotina, {STR0008	,'U_LibAtraso'	,0	,4}) //"Lib.Atraso"
	aAdd(aRotina, {STR0009	,'U_VerAtraso'	,0	,4}) //"Manutenção"
	aAdd(aRotina, {STR0010	,'U_AE_DV002'	,0	,2}) //"Imprime"
	aAdd(aRotina, {STR0012	,'U_AE_DVCANC()',0	,5,,}) //"Cancelamento"
	aAdd(aRotina, {STR0015	,'U_AE_DVEXC()'	,0	,5,,}) //"Excluir"
	aAdd(aRotina, {STR0011	,'U_AE_DV004'	,0	,2,,.F.}) //"Legenda"



Return(aRotina)                           



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AE_DESPV  ºAutor  ³Leandro Sousa       º Data ³  22/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cancelamento de despesas avulsas.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AE_DVCANC()

	Local aArea			:= GetArea()
	Local lRet			:= .F. 
	Local cPrefReem		:= GetMV("MV_PREREEM")
	Local cParcReem		:= GetMV("MV_PARREEM")
	Local cTipoReem		:= GetMV("MV_TIPREEM")
	Local cNumReem		:= ""
	Local cForReem		:= ""
	Local cLojReem		:= ""
	Local lCanc         := .F.

	If Empty(cPrefReem)
		cPrefReem := Space(TamSX3("E2_PREFIXO")[1])
	Else
		cPrefReem := PadR(cPrefReem,TamSX3("E2_PREFIXO")[1])	
	EndIf

	If Empty(cParcReem)
		cParcReem := Space(TamSX3("E2_PARCELA")[1])
	Else
		cParcReem := PadR(cParcReem,TamSX3("E2_PARCELA")[1])
	EndIf

	If Empty(cTipoReem)
		cTipoReem := Space(TamSX3("E2_TIPO")[1])     
	Else
		cTipoReem := PadR(cTipoReem,TamSX3("E2_TIPO")[1])
	EndIf

	dbSelectArea("LHQ")

	If LHQ->LHQ_Flag = "K"
		Alert(STR0021) //Despesa já cancelada.
	ElseIf lRet := MsgYesNo(STR0013)

		DbSelectArea("LHP")
		LHP->(DbSetOrder(1))
		LHP->(DbSeek(xFilial("LHP")+LHQ->LHQ_CODIGO))
		cNumReem := PadR(LHP->LHP_CODIGO,TamSX3("E2_NUM")[1])

		DbSelectArea("SA2")
		SA2->(DbOrderNickName("SA2CDV6"))
		SA2->(DbSeek(xFilial("SA2")+LHP->LHP_FUNC))
		cForReem := SA2->A2_COD
		cLojReem := SA2->A2_LOJA

		DbSelectArea("SE2")
		SE2->(DbSetOrder(1))
		If SE2->(DbSeek(xFilial("SE2")+cPrefReem+cNumReem+cParcReem+cTipoReem+cForReem+cLojReem))

			If SE2->E2_SALDO == SE2->E2_VALOR .And. Empty(SE2->E2_BAIXA) .And. Empty(SE2->E2_NUMBOR)

				lCanc := U_AE_EXCSE2( .F. , SE2->(RECNO()) )

				If lCanc 
					RecLock("LHQ",.F.)
					Replace LHQ->LHQ_FLAG With "K"
					MsUnLock()
				Else
					MsgAlert("Existe um título gerado no financeiro, para concluir essa operação é necessário estorná-lo", "Operação não permitida!")
				EndIf
			Else
				If !Empty(SE2->E2_NUMBOR)
					Alert(STR0022+SE2->E2_NUMBOR)
				Else
					Alert(STR0018 + CRLF + STR0019)
				Endif		
			EndIf
		Else	
			RecLock("LHQ",.F.)
			Replace LHQ->LHQ_FLAG With "K"
			MsUnLock()
		EndIf
	EndIf

	RestArea(aArea)

Return lRet   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AE_DESPV  ºAutor  ³Leandro Sousa       º Data ³  22/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exclusao de despesas avulsas.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AE_DVEXC()
	Local aArea			:= GetArea()
	Local lRet			:= .F.
	Local cPrefReem		:= GetMV("MV_PREREEM")
	Local cParcReem		:= GetMV("MV_PARREEM")
	Local cTipoReem		:= GetMV("MV_TIPREEM")
	Local cCodigo		:= ""
	Local cNumReem		:= ""
	Local cForReem		:= ""
	Local cLojReem		:= ""
	Local cChvSE2		:= ""
	Local nTamChv		:= 0
	Local lExc			:= .F.

	nTamChv := TamSX3("E2_FILIAL")[1] + TamSX3("E2_PREFIXO")[1] + TamSX3("E2_NUM")[1] + TamSX3("E2_PARCELA")[1] + TamSX3("E2_TIPO")[1] + TamSX3("E2_FORNECE")[1] + TamSX3("E2_LOJA")[1]

	If Empty(cPrefReem)
		cPrefReem := Space(TamSX3("E2_PREFIXO")[1])
	Else
		cPrefReem := PadR(cPrefReem,TamSX3("E2_PREFIXO")[1])	
	EndIf

	If Empty(cParcReem)
		cParcReem := Space(TamSX3("E2_PARCELA")[1])
	Else
		cParcReem := PadR(cParcReem,TamSX3("E2_PARCELA")[1])
	EndIf

	If Empty(cTipoReem)
		cTipoReem := Space(TamSX3("E2_TIPO")[1])     
	Else
		cTipoReem := PadR(cTipoReem,TamSX3("E2_TIPO")[1])
	EndIf

	dbSelectArea("LHQ")

	DbSelectArea("LHP")
	LHP->(DbSetOrder(1))

	If LHQ->LHQ_TPDES == "A" .And. LHQ->LHQ_Flag == "K"
		lRet := MsgYesNo(STR0017)
	ElseIf LHQ->LHQ_TPDES == "A" .And. !(IsInCallStack("U_AE_ESTLIB"))
		lRet := MsgYesNo(STR0016)
	Else
		// Na primeira chamada da função AE_EXCSE2 a função verificar se houve baixas.
		// Guardo o conteudo do Campo LHQ_CODIGO para ter controle do que foi excluido ou não.
		LHP->( DbSeek( xFilial("LHP") + LHQ->LHQ_CODIGO ) )
		cCodigo := LHQ->LHQ_CODIGO
		cChvSE2 := PadR( LHP->LHP_DOCUME, nTamChv )
		lRet 	:= U_AE_EXCSE2( .T. )
		lExc	:= .T.
	EndIf

	If lRet .And. lExc

		If LHP->( DbSeek( xFilial("LHP") + cCodigo ) )

			cNumReem := PadR( LHP->LHP_CODIGO, TamSX3("E2_NUM")[1] )

			If !Empty(LHP->LHP_DOCUME)
				cChvSE2 := PadR( LHP->LHP_DOCUME, nTamChv )
			EndIf

			If Empty(cChvSE2)
				DbSelectArea("SA2")
				SA2->(DbOrderNickName("SA2CDV6"))
				If SA2->( DbSeek(xFilial("SA2") + LHP->LHP_FUNC ) )
					cForReem := SA2->A2_COD
					cLojReem := SA2->A2_LOJA
				EndIf

				cChvSE2 := xFilial("SE2") + cPrefReem + cNumReem + cParcReem + cTipoReem + cForReem + cLojReem
			EndIf

			// Se o titulo for encontrado na SE2 mesmo após já ter executado a chamada da função U_AE_EXCSE2( .T. )
			// significa que o titulo não possuia baixas, desta forma posiciono do titulo e faço a exclusão
			DbSelectArea("SE2")
			SE2->(DbSetOrder(1))
			If SE2->( DbSeek( cChvSE2 ) )

				If SE2->E2_SALDO == SE2->E2_VALOR .And. Empty(SE2->E2_BAIXA) .And. Empty(SE2->E2_NUMBOR) // Se o Titulo possui o E2_Saldo igual ao E2_Valor e o campo data de Baixa estiver vazio o titulo não possui baixas 

					U_AE_EXCSE2( .F., SE2->(RECNO()) )// U_AE_EXCSE2( lTemBaixa, nRecno )

				Else
					Alert( STR0018 + CRLF + STR0020 )
					lRet := .F.	
				EndIf
			Else
				DVAVExc()
			EndIf
		EndIF
	EndIf

	RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AE_DESPV  ºAutor  ³Flavio Vilarim      º Data ³  23/10/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exclusao dos registros da despesas avulsas. LHQ, LHP e LHR  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                         
Static Function DVAVExc()  

	If IsInCallStack("U_AE_ESTLIB")

		RecLock("LHP",.F.)
		LHP->LHP_FLAG   := 'A'
		LHP->LHP_FLAG1  := 'A'
		LHP->LHP_XESTIT := 'S'
		LHP->LHP_DOCUME := Space(TamSX3("LHP_DOCUME")[1])
		If IsInCallStack("U_AE_FINAN")
			LHP->LHP_OKADIA := .F. 
		EndIf
		MsUnLock("LHP")	

		RecLock("LHQ",.F.)
		LHQ->LHQ_Flag	:= 'L'
		LHQ->LHQ_DFECHA := CtoD("")
		MsUnLock("LHQ")	
	Else

		RecLock("LHQ",.F.)
		DbDelete()
		MsUnLock()	

		RecLock("LHP",.F.)
		DbDelete()
		MsUnLock()

		DbSelectArea("LHR")
		LHR->(DbSetOrder(1))
		If (DbSeek(xFilial("LHQ")+LHQ->LHQ_CODIGO)) 
			While !Eof() .And. xFilial("LHR")+LHR->LHR_CODIGO  ==  xFilial("LHQ")+LHQ->LHQ_CODIGO 
				RecLock("LHR",.F.)
				DbDelete()
				MsUnLock()
				dbSkip()
			EndDo 
		EndIf	

	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AE_DESPV  ºAutor  ³Rodrigo Oliveira    º Data ³  04/12/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exclusao de despesas no Financeiro.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AE_EXCSE2( lTemBaixa, nRecSe2 )

	Local aArea		:= GetArea()
	Local lRet		:= .F.
	Local cQuery	:= "" 
	Local lFunname	:= FunName() $ "FINA050|FINA750"
	Local cTit		:= ""
	Local aDados	:= {}
	Local cTmp		:= ""

	//-- Variáveis utilizadas para o controle de erro da rotina automática
	Private lMsErroAuto		:= .F.

	Default lTemBaixa	:= .T.
	Default nRecSe2		:= 0

	If lTemBaixa // Verifico se tem baixa para o titulo
		If lFunname
			cTit := SE2->E2_NUM
		Else
			Posicione("LHP",1,xFilial("LHQ") + LHQ->LHQ_CODIGO,"LHP_DOCUME") 
			cTit := LHP->LHP_DOCUME
		EndIf

		If !Empty(cTit)

			If IsInCallStack("U_AE_ESTLIB")

				DbSelectArea("SE2")
				DbSetOrder(1)
				If DbSeek(cTit)
					If !Empty(Alltrim(SE2->E2_NUMBOR)) .Or. !Empty(Alltrim(SE2->E2_BAIXA)) .Or. SE2->E2_SALDO == 0
						MsgAlert("Título já se encontra em borderô ou baixado.", "Estorno não permitido!")
						lRet := .F.
					Else
						lRet := .T.
					EndIf
				Else
					MsgAlert("Título não encontrado!")
					lRet := .F.
				EndIf

			Else

				cQuery := "SELECT SE2.E2_NUM TIT, SE2.E2_SALDO SLD, SE2.E2_VALOR VALOR, SE2.E2_BAIXA DTBX, SE2.E2_NUMBOR NUMB, SE2.R_E_C_N_O_ Rec, SE5.R_E_C_N_O_ RECSE5 "
				cQuery += " FROM " + RetSqlName("SE2") + " SE2 "
				cQuery += " INNER JOIN " + RetSqlName("SE5") + " SE5 "
				cQuery += 		" ON E5_FILIAL = E2_FILIAL "
				cQuery += 		" AND E5_PREFIXO = E2_PREFIXO "
				cQuery += 		" AND E5_NUMERO = E2_NUM "
				cQuery += 		" AND E5_PARCELA = E2_PARCELA "
				cQuery += 		" AND E5_TIPO = E2_TIPO "
				cQuery += 		" AND E5_CLIFOR = E2_FORNECE "
				cQuery += 		" AND E5_LOJA = E2_LOJA "
				cQuery += " WHERE"
				cQuery += " SE2.E2_FILIAL || SE2.E2_PREFIXO || SE2.E2_NUM || SE2.E2_PARCELA || SE2.E2_TIPO || SE2.E2_FORNECE || SE2.E2_LOJA = '" + cTit + "'"
				cQuery += " AND SE2.D_E_L_E_T_ = ' '"

				cQuery := ChangeQuery(cQuery)
				cTmp   := GetNextAlias() 
				DbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cTmp, .F., .T. )

				If !Empty( (cTmp)->TIT )
					//		If !lFunname  
					If !lFunname .And. IsInCallStack("U_AE_DVEXC")  
						If (cTmp)->( SLD != VALOR .AND. DTBX != '' )
							Alert( STR0018 + chr(10) + chr(13) + If( LHQ->LHQ_FLAG == "K", STR0020, STR0019 ) )
						ElseIf !Empty( (cTmp)->NUMB )
							Alert(STR0022 + (cTmp)->NUMB)
						Else
							SE2->(DbGoTo( (cTmp)->Rec))

							//-- Monta Array para ExecAuto do Titulo Retentor
							aEval( SE2->(DbStruct()), {|x| AAdd( aDados, { x[1], SE2->&(x[1]), NIL } ) } )
							aAreaTMP :=(cTmp)->( GetArea() )	
							MSExecAuto( { |x, y, z| FINA050( x, y, z ) }, aClone( aDados ), 5, 5 )

							If lMsErroAuto
								If (!IsBlind()) // COM INTERFACE GRÁFICA
									MostraErro() // TELA
								Else // EM ESTADO DE JOB
									cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

									ConOut(PadC("Automatic routine ended with error", 80))
									ConOut("Error: "+ cError)
								EndIf

							Else
								DVAVExc()
								lRet := .T.
							EndIf
							RestArea( aAreaTMP )
						EndIf
					EndIf
				Else
					lRet := .T.
				EndIf

				If Select( (cTmp) ) > 0
					(cTmp)->(DbCloseArea())
				EndIf
			EndIf
		Else
			lRet := .T.
		EndIf
	Else // Se não tem baixa faço a exclusão do titulo
		//	If !lFunName
		If !lFunName  .And. IsInCallStack("U_AE_DVEXC")

			SE2->( DbGoTo( nRecSe2 ) )

			If IsInCallStack("U_AE_ESTLIB")
				//Grava historico de titulos excluidos na tabela FJU
				If AliasIndic("FJU") .And. FindFunction("FinGrvEx") 
					FinGrvEx("P")	
				EndIf
				RecLock("SE2",.F.)
				dbDelete()
				MsUnLock()	
			Else	
				//-- Monta Array para ExecAuto do Titulo Retentor
				aEval( SE2->(DbStruct()), {|x| AAdd( aDados, { x[1], SE2->&(x[1]), NIL } ) } )
				MSExecAuto( { |x, y, z| FINA050( x, y, z ) }, aClone( aDados ), 5, 5 )
			EndIf

			If lMsErroAuto
				If (!IsBlind()) // COM INTERFACE GRÁFICA
					MostraErro() // TELA
				Else // EM ESTADO DE JOB
					cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

					ConOut(PadC("Automatic routine ended with error", 80))
					ConOut("Error: "+ cError)
				EndIf

			Else
				DVAVExc()
				lRet := .T.
			EndIf
		Else
			cQuery	:= " SELECT R_E_C_N_O_ RECNO "
			cQuery	+= " FROM " + RetSqlName("LHP")
			cQuery	+= " WHERE LHP_FILIAL = '"+xFilial("LHP")+"' "
			cQuery 	+= " AND LHP_DOCUME = '"+ xFilial("LHP")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)+"' "
			cQuery 	+= " AND D_E_L_E_T_ = ' '"

			cQuery := ChangeQuery(cQuery)
			cTmp   := GetNextAlias() 
			DbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cTmp, .F., .T. )

			If (cTmp)->RECNO > 0 
				lRet	:= .F.
			Else
				lRet	:= .T.
			EndIf

			If Select( (cTmp)  ) > 0
				(cTmp)->(DbCloseArea())
			EndIf

		EndIf	
	EndIf

	RestArea(aArea)

Return lRet
