#include "protheus.ch"
#INCLUDE "topconn.ch"

User Function F300FIL 

Local aParam	:= PARAMIXB
Local cNumTit	:= aParam[1]
Local nTamParc	:= aParam[2]
Local nTamTit	:= aParam[3]
Local nRecTit	:= aParam[4]

DbSelectArea("SE2")                           
SE2->(DbsetOrder(11))
If dbSeek(xFilial("SE2")+Substr(cNumTit,1,10))
	lAchou := .T.
Else
	lAchou := .F.	
EndIf	   

 If valtype(lAut) == 'L'
	If !lAut
		xPerg := .T.
		lAut 	:= 1
	Else	
		xPerg := .F.
		lAut 	:= 0		
	EndIf	         
Else
//	If lAut = 1
		xPerg := .F.	         
//	EndIf
EndIf
    
If lAchou
	If dBaixa > dDataBase 
		If  xPerg
	//		xMsg := "Deseja Alterar a data de Baixa do Titulo "+Alltrim(SE2->E2_NUM)+" - "+Alltrim(SE2->E2_PREFIXO)+"  de "+DtoC(dBaixa)+" para "+dToc(dDataBase)+" ? "
			xMsg := "Deseja Alterar a data de Baixa dos Titulos de "+DtoC(dBaixa)+" para "+dToc(dDataBase)+" ? "
			If Aviso("Data Incorreta!",xMsg,{"Sim","Não"}) == 1
				dBaixa := dDataBase         
				lAut 	 := 1
			Else
				SE2->(DbGoTop())
				lAut 	 := 0
			EndIf
		Else
			If lAut = 1                    
				dBaixa := dDataBase         
			Else               
				SE2->(DbGoTop())
			EndIf				         
		EndiF	
	EndIf
EndIf      

Return