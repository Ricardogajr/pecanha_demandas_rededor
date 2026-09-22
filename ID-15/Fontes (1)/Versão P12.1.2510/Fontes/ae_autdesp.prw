#Include "AE_AUTDESP.CH"
#Include "Protheus.CH"
#Include "Colors.CH"

#XCOMMAND DEFAULT <uVar1> := <uVal1> ;
      [, <uVarN> := <uValN> ] => ;
    <uVar1> := If( <uVar1> == nil, <uVal1>, <uVar1> ) ;;
   [ <uVarN> := If( <uVarN> == nil, <uValN>, <uVarN> ); ]

#xtranslate bSETGET(<uVar>) => ;
    { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }

/*************************************************************************************************************/
User Function TipoAut()
Local oDlg, oBtnCargo, oBtnFunc, oSay, oBOLD 
Local nOpc:=0            

DEFINE MSDIALOG oDlg TITLE STR0001 From 00,00 To 095,350 PIXEL //"Autorizar uso de Despesas"
	
DEFINE FONT oBOLD Name "ARIAL" SIZE 0, -13 BOLD
	@003,003 To 044,173 Of oDlg PIXEL
	
	@020,008 Say oSay PROMPT STR0002 Of oDlg PIXEL FONT oBOLD COLOR CLR_HBLUE //"Autorizar por "

	@018,055 BUTTON oBtnCargo PROMPT STR0003 SIZE 45,15 ACTION (nOpc:=2, oDlg:End()) OF oDlg PIXEL //"Cargo"
	@020,105 Say oSay PROMPT STR0004 Of oDlg PIXEL FONT oBOLD COLOR CLR_HBLUE //"ou"
	@018,120 BUTTON oBtnCargo PROMPT STR0005 SIZE 45,15 ACTION (nOpc:=1, oDlg:End()) OF oDlg PIXEL //"Funcionario"
	
ACTIVATE MSDIALOG oDlg  CENTER
		
If nOpc > 0
	U_AutDesp(nOpc)
EndIf

Return

/*************************************************************************************************************/

User Function AutDesp(nTipo) //nTipo = 1 - Usuario, nTipo = 2 - Cargos
Local oDlg,oCbx
Local cComOpc 	:= ""
Local aItens  	:= {}

Local aCab     	:= {"",STR0006,STR0007} //"Código"###"Despesa"
Local aTam		:= {5,30,50}

Local aArea		:= GetArea()

Local oBtnMarcar
Local oBtnDesmarcar 
Local oBtnPadrao

Local nRow := 17 

Private _cFunc  := Space(TamSX3("LHT_CODMAT")[1])
Private _oFunc                                    
Private _cCodCar:= Space(TamSX3("LJJ_CODCAR")[1])
Private _oCodCar                                  


Private _cNome	:= Space(TamSX3("LHT_NOME")[1])
Private _oNome	
Private _cCargo	:= Space(TamSX3("LJL_CARGO")[1])
Private _oCargo

Private oLbx
Private aLin   	:= {	{1,'','',0} }

Private oOk    	:= LoadBitMap(GetResources(), "LBTIK")       	// Bitmap utilizado no Lisbox  (Marcado)
Private oNo    	:= LoadBitMap(GetResources(), "LBNO")			// Bitmap utilizado no Lisbox  (Desmarcado)
Private oRed   	:= LoadBitMap(GetResources(), "BR_VERMELHO")

//FUNCAO QUE CARREGARA O CONTEUDO DO LISTBOX
If nTipo == 1 
	aLin :=	U_LoadList(1, _cFunc)
Else
	aLin :=	U_LoadList(2, _cCodCar)
EndIf
	
DEFINE MSDIALOG oDlg TITLE STR0008 From 02,03 To 397,528 PIXEL //"Autorização para uso de despesas"

	@nRow+015,005 TO nRow+035,260 OF oDlg PIXEL
	
	If nTipo == 1 
		@ nRow+022,015 SAY STR0009 OF oDlg PIXEL //'Colaborador:'
		@ nRow+021,050 MSGET _oFunc Var _cFunc  Picture '@!' SIZE 20,07 Valid U_VFunc() F3('LHT') OF oDlg PIXEL
		@ nRow+021,083 MSGET _oNome Var _cNome Picture '@!' Size 163,07 When .F. OF oDlg PIXEL

		@nRow+164,111 BUTTON oBtnPadrao PROMPT STR0010  SIZE 48,12 ACTION (U_Padrao(_cFunc)) OF oDlg  PIXEL //"Padronizar"
		oBtnPadrao:cToolTip := STR0011 //"Padroniza a autorização de uso das despesas de acordo com o cargo do funcionário."
	Else
		@ nRow+022,015 SAY STR0012 OF oDlg PIXEL //'Cargo......:'
		@ nRow+021,050 MSGET _oCodCar Var _cCodCar  Picture '@!' SIZE 20,07 Valid U_VCargo() F3('LJL') OF oDlg PIXEL
		@ nRow+021,083 MSGET _oCargo Var _cCargo Picture '@!' Size 163,07 When .F. OF oDlg PIXEL
	EndIf
	
	@nRow+164,159 BUTTON oBtnMarcar PROMPT STR0013  SIZE 48,12 ACTION (U_MarcaTodos()) OF oDlg  PIXEL //"Marcar Todos"
	@nRow+164,207 BUTTON oBtnDesmarcar PROMPT STR0014 SIZE 48,12 ACTION (U_DesmarcaTodos()) OF oDlg PIXEL //"Desmarcar Todos"
	  
	@nRow+036,005 TO nRow+179,260 OF oDlg PIXEL
	
	oLbx:=TwBrowse():New(nRow+042,010,243,120,,aCab,aTam,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbx:lColDrag	:= .T.
	oLbx:nFreeze	:= 1
	oLbx:bLDblClick	:={ || ChgMarkLb(@oLbx,@aLin,{|| .T. }, .T.) }
	
	oLbx:SetArray(aLin)
	If !Empty(oLbx:aArray)	
		oLbx:bLine		:= { ||{IF(	oLbx:aArray[oLbx:nAt,1]>0,oOk,IF(oLbx:aArray[oLbx:nAt,1]<0,oNo,oRed)),;
									oLbx:aArray[oLbx:nAt][2],;
									oLbx:aArray[oLbx:nAt][3],;
									oLbx:aArray[oLbx:nAt][4] } }
	Else
	    MsgAlert(STR0015) //"Para configurar as autorizações para o uso de despesas, é necessário ter no minimo uma despesa e um cargo/funcionário cadastrados"
	    Return
	Endif								

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| If(nTipo==1, (U_GravaADCF(nTipo, _cFunc),oDlg:End()), (U_GravaADCF(nTipo, _cCodCar),oDlg:End()) ) }, {|| oDlg:End() }) CENTER

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GravaADCF ºAutor  ³                    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GravaADCF(nTipo, cCodigo)

Local nContador := 1, aArea:=GetArea()

If MsgYesNo(STR0016) //"Confirma gravação dos dados atuais?"
	If nTipo == 1
		// Procurar registros no LJI e deletar para criar as novas permissões.
		dbSelectArea("LJI")
		LJI->(dbSetOrder(1))
		For nContador := 1 To Len(oLbx:aArray)
			If oLbx:AARRAY[nContador][1] == 1
				If	!LJI->(dbSeek(xFilial("LJI") + cCodigo + oLbx:AARRAY[nContador][2]))
					RecLock("LJI", .T.)
					LJI->LJI_FILIAL := xFilial("LJI")
					LJI->LJI_CODFUN := cCodigo
					LJI->LJI_CODDES := oLbx:AARRAY[nContador][2]
					LJI->LJI_AUTRZA := If(oLbx:AARRAY[nContador][1] == 1, .T., .F.)
					MsUnlock("LJI")
				EndIf
			ElseIf LJI->(dbSeek(xFilial("LJI") + cCodigo + oLbx:AARRAY[nContador][2]))
				RecLock("LJI", .F.)
				LJI->(dbDelete())
				MsUnlock("LJI")
			EndIf
		Next
		MsgInfo(STR0017)  //"Permissões gravadas com sucesso."
	ElseIf nTipo == 2
		// Procurar registros no LJJ e deletar para criar as novas permissões.
		dbSelectArea("LJJ")
		LJJ->(dbSetOrder(1))
		For nContador := 1 To Len(oLbx:aArray)
			If oLbx:AARRAY[nContador][1] == 1
				If !LJJ->(dbSeek(xFilial("LJJ") + cCodigo + oLbx:AARRAY[nContador][2]))
					RecLock("LJJ", .T.)
					LJJ->LJJ_FILIAL := xFilial("LJJ")
					LJJ->LJJ_CODCAR := cCodigo
					LJJ->LJJ_CODDES := oLbx:AARRAY[nContador][2]
					MsUnlock("LJJ")
				EndIf
			ElseIf LJJ->(dbSeek(xFilial("LJJ") + cCodigo + oLbx:AARRAY[nContador][2]))
				RecLock("LJJ", .F.)
				LJJ->(dbDelete())
				MsUnlock("LJJ")
			EndIf
		Next
		MsgInfo(STR0017) //"Permissões gravadas com sucesso."
	EndIf
EndIF
RestArea(aArea)
Return

/******************************************************************************************************/
User Function VFunc()

Local aArea		:= GetArea()
Local lRet 		:= .T.
Local aLin2		:= {}
                     
dbSelectArea("LHT")
LHT->(dbSetOrder(1))
If AllTrim(_cFunc) != ""
	If LHT->((dbSeek(xFilial("LHT") + _cFunc)))
		_cNome := LHT_NOME
		aLin2 := U_LoadList(1, _cFunc)
		oLbx:Refresh()		
	Else
		lRet := .F.
		_cNome := ""
		_oNome:Refresh()
	EndIf
Else
	_cNome := ""
	_oNome:Refresh()
EndIf
RestArea(aArea)

Return lRet

/******************************************************************************************************/
User Function LoadList(nTipo, cCodigo) 		// nTipo -->	1 - Funcionario
											//				2 - Cargo  
											// cCodigo -->	Codigo do Funcionario ou do Cargo
Local aList 	:= {}
Local aArea 	:= GetArea()
Local nContador	:=1

dbSelectArea("LHS")
LHS->(dbSetOrder(2)) //Ordem por Descrição
LHS->(dbGoTop())
Do While !EOF()
	Aadd(aList, {-1,LHS_CODIGO,LHS_DESCRI,0} )
	LHS->(dbSKip())
EndDo

If nTipo = 1 .And. Alltrim(cCodigo) != "" //Funcionario
	//Verifica se existe o funcionario na tabela de permissões por funcionario
	//Se não existir, procurar o codigo do cargo do funcionario e trocar o valor
	//da variavel nTipo para 2, possibilitando mostrar a autorizacao de uso das
	//despesas pelo cargo do funcionario.
	dbSelectArea("LJI")
	LJI->(dbSetOrder(1))
		
	If !LJI->(dbSeek(xFilial("LJI")+cCodigo))
		dbSelectArea("LHT")
		LHT->(dbSetOrder(1))
		If LHT->(DbSeek(xFilial("LHT")+cCodigo))
			If AllTrim(LHT->LHT_CARGO) == ""
				MsgInfo(STR0018) //"O cargo do colaborador no cadastro de usuários de viagens está em branco e o colaborador não possui permissões para uso de despesas."
			Else
				cCodigo := LHT->LHT_CARGO
				nTipo := 2
			EndIf				
		EndIf
	EndIf
EndIf
If nTipo = 1 .And. Alltrim(cCodigo) != "" //Funcionario
	dbSelectArea("LJI")
	LJI->(DbSetOrder(1))
	For nContador := 1 To Len(oLbx:AARRAY)
		If LJI->(dbSeek(xFilial("LJI") + cCodigo + oLbx:AARRAY[nContador][2])) // Cod Func + Cod Desp
			If LJI->LJI_AUTRZA
				oLbx:AARRAY[nContador][1] := 1
			Else
				oLbx:AARRAY[nContador][1] := -1
			EndIf
		Else                              
			oLbx:AARRAY[nContador][1] := -1
		EndIF
	Next nContador 
ElseIf nTipo = 2 .And. Alltrim(cCodigo) != "" //Cargo
	dbSelectArea("LJJ")
	LJJ->(dbSetOrder(1))
	For nContador := 1 To Len(oLbx:AARRAY)
		If LJJ->(dbSeek(xFilial("LJJ") + cCodigo + oLbx:AARRAY[nContador][2])) // Cod Func + Cod Desp
			oLbx:AARRAY[nContador][1] := 1
		Else                              
			oLbx:AARRAY[nContador][1] := -1
		EndIF
	Next nContador
EndIf
RestArea(aArea)			
Return aList
                                          	
/******************************************************************************************************/
User Function VCargo()
Local aArea := GetArea(), lRet := .T., aLin2 := {}
                     
dbSelectArea("LJL")
LJL->(dbSetOrder(1))
    
If AllTrim(_cCodCar) != ""
	If (DbSeek(xFilial("LJL") + _cCodCar))
		_cCargo := LJL_CARGO

		aLin2 := U_LoadList(2, _cCodCar)
		oLbx:Refresh()
	Else
		lRet := .F.
		_cCargo := ""
		_oCargo:Refresh()
	EndIf                
Else
	_cCargo := ""
	_oCargo:Refresh()
EndIf
RestArea(aArea)

Return lRet

/******************************************************************************************************/
User Function MarcaTodos()

Local nContador := 1
	
For nContador := 1 To Len(oLbx:AARRAY)
	oLbx:AARRAY[nContador][1] := 1
Next 
oLbx:Refresh()

Return			

/******************************************************************************************************/
User Function DesmarcaTodos()

Local nContador := 1
	
For nContador := 1 To Len(oLbx:AARRAY)
	oLbx:AARRAY[nContador][1] := -1
Next 
oLbx:Refresh()

Return

/******************************************************************************************************/
User Function Padrao(cCodigo)

Local aArea := GetArea()
Local _cCargo:=Space(06), _nTipo:=0
  
If MsgYesNo(STR0019) //"Confirma a padronização das autorizações de uso pelo cargo do colaborador?"
	If LHT->(dbSeek(xFilial("LHT") + cCodigo))
		If AllTrim(LHT->LHT_CARGO) == ""
			MsgInfo(STR0020) //"O cargo do colaborador no cadastro de usuários de viagens está em branco. Por favor, atualize o cadastro do colaborador para poder configurar as autorizações de uso de despesas."
		Else
			_cCargo := LHT->LHT_CARGO
			_nTipo := 2
			dbSelectArea("LJI")
			LJI->(dbSetOrder(1))
			If LJI->(dbSeek(xFilial("LJI") + cCodigo))
				Do While !Eof() .And. LJI->LJI_CODFUN == cCodigo
					RecLock("LJI", .F.)
						LJI->(dbDelete())
					MsUnlock("LJI")
					LJI->(dbSkip())
				EndDo 
			EndIf
			U_LoadList(_nTipo, _cCargo)
			MsgInfo(STR0021) //"As configurações de autorização de uso pelo cargo do colaborador foram efetuadas com sucesso."
		EndIf				
	Else
		MsgInfo(STR0022) //"Não foi possível encontrar o colaborador no cadastro de usuários de viagens."
	EndIf
EndIf
RestArea(aArea)

Return

