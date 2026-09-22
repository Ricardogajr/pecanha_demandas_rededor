#Include 'Protheus.ch'

/*
{Protheus.doc} F0800101()
Cadastro Tipos de Solicitação
@Author     Bruno de Oliveira
@Since      02/03/2017
@Version    P12.1.07
@Project    MAN0000007423042_EF_001
*/
User Function F0800101()
	
	Local aArea := GetArea()
	
	PA7->(DbSetOrder(1)) //PA7_FILIAL + PA7_CODIGO + PA7_CODSUB
	If !PA7->(DbSeek(xFilial("PA7") + "001" + "001"))
		RecLock("PA7",.T.)
		PA7->PA7_FILIAL := xFilial("PA7")
		PA7->PA7_CODIGO := "001"
		PA7->PA7_DESCR  := "TREINAMENTO / EVENTO"
		PA7->PA7_CODSUB := "001"
		PA7->PA7_DESSUB := "TREINAMENTO / EVENTO"
		PA7->(MsUnLock())
	EndIf
	
	If !PA7->(DbSeek(xFilial("PA7") + "002" + "001"))
		RecLock("PA7",.T.)
		PA7->PA7_FILIAL := xFilial("PA7")
		PA7->PA7_CODIGO := "002"
		PA7->PA7_DESCR  := "VAGA"
		PA7->PA7_CODSUB := "001"
		PA7->PA7_DESSUB := "VAGA"
		PA7->(MsUnLock())
	EndIf
	
	If !PA7->(DbSeek(xFilial("PA7") + "003" + "001"))
		RecLock("PA7",.T.)
		PA7->PA7_FILIAL := xFilial("PA7")
		PA7->PA7_CODIGO := "003"
		PA7->PA7_DESCR  := "AUMENTO DE QUADRO"
		PA7->PA7_CODSUB := "001"
		PA7->PA7_DESSUB := "NOVO POSTO"
		PA7->(MsUnLock())
	EndIf
	
	If !PA7->(DbSeek(xFilial("PA7") + "003" + "002"))
		RecLock("PA7",.T.)
		PA7->PA7_FILIAL := xFilial("PA7")
		PA7->PA7_CODIGO := "003"
		PA7->PA7_DESCR  := "AUMENTO DE QUADRO"
		PA7->PA7_CODSUB := "002"
		PA7->PA7_DESSUB := "AUMENTO DE QUANTIDADE"
		PA7->(MsUnLock())
	EndIf
	
	If !PA7->(DbSeek(xFilial("PA7") + "004" + "001"))
		RecLock("PA7",.T.)
		PA7->PA7_FILIAL := xFilial("PA7")
		PA7->PA7_CODIGO := "004"
		PA7->PA7_DESCR  := "FAP"
		PA7->PA7_CODSUB := "001"
		PA7->PA7_DESSUB := "APROVAÇÃO FAP INTERNA"
		PA7->(MsUnLock())
	EndIf
	
	If !PA7->(DbSeek(xFilial("PA7") + "004" + "002"))
		RecLock("PA7",.T.)
		PA7->PA7_FILIAL := xFilial("PA7")
		PA7->PA7_CODIGO := "004"
		PA7->PA7_DESCR  := "FAP"
		PA7->PA7_CODSUB := "002"
		PA7->PA7_DESSUB := "FAP EXTERNA ACIMA DA FAIXA SALARIAL"
		PA7->(MsUnLock())
	EndIf
	
	If !PA7->(DbSeek(xFilial("PA7") + "004" + "003"))
		RecLock("PA7",.T.)
		PA7->PA7_FILIAL := xFilial("PA7")
		PA7->PA7_CODIGO := "004"
		PA7->PA7_DESCR  := "FAP"
		PA7->PA7_CODSUB := "003"
		PA7->PA7_DESSUB := "FAP EXTERNA ABAIXO OU DENTRO DA FAIXA SALARIAL"
		PA7->(MsUnLock())
	EndIf	
	
	If !PA7->(DbSeek(xFilial("PA7") + "005" + "001"))
		RecLock("PA7",.T.)
		PA7->PA7_FILIAL := xFilial("PA7")
		PA7->PA7_CODIGO := "005"
		PA7->PA7_DESCR  := "DESLIGAMENTO"
		PA7->PA7_CODSUB := "001"
		PA7->PA7_DESSUB := "ÓBITO"
		PA7->(MsUnLock())
	EndIf
	
	If !PA7->(DbSeek(xFilial("PA7") + "005" + "002"))
		RecLock("PA7",.T.)
		PA7->PA7_FILIAL := xFilial("PA7")
		PA7->PA7_CODIGO := "005"
		PA7->PA7_DESCR  := "DESLIGAMENTO"
		PA7->PA7_CODSUB := "002"
		PA7->PA7_DESSUB := "PEDIDO DE DEMISSÃO"
		PA7->(MsUnLock())
	EndIf
	
	If !PA7->(DbSeek(xFilial("PA7") + "005" + "003"))
		RecLock("PA7",.T.)
		PA7->PA7_FILIAL := xFilial("PA7")
		PA7->PA7_CODIGO := "005"
		PA7->PA7_DESCR  := "DESLIGAMENTO"
		PA7->PA7_CODSUB := "003"
		PA7->PA7_DESSUB := "TERMINO DE CONTRATO"
		PA7->(MsUnLock())
	EndIf
	
	If !PA7->(DbSeek(xFilial("PA7") + "005" + "004"))
		RecLock("PA7",.T.)
		PA7->PA7_FILIAL := xFilial("PA7")
		PA7->PA7_CODIGO := "005"
		PA7->PA7_DESCR  := "DESLIGAMENTO"
		PA7->PA7_CODSUB := "004"
		PA7->PA7_DESSUB := "ABANDONO DE EMPREGO"
		PA7->(MsUnLock())
	EndIf
	
	If !PA7->(DbSeek(xFilial("PA7") + "005" + "005"))
		RecLock("PA7",.T.)
		PA7->PA7_FILIAL := xFilial("PA7")
		PA7->PA7_CODIGO := "005"
		PA7->PA7_DESCR  := "DESLIGAMENTO"
		PA7->PA7_CODSUB := "005"
		PA7->PA7_DESSUB := "DISPENSA SEM JUSTA CAUSA"
		PA7->(MsUnLock())
	EndIf
	
	If !PA7->(DbSeek(xFilial("PA7") + "005" + "006"))
		RecLock("PA7",.T.)
		PA7->PA7_FILIAL := xFilial("PA7")
		PA7->PA7_CODIGO := "005"
		PA7->PA7_DESCR  := "DESLIGAMENTO"
		PA7->PA7_CODSUB := "006"
		PA7->PA7_DESSUB := "DISPENSA COM JUSTA CAUSA"
		PA7->(MsUnLock())
	EndIf
	
	If !PA7->(DbSeek(xFilial("PA7") + "005" + "098"))
		RecLock("PA7",.T.)
		PA7->PA7_FILIAL := xFilial("PA7")
		PA7->PA7_CODIGO := "005"
		PA7->PA7_DESCR  := "DESLIGAMENTO"
		PA7->PA7_CODSUB := "098"
		PA7->PA7_DESSUB := "FUNCIONÁRIO GERENTE OU SUPERIOR (DISPENSA SEM JUSTA CAUSA)"
		PA7->(MsUnLock())
	EndIf
	
	If !PA7->(DbSeek(xFilial("PA7") + "005" + "099"))
		RecLock("PA7",.T.)
		PA7->PA7_FILIAL := xFilial("PA7")
		PA7->PA7_CODIGO := "005"
		PA7->PA7_DESCR  := "DESLIGAMENTO"
		PA7->PA7_CODSUB := "099"
		PA7->PA7_DESSUB := "FUNCIONÁRIO COM MAIS DE 10 ANOS (DISPENSA SEM JUSTA CAUSA)"
		PA7->(MsUnLock())
	EndIf
	
	If !PA7->(DbSeek(xFilial("PA7") + "007" + "001"))
		RecLock("PA7",.T.)
		PA7->PA7_FILIAL := xFilial("PA7")
		PA7->PA7_CODIGO := "007"
		PA7->PA7_DESCR  := "INCENTIVO ACADÊMICO"
		PA7->PA7_CODSUB := "001"
		PA7->PA7_DESSUB := "INCENTIVO ACADÊMICO"
		PA7->(MsUnLock())
	EndIf
	
	If !PA7->(DbSeek(xFilial("PA7") + "008" + "001"))
		RecLock("PA7",.T.)
		PA7->PA7_FILIAL := xFilial("PA7")
		PA7->PA7_CODIGO := "008"
		PA7->PA7_DESCR  := "FÉRIAS"
		PA7->PA7_CODSUB := "001"
		PA7->PA7_DESSUB := "FÉRIAS"
		PA7->(MsUnLock())
	EndIf
	
	If !PA7->(DbSeek(xFilial("PA7") + "008" + "002"))
		RecLock("PA7", .T.)
		PA7->PA7_FILIAL := xFilial("PA7")
		PA7->PA7_CODIGO := "008"
		PA7->PA7_DESCR  := "FÉRIAS SEM APROVAÇÃO"
		PA7->PA7_CODSUB := "002"
		PA7->PA7_DESSUB := "FÉRIAS SEM APROVAÇÃO"
		PA7->(MsUnLock())
	EndIf	
	
	RestArea(aArea)
	
Return

/*
{Protheus.doc} F0800102()
Atualização da Tabela RCB e RCC
@Author     Bruno de Oliveira
@Since      02/03/2017
@Version    P12.1.07
@Project    MAN0000007423042_EF_001
*/
User Function F0800102()
	
	DbSelectArea("RCB")
	RCB->(DbSetOrder(1))
	
	If !RCB->(DbSeek(xFilial("RCB") + "U010"))
		
		RecLock("RCB", .T.)
		RCB->RCB_FILIAL := FwxFilial("RCB")
		RCB->RCB_CODIGO := 'U010'
		RCB->RCB_DESC   := 'TIPO MOVIMENTACAO DE PESSOA'
		RCB->RCB_ORDEM  := '01'
		RCB->RCB_CAMPOS := 'CODIGO'
		RCB->RCB_DESCPO := 'Codigo do Tipo de Mov.Pes'
		RCB->RCB_TIPO   := 'C'
		RCB->RCB_TAMAN  := 3
		RCB->RCB_DECIMA := 0
		RCB->RCB_PICTUR := '@!'
		RCB->RCB_VALID  := ''
		RCB->RCB_PESQ   := '1'
		RCB->RCB_SHOWMA := 'N'
		RCB->RCB_MODULO := '1'
		RCB->(MsUnlock())
		
		RecLock("RCB", .T.)
		RCB->RCB_FILIAL := FwxFilial("RCB")
		RCB->RCB_CODIGO := 'U010'
		RCB->RCB_DESC   := 'TIPO MOVIMENTACAO DE PESSOA'
		RCB->RCB_ORDEM  := '02'
		RCB->RCB_CAMPOS := 'DESCRICAO'
		RCB->RCB_DESCPO := 'Descricao do Tipo Mov.Pes'
		RCB->RCB_TIPO   := 'C'
		RCB->RCB_TAMAN  := 100
		RCB->RCB_DECIMA := 0
		RCB->RCB_PICTUR := '@!'
		RCB->RCB_VALID  := ''
		RCB->RCB_PESQ   := '2'
		RCB->RCB_SHOWMA := 'N'
		RCB->RCB_MODULO := '1'
		RCB->(MsUnlock())
		
	EndIf
	
Return

/*
{Protheus.doc} F0800103()
Job verificar de códigos de desligamento e mov.pessoal
@Author     Bruno de Oliveira
@Since      02/03/2017
@Version    P12.1.07
@Project    MAN0000007423042_EF_001
*/
User Function F0800103(aParam)
	
	Local cCodMov := ""
	Local cDesMov := ""
	Local cEmpIni := IIF(ValType(aParam) == "A", aParam[1], cEmpAnt)
	Local cFilIni := IIF(ValType(aParam) == "A", aParam[2], cFilAnt)
	
	RpcSetEnv(cEmpIni,cFilIni)
	
	DbSelectArea("PA7")
	PA7->(DbSetOrder(1))
	
	DbSelectArea("RCC")
	RCC->(DbSetOrder(1))
	If RCC->(DbSeek(xFilial("RCC") + "U006")) //Desligamento
		While RCC->(!EOF()) .AND. RCC->(RCC_FILIAL + RCC_CODIGO) == xFilial("RCC") + "U006"
			cCodMov := SubStr(RCC->RCC_CONTEU,1,3)
			cDesMov := SubStr(RCC->RCC_CONTEU,4)
			If !PA7->(DbSeek(xFilial("PA7") + "005" + cCodMov))
				RecLock("PA7",.T.)
				PA7->PA7_FILIAL := xFilial("PA7")
				PA7->PA7_CODIGO := "005"
				PA7->PA7_DESCR  := "DESLIGAMENTO"
				PA7->PA7_CODSUB := cCodMov
				PA7->PA7_DESSUB := cDesMov
				PA7->(MsUnLock())
			Else
				If UPPER(Alltrim(PA7->PA7_DESSUB)) != UPPER(Alltrim(cDesMov))
					RecLock("PA7",.F.)
					PA7->PA7_DESSUB := cDesMov
					PA7->(MsUnLock())
					
					DbSelectArea("PAB")
					PAB->(DbSetOrder(2))
					If PAB->(DbSeek(xFilial("PAB") + "005" + cCodMov))
						RecLock("PAB",.F.)
						PAB->PAB_GRPDES := cDesMov
						PAB->(MsUnLock())
					EndIf 
				EndIf
			EndIf
			RCC->(DbSkip())
		End
	EndIf
	
	If RCC->(DbSeek(xFilial("RCC") + "U010")) //Movimento de Pessoal
		While RCC->(!EOF()) .AND. RCC->(RCC_FILIAL + RCC_CODIGO) == xFilial("RCC") + "U010"
			cCodMov := SubStr(RCC->RCC_CONTEU,1,3)
			cDesMov := SubStr(RCC->RCC_CONTEU,4)
			PA7->(DbSetOrder(1))
			If !PA7->(DbSeek(xFilial("PA7") + "006" + cCodMov))
				RecLock("PA7",.T.)
				PA7->PA7_FILIAL := xFilial("PA7")
				PA7->PA7_CODIGO := "006"
				PA7->PA7_DESCR  := "MVT.DE PESSOAL"
				PA7->PA7_CODSUB := cCodMov
				PA7->PA7_DESSUB := cDesMov
				PA7->(MsUnLock())
			Else
				If UPPER(Alltrim(PA7->PA7_DESSUB)) != UPPER(Alltrim(cDesMov))
					RecLock("PA7",.F.)
					PA7->PA7_DESSUB := cDesMov
					PA7->(MsUnLock())
					
					DbSelectArea("PAB")
					PAB->(DbSetOrder(2))
					If PAB->(DbSeek(xFilial("PAB") + "005" + cCodMov))
						RecLock("PAB",.F.)
						PAB->PAB_GRPDES := cDesMov
						PAB->(MsUnLock())
					EndIf
				EndIf				
			EndIf
			RCC->(DbSkip())
		End
	EndIf
	
	RpcClearEnv() 
	
Return