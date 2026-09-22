#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH"
/*
{Protheus.doc} F0500111()
Atualização da tabela RCB
@Author     Kaiam Rodrigues
@Since      08/11/2016
@Version    P12.7
@Project    MAN0000007423039_EF_003
@Return
*/
User Function F0500111()
	
	Local nFil
	Local nI		 := 0
	Local nTamFil    := Len(cFilAnt)
	Local nTamFilRCB := Len(AllTrim(xFilial("RCB")))
	Local aTodasFil  := {}
	Local aFilRCB    := {xFilial("RCB")}
	Local cFilRCB    := cFilAnt
	Local nTamFilRCC := Len(AllTrim(xFilial("RCC")))	
	Local aFilRCC    := {xFilial("RCC")}
	Local cFilRCC	   := cFilAnt
	Local aTabela	   := {}
	Local cFilRCC_Us:= 	Replicate( " ", Len( cFilRCC ) )
	Local cNomeArq   := ""
	
	aTodasFil := FWAllFilial(cEmpAnt,,,.F.)
	For nFil := 1 To Len(aTodasFil)
		cFilRCB := PadR(Left(aTodasFil[nFil],nTamFilRCB),nTamFil)
		If ( AScan(aFilRCB,{|x| x == cFilRCB }) == 0 )
			AAdd(aFilRCB,cFilRCB)
		EndIf
	Next
	
	For nFil := 1 To Len(aFilRCB)
		RCB->(DbSetOrder(1))
		If !RCB->(DbSeek(IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil]) + "U008"))
			
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U008'
			RCB->RCB_DESC   := 'VISAO CANDIDATO INTERNO'
			RCB->RCB_ORDEM  := '01'
			RCB->RCB_CAMPOS := 'FSW_VIS'
			RCB->RCB_DESCPO := 'VISAO'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 6// N
			RCB->RCB_DECIMA := 0// N
			RCB->RCB_PICTUR := ''
			RCB->RCB_VALID  := 'EXISTCPO("RDK")'
			RCB->RCB_PESQ   := '2'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())
			
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U008'
			RCB->RCB_DESC   := 'VISAO CANDIDATO INTERNO'
			RCB->RCB_ORDEM  := '02'
			RCB->RCB_CAMPOS := 'FSW_COD   '
			RCB->RCB_DESCPO := 'CODIGO'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 6// N
			RCB->RCB_DECIMA := 0// N
			RCB->RCB_PICTUR := ''
			RCB->RCB_PESQ   := '1'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())
			
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U008'
			RCB->RCB_DESC   := 'VISAO CANDIDATO INTERNO'
			RCB->RCB_ORDEM  := '03'
			RCB->RCB_CAMPOS := 'FSW_DESC'
			RCB->RCB_DESCPO := 'DESCRIÇÃO'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 40// N
			RCB->RCB_DECIMA := 0// N
			RCB->RCB_PICTUR := ''
			RCB->RCB_PESQ   := '1'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())
		EndIf
		If !RCB->(DbSeek(IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil]) + "U009"))
			
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U009'
			RCB->RCB_DESC   := 'VISAO CANDIDATO EXTERNO'
			RCB->RCB_ORDEM  := '01'
			RCB->RCB_CAMPOS := 'FSW_VIS'
			RCB->RCB_DESCPO := 'VISAO'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 6// N
			RCB->RCB_DECIMA := 0// N
			RCB->RCB_PICTUR := ''
			RCB->RCB_VALID  := 'EXISTCPO("RDK")'
			RCB->RCB_PESQ   := '2'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())
			
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U009'
			RCB->RCB_DESC   := 'VISAO CANDIDATO EXTERNO'
			RCB->RCB_ORDEM  := '02'
			RCB->RCB_CAMPOS := 'FSW_COD   '
			RCB->RCB_DESCPO := 'CODIGO'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 6// N
			RCB->RCB_DECIMA := 0// N
			RCB->RCB_PICTUR := ''
			RCB->RCB_PESQ   := '1'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())
			
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U009'
			RCB->RCB_DESC   := 'VISAO CANDIDATO EXTERNO'
			RCB->RCB_ORDEM  := '03'
			RCB->RCB_CAMPOS := 'FSW_DESC'
			RCB->RCB_DESCPO := 'DESCRIÇÃO'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 40// N
			RCB->RCB_DECIMA := 0// N
			RCB->RCB_PICTUR := ''
			RCB->RCB_PESQ   := '1'
			RCB->RCB_SHOWMA := 'N'
			RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())			
		EndIf
	Next

	aTodasFil := FWAllFilial(cEmpAnt,,,.F.)
	For nFil := 1 To Len(aTodasFil)
		cFIlRCC := PadR(Left(aTodasFil[nFil],nTamFIlRCC),nTamFil)
		If ( AScan(aFIlRCC,{|x| x == cFIlRCC }) == 0 )
			AAdd(aFIlRCC,cFIlRCC)
		EndIf
	Next

	For nFil := 1 To Len(aFilRCC)
		RCC->(DbSetOrder(1))
	
		If RCC->(!DbSeek(IIF(Empty(xFilial("RCC")),xFilial("RCC"),aFilRCC[nFil]) + "U008"))             
			
			aTabela	:=	{}
			cNomeArq	:= "U008"
			//													                      1         2         3         4         5         6         7         8         9         0         1         2
			//													          123123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
			AAdd(aTabela,{IIF(Empty(xFilial("RCC")),xFilial("RCC"),aFilRCC[nFil]),cNomeArq,cFilRCC_Us,'      ','001','      000001Abaixo da Faixa Salarial'})
			AAdd(aTabela,{IIF(Empty(xFilial("RCC")),xFilial("RCC"),aFilRCC[nFil]),cNomeArq,cFilRCC_Us,'      ','002','      000002Dentro da Faixa, porém abaixo da solicitação da Vaga'})
			AAdd(aTabela,{IIF(Empty(xFilial("RCC")),xFilial("RCC"),aFilRCC[nFil]),cNomeArq,cFilRCC_Us,'      ','003','      000003Igual a Solicitação da Vaga'})
			AAdd(aTabela,{IIF(Empty(xFilial("RCC")),xFilial("RCC"),aFilRCC[nFil]),cNomeArq,cFilRCC_Us,'      ','004','      000004Dentro da Faixa, porém acima da Solicitação da Vaga'})
			AAdd(aTabela,{IIF(Empty(xFilial("RCC")),xFilial("RCC"),aFilRCC[nFil]),cNomeArq,cFilRCC_Us,'      ','005','      000005Acima da Faixa'})
			
			For nI := 1 To Len(aTabela) 	
				RecLock('RCC',.T.)
				RCC->RCC_FILIAL := aTabela[nI][01]                                             
				RCC->RCC_CODIGO := aTabela[nI][02]
				RCC->RCC_FIL    := aTabela[nI][03]
				RCC->RCC_CHAVE  := aTabela[nI][04]	
				RCC->RCC_SEQUEN := aTabela[nI][05]	
				RCC->RCC_CONTEU := aTabela[nI][06]		
				RCC->(MsUnLock())
			Next nI                                      	
		Endif
	Next
	
	For nFil := 1 To Len(aFilRCC)
		RCC->(DbSetOrder(1))
	
		If RCC->(!DbSeek(IIF(Empty(xFilial("RCC")),xFilial("RCC"),aFilRCC[nFil]) + "U009"))             
			
			aTabela	:=	{}
			cNomeArq	:= "U009"
			//													                      1         2         3         4         5         6         7         8         9         0         1         2
			//													          123123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
			AAdd(aTabela,{IIF(Empty(xFilial("RCC")),xFilial("RCC"),aFilRCC[nFil]),cNomeArq,cFilRCC_Us,'      ','001','      000001Abaixo da Faixa Salarial'})
			AAdd(aTabela,{IIF(Empty(xFilial("RCC")),xFilial("RCC"),aFilRCC[nFil]),cNomeArq,cFilRCC_Us,'      ','002','      000002Dentro da Faixa, porém abaixo da solicitação da Vaga'})
			AAdd(aTabela,{IIF(Empty(xFilial("RCC")),xFilial("RCC"),aFilRCC[nFil]),cNomeArq,cFilRCC_Us,'      ','003','      000003Igual a Solicitação da Vaga'})
			AAdd(aTabela,{IIF(Empty(xFilial("RCC")),xFilial("RCC"),aFilRCC[nFil]),cNomeArq,cFilRCC_Us,'      ','004','      000004Dentro da Faixa, porém acima da Solicitação da Vaga'})
			AAdd(aTabela,{IIF(Empty(xFilial("RCC")),xFilial("RCC"),aFilRCC[nFil]),cNomeArq,cFilRCC_Us,'      ','005','      000005Acima da Faixa'})
			
			For nI := 1 To Len(aTabela) 	
				RecLock('RCC',.T.)
				RCC->RCC_FILIAL := aTabela[nI][01]                                             
				RCC->RCC_CODIGO := aTabela[nI][02]
				RCC->RCC_FIL    := aTabela[nI][03]
				RCC->RCC_CHAVE  := aTabela[nI][04]	
				RCC->RCC_SEQUEN := aTabela[nI][05]	
				RCC->RCC_CONTEU := aTabela[nI][06]		
				RCC->(MsUnLock())
			Next nI                                      	
		Endif
	Next
	
Return