#Include 'Protheus.ch'

/*
{Protheus.doc} MT410CPY()
Ponto de Entrada na cópia do PV.
@Author		Paulo Krüger
@Since      09/11/2017
@Version    P12.7
@Project    MAN00000463301
@Return		Nil      
*/

User Function MT410CPY()
    Local aArea		:=	GetArea()
 
	U_F0703204() //Limpa conteúdo de campos específicos na cópia de pedidos de venda.
 
    RestArea(aArea)
Return Nil