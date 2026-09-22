#include "rwmake.ch"
#include "totvs.ch"
#xtranslate NToS([<n,...>])=>LTrim(Str([<n>]))
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa  ³ SRFDORIMP                              º Data ³ 15/09/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Autor     ³ Microsiga                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao ³ Rotina para a importação da Tabela SRF   template CSV para º±±
±±º           ³ o ERP Protheus.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe   ³ SRFDORIMP()                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno   ³ nil                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso       ³ Rede Dor São Luiz                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function SRFDORIMP()
    Local cSvFilAnt:=cFilAnt
	Local lExact:=Set(_SET_EXACT,"ON")
	IMPSRF()
	Set(_SET_EXACT,if(lExact,"ON","OFF"))
	cFilAnt:=cSvFilAnt
Return(NIL)

Static Function IMPSRF()

Local aRet		:= {}
Local aArea		:= GetArea()
Local cArq      := ""
// ORIGRINAL
Local cOrigem	:= UPPER(GetSrvProfString("ROOTPATH",""))+"\M&A\IMPORTAR\"
Local cDestino	:= UPPER(GetSrvProfString("ROOTPATH",""))+"\M&A\IMPORTADO\"
// TESTES
//Local cOrigem	:= GETMV("MV_PATH")+"IMPORTAR\"
//Local cDestino	:= GETMV("MV_PATH")+"IMPORTADO\"

Local lConv     := .F.

Private aErros  := {}
Private aLog    := {}

Public cArquivo := Space(150)
Public lOk      :=.F.
Public bOk      := { || If(u_ValidaDir(cArquivo), (lOk:=.T.,oDlg:End()) ,) }
Public bCancel  := { || lOk:=.F.,oDlg:End() }
Public lEnd     := .F.

Define MsDialog oDlg Title "Importação dias de Direito" From 08,15 To 18,080 Of GetWndDefault()
      
@ 050,028 Say 	  "Diretorio:" 	Size 060,015 Of oDlg Pixel
@ 050,082 MsGet   cArquivo 		Size 122,008 Of oDlg Pixel
@ 050,210 Button  "…"			Size 010,010 Action Eval({|| cArquivo:=u_SelectFile() }) Of oDlg Pixel

Activate MsDialog oDlg Centered On Init (EnchoiceBar(oDlg,bOk,bCancel))


If lOk
	oProcess:=MsNewProcess():New( { |lEnd| lConv:=u_IpTabSRF(cArquivo, @lEnd)}, "Importação das Progr. Ferias", "Processando arquivo das Progr. Ferias", .T. )
	oProcess:Activate()	
	If lConv
		cArq := SUBSTR(cArquivo,RAT("\", cArquivo)+1,LEN(cArquivo))
		// mover o arquivo lido da pasta IMPORTAR para a pasra IMPORTADO
		If FRENAME ( cOrigem+cArq , cDestino+cArq ) == -1
			MsgInfo("Não foi possível mover o arquivo da pasta IMPORTAR para a pasta IMPORTADO")
		EndIf
		// cria arquivo de LOG
		u_CRIARLOG(aLog, SUBSTR(cArq,1,LEN(cArq)-4), 2)
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
±±º Programa  ³ IPTABSRF                               º Data ³ 07/07/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Autor     ³ Adriano Sato                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao ³ Rotina para a importação dos Clientes to template CSV para º±±
±±º           ³ o ERP Protheus.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe   ³ IPTABSRF (lEnd, oProcess, cArq)                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno   ³ nil                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso       ³ Rede Dor São Luiz                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function IpTabSRF(cArq)

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

Local W

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
		
		If u_VERTEMPL(aCampos[1], "SRF", "RF")
			Return .F.
		EndIf
				
		nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RF_FILIAL" })
		nPosMat := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RF_MAT" })
		nPosDba := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RF_DATABAS" })
	EndIf
	AADD( aErros, cLinha )
	cLinha := ""
	Ft_FSkip()
	nLinTit--
EndDo

oProcess:SetRegua1( ntot )
oProcess:SetRegua2( int(ntot/100) )

// Processa os dados do template

Do While !FT_FEOF()
	oProcess:IncRegua1("Registros processados : " + ALLTRIM(STR(nCont)) )
	cLinha := FT_FREADLN()

	If lEnd
		MsgInfo("Importação cancelada!","Fim")
		Return .F.
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
	
	If u_VldChave("SRF", aCampos, aDados)
		For W:=1 To LEN(aCampos)
			
			/*
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Rotina utilizada para carregar os valores do campo da X3. ³
			//³ cCampo    := ALLTRIM(SX3->X3_CAMPO)                       ³
			//³ lObrigat  := X3OBRIGAT(SX3->X3_CAMPO)                     ³
			//³ cTipo     := SX3->X3_TIPO                                 ³
			//³ nTamanho  := SX3->X3_TAMANHO                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			*/
			u_ConfCpo(aCampos[W], W)
			
			// VERIFICAR SE O CAMPOS OBROGATORIO ESTA PREENCHIDO
			If lObrigat
				If EMPTY(aDados[W]) .OR. ALLTRIM(aDados[W]) == ""
					cErro := cLinha+";CAMPO OBRIGATORIO VAZIO - "+cCampo
					AADD( aErros, cErro )					
					
					AADD(aLog,{"RF_MAT"     ,aDados[nPosMat] ,Nil})
					AADD(aLog,{"ERRO" 	   ,"CAMPO OBRIGATORIO VAZIO - "+cCampo ,Nil})
					
					lGrava := .F.
					LOOP
				EndIf
			EndIf
			
			// VERIFICAR SE O TAMANHO DO CAMPO É MAIOR
			If u_VldTamCpo(cTipo, aDados[W], nTamanho, nDecimal) 
			   iF cCampo = "RF_VFGDTAT"
			      Alert("aqui")
			   endif
				cErro := cLinha+";CONTEUDO DO CAMPO MAIOR QUE O ESPERADO - "+cCampo
				AADD( aErros, cErro )
				
				AADD(aLog,{"RF_MAT"     ,aDados[nPosMat] ,Nil})
				AADD(aLog,{"ERRO" 	   ,"CONTEUDO DO CAMPO MAIOR QUE O ESPERADO - "+cCampo ,Nil})
				
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
			
			// VALIDAÇÃO DOS CAMPOS OBRIGATORIOS
			If lObrigat
				If aCampos[W] == "RF_DATABAS"	// GP050VLDDT()
					// GP050VLDDT() - FONTE - GPEA050.PRX
					// Validacao da data base de ferias >= a admissao.
					If aDados[W] < POSICIONE("SRA",1,xFilial("SRA")+aDados[nPosMat],"RA_ADMISSA")
						cErro := cLinha+";DATA BASE MENOR QUE A DATA DE ADMISSAO - "+cCampo+" = "+DTOS(aDados[W])
						AADD( aErros, cErro )
						
						AADD(aLog,{"RF_MAT"     ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"DATA BASE MENOR QUE A DATA DE ADMISSAO - "+cCampo+" = "+DTOS(aDados[W]) ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
			EndIf
		Next W
    Else
		cErro := cLinha+";REGISTRO JA EXISTENTE."
		AADD( aErros, cErro )
		
		AADD(aLog,{"RF_MAT"     ,aDados[nPosMat] ,Nil})
		AADD(aLog,{"ERRO" 	   ,"REGISTRO JA EXISTENTE." ,Nil})
		
		lGrava := .F.
	EndIf
	
    If lGrava
		u_GRVDADOS("SRF", aCampos, aDados, nPosFil)
	Else
		lGrava := .T.
	EndIf
	
	FT_FSKIP()
	nCont++	
EndDo

FT_FUSE()

Aviso("Finalizado","Leitura do arquivo realizado com sucesso",{"Fechar"})

RestArea(aArea)

Return .T.
