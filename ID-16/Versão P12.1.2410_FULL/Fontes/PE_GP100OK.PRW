//-----------------------------------------------------------------------
/*/{Protheus.doc} GP100OK
Validação linhaok GPEA580
 
@author Nairan Alves Silva
@since  07/12/2017
@return Nil  

@project MAN0000007423048_EF_018
@cliente Rededor
@version P12.1.7
             
/*/
//-----------------------------------------------------------------------
User Function GP100OK()
 
	Local lRet	:= .T.
	
	//Valida pelos parametros se essa empresa irá executar essas chamadas.
	If !U_VALIDEMP()
		Return lRet
	EndIf
	
	If IsInCallStack ("GPEA590") .Or. IsInCallStack ("GPEA580")
		lRet := U_F0501704()
	EndIf 
	
Return (lRet)