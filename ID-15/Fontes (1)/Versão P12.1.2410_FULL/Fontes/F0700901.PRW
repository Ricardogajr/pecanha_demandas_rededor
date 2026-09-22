#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} F0700901
Validação para avaliar se o código não está bloqueado
@author Fernando Carvalho
@since 23/01/2017
@Project MAN0000007423041_EF_007
@param cCod, caracter, Código Fabricante
/*/
User Function F0700901(cCod)
	Local lRet 	:= .T.
	Local aArea:= GetArea()
	
	Default cCod := SB1->B1_XCODFAB
		
	P13->(DbSetOrder(1))//P13_FILIAL + P13_CGC
	If P13->(DbSeek(xFilial("P13") + cCod))
		If P13->P13_MSBLQL == "1"
			Help("",1, "", "Não válido!" ,;
					"O codigo Fabricante informado se encontra bloqueado!" , 3, 0)		
			lRet := .F.
		EndIf			
	EndIf			
	RestArea(aArea)
Return lRet

