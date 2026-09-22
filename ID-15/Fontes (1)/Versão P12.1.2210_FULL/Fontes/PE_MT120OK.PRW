#INCLUDE 'TOTVS.ch'
/*/{Protheus.doc} MT120OK

    Pto.Entrada existente na Funçao A120TudOk() MATA121.PRX,
    responsável pela validação de todos os itens da GetDados do Pedido de Compras / Autorização de Entrega.

    @type Function User
    @author	Ademar Fernandes
    @since	17/08/2017
    @project	MAN0000007423046_EF_009
/*/
User Function MT120OK()
	Local aArea := GetArea() as array
	Local lRet  := .T.       as logical

	If FindFunction("U_F0702206")
		U_F0702206()
	EndIf

	If FindFunction("U_F1200902")
		lRet := U_F1200902()
	EndIf

	//Não executa caso a rotina de Exclusão de Nota Fiscal de Entrada esteja na pilha de chamada
	If lRet .And. !(FwIsInCallStack("U_F1303701")) .And. !(FwIsInCallStack("U_F1303702"))
		//Se vier de integração
		If FwIsInCallStack("U_F0703501")
			If !(U_F1303806())
				lRet := .F.
				Help("", 1, "HELP", "Semaforo", "Arquivo de semaforo em utilização. Não é possível prosseguir com a rotina.", 1, 0,,,,,,;
					{""})
			EndIf
		ElseIf FindFunction("U_F1303804")
			lRet := U_F1303804()
		EndIf
	EndIf

	If FwIsInCallStack('MATA121') .And. FindFunction("U_V01MT120OK") // Valida a gravação do campo BZ_XGRPCOM
		lRet := U_V01MT120OK()
	EndIf

	RestArea(aArea)

Return lRet
/*/{Protheus.doc} V01MT120OK

	Ponto de entrada no TudoOk de pedido de compra MATA121.PRX

    Irá preencher o grupo de compras caso esteja vaziu na SBZ - BZ_XGRPCOM

	@type  Function Static
	@version 12.1.2210
	@author  Cleiton Genuino da Silva
	@since   18/05/2023 at 16:45
	@return character, Retorna verdadeiro em caso de sucesso e caso contrário falso

/*/
User Function V01MT120OK()
	Local aArea      := GetArea()                                           as array
	Local lBlind     := IsBlind()                                           as logical
	Local lValido    := .T.                                                 as logical
	Local lSbz		 := .T.                                                 as logical
	Local nPosDelete := Len(aHeader)+1                                      as numeric
	Local nPosGpC    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_GRUPCOM' }) as numeric // Gr. Compras
	Local nPosNsC    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_NUMSC' })   as numeric // Numero da solicita.compra
	Local nPosPrd    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_PRODUTO' }) as numeric // Codigo do produto
	Local nX         := 0                                                   as numeric

	If !lBlind

		IF select('SBZ') <= 0
			DBSELECTAREA('SBZ')
		EndIf
		SBZ->(DbSetOrder(1)) // BZ_FILIAL + BZ_COD

		For nX := 1 To Len( aCols )

			If !aCols[nX,nPosDelete] // Não deletados

				If !Empty(aCols[nX][nPosNsC]) .And. Empty(aCols[nX][nPosGpC]) // Tem SC e vaziu o C7_GRUPCOM
					lValido  := .F.
					Help("", 1, "MT120OK", , "Grupo de compras não pode ser salvo com conteúdo vazio pois possui número da solicitação de compra está preenchido", 1, 0, , , , , , {""})
					Exit
				EndIf

			EndIf

		Next nX

		If lValido
			For nX := 1 To Len( aCols )

				If !aCols[nX,nPosDelete] // Não deletados
					If !Empty(aCols[nX][nPosNsC]) .And. !Empty(aCols[nX][nPosGpC])

						lSbz := SBZ->(DbSeek(xFilial("SBZ") + Padr(aCols[nX][nPosPrd],TamSx3("BZ_COD")[1]) ))
						
						If ! lSbz
							Help("", 1, "V01MT120OK", , "Na Filial "+ cFilAnt + " o produto " + aCols[nX][nPosPrd] + " informado não foi encontrado na tabela SBZ, mas não impeditivo para prosseguir !! ", 1, 0, , , , , , {""})
						EndIf

						If lSbz .And. Empty(SBZ->BZ_XGRPCOM)
							If reclock('SBZ',.F.)
								SBZ->BZ_XGRPCOM := aCols[nX][nPosGpC]
								SBZ->(MSUNLOCK())
							EndIf
						EndIf

					EndIf
				EndIf

			Next nX
		EndIf

	EndIf

	restarea(aArea)

Return(lValido)
/*/{Protheus.doc} VISC7

	Altera do mode de visualização/alteração o campo C7_GRUPCOM na geração do pedido de compra manual

	@type  Function Static
	@version 12.1.2210
	@author  Cleiton Genuino da Silva
	@since   18/05/2023 at 16:45

	@param cProduto,	character	, Código do produto da SB1 - B1_COD

	@return logical, Retorna verdadeiro em caso de sucesso e caso contrário falso

/*/
User Function VISC7()
	Local aArea    := GetArea()                as array
	Local cNumSc   := GDFieldGet("C7_NUMSC")   as character
	Local cProduto := GDFieldGet("C7_PRODUTO") as character
	Local lEdita   := .T.                      as logical

	IF select('SBZ') <= 0
		DBSELECTAREA('SBZ')
	EndIf
	SBZ->(DbSetOrder(1)) // BZ_FILIAL + BZ_COD

	If Empty(cProduto) .And. Empty(cNumSc)
		lEdita := .T.
	EndIf


	If !Empty(cProduto)

		If  SBZ->(DbSeek(xFilial("SBZ") + cProduto))
			If Empty(SBZ->BZ_XGRPCOM) .And. !Empty(cNumSc) // Só edita se estiver em branco na SBZ e Numero de SC preenchido
				lEdita := .T.
			Else
				lEdita := .F.
			EndIf
		EndIf

	EndIf

	restarea(aArea)

Return(lEdita)
/*/{Protheus.doc} VldGrComp

	Verifica se o usuario pertence a um grupo de compras.
	Valid solicitado no campo com alerta ao usuário.

	@type  Function Static
	@version 12.1.2210
	@author  Cleiton Genuino da Silva
	@since   09/06/2023 at 19:17

	@param cUser,	character	, Codigo do usuario a ser verificado.
	@param cUser,	character	,  Codigo do grupo a ser verificado.

	@return logical, Retorna verdadeiro em caso de sucesso e caso contrário falso

/*/
User Function VldGrComp( cUser, cGrupo )
	Local cSaveArea := Alias()                           as array
	Local cSavOrdem := IndexOrd()                        as numeric
	Local lAjMsblq  := SAJ->(FIELDPOS("AJ_MSBLQL ")) > 0 as logical //Valida se o campo reservado foi habilitado
	Local lRet      := .F.                               as logical
	Default cGrupo  := ''
	Default cUser   := RetCodUsr()

	If !Empty(cUser)
		If select('SAJ') <= 0
			dbSelectArea("SAJ")
		Endif
		SAJ->(dbSetOrder(2))
		If SAJ->(dbSeek(xFilial("SAJ")+cUser))
			While SAJ->(!Eof()) .And. SAJ->AJ_USER == cUser
				If AllTrim(SAJ->AJ_GRCOM) == "*" .Or. cGrupo == SAJ->AJ_GRCOM
					If lAjMsblq
						//Caso o registro esteja bloqueado, sai do while e apresenta help na função MaCanAltCot ou MaCanDelCot (COMXFUN).
						If !RegistroOk("SAJ",.F.)
							Exit
						EndIf
					EndIf
					lRet := .T.
					Exit
				EndIf
				SAJ->(dbSkip())
			End
		EndIf
	Endif

	If Empty(cGrupo)
		lRet := .T.
	EndIf

	If ! lRet
		Help("", 1, "VLDGRCOMP", , "O grupo de compras " + cGrupo + " informado não pertence ao grupo do usuário " + cUser + ' - ' + USRRETNAME(cUser), 1, 0, , , , , , {""})
	EndIf

	dbSelectArea(cSaveArea)
	dbSetOrder(cSavOrdem)

Return lRet
/*/{Protheus.doc} XTRIGGER

	Macro execução de RUNTRIGGER na linha da C7

	@type  Function Static
	@version 12.1.2210
	@author  Cleiton Genuino da Silva
	@since   09/06/2023 at 19:17
	@return logical, Retorna verdadeiro em caso de sucesso e caso contrário falso

/*/
User Function XTRIGGER()
	Local aArea := GetArea() as array
	Local lRet  := .T.       as logical
	
	If ExistTrigger( 'C7_PRODUTO' ) // verifica se existe trigger para este campo
		RunTrigger(2,N,nil,, 'C7_PRODUTO' )
	EndIf

	restarea(aArea)

Return lRet
