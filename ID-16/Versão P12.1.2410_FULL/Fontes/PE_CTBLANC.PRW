#include "Totvs.ch"

/*/{Protheus.doc} CTBLANC

Grava Lançamento Contábil do Folder
O ponto de entrada CTBLANC efetua a Gravação Lançamento Contábil do Folder

@type function
@version  
@author fabio.cazarini
@since 25/06/2021
@return return_type, return_description
/*/
User Function CTBLANC()
    Local dDatalanc := paramixb[1]
    Local cLote     := paramixb[2]
    Local cSubLote  := paramixb[3]
    Local cDoc      := paramixb[4]
    Local cLinha    := paramixb[5]
    Local cTipo     := paramixb[6]
    Local cMoeda    := paramixb[7]
    Local cHistPad  := paramixb[8]
    Local cDebito   := paramixb[9]
    Local cCredito  := paramixb[10]
    Local cCustoDeb := paramixb[11]
    Local cCustoCrd := paramixb[12]
    Local cItemDeb  := paramixb[13]
    Local cItemCrd  := paramixb[14]
    Local cClVlDeb  := paramixb[15]
    Local cClVlCrd  := paramixb[16]
    Local nValor    := paramixb[17]
    Local cTexto    := paramixb[18]
    Local cTpSald   := paramixb[19]
    Local cSeqLan   := paramixb[20]
    Local nOpc      := paramixb[21]
    Local aCols     := paramixb[22]
    Local cDCD      := paramixb[23]
    Local cDCC      := paramixb[24]
    Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual
    
    //Verifica se está habilitada a integração neste grupo de empresas
    If lGrpHblt
        If (nOpc == 4 .Or. nOpc == 5)                       // se for alteração ou exclusao, envia e-mail de notificacao
            U_F2000530(nOpc, dDatalanc, cLote, cSubLote, cDoc)  // envia e-mail de notificacao
        Endif
    EndIf        

Return NIL
