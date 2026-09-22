#Include "protheus.ch"

/*/{Protheus.doc} REDA006
Programa para o gerar o de Cadastro de Log's de Erro da Integração Bionexo.
É utilizado gerar os registros de Log de erros gerados durante o processamento 
da geração de cotações do que ainda não tinha sido integrada com o Bionexo no 
botao INTEGRAR BIONEXO ao menu de ações relacionadas.
@type function
@author Ricardo da Silva
@since 19/06/2017
@change 21/09/2017
@version 1.2
@return NIL
/*/

User Function REDA006( _cZFilial, _cZRotina, _cZNumero, _cZItem, _cZUser, _cZError, _cZIdBio, _cZIdProc )
	
	Local aArea			:= GetArea()
	Local cUser 		:= ""
	
	Local _lIdProc		:= .T.
	
	Default _cZFilial	:= xFilial("SC1")
	Default _cZRotina	:= "1"     // SC( Solicitação de Compras)
	Default _cZUser 	:= RetCodUsr()
	Default _cZItem		:= Space(TamSx3("C1_ITEM")[1]) //Space(04)  //"0001"
	Default _cZIdBio	:= Space(TamSx3("C1_XIDBIO")[1]) //Space(06) //"000002"
	Default _cZNumero	:= Space(TamSx3("C1_NUM")[1])
	Default _cZIdProc	:= Space(TamSx3("C1_XIDPROC")[1]) //Space(254)
	
	// 21/09/2017
	// Verifica se _cZNumero esta Vazia e confirma o seu Valor Padrão 
	If ( Empty( _cZNumero ) )
		_cZNumero	:= Space(TamSx3("C1_NUM")[1])
	EndIf
		
	// Verifica se _cZItem esta Vazia e confirma o seu Valor Padrão
	If ( Empty( _cZItem ) )
		_cZItem := Space(TamSx3("C1_ITEM")[1]) //Space(04)
	EndIf	
	
	// Verifica se _cZIdBio esta Vazio e confirma o seu Valor Padrão
	If ( Empty( _cZIdBio ) )
		_cZIdBio := Space(TamSx3("C1_XIDBIO")[1]) //Space(06)
	EndIf
	
	// Verifico se é um Processo Normal sem ID de Processo
	If ( Empty( _cZIdProc ) )
		//If !( ZZA->( DbSeek( _cZFilial + _cZRotina + _cZNumero + _cZItem + DToS( dDataBase ) + _cZIdBio ) ) )				
		// Identifica o Usuário
		cUser := fUserSC(_cZFilial, _cZNumero, _cZItem, _cZIdBio)			
		//EndIf	
	// Verifico se é um ID de Processo
	ElseIf ( !Empty( _cZIdProc ) )
		DbSelectArea("SC1")
		If ( DbOrderNickName("IDPROC") )
			If ( SC1->( MsSeek( _cZIdProc ) ) )
				// Localiza os Valores da SC, Item e ID Bionexo
				_cZNumero 	:= SC1->C1_NUM
				_cZItem		:= Space(TamSx3("C1_ITEM")[1]) //SC1->C1_ITEM
				_cZIdBio	:= SC1->C1_XIDBIO
				// Identifico o Usuário
				cUser := fUserSC(_cZFilial, , , , _lIdProc)
				
			EndIf
		EndIf
		
	EndIf
	
	// 21/09/2017
	// Tratamento do armazenamento para Registros de Erros
	DbSelectArea("ZZA")
	ZZA->( DbSetOrder( 1 ) )
	// Inclui o Erro no Log
	RecLock("ZZA",.T.)
		ZZA->ZZA_FILIAL := _cZFilial
		ZZA->ZZA_ROTINA := _cZRotina
		ZZA->ZZA_NUMERO := _cZNumero
		ZZA->ZZA_ITEM  	:= _cZItem
		ZZA->ZZA_DATA  	:= dDataBase
		ZZA->ZZA_HORA  	:= Time()
		ZZA->ZZA_USUARI	:= IIf(Empty(cUser), _cZUser, cUser)
		ZZA->ZZA_MSG   	:= _cZError
		ZZA->ZZA_IDBIO  := _cZIdBio 
		// Armazena o Valor do ID do Processo
		If ( !Empty( _cZIdProc ) )	
			ZZA->ZZA_IDPROC := _cZIdProc
		EndIf				
	ZZA->( MsUnLock() )
	
	RestArea( aArea )	
	
Return( .T. )

Static Function fUserSC(cFil, cNumero, cItem, cIdBio, lIdProc)
	
	Local cUserSC 	:= ""
	Local cQuery 	:= ""
	Local cAliasSC1 := GetNextAlias()
	
	Default cFil 	:= ""
	Default cIdBio 	:= ""
	Default	lIdProc := .F.

	cQuery := " SELECT SC1.R_E_C_N_O_ AS RECNO, SY1.Y1_USER FROM " + RetSqlName("SC1") + " SC1 " + CRLF
	cQuery += " LEFT JOIN " + RetSqlName("SY1") + " SY1 " + CRLF
	cQuery += " ON SC1.D_E_L_E_T_ = SY1.D_E_L_E_T_ " + CRLF
	cQuery += " AND SY1.Y1_COD = SC1.C1_XCPBIO " + CRLF
	cQuery += " WHERE SC1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " AND C1_FILIAL 	= '"+ PadR(cFil, TamSx3("C1_FILIAL")[1]) 	+"' " + CRLF
	// Verifico se é um Processo Normal sem ID de Processo
	If !( lIdProc )
		cQuery += " AND C1_NUM 		= '"+ PadR(cNumero, TamSx3("C1_NUM")[1])  	+"' " + CRLF
		cQuery += " AND C1_ITEM 	= '"+ PadR(cItem, TamSx3("C1_ITEM")[1]) 	+"' " + CRLF
		//cQuery += " AND C1_XIDBIO 	= '"+ PadR(cIdBio,TamSx3("C1_XIDBIO")[1])  	+"' " + CRLF
	// Verifico se é um ID de Processo
	ElseIf ( lIdProc )
		cQuery += " AND C1_XIDPROC 	= '"+ PadR(cItem, TamSx3("C1_XIDPROC")[1]) 	+"' " + CRLF	
	EndIf
	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC1,.T.,.T.)
	
	// Verifico se é um Processo Normal sem ID de Processo
	If !( lIdProc )
		If !( (cAliasSC1)->(Eof()) )
			cUserSC := (cAliasSC1)->Y1_USER
		EndIf
	// Verifico se é um ID de Processo		
	ElseIf ( lIdProc )
		While !( (cAliasSC1)->(Eof()) )
			SC1->(DbGoTo((cAliasSC1)->RECNO))
			RecLock("SC1", .F.)//Atualiza a solicitação de compras para o status de ERRO DE INTEGRAÇÃO.
				SC1->C1_XENVBIO := "4"
			SC1->(MsUnlock())
		End
		cUserSC := (cAliasSC1)->Y1_USER				
	EndIf
	
Return( cUserSC )