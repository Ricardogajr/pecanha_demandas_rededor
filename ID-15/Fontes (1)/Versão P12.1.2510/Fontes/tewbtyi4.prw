#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*
{Protheus.doc} TEWBTYI4
Importação de dados bancários para preenchimentos dos campos customizados para CNAB. 
@Author     Ramon Teodoro e Silva
@Since      12/11/2020     
@Version    P12.27
@Return
*/
User Function TEWBTYI4(lDebug)
Local aSay := {}
Local aButton := {}
Local nOpc := 0
Local Titulo := 'Importação planilha ajuste campos CNAB'
Local cDesc1 := 'Esta rotina fará a importação de informações para carga dos campos para o CNAB'
Local cDesc2 := 'conforme layout predefinido.'
Local cDesc3 := ''
Local aDados := {}

DEFAULT lDebug = .T.


Private aErros 	 := {}
Private cTempDir :=  GetTempPath()
Private cTexto   := ""  

/*If lDebug
	RpcClearEnv()
	RpcSetType( 3 )
 
	RpcSetEnv( "01", "01010004" )
EndIf*/

aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aButton, { 1, .T., { || nOpc := 1, FechaBatch() } } )
aAdd( aButton, { 2, .T., { || FechaBatch() } } )
FormBatch( Titulo, aSay, aButton )
If nOpc == 1
	//If ValidaMes(dDataBase,cLote,cSub,cDoc)
	//	If Pergunte(cPerg)
			aDados := PegaArq()
			If Len(aDados)>0
                FwMsgRun(,{|| RunProc(aDados) }, "Incluindo informações, aguarde...", "Cadastro Bancos")					
				//MsgRun("Incluindo informações, aguarde...","Cadastro Bancos",{|| RunProc(aDados) })
				//Processa( { || lOk := Runproc(aDados) },'Aguarde','Processando...',.t.)
			EndIf
			If Len(aErros)>=2
				ImpExcel(aErros,.t.)
			EndIf
	//	EndIf
	//EndIf
EndIf

Return NIL

/*
{Protheus.doc} PegaArq
Função para buscar o arquivo CSV
@Author     Ramon Teodoro e Silva
@Since      12/11/2020     
@Version    P12.27
@Return
*/
Static Function PegaArq

Local aComboBx1  := {"Importar cadastros de bancos"}
Local lOk 		 := .F.
Local aDados := {}

Private cComboBx1
Private oDlg
Private c_dirimp := space(100)
Private _nOpc	 := 0

while !lOk
	
	DEFINE MSDIALOG oDlg TITLE "Importação de Dados" FROM 000,000 TO 170,320 PIXEL //170 alt 320 larg
	@ 010,009 Say "Processo" Size 059,008 COLOR CLR_BLACK PIXEL OF oDlg   //007
	@ 018,009 ComboBox cComboBx1 Items aComboBx1 Size 121,010 PIXEL OF oDlg  //015
	@ 033,009 Say   "Diretorio"       Size 045,008 PIXEL OF oDlg   //030
	@ 041,009 MSGET c_dirimp          Size 120,010 WHEN .F. PIXEL OF oDlg  //038
	*-----------------------------------------------------------------------------------------------------------------*
	*Buscar o arquivo no diretorio desejado.                                                                          *
	*Comando para selecionar um arquivo.                                                                              *
	*Parametro: GETF_LOCALFLOPPY - Inclui o floppy drive local.                                                       *
	*           GETF_LOCALHARD   - Inclui o Harddisk local.                                                           *
	*-----------------------------------------------------------------------------------------------------------------*
	@ 041,140 BUTTON "..."            SIZE 013,013 PIXEL OF oDlg   Action(c_dirimp := cGetFile("*.csv|*.csv","Importacao de Dados",0, ,.T.,GETF_LOCALHARD))
	
	*-----------------------------------------------------------------------------------------------------------------*
	
	@ 065,30 Button "OK"       Size 037,012 PIXEL OF oDlg Action(_nOpc := 1,oDlg:End())
	@ 065,90 Button "Cancelar" Size 037,012 PIXEL OF oDlg Action (_nOpc := 2,oDlg:end())
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If _nOpc == 1
		If c_dirimp != ''
			cTempDir := substr(c_dirimp,1,rat('\',c_dirimp))
			Processa({|| aDados := LEARQ()  },"Importando Cadastro de bancos ...")
			lOk:=.T.
			
		else
			Alert("Selecione um arquivo para ser importado!")
			lOk:=.F.
		endif
	else
		lOk:=.T.
	endif
	
Enddo

Return aDados

/*
{Protheus.doc} LeArq
Função para fazer a leitura do arquivo
@Author     Ramon Teodoro e Silva
@Since      12/11/2020     
@Version    P12.27
@Return
*/
Static Function LeArq()

Local cArquiv
Local nContLin	 := 0
Local nContCol 	 := 0
Local nLinBranco := 0

Private lMsErroAuto := .F.
Private cDiretor 	:= "C:\TEMP\"

cDiretor := IIF(Right(cDiretor,1) == "\", cDiretor, cDiretor+"\" )
cArquiv  := c_dirimp
c_ren    :=  cDiretor+"\"+STRTRAN(UPPER(cArquiv),".CSV",".IMP")
lRenFile := .T.
lAtuData := .F.

FT_FUSE(cArquiv)
FT_FGOTOP()
ProcRegua(FT_FLASTREC())
aDados := {}
nContLin := 0

/**************************************
* Inicio do Processamento do Arquivo  *
***************************************/
cTexto += "==========================================================================="+Chr(13)+Chr(10)
cTexto += TIME()+"  -  Processamento do arquivo iniciado " +Chr(13)+Chr(10)
cTexto += "==========================================================================="+Chr(13)+Chr(10)

While !FT_FEOF()
	
	cBuffer:=FT_FREADLN()
	cBuffer := NoAcento(cBuffer)
	ATmpDados := {}
	nContLin++
	IncProc("Lendo o Arquivo...")
	//Se a linha estiver em branco será descartada
	If Empty(Trim(StrTran(cBuffer,";","")) )
		nLinBranco++
		//se a variazel nlinbranco for maior que 5, significa que já se acabaram os itens e daí pra frente vem somente item em branco
		If nLinBranco > 5
			Exit
		Endif
		
		FT_FSKIP()
		Loop
	Endif
	nLinBranco := 0
	xPos := AT(";",cBuffer)
	nContCol := 0
	
	//Varre a linha toda pegando as colunas pois estão separadas por ;
	While xPos <> 0
		
		cInfo  := SubStr(cBuffer , 1, xPos-1 )
		AAdd( aTmpDados , cInfo )
		
		cBuffer:= SubStr(cBuffer , xPos+1, Len(cBuffer)-xPos)
		xPos := AT(";",cBuffer)
	Enddo
	//Caso o csv não tenha terminado com ; e ainda tenha algum dado após o último ;, é necessário alimentar o aTmpDados
	if !Empty(cBuffer)
		cInfo  := SubStr(cBuffer , 1, Len(cBuffer) )
		AAdd( aTmpDados , cInfo )
	Else
		AAdd( aTmpDados , "" )
	endif
	
	//Adiciona a linha ao vetor aDados que será usado para incluir os dados bancários
	If Len(aTmpDados) > 0
		AAdd( aDados , aTmpDados )
	EndIf
	
	FT_FSKIP()
	
Enddo

cTexto += "Registros importados: " + Alltrim(Str(Len(aDados)-1))+Chr(13)+Chr(10)
cTexto += "==========================================================================="+Chr(13)+Chr(10)
cTexto += TIME()+"  -  Processamento do arquivo finalizado " +Chr(13)+Chr(10)
cTexto += "==========================================================================="+Chr(13)+Chr(10)
FT_FUSE()
/**************************************
* Fim do Processamento do Arquivo  *
***************************************/
Return aDados

/*
{Protheus.doc} Runproc
Grava os dados na tabela de bancos e gera log.
@Author     Ramon Teodoro e Silva
@Since      12/11/2020     
@Version    P12.27
@Return
*/
Static Function Runproc(aDados)
Local lRet      := .T.
Local aPos      := {} 
Local cLinha    := '001'
Local nI        := 0
Local lErro     := .F.
Local cArqLog   := ""
Local cFile     := ""
Local aNotF     := {}
Local nF        := 0
Local cAliasRec := ""

Private nTotal
PRIVATE lMsErroAuto := .f.

//filial;codbanco;agencia;conta;contacnab;agenciacnab;dvcontacnab;dvagenciacnab
AAdd(aPos,{"filial"  ,0})
AAdd(aPos,{"codbanco",0})
AAdd(aPos,{"agencia" ,0})
AAdd(aPos,{"conta"   ,0})
AAdd(aPos,{"contacnab"    ,0})
AAdd(aPos,{"agenciacnab"  ,0})
AAdd(aPos,{"dvcontacnab"  ,0})
AAdd(aPos,{"dvagenciacnab",0})

For nI:=1 To Len(aPos)
	aPos[nI,2]:= AScan(aDados[1],{|x| UPPER(Trim(x))==UPPER(Trim(aPos[nI,1]))})
	If(aPos[nI,2])=0
		Alert("Campo obrigatório não encontrado no arquivo ->"+aPos[nI,1])
		Return .F.
	EndIf
Next

nPosFil    := AScan(aDados[1],{|x| UPPER(Trim(x))==UPPER(Trim("filial"))})
nPosCod    := AScan(aDados[1],{|x| UPPER(Trim(x))==UPPER(Trim("codbanco"))})
nPosAge    := AScan(aDados[1],{|x| UPPER(Trim(x))==UPPER(Trim("agencia"))})
nPosCon    := AScan(aDados[1],{|x| UPPER(Trim(x))==UPPER(Trim("conta"))})
nPosConCNB := AScan(aDados[1],{|x| UPPER(Trim(x))==UPPER(Trim("contacnab"))})
nPosAgeCNB := AScan(aDados[1],{|x| UPPER(Trim(x))==UPPER(Trim("agenciacnab"))})
nPosXDVCON := AScan(aDados[1],{|x| UPPER(Trim(x))==UPPER(Trim("dvcontacnab"))})
nPosXDVAGE := AScan(aDados[1],{|x| UPPER(Trim(x))==UPPER(Trim("dvagenciacnab"))})

nTamFIl :=  FWSX3Util():GetFieldStruct( "A6_FILIAL"  )[3]
nTamCod :=  FWSX3Util():GetFieldStruct( "A6_COD"     )[3]
nTamAge :=  FWSX3Util():GetFieldStruct( "A6_AGENCIA" )[3]
nTamCon :=  FWSX3Util():GetFieldStruct( "A6_NUMCON"  )[3]

nTamConCNB :=  FWSX3Util():GetFieldStruct( "A6_XCNABCC"  )[3]
nTamAgeCNB :=  FWSX3Util():GetFieldStruct( "A6_XAGCNAB"  )[3]
nTamXDVCON :=  FWSX3Util():GetFieldStruct( "A6_XDCCNAB"  )[3]
nTamXDVAGE :=  FWSX3Util():GetFieldStruct( "A6_XDACNAB"  )[3]

//INDICE 1 - SA6 A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON 

cTexto += TIME()+"  -  Processo de gravação dos dados inciado " +Chr(13)+Chr(10)
cTexto += "==========================================================================="+Chr(13)+Chr(10)

dbSelectArea("SA6")
SA6->(dbSetOrder(1))
For nI:=2 To Len(aDados)
	cLinha := cValtoChar(nI)
	IncProc("Gravando dados...")
	If SA6->(dbSeek(PADR(aDados[nI,nPosFil],nTamFil)+PADR(aDados[nI,nPosCod],nTamCod)+PADR(aDados[nI,nPosAge],nTamAge)+PADR(aDados[nI,nPosCon],nTamCon)))
		SA6->(RecLock("SA6",.F.))
		SA6->A6_XCNABCC := aDados[nI,nPosConCNB]
		SA6->A6_XAGCNAB := aDados[nI,nPosAgeCNB]
		SA6->A6_XDCCNAB := aDados[nI,nPosXDVCON]
		SA6->A6_XDACNAB := aDados[nI,nPosXDVAGE]
		SA6->(MsUnLock("SA6"))
		cTexto += SA6->("Filial: " + A6_FILIAL + " Bco: " +A6_COD+" Ag: "+Alltrim(A6_XAGCNAB)+" DV "+A6_XDACNAB+" CC: "+Alltrim(A6_XCNABCC)+" DV: "+A6_XDCCNAB)+" <= Dados incluídos com sucesso" +Chr(13)+Chr(10)		
	Else
		//Aadd( aNotF, {aDados[nI,nPosFil], aDados[nI,nPosCod], aDados[nI,nPosAge], aDados[nI,nPosCon] })	
		Aadd( aNotF, aDados[nI])
		//cTexto += SA6->("Filial: "+PADR(aDados[nI,nPosFil],nTamFil)+" Bco: " + PADR(aDados[nI,nPosCod],nTamCod)+" Ag: "+PADR(aDados[nI,nPosAge],nTamAge)+" Conta: "+PADR(aDados[nI,nPosCon],nTamCon)) + " <= Dados não encontrados no cadastro de bancos " +Chr(13)+Chr(10)		
		lErro := .T.
	EndIf
Next
      
If Len(aNotF) > 0
	
	cTexto += "==========================================================================="+Chr(13)+Chr(10)
	cTexto += TIME()+"  -  ERROS " +Chr(13)+Chr(10)
	cTexto += "==========================================================================="+Chr(13)+Chr(10)
	For nF := 1 to Len(aNotF)
		cTexto += SA6->("Filial: "+PADR(aNotF[nF,nPosFil],nTamFil)+" Bco: " + PADR(aNotF[nF,nPosCod],nTamCod)+" Ag: "+PADR(aNotF[nF,nPosAge],nTamAge)+" Conta: "+PADR(aNotF[nF,nPosCon],nTamCon)) + " <= Dados não encontrados no cadastro de bancos " +Chr(13)+Chr(10)
	Next nF
	cTexto += "==========================================================================="+Chr(13)+Chr(10)
	
	For nF := 1 to Len(aNotF)

		cQuery := "SELECT R_E_C_N_O_ REC, A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON FROM " + RetSqlName("SA6") 
		cQuery += "WHERE A6_FILIAL = '" + aNotF[nF][1] + "' AND A6_COD = '" + aNotF[nF][2] + "' AND "
		cQuery += "(A6_AGENCIA = '" + aNotF[nF][3] + "' OR A6_AGENCIA LIKE '%" + aNotF[nF][3] + "') AND "
		cQuery += "(A6_NUMCON = '" + aNotF[nF][4] + "' OR A6_NUMCON LIKE '%" + aNotF[nF][4] + "%') AND "
		cQuery += "D_E_L_E_T_ =''"
		cQuery := ChangeQuery(cQuery)
		cAliasRec := GetNextAlias() 
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRec,.F.,.T.)

		If !(cAliasRec)->(Eof())

			dbSelectArea("SA6")
			SA6->(dbSetOrder(1))
			SA6->(DbGoto((cAliasRec)->REC))

			SA6->(RecLock("SA6",.F.))
			SA6->A6_XCNABCC := aNotF[nF,nPosConCNB]
			SA6->A6_XAGCNAB := aNotF[nF,nPosAgeCNB]
			SA6->A6_XDCCNAB := aNotF[nF,nPosXDVCON]
			SA6->A6_XDACNAB := aNotF[nF,nPosXDVAGE]
			SA6->(MsUnLock("SA6"))
			cTexto += SA6->("Filial: "+PADR(aNotF[nF,nPosFil],nTamFil)+" Bco: " + PADR(aNotF[nF,nPosCod],nTamCod)+" Ag: "+PADR(aNotF[nF,nPosAge],nTamAge)+" Conta: "+PADR(aNotF[nF,nPosCon],nTamCon)) + " <= Dados ajustados com sucesso após segunda verificação" +Chr(13)+Chr(10)
		
		Else
			(cAliasRec)->(DbCloseArea())
		EndIf

	Next nF 
	 
EndIf

cTexto += "==========================================================================="+Chr(13)+Chr(10)
cTexto += TIME()+"  -  Processo de gravação dos dados finalizado " +Chr(13)+Chr(10)
cTexto += "==========================================================================="+Chr(13)+Chr(10)

cArqLog := "LOGIMPBANCO_"+DtoS(dDataBase)+"_"+Replace(Time(),":","-")+".TXT" 

If lErro
	MsgAlert("Foram encontradas inconsistencias no processo. Verifique o log")
Else
	MsgInfo("Processo finalizado com sucesso!")
EndIf

cFile := cGetFile( cArqLog,"Salvar Log",,'C:\',.T.,nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY),.F.,.T.)

If cFile <> ""
	MemoWrite(cFile,cTexto) // Grava o arquivo de log no final do processamento    
Else
	MsgAlert("Arquivo de log não gerado!")
EndIf

Return lRet 
