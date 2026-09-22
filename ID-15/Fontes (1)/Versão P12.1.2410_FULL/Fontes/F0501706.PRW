//-----------------------------------------------------------------------
/*/{Protheus.doc} F0501706
Rotina para gerar a tabela U015
 
@author Nairan Alves Silva
@since  07/12/2017
@return Nil  

@project MAN0000007423048_EF_019
@cliente Rededor
@version P12.1.7
             
/*/
//-----------------------------------------------------------------------
User Function F0501706()

	AtuRCB()

Return


//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtuRCB
Cria a tabela U015 na RCB
@type function
@author Nairan Alves Silva
@since 07/12/2017 
@version 1.0
@return ${return}, ${return_description}
@project MAN0000007423048_EF_019
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function AtuRCB()
	
	Local nFil
	Local nTamFil    := 0
	Local nTamFilRCB := 0
	Local aFiles	 := {"RCB"}
	Local aTodasFil  := {}
	Local aFilRCB    := {}
	Local cFilRCB    := ""
	

	nTamFil		:= Len(cFilAnt)
	nTamFilRCB	:= Len(AllTrim(xFilial("RCB")))
	aTodasFil	:= {}
	aFilRCB		:= {}
	cFilRCB		:= cFilAnt
		
	If Empty(xFilial("RCB"))
		aFilRCB := {cFilAnt}
	Else
		aTodasFil := FWAllFilial(cEmpAnt,,,.F.)
		For nFil := 1 To Len(aTodasFil)
			cFilRCB := PadR(Left(aTodasFil[nFil],nTamFilRCB),nTamFil)
			If ( AScan(aFilRCB,{|x| x == cFilRCB }) == 0 )
				AAdd(aFilRCB,cFilRCB)
			EndIf
		Next
	EndIf
	
	For nFil := 1 To Len(aFilRCB)
		RCB->(DbSetOrder(1))
		If !RCB->(DbSeek(IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil]) + "U015"))
			
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U015'
			RCB->RCB_DESC   := 'USUARIOS MANUTENCAO'
			RCB->RCB_ORDEM  := '01'
			RCB->RCB_CAMPOS := 'USUARIO'
			RCB->RCB_DESCPO := 'Codigo do Usuario'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 6
			RCB->RCB_DECIMA := 0 
			RCB->RCB_PICTUR := '@!'
			RCB->RCB_VALID	:= 'U_F0501701(USUARIO,2)'
			RCB->RCB_PADRAO	:= 'USRPER'
			RCB->RCB_SHOWMA := 'N	'
			RCB->RCB_PESQ	:= '2'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())

			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U015'
			RCB->RCB_DESC   := 'USUARIOS MANUTENCAO'
			RCB->RCB_ORDEM  := '02'
			RCB->RCB_CAMPOS := 'NOME'
			RCB->RCB_DESCPO := 'Nome do Usuario'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 100
			RCB->RCB_DECIMA := 0 
			RCB->RCB_PICTUR := '@!'
			RCB->RCB_VALID := '.F.'
			RCB->RCB_PADRAO	:= ''
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_PESQ	:= '2'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())
					
		EndIf
	Next
Return 