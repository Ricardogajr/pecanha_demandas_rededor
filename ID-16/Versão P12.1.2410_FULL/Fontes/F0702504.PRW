#Include 'PROTHEUS.CH'

/*/{Protheus.doc} F0702504
Método que altera o status da P17.
@type 		function
@author 	Reinaldo Dias
@since 		28/08/2018
@version 	1.0
@param 		oProduto, objeto, Objeto com os campos e valores
@project	MAN000007423041_EF_025
@return 	cRetorno, Mensagem de sucesso ou erro

/*/
User Function F0702504(oProduto)

	Local cRetorno	:= "ERRO|"
	Local cFilInt	:= ""
	Local cFilAtu	:= ""
	Local cCodProd	:= ""
	Local cIdInt 	:= U_GetIntegID()
	Local nRegLog	:= 0
	Local cP17FRONT := ""

	cFilInt := oProduto:cFilReg

	Begin Transaction
		nRegLog := U_F07LOG01(cIdInt,{oProduto})
	End Transaction

	//Validar a filial
	If ! U_F07ChkFil(oProduto:cFILREG)
		cRetorno:= "ERRO| Filial Invalida  "
		U_F07LOG02(nRegLog,cRetorno,.f.,"P17",1,'')
		Return cRetorno
	EndIf

	If !(cFilInt == cFilAnt)
		cFilAtu := cFilAnt
		cFilAnt := cFilInt
	EndIf

	cCodProd := PADR(Alltrim(oProduto:cCod),TamSx3('B1_COD')[1])
	cP7_BLOQ := oProduto:cP17BLOQ
	cP17FRONT := oProduto:CCODFRONT

	//Validar o status do bloqueio
	If !Empty(cP7_BLOQ)
		IF !cP7_BLOQ $ "S/N"
			cRetorno:= "ERRO| O Status esta diferente de S ou N."
			U_F07LOG02(nRegLog,cRetorno,.f.,"P17",1,'')
			Return cRetorno
		EndIf
	EndIf

	//Validar o produto
	IF Empty(cCodProd)
		cRetorno:= "ERRO| O produto nao foi informado."
		U_F07LOG02(nRegLog,cRetorno,.f.,"P17",1,'')
		Return cRetorno
	EndIf

	//Verifica se o produto existe na filial.
	P17->(DbSetOrder(1))
	IF P17->(DbSeek(xFilial('P17') + cCodProd + cFilInt))
		P17->(RecLock('P17', .F.))
		If (!Empty(cP7_BLOQ) .And. AllTrim(cP7_BLOQ) <> AllTrim(P17->P17_BLOQ))
			P17->P17_BLOQ  := cP7_BLOQ
		EndIf
		If (!Empty(cP17FRONT) .And. AllTrim(cP17FRONT) <> AllTrim(P17->P17_FRONT))
			P17->P17_FRONT  := cP17FRONT
		EndIf
		P17->(MsUnlock())
		cRetorno := "OK|" + P17->P17_COD
		U_F07LOG02(nRegLog,cRetorno,.t.,"P17",1,xFilial('P17') + '|' + cCodProd + '|' + cFilInt)
	Else
		cRetorno:= "ERRO| O produto "+Alltrim(cCodProd)+" nao foi encontrado na tabela P17 para a filial "+cFilInt
		U_F07LOG02(nRegLog,cRetorno,.f.,"P17",1,xFilial('P17') + '|' + cCodProd + '|' + cFilInt)
		Return cRetorno
	EndIf

	If !(cFilAtu == cFilAnt)
		cFilAnt := cFilAtu
	EndIf

Return cRetorno
