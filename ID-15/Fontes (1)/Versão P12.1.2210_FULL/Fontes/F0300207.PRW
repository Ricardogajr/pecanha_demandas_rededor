#INCLUDE "Protheus.ch"
/*{Protheus.doc} F0300207()
Cria legenda

@author   Henrique Madureira
@since    05/08/2016
@version  P12.7
@Project  MAN0000004_EF_002

*/
User Function F0300207()
	Local aLegenda := {}
	
	Private cCadastro := "Legenda"
	
	AAdd(aLegenda,{"BR_VERDE"    ,"Iniciado" })
	AAdd(aLegenda,{"BR_AMARELO"  ,"Suspenso" })
	AAdd(aLegenda,{"BR_VERMELHO" ,"Cancelado" })
	AAdd(aLegenda,{"BR_AZUL"     ,"Concluido" })
	
	BrwLegenda(cCadastro, "Legenda", aLegenda)

Return