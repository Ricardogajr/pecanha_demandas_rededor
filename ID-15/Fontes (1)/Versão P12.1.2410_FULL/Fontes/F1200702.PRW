#INCLUDE 'PROTHEUS.CH'

/*
{Protheus.doc} F1200702()
Padroniza leitura de parâmetros.
@Author			Paulo Krüger
@Since			15/08/2017
@Version		P12.7
@Project    	MAN0000007423046_EF_001
@Param			cParametro
*/
User Function F1200702(cParametro)
 
Local cRet		:= ''
Local cFracPar	:= ''
Local nI		:=	0

cRet := "'"
For nI := 01 To Len(cParametro)
	cFracPar := SubsTr(cParametro,nI,01) 
	If	(ASC(cFracPar) >= 48 .and. ASC(cFracPar) <=  57) .or. ;
		(ASC(cFracPar) >= 65 .and. ASC(cFracPar) <=  90) .or. ;
		(ASC(cFracPar) >= 97 .and. ASC(cFracPar) <= 122)
		cRet += cFracPar
	Else
		If nI < Len(cParametro)
			cRet += "','"
		EndIf
	EndIf	
Next nI
cRet += "'"
cFracPar := ''
Return(cRet)