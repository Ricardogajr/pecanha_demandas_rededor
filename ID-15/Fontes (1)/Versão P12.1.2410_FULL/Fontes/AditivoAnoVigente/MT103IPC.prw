#Include 'Protheus.ch'
/*
//=============================================================================================\\
// Programa   MT103IPC   | Autor  Diego Fraidemberge Mariano              | Data    04/09/24   ||
//=============================================================================================||
//Desc.     | Ponto de Entrada utilizado para garregar automaticamente os valores de multa e   ||
//          | juros da tabela SC7 no Pedido de Compras para a Nota de Entrada no momento do    ||
//          | Vínculo do pedido de compras com a nota de entrada                               ||
||Parametros  | PARAMIXB[1] - Contém informações sobre os campos da SD1.                       ||
                                                                                               ||
||Ret Nil                                                                                      ||
//=============================================================================================//
*/
User Function MT103IPC()
Local fD1Jur    := GdFieldPos('D1_XJURMUL') 
Local fD1Mult    := GdFieldPos('D1_XMULTA') 
Local nLine     := PARAMIXB[1] 

aCols[nLine,fD1Jur]    := SC7->C7_XJURMUL
aCols[nLine,fD1Mult]   := SC7->C7_XMULTA


Return(Nil)
