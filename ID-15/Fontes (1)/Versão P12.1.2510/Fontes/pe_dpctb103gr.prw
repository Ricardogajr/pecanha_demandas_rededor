#include "Totvs.ch"

/*/{Protheus.doc} DPCTB103GR

Valida pós execução a gravação dos lançamentos
Ponto de entrada que valida se registro foi gravado corretamente 

@type function
@version  
@author fabio.cazarini
@since 25/06/2021
@return return_type, return_description
/*/
User Function DPCTB103GR()
    Local nOpc      := paramixb[1]
    Local dDatalanc := paramixb[2]
    Local cLote     := paramixb[3]
    Local cSubLote  := paramixb[4]
    Local cDoc      := paramixb[5]
    Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual
    
    //Verifica se está habilitada a integração neste grupo de empresas
    If lGrpHblt
        If (nOpc == 4 .Or. nOpc == 5)                       // se for alteração ou exclusao, envia e-mail de notificacao
            U_F2000530(nOpc, dDatalanc, cLote, cSubLote, cDoc)  // envia e-mail de notificacao
        Endif
    EndIf      

Return NIL
