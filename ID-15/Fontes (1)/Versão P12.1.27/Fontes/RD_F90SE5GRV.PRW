#Include 'Protheus.ch'

/*
{Protheus.doc}  F90SE5GRV()
PE utilizado para fazer a reposição de caixinha e baixa de despesas para títulos de reposição na rotina de baixa automática. 
@Author  Ramon Teodoro e Silva	
@Since   25/07/2019       
@Version P12.7
*/

User Function F90SE5GRV()

Local lRet     := .T.
Local aArea     := GetArea()
Local nSaldoAn  := 0
Local nValRep   := SE2->E2_VALOR
Local cCaixa    := SE2->E2_XCAIXIN
Local cSeqCxAnt := ""  

If !Empty(cCaixa) //.And. Alltrim(SE2->E2_ORIGEM) == "FINA550"

	_aAreaCx := GetArea() //12912589 - Thais Paiva

	DbSelectArea("SET")
	DbSetOrder(1)
	DbGoTop()
	
	PcoIniLan("000359")
	
	If DbSeek(xFilial("SET")+cCaixa)
		
		nSaldoAn := SET->ET_SALDO

		If ((SET->ET_SALDO+nValRep)>SET->ET_VALOR) 
			MsgAlert("Valor de reposição maior que o permitido", "Erro no momento da reposição do caixinha") //"Valor maior que o permitido."
			lRet := .F.
		Else
			
			cSeqCxAnt := U_RetSeqAnt(cCaixa, SE2->E2_NUM) 
			
			//Baixa das despesas
          	DbSelectArea("SEU")
			SEU->(DbSetOrder(5))  // filial + caixa + sequencia + num
			SEU->(DbSeek( xFilial("SEU")+ cCaixa + cSeqCxAnt))
			While !SEU->(Eof()) .And. xFilial("SEU")+cCaixa+cSeqCxAnt == SEU->(EU_FILIAL+EU_CAIXA+EU_SEQCXA)
	
				If SEU->EU_TIPO == "00" .And. Empty(SEU->EU_BAIXA) .And. SEU->EU_XNUMTIT == SE2->E2_NUM
					RecLock("SEU", .F.)
					SEU->EU_BAIXA := dDataBase
					SEU->(MsUnLock())
				Endif
	
				SEU->(DbSkip())
			End
			
			//Reposição
			RecLock("SET",.F.)
			SET->ET_SALDO  := nSaldoAn+ nValRep
			SET->ET_ULTREP := dDataBase
			SET->ET_SALANT := nSaldoAn
			//If nSaldoAn > 0
			//	SET->ET_SEQCXA := SOMA1(SET->ET_SEQCXA)
			//EndIf
			MsUnlock()
			PcoDetLan("000359","01","FINA550")
					
			Fa550Mov( SET->ET_CODIGO, "10", nValRep,"Reposição de Banco"+SET->ET_BANCO)
			AtuSalCxa( SET->ET_CODIGO, dDataBase, nValRep, .F. )
			
		EndIf
				
	EndIf
	
	PcoFinLan("000359")

	RestArea(_aAreaCx) //12912589 - Thais Paiva
EndIf

//Início - 12912589 - Thais Paiva
If FUNNAME() == "FINA091"
	Reclock("SE5",.F.)
	SE5->E5_XLOGMOV := USRFULLNAME(__cuserid)
	SE5->E5_XHORMOV := Time()
	SE5->E5_XDATMOV := Date()
	MsUnLock()
EndIf
//Fim - 12912589 - Thais Paiva

RestArea(aArea)
Return lRet

