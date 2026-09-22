#INCLUDE "Protheus.ch"
 
User Function F0201405()

	Local aLegenda := {}
	
	Private cCadastro := "Atualização de Status"
	
	AAdd(aLegenda, {"BR_VERDE"    , "Incluido" })
	AAdd(aLegenda, {"BR_AZUL"     , "Alteração"})
	AAdd(aLegenda, {"BR_VERMELHO" , "Exclusão" })
	AAdd(aLegenda, {"BR_PRETO"    , "Importado"})
	
	BrwLegenda(cCadastro, "Legenda", aLegenda)
	
Return Nil
