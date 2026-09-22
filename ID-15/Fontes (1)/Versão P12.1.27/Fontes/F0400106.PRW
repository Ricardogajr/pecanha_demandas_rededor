#Include "PROTHEUS.CH"
/*{Protheus.doc} F0400106
Função responsável pelas integrações de RH
@type		User function
@author	Paulo Krüger
@since		07/11/2016
@version	12.7
@param		cTabela, cNomAlias
@project	MAN000000463801
@return Nil
/*/

User Function F0400106(cNomAlias)
Local cFunc		:= AllTrim(FunName())
Local cFuncF004	:= "AE_DESPV"

If AllTrim(cNomAlias) == "LHQ" .And. cFunc $ cFuncF004
	FldSettrigger(LHQ_FILIAL,8192 + 16384 + 32768,{|X,Y| _fElimAnex(x,y,"LHQ")})
Endif

Return .T.

Static Function _fElimAnex(cCampo,nModo)
Local nCodDelete := 32768
Local aArea      := GetArea()

If nModo = nCodDelete
	U_F0400105('AE_DESPV', LHQ->LHQ_FILIAL, LHQ->LHQ_CODIGO)
Endif

Return .T.
