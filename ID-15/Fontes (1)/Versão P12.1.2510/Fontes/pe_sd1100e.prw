#Include 'Protheus.ch'

/*{Protheus.doc} SD1100E
O ponto de entrada no momento da exclusão do item da nota
@author Alex Sandro
@since 19/05/2017
@version 1.0
@Project MAN0000007423041_EF_035
*/

User Function SD1100E()
    
    SD1->(U_F0703504(D1_LOCAL, D1_COD, D1_FORNECE, D1_LOJA , D1_TOTAL , D1_QUANT ,"S", D1_XCONSIG)) //atualização consignado especifico

Return
