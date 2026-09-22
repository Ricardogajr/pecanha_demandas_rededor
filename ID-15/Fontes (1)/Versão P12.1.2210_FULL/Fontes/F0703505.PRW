#include "totvs.ch"

#define F24CONSUMO    1
#define F24COMPRA     2
#define F24P12TOFRONT 1
#define F24FRONTTOP12 2

/*{Protheus.doc} F0703505
Função responsável para tratamento da devolução de compras no consignado especifico 
@author Alex Sandro Valario
@since 19/05/2017
@version 1.0
@Project MAN0000007423041_EF_035
@return LOGICO
*/

User Function F0703505(lInclui)
    Local aAreaSD1 := {}

    If ! Empty(SD2->( D2_NFORI + D2_SERIORI ))
        Return
    EndIf
    
    aAreaSD1 := SD1->(GetArea('SD1'))
    SD1->(DbSetOrder(1))
    If SD1->(DbSeek(xFilial('SD1') + SD2->(D2_NFORI + D2_SERIORI + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEMORI) )) .and. SD1->D1_XCONSIG == "1"
        If lInclui
            SD2->(U_F0703504(D2_LOCAL, D2_COD, D2_CLIENTE, D2_LOJA , D2_TOTAL , D2_QUANT ,"S")) //atualização consignado especifico realizando saida
        Else    
            SD2->(U_F0703504(D2_LOCAL, D2_COD, D2_CLIENTE, D2_LOJA , D2_TOTAL , D2_QUANT ,"E")) //atualização consignado especifico realizando entrada
        EndIf
    EndIf
	RestArea(aAreaSD1)
Return .T.