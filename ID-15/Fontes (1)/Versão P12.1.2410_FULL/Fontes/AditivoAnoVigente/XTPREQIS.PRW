#INCLUDE 'TOPCONN.CH'
#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#Include 'TOTVS.ch'
/*=====================================================================================================================================*
Fonte:      XTPREQIS 
Função:     Ponto de Entrada executado na rotina de Inclusão de Medição:
			Permite alterar o campo CND_XTPREQ caso o CN9_TPCTO esteja no parametro EZ_XTIPO, sendo um contrato de serviço.
Parametro: cContra, recebe M->CND_FILCTR+M->CND_CONTRA+M->CND_REVISA
Analista:   Diego Fraidemberge Mariano - EZ4
Data:       25/09/2024
Empresa:    Rede D'Or
*=====================================================================================================================================*/
User Function XTPREQIS(cContra)
Local lRet := .F.
Local cTpServ := ""
Local eZ_ConSer := SuperGetMV("EZ_XCONSER", .F.)

DbSelectArea("CN9")
DbSetOrder(1)
DbGoTop()
If !Empty(cContra) .AND. cContra <> ""
    If CN9->(DBSEEK(cContra))
        cTpServ := CN9->CN9_TPCTO
        If cTpServ $ eZ_ConSer
            lRet := .T.   
        Else
            lRet := .F.
        EndIf
    EndIf
EndIf

Return lRet
