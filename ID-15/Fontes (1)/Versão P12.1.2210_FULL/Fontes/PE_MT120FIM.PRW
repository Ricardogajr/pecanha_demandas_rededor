#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "TOTVS.CH"
#Include 'TopConn.Ch'

/*/{Protheus.doc} MT120FIM

 	Ponto de entrada no final do processamento do Pedido de Compra.

	@Author  Paulo Krüger
	@Since   26/10/2016
	@Version P12.1.27
	@type  Function Static
	@Obs MAN00000463801_EF_001
		 MAN00000463801_EF_022 
/*/ 
user function mt120fim()
	local aArea    := getarea()
	local nOper    := paramixb[1]
	local cPedComp := paramixb[2]
	local nOpca    := paramixb[3]
	local cFil     := SC7->C7_FILIAL
	Local nRecno   := SC7->(RECNO())
	local cTipo    := "PC"
	local cNum     := cPedComp
	Local cRecnSC7 := SC7->(Recno())
	Local cUser    := RetCodUsr()
	Local nRecCND := 0

	//PROJETO CAPTURA DE NOTAS - STATUS INTEGRAÇÃO ONERGY
	If nOpca == 1 // Alteração Lucas Miranda de Aguiar 26/11/2024 - Só muda os campos se a operação for 1 (confirmação)
		If nOper == 03 .OR. nOper == 04 .OR. nOper == 09
			SC7->(DbSetOrder(1))
			SC7->(MsSeek(cFilant + AllTrim(cPedComp)))
			While SC7->(!Eof() .AND. C7_FILIAL + C7_NUM == cFil + AllTrim(cPedComp))
				If SC7->C7_XSOLPAG <> '1'
					RecLock("SC7",.F.)
					SC7->C7_ZONERGY := .T.
					SC7->C7_ZINTOGY := "1"
					SC7->C7_ZIDONGY := ""
					SC7->(MsUnlock())
				Endif
				SC7->(DbSkip())
			EndDo
		Endif
	EndIf

	//Alteração Lucas Miranda de Aguiar 26/11/2024 Correção do campo C7_USER que não grava certo no GCT serviços.
	If (isincallstack("MATA094") .Or. IsInCallStack("U_XMATA094"))
		If SCR->CR_TIPO == "MD"
			SC7->(DbSetOrder(1))
			SC7->(MsSeek(cFil + AllTrim(cPedComp)))

			If !Empty(SC7->C7_MEDICAO)
				cUser := Posicione("CND",4,SCR->CR_FILIAL+AllTrim(SCR->CR_NUM),"CND_XUSER")
				If !Empty(cUser)
					While SC7->(!Eof() .and. C7_FILIAL + C7_NUM == cFil + AllTrim(cPedComp))
						RecLock("SC7",.F.)
						SC7->C7_USER := cUser
						SC7->(MsUnlock())
						SC7->(DbSkip())
					EnddO
				EndIf
			EndIF
			SC7->(DbGoto(cRecnSC7))
		EndIf
	EndIf
	//Fim

//Leva anexo da medição para o pedido  - Lucas Miranda de Aguiar 20/08/2024
		fAnexGCT(cFil,cPedComp)

		SC7->(DbSetOrder(1))
		SC7->(MsSeek(cFil + AllTrim(cPedComp)))
		While SC7->(!Eof() .and. C7_FILIAL + C7_NUM== cFil + AllTrim(cPedComp))
			RecLock("SC7",.F.)
			SC7->C7_XNOMECO := UsrFullName(SC7->C7_USER)
			SC7->(MsUnlock())
			SC7->(DbSkip())
		EnddO

//Tratativa temporária para alterar o CONAPRO (devido ao erro na rotina padrão.)
		DbSelectArea("SCR")
		SCR->(DbSetOrder(1))
		If SCR->(DbSeek(cFil + cTipo + cNum))
			While SCR->(!(EoF())) .And. SCR->CR_FILIAL == cFil .And. SCR->CR_TIPO == cTipo .And. AllTrim(SCR->CR_NUM) == cNum
				If SCR->CR_STATUS $ "01|02"
					SC7->(DbSetOrder(1))
					SC7->(MsSeek(cFil + AllTrim(cPedComp)))
					While SC7->(!Eof() .and. C7_FILIAL + C7_NUM== cFil + AllTrim(cPedComp))
						If SC7->C7_CONAPRO <> 'B'
							RecLock("SC7",.F.)
							SC7->C7_CONAPRO := "B"
							SC7->(MsUnlock())
						Endif
						SC7->(DbSkip())
					End
					Exit
				EndIf
				SCR->(DbSkip())
			End
		EndIf

		SC7->(DbGoto(nRecno))

//--[ Só processa a integração SE não for proveniente do schedule - F1200601/F1200600 ]
		if !isincallstack( 'u_f1200601' ) .AND. ;
				!isincallstack( 'U_F1200600' )

			if nOper == 4 .AND. nOpca == 1
				u_f0702207( cPedComp )
			endif

			if nOper == 3 .AND. nOpca == 1
				u_f07022cz( xfilial( 'SC7' ) , cPedComp , nOper ) // Alimenta campo C7_DATPRF (Previsão de entrega)
			endif

// ------------------------------------------------------------------
//      [ Exclui documentos anexos quando excluido o Pedido de Compra. ]
// ------------------------------------------------------------------
			if nOper == 5 .AND. nOpca == 1
				u_f0400105( 'MATA121' , xfilial( 'SC7' ) , cPedComp )
			endif

			if isincallstack( 'A120Copia' )  .AND. nOpca == 1
				u_f07022cy( cPedComp ) // limpa os campos de integração
			endif

// ------------------------------------------------------------------
//      if ( isincallstack( 'MATA131'    ) .OR. !isblind() ) .AND. ;
//          !isincallstack( 'U_F1303701' )
// ------------------------------------------------------------------

			if ( isincallstack( 'MATA131'    ) .OR. ;
					isincallstack( 'U_F1200600' )      )
// ------------------------------------------------------------------
//          .AND. !isincallstack( 'U_W1303701' ) .AND. !isincallstack( 'U_W0702601' )
// ------------------------------------------------------------------
				//u_f1600702( xfilial( 'CNE' ) , cPedComp )
				u_f1600701( xfilial( 'CNE' ) , cPedComp )
			endif

			//-----[ integração com fronts ws client para inclusão e para alteração ]
			If fVldPedC(cPedComp)
				u_f0702203( cPedComp , nOper , nOpca )
			EndIf
// ------------------------------------------------------------------
//      if nOper == 3 .AND. nOpca == 1
// ------------------------------------------------------------------
			if ( nOper == 3 .OR. nOper == 4 ) .AND. nOpca == 1
				u_f1201002( xfilial( 'SC7' ) , cPedComp )
			endif

			if nOper == 3 .AND. SC7->C7_XSOLPAG == '1'
				u_EnvMailPC( xfilial( 'SC7' ) , cPedComp )
			endif

			restarea( aArea )

		endif

		//------[Projeto data programada ]---------------------------------
		if nOpca == 1
			u_DTPrograma( xfilial( 'SC7' ) , cPedComp ) // Alimenta campo C7_DATPRF com a data digitada na SC
		endif

		If IsInCallStack('MATA094') .OR. IsIncallStack("U_XMATA094")
			U_F1200501(cRecnSC7)
		EndIf
		return

// ------------------------------------------------------------------
// {Protheus.doc} GCTINTEGR()
// Executado quando vier do GCT.
// @Author  Thiago Oliveira
// @Since   03/05/2019 
// @Version P12.7
// @Return  lógico
// ------------------------------------------------------------------    
user function GCTIntegr( nOper , cPedComp , nOpca , nRecSC7 )

// ------------------------------------------------------------------
	local   aArea    := SC7->( getarea( 'SC7' ))
	local   lOk      := .F.
// ------------------------------------------------------------------
	default nOper    := 3 // Inclui
	default cPedComp := ''
	default nOpca    := 1
	default nRecSC7  := 0
// ------------------------------------------------------------------

	if !empty( cPedComp ) .AND. nRecSC7 > 0

//------[ Alimenta campo C7_DATPRF (Previsão de entrega) ]-----------
		u_f07022cz( xfilial( 'SC7' ) , cPedComp , nOper )

//------[ Calcula o Desconto Por item e o valor total do pedido ]----
		//u_f1600702( xfilial( 'CNE' ) , cPedComp )
		u_f1600701( xfilial( 'CNE' ) , cPedComp )

//------[ Integração com fronts WS client para inclusão e para alteração ]
		If fVldPedC(cPedComp)
			u_f0702203( cPedComp , nOper , nOpca , nRecSC7 )
		EndIf

//------[Altera nome do fornecedor ]---------------------------------
		u_f1201002( xfilial( 'SC7' ) , cPedComp )

//------[Projeto data programada ]---------------------------------
		u_DTPrograma( xfilial( 'SC7' ) , cPedComp ) // Alimenta campo C7_DATPRF com a data digitada na SC

		lOk := .T.

	endif

	restarea( aArea )

return



Static Function fVldPedC(cPedComp)

	Local aArea := GetArea()
	Local lRet := .F.
	Local cQuery := ""
	Local cAliasSc7 := GetNextAlias()

	Default cPedComp := ""


	If !Empty(cPedComp)

		cQuery := " SELECT C7_NUM FROM "+RETSQLNAME("SC7")+" WHERE D_E_L_E_T_ = ' ' "
		cQuery += " AND C7_FILIAL = '"+xFilial("SC7")+"' "
		cQuery += " AND C7_NUM = '"+cPedComp+"' "

		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSc7,.F.,.T.)

		If !((cAliasSc7)->(Eof()))
			lRet := .T.
		EndIf
	EndIf

	RestArea(aArea)
Return lRet

// ------------------------------------------------------------------
// [ fim de pe_mt120fim.prw ]
// ------------------------------------------------------------------


Static Function fAnexGCT(cFil,cPed)

	Default cFil := ""
	Default cPed := ""

	Local aArea := ""
	Local nRecCND := ""
	Local cChaveCND := ""
	Local cFilCND := ""
	Local cQuery := ""
	Local cAliasP09 := ""
	local cArqRed   := ""
	local cArqLoc   := ""

	If (!isincallstack("MATA094") .And. !IsInCallStack("U_XMATA094"))
		Return
	EndIf

	aArea := GetArea()
	nRecCND := CND->(RECNO())
	cChaveCND := ""
	cFilCND := ""
	cQuery := ""
	cAliasP09 := GetNextAlias()
	cArqRed   := '\RDANEXOS\'
	cArqLoc   := GetTempPath()

	SC7->(DbSetOrder(1))
	SC7->(MsSeek(cFil + AllTrim(cPed)))

	If !Empty(SC7->C7_MEDICAO)

		DbSelectArea("CND")
		CND->(DbGoto(nRecCND))
		cChaveCND := CND->(CND_FILIAL+CND_NUMMED+CND_CONTRA+CND_REVISA)
		cFilCND := CND->CND_FILIAL

		If Alltrim(CND->CND_NUMMED) <> Alltrim(SC7->C7_MEDICAO)
			Return
		EndIf

		cQuery := " SELECT * FROM " + retsqlname("P09")
		cQuery += " WHERE D_E_L_E_T_ = ' ' AND P09_FILIAL = '"+cFilCND+"' "
		cQuery += " AND P09_CODORI = '"+cChaveCND+"'"

		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasP09,.F.,.T.)

		While !((cAliasP09)->(Eof()))
			Reclock("P09",.T.)
			P09->P09_FILIAL := (cAliasP09)->P09_FILIAL
			P09->P09_CODDOC := getsxenum( 'P09' , 'P09_CODDOC' )
			P09->P09_NOMDOC := (cAliasP09)->P09_NOMDOC
			P09->P09_DTHORA := dtos( date() ) + strtran( time() , ':' , '' )
			P09->P09_NIVEL  := "02"
			P09->P09_CODORI := AllTrim(cPed)
			P09->P09_ROTINA := "MATA121"
			P09->( msunlock() )

			if ( file( cArqRed + (cAliasP09)->P09_FILIAL + (cAliasP09)->P09_CODDOC + '.MZP' ) )
				cpys2t( cArqRed + (cAliasP09)->P09_FILIAL + (cAliasP09)->P09_CODDOC + '.MZP' , cArqLoc , , )
				frename(cArqLoc + (cAliasP09)->P09_FILIAL + (cAliasP09)->P09_CODDOC + '.MZP', cArqLoc + (cAliasP09)->P09_FILIAL + P09->P09_CODDOC + '.MZP' )
				__CopyFile(cArqLoc + (cAliasP09)->P09_FILIAL + P09->P09_CODDOC + '.MZP',cArqRed + (cAliasP09)->P09_FILIAL + P09->P09_CODDOC + '.MZP')
			endif
			(cAliasP09)->(DbSkip())
		EndDo

	EndIf

	RestArea(aArea)
Return
