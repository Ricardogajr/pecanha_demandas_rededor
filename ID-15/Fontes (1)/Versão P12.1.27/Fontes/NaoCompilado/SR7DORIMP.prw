#include "totvs.ch"
#xtranslate NToS([<n,...>])=>LTrim(Str([<n>]))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±?Programa  ?SR7DORIMP                              ?Data ?20/07/2015 º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Autor     ?Microsiga                                                  º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Descricao ?Rotina para a importação dos Historico de Alterações       º±?
±±?          ?Salariais do template CSV para o ERP Protheus.             º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Sintaxe   ?SR7DORIMP()                                                º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Retorno   ?nil                                                        º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Uso       ?Rede Dor São Luiz                                          º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function SR7DORIMP()
	Local cSvFilAnt:=cFilAnt
	Local lExact:=Set(_SET_EXACT,"ON")
	IMPRTSR7()
	Set(_SET_EXACT,if(lExact,"ON","OFF"))
	cFilAnt:=cSvFilAnt
Return(NIL)

Static Function IMPRTSR7()

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

Define MsDialog oDlg Title "Importação dos Históricos de Alterações Salariais" From 08,15 To 18,080 Of GetWndDefault()
    
@ 050,028  Say 	"Selecione o Arquivo:" 	Size 060,015 Of oDlg Pixel
@ 050,082  MsGet 	cArquivo 		    Size 122,008 Of oDlg Pixel
@ 050,210  Button "?"			        Size 010,010 Action Eval({|| cArquivo:=u_SelectFile() }) Of oDlg Pixel

Activate MsDialog oDlg Centered On Init (EnchoiceBar(oDlg,bOk,bCancel))

If lOk
	oProcess:=MsNewProcess():New( { |lEnd| lConv:=u_ImpSr7CSV(cArquivo, @lEnd)}, "Importação dos Históricos de Alterações Salariais", "Processando arquivo dos Históricos de Alterações Salariais", .T. )
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
±±?Programa  ?IMPSR7CSV                              ?Data ?20/07/2015 º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Autor     ?Microsiga                                                  º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Descricao ?Rotina para a importação dos Historico de Alterações       º±?
±±?          ?Salariais do template CSV para o ERP Protheus.             º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Sintaxe   ?IMPSR7CSV(cArq, lEnd)                                      º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Retorno   ?Logico                                                     º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Uso       ?Rede Dor São Luiz                                          º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function ImpSr7CSV(cArq, lEnd)

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

Private nPosFil
Private	nPosMat
Private nPosDat
Private nPosTip
Private nPosFun

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
		
		If u_VLDTEMPLATE(aCampos[1], "SR7", "R7")
			Return .F.
		EndIf
		
		nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "R7_FILIAL" })
		nPosMat := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "R7_MAT" })
		nPosDat := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "R7_DATA" })
		nPosTip := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "R7_TIPO" })
		nPosFun := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "R7_FUNCAO" })
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
	
	If lSRAFound .and. u_VldChave("SR7", aCampos, aDados)
		
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
			
			// VERIFICAR SE OS CAMPOS OBRIGATORIO ESTA PREENCHIDO
			If lObrigat
				if aCampos[W]=="R7_FUNCAO"
					if empty(aDados[W])
						aDados[W]:=SRA->RA_CODFUNC	
					endif
				endif
				if (aCampos[W]=="R7_DESCFUN")
					if empty(aDados[W])
						aDados[W]:=Posicione("SRJ",1,fFilfunc("SRA")+SRA->RA_CODFUNC,"RJ_DESC")
					else
						aDados[W]:=Posicione("SRJ",1,fFilfunc("SRA")+aDados[nPosFun],"RJ_DESC")
					endif
				endif
				if (aCampos[W]=="R7_DESCCAR")
					if empty(aDados[W])
						aDados[W]:=Posicione("SRJ",1,fFilfunc("SRA")+SRA->RA_CODFUNC,"RJ_DESC")
					else
						aDados[W]:=Posicione("SRJ",1,fFilfunc("SRA")+aDados[nPosFun],"RJ_DESC")
					endif
				endif
				If EMPTY(aDados[W]) 
					cErro := cLinha+";CAMPO OBRIGATORIO VAZIO - "+cCampo
					AADD( aErros, cErro )					
					
					AADD(aLog,{"R7_MAT"     ,aDados[nPosMat] ,Nil})
					AADD(aLog,{"R7_TIPO"    ,aDados[nPosTip] ,Nil})
					AADD(aLog,{"ERRO" 	   ,"CAMPO OBRIGATORIO VAZIO - "+cCampo ,Nil})
						
					lGrava := .F.
					LOOP
				EndIf
			EndIf
			
			// VERIFICAR SE O TAMANHO DO CAMPO ?MAIOR
			If u_VldTamCpo(cTipo, aDados[W], nTamanho, nDecimal)
				cErro := cLinha+";CONTEUDO DO CAMPO MAIOR QUE O ESPERADO - "+cCampo
				AADD( aErros, cErro )
				
				AADD(aLog,{"R7_MAT"     ,aDados[nPosMat] ,Nil})
				AADD(aLog,{"R7_TIPO"    ,aDados[nPosTip] ,Nil})
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
			EndCase
					 
			// VALIDAÇÃO DOS CAMPOS OBRIGATORIOS
			If lObrigat
				If aCampos[W] == "R7_DESCTIP"	// NaoVazio()
					If Empty(aDados[W]) // !NaoVazio(aDados[W])
						cErro := cLinha+";O CAMPO "+aCampos[W]+" ESTA VAZIO."
						AADD( aErros, cErro )					
						
						AADD(aLog,{"R7_MAT"     ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"R7_TIPO"    ,aDados[nPosTip] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CAMPO "+aCampos[W]+" ESTA VAZIO." ,Nil})
							
						lGrava := .F.
						LOOP
					Endif                                           
				Endif                   
				If aCampos[W] == "R7_TIPOPGT"	//	ExistCpo('SX5','40'+M->R7_TIPOPGT)        
					If EMPTY(POSICIONE("SX5",1,xFilial("SX5")+"40"+PAD(aDados[W],6),"X5_CHAVE")) // !(ExistCpo('SX5','40'+aCampos[W]))				
						cErro := cLinha+";O TIPO PAGAMENTO NAO EXISTE. "+aCampos[W]+" = "+aDados[W]				
						AADD( aErros, cErro )					
						
						AADD(aLog,{"R7_MAT"     ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"R7_TIPO"    ,aDados[nPosTip] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O TIPO PAGAMENTO NAO EXISTE. "+aCampos[W]+" = "+aDados[W] ,Nil})
							
						lGrava := .F.
						LOOP
					Endif                                           
				Endif  		                       
				If aCampos[W] == "R7_CATFUNC"	//	ExistCpo('SX5','28'+M->R7_CATFUNC)
					If EMPTY(POSICIONE("SX5",1,xFilial("SX5")+"28"+PAD(aDados[W],6),"X5_CHAVE")) // !(ExistCpo('SX5','28'+aCampos[W]))
						cErro := cLinha+";CATEGORIA DE FUNCIONARIO INEXISTENTE. "+aCampos[W]+" = "+aDados[W]				
						AADD( aErros, cErro )					
						
						AADD(aLog,{"R7_MAT"     ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"R7_TIPO"    ,aDados[nPosTip] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"CATEGORIA DE FUNCIONARIO INEXISTENTE. "+aCampos[W]+" = "+aDados[W] ,Nil})
							
						lGrava := .F.
						LOOP
					Endif                                           
				Endif  	    
				If aCampos[W] == "R7_USUARIO" // NaoVazio()
					If Empty(aDados[W]) // !NaoVazio(aDados[W])
						cErro := cLinha+";O CAMPO "+aCampos[W]+" ESTA VAZIO."
						AADD( aErros, cErro )					
						
						AADD(aLog,{"R7_MAT"     ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"R7_TIPO"    ,aDados[nPosTip] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CAMPO "+aCampos[W]+" ESTA VAZIO." ,Nil})
							
						lGrava := .F.
						LOOP
					Endif                                           
				Endif  	                
			EndIf
		Next W
	Else
		if .not.(lSRAFound)
			cErro := cLinha+";FUNCIONARIO NAO CADASTRADO."
			AADD( aErros, cErro )
			
			AADD(aLog,{"R7_MAT"     ,aDados[nPosMat] ,Nil})
			AADD(aLog,{"R7_TIPO"    ,aDados[nPosTip] ,Nil})
			AADD(aLog,{"ERRO" 	   ,"FUNCIONARIO NAO CADASTRADO." ,Nil})

		else
			cErro := cLinha+";REGISTRO JA EXISTENTE."
			AADD( aErros, cErro )
			
			AADD(aLog,{"R7_MAT"     ,aDados[nPosMat] ,Nil})
			AADD(aLog,{"R7_TIPO"    ,aDados[nPosTip] ,Nil})
			AADD(aLog,{"ERRO" 	   ,"REGISTRO JA EXISTENTE." ,Nil})
		endif		
		lGrava := .F.
	EndIf
	
	If lGrava
		u_GRVDADOS("SR7", aCampos, aDados, nPosFil)
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
