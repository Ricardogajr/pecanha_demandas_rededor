#Include 'Protheus.ch'
#INCLUDE "TopConn.Ch"
#INCLUDE "FONT.CH"      
#INCLUDE "FILEIO.CH"   
#Include "TCBrowse.ch"

/*
{Protheus.doc} TEWBTYI2
Importação de Planilha de Lnaçamentos Contábeis do Protheus 12.
@Author     Thiago Pereira
@Since      24/02/2021     
@Version    P12
@Return
*/       

User Function TEWBTYI2
//IMPCT2
             
Private cDiretor    := ""
Private cDirProc    := ""
Private aFiles      := {}
Private nNumFiles   := 0
Private Titulo      := ""
Private cBuffer     := ""
Private cTpA        := ""
Private _MV_PAR01
Private _MV_PAR02
Private _MV_PAR03
Private nHdl
Private cEmpAtual := SM0->M0_CODIGO      // Empresa atual
Private cFilAtual := SM0->M0_CODFIL      // Filial atual
Private nConnect                         // Variavel com Numero do Ambiente Conectado
Private cArqTRE                          // Nome do Arquivo Temporario Criado para gravar erros durante o processo
Private cAmbiente := "" //GetMv("MV_XAMBIEN") // Nome do Ambiente Logado
Private cIntegra  := ""


PRIVATE LGO := .T.
private Erro := 0
PswOrder(1)     
PswSeek(__cUserID, .T. )
aDUsu := PswRet(1)

_MV_PAR01 := GetMV("MV_XDIRCTB")         
_MV_PAR02 := GetMV("MV_XMOSTLC")
_MV_PAR03 := GetMV("MV_XAGLULC")
    
cDiretor    := ALLTRIM(_MV_PAR01)
_cDiretorio := UPPER(cDiretor) // diretorio onde estao os arquivos

Private oLeTxt
Private cArquiv1    := ""
Private cArquiv2    := ""
Private cArquiv     := ""
Private cCodigo     := ""
Private nCodigo     := 1     
Private aLog        := {}

IF !EMPTY(_CDIRETORIO)
	LGO := SelArq() // 
ELSE
	ALERT("PARAMETRO MV_XDIRCTB QUE INDICA O DIRETORIO DOS ARQUIVOS ESTA EM BRANCO")
ENDIF


retuRN

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³SelArq      º Autor ³THIAGO PEREIRA º Data ³  27/03/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao responsavel pela carga do vetor contendo os arquivosº±±
±±º          ³ TXT encontrados na pasta informada no parametro.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SelArq()

Local cMascara := "*.TXT"  //DEFINE O TIPO DE ARQUIVO QUE SERA IMPORTADO - FAZ UM FILTRO
Local i        := 1

Local cDtHr 	:= DtoS(dDataBase)+"-"+Substr(time(),1,2)+"-"+Substr(time(),4,2)+"-"+Substr(time(),7,2)
Local cPath		:= 'C:\LOG_IMPORTACAO\' 
Local cTipoLog	:= "Import_"
Local cNomeLog	:=	"CTB"+cTipoLog+cDtHr+"_Log.txt"
Local cArq		:=	cPath+cNomeLog              
Local _cUsuario := UsrRetName(RetCodUsr())

Private cArqTxt:= ""
Private cEOL   := "CHR(13)+CHR(10)"
Private nInc    := 0
Private nAlt    := 0
Private lAborta := .F. // Variavel responsavel pelo encerramento do processamento caso encontre alguma inconsistencia em um arquivo TXT

cDiretor       := Iif(SubStr(cDiretor,Len(cDiretor),1) = "\",cDiretor,cDiretor+"\")
cDirProc       := cDiretor+"Processados\"          // Pasta para gravar os arquivos processados com sucesso
aFiles         := {}                               // Vetor com os arquivos que serao integrados

_cDiretorio    := UPPER(cDiretor)
_MV_PAR01      := _cDiretorio

AEVAL( DIRECTORY(cDiretor+cMascara), {|aFile| aAdd(aFiles, aFile[1])} )

// Processar Todos os Arquivos .TXT da Pasta Selecionado
If Empty(aFiles)
	Alert("Nenhum Arquivo de Integração (.TXT) Encontrado na Pasta. ")
	Return .F.
Endif


// Criar Temporarios para gravar erros de inconsistencia e contabilizacoes
LGO := .t. 


nNumFiles := Len(aFiles)  // Numero de arquivos encontrados na pasta

For nx:=1 To nNumFiles     

	//ï#####################################¿½Ä¿
	//ï¿½Inicia Log                            ï¿½
	//ï#######################################¿½
    
	AAdd(aLog, Replicate( '=', 80 ) )
	AAdd(aLog, 'INICIANDO O LOG - I M P O R T A C A O   D E   D A D O S - LANCAMENTOS CONTABEIS ' )
	AAdd(aLog, Replicate( '-', 80 ) )
	AAdd(aLog, 'DATABASE...........: ' + DtoC( dDataBase ) )
	AAdd(aLog, 'HORA...............: ' + Time() )
	AAdd(aLog, 'EMPRESA / FILIAL...: ' + SM0->M0_CODIGO + '/' + SM0->M0_CODFIL )
	AAdd(aLog, 'NOME EMPRESA.......: ' + Capital( Trim( SM0->M0_NOME ) ) )
	AAdd(aLog, 'NOME FILIAL........: ' + Capital( Trim( SM0->M0_FILIAL ) ) )
	AAdd(aLog, 'USUÁRIO............: ' + _cUsuario )

	
	If nx > nNumFiles .or. lAborta    // Serao processados todos os arquivos encontrados na pasta
		RETURN .F.                           // Caso encontre alguma inconsistencia aborta o processamento
	Endif
	
	//
	if lGo
		cArquiv1 := cDiretor+aFiles[nx]      // Caminho + Arquivo txt que sera processado
		cArquiv2 := cDirProc+aFiles[nx]      // Caminho + Arquivo txt onde sera gravado apos processado
		nHdl     := fOpen(cArquiv1,0) 		//  FOpen(nHandle,0)

		_cArq := aFiles[nx]
		nPos1 := AT(".",_cArq)

		If !FILE(cArquiv1) // TENTA LOCALIZAR O ARQUIVO NA PASTA
			//MsgAlert("O arquivo de importação de nome " + cArquiv1 + " não foi encontrado.","Atenção!")
			lgo := .f.
		Endif
		
		If nHdl == -1 .and. lGo
			//MsgAlert("O arquivo de nome "+cArquiv1+" nao pode ser aberto! Verifique os parametros.","Atenção!")
			lGo := .F.
		Endif

		IF LGO   
			
			AAdd(aLog, '' )
			AAdd(aLog, 'ARQUIVO IMPORT.....: ' + cArquiv1 )
			AAdd(aLog, Replicate( ':', 80 ) )
			AAdd(aLog, '' )

			AAdd(aLog, "Import = INICIO - Data "+DtoC(dDataBase)+ " as "+Time() )  

			LGO := Processa({||ImpCT212(cArquiv1) }, "Importando...")
			// FRename(UPPER(cArquiv1), STRTRAN(UPPER(cArquiv1),".TXT",".IMP"))

		ENDIF			
		// Encontrando Inconsistencia em Um Arquivo aborta o processamento e imprime relatorio de inconsistencias
	endif
	LGO := .T. 
	
Next nx


   //ï################################################¿½ï¿½
	//ï¿½Finaliza arquivo de Log                         ï¿½
	//ï################################################¿½ï¿½

	nHdl1:=fCreate(cArq)

	If nHdl1 == -1
		//MsgAlert("O arquivo  "+cArq+" nao pode ser criado!","Atencao!")
		fClose(nHdl1)
		fErase(cArq)
	else
		cLin := ""
		For nCont:=1 to Len(aLog)
    	
			cLin += aLog[nCont] + CHR(13)+CHR(10)

			If fWrite(nHdl1,cLin,Len(cLin)) != Len(cLin)
				fClose(nHdl1)
				fErase(cArq)
				cLin:=""
				RestArea(aArea)
			EndIf

			cLin:=""
   		Next

		fClose(nHdl1)
		MsgInfo("Verifique arquivo de log criado em:"+space(79)+cArq,"Arquivo")
   	endif 	


Return lGo 
    


/*
{Protheus.doc} ImpCT212
Importação de Planilha de Lnaçamentos Contábeis do Protheus 12.
@Author     Ramon Teodoro e Silva
@Since      26/10/2016     
@Version    P12.7
@Return
*/       

Static Function ImpCT212(cArqImpor)  

Local aArea      := GetArea() 
Local aAreaSM0   := SM0->(GetArea())
Local aAreaCT2   := CT2->(GetArea())    
Local cBuffer	 := ""
Local aInfo		 := {}
Local nXPos		 := ""
Local aTmpDados	 := {}
Local lGrv   	 := .F.
Local cQuery	 := ""
Local lRet		 := .T.
Local aHeader    := {}
Local cEmpFil    := ""  
Local aEmpFil    := {}
Local cNomeCampo := ""
Local nTotRec    := 0
Local nContL     := 0   
Local nG         := 0   
Local nP         := 0
Local aEstru     := {}  
Local nPosCCC    := 0
Local nPosCCD    := 0

Private cArquiv  := cDiretor
Private aDados 	 := {}

nContL := 0 


FT_FUSE(cArqImpor)

FT_FGOTOP()

cBuffer  := FT_FREADLN()
nTotRec  := FT_FLASTREC()
ProcRegua(nTotRec)

Begin Transaction

FT_FGOTOP()        

While !FT_FEOF() 	
	
	nContL  += 1
    IncProc("Analisando registro " + cValToChar(nContL) + " de " + cValToChar(nTotRec) + "...")
		
	cBuffer := FT_FREADLN()
	cBuffer := NoAcento(cBuffer)
	aTmpDados := {}
	
	If Empty(cBuffer)
		Exit
	Endif  
	
		nXPos := AT(";",cBuffer)
	  	If !Empty(SubStr(cBuffer , 1, nXPos-1 )) 
			
			If Alltrim(SubStr( SubStr(cBuffer , 1, nXPos-1), 1, 3)) <> "CT2"
				
				While nXPos <> 0
					aInfo := Alltrim(SubStr(cBuffer , 1, nXPos-1 ))                          
					aAdd( aTmpDados , aInfo )
					cBuffer := SubStr(cBuffer , nXPos+1, Len(cBuffer)-nXPos)
					nXPos := AT(";",cBuffer)
				End
				
				If Len(cBuffer) > 0 .Or. (Len(aHeader) - Len(aTmpDados) == 1)
					aInfo := Alltrim(SubStr(cBuffer , 1, Len(cBuffer) ))
					aAdd( aTmpDados , aInfo )
				EndIf
				
				aAdd( aDados, aTmpDados )
								
				lGrv := .T. 
			Else
				
				While nXPos <> 0
					Aadd(aHeader, Alltrim(SubStr(cBuffer , 1, nXPos-1 )))
					cBuffer := SubStr(cBuffer , nXPos+1, Len(cBuffer)-nXPos)
					nXPos   := AT(";",cBuffer)
				End
				
				If Len(cBuffer) > 0
					Aadd(aHeader, Alltrim(SubStr(cBuffer , 1, Len(cBuffer))))
				EndIf
			   
			  	lGrv := .F. 
			EndIf
		Else
		  	lGrv := .F. 
		EndIf

   	FT_FSKIP()
End          

End Transaction

lretorno := FT_FUSE()

If lGrv      
	fClose(nHdl)
	Copy File &cArqImpor To &cArquiv2
	FRename(UPPER(cArquiv2), STRTRAN(UPPER(cArquiv2),".TXT",".IMP"))
	lretorno := fErase(cArqImpor)
	if lretorno == -1
		aadd(alog, ("Falha ao excluir arquivo ","FERROR "+cValToChar(fError())))
	endif  

	cEmpFil := ""
	
	nPCC := aScan(aHeader,{|x| AllTrim(x)== "CT2_CCC"})        
	nPCD := aScan(aHeader,{|x| AllTrim(x)== "CT2_CCD"})        	
	
	oTempTable := FWTemporaryTable():New("TRB") //cArquivo := CriaTrab(,.F.)  
	aEstru := CT2->(DbStruct())
	Aadd(aEstru,{ "CT2_EMP", "C", 2, 0 })
	oTemptable:SetFields( aEstru ) //DbCreate(cArquivo,aEstru) 
	oTempTable:AddIndex( '01' , { "CT2_EMP","CT2_FILIAL" } )//DbUseArea( .T.,,cArquivo,"TRB",.F.,.F.)
   	oTempTable:Create() //IndRegua("TRB",cArquivo,"CT2_EMP+CT2_FILIAL")  
     
	TRB->(DbSetOrder(1))      
	
	For nG := 1 to Len(aDados)
	    
	    IncProc( "Montando estrutura para gravação..." )
	    
		RecLock("TRB",.T.) 
	
		For nI := 1 To Len(aEstru)  
			   
			nP := aScan(aHeader,{|x| AllTrim(x)== Alltrim(aEstru[nI][1])}) 
			
			If nP > 0

				If aEstru[nI][2] == "C" 
						&("TRB->" + aEstru[nI][1]) := upper(aDados[nG][nP])				
				ElseIf aEstru[nI][2] == "D"
			   		&("TRB->" + aEstru[nI][1]) := CtoD(aDados[nG][nP])
				ElseIf aEstru[nI][2] == "N"
			  		&("TRB->" + aEstru[nI][1]) := Val( StrTran(StrTran(aDados[nG][nP], ".", "" ), ",", "."))
				EndIf		
			EndIf
		
		Next nI
	
		TRB->(MsUnLock())
		
	Next nG	  
	
	DbSelectArea("TRB")
	TRB->(DbSetOrder(1))  
	TRB->(DbGoTop())

	DbSelectArea("CT2")
	DbSetOrder(1)  


	While !TRB->(Eof())  
			
	 	While !CT2->(Eof())
	 	
	 		If CT2->(DbSeek(TRB->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD)))
	 	 		TRB->CT2_DOC := StrZero( Val(CT2->CT2_DOC)+1, TamSX3("CT2_DOC")[1] ) //PADR( Alltrim(Str(Val(CT2->CT2_DOC)+1)),TamSX3("CT2_DOC")[1] )
	 	    Else
	 	    	Exit
	 	    EndIf
	 	
	 		CT2->(DbSkip())
	 	End
	 	
	 	RecLock("CT2",.T.) 
	 	
		
			For nI := 1 To CT2->(FCount())  
			  	    
				cNomeCampo := CT2->(FieldName(nI))

				IF UPPER(Alltrim(cNomeCampo)) == "CT2_ORIGEM"
					CT2->CT2_ORIGEM := "CARGAMA"
				ELSEIF UPPER(ALLTRIM(cNomeCampo)) == "CT2_MANUAL"
					CT2->CT2_MANUAL := "1" 
				ELSE   		
					CT2->(FieldPut(nI, &("TRB->" + cNomeCampo) ))
	   			ENDIF

			Next nI
		
		CT2->(MsUnLock())

	 	aadd(alog, "Registro INCLUIDO: " + TRB->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD))
		
		TRB->(DbSkip())
	End 
	
	EmpOpenFile("CT2","CT2",1,.F.,cEmpFil,"E")   
			
	
	TRB->(DbCloseArea())  
	oTempTable:Delete()
Else

	mSGaLERT("Não foi possível realizar a importação, verifique os dados do arquivo")  
		
EndIf

RestArea(aArea)
RestArea(aAreaCT2)   
RestArea(aAreaSM0)

Return lRet
              

