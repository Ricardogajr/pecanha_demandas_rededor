#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH"
#include 'FILEIO.ch'
/*
{Protheus.doc} F0300601()
Atualização da tabela RCB
@Author     Rogerio Candisani
@Since      14/10/2016
@Version    P12.7
@Project    MAN00000463701_EF_006
@Return
/*/
User Function F0300601()
	Local nFil
	Local nTamFil    := Len(cFilAnt)
	Local nTamFilRCB := Len(AllTrim(xFilial("RCB")))
	Local aTodasFil  := {}
	Local aFilRCB    := {}
	Local cFilRCB    := cFilAnt
	Local nTamFilRC2 := Len(AllTrim(xFilial("RC2")))
	Local aFilRC2    := {}
	Local cFilRC2    := cFilAnt
	Local nTamFilRC3 := Len(AllTrim(xFilial("RC3")))
	Local aFilRC3    := {}
	Local cFilSRM    := cFilAnt
	Local nTamFilSRM := Len(AllTrim(xFilial("SRM")))
	Local aFilSRM    := {}
	Local cFilRC3    := cFilAnt
	Local nTamFilRCA := Len(AllTrim(xFilial("RCA")))
	Local aFilRCA    := {}
	Local cFilRCA    := cFilAnt
	
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
		
		If !RCB->(DbSeek(IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil]) + "U002"))
			
			
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U002'
			RCB->RCB_DESC   := 'TABELA DE COPARTICIPACAO'
			RCB->RCB_ORDEM  := '01'
			RCB->RCB_CAMPOS := 'COD_DEV'
			RCB->RCB_DESCPO := 'Cod.Verba Dev. Excedente'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 3// N
			RCB->RCB_DECIMA := 0// N
			RCB->RCB_PICTUR := '@!'
			RCB->RCB_PADRAO := 'SRV'
			RCB->RCB_PESQ   := '1'
			//RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())
			
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U002'
			RCB->RCB_DESC   := 'TABELA DE COPARTICIPACAO'
			RCB->RCB_ORDEM  := '02'
			RCB->RCB_CAMPOS := 'LIMDESC'
			RCB->RCB_DESCPO := 'Limite Desconto'
			RCB->RCB_TIPO   := 'N'
			RCB->RCB_TAMAN  := 5// N
			RCB->RCB_DECIMA := 2// N
			RCB->RCB_PICTUR := '@E 99.99'
			RCB->RCB_PADRAO := ''
			RCB->RCB_PESQ   := '1'
			//RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())
			
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U002'
			RCB->RCB_DESC   := 'TABELA DE COPARTICIPACAO'
			RCB->RCB_ORDEM  := '03'
			RCB->RCB_CAMPOS := 'COP_ASM'
			RCB->RCB_DESCPO := 'Cod. Copart. Ass. Medica '
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 3// N
			RCB->RCB_DECIMA := 0// N
			RCB->RCB_PICTUR := '@!'
			RCB->RCB_PADRAO := 'SRV'
			RCB->RCB_PESQ   := '1'
			//RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())
			
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U002'
			RCB->RCB_DESC   := 'TABELA DE COPARTICIPACAO'
			RCB->RCB_ORDEM  := '04'
			RCB->RCB_CAMPOS := 'COP_ODO'
			RCB->RCB_DESCPO := 'Cod. Copart. Ass. Odontol'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 3// N
			RCB->RCB_DECIMA := 0// N
			RCB->RCB_PICTUR := '@!'
			RCB->RCB_PADRAO := 'SRV'
			RCB->RCB_PESQ   := '1'
			//RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())
			
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U002'
			RCB->RCB_DESC   := 'TABELA DE COPARTICIPACAO'
			RCB->RCB_ORDEM  := '05'
			RCB->RCB_CAMPOS := 'COD_DES'
			RCB->RCB_DESCPO := 'Cod Verba de Desconto'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 3// N
			RCB->RCB_DECIMA := 0// N
			RCB->RCB_PICTUR := '@!'
			RCB->RCB_PADRAO := 'SRV'
			RCB->RCB_PESQ   := '1'
			//RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())
			
			RCB->(MsUnlock())
			RecLock("RCB", .T.)
			RCB->RCB_FILIAL := IIF(Empty(xFilial("RCB")),xFilial("RCB"),aFilRCB[nFil])
			RCB->RCB_CODIGO := 'U002'
			RCB->RCB_DESC   := 'TABELA DE COPARTICIPACAO'
			RCB->RCB_ORDEM  := '06'
			RCB->RCB_CAMPOS := 'COD_REE'
			RCB->RCB_DESCPO := 'Cod. Verba Reembolso'
			RCB->RCB_TIPO   := 'C'
			RCB->RCB_TAMAN  := 3// N
			RCB->RCB_DECIMA := 0// N
			RCB->RCB_PICTUR := '@!'
			RCB->RCB_PADRAO := 'SRV'
			RCB->RCB_PESQ   := '1'
			//RCB->RCB_MODULO := '1'
			RCB->(MsUnlock())
			
			
		EndIf
	Next
	
	If Empty(xFilial("RC2"))
		aFilRC2 := {cFilAnt}
	Else
		aTodasFil := FWAllFilial(cEmpAnt,,,.F.)
		For nFil := 1 To Len(aTodasFil)
			cFilRC2 := PadR(Left(aTodasFil[nFil],nTamFilRC2),nTamFil)
			If ( AScan(aFilRCB,{|x| x == cFilRC2 }) == 0 )
				AAdd(aFilRC2,cFilRC2)
			EndIf
		Next
	EndIf
	
	For nFil := 1 To Len(aFilRC2)
		RC2->(DbSetOrder(1))
		
		If !RC2->(DbSeek(IIF(Empty(xFilial("RC2")),xFilial("RC2"),aFilRC2[nFil]) + "U_" + "FWCALPLA       "))
			
			
			RecLock("RC2", .T.)
			RC2->RC2_FILIAL := IIF(Empty(xFilial("RC2")),xFilial("RC2"),aFilRC2[nFil])
			RC2->RC2_ORIGEM	:= "U_"
			RC2->RC2_CODIGO := 'FWCALPLA       '
			RC2->RC2_DESC   := 'CALCULA PLANO DE SAUDE'
			RC2->RC2_RETURN := ''
			RC2->RC2_DESC2  := ''
			RC2->RC2_CODOBS := ''
			RC2->RC2_DESC3  := ''
			RC2->RC2_VERSAO := ''
			RC2->RC2_RECOMP := '2'
			RC2->RC2_MODELO := '1'
			
			RC2->(MsUnlock())
		EndIf
		If !RC2->(DbSeek(IIF(Empty(xFilial("RC2")),xFilial("RC2"),aFilRC2[nFil]) + "U_" + "FWCOPART       "))
			
			
			RecLock("RC2", .T.)
			RC2->RC2_FILIAL := IIF(Empty(xFilial("RC2")),xFilial("RC2"),aFilRC2[nFil])
			RC2->RC2_ORIGEM	:= "U_"
			RC2->RC2_CODIGO := 'FWCOPART       '
			RC2->RC2_DESC   := 'CALC. COPART. NA FOLHA DEVIDO LIMITE'
			RC2->RC2_RETURN := ''
			RC2->RC2_DESC2  := ''
			RC2->RC2_CODOBS := ''
			RC2->RC2_DESC3  := ''
			RC2->RC2_VERSAO := ''
			RC2->RC2_RECOMP := '2'
			RC2->RC2_MODELO := '1'
			
			RC2->(MsUnlock())
			
		EndIf
		
		If !RC2->(DbSeek(IIF(Empty(xFilial("RC2")),xFilial("RC2"),aFilRC2[nFil]) + "U_" + "FWCHKTAB       ")) 
		     
			RecLock("RC2", .T.)
			RC2->RC2_FILIAL := IIF(Empty(xFilial("RC2")),xFilial("RC2"),aFilRC2[nFil])
			RC2->RC2_ORIGEM	:= "U_"
			RC2->RC2_CODIGO := 'FWCHKTAB       '
			RC2->RC2_DESC   := 'VERIF. SE CADASTRADA TAB DE CALCULO U002'
			RC2->RC2_RETURN := ''
			RC2->RC2_DESC2  := ''
			RC2->RC2_CODOBS := ''
			RC2->RC2_DESC3  := ''
			RC2->RC2_VERSAO := ''
			RC2->RC2_RECOMP := '2'
			RC2->RC2_MODELO := '1'
	
			RC2->(MsUnlock())
			
		EndIf
	Next
	
	If Empty(xFilial("RC3"))
		aFilRC3 := {cFilAnt}
	Else
		aTodasFil := FWAllFilial(cEmpAnt,,,.F.)
		For nFil := 1 To Len(aTodasFil)
			cFilRC3 := PadR(Left(aTodasFil[nFil],nTamFilRC3),nTamFil)
			If ( AScan(aFilRCB,{|x| x == cFilRC3 }) == 0 )
				AAdd(aFilRC3,cFilRC3)
			EndIf
		Next
	EndIf
	
	For nFil := 1 To Len(aFilRC3)
		RC3->(DbSetOrder(1))
		If !RC3->(DbSeek(IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil]) + "U_" + "FWCALPLA       "))
			
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'P_SALINC'
			RC3->RC3_SEQFOR := '000001'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.CON.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'P_SALINC'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK1'
			RC3->RC3_RESOU2 := 'PMSTASK1'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'FSALINC(@NSALARIO,@NSALMES,@SALHORA,@SALDIA)'
			RC3->RC3_SEQFOR := '000002'
			RC3->RC3_SEQPAI := '000001'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'fSalInc(@nSalario,@nSalMes,@SalHora,@SalDia)'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := '!P_SALINC'
			RC3->RC3_SEQFOR := '000003'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.CON.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := '!P_SALINC'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK1'
			RC3->RC3_RESOU2 := 'PMSTASK1'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'FSALARIO(@NSALARIO,@SALHORA,@SALDIA,@NSALMES,"A")'
			RC3->RC3_SEQFOR := '000004'
			RC3->RC3_SEQPAI := '000003'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'fSalario(@nSalario,@SalHora,@SalDia,@nSalMes,"A")'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'RHK->(DBGOTOP())'
			RC3->RC3_SEQFOR := '000005'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'RHK->(dbGoTop())'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'RHK->(DbSeek( SRA->RA_FILIAL + SRA->RA_MAT, .F. ))'
			RC3->RC3_SEQFOR := '000006'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'RHK->(DbSeek( SRA->RA_FILIAL + SRA->RA_MAT, .F. ))'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'CCODFORANT := ""  '
			RC3->RC3_SEQFOR := '000007'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'cCodForAnt'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := '" "'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'CTPFORNANT := "" '
			RC3->RC3_SEQFOR := '000008'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'cTpFornAnt'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := '" "'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'CTPPLANO := ""  '
			RC3->RC3_SEQFOR := '000009'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'cTpPlano'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := '" "'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'CCODPLANO := ""'
			RC3->RC3_SEQFOR := '000010'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'cCodPlano'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := '" "'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'ALOG := {}'
			RC3->RC3_SEQFOR := '000011'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'ALOG'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := '{}'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'AAdd( aLog, {} )'
			RC3->RC3_SEQFOR := '000012'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'AAdd( aLog, {} )'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'AAdd( aLog, {} )'
			RC3->RC3_SEQFOR := '000013'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'AAdd( aLog, {} )'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'AAdd( aLog, {} )'
			RC3->RC3_SEQFOR := '000014'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'AAdd( aLog, {} )'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'AAdd( aLog, {} )'
			RC3->RC3_SEQFOR := '000015'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'AAdd( aLog, {} )'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'AAdd( aLog, {} )'
			RC3->RC3_SEQFOR := '000016'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'AAdd( aLog, {} )'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'AAdd( aLog, {} )'
			RC3->RC3_SEQFOR := '000017'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'AAdd( aLog, {} )'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'RHK->( !Eof() ) .and. RHK->RHK_FILIAL + RHK->RHK_MAT == SR'
			RC3->RC3_SEQFOR := '000018'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.ENQ.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'RHK->( !Eof() ) .and. RHK->RHK_FILIAL + RHK->RHK_MAT == SRA->RA_FILIAL + SRA->RA_MAT'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK3'
			RC3->RC3_RESOU2 := 'PMSTASK3'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'cAnoMesInT := Substr(RHK->RHK_PERINI,3,4) + Substr(RHK->RHK'
			RC3->RC3_SEQFOR := '000019'
			RC3->RC3_SEQPAI := '000018'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'cAnoMesInT'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'Substr(RHK->RHK_PERINI,3,4) + Substr(RHK->RHK_PERINI,1,2)'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'cAnoMesFiT := Substr(RHK->RHK_PERFIM,3,4) + Substr(RHK->RHK_'
			RC3->RC3_SEQFOR := '000020'
			RC3->RC3_SEQPAI := '000018'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'cAnoMesFiT '
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'Substr(RHK->RHK_PERFIM,3,4) + Substr(RHK->RHK_PERFIM,1,2)'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'RHK->RHK_TPFORN == cTpFornAnt .and. RHK->RHK_CODFOR == cCo'
			RC3->RC3_SEQFOR := '000021'
			RC3->RC3_SEQPAI := '000018'
			RC3->RC3_TIPO	:= '.CON.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'RHK->RHK_TPFORN == cTpFornAnt .and. RHK->RHK_CODFOR == cCodForAnt .and. RHK->RHK_TPPLAN == cTpPlano .AND. RHK->RHK_PLANO == cCodPlano'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK1'
			RC3->RC3_RESOU2 := 'PMSTASK1'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'Len( aLog[3] ) == 0 .or. AScan( aLog[3], { |x| x == Substr '
			RC3->RC3_SEQFOR := '000022'
			RC3->RC3_SEQPAI := '000021'
			RC3->RC3_TIPO	:= '.CON.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'Len( aLog[3] ) == 0 .or. AScan( aLog[3], { |x| x == Substr( SRA->RA_FILIAL + "  " + SRA->RA_MAT + " - " + SRA->RA_NOME, 1, 45 ) } ) == 0'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK1'
			RC3->RC3_RESOU2 := 'PMSTASK1'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'Len( aLog[3] ) == 0 .or. AScan( aLog[3], { |x| x == Substr '
			RC3->RC3_SEQFOR := '000023'
			RC3->RC3_SEQPAI := '000022'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'AAdd( aLog[3], Substr( SRA->RA_FILIAL + "  " + SRA->RA_MAT + " - " + SRA->RA_NOME, 1, 45 ) )'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := '!(RHK->RHK_TPFORN==cTpFornAnt .and. RHK->RHK_CODFOR==cCodF'
			RC3->RC3_SEQFOR := '000024'
			RC3->RC3_SEQPAI := '000018'
			RC3->RC3_TIPO	:= '.CON.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := '!(RHK->RHK_TPFORN==cTpFornAnt .and. RHK->RHK_CODFOR==cCodForAnt .and. RHK->RHK_TPPLAN==cTpPlano .AND. RHK->RHK_PLANO==cCodPlano)'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK1'
			RC3->RC3_RESOU2 := 'PMSTASK1'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'CCODFORANT := RHK->RHK_CODFOR'
			RC3->RC3_SEQFOR := '000025'
			RC3->RC3_SEQPAI := '000024'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'cCodForAnt'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'RHK->RHK_CODFOR'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'CTPFORNANT	:= RHK->RHK_TPFORN'
			RC3->RC3_SEQFOR := '000026'
			RC3->RC3_SEQPAI := '000024'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'cTpFornAnt'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'RHK->RHK_TPFORN'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'CTPPLANO 	:= RHK->RHK_TPPLAN'
			RC3->RC3_SEQFOR := '000027'
			RC3->RC3_SEQPAI := '000024'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'cTpPlano'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'RHK->RHK_TPPLAN'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'CCODPLANO	:= RHK->RHK_PLANO'
			RC3->RC3_SEQFOR := '000028'
			RC3->RC3_SEQPAI := '000024'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'cCodPlano '
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'RHK->RHK_PLANO'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := '(( cAnoMesInT > cAnoMes ) .or. ( cAnoMesInT <= cAnoMes .an'
			RC3->RC3_SEQFOR := '000029'
			RC3->RC3_SEQPAI := '000018'
			RC3->RC3_TIPO	:= '.CON.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := '(( cAnoMesInT > cAnoMes ) .or. ( cAnoMesInT <= cAnoMes .and. ! Empty( cAnoMesFiT ) .and. cAnoMesFiT < cAnoMes ))'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK1'
			RC3->RC3_RESOU2 := 'PMSTASK1'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'RHK->(DBSKIP())'
			RC3->RC3_SEQFOR := '000030'
			RC3->RC3_SEQPAI := '000029'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'RHK->(DBSKIP())'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'RETORNEENQ()  '
			RC3->RC3_SEQFOR := '000031'
			RC3->RC3_SEQPAI := '000029'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'RETORNEENQ()'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'NVLRFUNC := 0'
			RC3->RC3_SEQFOR := '000032'
			RC3->RC3_SEQPAI := '000018'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'nVlrFunc := 0'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'NVLREMPR := 0'
			RC3->RC3_SEQFOR := '000033'
			RC3->RC3_SEQPAI := '000018'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'nVlrEmpr := 0  '
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'FCALCPLANO(1, RHK->RHK_TPFORN, RHK->RHK_CODFOR, RHK->RHK_TPP'
			RC3->RC3_SEQFOR := '000034'
			RC3->RC3_SEQPAI := '000018'
			RC3->RC3_TIPO	:= '.CON.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'fCalcPlano(1, RHK->RHK_TPFORN, RHK->RHK_CODFOR, RHK->RHK_TPPLAN, RHK->RHK_PLANO, dDataRef, SRA->RA_NASC, @nVlrFunc, @nVlrEmpr, SRA->RA_FILIAL )'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK1'
			RC3->RC3_RESOU2 := 'PMSTASK1'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'fGravaCalc("1", Space(GetSx3Cache("RHR_CODIGO", "X3_TAMANHO"'
			RC3->RC3_SEQFOR := '000035'
			RC3->RC3_SEQPAI := '000034'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'fGravaCalc("1", Space(GetSx3Cache("RHR_CODIGO", "X3_TAMANHO")), "1", RHK->RHK_TPFORN, RHK->RHK_CODFOR, RHK->RHK_TPPLAN, RHK->RHK_PLANO, RHK->RHK_PD, nVlrFunc, nVlrEmpr )'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'CPDDAGR := RHK->RHK_PDDAGR'
			RC3->RC3_SEQFOR := '000036'
			RC3->RC3_SEQPAI := '000018'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'cPDDAgr'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'RHK->RHK_PDDAGR'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'LFIRST := .T. '
			RC3->RC3_SEQFOR := '000037'
			RC3->RC3_SEQPAI := '000018'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'lFirst'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := '.T.'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'SRB->(DBSETORDER( RETORDEM( "SRB", "RB_FILIAL + RB_MAT" ) ))'
			RC3->RC3_SEQFOR := '000038'
			RC3->RC3_SEQPAI := '000018'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'SRB->(DBSETORDER( RETORDEM( "SRB", "RB_FILIAL + RB_MAT" ) ))'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'SRB->(DbSeek( SRA->RA_FILIAL + SRA->RA_MAT, .F. )	)'
			RC3->RC3_SEQFOR := '000039'
			RC3->RC3_SEQPAI := '000018'
			RC3->RC3_TIPO	:= '.CON.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'SRB->(DbSeek( SRA->RA_FILIAL + SRA->RA_MAT, .F. ))'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK1'
			RC3->RC3_RESOU2 := 'PMSTASK1'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'SRB->( !Eof() ) .and. SRB->RB_FILIAL + SRB->RB_MAT  == SRA '
			RC3->RC3_SEQFOR := '000040'
			RC3->RC3_SEQPAI := '000039'
			RC3->RC3_TIPO	:= '.ENQ.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'SRB->( !Eof() ) .and. SRB->RB_FILIAL + SRB->RB_MAT  == SRA->RA_FILIAL + SRA->RA_MAT'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK3'
			RC3->RC3_RESOU2 := 'PMSTASK3'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'LRBPLSAUDE :=  SRB->RB_PLSAUDE == "1"'
			RC3->RC3_SEQFOR := '000041'
			RC3->RC3_SEQPAI := '000040'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'lRbPlSaude'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'SRB->RB_PLSAUDE == "1"'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'RHL->(DBSETORDER( RETORDEM( "RHL", "RHL_FILIAL + RHL_MAT + RHL_T'
			RC3->RC3_SEQFOR := '000042'
			RC3->RC3_SEQPAI := '000040'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'RHL->(DbSetorder( RetOrdem( "RHL", "RHL_FILIAL + RHL_MAT + RHL_TPFORN + RHL_CODFOR + RHL_CODIGO" ) ))'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'lSeek := RHL->(DbSeek( SRA->RA_FILIAL + SRA->RA_MAT + RHK->R'
			RC3->RC3_SEQFOR := '000043'
			RC3->RC3_SEQPAI := '000040'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'lSeek'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'RHL->(DbSeek( SRA->RA_FILIAL + SRA->RA_MAT + RHK->RHK_TPFORN + RHK->RHK_CODFOR + SRB->RB_COD, .F. ) )'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'lSeek '
			RC3->RC3_SEQFOR := '000044'
			RC3->RC3_SEQPAI := '000040'
			RC3->RC3_TIPO	:= '.CON.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'lSeek '
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK1'
			RC3->RC3_RESOU2 := 'PMSTASK1'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := '((cAnoMes >= Substr(RHL->RHL_PERINI,3,4) + Substr(RHL->RHL_P  '
			RC3->RC3_SEQFOR := '000045'
			RC3->RC3_SEQPAI := '000044'
			RC3->RC3_TIPO	:= '.CON.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := '((cAnoMes >= Substr(RHL->RHL_PERINI,3,4) + Substr(RHL->RHL_PERINI,1,2)) .and. Empty( RHL->RHL_PERFIM) .or. (cAnoMes >= Substr(RHL->RHL_PERINI,3,4) + Substr(RHL->RHL_PERINI,1,2)) .and. (cAnoMes <=  Substr(RHL->RHL_PERFIM,3,4) + Substr(RHL->RHL_PERFIM,1,2)))'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK1'
			RC3->RC3_RESOU2 := 'PMSTASK1'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'NVLRFUNC := 0'
			RC3->RC3_SEQFOR := '000046'
			RC3->RC3_SEQPAI := '000045'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'nVlrFunc '
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := '0'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'NVLREMPR := 0  '
			RC3->RC3_SEQFOR := '000047'
			RC3->RC3_SEQPAI := '000045'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'nVlrEmpr'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := '0'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'LRET := FCALCPLANO(2, RHL->RHL_TPFORN, RHL->RHL_CODFOR, RHL-'
			RC3->RC3_SEQFOR := '000048'
			RC3->RC3_SEQPAI := '000045'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'lRet := fCalcPlano(2, RHL->RHL_TPFORN, RHL->RHL_CODFOR, RHL->RHL_TPPLAN, RHL->RHL_PLANO, dDataRef, SRB->RB_DTNASC, @nVlrFunc, @nVlrEmpr, SRA->RA_FILIAL )'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'lFirst .AND. CCODPLANO $ M_PLANPDEP'
			RC3->RC3_SEQFOR := '000049'
			RC3->RC3_SEQPAI := '000045'
			RC3->RC3_TIPO	:= '.CON.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'lFirst .AND. RHL->RHL_PLANO $ M_PLAPDEP'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK1'
			RC3->RC3_RESOU2 := 'PMSTASK1'
			
			RC3->(MsUnlock())
			
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'NVLREMPR :=   NVLREMPR + NVLRFUNC '
			RC3->RC3_SEQFOR := '000050'
			RC3->RC3_SEQPAI := '000049'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'nVlrEmpr '
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'nVlrEmpr + nVlrFunc '
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'NVLRFUNC := 0   '
			RC3->RC3_SEQFOR := '000051'
			RC3->RC3_SEQPAI := '000049'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'nVlrFunc'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := '0'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'LFIRST:=.F.'
			RC3->RC3_SEQFOR := '000052'
			RC3->RC3_SEQPAI := '000049'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'lFirst	'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := '.F.'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'lRet .and. Round(nVlrFunc,2) > 0 .or. Round(nVlrEmpr,2) > 0'
			RC3->RC3_SEQFOR := '000053'
			RC3->RC3_SEQPAI := '000045'
			RC3->RC3_TIPO	:= '.CON.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'lRet .and. Round(nVlrFunc,2) > 0 .or. Round(nVlrEmpr,2) > 0'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK1'
			RC3->RC3_RESOU2 := 'PMSTASK1'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'FGRAVACALC("2", RHL->RHL_CODIGO, "1", RHL->RHL_TPFORN, RHL->'
			RC3->RC3_SEQFOR := '000054'
			RC3->RC3_SEQPAI := '000053'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'fGravaCalc("2", RHL->RHL_CODIGO, "1", RHL->RHL_TPFORN, RHL->RHL_CODFOR, RHL->RHL_TPPLAN, RHL->RHL_PLANO, cPDDAgr, nVlrFunc, nVlrEmpr )'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'LRET .AND. ROUND(NVLRFUNC,2) <= 0 .AND. ROUND(NVLREMPR,2) <='
			RC3->RC3_SEQFOR := '000055'
			RC3->RC3_SEQPAI := '000045'
			RC3->RC3_TIPO	:= '.CON.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'lRet .and. Round(nVlrFunc,2) <= 0 .and. Round(nVlrEmpr,2) <= 0'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK1'
			RC3->RC3_RESOU2 := 'PMSTASK1'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'AAdd( aLog[2], Substr(SRA->RA_FILIAL + "  " + SRA->RA_MAT + '
			RC3->RC3_SEQFOR := '000056'
			RC3->RC3_SEQPAI := '000055'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'AAdd( aLog[2], Substr(SRA->RA_FILIAL + "  " + SRA->RA_MAT + "-" + SRA->RA_NOME,1,45) + " -  Codigo  - " + RHL->RHL_CODIGO )'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := '!lSeek .And. lRbPlSaude'
			RC3->RC3_SEQFOR := '000057'
			RC3->RC3_SEQPAI := '000040'
			RC3->RC3_TIPO	:= '.CON.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := '!lSeek .And. lRbPlSaude'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK1'
			RC3->RC3_RESOU2 := 'PMSTASK1'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'AAdd( aLog[2], Substr(SRA->RA_FILIAL + "  " + SRA->RA_MAT + '
			RC3->RC3_SEQFOR := '000058'
			RC3->RC3_SEQPAI := '000057'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'AAdd( aLog[2], Substr(SRA->RA_FILIAL + "  " + SRA->RA_MAT + "-" + SRA->RA_NOME,1,45) + " Dependente sem Plano Ativo" )'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'SRB->(DBSKIP()) '
			RC3->RC3_SEQFOR := '000059'
			RC3->RC3_SEQPAI := '000040'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'SRB->(dbSkip())'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'RHM->(DBSETORDER( RETORDEM( "RHM", "RHM_FILIAL + RHM_MAT + RHM_T'
			RC3->RC3_SEQFOR := '000060'
			RC3->RC3_SEQPAI := '000018'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'RHM->(DbSetorder( RetOrdem( "RHM", "RHM_FILIAL + RHM_MAT + RHM_TPFORN + RHM_CODFOR + RHM_CODIGO" ) )) '
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'RHM->(DBSETORDER( RETORDEM( "RHM", "RHM_FILIAL + RHM_MAT + RHM_T'
			RC3->RC3_SEQFOR := '000061'
			RC3->RC3_SEQPAI := '000018'
			RC3->RC3_TIPO	:= '.CON.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'RHM->(DbSeek( SRA->RA_FILIAL + SRA->RA_MAT + RHK->RHK_TPFORN + RHK->RHK_CODFOR, .F. ))'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK1'
			RC3->RC3_RESOU2 := 'PMSTASK1'
			
			RC3->(MsUnlock())
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'RHM->( !Eof() ) .and. RHM->RHM_FILIAL + RHM->RHM_MAT + RHM  '
			RC3->RC3_SEQFOR := '000062'
			RC3->RC3_SEQPAI := '000061'
			RC3->RC3_TIPO	:= '.ENQ.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'RHM->( !Eof() ) .and. RHM->RHM_FILIAL + RHM->RHM_MAT + RHM->RHM_TPFORN + RHM->RHM_CODFOR == SRA->RA_FILIAL + SRA->RA_MAT + RHK->RHK_TPFORN + RHK->RHK_CODFOR'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK3'
			RC3->RC3_RESOU2 := 'PMSTASK3'
			
			RC3->(MsUnlock())
			
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := '((cAnoMes >= Substr(RHM->RHM_PERINI,3,4) + Substr(RHM->RHM_P  '
			RC3->RC3_SEQFOR := '000063'
			RC3->RC3_SEQPAI := '000062'
			RC3->RC3_TIPO	:= '.CON.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := '((cAnoMes >= Substr(RHM->RHM_PERINI,3,4) + Substr(RHM->RHM_PERINI,1,2)) .and. Empty( RHM->RHM_PERFIM) .or. (cAnoMes >= Substr(RHM->RHM_PERINI,3,4) + Substr(RHM->RHM_PERINI,1,2)) .and. (cAnoMes <=  Substr(RHM->RHM_PERFIM,3,4) + Substr(RHM->RHM_PERFIM,1,2)))'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK1'
			RC3->RC3_RESOU2 := 'PMSTASK1'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'NVLRFUNC := 0  '
			RC3->RC3_SEQFOR := '000064'
			RC3->RC3_SEQPAI := '000063'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'nVlrFunc'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := '0'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'NVLREMPR := 0  '
			RC3->RC3_SEQFOR := '000065'
			RC3->RC3_SEQPAI := '000063'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'nVlrEmpr'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := '0'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'lRet := fCalcPlano(3, RHM->RHM_TPFORN, RHM->RHM_CODFOR, RHM '
			RC3->RC3_SEQFOR := '000066'
			RC3->RC3_SEQPAI := '000063'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'lRet'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'fCalcPlano(3, RHM->RHM_TPFORN, RHM->RHM_CODFOR, RHM->RHM_TPPLAN, RHM->RHM_PLANO, dDataRef, RHM->RHM_DTNASC, @nVlrFunc, @nVlrEmpr, SRA->RA_FILIAL )'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'lRet .and. Round(nVlrFunc,2) > 0 .or. Round(nVlrEmpr,2) >   '
			RC3->RC3_SEQFOR := '000067'
			RC3->RC3_SEQPAI := '000063'
			RC3->RC3_TIPO	:= '.CON.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'lRet .and. Round(nVlrFunc,2) > 0 .or. Round(nVlrEmpr,2) > 0'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK1'
			RC3->RC3_RESOU2 := 'PMSTASK1'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'fGravaCalc("3", RHM->RHM_CODIGO, "1", RHM->RHM_TPFORN, RHM->'
			RC3->RC3_SEQFOR := '000068'
			RC3->RC3_SEQPAI := '000067'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'fGravaCalc("3", RHM->RHM_CODIGO, "1", RHM->RHM_TPFORN, RHM->RHM_CODFOR, RHM->RHM_TPPLAN, RHM->RHM_PLANO, cPDDAgr, nVlrFunc, nVlrEmpr )'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'fGravaCalc("3", RHM->RHM_CODIGO, "1", RHM->RHM_TPFORN, RHM->'
			RC3->RC3_SEQFOR := '000069'
			RC3->RC3_SEQPAI := '000063'
			RC3->RC3_TIPO	:= '.CON.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'lRet .and. Round(nVlrFunc,2) <= 0 .and. Round(nVlrEmpr,2) <= 0'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK1'
			RC3->RC3_RESOU2 := 'PMSTASK1'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'AAdd( aLog[2], Substr(SRA->RA_FILIAL + "  " + SRA->RA_MAT + '
			RC3->RC3_SEQFOR := '000070'
			RC3->RC3_SEQPAI := '000069'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'AAdd( aLog[2], Substr(SRA->RA_FILIAL + "  " + SRA->RA_MAT + "-" + SRA->RA_NOME,1,45) + " - Codigo - " + RHM->RHM_CODIGO ) '
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'RHM->(DBSKIP())'
			RC3->RC3_SEQFOR := '000071'
			RC3->RC3_SEQPAI := '000062'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'RHM->(DbSkip())'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'RHK->(DBSKIP())'
			RC3->RC3_SEQFOR := '000072'
			RC3->RC3_SEQPAI := '000018'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'RHK->(dbSkip())'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'RHO->(DbSetorder( RetOrdem( "RHO", "RHO_FILIAL + RHO_MAT + RHO_C'
			RC3->RC3_SEQFOR := '000073'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'RHO->(DbSetorder( RetOrdem( "RHO", "RHO_FILIAL + RHO_MAT + RHO_COMPPG" ) ))'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'RHO->(DbSetorder( RetOrdem( "RHO", "RHO_FILIAL + RHO_MAT + RHO_C'
			RC3->RC3_SEQFOR := '000074'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.CON.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'RHO->(DbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cAnoMes, .F. ))'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK1'
			RC3->RC3_RESOU2 := 'PMSTASK1'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'RHO->( !Eof() ) .and. RHO->( RHO_FILIAL + RHO_MAT + RHO_CO  '
			RC3->RC3_SEQFOR := '000075'
			RC3->RC3_SEQPAI := '000074'
			RC3->RC3_TIPO	:= '.ENQ.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'RHO->( !Eof() ) .and. RHO->( RHO_FILIAL + RHO_MAT + RHO_COMPPG ) == SRA->( RA_FILIAL + RA_MAT ) + cAnoMes'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK3'
			RC3->RC3_RESOU2 := 'PMSTASK3'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'cTpLan := If( RHO->RHO_TPLAN == "1", "2", "3")   .CNT.      '
			RC3->RC3_SEQFOR := '000076'
			RC3->RC3_SEQPAI := '000075'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'cTpLan  '
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'If( RHO->RHO_TPLAN == "1", "2", "3")'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'fGravaCalc(RHO->RHO_ORIGEM, RHO->RHO_CODIGO, cTpLan, RHO->RH'
			RC3->RC3_SEQFOR := '000077'
			RC3->RC3_SEQPAI := '000075'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'fGravaCalc(RHO->RHO_ORIGEM, RHO->RHO_CODIGO, cTpLan, RHO->RHO_TPFORN, RHO->RHO_CODFOR, Space(GetSx3Cache("RHK_TPPLAN", "X3_TAMANHO")), Space(GetSx3Cache("RHK_PLANO", "X3_TAMANHO")), RHO->RHO_PD, RHO->RHO_VLRFUN, RHO->RHO_VLREMP, .T. )'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'LPLANOATIV == .F. '
			RC3->RC3_SEQFOR := '000078'
			RC3->RC3_SEQPAI := '000075'
			RC3->RC3_TIPO	:= '.CON.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'LPLANOATIV'
			RC3->RC3_OPERA2 := '=='
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := '.F.'
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK1'
			RC3->RC3_RESOU2 := 'PMSTASK1'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'Len( aLog[6] ) == 0 .OR. AScan( aLog[6], { |x| x == Substr  '
			RC3->RC3_SEQFOR := '000079'
			RC3->RC3_SEQPAI := '000078'
			RC3->RC3_TIPO	:= '.CON.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'Len( aLog[6] ) == 0 .OR. AScan( aLog[6], { |x| x == Substr( SRA->RA_FILIAL + "  " + SRA->RA_MAT + " - " + SRA->RA_NOME, 1, 45 ) } ) == 0'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK1'
			RC3->RC3_RESOU2 := 'PMSTASK1'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'AAdd( aLog[6], 	Substr( SRA->RA_FILIAL + "  " + SRA->RA_MAT '
			RC3->RC3_SEQFOR := '000080'
			RC3->RC3_SEQPAI := '000079'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'AAdd( aLog[6], 	Substr( SRA->RA_FILIAL + "  " + SRA->RA_MAT + " - " + SRA->RA_NOME , 1, 45 ) + "Fornecedor: " + RHO->RHO_CODFOR + " Data de Ocorrencia: " + DTOC(RHO->RHO_DTOCOR) + " Observacao: " + Substr(RHO->RHO_OBSERV,1,45))'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'RHO->(DbSkip())'
			RC3->RC3_SEQFOR := '000081'
			RC3->RC3_SEQPAI := '000075'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'RHO->(DbSkip())'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCALPLA       '
			RC3->RC3_DESCR  := 'FLOGPLS(ALOG)  '
			RC3->RC3_SEQFOR := '000082'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'fLogPLS(aLog)'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
		EndIf
		
		If !RC3->(DbSeek(IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil]) + "U_" + "FWCOPART       "))
	
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCOPART       '
			RC3->RC3_DESCR  := 'm_limcopa := (Ftabela("U002",1,5) / 100) '
			RC3->RC3_SEQFOR := '000001'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'm_limcopa'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := '(Ftabela("U002",1,5) / 100)'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCOPART       '
			RC3->RC3_DESCR  := 'm_valdev := 0.00'
			RC3->RC3_SEQFOR := '000002'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'm_valdev'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := '0.00'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCOPART       '
			RC3->RC3_DESCR  := 'M_TOTCOPA: := 0.00'
			RC3->RC3_SEQFOR := '000003'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'M_TOTCOPA'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := '0.00'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCOPART       '
			RC3->RC3_DESCR  := 'M_COPSALBS := salario '
			RC3->RC3_SEQFOR := '000004'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'M_COPSALBS'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'salario'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCOPART       '
			RC3->RC3_DESCR  := 'M_VALLIM := ROUND(M_COPSALBS * M_LIMCOPA,2) '
			RC3->RC3_SEQFOR := '000005'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'M_VALLIM'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'ROUND(M_COPSALBS * M_LIMCOPA,2)'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCOPART       '
			RC3->RC3_DESCR  := 'M_TOTCOPA := FBUSCAPD(M_VERCOPA,"V")  '
			RC3->RC3_SEQFOR := '000006'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'M_TOTCOPA'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'ABS(FBUSCAPD(M_VERCOPA,"V"))'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCOPART       '
			RC3->RC3_DESCR  := 'M_RESULT := M_TOTCOPA - M_VALLIM '
			RC3->RC3_SEQFOR := '000007'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'M_RESULT'
			RC3->RC3_OPERA1	:= ':='
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'M_TOTCOPA - M_VALLIM'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCOPART       '
			RC3->RC3_DESCR  := 'M_RESULT > 0.00 '
			RC3->RC3_SEQFOR := '000008'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.CON.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := 'M_RESULT > 0.00 '
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK1'
			RC3->RC3_RESOU2 := 'PMSTASK1'
			
			RC3->(MsUnlock())
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCOPART       '
			RC3->RC3_DESCR  := 'FGERAVERBA(FTABELA,"U002",1,4),M_RESULT,,,,,,,,,.T.)'
			RC3->RC3_SEQFOR := '000009'
			RC3->RC3_SEQPAI := '000008'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'FGERAVERBA((FTABELA("U002",1,4)),M_RESULT,,,,,,,,,.T.)'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())
		Endif
		If !RC3->(DbSeek(IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil]) + "U_" + "FWCHKTAB       ")) 
			
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCHKTAB       '
			RC3->RC3_DESCR  := '!DbSeek(XFILIAL("RCC") + "U002")'
			RC3->RC3_SEQFOR := '000001'
			RC3->RC3_SEQPAI := '000000'
			RC3->RC3_TIPO	:= '.CON.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := ''
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := '( EMPTY(POSICIONE("RCC",1,XFILIAL("RCC") + "U002","RCC->RCC_CONTEU")) )'
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK1'
			RC3->RC3_RESOU2 := 'PMSTASK1'
			
			RC3->(MsUnlock())	
		
			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCHKTAB       '
			RC3->RC3_DESCR  := 'Help(" ",1,"Tabela U002  NAO CADASTRADA")'
			RC3->RC3_SEQFOR := '000002'
			RC3->RC3_SEQPAI := '000001'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := "Help('	',1,'Tabela U002  NAO CADASTRADA')"
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.CNT.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())	

			RecLock("RC3", .T.)
			
			RC3->RC3_FILIAL := IIF(Empty(xFilial("RC3")),xFilial("RC3"),aFilRC3[nFil])
			RC3->RC3_ORIGEM	:= "U_"
			RC3->RC3_CODIGO := 'FWCHKTAB       '
			RC3->RC3_DESCR  := 'FINALCALC()'
			RC3->RC3_SEQFOR := '000003'
			RC3->RC3_SEQPAI := '000001'
			RC3->RC3_TIPO	:= '.EXE.'
			RC3->RC3_TPRESU := '5'
			RC3->RC3_RESULT := 'FINALCALC()'
			RC3->RC3_OPERA1	:= ''
			RC3->RC3_TPFM01 := '5'
			RC3->RC3_FORM01 := ''
			RC3->RC3_OPERA2 := ''
			RC3->RC3_TPFM02 := '5'
			RC3->RC3_FORM02 := ''
			RC3->RC3_OPERA3	:= '.END.'
			RC3->RC3_RESOU1 := 'PMSTASK4'
			RC3->RC3_RESOU2 := 'PMSTASK4'
			
			RC3->(MsUnlock())	

		EndIf
	Next
	
	If Empty(xFilial("SRM"))
		aFilSRM := {cFilAnt}
	Else
		aTodasFil := FWAllFilial(cEmpAnt,,,.F.)
		For nFil := 1 To Len(aTodasFil)
			cFilSRM := PadR(Left(aTodasFil[nFil],nTamFilSRM),nTamFil)
			If ( AScan(aFilSRM,{|x| x == cFilSRM }) == 0 )
				AAdd(aFilSRM,cFilSRM)
			EndIf
		Next
	EndIf
	
	For nFil := 1 To Len(aFilSRM)
		SRM->(DbSetOrder(1))
		If !SRM->(DbSeek(IIF(Empty(xFilial("SRM")),xFilial("SRM"),aFilSRM[nFil]) + "PLA00041"))
			
			RecLock("SRM", .T.)
			SRM->RM_FILIAL  := IIF(Empty(xFilial("SRM")),xFilial("SRM"),aFilSRM[nFil])
			SRM->RM_CALCULO := 'PLA'
			SRM->RM_SEQ	    := '00041'
			SRM->RM_SUBSEQ := ''
			SRM->RM_DESCRIC := 'EFETUA CALCULO DO PLANO DE SAUDE REDE DO'
			SRM->RM_IF		:= ''
			SRM->RM_VERBA   := ''
			SRM->RM_FORMULA := 'U_FWCALPLA()'
			SRM->RM_FALSE	:= ''
			SRM->RM_HABILIT := '1'
			SRM->RM_CODFOR := 'U_FWCALPLA'
			
			SRM->(MsUnlock())
		EndIf
		If !SRM->(DbSeek(IIF(Empty(xFilial("SRM")),xFilial("SRM"),aFilSRM[nFil]) + "FOL00501"))
			
			RecLock("SRM", .T.)
			SRM->RM_FILIAL  := IIF(Empty(xFilial("SRM")),xFilial("SRM"),aFilSRM[nFil])
			SRM->RM_CALCULO := 'FOL'
			SRM->RM_SEQ	    := '00501'
			SRM->RM_SUBSEQ := ''
			SRM->RM_DESCRIC := 'VERIFICA EXISTENCIA TABELA U002        '
			SRM->RM_IF		:= ''
			SRM->RM_VERBA   := ''
			SRM->RM_FORMULA := 'U_FWCHKTAB()'
			SRM->RM_FALSE	:= ''
			SRM->RM_HABILIT := '1'
			SRM->RM_CODFOR := 'U_FWCHKTAB'
			
			SRM->(MsUnlock())
			
		EndIf

		If !SRM->(DbSeek(IIF(Empty(xFilial("SRM")),xFilial("SRM"),aFilSRM[nFil]) + "FOL00871"))
			
			RecLock("SRM", .T.)
			SRM->RM_FILIAL  := IIF(Empty(xFilial("SRM")),xFilial("SRM"),aFilSRM[nFil])
			SRM->RM_CALCULO := 'FOL'
			SRM->RM_SEQ	    := '00871'
			SRM->RM_SUBSEQ := ''
			SRM->RM_DESCRIC := 'CALCULO EXCEDENTE COPARTICIPACAO        '
			SRM->RM_IF		:= ''
			SRM->RM_VERBA   := ''
			SRM->RM_FORMULA := 'U_FWCOPART()'
			SRM->RM_FALSE	:= ''
			SRM->RM_HABILIT := '1'
			SRM->RM_CODFOR := 'U_FWCOPART'
			
			SRM->(MsUnlock())
			
		EndIf

	Next
	
	If Empty(xFilial("RCA"))
		aFilRCA := {cFilAnt}
	Else
		aTodasFil := FWAllFilial(cEmpAnt,,,.F.)
		For nFil := 1 To Len(aTodasFil)
			cFilRCA := PadR(Left(aTodasFil[nFil],nTamFilRCA),nTamFil)
			If ( AScan(aFilRCA,{|x| x == cFilRCA }) == 0 )
				AAdd(aFilRCA,cFilRCA)
			EndIf
		Next
	EndIf
	
	For nFil := 1 To Len(aFilRCA)
		RCA->(DbSetOrder(1))
		
		If !RCA->(DbSeek(IIF(Empty(xFilial("RCA")),xFilial("RCA"),aFilRCA[nFil]) + "M_COPSALBS      "))
			
			
			
			RecLock("RCA", .T.)
			RCA->RCA_FILIAL		:= IIF(Empty(xFilial("RCA")),xFilial("RCA"),aFilRCA[nFil])
			RCA->RCA_MNEMON		:= 'M_COPSALBS'
			RCA->RCA_DESC		:= 'SALARIO BASE COPARTICIPACAO'
			RCA->RCA_TIPO 	 	:= 'N'
			RCA->RCA_CONTEU 	:= 'GetValType("N")'
			RCA->RCA_ACUMUL		:= '2'
			RCA->RCA_ALIAS   	:= ''
			RCA->RCA_CAMPO	 	:= ''
			
			RCA->(MsUnlock())
		EndIf
		If !RCA->(DbSeek(IIF(Empty(xFilial("RCA")),xFilial("RCA"),aFilRCA[nFil]) + "M_LIMCOPA       "))
			
			
			RecLock("RCA", .T.)
			RCA->RCA_FILIAL		:= IIF(Empty(xFilial("RCA")),xFilial("RCA"),aFilRCA[nFil])
			RCA->RCA_MNEMON		:= 'M_LIMCOPA'
			RCA->RCA_DESC		:= 'LIMITE COPARTICIPCAO'
			RCA->RCA_TIPO 	 	:= 'N'
			RCA->RCA_CONTEU 	:= 'GetValType("N")'
			RCA->RCA_ACUMUL		:= '2'
			RCA->RCA_ALIAS   	:= ''
			RCA->RCA_CAMPO	 	:= ''
			
			RCA->(MsUnlock())
		EndIf
		
		If !RCA->(DbSeek(IIF(Empty(xFilial("RCA")),xFilial("RCA"),aFilRCA[nFil]) + "M_PLAPDEP       "))
			
			
			RecLock("RCA", .T.)
			RCA->RCA_FILIAL		:= IIF(Empty(xFilial("RCA")),xFilial("RCA"),aFilRCA[nFil])
			RCA->RCA_MNEMON		:= 'M_PLAPDEP'
			RCA->RCA_DESC		:= 'PLANO DE SAUDE QUE NAO DESCONTA 1º DEPENDENTE'
			RCA->RCA_TIPO 	 	:= 'C'
			RCA->RCA_CONTEU 	:= ''
			RCA->RCA_ACUMUL		:= '2'
			RCA->RCA_ALIAS   	:= ''
			RCA->RCA_CAMPO	 	:= ''
			
			RCA->(MsUnlock())
		EndIf
		If !RCA->(DbSeek(IIF(Empty(xFilial("RCA")),xFilial("RCA"),aFilRCA[nFil]) + "M_RESULT        "))
			
			
			RecLock("RCA", .T.)
			RCA->RCA_FILIAL		:= IIF(Empty(xFilial("RCA")),xFilial("RCA"),aFilRCA[nFil])
			RCA->RCA_MNEMON		:= 'M_RESULT'
			RCA->RCA_DESC		:= 'RESULTADO'
			RCA->RCA_TIPO 	 	:= 'N'
			RCA->RCA_CONTEU 	:= 'GetValType("N")'
			RCA->RCA_ACUMUL		:= '2'
			RCA->RCA_ALIAS   	:= ''
			RCA->RCA_CAMPO	 	:= ''
			
			RCA->(MsUnlock())
		EndIf
		
		
		If !RCA->(DbSeek(IIF(Empty(xFilial("RCA")),xFilial("RCA"),aFilRCA[nFil]) + "M_TOTCOPA       "))
			
			RecLock("RCA", .T.)
			RCA->RCA_FILIAL		:= IIF(Empty(xFilial("RCA")),xFilial("RCA"),aFilRCA[nFil])
			RCA->RCA_MNEMON		:= 'M_TOTCOPA'
			RCA->RCA_DESC		:= 'TOTAL COPARTICIPACAO'
			RCA->RCA_TIPO 	 	:= 'N'
			RCA->RCA_CONTEU 	:= 'GetValType("N")'
			RCA->RCA_ACUMUL		:= '2'
			RCA->RCA_ALIAS   	:= ''
			RCA->RCA_CAMPO	 	:= ''
			
			RCA->(MsUnlock())
		EndIf
		
		
		If !RCA->(DbSeek(IIF(Empty(xFilial("RCA")),xFilial("RCA"),aFilRCA[nFil]) +  "M_VALDEV        "))
			
			RecLock("RCA", .T.)
			RCA->RCA_FILIAL		:= IIF(Empty(xFilial("RCA")),xFilial("RCA"),aFilRCA[nFil])
			RCA->RCA_MNEMON		:= 'M_VALDEV'
			RCA->RCA_DESC		:= 'VALOR DEVOLUCAO ACIMA DO LIMITE COPARTICIPACAO'
			RCA->RCA_TIPO 	 	:= 'N'
			RCA->RCA_CONTEU 	:= 'GetValType("N")'
			RCA->RCA_ACUMUL		:= '2'
			RCA->RCA_ALIAS   	:= ''
			RCA->RCA_CAMPO	 	:= ''
			
			RCA->(MsUnlock())
		EndIf
		
		If !RCA->(DbSeek(IIF(Empty(xFilial("RCA")),xFilial("RCA"),aFilRCA[nFil]) + "M_VALLIM        "))
			
			RecLock("RCA", .T.)
			RCA->RCA_FILIAL		:= IIF(Empty(xFilial("RCA")),xFilial("RCA"),aFilRCA[nFil])
			RCA->RCA_MNEMON		:= 'M_VALLIM'
			RCA->RCA_DESC		:= 'VALOR LIMITE COPARTICIPACAO'
			RCA->RCA_TIPO 	 	:= 'N'
			RCA->RCA_CONTEU 	:= 'GetValType("N")'
			RCA->RCA_ACUMUL		:= '2'
			RCA->RCA_ALIAS   	:= ''
			RCA->RCA_CAMPO	 	:= ''
			
			RCA->(MsUnlock())
		EndIf
		
		
		If !RCA->(DbSeek(IIF(Empty(xFilial("RCA")),xFilial("RCA"),aFilRCA[nFil]) + "M_VERCOPA       "))
			
			RecLock("RCA", .T.)
			RCA->RCA_FILIAL		:= IIF(Empty(xFilial("RCA")),xFilial("RCA"),aFilRCA[nFil])
			RCA->RCA_MNEMON		:= 'M_VERCOPA'
			RCA->RCA_DESC		:= 'VERBAS DESCONTO DE COPARTICIPACAO'
			RCA->RCA_TIPO 	 	:= 'C'
			RCA->RCA_CONTEU 	:= ''
			RCA->RCA_ACUMUL		:= '2'
			RCA->RCA_ALIAS   	:= ''
			RCA->RCA_CAMPO	 	:= ''
			
			RCA->(MsUnlock())
		EndIf
		
	Next
	
Return

