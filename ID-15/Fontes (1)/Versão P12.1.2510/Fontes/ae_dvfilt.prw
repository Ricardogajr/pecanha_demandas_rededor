#Include 'Protheus.ch'

/*
{Protheus.doc}  AE_DVFILT()
Ponto de entrada para possibilitar o filtro de despesas de vigem no Browse da rotina de Prestação de contas
@Author  Ramon Teodoro e Silva	
@Since   27/06/2019       
@Version P12.7
*/

User Function AE_DVFILT()

Local aArea     := GetArea()
Local cRet      := ""
Local cLogin    := Alltrim(Substr(UsrRetName(__cUserID),1,TamSX3("LHT_LOGIN")[1]))
Local cCodMat   := Posicione("LHT", 4, xFilial("LHT") + cLogin, "LHT_CODMAT")
Local cAprov    := Posicione("LHT", 4, xFilial("LHT") + cLogin, "LHT_FLAGAP+LHT_APFIN")
Local lAcessAll := __cUserID $ Alltrim(SuperGetMV('FS_ACESCDV', .F., ""))
Local cNomeUser := AllTrim(SubStr(cUsuario,07,15))  

If !lAcessAll

	If !Empty(__cUserID)
		cRet += "LHQ_USRINC = '" + __cUserID + "' " 
	EndIf

	If !Empty(cNomeUser)
		cRet += IIF(Len(cRet)>0," OR LHQ_SOLPOR = '" + cNomeUser + "' ", " LHQ_SOLPOR = '" + cNomeUser + "' "  )		
	EndIf

	If !Empty(cCodMat)
		cRet += IIF(Len(cRet)>0, " OR LHQ_SUPIMD = '" + cCodMat + "' OR LHQ_FUNC = '" + cCodMat + "'",  " LHQ_SUPIMD = '" + cCodMat + "' OR LHQ_FUNC = '" + cCodMat + "'" )
	EndIf	

//	If Val(Substr(cAprov,1,1)) == 1 .Or. Val(Substr(cAprov,2,1)) == 1
		//cRet := "LHQ_USRINC = '" + __cUserID + "' OR LHQ_SOLPOR = '" + cNomeUser + "' OR LHQ_SUPIMD = '" + cCodMat + "' OR LHQ_FUNC = '" + cCodMat + "'"  
//	Else
//		cRet := "LHQ_USRINC = '" + __cUserID + "' OR LHQ_SOLPOR = '" + cNomeUser + "' OR LHQ_FUNC = " + cCodMat + "'"
//	EndIf

EndIf

RestArea(aArea)

Return cRet

