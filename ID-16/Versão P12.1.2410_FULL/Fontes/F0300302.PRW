#Include 'Protheus.ch'
#Include "TBICONN.CH"

//--------------------------------------------------------------------------
/*{Protheus.doc} F0300302
Atualização da tabela RCB e RCC
@owner      Ademar Fernandes
@author     Ademar Fernandes
@since      05/12/2016
@param      NIL
@return     NIL
@project    MAN00000463701_EF_003
@version    P 12.1.7
@obs        Observacoes
*/
//--------------------------------------------------------------------------
User Function F0300302()
	
	Local nFil, nX, nY
	Local nTamFil    := Len(cFilAnt)
	Local nTamFilRCB := Len(AllTrim(xFilial("RCB")))
	Local nTamFilRCC := Len(AllTrim(xFilial("RCC")))
	Local aTodasFil  := {}
	Local aFilRCB    := {}
	Local cFilRCB    := cFilAnt
	Local aFilRCC := {}
	Local cFilRCC := cFilAnt
	Local aRCB	:= {}
	Local aRCC	:= {}
	
	If Empty(xFilial("RCB"))
		aFilRCB := {xFilial("RCB")}
	Else
		aTodasFil := FWAllFilial(cEmpAnt,,,.F.)
		For nFil := 1 To Len(aTodasFil)
			cFilRCB := PadR(Left(aTodasFil[nFil],nTamFilRCB),nTamFil)
			If ( AScan(aFilRCB,{|x| x == cFilRCB }) == 0 )
				AAdd(aFilRCB,cFilRCB)
			EndIf
		Next
	EndIf
	
	//-Monta o array com a Definiçao dos Campos da Tabela RCB
	AAdd(aRCB, {"","U003","PLANO DE SUCESSÃO","01","X_EIXO"  ,"Código de Eixo Comp"	,"C",1,0,"@!"		,"NAOVAZIO()","","","1","N","1"})
	AAdd(aRCB, {"","U003","PLANO DE SUCESSÃO","02","X_FX1INI","Início Faixa 1"		,"N",6,2,"@E 999.99",""			 ,"","","2","N","1"})
	AAdd(aRCB, {"","U003","PLANO DE SUCESSÃO","03","X_FX1FIM","Final da Faixa 1"	,"N",6,2,"@E 999.99",""			 ,"","","2","N","1"})
	AAdd(aRCB, {"","U003","PLANO DE SUCESSÃO","04","X_FX2INI","Início Faixa 2"		,"N",6,2,"@E 999.99",""			 ,"","","2","N","1"})
	AAdd(aRCB, {"","U003","PLANO DE SUCESSÃO","05","X_FX2FIM","Final Faixa 2"		,"N",6,2,"@E 999.99",""			 ,"","","2","N","1"})
	AAdd(aRCB, {"","U003","PLANO DE SUCESSÃO","06","X_FX3INI","Início Faixa 3"		,"N",6,2,"@E 999.99",""			 ,"","","2","N","1"})
	AAdd(aRCB, {"","U003","PLANO DE SUCESSÃO","07","X_FX3FIM","Final Faixa 3"		,"N",6,2,"@E 999.99",""			 ,"","","2","N","1"})
	AAdd(aRCB, {"","U003","PLANO DE SUCESSÃO","08","X_FX4INI","Início Faixa 4"		,"N",6,2,"@E 999.99",""			 ,"","","2","N","1"})
	AAdd(aRCB, {"","U003","PLANO DE SUCESSÃO","09","X_FX4FIM","Final Faixa 4"		,"N",6,2,"@E 999.99",""			 ,"","","2","N","1"})
	
	//-Monta o array com a Definiçao dos Campos da Tabela RCB
	AAdd(aRCC, {"","U003","","","001","X  1.00  1.99  2.00  2.99  3.00  3.59  3.60  4.00"})
	AAdd(aRCC, {"","U003","","","002","Y  0.00 30.00 31.00 50.00 51.00 80.00 81.00100.00"})
	
	
	If !RCB->(DbSeek(IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil]) + aRCB[01,02]))
		
		For nX := 1 to Len(aRCB)
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := aRCB[nX,02]
			RCB->RCB_DESC   := aRCB[nX,03]
			RCB->RCB_ORDEM  := aRCB[nX,04]
			RCB->RCB_CAMPOS := aRCB[nX,05]
			RCB->RCB_DESCPO := aRCB[nX,06]
			RCB->RCB_TIPO   := aRCB[nX,07]
			RCB->RCB_TAMAN  := aRCB[nX,08]
			RCB->RCB_DECIMA := aRCB[nX,09]
			RCB->RCB_PICTUR := aRCB[nX,10]
			RCB->RCB_VALID	:= aRCB[nX,11]
			RCB->RCB_PADRAO	:= aRCB[nX,12]
			RCB->RCB_VERSAO	:= aRCB[nX,13]
			RCB->RCB_PESQ	:= aRCB[nX,14]
			RCB->RCB_SHOWMA := aRCB[nX,15]
			RCB->RCB_MODULO := aRCB[nX,16]
			RCB->(MsUnlock())
		Next nX
	EndIf
	
	
	
	If Empty(xFilial("RCC"))
		aFilRCC := {cFilAnt}
	Else
		aTodasFil := FWAllFilial(cEmpAnt,,,.F.)
		For nFil := 1 To Len(aTodasFil)
			cFilRCC := PadR(Left(aTodasFil[nFil],nTamFilRCC),nTamFil)
			If ( AScan(aFilRCC,{|x| x == cFilRCC }) == 0 )
				AAdd(aFilRCC,cFilRCC)
			EndIf
		Next
	EndIf
	
	
	For nFil := 1 To Len(aFilRCC)
		RCC->(DbSetOrder(1))
		If !RCC->(DbSeek(IIF(Empty(xFilial("RCC")),xFilial("RCC"),aFilRCC[nFil]) + aRCC[01,02]))
			
			For nY := 1 to Len(aRCC)
				RecLock("RCC", .T.)
				RCC->RCC_FILIAL := IIF(Empty(xFilial("RCC")),xFilial("RCC"),aFilRCC[nFil])
				RCC->RCC_CODIGO := aRCC[nY,02]
				RCC->RCC_FIL	:= aRCC[nY,03]
				RCC->RCC_CHAVE	:= aRCC[nY,04]
				RCC->RCC_SEQUEN	:= aRCC[nY,05]
				RCC->RCC_CONTEU	:= aRCC[nY,06]
				RCC->(MsUnlock())
			Next nY
		EndIf
		
	Next
Return

