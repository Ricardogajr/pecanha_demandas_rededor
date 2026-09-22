#Include 'Protheus.ch'

/*{Protheus.doc} F0100330()
Retorna o nome do funcionário
@author     Nairan Alves Silva	
@since      16/05/2017
@param      cCodRH3, caracter, código da solicitação
@param		cCodMat, caracter, código da matricula
@param		cTipo,   caracter, Tipo da solicitação (padrão)
@return     cNome, nome do solicitante
@project    MAN00000463701_EF_003
*/
User Function F0100330(cCodRH3, cCodMat, cTipo)
	
	Local aAreaSRA := SRA->(GetArea())
	Local aAreaRH3 := RH3->(GetArea())
	Local cNome    := ""
	
	If AllTrim(RH3->RH3_XTPCTM) == '004' .Or. Empty(RH3->RH3_MAT)
		cNome := POSICIONE("SRA", 1, RH3->RH3_FILINI + RH3->RH3_MATINI, "RA_NOME")
	Else
		cNome := GetNmRH3(RH3->RH3_CODIGO, RH3->RH3_MAT, RH3->RH3_TIPO)
	EndIf

	RestArea(aAreaSRA)
	RestArea(aAreaRH3)

Return cNome

/*{Protheus.doc} F0100331()
Retorna a Matrícula do Funcionário
@author     Nairan Alves Silva	
@since      28/03/2018
@param      cCodRH3, caracter, código da solicitação
@param		cCodMat, caracter, código da matricula
@param		cTipo,   caracter, Tipo da solicitação (padrão)
@return     cNome, nome do solicitante
@project    MAN00000463701_EF_003
*/
User Function F0100331(cMat, cMatApr)
	
	Local cRet    := ""
	
	If Empty(cMat)
		cRet := cMatApr
	Else
		cRet := cMat
	EndIf

Return cRet
