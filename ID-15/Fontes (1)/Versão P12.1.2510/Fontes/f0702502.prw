Static nTamProd := TamSX3("B1_COD")[1]
Static cCodProd := Space(nTamProd)
Static cNumProd := Space(nTamProd)
Static lFirst   := .T.

User Function F0702502()

	Local oModel   := FwModelActive()
	Local oModeCab := oModel:GetModel("SB1MASTER")

	If INCLUI
		If lFirst
			SB1->(DbSetOrder(13))
			cNumProd := GetSXENUM("SB1", "B1_COD")
			While SB1->(DbSeek(xFilial("SB1")+cNumProd))
				cNumProd := GetSXENUM("SB1","B1_COD")
			EndDo
			cCodProd := AllTrim(Str(Val(cNumProd)))
			ConfirmSX8()
		EndIf

	EndIf
	lFirst := !lFirst


Return cCodProd

User Function F0702503()

   /* If INCLUI
        If lFirst
        	SB1->(DbSetOrder(13))
            cNumProd := GetSX8NUM("SB1", "B1_XZERCOD") 
        	While SB1->(DbSeek(xFilial("SB1")+cNumProd))
				cNumProd := GetSX8NUM("SB1","B1_XZERCOD")
			EndDo
            cCodProd := AllTrim(Str(Val(cNumProd)))
        EndIf

    EndIf
	*/
	lFirst := !lFirst

Return ""

User Function F0702505(cCod)

	cB1XZER := STRZERO(Val(cCod),TamSX3("B1_XZERCOD")[1])

	If DbSeek(xFilial("SB1")+cCod)
		RecLock("SB1",.F.)
		SB1->B1_XZERCOD := cB1XZER
		SB1->(MsUnLock())
	EndIf

Return
