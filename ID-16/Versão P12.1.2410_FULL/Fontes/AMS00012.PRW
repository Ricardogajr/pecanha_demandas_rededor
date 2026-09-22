#INCLUDE "Protheus.ch"
#INCLUDE "TbiConn.ch"

///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROJETO CONECTA REDE DOR    |  MODULO | SIGAMDT                             |//
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | TstSch | AUTOR | Paulo Dias                 | DATA | 21/12/2018 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO  | Função: Schedule para Rotina de Blackout _ Lic Maternidade     |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////

User Function AMS00012()

Local aArea    := GetArea()
Local nU013 := 0
Local cAliSR8  := ""
Local cEmp     := "01"
Local cFil     := "01310011"

RPCSetType(3)
If RpcSetEnv(cEmp,cFil)
    cAliSR8 := GetNextAlias()
    ConOut( " Entrando no Schedule da rotina AMS00012() ") 

    nU013 := U_DORLIMAT(cFilAnt,'U013') 

    If nU013 > 0 // Blackout

        ConOut( "Rotina executada em " + cValToChar(DATE()) + ", às " + TIME() +  "- Período de Blackout da Folha (LICENÇA MATERNIDADE).")
        
    Else // Fora do período de Blackout
        // busco o registro na SR8. Na TOF não será necessário uma vez que não impacta na folha.
        cQrySR8 := " SELECT R_E_C_N_O_ RECNO "
        cQrySR8 += " FROM " + RetSqlName("SR8") + " SR8 "
        cQrySR8 += " WHERE SR8.D_E_L_E_T_ = ' ' "
        cQrySR8 += " AND R8_TIPO = 'Q ' AND R8_XDTINI <>  ' ' AND R8_XTPEFD <>  ' ' AND R8_DATAINI = ' '    AND R8_TPEFD   = ' '   "
        cQrySR8 += " ORDER BY RECNO "
    
        cQrySR8 := ChangeQuery(cQrySR8)

        If Select(cAliSR8) > 0
            DbSelectArea(cAliSR8)
            (cAliSR8)->(DbCloseArea())
        EndIf

        dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQrySR8),cAliSR8, .F., .T.)
        dbSelectArea(cAliSR8)

        While (cAliSR8)->(!EOF())
            DbSelectArea("SR8")
            DbSetOrder(1)
            DbGoto((cAliSR8)->(RECNO))

            RecLock("SR8",.F.)

            SR8->R8_DATAINI := SR8->R8_XDTINI //data início de afastamento
            SR8->R8_DATAFIM := SR8->R8_XDTFIM // data retorno
            SR8->R8_DURACAO := SR8->R8_XDURAC // duração
            SR8->R8_TPEFD   := SR8->R8_XTPEFD // tipo do afastamento

            SR8->(MsUnlock())
       
        (cAliSR8)->(dbSkip())
        EndDo

    EndIf

Else 
    Conout(" AMS00012.prw: falha ao iniciar o ambiente ")

EndIf


ConOut( "Saiu do Schedule")

RpcClearEnv()

RestArea(aArea)

Return