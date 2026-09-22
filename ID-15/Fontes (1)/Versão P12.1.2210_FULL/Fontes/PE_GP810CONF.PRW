#INCLUDE 'TOTVS.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GP810CONF()
Ponto de Entrada no TUDOOK da rotina GPEA810

@author Eduardo Fernandes 
@since 23/01/2017

@version P12
@project MAN0000007423040_EF_011
@return lRet
/*/
//-------------------------------------------------------------------
User Function GP810CONF()
Local lRet 		:= .T.
Local aAreas  	:= {GetArea(), SRA->(GetArea()), SRG->(GetArea()) }	

//Valida pelos parametros se essa empresa irá executar essas chamadas.
If !U_VALIDEMP()
	Return lRet
EndIf

//----------------------------------------------
// Esse deve ser o ULTIMO VALID, nao REMOVER  //
// -- ATENCAO -- Adicionar nonos VALIDs ACIMA //
//----------------------------------------------
If lRet 
	//Cria variavel na funçao OLD da pilha 	
	If Type("n_RecSRG") == "U"
		_SetNamedPrvt("n_RecSRG",0,"GPEA810Inc")
	Endif		
	n_RecSRG := SRG->(RECNO())
Endif

//Restaura as areas
AEval(aAreas,{|x,y| RestArea(x) })

Return lRet