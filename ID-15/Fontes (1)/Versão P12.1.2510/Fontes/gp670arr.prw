#Include "Protheus.Ch"
#Include "RwMake.ch"
#Include "FileIo.ch"
#Include "TopConn.ch" 


User Function GP670ARR()

    Local aArea := GetArea()
	Local aCposUsr := {}
	Local cTipo := GetNewPar("FS_XTITGPE","")
	
	Public __RETGP670 := "0"

    //Lucas Miranda de Aguiar - Melhoria
	If AllTrim(RC1->RC1_CODTIT) $ AllTrim(cTipo)
        aAdd( aCposUsr, { "E2_STATLIB", "03", NIL } )
        aAdd( aCposUsr, { "E2_DATALIB", Date(), NIL } )
        aAdd( aCposUsr, { "E2_USUALIB", RetCodUsr(), NIL } )
        aAdd( aCposUsr, { "E2_XHORLIB", Time(), NIL } )
        aAdd( aCposUsr, { "E2_PORTADO", "", NIL } )
		__RETGP670 := "1"
	EndIf

//Lucas Miranda de Aguiar - Melhoria multa e juros
    aAdd( aCposUsr, { "E2_MULTA", RC1->RC1_XMULTA, NIL } )
    aAdd( aCposUsr, { "E2_JUROS", RC1->RC1_XJUROS, NIL } )

RestArea(aArea)
Return aCposUsr
