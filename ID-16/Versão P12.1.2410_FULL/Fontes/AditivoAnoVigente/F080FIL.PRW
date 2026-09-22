#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} F080FIL
//TODO -->> PE para filtrar os títulos a pagar a partir da Baixa Manual(chamada dentro do FINA750 - funções do contas a pagar)
Deve considerar os parâmetros FS_CODGRPO e FS_CODUSER

@author Alexandre Felicio
@since 15/12/2019 
@version 12.1.17
@return ${return}, ${return_description}

@type function
/*/
user function F080FIL()
Local _cCusr       := RetCodUsr()
Local _aGrup       := UsrRetGrp(RetCodUsr())
Local _cCodG       := GetMV("FS_CODGRPO")
Local _cCodU       := GetMV("FS_CODUSER")
Local _cExprF      := ''
Local  cAlias74    := GetNextAlias()
Local _cQuery      := ''
Local _nM     := ''
Local _cOkPar := ''
	
	For _nM := 1 to Len(_aGrup)		
	   _cOkPar := IIf(_aGrup[_nM] $ _cCodG,'S','')	   
	   If _cOkPar == 'S'
	       Exit  
	   endif
	Next
	
	IF !(_cOkPar == 'S')  .and. !( _cCusr $ _cCodU) 
            Iif(Select((cAlias74)) > 0, (cAlias74)->(DbCloseArea()),)						   
								
			_cQuery := " SELECT A2_COD||A2_LOJA FORNECLJ "     
			_cQuery += " FROM  " + RetSqlName("SA2") 
			_cQuery += " WHERE  A2_FILIAL  = '" + xFilial( "SA2" ) + "'" 
			_cQuery += " and D_E_L_E_T_ = ' ' " 
			_cQuery += " AND A2_XAUTORI = 'S' "
			
			dbUseArea(.T. , "TOPCONN" , TcGenQry(,,_cQuery) , (cAlias74) , .T. , .T.)

			(cAlias74)->(DbGoTop())
			While !(cAlias74)->(Eof())
					
				_cExprF += " E2_FORNECE+E2_LOJA <> '" + 	(cAlias74)->FORNECLJ + "'" 	+ ' .and. '	
						
				(cAlias74)->(DbSkip())
			EndDo
			
			IF !Empty(_cExprF)	
			   _cExprF := Substr(_cExprF,1, LEN(alltrim(_cExprF)) - 5) 
			endif   
											 
			(cAlias74)->(DbCloseArea())
        
	endif 
	
return(_cExprF)	
