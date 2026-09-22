#INCLUDE 'TOTVS.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GP810GRV()
Ponto de Entrada apos GRAVACAO da Tela de Reintegracao (GPEA810) 

@author Eduardo Fernandes 
@since 23/01/2017

@version P12
@project MAN0000007423040_EF_011
@return Nil
/*/
//-------------------------------------------------------------------
User Function GP810GRV()
Local aAreas  	:= {GetArea(), SRA->(GetArea()), SRG->(GetArea()) }	
Local lOpcReint	:= ParamIXB[1]

//Valida pelos parametros se essa empresa irá executar essas chamadas.
If !U_VALIDEMP()
	Return
EndIf
	
If lOpcReint .And. n_RecSRG > 0
	SRG->(dbGoto(n_RecSRG))
	U_F0600601(SRG->RG_FILIAL, "SRG", SRG->RG_MAT + DtoS(SRG->RG_DTGERAR), n_RecSRG, "DELETE", "F0601101")		
Endif

//Restaura as areas
AEval(aAreas,{|x,y| RestArea(x) })

Return Nil