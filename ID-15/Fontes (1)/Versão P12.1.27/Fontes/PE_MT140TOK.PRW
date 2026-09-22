#INCLUDE 'TOTVS.CH'

/*{Protheus.doc} F0702904
Validação na inclusão de Pre Nota Fiscal de Entrada
@author Paulo Krüger
@since 17/11/2017
@project	MAN0000007423041_EF_029
@return lRet
*/

User Function MT140TOK()

	Local lRet  := .T.
	Local i     := 1
	Local nPosVenc := Ascan(aHeader,{|x|Alltrim(x[2])=="D1_XPRIVEN"})
	Local lCorrig := .F.

	Private cRot := ""

	lRet := U_F0702904() //Verifica ítens estocáveis 

	If ALTERA
		SD1->(DbSetOrder(1))
		//While SD1->(!EOF())
		For i := 1 To Len( aCols ) //  ticket n° 11507930
			If aCols[i][nPosVenc] <> SD1->D1_XPRIVEN
				Reclock("SF1",.F.)
				SF1->F1_XDTVNF  := aCols[i][nPosVenc]
				SF1->F1_XSTRECU := "C"
				SF1->F1_XDTRECU := dDataBase
				SF1->(MsUnLock())
				lCorrig := .T.
			EndIf
		Next i
		//EndDo
	EndIf

	If lCorrig
		U_XNCLAC(SF1->(RECNO()))
	EndIf
Return lRet
