
/*/{Protheus.doc} FMigraCT2
Rotina responsável por migrar os dados de uma filial para outra na contabilidade.
@type function
@version P122410 
@author Ricardo Junior
@since 4/22/2026
@return variant, Nulo
/*/
User function FMigraCT2()

	Local aPergs    := {}
	Local cFilDe    := {}
	Local cFilAte   := {}
	Local dDataDe   := {}
	Local dDataAt   := {}
	Local cLoteDe   := {}
	Local cLoteAte  := {}
	Local cDocDe    := {}
	Local cDocAte   := {}

	aAdd(aPergs, {1, "Fil. Origem",  cFilOrig, "", ".T.", "SM0",    ".T.", 80, .T.})//MV_PAR01
	aAdd(aPergs, {1, "Fil. Destino", cFilDest,  "", ".T.", "SM0", ".T.", 80,  .F.})//MV_PAR02
	aAdd(aPergs, {1, "Data De",   dDataDe,  "", ".T.", "", ".T.", 80,  .T.})//MV_PAR03
	aAdd(aPergs, {1, "Data Até",  dDataAt,  "", ".T.", "", ".T.", 80,  .T.})//MV_PAR04
	aAdd(aPergs, {1, "Lote de",   cLoteDe, "", ".T.", "",    ".T.", 80, .T.})//MV_PAR05
	aAdd(aPergs, {1, "Lote até",  cLoteAte,  "", ".T.", "", ".T.", 80,  .F.})//MV_PAR06
	aAdd(aPergs, {1, "Doc. de",   cDocDe, "", ".T.", "",    ".T.", 80, .T.})//MV_PAR07
	aAdd(aPergs, {1, "Doc. até",  cDocAte,  "", ".T.", "", ".T.", 80,  .F.})//MV_PAR08

	if parambox(aPergs, "Informe os parâmetros para execução da rotina.")
		if !FwFilExist(MV_PAR01)
			FWAlertErro("Atenção", "A filial origem não existe!")
			Return
		endif
		if !FwFilExist(MV_PAR02)
			FWAlertErro("Atenção", "A filial destino não existe!")
			Return
		endif
		oProcess := MsNewProcess():New({|| execMigra(oProcess)}, "Processando...", "Aguarde...", .T.)
		oProcess:Activate()			
	else
		FWAlertInfo("Atenção", "A Rotina foi cancelada pelo usuário!")
	endif

Return

/*/{Protheus.doc} execMigra
Função responsável por executar a migração.
@type function
@version  P122410
@author ricar
@since 4/27/2026
@param aPergs, array, perguntas do parambox
@return variant, nulo
/*/
Static Function execMigra(oObj)
	Local aArea      := FWGetArea()
	Local cQuery    := ""

	If Select(QRYCT2) > 0
		(QRYCT2)->(DbCloseArea())
	EndIf

	cLogDest := "DESTINO " + DToS(Date()) + " " + Time() + " " + MV_PAR01 + " " + UsrRetName(cCodUsr)
	cLogOrig:= "ORIGEM " + DToS(Date()) + " " + Time() + " " + MV_PAR01 + " " + UsrRetName(cCodUsr)

	cQuery += " SELECT CT2_FILIAL '"+MV_PAR02+"', CT2_XMIGTRF '"+cLogDest+"', CT2.* FROM " + RetSqlName("CT2") + " CT2 " + CRLF
	cQuery += " WHERE CT2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " AND CT2.CT2_FILIAL = '"+MV_PAR01+"' " + CRLF
	cQuery += " AND CT2.CT2_DATA = '"+MV_PAR03+"' BEETWEEN '"+MV_PAR04+"' " + CRLF
	cQuery += " AND CT2.CT2_LOTE = '"+DToS(MV_PAR05)+"' BEETWEEN '"+DToS(MV_PAR06)+"' " + CRLF
	cQuery += " AND CT2.CT2_DOC = '"+MV_PAR07+"' BEETWEEN '"+MV_PAR08+"' " + CRLF

	DbUseArea(.T., "TOPCONN", TCGenQry( , , cQuery), "QRYCT2", .F., .T.)

	//Caso haja dados, exibe uma mensagem
	If !QRYCT2->(EoF())
		nQtdReg := QRYCT2->(RecCount())
		oObj:SetRegua1(nQtdReg)
		QRYCT2->(DbGoTop())
		if MsgYesNo("Foram encontrados " +cValTochar(nQtdReg)+ " registros para a copia da filial "+MV_PAR01+" para a "+MV_PAR02+". Deseja continuar?", "Atenção")
			DbSelectArea("CT2")
			CT2->(DBRLock())
			Append From ( QRYCT2 ) VIA 'TOPCONN'//Importa tabela temporaria
			nAtual := 0
			While !QRYCT2->(Eof())
				nAtual++
        		oObj:IncRegua1("Analisando registro " + cValToChar(nAtual) + " de " + cValToChar(nQtdReg) + "...")
				CT2->(DbGoTo(QRYCT2->R_E_C_N_O_))
				RecLock("CT2", .F.)
				CT2->CT2_XDELTRF := "S"
				CT2->CT2_XMIGTRF := cLogOrig
				CT2->(DbDelete())
				CT2->(MsUnlock())
			QRYCT2->(DbSkip())
			enddo

			FWAlertSuccess("Atenção", "Rotina finalizada com sucesso!")
		else
			FWAlertInfo("Atenção", "A Rotina foi cancelada pelo usuário!")
		endif
	else
		FWAlertInfo("Nenhum registro foi encontrado!")
	EndIf
	
	FWRestArea(aArea)
Return
