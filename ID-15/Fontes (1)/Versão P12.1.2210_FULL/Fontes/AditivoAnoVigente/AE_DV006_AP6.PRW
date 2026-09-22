#INCLUDE "AE_DV006_AP6.ch"
#Include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AE_DV006  ºAutor  ³Willy               º Data ³  10/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Fechamento da Prestação de Contas.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AE_DV006()

Local _nRow,_nAux
Private _nVlSubTot,_nVlFatMic,_nVlIss,_nVlCofins,_nVlPis,_nVlTotFat,_nVlFatCli,_nVlFatFra
Private _nAlCOFINS,_nAlISS,_nAlPIS,_nAlTOTAL,aButtons,_aAreaLHPv,_nVlTtDesM2,_nVlTotDesp
Private _cUsuaViagem := GetMv('MV_USVIAGE'),lGravaFecha:= .T.,_nVlPassag,_nVlHospd
Private _cUsLogin:= AllTrim(SubStr(cUsuario,7,15)),_nQuem, _ConCC:=GetMv('MV_CCCDV')

chktemplate("CDV")

If LHQ->LHQ_Flag == 'K'
	MsgInfo(STR0001, STR0002) //'Esta solicitação está cancelada e nõa pode ser fechada.'###'Atenção'
	Return
Endif
	
If !_cUsLogin $ AllTrim(_cUsuaViagem) // Verifica se eh o usuario do Depto de Viagem.
	If LHQ->LHQ_Flag <> 'C'
		If LHQ->LHQ_Flag $ 'ZB'
			lGravaFecha:= .F.
			MsgInfo(STR0003, STR0002) //'Prestação de Contas, está Encerrada !'###'Atenção'
		Else
			MsgInfo(STR0004, STR0002) //'Prestação de Contas, não está Liberada !'###'Atenção'
			Return(Nil)
		EndIf
	EndIf
Else
	If !LHQ->LHQ_Flag $ 'CZB'
		MsgInfo(STR0004, STR0002) //'Prestação de Contas, não está Liberada !'###'Atenção'
		Return(Nil)
	EndIf
Endif
aButtons := {}
AaDd(aButtons, {"SIMULACA", {|| CalcFecha()},  STR0005 }) //"Calculo Total a Faturar"

DEFINE MSDIALOG oPrincipal FROM  000,000 TO 440,720 TITLE OemToAnsi(STR0006 + LHQ->LHQ_CODIGO) PIXEL //'Fechamento da Prestação de Contas - '

_aAreaLHPv:= GetArea()
// Alicotas Utilizadas nos Calculos
_nAlISS   := GetNewPar("MV_AISS",0)
_nAlCOFINS:= GetNewPar("MV_ACOFINS",0)
_nAlPIS   := GetNewPar("MV_APIS",0)
_nAlTOTAL := 100 - (_nAlISS+_nAlCOFINS+_nAlPIS)   

DbSelectArea('LHP')
DbSetOrder(1)
MsSeek(xFilial('LHP') + LHQ->LHQ_CODIGO)

_nQuem := IIf(LHP->LHP_EINTER == .T., "2", "1")
/*_aArea:=GetArea()
DbSelectArea("LJ9")
DbSetOrder(1)
LJ9->(DbSeek(xFilial() + Substr(LHP->LHP_Quem, 0, 4)))
_nQuem := LJ9->LJ9_NACION
RestArea(_aArea)*/

DbSelectArea('LHQ')
_nRow:= 15
@ _nRow,003 TO _nRow+18,359 OF oPrincipal PIXEL

_nRow+=5
_cQuem := LHP->LHP_Quem
@ _nRow,006 SAY STR0007 OF oPrincipal PIXEL //'Solicitante / País'
@ _nRow,048 MSGET _cQuem Size 82,07 When .F. OF oPrincipal PIXEL

_cAntec := LHP->LHP_Antec
@ _nRow,135 SAY STR0008 OF oPrincipal PIXEL //'Antecedência'
@ _nRow,172 MSGET _cAntec Size 100,07 When .F. OF oPrincipal PIXEL

_dEmissao := LHQ->LHQ_Emiss
@ _nRow,278 SAY STR0009 OF oPrincipal PIXEL //'Data da Emissão'
@ _nRow,322 MSGET _dEmissao Picture '@D' Size 35,07 When .F. OF oPrincipal PIXEL

_nRow+=18
_nAux := _nRow
_cFunc	:= LHQ->LHQ_Func
_cNFunc := LHP->LHP_NFunc
@ _nRow,005 SAY STR0010 OF oPrincipal PIXEL //'Colaborador'
@ _nRow,097 SAY STR0011 OF oPrincipal PIXEL //'Nome'
@ _nRow,055 MSGET _cFunc  Picture '@!' When .F. OF oPrincipal PIXEL
@ _nRow,117 MSGET _cNFunc Picture '@!' Size 163,07 When .F. OF oPrincipal PIXEL

_nRow+=13
_cSupImd  := LHQ->LHQ_SupImd
DbSelectArea('LHT')
DbSetOrder(1)
If MsSeek(xFilial('LHT') + _cSupImd)
	_cNSupImd := LHT->LHT_Nome
Else
	_cNSupImd := ''
EndIf
DbSelectArea('LHP')
@ _nRow,005 SAY STR0012 OF oPrincipal PIXEL //'Aprovador I'
@ _nRow,097 SAY STR0011 OF oPrincipal PIXEL //'Nome'
@ _nRow,055 MSGET _cSupImd  Picture '@!' When .F. OF oPrincipal PIXEL
@ _nRow,117 MSGET _cNSupImd Picture '@!' Size 163,07 When .F. OF oPrincipal PIXEL

_nRow+=13
_cDGRar  := LHQ->LHQ_DGRar
DbSelectArea('LHT')
DbSetOrder(1)
If MsSeek(xFilial('LHT') + _cDGRar)
	_cNDGRar := LHT->LHT_Nome
Else
	_cNDGRar := ''
EndIf
DbSelectArea('LHP')

@ _nRow,005 SAY STR0013 OF oPrincipal PIXEL //'Aprovador II'
@ _nRow,097 SAY STR0011 OF oPrincipal PIXEL //'Nome'
@ _nRow,055 MSGET _cDGRar  Picture '@!' When .F. OF oPrincipal PIXEL
@ _nRow,117 MSGET _cNDGRar Picture '@!' Size 163,07 When .F. OF oPrincipal PIXEL

_nRow+=13
_cEmpCli  := LHQ->LHQ_EmpCli
DbSelectArea('SA1')
DbSetOrder(1)
If MsSeek(xFilial('SA1') + _cEmpCli)
	_cNEmpCli := SA1->A1_Nome
Else
	_cNEmpCli := ''
EndIf
DbSelectArea('LHP')
@ _nRow,005 SAY STR0014 OF oPrincipal PIXEL //'Empresa / Cliente'
@ _nRow,097 SAY STR0011 OF oPrincipal PIXEL //'Nome'
@ _nRow,055 MSGET _cEmpCli  Picture '@!' When .F. OF oPrincipal PIXEL
@ _nRow,117 MSGET _cNEmpCli Picture '@!' Size 163,07 When .F. OF oPrincipal PIXEL

_nRow+=13
_cLocal := LHP->LHP_Local
@ _nRow,005 SAY STR0015 OF oPrincipal PIXEL //'Local da Viagem'
@ _nRow,055 MSGET _cLocal  Picture '@!' Size 170,07 When .F. OF oPrincipal PIXEL

_cCC := LHQ->LHQ_CC
@ _nAux+3,287 SAY STR0016 OF oPrincipal PIXEL //'CC'
@ _nAux+3,297 MSGET _cCC  Picture '@!' Size 58,07 Valid VCC() F3(_ConCC) OF oPrincipal PIXEL

_nAux+=32
_dSaida   := LHQ->LHQ_Saida
_dChegada := LHQ->LHQ_Chegad
@ _nRow,245 SAY STR0017 OF oPrincipal PIXEL //'Período'
@ _nRow,310 SAY STR0018 OF oPrincipal PIXEL //'à'
@ _nRow,270 MSGET _dSaida   Picture '@D' Size 35,07 When .F. OF oPrincipal PIXEL
@ _nRow,320 MSGET _dChegada Picture '@D' Size 35,07 When .F. OF oPrincipal PIXEL

_nRow+=12
@ _nRow,003 TO _nRow+89,359 OF oPrincipal PIXEL

_cSolPor := LHP->LHP_SolPor ; _cAprov  := LHP->LHP_Aprov
_cSolFin := LHP->LHP_SolFin ; _cAprovF := LHP->LHP_AprovF

@ _nRow,003 TO _nRow+18,359 OF oPrincipal PIXEL

_nRow+=5
@ _nRow,007 SAY STR0019 OF oPrincipal PIXEL //'Solicitado por'
@ _nRow,045 MSGET _cSolPor Picture '@!' Size 30,07 When .F. OF oPrincipal PIXEL

If LHP_Flag == 'P'
	@ _nRow,080 SAY STR0020 OF oPrincipal PIXEL //'Reprovado por'
	@ _nRow,119 MSGET _cAprov Picture '@!' Size 20,07 When .F. OF oPrincipal PIXEL
Else
	@ _nRow,080 SAY STR0021 OF oPrincipal PIXEL //'Aprovado por '
	@ _nRow,119 MSGET _cAprov Picture '@!' Size 20,07 When .F. OF oPrincipal PIXEL
Endif

@ _nRow,154 SAY STR0022 OF oPrincipal PIXEL //'Solicitante Depto Viagem'
@ _nRow,217 MSGET _cSolFin Picture '@!' Size 30,07 When .F. OF oPrincipal PIXEL

If LHP_Flag1 == 'P'
	@ _nRow,254 SAY STR0023 OF oPrincipal PIXEL //'Reprovado Depto Financeiro'
	@ _nRow,327 MSGET _cAprovF Picture '@!' Size 20,07 When .F. OF oPrincipal PIXEL
Else
	@ _nRow,254 SAY STR0024 OF oPrincipal PIXEL //'Aprovador Depto Financeiro'
	@ _nRow,327 MSGET _cAprovF Picture '@!' Size 20,07 When .F. OF oPrincipal PIXEL
Endif

_nVlPassag := LHP->LHP_VLPASS
_nVlHospd  := LHP->LHP_VLHOSP
If _nQuem == "2"
	_nVlTotDesp:= LHQ->LHQ_VlRBM1
	_nVlTtDesM2:= (LHQ->LHQ_ValRB + LHQ->LHQ_ValNR) / LHQ->LHQ_Mtaxa
Else      
	_nVlTtDesM2:= 0
	//Caso o valor gasto for menor que o adiantado, considero o valor do adiantamento
	//If LHP->LHP_VALORR > ABS(LHQ->LHQ_ValRB)	
		//_nVlTotDesp:= LHP->LHP_VALORR  // Adiantamento (R$)
	//Else
		_nVlTotDesp:= ABS(LHQ->LHQ_ValRB) //+ LHP->LHP_VALORR  // Valor Reemb. + Adiantamento (R$)
	//EndIf   
EndIf
_nVlSubTot:= 0 ; _nVlFatMic:= 0 ;_nVlIss:= 0 ; _nVlCofins:= 0
_nVlPis:= 0 ; _nVlTotFat:= 0 ; _nVlFatCli:= 0 ; _nVlFatFra:= 0

_nRow+=18
_nAux := _nRow
ofont3:= TFont():New("Tahoma",14,14,.F. ,.T., ,.T., , .F.,.F.)
If LHP->LHP_Adiant
	If LHP->LHP_OkAdia
		oSay1:= TSay():New(_nRow,048,{||STR0027},oPrincipal,,ofont3,,,,.T.,CLR_HBLUE,CLR_WHITE,200,180) //'Ok'
		_lAdiant := STR0028 //'Adiantamento'
	Else
		_lAdiant := STR0029 //'SIM-Adiantamento'
	EndIf
Else
	_lAdiant := STR0030 //'NÃO-Adiantamento'
EndIf

If LHP->LHP_Passag
	If LHP->LHP_OkPass
		oSay2:= TSay():New(_nRow,109,{||STR0027},oPrincipal,,ofont3,,,,.T.,CLR_HBLUE,CLR_WHITE,200,180) //'Ok'
		_lPassag := STR0031 //'Passagem'
	Else
		_lPassag := STR0032 //'SIM-Passagem Aérea'
	EndIf
Else
	_lPassag := STR0033 //'NÃO-Passagem Aérea'
EndIf

If LHP->LHP_Hosped
	If LHP->LHP_OkHosp
		oSay3:= TSay():New(_nRow,176,{||STR0027},oPrincipal,,ofont3,,,,.T.,CLR_HBLUE,CLR_WHITE,200,180) //'Ok'
		_lHosped := STR0034 //'Hospedagem'
	Else
		_lHosped := STR0035 //'SIM-Hospedagem'
	EndIf
Else
	_lHosped := STR0036 //'NÃO-Hospedagem'
EndIf

@ _nRow,007 SAY _lAdiant OF oPrincipal PIXEL
@ _nRow,072 SAY _lPassag OF oPrincipal PIXEL
@ _nRow,136 SAY _lHosped OF oPrincipal PIXEL

_nRow+=13
@ _nRow,007 SAY STR0037 OF oPrincipal PIXEL //'Total Despesas   R$'
@ _nRow,057 MSGET _nVlTotDesp Picture '@E 999,999.99' Size 40,07 Valid CalcFecha() OF oPrincipal PIXEL

_cAlISS:= AllTrim(Str(_nAlISS)) + STR0038 //'% I.S.S  '
@ _nRow,115 SAY _cAlISS OF oPrincipal PIXEL
@ _nRow,160 MSGET _oVlIss VAR _nVlIss Picture '@E 999,999.99' When .F. Size 40,07 OF oPrincipal PIXEL

_nRow+=13
@ _nRow,007 SAY STR0039 OF oPrincipal PIXEL //'Total Despesas US$'
If _nQuem == "2"
	@ _nRow,057 MSGET _nVlTtDesM2 Picture '@E 999,999.99' Size 40,07 Valid CalcFecha() OF oPrincipal PIXEL
Else
	@ _nRow,057 MSGET _nVlTtDesM2 Picture '@E 999,999.99'  When .F. Size 40,07 Valid CalcFecha() OF oPrincipal PIXEL
EndIf

_cAlCOFINS:= AllTrim(Str(_nAlCOFINS)) +STR0040 //'% COFINS  '
@ _nRow,115 SAY _cAlCOFINS OF oPrincipal PIXEL
@ _nRow,160 MSGET _oVlCofins VAR _nVlCofins Picture '@E 999,999.99' When .F. Size 40,07 OF oPrincipal PIXEL

_nRow+=13
If _nQuem == "2"
	@ _nRow,007 SAY STR0041 OF oPrincipal PIXEL //'Passagem         US$'
Else
	@ _nRow,007 SAY STR0042 OF oPrincipal PIXEL //'Passagem           R$'
EndIf
@ _nRow,057 MSGET _nVlPassag Picture '@E 999,999.99' Size 40,07 Valid CalcFecha() OF oPrincipal PIXEL

_cAlPIS:= AllTrim(Str(_nAlPIS)) +STR0043 //'% PIS    '
@ _nRow,115 SAY _cAlPIS OF oPrincipal PIXEL
@ _nRow,160 MSGET _oVlPis VAR _nVlPis Picture '@E 999,999.99' When .F. Size 40,07 OF oPrincipal PIXEL

_nRow+=13
If _nQuem == "2"
	@ _nRow,007 SAY STR0044 OF oPrincipal PIXEL //'Hospedagem     US$'
Else
	@ _nRow,007 SAY STR0045 OF oPrincipal PIXEL //'Hospedagem       R$'
EndIf
@ _nRow,057 MSGET _nVlHospd Picture '@E 999,999.99' Size 40,07 Valid CalcFecha() OF oPrincipal PIXEL

_nRow+=13
@ _nRow,003 TO _nRow+18,359 OF oPrincipal PIXEL

_nRow+=5
If _nQuem == "2"
	@ _nRow,007 SAY STR0046 OF oPrincipal PIXEL //'Sub Total           US$'
Else
	@ _nRow,007 SAY STR0047 OF oPrincipal PIXEL //'Sub Total             R$'
EndIf
@ _nRow,057 MSGET _oVlSubTot VAR _nVlSubTot Picture '@E 999,999.99' When .F. Size 40,07 OF oPrincipal PIXEL

@ _nRow,115 SAY STR0048 OF oPrincipal PIXEL //'Total a Faturar R$'
@ _nRow,160 MSGET _oVlTotFat VAR _nVlTotFat Picture '@E 999,999.99' When .F. Size 40,07 OF oPrincipal PIXEL

_nFatCli := LHQ->LHQ_FatCli ; _nFatFra := LHQ->LHQ_FatFra ; _nFatMic := LHQ->LHQ_FatMic
_cSistem := LHP->LHP_Sistem
@ _nAux,235 SAY STR0049 OF oPrincipal PIXEL //'Politica Adotada'
@ _nAux,295 MSGET _cSistem Size 60,07 When .F. OF oPrincipal PIXEL

_nAux+=13
@ _nAux,235 MSGET _nFatCli Picture '@E 999.99' Size 25,07 When .F. OF oPrincipal PIXEL
@ _nAux,267 SAY STR0050 OF oPrincipal PIXEL //'%  Cliente'
@ _nAux,305 MSGET _oVlFatCli VAR _nVlFatCli Picture '@E 999,999.99' When .F. Size 40,07 OF oPrincipal PIXEL

_nAux+=13
@ _nAux,235 MSGET _nFatFra Picture '@E 999.99' Size 25,07 When .F. OF oPrincipal PIXEL
@ _nAux,267 SAY STR0051 OF oPrincipal PIXEL //'%  Franquia'
@ _nAux,305 MSGET _oVlFatFra VAR _nVlFatFra Picture '@E 999,999.99' When .F. Size 40,07 OF oPrincipal PIXEL

_nAux+=13
@ _nAux,235 MSGET _nFatMic Picture '@E 999.99' Size 25,07 When .F. OF oPrincipal PIXEL
@ _nAux,267 SAY STR0052 OF oPrincipal PIXEL //'%  Não Fatura'
@ _nAux,305 MSGET _oVlFatMic VAR _nVlFatMic Picture '@E 999,999.99' When .F. Size 40,07 OF oPrincipal PIXEL

CalcFecha()

ACTIVATE MSDIALOG oPrincipal CENTERED ON INIT EnchoiceBar(oPrincipal, {|| GravaFecha()}, {|| CloseFecha(oPrincipal)}, , aButtons)

RestArea(_aAreaLHPv)

Return(Nil)
*--------------------------------------------------------------------------------------

*--------------------------------------------------------------------------------------
Static Function CalcFecha()
*--------------------------------------------------------------------------------------

// Calculo Valor Sub-Total Despesas
If _nQuem == "2"
	_nVlSubTot:= _nVlTtDesM2 + _nVlPassag + _nVlHospd
Else
	_nVlSubTot:= _nVlTotDesp + _nVlPassag + _nVlHospd
EndIf
_oVlSubTot:Refresh()

// Calculo Valor Total a Faturar
If _nQuem == "2"
	_nVlTotFat:= 0
Else
	_nVlTotFat:= (_nVlSubTot / _nAlTOTAL) * 100
EndIf
_oVlTotFat:Refresh()

// Calculo Valor Iss
_nVlIss:= (_nVlTotFat * _nAlISS) / 100
_oVlIss:Refresh()

// Calculo Valor Cofins
_nVlCofins:= (_nVlTotFat * _nAlCOFINS) / 100
_oVlCofins:Refresh()

// Calculo Valor Pis
_nVlPis:= (_nVlTotFat * _nAlPIS) / 100
_oVlPis:Refresh()

// Calculo do valor a Faturar Rateado
_nVlFatCli:= (_nVlTotFat*_nFatCli) / 100
_oVlFatCli:Refresh()

_nVlFatFra:= (_nVlTotFat*_nFatFra) / 100
_oVlFatFra:Refresh()

If _nQuem == "2"
	_nVlFatMic:= 0
Else
	_nVlFatMic:= (_nVlSubTot*_nFatMic) / 100
EndIf
_oVlFatMic:Refresh()

Return(.T.)
*--------------------------------------------------------------------------------------


*--------------------------------------------------------------------------------------
Static Function VCC()
*--------------------------------------------------------------------------------------
Local _lVCC := .T.
Local cContab:=GetMV('MV_MCONTAB')

If !Empty(_cCC)

	If cContab == 'CON'
		DbSelectArea('SI3')
		DbSetOrder(1)
		If !MsSeek(xFilial('SI3') + _cCC)
			MsgInfo(STR0053, STR0002) //'Centro de Custo não Cadastrado !'###'Atenção'
			_lVCC := .F.
		EndIf
	ElseIf cContab == 'CTB'
		DbSelectArea('CTT')
		DbSetOrder(1)
		If !MsSeek(xFilial('CTT') + _cCC)
			MsgInfo(STR0053, STR0002) //'Centro de Custo não Cadastrado !'###'Atenção'
			_lVCC := .F.
		EndIf
	EndIf
EndIf

Return(_lVCC)
*--------------------------------------------------------------------------------------

*--------------------------------------------------------------------------------------
Static Function GravaFecha()
*--------------------------------------------------------------------------------------
Local _cPerg1,_cFlagLHQ:= 'C'

If !lGravaFecha
	MsgInfo(STR0003, STR0002) //'Prestação de Contas, está Encerrada !'###'Atenção'
	Return
EndIf

_cPerg1 := STR0025 //"Deseja Finalizar o Processo de Fechamento, caso Contrário Ficará em Aberto, com a Legenda Vermelha ?"
If MsgYESNO(_cPerg1, STR0026) //"Atenção"
	If Empty(LHQ->LHQ_Saida)
		_cFlagLHQ:= 'B'
	Else
		_cFlagLHQ:= 'Z'
	EndIf
EndIf

If !DadosFOk()
	Return
EndIf

CalcFecha()

Begin Transaction

DbSelectArea('LHP')
RecLock('LHP', .F.)
LHP->LHP_FatCLi := _nFatCli
LHP->LHP_FatFra := _nFatFra
LHP->LHP_FatMic := _nFatMic
LHP->LHP_VLPASS := _nVlPassag
LHP->LHP_VLHOSP := _nVlHospd
LHP->LHP_Flag	:= _cFlagLHQ
LHP->LHP_Flag1	:= _cFlagLHQ
MsUnLock('LHP')

DbSelectArea('LHQ')
RecLock('LHQ',.F.)
LHQ->LHQ_Flag	:= _cFlagLHQ
LHQ->LHQ_FatCLi := _nFatCli
LHQ->LHQ_FatFra := _nFatFra
LHQ->LHQ_FatMic := _nFatMic
LHQ->LHQ_VlTFat := _nVlTotFat
LHQ->LHQ_VlFatC := _nVlFatCli
LHQ->LHQ_VlFatF := _nVlFatFra
LHQ->LHQ_VlFatM := _nVlFatMic
LHQ->LHQ_VlISS	:= _nVlIss
LHQ->LHQ_VlCOFI := _nVlCofins
LHQ->LHQ_VlPIS	:= _nVlPis
LHQ->LHQ_AlISS	:= _nAlIss
LHQ->LHQ_AlCOFI := _nAlCofins
LHQ->LHQ_AlPIS	:= _nAlPis
LHQ->LHQ_DFECHA := dDatabase
MsUnLock('LHQ')

End Transaction

RestArea(_aAreaLHPv)
oPrincipal:End()

Return
*--------------------------------------------------------------------------------------

*--------------------------------------------------------------------------------------
Static Function DadosFOk()
*--------------------------------------------------------------------------------------
Local _lDadosFOk := .T.

/*/
If _lDadosFOk .and. Empty(_dEmiss)
	MsgInfo('Data de emissão deve ser Informada !', 'Atenção')
	_lDadosFOk := .F.
EndIf

If _lDadosFOk .and. !aCols[n][10] .and. Empty(aCols[n][3]) // Cod Despesa
	MsgInfo('Código da Despesa não Informado !', 'Atenção')
	_lDadosFOk := .F.
EndIf
/*/
Return(_lDadosFOk)
*--------------------------------------------------------------------------------------

*--------------------------------------------------------------------------------------
Static Function CloseFecha(oPrincipal)
*--------------------------------------------------------------------------------------

RestArea(_aAreaLHPv)
oPrincipal:End()

Return
 