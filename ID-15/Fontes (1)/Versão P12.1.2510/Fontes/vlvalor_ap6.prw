#INCLUDE "VlValor_AP6.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VLVALOR   ºAutor  ³Willy/Armando       º Data ³  07/01/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gatilho Interno para atualização do Acols                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function VlValor()
Local _lVlValor := .T.

ChkTemplate("CDV")

DbSelectArea('LHS')
DbSetORder(1)
If !MsSeek(xFilial('LHS') + aCols[n][_nPosCod])
	MsgInfo(STR0001, STR0002) //'Despesa não Cadastrada !'###'Atenção'
	_lVlValor := .F.
Else
	If LHS->LHS_TIPO $ "E"
		aCols[n][_nPosVbn] := IIf(aCols[n][_nPosVrt] > _nAdiant,_nAdiant,aCols[n][_nPosVrt])
		aCols[n][_nPosVbs] := IIf(aCols[n][_nPosVrt] > _nAdiant,aCols[n][_nPosVrt] - _nAdiant,0)
	Else
		aCols[n][_nPosVbn] := 0 
		aCols[n][_nPosVbs] := aCols[n][_nPosVrt]
	EndIf
EndIf
/*If AllTrim(_cRotPrest) == 'AE_DV005'
	aCols[n][_nPosVbn] := 0
	aCols[n][_nPosVbs] := M->LHR_VlrTot
Else
	If aCols[n][_nPosTCal] == 'TAXAM2' // Conversao para Dolar
		aCols[n][_nPosTax] := M->LHR_VlrTot / aCols[n][_nPosQtd]
	EndIf
EndIf*/

// Chama rotina de validacao de Limites por Despesas
If _lVlValor
	If 	DTOS(aCols[n][_nPosDat]) != "" .And. ; //Data nao preenchida
			AllTrim(aCols[n][_nPosCod]) != "" .And. ; //Despesa nao preenchida
			aCols[n][_nPosQtd] != 0

		U_ValidLim(aCols[n][_nPosDat], aCols[n][_nPosCod], aCols[n][_nPosQtd], M->LHR_VLRTOT)
	EndIf
EndIf

_oDesemb:Refresh()
_oReembo:Refresh()
_oDifer:Refresh()

If EhInter
	_oGastoUS:Refresh()
	_oReembUS:Refresh()
	_oDiferUS:Refresh()
EndIf

Return(_lVlValor)
