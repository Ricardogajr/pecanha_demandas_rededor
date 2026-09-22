#include "totvs.ch"
#xtranslate NToS([<n,...>])=>LTrim(Str([<n>]))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±?Programa  ?SR3DORIMP                              ?Data ?20/07/2015 º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Autor     ?Microsiga                                                  º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Descricao ?Rotina para a importação dos Historico Valores Salariais   º±?
±±?          ?do template CSV para o ERP Protheus.                       º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Sintaxe   ?IMPRTSR3()                                                 º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Retorno   ?nil                                                        º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Uso       ?Rede Dor São Luiz                                          º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function SR3DORIMP()
	Local cSvFilAnt:=cFilAnt
	Local lExact:=Set(_SET_EXACT,"ON")
	IMPRTSR3()
	Set(_SET_EXACT,if(lExact,"ON","OFF"))
	cFilAnt:=cSvFilAnt
Return(NIL)

Static Function IMPRTSR3()

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

Private cArquivo := Space(150)
Private lOk      :=.F.
Private bOk      := { || If(u_ValidaDir(cArquivo), (lOk:=.T.,oDlg:End()) ,) }
Private bCancel  := { || lOk:=.F.,oDlg:End() }
Private lEnd     := .F.

Define MsDialog oDlg Title "Importação dos Históricos de Valores Salariais" From 08,15 To 18,080 Of GetWndDefault()
      
@ 050,028 Say 	 "Diretorio:" 	Size 060,015 Of oDlg Pixel
@ 050,082 MsGet  cArquivo 		Size 122,008 Of oDlg Pixel
@ 050,210 Button "?" 			Size 010,010 Action Eval({|| cArquivo:=u_SelectFile() }) Of oDlg Pixel

Activate MsDialog oDlg Centered On Init (EnchoiceBar(oDlg,bOk,bCancel))

If lOk
	oProcess:=MsNewProcess():New( { |lEnd| lConv:=u_ImpSr3CSV(cArquivo, @lEnd)}, "Importação dos Históricos de Valores Salariais", "Processando arquivo dos Históricos de Valores Salariais", .T. )
	oProcess:Activate()	
	If lConv
		cArq := SUBSTR(cArquivo,RAT("\", cArquivo)+1,LEN(cArquivo))
		// mover o arquivo lido da pasta IMPORTAR para a pasra IMPORTADO
		If FRENAME ( cOrigem+cArq , cDestino+cArq ) == -1
			MsgInfo("Não foi possível mover o arquivo da pasta IMPORTAR para a pasta IMPORTADO")
		EndIf
		// cria arquivo de LOG
		u_CRIARLOG(aLog, SUBSTR(cArq,1,LEN(cArq)-4), 4)
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
±±?Programa  ?IMPSR3CSV                              ?Data ?20/07/2015 º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Autor     ?Microsiga                                                  º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Descricao ?Rotina para a importação dos Historico Valores Salariais   º±?
±±?          ?do template CSV para o ERP Protheus.                       º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Sintaxe   ?IMPSR3CSV(cArq, lEnd)                                      º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Retorno   ?Logico                                                     º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Uso       ?Rede Dor São Luiz                                          º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function ImpSr3CSV(cArq, lEnd)

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

Local lSRAFound

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
		
		If u_VERTEMPL(aCampos[1], "SR3", "R3")
			Return .F.
		EndIf
		
		nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "R3_FILIAL" })
		nPosMat := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "R3_MAT" })
		nPosDat := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "R3_DATA" })
		nPosTip := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "R3_TIPO" })
		nPosPrd := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "R3_PD" })
		nPosDes := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "R3_DESCPD" })
	EndIf
	AADD( aErros, cLinha )
	cLinha := ""
	Ft_FSkip()
	nLinTit--
EndDo

oProcess:SetRegua1( nTot )
oProcess:SetRegua2( int(ntot/100) )

BEGIN TRANSACTION
// Processa os dados do template
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
		oProcess:IncRegua2( "Tempo Restante - (" + u_EstTime(ntot,nAtual,(nAtual-100),nTimeIni) + ")" )
	EndIf
	
	//aDados := STRTOKARR(cLinha,";")   // A função SEPARA e a função STRTOKARR, converte uma string em um array, o SEPARA converte os espaços em branco 
	aDados := SEPARA(UPPER(cLinha),";",.T.)      

	SRA->(dbSetOrder(RetOrder("SRA","RA_FILIAL+RA_MAT")))
	
	lSRAFound:=SRA->(dbSeek(fFilFunc("SRA")+aDados[nPosMat],.F.))

	If lSRAFound .and. u_VldChave("SR3", aCampos, aDados)
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
					
					AADD(aLog,{"R3_MAT"     ,aDados[nPosMat] ,Nil}) 
					AADD(aLog,{"R3_TIPO"    ,aDados[nPosTip] ,Nil}) 
					AADD(aLog,{"R3_PD"      ,aDados[nPosPrd] ,Nil})
					AADD(aLog,{"ERRO" 	   ,"CAMPO OBRIGATORIO VAZIO - "+cCampo ,Nil})	
					
					lGrava := .F.
					LOOP
				EndIf
			EndIf
			
			// VERIFICAR SE O TAMANHO DO CAMPO ?MAIOR
			If u_VldTamCpo(cTipo, aDados[W], nTamanho, nDecimal)
				cErro := cLinha+";CONTEUDO DO CAMPO MAIOR QUE O ESPERADO - "+cCampo
				AADD( aErros, cErro )
				
				AADD(aLog,{"R3_MAT"     ,aDados[nPosMat] ,Nil}) 
				AADD(aLog,{"R3_TIPO"    ,aDados[nPosTip] ,Nil}) 
				AADD(aLog,{"R3_PD"      ,aDados[nPosPrd] ,Nil})
				AADD(aLog,{"ERRO" 	   ,";CONTEUDO DO CAMPO MAIOR QUE O ESPERADO - "+cCampo ,Nil})
			
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
				If aCampos[W] == "R3_MAT"	//	NaoVazio() .And. EXISTCHAV("SRA") .And. Val(M->R7_MAT) > 0
					If Empty(aDados[W])	// !NaoVazio(aDados[W])
						cErro := cLinha+";O CAMPO "+aCampos[W]+" ESTA VAZIO."
						AADD( aErros, cErro )
						
						AADD(aLog,{"R3_MAT"     ,aDados[nPosMat] ,Nil}) 
						AADD(aLog,{"R3_TIPO"    ,aDados[nPosTip] ,Nil}) 
						AADD(aLog,{"R3_PD"      ,aDados[nPosPrd] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CAMPO "+aCampos[W]+" ESTA VAZIO." ,Nil})
						
						lGrava := .F.
						LOOP
					Endif
					If Val(aDados[W]) <= 0
						cErro := cLinha+";MATRICULA INVALIDA - "+cCampo+" = "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"R3_FILIAL"  ,aDados[nPosFil] ,Nil})
						AADD(aLog,{"R3_MAT"     ,aDados[nPosMat] ,Nil}) 
						AADD(aLog,{"R3_TIPO"    ,aDados[nPosTip] ,Nil}) 
						AADD(aLog,{"R3_PD"      ,aDados[nPosPrd] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"MATRICULA INVALIDA - "+cCampo+" = "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					Endif                  
				Endif
				IF aCampos[W] == "R3_DATA" .OR. aCampos[W] == "R3_TIPO"	// NaoVazio() .And. fA250Cons()
					IF Empty(aDados[W])	// !NaoVazio(aDados[W])
						cErro := cLinha+";O CAMPO "+aCampos[W]+" ESTA VAZIO."
						AADD( aErros, cErro )
						
						AADD(aLog,{"R3_MAT"     ,aDados[nPosMat] ,Nil}) 
						AADD(aLog,{"R3_TIPO"    ,aDados[nPosTip] ,Nil}) 
						AADD(aLog,{"R3_PD"      ,aDados[nPosPrd] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CAMPO "+aCampos[W]+" ESTA VAZIO." ,Nil})
						
						lGrava := .F.
						LOOP
	
					Endif
				Endif
				If aCampos[W] == "R3_PD"	//	R3PdVld()
					If EMPTY(POSICIONE("SRV",1,xFilial("SRV")+aDados[W],"RV_COD"))
						if .not.("000"$aDados[W])
							cErro := cLinha+";DADO NAO VALIDO PARA O CAMPO " +aCampos[W] + " = " + aDados[W]
							AADD( aErros, cErro )
							
							AADD(aLog,{"R3_MAT"     ,aDados[nPosMat] ,Nil}) 
							AADD(aLog,{"R3_TIPO"    ,aDados[nPosTip] ,Nil}) 
							AADD(aLog,{"R3_PD"      ,aDados[nPosPrd] ,Nil})
							AADD(aLog,{"ERRO" 	   ,"DADO NAO VALIDO PARA O CAMPO " +aCampos[W] + " = " + aDados[W] ,Nil})
							
							lGrava := .F.
							LOOP
						endif
					endif
				Endif                           
				If aCampos[W] == "R3_DESCPD"	//	NaoVazio()
					If EMPTY(aDados[W])
						aDados[W]:="SALARIO BASE"
					endif
					If EMPTY(aDados[W])	// !NaoVazio(aDados[W])
						cErro := cLinha+";O CAMPO "+aCampos[W]+" ESTA VAZIO."
						AADD( aErros, cErro )
						
						AADD(aLog,{"R3_MAT"     ,aDados[nPosMat] ,Nil}) 
						AADD(aLog,{"R3_TIPO"    ,aDados[nPosTip] ,Nil}) 
						AADD(aLog,{"R3_PD"      ,aDados[nPosPrd] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CAMPO "+aCampos[W]+" ESTA VAZIO." ,Nil})
						
						lGrava := .F.
						LOOP
					Endif                                           
				Endif    
				If aCampos[W] == "R3_VALOR" // NaoVazio() .AND. POSITIVO()
					If EMPTY(aDados[W])	// NaoVazio()
						cErro := cLinha+";O CAMPO "+aCampos[W]+" ESTA VAZIO."
						AADD( aErros, cErro )
						
						AADD(aLog,{"R3_MAT"     ,aDados[nPosMat] ,Nil}) 
						AADD(aLog,{"R3_TIPO"    ,aDados[nPosTip] ,Nil}) 
						AADD(aLog,{"R3_PD"      ,aDados[nPosPrd] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CAMPO "+aCampos[W]+" ESTA VAZIO." ,Nil})
						
						lGrava := .F.
						LOOP
					Endif    
					
					If aDados[W] < 0	//	POSITIVO()
						
						cErro := cLinha+";O CAMPO "+aCampos[W]+" ESTA NEGATIVO."
						AADD( aErros, cErro )
						
						AADD(aLog,{"R3_MAT"     ,aDados[nPosMat] ,Nil}) 
						AADD(aLog,{"R3_TIPO"    ,aDados[nPosTip] ,Nil}) 
						AADD(aLog,{"R3_PD"      ,aDados[nPosPrd] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CAMPO "+aCampos[W]+" ESTA NEGATIVO." ,Nil})
						
						lGrava := .F.
						LOOP
					Endif  				                                       
				Endif			
			Endif                       							
		Next W	
	Else
	
		if .not.(lSRAFound)
			cErro := cLinha+";FUNCIONARIO NAO CADASTRADO."
			AADD( aErros, cErro )
			
			AADD(aLog,{"R3_MAT"     ,aDados[nPosMat] ,Nil})
			AADD(aLog,{"R3_TIPO"    ,aDados[nPosTip] ,Nil})
			AADD(aLog,{"ERRO" 	   ,"FUNCIONARIO NAO CADASTRADO." ,Nil})

		else
		
			cErro := cLinha+";REGISTRO JA EXISTENTE."
			AADD( aErros, cErro )
			
			AADD(aLog,{"R3_MAT"     ,aDados[nPosMat] ,Nil}) 
			AADD(aLog,{"R3_TIPO"    ,aDados[nPosTip] ,Nil}) 
			AADD(aLog,{"R3_PD"      ,aDados[nPosPrd] ,Nil})
			AADD(aLog,{"ERRO" 	   ,"REGISTRO JA EXISTENTE." ,Nil})
		endif

			
		lGrava := .F.
	EndIf
	
    If lGrava
		u_GRVDADOS("SR3", aCampos, aDados, nPosFil)
	Else
		lGrava := .T.
	EndIf
	   	
	FT_FSKIP()
	nCont++
EndDo
END TRANSACTION

If lRet //Thais Paiva - Compatibiliza??o P27
	FT_FUSE()

	Aviso("Finalizado","Leitura do arquivo realizada com sucesso",{"Fechar"})
EndIf //Thais Paiva - Compatibiliza??o P27

RestArea(aArea)

Return lRet //.T. Thais Paiva - Compatibiliza??o P27
