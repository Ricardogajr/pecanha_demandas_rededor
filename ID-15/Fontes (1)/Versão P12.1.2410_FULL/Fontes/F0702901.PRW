#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} F0702901
Bloqueio de Nota Fiscal de Entrada
@type User function
@author Paulo Krüger
@since 16/03/2017
@version 12.7
@param cID    - ID do Título a Pagar
@project MAN0000007423041_EF_029
@return NIL
/*/
User Function F0702901(cId)

	Local lRet := .T.

	DEFAULT cId := ''

	If !Empty(cId)
		Processa({|| lRet := Prc0702901(cID) }, "Bloqeuio de NF integrada", "Enviando bloqueio de NF integrada ao Front.")
	EndIf
	

Return lRet

Static Function Prc0702901(cID)
	Local aArea      := GetArea()
	Local aAreaSF1   := SF1->(GetArea())
	Local dDataRef   := CTOD('  /  /  ')
	Local cAlias01   := ''
	Local lBloq      := .F.
	Local cStatus    := ''
	Local nRecNota   := 0
	Local cSF1Filter := ""
	Local aDadosTit  := {}
	
	dDataRef := SuperGetMv('MV_ULMES')
	cAlias01 := GetNextAlias()

	BeginSql Alias cAlias01
	SELECT	DISTINCT
			SE2.E2_FILIAL	FILITITULO	,
			SE2.E2_NUM		NUMETITULO	,		
			SE2.E2_PARCELA	PARCTITULO	,
			SE2.E2_PREFIXO	PREFTITULO	,
			SE2.E2_TIPO		TIPOTITULO	,
			SE2.E2_VALOR	VALOTITULO	,
			CASE WHEN SF1.F1_DOC	 IS NOT NULL   THEN SF1.R_E_C_N_O_  ELSE 0  END RECNONOTA  ,
			CASE WHEN SF1.F1_DOC	 IS NOT NULL   THEN SF1.F1_DOC		ELSE '' END NOTAENTRAD ,	
			CASE WHEN SF1.F1_SERIE	 IS NOT NULL   THEN SF1.F1_SERIE	ELSE '' END SERIENTRAD ,
			CASE WHEN SF1.F1_FORNECE IS NOT NULL   THEN SF1.F1_FORNECE	ELSE '' END FORNECEDOR ,
			CASE WHEN SF1.F1_LOJA	 IS NOT NULL   THEN SF1.F1_LOJA		ELSE '' END	LOJAFORNEC ,
			CASE WHEN SF1.F1_XTITFRO IS NOT NULL   THEN SF1.F1_XTITFRO  ELSE '' END XTITFRO    ,
			CASE WHEN SF1.F1_DTDIGIT IS NOT NULL   THEN CASE WHEN SF1.F1_DTDIGIT > %Exp:dDataRef% THEN 'SIM' ELSE 'NAO' END ELSE 'NAO' END BLOQUEAVEL	,
			CASE WHEN SEA.EA_NUMBOR  IS NOT NULL   THEN 'SIM' ELSE 'NAO'                                                               END NUMBORDERO	,
			CASE WHEN SE2.E2_SALDO <> SE2.E2_VALOR THEN 'SIM' ELSE 'NAO'                                                               END TITMOVIMEN
	FROM 	%Table:SE2% SE2 LEFT JOIN %Table:SEA% SEA ON		SEA.%notDel%	
															AND	SEA.EA_FILIAL	=	SE2.E2_FILIAL 
															AND SEA.EA_PREFIXO	=	SE2.E2_PREFIXO
															AND SEA.EA_NUM		=	SE2.E2_NUM
															AND SEA.EA_PARCELA	=	SE2.E2_PARCELA
															AND SEA.EA_TIPO		=   SE2.E2_TIPO   
															AND SEA.EA_FORNECE	=	SE2.E2_FORNECE
															AND SEA.EA_LOJA		=	SE2.E2_LOJA   
							LEFT JOIN %Table:SF1% SF1 ON		SF1.%notDel%
															AND SF1.F1_XID		=	SE2.E2_XID
	WHERE 			SE2.%notDel%
				AND SE2.E2_XID = %Exp:cId%
	EndSql
	(cAlias01)->(DbGoTop())
	
	If (cAlias01)->(!Eof())
		
		ProcRegua(0)

		nRecNota := (cAlias01)->RECNONOTA
		(cAlias01)->( aDadosTit := { FILITITULO, ;
		                             FORNECEDOR, ;
		                             LOJAFORNEC, ;
		                             NUMETITULO, ;
		                             PARCTITULO, ;
		                             PREFTITULO, ;
		                             TIPOTITULO, ;
		                             VALOTITULO, ;
		                             XTITFRO }  )
	
		Do While (cAlias01)->(!Eof()) .And. !lBloq .And. Empty(cStatus)
			IncProc()
			If (cAlias01)->BLOQUEAVEL == 'NAO'
				cStatus := 'WARNING|NFE: ' + (cAlias01)->NOTAENTRAD + '/' + ;
											 (cAlias01)->SERIENTRAD + '-' + ;
								'FORNEC: ' + (cAlias01)->FORNECEDOR + '/' + ;
								             (cAlias01)->LOJAFORNEC + 'NAO BLOQUEAVEL.' 
			
			Else
				If (cAlias01)->NUMBORDERO == 'SIM' .and. !lBloq
					lBloq := .T.
				EndIf
				If (cAlias01)->TITMOVIMEN == 'SIM' .and. !lBloq
					lBloq := .T.
				EndIf
			EndIf
			(cAlias01)->(DbSkip())
		EndDo
				
		If !Empty(cStatus)
			ConOut(cStatus)
		Else
			
			IncProc()
			
			cSF1Filter := SF1->(DbFilter())
			If !Empty(cSF1Filter)
				SF1->(DbClearFilter())
			EndIf
			SF1->(DbGoTo(nRecNota))

			If lBloq
				If SF1->F1_XBLOQ <> '1'
					Reclock('SF1',.F.)
					SF1->F1_XBLOQ := '1'
					SF1->(MsUnlock())
					U_F0702902(	aDadosTit[01], ;
								aDadosTit[02], ;
								aDadosTit[03], ;
								aDadosTit[04], ;
								aDadosTit[05], ;
								aDadosTit[06], ;
								aDadosTit[07], ;
								'1'			 , ;	
								aDadosTit[08], ;
								,              ;
								aDadosTit[09]  )
				EndIf
			Else
				If SF1->F1_XBLOQ == '1'
					Reclock('SF1',.F.)
					SF1->F1_XBLOQ := '2'
					SF1->(MsUnlock())
					U_F0702902(	aDadosTit[01], ;
								aDadosTit[02], ;
								aDadosTit[03], ;
								aDadosTit[04], ;
								aDadosTit[05], ;
								aDadosTit[06], ;
								aDadosTit[07], ;
								'2'          , ;	
								aDadosTit[08], ;
								,              ;
								aDadosTit[09]  )
				EndIf
			EndIf

			If !Empty(cSF1Filter)
				DbSelectArea("SF1")
				SET FILTER TO &cSF1Filter			
			EndIf
		
		EndIf

	EndIf	

	If Select(cAlias01) > 0
		(cAlias01)->(dbCloseArea()) 
	EndIf
		
	RestArea(aAreaSF1)
	RestArea(aArea)

Return .T.
