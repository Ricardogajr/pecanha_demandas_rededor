#include 'protheus.ch'

/*/{Protheus.doc} MTA110MNU
    Ponto de entrada para criação de botão em solicitaçoes de compras
    @type  Function
    @author Cesar Escobar
    @since 13/06/2017
    @version 1.0
    @return aRet,Array, Array com as informações do botão
    /*/
User Function FSPE0016()
    
    aAdd( aRotina , { "Desvincular solicitação" , "U_REDA004", 0,4,0,Nil } )
    //aAdd( aRotina , { "Re-integra Bionexo"      , "U_REDA007", 0,4,0,Nil } )

Return( .T. )