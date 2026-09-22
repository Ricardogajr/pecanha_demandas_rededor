#INCLUDE 'TOTVS.CH'
/*/{Protheus.doc} FSPE0023

    MT120BRW - Adicona o botão de Transferir Saldo PC - Pedido de Compra MATA121.PRX

	@type Function - User function
	@author Cleiton Genuino
	@since 19/06/2023
	@version 1.0
/*/
User Function FSPE0023()

	aadd(aRotina, {'Trans. Saldo Fornecedor PC', 'U_REDA4SEL', 0, 4, 0, NIL})

Return aRotina
/*/{Protheus.doc} FSPE0023

    MT120BRW - Adicona o botão de Transferir Saldo PC - Pedido de Compra MATA121.PRX

	@type Function - User function
	@author Cleiton Genuino
	@since 19/06/2023
	@version 1.0
/*/
User Function REDA4SEL()
	Local cBkpUsr   := __CUSERID as character
	Local cMensagem := ''        as character
	Local lOk       := .T.       as logical
	Local lParcial  := .F.       as logical
	Local lParcResi := .F.       as logical
	Local nRecnoSC7 := 0         as numeric

	If SC7->(!Eof())
		nRecnoSC7 := SC7->(Recno())

		If Parcial( SC7->C7_FILIAL, SC7->C7_NUM ) // Por item atendido
			lParcial := .T.
		EndIf
 		
		If ParResi( SC7->C7_FILIAL, SC7->C7_NUM )
			lParcResi := .T.
		EndIf

		If lOk .And. Empty(SC7->C7_MEDICAO)
			If Aviso("Atenção", "Este pedido de compras não possui uma medição de contrato e não será possível realizar esta rotina. Utilizar a rotina de eliminação de resíduo", {"Ok"})
				lOk := .F.
			EndIf
		EndIf

		If lOk .And. Empty(SC7->C7_CONTRA)
			If Aviso("Atenção", "Este pedido de compras não possui o número de contrato e não será possível realizar esta rotina. Utilizar a rotina de eliminação de resíduo", {"Ok"})
				lOk := .F.
			EndIf
		EndIf

		If lOk .And. !Empty(SC7->C7_ENCER) .And. !Empty(SC7->C7_RESIDUO)
			MsgAlert("Este pedido já foi eliminado por residuo e não poderá executar novamente esta rotina.")
			lOk := .F.
		EndIf

		If lOk .And. SC7->C7_QUJE == SC7->C7_QUANT
			MsgAlert("Este pedido foi atendido e não poderá executar esta rotina.")
			lOk := .F.
		EndIf

		If lOk .And. ! lParcial

			If lParcResi
				lOk := .T.
			Else
				MsgAlert("Este pedido está totalmente pendente e não será possível realizar esta rotina. Utilizar a rotina de estorno e exclusão de medição.")
				lOk := .F.
			EndIf

		EndIf

		If lOk .And. ! ValGrupo( SC7->C7_FILIAL, SC7->C7_NUM , SC7->C7_GRUPCOM )
			MsgAlert("Usuário não pertence ao grupo de compras desse pedido e não foi o criador desse pedido !", "Atenção!")
			lOk := .F.
		EndIf
		
		If lOk .And. ! Empty(SC7->C7_MEDICAO) .And. VazioSC( SC7->C7_FILIAL, SC7->C7_NUM )
			MsgAlert("Pedido de compra não possui número de Solicitação de Compra de origem !", "Atenção!")
			lOk := .F.
		EndIf
		
		If lOk .And. Aviso("Atenção", "Deseja eliminar residuo deste pedido de compras e gerar um novo pedido de compras?", {"Sim", "Não"}) == 2
			lOk := .F.
		EndIf

		If lOk
			AltrFornec(nRecnoSC7)
		EndIf

	Else
		cMensagem   := "Pedido de compra não é está pocionado na tabela SC7 corretamente não sendo possivel prosseguir"
		Help("", 1, "HELP", "Alt. Fornecedor", cMensagem, 1, 0,,,,,,{""})
	EndIf

	__cUserId := cBkpUsr

Return
/*/{Protheus.doc} AltrFornec

    Tela para alteração do fornecedor do Pedido de Compra

	@type Function - User function
	@author Cleiton Genuino
	@since 19/06/2023
	@version 1.0
	@param nRecnoSC7, numeric, Recno da SC7 para posicionmento.
/*/
Static Function AltrFornec(nRecnoSC7)
	Local aArea       := {}  as array
	Local aAreaSC7    := {}  as array
	Local aButtons    := {}  as array
	Local cCodFornec  := ""  as character
	Local cLojFornec  := ""  as character
	Local cNomFornec  := ""  as character
	Local cNvCodForn  := ""  as character
	Local cNvLojForn  := ""  as character
	Local cNvNomForn  := ""  as character
	Local oDlg        := Nil as object
	Default nRecnoSC7 := 0

	aArea    := fwGetArea()
	aAreaSC7 := SC7->(fwGetArea())

	If nRecnoSC7 > 0
		SC7->(DbGoTo(nRecnoSC7))
	EndIf

	IF SC7->(!Eof()) .And. nRecnoSC7 == SC7->(Recno())

		cCodFornec  := SC7->C7_FORNECE
		cLojFornec  := SC7->C7_LOJA
		cNomFornec  := GetAdvFVal("SA2", "A2_NOME", FwXFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA, 1, SC7->C7_XNOMFOR, .T.)
		cNvCodForn  := Space(TamSX3("C7_FORNECE")[1])
		cNvLojForn  := Space(TamSX3("C7_LOJA")[1])
		cNvNomForn  := Space(TamSX3("C7_XNOMFOR")[1])

		DEFINE MSDIALOG oDlg TITLE "Pedido de Compra - Alteração do Fornecedor" STYLE DS_MODALFRAME FROM 0, 0 TO 180, 700 PIXEL

		//ROW, COL

		//1a Coluna
		@ 040, 005  SAY "Cód. Fornecedor (Atual):"  SIZE 200, 008   PIXEL OF oDlg
		@ 040, 070  MSGET   cCodFornec  PICTURE "@!"    SIZE 020, 010   READONLY    PIXEL OF oDlg

		//2a Coluna
		@ 040, 105  SAY "Loja (Atual):"  SIZE 200, 008   PIXEL OF oDlg
		@ 040, 140  MSGET   cLojFornec  PICTURE "@!"    SIZE 010, 010   READONLY    PIXEL OF oDlg

		//3a Coluna
		@ 040, 160  SAY "Fornecedor (Atual):"  SIZE 200, 008   PIXEL OF oDlg
		@ 040, 210  MSGET   cNomFornec  PICTURE "@!"    SIZE 120, 010   READONLY    PIXEL OF oDlg

		//1a Coluna
		@ 055, 005  SAY "Cód. Fornecedor (Novo):"   SIZE 200, 008   PIXEL OF oDlg
		@ 055, 070  MSGET cNvCodForn  PICTURE "@!"  VALID VldFornec(cCodFornec, cLojFornec, @cNvCodForn, @cNvLojForn, @cNvNomForn) SIZE 010, 010   F3 "VV6A"   PIXEL OF oDlg

		//2a Coluna
		@ 055, 105  SAY "Loja (Novo):"    SIZE 200, 008 PIXEL OF oDlg
		@ 055, 140  MSGET cNvLojForn  PICTURE "@!"  VALID VldFornec(cCodFornec, cLojFornec, @cNvCodForn, @cNvLojForn, @cNvNomForn) SIZE 010, 010   PIXEL OF oDlg

		//3a Coluna
		@ 055, 160  SAY "Fornecedor (Novo):"   SIZE 200, 008 PIXEL OF oDlg
		@ 055, 210  MSGET cNvNomForn    PICTURE "@!"    SIZE 120, 010   READONLY    PIXEL OF oDlg

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,;
			{|| IIf(ValidGeral(cCodFornec, cLojFornec, cNvCodForn, cNvLojForn),;
			IIf(U_REDA900(cNvCodForn, cNvLojForn), oDlg:End(), Nil), Nil)}, {|| oDlg:End()},, aButtons,,, .F., .F., .F., .T., .F.)

	EndIF

	fwrestarea	(aArea)
	fwrestarea	(aAreaSC7)

Return Nil
/*/{Protheus.doc} ValidGeral
	
	Validação geral do fornecedor.

	@type       function static
	@author     Cleiton Genuino
	@since      28/06/2023
	@version    1.0
	@param      cCodForAtu, character, código do fornecedor atual do pedido de compra
	@param      cCodLojAtu, character, loja do fornecedor atual do pedido de compra
	@param      cCodForNov, character, novo código do fornecedor
	@param      cCodLojNov, character, nova loja do fornecedor
	@return     logical, se as informações foram validadas ou não
/*/
Static Function ValidGeral(cCodForAtu, cCodLojAtu, cCodForNov, cCodLojNov)
	Local lOk          := .T. as logical
	Default cCodForAtu := ""
	Default cCodForNov := ""
	Default cCodLojAtu := ""
	Default cCodLojNov := ""

	lOk := VldFornec(cCodForAtu, cCodLojAtu, cCodForNov, cCodLojNov)

Return lOk
/*/{Protheus.doc} VldFornec
	
	Valida o fornecedor informado

	@type       function static
	@author     Cleiton Genuino
	@since      28/06/2023
	@version    1.0
	@param      cCodForAtu, character, código do fornecedor atual do pedido de compra
	@param      cCodLojAtu, character, loja do fornecedor atual do pedido de compra
	@param      cCodForNov, character, novo código do fornecedor
	@param      cCodLojNov, character, nova loja do fornecedor
	@param      cNvNomForn, character, Nome do Fornecedor
	@return     logical, se as informações foram validadas ou não
/*/
Static Function VldFornec(cCodForAtu, cCodLojAtu, cCodForNov, cCodLojNov, cNvNomForn)
	Local aAreas       := {}  as array
	Local lValido      := .T. as logical
	Default cCodForAtu := ""
	Default cCodForNov := ""
	Default cCodLojAtu := ""
	Default cCodLojNov := ""
	Default cNvNomForn := ""

	aAreas := {fwGetArea(), SA2->(fwGetArea())}

	If !(Empty(cCodForNov)) .And. !(Empty(cCodLojNov))
		SA2->(DbSetOrder(1))
		If SA2->(DbSeek(FwXFilial("SA2") + cCodForNov + cCodLojNov))
			If SA2->A2_MSBLQL == "1"
				Help("", 1, "HELP", "Fornecedor", "Fornecedor bloqueado para uso.", 1, 0,,,,,,{""})
				lValido := .F.
			ElseIf (cCodForAtu + cCodLojAtu) == (cCodForNov + cCodLojNov)
				Help("", 1, "HELP", "Fornecedor", "Novo Fornecedor não pode ser igual ao Fornecedor antigo.", 1, 0,,,,,,{""})
				lValido := .F.
			EndIf
		Else
			Help("", 1, "HELP", "Fornecedor", "Fornecedor não encontrado na base da dados.", 1, 0,,,,,,{""})
			cCodForNov := space(TamSX3("C7_FORNECE")[1])
			cCodLojNov := space(TamSX3("C7_LOJA")[1])
			lValido := .F.
		EndIf
	EndIf

	If lValido .And. !(FwIsInCallStack("ValidGeral"))
		cNvNomForn := SA2->A2_NOME
		cCodLojNov := SA2->A2_LOJA
	EndIF

	AEval(aAreas, {|area| fwrestarea(area)})

Return lValido
/*/{Protheus.doc} ValGrupo

    Função para validar se o usuário está apto a alterar a Data do pedido de compra

	@type Function - Static function
	@author Cleiton Genuino
	@since 16/06/2023
	@version 1.0
	@return logical, Se executado com sucesso retorna verdadiero caso contrario falso

/*/
Static Function ValGrupo(cFilPc,cNumPc,cGrupoPc)
	Local aArea      := fwGetArea()      as array
	Local cAlias     := GetNextAlias() as character
	Local cNameUsr   := RetCodUsr()    as character
	Local lOk        := .F.            as logical
	Default cFilPc   := cFilAnt
	Default cGrupoPc := ''
	Default cNumPc   := ''

	If select('SC7') <= 0
		dbSelectArea("SC7")
	Endif
	SC7->(dbSetOrder(1)) // C7_FILIAL + C7_NUM + C7_ITEM + C7_SEQUEN

	cFilAnt := cFilPc

	BeginSql alias cAlias
		SELECT
			C7_USER
		FROM
			%Table:SC7% SC7
		WHERE
			C7_FILIAL = %exp:cFilPc%
			AND C7_NUM = %exp:cNumPc%
			AND SC7.%NotDel% 
	EndSql

	While (cAlias)->(!EOF())
		If Alltrim(cNameUsr) == Alltrim((cAlias)->C7_USER)
			lOk := .T.
			EXIT
		EndIf
		(cAlias)->(dbskip())
	Enddo

	If ! lOk .And. !Empty(cGrupoPc)
		lOk := VldGrComp(cNameUsr,cGrupoPc)
	Endif

	fwrestarea	(aArea)
	(cAlias)->(DbCloseArea())

Return lOk
/*/{Protheus.doc} Parcial

    Função para validar se o pedido foi parcial em no momento da transferencia

	@type Function - Static function
	@author Cleiton Genuino
	@since 16/06/2023
	@version 1.0
	@param cFilPc  , character, Filial do pedido de venda
	@param cNumPc  , character, Numero do pedido de compra
	@return logical, Se executado com sucesso retorna verdadiero caso contrario falso

/*/
Static Function Parcial(cFilPc,cNumPc)
	Local aArea      := fwGetArea()      as array
	Local cAlias     := GetNextAlias() as character
	Local lParcial   := .T.            as logical
	Default cFilPc   := cFilAnt
	Default cNumPc   := ''

	BeginSql alias cAlias
		SELECT
			C7_USER,
			C7_QUJE,
			C7_QUANT,
			C7_RESIDUO,
			C7_ENCER
		FROM
			%Table:SC7% SC7
		WHERE
			C7_FILIAL = %exp:cFilPc%
			AND C7_NUM = %exp:cNumPc%
			AND SC7.%NotDel% 
	EndSql

	While (cAlias)->(!EOF())
		If ( ((cAlias)->C7_QUANT - (cAlias)->C7_QUJE) == (cAlias)->C7_QUANT )
			lParcial:= .F.
		Else
			lParcial:= .T.
			EXIT
		EndIf
		(cAlias)->(dbskip())
	Enddo

	fwrestarea	(aArea)
	(cAlias)->(DbCloseArea())

Return lParcial
/*/{Protheus.doc} VazioSC

    Função para validar se o número da SC está em branco no pedido.

	@type Function - Static function
	@author Cleiton Genuino
	@since 18/06/2023
	@version 1.0
	@param cFilPc  , character, Filial do pedido de venda
	@param cNumPc  , character, Numero do pedido de compra
	@return logical, Se encontrar vazio retorna TRUE caso contrário retorna FALSE

/*/
Static Function VazioSC(cFilPc,cNumPc)
	Local aArea    := fwGetArea()      as array
	Local aAreaSC1 := {}             as array
	Local cAlias   := GetNextAlias() as character
	Local lVazio   := .F.            as logical
	Default cFilPc := cFilAnt
	Default cNumPc := ''
	
	If select( 'SC1' ) <= 0
		DBSELECTAREA( 'SC1' )
	EndIf
	DbSetOrder(6) // C1_FILIAL + C1_PEDIDO + C1_ITEMPED + C1_PRODUTO	Num. Pedido + Item Pedido + Produto
	aAreaSC1 := SC1->(fwGetArea())

	BeginSql alias cAlias
		SELECT
			C7_FILIAL,
			C7_NUM,
			C7_ITEM,
			C7_NUMSC,
			C7_PRODUTO
		FROM
			%Table:SC7% SC7
		WHERE
			C7_FILIAL = %exp:cFilPc%
			AND C7_NUM = %exp:cNumPc%
			AND SC7.%NotDel% 
	EndSql

	While (cAlias)->(!EOF()) .And. ! lVazio
		If EMPTY((cAlias)->C7_NUMSC)
			If SC1->(DbSeek((cAlias)->C7_FILIAL + (cAlias)->C7_NUM + (cAlias)->C7_ITEM + (cAlias)->C7_PRODUTO  )) 
				If Empty(SC1->C1_NUM)
					lVazio:= .T.
					EXIT
				EndIF
			EndIf
		EndIf
		(cAlias)->(dbskip())
	Enddo

	fwrestarea	(aArea)
	fwrestarea	(aAreaSC1)
	(cAlias)->(DbCloseArea())

Return lVazio
/*/{Protheus.doc} ParResi

    Função para validar se o pedido foi parcial em no momento da transferencia

	@type Function - Static function
	@author Cleiton Genuino
	@since 16/06/2023
	@version 1.0
	@param cFilPc  , character, Filial do pedido de venda
	@param cNumPc  , character, Numero do pedido de compra
	@return logical, Se executado com sucesso retorna verdadiero caso contrario falso

/*/
Static Function ParResi(cFilPc,cNumPc)
	Local aArea     := fwGetArea()      as array
	Local cAlias    := GetNextAlias() as character
	Local lEmlimin  := .F.            as logical
	Local lParcResi := .F.            as logical
	Default cFilPc  := cFilAnt
	Default cNumPc  := ''

	BeginSql alias cAlias
		SELECT
			C7_RESIDUO
		FROM
			%Table:SC7% SC7
		WHERE
			C7_FILIAL = %exp:cFilPc%
			AND C7_NUM = %exp:cNumPc%
			AND SC7.%NotDel%
		GROUP BY C7_RESIDUO
	EndSql

	While (cAlias)->(!EOF())

		If !Empty((cAlias)->C7_RESIDUO)
			lEmlimin := .T.
		Else
			lParcResi:= .T.
		EndIf
		(cAlias)->(dbskip())
		
	Enddo

	If ! lEmlimin .Or. ! lParcResi
		lParcResi := .F.
	EndIF

	fwrestarea	(aArea)
	(cAlias)->(DbCloseArea())

Return lParcResi
