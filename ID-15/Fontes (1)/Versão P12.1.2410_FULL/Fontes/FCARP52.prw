#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} COMP032_MVC
Exemplo de importacao de dados para uma estrutura pai/filho
para um rotina desenvolvida em MVC

@author Ernani Forastieri e Rodrigo Antonio Godinho
@since 05/10/2009
@version P10
/*/
//-------------------------------------------------------------------
User Function FCARP52()
	Local   aSay     := {}
	Local   aButton  := {}
	Local   nOpc     := 0
	Local   cTitulo   := 'ROTINA DE IMPORTA«√O!'
	Local   cDesc1   := 'Esta rotina fara a importacao de centro de custos x Filiais'
	Local   cDesc2   := 'conforme layout.'
	Local   cDesc3   := ''
	Local   lOk      := .T.
	private   cArqAux  := ""
	private cTxtError := ""
	aAdd( aSay, cDesc1 )
	aAdd( aSay, cDesc2 )
	aAdd( aSay, cDesc3 )

	aAdd( aButton, { 1, .T., { || nOpc := 1, FechaBatch() } } )
	aAdd( aButton, { 2, .T., { || FechaBatch()            } } )

	FormBatch( cTitulo, aSay, aButton )

	If nOpc == 1
		Processa( { || lOk := Runproc() },'Aguarde','Processando...',.F.)
		If lOk
			ApMsgInfo( 'Processamento terminado com sucesso.', 'ATEN«√O' )

		Else
			ApMsgStop( 'Processamento realizado com problemas.', 'ATEN«√O' )
		EndIf

	EndIf

Return NIL

/*/{Protheus.doc} Runproc
Processamento da rotina de carga
@type function
@version P122410 
@author ricar
@since 1/2/2026
@return variant, Null
/*/
Static Function Runproc()
	Local lRet     := .T.
	Local aCposCab := {}
	Local aCposDet := {}

	cArqAux := cGetFile('*.csv|*.csv', 'Selecao de Arquivos', 0, 'C:\', .T., GETF_LOCALHARD  + GETF_NETWORKDRIVE,.T.)

	if Empty(cArqAux)
		ApMsgInfo("Arquivo n„o foi escolhido, por favor, selecionar o arquivo.", "ATEN«√O!")
		return .F.
	endif

	oProcess := MsNewProcess():New( { || validaArq(cArqAux) } , "Validando arquivos selecionados..." , "Aguarde..." , .F. )
	oProcess:Activate()

	aCposCab := {}
	aCposDet := {}

Return lRet
/*/{Protheus.doc} validaArq
Valida arquivo
@type function
@version P122410 
@author Ricardo Junior
@since 1/2/2026
@param cArqAux, character, Arquivo
@return variant, nulo
/*/
static function validaArq(cArqAux)
	Local nX := 0
	Local aDados := {}
	Local aCposCab := {}
	Local aCposDet := {}
	Local aAux := {}

	FT_FUSE(AllTrim(cArqAux))
	nLastRec := FT_FLASTREC()

	oProcess:SetRegua1(nLastRec)

	_nLinha := 0
		/*aAdd(aLog, {"-----------------------------------------------------------", 0})
		aAdd(aLog, {"Iniciando leitura do arquivo: " + aArquivos[nX], 0})
		aAdd(aLog, {"Data da importa√ß√£o: " + DToC(dDataBase), 0})
		aAdd(aLog, {"Importa√ß√£o realizada pelo usu√°rio: " + cUserName, 0})
		aAdd(aLog, {"-----------------------------------------------------------", 0})
		*/
	If nLastRec <= 0
		aAdd(aLog, {"O Arquivo: " + cArqAux +" est· vazio.", 0})
		Return
	EndIf

	//ProcRegua(nLastRec)
	FT_FGOTOP()
	lPrim := .T.
	lRet := .T.
	While !FT_FEOF()
		nX++
		oProcess:IncRegua1("Linha: ..." + cValToChar(nX))
		//IncProc("Lendo arquivo texto...    Linha: " + cValToChar(_nLinha) )
		cLinha := FT_FREADLN()
		_nLinha := _nLinha + 1
		if lPrim
			lPrim := .F.
			lSegun := .T.
			aCabec := StrTokArr2(cLinha, ";",.T.)
			nPosCC := aScan(aCabec, {|x| AllTrim(x) == "P52_CC" })
			nPosFil:= aScan(aCabec, {|x| AllTrim(x) == "P52_FILCC" })
			nPosAtv:= aScan(aCabec, {|x| AllTrim(x) == "P52_ATIVO" })
		else
			aAdd(aDados, StrTokArr2(cLinha, ";",.T.))
		endif
		FT_FSKIP()
	EndDo

	ASort(aDados, , , {|x,y| x[1] + x[2] + x[3] + x[4] < y[1] + y[2] + y[3] + y[4] })
	cCC := aDados[01][nPosCC]
	lErro := .F.
	For nX := 01 To Len(aDados)
		DbSelectArea("CTT")
		DbSetOrder(01)
		if DbSeek(xFilial("CTT")+aDados[nX][nPosCC])
			if cCC == aDados[nX][nPosCC]
				if Len(aCposCab) <= 0
					aAdd( aCposCab, { 'P52_CC' , aDados[nX][nPosCC] } )
				endif
				aAux := {}
				aAdd( aAux, { 'P52_FILCC' , aDados[nX][nPosFil] } )
				aAdd( aAux, { 'P52_ATIVO', aDados[nX][nPosAtv] } )
				aAdd( aAux, { 'P52_CC' , aDados[nX][nPosCC] } )
				aAdd( aCposDet, aAux )
			else
				if Len(aCposCab) > 0 .And. Len(aCposDet) > 0
					Import( 'P52', aCposCab, aCposDet)
				endif
				aCposCab := {}
				aCposDet := {}
				aAdd( aCposCab, { 'P52_CC' , aDados[nX][nPosCC] } )
				aAux := {}
				aAdd( aAux, { 'P52_ATIVO', aDados[nX][nPosAtv] } )
				aAdd( aAux, { 'P52_FILCC' , aDados[nX][nPosFil] } )
				aAdd( aAux, { 'P52_CC' , aDados[nX][nPosCC] } )
				aAdd( aCposDet, aAux )
			endif
		else
			cTxtError += "Erro no Item: "+ AllTrim(aDados[nX][nPosCC]) + "/" + aDados[nX][nPosFil] + CRLF
			cTxtError += "Mensagem do erro: " + ' [O Centro de custo n„o existe] ' + CRLF
			cTxtError += "==================================================" + CRLF
		endif

		cCC := aDados[nX][nPosCC]
	Next nX

	if Len(aCposCab) > 0 .And. Len(aCposDet) > 0
		Import( 'P52', aCposCab, aCposDet)//Carrega o ultimo
	endif

	if !Empty(cTxtError)
		//MostraErro()
		if ShowLog(cTxtError)
			cArquivo := getTemppath()+"log_"+DToS(Date())+"_"+replace(Time(),":","_")+".txt"
			MemoWrite(cArquivo, cTxtError)
			ApMsgInfo("Arquivo salvo no caminho ["+cArquivo+"]", "ATEN«√O!")
		endif
		//AtShowLog(cTxtError, "Mensagem de Error", .T., .T., .T., .T.)
	endif
	cTxtError := ""
Return

/*/{Protheus.doc} Import
ImportaÁ„o da Carga
@type function
@version P122410 
@author ricar
@since 1/2/2026
@param cMaster, character, param_description
@param cDetail, character, param_description
@param aCpoMaster, array, param_description
@param aCpoDetail, array, param_description
@return variant, return_description
/*/
Static Function Import(  cMaster, aCpoMaster, aCpoDetail, lBloq )
	Local  oModel, oAux, oStruct
	Local aArea 	:= GetArea()
	Local aAreaCTT 	:= CTT->(GetArea())
	Local  nI        := 0
	Local  nJ        := 0
	Local  nPos      := 0
	Local  lRet      := .T.
	Local  aAux	     := {}
	Local  nItErro   := 0
	Local  lAux      := .T.

	oModel := FWLoadModel('FCADP52')

	if  Posicione("CTT",1,xFilial("CTT")+aCpoMaster[1][2], "CTT_BLOQ") == "1"
		cTxtError += "Erro no Item: "+ CTT->CTT_CUSTO + CRLF
		cTxtError += "Mensagem do erro: " + ' [O Centro de custo encontra-se bloqueado] '  + CRLF
		cTxtError += "==================================================" + CRLF		
		Return .F.
	endif
	
	if len(aCpoMaster) <= 0
		Return .F.
	endif

	DbSelectArea(cMaster)
	P52->(DbSetOrder(03))
	if !DbSeek(FwxFilial("P52") + aCpoMaster[1][2])
		Reclock("P52",.T.)
		P52->P52_CC := CTT->CTT_CUSTO
		P52->P52_ATIVO := "1"
		P52->(MsUnlock())
	endif
	oModel:SetOperation(4)
	//endif

	lRet := oModel:Activate()

	If lRet
		oAux    := oModel:GetModel( cMaster + 'MASTER' )

		// Obtemos a estrutura de dados do cabe√ßalho
		oStruct := oAux:GetStruct()
		aAux	:= oStruct:GetFields()

		If lRet
			For nI := 1 To Len( aCpoMaster )
				If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoMaster[nI][1] ) } ) ) > 0
					If !( lAux := oModel:SetValue( cMaster + 'MASTER', aCpoMaster[nI][1], aCpoMaster[nI][2] ) )
						lRet    := .F.
						Exit
					EndIf
				EndIf
			Next nI
		EndIf
	EndIf

	If lRet
		oAux     := oModel:GetModel( cMaster + 'DETAIL' )

		oStruct  := oAux:GetStruct()
		aAux	 := oStruct:GetFields()

		nItErro  := 0

		For nI := 1 To Len( aCpoDetail )
			if !Empty(FwFLdGet("P52_FILCC"))
				oAux:AddLine()
			endif
			For nJ := 1 To Len( aCpoDetail[nI] )

				If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoDetail[nI][nJ][1] ) } ) ) > 0
					If !( lAux := oModel:SetValue( cMaster + 'DETAIL', aCpoDetail[nI][nJ][1], aCpoDetail[nI][nJ][2] ) )
						lRet    := .F.
						nItErro := nI
						Exit
					EndIf
				EndIf
			Next nJ

			If !lRet
				Exit
			EndIf

		Next nI

	EndIf

	If lRet
		If ( lRet := oModel:VldData() )
			lRet := oModel:CommitData()
		EndIf
	EndIf

	If !lRet

		aErro   := oModel:GetErrorMessage()

		// A estrutura do vetor com erro √©:
		//  [1] Id do formul√°rio de origem
		//  [2] Id do campo de origem
		//  [3] Id do formul√°rio de erro
		//  [4] Id do campo de erro
		//  [5] Id do erro
		//  [6] mensagem do erro
		//  [7] mensagem da solu√ß√£o
		//  [8] Valor atribuido
		//  [9] Valor anterior

		//AutoGrLog( "Id do formul·rio de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
		//AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
		//AutoGrLog( "Id do formul·rio de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
		//AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
		//AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
		//AutoGrLog( "==================================================")
		//AutoGrLog( "Id do formul·rio de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
		//AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
		//AutoGrLog( "Id do formul·rio de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
		//AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
		//AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
		//AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
		//AutoGrLog( "Mensagem da soluÁ„o:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
		//AutoGrLog( "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
		//AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )

		cTxtError += "Erro no Item: "+ AllTrim(FwFLdGet("P52_CC")) +"/"+ AllTrim(FwFLdGet("P52_FILCC")) + CRLF
		cTxtError += "Mensagem do erro: " + ' [' + AllToChar( aErro[6]  ) + ']'  + CRLF
		cTxtError += "==================================================" + CRLF
		//AutoGrLog( "Erro no Item:              "+ AllTrim(oModel:Getvalue("P52DETAIL", "P52_CC")) +"/"+ AllTrim(oModel:Getvalue("P52DETAIL", "P52_FILCC")))
		//AutoGrLog( "==================================================")
		//AutoGrLog(cTxtError)
	EndIf
	oModel:DeActivate()
	RestArea(aAreaCTT)
	RestArea(aArea)
Return lRet
