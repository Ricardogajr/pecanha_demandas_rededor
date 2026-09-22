#INCLUDE 'PROTHEUS.CH'
#INCLUDE  'TBICONN.CH'

// ------------------------------------------------------------------
// {Protheus.doc} FINA580()
// Assunto     Inclusão de horário na liberação de título manual
// @Author     Paulo Dias
// @Since      17/02/2020
// @Version    P12.1.17
// @ticket     DOR07141920
// ------------------------------------------------------------------

User Function FINA580()

Local cTime := Time()

DbSelectArea("SE2")
Reclock("SE2",.F.)
SE2->E2_XHORLIB := cTime
MsUnlock()

Return