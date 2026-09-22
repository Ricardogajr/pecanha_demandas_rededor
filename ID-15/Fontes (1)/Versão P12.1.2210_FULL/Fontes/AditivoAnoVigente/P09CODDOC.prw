#include "protheus.ch"
/*/{Protheus.doc} P09CODDOC
Atualiza CODDOC da p09 e no arquivo. Projeto descomissionamento.
@type function
@version P12 
@author Ricardo Junior
@since 17/03/2025
@return variant, return_description
/*/
User function P09CODDOC()
	Local aPergs    := {}	
	//Local nTipo 	:= 1

	if Aviso("Atenção", "Rotina responsável por atualiza o sequencial da tabela P09. Primeiro processo ele iria criar um novo sequencial para que possa ser realizada a carga. Segundo processo ele atualiza o sequenacial conforme o numerado, só para os registros atualizado no primeiro processo.", {"Ok", "Cancela"}, 1, "Informação sobre a rotina.") == 2	
		Return
	EndIf
	aAdd(aPergs, {2, "Gera Sequencial P09",               "1", {"1=Sequência nova","2=Atualiza Sequêncial"},     122, ".T.", .F.})

	If !ParamBox(aPergs, "Informe a Filial para ser tratada.")
		Alert("Opção cancelada!")
	EndIf
 	FwMsgRun(NIL, {|oSay| fCarrega(oSay)}, "Processando", "Iniciando processamento...")
	//Processa({|| fCarrega()}, "Processando...", , , , )

	MsgInfo("Rotina finalizada!", "Atenção")
Return 
/*/{Protheus.doc} fCarrega
Função carrega os dados
@type function
@version P12 
@author Ricardo Junior
@since 17/03/2025
@return variant, return_description
/*/
Static Function fCarrega(oSay)
	Local aArea     := FWGetArea()	
	local cArqRed   := '\RDANEXOS\'
	Local nResult   := 0
	Local aRet      := {}
	Local aMatriz   := {}
	Local cAlias := GetNextAlias()
	Local nTotal := 0
	Local nQtd := 0
	Local nError := 0
	Local nOk := 0
	
	cSeqNew := "Z00001"
	if MV_PAR01 == "1"
		cQuery := " SELECT * FROM " + RetSqlName("P09")
		cQuery += " WHERE D_E_L_E_T_ = ' ' "
		cQuery += " AND P09_FILIAL = '"+cFilAnt+"'" 
		
		cQuery := ChangeQuery(cQuery) 
		
		DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAlias, .T., .T.)
		Count To nTotal
		(cAlias)->(DbGoTop())
		While (cAlias)->(!Eof())// .And. AllTrim(cFilAnt) == AllTrim((cAlias)->P09_FILIAL)
			nQtd++
			oSay:SetText("Processando registros "+cValToChar(nTotal)+"/"+cValToChar(nQtd)+"!") // ALTERA O TEXTO CORRETO
			//IncProc("Processando registros "+cValToChar(nTotal)+"/"+cValToChar(nQtd)+"!")			
			cFilCod := (cAlias)->P09_FILIAL+(cAlias)->P09_CODDOC + ".mzp"
			//Aciona a função para renomear os arquivos
			//cCodNew := Getsxenum( 'P09' , "P09_CODDOC" )
			//ConfirmSx8()
			cFilCodNew := (cAlias)->P09_FILIAL+cSeqNew+".mzp"
			//Se foi renomeado com sucesso
			nResult := FRename(cArqRed+cFilCod, cArqRed+cFilCodNew)
			If nResult == 0
				DbSelectArea("P09")			
				P09->(DbGoTo((cAlias)->R_E_C_N_O_))
				if RecLock("P09",.F.)
					P09->P09_CODDOC := cSeqNew
					P09->(MsUnlock())
					aAdd(aRet, "Arquivo " + cFilCod + " alterado para " +cFilCodNew +" com sucesso!"+CRLF)				
					nOk++
				else
					nResult := FRename(cArqRed+cFilCodNew, cArqRed+cFilCod)
					aAdd(aRet, "Erro no Arquivo " + cArqRed+cFilCod + " alterado para " +cArqRed+cFilCodNew + " com sucesso!"+CRLF)
					nError++
				endif				
			Else
				DbSelectArea("P09")			
				P09->(DbGoTo((cAlias)->R_E_C_N_O_))
				if RecLock("P09",.F.)//Altera o registro mesmo que não tenha atualizado o arquivo.
					P09->P09_CODDOC := cSeqNew
					P09->(MsUnlock())
				endif
				aAdd(aRet, "Erro ao renomear o arquivo " + cFilCod + " para "+cFilCodNew+"!"+CRLF)
				nError++
			EndIf
			cSeqNew := Soma1(cSeqNew)
			ProcessMessages()
			(cAlias)->(DbSkip())
		EndDo
	else		
		cQuery := " SELECT * FROM " + RetSqlName("P09")
		cQuery += " WHERE D_E_L_E_T_ = ' ' "
		cQuery += " AND P09_FILIAL = '"+cFilAnt+"'" 
		cQuery += " AND SUBSTR(P09_CODDOC,1,1) = 'Z'"
		cQuery += " ORDER BY P09_FILIAL, P09_CODDOC"
		
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAlias, .T., .T.)
		Count To nTotal
		(cAlias)->(DbGoTop())
		While (cAlias)->(!Eof())
			nQtd++
			oSay:SetText("Processando registros "+cValToChar(nTotal)+"/"+cValToChar(nQtd)+"!") // ALTERA O TEXTO CORRETO
			cFilCod := (cAlias)->P09_FILIAL+(cAlias)->P09_CODDOC + ".mzp"
			//Aciona a função para renomear os arquivos
			cCodNew := Getsxenum( 'P09' , "P09_CODDOC" )
			cFilCodNew := (cAlias)->P09_FILIAL+cCodNew+".mzp"
			//Se foi renomeado com sucesso
			nResult := FRename(cArqRed+cFilCod, cArqRed+cFilCodNew)
			If nResult == 0
				ConfirmSx8()		
				DbSelectArea("P09")			
				P09->(DbGoTo((cAlias)->R_E_C_N_O_))
				RecLock("P09",.F.)
				P09->P09_CODDOC := cCodNew
				P09->(MsUnlock())
				aAdd(aRet, "Arquivo " + cFilCod + " alterado para " +cFilCodNew + " com sucesso!"+CRLF)
				nOk++
			Else
				aAdd(aRet, "Erro ao renomear o arquivo " + cFilCod + " para "+cFilCodNew+"!"+CRLF)
				nError++
				RollBackSX8()
			EndIf
			cSeqNew := Soma1(cSeqNew)
			ProcessMessages()
			(cAlias)->(DbSkip())
		EndDo
	endif
	aAdd(aRet, "ERRO: " + cValToChar(nError) + " Sucesso: "+cValToChar(nOk)+"!"+CRLF)
	cArqName := GetTempPath()+"P09CODDOC_"+FWTimeStamp()+".txt"
	oSay:SetText("Gerando arquivo de log: " +cArqName) // ALTERA O TEXTO CORRETO
	nHandle := MsfCreate(cArqName,0)
	AEval( aRet, { | aMatriz | fWrite(nhandle, aMatriz) } )
	FWRestArea(aArea)
Return
