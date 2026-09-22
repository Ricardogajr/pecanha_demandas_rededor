/*/
MT103TPC - Ponto de entrada utilizado para corrigir o projeto Captura de notas, para as NFS de CNPJ RAIZ
Lucas Miranda de Aguiar 04/12/2024
Obs: É gambiarra, não mexe sem falar comigo antes.
/*/
User Function MT103TPC()



	Local nPosTes    	:= 0
	Local nPosCfo    	:= 0

	IF TYPE ("__XXQTIT") <> "N"
		Public __XXQTIT := 1 
	endif



	If IsInCallStack("U_xKPTInbAll")

		nPosTes    	:= GetPosSD1("D1_TES")
		nPosCfo    	:= GetPosSD1("D1_CF")
		If Empty(aCols[n][nPosTES])
			aCols[n][nPosTES] := aItensAuto[__XXQTIT][aScan(aItensauto[__XXQTIT],{|x| Upper(AllTrim(x[1])) == "D1_TES" })][2]
		EndIf
		If Empty(aCols[n][nPosCfo])
			aCols[n][nPosCfo] := "00000"
		EndIf
		__XXQTIT++
	endIf


Return
