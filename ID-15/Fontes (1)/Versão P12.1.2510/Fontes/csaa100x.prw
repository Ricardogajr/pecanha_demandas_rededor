#include 'protheus.ch'
#include 'parmtype.ch'
// ###########################################################################################
// Projeto:
// Modulo :
// Função : 
// -----------+-------------------+-----------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+-----------------------------------------------------------
// 22/06/2017 | Miqueias Dernier  | Ponto de entrada único para a manutenção de departamentos 
//------------|-------------------|-----------------------------------------------------------
//            |                   | Replica inclusões e exclusões de departamentos para todas 
//            |                   |as filiais.
// -----------+-------------------+-----------------------------------------------------------
user function CSAA100()
Local xRet := Processa({|| RunProc()},'Processando Filiais','Aguarde...')

Return xRet

Static Function RunProc()
Local lInclui := INCLUI
Local lExclui := !(ALTERA .Or. INCLUI)
Local lRet := .T.
Local aSM0 := FWLoadSM0()
Local nI,nJ
Local lExecuta := .T.
Local aRotAuto := {}
Local cFilBkp := cFilAnt
Local _cDepto := M->QB_DEPTO
Local nOpc
Private lMsErroAuto

If Type('__lExec')=='L'
	lExecuta := __lExec
Else
	__lExec := .F.
EndIf

ProcRegua(Len(aSM0))
If lExecuta
	If lInclui .Or. lExclui
		nOpc := If(lInclui,3,5)
		dbSelectArea('SQB')
		aStruct := dbStruct()
		For nJ:=1 To Len(aStruct)
			If !("|"+AllTrim(aStruct[nJ,1])+"|" $ '|QB_FILIAL|')
				AAdd(aRotAuto,{AllTrim(aStruct[nJ,1]) 	,M->(&(aStruct[nJ,1]))             ,Nil})
			EndIf
		Next
		
		For nI:=1 To Len(aSM0)
			IncProc()
			If cEmpAnt == aSM0[nI,1] .And. !(cFilBkp == aSM0[nI,2])
				cFilAnt := aSM0[nI,2]
				lMsErroAuto := .F.
				dbSelectArea('SQB')
				dbSetOrder(1)
				If !dbSeek(XFilial('SQB')+_cDepto)
					If nOpc = 5
						loop
					EndIf
				Else
					If nOpc=3
						loop
					EndIf
				EndIf
				MSExecAuto({|x,w,y,z| CSAA100(x,w,y,z)},,,aRotAuto, nOpc)
				If lMsErroAuto
					If !(IsBlind())
						MostraErro()
					EndIf
				EndIf
			EndIf
		Next
	EndIf
EndIf
cFilAnt := cFilBkp
return lRet
