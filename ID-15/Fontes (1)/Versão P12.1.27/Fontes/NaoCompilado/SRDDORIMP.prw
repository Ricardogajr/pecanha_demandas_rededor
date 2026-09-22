#include "rwmake.ch"
#include "totvs.ch"
#xtranslate NToS([<n,...>])=>LTrim(Str([<n>]))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออออออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑ?Programa  ?SRDDORIMP                              ?Data ?13/09/2015 บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑ?Autor     ?Microsiga                                                  บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Descricao ?Rotina para a importa็ใo dos Acumulados do template CSV    บฑ?
ฑฑ?          ?para o ERP Protheus.                                       บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Sintaxe   ?IMPRTSRD()                                                 บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Retorno   ?nil                                                        บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Uso       ?Rede Dor Sใo Luiz                                          บฑ?
ฑฑศอออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function SRDDORIMP()
    Local cSvFilAnt:=cFilAnt
	Local lExact:=Set(_SET_EXACT,"ON")
	IMPRTSRD()
	Set(_SET_EXACT,if(lExact,"ON","OFF"))
	cFilAnt:=cSvFilAnt
Return(NIL)

Static Function IMPRTSRD()

Local oGroup
Local oRadio
Local nRadio    := 1
Local aRet		:= {}                                
Local aArea		:= GetArea()
Local cArq      := ""
// ORIGRINAL
//Local cOrigem	:= UPPER(GetSrvProfString("ROOTPATH",""))+"\MIGRACAO\IMPORTAR\"
//Local cDestino	:= UPPER(GetSrvProfString("ROOTPATH",""))+"\MIGRACAO\IMPORTADO\"
// TESTES
//Local cOrigem	:= GETMV("MV_PATH")+"IMPORTAR\"
//Local cDestino	:= GETMV("MV_PATH")+"IMPORTADO\"

Local cOrigem	:= "C:\M&A\IMPORTAR\"
Local cDestino	:= "C:\M&A\IMPORTADO\"

Local lConv     := .F.

Private aErros  := {}
Private aLog    := {}

Public cArquivo := Space(150)
Public lOk      := .F.
Public bOk      := { || If(u_ValidaDir(cArquivo), (lOk:=.T.,oDlg:End()) ,) }
Public bCancel  := { || lOk:=.F.,oDlg:End() }
Public lEnd     := .F.

Define MsDialog oDlg Title "Importa็ใo dos Acumulados" From 08,15 To 18,080 Of GetWndDefault()
      
//@ 18,16  Say 	"Diretorio:" 	Size 050,10 Of oDlg Pixel
//@ 18,40  MsGet 	cArquivo 		Size 230,08 Of oDlg Pixel
//@ 18,275 Button "? 			Size 010,10 Action Eval({|| cArquivo:=u_SelectFile() }) Of oDlg Pixel
//@ 35,55  GROUP oGroup TO 70,117 PROMPT " Gera็ใo de Arquivo " OF oDlg COLOR 0, 16777215 PIXEL
//@ 49,70  RADIO oRadio VAR nRadio ITEMS "EXCEL","TXT" SIZE 040, 010 OF oDlg COLOR 0, 16777215 PIXEL

     
@ 050,028  Say 	"Selecione o Arquivo:" 	Size 060,015 Of oDlg Pixel
@ 050,082  MsGet 	cArquivo 		    Size 122,008 Of oDlg Pixel
@ 050,210  Button "?"			        Size 010,010 Action Eval({|| cArquivo:=u_SelectFile() }) Of oDlg Pixel

Activate MsDialog oDlg Centered On Init (EnchoiceBar(oDlg,bOk,bCancel))

If lOk
	oProcess:=MsNewProcess():New( { |lEnd| lConv:=u_ImpSrdCSV(cArquivo, @lEnd)}, "Importa็ใo dos Acumulados", "Processando arquivo dos Acumulados", .T. )
	oProcess:Activate()	
	If lConv
		cArq := SUBSTR(cArquivo,RAT("\", cArquivo)+1,LEN(cArquivo))
		// mover o arquivo lido da pasta IMPORTAR para a pasra IMPORTADO
		If FRENAME ( cOrigem+cArq , cDestino+cArq ) == -1
			MsgInfo("Nใo foi possํvel mover o arquivo da pasta IMPORTAR para a pasta IMPORTADO")
		EndIf
		// cria arquivo de LOG
		u_CRIARLOG(aLog, SUBSTR(cArq,1,LEN(cArq)-4), 6)
		If nRadio == 1
			// gera arquivo excel 
			u_GeraExcel(aErros, SUBSTR(cArq,1,LEN(cArq)-4))
		Else
			// gera arquivo txt
			oProcess1:=MsNewProcess():New( { |lEnd| u_GeraTxt(aErros, SUBSTR(cArq,1,LEN(cArq)-4))}, "Importa็ใo dos Acumulados", "Gerando arquivo TXT", .F. )
			oProcess1:Activate()
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออออออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑ?Programa  ?IMPSRDCSV                              ?Data ?20/07/2015 บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑ?Autor     ?Microsiga                                                  บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Descricao ?Rotina para a importa็ใo dos Acumulados do template CSV    บฑ?
ฑฑ?          ?para o ERP Protheus.                                       บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Sintaxe   ?IMPSRDCSV(cArq, lEnd)                                      บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Retorno   ?Logico                                                     บฑ?
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ?Uso       ?Rede Dor Sใo Luiz                                          บฑ?
ฑฑศอออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function ImpSrdCSV(cArq, lEnd)

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
Local nLinTit   := 2  // Total de linhas do Cabe็alho

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

// Tratamento do cabe็alho
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
		
		If u_VERTEMPL(aCampos[1], "SRD", "RD")
			Return .F.
		EndIf
		
		nPosFil := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RD_FILIAL" })
		nPosMat := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RD_MAT" })
		nPosDat := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RD_DATARQ" })
		nPosPd  := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RD_PD" })
		nPosSem := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RD_SEMANA" })
		nPosSeq := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RD_SEQ" })
		nPosCc  := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RD_CC" })
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
		MsgInfo("Importa็ใo cancelada!","Fim")
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
	
	//aDados := STRTOKARR(cLinha,";")   // A fun็ใo SEPARA e a fun็ใo STRTOKARR, converte uma string em um array, o SEPARA converte os espa็os em branco 
	aDados := SEPARA(UPPER(cLinha),";",.T.)
	
	If u_VldChave("SRD", aCampos, aDados)
		For W:=1 To LEN(aCampos)
			
			/*
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ?
			//?Rotina utilizada para carregar os valores do campo da X3. ?
			//?cCampo    := ALLTRIM(SX3->X3_CAMPO)                       ?
			//?lObrigat  := X3OBRIGAT(SX3->X3_CAMPO)                     ?
			//?cTipo     := SX3->X3_TIPO                                 ?
			//?nTamanho  := SX3->X3_TAMANHO                              ?
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ?
			*/
			u_ConfCpo(aCampos[W], W)
			
			// VERIFICAR SE O CAMPOS OBROGATORIO ESTA PREENCHIDO
			If lObrigat
				If aCampos[W] <> "RD_SEMANA"
					If EMPTY(aDados[W]) .OR. ALLTRIM(aDados[W]) == ""
						cErro := cLinha+";CAMPO OBRIGATORIO VAZIO - "+cCampo
						AADD( aErros, cErro )					
						
						AADD(aLog,{"RD_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RD_PD"     ,aDados[nPosPd] ,Nil})
						AADD(aLog,{"RD_SEMANA" ,aDados[nPosSem] ,Nil})
						AADD(aLog,{"RD_SEQ"    ,aDados[nPosSeq] ,Nil})
						AADD(aLog,{"RD_CC"     ,aDados[nPosCc] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"CAMPO OBRIGATORIO VAZIO - "+cCampo ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
			EndIf
			
			// VERIFICAR SE O TAMANHO DO CAMPO ?MAIOR
			If u_VldTamCpo(cTipo, aDados[W], nTamanho, nDecimal)
				cErro := cLinha+";CONTEUDO DO CAMPO MAIOR QUE O ESPERADO - "+cCampo
				AADD( aErros, cErro )
				
				AADD(aLog,{"RD_MAT"    ,aDados[nPosMat] ,Nil})
				AADD(aLog,{"RD_PD"     ,aDados[nPosPd] ,Nil})
				AADD(aLog,{"RD_SEMANA" ,aDados[nPosSem] ,Nil})
				AADD(aLog,{"RD_SEQ"    ,aDados[nPosSeq] ,Nil})
				AADD(aLog,{"RD_CC"     ,aDados[nPosCc] ,Nil})
				AADD(aLog,{"ERRO" 	   ,"CONTEUDO DO CAMPO MAIOR QUE O ESPERADO - "+cCampo ,Nil})
				
				lGrava := .F.
				LOOP
			EndIf
			
			// CONVERTER OS DADOS PARA INSERวรO NO BANCO DE DADOS
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
			
			// VALIDAวรO DOS CAMPOS OBRIGATORIOS
			If lObrigat
				If aCampos[W] == "RD_MAT" 	// EXISTCPO("SRA")
					If EMPTY(POSICIONE("SRA",1,xFilial("SRA")+aDados[W],"RA_MAT")) // !EXISTCPO("SRA", aDados[W])
						cErro := cLinha+";MATRICULA NAO EXISTENTE - "+cCampo+" = "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RD_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RD_PD"     ,aDados[nPosPd] ,Nil})
						AADD(aLog,{"RD_SEMANA" ,aDados[nPosSem] ,Nil})
						AADD(aLog,{"RD_SEQ"    ,aDados[nPosSeq] ,Nil})
						AADD(aLog,{"RD_CC"     ,aDados[nPosCc] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"MATRICULA NAO EXISTENTE - "+cCampo+" = "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				/*
				If aCampos[W] == "RD_PD"	//	ADescPd("RD_DESCPD") .and. fIncSrd() .and. fPosSRD("RD_PD",.T.)
					// ADescPd("RD_DESCPD") - esta validacao nใo sera executada pois ela ?usada apenas para retorna a descri็ใo do campo
					// fPosSRD("RD_PD",.T.) - Posicionar Cursor em aCols de Acordo com o Tipo da Verba
					// fIncSrd() - Carregar Incidencias das Verbas no SRD
				EndIf
				*/
				If aCampos[W] == "RD_TIPO1"	// Pertence("HVD") .and. fPosSrd("RD_TIPO1",.T.)
					// fPosSRD("RD_TIPO1",.T.) - Posicionar Cursor em aCols de Acordo com o Tipo da Verba
					If aDados[W] <> "H" .AND. aDados[W] <> "V" .AND. aDados[W] <> "D"
						cErro := cLinha+";O CONTEUDO DO CAMPO "+aCampos[W]+" NAO PERTENCE AO RANGE 'HVD' - "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RD_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RD_PD"     ,aDados[nPosPd] ,Nil})
						AADD(aLog,{"RD_SEMANA" ,aDados[nPosSem] ,Nil})
						AADD(aLog,{"RD_SEQ"    ,aDados[nPosSeq] ,Nil})
						AADD(aLog,{"RD_CC"     ,aDados[nPosCc] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CONTEUDO DO CAMPO "+aCampos[W]+" NAO PERTENCE AO RANGE 'HVD' - "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				If aCampos[W] == "RD_VALOR" .OR. aCampos[W] == "RD_HORAS"	// POSITIVO()
					If aDados[W] < 0	// !POSITIVO(aDados[W])
						cErro := cLinha+";O CONTEUDO DO CAMPO "+aCampos[W]+" NAO EH POSITIVO - "+STR(aDados[W])
						AADD( aErros, cErro )
						
						AADD(aLog,{"RD_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RD_PD"     ,aDados[nPosPd] ,Nil})
						AADD(aLog,{"RD_SEMANA" ,aDados[nPosSem] ,Nil})
						AADD(aLog,{"RD_SEQ"    ,aDados[nPosSeq] ,Nil})
						AADD(aLog,{"RD_CC"     ,aDados[nPosCc] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CONTEUDO DO CAMPO "+aCampos[W]+" NAO EH POSITIVO - "+STR(aDados[W]) ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				If aCampos[W] == "RD_CC"	// CTB105CC() - FONTE - CTB105.PRW
					If EMPTY(POSICIONE("CTT",1,xFilial("CTT")+aDados[W],"CTT_CUSTO")) // !CTB105CC(aDados[W])
						cErro := cLinha+";CONTA CONTABIL INVALIDA - "+cCampo+" = "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RD_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RD_PD"     ,aDados[nPosPd] ,Nil})
						AADD(aLog,{"RD_SEMANA" ,aDados[nPosSem] ,Nil})
						AADD(aLog,{"RD_SEQ"    ,aDados[nPosSeq] ,Nil})
						AADD(aLog,{"RD_CC"     ,aDados[nPosCc] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"CONTA CONTABIL INVALIDA - "+cCampo+" = "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
				If aCampos[W] == "RD_STATUS"	// Pertence("AMI ")
					If aDados[W] <> "A" .AND. aDados[W] <> "M" .AND. aDados[W] <> "I" .AND. aDados[W] <> " "
						cErro := cLinha+";O CONTEUDO DO CAMPO "+aCampos[W]+" NAO PERTENCE AO RANGE 'AMI ' - "+aDados[W]
						AADD( aErros, cErro )
						
						AADD(aLog,{"RD_MAT"    ,aDados[nPosMat] ,Nil})
						AADD(aLog,{"RD_PD"     ,aDados[nPosPd] ,Nil})
						AADD(aLog,{"RD_SEMANA" ,aDados[nPosSem] ,Nil})
						AADD(aLog,{"RD_SEQ"    ,aDados[nPosSeq] ,Nil})
						AADD(aLog,{"RD_CC"     ,aDados[nPosCc] ,Nil})
						AADD(aLog,{"ERRO" 	   ,"O CONTEUDO DO CAMPO "+aCampos[W]+" NAO PERTENCE AO RANGE 'AMI ' - "+aDados[W] ,Nil})
						
						lGrava := .F.
						LOOP
					EndIf
				EndIf
			EndIf
		Next W
    Else
		cErro := cLinha+";REGISTRO JA EXISTENTE."
		AADD( aErros, cErro )
		
		AADD(aLog,{"RD_MAT"    ,aDados[nPosMat] ,Nil})
		AADD(aLog,{"RD_PD"     ,aDados[nPosPd] ,Nil})
		AADD(aLog,{"RD_SEMANA" ,aDados[nPosSem] ,Nil})
		AADD(aLog,{"RD_SEQ"    ,aDados[nPosSeq] ,Nil})
		AADD(aLog,{"RD_CC"     ,aDados[nPosCc] ,Nil})
		AADD(aLog,{"ERRO" 	   ,"REGISTRO JA EXISTENTE." ,Nil})
		
		lGrava := .F.
	EndIf
	
    If lGrava
		u_GRVDADOS("SRD", aCampos, aDados, nPosFil)
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