
/*/{Protheus.doc} FMigraCT2
Rotina responsável por migrar os dados de uma filial para outra na contabilidade.
@type function
@version P122410 
@author Ricardo Junior
@since 4/22/2026
@return variant, Nulo
/*/
User function FMigraCT2()

	Local aPergs   := {}
	Local nQuant   := 0
	Local nValor   := 0

	aAdd(aPergs, {1, "Qtde",  nQuant,  "@E 9,999",     "Positivo()", "", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Valor", nValor,  "@E 99,999.99", "Positivo()", "", ".T.", 80,  .F.})

	if parambox("")

    endif

Return
