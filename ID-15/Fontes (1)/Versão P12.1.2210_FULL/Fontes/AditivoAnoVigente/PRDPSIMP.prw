#Include "Protheus.ch"
/*/{Protheus.doc} PRDPSIMP
Filtra os produtos genéricos só para filiais do Simplificado.
@type function
@version P12 
@author Ricardo Junior
@since 12/9/2024
@return variant, Nulo
/*/
User Function PRDPSIMP(cProd)

	Local lRet      := .T.
	Local cProds    := AllTrim(SuperGetMV("MV_XPRDEST",,"")) + "|"+ AllTrim(SuperGetMV("MV_XPRDNES",,"")) + "|"+ AllTrim(SuperGetMV("MV_XPRDGPE",,""))
	Local lFilSimp  := U_VALSIMP(cFilAnt)
	Local cTipoSP := ""

	if !lFilSimp
		if Alltrim(cProd) $ cProds
			lRet := .F.
		endif
	endif

Return lRet
