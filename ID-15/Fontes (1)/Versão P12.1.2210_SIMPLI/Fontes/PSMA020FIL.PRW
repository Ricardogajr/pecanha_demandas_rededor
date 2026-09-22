#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MA020FIL
//TODO -->> PE para filtrar o browse do cadastro de fornecedores.
Deve considerar os parâmetros FS_CODGRPO e FS_CODUSER

@author Alexandre Felicio
@since 14/12/2019
@version 12.1.17
@return ${return}, ${return_description}

@type function
/*/
user function MA020FIL()
Local _cCusr := RetCodUsr()
Local _aGrup := UsrRetGrp(RetCodUsr())
Local _cCodG := GetMV("FS_CODGRPO")
Local _cCodU := GetMV("FS_CODUSER")
Local _cFilt := ''
Local _nM     := ''
Local _cOkPar := ''

	For _nM := 1 to Len(_aGrup)		
	   _cOkPar := IIf(_aGrup[_nM] $ _cCodG,'S','')	   
	   If _cOkPar == 'S'
	       Exit  
	   endif
	Next
	
	IF !(_cOkPar == 'S')  .and. !( _cCusr $ _cCodU) 
		_cFilt := 'Empty(A2_XAUTORI)'	   		 
	endif	
	
return(_cFilt)