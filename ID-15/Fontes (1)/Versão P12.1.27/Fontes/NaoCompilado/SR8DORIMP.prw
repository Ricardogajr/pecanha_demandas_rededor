#include "rwmake.ch"
#include "totvs.ch"
#xtranslate NToS([<n,...>])=>LTrim(Str([<n>]))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±?Programa  ?SR8DORIMP                              ?Data ?13/09/2015 º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Autor     ?Microsiga                                                  º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Descricao ?Rotina para a importação dos Controles de Afastaemtnos do  º±?
±±?          ?template CSV para o ERP Protheus.                          º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Sintaxe   ?SR8DORIMP()                                                 º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Retorno   ?nil                                                        º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Uso       ?Rede Dor São Luiz                                          º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function SR8DORIMP() 
	Local cSvFilAnt:=cFilAnt
	Local lExact:=Set(_SET_EXACT,"ON")
	IMPRTSR8()
	Set(_SET_EXACT,if(lExact,"ON","OFF"))
	cFilAnt:=cSvFilAnt
Return(NIL)

Static Function IMPRTSR8()

Local aRet		:= {}
Local aArea		:= GetArea()
Local cArq      := ""
// ORIGRINAL
//Local cOrigem	:= UPPER(GetSrvProfString("ROOTPATH",""))+"\MIGRACAO\IMPORTAR\"
//Local cDestino	:= UPPER(GetSrvProfString("ROOTPATH",""))+"\MIGRACAO\IMPORTADO\"

Local cOrigem	:= "C:\M&A\IMPORTAR\"
Local cDestino	:= "C:\M&A\IMPORTADO\"

Local lConv     := .F.

Private aErros  := {}
Private aLog    := {}

Private cArquivo := Space(150)
Private lOk      :=.F.
Private bOk      := { || If(u_ValidaDir(cArquivo), (lOk:=.T.,oDlg:End()) ,) }
Private bCancel  := { || lOk:=.F.,oDlg:End() }
Private lEnd     := .F.

Define MsDialog oDlg Title "Importação dos Controles de Afastamentos" From 08,15 To 18,080 Of GetWndDefault()
      
@ 050,028  Say 	"Selecione o Arquivo:" 	Size 060,015 Of oDlg Pixel
@ 050,082  MsGet 	cArquivo 		    Size 122,008 Of oDlg Pixel
@ 050,210  Button "?"			        Size 010,010 Action Eval({|| cArquivo:=u_SelectFile() }) Of oDlg Pixel

Activate MsDialog oDlg Centered On Init (EnchoiceBar(oDlg,bOk,bCancel))

If lOk
	oProcess:=MsNewProcess():New( { |lEnd| lConv:=u_ImpSr8CSV(cArquivo, @lEnd)}, "Importação dos Controles de Afastamentos", "Processando arquivo dos Controles de Afastamentos", .T. )
	oProcess:Activate()	
	
	If lConv
		cArq := SUBSTR(cArquivo,RAT("\", cArquivo)+1,LEN(cArquivo))
		// mover o arquivo lido da pasta IMPORTAR para a pasra IMPORTADO
		If FRENAME ( cOrigem+cArq , cDestino+cArq ) == -1
			MsgInfo("Não foi possível mover o arquivo da pasta IMPORTAR para a pasta IMPORTADO")
		EndIf
		// cria arquivo de LOG
		u_CRIARLOG(aLog, SUBSTR(cArq,1,LEN(cArq)-4), 3)
		// gera arquivo excel 
		u_GeraExcel(aErros, SUBSTR(cArq,1,LEN(cArq)-4))
	EndIf
EndIf

RestArea(aArea)

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±?Programa  ?IMPSR8CSV                              ?Data ?13/09/2015 º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Autor     ?Microsiga                                                  º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Descricao ?Rotina para a importação dos Controles de Afastaemtnos do  º±?
±±?          ?template CSV para o ERP Protheus.                          º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Sintaxe   ?IMPSR8CSV(cArq, lEnd)                                      º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Retorno   ?Logico                                                     º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Uso       ?Rede Dor São Luiz                                          º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function ImpSr8CSV(cArq, lEnd)

Local aArea		:= GetArea()
Local aTables	:= {}
Local aVetor    := {}
Local aDados    := {}

Local cLinha
Local lGrava    := .T.
Local nTot      := 0
Local nCont     := 1
Local nAtual    := 0
Local nTimeIni  := 0
Local nLinTit   := 2  // Total de linhas do Cabeçalho

Local aCampos 	:= {} 
Local aCoors 	:= MsAdvSize()

Local lSRAFound

Local W

Local lRet := .T. //Thais Paiva - Compatibiliza??o P27

Private lMsErroAuto := .F.

Private cCampo   := ""
Private lObrigat := .T.
Private cTipo    := ""
Private nTamanho := 0
Private nDecimal := 0
Private cValida  := ""
Private aValida  := {}

If (nHandle := FT_FUse(AllTrim(cArq)))== -1
	Help(" ",1,"NOFILEIMPOR")
	RestInter()
	Return .F.
EndIf       

nTot := FT_FLASTREC()

FT_FGOTOP()

// Tratamento do cabeçalho
While nLinTit > 0 .AND. !Ft_FEof()
   cLinha := FT_FREADLN()
   If LEN(cLinha) == 1023
		FT_FSKIP()
		cConLinha := FT_FREADLN()
		While LEN(cConLinha) == 1023
			cLinha += cConLinha
			FT_FSKIP()
			cConLinha := FT_FREADLN()
		EndDo
		cLinha += cConLinha
	EndIf
	If nLinTit == 1
		aCampos := SEPARA(UPPER(cLinha),";",.T.)
		cLinha += ";DESC. ERRO"
		
		If u_VLDTEMPLATE(aCampos[1], "SR8", "R8")
			Return .F.
		EndIf
		
		nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "R8_FILIAL" })
		nPosMat := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "R8_MAT" })
		nPosTip := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "R8_TIPO" })
	EndIf
	AADD( aErros, cLinha )
	cLinha := ""
	Ft_FSkip()
	nLinTit--
EndDo
                     
oProcess:SetRegua1( ntot )
oProcess:SetRegua2( int(ntot/100) )

// Processa os dados do template
BEGIN TRANSACTION
Do While !FT_FEOF()
	oProcess:IncRegua1("Registros processados : " + ALLTRIM(STR(nCont)) )
	cLinha := FT_FREADLN()
	
	If lEnd
		MsgInfo("Importação cancelada!","Fim")
		//DISARMTRANSACTION() Thais Paiva - Compatibiliza??o P27
		//Return .F. Thais Paiva - Compatibiliza??o P27
		lRet := .F. //Thais Paiva - Compatibiliza??o P27
		Exit //Thais Paiva - Compatibiliza??o P27
	Endif
	
	If LEN(cLinha) == 1023
		FT_FSKIP()
		cConLinha := FT_FREADLN()
		While LEN(cConLinha) == 1023
			cLinha += cConLinha
			FT_FSKIP()
			cConLinha := FT_FREADLN()
		EndDo
		cLinha += cConLinha
	EndIf

	nAtual++
	If (nAtual % 100) = 1
		nTimeIni := Seconds()
	EndIf
	If (nAtual % 100) = 0
		oProcess:IncRegua2( "Tempo Restante - (" + U_EstTime(ntot,nAtual,(nAtual-100),nTimeIni) + ")" )
	EndIf
	
	//aDados := STRTOKARR(cLinha,";")   // A função SEPARA e a função STRTOKARR, converte uma string em um array, o SEPARA converte os espaços em branco 
	aDados := SEPARA(UPPER(cLinha),";",.T.)

	SRA->(dbSetOrder(RetOrder("SRA","RA_FILIAL+RA_MAT")))
	
	lSRAFound:=SRA->(dbSeek(fFilFunc("SRA")+aDados[nPosMat],.F.))
	
	If lSRAFound .and. u_VldChave("SR8", aCampos, aDados)
		For W:=1 To LEN(aCampos)
			
			/*
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//?Rotina utilizada para carregar os valores do campo da X3. ?
			//?cCampo    := ALLTRIM(SX3->X3_CAMPO)                       ?
			//?lObrigat  := X3OBRIGAT(SX3->X3_CAMPO)                     ?
			//?cTipo     := SX3->X3_TIPO                                 ?
			//?nTamanho  := SX3->X3_TAMANHO                              ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			*/
			u_ConfCpo(aCampos[W], W)
			
			// VERIFICAR SE O CAMPOS OBROGATORIO ESTA PREENCHIDO
			If lObrigat
				If .not.(aCampos[W]=="R8_TIPOAFA")
					If EMPTY(aDados[W])
						//Nao Validar Retorno de Afastamento em Branco
						if .not.(aCampos[W]=="R8_DATAFIM")
							cErro := cLinha+";CAMPO OBRIGATORIO VAZIO - "+cCampo
							AADD( aErros, cErro )					
							
							AADD(aLog,{"R8_MAT"     ,aDados[nPosMat] ,Nil})
							AADD(aLog,{"R8_TIPO"    ,aDados[nPosTip] ,Nil})
							AADD(aLog,{"ERRO" 	    ,"CAMPO OBRIGATORIO VAZIO - "+cCampo ,Nil})
							
							lGrava := .F.
							LOOP
						Endif
					EndIf
				EndIf
			EndIf
			
			// VERIFICAR SE O TAMANHO DO CAMPO ?MAIOR
			If u_VldTamCpo(cTipo, aDados[W], nTamanho, nDecimal)
				cErro := cLinha+";CONTEUDO DO CAMPO MAIOR QUE O ESPERADO - "+cCampo
				AADD( aErros, cErro )
				
				AADD(aLog,{"R8_MAT"     ,aDados[nPosMat] ,Nil})
				AADD(aLog,{"R8_TIPO"    ,aDados[nPosTip] ,Nil})
				AADD(aLog,{"ERRO" 		,"CONTEUDO DO CAMPO MAIOR QUE O ESPERADO - "+cCampo ,Nil})
				
				lGrava := .F.
				LOOP
			EndIf
			
			// CONVERTER OS DADOS PARA INSERÇÃO NO BANCO DE DADOS
			Do Case
				Case cTipo == 'D' 
					If AT("/", aDados[W]) > 0
						aDados[W] := IIf(EMPTY(aDados[W]),CTOD("  /  /    "),CTOD(aDados[W]))
					Else
						aDados[W] := IIf(EMPTY(aDados[W]),CTOD("  /  /    "),STOD(aDados[W]))
					EndIf
				Case cTipo == 'N' 
					aDados[W] := IIf(EMPTY(aDados[W]),0,VAL(STRTRAN(aDados[W],",",".")))
				Case cTipo == 'M' 
					aDados[W] := IIf(EMPTY(aDados[W]),"",MSMM(aDados[W]))
				/*
				Otherwise
					If ALLTRIM(aDados[X]) == ""
						aDados[X] == " "
					EndIF
				*/
			EndCase
			
			// VALIDAÇÃO DO CAMPO OBRIGATORIOS
			If lObrigat
				If aCampos[W] == "R8_MAT"	// NaoVazio() .And. EXISTCHAV("SRA") .And. Val(M->R8_MAT) > 0
					If EMPTY(aDados[W])	// !NaoVazio(aDados[W])
						
						cErro := cLinha+";O CAMPO "+aCampos[W]+" ESTA VAZIO."
						AADD( aErros, cErro )
						
						AADD(aLog,{"R8_MAT"    	,aDados[nPosMat] ,Nil})
						AADD(aLog,{"R8_TIPO"   	,aDados[nPosTip] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CAMPO "+aCampos[W]+" ESTA VAZIO." ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
					If EMPTY(POSICIONE("SRA",1,xFilial("SRA")+aDados[W],"RA_MAT")) // !EXISTCHAV("SRA", aDados[W])
						cErro := cLinha+";MATRICULA NAO EXISTENTE - "+cCampo+" = "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"R8_MAT"    	,aDados[nPosMat] ,Nil})
						AADD(aLog,{"R8_TIPO"   	,aDados[nPosTip] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"MATRICULA NAO EXISTENTE - "+cCampo+" = "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
					If Val(aDados[W]) <= 0
						cErro := cLinha+";MATRICULA INVALIDA - "+cCampo+" = "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"R8_MAT"    	,aDados[nPosMat] ,Nil})
						AADD(aLog,{"R8_TIPO"   	,aDados[nPosTip] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"MATRICULA INVALIDA - "+cCampo+" = "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				/*
				If aCampos[W] == "R8_DATA"	// NaoVazio()
					If EMPTY(aDados[W])	// !NaoVazio(aDados[W])
						cErro := cLinha+";O CAMPO "+aCampos[W]+" ESTA VAZIO."
						AADD( aErros, cErro )
						
						AADD(aLog,{"R8_MAT"    	,aDados[nPosMat] ,Nil})
						AADD(aLog,{"R8_TIPO"   	,aDados[nPosTip] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CAMPO "+aCampos[W]+" ESTA VAZIO." ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				*/
				If aCampos[W] == "R8_TIPO"	//NaoVazio() .And. EXISTCPO("SX5","30"+M->R8_TIPO) .And. Pertence("FOPQRXYZW18VB67D") .And. A240NumDias()
					// A240NumDias() - FONTE - GPEA240.PRX
					// Calcula a duracao do afastamento,os dias a serem pagos pela empresa
					If EMPTY(aDados[W])	// !NaoVazio(aDados[W])
						cErro := cLinha+";O CAMPO "+aCampos[W]+" ESTA VAZIO."
						AADD( aErros, cErro )
						
						AADD(aLog,{"R8_MAT"    	,aDados[nPosMat] ,Nil})
						AADD(aLog,{"R8_TIPO"   	,aDados[nPosTip] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CAMPO "+aCampos[W]+" ESTA VAZIO." ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
					If EMPTY(POSICIONE("SX5",1,xFilial("SX5")+"30"+PAD(aDados[W],6),"X5_CHAVE")) // !EXISTCPO("SX5","30"+aDados[W])
						cErro := cLinha+";O TIPO NAO EXISTE."+cCampo+" = "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"R8_MAT"    	,aDados[nPosMat] ,Nil})
						AADD(aLog,{"R8_TIPO"   	,aDados[nPosTip] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O TIPO NAO EXISTE."+cCampo+" = "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
					If !(aDados[W] $ "FOPQRSXYZW18VB67D")
						cErro := cLinha+";O CONTEUDO DO CAMPO "+aCampos[W]+" NAO PERTENCE AO RANGE 'FOPQRSXYZW18VB67D' - "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"R8_MAT"    	,aDados[nPosMat] ,Nil})
						AADD(aLog,{"R8_TIPO"   	,aDados[nPosTip] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CONTEUDO DO CAMPO "+aCampos[W]+" NAO PERTENCE AO RANGE 'FOPQRSXYZW18VB67D' - "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				/*
				If aCampos[W] == "R8_DATAINI"	// NaoVazio() .and. A240NumDias()
					If EMPTY(aDados[W])	// !NaoVazio(aDados[W])
						cErro := cLinha+";O CAMPO "+aCampos[W]+" ESTA VAZIO."
						AADD( aErros, cErro )
						
						AADD(aLog,{"R8_MAT"    	,aDados[nPosMat] ,Nil})
						AADD(aLog,{"R8_TIPO"   	,aDados[nPosTip] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CAMPO "+aCampos[W]+" ESTA VAZIO." ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				*/
				// retirada a validação deste campo pois o usuario nos informou que este campo não ?utilizado.
				// [16:41] Humberto Fernandes: em relação a SR8, precisamos desconsiderar o campo SR8_TIPOAFA
				// [16:41] Humberto Fernandes: ele ?obrigatório, mas não ?usado		
				/*
				If aCampos[W] == "R8_TIPOAFA"	// NaoVazio() .and. ExistCpo("RCM")
					If EMPTY(aDados[W])	// !NaoVazio(aDados[W])
						cErro := cLinha+";O CAMPO "+aCampos[W]+" ESTA VAZIO."
						AADD( aErros, cErro )
						
						AADD(aLog,{"R8_MAT"    	,aDados[nPosMat] ,Nil})
						AADD(aLog,{"R8_TIPO"   	,aDados[nPosTip] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CAMPO "+aCampos[W]+" ESTA VAZIO." ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
					If EMPTY(POSICIONE("RCM",1,xFilial("RCM")+aDados[W],"RCM_TIPO")) // !ExistCpo("RCM", aDados[W])
						cErro := cLinha+";TIPO DE AFASTAMENTO NAO EXISTENTE - "+cCampo+" = "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"R8_MAT"    	,aDados[nPosMat] ,Nil})
						AADD(aLog,{"R8_TIPO"   	,aDados[nPosTip] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"TIPO DE AFASTAMENTO NAO EXISTENTE - "+cCampo+" = "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				*/
			EndIf
			
		Next W
    Else
	
		if .not.(lSRAFound)
			cErro := cLinha+";FUNCIONARIO NAO CADASTRADO."
			AADD( aErros, cErro )
			
			AADD(aLog,{"R8_MAT"     ,aDados[nPosMat] ,Nil})
			AADD(aLog,{"R8_TIPO"    ,aDados[nPosTip] ,Nil})
			AADD(aLog,{"ERRO" 	   ,"FUNCIONARIO NAO CADASTRADO." ,Nil})

		else

			cErro := cLinha+";REGISTRO JA EXISTENTE."
			AADD( aErros, cErro )
			
			AADD(aLog,{"R8_MAT"    	,aDados[nPosMat] ,Nil})
			AADD(aLog,{"R8_TIPO"   	,aDados[nPosTip] ,Nil})
			AADD(aLog,{"ERRO" 	   ,"REGISTRO JA EXISTENTE." ,Nil})

		endif
			
		lGrava := .F.
	EndIf
	
	If lGrava
		u_GRVDADOS("SR8", aCampos, aDados, nPosFil)
	Else
		lGrava := .T.
	EndIf
	
	FT_FSKIP()
	nCont++	
EndDo
END TRANSACTION

If lRet //Thais Paiva - Compatibiliza??o P27
	FT_FUSE()

	Aviso("Finalizado","Leitura do arquivo realizado com sucesso",{"Fechar"})
EndIf //Thais Paiva - Compatibiliza??o P27
RestArea(aArea)

Return lRet //.T. Thais Paiva - Compatibiliza??o P27
