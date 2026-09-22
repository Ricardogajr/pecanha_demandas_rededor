#Include 'Protheus.ch'

/*
{Protheus.doc} F0300102()
Alocação de Participantes para visões
@Author     Bruno de Oliveira
@Since      23/12/2016
@Version    P12.1.07
@Project    MAN00000463701_EF_001
*/
User Function F0300102()

Local aArea     := GetArea()
Local cPerg     := "FSW0300102"
Local aSays     := {}
Local aButtons  := {}
Local nOpca     := 0
Local cCadastro := OemToAnsi("Processo de Alocação")

Pergunte(cPerg,.F.)
			
AAdd(aSays,OemToAnsi("Este programa realiza o processo de alocação com base na visão de origem."))
	
AAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T.)  } } )
AAdd(aButtons, { 1,.T.,{|o| nOpca := 1,If((MsgYesNo("Confirma configuração dos parâmetros?","Atenção")),FechaBatch(),nOpca:=0) }} )
AAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )
		
FormBatch(cCadastro,aSays,aButtons)

If nOpca == 1
	If !Empty(MV_PAR01) .AND. !Empty(MV_PAR02)
		If MV_PAR01 == MV_PAR02
			Help(,,'F0300302',,"As visões não podem ter o mesmo código",1,0)
		Else
			Processa( {|| FSRealAloc(MV_PAR01,MV_PAR02) }, "Aguarde", "Verificando alocação",.F.)
		EndIf		
	Else
		Help(,,'F0300302',,"Necessário preencher os parâmetros",1,0)
	EndIf	
EndIf

RestArea(aArea)

Return

/*
{Protheus.doc} FSRealAloc()
Realiza as alocações para a visão
@Author     Bruno de Oliveira
@Since      23/12/2016
@Version    P12.1.07
@Project    MAN00000463701_EF_001
@Param		cVisao, caracter, código da visão
@Param		cVisDest, caracter, código da visão de vínculo
*/
Static Function FSRealAloc(cVisao,cVisDest)

Local aArea := GetArea()
Local nTpVis := 0

DbSelectArea("RDK")
RDK->(DbSetOrder(1))
If RDK->(DbSeek(xFilial("RDK") + cVisao))
	If RDK->RDK_HIERAR == "1"
		nTpVis := 2 //Organizacional
	Else
		nTpVis := 1 //Comunicação
	EndIf	
EndIf

DbSelectArea("RD4")
RD4->(DbSetOrder(1))
ProcRegua(RD4->(RecCount()))
If RD4->(DbSeek(xFilial("RD4") + cVisao))

	While !RD4->(EOF()) .AND. RD4->(RD4_FILIAL + RD4_CODIGO) == xFilial("RD4") + cVisao
		
		IncProc()
		If nTpVis == 1 //Posto
			FSAlocPost(RD4_CODIGO,RD4_ITEM,RD4_EMPIDE,RD4_FILIDE,RD4_CODIDE,cVisDest)
		ElseIf nTpVis == 2 //Departamento
			FSAlocDpto(RD4_CODIGO,RD4_ITEM,RD4_EMPIDE,RD4_FILIDE,RD4_CODIDE,cVisDest)
		EndIf
		
	RD4->(DbSkip())
	End

EndIf

RestArea(aArea)

Return

/*
{Protheus.doc} FSAlocPost()
Posiciona nos postos para alocação.
@Author     Bruno de Oliveira
@Since      23/12/2016
@Version    P12.1.07
@Project    MAN00000463701_EF_001
@Param		cVisao, caracter, código da visão
@Param		cItem, caracter, item da visão
@Param		cEmpIde, caracter, empresa do identificador
@Param		cFilIde, caracter, filial do identificador
@Param		cCodIde, cacacter, codigo do identificador
@Param		cVisDest, caracter, código da visão de vínculo
*/
Static Function FSAlocPost(cVisao,cItem,cEmpIde,cFilIde,cCodIde,cVisDest)

	Local aArea := GetArea()
	
	DbSelectArea("RCX")
	RCX->(DbSetOrder(1))
	If RCX->(DbSeek(cFilIde + cCodIde))
		While !RCX->(EOF()) .AND. RCX->(RCX_FILIAL + RCX_POSTO) == cFilIde + cCodIde
		
			If RCX->RCX_DTINI <= dDatabase .AND. (RCX->RCX_DTFIM >= dDatabase .OR. Empty(RCX->RCX_DTFIM)) .AND. RCX->RCX_SUBST == "2" //Não Substituto
				
				If RCX->RCX_TIPOCU == "1" //Funcionário
				
					DbSelectArea("SRA")
					SRA->(DbSetOrder(1))	//RA_FILIAL + RA_MAT
					If SRA->(DbSeek(RCX->(RCX_FILFUN + RCX_MATFUN)))
					
						DbSelectArea("RD0")
						RD0->(DbSetOrder(6))	//RD0_FILIAL + RD0_CIC
						If RD0->(DbSeek(xFilial("RD0") + SRA->RA_CIC))
						
							DbSelectArea("RDE")
							RDE->(DbSetOrder(3)) //RDE_FILIAL + RDE_CODPAR + RDE_CODVIS + RDE_ITEVIS	
							If !RDE->(DbSeek(xFilial("RDE") + RD0->RD0_CODIGO + cVisDest + cItem))
								RecLock("RDE",.T.)
								RDE->RDE_FILIAL	:= xFilial("RDE")
								RDE->RDE_CODPAR	:= RD0->RD0_CODIGO
								RDE->RDE_CODVIS	:= cVisDest
								RDE->RDE_ITEVIS	:= cItem
								RDE->RDE_DATA	:= dDatabase
								RDE->RDE_STATUS	:= "1"
							Else
								If RDE->RDE_STATUS == "2"
									RecLock("RDE",.F.)
									RDE->RDE_STATUS	:= "1"
									RDE->(MsUnLock())
								EndIf
							EndIf			
						
						EndIf
					
					EndIf
				
				EndIf
				
			EndIf
		
		RCX->(DbSkip())
		End
	EndIf
	
	RestArea(aArea)

Return

/*
{Protheus.doc} FSAlocDpto()
Posiciona nos departamentos para buscar os postos.
@Author     Bruno de Oliveira
@Since      23/12/2016
@Version    P12.1.07
@Project    MAN00000463701_EF_001
@Param		cVisao, caracter, código da visão
@Param		cItem, caracter, item da visão
@Param		cEmpIde, caracter, empresa do identificador
@Param		cFilIde, caracter, filial do identificador
@Param		cCodIde, cacacter, codigo do identificador
@Param		cVisDest, caracter, código da visão de vínculo
*/
Static Function FSAlocDpto(cVisao,cItem,cEmpIde,cFilIde,cCodIde,cVisDest)

	Local aArea := GetArea()
	Local aPost	:= {}
	Local nX := 0
	
	DbSelectArea("RCL")
	RCL->(DbSetOrder(1))
	If RCL->(DbSeek(cFilIde + cCodIde))
	
		While !RCL->(EOF()) .AND. RCL->(RCL_FILIAL + RCL_DEPTO) == cFilIde + cCodIde
		
			If RCL->RCL_STATUS == "2"
				AAdd(aPost,{RCL->RCL_FILIAL,RCL->RCL_POSTO})
			EndIf
		
		RCL->(DbSkip())
		End 
		
	EndIf
	
	For nX := 1 to Len(aPost)
		FSAlocPost(cVisao,cItem,cEmpIde,aPost[nX][1],aPost[nX][2],cVisDest)	
	Next nX
	
	RestArea(aArea)
	
Return