#INCLUDE "Historico.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Historico ºAutor  ³Willy               º Data ³  10/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Mostra o historico da solicitação							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CDV - Controle de Despesas de Viagens						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function Historico()
Local oDlg
Local _aArea 		:= GetArea()
Local oBold
Local _oSolPor
Local _oAprov
Local _oSolFin 
Local _oAprovF
Local oBtnFechar

DEFINE MSDIALOG oDlg FROM  000,000 TO 148,585 TITLE STR0001 PIXEL //"Histórico"
dbSelectArea('LHP')

_cSolPor := LHP->LHP_SolPor 
_dDTSOL1 := LHP->LHP_DTSOL1
_cHrSolP := LHP->LHP_HrSolP

_cAprov  := LHP->LHP_Aprov 
_dDTAPR1 := LHP->LHP_DTAPR1
_cHrApv1 := LHP->LHP_HrApv1

_cSolFin := LHP->LHP_SolFin
_dDTSOL2 := LHP->LHP_DTSOL2
_cHrSolF := LHP->LHP_HrSolF

_cAprovF := LHP->LHP_AprovF
_dDTAPR2 := LHP->LHP_DTAPR2
_cHrApv2 := LHP->LHP_HrApv2
                           
_nRow:=0

@003,003 To 61,290 OF oDlg PIXEL

//Solicitacao
DEFINE FONT oBOLD Name "ARIAL" SIZE 0, -11 BOLD 

_nRow+=10
@ _nRow,007 SAY STR0002 OF oDlg PIXEL FONT oBold COLOR CLR_HBLUE //"Solicitado por"
@ _nRow,080 MSGET _oSolPor Var _cSolPor Picture '@!' Size 135,07 OF oDlg PIXEL FONT oBold COLOR CLR_HRED
_oSolPor:lReadOnly := .T.

@ _nRow,220 SAY STR0004 OF oDlg PIXEL FONT oBold COLOR CLR_HBLUE //" em "
@ _nRow,233 SAY _dDTSOL1 OF oDlg PIXEL FONT oBold COLOR CLR_HRED

@ _nRow,259 SAY STR0005 OF oDlg PIXEL FONT oBold COLOR CLR_HBLUE //"às"
@ _nRow,269 SAY _cHrSolP OF oDlg PIXEL FONT oBold COLOR CLR_HRED

//Aprovacao 1
_nRow+=12
If LHP->LHP_Flag == 'P'
	@ _nRow,007 SAY STR0006 OF oDlg PIXEL FONT oBold COLOR CLR_HRED //"Reprovado por"
Else
	@ _nRow,007 SAY STR0007 OF oDlg PIXEL FONT oBold COLOR CLR_HBLUE //"Aprovado por "
Endif

//Procurar Aprovador 1
DbSelectArea("LHT")
LHT->(DbSetOrder(1))
If (DbSeek(xFilial() + _cAprov))
	_cAprov := _cAprov + " - " + LHT->LHT_NOME
EndIf

@ _nRow,080 MSGET _oAprov VAR _cAprov Picture '@!' Size 135,07 When .F. OF oDlg PIXEL FONT oBold COLOR CLR_HRED
_oAprov:lReadOnly := .T.

@ _nRow,220 SAY STR0008 OF oDlg PIXEL FONT oBold COLOR CLR_HBLUE //"em"
@ _nRow,233 SAY _dDTAPR1 OF oDlg PIXEL FONT oBold COLOR CLR_HRED
		
@ _nRow,259 SAY STR0005 OF oDlg PIXEL FONT oBold COLOR CLR_HBLUE //"às"
@ _nRow,269 SAY _cHrApv1 OF oDlg PIXEL FONT oBold COLOR CLR_HRED

//Solicitacao Depto Viagem
_nRow+=12
@ _nRow,007 SAY STR0009 OF oDlg PIXEL FONT oBold COLOR CLR_HBLUE //"Solicitante Financeiro"
@ _nRow,080 MSGET _oSolFin VAR _cSolFin Picture '@!' Size 135,07 OF oDlg PIXEL FONT oBold COLOR CLR_HRED
_oSolFin:lReadOnly := .T.

@ _nRow,220 SAY STR0008 OF oDlg PIXEL FONT oBold COLOR CLR_HBLUE //"em"
@ _nRow,233 SAY _dDTSOL2 OF oDlg PIXEL FONT oBold COLOR CLR_HRED
		
@ _nRow,259 SAY STR0005 OF oDlg PIXEL FONT oBold COLOR CLR_HBLUE //"às"
@ _nRow,269 SAY _cHrSolF OF oDlg PIXEL FONT oBold COLOR CLR_HRED

//Aprovacao Depto Viagem
_nRow+=12
If LHP->LHP_Flag1 == 'P'
	@ _nRow,007 SAY STR0010 OF oDlg PIXEL FONT oBold COLOR CLR_HBLUE //"Reprovador Financeiro"
Else                                                                                  
	@ _nRow,007 SAY STR0011 OF oDlg PIXEL FONT oBold COLOR CLR_HBLUE //"Aprovador Financeiro"
Endif

//Procurar Aprovador 1
DbSelectArea("LHT")
LHT->(DbSetOrder(1))
If (DbSeek(xFilial() + _cAprovF))
	_cAprovF  := _cAprovF  + " - " + LHT->LHT_NOME
EndIf

@ _nRow,080 MSGET _oAprovF VAR _cAprovF Picture '@!' Size 135,07 OF oDlg PIXEL FONT oBold COLOR CLR_HRED
_oAprovF:lReadOnly := .T.

@ _nRow,220 SAY STR0008  OF oDlg PIXEL FONT oBold COLOR CLR_HBLUE //"em"
@ _nRow,233 SAY _dDTAPR2 OF oDlg PIXEL FONT oBold COLOR CLR_HRED
		
@ _nRow,259 SAY STR0005 OF oDlg PIXEL FONT oBold COLOR CLR_HBLUE //"às"
@ _nRow,269 SAY _cHrApv2 OF oDlg PIXEL FONT oBold COLOR CLR_HRED

_nRow+=17
@ _nRow,251 BUTTON oBtnFechar PROMPT STR0003 SIZE 40,12 ACTION (oDlg:End()) OF oDlg PIXEL //"Fechar"

ACTIVATE MSDIALOG oDlg CENTERED

RestArea(_aArea)

Return
