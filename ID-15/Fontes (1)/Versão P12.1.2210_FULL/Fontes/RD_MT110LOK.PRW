#Include 'totvs.ch'
/*
|----------------------------------------------------------------------------|
|Programa  |Mt110LOk  |Autor  |TECNOSUM            | Data |  14/04/2016      |
|----------------------------------------------------------------------------|
|Descrição |Validação do Linha OK na solicitação de comras		             |
|          |Valida se só existe o mesmo motivo em todas as linahs            |					  
|----------------------------------------------------------------------------|
|Uso       |REDEDOR                                                          |						  
|----------------------------------------------------------------------------|
*/
User Function Mt110LOk()

	Local nPMotivo 	:= aScan(aHeader, {|x| AllTrim(x[2]) == 'C1_XMOTIVO'})
	Local nPTipo	:= aScan(aHeader, {|x| AllTrim(x[2]) == 'C1_XTPSC'})
	Local nX := 0
	Local lRet := .T.
	Local lExist
	Local nDelete := Len(aHeader)+1 //posicao que define se linha esta deletada
	
//--[ ID 1473 ]------------------------
//CC1XTOTAL := U_F1206003()
	CC1XTOTAL := U_F1206004()
//-------------------------------------
    
    If n == 1
    	If !(aCols[n][nDelete]) 
			IF !U_RDDV002(aCols[n][nPTipo], aCols[n][nPMotivo])
				lRet := .F.
				//Exit
			Endif			
			IF !U_RDDV001(aCols[n][nPTipo])
				lRet := .F.
				//Exit
			Endif			
		EndIf
   Else
   //For nX := 1 To Len(aCols)
		If !(aCols[n][nDelete]) .And. !(aCols[n - 1][nDelete]) 
			If aCols[n][nPTipo] <> aCols[n - 1][nPTipo]
				lRet := .F.
				Alert("Todos os itens devem ser do mesmo tipo! Verifique!")
				//Exit
			Endif
			
			IF !U_RDDV002(aCols[n][nPTipo], aCols[n][nPMotivo])
				lRet := .F.
				//Exit
			Endif			
			IF !U_RDDV001(aCols[n][nPTipo])
				lRet := .F.
				//Exit
			Endif			
		EndIf
	EndIf	
	//Next
Return(lRet)
