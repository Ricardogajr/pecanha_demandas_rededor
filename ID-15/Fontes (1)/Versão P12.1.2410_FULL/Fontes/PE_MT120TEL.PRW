#Include 'PROTHEUS.CH'

/*{Protheus.doc} MT120TEL()
Ponto de entrada dentro da rotina que monta a dialog do pedido de compras 
antes da montagem dos folders e da chamada da getdados.
@Author     Paulo Krüger
@Since		09/10/2017
@Version	P12.7
@project	MAN0000007423041_EF_022 
@Return		Nil*/

User Function MT120TEL()

Local nX := 1
Local cPedOrig := SC7->C7_NUM
Local cNameFull := UsrFullName(__cUserId)


aHeader[aScan(aHeader,{|x| Alltrim(x[2]) == "C7_XANEXO"})][1] := ""

If IsIncallStack("A120COPIA")

For nX := 01 To Len(aCols)
	aCols[nX][aScan(aHeader,{|x| Alltrim(x[2]) == "C7_XNOMECO"})] := cNameFull
	aCols[nX][aScan(aHeader,{|x| Alltrim(x[2]) == "C7_XUSRIN"})] := DtoS(dDatabase) + " " + Time()
	aCols[nX][aScan(aHeader,{|x| Alltrim(x[2]) == "C7_XNUORIG"})] := cPedOrig
Next nX

EndIf
	
	U_F0702209(PARAMIXB[1], PARAMIXB[2], PARAMIXB[4]) //Inclui o campo endereço de entrega no cabeçalho do Pedido de Compra.
Return
