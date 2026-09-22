#Include 'Protheus.ch'

/*{Protheus.doc} M521DNFS
Ponto de entrada no termino de exclusão da nota fiscal.
 
@author Marcos Furtado
@since  03/01/2019
@return Nil  
@project -
*/

User Function M521DNFS() 
Local aArea	:= GetArea()                       
U_F0703403(.F.) // Rotina de Exclusão do Pedido
RestArea(aArea)
Return

