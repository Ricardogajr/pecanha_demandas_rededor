#INCLUDE "Protheus.ch"
#INCLUDE "TbiConn.ch"

///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROJETO CONECTA REDE DOR    |  MODULO | SIGAMDT                             |//
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | AMS00011 | AUTOR | Paulo Dias               | DATA | 09/10/2018 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO  | Função: Schedule para Rotina de Blackout                       |//
//+-----------------------------------------------------------------------------+//
//| OBSERVACAO | Rotina escreve no Arquivo Log do AppServer "Compila"           |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////

User Function AMS00011()

Local aArea    := GetArea()
Local nPosU013 := 0
Local cAliTNY  := ""
Local cAliSR8  := ""
Local cEmp     := "01"
Local cFil     := "01310011"

RPCSetType(3)
If RpcSetEnv(cEmp,cFil)

    cAliTNY := GetNextAlias()
    cAliSR8 := GetNextAlias()
    ConOut( " Entrando no Schedule da rotina AMS00011() ") 

    nPosU013 := U_DORBLK(cFilAnt,'U013') // implementada no fonte DOR007RH()

    If  nPosU013 > 0 // Blackout
   
        ConOut( "Rotina executada em " + cValToChar(DATE()) + ", às " + TIME() +  "- Período de Blackout da Folha.")
        
    Else // Fora do período de Blackout
    
        ConOut( "Faz update na SR8/TNY em " + cValToChar(DATE()) + ", às " + TIME() )
    
        cQryTNY := " SELECT R_E_C_N_O_ RECNO                         "
        cQryTNY += " FROM " + RetSqlName("TNY") + " TNY              "
        cQryTNY += " WHERE TNY.D_E_L_E_T_ = ' '                      "
        cQryTNY += " AND TNY_XDTBLK <> ' ' AND TNY_DTALTA = ' '      "
        cQryTNY += " ORDER BY RECNO                                  "

        cQryTNY := ChangeQuery(cQryTNY)

        If Select(cAliTNY) > 0
             DbSelectArea(cAliTNY)
            (cAliTNY)->(DbCloseArea())  
        Endif

        dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryTNY),cAliTNY, .F., .T.)
	    dbSelectArea(cAliTNY)

        While (cAliTNY)->(!Eof())
           dbSelectArea("TNY")
           dbSetOrder(1)
           dbGoTo((cAliTNY)->(RECNO))

           RecLock("TNY",.F.)
            TNY->TNY_DTSAID := TNY->TNY_XDTSAI
            TNY->TNY_DTALTA := TNY->TNY_XDALT
            TNY->TNY_QTDIAS := TNY->TNY_XQTDIA
            TNY->TNY_CODAFA := TNY->TNY_XCODAF
            TNY->TNY_TPEFD  := TNY->TNY_XTPEFD

           TNY->(MsUnlock())

        (cAliTNY)->(DbSkip())
        EndDo

        cQrySR8 := " SELECT R_E_C_N_O_ RECNO  "
        cQrySR8 += " FROM " + RetSqlName("SR8") + " SR8  "
        cQrySR8 += " WHERE SR8.D_E_L_E_T_ = ' '  "
        cQrySR8 += " AND ((R8_XDTINI <>  ' ' AND R8_XTPEFD <>  ' ' AND R8_DATAINI = ' '    AND R8_TPEFD   = ' ' AND R8_STATUS = ' ' )   "
        cQrySR8 += " OR (R8_XDTINI <>  ' ' AND R8_XTPEFD <>  ' '  AND R8_DATAFIM = ' ' AND R8_XDTFIM <> ' ' AND  R8_DATAINI <> ' ' AND R8_STATUS = ' '   ) ) "
        cQrySR8 += " ORDER BY RECNO  "                                                                               "
    
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

            SR8->R8_DATAINI := SR8->R8_XDTINI
            SR8->R8_DATAFIM := SR8->R8_XDTFIM
            SR8->R8_DURACAO := SR8->R8_XDURAC
            SR8->R8_TPEFD   := SR8->R8_XTPEFD

            SR8->(MsUnlock())
       
        (cAliSR8)->(dbSkip())
        EndDo

    EndIf

Else 
    Conout(" AMS00011.prw: falha ao iniciar o ambiente ")

EndIf


ConOut( "Saiu do Schedule")

RpcClearEnv()

RestArea(aArea)

Return