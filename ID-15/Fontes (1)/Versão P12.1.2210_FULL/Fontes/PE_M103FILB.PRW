
/*/{Protheus.doc} M103FILB
Retorna o Filtro de Browse para a Rotina MATA103
@author izac.ciszevski
@since 01/06/2017
@Project    MAN0000007423041_EF_003
/*/
User Function M103FILB()

    Local cFiltro := ""
    
    cFiltro := U_F1000302() //Filtro por Doc. Entrada

Return cFiltro