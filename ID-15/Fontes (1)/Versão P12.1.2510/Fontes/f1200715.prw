#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} F1200715
Ajusta Flag da Solicitação de Compra na exclusão da medição.
@Author		Paulo Krüger
@Since		06/06/2017
@Version	P12.7
@param		nOpc  - Opcao de operação
@Project    MAN0000007423046
@Return	lRet
/*/

User Function F1200715(nOpc)

Local nI		:=	0
Local aArea		:=  GetArea()
Local cFilOri	:=	xFilial('CND')
Local cAlias01	:=	''
Local cNumMed	:=	''
Default nOpc 	:=	0

cFilOri		:=	xFilial('CND')
cNumMed		:=	M->CND_NUMMED
nColItmMed	:=	aScan(aHeader,{|x| x[2] == 'CNE_ITEM  '})

If nOpc == 5

	For nI := 01 To Len(aCols)
		If aCols[nI][Len(aHeader) + 01] == .F.
			
			cAlias01 := GetNextAlias()
			
			BeginSql Alias cAlias01
			SELECT	SC1.R_E_C_N_O_ NUMREC
			FROM	%Table:SC1% SC1
			WHERE 		SC1.%notDel%
					AND SC1.C1_FILIAL	= %Exp:cFilOri%
					AND SC1.C1_XNUMMED	= %Exp:cNumMed%
					AND	SC1.C1_XITEMED	= %Exp:aCols[nI][nColItmMed]%
			EndSql
			
			Do While !(cAlias01)->(Eof())
				SC1->(DbGoTo((cAlias01)->NUMREC))
				Reclock('SC1',.F.)
				SC1->C1_FLAGGCT	:=	''
				SC1->C1_XNUMMED	:=	''
				SC1->C1_XITEMED	:=	''
				SC1->C1_XITMED	:=	'MEDICAO EXCLUIDA'
				SC1->C1_XOBSMED	:=	'MEDICAO EXCLUIDA'
				SC1->C1_PEDIDO  :=	''
				SC1->C1_ITEMPED :=	''
				SC1->(MsUnLock()) 
				(cAlias01)->(DbSkip())
			EndDo
			
			(cAlias01)->(DbCloseArea())

		EndIf
	Next nI
EndIf
Return