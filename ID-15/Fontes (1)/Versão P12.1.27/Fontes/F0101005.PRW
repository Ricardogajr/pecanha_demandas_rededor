#Include 'Protheus.ch'

/*
{Protheus.doc} F0101005()
PE FA750BRW Para adicionar o botão recusa nas rotinas FINA750 
@Author     Tiago Paulo Silva
@Since      28/04/2016
@Version    P12.7
@Project    MAN00000462901_EF_010
@Return		aRotina, Vetor de Menu
*/
User Function F0101005(aRotina)

    DEFAULT aRotina := {}
        
    AAdd(aRotina, {'Recusar'        , "U_F010101A"             , 0, 3})
    AAdd(aRotina, {'Cancelar Recusa', 'U_F010101PCANCELARECUSA', 0, 3} )
    AAdd(aRotina, {'Hist. Recusa'   , 'U_F010101G'             , 0, 3})

Return aRotina