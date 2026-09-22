#INCLUDE 'PROTHEUS.CH'
#INCLUDE  'TBICONN.CH'

// ------------------------------------------------------------------
// {Protheus.doc} F580CAN()
// Assunto     Exclusão de horário no cancelamento da liberação de título
// @Author     Paulo Dias
// @Since      17/02/2020
// @Version    P12.1.17
// @ticket     DOR07141920
// ------------------------------------------------------------------

User Function F580CAN()

Local lGrvMov := .T.
Local cNum := SE2->E2_NUM

    DbSelectArea("SE2")
    Reclock("SE2",.F.)
    SE2->E2_XHORLIB := ""
    MsUnlock()
    

Return lGrvMov