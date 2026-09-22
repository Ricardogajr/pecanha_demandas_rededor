#INCLUDE "TOTVS.CH"

//-----------------------------------------------------------------------
/*/{Protheus.doc} F0600604
Gravar PA6 da Exclusao do Calculo de Rescisao
 
@author Eduardo Fernandes 
@since  21/12/2016
@param oModelRec, objeto, Modelo de Dados
@return Nil  

@project MAN0000007423040_EF_006
@cliente Rededor
@version P12.1.7
             
/*/
//-----------------------------------------------------------------------
User Function F0600604(oModelRec)
Local aAreas  := {GetArea(), SRG->(GetArea())}	
Local nOpc 	:= oModelRec:GetOperation()

If nOpc == 5 .And. MsgYesNo("Enviar informações de Exclusao da Rescisao ao ApData?","Atenção")
	U_F0600601(SRG->RG_FILIAL, "SRG", SRG->RG_MAT + DtoS(SRG->RG_DTGERAR), SRG->(Recno()), "DELETE")	
Endif

//Restaura as areas
AEval(aAreas,{|x,y| RestArea(x) })

Return Nil