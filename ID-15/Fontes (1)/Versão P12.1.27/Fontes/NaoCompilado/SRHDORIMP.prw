#include "rwmake.ch"
#include "totvs.ch"
#xtranslate NToS([<n,...>])=>LTrim(Str([<n>]))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±?Programa  ?SRHDORIMP                              ?Data ?13/09/2015 º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Autor     ?Microsiga                                                  º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Descricao ?Rotina para a importação das Ferias do template CSV para o º±?
±±?          ?ERP Protheus.                                              º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Sintaxe   ?SRHDORIMP()                                                º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Retorno   ?nil                                                        º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Uso       ?Rede Dor São Luiz                                          º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function SRHDORIMP()
    Local cSvFilAnt:=cFilAnt
	Local lExact:=Set(_SET_EXACT,"ON")
	IMPRTSRH()
	Set(_SET_EXACT,if(lExact,"ON","OFF"))
	cFilAnt:=cSvFilAnt
Return(NIL)

Static Function IMPRTSRH()

Local aRet		:= {}                                
Local aArea		:= GetArea()
Local cArq      := ""
// ORIGRINAL
//Local cOrigem	:= UPPER(GetSrvProfString("ROOTPATH",""))+"\MIGRACAO\IMPORTAR\"
//Local cDestino	:= UPPER(GetSrvProfString("ROOTPATH",""))+"\MIGRACAO\IMPORTADO\"
Local cOrigem	:= UPPER(GetSrvProfString("ROOTPATH",""))+"\M&A\IMPORTAR\"
Local cDestino	:= UPPER(GetSrvProfString("ROOTPATH",""))+"\M&A\IMPORTADO\"

Local lConv     := .F.

Private aErros  := {}
Private aLog    := {}

Private cArquivo := Space(150)
Private lOk      :=.F.
Private bOk      := { || If(u_ValidaDir(cArquivo), (lOk:=.T.,oDlg:End()) ,) }
Private bCancel  := { || lOk:=.F.,oDlg:End() }
Private lEnd     := .F.

Define MsDialog oDlg Title "Importação das Férias" From 08,15 To 018,080 Of GetWndDefault()
      
@ 050,028  Say 	   "Diretorio:"  Size 060,015 Of oDlg Pixel
@ 050,088  MsGet   cArquivo 	 Size 122,008 Of oDlg Pixel
@ 050,210  Button  "?" 			 Size 010,010 Action Eval({|| cArquivo:=u_SelectFile() }) Of oDlg Pixel

Activate MsDialog oDlg Centered On Init (EnchoiceBar(oDlg,bOk,bCancel))

If lOk
	oProcess:=MsNewProcess():New( { |lEnd| lConv:=u_ImpSrhCSV(cArquivo, @lEnd)}, "Importação das Férias", "Processando arquivo das Férias", .T. )
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
±±?Programa  ?IMPSRHCSV                              ?Data ?19/07/2015 º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Autor     ?Microsiga                                                  º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Descricao ?Rotina para a importação das Ferias do template CSV para o º±?
±±?          ?ERP Protheus.                                              º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Sintaxe   ?IMPSRHCSV(cArq, lEnd)                                      º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Retorno   ?Logico                                                     º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Uso       ?Rede Dor São Luiz                                          º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function ImpSrhCSV(cArq, lEnd)

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
		
		If u_VERTEMPL(aCampos[1], "SRH", "RH")
			Return .F.
		EndIf
		
		nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RH_FILIAL" })
		nPosMat := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RH_MAT" })
		nPosDba := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RH_DATABAS" })
		nPosDin := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RH_DATAINI" })
	EndIf
	AADD( aErros, cLinha )
	cLinha := ""
	Ft_FSkip()
	nLinTit--
EndDo

oProcess:SetRegua1( nTot )
oProcess:SetRegua2( int(nTot/100) )

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
	
	If u_VldChave("SRH", aCampos, aDados)
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
				If EMPTY(aDados[W]) .OR. ALLTRIM(aDados[W]) == ""
					cErro := cLinha+";CAMPO OBRIGATORIO VAZIO - "+cCampo
					AADD( aErros, cErro )					
					
					AADD(aLog,{"RH_MAT"     ,aDados[nPosMat] ,Nil})
					AADD(aLog,{"ERRO" 	    ,"CAMPO OBRIGATORIO VAZIO - "+cCampo ,Nil})
					
					lGrava := .F.
					LOOP
				EndIf
			EndIf
			
			// VERIFICAR SE O TAMANHO DO CAMPO ?MAIOR
			If u_VldTamCpo(cTipo, aDados[W], nTamanho, nDecimal)
				cErro := cLinha+";CONTEUDO DO CAMPO MAIOR QUE O ESPERADO - "+cCampo
				AADD( aErros, cErro )
				
				AADD(aLog,{"RH_MAT"     ,aDados[nPosMat] ,Nil})
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
				/*
				If aCampos[W] == "RH_DATABAS"	// Ver_Med() - FONTE - GPEM030.PRX/GPEXMED.PRX
					// Ver_Med() - Verifica numero de faltas,gera Pensao Alimenticia 13?Sal. etc...
				EndIf
				*/
				/*
				If aCampos[W] == "RH_DFERVEN"	// fDiasFer()
					// fDiasFer() - FONTE - GPEM030.PRX
					// Calcula "RH_DFERIAS := M->RH_DFERVEN - nDFal"
					// cALCULA "RH_DABONPE := 0.00"
				EndIf
				*/
				If aCampos[W] == "RH_DFERIAS"	// fVerDias() .And. NaoVazio()
					// fVerDias() - FONTE - GPEM030.PRX
					// calcula "Dias Antecipados"
					// calcula "Dias Ferias" - RH_DFERIAS
					// calcula "Dias Abono" - RH_DABONPE
					IF EMPTY(aDados[W])	// !NaoVazio(aDados[W])
						cErro := cLinha+";O CAMPO "+aCampos[W]+" ESTA VAZIO."
						AADD( aErros, cErro )
						
						AADD(aLog,{"RH_MAT"     ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CAMPO "+aCampos[W]+" ESTA VAZIO." ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				If aCampos[W] == "RH_DATAINI"	// fDatafer() .and. NaoVazio()
					// GetRemoteType() == -1 // quando eh JOB 
					// fDatafer() - FONTE - GPEM030.PRX
					// Verifica se existe afastamento e mostra alerta na tela.
					IF EMPTY(aDados[W])	// !NaoVazio(aDados[W])
						cErro := cLinha+";O CAMPO "+cCampo+" ESTA VAZIO."
						AADD( aErros, cErro )
						
						AADD(aLog,{"RH_MAT"     ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CAMPO "+cCampo+" ESTA VAZIO." ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				If aCampos[W] == "RH_DATAFIM"	// If(M->RH_DATAINI > M->RH_DATAFIM, .F. , .T.) .And. NaoVazio()
					If EMPTY(aDados[W])	// !NaoVazio(aDados[W])
						cErro := cLinha+";O CAMPO "+aCampos[W]+" ESTA VAZIO."
						AADD( aErros, cErro )
						
						AADD(aLog,{"RH_MAT"     ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CAMPO "+aCampos[W]+" ESTA VAZIO." ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
					If aDados[nPosDin] > aDados[W]
						cErro := cLinha+";RH_DATAINI > RH_DATAFIM - "+cCampo+" - "+DTOC(aDados[W])
						AADD( aErros, cErro )
						
						AADD(aLog,{"RH_MAT"     ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"RH_DATAINI > RH_DATAFIM - "+DTOC(aDados[W]) ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				If aCampos[W] == "RH_DTAVISO"	// If(M->RH_DTAVISO <= (M->RH_DATAINI - 30) , .T. , .F.) .And. NaoVazio()
					IF EMPTY(aDados[W])	// !NaoVazio(aDados[W])
						cErro := cLinha+";O CAMPO "+aCampos[W]+" ESTA VAZIO."
						AADD( aErros, cErro )
						
						AADD(aLog,{"RH_MAT"     ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CAMPO "+aCampos[W]+" ESTA VAZIO." ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
					If aDados[W] > (aDados[nPosDin] - 30) 
						cErro := cLinha+";RH_DTAVISO <= (RH_DATAINI - 30) - "+aCampos[W]+" - "+DTOC(aDados[W])
						
						AADD( aErros, cErro )
						
						AADD(aLog,{"RH_MAT"     ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"RH_DTAVISO <= (RH_DATAINI - 30) - "+aCampos[W]+" - "+DTOC(aDados[W]) ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
					
				If aCampos[W] == "RH_DTRECIB"	// If(M->RH_DTRECIB < M->RH_DATAINI , .T. , .F.) .And. NaoVazio()
					IF EMPTY(aDados[W])
						cErro := cLinha+";O CAMPO "+aCampos[W]+" ESTA VAZIO."
						AADD( aErros, cErro )
						
						AADD(aLog,{"RH_MAT"     ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CAMPO "+aCampos[W]+" ESTA VAZIO." ,Nil})
					    
						lGrava := .F.
						LOOP
					EndIf
					IF aDados[W] >= aDados[nPosDin]
						cErro := cLinha+";RH_DTRECIB < RH_DATAINI - "+aCampos[W]+" - "+DTOS(aDados[W])
						AADD( aErros, cErro )
						
						AADD(aLog,{"RH_MAT"     ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"RH_DTRECIB < RH_DATAINI - "+aCampos[W]+" - "+DTOS(aDados[W]) ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				If aCampos[W] == "RH_MEDATU"	// Pertence("SN")
					If aDados[W] <> "S" .AND. aDados[W] <> "N"
						cErro := cLinha+";O CONTEUDO DO CAMPO "+aCampos[W]+" NAO PERTENCE AO RANGE 'SN' - "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RH_MAT"     ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CONTEUDO DO CAMPO "+aCampos[W]+" NAO PERTENCE AO RANGE 'SN' - "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
			EndIf
		Next W
    Else
		cErro := cLinha+";REGISTRO JA EXISTENTE."
		AADD( aErros, cErro )
		
		AADD(aLog,{"RH_MAT"     ,aDados[nPosMat] ,Nil})
		AADD(aLog,{"ERRO" 	   ,"REGISTRO JA EXISTENTE." ,Nil})
		
		lGrava := .F.
	EndIf
	
    If lGrava
		u_GRVDADOS("SRH", aCampos, aDados, nPosFil)
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
