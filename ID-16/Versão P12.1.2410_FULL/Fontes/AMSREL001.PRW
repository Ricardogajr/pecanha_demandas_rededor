#INCLUDE 'PROTHEUS.CH'

/*
{Protheus.doc} AMSREL001()
Relatório de títulos recusados no sistema.
@Author     Lucas Miranda de Aguiar
@Since      03/01/2023
@Version    P12.27
@Project    AMS MELHORIAS
   
*/
User Function AMSREL001()

	Local oReport := "N"
	Private cAlQry := GetNextAlias()

//-----------------------------------------------------------------------------
//--[ id 1522 ]----------------------------------------------------------------
	private dDtPriRec := ctod( space( 10 )) // id 1522
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

	if !pergunte( 'FSW0101003' , .T. )
		Return
	Else
		oReport := ReportDef()
		oReport:PrintDialog()
	Endif

Return

// ----------------------------------------------------------------------------
/*
{Protheus.doc} ReportDef()
Auxiliar Relatório de títulos recusados no sistema.
@Author     Lucas Miranda de Aguiar
@Since      03/01/2023
@Version    P12.27
@Project    AMS MELHORIAS
@Return		oReport, objeto TReport
*/
Static function ReportDef()

	Local oReport
	Local oSection1
	Local cTitulo := '[AMSREL001] - Impressão de Documentos Recusados'

	oReport := TReport():New( 'AMSREL001' , cTitulo , , { |oReport| PrintReport( oReport ) } , 'Este relatório irá imprimir os documentos recusados.' )

	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()

	oSection1 := TRSection():New( oReport , 'Filial' , { 'QRY' } )
	oSection1:SetTotalInLine(.F.)

	TRCell():new( oSection1 , 'P00_FILIAL' , cAlQry , RetTitle( 'P00_FILIAL' ) , PesqPict( 'P00' , 'P00_FILIAL' ) , 010 , .F. , )
	TRCell():new( oSection1 , 'P00_FORNEC' , cAlQry , RetTitle( 'P00_FORNEC' ) , PesqPict( 'P00' , 'P00_FORNEC' ) , 010 , .F. , )
	TRCell():new( oSection1 , 'P00NOMFOR' , cAlQry , 'Nome Fornecedor' , , 010 , .F. , )
	TRCell():new( oSection1 , 'P00_LOJAF'  , cAlQry , RetTitle( 'P00_LOJAF'  ) , PesqPict( 'P00' , 'P00_LOJAF'  ) , 010 , .F. , )
	TRCell():new( oSection1 , 'P00_DTRECU' , cAlQry , 'Data Ult.Recusa'        , PesqPict( 'P00' , 'P00_DTRECU' ) , 010 , .F. , )
	TRCell():new( oSection1 , 'QTDEREC'    , cAlQry , 'Qt Rec'           , '99'                             , 010 , .F. , )
	TRCell():new( oSection1 , 'P00_NUM'    , cAlQry , RetTitle( 'P00_NUM'    ) , PesqPict( 'P00' , 'P00_NUM'    ) , 010 , .F. , )
	//TRCell():new( oSection1 , 'P00_USRREC' , cAlQry , RetTitle( 'P00_USRREC' ) ,                                  ,     , .F. , )
	TRCell():new( oSection1 , 'P00MOTIVO'  , cAlQry , RetTitle( 'P00_MOTIVO' ) ,                                  , 090 , .F. , )
	TRCell():new( oSection1 , 'P00_TIPO'   , cAlQry , RetTitle( 'P00_TIPO'   ) ,                                  , 010 , .F. , )
	//TRCell():new( oSection1 , 'E2_XSTRECU' , cAlQry , 'STATUS'                 ,                                  , 010 , .F. , )
	TRCell():new( oSection1 , 'E2_XTPREQ'  , cAlQry , 'Solicitante'            ,                                  , 010 , .F. , )

Return oReport

// ----------------------------------------------------------------------------
/*
{Protheus.doc} ReportDef()
@Author     Lucas Miranda de Aguiar
@Since      03/01/2023
@Version    P12.27
@Project    AMS MELHORIAS
@Param		oReport, objeto TReport
*/
Static Function PrintReport(oReport)

	Local oSection1	:= oReport:Section(1)
	local cQuery    := ''
	Local aRegs     := {}

	oSection1:Init()
	oSection1:SetHeaderSection(.T.)

	cQuery += " SELECT	DISTINCT(P00_FILIAL||P00_NUM||P00_PREFIX||P00_FORNEC||P00_LOJAF) AS CHAVE, "
	cQuery += " utl_raw.cast_to_varchar2(P00_MOTIVO) AS P00MOTIVO, P00.* "
	cQuery += " FROM " + RetSqlName("P00") + " P00"
	cQuery += "     WHERE P00.D_E_L_E_T_  = ''  "
	cQuery += "       AND P00.P00_FILIAL >= '" + alltrim( MV_PAR01 ) + "' "
	cQuery += "       AND P00.P00_FILIAL <= '" + alltrim( MV_PAR02 ) + "' "
	cQuery += "       AND P00.P00_DTRECU >= '" +    dtos( MV_PAR03 ) + "' "
	cQuery += "       AND P00.P00_DTRECU <= '" +    dtos( MV_PAR04 ) + "' "
	cQuery += "       AND P00.P00_PREFIX >= '" + alltrim( MV_PAR05 ) + "' "
	cQuery += "       AND P00.P00_PREFIX <= '" + alltrim( MV_PAR07 ) + "' "
	cQuery += "       AND P00.P00_NUM    >= '" + alltrim( MV_PAR06 ) + "' "
	cQuery += "       AND P00.P00_NUM    <= '" + alltrim( MV_PAR08 ) + "' "

	If MV_PAR09 == 1
		cQuery += " AND P00.P00_TIPO = 'D'"
	ElseIf MV_PAR09 == 2
		cQuery += " AND P00.P00_TIPO = ' '"
	EndIf

	cQuery += " ORDER BY P00.P00_DTRECU DESC, R_E_C_N_O_ DESC"

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T. , 'TOPCONN' , TcGenQry( , , cQuery ) , cAlQry , .F. , .T. )

	(cAlQry)->(dbGoTop())

	If (cAlQry)->(EOF())
		help( '' , 1 , 'Sem Dados' , , 'Não foi possÃ­vel localizar dados correspondentes a essa pesquisa' , 1 , 0 )
	Else
		oReport:SetMeter(0)
		DbSelectArea("SA2")
		Do While (cAlQry)->(!Eof())
			If oReport:Cancel()
				Exit
			EndIf
			oReport:IncMeter()

			If aScan(aRegs,( cAlQry )->CHAVE) == 0
				AADD(aRegs,(cAlQry)->CHAVE)
				lInclui := fValidaP00()
				If lInclui
					oSection1:Cell( 'P00_DTRECU' ):SetValue( stod( ( cAlQry )->P00_DTRECU ))
					oSection1:Cell( 'P00_DTRECU' ):SetAlign( 'CENTER' )
					//oSection1:Cell( 'P00_USRREC' ):SetValue(   fNomRecu( ( cAlQry )->P00_USRREC , 1 ))
					//oSection1:Cell( 'P00_USRREC' ):SetAlign( 'CENTER' )
					oSection1:Cell( 'P00MOTIVO' ):SetValue( ( cAlQry )->P00MOTIVO )
					oSection1:Cell( 'P00MOTIVO' ):SetAlign( 'LEFT' )
					If alltrim( ( cAlQry )->P00_TIPO ) == 'D'
						oSection1:Cell( 'P00_TIPO' ):SetValue( 'DOC ENTRADA'    )
					Else
						oSection1:Cell( 'P00_TIPO' ):SetValue( 'CONTAS A PAGAR' )
					Endif
					oSection1:Cell( 'P00_TIPO' ):SetAlign( 'LEFT' )
					oSection1:Cell( 'E2_XTPREQ'  ):SetValue( fNomRecu( ( cAlQry )->P00_USREMI , 1 ))
					oSection1:Cell( 'P00NOMFOR'  ):SetValue( AllTrim(Posicione("SA2",1,xFilial("SA2")+( cAlQry )->P00_FORNEC+( cAlQry )->P00_LOJAF,"SA2->A2_NREDUZ")))
					oSecTion1:Cell('QTDEREC'):SetValue(fQtdRec())
					oSection1:PrintLine()
				EndIf
			EndIf
			(cAlQry)->(dbSkip())
		EndDo
	EndIf
	oSection1:Finish()
	(cAlQry)->(DbCloseArea())
Return

// ----------------------------------------------------------------------------

Static Function fNomRecu(cUser,nTp)

	Local cIDRecusa	:= cUser
	local cNomeRecu := ''
	Local nOrder := nTp

	PSWORDER(nOrder)

	If (PSWSEEK(cIDRecusa))
		cNomeRecu	:= Alltrim(PSWRET()[01][04])
	EndIf

return( AllTrim(cNomeRecu) )
//--------------------------------------------------------------------------------


Static function fValidaP00()

	Local lRet := .F.
	Local cAliasVal := GetNextAlias()
	Local cQuery := ""
	Local cTabela := ""

	If AllTrim(( cAlQry )->P00_TIPO) == ""
		cQuery := "SELECT E2_XDTRECU, E2_XSTRECU FROM " + RETSQLNAME("SE2")
		cQuery += " WHERE D_E_L_E_T_ = ' ' "
		cQuery += " AND E2_FILIAL = '"+( cAlQry )->P00_FILIAL+"'"
		cQuery += " AND E2_NUM = '"+( cAlQry )->P00_NUM+"'"
		cQuery += " AND E2_PREFIXO = '"+( cAlQry )->P00_PREFIX+"'"
		cQuery += " AND E2_FORNECE = '"+( cAlQry )->P00_FORNEC+"'"
		cQuery += " AND E2_LOJA = '"+( cAlQry )->P00_LOJAF+"'"
		cQuery += " AND E2_XDTRECU <> ' ' AND E2_XSTRECU = 'R'"
		cTabela := "SE2"
	ElseIf AllTrim(( cAlQry )->P00_TIPO) == "D"
		cQuery := "SELECT F1_XDTRECU, F1_XSTRECU FROM " + RETSQLNAME("SF1")
		cQuery += " WHERE D_E_L_E_T_ = ' ' "
		cQuery += " AND F1_FILIAL = '"+( cAlQry )->P00_FILIAL+"'"
		cQuery += " AND F1_DOC = '"+( cAlQry )->P00_NUM+"'"
		cQuery += " AND F1_SERIE = '"+( cAlQry )->P00_PREFIX+"'"
		cQuery += " AND F1_FORNECE = '"+( cAlQry )->P00_FORNEC+"'"
		cQuery += " AND F1_LOJA = '"+( cAlQry )->P00_LOJAF+"'"
		cQuery += " AND F1_XDTRECU <> ' ' AND F1_XSTRECU = 'R'"
		cTabela := "SF1"
	EndIf

	If !Empty(cQuery)
		cQuery := ChangeQuery(cQuery)
		DbUseArea( .T. , 'TOPCONN' , TcGenQry( , , cQuery ) , cAliasVal , .F. , .T. )

		If !(cAliasVal)->(EOF())
			lRet := .T.
		EndIf
		(cAliasVal)->(dbcloseArea())
	EndIf
Return lRet



Static Function fQtdRec()

	Local cAliasVal := GetNextAlias()
	Local cQuery := ""
	Local cTotal := ""

	cQuery := "SELECT COUNT(*) AS TOTAL FROM " +RetSqlName("P00") +"WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND P00_FILIAL||P00_NUM||P00_PREFIX||P00_FORNEC||P00_LOJAF = '"+( cAlQry )->CHAVE+"'"
	cQuery += " AND P00_TIPO = '"+( cAlQry )->P00_TIPO+"'"
	cQuery += " AND utl_raw.cast_to_varchar2(P00_MOTIVO) NOT LIKE '[CANCELAMENTO DE RECUSA]%'"

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T. , 'TOPCONN' , TcGenQry( , , cQuery ) , cAliasVal , .F. , .T. )

	cTotal := cValToChar((cAliasVal)->TOTAL)

	(cAliasVal)->(dbcloseArea())

Return cTotal
