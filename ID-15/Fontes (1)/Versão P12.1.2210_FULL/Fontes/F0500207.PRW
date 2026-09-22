#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH"
/*---------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} F0500207
Atualização da tabela RCB e RCC
@Author    queizy.nascimento
@Since      01/12/2016
@Version    P12.7
@project MAN0000007423039_EF_002
@Return
/*///---------------------------------------------------------------------------------------------------------------------------
User Function F0500207()

	//Inclui dados na RCB 
	AtuRCB()
	
	//Inclui dados na RCC
	AtuRCC()
Return


//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtuRCB
(long_description)
@type function
@author queizy.nascimento
@since 01/12/2016 
@version 1.0
@return ${return}, ${return_description}
@project MAN0000007423039_EF_002
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function AtuRCB()
	
	Local nFil
	Local nTamFil    := Len(cFilAnt)
	Local nTamFilRCB := Len(AllTrim(xFilial("RCB")))
	Local aTodasFil  := {}
	Local aFilRCB    := {}
	Local cFilRCB    := cFilAnt
	
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
		If !RCB->(DbSeek(IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil]) + "U007"))
			
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U007'
			RCB->RCB_DESC   := 'STATUS DAS SOLICITAÇÕES'
			RCB->RCB_ORDEM  := '01'
			RCB->RCB_CAMPOS := 'DESCRICAO'
			RCB->RCB_DESCPO := 'DESCRICAO'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 100
			RCB->RCB_DECIMA := 0 
			RCB->RCB_PICTUR := ''
			RCB->RCB_VALID := ''
			RCB->RCB_PESQ   := '1'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '3'
			RCB->(MsUnlock())
		
			PutMv ("MV_PROXNUM", "U007")
		EndIf
	Next
Return 


//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtuRCC
(long_description)
@type function
@author queizy.nascimento
@since 01/12/2016
@version 1.0
@return ${return}, ${return_description}
@project MAN0000007423039_EF_002
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function AtuRCC()

	Local nFil
	Local nTamFil	:= Len(cFilAnt)
	Local nTFilRCC	:= Len(AllTrim(xFilial("RCC")))
	Local nTamSta	:= 0
	Local aTodasFil:= {}
	Local aFilRCC	:= {}
	Local cFilRCC	:= cFilAnt
	Local cToken	:= ","
	Local aStatus	:= StrTokArr( "Solicitação Aberta,"+;		//001
							"Aguardando Aprovação,"+;			//002
							"Aprovado Solicitação,"+;			//003
							"Reprovado Solicitação,"+;			//004
							"Aguardando Efetivação do RH,"+;	//005
							"Efetivação Atendida,"+;			//006
							"Efetivação Reprovada,"+;			//007
							"Vaga Cancelada,"+;					//008
							"Vaga Suspensa,"+;					//009
							"Vaga Reaberta,"+;					//010
							"Em Recrutamento,"+;				//011
							"Em Movimentacao (RI),"+;			//012
							"Em Cadastro,"+;					//013
							"Concluída,"+;						//014
							"Desistente Docs/Exame,"+;			//015
							"Docs Inconsistente,"+;				//016
							"Inapto,"+;							//017
							"Desistente Contrato,"+;			//018
							"Em Exame/Docto,"+;					//019
							"Em Ass.Contrato,"+;				//020
							"FAP (RE) Efetivada,"+;				//021
							"Enc Célula Cadastro,"+;			//022
							"Enc Assinatura de Contrato,"+;		//023
							"Cancelado Solicitação",+;		    //024																					
							cToken)
	
	If Empty(xFilial("RCC"))
		aFilRCC := {cFilAnt}
	Else
		aTodasFil := FWAllFilial(cEmpAnt,,,.F.)
		For nFil := 1 To Len(aTodasFil)
			cFilRCC := PadR(Left(aTodasFil[nFil],nTFilRCC),nTamFil)
			If ( AScan(aFilRCC,{|x| x == cFilRCC }) == 0 )
				AAdd(aFilRCC,cFilRCC)
			EndIf
		Next
	EndIf
	
	For nFil := 1 To Len(aFilRCC)
		RCC->(DbSetOrder(1))
		If !RCC->(DbSeek(IIF(Empty(xFilial("RCC")),xFilial("RCC"),aFilRCC[nFil]) + "U007"))
			For nTamSta := 1 to Len(aStatus)
				RCC->(RecLock("RCC", .T.))
				
				RCC->RCC_FILIAL 	:=IIF(Empty(xFilial("RCC")),xFilial("RCC"),aFilRCC[nFil]) 
				RCC->RCC_CODIGO	:= "U007"
				RCC->RCC_FIL	   	:=''
				RCC->RCC_CHAVE	:=''
				RCC->RCC_SEQUEN	:= StrZero(nTamSta, 3)
				RCC->RCC_CONTEU	:= aStatus[nTamSta]
				RCC->(MsUnlock())				
			Next
		EndIf	
	Next
Return
