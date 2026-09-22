#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} F0700902
Validação do CNPJ do fabricante
@author Fernando Carvalho
@since 20/01/2017
@Project MAN0000007423041_EF_007
@param cCGC, caracter, Código CGC
/*/
User Function F0700902(cCGC)
	Local lRet 	:= .T.
	Local aArea	:= GetArea()
	
	P13->(DbSetOrder(2))//P13_FILIAL + P13_CGC
	If P13->(DbSeek(xFilial("P13") + SubStr(cCGC,1,8)))
		
		Help("",1, "CNPJ JÁ EXISTE!", "O CNPJ informado já foi cadastrado para o fabricante:" ,;
				"O CNPJ informado já foi cadastrado para o fabricante:" + CHR(13) + CHR(10) + ;
				 "Código:   " + P13->P13_COD + CHR(13) + CHR(10) + ;
				"Descrição:" + P13->P13_DESCR , 3, 0)
		
		lRet := .F.		
	EndIf			
	RestArea(aArea)
Return lRet






