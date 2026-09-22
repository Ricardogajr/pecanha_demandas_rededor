#INCLUDE "protheus.ch"     

/*
|----------------------------------------------------------------------------|
|Programa  |MA110BAR  |Autor  |TECNOSUM            | Data |  10/06/2016      |
|----------------------------------------------------------------------------|
|Descrição |Ponto de entrada para incluir botão de consulta aprovação        |						  
|----------------------------------------------------------------------------|
|Uso       |REDEDOR                                                          |						  
|----------------------------------------------------------------------------|
*/

*----------------------------------------------------------------------------------------------------------*
User Function MA110BAR(cAlias,nReg,nOpcx)   
* LOCALIZAÇÃO   :  Function A110Inclui, A110Altera, A110Visual e A110Deleta responsaveis pela inclusão,
* alteração, exclusão e cópia das Solicitações de Compras. 
* EM QUE PONTO :  No inico das Funções, antes de montar a ToolBar das SCs, deve ser usado para adicionar 
* botões do usuario na toolbar da SC através do  retorno de um Array com a estrutura do botão a adicionar.  
*----------------------------------------------------------------------------------------------------------*
Local aButtons := {} 
Local aArea    := GetArea() 

If !(Inclui .Or. Altera )
	aadd(aButtons,{'BUDGETY',{|| U_fTelaAprov("SC1",SC1->(RECNO()),2)},'Consulta Aprovacao','Log de Aprovação'}) 	
EndIf

RestArea(aArea) 

Return (aButtons ) 

*-----------------------------------------------------------------------------------------------*
User Function fTelaAprov(cAlias,nReg,nOpcx)
* Cria uma tela de consulta do status da solicitacao de compras
* Parametros : ExpC1 = Alias do arquivo , ExpN1 = Numero do registro,ExpN2 = Opcao selecionada  
*-----------------------------------------------------------------------------------------------*


Local bCampo
Local oDlg, oGet
Local nAcols := 0,nOpca := 0
Local cCampos
Local cSituaca := "",lBloq := .F.
Local cPedido
Local cComprador
Local cStatus
Local cTipoSC1 := ""
Local aSavCols := aClone(aCols)
Local aSavHead := aClone(aHeader)
Local nSavN		:= n
Local oBold
Local nCntFor  := 0
Local _aCmpSCR	:= {} //Thais Paiva - Compatibilização P27
Local lRej := .F. // ticket n° 10854911
Local lLib := .F. // ticket n° 10854911
Local lPen := .F. // ticket n° 10854911
Local lBloq := .F. // ticket n° 10854911

dbSelectArea("SC1")
dbGoto(nReg)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre o arquivo SCR sem filtros    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ChkFile("SCR",.F.,"TMP")
cPedido := SC1->C1_NUM
cComprador := UsrRetName(SC1->C1_USER)
//cStatus  := IIF(SC1->C1_APROV=="L",OemToAnsi("Solicitação Liberada"),OemToAnsi("Aguardando Lib."))

// ticket n° 10854911
If SC1->C1_APROV=="L"
	lLib := .T.
Else
	lPen := .T.
EndIf 

aCols := {}
aHeader := {}

dbSelectArea("TMP")
dbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A rotina a seguir garante o funcionamento correto na base historica dos clientes, ³
//³ pois com a implementacao do parametro MV_AEAPROV que estende o controle de alcadas³
//³ para a AE, em 22/07/04 foi alterada a gravacao do tipo do doc para PC e AE afim   ³
//³ de diferenciar o tipo de doc nos arquivos SC7 e SCR sem afetar o funcionamento ant³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTipoSC1 := "SC"
MsSeek(xFilial("SCR")+cTipoSC1+SC1->C1_NUM)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aTELA[0][0],aGETS[0],Continua,nUsado:=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a montagem do aHeader com os campos fixos.               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCampos := "CR_NIVEL/CR_OBS/CR_DATALIB"
//Início - Thais Paiva - Compatibilização P27
//DbSelectArea("SX3")
//SX3->(dbSetOrder(1))
//SX3->(MsSeek("SCR"))
_aCmpSCR := FWSX3Util():GetAllFields( "SCR" , .T. )
nUsado++
aAdd(aHeader,{"Nome Aprovador","CR_XNOME","",40,0,"","","C","SCR","","","",".F."} )	
//While !SX3->(Eof()) .And. (SX3->X3_ARQUIVO == "SCR")
For _nCr := 1 to Len(_aCmpSCR)
	//If AllTrim(SX3->X3_CAMPO) $ cCampos
	If AllTrim(_aCmpSCR[_nCr]) $ cCampos
		nUsado++		
		/*AADD(aHeader,{	TRIM(X3Titulo()),;
							SX3->X3_CAMPO,;
							SX3->X3_PICTURE,;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							SX3->X3_VALID,;
							SX3->X3_USADO,;
							SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,;
							SX3->X3_CONTEXT } )*/
		AADD(aHeader,{	ALLTRIM(GetSx3Cache(_aCmpSCR[_nCr], 'X3_TITULO')),;
							GetSx3Cache(_aCmpSCR[_nCr], 'X3_CAMPO'),;
							GetSx3Cache(_aCmpSCR[_nCr], 'X3_PICTURE'),;
							GetSx3Cache(_aCmpSCR[_nCr], 'X3_TAMANHO'),;
							GetSx3Cache(_aCmpSCR[_nCr], 'X3_DECIMAL'),;
							GetSx3Cache(_aCmpSCR[_nCr], 'X3_VALID'),;
							GetSx3Cache(_aCmpSCR[_nCr], 'X3_USADO'),;
							GetSx3Cache(_aCmpSCR[_nCr], 'X3_TIPO'),;
							GetSx3Cache(_aCmpSCR[_nCr], 'X3_ARQUIVO'),;
							GetSx3Cache(_aCmpSCR[_nCr], 'X3_CONTEXT') } )
													
		//If AllTrim(SX3->X3_CAMPO) == "CR_NIVEL"
		If AllTrim(_aCmpSCR[_nCr]) == "CR_NIVEL"
			AADD(aHeader,{ OemToAnsi("Usuario"),"bCR_NOME", "@",;    //"Usuario"
				15, 0, "","","C","",""} )
			nUsado++
			AADD(aHeader,{ OemToAnsi("Situacao"),"bCR_SITUACA", "@",;    //"Situacao"
				20, 0, "","","C","",""} )
			nUsado++
			AADD(aHeader,{ OemToAnsi("Usuario Lib."),"bCR_NOMELIB", "@",;    //"Usuario Lib."
				15, 0, "","","C","",""} )
			nUsado++
		EndIf
	Endif
	//SX3->(DbSkip())
//End
Next _nCr
//Fim - Thais Paiva - Compatibilização P27
DbSelectArea("TMP")
While !Eof() .And. CR_FILIAL+CR_TIPO+Substr(CR_NUM,1,len(SC1->C1_NUM)) == xFilial("SCR")+cTipoSC1+SC1->C1_NUM
	aadd(aCols,Array(nUsado+1))
	nAcols ++
	For nCntFor := 1 To nUsado
		If aHeader[nCntFor][02] == "bCR_NOME"
			aCols[nAcols][nCntFor] := UsrRetName(TMP->CR_USER)
		ElseIf aHeader[nCntFor][02] == "bCR_SITUACA"
			Do Case
			Case TMP->CR_STATUS == "01"
				cSituaca := OemToAnsi("Aguardando") //"Aguardando"
			Case TMP->CR_STATUS == "02"
				cSituaca := OemToAnsi("Em Aprovacao") //"Em Aprovacao"
			Case TMP->CR_STATUS == "03"
				cSituaca := OemToAnsi("Aprovado")  //"Aprovado"
			Case TMP->CR_STATUS == "04"
				cSituaca := OemToAnsi("Bloqueado") //"Bloqueado"
				lBloq := .T.
			Case TMP->CR_STATUS == "05"
				cSituaca := OemToAnsi("Nivel Liberado ") // "Nivel Liberado "
			Case TMP->CR_STATUS == "06"  
				cSituaca := OemToAnsi("Rejeitado") // "Rejeitado "
				lRej := .T.
			Case TMP->CR_STATUS == "07"
				cSituaca := OemToAnsi("Nivel Rejeitado") // "Nivel Rejeitado"
				lRej := .T.
			EndCase
			aCols[nAcols][nCntFor] := cSituaca
		ElseIf aHeader[nCntFor][02] == "bCR_NOMELIB"
			aCols[nAcols][nCntFor] := UsrRetName(TMP->CR_USERLIB)
		ElseIf ( aHeader[nCntFor][10] != "V")
			aCols[nAcols][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
		EndIf
	Next nCntFor
	aCols[nAcols][nUsado+1] := .F.
	TMP->(DbSkip())
EndDo

If Empty(aCols)
	Aviso("Atencao","Esta solicitação nao possui controle de aprovacao.",{"Voltar"})       
	aCols :={}
	aCols := aClone(aSavCols)
	aHeader :={}
	aHeader := aClone(aSavHead)
	dbSelectArea("TMP")
	dbCloseArea()
	dbSelectArea(cAlias)
	Return nOpca
EndIf

// ticket n° 10854911
Do Case
Case lBloq
	cStatus := OemToAnsi("Solicitação Bloqueada")
Case lRej
	cStatus := OemToAnsi("Documento Rejeitado")
Case lLib 
	cStatus := OemToAnsi("Solicitação Liberada")
Case lPen
	cStatus := OemToAnsi("Aguardando Lib.")
EndCase
/*
If lBloq
	cStatus := OemToAnsi("Solicitação Bloqueada")
EndIf
*/
Continua := .F.
nOpca := 0
n:=	 IIF(n > Len(aCols), Len(aCols), n)  
DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
DEFINE MSDIALOG oDlg TITLE "Aprovacao da Solicitação de Compra" From 109,95 To 400,600 OF oMainWnd PIXEL	
@ 5,3 TO 32,250 LABEL "" OF oDlg PIXEL
@ 15,7 SAY OemToAnsi("Solicitação") Of oDlg FONT oBold PIXEL SIZE 46,9 
@ 14,45 MSGET cPedido  Picture "@"  When .F. PIXEL SIZE 38,9 Of oDlg FONT oBold
@ 15,103 SAY OemToAnsi("Solicitante")  Of oDlg PIXEL SIZE 33,9 FONT oBold 
@ 14,138 MSGET cComprador Picture "@" When .F. of oDlg PIXEL SIZE 103,9 FONT oBold
@ 132,8 SAY 'Situacao :' Of oDlg PIXEL SIZE 52,9 
@ 132,38 SAY cStatus Of oDlg PIXEL SIZE 120,9 FONT oBold
@ 132,205 BUTTON 'Fechar' SIZE 35 ,10  FONT oDlg:oFont ACTION (oDlg:End()) Of oDlg PIXEL  
oGet := MSGetDados():New(38,3,120,250,nOpcx,,,"")
@ 126,2   TO 127,250 LABEL '' OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

aCols :={}
aCols := aClone(aSavCols)
aHeader :={}
aHeader := aClone(aSavHead)
n		:= nSavN

dbSelectArea("TMP")
dbCloseArea()

#IFNDEF WINDOWS
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura a integridade da janela                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetCursor(cSavCur5)
	DevPos(cSavRow5,cSavCol5)
	SetColor(cSavCor5)
	RestScreen(3,0,24,79,cSavScr5)
#ENDIF

dbSelectArea(cAlias)

Return nOpca



		
