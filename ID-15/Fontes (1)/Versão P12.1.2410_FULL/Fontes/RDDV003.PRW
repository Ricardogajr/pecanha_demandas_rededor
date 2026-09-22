//#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"

/*
|----------------------------------------------------------------------------|
|Programa  |RDDV001  |Autor  |TECNOSUM            | Data |  09/07/2016       |
|----------------------------------------------------------------------------|
|Descrição |Validação do campo C1_QUANT. Verifica se é múltiplo do campo     |
|          |BZ_QE(Quantidade por embalagem)                                  |
|----------------------------------------------------------------------------|
|Uso       |REDEDOR                                                          |						  
|----------------------------------------------------------------------------|
*/


User Function RDDV003(cProd)
	Local lRet := .t.
	Local nResult := 0

	DbSelectArea("SBZ")
	DbSetOrder(1)

	If DbSeek(xFilial("SBZ")+cProd)
		If SBZ->BZ_QE > 0 
			nResult := Mod(M->C1_QUANT,SBZ->BZ_QE)
			If nResult <> 0
				If l110Auto //Inicio Thais Paiva 9474856
					aadd(_aMsgErr,"A Quantidade do item deve ser múltiplo de "+cVAltochar(SBZ->BZ_QE)+", conforme a Quantidade por Embalagem informada no cadastro Indicador de Produtos!")
				Else //Fim Thais Paiva 9474856
					Aviso("A T E N Ç Ã O ! ! !", "A Quantidade do item deve ser múltiplo de " + ;
					cVAltochar(SBZ->BZ_QE) + ", conforme a Quantidade por Embalagem informada no cadastro Indicador de Produtos!",{"OK"})
				EndIf //Thais Paiva 9474856
				lRet := .f.
			Endif
		Endif
	Endif


Return lret

