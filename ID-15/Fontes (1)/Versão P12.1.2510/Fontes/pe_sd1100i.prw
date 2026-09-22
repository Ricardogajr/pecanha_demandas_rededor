#Include 'Protheus.ch'

/*{Protheus.doc} SD1100I
O ponto de entrada no momento da inclusão do item da nota
@author Alex Sandro
@since 19/05/2017
@version 1.0
@Project MAN0000007423041_EF_035
*/
User Function SD1100I() 

    SD1->(U_F0703504(D1_LOCAL, D1_COD, D1_FORNECE, D1_LOJA , D1_TOTAL , D1_QUANT ,"E", D1_XCONSIG)) //atualização consignado especifico
    SD1->(U_F0104101(D1_XPRIVEN)) //atualização campo F1_XDTVNF
 
Return
