#include "protheus.ch"
#Include "Fileio.ch"
#INCLUDE "Rwmake.CH"
#INCLUDE "Topconn.ch"
#INCLUDE "Ap5mail.ch"
//#INCLUDE "Directry.ch"                                                                                 
#INCLUDE "TbiConn.ch"
#DEFINE c_ent chr(13)+chr(10)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RDORLDLC บ Autor ณ THIAGO PEREIRAบ Data ณ  27/03/2008 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Integracao do Protheus x WPD via Arquivos TXT.             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Rede Dor     VERSAO DO FONTE RDOR009E                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function RDOR009E
// CARGAS   


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
Private _nTotalTit:= 0


PRIVATE LGO := .T.
private Erro := 0

chkfile('ZZ1')
chkfile('ZZ2')
chkfile('ZZ3')

PswOrder(1)     
PswSeek(__cUserID, .T. )
aDUsu := PswRet(1)

_MV_PAR01 := GetMV("MV_XCARGA")         
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
	ALERT("PARAMETRO MV_XCARGA QUE INDICA O DIRETORIO DOS ARQUIVOS ESTA EM BRANCO")
ENDIF

	

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบFuno    ณSelArq      บ Autor ณTHIAGO PEREIRA บ Data ณ  27/03/08 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescrio ณ Funcao responsavel pela carga do vetor contendo os arquivosบฑฑ
ฑฑบ          ณ TXT encontrados na pasta informada no parametro.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function SelArq()

Local cMascara := "*.TXT"  //DEFINE O TIPO DE ARQUIVO QUE SERA IMPORTADO - FAZ UM FILTRO
Local i        := 1
Local nCont
Local cDtHr 	:= DtoS(dDataBase)+"-"+Substr(time(),1,2)+"-"+Substr(time(),4,2)+"-"+Substr(time(),7,2)
Local cPath		:= 'C:\LOG_CARGAS\' 
Local cTipoLog	:= "CargasDiarias_"
Local cNomeLog	:=	cTipoLog+cDtHr+"_Log.txt"
Local cArq		:=	cPath+cNomeLog              
Local nx

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
	Alert("Nenhum Arquivo de Integra็ใo (.TXT) Encontrado na Pasta. ")
	Return .F.
Endif


// Criar Temporarios para gravar erros de inconsistencia e contabilizacoes
LGO := CriarTMPS(0)


nNumFiles := Len(aFiles)  // Numero de arquivos encontrados na pasta

For nx:=1 To nNumFiles     

	//๏#####################################ฟฝฤฟ
	//๏ฟฝInicia Log                            ๏ฟฝ
	//๏#######################################ฟฝ
    
	AAdd(aLog, Replicate( '=', 80 ) )
	AAdd(aLog, 'INICIANDO O LOG - CARGA DIARIA  D E   D A D O S' )
	AAdd(aLog, Replicate( '-', 80 ) )
	AAdd(aLog, 'DATA...............: ' + DtoC( Date() ) )
	AAdd(aLog, 'HORA...............: ' + Time() )
	AAdd(aLog, 'EMPRESA / FILIAL...: ' + SM0->M0_CODIGO + '/' + SM0->M0_CODFIL )
	AAdd(aLog, 'NOME EMPRESA.......: ' + Capital( Trim( SM0->M0_NOME ) ) )
	AAdd(aLog, 'NOME FILIAL........: ' + Capital( Trim( SM0->M0_FILIAL ) ) )
	AAdd(aLog, 'USUมRIO............: ' + Retname())

	
	If nx > nNumFiles .or. lAborta    // Serao processados todos os arquivos encontrados na pasta
		RETURN .F.                           // Caso encontre alguma inconsistencia aborta o processamento
	Endif

	//
	if lGo
		cArquiv1 := cDiretor+aFiles[nx]      // Caminho + Arquivo txt que sera processado
		cArquiv2 := cDirProc+aFiles[nx]      // Caminho + Arquivo txt onde sera gravado apos processado
		nHdl     := fOpen(cArquiv1,68)

		_cArq := aFiles[nx]
		nPos1 := AT(".",_cArq)

		If !FILE(cArquiv1) // TENTA LOCALIZAR O ARQUIVO NA PASTA
			MsgAlert("O arquivo de importa็ใo de nome " + cArquiv1 + " nใo foi encontrado.","Aten็ใo!")
			lgo := .f.
		Endif
		
		If nHdl == -1 .and. lGo
			MsgAlert("O arquivo de nome "+cArquiv1+" nao pode ser aberto! Verifique os parametros.","Aten็ใo!")
			lGo := .F.
		Endif

		IF LGO   
			
			AAdd(aLog, '' )
			AAdd(aLog, 'ARQUIVO IMPORT.....: ' + cArquiv1 )
			AAdd(aLog, Replicate( ':', 80 ) )
			AAdd(aLog, '' )

			AAdd(aLog, "Import = INICIO - Data "+DtoC(dDataBase)+ " as "+Time() )

			LGO := Processa({||Importar(cArquiv1)}, "Importando arquivo " + cArquiv1 )
		ENDIF			
		// Encontrando Inconsistencia em Um Arquivo aborta o processamento e imprime relatorio de inconsistencias
	endif
	LGO := .T. 

Next nx


   //๏################################################ฟฝ๏ฟฝ
	//๏ฟฝFinaliza arquivo de Log                         ๏ฟฝ
	//๏################################################ฟฝ๏ฟฝ

	nHdl1:=fCreate(cArq)

	If nHdl1 == -1
		MsgAlert("O arquivo  "+cArq+" nao pode ser criado!","Atencao!")
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
		MsgInfo("Verifique arquivo de log criado em:"+space(79)+cArq)
   	endif 	


Return lGo 
    

Static Function Importar(cArqImpor)    



Local aArea      := GetArea() 
Local aAreaSM0   := SM0->(GetArea())

Local cLinha := ""  
Local nLinha := 0
Local aDados := {}
Local nTamLinha := 0
Local nTamArq:= 0   
LOCAL LPAG  := .F.
LOCAL LFOR  := .F.
LOCAL LCTB  := .F.

private _cChave 
Private _cNaturez  

Private aVet1       := {} 
Private aVet2       := {} // VETOR Titulos Provisorios// VETOR Titulos Provisorios
Private aVet3       := {} // VETOR Titulos Provisorios
Private aVet4       := {} // VETOR Titulos Provisorios
Private lTipo3      := .F.
private lTipo4      := .F. 

private	_nTotalLC := 0
private	_cCtaDeb  := ""
PRivate _cHistor  := ""
private _nVlrCont := 0
private	_cCusto   := "" 
private	_cCustCP  := ""
private	lConta    := .F.
private	_nTotalLC := 0 
private	_cCtaDeb := ""



 erros := 0 

//Valida arquivo
If !file(cArqImpor)
   Aviso("Arquivo","Arquivo nใo selecionado ou invalido.",{"Sair"},1)
    Return .F.
Else     
        FT_FUse(cArqImpor)  //abre o arquivo 
        FT_FGOTOP()         //posiciona na primeira linha do arquivo      
        nTamLinha := Len(FT_FREADLN()) //Ve o tamanho da linha
        
        //+---------------------------------------------------------------------+
        //| Verifica quantas linhas tem o arquivo                               |
        //+---------------------------------------------------------------------+
        nLinhas := 100
        
        ProcRegua(nLinhas)

    
        aDados:={} 
		lgo := .T.  
		ncont := 1
        While !FT_FEOF() .and. lGo //Ler todo o arquivo enquanto nใo for o final dele

           IncProc("Analisando registro " + cValToChar(nCont)  + "...")

        
            clinha := FT_FREADLN() 
			cLinha := UPPER(cLinha)
			
			if nCont = 1 .and. Substr(clinha, 1,1) == "6"  
				_nTotalTit:= 0
				lPag := .T. 
				LGO  := .T.        
				CTPA := "6"
				AAdd(aLog, "CARGA DE CONTAS A PAGAR : " + cArqImpor )
			ELSEIF nCont = 1 .and. Substr(clinha, 1,1) == "2"     
				LFOR := .T.
				LGO  := .T.  
				CTPA := Substr(clinha, 1,1) 
				AAdd(aLog, "CARGA DE CADASTRO DE FORNECEDORES/CLIENTES : " + cArqImpor )
			ELSEIF NCONT = 1
				LCTB := .T.   
				LGO := .T.
				AAdd(aLog, "CARGA DE Lan็amentos Contabeis  : " + cArqImpor )
			ELSEIF NCONT > 1
				IF LPAG 
					IF (Substr(clinha, 1,1) == "1" .or. Substr(clinha, 1,1) == "3" .or. substr(cLinha,1,1) == "4" )
						lGo := ImpContasPag(nCont, cLinha)
						lGo := .T.             
					else
						_cOcorrencia := "TIPO DE REGISTRO INVALIDO P/ CONTAS A PAGAR."       
						u_Gravar_erro(NcONT,1,1,_cOcorrencia,cArqImpor,"",Substr(clinha, 1,1),.t.)
						AtuLog(_cOcorrencia,aLog,NcONT)
						lGo := .T.
					ENDIF 
				ELSEIF LFOR          
					If Substr(clinha, 1,1) == "1" .OR. Substr(clinha, 1,1) == "2"  
							CTPA := Substr(clinha, 1,1) 
							lGo := ImpCAD(nCont, cLinha)
							lGo := .T. 
					ELSE					
						erro++
						_cOcorrencia := "TIPO DE REGISTRO DIFERENTE DE '1 OU 2 ' INTEGRACAO DE CLIENTES/FORNECEDORES"   
						U_Gravar_erro(NCONT,1,1,_cOcorrencia,cArquiv1,cTpA,Substr(clinha, 1,1),.T.)//    
						LGO := .T.
						AtuLog(_cOcorrencia, aLog, ncont )
			           ENDIF 
			    ELSEIF LCTB 
					if Substr(clinha, 1,1) == "3"
						CTPA := '3' 
						lGo := ImpCTB(nCont, cLinha)
						lGo := .T.   
					else
						_cOcorrencia := "TIPO DE REGISTRO INVALIDO P/ lancamentos contabeis."       
						u_Gravar_erro(NcONT,1,1,_cOcorrencia,cArqImpor,"",Substr(clinha, 1,1),.t.)
						AtuLog(_cOcorrencia,aLog,NcONT)
						lGo := .T.
					endif     
	        	ENDIF
			ENDIF
            FT_FSKIP()
			nCont ++ 
        EndDo

        FT_FUse()
    

End Transaction

FT_FUSE()



    if !fClose(nHdl)
		conout( "Erro ao fechar arquivo, erro numero: ", FERROR() )
		aadd(alog, ("Erro ao fechar arquivo, erro numero: ", FERROR()) )
	else		
		Copy File &cArqImpor To &cArquiv2
		FRename(UPPER(cArquiv2), STRTRAN(UPPER(cArquiv2),".TXT",".IMP"))
		lretorno := fErase(cArqImpor)
		if lretorno == -1
			aadd(alog, ("Falha ao excluir arquivo - FERROR "+cValToChar(fError())))
		endif  
	endif

Return .T. 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณImpContasPag บ Autor ณ THIAGO PEREIRAบ Data ณ 03/04/08 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Gerar Titulo no Contas a pagar via execauto a partir dos   บฑฑ
ฑฑบ          ณ dados do arquivo TXT                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ImpContasPag(nx,xcTexto)
Local nP,nr,nz,ni
Private dEmissao    := DDATABASE
Private dVencto     := DDATABASE
Private cTp                
Private nOpc        := 3  
Private lMsErroAuto := .f.
Private _cArqs      := ""
Private nValorTit   := 0
Private DBASEOLD    := DDATABASE
Private _cEmpresa
Private _cFilial
Private lLpad       := .T.
Private _cCtaCred   := ""
Private _nVlrDesc   := 0   

erro := 0 
lProvisor := .F.
nPos      := 0
_nPDesc   := 0  
_nVlrDesc := 0


// Limpar Tabela Auxiliar Criada para Contabilizacao
//dbselectarea("TMPZZ2") 
/*
dbCloseArea()

aCampos := {{ "ZZ2_FILIAL" , "C" , 2,0},;
				{ "ZZ2_DEBITO" , "C" , 20,0},;
				{ "ZZ2_CREDIT" , "C" , 20,0},;
				{ "ZZ2_TIPO"   , "C" , 1,0},;
				{ "ZZ2_DATA"   , "D" , 8,0},;
				{ "ZZ2_CCD"    , "C" , 9,0},;
				{ "ZZ2_CCC"    , "C" , 9,0},;
				{ "ZZ2_ITDEB"  , "C" , 9,0},;
				{ "ZZ2_ITCRE"  , "C" , 9,0},;
				{ "ZZ2_CLADEB" , "C" , 9,0},;
				{ "ZZ2_CLACRE" , "C" , 9,0},;
				{ "ZZ2_SEQ"    , "C" , 2,0},;
				{ "ZZ2_DOC"    , "C" , 9,0},;
				{ "ZZ2_VALOR"  , "N" , 17,2},;
				{ "ZZ2_HIST"   , "C" , 40,2}}
				
cArqTmp := CriaTrab(aCampos)
dbUseArea( .T.,"", cArqTmp, "TMPZZ2", .F. , .F. )
IndRegua ( "TMPZZ2",cArqTmp, "ZZ2_FILIAL+DTOS(ZZ2_DATA)+ZZ2_SEQ",,,OemToAnsi("Selecionando Registros..."))
 */

cTp      := Substr(xcTexto,1,1)          // Tipo do Registro

IF CTP == '4'
	_nTotalMN := 0
	_nNP      := 0 
	lTipo4    := .T. 
	_cNaturez := Substr(xcTexto,2,9)                  // Natureza
	_nVlrCont := VAL(Substr(xcTexto,11,14))*0.01     // Valor Natureza
	_nTotalMN += _nVlrCont
     _nNP++  

	If _nTotalMN != _nTotalTit                                       
		_cOcorrencia := "SOMA LANC.MULT-NAT.:"+ALLTRIM(Transform(_nTotalMN,"@E 999,999,999.99"))+" DIFERENTE DO VLR.DO TITULO:"+ALLTRIM(Transform(_nTotalTit,"@E 999,999,999.99"))
		U_Gravar_erro(0,11,14,_cOcorrencia,cArquiv1,cTpA,"4",.T.) 
		atuLog(_cOcorrencia,aLog,nx)
		erro++
	Endif
			
	// Se nao houver inconsistencias carrega vetor para contabilizar
	If erro = 0
		AADD(aVet4,{_cNaturez,_nVlrCont,ALLTRIM(STR(_nNP))}) 
	Endif

ELSEif cTp == "1"		
			
		
	_cEmpresa := Substr(xcTexto,2,2)                // Empresa
	_cFilial  := Substr(xcTexto,4,8)                // Filial
	_cPrefixo := Substr(xcTexto,12,3)                // Prefixo
	_cDocum   := Substr(xcTexto,15,9)                // Numero documento
	_cParcela := Substr(xcTexto,24,1)               // Parcela
	_cCNPJ    := Substr(xcTexto,25,14)              // CNPJ ou CPF
	_dEmissao := STOD(Substr(xcTexto,39,8))         // Data Emissao da Nota
	_nValorTit:= VAL(Substr(xcTexto,47,14))*0.01    // Valor Total da Nota
	_dVencto  := STOD(Substr(xcTexto,61+nPos,8))    // Data vencimento do Titulo
	_cHistor  := Substr(xcTexto,69+nPos,25)         // Historico do Titulo
	_cNaturez := Substr(xcTexto,94+nPos,9)          // natureza do Titulo
	_cTipo    := Substr(xcTexto,103+nPos,3)          // Tipo do Titulo
	_nPDesc := VAL(Substr(xcTexto,106+nPos,5))*0.01 // Percentual de Desconto Financeiro
	_nVlrDesc := (_nPDesc * 0.01) * _nValorTit      // Valor do Decrescimo 

	lTipo3   := .F.
	lTipo4   := .F.
	_cCustCP := Space(9)
	
	// validacaoes: 
	_cMultNat := "1"                                // Mult-natureza       
	_cChave   := _cPrefixo+_cDocum+_cParcela+_cTipo
	_nTotalTit:= _nTotalTit + _nValorTit   

	// Verifica se a empresa/filial do arquivo eh a mesma em que esta selecionada
	If _cEmpresa+_cFilial != CEMPANT+CFILANT
		_cOcorrencia := "EMPRESA/FILIAL DO TXT DIFERENTE DA EMPRESA LOGADA."       
		u_Gravar_erro(nx,2,5,_cOcorrencia,cArquiv1,cTpA,cTP,.t.)     
		AtuLog(_cOcorrencia,aLog,nx)
		erro++
		lErroEmpFil = .T.
	Endif
			
	// Verifica se o numero do documento esta preenchido
	If Empty(_cDocum)
		_cOcorrencia := "NUMERO DO TITULO NAO INFORMADO NO ARQUIVO TXT."     
		u_Gravar_erro(nx,15,17,_cOcorrencia,cArquiv1,cTpA,cTP,.t.)      
		AtuLog(_cOcorrencia,aLog,nx)
		erro++
	Endif
			
	// Verifica se o Tipo o documento esta preenchido
	DbSelectArea("SX5")
	If !DbSeek(xFilial("SX5")+"05"+_cTipo)
		_cOcorrencia := "TIPO DO TITULO INFORMADO NO ARQUIVO TXT NAO EXISTE."   
		u_Gravar_erro(nx,103,98,_cOcorrencia,cArquiv1,cTpA,cTP,.t.) 
		AtuLog(_cOcorrencia,aLog,nx)
		erro++
    Endif


	// Verifica se a data de emissao do documento esta preenchida
	If Empty(_dEmissao)
		_cOcorrencia := "DATA EMISSAO DO TITULO NAO INFORMADA NO ARQUIVO TXT."   
		u_Gravar_erro(nx,39,40,_cOcorrencia,cArquiv1,cTpA,cTP,.t.) 
		AtuLog(_cOcorrencia,aLog,nx)
		erro++
	Endif
			
	// Verifica se a data de vencimento do documento esta preenchida
	If Empty(_dVencto)
		_cOcorrencia := "DATA VENCIMENTO DO TITULO NAO INFORMADA NO ARQUIVO TXT."  
		u_Gravar_erro(nx,61,62,_cOcorrencia,cArquiv1,cTpA,cTP,.t.)  
		AtuLog(_cOcorrencia,aLog,nx)
		erro++
	Endif
			
	// Verifica se a o fornecedor informado esta cadastrado
	dbselectarea("SA2")
	dbsetorder(3)  // Filial+CGC
	Dbseek(xFilial("SA2")+_cCNPJ)
	If Found()
		_cCodForn  := SA2->A2_COD
		_cLojaForn := SA2->A2_LOJA
		_cTipoForn := SA2->A2_TIPO
		_cCtaCred  := SA2->A2_CONTA
		_cNaturez  := SA2->A2_NATUREZ           
		_cNReduz   := SA2->A2_NREDUZ
           
		If SA2->A2_MSBLQL = "1"                                                  
			_cOcorrencia := "FORNECEDOR BLOQUEADO PARA MOVIMENTACAO: "+"( "+ALLTRIM(_cCNPJ)+" )" 
			u_Gravar_erro(nx,25,32,_cOcorrencia,cArquiv1,cTpA,cTP,.t.) 
			AtuLog(_cOcorrencia,aLog,nx)        
			erro++
       	Endif

		// Verificar se a conta contabil informada esta cadastrada
		dbselectarea("CT1")
		dbsetorder(1)
		Dbseek(xFilial("CT1")+_cCtaCred)
		If !Found()
			_cOcorrencia := "CONTA CONTABIL DO FORNECEDOR NAO ESTA CADASTRADA. "+"( "+ALLTRIM(_cCtaCred)+" )" 
			u_Gravar_erro(nx,0,0,_cOcorrencia,cArquiv1,cTpA,cTP,.t.) 
			AtuLog(_cOcorrencia,aLog,nx)       
			erro++
		Else
			If CT1->CT1_BLOQ = "1"
				_cOcorrencia := "CONTA CONTABIL DO FORNECEDOR BLOQUEADA PARA MOVIMENTO. "+"( "+ALLTRIM(_cCtaCred)+" )" 
				u_Gravar_erro(nx,0,0,_cOcorrencia,cArquiv1,cTpA,cTP,.t.)   
				AtuLog(_cOcorrencia,aLog,nx)     
				erro++
			Endif
		Endif
	Else
		_cOcorrencia := "CPF/CNPJ NAO ENCONTRADO NO CADASTRO DE FORNECEDORES."        
		u_Gravar_erro(nx,25,32,_cOcorrencia,cArquiv1,cTpA,cTP,.t.) 
		AtuLog(_cOcorrencia,aLog,nx)
		erro++
	Endif

	// Trazer Prefixo da Tabela de Prefixo (SZ3) Caso a conta contabil esteja associada ao prefixo
	dbselectarea("SZ3")
	dbsetorder(2)
	dbseek(xFilial("SZ3")+_cCtaCred)
	If Found()
		_cPrefixo := SZ3->Z3_PREFIXO
	Endif

	// Verifica se o historico do documento foi preenchido
	If Empty(_cHistor)
		_cOcorrencia := "HISTORICO DO TITULO NAO INFORMADO NO ARQUIVO TXT."       
		u_Gravar_erro(nx,69,87,_cOcorrencia,cArquiv1,cTpA,cTP,.t.)
		AtuLog(_cOcorrencia,aLog,nx)
		erro++
	Endif
			
	// Verifica se a natureza informada esta cadastrada               
	If !Empty(_cNaturez)
		If Empty(Posicione("SED",1,xFilial("SED")+_cNaturez,"ED_CODIGO"))
			erro++                                                        
			_cOcorrencia := "NATUREZA DO FORNECEDOR NAO ESTA CADASTRADA. "+"( "+ALLTRIM(_cNaturez)+" )" 
			u_Gravar_erro(nx,0,0,_cOcorrencia,cArquiv1,cTpA,cTP,.t.)      
			AtuLog(_cOcorrencia,aLog,nx)
		Endif
     Else
		erro++
		_cOcorrencia := "NATUREZA NAO PREENCHIDA NO CADASTRO DESTE FORNECEDOR."          
		u_Gravar_erro(nx,0,0,_cOcorrencia,cArquiv1,cTpA,cTP,.t.)
		AtuLog(_cOcorrencia,aLog,nx)
      Endif

	  If erro = 0
	  	if len(avet1) <> 0
	  		if 	(ascan(avet1[1],_cfilial) 	= 0 ) .and. ;
		  		(ascan(avet1[2],__cPrefixo) = 0 ) .and. ;
		  		(ascan(avet1[3],_cDocum) 	= 0 ) .and. ;
		  		(ascan(avet1[4],_cParcela)  = 0 ) 
				  
				AADD(aVet1,{_cFilial,;
							_cPrefixo,;
							_cDocum,;
							_cParcela,;
							_cTipo,;
							_cNaturez,;
							_nValorTit,;
							_dEmissao,;
							_dVencto,;
							_cCodForn,;
							_cLojaForn,;
							_cHistor,;
							_cMultNat,;
							_cChave,;
							_cNReduz,;
							nx,;
							_nVlrDesc})
				Endif
			else
							AADD(aVet1,{_cFilial,;
							_cPrefixo,;
							_cDocum,;
							_cParcela,;
							_cTipo,;
							_cNaturez,;
							_nValorTit,;
							_dEmissao,;
							_dVencto,;
							_cCodForn,;
							_cLojaForn,;
							_cHistor,;
							_cMultNat,;
							_cChave,;
							_cNReduz,;
							nx,;
							_nVlrDesc})
			Endif
		EndIf
ElseIf cTp == "3"   // Itens para Contabilizacao
		
	_nTotalLC := 0
	lTipo3    := .T. 
	_cCtaDeb  := Substr(xcTexto,2,20)                // Conta Contabil
	_cHistor  := Substr(xcTexto,22,40)               // Historico para o Lancamento Contabil
	_nVlrCont := VAL(Substr(xcTexto,62,14))*0.01     // Valor Contabil
	_cCusto   := Alltrim(Substr(xcTexto,76,9))                // C.Custo  
	_cCustCP  := _cCusto
	lConta    := .T.
	_nTotalLC += _nVlrCont
	_cCtaDeb := STRZERO(VAL(_cCtaDeb),10)	

	// Verifica se a conta contabil informada esta cadastrada
	If !Empty(_cCtaDeb)
		dbselectarea("CT1")
		dbsetorder(2)  
		Dbseek(xFilial("CT1")+_cCtaDeb)
		if !Found()
			_cOcorrencia := "CODIGO REDUZIDO "+ALLTRIM(_cCtaDeb)+" NAO ESTA CADASTRADO." 
			U_Gravar_erro(nx,2,21,_cOcorrencia,cArquiv1,cTpA,cTP) 
			AtuLog(_cOcorrencia,aLog,nx)
			erro++
		Else	
			If CT1->CT1_BLOQ = "1"                                                       
				_cOcorrencia := "CODIGO REDUZIDO "+ALLTRIM(_cCtaDeb)+" ESTA BLOQUEADO PARA MOVIMENTO."  
				U_Gravar_erro(NX,2,21,_cOcorrencia,cArquiv1,cTpA,cTP)  
				AtuLog(_cOcorrencia,aLog,nx)      
				erro++
			Else
				_cCtaDeb := CT1->CT1_CONTA
			Endif
		Endif        

		dbselectarea("CT1")
		dbsetorder(1)
	Else
		_cOcorrencia := "CONTA CONTABIL NAO INFORMADA NO ARQUIVO TEXTO."      
		U_Gravar_erro(NX,2,21,_cOcorrencia,cArquiv1,cTpA,cTP)
		AtuLog(_cOcorrencia,aLog,nx)
		erro++
	Endif	

	// Verifica se o c.custo informado esta cadastrado
	If !Empty(_cCusto)
		dbselectarea("CTT")
		dbsetorder(1)
		Dbseek(xFilial("CTT")+Substr(_cCusto,1,2))
		If !Found()
			_cOcorrencia := "CENTRO DE CUSTO "+ ALLTRIM(_cCusto) +" NAO ESTA CADASTRADO."   
			U_Gravar_erro(NX,76,84,_cOcorrencia,cArquiv1,cTpA,cTP)
			AtuLog(_cOcorrencia,aLog,nx)
			erro++
		Else	
			If CTT->CTT_BLOQ = "1"                                                              
				_cOcorrencia := "CENTRO DE CUSTO "+ ALLTRIM(_cCusto) +" ESTA BLOQUEADO PARA MOVIMENTO." 
				U_Gravar_erro(NX,2,21,_cOcorrencia,cArquiv1,cTpA,cTP)       
				AtuLog(_cOcorrencia,aLog,nx) 
				erro++
			Endif
		Endif
	
		
	Else 
		_cOcorrencia := "CENTRO DE CUSTO NAO INFORMADO NO ARQUIVO TXT."        			
		U_Gravar_erro(NX,76,84,_cOcorrencia,cArquiv1,cTpA,cTP)    
		AtuLog(_cOcorrencia,aLog,nx)
		erro++
	Endif	
	
	// Verifica se o historico do lancamento foi preenchido
	If Empty(_cHistor)
		_cOcorrencia := "HISTORICO DO LANCAMENTO NAO INFORMADO NO ARQUIVO TXT."       
		U_Gravar_erro(NX,22,61,_cOcorrencia,cArquiv1,cTpA,cTP)    
		AtuLog(_cOcorrencia,aLog,nx)
		erro++
	Endif
			
	If _nTotalLC != _nTotalTit                                                 
		_cOcorrencia := "SOMA LANC.CONTABEIS:"+ALLTRIM(Transform(_nTotalLC,"@E 999,999,999.99"))+" DIFERENTE DO VLR.DO TITULO:"+ALLTRIM(Transform(_nTotalTit,"@E 999,999,999.99"))
		U_Gravar_erro(0,62,14,_cOcorrencia,cArquiv1,cTpA,"3")      
		AtuLog(_cOcorrencia,aLog,nx)
		erro++
	Endif
			
	// Se nao houver inconsistencias carrega vetor para contabilizar
	If erro = 0
		AADD(aVet3,{_cCtaDeb,_cHistor,_nVlrCont,_cCusto,_cCtaCred,_cChave,_cNaturez})
	Endif
ENDIF			


_lEstornaCP := .F.  

dbselectarea("TRE") 
If Reccount() = 0   .or. erro = 0
	aVetor := {}
	For nr:=1 To Len(aVet1)
		lGravou := .F.
		aVetor  := {{"E2_FILIAL"    , aVet1[nr,1] ,NIL},;
						{"E2_PREFIXO"   , aVet1[nr,2] ,NIL},;
						{"E2_NUM"       , aVet1[nr,3] ,NIL},;
						{"E2_PARCELA"   , aVet1[nr,4] ,Nil},;
						{"E2_TIPO"      , aVet1[nr,5] ,NIL},;
						{"E2_NATUREZ"   , aVet1[nr,6] ,NIL},;
						{"E2_MULTNAT"   , aVet1[nr,13],NIL},; 
						{"E2_VALOR"     , aVet1[nr,7] ,NIL},;
						{"E2_DECRESC"   , aVet1[nr,17],NIL},; 
						{"E2_EMISSAO"   , aVet1[nr,8] ,NIL},;
						{"E2_VENCTO"    , aVet1[nr,9] ,NIL},;
						{"E2_VENCREA"   , DataValida(aVet1[nr,9]),NIL},;
						{"E2_FORNECE"   , aVet1[nr,10] ,NIL},;
						{"E2_LOJA"      , aVet1[nr,11] ,NIL},;
						{"E2_DIRF"      , "2"          ,NIL},;
						{"E2_CCD"       , Substr(_cCustCP,1,2),NIL},;
						{"E2_ITEMD"     , Substr(_cCustCP,3,2),NIL},;
						{"E2_CLVLDB"    , Substr(_cCustCP,5,2),NIL},;
						{"E2_HIST"      , aVet1[nr,12] ,NIL}}
						
		if cTp == '1'
			// Verifica se o titulo ja foi cadastrado
			dbselectarea("SE2")
			dbsetorder(6)
			dbseek(xFilial("SE2")+aVet1[nr,10]+aVet1[nr,11]+aVet1[nr,2]+aVet1[nr,3]+aVet1[nr,4]+aVet1[nr,5])
			// Caso o Titulo ja tenha sido importado e nao tenha sofrido baixas o mesmo sera excluido e 
			// importado novamente 
			_nCP := 0
			If !Found()
			_nOpc := 3        // Inclusao
			_nCP  := 1
			ElseIf Empty(SE2->E2_BAIXA)
				_nOpc 		:= 5    // Exclusao
				_nCP  		:= 2
				_lEstornaCP := .T.      
			Endif

			If !Empty(_nCP)
				For nP := 1 To _nCP           // Primeiro Exclui o Titulo depois Inclui Novamente
					If nP = 2
						_nOpc := 3   // Inclusao
				Endif
					MSExecAuto({|x,y,z| FINA050(x,y,z)},aVetor,,_nOpc)
					lGravou := .T.
					If lMsErroAuto
						If (!IsBlind())
							MostraErro()
						EndIf

						lMsErroAuto := .F.
						Aadd(alog, "erro no msexecauto " + aVet1[nr,10]+aVet1[nr,11]+aVet1[nr,2]+aVet1[nr,3]+aVet1[nr,4]+aVet1[nr,5])
					else
						if _nOPc == 3
							AtuLog("titulo incluido com sucesso " + aVet1[nr,10]+aVet1[nr,11]+aVet1[nr,2]+aVet1[nr,3]+aVet1[nr,4]+aVet1[nr,5],aLog,0)
							If _nOpc = 3        
								dbselectarea("ZZ1")
								Reclock("ZZ1",.T.)
									ZZ1_FILIAL  := CFILANT
									ZZ1_ARQUIV := cArquiv1
									ZZ1_DTINTE := DDATABASE
									ZZ1_LAYOUT  := "6"
									ZZ1_CLIFOR  := SE2->E2_FORNECE
									ZZ1_LOJA    := SE2->E2_LOJA
									ZZ1_PREFIX := SE2->E2_PREFIXO
									ZZ1_NUM     := SE2->E2_NUM
									ZZ1_PARCEL := SE2->E2_PARCELA
									ZZ1_TIPO    := SE2->E2_TIPO
									ZZ1_EMISSA := SE2->E2_EMISSAO
								msunlock()
							Endif	
					//
						else
							AtuLog("titulo excluido com sucesso "+  aVet1[nr,10]+aVet1[nr,11]+aVet1[nr,2]+aVet1[nr,3]+aVet1[nr,4]+aVet1[nr,5],aLog,0)
						endif
					Endif        
					//
					//
				Next nP	
				//
			Else
				_cOcorrencia := "ESTE TITULO JA FOI IMPORTADO E JA SOFREU BAIXA."     
				u_Gravar_erro(aVet1[nr,16],9,17,_cOcorrencia+" ( "+ aVet1[nr,3] +" )",cArquiv1,cTpA,"1",.t.)  
				erro++ 
				AtuLog(_cOcorrencia,aLog,aVet1[nr,16])
			Endif
		endif
		dbselectarea("SE2")
		dbsetorder(1)
	Next nr

	If !Empty(aVet1)   
	   If erro = 0  
			// Estornar Contabilizacao e gerar multnatureza apos inclusao das parcelas dos titulos
			//
			nr := 1
		
			If lTipo3   
				_cHist := alltrim(aVet3[nr,2]) +" "+aVet1[nr,5]+ALLTRIM(aVet1[nr,3]) 
			Endif	
			
			If _lEstornaCP .and. lTipo3    
				// Estornar Contabilizacao
				_cHist    := "EST REF "+ALLTRIM(aVet1[nr,5])+" "+ALLTRIM(aVet1[nr,3])+" "+ALLTRIM(aVet1[nr,15])
				cPadrao   := GetMv("MV_XLPEXRD")  // Lancamento Padrao que sera utilizado na contabilizacao do Estorno
				DDATABASE := aVet1[nr,8]		    // Passa Titulo e Historico para lancam do fornecedor
				CtbCtaPag(aVet1[nr,2]+aVet1[nr,3]+aVet1[nr,4]+aVet1[nr,5],_cHist,cPadrao)  
				_lEstornaCP := .F. 
		   Endif      
		   
			// Gerar Multinatureza
			If aVet1[nr,13] = "1"  .and. lTipo4  
				For ni := 1 to Len( aVet4 )
					nTotRatMN := 0
				   For nz := 1 To Len(aVet1)
						nTotRatMN += MultNatCP(aVet1,nr,aVet4,ni,_nTotalTit,nz)
					Next nz
					nAjustMN :=	aVet4[ni,2] - nTotRatMN
					DbSelectArea("SEV")
					Reclock("SEV",.F.)
						SEV->EV_VALOR	+= nAjustMN
						SEV->EV_PERC	:= SEV->EV_VALOR/_nTotalTit
					MsUnlock()
				Next
			Endif 		   

			// Contabilizar apos inclusao das parcelas dos titulos
			//
			If lTipo3  
				nr        := 1
				_cHist    := alltrim(aVet3[nr,2]) +" "+aVet1[nr,5]+ALLTRIM(aVet1[nr,3])  
				cPadrao   := GetMv("MV_XLPRDOR")    // Lancamento Padrao que sera utilizado na contabilizacao
				DDATABASE := aVet1[nr,8]		      // Passa Titulo e Historico para lancam do fornecedor
				CtbCtaPag(aVet1[nr,2]+aVet1[nr,3]+aVet1[nr,4]+aVet1[nr,5],_cHist,cPadrao)  
			Endif	
			
			lMSGFim   := .T.
			lMsg      := .T.
		Endif	
   Endif
Endif
		
Return .T. 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ CriarTMPSบ Autor ณ THIAGO PEREIRAบ Data ณ  04/08/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para criar o arquivo temporario utilizado para      บฑฑ
ฑฑบ          ณ gravar os erros encontrados durante a integracao e o       บฑฑ
ฑฑบ          ณ temporario utilizado nas contabilizacoes.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integracao                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function CriarTMPS(nTmp)

If nTmp = 0
	If Select("TRE") > 0
		dbselectarea("TRE")
		dbclosearea()
	Endif
	
	aStru := {}
	aAdd( aStru,{"ENOME"  ,"C",25,00} )
	aAdd( aStru,{"ESITUAC","C",76,00} )
	aAdd( aStru,{"EARQUIV","C",16,00} )
	aAdd( aStru,{"TPA"    ,"C",1 ,00} )
	aAdd( aStru,{"TPR"    ,"C",1 ,00} )
	aAdd( aStru,{"ELINHA" ,"N",06,00} )
	aAdd( aStru,{"COLINI" ,"N",06,00} )
	aAdd( aStru,{"COLFIM" ,"N",06,00} )
Endif	
oTempTable := FWTemporaryTable():New( "TRE" )
oTemptable:SetFields( aStru )
oTempTable:Create()	
dbselectarea("TRE")

// Criar Tabela Auxiliar Criada para Contabilizacao 
/*dbselectarea("ZZ2") 
dbCloseArea()  // Fecha Tabela no Banco
aCampos := {{ "ZZ2_FILIAL" , "C" , 2,0},;
				{ "ZZ2_DEBITO" , "C" , 20,0},;
				{ "ZZ2_CREDIT" , "C" , 20,0},;
				{ "ZZ2_TIPO"   , "C" , 1,0},;
				{ "ZZ2_DATA"   , "D" , 8,0},;
				{ "ZZ2_CCD"    , "C" , 9,0},;
				{ "ZZ2_CCC"    , "C" , 9,0},;
				{ "ZZ2_ITDEB"  , "C" , 9,0},;
				{ "ZZ2_ITCRE"  , "C" , 9,0},;
				{ "ZZ2_CLADEB" , "C" , 9,0},;
				{ "ZZ2_CLACRE" , "C" , 9,0},;
				{ "ZZ2_SEQ"    , "C" , 2,0},;
				{ "ZZ2_DOC"    , "C" , 9,0},;
				{ "ZZ2_VALOR"  , "N" , 17,2},;
				{ "ZZ2_HIST" , "C" , 80,2}}
				
cArqTmp := CriaTrab(aCampos)
dbUseArea( .T.,"", cArqTmp, "TMPZZ2", .F. , .F. )
IndRegua ( "TMPZZ2",cArqTmp, "ZZ2_FILIAL+DTOS(ZZ2_DATA)+ZZ2_SEQ",,,OemToAnsi("Selecionando Registros..."))
*/
Return  .T. 


/*
๏############################################################################ฟฝ
๏############################################################################ฟฝ
๏########################################################################ฟฝอป๏#ฟฝ
๏##ฟฝPrograma  ๏ฟฝAtuLog    ๏ฟฝAutor  ๏ฟฝJonas L. Souza Jr   ๏ฟฝ Data ๏ฟฝ  07/20/09   ๏##ฟฝ
๏########################################################################ฟฝอน๏#ฟฝ
๏##ฟฝDesc.     ๏ฟฝAtualiza Array de Log                                       ๏##ฟฝ
๏##ฟฝ          ๏ฟฝ                                                            ๏##ฟฝ
๏########################################################################ฟฝอน๏#ฟฝ
๏##ฟฝUso       ๏ฟฝ Totvs                                                      ๏##ฟฝ
๏########################################################################ฟฝอผ๏#ฟฝ
๏############################################################################ฟฝ
๏############################################################################ฟฝ
*/
Static Function AtuLog(cMsg,aLog,nAtu)

	AAdd(aLog, " Import = Linha "+StrZero(nAtu,12)+" = "+;
	" LOG = "+cMsg )
Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbCtaPag บ Autor ณ THIAGO PEREIRAบ Data ณ 03/04/08    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Contabilizacao do Contas a Pagar                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function CtbCtaPag(_cChave,_cHistor,cPadrao)

Local cOrigem   := "FINA050"
Local cArquivo  := " "
Local cLote     := "008820"
Local lPadrao   := VerPadrao(cPadrao)
Local nHdlPrv   := 0
Local nTotal    := 0
Local lMostra   := _MV_PAR02
Local lAglutina := _MV_PAR03
Local ni        := 0

If !lPadrao
	Return
Endif

nHdlPrv  := HeadProva(cLote,cOrigem,Substr(cUsuario,7,6),@cArquivo)

// Limpar Tabela Auxiliar Criada para Contabilizacao
/*dbselectarea("TMPZZ2")
ZAP*/

// Carrega tabela auxiliar com os lancamentos que serao contabilizados
nSeq     := 0
nTotForn := 0
For ni := 1 to Len( aVet3 )
	//If aVet3[ni,6] = _cChave
		nSeq++
		dbselectarea("ZZ2")
		Reclock("ZZ2",.T.)
		Replace ZZ2_FILIAL With xFilial("ZZ2")
		Replace ZZ2_DATA   With DDATABASE
		If _lEstornaCP = .F.  // Estorno do Contas a Pagar Para titulos ja importados e sem sofrer baixa
			Replace ZZ2_DEBITO With aVet3[ni,1]
			Replace ZZ2_CCD    With Substr(aVet3[ni,4],1,2)
			Replace ZZ2_ITDEB  With Substr(aVet3[ni,4],3,2)
			Replace ZZ2_CLADEB With Substr(aVet3[ni,4],5,2)
			Replace ZZ2_HIST With _cHistor  // - Gravar no Lancamento a Debito o Numero do Documento
      Else
			Replace ZZ2_CREDIT With aVet3[ni,1]
			Replace ZZ2_CCC    With Substr(aVet3[ni,4],1,2)
			Replace ZZ2_ITCRE  With Substr(aVet3[ni,4],3,2)
			Replace ZZ2_CLACRE With Substr(aVet3[ni,4],5,2)
			Replace ZZ2_HIST   With _cHistor // - Gravar no Lancamento a Debito o Numero do Documento //aVet3[ni,2]
      Endif
		Replace ZZ2_SEQ    With Strzero(nSeq,2)
		Replace ZZ2_VALOR  With aVet3[ni,3]
		Msunlock()
		nTotal    += DetProva(nHdlPrv,cPadrao,cOrigem,cLote)
		nTotForn  += aVet3[ni,3]
		_cCtaCred := aVet3[ni,5]
	//Endif
Next/*
nSeq++
dbselectarea("ZZ2")
Reclock("ZZ2",.T.)
Replace ZZ2_FILIAL With xFilial("ZZ2")
If _lEstornaCP = .F.  // ronha - Estorno do Contas a Pagar Para titulos ja importados e sem sofrer baixa
	Replace ZZ2_CREDIT With _cCtaCred
Else
	Replace ZZ2_DEBITO With _cCtaCred
Endif	
Replace ZZ2_DATA   With DDATABASE
Replace ZZ2_SEQ    With Strzero(nSeq,2)
Replace ZZ2_VALOR  With nTotForn
Replace ZZ2_HIST With _cHistor
Msunlock()
nTotal += DetProva(nHdlPrv,cPadrao,cOrigem,cLote)*/

If nTotal > 0
	
	// Chama rotina de contabilizacao padrao
	Processa({||RodaProva(nHdlPrv,nTotal)}, "Contabilizando  " )
	Processa({||cA100Incl(cArquivo,nHdlPrv,3,cLote,lMostra,lAglutina)}, "Contabilizando cA100Incl")

	AtuLog("titulo Contabilizado com sucesso " ,aLog,0)
	
Endif

DDATABASE := DBASEOLD
lTipo3 := .F. 

Return  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณImpContasPag บ Autor ณ THIAGO PEREIRAบ Data ณ 03/04/08 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Gerar Titulo no Contas a pagar via execauto a partir dos   บฑฑ
ฑฑบ          ณ dados do arquivo TXT                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ImpCTB(nx,xcTexto)

Private dEmissao    := DDATABASE
Private dVencto     := DDATABASE
Private cTp                
Private nOpc        := 3  
Private lMsErroAuto := .f.
Private _cArqs      := ""
Private aVet1       := {} 
Private aVet2       := {} // VETOR Titulos Provisorios// VETOR Titulos Provisorios
Private aVet3       := {} // VETOR Titulos Provisorios
Private aVet4       := {} // VETOR Titulos Provisorios
Private nValorTit   := 0
Private DBASEOLD    := DDATABASE
Private _cEmpresa
Private _cFilial
Private lLpad       := .T.
Private _cCtaCred   := ""
Private _nVlrDesc   := 0   

erro := 0 

	lProvisor := .F.
	_nTotalTit:= 0
			nPos      := 0
			_nPDesc   := 0  
			_nVlrDesc := 0


// Limpar Tabela Auxiliar Criada para Contabilizacao
dbselectarea("ZZ2") /*
dbCloseArea()

aCampos := {{ "ZZ2_FILIAL" , "C" , 2,0},;
				{ "ZZ2_DEBITO" , "C" , 20,0},;
				{ "ZZ2_CREDIT" , "C" , 20,0},;
				{ "ZZ2_TIPO"   , "C" , 1,0},;
				{ "ZZ2_DATA"   , "D" , 8,0},;
				{ "ZZ2_CCD"    , "C" , 9,0},;
				{ "ZZ2_CCC"    , "C" , 9,0},;
				{ "ZZ2_ITDEB"  , "C" , 9,0},;
				{ "ZZ2_ITCRE"  , "C" , 9,0},;
				{ "ZZ2_CLADEB" , "C" , 9,0},;
				{ "ZZ2_CLACRE" , "C" , 9,0},;
				{ "ZZ2_SEQ"    , "C" , 2,0},;
				{ "ZZ2_DOC"    , "C" , 9,0},;
				{ "ZZ2_VALOR"  , "N" , 17,2},;
				{ "ZZ2_HIST" , "C" , 40,2}}
				
cArqTmp := CriaTrab(aCampos)
dbUseArea( .T.,"", cArqTmp, "TMPZZ2", .F. , .F. )
IndRegua ( "TMPZZ2",cArqTmp, "ZZ2_FILIAL+DTOS(ZZ2_DATA)+ZZ2_SEQ",,,OemToAnsi("Selecionando Registros..."))
*/ 
cTp      	:= Substr(xcTexto,1,1)          // Tipo do Registro
_cEmpresa 	:= Substr(xcTexto,2,2)                // Empresa
_cFilial  	:= Substr(xcTexto,4,8)                // Filial
_cTipoLc  	:= Substr(xcTexto,12,1)                // Tipo de lancamento: D - Debito
_dLancto  	:= STOD(Substr(xcTexto,13,8))          //                     C - Credito
_cConta   	:= Substr(xcTexto,21,20)
_cHistor  	:= Substr(xcTexto,41,40)
_cValorLc 	:= Substr(xcTexto,81,14)
_cCusto   	:= Substr(xcTexto,95,9)    

_nPosNeg  	:= AT("-",_cValorLc)
If _nPosNeg > 0
	_nVlrCont := VAL(Substr(_cValorLc,_nPosNeg,(14-_nPosNeg+1)))*0.01
	If _nVlrCont < 0
		_cOcorrencia := "VALOR DO LANCAMENTO ESTA NEGATIVO NO ARQUIVO TXT."        // ok 03/07/08
		u_Gravar_Erro(nx,81,94,_cOcorrencia,cArquiv1,cTpA,cTP, _lAuto ) 
		AtuLog(_cOcorrencia,aLog,nx)
		erro++
	Endif
Else
	_nVlrCont := VAL(Substr(cBuffer,81,14))*0.01
Endif

// Verifica se a empresa/filial do arquivo eh a mesma em que esta selecionada
If _cEmpresa+_cFilial != CEMPANT+CFILANT
	_cOcorrencia := "EMPRESA/FILIAL DO TXT DIFERENTE DA EMPRESA LOGADA."       
	u_Gravar_erro(nx,2,5,_cOcorrencia,cArquiv1,cTpA,cTP,.t.)     
	AtuLog(_cOcorrencia,aLog,nx)
	erro++
	lErroEmpFil = .T.
Endif
			
If ! _cTipoLc $ "CDH"
	_cOcorrencia := "TIPO DE LANCAMENTO diferente de  D-DEBITO, C-CREDITO ou H-COMPLEMENTO DE HISTORICO."
	u_Gravar_Erro(nx,12,12,_cOcorrencia,cArquiv1,cTpA,cTP, _lAuto )   
	AtuLog(_cOcorrencia,aLog,nx)
	erro++
Endif
		// Verifica se a data do lancamento foi informada
If Empty(_dLancto)
	_cOcorrencia := "DATA DO LANCAMENTO NAO INFORMADA NO ARQUIVO TXT."
	u_Gravar_Erro(nx,13,20,_cOcorrencia,cArquiv1,cTpA,cTP, _lAuto )   
	AtuLog(_cOcorrencia,aLog,nx)
	erro++
Endif

// Verifica se o tipo de lancamento foi informado
// Verifica se a conta informada esta cadastrado      
_cConta 	:= STRZERO(VAL(_cConta),10)	
If !Empty(_cConta)
	dbselectarea("CT1")
	dbsetorder(2)
	Dbseek(xFilial("CT1")+_cConta)
	If !Found()
		_cOcorrencia := "CODIGO REDUZIDO NAO ENCONTRADO NO PLANO DE CONTAS. "+"( "+ALLTRIM(_cConta)+" )"
		u_Gravar_Erro(nx,21,40,_cOcorrencia,cArquiv1,cTpA,cTP, _lAuto )  
		AtuLog(_cOcorrencia,aLog,nx)
		erro++
	Else
		_cConta := CT1->CT1_CONTA
	Endif

	dbselectarea("CT1")
	dbsetorder(1)
Else
	If _cTipoLc <> "H"  // Complemento de Historico
		_cOcorrencia := "CODIGO REDUZIDO NAO INFORMADO NO ARQUIVO TXT."
		u_Gravar_Erro(nx,21,40,_cOcorrencia,cArquiv1,cTpA,cTP, _lAuto ) 
		AtuLog(_cOcorrencia,aLog,nx)
		erro++
	Endif
	//
Endif

		// Verifica se o c.custo informado esta cadastrado
If !Empty(_cCusto)
	dbselectarea("CTT")
	dbsetorder(1)
	Dbseek(xFilial("CTT")+Substr(_cCusto,1,2))
	If !Found()
		_cOcorrencia := "CENTRO DE CUSTO "+ ALLTRIM(_cCusto) +" NAO ESTA CADASTRADO."
		u_Gravar_Erro(nx,95,103,_cOcorrencia,cArquiv1,cTpA,cTP, _lAuto ) 
		AtuLog(_cOcorrencia,aLog,nx)
		erro++
	Else
		// Verificar Bloqueio
		If CTT->CTT_BLOQ = "1"
			_cOcorrencia := "CENTRO DE CUSTO "+ ALLTRIM(_cCusto) +" ESTA BLOQUEADO PARA MOVIMENTO."
			u_Gravar_Erro(nx,95,103,_cOcorrencia,cArquiv1,cTpA,cTP, _lAuto ) 
			AtuLog(_cOcorrencia,aLog,nx)
			erro++
		Endif
		//
	Endif
Endif

		// Verifica se o Item Contabil informado esta cadastrado
if !Empty(_cCusto)
	dbselectarea("CTD")
	dbsetorder(1)
	Dbseek(xFilial("CTD")+SUBSTR(_cCusto,3,2))
	If !Found()
		_cOcorrencia := "ITEM CONTABIL "+ SUBSTR(_cCusto,3,2) +" NAO ESTA CADASTRADO."
		u_Gravar_Erro(nx,95,103,_cOcorrencia,cArquiv1,cTpA,cTP, _lAuto )   
		AtuLog(_cOcorrencia,aLog,nx)
		erro++
	Else
		// Verificar Bloqueio
		If CTD->CTD_BLOQ = "1"
			_cOcorrencia := "ITEM CONTABIL "+ SUBSTR(_cCusto,3,2) +" ESTA BLOQUEADO PARA MOVIMENTO."
			u_Gravar_Erro(nx,95,103,_cOcorrencia,cArquiv1,cTpA,cTP, _lAuto )  
			AtuLog(_cOcorrencia,aLog,nx)
			erro++
		Endif
	Endif
Endif

// Verifica se a Classe de Valor informada esta cadastrada
If !Empty(_cCusto)
	dbselectarea("CTH")
	dbsetorder(1)
	Dbseek(xFilial("CTH")+SUBSTR(_cCusto,5,2))
	If !Found()
		_cOcorrencia := "CLASSE DE VALOR "+ SUBSTR(_cCusto,5,2) +" NAO ESTA CADASTRADA."
		u_Gravar_Erro(nx,95,103,_cOcorrencia,cArquiv1,cTpA,cTP, _lAuto )
		AtuLog(_cOcorrencia,aLog,nx)
		erro++
	Else
		// Verificar Bloqueio
		If CTH->CTH_BLOQ = "1"
			_cOcorrencia := "CLASSE DE VALOR "+ SUBSTR(_cCusto,5,2) +" ESTA BLOQUEADA PARA MOVIMENTO."
			u_Gravar_Erro(nx,95,103,,_cOcorrencia,cArquiv1,cTpA,cTP, _lAuto )  
			AtuLog(_cOcorrencia,aLog,nx)
			erro++
		Endif
	Endif
Endif

// Verifica se o historico do lancamento foi informado
If Empty(_cHistor)
	_cOcorrencia := "HISTORICO DO LANCAMENTO NAO INFORMADO NO ARQUIVO TXT."
	u_Gravar_Erro(nx,41,80,_cOcorrencia,cArquiv1,cTpA,cTP, _lAuto ) 
	AtuLog(_cOcorrencia,aLog,nx)
	erro++
Endif

if _cTipoLc <> "H"  // Complemento de Historico
	If Empty(_nVlrCont)
		_cOcorrencia := "VALOR DO LANCAMENTO ESTA ZERADO NO ARQUIVO TXT."
		u_Gravar_Erro(nx,81,94,_cOcorrencia,cArquiv1,cTpA,cTP, _lAuto )   
		AtuLog(_cOcorrencia,aLog,nx)
		erro++
	Endif
Endif

If erro = 0
	AADD(aVet3,{_cTipoLc,_dLancto,_cConta,_cHistor,_nVlrCont,_cCusto})
Endif

// Totaliza Debitos / Creditos
If _cTipoLc = "D"
	_nTotalDeb += _nVlrCont
Else
	_nTotalCre += _nVlrCont
Endif

dbselectarea("CT5")
dbsetorder(1)
Dbseek(xFilial("CT5")+cPadrao)
If !Found()
	_cOcorrencia := "LANCAMENTO PADRAO "+cPadrao+" NAO CADASTRADO."
	u_Gravar_Erro(0,0,0,_cOcorrencia,cArquiv1,cTpA,cTP, _lAuto )
	AtuLog(_cOcorrencia,aLog,0)
	erro++
	lAborta := .F.
	lMSG    := .F.
Endif

// Se nao existir inconsistencias executa contabilizacao
dbselectarea("TRE")
If Reccount() = 0 .or. (lAborta = .F. .and. erro = 0)
	ContabConsumo(cTpA)
Else
	lAborta := .F. 
Endif
			
return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบPrograma  ณ ContabConsumo บ Autor ณJose Carlos Noronhaบ Data ณ03/04/08 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDescricao ณ Contabilizacao da integracao de lancamentos de consumo     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ContabConsumo(cTpA)

Local cPadrao   := GetMv("MV_XLPRDOR")
Local cOrigem   := "CTBA102"
Local cArquivo  := " "
Local cLote     := ""
Local lPadrao   := VerPadrao(cPadrao)
Local nHdlPrv   := 0
Local nTotal    := 0
Local lMostra   := _MV_PAR02
Local lAglutina := _MV_PAR03
Local ni        := 0      
	
// variaveis fixas no registro
Local SBLOTE := '001'
LOCAL MOEDLC := '01'
LOCAL MOEDS  := '12222'
LOCAL CCD    := '01'
LOCAL CCC    := '01' 
LOCAL ITEMD  := '10'
LOCAL ITEMC  := '10'
LOCAL CLVLDB := '07'
LOCAL CLVLCR := '07'
LOCAL EMPORI := 'F5'
LOCAL FILORI := '01'
LOCAL TPSALDO:= 1
	
If !lPadrao
	Alert("Lan็amento Padrao: "+cPadrao+" Nao Esta Cadastrado.")
	Return
Endif

cLote := "008860"

nHdlPrv  := HeadProva(cLote,cOrigem,Substr(cUsuario,7,6),@cArquivo)

/* Limpar Tabela Auxiliar Criada para Contabilizacao
dbselectarea("TMPZZ2")
ZAP */

// Carregar Tabela Auxiliar com Valores para Contabilizacao
nSeq := 0
For ni := 1 to Len( aVet3 )
	If aVet3[ni,1] = "H"
		Reclock("ZZ2",.F.)
			Replace ZZ2_HIST With ALLTRIM(Z2_HISTOR)+aVet3[ni,4]
		Msunlock()
	Else
		nSeq++
		dbselectarea("ZZ2")
		Reclock("ZZ2",.T.)
		Replace ZZ2_FILIAL With xFilial("ZZ2")
		Replace ZZ2_DEBITO With Iif(aVet3[ni,1] = "D",aVet3[ni,3],"")
		Replace ZZ2_TIPO   With aVet3[ni,1]
		Replace ZZ2_DATA   With aVet3[ni,2]
		Replace ZZ2_CCD    With Iif(aVet3[ni,1] = "D",Substr(aVet3[ni,6],1,2),"")
		Replace ZZ2_ITDEB  With Iif(aVet3[ni,1] = "D",Substr(aVet3[ni,6],3,2),"")
		Replace ZZ2_CLADEB With Iif(aVet3[ni,1] = "D",Substr(aVet3[ni,6],5,2),"")
		Replace ZZ2_CREDIT With Iif(aVet3[ni,1] = "C",aVet3[ni,3],"")
		Replace ZZ2_CCC    With Iif(aVet3[ni,1] = "C",Substr(aVet3[ni,6],1,2),"")
		Replace ZZ2_ITCRE  With Iif(aVet3[ni,1] = "C",Substr(aVet3[ni,6],3,2),"")
		Replace ZZ2_CLACRE With Iif(aVet3[ni,1] = "C",Substr(aVet3[ni,6],5,2),"")
		Replace ZZ2_SEQ    With Strzero(nSeq,2)
		Replace ZZ2_VALOR  With aVet3[ni,5]
		Replace ZZ2_HIST   With aVet3[ni,4]
		If ni+1 <= Len(aVet3)
			If aVet3[ni+1,1] = "H"
				Replace ZZ2_HIST With ALLTRIM(Z2_HISTOR)+aVet3[ni+1,4]
			Endif
		Endif
		Msunlock()
		If cTpA = "3"
			nTotal += ZZ2->Z2_VALOR
		Else
			nTotal += DetProva(nHdlPrv,cPadrao,cOrigem,cLote)
		Endif
		nInc++
	Endif
	DDATABASE := ZZ2->ZZ2_DATA
Next

// Chama rotina para contabilizacao
If nTotal > 0
	If cTpA = "3"
		Dbselectarea("ZZ2")
		dbgotop()
		Do While !Eof()
			nTotal    := 0
			DDATABASE := ZZ2->ZZ2_DATA
			Do While !Eof() .AND. DDATABASE = ZZ2->ZZ2_DATA
				nTotal += DetProva(nHdlPrv,cPadrao,cOrigem,cLote)
				dbskip()
			Enddo
			Processa({||RodaProva(nHdlPrv,nTotal)}, "Contabilizando  " )
			cA100Incl(cArquivo,nHdlPrv,3,cLote,lMostra,lAglutina)
			Dbselectarea("ZZ2")
		Enddo
	Endif
	lMsg    := .T.
	lMSGFim := .T.
Endif

// Retorna data base
DDATABASE := DBASEOLD

Return     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณImpContasPag บ Autor ณ THIAGO PEREIRAบ Data ณ 03/04/08 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Gerar Titulo no Contas a pagar via execauto a partir dos   บฑฑ
ฑฑบ          ณ dados do arquivo TXT                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ImpCAD(nx,xcTexto)

Private dEmissao    := DDATABASE
Private dVencto     := DDATABASE
Private cTp                
Private nOpc        := 3  
Private lMsErroAuto := .f.
Private _cArqs      := ""
Private aVet1       := {} 
Private aVet2       := {} // VETOR Titulos Provisorios// VETOR Titulos Provisorios
Private aVet3       := {} // VETOR Titulos Provisorios
Private aVet4       := {} // VETOR Titulos Provisorios
Private nValorTit   := 0
Private DBASEOLD    := DDATABASE
Private _cEmpresa
Private _cFilial
Private lLpad       := .T.
Private _cCtaCred   := ""
Private _nVlrDesc   := 0   

erro := 0  
_lAuto := .T. 


_cEmpresa 	:= Substr(xcTexto,2,2)                // Empresa
//_cFilial  	:= Substr(xcTexto,4,8)                // Filial
_cCNPJ    	:= Substr(xcTexto,4,14)        // CNPJ
_cNome    	:= Substr(xcTexto,18,40)        // Nome
_cNReduz  	:= Substr(xcTexto,058,20)        // Nome Reduzido


// Verifica se a empresa/filial do arquivo eh a mesma em que esta selecionada
If _cEmpresa != CEMPANT
	_cOcorrencia := "EMPRESA DO TXT DIFERENTE DA EMPRESA LOGADA."       
	u_Gravar_erro(nx,2,8,_cOcorrencia,cArquiv1,cTpA,cTP,.t.)     
	AtuLog(_cOcorrencia,aLog,nx)
	erro++
	lErroEmpFil = .T.
Endif
			
If cTpA = "1"      // Integracao Clientes
	_cPessoa := Substr(cBuffer,086,01)       // Tipo de Pessoa: Fisica / Juridica
	nPos     := 0
	_cTab    := "SA1"  //TABELA CLIENTE
ElseIf cTpA = "2"  // Integracao Fornecedores
	nPos     := 0
	_cTab    := "SA2"
Endif

	dbselectarea(_cTab)//SA1 OU SA2
	dbsetorder(3)  // Filial+CGC
	Dbseek(xFilial(_cTab)+_cCNPJ)
	if Found()
		lInc := .F.
		lMSG     := .T. 
		lMSGFim  := .T. 
		//
	Else
		lInc := .T. // INCLUI UM NOVO CLIENTE/FORNECEDOR
	Endif

	dbsetorder(1)
	If lInc 
		_cEnderec := NoAcento(Substr(xcTexto,087+nPos,40))      
		_cMunicip := NoAcento(Substr(xcTexto,127+nPos,15))       
		_cBairro  := NoAcento(Substr(xcTexto,142+nPos,30))       
		_cEstado  := Substr(xcTexto,172+nPos,02)       
		_cCEP     := Substr(xcTexto,174+nPos,08)       
		_cDDD     := Substr(xcTexto,182+nPos,03)      
		_cTelef   := Substr(xcTexto,185+nPos,15)       
		_cFax     := Substr(xcTexto,200+nPos,15)       
		_cContato := NoAcento(Substr(xcTexto,215+nPos,15))  
		_cInscEst := Substr(xcTexto,230+nPos,18)       
		_cInscMun := Substr(xcTexto,248+nPos,18)      
		_cTipo    := Substr(xcTexto,266+nPos,01)       
		_cConta := Substr(xcTexto,267+nPos,20)       
	    _cNaturez   := Substr(xcTexto,287+nPos,10)      
//		_cConta := STRZERO(VAL(_cConta),20)	
		If cTpA = "2"  // Integracao Fornecedores
			_cBanco 	:=	Substr(xcTexto,297+nPos,03)
			_cAgencia  	:=	Substr(xcTexto,300+nPos,05)
			_cContaCor	:=	Substr(xcTexto,305+nPos,10)
		Endif	    

		If cTpA = "1"  // Integracao Clientes
			_cNat3 := Substr(xcTexto,297+nPos,10)       // Natureza para Glosa
			_cNat2 := Substr(xcTexto,307+nPos,10)       // Natureza para Adiantamento
        Endif

		If Empty(_cEnderec)
			_cEnderec := "RUA"
		Endif
	
			If Empty(_cMunicip)
			   _cMunicip := "RIO DE JANEIRO"
			endif
			
			If Empty(_cEstado)
			   _cEstado := "RJ"
			endif
	
			If Empty(_cNome)
				erro++
				_cOcorrencia := IIF(LEN(ALLTRIM(_cCNPJ))==11,"CPF: ","CNPJ: ")+_cCNPJ+" - NOME NAO PREENCHIDO NO ARQUIVO TXT."   
				U_Gravar_erro(NX,26,65,_cOcorrencia,cArquiv1,cTpA,cTP,_lAuto)     
				AtuLog(_cOcorrencia,aLog,nx)
			endif
			
			If Empty(_cNReduz) .and. !Empty(_cNome)
				_cNReduz := Left(_cNome,20)
			endif
			
			If cTpA = "1"      // Integracao Clientes
				If Empty(_cPessoa)
					erro++
					_cOcorrencia := IIF(LEN(ALLTRIM(_cCNPJ))==11,"CPF: ","CNPJ: ")+_cCNPJ+" - TIPO DE PESSOA NAO PREENCHIDO NO ARQUIVO TXT."       
					U_Gravar_erro(NX,86,86,_cOcorrencia,cArquiv1,cTpA,cTP,_lAuto)     
					AtuLog(_cOcorrencia,aLog,nx)
				Endif
			Endif
			
			If Empty(_cEnderec)
				erro++
				_cOcorrencia := IIF(LEN(ALLTRIM(_cCNPJ))==11,"CPF: ","CNPJ: ")+_cCNPJ+" - ENDERECO NAO INFORMADO NO ARQUIVO TXT." 
				U_Gravar_erro(NX,87+nPos,126+nPos,_cOcorrencia,cArquiv1,cTpA,cTP,_lAuto)   
				AtuLog(_cOcorrencia,aLog,nx)
			endif
			
			If Empty(_cMunicip)
				erro++
				_cOcorrencia := IIF(LEN(ALLTRIM(_cCNPJ))==11,"CPF: ","CNPJ: ")+_cCNPJ+" - MUNICIPIO NAO INFORMADO NO ARQUIVO TXT."
				U_Gravar_erro(NX,127+nPos,141+nPos,_cOcorrencia,cArquiv1,cTpA,cTP,_lAuto) 
				AtuLog(_cOcorrencia,aLog,nx)
			endif
			
			If Empty(_cEstado)
				erro++
				_cOcorrencia := IIF(LEN(ALLTRIM(_cCNPJ))==11,"CPF: ","CNPJ: ")+_cCNPJ+" - ESTADO NAO INFORMADO NO ARQUIVO TXT."
				U_Gravar_erro(NX,172+nPos,173+nPos,_cOcorrencia,cArquiv1,cTpA,cTP,_lAuto) 
				AtuLog(_cOcorrencia,aLog,nx)
			endif
			
			If Empty(_cConta)
				erro++
				_cOcorrencia := IIF(LEN(ALLTRIM(_cCNPJ))==11,"CPF: ","CNPJ: ")+_cCNPJ+" - CONTA CONTABIL NAO INFORMADA NO ARQUIVO TXT."
				U_Gravar_erro(NX,267+nPos,286+nPos,_cOcorrencia,cArquiv1,cTpA,cTP,_lAuto)  
				AtuLog(_cOcorrencia,aLog,nx)
			ElseIf Empty(Posicione("CT1",2,xFilial("CT1")+_cConta,"CT1_CONTA")) 
				erro++			
				_cOcorrencia := "CODIGO REDUZIDO ( "+ALLTRIM(_cConta)+" ) NAO ENCONTRADA NO PLANO DE CONTAS." 
				U_Gravar_erro(NX,267+nPos,286+nPos,_cOcorrencia,cArquiv1,cTpA,cTP,_lAuto)  
				AtuLog(_cOcorrencia,aLog,nx)
			Endif
			
			If Empty(_cNaturez)
				erro++
				_cOcorrencia := IIF(LEN(ALLTRIM(_cCNPJ))==11,"CPF: ","CNPJ: ")+_cCNPJ+" - NATUREZA NAO INFORMADA NO ARQUIVO TXT."     
				U_Gravar_erro(NX,287+nPos,295+nPos,_cOcorrencia,cArquiv1,cTpA,cTP,_lAuto)  
				AtuLog(_cOcorrencia,aLog,nx)
			ElseIf Empty(Posicione("SED",1,xFilial("SED")+_cNaturez,"ED_CODIGO"))  
				erro++
				_cOcorrencia := IIF(LEN(ALLTRIM(_cCNPJ))==11,"CPF: ","CNPJ: ")+_cCNPJ+" - NATUREZA ( "+ALLTRIM(_cNaturez)+" ) NAO ENCONTRADA NO CADASTRO DE NATUREZAS."  // ok 24/06/08
				U_Gravar_erro(NX,287+nPos,295+nPos,_cOcorrencia,cArquiv1,cTpA,cTP,_lAuto)  
				AtuLog(_cOcorrencia,aLog,nx)
			endif
			
		lCPFVazio := .F.
		If _cCNPJ = Replicate("0",14) .or. Empty(VAL(_cCNPJ))
			lCPFVazio := .T.
			lMSG      := .T.
			lMSGFim   := .T.
		ElseIf Empty(_cCNPJ)
			lCPFVazio := .T.
			lMSG      := .T.
			lMSGFim   := .T.
		ElseIf left(_cCNPJ,11) $ "22222222222|33333333333|44444444444|55555555555|66666666666|77777777777|88888888888|99999999999" 
			_cOcorrencia := "CPF/CNPJ ( "+ALLTRIM(_cCNPJ)+" ) EH INVALIDO."              
			U_Gravar_erro(NX,12,25,_cOcorrencia,cArquiv1,cTpA,cTP,_lAuto)  
			AtuLog(_cOcorrencia,aLog,nx)
			erro++
		Endif
			
		If erro = 0 .and. lCPFVazio = .F.
			If lInc  // VARIAVEL QUE INDICA INCLUSAO
				cCodigo :=ProcCodigo(cCodigo,cTpA)
				RecLock(_cTab,.T.)
				nInc++
				If cTpA = "1"      // Integracao Clientes
					SA1->A1_FILIAL  := xFilial("SA1")
					SA1->A1_COD     := cCodigo
					SA1->A1_LOJA	 := "01"
				ElseIf cTpA = "2"  // Integracao Fornecedores
					SA2->A2_FILIAL  := xFilial("SA2")               
					SA2->A2_COD     := cCodigo 
					SA2->A2_LOJA    := "01"
				Endif
			Else
				RecLock(_cTab,.F.)
				nAlt++
			Endif
				
			If cTpA = "1"      // Integracao Clientes
				cCodigo := SA1->A1_COD
				SA1->A1_NOME   		:= _cNOME
				SA1->A1_NREDUZ 		:= _cNREDUZ
				SA1->A1_PESSOA   	   := _cPESSOA
				SA1->A1_CGC    	   := _cCNPJ
				SA1->A1_END    		:= _cENDEREC
				SA1->A1_BAIRRO 		:= _cBAIRRO
				SA1->A1_MUN    		:= _cMUNICIP
				SA1->A1_EST    		:= _cESTADO
				SA1->A1_CEP    		:= _cCEP
				SA1->A1_TEL    		:= _cTELEF
				SA1->A1_FAX    		:= _cFAX
				SA1->A1_CONTATO 		:= _cCONTATO
				SA1->A1_DDD     		:= _cDDD
				SA1->A1_ENDCOB  		:= _cENDEREC
				SA1->A1_ENDENT  		:= _cENDEREC
				SA1->A1_ENDREC  		:= _cENDEREC
				SA1->A1_INSCR   		:= _cINSCEST
				SA1->A1_INSCRM  		:= _cINSCMUN
				SA1->A1_TIPO    		:= _cTIPO	 
				SA1->A1_CONTA   		:= Posicione("CT1",2,xFilial("CT1")+_cConta,"CT1_CONTA")
				SA1->A1_NATUREZ  		:= _cNATUREZ
		           SA1->A1_RECISS       := "1"  					// Recolhe ISS      
		           SA1->A1_INCISS       := "S"     				// ISS no Preco
		           SA1->A1_RECINSS      := SED->ED_CALCINS  // Recolhe INSS igual ao da Natureza
		           SA1->A1_RECCOFI      := SED->ED_CALCCOF  // Recolhe COFINS igual ao da Natureza
		           SA1->A1_RECCSLL      := SED->ED_CALCCSL  // Recolhe CSLL igual ao da Natureza
		           SA1->A1_RECPIS       := SED->ED_CALCPIS  // Recolhe PIS igual ao da Natureza
				SA1->A1_MSBLQL       := "2"					// Bloqueado 1-Sim 2-Nao
			   SA1->A1_XNAT3 := _cNAT3
			   SA1->A1_XNAT2 := _cNAT2
				SA1->A1_XWPD  := "S"
				//
			ElseIf cTpA = "2"  // Integracao Fornecedores
				cCodigo := SA2->A2_COD
				SA2->A2_NOME   		:= _cNOME
				SA2->A2_NREDUZ 		:= _cNREDUZ
				SA2->A2_CGC    	   := _cCNPJ
				SA2->A2_END    		:= _cENDEREC
				SA2->A2_BAIRRO 		:= _cBAIRRO
				SA2->A2_MUN    		:= _cMUNICIP
				SA2->A2_EST    		:= _cESTADO
				SA2->A2_CEP    		:= _cCEP
				SA2->A2_TEL    		:= _cTELEF
				SA2->A2_FAX    		:= _cFAX
				SA2->A2_CONTATO 		:= _cCONTATO
				SA2->A2_DDD     		:= _cDDD
				SA2->A2_INSCR   		:= _cINSCEST
				SA2->A2_INSCRM  		:= _cINSCMUN
				SA2->A2_TIPO    		:= _cTIPO	 
				SA2->A2_CONTA   		:= Posicione("CT1",2,xFilial("CT1")+_cConta,"CT1_CONTA")
				SA2->A2_NATUREZ  		:= _cNATUREZ
		           SA2->A2_RECISS       := "N"  					// Recolhe ISS      
		           SA2->A2_RECINSS      := SED->ED_CALCINS  // Calcula INSS igual ao da Natureza
		           SA2->A2_RECCOFI      := "2"				   // Recolhe COFINS
		           SA2->A2_RECCSLL      := "2"              // Recolhe CSLL
		           SA2->A2_RECPIS       := "2"              // Recolhe PIS
				SA2->A2_MSBLQL       := "2"              // Bloqueado 1-Sim 2-Nao
			    SA2->A2_BANCO   := _cBanco
			    SA2->A2_AGENCIA := _cAgencia
			    SA2->A2_NUMCON  := _cContaCor
//				SA2->A2_XWPD  := "S"
			Endif
			MSUnLock()
            AADD(ALOG, "Registro " + alltrim(UPPER(_cNOME)) + " INCLUIDO COM SUCESSO .")
			
			dbselectarea("ZZ1")
			RECLOCK("ZZ1",.T.)
				ZZ1->ZZ1_FILIAL := CFILANT
				ZZ1->ZZ1_ARQUIV:= cArquiv1
				ZZ1->ZZ1_DTINTE:= DDATABASE
				ZZ1->ZZ1_LAYOUT := CTPA
				ZZ1->ZZ1_CLIFOR := cCodigo
				ZZ1->ZZ1_LOJA   := "01"
				ZZ1->ZZ1_EMISSAO := DDATABASE
			MSUnLock()
		ELSE
            AADD(ALOG, "REGISTRO COM ERROS, FAVOR VERIFICAR. Registro com erros.")		
		Endif
	Endif
			
return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบPrograma  ณ ProcCodigo    บ Autor ณTHIAGO PEREIRA     บ Data ณ03/04/08 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDescricao ณ Busca Proximo Codigo Cliente                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ProcCodigo(cCodigo,cTpA)

If cTpA = "1"      // Integracao Clientes                                                          /
	_cTab   := "SA1"
	c_query := " SELECT MAX(A1_COD) AS UCOD FROM "+RetSqlname("SA1") + " WHERE D_E_L_E_T_ = ' '  AND LENGTH(TRIM(A1_COD))=6 AND A1_LOJA <> '00' "     
ElseIf cTpA = "2"  // Integracao Fornecedores
	_cTab   := "SA2"
	c_query := " SELECT MAX(A2_COD) AS UCOD FROM "+RetSqlname("SA2") + " WHERE D_E_L_E_T_ = ' '  AND LENGTH(TRIM(A2_COD))=6 AND A2_COD NOT LIKE 'ESTADO%' "
ENDIF

TCQUERY c_Query ALIAS "TRC" NEW
	
dbselectarea("TRC")
If ! Empty(TRC->UCOD)
	cCodigo := TRC->UCOD
Else
	cCodigo := "000001"
Endif

DbClosearea()

dbselectarea(_cTab)
dbsetorder(1)
dbseek(xFilial(_cTab)+cCodigo+"01")
If Found()
	Do While !EOF()
		nCodigo := Val(cCodigo)+1
		cCodigo := Strzero(nCodigo,6)
		dbseek(xFilial(_cTab)+cCodigo+"01")
	Enddo
Endif

Return(cCodigo)          

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณMultNatCP  บ Autor ณ Eduardo Brust      บ Data ณ 13/05/08   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Gera MultNatureza para o titulo a Pagar                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ  TABELA SEV                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/                                          
Static Function MultNatCP(aVet1,nr,aVet4,ni,nTotTit,nz)

Local nValMN := Round(aVet4[ni,2]/Len(aVet1),2)        

chave := aVet1[nr,2] // PREFIXO
chave += aVet1[nr,3] // TITULO
chave += aVet1[nz,4] // PARCELA
chave += aVet1[nr,5] // TIPO
chave += aVet1[nr,10] // FORNECEDOR
chave += aVet1[nr,11] // LOJA

chave += aVet4[ni,1]  // NATUREZA

DbSelectArea("SEV")
DbSeek(xFilial("SEV")+ chave)
If ( SEV->(EOF()) )
	Reclock("SEV",.T.)
	SEV->EV_FILIAL 	:= xFilial("SEV")
	SEV->EV_PREFIXO	:= aVet1[nr,2]
	SEV->EV_NUM			:= aVet1[nr,3]
	SEV->EV_PARCELA	:= aVet1[nz,4]
	SEV->EV_TIPO		:= aVet1[nr,5]
	SEV->EV_CLIFOR		:= aVet1[nr,10]
	SEV->EV_LOJA		:= aVet1[nr,11]
	SEV->EV_NATUREZ	:= aVet4[ni,1]
	SEV->EV_RATEICC	:= "2"
	SEV->EV_IDENT  	:= "1"

	//
Endif
MsUnlock()
Reclock("SEV",.F.)
	SEV->EV_VALOR	+= nValMN 
	SEV->EV_RECPAG	:= "P"
	SEV->EV_PERC	:= SEV->EV_VALOR/nTotTit   
MsUnlock()

Return(nValMN)

Static Function Retname()
Return UsrRetName(RetCodUsr()) 


