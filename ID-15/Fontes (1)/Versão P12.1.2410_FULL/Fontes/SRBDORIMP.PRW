#include "totvs.ch"
#xtranslate NToS([<n,...>])=>LTrim(Str([<n>]))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±?Programa  ?SRBDORIMP                              ?Data ?03/10/2015 º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Autor     ?Microsiga                                                  º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Descricao ?Rotina para a importação da Tabela SRB   template CSV para º±?
±±?          ?o ERP Protheus.                                            º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Sintaxe   ?SRBDORIMP()                                                º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Retorno   ?nil                                                        º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Uso       ?Rede Dor São Luiz                                          º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function SRBDORIMP()
    Local cSvFilAnt:=cFilAnt
	Local lExact:=Set(_SET_EXACT,"ON")
	IMPRTSRB()
	Set(_SET_EXACT,if(lExact,"ON","OFF"))
	cFilAnt:=cSvFilAnt
Return(NIL)

Static Function IMPRTSRB()

	Local aRet:= {}                                
	Local aArea:= GetArea()
	Local cArq:=""
//	Local cOrigem
//	Local cDestino:=GetMV("MV_PATH")

//	Local cOrigem   := UPPER(GetSrvProfString("ROOTPATH",""))+"\M&A\IMPORTAR\"
//	Local cDestino	:= UPPER(GetSrvProfString("ROOTPATH",""))+"\M&A\IMPORTADO\"

    Local cOrigem	:= "C:\M&A\IMPORTAR\"
    Local cDestino	:= "C:\M&A\IMPORTADO\"
	
	Local cDriver
	Local cDir
	Local cFile
	Local cExt
	
	Local lConv     := .F.
	
	Private aErros  := {}
	Private aLog    := {}
	
	Public cArquivo := Space(150)
	Public lOk      :=.F.
	Public bOk      := { || If(u_ValidaDir(cArquivo), (lOk:=.T.,oDlg:End()) ,) }
	Public bCancel  := { || lOk:=.F.,oDlg:End() }
	Public lEnd     := .F.
	
	Define MsDialog oDlg Title "Importação dos Dependentes" From 08,15 To 18,080 Of GetWndDefault()
	      
		@ 050,028  Say 	"Diretorio:" 	Size 060,015 Of oDlg Pixel
		@ 050,082  MsGet 	cArquivo 	Size 122,008 Of oDlg Pixel
		@ 050,210  Button "..." 		Size 010,010 Action Eval({|| cArquivo:=u_SelectFile() }) Of oDlg Pixel
		
	Activate MsDialog oDlg Centered On Init (EnchoiceBar(oDlg,bOk,bCancel))

	If lOk
		oProcess:=MsNewProcess():New( { |lEnd| lConv:=u_ImpSrbCSV(cArquivo, @lEnd)}, "Importação de Dependentes", "Processando arquivo de Dependentes", .T. )
		oProcess:Activate()	
		If lConv
			SplitPath(@cArquivo,@cDriver,@cDir,@cFile,@cExt)
			cArq+=cFile
			cArq+=cExt
			cOrigem:=cArquivo
			cDestino:=(cDestino+cArq)
			If .not.(__CopyFile(cOrigem,cDestino))
				MsgInfo("Não foi possível mover o arquivo da pasta IMPORTAR para a pasta IMPORTADO")
			EndIf
			// cria arquivo de LOG
			u_CRIARLOG(aLog,cFile,4)
			// gera arquivo excel 
//			u_GeraExcel(aErros,cFile)
		EndIf
	EndIf

Return 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±?Programa  ?IMPSRBCSV                              ?Data ?07/10/2015 º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Autor     ?Microsiga                                                  º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Descricao ?Rotina para a importação dos Dependentes do template CSV   º±?
±±?          ?para o ERP Protheus.                                       º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Sintaxe   ?IMPSRBCSV(cArq, lEnd)                                      º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Retorno   ?Logico                                                     º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Uso       ?Rede Dor São Luiz                                          º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function ImpSrbCSV(cArq, lEnd)

Local aArea		:= GetArea()
Local aStruct	:= {}
Local aVetor    := {}
Local aDados    := {}

Local cLinha
Local lGrava    := .T.
Local nTot      := 0
Local nCont     := 1
Local nAtual    := 0
Local nTimeIni  := 0
Local nLinTit   := 2  // Total de linhas do Cabeçalho
Local cArqTmp   := "\M&A\IMPORTAR\TMPSRB_"+CriaTrab(NIL,.F.) 
//Local cIndexKey := "RB_FILIAL+RB_MAT+RB_COD" //Thais Paiva - Compatibiliza??o P27

Local aCampos 	:= {} 
Local aCoors 	:= MsAdvSize()

Local W
Local X

Local lRet := .T. //Thais Paiva - Compatibiliza??o P27

Private lMsErroAuto := .F.

Private cCampo   := ""
Private lObrigat := .T.
Private cTipo    := ""
Private nTamanho := 0
Private nDecimal := 0
Private cValida  := ""
Private aValida  := {}

/*while .not.(lIsDir("\MIGRACAO\TEMP\"))
	MakeDir("\MIGRACAO\TEMP\")
end while */

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±?Descrição ?Criação do arquivo temporário que ir?receber os dados    º±?
±±?          ?do template SRB ( Dependentes )                           º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/ 
  
aStruct := u_CriaArray("SRB") 

//In¨ªcio - Thais Paiva - Compatibiliza??o P27
//dbCreate(cArqTmp, aStruct)
oTempTable := FWTemporaryTable():New( "TMPSRB" )
oTemptable:SetFields( aStrCmp )
oTempTable:AddIndex("TMPSRB", {"RB_FILIAL","RB_MAT","RB_COD"})
oTempTable:Create()
//Fim - Thais Paiva - Compatibiliza??o P27

dbUseArea(.T.,"LOCAL",cArqTmp,"TMPSRB",.T.,.F.)

//IndRegua("TMPSRB", cArqTmp, cIndexKey,,,"Aguarde indexando registros....") Thais Paiva - Compatibiliza??o P27


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
		
		If u_VERTEMPL(aCampos[1], "SRB", "RB")
			Return .F.
		EndIf
		
		nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RB_FILIAL" })
		nPosMat := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RB_MAT" })
		nPosCod := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RB_COD" })
		nPosNom := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RB_NOME" })
//		nPosNac := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RB_XNACIO" })
//		nPosDep := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RB_XDEPINV" })
		
//		cXnacio  := ALLTRIM(Posicione("SX3", 2, aCampos[nPosNac], "X3_CAMPO"))
//		cXdepinv := ALLTRIM(Posicione("SX3", 2, aCampos[nPosDep], "X3_CAMPO"))
	EndIf
	AADD( aErros, cLinha )
	cLinha := ""
	Ft_FSkip()
	nLinTit--
EndDo

oProcess:SetRegua1( nTot )
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
		oProcess:IncRegua2( "Tempo Restante - (" + u_EstTime(ntot,nAtual,(nAtual-100),nTimeIni) + ")" )
	EndIf
	
	//aDados := STRTOKARR(cLinha,";")   // A função SEPARA e a função STRTOKARR, converte uma string em um array, o SEPARA converte os espaços em branco 
	aDados := SEPARA(UPPER(cLinha),";",.T.)
	
	If TMPSRB->( !dbSeek(aDados[nPosMat]+aDados[nPosCod]) )
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
					
					AADD(aLog,{"RB_MAT"  ,aDados[nPosMat] ,Nil})
					AADD(aLog,{"RB_COD"  ,aDados[nPosCod] ,Nil})
					AADD(aLog,{"RB_NOME" ,aDados[nPosNom] ,Nil})
					AADD(aLog,{"ERRO" 	   ,"CAMPO OBRIGATORIO VAZIO - "+cCampo ,Nil})
					
					lGrava := .F.
					LOOP
				EndIf
			EndIf
			
			// VERIFICAR SE O TAMANHO DO CAMPO ?MAIOR
			If u_VldTamCpo(cTipo, aDados[W], nTamanho, nDecimal)
				cErro := cLinha+";CONTEUDO DO CAMPO MAIOR QUE O ESPERADO - "+cCampo
				AADD( aErros, cErro )
				
				AADD(aLog,{"RB_MAT"  ,aDados[nPosMat] ,Nil})
				AADD(aLog,{"RB_COD"  ,aDados[nPosCod] ,Nil})
				AADD(aLog,{"RB_NOME" ,aDados[nPosNom] ,Nil})
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
				If aCampos[W] == "RB_SEXO"	// Pertence("MF")
					If aDados[W] <> "M" .AND. aDados[W] <> "F"
						cErro := cLinha+";O CONTEUDO DO CAMPO "+aCampos[W]+" NAO PERTENCE AO RANGE 'MF' - "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RB_MAT"  ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RB_COD"  ,aDados[nPosCod] ,Nil})
						AADD(aLog,{"RB_NOME" ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CONTEUDO DO CAMPO "+aCampos[W]+" NAO PERTENCE AO RANGE 'MF' - "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				If aCampos[W] == "RB_GRAUPAR"	// Pertence('CFEPO')
					If aDados[W] <> "C" .AND. aDados[W] <> "F" .AND. aDados[W] <> "E" .AND. aDados[W] <> "P" .AND. aDados[W] <> "O"
						cErro := cLinha+";O CONTEUDO DO CAMPO "+aCampos[W]+" NAO PERTENCE AO RANGE 'CFEPO' - "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RB_MAT"  ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RB_COD"  ,aDados[nPosCod] ,Nil})
						AADD(aLog,{"RB_NOME" ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CONTEUDO DO CAMPO "+aCampos[W]+" NAO PERTENCE AO RANGE 'CFEPO' - "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				If aCampos[W] == "RB_TIPIR"	// Pertence('1234')
					If aDados[W] <> "1" .AND. aDados[W] <> "2" .AND. aDados[W] <> "3" .AND. aDados[W] <> "4"
						cErro := cLinha+";O CONTEUDO DO CAMPO "+aCampos[W]+" NAO PERTENCE AO RANGE '1234' - "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RB_MAT"  ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RB_COD"  ,aDados[nPosCod] ,Nil})
						AADD(aLog,{"RB_NOME" ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CONTEUDO DO CAMPO "+aCampos[W]+" NAO PERTENCE AO RANGE '1234' - "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				If aCampos[W] == "RB_TIPSF"	// Pertence('123')
					If aDados[W] <> "1" .AND. aDados[W] <> "2" .AND. aDados[W] <> "3"
						cErro := cLinha+";O CONTEUDO DO CAMPO "+aCampos[W]+" NAO PERTENCE AO RANGE '1234' - "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RB_MAT"  ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RB_COD"  ,aDados[nPosCod] ,Nil})
						AADD(aLog,{"RB_NOME" ,aDados[nPosNom] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CONTEUDO DO CAMPO "+aCampos[W]+" NAO PERTENCE AO RANGE '1234' - "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
			EndIf
		Next W
    Else
		cErro := cLinha+";REGISTRO JA EXISTENTE."
		AADD( aErros, cErro )
		
		AADD(aLog,{"RB_MAT"  ,aDados[nPosMat] ,Nil})
		AADD(aLog,{"RB_COD"  ,aDados[nPosCod] ,Nil})
		AADD(aLog,{"RB_NOME" ,aDados[nPosNom] ,Nil})
		AADD(aLog,{"ERRO" 	   ,"REGISTRO JA EXISTENTE." ,Nil})
		
		lGrava := .F.
	EndIf
	
    If lGrava
		u_GRVDADOS("SRB", aCampos, aDados, nPosFil)
	Else
		lGrava := .T.
	EndIf
	
	FT_FSKIP()
	nCont++
EndDo
END TRANSACTION

If lRet //Thais Paiva - Compatibiliza??o P27
	FT_FUSE()

	aDados := {}
	dbSelectArea("SRB")

	TMPSRB->( dbSetOrder(1) )
	TMPSRB->( dbGoTop() )
	While TMPSRB->( !EOF() )
		SRB->(Reclock("SRB",.T.))
		For X:=1 To LEN(aCampos)
			If nPosFil = 0 .OR. X = nPosFil
				SRB->&(aCampos[X]) := xFilial("SRB")
			EndIf
			If aCampos[X] = aCampos[nPosNac] .or. aCampos[X] = aCampos[nPosDep]
	/*			If !EMPTY(ALLTRIM(Posicione("SX3", 2, aCampos[nPosNac], "X3_CAMPO")))
					SRB->&(aCampos[X]) := TMPSRB->&(aCampos[X])
				EndIf
				If !EMPTY(ALLTRIM(Posicione("SX3", 2, aCampos[nPosDep], "X3_CAMPO")))
					SRB->&(aCampos[X]) := TMPSRB->&(aCampos[X])
				EndIf
	*/
			Else
				SRB->&(aCampos[X]) := TMPSRB->&(aCampos[X])
			EndIF
		Next X
		SRB->(Msunlock())
		
		TMPSRB->( dbSkip() )
	EndDo
	TMPSRB->( dbCloseArea() )
	oTempTable:Delete() //Thais Paiva - 04/12/2020
	FErase(cArqTmp + GetDbExtension())  // Deletando o arquivo Temporario
	FErase(cArqTmp + OrdBagExt())       // Deletando índice Temporario

	Aviso("Finalizado","Leitura do arquivo realizada com sucesso",{"Fechar"})
EndIf //Thais Paiva - Compatibiliza??o P27

RestArea(aArea)

Return lRet //.T. Thais Paiva - Compatibiliza??o P27