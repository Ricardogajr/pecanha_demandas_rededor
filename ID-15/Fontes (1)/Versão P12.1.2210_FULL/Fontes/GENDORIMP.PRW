#include "totvs.ch"
#xtranslate NToS([<n,...>])=>LTrim(Str([<n>]))

//--------------------------------------------------------------------------------------------------------------
    /*/
        Programa:GENDORIMP.PRW
        Funcao:GENDORIMP
        Data:23/07/2018 (v1)
        Autor: (v1) Mauricio Siqueira 
        Descricao:Rotina para a importação dos qualquer tabela do template CSV para o ERP Protheus.
    /*/
//--------------------------------------------------------------------------------------------------------------
User Function GENDORIMP()
	Local cSvFilAnt:=cFilAnt
	Local lExact:=Set(_SET_EXACT,"ON")
	IMPTABGEN()
	Set(_SET_EXACT,if(lExact,"ON","OFF"))
	cFilAnt:=cSvFilAnt
Return(NIL)

Static Function IMPTABGEN()

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
Private cTabela  := Space(03)
Private lOk      :=.F.
Private bOk      := { || If(u_ValidaDir(cArquivo), (lOk:=.T.,oDlg:End()) ,) }
Private bCancel  := { || lOk:=.F.,oDlg:End() }
Private lEnd     := .F.

Define MsDialog oDlg Title "Importação Genérica" From 08,15 To 21,080 Of GetWndDefault()
      
@ 050,028  Say 	   "Selecione o Arquivo:"  Size 060,015 Of oDlg Pixel
@ 050,082  MsGet   cArquivo 		       Size 122,008 Of oDlg Pixel
@ 050,210  Button  "…"			           Size 010,010 Action Eval({|| cArquivo:=u_SelectFile() }) Of oDlg Pixel

@ 070,028  Say 	   "Selecione o tabela"    Size 060,015 Of oDlg Pixel
@ 070,082  MsGet   cTabela    		       Size 020,008 Of oDlg Pixel
//@ 060,210  Button  "…"			           Size 010,010 Action Eval({|| cArquivo:=u_SelectFile() }) Of oDlg Pixel

Activate MsDialog oDlg Centered On Init (EnchoiceBar(oDlg,bOk,bCancel))

If lOk
	oProcess:=MsNewProcess():New( { |lEnd| lConv:=u_ImpGENCSV(cArquivo, @lEnd)}, "Importação Genérica", "Processando arquivo genérico", .T. )
	oProcess:Activate()	
	If lConv
		cArq := SUBSTR(cArquivo,RAT("\", cArquivo)+1,LEN(cArquivo))
		// mover o arquivo lido da pasta IMPORTAR para a pasTa IMPORTADO
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

/*
 Programa  ³ IMPGENCSV
 Autor     ³ Mauricio Siqueira
 Descricao ³ Rotina para a importação de qualquer tabela
/*/

User Function IMPGENCSV(cArq, lEnd)

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

        DO CASE
           CASE cTabela = "RBU"
              nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RBU_FILIAL" })
           CASE cTabela = "RD0"
              nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RD0_FILIAL" })
           CASE cTabela = "RDZ"
              nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RDZ_FILIAL" })		   
           CASE cTabela = "RI1"
              nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RI1_FILIAL" })
           CASE cTabela = "RCX"
              nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RCX_FILIAL" })
           CASE cTabela = "RGB"
              nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RGB_FILIAL" })
           CASE cTabela = "RHK"
              nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RHK_FILIAL" })
           CASE cTabela = "RHL"
              nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RHL_FILIAL" })
           CASE cTabela = "RHP"
              nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RHP_FILIAL" })
           CASE cTabela = "RHS"
              nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RHS_FILIAL" })
           CASE cTabela = "SR0"
              nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "R0_FILIAL" })
           CASE cTabela = "SRR"
              nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RR_FILIAL" })
           CASE cTabela = "SRK"
              nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RK_FILIAL" })
           CASE cTabela = "SRQ"
              nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RQ_FILIAL" })
           CASE cTabela = "TL5"
              nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "TL5_FILIAL" })
           CASE cTabela = "TL9"
              nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "TL9_FILIAL" })
           CASE cTabela = "TM5"
              nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "TM5_FILIAL" })
           CASE cTabela = "TM0"
              nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "TM0_FILIAL" })
           CASE cTabela = "TMT"
              nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "TMT_FILIAL" })
           CASE cTabela = "TMY"
              nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "TMY_FILIAL" })
           CASE cTabela = "TN0"
              nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "TN0_FILIAL" })
           CASE cTabela = "TNA"
              nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "TNA_FILIAL" })
           CASE cTabela = "TNC"
              nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "TNC_FILIAL" })
           CASE cTabela = "TNQ"
              nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "TNQ_FILIAL" })
           CASE cTabela = "TNY"
              nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "TNY_FILIAL" })
        ENDCASE

/*
		If u_VERTEMPL(aCampos[1], "SRA", "RA")
			Return .F.
		EndIf
		nPosMat := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RA_MAT" })
		nPosNom := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RA_NOME" })
		nPosNas := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RA_NASC" })
		nPosAdm := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RA_ADMISSA" })
		nPosCtd := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RA_CTDEPSA" })
		nPosNat := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RA_NATURAL" })
*/		

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
	
	If u_VldChave(cTabela, aCampos, aDados)
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
					
//					AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
//					AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
					AADD(aLog,{"ERRO" 	   ,"CAMPO OBRIGATORIO VAZIO - "+aCampos[W] ,Nil})
					
					lGrava := .F.
					LOOP
				EndIf
			EndIf
			
			// VERIFICAR SE O TAMANHO DO CAMPO É MAIOR
			If u_VldTamCpo(cTipo, ALLTRIM(aDados[W]), nTamanho, nDecimal)
				cErro := cLinha+";CONTEUDO DO CAMPO MAIOR QUE O ESPERADO - "+aCampos[W]
				AADD( aErros, cErro )
				
//				AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
//				AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
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
			
		Next W
	Else
		cErro := cLinha+";REGISTRO JA EXISTENTE."
		AADD( aErros, cErro )
		
//		AADD(aLog,{"RA_MAT"    ,aDados[nPosMat] ,Nil})
//		AADD(aLog,{"RA_NOME"   ,aDados[nPosNom] ,Nil})
		AADD(aLog,{"ERRO" 	   ,"REGISTRO JA EXISTENTE." ,Nil})
		
		lGrava := .F.
	EndIf
    
	If lGrava
		u_xRVDADOS(cTabela, aCampos, aDados, nPosFil)
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