User Function MT120GET()
Local aRet:= PARAMIXB[1]
aRet[2,1] := 110 

/*
// ------------------------------------
// Abaixando o começo da linha da getdados para caber os campos novos
// ------------------------------------
*/
aRet[1,3] := 105 // Abaixando a linha de contorno dos campos do cabeçalho

Return(aRet)
