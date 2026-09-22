#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} REDA004
//Rotina de Desvincular Solicita��o/Item.
@author Cesar
@since 13/06/2017
@version 1.0
@type function
 // Cria o Objeto XML.
   oXml := XmlParser(_sModelo, "_", @cError, @cWarning )
// Salva o objeto XML em uma string, jah com quebras de linha
_sXML := XMLSaveStr (_oXML, .T., .T.)
/*/
*---------------------------*
User Function REDA004()
*---------------------------*
			
Local nRecno 		:= SC1->(Recno())
Local cFilSc1		:= PadR(SC1->C1_FILIAL, TamSx3("C1_FILIAL")[01])
Local cNum			:= PadR(SC1->C1_NUM, TamSx3("C1_NUM")[01])
Local cIdBionexo	:= PadR(SC1->C1_XIDBIO, TamSx3("C1_XIDBIO")[01])
Local cProduto		:= PadR(SC1->C1_PRODUTO, TamSx3("C1_PRODUTO")[01])

Local lExecAll  	:= .F.
Local lDesvSc 		:= .F.
Local lDesvForca    := .F.
    
Local nCont			:= 0
Local nContErr		:= 0
Local cAliasSC1 := GetNextAlias()
Local aSolicitacoes := {}
Local cMV_XDTBIO:= SuperGetMv("MV_XDTBIO",,DToC(Date()+1))
Local cMV_XHRBIO:= SuperGetMv("MV_XHRBIO",,"00:00"		)

// Posiciono no Registro Selecionado	
SC1->( DbGoTo(nRecno) )
//If ( SC1->( DbSeek(cFilSc1 + cNum) ) )

//Private bDesvSolIt	:= {|| ProcessarIt() }
//Private bDesvSolAll	:= {|| ProcessarAll() }
		
Private lMsg		:= .F.
	
Private cFilBkp		:= ""
Private cIdProc		:= ""
// Define Cancelamento como N�O
Private cCancel		:= "N"

// Salva estado atual do aRotina	
aRotinaBkp := aRotina

// Inicializo um novo aRotina	
//aRotina := {}
	  
If ( MsgYesNo("Desvincular toda a Solicita��o?","Desvincular solicita��o") )
	// Define Desvinvulo para TODOS os Itens da SC
	lExecAll := .T.
	// Define Cancelamento como SIM
	cCancel  := "S"
EndIf
	
// Processa apenas o Item selecionado
If !(lExecAll)
	//aRotina   := {{ "Processar" ,"Eval(bDesvSolIt)" , 0, 4}}
	
	cQuery := "  SELECT * " + CRLF
	cQuery += " 	FROM "+ RetSqlName("SC1") +" SC1 " 	+ CRLF
	cQuery += " 	WHERE SC1.D_E_L_E_T_ = ' '" 			+ CRLF
	cQuery += " 	AND SC1.C1_FILIAL  = '" + cFilSc1 + "'" 	+ CRLF
	cQuery += " 	AND SC1.C1_XIDBIO  = '" + cIdBionexo + "'" 	+ CRLF
	cQuery += " 	AND SC1.C1_PRODUTO = '" + cProduto 	+ "'" 	+ CRLF
	cQuery += " 	AND SC1.C1_QUJE    = 0 "	+ CRLF
	cQuery += " 	AND SC1.C1_XENVBIO = '2'" 	+ CRLF
	
	If Select("cAliasSC1") > 0
		(cAliasSC1)->(DbCloseArea())
	EndIf 	
	
	DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasSC1, .F., .T.)
	
	cIdProc := AllTrim(FWUUIDV4())// - 29/09/2017 RTE							
	aAdd(aSolicitacoes,{{"PARAMETROS", 	"LAYOUT=WA;ID="+(cAliasSC1)->C1_XIDBIO},;
						{"FILIAL", 		cFilAnt},;
						{"LOGIN", 		"teste1"},;
						{"PASSWORD", 	"teste1"},;
						{"OPERACAO",	"WAUE"},;
						{"XIDPROC", 	cIdProc},;
						{"CANCELAMENTO", cCancel } } )
					
	While !(cAliasSC1)->(Eof())
		If (cAliasSC1)->C1_XCANWAU != "S" .And. (cAliasSC1)->C1_XENVBIO == "2" .And. Empty((cAliasSC1)->C1_COTACAO) .And. Empty((cAliasSC1)->C1_PEDIDO) 
			nCont++
			lMsg := .T.								
			aAdd(aSolicitacoes,{{"C1FILIAL",    (cAliasSC1)->C1_FILIAL				},;
								{"C1NUM",		(cAliasSC1)->C1_NUM					},;
								{"C1ITEM",		(cAliasSC1)->C1_ITEM				},;
								{"TITPDC", 		"XXX"								},;
								{"XCONDPAG",	(cAliasSC1)->C1_CONDPAG				},;
								{"XDTCOTA", 	cMV_XDTBIO},;
								{"XHRCOTA", 	cMV_XHRBIO},;
								{"C1PRODUTO",	AllTrim((cAliasSC1)->C1_PRODUTO)	},;
								{"C1QTSEGUM",	cValToChar(0) 						},;
								{"C1OBS",		(cAliasSC1)->C1_OBS   				},;
								{"C1XTPSC",		(cAliasSC1)->C1_XTPSC             	},;
								{"C1MOEDA",		cValToChar((cAliasSC1)->C1_MOEDA) 	},;
								{"C1XIDBIO", 	(cAliasSC1)->C1_XIDBIO 				} } )
																																																						
		// Verifico se j� foi processado Desvinculo	
		ElseIf ( (cAliasSC1)->C1_XCANWAU == "S" ) .And. ( (cAliasSC1)->C1_XENVBIO == "2" ) .And. ;
		       ( Empty( (cAliasSC1)->C1_COTACAO ) ) .And. ( Empty( (cAliasSC1)->C1_PEDIDO ) )
			// Defino como j� processado o Desvinculo
			lDesvSc := .T.
			nContErr++
		EndIf
		(cAliasSC1)->(DbSkip())
	EndDo				
	
	// Verifica se existe Item j� Processado para Desvinculo
	If ( Len(aSolicitacoes) > 0 )
		Processa({||fbDesvSolIt(aSolicitacoes)}, "Aguarde...", "Processando...", .F.)
	EndIf
	
	// Verifica se foi encontrado algum Registro para processamento	
	If ( nCont == 0 .And. lMsg )
		Aviso("Integra��o Bionexo","N�o foram encontrados itens nesta solicita��o para solicitar o desvinculo.",{"Fechar"})
	EndIf
	
	// Verifica se foi encontrado algum Registro j� processado	
	If nContErr > 0
		If MsgYesNo("Integra��o Bionexo","Desvincular solicita��o", "Esta SC esta em processo de conta��o no Bionexo e n�o poder� ser Desvincular! Deseja for�ar no Protheus?")
		   (cAliasSC1)->(DbGoTop())
		   DbSelectArea("SC1")
		   SC1->(DbSetOrder(01))			    
			While !(cAliasSC1)->(Eof())
				If DbSeek((cAliasSC1)->C1_FILIAL+(cAliasSC1)->C1_NUM+(cAliasSC1)->C1_ITEM)
					RecLock("SC1", .F.)
						SC1->C1_XCANWAU := ""
						SC1->C1_XENVBIO := ""
						SC1->C1_XIDBIO  := ""
						SC1->C1_XDTCOTA := CToD('  /  /    ')
						SC1->C1_XHRCOTA := ""
						SC1->C1_XIDPROC := "" 
					SC1->(MsUnLock())
				EndIf
			EndDo
		EndIf
	EndIf
	
// Processa TODOS os Itens da SC selecionada		
ElseIf ( lExecAll )

	cQuery := "  SELECT * " + CRLF
	cQuery += " 	FROM "+ RetSqlName("SC1") +" SC1 " 	+ CRLF
	cQuery += " 	WHERE SC1.D_E_L_E_T_ = ' '" 			+ CRLF
	cQuery += " 	AND SC1.C1_FILIAL  = '" + cFilSc1 + "'" 	+ CRLF
	cQuery += " 	AND SC1.C1_XIDBIO  = '" + cIdBionexo + "'" 	+ CRLF
	cQuery += " 	AND SC1.C1_QUJE    = 0 "	+ CRLF
	cQuery += " 	AND SC1.C1_XENVBIO = '2'" 	+ CRLF
	
	If Select("cAliasSC1") > 0
		(cAliasSC1)->(DbCloseArea())
	EndIf 	
	
	DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasSC1, .F., .T.)
	
	//If ( SC1->( DbSeek(cFilSc1 + cNum) ) )
		
		// Processo TODA SC			
		While !(cAliasSC1)->(Eof()) //.And. ( SC1->C1_FILIAL == cFilSc1 ) .And. ( SC1->C1_NUM == cNum ) )
			
			// Verifica se foi enviado para o Bionexo com determinada Quantidade Entregue 	
			//If ( !Empty( SC1->C1_XIDBIO ) .And. ( SC1->C1_QUJE > 0 ) )
			//If ( SC1->C1_XIDBIO == cIdBionexo .And. ( SC1->C1_QUJE > 0 ))
			//	SC1->( DbSkip() )
			//	Loop
			// Verifica se n�o foi enviado para o Bionexo
			//ElseIf ( Empty( (cAliasSC1)->C1_XIDBIO ) )
			//	SC1->( DbSkip() )
			//	Loop
			// Verifica se foi enviado para o Bionexo e esta Aguardando Desvinculo 
			// 1 - Aguardando Integra��o, 2 - Integrado Bionexo, 3 - Aguandando Desvinculo, 4 - Erro de Integra��o
			//ElseIf ( !Empty( SC1->C1_XIDBIO ) .And. ( SC1->C1_XENVBIO == "3" ) )
			//	SC1->( DbSkip() )
			//	Loop
			//EndIf
			// Verifico se n�o foi Desvinculado e se n�o foi Integrado ao Bionexo
						
			//If ( SC1->C1_XCANWAU # "S" ) .And. ( SC1->C1_XENVBIO == "2" ) .And.;
			If ( (cAliasSC1)->C1_XCANWAU != "S" ) .And. ( (cAliasSC1)->C1_XENVBIO == "2" ) .And. ;
			   ( Empty( (cAliasSC1)->C1_COTACAO ) ) .And. ( Empty( (cAliasSC1)->C1_PEDIDO ) )
				nCont++ 
			// Verifico se j� foi processado Desvinculo	
			//ElseIf ( SC1->C1_XCANWAU == "S" ) .And. ( SC1->C1_XENVBIO == "2" ) .And.;
			ElseIf ( (cAliasSC1)->C1_XCANWAU == "S" ) .And. ( (cAliasSC1)->C1_XENVBIO == "2" ) .And. ;							
			       ( Empty( (cAliasSC1)->C1_COTACAO ) ) .And. ( Empty( (cAliasSC1)->C1_PEDIDO ) )	
				// Defino como j� processado o Desvinculo
				lDesvSc := .T.
				nContErr++
				nCont++ 
			EndIf													
			(cAliasSC1)->( DbSkip() )				
		End
			
	//EndIf
	
	// Posiciono no Registro Selecionado	
	//SC1->( DbGoTo(nRecno) )
			
	// Verifica se foi encontrado algum Registro para processamento	
	If ( nCont == 0 )
		Aviso("Integra��o Bionexo","N�o foram encontrados itens nesta solicita��o para solicitar o desvinculo.",{"Fechar"})
		aRotina := aRotinaBkp
		Return
	EndIf
	
	// Verifica se foi encontrado algum Registro j� processado	
	If ( nContErr > 0 )
		If ( MsgYesNo("Integra��o Bionexo","Esta SC esta em processo de conta��o no Bionexo e n�o poder� ser Desvincular! Deseja for�ar no Protheus?","Desvincular solicita��o") )
			lDesvForca := .T.				
		EndIf		
	EndIf
	
	SC1->(DbGoTo(nRecno))
	ProcessarAll( lDesvForca )
	lMsg := .T.

	// Restauro o estado do aRotina		
	aRotina := aRotinaBkp
EndIf
	
// Informo o fim do Processamento			
Aviso("Atencao", "Rotina finalizada!",{"OK"})
		
Return( .T. )

*-------------------------------*   	
Static Function ProcessarIt()
*-------------------------------*   	

Local nRecno 		:= SC1->(Recno())
Local aSolicitacoes := {}
Local cMV_XDTBIO:= SuperGetMv("MV_XDTBIO",,DToC(Date()+1))
Local cMV_XHRBIO:= SuperGetMv("MV_XHRBIO",,"00:00"		)

// Posiciono no Registro Selecionado	
SC1->( DbGoTo(nRecno) )
//If ( SC1->( DbSeek(cFilSc1 + cNum) ) )
				
	cIdProc := AllTrim(FWUUIDV4())// - 29/09/2017 RTE
	aAdd(aSolicitacoes,{ {"PARAMETROS", 	"LAYOUT=WA;ID="+SC1->C1_XIDBIO},;
		{"FILIAL", 		cFilAnt},;
		{"LOGIN", 		"teste1"},;
		{"PASSWORD", 	"teste1"},;
		{"OPERACAO",	"WAUE"},;
		{"XIDPROC", 	cIdProc},;
		{"CANCELAMENTO", cCancel } } )
										
	aAdd(aSolicitacoes,{ {"C1FILIAL", SC1->C1_FILIAL},;
		{"C1NUM",		SC1->C1_NUM					},;
		{"C1ITEM",		SC1->C1_ITEM				},;
		{"TITPDC", 		"XXX"						},;
		{"XCONDPAG",	SC1->C1_CONDPAG				},;
		{"XDTCOTA", 	cMV_XDTBIO},;
		{"XHRCOTA", 	cMV_XHRBIO},;
		{"C1PRODUTO",	SC1->C1_PRODUTO				},;
		{"C1QTSEGUM",	cValToChar(0) 				},;
		{"C1OBS",		SC1->C1_OBS   				},;
		{"C1XTPSC",		SC1->C1_XTPSC             	},;
		{"C1MOEDA",		cValToChar(SC1->C1_MOEDA) 	},;
		{"C1XIDBIO", 	SC1->C1_XIDBIO 				} } )
																																		
	// Verifica se existe Item j� Processado para Desvinculo
	// 02/10/2017
	// Ricardo da Silva				
	If ( Len(aSolicitacoes) > 0 )
		Processa({||fbDesvSolIt(aSolicitacoes)}, "Aguarde...", "Processando...", .F.)
	EndIf	
	
//EndIf
		
Return( .T. )


*-------------------------------*   	
Static Function ProcessarAll( lDescForca )
*-------------------------------*   	
    
    Local cNum		:= ""
    Local cFilSc1	:= ""
    Local cAliasSc1 := GetNextAlias()
    Local aSolicitacoes := {}
    Local cIdBionexo 	:= SC1->C1_XIDBIO
    Default lDescForca	:= .F.
	
	cFilSc1 := SC1->C1_FILIAL
	cNum 	:= SC1->C1_NUM		
/*	
	DbSelectArea("SC1")
	SC1->( DbSetOrder(01) )
	SC1->( DbGoTop() )*/
	
	cQuery := "  SELECT * " + CRLF
	cQuery += " 	FROM "+ RetSqlName("SC1") +" SC1 " 	+ CRLF
	cQuery += " 	WHERE SC1.D_E_L_E_T_ = ' '" 			+ CRLF
	cQuery += " 	AND SC1.C1_FILIAL  = '" + cFilSc1 + "'" 	+ CRLF
	cQuery += " 	AND SC1.C1_XIDBIO  = '" + cIdBionexo + "'" 	+ CRLF
	cQuery += " 	AND SC1.C1_QUJE    = 0 "	+ CRLF
	cQuery += " 	AND SC1.C1_XENVBIO = '2'" 	+ CRLF
	
	If Select("cAliasSC1") > 0
		(cAliasSC1)->(DbCloseArea())
	EndIf 	
	
	DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasSC1, .F., .T.)
	
	//If ( SC1->( DbSeek(cFilSc1 + cNum) ) )
	
	cIdProc := AllTrim(FWUUIDV4())// - 29/09/2017 RTE					 								
	aAdd(aSolicitacoes,{ 	{"PARAMETROS", 	"LAYOUT=WA;ID="+SC1->C1_XIDBIO},;
							{"FILIAL", 		cFilAnt},;
							{"LOGIN", 		"teste1"},;
							{"PASSWORD", 	"teste1"},;
							{"OPERACAO",	"WAUE"},;
							{"XIDPROC", 	cIdProc},;
							{"CANCELAMENTO", cCancel } } )				
	While (!(cAliasSC1)->(Eof())) 	
		//If ( Empty( SC1->C1_XIDBIO ) )
		//	SC1->( DbSkip() )
		//	Loop
		//EndIf
		//While !SC1->(Eof()) .And. ( SC1->C1_FILIAL == cFilSc1 ) .And. ( SC1->C1_NUM == cNum )
			
			// Verifica se foi enviado para o Bionexo com determinada Quantidade Entregue 	
			//If ( !Empty( SC1->C1_XIDBIO ) .And. ( SC1->C1_QUJE > 0 ) )
			//	SC1->( DbSkip() )
			//	Loop
			// Verifica se n�o foi enviado para o Bionexo
			//ElseIf ( Empty( SC1->C1_XIDBIO ) )
			//	SC1->( DbSkip() )
			//	Loop
			// Verifica se foi enviado para o Bionexo e esta Aguardando Desvinculo 
			// 1 - Aguardando Integra��o, 2 - Integrado Bionexo, 3 - Aguandando Desvinculo, 4 - Erro de Integra��o
			//ElseIf ( !Empty( SC1->C1_XIDBIO ) .And. ( SC1->C1_XENVBIO == "3" ) )
			//	SC1->( DbSkip() )
			//	Loop
			//EndIf
			
											
			aAdd(aSolicitacoes,{{"C1FILIAL",	(cAliasSC1)->C1_FILIAL} ,;
								{"C1NUM",		(cAliasSC1)->C1_NUM}    ,;
								{"C1ITEM",		(cAliasSC1)->C1_ITEM}	,;
								{"TITPDC", 		"XXX"}          ,;
								{"XCONDPAG",	(cAliasSC1)->C1_CONDPAG},;
								{"XDTCOTA", 	cMV_XDTBIO},;
								{"XHRCOTA", 	cMV_XHRBIO},;				
								{"C1PRODUTO",	(cAliasSC1)->C1_PRODUTO}  ,;
								{"C1QTSEGUM",	cValToChar(0)}  ,;
								{"C1OBS",		(cAliasSC1)->C1_OBS}    ,;
								{"C1XTPSC",		(cAliasSC1)->C1_XTPSC}	    ,;
								{"C1MOEDA",		cValToChar((cAliasSC1)->C1_MOEDA)},;
								{"C1XIDBIO", 	(cAliasSC1)->C1_XIDBIO } } )
																																				
		(cAliasSC1)->( DbSkip() )
		//If 	!(( SC1->C1_FILIAL == cFilSc1 ) .And. ( SC1->C1_NUM == cNum ))
		//	Exit
		//EndIf	
		
	End
	If ( Len(aSolicitacoes) > 0 )
		// For�a o Desvinculo
		If ( !lDescForca ) 
			Processa({||fbDesvSolAll(aSolicitacoes)}, "Aguarde...", "Processando...", .F.)
		Else
			//Processa({||fbDesvSolIt(aSolicitacoes)}, "Aguarde...", "Processando...", .F.)							
			Processa({||fAtuSCAll(aSolicitacoes)}, "Aguarde...", "Processando...", .F.)
		EndIf
	EndIf	
		
	aSolicitacoes := {}
	//U_WsLogBio("REDA004", 1, "ENCONTROU A SOLICITACAO " + cFilSc1 + aSolicitacoes[2][2]+ aSolicitacoes[3][2])			
	
Return( .T. )


*-------------------------------*   	
Static Function fbDesvSolIt(aSolicitacoes)
*-------------------------------*
	
    Local nY 		:= 0
		
	ProcRegua(Len(aSolicitacoes))
		
	aXml := U_RedWsdL2("WAU", aSolicitacoes)
	Do Case 
		// Ok
		Case aXml[1] == "1"
			ProcRegua(Len(aSolicitacoes))
			For nY := 02 To Len(aSolicitacoes)
				IncProc("Atualizando os itens da solicita��o...")
				U_WsLogBio("REDA004", 1, "Atualizando os itens da solicita��o...")
				fAtuSCIt(aSolicitacoes[nY])								
			Next
			Aviso("Integra��o Bionexo","Solicita��o/item enviada para ser desvinculada.",{"OK"})		
		otherwise
			Aviso("Integra��o Bionexo","Erro: " + aXml[2],{"Fechar"})			
	EndCase

Return( .T. )


*-------------------------------*   	
Static Function fbDesvSolAll(aSolicitacoes)
*-------------------------------*

    Local nY 		:= 0

	ProcRegua(Len(aSolicitacoes))
		
	aXml := U_RedWsdL2("WAU", aSolicitacoes)
	ProcRegua(Len(aSolicitacoes))
	For nY := 02 To Len(aSolicitacoes)
		IncProc("Atualizando os itens da solicita��o...")
		fAtuSCIt(aSolicitacoes[nY])
	Next nY
	
	//U_WsLogBio("WASERET", 1, )
	Aviso("Integra��o Bionexo","Solicita��o/Item Desvinculada.",{"OK"})		
	
Return( .T. )


Static Function fAtuSCIt(aSolicitacoes)
	
	Local cFilSc1 	:= PadR(SC1->C1_FILIAL, TamSx3("C1_FILIAL")[01])
		
	DbSelectArea("SC1")
	SC1->( DbSetOrder(01) )
	If ( SC1->(DbSeek(aSolicitacoes[1][2] + aSolicitacoes[2][2]+ aSolicitacoes[3][2])) )
		U_WsLogBio("REDA004", 1, "ENCONTROU A SOLICITACAO " + cFilSc1 + aSolicitacoes[2][2]+ aSolicitacoes[3][2])		
		RecLock("SC1",.F.)
			SC1->C1_XENVBIO := "3"
			SC1->C1_XIDPROC := cIdProc 
	    SC1->( MsUnLock() )
	EndIf    
	
Return( .T. )

Static Function fAtuSCAll(aSolicitacoes)
		
	Local cFilSc1 := PadR(aSolicitacoes[1][2][2], TamSx3("C1_FILIAL")[01]) as character
	Local nX      := 0                                                     as numeric
		
	DbSelectArea("SC1")
	SC1->( DbSetOrder(01) )
	SC1->(DbGoTop())
	For nX := 01 To Len(aSolicitacoes)
		If ( SC1->(DbSeek(cFilSc1 + aSolicitacoes[2][2][2] )))
			_cNumSc := aSolicitacoes[2][2][2]
			While !SC1->(Eof()) .And. cFilSc1 == SC1->C1_FILIAL .And. _cNumSc == SC1->C1_NUM 
				U_WsLogBio("REDA004", 1, "ENCONTROU A SOLICITACAO" + cFilSc1 + aSolicitacoes[2][2][2])		
				RecLock("SC1", .F.)
					SC1->C1_XCANWAU := "N"
					SC1->C1_XENVBIO := ""
					SC1->C1_XIDBIO  := ""
					SC1->C1_XDTCOTA := CToD('  /  /    ')
					SC1->C1_XHRCOTA := ""
					SC1->C1_XIDPROC := "" 
				SC1->(MsUnLock())
				SC1->(DbSkip())
			EndDo
		EndIf    
	Next nX
Return( .T. )

/*
If ( MsgYesNo("Integra��o Bionexo","Esta SC esta em processo de conta��o no Bionexo e n�o poder� ser Desvincular! Deseja for�ar no Protheus?","Desvincular solicita��o") )
				RecLock("SC1", .F.)
					SC1->C1_XCANWAU := ""
					SC1->C1_XENVBIO := ""
					SC1->C1_XIDBIO  := ""
					SC1->C1_XDTCOTA := CToD('  /  /    ')
					SC1->C1_XHRCOTA := ""
					SC1->C1_XIDPROC := "" 
				SC1->(MsUnLock())
			EndIf
*/
