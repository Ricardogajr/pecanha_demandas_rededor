#INCLUDE "FIVEWIN.CH"
#INCLUDE "GPEM160.CH"

//-----------------------------------------------------------------------
/*/{Protheus.doc} F0501703
Rotina rИplica da GPEM160, porИm, sС permitindo exclusЦo de lanГamentos gerados via integraГЦo.
 
@author Nairan Alves Silva
@since  07/12/2017
@return Nil  

@project MAN0000007423048_EF_019
@cliente Rededor
@version P12.1.7
             
/*/
//-----------------------------------------------------------------------
User Function F0501703()

Local aSays		   := {}
Local aButtons	   := {}
Local cPerg        := "FSW0501703"
Local nOpcA		   := 0.00

Private aArea		:= GetArea()
Private aAreaSRA	   := SRA->( GetArea() )
Private cTabela		:= "" 
Private cCadastro 	:= OemToAnsi(STR0001) //"Cancelamentos de Calculos"
Private cCanPro    := ""
Private cCanRot    := ""
Private cCanPer    := ""
Private cCanNpg    := ""
Private cCanVrb    := ""
Private cNOTCanRGB := ""
Private cNOTCanSRC := ""
Private cNOTCanSRK := ""
Private cCanFil    := ""
Private cCanMat    := ""
Private cCanTip2   := ""
Private cProcesso  := ""
Private lCanTod    := .F.
Private nTipCanc   := 0 
Private cModFol		:= SuperGetMv( "MV_MODFOL", .F., "1" )

private cFilRCJ := ""


If !U_F0501702(__cUserId)
	Alert("UsuАrio nЦo possui permissЦo para executar a rotina!")
	Return
EndIf

aAdd(aSays,OemToAnsi(STR0002) )  //"Este programa exclui as verbas na movimenta┤фo mensal."
aAdd(aSays,OemToAnsi(STR0003) )  //"Informe o tipo de calculo e as verbas para exclusфo ou digite [*] ( Asterisco ) "
aAdd(aSays,OemToAnsi(STR0004) )  //"para excluir todas as verbas do tipo de calculo escolhido."
aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
aAdd(aButtons, { 1,.T.,{|o| nOpcA := 1,IF(gpconfOK(),FechaBatch(),nOpcA:=0) }} )
aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )
FormBatch( cCadastro, aSays, aButtons )

IF nOpcA == 1
	Processa({|lEnd| GPM160Processa( cPerg ),STR0001})  //"Cancelamentos de Calculos"
EndIF

//Restaura os Dados de Entrada						   	        
RestArea( aAreaSRA ) 
RestArea( aArea )
Return( NIL )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁGpm160Processa	ЁAutorЁEquipe Advanced RH Ё Data Ё27/02/2002Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁProcessar o Cancelamento de Calculo no SIGAGPE    		   	   Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁGpm160Processa()											         Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM160                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁNIL															             Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ															                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function Gpm160Processa( cPerg )
Local aCodFol	    := {}   
Local cFilDe     := ""
Local cFilAte    := ""
Local cCcDe      := ""
Local cCcAte     := ""
Local cMatDe     := ""
Local cMatAte    := ""
Local cCategoria := ""
Local cSituacao  := ""
Local cFim		:= ""
Local cFilAnt	   := Replicate("!", FwGetTamFilial)
Local nX		   := 0.00
Local cWhere	   := ""
Local cQuery	   := ""
Local cSeek		:= ""
Local cCodigo   := ""
Local laCodFol	:= !Empty( xFilial("SRV") )
Local lAvisoBlq  := .T.
Local lAvisoVrb  := .T.
Local lAvisoPON  := .T.
Local lBloqPON	:= ("3" $ SuperGetMv( "MV_BLOQPON",,"" ))
Local cAcessaSRA := &( " { || " + IF( Empty( cAcessaSRA := ChkRH( "GPEM160" , "SRA" , "2" ) ) , ".T." , cAcessaSRA ) + " } " )
Local cFilAnter	:= "_cFilAnter"
Local lFilValid  := .T.
Local lValidar	:= .T.
Local lBloqPer   := .F.
Local lGPROXFUN := ExistBlock("GPROXFUN")
Private cInicio := 'RA_FILIAL + RA_PROCES + RA_MAT'
Private dDtRefDe	:= Nil
Private dDtRefAte	:= Nil
Private lDataRef	:= Nil
Private lDtRefSRK	:= (aScan(SRK->(DbStruct()),{|x|AllTrim(x[1]) == "RK_DTREF"}) > 0) 


// VerIFica as perguntas selecionadas                           
Pergunte( cPerg , .F. )

// Carregando as Perguntas                                      
cCanPro	  	:= 	mv_par01	//Processo
cCanRot	  	:= 	mv_par02	//Roteiro
cCanPer	  	:= 	mv_par03	//Periodo
cCanNpg	  	:=	mv_par04	//Numero de Pagamento
nTipCanc    := 	mv_par05	//Tipo de Cancelamento - Informado/Gerado/Calculado/Ponto Eletronico/Valroes Futuros
cCodigo     :=  mv_par06	//Informe as verbas
cFilDe      :=  mv_par07	//Filial De
cFilAte     :=  mv_par08	//Filial Ate
cCcDe       :=  mv_par09	//Centro de Custo De
cCcAte      :=  mv_par10	//Centro de Custo Ate
cMatDe      :=  mv_par11	//Matricula De
cMatAte     :=  mv_par12	//Matricula Ate
cSituacao   :=  mv_par13 	//Situacoes	
cCategoria  :=  mv_par14 	//Categorias
dDtRefDe	:=	mv_par15	// Data de referencia inicial
dDtRefAte	:=	mv_par16	// Data de referencia final
lDataRef	:=  IIF(! Empty(dDtRefAte), .T., .F.)

// Ponto de Entrada para checar as perguntas de calculo.        
If ExistBlock("GPCHKPER")
	If !ExecBlock("GPCHKPER",.F.,.F.)
		Return
	EndIf
Endif

// Monta String para Testar as Verbas                           
cCanVrb := AllTrim( cCanVrb )
For nX = 1 To 30 Step 3 
	cCanVrb += SubStr(cCodigo,nX,3) 
	cCanVrb += "/"
Next nX

If "*" $ cCanVrb
	lCanTod := .T.
EndIF 

cCanVrb := STRTRAN(cCanVrb, "   /", NIL) 
cCanVrb := Substr(cCanVrb, 1, Len(cCanVrb) -1 )
cCanVrb := STRTRAN(cCanVrb, "/", "','")

// Retorna os Tipos para o Cancelamento de Calculo	            
cCanTip2 := RetTipo2(nTipCanc) 

//Para o tipo calculado, sempre referenciar a tabela SRC
//desde que nao tenha filtro de verbas, se tiver
//cancelara o processamento
If cCanTip2 == "C" .And. cModFol == "2" .And. !lCanTod
	If !gpConfOk(OemToAnsi(STR0005)) //"Para o tipo calculado as verbas selecionadas devem ser [*] ( Asterisco )"
		GPEM160() 
		Return( NIL )
	Else
		lCanTod := .T.
	EndIf
EndIf  

//O Tipo calculado fica sempre no SRC
If nTipCanc == 3 //calculados
	//If cCanRot $ "VTR/VRF/VAL/PLA/BEN" //para excluir os valores integrados para folha
    If cCanRot $ (fGetCalcRot('8') +"/"+fGetCalcRot('D')+"/"+fGetCalcRot('E')+"/"+fGetCalcRot('C')+"/"+fGetCalcRot('I'))
		cTabela  := "RGB"
    Else
        cTabela  := "SRC"
	 EndIf  
ElseIf nTipCanc == 5 //valores futuros
	cTabela  := "SRK"
Else //informados/gerados/ponto eletronico
	cTabela  := "RGB"
EndIF

// Carrega Regua Processamento	                                  
ProcRegua( SRA->( RecCount() ) )

// Seta as Ordens Cuja Chave Contenha ??_Filial + ??_Mat        
SRA->( dbSetOrder( RetOrdem( "SRA" ) ) )

// Procura primeiro funcionario                                 
SRA->( dbSetOrder( RetOrdem( "SRA" , "RA_FILIAL+RA_PROCES+RA_MAT" ) ) )
SRA->( dbSeek( cFilDe + cCanPro + cMatDe , .T. ) )

// Inicia o Processamento                                       
cFim := ( cFilAte + cCanPro + cMatAte )   

While SRA->( !Eof() .and. &(cInicio) <= cFim )

	IF !( SRA->RA_FILIAL $ fValidFil() ) .or. !Eval( cAcessaSRA )
		SRA->( dbSkip() )
		IncProc()
		Loop
	EndIF

	// PE para desprezar funcionario, caso retorne .t.   
	IF lGPROXFUN //ExistBlock("GPROXFUN")
		If Execblock("GPROXFUN",.F.,.F.)
			dbSelectArea( "SRA" )
			SRA->( dbSkip() )
			IncProc()
			Loop      	
		EndIf
	EndIF               

	// Consiste Parametrizacao do Intervalo de Impressao            
	IF  SRA->(RA_MAT < cMatDe .or. RA_MAT > cMatAte .or. ;
				RA_FILIAL < cFilDe .or. RA_FILIAL > cFilAte .or. ;
	    		RA_CC < cCcDe .or. RA_CC > cCcAte .or.;
	    		!( RA_CATFUNC $ cCategoria ) .or.;
	    		RA_PROCES <> cCanPro .or. ;
       		!( RA_SITFOLH $ cSituacao ))
	    IncProc()
		SRA->( dbSkip() )
		Loop
	EndIF 

   If cFilAnter != SRA->RA_FILIAL
		cFilAnter := SRA->RA_FILIAL
		lValidar  := .T.
		lFilValid := .T.	
	EndIf

	If lValidar
		 lValidar  := .F.
	    //Verifica se o calculo esta Liberado
		 If !( lFilValid := fVldAccess( SRA->RA_FILIAL, Stod( cCanPer + "01" ), cCanNpg, lAvisoBlq, cCanRot, "2" ) )
		     lAvisoBlq := .F.
			  SRA->( dbSkip() )
			  IncProc()
			  Loop
		 EndIf
	ElseIf !lFilValid
		 lAvisoBlq := .F.
		 SRA->( dbSkip() )
		 IncProc()
		 Loop
	EndIf
		
	// Incrementa Regua Processamento	                          
	IncProc(SRA->RA_FILIAL+" - "+SRA->RA_MAT+" - "+SRA->RA_NOME)

	cCanFil := SRA->(RA_FILIAL) 
	cCanMat := SRA->(RA_MAT)
	lBloqPer := .F. //se tiver algum tipo de bloqueio, nЦo exclui

   //Verifica se pode alterar Verbas de Adto.
	If !fVldAccess( SRA->RA_FILIAL, Stod( cCanPer + "01" ), cCanNpg, lAvisoVrb, "ADI", "4", "V" )
	    lAvisoVrb := .F.
	    lBloqPer  := .T.
	EndIf
						
	//?-Bloqueia Verbas vindas do SIGAPON
	If lBloqPON .And. Upper(cCanTip2) == "E"
	    Iif( lAvisoPON, fVldAltPon( "2" ), Nil )	//?-Apresenta Mensagem
	    lAvisoPON := .F.
	    lBloqPer  := .T.
	EndIf
	
	If !lBloqPer
        Gpm160RGB(.T.)	    
	EndIf

	// Proximo Funcionario				 					     
	SRA->( dbSkip() )
	
End While
If cTabela == "RGB"
	 DbSelectArea("RCH")
	 DbSetOrder(1) //RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR
	 If DbSeek(xFilial("RCH")+cCanPro+cCanPer+cCanNpg+cCanRot)
	     RecLock("RCH",.F.)
		  RCH->RCH_DTINTE  := Ctod("  /  /    ")
		  RCH->( MsUnlock() )
	 EndIf
EndIf
Return( NIL )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁRetTipo2		ЁAutorЁMarinaldo de Jesu  Ё Data Ё27/02/2002Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRetorna os Tipos Para Cancelamento de Calculo     		   	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁRetTipo2(nTipCanc)                           				Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM160                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁcTipo2														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ															Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function RetTipo2(nTipCanc)
Local cTipo2 := ""

// Verifica os Tipos para Exclusa						     
IF nTipCanc == 1			//Informados
	cTipo2 := "I"				
ElseIF nTipCanc == 2		//Gerados
	cTipo2 := "G"				
ElseIF nTipCanc == 3		//Calculados
	cTipo2 := "C"			
ElseIF nTipCanc == 4		//Integracao do Ponto Eletronico
	cTipo2 := "E"
ElseIF nTipCanc == 5		//Valores Futuros
	cTipo2 := " "
EndIF
Return( cTipo2 )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁfProcesso		   ЁAutorЁ                   Ё Data Ё          Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁAtualiza a variavel cProcesso.                    		     	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁfProcesso(Variavel com Processo)		       				   Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM160                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  Ё.t.   														             Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ															                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function fProcesso(cVar)
	cProcesso := cVar
	Gpm020SetVar()
Return (.T.)

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁfPeriodo		   ЁAutorЁ                   Ё Data Ё          Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁAtualiza a variavel cPeriodo                      		   	   Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁfPeriodo(Variavel com Periodo)               				   Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM160                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  Ё.t.   														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ															Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function fPeriodo(cVar)
	cPeriodo := cVar           
Return (.T.)

/*
зддддддддддбддддддддддбдддддбдддддддддддддддддддддддддддбддддбдддддддддд©
ЁFun┤┘o    ЁGpem160RotЁAutorЁEquipe Inovacao RH         ЁDataЁ30/08/2013Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддддаддддадддддддддд╢
ЁDescri┤┘o ЁValidar o Roteiro digitado na Consulta Padrao			    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGPEM160			                  	                       	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
User Function Gpem160Rot( cRtPro, cRtPer, cRtNpg, cRtVarRet, lPergRot, lTelaCalc )
Local aPerAtual	:= {}
Local cFilRCH
Local lRet     	:= .T.
Local lFound 	:= .F.
Local cTipoRot 	:= fGetTipoRot( &cRtVarRet )

DEFAULT lPergRot  := .T.
DEFAULT lTelaCalc := .F.

// Variavel pertence aos mnemonicos. Para evitar erros no sistema para os paises que nao possuem esse mnemonico cadastrado
If Type( "lDissidio" ) == "U"
	lDissidio := .F.
EndIf

If lTelaCalc
	If !fGetPerAtual( @aPerAtual, cFilRCJ, cRtPro, &cRtVarRet )
		MsgInfo( OemToAnsi(STR0007) , OemToAnsi(STR0006) ) // "Nenhum Periodo Ativo para este Roteiro!" ## "Atencao"
		Return(.F.)
	Else
		mv_par03 := aPerAtual[1,1]
		mv_par04 := aPerAtual[1,2]
		Return(.T.)
	EndIf
EndIf

Begin Sequence

 	If Empty( cRtPro ) .Or. !( lRet := ExistCpo( "SRY" ) )
		lRet := .F.
		Break
	EndIf

	cFilRCH	:= xFilial("RCH")

	DbSelectArea("RCH")
	RCH->( dbsetOrder( Retorder( "RCH" , "RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR" ) ) )
	If cTipoRot <> "9"   //Roteiro Diferente de Autonomos
		RCH->( dbSeek( cFilRCH + cRtPro + cRtPer + cRtNpg, .F. ) )
		While RCH->(!Eof() .And. ((RCH_FILIAL + RCH_PROCES + RCH_PER + RCH_NUMPAG)	==	(cFilRCH + cRtPro + cRtPer + cRtNpg)))	
			If RCH->((	RCH_ROTEIR == &cVarRet .And. Empty( RCH_DTFECH)) .Or. (Empty( RCH_ROTEIR )	.And. Empty( RCH_DTFECH )))
				lFound := .T.
				Exit
			EndIf
			RCH->( dbSkip() )
		EndDo
	Else	
		RCH->( dbSeek( cFilRCH + cRtPro + cRtPer , .F. ) )
		While RCH->(!Eof() .And. ((RCH_FILIAL + RCH_PROCES + RCH_PER) ==	(cFilRCH + cRtPro + cRtPer)))	
			If RCH->((	RCH_ROTEIR == &cVarRet .And. Empty(RCH_DTFECH))	.Or. (Empty(RCH_ROTEIR)	.And. Empty(RCH_DTFECH)))
				lFound := .T.
				Exit
			EndIf
			RCH->( dbSkip() )
		EndDo
   	EndIf
	If ( lFound )
		lFound := ExistCpo( "SRY" )
	EndIf

	If !( lFound ) .And. !lDissidio
		If lPergRot
			If MsgNoYes( OemToAnsi(STR0008) ) //"Utiliza Periodo para a Execucao do Roteiro"
				lRet := .F.
				MsgInfo( OemToAnsi(STR0009) , OemToAnsi(STR0006) ) // "Nenhum Roteiro Cadastrado com este Periodo!" ## "Atencao"
			EndIf
		Else
			lRet := .F.
			MsgInfo( OemToAnsi(STR0009) , OemToAnsi(STR0006) ) // "Nenhum Roteiro Cadastrado com este Periodo!" ## "Atencao"
		EndIf
	EndIf

End Sequence

Return( lRet )

/*
здддддддддбддддддддддбдддддбдддддддддддддддддддддддддддбддддбдддддддддд©
ЁFun┤┘o   ЁGpm160BeneЁAutorЁEquipe Inovacao RH       ЁDataЁ02/09/2013Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддддаддддадддддддддд╢
ЁDescricao ЁLimpar os valores calculados dos itens de beneficios SR0			Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGPEM160			                  	   	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function Gpm160Bene()
Local lRet    := .T.
Local cTpVale := ""
Local cFilSR0 := xFilial("SR0")
Local lNovoCal:= NovoCalcBEN()

If cCanRot == fGetCalcRot('8')	//"VTR"
    cTpVale := "0" 
ElseIf cCanRot == fGetCalcRot('D')	//"VRF"
    cTpVale := "1" 
Else
    cTpVale := "2" 
EndIf

DbSelectArea("SR0")
DbSetOrder(RetOrder("SR0", "R0_FILIAL+R0_MAT+R0_TPVALE+R0_CODIGO+R0_PEDIDO"))
If (SR0->(DbSeek(cFilSR0 + cCanMat + cTpVale)))
	 While SR0->(!Eof() .and. R0_FILIAL+R0_MAT+R0_TPVALE == cFilSR0 + cCanMat + cTpVale)
		If lNovoCal
			If SR0->R0_PEDIDO == "1"
				SR0->( RecLock( "SR0" , .F. ) )
					SR0->(dbDelete())				
				SR0->(MsUnLock())
			EndIf
		Else
			SR0->( RecLock( "SR0" , .F. ) )
			SR0->R0_DIASPRO	:= 0
			SR0->R0_DUTILM	:= 0
			SR0->R0_DNUTIM	:= 0
			SR0->R0_SALBASE	:= 0
			SR0->R0_CC		:= ""
			SR0->R0_FALTAS 	:= 0
			SR0->R0_FERIAS 	:= 0
			SR0->R0_AFAST 	:= 0
			SR0->R0_QDIADIF	:= 0
			SR0->R0_VALDIF 	:= 0
			SR0->R0_CUNIDF 	:= 0
			SR0->R0_CFUNDF	:= 0
			SR0->R0_CEMPDF	:= 0
			SR0->R0_QDIACAL	:= 0
			SR0->R0_VALCAL 	:= 0
			SR0->R0_VLRVALE	:= 0
			SR0->R0_VLRFUNC	:= 0
			SR0->R0_VLREMP 	:= 0					
			SR0->( MsUnLock() )
		EndIf
		SR0->(DbSkip())
	 EndDo
EndIf
Return( lRet )

/*
зддддддддддбддддддддддбдддддбдддддддддддддддддддддддддбддддбдддддддддд©
ЁFun┤┘o    ЁGpm160PlasЁAutorЁEquipe Inovacao RH       ЁDataЁ02/09/2013Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддаддддадддддддддд╢
ЁDescricao ЁDeleta os valores calculados de plano de saude		      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>								  Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>								  Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGPEM160				                  	   				  Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function Gpm160Plas()
Local lRet     := .T.
Local aArea    := GetArea()
Local cQuery
Local cNameDB
Local cDelet
Local cSqlName := InitSqlName( "RHR" )
	
	//O banco DB2 nao aceita o nome da tabela apos o comando DELETE			 
  	cNameDB	:= Upper(TcGetDb())
  		
	cQuery := "DELETE " 
			
	If TcSrvType() != "AS/400" .And. !( cNameDB $ "INFORMIX" ) 
		cDelet 		:= "RHR.D_E_L_E_T_ = ' ' " 
	ElseIf ( cNameDB $ "INFORMIX" )
   		cDelet	:= cSqlName +  ".D_E_L_E_T_ = ' ' "
   	Else		
		cDelet	:= "RHR.@DELETED@ = ' ' "
	EndIf
              	   		
	If !( cNameDB $ "DB2_ORACLE_INFORMIX_POSTGRES" )
		cQuery += cSqlName
	EndIf
	
	//O Informix precisa do nome da tabela ao inves do Alias no comando DELETE
	If ( cNameDB $ "INFORMIX" )
		cQuery += " FROM " + cSqlName
	Else
		cQuery += " FROM " + cSqlName + " RHR"
		cSqlName := "RHR"
	EndIf

	cQuery += " WHERE " + cSqlName + ".RHR_FILIAL = '" + cCanFil + "'"
	cQuery += " AND " + cSqlName + ".RHR_MAT = '" + cCanMat + "'"
	cQuery += " AND " + cSqlName + ".RHR_COMPPG = '" + cCanPer + "'" 
	cQuery += " AND " + cDelet 
	
	TcSqlExec( cQuery )
	RestArea( aArea )
Return( lRet )

/*
зддддддддддбддддддддддбдддддбдддддддддддддддддддддддддбддддбдддддддддд©
ЁFun┤┘o    ЁGpm160Out ЁAutorЁLeandro Drumond          ЁDataЁ25/02/2014Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддаддддадддддддддд╢
ЁDescricao ЁDeleta os valores calculados de outros beneficios	      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>								  Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>								  Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGPEM160				                  	   				  Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function Gpm160Out()
Local lRet     := .T.
Local aArea    := GetArea()
Local cQuery
Local cNameDB
Local cDelet
Local cSqlName := InitSqlName( "RIQ" )
	
	//O banco DB2 nao aceita o nome da tabela apos o comando DELETE			 
  	cNameDB	:= Upper(TcGetDb())
  		
	cQuery := "DELETE " 
			
	If TcSrvType() != "AS/400" .And. !( cNameDB $ "INFORMIX" ) 
		cDelet 		:= "RIQ.D_E_L_E_T_ = ' ' " 
	ElseIf ( cNameDB $ "INFORMIX" )
   		cDelet	:= cSqlName +  ".D_E_L_E_T_ = ' ' "
   	Else		
		cDelet	:= "RIQ.@DELETED@ = ' ' "
	EndIf
              	   		
	If !( cNameDB $ "DB2_ORACLE_INFORMIX_POSTGRES" )
		cQuery += cSqlName
	EndIf
	
	//O Informix precisa do nome da tabela ao inves do Alias no comando DELETE
	If ( cNameDB $ "INFORMIX" )
		cQuery += " FROM " + cSqlName
	Else
		cQuery += " FROM " + cSqlName + " RIQ"
		cSqlName := "RIQ"
	EndIf

	cQuery += " WHERE " + cSqlName + ".RIQ_FILIAL = '" + cCanFil + "'"
	cQuery += " AND " + cSqlName + ".RIQ_MAT = '" + cCanMat + "'"
	cQuery += " AND " + cSqlName + ".RIQ_PROCES = '" + cCanPro + "'"
	cQuery += " AND " + cSqlName + ".RIQ_ROTEIR = '" + cCanRot + "'"
	cQuery += " AND " + cSqlName + ".RIQ_PERIOD = '" + cCanPer + "'"
	cQuery += " AND " + cSqlName + ".RIQ_NUMPAG = '" + cCanNpg + "'"
	cQuery += " AND " + cDelet 
	
	TcSqlExec( cQuery )
	RestArea( aArea )
Return( lRet )

/*
здддддддддбддддддддддбдддддбдддддддддддддддддддддддддддбддддбдддддддддд©
ЁFun┤┘o   ЁGpm160FutrЁAutorЁEquipe Inovacao RH       ЁDataЁ02/09/2013Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддддаддддадддддддддд╢
ЁDescricao ЁDeleta os valores futuros 			Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGPEM160				                  	   	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function Gpm160Futr( cFtFil, cFtMat, cFtPer, cFtNpg, cFtVer, lFtTod )
Local lRet     := .T.
Local aArea    := GetArea()
Local cQuery
Local cNameDB
Local cDelet
Local cSqlName := InitSqlName( "SRK" )

//O banco DB2 nao aceita o nome da tabela apos o comando DELETE			 
cNameDB	:= Upper(TcGetDb())
  		
cQuery := "DELETE " 
			
If TcSrvType() != "AS/400" .And. !( cNameDB $ "INFORMIX" ) 
	cDelet 		:= "SRK.D_E_L_E_T_ = ' ' " 
ElseIf ( cNameDB $ "INFORMIX" )
	cDelet	:= cSqlName +  ".D_E_L_E_T_ = ' ' "
Else		
	cDelet	:= "SRK.@DELETED@ = ' ' "
EndIf
              	   		
If !( cNameDB $ "DB2_ORACLE_INFORMIX_POSTGRES" )
	cQuery += cSqlName
EndIf
	
//O Informix precisa do nome da tabela ao inves do Alias no comando DELETE
If ( cNameDB $ "INFORMIX" )
	cQuery += " FROM " + cSqlName
Else
	cQuery += " FROM " + cSqlName + " SRK"
	cSqlName := "SRK"
EndIf

cQuery += " WHERE " + cSqlName + ".RK_FILIAL = '" + cCanFil + "'"
cQuery += " AND " + cSqlName + ".RK_MAT = '" + cCanMat + "'"
cQuery += " AND " + cSqlName + ".RK_PROCES = '" + cCanPro + "'"
cQuery += " AND " + cSqlName + ".RK_PERINI = '" + cCanPer + "'"
cQuery += " AND " + cSqlName + ".RK_NUMPAGO = '" + cCanNpg + "'"
If !lCanTod 
	cQuery += " AND " + cSqlName + ".RK_PD IN ('" + cCanVrb + "')"
EndIf
If !Empty(cNOTCanSRK) 
	cQuery += " AND " + cSqlName + ".RK_PD NOT IN ('" + cNOTCanSRK + "')"
EndIf
If lDataRef .And. lDtRefSRK
	cQuery += " AND " + cSqlName + ".RK_DTREF BETWEEN '" + dTOs(dDtRefDe) + "' AND '" + dTOs(dDtRefAte) + "' "
EndIf
cQuery += " AND " + cDelet 
	
TcSqlExec( cQuery )
RestArea( aArea )	
Return( lRet )

/*
здддддддддбддддддддддбдддддбдддддддддддддддддддддддддддбддддбдддддддддд©
ЁFun┤┘o   ЁGpm160RGBЁAutorЁEquipe Inovacao RH       ЁDataЁ03/09/2013Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддддаддддадддддддддд╢
ЁDescricao ЁDeleta os valores da tabela RGB 		   	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGPEM160				                  	   	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function Gpm160RGB(lInt)
Local lRet     := .T.
Local aArea    := GetArea()
Local cQuery
Local cNameDB
Local cDelet
Local cSqlName := InitSqlName( "RGB" )

Local cAlias1	:= GetNextAlias()
Local aAreaRGB	:= RGB->(GetArea())
Local aAreaSRC	:= SRC->(GetArea())
	
Default lInt := .F.

//O banco DB2 nao aceita o nome da tabela apos o comando DELETE			 
  		
cQuery := " SELECT RGB_FILIAL, RGB_MAT, RGB_PD, RGB_CC, RGB_SEMANA, RGB_SEQ, R_E_C_N_O_ NumRec "
cQuery += " FROM "+RetSqlName("RGB")+" 
cQuery += " WHERE " + cSqlName + ".RGB_FILIAL = '" + cCanFil + "'"
cQuery += " AND " + cSqlName + ".RGB_MAT = '" + cCanMat + "'"
cQuery += " AND " + cSqlName + ".RGB_PROCES = '" + cCanPro + "'"
cQuery += " AND " + cSqlName + ".RGB_ROTEIR = '" + cCanRot + "'"
cQuery += " AND " + cSqlName + ".RGB_PERIOD = '" + cCanPer + "'"
cQuery += " AND " + cSqlName + ".RGB_SEMANA = '" + cCanNpg + "'"

If lInt
	cQuery += " AND " + cSqlName + ".RGB_XIMPAP = 'I' "
EndIf

If cCanTip2 == "C" 
    cQuery += " AND " + cSqlName +".RGB_TIPO2 NOT IN ('I','G','E','V','F')"
ElseIf cCanTip2 <> "C"
    cQuery += " AND " + cSqlName +".RGB_TIPO2 = '" + cCanTip2 + "'"
EndIf

If !lCanTod 
	cQuery += " AND " + cSqlName +".RGB_PD IN ('" + cCanVrb + "')"
EndIf
If !Empty(cNOTCanRGB)
	cQuery += " AND " + cSqlName +".RGB_PD NOT IN ('" + cNOTCanRGB + "')"
EndIf
If lDataRef
	cQuery += " AND " + cSqlName + ".RGB_DTREF BETWEEN '" + dTOs(dDtRefDe) + "' AND '" + dTOs(dDtRefAte) + "' "
EndIf
cQuery += " AND " + cSqlName + ".D_E_L_E_T_ = ' '" 
	
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1)

While (cAlias1)->(!EOF())
	If (SRC->(DbSeek((cAlias1)->(RGB_FILIAL + RGB_MAT + RGB_PD + RGB_CC + RGB_SEMANA + RGB_SEQ))))
		RecLock("SRC",.F.)
		SRC->( dbDelete() )
		SRC->(MsUnLock())
	EndIf
	RGB->(DbGoTo((cAlias1)->NumRec))
	RecLock("RGB",.F.)
	RGB->( dbDelete() )
	RGB->(MsUnLock())
	(cAlias1)->(DbSkip())
EndDo

(cAlias1)->(DbCloseArea())
RestArea(aAreaRGB)
RestArea(aAreaSRC)
Return( lRet )

/*
здддддддддбддддддддддбдддддбдддддддддддддддддддддддддддбддддбдддддддддд©
ЁFun┤┘o   ЁGpm160SRCЁAutorЁEquipe Inovacao RH       ЁDataЁ03/09/2013Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддддаддддадддддддддд╢
ЁDescricao ЁDeleta os valores da tabela SRC 		   	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGPEM160				                  	   	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function Gpm160SRC()
Local lRet     := .T.
Local aArea    := GetArea()
Local cQuery
Local cNameDB
Local cDelet
Local cSqlName := InitSqlName( "SRC" )


//O banco DB2 nao aceita o nome da tabela apos o comando DELETE			 
cNameDB	:= Upper(TcGetDb())
  		
cQuery := "DELETE " 
			
If TcSrvType() != "AS/400" .And. !( cNameDB $ "INFORMIX" ) 
	cDelet 		:= "SRC.D_E_L_E_T_ = ' ' " 
ElseIf ( cNameDB $ "INFORMIX" )
	cDelet	:= cSqlName +  ".D_E_L_E_T_ = ' ' "
Else		
	cDelet	:= "SRC.@DELETED@ = ' ' "
EndIf
              	   		
If !( cNameDB $ "DB2_ORACLE_INFORMIX_POSTGRES" )
	cQuery += cSqlName
EndIf
	
//O Informix precisa do nome da tabela ao inves do Alias no comando DELETE
If ( cNameDB $ "INFORMIX" )
	cQuery += " FROM " + cSqlName
Else
	cQuery += " FROM " + cSqlName + " SRC"
	cSqlName := "SRC"
EndIf

cQuery += " WHERE " + cSqlName + ".RC_FILIAL = '" + cCanFil + "'"
cQuery += " AND " + cSqlName + ".RC_MAT = '" + cCanMat + "'"
cQuery += " AND " + cSqlName + ".RC_PROCES = '" + cCanPro + "'"
cQuery += " AND " + cSqlName + ".RC_ROTEIR = '" + cCanRot + "'" 
cQuery += " AND " + cSqlName + ".RC_PERIODO = '" + cCanPer + "'"
cQuery += " AND " + cSqlName + ".RC_SEMANA = '" + cCanNpg + "'"

If cCanTip2 == "C" 
    cQuery += " AND " + cSqlName + ".RC_TIPO2 NOT IN ('I','G','E','V','F')"
ElseIf cCanTip2 <> "C"
    cQuery += " AND " + cSqlName + ".RC_TIPO2 = '" + cCanTip2 + "'"
EndIf

If !lCanTod 
	cQuery += " AND " + cSqlName + ".RC_PD IN ('" + cCanVrb + "')"
EndIf
If !Empty(cNOTCanSRC)
	cQuery += " AND " + cSqlName +".RC_PD NOT IN ('" + cNOTCanSRC + "')"
EndIf
cQuery += " AND " + cDelet 
	
TcSqlExec( cQuery )
RestArea( aArea )	
Return( lRet )
