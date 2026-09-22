#include "totvs.ch"
#xtranslate NToS([<n,...>])=>LTrim(Str([<n>]))

//--------------------------------------------------------------------------------------------------------------
    /*/
        Programa:IMPRTSRA.PRW
        Funcao:IMPRTSRA
        Data:12/09/2015 (v1)
        Data:18/07/2016 (v2)
        Autor: (v1) Sato 
        Autor: (v2) Marinaldo de Jesus (marinaldo.jesus@totvspartners.com.br)
        Descricao:Rotina para a importação dos Funcionarios do template CSV para o ERP Protheus.
    /*/
//--------------------------------------------------------------------------------------------------------------
User Function SRADORIMP()
	Local cSvFilAnt:=cFilAnt
	Local lExact:=Set(_SET_EXACT,"ON")
	IMPRTSRA()
	Set(_SET_EXACT,if(lExact,"ON","OFF"))
	cFilAnt:=cSvFilAnt
Return(NIL)

Static Function IMPRTSRA()

Local aRet		:= {}
Local aArea		:= GetArea()
Local cArq      := ""
//Local cOrigem	    := UPPER(GetSrvProfString("ROOTPATH",""))+"\M&A\IMPORTAR\"
//Local cDestino	:= UPPER(GetSrvProfString("ROOTPATH",""))+"\M&A\IMPORTADO\"

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

Define MsDialog oDlg Title "Importação de Funcionários" From 08,15 To 18,080 Of GetWndDefault()
      
@ 050,028  Say 	"Selecione o Arquivo:" 	Size 060,015 Of oDlg Pixel
@ 050,082  MsGet 	cArquivo 		    Size 122,008 Of oDlg Pixel
@ 050,210  Button "…"			        Size 010,010 Action Eval({|| cArquivo:=u_SelectFile() }) Of oDlg Pixel

Activate MsDialog oDlg Centered On Init (EnchoiceBar(oDlg,bOk,bCancel))

If lOk
	oProcess:=MsNewProcess():New( { |lEnd| lConv:=u_ImpSraCSV(cArquivo, @lEnd)}, "Importação dos Funcionarios", "Processando arquivo dos Funcionarios", .T. )
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
±±º Programa  ³ IMPSRACSV                              º Data ³ 12/09/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Autor     ³ Microsiga                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao ³ Rotina para a importação dos Funcionarios do template CSV  º±±
±±º           ³ para o ERP Protheus.                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe   ³ IMPSRACSV(cArq, lEnd)                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno   ³ Logico                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso       ³ Rede Dor São Luiz                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function ImpSraCSV(cArq, lEnd)

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
		
		If u_VERTEMPL(aCampos[1], "SRA", "RA")
			Return .F.
		EndIf
		
		nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RA_FILIAL" })
		nPosMat := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RA_MAT" })
		nPosNom := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RA_NOME" })
		nPosNas := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RA_NASC" })
		nPosAdm := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RA_ADMISSA" })
		nPosCtd := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RA_CTDEPSA" })
		nPosNat := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RA_NATURAL" })
	EndIf
	AADD( aErros, cLinha )
	cLinha := ""
	Ft_FSkip()
	nLinTit--
EndDo

oProcess:SetRegua1( nTot )
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
	
	If u_VldChave("SRA", aCampos, aDados)
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
					cErro := cLinha+";CAMPO OBRIGATORIO VAZIO - "+aCampos[W]
					AADD( aErros, cErro )					
					
					AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
					AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
					AADD(aLog,{"ERRO" 	   ,"CAMPO OBRIGATORIO VAZIO - "+aCampos[W] ,Nil})
					
					lGrava := .F.
					LOOP
				EndIf
			EndIf
			
			// VERIFICAR SE O TAMANHO DO CAMPO É MAIOR
			If u_VldTamCpo(cTipo, ALLTRIM(aDados[W]), nTamanho, nDecimal)
				cErro := cLinha+";CONTEUDO DO CAMPO MAIOR QUE O ESPERADO - "+aCampos[W]
				AADD( aErros, cErro )
				
				AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
				AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
				AADD(aLog,{"ERRO" 	   ,"CONTEUDO DO CAMPO MAIOR QUE O ESPERADO - "+aCampos[W] ,Nil})
				
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
				If aCampos[W] == "RA_MAT"   // NaoVazio() .And. EXISTCHAV("SRA",M->RA_MAT) .And. Val(M->RA_MAT) > 0 .And. FreeForUse("SRA",M->RA_MAT)
					If EMPTY(aDados[W])	// !NaoVazio(aDados[W])
						cErro := cLinha+";O CAMPO "+aCampos[W]+" ESTA VAZIO."
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CAMPO "+aCampos[W]+" ESTA VAZIO." ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
					If !EXISTCHAV("SRA", aDados[W])
						cErro := cLinha+";MATRICULA NAO EXISTENTE - "+aCampos[W]+" = "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"MATRICULA NAO EXISTENTE - "+aCampos[W]+" = "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
					If Val(aDados[W]) <= 0
						cErro := cLinha+";MATRICULA INVALIDA - "+aCampos[W]+" = "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"MATRICULA INVALIDA - "+aCampos[W]+" = "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
					
					// FreeForUse("SRA",M->RA_MAT)
					// A função não será realizada pois a mesma retorna uma tela de aviso que fica aguardando uma confirmação do usuário, 
					// interrompendo o processo de importação dos dados.
					
				EndIf
				If aCampos[W] == "RA_CC"  // CTB105CC() .And. FHIST()
					// CTB105CC() - FONTE - CTB105.PRW
					If EMPTY(POSICIONE("CTT",1,xFilial("CTT")+aDados[W],"CTT_CUSTO")) // !CTB105CC(aDados[W])
						cErro := cLinha+";CENTRO DE CUSTO INVALIDA - "+aCampos[W]+" = "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"CENTRO DE CUSTO INVALIDA - "+aCampos[W]+" = "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
					
					// FHIST()
					// A função não será executada pois a mesma retorna uma tela de aviso que fica aguardando uma confirmação do usuário, 
					// interrompendo o processo de importação dos dados.
					
				EndIf
				If aCampos[W] == "RA_NOME" 	// Texto() .And. FHIST()
					If !Texto(ALLTRIM(aDados[W]))
						cErro := cLinha+";CONTEUDO INVALID0 - "+aCampos[W]+" = "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"CONTEUDO INVALID0 - "+aCampos[W]+" = "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				If aCampos[W] == "RA_NUMCP"	// NaoVazio() .AND. FHIST()
					IF EMPTY(aDados[W])	// !NaoVazio(aDados[W])
						cErro := cLinha+";O CAMPO "+aCampos[W]+" ESTA VAZIO."
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CAMPO "+aCampos[W]+" ESTA VAZIO." ,Nil})
					EndIf
				EndIf		
				If aCampos[W] == "RA_SERCP"	// NaoVazio() .AND. FHIST()
					IF EMPTY(aDados[W])	// !NaoVazio(aDados[W])
						cErro := cLinha+";O CAMPO "+aCampos[W]+" ESTA VAZIO."
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CAMPO "+aCampos[W]+" ESTA VAZIO." ,Nil})
					EndIf
				EndIf
				If aCampos[W] == "RA_SEXO" 	// Pertence("MF")
					IF aDados[W] <> "M" .AND. aDados[W] <> "F"
						cErro := cLinha+";O CONTEUDO DO CAMPO "+aCampos[W]+" NAO PERTENCE AO RANGE 'MF' - "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CONTEUDO DO CAMPO "+aCampos[W]+" NAO PERTENCE AO RANGE 'MF' - "+aDados[W] ,Nil})
					EndIf
				EndIf
				If aCampos[W] == "RA_ESTCIVI"	// EXISTCPO("SX5","33"+M->RA_ESTCIVI) .AND. FHIST()
					If EMPTY(POSICIONE("SX5",1,xFilial("SX5")+"33"+PAD(aDados[W],6),"X5_CHAVE")) // !EXISTCPO("SX5","33"+aDados[W])
						cErro := cLinha+";O ESTADO CIVIL NAO EXISTE. "+aCampos[W]+" = "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O ESTADO CIVIL NAO EXISTE. "+aCampos[W]+" = "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				If aCampos[W] == "RA_NATURAL"	// If(M->RA_NATURAL="EX" ,.T.,EXISTCPO("SX5","12"+M->RA_NATURAL))
					If aDados[W] <> "EX"
						If EMPTY(POSICIONE("SX5",1,xFilial("SX5")+"12"+PAD(aDados[W],6),"X5_CHAVE")) // !EXISTCPO("SX5","12"+aDados[W])
							cErro := cLinha+";NATURALIDADE NAO EXISTE. "+aCampos[W]+" = "+aDados[W]
							AADD( aErros, cErro )
							
							AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
							AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
							AADD(aLog,{"ERRO" 	   ,"DADO NAO EXISTE."+aCampos[W]+" = "+aDados[W] ,Nil})
							
							lGrava := .F.
							LOOP
						EndIf
					EndIf
				EndIf 
				If aCampos[W] == "RA_NACIONA"	// If(M->RA_NATURAL="EX".And.M->RA_NACIONA="10",.F.,EXISTCPO("SX5","34"+M->RA_NACIONA))
					If aDados[nPosNat] = "EX" .AND. aDados[W] = "10"
						cErro := cLinha+";NACIONALIDADE INVALIDA. "+aCampos[W]+" = "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"NACIONALIDADE INVALIDA. "+aCampos[W]+" = "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					Else	
						If EMPTY(POSICIONE("SX5",1,xFilial("SX5")+"34"+PAD(aDados[W],6),"X5_CHAVE")) // !EXISTCPO("SX5","34"+aDados[W])
							cErro := cLinha+";NACIONALIDADE NAO EXISTE. "+aCampos[W]+" = "+aDados[W]
							AADD( aErros, cErro )
							
							AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
							AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
							AADD(aLog,{"ERRO" 	   ,"NACIONALIDADE NAO EXISTE. "+aCampos[W]+" = "+aDados[W] ,Nil})
							
							lGrava := .F.
							LOOP
						EndIf
					EndIf
				EndIf
				If aCampos[W] == "RA_NASC"	// NaoVazio() .And. ChkDtNa(dDataBase,M->RA_NASC) .and. FHIST() .and. ValidSetEpoch()
					IF EMPTY(aDados[W])	// !NaoVazio(aDados[W])
						cErro := cLinha+";O CAMPO "+aCampos[W]+" ESTA VAZIO."
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CAMPO "+aCampos[W]+" ESTA VAZIO." ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
					IF aDados[W] >= dDatabase	// ChkDtNa(dDataBase,M->RA_NASC)
						cErro := cLinha+";COMPARA DATA DE NASCIMENTO. "+aCampos[W]+" = "+DTOS(aDados[W])
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"COMPARA DATA DE NASCIMENTO. "+aCampos[W]+" = "+DTOS(aDados[W]) ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
					
					// ValidSetEpoch()
					//
					
				EndIf
				If aCampos[W] == "RA_ADMISSA"	// NaoVazio() .And. ChkDtAd(M->RA_NASC,M->RA_ADMISSA) .And. FHIST()
					IF EMPTY(aDados[W])	// !NaoVazio(aDados[W])
						cErro := cLinha+";O CAMPO "+aCampos[W]+" ESTA VAZIO."
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CAMPO "+aCampos[W]+" ESTA VAZIO." ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
					IF aDados[nPosNas] >= aDados[W]	// ChkDtAd(M->RA_NASC,M->RA_ADMISSA)
						cErro := cLinha+";DATA DE NASCIMENTO MAIOR OU IGUAL A DATA DE ADMISSAO. "+aCampos[W]+" = "+DTOS(aDados[W])
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"DATA DE NASCIMENTO MAIOR OU IGUAL A DATA DE ADMISSAO. "+aCampos[W]+" = "+DTOS(aDados[W]) ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				If aCampos[W] == "RA_OPCAO"	//	NaoVazio() .And. ChkDtOp(M->RA_ADMISSA,M->RA_OPCAO)
					IF EMPTY(aDados[W])	// !NaoVazio(aDados[W])
						cErro := cLinha+";O CAMPO "+aCampos[W]+" ESTA VAZIO."
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,";O CAMPO "+aCampos[W]+" ESTA VAZIO." ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
					IF aDados[W] < aDados[nPosAdm]	// ChkDtOp(M->RA_ADMISSA,M->RA_OPCAO)
						cErro := cLinha+";DATA DE OPCAO MENOR DO QUE A DATA DE ADMISSAO. "+aCampos[W]+" = "+DTOS(aDados[W])
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"DATA DE OPCAO MENOR DO QUE A DATA DE ADMISSAO. "+aCampos[W]+" = "+DTOS(aDados[W]) ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				If aCampos[W] == "RA_EXAMEDI"	// ChkDt4(M->RA_ADMISSA,M->RA_EXAMEDI)
					IF aDados[W] < aDados[nPosAdm]	// ChkDt4(M->RA_ADMISSA,M->RA_EXAMEDI) 
						cErro := cLinha+";DATA DO EXAME MEDICO MENOR DO QUE A DATA DE ADMISSAO. "+aCampos[W]+" = "+DTOS(aDados[W])
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"DATA DO EXAME MEDICO MENOR DO QUE A DATA DE ADMISSAO. "+aCampos[W]+" = "+DTOS(aDados[W]) ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				If aCampos[W] == "RA_CTDPFGT"	//	NaoVazio() .And. If(M->RA_CTDEPSA=M->RA_CTDPFGT,.F.,.T.)
					If EMPTY(aDados[W])	// !NaoVazio(aDados[W])
						cErro := cLinha+";O CAMPO "+aCampos[W]+" ESTA VAZIO."
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CAMPO "+aCampos[W]+" ESTA VAZIO." ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
					If aDados[nPosCtd] = aDados[W]
						cErro := cLinha+";CONTA DE DEPOSITO DE SALARIO NAO PODE SER IGUAL A DE DEPOSITO DE FGTS. "+aCampos[W]+" = "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"CONTA DE DEPOSITO DE SALARIO NAO PODE SER IGUAL A DE DEPOSITO DE FGTS. "+aCampos[W]+" = "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				If aCampos[W] == "RA_HRSEMAN"	//	If(M->RA_HRSEMAN > 44.00,.F.,aMaiorZero(M->RA_HRSEMAN)) .And. POSITIVO()
					If aDados[W] < 0 .OR. aDados[W] > 44.00	// aMaiorZero(M->RA_HRSEMAN)) - POSITIVO()
						cErro := cLinha+";O CONTEUDO DO CAMPO "+aCampos[W]+" DEVE ESTAR ENTRE 0 E 44 - "+STR(aDados[W])
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CONTEUDO DO CAMPO "+aCampos[W]+" DEVE ESTAR ENTRE 0 E 44 - "+STR(aDados[W]) ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				If aCampos[W] == "RA_TNOTRAB"	//	EXISTCPO("SR6") .AND. FHIST()
					If EMPTY(POSICIONE("SR6",1,xFilial("SR6")+aDados[W],"R6_TURNO")) // !EXISTCPO("SR6",aDados[W])
						cErro := cLinha+";TURNO DE TRABALHO NAO EXISTE. "+aCampos[W]+" = "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"TURNO DE TRABALHO NAO EXISTE. "+aCampos[W]+" = "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				If aCampos[W] == "RA_CODFUNC"	//	EXISTCPO("SRJ")
					If EMPTY(POSICIONE("SRJ",1,xFilial("SRJ")+aDados[W],"RJ_FUNCAO")) // !EXISTCPO("SRJ",aDados[W])
						cErro := cLinha+";FUNCAO NAO EXISTE. "+aCampos[W]+" = "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"FUNCAO NAO EXISTE. "+aCampos[W]+" = "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf	
				If aCampos[W] == "RA_CATFUNC"	// EXISTCPO("SX5","28"+M->RA_CATFUNC).And.GPEA010Vld() .AND. GP010CATEG( M->RA_CATFUNC )
					If EMPTY(POSICIONE("SX5",1,xFilial("SX5")+"28"+PAD(aDados[W],6),"X5_CHAVE")) // !EXISTCPO("SX5","28"+aDados[W])
						cErro := cLinha+";DADO INVALIDO. "+aCampos[W]+" = "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"DADO INVALIDO. "+aCampos[W]+" = "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
					/*
					If GPEA010Vld(aDados[W])  // NUMERO MAIOR QUE 20
						cErro := cLinha+";DADO INVALIDO. "+aCampos[W]+" = "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"DADO INVALIDO. "+aCampos[W]+" = "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf 
					If GP010CATEG(aDados[W])	// NUMERO MAIOR QUE 20
						cErro := cLinha+";DADO INVALIDO. "+aCampos[W]+" = "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"DADO INVALIDO. "+aCampos[W]+" = "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
					*/
				EndIf
				If aCampos[W] == "RA_TIPOPGT"	//	EXISTCPO("SX5","40"+M->RA_TIPOPGT)
					If EMPTY(POSICIONE("SX5",1,xFilial("SX5")+"40"+PAD(aDados[W],6),"X5_CHAVE")) // !EXISTCPO("SX5","40"+aDados[W])
						cErro := cLinha+";DADO INVALIDO. "+aCampos[W]+" = "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"DADO INVALIDO. "+aCampos[W]+" = "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				If aCampos[W] == "RA_TIPOADM"	// ExistCpo("SX5","38"+M->RA_TIPOADM)
					If EMPTY(POSICIONE("SX5",1,xFilial("SX5")+"38"+PAD(aDados[W],6),"X5_CHAVE")) // !EXISTCPO("SX5","38"+aDados[W])
						cErro := cLinha+";DADO INVALIDO. "+aCampos[W]+" = "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"DADO INVALIDO. "+aCampos[W]+" = "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				If aCampos[W] == "RA_VIEMRAI"	// EXISTCPO("SX5","25"+M->RA_VIEMRAI)
					If EMPTY(POSICIONE("SX5",1,xFilial("SX5")+"25"+PAD(aDados[W],6),"X5_CHAVE")) // !EXISTCPO("SX5","25"+aDados[W])
						cErro := cLinha+";DADO INVALIDO. "+aCampos[W]+" = "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"DADO INVALIDO. "+aCampos[W]+" = "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				If aCampos[W] == "RA_GRINRAI"	// EXISTCPO("SX5","26"+M->RA_GRINRAI)
					If EMPTY(POSICIONE("SX5",1,xFilial("SX5")+"26"+PAD(aDados[W],6),"X5_CHAVE")) // !EXISTCPO("SX5","26"+aDados[W])
						cErro := cLinha+";DADO INVALIDO. "+aCampos[W]+" = "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"DADO INVALIDO. "+aCampos[W]+" = "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				If aCampos[W] == "RA_HOPARC"	// Pertence("12")
					If aDados[W] <> "1" .AND. aDados[W] <> "2"
						cErro := cLinha+";O CONTEUDO DO CAMPO "+aCampos[W]+" NAO PERTENCE AO RANGE '12' - "+aDados[W]
						cErro := cLinha+";O CONTEUDO DO CAMPO "+aCampos[W]+" NAO PERTENCE AO RANGE '12' - "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CONTEUDO DO CAMPO "+aCampos[W]+" NAO PERTENCE AO RANGE '12' - "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				If aCampos[W] == "RA_COMPSAB"	// Pertence("12")
					If aDados[W] <> "1" .AND. aDados[W] <> "2"
						cErro := cLinha+";O CONTEUDO DO CAMPO "+aCampos[W]+" NAO PERTENCE AO RANGE '12' - "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CONTEUDO DO CAMPO "+aCampos[W]+" NAO PERTENCE AO RANGE '12' - "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
			EndIf
		Next W
	Else
		cErro := cLinha+";REGISTRO JA EXISTENTE."
		AADD( aErros, cErro )
		
		AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
		AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
		AADD(aLog,{"ERRO" 	   ,"REGISTRO JA EXISTENTE." ,Nil})
		
		lGrava := .F.
	EndIf
    
	If lGrava
		u_GRVDADOS("SRA", aCampos, aDados, nPosFil)
	Else
		lGrava := .T.
	EndIf

	FT_FSKIP()
	nCont++
EndDo

FT_FUSE()

Aviso("Finalizado","Leitura do arquivo realizada com sucesso",{"Fechar"})

RestArea(aArea)

Return .T.