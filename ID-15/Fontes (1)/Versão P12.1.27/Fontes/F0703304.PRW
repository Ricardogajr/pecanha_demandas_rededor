#include "totvs.ch"

/*/{Protheus.doc} F0703304
Função responsável por validar a devolução manual de notas fiscais de entrada
@type User function
@author anieli.rodrigues
@since 20/02/2017
@version 12.7
@project	MAN0000007423041_EF_033
@return lRet
/*/

User Function F0703304()

	Local aAreaSF1	:= SF1->(GetArea())
	Local lInt 		:= IsInCallStack("U_F0703302")
	Local lRet 		:= .T.
	Local nPosNfOri 	:= AScan(aHeader,{|x| AllTrim(x[2])=="C6_NFORI"})
	Local nPosSerOri 	:= AScan(aHeader,{|x| AllTrim(x[2])=="C6_SERIORI"})
	Local nPosIteOri	:= AScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMORI"})
	
	If !lInt .And. !Empty(aCols[n][nPosNfOri] + aCols[n][nPosSerOri] + aCols[n][nPosIteOri]) .and. !IsInCallStack('A410Copia') 
		SF1->(DbSetOrder(1))
		If SF1->(DbSeek(xFilial("SF1") + aCols[n][nPosNfOri] + aCols[n][nPosSerOri] + M->C5_CLIENTE + M->C5_LOJACLI))
			If !Empty(SF1->F1_XID)
				Help(,,"EXTERNO",,"Não é possível realizar a devolução manual de notas fiscais originadas pela integração",1,0) 
				lRet := .F.
			EndIf  
		EndIf 
	EndIf 
	
	RestArea(aAreaSF1)

Return lRet 