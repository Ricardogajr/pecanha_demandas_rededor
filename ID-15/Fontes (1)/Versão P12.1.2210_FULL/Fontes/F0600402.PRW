#Include 'Protheus.ch'

/*{Protheus.doc} F0600402
Ajusta a Filial conforme configuracao padrao do SX2 Antiga RetFilSX2
@author     Eduardo Fernandes
@since      17/11/2016
@return     cRet
@version    P12.1.7
@project    MAN0000007423040_EF_004
*/
User Function F0600402(cFil,cAliasFil)

	Local cRet        := ""
	Local cFilAux     := ""
	Local aModoComp   := {}
	Local cLayoutEmp  := AllTrim(FWSM0Layout())
	Local nPosEmpresa := At("E",cLayoutEmp)
	Local nPosUnidade := At("U",cLayoutEmp)
	Local nPosFilial  := At("F",cLayoutEmp)
	Local nTamFilial  := Len(Alltrim(cLayoutEmp))
	Local lGestao     := ( "E" $ FWSM0Layout() .And. "U" $ FWSM0Layout() )	// Indica se usa Gestao Corporativa
	Local cEmp        := ""
	Local cUnid       := ""
	
	If lGestao
		cEmp    := Subs(cFil,nPosEmpresa, nPosUnidade-nPosEmpresa)
		cUnid   := Subs(cFil,nPosUnidade, nPosFilial-nPosUnidade)
		cFilAux := Subs(cFil,nPosFilial, nTamFilial)
		
		AAdd(aModoComp, FWModeAccess(cAliasFil,1,cEmpAnt) )
		AAdd(aModoComp, FWModeAccess(cAliasFil,2, cEmpAnt) )
		AAdd(aModoComp, FWModeAccess(cAliasFil,3, cEmpAnt) )
		
		//Empresa
		cRet := IIF(aModoComp[1] == "E", cEmp, Space(Len(cEmp)) )
		
		//Unid Negocio
		cRet += IIF(aModoComp[2] == "E", cUnid, Space(Len(cUnid)) )
		
		//Filial
		cRet += IIF(aModoComp[3] == "E", cFilAux, Space(Len(cFilAux)) )
		
	Else
		cRet := cFil
		
	Endif
	
Return cRet