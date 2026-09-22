//#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"

/*
|----------------------------------------------------------------------------|
|Programa  |RDDA003  |Autor  |TECNOSUM            | Data |  06/06/2016       |
|----------------------------------------------------------------------------|
|Descri豫o |Amarra豫o Aprovador x Centro de Custo                            |						  
|----------------------------------------------------------------------------|
|Uso       |REDEDOR                                                          |						  
|----------------------------------------------------------------------------|
*/

User Function RDDA003()

Local cFiltro := " " 
Local cStatus := " "

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Declaracao de Variaveis                                             ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

Private cCadastro := "Amarra豫o Aprovador x Centro de Custo"


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Monta um aRotina proprio                                            ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

Private aRotina := {{"Pesquisar"  ,"AxPesqui"  ,0,1} ,;
					{"Visualizar" ,"U_RDDA003A",0,2} ,;
					{"Incluir"    ,"U_RDDA003A",0,3} ,;
					{"Alterar"    ,"U_RDDA003A",0,4} ,;
					{"Excluir"    ,"U_RDDA003A",0,5}}

Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

Private cString := "PZX" 


DbSelectArea("PZX")
DbSetOrder(1) 

mBrowse(6,1,22,75,"PZX")

Return


/*
|----------------------------------------------------------------------------|
|Programa  |RDDA001A  |Autor  |TECNOSUM            | Data |  31/03/2016       |
|----------------------------------------------------------------------------|
|Descri豫o |Amarra豫o tipo sc x motivo sc                                    |						  
|----------------------------------------------------------------------------|
|Uso       |REDEDOR                                                            |						  
|----------------------------------------------------------------------------|
*/
User Function RDDA003A(cAlias, nReg, nOpc)

Local aArea     := GetArea()
Local oDlg
Local nUsado    := 0
Local nCntFor   := 0
Local nOpca     := 0
Local aObjects  := {}
Local aPosObj   := {}
Local aSizeAut  := MsAdvSize()
Local lNopc1    := .F.
Local lNopc2    := .F.

Local aAlter       	:= {"PZX_CCUSTO", "PZX_DESCCC"}
//Local aFields		:= {"PZX_CODAPR","PZX_NOMAPR"}
Local nOpcx        	:= GD_INSERT+GD_DELETE+GD_UPDATE
Local cLinOk       	:= "U_RDDA3LOK()"/*"U_LinOk"*/    // Funcao executada para validar o contexto da linha atual do aCols
Local cTudoOk      	:= "U_RDDA3LOK()"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local cIniCpos     	:= ""               // Nome dos campos do tipo caracter que utilizarao incremento automatico.
Local nFreeze      	:= 000              // Campos estaticos na GetDados.
Local nMax         	:= 9999              // Numero maximo de linhas permitidas. Valor padrao 99
Local cFieldOk     	:= "AllwaysTrue"    // Funcao executada na validacao do campo
Local cSuperDel    	:= ""              // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cDelOk       	:= "AllwaysTrue"   // Funcao executada para validar a exclusao de uma linha do aCols
Local _aCmpPZX	:= {} //Thais Paiva - Compatibilizacao P27

Private aHeader := {}
Private aCols   := {}
Private aGets   := {}
Private aTela   := {}

Private oGetDad

*----------------------------------------------------------------
*|   Montagem de Variaveis de Memoria                             |
*----------------------------------------------------------------
If nOpc == 2
	lNopc1 :=.F.
	lNopc2 :=.F.
ElseIf nOpc == 3
	lNopc1 :=.T.
	lNopc2 :=.F.
ElseIf nOpc == 4
	lNopc1 :=.F.
	lNopc2 :=.T.
ElseIf nOpc == 5
	lNopc1 :=.F.
	lNopc2 :=.F.
EndIf

RegToMemory( "PZX", lNopc1, lNopc2 )

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Monta o aHeader                                       ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

aHeader := {}
//Inicio - Thais Paiva - Compatibilizacao P27
//DbSelectArea("SX3")
//DbSetOrder(1)
//DbSeek("PZX",.T.)
_aCmpPZX := FWSX3Util():GetAllFields( "PZX" , .T. )
nUsado := 0

//Do While ( !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "PZX" )
For _nZx := 1 to Len(_aCmpPZX)
	//If ( cNivel >= SX3->X3_NIVEL )
	If ( cNivel >= GetSx3Cache(_aCmpPZX[_nZx], 'X3_NIVEL') )
		//If (ALLTRIM(SX3->X3_CAMPO) $ "PZX_CCUSTO|PZX_DESCCC")
		If (ALLTRIM(GetSx3Cache(_aCmpPZX[_nZx], 'X3_CAMPO')) $ "PZX_CCUSTO|PZX_DESCCC")
			/*AADD(aHeader,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_F3,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX,;
			SX3->X3_RELACAO,;
			SX3->X3_WHEN,;
			SX3->X3_VISUAL,;
			SX3->X3_VLDUSER,;
			SX3->X3_PICTVAR,;
			SX3->X3_OBRIGAT})*/
			AADD(aHeader,{ AllTrim(GetSx3Cache(_aCmpPZX[_nZx], 'X3_TITULO')),;
			GetSx3Cache(_aCmpPZX[_nZx], 'X3_CAMPO'),;
			GetSx3Cache(_aCmpPZX[_nZx], 'X3_PICTURE'),;
			GetSx3Cache(_aCmpPZX[_nZx], 'X3_TAMANHO'),;
			GetSx3Cache(_aCmpPZX[_nZx], 'X3_DECIMAL'),;
			GetSx3Cache(_aCmpPZX[_nZx], 'X3_VALID'),;
			GetSx3Cache(_aCmpPZX[_nZx], 'X3_USADO'),;
			GetSx3Cache(_aCmpPZX[_nZx], 'X3_TIPO'),;
			GetSx3Cache(_aCmpPZX[_nZx], 'X3_F3'),;
			GetSx3Cache(_aCmpPZX[_nZx], 'X3_CONTEXT'),;
			GetSx3Cache(_aCmpPZX[_nZx], 'X3_CBOX'),;
			GetSx3Cache(_aCmpPZX[_nZx], 'X3_RELACAO'),;
			GetSx3Cache(_aCmpPZX[_nZx], 'X3_WHEN'),;
			GetSx3Cache(_aCmpPZX[_nZx], 'X3_VISUAL'),;
			GetSx3Cache(_aCmpPZX[_nZx], 'X3_VLDUSER'),;
			GetSx3Cache(_aCmpPZX[_nZx], 'X3_PICTVAR'),;
			GetSx3Cache(_aCmpPZX[_nZx], 'X3_OBRIGAT')})
			nUsado++
		Endif
	Endif
	//SX3->(DbSkip())
//End
Next _nZx
//Fim - Thais Paiva - COmpatibilizacao P27

*----------------------------------------------------------------+
*   Montagem do aCols                                              |
*----------------------------------------------------------------+

If nOpc <> 3

	BeginSql alias "PZXTMP"

	%noparser%
	SELECT PZX_FILIAL, PZX_CCUSTO, PZX_DESCCC
	FROM %table:PZX% PZX
	WHERE 	PZX_FILIAL = %exp:PZX->PZX_FILIAL% AND PZX_CODAPR = %exp:PZX->PZX_CODAPR% AND	%notDel%
	ORDER BY PZX_CCUSTO

	EndSql

	While (!PZXTMP->(Eof()))
		aadd(aCols,Array(nUsado+1))
		For nCntFor := 1 To nUsado
			If ( aHeader[nCntFor][10] != "V" )
				aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
			Else
				aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
				If aHeader[nCntFor][2] = "PZX_DESCCC"
					aCols[Len(aCols)][nCntFor] := Posicione("CTT",1,xFilial("CTT")+PZXTMP->PZX_CCUSTO,"CTT_DESC01")
				Endif	
			EndIf
		Next nCntFor
		aCols[Len(aCols)][Len(aHeader)+1] := .F.
		PZXTMP->(DbSkip())
	End

	If Select("PZXTMP")>0
		DbSelectArea("PZXTMP")
		DbCloseArea()
	EndIf
Endif

DbSelectArea("PZX")
DbSetOrder(1)

//****

aObjects := {}
AAdd( aObjects, { 315,  30, .T., .T. } )
AAdd( aObjects, { 100,  70, .T., .T. } )

aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DbSelectArea(cAlias)
DbGoTo(nReg)


DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
EnChoice( cAlias,nReg, nOpc, , , , , aPosObj[1], , 3, , , ,oDlg)
oGetDad:= MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],iF(INCLUI .OR. ALTERA,GD_INSERT+GD_UPDATE+GD_DELETE,0),cLinOk,cTudoOk,cIniCpos,;
aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oDlg,aHeader,aCols)


ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{ || IIF( OBRIGATORIO(AGETS,ATELA) .And. TudoOk() .and. U_RDDA3LOK(), (nOpca := 1, oDlg:END()), nOpca := 0) }, { || oDlg:END() },,)

IF  nOpca = 1
	U_GrvPZX(cAlias,nReg,nOpc)
EndIf
RestArea(aArea)

Return


/*
|----------------------------------------------------------------------------|
|Programa  |RDDA001A  |Autor  |TECNOSUM            | Data |  31/03/2016       |
|----------------------------------------------------------------------------|
|Descri豫o |Amarra豫o tipo sc x motivo sc                                    |						  
|----------------------------------------------------------------------------|
|Uso       |REDEDOR                                                            |						  
|----------------------------------------------------------------------------|
*/

User Function GrvPZX(cAlias,nReg,nOpcx)

Local nI        := 0 //Contador
Local lRet    	:= .T. // logico que permite a exclusao caso nao tenha restricao
Local aHeader 	:= aClone(oGetDad:aHeader)
Local aCols		:= aClone(oGetDad:aCols)
Local nPosCC 	:= aScan(aHeader,{|x| AllTrim(x[2])=="PZX_CCUSTO"})

DbSelectArea("PZX")
DbSetOrder(1)

If nOpcx == 5 // Exclusao

	DbSelectArea("PZX")
	DbSetOrder(1)
	DbSeek(xFilial("PZX")+M->PZX_CODAPR)
	While !PZX->(Eof()) .And. PZX->PZX_FILIAL+PZX->PZX_CODAPR = xFilial("PZX")+M->PZX_CODAPR

		Reclock("PZX",.F.)
		DbDelete()
		MsUnlock()
		PZX->(DbSkip())

	End

ElseIf nopcx == 3 .OR. nOpcx == 4
	
	DbSelectArea("PZX")
	DbSetOrder(1)
	If DbSeek(xFilial("PZX")+M->PZX_CODAPR)
	
		If nOpcx = 4
		
			/*While !PZX->(Eof()) .And. PZX->PZX_FILIAL+PZX->PZX_CODAPR = xFilial("PZX")+M->PZX_CODAPR
				Reclock("PZX",.F.)
				DbDelete()
				MsUnlock()
				PZX->(DbSkip())
			End
			
			DbSeek(xFilial("PZX")+M->PZX_CODAPR)*/
			For nI := 1 to Len(aCols)
				If !aCols[nI][Len(aCols[nI])] .And. !Empty(aCols[nI][1]) //Se n? estiver deletado
				
					If DbSeek(xFilial("PZX")+M->PZX_CODAPR+aCols[nI][1])
						Reclock("PZX", .f.)
					Else
						Reclock("PZX", .t.)
					EndIf
					PZX->PZX_FILIAL := xFilial("PZX")
					PZX->PZX_CODAPR	:= M->PZX_CODAPR
					PZX->PZX_NOMAPR := POSICIONE("SAK",1,XFILIAL("SAK")+M->PZX_CODAPR,"AK_NOME")
					PZX->PZX_CCUSTO	:= aCols[nI,nPosCC]
					PZX->PZX_DESCCC := POSICIONE("CTT",1,XFILIAL("CTT")+aCols[nI,nPosCC],"CTT_DESC01")                  
					MsUnlock()
				Else
					If DbSeek(xFilial("PZX")+M->PZX_CODAPR+aCols[nI][1])
						Reclock("PZX",.F.)
						DbDelete()
						MsUnlock()
					Endif
				EndIf
			Next nI
		
		Else
		
			MsgStop("Este aprovador j?possui registro inclu?o.", "Alerta de duplicidade")
			Return
			
		EndIf
 
	Else
	
	//	DbSeek(xFilial("PZX")+M->PZX_CODAPR)
		For nI := 1 to Len(aCols)
			If !aCols[nI][Len(aCols[nI])] .And. !Empty(aCols[nI][1]) //Se n? estiver deletado
				Reclock("PZX", .t.)
				PZX->PZX_FILIAL := xFilial("PZX")
				PZX->PZX_CODAPR	:= M->PZX_CODAPR
				PZX->PZX_NOMAPR := POSICIONE("SAK",1,XFILIAL("SAK")+M->PZX_CODAPR,"AK_NOME")
				PZX->PZX_CCUSTO	:= aCols[nI,nPosCC]
				PZX->PZX_DESCCC := POSICIONE("CTT",1,XFILIAL("CTT")+aCols[nI,nPosCC],"CTT_DESC01")                  
				MsUnlock()
			Endif
		Next
	
	EndIf

EndIf

Return
/*
|----------------------------------------------------------------------------|
|Programa  |RDDA001A  |Autor  |TECNOSUM            | Data |  31/03/2016       |
|----------------------------------------------------------------------------|
|Descri豫o |Amarra豫o tipo sc x motivo sc                                    |						  
|----------------------------------------------------------------------------|
|Uso       |REDEDOR                                                            |						  
|----------------------------------------------------------------------------|
*/

User Function RDDA3LOK()

Local aHeader 	:= aClone(oGetDad:aHeader)
Local aCols		:= aClone(oGetDad:aCols)
Local nI		:= 0
Local nPosCC 	:= aScan(aHeader,{|x| AllTrim(x[2])=="PZX_CCUSTO"})
Local lRet := .T.

For nI := 1 to Len(aCols)
	If !aCols[nI][Len(aCols[nI])] .and. oGetDad:nAt <> nI
		If aCols[nI][nPosCC] == aCols[oGetDad:nAt][nPosCC] 
			Alert("Centro de Custo j?informado para o Aprovador")
			lRet := .f.
		Endif
	Endif
Next nI

Return lRet

/*
|----------------------------------------------------------------------------|
|Programa  |ValidPZX  |Autor  |TECNOSUM            | Data |  15/04/2016      |
|----------------------------------------------------------------------------|
|Descri豫o |Valida豫o do campo PZX_CODAPR                                    |						  
|----------------------------------------------------------------------------|
|Uso       |CAMPO PZX_CODAPR                                                 |						  
|----------------------------------------------------------------------------|
*/

User Function ValidPZX(cCCusto)

Local aArea 	:= GetArea()
Local lRet := .t.

BeginSql alias "PZXTMP"
%noparser%
Select COUNT(PZX_CODAPR) CONT FROM %table:PZX% PZX 
WHERE PZX_CODAPR = %exp:cCCusto% and PZX.%notdel%
EndSql		

DbSelectArea("PZXTMP")

PZXTMP->(DbGoTop()) 

If PZXTMP->CONT > 0
	Alert("Centro de Custo j?cadastrado!")
	lRet:= .f.
Endif
DbSelectArea("PZXTMP")
DbCloseArea()
RestArea(aArea)	

Return lRet

