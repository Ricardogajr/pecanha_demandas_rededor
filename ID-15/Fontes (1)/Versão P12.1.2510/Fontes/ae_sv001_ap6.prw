#INCLUDE "AE_SV001_AP6.ch"
#INCLUDE "PROTHEUS.CH"

Static __lCDVPCOLCO
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AE_SV001  ºAutor  ³Willy / Armando     º Data ³  09/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±               
±±ºDesc.     ³Inclusão da Solicitação de Viagem.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Template CDV - Controle de Despesas de Viagens              º±±
±±º          ³Modificado por Itamar Oliveira - 08/2005	                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
                       
User Function AE_SV001(nStat)
//nStatus = 0 - Visualizar
//nStatus = 1 - Incluir
//nStatus = 2 - Alterar
//nStatus = 3 - Excluir
//nStatus = 4 - Aprovacao
//nStatus = 5 - Copia da Solicitacao

Local _nRow
Local _nAux
Local _aAntec		:={}
Local _lHabilita 	:= .F. 
Local _cRot 		:= FunName()
Local _aRet 		:= {}
Local _cDesFatura := Space(20)
Local _lAlVeic 	:= .F.

Private _dEmissao		:= dDataBase
Private _cCodCidade	:= Space(TamSX3("LDY_CODIGO")[1])
Private _cMun			:= Space(TamSX3("LDY_NOME")[1])
Private _cQuem 		:= Space(TamSX3("LHP_QUEM")[1])
Private _cFunc 		:= Space(TamSX3("LHT_CODMAT")[1])
Private _cNFunc 		:= Space(TamSX3("LHT_NOME")[1])
Private _cSupImd 		:= Space(TamSX3("LHT_CODMAT")[1])
Private _cDGRar 		:= Space(TamSX3("LHT_CODMAT")[1])
Private _cNSupImd 		:= Space(TamSX3("LHT_NOME")[1])
Private _cNDGRar 		:= Space(TamSX3("LHT_NOME")[1])
Private _cEmpCli 		:= Space(TamSX3("A1_COD")[1])
Private _cNEmpCli 		:= Space(TamSX3("A1_NOME")[1])
Private _cLojaCli 	:= Space(TamSX3("A1_LOJA")[1])
Private _mMotivo 		:= Space(TamSX3("LHP_MOTMEM")[1])
Private _mObs 			:= Space(TamSX3("LHP_OBSMEM")[1])
Private _cConta  		:= Space(TamSX3("LHT_CTDEPS")[1])
Private _cHosped 		:= Space(TamSX3("LJ3_CODIGO")[1])
Private _cNomeHotel 	:= Space(TamSX3("LJ3_NOME")[1])
Private aMemos 		:= {{"LHP_CODMOT","LHP_MOTMEM","LHP_CODOBS","LHP_OBSMEM"}}
Private _lFPrazo 
Private _ConCC			:= GetMv('MV_CCCDV')
Private oPrincipal
Private _aQuem			:= {}
Private _cSolPor		:= SubStr(cUsuario,7,15)
Private _lInter:=.F.
Private _dSaida   		:= CtoD('  /  /  ')
Private _dChegada 		:= CtoD('  /  /  ')
Private _cHoraId 		:= Space(05)
Private _cHoraVt 		:= Space(05)
Private _cCC
Private _nRecno 		:= Recno()
Private _lAdiant 		:= .F.
Private _lPassag 		:= .F.
Private _lHosped 		:= .F.
Private _nFatCli 		:= GetMv('MV_PORCCLI')
Private _nFatMic 		:= GetMv('MV_PRCNFAT')
Private _nValorR 		:= 0
Private _nValorU 		:= 0
Private _cBanco 		:= Space(03)
Private _cAgenci 		:= Space(05)
Private _nDiariaUmDIa 	:= 0
Private _nVlDiaria 	:= 0
Private _nVlDiaInt 	:= 0
Private _nAcrescimo 	:= 0
Private nStatus 		:= 0
Private _cLocal		:= Space(20)
Private _oLocal
Private _lAlocVeic 	:= .F.
Private _nValAcr 		:= 0
Private _lAdiantKm 	:= SuperGetMv("MV_ADTOKM",,"2") == "1" //Adiantamento sobre Kilometragem
Private _nAcresKM 		:= 0
Private _nKm 			:= 0
Private _cMotViag 		:= ""
Private _lAdiaOK 		:= .T.

If GetMv('MV_MCONTAB') == "CTB"
	_cCC := " "
	If Empty(_ConCC)
		_ConCC := 'CTT'
	EndIf
Else
	_cCC := " "
	If Empty(_ConCC)
		_ConCC := 'SI3'
	EndIf
EndIf

ChkTemplate("CDV")

//VERIFICACAO DE ROTINA CHAMADA
nStatus := nStat
If nStatus == 0 //VISUALIZAR

	If 	AllTrim(_cRot) == "AE_DESPV" .OR. ;
		AllTrim(_cRot) == "DESPVA" .OR. ;
		AllTrim(_cRot) == "U_AE_DESPV" .OR. ;
		AllTrim(_cRot) == "U_DESPVA" //Acesso pelo Departamento de Viagens
		
		DbSelectArea('LHP')
		DbSetOrder(1)
		MsSeek(xFilial('LHP') + LHQ->LHQ_CODIGO)
	Endif
	AtribuiCampos()
	_lHabilita := .F.

ElseIf nStatus == 1 //INCLUIR  
	_lHabilita := .T.

ElseIf nStatus == 2 //ALTERAR

	If LHP->LHP_FLAG == 'A' .And. LHP->LHP_XESTIT == 'S'
		AtribuiCampos()
		_lHabilita := .T.
	ElseIf !(Alltrim(LHP->LHP_Flag) $ 'D|I')  //Solicitacao sendo montada
		MsgInfo(STR0001) //"Somente solicitações que estão sendo montadas poderão ser alteradas. Solicitações enviadas para aprovação, aprovadas ou canceladas não poderão ser alteradas."
		Return
	Else
		AtribuiCampos()
		_lHabilita := .T.
	EndIf

ElseIf nStatus == 3 //EXCLUIR
	If LHP->LHP_Flag != 'D|I' //Solicitacao sendo montada
		MsgInfo(STR0002) //"Somente solicitações que estão sendo montadas poderão ser excluídas. Solicitações com outros status deverão ser canceladas."
		Return
	Else
		AtribuiCampos()
		_lHabilita := .F.
	EndIf

ElseIf nStatus == 4 //APROVACAO
	If !ValAprov()
		Return
	EndIf

	AtribuiCampos()
	_lHabilita := .F.
	
ElseIf nStatus == 5 //COPIA DA SOLICITACAO
	AtribuiCampos( .T. )
	_lHabilita := .T.
	
EndIf

//Ponto de Entrada para que possa ser enviado itens a mais nos HTML's
If ExistBlock("MontaSolic")
	_aRet := ExecBlock("MontaSolic", .F., .F.,{ nStatus })

	If Len(_aRet) > 0 
		_cFunc		:= _aRet[1]                 
		_cNFunc 	:= IIf(Len(_aRet) > 1, _aRet[2], _cNFunc)
		_cSupImd	:= IIf(Len(_aRet) > 2, _aRet[3], _cSupImd)
		_cNSupImd 	:= IIf(Len(_aRet) > 3, _aRet[4], _cNSupImd)
		_cDGRar 	:= IIf(Len(_aRet) > 4, _aRet[5], _cDGRar)
		_cNDGRar	:= IIf(Len(_aRet) > 5, _aRet[6], _cNDGRar)
		_cEmpCli	:= IIf(Len(_aRet) > 6, _aRet[7], _cEmpCli)
		_cNEmpCli	:= IIf(Len(_aRet) > 7, _aRet[8], _cNEmpCli)
		_cCodCidade := IIf(Len(_aRet) > 8, _aRet[9], _cCodCidade)
		_cMun 		:= IIf(Len(_aRet) > 9, _aRet[10], _cMun)
		_cCC  		:= IIf(Len(_aRet) > 10, _aRet[11], _cCC)
		_mMotivo 	:= IIf(Len(_aRet) > 11, _aRet[12], _mMotivo)
		_mObs 		:= IIf(Len(_aRet) > 12, _aRet[13], _mObs)
		_dSaida   	:= IIf(Len(_aRet) > 13, _aRet[14], _dSaida)
		_dChegada 	:= IIf(Len(_aRet) > 14, _aRet[15], _dChegada)
		_cHoraId 	:= IIf(Len(_aRet) > 15, _aRet[16], _cHoraId)
		_cHoraVt	:= IIf(Len(_aRet) > 16, _aRet[17], _cHoraVt)
		_lAdiant 	:= IIf(Len(_aRet) > 17, _aRet[18], _lAdiant)
		_lPassag 	:= IIf(Len(_aRet) > 18, _aRet[19], _lPassag)
		_lHosped 	:= IIf(Len(_aRet) > 19, _aRet[20], _lHosped)
		_cHosped 	:= IIf(Len(_aRet) > 20, _aRet[21], _cHosped)
		_cNomeHotel := IIf(Len(_aRet) > 21, _aRet[22], _cNomeHotel)
	EndIf
EndIf

//BOTAO DE CALCULO DO ADIANTAMENTO
aButtons := {}
AaDd(aButtons, {"SIMULACA", {|| Calcula()}, STR0003 }) //"Calcular"

If _lAdiantKm
	AaDd(aButtons, {"CARGA", {|| CalcKM()}, STR0004 }) //"KM"
EndIf                                 

If ExistBlock("CUSU_ADTO")
	AaDd(aButtons, {"BUDGETY", {|| _nValAcr := ExecBlock("CUSU_ADTO",.F.,.F.)}, STR0005 }) //"Acréscimo"
EndIf

If nStatus <> 1 .AND. nStatus <> 2
	AaDd(aButtons, {"BMPVISUAL", {|| U_HISTORICO()}, STR0006}) //"Historico da Solicitação"
EndIf

//DEFINICAO DA DIALOG
If AllTrim(PtGetTheme()) $ "MDI/TEMAP10"                                                      
	DEFINE MSDIALOG oPrincipal FROM  000,000 TO 390,760 TITLE STR0007 PIXEL //'Solicitação de Viagem'
Else
	DEFINE MSDIALOG oPrincipal FROM  000,000 TO 360,760 TITLE STR0007 PIXEL //'Solicitação de Viagem'
Endif

//EMPRESA/FILIAL SOLICITANTE
_nRow := 30
@ _nRow,003 TO _nRow+18,379 OF oPrincipal PIXEL

_nRow+=6
@ _nRow,008 SAY RetTitle("LHP_QUEM") OF oPrincipal PIXEL

DbSelectArea("SM0")
DbGoTop()

Do While !Eof() 
	AaDd(_aQuem, SM0->M0_CODIGO + SM0->M0_CODFIL + "-" + RTrim(SM0->M0_NOME) + " / " + RTrim(SM0->M0_FILIAL))
	DbSkip()
EndDo

_nRow-=5

//COMBO DO SOLICITANTE
oCombo:= TComboBox():New(_nRow,035,{|u|If(PCount()>0,_cQuem:=u,_cQuem)},;
_aQuem,125,82,oPrincipal,,,,,,.T.,,,,,,,,,"_cQuem")
oCombo:lReadOnly := !_lHabilita

If nStatus <> 1 //Não é inclusão
	If !Empty(LHP->LHP_QUEM)
		oCombo:Select(aScan(_aQuem,{ |x| AllTrim(x) == AllTrim(LHP->LHP_QUEM)}))
	EndIf
EndIf

If nStatus == 0
	_cQuem := LHP->LHP_QUEM
EndIf

//ANTECEDENCIA DA SOLICITACAO DE VIAGENS
_nRow+=5
_lFPrazo := .F.
@ _nRow,165 SAY RetTitle("LHP_ANTEC") OF oPrincipal PIXEL

DbSelectArea("LJ8")
DbSetOrder(1)
DbGoTop()
While !EOF()
	AADD(_aAntec, (RIGHT("00" + LJ8->LJ8_DIAS, 2) + STR0008 + LJ8->LJ8_DESCR)) //" DIAS - "
	DbSkip()
End

_nRow-=5
_cAntec := ''
If nStatus == 0
	_cAntec := LHP->LHP_Antec
EndIf   

//COMBO DO SOLICITANTE
oComboAntec:= TComboBox():New(_nRow,200,{|u|If(PCount()>0,_cAntec:=u,_cAntec)},_aAntec,110,82,oPrincipal,,,,,,.T.,,,,,,,,,"_cAntec")
oComboAntec:lReadOnly := !_lHabilita

If nStatus <> 1 //Não é inclusão
	If !Empty(LHP->LHP_ANTEC)
		oComboAntec:Select(aScan(_aAntec,{ |x| AllTrim(x) == AllTrim(LHP->LHP_ANTEC)}))
	EndIf
EndIf        

//DATA DA SOLICITACAO DA VIAGEM
_nRow+=5
@ _nRow,315 SAY RetTitle("LHP_EMISS") OF oPrincipal PIXEL
_nRow-=2                 
@ _nRow,340 MSGET _dEmissao Picture '@D' Size 35,07 When .F. OF oPrincipal PIXEL

//COLABORADOR VIAJANTE
_nRow+=20
_nAux:= _nRow //Esta variavel ira ajudar a montar a segunda coluna da tela
@ _nRow,005 SAY RetTitle("LHP_FUNC") OF oPrincipal PIXEL
@ _nRow,082 SAY RetTitle("LHP_NFUNC") OF oPrincipal PIXEL
@ _nRow,040 MSGET _cFunc  Picture '@!' Valid VFunc() F3('LHT') When _lHabilita OF oPrincipal PIXEL
@ _nRow,117 MSGET _cNFunc Picture '@!' Size 163,07 When .F. OF oPrincipal PIXEL

//PRIMEIRO APROVADOR
_nRow+=13
@ _nRow,005 SAY  RetTitle("LHP_SUPIMD") OF oPrincipal PIXEL
@ _nRow,082 SAY  RetTitle("LHT_NOME") OF oPrincipal PIXEL
@ _nRow,040 MSGET _cSupImd  Picture '@!' Valid VSupImd() F3('LH2') When _lHabilita OF oPrincipal PIXEL
@ _nRow,117 MSGET _cNSupImd Picture '@!' Size 163,07 When .F. OF oPrincipal PIXEL

//SEGUNDO APROVADOR - FINANCEIRO
 _nRow+=13
@ _nRow,005 SAY RetTitle("LHP_DGRAR") OF oPrincipal PIXEL
@ _nRow,082 SAY RetTitle("LHT_NOME") OF oPrincipal PIXEL
@ _nRow,040 MSGET _oDGRar VAR _cDGRar Picture '@!' Valid VDGRar() F3('LH2') When _lHabilita OF oPrincipal PIXEL
@ _nRow,117 MSGET _cNDGRar Picture '@!' Size 163,07 When .F. OF oPrincipal PIXEL

//CLIENTE QUE SERA VISITADO
_nRow+=13
@ _nRow,005 SAY RetTitle("LHP_EMPCLI") OF oPrincipal PIXEL
@ _nRow,082 SAY RetTitle("A1_NOME") OF oPrincipal PIXEL
@ _nRow,040 MSGET _cEmpCli  Picture '@!' Valid VEmpCli() F3('SA1') When _lHabilita OF oPrincipal PIXEL
@ _nRow,117 MSGET _cNEmpCli Picture '@!' Size 163,07 When .F. OF oPrincipal PIXEL

//LOCAL DA VIAGEM
_nRow+=13
@ _nRow,005 SAY RetTitle("LHP_CODMUN") OF oPrincipal PIXEL
@ _nRow,082 SAY RetTitle("LDY_NOME") OF oPrincipal PIXEL
@ _nRow,040 MSGET _cCodCidade Picture '999999' Valid VCidDest() F3('LDY') When _lHabilita OF oPrincipal PIXEL
@ _nRow,117 MSGET _cMun Picture '@!' Size 115,07 When .F. OF oPrincipal PIXEL

//CENTRO DE CUSTO
@ _nAux+3,290 SAY RetTitle("LHP_CC") OF oPrincipal PIXEL
@ _nAux+3,325 MSGET _cCC  Picture '@!' Size 55,07 Valid VCC() F3(_ConCC) /*When _lHabilita*/ OF oPrincipal PIXEL

//BOTAO MOTIVO
_nAux+=17
@ _nAux,290 Button RetTitle("LHP_CODMOT") Size 88,12 Action _mMotivo := U_EditaTexto(STR0009, _mMotivo, .T.) OF oPrincipal PIXEL //'Motivo da Viagem'

//BOTAO OBSERVACOES
_nAux+=15
@ _nAux,290 Button RetTitle("LHP_CODOBS") Size 88,12 Action _mObs := U_EditaTexto(STR0010, _mObs, .T.) OF oPrincipal PIXEL //'Observações Gerais'

//PERIODO DA VIAGEM
@ _nRow+1,236 SAY RetTitle("LHP_SAIDA") OF oPrincipal PIXEL
@ _nRow+1,306 SAY RetTitle("LHP_CHEGAD") OF oPrincipal PIXEL
@ _nRow,264 MSGET _dSaida   Picture '@D' Size 40,07 When _lHabilita OF oPrincipal PIXEL
@ _nRow,342 MSGET _dChegada Picture '@D' Size 40,07 When _lHabilita OF oPrincipal PIXEL

//HORARIO PRETENDIDO PARA VIAJAR
_nRow+=12
_nAux:= _nRow
@ _nRow,003 TO _nRow+20,185 OF oPrincipal PIXEL
_nRow+=6
@ _nRow+1,007 SAY RetTitle("LHP_HORAID") OF oPrincipal PIXEL
@ _nRow,044 MSGET _cHoraId Picture '99:99' Size 25,07 When _lHabilita OF oPrincipal PIXEL
@ _nRow+1,100 SAY RetTitle("LHP_HORAVT") OF oPrincipal PIXEL
@ _nRow,143 MSGET _cHoraVt Picture '99:99' Size 25,07 When _lHabilita OF oPrincipal PIXEL

//RATEIO DO FATURAMENTO
_nRow+=13
@ _nAux,190 TO _nAux+20,379 OF oPrincipal PIXEL
_nAux+=5

If ExistBlock("RetDesFat")
	_cDesFatura := ExecBlock("RetDesFat", .F., .F.)
Else
	_cDesFatura := STR0011 //'Faturamento %'
EndIf

@ _nAux+1,195 SAY _cDesFatura OF oPrincipal PIXEL
@ _nAux+1,245 SAY RetTitle("LHP_FATCLI") OF oPrincipal PIXEL
@ _nAux,270 MSGET _nFatCli Picture '@E 999.99' Size 25,07 When _lHabilita OF oPrincipal PIXEL
@ _nAux+1,313 SAY RetTitle("LHP_FATMIC") OF oPrincipal PIXEL
@ _nAux,345 MSGET _nFatMic Picture '@E 999.99' Size 25,07 When _lHabilita OF oPrincipal PIXEL

If ExistBlock("ALOC_VEIC")
	_lAlVeic	:= ExecBlock("ALOC_VEIC",.F.,.F.)
EndIf

//ADIANTAMENTO / PASSAGEM AEREA / HOSPEDAGEM / ALOCACAO DE VEICULOS
_nAux+=8
_nRow+=05
@ _nRow,003 TO _nRow+31,379 OF oPrincipal PIXEL 
_nRow+=5                               
@ _nRow,007 CHECKBOX oCkb1 VAR _lAdiant SIZE 45,07 VALID SV001_VAD() When _lHabilita OF oPrincipal PROMPT OemToAnsi(RetTitle("LHP_ADIANT")) PIXEL
@ _nRow,055 CHECKBOX oCkb2 VAR _lPassag SIZE 55,07 When _lHabilita OF oPrincipal PROMPT OemToAnsi(RetTitle("LHP_PASSAG")) PIXEL
@ _nRow,095 CHECKBOX oCkb3 VAR _lHosped SIZE 45,07 When _lHabilita OF oPrincipal PROMPT OemToAnsi(RetTitle("LHP_HOSPED")) PIXEL
If _lAlVeic
	@ _nRow,145 CHECKBOX oCkb4 VAR _lAlocVeic SIZE 45,07 When _lHabilita OF oPrincipal PROMPT OemToAnsi('Aloc. Veic.') PIXEL
EndIf   

//VALORES DE ADIANTAMENTO EM REAIS E DOLAR (CASO VIAGEM INTERNACIONAL)
@ _nRow,199 SAY RetTitle("LHP_VALORR") OF oPrincipal PIXEL
@ _nRow,230 MSGET _oValorR VAR _nValorR Picture '@E 999,999.99' When .F. Size 40,07 OF oPrincipal PIXEL
@ _nRow,292 SAY  RetTitle("LHP_VALORU") OF oPrincipal PIXEL
@ _nRow,321 MSGET _oValorU VAR _nValorU Picture '@E 999,999.99' When .F. Size 40,07 OF oPrincipal PIXEL

//BANCO / AGENCIA / CONTA -> SOLICITANTE - USADO PARA O ADIANTAMENTO OU REEMBOLSO APOS A VIAGEM
_nRow+=12
@ _nRow,199 SAY RetTitle("LHP_BANCO") OF oPrincipal PIXEL
@ _nRow,218 MSGET _oBanco VAR _cBanco Picture '@!' When .F. Size 15,07 OF oPrincipal PIXEL

@ _nRow,246 SAY RetTitle("LHP_AGENCI") OF oPrincipal PIXEL
@ _nRow,270 MSGET _oAgenci VAR _cAgenci Picture '@!' When .F. Size 20,07 OF oPrincipal PIXEL

@ _nRow,303 SAY RetTitle("LHP_CONTA") OF oPrincipal PIXEL
@ _nRow,321 MSGET _oConta VAR _cConta Picture '@!' When .F. Size 40,07 OF oPrincipal PIXEL

//HOTEL DE PREFERENCIA DO VIAJANTE
@ _nRow,007 SAY RetTitle("LHP_CODHOT") OF oPrincipal PIXEL
@ _nRow,025 MSGET _cHosped Picture '@!' Valid VHotel() F3('LJ3') When _lHabilita OF oPrincipal PIXEL
@ _nRow,065 MSGET _cNomeHotel Picture '@!' When .F. Size 125,07 OF oPrincipal PIXEL

//SOLICITANTE (USUARIO DO SIGA QUE ESTA LOGADO NO MOMENTO DA SOLICITACAO)
_nRow+=17
@ _nRow,003 TO _nRow+18,379 OF oPrincipal PIXEL
_nRow+=5
@ _nRow,007 SAY RetTitle("LHP_SOLPOR") OF oPrincipal PIXEL
@ _nRow,045 MSGET _cSolPor Picture '@!' Size 220,07 When .F. OF oPrincipal PIXEL

//TIPO DE VIAGEM - NACIONAL OU INTERNACIONAL
@ _nRow,280 SAY _oLocal VAR _cLocal Of oPrincipal PIXEL
VCidDest()

ACTIVATE MSDIALOG oPrincipal CENTERED ON INIT EnchoiceBar(oPrincipal, {|| Acao()}, {|| oPrincipal:End()}, , aButtons)

Return

//--------------------------------------------------------------------------------------
Static Function VCC() //Valida Centro de Custo Preenchido na Solicitacao
//--------------------------------------------------------------------------------------
Local _lVCC := .T.
Local cContab:=GetMV('MV_MCONTAB')

If !Empty(_cCC)

	If cContab == 'CON'
		DbSelectArea('SI3')
		DbSetOrder(1)
		If !MsSeek(xFilial('SI3') + _cCC)
			MsgInfo(STR0012, STR0013) //'Centro de Custo não Cadastrado !'###'Atenção'
			_lVCC := .F.
		EndIf
	ElseIf cContab == 'CTB'
		DbSelectArea('CTT')
		DbSetOrder(1)
		If !MsSeek(xFilial('CTT') + _cCC)
			MsgInfo(STR0012, STR0013) //'Centro de Custo não Cadastrado !'###'Atenção'
			_lVCC := .F.
		Else
			If CTT->CTT_BLOQ == "1" //Valida se o centro de custo selecionado está bloqueado
				MsgInfo(STR0068, STR0013) //'Centro de Custo Bloqueado!'###'Atenção'
				_lVCC := .F.
			EndIf
		EndIf
	EndIf
EndIf

Return(_lVCC)

//---------------------------------------------------------------------------------------------------
Static Function VFunc() //Valida codigo do Funcionario digitado e exibe nome, banco, agencia e conta
//---------------------------------------------------------------------------------------------------
Local _aAreaLHQa, _lFunc := .T.
Local lCpBloq	:= (LHT->(FieldPos("LHT_MSBLQL")) > 0)

If !Empty(_cFunc)
	DbSelectArea('LHT')
	DbSetOrder(1)
	If MsSeek(xFilial('LHT') + _cFunc)
		If (lCpBloq  .AND. LHT->LHT_MSBLQL == '1')
			MsgInfo(STR0069,STR0013) //Colaborador está Bloqueado
			_lFunc := .F.
		EndIf
		_cNFunc	:= LHT->LHT_Nome
		_cBanco	:= SubStr(LHT->LHT_BcDepS,1,3)
		_cAgenci := SubStr(LHT->LHT_BcDepS,4,9)
		_cConta	:= LHT->LHT_CtDepS
		If GetMV('MV_MCONTAB') == "CTB"
			dbSelectArea("CTT")
			CTT->(dbSetOrder(1))
			If CTT->(dbSeek(xFilial("CTT") + LHT->LHT_CC)) .AND. !Empty(LHT->LHT_CC)
				If !Empty(_cCC) .AND. _cCC # LHT->LHT_CC
					If !(MsgYesNo(STR0014 + AllTrim(LHT->LHT_CC) + STR0015 + CRLF + STR0016)) //"O CC associado do solicitador ("###") é diferente do estabelecido no campo de CC."###"Deseja alterá-lo?"
						_cCC := LHT->LHT_CC
					Endif
				Else
					_cCC := LHT->LHT_CC
				Endif
			Else 
				If Empty(_cCC) 
					_cCC := " "
				Endif
			Endif
        Else 
			dbSelectArea("SI3")
			SI3->(dbSetOrder(1))
			If SI3->(dbSeek(xFilial("SI3") + LHT->LHT_CC)) .AND. !Empty(LHT->LHT_CC)
				If !Empty(_cCC) .AND. _cCC # LHT->LHT_CC
					If !(MsgYesNo(STR0014 + AllTrim(LHT->LHT_CC) + STR0015 + CRLF + STR0016)) //"O CC associado do solicitador ("###") é diferente do estabelecido no campo de CC."###"Deseja alterá-lo?"
						_cCC := LHT->LHT_CC
					Endif
				Else
					_cCC := LHT->LHT_CC
				Endif
			Else
				If Empty(_cCC) 
					_cCC := Space(TamSX3("I3_CUSTO")[1])
				Endif
			Endif        
        Endif
		
		//Ponto de entrada para customizar o retorno automatico dos códigos 
		//dos aprovadores de acordo com o colaborador selecionado
		If ExistBlock("AUU_APROV")
			ExecBlock("AUU_APROV",.F.,.F.)
		EndIf
		
		If AllTrim(LHT->LHT_SITFOL) == 'D' .Or. AllTrim(LHT->LHT_SITFOL) == 'A'
			MsgInfo(STR0017 + CRLF + STR0018, STR0013)		 //'O colaborador não pode solicitar uma viagem'###'pois está afastado ou foi demitido.'###'Atenção'
			_lFunc := .F.		
		ElseIf Empty(LHT->LHT_EMAIL)
			MsgInfo(STR0019, STR0013) //'Colaborador não possui Conta de Email Cadastrado.'###'Atenção'
			_lFunc := .F.
		Endif
	Else
		MsgInfo(STR0020, STR0013) //'Colaborador não Cadastrado.'###'Atenção'
		_lFunc := .F.
	EndIf
Else
	_cNFunc  := ''
	_cBanco  := ''
	_cAgenci := ''
	_cConta  := ''
EndIf

_oBanco:Refresh()
_oAgenci:Refresh()
_oConta:Refresh()

If _lFunc .And. !Empty(_cFunc) // Verifica atraso na prestacao de contas do Colaborador
	_aAreaLHQa:= GetArea()
	DbSelectArea('LHQ')
	DbSetOrder(4)
	If MsSeek(xFilial('LHQ') + _cFunc)
		Do While !Eof() .And.;
			LHQ->LHQ_Filial == xFilial('LHQ') .And.;
			LHQ->LHQ_FUNC  == _cFunc
			If LHQ->LHQ_FLAG == 'P'
				MsgInfo(STR0021, STR0022) //'Colaborador com Prestação de Contas em Atraso, Solicitação Bloqueada !'###"Atenção"
				_lFunc := .F.
				Exit
			EndIf
			DbSkip()
		EndDo
	EndIf
	LHQ->(DbSetOrder(1))
	RestArea(_aAreaLHQa)
Endif

Return(_lFunc)

//--------------------------------------------------------------------------------------
Static Function VSupImd() //Valida Primeiro Aprovador e exibe seu nome 
//--------------------------------------------------------------------------------------
Local _lSupImd := .T.

If !Empty(_cSupImd)
	DbSelectArea('LHT')
	DbSetOrder(1)
	If MsSeek(xFilial('LHT') + _cSupImd)
		_cNSupImd := LHT->LHT_Nome
		If AllTrim(_cSupImd) == AllTrim(_cFunc)
			MsgInfo(STR0023, STR0013) //'Colaborador não pode Aprovar sua Própria Viagem.'###'Atenção'
			_lSupImd := .F.
		Endif
		If Empty(LHT->LHT_EMAIL)
			MsgInfo(STR0019, STR0013) //'Colaborador não possui conta de Email Cadastrado.'###'Atenção'
			_lSupImd := .F.
		Endif
		If LHT->LHT_FLAGAP <> '1'
			MsgInfo(STR0024, STR0013) //'Colaborador não Autorizado a Aprovar Solicitações de Viagens.'###'Atenção'
			_lSupImd := .F.
		Endif
/*		If _lSupImd .And. !Empty(LHT->LHT_Aprov2)
			_cDGRar := LHT->LHT_Aprov2
			_oDGRar:Refresh()
		Endif*/
	Else
		MsgInfo(STR0020, STR0013) //'Colaborador não Cadastrado.'###'Atenção'
		_lSupImd := .F.
	EndIf
Else
	_cNSupImd := ''
EndIf

Return(_lSupImd)

//--------------------------------------------------------------------------------------
Static Function VDGRar() //Valida Segundo Aprovador e exibe seu nome 
//--------------------------------------------------------------------------------------
Local _lDGRar := .T.

If !Empty(_cDGRar)
	DbSelectArea('LHT')
	DbSetOrder(1)
	If MsSeek(xFilial('LHT') + _cDGRar)
		_cNDGRar := LHT->LHT_Nome
		If AllTrim(_cDGRar) == AllTrim(_cFunc)
			MsgInfo(STR0023, STR0013) //'Colaborador não pode Aprovar sua Própria Viagem.'###'Atenção'
			_lDGRar := .F.
		Endif		
		If Empty(LHT->LHT_EMAIL)
			MsgInfo(STR0019, STR0013) //'Colaborador não possui Conta de Email Cadastrado.'###'Atenção'
			_lDGRar := .F.
		Endif
		If LHT->LHT_APFIN <> '1'
			MsgInfo(STR0025, STR0013) //'Colaborador não é Autorizador Financeiro.'###'Atenção'
			_lDGRar := .F.
		Endif
	Else
		MsgInfo(STR0026, STR0013) //'Aprovador II não Cadastrado.'###'Atenção'
		_lDGRar := .F.
	EndIf
Else
	_cNDGRar := ''
EndIf

Return(_lDGRar)

//--------------------------------------------------------------------------------------
Static Function VEmpCli() //Valida codigo do cliente, exibe nome e cidade do cliente
//--------------------------------------------------------------------------------------
Local _lEmpCli := .T.

If !Empty(_cEmpCli)
	dbSelectArea('SA1')
	SA1->(dbSetOrder(1))
	_cLojaCli := SA1->A1_LOJA 
	If SA1->(MsSeek(xFilial('SA1') + _cEmpCli + _cLojaCli))
		_cNEmpCli := SA1->A1_Nome
		dbSelectArea('LDY')
		LDY->(dbSetOrder(2))
		//Procura Cidade + Estado na tabela de municipios para trazer o codigo automatico 
		//do cliente case esteja cadastrado.
		If LDY->(MsSeek(xFilial('LDY') + 	Left( (SA1->A1_MUN + Space(TamSX3('LDY_NOME')[1])), TamSX3('LDY_NOME')[1] ) + SA1->A1_EST))
			_cCodCidade	:= LDY->LDY_CODIGO
			_cMun 		:= LDY->LDY_NOME
		EndIf			
	Else
		_lEmpCli := .F.
		MsgInfo(STR0027, STR0013) //'Empresa/Cliente não Cadastrado.'###'Atenção'
	EndIf
Else
	_cNEmpCli := ''
EndIf

SA1->(DbGoTop())

Return(_lEmpCli)

//--------------------------------------------------------------------------------------
Static Function VCidDest() //Valida codigo do municipio digitado e exibe o nome do mun.
//--------------------------------------------------------------------------------------
Local _lCidDest := .T.
Local _cPais := GetMv("MV_PAISLOC")
_cLocal := ""
If !Empty(_cCodCidade)
	dbSelectArea('LDY')
	LDY->(dbSetOrder(1))
	If LDY->(MsSeek(xFilial('LDY') + _cCodCidade))
		_cMun := RTrim(LDY->LDY_NOME) + '/' + LDY->LDY_EST
		If SubStr(LDY->LDY_PAIS,1,3) <> _cPais		//Este tratamento nao funcionara para os Paises: Rep.Dominicana, EUA, Portugal e El Salvador, deivdo o Conteudo do Pais parametro MV_PAISLOC nao ser escrito com as iniciais do nome do Pais.
			//MsgInfo('Selecionada viagem internacional')     
			_cLocal := STR0028 //"Viagem Internacional"
			_lInter := .T.
		Else
			_cLocal := STR0029 //"Viagem Nacional"
			_lInter := .F.
		EndIf
	Else
		_lCidDest := .F.
		MsgInfo(STR0030, STR0013) //'Cidade não Cadastrada.'###'Atenção'
	EndIf
Else
	_cMun := ''
EndIf
If cValtoChar(nStatus) $ "02345" .AND. LHP->LHP_CODMUN # _cCodCidade      
	If _lInter
		_nValorR := 0
	Else
		_nValorU := 0
	Endif
Endif
_oLocal:Refresh()

Return(_lCidDest)

//--------------------------------------------------------------------------------------
Static Function VHotel() //Valida codigo do hotel digitado e exibe seu nome
//--------------------------------------------------------------------------------------
Local _lHotel := .T.

If !Empty(_cHosped)
	DbSelectArea('LJ3')
	DbSetOrder(1)
	If MsSeek(xFilial('LJ3') + _cHosped)
		_cNomeHotel := LJ3->LJ3_NOME
		If !Empty(_cCodCidade)             
		//parei aqui - ativar as linhas abaixo dentro de um loop quando for possivel selecionar varias cidades para os hoteis
/*			If _cCodCidade <> LJ3->LJ3_MUNIC
				MsgInfo('Hotel selecionado não esta instalado dentro da cidade selecionada como destino')
			EndIf*/
		EndIf
	Else
		_lHotel := .F.
		MsgInfo(STR0031, STR0013) //'Hotel não Cadastrado.'###'Atenção'
	EndIf
Else
	_cNomeHotel := ''
EndIf

Return(_lHotel)

//--------------------------------------------------------------------------------------
Static Function Grava()
//--------------------------------------------------------------------------------------
Local _lReturn := .F.

If !DadosOk()
	Return
EndIf

If ExistBlock("VLDGRAVA")
	_lReturn := ExecBlock("VLDGRAVA", .F., .F.,{	_cQuem, 	_cAntec, 		_dEmissao,;
													_cFunc, 	_cSupImd, 		_cDGRar,;
													_cEmpCli, 	_cCodCidade, 	_cCC,;
													_mMotivo, 	_mObs, 			_dSaida,;
													_dChegada, 	_cHoraId, 		_cHoraVt,;
													_nFatCli, 	_nFatMic, 		_lAdiant,;
													_lPassag, 	_lHosped, 		_nValorR,;
													_nValorU, 	_cHosped, 		_cSolPor })
	If ! _lReturn
		Return
	EndIf
EndIf

Calcula()

//Validação Adiantamento KM CAIXA RS
If !_lAdiaOK
	Return
EndIf

Begin Transaction
	DbSelectArea('LHP')
	If nStatus == 2 //Alteracao
		RecLock('LHP', .F.)
	Else
		RecLock('LHP', .T.)
	EndIf
	LHP->LHP_Filial := xFilial('LHP')
	LHP->LHP_Quem	:= _cQuem 
	LHP->LHP_Antec	:= _cAntec
	LHP->LHP_FPrazo := _lFPrazo
	LHP->LHP_Emiss	:= _dEmissao
	LHP->LHP_Impres := LHP->LHP_Impres + 1
	LHP->LHP_CC		:= _cCC
	LHP->LHP_Func	:= _cFunc
	LHP->LHP_NFunc	:= _cNFunc
	LHP->LHP_DGRar	:= _cDGRar
	LHP->LHP_SupImd := _cSupImd
	LHP->LHP_EmpCli := _cEmpCli
	LHP->LHP_CODMUN := _cCodCidade
	LHP->LHP_Local	:= _cMun 
	LHP->LHP_Saida	:= _dSaida
	LHP->LHP_Chegad := _dChegada
	LHP->LHP_HoraId := _cHoraId
	LHP->LHP_HoraVt := _cHoraVt
	LHP->LHP_FatCLi := _nFatCli
	LHP->LHP_FatMic := _nFatMic
	LHP->LHP_Adiant := _lAdiant
	LHP->LHP_Passag := _lPassag
//	LHP->LHP_HPass	:= _cPassag //Historico da Passagem
	LHP->LHP_Hosped := _lHosped
//	LHP->LHP_HHosp	:= _cHosped //Historico da Hospedagem
	LHP->LHP_ValorR := _nValorR
	LHP->LHP_ValorU := _nValorU
	LHP->LHP_CODHOT	:= _cHosped
	LHP->LHP_Banco	:= _cBanco
	LHP->LHP_Agenci := _cAgenci
	LHP->LHP_Conta	:= _cConta
	LHP->LHP_Flag	:= 'D'
	LHP->LHP_Flag1	:= 'M'
	
	//Valores das diarias utilizadas no calculo do adiantamento
	LHP->LHP_UmDia	:= Str(_nDiariaUmDIa)
	LHP->LHP_RDia	:= Str(_nVlDiaria)
	LHP->LHP_DiaInt	:= _nVlDiaInt
	LHP->LHP_ViaNac	:= Str(_nAcrescimo)
	LHP->LHP_ViaInt	:= Str(_nAcrescimo)
	LHP->LHP_KMI	:= GetMV('MV_KmI')
//	LHP->LHP_HSai	:= Trim(Str(GetMV('MV_HSai')))
//	LHP->LHP_HCheg	:= Trim(Str(GetMV('MV_HCheg')))
	LHP->LHP_SolPor := _cSolPor
	LHP->LHP_HrSolP := Time()
	LHP->LHP_EINTER := IIf(_cLocal == STR0029, .F., .T.) //"Viagem Nacional"

	If ExistBlock("GRVGRAVA") //Testar execucao sem retorno algum
		ExecBlock("GRVGRAVA", .F., .F.,{	_cQuem, 	_cAntec, 		_dEmissao,;
											_cFunc, 	_cSupImd, 		_cDGRar,;
											_cEmpCli, 	_cCodCidade, 	_cCC,;
											_mMotivo, 	_mObs, 			_dSaida,;
											_dChegada, 	_cHoraId, 		_cHoraVt,;
											_nFatCli, 	_nFatMic, 		_lAdiant,;
											_lPassag, 	_lHosped, 		_nValorR,;
											_nValorU, 	_cHosped, 		_cSolPor })
	EndIf
	MsUnLock('LHP')
	If !Empty(_mMotivo)
		MSMM(,80,,_mMotivo,1,,,"LHP","LHP_CODMOT")
	Endif
	
	If !Empty(_mObs)
		MSMM(,80,,_mObs,1,,,"LHP","LHP_CODOBS")
	Endif
	
End Transaction

If GetMv("MV_EAUTOM1")
	_nRecno := Recno()
	U_AEWF001(1,_nRecno,.F.,"SC",NIL)   
	RecLock('LHP', .F.)
		LHP->LHP_FLAG  := 'I'
		LHP->LHP_Flag1 := 'M'
	MsUnLock('LHP')
EndIf

oPrincipal:End()

Return

//--------------------------------------------------------------------------------------
Static Function DadosOk()
//--------------------------------------------------------------------------------------
Local _cMSGPRAZ
Local lNoAdto := .F.
Private _lDadosOk := .T.                               

//Permite inclusão de solicitação sem adiantamento
If ExistBlock("AE_NOADTO")
	lNoAdto :=	ExecBlock("AE_NOADTO",.F.,.F.)    
EndIf               

Do Case
	Case Empty(_cCC)
		_lDadosOk := .F.
		MsgInfo(STR0032, STR0033) //'Centro de Custo não Informado.'###'Dados Incompletos'
	Case Empty(_dEmissao)
		_lDadosOk := .F.
		MsgInfo(STR0034, STR0033) //'Data de Emissão não Informada.'###'Dados Incompletos'
	Case Empty(_cFunc)
		_lDadosOk := .F.
		MsgInfo(STR0035, STR0033) //'Colaborador não Informado.'###'Dados Incompletos'
	Case Empty(_cSupImd)
		_lDadosOk := .F.
		MsgInfo(STR0036, STR0033) //'Aprovador I não Informado.'###'Dados Incompletos'
	Case Empty(_cDGRar)
		_lDadosOk := .F.
		MsgInfo(STR0037, STR0033) //'Aprovador II não Informado.'###'Dados Incompletos'
	//Cliente nao eh obrigatorio
   /*	Case Empty(_cEmpCli)
		_lDadosOk := .F.
		MsgInfo('Empresa/Cliente não Informado.', 'Dados Incompletos')*/
	Case Empty(_cCodCidade)
		_lDadosOk := .F.
		MsgInfo(STR0038, STR0033) //'Local de Destino não Informado.'###'Dados Incompletos'
	Case Empty(_dSaida)
		_lDadosOk := .F.
		MsgInfo(STR0039, STR0033) //'Data de Saída no Período não Informada.'###'Dados Incompletos'
	Case _dSaida < dDataBase .Or. _dSaida < _dEmissao
		_lDadosOk := .F.
		MsgInfo(STR0040, STR0041) //'Data de Saída deve ser Maior ou Igual a Hoje.'###'Dados Incorretos'
	Case Empty(_dChegada)
		_lDadosOk := .F.
		MsgInfo(STR0042, STR0033) //'Data de Chegada no Período não Informada.'###'Dados Incompletos'
	Case _dChegada < _dSaida
		_lDadosOk := .F.
		MsgInfo(STR0043, STR0041) //'Data de Chegada deve ser Maior ou Igual Saída.'###'Dados Incorretos'
	Case Empty(_mMotivo)
		_lDadosOk := .F.
		MsgInfo(STR0044, STR0033) //'Informe o Motivo da Viagem.'###'Dados Incompletos'
	Case !SetHora()
		_lDadosOk := .F.
		MsgInfo(STR0045, STR0041) //'Horário Informado Inválido.'###'Dados Incorretos'
	Case _nFatCli + _nFatMic <> 100
		_lDadosOk := .F.
		MsgInfo(STR0046, STR0041) //'Percentual a Faturar Diferente de 100%.'###'Dados Incorretos'
	Case Empty(_cSolPor)
		_lDadosOk := .F.
		MsgInfo(STR0047, STR0033) //'Necessário Informar Nome do Solicitante.'###'Dados Incompletos'
	Case !_lAdiant .And. !_lPassag .And. !_lHosped  
		If lNoAdto      
			_lDadosOk := .T.
		Else		
			_lDadosOk := .F.
			MsgInfo(STR0048, STR0033) //'Necessário Informar Adiantamento ou Passagem ou Hospedagem.'###'Dados Incompletos'
		Endif
EndCase

_lFPrazo := .F.
_cMSGPRAZ:=GetMv('MV_MSGPRAZ')

If _dSaida - _dEmissao < Val(SubStr(_cAntec,1,2))
	DbSelectArea("LJ8")
	DbSetOrder(1)
	DbSeek(XFilial()+SubStr(_cAntec,1,2))
	
	If LJ8->LJ8_BLOQ == "1"
		If Right(RTrim(_cMSGPRAZ), 1) == "."
			_cMSGPRAZ += STR0049 //" Essa solicitacao nao podera ser concluida!"
		Else
			_cMSGPRAZ += STR0050 //". Essa solicitacao nao podera ser concluida!"
		EndIf
		_lDadosOK := .F.
	EndIf

	MsgInfo(_cMSGPRAZ, STR0051) //'Informativo'
	_lFPrazo := .T.
EndIf

Return _lDadosOk

//--------------------------------------------------------------------------------------
Static Function SetHora()
//--------------------------------------------------------------------------------------
Local _lSetHora := .T.

Do Case
	Case !Empty(_cHoraId) .And. (Val(SubStr(_cHoraId,1,2)) < 0 .Or. Val(SubStr(_cHoraId,1,2)) > 23)
		_lSetHora := .F.
	Case !Empty(_cHoraId) .And. (Val(SubStr(_cHoraId,4,2)) < 0 .Or. Val(SubStr(_cHoraId,4,2)) > 59)
		_lSetHora := .F.
	Case !Empty(_cHoraVt) .And. (Val(SubStr(_cHoraVt,1,2)) < 0 .Or. Val(SubStr(_cHoraVt,1,2)) > 23)
		_lSetHora := .F.
	Case !Empty(_cHoraVt) .And. (Val(SubStr(_cHoraVt,4,2)) < 0 .Or. Val(SubStr(_cHoraVt,4,2)) > 59)
		_lSetHora := .F.
	Case SubStr(_cAntec,4,1) == 'h' .And. Empty(_cHoraId)
		_lSetHora := .F.
EndCase

Return(_lSetHora)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do Adiantamento.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function Calcula()
Local _nDias, aArea:=GetArea(), _cCargo:=Space(TamSx3("LJL_CODCAR")[1]), _nValores := {}
_nValorR := 0
_nValorU := 0

//Caso o colaborador selecione as opcoes de Passagem ou Hospedagem, zero o
//valor sobre adiantamento de kilometragem e os kms informadors
If _lAlocVeic .Or. _lPassag
	_nAcresKM := 0
	_nKm := 0
EndIf

If !_lAdiant // Sem Adiantamento
	_nValorR := 0
	_nValorU := 0
	_oValorR:Refresh()
	_oValorU:Refresh()
	Return
EndIf

DbSelectArea("LHP")

If !SetHora()
	MsgInfo(STR0045, STR0041) //'Horário Informado Inválido.'###'Dados Incorretos'
	Return
EndIf

If Empty(_dSaida) .Or. Empty(_dChegada)
	MsgInfo(STR0052, STR0041) //'Período Inválido para Viagem.'###'Dados Incorretos'
	Return
EndIf

If _dSaida < dDataBase
	MsgInfo(STR0040, STR0041) //'Data de Saída deve ser Maior ou Igual a Hoje.'###'Dados Incorretos'
	Return
EndIf

If _dChegada < _dSaida
	MsgInfo(STR0043, STR0041) //'Data de Chegada deve ser Maior ou Igual Saída.'###'Dados Incorretos'
	Return
EndIf

_nDias := _dChegada - _dSaida + 1

If _lInter // Viagem Internacional
	//Selecionar os valores do cargo do colaborador
	DbSelectArea("LHT")
	DbOrderNickName("LHTCDV1")
	If LHT->(DbSeek(xFilial("LHT")+_cFunc))
		If AllTrim(LHT->LHT_CARGO) != ""
			_cCargo:=LHT->LHT_CARGO
			DbSelectArea("LJL")
			DbSetOrder(1)
			If LJL->(DbSeek(xFilial("LJL")+_cCargo))
				If LJL->LJL_VLINT > 0
					_nVlDiaInt	:= LJL->LJL_VLINT  //Valor diaria Internacional
					_nVlDiaria	:= LJL->LJL_VLCPER //Essa variavel sera usada para gravar o valor da diaria na tabela de solicitacao
					_nAcrescimo	:= LJL->LJL_ACRESC //Essa variavel sera usada para gravar o valor da diaria na tabela de solicitacao
					_nDiariaUmDIa := 0 //Essa variavel sera usada para gravar o valor da diaria na tabela de solicitacao
					_nValorU 	:= Round((_nVlDiaInt * _nDias),2)
					_nValorR 	:= _nAcrescimo
				EndIf
			EndIf
		EndIf
	EndIf

	If _nValorU == 0 .And. !ExistBlock("POS_ADIA") 
		MsgInfo(STR0053 , STR0054) //"Tabela com o Valor da Diária em US$ para este cargo não está Cadastrada, favor Comunicar o Departamento de Viagem !"###"Informativo"
		_nValorU := 0
		_nValorR := 0
	EndIf	
Else              
	//Selecionar os valores do cargo do colaborador
	DbSelectArea("LHT")
	DbOrderNickName("LHTCDV1")
	If LHT->(DbSeek(xFilial("LHT")+_cFunc))
		If AllTrim(LHT->LHT_CARGO) != ""
			_cCargo:=LHT->LHT_CARGO
			DbSelectArea("LJL")
			DbSetOrder(1)
			If LJL->(DbSeek(xFilial("LJL")+_cCargo))
				If _nDias == 1
					If LJL->LJL_VLSPER > 0
						_nDiariaUmDIa 	:= LJL->LJL_VLSPER	//Essa variavel sera usada para gravar o valor da diaria na tabela de solicitacao
						_nVlDiaria		:= LJL->LJL_VLCPER	//Essa variavel sera usada para gravar o valor da diaria na tabela de solicitacao
						_nAcrescimo		:= LJL->LJL_ACRESC 	//Essa variavel sera usada para gravar o valor da diaria na tabela de solicitacao
						If _lPassag
							_nValorR 	:= Round((_nDiariaUmDIa + _nAcrescimo + _nAcresKM + _nValAcr ), 2) //Variavel que alimenta o objeto na tela
						Else
							_nValorR 	:= Round(_nDiariaUmDIa + _nAcresKM + _nValAcr , 2) //Variavel que alimenta o objeto na tela
						EndIf
					EndIf
				Else
					If LJL->LJL_VLCPER > 0
						_nDiariaUmDIa 	:= LJL->LJL_VLSPER	//Essa variavel sera usada para gravar o valor da diaria na tabela de solicitacao
						_nVlDiaria		:= LJL->LJL_VLCPER	//Essa variavel sera usada para gravar o valor da diaria na tabela de solicitacao
						_nAcrescimo		:= LJL->LJL_ACRESC 	//Essa variavel sera usada para gravar o valor da diaria na tabela de solicitacao
						If _lPassag
							_nValorR 	:= Round((_nVlDiaria * _nDias + _nAcrescimo + _nAcresKM + _nValAcr ), 2) //Variavel que alimenta o objeto na tela
						Else
							_nValorR 	:= Round((_nVlDiaria * _nDias + _nAcresKM + _nValAcr), 2) //Variavel que alimenta o objeto na tela
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If _nValorR == 0 .And. !ExistBlock("POS_ADIA")
		If _nDias == 1
			MsgInfo(STR0055) //'Não há valores cadastrados para viagens nacionais sem pernoite para este cargo. Por favor, contate o Depto. de Viagens.'
		Else
			MsgInfo(STR0056) //'Não há valores cadastrados para viagens nacionais com pernoite para este cargo. Por favor, contate o Depto. de Viagens.'
		EndIf
	EndIf
EndIf

//Ponto de Entrada apos o calculo
If ExistBlock("POS_ADIA")
	_nValores := ExecBlock("POS_ADIA", .F., .F.,{	_cQuem, 	_cAntec, 		_dEmissao,;
													_cFunc, 	_cSupImd, 		_cDGRar,;
													_cEmpCli, 	_cCodCidade, 	_cCC,;
													_mMotivo, 	_mObs, 			_dSaida,;
													_dChegada, 	_cHoraId, 		_cHoraVt,;
													_nFatCli, 	_nFatMic, 		_lAdiant,;
													_lPassag, 	_lHosped, 		_nValorR,;
													_nValorU, 	_cHosped, 		_cSolPor,; 
													_lAlocVeic })
	If _nValores[3]
		_nValorR := _nValores[1]
		_nValorU := _nValores[2]
	EndIf
EndIf

_oValorR:Refresh()
_oValorU:Refresh()

RestArea(aArea)
Return

//--------------------------------------------------------------------------------------
Static Function AtribuiCampos( lCopia ) //Atribui Dados da Tabela aos Campos de tela
//--------------------------------------------------------------------------------------
Local _aArea := GetArea()

Default lCopia := .F.

If !lCopia
	_dEmissao 	:= LHP->LHP_Emiss
EndIf

_cFunc		:= LHP->LHP_Func
_cNFunc 	:= LHP->LHP_NFunc

_cSupImd  := LHP->LHP_SupImd
DbSelectArea('LHT')
DbSetOrder(1)
If MsSeek(xFilial('LHT') + _cSupImd)
	_cNSupImd := LHT->LHT_NOME
Else
	_cNSupImd := ''
EndIf

_cDGRar  := LHP->LHP_DGRAR
DbSelectArea('LHT')
DbSetOrder(1)
If MsSeek(xFilial('LHT') + _cDGRar)
	_cNDGRar := LHT->LHT_NOME
Else
	_cNDGRar := ''
EndIf

_cEmpCli  := LHP->LHP_EmpCli
DbSelectArea('SA1')
DbSetOrder(1)
If MsSeek(xFilial('SA1') + _cEmpCli)
	_cNEmpCli := SA1->A1_NOME
Else
	_cNEmpCli := ''
EndIf

_cCodCidade	:= LHP->LHP_CODMUN
DbSelectArea('LDY')
DbSetOrder(1)
If MsSeek(xFilial('LDY') + _cCodCidade)
	_cMun := LDY->LDY_NOME
Else
	_cMun := ''
EndIf 

_cCC 		:= LHP->LHP_CC
_mMotivo 	:= MSMM(LHP->LHP_CodMot,,,,3)
_mObs 		:= MSMM(LHP->LHP_CodObs,,,,3)
_dSaida   	:= LHP->LHP_Saida
_dChegada 	:= LHP->LHP_Chegad
_cHoraId 	:= LHP->LHP_HoraId
_cHoraVt 	:= LHP->LHP_HoraVt
_nFatCli 	:= LHP->LHP_FatCli
_nFatMic 	:= LHP->LHP_FatMic
_lAdiant 	:= LHP->LHP_Adiant
_lPassag 	:= LHP->LHP_PASSAG
_lHosped	:= LHP->LHP_Hosped
_cHosped	:= LHP->LHP_CODHOT

DbSelectArea('LJ3')
DbSetOrder(1)
If MsSeek(xFilial('LJ3') + _cHosped)
	_cNomeHotel := LJ3->LJ3_NOME
Else
	_cNomeHotel := ''
EndIf

_nValorR := LHP->LHP_ValorR
_nValorU := LHP->LHP_ValorU
_cBanco  := LHP->LHP_Banco
_cAgenci := LHP->LHP_Agenci
_cConta  := LHP->LHP_Conta

//CRIAR ESPACO PARA OS CAMPOS ABAIXO
_cSolPor := LHP->LHP_SolPor 
_cHrSolP := LHP->LHP_HrSolP
_cAprov  := LHP->LHP_Aprov 
_cHrApv1 := LHP->LHP_HrApv1
_cSolFin := LHP->LHP_SolFin 
_cHrSolF := LHP->LHP_HrSolF
_cAprovF := LHP->LHP_AprovF 
_cHrApv2 := LHP->LHP_HrApv2


RestArea(_aArea)
Return

//----------------------------------------------------------------------------------------------------------
User Function EditaTexto(_cTitulo, _cTexto, _lEdita) //Mostra janela de Motivo e Obs ao clicar no botao
//----------------------------------------------------------------------------------------------------------
Local _cTextoOld := _cTexto
Local _cTextoNew := '' , oEditaTexto

chktemplate("CDV")

//Ponto de entrada para customização do motivo da viagem (CAIXA RS)
If ExistBlock("AE_MOTVIAG")
	ExecBlock("AE_MOTVIAG",.F.,.F.)
EndIf

DEFINE MSDIALOG oEditaTexto FROM  000,000 TO 200,365 TITLE OemToAnsi(_cTitulo) PIXEL

@ 005,005 GET _oTexto VAR _cTexto MEMO When _lEdita Size 175,075 OF oEditaTexto PIXEL

DEFINE SBUTTON FROM 084,120 TYPE 1 ENABLE OF oEditaTexto ACTION (nOpca:=1,_cTextoNew:= TextoOk(_cTexto,oEditaTexto))
DEFINE SBUTTON FROM 084,150 TYPE 2 ENABLE OF oEditaTexto ACTION (nOpca:=0,_cTextoNew:= TextoOk(_cTextoOld,oEditaTexto))

ACTIVATE MSDIALOG oEditaTexto CENTERED

Return(_cTextoNew)

//----------------------------------------------------------------------------------------------------------
Static Function TextoOK(_cQualTexto,oEditaTexto)
//----------------------------------------------------------------------------------------------------------
	oEditaTexto:End()
Return(_cQualTexto)

//----------------------------------------------------------------------------------------------------------
Static Function Acao() //Acao realizada apos o clique do botão OK
//----------------------------------------------------------------------------------------------------------
Local _cPerg, _cOpcao, _cRot := FunName()

Default __lCDVPCOLCO := ExistBlock("CDVPCOLCO")

	If nStatus == 0 //VISUALIZAR 
		oPrincipal:End() //Fechar a janela

	ElseIf nStatus == 1 .Or. nStatus == 2 //INCLUIR OU ALTERAR 
		If VFunc() //Grava apenas se o recurso estiver ok
			Grava()
			If __lCDVPCOLCO
				ExecBlock("CDVPCOLCO",.F.,.F.)
			EndIf
		EndIf							

	ElseIf nStatus == 3 //EXCLUIR
		If RecLock('LHP', .F.)
			DbDelete()
			MsUnLock('LHP')
			
			If !Empty(_mMotivo)
				MSMM(LHP->LHP_CodMot,,,,2)
			Endif
			
			If !Empty(_mObs)
				MSMM(LHP->LHP_CodObs,,,,2)
			Endif

			MsgInfo(STR0057, STR0013) //'Registro excluído com sucesso!'###'Atenção'
			oPrincipal:End() //Fechar a janela
		Else
			MsgInfo(STR0058, STR0013) //'Registro Bloqueado por outro Usuário !'###'Atenção'
		EndIf

	ElseIf nStatus == 4 //APROVACAO
		If AllTrim(_cRot) == "AE_SVIAG" .OR. AllTrim(_cRot) == "U_AE_SVIAG" // Rotina de Solicitação de Viagem
			_cPerg := STR0059 //"Deseja enviar Solicitação de Viagem para Aprovação ?"
			_cOpcao := "SC"
		Else // Rotina de Solicitação de Viagem para Depto de viagens
			_cPerg := STR0059 //"Deseja enviar Solicitação de Viagem para Aprovação ?"
			_cOpcao := "SCV"
		Endif

		IF MsgYESNO(_cPerg, STR0022) //"Atenção"
			U_AEWF001(1,_nRecno,.F.,_cOpcao,NIL)
			RecLock('LHP', .F.)
			If _cOpcao == "SC"
				LHP->LHP_FLAG  := 'I'
				LHP->LHP_Flag1 := 'M'
			Else
				LHP->LHP_Flag  := 'M'
				LHP->LHP_FLAG1 := 'I'
			Endif
			MsUnLock('LHP')  
			
			If _cOpcao == "SC"
				If ExistBlock("PE_APROV")
					ExecBlock("PE_APROV", .F., .F.)
				EndIf
			EndIf
		EndIf
		oPrincipal:End() //Fechar a janela

	ElseIf nStatus == 5 //COPIAR SOLICITACAO
		If VFunc() //Grava apenas se o recurso estiver ok
			Grava()
		EndIf			
		oPrincipal:End() //Fechar a janela
	
	EndIf 
Return

//----------------------------------------------------------------------------------------------------------
//Static Function ZerarVariaveis() //Zerar Variaveis para uma nova inclusao
//----------------------------------------------------------------------------------------------------------
/*_dEmissao 	:= dDataBase
_cFunc		:= Space(Len(_cFunc))
_cNFunc 	:= ''
_cSupImd  	:= ''
_cNSupImd 	:= ''
_cDGRar  	:= ''
_cNDGRar 	:= ''
_cEmpCli  	:= ''
_cNEmpCli 	:= ''
_cCodCidade	:= ''
_cMun 		:= ''
_cCC 		:= ''
_mMotivo 	:= MSMM('',,,,3)
_mObs 		:= MSMM('',,,,3)
_dSaida   	:= CtoD('  /  /  ')
_dChegada 	:= CtoD('  /  /  ')
_cHoraId 	:= ''
_cHoraVt 	:= ''
_nFatCli 	:= 0
_nFatMic 	:= 0
_lAdiant 	:= .F.
_lPassag 	:= .F.
_lHosped	:= .F.
_cHosped	:= ''
_cNomeHotel := ''
_nValorR 	:= 0
_nValorU 	:= 0
_cBanco  	:= ''
_cAgenci 	:= ''
_cConta  	:= ''
Return*/

//----------------------------------------------------------------------------------------------------------
Static Function ValAprov()
//----------------------------------------------------------------------------------------------------------
Local lRet:= .T., _cRot := FunName()

	If AllTrim(_cRot) == "AE_SVIAG" .OR. AllTrim(_cRot) == "U_AE_SVIAG" // Rotina de Solicitação de Viagem
		If LHP->LHP_Flag == 'K' //Solicitacao cancelada
			MsgInfo(STR0060) //"Esta solicitação está cancelada."
			lRet := .F.
		ElseIf LHP->LHP_Flag <> 'D'
			MsgInfo(STR0061, STR0013) //'Solicitação já foi Encaminhada para Aprovação !'###'Atenção'
			lRet := .F.
		ElseIf !Empty(LHP->LHP_Codigo)
			MsgInfo(STR0062, STR0013) //'Código da Solicitação já Preenchido!'###'Atenção'
			lRet := .F.
		EndIf
	Else // Rotina de Solicitação de Viagem para Depto de viagens
		If LHP->LHP_Flag1 == 'K' //Solicitacao cancelada
			MsgInfo(STR0063) //"Esta solicitação está cancelada e não pode ser alterada."
			lRet := .F.
		ElseIf LHP->LHP_Flag1 <> 'D'
			MsgInfo(STR0064, STR0013) //'Solicitação nao encaminhada para aprovação !'###'Atenção'
			lRet := .F.
		ElseIf !Empty(LHP->LHP_Codigo)
			MsgInfo(STR0062, STR0013) //'Código da Solicitação já Preenchido!'###'Atenção'
			lRet := .F.
		EndIf
	Endif
	
Return lRet                

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AE_SV001_AP6ºAutor  ³Ricardo A. Canteras º Data ³  31/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do valor a ser adiantado de acordo com os             º±±
±±º          ³Kilometros informados pelo colaborador                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Template CDV                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CalcKM()

Local aArea		:= GetArea()
Local lRet 		:= .T.
Local nFator	:= 1          
Local lOk		:= .T.
Local ni		:= 0
Local aRefKMI	:= {}       
Local nPosSepP	:= 0
Local nSepDec	:= 0
Local cKMI		:= SuperGetMV("MV_KMI",.F.,"")

If _lAlocVeic .Or. _lPassag
	MsgInfo(STR0065,STR0022) //"Desabilite os campos referentes a 'Passagem' e 'Aloc. Veic.' para utilizar adiantamento sobre Kilometragem!"###"Atenção"
	lRet := .F.
EndIf
	
If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mostra Get da Quantidade de Kilômetros               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpca := 0
		
	DEFINE MSDIALOG oDlg FROM 10, 5 TO 25, 38 TITLE STR0066 //"Kilômetros a serem Adiantados"
	@	.3,1 TO 07.3,15 OF oDlg  
	@	2.0,2 Say STR0067 Of oDlg  //"Quantidade Km(s):"
	@	2.0,8 MSGET _oQtdKm VAR _nKm	Picture "@E 99,999.9" SIZE 25, 10 OF oDlg
	DEFINE SBUTTON FROM 070,035   TYPE 1 ACTION (nOpca := 1,;
	If(_nKm > 0,oDlg:End(),nOpca:=0)) ENABLE OF oDlg
	DEFINE SBUTTON FROM 070,065.1 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED
		
	If nOpca != 0
		//Calculo o valor a ser adiantado sobre a qtde de KM informados
		nPosSepP := At("/",cKMI)
		aAdd(aRefKMI,AllTrim(Substr(cKMI,1,nPosSepP - 1)))
		aAdd(aRefKMI,AllTrim(Substr(cKMI,nPosSepP+1,Len(cKMI))))		
		//Validador do fator de calculo
		If Len(aRefKMI) == 2
			For ni := 1 to Len(aRefKMI[2]) Step 1
				If !Substr(aRefKMI[2],ni,1) $ ",.1234567890"
					lOk := .F.
					Exit
				ElseIf Substr(aRefKMI[2],ni,1) == ","
					nSepDec++
					aRefKMI[2] := Substr(aRefKMI[2],1,ni-1) + "." + Substr(aRefKMI[2],ni+1,Len(aRefKMI[2]))
				ElseIf Substr(aRefKMI[2],ni,1) == "."
					nSepDec++
				Endif
				If nSepDec > 1
					lOk := .F.
					Exit
				Endif			
			Next ni
		Endif		
		If lOk
			nFator := Val(aRefKMI[2])
		Endif			
		_nAcresKM := _nKm *	nFator
	EndIf
EndIf       
RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SV001_VAD ºAutor ³Pablo Gollan Carrerasº Data ³  17/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validador do adiantamento                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³AE_SV001                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SV001_VAD()

If !_lAdiant
	_nValorR := 0
	_nValorU := 0
Endif

Return .T.
