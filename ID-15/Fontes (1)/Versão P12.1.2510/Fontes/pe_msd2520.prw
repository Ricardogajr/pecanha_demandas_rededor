#Include 'Protheus.ch'

/*{Protheus.doc} MSD2520
O ponto de entrada no momento da exclusão do item da nota de saida
@author Alex Sandro
@since 19/05/2017
@version 1.0
@Project MAN0000007423041_EF_035
*/
User Function MSD2520()

    U_F0703505(.F.) // tratamento de consignado para devolução de compras
    U_F0703403(.T.) // adiciona o codigo pedido em array para ser usado no pe MS520DEL

Return

