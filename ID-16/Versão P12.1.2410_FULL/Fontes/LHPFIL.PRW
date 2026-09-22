#Include 'Protheus.ch'

/*
{Protheus.doc}  LHPFIL()
Ponto de entrada para possibilitar o filtro de despesas de vigem no Browse da rotina de Solicitação de viagem
@Author  Ramon Teodoro e Silva	
@Since   02/08/2019       
@Version P12.7
*/

User Function LHPFIL()

Local aArea     := GetArea()
Local cRet      := ""
Local cLogin    := Alltrim(Substr(UsrRetName(__cUserID),1,TamSX3("LHT_LOGIN")[1]))
Local cCodMat   := Posicione("LHT", 4, xFilial("LHT") + cLogin, "LHT_CODMAT")
//Local cAprov    := Posicione("LHT", 4, xFilial("LHT") + cLogin, "LHT_FLAGAP+LHT_APFIN")
Local lAcessAll := __cUserID $ Alltrim(SuperGetMV('FS_ACESCDV', .F., ""))
Local cNomeUser := AllTrim(SubStr(cUsuario,07,15))  

If !lAcessAll

	If !Empty(__cUserID)
		cRet += "LHP_XUSINC = '" + __cUserID + "'"
	EndIf

	If !Empty(cNomeUser)		
		cRet += IIF(Len(cRet)>0, " .OR. LHP_SOLPOR = '" + cNomeUser + "'", "LHP_SOLPOR = '" + cNomeUser + "'")
	EndIf

	If !Empty(cCodMat)
		cRet += IIF(Len(cRet)>0, " .OR. LHP_SUPIMD = '" + cCodMat + "' .OR. LHP_FUNC = '" + cCodMat + "'", "LHP_SUPIMD = '" + cCodMat + "'  .OR. LHP_FUNC = '" + cCodMat + "'") 
	EndIf
	//cRet := "LHP_XUSINC = '" + __cUserID + "' .OR. LHP_SOLPOR = '" + cNomeUser + "' .OR. LHP_SUPIMD = '" + cCodMat + "' .OR. LHP_FUNC = '" + cCodMat + "'"

EndIf

RestArea(aArea)

Return cRet

