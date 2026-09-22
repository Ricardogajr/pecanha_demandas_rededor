#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} F0703202
JOB: Liberacao de PV, geracao de NF envio ao SEFAZ e notificação de retorno ao Front.
@author Paulo Krüger
@since  13/02/2017
@param aParam
@return Nil
@project MAN0000007423041_EF_032
@cliente Rededor
@version P12.1.7
/*/

User Function F0703202( aParam )

	Local aFiles	:= {"P22", "SC5", "SC6", "SC9", "SF2", "SF3", "SD2"}
	Local aRetChav	:= {}
	Local cAlias01	:= ""
//	Local cEmpIni   := IIF(ValType(aParam) <> "U", aParam[1], cEmpAnt)
//	Local cFilIni   := IIF(ValType(aParam) <> "U", aParam[2], cFilAnt)

	Local cEmpIni   := "" 
	Local cFilIni   := "" 
	Local cRefAmb	:= ""
	Local nX		:= 0

	Static aAmbiente:= {}

	DEFAULT aParam := {"01","01010001"}
 
	cEmpIni := aParam[1]
	cFilIni := aParam[2]
      
	aAmbiente   := {}
	aRetChav    := {}
	 
   /*	cEmpIni := cEmpAnt
	cFilIni := cFilAnt*/

	If IsBlind() .Or. IsInCallStack('U_F0703202')
		cEmpAnt := aParam[1]
		cFilAnt := aParam[2]
	Endif
	
	Conout("F0703202 - Processo será iniciado. Empresa.: " + cEmpIni + " Filial.: " + cFilIni + " !")

	If IsBlind() .Or. IsInCallStack('U_F0703202')
		RpcSetEnv(cEmpAnt,cFilAnt)
	Endif	

// Alterar para tratar por filial na proxima versao
//	If !LockByName("F0703202" + cEmpIni  , .F., .F.)

	If !LockByName("F0703202" + cEmpIni + cFilIni , .T. , .T. )
		Conout("F0703202 - Já existe um Job com mesmo nome em execução!")
		Return
	EndIf

	RpcClearEnv()

	Begin Sequence
		PrintCon("Preparação do Ambiente e Recuperação dos Dados.", cEmpIni + " - " + cFilIni )
	
		If !SetEnv(cEmpIni, cFilIni, aFiles)
			Break
		Endif

		cAlias01 := GetNextAlias()
		BeginSql Alias cAlias01
			%noparser%
			SELECT	P22.P22_EMPPV	AS EMPRESA	,
					P22.P22_FILPV	AS FILIAL	,
					P22.P22_NUMPV	AS PEDVEND	,
					P22.P22_STATRS	AS STATRS	,
					P22.P22_STATFT  AS STATFT   ,
					P22.R_E_C_N_O_	AS REGNUM
			FROM 	%Table:P22% P22
			WHERE 		P22.%notDel%
					AND	P22.P22_STATPV  = '1'    
					AND P22_EMPPV = %exp:cEmpIni% 					
					AND P22_FILPV = %exp:cFilIni%     
					AND (P22_DTRTSF =  ' ' OR P22_NOTA = ' ')
			ORDER BY 	P22.P22_EMPPV,
						P22.P22_FILPV,
						P22.P22_NUMPV
		EndSql

		While (cAlias01)->(!Eof())
			If Empty((cAlias01)->STATRS) .and. (cAlias01)->STATFT == "1"
				AAdd(aRetChav , {(cAlias01)->EMPRESA, (cAlias01)->FILIAL, (cAlias01)->PEDVEND, (cAlias01)->REGNUM})
			ElseIf (cAlias01)->STATFT <> "1"
				AAdd(aAmbiente, {(cAlias01)->EMPRESA, (cAlias01)->FILIAL, (cAlias01)->PEDVEND, (cAlias01)->REGNUM})
			EndIf
			(cAlias01)->(DbSkip())
		EndDo

		(cAlias01)->(dbCloseArea())

		PrintCon("Envio de status de retorno do SEFAZ", cEmpIni + " - " + cFilIni )

		If !Empty(aRetChav)
			For nX := 01 To Len(aRetChav)
				If !SetEnv(aRetChav[nX][01], aRetChav[nX][02], aFiles)
					Break
				Endif

				fEnvStatus(aRetChav[nX][02], aRetChav[nX][03], aRetChav[nX][04])
			Next nX
		EndIf

		PrintCon("Liberacao de PV, geracao de NF e envio ao SEFAZ.", cEmpIni + " - " + cFilIni )

		If Empty(aAmbiente)
			Conout("F0703202 - Não existem Pedidos de Venda a processar.")
		EndIf

		SC5->(DbSetOrder(01))

		For nX := 01 To Len(aAmbiente)
			If !SetEnv(aAmbiente[nX][01], aAmbiente[nX][02], aFiles)
				Return
			Endif

			If SC5->(DbSeek(aAmbiente[nX][02] + aAmbiente[nX][03]))
				U_F0201201("1", aAmbiente[nX][04], "")
			Else
				U_F0201201("2", aAmbiente[nX][04], "Empresa/Filial/Pedido: " + aAmbiente[nX][01] + "/" + aAmbiente[nX][02] + "/" + aAmbiente[nX][03] + " não encontrado no sistema Protheus.")
			EndIf
		Next nX
	End Sequence

	UnLockByName("F0703202" + cEmpIni + cFilIni, .F., .F.)

	If IsBlind()
		RpcClearEnv()
	Endif
	
Return Nil

Static Function PrintCon(cMensagem ,cEmpFil)
	ConOut("**************************************************************************")
	ConOut("* F0703202: " + cMensagem)
	ConOut("* Inicio  : " + FwTimeStamp(2) )
	ConOut("* Montagem do ambiente na empresa " + cEmpFil)
	Conout("* F0703202 - Inicio Thread: " + cValToChar(ThreadID()))
	ConOut("**************************************************************************")

Return

Static Function SetEnv(cEmp, cFil, aFiles)
	If Select("SX2") == 0 .or. cEmp != cEmpAnt
		If !RPCSetEnv( cEmp, cFil, , , , , aFiles )
			Conout("F0703202 - Não foi possivel inicializar o ambiente")
			Return .F.
		EndIf
	EndIf

	If !SM0->(MsSeek(cEmp + cFil))
		Conout("F0703202 - Não foi possivel inicializar o ambiente: Filial ou empresa inválidos.")
		Return .F.
	EndIf

	cFilAnt := cFil
Return .T.

/*/{Protheus.doc} fEnvStatus
Envio de status SEFAZ ao Front.
@author Paulo Krüger
@since  09/03/2017
@param  cFilPed - Filial
@param  cNumPed - Num Pedido
@param  nRecnoP22 - Num do registro da tabela P22
@return Nil
@project MAN0000007423041_EF_032
@cliente Rededor
@version P12.1.7
/*/

Static Function fEnvStatus(cFilPed, cNumPed, nRecnoP22)
	Local cRet		:= ""
	Local cStatus	:= ""
	Local cSTATRS	:= ""

	Begin Sequence
		SC5->(DbSetOrder(01))
		If !SC5->(DbSeek(cFilPed + cNumPed))
			Conout("F0703202 - Registro não encontrado na tabela SC5: Filial/Pedido: " +  cFilPed + "/" + cNumPed)
			U_F0703401(CValToChar(nRecnoP22), cSTATRS, "F", cNumPed)
			Break
		EndIf

		SF2->(DbSetOrder(01))
		If !SF2->(DbSeek(SC5->C5_FILIAL + SC5->C5_NOTA + SC5->C5_SERIE + SC5->C5_CLIENTE + SC5->C5_LOJACLI))
			Conout("F0703202 - Registro não encontrado na tabela SF2: Nota: " + SC5->C5_NOTA + "/" + SC5->C5_SERIE)
			U_F0703401(CValToChar(nRecnoP22), cSTATRS, "F", cNumPed)
			Break
		EndIf

		SF3->(DbSetOrder(04))
		If !SF3->(DbSeek(SF2->F2_FILIAL + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_DOC + SF2->F2_SERIE))
			Conout("F0703202 - Registro não encontrado na tabela SF3: Nota: " + SC5->C5_NOTA + "/" + SC5->C5_SERIE)
			U_F0703401(CValToChar(nRecnoP22), cSTATRS, "F", cNumPed)
			Break
		EndIf

		If SF2->F2_FIMP == "" .AND. AllTrim(SF2->F2_ESPECIE) == "SPED"
			cStatus := "ERRO|" + AllTrim(SF3->F3_CODRSEF) + "-" + "NOTA FISCAL NAO TRANSMITIDA"
			cRet	:= "T"
			cSTATRS := "2"
		ElseIf SF2->F2_FIMP == "T"
			cStatus := "OK|NOTA FISCAL TRANSMITIDA"
			cRet	:= "T"
			cSTATRS := "2"
		ElseIf SF2->F2_FIMP == "D"
			cStatus := "ERRO|" + AllTrim(SF3->F3_CODRSEF) + "-" + "NOTA FISCAL USO DENEGADO"
			cRet	:= "D"
			cSTATRS	:= "2"
		ElseIf SF2->F2_FIMP == "N"
			cStatus := "ERRO|" + AllTrim(SF3->F3_CODRSEF) + "-" + "NOTA FISCAL NAO AUTORIZADA"
			cRet	:= "N"
			cSTATRS := "2"
		ElseIf SF2->F2_FIMP == "S"
			cStatus := "OK|NOTA FISCAL AUTORIZADA"
			cRet	:= "E"
			cSTATRS := "1"
		EndIf

		If cRet == "E"
			U_F0703401( CValToChar(nRecnoP22)      , cSTATRS                    , cNumPed                   , cStatus, ;
			            SF3->F3_FILIAL             , SC5->C5_XTIPO              , cRet                      , SF2->F2_NFELETR, ;
			            SF3->F3_SERIE              , SF3->F3_CLIEFOR            , SF3->F3_LOJA              , "F"            , ;
						StrZero(Day(SF3->F3_EMISSAO),2) + "/" + StrZero(Month(SF3->F3_EMISSAO),2) + "/" + StrZero(Year(SF3->F3_EMISSAO),4), ;
			            SF3->F3_ESPECIE            , CValToChar(SF2->F2_VALBRUT), CValToChar(SF2->F2_VALISS), CValToChar(SF2->F2_VALPIS), CValToChar(SF2->F2_VALCOFI), ;
			            CValToChar(SF2->F2_VALCSLL), CValToChar(SF2->F2_VALIRRF), CValToChar(SF2->F2_VALFAT), SF2->F2_MENNOTA, SF3->F3_CHVNFE              , ;
						SC5->C5_XNUM, SF3->F3_CODNFE )
		Else
			Conout("F0703202 - " + cStatus + " - NOTA: " + SC5->C5_NOTA + "/" + SC5->C5_SERIE)
		EndIf
	End Sequence
Return

