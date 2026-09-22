#INCLUDE "PROTHEUS.CH"

//-----------------------------------------------------------------------
/*/{Protheus.doc} F1300803
Validação do município na tabela U014
 
@author Nairan Alves Silva
@since  27/12/2017
@return Nil  

@project MAN0000007423048_EF_008
@cliente Rededor
@version P12.1.7
             
/*/
//-----------------------------------------------------------------------

User Function F1300803 (cCampo, nTipo)

	Local aAreaCC2	:= CC2->(GetArea())
	Local aAreaSRJ	:= SRJ->(GetArea())
	Local aFunc		:= {}
	Local nX		:= 0
	Local lRet		:= .T.
		
	If nTipo == 1
		CC2->(DbSetOrder(3))
	
		If !(CC2->(DbSeek(xFilial("CC2") + cCampo)))
			Alert("Município não encontrado")
			lRet := .F.
		EndIf
	Else
		aFunc := aTipoSolic := StrToKarr(cCampo,"/")
		For nX := 1 To Len(aFunc)
			If !(SRJ->(DbSeek(xFilial("SRJ") + aFunc[nX])))
				Alert("Função " + AllTrim(aFunc[nX]) + " não encontrada")
				lRet := .F.
				Exit			
			EndIf
		Next
	EndIf

	RestArea(aAreaCC2)
	RestArea(aAreaSRJ)	
Return lRet