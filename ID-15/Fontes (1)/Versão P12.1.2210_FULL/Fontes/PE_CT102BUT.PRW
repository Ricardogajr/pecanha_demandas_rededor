#include "Totvs.ch"

/*/{Protheus.doc} CT102BUT

Adiciona botões
Ponto de Entrada que permite adicionar novos botões para o array arotina, no menu da mbrowse em lançamentos contábeis automáticos.

@type function
@version  
@author fabio.cazarini
@since 24/06/2021
@return return_type, return_description
/*/
User Function CT102BUT()
    Local aRotina   := paramixb[1]
    Local aRet      := {}
    //Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual
    
    //Verifica se está habilitada a integração neste grupo de empresas
    //If lGrpHblt
        aAdd(aRet, {'Log de Integração XRT',"U_F2000520",   0 , 2    })
    //EndIf 

Return aRet
