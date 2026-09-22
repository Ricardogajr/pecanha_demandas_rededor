/*/{Protheus.doc} ChkFile
Ponto de Entrada após o MSUnLock.
@type User Function
@author nairan.silva
@since 01/11/2016
@version 12.7
@return True
@project	MAN000000463801_EF_001
@project	MAN0000007423040_EF_001,MAN0000007423040_EF_002,
@project	MAN0000007423040_EF_003,MAN0000007423040_EF_005,MAN0000007423040_EF_007
/*/
User Function  ChkFile()

	Local cNomAlias	:= PARAMIXB[2]

	U_F1400101(/*cTabela,*/cNomAlias)

	//U_F0400106(/*cTabela,*/cNomAlias)

	//U_F0600106(/*cTabela,*/cNomAlias)

Return .T.
